-- variety-act-h16.lua : regional rest-stop scenes (group h16) -> act-<slug>.png (144x108, drawn on 72x54, out=2). param only=<slug>, out=<dir>/
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
local function round_tree(c, x, yb, r, trunkh, col)
  part(c, R(c, x - 1, yb - trunkh, x + 1, yb), "#6b4a2e", { noline = true })
  part(c, c:ellipse(x, yb - trunkh - r + 2, r, r), col or "#3f8a42", { shade = true })
end
local function hills(c, g, a, b)
  c:fill(c:ellipse(18, g + 2, 34, 11), a or "#5e8a44"); c:fill(c:ellipse(60, g + 3, 30, 9), b or "#4e8a3c")
end
local function stone(c, x0, y0, x1, y1, col) part(c, R(c, x0, y0, x1, y1), col or "#a8aeb4"); fl(c, R(c, x0 + 1, y0, x1 - 1, y0), "#c9c5bc") end
local function spark(c, x, y, a, b)
  c:px(x, y, a or "#fff1c8"); c:px(x - 1, y, b or "#f5cf6a"); c:px(x + 1, y, b or "#f5cf6a"); c:px(x, y - 1, b or "#f5cf6a"); c:px(x, y + 1, b or "#f5cf6a")
end

-- 1. seven stones: team throw at a pile of flat stones
function S.r_csa_seven_stones()
  seed = 61
  local c = new()
  day(c, 34, { cloud = 50 })
  round_tree(c, 30, 35, 5, 7); round_tree(c, 46, 34, 4, 6, "#4e9a48")
  for i = 0, 2 do stone(c, 28 + i * 8, 45, 34 + i * 8, 47, i == 1 and "#8b8f96" or "#a8aeb4") end
  stone(c, 32, 42, 38, 44, "#9a9ea6"); stone(c, 40, 42, 46, 44, "#a8aeb4")
  stone(c, 36, 39, 42, 41, "#b4b8be"); stone(c, 37, 36, 41, 38, "#8b8f96")
  gnome(c, 13, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 8 }, { 7, 15 }, true) } })
  part(c, c:ellipse(23, 26, 2, 2), "#dd3a2a"); c:px(22, 25, "#f4a090")
  for _, p in ipairs({ { 18, 24 }, { 15, 22 } }) do c:px(p[1], p[2], "#f4eee0") end
  gnome(c, 60, 47, { d = -1, hat = "#4f9a45", eyes = "happy", arms = { arm({ -4, 8 }, { -8, 14 }, false), arm({ 4, 8 }, { 8, 14 }, true) } })
  spark(c, 51, 30); spark(c, 29, 31)
  finish(c, "r_csa_seven_stones")
end

-- 2. apricot stones: two travellers flicking dried stones across a crate outside the inn
function S.r_csa_apricot_stones()
  seed = 62
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#e8d8b4")
  for x = 0, W, 8 do fl(c, R(c, x, 0, x, 40), "#d8c69c") end
  fl(c, R(c, 0, 8, W - 1, 9), "#8a5a35")
  c:fill(R(c, 0, 41, W - 1, H - 1), "#c9a96e")
  fl(c, R(c, 0, 41, W - 1, 41), "#b8965c")
  part(c, R(c, 28, 11, 44, 27), "#8a5a35")
  c:fill(R(c, 30, 13, 42, 25), "#a8d4e0"); c:fill(R(c, 30, 20, 42, 25), "#6a8a60")
  c:fill(c:poly({ { 36, 17 }, { 41, 22 }, { 31, 22 } }), "#f4f8fa"); fl(c, R(c, 36, 13, 36, 25), "#8a5a35"); fl(c, R(c, 30, 19, 42, 19), "#8a5a35")
  part(c, R(c, 5, 14, 6, 22), "#3d2a1c", { noline = true }); part(c, R(c, 4, 22, 7, 27), "#ffd86a"); c:fill(R(c, 5, 23, 6, 25), "#fff1c8")
  -- crate table
  part(c, R(c, 24, 36, 48, 47), "#b07a45")
  fl(c, R(c, 24, 36, 48, 37), "#d9a660"); fl(c, R(c, 36, 38, 36, 46), "#8a4f2a"); fl(c, R(c, 25, 41, 47, 41), "#8a4f2a")
  for _, x in ipairs({ 28, 31, 40, 44 }) do part(c, c:ellipse(x, 35, 1, 1), "#e8a85a", { noline = true }); c:px(x, 35, "#c8802a") end
  part(c, c:ellipse(34, 30, 2, 1), "#e8a85a"); c:px(33, 30, "#c8802a")
  c:px(31, 32, "#f4eee0"); c:px(32, 31, "#f4eee0"); c:px(29, 33, "#f4eee0")
  part(c, R(c, 10, 41, 18, 44), "#8a5a35"); part(c, R(c, 54, 41, 62, 44), "#8a5a35")
  gnome(c, 14, 42, { d = 1, sit = true, eyes = "open", arms = { arm({ 4, 6 }, { 9, 8 }, true) } })
  gnome(c, 58, 42, { d = -1, sit = true, hat = "#e8a317", eyes = "happy", arms = { arm({ 4, 6 }, { 8, 12 }, true) } })
  finish(c, "r_csa_apricot_stones")
end

-- 3. jackfruit: knuckle-thump on a ripe jackfruit hanging straight off the trunk
function S.r_csa_jackfruit_thump()
  seed = 63
  local c = new()
  day(c, 35, { cloud = 14 })
  part(c, R(c, 52, 8, 60, 44), "#6b4a2e")
  fl(c, R(c, 55, 12, 55, 42), "#4a2c1a")
  part(c, c:ellipse(56, 10, 17, 8), "#3f8a42", { shade = true })
  c:fill(c:ellipse(52, 7, 4, 1), "#7ab55c"); c:fill(c:ellipse(62, 9, 3, 1), "#7ab55c")
  local function jf(x, y, col)
    part(c, c:ellipse(x, y, 4, 5), col, { shade = true })
    for _, p in ipairs({ { -1, -2 }, { 1, 0 }, { -2, 1 }, { 1, 3 }, { 0, -4 } }) do c:px(x + p[1], y + p[2], "#6a7a2a") end
  end
  jf(48, 34, "#b8c050"); jf(64, 22, "#8aa040"); jf(48, 20, "#8aa040"); jf(64, 38, "#8aa040")
  gnome(c, 30, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 7 }, { 9, 11 }, true) } })
  for i = 0, 1 do fl(c, R(c, 42 - i * 2, 28 + i * 3, 42 - i * 2, 30 + i * 3), "#f4eee0") end
  c:px(40, 31, "#f4eee0"); c:px(39, 27, "#f4eee0")
  for _, p in ipairs({ { 20, 44 }, { 40, 47 }, { 12, 46 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#9cc070") end
  finish(c, "r_csa_jackfruit_thump")
end

-- 4. lotus pods: delta pond, gnome on a jetty shaking a dry lotus pod by his ear
function S.r_csa_lotus_pods()
  seed = 64
  local c = new()
  day(c, 27, { cloud = 44, sky = { "#c8e4d8", "#d8ecd8", "#e8f0d8" } })
  c:fill(R(c, 0, 28, W - 1, H - 1), "#4a9aa0")
  for y = 31, 47, 4 do fl(c, R(c, 8 + (y % 8) * 3, y, 14 + (y % 8) * 3, y), "#7cc4c4"); fl(c, R(c, 40 + (y % 6) * 3, y + 1, 48 + (y % 6) * 3, y + 1), "#7cc4c4") end
  for _, p in ipairs({ { 34, 44 }, { 52, 40 }, { 62, 46 }, { 28, 34 } }) do c:fill(c:ellipse(p[1], p[2], 5, 2), "#4e8a3c"); c:fill(c:ellipse(p[1], p[2] - 1, 3, 1), "#7ab55c") end
  c:fill(c:ellipse(52, 39, 2, 1), "#e46a9b"); c:px(52, 38, "#f6b8cf")
  local function pod(x, y, nod)
    part(c, R(c, x, y + 2, x, 40), "#4e7a3a", { noline = true })
    part(c, c:ellipse(x, y, 4, 2), "#8a9a44")
    for _, dx in ipairs({ -2, 0, 2 }) do c:px(x + dx, y, "#3d4a1a") end
  end
  pod(40, 22); pod(56, 18); pod(65, 28)
  -- jetty
  part(c, R(c, 5, 38, 28, 41), "#a8703e")
  fl(c, R(c, 6, 38, 27, 38), "#c08a52")
  part(c, R(c, 8, 42, 10, 49), "#6b4a2e", { noline = true }); part(c, R(c, 22, 42, 24, 49), "#6b4a2e", { noline = true })
  gnome(c, 16, 37, { d = 1, eyes = "happy", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 8 }, { 8, 18 }, true) } })
  local px_, py_ = 24, 19
  part(c, R(c, px_ - 1, py_ + 2, px_ - 1, 35), "#4e7a3a", { noline = true })
  part(c, c:ellipse(px_ + 1, py_, 4, 2), "#8a9a44")
  for _, dx in ipairs({ -1, 1, 3 }) do c:px(px_ + dx, py_, "#3d4a1a") end
  for _, p in ipairs({ { 28, 15 }, { 31, 19 }, { 29, 23 } }) do c:px(p[1], p[2], "#f4eee0"); c:px(p[1] + 1, p[2], "#f4eee0") end
  c:px(23, 24, "#c8b060"); c:px(25, 26, "#c8b060")
  finish(c, "r_csa_lotus_pods")
end

-- 5. tea hide: a giggling hat pops over one of the round tea bushes
function S.r_csa_tea_hide()
  seed = 65
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 22), { "#c4dce0", "#d4e4e0", "#e4ece0" }, { dir = "v" })
  c:fill(c:poly({ { 0, 22 }, { 14, 8 }, { 30, 22 } }), "#8aa0a8"); c:fill(c:poly({ { 24, 22 }, { 46, 6 }, { 70, 22 } }), "#9ab0b4")
  c:fill(R(c, 0, 18, W - 1, 22), "#dce8e4")
  c:fill(R(c, 0, 22, W - 1, H - 1), "#6a9a4a")
  for y = 26, 36, 10 do for x = 4, 70, 9 do c:fill(c:ellipse(x + (y % 20) / 2, y, 5, 3), "#4e8a3c"); c:fill(c:ellipse(x + (y % 20) / 2, y - 1, 3, 1), "#7ab55c") end end
  fl(c, R(c, 0, 30, W - 1, 30), "#8ab060")
  -- child hides: hat above bush 4
  local function bush(x, y) part(c, c:ellipse(x, y, 7, 5), "#3f8a42", { shade = true }); c:fill(c:ellipse(x - 1, y - 2, 4, 1), "#7ab55c"); c:px(x + 3, y, "#e8f0d8"); c:px(x - 3, y + 1, "#e8f0d8") end
  bush(14, 44)
  gnome(c, 46, 40, { d = -1, s = 0.7, upper = true, eyes = "happy", arms = { arm({ 4, 8 }, { 6, 14 }, true), arm({ -4, 8 }, { -6, 14 }, false) } })
  bush(46, 46); bush(30, 45); bush(62, 45)
  gnome(c, 13, 38, { d = 1, upper = true, eyes = "open", arms = { arm({ 4, 7 }, { 9, 6 }, true) } })
  bush(14, 46); 
  c:px(52, 25, "#f4eee0"); c:px(54, 27, "#f4eee0"); c:px(55, 24, "#f5cf6a")
  finish(c, "r_csa_tea_hide")
end

-- 6. banyan swing: big gnome pushes a small one on a rope swing
function S.r_csa_banyan_swing()
  seed = 66
  local c = new()
  day(c, 36, { cloud = 12 })
  part(c, R(c, 4, 10, 13, 45), "#6b4a2e")
  fl(c, R(c, 8, 14, 8, 44), "#4a2c1a")
  part(c, c:ellipse(40, 9, 36, 7), "#3f8a42", { shade = true })
  c:fill(c:ellipse(30, 6, 6, 1), "#7ab55c"); c:fill(c:ellipse(50, 7, 5, 1), "#7ab55c")
  part(c, R(c, 10, 14, 66, 16), "#7a5a3a")
  for _, x in ipairs({ 22, 62, 66 }) do part(c, R(c, x, 16, x, 33 + (x % 5)), "#6b4a2e", { noline = true }) end
  c:fill(c:line({ { 45, 17 }, { 50, 36 } }, 1), "#e0c88a"); c:fill(c:line({ { 52, 17 }, { 57, 36 } }, 1), "#e0c88a")
  part(c, R(c, 47, 36, 58, 37), "#b07a45")
  gnome(c, 53, 36, { d = 1, s = 0.7, sit = true, eyes = "happy", arms = { arm({ 3, 9 }, { 4, 17 }, true) } })
  gnome(c, 36, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 12 }, true) } })
  for _, p in ipairs({ { 62, 28 }, { 24, 40 }, { 66, 44 } }) do c:px(p[1], p[2], "#f4eee0"); c:px(p[1], p[2] - 1, "#e8a317") end
  spark(c, 60, 22)
  finish(c, "r_csa_banyan_swing")
end

-- 7. butter tea: churning in a tall wooden tube at a snowed-in inn
function S.r_csa_butter_tea()
  seed = 67
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 44), "#8a5a35")
  for x = 3, W, 6 do fl(c, R(c, x, 0, x, 44), "#6b3b2a") end
  c:fill(R(c, 0, 45, W - 1, H - 1), "#5e3f28"); fl(c, R(c, 0, 45, W - 1, 45), "#3d2a1c")
  -- window with falling snow and drifts
  part(c, R(c, 8, 9, 26, 27), "#d9bc84")
  c:fill(R(c, 10, 11, 24, 25), "#b8cfe0"); c:fill(R(c, 10, 21, 24, 25), "#f4f8fa"); c:fill(c:ellipse(17, 25, 7, 3), "#f4f8fa")
  fl(c, R(c, 17, 11, 17, 25), "#d9bc84"); fl(c, R(c, 10, 18, 24, 18), "#d9bc84")
  for _, p in ipairs({ { 12, 13 }, { 20, 14 }, { 14, 21 }, { 22, 20 }, { 19, 12 } }) do c:px(p[1], p[2], "#fbfdfe") end
  -- shelf with kettle and cups
  part(c, R(c, 52, 18, 68, 19), "#b07a45")
  part(c, R(c, 55, 11, 62, 17), "#aeb4bc", { shade = true }); fl(c, R(c, 56, 10, 61, 10), "#6b3b2a"); part(c, R(c, 62, 12, 65, 13), "#aeb4bc")
  c:px(58, 7, "#f4f8fa"); c:px(59, 5, "#f4f8fa"); c:px(58, 9, "#f4f8fa")
  part(c, R(c, 66, 15, 67, 17), "#d9a660")
  -- stove glow
  part(c, R(c, 52, 34, 66, 47), "#6b6f78", { shade = true }); c:fill(R(c, 55, 38, 63, 44), "#e0501f"); c:fill(R(c, 57, 41, 61, 44), "#ffd86a")
  -- churn
  part(c, R(c, 36, 32, 46, 47), "#b07a45")
  for _, y in ipairs({ 35, 44 }) do fl(c, R(c, 36, y, 46, y), "#6b3b2a") end
  fl(c, R(c, 37, 32, 45, 32), "#d9a660")
  part(c, R(c, 40, 22, 42, 32), "#d9a660", { noline = true })
  part(c, R(c, 38, 20, 44, 22), "#8a5a35")
  c:px(36, 28, "#f5cf6a"); c:px(47, 30, "#f5cf6a"); c:px(35, 31, "#fff1c8"); c:px(48, 33, "#fff1c8")
  gnome(c, 24, 47, { d = 1, s = 1.25, eyes = "open", arms = { arm({ 4, 8 }, { 8, 15 }, true), arm({ -4, 8 }, { -3, 14 }, false, true) } })
  part(c, R(c, 3, 40, 12, 47), "#c0442e"); fl(c, R(c, 3, 40, 12, 40), "#8e2e1e")
  finish(c, "r_csa_butter_tea")
end

-- 8. caravan tales: telling a tall tale under the caravanserai arches, a camel listening
function S.r_csa_caravan_tales()
  seed = 68
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 40), { "#f0c888", "#f4d49a", "#f8e0b0" }, { dir = "v" })
  c:fill(R(c, 0, 8, W - 1, 40), "#d9b878")
  for y = 12, 36, 6 do for x = (y % 12 == 0) and 0 or 4, W, 8 do fl(c, R(c, x, y, x + 5, y), "#c8a468") end end
  fl(c, R(c, 0, 8, W - 1, 9), "#e8cc90")
  for _, ax in ipairs({ 12, 36, 60 }) do
    local m = c:mask(); m:add(R(c, ax - 6, 22, ax + 6, 40)); m:add(c:ellipse(ax, 22, 7, 8))
    c:fill(m, "#b88a50"); c:fill(c:ellipse(ax, 22, 5, 6), "#a87a44")
  end
  c:fill(R(c, 0, 41, W - 1, H - 1), "#e0bc7a"); fl(c, R(c, 0, 41, W - 1, 41), "#c8a468")
  for _, p in ipairs({ { 6, 46 }, { 22, 48 }, { 50, 47 }, { 66, 45 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2]), "#c8a468") end
  -- camel (right), listening
  local cx = 49
  part(c, c:ellipse(cx, 36, 8, 4), "#8a5a35", { shade = true })
  part(c, c:ellipse(cx - 3, 31, 2, 3), "#8a5a35"); part(c, c:ellipse(cx + 3, 31, 2, 3), "#8a5a35")
  for _, dx in ipairs({ -6, -3, 3, 6 }) do part(c, R(c, cx + dx - 1, 38, cx + dx, 47), "#6b4a2e", { noline = true }) end
  part(c, R(c, cx + 7, 24, cx + 9, 35), "#8a5a35", { noline = true })
  part(c, c:ellipse(cx + 11, 23, 4, 2), "#8a5a35"); c:px(cx + 12, 22, "#f4eee0")
  fl(c, R(c, cx + 8, 22, cx + 9, 23), "#6b4a2e")
  part(c, R(c, cx - 1, 33, cx + 1, 35), "#e8a317", { noline = true }); fl(c, R(c, cx - 8, 34, cx + 8, 34), "#c0442e")
  gnome(c, 22, 47, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -9, 14 }, false), arm({ 4, 8 }, { 9, 12 }, true) } })
  -- tale bubble with a counting bell
  part(c, c:rrect(30, 10, 46, 22, 3), "#f4eee0")
  c:fill(c:poly({ { 33, 22 }, { 37, 22 }, { 34, 26 } }), "#f4eee0")
  c:fill(c:ellipse(38, 17, 3, 3), "#e8a317"); c:fill(R(c, 35, 19, 41, 19), "#e8a317"); c:px(38, 21, "#8a5a1a"); c:px(37, 13, "#e8a317"); c:px(38, 13, "#e8a317"); c:px(37, 16, "#fff1c8")
  c:px(43, 14, "#e8a317"); c:px(44, 16, "#e8a317"); c:px(33, 14, "#e8a317")
  finish(c, "r_csa_caravan_tales")
end

-- 9. moth temple: low lamp, a tiger moth, and the keeper reading in a hush (night)
function S.r_csa_moth_temple()
  seed = 69
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 44), "#2a3a3a")
  for y = 10, 40, 8 do for x = (y % 16 == 10) and 0 or 5, W, 10 do fl(c, R(c, x, y, x + 7, y), "#34484a") end end
  -- high window with jungle night
  c:fill(c:ellipse(53, 18, 7, 8), "#1a2848"); c:fill(R(c, 46, 18, 60, 30), "#1a2848")
  c:outline(c:ellipse(53, 18, 7, 8):add(R(c, 46, 18, 60, 30)))
  c:px(50, 14, "#f4eee0"); c:px(56, 18, "#f4eee0"); c:px(52, 22, "#f4eee0"); c:px(57, 12, "#f4eee0")
  c:fill(c:ellipse(48, 30, 4, 2), "#26503a"); c:fill(c:ellipse(58, 30, 4, 2), "#2f6a46")
  c:fill(R(c, 0, 45, W - 1, H - 1), "#4a4a48"); fl(c, R(c, 0, 45, W - 1, 45), "#6a6a66")
  -- jungle leaves in the corners
  for _, p in ipairs({ { 6, 5 }, { 11, 6 }, { 16, 5 }, { 64, 5 }, { 59, 6 } }) do part(c, c:ellipse(p[1], p[2], 4, 2), "#3f8a42", { shade = true }) end
  fl(c, R(c, 8, 7, 8, 14), "#3f8a42"); fl(c, R(c, 62, 7, 62, 12), "#3f8a42")
  -- lamp on pedestal, glow
  c:fill(c:ellipse(36, 38, 12, 8), "#4a5a50")
  part(c, R(c, 32, 40, 40, 47), "#8b8f96", { shade = true })
  part(c, R(c, 32, 37, 40, 40), "#aeb4bc")
  part(c, c:ellipse(36, 34, 3, 3), "#ffd86a"); c:fill(c:ellipse(36, 34, 1, 2), "#fff1c8")
  c:px(36, 30, "#f5cf6a"); c:px(36, 29, "#e8a317")
  -- the Tiger Moth
  local mx, my = 36, 21
  local function wing(sd)
    local m = c:mask(); m:add(c:ellipse(mx + sd * 7, my - 2, 7, 4)); m:add(c:ellipse(mx + sd * 5, my + 3, 4, 3))
    part(c, m, "#e8a317", { shade = true })
    for i = 0, 2 do fl(c, c:line({ { mx + sd * (3 + i * 3), my - 5 }, { mx + sd * (3 + i * 3), my + 1 } }, 1), "#2a1a10") end
    c:px(mx + sd * 10, my - 2, "#fff1c8"); c:px(mx + sd * 7, my + 4, "#fff1c8")
  end
  wing(-1); wing(1)
  part(c, c:ellipse(mx, my, 1, 4), "#d8d0b8"); c:px(mx - 1, my - 5, "#2a1a10"); c:px(mx + 1, my - 5, "#2a1a10")
  fl(c, R(c, mx - 1, my - 7, mx - 1, my - 6), "#d8d0b8"); fl(c, R(c, mx + 1, my - 7, mx + 1, my - 6), "#d8d0b8")
  -- keeper on a mat, book in lap
  part(c, R(c, 6, 44, 22, 46), "#8e2e1e"); fl(c, R(c, 7, 45, 21, 45), "#c0442e")
  local _, G = gnome(c, 14, 44, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 7 }, { 7, 3 }, true, true) } })
  local bx, by = G.P(5, 3)
  part(c, R(c, bx - 1, by - 3, bx + 5, by + 1), "#f4eee0"); fl(c, R(c, bx + 2, by - 3, bx + 2, by + 1), "#8a5a35"); fl(c, R(c, bx - 1, by - 3, bx + 5, by - 3), "#dd3a2a")
  fl(c, R(c, bx, by - 1, bx + 1, by), "#f0c8a0")
  spark(c, 24, 28, "#ffd86a", "#c08a52"); spark(c, 48, 36, "#ffd86a", "#c08a52")
  finish(c, "r_csa_moth_temple")
end

-- 10. ledge tales: blanket-wrapped by the beacon fire while snow hisses on the stones
function S.r_csa_ledge_tales()
  seed = 70
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#8ea4bd", "#9db1c6", "#adbfd1", "#bccbda" }, { dir = "v" })
  c:fill(c:poly({ { 0, 30 }, { 12, 14 }, { 26, 30 } }), "#d3deea"); c:fill(c:poly({ { 20, 30 }, { 44, 10 }, { 70, 30 } }), "#c4d2e0")
  c:fill(c:poly({ { 44, 10 }, { 49, 16 }, { 40, 16 } }), "#f4f8fa"); c:fill(c:poly({ { 12, 14 }, { 16, 20 }, { 9, 20 } }), "#f4f8fa")
  c:fill(R(c, 0, 30, W - 1, 37), "#e6edf3")
  part(c, R(c, 5, 38, 68, 49), "#8b8f96", { shade = true })
  for y = 41, 46, 5 do fl(c, R(c, 6, y, 67, y), "#6a6e76") end
  for x = 10, 66, 9 do fl(c, R(c, x, 38, x, 49), "#6a6e76") end
  fl(c, R(c, 5, 38, 68, 39), "#f4f8fa")
  part(c, R(c, 53, 33, 67, 37), "#3d2a1c"); fl(c, R(c, 60, 37, 60, 40), "#3d2a1c")
  part(c, c:poly({ { 60, 18 }, { 66, 28 }, { 67, 33 }, { 53, 33 }, { 54, 28 } }), "#e0501f")
  c:fill(c:poly({ { 60, 23 }, { 63, 29 }, { 64, 33 }, { 56, 33 }, { 57, 29 } }), "#f08a24"); c:fill(c:ellipse(60, 31, 2, 3), "#ffd86a")
  c:px(54, 18, "#f08a24"); c:px(67, 21, "#ffd86a"); c:px(57, 14, "#f08a24")
  gnome(c, 44, 47, { d = -1, hat = "#4f9a45", eyes = "open", arms = { arm({ 4, 8 }, { 8, 13 }, true) } })
  local _, G = gnome(c, 22, 46, { d = 1, s = 1.25, sit = true, eyes = "shut", arms = {} })
  local m = R(c, 15, 37, 29, 45)
  m:del(15, 37); m:del(29, 37)
  part(c, m, "#c0442e")
  for x = 17, 28, 3 do fl(c, R(c, x, 38, x, 44), "#f5cf6a") end
  fl(c, R(c, 15, 37, 29, 37), "#e8a317")
  seed = 71
  for i = 1, 26 do c:px(6 + floor(rand() * 62), 6 + floor(rand() * 36), "#fbfdfe") end
  finish(c, "r_csa_ledge_tales")
end

-- 11. cloud pool: head-high in a hot pool above a sea of clouds, flannel on the hat
function S.r_csa_cloud_pool()
  seed = 72
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#6aa8d8", "#82bce0", "#a0cee8", "#c0e0f0" }, { dir = "v" })
  c:fill(c:poly({ { 40, 28 }, { 54, 14 }, { 70, 28 } }), "#a8b4c8"); c:fill(c:poly({ { 54, 14 }, { 57, 18 }, { 51, 18 } }), "#f4f8fa")
  for _, p in ipairs({ { 12, 28, 12 }, { 30, 30, 14 }, { 50, 29, 12 }, { 66, 30, 12 } }) do c:fill(c:ellipse(p[1], p[2], p[3], 5), "#f4f8fa") end
  c:fill(R(c, 0, 32, W - 1, 36), "#e4eef4")
  for _, p in ipairs({ { 6, 34 }, { 24, 36 }, { 44, 35 }, { 62, 36 } }) do c:fill(c:ellipse(p[1], p[2], 8, 3), "#f4f8fa") end
  c:fill(c:ellipse(18, 18, 7, 2), "#f4f8fa"); c:fill(c:ellipse(25, 16, 4, 1), "#f4f8fa")
  -- rock ledge and pool
  c:fill(R(c, 0, 37, W - 1, H - 1), "#7a6a5a")
  part(c, c:ellipse(36, 44, 34, 10), "#8a7a6a", { shade = true })
  part(c, R(c, 5, 44, 68, 49), "#7a6a5a", { noline = true })
  c:fill(c:ellipse(36, 43, 28, 7), "#58c4c4"); c:fill(c:ellipse(36, 43, 28, 7):clip(R(c, 0, 36, W, 40)), "#7cd4d0")
  local _, G = gnome(c, 36, 46, { s = 1.5, eyes = "shut" })
  local flan = R(c, 33, G.tipy + 5, 38, G.tipy + 6); fl(c, flan, "#f4eee0")
  c:fill(c:ellipse(36, 43, 28, 7):clip(R(c, 0, 42, W, 60)), "#58c4c4")
  for x = 10, 62 do if (x % 3) ~= 1 then c:px(x, 42, "#a8ecea") end end
  c:fill(R(c, 16, 45, 24, 45), "#7cd4d0"); c:fill(R(c, 48, 46, 56, 46), "#7cd4d0")
  for _, st in ipairs({ { 10, 47 }, { 60, 47 }, { 20, 48 }, { 52, 48 } }) do part(c, c:ellipse(st[1], st[2], 3, 2), "#a89a88", { shade = true }) end
  for _, p in ipairs({ { 14, 38 }, { 56, 38 }, { 20, 34 }, { 52, 33 } }) do for i = 0, 2 do fl(c, R(c, p[1] + (i % 2), p[2] - i * 2, p[1] + (i % 2) + 1, p[2] - i * 2 + 1), "#f4f8fa") end end
  finish(c, "r_csa_cloud_pool")
end

-- 12. terrace sluice: lift a mud-gate and the spring water drops to the next paddy
function S.r_ea_terrace_sluice()
  seed = 73
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 20), { "#a8d4e0", "#c4e0e0", "#d8ecdc" }, { dir = "v" })
  c:fill(c:ellipse(10, 22, 20, 8), "#7a9a7a"); c:fill(c:ellipse(60, 21, 22, 7), "#6a8a6a")
  c:fill(R(c, 0, 21, W - 1, H - 1), "#6a9a4a")
  local function paddy(x0, x1, y0, y1)
    c:fill(R(c, x0, y0, x1, y1), "#9ccfd8"); fl(c, R(c, x0 + 2, y0 + 1, x0 + 6, y0 + 1), "#d8f0f4")
    for x = x0 + 3, x1 - 2, 5 do c:px(x, y0 + 2, "#4e8a3c"); c:px(x, y0 + 1, "#7ab55c") end
    c:fill(R(c, x0, y1 + 1, x1, y1 + 4), "#8a6a46"); fl(c, R(c, x0, y1 + 1, x1, y1 + 1), "#a8845a")
  end
  paddy(5, 68, 22, 24)   -- top
  paddy(34, 68, 31, 33)  -- middle (path at left)
  paddy(5, 68, 41, 43)   -- bottom
  c:fill(R(c, 5, 31, 33, 34), "#8ab060"); c:fill(R(c, 5, 35, 33, 38), "#8a6a46")
  -- gate and cascade
  c:fill(R(c, 29, 22, 33, 24), "#9ccfd8")
  part(c, R(c, 28, 17, 29, 26), "#a8703e", { noline = true }); part(c, R(c, 33, 17, 34, 26), "#a8703e", { noline = true })
  part(c, R(c, 28, 17, 34, 18), "#a8703e")
  part(c, R(c, 29, 19, 33, 20), "#d9a660")
  c:fill(R(c, 30, 25, 32, 31), "#6ab4d8"); fl(c, R(c, 31, 26, 31, 30), "#d8f0f4")
  c:fill(R(c, 29, 32, 33, 34), "#9ccfd8"); c:px(28, 31, "#d8f0f4"); c:px(34, 30, "#d8f0f4")
  gnome(c, 20, 36, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 8, 14 }, true), arm({ -4, 7 }, { -5, 4 }, false) } })
  fl(c, R(c, 10, 28, 12, 28), "#f5cf6a"); fl(c, R(c, 56, 18, 58, 18), "#f5cf6a")
  for _, p in ipairs({ { 12, 48 }, { 30, 48 }, { 48, 47 }, { 62, 47 } }) do c:px(p[1], p[2], "#4e8a3c"); c:px(p[1] + 1, p[2] - 1, "#4e8a3c") end
  finish(c, "r_ea_terrace_sluice")
end

local function duck(c, x, y, d)
  local rows = { "....ww..", "....wkyy", "wwwwww..", ".wwwwg..", "..gggg.." }
  local out = {}
  for i, r in ipairs(rows) do out[i] = (d < 0) and r:reverse() or r end
  c:paint(out, x - 4, y - 2, { w = "#fbf6ea", k = INK, y = "#e8801a", g = "#b8b4a4" })
end

-- 13. duck herding: the ducks love the puddle, the gnome whistles from the rice
function S.r_ea_duck_paddy()
  seed = 74
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 18), { "#a8d4e0", "#c4e0e0", "#d8ecdc" }, { dir = "v" })
  c:fill(c:ellipse(14, 20, 22, 7), "#7a9a7a"); c:fill(c:ellipse(58, 20, 22, 6), "#6a8a6a")
  c:fill(R(c, 0, 19, W - 1, H - 1), "#78b8c8")
  for y = 22, 48, 5 do
    for x = 4 + (y % 4) * 2, 70, 5 do c:px(x, y, "#4e8a3c"); c:px(x, y - 1, "#7ab55c"); c:px(x + 1, y - 1, "#7ab55c") end
    fl(c, R(c, 8 + (y % 7) * 4, y + 2, 14 + (y % 7) * 4, y + 2), "#b8e0e8")
  end
  -- the favourite puddle
  c:fill(c:ellipse(46, 40, 14, 6), "#8a7a52"); c:fill(c:ellipse(46, 40, 12, 5), "#7a98a0")
  c:fill(R(c, 40, 39, 46, 39), "#b8d8dc")
  duck(c, 40, 38, 1); duck(c, 52, 40, -1); duck(c, 44, 44, 1)
  -- a tidy line heading back into the rice
  duck(c, 16, 29, 1); duck(c, 26, 28, 1); duck(c, 36, 27, 1); duck(c, 60, 28, -1)
  gnome(c, 14, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 14 }, true), arm({ -4, 8 }, { -8, 12 }, false) } })
  c:px(26, 38, "#f5cf6a"); c:px(27, 37, "#f5cf6a"); c:px(28, 36, "#f5cf6a"); c:px(24, 40, "#f5cf6a")
  fl(c, R(c, 25, 33, 25, 36), "#f5cf6a"); fl(c, R(c, 25, 33, 27, 33), "#f5cf6a")
  finish(c, "r_ea_duck_paddy")
end

-- 14. bamboo talk: wind in the grove, the gnome cups an ear to the knocking stems
function S.r_ea_bamboo_talk()
  seed = 75
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 40), { "#c4dcc8", "#d4e4cc", "#e0ecd4" }, { dir = "v" })
  c:fill(R(c, 0, 41, W - 1, H - 1), "#6a9a4a"); fl(c, R(c, 0, 41, W - 1, 41), "#8ab060")
  local function stalk(x0, x1, w, col, node)
    c:fill(c:line({ { x0, 49 }, { x1, 3 } }, w), col)
    for k = 1, 5 do
      local t = k / 6
      local nx = floor(x0 + (x1 - x0) * t + 0.5)
      fl(c, R(c, nx - 1, 49 - floor(46 * t), nx + w - 1, 49 - floor(46 * t)), node)
    end
    for k = 1, 3 do
      local t = 0.3 + k * 0.17
      local nx, ny = floor(x0 + (x1 - x0) * t + 0.5), 49 - floor(46 * t)
      fl(c, c:ellipse(nx + 3, ny - 1, 3, 1), "#7ab55c")
    end
  end
  stalk(8, 14, 2, "#8cc060", "#4e8a3c"); stalk(18, 26, 2, "#6aa84a", "#3f7a38"); stalk(50, 56, 2, "#6aa84a", "#3f7a38")
  stalk(58, 66, 2, "#8cc060", "#4e8a3c"); stalk(44, 48, 2, "#8cc060", "#4e8a3c"); stalk(64, 69, 3, "#6aa84a", "#3f7a38")
  gnome(c, 34, 47, { d = 1, s = 1.25, eyes = "shut", arms = { arm({ -4, 8 }, { -5, 4 }, false), arm({ 4, 9 }, { 5, 16 }, true) } })
  -- the stems knock: short strokes either side
  for _, p in ipairs({ { 42, 26 }, { 40, 32 }, { 44, 33 }, { 26, 22 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 2), "#f4eee0") end
  for _, p in ipairs({ { 12, 16 }, { 56, 14 }, { 20, 36 } }) do fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#f4f8fa"); c:px(p[1] + 6, p[2] + 1, "#f4f8fa") end
  finish(c, "r_ea_bamboo_talk")
end

-- 15. pearl dive: down on the cove bed with an oyster held up, a boat far above
function S.r_ea_pearl_dive()
  seed = 76
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 11), { "#a8d4e0", "#c4e0e8" }, { dir = "v" })
  c:bands(R(c, 0, 12, W - 1, 49), { "#58b4c4", "#4a9ab4", "#3a80a4", "#2f6a94", "#285a84" }, { dir = "v" })
  for x = 5, 68, 4 do fl(c, R(c, x, 12, x + 2, 12), "#d8f0f4") end
  -- boat hull at the top, rope drops to a basket
  part(c, c:poly({ { 40, 5 }, { 64, 5 }, { 60, 12 }, { 44, 12 } }), "#8a5a35")
  fl(c, R(c, 41, 6, 63, 6), "#b07a45")
  fl(c, R(c, 52, 13, 52, 40), "#e0c88a")
  c:fill(R(c, 5, 44, 68, 49), "#d9bc84"); c:fill(c:ellipse(36, 44, 34, 2), "#e0c88a")
  c:fill(c:ellipse(10, 46, 9, 4), "#8b8f96"); c:fill(c:ellipse(64, 47, 8, 3), "#8b8f96")
  c:fill(c:ellipse(10, 44, 4, 1), "#aeb4bc")
  part(c, R(c, 48, 40, 56, 44), "#c8924e"); fl(c, R(c, 48, 41, 56, 41), "#e0b878"); fl(c, R(c, 51, 40, 51, 44), "#a8703e"); fl(c, R(c, 54, 40, 54, 44), "#a8703e")
  local function weed(x, h) for i = 0, h do c:px(x + ((i % 2 == 0) and 0 or 1), 44 - i, "#4e8a3c") end end
  weed(20, 7); weed(23, 5); weed(63, 6)
  gnome(c, 32, 44, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -6, 12 }, false), arm({ 4, 8 }, { 9, 14 }, true) } })
  -- oyster held up with its pearl
  part(c, c:ellipse(43, 28, 3, 2), "#9a9488"); fl(c, R(c, 41, 28, 45, 28), "#4a4440"); part(c, c:ellipse(43, 25, 3, 2), "#b8b0a0")
  c:px(43, 27, "#fbfdfe"); c:px(43, 26, "#f4eee0")
  spark(c, 48, 24, "#fbfdfe", "#d8f0f4")
  for _, p in ipairs({ { 30, 20 }, { 33, 16 }, { 29, 12 }, { 36, 22 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#a8e0f0", { noline = true }); c:px(p[1], p[2], "#e8f8fc") end
  finish(c, "r_ea_pearl_dive")
end

-- 16. long wall: climbing the crenellated wall as it runs over the ridge to the next watchtower
function S.r_ea_long_wall()
  seed = 77
  local c = new()
  day(c, 30, { sky = { "#b8d4e0", "#cde0e4", "#e0ece4" }, cloud = 52, hill = "#8aa0a8", hill2 = "#9ab0b0", grass = "#7a9a5a", edge = "#8ab060" })
  c:fill(c:ellipse(10, 30, 20, 8), "#6a8a68"); c:fill(c:ellipse(64, 26, 24, 8), "#5a7a58")
  c:fill(R(c, 0, 30, W - 1, H - 1), "#6a8a50")
  -- watchtower at the top of the ridge
  part(c, R(c, 52, 10, 66, 28), "#a8aeb4"); fl(c, R(c, 53, 10, 65, 10), "#c9c5bc")
  for x = 52, 64, 4 do part(c, R(c, x, 7, x + 2, 10), "#a8aeb4") end
  c:fill(R(c, 57, 15, 60, 20), "#3d3a38"); fl(c, R(c, 52, 22, 66, 22), "#8b8f96")
  part(c, R(c, 58, 2, 58, 7), "#3d2a1c", { noline = true }); fl(c, R(c, 59, 3, 62, 4), "#dd3a2a")
  -- the wall climbing from lower left
  local wall = c:poly({ { 0, 40 }, { 52, 24 }, { 72, 24 }, { 72, 56 }, { 0, 56 } })
  part(c, wall, "#b4ae9c")
  for y = 30, 48, 4 do fl(c, R(c, 5, y, 68, y), "#9a9484") end
  for x = 8, 68, 8 do for y = 28, 48, 8 do fl(c, R(c, x + ((y / 4) % 2) * 4, y, x + ((y / 4) % 2) * 4, y + 3), "#9a9484") end end
  c:fill(c:line({ { 5, 38 }, { 52, 24 } }, 1), "#d8d2be")
  for i = 0, 7 do local x = 8 + i * 6; local y = 37 - floor((x - 5) * 14 / 47); part(c, R(c, x, y - 3, x + 2, y), "#b4ae9c") end
  gnome(c, 30, 31, { d = 1, walk = 1, eyes = "open", arms = { arm({ -4, 7 }, { -6, 3 }, false), arm({ 4, 7 }, { 6, 4 }, true) } })
  finish(c, "r_ea_long_wall")
end

-- 17. typhoon shutters: sliding the bar across banging shutters in a storm
function S.r_ea_typhoon_shutters()
  seed = 78
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 14), { "#3a4658", "#465468", "#566478" }, { dir = "v" })
  c:fill(R(c, 0, 15, W - 1, H - 1), "#7a8a98")
  for x = 3, W, 6 do fl(c, R(c, x, 15, x, 49), "#6a7a88") end
  part(c, R(c, 0, 12, W - 1, 15), "#5e3f28", { noline = true })
  c:fill(R(c, 0, 5, W - 1, 11), "#6a4a38"); for x = 0, W, 5 do fl(c, R(c, x, 5, x, 11), "#4a2c1a") end
  c:fill(R(c, 0, 44, W - 1, H - 1), "#4a4a46"); fl(c, R(c, 0, 44, W - 1, 44), "#6a6a66")
  -- window and two shutters
  c:fill(R(c, 28, 17, 60, 42), "#2a3040")
  local function shutter(x0, x1)
    part(c, R(c, x0, 17, x1, 42), "#a8703e")
    for x = x0 + 3, x1 - 1, 4 do fl(c, R(c, x, 18, x, 41), "#8a5a35") end
    fl(c, R(c, x0, 22, x1, 22), "#6b3b2a"); fl(c, R(c, x0, 37, x1, 37), "#6b3b2a")
  end
  shutter(28, 43); shutter(45, 60)
  -- bar sliding into place
  part(c, R(c, 22, 28, 54, 31), "#d9a660"); fl(c, R(c, 22, 28, 54, 28), "#e8c48a")
  part(c, R(c, 56, 27, 62, 32), "#5e3f28")
  c:px(35, 26, "#f4eee0")
  gnome(c, 14, 47, { d = 1, s = 1.25, eyes = "open", arms = { arm({ 4, 8 }, { 8, 14 }, true), arm({ -4, 8 }, { -5, 4 }, false) } })
  -- rain and flying leaves
  seed = 80
  for i = 1, 34 do local x, y = 6 + floor(rand() * 62), 6 + floor(rand() * 40); c:px(x, y, "#c4d8e8"); c:px(x - 1, y + 1, "#c4d8e8") end
  for _, p in ipairs({ { 20, 20 }, { 10, 34 }, { 64, 20 } }) do c:px(p[1], p[2], "#e8a317"); c:px(p[1] + 1, p[2], "#c8802a"); c:px(p[1] + 2, p[2] - 1, "#e8a317") end
  fl(c, R(c, 8, 20, 12, 20), "#f4f8fa"); fl(c, R(c, 62, 36, 67, 36), "#f4f8fa")
  finish(c, "r_ea_typhoon_shutters")
end

-- 18. moon rabbit: the clear autumn moon with a rabbit pounding in a bowl
function S.r_ea_moon_rabbit()
  seed = 79
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 36), { "#1a2448", "#243058", "#2e3c68", "#3a4878" }, { dir = "v" })
  c:fill(c:ellipse(45, 17, 12, 12), "#f5e6a8"); c:fill(c:ellipse(45, 17, 10, 10), "#f8edb8")
  c:paint({ ".....aa.aa.........",
            ".....aa.aa....mmmm.",
            ".....aa.aa....mmmm.",
            "......aaaa....mmmm.",
            "......aaaaa...mmmm.",
            ".....aaakaaa..h....",
            "....aaaaaaaaaah....",
            "...aaaaaaaaa..h....",
            "...aaaaaaaaa..h....",
            "...aaaaaaaa.bbbbbb.",
            "....aaaaaa..bbbbbb.",
            "....aa..aa...bbbb.." }, 36, 11, { a = "#b09440", k = "#6a5a30", m = "#8a7440", h = "#8a7440", b = "#8a7440" })
  seed = 81
  for i = 1, 14 do c:px(6 + floor(rand() * 62), 6 + floor(rand() * 20), "#f4eee0") end
  c:fill(c:ellipse(16, 36, 30, 9), "#243258"); c:fill(c:ellipse(62, 37, 28, 8), "#283860")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#2c4a40"); fl(c, R(c, 0, 36, W - 1, 36), "#3a5a4a")
  -- watchtower silhouette
  part(c, R(c, 58, 22, 66, 40), "#2a2c48"); for x = 58, 64, 4 do part(c, R(c, x, 19, x + 2, 22), "#2a2c48") end
  c:fill(R(c, 61, 27, 63, 31), "#f5cf6a")
  -- maple tree, autumn
  part(c, R(c, 8, 28, 10, 47), "#4a2c1a", { noline = true })
  part(c, c:ellipse(9, 24, 9, 7), "#b8501f", { shade = true }); c:fill(c:ellipse(6, 22, 3, 2), "#e8801a")
  gnome(c, 30, 47, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -6, 4 }, false), arm({ 4, 9 }, { 8, 19 }, true) } })
  for _, p in ipairs({ { 22, 14 }, { 20, 30 }, { 50, 36 }, { 56, 46 }, { 40, 40 } }) do c:px(p[1], p[2], "#e8801a"); c:px(p[1] + 1, p[2], "#c8502a") end
  finish(c, "r_ea_moon_rabbit")
end

-- 19. gobi well: the camel knows; the gnome heaves the flat stone off the water
function S.r_ea_gobi_well()
  seed = 82
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#f0e0a0", "#f4e8b0", "#f8f0c8" }, { dir = "v" })
  c:fill(c:ellipse(56, 12, 7, 7), "#fff4c0"); c:fill(c:ellipse(56, 12, 5, 5), "#ffe890")
  c:fill(c:ellipse(14, 33, 30, 9), "#e8c47c"); c:fill(c:ellipse(60, 34, 30, 8), "#dcb26a")
  c:fill(R(c, 0, 33, W - 1, H - 1), "#e8c47c"); c:fill(R(c, 0, 33, W - 1, 33), "#f0d490")
  for _, p in ipairs({ { 8, 42 }, { 20, 47 }, { 52, 48 }, { 64, 44 }, { 30, 38 } }) do c:fill(R(c, p[1], p[2], p[1] + 4, p[2]), "#d4a85c") end
  -- distant cairn
  part(c, R(c, 4, 29, 9, 33), "#8b8f96"); part(c, R(c, 5, 26, 8, 29), "#a8aeb4"); part(c, R(c, 6, 24, 7, 26), "#8b8f96")
  -- the hidden well: dark hole and water
  c:fill(c:ellipse(40, 45, 10, 3), "#6a4a2e"); c:fill(c:ellipse(40, 45, 8, 2), "#58b4d8"); fl(c, R(c, 36, 45, 40, 45), "#d8f0f8")
  -- flat stone tilted up
  part(c, c:poly({ { 26, 44 }, { 32, 36 }, { 36, 38 }, { 31, 46 } }), "#a8aeb4"); fl(c, R(c, 32, 37, 34, 37), "#c9c5bc")
  gnome(c, 16, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 5 }, true), arm({ -4, 8 }, { -3, 4 }, false) } })
  -- camel facing left with its nose to the water
  local cx = 54
  part(c, c:ellipse(cx, 36, 8, 4), "#a8703e", { shade = true })
  part(c, c:ellipse(cx - 1, 31, 2, 3), "#a8703e"); part(c, c:ellipse(cx + 3, 31, 2, 3), "#a8703e")
  for _, dx in ipairs({ -6, -3, 3, 6 }) do part(c, R(c, cx + dx - 1, 38, cx + dx, 46), "#8a5a35", { noline = true }) end
  c:fill(c:line({ { cx - 6, 34 }, { cx - 10, 38 }, { cx - 12, 42 } }, 3), "#a8703e")
  part(c, c:ellipse(cx - 13, 44, 3, 2), "#a8703e"); c:px(cx - 14, 43, INK)
  fl(c, R(c, cx - 8, 34, cx + 8, 34), "#4f9a45")
  -- heat shimmer
  for _, p in ipairs({ { 8, 22 }, { 40, 20 }, { 30, 27 } }) do fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#fff8d8"); c:px(p[1] + 6, p[2] - 1, "#fff8d8") end
  spark(c, 38, 41, "#fbfdfe", "#d8f0f8")
  finish(c, "r_ea_gobi_well")
end

-- 20. snow monkeys: a shuffle-up in the steaming pool, snow on every head
function S.r_ea_snow_monkeys()
  seed = 83
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#8ea4bd", "#9db1c6", "#adbfd1", "#bccbda" }, { dir = "v" })
  c:fill(c:ellipse(16, 33, 30, 11), "#d3deea"); c:fill(c:ellipse(62, 32, 28, 9), "#dae4ee")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#e6edf3")
  pine(c, 9, 34, 17, true); pine(c, 62, 33, 15, true)
  part(c, c:ellipse(36, 40, 31, 11), "#8b8f96", { shade = true })
  c:fill(c:ellipse(36, 40, 27, 8), "#58b4c4")
  local function monkey(x, y, s)
    part(c, c:ellipse(x, y, 5, 5), "#a89484", { shade = true })
    c:fill(c:ellipse(x, y + 1, 3, 3), "#e0604a")
    c:px(x - 2, y, "#4a2c1a"); c:px(x + 1, y, "#4a2c1a"); fl(c, R(c, x - 2, y - 1, x - 1, y - 1), "#7a5e50"); fl(c, R(c, x + 1, y - 1, x + 2, y - 1), "#7a5e50")
    c:px(x - 1, y + 3, "#8a3a2a"); c:px(x, y + 3, "#8a3a2a")
    c:fill(c:ellipse(x, y - 5, 4, 1), "#f4f8fa"); c:fill(R(c, x - 3, y - 5, x + 3, y - 5), "#f4f8fa")
  end
  monkey(34, 40, 1); monkey(46, 41, 1); monkey(58, 39, 1)
  local _, G = gnome(c, 18, 45, { s = 1.2, eyes = "shut" })
  G.hat:each(function(x, y) if y <= G.tipy + 2 then c:px(x, y, "#f4f8fa") end end)
  c:fill(c:ellipse(36, 40, 27, 8):clip(R(c, 0, 42, W, 60)), "#58b4c4")
  c:fill(c:ellipse(36, 40, 27, 8):clip(R(c, 0, 41, W, 41)), "#7cd4d4")
  for x = 12 + 1, 60 do if (x % 3) == 0 then c:px(x, 43, "#a8ecea") end end
  for _, st in ipairs({ { 8, 46 }, { 28, 50 }, { 40, 50 }, { 52, 50 }, { 64, 46 } }) do part(c, c:ellipse(st[1], st[2], 3, 2), "#9a9ea6", { shade = true }) end
  for _, p in ipairs({ { 12, 33 }, { 62, 31 } }) do for i = 0, 3 do fl(c, R(c, p[1] + (i % 2), p[2] - i * 2, p[1] + (i % 2) + 1, p[2] - i * 2 + 1), "#f4f8fa") end end
  seed = 84
  for i = 1, 28 do c:px(6 + floor(rand() * 62), 6 + floor(rand() * 40), "#fbfdfe") end
  finish(c, "r_ea_snow_monkeys")
end

-- 21. whisk tea: a green froth in a wide bowl, the host watching every flick
function S.r_ea_whisk_tea()
  seed = 85
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#efe6cc")
  for x = 0, W, 12 do fl(c, R(c, x, 0, x, 38), "#8a5a35") end
  for y = 6, 32, 13 do fl(c, R(c, 0, y, W - 1, y), "#c9b48a") end
  -- open window with cherry blossoms
  c:fill(R(c, 22, 8, 50, 30), "#c8e0ec"); c:fill(R(c, 22, 24, 50, 30), "#8ab060")
  part(c, R(c, 21, 7, 51, 8), "#8a5a35", { noline = true }); part(c, R(c, 21, 30, 51, 31), "#8a5a35", { noline = true })
  c:fill(c:line({ { 22, 20 }, { 34, 15 }, { 48, 18 } }, 1), "#6b4a2e")
  for _, p in ipairs({ { 26, 17 }, { 30, 14 }, { 36, 13 }, { 41, 17 }, { 46, 15 }, { 33, 18 }, { 24, 21 } }) do c:fill(c:ellipse(p[1], p[2], 2, 2), "#f4a8c4"); c:px(p[1], p[2], "#fbd8e4") end
  c:fill(R(c, 0, 39, W - 1, H - 1), "#b8b070")
  for x = 0, W, 18 do fl(c, R(c, x, 39, x, 49), "#8a8450") end
  fl(c, R(c, 0, 39, W - 1, 39), "#8a8450")
  -- low table
  part(c, R(c, 24, 39, 48, 42), "#8a5a35"); fl(c, R(c, 25, 39, 47, 39), "#a8703e")
  part(c, R(c, 26, 43, 28, 47), "#6b3b2a", { noline = true }); part(c, R(c, 44, 43, 46, 47), "#6b3b2a", { noline = true })
  -- bowl and froth
  part(c, c:rrect(30, 33, 42, 39, 2), "#3f6a8a"); fl(c, R(c, 31, 36, 41, 36), "#e8ecf0")
  c:fill(R(c, 31, 33, 41, 34), "#8fc462"); c:fill(R(c, 33, 32, 39, 33), "#a8d870"); c:px(35, 31, "#a8d870"); c:px(37, 31, "#a8d870")
  -- whisk
  c:fill(c:line({ { 36, 33 }, { 30, 26 } }, 1), "#e8c48a"); part(c, R(c, 34, 33, 38, 34), "#e8c48a", { noline = true })
  for _, p in ipairs({ { 38, 28 }, { 41, 30 }, { 40, 25 } }) do c:px(p[1], p[2], "#f4eee0"); c:px(p[1] + 1, p[2] - 1, "#f4eee0") end
  gnome(c, 18, 45, { d = 1, sit = true, eyes = "open", arms = { arm({ 4, 7 }, { 9, 11 }, true), arm({ 3, 5 }, { 7, 4 }, true) } })
  gnome(c, 58, 45, { d = -1, sit = true, hat = "#6a4a8a", eyes = "open", arms = { arm({ 4, 6 }, { 1, 8 }, true), arm({ 3, 8 }, { 0, 6 }, true) } })
  finish(c, "r_ea_whisk_tea")
end

-- 22. kimchi: red paste rubbed between every salted leaf, crocks stacked behind
function S.r_ea_kimchi()
  seed = 86
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#c9a96e")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 40), "#b8965c") end
  c:fill(R(c, 0, 41, W - 1, H - 1), "#a88a5a"); fl(c, R(c, 0, 41, W - 1, 41), "#8a6a46")
  local function crock(x, y, w, h)
    part(c, c:ellipse(x, y, w, h), "#9a5a35", { shade = true })
    part(c, R(c, x - floor(w * 0.6), y - h - 1, x + floor(w * 0.6), y - h + 1), "#7a4a2a")
    c:fill(c:ellipse(x - 1, y - 1, 2, 2), "#b8704a")
  end
  crock(10, 38, 6, 7); crock(22, 40, 5, 6); crock(8, 29, 5, 5)
  c:fill(R(c, 54, 40, 54, 40), "#a88a5a")
  -- cabbage heap on the right
  local function cab(x, y) part(c, c:ellipse(x, y, 4, 3), "#e8f0c0", { shade = true }); fl(c, R(c, x - 2, y, x + 2, y), "#8ab060"); c:px(x, y - 2, "#f8fce0") end
  cab(58, 44); cab(65, 45); cab(61, 40); cab(53, 46)
  -- gnome behind the tub, arms in
  gnome(c, 36, 40, { d = 1, s = 1.2, upper = true, eyes = "open", arms = { arm({ -4, 7 }, { -6, 0 }, true), arm({ 4, 7 }, { 6, 0 }, true) } })
  part(c, c:ellipse(36, 44, 17, 6), "#a8703e", { shade = true })
  c:fill(c:ellipse(36, 43, 14, 4), "#dd3a2a"); c:fill(c:ellipse(36, 44, 8, 2), "#e0502a")
  for _, p in ipairs({ { 28, 42 }, { 40, 44 }, { 44, 42 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#e8f0c0") end
  fl(c, R(c, 24, 43, 26, 43), "#c0301f")
  part(c, c:ellipse(22, 46, 1, 1), "#dd3a2a", { noline = true })
  c:px(50, 38, "#dd3a2a"); c:px(20, 33, "#f5cf6a")
  finish(c, "r_ea_kimchi")
end

-- 23. daikon pickle: slicing coins into the brine jar, a stone to weigh them down
function S.r_ea_daikon_pickle()
  seed = 87
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#d8cfb4")
  for y = 3, 36, 6 do fl(c, R(c, 0, y, W - 1, y), "#c4b898") end
  c:fill(R(c, 0, 39, W - 1, H - 1), "#8a5a35"); for y = 43, 52, 5 do fl(c, R(c, 0, y, W - 1, y), "#6b3b2a") end
  -- shelf of jars
  part(c, R(c, 5, 16, 30, 17), "#6b3b2a")
  for _, x in ipairs({ 10, 18, 26 }) do part(c, R(c, x - 2, 9, x + 2, 15), "#b8e0e8"); c:fill(R(c, x - 1, 12, x + 1, 14), "#f4eee0"); fl(c, R(c, x - 2, 8, x + 2, 8), "#8a5a35") end
  -- counter
  part(c, R(c, 24, 38, 56, 47), "#b07a45"); fl(c, R(c, 24, 38, 56, 39), "#d9a660")
  fl(c, R(c, 40, 41, 40, 46), "#8a4f2a")
  -- whole daikon and slices
  part(c, c:ellipse(37, 36, 7, 2), "#f4f8f4"); fl(c, R(c, 40, 36, 44, 36), "#e8f0e0"); c:fill(R(c, 28, 36, 30, 36), "#4e8a3c"); fl(c, R(c, 26, 34, 29, 35), "#4e8a3c")
  for _, x in ipairs({ 46, 49 }) do part(c, c:ellipse(x, 37, 1, 1), "#f4f8f4") end
  -- knife slicing down
  part(c, c:poly({ { 36, 30 }, { 47, 30 }, { 47, 35 }, { 36, 33 } }), "#d8dce0"); fl(c, R(c, 37, 30, 46, 30), "#f4f8fa")
  part(c, R(c, 30, 30, 36, 32), "#5e3f28")
  -- jar with brine and weight
  part(c, R(c, 56, 24, 66, 38), "#b8e0e8"); c:fill(R(c, 57, 30, 65, 37), "#9ccfd8")
  for _, p in ipairs({ { 59, 33 }, { 62, 34 }, { 60, 36 }, { 63, 31 } }) do c:fill(c:ellipse(p[1], p[2], 1, 1), "#f4f8f4") end
  part(c, R(c, 58, 20, 64, 24), "#8b8f96", { shade = true })
  gnome(c, 20, 47, { d = 1, s = 1.15, eyes = "open", arms = { arm({ 4, 9 }, { 8, 11 }, true), arm({ -4, 7 }, { -5, 4 }, false) } })
  c:px(52, 33, "#f4f8f4"); c:px(53, 31, "#f4f8f4")
  finish(c, "r_ea_daikon_pickle")
end

-- 24. bok choy fried rice: a high toss over a roaring flame
function S.r_ea_bokchoy_rice()
  seed = 88
  local c = new()
  day(c, 34, { cloud = false, sky = { "#c8dce0", "#d8e6e0", "#e6ece0" }, hill = "#5e8a44", hill2 = "#4e8a3c" })
  part(c, R(c, 56, 18, 58, 37), "#6b4a2e", { noline = true }); part(c, c:ellipse(57, 15, 9, 7), "#3f8a42", { shade = true })
  -- stone stove and flame
  for _, p in ipairs({ { 36, 47 }, { 44, 48 }, { 52, 47 } }) do part(c, c:ellipse(p[1], p[2], 4, 2), "#8b8f96", { shade = true }) end
  part(c, c:poly({ { 43, 36 }, { 49, 41 }, { 51, 46 }, { 35, 46 }, { 37, 41 } }), "#e0501f")
  c:fill(c:poly({ { 43, 40 }, { 46, 43 }, { 47, 46 }, { 39, 46 }, { 40, 43 } }), "#f08a24"); c:fill(c:ellipse(43, 44, 2, 2), "#ffd86a")
  c:px(34, 38, "#f08a24"); c:px(52, 37, "#ffd86a")
  -- the wok, tilted, with a long handle to the gnome's hand
  local _, G = gnome(c, 20, 47, { d = 1, s = 1.25, eyes = "open", arms = { arm({ 4, 8 }, { 8, 12 }, true), arm({ -4, 8 }, { -5, 4 }, false) } })
  local hx, hy = G.P(8, 12)
  c:fill(c:line({ { hx + 1, hy }, { 36, 34 } }, 2), "#5e3f28")
  part(c, c:poly({ { 35, 30 }, { 52, 30 }, { 49, 37 }, { 38, 37 } }), "#4a4e58")
  fl(c, R(c, 37, 30, 50, 30), "#8b929c")
  -- the toss: rice, a bok choy leaf, an egg
  for _, p in ipairs({ { 38, 22 }, { 42, 18 }, { 46, 24 }, { 50, 20 }, { 44, 14 }, { 40, 26 }, { 49, 27 }, { 36, 16 } }) do c:px(p[1], p[2], "#fbf6ea"); c:px(p[1] + 1, p[2], "#fbf6ea") end
  part(c, c:ellipse(44, 21, 3, 2), "#4f9a45"); fl(c, R(c, 42, 21, 46, 21), "#e8f0c0")
  part(c, c:ellipse(52, 14, 2, 2), "#f4eee0"); c:px(52, 14, "#f5cf6a")
  part(c, c:ellipse(37, 11, 2, 1), "#4f9a45")
  finish(c, "r_ea_bokchoy_rice")
end

local order = {}
for l in io.lines("/tmp/claude-0/-home-user-gnome-venture/1b9189c1-3b2f-55fd-a82b-d2ac35c1c228/scratchpad/lists/h16.txt") do if l ~= "" then order[#order + 1] = l end end
for _, s2 in ipairs(order) do
  if S[s2] and (not only or only == s2) then seed = 7; S[s2]() end
end
