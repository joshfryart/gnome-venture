-- variety-act-h4.lua : Do-tab scenes for 24 regional rest-stop activities (cb_*, sa_*) -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-h4.lua   (params BEFORE --script)
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


---------------------------------------------------------------- shared scene bits
local S = {}
local TS = { "#7fcbe0", "#9bd8e6", "#b8e4ea" }
local function tsky(c, g, cl, pal)
  c:bands(R(c, 0, 0, W - 1, g), pal or TS, { dir = "v" })
  if cl then c:fill(c:ellipse(cl, 10, 8, 2), "#f4eee0"); c:fill(c:ellipse(cl + 4, 8, 5, 2), "#f4eee0") end
end
local function sandfill(c, g, col, edge)
  c:fill(R(c, 0, g, W - 1, H - 1), col or "#e8d29a")
  c:fill(R(c, 0, g, W - 1, g), edge or "#f2e2b0")
  for i = 1, 16 do
    local x, y = floor(rand() * 64) + 4, g + 2 + floor(rand() * (H - g - 3))
    c:px(x, y, "#d4bb80"); c:px(x + 1, y, "#d4bb80")
  end
end
local function sea(c, y0, y1, col, hi)
  c:fill(R(c, 0, y0, W - 1, y1), col or "#3fa6b8")
  c:fill(R(c, 0, y0, W - 1, y0), hi or "#7ad0d4")
  for y = y0 + 3, y1 - 1, 4 do
    for x = (y % 8 == 0) and 4 or 10, W - 4, 14 do c:fill(R(c, x, y, x + 3, y), "#58b9c4") end
  end
end
local function foam(c, y, x0, x1)
  for x = x0, x1, 5 do c:fill(R(c, x, y, x + 2, y), "#f4fbf8"); c:fill(R(c, x + 2, y + 1, x + 4, y + 1), "#d8f0ee") end
end
local function palm(c, x, yb, h, lean)
  local tx, ty = x + lean, yb - h
  part(c, c:line({ { x, yb }, { x + rnd(lean * 0.3), yb - rnd(h * 0.5) }, { tx, ty } }, 2), "#8a5a35", { noline = true })
  local m = c:mask()
  for _, f in ipairs({ { -9, 2 }, { -6, -2 }, { -2, -4 }, { 3, -4 }, { 7, -2 }, { 9, 2 } }) do
    m:add(c:line({ { tx, ty }, { tx + f[1], ty + f[2] }, { tx + rnd(f[1] * 1.3), ty + f[2] + 3 } }, 2))
  end
  part(c, m, "#3f8a42")
  fl(c, R(c, tx - 1, ty + 1, tx, ty + 2), "#6b3b2a")
end
local function note(c, x, y, col)
  fl(c, R(c, x, y + 4, x + 1, y + 5), col); fl(c, R(c, x + 1, y, x + 1, y + 4), col); fl(c, R(c, x + 2, y, x + 3, y + 1), col)
end
local function rain(c, n, x0, y0, x1, y1, col)
  for i = 1, n do
    local x, y = x0 + floor(rand() * (x1 - x0)), y0 + floor(rand() * (y1 - y0))
    c:px(x, y, col or "#dbe8ee"); c:px(x - 1, y + 1, col or "#dbe8ee")
  end
end
local function lime(c, x, y, col) part(c, c:ellipse(x, y, 2, 2), col or "#7cc043"); c:px(x - 1, y - 1, "#c8e890") end

---------------------------------------------------------------- scenes (cb = Coralteeth / Sunsprinkle isles, sa = South America)
-- 1. push mangrove pods into the crumbling mud bank
function S.r_cb_mangrove_seedlings()
  local c = new()
  tsky(c, 24, 50)
  c:fill(c:ellipse(12, 26, 22, 6), "#2f6a3a"); c:fill(c:ellipse(52, 25, 26, 5), "#3a7a40")
  c:fill(R(c, 0, 25, W - 1, 36), "#6ab0a0")
  for x = 6, 64, 9 do c:fill(R(c, x, 30, x + 3, 30), "#8cc8b8") end
  -- stilt roots of a big mangrove at left
  for _, sx in ipairs({ -6, -2, 3, 7 }) do part(c, c:line({ { 12 + sx // 2, 17 }, { 12 + sx, 30 }, { 12 + sx * 2, 37 } }, 1), "#6b3b2a", { noline = true }) end
  part(c, c:ellipse(12, 15, 11, 6), "#3f8a42", { shade = true })
  -- floating pods
  for _, p in ipairs({ { 30, 29 }, { 38, 33 }, { 52, 28 }, { 62, 32 }, { 22, 34 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#7ab55c"); c:px(p[1] + 4, p[2], "#6b4a2e") end
  -- mud bank
  c:fill(R(c, 0, 37, W - 1, H - 1), "#7a5a3c"); c:fill(R(c, 0, 37, W - 1, 38), "#9a7a52")
  for i = 1, 22 do local x, y = floor(rand() * 62) + 5, 40 + floor(rand() * 9); c:px(x, y, "#5e4228"); c:px(x + 1, y, "#8e6b48") end
  -- planted row
  for i, x in ipairs({ 40, 48, 56, 64 }) do
    local h = (i == 1) and 5 or 7
    part(c, R(c, x, 46 - h, x + 1, 46), "#7ab55c")
    fl(c, R(c, x, 46, x + 1, 47), "#5e4228")
    fl(c, R(c, x - 2, 46 - h - 1, x - 1, 46 - h), "#4e9a48"); fl(c, R(c, x + 2, 46 - h - 2, x + 3, 46 - h - 1), "#4e9a48")
  end
  local _, G = gnome(c, 26, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 7 }, { 9, 4 }, true, true) } })
  local hx, hy = G.P(9, 4)
  c:fill(c:ellipse(hx + 2, 47, 3, 1), "#4a3220")
  part(c, R(c, hx + 1, hy - 5, hx + 2, hy + 2), "#7ab55c"); fl(c, R(c, hx + 1, hy - 5, hx + 2, hy - 5), "#6b4a2e")
  fl(c, R(c, hx - 1, hy - 2, hx, hy), "#f0c8a0")
  fl(c, R(c, hx, hy - 7, hx + 1, hy - 6), "#4e9a48"); fl(c, R(c, hx + 3, hy - 7, hx + 4, hy - 6), "#4e9a48")
  finish(c, "r_cb_mangrove_seedlings")
end

-- 2. turning nutmegs with red mace lace on a drying rack in the spice shed
function S.r_cb_nutmeg_racks()
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#b8965c")
  for x = 3, W - 1, 6 do fl(c, R(c, x, 12, x, 40), "#9a7a48") end
  fl(c, R(c, 0, 5, W - 1, 12), "#8a5a35"); for x = 5, W - 1, 4 do fl(c, R(c, x, 12, x + 1, 14), "#c9a96e") end
  fl(c, R(c, 0, 12, W - 1, 12), "#5e3f28")
  -- open window to palms
  part(c, R(c, 46, 17, 64, 33), "#9bd8e6")
  c:fill(R(c, 46, 27, 64, 33), "#3fa6b8")
  palm(c, 56, 33, 9, 3)
  part(c, R(c, 44, 16, 45, 34), "#6b4a2e", { noline = true }); part(c, R(c, 65, 16, 66, 34), "#6b4a2e", { noline = true })
  -- sacks on the left
  part(c, c:rrect(7, 30, 18, 41, 3), "#d8c08a"); fl(c, R(c, 10, 30, 15, 31), "#8a5a35")
  c:fill(c:ellipse(12, 35, 3, 1), "#b8965c")
  c:fill(R(c, 0, 41, W - 1, H - 1), "#6b4a2e"); for y = 45, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#5e3f28") end
  gnome(c, 32, 46, { d = 1, upper = true, eyes = "open", arms = { arm({ 4, 7 }, { 9, 8 }, true, true) } })
  -- slatted rack
  part(c, R(c, 4, 40, 67, 44), "#a8703e")
  for x = 8, 66, 5 do fl(c, R(c, x, 41, x, 44), "#6b3b2a") end
  fl(c, R(c, 5, 40, 66, 40), "#d9a660")
  part(c, R(c, 6, 45, 8, 49), "#8a5a35", { noline = true }); part(c, R(c, 62, 45, 64, 49), "#8a5a35", { noline = true })
  local function nut(x, y, lace)
    part(c, c:ellipse(x, y, 2, 1), "#8a5a35"); c:px(x - 1, y - 1, "#b07a45")
    if lace then fl(c, R(c, x - 1, y - 2, x + 1, y - 2), "#d02a2a"); c:px(x + 2, y - 1, "#d02a2a") end
  end
  for i, x in ipairs({ 8, 14, 20, 26, 38, 46, 52, 58, 64 }) do nut(x, 39, i % 3 == 0) end
  for _, x in ipairs({ 11, 55 }) do fl(c, R(c, x, 38, x + 3, 38), "#d02a2a"); c:px(x + 1, 37, "#d02a2a") end
  -- held nutmeg with lace
  part(c, c:ellipse(46, 36, 2, 2), "#8a5a35"); fl(c, R(c, 44, 34, 48, 34), "#d02a2a"); c:px(48, 35, "#d02a2a")
  finish(c, "r_cb_nutmeg_racks")
end

-- 3. weaving a palm-frond roof: half thatched, half open sky
function S.r_cb_frond_thatch()
  local c = new()
  tsky(c, 36, 12, { "#6f90a0", "#88a8b4", "#a8c4c8" })
  c:fill(c:ellipse(8, 9, 9, 3), "#566a78"); c:fill(c:ellipse(14, 7, 6, 3), "#566a78")
  c:fill(R(c, 0, 37, W - 1, H - 1), "#e0cc90"); c:fill(R(c, 0, 37, W - 1, 37), "#eeddb0")
  -- hut
  part(c, R(c, 32, 30, 66, 48), "#b8965c")
  for x = 35, 64, 5 do fl(c, R(c, x, 31, x, 48), "#9a7a48") end
  part(c, R(c, 44, 36, 52, 48), "#3d2a1c")
  -- roof: bare rafters + thatched lower rows
  local roof = c:poly({ { 49, 8 }, { 70, 30 }, { 28, 30 } })
  part(c, roof, "#9bd8e6")
  for _, p in ipairs({ { 49, 8, 38, 30 }, { 49, 8, 49, 30 }, { 49, 8, 60, 30 } }) do part(c, c:line({ { p[1], p[2] }, { p[3], p[4] } }, 1), "#6b4a2e", { noline = true }) end
  for _, y in ipairs({ 17, 21, 25 }) do c:fill(c:poly({ { 49, 8 }, { 70, 30 }, { 28, 30 } }):clip(R(c, 0, y, W, y)), "#6b4a2e") end
  local rows = { { 27, "#3f8a42" }, { 23, "#4e9a48" }, { 19, "#3f8a42" } }
  for i, r in ipairs(rows) do
    local band = c:poly({ { 49, 8 }, { 70, 30 }, { 28, 30 } }):clip(R(c, 0, r[1], W, 30))
    if i == 1 then c:fill(band, r[2]) else c:fill(band:clip(R(c, 45, 0, 80, 60)), r[2]) end
  end
  for x = 28, 66, 3 do c:px(x, 29, "#7ab55c"); c:px(x + 1, 30, "#2f6a34") end
  for x = 44, 66, 3 do c:px(x, 25, "#7ab55c"); c:px(x + 1, 26, "#2f6a34") end
  c:outline(roof)
  -- frond pile and gnome
  for i = 0, 3 do fl(c, c:line({ { 5 + i, 47 }, { 15 + i * 2, 43 - (i % 2) } }, 2), (i % 2 == 0) and "#4e9a48" or "#3f8a42") end
  local _, G = gnome(c, 22, 48, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 8 }, { 8, 15 }, true) } })
  local hx, hy = G.P(8, 15)
  part(c, c:line({ { hx, hy }, { hx + 5, hy - 9 } }, 2), "#3f8a42"); fl(c, c:line({ { hx + 1, hy - 2 }, { hx + 7, hy - 3 } }, 1), "#6fb356")
  fl(c, c:line({ { hx + 1, hy - 5 }, { hx - 3, hy - 8 } }, 1), "#6fb356")
  finish(c, "r_cb_frond_thatch")
end

-- 4. a clapping-circle game: three small gnomes and one big around a stall market
function S.r_cb_clap_circle()
  local c = new()
  tsky(c, 30, 52)
  c:fill(c:ellipse(16, 31, 30, 7), "#5e9a50"); c:fill(R(c, 0, 30, W - 1, H - 1), "#e8d29a")
  c:fill(R(c, 0, 30, W - 1, 30), "#f2e2b0")
  -- little stalls with striped awnings
  for _, st in ipairs({ { 8, 18, "#dd3a2a" }, { 50, 17, "#3f8fb0" } }) do
    local x0 = st[1]
    part(c, R(c, x0, 23, x0 + 14, 30), "#b07a45")
    for k = 0, 4 do fl(c, R(c, x0 - 1 + k * 3, st[2], x0 + 1 + k * 3, st[2] + 4), (k % 2 == 0) and st[3] or "#f4eee0") end
    c:outline(R(c, x0 - 1, st[2], x0 + 14, st[2] + 4))
  end
  c:fill(c:ellipse(36, 44, 25, 6), "#d4bb80"); c:fill(c:ellipse(36, 44, 22, 5), "#e8d29a")
  gnome(c, 13, 47, { s = 0.7, d = 1, hat = "#e8a317", eyes = "happy", arms = { arm({ 3, 6 }, { 6, 10 }, true), arm({ -3, 6 }, { 2, 10 }, true) } })
  gnome(c, 59, 47, { s = 0.7, d = -1, hat = "#4f9a45", eyes = "happy", arms = { arm({ -3, 6 }, { -6, 10 }, true), arm({ 3, 6 }, { -2, 10 }, true) } })
  gnome(c, 22, 39, { s = 0.7, d = 1, hat = "#3f8fb0", eyes = "happy", arms = { arm({ 3, 6 }, { 6, 4 }, true), arm({ -3, 6 }, { 2, 4 }, true) } })
  gnome(c, 48, 39, { s = 0.7, d = -1, hat = "#8a4fa0", eyes = "happy", arms = { arm({ -3, 6 }, { -6, 4 }, true), arm({ 3, 6 }, { -2, 4 }, true) } })
  gnome(c, 36, 48, { s = 1.2, d = 1, eyes = "happy", arms = { arm({ -4, 8 }, { -1, 18 }, true), arm({ 4, 8 }, { 3, 18 }, true) } })
  for _, p in ipairs({ { 33, 12 }, { 41, 12 }, { 47, 15 }, { 27, 15 } }) do c:px(p[1], p[2], "#fff1c8"); c:px(p[1] - 1, p[2] + 1, "#f5cf6a"); c:px(p[1] + 1, p[2] + 1, "#f5cf6a") end
  note(c, 44, 16, "#c0442e"); note(c, 20, 18, "#3f6fb0")
  finish(c, "r_cb_clap_circle")
end

-- 5. trade-wind kite duel: two paper kites, one diving at the other
function S.r_cb_kite_duel()
  local c = new()
  tsky(c, 34, nil, { "#6cb8e0", "#88cce6", "#a8dcea" })
  for _, p in ipairs({ { 10, 14, 16 }, { 40, 20, 12 } }) do fl(c, R(c, p[1], p[2], p[1] + p[3], p[2]), "#f4eee0") end
  sea(c, 30, 38)
  foam(c, 38, 4, 66)
  sandfill(c, 39)
  palm(c, 60, 45, 18, -4)
  local _, G = gnome(c, 20, 48, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 8 }, { 7, 16 }, true) } })
  local hx, hy = G.P(7, 16)
  local function kite(x, y, col, col2, tilt)
    local m = c:poly({ { x, y - 6 }, { x + 4 + tilt, y }, { x, y + 7 }, { x - 4 + tilt, y } })
    part(c, m, col)
    c:fill(c:poly({ { x, y - 6 }, { x + 4 + tilt, y }, { x, y } }), col2)
    fl(c, R(c, x, y - 5, x, y + 6), "#6b3b2a")
    local tx = x
    for i = 1, 5 do tx = tx + ((i % 2 == 0) and 1 or -1); fl(c, R(c, tx, y + 7 + i * 2, tx + 1, y + 8 + i * 2), (i % 2 == 0) and "#f5cf6a" or "#3f8fb0") end
  end
  fl(c, c:line({ { hx + 1, hy }, { 42, 17 } }, 1), "#f4eee0")
  fl(c, c:line({ { hx + 1, hy }, { 56, 14 } }, 1), "#f4eee0")
  kite(42, 15, "#dd3a2a", "#f4eee0", 1)
  kite(57, 10, "#e8a317", "#f5e6a8", -1)
  for _, w in ipairs({ { 8, 24, 6 }, { 28, 30, 5 }, { 60, 24, 5 } }) do fl(c, R(c, w[1], w[2], w[1] + w[3], w[2]), "#f4fbf8") end
  finish(c, "r_cb_kite_duel")
end

-- 6. marbles in a ring scratched in the coral sand beside the ferry steps
function S.r_cb_marble_ring()
  local c = new()
  tsky(c, 18, 52)
  sea(c, 14, 26)
  sandfill(c, 27)
  -- plank steps down to the sand
  for i = 0, 3 do part(c, R(c, 5, 18 + i * 3, 22 - i * 3, 21 + i * 3), (i % 2 == 0) and "#b07a45" or "#a8703e") end
  part(c, c:poly({ { 36, 18 }, { 68, 18 }, { 64, 25 }, { 40, 25 } }), "#6b4a2e"); fl(c, R(c, 38, 19, 66, 19), "#c0442e")
  part(c, R(c, 48, 10, 60, 17), "#c9a96e"); part(c, c:poly({ { 47, 10 }, { 54, 6 }, { 61, 10 } }), "#c0442e"); fl(c, R(c, 52, 12, 55, 17), "#3d2a1c")
  c:fill(c:ellipse(46, 41, 16, 6), "#d4bb80"); c:fill(c:ellipse(46, 41, 14, 4.5), "#ecd9a4")
  for i, m in ipairs({ { 40, 41, "#3f6fb0" }, { 46, 40, "#dd3a2a" }, { 52, 42, "#4f9a45" }, { 44, 43, "#e8a317" }, { 50, 39, "#8a4fa0" } }) do
    part(c, R(c, m[1], m[2], m[1] + 1, m[2] + 1), m[3]); c:px(m[1], m[2], "#f4f8fa")
  end
  local _, G = gnome(c, 15, 44, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 9, 4 }, true) } })
  local sx, sy = G.P(11, 4)
  part(c, c:ellipse(sx + 3, sy + 1, 1, 1), "#e8a317", { noline = true }); c:px(sx + 2, sy, "#f4f8fa")
  fl(c, R(c, sx + 6, sy + 1, sx + 9, sy + 1), "#c9b27a"); fl(c, R(c, sx + 11, sy + 1, sx + 12, sy + 1), "#c9b27a")
  finish(c, "r_cb_marble_ring")
end

-- 7. hermit-crab derby: three crabs in shells on roped lanes, cheering gnome
function S.r_cb_crab_derby()
  local c = new()
  tsky(c, 20, 40)
  sea(c, 16, 22)
  sandfill(c, 23)
  local function crab(x, y, shell, hat)
    part(c, c:ellipse(x, y, 4, 3), shell); fl(c, R(c, x - 1, y - 1, x + 1, y - 1), "#fff1c8"); c:px(x, y, "#fff1c8")
    part(c, c:ellipse(x + 5, y + 2, 3, 1), "#d4492e", { noline = true })
    fl(c, R(c, x + 8, y - 1, x + 9, y + 1), "#d4492e"); c:px(x + 9, y - 2, "#d4492e")
    c:px(x + 6, y, INK); c:px(x + 4, y + 4, "#a02a1a"); c:px(x + 7, y + 4, "#a02a1a")
  end
  for _, y in ipairs({ 26, 33, 40, 47 }) do fl(c, R(c, 24, y, 62, y), "#a8703e") end
  for _, y in ipairs({ 26, 33, 40 }) do for x = 24, 62, 8 do fl(c, R(c, x, y - 1, x, y + 1), "#6b4a2e") end end
  crab(42, 30, "#e8a0b0"); crab(32, 37, "#f5cf6a"); crab(50, 44, "#8a4fa0")
  -- finish: two poles with checked ribbon
  part(c, R(c, 62, 24, 63, 49), "#6b4a2e", { noline = true })
  for y = 25, 47, 2 do fl(c, R(c, 60, y, 61, y), (y % 4 == 1) and "#f4eee0" or "#2a1a10") end
  gnome(c, 13, 47, { d = 1, eyes = "happy", arms = { arm({ -4, 8 }, { -8, 16 }, true), arm({ 4, 8 }, { 9, 16 }, true) } })
  for _, p in ipairs({ { 20, 24 }, { 6, 28 }, { 24, 30 } }) do c:px(p[1], p[2], "#fff1c8"); c:px(p[1] + 1, p[2] + 1, "#f5cf6a") end
  finish(c, "r_cb_crab_derby")
end

-- 8. strandline treasures: gnome holds up a conch, shells on the sand and on a driftwood shelf
function S.r_cb_cay_shells()
  local c = new()
  tsky(c, 22, 14)
  sea(c, 18, 28)
  foam(c, 28, 3, 66)
  c:fill(R(c, 0, 29, W - 1, 33), "#d8c48a")
  sandfill(c, 34)
  for x = 6, 64, 7 do fl(c, R(c, x, 34 + (x % 3), x + 3, 34 + (x % 3)), "#3f6a3a") end
  local function shell(x, y, kind)
    if kind == 1 then part(c, c:ellipse(x, y, 2, 1), "#f0a890"); c:px(x + 2, y, "#fff1c8")
    elseif kind == 2 then part(c, c:ellipse(x, y, 2, 2), "#f4eee0"); c:px(x, y, "#b8a888")
    else part(c, c:poly({ { x - 2, y + 1 }, { x, y - 2 }, { x + 2, y + 1 } }), "#e8c4d8") end
  end
  for _, p in ipairs({ { 8, 40, 1 }, { 14, 46, 2 }, { 40, 40, 3 }, { 36, 47, 1 }, { 29, 43, 2 }, { 46, 36, 3 } }) do shell(p[1], p[2], p[3]) end
  -- driftwood shelf
  part(c, R(c, 50, 42, 67, 44), "#8a5a35"); part(c, R(c, 52, 45, 54, 49), "#8b8f96"); part(c, R(c, 63, 45, 65, 49), "#8b8f96")
  shell(54, 40, 1); shell(59, 40, 2); shell(64, 40, 3); shell(57, 37, 3)
  local _, G = gnome(c, 26, 48, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 8 }, { 7, 15 }, true, true) } })
  local hx, hy = G.P(7, 15)
  part(c, c:ellipse(hx + 1, hy - 3, 3, 4), "#f0a890"); c:fill(c:ellipse(hx + 1, hy - 4, 1, 2), "#fff1c8")
  fl(c, R(c, hx, hy - 9, hx + 1, hy - 7), "#f0a890"); fl(c, R(c, hx - 1, hy - 1, hx + 2, hy + 1), "#f0c8a0")
  c:px(hx + 6, hy - 7, "#fff1c8"); c:px(hx - 5, hy - 5, "#fff1c8")
  finish(c, "r_cb_cay_shells")
end

-- 9. reef fish seen through a glass-bottomed bucket from the jetty
function S.r_cb_reef_fish()
  local c = new()
  tsky(c, 31, 54)
  c:bands(R(c, 0, 32, W - 1, H - 1), { "#2f8aa8", "#287a9a", "#216a8c", "#1c5a7c" }, { dir = "v" })
  c:fill(R(c, 0, 32, W - 1, 32), "#7ad0d4")
  -- jetty
  part(c, R(c, 5, 28, 36, 31), "#b07a45"); for x = 9, 34, 5 do fl(c, R(c, x, 29, x, 31), "#6b4a2e") end
  for _, x in ipairs({ 8, 22, 33 }) do part(c, R(c, x, 31, x + 1, 44), "#6b4a2e", { noline = true }) end
  -- bright view cone
  local cone = c:poly({ { 38, 33 }, { 50, 33 }, { 58, 49 }, { 30, 49 } })
  c:fill(cone, "#58c0cc")
  c:fill(c:poly({ { 40, 33 }, { 48, 33 }, { 54, 44 }, { 34, 44 } }), "#7ad4d8")
  -- reef
  for _, k in ipairs({ { 34, "#e86a8a" }, { 44, "#f08a3a" }, { 52, "#c85ab0" } }) do
    part(c, R(c, k[1], 45, k[1] + 2, 49), k[2], { noline = true }); fl(c, R(c, k[1] - 2, 43, k[1] - 1, 45), k[2]); fl(c, R(c, k[1] + 3, 44, k[1] + 4, 46), k[2])
  end
  fl(c, R(c, 6, 46, 26, 49), "#3a6a58")
  local function fish(x, y, body, tail, d)
    part(c, c:ellipse(x, y, 3, 2), body, { noline = true })
    fl(c, R(c, x - 5 * d, y - 1, x - 4 * d, y + 1), tail); c:px(x + 2 * d, y - 1, INK)
  end
  fish(45, 39, "#2f6fd0", "#f5cf6a", 1); fish(39, 45, "#4fb86a", "#e86a8a", -1); fish(48, 35, "#f5cf6a", "#f08a3a", 1)
  fish(14, 40, "#215a80", "#215a80", 1); fish(62, 42, "#215a80", "#215a80", -1)
  -- gnome seated on the jetty end, bucket pressed to the water
  local _, G = gnome(c, 30, 28, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 7 }, { 9, 0 }, true, true) } })
  part(c, R(c, 38, 29, 49, 33), "#a8703e"); fl(c, R(c, 39, 30, 48, 30), "#d9a660")
  fl(c, R(c, 38, 33, 49, 33), "#9ae0e6")
  fl(c, R(c, 36, 29, 38, 32), "#f0c8a0")
  finish(c, "r_cb_reef_fish")
end

-- 10. dusk on Greenmist: whistling tree frogs on big leaves, gnome with a lantern
function S.r_cb_tree_frogs()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 36), { "#3b2f66", "#52407a", "#7a4a88", "#b45a7c", "#e8825e" }, { dir = "v" })
  for _, p in ipairs({ { 12, 8 }, { 30, 6 }, { 44, 9 }, { 60, 7 }, { 66, 16 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(c:ellipse(14, 36, 26, 10), "#2a3a5a"); c:fill(c:ellipse(54, 35, 26, 9), "#2f4a5a")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#2f5a3a")
  for _, p in ipairs({ { 8, 18 }, { 63, 14 } }) do part(c, R(c, p[1], p[2], p[1] + 1, 38), "#3a2a22", { noline = true }) end
  -- big leaves with frogs
  local function leaf(x, y, w, col) part(c, c:ellipse(x, y, w, 3), col, { shade = true }); fl(c, R(c, x - w + 2, y, x + w - 2, y), "#2f6a34") end
  leaf(52, 30, 12, "#4e9a48"); leaf(32, 38, 9, "#3f8a42"); leaf(63, 40, 6, "#4e9a48")
  local function frog(x, y, d)
    part(c, c:ellipse(x, y, 3, 2), "#7ad04a", { noline = true }); fl(c, R(c, x - 2, y - 3, x - 1, y - 3), "#e0302a"); fl(c, R(c, x + 1, y - 3, x + 2, y - 3), "#e0302a")
    fl(c, R(c, x - 1, y + 1, x + 1, y + 1), "#f5e6a8"); fl(c, R(c, x - 3, y + 2, x - 3 + 1, y + 2), "#f08a24"); fl(c, R(c, x + 3, y + 2, x + 4, y + 2), "#f08a24")
  end
  frog(48, 28, 1); frog(57, 28, 1); frog(33, 36, 1)
  note(c, 44, 17, "#f5e6a8"); note(c, 56, 14, "#f5e6a8"); note(c, 37, 24, "#f5e6a8")
  local _, G = gnome(c, 17, 48, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 8 }, { 8, 12 }, true) } })
  local hx, hy = G.P(8, 12)
  part(c, R(c, hx, hy - 4, hx + 4, hy), "#ffd86a"); fl(c, R(c, hx + 1, hy - 3, hx + 3, hy - 1), "#fff1c8"); fl(c, R(c, hx + 1, hy - 5, hx + 3, hy - 5), "#3d2a1c")
  for _, p in ipairs({ { hx - 3, hy - 6 }, { hx + 7, hy - 3 }, { 40, 41 }, { 26, 28 } }) do c:px(p[1], p[2], "#e8f088") end
  finish(c, "r_cb_tree_frogs")
end

-- 11. thump the ripe breadfruit: four knobbly fruits on the market table
function S.r_cb_thump_breadfruit()
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#d9c48a")
  for x = 4, W - 1, 8 do fl(c, R(c, x, 14, x, 38), "#c4ae72") end
  for k = 0, 17 do fl(c, R(c, 4 + k * 4, 5, 6 + k * 4, 13), (k % 2 == 0) and "#e07a2a" or "#f4eee0") end
  fl(c, R(c, 0, 13, W - 1, 14), "#a8703e")
  for _, x in ipairs({ 10, 18 }) do part(c, c:ellipse(x, 21, 2, 4), "#e8c84a") end
  gnome(c, 20, 49, { s = 1.25, d = 1, upper = true, eyes = "open", arms = { arm({ 4, 8 }, { 10, 14 }, true) } })
  c:fill(R(c, 0, 40, W - 1, H - 1), "#a8703e"); fl(c, R(c, 0, 40, W - 1, 41), "#d9a660")
  for y = 46, 52, 5 do fl(c, R(c, 0, y, W - 1, y), "#8a5a35") end
  fl(c, R(c, 4, 43, 67, 43), "#e07a2a")
  local function bf(x, y, col, dot) part(c, c:ellipse(x, y, 5, 5), col)
    for _, d in ipairs({ { -2, -2 }, { 1, -3 }, { 3, -1 }, { -3, 1 }, { 0, 0 }, { 2, 2 }, { -1, 3 } }) do c:px(x + d[1], y + d[2], dot) end end
  bf(36, 37, "#b8c860", "#8a9a3a"); bf(46, 37, "#7fa040", "#5e8230"); bf(56, 37, "#8cb048", "#5e8230"); bf(66, 37, "#7fa040", "#5e8230")
  -- knuckle knock marks on the ripe one
  fl(c, R(c, 38, 27, 38, 28), "#fff1c8"); fl(c, R(c, 41, 30, 41, 31), "#fff1c8"); fl(c, R(c, 36, 26, 36, 27), "#fff1c8")
  finish(c, "r_cb_thump_breadfruit")
end

-- 12. holding a conch to the ear: ledge, sea beyond, sound waves
function S.r_cb_humming_conch()
  local c = new()
  tsky(c, 28, nil, { "#7fcbe0", "#a8dcea", "#f4e8c0" })
  c:fill(c:ellipse(56, 26, 6, 6), "#f5e6a8"); c:fill(c:ellipse(56, 26, 3, 3), "#fff1c8")
  sea(c, 26, 38)
  fl(c, R(c, 8, 22, 10, 22), "#f4eee0"); fl(c, R(c, 9, 21, 9, 21), "#f4eee0")
  -- stone ledge
  part(c, R(c, 4, 38, 67, 49), "#a8aeb4", { shade = true })
  for _, y in ipairs({ 42, 46 }) do fl(c, R(c, 5, y, 66, y), "#7a8088") end
  for _, x in ipairs({ 12, 30, 48, 62 }) do fl(c, R(c, x, 38, x, 41), "#7a8088") end
  for _, x in ipairs({ 20, 40, 56 }) do fl(c, R(c, x, 42, x, 45), "#7a8088") end
  fl(c, R(c, 4, 38, 67, 38), "#c9c5bc")
  local function conch(x, y) part(c, c:ellipse(x, y, 4, 2), "#f0a890"); c:fill(c:ellipse(x - 1, y, 1, 1), "#fff1c8"); fl(c, R(c, x + 4, y - 1, x + 6, y), "#f0a890"); c:px(x - 2, y - 1, "#fff1c8") end
  conch(52, 36); conch(61, 36)
  local _, G = gnome(c, 28, 38, { s = 1, d = 1, eyes = "shut", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 7 }, { 7, 12 }, true, true) } })
  local hx, hy = G.P(6, 12)
  part(c, c:ellipse(hx + 1, hy, 2, 3), "#f0a890"); fl(c, R(c, hx + 1, hy - 5, hx + 1, hy - 3), "#f0a890"); c:px(hx, hy, "#fff1c8")
  fl(c, R(c, hx - 1, hy + 1, hx + 1, hy + 3), "#f0c8a0")
  -- sound arcs
  for i = 1, 3 do
    local r = 3 + i * 3
    for k = -2, 2 do c:px(hx + 4 + r - math.abs(k) // 2 * 1 - (k * k) // 4, hy + k * 2, "#f4fbf8") end
  end
  finish(c, "r_cb_humming_conch")
end

-- 13. choosing the juiciest lime: big gnome rolling one under his palm, punch bowl waiting
function S.r_cb_juicy_lime()
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#b8965c")
  for x = 3, W - 1, 6 do fl(c, R(c, x, 5, x, 38), "#9a7a48") end
  part(c, R(c, 8, 10, 24, 26), "#9bd8e6"); fl(c, R(c, 16, 10, 16, 26), "#6b4a2e"); fl(c, R(c, 8, 18, 24, 18), "#6b4a2e")
  c:fill(R(c, 8, 20, 24, 26), "#3fa6b8")
  part(c, R(c, 54, 8, 60, 16), "#ffd86a"); fl(c, R(c, 55, 10, 59, 14), "#fff1c8"); fl(c, R(c, 56, 5, 56, 8), "#3d2a1c")
  gnome(c, 32, 49, { s = 1.4, d = 1, upper = true, eyes = "shut", arms = { arm({ 4, 8 }, { 10, 11 }, true) } })
  c:fill(R(c, 0, 38, W - 1, H - 1), "#a8703e"); fl(c, R(c, 0, 38, W - 1, 39), "#d9a660")
  for y = 45, 52, 5 do fl(c, R(c, 0, y, W - 1, y), "#8a5a35") end
  -- punch bowl
  part(c, c:ellipse(58, 36, 9, 3), "#e8c0d0"); c:fill(c:ellipse(58, 35, 7, 2), "#e8486a")
  part(c, c:poly({ { 49, 36 }, { 67, 36 }, { 63, 42 }, { 53, 42 } }), "#e8c0d0"); c:fill(R(c, 51, 37, 65, 38), "#e8486a")
  for _, x in ipairs({ 55, 60 }) do part(c, c:ellipse(x, 34, 2, 1), "#c8e890") end
  -- limes
  lime(c, 9, 36); lime(c, 15, 36); lime(c, 21, 36)
  lime(c, 45, 36, "#9ad050")
  c:px(48, 30, "#c8e890"); c:px(49, 32, "#c8e890"); c:px(47, 28, "#c8e890")
  finish(c, "r_cb_juicy_lime")
end

-- 14. beach seine: gnomes in a line haul a long rope, net full of silver fish in the surf
function S.r_cb_seine_haul()
  local c = new()
  tsky(c, 22, 20)
  sea(c, 16, 30)
  foam(c, 30, 3, 66)
  sandfill(c, 31, "#e8d29a", "#d8c48a")
  -- floats + net with fish
  c:fill(c:ellipse(54, 28, 12, 6), "#3f8fa0")
  part(c, c:ellipse(54, 26, 11, 5), "#7a98a0")
  for x = 46, 62, 4 do fl(c, R(c, x, 22, x, 30), "#c9b27a") end
  for y = 24, 29, 3 do fl(c, R(c, 44, y, 64, y), "#c9b27a") end
  for _, p in ipairs({ { 50, 26 }, { 55, 27 }, { 60, 25 } }) do part(c, c:ellipse(p[1], p[2], 2, 1), "#dfe8ee", { noline = true }); c:px(p[1] + 1, p[2] - 1, INK) end
  for x = 44, 64, 5 do part(c, R(c, x, 21, x + 1, 22), "#e0501f", { noline = true }) end
  -- rope along the sand, gnomes pulling left
  fl(c, c:line({ { 46, 29 }, { 42, 36 }, { 36, 42 }, { 8, 43 } }, 1), "#8a5a35")
  gnome(c, 18, 48, { s = 1.2, d = -1, walk = -1, eyes = "shut", arms = { arm({ -4, 6 }, { -7, 5 }, true) } })
  gnome(c, 38, 47, { s = 1, d = -1, walk = -1, hat = "#e8a317", eyes = "shut", arms = { arm({ -4, 6 }, { -7, 5 }, true) } })
  gnome(c, 56, 47, { s = 0.8, d = -1, walk = -1, hat = "#4f9a45", eyes = "shut", arms = { arm({ -4, 6 }, { -7, 5 }, true) } })
  for _, p in ipairs({ { 28, 49 }, { 46, 49 }, { 62, 46 }, { 10, 50 } }) do c:px(p[1], p[2], "#d4bb80"); c:px(p[1] + 1, p[2], "#d4bb80") end
  finish(c, "r_cb_seine_haul")
end

-- 15. shove the flat ferry off the sandbar
function S.r_cb_sandbar_shove()
  local c = new()
  tsky(c, 20, 52)
  sea(c, 16, H - 1, "#3fa6b8", "#7ad0d4")
  c:fill(c:ellipse(40, 44, 30, 6), "#f2e2b0"); c:fill(c:ellipse(40, 44, 26, 4), "#e8d29a")
  foam(c, 40, 16, 60)
  -- flat ferry hull
  part(c, c:poly({ { 28, 29 }, { 66, 29 }, { 63, 41 }, { 31, 41 } }), "#8a5a35")
  fl(c, R(c, 29, 33, 65, 33), "#6b3b2a"); fl(c, R(c, 30, 37, 64, 37), "#6b3b2a")
  fl(c, R(c, 28, 29, 66, 29), "#d9a660")
  -- cabin and lantern
  part(c, R(c, 44, 20, 58, 28), "#c9a96e"); part(c, c:poly({ { 42, 20 }, { 51, 14 }, { 60, 20 } }), "#c0442e"); part(c, R(c, 49, 22, 53, 28), "#3d2a1c")
  part(c, R(c, 62, 22, 63, 28), "#6b4a2e", { noline = true }); fl(c, R(c, 61, 19, 64, 22), "#ffd86a")
  gnome(c, 36, 28, { s = 0.7, d = -1, upper = false, hat = "#3f6fb0", eyes = "open", arms = { arm({ -3, 6 }, { -7, 9 }, true) } })
  -- water over the gnome's legs + shoving lines
  c:fill(R(c, 5, 42, 25, 49), "#3fa6b8"); fl(c, R(c, 5, 42, 25, 42), "#7ad0d4")
  for _, x in ipairs({ 8, 16, 22 }) do fl(c, R(c, x, 45, x + 3, 45), "#58b9c4") end
  gnome(c, 14, 41, { d = 1, upper = true, eyes = "shut", arms = { arm({ 4, 8 }, { 10, 9 }, true) } })
  for _, p in ipairs({ { 27, 40 }, { 26, 36 }, { 28, 34 } }) do c:px(p[1], p[2], "#fff1c8"); c:px(p[1] + 1, p[2], "#fff1c8") end
  finish(c, "r_cb_sandbar_shove")
end

-- 16. night in the Driftwood Tavern: a single mast through the roof, a parrot, a gnome mid-yarn
function S.r_cb_tavern_yarns()
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#4a2c1a")
  for x = 2, W - 1, 6 do fl(c, R(c, x, 5, x, 40), "#3a2216") end
  fl(c, R(c, 0, 5, W - 1, 9), "#2f1c10")
  c:fill(R(c, 0, 41, W - 1, H - 1), "#6b3b2a"); for y = 45, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#4a2c1a") end
  -- porthole window with moon
  part(c, c:ellipse(14, 20, 6, 6), "#2a3558"); c:fill(c:ellipse(15, 19, 2, 2), "#f5e6a8"); c:px(11, 22, "#f4eee0")
  c:outline(c:ellipse(14, 20, 6, 6)); fl(c, R(c, 14, 14, 14, 26), "#8a5a35"); fl(c, R(c, 8, 20, 20, 20), "#8a5a35")
  -- the one mast
  part(c, R(c, 44, 5, 47, 44), "#a8703e"); fl(c, R(c, 45, 5, 45, 44), "#c08a52")
  part(c, R(c, 39, 12, 52, 13), "#8a5a35")
  c:fill(c:line({ { 40, 13 }, { 44, 30 } }, 1), "#d9bc84"); c:fill(c:line({ { 51, 13 }, { 47, 30 } }, 1), "#d9bc84")
  for _, x in ipairs({ 28, 60 }) do
    fl(c, R(c, x, 9, x, 13), "#d9bc84"); part(c, R(c, x - 2, 14, x + 2, 19), "#ffd86a"); fl(c, R(c, x - 1, 15, x + 1, 18), "#fff1c8")
  end
  -- parrot on the yardarm
  part(c, c:ellipse(51, 9, 2, 3), "#dd3a2a"); fl(c, R(c, 51, 12, 52, 15), "#3f8fb0"); fl(c, R(c, 50, 6, 52, 6), "#dd3a2a"); c:px(53, 7, "#f5cf6a"); c:px(52, 7, INK)
  fl(c, R(c, 49, 9, 50, 11), "#4f9a45")
  -- bar, barrel seat, gnome
  part(c, R(c, 4, 34, 67, 39), "#8a5a35"); fl(c, R(c, 5, 34, 66, 34), "#c08a52")
  for _, x in ipairs({ 52, 58, 64 }) do part(c, R(c, x, 30, x + 3, 34), "#d9a660"); fl(c, R(c, x + 1, 30, x + 2, 30), "#f4eee0") end
  part(c, R(c, 8, 40, 20, 49), "#a8703e"); fl(c, R(c, 8, 43, 20, 43), "#6b4a2e"); fl(c, R(c, 8, 46, 20, 46), "#6b4a2e")
  local _, G = gnome(c, 32, 48, { d = -1, eyes = "open", arms = { arm({ -4, 7 }, { -9, 13 }, true, true), arm({ 4, 7 }, { 8, 5 }, false) } })
  local hx, hy = G.P(-9, 13)
  part(c, c:ellipse(hx - 1, hy - 2, 3, 3), "#e8d29a"); fl(c, R(c, hx - 2, hy - 7, hx - 2, hy - 4), "#4f9a45"); fl(c, R(c, hx - 1, hy - 7, hx + 1, hy - 6), "#e46a9b")
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0")
  gnome(c, 56, 48, { s = 0.8, d = -1, hat = "#4f9a45", eyes = "happy", arms = { arm({ -3, 6 }, { -6, 4 }, true) } })
  finish(c, "r_cb_tavern_yarns")
end

-- 17. the Singing Waterfall in the rain: gnome with a hand cupped to his ear, notes rising from the spray
function S.r_cb_waterfall_tales()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#7a8a96", "#8a9aa4", "#9aa8b0" }, { dir = "v" })
  part(c, R(c, 5, 5, 26, 34), "#6b7a78", { shade = true }); part(c, R(c, 46, 5, 68, 34), "#677674", { shade = true })
  for _, p in ipairs({ { 6, 14, 24 }, { 48, 22, 66 } }) do fl(c, R(c, p[1], p[2], p[3], p[2]), "#4e7a44") end
  fl(c, R(c, 5, 5, 26, 8), "#3f8a42"); fl(c, R(c, 46, 5, 68, 8), "#3f8a42")
  -- falls
  c:fill(R(c, 26, 5, 45, 36), "#cfe4ee")
  for _, x in ipairs({ 29, 33, 37, 41 }) do fl(c, R(c, x, 5, x, 34), "#eef8fa") end
  for _, x in ipairs({ 31, 35, 39, 43 }) do fl(c, R(c, x, 8, x, 28), "#a8cce0") end
  fl(c, R(c, 25, 5, 25, 36), "#2a1a10"); fl(c, R(c, 46, 5, 46, 36), "#2a1a10")
  -- pool
  c:fill(R(c, 0, 36, W - 1, H - 1), "#2f8a9a"); c:fill(R(c, 0, 36, W - 1, 36), "#7ad0d4")
  c:fill(c:ellipse(36, 37, 10, 2), "#f4fbf8")
  for _, p in ipairs({ { 14, 42 }, { 24, 46 }, { 50, 44 }, { 60, 47 } }) do fl(c, R(c, p[1], p[2], p[1] + 4, p[2]), "#58b9c4") end
  part(c, c:ellipse(52, 41, 4, 2), "#4e9a48", { noline = true }); fl(c, R(c, 52, 38, 53, 39), "#7ad04a"); c:px(51, 38, "#e0302a"); c:px(54, 38, "#e0302a")
  -- shore at left where the gnome stands
  part(c, c:ellipse(12, 46, 12, 4), "#7a8a6a", { shade = true }); fl(c, R(c, 4, 44, 6, 46), "#4e9a48")
  gnome(c, 14, 46, { d = 1, eyes = "shut", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 3, 9 }, { 5, 13 }, true) } })
  note(c, 20, 12, "#fff1c8"); note(c, 12, 20, "#fff1c8"); note(c, 52, 12, "#fff1c8"); note(c, 58, 22, "#fff1c8"); note(c, 18, 26, "#fff1c8")
  seed = 77
  rain(c, 38, 6, 6, 68, 48, "#cfdde6")
  finish(c, "r_cb_waterfall_tales")
end

-- 18. the Hurricane Crab: giant crab on a rock blows the sand, gnome listens with a cup of salty tea
function S.r_cb_crab_legends()
  local c = new()
  tsky(c, 30, nil, { "#8fb8d0", "#a8c8d8", "#c8dce4" })
  sea(c, 24, 32, "#3f8aa8", "#a8dce6")
  foam(c, 32, 3, 66)
  part(c, R(c, 8, 12, 12, 30), "#e8e0d0"); fl(c, R(c, 8, 16, 12, 18), "#c0442e"); fl(c, R(c, 8, 22, 12, 24), "#c0442e")
  part(c, c:poly({ { 7, 12 }, { 10, 7 }, { 13, 12 } }), "#3d2a1c")
  sandfill(c, 33)
  -- rock and crab
  part(c, c:ellipse(52, 46, 15, 6), "#7a8088", { shade = true })
  part(c, c:ellipse(52, 36, 10, 6), "#d4492e")
  c:fill(c:ellipse(52, 34, 6, 2), "#e8704a")
  fl(c, R(c, 47, 27, 47, 29), "#d4492e"); fl(c, R(c, 57, 27, 57, 29), "#d4492e")
  part(c, R(c, 46, 25, 48, 27), "#f4eee0"); part(c, R(c, 56, 25, 58, 27), "#f4eee0"); c:px(47, 26, INK); c:px(57, 26, INK)
  part(c, c:ellipse(40, 31, 4, 3), "#d4492e"); part(c, c:ellipse(64, 31, 4, 3), "#d4492e")
  c:px(39, 31, "#8e2e1e"); c:px(65, 31, "#8e2e1e")
  fl(c, R(c, 47, 38, 57, 38), "#8e2e1e")
  for _, x in ipairs({ 43, 46, 58, 61 }) do fl(c, R(c, x, 40, x, 43), "#a02a1a") end
  -- wind streaks and sand
  for _, w in ipairs({ { 14, 13, 10 }, { 30, 17, 9 }, { 17, 22, 12 }, { 36, 28, 8 }, { 4, 40, 6 } }) do fl(c, R(c, w[1], w[2], w[1] + w[3], w[2]), "#f4fbf8") end
  for _, p in ipairs({ { 33, 36 }, { 26, 40 }, { 38, 44 }, { 30, 47 } }) do c:px(p[1], p[2], "#d4bb80"); c:px(p[1] + 1, p[2], "#c9a96e") end
  local _, G = gnome(c, 20, 48, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 8 }, { 8, 10 }, true, true) } })
  local hx, hy = G.P(8, 10)
  part(c, R(c, hx, hy - 3, hx + 3, hy + 1), "#f4eee0"); fl(c, R(c, hx + 4, hy - 2, hx + 4, hy), "#f4eee0"); fl(c, R(c, hx - 1, hy - 1, hx, hy + 1), "#f0c8a0")
  fl(c, R(c, hx + 2, hy - 7, hx + 3, hy - 5), "#f4fbf8"); fl(c, R(c, hx + 4, hy - 9, hx + 5, hy - 8), "#f4fbf8")
  finish(c, "r_cb_crab_legends")
end

-- 19. midday heat: gnome in a hammock between two palms, drink on a stump, shimmering sun
function S.r_cb_hammock_heat()
  local c = new()
  tsky(c, 30, nil, { "#f8e8a8", "#fbeebc", "#fdf4d0" })
  c:fill(c:ellipse(56, 16, 8, 8), "#ffd34a"); c:fill(c:ellipse(56, 16, 5, 5), "#fff1a8")
  for _, r in ipairs({ { 56, 4, 56, 6 }, { 67, 16, 65, 16 }, { 64, 8, 62, 10 }, { 64, 24, 62, 22 }, { 46, 8, 48, 10 } }) do fl(c, c:line({ { r[1], r[2] }, { r[3], r[4] } }, 1), "#ffd34a") end
  sea(c, 26, 34, "#3fb0c0", "#a8e8ea")
  sandfill(c, 35, "#f0dca0", "#f8ecc0")
  palm(c, 11, 47, 30, 4); palm(c, 63, 47, 30, -4)
  -- hammock rope net sagging
  local function pt(x, y) return { x, y } end
  fl(c, c:line({ pt(14, 24), pt(26, 33) }, 1), "#d9bc84"); fl(c, c:line({ pt(52, 24), pt(46, 32) }, 1), "#d9bc84")
  part(c, c:poly({ pt(16, 26), pt(26, 35), pt(40, 40), pt(50, 30), pt(52, 27), pt(44, 36), pt(40, 37), pt(26, 31) }), "#e8c4a0")
  part(c, c:poly({ pt(24, 34), pt(40, 41), pt(50, 33), pt(46, 36), pt(40, 43), pt(26, 38) }), "#d9a07a")
  local _, G = gnome(c, 36, 37, { s = 1, d = 1, sit = true, eyes = "shut", arms = { arm({ 3, 7 }, { 6, 5 }, true) } })
  -- hat tipped over the eyes handled by shut eyes; drink on a stump
  part(c, R(c, 52, 42, 60, 49), "#8a5a35"); fl(c, R(c, 52, 42, 60, 43), "#c08a52")
  part(c, R(c, 55, 35, 58, 41), "#e8f4f8"); fl(c, R(c, 55, 35, 58, 38), "#f08a24"); fl(c, R(c, 59, 36, 60, 36), "#e46a9b"); fl(c, R(c, 59, 34, 59, 36), "#f4eee0")
  -- heat shimmer
  for _, p in ipairs({ { 22, 41 }, { 26, 43 }, { 44, 44 }, { 20, 46 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#fdf4d0"); c:px(p[1] + 3, p[2] - 1, "#fdf4d0") end
  finish(c, "r_cb_hammock_heat")
end

-- 20. the pampero gale: gnome grabs at runaway hats over the windswept pampas
function S.r_sa_pampero_hats()
  local c = new()
  tsky(c, 34, nil, { "#8fa8c0", "#a8bccc", "#c4d2d8" })
  for _, w in ipairs({ { 6, 8, 14 }, { 30, 11, 12 }, { 50, 7, 10 }, { 18, 16, 10 }, { 40, 20, 14 }, { 8, 26, 9 } }) do fl(c, R(c, w[1], w[2], w[1] + w[3], w[2]), "#eef4f6") end
  c:fill(c:ellipse(20, 35, 34, 5), "#8aa05a"); c:fill(R(c, 0, 35, W - 1, H - 1), "#a8b068")
  c:fill(R(c, 0, 35, W - 1, 35), "#c0c47a")
  for i = 1, 20 do local x, y = 4 + floor(rand() * 62), 38 + floor(rand() * 11); fl(c, R(c, x, y, x + 2, y), "#8a9a50") end
  -- pampas grass plumes bent by the wind
  for _, x in ipairs({ 9, 25, 55, 66 }) do
    fl(c, c:line({ { x, 47 }, { x + 2, 42 }, { x + 6, 39 } }, 1), "#8a9a50")
    part(c, c:poly({ { x + 3, 40 }, { x + 10, 37 }, { x + 7, 42 } }), "#f4e8c0", { noline = true })
  end
  -- market awning flapping
  part(c, R(c, 4, 18, 5, 36), "#6b4a2e", { noline = true })
  for k = 0, 3 do fl(c, c:poly({ { 6 + k * 3, 17 - k }, { 9 + k * 3, 17 - k + 1 }, { 9 + k * 3, 24 - k }, { 6 + k * 3, 22 - k } }), (k % 2 == 0) and "#dd3a2a" or "#f4eee0") end
  local _, G = gnome(c, 38, 48, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -7, 11 }, false), arm({ 4, 8 }, { 8, 17 }, true) } })
  local function hat(x, y, brim, dome)
    part(c, c:ellipse(x, y, 5, 1), brim); part(c, R(c, x - 2, y - 3, x + 2, y - 1), dome)
    fl(c, R(c, x - 2, y - 1, x + 2, y - 1), "#6b3b2a")
  end
  hat(50, 24, "#e8c48a", "#d9a660"); hat(26, 20, "#6b4a2e", "#8a5a35"); hat(60, 33, "#5a7a9a", "#4a6a8a"); hat(14, 30, "#e8c48a", "#d9a660")
  for _, w in ipairs({ { 54, 25, 5 }, { 30, 21, 5 }, { 64, 34, 3 }, { 18, 31, 4 } }) do fl(c, R(c, w[1], w[2], w[1] + w[3], w[2]), "#f4fbf8") end
  finish(c, "r_sa_pampero_hats")
end

-- 21. pole the ferry between flooded forest trunks in the rain
function S.r_sa_flood_ferry()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#7a8a8e", "#8a9a98", "#a0aea4" }, { dir = "v" })
  c:fill(c:ellipse(36, 28, 40, 7), "#5e7a58"); c:fill(R(c, 0, 28, W - 1, 31), "#6a846a")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#7a8a62")
  c:bands(R(c, 0, 31, W - 1, 49), { "#7a8a62", "#6e7e5a", "#667652" }, { dir = "v" })
  c:fill(R(c, 0, 31, W - 1, 31), "#a8b888")
  for y = 36, 48, 4 do for x = (y % 8 == 0) and 4 or 12, 66, 16 do fl(c, R(c, x, y, x + 4, y), "#8a9a70") end end
  -- trunks standing in the flood with high-water marks and blazes
  for _, t in ipairs({ { 10, 5, 38, 4 }, { 26, 5, 34, 3 }, { 52, 5, 38, 4 }, { 64, 5, 33, 3 } }) do
    part(c, R(c, t[1], t[2], t[1] + t[4] - 1, t[3]), "#5e4a3a", { noline = true })
    fl(c, R(c, t[1], 20, t[1] + t[4] - 1, 20), "#a89a72"); fl(c, R(c, t[1], 27, t[1] + t[4] - 1, 28), "#a89a72")
    fl(c, R(c, t[1] + 1, 13, t[1] + 1, 15), "#f4eee0")
    fl(c, R(c, t[1], 5, t[1] + t[4] + 3, 9), "#3f6a3a")
  end
  -- dugout ferry
  part(c, c:poly({ { 16, 40 }, { 56, 40 }, { 50, 46 }, { 22, 46 } }), "#8a5a35"); fl(c, R(c, 17, 40, 55, 40), "#c08a52")
  fl(c, R(c, 24, 43, 48, 43), "#6b3b2a")
  part(c, R(c, 44, 33, 48, 39), "#c9a96e"); fl(c, R(c, 45, 34, 47, 36), "#3d2a1c")
  local _, G = gnome(c, 28, 40, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -5, 5 }, false), arm({ 4, 8 }, { 8, 10 }, true) } })
  local hx, hy = G.P(8, 10)
  part(c, c:line({ { hx - 2, hy - 18 }, { hx + 2, hy }, { hx + 8, 47 } }, 1), "#a8703e", { noline = true })
  for _, p in ipairs({ { 14, 47 }, { 52, 47 }, { 40, 48 } }) do fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#8a9a70") end
  seed = 88
  rain(c, 55, 6, 5, 68, 48, "#d4e0e4")
  finish(c, "r_sa_flood_ferry")
end

-- 22. dawn on the Saltglass Flats: gnome shades his eyes towards the far gold cairn
function S.r_sa_salt_crossing()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#5a5a98", "#8a6aa4", "#c88aa4", "#f0a890", "#f8cc90" }, { dir = "v" })
  c:fill(c:ellipse(48, 30, 9, 9):clip(R(c, 0, 0, W, 30)), "#fff0b0"); c:fill(c:ellipse(48, 30, 6, 6):clip(R(c, 0, 0, W, 30)), "#ffe080")
  c:fill(c:ellipse(12, 31, 22, 6):clip(R(c, 0, 0, W, 30)), "#7a6aa0"); c:fill(c:ellipse(62, 31, 20, 8):clip(R(c, 0, 0, W, 30)), "#8a72a8")
  fl(c, R(c, 12, 22, 14, 23), "#d8c8e0"); fl(c, R(c, 60, 20, 62, 21), "#d8c8e0")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#f2eee6")
  c:bands(R(c, 0, 31, W - 1, 38), { "#f8e8c8", "#f4eadc", "#f2eee6" }, { dir = "v" })
  c:fill(c:ellipse(48, 36, 14, 3), "#fbe0a0")
  -- crust hexagon lines
  local rows = { { 33, 6, 14 }, { 37, 8, 18 }, { 42, 11, 24 }, { 48, 15, 32 } }
  for _, r in ipairs(rows) do
    local y, cw, hh = r[1], r[2], r[3]
    for x = 4 - (y % 2) * (cw // 2), 68, cw do
      fl(c, R(c, x, y, x + cw // 2, y), "#d4cebe")
      fl(c, c:line({ { x + cw // 2, y }, { x + cw, y + (hh > 20 and 3 or 2) } }, 1), "#d4cebe")
      fl(c, R(c, x, y, x, y + (hh > 20 and 2 or 1)), "#d4cebe")
    end
  end
  -- cairn far away, gold-lit
  part(c, R(c, 59, 31, 65, 33), "#a89a8a"); part(c, R(c, 60, 29, 64, 30), "#b8aa9a"); part(c, R(c, 61, 27, 63, 28), "#c8bcaa"); c:px(62, 27, "#ffe080")
  -- gnome walking, hand to brow, long shadow
  c:fill(c:ellipse(15, 49, 10, 1), "#cfc6c0")
  local _, G = gnome(c, 24, 48, { d = 1, walk = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 8 }, { 5, 13 }, true) } })
  c:px(40, 44, "#fff8e0"); c:px(52, 40, "#fff8e0"); c:px(30, 38, "#fff8e0")
  finish(c, "r_sa_salt_crossing")
end

-- 23. cloud-forest stair: mossy steps vanishing into the mist, orchids glowing, gnome with a lantern
function S.r_sa_cloud_path()
  local c = new()
  c:bands(R(c, 0, 0, W - 1, H - 1), { "#b8c8c0", "#c4d2ca", "#ccd8d0", "#d4dfd8" }, { dir = "v" })
  -- faded trunks
  for _, t in ipairs({ { 9, 5 }, { 24, 5 }, { 47, 5 }, { 62, 5 } }) do part(c, R(c, t[1], t[2], t[1] + 3, 40), "#6a7a6a", { noline = true }) end
  for _, t in ipairs({ { 17, 5 }, { 38, 5 }, { 56, 5 } }) do part(c, R(c, t[1], t[2], t[1] + 1, 36), "#8a9a8c", { noline = true }) end
  -- orchids on trunks
  local function orchid(x, y, col) fl(c, R(c, x, y, x + 2, y + 1), col); c:px(x + 1, y - 1, col); c:px(x + 1, y, "#fff1c8") end
  orchid(8, 14, "#e84aa0"); orchid(23, 20, "#f5cf6a"); orchid(46, 12, "#c85ab0"); orchid(61, 24, "#f08a3a"); orchid(46, 28, "#e84aa0"); orchid(23, 31, "#c85ab0")
  -- mist veils over the far part
  fl(c, R(c, 5, 16, 68, 19), "#dfe8e2"); fl(c, R(c, 5, 30, 68, 31), "#dfe8e2")
  -- mossy steps climbing right
  local steps = { { 10, 47, 24 }, { 22, 44, 36 }, { 34, 41, 48 }, { 46, 38, 60 }, { 58, 35, 70 } }
  for i, s in ipairs(steps) do
    part(c, R(c, s[1], s[2], s[3], 49), (i % 2 == 0) and "#8a8e86" or "#7a7e78", { shade = false })
    fl(c, R(c, s[1], s[2], s[3], s[2]), "#4e8a44"); fl(c, R(c, s[1] + 2, s[2] + 1, s[1] + 5, s[2] + 1), "#3f7a3a")
  end
  fl(c, R(c, 48, 30, 68, 34), "#dfe8e2")
  -- gnome with lantern on the second step
  local _, G = gnome(c, 22, 44, { d = 1, walk = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 7 }, { 8, 9 }, true) } })
  local hx, hy = G.P(8, 9)
  part(c, R(c, hx, hy, hx + 3, hy + 4), "#ffd86a"); fl(c, R(c, hx + 1, hy + 1, hx + 2, hy + 3), "#fff1c8"); fl(c, R(c, hx + 1, hy - 1, hx + 2, hy - 1), "#3d2a1c")
  -- big fern fronds in the foreground corners
  for i = 0, 3 do fl(c, c:line({ { 5, 49 }, { 10 + i * 2, 41 - i * 2 } }, 1), "#3f7a3a") end
  for i = 0, 2 do fl(c, c:line({ { 68, 49 }, { 62 - i * 3, 43 - i } }, 1), "#3f7a3a") end
  for _, p in ipairs({ { 12, 24 }, { 30, 26 }, { 52, 22 }, { 40, 36 } }) do c:px(p[1], p[2], "#eef4f0") end
  finish(c, "r_sa_cloud_path")
end

-- 24. rhea roundup: big grey rheas stride towards the gate, gnome loops round behind them
function S.r_sa_rhea_roundup()
  local c = new()
  tsky(c, 30, 52, { "#8cc0e0", "#a8d4e8", "#c8e4ec" })
  c:fill(c:ellipse(16, 31, 30, 6), "#a8b868"); c:fill(R(c, 0, 30, W - 1, H - 1), "#b8c070")
  c:fill(R(c, 0, 30, W - 1, 30), "#d0d488")
  for i = 1, 26 do local x, y = 4 + floor(rand() * 62), 32 + floor(rand() * 17); fl(c, R(c, x, y, x, y + 2), "#8a9a50"); c:px(x + 1, y + 1, "#8a9a50") end
  -- gate and fence at right
  for _, x in ipairs({ 54, 66 }) do part(c, R(c, x, 22, x + 1, 42), "#8a5a35", { noline = true }) end
  fl(c, R(c, 44, 26, 66, 27), "#a8703e"); fl(c, R(c, 44, 33, 66, 34), "#a8703e"); fl(c, R(c, 44, 26, 44, 40), "#6b4a2e")
  for _, x in ipairs({ 44, 58 }) do part(c, R(c, x, 24, x + 1, 38), "#8a5a35", { noline = true }) end
  local function rhea(x, yb, s2)
    part(c, R(c, x - 3, yb - 9, x - 3, yb), "#8a7a6a", { noline = true }); part(c, R(c, x + 2, yb - 9, x + 2, yb), "#8a7a6a", { noline = true })
    part(c, c:ellipse(x, yb - 12, 7, 4), "#a8a094")
    c:fill(c:ellipse(x - 1, yb - 10, 5, 1), "#cfc8bc"); fl(c, R(c, x - 7, yb - 14, x - 5, yb - 11), "#8a8478")
    part(c, R(c, x + 4, yb - 22, x + 5, yb - 14), "#a8a094", { noline = true })
    part(c, R(c, x + 4, yb - 25, x + 7, yb - 22), "#a8a094"); fl(c, R(c, x + 8, yb - 24, x + 9, yb - 24), "#6b4a2e"); c:px(x + 6, yb - 24, INK)
  end
  rhea(38, 41, 1); rhea(52, 46, 1); rhea(30, 48, 1)
  gnome(c, 12, 48, { d = 1, walk = 1, eyes = "open", arms = { arm({ -4, 8 }, { -9, 12 }, false), arm({ 4, 8 }, { 10, 12 }, true) } })
  for _, p in ipairs({ { 22, 44 }, { 24, 47 }, { 19, 49 } }) do c:px(p[1], p[2], "#f5e6a8") end
  finish(c, "r_sa_rhea_roundup")
end

local order = {}
for line in io.lines("/tmp/claude-0/-home-user-gnome-venture/1b9189c1-3b2f-55fd-a82b-d2ac35c1c228/scratchpad/lists/h4.txt") do
  line = line:gsub("%s+", "")
  if line ~= "" then order[#order + 1] = line end
end
local sd = 0
for _, s2 in ipairs(order) do
  sd = sd + 13
  if S[s2] and (not only or only == s2) then seed = sd; S[s2]() end
end
