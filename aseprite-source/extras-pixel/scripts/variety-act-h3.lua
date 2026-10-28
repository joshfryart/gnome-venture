-- variety-act-h3.lua : regional rest-stop activity scenes (group h3) -> act-<slug>.png (144x108, drawn on 72x54, out=2). Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-h3.lua
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

---------------------------------------------------------------- extra helpers
local function ring(c, cx, cy, rx, ry, col)
  local m = c:ellipse(cx, cy, rx, ry); m:cut(c:ellipse(cx, cy, rx - 1, math.max(0, ry - 1))); c:fill(m, col)
end
local function rain(c, n, x0, x1, y0, y1, col, sl)
  for i = 1, n do
    local x, y = x0 + floor(rand() * (x1 - x0)), y0 + floor(rand() * (y1 - y0))
    c:px(x, y, col); c:px(x + (sl or 1), y + 2, col)
  end
end
local function stars(c, n, y1, col)
  for i = 1, n do
    local x, y = 6 + floor(rand() * 62), 6 + floor(rand() * (y1 - 6))
    c:px(x, y, col or "#f4eee0")
    if i % 6 == 0 then c:px(x + 1, y, "#9aa8c8"); c:px(x - 1, y, "#9aa8c8") end
  end
end
local function palm(c, x, yb, h, lean, nococo)
  local tx, ty = x + lean, yb - h
  part(c, c:line({ { x, yb }, { x + floor(lean / 3), yb - floor(h / 2) }, { tx, ty } }, 3), "#8a6a45")
  for i = 1, 3 do local yy = yb - floor(h * i / 4); c:px(x + floor(lean * i / 4) - 1, yy, "#6a4a2e") end
  local fr = { { -9, 3 }, { -6, -1 }, { -3, -3 }, { 3, -3 }, { 6, -1 }, { 9, 3 } }
  for _, f in ipairs(fr) do
    local m = c:line({ { tx, ty }, { tx + floor(f[1] / 2), ty + f[2] - 1 }, { tx + f[1], ty + f[2] + 3 } }, 2)
    c:fill(m, "#3f8a42")
    c:px(tx + floor(f[1] / 2), ty + f[2] - 2, "#5faa52")
  end
  if not nococo then
    part(c, c:ellipse(tx - 1, ty + 2, 1, 1), "#6a4a2e"); part(c, c:ellipse(tx + 2, ty + 2, 1, 1), "#6a4a2e")
  end
end
local function steam(c, x, y, n, col)
  for i = 0, n do local sx = x + ((i % 2 == 0) and 0 or 1); fl(c, R(c, sx, y - i * 2, sx, y - i * 2 + 1), col or "#f4f8fa") end
end
local function ripples(c, y0, y1, col, n)
  for i = 1, n do
    local x, y = 6 + floor(rand() * 56), y0 + floor(rand() * (y1 - y0))
    c:fill(R(c, x, y, x + 3 + floor(rand() * 3), y), col)
  end
end
local function jar(c, x, y, w, h, col)
  part(c, R(c, x, y, x + w - 1, y + h - 1), col)
  fl(c, R(c, x, y - 1, x + w - 1, y - 1), "#8a5a35")
  c:px(x + 1, y + 1, "#fbfdfe")
end

---------------------------------------------------------------- scenes
local S = {}

function S.r_ca_smokecap_stones()
  seed = 5
  local c = new()
  day(c, 34, { sky = { "#b8d8d8", "#cde4dc", "#e0ecd8" }, cloud = false, hill = "#4e7a3a", hill2 = "#3f6a32" })
  part(c, c:poly({ { 30, 14 }, { 42, 14 }, { 58, 36 }, { 14, 36 } }), "#6e5e5c")
  fl(c, R(c, 30, 14, 41, 14), "#3a2a28"); fl(c, R(c, 31, 15, 40, 15), "#e0501f")
  for _, p in ipairs({ { 36, 10, 3, 2 }, { 40, 8, 3, 2 }, { 35, 6, 2, 1 } }) do c:fill(c:ellipse(p[1], p[2], p[3], p[4]), "#d8d4d0") end
  for _, p in ipairs({ { 34, 25 }, { 40, 30 }, { 26, 31 }, { 46, 24 } }) do c:fill(R(c, p[1], p[2], p[1] + 3, p[2]), "#8a7a78") end
  -- paving stones up the path
  for i, p in ipairs({ { 33, 36 }, { 36, 33 }, { 38, 30 }, { 40, 28 } }) do
    part(c, c:ellipse(p[1] + 2, p[2] + 1, 2 + (4 - i) // 2, 1), i % 2 == 0 and "#a8a0a0" or "#b8a898")
  end
  -- windowsill with stones
  part(c, R(c, 44, 41, 68, 43), "#a8703e"); fl(c, R(c, 44, 41, 68, 41), "#c08a52")
  fl(c, R(c, 47, 44, 48, 49), "#6b3b2a"); fl(c, R(c, 64, 44, 65, 49), "#6b3b2a")
  for i, col in ipairs({ "#4a4a52", "#c0442e", "#ece8dc", "#e8c23a", "#5fa8a8" }) do
    part(c, c:ellipse(46 + i * 4, 40, 2, 1), col); c:px(45 + i * 4, 39, "#fbfdfe")
  end
  local _, G = gnome(c, 24, 47, { s = 1.25, d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 2 }, false), arm({ 4, 6 }, { 8, 13 }, true) } })
  local sx, sy = G.P(9, 14)
  part(c, c:ellipse(sx, sy, 2, 2), "#c0442e"); c:px(sx - 1, sy - 1, "#f08a6a")
  finish(c, "r_ca_smokecap_stones")
end

function S.r_ca_husk_parcel()
  seed = 6
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#c8995e")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 38), "#a8703e") end
  part(c, R(c, 8, 9, 22, 24), "#6b3b2a"); c:fill(R(c, 10, 11, 20, 22), "#a8d4e0"); fl(c, R(c, 15, 11, 15, 22), "#6b3b2a"); fl(c, R(c, 10, 17, 20, 17), "#6b3b2a")
  for _, p in ipairs({ { 52, 9 }, { 58, 12 } }) do part(c, c:ellipse(p[1], p[2], 2, 4), "#4f9a45") end
  fl(c, R(c, 54, 8, 54, 17), "#d8c88a")
  local _, G = gnome(c, 30, 43, { s = 1.3, d = 1, upper = true, eyes = "happy", arms = { arm({ -4, 6 }, { -6, 12 }, true), arm({ 4, 6 }, { 7, 14 }, true) } })
  -- table
  part(c, R(c, 3, 39, 69, 42), "#b07a45"); fl(c, R(c, 3, 39, 69, 39), "#d9a660")
  c:fill(R(c, 4, 43, 68, 49), "#8a5a35"); for x = 10, 66, 8 do fl(c, R(c, x, 43, x, 49), "#6b3b2a") end
  -- opened husk + bean
  local hx, hy = G.P(-6, 12)
  for _, dx in ipairs({ -3, 0, 3 }) do part(c, c:ellipse(hx + dx, hy - 1, 1, 2), "#e8d8a0") end
  fl(c, R(c, hx - 2, hy + 1, hx + 2, hy + 1), "#f0c8a0")
  local bx, by = G.P(8, 15)
  part(c, c:ellipse(bx, by, 1, 1), "#2a1a1a"); c:px(bx - 1, by - 3, "#fff8c0"); c:px(bx + 2, by - 2, "#fff8c0"); c:px(bx, by - 4, "#fff8c0")
  -- tray of parcels
  part(c, R(c, 38, 36, 66, 38), "#8a8f96")
  for i = 0, 3 do
    local x = 42 + i * 6
    part(c, c:ellipse(x, 34, 3, 2), "#e8d8a0"); fl(c, R(c, x, 32, x, 36), "#c8b070")
  end
  steam(c, 44, 30, 4); steam(c, 56, 29, 4)
  finish(c, "r_ca_husk_parcel")
end

function S.r_ca_rattle_gourd()
  seed = 7
  local c = new()
  day(c, 34, { sky = { "#b8d8d8", "#cfe4d8", "#e0ecd4" }, cloud = 60, hill = "#4e8a3c", hill2 = "#5e8a44" })
  part(c, R(c, 8, 12, 10, 40), "#6b4a2e", { noline = true }); part(c, R(c, 62, 12, 64, 40), "#6b4a2e", { noline = true })
  part(c, R(c, 6, 11, 66, 13), "#8a5a35")
  local function gourd(x, y, col, hang)
    fl(c, R(c, x, 14, x, y), "#c8b070")
    part(c, c:ellipse(x, y + 2, 1, 2), col); part(c, c:ellipse(x, y + 7, 3, 4), col); c:px(x - 1, y + 6, "#f8e8b0")
  end
  gourd(15, 14, "#c8a860"); gourd(24, 16, "#9aa84a"); gourd(55, 15, "#c8a860")
  local _, G = gnome(c, 38, 47, { s = 1.25, d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 2 }, false), arm({ 4, 6 }, { 8, 12 }, true) } })
  local gx, gy = G.P(11, 13)
  part(c, c:ellipse(gx, gy, 3, 3), "#e8c870"); part(c, c:ellipse(gx - 1, gy - 4, 1, 2), "#e8c870"); c:px(gx - 1, gy, "#fff0b0")
  for _, p in ipairs({ { 6, 9 }, { 8, 11 }, { 8, 14 } }) do local a, b = G.P(p[1] + 8, p[2]); c:px(a + 4, b, "#4a3a22") end
  for _, p in ipairs({ { 11, -3 }, { 12, 1 } }) do local a, b = G.P(p[1] + 5, 10 + p[2]); fl(c, R(c, a, b, a, b + 1), "#2a1a10") end
  -- motion marks
  for _, d in ipairs({ -1, 1 }) do
    for k = 0, 1 do c:fill(R(c, gx + d * (5 + k), gy - 3 + k * 3, gx + d * (6 + k), gy - 3 + k * 3), "#fbfdfe") end
  end
  finish(c, "r_ca_rattle_gourd")
end

function S.r_ca_paper_star()
  seed = 8
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 40), { "#3a3a6a", "#5a4a8a", "#a8587a", "#d8786a", "#f0a070" }, { dir = "v" })
  c:fill(c:ellipse(18, 38, 30, 8), "#2a4a3a"); c:fill(c:ellipse(60, 39, 28, 7), "#325a3c")
  c:fill(R(c, 0, 38, W - 1, H - 1), "#3a6a3c"); c:fill(R(c, 0, 38, W - 1, 38), "#5a8a4c")
  stars(c, 8, 20, "#f4eee0")
  part(c, R(c, 9, 6, 11, 40), "#6b4a2e", { noline = true }); part(c, R(c, 61, 6, 63, 40), "#6b4a2e", { noline = true })
  part(c, R(c, 8, 6, 64, 8), "#8a5a35")
  -- star
  local cx, cy = 46, 24
  local pts, pin = {}, {}
  for i = 0, 13 do
    local a = -math.pi / 2 + i * math.pi / 7 + 0.2
    local r = (i % 2 == 0) and 8 or 4
    pts[#pts + 1] = { rnd(cx + r * math.cos(a)), rnd(cy + r * math.sin(a)) }
    local r2 = (i % 2 == 0) and 5 or 2.5
    pin[#pin + 1] = { rnd(cx + r2 * math.cos(a)), rnd(cy + r2 * math.sin(a)) }
  end
  fl(c, c:line({ { 46, 8 }, { 46, 16 } }, 1), "#d8c88a")
  part(c, c:poly(pts), "#e8a317"); c:fill(c:poly(pin), "#e0501f"); c:fill(c:ellipse(cx, cy, 1, 1), "#f5e6a8")
  for _, p in ipairs({ { 36, 33, "#f0c040" }, { 40, 38, "#e0501f" }, { 54, 34, "#5fc0a0" }, { 50, 41, "#f0c040" }, { 60, 31, "#e0501f" } }) do
    part(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), p[3], { noline = true })
  end
  -- cook tugging the rope
  local _, K = gnome(c, 62, 47, { s = 1, d = -1, hat = "#4f9a45", eyes = "happy", arms = { arm({ -4, 6 }, { -8, 12 }, true) } })
  local kx, ky = K.P(-8, 12)
  fl(c, c:line({ { kx, ky }, { 52, 29 } }, 1), "#d8c88a")
  -- jumping gnome with stick
  c:fill(c:ellipse(28, 47, 6, 1), "#2a4a30")
  local _, G = gnome(c, 28, 42, { s = 1.2, d = 1, eyes = "open", walk = 1, arms = { arm({ -4, 7 }, { -8, 17 }, false), arm({ 4, 7 }, { 8, 17 }, true) } })
  local hx, hy = G.P(8, 17)
  fl(c, c:line({ { hx, hy }, { 40, 25 } }, 1), "#8a5a35")
  finish(c, "r_ca_paper_star")
end

function S.r_ca_vine_swing()
  seed = 9
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#2f5a3a")
  for i = 1, 16 do
    local x, y = 4 + floor(rand() * 64), 5 + floor(rand() * 28)
    c:fill(c:ellipse(x, y, 4, 2), (i % 2 == 0) and "#3a7a44" or "#244a30")
  end
  c:fill(R(c, 0, 0, W - 1, 8), "#244a30")
  for x = 6, 66, 5 do c:fill(c:ellipse(x, 8, 3, 2), "#3a7a44") end
  c:fill(R(c, 0, 36, W - 1, H - 1), "#4a8fa8")
  ripples(c, 38, 48, "#8ac8d8", 9)
  c:fill(c:ellipse(6, 38, 12, 4), "#3f8a42"); c:fill(c:ellipse(66, 38, 12, 4), "#3f8a42")
  for _, x in ipairs({ 4, 9, 14, 62, 67 }) do c:fill(c:line({ { x, 38 }, { x + (x < 36 and 2 or -2), 29 } }, 1), "#5faa52") end
  part(c, c:line({ { 46, 5 }, { 44, 10 }, { 39, 19 } }, 2), "#5a7a2e")
  local _, G = gnome(c, 38, 38, { s = 1, d = -1, walk = 1, eyes = "happy", arms = { arm({ -3, 7 }, { 1, 19 }, false, true), arm({ 3, 7 }, { 0, 19 }, true) } })
  c:fill(R(c, 36, 17, 39, 19), "#f0c8a0")
  for _, p in ipairs({ { 30, 45 }, { 33, 43 }, { 44, 44 }, { 47, 46 } }) do c:px(p[1], p[2], "#e8f8f4") end
  fl(c, R(c, 40, 47, 46, 47), "#8ac8d8")
  finish(c, "r_ca_vine_swing")
end

function S.r_ca_caldera_tales()
  seed = 10
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#141a3a", "#1c2650", "#283468", "#34437a" }, { dir = "v" })
  stars(c, 18, 24)
  c:fill(c:ellipse(10, 6, 2, 2), "#f4eee0"); c:fill(c:ellipse(11, 6, 1, 1), "#34437a")
  part(c, c:poly({ { 28, 18 }, { 44, 18 }, { 62, 38 }, { 10, 38 } }), "#3a3a52")
  fl(c, R(c, 28, 18, 43, 18), "#2a2a40")
  c:fill(c:ellipse(36, 10, 3, 2), "#8a96b8"); c:fill(c:ellipse(40, 7, 2, 1), "#8a96b8")
  -- sleeping face on the mountain
  fl(c, R(c, 31, 25, 33, 25), "#1c1c30"); fl(c, R(c, 39, 25, 41, 25), "#1c1c30"); fl(c, R(c, 35, 29, 37, 29), "#1c1c30")
  c:fill(c:ellipse(8, 38, 14, 5), "#2a3a4a"); c:fill(c:ellipse(64, 38, 14, 5), "#2a3a4a")
  c:fill(R(c, 0, 38, W - 1, H - 1), "#2a3a3a"); c:fill(R(c, 0, 38, W - 1, 38), "#3a4a4a")
  -- glowing pools
  for _, p in ipairs({ { 18, 41, 11, 3 }, { 54, 40, 12, 3 } }) do
    part(c, c:ellipse(p[1], p[2], p[3] + 1, p[4] + 1), "#4a5a62")
    c:fill(c:ellipse(p[1], p[2], p[3], p[4]), "#5fe0d0"); c:fill(c:ellipse(p[1], p[2], p[3] - 3, p[4] - 1), "#a8f4e8")
  end
  for _, x in ipairs({ 16, 54, 58 }) do steam(c, x, 37, 3, "#a8d8d8") end
  part(c, R(c, 10, 46, 66, 49), "#5a5a68", { noline = true })
  for x = 14, 62, 9 do fl(c, R(c, x, 46, x, 49), "#3a3a48") end
  gnome(c, 22, 47, { s = 1, d = 1, sit = true, eyes = "open", arms = { arm({ 3, 6 }, { 5, 4 }, true) } })
  gnome(c, 50, 47, { s = 1, d = -1, hat = "#7a8aa8", eyes = "happy", arms = { arm({ -4, 6 }, { -8, 12 }, true), arm({ 4, 6 }, { 6, 4 }, false) } })
  finish(c, "r_ca_caldera_tales")
end

function S.r_ca_seed_steps()
  seed = 11
  local c = new()
  day(c, 34, { sky = { "#a8d8e0", "#c0e0e0", "#d8ecdc" }, cloud = 56, hill = "#3a7a3a", hill2 = "#2f6a34" })
  local tiers = { { 25, 63, 33, 40 }, { 29, 59, 27, 33 }, { 33, 55, 21, 27 }, { 37, 51, 15, 21 } }
  for i, t in ipairs(tiers) do
    part(c, R(c, t[1] - 4 + (i - 1) * 0 + 0, t[3], t[2] + 4, t[4]), i % 2 == 0 and "#d0c098" or "#c0b088")
  end
  fl(c, R(c, 43, 15, 45, 40), "#a89868")
  for _, t in ipairs(tiers) do fl(c, R(c, t[1] - 3, t[3], t[2] + 3, t[3]), "#e0d4a8") end
  part(c, R(c, 40, 9, 48, 15), "#c0b088"); fl(c, R(c, 43, 11, 45, 15), "#3a2a20")
  for _, x in ipairs({ 47, 51 }) do c:px(x, 21, "#f0c040"); c:px(x + 1, 21, "#f0c040") end
  c:px(54, 27, "#f0c040"); c:px(55, 27, "#f0c040"); c:px(58, 33, "#f0c040")
  c:px(59, 32, "#6aaa4a"); c:px(59, 31, "#6aaa4a"); c:px(60, 31, "#6aaa4a")
  local _, G = gnome(c, 16, 47, { s = 1.25, d = 1, walk = 1, eyes = "open", arms = { arm({ -4, 6 }, { 2, 3 }, false), arm({ 4, 6 }, { 8, 8 }, true) } })
  local bx, by = G.P(8, 8)
  fl(c, c:line({ { bx, by }, { bx + 6, by + 8 } }, 1), "#8a5a35")
  part(c, c:poly({ { bx + 4, by + 7 }, { bx + 11, by + 7 }, { bx + 12, by + 10 }, { bx + 3, by + 10 } }), "#d9b050")
  for _, p in ipairs({ { 32, 44 }, { 35, 46 }, { 30, 47 }, { 38, 44 } }) do c:fill(R(c, p[1], p[2], p[1] + 1, p[2]), "#d8c8a0") end
  finish(c, "r_ca_seed_steps")
end

function S.r_ca_shade_hammock()
  seed = 12
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#f2dd90", "#f6e8a8", "#f8f0c0" }, { dir = "v" })
  c:fill(c:ellipse(60, 10, 4, 4), "#fff4b8")
  c:fill(c:ellipse(18, 34, 34, 7), "#d8c060"); c:fill(R(c, 0, 34, W - 1, H - 1), "#c8b060"); c:fill(R(c, 0, 34, W - 1, 34), "#d8c878")
  for i = 1, 8 do local x, y = 6 + floor(rand() * 60), 40 + floor(rand() * 8); c:px(x, y, "#a8903e"); c:px(x + 1, y - 1, "#a8903e") end
  -- shimmer
  for _, p in ipairs({ { 8, 30 }, { 30, 28 }, { 52, 31 }, { 40, 24 } }) do
    for k = 0, 3 do c:px(p[1] + k * 2, p[2] + (k % 2), "#fffbe0") end
  end
  for _, x in ipairs({ 14, 58 }) do
    part(c, R(c, x - 1, 22, x + 1, 44), "#6b4a2e", { noline = true })
    part(c, c:ellipse(x, 14, 11, 8), "#3f8a42", { shade = true })
    c:fill(c:ellipse(x - 3, 12, 4, 2), "#5faa52")
  end
  for _, p in ipairs({ { 8, 16 }, { 18, 19 }, { 54, 17 }, { 62, 20 } }) do part(c, c:ellipse(p[1], p[2], 1, 2), "#e8902a"); c:px(p[1], p[2] - 1, "#f8c860") end
  -- lying gnome
  part(c, c:poly({ { 22, 36 }, { 27, 29 }, { 32, 29 }, { 32, 35 } }), "#c0442e")
  part(c, R(c, 30, 31, 34, 35), "#f0c8a0"); fl(c, R(c, 31, 33, 32, 33), "#8a4a34")
  part(c, R(c, 33, 34, 40, 37), "#f4eee0"); part(c, R(c, 38, 32, 46, 36), "#4a6e9a")
  part(c, R(c, 45, 33, 49, 36), "#5a3a22")
  -- hammock
  fl(c, c:line({ { 17, 24 }, { 24, 36 }, { 36, 40 }, { 48, 37 }, { 55, 24 } }, 2), "#e8d8a0")
  for _, x in ipairs({ 22, 30, 38, 46 }) do fl(c, R(c, x, 39, x, 41), "#c8b070") end
  fl(c, R(c, 28, 41, 48, 41), "#c8b070")
  finish(c, "r_ca_shade_hammock")
end

function S.r_cb_hatchling_guard()
  seed = 13
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 26), { "#0e1430", "#162040", "#202c52", "#2c3a64" }, { dir = "v" })
  stars(c, 22, 20)
  c:fill(c:ellipse(56, 11, 4, 4), "#f4eee0"); c:fill(c:ellipse(58, 10, 3, 3), "#2a3660")
  c:fill(R(c, 0, 26, W - 1, 33), "#1c3a5a"); c:fill(R(c, 0, 29, W - 1, 30), "#244a6a")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 31, x + 3, 31), "#6a8aa8") end
  fl(c, R(c, 54, 27, 58, 27), "#8ab0c8"); fl(c, R(c, 55, 29, 57, 29), "#8ab0c8")
  c:fill(R(c, 0, 32, W - 1, H - 1), "#5a6078"); c:fill(R(c, 0, 32, W - 1, 33), "#aab4c8")
  c:fill(R(c, 0, 40, W - 1, H - 1), "#4e546c")
  -- nest mound
  part(c, c:ellipse(12, 46, 8, 3), "#6a7088")
  for _, p in ipairs({ { 9, 45 }, { 13, 44 }, { 15, 46 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#e8e4d0", { noline = true }) end
  -- hatchlings heading to the waves
  local path = { { 20, 44 }, { 25, 42 }, { 29, 40 }, { 33, 38 }, { 37, 36 }, { 41, 35 }, { 44, 33 }, { 31, 45 }, { 38, 42 } }
  for _, p in ipairs(path) do
    part(c, c:ellipse(p[1], p[2], 2, 1), "#3a7a5a")
    c:px(p[1] - 2, p[2] - 1, "#2a5a42"); c:px(p[1] + 2, p[2] + 1, "#2a5a42"); c:px(p[1] + 2, p[2] - 1, "#2a5a42")
  end
  -- gnome with a hooded lantern, standing guard
  local _, G = gnome(c, 56, 47, { s = 1.25, d = -1, eyes = "open", arms = { arm({ -4, 6 }, { -8, 3 }, true) } })
  local lx, ly = G.P(-9, 2)
  part(c, R(c, lx - 2, ly - 2, lx + 1, ly + 2), "#e08a3a"); fl(c, R(c, lx - 1, ly - 1, lx, ly + 1), "#f8d880")
  fl(c, R(c, lx - 2, ly - 3, lx + 1, ly - 3), "#3a2a1a")
  c:fill(R(c, lx - 6, ly + 3, lx + 3, ly + 3), "#6a5a60")
  -- gulls circling off to the side
  c:px(8, 12, "#6a7088"); c:px(9, 11, "#6a7088"); c:px(10, 12, "#6a7088"); c:px(12, 14, "#6a7088"); c:px(13, 13, "#6a7088"); c:px(14, 14, "#6a7088")
  finish(c, "r_cb_hatchling_guard")
end

function S.r_cb_batten_shutters()
  seed = 14
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 36), { "#3e4a5c", "#4a5668", "#566274", "#667284" }, { dir = "v" })
  c:fill(c:ellipse(16, 14, 10, 3), "#2e3848"); c:fill(c:ellipse(46, 9, 12, 3), "#2e3848"); c:fill(c:ellipse(60, 18, 8, 2), "#37424f")
  c:fill(R(c, 0, 37, W - 1, H - 1), "#52663f"); c:fill(R(c, 0, 37, W - 1, 37), "#6a7e50")
  -- house
  part(c, R(c, 38, 17, 68, 46), "#e8c8a0")
  part(c, c:poly({ { 36, 17 }, { 53, 8 }, { 70, 17 } }), "#9a4a3a")
  part(c, R(c, 48, 24, 60, 38), "#2a2a3a"); fl(c, R(c, 54, 24, 54, 38), "#4a4a5a"); fl(c, R(c, 48, 31, 60, 31), "#4a4a5a")
  -- shutters: left one closed, right one flapping open
  part(c, R(c, 48, 24, 53, 38), "#3f8a98"); for y = 26, 36, 2 do fl(c, R(c, 49, y, 52, y), "#2e6a78") end
  part(c, c:poly({ { 61, 24 }, { 67, 21 }, { 67, 35 }, { 61, 38 } }), "#3f8a98")
  for y = 25, 33, 2 do fl(c, R(c, 62, y, 66, y - 1), "#2e6a78") end
  -- bent palm streaming right
  part(c, c:line({ { 8, 46 }, { 9, 36 }, { 14, 26 }, { 22, 22 } }, 3), "#8a6a45")
  for _, f in ipairs({ { 28, 22 }, { 30, 27 }, { 26, 18 }, { 24, 28 } }) do c:fill(c:line({ { 22, 22 }, { f[1], f[2] } }, 2), "#3f8a42") end
  c:fill(c:line({ { 22, 22 }, { 18, 28 } }, 2), "#3f8a42")
  -- gnome hammering a shutter peg
  local _, G = gnome(c, 32, 47, { s = 1.2, d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -7, 3 }, false), arm({ 4, 7 }, { 10, 13 }, true) } })
  local hx, hy = G.P(10, 13)
  fl(c, c:line({ { hx, hy }, { hx + 3, hy - 3 } }, 1), "#8a5a35"); part(c, R(c, hx + 1, hy - 6, hx + 5, hy - 3), "#8a8f96")
  local px, py = G.P(-8, 3)
  for k = 0, 2 do c:px(px + k, py + (k % 2), "#e8c48a") end
  -- wind + rain
  seed = 33
  rain(c, 34, 6, 68, 6, 48, "#c8d8e0", 2)
  for _, p in ipairs({ { 12, 14 }, { 38, 12 }, { 22, 38 } }) do fl(c, R(c, p[1], p[2], p[1] + 8, p[2]), "#e8eef2"); fl(c, R(c, p[1] + 8, p[2] + 1, p[1] + 10, p[2] + 1), "#e8eef2") end
  finish(c, "r_cb_batten_shutters")
end

function S.r_cb_palm_shin()
  seed = 15
  local c = new()
  day(c, 38, { sky = { "#9ad4e8", "#b8e0ea", "#d4ecea" }, cloud = 10, hill = "#3a8a4a", hill2 = "#2f7a40", grass = "#e0cc90", edge = "#f0e0a8" })
  c:fill(R(c, 0, 28, W - 1, 29), "#d4ecea")
  c:fill(R(c, 0, 30, W - 1, 38), "#4aa8c8"); c:fill(R(c, 0, 30, W - 1, 31), "#8adae8")
  c:fill(R(c, 0, 38, W - 1, H - 1), "#e0cc90"); c:fill(R(c, 0, 38, W - 1, 38), "#f0e0a8")
  for i = 1, 8 do local x, y = 6 + floor(rand() * 60), 41 + floor(rand() * 7); c:px(x, y, "#c8b070") end
  local tx, ty = 48, 14
  part(c, c:line({ { 38, 46 }, { 40, 36 }, { 44, 24 }, { tx, ty + 2 } }, 3), "#8a6a45")
  for i = 1, 5 do local yy = 44 - i * 6; fl(c, R(c, 38 + (44 - yy) // 6 * 2 - 1, yy, 38 + (44 - yy) // 6 * 2 + 1, yy), "#6a4a2e") end
  for _, f in ipairs({ { -11, 4 }, { -7, -2 }, { -3, -5 }, { 4, -5 }, { 9, -1 }, { 12, 4 } }) do
    c:fill(c:line({ { tx, ty }, { tx + f[1] // 2, ty + f[2] - 1 }, { tx + f[1], ty + f[2] + 3 } }, 2), "#3f8a42")
    c:px(tx + f[1] // 2, ty + f[2] - 2, "#6ac05a")
  end
  for _, p in ipairs({ { tx - 2, ty + 2 }, { tx + 1, ty + 3 }, { tx + 3, ty + 2 }, { tx, ty + 5 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#6a4a2a"); c:px(p[1] - 1, p[2] - 1, "#a8844a") end
  -- gnome hugging the trunk
  local _, G = gnome(c, 33, 39, { s = 1.1, d = 1, walk = 1, eyes = "open", arms = { arm({ 3, 7 }, { 6, 13 }, true), arm({ 3, 6 }, { 6, 9 }, true) } })
  c:fill(c:ellipse(34, 47, 6, 1), "#c8b070")
  c:px(30, 18, "#a8e0f0"); c:px(30, 19, "#a8e0f0")
  finish(c, "r_cb_palm_shin")
end

function S.r_cb_galleon_peek()
  seed = 16
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#8ad8d0", "#6ac8c4", "#4ab4b4", "#3a9ca4", "#2e8a98" }, { dir = "v" })
  for _, x in ipairs({ 14, 30, 48, 60 }) do c:fill(c:poly({ { x, 5 }, { x + 4, 5 }, { x + 8, 30 }, { x - 4, 30 } }), "#82d8d0") end
  c:fill(R(c, 0, 5, W - 1, 6), "#d8f4f0")
  c:fill(R(c, 0, 39, W - 1, H - 1), "#d8c890"); c:fill(c:ellipse(30, 40, 40, 4), "#d8c890")
  for i = 1, 8 do local x, y = 6 + floor(rand() * 60), 42 + floor(rand() * 6); c:px(x, y, "#b8a870") end
  -- galleon hull, tilted
  part(c, c:poly({ { 8, 24 }, { 40, 20 }, { 44, 28 }, { 36, 42 }, { 14, 42 } }), "#6a4630")
  fl(c, c:line({ { 9, 26 }, { 41, 22 } }, 1), "#8a6a45")
  for _, p in ipairs({ { 16, 31 }, { 24, 29 }, { 32, 27 } }) do
    part(c, c:ellipse(p[1], p[2], 2, 2), "#a8e8c8"); c:fill(c:ellipse(p[1], p[2], 1, 1), "#e8f8d8")
  end
  c:fill(c:ellipse(16, 31, 1, 1), "#e8902a"); c:px(15, 31, "#e8902a"); c:px(24, 28, "#e8f8d8")
  part(c, R(c, 24, 7, 25, 22), "#5a3a26", { noline = true }); fl(c, c:line({ { 25, 9 }, { 32, 13 } }, 1), "#5a3a26")
  c:fill(c:poly({ { 14, 22 }, { 14, 36 }, { 6, 38 } }), "#2e8a98")
  -- fish
  for _, p in ipairs({ { 50, 14 }, { 12, 12 }, { 56, 24 } }) do
    part(c, c:ellipse(p[1], p[2], 2, 1), "#e8902a"); c:px(p[1] - 3, p[2] - 1, "#e8902a"); c:px(p[1] - 3, p[2] + 1, "#e8902a")
  end
  fl(c, R(c, 50, 45, 52, 45), "#fbfdfe"); c:px(51, 44, "#fbfdfe")
  -- gnome snorkelling, peeking
  fl(c, c:line({ { 54, 6 }, { 54, 22 } }, 1), "#e8902a"); c:fill(R(c, 53, 5, 55, 6), "#c0442e")
  local _, G = gnome(c, 54, 38, { s = 1, d = -1, walk = 1, eyes = "open", arms = { arm({ -3, 6 }, { -7, 7 }, true) } })
  local mx, my = G.P(-2, 10)
  part(c, R(c, mx - 4, my - 2, mx + 2, my + 1), "#bfe8f0", { noline = true }); fl(c, R(c, mx - 4, my - 2, mx + 2, my - 2), "#2a5a6a"); fl(c, R(c, mx - 4, my + 1, mx + 2, my + 1), "#2a5a6a")
  c:px(mx - 1, my, "#2a1a10"); c:px(mx - 3, my, "#2a1a10")
  for _, p in ipairs({ { 60, 22 }, { 62, 28 }, { 58, 33 } }) do ring(c, p[1], p[2], 1, 1, "#e8f8f4") end
  c:px(41, 44, "#d8d8e0"); c:px(42, 43, "#fbfdfe"); c:px(41, 45, "#d8d8e0")
  finish(c, "r_cb_galleon_peek")
end

function S.r_cb_mangrove_punt()
  seed = 17
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 32), { "#c8d4d0", "#d4dcd8", "#dde4e0", "#e4eae6" }, { dir = "v" })
  c:fill(R(c, 0, 33, W - 1, H - 1), "#9ab4ac"); c:fill(R(c, 0, 33, W - 1, 34), "#c0d4cc")
  ripples(c, 36, 48, "#c0d4cc", 10)
  -- hazy far canopy
  for _, p in ipairs({ { 12, 12, 11, 5 }, { 56, 10, 13, 4 }, { 34, 8, 8, 3 } }) do c:fill(c:ellipse(p[1], p[2], p[3], p[4]), "#a8c0b0") end
  -- root arches left and right
  local function root(x0, y0, x1, y1, w, col)
    c:fill(c:line({ { x0, y0 }, { (x0 + x1) // 2, y0 + (y1 - y0) // 3 }, { x1, y1 } }, w), col or "#5a4a30")
  end
  for i, p in ipairs({ { 10, 12, 4, 40 }, { 14, 14, 20, 40 }, { 9, 14, 12, 40 }, { 62, 12, 68, 40 }, { 58, 14, 52, 40 }, { 64, 14, 60, 40 } }) do root(p[1], p[2], p[3], p[4], 2) end
  c:fill(c:ellipse(11, 10, 9, 4), "#5f8a58"); c:fill(c:ellipse(62, 9, 9, 4), "#5f8a58")
  for _, p in ipairs({ { 8, 27 }, { 18, 30 }, { 13, 35 }, { 64, 27 }, { 55, 30 }, { 62, 35 } }) do fl(c, R(c, p[1], p[2], p[1], p[2] + 2), "#dd3a2a"); c:px(p[1] + 1, p[2] + 2, "#dd3a2a") end
  -- punt
  part(c, c:poly({ { 20, 41 }, { 54, 41 }, { 50, 46 }, { 24, 46 } }), "#8a5a35")
  fl(c, R(c, 22, 41, 52, 41), "#b07a45")
  local _, G = gnome(c, 38, 42, { s = 1.1, d = 1, upper = false, eyes = "open", arms = { arm({ -4, 7 }, { -7, 11 }, false), arm({ 4, 7 }, { 8, 12 }, true) } })
  local hx, hy = G.P(8, 12)
  fl(c, c:line({ { hx - 2, hy - 7 }, { hx + 10, hy + 20 } }, 1), "#8a5a35")
  c:fill(R(c, hx + 8, 45, hx + 14, 45), "#e4eae6"); c:fill(R(c, hx + 6, 47, hx + 10, 47), "#e4eae6")
  fl(c, R(c, 24, 47, 50, 47), "#c0d4cc")
  finish(c, "r_cb_mangrove_punt")
end

function S.r_cb_cane_press()
  seed = 18
  local c = new()
  day(c, 34, { sky = { "#a8d8e0", "#c0e4e4", "#d8ecdc" }, cloud = 52, hill = "#4e8a3c", hill2 = "#5e9a44" })
  -- cane field
  for x = 6, 26, 3 do
    fl(c, R(c, x, 12 + (x % 2) * 2, x, 38), "#7ab04a")
    for y = 16, 36, 5 do c:px(x, y, "#d8d070") end
    c:fill(c:line({ { x, 12 + (x % 2) * 2 }, { x - 3, 10 } }, 1), "#5f9a3a"); c:fill(c:line({ { x, 12 + (x % 2) * 2 }, { x + 3, 9 } }, 1), "#5f9a3a")
  end
  -- press
  part(c, R(c, 30, 36, 56, 40), "#8a5a35")
  part(c, R(c, 36, 22, 40, 36), "#b07a45"); part(c, R(c, 44, 22, 48, 36), "#b07a45")
  for y = 25, 33, 4 do fl(c, R(c, 36, y, 40, y), "#8a5a35"); fl(c, R(c, 44, y, 48, y), "#8a5a35") end
  part(c, R(c, 33, 18, 51, 22), "#8a5a35")
  part(c, R(c, 41, 14, 43, 18), "#6b4a2e")
  fl(c, c:line({ { 42, 20 }, { 62, 38 } }, 2), "#6b4a2e")
  fl(c, c:line({ { 27, 28 }, { 36, 29 } }, 2), "#7ab04a")
  -- bucket with juice
  part(c, R(c, 40, 41, 50, 48), "#8a5a35"); fl(c, R(c, 41, 42, 49, 43), "#e8d870"); fl(c, R(c, 40, 44, 50, 44), "#5e3f28")
  c:px(44, 38, "#e8d870"); c:px(44, 40, "#e8d870")
  -- wasps
  for _, p in ipairs({ { 54, 36 }, { 56, 31 }, { 36, 41 } }) do
    fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#e8c23a"); c:px(p[1] + 1, p[2], "#2a1a10"); c:px(p[1], p[2] - 1, "#d8f0f4"); c:px(p[1] + 1, p[2] - 1, "#d8f0f4")
  end
  local _, G = gnome(c, 62, 47, { s = 1.2, d = -1, walk = 1, eyes = "open", arms = { arm({ -4, 7 }, { -8, 8 }, true) } })
  finish(c, "r_cb_cane_press")
end

function S.r_cb_sulphur_mud()
  seed = 19
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#b8ccc0", "#c8d8cc", "#d6e2d4", "#e2ebdc" }, { dir = "v" })
  part(c, c:poly({ { 4, 30 }, { 18, 10 }, { 32, 30 } }), "#8ab09a"); part(c, c:poly({ { 26, 30 }, { 46, 6 }, { 66, 30 } }), "#7aa08a")
  part(c, c:poly({ { 50, 30 }, { 60, 17 }, { 70, 30 } }), "#6a9078")
  for _, p in ipairs({ { 18, 14 }, { 17, 16 }, { 46, 10 }, { 45, 13 }, { 60, 20 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#d8c84a") end
  for _, y in ipairs({ 22, 26 }) do fl(c, R(c, 8, y, 60, y), "#dbe6dc") end
  c:fill(R(c, 0, 31, W - 1, H - 1), "#9a9a88"); c:fill(R(c, 0, 31, W - 1, 31), "#b0b098")
  part(c, c:ellipse(36, 41, 30, 8), "#c8b84a", { shade = true })
  c:fill(c:ellipse(36, 41, 27, 6), "#7a7a72")
  for _, p in ipairs({ { 14, 41, 2 }, { 20, 44, 3 }, { 54, 42, 3 }, { 58, 40, 2 }, { 48, 45, 2 } }) do ring(c, p[1], p[2], p[3], p[3] - 1, "#a8a8a0") end
  gnome(c, 38, 45, { s = 1.2, d = 1, eyes = "shut", upper = true, arms = {} })
  c:fill(c:ellipse(38, 42, 14, 4), "#7a7a72"):fill(R(c, 24, 42, 52, 42), "#7a7a72")
  c:fill(R(c, 24, 41, 52, 41), "#8a8a82")
  for x = 24, 52 do if x % 3 == 0 then c:px(x, 41, "#a8a8a0") end end
  -- mud blob on hat
  c:fill(c:ellipse(37, 31, 2, 1), "#7a7a72")
  -- floating arms
  fl(c, R(c, 25, 40, 29, 41), "#4a6e9a"); fl(c, R(c, 47, 40, 51, 41), "#4a6e9a"); fl(c, R(c, 23, 39, 25, 41), "#f0c8a0"); fl(c, R(c, 51, 39, 53, 41), "#f0c8a0")
  -- sulphur fumes
  local function fume(x, y) for i = 0, 5 do c:px(x + ((i // 2) % 2) * 2 - 1 + (i % 2), y - i * 2, "#d0d870"); c:px(x + ((i // 2) % 2) * 2 + (i % 2), y - i * 2 - 1, "#d0d870") end end
  fume(14, 38); fume(60, 38); fume(20, 37)
  finish(c, "r_cb_sulphur_mud")
end

function S.r_cb_squall_dash()
  seed = 20
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#8ac8e8", "#a8d8ec", "#c8e6ee" }, { dir = "v" })
  -- rainbow at right
  for i, col in ipairs({ "#e0502f", "#f0a030", "#f0e060", "#5fb050", "#4a8ad0", "#8a5ab0" }) do
    local r = 26 - i
    c:fill(c:ellipse(56, 40, r + 1, r + 1):clip(R(c, 0, 0, W, 38)), col)
  end
  c:fill(c:ellipse(56, 40, 19, 19):clip(R(c, 0, 0, W, 38)), "#c8e6ee")
  c:fill(c:ellipse(66, 9, 3, 3), "#fff0a0")
  -- squall cloud, left
  c:fill(c:ellipse(18, 10, 22, 6), "#4a5668"); c:fill(c:ellipse(10, 15, 14, 4), "#586478"); c:fill(c:ellipse(28, 14, 12, 3), "#3e4a5c")
  seed = 41
  rain(c, 36, 6, 34, 15, 48, "#b8cce0", 1)
  c:fill(R(c, 0, 36, W - 1, H - 1), "#7ea85a"); c:fill(R(c, 0, 36, W - 1, 36), "#9cc070")
  c:fill(R(c, 5, 38, 34, 49), "#6a8a60")
  c:fill(c:ellipse(18, 47, 8, 1), "#6aa8c8")
  -- market awning
  part(c, R(c, 52, 24, 68, 28), "#dd3a2a"); for x = 53, 67, 4 do fl(c, R(c, x, 24, x + 1, 28), "#f4eee0") end
  fl(c, R(c, 53, 29, 53, 40), "#6b3b2a"); fl(c, R(c, 66, 29, 66, 40), "#6b3b2a")
  part(c, R(c, 54, 38, 67, 41), "#b07a45")
  part(c, c:ellipse(58, 37, 2, 1), "#e0501f"); part(c, c:ellipse(63, 37, 2, 1), "#f0c040")
  -- gnome dashing with a banana leaf over his head
  local _, G = gnome(c, 32, 46, { s = 1.2, d = 1, walk = 1, eyes = "happy", arms = { arm({ -4, 7 }, { -8, 20 }, false, true), arm({ 4, 7 }, { 7, 21 }, true) } })
  part(c, c:ellipse(30, 21, 11, 2), "#4faa4a"); fl(c, R(c, 22, 21, 38, 21), "#2f7a36"); c:px(24, 23, "#4faa4a"); c:px(36, 23, "#4faa4a")
  seed = 51
  finish(c, "r_cb_squall_dash")
end

function S.r_cb_whale_spouts()
  seed = 21
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#b0c8dc", "#bcd2e2", "#c8dce8", "#d6e6ee" }, { dir = "v" })
  c:fill(c:ellipse(12, 10, 8, 2), "#eef4f8"); c:fill(c:ellipse(60, 7, 7, 2), "#eef4f8")
  c:fill(R(c, 0, 28, W - 1, H - 1), "#3a6a98"); c:fill(R(c, 0, 28, W - 1, 29), "#6a9ac0")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#2f5a88")
  ripples(c, 30, 44, "#6a9ac0", 12)
  -- whales and spouts
  for _, w in ipairs({ { 52, 35 }, { 64, 31 }, { 17, 31 } }) do
    part(c, c:ellipse(w[1], w[2], 5, 2), "#3a4a62"); c:px(w[1] - 3, w[2] - 2, "#3a4a62"); fl(c, R(c, w[1] - 7, w[2] - 1, w[1] - 6, w[2]), "#3a4a62")
    local sx, sy = w[1] + 1, w[2] - 3
    fl(c, R(c, sx, sy - 5, sx, sy), "#f4f8fa"); c:px(sx - 1, sy - 5, "#f4f8fa"); c:px(sx + 1, sy - 5, "#f4f8fa"); c:px(sx - 2, sy - 4, "#f4f8fa"); c:px(sx + 2, sy - 4, "#f4f8fa")
  end
  -- balcony rail
  part(c, R(c, 4, 40, 69, 42), "#a8703e"); fl(c, R(c, 4, 40, 69, 40), "#c08a52")
  for x = 8, 66, 6 do fl(c, R(c, x, 43, x + 1, 49), "#8a5a35") end
  -- chalk tally slate
  part(c, R(c, 4, 32, 24, 39), "#8a5a35"); c:fill(R(c, 5, 33, 23, 38), "#2a3a3a")
  for _, x in ipairs({ 7, 9, 11, 13 }) do fl(c, R(c, x, 34, x, 37), "#f4f4e8") end
  fl(c, c:line({ { 6, 37 }, { 15, 34 } }, 1), "#f4f4e8")
  for _, x in ipairs({ 18, 20 }) do fl(c, R(c, x, 34, x, 37), "#f4f4e8") end
  -- gnome with spyglass
  local _, G = gnome(c, 36, 44, { s = 1.2, d = 1, upper = true, eyes = "open", arms = { arm({ 4, 7 }, { 6, 12 }, true) } })
  local hx, hy = G.P(6, 12)
  fl(c, c:line({ { hx - 3, hy + 1 }, { hx + 9, hy - 2 } }, 2), "#8a5a35"); fl(c, R(c, hx + 8, hy - 3, hx + 10, hy), "#d8a83a"); fl(c, R(c, hx - 3, hy, hx - 2, hy + 1), "#d8a83a")
  finish(c, "r_cb_whale_spouts")
end

function S.r_cb_fish_pot()
  seed = 22
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#8a7098", "#b8708a", "#e88a7a", "#f4a878", "#f4c890" }, { dir = "v" })
  c:fill(c:ellipse(36, 30, 9, 8):clip(R(c, 0, 0, W, 30)), "#fff0a0"); c:fill(c:ellipse(36, 30, 6, 5):clip(R(c, 0, 0, W, 30)), "#fffad0")
  c:fill(R(c, 0, 30, W - 1, H - 1), "#4a6a98"); c:fill(R(c, 0, 30, W - 1, 31), "#f4c890")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#3e5a88")
  for y = 32, 44, 3 do fl(c, R(c, 30 + (y % 2) * 2, y, 42 - (y % 2) * 2, y), "#f4d890") end
  -- reef patch
  c:fill(c:ellipse(12, 46, 12, 4), "#4aa8a8"); for _, p in ipairs({ { 8, 45 }, { 14, 44 }, { 19, 46 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#e0705a") end
  -- boat
  part(c, c:poly({ { 20, 38 }, { 58, 38 }, { 54, 44 }, { 24, 44 } }), "#8a5a35"); fl(c, R(c, 22, 38, 56, 38), "#c08a52")
  local _, G = gnome(c, 34, 39, { s = 1.1, d = 1, eyes = "open", arms = { arm({ -4, 7 }, { 4, 5 }, false), arm({ 4, 7 }, { 11, 6 }, true) } })
  local hx, hy = G.P(11, 6)
  fl(c, c:line({ { hx, hy }, { 56, 38 } }, 1), "#d8c88a")
  -- pot hauled up at the gunwale
  part(c, c:ellipse(58, 36, 5, 4), "#c89a58"); fl(c, R(c, 54, 36, 62, 36), "#8a6a38"); fl(c, R(c, 58, 33, 58, 39), "#8a6a38")
  c:fill(c:ellipse(58, 31, 2, 1), "#e8902a"); c:px(55, 30, "#e8902a"); c:px(55, 32, "#e8902a")
  for _, p in ipairs({ { 55, 41 }, { 60, 42 }, { 58, 44 } }) do c:px(p[1], p[2], "#8ac8d8"); c:px(p[1], p[2] + 1, "#8ac8d8") end
  part(c, c:ellipse(12, 33, 1, 1), "#dd3a2a")
  finish(c, "r_cb_fish_pot")
end

function S.r_cb_rice_peas()
  seed = 23
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#6a5a52")
  for y = 5, 38, 4 do for x = (y // 4 % 2) * 4, W, 8 do fl(c, R(c, x, y, x + 6, y), "#8a7a70"); fl(c, R(c, x + 7, y, x + 7, y + 3), "#4a3e38") end end
  -- shelf with jars
  part(c, R(c, 36, 12, 68, 14), "#a8703e")
  jar(c, 40, 7, 5, 5, "#f4eee0"); jar(c, 48, 7, 5, 5, "#c0442e"); jar(c, 56, 7, 5, 5, "#8aaa4a"); jar(c, 63, 8, 4, 4, "#e8c23a")
  c:fill(R(c, 0, 39, W - 1, H - 1), "#8a6a48"); c:fill(R(c, 0, 39, W - 1, 39), "#a8845a")
  -- hearth fire and pot
  part(c, R(c, 36, 40, 66, 48), "#5a5258"); fl(c, R(c, 38, 42, 64, 47), "#2a2428")
  for _, p in ipairs({ { 44, 43, 5 }, { 52, 42, 7 }, { 59, 43, 5 } }) do
    c:fill(c:poly({ { p[1] - 3, 47 }, { p[1], 47 - p[3] }, { p[1] + 3, 47 } }), "#e0501f"); c:fill(c:poly({ { p[1] - 1, 47 }, { p[1], 47 - p[3] + 3 }, { p[1] + 1, 47 } }), "#f8d040")
  end
  part(c, c:ellipse(51, 33, 12, 7), "#2a2a32"); c:fill(c:ellipse(51, 31, 11, 4), "#3a3a44")
  c:fill(c:ellipse(51, 31, 9, 2), "#f4eee0")
  for _, p in ipairs({ { 46, 31 }, { 50, 30 }, { 54, 31 }, { 57, 30 }, { 48, 32 } }) do c:px(p[1], p[2], "#8a6a38") end
  fl(c, R(c, 38, 33, 40, 34), "#2a2a32"); fl(c, R(c, 62, 33, 64, 34), "#2a2a32")
  -- lid tilted on the rim
  part(c, c:ellipse(46, 25, 6, 2), "#4a4a56"); c:px(46, 23, "#8a8f96")
  steam(c, 52, 27, 5); steam(c, 57, 26, 4)
  -- gnome stirring with a long spoon
  local _, G = gnome(c, 20, 47, { s = 1.25, d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 6 }, { 9, 10 }, true) } })
  local hx, hy = G.P(9, 10)
  fl(c, c:line({ { hx - 2, hy + 4 }, { 52, 30 } }, 1), "#d9a660"); part(c, c:ellipse(53, 30, 2, 1), "#d9a660")
  -- sack of rice
  part(c, R(c, 6, 40, 14, 48), "#e8d8a8"); fl(c, R(c, 7, 39, 13, 39), "#f4eee0"); fl(c, R(c, 8, 44, 12, 44), "#c8b070")
  finish(c, "r_cb_rice_peas")
end

function S.r_cb_coir_rope()
  seed = 24
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 24), { "#a8d8e8", "#bce2ea", "#d0ecec" }, { dir = "v" })
  c:fill(R(c, 0, 24, W - 1, 33), "#4aa8c8"); c:fill(R(c, 0, 24, W - 1, 24), "#8adae8"); ripples(c, 26, 32, "#8adae8", 8)
  c:fill(R(c, 0, 34, W - 1, H - 1), "#b8905a")
  for y = 35, 48, 5 do fl(c, R(c, 0, y, W - 1, y), "#8a6a40") end
  part(c, R(c, 60, 14, 62, 34), "#6b4a2e", { noline = true }); part(c, R(c, 8, 26, 10, 36), "#6b4a2e", { noline = true })
  -- husk pile and fibre
  for _, p in ipairs({ { 55, 43 }, { 60, 44 }, { 65, 43 }, { 58, 40 }, { 63, 40 } }) do part(c, c:ellipse(p[1], p[2], 3, 2), "#8a6a3a"); c:px(p[1] - 1, p[2] - 1, "#a8844a"); c:px(p[1] + 1, p[2], "#6a4a28") end
  for _, p in ipairs({ { 6, 44 }, { 10, 46 }, { 5, 47 } }) do c:fill(c:ellipse(p[1], p[2], 3, 1), "#d8b078"); c:px(p[1] - 2, p[2] - 1, "#d8b078"); c:px(p[1] + 2, p[2] - 1, "#d8b078") end
  -- seat
  part(c, R(c, 14, 44, 28, 49), "#8a5a35"); fl(c, R(c, 14, 44, 28, 44), "#b07a45")
  local _, G = gnome(c, 20, 44, { s = 1.1, d = 1, sit = true, eyes = "open", arms = { arm({ 4, 7 }, { 7, 3 }, true), arm({ -3, 6 }, { 1, 2 }, true) } })
  local hx, hy = G.P(7, 3)
  -- twisted rope running right to a coil
  local pts = { { hx + 1, hy + 1 }, { hx + 8, hy + 3 }, { 44, 45 } }
  c:fill(c:line(pts, 2), "#c89a58")
  for x = hx + 3, 42, 3 do c:px(x, hy + 2 + (x - hx) // 8, "#8a6a38") end
  for k, r in ipairs({ 6, 4, 2 }) do ring(c, 48, 45, r + 1, math.max(1, r // 2 + 1), k % 2 == 0 and "#a8844a" or "#c89a58") end
  c:fill(c:ellipse(48, 45, 1, 0), "#8a6a38")
  finish(c, "r_cb_coir_rope")
end

function S.r_cb_fruit_platter()
  seed = 25
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#e8d8a8")
  c:fill(R(c, 5, 5, 68, 13), "#f4eee0")
  for x = 5, 68, 8 do c:fill(R(c, x, 5, x + 3, 13), "#dd3a2a") end
  for x = 5, 68, 4 do c:fill(R(c, x, 14, x + 3, 14), (x // 4 % 2 == 0) and "#dd3a2a" or "#f4eee0") end
  fl(c, R(c, 5, 15, 68, 15), "#8a4a2a")
  part(c, c:ellipse(60, 24, 3, 3), "#f0c040"); part(c, c:ellipse(54, 22, 3, 2), "#e87a8a")
  part(c, R(c, 8, 20, 12, 30), "#a8d4e0", { noline = true })
  local _, G = gnome(c, 20, 43, { s = 1.3, d = 1, upper = true, eyes = "open", arms = { arm({ -4, 6 }, { -3, 10 }, true), arm({ 4, 6 }, { 11, 9 }, true) } })
  local kx, ky = G.P(11, 9)
  -- table
  part(c, R(c, 3, 40, 69, 42), "#b07a45"); fl(c, R(c, 3, 40, 69, 40), "#d9a660")
  c:fill(R(c, 4, 43, 68, 49), "#f4eee0"); for x = 4, 68, 6 do c:fill(R(c, x, 43, x + 2, 49), "#e87a8a") end
  -- platter
  part(c, c:ellipse(46, 39, 17, 3), "#d8e0e4")
  c:fill(c:ellipse(46, 38, 15, 2), "#eef2f4")
  for i, p in ipairs({ { 36, 37 }, { 41, 38 } }) do
    part(c, c:ellipse(p[1], p[2], 3, 2), "#e87a8a"); c:fill(c:ellipse(p[1], p[2], 2, 1), "#f4a0a8"); c:px(p[1], p[2], "#f8d8d8")
  end
  for _, p in ipairs({ { 47, 37 }, { 52, 38 }, { 57, 37 } }) do part(c, c:ellipse(p[1], p[2], 2, 2), "#f0c040"); c:px(p[1], p[2], "#fff0a0") end
  part(c, c:ellipse(30, 36, 4, 4), "#7aaa4a"); c:fill(c:ellipse(31, 37, 2, 2), "#e8f0d0")
  for _, p in ipairs({ { 28, 34 }, { 31, 33 }, { 33, 36 } }) do c:px(p[1], p[2], "#4a7a2e") end
  -- knife + slice
  fl(c, c:line({ { kx, ky }, { kx + 6, ky - 1 } }, 1), "#d0d8dc")
  finish(c, "r_cb_fruit_platter")
end

function S.r_cb_fish_tea()
  seed = 26
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 26), { "#a8d8e8", "#bce2ea", "#d0ecec" }, { dir = "v" })
  c:fill(R(c, 0, 20, W - 1, 28), "#4aa8c8"); c:fill(R(c, 0, 20, W - 1, 20), "#8adae8")
  c:fill(R(c, 0, 29, W - 1, H - 1), "#e0cc90"); c:fill(R(c, 0, 29, W - 1, 29), "#f0e0a8")
  for i = 1, 9 do local x, y = 6 + floor(rand() * 60), 32 + floor(rand() * 16); c:px(x, y, "#c8b070") end
  palm(c, 62, 40, 24, -3)
  part(c, R(c, 8, 41, 22, 44), "#8a6a45")
  -- fire and tripod pot
  fl(c, c:line({ { 30, 44 }, { 38, 28 } }, 1), "#5e3f28"); fl(c, c:line({ { 46, 44 }, { 38, 28 } }, 1), "#5e3f28")
  for _, p in ipairs({ { 33, 46, 5 }, { 38, 46, 8 }, { 43, 46, 5 } }) do
    c:fill(c:poly({ { p[1] - 3, 47 }, { p[1], 47 - p[3] }, { p[1] + 3, 47 } }), "#e0501f"); c:fill(c:poly({ { p[1] - 1, 47 }, { p[1], 47 - p[3] + 3 }, { p[1] + 1, 47 } }), "#f8d040")
  end
  part(c, c:ellipse(38, 38, 10, 5), "#2a2a32"); c:fill(c:ellipse(38, 36, 9, 3), "#e8c070")
  part(c, c:ellipse(34, 36, 2, 1), "#e8902a"); part(c, c:ellipse(43, 36, 2, 1), "#e8902a")
  c:fill(R(c, 37, 34, 38, 35), "#e8902a"); c:px(36, 33, "#e8902a"); c:px(39, 33, "#e8902a")
  part(c, c:ellipse(39, 36, 1, 1), "#8ac05a")
  steam(c, 31, 33, 4); steam(c, 46, 33, 4)
  -- gnome with a squeezed lime
  local _, G = gnome(c, 18, 46, { s = 1.25, d = 1, sit = true, eyes = "happy", arms = { arm({ 4, 6 }, { 15, 9 }, true) } })
  local lx, ly = G.P(15, 10)
  part(c, c:ellipse(lx, ly, 2, 2), "#8ac05a"); c:fill(c:ellipse(lx, ly, 1, 1), "#d8f08a")
  c:px(lx, ly + 3, "#d8f08a"); c:px(lx - 1, ly + 5, "#d8f08a")
  finish(c, "r_cb_fish_tea")
end

function S.r_cb_mango_chutney()
  seed = 27
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#7a5a42")
  for x = 5, W, 6 do fl(c, R(c, x, 0, x, 38), "#5e4430") end
  for _, x in ipairs({ 10, 22, 34 }) do
    fl(c, R(c, x, 5, x, 8), "#d8c88a")
    c:fill(c:ellipse(x, 11, 2, 3), (x == 22) and "#8aaa4a" or "#6a9a46"); c:px(x, 13, "#4a7a2e")
  end
  part(c, R(c, 40, 20, 68, 22), "#a8703e")
  jar(c, 42, 14, 5, 6, "#e8902a"); jar(c, 50, 14, 5, 6, "#f0b840"); jar(c, 58, 14, 5, 6, "#e8902a")
  part(c, R(c, 40, 30, 68, 32), "#a8703e")
  jar(c, 44, 24, 5, 6, "#8aaa4a"); jar(c, 54, 24, 5, 6, "#e8902a"); jar(c, 62, 25, 4, 5, "#d8a860")
  local _, G = gnome(c, 18, 43, { s = 1.3, d = 1, upper = true, eyes = "happy", arms = { arm({ 4, 6 }, { 8, 12 }, true) } })
  local sx, sy = G.P(8, 12)
  fl(c, c:line({ { sx, sy }, { sx + 6, sy + 5 } }, 1), "#d9a660"); part(c, c:ellipse(sx + 7, sy + 6, 2, 1), "#e8902a")
  -- table
  part(c, R(c, 3, 39, 69, 42), "#b07a45"); fl(c, R(c, 3, 39, 69, 39), "#d9a660")
  c:fill(R(c, 4, 43, 68, 49), "#8a5a35"); for x = 10, 66, 8 do fl(c, R(c, x, 43, x, 49), "#6b3b2a") end
  -- pot of chutney
  part(c, c:ellipse(36, 37, 8, 4), "#2a2a32"); c:fill(c:ellipse(36, 35, 7, 2), "#e8902a"); c:px(34, 35, "#f8d070"); c:px(38, 35, "#d07a20")
  steam(c, 33, 32, 3); steam(c, 38, 31, 3)
  -- mangoes, ginger, lime
  for _, p in ipairs({ { 50, 37 }, { 56, 38 } }) do part(c, c:ellipse(p[1], p[2], 3, 2), "#f0a030"); c:px(p[1] - 1, p[2] - 1, "#e0502f"); c:px(p[1] + 1, p[2], "#f8d070") end
  part(c, c:ellipse(62, 37, 2, 2), "#e8902a"); c:fill(c:ellipse(62, 37, 1, 1), "#f8c860")
  part(c, R(c, 65, 37, 68, 38), "#d8b078"); part(c, c:ellipse(66, 36, 1, 1), "#d8b078")
  part(c, c:ellipse(46, 38, 2, 1), "#8ac05a"); c:px(46, 38, "#d8f08a")
  finish(c, "r_cb_mango_chutney")
end

function S.r_cb_tin_pan()
  seed = 28
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#5a4a3a")
  for x = 4, W, 7 do fl(c, R(c, x, 0, x, 38), "#443628") end
  -- tools on the wall
  fl(c, R(c, 8, 9, 24, 9), "#8a5a35")
  fl(c, R(c, 10, 10, 10, 18), "#8a8f96"); fl(c, R(c, 15, 10, 15, 16), "#8a5a35"); part(c, R(c, 13, 16, 17, 18), "#8a8f96"); fl(c, R(c, 20, 10, 20, 17), "#8a5a35"); part(c, R(c, 19, 10, 22, 12), "#a8b0b8")
  -- notes
  local function note(x, y, col)
    fl(c, R(c, x + 2, y, x + 2, y + 5), col); c:fill(R(c, x, y + 5, x + 2, y + 6), col); c:px(x + 3, y, col); c:px(x + 4, y + 1, col)
  end
  note(54, 8, "#f5cf6a"); note(62, 14, "#5fe0d0"); note(48, 15, "#f08a7a")
  -- bench
  part(c, R(c, 3, 38, 69, 41), "#b07a45"); fl(c, R(c, 3, 38, 69, 38), "#d9a660")
  c:fill(R(c, 4, 42, 68, 49), "#6a4a30")
  -- tin drum-lid, tilted toward us
  part(c, c:ellipse(46, 31, 18, 7), "#8a929c")
  c:fill(c:ellipse(46, 31, 16, 6), "#b8c0c8")
  ring(c, 46, 31, 13, 5, "#f4f4e8"); ring(c, 46, 31, 8, 3, "#f4f4e8")
  for _, p in ipairs({ { 36, 29 }, { 41, 27 }, { 52, 27 }, { 57, 30 }, { 44, 34 }, { 50, 34 } }) do c:fill(c:ellipse(p[1], p[2], 1, 1), "#7a828c") end
  c:px(46, 31, "#7a828c"); c:px(47, 31, "#7a828c")
  c:px(30, 33, "#dcdcd0"); c:px(31, 33, "#dcdcd0")
  fl(c, R(c, 40, 38, 52, 38), "#443628")
  -- gnome with a little hammer, tapping a dent
  local _, G = gnome(c, 16, 44, { s = 1.3, d = 1, upper = true, eyes = "open", arms = { arm({ 4, 6 }, { 10, 14 }, true) } })
  local hx, hy = G.P(10, 14)
  fl(c, c:line({ { hx, hy }, { hx + 6, hy + 8 } }, 1), "#8a5a35"); part(c, R(c, hx + 4, hy + 8, hx + 9, hy + 11), "#8a8f96")
  c:px(hx + 11, hy + 12, "#fff0a0"); c:px(hx + 12, hy + 9, "#fff0a0"); c:px(hx + 10, hy + 14, "#fff0a0")
  finish(c, "r_cb_tin_pan")
end

local order = { "r_ca_smokecap_stones", "r_ca_husk_parcel", "r_ca_rattle_gourd", "r_ca_paper_star", "r_ca_vine_swing", "r_ca_caldera_tales", "r_ca_seed_steps", "r_ca_shade_hammock",
  "r_cb_hatchling_guard", "r_cb_batten_shutters", "r_cb_palm_shin", "r_cb_galleon_peek", "r_cb_mangrove_punt", "r_cb_cane_press", "r_cb_sulphur_mud", "r_cb_squall_dash",
  "r_cb_whale_spouts", "r_cb_fish_pot", "r_cb_rice_peas", "r_cb_coir_rope", "r_cb_fruit_platter", "r_cb_fish_tea", "r_cb_mango_chutney", "r_cb_tin_pan" }
for _, s2 in ipairs(order) do
  if not only or only == s2 then seed = 7; S[s2]() end
end
