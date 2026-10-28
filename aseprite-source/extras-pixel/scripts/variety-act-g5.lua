-- variety-act-g5.lua : Do-tab scenes for 11 rest-stop activities -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- snow_soak egg_boil firewood campfire_story kettle frost_fair bench_rest trader_stall lantern_post wishing_well long_table
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g5.lua   (params BEFORE --script)
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

-- 1. snow_soak: neck-deep in a hot spring while snow falls, arms floating
function S.snow_soak()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#8ea4bd", "#9db1c6", "#adbfd1", "#bccbda", "#cdd9e4" }, { dir = "v" })
  c:fill(c:ellipse(16, 38, 30, 11), "#d3deea"); c:fill(c:ellipse(62, 37, 28, 9), "#dae4ee")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#e6edf3")
  c:fill(R(c, 0, 50, W - 1, H - 1), "#dbe5ee")
  pine(c, 10, 37, 17, true); pine(c, 19, 35, 12, true); pine(c, 62, 37, 17, true); pine(c, 53, 35, 11, true)
  -- stone rim and hot water
  part(c, c:ellipse(36, 42, 28, 9), "#8b8f96", { shade = true })
  c:fill(c:ellipse(36, 42, 24, 6.5), "#58b4c4")
  for _, x in ipairs({ 13, 20, 28, 44, 52, 59 }) do c:fill(c:ellipse(x, 35, 3, 1), "#f4f8fa") end
  local _, G = gnome(c, 36, 46, { s = 1.5, eyes = "shut" })
  -- snow cap on the hat
  G.hat:each(function(x, y) if y <= G.tipy + 2 then c:px(x, y, "#f4f8fa") end end)
  -- water over the lower body with a wavy lip
  local wm = c:ellipse(36, 42, 24, 6.5):clip(R(c, 0, 41, W, 60))
  c:fill(wm, "#58b4c4")
  for x = 13, 59 do if (x % 3) ~= 0 then c:px(x, 41, "#a8e6e6") end end
  c:fill(R(c, 19, 44, 25, 44), "#7ccfd4"); c:fill(R(c, 47, 45, 54, 45), "#7ccfd4"); c:fill(R(c, 30, 47, 38, 47), "#7ccfd4")
  -- floating arms, hands up
  fl(c, R(c, 24, 40, 29, 41), "#4a6e9a"); fl(c, R(c, 43, 40, 48, 41), "#4a6e9a")
  fl(c, R(c, 22, 39, 24, 41), "#f0c8a0"); fl(c, R(c, 48, 39, 50, 41), "#f0c8a0")
  for _, p in ipairs({ { 22, 38 }, { 49, 38 } }) do c:px(p[1], p[2], "#1a1008") end
  -- front rim stones
  for _, st in ipairs({ { 12, 46 }, { 17, 49 }, { 24, 51 }, { 31, 52 }, { 38, 52 }, { 45, 51 }, { 52, 49 }, { 58, 46 } }) do
    part(c, c:ellipse(st[1], st[2], 3, 2), "#9a9ea6", { shade = true })
  end
  -- steam wisps at the sides
  local function wisp(x, y0, n)
    for i = 0, n do
      local sx = x + ((i % 2 == 0) and 0 or (x < 36 and -1 or 1))
      fl(c, R(c, sx, y0 - i * 2, sx + 1, y0 - i * 2 + 1), "#f4f8fa")
    end
  end
  wisp(17, 38, 7); wisp(55, 38, 7); wisp(22, 36, 5); wisp(50, 36, 5)
  -- falling snow
  seed = 11
  for i = 1, 30 do
    local x, y = 6 + floor(rand() * 62), 6 + floor(rand() * 43)
    c:px(x, y, "#fbfdfe")
    if i % 5 == 0 then c:px(x + 1, y, "#fbfdfe"); c:px(x, y + 1, "#fbfdfe") end
  end
  finish(c, "snow_soak")
end

-- 2. egg_boil: lifting a boiled egg out of a bubbling spring on a ladle; toast and honey on a stump
function S.egg_boil()
  seed = 3
  local c = new()
  day(c, 32, { cloud = 48 })
  -- small camp tent on the left hill
  part(c, c:poly({ { 15, 18 }, { 22, 29 }, { 8, 29 } }), "#e8d2a0")
  c:fill(c:poly({ { 15, 22 }, { 18, 29 }, { 12, 29 } }), "#6b3b2a")
  -- spring: pale teal pool with stone rim
  part(c, c:ellipse(58, 43, 15, 6), "#8b8f96", { shade = true })
  c:fill(c:ellipse(58, 43, 12, 4), "#7cc9c8")
  c:fill(R(c, 49, 42, 54, 42), "#b8e8e0"); c:fill(R(c, 61, 44, 66, 44), "#b8e8e0")
  for _, b in ipairs({ { 56, 43 }, { 60, 42 }, { 63, 43 } }) do c:px(b[1], b[2], "#e8f8f4"); c:px(b[1] + 1, b[2], "#e8f8f4") end
  local function puff(x, y) c:fill(c:ellipse(x, y, 2, 1), "#f4eee0"); c:fill(R(c, x - 1, y + 1, x, y + 1), "#cfdcdc") end
  puff(64, 37); puff(66, 34); puff(64, 31); puff(53, 36)
  -- stump with toast and honey
  part(c, R(c, 8, 40, 18, 49), "#8a5a35")
  fl(c, R(c, 11, 43, 11, 48), "#5e2f1e"); fl(c, R(c, 15, 43, 15, 48), "#5e2f1e")
  part(c, c:ellipse(13, 40, 6, 2), "#e8c48a")
  part(c, R(c, 9, 35, 14, 38), "#d9a660")
  c:fill(R(c, 10, 35, 13, 35), "#e8a317"); c:px(12, 36, "#e8a317"); c:px(12, 37, "#e8a317")
  part(c, R(c, 15, 34, 18, 38), "#e8a317"); fl(c, R(c, 15, 33, 18, 33), "#8a4f2a"); c:px(16, 36, "#ffe08a")
  -- gnome lifting the egg out of the spring
  gnome(c, 32, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 6 }, { 9, 9 }, true) } })
  c:fill(c:line({ { 41, 38 }, { 47, 33 } }, 2), "#8a5a35")
  part(c, c:ellipse(50, 32, 3, 2), "#8a5a35")
  part(c, c:ellipse(50, 29, 2, 3), "#f4eee0")
  c:px(49, 28, "#fff8e0"); c:px(52, 34, "#7cc9c8"); c:px(52, 36, "#7cc9c8")
  finish(c, "egg_boil")
end

-- 3. firewood: a big gnome staggering under an armful of logs towards the woodpile
function S.firewood()
  seed = 21
  local c = new()
  day(c, 34, { sky = { "#b9d9d0", "#cfe2cc", "#dce8c8" }, hill = "#4e7a3a", hill2 = "#3f6a32", cloud = false })
  for _, t in ipairs({ { 9, 37 }, { 62, 34 } }) do
    part(c, R(c, t[1] - 1, t[2] - 12, t[1] + 1, t[2]), "#6b4a2e", { noline = true })
    part(c, c:ellipse(t[1], t[2] - 16, 6, 6), "#3f8a42", { shade = true })
  end
  -- woodpile at right
  local function logend(x, y) part(c, c:ellipse(x, y, 3, 3), "#a8703e"); c:fill(c:ellipse(x, y, 1, 1), "#e8c48a"); c:px(x, y, "#c08a52") end
  for i = 0, 2 do logend(52 + i * 7, 46) end
  for i = 0, 1 do logend(55 + i * 7, 40) end
  logend(58, 34)
  -- gnome with an armful, mid stride
  local _, G = gnome(c, 27, 47, { s = 1.25, d = 1, walk = 1, eyes = "open", arms = { arm({ -4, 7 }, { 0, 8 }, false, true) } })
  local function log(u0, u1, col, dx0, dx1)
    local x0, y0 = G.P(dx0, u1); local x1, y1 = G.P(dx1, u0)
    part(c, R(c, x0, y0, x1, y1), col)
    local my = floor((y0 + y1) / 2)
    for _, ex in ipairs({ x0, x1 }) do
      part(c, c:ellipse(ex, my, 2, 2), "#e8c48a"); c:fill(c:ellipse(ex, my, 1, 1), "#c08a52"); c:px(ex, my, "#8a5a35")
    end
    fl(c, R(c, x0 + 4, y0 + 1, x0 + 8, y0 + 1), "#5e2f1e")
  end
  log(1, 3, "#8a5a35", -8, 8); log(4, 6, "#b07a45", -9, 7); log(7, 8, "#a8582f", -7, 8)
  -- twigs sticking out of the top
  local tx, ty = G.P(-5, 10); c:fill(c:line({ { tx, ty }, { tx - 3, ty - 7 } }, 2), "#7a4a2a")
  c:fill(R(c, tx - 5, ty - 10, tx - 3, ty - 8), "#4e8a3c")
  tx, ty = G.P(5, 10); c:fill(c:line({ { tx, ty }, { tx + 4, ty - 6 } }, 2), "#7a4a2a")
  c:fill(R(c, tx + 3, ty - 9, tx + 6, ty - 7), "#4e8a3c")
  local hx, hy = G.P(8, 9); fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0")
  c:px(14, 48, "#d9a660"); c:px(40, 49, "#d9a660"); c:px(8, 47, "#d9a660"); c:px(34, 48, "#d9a660")
  finish(c, "firewood")
end

-- 4. campfire_story: night, the teller gestures under a beetle bubble, a small listener on a log
function S.campfire_story()
  seed = 5
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#2a3558", "#34426a", "#3f5078", "#4a5c84" }, { dir = "v" })
  for _, st in ipairs({ { 8, 8 }, { 34, 7 }, { 50, 12 }, { 46, 22 }, { 12, 26 }, { 34, 27 }, { 66, 24 } }) do c:px(st[1], st[2], "#f4eee0") end
  c:px(40, 11, "#f4eee0"); c:px(41, 12, "#f4eee0"); c:px(39, 12, "#f4eee0"); c:px(40, 13, "#f4eee0")
  c:fill(c:ellipse(61, 11, 4, 4), "#f5e6a8"); c:fill(c:ellipse(63, 10, 3, 3), "#3a4870")
  c:fill(c:ellipse(18, 35, 34, 10), "#26345a"); c:fill(c:ellipse(60, 36, 28, 8), "#2a3a60")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#35583a")
  c:fill(R(c, 0, 34, W - 1, 34), "#4a7048")
  c:fill(c:ellipse(40, 46, 20, 4), "#4c7a46"); c:fill(c:ellipse(40, 46, 12, 3), "#6a9650")
  -- fire
  part(c, c:line({ { 31, 46 }, { 49, 43 } }, 2), "#6b3b2a"); part(c, c:line({ { 31, 43 }, { 49, 46 } }, 2), "#8a5a35")
  part(c, c:poly({ { 40, 28 }, { 46, 38 }, { 47, 44 }, { 33, 44 }, { 34, 38 } }), "#e0501f")
  c:fill(c:poly({ { 40, 33 }, { 43, 39 }, { 44, 44 }, { 36, 44 }, { 37, 39 } }), "#f08a24")
  c:fill(c:ellipse(40, 41, 2, 3), "#ffd86a")
  c:px(34, 26, "#f08a24"); c:px(47, 29, "#f08a24"); c:px(44, 24, "#ffd86a")
  -- the teller, arms wide
  gnome(c, 19, 47, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -9, 14 }, false), arm({ 4, 8 }, { 9, 13 }, true) } })
  -- listener on a log
  part(c, R(c, 51, 44, 67, 47), "#8a5a35"); fl(c, R(c, 52, 44, 66, 44), "#a8703e")
  gnome(c, 58, 43, { d = -1, sit = true, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, true) } })
  -- story bubble with a singing beetle
  part(c, c:rrect(8, 8, 28, 20, 3), "#f4eee0")
  c:fill(c:poly({ { 19, 21 }, { 23, 21 }, { 20, 25 } }), "#f4eee0")
  c:fill(c:ellipse(15, 15, 3, 2), "#4a8a3e"); c:fill(c:ellipse(15, 15, 3, 2):clip(R(c, 15, 0, 20, 30)), "#2f5a2a")
  fl(c, R(c, 11, 14, 12, 15), "#2a1a10"); c:px(14, 12, INK); c:px(16, 12, INK)
  c:px(13, 18, INK); c:px(15, 18, INK); c:px(17, 18, INK)
  fl(c, R(c, 23, 10, 23, 15), "#b8661a"); fl(c, R(c, 21, 15, 22, 16), "#b8661a"); fl(c, R(c, 24, 10, 25, 11), "#b8661a")
  c:px(36, 22, "#f5cf6a"); c:px(43, 20, "#f08a24")
  finish(c, "campfire_story")
end

-- 5. kettle: a big gnome on a log with a tin mug, kettle steaming on a cross of sticks over a small fire
function S.kettle()
  seed = 9
  local c = new()
  day(c, 34, { cloud = 52, sky = { "#c8dce0", "#d8e6e0", "#e6ece0" } })
  part(c, c:ellipse(10, 33, 8, 5), "#4e8a3c", { shade = true })
  part(c, c:ellipse(62, 31, 7, 6), "#4e8a3c", { shade = true })
  part(c, c:rrect(2, 40, 30, 48, 3), "#8a5a35", { shade = true })
  c:fill(c:ellipse(4, 44, 2, 3), "#e8c48a"); c:px(4, 44, "#c08a52")
  fl(c, R(c, 12, 43, 19, 43), "#6b3b2a"); fl(c, R(c, 21, 46, 27, 46), "#6b3b2a")
  for _, p in ipairs({ { 42, 47 }, { 48, 48 }, { 54, 47 }, { 60, 48 } }) do part(c, c:ellipse(p[1], p[2], 3, 2), "#8b8f96", { shade = true }) end
  part(c, c:poly({ { 51, 38 }, { 55, 43 }, { 57, 47 }, { 45, 47 }, { 47, 43 } }), "#e0501f")
  c:fill(c:poly({ { 51, 41 }, { 53, 44 }, { 54, 47 }, { 48, 47 }, { 49, 44 } }), "#ffd86a")
  -- kettle: tin body, lid, knob, spout, wooden handle
  part(c, c:line({ { 41, 38 }, { 60, 38 } }, 2), "#6b3b2a", { noline = true })
  c:fill(c:line({ { 44, 29 }, { 47, 22 }, { 54, 22 }, { 57, 29 } }, 1), "#8a5a35")
  part(c, c:poly({ { 58, 31 }, { 64, 26 }, { 65, 28 }, { 58, 36 } }), "#aeb4bc")
  part(c, c:rrect(43, 29, 58, 38, 3), "#aeb4bc", { shade = true })
  part(c, R(c, 45, 26, 56, 29), "#8b929c")
  c:fill(R(c, 49, 24, 52, 25), "#6b3b2a")
  c:fill(R(c, 45, 32, 46, 35), "#e8ecf0")
  for i = 0, 3 do fl(c, c:ellipse(65 - (i % 2), 24 - i * 4, 2, 1), "#f4f8fa") end
  -- gnome seated, mug in both hands
  local _, G = gnome(c, 14, 39, { s = 1.25, d = 1, sit = true, eyes = "shut", arms = { arm({ 3, 8 }, { 8, 9 }, true, true) } })
  local mx, my = G.P(7, 8)
  part(c, R(c, mx + 1, my - 4, mx + 6, my + 2), "#aeb4bc")
  c:fill(R(c, mx + 7, my - 3, mx + 8, my), "#8b929c")
  fl(c, R(c, mx - 1, my - 2, mx + 1, my), "#f0c8a0"); fl(c, R(c, mx + 6, my - 2, mx + 8, my), "#f0c8a0")
  c:fill(R(c, mx + 2, my - 4, mx + 5, my - 4), "#6b3b2a")
  for i, y in ipairs({ my - 7, my - 10, my - 13 }) do fl(c, R(c, mx + 3 + (i % 2), y, mx + 4 + (i % 2), y + 1), "#f4f8fa") end
  finish(c, "kettle")
end

-- 6. frost_fair: snowy fair, stall with the prize jar, bunting, gnome in a scarf with a hot mug
function S.frost_fair()
  seed = 14
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#aecbe0", "#bfd6e6", "#d0e2ec", "#e0ecf0" }, { dir = "v" })
  c:fill(c:ellipse(60, 12, 4, 4), "#f5e6a8")
  c:fill(c:ellipse(16, 33, 28, 8), "#d3e0ea")
  c:fill(R(c, 0, 33, W - 1, H - 1), "#eef3f6")
  c:fill(R(c, 0, 46, W - 1, H - 1), "#e0e9f0")
  -- ice patch with glints
  c:fill(c:ellipse(11, 48, 12, 2), "#a8d4e8"); c:fill(R(c, 5, 48, 10, 48), "#d8f0f8")
  local function stall(x0, x1, ytop, c1, c2)
    part(c, R(c, x0 + 1, ytop + 4, x0 + 2, 43), "#8a5a35", { noline = true })
    part(c, R(c, x1 - 2, ytop + 4, x1 - 1, 43), "#8a5a35", { noline = true })
    part(c, R(c, x0, 38, x1, 43), "#b07a45")
    c:fill(R(c, x0 + 1, 38, x1 - 1, 38), "#d9a660")
    local n = 0
    for x = x0 - 1, x1 + 1, 3 do
      fl(c, R(c, x, ytop, x + 2, ytop + 5), (n % 2 == 0) and c1 or c2)
      n = n + 1
    end
    c:outline(R(c, x0 - 1, ytop, x1 + 1, ytop + 5))
  end
  stall(5, 24, 25, "#3f6fb0", "#f4eee0")
  stall(43, 67, 21, "#dd3a2a", "#f4eee0")
  -- prize jar with a golden star on the right stall
  part(c, R(c, 50, 31, 57, 37), "#b8e0e8")
  part(c, R(c, 51, 29, 56, 30), "#8a5a35")
  c:paint({ "..g..", ".ggg.", "ggggg", ".ggg.", ".g.g." }, 51, 31, { g = "#f5cf6a" })
  -- chestnuts in a pan and cider on the stall tops
  part(c, R(c, 60, 34, 65, 37), "#aeb4bc")
  for i = 0, 2 do c:fill(c:ellipse(61 + i * 2, 33, 1, 1), "#8a4f2a") end
  part(c, R(c, 9, 34, 12, 37), "#dd3a2a"); part(c, R(c, 15, 35, 18, 37), "#e8a317")
  -- bunting
  c:fill(c:line({ { 5, 9 }, { 22, 13 }, { 38, 12 }, { 54, 14 }, { 68, 10 } }, 1), "#5e3f28")
  local cols = { "#dd3a2a", "#f5cf6a", "#3f8fb0", "#7ab55c" }
  for i, f in ipairs({ { 9, 10 }, { 14, 11 }, { 20, 13 }, { 27, 13 }, { 33, 13 }, { 39, 12 }, { 46, 13 }, { 52, 14 }, { 58, 13 }, { 64, 11 } }) do
    fl(c, c:poly({ { f[1], f[2] + 1 }, { f[1] + 4, f[2] + 1 }, { f[1] + 2, f[2] + 5 } }), cols[(i - 1) % 4 + 1])
  end
  -- gnome with scarf, hot mug raised towards the prize
  local _, G = gnome(c, 34, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 7 }, { 7, 11 }, true, true) } })
  fl(c, R(c, 31, 38, 37, 38), "#3f8a5a"); fl(c, R(c, 31, 39, 37, 39), "#f4eee0"); fl(c, R(c, 37, 39, 38, 43), "#3f8a5a")
  local mx, my = G.P(7, 11)
  part(c, R(c, mx, my - 3, mx + 3, my + 1), "#c0442e"); fl(c, R(c, mx + 1, my - 3, mx + 2, my - 3), "#6b3b2a")
  fl(c, R(c, mx - 1, my, mx + 0, my + 1), "#f0c8a0")
  c:px(mx + 1, my - 6, "#f4f8fa"); c:px(mx + 2, my - 8, "#f4f8fa")
  seed = 40
  for i = 1, 14 do c:px(6 + floor(rand() * 62), 6 + floor(rand() * 36), "#fbfdfe") end
  finish(c, "frost_fair")
end

-- 7. bench_rest: gnome leaning back on a fresh pale-wood bench, hands behind head, in the shade of a tree
function S.bench_rest()
  seed = 33
  local c = new()
  day(c, 36, { cloud = 54, hill = "#5e8a44", hill2 = "#4e8a3c" })
  part(c, R(c, 6, 18, 11, 46), "#7a4a2a")
  fl(c, R(c, 8, 22, 8, 44), "#5e2f1e")
  part(c, c:ellipse(13, 13, 14, 9), "#3f8a42", { shade = true })
  part(c, c:ellipse(30, 10, 9, 6), "#4e9a48", { shade = true })
  c:fill(c:ellipse(10, 12, 2, 1), "#7ab55c"); c:fill(c:ellipse(28, 8, 2, 1), "#8fc462")
  for _, p in ipairs({ { 26, 44 }, { 32, 46 }, { 52, 45 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#9cc070") end
  -- new bench in pale wood: legs, tall backrest, seat
  part(c, R(c, 33, 40, 34, 47), "#e8c48a"); part(c, R(c, 55, 40, 56, 47), "#e8c48a")
  part(c, R(c, 28, 22, 31, 40), "#e8c48a")
  fl(c, R(c, 29, 22, 29, 40), "#f0d49e")
  c:px(30, 25, "#b07a45"); c:px(30, 33, "#b07a45")
  gnome(c, 38, 38, { d = 1, sit = true, s = 1.25, eyes = "open",
    arms = { arm({ -3, 8 }, { -6, 15 }, false), arm({ 3, 8 }, { 0, 17 }, true, true) } })
  part(c, R(c, 28, 38, 60, 40), "#f0d49e")
  fl(c, R(c, 29, 39, 59, 39), "#e8c48a")
  for _, x in ipairs({ 34, 46, 56 }) do c:px(x, 38, "#b07a45") end
  fl(c, R(c, 22, 20, 23, 21), "#c8802a"); c:px(24, 22, "#c8802a"); c:px(50, 24, "#c8802a"); c:px(51, 25, "#c8802a")
  for _, p in ipairs({ { 18, 47 }, { 20, 46 }, { 62, 47 }, { 64, 46 } }) do c:px(p[1], p[2], "#f4eee0"); c:px(p[1], p[2] - 1, "#e8a317") end
  finish(c, "bench_rest")
end

-- 8. trader_stall: gnome holds up a coin at a wooden stall of rope, planks, bricks and a sack
function S.trader_stall()
  seed = 18
  local c = new()
  day(c, 38, { cloud = 20, hill = "#5e8a44", hill2 = "#4e8a3c" })
  fl(c, R(c, 0, 40, W - 1, H - 1), "#c9a96e")
  fl(c, R(c, 0, 40, W - 1, 40), "#d9bc84")
  for _, p in ipairs({ { 6, 44 }, { 14, 47 }, { 30, 49 }, { 52, 48 }, { 66, 44 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2]), "#b8965c") end
  part(c, R(c, 25, 18, 27, 44), "#8a5a35", { noline = true })
  part(c, R(c, 65, 18, 67, 44), "#8a5a35", { noline = true })
  part(c, R(c, 28, 26, 64, 28), "#a8703e")
  -- rope coil and hammer on the shelf
  part(c, c:ellipse(34, 23, 4, 3), "#e0c88a"); c:fill(c:ellipse(34, 23, 2, 1), "#a8703e")
  part(c, R(c, 45, 21, 55, 22), "#8a5a35"); part(c, R(c, 53, 19, 58, 24), "#8b929c")
  -- striped awning with scalloped hem
  local n = 0
  for x = 24, 67, 4 do
    local col = (n % 2 == 0) and "#4e8a3c" or "#f4eee0"
    fl(c, R(c, x, 12, x + 3, 17), col); fl(c, R(c, x, 18, x + 3, 18), col); fl(c, R(c, x + 1, 19, x + 2, 19), col)
    n = n + 1
  end
  c:outline(R(c, 24, 12, 67, 19))
  -- counter
  part(c, R(c, 26, 33, 66, 44), "#b07a45")
  fl(c, R(c, 26, 33, 66, 34), "#d9a660")
  for _, x in ipairs({ 36, 46, 56 }) do fl(c, R(c, x, 36, x, 43), "#8a4f2a") end
  -- goods: rope coils, plank bundle, bricks
  part(c, c:ellipse(32, 30, 4, 3), "#e0c88a"); c:fill(c:ellipse(32, 30, 2, 1), "#a8703e")
  part(c, c:ellipse(40, 31, 3, 2), "#e0c88a"); c:fill(c:ellipse(40, 31, 1, 1), "#a8703e")
  part(c, R(c, 46, 28, 56, 29), "#d9a660"); part(c, R(c, 47, 30, 57, 31), "#e8c48a"); part(c, R(c, 46, 32, 56, 33), "#d9a660")
  part(c, R(c, 59, 30, 63, 32), "#c4623a"); part(c, R(c, 61, 27, 65, 29), "#c4623a"); part(c, R(c, 58, 32, 62, 33), "#c4623a")
  -- gnome customer with a coin held up
  gnome(c, 13, 47, { d = 1, eyes = "open", arms = { arm({ 4, 6 }, { 8, 10 }, true), arm({ -4, 5 }, { -5, 2 }, false) } })
  part(c, c:ellipse(23, 35, 2, 2), "#e8a317"); c:px(22, 34, "#fff1c8")
  c:px(26, 32, "#f5cf6a"); c:px(20, 33, "#f5cf6a")
  finish(c, "trader_stall")
end

-- 9. lantern_post: dusk lane, tall lantern post glowing, gnome strolling in its light
function S.lantern_post()
  seed = 27
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#3b2f66", "#4e3a78", "#7a4a88", "#b45a7c", "#e8825e", "#f0a868" }, { dir = "v" })
  c:fill(c:ellipse(10, 36, 28, 11), "#2f2a58"); c:fill(c:ellipse(60, 35, 30, 10), "#352c5c")
  for _, p in ipairs({ { 9, 8 }, { 24, 6 }, { 40, 9 }, { 55, 7 }, { 62, 16 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(R(c, 0, 34, W - 1, H - 1), "#3a5a42")
  c:fill(c:poly({ { 30, 34 }, { 52, 34 }, { 72, 54 }, { 8, 54 } }), "#8a6a56")
  c:fill(c:poly({ { 32, 36 }, { 50, 36 }, { 66, 52 }, { 14, 52 } }), "#9a7a62")
  for x = 6, 30, 6 do part(c, R(c, x, 28 + floor((x - 6) / 12), x + 1, 36), "#5e3f28", { noline = true }) end
  fl(c, R(c, 5, 30, 32, 30), "#5e3f28")
  c:fill(c:ellipse(46, 46, 20, 5):clip(c:poly({ { 30, 34 }, { 52, 34 }, { 72, 54 }, { 8, 54 } })), "#b88a60")
  c:fill(c:ellipse(46, 46, 12, 3), "#d8a870")
  -- the lantern post
  part(c, R(c, 46, 22, 47, 47), "#3d2a1c", { noline = true })
  part(c, R(c, 44, 46, 49, 48), "#3d2a1c")
  part(c, R(c, 43, 14, 50, 22), "#ffd86a", { shade = true, cres = 1 })
  c:fill(R(c, 45, 16, 48, 20), "#fff1c8")
  fl(c, R(c, 46, 14, 47, 22), "#8a5a2a")
  part(c, c:poly({ { 46, 9 }, { 52, 14 }, { 41, 14 } }), "#3d2a1c")
  part(c, R(c, 42, 22, 51, 23), "#3d2a1c")
  c:px(46, 8, "#f5cf6a")
  for _, p in ipairs({ { 40, 12 }, { 53, 12 }, { 39, 18 }, { 54, 18 }, { 46, 5 } }) do c:px(p[1], p[2], "#f8c070"); c:px(p[1] + 1, p[2], "#f8c070") end
  part(c, R(c, 62, 30, 62, 38), "#3d2a1c", { noline = true }); fl(c, R(c, 61, 28, 63, 30), "#ffd86a")
  fl(c, c:ellipse(17, 49, 5, 1), "#6a4e44")
  gnome(c, 26, 48, { d = 1, walk = 1, eyes = "open", arms = { arm({ -4, 7 }, { -5, 4 }, false), arm({ 4, 7 }, { 5, 4 }, true) } })
  for _, p in ipairs({ { 14, 26 }, { 58, 24 }, { 64, 40 }, { 34, 22 } }) do c:px(p[1], p[2], "#ffe08a") end
  finish(c, "lantern_post")
end

-- 10. wishing_well: gnome tossing a petal towards a stone well under a little roof, sparkles
function S.wishing_well()
  seed = 44
  local c = new()
  day(c, 35, { cloud = 54, hill = "#5e8a44", hill2 = "#4e8a3c" })
  for _, p in ipairs({ { 8, 42 }, { 12, 46 }, { 62, 44 }, { 66, 47 }, { 30, 47 }, { 56, 48 } }) do
    c:px(p[1], p[2], "#f4eee0"); c:px(p[1] - 1, p[2], "#e46a9b"); c:px(p[1] + 1, p[2], "#e46a9b"); c:px(p[1], p[2] - 1, "#e46a9b"); c:px(p[1], p[2] + 1, "#e46a9b")
  end
  part(c, c:rrect(40, 36, 63, 47, 2), "#a8aeb4", { shade = true })
  for _, y in ipairs({ 40, 44 }) do fl(c, R(c, 41, y, 62, y), "#7a8088") end
  for _, p in ipairs({ { 46, 37 }, { 52, 41 }, { 58, 37 }, { 44, 45 }, { 56, 45 } }) do fl(c, R(c, p[1], p[2], p[1], p[2] + 3), "#7a8088") end
  part(c, c:ellipse(51.5, 36, 12, 3), "#c9c5bc")
  c:fill(c:ellipse(51.5, 36, 9, 2), "#2f6290"); c:fill(R(c, 46, 36, 50, 36), "#8fcbd8")
  part(c, R(c, 42, 20, 43, 36), "#8a5a35", { noline = true }); part(c, R(c, 60, 20, 61, 36), "#8a5a35", { noline = true })
  part(c, R(c, 42, 22, 61, 23), "#a8703e")
  part(c, c:poly({ { 51, 10 }, { 66, 20 }, { 38, 20 } }), "#c0442e")
  c:fill(c:line({ { 41, 19 }, { 62, 19 } }, 1), "#8e2e1e")
  fl(c, R(c, 44, 15, 46, 15), "#dd5a42"); fl(c, R(c, 51, 12, 52, 12), "#dd5a42")
  fl(c, R(c, 51, 24, 51, 29), "#d9bc84")
  part(c, R(c, 49, 29, 53, 33), "#8a5a35"); fl(c, R(c, 49, 31, 53, 31), "#b07a45")
  gnome(c, 20, 46, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 8 }, { 8, 15 }, true) } })
  local function petal(x, y) part(c, c:ellipse(x, y, 1, 1), "#e46a9b", { noline = true }); c:px(x, y, "#f6b8cf") end
  petal(31, 27); petal(36, 23); petal(43, 25)
  c:px(33, 25, "#f6b8cf"); c:px(39, 22, "#f6b8cf")
  local function spark(x, y)
    c:px(x, y, "#fff1c8"); c:px(x - 1, y, "#f5cf6a"); c:px(x + 1, y, "#f5cf6a"); c:px(x, y - 1, "#f5cf6a"); c:px(x, y + 1, "#f5cf6a")
  end
  spark(48, 8); spark(60, 28); spark(36, 32); spark(66, 12)
  finish(c, "wishing_well")
end

-- 11. long_table: front-on hall feast, three gnomes behind a long table laden with food
function S.long_table()
  seed = 52
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#c9a96e")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 40), "#b8965c") end
  fl(c, R(c, 0, 8, W - 1, 8), "#8a5a35"); fl(c, R(c, 0, 5, W - 1, 7), "#a8703e")
  c:fill(R(c, 0, 41, W - 1, H - 1), "#8a5a35")
  for y = 44, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#6b3b2a") end
  part(c, c:rrect(28, 10, 44, 30, 3), "#a8703e")
  c:fill(c:rrect(30, 12, 42, 28, 2), "#a8d4e0"); c:fill(R(c, 30, 12, 42, 18), "#bcdde4")
  fl(c, R(c, 36, 12, 36, 28), "#a8703e"); fl(c, R(c, 30, 20, 42, 20), "#a8703e")
  c:fill(c:ellipse(40, 16, 2, 2), "#f5e6a8")
  part(c, R(c, 8, 9, 20, 24), "#c0442e")
  local tail = c:poly({ { 8, 24 }, { 14, 28 }, { 20, 24 } })
  c:fill(tail, "#c0442e"); c:outline(tail)
  fl(c, R(c, 10, 11, 18, 11), "#f5cf6a")
  c:paint({ "..g..", ".ggg.", "ggggg", ".ggg.", ".g.g." }, 12, 14, { g = "#f5cf6a" })
  fl(c, R(c, 55, 9, 55, 14), "#3d2a1c"); part(c, R(c, 52, 15, 58, 22), "#ffd86a"); fl(c, R(c, 54, 17, 56, 20), "#fff1c8")
  part(c, R(c, 52, 14, 58, 15), "#3d2a1c", { noline = true })
  gnome(c, 14, 42, { d = 1, upper = true, hat = "#e8a317", eyes = "open", arms = { arm({ 5, 7 }, { 7, 10 }, true) } })
  gnome(c, 58, 42, { d = -1, upper = true, hat = "#4f9a45", eyes = "open", arms = { arm({ 5, 7 }, { 7, 10 }, true) } })
  local _, G = gnome(c, 36, 43, { d = 1, upper = true, s = 1.25, eyes = "open", arms = { arm({ -5, 6 }, { -8, 13 }, true, true), arm({ 5, 6 }, { 8, 13 }, true, true) } })
  for _, sd in ipairs({ -1, 1 }) do
    local mx, my = G.P(sd * 8, 13)
    part(c, R(c, mx - 2, my - 3, mx + 1, my + 1), "#d9a660"); fl(c, R(c, mx - 1, my - 3, mx, my - 3), "#f4eee0")
    fl(c, R(c, mx - 1, my + 1, mx + 1, my + 2), "#f0c8a0")
  end
  part(c, R(c, 3, 38, 68, 41), "#b07a45")
  fl(c, R(c, 3, 38, 68, 38), "#d9a660")
  part(c, R(c, 5, 42, 67, 46), "#f4eee0")
  for x = 7, 66, 4 do fl(c, R(c, x, 46, x + 1, 46), "#dd3a2a") end
  fl(c, R(c, 5, 42, 67, 42), "#dd3a2a")
  part(c, R(c, 8, 47, 10, 52), "#8a5a35", { noline = true }); part(c, R(c, 61, 47, 63, 52), "#8a5a35", { noline = true })
  part(c, c:ellipse(8, 37, 3, 2), "#d9a660"); c:fill(c:ellipse(8, 36, 2, 1), "#e8c48a")
  part(c, c:ellipse(22, 37, 4, 2), "#f4eee0"); c:fill(c:ellipse(22, 36, 2, 1), "#c4623a")
  part(c, R(c, 27, 33, 30, 38), "#3f8fb0"); fl(c, R(c, 28, 32, 29, 32), "#3f8fb0")
  part(c, c:ellipse(51, 37, 4, 2), "#f4eee0"); c:fill(c:ellipse(51, 36, 2, 1), "#e0501f")
  part(c, c:ellipse(62, 37, 3, 2), "#e8a317"); c:fill(c:ellipse(62, 36, 1, 1), "#f5cf6a")
  part(c, R(c, 44, 33, 45, 37), "#f4eee0"); c:px(44, 31, "#ffd86a"); c:px(44, 32, "#e0501f"); c:px(45, 32, "#ffd86a")
  finish(c, "long_table")
end

local order = { "snow_soak", "egg_boil", "firewood", "campfire_story", "kettle", "frost_fair", "bench_rest", "trader_stall", "lantern_post", "wishing_well", "long_table" }
for _, s2 in ipairs(order) do
  if not only or only == s2 then seed = 7; S[s2]() end
end
