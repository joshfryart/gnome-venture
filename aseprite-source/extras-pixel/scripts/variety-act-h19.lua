-- variety-act-h19.lua : regional rest-stop scenes (group h19) -> act-<slug>.png (144x108, drawn 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-h19.lua
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

---------------------------------------------------------------- h19 helpers
local WD, WL, WD2 = "#8a5a35", "#b07a45", "#d9a660"
local function steam(c, x, y, n, col)
  for i = 0, n - 1 do fl(c, R(c, x + (i % 2), y - i * 3, x + (i % 2) + 1, y - i * 3 + 1), col or "#f4f8fa") end
end
local function palm(c, x, yb, h, lean, big)
  local tx, ty = x + lean, yb - h
  part(c, c:line({ { x, yb }, { x + floor(lean * 0.3), yb - floor(h * 0.5) }, { tx, ty } }, 2), "#8a6a44", { noline = true })
  for i = 1, 3 do fl(c, R(c, x + floor(lean * i / 4), yb - floor(h * i / 4), x + floor(lean * i / 4), yb - floor(h * i / 4)), "#6b4a2e") end
  local m = c:mask()
  local L = big and 11 or 8
  for _, dx in ipairs({ -L, -floor(L * 0.6), floor(L * 0.6), L }) do
    m:add(c:line({ { tx, ty }, { tx + floor(dx * 0.5), ty - 3 }, { tx + dx, ty + 3 } }, 2))
  end
  m:add(c:line({ { tx, ty }, { tx - 1, ty - 4 }, { tx + 1, ty - 6 } }, 2))
  part(c, m, "#3f8a42")
  fl(c, R(c, tx - 1, ty + 1, tx, ty + 2), "#8a4f2a")
  c:px(tx + floor(L * 0.5), ty - 2, "#7ab55c"); c:px(tx - floor(L * 0.5), ty - 2, "#7ab55c")
end
local function rain(c, n, x0, y0, x1, y1, col)
  for i = 1, n do
    local x, y = x0 + floor(rand() * (x1 - x0)), y0 + floor(rand() * (y1 - y0))
    c:px(x, y, col or "#d8e8f0"); c:px(x - 1, y + 1, col or "#d8e8f0")
  end
end
local function stars(c, pts, col)
  for _, p in ipairs(pts) do c:px(p[1], p[2], col or "#f4eee0") end
end
local function spark(c, x, y, a, b)
  c:px(x, y, a or "#fff1c8"); c:px(x - 1, y, b or "#f5cf6a"); c:px(x + 1, y, b or "#f5cf6a"); c:px(x, y - 1, b or "#f5cf6a"); c:px(x, y + 1, b or "#f5cf6a")
end
local function water(c, y0, cols) c:bands(R(c, 0, y0, W - 1, H - 1), cols, { dir = "v" }) end
local function bush(c, x, y, rx, ry, col) part(c, c:ellipse(x, y, rx, ry), col or "#4e8a3c", { shade = true }) end
local function leafdiamond(c, cx, y0, col, w)
  w = w or 4
  part(c, c:poly({ { cx, y0 }, { cx + w, y0 + 3 }, { cx, y0 + 6 }, { cx - w, y0 + 3 } }), col or "#4e9a48")
  fl(c, R(c, cx, y0 + 1, cx, y0 + 5), "#e8c48a"); fl(c, R(c, cx - w + 2, y0 + 3, cx + w - 2, y0 + 3), "#e8c48a")
end

---------------------------------------------------------------- scenes (SEA)
local S = {}

function S.r_sea_leaf_parcels()
  seed = 61
  local c = new()
  day(c, 33, { cloud = 20, sky = { "#b8dcc8", "#c8e4cc", "#d8ecd0" }, hill = "#4e8a3c", hill2 = "#3f7a38" })
  palm(c, 8, 34, 22, 4, true)
  -- thatch awning on two posts
  part(c, R(c, 28, 14, 29, 36), WD, { noline = true }); part(c, R(c, 66, 14, 67, 36), WD, { noline = true })
  local aw = c:poly({ { 24, 18 }, { 32, 9 }, { 64, 9 }, { 71, 18 } })
  part(c, aw, "#c9a96e")
  for x = 27, 68, 4 do fl(c, R(c, x, 12, x, 17), "#a8863e") end
  fl(c, R(c, 25, 17, 70, 17), "#b8965c")
  -- table
  part(c, R(c, 25, 36, 69, 39), WL); fl(c, R(c, 26, 36, 68, 36), WD2)
  part(c, R(c, 28, 40, 30, 48), WD, { noline = true }); part(c, R(c, 63, 40, 65, 48), WD, { noline = true })
  fl(c, R(c, 28, 43, 65, 43), "#6b3b2a")
  -- four parcels in a row, one with a peek of sugar
  for i, x in ipairs({ 33, 42, 51, 60 }) do leafdiamond(c, x, 29, (i == 3) and "#5aa64e" or "#4e9a48", 4) end
  c:px(51, 31, "#c8802a"); c:px(52, 31, "#f4eee0")
  -- steamer basket at the end
  part(c, c:ellipse(60, 24, 4, 1), "#d9a660")
  steam(c, 59, 22, 3)
  -- gnome: chin in hand, pondering
  local _, G = gnome(c, 15, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 7 }, { 9, 10 }, true) } })
  -- thought dots
  fl(c, R(c, 22, 24, 23, 25), "#f4eee0"); fl(c, R(c, 24, 20, 26, 22), "#f4eee0")
  finish(c, "r_sea_leaf_parcels")
end

function S.r_sea_lily_frog()
  seed = 62
  local c = new()
  day(c, 22, { cloud = 50, sky = { "#b8dcc8", "#c8e4cc", "#d8ecd0" }, hill = "#3f7a38", hill2 = "#4e8a3c", grass = "#5e9a48" })
  water(c, 24, { "#58b4c4", "#4aa4b8", "#3f94ac" })
  for i = 0, 5 do fl(c, R(c, 8 + i * 11, 26 + (i % 2) * 4, 12 + i * 11, 26 + (i % 2) * 4), "#7ccfd4") end
  -- reeds
  for _, x in ipairs({ 36, 40, 63 }) do part(c, R(c, x, 14, x, 24), "#5e8a44", { noline = true }); fl(c, R(c, x - 1, 13, x, 16), "#8a4f2a") end
  -- bank
  part(c, c:ellipse(10, 50, 22, 11), "#7ea85a", { shade = true })
  c:fill(c:ellipse(10, 49, 20, 9), "#7ea85a")
  local function pad(x, y, col)
    part(c, c:ellipse(x, y, 7, 3), col or "#3f8a42", { shade = true })
    fl(c, R(c, x - 2, y - 1, x + 2, y - 1), "#7ab55c")
    c:px(x + 4, y + 1, "#58b4c4"); c:px(x + 5, y + 1, "#58b4c4"); c:px(x + 4, y, "#58b4c4")
  end
  pad(32, 31); pad(48, 29); pad(62, 36); pad(36, 42); pad(54, 45)
  -- lotus bloom
  part(c, c:ellipse(30, 29, 2, 2), "#e46a9b"); c:px(30, 28, "#f6b8cf")
  -- frog peeking out from under the right pad
  part(c, c:ellipse(56, 39, 4, 3), "#6bc04a"); c:fill(R(c, 53, 36, 54, 37), "#f4eee0"); c:fill(R(c, 58, 36, 59, 37), "#f4eee0")
  c:px(54, 37, INK); c:px(59, 37, INK)
  c:fill(R(c, 55, 40, 57, 40), "#e0501f")
  -- gnome on the bank, pointing
  gnome(c, 13, 43, { d = 1, sit = true, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 7 }, { 11, 9 }, true) } })
  finish(c, "r_sea_lily_frog")
end

function S.r_sea_cave_breeze()
  seed = 63
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 49), { "#1c2238", "#222a42", "#2a3450" }, { dir = "v" })
  c:fill(R(c, 0, 40, W - 1, H - 1), "#3a3a4e"); c:fill(R(c, 0, 40, W - 1, 40), "#4e4e64")
  -- three tunnel mouths
  local function arch(x, lit)
    local m = c:ellipse(x, 24, 8, 8); m:add(R(c, x - 8, 24, x + 7, 40))
    part(c, m, "#0e1220", { shade = false })
    if lit then
      local lm = c:ellipse(x, 25, 5, 6); lm:add(R(c, x - 5, 25, x + 4, 40))
      c:fill(lm, "#a8d4e0")
      local lm2 = c:ellipse(x, 26, 3, 4); lm2:add(R(c, x - 3, 26, x + 2, 40))
      c:fill(lm2, "#e0f2ea")
      fl(c, R(c, x - 5, 37, x + 4, 40), "#5e9a48")
    end
  end
  arch(14, false); arch(36, false); arch(58, true)
  -- stalactites and stalagmites
  for _, x in ipairs({ 6, 22, 28, 46, 52, 66 }) do
    c:fill(c:poly({ { x - 2, 5 }, { x + 2, 5 }, { x, 10 + (x % 5) } }), "#4a4e66")
  end
  for _, x in ipairs({ 24, 47, 67 }) do part(c, c:poly({ { x - 2, 44 }, { x + 2, 44 }, { x, 38 } }), "#4a4e66") end
  -- breeze lines from the right tunnel
  for _, p in ipairs({ { 50, 30, 5 }, { 47, 35, 7 }, { 50, 38, 5 } }) do
    local x, y, n = p[1], p[2], p[3]
    for i = 0, n do c:px(x - i, y + ((i % 3 == 1) and -1 or 0), "#d8f0f4") end
  end
  -- fireflies
  for _, p in ipairs({ { 10, 14 }, { 20, 20 }, { 31, 12 }, { 42, 18 }, { 8, 30 }, { 28, 30 }, { 64, 12 }, { 40, 30 } }) do
    c:px(p[1], p[2], "#f5e66a"); c:px(p[1] + 1, p[2], "#9ab84a")
  end
  gnome(c, 36, 47, { d = 1, s = 1.25, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 7, 15 }, true) } })
  spark(c, 66, 18, "#f5e66a", "#9ab84a")
  finish(c, "r_sea_cave_breeze")
end

function S.r_sea_rabbit_grater()
  seed = 64
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#d9bc84")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 0, x, 38), "#c9a96e") end
  fl(c, R(c, 0, 12, W - 1, 12), "#8a5a35")
  c:fill(R(c, 0, 39, W - 1, H - 1), "#a8703e")
  for y = 43, 52, 5 do fl(c, R(c, 0, y, W - 1, y), "#8a5a35") end
  -- shelf with coconuts and a window of palm green
  part(c, R(c, 5, 22, 20, 23), WD)
  for _, x in ipairs({ 8, 13, 18 }) do part(c, c:ellipse(x, 20, 2, 2), "#6b4a2e"); c:px(x, 19, "#a8703e") end
  part(c, R(c, 52, 14, 66, 26), "#a8d4c0"); fl(c, R(c, 59, 14, 59, 26), WD); fl(c, R(c, 52, 20, 66, 20), WD)
  -- the rabbit stool
  part(c, R(c, 19, 43, 21, 48), "#a8703e", { noline = true }); part(c, R(c, 40, 43, 42, 48), "#a8703e", { noline = true })
  part(c, R(c, 27, 44, 28, 48), "#8a5a35", { noline = true }); part(c, R(c, 34, 44, 35, 48), "#8a5a35", { noline = true })
  part(c, c:ellipse(30, 41, 13, 5), "#c08a52", { shade = true })
  part(c, c:ellipse(47, 37, 5, 4), "#c08a52", { shade = true })
  part(c, c:ellipse(45, 29, 1.5, 4), "#c08a52"); part(c, c:ellipse(50, 29, 1.5, 4), "#c08a52")
  fl(c, R(c, 45, 28, 45, 31), "#e8a8a0"); fl(c, R(c, 50, 28, 50, 31), "#e8a8a0")
  c:px(49, 36, INK); c:px(52, 38, "#e08a7a")
  part(c, c:ellipse(17, 40, 3, 3), "#f4eee0")
  -- blade tongue
  part(c, R(c, 51, 39, 59, 40), "#aeb4bc")
  for x = 52, 58, 2 do c:px(x, 41, "#8b929c") end
  -- gnome seated astride, coconut half scraped on the blade
  local _, G = gnome(c, 31, 38, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 11, 6 }, true, true), arm({ -3, 8 }, { 10, 5 }, false, true) } })
  part(c, c:ellipse(54, 36, 4, 3), "#6b4a2e"); c:fill(R(c, 51, 37, 57, 37), "#f4eee0")
  fl(c, R(c, 41, 31, 43, 33), "#f0c8a0"); fl(c, R(c, 47, 34, 49, 36), "#f0c8a0")
  -- shavings falling into a basket
  for _, p in ipairs({ { 55, 41 }, { 57, 43 }, { 54, 44 } }) do c:px(p[1], p[2], "#f4f8fa") end
  part(c, c:ellipse(57, 47, 6, 2), "#c9a96e"); c:fill(R(c, 52, 46, 62, 46), "#f4f8fa")
  finish(c, "r_sea_rabbit_grater")
end

function S.r_sea_pole_raft()
  seed = 65
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 24), { "#a8d4e0", "#bcdde4", "#d0e8e6" }, { dir = "v" })
  c:fill(c:ellipse(60, 12, 4, 4), "#fdf2c0")
  water(c, 24, { "#58b4c4", "#4aa4b8", "#3f94ac", "#3a88a4" })
  -- far shore with palms
  c:fill(c:ellipse(14, 25, 20, 3), "#4e8a3c"); c:fill(c:ellipse(62, 25, 18, 3), "#3f7a38")
  palm(c, 8, 26, 12, 3); palm(c, 58, 26, 10, -3)
  for i = 0, 5 do fl(c, R(c, 6 + i * 11, 29 + (i % 3) * 5, 10 + i * 11, 29 + (i % 3) * 5), "#7ccfd4") end
  -- sandbar under the raft
  part(c, c:ellipse(34, 43, 29, 5), "#e8d2a0", { shade = true })
  c:fill(c:ellipse(34, 42, 25, 3), "#f0dcae")
  -- bamboo raft
  part(c, R(c, 18, 38, 50, 42), "#c8b850")
  for x = 20, 49, 4 do fl(c, R(c, x, 38, x, 42), "#8a7a2a") end
  for y = 40, 40 do fl(c, R(c, 19, y, 49, y), "#a89a3a") end
  c:fill(R(c, 18, 38, 50, 38), "#e0d070")
  -- gnome leaning on the pole
  local _, G = gnome(c, 30, 38, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 7, 10 }, true), arm({ -3, 8 }, { 3, 4 }, false) } })
  part(c, c:line({ { 34, 20 }, { 48, 46 } }, 2), "#d8c860", { noline = false })
  fl(c, R(c, 37, 29, 37, 29), "#8a7a2a")
  fl(c, R(c, 36, 25, 37, 26), "#8a7a2a"); fl(c, R(c, 42, 36, 43, 37), "#8a7a2a")
  -- splash and sweat
  c:px(49, 47, "#f4f8fa"); c:px(51, 46, "#f4f8fa"); c:px(47, 47, "#a8e6e6")
  c:px(58, 38, "#f4f8fa"); c:px(60, 40, "#f4f8fa")
  finish(c, "r_sea_pole_raft")
end

function S.r_sea_lantern_river()
  seed = 66
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#3b2f66", "#4e3a78", "#7a4a88", "#b45a7c", "#e8825e", "#f0a868" }, { dir = "v" })
  stars(c, { { 8, 7 }, { 22, 6 }, { 38, 9 }, { 58, 6 }, { 66, 12 } })
  c:fill(c:ellipse(14, 29, 24, 6), "#2f2a58"); c:fill(c:ellipse(60, 29, 22, 5), "#352c5c")
  water(c, 29, { "#4a3a78", "#3f3470", "#342c66", "#2c265a" })
  for i = 0, 5 do fl(c, R(c, 6 + i * 11, 32 + (i % 3) * 4, 11 + i * 11, 32 + (i % 3) * 4), "#6a5898") end
  -- floating lanterns with glow reflections
  local function lan(x, y, col)
    part(c, R(c, x, y, x + 3, y + 3), col or "#ffd86a", { shade = false })
    c:px(x + 1, y + 1, "#fff1c8"); c:px(x + 2, y + 1, "#fff1c8")
    fl(c, R(c, x, y + 4, x + 3, y + 4), "#8a5a2a")
    fl(c, R(c, x + 1, y + 5, x + 2, y + 5), "#b8864a")
  end
  lan(38, 33); lan(52, 36); lan(30, 34, "#f08a4a"); lan(60, 31, "#f08a4a"); lan(46, 43)
  -- reeds on the far bank with a snagged old lantern
  for _, x in ipairs({ 64, 66, 68 }) do fl(c, R(c, x, 22, x, 30), "#3a5a42") end
  lan(61, 27, "#d9a050")
  -- jetty
  part(c, R(c, 0, 41, 24, 44), WL); fl(c, R(c, 0, 41, 24, 41), WD2)
  for _, x in ipairs({ 4, 12, 20 }) do part(c, R(c, x, 45, x + 1, 52), WD, { noline = true }) end
  gnome(c, 14, 40, { d = 1, sit = true, eyes = "open", arms = { arm({ -3, 6 }, { -4, 3 }, false), arm({ 4, 7 }, { 12, 12 }, true) } })
  -- a little lantern bubble: story
  part(c, R(c, 25, 16, 31, 22), "#f4eee0"); c:fill(R(c, 27, 18, 29, 20), "#f5cf6a"); c:fill(c:poly({ { 23, 24 }, { 26, 22 }, { 27, 22 } }), "#f4eee0")
  finish(c, "r_sea_lantern_river")
end

function S.r_sea_dragonlizard()
  seed = 67
  local c = new()
  day(c, 30, { cloud = 14, sky = { "#b8dcc8", "#c8e4cc", "#e0ecc8" }, hill = "#4e8a3c", hill2 = "#3f7a38", grass = "#6a9a48" })
  -- distant warm rock + lizard
  part(c, c:ellipse(52, 27, 17, 6), "#b88a60", { shade = true })
  c:fill(c:ellipse(52, 25, 13, 3), "#d9aa78")
  part(c, c:ellipse(53, 22, 9, 3), "#4e8a42")
  part(c, c:poly({ { 60, 20 }, { 70, 23 }, { 60, 24 } }), "#4e8a42")
  part(c, c:ellipse(43, 23, 4, 2.5), "#4e8a42"); c:px(42, 22, INK)
  for x = 48, 58, 3 do c:px(x, 19, "#3a6a32") end
  fl(c, R(c, 45, 25, 47, 25), "#d9aa78")
  -- sleepy bubbles
  for _, p in ipairs({ { 41, 17, 1 }, { 39, 12, 2 }, { 36, 7, 3 } }) do part(c, c:ellipse(p[1], p[2], p[3], p[3]), "#f4eee0", { noline = true }) end
  -- the tower platform
  part(c, R(c, 0, 40, W - 1, 44), WL); fl(c, R(c, 0, 40, W - 1, 40), WD2)
  for x = 4, 70, 8 do fl(c, R(c, x, 41, x, 44), WD) end
  for _, x in ipairs({ 4, 30, 66 }) do part(c, R(c, x, 33, x + 1, 40), WD, { noline = true }) end
  part(c, R(c, 3, 32, 68, 33), WD2)
  part(c, R(c, 0, 45, W - 1, H - 1), "#6b4a2e")
  for x = 6, 70, 12 do fl(c, R(c, x, 46, x, 49), "#4a2c1a") end
  gnome(c, 18, 41, { d = 1, s = 1.25, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 9 }, { 7, 13 }, true) } })
  finish(c, "r_sea_dragonlizard")
end

function S.r_sea_root_whispers()
  seed = 68
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 49), { "#6a9a58", "#5e8a48", "#4e7a3c", "#436e36" }, { dir = "v" })
  -- sunbeams
  for _, x in ipairs({ 14, 30 }) do c:fill(c:poly({ { x, 5 }, { x + 4, 5 }, { x + 16, 49 }, { x + 8, 49 } }), "#7aaa60") end
  -- hanging roots / lianas
  for _, x in ipairs({ 10, 24, 44, 52, 64 }) do part(c, R(c, x, 5, x, 14 + (x % 7) * 2), "#7a5a3a", { noline = true }) end
  -- the great fig: trunk + root bench
  part(c, R(c, 40, 5, 66, 36), "#6b4a2e")
  for _, x in ipairs({ 44, 50, 56, 62 }) do fl(c, R(c, x, 6, x, 34), "#5a3a22") end
  local root = c:mask()
  root:add(c:ellipse(22, 44, 26, 7)); root:add(c:ellipse(46, 40, 16, 8))
  part(c, root, "#7a5a3a", { shade = true })
  c:fill(c:ellipse(24, 40, 20, 3), "#8a6a46")
  part(c, c:ellipse(18, 45, 10, 2), "#5a3a22", { noline = true })
  c:fill(R(c, 0, 47, W - 1, H - 1), "#4e7a3c")
  -- listeners: keeper (white hat? green) and the gnome
  gnome(c, 32, 39, { d = -1, sit = true, hat = "#4f9a45", eyes = "open", arms = { arm({ 3, 8 }, { 7, 12 }, true) } })
  gnome(c, 11, 40, { d = 1, sit = true, eyes = "shut", arms = { arm({ -3, 6 }, { -4, 3 }, false) } })
  -- leaf swirls of whisper
  for _, p in ipairs({ { 20, 17 }, { 24, 12 }, { 16, 10 } }) do
    part(c, c:ellipse(p[1], p[2], 2, 1), "#a8d060", { noline = true }); c:px(p[1] + 2, p[2] + 1, "#a8d060")
  end
  finish(c, "r_sea_root_whispers")
end

function S.r_sea_rain_hammock()
  seed = 69
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 49), { "#8a9a9c", "#7a8a8c", "#6a7c80", "#5e7274" }, { dir = "v" })
  c:fill(c:ellipse(10, 34, 24, 8), "#4e6a50"); c:fill(c:ellipse(62, 33, 22, 7), "#46604a")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#58704a")
  c:fill(R(c, 0, 36, W - 1, 36), "#6a8458")
  c:fill(R(c, 0, 46, W - 1, H - 1), "#3f5a4a")
  for _, p in ipairs({ { 12, 47 }, { 30, 49 }, { 56, 48 } }) do c:fill(c:ellipse(p[1], p[2], 5, 1), "#7a9aa0") end
  -- posts and palm-leaf roof
  part(c, R(c, 10, 18, 12, 46), WD, { noline = true }); part(c, R(c, 60, 18, 62, 46), WD, { noline = true })
  local roof = c:mask()
  roof:add(c:poly({ { 5, 22 }, { 36, 6 }, { 67, 22 } }))
  part(c, roof, "#5e8a44")
  for i = 0, 9 do fl(c, R(c, 8 + i * 6, 15 - math.abs(5 - i) * 0 + (i < 5 and (4 - i) * 0 or 0), 8 + i * 6, 19), "#3f6a32") end
  for x = 8, 64, 4 do c:px(x, 21, "#4a7a38"); c:px(x + 1, 20, "#3f6a32") end
  fl(c, R(c, 8, 20, 64, 21), "#4e8a3c")
  -- hammock
  c:fill(c:line({ { 12, 28 }, { 24, 36 }, { 48, 36 }, { 60, 28 } }, 1), "#e8c48a")
  part(c, c:poly({ { 13, 30 }, { 24, 38 }, { 48, 38 }, { 59, 30 }, { 59, 29 }, { 48, 33 }, { 24, 33 }, { 13, 29 } }), "#e0b068", { noline = true })
  -- lying gnome
  local gx, gy = 25, 29
  part(c, R(c, gx + 8, gy + 1, gx + 22, gy + 6), "#4a6e9a", { noline = true })
  part(c, R(c, gx + 23, gy - 1, gx + 26, gy + 2), "#5a3a22", { noline = true })
  part(c, R(c, gx + 23, gy + 3, gx + 26, gy + 6), "#5a3a22", { noline = true })
  part(c, R(c, gx, gy + 1, gx + 9, gy + 7), "#f4eee0", { noline = true })
  part(c, R(c, gx - 4, gy - 1, gx + 1, gy + 5), "#f0c8a0", { noline = true })
  c:px(gx - 2, gy + 1, "#8a4a34"); c:px(gx, gy + 1, "#8a4a34"); c:px(gx - 3, gy + 3, "#e08a7a")
  part(c, c:poly({ { gx - 4, gy - 3 }, { gx - 4, gy + 5 }, { gx - 15, gy + 5 }, { gx - 12, gy + 2 } }), "#c0442e", { noline = true })
  fl(c, R(c, gx - 5, gy - 2, gx - 4, gy + 5), "#8e2e1e")
  -- rain outside the roof
  local n = 0
  while n < 40 do
    local x, y = 6 + floor(rand() * 62), 6 + floor(rand() * 43)
    local edge = 22 - 16 * (1 - math.abs(x - 36) / 31)
    if x <= 8 or x >= 64 or y < edge - 1 or y >= 45 then
      c:px(x, y, "#d8e8f0"); c:px(x - 1, y + 1, "#d8e8f0"); n = n + 1
    end
  end
  for _, x in ipairs({ 8, 24, 40, 56, 66 }) do c:px(x, 24, "#d8e8f0"); c:px(x, 26, "#d8e8f0") end
  finish(c, "r_sea_rain_hammock")
end

---------------------------------------------------------------- scenes (OCEANIA 1)
local function seastar(c, x, y, col)
  c:paint({ "..o..", "ooooo", ".ooo.", "oo.oo" }, x - 2, y - 1, { o = col or "#e8823a" })
  c:px(x, y, "#f8c070")
end
local function crab(c, x, y)
  part(c, c:ellipse(x, y, 3, 2), "#d9482e", { noline = false })
  c:px(x - 3, y - 3, "#d9482e"); c:px(x + 3, y - 3, "#d9482e"); c:px(x - 3, y - 2, "#d9482e"); c:px(x + 3, y - 2, "#d9482e")
  c:px(x - 1, y - 1, INK); c:px(x + 1, y - 1, INK)
  c:px(x - 4, y + 1, "#a8321e"); c:px(x + 4, y + 1, "#a8321e")
end

function S.r_oc_reef_flat()
  seed = 71
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 21), { "#5a4a82", "#8a5a8a", "#c4687a", "#e8825e", "#f8b078", "#fcd498" }, { dir = "v" })
  c:fill(c:ellipse(40, 22, 7, 7):clip(R(c, 0, 0, W, 21)), "#fff0b8")
  c:bands(R(c, 0, 22, W - 1, 28), { "#f0b890", "#e8a8a0", "#d898b0" }, { dir = "v" })
  c:fill(R(c, 0, 29, W - 1, H - 1), "#c8a888")
  c:fill(R(c, 0, 29, W - 1, 30), "#a8c4c8")
  for _, p in ipairs({ { 8, 33 }, { 30, 31 }, { 60, 34 }, { 14, 45 }, { 52, 47 } }) do c:fill(R(c, p[1], p[2], p[1] + 4, p[2]), "#b89878") end
  -- old jetty posts
  for _, x in ipairs({ 54, 60, 66 }) do part(c, R(c, x, 24, x + 1, 38), WD, { noline = true }) end
  part(c, R(c, 52, 22, 68, 24), WL)
  -- tide pools
  local function pool(x, y, rx, ry) part(c, c:ellipse(x, y, rx, ry), "#9a8a78"); c:fill(c:ellipse(x, y, rx - 1, ry - 1), "#58b4c4"); c:fill(R(c, x - rx + 3, y - 1, x - 1, y - 1), "#a8e6e6") end
  pool(46, 42, 10, 4); pool(62, 33, 6, 2); pool(30, 35, 6, 2); pool(12, 46, 8, 3)
  seastar(c, 42, 42); crab(c, 51, 41)
  -- an eel peeking from the pool edge
  part(c, c:line({ { 66, 33 }, { 64, 31 }, { 62, 31 } }, 2), "#4a6a52", { noline = true }); c:px(62, 30, "#f4eee0")
  seastar(c, 30, 35, "#e46a9b")
  gnome(c, 22, 44, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 7 }, { 8, 5 }, true) } })
  c:px(34, 28, "#f4f8fa"); c:px(10, 30, "#f4f8fa")
  finish(c, "r_oc_reef_flat")
end

function S.r_oc_cyclone_shutters()
  seed = 72
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 36), { "#33284a", "#432f58", "#553a66", "#664a72", "#7a5a80" }, { dir = "v" })
  c:fill(R(c, 0, 37, W - 1, H - 1), "#5a5a46"); c:fill(R(c, 0, 37, W - 1, 37), "#6a6a54")
  -- inn wall and roof
  part(c, R(c, 5, 16, 46, 49), "#d9bc84")
  for y = 20, 46, 4 do fl(c, R(c, 6, y, 45, y), "#c9a96e") end
  part(c, c:poly({ { 3, 17 }, { 12, 8 }, { 40, 8 }, { 49, 17 } }), "#8a4a3a")
  fl(c, R(c, 12, 10, 40, 10), "#a8603e")
  -- window: left shutter closed and lashed, right shutter flapping open
  part(c, R(c, 14, 22, 30, 38), "#2a3a50")
  c:fill(R(c, 15, 23, 29, 23), "#4a6a8a")
  part(c, R(c, 14, 22, 21, 38), "#4a7a4a")
  for y = 24, 36, 3 do fl(c, R(c, 15, y, 20, y), "#3a6a3a") end
  c:fill(c:line({ { 15, 24 }, { 20, 36 } }, 1), "#e8c48a"); c:fill(c:line({ { 20, 24 }, { 15, 36 } }, 1), "#e8c48a")
  part(c, c:poly({ { 30, 22 }, { 36, 25 }, { 36, 41 }, { 30, 38 } }), "#4a7a4a")
  fl(c, R(c, 32, 27, 34, 27), "#3a6a3a"); fl(c, R(c, 32, 32, 34, 32), "#3a6a3a")
  -- door
  -- palm bent flat by the wind
  part(c, c:line({ { 63, 48 }, { 63, 38 }, { 60, 30 }, { 54, 27 } }, 3), "#b08a5a")
  local fm = c:mask()
  for _, p in ipairs({ { 44, 24 }, { 46, 30 }, { 50, 33 }, { 52, 21 }, { 46, 27 } }) do fm:add(c:line({ { 54, 26 }, { p[1] + 4, p[2] }, { p[1], p[2] + 2 } }, 2)) end
  part(c, fm, "#3f8a42")
  -- gnome hauling the shutter shut
  local _, G = gnome(c, 46, 48, { d = -1, eyes = "open", arms = { arm({ -4, 7 }, { -10, 10 }, true), arm({ 4, 6 }, { 5, 3 }, false) } })
  fl(c, R(c, 38, 36, 40, 38), "#f0c8a0")
  c:fill(c:line({ { 36, 36 }, { 31, 33 } }, 1), "#e8c48a")
  -- wind streaks and rain
  for _, p in ipairs({ { 8, 5, 12 }, { 30, 4, 9 }, { 48, 11, 14 }, { 16, 12, 8 }, { 58, 18, 8 } }) do fl(c, R(c, p[1], p[2], p[1] + p[3], p[2]), "#aeb4c8") end
  rain(c, 20, 6, 20, 68, 49, "#b8c4d8")
  finish(c, "r_oc_cyclone_shutters")
end

function S.r_oc_glowworm_hush()
  seed = 73
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 49), { "#10182e", "#141e38", "#18284a", "#1a3050" }, { dir = "v" })
  -- ceiling of glowworms
  for i = 1, 70 do
    local x, y = 6 + floor(rand() * 62), 5 + floor(rand() * 22)
    local col = (i % 5 == 0) and "#d8f8ff" or ((i % 3 == 0) and "#7ad8f8" or "#4a98d8")
    c:px(x, y, col)
    if i % 7 == 0 then c:px(x + 1, y, "#4a98d8"); c:px(x, y + 1, "#4a98d8") end
  end
  for _, x in ipairs({ 8, 20, 36, 50, 62 }) do c:fill(c:poly({ { x - 3, 5 }, { x + 3, 5 }, { x, 11 + (x % 4) } }), "#232a48") end
  -- floor ledge and still pool with mirrored lights
  c:fill(R(c, 0, 40, W - 1, H - 1), "#2a3050"); c:fill(R(c, 0, 40, W - 1, 40), "#3a4468")
  c:fill(c:ellipse(52, 46, 17, 4), "#16284a")
  for i = 1, 22 do c:px(38 + floor(rand() * 28), 44 + floor(rand() * 5), (i % 3 == 0) and "#7ad8f8" or "#3a78b8") end
  -- unlit lamp on a rock with a curl of smoke
  part(c, c:ellipse(60, 41, 6, 3), "#4a5070", { shade = true })
  part(c, R(c, 58, 34, 62, 39), "#8a6a3a"); fl(c, R(c, 59, 35, 61, 37), "#2a2a30")
  part(c, R(c, 58, 33, 62, 33), "#5a4020", { noline = true })
  for i, p in ipairs({ { 60, 31 }, { 61, 28 }, { 60, 25 } }) do c:px(p[1], p[2], "#8a90a8"); c:px(p[1] + (i % 2), p[2] - 1, "#8a90a8") end
  -- gnome, finger to lips, looking up
  gnome(c, 26, 47, { d = 1, s = 1.25, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 3, 7 }, { 1, 9 }, true) } })
  -- a couple of bright motes
  spark(c, 14, 12, "#d8f8ff", "#4a98d8"); spark(c, 44, 17, "#d8f8ff", "#4a98d8")
  finish(c, "r_oc_glowworm_hush")
end

function S.r_oc_star_steering()
  seed = 74
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 31), { "#161c44", "#1e2858", "#2e3a72", "#4a4a84", "#7a5a8a", "#c0708a", "#f0a07a" }, { dir = "v" })
  stars(c, { { 8, 8 }, { 18, 14 }, { 30, 7 }, { 44, 10 }, { 14, 22 }, { 36, 18 }, { 64, 8 }, { 24, 26 }, { 8, 28 } })
  water(c, 32, { "#6a4a7e", "#3a3a6e", "#2a3262", "#222a58" })
  for i = 0, 5 do fl(c, R(c, 5 + i * 11, 36 + (i % 3) * 5, 9 + i * 11, 36 + (i % 3) * 5), "#5a5a98") end
  -- the rising star and its glitter trail on the water
  spark(c, 58, 24, "#fffbe8", "#ffe08a")
  c:px(58, 22, "#ffe08a"); c:px(58, 26, "#ffe08a"); c:px(56, 24, "#ffe08a"); c:px(60, 24, "#ffe08a")
  fl(c, R(c, 56, 33, 60, 33), "#ffe08a"); fl(c, R(c, 57, 36, 59, 36), "#f8c070")
  -- canoe with outrigger
  part(c, c:poly({ { 6, 41 }, { 62, 41 }, { 54, 47 }, { 14, 47 } }), "#8a5a35")
  fl(c, R(c, 8, 41, 60, 41), "#b07a45"); fl(c, R(c, 16, 45, 52, 45), "#6b3b2a")
  part(c, R(c, 62, 40, 66, 42), "#d9a660")
  part(c, R(c, 11, 46, 12, 51), "#6b3b2a", { noline = true }); part(c, R(c, 40, 46, 41, 51), "#6b3b2a", { noline = true })
  -- navigator points, apprentice squints
  gnome(c, 44, 42, { d = 1, hat = "#3f8fb0", eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 12, 13 }, true) } })
  gnome(c, 24, 42, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 5, 14 }, true) } })
  finish(c, "r_oc_star_steering")
end

function S.r_oc_creek_soak()
  seed = 75
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#f8e8b0", "#f8e0a0", "#f8d890", "#f8c880" }, { dir = "v" })
  c:fill(c:ellipse(56, 11, 6, 6), "#fffbe8")
  c:fill(c:ellipse(14, 29, 28, 7), "#c4623a"); c:fill(c:ellipse(60, 30, 26, 6), "#b4542e")
  c:fill(R(c, 0, 29, W - 1, H - 1), "#c97a46")
  for y = 31, 47, 4 do for x = (y % 8 == 3) and 4 or 10, W - 4, 17 do c:px(x, y, "#a8522e"); c:px(x + 1, y, "#a8522e"); c:px(x + 2, y + 1, "#a8522e") end end
  -- dry creek bed
  c:fill(c:poly({ { 0, 38 }, { 30, 34 }, { 72, 36 }, { 72, 49 }, { 0, 49 } }), "#e4be84")
  c:fill(c:poly({ { 0, 41 }, { 30, 38 }, { 72, 40 }, { 72, 45 }, { 0, 46 } }), "#ecca94")
  -- dead gum tree
  part(c, c:line({ { 8, 36 }, { 9, 24 }, { 7, 14 } }, 2), "#e8e0d0", { noline = true })
  c:fill(c:line({ { 8, 20 }, { 3, 15 } }, 1), "#e8e0d0"); c:fill(c:line({ { 8, 22 }, { 13, 17 } }, 1), "#e8e0d0")
  fl(c, R(c, 9, 25, 9, 30), "#b8a888")
  -- finches all flying one way
  local function finch(x, y) c:fill(R(c, x, y, x + 2, y + 1), "#8a5a35"); c:px(x + 3, y, "#e8823a"); c:px(x, y - 1, "#f0c040"); c:px(x + 1, y - 2, "#f0c040"); c:px(x - 1, y + 1, "#f0c040") end
  finch(30, 14); finch(40, 18); finch(48, 12); finch(36, 24)
  -- heat shimmer
  for x = 12, 64, 12 do fl(c, R(c, x, 30, x + 4, 30), "#fff4c8"); fl(c, R(c, x + 3, 32, x + 7, 32), "#fff4c8") end
  -- hole with a damp patch, mound beside
  part(c, c:ellipse(50, 45, 9, 3), "#6b4a2e"); c:fill(c:ellipse(50, 45, 6, 2), "#3a2a20"); c:fill(R(c, 48, 45, 52, 46), "#5a8aa0")
  part(c, c:ellipse(62, 46, 6, 3), "#e4be84", { shade = true })
  -- gnome digging
  local _, G = gnome(c, 33, 47, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { 3, 6 }, false), arm({ 4, 8 }, { 8, 5 }, true) } })
  part(c, c:line({ { 38, 33 }, { 47, 43 } }, 2), "#a8703e", { noline = true })
  part(c, R(c, 45, 43, 50, 46), "#aeb4bc")
  c:px(44, 19, "#a8d8e8"); c:px(54, 40, "#a8d8e8")
  finish(c, "r_oc_creek_soak")
end

function S.r_oc_seal_on_ramp()
  seed = 76
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 18), { "#a8d4e0", "#bcdde4", "#d0e8e6" }, { dir = "v" })
  water(c, 19, { "#58b4c4", "#4aa4b8", "#3f94ac" })
  for i = 0, 5 do fl(c, R(c, 6 + i * 11, 22 + (i % 2) * 3, 10 + i * 11, 22 + (i % 2) * 3), "#7ccfd4") end
  -- kelp
  for _, x in ipairs({ 40, 44, 58 }) do part(c, c:line({ { x, 27 }, { x + 1, 23 }, { x - 1, 19 } }, 1), "#6a5a2a", { noline = true }) end
  -- waiting ferry
  part(c, c:poly({ { 44, 17 }, { 66, 17 }, { 62, 23 }, { 48, 23 } }), "#f4eee0")
  fl(c, R(c, 46, 20, 64, 20), "#3f6fb0")
  part(c, R(c, 50, 11, 60, 17), "#f4eee0"); fl(c, R(c, 52, 13, 58, 14), "#3f8fb0")
  part(c, R(c, 54, 6, 56, 10), "#c0442e", { noline = true })
  -- concrete ramp
  c:fill(c:poly({ { 0, 28 }, { 72, 28 }, { 72, 49 }, { 0, 49 } }), "#a8a8a0")
  c:fill(R(c, 0, 28, W - 1, 29), "#c8c8bc")
  for x = 4, 70, 10 do fl(c, R(c, x, 31, x, 49), "#8e8e86") end
  for y = 35, 47, 6 do fl(c, R(c, 0, y, W - 1, y), "#98988e") end
  -- the seal, flopped across it
  part(c, c:ellipse(46, 41, 17, 5), "#7a7068", { shade = true })
  c:fill(c:ellipse(46, 39, 13, 2), "#948a80")
  part(c, c:ellipse(30, 38, 5, 4), "#7a7068", { shade = true })
  c:fill(R(c, 28, 38, 29, 38), "#4a3a30"); c:px(27, 40, INK); c:px(26, 40, INK)
  c:px(33, 38, "#e8e0d0"); c:px(33, 40, "#e8e0d0")
  part(c, c:poly({ { 62, 40 }, { 70, 36 }, { 68, 43 } }), "#6a6058")
  part(c, c:ellipse(40, 46, 4, 2), "#6a6058")
  for _, p in ipairs({ { 27, 33 }, { 30, 31 }, { 33, 29 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#f4eee0", { noline = true }) end
  -- gnome with a fish held out
  gnome(c, 12, 48, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 8, 8 }, true) } })
  part(c, c:ellipse(20, 40, 3, 1), "#8aa8c8"); c:px(23, 39, "#8aa8c8"); c:px(23, 41, "#8aa8c8"); c:px(18, 40, INK)
  finish(c, "r_oc_seal_on_ramp")
end

function S.r_oc_fernmist_path()
  seed = 77
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 49), { "#a8bcb0", "#b4c6ba", "#c0d0c4", "#c8d6ca" }, { dir = "v" })
  c:fill(R(c, 0, 36, W - 1, H - 1), "#5a7a58"); c:fill(R(c, 0, 36, W - 1, 36), "#6a8a62")
  -- far shadowy ferns
  local function tf(x, yb, h, col, trunk)
    part(c, R(c, x, yb - h, x + 1, yb), trunk, { noline = true })
    local m = c:mask()
    for _, dx in ipairs({ -8, -5, 5, 8 }) do m:add(c:line({ { x, yb - h }, { x + floor(dx / 2), yb - h - 3 }, { x + dx, yb - h + 3 } }, 2)) end
    m:add(c:line({ { x, yb - h }, { x, yb - h - 5 } }, 2))
    part(c, m, col)
  end
  tf(30, 33, 12, "#7a9a82", "#8a9a7a"); tf(58, 35, 10, "#7a9a82", "#8a9a7a"); tf(6, 33, 11, "#7a9a82", "#8a9a7a")
  -- mist band (dither) across the middle
  for y = 24, 34 do for x = 5 + (y % 2), 68, 2 do c:px(x, y, "#d8e4dc") end end
  c:fill(R(c, 5, 28, 68, 31), "#d8e4dc")
  -- path
  c:fill(c:poly({ { 14, 49 }, { 34, 49 }, { 54, 36 }, { 46, 36 } }), "#b0946a")
  c:fill(c:poly({ { 20, 49 }, { 30, 49 }, { 50, 36 }, { 47, 36 } }), "#c4aa7e")
  -- near ferns
  tf(60, 48, 17, "#3f7a4a", "#6b5a3a"); tf(10, 48, 14, "#4a8a52", "#6b5a3a")
  for _, p in ipairs({ { 20, 40 }, { 56, 44 }, { 38, 47 } }) do c:fill(c:ellipse(p[1], p[2], 3, 1), "#6a9a62") end
  -- fantail
  part(c, c:ellipse(44, 36, 2, 1), "#4a4a52"); c:px(42, 35, "#f4eee0")
  part(c, c:poly({ { 46, 36 }, { 51, 32 }, { 53, 36 }, { 51, 38 } }), "#6a6a72")
  fl(c, R(c, 51, 36, 52, 36), "#f4eee0")
  gnome(c, 25, 47, { d = 1, walk = 1, eyes = "open", arms = { arm({ -4, 7 }, { -5, 4 }, false), arm({ 4, 7 }, { 9, 6 }, true) } })
  finish(c, "r_oc_fernmist_path")
end

function S.r_oc_cockatoo_watch()
  seed = 78
  local c = new()
  day(c, 33, { cloud = 50, hill = "#4e8a3c", hill2 = "#3f7a38", grass = "#7ea85a" })
  local function tree(x, ytop)
    part(c, R(c, x - 1, ytop + 8, x + 1, 38), "#6b4a2e", { noline = true })
    part(c, c:ellipse(x, ytop + 4, 12, 7), "#3f7a38", { shade = true })
    for _, p in ipairs({ { -6, 4 }, { 0, 7 }, { 5, 5 }, { -2, 1 }, { 7, 8 } }) do c:fill(R(c, x + p[1], ytop + p[2], x + p[1] + 1, ytop + p[2] + 1), "#c8a85a") end
  end
  tree(14, 8); tree(56, 7)
  local function cockatoo(x, y, fly)
    part(c, c:ellipse(x, y, 3, 2), "#f8f4ec")
    part(c, c:ellipse(x - 2, y - 3, 2, 2), "#f8f4ec")
    c:px(x - 2, y - 6, "#f5cf6a"); c:px(x - 3, y - 5, "#f5cf6a"); c:px(x - 1, y - 6, "#f5cf6a")
    c:px(x - 4, y - 3, "#6a6a72"); c:px(x - 2, y - 3, INK)
    if fly then
      c:fill(c:poly({ { x, y - 1 }, { x + 6, y - 6 }, { x + 4, y } }), "#f8f4ec"); c:fill(R(c, x + 4, y - 6, x + 6, y - 6), "#f5cf6a")
    else
      c:px(x + 3, y + 1, "#d8d4cc"); c:px(x + 4, y + 2, "#d8d4cc"); c:px(x, y + 2, "#f5cf6a")
    end
  end
  cockatoo(10, 17); cockatoo(60, 17); cockatoo(66, 27, true); cockatoo(34, 12, true); cockatoo(48, 40); cockatoo(60, 45)
  c:px(46, 43, "#c8a85a"); c:px(58, 47, "#c8a85a"); c:px(52, 46, "#c8a85a")
  -- nut basket
  part(c, R(c, 4, 42, 13, 48), "#c9a96e")
  for x = 5, 12, 2 do c:px(x, 41, "#c8a85a") end
  fl(c, R(c, 4, 44, 13, 44), "#a8863e")
  -- gnome shooing, a pot lid in each hand
  gnome(c, 32, 47, { d = 1, s = 1.25, eyes = "open", arms = { arm({ -4, 8 }, { -8, 17 }, false), arm({ 4, 8 }, { 8, 17 }, true) } })
  for _, p in ipairs({ { 24, 29 }, { 41, 29 } }) do part(c, c:ellipse(p[1], p[2], 3, 3), "#aeb4bc"); c:px(p[1], p[2], "#e8ecf0") end
  spark(c, 22, 22, "#f4f8fa", "#f5cf6a"); spark(c, 44, 22, "#f4f8fa", "#f5cf6a")
  finish(c, "r_oc_cockatoo_watch")
end

---------------------------------------------------------------- scenes (OCEANIA 2)
function S.r_oc_watcher_shadows()
  seed = 81
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 31), { "#e8a878", "#f0b888", "#f4c898", "#f8d8a8" }, { dir = "v" })
  c:fill(c:ellipse(66, 28, 8, 8), "#f8e8b0"); c:fill(c:ellipse(66, 28, 6, 6), "#fff4c8")
  c:fill(c:ellipse(18, 32, 30, 7), "#7a9a52"); c:fill(c:ellipse(60, 33, 26, 6), "#6a8a48")
  c:fill(R(c, 0, 32, W - 1, H - 1), "#8aa85a"); c:fill(R(c, 0, 32, W - 1, 32), "#a0b868")
  -- long shadows of the Watchers falling left
  c:fill(c:poly({ { 42, 43 }, { 42, 47 }, { 5, 48 }, { 5, 45 } }), "#456a38")
  c:fill(c:poly({ { 51, 35 }, { 51, 38 }, { 20, 39 }, { 20, 37 } }), "#456a38")
  c:fill(c:poly({ { 63, 39 }, { 63, 42 }, { 30, 43 }, { 30, 40 } }), "#456a38")
  -- timekeeping pegs along the grass
  for _, x in ipairs({ 12, 20, 28, 36 }) do part(c, R(c, x, 46, x + 1, 47), "#e8e0d0", { noline = true }) end
  -- three stone heads
  local function head(x, yb, h, w)
    part(c, R(c, x, yb - h, x + w, yb), "#8b8f96")
    fl(c, R(c, x, yb - h, x + w, yb - h), "#a8aeb4")
    fl(c, R(c, x + 1, yb - h + floor(h * 0.3), x + w - 1, yb - h + floor(h * 0.3) + 1), "#5a5e68")
    fl(c, R(c, x + floor(w / 2), yb - h + floor(h * 0.4), x + floor(w / 2) + 1, yb - floor(h * 0.3)), "#a8aeb4")
    fl(c, R(c, x + 1, yb - floor(h * 0.2), x + w - 1, yb - floor(h * 0.2)), "#5a5e68")
  end
  head(63, 42, 14, 5); head(51, 38, 11, 4); head(42, 47, 16, 6)
  -- gnome with a stick, reading the shadow
  gnome(c, 20, 44, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -5, 4 }, false), arm({ 4, 8 }, { 9, 7 }, true) } })
  part(c, c:line({ { 26, 38 }, { 36, 47 } }, 1), "#8a5a35", { noline = true })
  finish(c, "r_oc_watcher_shadows")
end

function S.r_oc_billy_swing()
  seed = 82
  local c = new()
  day(c, 33, { cloud = 52, sky = { "#c8dce0", "#d8e6e0", "#e8ece0" }, hill = "#b4623a", hill2 = "#a4522e", grass = "#c97a46", edge = "#d99256" })
  for _, p in ipairs({ { 6, 44 }, { 20, 49 }, { 54, 46 }, { 64, 49 }, { 40, 39 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2]), "#a8522e") end
  -- gum tree
  part(c, c:line({ { 62, 40 }, { 61, 28 }, { 63, 18 } }, 3), "#e8e0d0")
  c:fill(c:line({ { 62, 24 }, { 68, 20 } }, 1), "#e8e0d0")
  part(c, c:ellipse(62, 14, 8, 5), "#6a8a5a", { shade = true }); c:fill(c:ellipse(64, 12, 3, 1), "#8aaa72")
  -- campfire with logs, stones, smoke
  for _, p in ipairs({ { 6, 47 }, { 11, 48 }, { 16, 47 } }) do part(c, c:ellipse(p[1], p[2], 2, 1), "#8b8f96") end
  part(c, c:line({ { 5, 45 }, { 16, 45 } }, 2), "#6b3b2a")
  part(c, c:poly({ { 10, 37 }, { 14, 42 }, { 15, 45 }, { 6, 45 }, { 7, 42 } }), "#e0501f")
  c:fill(c:poly({ { 10, 40 }, { 12, 43 }, { 12, 45 }, { 8, 45 } }), "#ffd86a")
  steam(c, 11, 34, 3, "#d8d8d8")
  -- the swinging billy: dotted arc, tin can with a gum leaf on top
  local gx, gy = 36, 47
  for i = 0, 9 do
    local a = math.rad(15 + i * 12)
    c:px(gx + 4 + rnd(math.cos(a) * 9), gy - 8 + rnd(math.sin(a) * 9), "#fff8e0")
  end
  gnome(c, gx, gy, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 10, 12 }, true) } })
  local bx, by = 49, 39
  fl(c, R(c, bx - 1, by - 7, bx - 1, by - 4), "#2a1a10"); fl(c, R(c, bx + 3, by - 7, bx + 3, by - 4), "#2a1a10")
  fl(c, R(c, bx - 1, by - 8, bx + 3, by - 8), "#2a1a10")
  part(c, c:poly({ { bx - 2, by - 4 }, { bx + 4, by - 4 }, { bx + 5, by + 1 }, { bx - 3, by + 1 } }), "#aeb4bc")
  fl(c, R(c, bx - 3, by, bx + 5, by + 1), "#4a4a52"); fl(c, R(c, bx - 1, by - 3, bx, by - 1), "#e8ecf0")
  c:px(bx + 1, by - 5, "#4e8a3c"); c:px(bx + 2, by - 5, "#4e8a3c")
  fl(c, R(c, 45, 38, 47, 40), "#f0c8a0")
  finish(c, "r_oc_billy_swing")
end

function S.r_oc_coir_cord()
  seed = 83
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 24), { "#a8d4e0", "#bcdde4", "#d0e8e6" }, { dir = "v" })
  water(c, 25, { "#58b4c4", "#4aa4b8", "#3f94ac" })
  for i = 0, 5 do fl(c, R(c, 6 + i * 11, 27 + (i % 2) * 3, 10 + i * 11, 27 + (i % 2) * 3), "#7ccfd4") end
  -- sand beach
  c:fill(c:poly({ { 0, 33 }, { 72, 31 }, { 72, 49 }, { 0, 49 } }), "#e8d2a0"); c:fill(R(c, 0, 33, 71, 33), "#f4e6bc")
  c:fill(R(c, 0, 43, W - 1, H - 1), "#d9bc84")
  palm(c, 9, 34, 22, 3, true)
  -- canoe resting on the beach, a jetty rail behind
  part(c, c:poly({ { 36, 28 }, { 68, 28 }, { 62, 34 }, { 42, 34 } }), "#8a5a35")
  fl(c, R(c, 38, 28, 66, 28), "#b07a45")
  part(c, R(c, 62, 22, 63, 28), WD, { noline = true }); part(c, R(c, 52, 22, 53, 28), WD, { noline = true })
  -- husks and fibre
  for _, p in ipairs({ { 6, 46 }, { 12, 48 } }) do part(c, c:ellipse(p[1], p[2], 4, 2), "#a87a45") ; fl(c, R(c, p[1] - 2, p[2] - 1, p[1] + 2, p[2] - 1), "#c89a5a") end
  part(c, c:ellipse(18, 45, 3, 2), "#c89a5a")
  -- stake and the finished cord stretching to it
  part(c, R(c, 63, 35, 64, 44), "#6b3b2a", { noline = true })
  local lx, ly = 33, 37
  for i = 0, 29 do
    local x = lx + i
    local y = ly - rnd(i * 0.1) + ((i % 4 < 2) and 0 or 1)
    c:px(x, y, (i % 4 < 2) and "#f0dca8" or "#a87a45"); c:px(x, y + 1, (i % 4 < 2) and "#a87a45" or "#f0dca8")
  end
  part(c, c:ellipse(56, 47, 6, 2), "#e0c88a"); c:fill(c:ellipse(56, 47, 3, 1), "#a87a45")
  -- gnome seated rolling fibre on the knee
  local _, G = gnome(c, 22, 41, { d = 1, sit = true, s = 1.25, eyes = "open", arms = { arm({ 3, 7 }, { 9, 3 }, true, true), arm({ -3, 7 }, { 8, 2 }, false, true) } })
  fl(c, R(c, 29, 36, 33, 38), "#f0c8a0")
  finish(c, "r_oc_coir_cord")
end

function S.r_oc_earth_oven()
  seed = 84
  local c = new()
  day(c, 32, { cloud = 14, sky = { "#b8dcc8", "#c8e4cc", "#d8ecd0" }, hill = "#4e8a3c", hill2 = "#3f7a38" })
  palm(c, 10, 33, 22, 4, true); palm(c, 64, 33, 16, -3)
  -- the mound: hot stones ring, leaf cover, steam
  part(c, c:ellipse(46, 43, 17, 6), "#5a3a22", { shade = true })
  c:fill(c:ellipse(46, 42, 14, 4), "#6b4a2e")
  for _, p in ipairs({ { 33, 44 }, { 38, 48 }, { 46, 49 }, { 54, 48 }, { 59, 44 } }) do part(c, c:ellipse(p[1], p[2], 3, 2), "#6a6e76", { shade = true }); c:px(p[1], p[2], "#e0501f") end
  part(c, c:ellipse(46, 39, 10, 4), "#3f8a42", { shade = true })
  c:fill(R(c, 41, 38, 51, 38), "#7ab55c"); c:fill(R(c, 45, 37, 47, 40), "#4e9a48")
  steam(c, 44, 34, 4); steam(c, 50, 33, 3); steam(c, 40, 35, 2)
  -- spade and coconut halves
  part(c, R(c, 63, 36, 63, 47), "#8a5a35", { noline = true }); part(c, R(c, 61, 46, 65, 49), "#aeb4bc")
  for _, p in ipairs({ { 24, 49 }, { 29, 48 } }) do part(c, c:ellipse(p[1], p[2], 2, 1), "#6b4a2e"); c:px(p[1], p[2] - 1, "#f4eee0") end
  -- waiting gnome: seated, chin in hand, foot tapping
  gnome(c, 14, 41, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 5, 5 }, true), arm({ -3, 6 }, { -4, 3 }, false) } })
  c:px(24, 44, "#f4f8fa"); c:px(26, 43, "#f4f8fa")
  -- little clock-like dots of impatience
  for _, p in ipairs({ { 28, 22 }, { 31, 20 }, { 34, 18 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#f4eee0", { noline = true }) end
  finish(c, "r_oc_earth_oven")
end

function S.r_oc_sago_pancakes()
  seed = 85
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#d9bc84")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 0, x, 38), "#c9a96e") end
  fl(c, R(c, 0, 10, W - 1, 10), WD)
  c:fill(R(c, 0, 39, W - 1, H - 1), "#a8703e")
  for y = 44, 52, 6 do fl(c, R(c, 0, y, W - 1, y), WD) end
  -- sago sack with scoop, banana bunch
  part(c, c:rrect(5, 22, 18, 38, 3), "#e8dcc0"); fl(c, R(c, 7, 24, 16, 24), "#c9bc9a"); c:px(11, 29, "#8a6a3a"); c:px(12, 29, "#8a6a3a")
  part(c, R(c, 8, 20, 15, 22), "#c9bc9a")
  part(c, c:ellipse(60, 32, 4, 1), "#f0d84a")
  for i = 0, 3 do part(c, c:ellipse(56 + i * 3, 33 - (i % 2), 1.5, 3), "#f0d84a"); c:px(56 + i * 3, 30 - (i % 2), "#6a8a3a") end
  -- window of shelves
  part(c, R(c, 28, 14, 44, 26), "#a8d4c0"); fl(c, R(c, 36, 14, 36, 26), WD); fl(c, R(c, 28, 20, 44, 20), WD)
  -- low stove: three stones, glowing fire, clay plate
  for _, x in ipairs({ 46, 52, 58 }) do part(c, c:ellipse(x, 47, 3, 2), "#6a6e76", { shade = true }) end
  part(c, c:poly({ { 49, 41 }, { 55, 41 }, { 56, 46 }, { 48, 46 } }), "#e0501f"); c:fill(R(c, 51, 43, 53, 46), "#ffd86a")
  part(c, c:ellipse(52, 40, 11, 3), "#c4623a"); c:fill(c:ellipse(52, 39, 9, 2), "#d9784a")
  -- pancake mid-flip above the plate, spatula below it
  part(c, c:ellipse(46, 25, 6, 2), "#e8b04a"); c:fill(R(c, 43, 24, 49, 24), "#f5d070")
  c:px(41, 28, "#f4f8fa"); c:px(51, 29, "#f4f8fa"); c:px(53, 24, "#f5cf6a"); c:px(39, 22, "#f5cf6a")
  part(c, c:ellipse(60, 38, 3, 1), "#e8b04a")
  -- gnome flipping with a spatula
  local _, G = gnome(c, 30, 48, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 9, 12 }, true) } })
  part(c, c:line({ { 39, 36 }, { 45, 28 } }, 1), "#8a5a35", { noline = true })
  part(c, R(c, 43, 27, 48, 28), "#aeb4bc")
  -- first golden pancake stacked with banana on a plate
  part(c, c:ellipse(18, 47, 6, 2), "#f4eee0"); part(c, c:ellipse(18, 45, 4, 1), "#e8b04a"); c:fill(c:ellipse(18, 44, 2, 1), "#f0d84a")
  finish(c, "r_oc_sago_pancakes")
end

function S.r_oc_finger_lime_pot()
  seed = 86
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 24), { "#a8d4e0", "#bcdde4", "#d0e8e6" }, { dir = "v" })
  water(c, 25, { "#58b4c4", "#4aa4b8", "#3f94ac" })
  for i = 0, 5 do fl(c, R(c, 6 + i * 11, 28 + (i % 2) * 3, 10 + i * 11, 28 + (i % 2) * 3), "#7ccfd4") end
  -- little boat beyond the jetty
  part(c, c:poly({ { 8, 27 }, { 26, 27 }, { 22, 31 }, { 12, 31 } }), "#c0442e"); fl(c, R(c, 16, 21, 17, 27), "#8a5a35"); part(c, c:poly({ { 18, 21 }, { 24, 26 }, { 18, 26 } }), "#f4eee0")
  -- jetty planks + table with the pot
  part(c, R(c, 0, 38, W - 1, 45), WL); fl(c, R(c, 0, 38, W - 1, 38), WD2)
  for x = 6, 70, 10 do fl(c, R(c, x, 39, x, 45), WD) end
  part(c, R(c, 0, 46, W - 1, H - 1), "#6b4a2e")
  for x = 5, 70, 14 do fl(c, R(c, x, 47, x, 49), "#4a2c1a") end
  part(c, R(c, 34, 30, 66, 33), WL); fl(c, R(c, 35, 30, 65, 30), WD2)
  part(c, R(c, 36, 34, 38, 44), WD, { noline = true }); part(c, R(c, 62, 34, 64, 44), WD, { noline = true })
  -- the fish pot: black iron pot, tail and steam
  part(c, c:rrect(42, 20, 58, 30, 3), "#3a3a44", { shade = true }); fl(c, R(c, 43, 21, 57, 21), "#5a5a66")
  fl(c, R(c, 41, 22, 41, 24), "#3a3a44"); fl(c, R(c, 59, 22, 59, 24), "#3a3a44")
  part(c, c:ellipse(50, 20, 7, 1.5), "#8a5a35", { noline = true }); fl(c, R(c, 45, 20, 55, 20), "#e8a317")
  part(c, c:poly({ { 53, 19 }, { 58, 15 }, { 59, 19 } }), "#8aa8c8"); c:px(58, 18, "#e8ecf0")
  steam(c, 46, 16, 3); steam(c, 51, 14, 2)
  -- gnome squeezing a finger lime over the pot
  gnome(c, 24, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 12, 16 }, true) } })
  part(c, c:rrect(31, 25, 39, 28, 1), "#6aa83a"); fl(c, R(c, 39, 26, 40, 27), "#f4c8d0"); fl(c, R(c, 33, 26, 37, 26), "#8cc858")
  -- bursting pearls
  for _, p in ipairs({ { 40, 31, "#b8e86a" }, { 43, 29, "#f4a8b8" }, { 45, 32, "#b8e86a" }, { 41, 34, "#f4a8b8" }, { 47, 27, "#b8e86a" } }) do c:px(p[1], p[2], p[3]); c:px(p[1] + 1, p[2], p[3]) end
  finish(c, "r_oc_finger_lime_pot")
end

function S.r_oc_warrigal_salad()
  seed = 87
  local c = new()
  day(c, 31, { cloud = 52, sky = { "#b8dcd8", "#c8e4dc", "#d8ece0" }, hill = "#4e8a3c", hill2 = "#3f7a38", grass = "#7ea85a" })
  -- garden bed of warrigal at the back
  for x = 8, 66, 9 do part(c, c:ellipse(x, 33, 5, 2), "#5a9a4a", { shade = true }); c:fill(R(c, x - 2, 32, x + 1, 32), "#8fc462") end
  -- trestle table with a wooden salad bowl and kiwi slices
  part(c, R(c, 38, 38, 68, 40), WL); fl(c, R(c, 39, 38, 67, 38), WD2)
  part(c, R(c, 40, 41, 41, 48), WD, { noline = true }); part(c, R(c, 65, 41, 66, 48), WD, { noline = true })
  part(c, c:ellipse(52, 36, 9, 3), "#8a5a35", { shade = true })
  c:fill(c:ellipse(52, 34, 8, 3), "#4e9a48"); c:fill(R(c, 47, 33, 52, 33), "#7ab55c"); c:fill(R(c, 54, 35, 58, 35), "#3f8a42")
  for _, p in ipairs({ { 59, 31 }, { 45, 31 } }) do
    part(c, c:ellipse(p[1], p[2], 2, 2), "#a8d060"); c:px(p[1], p[2], "#f4f0c8"); c:px(p[1] - 1, p[2], INK); c:px(p[1] + 1, p[2] - 1, INK)
  end
  part(c, c:ellipse(62, 36, 2, 1), "#a8d060"); c:px(62, 36, INK)
  -- boiling pot over a small fire, steam
  part(c, c:ellipse(12, 48, 6, 1), "#6b3b2a", { noline = true })
  part(c, c:poly({ { 8, 44 }, { 12, 40 }, { 16, 44 } }), "#e0501f"); c:fill(R(c, 11, 42, 13, 45), "#ffd86a")
  part(c, c:rrect(6, 33, 18, 41, 2), "#aeb4bc", { shade = true }); fl(c, R(c, 8, 34, 16, 34), "#58b4c4")
  for _, p in ipairs({ { 9, 33 }, { 13, 32 }, { 16, 33 } }) do c:px(p[1], p[2], "#e8f8f4") end
  steam(c, 10, 30, 3); steam(c, 15, 29, 2)
  -- gnome dips the greens in a basket on a stick
  gnome(c, 28, 47, { d = -1, eyes = "open", arms = { arm({ 4, 7 }, { 5, 3 }, false), arm({ -4, 8 }, { -9, 10 }, true) } })
  part(c, c:line({ { 20, 38 }, { 14, 35 } }, 1), "#8a5a35", { noline = true })
  part(c, c:ellipse(13, 35, 3, 2), "#4e9a48"); c:px(12, 34, "#7ab55c")
  finish(c, "r_oc_warrigal_salad")
end

local order = {
  "r_sea_leaf_parcels", "r_sea_lily_frog", "r_sea_cave_breeze", "r_sea_rabbit_grater", "r_sea_pole_raft", "r_sea_lantern_river",
  "r_sea_dragonlizard", "r_sea_root_whispers", "r_sea_rain_hammock",
  "r_oc_reef_flat", "r_oc_cyclone_shutters", "r_oc_glowworm_hush", "r_oc_star_steering", "r_oc_creek_soak", "r_oc_seal_on_ramp",
  "r_oc_fernmist_path", "r_oc_cockatoo_watch", "r_oc_watcher_shadows", "r_oc_billy_swing", "r_oc_coir_cord", "r_oc_earth_oven",
  "r_oc_sago_pancakes", "r_oc_finger_lime_pot", "r_oc_warrigal_salad",
}
for _, s2 in ipairs(order) do
  if S[s2] and (not only or only == s2) then seed = 7; S[s2]() end
end
