-- variety-act-h15.lua : Do-tab scenes for 24 Central/South Asia regional rest-stop activities -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-h15.lua   (params BEFORE --script)
-- gnome sprite + frame copied from variety-act-g5.lua
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
local S = {}

local function wave(c, x0, x1, y, col) for x = x0, x1 do if (x % 3) ~= 2 then c:px(x, y, col) end end end

-- 1. flower boat at dawn: gnome poling a boat heaped with marigolds and lotus
function S.r_csa_flower_boat(sl)
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 26), { "#f2a88e", "#f5b898", "#f8c8a0", "#fbdcb4" }, { dir = "v" })
  c:fill(c:ellipse(54, 26, 6, 6), "#fff0c0")
  c:fill(c:ellipse(12, 27, 18, 4), "#6f8a62"); c:fill(c:ellipse(62, 27, 14, 3), "#7a9468")
  c:bands(R(c, 0, 26, W - 1, H - 1), { "#6fb0b8", "#5aa0b0", "#4a90a8", "#3f84a0" }, { dir = "v" })
  wave(c, 8, 22, 29, "#c8e8e8"); wave(c, 44, 66, 31, "#c8e8e8"); wave(c, 6, 18, 49, "#8cc8d0"); wave(c, 48, 64, 48, "#8cc8d0")
  -- small far boat with lotus
  part(c, c:poly({ { 48, 29 }, { 66, 29 }, { 63, 32 }, { 51, 32 } }), "#a8582f")
  for i = 0, 3 do part(c, c:ellipse(51 + i * 4, 27, 2, 2), (i % 2 == 0) and "#e46a9b" or "#f4eee0", { noline = true }) end
  -- main boat
  part(c, c:poly({ { 8, 40 }, { 64, 40 }, { 58, 47 }, { 14, 47 } }), "#a8582f")
  fl(c, R(c, 9, 41, 63, 41), "#c87a42"); fl(c, R(c, 15, 45, 57, 45), "#8a4524")
  -- flower heap
  part(c, c:ellipse(46, 36, 15, 5), "#f08a24", { shade = true })
  for _, p in ipairs({ { 36, 33 }, { 42, 31 }, { 49, 31 }, { 55, 34 }, { 39, 37 }, { 52, 37 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#ffc83a") end
  for _, p in ipairs({ { 45, 35 }, { 56, 38 } }) do part(c, c:ellipse(p[1], p[2], 3, 2), "#e46a9b", { noline = true }); c:px(p[1], p[2], "#f6b8cf") end
  -- the pole, planted in the water
  c:fill(c:line({ { 25, 19 }, { 41, 50 } }, 2), "#7a4a2a")
  local _, G = gnome(c, 22, 40, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 8, 11 }, true), arm({ -3, 6 }, { 12, 6 }, true) } })
  wave(c, 34, 48, 49, "#c8e8e8")
  c:px(60, 33, "#ffc83a"); c:px(30, 35, "#ffc83a")
  finish(c, sl)
end

-- 2. two leaves and a bud: dawn on terraced tea slopes, gnome with a basket on his back picks a tip
function S.r_csa_two_leaves(sl)
  seed = 62
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#f4c8a0", "#f6d4a8", "#f8e0b8", "#e8e8c4" }, { dir = "v" })
  c:fill(c:ellipse(10, 18, 7, 7), "#fff0c0")
  c:fill(c:ellipse(52, 24, 30, 9), "#9ab890"); c:fill(c:ellipse(20, 26, 26, 8), "#8aac7a")
  -- terraces: stepped bands with rows of bushes
  local cols = { "#6a9a4a", "#5a8c3e", "#4e8a3c", "#3f7a34", "#356a2c" }
  for i = 0, 4 do
    local y = 24 + i * 6
    c:fill(R(c, 0, y, W - 1, y + 5), cols[i + 1])
    fl(c, R(c, 0, y, W - 1, y), "#8cc060")
    for x = (i % 2) * 3 + 2, W - 3, 6 do c:fill(c:ellipse(x, y + 3, 3, 1), (i % 2 == 0) and "#7ab05a" or "#6a9c4c") end
  end
  c:fill(R(c, 0, 48, W - 1, H - 1), "#5a3e28")
  -- gnome with a basket on his back (left), picking the tip of a bush
  part(c, R(c, 14, 31, 19, 41), "#c8923e"); fl(c, R(c, 15, 34, 18, 34), "#a8702a"); fl(c, R(c, 15, 38, 18, 38), "#a8702a")
  fl(c, R(c, 15, 30, 18, 31), "#6ab04a")
  local _, G = gnome(c, 26, 46, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 9, 11 }, true) } })
  -- the picked shoot: two leaves and a bud
  local hx, hy = G.P(10, 11)
  fl(c, R(c, hx + 1, hy - 5, hx + 2, hy - 2), "#9ad46a")
  fl(c, R(c, hx - 1, hy - 4, hx, hy - 3), "#6ab04a"); fl(c, R(c, hx + 3, hy - 4, hx + 4, hy - 3), "#6ab04a")
  fl(c, R(c, hx + 1, hy - 7, hx + 2, hy - 6), "#d8f0a0")
  -- the bush being picked
  part(c, c:ellipse(42, 43, 9, 5), "#3f8a3e", { shade = true })
  for _, p in ipairs({ { 38, 41 }, { 42, 39 }, { 46, 41 }, { 40, 44 }, { 45, 44 } }) do c:px(p[1], p[2], "#9ad46a"); c:px(p[1] + 1, p[2], "#9ad46a") end
  -- a few more sprouts as sparkle
  c:px(58, 40, "#d8f0a0"); c:px(63, 44, "#d8f0a0"); c:px(55, 46, "#d8f0a0")
  finish(c, sl)
end

-- 3. spice mats in the first monsoon rain: gnome runs with a tarp held overhead
function S.r_csa_spice_mats(sl)
  seed = 63
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#5e6a7c", "#6e7a8a", "#7e8a98", "#8e9aa6" }, { dir = "v" })
  c:fill(c:ellipse(16, 8, 14, 5), "#4a5568"); c:fill(c:ellipse(50, 6, 16, 5), "#444e60"); c:fill(c:ellipse(36, 14, 12, 3), "#56627a")
  c:fill(c:ellipse(18, 31, 30, 8), "#4e6a4a"); c:fill(c:ellipse(60, 32, 24, 7), "#46604a")
  c:fill(R(c, 0, 30, W - 1, H - 1), "#7a6248")
  c:fill(R(c, 0, 30, W - 1, 30), "#6a5640")
  -- mats of chilies (red) and turmeric (yellow) and coriander (green)
  local function mat(x0, y0, x1, y1, col, dot)
    part(c, R(c, x0, y0, x1, y1), "#c8a468")
    c:fill(R(c, x0 + 1, y0 + 1, x1 - 1, y1 - 1), col)
    for i = 0, 6 do c:px(x0 + 2 + (i * 5) % (x1 - x0 - 3), y0 + 1 + (i * 3) % (y1 - y0 - 1), dot) end
  end
  mat(6, 33, 24, 38, "#c8321e", "#e8603a")
  mat(46, 32, 64, 37, "#e8a317", "#f8d058")
  mat(8, 42, 22, 47, "#4e8a3c", "#8cc060")
  mat(48, 42, 64, 47, "#c8321e", "#e8603a")
  -- the tarp overhead, gnome running underneath
  local _, G = gnome(c, 34, 47, { d = 1, walk = 1, eyes = "open", arms = { arm({ -4, 9 }, { -8, 24 }, false), arm({ 4, 9 }, { 8, 24 }, true) } })
  local ax, ay = G.P(-9, 26); local bx, by = G.P(10, 26)
  part(c, c:poly({ { ax - 4, ay }, { bx + 5, by - 1 }, { bx + 3, by + 3 }, { ax - 2, ay + 4 } }), "#3f78b0")
  fl(c, R(c, ax, ay + 1, bx + 3, ay + 1), "#6ea0d0")
  -- rain streaks
  seed = 17
  for i = 1, 46 do
    local x, y = 6 + floor(rand() * 62), 6 + floor(rand() * 42)
    c:px(x, y, "#cfe0ee"); c:px(x - 1, y + 1, "#cfe0ee")
  end
  finish(c, sl)
end

-- 4. yak on the pass: gnome hauls on a rope, the yak stops to think, prayer flags snap overhead
function S.r_csa_yak_pass(sl)
  seed = 64
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#90b4d4", "#a4c4de", "#b8d4e6", "#cce2ee" }, { dir = "v" })
  c:fill(c:poly({ { 0, 34 }, { 14, 14 }, { 24, 24 }, { 36, 10 }, { 52, 30 }, { 62, 18 }, { 72, 32 }, { 72, 34 } }), "#c8d8e6")
  c:fill(c:poly({ { 14, 14 }, { 17, 20 }, { 11, 20 } }), "#f4f8fa"); c:fill(c:poly({ { 36, 10 }, { 40, 18 }, { 32, 18 } }), "#f4f8fa"); c:fill(c:poly({ { 62, 18 }, { 65, 24 }, { 59, 24 } }), "#f4f8fa")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#a8a8a0")
  c:fill(R(c, 0, 34, W - 1, 35), "#e8eef2")
  for _, p in ipairs({ { 8, 40 }, { 20, 46 }, { 50, 44 }, { 62, 48 } }) do c:fill(c:ellipse(p[1], p[2], 3, 1), "#e8eef2") end
  -- cairn with a flag string
  part(c, c:ellipse(66, 33, 4, 3), "#8b8f96", { shade = true }); part(c, c:ellipse(66, 29, 3, 2), "#9a9ea6", { shade = true })
  fl(c, R(c, 66, 12, 66, 28), "#5e3f28")
  c:fill(c:line({ { 6, 8 }, { 20, 12 }, { 36, 9 }, { 52, 13 }, { 66, 12 } }, 1), "#5e3f28")
  local fc = { "#3f78b0", "#f4eee0", "#dd3a2a", "#4e9a48", "#f5cf6a" }
  for i, f in ipairs({ { 9, 9 }, { 14, 11 }, { 20, 12 }, { 26, 11 }, { 32, 10 }, { 38, 10 }, { 44, 12 }, { 50, 13 }, { 56, 13 }, { 61, 13 } }) do
    fl(c, R(c, f[1], f[2], f[1] + 3, f[2] + 3), fc[(i - 1) % 5 + 1]); c:px(f[1] + 4, f[2] + ((i % 2 == 0) and 1 or 2), fc[(i - 1) % 5 + 1])
  end
  -- the yak: shaggy dark body, horns, loaded packs
  part(c, c:ellipse(50, 41, 13, 7), "#3a2a22", { shade = true })
  part(c, c:ellipse(39, 40, 6, 5), "#4a342a")
  fl(c, R(c, 34, 40, 36, 41), "#e8ddc8")
  c:px(37, 38, "#e8ddc8"); c:px(35, 43, "#d8a8a0")
  fl(c, R(c, 32, 33, 33, 36), "#e8ddc8"); fl(c, R(c, 31, 32, 32, 33), "#e8ddc8"); fl(c, R(c, 43, 33, 44, 36), "#e8ddc8"); fl(c, R(c, 44, 32, 45, 33), "#e8ddc8")
  for _, x in ipairs({ 42, 48, 54, 59 }) do part(c, R(c, x, 44, x + 2, 49), "#3a2a22", { noline = true }); fl(c, R(c, x, 49, x + 2, 49), "#e8eef2") end
  fl(c, R(c, 40, 46, 62, 47), "#2a1c16")
  part(c, R(c, 44, 31, 54, 38), "#c0442e"); part(c, R(c, 55, 32, 62, 38), "#c8923e")
  fl(c, R(c, 45, 34, 53, 34), "#f5cf6a")
  -- rope and gnome leaning hard, scarf flying
  local gx = 16
  c:fill(c:line({ { 21, 36 }, { 34, 40 } }, 1), "#a8703e")
  local _, G = gnome(c, gx, 47, { d = 1, walk = -1, s = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 6 }, true) } })
  fl(c, R(c, 10, 38, 16, 38), "#dd3a2a"); fl(c, R(c, 6, 37, 9, 37), "#dd3a2a")
  seed = 8
  for i = 1, 18 do local x, y = 6 + floor(rand() * 40), 6 + floor(rand() * 40); fl(c, R(c, x, y, x + 2, y), "#fbfdfe") end
  finish(c, sl)
end

-- 5. snow leopard spotting: gnome on a tower ledge with a spyglass, a spotted cat half-hidden in the rocks
function S.r_csa_leopard_spot(sl)
  seed = 65
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#98bcd8", "#aac8e0", "#bcd6e8", "#d0e4ee" }, { dir = "v" })
  c:fill(c:poly({ { 20, 30 }, { 34, 8 }, { 46, 20 }, { 56, 12 }, { 72, 28 }, { 72, 30 } }), "#b4c4d4")
  c:fill(c:poly({ { 34, 8 }, { 38, 15 }, { 30, 15 } }), "#f4f8fa"); c:fill(c:poly({ { 56, 12 }, { 60, 18 }, { 52, 18 } }), "#f4f8fa")
  c:fill(R(c, 0, 30, W - 1, H - 1), "#6c6a68")
  -- rocky ledges on the right
  part(c, c:poly({ { 30, 30 }, { 72, 26 }, { 72, 40 }, { 34, 40 } }), "#8e8c88", { shade = true })
  part(c, c:poly({ { 26, 40 }, { 72, 38 }, { 72, 50 }, { 26, 50 } }), "#7c7a78", { shade = true })
  for _, p in ipairs({ { 40, 31 }, { 62, 30 }, { 50, 44 }, { 66, 46 } }) do fl(c, R(c, p[1], p[2], p[1] + 4, p[2]), "#a4a29c") end
  -- the snow leopard, grey on grey
  part(c, c:ellipse(52, 36, 8, 3), "#b8b8b4", { noline = true })
  part(c, c:ellipse(45, 34, 3, 3), "#c4c4c0", { noline = true })
  fl(c, R(c, 44, 31, 44, 32), "#c4c4c0"); fl(c, R(c, 47, 31, 47, 32), "#c4c4c0")
  c:px(44, 34, "#e8c840"); c:px(46, 34, "#e8c840"); c:px(45, 36, "#6a5a50")
  for _, p in ipairs({ { 50, 35 }, { 54, 34 }, { 57, 36 }, { 52, 37 }, { 60, 35 } }) do c:px(p[1], p[2], "#5a5a5e"); c:px(p[1] + 1, p[2], "#5a5a5e") end
  fl(c, R(c, 60, 34, 66, 35), "#b8b8b4"); fl(c, R(c, 66, 32, 67, 34), "#b8b8b4"); c:px(64, 35, "#5a5a5e")
  -- tower ledge in the foreground: timber platform with rail
  part(c, R(c, 0, 40, 26, 44), "#a8703e")
  fl(c, R(c, 1, 40, 25, 40), "#c8923e")
  part(c, R(c, 2, 45, 4, 54), "#6b3b2a", { noline = true }); part(c, R(c, 22, 45, 24, 54), "#6b3b2a", { noline = true })
  part(c, R(c, 0, 32, 1, 40), "#8a5a35", { noline = true }); fl(c, R(c, 0, 33, 24, 34), "#8a5a35")
  local _, G = gnome(c, 14, 40, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 9, 11 }, true), arm({ -3, 7 }, { 5, 10 }, true) } })
  -- spyglass pointing at the cat
  local sx, sy = G.P(7, 11)
  c:fill(c:line({ { sx, sy }, { sx + 14, sy + 5 } }, 3), "#c8923e")
  fl(c, R(c, sx + 14, sy + 3, sx + 15, sy + 7), "#e8c840")
  c:fill(c:line({ { sx + 2, sy - 1 }, { sx + 5, sy } }, 1), "#8a5a35")
  c:px(30, 24, "#fff1c8"); c:px(66, 8, "#fff1c8"); c:px(10, 14, "#f4eee0")
  -- spring flowers on the rocks
  for _, p in ipairs({ { 36, 41 }, { 58, 48 }, { 30, 47 } }) do c:px(p[1], p[2], "#e46a9b"); c:px(p[1], p[2] + 1, "#4e8a3c") end
  finish(c, sl)
end

-- 6. buffalo on the ferry: the beast sits tight on the deck, gnome tugs the rope from the bank, queue waits
function S.r_csa_buffalo_ramp(sl)
  seed = 66
  local c = new()
  day(c, 24, { cloud = 44, hill = "#5e8a44", hill2 = "#4e8a3c" })
  c:bands(R(c, 0, 24, W - 1, H - 1), { "#7ab8a0", "#6aa890", "#5a9c88", "#4e9080" }, { dir = "v" })
  wave(c, 30, 44, 28, "#c8e8e0"); wave(c, 52, 66, 33, "#a8d8c8"); wave(c, 40, 50, 47, "#a8d8c8")
  -- bank with the queue
  c:fill(c:poly({ { 5, 36 }, { 24, 34 }, { 28, 49 }, { 5, 49 } }), "#9a8a5c"); fl(c, R(c, 5, 34, 24, 35), "#b8a874")
  c:fill(R(c, 5, 36, 24, 40), "#8a8050")
  -- ferry: flat raft with posts
  part(c, c:poly({ { 28, 39 }, { 66, 39 }, { 63, 46 }, { 31, 46 } }), "#a8703e")
  for x = 32, 62, 6 do fl(c, R(c, x, 40, x, 45), "#7a4a2a") end
  fl(c, R(c, 29, 40, 65, 40), "#c8923e")
  part(c, R(c, 28, 32, 29, 39), "#6b3b2a", { noline = true }); part(c, R(c, 64, 32, 65, 39), "#6b3b2a", { noline = true })
  -- buffalo sitting comfortably in the middle
  part(c, c:ellipse(49, 34, 12, 5), "#5a5a62", { shade = true })
  part(c, c:ellipse(40, 33, 5, 4), "#6a6a72")
  fl(c, R(c, 36, 31, 39, 32), "#8a8a94"); c:px(38, 33, "#2a1a10"); c:px(36, 36, "#d8a8a0")
  c:fill(c:line({ { 41, 29 }, { 34, 27 }, { 31, 30 } }, 1), "#e8ddc8"); c:fill(c:line({ { 45, 29 }, { 52, 26 }, { 55, 29 } }, 1), "#e8ddc8")
  fl(c, R(c, 56, 34, 60, 36), "#5a5a62"); c:px(60, 37, "#4a4a52")
  fl(c, R(c, 44, 38, 54, 38), "#4a4a52")
  -- gnome pulling a rope, queue of two little ones behind
  c:fill(c:line({ { 22, 33 }, { 37, 36 } }, 1), "#a8703e")
  gnome(c, 8, 40, { d = 1, s = 0.7, upper = false, hat = "#4f9a45", eyes = "open" })
  gnome(c, 15, 42, { d = 1, s = 0.7, hat = "#e8a317", eyes = "open" })
  gnome(c, 20, 49, { d = 1, walk = -1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 7 }, true) } })
  finish(c, sl)
end

-- 7. turmeric grating: indoors, a close big gnome grinds a root on a tin grater, yellow hands, golden heap
function S.r_csa_turmeric_grate(sl)
  seed = 67
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 34), "#d8b878")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 0, x, 34), "#c8a468") end
  fl(c, R(c, 0, 14, W - 1, 14), "#b8945a")
  -- shelf with jars
  part(c, R(c, 40, 17, 68, 18), "#8a5a35")
  for i, x in ipairs({ 42, 48, 54, 60 }) do part(c, R(c, x, 11, x + 4, 16), ({ "#e8a317", "#c8321e", "#4e8a3c", "#e8a317" })[i]); fl(c, R(c, x + 1, 10, x + 3, 10), "#8a5a35") end
  -- hanging string of chilies
  fl(c, R(c, 8, 6, 8, 8), "#5e3f28")
  for i = 0, 4 do fl(c, R(c, 7, 8 + i * 3, 9, 9 + i * 3), "#c8321e") end
  c:fill(R(c, 0, 35, W - 1, H - 1), "#a8703e")
  -- big gnome behind the table
  local _, G = gnome(c, 26, 44, { d = 1, upper = true, s = 1.4, eyes = "open", arms = { arm({ 4, 7 }, { 8, 8 }, true) } })
  part(c, R(c, 3, 40, 68, 44), "#b07a45")
  fl(c, R(c, 3, 40, 68, 40), "#d9a660")
  part(c, R(c, 6, 45, 9, 52), "#8a5a35", { noline = true }); part(c, R(c, 62, 45, 65, 52), "#8a5a35", { noline = true })
  -- the grater: angled tin plate with holes
  part(c, c:poly({ { 36, 40 }, { 50, 40 }, { 46, 27 }, { 40, 27 } }), "#aeb4bc")
  for _, p in ipairs({ { 42, 30 }, { 44, 30 }, { 41, 33 }, { 43, 33 }, { 45, 33 }, { 40, 36 }, { 42, 36 }, { 44, 36 }, { 46, 36 } }) do c:px(p[1], p[2], "#6a717a") end
  -- the root in yellow hands
  part(c, c:ellipse(43, 30, 5, 2), "#e8a317")
  fl(c, R(c, 39, 29, 41, 31), "#f8d058"); fl(c, R(c, 46, 29, 48, 31), "#f8d058")
  -- gold heap and a yellow-streaked bowl
  part(c, c:ellipse(57, 39, 7, 3), "#f8c020", { shade = true })
  for _, p in ipairs({ { 54, 37 }, { 58, 36 }, { 61, 38 }, { 56, 39 } }) do c:px(p[1], p[2], "#ffe070") end
  part(c, c:ellipse(18, 40, 5, 1), "#8b8f96"); fl(c, R(c, 14, 38, 22, 39), "#e8a317")
  c:px(30, 34, "#f8c020"); c:px(34, 33, "#f8c020"); c:px(68 - 6, 44, "#f8c020")
  finish(c, sl)
end

-- 8. winnowing: gnome tosses wheat from a flat basket, the wind carries the chaff off
function S.r_csa_threshing_floor(sl)
  seed = 68
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 31), { "#c8d8d0", "#d8e0cc", "#e8e4c0", "#f0e8b8" }, { dir = "v" })
  c:fill(c:ellipse(12, 33, 28, 9), "#b8a060"); c:fill(c:ellipse(58, 34, 28, 8), "#a89458")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#c0a868")
  c:fill(R(c, 0, 31, W - 1, 31), "#d8c888")
  -- threshing floor: packed-earth disc with a small mill shed behind
  c:fill(c:ellipse(36, 46, 33, 7), "#d4b87c"); c:fill(c:ellipse(36, 46, 27, 5), "#dcc48c")
  part(c, R(c, 52, 19, 66, 30), "#b07a45"); part(c, c:poly({ { 50, 20 }, { 59, 13 }, { 68, 20 } }), "#c0442e")
  part(c, R(c, 56, 24, 60, 30), "#5e3f28")
  -- wheat sheaves
  for i = 0, 2 do part(c, c:poly({ { 8 + i * 6, 40 }, { 10 + i * 6, 31 }, { 12 + i * 6, 40 } }), "#e8c048"); fl(c, R(c, 8 + i * 6, 37, 12 + i * 6, 37), "#a8702a") end
  local _, G = gnome(c, 34, 47, { d = 1, eyes = "open", arms = { arm({ -3, 8 }, { 5, 8 }, true, true), arm({ 3, 9 }, { 9, 11 }, true, true) } })
  -- flat round basket tilted, held in both hands
  local bx, by = G.P(7, 9)
  part(c, c:poly({ { bx - 6, by + 3 }, { bx + 8, by - 1 }, { bx + 8, by + 1 }, { bx - 6, by + 5 } }), "#c8923e")
  fl(c, R(c, bx - 4, by + 4, bx + 6, by + 1), "#a8702a")
  -- tossed grain arcs up, chaff blows away on the wind
  for _, p in ipairs({ { 41, 29 }, { 43, 24 }, { 45, 28 }, { 47, 22 }, { 39, 25 }, { 44, 19 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#e8b838") end
  for _, p in ipairs({ { 49, 24 }, { 53, 21 }, { 58, 26 }, { 61, 20 }, { 55, 28 }, { 64, 25 }, { 50, 17 }, { 62, 15 } }) do
    fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#f4eed0"); c:px(p[1] - 2, p[2], "#f4eed0")
  end
  for _, p in ipairs({ { 52, 34 }, { 60, 33 }, { 66, 36 } }) do fl(c, R(c, p[1], p[2], p[1] + 4, p[2]), "#f4eed0") end
  finish(c, sl)
end

-- 9. monkey and the sandal: shrine wall, monkey wears a sandal as a hat, gnome offers a mango
function S.r_csa_monkey_sandal(sl)
  seed = 69
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#8cc4b0", "#a0d0b4", "#b4dcb8", "#c8e4bc" }, { dir = "v" })
  -- jungle canopy and leaf fronds
  c:fill(c:ellipse(8, 8, 14, 9), "#2f6a38"); c:fill(c:ellipse(60, 6, 18, 9), "#356e3a"); c:fill(c:ellipse(34, 4, 12, 5), "#3f7a40")
  for _, p in ipairs({ { 14, 15 }, { 6, 16 }, { 62, 14 }, { 68, 16 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2] + 4), "#4e9a48") end
  c:fill(R(c, 0, 30, W - 1, H - 1), "#5e8a44")
  -- shrine wall with a tiny red-roofed shrine
  part(c, R(c, 30, 28, 70, 38), "#b4aea0", { shade = true })
  for x = 34, 66, 8 do fl(c, R(c, x, 28, x, 38), "#8e887c") end
  fl(c, R(c, 31, 33, 69, 33), "#8e887c")
  part(c, R(c, 54, 18, 64, 28), "#e8d2a0"); part(c, R(c, 58, 21, 60, 28), "#5e3f28")
  part(c, c:poly({ { 59, 11 }, { 67, 18 }, { 51, 18 } }), "#c0442e")
  fl(c, R(c, 59, 9, 59, 10), "#f5cf6a")
  -- monkey on the wall wearing a sandal as a hat
  part(c, c:ellipse(40, 25, 5, 4), "#8a5a35", { shade = true })
  part(c, c:ellipse(40, 19, 4, 4), "#8a5a35")
  c:fill(c:ellipse(40, 20, 3, 2), "#e8c4a0"); c:px(39, 19, "#2a1a10"); c:px(41, 19, "#2a1a10")
  fl(c, R(c, 35, 18, 36, 20), "#e8c4a0"); fl(c, R(c, 44, 18, 45, 20), "#e8c4a0")
  part(c, c:ellipse(40, 14, 4, 2), "#d9a660"); fl(c, R(c, 37, 13, 43, 13), "#f0c890"); fl(c, R(c, 39, 11, 41, 12), "#3f78b0")
  fl(c, R(c, 45, 26, 49, 27), "#8a5a35"); fl(c, R(c, 49, 22, 50, 26), "#8a5a35"); fl(c, R(c, 48, 21, 49, 22), "#8a5a35")
  fl(c, R(c, 36, 28, 37, 30), "#8a5a35")
  -- gnome holds up a mango in trade
  local _, G = gnome(c, 18, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 14 }, true, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  local mx, my = G.P(10, 15)
  part(c, c:ellipse(mx, my - 1, 3, 3), "#f08a24", { shade = true }); fl(c, R(c, mx - 1, my - 3, mx, my - 3), "#f5cf6a"); fl(c, R(c, mx, my - 5, mx + 1, my - 4), "#4e8a3c")
  fl(c, R(c, mx - 2, my + 1, mx + 1, my + 2), "#f0c8a0")
  c:px(28, 30, "#f5cf6a"); c:px(30, 22, "#f5cf6a")
  finish(c, sl)
end

-- 10. great dip-net: long beam over the water, net hanging low, counterweight stones, gnomes hauling
function S.r_csa_dip_net(sl)
  seed = 70
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 24), { "#a8d4dc", "#bce0e0", "#d0e8e0", "#e0eed8" }, { dir = "v" })
  c:fill(c:ellipse(10, 25, 18, 5), "#6a9a60"); c:fill(c:ellipse(58, 26, 20, 4), "#7aa868")
  c:bands(R(c, 0, 25, W - 1, H - 1), { "#6fb8b4", "#5ca8a8", "#4e9aa0", "#448e98" }, { dir = "v" })
  wave(c, 40, 60, 28, "#c8ecec"); wave(c, 28, 40, 42, "#8cccd0"); wave(c, 58, 68, 47, "#8cccd0")
  -- lotus pads
  for _, p in ipairs({ { 48, 45 }, { 60, 40 }, { 36, 48 } }) do c:fill(c:ellipse(p[1], p[2], 3, 1), "#4e9a48") end
  c:px(60, 39, "#e46a9b"); c:px(61, 39, "#f6b8cf")
  -- shore platform with post
  part(c, R(c, 2, 38, 36, 42), "#a8703e"); fl(c, R(c, 3, 38, 35, 38), "#c8923e")
  part(c, R(c, 6, 43, 8, 54), "#6b3b2a", { noline = true }); part(c, R(c, 30, 43, 32, 54), "#6b3b2a", { noline = true })
  part(c, R(c, 29, 13, 31, 38), "#6b3b2a")
  -- the beam, pivoting on the post, long end out over the water
  c:fill(c:line({ { 8, 21 }, { 62, 3 } }, 2), "#8a5a35")
  c:outline(c:line({ { 8, 21 }, { 62, 3 } }, 2))
  -- counterweight basket of stones hanging at the short end
  fl(c, R(c, 8, 22, 8, 25), "#5e3f28")
  part(c, R(c, 4, 25, 12, 30), "#c8923e"); fl(c, R(c, 5, 27, 11, 27), "#a8702a")
  for _, x in ipairs({ 5, 8, 11 }) do part(c, c:ellipse(x, 25, 2, 1), "#8b8f96", { noline = true }) end
  -- net hanging from the beam end down to the water
  for _, x in ipairs({ 52, 66 }) do c:fill(c:line({ { 62, 4 }, { x, 36 } }, 1), "#5e3f28") end
  part(c, c:poly({ { 50, 36 }, { 68, 36 }, { 66, 40 }, { 52, 40 } }), "#c8b88a")
  for x = 53, 65, 3 do fl(c, R(c, x, 36, x, 40), "#8a7a52") end
  fl(c, R(c, 51, 38, 67, 38), "#8a7a52")
  -- gnomes leaning on the haul rope
  c:fill(c:line({ { 8, 30 }, { 14, 28 }, { 20, 28 } }, 1), "#a8703e")
  gnome(c, 22, 38, { d = -1, s = 0.9, hat = "#c0442e", eyes = "open", arms = { arm({ -3, 8 }, { -8, 10 }, true) } })
  gnome(c, 15, 38, { d = -1, s = 0.9, hat = "#e8a317", eyes = "open", arms = { arm({ -3, 8 }, { -8, 10 }, true) } })
  finish(c, sl)
end

-- 11. mango chutney: marketplace lane, a big pan simmering, long spoon stirring, mangoes and ginger by
function S.r_csa_mango_chutney(sl)
  seed = 71
  local c = new()
  day(c, 31, { cloud = 50, sky = { "#bcdce0", "#cce6e0", "#dceede" } })
  -- market awning at the back
  local n = 0
  for x = 6, 66, 6 do fl(c, R(c, x, 12, x + 5, 17), (n % 2 == 0) and "#e8a317" or "#c0442e"); fl(c, R(c, x + 1, 18, x + 4, 18), (n % 2 == 0) and "#e8a317" or "#c0442e"); n = n + 1 end
  c:outline(R(c, 6, 12, 71 - 6, 18))
  part(c, R(c, 6, 18, 8, 34), "#8a5a35", { noline = true }); part(c, R(c, 63, 18, 65, 34), "#8a5a35", { noline = true })
  c:fill(R(c, 0, 31, W - 1, H - 1), "#d4b880")
  for _, p in ipairs({ { 8, 44 }, { 20, 49 }, { 40, 50 }, { 64, 47 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#b89a60") end
  -- stove with fire and a big pan
  part(c, R(c, 38, 40, 66, 47), "#a06a3c"); for x = 42, 62, 6 do fl(c, R(c, x, 41, x, 46), "#7a4a2a") end
  c:fill(c:poly({ { 44, 47 }, { 46, 44 }, { 48, 47 } }), "#f08a24"); c:fill(c:poly({ { 54, 47 }, { 56, 43 }, { 58, 47 } }), "#f08a24"); c:px(56, 46, "#ffd86a")
  part(c, c:ellipse(52, 36, 14, 5), "#3a3a42", { shade = true })
  c:fill(c:ellipse(52, 35, 11, 3), "#e07a1a")
  for _, p in ipairs({ { 46, 35 }, { 52, 34 }, { 57, 36 }, { 49, 36 }, { 55, 33 } }) do c:px(p[1], p[2], "#ffd070"); c:px(p[1] + 1, p[2], "#ffd070") end
  fl(c, R(c, 38, 36, 40, 37), "#2a2a30"); fl(c, R(c, 64, 36, 66, 37), "#2a2a30")
  -- gnome stirring with a long spoon, steam and scent curls
  local _, G = gnome(c, 24, 47, { d = 1, eyes = "shut", arms = { arm({ 4, 9 }, { 9, 12 }, true), arm({ -3, 6 }, { 6, 8 }, true) } })
  c:fill(c:line({ { 33, 28 }, { 50, 37 } }, 2), "#8a5a35")
  c:fill(c:line({ { 24, 25 }, { 33, 28 } }, 1), "#8a5a35")
  for i = 0, 3 do fl(c, R(c, 50 + (i % 2) * 2, 28 - i * 4, 51 + (i % 2) * 2, 29 - i * 4), "#f4f8fa") end
  -- mangoes and ginger on a low table
  part(c, R(c, 2, 42, 18, 44), "#a8703e"); part(c, R(c, 4, 44, 5, 49), "#8a5a35", { noline = true }); part(c, R(c, 15, 44, 16, 49), "#8a5a35", { noline = true })
  part(c, c:ellipse(6, 40, 3, 2), "#f5b030", { shade = true }); part(c, c:ellipse(11, 40, 3, 2), "#f08a24", { shade = true })
  part(c, c:ellipse(15, 41, 2, 1), "#d9b070"); c:px(6, 38, "#4e8a3c"); c:px(11, 38, "#4e8a3c")
  finish(c, sl)
end

-- 12. mung dal about to boil over: startled gnome, foam climbing the pot, beans sacked by the mill
function S.r_csa_mung_dal(sl)
  seed = 72
  local c = new()
  day(c, 33, { cloud = 14, sky = { "#c8dce0", "#d8e6dc", "#e6ece0" } })
  -- little mill with a wheel behind on the right
  part(c, R(c, 48, 14, 66, 33), "#e8d2a0"); part(c, c:poly({ { 46, 15 }, { 57, 6 }, { 68, 15 } }), "#8a5a35")
  part(c, R(c, 55, 24, 59, 33), "#5e3f28"); part(c, R(c, 51, 19, 53, 22), "#3f78b0", { noline = true })
  -- campfire under a pot
  c:fill(c:ellipse(30, 47, 14, 3), "#6a4a30")
  part(c, c:line({ { 20, 47 }, { 40, 45 } }, 2), "#6b3b2a"); part(c, c:line({ { 20, 45 }, { 40, 47 } }, 2), "#8a5a35")
  c:fill(c:poly({ { 24, 46 }, { 26, 39 }, { 28, 44 }, { 30, 37 }, { 32, 44 }, { 35, 40 }, { 36, 46 } }), "#e0501f")
  c:fill(c:poly({ { 28, 46 }, { 30, 41 }, { 32, 46 } }), "#ffd86a")
  -- the pot with yellow foam sliding over the rim
  part(c, c:rrect(19, 24, 41, 40, 4), "#3a3a42", { shade = true })
  fl(c, R(c, 17, 27, 19, 28), "#2a2a30"); fl(c, R(c, 41, 27, 43, 28), "#2a2a30")
  part(c, c:ellipse(30, 24, 11, 3), "#4a4a52")
  c:fill(c:ellipse(30, 23, 9, 2), "#f5cf6a")
  for _, p in ipairs({ { 23, 20 }, { 28, 18 }, { 33, 19 }, { 37, 21 }, { 26, 21 }, { 31, 17 } }) do c:fill(c:ellipse(p[1], p[2], 2, 2), "#f8e48a"); c:px(p[1] - 1, p[2] - 1, "#fff8d0") end
  fl(c, R(c, 20, 24, 22, 31), "#f8d058"); fl(c, R(c, 38, 24, 40, 33), "#f8d058"); fl(c, R(c, 38, 34, 39, 35), "#f8d058")
  fl(c, R(c, 29, 25, 30, 28), "#f8d058")
  -- startled gnome with a spoon, mouth agape
  local _, G = gnome(c, 54, 47, { d = -1, eyes = "open", arms = { arm({ -4, 8 }, { -10, 15 }, true), arm({ 4, 7 }, { 8, 14 }, false) } })
  local sx, sy = G.P(10, 15)
  c:fill(c:line({ { 48, 26 }, { 40, 20 } }, 1), "#8a5a35")
  c:fill(c:line({ { sx - 2, sy }, { sx - 6, sy - 5 } }, 1), "#8a5a35")
  -- bean sack
  part(c, c:ellipse(8, 44, 5, 5), "#d8b878", { shade = true }); fl(c, R(c, 6, 38, 10, 39), "#a8702a")
  c:fill(c:ellipse(8, 47, 7, 1), "#e8c048"); for _, p in ipairs({ { 4, 48 }, { 11, 49 }, { 14, 48 } }) do c:px(p[1], p[2], "#e8c048") end
  for _, p in ipairs({ { 20, 14 }, { 36, 12 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 2), "#f4f8fa") end
  finish(c, sl)
end

-- 13. jackfruit: a gnome-sized spiky fruit split open on a table, golden pods, knife, melon and mango beside
function S.r_csa_jackfruit_carve(sl)
  seed = 73
  local c = new()
  day(c, 30, { cloud = 56, sky = { "#c0e0d8", "#d0e8d8", "#e0f0d8" } })
  -- palm trunk and fronds at the back-left
  part(c, R(c, 8, 12, 10, 34), "#8a5a35", { noline = true })
  for _, p in ipairs({ { 2, 10, 8, 14 }, { 10, 8, 16, 14 }, { 4, 6, 9, 10 }, { 10, 5, 15, 9 } }) do c:fill(c:line({ { p[1], p[2] }, { p[3], p[4] } }, 2), "#3f8a42") end
  c:fill(R(c, 0, 30, W - 1, H - 1), "#a8703e")
  fl(c, R(c, 0, 30, W - 1, 30), "#c8923e")
  -- table
  part(c, R(c, 2, 36, 70, 41), "#b07a45"); fl(c, R(c, 2, 36, 70, 36), "#d9a660")
  part(c, R(c, 6, 42, 9, 52), "#8a5a35", { noline = true }); part(c, R(c, 62, 42, 65, 52), "#8a5a35", { noline = true })
  -- the jackfruit, cut open: green spiky half with golden pods
  part(c, c:ellipse(36, 28, 15, 9), "#5e8a3a", { shade = true })
  for x = 24, 48, 3 do c:px(x, 20, "#3f6a2a"); c:px(x + 1, 36, "#3f6a2a") end
  c:fill(c:ellipse(36, 28, 11, 6), "#e8c860")
  for _, p in ipairs({ { 29, 26 }, { 34, 24 }, { 40, 25 }, { 44, 28 }, { 31, 31 }, { 37, 30 }, { 42, 32 } }) do part(c, c:ellipse(p[1], p[2], 2, 2), "#f5b020", { noline = true }); c:px(p[1], p[2], "#fff0a0") end
  -- gnome with the knife, sticky oiled hands
  local _, G = gnome(c, 56, 44, { d = -1, upper = true, eyes = "open", arms = { arm({ -4, 8 }, { -10, 10 }, true) } })
  part(c, R(c, 50, 36, 56, 37), "#aeb4bc", { noline = true })
  local kx, ky = G.P(-10, 10)
  c:fill(c:line({ { kx, ky }, { kx - 5, ky - 7 } }, 1), "#aeb4bc"); fl(c, R(c, kx - 1, ky - 1, kx + 1, ky + 1), "#8a5a35")
  -- melon slice and mango at left
  part(c, c:ellipse(15, 34, 4, 3), "#e8503a", { shade = true }); fl(c, R(c, 12, 36, 18, 36), "#4e9a48"); c:px(14, 33, "#2a1a10"); c:px(17, 34, "#2a1a10")
  part(c, c:ellipse(22, 34, 3, 2), "#f08a24")
  fl(c, R(c, 19, 35, 25, 35), "#f08a24")
  c:px(31, 17, "#fff1c8"); c:px(44, 20, "#fff1c8"); c:px(26, 22, "#fff1c8")
  finish(c, sl)
end

-- 14. silkworm trays: dim shed, racks of trays with leaves and worms, gnome sprinkling fresh mulberry leaves
function S.r_csa_silkworm_trays(sl)
  seed = 74
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#8a6a48")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 40), "#7a5a3a") end
  c:fill(R(c, 0, 41, W - 1, H - 1), "#6a4a30")
  -- window with morning light
  part(c, R(c, 6, 8, 20, 26), "#e8f0d8"); fl(c, R(c, 12, 8, 13, 26), "#8a5a35"); fl(c, R(c, 6, 16, 20, 17), "#8a5a35")
  c:fill(c:poly({ { 6, 27 }, { 20, 27 }, { 28, 46 }, { 2, 46 } }), "#9a7a52")
  -- rack on the right, 3 trays
  part(c, R(c, 36, 8, 38, 46), "#5e3f28", { noline = true }); part(c, R(c, 66, 8, 68, 46), "#5e3f28", { noline = true })
  for i, y in ipairs({ 14, 26, 38 }) do
    part(c, R(c, 36, y, 68, y + 4), "#c8923e")
    c:fill(R(c, 38, y - 2, 66, y - 1), "#4e9a3c")
    for x = 39, 65, 3 do fl(c, R(c, x, y - 2, x + 1, y - 2), (x % 2 == 0) and "#8cc060" or "#6ab04a") end
    for x = 40 + i * 2, 65, 7 do fl(c, R(c, x, y - 3, x + 2, y - 3), "#f4eed0") end
  end
  -- gnome on a low stool with a basket of leaves, dropping a handful on the tray
  part(c, R(c, 18, 41, 26, 43), "#a8703e"); fl(c, R(c, 19, 43, 19, 47), "#6b3b2a"); fl(c, R(c, 25, 43, 25, 47), "#6b3b2a")
  local _, G = gnome(c, 30, 47, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 8, 13 }, true) } })
  part(c, R(c, 15, 42, 23, 47), "#c8923e"); fl(c, R(c, 15, 44, 23, 44), "#a8702a")
  for _, p in ipairs({ { 15, 41 }, { 18, 40 }, { 21, 41 }, { 23, 40 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2] + 1), "#5aa844") end
  local lx, ly = G.P(9, 14)
  for _, p in ipairs({ { 0, 0 }, { 2, -2 }, { 3, 2 }, { 5, -1 } }) do fl(c, R(c, lx + p[1], ly + p[2] - 1, lx + p[1] + 2, ly + p[2]), "#6ab04a") end
  finish(c, sl)
end

-- 15. reeling silk: warm basin of cocoons, gnome draws a fine thread up to the reel that glints
function S.r_csa_reel_silk(sl)
  seed = 75
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#d8b878")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 0, x, 38), "#c8a468") end
  c:fill(R(c, 0, 39, W - 1, H - 1), "#a8703e")
  fl(c, R(c, 0, 39, W - 1, 39), "#c8923e")
  -- reel: big wooden wheel with spokes at the right
  part(c, c:ellipse(56, 24, 11, 11), "#a06a3c", { shade = true })
  c:fill(c:ellipse(56, 24, 8, 8), "#d8b878")
  for _, p in ipairs({ { 56, 17, 56, 31 }, { 49, 24, 63, 24 }, { 51, 19, 61, 29 }, { 61, 19, 51, 29 } }) do fl(c, c:line({ { p[1], p[2] }, { p[3], p[4] } }, 1), "#8a5a35") end
  c:fill(c:ellipse(56, 24, 2, 2), "#5e3f28")
  c:fill(c:ellipse(56, 24, 8, 8):clip(R(c, 0, 0, W, 24)), "#f4eee0")
  c:fill(c:ellipse(56, 24, 5, 5), "#d8b878"); c:fill(c:ellipse(56, 24, 2, 2), "#5e3f28")
  for _, p in ipairs({ { 56, 17 }, { 51, 20 } }) do c:px(p[1], p[2], "#fffdf4") end
  part(c, R(c, 54, 34, 58, 46), "#6b3b2a", { noline = true })
  -- table with basin
  part(c, R(c, 3, 40, 50, 44), "#b07a45"); fl(c, R(c, 3, 40, 50, 40), "#d9a660")
  part(c, R(c, 6, 45, 9, 53), "#8a5a35", { noline = true }); part(c, R(c, 44, 45, 47, 53), "#8a5a35", { noline = true })
  part(c, c:ellipse(27, 38, 13, 4), "#c0442e", { shade = true })
  c:fill(c:ellipse(27, 37, 11, 3), "#c8e8ec")
  for _, p in ipairs({ { 20, 37 }, { 24, 36 }, { 29, 38 }, { 33, 36 }, { 26, 38 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#f8f4e4", { noline = true }) end
  -- steam
  for i = 0, 2 do fl(c, R(c, 22 + (i % 2), 28 - i * 3, 23 + (i % 2), 29 - i * 3), "#f4f8fa") end
  -- gnome pinches the thread, a fine bright line rises to the reel
  local _, G = gnome(c, 14, 40, { d = 1, upper = false, eyes = "shut", arms = { arm({ 4, 8 }, { 8, 10 }, true) } })
  local hx, hy = G.P(9, 11)
  c:fill(c:line({ { hx, hy }, { 30, 34 } }, 1), "#fff8e8")
  c:fill(c:line({ { hx, hy }, { 46, 22 } }, 1), "#fff8e8")
  c:px(30, 33, "#fffdf4"); c:px(40, 27, "#fffdf4"); c:px(20, 18, "#fffdf4"); c:px(24, 12, "#fffdf4")
  finish(c, sl)
end

-- 16. ragas in the courtyard: sitar and tabla gnomes sit in a colonnaded caravanserai, notes drift
function S.r_csa_courtyard_ragas(sl)
  seed = 76
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 34), "#e0c898")
  -- arched arcade
  for i = 0, 3 do
    local x0 = 4 + i * 17
    part(c, R(c, x0, 8, x0 + 3, 34), "#d8b078", { noline = true })
    c:fill(c:ellipse(x0 + 9, 20, 6, 7), "#6a5a78"); c:fill(R(c, x0 + 3, 20, x0 + 14, 34), "#6a5a78")
  end
  c:fill(R(c, 0, 4, W - 1, 8), "#c8946a"); c:fill(R(c, 0, 4, W - 1, 4), "#e0b080")
  for _, x in ipairs({ 8, 25, 42, 59 }) do fl(c, R(c, x, 28, x + 5, 30), "#4a4268") end
  c:fill(R(c, 0, 35, W - 1, H - 1), "#c8a070")
  for x = 2, W - 1, 9 do fl(c, R(c, x, 35, x, H - 1), "#b88c5c") end
  for y = 40, 50, 5 do fl(c, R(c, 0, y, W - 1, y), "#b88c5c") end
  -- rug
  part(c, R(c, 8, 42, 64, 50), "#a8321e"); fl(c, R(c, 10, 44, 62, 48), "#d88a2a"); fl(c, R(c, 12, 45, 60, 47), "#a8321e")
  -- sitar player at left, sitting, long-necked sitar across
  gnome(c, 20, 47, { d = 1, sit = true, eyes = "shut", arms = { arm({ 3, 7 }, { 8, 9 }, true), arm({ -3, 6 }, { -1, 11 }, true) } })
  c:fill(c:line({ { 6, 25 }, { 28, 40 } }, 1), "#a8703e")
  part(c, c:ellipse(10, 38, 5, 4), "#c8923e", { shade = true }); fl(c, R(c, 8, 37, 12, 37), "#8a5a35")
  c:px(8, 34, "#f5cf6a"); c:px(6, 26, "#8a5a35")
  -- tabla player on the right, two drums
  gnome(c, 54, 47, { d = -1, sit = true, hat = "#e8a317", eyes = "happy", arms = { arm({ -3, 7 }, { -9, 6 }, true), arm({ 3, 6 }, { -5, 5 }, true) } })
  part(c, c:ellipse(46, 44, 4, 3), "#8a5a35", { shade = true }); part(c, c:ellipse(41, 46, 3, 2), "#c0442e", { shade = true })
  c:fill(c:ellipse(46, 42, 3, 1), "#f4eee0"); c:px(46, 42, "#2a1a10")
  -- music notes
  local function note(x, y) fl(c, R(c, x, y + 3, x + 1, y + 4), "#3a2a4a"); fl(c, R(c, x + 1, y, x + 1, y + 3), "#3a2a4a"); c:px(x + 2, y + 1, "#3a2a4a") end
  note(30, 12); note(38, 8); note(46, 14); note(34, 20)
  finish(c, sl)
end

-- 17. caravan bells: scout gnome cups an ear on a steppe tower step; a camel train with bells winds over the far ridge
function S.r_csa_caravan_bells(sl)
  seed = 77
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#a4cce0", "#b8d8e4", "#cce4e4", "#e0ecd8" }, { dir = "v" })
  c:fill(c:ellipse(60, 10, 12, 3), "#f4eee0"); c:fill(c:ellipse(52, 8, 6, 2), "#f4eee0")
  c:fill(c:ellipse(20, 31, 30, 7), "#c8b078"); c:fill(c:ellipse(62, 29, 26, 6), "#d4bc84")
  c:fill(R(c, 0, 30, W - 1, H - 1), "#b8a468")
  c:fill(R(c, 0, 30, W - 1, 30), "#d4bc84")
  for _, p in ipairs({ { 10, 40 }, { 30, 46 }, { 44, 42 }, { 62, 47 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#9a8a56"); c:px(p[1] + 1, p[2] - 1, "#7a9a4a") end
  -- distant camel train on the ridge with bright bells
  for i = 0, 2 do
    local x = 40 + i * 10
    fl(c, R(c, x, 25, x + 5, 27), "#8a6a48"); fl(c, R(c, x + 1, 23, x + 2, 24), "#8a6a48"); fl(c, R(c, x + 4, 22, x + 5, 25), "#8a6a48")
    fl(c, R(c, x, 28, x, 30), "#6a4a30"); fl(c, R(c, x + 5, 28, x + 5, 30), "#6a4a30")
    c:px(x + 3, 28, "#f5cf6a")
  end
  -- sound rings
  for _, p in ipairs({ { 38, 20, 2 }, { 50, 19, 2 }, { 62, 20, 2 } }) do
    c:px(p[1], p[2], "#f5cf6a"); c:px(p[1] - 2, p[2] - 2, "#f5cf6a"); c:px(p[1] + 2, p[2] - 2, "#f5cf6a"); c:px(p[1] - 3, p[2], "#f5cf6a"); c:px(p[1] + 3, p[2], "#f5cf6a")
  end
  -- watch tower at left with a hanging bell
  part(c, R(c, 2, 14, 11, 44), "#c8a468", { shade = true })
  for y = 20, 40, 6 do fl(c, R(c, 3, y, 10, y), "#a88848") end
  part(c, R(c, 0, 10, 13, 14), "#a8703e")
  part(c, R(c, 4, 22, 9, 27), "#4a3a2a")
  -- the scout, big, hand cupped to ear, eyes shut
  local _, G = gnome(c, 26, 47, { d = 1, s = 1.3, eyes = "shut", arms = { arm({ -4, 8 }, { -4, 13 }, true) } })
  local ex, ey = G.P(-5, 15)
  c:outline(R(c, ex - 2, ey - 3, ex + 1, ey + 1)); fl(c, R(c, ex - 2, ey - 3, ex + 1, ey + 1), "#f0c8a0")
  -- hanging bell
  fl(c, R(c, 6, 14, 6, 16), "#5e3f28")
  part(c, c:poly({ { 6, 16 }, { 9, 19 }, { 3, 19 } }), "#e8a317"); c:px(6, 20, "#f5cf6a")
  finish(c, sl)
end

-- 18. block printing: gnome presses a carved block onto cloth, patterns repeat, shelf of blocks, indigo vat
function S.r_csa_block_prints(sl)
  seed = 78
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 36), "#d8c8a0")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 0, x, 36), "#c8b88c") end
  -- shelves of carved blocks
  for _, y in ipairs({ 14, 24 }) do
    part(c, R(c, 36, y, 68, y + 1), "#8a5a35")
    for x = 38, 64, 5 do part(c, R(c, x, y - 5, x + 3, y - 1), (x % 2 == 0) and "#a8703e" or "#c8923e"); c:px(x + 1, y - 3, "#5e3f28"); c:px(x + 2, y - 4, "#5e3f28") end
  end
  -- drying cloth hung at left
  fl(c, R(c, 6, 6, 6, 8), "#5e3f28"); fl(c, R(c, 4, 8, 22, 8), "#5e3f28")
  part(c, R(c, 5, 9, 21, 26), "#f4eee0")
  for gx = 8, 18, 5 do for gy = 11, 23, 6 do fl(c, R(c, gx, gy, gx + 1, gy + 1), "#2f4f8a"); c:px(gx - 1, gy + 2, "#c0442e"); c:px(gx + 2, gy + 2, "#c0442e") end end
  c:fill(R(c, 0, 37, W - 1, H - 1), "#a8703e")
  -- table with a long printed cloth
  part(c, R(c, 4, 38, 68, 43), "#b07a45"); fl(c, R(c, 4, 38, 68, 38), "#d9a660")
  part(c, R(c, 8, 44, 11, 52), "#8a5a35", { noline = true }); part(c, R(c, 62, 44, 65, 52), "#8a5a35", { noline = true })
  part(c, R(c, 4, 35, 50, 37), "#f4eee0")
  for gx = 6, 36, 6 do fl(c, R(c, gx, 35, gx + 2, 36), "#2f4f8a"); c:px(gx + 3, 35, "#c0442e") end
  -- indigo vat at right
  part(c, c:rrect(54, 30, 67, 37, 2), "#5e3f28", { shade = true }); fl(c, R(c, 55, 31, 66, 32), "#2f4f8a"); fl(c, R(c, 57, 31, 60, 31), "#4a72b0")
  -- gnome presses the block, hands on top
  local _, G = gnome(c, 54, 45, { d = -1, upper = true, eyes = "open", arms = { arm({ -4, 7 }, { -9, 7 }, true) } })
  part(c, R(c, 38, 30, 44, 35), "#a8703e"); fl(c, R(c, 39, 31, 43, 31), "#c8923e"); fl(c, R(c, 40, 33, 42, 34), "#5e3f28")
  fl(c, R(c, 43, 31, 44, 31), "#2f4f8a")
  part(c, R(c, 45, 31, 48, 33), "#c8923e", { noline = true })
  finish(c, sl)
end

-- 19. rooftop apricots: flat adobe roof laid with orange halves, gnome turns them while a crow eyes the trays
function S.r_csa_rooftop_apricots(sl)
  seed = 79
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#7cb8e0", "#92c6e4", "#aad4e8", "#c4e2ec" }, { dir = "v" })
  c:fill(c:poly({ { 0, 28 }, { 10, 10 }, { 20, 22 }, { 34, 6 }, { 48, 24 }, { 58, 14 }, { 72, 28 } }), "#b4c8d8")
  for _, t in ipairs({ { 10, 10, 6 }, { 34, 6, 7 }, { 58, 14, 6 } }) do c:fill(c:poly({ { t[1], t[2] }, { t[1] + 3, t[2] + t[3] - 1 }, { t[1] - 3, t[2] + t[3] - 1 } }), "#f4f8fa") end
  c:fill(R(c, 0, 28, W - 1, 36), "#b4a888")
  -- adobe houses
  part(c, R(c, 0, 26, 20, 36), "#c8a070"); part(c, R(c, 50, 24, 70, 34), "#d4ae7c")
  part(c, R(c, 4, 29, 7, 36), "#5e3f28"); part(c, R(c, 58, 27, 62, 34), "#5e3f28")
  -- the flat roof in the foreground
  part(c, R(c, 0, 36, W - 1, H - 1), "#c8a070")
  fl(c, R(c, 0, 36, W - 1, 37), "#dcb888")
  for x = 6, 66, 9 do fl(c, R(c, x, 43, x + 3, 43), "#b88c5c") end
  -- trays of apricot halves
  local function tray(x0, y0, x1, y1)
    part(c, R(c, x0, y0, x1, y1), "#f4eee0")
    for x = x0 + 1, x1 - 2, 3 do for y = y0 + 1, y1 - 1, 2 do fl(c, R(c, x, y, x + 1, y), "#f08a24") end end
  end
  tray(4, 40, 24, 44); tray(4, 46, 24, 49); tray(44, 40, 66, 44); tray(46, 46, 66, 49)
  -- the gnome flips halves, crow perched on the parapet
  local _, G = gnome(c, 34, 48, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 9, 5 }, true) } })
  local hx, hy = G.P(9, 5)
  part(c, c:ellipse(hx + 1, hy, 2, 1), "#f08a24", { noline = true }); c:px(hx + 1, hy - 3, "#f08a24")
  part(c, c:ellipse(59, 37, 3, 2), "#2a2a38", { shade = false }); fl(c, R(c, 56, 34, 58, 36), "#2a2a38"); c:px(55, 35, "#f5cf6a"); c:px(57, 35, "#f4eee0")
  fl(c, R(c, 61, 38, 64, 38), "#2a2a38")
  finish(c, sl)
end

-- 20. delta bank in monsoon rain: river creeping up the mud bank, gnome packs sandbags with a spade
function S.r_csa_delta_bank(sl)
  seed = 80
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 24), { "#5a6678", "#66727e", "#76828c", "#88929a" }, { dir = "v" })
  c:fill(c:ellipse(14, 6, 16, 5), "#465060"); c:fill(c:ellipse(52, 4, 18, 5), "#404a5c")
  c:fill(c:ellipse(60, 24, 20, 4), "#4a6248"); c:fill(c:ellipse(10, 25, 20, 4), "#46604a")
  -- brown river at the right, up the bank
  c:fill(R(c, 0, 24, W - 1, H - 1), "#7a5e3c")
  c:fill(c:poly({ { 40, 24 }, { 72, 24 }, { 72, 54 }, { 30, 54 }, { 34, 38 } }), "#9a7a4e")
  c:fill(c:poly({ { 44, 26 }, { 72, 26 }, { 72, 54 }, { 36, 54 }, { 40, 38 } }), "#a8874e")
  wave(c, 48, 66, 30, "#c8a870"); wave(c, 42, 58, 38, "#c8a870"); wave(c, 40, 56, 46, "#c8a870"); wave(c, 58, 70, 49, "#c8a870")
  -- jetty post and ferry rope
  part(c, R(c, 60, 14, 62, 30), "#5e3f28", { noline = true })
  -- sandbag wall, two rows
  local function bag(x, y) part(c, c:rrect(x, y, x + 6, y + 3, 1), "#d8b878"); c:px(x + 3, y + 1, "#b8965c") end
  for i = 0, 3 do bag(26 + i * 0, 49 - i * 3) end
  for i = 0, 1 do bag(27, 33 + i * 0) end
  bag(20, 49); bag(20, 45); bag(26, 49); bag(26, 45); bag(26, 41); bag(32, 49); bag(32, 45); bag(32, 41); bag(32, 37)
  -- ferryman gnome with a bag, spade in the mud
  c:fill(c:line({ { 8, 29 }, { 8, 48 } }, 1), "#8a5a35"); fl(c, R(c, 6, 28, 10, 28), "#aeb4bc")
  local _, G = gnome(c, 14, 48, { d = 1, hat = "#c0442e", eyes = "open", arms = { arm({ 4, 7 }, { 7, 6 }, true) } })
  local bx, by = G.P(7, 7)
  part(c, c:rrect(bx - 1, by - 2, bx + 5, by + 2, 1), "#d8b878")
  -- rain
  seed = 23
  for i = 1, 40 do local x, y = 6 + floor(rand() * 62), 6 + floor(rand() * 42); c:px(x, y, "#d0dce8"); c:px(x - 1, y + 1, "#d0dce8") end
  finish(c, sl)
end

-- 21. felt rolling: two gnomes roll a patterned felt roll on a reed mat, yurt behind, a song
function S.r_csa_felt_roll(sl)
  seed = 81
  local c = new()
  day(c, 30, { cloud = 52, sky = { "#a8d0e4", "#bcdce8", "#d0e8ea" }, hill = "#7a9a58", hill2 = "#6a8c4e", grass = "#8aac5e" })
  -- yurt at the back
  part(c, c:ellipse(18, 27, 13, 6), "#f4eee0", { shade = true })
  part(c, c:poly({ { 18, 14 }, { 32, 26 }, { 4, 26 } }), "#e8e0cc")
  fl(c, R(c, 16, 22, 20, 28), "#8a4a2a"); fl(c, R(c, 4, 25, 32, 25), "#c0442e")
  part(c, R(c, 15, 21, 21, 29), "#c0442e"); fl(c, R(c, 17, 23, 19, 28), "#6b3b2a")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#a8b868")
  -- reed mat
  part(c, R(c, 6, 40, 66, 50), "#d8b878")
  for x = 8, 64, 3 do fl(c, R(c, x, 41, x, 49), "#c8a468") end
  -- unrolled felt with a pattern, left; the roll lies across
  fl(c, R(c, 8, 42, 24, 48), "#f4eee0")
  for x = 10, 22, 4 do fl(c, R(c, x, 44, x + 1, 46), "#2f4f8a"); c:px(x + 2, 45, "#c0442e") end
  part(c, c:rrect(24, 38, 54, 48, 4), "#e8d8b8", { shade = true })
  fl(c, R(c, 25, 41, 53, 41), "#2f4f8a"); fl(c, R(c, 25, 44, 53, 44), "#c0442e")
  part(c, c:ellipse(54, 43, 2, 5), "#f4eee0")
  c:fill(c:ellipse(54, 43, 1, 3), "#2f4f8a")
  -- gnomes at each end pushing, one behind the roll
  gnome(c, 14, 44, { d = 1, upper = false, hat = "#c0442e", eyes = "happy", arms = { arm({ 4, 7 }, { 10, 6 }, true) } })
  gnome(c, 60, 44, { d = -1, walk = 1, hat = "#4f9a45", eyes = "happy", arms = { arm({ -4, 7 }, { -8, 6 }, true) } })
  local function note(x, y) fl(c, R(c, x, y + 3, x + 1, y + 4), "#3a2a4a"); fl(c, R(c, x + 1, y, x + 1, y + 3), "#3a2a4a"); c:px(x + 2, y + 1, "#3a2a4a") end
  note(30, 14); note(40, 10); note(48, 16); note(36, 22)
  finish(c, sl)
end

-- 22. snowmelt channels: spring thaw, snowy peaks, stone channel leading to a mill pool, gnome rakes out grit
function S.r_csa_snowmelt(sl)
  seed = 82
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 22), { "#88b8dc", "#9cc6e2", "#b0d4e6", "#c8e2ec" }, { dir = "v" })
  c:fill(c:poly({ { 0, 22 }, { 12, 6 }, { 26, 22 }, { 40, 8 }, { 58, 22 }, { 72, 12 }, { 72, 22 } }), "#a8b8cc")
  c:fill(c:poly({ { 12, 6 }, { 17, 13 }, { 7, 13 } }), "#f4f8fa"); c:fill(c:poly({ { 40, 8 }, { 46, 15 }, { 34, 15 } }), "#f4f8fa")
  c:fill(c:poly({ { 0, 22 }, { 4, 15 }, { 12, 22 } }), "#e8f0f4")
  c:fill(R(c, 0, 22, W - 1, H - 1), "#7aa05a")
  -- patches of melting snow
  for _, p in ipairs({ { 6, 24, 9 }, { 50, 26, 8 }, { 62, 34, 7 }, { 8, 40, 6 } }) do c:fill(c:ellipse(p[1], p[2], p[3] // 2 + 1, 1), "#e8f0f4") end
  -- stone channel running diagonally into a pool at lower right
  c:fill(c:poly({ { 18, 22 }, { 26, 22 }, { 62, 44 }, { 52, 48 } }), "#8b8f96")
  c:fill(c:poly({ { 20, 22 }, { 24, 22 }, { 58, 44 }, { 54, 46 } }), "#58b4c4")
  c:outline(c:poly({ { 18, 22 }, { 26, 22 }, { 62, 44 }, { 52, 48 } }))
  for _, p in ipairs({ { 28, 28 }, { 36, 33 }, { 44, 38 } }) do c:px(p[1], p[2], "#d8f4f4"); c:px(p[1] + 1, p[2], "#d8f4f4") end
  -- grit and clogs piled in the channel
  for _, p in ipairs({ { 40, 35 }, { 44, 36 }, { 47, 38 }, { 42, 37 } }) do part(c, c:ellipse(p[1], p[2], 2, 1), "#6a6a68", { noline = true }) end
  -- pool and mill wheel
  part(c, c:ellipse(62, 47, 9, 4), "#8b8f96", { shade = true }); c:fill(c:ellipse(62, 47, 7, 3), "#58b4c4")
  part(c, R(c, 58, 28, 68, 40), "#c8923e"); part(c, c:poly({ { 56, 29 }, { 63, 22 }, { 70, 29 } }), "#8a5a35")
  part(c, c:ellipse(66, 39, 4, 4), "#6b3b2a"); c:fill(c:ellipse(66, 39, 2, 2), "#58b4c4")
  -- gnome rakes grit out of the channel
  local _, G = gnome(c, 22, 48, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 8 }, true), arm({ -3, 6 }, { 6, 5 }, true) } })
  c:fill(c:line({ { 31, 38 }, { 39, 33 } }, 1), "#7a4a2a"); c:fill(c:line({ { 30, 40 }, { 33, 38 } }, 1), "#7a4a2a")
  fl(c, R(c, 38, 31, 41, 32), "#aeb4bc")
  for _, p in ipairs({ { 12, 40 }, { 30, 28 } }) do c:px(p[1], p[2], "#e46a9b"); c:px(p[1], p[2] + 1, "#4e8a3c") end
  finish(c, sl)
end

-- 23. kite duel: red kite against the rival's blue, strings crossing high above the windy ridge
function S.r_csa_kite_duel(sl)
  seed = 83
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#7cb4dc", "#90c2e2", "#a8d2e8", "#c0e0ec" }, { dir = "v" })
  for _, p in ipairs({ { 8, 24, 10 }, { 50, 20, 12 } }) do c:fill(c:ellipse(p[1], p[2], p[3], 2), "#f4eee0") end
  c:fill(c:ellipse(20, 40, 36, 8), "#6a9a4a"); c:fill(c:ellipse(62, 42, 24, 7), "#5a8c42")
  c:fill(R(c, 0, 38, W - 1, H - 1), "#7ea85a")
  fl(c, R(c, 0, 38, W - 1, 38), "#9cc070")
  -- tiny watch tower on the ridge, flag streaming
  part(c, R(c, 60, 28, 66, 38), "#b4a888"); fl(c, R(c, 62, 31, 63, 33), "#5e3f28"); fl(c, R(c, 66, 22, 66, 28), "#5e3f28")
  fl(c, R(c, 67, 22, 70, 24), "#dd3a2a")
  -- the two kites: diamond with cross-spars and a flapping tail
  local function kite(x, y, col, col2)
    part(c, c:poly({ { x, y - 7 }, { x + 6, y }, { x, y + 8 }, { x - 6, y } }), col)
    fl(c, R(c, x, y - 6, x, y + 7), col2); fl(c, R(c, x - 5, y, x + 5, y), col2)
  end
  local function tail(x, y, n, dx, col)
    for i = 1, n do local tx, ty = x + dx * i, y + i * 3; fl(c, R(c, tx, ty, tx + 1, ty + 1), (i % 2 == 0) and col or "#f4eee0") end
  end
  -- strings first
  c:fill(c:line({ { 20, 40 }, { 26, 28 }, { 34, 17 } }, 1), "#f4eee0")
  c:fill(c:line({ { 62, 38 }, { 52, 26 }, { 40, 16 } }, 1), "#e8d0a0")
  kite(34, 14, "#dd3a2a", "#8e2e1e"); tail(34, 22, 6, 1, "#f5cf6a")
  kite(46, 12, "#3f78b0", "#2f4f8a"); tail(46, 20, 5, -1, "#f4eee0")
  -- gnome on the ridge, arm up with the string
  gnome(c, 18, 47, { d = 1, walk = 1, eyes = "open", arms = { arm({ 4, 9 }, { 8, 17 }, true), arm({ -3, 6 }, { 0, 10 }, true) } })
  for _, p in ipairs({ { 8, 44 }, { 46, 46 } }) do fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#5e8a44") end
  for _, p in ipairs({ { 8, 30 }, { 12, 33 }, { 56, 34 } }) do fl(c, R(c, p[1], p[2], p[1] + 4, p[2]), "#f4f8fa") end
  finish(c, sl)
end

-- 24. carrom: the woodcarver's board seen from above-front, discs scattered, gnome flicks the striker
function S.r_csa_carrom_board(sl)
  seed = 84
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 20), "#d8c8a0")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 0, x, 20), "#c8b88c") end
  -- shelf with carved pieces
  part(c, R(c, 6, 15, 30, 16), "#8a5a35"); part(c, c:ellipse(11, 12, 2, 3), "#c8923e"); part(c, c:ellipse(18, 12, 2, 3), "#a8703e"); part(c, R(c, 23, 9, 28, 14), "#c8923e")
  c:fill(R(c, 0, 21, W - 1, H - 1), "#a8703e")
  fl(c, R(c, 0, 21, W - 1, 21), "#c8923e")
  -- big board, square-ish, seen from above
  part(c, R(c, 22, 18, 68, 50), "#6b3b2a")
  c:fill(R(c, 24, 20, 66, 48), "#d9a660")
  c:fill(R(c, 27, 23, 63, 45), "#f0d49e")
  -- corner pockets
  for _, p in ipairs({ { 25, 21 }, { 65, 21 }, { 25, 47 }, { 65, 47 } }) do c:fill(c:ellipse(p[1], p[2], 2, 2), "#2a1a10") end
  -- baseline strips and centre circle
  fl(c, R(c, 31, 27, 59, 27), "#c0442e"); fl(c, R(c, 31, 41, 59, 41), "#c0442e")
  c:fill(c:ellipse(45, 34, 6, 5), "#c0442e"); c:fill(c:ellipse(45, 34, 4, 3), "#f0d49e")
  -- discs: white, black, red queen
  local function disc(x, y, col) part(c, c:ellipse(x, y, 1, 1), col, { noline = true }); c:px(x, y, (col == "#f4eee0") and "#d8ccb0" or "#6a4a3a") end
  for _, p in ipairs({ { 43, 32 }, { 47, 32 }, { 43, 36 }, { 47, 36 }, { 45, 30 }, { 45, 38 } }) do disc(p[1], p[2], (p[1] + p[2]) % 2 == 0 and "#f4eee0" or "#3a2a22") end
  part(c, c:ellipse(45, 34, 1, 1), "#dd3a2a", { noline = true })
  -- gnome at the left edge, striker flicked, a streak
  local _, G = gnome(c, 12, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 5 }, true) } })
  part(c, c:ellipse(36, 37, 2, 1), "#f4eee0", { noline = true })
  fl(c, R(c, 28, 37, 33, 37), "#d8ccb0")
  c:px(30, 36, "#f5cf6a"); c:px(32, 38, "#f5cf6a")
  finish(c, sl)
end

local order = {}
for _, line in ipairs({ "r_csa_flower_boat","r_csa_two_leaves","r_csa_spice_mats","r_csa_yak_pass","r_csa_leopard_spot","r_csa_buffalo_ramp","r_csa_turmeric_grate","r_csa_threshing_floor","r_csa_monkey_sandal","r_csa_dip_net","r_csa_mango_chutney","r_csa_mung_dal","r_csa_jackfruit_carve","r_csa_silkworm_trays","r_csa_reel_silk","r_csa_courtyard_ragas","r_csa_caravan_bells","r_csa_block_prints","r_csa_rooftop_apricots","r_csa_delta_bank","r_csa_felt_roll","r_csa_snowmelt","r_csa_kite_duel","r_csa_carrom_board" }) do order[#order + 1] = line end
for _, s2 in ipairs(order) do
  if (not only or only == s2) and S[s2] then seed = 7; S[s2](s2) end
end
