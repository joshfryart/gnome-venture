-- variety-act-g6.lua : Do-tab scenes for group g6 (4 kind cards + 11 w1 jetty/workshop activities) -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g6.lua   (params BEFORE --script). Helpers copied from variety-act-g5.lua.
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

---------------------------------------------------------------- shared bits for g6
local function spark(c, x, y, a, b)
  a, b = a or "#fff1c8", b or "#f5cf6a"
  c:px(x, y, a); c:px(x - 1, y, b); c:px(x + 1, y, b); c:px(x, y - 1, b); c:px(x, y + 1, b)
end
local function deck(c, y0, base, seam, hi)
  base, seam, hi = base or "#b07a45", seam or "#8a5a35", hi or "#d9a660"
  fl(c, R(c, 0, y0, W - 1, H - 1), base)
  fl(c, R(c, 0, y0, W - 1, y0), hi)
  local row = 0
  for y = y0 + 5, H - 1, 5 do
    fl(c, R(c, 0, y, W - 1, y), seam)
    for x = (row % 2) * 7 + 3, W - 1, 14 do fl(c, R(c, x, y - 4, x, y - 1), seam) end
    row = row + 1
  end
end
local function sea(c, hz, y1, cols)
  c:bands(R(c, 0, hz, W - 1, y1), cols or { "#6aaecb", "#5aa0c0", "#4a88b0", "#4a88b0" }, { dir = "v" })
  seed = 3
  for i = 1, 12 do
    local x, y = floor(rand() * 64) + 3, hz + 2 + floor(rand() * (y1 - hz - 2))
    fl(c, R(c, x, y, x + 2, y), "#a8dcea")
  end
end
local function skyhills(c, hz, cloud)
  c:bands(R(c, 0, 0, W - 1, hz), { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  if cloud then c:fill(c:ellipse(cloud, 11, 8, 2), "#f4eee0"); c:fill(c:ellipse(cloud + 4, 9, 5, 2), "#f4eee0") end
end
local function post(c, x, y0, y1, w, col)
  part(c, R(c, x, y0, x + (w or 2) - 1, y1), col or "#7a4a2a", { noline = false })
  fl(c, R(c, x, y0, x, y0), "#a8703e")
end
local function gear(c, x, y, r, col, hole)
  col = col or "#8b929c"
  local m = c:ellipse(x, y, r, r)
  for i = 0, 7 do
    local a = i * math.pi / 4
    local tx, ty = rnd(x + math.cos(a) * (r + 1)), rnd(y + math.sin(a) * (r + 1))
    m:add(c:rect(tx - 1, ty - 1, tx, ty))
  end
  part(c, m, col)
  c:fill(c:ellipse(x, y, math.max(1, rnd(r / 3)), math.max(1, rnd(r / 3))), hole or "#3a2a1c")
end
local function jar(c, x, y, body, lid, fill)  -- 5 wide, 6 tall body at (x,y) top-left
  part(c, R(c, x, y + 1, x + 4, y + 6), body)
  part(c, R(c, x, y, x + 4, y), lid or "#8a5a35", { noline = true })
  c:fill(R(c, x, y, x + 4, y), lid or "#8a5a35")
  c:fill(R(c, x + 1, y + 3, x + 3, y + 5), fill or "#f4eee0")
  c:px(x + 1, y + 2, "#f8f4ec")
end

---------------------------------------------------------------- scenes
local S = {}

-- craft card: gnome behind a bench stirring a bowl; ingredients drop in, a finished star-loaf waits
function S.craft()
  local c = new()
  fl(c, R(c, 0, 0, W - 1, 40), "#d9bc84")
  for x = 3, W - 1, 8 do fl(c, R(c, x, 0, x, 40), "#c4a468") end
  fl(c, R(c, 0, 41, W - 1, H - 1), "#8a5a35")
  for y = 45, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#6b3b2a") end
  -- window
  part(c, R(c, 8, 8, 22, 24), "#8a5a35")
  c:fill(R(c, 10, 10, 20, 22), "#a8d4e0"); c:fill(R(c, 10, 10, 20, 14), "#cfe8e6")
  fl(c, R(c, 15, 10, 15, 22), "#8a5a35"); fl(c, R(c, 10, 16, 20, 16), "#8a5a35")
  -- herb bundles hanging from a rod
  part(c, R(c, 44, 9, 67, 10), "#8a5a35", { noline = true })
  for i, x in ipairs({ 47, 54, 61 }) do
    fl(c, R(c, x, 11, x, 13), "#6b3b2a")
    local col = ({ "#4e8a3c", "#7ab55c", "#8a5aa0" })[i]
    part(c, c:poly({ { x - 2, 14 }, { x + 3, 14 }, { x + 1, 22 }, { x, 22 } }), col)
    fl(c, R(c, x - 1, 14, x - 1, 16), "#a8d890")
  end
  local _, G = gnome(c, 17, 43, { s = 1.25, d = 1, upper = true, eyes = "open",
    arms = { arm({ -4, 6 }, { 0, 5 }, false, true), arm({ 4, 7 }, { 11, 6 }, true) } })
  -- bench
  part(c, R(c, 4, 38, 66, 41), "#b07a45")
  fl(c, R(c, 4, 38, 66, 38), "#d9a660")
  part(c, R(c, 6, 42, 64, 48), "#8a5a35")
  for _, x in ipairs({ 18, 34, 50 }) do fl(c, R(c, x, 43, x, 48), "#6b3b2a") end
  -- bowl in the middle, spoon in the gnome's hand
  part(c, c:rrect(31, 33, 45, 38, 2), "#c4623a")
  c:fill(R(c, 32, 33, 44, 33), "#e8a317")
  c:fill(R(c, 33, 34, 35, 34), "#f5cf6a")
  local hx, hy = G.P(11, 6)
  c:fill(c:line({ { hx, hy - 1 }, { 38, 31 } }, 1), "#e8c48a"); c:fill(c:rect(37, 30, 39, 31), "#e8c48a")
  -- falling ingredients with sparkle trail
  part(c, c:ellipse(36, 22, 2, 1), "#4e8a3c", { noline = false }); c:px(36, 22, "#8fc462")
  part(c, c:ellipse(41, 26, 1, 1), "#dd3a2a")
  for _, p in ipairs({ { 36, 25 }, { 36, 28 }, { 41, 29 }, { 41, 31 } }) do c:px(p[1], p[2], "#fff1c8") end
  spark(c, 33, 19); spark(c, 45, 23)
  -- other ingredients and the finished star loaf
  part(c, c:ellipse(52, 36, 4, 2), "#7a8a6a"); c:fill(c:ellipse(52, 35, 2, 1), "#b8c8a8")
  jar(c, 56, 32, "#b8e0e8", "#8a5a35", "#e8a317")
  part(c, c:rrect(60, 36, 67, 38, 1), "#aeb4bc")
  c:paint({ "..g..", ".ggg.", "ggggg", ".ggg.", ".g.g." }, 62, 30, { g = "#f5cf6a" })
  c:px(64, 32, "#fff1c8")
  finish(c, "craft")
end

-- collect card: gnome slotting a jar into a display shelf of jars
function S.collect()
  local c = new()
  fl(c, R(c, 0, 0, W - 1, 41), "#9db89a")
  for y = 4, 40, 9 do fl(c, R(c, 0, y, W - 1, y), "#8aa688") end
  deck(c, 42, "#b07a45", "#8a5a35", "#d9a660")
  -- shelf unit
  part(c, R(c, 28, 8, 29, 44), "#8a5a35", { noline = true }); part(c, R(c, 64, 8, 65, 44), "#8a5a35", { noline = true })
  part(c, R(c, 27, 6, 66, 8), "#a8703e")
  part(c, R(c, 28, 21, 65, 22), "#c08a52")
  part(c, R(c, 28, 35, 65, 36), "#c08a52")
  fl(c, R(c, 30, 9, 63, 20), "#7f9a7e"); fl(c, R(c, 30, 23, 63, 34), "#7f9a7e"); fl(c, R(c, 30, 37, 63, 43), "#7f9a7e")
  local cols = { { "#dd3a2a", "#c0442e" }, { "#e8a317", "#f5cf6a" }, { "#3f8fb0", "#8cc4dc" }, { "#7ab55c", "#a8d890" }, { "#8a5aa0", "#c8a0d8" } }
  local function J(x, y, k) jar(c, x, y, "#d8ece8", "#8a5a35", cols[k][1]) end
  J(33, 14, 1); J(42, 14, 2); J(51, 14, 3); J(44, 28, 4); J(54, 28, 5)
  -- empty slot (dotted outline) at the lower left of the shelf, with a wee star
  for _, p in ipairs({ { 33, 28 }, { 35, 28 }, { 37, 28 }, { 33, 34 }, { 35, 34 }, { 37, 34 }, { 32, 30 }, { 32, 32 }, { 38, 30 }, { 38, 32 } }) do c:px(p[1], p[2], "#e8ecd8") end
  spark(c, 60, 29)
  -- small things on the floor shelf
  part(c, c:ellipse(36, 41, 3, 2), "#e8c48a"); part(c, c:ellipse(46, 41, 3, 2), "#a8703e"); part(c, c:ellipse(56, 41, 3, 2), "#e8c48a")
  -- gnome holding a jar up to the slot
  local _, G = gnome(c, 16, 47, { d = 1, eyes = "happy", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 12, 14 }, true, true) } })
  local jx, jy = G.P(12, 14)
  part(c, R(c, jx + 1, jy - 5, jx + 5, jy), "#d8ece8")
  c:fill(R(c, jx + 1, jy - 6, jx + 5, jy - 6), "#8a5a35"); c:fill(R(c, jx + 2, jy - 3, jx + 4, jy - 1), "#e46a9b")
  fl(c, R(c, jx - 1, jy - 1, jx + 1, jy + 1), "#f0c8a0")
  finish(c, "collect")
end

-- tend card: three beds at three growth stages, gnome watering the middle one
function S.tend()
  local c = new()
  day(c, 33, { cloud = 20 })
  c:fill(c:ellipse(60, 12, 4, 4), "#f5e6a8")
  part(c, R(c, 25, 36, 68, 46), "#6b4328", { noline = false })
  fl(c, R(c, 26, 37, 67, 37), "#8a5a35")
  for _, x in ipairs({ 30, 38, 46, 54, 62 }) do fl(c, R(c, x, 41, x + 2, 41), "#8a5a35"); fl(c, R(c, x + 3, 44, x + 4, 44), "#8a5a35") end
  -- stage 1: seed mound with a tiny sprout
  c:fill(c:ellipse(33, 36, 3, 1), "#8a5a35")
  fl(c, R(c, 33, 33, 33, 35), "#4e8a3c"); c:px(32, 33, "#7ab55c"); c:px(34, 32, "#7ab55c")
  -- stage 2: leafy sprout
  fl(c, R(c, 46, 29, 46, 36), "#4e8a3c")
  part(c, c:ellipse(43, 31, 3, 1), "#7ab55c"); part(c, c:ellipse(50, 29, 3, 1), "#7ab55c")
  -- stage 3: tall with a flower
  fl(c, R(c, 60, 17, 60, 36), "#3f7a35")
  part(c, c:ellipse(56, 29, 3, 1), "#7ab55c"); part(c, c:ellipse(64, 25, 3, 1), "#7ab55c")
  part(c, c:ellipse(60, 15, 4, 4), "#e46a9b"); c:fill(c:ellipse(60, 15, 1, 1), "#f5cf6a")
  -- tiny peg marking the days
  part(c, R(c, 27, 31, 28, 38), "#e8c48a", { noline = false })
  -- gnome with watering can
  local _, G = gnome(c, 14, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 7 }, { 10, 11 }, true, true) } })
  local cx, cy = G.P(10, 11)
  part(c, R(c, cx - 1, cy - 4, cx + 6, cy + 3), "#4a88b0")
  fl(c, R(c, cx + 1, cy - 4, cx + 5, cy - 4), "#8cc4dc")
  c:fill(c:line({ { cx + 6, cy }, { cx + 10, cy - 3 } }, 2), "#3a6a94")
  fl(c, R(c, cx - 1, cy - 6, cx + 4, cy - 6), "#3a6a94"); fl(c, R(c, cx - 1, cy - 5, cx - 1, cy - 4), "#3a6a94")
  fl(c, R(c, cx - 2, cy - 1, cx, cy + 1), "#f0c8a0")
  for i, p in ipairs({ { 11, -3 }, { 13, 0 }, { 12, 3 }, { 14, 6 } }) do c:px(cx + p[1], cy + p[2] + 1, "#8cc4dc"); if i % 2 == 0 then c:px(cx + p[1] + 1, cy + p[2], "#e8f8f4") end end
  finish(c, "tend")
end

-- contest card: finish tape across the track, gnome breaks it with arms up, rosette, rival far behind
function S.contest()
  local c = new()
  day(c, 30, { cloud = 14 })
  -- bunting across the top
  c:fill(c:line({ { 5, 8 }, { 20, 11 }, { 40, 11 }, { 56, 11 }, { 68, 8 } }, 1), "#5e3f28")
  local cols = { "#dd3a2a", "#f5cf6a", "#3f8fb0", "#7ab55c" }
  for i, f in ipairs({ { 9, 9 }, { 15, 11 }, { 22, 12 }, { 29, 12 }, { 36, 12 }, { 43, 12 }, { 50, 12 }, { 57, 11 }, { 63, 10 } }) do
    fl(c, c:poly({ { f[1], f[2] + 1 }, { f[1] + 4, f[2] + 1 }, { f[1] + 2, f[2] + 5 } }), cols[(i - 1) % 4 + 1])
  end
  -- track
  fl(c, R(c, 0, 36, W - 1, H - 1), "#c9a96e"); fl(c, R(c, 0, 36, W - 1, 36), "#d9bc84")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 41, x + 2, 41), "#b8965c") end
  fl(c, R(c, 0, 50, W - 1, 50), "#f4eee0")
  -- rival, small and far behind
  gnome(c, 12, 41, { d = 1, walk = -1, hat = "#4f9a45", s = 0.8, eyes = "open", arms = { arm({ -4, 7 }, { -6, 4 }, false), arm({ 4, 7 }, { 6, 4 }, true) } })
  -- tape posts
  part(c, R(c, 5, 22, 7, 46), "#f4eee0"); part(c, R(c, 65, 22, 67, 46), "#f4eee0")
  for y = 24, 44, 4 do fl(c, R(c, 5, y, 7, y + 1), "#dd3a2a"); fl(c, R(c, 65, y, 67, y + 1), "#dd3a2a") end
  -- winner behind the tape, arms up
  gnome(c, 37, 47, { s = 1.25, d = 1, eyes = "happy", arms = { arm({ -4, 8 }, { -8, 17 }, false), arm({ 4, 8 }, { 8, 17 }, true) } })
  -- tape: striped ribbon, snapped and fluttering at the middle
  for x = 8, 31 do fl(c, R(c, x, 34 + (x > 28 and 1 or 0), x, 35 + (x > 28 and 1 or 0)), (x // 2 % 2 == 0) and "#dd3a2a" or "#f4eee0") end
  for x = 43, 64 do fl(c, R(c, x, 34 + (x < 46 and 1 or 0), x, 35 + (x < 46 and 1 or 0)), (x // 2 % 2 == 0) and "#dd3a2a" or "#f4eee0") end
  fl(c, R(c, 31, 36, 32, 38), "#dd3a2a"); fl(c, R(c, 41, 36, 42, 38), "#f4eee0")
  -- rosette hung above on the right
  local function rosette(x, y)
    fl(c, R(c, x - 3, y + 4, x - 1, y + 10), "#3f6fb0"); fl(c, R(c, x + 1, y + 4, x + 3, y + 10), "#e8a317")
    part(c, c:ellipse(x, y, 5, 5), "#3f6fb0")
    c:fill(c:ellipse(x, y, 3, 3), "#5a8ad0"); c:fill(c:ellipse(x, y, 1, 1), "#f5cf6a")
  end
  rosette(58, 17)
  spark(c, 50, 20); spark(c, 24, 22); spark(c, 62, 28)
  finish(c, "contest")
end

-- w1_net_mending
function S.w1_net_mending()
  local c = new()
  skyhills(c, 24, 50)
  sea(c, 24, 42)
  -- far sail
  part(c, c:poly({ { 56, 17 }, { 56, 25 }, { 62, 25 } }), "#f4eee0"); fl(c, R(c, 55, 17, 55, 26), "#5e3f28")
  -- rail and posts
  post(c, 4, 22, 44, 3); post(c, 64, 22, 44, 3)
  part(c, R(c, 4, 22, 66, 24), "#a8703e")
  -- net hanging from the rail: diamond mesh with a hole
  local hole = c:ellipse(30, 32, 5, 4)
  for y = 25, 42 do for x = 6, 52 do
    local ed = (x > 48 and y > 36) or (x < 8 and y > 40)
    if ((x + y) % 4 == 0 or (x - y) % 4 == 0) and not hole:has(x, y) and not ed then c:px(x, y, "#e0c88a") end
  end end
  for _, p in ipairs({ { 25, 31 }, { 35, 31 }, { 30, 27 }, { 30, 37 }, { 27, 28 }, { 33, 36 } }) do c:px(p[1], p[2], "#b89460") end
  deck(c, 43, "#b07a45", "#8a5a35", "#d9a660")
  -- gnome with needle and thread
  local _, G = gnome(c, 54, 49, { d = -1, eyes = "open", arms = { arm({ 4, 6 }, { 6, 3 }, true), arm({ -4, 8 }, { -9, 12 }, false) } })
  local hx, hy = G.P(-9, 12)
  c:fill(c:line({ { hx, hy }, { 33, 33 } }, 1), "#e8c48a")
  c:px(34, 32, "#f4eee0"); c:px(35, 31, "#f4eee0")
  c:fill(c:line({ { 34, 36 }, { 29, 41 } }, 1), "#e0c88a")
  -- ball of twine at the feet
  part(c, c:ellipse(40, 48, 3, 2), "#e8c48a")
  c:px(39, 47, "#b89460"); c:px(41, 49, "#b89460")
  finish(c, "w1_net_mending")
end

-- w1_gull_standoff
function S.w1_gull_standoff()
  local c = new()
  skyhills(c, 26, 14)
  sea(c, 26, 40)
  deck(c, 38, "#b07a45", "#8a5a35", "#d9a660")
  -- crate/bollard the gull has claimed
  part(c, R(c, 44, 36, 62, 46), "#a8703e")
  fl(c, R(c, 45, 36, 61, 36), "#d9a660"); fl(c, R(c, 52, 37, 52, 46), "#8a5a35"); fl(c, R(c, 45, 41, 61, 41), "#8a5a35")
  -- gull: body, wing, tail, head, beak, glare
  part(c, c:poly({ { 60, 28 }, { 68, 30 }, { 62, 34 } }), "#8b929c")
  part(c, c:ellipse(53, 31, 9, 5), "#f4f8fa")
  c:fill(c:ellipse(55, 32, 6, 3), "#aeb4bc"); fl(c, R(c, 50, 33, 58, 33), "#8b929c")
  part(c, c:ellipse(45, 25, 4, 4), "#f4f8fa")
  part(c, c:poly({ { 41, 24 }, { 37, 27 }, { 42, 27 } }), "#f5cf6a"); c:px(37, 27, "#dd8a1e")
  c:px(44, 24, INK); c:px(43, 23, INK); c:px(45, 23, "#a8703e")
  fl(c, R(c, 49, 35, 49, 36), "#e8923a"); fl(c, R(c, 56, 35, 56, 36), "#e8923a")
  -- gnome glaring
  local _, G = gnome(c, 20, 48, { s = 1.25, d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 6 }, { 7, 3 }, true) } })
  -- glare lines between them
  fl(c, R(c, 30, 28, 32, 28), "#dd3a2a"); fl(c, R(c, 31, 31, 34, 31), "#dd3a2a"); fl(c, R(c, 30, 34, 32, 34), "#dd3a2a")
  c:px(52, 19, "#f4f8fa"); c:px(53, 18, "#f4f8fa"); c:px(60, 20, "#f4f8fa")
  c:px(34, 46, "#e8c48a"); c:px(35, 46, "#e8c48a")
  finish(c, "w1_gull_standoff")
end

-- w1_wriggle_bucket
function S.w1_wriggle_bucket()
  local c = new()
  skyhills(c, 22, 52)
  sea(c, 22, 33)
  deck(c, 33, "#b07a45", "#8a5a35", "#d9a660")
  local function bucket(x, wig)
    post(c, x + 6, 20, 34, 2)
    part(c, c:poly({ { x - 1, 28 }, { x + 9, 28 }, { x + 8, 37 }, { x, 37 } }), "#aeb4bc")
    fl(c, R(c, x, 31, x + 8, 31), "#8b929c"); fl(c, R(c, x, 34, x + 8, 34), "#8b929c")
    fl(c, R(c, x - 1, 28, x + 9, 28), "#d0d4da")
  end
  for _, x in ipairs({ 6, 20, 42, 56 }) do bucket(x) end
  -- the wriggler (bucket at x=42): a fish leaping out, with splash
  part(c, c:ellipse(46, 21, 4, 2), "#e8923a")
  part(c, c:poly({ { 41, 17 }, { 43, 21 }, { 40, 23 } }), "#c8701e")
  fl(c, R(c, 45, 20, 47, 20), "#f5cf6a"); c:px(48, 20, INK)
  fl(c, R(c, 44, 23, 48, 23), "#f4eee0")
  for _, p in ipairs({ { 38, 25 }, { 52, 24 }, { 40, 29 }, { 53, 28 }, { 49, 15 }, { 42, 14 } }) do c:px(p[1], p[2], "#a8e6f0"); c:px(p[1], p[2] + 1, "#e8f8f4") end
  fl(c, R(c, 43, 28, 48, 28), "#e8f8f4")
  -- gnome thinking, hand on chin, eyeing the right one
  local _, G = gnome(c, 33, 49, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 9, 12 }, true) } })
  finish(c, "w1_wriggle_bucket")
end

-- w1_dry_kelp
function S.w1_dry_kelp()
  local c = new()
  skyhills(c, 28, 44)
  sea(c, 28, 40)
  post(c, 6, 18, 40, 3); post(c, 62, 18, 40, 3)
  c:fill(c:line({ { 8, 21 }, { 20, 24 }, { 34, 25 }, { 48, 24 }, { 62, 21 } }, 1), "#5e3f28")
  local kc = { "#3f6a3a", "#5a7a34", "#2f5a2a", "#6a8a3a", "#3f6a3a", "#4a7a3a" }
  for i, x in ipairs({ 11, 16, 22, 28, 43, 49, 54, 59 }) do
    local len = 11 + (i * 5) % 6
    local col = kc[(i - 1) % #kc + 1]
    for y = 25, 25 + len do
      local off = ((y // 2) % 2 == 0) and 0 or 1
      fl(c, R(c, x + off, y, x + off + 2, y), col)
    end
    c:px(x + 2, 25 + len, col)
    c:fill(c:rect(x, 25, x + 1, 26), "#5e3f28")
  end
  deck(c, 40, "#b07a45", "#8a5a35", "#d9a660")
  -- sack of finished meal with a scoop
  part(c, c:poly({ { 6, 38 }, { 16, 38 }, { 17, 47 }, { 5, 47 } }), "#d9bc84")
  part(c, c:ellipse(11, 38, 6, 2), "#4e7a34"); c:fill(c:ellipse(11, 38, 4, 1), "#6a8a3a")
  c:px(9, 36, "#8fb060"); c:px(13, 37, "#8fb060")
  fl(c, R(c, 8, 41, 14, 41), "#a8703e")
  -- gnome pegging up a frond
  local _, G = gnome(c, 36, 48, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 6, 16 }, true, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  local hx, hy = G.P(6, 16)
  for y = hy, hy + 12 do local off = ((y // 2) % 2 == 0) and 0 or 1; fl(c, R(c, hx - 1 + off, y, hx + off, y), "#5a7a34") end
  fl(c, R(c, hx - 1, hy - 2, hx + 1, hy), "#f0c8a0")
  finish(c, "w1_dry_kelp")
end

-- w1_jetty_knots
function S.w1_jetty_knots()
  local c = new()
  skyhills(c, 20, 52)
  sea(c, 20, 38)
  deck(c, 38, "#b07a45", "#8a5a35", "#d9a660")
  local function pile(x) post(c, x, 10, 40, 5, "#7a4a2a"); fl(c, R(c, x + 3, 12, x + 3, 38), "#5e2f1e") end
  pile(5); pile(17); pile(29)
  local rope, ropeD = "#e0c88a", "#b89460"
  -- post 1: wrapped bands (round turn)
  for y = 17, 27, 3 do fl(c, R(c, 4, y, 10, y + 1), rope); fl(c, R(c, 4, y + 1, 10, y + 1), ropeD) end
  -- post 2: a loop hanging from a hitch
  fl(c, R(c, 16, 18, 22, 19), rope); fl(c, R(c, 16, 19, 22, 19), ropeD)
  part(c, c:ellipse(19, 27, 3, 5), rope, { noline = false }); c:fill(c:ellipse(19, 27, 1, 3), "#9ac8d8")
  -- post 3: a figure of eight
  fl(c, R(c, 28, 16, 34, 17), rope); fl(c, R(c, 28, 17, 34, 17), ropeD)
  part(c, c:ellipse(31, 23, 3, 3), rope); c:fill(c:ellipse(31, 23, 1, 1), "#8a5a35")
  part(c, c:ellipse(31, 30, 3, 3), rope); c:fill(c:ellipse(31, 30, 1, 1), "#8a5a35")
  -- gnome holding a freshly tied monkey's fist
  local _, G = gnome(c, 52, 49, { s = 1.25, d = -1, eyes = "happy", arms = { arm({ 4, 8 }, { 7, 4 }, true, true), arm({ -4, 8 }, { -9, 14 }, false, true) } })
  local hx, hy = G.P(-9, 14)
  part(c, c:ellipse(hx - 1, hy - 2, 3, 3), rope)
  c:px(hx - 2, hy - 3, ropeD); c:px(hx, hy - 3, ropeD); c:px(hx - 1, hy - 1, ropeD); c:px(hx - 1, hy - 4, ropeD)
  fl(c, R(c, hx - 1, hy + 1, hx + 1, hy + 2), "#f0c8a0")
  c:fill(c:line({ { hx - 1, hy + 1 }, { hx - 3, hy + 9 }, { 44, 44 } }, 1), rope)
  spark(c, hx - 7, hy - 7); spark(c, hx + 6, hy - 5)
  finish(c, "w1_jetty_knots")
end

-- w1_bail_dinghy: rain, gnome in a little boat flinging water out
function S.w1_bail_dinghy()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#6a7a8c", "#7a8a9a", "#8a9aaa", "#9aaab8" }, { dir = "v" })
  c:fill(c:ellipse(16, 10, 9, 3), "#5e6e80"); c:fill(c:ellipse(52, 7, 10, 3), "#5e6e80"); c:fill(c:ellipse(36, 15, 8, 2), "#6a7a8c")
  sea(c, 28, H - 1, { "#5a7a94", "#4e6e8a", "#456480", "#3e5a74" })
  for _, x in ipairs({ 6, 12, 18 }) do part(c, R(c, x, 24, x + 1, 36), "#5e3f28", { noline = false }) end
  fl(c, R(c, 5, 25, 20, 26), "#7a5a3a")
  seed = 77
  for i = 1, 60 do
    local x, y = 6 + floor(rand() * 62), 5 + floor(rand() * 42)
    c:px(x, y, "#d0dce8"); c:px(x - 1, y + 1, "#d0dce8")
  end
  -- boat: hull with a water line, gnome upper-body sat in it
  local _, G = gnome(c, 38, 43, { upper = true, s = 1.0, d = -1, eyes = "open", arms = { arm({ 4, 6 }, { 6, 3 }, true), arm({ -4, 7 }, { -11, 13 }, true, true) } })
  part(c, c:poly({ { 20, 38 }, { 58, 38 }, { 52, 47 }, { 27, 47 } }), "#a8703e")
  fl(c, R(c, 21, 38, 57, 38), "#d9a660"); fl(c, R(c, 25, 41, 54, 41), "#8a5a35")
  fl(c, R(c, 23, 39, 55, 40), "#4a6e8a")
  fl(c, R(c, 28, 44, 52, 44), "#8a5a35")
  -- bucket flinging water over the side
  local hx, hy = G.P(-11, 13)
  part(c, c:poly({ { hx - 5, hy - 1 }, { hx + 1, hy - 1 }, { hx - 1, hy + 4 }, { hx - 4, hy + 4 } }), "#aeb4bc")
  fl(c, R(c, hx - 2, hy - 1, hx - 2, hy - 1), "#8cc4dc")
  fl(c, R(c, hx - 2, hy, hx + 1, hy + 3), "#f0c8a0")
  for _, p in ipairs({ { -9, 2 }, { -11, 0 }, { -13, 3 }, { -10, 5 } }) do c:px(hx + p[1], hy + p[2], "#8cc4dc"); c:px(hx + p[1] - 1, hy + p[2] + 1, "#e8f8f4") end
  -- ripples
  fl(c, R(c, 14, 46, 22, 46), "#8ab0c8"); fl(c, R(c, 56, 47, 66, 47), "#8ab0c8"); fl(c, R(c, 24, 50, 54, 50), "#6a8aa4")
  finish(c, "w1_bail_dinghy")
end

-- w1_whetstone
function S.w1_whetstone()
  local c = new()
  fl(c, R(c, 0, 0, W - 1, 42), "#8a6a46")
  for x = 3, W - 1, 9 do fl(c, R(c, x, 0, x, 42), "#6b5030") end
  fl(c, R(c, 0, 43, W - 1, H - 1), "#5e3f28")
  for y = 47, 53, 4 do fl(c, R(c, 0, y, W - 1, y), "#4a2c1a") end
  -- window and hanging tools
  part(c, R(c, 28, 7, 40, 20), "#a8703e")
  c:fill(R(c, 30, 9, 38, 18), "#bcdde4"); fl(c, R(c, 34, 9, 34, 18), "#a8703e")
  for i, x in ipairs({ 6, 11, 16 }) do
    fl(c, R(c, x, 8, x, 9), "#3a2a1c")
    part(c, R(c, x - 1, 10, x + 1, 21 + (i % 2) * 4), "#8b929c")
    fl(c, R(c, x - 1, 10, x + 1, 12), "#a8703e")
  end
  -- whetstone wheel on a trestle
  part(c, R(c, 52, 38, 53, 47), "#a8703e", { noline = true }); part(c, R(c, 63, 38, 64, 47), "#a8703e", { noline = true })
  part(c, R(c, 50, 36, 66, 38), "#c08a52")
  part(c, c:ellipse(58, 28, 9, 9), "#aeb4bc", { shade = true })
  c:fill(c:ellipse(58, 28, 3, 3), "#8b929c"); c:fill(c:ellipse(58, 28, 1, 1), "#3a2a1c")
  for _, p in ipairs({ { 52, 24 }, { 56, 21 }, { 63, 24 }, { 62, 33 } }) do c:px(p[1], p[2], "#d0d4da") end
  fl(c, R(c, 56, 36, 60, 36), "#8cc4dc")
  -- gnome sharpening a trowel
  local _, G = gnome(c, 36, 47, { d = 1, eyes = "shut", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 9, 11 }, true) } })
  local hx, hy = G.P(9, 11)
  c:fill(c:line({ { hx, hy }, { 47, 28 } }, 2), "#e8ecf0")
  c:fill(c:poly({ { 46, 25 }, { 49, 27 }, { 49, 32 }, { 45, 31 } }), "#e8ecf0")
  spark(c, 49, 31, "#f8f4ec", "#f5cf6a"); c:px(47, 34, "#f08a24"); c:px(51, 27, "#ffd86a"); c:px(46, 22, "#f08a24")
  -- bucket of blunt tools, red tags
  part(c, c:poly({ { 6, 38 }, { 20, 38 }, { 18, 48 }, { 8, 48 } }), "#6a7a8c")
  fl(c, R(c, 7, 41, 19, 41), "#4a5a6c"); fl(c, R(c, 8, 45, 18, 45), "#4a5a6c")
  fl(c, R(c, 9, 29, 10, 38), "#a8703e"); part(c, R(c, 8, 26, 11, 30), "#8b929c")
  fl(c, R(c, 13, 31, 13, 38), "#a8703e"); fl(c, R(c, 12, 27, 14, 31), "#8b929c")
  fl(c, R(c, 17, 30, 17, 38), "#7a4a2a"); fl(c, R(c, 16, 28, 18, 30), "#c8ccd4")
  fl(c, R(c, 11, 33, 12, 34), "#dd3a2a"); fl(c, R(c, 15, 34, 16, 35), "#dd3a2a")
  finish(c, "w1_whetstone")
end

-- w1_cart_wheel
function S.w1_cart_wheel()
  local c = new()
  day(c, 25, { cloud = 52 })
  fl(c, R(c, 0, 26, W - 1, H - 1), "#c9a96e"); fl(c, R(c, 0, 26, W - 1, 26), "#d9bc84")
  for _, p in ipairs({ { 8, 45 }, { 28, 49 }, { 52, 48 }, { 64, 44 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#b8965c") end
  -- cart bed on a stack of blocks, missing its wheel
  part(c, R(c, 6, 40, 14, 47), "#8b8f96")
  part(c, R(c, 2, 24, 22, 38), "#a8703e")
  fl(c, R(c, 3, 25, 21, 25), "#d9a660")
  for _, x in ipairs({ 8, 14 }) do fl(c, R(c, x, 26, x, 37), "#8a5a35") end
  part(c, R(c, 20, 20, 23, 25), "#7a4a2a")
  fl(c, R(c, 17, 38, 22, 40), "#5e3f28")
  -- the wheel: rim, hub, spokes (three missing)
  local cx, cy, r = 50, 35, 11
  part(c, c:ellipse(cx, cy, r, r), "#8a5a35", { shade = false })
  c:fill(c:ellipse(cx, cy, r - 2, r - 2), "#c9a96e")
  fl(c, R(c, 0, 0, 0, 0), "#c9a96e")
  for i = 0, 7 do
    local a = i * math.pi / 4 + 0.2
    if i ~= 1 and i ~= 4 and i ~= 6 then
      local x1, y1 = rnd(cx + math.cos(a) * (r - 2)), rnd(cy + math.sin(a) * (r - 2))
      c:fill(c:line({ { cx, cy }, { x1, y1 } }, 2), "#e8c48a")
    end
  end
  part(c, c:ellipse(cx, cy, 3, 3), "#6b3b2a"); c:px(cx, cy, "#d9a660")
  fl(c, R(c, cx - r + 1, cy - 2, cx - r + 2, cy - 2), "#b07a45")
  -- gnome with a spoke in hand, about to fit it
  local _, G = gnome(c, 28, 48, { s = 1.25, d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 7 }, { 9, 11 }, true) } })
  local hx, hy = G.P(9, 11)
  c:fill(c:line({ { hx, hy - 1 }, { cx - 8, cy + 2 } }, 2), "#f0d49e")
  spark(c, 35, 24); c:px(55, 20, "#f5cf6a")
  finish(c, "w1_cart_wheel")
end

-- w1_plane_boards
function S.w1_plane_boards()
  local c = new()
  day(c, 33, { sky = { "#b9d9d0", "#cfe2cc", "#dce8c8" }, hill = "#4e7a3a", hill2 = "#3f6a32", cloud = false })
  pine(c, 8, 36, 20, false); pine(c, 17, 34, 14, false); pine(c, 62, 35, 18, false)
  fl(c, R(c, 0, 34, W - 1, H - 1), "#b89a64")
  fl(c, R(c, 0, 34, W - 1, 34), "#c9ae78")
  -- trestles and the board being planed
  part(c, R(c, 34, 40, 35, 48), "#7a4a2a", { noline = true }); part(c, R(c, 60, 40, 61, 48), "#7a4a2a", { noline = true })
  part(c, R(c, 31, 37, 66, 40), "#e8c48a")
  fl(c, R(c, 32, 37, 65, 37), "#f0d49e")
  for _, p in ipairs({ { 52, 39 }, { 62, 39 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#c08a52") end
  fl(c, R(c, 45, 38, 47, 38), "#b07a45")
  -- the plane
  local _, G = gnome(c, 24, 48, { s = 1.25, d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -2, 4 }, false), arm({ 4, 7 }, { 11, 9 }, true) } })
  part(c, R(c, 38, 33, 46, 37), "#c08a52")
  fl(c, R(c, 38, 36, 46, 37), "#8b929c"); part(c, R(c, 44, 30, 46, 33), "#7a4a2a")
  -- curling shavings
  for _, p in ipairs({ { 49, 31 }, { 54, 33 }, { 59, 32 } }) do
    c:paint({ ".fff.", "fsssf", "fsff.", ".ff.." }, p[1] - 2, p[2] - 2, { f = "#a8703e", s = "#f0d49e" })
  end
  for _, p in ipairs({ { 28, 49 }, { 38, 49 }, { 46, 48 }, { 52, 49 }, { 66, 48 } }) do c:px(p[1], p[2], "#f0d49e"); c:px(p[1] + 1, p[2], "#f0d49e") end
  -- stack of finished boards
  part(c, R(c, 2, 44, 17, 46), "#e8c48a"); part(c, R(c, 3, 41, 16, 43), "#f0d49e"); part(c, R(c, 2, 47, 18, 49), "#e8c48a")
  finish(c, "w1_plane_boards")
end

-- w1_inventors_duel
function S.w1_inventors_duel()
  local c = new()
  fl(c, R(c, 0, 0, W - 1, 41), "#7a8c94")
  for y = 5, 40, 7 do fl(c, R(c, 0, y, W - 1, y), "#6a7c84") end
  deck(c, 42, "#8a5a35", "#6b3b2a", "#a8703e")
  -- wall gears and a banner
  gear(c, 11, 14, 5, "#8b929c"); gear(c, 58, 12, 4, "#8b929c")
  part(c, R(c, 28, 6, 44, 18), "#c0442e")
  c:fill(c:poly({ { 28, 18 }, { 36, 22 }, { 44, 18 } }), "#c0442e")
  c:paint({ "..g..", ".ggg.", "ggggg", ".ggg.", ".g.g." }, 34, 9, { g = "#f5cf6a" })
  -- lever on a log in the middle
  part(c, c:ellipse(36, 47, 4, 3), "#8a5a35"); fl(c, R(c, 36, 46, 36, 46), "#c08a52")
  part(c, c:poly({ { 26, 44 }, { 46, 40 }, { 46, 42 }, { 26, 46 } }), "#d9a660")
  part(c, R(c, 42, 36, 46, 39), "#8b929c")
  -- red gnome with a spring gadget; green gnome with a gear
  local _, GA = gnome(c, 14, 48, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 8, 15 }, true, true) } })
  local sx, sy = GA.P(8, 15)
  part(c, R(c, sx - 3, sy, sx + 3, sy + 1), "#8a5a35")
  for i = 0, 3 do fl(c, R(c, sx - 3 + (i % 2) * 3, sy - 2 - i * 2, sx - 1 + (i % 2) * 3 + 1, sy - 1 - i * 2), "#aeb4bc") end
  fl(c, R(c, sx - 2, sy - 9, sx + 2, sy - 9), "#e8a317")
  fl(c, R(c, sx - 1, sy - 1, sx + 1, sy + 1), "#f0c8a0")
  local _, GB = gnome(c, 58, 48, { d = -1, hat = "#4f9a45", eyes = "open", arms = { arm({ 4, 6 }, { 5, 3 }, false), arm({ -4, 8 }, { -8, 15 }, true, true) } })
  local gx, gy = GB.P(-8, 15)
  gear(c, gx, gy - 5, 5, "#e8a317", "#4a3a18")
  fl(c, R(c, gx - 1, gy - 1, gx + 1, gy + 1), "#f0c8a0")
  spark(c, 36, 27, "#f8f4ec", "#f5cf6a"); c:px(31, 24, "#f08a24"); c:px(41, 29, "#f08a24"); c:px(33, 31, "#ffd86a")
  finish(c, "w1_inventors_duel")
end

-- w1_anvil_bell
function S.w1_anvil_bell()
  local c = new()
  day(c, 33, { cloud = 14 })
  -- barn wall at the right
  part(c, R(c, 56, 16, 69, 36), "#b8503a")
  for x = 58, 68, 3 do fl(c, R(c, x, 17, x, 35), "#963e2c") end
  part(c, c:poly({ { 54, 16 }, { 62, 8 }, { 70, 16 } }), "#6b3b2a")
  part(c, R(c, 59, 26, 65, 36), "#f4eee0"); fl(c, R(c, 62, 27, 62, 36), "#b8503a")
  fl(c, R(c, 0, 34, W - 1, H - 1), "#c9a96e"); fl(c, R(c, 0, 34, W - 1, 34), "#d9bc84")
  for _, p in ipairs({ { 6, 46 }, { 30, 49 }, { 52, 48 }, { 14, 40 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#b8965c") end
  -- tall pole with rails, rungs of marks, puck halfway, bell on top
  part(c, R(c, 41, 14, 45, 42), "#8a5a35")
  fl(c, R(c, 43, 15, 43, 41), "#4a2c1a")
  for y = 19, 39, 4 do fl(c, R(c, 41, y, 42, y), "#f4eee0") end
  part(c, R(c, 40, 27, 46, 30), "#dd3a2a"); fl(c, R(c, 41, 27, 45, 27), "#f4a090")
  part(c, c:poly({ { 40, 9 }, { 46, 9 }, { 48, 15 }, { 38, 15 } }), "#f5cf6a")
  fl(c, R(c, 41, 10, 41, 13), "#fff1c8"); fl(c, R(c, 42, 7, 44, 8), "#c89a2a")
  part(c, c:ellipse(43, 16, 1, 1), "#c89a2a")
  for _, p in ipairs({ { 35, 8 }, { 51, 8 }, { 34, 14 }, { 52, 14 } }) do spark(c, p[1], p[2]) end
  -- base and the lever
  part(c, R(c, 34, 42, 52, 45), "#6b3b2a")
  part(c, c:poly({ { 20, 38 }, { 36, 40 }, { 36, 43 }, { 20, 41 } }), "#d9a660")
  part(c, R(c, 36, 40, 40, 43), "#8b929c")
  -- gnome with a big mallet, mid swing
  local _, G = gnome(c, 14, 48, { s = 1.25, d = 1, walk = 1, eyes = "open", arms = { arm({ -4, 8 }, { 0, 16 }, false), arm({ 4, 8 }, { 8, 17 }, true) } })
  local hx, hy = G.P(8, 17)
  c:fill(c:line({ { hx, hy }, { hx + 5, hy - 6 } }, 2), "#a8703e")
  part(c, c:poly({ { hx + 3, hy - 12 }, { hx + 13, hy - 8 }, { hx + 11, hy - 3 }, { hx + 1, hy - 7 } }), "#aeb4bc")
  finish(c, "w1_anvil_bell")
end

local order = { "craft", "collect", "tend", "contest", "w1_net_mending", "w1_gull_standoff", "w1_wriggle_bucket", "w1_dry_kelp", "w1_jetty_knots", "w1_bail_dinghy", "w1_whetstone", "w1_cart_wheel", "w1_plane_boards", "w1_inventors_duel", "w1_anvil_bell" }
for _, s2 in ipairs(order) do
  if not only or only == s2 then seed = 7; S[s2]() end
end
