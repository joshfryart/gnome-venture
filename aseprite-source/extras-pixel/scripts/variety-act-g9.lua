-- variety-act-g9.lua : Do-tab scenes for rest-stop activities (group g9) -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g9.lua   (params BEFORE --script)
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

local function rain(c, n, col, x0, x1, y0, y1)
  for i = 1, n do
    local x, y = x0 + floor(rand() * (x1 - x0)), y0 + floor(rand() * (y1 - y0))
    c:px(x, y, col); c:px(x - 1, y + 1, col); c:px(x - 2, y + 2, col)
  end
end

-- 1. prop_branches: a laden pear bough bowed to the grass, gnome wedging a forked stick under it
function S.prop_branches()
  seed = 5
  local c = new()
  day(c, 32, { cloud = 40, sky = { "#b4d8dc", "#c8e2dc", "#dbebd4" }, hill = "#5e8a44", hill2 = "#6a9648" })
  -- far tree (left), small
  part(c, R(c, 8, 22, 9, 32), "#6b4a2e", { noline = true })
  part(c, c:ellipse(9, 18, 7, 5), "#4f8a3c", { shade = true })
  for _, p in ipairs({ { 6, 18 }, { 11, 20 }, { 9, 15 } }) do c:px(p[1], p[2], "#d8d860") end
  -- big tree (right)
  part(c, R(c, 56, 13, 60, 46), "#6b4a2e", { noline = true })
  fl(c, R(c, 57, 16, 57, 44), "#8a5a35")
  part(c, c:ellipse(58, 10, 11, 7), "#3f8a42", { shade = true })
  part(c, c:ellipse(49, 15, 6, 4), "#3f8a42", { shade = true })
  c:fill(c:ellipse(56, 7, 5, 2), "#5aa84e")
  -- the bowed bough, heavy with pears, down to the grass
  local bo = { { 55, 17 }, { 48, 23 }, { 42, 30 }, { 37, 36 } }
  part(c, c:line(bo, 4), "#6b4a2e", { noline = true })
  fl(c, c:line(bo, 2), "#8a5a35")
  part(c, c:ellipse(37, 36, 7, 3), "#3f8a42", { shade = true })
  c:fill(c:ellipse(36, 35, 4, 1), "#5aa84e")
  local function pear(x, y)
    part(c, c:ellipse(x, y, 2, 2), "#d2d640"); c:px(x - 1, y - 1, "#f4f4a8"); c:px(x, y - 3, "#6b4a2e")
  end
  pear(31, 40); pear(37, 40); pear(43, 38); pear(47, 28); pear(52, 22); pear(42, 33)
  -- forked stick under the bough
  part(c, c:line({ { 38, 47 }, { 38, 42 } }, 2), "#a8703e", { noline = true })
  fl(c, R(c, 36, 40, 36, 42), "#a8703e"); fl(c, R(c, 40, 40, 40, 42), "#a8703e")
  -- windfalls in the grass
  part(c, c:ellipse(52, 47, 2, 1), "#d2d640"); part(c, c:ellipse(63, 45, 2, 1), "#d2d640"); part(c, c:ellipse(12, 40, 2, 1), "#d2d640")
  gnome(c, 23, 47, { d = 1, eyes = "happy", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 7 }, { 14, 5 }, true) } })
  finish(c, "w1_prop_branches")
end

-- 2. windfall_toss: underarm lob of an apple at a cider barrel, chalk line in the grass, orchard behind
function S.windfall_toss()
  seed = 9
  local c = new()
  day(c, 30, { cloud = 52, sky = { "#9fd0e4", "#b8dde8", "#cfe8ea" }, hill = "#5e8a44", hill2 = "#4e8a3c" })
  -- trees with red apples at the back
  for _, t in ipairs({ { 12, 30 }, { 30, 28 }, { 46, 29 } }) do
    part(c, R(c, t[1] - 1, t[2] - 8, t[1] + 1, t[2]), "#6b4a2e", { noline = true })
    part(c, c:ellipse(t[1], t[2] - 12, 7, 6), "#3f8a42", { shade = true })
    c:px(t[1] - 3, t[2] - 12, "#e04a30"); c:px(t[1] + 2, t[2] - 14, "#e04a30"); c:px(t[1] + 1, t[2] - 10, "#e04a30")
  end
  -- chalk line (the throwing line)
  for y = 40, 49, 1 do c:px(26, y, "#f4eee0") end
  for y = 40, 49, 2 do c:px(27, y, "#f4eee0") end
  -- barrel
  part(c, R(c, 55, 33, 67, 47), "#b07a45")
  part(c, c:ellipse(61, 33, 6, 2), "#5a2f1e")
  c:fill(c:ellipse(61, 33, 4, 1), "#d68a3a")
  fl(c, R(c, 55, 37, 67, 37), "#4a4a52"); fl(c, R(c, 55, 43, 67, 43), "#4a4a52")
  fl(c, R(c, 59, 34, 59, 46), "#c89258")
  c:px(60, 33, "#e04a30"); c:px(63, 33, "#c0402e")
  -- pile of windfalls
  for _, p in ipairs({ { 8, 46 }, { 12, 47 }, { 16, 46 }, { 10, 44 } }) do
    part(c, c:ellipse(p[1], p[2], 2, 2), "#d8402e"); c:px(p[1] - 1, p[2] - 1, "#f08a6a")
  end
  gnome(c, 22, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 4 }, false), arm({ 4, 6 }, { 8, 11 }, true) } })
  -- apple in flight with its arc
  for _, p in ipairs({ { 33, 24 }, { 37, 21 }, { 41, 20 }, { 45, 21 }, { 49, 24 } }) do c:px(p[1], p[2], "#fff6d8") end
  part(c, c:ellipse(53, 28, 2, 2), "#e04a30"); c:px(52, 27, "#f6a088"); c:px(53, 25, "#4f8a3c")
  finish(c, "w1_windfall_toss")
end

-- 3. wassail: winter dusk, gnome with a lantern singing to the old tree, toast in its branches
function S.wassail()
  seed = 14
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 32), { "#2a2a5a", "#3a3468", "#523e74", "#7a4a78", "#a85a78" }, { dir = "v" })
  c:fill(c:ellipse(14, 34, 30, 9), "#38405e"); c:fill(c:ellipse(64, 34, 26, 8), "#2e3652")
  for _, p in ipairs({ { 12, 8 }, { 26, 14 }, { 40, 7 }, { 56, 12 }, { 64, 7 }, { 34, 20 }, { 8, 20 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(R(c, 0, 32, W - 1, H - 1), "#dde6ee")
  c:fill(R(c, 0, 32, W - 1, 32), "#f4f8fa")
  for i = 1, 10 do local x, y = 3 + floor(rand() * 66), 36 + floor(rand() * 13); fl(c, R(c, x, y, x + 2, y), "#b8c6d8") end
  -- old gnarled tree
  part(c, c:poly({ { 53, 18 }, { 58, 18 }, { 60, 46 }, { 50, 46 } }), "#5e3f28", { noline = true })
  fl(c, R(c, 54, 22, 54, 42), "#4a2c1a"); fl(c, R(c, 57, 26, 57, 42), "#7a5636")
  local function branch(pts, w) part(c, c:line(pts, w), "#5e3f28", { noline = true }) end
  branch({ { 54, 20 }, { 47, 15 }, { 42, 9 } }, 3)
  branch({ { 57, 20 }, { 62, 14 }, { 66, 8 } }, 3)
  branch({ { 55, 18 }, { 55, 11 }, { 57, 6 } }, 2)
  branch({ { 50, 26 }, { 44, 24 } }, 2)
  branch({ { 59, 28 }, { 65, 26 } }, 2)
  for _, p in ipairs({ { 43, 9 }, { 47, 14 }, { 65, 10 }, { 57, 6 }, { 44, 24 }, { 65, 26 }, { 55, 19 } }) do c:fill(R(c, p[1] - 1, p[2] - 1, p[1] + 1, p[2] - 1), "#f4f8fa") end
  -- toast soaked in cider hung in the boughs, and apples
  for _, p in ipairs({ { 41, 11 }, { 64, 12 }, { 43, 25 } }) do part(c, R(c, p[1], p[2], p[1] + 2, p[2] + 2), "#d9a660"); c:px(p[1] + 1, p[2] + 1, "#8a4f2a") end
  c:px(58, 9, "#d8402e"); c:px(59, 9, "#d8402e"); c:px(52, 18, "#d8402e")
  part(c, R(c, 47, 44, 62, 47), "#f4f8fa", { noline = true })
  -- the singer, lantern held high
  local _, G = gnome(c, 22, 47, { d = 1, eyes = "happy", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 8 }, { 9, 12 }, true) } })
  -- lantern on a hook-pole
  local lx, ly = G.P(9, 12)
  part(c, R(c, lx - 1, ly - 7, lx, ly), "#6b4a2e", { noline = true })
  part(c, R(c, lx - 3, ly - 12, lx + 3, ly - 7), "#3d2a1c")
  fl(c, R(c, lx - 2, ly - 11, lx + 2, ly - 8), "#ffe08a"); fl(c, R(c, lx - 1, ly - 10, lx + 1, ly - 9), "#fff8d8")
  -- warm glow as dither dots
  for _, p in ipairs({ { -6, -8 }, { 6, -8 }, { -5, -12 }, { 5, -12 }, { 0, -15 }, { -7, -10 }, { 7, -10 } }) do c:px(lx + p[1], ly + p[2], "#f5cf6a") end
  -- song notes
  local function note(x, y) fl(c, R(c, x, y, x + 1, y + 1), "#fff1c8"); fl(c, R(c, x + 1, y - 3, x + 1, y), "#fff1c8"); c:px(x + 2, y - 3, "#fff1c8") end
  note(36, 36); note(41, 31); note(44, 38)
  -- snowfall
  for i = 1, 16 do c:px(6 + floor(rand() * 62), 6 + floor(rand() * 26), "#fbfdfe") end
  finish(c, "w1_wassail")
end

-- 4. umbrella_duty: huge umbrella over a little queue on a rainy jetty
function S.umbrella_duty()
  seed = 20
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#6a7a8c", "#7a8a9a", "#8a98a6", "#9aa6b2" }, { dir = "v" })
  c:fill(c:ellipse(10, 28, 22, 6), "#4e6a58"); c:fill(c:ellipse(60, 29, 26, 7), "#456450")
  c:bands(R(c, 0, 30, W - 1, H - 1), { "#5a7c92", "#4e7088", "#456580", "#3e5c74" }, { dir = "v" })
  for _, p in ipairs({ { 8, 36 }, { 20, 41 }, { 54, 38 }, { 62, 45 }, { 14, 47 } }) do fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#8fb4c8") end
  -- jetty planks + posts
  part(c, R(c, 4, 38, 67, 44), "#8a5a35")
  for x = 10, 66, 8 do fl(c, R(c, x, 38, x, 44), "#6b3b2a") end
  fl(c, R(c, 4, 38, 67, 38), "#b07a45")
  for _, x in ipairs({ 8, 26, 46, 64 }) do part(c, R(c, x, 44, x + 2, 52), "#5e3f28", { noline = true }) end
  -- mooring post at right
  part(c, R(c, 62, 30, 65, 38), "#6b4a2e")
  -- passengers (small gnomes) waiting under the umbrella
  gnome(c, 42, 38, { d = -1, s = 0.7, hat = "#4f9a45", eyes = "open" })
  gnome(c, 51, 38, { d = -1, s = 0.7, hat = "#e8a317", eyes = "open" })
  -- the umbrella gnome
  local _, G = gnome(c, 31, 40, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 9 }, { 8, 14 }, true) } })
  local hx, hy = G.P(8, 14)
  part(c, R(c, hx, hy - 10, hx + 1, hy), "#3d2a1c", { noline = true })
  local dome = c:mask()
  local cx, top = hx + 1, hy - 20
  local function hwid(i) return floor(19 * math.sqrt(1 - ((8 - i) / 9) ^ 2) + 0.5) end
  for i = 0, 8 do dome:add(c:rect(cx - hwid(i), top + i, cx + hwid(i), top + i)) end
  part(c, dome, "#2f6290")
  for k = -3, 3, 2 do
    for i = 1, 8 do
      local x0, x1 = cx + k * 5 - 2, cx + k * 5 + 2
      if x0 >= cx - hwid(i) and x1 <= cx + hwid(i) then fl(c, R(c, x0, top + i, x1, top + i), "#e8a317") end
    end
  end
  for k = -19, 17, 4 do part(c, c:ellipse(cx + k + 2, top + 9, 2, 1), (floor(k / 4) % 2 == 0) and "#2f6290" or "#e8a317", { noline = true }) end
  c:px(cx, top - 1, "#3d2a1c"); c:px(cx, top - 2, "#3d2a1c")
  -- rain
  seed = 33
  rain(c, 34, "#cfe4f0", 6, 68, 5, 36)
  for _, p in ipairs({ { 20, 44 }, { 38, 42 }, { 58, 41 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#cfe4f0") end
  finish(c, "w1_umbrella_duty")
end

-- 5. crate_mixup: three label-less crates on the landing, a gnome pointing, an anxious grandmother wringing her knitting-free hands
function S.crate_mixup()
  seed = 30
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 26), { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  c:fill(c:ellipse(52, 8, 8, 2), "#f4eee0")
  c:fill(c:ellipse(10, 27, 24, 6), "#5e8a44")
  c:bands(R(c, 0, 26, W - 1, 33), { "#4f86a8", "#5a94b4" }, { dir = "v" })
  fl(c, R(c, 8, 30, 14, 30), "#8fc4d8"); fl(c, R(c, 40, 29, 47, 29), "#8fc4d8")
  -- landing planks
  c:fill(R(c, 0, 34, W - 1, H - 1), "#a8703e")
  for y = 38, 50, 6 do fl(c, R(c, 0, y, W - 1, y), "#8a5a35") end
  for x = 4, 70, 9 do fl(c, R(c, x, 34, x, H - 1), "#8a5a35") end
  fl(c, R(c, 0, 34, W - 1, 34), "#c89258")
  -- ferry rope post
  part(c, R(c, 62, 22, 65, 36), "#6b4a2e"); part(c, c:ellipse(63.5, 22, 3, 1), "#8a5a35")
  local function crate(x0, y0, x1, y1, col, lid)
    part(c, R(c, x0, y0, x1, y1), col)
    fl(c, R(c, x0, y0 + 2, x1, y0 + 2), lid); fl(c, R(c, x0, y1 - 2, x1, y1 - 2), lid)
    fl(c, R(c, x0 + 1, y0, x0 + 1, y1), lid); fl(c, R(c, x1 - 1, y0, x1 - 1, y1), lid)
  end
  -- three crates, torn tags dangling off each
  crate(24, 33, 35, 46, "#b8864e", "#8a5a35")
  part(c, R(c, 32, 40, 34, 43), "#f4eee0", { noline = true }); fl(c, R(c, 33, 38, 33, 40), "#8a5a35")
  crate(38, 36, 48, 47, "#c89258", "#8a5a35")
  part(c, R(c, 41, 41, 44, 45), "#f4eee0", { noline = true })
  crate(51, 31, 62, 46, "#a8703e", "#6b3b2a")
  part(c, R(c, 58, 38, 60, 41), "#f4eee0", { noline = true })
  -- wool peeking out? no: a turnip leaf on the middle one
  c:px(42, 35, "#6ab04a"); c:px(43, 34, "#6ab04a"); c:px(44, 35, "#6ab04a")
  -- pointing gnome
  gnome(c, 12, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 7 }, { 11, 9 }, true) } })
  -- grandmother: lilac hat, hands together, worried
  gnome(c, 61, 49, { d = -1, s = 0.8, hat = "#8a6aa8", eyes = "open", arms = { arm({ 3, 5 }, { -2, 6 }, true) } })
  finish(c, "w1_crate_mixup")
end

-- 6. river_drift: seated on the landing steps watching drifting things bob by
function S.river_drift()
  seed = 40
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 24), { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  c:fill(c:ellipse(40, 7, 9, 2), "#f4eee0")
  c:fill(c:ellipse(60, 25, 24, 7), "#5e8a44"); c:fill(c:ellipse(14, 26, 20, 5), "#4e8a3c")
  c:fill(R(c, 0, 25, W - 1, H - 1), "#4f9cb4")
  for y = 29, 49, 5 do for x = (y % 2) * 3 + 20, 66, 12 do fl(c, R(c, x, y, x + 4, y), "#8fcbd8") end end
  -- toll house wall with doorframe notches (left)
  part(c, R(c, 4, 10, 20, 36), "#b8a078")
  for y = 12, 34, 4 do fl(c, R(c, 4, y, 20, y), "#a08a62") end
  part(c, R(c, 8, 15, 15, 36), "#6b3b2a", { noline = true })
  part(c, R(c, 7, 14, 16, 15), "#8a5a35", { noline = true }); part(c, R(c, 7, 14, 8, 36), "#8a5a35", { noline = true }); part(c, R(c, 15, 14, 16, 36), "#8a5a35", { noline = true })
  for y = 20, 32, 3 do fl(c, R(c, 7, y, 8, y), "#f4eee0") end
  fl(c, R(c, 15, 20, 15, 20), "#f4eee0"); fl(c, R(c, 15, 23, 15, 23), "#f4eee0")
  part(c, R(c, 3, 8, 21, 10), "#c0442e")
  -- stepped landing
  part(c, R(c, 4, 41, 28, 44), "#a8aeb4")
  part(c, R(c, 4, 45, 37, 49), "#9aa0a8")
  fl(c, R(c, 4, 41, 28, 41), "#c9c5bc"); fl(c, R(c, 4, 45, 37, 45), "#c9c5bc")
  fl(c, R(c, 4, 37, 28, 40), "#b8a078")
  -- seated gnome, legs dangling toward the water
  gnome(c, 17, 41, { d = 1, sit = true, eyes = "open", arms = { arm({ -4, 6 }, { -4, 2 }, false) } })
  -- drifting things
  local function ring(x, y) fl(c, R(c, x - 3, y + 2, x + 3, y + 2), "#8fcbd8") end
  -- leaf boat with a twig sail
  ring(44, 36); part(c, c:ellipse(44, 35, 4, 1), "#d68a3a"); fl(c, R(c, 44, 30, 44, 34), "#6b4a2e"); fl(c, R(c, 45, 31, 46, 33), "#f4eee0")
  -- duckling
  ring(58, 33); part(c, c:ellipse(58, 32, 3, 2), "#f5cf6a"); part(c, R(c, 60, 28, 62, 30), "#f5cf6a"); c:px(63, 29, "#e8802a"); c:px(61, 28, "#2a1a10")
  -- lost red mitten
  ring(50, 44); part(c, c:ellipse(50, 43, 3, 2), "#c0442e"); fl(c, R(c, 52, 41, 53, 42), "#c0442e")
  -- floating apple + feather + cork
  ring(43, 48); part(c, c:ellipse(43, 47, 2, 2), "#e04a30"); c:px(43, 44, "#4f8a3c")
  part(c, c:ellipse(63, 46, 1, 1), "#c8a068")
  fl(c, R(c, 40, 39, 43, 39), "#f4eee0"); fl(c, R(c, 43, 38, 44, 38), "#cfd8e0")
  finish(c, "w1_river_drift")
end

-- 7. dawn_tales: sunrise, three wanderers round the dying embers, one telling a tale with wide arms
function S.dawn_tales()
  seed = 50
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 31), { "#7a6aa8", "#a87aa8", "#d88a98", "#f0a888", "#f8cf88", "#fbe6a8" }, { dir = "v" })
  -- sun rising behind hills
  c:fill(c:ellipse(36, 32, 10, 8), "#fff1c8"); c:fill(c:ellipse(36, 32, 7, 6), "#fffbe8")
  for _, a in ipairs({ { 36, 17 }, { 22, 22 }, { 50, 22 }, { 14, 28 }, { 58, 28 } }) do c:px(a[1], a[2], "#fff1c8"); c:px(a[1], a[2] + 1, "#fff1c8") end
  c:fill(c:ellipse(12, 36, 26, 9), "#6a6a8a"); c:fill(c:ellipse(60, 36, 26, 9), "#5e6a84")
  c:fill(R(c, 0, 33, W - 1, H - 1), "#7a9a58")
  c:fill(R(c, 0, 33, W - 1, 33), "#c8b868")
  for i = 1, 10 do local x, y = 3 + floor(rand() * 66), 36 + floor(rand() * 12); c:px(x, y, "#5e8a44"); c:px(x + 1, y - 1, "#5e8a44") end
  pine(c, 6, 38, 14); pine(c, 12, 37, 10)
  -- tent at right
  part(c, c:poly({ { 62, 29 }, { 69, 39 }, { 55, 39 } }), "#e8a317")
  c:fill(c:poly({ { 62, 33 }, { 65, 39 }, { 59, 39 } }), "#6b3b2a")
  fl(c, R(c, 62, 27, 62, 29), "#8a5a35")
  gnome(c, 36, 41, { d = 1, eyes = "happy", arms = { arm({ -4, 8 }, { -10, 15 }, false), arm({ 4, 8 }, { 10, 15 }, true) } })
  -- ring of stones, embers, wisp of smoke
  for _, x in ipairs({ 29, 32, 35, 38, 41 }) do part(c, c:ellipse(x, 47, 2, 1), "#9a9ea6") end
  fl(c, R(c, 31, 45, 39, 46), "#5a2f1e"); fl(c, R(c, 33, 44, 37, 45), "#e8601f"); fl(c, R(c, 34, 44, 36, 44), "#f5cf6a")
  gnome(c, 18, 48, { d = 1, sit = true, hat = "#4f9a45", eyes = "open", arms = { arm({ -4, 6 }, { -4, 2 }, false) } })
  gnome(c, 54, 48, { d = -1, sit = true, hat = "#e8a317", eyes = "open", arms = { arm({ 4, 6 }, { 4, 2 }, false) } })
  finish(c, "w1_dawn_tales")
end

-- 8. pitch_tent: gale, tent lifting like a kite, gnome heaving on the guy rope
function S.pitch_tent()
  seed = 60
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#8896a4", "#98a6b2", "#a8b4be", "#b8c4cc" }, { dir = "v" })
  c:fill(c:ellipse(16, 12, 14, 2), "#d8dee4"); c:fill(c:ellipse(52, 18, 16, 2), "#cfd6dc")
  c:fill(c:ellipse(20, 34, 32, 8), "#5e7e4a"); c:fill(c:ellipse(62, 35, 24, 7), "#547444")
  c:fill(R(c, 0, 33, W - 1, H - 1), "#7ea060")
  c:fill(R(c, 0, 33, W - 1, 33), "#98b878")
  -- grass leaning in the wind
  for i = 1, 18 do local x, y = 4 + floor(rand() * 64), 35 + floor(rand() * 13); c:px(x, y, "#5e8a44"); c:px(x + 1, y, "#5e8a44"); c:px(x + 2, y - 1, "#5e8a44") end
  -- the tent: left side torn up off the grass by the gale, right side still pegged
  c:fill(c:ellipse(46, 43, 20, 2), "#5e7e4a")
  part(c, c:poly({ { 48, 11 }, { 68, 42 }, { 36, 39 }, { 30, 31 } }), "#d9a840")
  c:fill(c:poly({ { 48, 18 }, { 56, 38 }, { 40, 37 } }), "#b8862a")
  c:fill(c:poly({ { 48, 24 }, { 52, 39 }, { 45, 38 } }), "#5a2f1e")
  fl(c, R(c, 48, 9, 48, 11), "#8a5a35")
  fl(c, R(c, 30, 31, 32, 31), "#f4eee0"); fl(c, R(c, 34, 36, 36, 36), "#f4eee0")
  c:fill(c:poly({ { 36, 39 }, { 62, 41 }, { 40, 42 } }), "#4a6a3a")
  -- guy rope from the raised corner down to the gnome's fists
  fl(c, c:line({ { 31, 32 }, { 27, 41 } }, 1), "#3d2a1c")
  -- gnome leaning back on the rope, hauling
  gnome(c, 17, 47, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { 9, 7 }, false), arm({ 4, 7 }, { 10, 6 }, true) } })
  fl(c, c:line({ { 26, 40 }, { 27, 41 } }, 1), "#3d2a1c")
  -- pegs and a mallet on the ground
  part(c, R(c, 60, 45, 61, 47), "#8a5a35", { noline = true }); part(c, R(c, 64, 46, 65, 48), "#8a5a35", { noline = true })
  part(c, R(c, 40, 46, 44, 47), "#8a5a35", { noline = true }); part(c, R(c, 40, 44, 42, 48), "#a8703e", { noline = true })
  -- wind streaks, flying leaves
  for _, p in ipairs({ { 8, 10 }, { 30, 8 }, { 12, 22 }, { 60, 7 }, { 20, 28 }, { 50, 28 } }) do fl(c, R(c, p[1], p[2], p[1] + 7, p[2]), "#e8eef2") end
  for _, p in ipairs({ { 24, 16 }, { 56, 24 }, { 40, 6 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#c8803a", { noline = true }) end
  -- a pair of flying pegs
  fl(c, R(c, 62, 14, 64, 14), "#8a5a35")
  finish(c, "w1_pitch_tent")
end

local function awning(c, x0, x1, y, h, ca, cb)
  part(c, R(c, x0, y, x1, y + h), ca)
  local i = 0
  for x = x0 + 1, x1 - 1, 3 do
    if i % 2 == 1 then fl(c, R(c, x, y + 1, x + 2, y + h), cb) end
    i = i + 1
  end
  for x = x0, x1 - 2, 3 do part(c, c:ellipse(x + 1, y + h + 1, 1, 1), (((x - x0) // 3) % 2 == 1) and cb or ca, { noline = true }) end
end

-- 9. ash_flatbread: cook crouched at a campfire, a hot stone with dough, turning with a stick
function S.ash_flatbread()
  seed = 70
  local c = new()
  day(c, 31, { cloud = 46, sky = { "#a8c8e0", "#bcd8e4", "#d0e6e4" }, hill = "#4e7a3a", hill2 = "#3f6a32" })
  pine(c, 8, 34, 18); pine(c, 64, 33, 16)
  -- camp tent, left back
  part(c, c:poly({ { 20, 21 }, { 30, 34 }, { 10, 34 } }), "#d9c8a0")
  c:fill(c:poly({ { 20, 26 }, { 24, 34 }, { 16, 34 } }), "#6b3b2a")
  -- sack of flour + wheat sheaf + herbs
  part(c, c:rrect(3, 40, 11, 49, 2), "#e8dcc0"); fl(c, R(c, 5, 39, 9, 40), "#b8a078")
  part(c, c:ellipse(7, 45, 2, 2), "#f4eee0", { noline = true })
  for k = 0, 4 do fl(c, R(c, 14 + k, 38 + (k % 2), 14 + k, 47), "#e8c050") end
  fl(c, R(c, 13, 44, 19, 44), "#8a5a35")
  for _, p in ipairs({ { 14, 37 }, { 16, 36 }, { 18, 37 } }) do c:px(p[1], p[2], "#e8c050"); c:px(p[1], p[2] - 1, "#e8c050") end
  -- fire with a flat hot stone on top
  for _, x in ipairs({ 43, 48, 53, 58 }) do part(c, c:ellipse(x, 48, 3, 2), "#8b8f96", { shade = true }) end
  part(c, c:rrect(42, 40, 60, 43, 1), "#6a6a72")
  fl(c, R(c, 42, 40, 60, 40), "#9a9aa4")
  -- flames under and beside
  for _, f in ipairs({ { 46, 47, 3, 5 }, { 51, 47, 4, 7 }, { 56, 47, 3, 5 } }) do
    c:fill(c:poly({ { f[1], f[2] - f[4] }, { f[1] + f[3], f[2] }, { f[1] - f[3], f[2] } }), "#e8601f")
    c:fill(c:poly({ { f[1], f[2] - f[4] + 3 }, { f[1] + 1, f[2] }, { f[1] - 1, f[2] } }), "#f5cf6a")
  end
  fl(c, R(c, 44, 44, 58, 45), "#5a2f1e"); fl(c, R(c, 47, 44, 55, 44), "#e8601f")
  -- the flatbreads on the stone: one done, one being turned
  part(c, c:ellipse(47, 38, 5, 2), "#e0a850"); fl(c, R(c, 45, 37, 46, 37), "#8a4f2a"); fl(c, R(c, 49, 39, 50, 39), "#8a4f2a")
  part(c, c:ellipse(56, 38, 4, 1), "#f0d8a0"); c:px(55, 38, "#c89258")
  -- the cook, crouched, poking with a stick
  gnome(c, 30, 47, { d = 1, sit = true, eyes = "open", arms = { arm({ -4, 6 }, { -4, 2 }, false), arm({ 4, 6 }, { 11, 5 }, true) } })
  fl(c, c:line({ { 38, 41 }, { 46, 37 } }, 1), "#a8703e")
  c:px(46, 37, "#a8703e")
  finish(c, "w1_ash_flatbread")
end

-- 10. runaway_cabbages: market lane, tipped crate at the top, cabbages rolling off past the stalls, gnome in pursuit
function S.runaway_cabbages()
  seed = 80
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 24), { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  c:fill(c:ellipse(56, 8, 8, 2), "#f4eee0")
  -- stalls along the back
  c:fill(R(c, 0, 24, W - 1, 33), "#d9c8a0")
  awning(c, 3, 23, 14, 4, "#c0442e", "#f4eee0"); part(c, R(c, 4, 19, 5, 30), "#8a5a35", { noline = true }); part(c, R(c, 21, 19, 22, 30), "#8a5a35", { noline = true })
  part(c, R(c, 4, 28, 22, 33), "#a8703e"); fl(c, R(c, 4, 28, 22, 28), "#c89258")
  for x = 7, 20, 5 do part(c, c:ellipse(x, 27, 2, 1), "#e8a317", { noline = true }) end
  awning(c, 44, 66, 12, 4, "#2f6290", "#f4eee0"); part(c, R(c, 45, 17, 46, 30), "#8a5a35", { noline = true }); part(c, R(c, 64, 17, 65, 30), "#8a5a35", { noline = true })
  part(c, R(c, 45, 28, 65, 33), "#a8703e"); fl(c, R(c, 45, 28, 65, 28), "#c89258")
  for x = 48, 63, 5 do part(c, c:ellipse(x, 27, 2, 1), "#d8402e", { noline = true }) end
  -- cobbled lane
  c:fill(R(c, 0, 34, W - 1, H - 1), "#a89880")
  for y = 38, 50, 4 do for x = ((y // 4) % 2) * 4, 70, 8 do fl(c, R(c, x, y, x + 4, y), "#8a7a64") end end
  fl(c, R(c, 0, 34, W - 1, 34), "#c8b898")
  -- tipped crate at the top of the lane (left), spilled
  part(c, c:poly({ { 4, 36 }, { 14, 34 }, { 16, 42 }, { 6, 44 } }), "#a8703e")
  fl(c, c:line({ { 5, 39 }, { 15, 37 } }, 1), "#6b3b2a")
  c:fill(c:poly({ { 6, 38 }, { 13, 37 }, { 14, 41 }, { 7, 42 } }), "#4a2c1a")
  -- cabbages
  local function cab(x, y, r)
    part(c, c:ellipse(x, y, r, r), "#5aa84e", { shade = false })
    c:fill(c:ellipse(x, y, r - 2, r - 2), "#7cc868")
    fl(c, R(c, x - 1, y - 1, x + 1, y - 1), "#a8e08a"); c:px(x, y + 1, "#a8e08a"); c:px(x - r + 1, y + 1, "#3f8a42")
  end
  cab(38, 41, 3); cab(46, 44, 3); cab(55, 40, 3); cab(63, 46, 3)
  -- motion dashes
  for _, p in ipairs({ { 33, 43 }, { 41, 46 }, { 50, 42 }, { 58, 48 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#e8dcc0") end
  -- the chaser, mid-stride, arms out
  gnome(c, 25, 49, { d = 1, walk = 1, s = 1.1, eyes = "open", arms = { arm({ -4, 6 }, { -8, 7 }, false), arm({ 4, 7 }, { 11, 6 }, true) } })
  finish(c, "w2_runaway_cabbages")
end

-- 11. dawn_carts: pink dawn, a cart heaped with crates, gnome hauling a crate to the stall
function S.dawn_carts()
  seed = 90
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#7a7ab0", "#a888b0", "#d898a0", "#f0a890", "#f8c890" }, { dir = "v" })
  c:fill(c:ellipse(60, 30, 7, 6), "#fff1c8")
  c:fill(c:ellipse(10, 33, 26, 7), "#68688a"); c:fill(c:ellipse(52, 34, 22, 6), "#5e6a84")
  c:fill(R(c, 0, 31, W - 1, 38), "#b8a888")
  c:fill(R(c, 0, 38, W - 1, H - 1), "#a89880")
  for y = 42, 50, 4 do for x = ((y // 4) % 2) * 4, 70, 8 do fl(c, R(c, x, y, x + 4, y), "#8a7a64") end end
  -- stall at the left with striped awning
  awning(c, 2, 24, 14, 4, "#e8a317", "#f4eee0"); part(c, R(c, 3, 19, 4, 36), "#8a5a35", { noline = true }); part(c, R(c, 22, 19, 23, 36), "#8a5a35", { noline = true })
  part(c, R(c, 3, 32, 23, 38), "#a8703e"); fl(c, R(c, 3, 32, 23, 32), "#c89258")
  -- lantern
  fl(c, R(c, 13, 19, 13, 21), "#3d2a1c"); part(c, R(c, 12, 22, 14, 24), "#ffd86a")
  -- the cart at right piled with crates: leeks, eggs, jars
  part(c, R(c, 38, 36, 66, 42), "#8a5a35")
  fl(c, R(c, 38, 36, 66, 36), "#b07a45")
  part(c, c:ellipse(46, 45, 4, 4), "#6b3b2a"); c:fill(c:ellipse(46, 45, 1, 1), "#b07a45")
  part(c, c:ellipse(60, 45, 4, 4), "#6b3b2a"); c:fill(c:ellipse(60, 45, 1, 1), "#b07a45")
  part(c, c:line({ { 38, 38 }, { 30, 44 } }, 1), "#6b3b2a", { noline = true })
  -- crates on the cart
  part(c, R(c, 40, 28, 51, 36), "#c89258"); fl(c, R(c, 40, 31, 51, 31), "#8a5a35")
  for x = 41, 49, 2 do fl(c, R(c, x, 24, x, 28), "#6ab04a"); c:px(x + 1, 26, "#e8f0d0") end
  part(c, R(c, 53, 30, 64, 36), "#b07a45")
  for _, p in ipairs({ { 55, 29 }, { 59, 29 }, { 62, 29 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#f4eee0", { noline = true }) end
  part(c, R(c, 55, 22, 59, 27), "#a8d4e0"); fl(c, R(c, 55, 22, 59, 22), "#c0442e"); fl(c, R(c, 56, 24, 58, 26), "#d8402e")
  part(c, R(c, 60, 24, 64, 29), "#a8d4e0"); fl(c, R(c, 60, 24, 64, 24), "#e8a317"); fl(c, R(c, 61, 26, 63, 28), "#e8a317")
  -- unloaded stack beside the stall, gnome carrying a crate on his back-front
  part(c, R(c, 27, 40, 34, 47), "#c89258"); fl(c, R(c, 27, 43, 34, 43), "#8a5a35")
  for x = 28, 33, 2 do fl(c, R(c, x, 36, x, 40), "#6ab04a") end
  local _, G = gnome(c, 17, 48, { d = 1, walk = 1, eyes = "open", arms = { arm({ -4, 6 }, { 5, 5 }, false, true), arm({ 4, 6 }, { 5, 5 }, true) } })
  part(c, R(c, 13, 43, 24, 49), "#c89258"); fl(c, R(c, 13, 46, 24, 46), "#8a5a35")
  finish(c, "w2_dawn_carts")
end

-- 12. mind_stall: front-on, behind a jam stall, a customer waiting with a basket
function S.mind_stall()
  seed = 100
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#d8c8a0")
  c:bands(R(c, 0, 0, W - 1, 20), { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  c:fill(c:ellipse(60, 7, 8, 2), "#f4eee0")
  c:fill(c:ellipse(12, 21, 20, 5), "#5e8a44")
  c:fill(R(c, 0, 20, W - 1, 24), "#9a8a6a")
  awning(c, 4, 52, 5, 6, "#2f9a8a", "#f4eee0")
  part(c, R(c, 6, 11, 7, 38), "#8a5a35", { noline = true }); part(c, R(c, 49, 11, 50, 38), "#8a5a35", { noline = true })
  -- shelf of jam jars behind
  part(c, R(c, 8, 28, 48, 29), "#8a5a35", { noline = true })
  for x = 10, 44, 5 do
    local col = ({ "#c0442e", "#8a2e6a", "#e8a317", "#c0442e", "#4f9a45", "#8a2e6a", "#e8a317", "#c0442e" })[((x - 10) // 5) % 8 + 1]
    part(c, R(c, x, 23, x + 3, 28), col); fl(c, R(c, x, 22, x + 3, 22), "#f4eee0")
  end
  -- price board hanging (no words, just lines)
  part(c, R(c, 36, 13, 46, 20), "#f4eee0")
  for y = 15, 19, 2 do fl(c, R(c, 38, y, 44, y), "#8a5a35") end
  fl(c, R(c, 40, 11, 40, 13), "#3d2a1c"); fl(c, R(c, 43, 11, 43, 13), "#3d2a1c")
  -- ground + counter
  c:fill(R(c, 0, 41, W - 1, H - 1), "#a89880")
  part(c, R(c, 3, 36, 53, 49), "#b07a45")
  fl(c, R(c, 3, 36, 53, 36), "#d9a660"); fl(c, R(c, 3, 40, 53, 40), "#8a5a35")
  for x = 5, 51, 6 do fl(c, R(c, x, 41, x, 48), "#9a6a3a") end
  -- the stall-minder, holding up a jar
  gnome(c, 28, 38, { d = 1, upper = true, eyes = "happy", arms = { arm({ -5, 7 }, { -9, 9 }, true), arm({ 5, 7 }, { 8, 13 }, true) } })
  part(c, R(c, 34, 33, 38, 38), "#c0442e"); fl(c, R(c, 34, 32, 38, 32), "#f4eee0")
  -- on the counter: cash tin, jars, ribbon
  part(c, R(c, 8, 33, 15, 36), "#9a9aa4"); fl(c, R(c, 8, 33, 15, 33), "#cfd0d6"); fl(c, R(c, 11, 34, 12, 34), "#e8a317")
  part(c, R(c, 44, 32, 47, 36), "#8a2e6a"); fl(c, R(c, 44, 31, 47, 31), "#f4eee0")
  fl(c, R(c, 20, 35, 22, 35), "#e46a9b")
  -- customer on the right with a basket
  gnome(c, 63, 49, { d = -1, s = 0.9, hat = "#4f9a45", eyes = "open", arms = { arm({ 4, 6 }, { -2, 7 }, true) } })
  part(c, R(c, 58, 42, 65, 46), "#d9a660"); fl(c, R(c, 59, 40, 64, 41), "#a8703e"); fl(c, R(c, 59, 43, 64, 43), "#a8703e")
  finish(c, "w2_mind_stall")
end

-- 13. tot_takings: dusk, trestle with towers of coins, buttons and one acorn; pedlar's gnome checking a coin
function S.tot_takings()
  seed = 110
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#34305a", "#4a3a6a", "#6a4872", "#a05a78", "#d8806a", "#f0a870" }, { dir = "v" })
  for _, p in ipairs({ { 10, 8 }, { 24, 12 }, { 50, 8 }, { 62, 14 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(c:ellipse(12, 36, 26, 8), "#3a3a5a"); c:fill(c:ellipse(58, 36, 26, 8), "#34345a")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#7a8a58")
  c:fill(R(c, 0, 34, W - 1, 34), "#98a86a")
  for i = 1, 9 do local x, y = 3 + floor(rand() * 66), 38 + floor(rand() * 11); c:px(x, y, "#5e7a44"); c:px(x + 1, y - 1, "#5e7a44") end
  -- packed-up stall: poles and folded canvas at right
  part(c, R(c, 60, 12, 61, 40), "#6b4a2e", { noline = true })
  part(c, c:poly({ { 61, 14 }, { 70, 22 }, { 61, 24 } }), "#6a8a9a")
  -- lantern on the pole, lit
  fl(c, R(c, 56, 14, 60, 14), "#3d2a1c"); fl(c, R(c, 56, 14, 56, 16), "#3d2a1c")
  part(c, R(c, 54, 17, 58, 21), "#3d2a1c"); fl(c, R(c, 55, 18, 57, 20), "#ffe08a"); fl(c, R(c, 56, 19, 56, 19), "#fff8d8")
  for _, p in ipairs({ { 52, 15 }, { 60, 17 }, { 51, 20 }, { 53, 24 }, { 59, 24 } }) do c:px(p[1], p[2], "#f5cf6a") end
  -- trestle table seen from the side-front
  part(c, R(c, 26, 38, 58, 41), "#b07a45"); fl(c, R(c, 26, 38, 58, 38), "#d9a660")
  part(c, c:line({ { 30, 41 }, { 28, 49 } }, 2), "#6b4a2e", { noline = true }); part(c, c:line({ { 54, 41 }, { 56, 49 } }, 2), "#6b4a2e", { noline = true })
  -- coin towers (gold), button rows (pink/blue), and the acorn
  local function tower(x, n, col)
    for i = 0, n - 1 do part(c, R(c, x, 37 - i * 2, x + 3, 38 - i * 2), col) ; fl(c, R(c, x, 37 - i * 2, x + 3, 37 - i * 2), "#fff1c8") end
  end
  tower(30, 4, "#e8a317"); tower(35, 2, "#e8a317"); tower(40, 5, "#e8a317"); tower(45, 3, "#c8b8a0")
  -- spilled tin, buttons, acorn
  part(c, R(c, 50, 35, 56, 38), "#9a9aa4"); fl(c, R(c, 50, 35, 56, 35), "#cfd0d6")
  for _, p in ipairs({ { 51, 38 }, { 54, 38 }, { 56, 39 } }) do c:px(p[1], p[2], "#e46a9b") end
  part(c, c:ellipse(48, 36, 1, 1), "#c4623a"); fl(c, R(c, 47, 34, 49, 34), "#6b4a2e")
  -- the counter, seated gnome tapping one tower
  gnome(c, 17, 49, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 7 }, { 10, 9 }, true) } })
  -- the gnome is standing, small stool omitted: a hand reaching to the tower
  finish(c, "w2_tot_takings")
end

-- 14. chestnut_brazier: shaking the pan over glowing coals, chestnuts popping, a little queue with paper cones
function S.chestnut_brazier()
  seed = 120
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#9aa0aa", "#aab0b6", "#bcc0c0", "#cfc8b8" }, { dir = "v" })
  c:fill(c:ellipse(20, 8, 12, 2), "#d8dce0"); c:fill(c:ellipse(52, 13, 14, 2), "#cfd4d8")
  c:fill(c:ellipse(14, 34, 28, 7), "#8a6a44"); c:fill(c:ellipse(60, 35, 24, 6), "#7a5a3a")
  c:fill(R(c, 0, 33, W - 1, H - 1), "#a89880")
  for y = 38, 50, 4 do for x = ((y // 4) % 2) * 4, 70, 8 do fl(c, R(c, x, y, x + 4, y), "#8a7a64") end end
  fl(c, R(c, 0, 33, W - 1, 33), "#c8b898")
  -- bare-ish autumn tree and falling leaves
  part(c, R(c, 62, 14, 64, 34), "#5e3f28", { noline = true })
  part(c, c:ellipse(63, 11, 8, 6), "#d68a3a", { shade = true }); c:fill(c:ellipse(60, 9, 3, 2), "#e8a850"); c:px(66, 13, "#a8582f")
  for _, p in ipairs({ { 52, 20 }, { 57, 28 }, { 46, 14 }, { 12, 22 }, { 22, 14 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), (p[1] % 2 == 0) and "#d68a3a" or "#c0442e", { noline = true }) end
  -- brazier: bowl on three legs full of coals, with a mesh pan on a long handle
  part(c, c:line({ { 41, 43 }, { 39, 49 } }, 2), "#3d3d44", { noline = true }); part(c, c:line({ { 53, 43 }, { 55, 49 } }, 2), "#3d3d44", { noline = true }); fl(c, R(c, 46, 43, 47, 49), "#3d3d44")
  part(c, c:ellipse(47, 41, 9, 3), "#4a4a52", { shade = true })
  c:fill(c:ellipse(47, 40, 7, 2), "#e8601f")
  for _, p in ipairs({ { 43, 40 }, { 47, 39 }, { 51, 40 }, { 45, 41 }, { 49, 41 } }) do c:px(p[1], p[2], "#f5cf6a") end
  -- the roasting pan above the coals, chestnuts bouncing out
  part(c, c:ellipse(46, 35, 7, 2), "#5a5a62"); fl(c, R(c, 40, 35, 52, 35), "#8a8a92")
  for _, p in ipairs({ { 43, 33 }, { 46, 32 }, { 49, 33 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#8a4a1e", { noline = true }); c:px(p[1], p[2], "#e0b070") end
  for _, p in ipairs({ { 44, 27 }, { 50, 25 }, { 38, 30 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#8a4a1e", { noline = true }) end
  -- smoke / steam
  fl(c, R(c, 55, 32, 56, 33), "#e6e0d8"); fl(c, R(c, 56, 28, 57, 29), "#d6d0c8"); fl(c, R(c, 55, 24, 56, 25), "#cac4bc")
  -- the roaster: shaking the pan by its long handle
  gnome(c, 24, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { 3, 5 }, false), arm({ 4, 7 }, { 11, 9 }, true) } })
  fl(c, c:line({ { 35, 38 }, { 40, 36 } }, 2), "#6b4a2e")
  -- two queuers with cones at the right edge, one with a scarf
  gnome(c, 63, 49, { d = -1, s = 0.8, hat = "#4f9a45", eyes = "open", arms = { arm({ 4, 5 }, { -1, 7 }, true) } })
  part(c, c:poly({ { 56, 41 }, { 60, 41 }, { 58, 45 } }), "#f4eee0")
  finish(c, "w2_chestnut_brazier")
end

-- 15. kraut_crock: close-up, gnome pounding shredded cabbage in the big stoneware crock
function S.kraut_crock()
  seed = 130
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#c9b890")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 0, x, 38), "#b8a67c") end
  fl(c, R(c, 0, 10, W - 1, 11), "#8a5a35")
  c:fill(R(c, 0, 39, W - 1, H - 1), "#9a7a52")
  for y = 43, 52, 5 do fl(c, R(c, 0, y, W - 1, y), "#7a5a3a") end
  -- shelf with jars of finished pickle
  part(c, R(c, 4, 18, 34, 19), "#8a5a35", { noline = true })
  for x = 6, 30, 7 do part(c, R(c, x, 11, x + 4, 17), "#a8d4e0"); fl(c, R(c, x + 1, 13, x + 3, 16), "#c8d890"); fl(c, R(c, x, 11, x + 4, 11), "#8a5a35") end
  -- cabbages & salt on a board (left)
  part(c, R(c, 3, 41, 16, 44), "#b07a45"); fl(c, R(c, 3, 41, 16, 41), "#d9a660")
  part(c, c:ellipse(7, 39, 3, 3), "#5aa84e"); c:fill(c:ellipse(7, 39, 1, 1), "#a8e08a")
  part(c, c:ellipse(13, 39, 3, 3), "#7cc868"); c:fill(c:ellipse(13, 39, 1, 1), "#c8f0a8")
  part(c, R(c, 4, 46, 12, 49), "#f4eee0"); fl(c, R(c, 5, 46, 11, 46), "#cfd8e0")
  -- the crock (big, brown-glazed) with shreds heaped
  part(c, c:rrect(30, 37, 58, 54, 4), "#a8703e", { shade = true })
  fl(c, R(c, 31, 43, 57, 44), "#6b3b2a")
  for _, p in ipairs({ { 36, 47 }, { 44, 48 }, { 51, 47 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#c89258") end
  part(c, c:ellipse(44, 37, 15, 3), "#8a5a35")
  c:fill(c:ellipse(44, 37, 12, 2), "#d8e8a0")
  for _, p in ipairs({ { 36, 37 }, { 41, 36 }, { 46, 37 }, { 51, 36 }, { 39, 38 }, { 49, 38 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#a8c868") end
  fl(c, R(c, 38, 34, 41, 35), "#d8e8a0"); fl(c, R(c, 47, 34, 51, 35), "#d8e8a0")
  part(c, c:ellipse(63, 47, 4, 2), "#9a9ea6", { shade = true })
  -- gnome looming behind, both hands on the pounder
  local _, G = gnome(c, 19, 49, { d = 1, s = 1.4, eyes = "open", arms = { arm({ -4, 7 }, { 7, 12 }, false), arm({ 4, 7 }, { 8, 15 }, true) } })
  part(c, R(c, 27, 16, 29, 37), "#a8703e", { noline = true }); fl(c, R(c, 28, 17, 28, 36), "#c89258")
  part(c, R(c, 25, 14, 31, 17), "#a8703e")
  -- hands over the pounder
  fl(c, R(c, 26, 29, 30, 31), "#f0c8a0"); fl(c, R(c, 26, 25, 30, 26), "#f0c8a0")
  for _, p in ipairs({ { 36, 29 }, { 52, 30 }, { 41, 26 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#d8e8a0") end
  finish(c, "w2_kraut_crock")
end

local order = { "prop_branches", "windfall_toss", "wassail", "umbrella_duty", "crate_mixup", "river_drift", "dawn_tales", "pitch_tent", "ash_flatbread", "runaway_cabbages", "dawn_carts", "mind_stall", "tot_takings", "chestnut_brazier", "kraut_crock" }
local slugmap = { prop_branches = "w1_prop_branches", windfall_toss = "w1_windfall_toss", wassail = "w1_wassail", umbrella_duty = "w1_umbrella_duty", crate_mixup = "w1_crate_mixup", river_drift = "w1_river_drift", dawn_tales = "w1_dawn_tales", pitch_tent = "w1_pitch_tent", ash_flatbread = "w1_ash_flatbread", runaway_cabbages = "w2_runaway_cabbages", dawn_carts = "w2_dawn_carts", mind_stall = "w2_mind_stall", tot_takings = "w2_tot_takings", chestnut_brazier = "w2_chestnut_brazier", kraut_crock = "w2_kraut_crock" }
for _, s2 in ipairs(order) do
  if S[s2] and (not only or only == slugmap[s2] or only == s2) then seed = 7; S[s2]() end
end
