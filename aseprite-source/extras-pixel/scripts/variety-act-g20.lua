-- variety-act-g20.lua : Do-tab scenes for ferry (w4_*) and tower (w5_*) rest-stop activities -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g20.lua   (params BEFORE --script)
-- Sprite/frame helpers copied from variety-act-g5.lua. Frame (5 grid px wooden frame) copied from the shipped act-hand.png.
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

---------------------------------------------------------------- shared bits for g20
local function river(c, y0, cols)
  c:bands(R(c, 0, y0, W - 1, H - 1), cols or { "#5aa0c8", "#4f93c0", "#4688b6", "#3d7aa8" }, { dir = "v" })
  for i = 1, 14 do
    local x, y = floor(rand() * 62) + 3, y0 + 2 + floor(rand() * (H - y0 - 3))
    fl(c, R(c, x, y, x + 2 + floor(rand() * 3), y), "#9ed0e4")
  end
end
local function flatboat(c, x0, x1, y)
  part(c, R(c, x0, y, x1, y + 4), "#8a5a35")
  fl(c, R(c, x0 + 1, y + 1, x1 - 1, y + 1), "#b07a45")
  fl(c, R(c, x0 + 1, y + 4, x1 - 1, y + 4), "#5e3f28")
  for x = x0 + 6, x1 - 4, 8 do fl(c, R(c, x, y + 2, x, y + 3), "#5e3f28") end
end
local function stonewall(c, x0, y0, x1, y1, col, mortar)
  fl(c, R(c, x0, y0, x1, y1), col)
  local r = 0
  for y = y0 + 3, y1, 4 do
    fl(c, R(c, x0, y, x1, y), mortar)
    for x = x0 + (r % 2) * 4 + 2, x1, 8 do fl(c, R(c, x, y - 3, x, y - 1), mortar) end
    r = r + 1
  end
end
-- stone parapet with merlons; top of the merlons at y0
local function parapet(c, y0, col, mortar)
  col = col or "#9aa0a8"
  local m = c:mask()
  m:add(R(c, 0, y0 + 4, W - 1, H - 1))
  for x = 1, W - 1, 11 do m:add(R(c, x, y0, x + 6, y0 + 4)) end
  part(c, m, col)
  for y = y0 + 8, H - 1, 4 do fl(c, R(c, 0, y, W - 1, y), mortar or "#7a8088") end
  for x = 3, W - 1, 8 do fl(c, R(c, x, y0 + 5, x, y0 + 7), mortar or "#7a8088") end
end
local function skyv(c, y1, cols, cl)
  c:bands(R(c, 0, 0, W - 1, y1), cols or { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  if cl then
    for _, p in ipairs(cl) do c:fill(c:ellipse(p[1], p[2], p[3] or 8, 2), "#f4eee0"); c:fill(c:ellipse(p[1] + 4, p[2] - 2, 5, 2), "#f4eee0") end
  end
end
local function folk(c, x, yb, body, skin, hatfn)
  part(c, R(c, x - 3, yb - 5, x + 3, yb), body)
  part(c, R(c, x - 2, yb - 10, x + 2, yb - 6), skin)
  c:px(x - 1, yb - 8, INK); c:px(x + 1, yb - 8, INK)
  hatfn(x, yb - 10)
end
local Q = { ".xx.", "x..x", "...x", "..x.", "....", "..x." }
local function qmark(c, x, y, col) c:paint(Q, x, y, { x = col or "#2a1a10" }) end

---------------------------------------------------------------- scenes
-- w4_passenger_hats: porter with his list points at the new hat among the ferry passengers
function S.w4_passenger_hats()
  seed = 61
  local c = new()
  day(c, 24, { cloud = 50 })
  river(c, 30)
  part(c, R(c, 5, 38, 18, 41), "#b07a45")
  part(c, R(c, 7, 41, 8, 49), "#5e3f28", { noline = true }); part(c, R(c, 15, 41, 16, 49), "#5e3f28", { noline = true })
  flatboat(c, 20, 67, 40)
  local sk = "#f0c8a0"
  folk(c, 27, 39, "#7a5a9a", sk, function(x, ty)
    part(c, R(c, x - 4, ty - 1, x + 4, ty), "#e8c48a"); part(c, R(c, x - 2, ty - 4, x + 2, ty - 2), "#e8c48a"); fl(c, R(c, x - 2, ty - 2, x + 2, ty - 2), "#c0442e") end)
  folk(c, 36, 39, "#4f9a6a", sk, function(x, ty)
    part(c, c:ellipse(x, ty - 1, 4, 3), "#f5cf6a"); fl(c, R(c, x + 3, ty, x + 3, ty + 3), "#dd5a42") end)
  folk(c, 45, 39, "#3f6fb0", sk, function(x, ty)
    part(c, c:poly({ { x - 5, ty }, { x, ty - 5 }, { x + 5, ty } }), "#3a3a4a"); fl(c, R(c, x - 4, ty, x + 4, ty), "#e8a317") end)
  folk(c, 54, 39, "#c07a8a", sk, function(x, ty)
    fl(c, R(c, x - 3, ty - 1, x + 3, ty - 1), "#4e9a48")
    for i, cc in ipairs({ "#e46a9b", "#f5cf6a", "#f4eee0", "#e46a9b", "#f5cf6a" }) do c:px(x - 3 + floor((i - 1) * 1.5), ty - 2, cc) end end)
  folk(c, 63, 39, "#d9a660", sk, function(x, ty)
    part(c, R(c, x - 3, ty - 4, x + 3, ty), "#3f8fb0"); part(c, c:ellipse(x, ty - 5, 1, 1), "#f4eee0") end)
  -- rail in front
  fl(c, R(c, 20, 37, 67, 37), "#b07a45"); fl(c, R(c, 20, 38, 67, 38), "#8a5a35")
  for _, x in ipairs({ 21, 66 }) do part(c, R(c, x - 1, 34, x, 39), "#8a5a35", { noline = true }) end
  -- the porter with his list
  gnome(c, 11, 37, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 10, 11 }, true), arm({ -4, 7 }, { -5, 3 }, false) } })
  part(c, R(c, 5, 31, 8, 40), "#f4eee0")
  for y = 33, 39, 2 do fl(c, R(c, 6, y, 7, y), "#8a5a35") end
  finish(c, "w4_passenger_hats")
end

-- w4_lost_ticket: five patting passengers on deck, gnome holds the ticket up
function S.w4_lost_ticket()
  seed = 62
  local c = new()
  skyv(c, 22, nil, { { 50, 9 } })
  c:fill(c:ellipse(18, 24, 34, 8), "#5e8a44"); c:fill(c:ellipse(60, 25, 28, 7), "#4e8a3c")
  c:fill(R(c, 0, 24, W - 1, 28), "#4688b6")
  fl(c, R(c, 0, 28, W - 1, 30), "#5a3a22")
  -- deck
  c:fill(R(c, 0, 29, W - 1, H - 1), "#b07a45")
  for y = 33, 49, 4 do fl(c, R(c, 0, y, W - 1, y), "#8a5a35") end
  for x = 4, W - 1, 11 do fl(c, R(c, x, 30, x, 32), "#8a5a35") end
  local sk = { "#f0c8a0", "#d9a07a", "#f0c8a0", "#c08a62", "#f0c8a0" }
  local bd = { "#7a5a9a", "#4f9a6a", "#c07a8a", "#3f6fb0", "#d9a660" }
  local hats = {
    function(x, ty) part(c, R(c, x - 3, ty - 3, x + 3, ty), "#3a3a4a") end,
    function(x, ty) part(c, c:ellipse(x, ty - 1, 4, 2), "#f5cf6a") end,
    function(x, ty) part(c, R(c, x - 2, ty - 4, x + 2, ty), "#dd5a42"); fl(c, R(c, x - 2, ty - 2, x + 2, ty - 2), "#f4eee0") end,
    function(x, ty) part(c, R(c, x - 4, ty - 1, x + 4, ty), "#e8c48a"); part(c, R(c, x - 2, ty - 3, x + 2, ty - 2), "#e8c48a") end,
    function(x, ty) part(c, R(c, x - 3, ty - 3, x + 3, ty), "#4f9a45") end,
  }
  local xs = { 10, 21, 42, 53, 64 }
  for i = 1, 5 do folk(c, xs[i], 42, bd[i], sk[i], hats[i]) end
  for i = 1, 5 do fl(c, R(c, xs[i] + 2, 40, xs[i] + 3, 41), sk[i]) end
  qmark(c, 8, 19); qmark(c, 51, 19, "#dd3a2a"); qmark(c, 62, 19)
  gnome(c, 31, 49, { d = 1, eyes = "happy", arms = { arm({ 4, 8 }, { 7, 19 }, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  local tx, ty = 34, 23
  part(c, R(c, tx, ty, tx + 8, ty + 4), "#f4eee0")
  fl(c, R(c, tx + 5, ty + 1, tx + 5, ty + 3), "#dd5a42"); fl(c, R(c, tx + 1, ty + 2, tx + 3, ty + 2), "#8a5a35")
  c:px(tx, ty + 2, "#8a5a35")
  finish(c, "w4_lost_ticket")
end

-- w4_loose_plank: a plank on the landing pops up under the gnome's boot; porter fetches the hammer
function S.w4_loose_plank()
  seed = 63
  local c = new()
  day(c, 25, { cloud = 14 })
  river(c, 30)
  for _, x in ipairs({ 8, 24, 40, 56 }) do part(c, R(c, x, 40, x + 2, 49), "#5e3f28", { noline = true }) end
  fl(c, R(c, 5, 44, 68, 44), "#3d74a2")
  -- deck made of four planks; the third is raised at one end
  part(c, R(c, 5, 38, 19, 41), "#b07a45"); part(c, R(c, 20, 38, 34, 41), "#c08a52")
  part(c, R(c, 53, 38, 68, 41), "#b07a45")
  fl(c, R(c, 35, 41, 52, 44), "#2a1a10")
  part(c, c:poly({ { 35, 39 }, { 52, 28 }, { 52, 33 }, { 35, 43 } }), "#e8c48a")
  fl(c, R(c, 48, 30, 48, 31), "#e8ecf0"); fl(c, R(c, 49, 30, 49, 31), "#7a8088")
  for _, p in ipairs({ { 36, 36 }, { 33, 33 }, { 31, 37 } }) do c:px(p[1], p[2], "#f4eee0"); c:px(p[1] + 1, p[2], "#f4eee0") end
  for _, p in ipairs({ { 26, 48 }, { 14, 46 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#8fc4dc") end
  gnome(c, 28, 37, { d = 1, walk = 1, eyes = "open", arms = { arm({ -4, 7 }, { -8, 11 }, false), arm({ 4, 7 }, { 8, 12 }, true) } })
  gnome(c, 61, 37, { d = -1, hat = "#8a6a3a", eyes = "open", arms = { arm({ -4, 8 }, { -8, 14 }, true) } })
  fl(c, c:line({ { 53, 24 }, { 53, 17 } }, 1), "#8a5a35")
  part(c, R(c, 50, 13, 56, 17), "#8b929c")
  finish(c, "w4_loose_plank")
end

-- w4_chain_winch: gnome heaves the crank of a big winch; the chain tows the ferry across
function S.w4_chain_winch()
  seed = 64
  local c = new()
  day(c, 24, { cloud = 20 })
  river(c, 30)
  flatboat(c, 5, 27, 38)
  fl(c, R(c, 7, 34, 8, 37), "#5a3a22"); fl(c, R(c, 23, 34, 24, 37), "#5a3a22"); fl(c, R(c, 7, 34, 24, 34), "#b07a45")
  folk(c, 15, 37, "#7a5a9a", "#f0c8a0", function(x, ty) part(c, R(c, x - 3, ty - 3, x + 3, ty), "#4f9a45") end)
  part(c, R(c, 36, 38, 68, 42), "#b07a45")
  for _, x in ipairs({ 39, 63 }) do part(c, R(c, x, 42, x + 1, 49), "#5e3f28", { noline = true }) end
  local n = 0
  c:line({ { 45, 29 }, { 38, 33 }, { 32, 36 }, { 27, 37 } }, 2):each(function(x, y) n = n + 1; c:px(x, y, ((x + y) % 4 < 2) and "#3a3f48" or "#d0d6dc") end)
  part(c, R(c, 40, 20, 41, 38), "#8a5a35", { noline = true }); part(c, R(c, 51, 20, 52, 38), "#8a5a35", { noline = true })
  part(c, c:ellipse(46, 28, 8, 8), "#a8703e", { shade = true })
  c:fill(c:ellipse(46, 28, 5, 5), "#d9a660")
  fl(c, R(c, 46, 21, 46, 35), "#6b3b2a"); fl(c, R(c, 39, 28, 53, 28), "#6b3b2a")
  fl(c, c:line({ { 40, 22 }, { 52, 34 } }, 1), "#6b3b2a"); fl(c, c:line({ { 52, 22 }, { 40, 34 } }, 1), "#6b3b2a")
  c:fill(c:ellipse(46, 28, 1, 1), "#3a3f48")
  fl(c, c:line({ { 46, 28 }, { 53, 31 } }, 2), "#6b3b2a"); fl(c, R(c, 52, 31, 54, 34), "#8a5a35")
  gnome(c, 61, 37, { d = -1, eyes = "open", arms = { arm({ -4, 8 }, { -8, 5 }, true), arm({ 4, 7 }, { 5, 3 }, false) } })
  for _, p in ipairs({ { 57, 24 }, { 58, 20 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#f4f8fa") end
  finish(c, "w4_chain_winch")
end

-- w4_strange_fares: dusk, last ferry lamp-lit, ferryman remembers a hedgehog fare
function S.w4_strange_fares()
  seed = 65
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#3b2f66", "#4e3a78", "#7a4a88", "#b45a7c", "#e8825e", "#f0a868" }, { dir = "v" })
  for _, p in ipairs({ { 9, 7 }, { 22, 5 }, { 36, 8 }, { 58, 6 }, { 66, 14 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(c:ellipse(12, 31, 28, 8), "#2f2a58"); c:fill(c:ellipse(62, 31, 26, 7), "#352c5c")
  c:bands(R(c, 0, 30, W - 1, H - 1), { "#5a4a86", "#4a3e78", "#3e3470", "#342c62" }, { dir = "v" })
  for i = 1, 10 do local x, y = 4 + floor(rand() * 60), 33 + floor(rand() * 15); fl(c, R(c, x, y, x + 3, y), "#8a6aa8") end
  -- lamp glow streaks on the water
  for i, y in ipairs({ 45, 47, 49 }) do fl(c, R(c, 52 - i, y, 56 + i, y), "#f0b868") end
  -- the flat boat, centre
  flatboat(c, 10, 64, 40)
  part(c, R(c, 11, 36, 12, 40), "#8a5a35", { noline = true }); part(c, R(c, 62, 36, 63, 40), "#8a5a35", { noline = true })
  fl(c, R(c, 11, 36, 63, 36), "#8a5a35")
  -- lantern post
  part(c, R(c, 56, 26, 57, 40), "#3d2a1c", { noline = true })
  part(c, R(c, 54, 20, 59, 26), "#ffd86a", { shade = true, cres = 1 })
  c:fill(R(c, 55, 21, 58, 24), "#fff1c8")
  part(c, R(c, 53, 19, 60, 20), "#3d2a1c")
  for _, p in ipairs({ { 51, 22 }, { 62, 22 }, { 56, 16 } }) do c:px(p[1], p[2], "#f8c070") end
  -- ferryman seated at the stern with a pole
  fl(c, R(c, 14, 20, 15, 39), "#6b4a2e")
  gnome(c, 24, 39, { d = 1, sit = true, eyes = "shut", arms = { arm({ 3, 8 }, { 7, 6 }, true, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  -- memory bubble: a hedgehog paying in rhymes
  part(c, c:ellipse(29, 24, 1, 1), "#f4eee0"); part(c, c:ellipse(32, 20, 2, 1), "#f4eee0")
  part(c, c:ellipse(40, 13, 17, 9), "#f4eee0")
  part(c, c:ellipse(40, 14, 5, 3), "#8a5a35", { noline = true })
  for _, x in ipairs({ 36, 38, 40, 42, 44 }) do c:px(x, 11, "#4a2c1a"); c:px(x, 12 - ((x % 2)), "#4a2c1a") end
  fl(c, R(c, 44, 14, 46, 15), "#d9a07a"); c:px(46, 14, INK); c:px(41, 14, INK)
  fl(c, R(c, 36, 17, 37, 17), "#4a2c1a"); fl(c, R(c, 43, 17, 44, 17), "#4a2c1a")
  -- little musical notes (rhymes)
  fl(c, R(c, 31, 8, 32, 11), "#8a5a35"); fl(c, R(c, 30, 11, 31, 12), "#8a5a35")
  fl(c, R(c, 50, 7, 51, 10), "#8a5a35"); fl(c, R(c, 49, 10, 50, 11), "#8a5a35")
  c:px(52, 22, "#ffe08a"); c:px(18, 33, "#ffe08a")
  finish(c, "w4_strange_fares")
end

-- w4_toll_ledger: night hut, toll-keeper at her ledger under a lantern; gnawed stick over the door
function S.w4_toll_ledger()
  seed = 66
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#2c2640")
  for x = 3, W - 1, 8 do fl(c, R(c, x, 0, x, 40), "#231e36") end
  c:fill(c:ellipse(34, 18, 28, 20), "#3b3454"); c:fill(c:ellipse(34, 18, 18, 13), "#4e4366")
  for x = 3, W - 1, 8 do for y = 2, 38, 9 do c:px(x, y, "#5a4e74") end end
  -- night window with moon
  part(c, R(c, 6, 10, 18, 26), "#1f2a52")
  fl(c, R(c, 12, 10, 12, 26), "#5a3a22"); fl(c, R(c, 6, 18, 18, 18), "#5a3a22")
  c:fill(c:ellipse(9, 13, 2, 2), "#f5e6a8"); c:px(15, 22, "#f4eee0"); c:px(16, 14, "#f4eee0")
  -- gnawed stick on pegs high on the right wall
  fl(c, R(c, 52, 11, 52, 14), "#5a3a22"); fl(c, R(c, 63, 11, 63, 14), "#5a3a22")
  part(c, c:line({ { 51, 12 }, { 64, 11 } }, 2), "#c08a52")
  for _, x in ipairs({ 55, 58, 61 }) do c:px(x, 11, "#7a4a2a"); c:px(x + 1, 12, "#7a4a2a") end
  fl(c, R(c, 50, 11, 50, 12), "#e8c48a")
  -- hanging lantern
  fl(c, R(c, 34, 0, 34, 6), "#3d2a1c")
  part(c, R(c, 31, 6, 37, 13), "#ffd86a", { shade = true, cres = 1 })
  c:fill(R(c, 32, 8, 36, 11), "#fff1c8")
  part(c, R(c, 30, 5, 38, 6), "#3d2a1c")
  for _, p in ipairs({ { 27, 8 }, { 41, 8 }, { 34, 16 } }) do c:px(p[1], p[2], "#a8884a") end
  -- floor + desk
  c:fill(R(c, 0, 41, W - 1, H - 1), "#4a3322")
  for y = 45, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#3a2418") end
  gnome(c, 34, 45, { d = 1, upper = true, s = 1.25, eyes = "open", arms = { arm({ -4, 6 }, { -8, 8 }, true, true), arm({ 4, 6 }, { 9, 10 }, true) } })
  part(c, R(c, 4, 41, 67, 49), "#7a4a2a")
  fl(c, R(c, 4, 41, 67, 42), "#a8703e")
  for _, x in ipairs({ 20, 36, 52 }) do fl(c, R(c, x, 44, x, 48), "#5e2f1e") end
  -- the open ledger, bright pages
  part(c, R(c, 16, 36, 51, 41), "#f4eee0")
  fl(c, R(c, 33, 36, 34, 41), "#b8a888")
  for y = 38, 40, 2 do fl(c, R(c, 19, y, 31, y), "#8a6a4a"); fl(c, R(c, 36, y, 48, y), "#8a6a4a") end
  fl(c, R(c, 19, 37, 24, 37), "#3a4a8a")
  -- coins, quill and ink
  for i = 0, 2 do part(c, c:ellipse(58, 38 - i * 2, 3, 1), "#e8a317", { noline = true }); fl(c, R(c, 56, 38 - i * 2, 59, 38 - i * 2), "#f5cf6a") end
  part(c, R(c, 8, 36, 12, 40), "#2a1a10"); fl(c, R(c, 9, 36, 11, 36), "#4a3e78")
  fl(c, c:line({ { 45, 33 }, { 50, 26 } }, 1), "#f4eee0"); c:px(51, 25, "#f4eee0")
  finish(c, "w4_toll_ledger")
end


-- w5_weathervane_oil: gnome on a crate squirts oil at the stuck pivot under the tin cockerel
function S.w5_weathervane_oil()
  seed = 71
  local c = new()
  skyv(c, 40, nil, { { 54, 10 }, { 12, 24 } })
  c:fill(c:ellipse(16, 42, 30, 9), "#5e8a44"); c:fill(c:ellipse(62, 42, 26, 8), "#4e8a3c")
  stonewall(c, 0, 40, W - 1, H - 1, "#9aa0a8", "#7a8088")
  fl(c, R(c, 0, 40, W - 1, 40), "#c9ccd0")
  -- pole, collar with the four arms, tin cockerel
  part(c, R(c, 36, 14, 37, 40), "#6b4a2e", { noline = true })
  fl(c, R(c, 31, 22, 42, 22), "#4a4f58"); fl(c, R(c, 36, 17, 37, 27), "#4a4f58")
  for _, p in ipairs({ { 30, 22 }, { 43, 22 }, { 36, 17 }, { 37, 28 } }) do part(c, R(c, p[1] - 1, p[2] - 1, p[1] + 1, p[2] + 1), "#8b929c", { noline = true }) end
  part(c, c:ellipse(36, 12, 5, 3), "#aeb4bc", { shade = true })
  part(c, c:poly({ { 29, 6 }, { 32, 8 }, { 32, 12 }, { 30, 11 } }), "#8b929c")
  part(c, c:ellipse(40, 9, 2, 2), "#aeb4bc")
  fl(c, R(c, 39, 6, 41, 7), "#dd3a2a"); fl(c, R(c, 42, 9, 43, 10), "#e8a317"); c:px(40, 9, INK)
  -- crate and gnome with oilcan
  part(c, R(c, 19, 34, 29, 40), "#a8703e"); fl(c, R(c, 19, 37, 29, 37), "#8a5a35")
  local _, G = gnome(c, 24, 34, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 13 }, true, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  local hx, hy = G.P(9, 13)
  part(c, R(c, hx - 2, hy - 3, hx + 2, hy + 1), "#c0442e")
  fl(c, c:line({ { hx + 2, hy - 2 }, { hx + 6, hy - 5 } }, 1), "#aeb4bc")
  fl(c, R(c, hx - 1, hy + 1, hx + 1, hy + 2), "#f0c8a0")
  for _, p in ipairs({ { hx + 7, hy - 4 }, { hx + 8, hy - 2 }, { hx + 7, hy } }) do c:px(p[1], p[2], "#e8a317") end
  c:px(33, 23, "#e8a317"); c:px(34, 25, "#e8a317")
  -- twinkle where it frees up
  c:px(45, 16, "#fff1c8"); c:px(44, 16, "#f5cf6a"); c:px(46, 16, "#f5cf6a"); c:px(45, 15, "#f5cf6a"); c:px(45, 17, "#f5cf6a")
  finish(c, "w5_weathervane_oil")
end

-- w5_count_carts: gnome behind the wall with a chalk slate, carts on three roads
function S.w5_count_carts()
  seed = 72
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 46), "#7ea85a")
  for y = 8, 44, 6 do fl(c, R(c, 0, y, W - 1, y), "#74a052") end
  for i = 1, 16 do local x, y = 3 + floor(rand() * 66), 6 + floor(rand() * 38); c:px(x, y, "#5e8a44"); c:px(x + 1, y - 1, "#5e8a44") end
  -- three roads seen from the tower, each with a different cart
  local road, edge = "#e0c88a", "#b8965c"
  local function lane(y0, h, bend)
    for x = 0, W - 1 do
      local yy = y0 + floor(bend * math.sin(x / 11))
      fl(c, R(c, x, yy, x, yy + h), road)
      c:px(x, yy, edge); c:px(x, yy + h, edge)
    end
  end
  lane(11, 5, 1.2); lane(21, 6, 1.5); lane(32, 6, 1.2)
  -- far lane: hay wagon (small)
  part(c, R(c, 46, 11, 53, 14), "#8a5a35"); part(c, c:ellipse(49.5, 10, 4, 2), "#e8c860"); part(c, c:ellipse(48, 15, 1, 1), "#5a3a22", { noline = true }); part(c, c:ellipse(52, 15, 1, 1), "#5a3a22", { noline = true })
  -- middle lane: barrow with a sack, and a loaded wagon
  part(c, R(c, 28, 21, 33, 24), "#c0442e"); part(c, c:ellipse(30.5, 20, 2, 1), "#e8d8a8", { noline = true }); part(c, c:ellipse(31, 25, 1, 1), "#5a3a22", { noline = true })
  part(c, R(c, 52, 20, 62, 24), "#6b8aa8"); part(c, R(c, 53, 17, 61, 19), "#a8703e"); part(c, c:ellipse(54, 25, 2, 2), "#5a3a22", { noline = true }); part(c, c:ellipse(60, 25, 2, 2), "#5a3a22", { noline = true })
  -- near lane: goose on a lead towards a barrow
  part(c, c:ellipse(40, 36, 3, 2), "#f4eee0"); fl(c, R(c, 42, 32, 43, 35), "#f4eee0"); fl(c, R(c, 43, 31, 45, 31), "#f4eee0"); fl(c, R(c, 46, 31, 46, 32), "#e8a317"); c:px(44, 31, INK)
  fl(c, R(c, 38, 38, 38, 38), "#e8a317"); fl(c, R(c, 41, 38, 41, 38), "#e8a317")
  part(c, R(c, 55, 33, 61, 36), "#a8703e"); part(c, c:ellipse(58, 38, 2, 2), "#5a3a22", { noline = true })
  fl(c, c:line({ { 44, 37 }, { 54, 35 } }, 1), "#5a3a22")
  -- gnome behind the wall with a chalk slate
  gnome(c, 11, 51, { d = 1, upper = true, s = 1.25, eyes = "open", arms = { arm({ 4, 7 }, { 8, 8 }, true, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  part(c, R(c, 17, 33, 28, 46), "#4a5058")
  for i = 0, 3 do fl(c, R(c, 19 + i * 2, 35, 19 + i * 2, 39), "#f4eee0") end
  fl(c, c:line({ { 18, 38 }, { 26, 36 } }, 1), "#f4eee0")
  for i = 0, 3 do fl(c, R(c, 19 + i * 2, 41, 19 + i * 2, 44), "#f4eee0") end
  fl(c, c:line({ { 18, 43 }, { 26, 41 } }, 1), "#f4eee0")
  fl(c, R(c, 15, 42, 17, 43), "#f0c8a0")
  part(c, R(c, 0, 46, W - 1, H - 1), "#9aa0a8")
  fl(c, R(c, 0, 46, W - 1, 46), "#c9ccd0")
  for y = 50, H - 1, 4 do fl(c, R(c, 0, y, W - 1, y), "#7a8088") end
  for x = 3, W - 1, 8 do fl(c, R(c, x, 47, x, 49), "#7a8088") end
  finish(c, "w5_count_carts")
end

-- w5_rain_gauge: grey downpour, gnome under a leaf reads the little brass cup on its stone post
function S.w5_rain_gauge()
  seed = 73
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#6f7f94", "#7f8da0", "#8d9bad", "#9ba8b8" }, { dir = "v" })
  for _, p in ipairs({ { 14, 8, 14 }, { 44, 6, 16 }, { 62, 12, 10 } }) do c:fill(c:ellipse(p[1], p[2], p[3], 4), "#59687c") end
  c:fill(c:ellipse(18, 38, 30, 7), "#5f7a66"); c:fill(c:ellipse(62, 38, 24, 6), "#56705e")
  stonewall(c, 0, 40, W - 1, H - 1, "#8b929c", "#6a727c")
  fl(c, R(c, 0, 40, W - 1, 41), "#a8aeb8")
  -- puddles on the slab
  for _, p in ipairs({ { 12, 44 }, { 42, 46 }, { 62, 44 } }) do c:fill(c:ellipse(p[1], p[2], 4, 1), "#6f8aa8") end
  -- stone post and the brass cup
  part(c, R(c, 47, 34, 56, 40), "#a8aeb8")
  part(c, R(c, 48, 22, 55, 34), "#e8a317")
  fl(c, R(c, 49, 22, 49, 34), "#f5cf6a")
  part(c, c:ellipse(51.5, 22, 4, 1), "#f5cf6a")
  c:fill(R(c, 49, 28, 54, 33), "#7ab8d8")
  for y = 24, 32, 2 do fl(c, R(c, 53, y, 54, y), "#8a5a1a") end
  c:fill(c:ellipse(51.5, 22, 3, 1), "#4a7aa0")
  -- gnome under a leaf, peering at the cup
  local _, G = gnome(c, 30, 40, { s = 1.25, d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 10 }, true), arm({ -4, 8 }, { -6, 19 }, false) } })
  local lx, ly = G.P(-6, 19)
  fl(c, c:line({ { lx, ly }, { lx + 2, ly - 4 } }, 1), "#4a6a2a")
  part(c, c:ellipse(lx + 4, ly - 5, 10, 3), "#4e9a48", { shade = true })
  fl(c, R(c, lx - 4, ly - 5, lx + 12, ly - 5), "#3f7a3a")
  -- rain
  seed = 77
  for i = 1, 46 do
    local x, y = 5 + floor(rand() * 64), 5 + floor(rand() * 44)
    if not (x >= lx - 6 and x <= lx + 14 and y >= ly - 8 and y <= 40 and false) then
      c:px(x, y, "#d8e4f0"); c:px(x - 1, y + 1, "#d8e4f0")
    end
  end
  finish(c, "w5_rain_gauge")
end

-- w5_hundred_rungs: dawn, gnome halfway up the endless ladder on the tower wall
function S.w5_hundred_rungs()
  seed = 74
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 36), { "#3b2f66", "#5a3f7a", "#8a4a88", "#c05a7c", "#e8825e", "#f4a868", "#f8c880" }, { dir = "v" })
  for _, p in ipairs({ { 38, 8 }, { 48, 6 }, { 60, 10 }, { 66, 18 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(c:ellipse(52, 36, 9, 9):clip(R(c, 0, 0, W, 35)), "#ffe08a")
  c:fill(c:ellipse(52, 36, 6, 6):clip(R(c, 0, 0, W, 35)), "#fff1c8")
  c:fill(c:ellipse(30, 38, 20, 5), "#6a3f7a"); c:fill(c:ellipse(66, 38, 16, 6), "#5a3a72")
  c:fill(R(c, 0, 37, W - 1, 49), "#4a4a6a")
  c:fill(c:ellipse(52, 43, 14, 2), "#6a7a8a")
  for i = 1, 10 do c:px(36 + floor(rand() * 30), 40 + floor(rand() * 8), "#7a8a9a") end
  -- the tower wall, left, with the ladder
  stonewall(c, 5, 5, 33, 49, "#9a8aa0", "#6a5a7a")
  c:fill(R(c, 31, 5, 33, 49), "#7a6a8a"); fl(c, R(c, 34, 5, 34, 49), INK)
  fl(c, R(c, 5, 5, 5, 49), "#b0a0b0")
  fl(c, R(c, 15, 5, 16, 49), "#6a5a7a"); fl(c, R(c, 25, 5, 26, 49), "#6a5a7a")
  part(c, R(c, 13, 5, 14, 49), "#a8703e", { noline = true }); part(c, R(c, 23, 5, 24, 49), "#a8703e", { noline = true })
  for y = 6, 49, 3 do fl(c, R(c, 13, y, 24, y), "#d9a660"); fl(c, R(c, 13, y + 1, 24, y + 1), "#8a5a35") end
  gnome(c, 19, 31, { d = 1, walk = 1, eyes = "open", arms = { arm({ -4, 8 }, { -5, 16 }, false), arm({ 4, 8 }, { 4, 19 }, true) } })
  for _, p in ipairs({ { 50, 22 }, { 40, 26 }, { 60, 26 } }) do c:px(p[1], p[2], "#ffe08a") end
  finish(c, "w5_hundred_rungs")
end

-- w5_lost_spectacles: the cartographer hunts everywhere; the specs sit on his hat. Gnome points.
function S.w5_lost_spectacles()
  seed = 75
  local c = new()
  stonewall(c, 0, 0, W - 1, 41, "#b0a08a", "#8a7c68")
  c:fill(R(c, 0, 41, W - 1, H - 1), "#7a4a2a")
  for y = 45, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#5e3a20") end
  -- small window
  part(c, R(c, 22, 6, 32, 17), "#a8d4e0"); fl(c, R(c, 27, 6, 27, 17), "#8a5a35"); fl(c, R(c, 22, 11, 32, 11), "#8a5a35")
  c:fill(R(c, 23, 7, 26, 9), "#f4eee0")
  -- the map with a sock-shaped coast
  part(c, R(c, 42, 6, 64, 24), "#e8d8a8")
  c:fill(R(c, 44, 8, 62, 22), "#bcdde4")
  c:fill(R(c, 50, 9, 54, 17), "#7ab55c"); c:fill(R(c, 50, 16, 59, 20), "#7ab55c"); c:fill(c:ellipse(58, 18, 2, 2), "#7ab55c")
  fl(c, R(c, 50, 9, 54, 10), "#dd3a2a")
  fl(c, R(c, 49, 9, 49, 20), "#8a5a2a"); fl(c, R(c, 55, 9, 55, 15), "#8a5a2a"); fl(c, R(c, 49, 21, 60, 21), "#8a5a2a")
  c:px(45, 10, "#dd3a2a"); c:px(46, 11, "#dd3a2a"); c:px(46, 10, "#dd3a2a")
  -- the desk
  part(c, R(c, 2, 41, 69, 49), "#8a5a35")
  fl(c, R(c, 2, 41, 69, 42), "#b07a45")
  for _, x in ipairs({ 18, 36, 54 }) do fl(c, R(c, x, 45, x, 48), "#5e2f1e") end
  -- cartographer with specs on his hat (behind the desk)
  local _, G = gnome(c, 15, 45, { d = 1, upper = true, s = 1.25, hat = "#3f6fb0", eyes = "open", arms = { arm({ 4, 6 }, { 8, 8 }, true), arm({ -4, 6 }, { -6, 5 }, true) } })
  for _, dx in ipairs({ -2, 3 }) do
    local sx, sy = G.P(dx, 16)
    fl(c, R(c, sx - 1, sy - 1, sx + 2, sy + 2), "#2a1a10"); fl(c, R(c, sx, sy, sx + 1, sy + 1), "#d8f0f8")
  end
  local ax, ay = G.P(-2, 16); local bx, by = G.P(3, 16)
  fl(c, R(c, ax + 2, ay, bx - 1, ay), "#2a1a10")
    -- parchment and quill on the desk
  part(c, R(c, 6, 39, 24, 41), "#f4eee0"); fl(c, c:line({ { 20, 38 }, { 24, 33 } }, 1), "#f4eee0")
  -- the gnome pointing at the hat
  gnome(c, 36, 45, { d = -1, upper = true, s = 1.25, eyes = "happy", arms = { arm({ -4, 7 }, { -11, 15 }, true) } })
  finish(c, "w5_lost_spectacles")
end

-- w5_pigeon_post: gnome on the tower top releases the grey pigeon with a note, towards the far village
function S.w5_pigeon_post()
  seed = 76
  local c = new()
  skyv(c, 34, nil, { { 50, 9 }, { 14, 14 } })
  c:fill(c:ellipse(48, 36, 26, 7), "#6e9a4e"); c:fill(c:ellipse(66, 38, 14, 6), "#5e8a44")
  c:fill(R(c, 36, 38, W - 1, H - 1), "#7ea85a")
  for y = 42, 48, 3 do fl(c, R(c, 38, y, W - 1, y), "#628a44") end
  for x = 40, 66, 4 do for y = 43, 48, 3 do c:px(x, y, "#e8d8f0"); c:px(x, y - 1, "#4e9a48") end end
  -- village
  for _, h in ipairs({ { 50, 34, 5 }, { 58, 32, 6 }, { 65, 35, 4 } }) do
    part(c, R(c, h[1], h[2], h[1] + h[3], h[2] + 3), "#e8d8a8")
    part(c, c:poly({ { h[1] - 1, h[2] }, { h[1] + h[3] + 1, h[2] }, { h[1] + h[3] / 2, h[2] - 3 } }), "#c0442e")
  end
  -- stone tower top at left
  stonewall(c, 5, 38, 34, 49, "#9aa0a8", "#7a8088")
  fl(c, R(c, 5, 38, 34, 38), "#c9ccd0")
  for _, x in ipairs({ 6, 17, 28 }) do part(c, R(c, x, 33, x + 5, 38), "#9aa0a8") end
  local _, G = gnome(c, 22, 38, { d = 1, eyes = "happy", arms = { arm({ 4, 8 }, { 9, 17 }, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  -- pigeon in flight, note tied to its leg
  local px, py = 40, 15
  part(c, c:ellipse(px, py, 4, 2), "#aeb4bc", { shade = true })
  part(c, c:poly({ { px - 2, py - 1 }, { px + 1, py - 7 }, { px + 3, py - 1 } }), "#8b929c")
  part(c, c:poly({ { px - 6, py + 1 }, { px - 3, py }, { px - 3, py + 2 } }), "#8b929c")
  part(c, c:ellipse(px + 5, py - 1, 2, 2), "#aeb4bc"); fl(c, R(c, px + 7, py - 1, px + 8, py - 1), "#e8a317"); c:px(px + 5, py - 2, INK)
  c:px(px + 1, py + 3, "#dd3a2a")
  part(c, R(c, px, py + 4, px + 2, py + 6), "#f4eee0")
  for _, p in ipairs({ { 32, 22 }, { 34, 20 }, { 29, 25 } }) do c:px(p[1], p[2], "#f4eee0") end
  finish(c, "w5_pigeon_post")
end

-- w5_sift_beacon_ash: shaking a sieve over a basket in front of the cold iron beacon
function S.w5_sift_beacon_ash()
  seed = 77
  local c = new()
  skyv(c, 34, { "#b8d4e0", "#c8dce4", "#dae6e8" }, { { 14, 10 }, { 52, 8 } })
  c:fill(c:ellipse(20, 36, 28, 7), "#6e9a4e"); c:fill(c:ellipse(62, 36, 22, 6), "#5e8a44")
  c:fill(R(c, 0, 35, W - 1, H - 1), "#9aa0a8")
  for y = 38, 50, 5 do fl(c, R(c, 0, y, W - 1, y), "#7a8088") end
  for x = 4, W - 1, 16 do fl(c, R(c, x, 36, x, 40), "#7a8088"); fl(c, R(c, x + 8, 43, x + 8, 47), "#7a8088") end
  -- the beacon: iron basket on a post, cold
  part(c, R(c, 58, 24, 60, 38), "#3a3f48", { noline = true })
  part(c, c:poly({ { 51, 11 }, { 67, 11 }, { 63, 24 }, { 55, 24 } }), "#4a4f58")
  for _, x in ipairs({ 55, 59, 63 }) do fl(c, c:line({ { x, 12 }, { x - 1 + (x - 59) // 4 * -1, 23 } }, 1), "#2a2e36") end
  part(c, c:ellipse(59, 11, 8, 2), "#c8ccd0")
  c:fill(c:ellipse(59, 10, 6, 1), "#9aa0a8")
  for _, p in ipairs({ { 55, 10 }, { 58, 9 }, { 62, 10 }, { 60, 11 } }) do c:px(p[1], p[2], "#2a2e36") end
  fl(c, R(c, 56, 13, 56, 18), "#6a6f78"); fl(c, R(c, 62, 14, 62, 19), "#6a6f78")
  -- basket on the floor
  part(c, c:ellipse(25, 44, 8, 4), "#c08a52", { shade = true })
  c:fill(c:ellipse(25, 42, 7, 2), "#c8ccd0")
  for _, x in ipairs({ 20, 23, 26, 29 }) do fl(c, R(c, x, 44, x, 47), "#8a5a35") end
  -- gnome facing left, sieve in front
  local _, G = gnome(c, 41, 44, { d = -1, eyes = "shut", arms = { arm({ -4, 8 }, { -9, 9 }, true), arm({ -4, 7 }, { -8, 7 }, true) } })
  part(c, c:ellipse(30, 34, 6, 2), "#a8703e")
  c:fill(c:ellipse(30, 34, 5, 1), "#7a7f88")
  for _, x in ipairs({ 27, 30, 33 }) do c:px(x, 33, "#2a2e36") end
  c:px(29, 32, "#2a2e36"); c:px(32, 32, "#4a4f58"); c:px(31, 34, "#2a2e36")
  -- falling ash, puffs, grey smudges on the beard
  for _, p in ipairs({ { 26, 37 }, { 28, 39 }, { 30, 38 }, { 32, 40 }, { 27, 41 }, { 31, 36 }, { 34, 38 }, { 29, 40 } }) do c:px(p[1], p[2], "#d8dce0") end
  for _, p in ipairs({ { 22, 33 }, { 20, 36 }, { 36, 29 }, { 38, 31 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#d8dce0") end
  for _, d in ipairs({ { -2, 4 }, { 0, 6 }, { 2, 5 } }) do local gx, gy = G.P(d[1], d[2]); c:px(gx, gy, "#9aa0a8") end
  finish(c, "w5_sift_beacon_ash")
end

-- w5_watchers_cocoa: stirring cocoa in a pan on the little iron stove
function S.w5_watchers_cocoa()
  seed = 78
  local c = new()
  skyv(c, 26, { "#b8d4e0", "#c8dce4", "#dae6e8" }, { { 54, 9 } })
  for _, y in ipairs({ 12, 17 }) do fl(c, R(c, 8, y, 16, y), "#f4f8fa"); c:px(17, y - 1, "#f4f8fa"); fl(c, R(c, 56, y + 2, 63, y + 2), "#f4f8fa"); c:px(64, y + 1, "#f4f8fa") end
  parapet(c, 24, "#9aa0a8", "#7a8088")
  c:fill(R(c, 0, 38, W - 1, H - 1), "#8a5a35")
  for y = 42, 50, 4 do fl(c, R(c, 0, y, W - 1, y), "#6b3b2a") end
  fl(c, R(c, 0, 38, W - 1, 38), "#b07a45")
  -- stove, chimney, pan
  part(c, R(c, 41, 14, 43, 30), "#4a4f58", { noline = true })
  part(c, R(c, 40, 13, 44, 14), "#3a3f48")
  for i = 0, 3 do fl(c, c:ellipse(46 + (i % 2) * 2, 10 - i * 3, 2, 1), "#f4f8fa") end
  part(c, R(c, 33, 29, 50, 38), "#4a4f58")
  fl(c, R(c, 33, 29, 50, 30), "#6a707a")
  part(c, R(c, 38, 32, 46, 36), "#f08a24"); c:fill(R(c, 40, 34, 44, 36), "#ffd86a")
  fl(c, R(c, 34, 39, 35, 40), "#3a3f48"); fl(c, R(c, 48, 39, 49, 40), "#3a3f48")
  part(c, R(c, 35, 24, 47, 28), "#2f333a")
  c:fill(R(c, 36, 25, 46, 26), "#6b3b2a"); fl(c, R(c, 38, 25, 40, 25), "#e8c48a"); fl(c, R(c, 43, 25, 44, 25), "#e8c48a")
  fl(c, R(c, 30, 26, 35, 26), "#2f333a")
  -- gnome with a scarf stirs with a long spoon
  local _, G = gnome(c, 20, 47, { d = 1, eyes = "happy", arms = { arm({ 4, 8 }, { 8, 11 }, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  fl(c, R(c, 17, 38, 23, 38), "#e8742a"); fl(c, R(c, 17, 39, 23, 39), "#f5cf6a"); fl(c, R(c, 23, 39, 24, 43), "#e8742a")
  fl(c, c:line({ { 29, 36 }, { 41, 24 } }, 1), "#d9a660")
  -- crate with milk jug, cacao pods and a steaming mug
  part(c, R(c, 55, 38, 68, 48), "#a8703e"); fl(c, R(c, 55, 43, 68, 43), "#8a5a35")
  part(c, R(c, 57, 28, 60, 37), "#f4eee0"); fl(c, R(c, 57, 29, 60, 29), "#8fc4dc"); fl(c, R(c, 58, 27, 59, 27), "#8a5a35")
  for i = 0, 1 do part(c, c:ellipse(62 + i * 4, 36, 2, 1), "#6b3b2a", { noline = true }) end
  part(c, c:ellipse(63, 33, 2, 1), "#6b3b2a", { noline = true })
  part(c, R(c, 62, 32, 66, 34), "#c0442e"); fl(c, R(c, 63, 32, 65, 32), "#6b3b2a")
  for i, y in ipairs({ 29, 26, 23 }) do fl(c, R(c, 63 + (i % 2), y, 64 + (i % 2), y + 1), "#f4f8fa") end
  finish(c, "w5_watchers_cocoa")
end

-- w5_wind_harp: gnome plucks the strung frame hanging from a beam in the wind
function S.w5_wind_harp()
  seed = 79
  local c = new()
  skyv(c, 38, { "#a8cce0", "#bcd8e8", "#d0e6ee" }, { { 56, 40 - 30 }, { 12, 10 } })
  parapet(c, 38, "#9aa0a8", "#7a8088")
  part(c, R(c, 33, 10, 34, 38), "#6b4a2e", { noline = true }); part(c, R(c, 60, 10, 61, 38), "#6b4a2e", { noline = true })
  part(c, R(c, 31, 9, 63, 11), "#8a5a35")
  fl(c, c:line({ { 38, 12 }, { 38, 15 } }, 1), "#e0c88a"); fl(c, c:line({ { 55, 12 }, { 55, 15 } }, 1), "#e0c88a")
  -- harp frame: wooden bars, silk strings
  part(c, R(c, 37, 15, 56, 17), "#a8703e")
  part(c, R(c, 37, 17, 38, 33), "#a8703e", { noline = true }); part(c, R(c, 55, 17, 56, 33), "#a8703e", { noline = true })
  part(c, R(c, 37, 33, 56, 35), "#a8703e")
  for i = 0, 6 do
    local x = 40 + i * 2 + ((i % 2 == 0) and 0 or 0)
    fl(c, R(c, x + ((i == 2 or i == 3) and 1 or 0), 18, x + ((i == 2 or i == 3) and 1 or 0), 32), "#f4eee0")
  end
  -- wind swirls
  for _, w in ipairs({ { 6, 20 }, { 6, 27 }, { 64, 19 }, { 62, 26 } }) do
    fl(c, R(c, w[1], w[2], w[1] + 7, w[2]), "#f4f8fa"); c:px(w[1] + 8, w[2] - 1, "#f4f8fa"); c:px(w[1] + 9, w[2] - 2, "#f4f8fa"); c:px(w[1] + 7, w[2] - 1, "#f4f8fa")
  end
  -- music notes
  for _, p in ipairs({ { 46, 6 }, { 51, 3 } }) do
    fl(c, R(c, p[1] + 2, p[2], p[1] + 2, p[2] + 4), "#2a1a10"); fl(c, R(c, p[1], p[2] + 4, p[1] + 1, p[2] + 5), "#2a1a10")
  end
  local _, G = gnome(c, 25, 38, { d = 1, eyes = "happy", arms = { arm({ 4, 8 }, { 9, 12 }, true), arm({ -4, 7 }, { -6, 4 }, false) } })
  -- spool of silk thread in the back hand
  local sx, sy = G.P(-6, 4)
  part(c, R(c, sx - 2, sy - 2, sx + 1, sy + 1), "#f4eee0"); fl(c, R(c, sx - 2, sy - 2, sx + 1, sy - 2), "#8a5a35"); fl(c, R(c, sx - 2, sy + 1, sx + 1, sy + 1), "#8a5a35")
  finish(c, "w5_wind_harp")
end

local order = { "w4_passenger_hats", "w4_lost_ticket", "w4_loose_plank", "w4_chain_winch", "w4_strange_fares", "w4_toll_ledger",
  "w5_weathervane_oil", "w5_count_carts", "w5_rain_gauge", "w5_hundred_rungs", "w5_lost_spectacles", "w5_pigeon_post",
  "w5_sift_beacon_ash", "w5_watchers_cocoa", "w5_wind_harp" }
for _, s2 in ipairs(order) do
  if S[s2] and (not only or only == s2) then seed = 7; S[s2]() end
end
