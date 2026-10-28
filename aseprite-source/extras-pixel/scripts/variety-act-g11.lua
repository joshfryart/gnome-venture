-- variety-act-g11.lua : Do-tab scenes for 15 mill rest-stop activities -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g11.lua   (params BEFORE --script)
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
  slug = "w2_" .. slug
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

-- ---------- shared mill props
local WOOD, WOODL, WOODD = "#8a5a35", "#a8703e", "#6b3b2a"
local STONE, STONEL = "#8b8f96", "#aeb4bc"

-- water wheel: ring + 8 spokes + hub, paddles round the rim (flat fills, one outline). pcol(k) -> paddle colour
local function wheel(c, cx, cy, r, col, pcol)
  local m = c:mask()
  m:add(c:ellipse(cx, cy, r, r)); m:cut(c:ellipse(cx, cy, r - 2, r - 2))
  local pm = {}
  local n = math.max(8, floor(r * 0.8))
  local all = m:copy()
  for k = 0, n - 1 do
    local a = k * 2 * math.pi / n + 0.1
    local px, py = cx + rnd(math.cos(a) * (r + 1)), cy + rnd(math.sin(a) * (r + 1))
    local q = c:mask(); q:add(c:rect(px - 1, py - 1, px, py)); pm[k] = q; all:add(q)
  end
  local sp = c:mask()
  for k = 0, 3 do
    local a = k * math.pi / 4 + 0.2
    local dx, dy = rnd(math.cos(a) * (r - 1)), rnd(math.sin(a) * (r - 1))
    sp:add(c:line({ { cx - dx, cy - dy }, { cx + dx, cy + dy } }, 1))
  end
  all:add(sp); all:add(c:ellipse(cx, cy, 1, 1))
  c:fill(all, col)
  for k = 0, n - 1 do if pcol then c:fill(pm[k], pcol(k)) else c:fill(pm[k], "#c08a52") end end
  c:fill(c:ellipse(cx, cy, 1, 1), "#4a2c1a")
  c:outline(all, { ol = 1, olx = 0 })
end

local function sack(c, x, y, w, h, col, tie)
  col = col or "#d9c8a0"
  part(c, c:rrect(x, y + 2, x + w - 1, y + h - 1, 2), col)
  part(c, R(c, x + 2, y, x + w - 3, y + 3), col)
  fl(c, R(c, x + 2, y + 2, x + w - 3, y + 2), tie or "#8a5a35")
  fl(c, R(c, x + 2, y + 5, x + 2, y + h - 4), "#efe2bc")
end

local function planks(c, x0, y0, x1, y1, a, b)
  c:fill(R(c, x0, y0, x1, y1), a or "#c9a266")
  for x = x0, x1, 6 do fl(c, R(c, x, y0, x, y1), b or "#b8965c") end
end

local function snowfall(c, n, y1, sd)
  seed = sd or 11
  for i = 1, n do
    local x, y = 6 + floor(rand() * 62), 6 + floor(rand() * y1)
    c:px(x, y, "#fbfdfe")
    if i % 5 == 0 then c:px(x + 1, y, "#fbfdfe"); c:px(x, y + 1, "#fbfdfe") end
  end
end

local GREY = "#aeb4bc"

-- 1. ice_paddles: frost on the wheel, chiselling off ice
function S.ice_paddles()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#aecbe0", "#bfd6e6", "#d0e2ec", "#e0ecf0" }, { dir = "v" })
  c:fill(c:ellipse(14, 34, 30, 9), "#d3e0ea"); c:fill(c:ellipse(62, 34, 26, 7), "#dbe6ee")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#eef3f6"); c:fill(R(c, 0, 46, W - 1, H - 1), "#e0e9f0")
  -- mill wall, snow-capped
  part(c, R(c, 48, 14, 70, 40), "#b6b0a2")
  for y = 18, 38, 4 do fl(c, R(c, 49, y, 69, y), "#9a9486") end
  fl(c, R(c, 48, 12, 70, 14), "#f4f8fa")
  part(c, R(c, 56, 20, 62, 27), "#6b4a2e"); fl(c, R(c, 57, 21, 61, 26), "#a8d4e8")
  -- frozen pool under the wheel
  c:fill(c:ellipse(36, 44, 16, 4), "#a8d4e8"); c:fill(R(c, 28, 44, 34, 44), "#e0f4fa")
  wheel(c, 38, 28, 14, "#8a5a35", function(k) return (k % 2 == 0) and "#c8e6f2" or "#a8703e" end)
  -- ice crust and icicles
  for k = 0, 12 do
    local a = math.pi * 0.05 + k * math.pi * 0.9 / 12
    local px, py = 38 + rnd(math.cos(a) * 13), 28 + rnd(math.sin(a) * 13)
    for j = 0, 2 + (k % 3) do c:px(px, py + 2 + j, (j == 0) and "#e8f8fc" or "#bfe6f4") end
    c:px(px, py + 1, "#e8f8fc")
  end
  for _, p in ipairs({ { 30, 17 }, { 36, 15 }, { 44, 16 }, { 49, 22 }, { 27, 38 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2] + 1), "#e8f8fc") end
  pine(c, 8, 38, 14, true)
  -- gnome, chisel in one hand, mallet in the other
  local _, G = gnome(c, 16, 47, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -2, 11 }, false), arm({ 4, 7 }, { 9, 12 }, true, false) } })
  local hx, hy = G.P(9, 12)
  fl(c, R(c, hx + 1, hy - 1, hx + 4, hy), GREY); c:px(hx + 5, hy - 1, "#e8f8fc")
  local mx, my = G.P(-2, 11)
  part(c, R(c, mx - 3, my - 5, mx + 1, my - 3), "#8a5a35")
  fl(c, R(c, mx - 1, my - 3, mx, my), "#6b3b2a")
  -- chips, cold breath
  for _, p in ipairs({ { 29, 24 }, { 28, 21 }, { 31, 30 }, { 26, 28 } }) do c:px(p[1], p[2], "#e8f8fc"); c:px(p[1] + 1, p[2] + 1, "#bfe6f4") end
  fl(c, c:ellipse(23, 36, 1, 1), "#f4f8fa"); fl(c, c:ellipse(25, 33, 1, 1), "#f4f8fa")
  snowfall(c, 16, 36, 17)
  finish(c, "ice_paddles")
end

-- 2. millrace_cornbread: gnome offers a fresh slab from the oven; cobs, egg, cornmeal
function S.millrace_cornbread()
  seed = 4
  local c = new()
  day(c, 34, { cloud = 46, hill = "#5e8a44" })
  -- small mill on the hill
  part(c, R(c, 8, 20, 24, 33), "#b8a890")
  part(c, c:poly({ { 6, 21 }, { 16, 11 }, { 26, 21 } }), "#a8582f")
  fl(c, R(c, 13, 26, 18, 33), "#6b4a2e"); fl(c, R(c, 15, 15, 17, 17), "#f4eee0")
  -- baker's oven: stone dome with a glowing mouth
  part(c, c:ellipse(56, 40, 13, 10), STONE, { shade = true })
  part(c, R(c, 43, 38, 69, 49), STONE)
  fl(c, R(c, 44, 41, 68, 41), "#767a82"); fl(c, R(c, 44, 45, 68, 45), "#767a82")
  part(c, c:rrect(51, 36, 61, 49, 4), "#2a1a10")
  c:fill(c:rrect(53, 41, 59, 49, 3), "#e0501f"); c:fill(R(c, 54, 44, 58, 49), "#f08a24"); c:fill(R(c, 55, 46, 57, 49), "#ffd86a")
  part(c, R(c, 55, 24, 58, 32), STONE)
  fl(c, c:ellipse(57, 21, 2, 1), "#d8dee0"); fl(c, c:ellipse(59, 17, 2, 1), "#e6ecee")
  -- low table at left with cobs, egg
  part(c, R(c, 4, 38, 20, 40), "#b07a45")
  part(c, R(c, 5, 41, 6, 49), "#8a5a35", { noline = true }); part(c, R(c, 18, 41, 19, 49), "#8a5a35", { noline = true })
  for i = 0, 1 do
    part(c, c:ellipse(8 + i * 5, 36, 2, 3), "#f5cf6a")
    fl(c, R(c, 7 + i * 5, 33, 7 + i * 5, 38), "#e8a317")
    fl(c, R(c, 6 + i * 5, 36, 6 + i * 5, 39), "#6a9a42"); fl(c, R(c, 10 + i * 5, 36, 10 + i * 5, 39), "#6a9a42")
  end
  part(c, c:ellipse(17, 37, 2, 2), "#f4eee0")
  -- gnome with a peel and a golden slab
  local _, G = gnome(c, 33, 47, { d = 1, eyes = "happy", arms = { arm({ -4, 7 }, { -4, 4 }, false), arm({ 4, 7 }, { 7, 8 }, true, true) } })
  local px, py = G.P(7, 8)
  part(c, R(c, px - 1, py - 1, px + 12, py), "#a8703e")
  part(c, R(c, px + 3, py - 5, px + 12, py - 2), "#e8a317")
  fl(c, R(c, px + 4, py - 5, px + 11, py - 5), "#f5cf6a")
  for _, d2 in ipairs({ { 5, 4 }, { 8, 3 }, { 10, 5 }, { 6, 2 } }) do c:px(px + d2[1], py - d2[2] - 1, "#c4781a") end
  fl(c, R(c, px - 2, py, px, py + 1), "#f0c8a0")
  c:px(px + 8, py - 9, "#f5e6a8"); c:px(px + 5, py - 11, "#f5e6a8")
  finish(c, "millrace_cornbread")
end

-- 3. oat_porridge: dawn, spoon stands up in thick porridge, goat waits
function S.oat_porridge()
  seed = 8
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#7a6a9a", "#b8709a", "#e08a8a", "#f4a878", "#f8d098" }, { dir = "v" })
  c:fill(c:ellipse(31, 35, 6, 6):clip(R(c, 0, 0, W, 33)), "#fff0b8")
  for i = 0, 5 do c:px(30 + i * 5, 20 + (i % 2) * 2, "#f8d098") end
  c:fill(c:ellipse(14, 36, 28, 9), "#5a7a5a"); c:fill(c:ellipse(60, 37, 26, 8), "#4e7a52")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#6a9a5a"); c:fill(R(c, 0, 34, W - 1, 34), "#8cb46a")
  seed = 8
  for i = 1, 12 do local x, y = floor(rand() * 64) + 4, 37 + floor(rand() * 12); c:px(x, y, "#4e8a3c"); c:px(x + 1, y - 1, "#4e8a3c") end
  -- distant mill silhouette on the left
  part(c, R(c, 5, 22, 17, 34), "#5a4a6a", { noline = true }); fl(c, c:poly({ { 4, 23 }, { 11, 15 }, { 18, 23 } }), "#463a58")
  -- goat at right
  part(c, c:ellipse(60, 40, 6, 4), "#f4eee0"); part(c, c:ellipse(66, 35, 3, 3), "#f4eee0")
  fl(c, R(c, 56, 43, 57, 47), "#e8e0cc"); fl(c, R(c, 59, 43, 60, 47), "#e8e0cc"); fl(c, R(c, 63, 43, 64, 47), "#e8e0cc")
  c:px(65, 31, "#8a6a4a"); c:px(66, 30, "#8a6a4a"); c:px(68, 31, "#8a6a4a")
  c:px(66, 35, INK); c:px(67, 38, "#c8b898"); c:px(67, 39, "#c8b898")
  fl(c, R(c, 54, 38, 55, 39), "#f4eee0")
  -- stool-seated gnome stirring a pot over embers
  local _, G = gnome(c, 20, 41, { d = 1, sit = true, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 8 }, { 9, 6 }, true) } })
  part(c, R(c, 11, 41, 18, 43), "#8a5a35"); fl(c, R(c, 12, 44, 12, 48), "#6b3b2a"); fl(c, R(c, 17, 44, 17, 48), "#6b3b2a")
  -- fire and pot
  fl(c, R(c, 36, 46, 48, 47), "#6b3b2a")
  part(c, c:poly({ { 42, 41 }, { 45, 47 }, { 39, 47 } }), "#e0501f"); c:fill(R(c, 41, 44, 43, 47), "#ffd86a")
  part(c, c:rrect(34, 33, 50, 44, 4), "#4a4e58", { shade = true })
  fl(c, R(c, 36, 33, 48, 33), "#e8d49a"); fl(c, R(c, 35, 34, 49, 34), "#d9b870")
  part(c, R(c, 31, 35, 33, 36), "#4a4e58"); part(c, R(c, 51, 35, 53, 36), "#4a4e58")
  -- the spoon stands straight up in it
  part(c, R(c, 41, 21, 42, 33), "#a8703e"); part(c, c:ellipse(41, 19, 2, 2), "#a8703e")
  fl(c, c:ellipse(41, 19, 1, 1), "#c08a52")
  for i = 0, 3 do fl(c, c:ellipse(37 + (i % 2) * 7, 28 - i * 3, 1, 1), "#f8e8d8") end
  -- milk pail
  part(c, R(c, 25, 43, 30, 48), "#aeb4bc"); fl(c, R(c, 26, 43, 29, 43), "#f4f8fa")
  finish(c, "oat_porridge")
end

-- 4. carrot_cake: tall iced cake, a sack-carrier shows off lifting a sack
function S.carrot_cake()
  seed = 12
  local c = new()
  day(c, 34, { cloud = 20, sky = { "#b0d8e6", "#c4e2e6", "#d6ece4" } })
  -- stone mill wall with a red door behind
  part(c, R(c, 46, 14, 69, 34), "#b8a890"); for y = 18, 32, 4 do fl(c, R(c, 47, y, 68, y), "#9a9486") end
  part(c, R(c, 44, 11, 70, 14), "#a8582f")
  fl(c, R(c, 52, 22, 58, 34), "#8e2e1e")
  -- table with cloth
  part(c, R(c, 15, 38, 46, 41), "#f4eee0")
  for x = 16, 45, 4 do fl(c, R(c, x, 41, x + 1, 41), "#dd3a2a") end
  part(c, R(c, 17, 42, 19, 49), "#8a5a35", { noline = true }); part(c, R(c, 42, 42, 44, 49), "#8a5a35", { noline = true })
  -- tall cake, 3 tiers
  local function tier(x0, x1, y0, y1)
    part(c, R(c, x0, y0, x1, y1), "#b8621f")
    fl(c, R(c, x0, y0, x1, y0), "#f4eee0"); fl(c, R(c, x0, y1 - 1, x1, y1 - 1), "#f4eee0")
    for x = x0 + 2, x1 - 1, 4 do c:px(x, y0 + 2, "#e8a05a"); c:px(x + 1, y1 - 3, "#8a4a14") end
  end
  tier(23, 39, 33, 37); tier(25, 37, 28, 32); tier(27, 35, 23, 27)
  for _, p in ipairs({ { 29, 17 }, { 33, 18 } }) do
    part(c, c:poly({ { p[1], p[2] + 5 }, { p[1] + 3, p[2] + 5 }, { p[1] + 1, p[2] + 9 } }), "#e8731f")
    fl(c, R(c, p[1], p[2] + 3, p[1], p[2] + 4), "#4e9a3e"); fl(c, R(c, p[1] + 2, p[2] + 2, p[1] + 3, p[2] + 4), "#4e9a3e")
  end
  -- gnome, knife in hand
  local _, G = gnome(c, 11, 47, { d = 1, eyes = "happy", arms = { arm({ -4, 7 }, { -4, 4 }, false), arm({ 4, 7 }, { 10, 9 }, true) } })
  local kx, ky = G.P(10, 9)
  fl(c, R(c, kx + 1, ky - 1, kx + 6, ky - 1), GREY); fl(c, R(c, kx + 1, ky, kx + 2, ky), "#6b3b2a")
  -- sack-carrier at right: sack hoisted overhead in one hand
  local _, H2 = gnome(c, 58, 47, { d = -1, hat = "#e8a317", eyes = "open", arms = { arm({ 4, 7 }, { 6, 17 }, true, true) } })
  local sx, sy = H2.P(6, 17)
  sack(c, sx - 5, sy - 10, 11, 11, "#d9c8a0")
  fl(c, R(c, sx - 2, sy - 1, sx + 1, sy + 1), "#f0c8a0")
  c:px(sx - 8, sy - 6, "#f5cf6a"); c:px(sx + 7, sy - 8, "#f5cf6a")
  c:px(41, 40, "#b8621f"); c:px(21, 40, "#b8621f")
  finish(c, "carrot_cake")
end

-- 5. millrace_weed: summer, raking green weed out of the channel
function S.millrace_weed()
  seed = 15
  local c = new()
  day(c, 30, { cloud = 36, sky = { "#9ccce0", "#b4dae4", "#cae8e6" }, grass = "#7ea85a" })
  part(c, R(c, 46, 8, 70, 31), "#b8a890"); for y = 12, 30, 4 do fl(c, R(c, 47, y, 69, y), "#9a9486") end
  part(c, R(c, 44, 6, 70, 9), "#a8582f")
  wheel(c, 58, 24, 9, "#8a5a35")
  c:fill(R(c, 0, 30, W - 1, 40), "#7ea85a"); c:fill(R(c, 0, 30, W - 1, 30), "#9cc070")
  c:fill(R(c, 0, 41, W - 1, H - 1), "#3f8fb0")
  c:fill(R(c, 0, 41, W - 1, 42), "#2a6e92")
  seed = 15
  for i = 1, 8 do local x, y = 6 + floor(rand() * 58), 44 + floor(rand() * 5); c:fill(R(c, x, y, x + 4, y), "#7ccfd4") end
  for _, w in ipairs({ { 52, 45 }, { 62, 44 }, { 42, 48 }, { 58, 48 } }) do
    part(c, c:ellipse(w[1], w[2], 5, 2), "#3f8a42")
    fl(c, R(c, w[1] - 3, w[2] - 1, w[1] + 2, w[2] - 1), "#6ab050")
  end
  part(c, c:ellipse(9, 38, 7, 4), "#3f8a42"); fl(c, R(c, 5, 36, 11, 36), "#6ab050")
  -- a frog on a weed mat, not amused
  part(c, c:ellipse(66, 42, 3, 2), "#6ab050"); c:px(65, 40, INK); c:px(67, 40, INK); fl(c, R(c, 65, 41, 67, 41), "#e8a8a0")
  local _, G = gnome(c, 24, 40, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 8, 8 }, true), arm({ -4, 7 }, { 3, 4 }, true) } })
  local hx, hy = G.P(8, 8)
  c:fill(c:line({ { hx, hy }, { 44, 46 } }, 2), "#8a5a35")
  c:fill(R(c, 42, 46, 46, 47), "#6b3b2a")
  part(c, c:ellipse(44, 49, 4, 2), "#3f8a42")
  c:px(34, 45, "#a8e6e6"); c:px(48, 49, "#a8e6e6")
  c:px(60, 11, "#fff0b8"); c:px(10, 24, "#fff0b8")
  finish(c, "millrace_weed")
end

-- 6. tar_paddles: brushing hot tar onto the wheel paddles from a plank walkway
function S.tar_paddles()
  seed = 6
  local c = new()
  day(c, 36, { cloud = 14, sky = { "#b4d4dc", "#c8e0de", "#dcebe0" } })
  part(c, R(c, 38, 6, 70, 40), "#b8a890"); for y = 10, 38, 4 do fl(c, R(c, 39, y, 69, y), "#9a9486") end
  c:fill(R(c, 0, 36, W - 1, H - 1), "#7ea85a")
  c:fill(R(c, 30, 40, 70, 44), "#3f8fb0")
  wheel(c, 54, 26, 17, "#8a5a35", function(k, px, py) return (k >= 4 and k <= 9) and "#1e1a18" or "#6a8a4a" end)
  -- dock of planks
  part(c, R(c, 4, 42, 40, 49), "#b07a45")
  for x = 10, 38, 7 do fl(c, R(c, x, 43, x, 49), "#8a5a35") end
  fl(c, R(c, 5, 42, 39, 42), "#d9a660")
  -- tar pot over a small fire
  part(c, c:poly({ { 11, 40 }, { 14, 46 }, { 8, 46 } }), "#e0501f"); c:fill(R(c, 10, 43, 12, 46), "#ffd86a")
  part(c, c:rrect(6, 33, 16, 40, 2), "#1e1a18"); fl(c, R(c, 7, 33, 15, 33), "#3a3430"); fl(c, R(c, 8, 34, 10, 34), "#6a6460")
  for i = 0, 2 do fl(c, c:ellipse(9 + i * 3, 29 - i * 3, 1, 1), "#8a8480") end
  -- gnome with a brush
  local _, G = gnome(c, 25, 41, { s = 1.2, d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -5, 4 }, false), arm({ 4, 8 }, { 8, 12 }, true) } })
  local bx, by = G.P(8, 12)
  c:fill(c:line({ { bx, by }, { 41, 27 } }, 2), "#8a5a35")
  part(c, R(c, 40, 23, 43, 28), "#1e1a18")
  fl(c, R(c, 41, 24, 41, 25), "#3a3430")
  c:px(43, 30, "#1e1a18"); c:px(37, 28, "#1e1a18")
  c:px(30, 14, "#ffd86a")
  finish(c, "tar_paddles")
end

-- 7. stick_race: two sticks race down the race to a ribbon; two gnomes cheer on the bank
function S.stick_race()
  seed = 17
  local c = new()
  day(c, 28, { cloud = 44 })
  c:fill(R(c, 0, 28, W - 1, 35), "#7ea85a"); c:fill(R(c, 0, 28, W - 1, 28), "#9cc070")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#58b4c4")
  c:fill(R(c, 0, 36, W - 1, 37), "#3f8fb0")
  -- sluice gate, water pouring down at the left
  part(c, R(c, 5, 30, 8, 45), "#8a5a35"); part(c, R(c, 15, 30, 18, 45), "#8a5a35")
  part(c, R(c, 9, 30, 14, 38), "#a8703e")
  c:fill(R(c, 9, 39, 14, 49), "#e8f8fc"); for y = 40, 48, 3 do fl(c, R(c, 10, y, 12, y), "#9fd8e4") end
  seed = 17
  for i = 1, 10 do local x, y = 20 + floor(rand() * 44), 39 + floor(rand() * 10); c:fill(R(c, x, y, x + 4, y), "#a8e6e6") end
  -- finish ribbon
  part(c, R(c, 52, 24, 53, 49), "#8a5a35", { noline = true })
  fl(c, R(c, 54, 38, 54, 38), "#8a5a35")
  c:fill(R(c, 53, 37, 53, 49), "#dd3a2a")
  fl(c, R(c, 52, 22, 54, 23), "#f5cf6a")
  -- sticks (winner ahead, other behind) and a leaf
  part(c, R(c, 33, 42, 43, 44), "#6b3b2a"); fl(c, R(c, 34, 42, 41, 42), "#8a5a35")
  part(c, R(c, 24, 46, 32, 48), "#b07a45"); fl(c, R(c, 25, 46, 30, 46), "#d9a660")
  part(c, c:ellipse(46, 47, 2, 1), "#6ab050")
  -- foam trails
  fl(c, R(c, 28, 44, 32, 44), "#e8f8fc"); fl(c, R(c, 21, 48, 24, 48), "#e8f8fc")
  -- cheering gnomes on the bank
  gnome(c, 26, 35, { d = 1, eyes = "happy", arms = { arm({ -4, 8 }, { -7, 15 }, true), arm({ 4, 8 }, { 7, 15 }, true) } })
  gnome(c, 62, 35, { d = -1, hat = "#4f9a45", eyes = "open", arms = { arm({ 4, 8 }, { 7, 14 }, true) } })
  finish(c, "stick_race")
end

-- 8. flour_puff: puff beats pat; flour everywhere
function S.flour_puff()
  seed = 19
  local c = new()
  planks(c, 5, 5, 68, 49, "#c9a266", "#b8965c")
  fl(c, R(c, 5, 38, 68, 49), "#8a5a35")
  for y = 42, 48, 3 do fl(c, R(c, 5, y, 68, y), "#6b3b2a") end
  part(c, R(c, 5, 24, 26, 25), "#8a5a35"); part(c, R(c, 48, 24, 68, 25), "#8a5a35")
  sack(c, 7, 14, 9, 10, "#d9c8a0"); sack(c, 17, 15, 8, 9, "#c8b080"); sack(c, 50, 14, 9, 10, "#c8b080"); sack(c, 60, 15, 8, 9, "#d9c8a0")
  local function flour(sil, dens)
    sil:each(function(x, y)
      local v = c:get(x, y)
      if v and v ~= INK and v ~= "#8e2e1e" and v ~= "#c0442e" and v ~= "#3f6fb0" and rand() < dens then c:px(x, y, "#f4eee0") end
    end)
  end
  local sa = gnome(c, 20, 47, { s = 1.3, d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -2, 4 }, false), arm({ 4, 8 }, { 8, 12 }, true) } })
  local sb = gnome(c, 54, 47, { s = 1.3, d = -1, hat = "#3f6fb0", eyes = "shut", arms = { arm({ 4, 7 }, { 3, 4 }, false), arm({ -4, 8 }, { -7, 10 }, true) } })
  flour(sa, 0.15); flour(sb, 0.4)
  -- puff cloud rolling across, with chunky white lumps
  local cl = c:mask()
  for _, e in ipairs({ { 33, 33, 3, 2 }, { 37, 31, 4, 3 }, { 42, 32, 4, 3 }, { 40, 36, 5, 2 }, { 35, 36, 3, 2 }, { 46, 35, 3, 2 }, { 31, 36, 2, 1 } }) do cl:add(c:ellipse(e[1], e[2], e[3], e[4])) end
  c:fill(cl, "#f4eee0")
  c:fill(c:ellipse(38, 31, 2, 1), "#fbfdfe"); c:fill(c:ellipse(43, 34, 2, 1), "#fbfdfe")
  c:fill(cl:copy():shrink(1), "#fbfaf4")
  for _, p in ipairs({ { 29, 38 }, { 49, 38 }, { 38, 27 }, { 45, 29 }, { 28, 28 }, { 50, 32 }, { 34, 28 }, { 47, 40 } }) do c:px(p[1], p[2], "#f4eee0") end
  -- flour dust on the floor
  fl(c, R(c, 14, 48, 28, 48), "#f4eee0"); fl(c, R(c, 50, 48, 64, 48), "#f4eee0")
  finish(c, "flour_puff")
end

-- 9. hopper_grains: pouring a scoop into the hopper; sample board on the wall
function S.hopper_grains()
  seed = 23
  local c = new()
  planks(c, 5, 5, 68, 49, "#c9a266", "#b8965c")
  fl(c, R(c, 5, 5, 68, 7), "#8a5a35")
  c:fill(R(c, 5, 44, 68, 49), "#8a5a35"); fl(c, R(c, 5, 44, 68, 44), "#6b3b2a")
  -- sample board with pinned grain heads
  part(c, R(c, 51, 10, 67, 30), "#d9a660")
  fl(c, R(c, 52, 11, 66, 11), "#e8c48a")
  local cols = { "#e8c860", "#c4883a", "#a85a3a", "#e8e0b0", "#7a5a3a", "#d9d070" }
  for i = 0, 5 do
    local x, y = 54 + (i % 3) * 5, 14 + floor(i / 3) * 8
    c:px(x, y, "#aeb4bc")
    fl(c, R(c, x, y + 1, x, y + 5), "#6a8a4a")
    fl(c, R(c, x - 1, y + 1, x + 1, y + 3), cols[i + 1])
  end
  -- hopper on a frame above a millstone
  part(c, R(c, 26, 33, 28, 44), "#8a5a35", { noline = true }); part(c, R(c, 44, 33, 46, 44), "#8a5a35", { noline = true })
  part(c, c:ellipse(36, 41, 13, 4), "#8b8f96", { shade = true })
  c:fill(c:ellipse(36, 40, 10, 2), "#aeb4bc")
  part(c, c:poly({ { 24, 15 }, { 48, 15 }, { 40, 31 }, { 32, 31 } }), "#a8703e")
  fl(c, R(c, 25, 16, 47, 16), "#d9a660")
  c:fill(R(c, 27, 17, 45, 18), "#e8c860")
  -- trickle into the stone
  fl(c, R(c, 36, 31, 36, 38), "#e8c860"); c:px(35, 34, "#e8c860"); c:px(37, 36, "#e8c860")
  fl(c, R(c, 31, 39, 41, 39), "#e8c860")
  -- gnome on a crate, tipping a scoop of grain
  part(c, R(c, 7, 37, 21, 48), "#b07a45"); fl(c, R(c, 8, 37, 20, 37), "#d9a660"); fl(c, R(c, 8, 42, 20, 42), "#8a5a35")
  local _, G = gnome(c, 14, 37, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 14 }, true, true), arm({ -4, 7 }, { 3, 12 }, true, true) } })
  local sx, sy = G.P(9, 14)
  part(c, R(c, sx - 1, sy - 3, sx + 4, sy + 1), "#aeb4bc")
  fl(c, R(c, sx, sy - 3, sx + 3, sy - 3), "#e8c860")
  fl(c, R(c, sx - 2, sy - 1, sx, sy + 1), "#f0c8a0")
  for _, p in ipairs({ { sx + 6, sy - 2 }, { sx + 8, sy - 5 }, { sx + 7, sy + 1 }, { 38, 14 } }) do c:px(p[1], p[2], "#e8c860") end
  finish(c, "hopper_grains")
end

-- 10. sack_stamps: inking a mark on a sack, a stack of marked sacks behind
function S.sack_stamps()
  seed = 29
  local c = new()
  planks(c, 5, 5, 68, 40, "#b8a890", "#9a9486")
  for y = 9, 38, 5 do fl(c, R(c, 5, y, 68, y), "#9a9486") end
  fl(c, R(c, 5, 5, 68, 8), "#a8582f")
  c:fill(R(c, 5, 41, 68, 49), "#a8823e"); for x = 5, 68, 9 do fl(c, R(c, x, 41, x, 49), "#8a5a35") end
  fl(c, R(c, 5, 41, 68, 41), "#6b3b2a")
  -- stack of stamped sacks at the right
  local marks = {
    { "..g..", ".ggg.", "ggggg", ".ggg.", ".g.g." }, { "g...g", "ggggg", "g.g.g", "ggggg", ".g.g." },
    { ".ggg.", "g...g", "g.g.g", "g...g", ".ggg." }, { "g.g.g", ".ggg.", "ggggg", ".ggg.", "g.g.g" },
    { "..g..", ".ggg.", "..g..", ".ggg.", "g.g.g" } }
  local mcol = { "#dd3a2a", "#3f6fb0", "#3f8a42", "#8a4a9a", "#b8661a" }
  local pos = { { 40, 33, 1 }, { 52, 33, 2 }, { 63, 33, 3 }, { 46, 24, 4 }, { 58, 24, 5 }, { 52, 15, 1 } }
  for _, p in ipairs(pos) do
    local x, y = p[1], p[2]
    sack(c, x - 5, y - 3, 12, 14, "#d9c8a0")
  end
  for _, p in ipairs(pos) do c:paint(marks[p[3]], p[1] - 2, p[2] + 3, { g = mcol[p[3]] }) end
  -- low stamping table with the fresh sack and an ink pad
  part(c, R(c, 8, 38, 36, 41), "#b07a45")
  part(c, R(c, 10, 42, 12, 49), "#8a5a35", { noline = true }); part(c, R(c, 32, 42, 34, 49), "#8a5a35", { noline = true })
  sack(c, 20, 31, 14, 8, "#d9c8a0")
  c:paint({ "..g..", ".ggg.", "ggggg", ".ggg.", ".g.g." }, 26, 33, { g = "#dd3a2a" })
  local _, G = gnome(c, 13, 38, { d = 1, upper = true, s = 1.2, eyes = "open", arms = { arm({ -4, 7 }, { -5, 3 }, true), arm({ 4, 8 }, { 9, 6 }, true, true) } })
  local sx, sy = G.P(9, 6)
  part(c, R(c, sx - 1, sy - 4, sx + 2, sy - 1), "#8a5a35"); part(c, R(c, sx - 3, sy - 1, sx + 4, sy + 1), "#6b3b2a")
  fl(c, R(c, sx - 2, sy + 1, sx + 3, sy + 1), "#dd3a2a")
  part(c, R(c, 8, 39, 14, 40), "#4a2c5a"); fl(c, R(c, 9, 39, 13, 39), "#8a4a9a")
  finish(c, "sack_stamps")
end

-- 11. bean_loaf: midwinter, a dried bean in the broken loaf
function S.bean_loaf()
  seed = 31
  local c = new()
  planks(c, 5, 5, 68, 49, "#c9a266", "#b8965c")
  fl(c, R(c, 5, 5, 68, 7), "#8a5a35")
  -- window onto the snow
  part(c, R(c, 8, 10, 24, 28), "#8a5a35")
  c:fill(R(c, 10, 12, 22, 26), "#aecbe0"); c:fill(R(c, 10, 12, 22, 17), "#bfd6e6")
  fl(c, R(c, 16, 12, 16, 26), "#8a5a35"); fl(c, R(c, 10, 19, 22, 19), "#8a5a35")
  fl(c, R(c, 10, 24, 22, 26), "#f4f8fa"); fl(c, R(c, 7, 28, 25, 29), "#f4f8fa")
  for _, p2 in ipairs({ { 12, 14 }, { 19, 16 }, { 13, 21 }, { 20, 22 }, { 15, 15 } }) do c:px(p2[1], p2[2], "#fbfdfe") end
  -- holly wreath
  part(c, c:ellipse(34, 15, 5, 5), "#3f8a42"); c:fill(c:ellipse(34, 15, 2, 2), "#c9a266")
  for _, p2 in ipairs({ { 31, 12 }, { 37, 13 }, { 34, 10 }, { 30, 17 }, { 38, 18 }, { 34, 20 } }) do c:px(p2[1], p2[2], "#dd3a2a") end
  -- table with four whole loaves
  part(c, R(c, 5, 38, 68, 42), "#8a5a35"); fl(c, R(c, 6, 38, 67, 38), "#a8703e")
  c:fill(R(c, 5, 43, 68, 49), "#6b3b2a")
  for _, x in ipairs({ 10, 20, 30, 64 }) do
    part(c, c:ellipse(x, 36, 4, 3), "#b8661a"); c:fill(c:ellipse(x, 35, 2, 1), "#d9983a")
    c:px(x - 1, 34, "#8a4a14"); c:px(x + 1, 34, "#8a4a14")
  end
  -- gnome behind the table holding the loaf that cracked
  local _, G = gnome(c, 43, 39, { d = 1, s = 1.25, upper = true, eyes = "happy", arms = { arm({ -3, 7 }, { -7, 5 }, true, true), arm({ 3, 8 }, { 9, 12 }, true, true) } })
  local hx, hy = G.P(9, 12)
  part(c, c:ellipse(hx, hy - 3, 6, 4), "#b8661a")
  c:fill(c:ellipse(hx, hy - 5, 5, 2), "#f0dcaa")
  fl(c, R(c, hx - 4, hy - 4, hx + 4, hy - 4), "#d8bd84")
  part(c, c:ellipse(hx + 1, hy - 5, 2, 1), "#4a2c1a"); c:px(hx, hy - 6, "#9a7a4a")
  part(c, c:ellipse(hx - 9, hy - 1, 2, 2), "#b8661a"); c:px(hx - 9, hy - 2, "#f0dcaa")
  fl(c, R(c, hx - 3, hy, hx + 3, hy + 1), "#f0c8a0")
  for _, p2 in ipairs({ { hx + 1, hy - 11 }, { hx - 6, hy - 9 }, { hx + 8, hy - 9 } }) do
    c:px(p2[1], p2[2], "#fff0b8"); c:px(p2[1] - 1, p2[2], "#fff0b8"); c:px(p2[1] + 1, p2[2], "#fff0b8"); c:px(p2[1], p2[2] - 1, "#fff0b8"); c:px(p2[1], p2[2] + 1, "#fff0b8")
  end
  finish(c, "bean_loaf")
end

-- 12. finest_flour: three bins, a pinch rubbed between the fingers
function S.finest_flour()
  seed = 37
  local c = new()
  planks(c, 5, 5, 68, 49, "#c9a266", "#b8965c")
  fl(c, R(c, 5, 5, 68, 7), "#8a5a35")
  -- hanging sieve and a flour scoop on the wall
  part(c, c:ellipse(12, 16, 6, 6), "#8a5a35"); c:fill(c:ellipse(12, 16, 4, 4), "#e8e0c8")
  for x = 9, 15, 2 do for y = 13, 19, 2 do c:px(x, y, "#a89a78") end end
  part(c, R(c, 58, 10, 66, 11), "#8a5a35"); part(c, c:ellipse(66, 15, 3, 3), "#aeb4bc"); fl(c, R(c, 66, 11, 66, 12), "#8a5a35")
  local _, G = gnome(c, 36, 41, { s = 1.4, d = 1, upper = true, eyes = "shut", arms = { arm({ -4, 7 }, { -6, 15 }, true, true), arm({ 4, 7 }, { 6, 2 }, true) } })
  -- pinching hand at the beard
  local hx, hy = G.P(-6, 15)
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0"); c:px(hx + 2, hy - 1, "#fbfaf4"); c:px(hx + 2, hy, "#fbfaf4"); c:px(hx - 2, hy - 2, "#fbfaf4")
  -- three bins
  local function bin(x0, x1, col, tone, specks)
    part(c, R(c, x0, 39, x1, 49), "#b07a45")
    fl(c, R(c, x0 + 1, 39, x1 - 1, 39), "#d9a660")
    fl(c, R(c, x0 + 1, 43, x1 - 1, 43), "#8a5a35")
    part(c, c:ellipse(floor((x0 + x1) / 2), 37, floor((x1 - x0) / 2) - 1, 3), col)
    c:fill(c:ellipse(floor((x0 + x1) / 2), 36, floor((x1 - x0) / 2) - 4, 1), tone)
    if specks then for i = 1, 7 do c:px(x0 + 2 + (i * 5) % (x1 - x0 - 3), 35 + (i * 3) % 4, specks) end end
  end
  bin(6, 22, "#c0a070", "#d8c090", "#7a5a30")
  bin(28, 44, "#e8dcba", "#f2e8cc", nil)
  bin(50, 66, "#faf6ec", "#fbfdfe", nil)
  for _, p2 in ipairs({ { 55, 31 }, { 60, 30 }, { 62, 33 } }) do c:px(p2[1], p2[2], "#fbfdfe") end
  finish(c, "finest_flour")
end

-- 13. sluice_gate: leaning on the lever, the gate lifts and water roars through
function S.sluice_gate()
  seed = 41
  local c = new()
  day(c, 30, { cloud = 14, sky = { "#a8d4e0", "#bcdde4", "#cfe8e6" } })
  c:fill(R(c, 0, 30, W - 1, H - 1), "#7ea85a"); c:fill(R(c, 0, 30, W - 1, 30), "#9cc070")
  -- stone dam with a gate arch
  part(c, R(c, 33, 14, 70, 37), STONE)
  for y = 18, 36, 4 do fl(c, R(c, 34, y, 69, y), "#767a82") end
  part(c, R(c, 38, 22, 56, 37), "#2a4a5a")
  -- raised gate panel with a pulley beam
  part(c, R(c, 37, 8, 39, 37), "#8a5a35", { noline = true }); part(c, R(c, 55, 8, 57, 37), "#8a5a35", { noline = true })
  part(c, R(c, 36, 6, 58, 8), "#6b3b2a")
  part(c, R(c, 40, 13, 54, 21), "#a8703e"); for x = 43, 53, 4 do fl(c, R(c, x, 14, x, 20), "#8a5a35") end
  fl(c, R(c, 47, 9, 47, 12), "#d9d4c0")
  -- water through the gap and the pool below
  c:fill(R(c, 39, 22, 55, 36), "#58b4c4")
  for y = 24, 34, 3 do fl(c, R(c, 41, y, 53, y), "#a8e6e6") end
  c:fill(R(c, 30, 38, 70, 49), "#3f8fb0")
  c:fill(c:ellipse(47, 38, 11, 3), "#e8f8fc"); c:fill(c:ellipse(47, 38, 7, 2), "#fbfdfe")
  seed = 41
  for i = 1, 8 do local x, y = 32 + floor(rand() * 34), 41 + floor(rand() * 7); c:fill(R(c, x, y, x + 4, y), "#7ccfd4") end
  for _, p2 in ipairs({ { 40, 34 }, { 54, 33 }, { 36, 40 }, { 58, 41 } }) do c:px(p2[1], p2[2], "#fbfdfe") end
  -- lever and rope to the gate
  local _, G = gnome(c, 14, 41, { d = 1, s = 1.1, eyes = "open", arms = { arm({ 4, 7 }, { 11, 9 }, true), arm({ -4, 7 }, { 8, 5 }, true) } })
  c:fill(c:line({ { 29, 42 }, { 23, 18 } }, 2), "#8a5a35")
  fl(c, R(c, 28, 40, 30, 42), "#6b3b2a")
  c:fill(c:line({ { 23, 17 }, { 36, 7 }, { 47, 7 }, { 47, 13 } }, 1), "#d9d4c0")
  -- little miller dodging on the dam top
  gnome(c, 65, 16, { d = -1, s = 0.7, hat = "#8a8a9a", eyes = "open", arms = { arm({ 4, 7 }, { 6, 13 }, true), arm({ -4, 7 }, { -6, 12 }, true) } })
  finish(c, "sluice_gate")
end

-- 14. miller_ledger: the fat ledger, a floury cat on the open page
function S.miller_ledger()
  seed = 43
  local c = new()
  planks(c, 5, 5, 68, 49, "#b08a58", "#98764a")
  fl(c, R(c, 5, 5, 68, 7), "#6b3b2a")
  part(c, R(c, 8, 10, 22, 24), "#8a5a35"); c:fill(R(c, 10, 12, 20, 22), "#bcdde4"); c:fill(R(c, 10, 12, 20, 16), "#cfe8e6")
  fl(c, R(c, 15, 12, 15, 22), "#8a5a35"); fl(c, R(c, 10, 17, 20, 17), "#8a5a35")
  -- hanging lamp
  fl(c, R(c, 56, 8, 56, 14), "#3d2a1c"); part(c, R(c, 53, 15, 59, 21), "#ffd86a"); fl(c, R(c, 55, 17, 57, 19), "#fff1c8"); part(c, R(c, 52, 14, 60, 15), "#3d2a1c", { noline = true })
  -- table
  part(c, R(c, 5, 38, 68, 42), "#8a5a35"); fl(c, R(c, 6, 38, 67, 38), "#a8703e")
  c:fill(R(c, 5, 43, 68, 49), "#6b3b2a")
  -- gnome behind, finger on a line
  local _, G = gnome(c, 20, 40, { d = 1, upper = true, s = 1.25, eyes = "open", arms = { arm({ -4, 7 }, { -6, 4 }, true, true), arm({ 4, 7 }, { 11, 4 }, true) } })
  -- the fat book: page block, two pages, writing lines
  part(c, R(c, 26, 30, 62, 38), "#6b3b2a")
  part(c, R(c, 28, 28, 44, 36), "#f0e6c8"); part(c, R(c, 45, 28, 61, 36), "#f0e6c8")
  for y = 30, 35, 2 do fl(c, R(c, 30, y, 42, y), "#b8a888") end
  for y = 30, 35, 2 do fl(c, R(c, 47, y, 52, y), "#b8a888") end
  fl(c, R(c, 44, 28, 44, 36), "#c8b890")
  fl(c, R(c, 27, 37, 62, 37), "#e8dcb8")
  -- cat on the right page
  part(c, c:ellipse(55, 31, 5, 3), "#f4eee0"); part(c, c:ellipse(51, 28, 3, 3), "#f4eee0")
  c:px(49, 24, "#f4eee0"); c:px(53, 24, "#f4eee0"); c:px(49, 25, "#e8a8a0"); c:px(53, 25, "#e8a8a0")
  c:px(50, 28, INK); c:px(52, 28, INK)
  fl(c, R(c, 58, 28, 61, 29), "#f4eee0"); c:px(61, 27, "#f4eee0"); c:px(61, 26, "#f4eee0")
  c:px(56, 33, "#c8bca4"); c:px(54, 33, "#c8bca4")
  -- ink pot and quill
  part(c, R(c, 63, 33, 67, 37), "#2a2438"); c:fill(c:line({ { 65, 32 }, { 67, 24 } }, 1), "#f4eee0"); c:px(67, 23, "#e8dcb8")
  finish(c, "miller_ledger")
end

-- 15. sackcarrier_sayings: dusk, resting on sacks, a torn sack letting out feathers
function S.sackcarrier_sayings()
  seed = 47
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#4a4a86", "#7a5a9a", "#b8648a", "#e08a78", "#f4a878", "#f8c890" }, { dir = "v" })
  c:fill(c:ellipse(60, 11, 3, 3), "#f5e6a8")
  for _, st in ipairs({ { 10, 9 }, { 30, 7 }, { 44, 12 }, { 20, 15 } }) do c:px(st[1], st[2], "#f4eee0") end
  c:fill(c:ellipse(14, 36, 28, 9), "#4a4a6a"); c:fill(c:ellipse(60, 37, 26, 8), "#3f4a62")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#4a6a58"); c:fill(R(c, 0, 34, W - 1, 34), "#6a8a68")
  -- mill silhouette
  part(c, R(c, 44, 20, 62, 34), "#3a3450", { noline = true }); c:fill(c:poly({ { 42, 21 }, { 53, 11 }, { 64, 21 } }), "#2e2840")
  c:fill(R(c, 51, 25, 54, 29), "#f5cf6a")
  -- sacks
  sack(c, 5, 37, 15, 13, "#d9c8a0"); sack(c, 54, 38, 14, 12, "#c8b080")
  part(c, c:rrect(28, 38, 42, 49, 3), "#d9c8a0")
  fl(c, R(c, 29, 44, 41, 44), "#c8b080")
  local tear = c:mask(); for i, x in ipairs({ 28, 30, 32, 34, 36, 38, 40 }) do tear:add(c:rect(x, 34 + (i % 2) * 2, x + 1, 38)) end
  part(c, tear, "#d9c8a0")
  fl(c, R(c, 29, 37, 41, 38), "#f4eee0")
  for x = 30, 40, 3 do fl(c, R(c, x, 36, x + 1, 37), "#f4eee0") end
  -- feathers drifting up
  local fth = { { 34, 33 }, { 38, 30 }, { 36, 26 }, { 40, 22 }, { 35, 19 }, { 42, 17 }, { 39, 13 }, { 33, 29 } }
  for _, f in ipairs(fth) do
    c:fill(R(c, f[1], f[2], f[1] + 2, f[2]), "#f4eee0"); c:px(f[1] + 3, f[2] - 1, "#f4eee0"); c:px(f[1] - 1, f[2] + 1, "#c8c4d0")
  end
  -- two sack-carriers
  gnome(c, 12, 37, { d = 1, sit = true, eyes = "open", arms = { arm({ 4, 8 }, { 10, 12 }, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  gnome(c, 61, 38, { d = -1, sit = true, hat = "#e8a317", eyes = "shut", arms = { arm({ -4, 8 }, { -6, 16 }, true, true), arm({ 4, 8 }, { 7, 14 }, true, true) } })
  finish(c, "sackcarrier_sayings")
end

local order = { "ice_paddles", "millrace_cornbread", "oat_porridge", "carrot_cake", "millrace_weed",
  "tar_paddles", "stick_race", "flour_puff", "hopper_grains", "sack_stamps", "bean_loaf", "finest_flour", "sluice_gate", "miller_ledger", "sackcarrier_sayings" }
for _, s2 in ipairs(order) do
  if S[s2] and (not only or only == "w2_" .. s2 or only == s2) then seed = 7; S[s2]() end
end
