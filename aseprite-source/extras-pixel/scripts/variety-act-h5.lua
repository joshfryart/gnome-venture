-- variety-act-h5.lua : first-pass regional rest-stop scenes (group h5) -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-h5.lua   (params BEFORE --script)
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
  slug = "r_sa_" .. slug
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

---------------------------------------------------------------- extra helpers (h5)
local S = {}
local function note(c, x, y, col) -- tiny music note
  col = col or "#fff6d0"
  c:px(x + 1, y, col); c:px(x + 1, y + 1, col); c:px(x + 1, y + 2, col); c:px(x, y + 3, col); c:px(x + 2, y, col)
end
local function leafblob(c, x, y, rx, ry, col, hi)
  part(c, c:ellipse(x, y, rx, ry), col, { shade = true })
end
local function tree(c, x, yb, h, r, trunk, crown)
  part(c, R(c, x - 1, yb - h, x + 1, yb), trunk or "#6b4a2e", { noline = true })
  part(c, c:ellipse(x, yb - h, r, math.max(3, r - 2)), crown or "#3f8a42", { shade = true })
end
local function sunburst(c, x, y, col)
  c:fill(c:ellipse(x, y, 3, 3), col or "#ffe58a")
  for _, d in ipairs({ { -5, 0 }, { 5, 0 }, { 0, -5 }, { 0, 5 }, { -4, -4 }, { 4, -4 }, { -4, 4 }, { 4, 4 } }) do c:px(x + d[1], y + d[2], col or "#ffe58a") end
end
local function post(c, x0, y0, x1, y1, col) part(c, R(c, x0, y0, x1, y1), col or "#8a5a35", { noline = true }) end
local function cloud(c, x, y, col)
  col = col or "#f4eee0"
  c:fill(c:ellipse(x, y, 7, 2), col); c:fill(c:ellipse(x + 3, y - 2, 4, 2), col)
end
local function planks(c, x0, y0, x1, y1, top, base)
  part(c, R(c, x0, y0, x1, y1), base or "#b07a45")
  fl(c, R(c, x0, y0, x1, y0), top or "#d9a660")
  for x = x0 + 5, x1 - 1, 6 do c:px(x, y0 + 1, "#7a4a2a"); c:px(x, y0 + 2, "#7a4a2a") end
end

-- 1. dolphin whistle: gnome whistling on a jetty, a pink dolphin leaps from tea-brown water
function S.dolphin_whistle()
  seed = 31
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#b4d8d4", "#c6e2d6", "#d8ecd6" }, { dir = "v" })
  cloud(c, 50, 11)
  c:fill(c:ellipse(12, 29, 20, 8), "#3f7a3a"); c:fill(c:ellipse(54, 30, 26, 8), "#4a8640"); c:fill(c:ellipse(34, 30, 12, 5), "#357034")
  tree(c, 9, 30, 11, 6, "#6b4a2e", "#2f6a34"); tree(c, 62, 30, 9, 6, "#6b4a2e", "#2f6a34")
  c:bands(R(c, 0, 30, W - 1, H - 1), { "#8a5e3a", "#80563a", "#76503a", "#6c4a36" }, { dir = "v" })
  for _, p in ipairs({ { 14, 33 }, { 40, 34 }, { 24, 45 }, { 52, 46 }, { 44, 40 }, { 12, 42 } }) do fl(c, R(c, p[1], p[2], p[1] + 4, p[2]), "#a07848") end
  -- jetty
  post(c, 8, 38, 10, 49); post(c, 26, 38, 28, 49)
  planks(c, 4, 36, 34, 39)
  gnome(c, 18, 35, { d = 1, eyes = "open", arms = { arm({ 4, 6 }, { 6, 5 }, true) } })
  note(c, 27, 20); note(c, 32, 16, "#ffe58a")
  -- dolphin leaping from the right
  local P, PD, PB = "#e89aa8", "#c8727f", "#f8d0d4"
  part(c, c:ellipse(51, 31, 9, 3), P, { shade = true })
  part(c, R(c, 38, 31, 43, 32), PD)
  c:fill(R(c, 45, 33, 56, 33), PB)
  part(c, c:poly({ { 49, 28 }, { 54, 28 }, { 52, 23 } }), PD)
  part(c, c:line({ { 58, 32 }, { 62, 37 } }, 2), P)
  part(c, c:poly({ { 59, 37 }, { 66, 35 }, { 64, 41 }, { 61, 40 } }), PD)
  c:px(44, 29, "#2a1a10")
  -- splash
  for _, p in ipairs({ { 60, 43 }, { 64, 42 }, { 57, 44 }, { 66, 44 } }) do c:px(p[1], p[2], "#f4eee0"); c:px(p[1], p[2] + 1, "#f4eee0") end
  fl(c, R(c, 56, 46, 66, 46), "#c8a070")
  -- second dolphin fin far left
  part(c, c:poly({ { 38, 44 }, { 42, 44 }, { 38, 39 } }), PD); fl(c, R(c, 34, 45, 46, 45), "#a07848")
  finish(c, "dolphin_whistle")
end

-- 2. condor thermals: gnome on a crag shading eyes, condors circling in a spiral
function S.condor_thermals()
  seed = 32
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 44), { "#78b6dc", "#8cc4e2", "#a2d2e6", "#bae0ea", "#d0ecee" }, { dir = "v" })
  sunburst(c, 64, 10, "#fff0a0")
  cloud(c, 14, 13, "#fbf6ea")
  c:fill(c:poly({ { 0, 40 }, { 12, 28 }, { 20, 34 }, { 32, 22 }, { 46, 36 }, { 58, 30 }, { 72, 40 }, { 72, 50 }, { 0, 50 } }), "#8f96ae")
  c:fill(c:poly({ { 32, 22 }, { 36, 28 }, { 30, 30 } }), "#f4f8fa")
  -- warm air shimmer
  for i = 0, 5 do local x = 38 + (i % 2) * 2; fl(c, R(c, x, 43 - i * 5, x + 1, 44 - i * 5), "#f6e8b8") end
  -- crag ledge
  part(c, c:poly({ { 3, 46 }, { 5, 36 }, { 24, 34 }, { 34, 40 }, { 38, 50 }, { 3, 50 } }), "#a0856a", { shade = true })
  fl(c, R(c, 5, 36, 24, 36), "#c4aa88"); c:px(12, 42, "#7a604a"); c:px(20, 44, "#7a604a"); c:px(28, 44, "#7a604a")
  gnome(c, 16, 36, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 6, 11 }, true), arm({ -4, 7 }, { -6, 4 }, false) } })
  -- condor: wide dark wings, white collar
  local function condor(x, y, s, tilt)
    local w = 6 * s
    part(c, c:poly({ { x - w, y + tilt }, { x - 2, y - 2 }, { x + 2, y - 2 }, { x + w, y - tilt }, { x + 2, y + 2 }, { x - 2, y + 2 } }), "#2e2a3a")
    for i = 1, s do fl(c, R(c, x - w + 3 * i, y + 1, x - w + 3 * i, y + 2), "#f4f0ee"); fl(c, R(c, x + w - 3 * i - 1, y, x + w - 3 * i - 1, y + 1), "#f4f0ee") end
    fl(c, R(c, x - 1, y - 3, x + 1, y - 2), "#f4f0ee"); c:px(x, y - 4, "#c8463a")
  end
  condor(44, 10, 2, 1); condor(54, 22, 2, -1); condor(30, 19, 1, 1); condor(24, 8, 1, -1)
  finish(c, "condor_thermals")
end

-- 3. sky-city stairs: a diagonal stone stair climbing out of clouds
function S.ruin_steps()
  seed = 33
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 49), { "#6a96c8", "#7ca6d0", "#92b8d8", "#aecde0", "#cde0ea" }, { dir = "v" })
  cloud(c, 18, 13, "#f4f8fa"); cloud(c, 58, 20, "#f4f8fa")
  c:fill(c:poly({ { 44, 30 }, { 54, 18 }, { 64, 26 }, { 72, 22 }, { 72, 40 }, { 44, 40 } }), "#8a96b4")
  -- ruin gate at the summit
  part(c, R(c, 57, 8, 59, 17), "#b8b0a0"); part(c, R(c, 65, 8, 67, 17), "#b8b0a0"); part(c, R(c, 56, 6, 68, 8), "#c8c0b0")
  fl(c, R(c, 60, 11, 64, 17), "#4a5a78")
  -- stair: steps going up right
  for i = 0, 8 do
    local x0, y0 = 6 + i * 5, 46 - i * 4
    part(c, R(c, x0, y0, x0 + 9, y0 + 3), "#b8b0a0")
    fl(c, R(c, x0, y0, x0 + 9, y0), "#d4ccb8"); fl(c, R(c, x0 + 4, y0 + 3, x0 + 9, y0 + 3), "#8a8478")
  end
  -- clouds rolling across the stairs
  for _, p in ipairs({ { 20, 44 }, { 12, 48 }, { 34, 38 }, { 48, 33 }, { 28, 47 }, { 60, 49 } }) do
    c:fill(c:ellipse(p[1], p[2], 8, 3), "#f4f8fa"); c:fill(R(c, p[1] - 6, p[2] + 2, p[1] + 6, p[2] + 3), "#dbe8f0")
  end
  gnome(c, 38, 29, { d = 1, walk = 1, eyes = "open", arms = { arm({ -4, 7 }, { -7, 6 }, false), arm({ 4, 7 }, { 7, 8 }, true) } })
  -- counting marks
  for i = 0, 4 do c:px(10 + i * 2, 11, "#fff6d0"); c:px(10 + i * 2, 12, "#fff6d0") end
  finish(c, "ruin_steps")
end

-- 4. mate round: dawn, circle of gnomes passing a gourd by a small fire
function S.mate_round()
  seed = 34
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#6a6aa0", "#9a7aa6", "#d08aa0", "#f0a888", "#f8c880", "#fbe2a0" }, { dir = "v" })
  c:fill(c:ellipse(36, 34, 8, 6), "#ffe58a")
  c:fill(c:ellipse(12, 35, 26, 8), "#5a5e8a"); c:fill(c:ellipse(60, 35, 28, 9), "#4e5a82")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#6a8a52"); c:fill(R(c, 0, 34, W - 1, 34), "#8aa860")
  c:fill(c:ellipse(36, 45, 24, 5), "#7a9a58")
  -- little fire with kettle
  part(c, c:line({ { 41, 46 }, { 51, 44 } }, 2), "#6b3b2a")
  part(c, c:poly({ { 46, 37 }, { 49, 42 }, { 50, 44 }, { 42, 44 }, { 43, 42 } }), "#e0501f")
  c:fill(c:ellipse(46, 42, 2, 2), "#ffd86a")
  -- kettle on a tripod
  part(c, c:line({ { 40, 30 }, { 46, 38 } }, 1), "#5a3a22"); part(c, c:line({ { 52, 30 }, { 46, 38 } }, 1), "#5a3a22")
  part(c, c:ellipse(46, 33, 4, 3), "#9aa0a8", { shade = true }); fl(c, R(c, 50, 32, 52, 32), "#9aa0a8")
  c:px(51, 29, "#f4f8fa"); c:px(52, 27, "#f4f8fa")
  -- the circle
  gnome(c, 10, 46, { d = 1, upper = true, hat = "#e8a317", eyes = "open", arms = { arm({ 5, 7 }, { 11, 10 }, true) } })
  gnome(c, 30, 48, { d = 1, upper = true, eyes = "happy", arms = { arm({ 5, 7 }, { 4, 10 }, true) } })
  gnome(c, 62, 46, { d = -1, upper = true, hat = "#4f9a45", eyes = "open", arms = { arm({ 5, 7 }, { 7, 9 }, true) } })
  -- the gourd, midway on its trip
  local gx, gy = 19, 31
  part(c, c:ellipse(gx, gy, 3, 3), "#8a5a35", { shade = true }); fl(c, R(c, gx - 1, gy - 5, gx - 1, gy - 3), "#d8dce0"); fl(c, R(c, gx - 1, gy - 6, gx, gy - 6), "#d8dce0")
  fl(c, R(c, gx - 1, gy - 1, gx, gy), "#a8723e")
  
  finish(c, "mate_round")
end

-- 5. anaconda length: two gnomes stretch a knotted rope along a snoozing anaconda on a boardwalk
function S.anaconda_length()
  seed = 35
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#b8d8a8", "#c6e0a8", "#d6e8b0" }, { dir = "v" })
  tree(c, 10, 31, 17, 8, "#5a4028", "#2f6a34"); tree(c, 36, 31, 13, 7, "#5a4028", "#3a7a38"); tree(c, 62, 31, 18, 8, "#5a4028", "#2f6a34")
  for _, x in ipairs({ 8, 14, 33, 40, 60, 66 }) do fl(c, R(c, x, 20, x, 27 + (x % 3) * 2), "#4a8a3a") end
  c:bands(R(c, 0, 31, W - 1, H - 1), { "#5a7a4a", "#4e6e44", "#44603e" }, { dir = "v" })
  for _, p in ipairs({ { 8, 46 }, { 30, 48 }, { 52, 47 }, { 20, 33 }, { 50, 34 } }) do fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#7a9a5a") end
  post(c, 8, 42, 10, 49); post(c, 34, 42, 36, 49); post(c, 60, 42, 62, 49)
  planks(c, 4, 40, 69, 43, "#c89a58", "#a8723e")
  -- the anaconda, in lazy waves
  local pts = { { 20, 38 }, { 26, 35 }, { 32, 38 }, { 38, 35 }, { 44, 38 }, { 48, 36 } }
  part(c, c:line(pts, 5), "#5e9a3e", { shade = true })
  for i, p in ipairs(pts) do fl(c, R(c, p[1] - 1, p[2] - 1, p[1], p[2]), "#2f5a22") end
  for _, x in ipairs({ 24, 30, 36, 42, 46 }) do c:fill(c:ellipse(x, 35 + (x % 2) * 3, 1, 1), "#e0c860") end
  for x = 22, 46, 3 do c:px(x, 37 - ((x // 3) % 2) * 3 + 2, "#8ab860") end
  part(c, c:ellipse(52, 37, 4, 3), "#6aa846"); fl(c, R(c, 50, 36, 53, 36), "#2a1a10")
  fl(c, R(c, 55, 38, 57, 38), "#d8403a"); c:px(57, 37, "#d8403a"); c:px(57, 39, "#d8403a")
  c:paint({ "ggg", "..g", ".g.", "ggg" }, 46, 25, { g = "#fff6d0" }); c:paint({ "gg", ".g", "gg" }, 51, 21, { g = "#fff6d0" })
  -- tail tip
  part(c, c:line({ { 20, 39 }, { 17, 39 } }, 2), "#4e8a34")
  local _, G1 = gnome(c, 11, 39, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 8, 12 }, true) } })
  local _, G2 = gnome(c, 61, 39, { d = -1, eyes = "open", hat = "#e8a317", arms = { arm({ 4, 7 }, { 8, 12 }, true) } })
  local x0, y0 = G1.P(9, 12); local x1, y1 = G2.P(9, 12)
  local n = x1 - x0
  for x = x0, x1 do
    local t = (x - x0) / n
    local y = floor(y0 + (y1 - y0) * t + math.sin(t * math.pi) * 4 + 0.5)
    c:px(x, y, "#e8d8a8"); c:px(x, y + 1, "#8a6a3a")
    if (x - x0) % 8 == 4 then c:px(x, y - 1, "#d8403a"); c:px(x, y + 2, "#d8403a") end
  end
  finish(c, "anaconda_length")
end

-- 6. quinoa bread: the baker pounds peanuts in a stone bowl behind a table of flatbread and quinoa sacks
function S.quinoa_bread()
  seed = 36
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#b8884e", "#b0804a", "#a87a46" }, { dir = "v" })
  for x = 8, 68, 10 do fl(c, R(c, x, 5, x, 38), "#8a5a35") end
  -- window
  part(c, R(c, 8, 9, 22, 21), "#a8d4e0"); fl(c, R(c, 15, 9, 15, 21), "#8a5a35"); fl(c, R(c, 8, 15, 22, 15), "#8a5a35")
  c:fill(c:ellipse(12, 12, 2, 1), "#f4eee0")
  -- shelf with jars and hanging corn
  part(c, R(c, 46, 14, 68, 15), "#6b4a2e")
  part(c, R(c, 49, 8, 53, 13), "#c4623a"); part(c, R(c, 57, 9, 61, 13), "#e8c070"); part(c, R(c, 63, 10, 66, 13), "#4f9a45")
  for _, x in ipairs({ 30, 36 }) do part(c, c:ellipse(x, 14, 1, 3), "#e8a317"); fl(c, R(c, x, 8, x, 10), "#6b4a2e") end
  gnome(c, 29, 45, { d = 1, upper = true, s = 1.15, eyes = "open", arms = { arm({ 4, 7 }, { 11, 4 }, true), arm({ -4, 7 }, { 6, 5 }, true) } })
  -- table
  part(c, R(c, 5, 41, 68, 44), "#c08a52"); fl(c, R(c, 5, 41, 68, 41), "#dca868")
  part(c, R(c, 6, 45, 68, 49), "#8a5a35")
  fl(c, R(c, 17, 45, 17, 49), "#5e2f1e"); fl(c, R(c, 50, 45, 50, 49), "#5e2f1e")
  -- stone mortar + peanuts
  part(c, c:ellipse(43, 38, 6, 4), "#8b8f96", { shade = true }); c:fill(c:ellipse(43, 37, 4, 2), "#c89458")
  part(c, c:line({ { 49, 24 }, { 44, 36 } }, 2), "#a8703e")
  for _, p in ipairs({ { 53, 40 }, { 56, 40 }, { 54, 38 }, { 51, 40 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#d8b078", { noline = true }); c:px(p[1], p[2], "#a8783e") end
  -- flatbread with paste
  part(c, c:ellipse(62, 40, 6, 2), "#e8c88a"); c:fill(c:ellipse(62, 39, 4, 1), "#c08a52")
  -- quinoa sack
  part(c, c:poly({ { 8, 29 }, { 16, 29 }, { 18, 41 }, { 6, 41 } }), "#d8c8a0")
  fl(c, R(c, 6, 30, 18, 31), "#e8d8b0"); fl(c, R(c, 9, 27, 15, 29), "#d8c8a0")
  for x = 9, 15, 2 do c:px(x, 28, "#e8e0c8") end
  for _, p in ipairs({ { 20, 41 }, { 22, 40 }, { 19, 40 } }) do c:px(p[1], p[2], "#f4eee0") end
  finish(c, "quinoa_bread")
end

-- 7. acai bowl: big close gnome mashing a purple bowl, passion fruit halves and berries
function S.acai_bowl()
  seed = 37
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#f8e8a0", "#f4eeb0", "#e6eec0" }, { dir = "v" })
  sunburst(c, 60, 11, "#fff0a0")
  c:fill(c:ellipse(14, 35, 28, 9), "#4e8a3c"); c:fill(c:ellipse(58, 36, 30, 8), "#5a9a44")
  -- acai palms
  for _, x in ipairs({ 12, 56 }) do
    part(c, R(c, x, 14, x + 1, 36), "#7a6a4a", { noline = true })
    for _, d in ipairs({ { -8, 3 }, { 8, 3 }, { -5, -1 }, { 5, -1 }, { 0, -2 } }) do part(c, c:line({ { x, 13 }, { x + d[1], 13 + d[2] } }, 2), "#3f8a42", { noline = true }) end
    for _, p in ipairs({ { 0, 16 }, { 2, 17 }, { -1, 18 }, { 1, 19 } }) do c:fill(c:ellipse(x + p[1], p[2], 1, 1), "#4a2060") end
  end
  c:fill(R(c, 0, 36, W - 1, H - 1), "#7ea85a"); c:fill(R(c, 0, 36, W - 1, 36), "#9cc070")
  -- crate table
  part(c, R(c, 6, 42, 68, 49), "#b07a45"); fl(c, R(c, 6, 42, 68, 42), "#d9a660"); fl(c, R(c, 6, 46, 68, 46), "#7a4a2a")
  gnome(c, 20, 50, { d = 1, upper = true, s = 1.35, eyes = "happy", arms = { arm({ 4, 8 }, { 12, 11 }, true) } })
  -- the bowl
  part(c, c:ellipse(47, 40, 11, 6):clip(R(c, 30, 38, 66, 48)), "#c08a52", { shade = true })
  part(c, c:ellipse(47, 38, 11, 3), "#a8703e")
  part(c, c:ellipse(47, 37, 9, 2), "#5a2a6a"); c:fill(c:ellipse(47, 35, 6, 2), "#6e3a80"); c:fill(R(c, 43, 34, 46, 34), "#9a6aaa"); c:fill(R(c, 50, 36, 54, 36), "#9a6aaa")
  -- passion fruit halves
  for _, p in ipairs({ { 62, 41 }, { 63, 44 } }) do
    part(c, c:ellipse(p[1], p[2], 3, 2), "#e8a317"); c:fill(c:ellipse(p[1], p[2], 2, 1), "#f8d860"); c:px(p[1], p[2], "#6a3a1a")
  end
  -- mashing spoon
  part(c, c:line({ { 35, 28 }, { 45, 35 } }, 1), "#c08a52")
  part(c, c:ellipse(46, 36, 2, 1), "#d9a660")
  -- loose berries
  for _, p in ipairs({ { 12, 45 }, { 16, 47 }, { 31, 44 }, { 66, 41 }, { 59, 46 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#4a2060", { noline = true }) end
  finish(c, "acai_bowl")
end

-- 8. red clay pot: coil on coil, the potter builds a belly with a kiln behind
function S.red_clay_pot()
  seed = 38
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#e8c8a0", "#f0d4a8", "#f4e0b8" }, { dir = "v" })
  c:fill(c:ellipse(20, 36, 30, 8), "#c8946a"); c:fill(c:ellipse(60, 37, 26, 7), "#b88458")
  c:fill(R(c, 0, 35, W - 1, H - 1), "#b85a38"); c:fill(R(c, 0, 35, W - 1, 35), "#d07848")
  for _, p in ipairs({ { 8, 44 }, { 26, 47 }, { 55, 48 }, { 62, 42 }, { 16, 40 } }) do c:px(p[1], p[2], "#8a3a22"); c:px(p[1] + 1, p[2], "#8a3a22") end
  -- kiln
  part(c, c:ellipse(12, 35, 9, 9):clip(R(c, 0, 20, 30, 35)), "#9a7a68", { shade = true })
  fl(c, R(c, 9, 31, 14, 35), "#2a1a10"); fl(c, R(c, 10, 33, 13, 35), "#e8701f")
  part(c, R(c, 11, 17, 13, 21), "#8a6a58", { noline = true })
  c:px(12, 14, "#d8d0c8"); c:px(13, 12, "#d8d0c8")
  -- stump + pot
  part(c, R(c, 40, 42, 58, 49), "#8a5a35"); fl(c, R(c, 40, 42, 58, 42), "#a8703e")
  part(c, c:ellipse(49, 33, 9, 9), "#c4502e", { shade = true })
  part(c, R(c, 45, 22, 53, 25), "#c4502e")
  for _, y in ipairs({ 24, 27, 30, 33, 36, 39 }) do local hw = (y < 28) and 4 or ((y < 38) and 8 or 6); fl(c, R(c, 49 - hw, y, 49 + hw, y), "#8a3a22") end
  part(c, c:ellipse(49, 21, 4, 1), "#d86a3a")
  -- potter with a fresh coil
  gnome(c, 28, 49, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 12, 14 }, true), arm({ -4, 7 }, { -8, 3 }, false) } })
  part(c, c:line({ { 38, 22 }, { 45, 20 } }, 2), "#d86a3a")
  -- spare coils
  part(c, c:ellipse(10, 46, 5, 2), "#c4502e"); c:fill(c:ellipse(10, 46, 2, 1), "#8a3a22")
  part(c, c:ellipse(18, 47, 3, 1), "#d86a3a")
  finish(c, "red_clay_pot")
end

-- 9. humus sift: sifting dark soil through a palm sieve, a lens bubble shows the busy village in a handful
function S.humus_sift()
  seed = 39
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#3a6a3a", "#42763e", "#4a8442", "#56904a" }, { dir = "v" })
  for _, x in ipairs({ 8, 22, 60 }) do part(c, R(c, x, 5, x + 3, 36), "#5a4028", { noline = true }) end
  for _, x in ipairs({ 14, 40, 66 }) do part(c, c:ellipse(x, 20, 5, 7), "#2f6a34", { noline = true }) end
  for i = 0, 3 do fl(c, R(c, 28 + i * 3, 5 + i * 4, 30 + i * 3, 8 + i * 4), "#7aaa58") end
  c:bands(R(c, 0, 33, W - 1, H - 1), { "#5a3e28", "#4e3422", "#44301e" }, { dir = "v" })
  for _, p in ipairs({ { 8, 40 }, { 20, 47 }, { 46, 48 }, { 60, 45 }, { 36, 37 } }) do c:px(p[1], p[2], "#7a5a3a"); c:px(p[1] + 1, p[2] + 1, "#2e2014") end
  -- gnome kneeling with sieve out front
  gnome(c, 14, 44, { d = 1, sit = true, eyes = "open", arms = { arm({ 4, 7 }, { 12, 10 }, true) } })
  part(c, c:ellipse(30, 38, 7, 2), "#c8b068"); c:fill(c:ellipse(30, 38, 5, 1), "#8a7a40")
  for x = 25, 35, 2 do c:px(x, 38, "#c8b068") end
  for _, p in ipairs({ { 27, 40 }, { 30, 41 }, { 33, 40 }, { 29, 43 }, { 32, 44 }, { 28, 46 } }) do c:px(p[1], p[2], "#2e2014") end
  part(c, c:ellipse(30, 48, 8, 2), "#3a2818")
  -- inset lens bubble
  part(c, c:ellipse(53, 20, 12, 12), "#7a5a38", { shade = false })
  c:fill(c:ellipse(53, 20, 10, 10), "#4e3422")
  c:fill(c:ellipse(53, 26, 9, 3), "#3a2818")
  part(c, c:line({ { 45, 28 }, { 47, 25 }, { 45, 23 }, { 47, 21 } }, 1), "#e89aa8", { noline = true })
  part(c, c:ellipse(56, 25, 3, 2), "#2f8a8a"); fl(c, R(c, 55, 23, 56, 23), "#c8e0e0"); c:px(53, 27, "#2a1a10"); c:px(59, 27, "#2a1a10")
  part(c, R(c, 49, 17, 50, 21), "#e8dcc8", { noline = true }); part(c, c:ellipse(49, 16, 3, 2), "#d8402e"); c:px(48, 16, "#f4eee0"); c:px(50, 15, "#f4eee0")
  part(c, R(c, 57, 14, 57, 17), "#e8dcc8", { noline = true }); part(c, c:ellipse(57, 13, 2, 1), "#e8a317")
  c:px(52, 21, "#f4eee0"); c:px(60, 19, "#f4eee0"); c:px(54, 17, "#f4eee0")
  finish(c, "humus_sift")
end

-- 10. spring oven: digging a steaming pit by the hot pools, leaf-wrapped roots going in
function S.spring_oven()
  seed = 40
  local c = new()
  day(c, 28, { cloud = 52, hill = "#6a8a54", hill2 = "#5a7e4a", grass = "#8aa864" })
  -- hot pool behind
  part(c, c:ellipse(24, 33, 17, 4), "#9a9ea6", { shade = true }); c:fill(c:ellipse(24, 33, 14, 3), "#6cc8cc"); c:fill(R(c, 16, 33, 22, 33), "#b8ece8")
  for _, p in ipairs({ { 18, 27 }, { 24, 24 }, { 29, 21 }, { 26, 29 }, { 20, 22 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#f4f8fa") end
  for _, p in ipairs({ { 52, 35 }, { 62, 36 } }) do part(c, c:ellipse(p[1], p[2], 3, 2), "#9a9ea6", { shade = true }) end
  c:fill(R(c, 36, 34, 68, H - 1), "#a08058"); c:fill(c:ellipse(52, 43, 17, 6), "#a88860")
  -- the pit
  part(c, c:ellipse(52, 43, 9, 3), "#4a3020"); c:fill(c:ellipse(52, 43, 7, 2), "#6a4a30")
  local function parcel(x, y, col) part(c, c:ellipse(x, y, 3, 2), col, { shade = true }); fl(c, R(c, x - 3, y, x + 3, y), "#e8c060"); c:px(x, y - 2, "#8a5a35") end
  parcel(49, 42, "#4f9a45"); parcel(55, 43, "#5ab04a"); parcel(52, 40, "#3f8a42")
  for _, p in ipairs({ { 48, 36 }, { 52, 32 }, { 56, 37 }, { 53, 28 }, { 49, 31 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#f4f8fa"); c:px(p[1] + 1, p[2] + 1, "#d8e4ea") end
  gnome(c, 22, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 9, 4 }, true) } })
  part(c, c:line({ { 31, 41 }, { 40, 44 } }, 2), "#a8703e")
  part(c, c:poly({ { 40, 42 }, { 45, 46 }, { 41, 48 } }), "#9aa0a8")
  -- spilled soil
  for _, p in ipairs({ { 37, 47 }, { 40, 49 }, { 62, 47 }, { 65, 44 } }) do c:px(p[1], p[2], "#6a4a30"); c:px(p[1] + 1, p[2], "#6a4a30") end
  finish(c, "spring_oven")
end

-- 11. terrace wall: a slumped stretch of stone wall, a gnome hefting the stone back up
function S.terrace_wall()
  seed = 41
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 22), { "#98c0e0", "#aed0e6", "#c8e2ec" }, { dir = "v" })
  c:fill(c:poly({ { 0, 22 }, { 16, 8 }, { 30, 18 }, { 44, 6 }, { 60, 18 }, { 72, 12 }, { 72, 24 }, { 0, 24 } }), "#8a96b4")
  c:fill(c:poly({ { 44, 6 }, { 47, 10 }, { 41, 10 } }), "#f4f8fa"); c:fill(c:poly({ { 16, 8 }, { 19, 12 }, { 13, 12 } }), "#f4f8fa")
  local function band(y0, y1, gcol)
    c:fill(R(c, 0, y0, W - 1, y0 + 2), gcol)
    for x = 2, W - 3, 4 do c:px(x, y0 + 1, "#e8dca0"); c:px(x, y0, "#e8dca0") end
  end
  local function wall(y0, y1, gap)
    part(c, R(c, 0, y0, W - 1, y1), "#a8a090")
    local row = 0
    for y = y0 + 3, y1, 3 do fl(c, R(c, 0, y, W - 1, y), "#7a7468"); row = row + 1 end
    for y = y0, y1 - 1, 3 do for x = (y // 3 % 2) * 4 + 1, W - 1, 8 do fl(c, R(c, x, y + 1, x, y + 2), "#7a7468") end end
    if gap then c:fill(R(c, gap[1], y0, gap[2], y1), "#5a3e28") end
  end
  c:fill(R(c, 0, 24, W - 1, H - 1), "#7aa050")
  band(25, 27, "#9ab868"); wall(28, 33)
  band(34, 36, "#8ab05c"); wall(37, 42, { 38, 48 })
  band(43, 45, "#7aa050"); wall(46, 49)
  -- fallen stones below the gap
  for _, p in ipairs({ { 36, 43 }, { 41, 44 }, { 47, 43 }, { 52, 44 }, { 44, 41 } }) do part(c, R(c, p[1] - 2, p[2] - 1, p[1] + 2, p[2] + 1), "#b0a898") end
  c:fill(R(c, 38, 37, 38, 42), "#6a5a48")
  gnome(c, 15, 49, { d = 1, walk = 1, eyes = "open", arms = { arm({ 4, 7 }, { 9, 6 }, true, true) } })
  part(c, R(c, 24, 37, 33, 46), "#b8b0a0"); fl(c, R(c, 24, 37, 33, 37), "#d4ccb8"); fl(c, R(c, 29, 43, 33, 46), "#8a8478")
  fl(c, R(c, 22, 41, 24, 44), "#f0c8a0")
  finish(c, "terrace_wall")
end

-- 12. latex cups: milky sap into a clay cup on a rubber tree, a monkey eyeing the next cup
function S.latex_cups()
  seed = 42
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 49), { "#2f6a34", "#3a7a38", "#468a40", "#56964a" }, { dir = "v" })
  for _, x in ipairs({ 8, 66 }) do part(c, R(c, x, 5, x + 2, 49), "#4a3a28", { noline = true }) end
  for _, p in ipairs({ { 14, 12 }, { 30, 8 }, { 58, 10 }, { 20, 22 } }) do c:fill(c:ellipse(p[1], p[2], 6, 3), "#4e9a48") end
  c:fill(R(c, 0, 44, W - 1, H - 1), "#4a6a3a"); c:fill(R(c, 0, 44, W - 1, 44), "#6a8a50")
  -- rubber tree
  part(c, R(c, 42, 8, 50, 47), "#9a9084"); fl(c, R(c, 43, 8, 44, 47), "#b8aea0"); fl(c, R(c, 49, 8, 49, 47), "#7a7064")
  c:fill(c:line({ { 43, 20 }, { 49, 32 } }, 1), "#f4eee0")
  for _, p in ipairs({ { 44, 23 }, { 46, 27 }, { 48, 31 } }) do c:px(p[1], p[2], "#6a5e50") end
  part(c, c:poly({ { 40, 31 }, { 47, 31 }, { 46, 37 }, { 41, 37 } }), "#c4623a"); fl(c, R(c, 41, 31, 46, 31), "#f4eee0")
  -- branch + monkey
  part(c, c:line({ { 50, 14 }, { 62, 12 } }, 2), "#6a5a44", { noline = true })
  part(c, c:ellipse(60, 16, 3, 3), "#8a5a35"); part(c, c:ellipse(60, 9, 3, 3), "#8a5a35"); fl(c, R(c, 59, 9, 61, 10), "#e8c8a0"); c:px(59, 8, "#2a1a10"); c:px(61, 8, "#2a1a10")
  part(c, c:line({ { 57, 17 }, { 52, 28 } }, 1), "#8a5a35", { noline = true }); fl(c, R(c, 51, 28, 52, 29), "#e8c8a0")
  part(c, c:line({ { 63, 18 }, { 66, 26 }, { 64, 30 } }, 1), "#8a5a35", { noline = true })
  -- gnome tipping a full cup into a pail
  gnome(c, 22, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 9, 9 }, true, true), arm({ -4, 7 }, { -7, 4 }, false) } })
  part(c, c:poly({ { 28, 33 }, { 33, 33 }, { 32, 38 }, { 29, 38 } }), "#c4623a"); fl(c, R(c, 29, 33, 32, 33), "#f4eee0")
  fl(c, R(c, 33, 36, 33, 39), "#f4eee0")
  part(c, R(c, 31, 43, 39, 49), "#9a9ea6"); fl(c, R(c, 31, 43, 39, 44), "#f4eee0"); fl(c, R(c, 33, 40, 33, 43), "#f4eee0")
  finish(c, "latex_cups")
end

-- 13. frost potatoes: a winter dawn on the highland, a gnome stomping frozen potatoes flat
function S.frost_potatoes()
  seed = 43
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#b8c8e6", "#c8d4ea", "#dcdcec", "#f0dcd8", "#f8e4d0" }, { dir = "v" })
  c:fill(c:ellipse(52, 30, 5, 5), "#fff0c8")
  c:fill(c:poly({ { 0, 32 }, { 14, 14 }, { 26, 26 }, { 40, 10 }, { 56, 28 }, { 66, 20 }, { 72, 26 }, { 72, 34 }, { 0, 34 } }), "#9aa6c8")
  c:fill(c:poly({ { 40, 10 }, { 45, 17 }, { 36, 17 } }), "#f4f8fa"); c:fill(c:poly({ { 14, 14 }, { 18, 20 }, { 10, 20 } }), "#f4f8fa")
  c:fill(R(c, 0, 33, W - 1, H - 1), "#dce6ee"); c:fill(R(c, 0, 33, W - 1, 33), "#f4f8fa")
  c:fill(R(c, 0, 42, W - 1, H - 1), "#cfdbe6")
  for _, p in ipairs({ { 8, 36 }, { 30, 38 }, { 60, 37 }, { 12, 47 }, { 56, 48 }, { 44, 35 } }) do c:px(p[1], p[2], "#aabbd0"); c:px(p[1] + 1, p[2], "#aabbd0") end
  local function spud(x, y, flat)
    if flat then part(c, c:ellipse(x, y, 4, 1), "#a8845a", { noline = true }); fl(c, R(c, x - 3, y - 1, x + 2, y - 1), "#e8f0f4")
    else part(c, c:ellipse(x, y, 3, 2), "#b8905a"); c:px(x - 1, y - 1, "#f4f8fa"); c:px(x, y - 2, "#f4f8fa"); c:px(x + 1, y - 1, "#d8e8f0") end
  end
  spud(46, 40, false); spud(55, 39, false); spud(63, 41, false); spud(50, 46, false); spud(61, 47, false); spud(14, 41, false)
  spud(26, 47, true); spud(35, 47, true); spud(30, 44, true); spud(22, 42, true)
  gnome(c, 31, 45, { d = -1, walk = -1, eyes = "open", hat = "#4a7ab8", arms = { arm({ -4, 7 }, { -7, 11 }, false), arm({ 4, 7 }, { 7, 4 }, true) } })
  -- breath puff + sparkle
  c:fill(c:ellipse(21, 29, 2, 1), "#f4f8fa"); c:px(18, 31, "#f4f8fa")
  for _, p in ipairs({ { 12, 24 }, { 66, 38 }, { 40, 50 }, { 6, 44 } }) do c:px(p[1], p[2], "#fbfdfe"); c:px(p[1] - 1, p[2], "#cfe0f0"); c:px(p[1] + 1, p[2], "#cfe0f0"); c:px(p[1], p[2] - 1, "#cfe0f0"); c:px(p[1], p[2] + 1, "#cfe0f0") end
  finish(c, "frost_potatoes")
end

-- 14. salt channel: pickaxe cracking the white crust that clogs a warm spring channel
function S.salt_channel()
  seed = 44
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 24), { "#9ac8e6", "#b0d6ec", "#c8e4f0", "#e0f0f4" }, { dir = "v" })
  c:fill(c:poly({ { 0, 25 }, { 10, 18 }, { 22, 24 }, { 34, 16 }, { 48, 25 }, { 60, 19 }, { 72, 25 }, { 72, 27 }, { 0, 27 } }), "#a8b4d0")
  c:fill(R(c, 0, 26, W - 1, H - 1), "#eef4f6"); c:fill(R(c, 0, 26, W - 1, 27), "#dce8ee")
  for _, p in ipairs({ { 10, 31 }, { 34, 29 }, { 56, 32 }, { 22, 47 }, { 60, 48 } }) do fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#d4e2ea") end
  -- channel
  c:fill(R(c, 0, 38, W - 1, 44), "#c8d8e0"); c:fill(R(c, 0, 39, 24, 43), "#5ec4c8"); c:fill(R(c, 0, 39, 24, 39), "#9ae4e4"); c:fill(R(c, 8, 41, 13, 41), "#8adcdc")
  c:fill(R(c, 25, 40, 28, 43), "#5ec4c8")
  -- crust clog
  for _, p in ipairs({ { 30, 40 }, { 36, 39 }, { 42, 40 }, { 48, 41 }, { 33, 43 }, { 40, 43 }, { 46, 44 } }) do part(c, R(c, p[1] - 3, p[2] - 2, p[1] + 3, p[2] + 2), "#f8fbfc", { shade = false }) end
  c:fill(R(c, 62, 40, 68, 43), "#e0eaee")
  gnome(c, 24, 36, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 15 }, true) } })
  -- pick overhead
  part(c, c:line({ { 31, 22 }, { 36, 35 } }, 2), "#8a5a35", { noline = true })
  part(c, c:line({ { 29, 21 }, { 38, 24 } }, 2), "#7a8088")
  -- chips
  for _, p in ipairs({ { 39, 33 }, { 42, 35 }, { 36, 31 }, { 44, 38 }, { 33, 34 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#fbfdfe"); c:px(p[1] + 2, p[2] + 1, "#c8d8e0") end
  -- steam from the warm water
  c:fill(c:ellipse(6, 35, 2, 1), "#fbfdfe"); c:fill(c:ellipse(14, 34, 2, 1), "#fbfdfe")
  finish(c, "salt_channel")
end

-- 15. ombu hands: two gnomes on a bench under the lone ombu, wind flattening the thistles
function S.ombu_hands()
  seed = 45
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#9ccce6", "#b0d8ea", "#c8e6ee" }, { dir = "v" })
  cloud(c, 12, 12); cloud(c, 58, 18)
  c:fill(R(c, 0, 33, W - 1, H - 1), "#b4a85a"); c:fill(R(c, 0, 33, W - 1, 33), "#cabc6c")
  c:fill(R(c, 0, 42, W - 1, H - 1), "#a09448")
  -- wind lines
  for _, p in ipairs({ { 6, 8 }, { 40, 6 }, { 56, 26 }, { 8, 28 } }) do fl(c, R(c, p[1], p[2], p[1] + 8, p[2]), "#f4f8fa"); fl(c, R(c, p[1] + 8, p[2] - 1, p[1] + 10, p[2] - 1), "#f4f8fa") end
  -- the ombu: fat trunk, wide crown leaning with the wind
  part(c, c:poly({ { 31, 24 }, { 42, 24 }, { 45, 40 }, { 28, 40 } }), "#7a6048", { shade = true })
  part(c, c:ellipse(37, 18, 24, 9), "#4a8a42", { shade = true })
  c:fill(c:ellipse(30, 16, 10, 4), "#5a9a4c"); c:fill(c:ellipse(46, 19, 8, 3), "#3a7a38")
  -- bench
  part(c, R(c, 9, 40, 65, 42), "#a8703e"); fl(c, R(c, 9, 40, 65, 40), "#c08a52")
  post(c, 12, 43, 14, 49); post(c, 60, 43, 62, 49)
  gnome(c, 20, 40, { d = 1, sit = true, eyes = "open", arms = { arm({ 4, 7 }, { 11, 11 }, true) } })
  gnome(c, 54, 40, { d = -1, sit = true, eyes = "open", hat = "#e8a317", arms = { arm({ 4, 7 }, { 11, 11 }, true) } })
  -- thistles pushed flat
  for _, x in ipairs({ 10, 24, 40, 56, 64 }) do
    fl(c, R(c, x, 46, x + 4, 46), "#5e8a44"); fl(c, R(c, x + 4, 45, x + 5, 45), "#5e8a44")
    c:px(x + 6, 45, "#a860b8"); c:px(x + 6, 46, "#a860b8"); c:px(x + 7, 45, "#c880d0")
  end
  finish(c, "ombu_hands")
end

-- 16. ant leaf raindrop: under a drip-leaf umbrella, a gnome plays the hand game while an ant hauls its leaf
function S.ant_leaf_rain()
  seed = 46
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 49), { "#5a7a72", "#4e6e66", "#46665e", "#3e5a54" }, { dir = "v" })
  for _, x in ipairs({ 6, 30, 62 }) do part(c, R(c, x, 5, x + 2, 49), "#3a4a3a", { noline = true }) end
  c:fill(R(c, 0, 44, W - 1, H - 1), "#3e5a3a"); c:fill(R(c, 0, 44, W - 1, 44), "#56764a")
  for _, p in ipairs({ { 8, 8 }, { 14, 20 }, { 22, 12 }, { 48, 14 }, { 58, 8 }, { 64, 30 }, { 10, 34 }, { 52, 40 }, { 40, 6 }, { 26, 40 } }) do c:px(p[1], p[2], "#a8d0e0"); c:px(p[1] - 1, p[2] - 2, "#a8d0e0"); c:px(p[1] - 1, p[2] - 1, "#a8d0e0") end
  -- leaf umbrella
  part(c, R(c, 36, 20, 37, 45), "#4a6a38", { noline = true })
  part(c, c:ellipse(37, 18, 24, 6), "#4f9a45", { shade = true }); fl(c, R(c, 15, 18, 59, 18), "#3a7a38")
  fl(c, R(c, 24, 15, 24, 18), "#7ac070"); fl(c, R(c, 37, 14, 37, 18), "#7ac070"); fl(c, R(c, 50, 15, 50, 18), "#7ac070")
  c:px(14, 21, "#a8d0e0"); c:px(14, 23, "#a8d0e0"); c:px(14, 26, "#a8d0e0")
  gnome(c, 40, 46, { d = -1, sit = true, eyes = "open", arms = { arm({ 4, 7 }, { 11, 12 }, true) } })
  -- the ant carrying a leaf piece, and the drop about to land
  part(c, c:ellipse(15, 46, 5, 2), "#7ac070"); fl(c, R(c, 11, 46, 19, 46), "#4f9a45")
  fl(c, R(c, 13, 47, 19, 48), "#2a1a10"); c:fill(c:ellipse(11, 49, 1, 1), "#2a1a10"); c:px(8, 48, "#2a1a10")
  for _, x in ipairs({ 13, 15, 17 }) do c:px(x, 49, "#2a1a10") end
  c:fill(c:ellipse(15, 33, 1, 2), "#cfe8f4"); c:px(15, 32, "#fbfdfe")
  finish(c, "ant_leaf_rain")
end

-- 17. panpipe echo-off: piping from a ledge, the far mountain answers
function S.panpipe_echo()
  seed = 47
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 40), { "#80b4dc", "#98c4e2", "#b0d4e8", "#cce4ee" }, { dir = "v" })
  cloud(c, 18, 11); cloud(c, 54, 8)
  c:fill(c:poly({ { 26, 40 }, { 40, 24 }, { 50, 30 }, { 62, 8 }, { 72, 22 }, { 72, 40 } }), "#a8a8d0")
  c:fill(c:poly({ { 62, 8 }, { 66, 14 }, { 58, 14 } }), "#f4f8fa")
  c:fill(c:poly({ { 20, 44 }, { 34, 32 }, { 46, 38 }, { 60, 28 }, { 72, 36 }, { 72, 49 }, { 20, 49 } }), "#8a88b8")
  -- ledge
  part(c, c:poly({ { 5, 49 }, { 5, 36 }, { 26, 35 }, { 30, 49 } }), "#9a8a78", { shade = true })
  fl(c, R(c, 5, 36, 26, 36), "#bcae98")
  gnome(c, 16, 36, { d = 1, eyes = "shut", arms = { arm({ 4, 7 }, { 7, 11 }, true) } })
  -- panpipes at the mouth
  local px0, py0 = 22, 24
  for i = 0, 4 do part(c, R(c, px0 + i * 2, py0 + i, px0 + i * 2 + 1, py0 + 6), "#d9b060", { noline = true }); c:px(px0 + i * 2, py0 + 6, "#8a5a2a") end
  fl(c, R(c, px0, py0 + 4, px0 + 9, py0 + 4), "#a8483a")
  note(c, 29, 16); note(c, 34, 12, "#ffe58a")
  -- sound arcs out, echo arcs back
  for i = 0, 2 do for k = -3 - i * 2, 3 + i * 2 do c:px(32 + i * 4 - (k * k) // (6 + i * 4), 25 + k, "#fbfdfe") end end
  for i = 0, 2 do for k = -3 - i * 2, 3 + i * 2 do c:px(58 - i * 4 + (k * k) // (6 + i * 4), 30 + k, "#f0d8ff") end end
  finish(c, "panpipe_echo")
end

-- 18. mirror poses: rain-wet salt flat as a perfect mirror, a stretch and a crouch with their reflections
function S.mirror_poses()
  seed = 48
  local c = new()
  local function skyband(y0, y1, flip)
    local cols = { "#78b4e0", "#90c4e6", "#a8d4ec", "#c0e2f0", "#d8eef4" }
    for y = y0, y1 do
      local t = (y - y0) / (y1 - y0 + 1); if flip then t = 1 - t end
      c:fill(R(c, 0, y, W - 1, y), cols[floor(t * 5) + 1])
    end
  end
  skyband(0, 28, false); skyband(29, 49, true)
  local function cl(x, y, dy) c:fill(c:ellipse(x, y, 8, 2), "#f4f8fa"); c:fill(c:ellipse(x + 3, y + dy, 5, 2), "#f4f8fa") end
  cl(16, 12, -2); cl(52, 17, -2); cl(16, 45, 2); cl(52, 40, 2)
  fl(c, R(c, 0, 28, W - 1, 29), "#e8f2f6")
  local function mirrored(draw, fy, y0)
    local snap = {}
    for y = y0, fy do for x = 0, W - 1 do snap[y * 100 + x] = c:get(x, y) end end
    draw()
    local moves = {}
    for y = y0, fy do for x = 0, W - 1 do
      local v = c:get(x, y)
      if v ~= snap[y * 100 + x] then moves[#moves + 1] = { x, 2 * fy + 2 - y + 0, v } end
    end end
    for _, m in ipairs(moves) do c:px(m[1] + ((m[2] // 2) % 2 == 0 and 0 or 1), m[2], m[3]) end
  end
  mirrored(function()
    gnome(c, 22, 29, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -8, 19 }, false), arm({ 4, 8 }, { 8, 19 }, true) } })
  end, 29, 6)
  mirrored(function()
    gnome(c, 52, 31, { d = -1, sit = true, hat = "#e8a317", eyes = "happy", arms = { arm({ 4, 7 }, { 8, 4 }, true) } })
  end, 31, 8)
  -- water lines over the reflections
  for _, p in ipairs({ { 8, 40 }, { 30, 44 }, { 44, 46 }, { 12, 47 }, { 60, 42 } }) do fl(c, R(c, p[1], p[2], p[1] + 6, p[2]), "#e8f4f8") end
  finish(c, "mirror_poses")
end

-- 19. potato kinds: baskets of every sort of potato, a gnome with a notebook and a purple one in hand
function S.potato_kinds()
  seed = 49
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 49), { "#d8c4a0", "#d0bc98", "#c8b490" }, { dir = "v" })
  -- striped awning
  for x = 5, 68, 8 do fl(c, R(c, x, 5, x + 3, 11), "#dd3a2a"); fl(c, R(c, x + 4, 5, x + 7, 11), "#f4eee0") end
  for x = 5, 68, 8 do fl(c, R(c, x, 12, x + 3, 12), "#dd3a2a"); fl(c, R(c, x + 4, 12, x + 7, 12), "#f4eee0"); c:px(x + 1, 13, "#dd3a2a"); c:px(x + 5, 13, "#f4eee0") end
  c:fill(R(c, 0, 14, 4, 14), "#a8905a")
  -- crate display
  part(c, R(c, 28, 38, 68, 49), "#a8703e"); fl(c, R(c, 28, 38, 68, 38), "#c08a52"); fl(c, R(c, 28, 44, 68, 44), "#7a4a2a")
  local function basket(x, col, spot)
    part(c, c:ellipse(x, 39, 5, 3), "#8a5a35")
    for dx = -3, 3, 2 do for dy = -2, 0, 2 do c:fill(c:ellipse(x + dx, 34 + dy + 1, 1, 1), col) end end
    c:fill(c:ellipse(x, 35, 4, 1), col)
    for i = -3, 3, 2 do c:fill(c:ellipse(x + i, 36, 1, 1), col) end
    fl(c, R(c, x - 4, 38, x + 4, 38), "#c89a58")
    if spot then c:px(x - 2, 35, spot); c:px(x + 1, 34, spot); c:px(x + 2, 36, spot) end
  end
  basket(33, "#6a3a8a", "#c8a0e0"); basket(43, "#c4402e", "#f08a7a"); basket(53, "#e8c860", "#fff0a8"); basket(63, "#e8a0a8", "#a8484a")
  for _, p in ipairs({ { 34, 42 }, { 46, 42 }, { 58, 42 } }) do part(c, c:ellipse(p[1], p[2], 2, 1), "#b8905a", { noline = true }) end
  -- gnome with notebook
  gnome(c, 14, 49, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 9, 6 }, true), arm({ -4, 7 }, { -6, 14 }, false) } })
  part(c, R(c, 22, 38, 27, 45), "#f4eee0"); fl(c, R(c, 23, 40, 26, 40), "#7a7a8a"); fl(c, R(c, 23, 42, 26, 42), "#7a7a8a"); fl(c, R(c, 24, 36, 24, 38), "#a8483a")
  finish(c, "potato_kinds")
end

-- 20. frog calls: dusk pond, a gnome with lantern and notebook on the jetty, three different frogs singing
function S.frog_calls()
  seed = 50
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#2a2a5a", "#3a3a6e", "#5a4a7e", "#8a5a82", "#c0786e" }, { dir = "v" })
  for _, p in ipairs({ { 10, 8 }, { 30, 6 }, { 48, 10 }, { 20, 16 }, { 62, 18 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(c:ellipse(58, 11, 3, 3), "#f5e6a8"); c:fill(c:ellipse(60, 10, 2, 2), "#3a3a6e")
  c:fill(c:ellipse(12, 31, 22, 8), "#1e3a3a"); c:fill(c:ellipse(56, 32, 26, 9), "#22403e")
  for _, x in ipairs({ 36, 40, 68 }) do part(c, R(c, x, 24, x, 35), "#2a5a3a", { noline = true }); fl(c, R(c, x - 1, 24, x + 1, 26), "#5a4028") end
  c:bands(R(c, 0, 32, W - 1, H - 1), { "#263a52", "#223048", "#1e2a40", "#1a2438" }, { dir = "v" })
  for _, p in ipairs({ { 30, 34 }, { 52, 36 }, { 24, 46 }, { 44, 48 } }) do fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#3e5a78") end
  -- jetty
  post(c, 8, 40, 10, 49); post(c, 30, 40, 32, 49)
  planks(c, 4, 38, 36, 40, "#9a6a3a", "#7a4a2a")
  -- lantern post
  post(c, 34, 30, 35, 38); part(c, R(c, 32, 26, 36, 30), "#ffd86a"); fl(c, R(c, 33, 27, 35, 29), "#fff1c8")
  c:fill(c:ellipse(34, 28, 5, 5), "#4a5a6e")
  part(c, R(c, 32, 26, 36, 30), "#ffd86a"); fl(c, R(c, 33, 27, 35, 29), "#fff1c8")
  gnome(c, 18, 37, { d = 1, sit = true, eyes = "open", arms = { arm({ 4, 6 }, { 7, 5 }, true) } })
  part(c, R(c, 26, 31, 30, 36), "#f4eee0"); fl(c, R(c, 27, 33, 29, 33), "#7a7a8a")
  -- lily pads + frogs
  local function frog(x, y, body, belly, eye)
    part(c, c:ellipse(x, y + 3, 5, 1), "#3a7a48", { noline = true })
    part(c, c:ellipse(x, y, 3, 2), body); fl(c, R(c, x - 1, y + 1, x + 1, y + 1), belly)
    part(c, R(c, x - 3, y - 3, x - 2, y - 2), eye, { noline = true }); part(c, R(c, x + 2, y - 3, x + 3, y - 2), eye, { noline = true })
    c:px(x - 3, y - 3, "#2a1a10"); c:px(x + 3, y - 3, "#2a1a10")
  end
  frog(46, 37, "#4aa04a", "#d8e8a8", "#e03a3a"); frog(58, 42, "#3a78c8", "#a8c8f0", "#f4eee0"); frog(52, 47, "#d8602e", "#f8d8a0", "#f4eee0")
  for _, p in ipairs({ { 42, 31 }, { 62, 36 }, { 64, 46 } }) do c:px(p[1], p[2], "#e8f070"); c:px(p[1], p[2] - 1, "#a8c040") end
  c:paint({ "g.g", ".g.", "g.g" }, 56, 36, { g = "#e8f0ff" })
  c:paint({ "g..", ".g.", "g.." }, 61, 41, { g = "#e8f0ff" }); c:paint({ ".g.", "g..", ".g." }, 47, 41, { g = "#e8f0ff" })
  finish(c, "frog_calls")
end

-- 21. weave patterns: highland blankets airing on a line, a gnome pointing out a favourite
function S.weave_patterns()
  seed = 51
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#a8d0e8", "#bcdcec", "#d0e8ee" }, { dir = "v" })
  c:fill(c:poly({ { 0, 34 }, { 12, 20 }, { 26, 30 }, { 44, 16 }, { 60, 28 }, { 72, 22 }, { 72, 36 }, { 0, 36 } }), "#9a98c0")
  c:fill(R(c, 0, 35, W - 1, H - 1), "#8aa860"); c:fill(R(c, 0, 35, W - 1, 35), "#a8c070")
  post(c, 6, 8, 8, 46); post(c, 61, 8, 63, 46)
  fl(c, R(c, 6, 9, 63, 9), "#5a3a22"); fl(c, R(c, 6, 10, 63, 10), "#8a5a35")
  local function blanket(x0, x1, rows)
    local w = x1 - x0 + 1
    part(c, R(c, x0, 11, x1, 40), "#d8402e")
    rows(x0, x1)
    for x = x0, x1, 2 do c:px(x, 41, "#f4eee0"); c:px(x, 42, "#e8c070") end
  end
  blanket(9, 30, function(x0, x1)
    for y = 12, 39, 6 do fl(c, R(c, x0, y, x1, y + 1), "#e8a317"); fl(c, R(c, x0, y + 2, x1, y + 2), "#2a2a4a"); fl(c, R(c, x0, y + 3, x1, y + 3), "#4a9a5a") end
    for _, cx in ipairs({ 14, 20, 26 }) do for _, cy in ipairs({ 20, 32 }) do c:px(cx, cy - 1, "#f4eee0"); c:px(cx - 1, cy, "#f4eee0"); c:px(cx + 1, cy, "#f4eee0"); c:px(cx, cy + 1, "#f4eee0") end end
  end)
  blanket(33, 54, function(x0, x1)
    c:fill(R(c, x0, 11, x1, 40), "#2a4a8a")
    local cx = (x0 + x1) // 2
    for r = 10, 2, -2 do
      local col = ({ [10] = "#e8a317", [8] = "#d8402e", [6] = "#f4eee0", [4] = "#4a9a5a", [2] = "#e8a317" })[r]
      c:fill(c:poly({ { cx, 26 - r - 3 }, { cx + r + 2, 26 }, { cx, 26 + r + 4 }, { cx - r - 2, 26 } }), col)
    end
    for y = 12, 39, 27 do fl(c, R(c, x0, y, x1, y + 1), "#e8a317") end
  end)
  gnome(c, 61, 47, { d = -1, eyes = "open", arms = { arm({ 4, 7 }, { 9, 15 }, true) } })
  finish(c, "weave_patterns")
end

-- 22. ripe cherimoya: four scaly dragon-green fruit on a cloth, a fingertip test, one cut open
function S.ripe_cherimoya()
  seed = 52
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#b8dc98", "#a8d088", "#98c478" }, { dir = "v" })
  for _, p in ipairs({ { 10, 10 }, { 30, 6 }, { 52, 10 }, { 66, 7 }, { 20, 22 }, { 58, 24 } }) do c:fill(c:ellipse(p[1], p[2], 7, 3), "#4e8a3c") end
  c:fill(R(c, 0, 31, W - 1, H - 1), "#8a6a40"); c:fill(R(c, 0, 31, W - 1, 31), "#a8844f")
  part(c, R(c, 24, 36, 68, 49), "#e8d8b0")
  for x = 24, 68, 6 do fl(c, R(c, x, 36, x + 2, 49), "#c4623a") end
  fl(c, R(c, 24, 36, 68, 36), "#f4eee0")
  local function cher(x, y, cut)
    part(c, c:ellipse(x, y, 6, 5), "#6aaa44", { shade = true })
    for dy = -3, 3, 3 do for dx = -4, 4, 2 do local xx = x + dx + ((dy // 3) % 2 == 0 and 0 or 1); c:px(xx, y + dy, "#3e7a2e"); c:px(xx, y + dy - 1, "#8ac860") end end
    c:px(x, y - 6, "#3e7a2e")
  end
  cher(30, 43, false); cher(41, 44, false); cher(63, 44, false)
  -- cut one
  part(c, c:ellipse(52, 44, 6, 5), "#6aaa44"); c:fill(c:ellipse(52, 44, 5, 4), "#f8f4e0"); c:fill(c:ellipse(52, 44, 5, 4):clip(R(c, 0, 0, 80, 43)), "#fdfaf0")
  for _, p in ipairs({ { 50, 42 }, { 53, 43 }, { 51, 45 }, { 54, 45 }, { 49, 44 } }) do c:px(p[1], p[2], "#2a1a10"); c:px(p[1] + 1, p[2], "#2a1a10") end
  gnome(c, 13, 52, { d = 1, upper = true, s = 1.25, eyes = "open", arms = { arm({ 4, 8 }, { 14, 9 }, true) } })
  finish(c, "ripe_cherimoya")
end

-- 23. bromeliad frog: five spiky rainwater rosettes on a mossy limb, a gnome with a hand lens finds the red frog
function S.bromeliad_frog()
  seed = 53
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 49), { "#2a5a3a", "#306a3e", "#3a7a44", "#46864c" }, { dir = "v" })
  for _, x in ipairs({ 12, 38, 64 }) do for y = 5, 22, 4 do c:px(x + ((y // 4) % 2), y, "#5aaa5a") end end
  for _, p in ipairs({ { 20, 10 }, { 46, 8 }, { 58, 20 } }) do c:fill(c:ellipse(p[1], p[2], 5, 2), "#4e9a50") end
  c:fill(R(c, 0, 45, W - 1, H - 1), "#2a4a30")
  -- mossy limb
  part(c, R(c, 5, 38, 68, 44), "#6a4a30"); fl(c, R(c, 5, 38, 68, 39), "#4a8a40")
  for x = 8, 66, 6 do c:px(x, 40, "#5aa850") end
  local function brom(x, frog)
    for _, d in ipairs({ { -7, -6 }, { -4, -9 }, { 0, -10 }, { 4, -9 }, { 7, -6 }, { -8, -2 }, { 8, -2 } }) do
      part(c, c:poly({ { x - 1, 37 }, { x + 1, 37 }, { x + d[1], 37 + d[2] } }), "#4fa845", { noline = false })
    end
    part(c, c:ellipse(x, 36, 4, 2), "#7ac0e0"); c:fill(R(c, x - 2, 36, x + 1, 36), "#b8e4f4")
    if frog then
      part(c, c:ellipse(x, 34, 2, 2), "#d8301e"); c:px(x - 1, 32, "#f4eee0"); c:px(x + 1, 32, "#f4eee0"); c:px(x - 1, 33, "#2a1a10"); c:px(x + 1, 33, "#2a1a10"); fl(c, R(c, x - 2, 36, x - 1, 36), "#3a78d8"); fl(c, R(c, x + 1, 36, x + 2, 36), "#3a78d8")
    end
  end
  for i, x in ipairs({ 26, 35, 44, 53, 62 }) do brom(x, i == 4) end
  gnome(c, 12, 49, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 10, 11 }, true, true) } })
  -- hand lens
  part(c, c:ellipse(25, 28, 4, 4), "#b8e4f4"); part(c, c:ellipse(25, 28, 4, 4), "#8a5a35", { noline = true }); c:fill(c:ellipse(25, 28, 3, 3), "#c8ecf8")
  c:px(23, 27, "#fbfdfe"); c:px(24, 26, "#fbfdfe")
  part(c, c:line({ { 22, 31 }, { 19, 36 } }, 1), "#8a5a35", { noline = true })
  fl(c, R(c, 18, 36, 20, 38), "#f0c8a0")
  finish(c, "bromeliad_frog")
end

-- 24. armadillo door: dusk by the ranch fence, four holes in the grass and one with glinting eyes
function S.armadillo_door()
  seed = 54
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 31), { "#5a4a82", "#8a5a8a", "#c0688a", "#e88a7a", "#f4b070", "#f8cf88" }, { dir = "v" })
  c:fill(c:ellipse(18, 31, 7, 5), "#fbe08a")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#5a7a44"); c:fill(R(c, 0, 31, W - 1, 31), "#7a9650")
  c:fill(R(c, 0, 40, W - 1, H - 1), "#4e6e3c")
  for x = 3, 66, 3 do c:px(x, 32 + (x % 5), "#3e5a30"); c:px(x + 1, 31 + (x % 7), "#3e5a30") end
  -- ranch fence
  for _, x in ipairs({ 8, 24, 40, 56 }) do part(c, R(c, x, 24, x + 2, 36), "#6a4a2e", { noline = true }) end
  fl(c, R(c, 5, 27, 68, 28), "#8a5a35"); fl(c, R(c, 5, 32, 68, 33), "#8a5a35")
  -- holes
  local function hole(x, y, eyes)
    part(c, c:ellipse(x, y, 6, 3), "#7a5a38", { noline = true })
    c:fill(c:ellipse(x, y + 1, 4, 2), "#1a1008"); c:fill(R(c, x - 4, y - 1, x + 4, y), "#7a5a38")
    c:fill(c:ellipse(x, y + 1, 4, 2):clip(R(c, 0, y + 1, 80, 80)), "#1a1008"); c:fill(R(c, x - 3, y + 1, x + 3, y + 1), "#1a1008")
    if eyes then c:px(x - 2, y + 1, "#ffe58a"); c:px(x + 2, y + 1, "#ffe58a"); c:px(x, y + 2, "#c8a090") end
  end
  hole(31, 41, false); hole(42, 45, true); hole(53, 41, false); hole(63, 46, false)
  gnome(c, 14, 46, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 10, 4 }, true) } })
  fl(c, R(c, 22, 41, 24, 43), "#f0c8a0")
  finish(c, "armadillo_door")
end

local order = { "dolphin_whistle", "condor_thermals", "ruin_steps", "mate_round", "anaconda_length", "quinoa_bread", "acai_bowl", "red_clay_pot",
  "humus_sift", "spring_oven", "terrace_wall", "latex_cups", "frost_potatoes", "salt_channel", "ombu_hands", "ant_leaf_rain",
  "panpipe_echo", "mirror_poses", "potato_kinds", "frog_calls", "weave_patterns", "ripe_cherimoya", "bromeliad_frog", "armadillo_door" }
for _, s2 in ipairs(order) do
  s2 = s2
  if S[s2] and (not only or only == s2) then seed = 7; S[s2]() end
end
