-- variety-act-g16.lua : Do-tab scenes for herb/workshop wave activities -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g16.lua   (params BEFORE --script)
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

-- mirrored-arm helper: x offsets flipped by facing d
local function armd(d, a, b, front, nohand) return { a = { a[1] * d, a[2] }, b = { b[1] * d, b[2] }, front = front, nohand = nohand } end

local function bee(c, x, y, big)
  if big then
    part(c, c:ellipse(x, y, 3, 2), "#f5cf6a")
    fl(c, R(c, x - 1, y - 1, x - 1, y + 1), "#2a1a10"); fl(c, R(c, x + 1, y - 1, x + 1, y + 1), "#2a1a10")
    fl(c, R(c, x - 2, y - 4, x - 1, y - 3), "#f4f8fa"); fl(c, R(c, x + 1, y - 4, x + 2, y - 3), "#f4f8fa")
  else
    fl(c, R(c, x, y, x + 2, y + 1), "#f5cf6a"); c:px(x + 1, y, INK); c:px(x + 1, y + 1, INK)
    c:px(x, y - 1, "#f4f8fa"); c:px(x + 2, y - 1, "#f4f8fa")
  end
end

local function flower(c, x, y, col, stem, ctr)
  fl(c, R(c, x, y, x, y + (stem or 5)), "#3f7a38")
  c:px(x - 1, y - 1, col); c:px(x + 1, y - 1, col); c:px(x, y - 2, col); c:px(x, y, col)
  c:px(x, y - 1, ctr or "#f5cf6a")
end

-- straw skep hive
local function skep(c, x, yb, w, h)
  local m = c:ellipse(x, yb - h + 3, w, h):clip(R(c, x - w, 0, x + w, yb))
  part(c, m, "#e0b85a")
  for yy = yb - h + 3, yb - 1, 3 do fl(c, R(c, x - w + 1, yy, x + w - 1, yy):clip(m), "#b8863a") end
  fl(c, c:ellipse(x, yb - 2, 2, 2):clip(R(c, 0, 0, W, yb)), "#2a1a10")
end

local S = {}

-- 1. herb_spiral: slumped tiers of the drystone spiral, gnome carrying a stone to the gap
function S.w3_herb_spiral()
  seed = 61
  local c = new()
  day(c, 34, { cloud = 20 })
  local function tier(cx, yb, hw, hh, wall)
    part(c, c:rrect(cx - hw, yb - hh, cx + hw, yb, 2), "#a8aeb4", { shade = true })
    for y = yb - hh + 3, yb - 1, 3 do fl(c, R(c, cx - hw + 1, y, cx + hw - 1, y), "#7a8088") end
    for i, x in ipairs({ 0, 5, 9 }) do fl(c, R(c, cx - hw + 3 + x + (i % 2) * 6, yb - hh + 1, cx - hw + 3 + x + (i % 2) * 6, yb - hh + 3), "#7a8088") end
    part(c, c:ellipse(cx, yb - hh, hw, 3), "#5e8a44", { noline = false })
  end
  tier(47, 47, 19, 9); tier(47, 38, 13, 8); tier(47, 30, 8, 7)
  -- gap in the bottom tier (stone missing)
  fl(c, R(c, 31, 41, 36, 46), "#6b4a2e"); fl(c, R(c, 31, 41, 36, 41), "#4a2c1a")
  -- herbs: thyme purple, rosemary spikes, green tufts
  for _, p in ipairs({ { 33, 37 }, { 37, 38 }, { 56, 38 }, { 60, 37 }, { 41, 31 }, { 52, 31 } }) do
    fl(c, R(c, p[1], p[2], p[1] + 2, p[2] + 1), "#8a6ab8"); c:px(p[1] + 1, p[2] - 1, "#a88ad4")
  end
  for _, p in ipairs({ { 45, 22 }, { 49, 23 }, { 47, 21 } }) do fl(c, R(c, p[1], p[2], p[1], p[2] + 4), "#3f7a38"); c:px(p[1], p[2] - 1, "#8a6ab8") end
  fl(c, R(c, 43, 24, 51, 25), "#4e8a3c")
  -- fallen stones
  for _, s in ipairs({ { 28, 48, 3, 2 }, { 24, 46, 2, 2 }, { 65, 49, 3, 2 } }) do part(c, c:ellipse(s[1], s[2], s[3], s[4]), "#a8aeb4", { shade = true }) end
  local _, G = gnome(c, 14, 48, { d = 1, walk = 1, eyes = "open", arms = { armd(1, { -4, 7 }, { 3, 6 }, false, true), armd(1, { 4, 7 }, { 8, 7 }, true, true) } })
  local sx, sy = G.P(6, 10)
  part(c, c:ellipse(sx + 1, sy, 4, 3), "#a8aeb4", { shade = true })
  fl(c, R(c, sx - 2, sy + 2, sx + 2, sy + 4), "#f0c8a0")
  fl(c, R(c, sx - 2, sy, sx, sy + 2), "#f0c8a0")
  finish(c, "w3_herb_spiral")
end

-- 2. bee_dance: gnome waggle-dancing before a skep, bees watching in a row
function S.w3_bee_dance()
  seed = 62
  local c = new()
  day(c, 35, { cloud = 36, sky = { "#9fd0e4", "#b8dcea", "#cfe8ee" } })
  for _, x in ipairs({ 8, 13, 18 }) do flower(c, x, 30, "#b070d0", 14); flower(c, x + 2, 36, "#e46a9b", 9) end
  -- dotted waggle path on the grass
  for i = 0, 17 do
    local a = i * math.pi * 2 / 18
    c:px(rnd(30 + math.cos(a) * 12), rnd(46 + math.sin(a * 2) * 2.5), "#f4eee0")
  end
  -- hive on a stump
  part(c, R(c, 51, 42, 66, 49), "#8a5a35")
  fl(c, R(c, 52, 42, 65, 42), "#a8703e")
  skep(c, 59, 42, 7, 15)
  -- audience of bees, hovering in a row at different heights
  bee(c, 41, 36, true); bee(c, 44, 28, true); bee(c, 39, 22, true)
  bee(c, 47, 33); bee(c, 36, 30); bee(c, 66, 22); bee(c, 50, 22)
  -- the dancing gnome
  local _, G = gnome(c, 26, 47, { d = 1, walk = -1, eyes = "happy", arms = { armd(1, { -4, 7 }, { -9, 13 }, false), armd(1, { 4, 7 }, { 8, 3 }, true) } })
  -- wiggle marks
  for _, p in ipairs({ { 14, 30 }, { 15, 33 }, { 38, 28 } }) do c:px(p[1], p[2], "#f5cf6a"); c:px(p[1] + 1, p[2] + 1, "#f5cf6a") end
  c:px(33, 26, "#f08a24"); c:px(35, 24, "#f08a24")
  finish(c, "w3_bee_dance")
end

-- 3. snail_derby: rainy day, two snails racing on a plank, gnome with a lettuce leaf lure under a leaf umbrella
function S.w3_snail_derby()
  seed = 63
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 26), { "#8c9aa8", "#9aa8b4", "#a8b4be", "#b4c0c8" }, { dir = "v" })
  c:fill(c:ellipse(18, 27, 34, 8), "#5a7a5a"); c:fill(c:ellipse(62, 28, 26, 7), "#4e6e52")
  c:fill(R(c, 0, 27, W - 1, H - 1), "#4e7a48"); c:fill(R(c, 0, 27, W - 1, 27), "#6a9462")
  c:fill(c:ellipse(52, 48, 14, 2), "#8cb0c0"); c:fill(c:ellipse(12, 49, 9, 2), "#8cb0c0")
  -- lettuce bed behind
  for i, x in ipairs({ 32, 44, 66 }) do
    part(c, c:ellipse(x, 49, 4, 3), (i % 2 == 0) and "#8ac86a" or "#6ab05a", { shade = true })
    c:px(x, 48, "#b8e890")
  end
  for x = 4, 70, 7 do c:px(x, 31 + (x % 3), "#3f6a3a"); c:px(x + 1, 30 + (x % 3), "#3f6a3a") end
  -- plank on two blocks
  part(c, R(c, 16, 44, 20, 49), "#8a5a35"); part(c, R(c, 56, 44, 60, 49), "#8a5a35")
  part(c, R(c, 8, 40, 66, 44), "#b07a45")
  fl(c, R(c, 9, 40, 65, 40), "#d9a660")
  for _, x in ipairs({ 22, 38, 50 }) do fl(c, R(c, x, 43, x + 2, 43), "#8a5a35") end
  for x = 10, 64, 4 do c:px(x, 42, "#e8c48a") end
  -- finish ribbon
  part(c, R(c, 60, 32, 60, 42), "#6b3b2a", { noline = true }); part(c, R(c, 68, 32, 68, 42), "#6b3b2a", { noline = true })
  for x = 61, 67 do c:px(x, 33, (x % 2 == 0) and "#dd3a2a" or "#f4eee0"); c:px(x, 34, (x % 2 == 0) and "#f4eee0" or "#dd3a2a") end
  local function snail(x, y, shell)
    part(c, R(c, x, y - 1, x + 9, y), "#d8c4a0")
    fl(c, R(c, x + 8, y - 3, x + 10, y - 1), "#d8c4a0")
    c:px(x + 9, y - 5, "#d8c4a0"); c:px(x + 9, y - 6, INK); c:px(x + 11, y - 4, "#d8c4a0"); c:px(x + 11, y - 5, INK)
    part(c, c:ellipse(x + 3, y - 4, 4, 4), shell)
    fl(c, R(c, x + 2, y - 5, x + 4, y - 5), "#8a4f2a"); c:px(x + 4, y - 4, "#8a4f2a"); c:px(x + 2, y - 3, "#8a4f2a"); c:px(x + 3, y - 3, "#8a4f2a")
  end
  snail(44, 40, "#e0a050"); snail(32, 40, "#b8664a")
  -- gnome under a big leaf, dangling a lettuce leaf in front of the leading snail
  local _, G = gnome(c, 20, 48, { d = 1, eyes = "open", arms = { armd(1, { -3, 8 }, { -3, 21 }, false), armd(1, { 4, 7 }, { 9, 10 }, true) } })
  local lx, ly = G.P(-3, 21)
  fl(c, R(c, lx, ly, lx, ly + 5), "#3f7a38")
  part(c, c:ellipse(lx, ly - 1, 9, 2), "#4e9a48", { shade = true })
  fl(c, R(c, lx - 5, ly - 1, lx + 5, ly - 1), "#6ab05a")
  local hx, hy = G.P(9, 10)
  fl(c, c:line({ { hx, hy }, { 54, 28 } }, 1), "#8a5a35")
  part(c, c:ellipse(55, 30, 3, 2), "#8ac86a")
  -- rain
  seed = 70
  for i = 1, 34 do
    local x, y = 6 + floor(rand() * 62), 6 + floor(rand() * 40)
    c:px(x, y, "#d4e4f0"); c:px(x - 1, y + 1, "#d4e4f0")
  end
  finish(c, "w3_snail_derby")
end

-- 4. croft_bees: chalk tally board, gnome pointing at a bee on a foxglove
function S.w3_croft_bees()
  seed = 64
  local c = new()
  day(c, 36, { cloud = 44 })
  -- chalkboard on posts
  part(c, R(c, 8, 26, 9, 46), "#8a5a35", { noline = true }); part(c, R(c, 27, 26, 28, 46), "#8a5a35", { noline = true })
  part(c, R(c, 5, 12, 31, 31), "#a8703e")
  c:fill(R(c, 7, 14, 29, 29), "#34423e")
  -- tally marks and bee icons
  for g = 0, 1 do
    local x0 = 9 + g * 10
    for k = 0, 3 do fl(c, R(c, x0 + k * 2, 16, x0 + k * 2, 19), "#f4eee0") end
    c:fill(c:line({ { x0 - 1, 19 }, { x0 + 7, 16 } }, 1), "#f4eee0")
  end
  fl(c, R(c, 27, 16, 27, 19), "#f4eee0")
  for g = 0, 3 do bee(c, 9 + g * 5, 22) end
  for g = 0, 1 do fl(c, R(c, 9 + g * 5, 26, 11 + g * 5, 27), "#6e7a74") end
  fl(c, R(c, 25, 26, 27, 27), "#f4eee0")
  -- ledge with chalk
  fl(c, R(c, 8, 30, 28, 30), "#d9a660")
  -- foxgloves and border flowers
  for _, p in ipairs({ { 46, 18 }, { 53, 14 }, { 61, 20 } }) do
    fl(c, R(c, p[1], p[2], p[1], 47), "#3f7a38")
    for k = 0, 3 do
      local y = p[2] + 2 + k * 3
      fl(c, R(c, p[1] - 1, y, p[1] + 1, y + 1), "#b070d0"); c:px(p[1], y + 1, "#7a3a98")
    end
    c:px(p[1], p[2] + 1, "#c890e0")
  end
  for _, p in ipairs({ { 42, 43 }, { 56, 44 }, { 66, 43 } }) do flower(c, p[0 + 1], p[2], "#f4eee0", 4) end
  bee(c, 54, 19); bee(c, 62, 11); bee(c, 47, 27)
  -- gnome pointing at a bee, chalk in the other hand
  local _, G = gnome(c, 38, 47, { d = 1, eyes = "open", arms = { armd(1, { 4, 8 }, { 9, 15 }, true), armd(1, { -4, 7 }, { -6, 4 }, false) } })
  local cx, cy = G.P(-6, 4); fl(c, R(c, cx - 1, cy + 2, cx + 1, cy + 3), "#f4eee0")
  finish(c, "w3_croft_bees")
end

-- 5. seed_drawers: shed cabinet of little drawers, one pulled open showing seeds
function S.w3_seed_drawers()
  seed = 65
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 44), "#c9a96e")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 44), "#b8965c") end
  c:fill(R(c, 0, 45, W - 1, H - 1), "#8a5a35")
  for y = 48, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#6b3b2a") end
  -- window and hanging herbs
  part(c, R(c, 16, 5, 36, 15), "#a8703e")
  c:fill(R(c, 18, 7, 34, 13), "#a8d4e0"); c:fill(R(c, 18, 7, 34, 9), "#bcdde4"); fl(c, R(c, 26, 7, 26, 13), "#a8703e")
  fl(c, R(c, 55, 5, 67, 5), "#6b3b2a")
  for i, x in ipairs({ 56, 60, 64 }) do
    fl(c, R(c, x, 6, x, 9), "#5e3f28")
    part(c, R(c, x - 1, 10, x + 1, 14), (i == 2) and "#8a6ab8" or "#4e8a3c")
  end
  -- cabinet
  part(c, R(c, 8, 18, 49, 47), "#8a5a35")
  local seedc = { "#e8a317", "#dd3a2a", "#5a3a22", "#4f9a45", "#e46a9b", "#f4eee0", "#3f8fb0", "#c8802a" }
  for r = 0, 3 do
    for k = 0, 3 do
      local x0, y0 = 10 + k * 10, 20 + r * 7
      if not (r == 2 and k == 3) then
        fl(c, R(c, x0, y0, x0 + 8, y0 + 5), "#b07a45"); fl(c, R(c, x0, y0, x0 + 8, y0), "#d9a660")
        fl(c, R(c, x0 + 3, y0 + 3, x0 + 5, y0 + 3), "#5e3f28")
        fl(c, R(c, x0 + 1, y0 + 1, x0 + 2, y0 + 2), seedc[(r * 4 + k) % 8 + 1])
      end
    end
  end
  -- the open drawer: dark socket, seeds heaped, pulled-out front below
  fl(c, R(c, 40, 34, 48, 39), "#3d2a1c")
  fl(c, R(c, 39, 38, 49, 42), "#b07a45"); fl(c, R(c, 39, 38, 49, 38), "#d9a660"); fl(c, R(c, 43, 41, 45, 41), "#5e3f28")
  c:outline(R(c, 39, 38, 49, 42))
  for i, p in ipairs({ { 40, 36 }, { 42, 35 }, { 44, 36 }, { 46, 35 }, { 48, 36 }, { 41, 37 }, { 45, 37 }, { 47, 37 } }) do fl(c, R(c, p[1], p[2], p[1], p[2]), seedc[i]) end
  -- rattling seed spill
  for _, p in ipairs({ { 52, 41 }, { 54, 44 }, { 51, 46 } }) do c:px(p[1], p[2], "#e8a317") end
  c:px(53, 45, "#dd3a2a")
  -- gnome pulling the drawer
  gnome(c, 59, 47, { d = -1, eyes = "open", arms = { armd(-1, { 4, 7 }, { 9, 11 }, true), armd(-1, { -4, 7 }, { -6, 4 }, false) } })
  finish(c, "w3_seed_drawers")
end

-- 6. bees_next_flower: four border flowers, a fat bumblebee hovering, gnome pointing a bet with a honey drop
function S.w3_bees_next_flower()
  seed = 66
  local c = new()
  day(c, 33, { cloud = 50, sky = { "#a8d4e8", "#c0e0ea", "#d4ecea" } })
  local fl4 = { { 28, 22, "#dd3a2a", 4 }, { 38, 16, "#f5cf6a", 4 }, { 49, 24, "#5a7ad0", 3 }, { 60, 18, "#e46a9b", 4 } }
  for _, f in ipairs(fl4) do
    part(c, R(c, f[1], f[2] + 2, f[1], 48), "#3f7a38", { noline = true })
    fl(c, R(c, f[1] - 3, f[2] + 14, f[1] - 1, f[2] + 15), "#4e9a48"); fl(c, R(c, f[1] + 1, f[2] + 9, f[1] + 3, f[2] + 10), "#4e9a48")
    part(c, c:ellipse(f[1], f[2], f[4] + 1, f[4] + 1), f[3], { shade = true })
    fl(c, c:ellipse(f[1], f[2], 1, 1), (f[3] == "#f5cf6a") and "#8a4f2a" or "#f5cf6a")
  end
  -- dotted flight path: she wanders towards the second flower
  for _, p in ipairs({ { 28, 41 }, { 31, 38 }, { 34, 41 }, { 37, 36 }, { 39, 32 } }) do c:px(p[1], p[2], "#f4eee0") end
  bee(c, 44, 33, true)
  c:px(33, 14, "#f5cf6a"); c:px(54, 14, "#f5cf6a")
  -- the gnome points; the other hand holds a honey drop
  local _, G = gnome(c, 12, 48, { d = 1, eyes = "open", arms = { armd(1, { 4, 8 }, { 10, 15 }, true), armd(1, { -4, 7 }, { 2, 4 }, true, true) } })
  local hx, hy = G.P(3, 7)
  part(c, c:ellipse(hx, hy - 1, 2, 2), "#e8a317"); c:px(hx, hy - 4, "#e8a317"); c:px(hx - 1, hy - 1, "#fff1c8")
  fl(c, R(c, hx - 1, hy + 1, hx + 1, hy + 2), "#f0c8a0")
  finish(c, "w3_bees_next_flower")
end

-- 7. sprouting_pot: four pots on a sunny sill, a tiny sprout in one, gnome peering with a magnifier
function S.w3_sprouting_pot()
  seed = 67
  local c = new()
  c:fill(R(c, 0, 0, W - 1, H - 1), "#c9a96e")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 40), "#b8965c") end
  -- big window with a view
  part(c, R(c, 5, 5, 54, 33), "#a8703e")
  c:bands(R(c, 7, 7, 52, 31), { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  c:fill(c:ellipse(18, 31, 16, 6):clip(R(c, 7, 7, 52, 31)), "#5e8a44"); c:fill(c:ellipse(46, 32, 14, 5):clip(R(c, 7, 7, 52, 31)), "#4e8a3c")
  c:fill(c:ellipse(20, 12, 5, 2), "#f4eee0"); c:fill(c:ellipse(16, 11, 3, 1), "#f4eee0")
  fl(c, R(c, 29, 7, 30, 31), "#a8703e"); fl(c, R(c, 7, 19, 52, 20), "#a8703e")
  -- sill shelf
  part(c, R(c, 4, 35, 68, 38), "#d9a660")
  part(c, R(c, 10, 39, 12, 44), "#8a5a35", { noline = true }); part(c, R(c, 40, 39, 42, 44), "#8a5a35", { noline = true })
  c:fill(R(c, 5, 45, 68, 49), "#8a5a35"); fl(c, R(c, 5, 47, 68, 47), "#6b3b2a")
  for i, x in ipairs({ 13, 24, 35, 46 }) do
    part(c, c:poly({ { x - 4, 28 }, { x + 5, 28 }, { x + 4, 35 }, { x - 3, 35 } }), "#c4623a")
    part(c, R(c, x - 5, 26, x + 5, 28), "#d9743f")
    fl(c, R(c, x - 4, 26, x + 4, 26), "#3d2a1c")
    if i == 4 then
      fl(c, R(c, x, 20, x, 25), "#4e9a48"); fl(c, R(c, x - 2, 20, x - 1, 21), "#6ab05a"); fl(c, R(c, x + 1, 19, x + 3, 20), "#6ab05a"); c:px(x + 3, 21, "#6ab05a")
      c:px(x, 19, "#8fd070")
    end
  end
  -- gnome with a magnifier peering at the sprout pot
  local _, G = gnome(c, 60, 48, { d = -1, eyes = "open", arms = { armd(-1, { 4, 8 }, { 8, 13 }, true), armd(-1, { -4, 7 }, { -5, 4 }, false) } })
  local lx, ly = 55, 25
  fl(c, c:line({ { G.P(-8, 13) }, { lx - 1, ly + 3 } }, 1), "#6b3b2a")
  part(c, c:ellipse(lx, ly, 4, 4), "#b8e0e8", { noline = false })
  fl(c, R(c, lx - 2, ly - 2, lx - 1, ly - 2), "#f4f8fa"); c:px(lx - 2, ly - 1, "#f4f8fa")
  fl(c, R(c, lx - 1, ly + 6, lx + 1, ly + 7), "#f0c8a0")
  finish(c, "w3_sprouting_pot")
end

-- 8. garden_pump: gnome heaving the long pump handle, water running down a stone channel to the beds
function S.w3_garden_pump()
  seed = 68
  local c = new()
  day(c, 33, { cloud = 14 })
  -- garden beds at right with sprouts
  c:fill(R(c, 46, 38, 68, 44), "#6b4a2e")
  for x = 48, 66, 4 do
    fl(c, R(c, x, 36, x, 38), "#3f7a38"); fl(c, R(c, x - 1, 35, x - 1, 36), "#6ab05a"); fl(c, R(c, x + 1, 35, x + 1, 36), "#6ab05a")
  end
  -- stone channel with water
  part(c, R(c, 36, 45, 68, 49), "#a8aeb4")
  fl(c, R(c, 37, 46, 67, 48), "#58a0d0"); for x = 40, 64, 5 do fl(c, R(c, x, 47, x + 2, 47), "#a8d8f0") end
  -- pump: base, column, head, spout
  part(c, R(c, 26, 44, 37, 49), "#8b8f96", { shade = true })
  part(c, R(c, 29, 24, 33, 44), "#4a5058")
  fl(c, R(c, 30, 26, 30, 43), "#6a7078")
  part(c, R(c, 27, 21, 35, 27), "#4a5058")
  part(c, R(c, 33, 31, 40, 34), "#4a5058")
  c:fill(R(c, 39, 34, 40, 35), "#4a5058")
  -- water out of the spout and splash
  for _, p in ipairs({ { 41, 35 }, { 42, 37 }, { 42, 39 }, { 42, 41 }, { 42, 43 } }) do fl(c, R(c, p[1], p[2], p[1], p[2] + 1), "#58a0d0") end
  c:px(40, 44, "#a8d8f0"); c:px(44, 44, "#a8d8f0"); c:px(39, 42, "#a8d8f0"); c:px(45, 41, "#a8d8f0")
  -- gnome pulling the handle down, both hands on the grip
  local _, G = gnome(c, 14, 48, { d = 1, walk = -1, eyes = "open", arms = { armd(1, { 3, 7 }, { 7, 15 }, false), armd(1, { 4, 7 }, { 8, 14 }, true) } })
  local gx, gy = G.P(8, 15)
  part(c, c:line({ { 33, 22 }, { gx, gy } }, 2), "#4a5058", { noline = true })
  fl(c, R(c, 34, 20, 38, 21), "#4a5058"); fl(c, R(c, 38, 18, 39, 21), "#4a5058")
  fl(c, R(c, gx - 1, gy - 1, gx + 1, gy + 1), "#f0c8a0")
  -- spray from the gush
  for _, p in ipairs({ { 52, 30 }, { 58, 26 }, { 64, 32 } }) do c:px(p[1], p[2], "#a8d8f0") end
  finish(c, "w3_garden_pump")
end

-- 9. telling_bees: seated gnome whispering to a row of hives, bees listening
function S.w3_telling_bees()
  seed = 69
  local c = new()
  day(c, 34, { cloud = 24, sky = { "#c8d8e4", "#e4dcd8", "#f4e0c8" }, hill = "#5e8a44" })
  -- stool and trestle
  part(c, R(c, 34, 41, 68, 43), "#8a5a35")
  part(c, R(c, 39, 43, 41, 49), "#8a5a35", { noline = true }); part(c, R(c, 63, 43, 65, 49), "#8a5a35", { noline = true })
  -- two skeps and a box hive
  skep(c, 41, 41, 6, 11)
  part(c, R(c, 48, 31, 58, 41), "#f4eee0")
  fl(c, R(c, 48, 35, 58, 35), "#c8c0b0"); fl(c, R(c, 48, 38, 58, 38), "#c8c0b0"); fl(c, R(c, 52, 39, 54, 40), "#2a1a10")
  part(c, c:poly({ { 53, 25 }, { 61, 31 }, { 45, 31 } }), "#c0442e")
  fl(c, R(c, 55, 32, 56, 34), "#2a1a10"); fl(c, R(c, 55, 34, 57, 36), "#2a1a10")
  skep(c, 64, 41, 4, 9)
  -- bees at the entrances and drifting near
  bee(c, 52, 21); bee(c, 36, 33); bee(c, 46, 26); bee(c, 60, 24); bee(c, 66, 30)
  -- whispering gnome on a milking stool
  part(c, R(c, 10, 40, 20, 42), "#b07a45"); part(c, R(c, 12, 43, 13, 48), "#8a5a35", { noline = true }); part(c, R(c, 17, 43, 18, 48), "#8a5a35", { noline = true })
  local _, G = gnome(c, 15, 40, { d = 1, sit = true, eyes = "happy", arms = { armd(1, { 3, 7 }, { 7, 11 }, true, true), armd(1, { -3, 7 }, { 0, 3 }, false, true) } })
  local hx, hy = G.P(7, 12)
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0")
  -- murmured words as small notes drifting to the hives
  for _, p in ipairs({ { 28, 25 }, { 31, 28 }, { 33, 25 }, { 24, 28 } }) do c:px(p[1], p[2], "#f5cf6a"); c:px(p[1], p[2] - 1, "#f5cf6a") end
  finish(c, "w3_telling_bees")
end

-- 10. remedy_mishaps: dusk, gnome reading the crossed-out remedy book; a hugely fluffed cat; fizzing bottle
function S.w3_remedy_mishaps()
  seed = 70
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#3b2f66", "#4e3a78", "#7a4a88", "#b45a7c", "#e8825e", "#f0a868" }, { dir = "v" })
  for _, p in ipairs({ { 9, 8 }, { 24, 6 }, { 44, 9 }, { 58, 6 }, { 64, 14 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(c:ellipse(12, 36, 28, 9), "#2f2a58"); c:fill(c:ellipse(60, 35, 30, 9), "#352c5c")
  c:fill(R(c, 0, 35, W - 1, H - 1), "#3a5a42"); c:fill(R(c, 0, 35, W - 1, 35), "#4a6c4a")
  -- thyme bushes
  for _, p in ipairs({ { 30, 37 }, { 66, 38 } }) do part(c, c:ellipse(p[1], p[2], 4, 2), "#3f6a3a", { shade = true }); c:px(p[1] - 1, p[2] - 1, "#8a6ab8"); c:px(p[1] + 2, p[2] - 1, "#8a6ab8") end
  -- stump with fizzing bottle and a glowing lantern
  part(c, R(c, 28, 43, 38, 49), "#8a5a35"); fl(c, R(c, 29, 43, 37, 43), "#a8703e")
  part(c, R(c, 29, 35, 32, 42), "#58c878"); part(c, R(c, 30, 32, 31, 34), "#e8c48a")
  c:px(30, 38, "#c8f4d4"); c:px(30, 28, "#c8f4d4"); c:px(32, 30, "#c8f4d4"); c:px(29, 25, "#c8f4d4")
  part(c, R(c, 34, 38, 37, 42), "#ffd86a"); fl(c, R(c, 35, 39, 36, 41), "#fff1c8"); fl(c, R(c, 34, 37, 37, 37), "#3d2a1c")
  -- fluffed-up cat
  part(c, c:ellipse(15, 41, 8, 7), "#c8c8d4", { shade = true })
  for _, p in ipairs({ { 5, 38 }, { 6, 34 }, { 9, 33 }, { 15, 32 }, { 20, 33 }, { 22, 36 }, { 23, 41 }, { 22, 45 }, { 6, 44 } }) do
    fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#c8c8d4"); c:px(p[1], p[2], INK)
  end
  part(c, c:poly({ { 10, 34 }, { 11, 29 }, { 14, 34 } }), "#c8c8d4"); part(c, c:poly({ { 17, 34 }, { 19, 29 }, { 21, 34 } }), "#c8c8d4")
  fl(c, R(c, 11, 38, 13, 40), "#f4f8fa"); fl(c, R(c, 17, 38, 19, 40), "#f4f8fa")
  c:px(12, 39, INK); c:px(18, 39, INK); c:px(12, 38, INK); c:px(18, 38, INK)
  c:px(15, 42, "#e08a7a"); fl(c, R(c, 13, 44, 17, 44), INK)
  part(c, R(c, 10, 48, 12, 49), "#c8c8d4", { noline = true }); part(c, R(c, 18, 48, 20, 49), "#c8c8d4", { noline = true })
  -- gnome reading the crossed-out book
  local _, G = gnome(c, 54, 48, { d = -1, eyes = "open", arms = { armd(-1, { 4, 7 }, { 7, 4 }, true, true), armd(-1, { -4, 7 }, { -7, 4 }, true, true) } })
  local bx, by = G.P(0, 3)
  part(c, R(c, bx - 7, by - 3, bx + 7, by + 3), "#a8703e")
  fl(c, R(c, bx - 6, by - 2, bx - 1, by + 2), "#f4eee0"); fl(c, R(c, bx + 1, by - 2, bx + 6, by + 2), "#f4eee0")
  fl(c, R(c, bx, by - 2, bx, by + 2), "#c8b090")
  for k = 0, 1 do fl(c, R(c, bx - 5, by - 1 + k * 2, bx - 2, by - 1 + k * 2), "#8a6a50") end
  for k = 0, 1 do fl(c, R(c, bx + 2, by - 1 + k * 2, bx + 5, by - 1 + k * 2), "#8a6a50") end
  c:fill(c:line({ { bx + 2, by - 2 }, { bx + 5, by + 2 } }, 1), "#dd3a2a"); c:fill(c:line({ { bx + 5, by - 2 }, { bx + 2, by + 2 } }, 1), "#dd3a2a")
  fl(c, R(c, bx - 9, by - 1, bx - 8, by + 1), "#f0c8a0"); fl(c, R(c, bx + 8, by - 1, bx + 9, by + 1), "#f0c8a0")
  for _, p in ipairs({ { 22, 20 }, { 48, 24 }, { 62, 20 } }) do c:px(p[1], p[2], "#ffe08a") end
  finish(c, "w3_remedy_mishaps")
end

-- barn wall helper: vertical red planks
local function barnwall(c, y1)
  c:fill(R(c, 0, 0, W - 1, y1), "#a8503a")
  for x = 0, W - 1, 5 do fl(c, R(c, x, 0, x, y1), "#8e3e2c") end
  for x = 2, W - 1, 10 do c:px(x + 1, 14, "#6b2c20"); c:px(x + 3, 30, "#6b2c20") end
end

-- 11. hinge_oil: barn door ajar, gnome with an oilcan dripping on the strap hinge, squeaks fading
function S.w4_hinge_oil()
  seed = 71
  local c = new()
  barnwall(c, 44)
  c:fill(R(c, 0, 45, W - 1, H - 1), "#b8965c"); fl(c, R(c, 0, 45, W - 1, 45), "#d9bc84")
  for _, p in ipairs({ { 8, 48 }, { 22, 50 }, { 58, 48 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#9a7a46") end
  fl(c, R(c, 0, 5, W - 1, 8), "#4a2c1a"); fl(c, R(c, 0, 9, W - 1, 9), "#3d2a1c")
  -- dark gap, post, and the leaf of the door
  part(c, R(c, 29, 10, 68, 45), "#2a1a10", { noline = true })
  part(c, R(c, 29, 10, 32, 45), "#8a5a35")
  part(c, R(c, 36, 12, 68, 44), "#c27a4a")
  for x = 36, 68, 6 do fl(c, R(c, x, 13, x, 43), "#9a5e36") end
  c:fill(c:line({ { 37, 14 }, { 67, 42 } }, 1), "#8a5a35")
  fl(c, R(c, 36, 12, 68, 12), "#e0a470")
  -- hinge straps with barrels
  for _, y in ipairs({ 16, 36 }) do
    part(c, R(c, 36, y, 52, y + 3), "#3d4048"); part(c, R(c, 32, y - 1, 36, y + 4), "#4a5058")
    fl(c, R(c, 38, y + 1, 51, y + 1), "#6a7078")
    for _, x in ipairs({ 42, 47, 51 }) do c:px(x, y + 2, "#9aa0a8") end
  end
  -- squeak zigzags from the top hinge, fading
  for i, col in ipairs({ "#f5cf6a", "#e8c48a", "#c9a96e" }) do
    local x = 54 + i * 4
    c:px(x, 17, col); c:px(x + 1, 16, col); c:px(x + 2, 17, col); c:px(x + 3, 16, col)
    c:px(x, 21, col); c:px(x + 1, 22, col); c:px(x + 2, 21, col)
  end
  -- gnome with oilcan
  local _, G = gnome(c, 18, 48, { d = 1, eyes = "open", arms = { armd(1, { 4, 8 }, { 9, 13 }, true), armd(1, { -4, 7 }, { -5, 4 }, false) } })
  local hx, hy = G.P(9, 13)
  part(c, R(c, hx - 1, hy - 5, hx + 4, hy - 1), "#e8a317")
  fl(c, R(c, hx, hy - 4, hx + 1, hy - 4), "#fff1c8")
  fl(c, c:line({ { hx + 3, hy - 5 }, { 33, 37 } }, 1), "#aeb4bc")
  c:px(33, 38, "#aeb4bc")
  fl(c, R(c, hx - 1, hy, hx + 1, hy + 1), "#f0c8a0")
  -- oil drops
  fl(c, R(c, 33, 40, 33, 41), "#e8a317"); c:px(33, 44, "#e8a317")
  finish(c, "w4_hinge_oil")
end

-- 12. spring_drawer: tray of springs knotted into a silver hedgehog, gnome tugging a coil, one freed spring boinging up
function S.w4_spring_drawer()
  seed = 72
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 42), "#c9a96e")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 42), "#b8965c") end
  c:fill(R(c, 0, 43, W - 1, H - 1), "#8a5a35"); fl(c, R(c, 0, 49, W - 1, 49), "#6b3b2a")
  -- pegboard with tools
  part(c, R(c, 6, 7, 26, 22), "#a8703e")
  fl(c, R(c, 10, 10, 11, 19), "#aeb4bc"); fl(c, R(c, 9, 9, 12, 10), "#8b929c")
  fl(c, R(c, 16, 10, 16, 20), "#8a5a35"); fl(c, R(c, 14, 10, 18, 12), "#8b929c")
  fl(c, R(c, 21, 11, 22, 20), "#aeb4bc"); fl(c, R(c, 20, 20, 23, 21), "#8a5a35")
  -- workbench
  part(c, R(c, 28, 40, 68, 43), "#d9a660")
  part(c, R(c, 29, 44, 67, 49), "#a8703e")
  fl(c, R(c, 44, 46, 52, 46), "#5e3f28")
  -- tray with the knot of springs
  fl(c, R(c, 33, 29, 63, 34), "#3d2a1c")
  local knot = c:ellipse(48, 30, 12, 8)
  part(c, knot, "#aeb4bc", { shade = false })
  for _, q in ipairs({ { 37, 26, 34, 22 }, { 42, 22, 40, 17 }, { 48, 21, 49, 15 }, { 54, 22, 57, 17 }, { 59, 26, 63, 23 }, { 60, 31, 64, 30 }, { 36, 31, 32, 31 } }) do
    c:fill(c:line({ { q[1], q[2] }, { q[3], q[4] } }, 1), "#8b929c")
    c:px(q[3], q[4], "#e8ecf0")
  end
  local rings = { { 43, 29, 6, 5 }, { 49, 28, 7, 4 }, { 54, 31, 5, 5 }, { 46, 32, 8, 3 }, { 51, 26, 4, 4 } }
  for _, r in ipairs(rings) do
    local m = c:ellipse(r[1], r[2], r[3], r[4]):cut(c:ellipse(r[1], r[2], r[3] - 1, r[4] - 1)):clip(knot)
    c:fill(m, "#5a6068")
  end
  for _, q in ipairs({ { 42, 26 }, { 49, 25 }, { 56, 28 }, { 46, 33 } }) do c:px(q[1], q[2], "#f4f8fa"); c:px(q[1] + 1, q[2], "#f4f8fa") end
  c:px(54, 29, INK); c:px(58, 30, INK); c:px(60, 31, "#e08a7a")
  -- tray front
  part(c, R(c, 31, 34, 65, 40), "#b07a45")
  fl(c, R(c, 32, 34, 64, 34), "#d9a660"); fl(c, R(c, 46, 37, 50, 37), "#5e3f28")
  -- gnome tugging a coil that has caught his sleeve
  local _, G = gnome(c, 18, 48, { d = 1, eyes = "open", arms = { armd(1, { 4, 8 }, { 9, 12 }, true, true), armd(1, { -4, 7 }, { -6, 4 }, false) } })
  local hx, hy = G.P(9, 12)
  local pts = { { hx, hy }, { hx + 3, hy - 3 }, { hx + 6, hy }, { hx + 9, hy - 3 }, { hx + 12, hy - 1 }, { 36, 30 } }
  c:fill(c:line(pts, 1), "#6a7078")
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0")
  -- freed little spring, brass, boinging
  local bx, by = 30, 12
  for k = 0, 3 do fl(c, R(c, bx, by + k * 2, bx + 3, by + k * 2), "#e8a317"); c:px(bx + (k % 2) * 3, by + k * 2 + 1, "#e8a317") end
  fl(c, R(c, bx + 1, by - 1, bx + 2, by - 1), "#fff1c8")
  for _, p in ipairs({ { 26, 10 }, { 35, 10 }, { 26, 20 }, { 35, 20 } }) do c:px(p[1], p[2], "#f5cf6a") end
  finish(c, "w4_spring_drawer")
end

-- 13. flying_trial: gnome in a canvas-winged wheelbarrow, airborne, pond below
function S.w4_flying_trial()
  seed = 73
  local c = new()
  day(c, 38, { cloud = 56, sky = { "#9cc8e8", "#b0d6ec", "#c8e4f0" } })
  -- windsock pole on the left


  -- pond with a duck
  c:fill(c:ellipse(58, 45, 14, 4), "#7cb8d8"); fl(c, R(c, 50, 45, 56, 45), "#bce0f0")
  part(c, c:ellipse(60, 44, 3, 2), "#f4eee0"); fl(c, R(c, 62, 41, 64, 43), "#f4eee0"); c:px(65, 42, "#e8a317"); c:px(64, 41, INK)
  -- shadow
  c:fill(c:ellipse(36, 47, 10, 2), "#6a9a4a")
  -- wings first (behind): struts and canvas
  local wl = c:poly({ { 31, 33 }, { 9, 19 }, { 8, 27 }, { 22, 36 } })
  local wr = c:poly({ { 39, 33 }, { 62, 19 }, { 63, 27 }, { 48, 36 } })
  part(c, wl, "#f4eee0", { shade = true }); part(c, wr, "#f4eee0", { shade = true })
  c:fill(c:line({ { 31, 33 }, { 9, 19 } }, 1), "#8a5a35"); c:fill(c:line({ { 39, 33 }, { 62, 19 } }, 1), "#8a5a35")
  c:fill(c:line({ { 24, 33 }, { 13, 26 } }, 1), "#c8b090"); c:fill(c:line({ { 46, 33 }, { 57, 26 } }, 1), "#c8b090")
  -- gnome sitting in the barrow
  local _, G = gnome(c, 35, 41, { d = 1, upper = true, eyes = "open", arms = { armd(1, { -4, 7 }, { -9, 12 }, true), armd(1, { 4, 7 }, { 9, 12 }, true) } })
  -- barrow tub, handles, wheel
  part(c, c:poly({ { 24, 36 }, { 46, 36 }, { 43, 44 }, { 28, 44 } }), "#b07a45")
  fl(c, R(c, 25, 36, 45, 36), "#d9a660"); fl(c, R(c, 29, 40, 43, 40), "#8a5a35")
  c:fill(c:line({ { 25, 40 }, { 14, 46 } }, 2), "#6b3b2a"); c:fill(c:line({ { 14, 46 }, { 12, 46 } }, 2), "#6b3b2a")
  part(c, c:ellipse(46, 44, 3, 3), "#2a2018"); c:px(46, 44, "#aeb4bc")
  -- wind streaks
  for _, p in ipairs({ { 10, 12 }, { 22, 9 }, { 12, 33 }, { 56, 12 } }) do fl(c, R(c, p[1], p[2], p[1] + 6, p[2]), "#f4f8fa"); c:px(p[1] + 7, p[2] + 1, "#f4f8fa") end
  finish(c, "w4_flying_trial")
end

-- 14. lost_spectacles: dawn workshop, the tinker hunting everywhere, her spectacles on her own hat
function S.w4_lost_spectacles()
  seed = 74
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 44), "#b89a86")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 44), "#a68672") end
  c:fill(R(c, 0, 45, W - 1, H - 1), "#7a5a40"); fl(c, R(c, 0, 49, W - 1, 49), "#5e3f28")
  -- dawn window
  part(c, R(c, 6, 6, 26, 28), "#a8703e")
  c:bands(R(c, 8, 8, 24, 26), { "#7a6aa8", "#c46a8a", "#e8825e", "#f5b870", "#f8d890" }, { dir = "v" })
  c:fill(c:ellipse(16, 27, 10, 4):clip(R(c, 8, 8, 24, 26)), "#4a4a78")
  c:fill(c:ellipse(16, 24, 3, 3):clip(R(c, 8, 8, 24, 26)), "#fff1c8")
  fl(c, R(c, 16, 8, 16, 26), "#a8703e"); fl(c, R(c, 8, 17, 24, 17), "#a8703e")
  -- light patch on the floor
  c:fill(c:poly({ { 8, 45 }, { 26, 45 }, { 32, 52 }, { 4, 52 } }), "#d49a6a")
  -- shelf with kettle, jars and three wrong pairs of spectacles
  part(c, R(c, 38, 22, 68, 24), "#a8703e")
  part(c, R(c, 40, 24, 41, 27), "#8a5a35", { noline = true }); part(c, R(c, 65, 24, 66, 27), "#8a5a35", { noline = true })
  part(c, R(c, 63, 15, 67, 21), "#e8a317")
  local function specs(x, y)
    part(c, R(c, x - 1, y - 1, x + 1, y + 1), "#bfe6f0"); part(c, R(c, x + 6, y - 1, x + 8, y + 1), "#bfe6f0")
    fl(c, R(c, x + 2, y - 1, x + 5, y - 1), INK)
    c:px(x - 1, y - 1, "#f4f8fa")
  end
  specs(41, 20); specs(51, 20); specs(50, 11)
  fl(c, R(c, 52, 7, 52, 9), "#6b3b2a"); fl(c, R(c, 57, 7, 57, 9), "#6b3b2a")
  -- the tinker, searching with open palms
  local _, G = gnome(c, 34, 48, { d = 1, hat = "#4f9a45", eyes = "open", arms = { armd(1, { -4, 7 }, { -9, 10 }, false), armd(1, { 4, 7 }, { 9, 10 }, true) } })
  c:fill(R(c, 32, 29, 40, 29), "#2a1a10")
  -- her spectacles on top of her hat, glass flashing
  local hx, hy = G.tipx, G.tipy
  specs(hx - 3, hy + 6)
  -- the helper gnome pointing it out
  gnome(c, 56, 48, { d = -1, eyes = "happy", arms = { armd(-1, { 4, 8 }, { 12, 17 }, true), armd(-1, { -4, 7 }, { -5, 4 }, false) } })
  for _, p in ipairs({ { 30, 26 }, { 40, 25 }, { 36, 22 } }) do c:px(p[1], p[2], "#fff1c8"); c:px(p[1] - 1, p[2], "#f5cf6a"); c:px(p[1] + 1, p[2], "#f5cf6a") end
  finish(c, "w4_lost_spectacles")
end

-- 15. glue_pot: snowy window, gnome in a scarf stirring a pot of glue on the stove, stuck-together planks on the bench
function S.w4_glue_pot()
  seed = 75
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 44), "#a8987a")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 44), "#94846a") end
  c:fill(R(c, 0, 45, W - 1, H - 1), "#6b4a34"); fl(c, R(c, 0, 49, W - 1, 49), "#4a3224")
  -- frosty window with snow outside
  part(c, R(c, 6, 6, 28, 28), "#a8703e")
  c:bands(R(c, 8, 8, 26, 26), { "#c0d0e0", "#d0dce8", "#e0e8f0" }, { dir = "v" })
  c:fill(c:ellipse(12, 27, 12, 5):clip(R(c, 8, 8, 26, 26)), "#f4f8fa"); c:fill(c:ellipse(24, 27, 8, 4):clip(R(c, 8, 8, 26, 26)), "#f4f8fa")
  fl(c, R(c, 17, 8, 17, 26), "#a8703e"); fl(c, R(c, 8, 17, 26, 17), "#a8703e")
  for _, p in ipairs({ { 12, 11 }, { 21, 13 }, { 11, 21 }, { 22, 22 }, { 14, 14 } }) do c:px(p[1], p[2], "#fbfdfe") end
  -- frost in the corners
  for _, p in ipairs({ { 8, 8 }, { 9, 9 }, { 10, 8 }, { 8, 10 }, { 26, 8 }, { 25, 9 }, { 24, 8 }, { 26, 10 }, { 8, 26 }, { 9, 25 }, { 26, 26 }, { 25, 25 } }) do c:px(p[1], p[2], "#f4f8fa") end
  -- icicles under the sill-top
  for _, x in ipairs({ 9, 14, 20, 25 }) do fl(c, R(c, x, 29, x, 30 + (x % 3)), "#e8f4fa") end
  fl(c, R(c, 5, 29, 29, 29), "#f4f8fa")
  -- bench with two planks being clamped
  part(c, R(c, 4, 40, 28, 43), "#d9a660"); part(c, R(c, 6, 44, 8, 49), "#8a5a35", { noline = true }); part(c, R(c, 24, 44, 26, 49), "#8a5a35", { noline = true })
  part(c, R(c, 9, 36, 22, 37), "#e8c48a"); part(c, R(c, 9, 38, 22, 39), "#c8a060")
  fl(c, R(c, 14, 38, 16, 38), "#e8a317")
  part(c, R(c, 24, 33, 25, 39), "#6a7078"); part(c, R(c, 20, 33, 25, 34), "#6a7078")
  -- stove with pipe
  part(c, R(c, 55, 3, 57, 31), "#3d4048", { noline = true })
  part(c, R(c, 46, 36, 67, 49), "#3d4048")
  fl(c, R(c, 47, 37, 66, 37), "#6a7078")
  fl(c, R(c, 50, 42, 62, 46), "#f08a24"); fl(c, R(c, 52, 43, 60, 45), "#ffd86a")
  fl(c, R(c, 50, 41, 62, 41), "#2a2018")
  -- pot of glue
  part(c, R(c, 48, 30, 64, 36), "#5a5e68")
  part(c, c:ellipse(56, 30, 8, 2), "#2a2018"); c:fill(c:ellipse(56, 30, 6, 1), "#e8a317"); c:px(54, 30, "#fff1c8")
  for _, p in ipairs({ { 61, 25 }, { 63, 22 }, { 61, 19 }, { 63, 16 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#f4f8fa") end
  -- gnome in a scarf, stirring
  local _, G = gnome(c, 38, 48, { d = 1, eyes = "open", arms = { armd(1, { 4, 8 }, { 8, 17 }, true), armd(1, { -4, 7 }, { -6, 4 }, false) } })
  fl(c, R(c, 35, 39, 41, 39), "#3f8a5a"); fl(c, R(c, 35, 40, 41, 40), "#f4eee0"); fl(c, R(c, 41, 40, 42, 44), "#3f8a5a")
  local hx, hy = G.P(8, 17)
  c:fill(c:line({ { hx, hy - 1 }, { 54, 33 } }, 2), "#e8c48a")
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0")
  fl(c, R(c, 53, 33, 54, 35), "#e8a317")
  finish(c, "w4_glue_pot")
end

local order = { "w3_herb_spiral", "w3_bee_dance", "w3_snail_derby", "w3_croft_bees", "w3_seed_drawers", "w3_bees_next_flower", "w3_sprouting_pot", "w3_garden_pump", "w3_telling_bees", "w3_remedy_mishaps", "w4_hinge_oil", "w4_spring_drawer", "w4_flying_trial", "w4_lost_spectacles", "w4_glue_pot" }
for _, s2 in ipairs(order) do
  if not only or only == s2 then seed = 7; S[s2]() end
end
