-- variety-act-g24.lua : Do-tab scenes for 13 NA/CA regional rest-stop activities -> act-<slug>.png (144x108, 72x54 grid at out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g24.lua (params BEFORE --script)
-- Gnome sprite + frame copied from variety-act-g5.lua; frame pixel-exact from act-hand.png.
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

---------------------------------------------------------------- scenes
local S = {}
local function wisp(c, x, y, n, col)
  for i = 0, n do
    local sx = x + ((i % 2 == 0) and 0 or 1)
    fl(c, R(c, sx, y - i * 2, sx + 1, y - i * 2 + 1), col or "#f4f8fa")
  end
end
local function leafy(c, x, y, rx, ry, col, col2)
  part(c, c:ellipse(x, y, rx, ry), col, { shade = true })
  if col2 then c:fill(c:ellipse(x - 1, y - 1, rx - 3, ry - 3), col2) end
end

-- 1. na_pitch_candles: gnome at a table dipping candles in a pitch pot; a drying rack of candles; pine with amber resin
function S.na_pitch_candles()
  seed = 31
  local c = new()
  day(c, 33, { cloud = 52, sky = { "#c4dcd8", "#d6e6dc", "#e4eadc" }, hill = "#4e7a3a", hill2 = "#3f6a32" })
  -- big pine trunk left with resin drips
  part(c, R(c, 6, 8, 12, 41), "#6b4a2e")
  fl(c, R(c, 8, 10, 8, 38), "#5a3a24")
  for _, d in ipairs({ { 7, 18, 4 }, { 10, 24, 6 }, { 7, 30, 3 } }) do
    fl(c, R(c, d[1], d[2], d[1], d[2] + d[3]), "#e8a317"); fl(c, R(c, d[1], d[2] + d[3], d[1] + 1, d[2] + d[3] + 1), "#f5cf6a")
  end
  part(c, c:poly({ { 9, 4 }, { 16, 14 }, { 2, 14 } }), "#2f5a2a")
  -- drying rack: crossbar with hanging candles
  part(c, R(c, 36, 12, 37, 28), "#6b4a2e", { noline = true }); part(c, R(c, 60, 12, 61, 28), "#6b4a2e", { noline = true })
  part(c, R(c, 35, 11, 62, 13), "#8a5a35")
  for i = 0, 5 do
    local x = 39 + i * 4
    fl(c, R(c, x, 14, x, 14), "#2a1a10")
    part(c, R(c, x - 1, 15, x + 1, 15 + 5 + (i % 3)), (i % 2 == 0) and "#f4eee0" or "#f0dca0")
  end
  -- lit candle on the stump to the far right
  -- table
  part(c, R(c, 28, 35, 66, 38), "#b07a45"); fl(c, R(c, 28, 35, 66, 35), "#d9a660")
  part(c, R(c, 31, 39, 33, 48), "#8a5a35", { noline = true }); part(c, R(c, 62, 39, 64, 48), "#8a5a35", { noline = true })
  -- pot of pitch on a tiny fire
  part(c, c:rrect(37, 28, 48, 35, 2), "#2a2a30", { shade = true })
  fl(c, R(c, 38, 29, 47, 29), "#e8a317"); fl(c, R(c, 42, 29, 45, 29), "#f5cf6a")
  wisp(c, 50, 26, 3, "#d6dad8")
  -- finished candles and bowl of beeswax chunks
  for i = 0, 2 do part(c, R(c, 61 + i * 2 - 1 + (i == 2 and 1 or 0), 29, 61 + i * 2 + (i == 2 and 1 or 0), 34), "#f0dca0") end
  part(c, c:ellipse(56, 34, 4, 1), "#e8c48a")
  -- gnome dipping a candle on a string into the pot
  local _, G = gnome(c, 23, 47, { s = 1.15, d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 17 }, true) } })
  local hx, hy = G.P(9, 17)
  fl(c, R(c, hx + 1, hy, hx + 3, hy), "#d9bc84")
  fl(c, R(c, hx + 3, hy, hx + 3, hy + 2), "#d9bc84")
  part(c, R(c, hx + 2, hy + 2, hx + 4, hy + 7), "#f4eee0")
  fl(c, R(c, hx + 2, hy + 5, hx + 4, hy + 7), "#e8a317")
  c:px(hx + 3, hy + 9, "#e8a317")
  finish(c, "na_pitch_candles")
end

-- 2. na_prairie_birds: gnome on a log by a lake with binoculars, a cardinal on a maple branch, a loon on the water
function S.na_prairie_birds()
  seed = 41
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 26), { "#b4d6e0", "#c4e0e4", "#d6ebe6" }, { dir = "v" })
  c:fill(c:ellipse(52, 9, 8, 2), "#f4eee0"); c:fill(c:ellipse(56, 7, 5, 2), "#f4eee0")
  c:fill(c:ellipse(14, 27, 30, 8), "#c8602e"); c:fill(c:ellipse(58, 28, 26, 7), "#a8502a")
  -- lake
  c:fill(R(c, 0, 27, W - 1, 38), "#4f8fb0")
  for _, w in ipairs({ { 8, 31 }, { 26, 34 }, { 52, 30 }, { 40, 36 } }) do fl(c, R(c, w[1], w[2], w[1] + 4, w[2]), "#7cb8d0") end
  -- loon on the water
  part(c, c:ellipse(28, 32, 5, 2), "#2a2a34")
  fl(c, R(c, 24, 32, 31, 32), "#f4eee0")
  part(c, R(c, 31, 27, 32, 32), "#2a2a34", { noline = true }); part(c, R(c, 31, 26, 34, 28), "#2a2a34")
  c:px(33, 27, "#dd3a2a"); fl(c, R(c, 35, 27, 36, 27), "#c0c4c8")
  fl(c, R(c, 31, 30, 32, 30), "#f4eee0")
  for x = 22, 35 do if x % 2 == 0 then c:px(x, 34, "#7cb8d0") end end
  -- grass bank
  c:fill(R(c, 0, 38, W - 1, H - 1), "#7a9c4e"); c:fill(R(c, 0, 38, W - 1, 38), "#9cb868")
  for i = 1, 12 do c:px(floor(rand() * 64) + 4, 41 + floor(rand() * 8), "#5e8244") end
  -- maple at left with a cardinal on a branch
  part(c, R(c, 10, 14, 13, 44), "#6b4a2e", { noline = true })
  part(c, c:line({ { 13, 22 }, { 30, 17 } }, 2), "#6b4a2e", { noline = true })
  leafy(c, 11, 10, 11, 8, "#d25a1f", "#e8801f")
  leafy(c, 26, 12, 7, 5, "#c84a1a", "#e8a317")
  part(c, c:ellipse(25, 15, 3, 2), "#dd2a2a"); part(c, c:ellipse(28, 13, 2, 2), "#dd2a2a")
  c:px(29, 13, "#2a1a10"); fl(c, R(c, 30, 13, 31, 14), "#f0a020"); fl(c, R(c, 21, 16, 23, 16), "#aa1818")
  -- gnome seated on a log, binoculars up, tea flask beside
  part(c, R(c, 38, 43, 62, 47), "#8a5a35"); fl(c, R(c, 39, 43, 61, 43), "#a8703e")
  c:fill(c:ellipse(62, 45, 1, 2), "#e8c48a")
  local _, G = gnome(c, 54, 43, { d = -1, sit = true, eyes = "open", arms = { arm({ -4, 6 }, { -7, 10 }, true, true) } })
  local bx, by = G.P(-6, 11)
  part(c, R(c, bx - 4, by - 1, bx - 1, by + 1), "#2a2a34")
  fl(c, R(c, bx - 4, by - 1, bx - 4, by + 1), "#8a8f98")
  fl(c, R(c, bx - 1, by - 1, bx - 1, by + 1), "#8a8f98")
  fl(c, R(c, bx, by, bx + 1, by + 1), "#f0c8a0")
  part(c, R(c, 40, 39, 42, 43), "#3f8fb0"); fl(c, R(c, 40, 38, 42, 38), "#8a5a35")
  finish(c, "na_prairie_birds")
end

-- 3. na_beaver_dam: pond on the left, a dam of sticks with a gap; gnome plugs it with a branch, beaver brings another
function S.na_beaver_dam()
  seed = 51
  local c = new()
  day(c, 22, { cloud = 55, sky = { "#b4d6e0", "#c8e0e0", "#dcebe0" }, hill = "#4e7a3a", hill2 = "#3f6a32" })
  -- ground and water
  c:fill(R(c, 0, 22, W - 1, H - 1), "#7ea85a")
  -- pond (left/back) and stream (front right)
  c:fill(c:ellipse(22, 34, 22, 10), "#3f87ac")
  c:fill(R(c, 0, 30, 20, 46), "#3f87ac")
  for _, w in ipairs({ { 6, 33 }, { 14, 38 }, { 20, 31 }, { 8, 42 } }) do fl(c, R(c, w[1], w[2], w[1] + 4, w[2]), "#7cb8d0") end
  -- the stream going away at right (lower)
  c:fill(R(c, 50, 30, 68, 49), "#4f98b8")
  for _, w in ipairs({ { 54, 34 }, { 60, 40 }, { 56, 46 } }) do fl(c, R(c, w[1], w[2], w[1] + 3, w[2]), "#9ad0e0") end
  -- the dam: tangled sticks, vertical wall of the stream bank
  part(c, R(c, 28, 26, 50, 46), "#7a5030")
  for i = 0, 8 do
    local y = 27 + i * 2
    fl(c, R(c, 28, y, 49, y), (i % 2 == 0) and "#5e3a22" or "#9a6a3c")
  end
  for _, s in ipairs({ { 29, 26, 36, 24 }, { 40, 25, 48, 27 }, { 33, 28, 42, 30 } }) do
    c:fill(c:line({ { s[1], s[2] }, { s[3], s[4] } }, 1), "#8a5a35")
  end
  -- gap with water pouring through
  c:fill(R(c, 36, 27, 41, 43), "#3f87ac")
  fl(c, R(c, 37, 29, 38, 41), "#a8dcec"); fl(c, R(c, 40, 33, 40, 43), "#a8dcec")
  fl(c, R(c, 34, 44, 43, 45), "#d6f0f4")
  -- gnome on the dam with a stick, plugging the gap
  local _, G = gnome(c, 24, 47, { s = 1.2, d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 9, 10 }, true) } })
  local sx, sy = G.P(9, 10)
  part(c, c:line({ { sx, sy - 2 }, { 36, 28 } }, 2), "#8a5a35", { noline = true })
  -- beaver at the right with a stick in its teeth
  part(c, c:ellipse(56, 47, 6, 4), "#8a5a35", { shade = true })
  part(c, c:ellipse(49, 44, 3, 3), "#8a5a35", { shade = true })
  part(c, c:poly({ { 61, 47 }, { 66, 45 }, { 66, 49 }, { 61, 49 } }), "#5e3a22")
  fl(c, R(c, 62, 46, 64, 46), "#7a5030"); fl(c, R(c, 62, 48, 64, 48), "#7a5030")
  c:px(48, 43, "#1a1008"); fl(c, R(c, 47, 46, 48, 47), "#f4eee0"); c:px(49, 42, "#5e3a22")
  c:fill(c:line({ { 46, 46 }, { 42, 40 } }, 1), "#a8703e")
  fl(c, R(c, 41, 39, 43, 40), "#a8703e")
  -- reeds
  for _, x in ipairs({ 4, 11, 17 }) do fl(c, R(c, x, 26, x, 31), "#5e8244"); fl(c, R(c, x, 24, x, 26), "#8a5a35") end
  finish(c, "na_beaver_dam")
end

-- 4. na_pumpkin_roll: autumn field, gnome shoving a pumpkin along a furrow, kids cheering on a hay bale
function S.na_pumpkin_roll()
  seed = 61
  local c = new()
  day(c, 30, { cloud = 14, sky = { "#e4c89a", "#ecd4a8", "#f0dcb4" }, hill = "#b8783a", hill2 = "#a8682e", grass = "#a8a050", edge = "#c4b868" })
  -- autumn trees
  for _, t in ipairs({ { 8, 31 }, { 64, 30 } }) do
    part(c, R(c, t[1] - 1, t[2] - 8, t[1] + 1, t[2]), "#6b4a2e", { noline = true })
    leafy(c, t[1], t[2] - 12, 8, 7, "#d25a1f", "#e8a317")
  end
  -- orange pumpkins in the patch along the horizon
  for _, p in ipairs({ { 20, 34 }, { 30, 33 }, { 44, 34 }, { 54, 33 } }) do
    part(c, c:ellipse(p[1], p[2], 3, 2), "#e0701f"); fl(c, R(c, p[1], p[2] - 3, p[1], p[2] - 2), "#4e7a3a")
  end
  -- furrow dirt strip
  c:fill(R(c, 5, 44, 68, 49), "#a8703e"); fl(c, R(c, 5, 44, 68, 44), "#c08a52")
  for x = 8, 66, 5 do c:px(x, 47, "#8a5a35") end
  -- the big pumpkin being rolled
  part(c, c:ellipse(44, 42, 9, 8), "#e0701f", { shade = true })
  for _, dx in ipairs({ -5, -2, 2, 5 }) do fl(c, R(c, 44 + dx, 36 + (math.abs(dx) > 3 and 2 or 0), 44 + dx, 48 - (math.abs(dx) > 3 and 2 or 0)), "#b8501a") end
  part(c, R(c, 43, 31, 45, 34), "#4e7a3a")
  fl(c, R(c, 40, 37, 41, 38), "#f09a40")
  -- speed lines
  fl(c, R(c, 56, 40, 61, 40), "#f4eee0"); fl(c, R(c, 57, 44, 63, 44), "#f4eee0")
  -- gnome pushing hard, leaning in
  gnome(c, 29, 46, { s = 1.2, d = 1, walk = 1, eyes = "open", arms = { arm({ 4, 7 }, { 10, 9 }, true), arm({ -2, 7 }, { 7, 6 }, false) } })
  -- kids on a hay bale at the back
  part(c, R(c, 4, 36, 17, 41), "#d9bc54"); for x = 6, 15, 3 do fl(c, R(c, x, 37, x, 40), "#b8953a") end
  gnome(c, 8, 36, { s = 0.7, d = 1, upper = true, hat = "#4f9a45", eyes = "happy", arms = { arm({ 3, 6 }, { 5, 13 }, true) } })
  gnome(c, 14, 36, { s = 0.7, d = 1, upper = true, hat = "#e8a317", eyes = "happy", arms = { arm({ 3, 6 }, { 5, 13 }, true) } })
  finish(c, "na_pumpkin_roll")
end


-- 5. na_full_bucket: four sap buckets on four maples, one brim-full and dripping; the gnome points at it
function S.na_full_bucket()
  seed = 71
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#e8d4a8", "#ecdcb4", "#f0e2c0" }, { dir = "v" })
  c:fill(c:ellipse(16, 30, 30, 9), "#b8783a"); c:fill(c:ellipse(58, 31, 28, 8), "#a8682e")
  c:fill(R(c, 0, 30, W - 1, H - 1), "#a8a050"); c:fill(R(c, 0, 30, W - 1, 30), "#c4b868")
  for i = 1, 14 do c:px(floor(rand() * 64) + 4, 33 + floor(rand() * 15), "#8a8a3e") end
  -- fallen leaves
  for _, l in ipairs({ { 8, 46 }, { 20, 48 }, { 46, 47 }, { 60, 45 }, { 30, 44 } }) do fl(c, R(c, l[1], l[2], l[1] + 1, l[2]), "#d25a1f") end
  local xs = { 11, 26, 42, 58 }
  for k, x in ipairs(xs) do
    part(c, R(c, x - 2, 12, x + 2, 44), "#6b4a2e", { noline = true })
    fl(c, R(c, x - 1, 16, x - 1, 40), "#5a3a24"); fl(c, R(c, x + 2, 14, x + 2, 42), "#7a5a3a")
  end
  -- one continuous orange canopy
  for k, x in ipairs(xs) do
    leafy(c, x, 9, 9, 6, (k % 2 == 1) and "#d25a1f" or "#c84a1a", (k % 2 == 1) and "#e8801f" or "#e8a317")
  end
  -- buckets with spiles
  for k, x in ipairs(xs) do
    local full = (k == 3)
    fl(c, R(c, x + 2, 24, x + 4, 24), "#8a8f98")
    part(c, R(c, x + 3, 25, x + 9, 33), "#aeb4bc")
    fl(c, R(c, x + 3, 28, x + 9, 28), "#8a8f98"); fl(c, R(c, x + 3, 31, x + 9, 31), "#8a8f98")
    part(c, c:ellipse(x + 6, 25, 3, 1), full and "#f5cf6a" or "#8a8f98", { noline = false })
    c:fill(c:ellipse(x + 6, 25, 2, 1), full and "#f5e6a8" or "#5a5048")
    if full then
      fl(c, R(c, x + 4, 23, x + 8, 24), "#f5cf6a"); fl(c, R(c, x + 5, 22, x + 7, 22), "#f5cf6a")
      fl(c, R(c, x + 9, 26, x + 9, 34), "#f5cf6a"); fl(c, R(c, x + 3, 27, x + 3, 30), "#f5cf6a"); fl(c, R(c, x + 10, 35, x + 10, 36), "#f5cf6a")
      c:px(x + 10, 32, "#f5cf6a"); c:px(x + 6, 36, "#f5cf6a")
    else
      c:px(x + 3, 25, "#aeb4bc")
    end
  end
  gnome(c, 33, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 9 }, { 8, 17 }, true) } })
  finish(c, "na_full_bucket")
end

-- 6. na_aurora_watch: night, snowy shore; the gnome in a scarf on a log, mug in hand, green ribbons over the pines
function S.na_aurora_watch()
  seed = 81
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#0e1630", "#141e3e", "#1a2848", "#203050" }, { dir = "v" })
  for i = 1, 28 do c:px(5 + floor(rand() * 63), 5 + floor(rand() * 32), (i % 4 == 0) and "#f4eee0" or "#8a9cc0") end
  -- aurora: wavy curtains
  local function curtain(y0, amp, ph, cols, len)
    for x = 5, 68 do
      local top = y0 + rnd(amp * math.sin(x / 6.5 + ph))
      for j = 0, len - 1 do
        local col = cols[1 + floor(j * #cols / len)]
        if (x % 2 == 0) or j < len - 4 then c:px(x, top + j, col) end
      end
    end
  end
  curtain(8, 4, 0, { "#7ae8b0", "#4fd08a", "#2fa878", "#1f7a78" }, 11)
  curtain(17, 3, 2, { "#a8f0c8", "#5fdca0", "#3a9ab0", "#34588a" }, 7)
  for x = 8, 66, 7 do c:px(x, 8 + rnd(4 * math.sin(x / 6.5)), "#d6ffe4") end
  c:fill(c:ellipse(60, 12, 3, 3), "#e8ecc0"); c:fill(c:ellipse(61, 11, 3, 3), "#141e3e")
  -- far shore and lake with a green shimmer
  c:fill(c:ellipse(18, 38, 32, 5), "#10202e"); c:fill(c:ellipse(56, 38, 30, 4), "#12242e")
  c:fill(R(c, 5, 38, 68, 42), "#1c3850")
  for x = 8, 66, 4 do fl(c, R(c, x, 39 + ((x / 4) % 2), x + 2, 39 + ((x / 4) % 2)), (x % 8 == 0) and "#3fa890" or "#2a6a78") end
  -- silhouette pines
  for _, t in ipairs({ { 6, 44, 20 }, { 14, 44, 15 }, { 64, 44, 19 }, { 56, 44, 14 } }) do
    local x, yb, h = t[1], t[2], t[3]
    local m = c:mask()
    for i = 0, h - 1 do local hw = rnd(i * 5 / h); m:add(c:rect(x - hw, yb - h + i, x + hw, yb - h + i)) end
    c:fill(m, "#0c1420"); c:fill(R(c, x, yb - 1, x, yb + 1), "#0c1420")
  end
  c:fill(R(c, 5, 43, 68, 49), "#c8d8e6"); c:fill(R(c, 5, 43, 68, 43), "#e8f0f6")
  for _, p in ipairs({ { 10, 47 }, { 24, 48 }, { 52, 47 }, { 62, 48 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#a8bcd0") end
  -- log seat
  part(c, R(c, 25, 43, 49, 47), "#6b4a2e"); fl(c, R(c, 26, 43, 48, 43), "#8a6a44")
  local _, G = gnome(c, 38, 43, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 6 }, { 6, 8 }, true) } })
  -- scarf
  local sx0, sy0 = G.P(-3, 9)
  fl(c, R(c, sx0, sy0, sx0 + 6, sy0 + 1), "#e8a317")
  fl(c, R(c, sx0 + 1, sy0, sx0 + 1, sy0 + 1), "#c0442e"); fl(c, R(c, sx0 + 4, sy0, sx0 + 4, sy0 + 1), "#c0442e")
  fl(c, R(c, sx0 + 5, sy0 + 2, sx0 + 6, sy0 + 5), "#e8a317")
  -- mug with steam
  local mx, my = G.P(6, 8)
  part(c, R(c, mx, my - 1, mx + 3, my + 3), "#d9a660"); fl(c, R(c, mx + 4, my, mx + 4, my + 1), "#d9a660")
  wisp(c, mx + 1, my - 3, 2, "#c8d8e6")
  -- lantern on the log
  part(c, R(c, 28, 40, 31, 43), "#2a2a30"); fl(c, R(c, 29, 41, 30, 42), "#ffd86a"); fl(c, R(c, 29, 39, 30, 39), "#2a2a30")
  finish(c, "na_aurora_watch")
end

-- 7. ca_tortilla_press: stall under a striped awning; the gnome leans on the press lever, comal sizzling, a warm stack of tortillas
function S.ca_tortilla_press()
  seed = 91
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#d8905a")
  c:fill(R(c, 0, 24, W - 1, 40), "#c8804e")
  for x = 5, 68, 8 do fl(c, R(c, x, 14, x + 3, 15), "#c07044"); fl(c, R(c, x + 4, 28, x + 7, 29), "#b87040") end
  -- striped awning
  for x = 5, 68 do
    local col = ((floor((x - 5) / 4)) % 2 == 0) and "#dd3a2a" or "#f4eee0"
    c:px(x, 5, col); c:px(x, 6, col); c:px(x, 7, col); c:px(x, 8, col); c:px(x, 9, col)
    if (floor((x - 5) / 2)) % 2 == 0 then c:px(x, 10, col) end
  end
  fl(c, R(c, 5, 5, 68, 5), "#b02a1c")
  -- ristra of chilies on the wall
  fl(c, R(c, 10, 11, 10, 14), "#d9bc84")
  for i = 0, 3 do part(c, c:ellipse(i % 2 == 0 and 9 or 12, 14 + i * 3, 1, 2), "#dd3a2a", { noline = true }) end
  -- table
  part(c, R(c, 5, 38, 68, 42), "#a8703e"); fl(c, R(c, 5, 38, 68, 38), "#d9a660")
  part(c, R(c, 5, 43, 68, 49), "#f4eee0")
  for x = 7, 66, 6 do fl(c, R(c, x, 43, x + 2, 49), "#3f8fb0") end
  fl(c, R(c, 5, 43, 68, 43), "#3f8fb0")
  -- press: base board, lid, long lever
  part(c, R(c, 30, 35, 42, 37), "#8a5a35")
  part(c, c:ellipse(36, 34, 4, 1), "#f0dca0")
  part(c, R(c, 30, 30, 42, 32), "#a8703e")
  part(c, R(c, 42, 27, 44, 37), "#6b4a2e", { noline = true })
  part(c, c:line({ { 43, 29 }, { 29, 22 } }, 2), "#6b4a2e", { noline = true })
  -- gnome behind, pushing the lever down
  local _, G = gnome(c, 20, 44, { s = 1.25, d = 1, upper = true, eyes = "open", arms = { arm({ 4, 11 }, { 7, 17 }, true), arm({ -4, 10 }, { 5, 17 }, false) } })
  -- stack of tortillas and a corn pile
  for i = 0, 3 do part(c, c:ellipse(52, 36 - i, 5, 1), (i % 2 == 0) and "#f0dca0" or "#e8c880") end
  wisp(c, 54, 31, 2, "#f4f8fa")
  part(c, c:ellipse(63, 37, 3, 2), "#f5cf6a"); fl(c, R(c, 62, 34, 62, 36), "#e8a317"); fl(c, R(c, 64, 34, 64, 36), "#e8a317")
  part(c, c:ellipse(46, 37, 3, 1), "#e8c880")
  finish(c, "ca_tortilla_press")
end

-- 8. ca_cocoa_grind: kitchen with a sun-shaft; the gnome grinds roasted cacao on a stone metate, pods and a steaming mug beside
function S.ca_cocoa_grind()
  seed = 101
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#b87a4a")
  for y = 10, 36, 9 do for x = 5, 68, 8 do fl(c, R(c, x + (y % 2) * 3, y, x + 3 + (y % 2) * 3, y), "#a86a3e") end end
  c:fill(R(c, 5, 5, 68, 6), "#6b3b2a")
  -- window with sunlight
  part(c, R(c, 44, 11, 58, 27), "#6b3b2a")
  c:fill(R(c, 46, 13, 56, 25), "#f5e6a8"); fl(c, R(c, 51, 13, 51, 25), "#6b3b2a"); fl(c, R(c, 46, 19, 56, 19), "#6b3b2a")
  c:fill(c:poly({ { 46, 26 }, { 56, 26 }, { 40, 49 }, { 26, 49 } }):clip(R(c, 0, 26, 70, 40)), "#cc9a68")
  -- shelf with jars at left
  part(c, R(c, 7, 19, 30, 20), "#6b3b2a")
  part(c, R(c, 8, 12, 13, 18), "#d9a660"); fl(c, R(c, 8, 12, 13, 13), "#6b3b2a")
  part(c, R(c, 16, 14, 21, 18), "#aeb4bc"); part(c, R(c, 24, 11, 28, 18), "#8a5a35")
  -- floor
  c:fill(R(c, 5, 39, 68, 49), "#8a5a35")
  for x = 5, 68, 9 do fl(c, R(c, x, 39, x, 49), "#6b3b2a") end
  fl(c, R(c, 5, 44, 68, 44), "#6b3b2a")
  -- stone bench + metate (slab) + mano
  part(c, R(c, 36, 41, 64, 49), "#8b8f96", { shade = true })
  fl(c, R(c, 37, 41, 63, 41), "#aeb2ba")
  part(c, c:poly({ { 36, 37 }, { 66, 37 }, { 64, 41 }, { 38, 41 } }), "#b4b6bc")
  fl(c, R(c, 40, 38, 62, 38), "#9a9ca4")
  -- ground cacao heap at the far end
  for _, b2 in ipairs({ { 60, 36 }, { 62, 37 }, { 58, 37 }, { 61, 38 } }) do part(c, c:ellipse(b2[1], b2[2], 1, 1), "#4a2c1a", { noline = true }) end
  -- gnome pushing the mano over the slab
  local _, G = gnome(c, 28, 49, { s = 1.2, d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 11, 12 }, true) } })
  part(c, R(c, 41, 34, 53, 37), "#5e3a22")
  fl(c, R(c, 41, 34, 53, 34), "#7a5030")
  fl(c, R(c, 38, 36, 38, 36), "#f0c8a0")
  -- cacao pods on the floor, and a steaming mug on a stool at the left
  for _, p in ipairs({ { 52, 47 }, { 60, 48 } }) do
    part(c, c:ellipse(p[1], p[2], 4, 2), "#e8a317", { shade = true })
    fl(c, R(c, p[1] - 2, p[2], p[1] + 2, p[2]), "#b86a1a")
  end
  part(c, R(c, 9, 42, 15, 43), "#8a5a35"); part(c, R(c, 10, 44, 11, 48), "#6b3b2a", { noline = true }); part(c, R(c, 13, 44, 14, 48), "#6b3b2a", { noline = true })
  part(c, R(c, 10, 38, 14, 41), "#f4eee0"); fl(c, R(c, 11, 38, 13, 39), "#4a2c1a"); fl(c, R(c, 15, 39, 15, 40), "#f4eee0")
  wisp(c, 12, 35, 3, "#f4eee0")
  finish(c, "ca_cocoa_grind")
end


-- 9. ca_quetzal_trail: dense jungle, the gnome points up at a quetzal with a long tail; a toucan peeks from the leaves
function S.ca_quetzal_trail()
  seed = 111
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 49), { "#2f6a3a", "#2a5e36", "#3a7a42", "#4a8a48" }, { dir = "v" })
  -- distant light glade
  c:fill(c:ellipse(36, 22, 18, 12), "#8ac070"); c:fill(c:ellipse(36, 24, 11, 7), "#b8dc8a")
  -- tree trunks and vines
  part(c, R(c, 6, 5, 11, 49), "#5e3f28", { noline = true }); fl(c, R(c, 8, 5, 8, 49), "#4a3020")
  part(c, R(c, 62, 5, 66, 49), "#5e3f28", { noline = true }); fl(c, R(c, 64, 5, 64, 49), "#4a3020")
  for _, v in ipairs({ { 18, 5, 14 }, { 54, 5, 18 }, { 24, 5, 9 } }) do
    fl(c, R(c, v[1], v[2], v[1], v[2] + v[3]), "#2a5a2a"); fl(c, R(c, v[1] - 1, v[2] + v[3], v[1] + 1, v[2] + v[3] + 1), "#3f8a42")
  end
  -- big leaves at the top corners
  c:fill(c:ellipse(8, 7, 9, 4), "#1f5a2a"); c:fill(c:ellipse(60, 6, 11, 4), "#1f5a2a")
  c:fill(c:ellipse(30, 6, 7, 3), "#2a7a3a"); c:fill(c:ellipse(46, 8, 6, 3), "#3a8a44")
  -- branch with the quetzal
  part(c, c:line({ { 11, 22 }, { 40, 20 }, { 62, 24 } }, 2), "#5e3f28", { noline = true })
  part(c, c:ellipse(46, 18, 4, 3), "#e0202a")
  part(c, c:ellipse(46, 15, 4, 3), "#2fb860", { shade = true })
  part(c, c:ellipse(49, 12, 3, 3), "#2fb860")
  fl(c, R(c, 52, 12, 53, 13), "#f0c020"); c:px(50, 11, "#1a1008")
  fl(c, R(c, 43, 14, 45, 15), "#1e8a48"); fl(c, R(c, 44, 17, 46, 17), "#f4eee0")
  for k = 0, 2 do c:fill(c:line({ { 44 + k, 19 }, { 40 + k * 2, 29 + k * 2 }, { 43 + k * 2, 39 + k } }, 1), (k == 1) and "#7cdc9a" or "#1fa858") end
  -- toucan low at the right
  part(c, c:ellipse(58, 31, 3, 4), "#2a2a30"); fl(c, R(c, 56, 29, 58, 30), "#f4eee0")
  part(c, R(c, 52, 29, 56, 31), "#f08a24"); fl(c, R(c, 52, 31, 56, 31), "#dd3a2a"); c:px(57, 28, "#f4eee0")
  part(c, c:line({ { 52, 36 }, { 66, 36 } }, 1), "#5e3f28", { noline = true })
  -- path
  c:fill(c:poly({ { 26, 38 }, { 46, 38 }, { 64, 49 }, { 8, 49 } }), "#a88858")
  fl(c, R(c, 20, 44, 24, 44), "#8a6a40"); fl(c, R(c, 46, 46, 52, 46), "#8a6a40")
  c:fill(R(c, 5, 44, 12, 49), "#3f8a42"); c:fill(R(c, 62, 43, 68, 49), "#3f8a42")
  leafy(c, 12, 46, 5, 3, "#3f8a42", "#5aaa50"); leafy(c, 62, 46, 6, 3, "#2a7a3a", "#4a9a48")
  -- gnome pointing up, notebook in the other hand
  gnome(c, 30, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -7, 7 }, false), arm({ 4, 9 }, { 8, 19 }, true) } })
  part(c, R(c, 19, 38, 23, 43), "#f4eee0"); fl(c, R(c, 20, 40, 22, 40), "#8a5a35"); fl(c, R(c, 20, 42, 22, 42), "#8a5a35")
  finish(c, "ca_quetzal_trail")
end

-- 10. ca_milpa_row: corn stalks with beans climbing and squash below, a volcano behind; the gnome waters the row
function S.ca_milpa_row()
  seed = 121
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#f0c890", "#f4d4a0", "#f8e0b4" }, { dir = "v" })
  -- volcano
  c:fill(c:poly({ { 40, 8 }, { 50, 8 }, { 64, 31 }, { 26, 31 } }), "#8a6a7a")
  c:fill(c:poly({ { 40, 8 }, { 50, 8 }, { 52, 13 }, { 38, 13 } }), "#b8a0aa")
  wisp(c, 46, 7, 1, "#f4eee0")
  c:fill(c:ellipse(14, 31, 26, 7), "#7a9a58"); c:fill(c:ellipse(62, 32, 22, 6), "#6a8a4c")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#a87848"); c:fill(R(c, 0, 31, W - 1, 31), "#c09058")
  -- dry earth ridges
  for y = 36, 48, 6 do fl(c, R(c, 5, y, 68, y), "#8a5e36") end
  -- the row: mounds with corn
  for k, x in ipairs({ 30, 42, 54, 66 }) do
    part(c, c:ellipse(x, 40, 6, 3), "#7a5030", { noline = false })
    part(c, R(c, x - 1, 15, x, 39), "#6aa04a", { noline = true })
    c:fill(c:line({ { x - 1, 22 }, { x - 7, 17 } }, 1), "#4e8a3c"); c:fill(c:line({ { x, 26 }, { x + 6, 21 } }, 1), "#4e8a3c")
    c:fill(c:line({ { x - 1, 31 }, { x - 6, 29 } }, 1), "#4e8a3c")
    part(c, R(c, x + 1, 27, x + 2, 32), "#f5cf6a", { noline = true }); fl(c, R(c, x + 1, 26, x + 2, 27), "#4e8a3c")
    fl(c, R(c, x - 1, 13, x, 15), "#e8c080")
    -- climbing bean vine
    fl(c, R(c, x - 2, 20, x - 2, 20), "#3f6a2a"); c:px(x - 2, 24, "#3f6a2a"); c:px(x + 1, 28, "#3f6a2a"); c:px(x - 2, 33, "#3f6a2a")
    c:px(x - 3, 21, "#c0442e"); c:px(x + 2, 25, "#c0442e")
  end
  -- squash at the foot: leaves and orange squash
  for _, x in ipairs({ 36, 48, 60 }) do
    leafy(c, x, 43, 4, 2, "#3f8a42", "#5aaa50")
    part(c, c:ellipse(x + 1, 45, 2, 1), "#e0901f", { noline = true })
  end
  -- gnome pouring from a watering can
  gnome(c, 14, 47, { s = 1.2, d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 11 }, true) } })
  part(c, R(c, 25, 32, 31, 37), "#aeb4bc"); fl(c, R(c, 25, 33, 31, 33), "#8a8f98")
  part(c, c:line({ { 31, 34 }, { 36, 31 } }, 1), "#aeb4bc", { noline = true })
  fl(c, R(c, 36, 30, 37, 31), "#8a8f98"); fl(c, R(c, 24, 31, 28, 31), "#aeb4bc")
  for _, d in ipairs({ { 37, 32 }, { 38, 35 }, { 39, 38 }, { 36, 34 }, { 37, 37 }, { 35, 40 } }) do c:px(d[1], d[2], "#7cc8e8") end
  finish(c, "ca_milpa_row")
end

-- 11. ca_hip_ball: stone ball court with a ring high on the wall; the gnome bumps a rubber ball with his hip, little gnomes cheer from the wall
function S.ca_hip_ball()
  seed = 131
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 22), { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  c:fill(c:ellipse(50, 9, 8, 2), "#f4eee0"); c:fill(c:ellipse(54, 7, 5, 2), "#f4eee0")
  -- stone wall
  c:fill(R(c, 0, 22, W - 1, 40), "#b8a888")
  for y = 27, 38, 5 do for x = 5, 68, 9 do fl(c, R(c, x + ((y / 5) % 2) * 4, y, x + 7 + ((y / 5) % 2) * 4, y), "#9a9070") end end
  -- spectators peering over the parapet
  gnome(c, 12, 26, { s = 0.7, d = 1, upper = true, hat = "#4f9a45", eyes = "happy", arms = { arm({ 3, 7 }, { 5, 14 }, true) } })
  gnome(c, 22, 26, { s = 0.7, d = 1, upper = true, hat = "#e8a317", eyes = "happy", arms = { arm({ 3, 7 }, { 5, 14 }, true) } })
  gnome(c, 62, 26, { s = 0.7, d = -1, upper = true, hat = "#3f8fb0", eyes = "happy", arms = { arm({ 3, 7 }, { 5, 14 }, true) } })
  part(c, R(c, 0, 24, W - 1, 28), "#8a7a5a")
  for x = 6, 66, 6 do fl(c, R(c, x, 25, x + 2, 26), "#c8b894") end
  -- the stone ring
  part(c, c:ellipse(52, 33, 4, 5), "#8a7a5a", { shade = true })
  c:fill(c:ellipse(52, 33, 2, 3), "#b8a888")
  -- court floor
  c:fill(R(c, 0, 40, W - 1, H - 1), "#d4b070"); c:fill(R(c, 0, 40, W - 1, 40), "#a88850")
  fl(c, R(c, 5, 44, 68, 44), "#c49c5c"); fl(c, R(c, 5, 48, 68, 48), "#c49c5c")
  -- the player: arms out, hip thrust at the ball
  gnome(c, 24, 48, { s = 1.2, d = 1, eyes = "open", arms = { arm({ -4, 9 }, { -9, 14 }, false), arm({ 4, 9 }, { 9, 12 }, true) } })
  -- ball (dark rubber) at the hip, dotted trail up toward the ring
  part(c, c:ellipse(34, 40, 3, 3), "#4a2c1a", { shade = true }); fl(c, R(c, 32, 38, 33, 39), "#8a5a35")
  for _, d in ipairs({ { 38, 36 }, { 41, 34 }, { 44, 33 }, { 40, 45 } }) do c:px(d[1], d[2], "#f4eee0") end
  fl(c, R(c, 31, 44, 33, 44), "#f4eee0")
  finish(c, "ca_hip_ball")
end

-- 12. ca_chili_guess: market table, four bowls of chilies from mild green to terrifying red with a wisp of fire; the gnome sweats over the choice
function S.ca_chili_guess()
  seed = 141
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#e0b078")
  c:fill(R(c, 0, 0, W - 1, 9), "#6a9a4e")
  for x = 5, 68, 6 do fl(c, R(c, x, 6, x + 2, 9), "#4e7a3a") end
  -- hanging chili strings on the back wall
  for _, x in ipairs({ 10, 60, 66 }) do
    fl(c, R(c, x, 10, x, 12), "#d9bc84")
    for i = 0, 3 do part(c, c:ellipse(x + ((i % 2 == 0) and -1 or 1), 14 + i * 3, 1, 2), (i % 2 == 0) and "#dd3a2a" or "#e8a317", { noline = true }) end
  end
  c:fill(R(c, 0, 38, W - 1, H - 1), "#b8864e")
  -- table
  part(c, R(c, 22, 35, 68, 39), "#a8703e"); fl(c, R(c, 22, 35, 68, 35), "#d9a660")
  part(c, R(c, 22, 40, 68, 49), "#f4eee0")
  for x = 24, 66, 6 do fl(c, R(c, x, 40, x + 2, 49), "#dd3a2a") end
  -- four bowls
  local cols = { { "#4a9a45", "#7cc060" }, { "#f0b020", "#f5cf6a" }, { "#dd3a2a", "#f06a4a" }, { "#8a1a1a", "#c02a2a" } }
  for k = 1, 4 do
    local x = 21 + k * 10
    part(c, c:rrect(x - 4, 31, x + 4, 36, 2), "#8a5a35", { shade = true })
    for j = 0, 3 do
      c:fill(c:line({ { x - 3 + j * 2, 31 }, { x - 2 + j * 2, 28 - (j % 2) } }, 2), cols[k][(j % 2) + 1])
    end
    fl(c, R(c, x - 3, 30, x + 3, 30), cols[k][1])
  end
  -- flames wisping off the hottest bowl
  fl(c, R(c, 61, 25, 61, 27), "#f08a24"); fl(c, R(c, 63, 23, 63, 26), "#e0501f"); fl(c, R(c, 62, 21, 62, 23), "#ffd86a"); fl(c, R(c, 59, 24, 59, 26), "#e0501f")
  -- gnome with a sweat drop, finger to chin
  local _, G = gnome(c, 13, 49, { s = 1.2, d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 14 }, true) } })
  local tx, ty = G.tipx, G.tipy
  c:px(21, 31 + 0, "#7cc8e8")
  fl(c, R(c, 4, 31, 4, 32), "#7cc8e8"); fl(c, R(c, 20, 27, 20, 28), "#7cc8e8")
  finish(c, "ca_chili_guess")
end

-- 13. ca_cenote_dip: cutaway sinkhole, a shaft of light through the roof, the gnome mid-leap above the blue water with a splash
function S.ca_cenote_dip()
  seed = 151
  local c = new()
  c:fill(R(c, 0, 0, W - 1, H - 1), "#2a2a30")
  -- cave walls with strata
  c:fill(R(c, 0, 0, W - 1, 49), "#6b5a4a")
  for y = 8, 48, 6 do fl(c, R(c, 0, y, W - 1, y), "#5a4a3c") end
  for y = 11, 45, 6 do for x = 5 + (y % 4) * 2, 68, 12 do fl(c, R(c, x, y, x + 5, y), "#7a6a58") end end
  -- the hole in the roof and light shaft
  c:fill(R(c, 0, 0, W - 1, 6), "#6a9a4e")
  c:fill(c:ellipse(36, 5, 12, 5), "#a8d4e0")
  c:fill(c:poly({ { 26, 7 }, { 46, 7 }, { 54, 38 }, { 18, 38 } }), "#8a7a62")
  c:fill(c:poly({ { 30, 7 }, { 42, 7 }, { 48, 38 }, { 24, 38 } }), "#a89a78")
  -- vines and grass lip
  for _, v in ipairs({ { 20, 14 }, { 28, 9 }, { 46, 12 }, { 52, 18 } }) do fl(c, R(c, v[1], 4, v[1], v[2]), "#2a7a3a"); fl(c, R(c, v[1] - 1, v[2], v[1] + 1, v[2] + 1), "#3f8a42") end
  for x = 8, 66, 3 do fl(c, R(c, x, 5, x + 1, 6 + (x % 2)), "#3f8a42") end
  -- water
  c:fill(R(c, 5, 38, 68, 49), "#2f9fb8")
  c:fill(c:ellipse(36, 41, 22, 3), "#6fdcdc")
  c:fill(c:ellipse(36, 41, 12, 1), "#bff4f0")
  for _, w in ipairs({ { 8, 45 }, { 20, 47 }, { 50, 46 }, { 58, 43 }, { 12, 41 } }) do fl(c, R(c, w[1], w[2], w[1] + 4, w[2]), "#5ac8d8") end
  -- ledge on the left
  part(c, R(c, 5, 30, 17, 38), "#8a7a62", { shade = true })
  fl(c, R(c, 5, 30, 17, 30), "#a8987a")
  -- gnome leaping, arms thrown wide, eyes squeezed shut
  gnome(c, 30, 31, { s = 1.1, d = 1, walk = 1, eyes = "shut", arms = { arm({ -4, 9 }, { -9, 17 }, false), arm({ 4, 9 }, { 9, 17 }, true) } })
  -- the splash column below him
  for _, d in ipairs({ { 30, 36 }, { 31, 35 }, { 29, 35 }, { 33, 37 }, { 27, 37 } }) do c:px(d[1], d[2], "#e8fbfa") end
  fl(c, R(c, 26, 40, 34, 40), "#e8fbfa"); fl(c, R(c, 28, 41, 32, 41), "#e8fbfa")
  fl(c, R(c, 56, 29, 56, 33), "#6fdcdc")
  finish(c, "ca_cenote_dip")
end

local order = { "na_pitch_candles", "na_prairie_birds", "na_beaver_dam", "na_pumpkin_roll", "na_full_bucket", "na_aurora_watch", "ca_tortilla_press", "ca_cocoa_grind", "ca_quetzal_trail", "ca_milpa_row", "ca_hip_ball", "ca_chili_guess", "ca_cenote_dip" }
for _, s2 in ipairs(order) do
  if S[s2] and (not only or only == s2 or only:find(s2, 1, true)) then seed = 7; S[s2]() end
end
