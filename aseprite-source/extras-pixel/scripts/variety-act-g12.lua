-- variety-act-g12.lua : Do-tab scenes for 15 rest-stop activities (inn / shrine) -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g12.lua   (params BEFORE --script)
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

---------------------------------------------------------------- shared bits
local function room(c, fy, wall, line, floor, fline, step)
  c:fill(R(c, 0, 0, W - 1, fy), wall)
  for x = 0, W - 1, step or 6 do fl(c, R(c, x, 0, x, fy), line) end
  c:fill(R(c, 0, fy + 1, W - 1, H - 1), floor)
  for y = fy + 4, H - 1, 4 do fl(c, R(c, 0, y, W - 1, y), fline) end
  fl(c, R(c, 0, fy - 1, W - 1, fy), fline)
end
local function dither(c, x0, y0, x1, y1, hex, ph)
  for y = y0, y1 do for x = x0, x1 do if (x + y) % 2 == (ph or 0) then c:px(x, y, hex) end end end
end
local function window(c, x0, y0, x1, y1, skyfn, frame)
  part(c, R(c, x0 - 1, y0 - 1, x1 + 1, y1 + 1), frame or "#a8703e")
  skyfn(x0, y0, x1, y1)
  local mx, my = floor((x0 + x1) / 2), floor((y0 + y1) / 2)
  fl(c, R(c, mx, y0, mx, y1), frame or "#a8703e"); fl(c, R(c, x0, my, x1, my), frame or "#a8703e")
end
local function note(c, x, y, col)
  fl(c, R(c, x, y, x + 1, y + 1), col); fl(c, R(c, x + 1, y - 4, x + 1, y), col); c:px(x + 2, y - 4, col); c:px(x + 3, y - 3, col)
end
local function steam(c, x, y, n, col)
  for i = 0, n do
    local sx = x + ((i % 2 == 0) and 0 or 1)
    fl(c, R(c, sx, y - i * 2, sx, y - i * 2 + 1), col or "#f4f8fa")
  end
end

---------------------------------------------------------------- 1. w2_make_beds
function S.w2_make_beds()
  seed = 61
  local c = new()
  room(c, 40, "#e2d0a6", "#d2bd90", "#a8703e", "#8a5a35")
  -- sunny window, left
  window(c, 8, 8, 21, 25, function(x0, y0, x1, y1)
    c:fill(R(c, x0, y0, x1, y1), "#bcdde4"); c:fill(c:ellipse(15, 20, 8, 4), "#7ea85a"); c:fill(c:ellipse(12, 12, 3, 1), "#f4eee0")
  end, "#b07a45")
  part(c, R(c, 5, 8, 7, 22), "#e46a9b", { noline = true }); part(c, R(c, 22, 8, 24, 22), "#e46a9b", { noline = true })
  -- linen stack on a stool (left)
  part(c, R(c, 6, 41, 15, 42), "#8a5a35"); fl(c, R(c, 7, 43, 7, 47), "#6b3b2a"); fl(c, R(c, 14, 43, 14, 47), "#6b3b2a")
  part(c, R(c, 6, 36, 15, 40), "#f4eee0"); fl(c, R(c, 6, 38, 15, 38), "#cfdcdc")
  part(c, R(c, 7, 32, 14, 35), "#a8d4e0"); fl(c, R(c, 7, 34, 14, 34), "#7ab4c8")
  fl(c, R(c, 10, 29, 10, 31), "#8a6ab0"); c:px(9, 30, "#b79ad8"); c:px(11, 29, "#b79ad8"); c:px(10, 28, "#b79ad8")
  -- the bed (right): headboard far right, footboard near the gnome
  part(c, R(c, 63, 22, 66, 46), "#6b3b2a"); part(c, R(c, 34, 33, 37, 46), "#6b3b2a")
  part(c, R(c, 35, 38, 64, 41), "#f4eee0")
  part(c, R(c, 37, 33, 63, 40), "#d8664a")
  for x = 39, 61, 4 do fl(c, R(c, x, 34, x + 1, 39), "#c0442e") end
  fl(c, R(c, 37, 33, 63, 33), "#e88a6a")
  part(c, c:ellipse(58, 31, 5, 3), "#f4eee0"); c:fill(c:ellipse(58, 31, 3, 1), "#e2dccd")
  part(c, R(c, 36, 41, 36, 41), "#f4eee0", { noline = true })
  -- the near corner: sheet flap pulled out and being tucked
  local g, G = gnome(c, 25, 47, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -6, 4 }, false), arm({ 4, 8 }, { 9, 11 }, true) } })
  part(c, c:poly({ { 33, 37 }, { 39, 32 }, { 40, 38 } }), "#e88a6a")
  finish(c, "w2_make_beds")
end

---------------------------------------------------------------- 2. w2_late_coach (night)
function S.w2_late_coach()
  seed = 62
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 36), { "#141a38", "#1c2448", "#242e58", "#2e3a68" }, { dir = "v" })
  for _, p in ipairs({ { 8, 7 }, { 22, 6 }, { 40, 8 }, { 52, 6 }, { 62, 12 }, { 48, 15 }, { 14, 14 }, { 34, 12 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(c:ellipse(60, 9, 3, 3), "#f5e6a8"); c:fill(c:ellipse(61, 8, 2, 2), "#1c2448")
  c:fill(c:ellipse(60, 38, 30, 7), "#1c2a3c")
  c:fill(R(c, 0, 37, W - 1, H - 1), "#2c4a3a")
  c:fill(c:poly({ { 6, 49 }, { 70, 49 }, { 68, 40 }, { 12, 40 } }), "#5a4a52")
  -- inn front, left: lit windows and an open glowing door
  part(c, R(c, 4, 18, 32, 41), "#a8927a")
  part(c, c:poly({ { 2, 19 }, { 18, 7 }, { 35, 19 } }), "#5a3040")
  for _, x in ipairs({ 8, 25 }) do part(c, R(c, x, 23, x + 4, 30), "#ffd86a"); fl(c, R(c, x + 2, 23, x + 2, 30), "#a8703e") end
  part(c, R(c, 15, 28, 21, 41), "#ffd86a"); c:fill(R(c, 16, 29, 20, 41), "#fff1c8")
  c:fill(c:poly({ { 15, 41 }, { 21, 41 }, { 30, 49 }, { 8, 49 } }), "#8a7a4a"); c:fill(c:poly({ { 16, 41 }, { 20, 41 }, { 25, 48 }, { 12, 48 } }), "#c9b05a")
  -- a coach, right: lantern, wheels, trunk on the roof
  part(c, R(c, 44, 24, 68, 38), "#7a3038")
  part(c, R(c, 47, 27, 53, 33), "#ffd86a"); fl(c, R(c, 50, 27, 50, 33), "#7a3038")
  part(c, R(c, 56, 27, 64, 38), "#5a2028")
  part(c, R(c, 46, 20, 62, 24), "#6b3b2a"); fl(c, R(c, 47, 21, 61, 21), "#a8703e")
  for _, wx in ipairs({ 49, 63 }) do
    part(c, c:ellipse(wx, 41, 5, 5), "#3d2a1c"); c:fill(c:ellipse(wx, 41, 3, 3), "#6a4a32"); c:fill(R(c, wx, 36, wx, 46), "#3d2a1c"); c:fill(R(c, wx - 5, 41, wx + 4, 41), "#3d2a1c")
  end
  -- a hooded weary traveller with a bag, by the coach step
  part(c, R(c, 56, 34, 61, 47), "#6a6e84"); part(c, c:ellipse(58, 33, 3, 4), "#6a6e84"); c:fill(R(c, 57, 32, 59, 34), "#f0c8a0"); c:px(57, 33, INK); c:px(59, 33, INK)
  part(c, R(c, 62, 42, 66, 47), "#8a5a35")
  -- the gnome lifts a lantern to light the way
  local _, G = gnome(c, 31, 47, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -6, 5 }, false), arm({ 4, 9 }, { 8, 15 }, true, true) } })
  local hx, hy = G.P(8, 15)
  fl(c, R(c, hx, hy - 5, hx, hy - 2), "#3d2a1c")
  part(c, R(c, hx - 2, hy - 2, hx + 2, hy + 3), "#ffd86a"); c:fill(R(c, hx - 1, hy - 1, hx + 1, hy + 2), "#fff1c8")
  fl(c, R(c, hx - 1, hy + 4, hx + 1, hy + 4), "#3d2a1c")
  finish(c, "w2_late_coach")
end

---------------------------------------------------------------- 3. w2_dry_cloaks (rain)
function S.w2_dry_cloaks()
  seed = 63
  local c = new()
  room(c, 41, "#7a6256", "#6c5448", "#5e4034", "#4a3228", 5)
  -- rainy window
  window(c, 8, 8, 19, 26, function(x0, y0, x1, y1)
    c:fill(R(c, x0, y0, x1, y1), "#6f879c"); c:fill(R(c, x0, y0, x1, y0 + 6), "#8aa0b2")
    for i = 0, 7 do local x = x0 + (i * 3) % 12; c:px(x, y0 + 2 + (i * 5) % 14, "#cfe2ee"); c:px(x, y0 + 3 + (i * 5) % 14, "#cfe2ee") end
  end, "#4a3228")
  -- hearth right, fire going
  part(c, R(c, 50, 14, 68, 42), "#8f929a")
  for y = 18, 40, 6 do fl(c, R(c, 51, y, 67, y), "#6c7078") end
  part(c, R(c, 47, 12, 68, 15), "#6b3b2a")
  part(c, R(c, 54, 26, 66, 42), "#2a1a10")
  c:fill(c:poly({ { 60, 29 }, { 64, 38 }, { 56, 38 } }), "#e0501f"); c:fill(c:poly({ { 60, 33 }, { 62, 38 }, { 58, 38 } }), "#ffd86a")
  c:fill(c:poly({ { 57, 31 }, { 58, 38 }, { 55, 38 } }), "#f08a24")
  fl(c, R(c, 54, 39, 66, 41), "#6b3b2a")
  -- clothes horse with three cloaks
  part(c, R(c, 29, 18, 30, 44), "#a8703e", { noline = true }); part(c, R(c, 45, 18, 46, 44), "#a8703e", { noline = true })
  for _, y in ipairs({ 19, 25 }) do fl(c, R(c, 29, y, 46, y), "#a8703e") end
  local cl = { { 31, "#4f9a45", 18 }, { 36, "#8a6ab0", 20 }, { 41, "#e8a317", 17 } }
  for _, k in ipairs(cl) do
    part(c, R(c, k[1], 20, k[1] + 3, 20 + k[3] - 3), k[2])
    c:fill(c:poly({ { k[1], 20 + k[3] - 3 }, { k[1] + 3, 20 + k[3] - 3 }, { k[1] + 1, 20 + k[3] } }), k[2])
    c:px(k[1] + 3, 20 + k[3] + 2, "#7ccfd4")
  end
  fl(c, R(c, 33, 41, 34, 41), "#7ccfd4"); fl(c, R(c, 39, 43, 39, 43), "#7ccfd4")
  steam(c, 33, 18, 4, "#d9e4ea"); steam(c, 39, 16, 5, "#d9e4ea"); steam(c, 44, 15, 4, "#d9e4ea")
  -- the gnome tugging a cloak round
  gnome(c, 21, 47, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -6, 4 }, false), arm({ 4, 8 }, { 8, 15 }, true) } })
  fl(c, R(c, 7, 46, 9, 46), "#6f879c"); fl(c, R(c, 12, 48, 15, 48), "#6f879c")
  finish(c, "w2_dry_cloaks")
end

---------------------------------------------------------------- 4. w2_apple_crumble
function S.w2_apple_crumble()
  seed = 64
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#ecdcb4")
  for y = 0, 38, 6 do for x = (y % 12 == 0) and 0 or 3, W - 1, 6 do fl(c, R(c, x, y, x + 2, y), "#dcc896") end end
  -- shelf with pans and a window
  window(c, 5, 7, 20, 22, function(x0, y0, x1, y1)
    c:fill(R(c, x0, y0, x1, y1), "#bcdde4"); c:fill(c:ellipse(12, 21, 9, 4), "#7ea85a"); c:fill(c:ellipse(8, 11, 3, 1), "#f4eee0")
  end, "#b07a45")
  fl(c, R(c, 28, 9, 66, 9), "#8a5a35"); fl(c, R(c, 28, 10, 66, 10), "#6b3b2a")
  for _, x in ipairs({ 32, 44, 56 }) do
    fl(c, R(c, x + 3, 9, x + 3, 10), "#3d2a1c")
    part(c, c:ellipse(x + 3, 16, 5, 5), "#9a9ea6", { shade = true }); c:fill(c:ellipse(x + 3, 16, 3, 3), "#7a8088")
    fl(c, R(c, x + 3, 11, x + 3, 12), "#3d2a1c")
  end
  fl(c, R(c, 31, 21, 31, 26), "#3d2a1c"); part(c, c:ellipse(31, 28, 2, 2), "#9a9ea6")
  -- table
  c:fill(R(c, 0, 39, W - 1, H - 1), "#a8703e")
  fl(c, R(c, 0, 39, W - 1, 40), "#d9a660"); for y = 44, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#8a5a35") end
  -- gnome behind, both hands in the bowl
  gnome(c, 26, 44, { d = 1, upper = true, s = 1.25, eyes = "open", arms = { arm({ -6, 7 }, { -3, 3 }, true), arm({ 6, 7 }, { 4, 3 }, true) } })
  part(c, c:ellipse(26, 44, 11, 5), "#f4eee0"); c:fill(c:ellipse(26, 44, 9, 3), "#e8c48a")
  for _, p in ipairs({ { 22, 44 }, { 26, 43 }, { 30, 45 }, { 24, 46 }, { 28, 44 } }) do c:px(p[1], p[2], "#c4923f") end
  fl(c, R(c, 18, 41, 34, 41), "#a8d4e0"); c:px(15, 45, "#f4eee0")
  -- butter + flour sack
  part(c, R(c, 4, 44, 9, 47), "#ffe08a"); fl(c, R(c, 4, 44, 9, 44), "#fff1c8")
  -- the crumble, hot and bubbling, with steam
  part(c, c:ellipse(53, 45, 12, 5), "#d9d4cc", { shade = true })
  c:fill(c:ellipse(53, 44, 10, 3), "#b8661a")
  c:fill(c:ellipse(53, 44, 8, 2), "#d9964a")
  for _, p in ipairs({ { 47, 43 }, { 51, 42 }, { 55, 43 }, { 59, 44 }, { 49, 45 }, { 53, 44 }, { 57, 45 } }) do c:px(p[1], p[2], "#f0c47a") end
  for _, p in ipairs({ { 44, 44 }, { 62, 44 }, { 48, 47 }, { 58, 47 } }) do c:px(p[1], p[2], "#c0442e"); c:px(p[1] + 1, p[2], "#c0442e") end
  steam(c, 50, 38, 5, "#f4f8fa"); steam(c, 56, 37, 6, "#f4f8fa")
  -- apples
  part(c, c:ellipse(37, 48, 3, 3), "#c0442e"); c:px(36, 47, "#e88a6a")
  part(c, c:ellipse(66, 48, 3, 3), "#7ea85a"); c:px(65, 47, "#b8d88a")
  finish(c, "w2_apple_crumble")
end

---------------------------------------------------------------- 5. w2_early_eggs (dawn)
function S.w2_early_eggs()
  seed = 65
  local c = new()
  room(c, 40, "#6e6a86", "#625e7a", "#5a4642", "#46342e", 6)
  -- dawn window: sun just up over the hills
  window(c, 7, 7, 28, 27, function(x0, y0, x1, y1)
    c:bands(R(c, x0, y0, x1, y1), { "#6a5a9a", "#a06a9a", "#e08a7a", "#f0b068", "#f8d890" }, { dir = "v" })
    c:fill(c:ellipse(18, 24, 5, 5):clip(R(c, x0, y0, x1, 24)), "#fff1c8")
    c:fill(c:ellipse(10, 27, 10, 4), "#4a5a7a"); c:fill(c:ellipse(26, 27, 9, 4), "#3e4e6e")
  end, "#a8703e")
  -- warm glow on the wall below the window
  -- rooster-shaped clock? keep it simple: hanging ladles
  fl(c, R(c, 40, 10, 66, 10), "#3d2a1c")
  for _, x in ipairs({ 44, 52, 60 }) do fl(c, R(c, x, 11, x, 17), "#9a9ea6"); part(c, c:ellipse(x, 19, 2, 2), "#9a9ea6") end
  -- iron stove with a pan
  part(c, R(c, 44, 30, 68, 47), "#2e2a32")
  fl(c, R(c, 45, 31, 67, 31), "#4a4652")
  part(c, R(c, 50, 36, 58, 43), "#1c1820"); c:fill(R(c, 51, 38, 57, 42), "#e0501f"); c:fill(R(c, 52, 40, 56, 42), "#ffd86a")
  part(c, R(c, 60, 12, 62, 30), "#2e2a32", { noline = true })
  part(c, c:ellipse(52, 30, 8, 2), "#4a4652")
  c:fill(c:ellipse(52, 29, 6, 1), "#f5cf6a"); c:fill(c:ellipse(51, 29, 3, 1), "#ffe89a"); c:px(54, 28, "#fff8d8")
  steam(c, 50, 26, 4, "#e8e4ec"); steam(c, 55, 25, 5, "#e8e4ec")
  fl(c, R(c, 38, 30, 43, 30), "#3d2a1c")
  -- gnome stirring with a wooden spoon
  local _, G = gnome(c, 30, 47, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -6, 4 }, false), arm({ 4, 8 }, { 8, 12 }, true) } })
  local hx, hy = G.P(8, 12)
  c:fill(c:line({ { hx + 1, hy }, { 49, 29 } }, 1), "#d9a660")
  c:fill(R(c, 48, 28, 49, 29), "#d9a660")
  -- basket of eggs on the floor
  part(c, c:ellipse(12, 46, 7, 3), "#b07a45", { shade = true })
  for _, x in ipairs({ 9, 12, 15 }) do part(c, c:ellipse(x, 44, 2, 2), "#f4eee0", { noline = true }); c:px(x - 1, 43, "#fff8e8") end
  for _, x in ipairs({ 10, 13 }) do c:fill(c:ellipse(x, 46, 1, 1), "#b07a45") end
  finish(c, "w2_early_eggs")
end

---------------------------------------------------------------- 6. w2_air_mattresses
function S.w2_air_mattresses()
  seed = 66
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 12), { "#a8d4e0", "#bcdde4" }, { dir = "v" })
  -- the inn's back wall, shuttered window
  c:fill(R(c, 0, 5, W - 1, 36), "#e8dcc0")
  for y = 8, 34, 6 do fl(c, R(c, 0, y, W - 1, y), "#d8c8a4") end
  part(c, R(c, 0, 4, W - 1, 6), "#a8523a", { noline = true })
  part(c, R(c, 8, 12, 17, 27), "#a8d4e0"); fl(c, R(c, 12, 12, 12, 27), "#a8703e"); fl(c, R(c, 8, 19, 17, 19), "#a8703e")
  part(c, R(c, 4, 12, 7, 27), "#4f9a45"); part(c, R(c, 18, 12, 21, 27), "#4f9a45")
  fl(c, R(c, 5, 15, 6, 24), "#3f7a38"); fl(c, R(c, 19, 15, 20, 24), "#3f7a38")
  c:fill(R(c, 0, 37, W - 1, H - 1), "#a89a76")
  fl(c, R(c, 0, 37, W - 1, 37), "#c4b48a")
  for _, p in ipairs({ { 6, 42 }, { 18, 46 }, { 28, 41 }, { 40, 48 }, { 52, 43 }, { 64, 47 }, { 34, 45 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#8a7a58") end
  -- airing pole with two striped mattresses
  part(c, R(c, 28, 17, 29, 40), "#8a5a35", { noline = true }); part(c, R(c, 67, 17, 68, 40), "#8a5a35", { noline = true })
  part(c, R(c, 27, 16, 69, 18), "#a8703e")
  local function mat(x0, x1, y1, a, b)
    part(c, R(c, x0, 18, x1, y1), a)
    for x = x0 + 1, x1, 4 do fl(c, R(c, x, 19, x + 1, y1 - 1), b) end
    fl(c, R(c, x0, y1 - 1, x1, y1 - 1), b)
    fl(c, R(c, x0 + 1, 19, x1 - 1, 19), "#f4eee0")
  end
  mat(31, 47, 37, "#f4eee0", "#4a78b8")
  mat(50, 65, 33, "#f4eee0", "#d8664a")
  -- the gnome, big carpet-beater swung high
  local _, G = gnome(c, 20, 47, { d = 1, s = 1.2, eyes = "open", arms = { arm({ -4, 7 }, { -6, 4 }, false), arm({ 4, 9 }, { 8, 19 }, true) } })
  local hx, hy = G.P(8, 19)
  c:fill(c:line({ { hx + 1, hy }, { hx + 5, hy - 4 } }, 1), "#8a5a35")
  part(c, c:ellipse(hx + 8, hy - 8, 4, 4), "#d9a660"); c:fill(c:ellipse(hx + 8, hy - 8, 2, 2), "#e8dcc0")
  fl(c, R(c, hx + 6, hy - 8, hx + 10, hy - 8), "#d9a660"); fl(c, R(c, hx + 8, hy - 10, hx + 8, hy - 6), "#d9a660")
  -- dust and drifting feathers
  for _, p in ipairs({ { 33, 28 }, { 41, 26 }, { 36, 33 }, { 52, 25 }, { 59, 30 }, { 45, 13 }, { 55, 12 }, { 62, 10 } }) do
    fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#fbfdfe"); c:px(p[1] + 2, p[2] + 1, "#cfe2ee")
  end
  for _, p in ipairs({ { 30, 24 }, { 49, 35 }, { 57, 21 } }) do c:px(p[1], p[2], "#e8dcc0"); c:px(p[1] + 1, p[2] - 1, "#e8dcc0") end
  finish(c, "w2_air_mattresses")
end

---------------------------------------------------------------- 7. w2_creaky_stair
function S.w2_creaky_stair()
  seed = 67
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 44), "#5e4636")
  for x = 0, W - 1, 5 do fl(c, R(c, x, 0, x, 44), "#4e3a2c") end
  fl(c, R(c, 0, 30, W - 1, 30), "#6e5444")
  c:fill(R(c, 0, 45, W - 1, H - 1), "#3a2a20")
  for x = 0, W - 1, 9 do fl(c, R(c, x, 45, x, H - 1), "#2e2018") end
  -- wall lamp glow
  c:fill(c:ellipse(52, 14, 9, 8), "#6e5444"); c:fill(c:ellipse(52, 14, 5, 5), "#7e6250")
  part(c, R(c, 50, 15, 54, 19), "#ffd86a"); fl(c, R(c, 51, 16, 53, 18), "#fff1c8")
  part(c, R(c, 49, 12, 55, 14), "#3d2a1c")
  -- staircase: tread rise 5, width 11, 5 steps climbing right
  for k = 0, 4 do
    local x0 = 14 + k * 11
    local top = 46 - k * 5
    part(c, R(c, x0, top, 68, 49), "#5e3a22")
    fl(c, R(c, x0, top, x0 + 10, top + 1), "#d9a660")
    fl(c, R(c, x0, top + 2, x0 + 10, top + 2), "#a06a3a")
  end
  -- the loud step has a fresh pale plank and a row of nails
  fl(c, R(c, 36, 36, 46, 37), "#f0d8a0")
  for _, x in ipairs({ 38, 42, 45 }) do c:px(x, 36, "#7a8088") end
  -- banister rail climbing alongside
  for k = 0, 4 do
    local bx = 19 + k * 11
    fl(c, R(c, bx, 46 - k * 5 - 17, bx, 46 - k * 5 - 1), "#3d2a1c")
  end
  c:fill(c:line({ { 19, 29 }, { 63, 9 } }, 1), "#6b3b2a")
  -- the gnome crouched on the second step, hammer coming down on a nail
  local _, G = gnome(c, 31, 41, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -6, 4 }, false), arm({ 4, 8 }, { 8, 6 }, true) } })
  local hx, hy = G.P(8, 6)
  part(c, R(c, hx - 1, hy - 5, hx + 3, hy - 3), "#7a8088")
  fl(c, R(c, hx, hy - 2, hx + 1, hy), "#8a5a35")
  for _, p in ipairs({ { hx + 5, hy + 1 }, { hx + 6, hy - 3 }, { hx + 4, hy - 7 } }) do c:px(p[1], p[2], "#ffd86a") end
  fl(c, R(c, hx + 1, hy + 1, hx + 1, hy + 2), "#2a1a10")
  -- creak rings
  fl(c, R(c, hx + 7, hy - 1, hx + 8, hy - 1), "#f5cf6a"); fl(c, R(c, hx + 7, hy + 1, hx + 8, hy + 1), "#f5cf6a")
  -- toolbox on the floor
  part(c, R(c, 4, 42, 13, 47), "#c0442e"); fl(c, R(c, 4, 44, 13, 44), "#8e2e1e"); fl(c, R(c, 7, 40, 10, 41), "#7a8088")
  for _, x in ipairs({ 16, 18, 20 }) do fl(c, R(c, x, 47, x, 47), "#c9c5bc") end
  finish(c, "w2_creaky_stair")
end

---------------------------------------------------------------- 8. w2_song_off (dusk / night)
function S.w2_song_off()
  seed = 68
  local c = new()
  room(c, 41, "#4e3a56", "#44324c", "#6e4630", "#583824", 6)
  window(c, 7, 8, 20, 24, function(x0, y0, x1, y1)
    c:bands(R(c, x0, y0, x1, y1), { "#3b2f66", "#7a4a88", "#b45a7c", "#e8825e" }, { dir = "v" })
    c:fill(c:ellipse(12, 24, 9, 3), "#2a2450"); c:px(10, 11, "#f4eee0"); c:px(17, 14, "#f4eee0")
  end, "#6b3b2a")
  -- big hearth, centre right
  part(c, R(c, 36, 16, 60, 43), "#8f929a")
  for y = 20, 40, 6 do fl(c, R(c, 37, y, 59, y), "#6c7078") end
  part(c, R(c, 33, 13, 63, 16), "#6b3b2a")
  part(c, R(c, 40, 24, 56, 43), "#2a1a10")
  c:fill(c:poly({ { 48, 27 }, { 53, 40 }, { 43, 40 } }), "#e0501f"); c:fill(c:poly({ { 48, 32 }, { 51, 40 }, { 45, 40 } }), "#f08a24")
  c:fill(c:ellipse(48, 38, 2, 3), "#ffd86a")
  fl(c, R(c, 40, 40, 56, 42), "#6b3b2a")
  -- firelit rug
  c:fill(c:ellipse(36, 48, 30, 3), "#a8523a"); c:fill(c:ellipse(36, 48, 22, 2), "#c0442e")
  -- armchair on the right with the storyteller (yellow hat) and a mug
  part(c, R(c, 59, 31, 68, 46), "#7a3a3a"); part(c, R(c, 59, 40, 66, 46), "#a8523a")
  gnome(c, 63, 43, { d = -1, sit = true, hat = "#e8a317", eyes = "open", arms = { arm({ -4, 6 }, { -7, 7 }, true) } })
  -- the fiddler, mid-tune
  local _, G = gnome(c, 24, 47, { d = 1, eyes = "happy", arms = { arm({ -4, 9 }, { -8, 6 }, false, true), arm({ 4, 9 }, { 9, 12 }, true, true) } })
  local fx, fy = G.P(4, 10)
  part(c, c:ellipse(fx + 2, fy + 1, 4, 3), "#c0742e", { noline = true }); c:fill(c:ellipse(fx + 2, fy + 1, 2, 1), "#8a4a1a")
  part(c, c:ellipse(fx + 2, fy + 1, 4, 3), "#c0742e")
  c:fill(c:ellipse(fx + 2, fy + 1, 2, 1), "#8a4a1a")
  fl(c, R(c, fx + 5, fy - 3, fx + 6, fy + 1), "#8a5a35")
  local bx, by = G.P(9, 12)
  c:fill(c:line({ { bx - 7, by + 5 }, { bx + 3, by - 3 } }, 1), "#f4eee0")
  fl(c, R(c, bx - 1, by - 1, bx + 1, by + 1), "#f0c8a0")
  -- notes
  note(c, 30, 14, "#f5cf6a"); note(c, 36, 8, "#f4eee0"); note(c, 24, 11, "#f08a24"); note(c, 18, 28, "#f5cf6a")
  finish(c, "w2_song_off")
end

---------------------------------------------------------------- 9. w2_hat_pegs
function S.w2_hat_pegs()
  seed = 69
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#6f9a78")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 0, x + 3, 40), "#628a6c") end
  c:fill(R(c, 0, 41, W - 1, H - 1), "#8a5a35")
  for y = 45, 53, 4 do fl(c, R(c, 0, y, W - 1, y), "#6b3b2a") end
  fl(c, R(c, 0, 38, W - 1, 40), "#a8703e")
  part(c, R(c, 4, 19, 68, 22), "#7a4a2e"); fl(c, R(c, 5, 19, 67, 19), "#a8703e")
  local pegs = { 9, 18, 27, 45, 54, 63 }
  for _, x in ipairs(pegs) do part(c, R(c, x, 22, x + 1, 25), "#6b3b2a") end
  local function hat(x, kind)
    local y = 25
    if kind == "boater" then
      part(c, c:ellipse(x, y + 4, 5, 1), "#e8c48a"); part(c, R(c, x - 2, y, x + 2, y + 3), "#e8c48a"); fl(c, R(c, x - 2, y + 2, x + 2, y + 2), "#c0442e")
    elseif kind == "bobble" then
      part(c, c:ellipse(x, y + 3, 3, 4), "#4a78b8"); fl(c, R(c, x - 3, y + 5, x + 3, y + 6), "#3a5a98"); part(c, c:ellipse(x, y + 8, 1, 1), "#f4eee0")
      c:px(x, y + 8, "#f4eee0")
    elseif kind == "cone" then
      part(c, c:poly({ { x, y }, { x + 4, y + 9 }, { x - 3, y + 9 } }), "#c0442e"); fl(c, R(c, x - 3, y + 9, x + 4, y + 9), "#8e2e1e")
    elseif kind == "sou" then
      part(c, R(c, x - 3, y + 1, x + 3, y + 5), "#e8b830"); part(c, R(c, x - 2, y + 5, x + 4, y + 9), "#e8b830"); fl(c, R(c, x - 3, y + 2, x + 3, y + 2), "#c0881a")
    elseif kind == "bonnet" then
      part(c, c:ellipse(x, y + 4, 4, 5), "#f4b8cf"); c:fill(c:ellipse(x, y + 5, 2, 3), "#f4eee0"); fl(c, R(c, x - 1, y + 9, x + 1, y + 11), "#e46a9b")
    elseif kind == "beret" then
      part(c, c:ellipse(x, y + 2, 4, 2), "#8e2e50"); c:px(x, y, "#8e2e50"); fl(c, R(c, x, y - 1, x, y - 1), "#3d2a1c")
    elseif kind == "pot" then
      part(c, R(c, x - 3, y + 1, x + 3, y + 3), "#c4623a"); part(c, R(c, x - 2, y + 4, x + 2, y + 7), "#c4623a")
      fl(c, R(c, x - 2, y - 1, x - 1, y), "#4f9a45"); fl(c, R(c, x + 1, y - 2, x + 2, y), "#e46a9b"); c:px(x, y, "#4f9a45")
    end
  end
  hat(9, "bobble"); hat(18, "boater"); hat(27, "sou"); hat(45, "cone"); hat(54, "bonnet"); hat(63, "beret")
  -- the free peg, a hat in hand
  local _, G = gnome(c, 36, 47, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -7, 5 }, false), arm({ 4, 10 }, { 4, 22 }, true, true) } })
  local hx, hy = G.P(4, 22)
  hat(hx + 1, "pot")
  fl(c, R(c, hx - 1, hy - 1, hx + 2, hy + 1), "#f0c8a0")
  part(c, R(c, 35, 22, 36, 25), "#6b3b2a")
  -- boots below on a mat
  part(c, R(c, 56, 44, 66, 47), "#a8523a"); part(c, R(c, 8, 44, 15, 47), "#a8523a")
  part(c, R(c, 58, 40, 60, 45), "#5a3a22"); part(c, R(c, 62, 40, 64, 45), "#5a3a22")
  finish(c, "w2_hat_pegs")
end

---------------------------------------------------------------- 10. w2_room_keys
function S.w2_room_keys()
  seed = 70
  local c = new()
  room(c, 41, "#c9a96e", "#b8965c", "#7a4a2e", "#5e3a22", 6)
  -- the key board, left, a tangle of keys with no labels
  part(c, R(c, 6, 10, 30, 34), "#6b3b2a")
  c:fill(R(c, 8, 12, 28, 32), "#8a5a35")
  local kc = { "#f5cf6a", "#c9c5bc", "#e8a317", "#f5cf6a", "#c9c5bc", "#e8a317" }
  local i = 0
  for r = 0, 1 do for q = 0, 2 do
    i = i + 1
    local x, y = 11 + q * 7, 14 + r * 9
    fl(c, R(c, x, y, x, y + 1), "#3d2a1c")
    fl(c, R(c, x - 1, y + 1, x + 1, y + 5), kc[i])
    c:px(x, y + 2, "#3d2a1c"); fl(c, R(c, x + 1, y + 5, x + 2, y + 5), kc[i])
  end end
  -- one hook left empty
  -- door, right, arched, with a keyhole plate
  part(c, R(c, 44, 11, 66, 46), "#7a4a2e")
  part(c, c:ellipse(55, 12, 11, 4), "#7a4a2e")
  c:fill(R(c, 46, 14, 64, 45), "#9a6a3e")
  for _, x in ipairs({ 50, 55, 60 }) do fl(c, R(c, x, 14, x, 45), "#7a4a2e") end
  part(c, R(c, 58, 28, 62, 33), "#e8a317"); c:px(60, 29, "#2a1a10"); c:px(60, 30, "#2a1a10")
  part(c, R(c, 53, 19, 57, 22), "#f5cf6a")
  -- the gnome tries a big key
  local _, G = gnome(c, 42, 47, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -7, 9 }, false), arm({ 4, 8 }, { 8, 12 }, true, true) } })
  local hx, hy = G.P(8, 12)
  fl(c, R(c, hx - 1, hy - 1, hx + 2, hy + 1), "#f0c8a0")
  fl(c, R(c, hx + 2, hy, hx + 9, hy), "#f5cf6a"); fl(c, R(c, hx + 7, hy, hx + 8, hy + 2), "#f5cf6a"); fl(c, R(c, hx + 9, hy - 1, hx + 9, hy + 1), "#f5cf6a")
  -- bunch of keys on his belt
  for _, p in ipairs({ { 34, 36 }, { 36, 37 } }) do c:px(p[1], p[2], "#f5cf6a"); c:px(p[1], p[2] + 1, "#c9c5bc") end
  -- a pair of slippers at the door's foot
  part(c, R(c, 47, 44, 51, 47), "#d8a0c0"); part(c, R(c, 52, 44, 56, 47), "#d8a0c0")
  finish(c, "w2_room_keys")
end

---------------------------------------------------------------- 11. w2_hearth_bellows (frost / snow)
function S.w2_hearth_bellows()
  seed = 71
  local c = new()
  room(c, 42, "#8a7a82", "#7a6a74", "#5e4034", "#4a3228", 6)
  -- frosty window with snow
  window(c, 7, 8, 20, 27, function(x0, y0, x1, y1)
    c:fill(R(c, x0, y0, x1, y1), "#8aa0b8"); c:fill(R(c, x0, y1 - 3, x1, y1), "#f4f8fa")
    for _, p in ipairs({ { 9, 11 }, { 14, 14 }, { 18, 10 }, { 11, 19 }, { 17, 21 }, { 13, 24 } }) do c:px(p[1], p[2], "#fbfdfe") end
    fl(c, R(c, x0, y0, x0 + 1, y0), "#f4f8fa"); fl(c, R(c, x1 - 1, y0, x1, y0), "#f4f8fa"); fl(c, R(c, x0, y0 + 1, x0, y0 + 2), "#f4f8fa")
  end, "#4a3228")
  fl(c, R(c, 5, 29, 22, 29), "#f4f8fa")
  -- tall stone hearth, roaring
  part(c, R(c, 44, 8, 68, 43), "#8f929a")
  for y = 13, 41, 6 do fl(c, R(c, 45, y, 67, y), "#6c7078") end
  part(c, R(c, 41, 6, 68, 10), "#6b3b2a")
  part(c, R(c, 47, 20, 65, 43), "#2a1a10")
  c:fill(c:poly({ { 56, 14 }, { 62, 27 }, { 64, 41 }, { 48, 41 }, { 50, 27 } }), "#e0501f")
  c:fill(c:poly({ { 56, 21 }, { 60, 31 }, { 61, 41 }, { 51, 41 }, { 52, 31 } }), "#f08a24")
  c:fill(c:poly({ { 56, 28 }, { 58, 35 }, { 59, 41 }, { 53, 41 }, { 54, 35 } }), "#ffd86a")
  part(c, c:line({ { 48, 42 }, { 64, 42 } }, 2), "#6b3b2a")
  for _, p in ipairs({ { 50, 18 }, { 63, 16 }, { 60, 11 }, { 53, 12 }, { 46, 24 }, { 66, 22 } }) do c:px(p[1], p[2], "#ffd86a"); c:px(p[1] + 1, p[2] + 1, "#f08a24") end
  -- the bellows, pumped by the top handle, nozzle into the fire
  local _, G = gnome(c, 19, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 9 }, { 8, 15 }, true, true) } })
  part(c, c:poly({ { 28, 35 }, { 40, 39 }, { 40, 42 }, { 28, 43 } }), "#8a4a2a")
  for x = 31, 39, 3 do fl(c, R(c, x, 36 + floor((x - 28) / 3), x, 42), "#5e2f1e") end
  part(c, c:line({ { 27, 33 }, { 41, 38 } }, 2), "#d9a660")
  part(c, c:line({ { 27, 44 }, { 41, 41 } }, 2), "#d9a660")
  part(c, R(c, 40, 39, 46, 40), "#3d2a1c")
  fl(c, R(c, 43, 39, 46, 39), "#7a8088")
  local hx, hy = G.P(8, 15)
  part(c, R(c, hx - 1, hy, hx + 2, hy + 2), "#d9a660"); fl(c, R(c, hx - 1, hy - 1, hx + 1, hy), "#f0c8a0")
  fl(c, R(c, 27, 45, 28, 45), "#d9a660")
  fl(c, R(c, 47, 37, 48, 37), "#f4f8fa"); fl(c, R(c, 47, 41, 48, 41), "#f4f8fa")
  -- a stool with a mug, left
  part(c, R(c, 6, 41, 12, 42), "#8a5a35"); fl(c, R(c, 7, 43, 7, 47), "#6b3b2a"); fl(c, R(c, 11, 43, 11, 47), "#6b3b2a")
  part(c, R(c, 8, 37, 10, 40), "#f4eee0"); steam(c, 9, 36, 2, "#e8e4ec")
  finish(c, "w2_hearth_bellows")
end

---------------------------------------------------------------- 12. w2_guestbook
function S.w2_guestbook()
  seed = 72
  local c = new()
  room(c, 41, "#3e2c34", "#34242c", "#4a3020", "#3a2418", 7)
  -- shelf of books, left top
  fl(c, R(c, 5, 15, 30, 15), "#6b3b2a"); fl(c, R(c, 5, 16, 30, 16), "#4a2a1a")
  local bk = { "#a8523a", "#4a78b8", "#4f9a45", "#e8a317", "#8a6ab0", "#c0442e", "#4a78b8" }
  for i, col in ipairs(bk) do part(c, R(c, 5 + (i - 1) * 3 + 1, 8 + (i % 3), 5 + (i - 1) * 3 + 3, 14), col, { noline = true }); fl(c, R(c, 5 + (i - 1) * 3 + 2, 10 + (i % 3), 5 + (i - 1) * 3 + 2, 11 + (i % 3)), "#f5cf6a") end
  -- the big lectern with a giant open guestbook
  part(c, R(c, 36, 34, 66, 38), "#8a5a35"); fl(c, R(c, 36, 34, 66, 34), "#a8703e")
  part(c, R(c, 38, 39, 41, 47), "#6b3b2a"); part(c, R(c, 61, 39, 64, 47), "#6b3b2a")
  part(c, c:poly({ { 36, 33 }, { 40, 21 }, { 51, 23 }, { 51, 34 } }), "#f4eee0")
  part(c, c:poly({ { 51, 34 }, { 51, 23 }, { 62, 21 }, { 66, 33 } }), "#e8dcc0")
  fl(c, R(c, 51, 23, 51, 34), "#a8703e")
  for k = 0, 4 do
    fl(c, R(c, 41 + (k % 2), 25 + k * 2 - floor(k / 2), 49, 25 + k * 2 - floor(k / 2)), "#8a7a6a")
  end
  for k = 0, 2 do fl(c, R(c, 54, 26 + k * 2, 61 - k, 26 + k * 2), "#8a7a6a") end
  -- tiny inky hedgehog tracks across the right page
  for _, p in ipairs({ { 55, 32 }, { 57, 31 }, { 59, 32 }, { 61, 31 }, { 63, 32 } }) do c:px(p[1], p[2], "#2a1a10"); c:px(p[1], p[2] + 1, "#2a1a10") end
  -- candle and ink pot with a quill
  part(c, R(c, 63, 26, 65, 33), "#f4eee0"); fl(c, R(c, 64, 22, 64, 25), "#f08a24"); c:px(64, 21, "#ffd86a"); c:px(64, 23, "#ffd86a")
  part(c, R(c, 37, 29, 39, 33), "#2a2a4a"); fl(c, R(c, 38, 24, 38, 29), "#f4eee0"); c:px(37, 25, "#f4eee0"); c:px(39, 24, "#f4eee0")
  -- the gnome leans in and reads aloud
  local _, G = gnome(c, 24, 47, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -6, 4 }, false), arm({ 4, 9 }, { 9, 14 }, true) } })
  -- a few glowing motes in the candle light
  for _, p in ipairs({ { 60, 17 }, { 68, 20 }, { 56, 14 } }) do c:px(p[1], p[2], "#f5cf6a") end
  -- little moon window
  window(c, 8, 20, 17, 30, function(x0, y0, x1, y1)
    c:fill(R(c, x0, y0, x1, y1), "#1c2448"); c:px(10, 22, "#f4eee0"); c:fill(c:ellipse(15, 24, 2, 2), "#f5e6a8")
  end, "#6b3b2a")
  finish(c, "w2_guestbook")
end

---------------------------------------------------------------- 13. w3_shrine_cat
function S.w3_shrine_cat()
  seed = 73
  local c = new()
  day(c, 38, { sky = { "#b8dcd8", "#cfe8de", "#e0f0e0" }, hill = "#4e7a3a", hill2 = "#3f6a32", cloud = 10 })
  c:fill(R(c, 0, 38, W - 1, H - 1), "#a89a76")
  fl(c, R(c, 0, 38, W - 1, 38), "#c4b48a")
  for _, p in ipairs({ { 6, 44 }, { 18, 48 }, { 28, 42 }, { 8, 49 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#8a7a58") end
  -- the cedar beside the shrine
  part(c, R(c, 4, 22, 8, 40), "#6b4a2e", { noline = true })
  for _, t in ipairs({ { 6, 12, 9 }, { 6, 19, 12 }, { 6, 27, 14 } }) do part(c, c:poly({ { t[1], t[2] - 6 }, { t[1] + t[3] - 3, t[2] + 4 }, { t[1] - t[3] + 3, t[2] + 4 } }), "#2f5a2a") end
  -- the shrine hall
  part(c, R(c, 36, 36, 68, 39), "#9a9ea6"); part(c, R(c, 39, 39, 65, 41), "#8b8f96")
  part(c, R(c, 38, 25, 66, 36), "#f0e4cc")
  for _, x in ipairs({ 38, 49, 59, 65 }) do part(c, R(c, x, 25, x + 1, 36), "#a8321e", { noline = true }) end
  part(c, R(c, 51, 28, 58, 36), "#4a2a1a")
  fl(c, R(c, 54, 29, 55, 36), "#6b3b2a")
  part(c, R(c, 52, 24, 57, 25), "#a8321e")
  fl(c, R(c, 54, 26, 54, 31), "#f4eee0"); part(c, c:ellipse(54, 32, 1, 1), "#e8a317")
  -- big mossy roof
  part(c, c:poly({ { 33, 25 }, { 40, 19 }, { 48, 15 }, { 56, 15 }, { 64, 19 }, { 71, 25 } }), "#6a7a8a")
  c:fill(c:poly({ { 37, 22 }, { 42, 19 }, { 46, 18 }, { 40, 24 } }), "#5e8a44")
  c:fill(c:poly({ { 57, 17 }, { 62, 19 }, { 66, 23 }, { 59, 21 } }), "#5e8a44")
  c:fill(R(c, 50, 17, 52, 18), "#7ea85a")
  fl(c, R(c, 44, 16, 60, 16), "#8a9aaa")
  -- the cat on the ridge, pretending it meant to
  part(c, c:ellipse(52, 13, 4, 3), "#e8913a")
  part(c, c:ellipse(52, 9, 3, 3), "#e8913a")
  c:px(49, 6, "#e8913a"); c:px(50, 6, "#e8913a"); c:px(54, 6, "#e8913a"); c:px(55, 6, "#e8913a"); c:px(50, 7, "#c0442e"); c:px(54, 7, "#c0442e")
  c:px(51, 9, "#2a1a10"); c:px(53, 9, "#2a1a10"); c:px(52, 10, "#e08a7a")
  fl(c, R(c, 51, 12, 51, 14), "#b8661a"); fl(c, R(c, 53, 12, 53, 14), "#b8661a")
  fl(c, R(c, 56, 14, 60, 14), "#e8913a"); fl(c, R(c, 60, 12, 60, 14), "#e8913a"); fl(c, R(c, 60, 11, 61, 11), "#f4eee0")
  -- the gnome holds up a saucer, treat tin in the other hand
  local _, G = gnome(c, 24, 47, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -7, 9 }, false), arm({ 4, 10 }, { 9, 24 }, true) } })
  local hx, hy = G.P(9, 24)
  part(c, c:ellipse(hx + 1, hy - 1, 5, 1), "#f4eee0"); fl(c, R(c, hx - 1, hy - 3, hx + 2, hy - 2), "#8ab8c8"); c:px(hx + 3, hy - 3, "#8ab8c8")
  local tx, ty = G.P(-7, 9)
  part(c, R(c, tx - 3, ty - 1, tx, ty + 3), "#c9c5bc"); fl(c, R(c, tx - 3, ty, tx, ty), "#7a8088")
  finish(c, "w3_shrine_cat")
end

---------------------------------------------------------------- 14. w3_snowy_lanterns (winter)
function S.w3_snowy_lanterns()
  seed = 74
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#9db1c6", "#adbfd1", "#bccbda", "#cdd9e4" }, { dir = "v" })
  c:fill(c:ellipse(16, 36, 30, 10), "#d3deea"); c:fill(c:ellipse(60, 35, 28, 9), "#dae4ee")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#e6edf3")
  pine(c, 8, 38, 15, true); pine(c, 63, 36, 14, true); pine(c, 16, 36, 10, true)
  -- a trodden path curving to the foreground
  c:fill(c:poly({ { 30, 36 }, { 44, 36 }, { 58, 49 }, { 10, 49 } }), "#c9d6e2")
  -- far and mid lanterns, glowing
  local function lantern(x, yb, k, glow, capdepth)
    local w = 4 * k
    part(c, R(c, x - 1, yb - 3 * k, x, yb), "#8b8f96", { noline = true })
    part(c, R(c, x - w, yb - 3 * k - 4 * k, x + w - 1, yb - 3 * k), "#8b8f96")
    c:fill(R(c, x - w + 2, yb - 3 * k - 4 * k + 2, x + w - 3, yb - 3 * k - 2), glow and "#ffd86a" or "#4a4a5a")
    local rt = yb - 3 * k - 4 * k
    part(c, c:poly({ { x - 1, rt - 3 * k }, { x + w + k, rt }, { x - w - k, rt } }), "#6a6e76")
    c:fill(c:poly({ { x - 1, rt - 3 * k - 1 }, { x + w, rt - 1 }, { x - w - 1, rt - 1 } }), "#f4f8fa")
    c:fill(R(c, x - w - k, rt, x + w + k - 1, rt), "#f4f8fa")
  end
  lantern(14, 42, 1, true); lantern(26, 38, 1, false)
  -- the near lantern, wearing a tall white hat of snow
  local lx = 52
  part(c, R(c, lx - 1, 38, lx + 1, 47), "#8b8f96", { noline = true })
  part(c, R(c, lx - 4, 46, lx + 4, 48), "#8b8f96")
  part(c, R(c, lx - 5, 29, lx + 5, 38), "#8b8f96")
  c:fill(R(c, lx - 3, 31, lx + 3, 36), "#ffd86a"); c:fill(R(c, lx - 2, 32, lx + 2, 35), "#fff1c8")
  part(c, R(c, lx - 7, 27, lx + 7, 29), "#6a6e76")
  part(c, c:poly({ { lx, 14 }, { lx + 8, 27 }, { lx - 8, 27 } }), "#f4f8fa")
  c:fill(R(c, lx - 8, 27, lx + 8, 27), "#f4f8fa")
  c:fill(c:poly({ { lx, 16 }, { lx + 4, 22 }, { lx - 4, 22 } }), "#f4f8fa")
  fl(c, R(c, lx - 5, 24, lx - 3, 25), "#c4d2e0"); fl(c, R(c, lx + 2, 20, lx + 3, 21), "#c4d2e0")
  -- gnome sweeping with a broom, hat snowy too
  local _, G = gnome(c, 38, 48, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -6, 11 }, false, true), arm({ 4, 10 }, { 6, 17 }, true, true) } })
  G.hat:each(function(x, y) if y <= G.tipy + 2 then c:px(x, y, "#f4f8fa") end end)
  local hx, hy = G.P(6, 17)
  c:fill(c:line({ { hx, hy + 5 }, { hx + 3, hy - 4 } }, 1), "#8a5a35")
  part(c, c:poly({ { hx + 2, hy - 4 }, { hx + 9, hy - 3 }, { hx + 7, hy - 10 }, { hx + 3, hy - 9 } }), "#d9bc84")
  fl(c, R(c, hx + 5, hy - 8, hx + 5, hy - 4), "#a8895a")
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0")
  -- chunks of snow sliding off, and flakes
  for _, p in ipairs({ { 46, 24 }, { 47, 30 }, { 45, 35 }, { 58, 33 }, { 60, 38 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#fbfdfe") end
  seed = 74
  for i = 1, 24 do
    local x, y = 6 + floor(rand() * 62), 6 + floor(rand() * 40)
    c:px(x, y, "#fbfdfe")
  end
  finish(c, "w3_snowy_lanterns")
end

---------------------------------------------------------------- 15. w3_fog_pilgrim (fog)
function S.w3_fog_pilgrim()
  seed = 75
  local c = new()
  local FOG, FOG2 = "#d3d9db", "#c0c9cd"
  c:fill(R(c, 0, 0, W - 1, H - 1), "#aab6b8")
  -- tree trunks on the sides, receding
  for _, t in ipairs({ { 7, 10 }, { 13, 6 }, { 62, 12 }, { 67, 7 } }) do
    part(c, R(c, t[1], t[2], t[1] + 3, 49), "#5e6e60", { noline = true })
  end
  -- the stone stair climbing straight away from us
  c:fill(c:poly({ { 28, 12 }, { 44, 12 }, { 62, 49 }, { 10, 49 } }), "#8b8f96")
  local ys = { 47, 43, 39, 36, 33, 30, 27, 25, 23, 21, 19, 17, 15, 13 }
  for i, y in ipairs(ys) do
    local t = (y - 12) / 37
    local x0, x1 = floor(28 - 18 * t + 0.5), floor(44 + 18 * t + 0.5)
    fl(c, R(c, x0, y, x1, y), "#b5b9bf")
    fl(c, R(c, x0, y + 1, x1, y + 1), "#6c7078")
  end
  -- moss on the stones, marking the way
  for _, p in ipairs({ { 18, 44 }, { 27, 41 }, { 40, 38 }, { 24, 35 }, { 44, 32 }, { 34, 29 }, { 30, 26 } }) do
    fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#5e8a44"); fl(c, R(c, p[1] + 1, p[2] - 1, p[1] + 2, p[2] - 1), "#7ea85a")
  end
  -- stone lanterns by the steps, fading
  for _, l in ipairs({ { 9, 38, 1 }, { 61, 38, 1 }, { 23, 22, 0 }, { 49, 22, 0 } }) do
    local x, y, big = l[1], l[2], l[3]
    if big == 1 then
      part(c, R(c, x - 1, y - 2, x + 1, y + 6), "#8b8f96", { noline = true }); part(c, R(c, x - 3, y - 7, x + 3, y - 2), "#8b8f96"); part(c, c:poly({ { x, y - 11 }, { x + 5, y - 7 }, { x - 5, y - 7 } }), "#7a8088")
      c:fill(R(c, x - 1, y - 6, x + 1, y - 4), "#ffd86a")
    else
      part(c, R(c, x - 1, y - 1, x + 1, y + 3), "#8b8f96", { noline = true }); part(c, R(c, x - 2, y - 4, x + 2, y - 1), "#8b8f96"); c:px(x, y - 3, "#ffd86a")
    end
  end
  -- the fog itself: solid up high, dithered lower
  c:fill(R(c, 0, 0, W - 1, 15), FOG)
  dither(c, 0, 16, W - 1, 19, FOG, 0); dither(c, 0, 16, W - 1, 17, FOG, 1)
  dither(c, 0, 20, W - 1, 23, FOG2, 0)
  dither(c, 0, 24, W - 1, 24, FOG2, 1)
  c:fill(c:ellipse(12, 30, 9, 2), FOG); c:fill(c:ellipse(60, 33, 9, 2), FOG); c:fill(c:ellipse(40, 44, 6, 1), FOG2)
  -- a faint torii at the top of the stair
  fl(c, R(c, 28, 8, 29, 14), "#aab6b8"); fl(c, R(c, 43, 8, 44, 14), "#aab6b8"); fl(c, R(c, 26, 7, 46, 8), "#aab6b8")
  dither(c, 24, 4, 48, 10, FOG, 0)
  -- the pilgrim follows, straw hat and staff
  local _, P = gnome(c, 22, 48, { d = 1, s = 1.2, hat = "#d9bc84", eyes = "open", arms = { arm({ -4, 7 }, { -6, 4 }, false), arm({ 4, 9 }, { 8, 12 }, true) } })
  local px_, py_ = P.P(8, 12)
  c:fill(c:line({ { px_ + 1, py_ - 3 }, { px_ + 1, 48 } }, 1), "#8a5a35")
  -- our gnome leads, lantern held out, glancing back
  local _, G = gnome(c, 44, 42, { d = -1, eyes = "open", walk = -1, arms = { arm({ -4, 8 }, { -7, 12 }, true, true), arm({ 4, 8 }, { 6, 5 }, false) } })
  local hx, hy = G.P(-7, 12)
  fl(c, R(c, hx - 1, hy, hx, hy + 1), "#f0c8a0")
  fl(c, R(c, hx - 1, hy + 2, hx - 1, hy + 2), "#3d2a1c")
  part(c, R(c, hx - 3, hy + 2, hx + 1, hy + 6), "#ffd86a"); c:fill(R(c, hx - 2, hy + 3, hx, hy + 5), "#fff1c8")
  finish(c, "w3_fog_pilgrim")
end

local order = { "w2_make_beds", "w2_late_coach", "w2_dry_cloaks", "w2_apple_crumble", "w2_early_eggs", "w2_air_mattresses", "w2_creaky_stair", "w2_song_off", "w2_hat_pegs", "w2_room_keys", "w2_hearth_bellows", "w2_guestbook", "w3_shrine_cat", "w3_snowy_lanterns", "w3_fog_pilgrim" }
for _, s2 in ipairs(order) do
  if not only or only == s2 then if S[s2] then seed = 7; S[s2]() end end
end
