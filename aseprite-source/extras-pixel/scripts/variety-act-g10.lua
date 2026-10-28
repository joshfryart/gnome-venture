-- variety-act-g10.lua : Do-tab scenes for 15 market/mill rest-stop activities -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- w2_chutney_pot w2_level_trestles w2_stall_signs w2_juggle_match w2_taster_showdown w2_bunting_patterns w2_stamped_weight w2_honest_scale w2_cheese_roll w2_weigher_memory w2_bargains_of_old w2_branch_wheel w2_sift_flour w2_grease_cogs w2_granary_mice
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g10.lua   (params BEFORE --script)
-- Frame (5 grid px wooden frame) is copied from the shipped act-hand.png; interior is x 5..68, y 5..49.
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

---------------------------------------------------------------- shared bits
local S = {}
local DIRT, DIRTL = "#c9a96e", "#d9bc84"
local function dirt(c, y)
  fl(c, R(c, 0, y, W - 1, H - 1), DIRT); fl(c, R(c, 0, y, W - 1, y), DIRTL)
  for _, p in ipairs({ { 8, y + 5 }, { 20, y + 8 }, { 37, y + 6 }, { 52, y + 8 }, { 64, y + 4 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#b8965c") end
end
local function awning(c, x0, x1, y0, c1, c2, h)
  h = h or 5
  local n = 0
  for x = x0, x1 - 3, 4 do
    local col = (n % 2 == 0) and c1 or c2
    fl(c, R(c, x, y0, x + 3, y0 + h), col); fl(c, R(c, x, y0 + h + 1, x + 3, y0 + h + 1), col); fl(c, R(c, x + 1, y0 + h + 2, x + 2, y0 + h + 2), col)
    n = n + 1
  end
  c:outline(R(c, x0, y0, x1 - 1, y0 + h + 2))
end
local function counter(c, x0, x1, y0, y1)
  part(c, R(c, x0, y0, x1, y1), "#b07a45"); fl(c, R(c, x0, y0, x1, y0 + 1), "#d9a660")
  for x = x0 + 7, x1 - 4, 9 do fl(c, R(c, x, y0 + 3, x, y1 - 1), "#8a4f2a") end
end
local function tomato(c, x, y)
  part(c, c:ellipse(x, y, 2, 2), "#d8402a"); c:px(x - 1, y - 1, "#f08a6a"); c:px(x, y - 3, "#4e8a3c"); c:px(x + 1, y - 3, "#4e8a3c")
end
local function bubble(c, x0, y0, x1, y1, tx, ty)
  part(c, c:rrect(x0, y0, x1, y1, 3), "#f4eee0")
  local mx = floor((x0 + x1) / 2)
  c:fill(c:poly({ { mx - 2, y1 }, { mx + 2, y1 }, { tx, ty } }), "#f4eee0")
end
local function spark(c, x, y, a, b)
  c:px(x, y, "#fff1c8"); c:px(x - 1, y, a or "#f5cf6a"); c:px(x + 1, y, a or "#f5cf6a"); c:px(x, y - 1, a or "#f5cf6a"); c:px(x, y + 1, a or "#f5cf6a")
end
local function wisp(c, x, y0, n, col)
  for i = 0, n do fl(c, R(c, x + ((i % 2 == 0) and 0 or 1), y0 - i * 2, x + ((i % 2 == 0) and 1 or 2), y0 - i * 2 + 1), col or "#f4f8fa") end
end
local function rope(c, pts, col) c:fill(c:line(pts, 1), col or "#5e3f28") end

-- 1. chutney pot: stirring a bubbling red pot behind the veg stall
function S.w2_chutney_pot()
  seed = 61
  local c = new()
  day(c, 38, { cloud = 50, hill = "#5e8a44", hill2 = "#4e8a3c" })
  dirt(c, 40)
  -- veg stall on the left
  part(c, R(c, 7, 17, 8, 40), "#8a5a35", { noline = true }); part(c, R(c, 28, 17, 29, 40), "#8a5a35", { noline = true })
  awning(c, 6, 31, 12, "#dd3a2a", "#f4eee0")
  counter(c, 6, 30, 33, 45)
  for _, p in ipairs({ { 10, 30 }, { 14, 30 }, { 12, 27 }, { 18, 30 } }) do tomato(c, p[1], p[2]) end
  for _, p in ipairs({ { 23, 30 }, { 27, 30 }, { 25, 28 } }) do
    part(c, c:ellipse(p[1], p[2], 2, 2), "#e0b070"); c:px(p[1], p[2] - 3, "#7ab55c"); c:px(p[1] - 1, p[2] - 1, "#f4e0b0")
  end
  -- cauldron on a fire
  for _, x in ipairs({ 36, 48 }) do part(c, R(c, x, 44, x + 1, 48), "#2a1a10", { noline = true }) end
  c:fill(c:poly({ { 42, 43 }, { 45, 47 }, { 39, 47 } }), "#e0501f"); c:fill(c:poly({ { 42, 45 }, { 43, 47 }, { 41, 47 } }), "#ffd86a")
  part(c, c:rrect(34, 36, 50, 46, 4), "#3d3a44", { shade = true })
  part(c, c:ellipse(42, 36, 8, 2), "#5a5660")
  c:fill(c:ellipse(42, 36, 6, 1), "#b8321e")
  for _, p in ipairs({ { 39, 36 }, { 44, 35 }, { 46, 36 } }) do c:px(p[1], p[2], "#e8704a"); c:px(p[1] + 1, p[2], "#e8704a") end
  fl(c, R(c, 36, 38, 37, 41), "#6a6672")
  wisp(c, 38, 32, 4, "#f4eee0"); wisp(c, 45, 31, 5, "#f4eee0"); wisp(c, 41, 30, 3, "#e0d8c8")
  -- gnome stirring with a long spoon
  gnome(c, 58, 47, { d = -1, eyes = "open", arms = { arm({ -4, 7 }, { -8, 12 }, true), arm({ 4, 6 }, { 5, 3 }, false) } })
  c:fill(c:line({ { 52, 28 }, { 43, 37 } }, 2), "#8a5a35")
  -- finished jars on a little crate
  part(c, R(c, 62, 43, 68, 47), "#a8703e")
  for _, x in ipairs({ 63, 66 }) do part(c, R(c, x, 39, x + 2, 42), "#b8321e"); fl(c, R(c, x, 38, x + 2, 38), "#f4eee0") end
  finish(c, "w2_chutney_pot")
end

-- 2. level trestles: wedge under the short leg, eggs wobbling on a tilted table
function S.w2_level_trestles()
  seed = 62
  local c = new()
  day(c, 34, { cloud = 14, hill = "#5e8a44", hill2 = "#4e8a3c" })
  dirt(c, 38)
  -- far stalls
  awning(c, 40, 60, 19, "#3f8fb0", "#f4eee0", 3)
  part(c, R(c, 41, 26, 42, 36), "#8a5a35", { noline = true }); part(c, R(c, 58, 26, 59, 36), "#8a5a35", { noline = true })
  part(c, R(c, 6, 21, 8, 36), "#8a5a35", { noline = true })
  awning(c, 6, 24, 17, "#dd3a2a", "#f4eee0", 3)
  -- table on two trestles; the right trestle has a short leg
  for _, a in ipairs({ { 14, 33, 10, 47 }, { 14, 33, 20, 47 }, { 38, 37, 34, 47 }, { 38, 37, 45, 44 } }) do
    part(c, c:line({ { a[1], a[2] }, { a[3], a[4] } }, 2), "#8a5a35", { noline = true })
  end
  part(c, c:line({ { 7, 30 }, { 47, 37 } }, 3), "#c08a52")
  c:fill(c:line({ { 8, 29 }, { 46, 36 } }, 1), "#e0b070")
  -- basket of eggs at the high end, eggs sliding down
  part(c, R(c, 8, 25, 16, 29), "#a8703e"); fl(c, R(c, 8, 25, 16, 25), "#d9a660")
  for _, p in ipairs({ { 10, 23 }, { 13, 23 }, { 15, 24 } }) do part(c, c:ellipse(p[1], p[2], 1, 2), "#f4eee0", { noline = true }); c:px(p[1], p[2] - 1, "#fbfdfe") end
  part(c, c:ellipse(25, 29, 1, 2), "#f4eee0"); part(c, c:ellipse(36, 32, 1, 2), "#f4eee0")
  c:px(20, 28, "#8a6a56"); c:px(22, 29, "#8a6a56"); c:px(31, 31, "#8a6a56"); c:px(33, 32, "#8a6a56")
  -- wedge under the short leg
  part(c, c:poly({ { 43, 47 }, { 49, 47 }, { 49, 44 } }), "#d9a660")
  -- gnome with a mallet
  gnome(c, 58, 47, { d = -1, eyes = "open", arms = { arm({ -4, 7 }, { -8, 11 }, true), arm({ 4, 6 }, { 5, 3 }, false) } })
  c:fill(c:line({ { 50, 36 }, { 47, 39 } }, 2), "#8a5a35")
  part(c, R(c, 44, 39, 49, 42), "#8b929c")
  spark(c, 51, 44, "#f5cf6a"); c:px(41, 45, "#f5cf6a")
  finish(c, "w2_level_trestles")
end

-- 3. stall signs: repainting a faded cheese sign with a yellow brush
function S.w2_stall_signs()
  seed = 63
  local c = new()
  day(c, 36, { sky = { "#c4d2d8", "#d0dcde", "#dce6e2" }, cloud = 12, hill = "#6a8a58", hill2 = "#5e8a4e" })
  dirt(c, 40)
  fl(c, c:ellipse(18, 47, 9, 1), "#a8c0c8"); fl(c, c:ellipse(62, 48, 5, 1), "#a8c0c8")
  part(c, R(c, 36, 16, 37, 40), "#8a5a35", { noline = true }); part(c, R(c, 66, 16, 67, 40), "#8a5a35", { noline = true })
  awning(c, 35, 68, 10, "#f4eee0", "#d9a030", 4)
  counter(c, 35, 67, 35, 47)
  for _, p in ipairs({ { 41, 33 }, { 50, 33 }, { 59, 33 } }) do
    part(c, c:ellipse(p[1], p[2], 4, 2), "#f0c040"); c:px(p[1] - 1, p[2], "#c89a2a"); c:px(p[1] + 2, p[2] - 1, "#c89a2a")
  end
  -- hanging sign: pale, half repainted
  rope(c, { { 41, 17 }, { 41, 21 } }); rope(c, { { 61, 17 }, { 61, 21 } })
  part(c, R(c, 38, 21, 64, 31), "#d8d2c0")
  fl(c, R(c, 40, 23, 44, 24), "#c8c2b0"); fl(c, R(c, 56, 28, 61, 29), "#c8c2b0")
  c:fill(c:poly({ { 41, 23 }, { 54, 26 }, { 41, 29 } }), "#f0c040")
  for _, p in ipairs({ { 45, 26 }, { 49, 26 }, { 47, 24 } }) do c:px(p[1], p[2], "#c89a2a") end
  c:px(62, 32, "#9ab4c4"); c:px(62, 34, "#9ab4c4"); c:px(46, 31, "#f0c040"); c:px(46, 33, "#f0c040")
  -- paint pot
  part(c, R(c, 24, 44, 30, 47), "#aeb4bc"); fl(c, R(c, 25, 44, 29, 44), "#f0c040")
  -- gnome with a brush, a daub of paint on the nose
  local _, G = gnome(c, 20, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 16 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  c:fill(c:line({ { 31, 28 }, { 36, 24 } }, 1), "#8a5a35"); c:fill(R(c, 37, 22, 39, 24), "#f0c040")
  local nx, ny = G.P(3, 10); c:px(nx, ny, "#f0c040")
  finish(c, "w2_stall_signs")
end

-- 4. juggle match: two pedlars juggling, a crowd peeking over the rope
function S.w2_juggle_match()
  seed = 64
  local c = new()
  day(c, 36, { cloud = 30, hill = "#5e8a44", hill2 = "#4e8a3c" })
  dirt(c, 38)
  -- bunting
  rope(c, { { 5, 8 }, { 36, 12 }, { 68, 8 } })
  local cols = { "#dd3a2a", "#f5cf6a", "#3f8fb0", "#7ab55c" }
  for i, x in ipairs({ 9, 15, 21, 27, 33, 39, 45, 51, 57, 63 }) do
    local y = 8 + floor(4 * math.sin((x - 5) / 63 * math.pi))
    fl(c, c:poly({ { x, y + 1 }, { x + 4, y + 1 }, { x + 2, y + 5 } }), cols[(i - 1) % 4 + 1])
  end
  -- crowd behind a rope: little faces under pointed hats
  for _, p in ipairs({ { 11, "#e8a317" }, { 30, "#4f9a45" }, { 42, "#3f8fb0" }, { 62, "#e8a317" } }) do
    local x = p[1]
    part(c, c:poly({ { x, 31 }, { x + 3, 36 }, { x - 3, 36 } }), p[2])
    part(c, R(c, x - 2, 36, x + 2, 38), "#f0c8a0"); part(c, R(c, x - 2, 39, x + 2, 42), "#f4eee0")
    c:px(x - 1, 37, INK); c:px(x + 1, 37, INK)
  end
  rope(c, { { 5, 41 }, { 68, 41 } }, "#8a5a35")
  for _, x in ipairs({ 6, 36, 67 }) do part(c, R(c, x, 36, x + 1, 44), "#6b4a2e", { noline = true }) end
  -- jugglers
  gnome(c, 20, 48, { d = 1, hat = "#c0442e", eyes = "open", arms = { arm({ -4, 8 }, { -8, 14 }, true), arm({ 4, 8 }, { 8, 14 }, true) } })
  gnome(c, 52, 48, { d = -1, hat = "#4f9a45", eyes = "open", arms = { arm({ -4, 8 }, { -8, 14 }, true), arm({ 4, 8 }, { 8, 14 }, true) } })
  local function apple(x, y) part(c, c:ellipse(x, y, 2, 2), "#d8402a"); c:px(x - 1, y - 1, "#f08a6a"); c:px(x, y - 3, "#4e8a3c") end
  apple(13, 21); apple(20, 15); apple(27, 21)
  part(c, c:ellipse(45, 21, 1, 2), "#f4eee0"); part(c, c:ellipse(59, 21, 1, 2), "#f4eee0")
  part(c, c:ellipse(52, 15, 2, 2), "#e8e0f0"); c:fill(R(c, 50, 16, 54, 17), "#a060b0"); c:px(52, 12, "#4e8a3c")
  spark(c, 36, 24, "#f5cf6a"); c:px(30, 18, "#f5cf6a"); c:px(42, 17, "#f5cf6a")
  finish(c, "w2_juggle_match")
end

-- 5. taster showdown: sour lemon face, three nibbles on the tasting table
function S.w2_taster_showdown()
  seed = 65
  local c = new()
  day(c, 36, { cloud = 14, hill = "#5e8a44", hill2 = "#4e8a3c" })
  dirt(c, 38)
  rope(c, { { 5, 9 }, { 30, 13 }, { 68, 9 } })
  for i, x in ipairs({ 12, 20, 28, 36, 44, 52, 60 }) do
    local y = 9 + floor(4 * math.sin((x - 5) / 63 * math.pi * 1.2))
    fl(c, c:poly({ { x, y + 1 }, { x + 4, y + 1 }, { x + 2, y + 5 } }), ({ "#f5cf6a", "#e46a9b", "#3f8fb0" })[(i - 1) % 3 + 1])
  end
  -- judge behind the table
  gnome(c, 63, 40, { d = -1, upper = true, hat = "#4f9a45", eyes = "happy", arms = { arm({ -3, 6 }, { -5, 10 }, true) } })
  -- tasting table
  for _, x in ipairs({ 36, 65 }) do part(c, R(c, x, 36, x + 1, 47), "#8a5a35", { noline = true }) end
  part(c, R(c, 33, 34, 68, 37), "#f4eee0")
  for x = 34, 66, 4 do fl(c, R(c, x, 35, x + 1, 36), "#3f8fb0") end
  fl(c, R(c, 34, 34, 67, 34), "#e8e0d0")
  -- sweet cupcake, salty pretzel
  part(c, c:ellipse(42, 33, 3, 1), "#f4eee0"); part(c, R(c, 40, 29, 44, 32), "#d9a660"); part(c, c:ellipse(42, 28, 3, 2), "#e46a9b"); c:px(42, 25, "#d8402a")
  part(c, c:ellipse(56, 33, 3, 1), "#f4eee0")
  part(c, c:ellipse(56, 30, 3, 3), "#a8582f"); c:fill(c:ellipse(56, 30, 1, 1), "#e8c48a"); for _, p in ipairs({ { 54, 28 }, { 58, 29 }, { 54, 32 }, { 57, 32 } }) do c:px(p[1], p[2], "#fbfdfe") end
  part(c, c:ellipse(48, 33, 3, 1), "#f4eee0"); c:fill(c:poly({ { 46, 32 }, { 50, 32 }, { 48, 28 } }), "#f0c040"); c:px(48, 30, "#fff1a0")
  -- taster pulling a face over a lemon wedge
  local _, G = gnome(c, 20, 47, { s = 1.25, d = 1, eyes = "shut", arms = { arm({ 4, 7 }, { 6, 12 }, true, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  local mx, my = G.P(7, 12)
  c:fill(c:poly({ { mx - 1, my + 2 }, { mx + 5, my + 2 }, { mx + 2, my - 3 } }), "#f0c040")
  c:outline(c:poly({ { mx - 1, my + 2 }, { mx + 5, my + 2 }, { mx + 2, my - 3 } }))
  fl(c, R(c, mx - 2, my + 1, mx - 1, my + 3), "#f0c8a0")
  c:px(mx + 2, my, "#fff1a0"); c:px(mx + 2, my - 1, "#fff1a0")
  -- sour sparks
  c:px(36, 22, "#fff1a0"); c:px(34, 25, "#fff1a0"); c:px(37, 27, "#fff1a0")
  finish(c, "w2_taster_showdown")
end

-- 6. bunting patterns: gnome with a little book, looking up at pennants of every pattern
function S.w2_bunting_patterns()
  seed = 66
  local c = new()
  day(c, 38, { cloud = false, sky = { "#a8d4e0", "#bcdde4", "#cfe8e6" }, hill = "#6a8a58", hill2 = "#5e8a4e" })
  dirt(c, 40)
  -- stall roofs at both sides
  awning(c, 5, 19, 28, "#dd3a2a", "#f4eee0", 3); part(c, R(c, 6, 35, 7, 40), "#8a5a35", { noline = true })
  awning(c, 54, 68, 30, "#3f8fb0", "#f4eee0", 3); part(c, R(c, 66, 37, 67, 40), "#8a5a35", { noline = true })
  local W5 = { 5, 5, 4, 3, 2, 1 }
  local function pennant(x, y, pat)
    for i = 0, 5 do
      local half = W5[i + 1]
      local x0 = x + floor((5 - half) / 2)
      for k = 0, half - 1 do
        local col, cx, cy = nil, x0 + k - x, i
        if pat == "dots" then col = ((cx + cy) % 3 == 0) and "#d8402a" or "#f4eee0"
        elseif pat == "stripes" then col = (cy % 2 == 0) and "#3f6fb0" or "#f4eee0"
        elseif pat == "gingham" then col = ((cx % 2 + cy % 2) == 0) and "#3f8a5a" or (((cx % 2 + cy % 2) == 1) and "#9ccaa8" or "#f4eee0")
        elseif pat == "stars" then col = ((cx + cy) % 2 == 0) and "#f5cf6a" or "#3b4a8a"
        elseif pat == "zig" then col = (((cx + (cy % 2) * 2) % 4) < 2) and "#e46a9b" or "#f4eee0"
        else col = ((cx == 2 and cy == 1) or (cx == 1 and cy == 2) or (cx == 3 and cy == 2)) and "#f5cf6a" or "#f4eee0" end
        c:px(x0 + k, y + i, col)
      end
    end
    c:outline(c:poly({ { x, y }, { x + 4, y }, { x + 2, y + 5 } }))
  end
  local pats = { "dots", "stripes", "gingham", "stars", "zig", "daisy" }
  rope(c, { { 5, 8 }, { 22, 13 }, { 38, 14 }, { 54, 13 }, { 68, 8 } })
  for i, x in ipairs({ 8, 14, 20, 26, 32, 38, 44, 50, 56, 62 }) do
    local y = 9 + floor(5 * math.sin((x - 5) / 63 * math.pi))
    pennant(x, y + 1, pats[(i - 1) % 6 + 1])
  end
  rope(c, { { 5, 19 }, { 24, 24 }, { 42, 25 }, { 68, 19 } })
  for i, x in ipairs({ 10, 17, 24, 31, 38, 45, 52, 59 }) do
    local y = 19 + floor(5 * math.sin((x - 5) / 63 * math.pi))
    pennant(x, y + 1, pats[(i + 2) % 6 + 1])
  end
  -- gnome with the little book and pencil
  local _, G = gnome(c, 36, 47, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -6, 9 }, true, true), arm({ 4, 8 }, { 7, 16 }, true) } })
  local bx, by = G.P(-6, 9)
  part(c, R(c, bx - 4, by - 3, bx + 1, by + 3), "#8a4f2a"); fl(c, R(c, bx - 3, by - 2, bx, by + 2), "#f4eee0"); fl(c, R(c, bx - 2, by - 1, bx - 1, by - 1), "#a8703e")
  fl(c, R(c, bx + 1, by, bx + 2, by + 2), "#f0c8a0")
  local px_, py_ = G.P(7, 16)
  fl(c, R(c, px_ + 1, py_ - 2, px_ + 1, py_ + 1), "#f5cf6a")
  finish(c, "w2_bunting_patterns")
end

-- 7. stamped weight: summer, holding up a brass weight with a tiny hat stamped underneath
function S.w2_stamped_weight()
  seed = 67
  local c = new()
  day(c, 36, { sky = { "#7cc4e8", "#9ad2ec", "#b8e0ee" }, cloud = 40, hill = "#5e9a44", hill2 = "#4e8a3c", grass = "#7eb05a" })
  -- sun
  c:fill(c:ellipse(60, 12, 5, 5), "#ffe27a")
  for _, p in ipairs({ { 60, 4 }, { 60, 20 }, { 51, 12 }, { 69, 12 }, { 53, 5 }, { 67, 5 }, { 53, 19 }, { 67, 19 } }) do c:px(p[1], p[2], "#ffe27a") end
  dirt(c, 40)
  -- weigher's bench with three brass weights
  for _, x in ipairs({ 40, 66 }) do part(c, R(c, x, 36, x + 1, 47), "#8a5a35", { noline = true }) end
  part(c, R(c, 37, 34, 68, 37), "#b07a45"); fl(c, R(c, 37, 34, 68, 34), "#d9a660")
  local function weight(x, y, w, h)
    part(c, R(c, x, y, x + w, y + h), "#d9a82a")
    fl(c, R(c, x + 1, y + 1, x + 1, y + h - 1), "#f5d56a")
    part(c, R(c, x + floor(w / 2) - 1, y - 2, x + floor(w / 2) + 1, y - 1), "#c89a2a", { noline = true })
  end
  weight(41, 28, 6, 5); weight(50, 27, 6, 6)
  -- strawberries
  part(c, R(c, 59, 28, 66, 33), "#a8703e"); fl(c, R(c, 59, 28, 66, 28), "#d9a660")
  for _, p in ipairs({ { 60, 27 }, { 63, 26 }, { 65, 27 }, { 62, 28 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#d8302a", { noline = true }); c:px(p[1], p[2] - 2, "#4e8a3c") end
  -- gnome holding up the fourth weight, stamped side to us
  gnome(c, 18, 47, { d = 1, eyes = "happy", arms = { arm({ 4, 8 }, { 7, 15 }, true, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  part(c, R(c, 22, 22, 33, 31), "#d9a82a")
  fl(c, R(c, 23, 23, 23, 30), "#f5d56a"); fl(c, R(c, 24, 30, 32, 30), "#c89a2a")
  part(c, R(c, 25, 19, 30, 21), "#c89a2a", { noline = true })
  c:fill(c:poly({ { 27, 23 }, { 30, 28 }, { 24, 28 } }), "#c0442e"); fl(c, R(c, 24, 28, 30, 28), "#8e2e1e")
  fl(c, R(c, 22, 28, 24, 30), "#f0c8a0")
  spark(c, 36, 20); spark(c, 20, 16); c:px(34, 25, "#fff1c8")
  finish(c, "w2_stamped_weight")
end

-- 8. honest scale: three balance scales, only the first one sits level under the butter pound
function S.w2_honest_scale()
  seed = 68
  local c = new()
  c:fill(R(c, 0, 0, W - 1, H - 1), "#d8c298")
  for x = 6, W - 1, 8 do fl(c, R(c, x, 0, x, 33), "#c8b084") end
  part(c, R(c, 38, 4, 64, 9), "#f4eee0"); for x = 40, 62, 4 do fl(c, R(c, x, 4, x + 1, 9), "#c0442e") end
  local function scale(x, tilt)
    local by = 21
    part(c, R(c, x, by, x + 1, 41), "#c89a2a", { noline = true })
    part(c, R(c, x - 3, 40, x + 4, 41), "#c89a2a")
    local lx, ly, rx, ry = x - 5, by + tilt, x + 6, by - tilt
    part(c, c:line({ { lx, ly }, { rx, ry } }, 2), "#c89a2a", { noline = true })
    part(c, c:ellipse(x, by, 1, 1), "#f5d56a")
    for _, e in ipairs({ { lx, ly }, { rx, ry } }) do
      c:fill(c:line({ { e[1], e[2] }, { e[1] - 3, e[2] + 6 } }, 1), "#5e3f28"); c:fill(c:line({ { e[1], e[2] }, { e[1] + 3, e[2] + 6 } }, 1), "#5e3f28")
      part(c, c:poly({ { e[1] - 4, e[2] + 6 }, { e[1] + 4, e[2] + 6 }, { e[1] + 2, e[2] + 8 }, { e[1] - 2, e[2] + 8 } }), "#aeb4bc")
    end
    return lx, ly + 6, rx, ry + 6
  end
  scale(47, -4); scale(62, 4)
  local lx, ly, rx, ry = scale(32, 0)
  -- butter on the left pan, brass weight on the right: level
  part(c, R(c, lx - 2, ly - 3, lx + 2, ly), "#f5dd6a"); fl(c, R(c, lx - 2, ly - 3, lx + 2, ly - 3), "#fff1a0")
  part(c, R(c, rx - 1, ry - 2, rx + 1, ry), "#d9a82a")
  spark(c, 32, 13); spark(c, 40, 17); spark(c, 24, 16)
  -- a goose feather on the crooked pan
  c:px(41, 26, "#f4eee0"); c:px(42, 27, "#f4eee0"); c:px(43, 27, "#f4eee0")
  -- counter and the gnome behind it
  gnome(c, 14, 48, { d = 1, upper = true, s = 1.2, eyes = "happy", arms = { arm({ 4, 7 }, { 7, 12 }, true) } })
  part(c, R(c, 4, 42, 69, 49), "#b07a45"); fl(c, R(c, 4, 42, 69, 43), "#d9a660")
  for _, x in ipairs({ 22, 40, 58 }) do fl(c, R(c, x, 45, x, 48), "#8a4f2a") end
  finish(c, "w2_honest_scale")
end

-- 9. cheese roll: a big wheel rolling down the lane towards the gate and the duck pond
function S.w2_cheese_roll()
  seed = 69
  local c = new()
  day(c, 30, { cloud = 24, hill = "#5e8a44", hill2 = "#4e8a3c" })
  -- the lane: tan path sloping down to the right
  c:fill(c:poly({ { 0, 34 }, { 72, 38 }, { 72, 49 }, { 0, 49 } }), "#d0b078")
  fl(c, c:line({ { 0, 34 }, { 72, 38 } }, 1), "#e0c690")
  -- pond at lower right and a duck
  c:fill(c:ellipse(62, 46, 10, 3), "#4a88b0"); c:fill(R(c, 56, 46, 61, 46), "#8cc4dc")
  part(c, c:ellipse(64, 45, 3, 2), "#f4eee0"); part(c, c:ellipse(67, 43, 1, 1), "#f4eee0"); c:px(69, 43, "#f0a020"); c:px(67, 42, INK)
  -- hedge and gate at the end of the lane
  part(c, c:rrect(44, 22, 72, 31, 3), "#3f7a3c", { shade = true })
  part(c, R(c, 48, 26, 49, 40), "#8a5a35"); part(c, R(c, 61, 26, 62, 40), "#8a5a35")
  part(c, R(c, 49, 29, 61, 30), "#a8703e"); part(c, R(c, 49, 34, 61, 35), "#a8703e")
  -- speed lines and dust
  fl(c, R(c, 15, 40, 21, 40), "#f4eee0"); fl(c, R(c, 17, 43, 23, 43), "#f4eee0"); fl(c, R(c, 14, 46, 19, 46), "#f4eee0")
  c:fill(c:ellipse(25, 46, 3, 1), "#e0c690"); c:px(23, 44, "#e0c690")
  -- the wheel
  local m = c:ellipse(34, 40, 8, 8)
  part(c, m, "#f0c040", { shade = true })
  c:fill(c:ellipse(34, 40, 5, 5), "#f5d56a")
  c:fill(c:poly({ { 34, 40 }, { 42, 38 }, { 42, 43 } }):clip(m), "#8a5a35")
  c:fill(c:poly({ { 34, 40 }, { 42, 38 }, { 42, 43 } }):clip(m), "#f5dd6a")
  c:px(31, 38, "#c89a2a"); c:px(32, 38, "#c89a2a"); c:px(36, 44, "#c89a2a"); c:px(37, 44, "#c89a2a"); c:px(30, 43, "#c89a2a"); c:px(35, 36, "#c89a2a")
  c:px(28, 40, "#c89a2a"); c:px(38, 41, "#c89a2a")
  -- gnome who just pushed it
  gnome(c, 12, 46, { d = 1, walk = 1, eyes = "open", arms = { arm({ 4, 7 }, { 9, 8 }, true), arm({ -4, 7 }, { -3, 5 }, false) } })
  finish(c, "w2_cheese_roll")
end

-- 10. weigher memory: the weigher leans on her big brass scale and tells a pumpkin tale
function S.w2_weigher_memory()
  seed = 70
  local c = new()
  day(c, 36, { cloud = 60, hill = "#5e8a44", hill2 = "#4e8a3c" })
  dirt(c, 40)
  -- the big brass scale: post, dial, platter
  part(c, R(c, 58, 32, 63, 46), "#c89a2a")
  part(c, R(c, 53, 45, 68, 48), "#8a5a35")
  part(c, c:ellipse(60, 28, 6, 6), "#d9a82a", { shade = true })
  c:fill(c:ellipse(60, 28, 4, 4), "#f4eee0")
  c:fill(c:line({ { 60, 28 }, { 63, 25 } }, 1), "#c0442e"); c:px(60, 28, INK)
  for _, p in ipairs({ { 60, 24 }, { 56, 28 }, { 64, 28 }, { 60, 32 } }) do c:px(p[1], p[2], "#8a5a35") end
  part(c, c:ellipse(60, 22, 8, 2), "#d9a82a"); fl(c, R(c, 56, 21, 62, 21), "#f5d56a")
  -- the weigher, leaning an elbow on the scale
  gnome(c, 46, 47, { d = -1, hat = "#4f9a45", eyes = "open", arms = { arm({ 4, 6 }, { 8, 8 }, true), arm({ -4, 8 }, { -9, 12 }, true) } })
  -- the listener, seated on a crate
  part(c, R(c, 6, 44, 20, 49), "#a8703e"); fl(c, R(c, 6, 44, 20, 45), "#d9a660"); fl(c, R(c, 13, 46, 13, 49), "#8a4f2a")
  gnome(c, 13, 43, { d = 1, sit = true, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, true) } })
  -- story bubble: an enormous pumpkin in two halves
  bubble(c, 12, 7, 42, 25, 43, 31)
  part(c, c:ellipse(22, 17, 5, 5), "#e8842a"); fl(c, R(c, 20, 13, 20, 21), "#c8601a"); fl(c, R(c, 23, 13, 23, 21), "#c8601a")
  part(c, c:ellipse(32, 17, 5, 5), "#e8842a"); fl(c, R(c, 30, 13, 30, 21), "#c8601a"); fl(c, R(c, 33, 13, 33, 21), "#c8601a")
  fl(c, R(c, 26, 12, 27, 13), "#4e8a3c"); fl(c, R(c, 26, 20, 27, 21), "#4e8a3c")
  fl(c, R(c, 26, 18, 27, 18), "#f4eee0")
  finish(c, "w2_weigher_memory")
end

-- 11. bargains of old: dusk, shutters down, two stallholders on crates swapping tales by a lantern
function S.w2_bargains_of_old()
  seed = 71
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#2c2a5a", "#43346e", "#6a3f7c", "#a8506e", "#d8706a" }, { dir = "v" })
  for _, p in ipairs({ { 8, 7 }, { 60, 6 }, { 66, 14 }, { 22, 5 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(R(c, 0, 33, W - 1, H - 1), "#5a5668")
  fl(c, R(c, 0, 33, W - 1, 33), "#6e6a7e")
  for _, p in ipairs({ { 6, 44 }, { 14, 48 }, { 28, 46 }, { 52, 48 }, { 62, 44 }, { 40, 49 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2] + 1), "#4a4658") end
  -- closed stalls behind: awning, shutters
  for _, x in ipairs({ 5, 49 }) do
    awning(c, x, x + 20, 20, "#7a3a4a", "#4a3a5a", 3)
    part(c, R(c, x + 1, 27, x + 18, 40), "#6b4a34")
    for xx = x + 1, x + 18, 3 do fl(c, R(c, xx, 28, xx, 39), "#4a3022") end
    fl(c, R(c, x + 1, 33, x + 18, 33), "#4a3022")
  end
  -- lantern on a post in the middle, glowing
  part(c, R(c, 35, 26, 36, 45), "#2a1a10", { noline = true })
  part(c, R(c, 32, 17, 39, 26), "#ffd86a", { shade = true, cres = 1 })
  c:fill(R(c, 34, 19, 37, 24), "#fff1c8"); fl(c, R(c, 35, 17, 36, 26), "#8a5a2a")
  part(c, c:poly({ { 35, 13 }, { 41, 17 }, { 30, 17 } }), "#2a1a10")
  for _, p in ipairs({ { 29, 20 }, { 42, 20 }, { 28, 25 }, { 43, 25 } }) do c:px(p[1], p[2], "#f8c070") end
  c:fill(c:ellipse(35, 47, 13, 2), "#9a7a62")
  -- two crates and two gnomes
  part(c, R(c, 8, 44, 21, 49), "#a8703e"); fl(c, R(c, 8, 44, 21, 45), "#d9a660"); fl(c, R(c, 15, 46, 15, 49), "#8a4f2a")
  part(c, R(c, 50, 44, 63, 49), "#a8703e"); fl(c, R(c, 50, 44, 63, 45), "#d9a660"); fl(c, R(c, 57, 46, 57, 49), "#8a4f2a")
  gnome(c, 14, 43, { d = 1, sit = true, eyes = "open", arms = { arm({ -4, 8 }, { -8, 13 }, false), arm({ 4, 7 }, { 8, 12 }, true) } })
  gnome(c, 57, 43, { d = -1, sit = true, hat = "#e8a317", eyes = "happy", arms = { arm({ 4, 6 }, { 6, 3 }, true) } })
  -- tale bubble: a bean swapped for a cart
  bubble(c, 6, 4, 30, 16, 12, 25)
  part(c, c:ellipse(12, 10, 2, 2), "#7a9a3a"); c:px(11, 9, "#a8c860")
  c:fill(c:line({ { 16, 8 }, { 21, 8 } }, 1), "#8a5a35"); c:fill(c:line({ { 16, 12 }, { 21, 12 } }, 1), "#8a5a35")
  c:px(20, 7, "#8a5a35"); c:px(17, 13, "#8a5a35")
  part(c, R(c, 23, 7, 28, 11), "#a8703e"); for _, x in ipairs({ 24, 27 }) do part(c, c:ellipse(x, 12, 1, 1), "#5e3f28", { noline = true }) end
  finish(c, "w2_bargains_of_old")
end

-- 12. branch wheel: rainy day, the swollen stream has jammed a willow branch in the mill wheel
function S.w2_branch_wheel()
  seed = 72
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#7a8a9c", "#8898a8", "#98a6b4", "#a8b4c0" }, { dir = "v" })
  c:fill(c:ellipse(60, 33, 30, 7), "#4a6a4a"); c:fill(c:ellipse(10, 34, 26, 6), "#52724e")
  c:fill(R(c, 0, 33, W - 1, H - 1), "#5a7a54")
  -- mill wall at the right
  part(c, R(c, 46, 14, 70, 44), "#d8c8a8"); fl(c, R(c, 46, 14, 70, 15), "#b0a080")
  c:fill(c:poly({ { 44, 14 }, { 58, 4 }, { 72, 14 } }), "#8a4a3a"); c:outline(c:poly({ { 44, 14 }, { 58, 4 }, { 72, 14 } }))
  part(c, R(c, 52, 22, 58, 30), "#4a6a8a"); fl(c, R(c, 55, 22, 55, 30), "#2a1a10"); fl(c, R(c, 52, 26, 58, 26), "#2a1a10")
  part(c, R(c, 62, 30, 67, 44), "#6b4a2e")
  -- stream
  c:fill(R(c, 5, 40, 46, 49), "#5a7a96")
  for _, p in ipairs({ { 8, 42 }, { 30, 44 }, { 14, 47 }, { 36, 47 }, { 22, 42 } }) do fl(c, R(c, p[1], p[2], p[1] + 4, p[2]), "#8aa8c0") end
  -- the wheel
  local cx, cy = 26, 29
  local ring = c:ellipse(cx, cy, 15, 15)
  part(c, ring, "#a8703e")
  c:fill(c:ellipse(cx, cy, 11, 11), "#7a8a9c")
  for a = 0, 7 do
    local ang = a * math.pi / 4
    local x1, y1 = cx + floor(11 * math.cos(ang) + 0.5), cy + floor(11 * math.sin(ang) + 0.5)
    c:fill(c:line({ { cx, cy }, { x1, y1 } }, 1), "#8a5a35")
    local px_, py_ = cx + floor(15 * math.cos(ang + 0.39) + 0.5), cy + floor(15 * math.sin(ang + 0.39) + 0.5)
    part(c, R(c, px_ - 1, py_ - 1, px_ + 1, py_ + 1), "#8a5a35", { noline = true })
  end
  part(c, c:ellipse(cx, cy, 2, 2), "#5e3f28")
  -- the branch wedged across the lower paddles, leaves trailing in the water
  part(c, c:line({ { 8, 24 }, { 24, 36 }, { 46, 40 } }, 3), "#6b4a2e", { noline = true })
  for _, p in ipairs({ { 12, 28 }, { 18, 33 }, { 30, 39 } }) do c:fill(c:line({ { p[1], p[2] }, { p[1] - 2, p[2] + 7 } }, 1), "#7ab55c") end
  for _, p in ipairs({ { 8, 24 }, { 10, 27 }, { 36, 41 }, { 40, 42 } }) do c:fill(c:ellipse(p[1], p[2] + 1, 3, 2), "#6aa04a") end
  -- gnome hauling, rain on his hat
  gnome(c, 56, 47, { d = -1, eyes = "shut", arms = { arm({ -4, 7 }, { -9, 9 }, true), arm({ 4, 7 }, { -2, 6 }, true) } })
  -- rain and splashes
  seed = 80
  for i = 1, 34 do
    local x, y = 6 + floor(rand() * 62), 6 + floor(rand() * 40)
    c:px(x, y, "#d8e6f0"); c:px(x - 1, y + 1, "#d8e6f0")
  end
  for _, p in ipairs({ { 41, 43 }, { 6, 45 } }) do c:px(p[1], p[2], "#d8e6f0"); c:px(p[1] + 2, p[2] - 1, "#d8e6f0") end
  finish(c, "w2_branch_wheel")
end

-- 13. sift flour: shaking a sieve over a bin, flour drifting down, a dab on the nose
function S.w2_sift_flour()
  seed = 73
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 39), "#d8b888")
  for x = 6, W - 1, 7 do fl(c, R(c, x, 0, x, 39), "#c8a478") end
  c:fill(R(c, 0, 40, W - 1, H - 1), "#9a6a3e")
  for y = 44, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#7a5230") end
  fl(c, R(c, 0, 40, W - 1, 40), "#7a5230")
  -- window with morning light
  part(c, R(c, 44, 8, 60, 22), "#a8d4e0"); fl(c, R(c, 52, 8, 52, 22), "#8a5a35"); fl(c, R(c, 44, 15, 60, 15), "#8a5a35")
  fl(c, R(c, 45, 9, 47, 10), "#f4f8fa")
  -- sacks at the left
  part(c, c:rrect(5, 30, 15, 44, 3), "#e0d4b0"); fl(c, R(c, 7, 32, 13, 32), "#b8a878")
  part(c, c:rrect(7, 21, 16, 31, 3), "#e8dcb8"); fl(c, R(c, 9, 23, 14, 23), "#b8a878")
  -- bin with a soft white heap
  part(c, R(c, 29, 38, 53, 49), "#a8703e"); fl(c, R(c, 29, 38, 53, 39), "#d9a660")
  for _, x in ipairs({ 36, 43, 49 }) do fl(c, R(c, x, 41, x, 48), "#8a4f2a") end
  part(c, c:ellipse(41, 37, 11, 3), "#f4f2ea"); fl(c, c:ellipse(39, 36, 6, 1), "#fbfdfe")
  -- gnome sifting
  local _, G = gnome(c, 19, 47, { d = 1, eyes = "shut", arms = { arm({ 4, 8 }, { 8, 17 }, true), arm({ -2, 8 }, { 5, 16 }, true) } })
  local nx, ny = G.P(3, 10); c:px(nx, ny, "#fbfdfe"); c:px(nx + 1, ny, "#fbfdfe")
  c:px(G.tipx + 1, G.tipy + 4, "#fbfdfe"); c:px(G.tipx - 2, G.tipy + 6, "#fbfdfe")
  -- the round sieve
  part(c, c:ellipse(31, 28, 7, 2), "#8a5a35"); c:fill(c:ellipse(31, 28, 5, 1), "#c8b08a")
  -- falling flour
  for _, p in ipairs({ { 28, 31 }, { 31, 32 }, { 29, 34 }, { 33, 33 }, { 27, 35 }, { 32, 35 }, { 35, 31 }, { 34, 34 } }) do c:px(p[1], p[2], "#fbfdfe") end
  c:px(25, 24, "#fbfdfe"); c:px(37, 24, "#fbfdfe"); c:px(36, 27, "#fbfdfe")
  finish(c, "w2_sift_flour")
end

local function cog(c, cx, cy, r, n, col)
  local m = c:ellipse(cx, cy, r, r)
  for i = 0, n - 1 do
    local a = i * 2 * math.pi / n
    local tx, ty = cx + floor((r + 1) * math.cos(a) + 0.5), cy + floor((r + 1) * math.sin(a) + 0.5)
    m:add(c:rect(tx - 1, ty - 1, tx + 1, ty + 1))
  end
  part(c, m, col)
  c:fill(c:ellipse(cx, cy, floor(r / 2), floor(r / 2)), "#8a5a35")
  part(c, c:ellipse(cx, cy, 2, 2), "#3d2a1c")
end

-- 14. grease cogs: up a ladder, daubing grease on the great wooden cog while it squeaks
function S.w2_grease_cogs()
  seed = 74
  local c = new()
  c:fill(R(c, 0, 0, W - 1, H - 1), "#5a4030")
  for x = 5, W - 1, 8 do fl(c, R(c, x, 0, x, H - 1), "#4a3224") end
  fl(c, R(c, 0, 46, W - 1, H - 1), "#3a281c")
  part(c, R(c, 8, 8, 18, 18), "#a8d4e0"); fl(c, R(c, 13, 8, 13, 18), "#3a281c"); fl(c, R(c, 8, 13, 18, 13), "#3a281c"); fl(c, R(c, 9, 9, 11, 10), "#f4f8fa")
  cog(c, 50, 28, 14, 10, "#b8804a")
  cog(c, 22, 19, 8, 7, "#9a6a3a")
  -- ladder
  for _, x in ipairs({ 28, 38 }) do part(c, R(c, x, 20, x + 1, 49), "#d9a660", { noline = true }) end
  for y = 24, 48, 6 do part(c, R(c, 28, y, 39, y + 1), "#d9a660", { noline = true }) end
  -- gnome standing on a rung, brush up to the teeth, pot in the other hand
  local _, G = gnome(c, 33, 42, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 15 }, true), arm({ -4, 7 }, { -7, 9 }, true) } })
  local bx, by = G.P(8, 15)
  c:fill(R(c, bx + 1, by - 1, bx + 3, by), "#f0c040")
  local gx, gy = G.P(-7, 9)
  part(c, R(c, gx - 4, gy - 2, gx, gy + 3), "#aeb4bc"); fl(c, R(c, gx - 4, gy - 2, gx, gy - 2), "#f0c040")
  -- greasy daubs and squeak marks
  for _, p in ipairs({ { 38, 27 }, { 39, 33 }, { 42, 18 } }) do c:px(p[1], p[2], "#f0c040"); c:px(p[1], p[2] + 1, "#f0c040") end
  for _, p in ipairs({ { 59, 9 }, { 64, 12 } }) do
    c:px(p[1], p[2], "#f4eee0"); c:px(p[1] + 1, p[2] - 1, "#f4eee0"); c:px(p[1] + 2, p[2] - 2, "#f4eee0")
    c:px(p[1] + 3, p[2], "#f4eee0"); c:px(p[1] + 4, p[2] - 1, "#f4eee0")
  end
  finish(c, "w2_grease_cogs")
end

-- 15. granary mice: night, lantern-lit gnome with a broom, mice marching off with crusts
function S.w2_granary_mice()
  seed = 75
  local c = new()
  c:fill(R(c, 0, 0, W - 1, H - 1), "#2e2840")
  for x = 6, W - 1, 8 do fl(c, R(c, x, 0, x, 39), "#241e34") end
  c:fill(R(c, 0, 40, W - 1, H - 1), "#4a3a34")
  for y = 45, 53, 4 do fl(c, R(c, 0, y, W - 1, y), "#382a26") end
  fl(c, R(c, 0, 40, W - 1, 40), "#382a26")
  -- moonlit window and the patch of light on the floor
  part(c, R(c, 48, 8, 60, 22), "#6a88b8"); fl(c, R(c, 54, 8, 54, 22), "#2a2036"); fl(c, R(c, 48, 15, 60, 15), "#2a2036")
  c:fill(c:ellipse(51, 12, 2, 2), "#f5e6a8"); c:fill(c:ellipse(52, 11, 2, 2), "#6a88b8")
  c:fill(c:poly({ { 48, 22 }, { 60, 22 }, { 70, 46 }, { 46, 46 } }):clip(R(c, 0, 41, W, 60)), "#5a5e78")
  -- grain sacks
  part(c, c:rrect(5, 32, 15, 46, 3), "#a89468"); fl(c, R(c, 7, 34, 13, 34), "#7a6a48")
  part(c, c:rrect(7, 24, 16, 33, 3), "#b8a478"); fl(c, R(c, 9, 26, 14, 26), "#7a6a48")
  -- hole in the boards at the right
  part(c, c:ellipse(67, 46, 2, 2), "#150e18", { noline = true })
  -- warm lantern glow
  c:fill(c:ellipse(33, 36, 12, 8), "#4e4048")
  -- gnome with lantern and broom
  local _, G = gnome(c, 26, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 15 }, true), arm({ -4, 7 }, { -7, 4 }, true) } })
  local lx, ly = G.P(8, 15)
  part(c, R(c, lx, ly - 5, lx + 4, ly - 1), "#ffd86a"); fl(c, R(c, lx + 1, ly - 4, lx + 3, ly - 2), "#fff1c8"); fl(c, R(c, lx, ly - 6, lx + 4, ly - 6), "#2a1a10")
  part(c, R(c, lx + 1, ly - 8, lx + 3, ly - 7), "#2a1a10", { noline = true })
  local bx, by = G.P(-7, 4)
  c:fill(c:line({ { bx, by }, { bx - 2, by - 10 } }, 1), "#8a5a35"); part(c, R(c, bx - 2, by, bx + 3, by + 3), "#d8b050")
  -- mice with crusts, heading for the hole
  local function mouse(x, y)
    part(c, c:ellipse(x, y, 3, 2), "#9a98a8"); part(c, c:ellipse(x + 3, y - 1, 1, 1), "#9a98a8", { noline = true })
    c:px(x + 2, y - 3, "#e08a7a"); c:px(x + 4, y, INK); c:px(x + 5, y, "#e08a7a")
    c:fill(c:line({ { x - 3, y }, { x - 6, y - 1 } }, 1), "#e08a7a")
    fl(c, R(c, x + 5, y + 1, x + 7, y + 2), "#d9a660")
  end
  mouse(40, 43); mouse(50, 48); mouse(59, 44)
  finish(c, "w2_granary_mice")
end

local order = { "w2_chutney_pot", "w2_level_trestles", "w2_stall_signs", "w2_juggle_match", "w2_taster_showdown", "w2_bunting_patterns", "w2_stamped_weight", "w2_honest_scale", "w2_cheese_roll", "w2_weigher_memory", "w2_bargains_of_old", "w2_branch_wheel", "w2_sift_flour", "w2_grease_cogs", "w2_granary_mice" }
for _, s2 in ipairs(order) do
  if not only or only == s2 then seed = 7; S[s2]() end
end
