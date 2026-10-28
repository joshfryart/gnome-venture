-- variety-act-h7.lua : regional rest-stop activity scenes (group h7) -> act-<slug>.png (144x108, 72x54 grid, out=2). Param only=<slug>, out=<dir>/
local ROOT = "/home/user/gnome-venture/"
local GV = dofile(ROOT .. "aseprite-source/gvlib/gvlib.lua")
local OUT = app.params.out or (ROOT .. "aseprite-source/extras-pixel/png/")
local ASE = ROOT .. "aseprite-source/extras-pixel/aseprite/"
local FRAME_SRC = ROOT .. "game/assets/img/acts/act-hand.png"
local only = app.params.only
local floor = math.floor
local function rnd(v) return floor(v + 0.5) end

local INK, UMB = "#2a1a10", "#4a2c1a"
local W, H = 72, 54

---------------------------------------------------------------- helpers
local function new() return GV.canvas{ w = W, h = H, mode = "scene", out = 2, ol = 1, olx = 0, cres = 2, deep = 1 } end

-- flat (or shaded) outlined prop part
local function part(c, m, hex, o)
  o = o or {}
  local ov = {}
  if not o.shade then ov.rim = hex end
  local op = { flat = not o.shade, gloss = false, cres = o.cres or 2, deep = o.deep or 1, contact = false }
  if o.noline then op.outline = false; op.contour = false end
  return c:part(m, GV.ramp(hex, ov), op)
end
-- plain fill with no outline
local function fl(c, m, hex) c:fill(m, hex); return m end
local function R(c, x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end

local FRAME
local function frame(c)
  if not FRAME then FRAME = Image{ fromFile = FRAME_SRC } end
  for gy = 0, H - 1 do for gx = 0, W - 1 do
    if not (gx >= 5 and gx <= 68 and gy >= 5 and gy <= 49) then
      local v = FRAME:getPixel(gx * 2, gy * 2)
      if app.pixelColor.rgbaA(v) > 0 then
        c:px(gx, gy, string.format("#%02x%02x%02x", app.pixelColor.rgbaR(v), app.pixelColor.rgbaG(v), app.pixelColor.rgbaB(v)))
      end
    end
  end end
end

local function finish(c, slug)
  frame(c)
  local ase, png = ASE .. "variety-act-" .. slug .. ".aseprite", OUT .. "act-" .. slug .. ".png"
  local t = c:save(ase, png)
  print(slug, GV.report(t))
  assert(t.semi == 0 and t.bw == 0)
  -- the shipped frame has a 2x2 transparent notch at each corner: clear them, then rewrite both files
  local spr = app.open(ase)
  local img = spr.cels[1].image
  for _, p in ipairs({ { 0, 0 }, { 142, 0 }, { 0, 106 }, { 142, 106 } }) do
    for dx = 0, 1 do for dy = 0, 1 do img:putPixel(p[1] + dx, p[2] + dy, 0) end end
  end
  spr:saveAs(ase)
  spr:saveCopyAs(png)
  spr:close()
end

-- rng
local seed = 7
local function rand() seed = (seed * 1103515245 + 12345) % 2147483648; return seed / 2147483648 end

-- sky + hills + grass for a daylight meadow. g = grass line.
local function day(c, g, opt)
  opt = opt or {}
  local sky = opt.sky or { "#a8d4e0", "#bcdde4", "#cfe8e6" }
  c:bands(R(c, 0, 0, W - 1, g), sky, { dir = "v" })
  if opt.cloud ~= false then
    local cx = opt.cloud or 14
    c:fill(c:ellipse(cx, 10, 8, 2), "#f4eee0"); c:fill(c:ellipse(cx + 4, 8, 5, 2), "#f4eee0")
  end
  local hc = opt.hill or "#5e8a44"
  c:fill(c:ellipse(18, g + 2, 34, 11), hc)
  c:fill(c:ellipse(60, g + 3, 30, 9), opt.hill2 or "#4e8a3c")
  c:fill(R(c, 0, g, W - 1, H - 1), opt.grass or "#7ea85a")
  c:fill(R(c, 0, g, W - 1, g), opt.edge or "#9cc070")
  for i = 1, 14 do
    local x, y = floor(rand() * 66) + 3, g + 2 + floor(rand() * (H - g - 4))
    c:px(x, y, "#5e8a44"); c:px(x + 1, y - 1, "#5e8a44")
  end
end

-- a pine built of stacked row-triangles (snow caps optional)
local function pine(c, x, yb, h, snow)
  part(c, R(c, x - 1, yb - 3, x, yb), "#5e3f28", { noline = true })
  local tiers = 3
  local th = floor((h - 2) / 2)
  local m = c:mask()
  local caps = c:mask()
  for t = 0, tiers - 1 do
    local top = yb - 3 - h + 2 + t * floor((h - 4) / tiers)
    local hh = th
    local w = 2 + t * 2
    for i = 0, hh - 1 do
      local hw = floor(i * w / (hh - 1) + 0.5)
      m:add(c:rect(x - hw - 1, top + i, x + hw, top + i))
      if i <= 1 then caps:add(c:rect(x - hw - 1, top + i, x + hw, top + i)) end
    end
  end
  part(c, m, "#2f5a2a")
  if snow then c:fill(caps, "#f4f8fa") end
end

---------------------------------------------------------------- the gnome
-- Parametric by scale s (1 = the 10x18 gnome of the shipped cards). Base units: x cells from the centre, u rows up from the feet row.
-- o: d = facing (1 right, -1 left), s = scale, upper = no legs, sit = seated (hips at oy, legs forward), walk = 1/-1 stride,
--    eyes = "open"|"shut"|"happy", hat = hex, arms = { {a={dx,u}, b={dx,u}, front=bool, nohand=bool}, ... } (base units from feet-centre)
-- returns sil, G where G.P(dx,u) -> absolute x,y ; G.hat = hat mask ; G.tip = x,y of the hat tip
local function gnome(c, ox, oy, o)
  o = o or {}
  local d, s = o.d or 1, o.s or 1
  local BODY, BEARD, SKIN, BOOT = "#4a6e9a", "#f4eee0", "#f0c8a0", "#5a3a22"
  local hatc = o.hat or "#c0442e"
  local hatd = (o.hat and "#8a4a1a") or "#8e2e1e"
  local sil = c:mask()
  local function X(v) return ox + rnd(v * s) end
  local function Yp(u) return oy - rnd(u * s) end
  local function rx(x0, x1)
    if d < 0 then x0, x1 = -x1, -x0 end
    return ox + rnd(x0 * s), ox + math.max(rnd(x0 * s), rnd((x1 + 1) * s) - 1)
  end
  local function ry(u0, u1)
    local y0, y1 = oy + 1 - rnd((u1 + 1) * s), oy - rnd(u0 * s)
    if y0 > y1 then y0 = y1 end
    return y0, y1
  end
  local function rc(x0, u0, x1, u1) -- rect in base cell units (x mirrored by facing)
    local a, b = rx(x0, x1); local e, f = ry(u0, u1)
    return c:rect(a, e, b, f)
  end
  local function sym(x0, u0, x1, u1) -- symmetric rect (no mirroring)
    local a, b = ox + rnd(x0 * s), ox + math.max(rnd(x0 * s), rnd((x1 + 1) * s) - 1)
    local e, f = ry(u0, u1)
    return c:rect(a, e, b, f)
  end
  local function pp(m, hex)
    c:part(m, GV.ramp(hex, { rim = hex }), { flat = true, gloss = false, contact = false, outline = false, contour = false })
    sil:add(m)
  end
  local G = {}
  function G.P(dx, u) return X(dx), Yp(u) end
  -- legs
  if not o.upper then
    if o.sit then
      pp(rc(2, 0, 7, 2), BODY)                  -- thigh forward
      pp(rc(6, -4, 7, 0), BODY)                 -- shin
      pp(rc(6, -6, 9, -5), BOOT)                -- boot
    else
      local bl, br = { -4, 0, -1, 1 }, { 1, 0, 4, 1 }
      if o.walk and o.walk > 0 then br = { 2, 1, 5, 2 } elseif o.walk and o.walk < 0 then bl = { -5, 1, -2, 2 } end
      pp(sym(bl[1], bl[2], bl[3], bl[4]), BOOT); pp(sym(br[1], br[2], br[3], br[4]), BOOT)
      pp(sym(bl[1] + 1, bl[2] + 2, bl[3] - 1, bl[2] + 3), BODY); pp(sym(br[1] + 1, br[2] + 2, br[3] - 1, br[2] + 3), BODY)
    end
  end
  pp(sym(-4, 2, 4, 8), BODY)
  local function arms(front)
    for _, a in ipairs(o.arms or {}) do
      if (a.front or false) == front then
        local t = math.max(2, rnd(2 * s))
        local ax, ay = X(a.a[1]), Yp(a.a[2])
        local bx, by = X(a.b[1]), Yp(a.b[2])
        pp(c:line({ { ax, ay }, { bx, by } }, t), a.sleeve or BODY)
        if not a.nohand then
          local hs = math.max(2, rnd(2 * s))
          pp(c:rect(bx - 0, by - 0, bx + hs - 1, by + hs - 1):shift(-floor(hs / 2) + 0, -floor(hs / 2)), SKIN)
        end
      end
    end
  end
  arms(false)
  local beard = sym(-3, 5, 3, 9); beard:add(sym(-3, 5, 3, 9)); beard:add(sym(-2, 2, 2, 5))
  local bb = c:rect(ox + rnd(-3 * s), select(1, ry(2, 9)), ox + rnd(4 * s) - 1, select(2, ry(2, 9)))
  -- round the beard bottom corners
  bb:del(ox + rnd(-3 * s), select(2, ry(2, 9))); bb:del(ox + rnd(4 * s) - 1, select(2, ry(2, 9)))
  pp(bb, BEARD)
  -- face
  pp(sym(-3, 10, 3, 11), SKIN)
  local fy0, fy1 = ry(10, 11)
  local ey = fy1
  local c1, c2 = (d > 0) and -1 or -2, (d > 0) and 2 or 1
  local e1a, e1b = ox + rnd(c1 * s), ox + rnd(c2 * s)
  local eh = math.max(1, rnd(s))
  local function eye(x, col) for k = 0, eh - 1 do c:px(x, ey - k, col) end end
  if o.eyes == "shut" then
    eye(e1a, "#8a4a34"); eye(e1b, "#8a4a34")
    c:px(e1a - 1, ey - eh + 1, "#8a4a34"); c:px(e1b + 1, ey - eh + 1, "#8a4a34")
  elseif o.eyes == "happy" then
    c:px(e1a, ey - eh, INK); c:px(e1b, ey - eh, INK)
    c:px(e1a - 1, ey - eh + 1, INK); c:px(e1a + 1, ey - eh + 1, INK); c:px(e1b - 1, ey - eh + 1, INK); c:px(e1b + 1, ey - eh + 1, INK)
    c:px(e1a, ey - eh + 1, "#f0c8a0"); c:px(e1b, ey - eh + 1, "#f0c8a0")
  else
    eye(e1a, INK); eye(e1b, INK)
  end
  local nx = ox + d * rnd(3 * s) + (d < 0 and 0 or 0)
  for yy = fy1 - math.max(0, rnd(s) - 1), fy1 do c:px(nx, yy, "#e08a7a") end
  arms(true)
  -- hat: cone with a bent tip, then the brim
  local hy0, _ = ry(13, 18)
  local _, hy1 = ry(13, 13)
  local hat = c:mask()
  local n = hy1 - hy0
  for yy = hy0, hy1 do
    local fr = (n == 0) and 1 or (yy - hy0) / n
    local hw = rnd(fr * 3.2 * s)
    local shift = (yy - hy0 <= math.max(1, rnd(s))) and -d or 0
    hat:add(c:rect(ox - hw + shift, yy, ox + hw + shift, yy))
  end
  local by0, by1 = ry(12, 12)
  local brim = c:rect(ox + rnd(-4 * s), by0, ox + rnd(5 * s) - 1, by1)
  hat:add(brim)
  pp(hat, hatc)
  pp(brim, hatd)
  G.hat = hat; G.tipx, G.tipy = ox - d, hy0
  if o.band then c:fill(c:rect(ox + rnd(-3 * s), hy1 - 1, ox + rnd(3 * s), hy1 - 1), o.band) end
  c:outline(sil, { ol = 1, olx = 0 })
  return sil, G
end

local function arm(a, b, front, nohand) return { a = a, b = b, front = front, nohand = nohand } end


local S = {}
local ORDER = {}
local function scene(name, fn) S[name] = fn; ORDER[#ORDER + 1] = name end

-- shared small props
local function goat(c, x, y, d, col, bell)
  col = col or "#f4eee0"
  local sh = (col == "#f4eee0") and "#cfc8b8" or "#6b4a30"
  part(c, c:ellipse(x, y - 4, 4, 2), col)                     -- body
  part(c, R(c, x - 3, y - 2, x - 2, y), sh); part(c, R(c, x + 2, y - 2, x + 3, y), sh)   -- legs
  part(c, R(c, x + d * 3, y - 8, x + d * 4 + (d > 0 and 1 or 0), y - 5), col)            -- head
  fl(c, R(c, x + d * 4, y - 6, x + d * 5, y - 5), "#d9c8a8")
  c:px(x + d * 3 + (d > 0 and 1 or 0), y - 7, INK)
  fl(c, R(c, x + d * 3, y - 10, x + d * 3, y - 9), "#8a6a4a")
  c:px(x + d * 4, y - 3, sh)
  fl(c, R(c, x - d * 4, y - 6, x - d * 4, y - 5), col)        -- tail
  if bell then part(c, R(c, x + d * 2, y - 3, x + d * 3, y - 2), "#f5cf6a") end
end

local function tuft(c, x, y, col) c:px(x, y, col or "#5e8a44"); c:px(x + 1, y - 1, col or "#5e8a44") end

-- 1. forced rhubarb: lifting a tall clay forcing pot to show pink stalks
scene("r_nwe_forced_rhubarb", function()
  seed = 3
  local c = new()
  day(c, 30, { sky = { "#b8cfd8", "#cfdde0", "#e0e8e6" }, cloud = 50, grass = "#8a7a52", edge = "#a89a6a", hill = "#6e8a58", hill2 = "#5e7a4c" })
  c:fill(c:ellipse(60, 31, 10, 2), "#f4f8fa"); c:fill(c:ellipse(8, 31, 6, 1), "#f4f8fa")
  c:fill(R(c, 5, 36, 68, 49), "#5e3f2e")
  for _, p in ipairs({ { 10, 40 }, { 20, 44 }, { 52, 40 }, { 63, 45 }, { 44, 47 } }) do c:fill(R(c, p[1], p[2], p[1] + 3, p[2]), "#4a2c1e") end
  -- bed with pink stalks under the lifted pot
  c:fill(R(c, 31, 41, 44, 44), "#6e4a34")
  for i, x in ipairs({ 32, 35, 38, 41 }) do
    part(c, R(c, x, 31 + (i % 2) * 2, x + 1, 43), "#e0607a", { noline = true })
    fl(c, R(c, x - 1, 29 + (i % 2) * 2, x + 2, 31 + (i % 2) * 2), "#e8d060")
  end
  -- two covered pots
  local function pot(x, y, lift)
    part(c, c:poly({ { x - 3, y - 14 }, { x + 3, y - 14 }, { x + 5, y }, { x - 5, y } }), "#c4623a", { shade = true })
    part(c, R(c, x - 4, y - 16, x + 4, y - 14), "#d4743e")
    fl(c, R(c, x - 1, y - 18, x + 1, y - 17), "#8a4a2a")
  end
  pot(57, 46); pot(66, 44)
  -- gnome lifting the pot (arm raised), ear cocked
  gnome(c, 20, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 11, 10 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  local px, py = 33, 20
  part(c, c:poly({ { px - 3, py }, { px + 3, py }, { px + 5, py + 14 }, { px - 5, py + 14 } }), "#c4623a", { shade = true })
  part(c, R(c, px - 4, py + 12, px + 4, py + 14), "#d4743e")
  fl(c, R(c, px - 1, py - 3, px + 1, py - 1), "#8a4a2a")
  c:px(29, 36, "#f4f8fa"); c:px(26, 31, "#f4f8fa")
  finish(c, "r_nwe_forced_rhubarb")
end)

-- 2. hazel conkers: two gnomes swinging hazelnuts on strings, autumn hedgerow
scene("r_nwe_hazel_conkers", function()
  seed = 8
  local c = new()
  day(c, 38, { sky = { "#e0cf9e", "#ead8a8", "#efe0b8" }, cloud = 52, hill = "#8a8a44", hill2 = "#7a8a40", grass = "#9a9a4c", edge = "#b0b05c" })
  -- autumn hedgerow
  for _, b in ipairs({ { 10, 26, 10, 7, "#b8662a" }, { 22, 24, 9, 8, "#8a8a2e" }, { 36, 26, 11, 7, "#c88a30" }, { 50, 24, 10, 8, "#a85a28" }, { 63, 26, 9, 7, "#8a8a2e" } }) do
    part(c, c:ellipse(b[1], b[2], b[3], b[4]), b[5], { shade = true })
  end
  for _, p in ipairs({ { 12, 24 }, { 28, 27 }, { 46, 23 }, { 58, 27 }, { 66, 24 } }) do c:fill(c:ellipse(p[1], p[2], 1, 1), "#8a2a3a") end
  c:fill(R(c, 5, 31, 68, 38), "#6e7a38")
  fl(c, R(c, 5, 31, 68, 31), "#7e8a40")
  gnome(c, 19, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 14 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  gnome(c, 53, 47, { d = -1, hat = "#4f9a45", eyes = "open", arms = { arm({ -4, 8 }, { -9, 13 }, true), arm({ 4, 6 }, { 5, 3 }, false) } })
  -- strings with a swinging nut each, meeting in the middle
  c:fill(c:line({ { 28, 33 }, { 30, 38 } }, 1), "#5e3f28"); c:fill(c:line({ { 44, 34 }, { 40, 38 } }, 1), "#5e3f28")
  part(c, c:ellipse(31, 40, 2, 2), "#b07a45"); fl(c, R(c, 30, 38, 32, 38), "#8a5a35")
  part(c, c:ellipse(39, 40, 2, 2), "#b07a45"); fl(c, R(c, 38, 38, 40, 38), "#8a5a35")
  c:px(35, 39, "#f5cf6a"); c:px(35, 41, "#f5cf6a"); c:px(34, 40, "#f5cf6a"); c:px(36, 40, "#f5cf6a")
  fl(c, R(c, 10, 47, 11, 48), "#b8662a"); fl(c, R(c, 36, 48, 37, 49), "#c88a30")
  finish(c, "r_nwe_hazel_conkers")
end)

-- 3. twig race: leaning over a ferry rail dropping a twig into the river, others already floating
scene("r_nwe_twig_race", function()
  seed = 12
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 20), { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  c:fill(c:ellipse(16, 20, 28, 6), "#5e8a44"); c:fill(c:ellipse(60, 21, 26, 5), "#4e8a3c")
  c:fill(R(c, 0, 20, W - 1, 41), "#4f8fb4")
  for y = 22, 36, 4 do for x = (y % 8 == 0) and 6 or 12, 68, 14 do fl(c, R(c, x, y, x + 5, y), "#8fc8dc") end end
  -- twigs floating downstream (left)
  part(c, R(c, 10, 26, 22, 27), "#8a5a35"); fl(c, R(c, 14, 28, 18, 28), "#6ab4c8")                    -- fat
  part(c, R(c, 26, 28, 34, 28), "#8a5a35"); fl(c, R(c, 29, 26, 32, 27), "#4e9a48"); fl(c, R(c, 27, 29, 31, 29), "#4e9a48")  -- leafy
  fl(c, R(c, 46, 29, 54, 29), "#6b4a2e")
  -- deck + rail in front
  c:fill(R(c, 5, 42, 68, 49), "#a8703e")
  for x = 8, 68, 9 do fl(c, R(c, x, 42, x, 49), "#7a4a2a") end
  fl(c, R(c, 5, 42, 68, 42), "#c08a52")
  for x = 9, 66, 9 do part(c, R(c, x, 33, x + 1, 42), "#6b4a2e", { noline = true }) end
  part(c, R(c, 5, 31, 68, 33), "#d9a660")
  fl(c, R(c, 5, 31, 68, 31), "#ecc47e")
  gnome(c, 56, 49, { d = -1, eyes = "open", arms = { arm({ -4, 8 }, { -9, 9 }, true) } })
  -- twig dropped from the hand, falling toward the water
  part(c, R(c, 41, 36, 46, 37), "#6b4a2e")
  fl(c, R(c, 39, 39, 39, 40), "#cfe8e6"); fl(c, R(c, 38, 35, 38, 36), "#cfe8e6")
  finish(c, "r_nwe_twig_race")
end)

-- 4. puddle jump: rainy market square, gnome mid-jump over a puddle with a big splash
scene("r_nwe_puddle_jump", function()
  seed = 6
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#7a8aa0", "#8a9ab0", "#9aa8bc", "#aab6c6" }, { dir = "v" })
  -- stalls with wet awnings
  local function stall(x0, x1, c1)
    part(c, R(c, x0 + 1, 22, x0 + 2, 38), "#6b4a2e", { noline = true }); part(c, R(c, x1 - 2, 22, x1 - 1, 38), "#6b4a2e", { noline = true })
    local n = 0
    for x = x0, x1 - 2, 3 do fl(c, R(c, x, 16, x + 2, 22), (n % 2 == 0) and c1 or "#e8e0d0"); n = n + 1 end
    c:outline(R(c, x0, 16, x1, 22))
    part(c, R(c, x0, 32, x1, 38), "#8a5a35")
  end
  stall(6, 26, "#3f6fb0"); stall(46, 66, "#c0442e")
  part(c, c:ellipse(12, 31, 2, 2), "#e0a030"); part(c, c:ellipse(18, 31, 2, 2), "#c0442e")
  c:fill(R(c, 0, 38, W - 1, H - 1), "#8a8a92")
  for y = 41, 49, 4 do for x = (y % 8 == 1) and 4 or 9, 70, 10 do fl(c, R(c, x, y, x + 4, y), "#74747c") end end
  -- puddle
  part(c, c:ellipse(36, 46, 22, 4), "#6a9ac0", { noline = true })
  c:fill(c:ellipse(36, 46, 22, 4), "#7ab0d4"); fl(c, R(c, 20, 45, 26, 45), "#a8d4ec"); fl(c, R(c, 46, 47, 52, 47), "#a8d4ec")
  -- gnome in the air
  gnome(c, 36, 38, { d = 1, eyes = "happy", walk = 1, arms = { arm({ -4, 8 }, { -9, 14 }, false), arm({ 4, 8 }, { 9, 14 }, true) } })
  -- splash crown
  for _, p in ipairs({ { 28, 43 }, { 30, 41 }, { 32, 43 }, { 40, 43 }, { 43, 41 }, { 45, 43 }, { 26, 45 }, { 47, 45 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#d8eef8") end
  -- rain
  seed = 20
  for i = 1, 38 do
    local x, y = 6 + floor(rand() * 62), 5 + floor(rand() * 40)
    c:px(x, y, "#cfe0ee"); c:px(x - 1, y + 1, "#cfe0ee")
  end
  finish(c, "r_nwe_puddle_jump")
end)

-- 5. downs kites: windy hill, gnome holding a string, three kites in the sky
scene("r_nwe_downs_kites", function()
  seed = 5
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 36), { "#7ab4d8", "#8cc2e0", "#a0d0e6", "#b8dcea" }, { dir = "v" })
  c:fill(c:ellipse(60, 22, 8, 2), "#f4eee0"); c:fill(c:ellipse(12, 30, 9, 2), "#f4eee0")
  c:fill(c:ellipse(54, 44, 30, 14), "#5e8a44")
  c:fill(c:ellipse(10, 48, 34, 14), "#6e9a4c")
  c:fill(R(c, 0, 44, W - 1, H - 1), "#6e9a4c")
  -- tower on the hill
  part(c, R(c, 56, 24, 62, 38), "#a8a29a"); part(c, R(c, 55, 20, 63, 24), "#8a847c")
  fl(c, R(c, 58, 28, 59, 31), "#3a3a44"); for x = 55, 63, 3 do fl(c, R(c, x, 19, x + 1, 19), "#8a847c") end
  -- kites
  local function kite(x, y, col, col2, tail)
    part(c, c:poly({ { x, y - 5 }, { x + 4, y }, { x, y + 6 }, { x - 4, y } }), col)
    fl(c, R(c, x, y - 4, x, y + 5), col2); fl(c, R(c, x - 3, y, x + 3, y), col2)
    for i = 1, tail do fl(c, R(c, x - (i % 2) * 2 + 1, y + 6 + i * 2, x - (i % 2) * 2 + 2, y + 7 + i * 2), (i % 2 == 0) and "#f5cf6a" or "#e0402e") end
  end
  kite(24, 14, "#dd3a2a", "#f4eee0", 3)
  kite(44, 9, "#f5cf6a", "#c0442e", 2)
  kite(60, 14, "#3f6fb0", "#f4eee0", 2)
  -- strings
  c:fill(c:line({ { 24, 20 }, { 26, 30 }, { 22, 38 } }, 1), "#f4eee0")
  c:fill(c:line({ { 44, 15 }, { 36, 30 }, { 24, 40 } }, 1), "#f4eee0")
  gnome(c, 18, 49, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 5, 15 }, true), arm({ -4, 8 }, { 4, 17 }, false) } })
  for _, p in ipairs({ { 30, 46 }, { 38, 48 }, { 8, 46 } }) do c:px(p[1], p[2], "#4a7a38"); c:px(p[1] + 1, p[2] - 1, "#4a7a38"); c:px(p[1] + 2, p[2] - 1, "#4a7a38") end
  for _, w in ipairs({ { 6, 26 }, { 34, 24 }, { 66, 30 } }) do fl(c, R(c, w[1], w[2], w[1] + 5, w[2]), "#f4f8fa"); c:px(w[1] + 6, w[2] + 1, "#f4f8fa") end
  finish(c, "r_nwe_downs_kites")
end)

-- 6. hedge flowers: pressing a sprig into a tin in front of a blooming hedge
scene("r_nwe_hedge_flowers", function()
  seed = 9
  local c = new()
  day(c, 34, { cloud = 14 })
  part(c, R(c, 5, 14, 68, 36), "#3f7a3a", { noline = true })
  for _, b in ipairs({ { 8, 15, 8 }, { 20, 13, 9 }, { 33, 15, 9 }, { 46, 13, 9 }, { 59, 15, 8 }, { 67, 14, 5 } }) do c:fill(c:ellipse(b[1], b[2], b[3], 4), "#4e9a42") end
  c:fill(R(c, 5, 18, 68, 36), "#3f7a3a")
  local cols = { "#f4eee0", "#f08ab4", "#f5cf6a", "#c070d8", "#e0402e" }
  seed = 31
  for i = 1, 34 do
    local x, y = 6 + floor(rand() * 62), 14 + floor(rand() * 21)
    local col = cols[i % 5 + 1]
    c:px(x, y, col); if i % 3 == 0 then c:px(x + 1, y, col); c:px(x, y + 1, col) end
  end
  fl(c, R(c, 5, 36, 68, 37), "#2f5a2a")
  gnome(c, 26, 48, { d = 1, eyes = "happy", arms = { arm({ 4, 8 }, { 9, 12 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  -- sprig in hand
  local sx, sy = 36, 33
  c:fill(c:line({ { sx, sy }, { sx + 1, sy - 5 } }, 1), "#4e9a42"); fl(c, R(c, sx - 1, sy - 8, sx + 2, sy - 6), "#f08ab4"); c:px(sx, sy - 7, "#f5cf6a")
  -- tin with pressed sprigs
  part(c, R(c, 46, 41, 60, 48), "#aeb4bc"); fl(c, R(c, 46, 41, 60, 42), "#d4d8dc")
  part(c, R(c, 46, 38, 60, 40), "#8b929c")
  c:fill(R(c, 48, 43, 58, 46), "#e8d9b0")
  for i, col in ipairs({ "#f4eee0", "#f08ab4", "#f5cf6a", "#c070d8" }) do fl(c, R(c, 49 + (i - 1) * 3, 44, 50 + (i - 1) * 3, 45), col) end
  finish(c, "r_nwe_hedge_flowers")
end)

-- 7. fell lichens: lens to a big lichen-patched boulder
scene("r_nwe_fell_lichens", function()
  seed = 15
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#8fa4b8", "#a0b4c4", "#b4c4cf", "#c8d4d8" }, { dir = "v" })
  c:fill(c:ellipse(14, 34, 30, 12), "#7a8a92"); c:fill(c:ellipse(62, 36, 26, 10), "#6e7e88")
  c:fill(R(c, 0, 35, W - 1, H - 1), "#7a8a62")
  c:fill(R(c, 0, 35, W - 1, 35), "#92a272")
  for _, p in ipairs({ { 8, 40 }, { 18, 46 }, { 62, 42 }, { 50, 48 } }) do tuft(c, p[1], p[2], "#5e6e48") end
  -- big boulder
  part(c, c:rrect(34, 20, 66, 47, 8), "#8e9298", { shade = true })
  local function patch(x, y, rx, ry, col, dot)
    c:fill(c:ellipse(x, y, rx, ry), col)
    if dot then for i = 0, 3 do c:px(x - rx + 2 + i * 2, y - 1 + (i % 2), dot) end end
  end
  patch(42, 27, 4, 3, "#e8a030", "#b87a1c"); patch(56, 25, 5, 2, "#a8c460", "#7a9a40"); patch(60, 36, 4, 3, "#e8d060", "#c8a830")
  patch(45, 40, 5, 3, "#9ac0a0", "#6e9a7a"); patch(51, 32, 3, 2, "#e8e0c8", "#bcb498")
  gnome(c, 20, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 12 }, true), arm({ -4, 7 }, { -4, 3 }, false) } })
  -- lens
  c:fill(c:line({ { 30, 35 }, { 34, 32 } }, 1), "#5e3f28")
  part(c, c:ellipse(37, 29, 4, 4), "#8a5a35")
  c:fill(c:ellipse(37, 29, 3, 3), "#d8eef4"); c:px(35, 27, "#f8fcfc"); c:px(36, 27, "#f8fcfc")
  c:fill(c:ellipse(37, 29, 1, 1), "#e8a030")
  -- notebook
  part(c, R(c, 8, 38, 13, 43), "#f4eee0"); fl(c, R(c, 8, 38, 8, 43), "#8a4a1a"); fl(c, R(c, 10, 40, 12, 40), "#8a8a8a")
  finish(c, "r_nwe_fell_lichens")
end)

-- 8. fairy ring: gnome watching a ring of toadstools, hands behind his back
scene("r_nwe_fairy_ring", function()
  seed = 22
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#9ab8a0", "#a8c4a8", "#b8d0b0", "#c8dcba" }, { dir = "v" })
  for _, x in ipairs({ 9, 24, 48, 62 }) do
    part(c, R(c, x - 1, 8, x + 1, 36), "#5e4a34", { noline = true })
    c:fill(c:ellipse(x, 8, 7, 6), "#3a6a3a"); c:fill(c:ellipse(x - 2, 6, 3, 2), "#4e8a42")
  end
  c:fill(R(c, 0, 30, W - 1, H - 1), "#5e8a4a"); c:fill(R(c, 0, 30, W - 1, 30), "#7aa65a")
  c:fill(c:ellipse(46, 41, 22, 8), "#72a052")
  for _, p in ipairs({ { 8, 36 }, { 16, 46 }, { 60, 36 }, { 66, 48 }, { 36, 34 } }) do tuft(c, p[1], p[2], "#4a7a3a") end
  -- the ring of toadstools (ellipse path)
  local caps = { "#dd3a2a", "#c08a52", "#c070d8", "#e8a030", "#dd3a2a", "#e8e0d0", "#c070d8", "#e8a030", "#dd3a2a", "#c08a52" }
  for i = 0, 9 do
    local a = i / 10 * 6.2832
    local x, y = floor(46 + math.cos(a) * 17 + 0.5), floor(41 + math.sin(a) * 6.2 + 0.5)
    fl(c, R(c, x, y, x, y + 2), "#f0e8d0")
    part(c, c:ellipse(x, y, 2, 1), caps[i + 1], { noline = (y < 40) })
    if caps[i + 1] == "#dd3a2a" then c:px(x - 1, y, "#f4eee0") end
  end
  gnome(c, 14, 47, { d = 1, eyes = "happy" })
  -- hands tucked behind: only a hint of sleeves at the back
  fl(c, R(c, 9, 42, 10, 43), "#f0c8a0")
  for _, p in ipairs({ { 40, 30 }, { 52, 26 }, { 30, 24 } }) do c:px(p[1], p[2], "#fff1c8"); c:px(p[1] + 1, p[2], "#f5cf6a") end
  finish(c, "r_nwe_fairy_ring")
end)

-- 9. tea cosy: four knitted cosies on four pots, the gnome feels which one is still warm
scene("r_nwe_tea_cosy", function()
  seed = 4
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#d9c49a")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 0, x, 40), "#c9b488") end
  fl(c, R(c, 0, 30, W - 1, 31), "#a8703e")
  part(c, R(c, 40, 8, 62, 24), "#a8703e"); c:fill(R(c, 42, 10, 60, 22), "#c4dce0"); fl(c, R(c, 51, 10, 51, 22), "#a8703e"); fl(c, R(c, 42, 16, 60, 16), "#a8703e")
  fl(c, R(c, 43, 11, 46, 13), "#e4f0f0")
  c:fill(R(c, 0, 41, W - 1, H - 1), "#8a5a35")
  for y = 45, 49, 4 do fl(c, R(c, 0, y, W - 1, y), "#6b3b2a") end
  -- table
  part(c, R(c, 22, 34, 68, 38), "#b07a45"); fl(c, R(c, 22, 34, 68, 34), "#d9a660")
  part(c, R(c, 25, 39, 27, 49), "#8a5a35", { noline = true }); part(c, R(c, 63, 39, 65, 49), "#8a5a35", { noline = true })
  local cols = { { "#3f6fb0", "#f4eee0" }, { "#dd3a2a", "#f5cf6a" }, { "#4f9a45", "#f4eee0" }, { "#c070d8", "#f5cf6a" } }
  for i, cc in ipairs(cols) do
    local x = 27 + (i - 1) * 12
    part(c, c:ellipse(x, 31, 5, 4), cc[1], { shade = true })
    for k = 0, 2 do fl(c, R(c, x - 4, 28 + k * 2, x + 4, 28 + k * 2), cc[2]) end
    part(c, c:ellipse(x, 26, 1, 1), cc[2], { noline = true })
    fl(c, R(c, x + 5, 30, x + 7, 31), "#e8e0d0"); fl(c, R(c, x - 7, 30, x - 5, 30), "#e8e0d0")    -- spout + handle
  end
  -- steam from the warm one (third)
  for k = 0, 2 do fl(c, R(c, 51 + (k % 2) * 2, 22 - k * 3, 52 + (k % 2) * 2, 23 - k * 3), "#f4f8fa") end
  gnome(c, 12, 49, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 14 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  fl(c, R(c, 25, 9, 25, 9), "#d9c49a")
  finish(c, "r_nwe_tea_cosy")
end)

-- 10. puffin burrows: clifftop turf, a puffin pops out of one hole with a beakful of fish
scene("r_nwe_puffin_burrows", function()
  seed = 11
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 20), { "#a0d0e6", "#b4dcea", "#c8e6ee" }, { dir = "v" })
  c:fill(c:ellipse(14, 9, 8, 2), "#f4eee0")
  c:fill(R(c, 0, 20, W - 1, 32), "#3f8fb4")
  for x = 6, 66, 12 do fl(c, R(c, x, 23, x + 4, 23), "#8fc8dc") end
  fl(c, R(c, 0, 20, W - 1, 20), "#6cb0cc")
  -- cliff edge rock and turf
  c:fill(c:poly({ { 0, 30 }, { 72, 26 }, { 72, 54 }, { 0, 54 } }), "#6a8a46")
  fl(c, R(c, 0, 29, 12, 34), "#8a8478")
  c:fill(c:poly({ { 0, 30 }, { 72, 26 }, { 72, 28 }, { 0, 32 } }), "#8cb462")
  for _, p in ipairs({ { 10, 38 }, { 24, 44 }, { 52, 36 }, { 62, 46 }, { 40, 48 } }) do tuft(c, p[1], p[2], "#4a7a3a") end
  for _, p in ipairs({ { 14, 35 }, { 30, 40 }, { 58, 41 } }) do c:fill(c:ellipse(p[1], p[2], 3, 2), "#e8d060") end
  -- burrow holes
  for _, p in ipairs({ { 15, 42 }, { 30, 36 }, { 56, 38 }, { 64, 46 } }) do part(c, c:ellipse(p[1], p[2], 3, 2), "#2a1a10", { noline = true }) end
  local hx, hy = 43, 45
  part(c, c:ellipse(hx, hy, 5, 2), "#2a1a10", { noline = true })
  -- puffin: black back, white face, big striped beak, fish
  part(c, R(c, hx - 3, hy - 9, hx + 2, hy - 1), "#26262e")
  fl(c, R(c, hx - 2, hy - 8, hx + 1, hy - 6), "#f4f0e8"); c:px(hx - 1, hy - 7, INK)
  fl(c, R(c, hx - 2, hy - 5, hx + 1, hy - 1), "#f4f0e8")
  part(c, R(c, hx + 2, hy - 8, hx + 6, hy - 6), "#e8602a")
  fl(c, R(c, hx + 4, hy - 8, hx + 4, hy - 6), "#f5cf6a")
  fl(c, R(c, hx - 4, hy - 4, hx - 4, hy - 1), "#e8602a"); fl(c, R(c, hx + 1, hy - 1, hx + 2, hy), "#e8602a")
  for k = 0, 2 do fl(c, R(c, hx + 1 + k * 2, hy - 11 - k % 2, hx + 2 + k * 2, hy - 10 - k % 2), "#c8d4dc") end
  fl(c, R(c, hx + 6, hy - 11, hx + 7, hy - 10), "#8a98a8")
  -- gnome crouched, watching
  gnome(c, 18, 52, { d = 1, sit = true, eyes = "open", arms = { arm({ 4, 6 }, { 7, 3 }, true) } })
  finish(c, "r_nwe_puffin_burrows")
end)

-- 11. humming stone: ear to a mossy standing stone, soft waves in the air
scene("r_nwe_humming_stone", function()
  seed = 19
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#a8b8c8", "#b8c8d0", "#c8d4d8", "#d4dcda" }, { dir = "v" })
  c:fill(c:ellipse(12, 36, 30, 10), "#7e9a6a"); c:fill(c:ellipse(62, 36, 26, 8), "#6e8a5c")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#6a9250"); fl(c, R(c, 0, 36, W - 1, 36), "#88aa68")
  -- ring: far stones small
  for _, x in ipairs({ 6, 18, 56, 64 }) do part(c, R(c, x, 25, x + 4, 37), "#9a9ea2"); fl(c, R(c, x, 25, x + 4, 25), "#adb1b4") end
  -- near stone
  part(c, c:rrect(38, 12, 54, 48, 5), "#9a9ea2", { shade = true })
  c:fill(c:ellipse(44, 14, 4, 2), "#5e9a48"); c:fill(R(c, 38, 30, 41, 44), "#5e9a48"); c:fill(c:ellipse(52, 42, 3, 4), "#5e9a48")
  fl(c, R(c, 45, 22, 47, 25), "#6a6e72"); fl(c, R(c, 48, 33, 50, 34), "#6a6e72")
  gnome(c, 31, 48, { d = 1, eyes = "shut", arms = { arm({ 4, 8 }, { 8, 11 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  -- hum waves
  for k = 0, 2 do
    local x = 58 + k * 3
    c:fill(c:line({ { x, 22 - k * 2 }, { x + 1, 26 - k * 2 }, { x, 30 - k * 2 } }, 1), (k == 0) and "#4f9ab4" or "#7ac0d4")
  end
  for k = 0, 1 do c:px(24, 14 + k * 3, "#f5cf6a"); c:px(23, 15 + k * 3, "#f5cf6a") end
  fl(c, R(c, 62, 8, 63, 10), "#f4f8fa"); fl(c, R(c, 10, 14, 15, 14), "#f4f8fa")
  finish(c, "r_nwe_humming_stone")
end)

-- 12. welly fling: boot flying over a chalk line towards a record flag
scene("r_nwe_welly_fling", function()
  seed = 17
  local c = new()
  day(c, 34, { cloud = 40, grass = "#82a858" })
  -- bunting and tent in background
  c:fill(c:line({ { 5, 14 }, { 28, 18 }, { 50, 14 } }, 1), "#5e3f28")
  local cols = { "#dd3a2a", "#f5cf6a", "#3f8fb0" }
  for i, f in ipairs({ { 9, 15 }, { 16, 17 }, { 23, 18 }, { 31, 18 }, { 38, 17 }, { 45, 15 } }) do
    fl(c, c:poly({ { f[1], f[2] }, { f[1] + 4, f[2] }, { f[1] + 2, f[2] + 4 } }), cols[(i - 1) % 3 + 1])
  end
  -- field with chalk line and far record flag
  fl(c, R(c, 5, 34, 68, 49), "#7ea85a")
  fl(c, R(c, 30, 36, 30, 49), "#f4f8fa"); fl(c, R(c, 31, 36, 31, 49), "#d8e8e8")
  for y = 38, 48, 4 do fl(c, R(c, 29, y, 32, y), "#f4f8fa") end
  part(c, R(c, 62, 22, 63, 40), "#6b4a2e", { noline = true })
  part(c, c:poly({ { 63, 22 }, { 69, 25 }, { 63, 28 } }), "#dd3a2a")
  fl(c, R(c, 55, 41, 62, 41), "#f4f8fa")
  -- tiny granny watching near the flag
  part(c, R(c, 56, 34, 59, 40), "#8a4a8a"); fl(c, R(c, 56, 32, 59, 33), "#e8e0d8"); fl(c, R(c, 57, 33, 58, 34), "#f0c8a0")
  -- gnome after the throw
  gnome(c, 20, 47, { d = 1, eyes = "happy", arms = { arm({ 4, 8 }, { 9, 16 }, true), arm({ -4, 7 }, { -8, 5 }, false) } })
  -- boot at the top of its arc with dashed trail
  for _, p in ipairs({ { 33, 25 }, { 37, 22 }, { 41, 20 }, { 45, 19 } }) do c:px(p[1], p[2], "#f4f8fa") end
  local bx, by = 50, 18
  part(c, R(c, bx, by, bx + 3, by + 7), "#3f6a3a"); part(c, R(c, bx - 1, by + 6, bx + 7, by + 9), "#3f6a3a")
  fl(c, R(c, bx, by, bx + 3, by), "#f5cf6a"); fl(c, R(c, bx - 1, by + 9, bx + 7, by + 9), "#2a4a28")
  fl(c, R(c, bx + 8, by + 3, bx + 10, by + 3), "#f4f8fa"); fl(c, R(c, bx + 8, by + 7, bx + 11, by + 7), "#f4f8fa")
  finish(c, "r_nwe_welly_fling")
end)

-- 13. chain ferry: hauling a chain hand over hand on a small ferry between fjord walls
scene("r_nwe_chain_ferry", function()
  seed = 23
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 36), { "#a8c8dc", "#bcd4e2", "#d0e0e8" }, { dir = "v" })
  c:fill(c:poly({ { 0, 4 }, { 14, 10 }, { 20, 36 }, { 0, 36 } }), "#5a6a70")
  c:fill(c:poly({ { 72, 2 }, { 58, 12 }, { 52, 36 }, { 72, 36 } }), "#4e5e66")
  c:fill(c:poly({ { 0, 4 }, { 8, 7 }, { 3, 12 }, { 0, 12 } }), "#f4f8fa"); c:fill(c:poly({ { 72, 2 }, { 66, 5 }, { 69, 11 }, { 72, 11 } }), "#f4f8fa")
  for _, p in ipairs({ { 6, 28 }, { 12, 22 }, { 64, 26 }, { 68, 20 } }) do pine(c, p[1], p[2] + 6, 12, false) end
  c:fill(R(c, 0, 36, W - 1, H - 1), "#3f7a9a")
  for y = 38, 48, 4 do for x = (y % 8 == 2) and 4 or 10, 68, 14 do fl(c, R(c, x, y, x + 5, y), "#6cb0cc") end end
  -- chain across the water, sagging, hauled hand over hand
  for x = 5, 68, 2 do
    local y = 29 + floor(((x - 40) / 30) ^ 2 * 3 + 0.5)
    fl(c, R(c, x, y, x + 1, y), ((x // 2) % 2 == 0) and "#2a2a32" or "#8a8e98")
    fl(c, R(c, x, y + 1, x, y + 1), "#2a2a32")
  end
  -- ferry hull and deck
  part(c, c:poly({ { 12, 42 }, { 60, 42 }, { 56, 49 }, { 16, 49 } }), "#8a5a35", { shade = true })
  part(c, R(c, 12, 40, 60, 42), "#b07a45")
  part(c, R(c, 14, 36, 15, 40), "#6b4a2e", { noline = true }); part(c, R(c, 57, 36, 58, 40), "#6b4a2e", { noline = true })
  fl(c, R(c, 14, 36, 58, 36), "#7a4a2a")
  gnome(c, 34, 41, { d = 1, eyes = "open", walk = 1, arms = { arm({ 4, 8 }, { 8, 14 }, true), arm({ -4, 8 }, { -8, 14 }, false) } })
  fl(c, R(c, 40, 41, 50, 41), "#b07a45")
  for _, p in ipairs({ { 20, 46 }, { 44, 46 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#5e3f28") end
  fl(c, R(c, 8, 36, 10, 36), "#cfe8e6"); fl(c, R(c, 62, 37, 65, 37), "#cfe8e6")
  finish(c, "r_nwe_chain_ferry")
end)

-- 14. sauna tales (night): ladle on the hot stones, steam rising, aurora in the window, a listener on the bench
scene("r_nwe_sauna_tales", function()
  seed = 21
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 49), "#a8703e")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 40), "#8a5a35") end
  c:fill(R(c, 0, 42, W - 1, H - 1), "#7a4a2a")
  for y = 45, 52, 3 do fl(c, R(c, 0, y, W - 1, y), "#5e3a22") end
  -- window with aurora
  part(c, R(c, 8, 9, 26, 26), "#6b4a2e")
  c:bands(R(c, 10, 11, 24, 24), { "#1c2a4a", "#2a3a5e", "#2f5a6a", "#3f9a8a", "#58c8a0" }, { dir = "v" })
  fl(c, R(c, 11, 13, 11, 13), "#f4eee0"); fl(c, R(c, 20, 12, 20, 12), "#f4eee0"); fl(c, R(c, 16, 16, 16, 16), "#f4eee0")
  fl(c, R(c, 17, 11, 17, 24), "#6b4a2e"); 
  -- benches
  part(c, R(c, 5, 38, 68, 41), "#c08a52"); fl(c, R(c, 5, 38, 68, 38), "#d9a660")
  -- stove with stones
  part(c, R(c, 50, 30, 66, 46), "#4a4a52", { shade = true })
  fl(c, R(c, 52, 42, 64, 44), "#e0501f"); fl(c, R(c, 54, 43, 62, 43), "#ffd86a")
  for _, p in ipairs({ { 54, 28 }, { 58, 27 }, { 62, 28 }, { 56, 25 }, { 60, 25 } }) do part(c, c:ellipse(p[1], p[2], 2, 2), "#6e6e78") end
  -- steam
  for k = 0, 5 do
    local x = 52 + (k % 2) * 3 + k
    c:fill(c:ellipse(x, 21 - k * 3, 3, 1), "#f4f8fa")
  end
  c:fill(c:ellipse(44, 22, 3, 1), "#e8eef0"); c:fill(c:ellipse(40, 14, 3, 1), "#e8eef0")
  -- listener on the bench
  gnome(c, 14, 38, { d = 1, sit = true, hat = "#4f9a45", s = 1, eyes = "open", arms = { arm({ 4, 6 }, { 6, 3 }, true) } })
  -- storyteller pouring a ladle on the stones
  gnome(c, 37, 49, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 13 }, true), arm({ -4, 8 }, { -9, 14 }, false) } })
  c:fill(c:line({ { 46, 36 }, { 51, 31 } }, 1), "#6b4a2e"); part(c, R(c, 50, 28, 54, 31), "#aeb4bc")
  fl(c, R(c, 53, 32, 53, 34), "#8fc8dc")
  finish(c, "r_nwe_sauna_tales")
end)

-- 15. smuggler tales: cave mouth, lantern, a barrel spilling striped socks, gnome whispering with a wink
scene("r_nwe_smuggler_tales", function()
  seed = 25
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 49), "#2a2a38")
  -- cave mouth showing sea light
  c:fill(c:poly({ { 28, 8 }, { 72, 8 }, { 72, 40 }, { 28, 40 } }), "#3a3a4a")
  local mouth = c:ellipse(52, 28, 15, 19):clip(R(c, 0, 0, W, 40))
  c:fill(mouth, "#a8d4e0")
  c:fill(mouth:copy():clip(R(c, 0, 24, W, 40)), "#7ab4cc")
  c:fill(mouth:copy():clip(R(c, 0, 31, W, 40)), "#4f8fb4")
  fl(c, R(c, 40, 33, 58, 33), "#7ab4cc"); fl(c, R(c, 46, 36, 62, 36), "#7ab4cc")
  c:fill(c:ellipse(52, 18, 3, 2), "#f4eee0")
  c:fill(R(c, 0, 40, W - 1, H - 1), "#5e5a54")
  for y = 44, 48, 4 do fl(c, R(c, 0, y, W - 1, y), "#4a4640") end
  -- socks on a line
  c:fill(c:line({ { 5, 12 }, { 20, 15 }, { 36, 12 } }, 1), "#8a7a5e")
  for i, p in ipairs({ { 9, 13 }, { 16, 15 }, { 24, 15 }, { 31, 13 } }) do
    fl(c, R(c, p[1], p[2], p[1] + 2, p[2] + 6), (i % 2 == 0) and "#dd3a2a" or "#3f6fb0"); fl(c, R(c, p[1] + 2, p[2] + 5, p[1] + 4, p[2] + 6), (i % 2 == 0) and "#dd3a2a" or "#3f6fb0")
    for y = p[2] + 1, p[2] + 6, 2 do fl(c, R(c, p[1], y, p[1] + 2, y), "#f4eee0") end
  end
  -- barrel with socks spilling
  part(c, c:rrect(53, 36, 66, 49, 3), "#8a5a35", { shade = true })
  fl(c, R(c, 54, 39, 65, 39), "#4a4a52"); fl(c, R(c, 54, 46, 65, 46), "#4a4a52")
  part(c, R(c, 55, 34, 58, 36), "#dd3a2a"); part(c, R(c, 59, 33, 62, 35), "#3f6fb0"); fl(c, R(c, 62, 36, 63, 38), "#f5cf6a")
  fl(c, R(c, 55, 35, 58, 35), "#f4eee0"); fl(c, R(c, 59, 34, 62, 34), "#f4eee0")
  -- lantern
  part(c, R(c, 40, 41, 44, 46), "#ffd86a", { cres = 1 }); fl(c, R(c, 41, 40, 43, 40), "#3d2a1c"); fl(c, R(c, 41, 42, 43, 45), "#fff1c8")
  for _, p in ipairs({ { 38, 40 }, { 46, 40 }, { 38, 46 }, { 46, 46 } }) do c:px(p[1], p[2], "#f8c070") end
  -- gnome whispering, hand cupped, with a wink
  local _, G = gnome(c, 22, 49, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 5, 12 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  local ex, ey = G.P(2, 10)
  fl(c, R(c, 25, 36, 26, 37), "#f0c8a0")
  c:px(ex + 1, ey, "#8a4a34"); c:px(ex, ey + 0, "#8a4a34")
  finish(c, "r_nwe_smuggler_tales")
end)

-- 16. long night tales (winter): a tower, barely-risen sun, gnome telling a story to a wrapped-up listener
scene("r_nwe_long_night_tales", function()
  seed = 27
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#1c2848", "#26345c", "#34447a", "#4e5e8e", "#8a7aa0", "#d89a8a" }, { dir = "v" })
  seed = 40
  for i = 1, 14 do c:px(6 + floor(rand() * 62), 6 + floor(rand() * 20), "#f4eee0") end
  c:fill(c:ellipse(46, 34, 9, 3), "#f4c890"); c:fill(c:ellipse(46, 34, 5, 1), "#ffe8b0")
  c:fill(c:ellipse(14, 36, 30, 9), "#b8c4d8"); c:fill(c:ellipse(62, 36, 24, 8), "#a8b4cc")
  c:fill(R(c, 0, 35, W - 1, H - 1), "#dce6f0"); c:fill(R(c, 0, 44, W - 1, H - 1), "#c4d0e0")
  fl(c, R(c, 0, 35, W - 1, 35), "#eef4fa")
  -- watchtower with lit window
  part(c, R(c, 52, 14, 62, 42), "#7a7e8a", { shade = true })
  part(c, R(c, 50, 10, 64, 14), "#5a5e6a")
  part(c, c:poly({ { 57, 3 }, { 65, 10 }, { 49, 10 } }), "#8a4a3a")
  fl(c, R(c, 55, 20, 59, 25), "#ffd86a"); fl(c, R(c, 56, 21, 58, 24), "#fff1c8"); fl(c, R(c, 57, 20, 57, 25), "#8a5a2a")
  fl(c, R(c, 55, 34, 59, 42), "#4a3a32")
  fl(c, R(c, 50, 10, 64, 10), "#f4f8fa")
  -- storyteller + bubble
  gnome(c, 16, 47, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -9, 14 }, false), arm({ 4, 8 }, { 9, 13 }, true) } })
  part(c, c:rrect(6, 5, 26, 17, 3), "#f4eee0")
  c:fill(c:poly({ { 15, 18 }, { 18, 18 }, { 16, 22 } }), "#f4eee0")
  c:fill(c:ellipse(12, 11, 3, 3), "#3a4870"); c:fill(c:ellipse(14, 10, 3, 3), "#f4eee0")
  c:fill(R(c, 19, 8, 19, 10), "#e8a317"); c:px(18, 9, "#e8a317"); c:px(20, 9, "#e8a317"); c:px(22, 13, "#e8a317")
  -- listener wrapped in a blanket with a mug, on a log
  part(c, R(c, 31, 44, 46, 47), "#8a5a35"); fl(c, R(c, 32, 44, 45, 44), "#a8703e")
  gnome(c, 38, 43, { d = -1, sit = true, hat = "#4f9a45", eyes = "open", arms = { arm({ -4, 7 }, { -7, 7 }, true) } })
  fl(c, R(c, 34, 37, 42, 41), "#c0442e"); fl(c, R(c, 34, 39, 42, 39), "#f5cf6a")
  fl(c, R(c, 30, 38, 31, 41), "#aeb4bc"); c:px(30, 35, "#f4f8fa")
  seed = 44
  for i = 1, 16 do c:px(6 + floor(rand() * 62), 6 + floor(rand() * 42), "#fbfdfe") end
  finish(c, "r_nwe_long_night_tales")
end)

-- 17. peat fire (rain): wet socks steaming on a line over a low peat fire, gnome with bare feet to the glow
scene("r_nwe_peat_fire", function()
  seed = 13
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 42), "#6a5a4a")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 0, x, 42), "#5a4a3c") end
  c:fill(R(c, 0, 43, W - 1, H - 1), "#4a3a2e")
  fl(c, R(c, 0, 43, W - 1, 43), "#7a6450")
  -- rainy window
  part(c, R(c, 8, 9, 26, 26), "#8a5a35")
  c:fill(R(c, 10, 11, 24, 24), "#7a8aa0"); fl(c, R(c, 17, 11, 17, 24), "#8a5a35"); fl(c, R(c, 10, 18, 24, 18), "#8a5a35")
  for _, p in ipairs({ { 12, 12 }, { 14, 16 }, { 20, 13 }, { 22, 20 }, { 12, 21 }, { 19, 22 } }) do c:px(p[1], p[2], "#cfe0ee"); c:px(p[1] - 1, p[2] + 1, "#cfe0ee") end
  -- stone hearth with low peat fire
  part(c, R(c, 44, 28, 68, 49), "#8b8f96", { shade = true })
  c:fill(R(c, 48, 36, 64, 49), "#2a1a10")
  for _, x in ipairs({ 44, 56 }) do fl(c, R(c, x, 34, x + 11, 34), "#7a7e86") end
  for i, x in ipairs({ 50, 54, 58, 62 }) do part(c, R(c, x - 1, 44, x + 2, 47), (i % 2 == 0) and "#4a2c1a" or "#3a2418", { noline = true }) end
  c:fill(c:poly({ { 56, 38 }, { 60, 45 }, { 52, 45 } }), "#e0501f"); c:fill(c:poly({ { 56, 41 }, { 58, 45 }, { 54, 45 } }), "#ffd86a")
  c:px(52, 43, "#f08a24"); c:px(61, 42, "#f08a24")
  -- line with wet socks, one hook each
  c:fill(c:line({ { 30, 18 }, { 56, 18 }, { 68, 20 } }, 1), "#d9bc84")
  for i, p in ipairs({ { 36, 19 }, { 44, 19 }, { 52, 19 }, { 61, 19 } }) do
    local col = ({ "#3f6fb0", "#dd3a2a", "#4f9a45", "#e8a317" })[i]
    fl(c, R(c, p[1], p[2], p[1] + 2, p[2] + 6), col); fl(c, R(c, p[1] + 2, p[2] + 5, p[1] + 4, p[2] + 6), col)
    for y = p[2] + 1, p[2] + 5, 2 do fl(c, R(c, p[1], y, p[1] + 2, y), "#f4eee0") end
    c:px(p[1] + 1, p[2] + 8, "#8fc8dc")
  end
  for _, p in ipairs({ { 40, 12 }, { 48, 10 }, { 58, 13 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 2), "#d8dce0") end
  -- gnome sat on a low stool, bare toes toward the fire, rubbing a sock
  part(c, R(c, 14, 44, 24, 47), "#8a5a35")
  gnome(c, 20, 44, { d = 1, sit = true, eyes = "shut", arms = { arm({ 4, 7 }, { 8, 5 }, true) } })
  fl(c, R(c, 28, 40, 30, 41), "#f0c8a0")
  part(c, R(c, 30, 39, 33, 43), "#3f6fb0"); fl(c, R(c, 30, 40, 33, 40), "#f4eee0")
  c:px(31, 36, "#d8dce0"); c:px(32, 34, "#d8dce0")
  finish(c, "r_nwe_peat_fire")
end)

-- 18. goats home (dusk): bells ringing, gnome shepherding three goats up the hill, one short
scene("r_se_goats_home", function()
  seed = 30
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#4a4a88", "#6a5a98", "#a8689a", "#e08a7a", "#f0b078" }, { dir = "v" })
  for _, p in ipairs({ { 10, 7 }, { 28, 5 }, { 52, 8 }, { 64, 16 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(c:ellipse(14, 36, 30, 12), "#5a5a7a"); c:fill(c:ellipse(60, 34, 30, 10), "#4e4e72")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#5a7a4c"); fl(c, R(c, 0, 36, W - 1, 36), "#7a8e5a")
  c:fill(c:poly({ { 0, 40 }, { 72, 36 }, { 72, 54 }, { 0, 54 } }), "#4e6e42")
  for _, p in ipairs({ { 8, 44 }, { 62, 46 }, { 40, 50 } }) do tuft(c, p[1], p[2], "#3a5a34") end
  goat(c, 40, 48, 1, "#f4eee0", true); goat(c, 50, 43, 1, "#8a6a4a", true); goat(c, 61, 49, 1, "#cfc8b8", true)
  -- gnome with crook, hand to ear
  gnome(c, 24, 49, { d = 1, walk = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 11 }, true), arm({ -4, 8 }, { -7, 14 }, false) } })
  c:fill(c:line({ { 33, 33 }, { 33, 49 } }, 1), "#8a5a35"); fl(c, R(c, 31, 32, 33, 32), "#8a5a35"); c:px(31, 33, "#8a5a35")
  -- tumbling notes from the bells
  for _, p in ipairs({ { 46, 28 }, { 55, 24 }, { 64, 33 }, { 40, 24 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#ffe08a"); fl(c, R(c, p[1] + 1, p[2] - 3, p[1] + 1, p[2]), "#ffe08a") end
  finish(c, "r_se_goats_home")
end)

-- 19. cliff capers: gnome on tiptoe stretching for caper buds sprouting from the old sea wall
scene("r_se_cliff_capers", function()
  seed = 33
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 12), { "#8cc8e0", "#a8d8e8" }, { dir = "v" })
  c:fill(R(c, 0, 8, W - 1, 14), "#3f8fb4"); fl(c, R(c, 0, 8, W - 1, 8), "#6cb0cc")
  -- old stone wall
  c:fill(R(c, 0, 14, W - 1, H - 1), "#c8b898")
  for r = 0, 8 do
    local y = 14 + r * 4
    fl(c, R(c, 0, y, W - 1, y), "#a89878")
    for x = (r % 2 == 0) and 0 or 6, W - 1, 12 do fl(c, R(c, x, y, x, y + 3), "#a89878") end
  end
  c:fill(R(c, 0, 14, W - 1, 14), "#dccca8")
  c:fill(R(c, 0, 46, W - 1, H - 1), "#a89270"); fl(c, R(c, 0, 46, W - 1, 46), "#c8b88e")
  -- caper bush in a crack
  fl(c, R(c, 51, 27, 52, 31), "#2a1a10")
  part(c, c:ellipse(52, 23, 8, 5), "#5e9a42", { shade = true })
  c:fill(c:ellipse(50, 21, 3, 1), "#8fc462"); c:fill(c:ellipse(56, 24, 3, 1), "#4a8a38")
  for _, p in ipairs({ { 47, 24 }, { 57, 21 }, { 52, 27 }, { 59, 25 }, { 45, 20 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#6aaa50", { noline = true }); c:px(p[1], p[2], "#a8d880") end
  c:px(52, 19, "#f4eee0"); c:px(53, 19, "#f4eee0"); c:px(52, 18, "#f08ab4")
  c:fill(c:line({ { 44, 28 }, { 36, 31 } }, 1), "#5e9a42"); part(c, c:ellipse(35, 31, 1, 1), "#6aaa50", { noline = true })
  -- gnome on tiptoe, long reach, basket on the other arm
  gnome(c, 33, 48, { d = 1, s = 1.1, eyes = "open", arms = { arm({ 4, 9 }, { 12, 19 }, true), arm({ -4, 7 }, { -6, 3 }, false) } })
  part(c, R(c, 22, 41, 29, 46), "#c08a52", { shade = true }); fl(c, R(c, 22, 41, 29, 41), "#8a5a35"); fl(c, R(c, 23, 39, 28, 40), "#a8d880")
  fl(c, R(c, 22, 47, 22, 48), "#2a1a10")
  c:px(42, 14, "#f4eee0"); c:px(14, 10, "#f4eee0"); c:px(15, 10, "#f4eee0")
  finish(c, "r_se_cliff_capers")
end)

-- 20. whistlewind (wind): gnome hauling a shutter closed, things flying off, notes from the keyhole
scene("r_se_whistlewind", function()
  seed = 36
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 24), { "#c8d8d4", "#d8e0d4", "#e4e6d0" }, { dir = "v" })
  -- house wall with window and shutters
  c:fill(R(c, 5, 4, 68, 40), "#e8c878")
  for y = 8, 36, 7 do fl(c, R(c, 5, y, 68, y), "#d8b868") end
  part(c, R(c, 34, 12, 50, 32), "#4a3a30"); c:fill(R(c, 36, 14, 48, 30), "#3a4a5a"); fl(c, R(c, 42, 14, 42, 30), "#4a3a30")
  part(c, R(c, 26, 12, 33, 32), "#3f8fb0")                       -- shutter, open at left
  for y = 14, 30, 3 do fl(c, R(c, 27, y, 32, y), "#2f6a8a") end
  part(c, R(c, 51, 12, 58, 32), "#3f8fb0")
  for y = 14, 30, 3 do fl(c, R(c, 52, y, 57, y), "#2f6a8a") end
  c:fill(R(c, 0, 40, W - 1, H - 1), "#b8a888")
  for y = 43, 49, 3 do for x = (y % 6 == 1) and 3 or 8, 70, 10 do fl(c, R(c, x, y, x + 4, y), "#9a8a6e") end end
  -- gnome bracing against the wind, pulling the shutter
  gnome(c, 18, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 13 }, true), arm({ -4, 6 }, { -6, 4 }, false) } })
  -- gusts and flying things
  for _, w in ipairs({ { 8, 10, 9 }, { 12, 17, 6 }, { 38, 6, 10 }, { 54, 34, 8 }, { 40, 38, 9 }, { 60, 8, 7 } }) do
    fl(c, R(c, w[1], w[2], w[1] + w[3], w[2]), "#f4f8fa"); c:px(w[1] + w[3] + 1, w[2] + 1, "#f4f8fa")
  end
  part(c, c:ellipse(60, 18, 4, 1), "#e0c068"); part(c, R(c, 58, 14, 62, 17), "#e0c068")     -- straw hat
  fl(c, R(c, 59, 16, 61, 16), "#dd3a2a")
  part(c, R(c, 8, 22, 12, 26), "#dd3a2a"); c:px(13, 23, "#dd3a2a"); c:px(14, 22, "#dd3a2a")  -- a cloth
  for _, p in ipairs({ { 28, 36 }, { 44, 36 }, { 64, 40 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#c8802a") end
  for _, p in ipairs({ { 66, 34 }, { 64, 29 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#4e8a3c") end
  -- keyhole flute notes
  fl(c, R(c, 41, 24, 43, 26), "#f5cf6a")
  for _, p in ipairs({ { 38, 20 }, { 45, 18 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#f5cf6a"); fl(c, R(c, p[1] + 1, p[2] - 3, p[1] + 1, p[2]), "#f5cf6a") end
  finish(c, "r_se_whistlewind")
end)

-- 21. sponge dive: clear water, gnome reaching under a ledge for a fat sponge, bubbles rising
scene("r_se_sponge_dive", function()
  seed = 38
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 49), { "#7ad8dc", "#6cc8d4", "#5ab8cc", "#4aa4c0", "#3a90b0" }, { dir = "v" })
  -- surface and boat hull
  c:fill(R(c, 0, 0, W - 1, 5), "#cfeef0"); fl(c, R(c, 0, 5, W - 1, 5), "#e8f8f8")
  part(c, c:poly({ { 40, 0 }, { 66, 0 }, { 62, 4 }, { 44, 4 } }), "#8a5a35")
  for x = 8, 36, 7 do fl(c, R(c, x, 6, x + 3, 6), "#a8e8ec") end
  -- light rays
  for _, x in ipairs({ 14, 30, 50 }) do for y = 7, 28 do if (y + x) % 2 == 0 then c:px(x + floor((y - 7) / 5), y, "#8ae8e0") end end end
  -- sea floor with pebbles
  c:fill(c:poly({ { 0, 43 }, { 72, 41 }, { 72, 54 }, { 0, 54 } }), "#d8c890")
  for _, p in ipairs({ { 8, 47 }, { 14, 49 }, { 26, 47 }, { 56, 49 }, { 64, 46 }, { 34, 49 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2] + 1), (p[1] % 2 == 0) and "#a89a70" or "#c0b080") end
  -- ledge with sponge underneath
  part(c, c:rrect(42, 34, 68, 44, 3), "#6e6a7a", { shade = true })
  c:fill(R(c, 46, 40, 62, 46), "#2a4a5e")
  part(c, c:ellipse(53, 43, 5, 4), "#e8a030", { shade = true })
  for _, p in ipairs({ { 50, 42 }, { 53, 41 }, { 56, 43 }, { 52, 45 } }) do c:px(p[1], p[2], "#9a5a1c") end
  part(c, R(c, 60, 44, 62, 48), "#e8a030", { noline = true }); fl(c, R(c, 60, 44, 62, 44), "#9a5a1c")
  -- diver gnome reaching down toward the ledge
  gnome(c, 32, 46, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 10, 5 }, true), arm({ -4, 8 }, { -9, 10 }, false) } })
  c:fill(c:ellipse(30, 31, 1, 1), "#d8f8f8")
  for _, b in ipairs({ { 34, 24, 1 }, { 36, 19, 1 }, { 32, 14, 2 }, { 38, 10, 1 }, { 20, 22, 1 }, { 22, 30, 1 } }) do
    part(c, c:ellipse(b[1], b[2], b[3], b[3]), "#cfeef0", { noline = true }); c:px(b[1], b[2], "#f8ffff")
  end
  finish(c, "r_se_sponge_dive")
end)

-- 22. cinder smoke: thin curl over the peak, gnome with a hand to his chin, thinking
scene("r_se_cinder_smoke", function()
  seed = 40
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#d8b8a0", "#e0c4a8", "#ead0b0", "#f0dcbc" }, { dir = "v" })
  -- the mountain
  c:fill(c:poly({ { 36, 14 }, { 70, 38 }, { 2, 38 } }), "#6a4a4a")
  part(c, c:poly({ { 36, 14 }, { 70, 38 }, { 2, 38 } }), "#6a4a4a", { shade = true })
  c:fill(c:poly({ { 36, 14 }, { 52, 38 }, { 40, 38 } }), "#7e5a58")
  c:fill(c:poly({ { 36, 14 }, { 42, 20 }, { 30, 20 } }), "#4a3a3e")
  fl(c, R(c, 33, 14, 39, 15), "#e0501f"); fl(c, R(c, 35, 14, 37, 14), "#ffd86a")
  for _, p in ipairs({ { 22, 28 }, { 28, 24 }, { 48, 30 }, { 14, 33 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#563a3c") end
  -- thin smoke curl
  local sm = { { 36, 11 }, { 38, 9 }, { 35, 7 }, { 38, 5 }, { 36, 3 } }
  for i, p in ipairs(sm) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), (i % 2 == 0) and "#cfc4bc" or "#a89c98") end
  fl(c, R(c, 38, 6, 40, 6), "#cfc4bc")
  c:fill(R(c, 0, 38, W - 1, H - 1), "#7a8a52"); fl(c, R(c, 0, 38, W - 1, 38), "#92a266")
  c:fill(c:poly({ { 0, 40 }, { 72, 38 }, { 72, 54 }, { 0, 54 } }), "#6e7e48")
  for _, p in ipairs({ { 8, 44 }, { 60, 44 }, { 66, 49 } }) do tuft(c, p[1], p[2], "#4e5e34") end
  -- watch rock and the thinking gnome
  part(c, c:rrect(8, 42, 30, 49, 3), "#8a8480", { shade = true })
  gnome(c, 19, 42, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 3, 11 }, true) } })
  fl(c, R(c, 43, 31, 43, 34), "#6b4a2e")
  -- thought dots
  for i, p in ipairs({ { 28, 27 }, { 31, 23 } }) do part(c, c:ellipse(p[1], p[2], i, i), "#f4eee0", { noline = true }) end
  finish(c, "r_se_cinder_smoke")
end)

-- 23. mud pot: bubbling grey mud in a ring of stones, gnome with painted cheeks checks the mirror
scene("r_se_mud_pot", function()
  seed = 42
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#c8c8c4", "#d4d4cc", "#dcdcd0" }, { dir = "v" })
  c:fill(c:ellipse(14, 31, 28, 10), "#8a8470"); c:fill(c:ellipse(60, 32, 28, 9), "#7a7660")
  c:fill(R(c, 0, 32, W - 1, H - 1), "#9a9078"); fl(c, R(c, 0, 32, W - 1, 32), "#b0a68c")
  for _, p in ipairs({ { 6, 38 }, { 12, 48 }, { 62, 38 }, { 66, 47 } }) do c:fill(R(c, p[1], p[2], p[1] + 3, p[2]), "#80765e") end
  -- pot
  part(c, c:ellipse(46, 42, 20, 7), "#8b8f96", { shade = true })
  c:fill(c:ellipse(46, 42, 17, 5), "#8a8478")
  c:fill(c:ellipse(46, 41, 15, 3), "#a29a88")
  for _, b in ipairs({ { 40, 42, 3 }, { 48, 41, 2 }, { 54, 43, 3 }, { 45, 44, 2 } }) do
    part(c, c:ellipse(b[1], b[2], b[3], b[3] - 1), "#9a9280", { noline = true }); c:px(b[1] - 1, b[2] - 1, "#d0c8b8")
  end
  fl(c, R(c, 36, 41, 38, 41), "#78705e")
  for _, st in ipairs({ { 28, 44 }, { 32, 48 }, { 46, 50 }, { 60, 48 }, { 64, 44 } }) do part(c, c:ellipse(st[1], st[2], 3, 2), "#9a9ea6", { shade = true }) end
  for _, p in ipairs({ { 44, 30 }, { 50, 26 }, { 47, 22 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#f4f8fa") end
  fl(c, R(c, 40, 24, 41, 25), "#f4f8fa")
  local _, G = gnome(c, 18, 48, { d = 1, eyes = "happy", arms = { arm({ 4, 8 }, { 9, 12 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  -- mud on the cheeks
  local mx, my = G.P(-3, 10); fl(c, R(c, mx, my, mx + 1, my + 1), "#7a6a58")
  mx, my = G.P(3, 10); fl(c, R(c, mx - 1, my, mx, my + 1), "#7a6a58")
  -- hand mirror
  c:fill(c:line({ { 28, 37 }, { 29, 34 } }, 1), "#8a5a35")
  part(c, c:ellipse(29, 31, 3, 3), "#d9a660"); c:fill(c:ellipse(29, 31, 2, 2), "#d8eef4"); c:px(28, 30, "#f8fcfc")
  finish(c, "r_se_mud_pot")
end)

-- 24. goat ferry: a crowded little ferry, goats facing every way, gnome poling
scene("r_se_goat_ferry", function()
  seed = 46
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 25), { "#8cc8e0", "#a8d8e8", "#c4e4ec" }, { dir = "v" })
  c:fill(c:ellipse(62, 26, 18, 6), "#8a9a5e"); c:fill(c:ellipse(62, 24, 10, 3), "#9aaa6a")
  c:fill(c:ellipse(60, 22, 3, 3), "#4e8a3c")
  c:fill(c:ellipse(10, 20, 8, 2), "#f4eee0")
  c:fill(R(c, 0, 26, W - 1, H - 1), "#3f90b4")
  for y = 29, 49, 4 do for x = (y % 8 == 1) and 4 or 11, 68, 14 do fl(c, R(c, x, y, x + 5, y), "#7ac4dc") end end
  -- ferry
  part(c, c:poly({ { 8, 40 }, { 66, 40 }, { 61, 48 }, { 13, 48 } }), "#8a5a35", { shade = true })
  part(c, R(c, 8, 38, 66, 40), "#b07a45")
  goat(c, 23, 38, 1, "#f4eee0", true); goat(c, 33, 38, -1, "#8a6a4a", true); goat(c, 43, 38, 1, "#cfc8b8", true); goat(c, 53, 38, -1, "#f4eee0", true)
  goat(c, 62, 38, -1, "#6a4a30", false)
  -- gnome at the stern with a pole, sailing right
  gnome(c, 12, 38, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 11 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  c:fill(c:line({ { 22, 27 }, { 17, 49 } }, 1), "#6b4a2e")
  fl(c, R(c, 66, 44, 69, 44), "#cfeef0"); fl(c, R(c, 4, 46, 8, 46), "#cfeef0")
  finish(c, "r_se_goat_ferry")
end)

for _, s2 in ipairs(ORDER) do
  if not only or only == s2 then seed = 7; S[s2]() end
end
