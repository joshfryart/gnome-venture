-- variety-act-h18.lua : Do-tab scenes for 24 regional (r_sea_*) rest-stop activities -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-h18.lua   (params BEFORE --script)
-- Frame is copied from the shipped act-hand.png; interior is x 5..68, y 5..49. Gnome sprite copied from variety-act-g5.lua.
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

---------------------------------------------------------------- h18 helpers
local function water(c, y0, y1, cols, hl)
  local n = #cols
  for i = 0, n - 1 do
    local a = y0 + floor((y1 - y0 + 1) * i / n); local b = y0 + floor((y1 - y0 + 1) * (i + 1) / n) - 1
    c:fill(R(c, 0, a, W - 1, b), cols[i + 1])
  end
  if hl then
    for i = 1, 9 do
      local x, y = floor(rand() * 60) + 3, y0 + 2 + floor(rand() * (y1 - y0 - 3))
      c:fill(R(c, x, y, x + 2 + floor(rand() * 3), y), hl)
    end
  end
end
local function rain(c, n, col, x0, y0, x1, y1)
  for i = 1, n do
    local x, y = x0 + floor(rand() * (x1 - x0)), y0 + floor(rand() * (y1 - y0))
    c:px(x, y, col); c:px(x - 1, y + 1, col); c:px(x - 1, y + 2, col)
  end
end
local function palm(c, x, yb, h, dir, col)
  dir = dir or 1
  local tx, ty = x + dir * 3, yb - h
  c:fill(c:line({ { x, yb }, { x + dir, yb - floor(h / 2) }, { tx, ty } }, 2), "#7a5a3a")
  col = col or "#3f8a42"
  for _, f in ipairs({ { -8, 3 }, { -5, -2 }, { 0, -4 }, { 5, -2 }, { 8, 3 } }) do
    c:fill(c:line({ { tx, ty }, { tx + f[1], ty + f[2] } }, 2), col)
    c:fill(R(c, tx + f[1], ty + f[2] + 1, tx + f[1], ty + f[2] + 2), col)
  end
  c:px(tx, ty + 1, "#6b4a2e"); c:px(tx + 1, ty + 1, "#6b4a2e")
end
local function boat(c, x0, x1, y, col, rim)
  part(c, c:poly({ { x0, y }, { x1 + 1, y }, { x1 - 2, y + 4 }, { x0 + 3, y + 4 } }), col)
  fl(c, R(c, x0 + 1, y, x1 - 1, y), rim or "#c08a52")
end
local function star(c, x, y, col) c:px(x, y, col); end
local function hang(c, x, y0, y1, hex) fl(c, R(c, x, y0, x, y1), hex) end
local function fruit(c, x, y, r, hex, hi)
  part(c, c:ellipse(x, y, r, r), hex)
  if hi then c:px(x - 1, y - 1, hi) end
end
local A = arm
local S = {}

-- 1. firefly_paddle (night)
function S.r_sea_firefly_paddle()
  seed = 31
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#0b1428", "#10203a", "#16304a" }, { dir = "v" })
  for _, p in ipairs({ { 12, 8 }, { 30, 7 }, { 47, 10 }, { 62, 7 }, { 22, 12 }, { 56, 14 } }) do c:px(p[1], p[2], "#d8e4f0") end
  c:fill(c:ellipse(60, 12, 3, 3), "#e8e4c0"); c:fill(c:ellipse(62, 11, 3, 3), "#10203a")
  water(c, 34, 53, { "#0d2236", "#10293e", "#123046" }, "#27506a")
  -- mangrove trees (dark crowns, prop roots)
  local function tree(x, y, rx, ry)
    c:fill(c:ellipse(x, y, rx, ry), "#0c2a26")
    for i = -2, 2 do c:fill(c:line({ { x + i * 3, y + ry - 2 }, { x + i * 4, 35 } }, 1), "#0c2a26") end
  end
  tree(14, 24, 11, 9); tree(58, 22, 12, 10); tree(36, 27, 8, 6)
  -- fireflies: whole trees blinking
  seed = 5
  for _, t in ipairs({ { 14, 24, 10, 8 }, { 58, 22, 11, 9 }, { 36, 27, 7, 5 } }) do
    for i = 1, 20 do
      local x, y = t[1] + floor((rand() * 2 - 1) * t[3]), t[2] + floor((rand() * 2 - 1) * t[4])
      c:px(x, y, (i % 3 == 0) and "#fffbb0" or "#d8e860")
      if y > 0 and i % 4 == 0 then c:px(x, 36 + (y - 20) // 2 + 6, "#2c6a5a") end
    end
  end
  -- dugout with two gnomes
  local _, G = gnome(c, 31, 41, { upper = true, d = 1, eyes = "open", arms = { A({ 4, 6 }, { 3, 11 }, true) } })
  gnome(c, 42, 41, { upper = true, d = 1, hat = "#4f9a45", eyes = "open", arms = { A({ -4, 6 }, { 2, 2 }, true) } })
  fl(c, R(c, 40, 40, 50, 47), "#7a5a3a")
  c:fill(c:line({ { 44, 41 }, { 50, 49 } }, 2), "#7a5a3a"); part(c, c:ellipse(50, 49, 2, 3), "#9a7448")
  boat(c, 21, 53, 41, "#5a3a22", "#8a5a35")
  c:fill(R(c, 18, 46, 56, 46), "#1b4a5a"); c:fill(R(c, 22, 47, 52, 47), "#27506a")
  c:fill(R(c, 25, 50, 35, 50), "#27506a"); c:fill(R(c, 40, 49, 47, 49), "#27506a")
  finish(c, "r_sea_firefly_paddle")
end

-- 2. bamboo_gutters (rain)
function S.r_sea_bamboo_gutters()
  seed = 41
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 49), { "#7f9a9e", "#8aa5a8", "#96b0b0" }, { dir = "v" })
  -- inn wall and thatch
  c:fill(R(c, 5, 14, 47, 49), "#b08a58")
  for x = 5, 47, 6 do fl(c, R(c, x, 14, x, 49), "#8a6a40") end
  local th = c:poly({ { 3, 5 }, { 50, 5 }, { 50, 14 }, { 3, 14 } })
  part(c, th, "#c9a24c")
  for x = 6, 48, 4 do fl(c, R(c, x, 6, x, 12), "#9a7a30") end
  -- doorway (dark) and step
  c:fill(R(c, 19, 22, 35, 45), "#3a2a20"); fl(c, R(c, 19, 22, 35, 23), "#241810")
  part(c, R(c, 6, 45, 47, 49), "#8b8f96")
  -- sandals on the step
  for _, x in ipairs({ 9, 14 }) do part(c, R(c, x, 43, x + 2, 45), "#6a4a2a"); fl(c, R(c, x, 43, x + 2, 43), "#e8c48a") end
  -- bamboo gutter
  part(c, R(c, 8, 15, 44, 18), "#7ea850")
  fl(c, R(c, 8, 16, 44, 16), "#a8d070"); for x = 14, 44, 10 do fl(c, R(c, x, 15, x, 18), "#4e7a30") end
  -- overflow waterfall
  for x = 20, 33 do
    local len = 29 - ((x * 7) % 5)
    fl(c, R(c, x, 19, x, 19 + len), ((x % 3) == 0) and "#e8f4f8" or "#9ad4e8")
  end
  for x = 19, 34 do c:px(x, 19, "#cdeaf2") end
  -- splash at foot
  c:fill(c:ellipse(27, 47, 10, 2), "#9ad4e8"); for _, p in ipairs({ { 18, 44 }, { 36, 43 }, { 24, 43 }, { 31, 42 } }) do c:px(p[1], p[2], "#e8f4f8") end
  -- gnome with long pole to unclog the gutter
  local _, G = gnome(c, 58, 47, { d = -1, eyes = "open", arms = { A({ 4, 8 }, { 3, 15 }, true), A({ -4, 7 }, { -5, 11 }, false) } })
  c:fill(c:line({ { 55, 36 }, { 40, 20 } }, 1), "#7ea850"); fl(c, R(c, 54, 36, 55, 37), "#a8d070")
  -- leaf clog
  part(c, c:ellipse(41, 17, 3, 2), "#4e7a30")
  rain(c, 55, "#d2e4ea", 6, 6, 67, 46)
  finish(c, "r_sea_bamboo_gutters")
end

-- 3. buffalo_wallow
function S.r_sea_buffalo_wallow()
  seed = 51
  local c = new()
  day(c, 18, { sky = { "#c8e0dc", "#d6e8dc", "#e0ecd6" }, cloud = 52, grass = "#7ea85a" })
  water(c, 19, 31, { "#6aa8a8", "#58969a", "#4e8890" }, "#a8d4d0")
  -- ferry with a wheeled cart waiting
  part(c, R(c, 44, 22, 68, 26), "#8a6a40"); fl(c, R(c, 45, 22, 67, 22), "#b08a58")
  part(c, R(c, 52, 14, 62, 21), "#c08a52"); fl(c, R(c, 52, 17, 62, 17), "#8a5a35")
  for _, x in ipairs({ 54, 60 }) do part(c, c:ellipse(x, 22, 2, 2), "#5a3a22"); c:px(x, 22, "#c08a52") end
  -- muddy ramp
  c:fill(c:poly({ { 5, 49 }, { 5, 30 }, { 24, 28 }, { 68, 28 }, { 68, 49 } }), "#8a6a48")
  c:fill(R(c, 5, 38, 68, 49), "#7a5a3a")
  for _, p in ipairs({ { 12, 44 }, { 30, 47 }, { 56, 46 }, { 20, 36 }, { 64, 33 } }) do c:fill(R(c, p[1], p[2], p[1] + 4, p[2]), "#6a4a2e"); c:px(p[1] + 1, p[2] - 1, "#b09468") end
  -- buffalo
  local bx, by = 45, 38
  part(c, c:ellipse(bx, by, 13, 7), "#5e6068", { shade = true })
  part(c, c:ellipse(bx - 14, by - 1, 6, 5), "#66686f")
  part(c, c:ellipse(bx - 18, by + 2, 4, 3), "#a8a0a0")
  c:px(bx - 17, by - 2, "#1a1008")
  c:fill(c:line({ { bx - 12, by - 5 }, { bx - 9, by - 9 }, { bx - 5, by - 8 } }, 2), "#e8e0c8")
  c:fill(c:line({ { bx - 12, by - 5 }, { bx - 16, by - 9 }, { bx - 21, by - 8 } }, 2), "#e8e0c8")
  fl(c, R(c, bx - 14, by - 5, bx - 13, by - 4), "#44464c")
  part(c, R(c, bx - 6, by + 5, bx + 8, by + 8), "#7a5a3a", { noline = true })
  c:fill(c:ellipse(bx + 3, by + 7, 9, 2), "#7a5a3a")
  c:fill(c:line({ { bx + 12, by } , { bx + 15, by + 4 } }, 1), "#44464c")
  for _, p in ipairs({ { bx - 4, by - 6 }, { bx + 5, by - 5 }, { bx + 1, by - 2 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2] + 1), "#7a5a3a") end
  -- gnome hauling on a rope
  gnome(c, 16, 47, { d = 1, eyes = "open", walk = -1, arms = { A({ 4, 8 }, { 9, 6 }, true) } })
  c:fill(c:line({ { 24, 41 }, { 29, 41 }, { 33, 38 } }, 2), "#e8c48a")
  finish(c, "r_sea_buffalo_wallow")
end

-- 4. volcano_plume
function S.r_sea_volcano_plume()
  seed = 61
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#9ccce0", "#b4dae4", "#cfe8e6" }, { dir = "v" })
  -- volcano
  local v = c:poly({ { 20, 38 }, { 40, 14 }, { 50, 14 }, { 70, 38 } })
  part(c, v, "#5e6a7e")
  c:fill(c:poly({ { 44, 14 }, { 50, 14 }, { 70, 38 }, { 56, 38 } }), "#4e586c")
  fl(c, R(c, 40, 14, 50, 15), "#e8501f"); fl(c, R(c, 42, 14, 48, 14), "#ffb030")
  fl(c, R(c, 36, 20, 38, 24), "#4e586c")
  c:fill(c:ellipse(18, 34, 22, 7), "#4a8a46"); c:fill(R(c, 0, 36, W - 1, H - 1), "#5e9a48")
  -- plume leaning on the wind
  local pl = { { 46, 11, 5 }, { 42, 8, 5 }, { 37, 6, 5 }, { 31, 5, 4 }, { 25, 6, 3 } }
  for i, p in ipairs(pl) do c:fill(c:ellipse(p[1], p[2], p[3] + 1, p[3] - 1), (i % 2 == 0) and "#8a8e98" or "#aab0ba") end
  for _, p in ipairs(pl) do c:fill(c:ellipse(p[1] - 1, p[2] - 1, p[3] - 1, p[3] - 2), "#d6dae0") end
  -- clove trees in rows
  local function ctree(x, y, s)
    fl(c, R(c, x, y - 2, x + 1, y + 3), "#6b4a2e")
    part(c, c:ellipse(x, y - 5, 5 + s, 5 + s), "#2f7a3a", { shade = true })
    for _, p in ipairs({ { -3, -6 }, { 2, -8 }, { 3, -3 }, { -1, -3 }, { 0, -9 } }) do c:px(x + p[1], y + p[2], "#e8708a") end
  end
  ctree(11, 42, 1); ctree(60, 42, 1); ctree(22, 46, 0); ctree(66, 47, 0); ctree(50, 46, 0)
  -- gnome shading eyes, reading the plume
  gnome(c, 34, 48, { s = 1.25, d = 1, eyes = "open", arms = { A({ -4, 7 }, { -5, 15 }, true), A({ 4, 7 }, { 6, 12 }, false) } })
  -- harvest basket
  part(c, R(c, 50, 42, 56, 47), "#c08a52"); fl(c, R(c, 50, 43, 56, 43), "#8a5a35")
  for _, x in ipairs({ 51, 53, 55 }) do c:px(x, 41, "#e8708a") end
  finish(c, "r_sea_volcano_plume")
end

-- 5. gecko_calls (night)
function S.r_sea_gecko_calls()
  seed = 71
  local c = new()
  c:fill(R(c, 5, 5, 68, 49), "#2a2034")
  for x = 5, 68, 7 do fl(c, R(c, x, 14, x, 49), "#221a2c") end
  c:fill(R(c, 5, 5, 68, 13), "#5a4a30")
  for x = 6, 68, 4 do fl(c, R(c, x, 6, x, 12), "#7a6a40") end
  fl(c, R(c, 5, 13, 68, 14), "#3a2a1c")
  -- window with moon
  part(c, R(c, 9, 18, 21, 33), "#8a5a35")
  c:fill(R(c, 11, 20, 19, 31), "#12203a"); c:fill(c:ellipse(15, 24, 3, 3), "#f0eac0"); c:px(12, 28, "#d8e4f0"); c:px(18, 21, "#d8e4f0")
  fl(c, R(c, 15, 20, 15, 31), "#8a5a35"); fl(c, R(c, 11, 26, 19, 26), "#8a5a35")
  -- gecko on the wall
  local gx, gy = 46, 19
  part(c, c:ellipse(gx, gy, 10, 3), "#6a9a3a")
  part(c, c:ellipse(gx - 11, gy - 1, 4, 3), "#7aaa44")
  c:px(gx - 12, gy - 2, "#f4d040"); c:px(gx - 12, gy - 1, "#1a1008")
  fl(c, R(c, gx - 15, gy, gx - 13, gy), "#241810")
  c:fill(c:line({ { gx + 9, gy }, { gx + 14, gy + 2 }, { gx + 17, gy - 1 } }, 2), "#6a9a3a")
  for _, p in ipairs({ { -5, 4 }, { 4, 4 }, { -6, -3 }, { 3, -3 } }) do
    c:fill(c:line({ { gx + p[1], gy + (p[2] > 0 and 1 or -1) }, { gx + p[1] - 1, gy + p[2] } }, 1), "#6a9a3a")
  end
  for _, p in ipairs({ { -4, -1 }, { 0, 1 }, { 4, -1 }, { 7, 0 } }) do c:px(gx + p[1], gy + p[2], "#e0803a") end
  -- sound arcs
  for i = 1, 3 do
    c:fill(c:line({ { gx - 18 - i * 2, gy - 3 - i }, { gx - 19 - i * 2, gy }, { gx - 18 - i * 2, gy + 3 + i } }, 1), "#a8b8d8")
  end
  -- bed and gnome counting on fingers
  gnome(c, 26, 47, { upper = true, s = 1.25, d = 1, eyes = "open", arms = { A({ 4, 7 }, { 6, 14 }, true) } })
  part(c, R(c, 8, 41, 46, 49), "#8a5a35")
  c:fill(R(c, 10, 42, 44, 48), "#4a6aa0")
  for x = 12, 42, 6 do for y = 43, 47, 4 do fl(c, R(c, x, y, x + 2, y + 1), "#6a8ac0") end end
  fl(c, R(c, 10, 42, 44, 42), "#8aaae0")
  fl(c, R(c, 6, 36, 8, 49), "#6b3b2a")
  finish(c, "r_sea_gecko_calls")
end

-- 6. hail_boat (dawn)
function S.r_sea_hail_boat()
  seed = 81
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#6a6a9a", "#9a7aa0", "#d68a8a", "#f0aa7a", "#f8d08a" }, { dir = "v" })
  c:fill(c:ellipse(36, 31, 9, 8):clip(R(c, 0, 0, W, 30)), "#fff0b0")
  water(c, 31, 49, { "#e0a090", "#c08a98", "#9a7aa0", "#7a6aa0" }, "#f8d08a")
  c:fill(R(c, 20, 32, 52, 32), "#f8d08a"); c:fill(R(c, 25, 34, 47, 34), "#e8b090")
  -- distant boats
  for _, b in ipairs({ { 8, 29 }, { 56, 28 } }) do fl(c, R(c, b[1], b[2], b[1] + 6, b[2]), "#5a4a78"); fl(c, R(c, b[1] + 2, b[2] - 2, b[1] + 3, b[2] - 1), "#5a4a78") end
  -- jetty
  part(c, R(c, 5, 37, 28, 40), "#8a5a35"); fl(c, R(c, 5, 37, 28, 37), "#b07a45")
  for _, x in ipairs({ 9, 17, 25 }) do part(c, R(c, x, 41, x + 1, 49), "#5a3a22", { noline = true }) end
  -- drifting stall boat
  boat(c, 36, 66, 40, "#4a8a6a", "#2f6a4a")
  part(c, R(c, 42, 33, 58, 39), "#6a2a5a")
  for i = 0, 3 do for j = 0, 2 do c:fill(c:ellipse(43 + i * 4, 36 + (i % 2), 1, 1), "#8a3a78") end end
  for i = 0, 4 do fruit(c, 41 + i * 4, 38, 2, "#8a3a78", "#c070b0") end
  for i = 0, 3 do fruit(c, 43 + i * 4, 35, 2, "#7a2a68", "#b060a0"); c:px(43 + i * 4, 33, "#4a9a3a") end
  for i = 0, 2 do fruit(c, 45 + i * 4, 32, 2, "#8a3a78", "#c070b0") end
  -- paddler stern with a straw hat
  c:fill(c:poly({ { 63, 29 }, { 67, 36 }, { 59, 36 } }), "#d9b870"); fl(c, R(c, 60, 36, 66, 36), "#a88840")
  fl(c, R(c, 61, 37, 65, 40), "#c0442e")
  c:fill(c:line({ { 65, 38 }, { 68, 47 } }, 1), "#8a5a35")
  -- wake
  for _, y in ipairs({ 44, 46 }) do c:fill(R(c, 28, y, 44, y), "#f8d08a") end
  -- gnome hailing
  gnome(c, 22, 37, { d = 1, eyes = "open", arms = { A({ 4, 9 }, { 9, 17 }, true), A({ -4, 7 }, { -6, 5 }, false) } })
  finish(c, "r_sea_hail_boat")
end

-- 7. judge_durian (summer)
function S.r_sea_judge_durian()
  seed = 91
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 49), { "#a8dce8", "#c4e8ec", "#e0f0d8" }, { dir = "v" })
  c:fill(c:ellipse(60, 10, 4, 4), "#fff0a0")
  -- stall awning
  for x = 5, 68 do for y = 5, 12 do c:px(x, y, (((x - 5) // 4) % 2 == 0) and "#dd3a2a" or "#f4eee0") end end
  for x = 5, 68, 4 do fl(c, R(c, x, 13, x + 3, 13), ((((x - 5) // 4) % 2 == 0) and "#dd3a2a" or "#f4eee0")) end
  fl(c, R(c, 5, 5, 68, 5), "#8e2e1e")
  fl(c, R(c, 8, 14, 8, 49), "#8a5a35"); fl(c, R(c, 65, 14, 65, 49), "#8a5a35")
  -- onlookers pinching their noses
  gnome(c, 12, 44, { upper = true, s = 1, d = 1, hat = "#e8a317", eyes = "shut", arms = { A({ 3, 7 }, { 3, 10 }, true) } })
  gnome(c, 60, 44, { upper = true, s = 1, d = -1, hat = "#4f9a45", eyes = "shut", arms = { A({ -3, 7 }, { -3, 10 }, true) } })
  -- the gnome holds up a durian
  local _, G = gnome(c, 36, 44, { upper = true, s = 1.25, d = 1, eyes = "shut", arms = { A({ -4, 7 }, { -2, 10 }, true), A({ 4, 7 }, { 8, 15 }, true) } })
  local dx, dy = G.P(9, 19)
  part(c, c:ellipse(dx, dy, 5, 4), "#c8b84a")
  c:fill(c:ellipse(dx - 1, dy - 1, 2, 1), "#e0d070")
  for _, p in ipairs({ { -6, 0 }, { 6, 0 }, { 0, -5 }, { -4, -4 }, { 4, -4 }, { -4, 4 }, { 4, 4 }, { 0, 5 } }) do c:px(dx + p[1], dy + p[2], "#8a7a2a") end
  for _, p in ipairs({ { -2, -2 }, { 2, -1 }, { 0, 2 }, { -3, 1 } }) do c:px(dx + p[1], dy + p[2], "#8a7a2a") end
  -- stink waves
  for i = 0, 2 do
    local sx = dx - 6 + i * 6
    for k = 0, 4 do c:px(sx + ((k // 2) % 2), dy - 7 - k, "#8ec040") end
  end
  -- counter with fruit
  part(c, R(c, 5, 44, 68, 49), "#b07a45"); fl(c, R(c, 5, 44, 68, 44), "#d9a660")
  for _, x in ipairs({ 20, 28, 46, 54 }) do fruit(c, x, 42, 2, (x % 8 == 4) and "#c8b84a" or "#e8a317", "#f0e0a0") end
  finish(c, "r_sea_judge_durian")
end

-- 8. flooded_causeway (monsoon)
function S.r_sea_flooded_causeway()
  seed = 101
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#6a7a84", "#76868e", "#8494a0" }, { dir = "v" })
  c:fill(c:ellipse(60, 30, 20, 6), "#4e7a4a")
  c:fill(c:ellipse(10, 30, 14, 5), "#46704a")
  -- little shrine on a rise
  part(c, R(c, 52, 20, 64, 26), "#8a5a35")
  c:fill(c:poly({ { 49, 21 }, { 58, 14 }, { 67, 21 } }), "#a8402e"); fl(c, R(c, 49, 21, 66, 21), "#6a2a1e")
  fl(c, R(c, 56, 22, 60, 26), "#241810")
  palm(c, 9, 32, 20, 1); palm(c, 66, 33, 17, -1)
  -- flood
  water(c, 31, 49, { "#a08258", "#947650", "#886a48", "#7e6040" }, "#c4a878")
  -- stepping stones hidden just below
  for _, p in ipairs({ { 50, 33 }, { 44, 36 }, { 38, 40 } }) do c:fill(c:ellipse(p[1], p[2], 3, 1), "#a8a8a0"); c:fill(R(c, p[1] - 2, p[2] + 1, p[1] + 2, p[2] + 1), "#8a7a60") end
  -- gnome wading, probing with a stick; water laps over the knees
  rain(c, 38, "#d2dde2", 6, 6, 67, 40)
  gnome(c, 24, 48, { s = 1.2, d = 1, eyes = "open", walk = 1, arms = { A({ 4, 8 }, { 10, 4 }, true) } })
  c:fill(c:line({ { 31, 38 }, { 38, 45 } }, 1), "#8a5a35")
  c:fill(R(c, 10, 45, 40, 49), "#947650"); c:fill(R(c, 10, 47, 40, 49), "#886a48")
  for x = 12, 38, 3 do c:px(x, 45, "#c4a878") end
  for x = 14, 36, 5 do c:fill(R(c, x, 48, x + 2, 48), "#c4a878") end
  c:fill(c:ellipse(40, 46, 3, 1), "#c4a878")
  finish(c, "r_sea_flooded_causeway")
end

-- 9. beat_husks
function S.r_sea_beat_husks()
  seed = 111
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 22), { "#a8d4e0", "#bcdde4", "#d0e8e4" }, { dir = "v" })
  c:fill(c:ellipse(60, 20, 18, 5), "#4e8a3c")
  palm(c, 63, 30, 22, -1); palm(c, 7, 30, 16, 1)
  water(c, 23, 36, { "#4aa0b0", "#5ab0b8", "#6ac0c0" }, "#a8e6e6")
  -- husks soaking in the shallows
  for _, p in ipairs({ { 14, 29 }, { 24, 32 }, { 56, 28 }, { 48, 33 } }) do
    part(c, c:ellipse(p[1], p[2], 4, 2), "#8a6a3a")
    c:fill(R(c, p[1] - 2, p[2], p[1] + 2, p[2]), "#a88848")
  end
  c:fill(R(c, 5, 37, 68, 49), "#c8a870")
  for x = 7, 66, 6 do c:px(x, 40 + (x % 3) * 3, "#a88848") end
  -- chopping stump and the husk being beaten
  part(c, R(c, 38, 39, 56, 48), "#8a5a35")
  c:fill(c:ellipse(47, 39, 9, 2), "#c08a52"); c:fill(c:ellipse(47, 39, 6, 1), "#d9a660")
  part(c, c:ellipse(47, 37, 6, 3), "#7a5a2a")
  for x = 42, 52, 2 do c:px(x, 36, "#c4a060"); c:px(x + 1, 38, "#a88848") end
  -- loose fibres flying
  for _, p in ipairs({ { 38, 33 }, { 40, 30 }, { 55, 33 }, { 57, 30 }, { 36, 37 }, { 59, 36 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2]), "#d8c080") end
  -- gnome swinging the mallet
  local _, G = gnome(c, 26, 48, { s = 1.25, d = 1, eyes = "open", walk = 1, arms = { A({ 4, 8 }, { 8, 15 }, true), A({ -4, 7 }, { 0, 12 }, true) } })
  local hx, hy = G.P(8, 15)
  c:fill(c:line({ { hx, hy }, { hx + 5, hy - 7 } }, 2), "#8a5a35")
  part(c, c:rect(hx + 3, hy - 13, hx + 12, hy - 8), "#a8703e")
  c:fill(R(c, hx + 3, hy - 13, hx + 12, hy - 12), "#d9a660")
  -- rope coil by the posts
  part(c, c:ellipse(11, 46, 5, 3), "#d8c080"); c:fill(c:ellipse(11, 46, 3, 1), "#c8a870")
  finish(c, "r_sea_beat_husks")
end

-- 10. lemongrass_curry
function S.r_sea_lemongrass_curry()
  seed = 121
  local c = new()
  c:fill(R(c, 5, 5, 68, 49), "#b89464")
  for x = 5, 68, 7 do fl(c, R(c, x, 5, x, 38), "#9a7a4a") end
  -- shelf with jars, hanging chillies
  part(c, R(c, 8, 17, 36, 18), "#8a5a35")
  for i, x in ipairs({ 10, 16, 22, 28 }) do part(c, R(c, x, 11, x + 3, 16), (i % 2 == 0) and "#c4623a" or "#d9a660"); fl(c, R(c, x, 10, x + 3, 10), "#6b3b2a") end
  hang(c, 50, 5, 9, "#6b3b2a")
  for i = 0, 5 do c:fill(R(c, 49 + (i % 2) * 2, 8 + i * 2, 50 + (i % 2) * 2, 9 + i * 2), "#dd3a2a") end
  for i = 0, 4 do c:fill(R(c, 58 + (i % 2) * 2, 8 + i * 2, 59 + (i % 2) * 2, 9 + i * 2), "#e0a317") end
  -- table
  part(c, R(c, 5, 38, 68, 49), "#8a5a35"); fl(c, R(c, 5, 38, 68, 38), "#c08a52")
  for y = 42, 48, 3 do fl(c, R(c, 5, y, 68, y), "#6b3b2a") end
  -- gnome pounding
  local _, G = gnome(c, 22, 40, { upper = true, s = 1.25, d = 1, eyes = "open", arms = { A({ 4, 7 }, { 10, 11 }, true) } })
  -- mortar with lemongrass
  local mx = 38
  for i = -2, 2 do
    c:fill(c:line({ { mx + i * 2, 34 }, { mx + i * 2 + (i > 0 and 3 or -3), 22 } }, 1), "#9ac050")
    c:fill(R(c, mx + i * 2 - 0, 32, mx + i * 2, 34), "#e8f0c0")
  end
  part(c, c:ellipse(mx, 37, 8, 3), "#8b8f96", { shade = true })
  part(c, R(c, mx - 8, 37, mx + 8, 42), "#8b8f96", { shade = true })
  c:fill(c:ellipse(mx, 42, 6, 2), "#8b8f96")
  c:fill(c:ellipse(mx, 36, 6, 2), "#5a5e66")
  c:fill(c:line({ { 36, 36 }, { 34, 24 } }, 2), "#a8a8a0"); fl(c, R(c, 33, 23, 36, 24), "#c8c8c0")
  -- green aroma curls
  for i = 0, 2 do for k = 0, 5 do c:px(mx - 6 + i * 6 + ((k // 2) % 2), 20 - k, "#a8d070") end end
  -- curry pot and rice bowl
  part(c, R(c, 52, 30, 64, 38), "#2a2a30"); fl(c, R(c, 50, 29, 66, 30), "#44444c")
  c:fill(c:ellipse(58, 30, 7, 1), "#f0d8a0"); fl(c, R(c, 53, 30, 55, 30), "#e0a317"); c:px(60, 30, "#dd3a2a")
  part(c, R(c, 56, 38, 68, 38), "#2a2a30", { noline = true })
  part(c, c:ellipse(46, 45, 5, 2), "#f4eee0"); c:fill(c:ellipse(46, 44, 4, 1), "#fff8e8")
  part(c, c:ellipse(60, 45, 4, 2), "#dc9a4a")
  c:fill(c:line({ { 62, 46 }, { 67, 42 } }, 1), "#e8c48a")
  finish(c, "r_sea_lemongrass_curry")
end

-- 11. wok_rice
function S.r_sea_wok_rice()
  seed = 131
  local c = new()
  c:bands(R(c, 5, 5, 68, 43), { "#d8b078", "#dcb87e", "#e0c084" }, { dir = "v" })
  for x = 5, 68, 8 do fl(c, R(c, x, 5, x, 43), "#b8905a") end
  -- window with morning light
  part(c, R(c, 8, 10, 22, 24), "#8a5a35"); c:fill(R(c, 10, 12, 20, 22), "#fff0b0"); fl(c, R(c, 15, 12, 15, 22), "#8a5a35"); fl(c, R(c, 10, 17, 20, 17), "#8a5a35")
  c:fill(c:poly({ { 10, 22 }, { 22, 22 }, { 38, 44 }, { 18, 44 } }), "#e8c890")
  -- hanging ladles
  fl(c, R(c, 56, 8, 66, 8), "#6b3b2a")
  for _, x in ipairs({ 58, 62, 66 }) do c:fill(R(c, x, 9, x, 17), "#8a8e96"); part(c, c:ellipse(x, 19, 2, 2), "#8a8e96") end
  -- counter + stove
  part(c, R(c, 5, 44, 68, 49), "#8a5a35"); fl(c, R(c, 5, 44, 68, 44), "#b07a45")
  part(c, R(c, 38, 36, 62, 44), "#8e4a3a")
  for y = 38, 43, 2 do fl(c, R(c, 38, y, 62, y), "#6a3428") end
  c:fill(R(c, 46, 39, 54, 44), "#2a1810")
  c:fill(c:poly({ { 50, 38 }, { 53, 44 }, { 47, 44 } }), "#f08a2a"); c:fill(c:poly({ { 50, 41 }, { 52, 44 }, { 48, 44 } }), "#ffd860")
  -- gnome flinging the wok
  local _, G = gnome(c, 22, 48, { s = 1.25, d = 1, eyes = "open", arms = { A({ 4, 8 }, { 9, 10 }, true), A({ -4, 7 }, { -2, 4 }, false) } })
  local hx, hy = G.P(9, 10)
  c:fill(c:line({ { hx, hy }, { 40, 34 } }, 2), "#6b3b2a")
  c:fill(c:ellipse(48, 33, 9, 3):clip(R(c, 0, 33, W, 60)), "#2a2a30")
  c:fill(c:ellipse(48, 33, 9, 1), "#3a3a42"); fl(c, R(c, 40, 33, 56, 33), "#5a5a64")
  -- flying rice, egg and greens
  for _, p in ipairs({ { 42, 28 }, { 46, 22 }, { 50, 18 }, { 54, 24 }, { 57, 29 }, { 44, 16 }, { 40, 24 }, { 52, 13 } }) do
    c:fill(R(c, p[1], p[2], p[1] + 1, p[2]), "#fbf6e6")
  end
  for _, p in ipairs({ { 48, 27 }, { 53, 20 }, { 44, 21 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2] + 1), "#f4c830") end
  for _, p in ipairs({ { 50, 24 }, { 56, 26 }, { 47, 15 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2]), "#4f9a45"); c:px(p[1] + 1, p[2] + 1, "#4f9a45") end
  -- bowl on counter
  part(c, c:ellipse(30, 42, 4, 2), "#f4eee0")
  finish(c, "r_sea_wok_rice")
end

-- 12. fruit_bowl
function S.r_sea_fruit_bowl()
  seed = 141
  local c = new()
  c:bands(R(c, 5, 5, 68, 49), { "#f0dcb0", "#ecd4a4", "#e8cc9a" }, { dir = "v" })
  -- stall roof of leaves
  for x = 5, 68, 4 do c:fill(R(c, x, 5, x + 3, 9), (((x - 5) // 4) % 2 == 0) and "#4f9a45" or "#3f8a42") end
  for x = 5, 68, 4 do c:px(x + 1, 10, "#3f8a42"); c:px(x + 2, 10, "#3f8a42") end
  -- gnome behind the table, holding up a peeled rambutan
  local _, G = gnome(c, 22, 40, { upper = true, s = 1.25, d = 1, eyes = "open", arms = { A({ 4, 7 }, { 9, 12 }, true) } })
  local px, py = G.P(11, 14)
  part(c, c:ellipse(px, py, 3, 3), "#f4eee0"); c:px(px - 1, py - 1, "#fbf6e6")
  for _, p in ipairs({ { -1, 3 }, { 1, 3 }, { 0, 4 } }) do c:px(px + p[1], py + p[2], "#dd3a2a") end
  -- table
  part(c, R(c, 5, 38, 68, 49), "#b07a45"); fl(c, R(c, 5, 38, 68, 38), "#d9a660")
  -- big bowl of rambutans
  part(c, c:ellipse(38, 42, 15, 7), "#8a5a35", { shade = true })
  c:fill(c:ellipse(38, 40, 13, 5), "#6b3b2a")
  for _, p in ipairs({ { 30, 37 }, { 36, 35 }, { 42, 36 }, { 47, 38 }, { 33, 40 }, { 40, 40 }, { 45, 41 } }) do
    part(c, c:ellipse(p[1], p[2], 3, 3), "#d8342a")
    for _, h in ipairs({ { -3, 0 }, { 3, 0 }, { 0, -3 }, { -2, -2 }, { 2, -2 }, { 0, 3 } }) do c:px(p[1] + h[1], p[2] + h[2], "#8ec040") end
    c:px(p[1] - 1, p[2] - 1, "#f0705a")
  end
  -- longans out of their shells
  for _, p in ipairs({ { 57, 41 }, { 61, 43 }, { 64, 41 } }) do part(c, c:ellipse(p[1], p[2], 2, 2), "#e0c898"); c:px(p[1], p[2], "#3a2a1c") end
  part(c, c:ellipse(60, 46, 2, 1), "#a88858"); c:px(56, 46, "#a88858"); c:px(64, 46, "#a88858")
  -- starfruit stars on a plate
  part(c, c:ellipse(12, 44, 6, 3), "#f4eee0")
  c:paint({ "..y..", "yyyyy", ".yyy.", "yy.yy" }, 9, 41, { y = "#e8d84a" })
  c:paint({ "..y..", "yyyyy", ".yyy.", "yy.yy" }, 14, 43, { y = "#d8c83a" })
  finish(c, "r_sea_fruit_bowl")
end

-- 13. paddy_pot
function S.r_sea_paddy_pot()
  seed = 151
  local c = new()
  c:bands(R(c, 5, 5, 68, 26), { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  c:fill(c:ellipse(20, 27, 26, 7), "#5e9a48"); c:fill(c:ellipse(62, 28, 20, 6), "#4e8a3c")
  c:fill(R(c, 5, 26, 68, 43), "#7ea85a")
  for y = 28, 41, 3 do for x = 7, 66, 3 do c:px(x + (y % 2), y, "#5e8a44") end end
  -- workshop shed posts and roof
  part(c, R(c, 5, 5, 68, 8), "#c9a24c"); for x = 7, 66, 4 do fl(c, R(c, x, 6, x, 8), "#9a7a30") end
  part(c, R(c, 5, 8, 7, 49), "#6b4a2e", { noline = true }); part(c, R(c, 66, 8, 68, 49), "#6b4a2e", { noline = true })
  -- finished pots on a shelf
  part(c, R(c, 50, 24, 66, 25), "#8a5a35")
  for _, p in ipairs({ { 53, "#c4623a" }, { 59, "#a8482e" }, { 64, "#c4623a" } }) do part(c, c:ellipse(p[1], 21, 3, 3), p[2]); fl(c, R(c, p[1] - 1, 17, p[1] + 1, 18), p[2]) end
  -- bench
  part(c, R(c, 5, 44, 68, 49), "#8a5a35"); fl(c, R(c, 5, 44, 68, 44), "#b07a45")
  -- the pot, built from coils
  local cx = 42
  local rows = { { 43, 7 }, { 41, 8 }, { 38, 9 }, { 35, 9 }, { 32, 8 }, { 29, 7 }, { 27, 6 } }
  for i, r in ipairs(rows) do
    local col = (i % 2 == 0) and "#c4623a" or "#b5532f"
    part(c, c:rrect(cx - r[2], r[1], cx + r[2], r[1] + 2, 1), col)
    c:fill(R(c, cx - r[2] + 1, r[1], cx + r[2] - 2, r[1]), "#dd8a58")
  end
  for _, p in ipairs({ { 36, 41 }, { 47, 37 }, { 39, 33 }, { 45, 30 } }) do c:px(p[1], p[2], "#e8d070") end
  -- the long clay coil being laid on the rim
  c:fill(c:line({ { 31, 21 }, { 34, 24 }, { 38, 26 }, { 42, 26 } }, 2), "#d97a4a")
  -- gnome shaping with a wet thumb
  local _, G = gnome(c, 19, 44, { upper = true, s = 1.25, d = 1, eyes = "open", arms = { A({ 4, 7 }, { 9, 13 }, true) } })
  -- straw and clay lump, water bucket
  c:fill(R(c, 58, 40, 65, 40), "#e8d070"); c:fill(R(c, 60, 41, 66, 41), "#c8a850")
  part(c, c:ellipse(60, 43, 4, 2), "#8a7a68")
  finish(c, "r_sea_paddy_pot")
end

-- 14. paddy_bunds
function S.r_sea_paddy_bunds()
  seed = 161
  local c = new()
  c:bands(R(c, 5, 5, 68, 17), { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  c:fill(c:ellipse(16, 18, 26, 7), "#5e8a44"); c:fill(c:ellipse(56, 19, 22, 6), "#4e7a3a")
  local function field(y0, y1)
    c:fill(R(c, 5, y0, 68, y1), "#8cc4d4"); c:fill(R(c, 5, y0, 68, y0), "#bce0e8")
    for x = 7, 66, 4 do c:px(x, y0 + 2, "#5aa040"); c:px(x + 1, y0 + 1, "#5aa040"); c:px(x + 2, y0 + 2, "#5aa040") end
  end
  local function bund(y0, y1) c:fill(R(c, 5, y0, 68, y1), "#8a6a48"); c:fill(R(c, 5, y0, 68, y0), "#a8885c"); c:fill(R(c, 5, y1, 68, y1), "#6a4a30") end
  field(18, 23); bund(24, 25)
  field(26, 31); bund(32, 34)
  field(35, 40)
  -- water sheeting down through a slumped gap in the middle bund
  c:fill(R(c, 18, 32, 28, 34), "#8cc4d4")
  c:fill(R(c, 20, 26, 26, 31), "#8cc4d4"); c:fill(R(c, 21, 32, 26, 39), "#bce0e8"); for y = 32, 38, 2 do c:px(22, y, "#f4f8fa"); c:px(25, y + 1, "#f4f8fa") end
  bund(41, 46); c:fill(R(c, 5, 47, 68, 49), "#6a4a30")
  for _, x in ipairs({ 9, 14, 33, 40, 45, 60, 65 }) do c:fill(R(c, x, 42, x + 1, 42), "#8a6a48"); c:px(x, 41, "#a8885c") end
  for _, p in ipairs({ { 13, 43 }, { 36, 44 }, { 58, 43 } }) do c:fill(R(c, p[1], p[2], p[1] + 3, p[2]), "#6a4a30") end
  -- fresh mud patted into place
  c:fill(R(c, 18, 40, 28, 41), "#a8885c"); c:fill(R(c, 20, 39, 26, 39), "#8a6a48")
  -- gnome on the bund with a flat paddle
  local _, G = gnome(c, 44, 47, { s = 1.25, d = -1, eyes = "open", arms = { A({ -4, 8 }, { -8, 4 }, true), A({ -4, 7 }, { -2, 12 }, true) } })
  local hx, hy = G.P(-8, 4)
  c:fill(c:line({ { hx + 2, hy - 7 }, { hx - 1, hy + 1 } }, 1), "#8a5a35")
  part(c, R(c, hx - 6, hy, hx - 1, hy + 3), "#c08a52")
  for _, p in ipairs({ { hx - 8, hy - 3 }, { hx - 10, hy - 1 }, { hx - 8, hy + 5 } }) do c:fill(R(c, p[1], p[2], p[1] + 1, p[2]), "#6a4a30") end
  finish(c, "r_sea_paddy_bunds")
end

-- 15. ease_roots (dawn)
function S.r_sea_ease_roots()
  seed = 171
  local c = new()
  c:bands(R(c, 5, 5, 68, 33), { "#c89aa8", "#e0a898", "#f0b890", "#f8d09a" }, { dir = "v" })
  c:fill(c:ellipse(24, 28, 7, 5):clip(R(c, 0, 0, W, 29)), "#fff0b0")
  -- jungle edges
  c:fill(c:ellipse(10, 30, 14, 12), "#3a5a3a"); c:fill(c:ellipse(62, 30, 12, 10), "#34503a")
  -- temple tower
  local tw = c:poly({ { 36, 10 }, { 39, 10 }, { 44, 18 }, { 50, 18 }, { 52, 34 }, { 22, 34 }, { 24, 18 }, { 30, 18 } })
  part(c, tw, "#8a7a78")
  for y = 20, 32, 4 do fl(c, R(c, 25, y, 50, y), "#6a5a5c") end
  c:fill(R(c, 34, 25, 40, 34), "#2a1e24")
  fl(c, R(c, 37, 6, 37, 9), "#6a5a5c")
  -- steps
  c:fill(R(c, 5, 34, 68, 49), "#4a5a3a")
  for i = 0, 4 do part(c, R(c, 16 - i * 0 + i * 2, 35 + i * 3, 59 - i * 2, 37 + i * 3), (i % 2 == 0) and "#a8a49c" or "#9a968e") end
  c:fill(R(c, 5, 47, 68, 49), "#6a6a5a")
  -- great fig roots draped over the steps
  local rt = "#7a6048"
  c:fill(c:line({ { 66, 5 }, { 60, 18 }, { 56, 30 }, { 48, 38 }, { 40, 44 } }, 3), rt)
  c:fill(c:line({ { 58, 5 }, { 52, 16 }, { 50, 30 }, { 44, 36 } }, 2), "#6a5038")
  c:fill(c:line({ { 66, 20 }, { 62, 34 }, { 58, 42 }, { 52, 46 } }, 3), rt)
  c:fill(c:line({ { 66, 5 }, { 60, 18 }, { 56, 30 } }, 1), "#9a7a58")
  -- root lifted gently aside by the gnome (arms hold it)
  local _, G = gnome(c, 24, 48, { s = 1.25, d = 1, eyes = "open", arms = { A({ 4, 8 }, { 10, 11 }, true), A({ -4, 8 }, { 7, 8 }, true) } })
  c:fill(c:line({ { 30, 40 }, { 34, 36 }, { 40, 32 }, { 48, 30 } }, 3), "#8a7058")
  c:fill(c:line({ { 30, 40 }, { 34, 36 }, { 40, 32 }, { 48, 30 } }, 1), "#a88a68")
  -- soft light motes
  for _, p in ipairs({ { 14, 12 }, { 30, 8 }, { 12, 20 }, { 46, 12 } }) do c:px(p[1], p[2], "#fff0c0") end
  finish(c, "r_sea_ease_roots")
end

-- 16. thatch_stilt
function S.r_sea_thatch_stilt()
  seed = 181
  local c = new()
  c:bands(R(c, 5, 5, 68, 30), { "#a8dce8", "#bce4ea", "#d0ece6" }, { dir = "v" })
  c:fill(c:ellipse(60, 12, 8, 2), "#f4eee0")
  c:fill(c:ellipse(10, 30, 16, 5), "#4e8a3c")
  water(c, 31, 49, { "#58b4c4", "#4aa4b8", "#3f94ac" }, "#a8e6e6")
  -- stilts
  for _, x in ipairs({ 18, 28, 44, 52 }) do part(c, R(c, x, 36, x + 1, 49), "#6b4a2e", { noline = true }) end
  for _, x in ipairs({ 18, 28, 44, 52 }) do c:fill(R(c, x - 1, 46, x + 2, 46), "#a8e6e6") end
  -- platform and walls
  part(c, R(c, 14, 32, 58, 36), "#a8703e"); fl(c, R(c, 14, 32, 58, 32), "#c08a52")
  part(c, R(c, 18, 22, 54, 31), "#c08a52")
  for x = 22, 54, 5 do fl(c, R(c, x, 22, x, 31), "#8a5a35") end
  c:fill(R(c, 33, 25, 40, 31), "#2a1a10")
  -- palm-leaf roof with a storm-torn patch
  local roof = c:poly({ { 11, 22 }, { 36, 5 }, { 62, 22 } })
  part(c, roof, "#c9a24c")
  for i = 0, 4 do c:fill(c:line({ { 20 + i * 4, 21 - i }, { 30 + i * 3, 10 } }, 1), "#9a7a30") end
  local hole = c:poly({ { 38, 12 }, { 48, 12 }, { 54, 21 }, { 42, 21 } })
  c:fill(hole, "#bce4ea")
  for _, x in ipairs({ 40, 44, 48, 51 }) do c:fill(c:line({ { x, 12 }, { x + 4, 21 } }, 1), "#7a5a3a") end
  -- stack of fresh palm leaves
  part(c, R(c, 17, 28, 25, 31), "#3f8a42"); fl(c, R(c, 18, 28, 24, 28), "#6fb450"); c:fill(c:line({ { 16, 30 }, { 12, 28 } }, 1), "#3f8a42")
  -- gnome on a ladder fixing the roof
  c:fill(c:line({ { 58, 49 }, { 56, 24 } }, 1), "#8a5a35"); c:fill(c:line({ { 64, 49 }, { 62, 24 } }, 1), "#8a5a35")
  for y = 27, 48, 4 do local o = (49 - y) // 12; fl(c, R(c, 56 + (y >= 40 and 1 or 0) , y, 62 + (y >= 40 and 1 or 0) + 1, y), "#a8703e") end
  gnome(c, 60, 37, { s = 1, d = -1, eyes = "open", arms = { A({ -4, 9 }, { -9, 15 }, true), A({ 4, 7 }, { 5, 10 }, false) } })
  c:fill(c:line({ { 47, 20 }, { 53, 18 } }, 2), "#4f9a45"); c:fill(c:line({ { 49, 19 }, { 55, 16 } }, 1), "#6fb450")
  finish(c, "r_sea_thatch_stilt")
end

-- note glyph (pixel music note) and orchid flower helpers
local function note(c, x, y, col)
  c:fill(R(c, x, y, x + 1, y + 1), col); c:fill(R(c, x + 1, y - 4, x + 1, y), col); c:px(x + 2, y - 4, col); c:px(x + 2, y - 3, col)
end
local function orchid(c, x, y, col, cen)
  c:paint({ ".p.", "ppp", ".p." }, x - 1, y - 1, { p = col }); c:px(x, y, cen or "#f0c030")
  c:px(x - 2, y, col); c:px(x + 2, y, col)
end

-- 17. hornbill_figs
function S.r_sea_hornbill_figs()
  seed = 191
  local c = new()
  c:bands(R(c, 5, 5, 68, 49), { "#2f6a3a", "#3a7a44", "#468a4c" }, { dir = "v" })
  for _, p in ipairs({ { 8, 8 }, { 16, 12 }, { 54, 9 }, { 62, 14 }, { 66, 28 } }) do c:fill(c:ellipse(p[1], p[2], 6, 3), "#5aa050") end
  -- great trunk with the sealed hollow
  part(c, R(c, 34, 5, 48, 49), "#6b4a2e")
  for _, x in ipairs({ 37, 42, 46 }) do fl(c, R(c, x, 5, x, 46), "#4e3220") end
  c:fill(c:poly({ { 30, 49 }, { 34, 40 }, { 48, 40 }, { 52, 49 } }), "#6b4a2e")
  c:fill(c:ellipse(41, 22, 5, 8), "#2a1810")
  c:fill(c:ellipse(41, 22, 4, 7), "#b09468")
  fl(c, R(c, 37, 20, 38, 22), "#2a1810")
  -- mother's big beak through the slit
  part(c, c:poly({ { 30, 19 }, { 38, 20 }, { 38, 23 }, { 32, 23 } }), "#e8a317"); fl(c, R(c, 31, 19, 36, 19), "#f5cf6a")
  -- branch with father hornbill
  c:fill(c:line({ { 34, 30 }, { 22, 28 }, { 8, 28 } }, 2), "#6b4a2e")
  part(c, c:ellipse(14, 22, 5, 3), "#2a2a30"); c:fill(R(c, 8, 22, 12, 24), "#f4eee0"); c:fill(R(c, 6, 23, 8, 25), "#f4eee0")
  part(c, c:ellipse(20, 19, 3, 3), "#2a2a30")
  c:px(21, 18, "#f4eee0")
  part(c, c:poly({ { 22, 17 }, { 31, 19 }, { 31, 21 }, { 23, 22 } }), "#e8a317")
  c:fill(R(c, 22, 15, 26, 17), "#f5cf6a")
  fruit(c, 31, 22, 1, "#a8305a", "#e0709a")
  -- gnome handing up a fig
  gnome(c, 14, 48, { s = 1.2, d = 1, eyes = "open", arms = { A({ 4, 8 }, { 6, 17 }, true), A({ -4, 7 }, { -5, 4 }, false) } })
  fruit(c, 22, 26, 2, "#a8305a", "#e0709a")
  -- basket of figs
  part(c, R(c, 55, 43, 64, 48), "#c08a52"); fl(c, R(c, 55, 44, 64, 44), "#8a5a35")
  for _, x in ipairs({ 57, 60, 63 }) do fruit(c, x, 42, 2, "#a8305a", "#e0709a") end
  for _, p in ipairs({ { 56, 17 }, { 60, 11 } }) do c:fill(R(c, p[0 + 1], p[2], p[1] + 2, p[2] + 1), "#8ec040") end
  finish(c, "r_sea_hornbill_figs")
end

-- 18. rattan_ball
function S.r_sea_rattan_ball()
  seed = 201
  local c = new()
  c:bands(R(c, 5, 5, 68, 30), { "#a8dce8", "#bce4ea", "#d0ece6" }, { dir = "v" })
  c:fill(c:ellipse(18, 31, 24, 6), "#4e8a3c")
  -- market awnings behind
  for _, a in ipairs({ { 6, 22, "#dd3a2a" }, { 26, 20, "#4a8fd0" }, { 46, 22, "#e8a317" } }) do
    part(c, c:poly({ { a[1], a[2] + 4 }, { a[1] + 4, a[2] }, { a[1] + 14, a[2] }, { a[1] + 18, a[2] + 4 } }), a[3])
    for x = a[1] + 3, a[1] + 15, 4 do fl(c, R(c, x, a[2] + 1, x, a[2] + 3), "#f4eee0") end
    fl(c, R(c, a[1] + 2, a[2] + 5, a[1] + 2, a[2] + 10), "#6b4a2e"); fl(c, R(c, a[1] + 16, a[2] + 5, a[1] + 16, a[2] + 10), "#6b4a2e")
  end
  c:fill(R(c, 5, 30, 68, 49), "#d8b878")
  for _, p in ipairs({ { 10, 45 }, { 25, 47 }, { 50, 46 }, { 62, 44 }, { 38, 48 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2]), "#b89858") end
  -- ring of players
  gnome(c, 11, 46, { s = 1, d = 1, hat = "#e8a317", eyes = "open", arms = { A({ -4, 9 }, { -8, 12 }, true), A({ 4, 9 }, { 8, 14 }, true) } })
  gnome(c, 62, 46, { s = 1, d = -1, hat = "#4f9a45", eyes = "open", arms = { A({ -4, 9 }, { -8, 12 }, true), A({ 4, 9 }, { 8, 14 }, true) } })
  c:fill(c:ellipse(36, 48, 8, 1), "#b89858")
  gnome(c, 36, 40, { s = 1.1, d = 1, eyes = "happy", walk = -1, arms = { A({ -4, 9 }, { -10, 12 }, true), A({ 4, 9 }, { 10, 15 }, true) } })
  -- the woven ball
  local bx, by = 36, 12
  part(c, c:ellipse(bx, by, 4, 4), "#d9a660")
  for i = -3, 3, 2 do c:px(bx + i, by - 2, "#8a5a35"); c:px(bx + i + 1, by - 1, "#8a5a35"); c:px(bx + i, by, "#8a5a35"); c:px(bx + i + 1, by + 1, "#8a5a35") end
  c:px(bx - 2, by - 2, "#f0d090")
  for _, p in ipairs({ { 30, 8 }, { 42, 9 }, { 33, 17 }, { 40, 17 } }) do c:px(p[1], p[2], "#fbf6e6") end
  finish(c, "r_sea_rattan_ball")
end

-- 19. spinning_tops
function S.r_sea_spinning_tops()
  seed = 211
  local c = new()
  c:fill(R(c, 5, 5, 68, 30), "#c8a070")
  for x = 5, 68, 8 do fl(c, R(c, x, 5, x, 30), "#a8804e") end
  -- tools on the workshop wall
  fl(c, R(c, 9, 10, 9, 14), "#8a5a35"); c:fill(R(c, 8, 8, 12, 9), "#a8aab2")
  c:fill(c:line({ { 18, 10 }, { 28, 10 } }, 1), "#a8aab2"); fl(c, R(c, 28, 9, 30, 11), "#8a5a35")
  c:fill(R(c, 50, 9, 56, 14), "#8a5a35"); c:fill(R(c, 51, 10, 55, 13), "#c8a070")
  for _, x in ipairs({ 40, 44 }) do part(c, c:poly({ { x, 12 }, { x + 4, 12 }, { x + 2, 18 } }), "#4a8fd0") end
  -- floor planks
  c:fill(R(c, 5, 31, 68, 49), "#a8703e")
  for y = 34, 48, 5 do fl(c, R(c, 5, y, 68, y), "#8a5a35") end
  for _, p in ipairs({ { 8, 44 }, { 20, 41 }, { 48, 47 }, { 62, 38 }, { 56, 44 } }) do c:fill(R(c, p[1], p[2], p[1] + 3, p[2]), "#e8d4a0"); c:px(p[1] + 1, p[2] - 1, "#e8d4a0") end
  -- the spinning top, big, with blur arcs
  local tx, ty = 40, 36
  c:fill(c:ellipse(tx, 46, 8, 2), "#8a5a35")
  part(c, c:poly({ { tx - 5, ty }, { tx + 6, ty }, { tx + 1, 46 }, { tx, 46 } }), "#dd3a2a")
  part(c, c:ellipse(tx, ty - 1, 6, 3), "#e8a317")
  c:fill(R(c, tx - 5, ty - 1, tx + 5, ty - 1), "#4a8fd0")
  c:fill(R(c, tx, ty - 7, tx, ty - 4), "#6b3b2a"); c:fill(R(c, tx - 1, ty - 8, tx + 1, ty - 8), "#6b3b2a")
  c:fill(c:line({ { tx - 10, ty - 4 }, { tx - 11, ty + 1 }, { tx - 9, ty + 5 } }, 1), "#f4eee0")
  c:fill(c:line({ { tx + 11, ty - 4 }, { tx + 12, ty + 1 }, { tx + 10, ty + 5 } }, 1), "#f4eee0")
  -- a toppled top
  part(c, c:poly({ { 56, 44 }, { 62, 42 }, { 62, 47 } }), "#4f9a45"); part(c, c:ellipse(55, 44, 2, 3), "#e8a317")
  -- string whip: gnome launches the top
  gnome(c, 15, 47, { s = 1.25, d = 1, eyes = "open", walk = 1, arms = { A({ 4, 8 }, { 8, 5 }, true), A({ -4, 7 }, { -7, 11 }, false) } })
  c:fill(c:line({ { 25, 41 }, { 31, 44 }, { 34, 42 } }, 1), "#f4eee0")
  -- child gnome watching, hands clasped
  gnome(c, 62, 40, { s = 0.75, d = -1, hat = "#4f9a45", eyes = "happy", arms = { A({ -3, 7 }, { -4, 11 }, true) } })
  finish(c, "r_sea_spinning_tops")
end

-- 20. moon_kites (wind)
function S.r_sea_moon_kites()
  seed = 221
  local c = new()
  c:bands(R(c, 5, 5, 68, 49), { "#7ab8d8", "#98ccdc", "#b4dce0", "#c8e8e0" }, { dir = "v" })
  c:fill(c:ellipse(14, 12, 8, 2), "#f4eee0"); c:fill(c:ellipse(58, 32, 8, 2), "#f4eee0")
  for _, y in ipairs({ 18, 28, 37 }) do c:fill(R(c, 8 + (y % 7), y, 18 + (y % 7), y), "#e0f0f0"); c:fill(R(c, 44 + (y % 5), y + 3, 54 + (y % 5), y + 3), "#e0f0f0") end
  -- tangled strings
  local g1x, g1y, g2x, g2y = 22, 30, 26, 31
  c:fill(c:line({ { g1x, g1y }, { 36, 22 }, { 52, 16 } }, 1), "#f4eee0")
  c:fill(c:line({ { g2x, g2y }, { 44, 22 }, { 54, 26 } }, 1), "#f4eee0")
  c:fill(c:line({ { 36, 22 }, { 40, 25 }, { 44, 22 } }, 1), "#f4eee0")
  -- crescent kites
  local function crescent(cx, cy, r, hex, dir)
    local m = c:ellipse(cx, cy, r, r); local cut = c:ellipse(cx + dir * 4, cy, r - 1, r - 1)
    m:cut(cut)
    part(c, m, hex)
    for i = 1, 3 do c:px(cx - dir * (r - 3), cy - 3 + i * 2, "#f4eee0") end
  end
  crescent(53, 13, 8, "#e8a317", 1); crescent(60, 26, 6, "#dd5a3a", -1)
  for k = 0, 4 do c:px(51 - k, 22 + k % 2 + k, "#f4eee0") end
  c:fill(R(c, 50, 22, 51, 22), "#dd3a2a")
  -- hum arcs from the bows
  c:fill(c:line({ { 63, 9 }, { 65, 12 }, { 63, 15 } }, 1), "#fbf6e6"); c:fill(c:line({ { 66, 8 }, { 68, 12 }, { 66, 16 } }, 1), "#fbf6e6")
  -- tower platform and railing
  part(c, R(c, 5, 40, 40, 44), "#a8703e"); fl(c, R(c, 5, 40, 40, 40), "#c08a52")
  for _, x in ipairs({ 7, 20, 38 }) do part(c, R(c, x, 34, x + 1, 40), "#6b4a2e", { noline = true }) end
  fl(c, R(c, 6, 34, 39, 34), "#6b4a2e")
  c:fill(R(c, 5, 45, 36, 49), "#8a5a35"); c:fill(R(c, 5, 45, 36, 45), "#6b3b2a")
  -- gnome with a spool, looking up
  gnome(c, 14, 40, { s = 1.2, d = 1, eyes = "open", arms = { A({ 4, 8 }, { 9, 12 }, true), A({ -4, 7 }, { 3, 9 }, true) } })
  part(c, c:ellipse(23, 33, 2, 2), "#8a5a35"); c:fill(R(c, 23, 31, 23, 35), "#e8d4a0")
  finish(c, "r_sea_moon_kites")
end

-- 21. pantun_trade
function S.r_sea_pantun_trade()
  seed = 231
  local c = new()
  c:fill(R(c, 5, 5, 68, 49), "#d8c8a0")
  c:bands(R(c, 5, 5, 68, 36), { "#d8c8a0", "#dccca4", "#e0d0a8" }, { dir = "v" })
  -- pavilion: pillars, roof beam, hanging lantern
  c:fill(R(c, 5, 5, 68, 10), "#a8402e"); fl(c, R(c, 5, 10, 68, 10), "#6a2a1e")
  for x = 7, 66, 6 do c:px(x, 7, "#e8a317"); c:px(x + 1, 8, "#e8a317") end
  part(c, R(c, 6, 10, 9, 49), "#8e3a2a", { noline = true }); part(c, R(c, 63, 10, 66, 49), "#8e3a2a", { noline = true })
  hang(c, 36, 11, 15, "#6b3b2a"); part(c, R(c, 33, 16, 39, 22), "#e8a317"); fl(c, R(c, 35, 17, 37, 20), "#fff1c8")
  -- floor boards
  c:fill(R(c, 5, 44, 68, 49), "#a8703e"); fl(c, R(c, 5, 44, 68, 44), "#c08a52")
  -- two benches facing
  part(c, R(c, 10, 38, 26, 40), "#8a5a35"); part(c, R(c, 46, 38, 62, 40), "#8a5a35")
  for _, x in ipairs({ 12, 24, 48, 60 }) do fl(c, R(c, x, 41, x + 1, 46), "#6b3b2a") end
  gnome(c, 16, 38, { sit = true, s = 1, d = 1, eyes = "happy", arms = { A({ 4, 6 }, { 8, 12 }, true) } })
  gnome(c, 56, 38, { sit = true, s = 1, d = -1, hat = "#e8a317", eyes = "open", arms = { A({ -4, 6 }, { -8, 11 }, true) } })
  -- verses flying across: little four-line scrolls in bubbles
  local function verse(x, y, col)
    part(c, R(c, x, y, x + 9, y + 8), "#f4eee0")
    c:px(x + 2, y + 9, "#f4eee0"); c:px(x + 1, y + 10, "#f4eee0")
    for i = 0, 3 do c:fill(R(c, x + 2, y + 1 + i * 2, x + 7 - (i % 2) * 2, y + 1 + i * 2), col) end
  end
  verse(24, 14, "#4a6e9a"); verse(40, 22, "#a8402e")
  c:fill(c:line({ { 35, 18 }, { 38, 20 } }, 1), "#e0708a")
  for _, p in ipairs({ { 33, 28 }, { 36, 31 }, { 31, 33 } }) do c:fill(R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#f08aa0") end
  finish(c, "r_sea_pantun_trade")
end

-- 22. market_boats
function S.r_sea_market_boats()
  seed = 241
  local c = new()
  c:bands(R(c, 5, 5, 68, 26), { "#a8dce8", "#bce4ea", "#d0ece6" }, { dir = "v" })
  c:fill(c:ellipse(14, 27, 20, 5), "#4e8a3c"); c:fill(c:ellipse(60, 27, 18, 4), "#4e8a3c")
  water(c, 27, 49, { "#5ab0b8", "#4aa0ae", "#3f94a6", "#388898" }, "#a8e6e6")
  -- back row of single-fruit boats
  local function pile(x, y, col, hi)
    boat(c, x, x + 14, y + 4, "#8a5a35", "#c08a52")
    for i = 0, 4 do fruit(c, x + 2 + i * 2 + (i % 2), y + 2, 2, col, hi) end
    for i = 0, 2 do fruit(c, x + 4 + i * 3, y, 2, col, hi) end
    c:fill(c:poly({ { x + 6, y - 8 }, { x + 10, y - 3 }, { x + 2, y - 3 } }), "#d9b870")
  end
  pile(6, 33, "#dd3a2a", "#f58a6a"); pile(30, 31, "#f0c830", "#fff0a0"); pile(52, 33, "#4f9a45", "#a8d070")
  -- paddle with chalked tally
  c:fill(R(c, 17, 22, 18, 49), "#8a5a35")
  part(c, R(c, 11, 8, 25, 22), "#c08a52")
  c:fill(R(c, 12, 9, 24, 21), "#2f4a3a")
  for i = 0, 3 do c:fill(R(c, 14 + i * 3, 11, 14 + i * 3, 15), "#f4eee0") end
  c:fill(c:line({ { 13, 16 }, { 23, 14 } }, 1), "#f4eee0")
  for i = 0, 2 do c:fill(R(c, 14 + i * 3, 18, 14 + i * 3, 20), "#f4eee0") end
  -- gnome in own boat with mangoes
  gnome(c, 38, 44, { upper = true, s = 1.25, d = -1, eyes = "open", arms = { A({ -4, 7 }, { -8, 12 }, true) } })
  boat(c, 22, 56, 44, "#8a5a35", "#c08a52")
  c:fill(R(c, 26, 45, 52, 46), "#6b3b2a")
  for i = 0, 5 do fruit(c, 28 + i * 5, 43, 2, "#f08a2a", "#ffc070") end
  c:fill(R(c, 24, 49, 54, 49), "#a8e6e6")
  finish(c, "r_sea_market_boats")
end

-- 23. tangle_orchids
function S.r_sea_tangle_orchids()
  seed = 251
  local c = new()
  c:bands(R(c, 5, 5, 68, 49), { "#a8d4b8", "#b8e0c0", "#c8e8c8" }, { dir = "v" })
  -- herb shed eaves with hanging pots
  c:fill(c:poly({ { 5, 5 }, { 68, 5 }, { 68, 12 }, { 5, 16 } }), "#8a7a3a")
  for x = 7, 66, 4 do fl(c, R(c, x, 6, x, 11), "#6a5a2a") end
  for _, p in ipairs({ { 14, 15 }, { 33, 13 }, { 55, 12 } }) do
    hang(c, p[1], 12, p[2] + 5, "#6b3b2a")
    part(c, c:ellipse(p[1], p[2] + 8, 3, 3), "#8a5a35")
    orchid(c, p[1] - 1, p[2] + 3, ({ "#f08aa0", "#b070d0", "#f4eee0" })[((p[1] // 7) % 3) + 1])
    c:fill(c:line({ { p[1] + 2, p[2] + 5 }, { p[1] + 4, p[2] + 11 } }, 1), "#4f9a45")
    orchid(c, p[1] + 4, p[2] + 12, "#f4eee0", "#e0709a")
  end
  -- tree trunk with orchids clinging to the bark (right)
  part(c, R(c, 58, 14, 66, 49), "#6b4a2e")
  for _, y in ipairs({ 22, 34 }) do fl(c, R(c, 60, y, 60, y + 8), "#4e3220") end
  orchid(c, 60, 24, "#b070d0"); orchid(c, 64, 30, "#f08aa0"); orchid(c, 61, 38, "#f0c030", "#dd3a2a"); orchid(c, 63, 18, "#f4eee0")
  c:fill(c:line({ { 59, 26 }, { 55, 30 } }, 1), "#4f9a45")
  -- stall post at left with orchids tied on
  part(c, R(c, 8, 20, 11, 49), "#8a5a35")
  orchid(c, 10, 26, "#f08aa0"); orchid(c, 9, 34, "#b070d0", "#f0c030"); orchid(c, 10, 42, "#f4eee0")
  -- gnome holds up the keeper's pick
  gnome(c, 34, 48, { s = 1.25, d = 1, eyes = "happy", arms = { A({ 4, 8 }, { 8, 15 }, true), A({ -4, 7 }, { -3, 4 }, false) } })
  c:fill(c:line({ { 44, 28 }, { 44, 31 } }, 1), "#4f9a45")
  orchid(c, 44, 25, "#b070d0", "#f0c030"); orchid(c, 47, 27, "#d890e8", "#f0c030")
  -- mist
  for _, p in ipairs({ { 20, 34 }, { 48, 42 }, { 24, 22 }, { 50, 20 } }) do c:fill(R(c, p[1], p[2], p[1] + 5, p[2]), "#e4f4ea") end
  finish(c, "r_sea_tangle_orchids")
end

-- 24. forest_sounds
function S.r_sea_forest_sounds()
  seed = 261
  local c = new()
  c:bands(R(c, 5, 5, 68, 40), { "#274a30", "#2f5a38", "#386a40", "#42784a" }, { dir = "v" })
  -- light shafts
  for _, x in ipairs({ 30, 44 }) do c:fill(c:poly({ { x, 5 }, { x + 6, 5 }, { x + 18, 45 }, { x + 10, 45 } }), "#5a9050") end
  -- giant trunks
  part(c, R(c, 5, 5, 16, 49), "#4a3422"); part(c, R(c, 58, 5, 68, 49), "#4a3422")
  for _, x in ipairs({ 8, 12, 61, 65 }) do fl(c, R(c, x, 5, x, 47), "#362414") end
  c:fill(c:poly({ { 16, 49 }, { 16, 38 }, { 22, 49 } }), "#4a3422"); c:fill(c:poly({ { 58, 49 }, { 58, 38 }, { 52, 49 } }), "#4a3422")
  -- hornbill on a branch
  c:fill(c:line({ { 58, 14 }, { 48, 15 }, { 40, 14 } }, 2), "#4a3422")
  part(c, c:ellipse(46, 11, 4, 3), "#2a2a30"); part(c, c:ellipse(43, 9, 2, 2), "#2a2a30"); c:fill(R(c, 49, 12, 52, 14), "#f4eee0")
  c:fill(c:poly({ { 40, 8 }, { 46, 9 }, { 40, 11 } }), "#e8a317"); c:px(42, 8, "#f5cf6a")
  -- forest floor
  c:fill(R(c, 5, 41, 68, 49), "#2f6a38"); c:fill(R(c, 5, 41, 68, 41), "#4f9a45")
  for _, x in ipairs({ 20, 26, 48, 54 }) do c:fill(c:line({ { x, 44 }, { x - 2, 40 } }, 1), "#5aa050"); c:fill(c:line({ { x, 44 }, { x + 2, 40 } }, 1), "#5aa050") end
  -- frog
  part(c, c:ellipse(52, 44, 3, 2), "#8ec040"); c:px(51, 42, "#1a1008"); c:px(53, 42, "#1a1008")
  -- gnome sitting still, eyes shut, hand cupped to the ear
  gnome(c, 32, 42, { sit = true, s = 1.1, d = 1, eyes = "shut", arms = { A({ 4, 6 }, { 3, 14 }, true) } })
  -- songs, taking turns
  note(c, 22, 20, "#f5cf6a"); note(c, 27, 12, "#a8e6e6"); note(c, 52, 24, "#f08aa0"); note(c, 46, 31, "#f5cf6a"); note(c, 20, 31, "#f08aa0"); note(c, 36, 8, "#fbf6e6")
  for _, p in ipairs({ { 24, 36 }, { 44, 22 }, { 30, 16 } }) do c:px(p[1], p[2], "#f5e08a") end
  finish(c, "r_sea_forest_sounds")
end

local order = {"r_sea_firefly_paddle","r_sea_bamboo_gutters","r_sea_buffalo_wallow","r_sea_volcano_plume","r_sea_gecko_calls","r_sea_hail_boat","r_sea_judge_durian","r_sea_flooded_causeway","r_sea_beat_husks","r_sea_lemongrass_curry","r_sea_wok_rice","r_sea_fruit_bowl","r_sea_paddy_pot","r_sea_paddy_bunds","r_sea_ease_roots","r_sea_thatch_stilt","r_sea_hornbill_figs","r_sea_rattan_ball","r_sea_spinning_tops","r_sea_moon_kites","r_sea_pantun_trade","r_sea_market_boats","r_sea_tangle_orchids","r_sea_forest_sounds"}
for _, s2 in ipairs(order) do
  if S[s2] and (not only or only == s2) then seed = 7; S[s2]() end
end
