-- variety-act-h10.lua : first-pass Do-tab scenes for 24 regional rest-stop activities -> act-<slug>.png (144x108, 72x54 grid at out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-h10.lua   (params BEFORE --script)
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
local function wisp(c, x, y, n, col)
  for i = 0, n do
    local sx = x + ((i % 2 == 0) and 0 or 1)
    fl(c, R(c, sx, y - i * 2, sx + 1, y - i * 2 + 1), col or "#f4f8fa")
  end
end
local function leafy(c, x, y, rx, ry, col, col2)
  part(c, c:ellipse(x, y, rx, ry), col, { shade = true })
  if col2 then c:fill(c:ellipse(x - 1, y - 1, rx - 3, ry - 3), col2) end
end

---------------------------------------------------------------- h10 helpers
local function goat(c, x, yb, d, col)
  col = col or "#f4eee0"
  fl(c, R(c, x - 3, yb - 1, x - 3, yb), "#5a3a22"); fl(c, R(c, x + 2, yb - 1, x + 2, yb), "#5a3a22")
  part(c, R(c, x - 3, yb - 5, x + 3, yb - 2), col)
  local hx = x + d * 4
  part(c, R(c, hx - 1, yb - 8, hx + 1, yb - 4), col)
  fl(c, R(c, hx - 1 + d, yb - 10, hx - 1 + d, yb - 9), "#8a6a44"); fl(c, R(c, hx + 1 + d, yb - 10, hx + 1 + d, yb - 9), "#8a6a44")
  c:px(hx + d, yb - 7, "#1a1008"); fl(c, R(c, hx, yb - 4, hx, yb - 3), "#c8b890")
  fl(c, R(c, x - d * 4, yb - 5, x - d * 4, yb - 4), col)
end
local function wolf(c, x, yb, d, col)
  col = col or "#7a7e88"
  fl(c, R(c, x - 3, yb - 1, x - 3, yb), "#4a4e58"); fl(c, R(c, x + 3, yb - 1, x + 3, yb), "#4a4e58")
  fl(c, R(c, x - 1, yb - 1, x - 1, yb), "#4a4e58"); fl(c, R(c, x + 1, yb - 1, x + 1, yb), "#4a4e58")
  part(c, R(c, x - 4, yb - 5, x + 4, yb - 2), col)
  local hx = x + d * 5
  part(c, R(c, hx - 2, yb - 8, hx + 2, yb - 4), col)
  fl(c, R(c, hx + d * 2, yb - 5, hx + d * 4, yb - 4), "#a8acb4")
  fl(c, R(c, hx - 2, yb - 10, hx - 2, yb - 9), col); fl(c, R(c, hx + 2, yb - 10, hx + 2, yb - 9), col)
  c:px(hx + d, yb - 7, "#e8c030"); c:px(hx + d * 4, yb - 5, "#1a1008")
  local tx = x - d * 5
  fl(c, R(c, math.min(tx, tx - d * 2), yb - 5, math.max(tx, tx - d * 2), yb - 4), col)
  fl(c, R(c, tx - d * 2, yb - 4, tx - d * 2, yb - 3), "#4a4e58")
end
local function cabbage(c, x, yb, r)
  r = r or 3
  part(c, c:ellipse(x, yb - r, r, r), "#6fae4a", { shade = true })
  c:fill(c:ellipse(x, yb - r, r - 2, r - 2), "#9ad06a"); c:px(x - 1, yb - r, "#6fae4a"); c:px(x, yb - r - 1, "#cfe8a0")
end
local function sparkle(c, x, y, col) c:px(x, y, col); c:px(x - 1, y, col); c:px(x + 1, y, col); c:px(x, y - 1, col); c:px(x, y + 1, col) end
local function note(c, x, y, col) col = col or "#2a1a10"; c:px(x, y, col); c:px(x + 1, y, col); c:px(x + 1, y - 1, col); c:px(x + 1, y - 2, col); c:px(x + 1, y - 3, col); c:px(x + 2, y - 3, col) end
local function snowfall(c, n, col)
  for i = 1, n do
    local x, y = 6 + floor(rand() * 62), 6 + floor(rand() * 43)
    c:px(x, y, col or "#fbfdfe")
    if i % 5 == 0 then c:px(x + 1, y, col or "#fbfdfe") end
  end
end
local function birch(c, x, y0, y1, w)
  w = w or 2
  part(c, R(c, x, y0, x + w - 1, y1), "#e8e4d8", { noline = true })
  for yy = y0 + 2, y1 - 1, 4 do fl(c, R(c, x, yy, x + (yy % 3 == 0 and w - 1 or 0), yy), "#2a2a2a") end
end

---------------------------------------------------------------- EE scenes
-- 1. wolf_goat_cabbage: ferrying goat and cabbage across, the wolf watching from the bank
function S.r_ee_wolf_goat_cabbage()
  seed = 301
  local c = new()
  day(c, 27, { cloud = 46, hill = "#4e8a44", hill2 = "#3f7a3a", grass = "#6a9a4e" })
  c:fill(R(c, 0, 27, W - 1, H - 1), "#4f9fb8")
  c:fill(R(c, 0, 27, W - 1, 28), "#6a9a4e")
  for y = 31, 49, 3 do for x = 6 + (y % 6), 68, 11 do fl(c, R(c, x, y, x + 3, y), "#78bdd0") end end
  -- left bank
  part(c, c:ellipse(6, 44, 14, 8), "#7ea85a", { shade = true })
  fl(c, R(c, 5, 39, 18, 40), "#9cc070")
  wolf(c, 12, 43, 1)
  -- boat
  part(c, c:poly({ { 20, 40 }, { 62, 40 }, { 58, 46 }, { 24, 46 } }), "#a8703e")
  fl(c, R(c, 22, 41, 60, 41), "#c08a52"); fl(c, R(c, 26, 44, 56, 44), "#8a5a35")
  fl(c, R(c, 24, 47, 58, 47), "#78bdd0")
  goat(c, 46, 40, -1)
  cabbage(c, 55, 40, 3)
  -- pole
  fl(c, c:line({ { 38, 30 }, { 41, 49 } }, 1), "#8a5a35")
  gnome(c, 30, 40, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -6, 4 }, false), arm({ 4, 7 }, { 8, 11 }, true) } })
  finish(c, "r_ee_wolf_goat_cabbage")
end

-- 2. snow_fort: duck behind a snow wall, snowball in hand, another flying overhead
function S.r_ee_snow_fort()
  seed = 302
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#9fb0c4", "#b4c2d2", "#c8d3de", "#dbe3ea" }, { dir = "v" })
  c:fill(c:ellipse(16, 32, 30, 8), "#d8e2ec"); c:fill(c:ellipse(58, 31, 28, 7), "#d0dbe6")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#eef3f7")
  c:fill(R(c, 0, 44, W - 1, H - 1), "#e0e8f0")
  pine(c, 9, 33, 16, true); pine(c, 64, 33, 14, true)
  -- far fort (right) with a peeking small gnome
  gnome(c, 57, 34, { upper = true, s = 0.8, d = -1, hat = "#4f9a45", eyes = "open", arms = { arm({ -4, 7 }, { -7, 12 }, true) } })
  part(c, R(c, 47, 32, 67, 39), "#f4f8fa", { noline = false })
  for x = 48, 66, 4 do fl(c, R(c, x, 30, x + 1, 31), "#f4f8fa"); part(c, R(c, x, 31, x + 1, 32), "#f4f8fa", { noline = true }) end
  fl(c, R(c, 48, 38, 66, 39), "#d6e2ec")
  -- near fort wall (left, bottom)
  part(c, R(c, 5, 39, 38, 49), "#f8fbfc", { noline = false })
  for x = 6, 36, 5 do part(c, R(c, x, 37, x + 2, 39), "#f8fbfc", { noline = true }) end
  for y = 43, 48, 3 do fl(c, R(c, 6, y, 37, y), "#d6e2ec") end
  for x = 12, 36, 8 do fl(c, R(c, x, 40, x, 49), "#d6e2ec") end
  gnome(c, 22, 38, { upper = true, eyes = "open", arms = { arm({ 4, 7 }, { 9, 14 }, true) } })
  -- snowball in hand and one flying
  local function ball(x, y) part(c, c:ellipse(x, y, 2, 2), "#fcfcfa", { noline = false }) end
  ball(33, 22)
  ball(42, 17); fl(c, R(c, 36, 19, 38, 19), "#fcfcfa"); fl(c, R(c, 38, 18, 40, 18), "#fcfcfa")
  ball(14, 14); fl(c, R(c, 8, 16, 10, 16), "#fcfcfa"); fl(c, R(c, 10, 15, 12, 15), "#fcfcfa")
  snowfall(c, 24)
  finish(c, "r_ee_snow_fort")
end

-- 3. bark_whistle: big gnome blowing a birch-bark whistle, a thrush answers from the birch
function S.r_ee_bark_whistle()
  seed = 303
  local c = new()
  day(c, 36, { sky = { "#b8dcd8", "#cce6d8", "#dcecd0" }, cloud = false, hill = "#5e8a44", hill2 = "#4e7a3c" })
  birch(c, 46, 5, 38, 3); birch(c, 58, 5, 37, 2); birch(c, 12, 5, 38, 2)
  for _, l in ipairs({ { 52, 8 }, { 40, 10 }, { 62, 10 }, { 16, 12 }, { 8, 17 } }) do leafy(c, l[1], l[2], 6, 3, "#6fae4a", "#8ac85a") end
  -- thrush on a branch
  fl(c, R(c, 44, 20, 56, 20), "#6b4a2e")
  part(c, c:ellipse(51, 17, 3, 2), "#8a5a35"); fl(c, R(c, 50, 18, 52, 19), "#f4eee0"); c:px(52, 16, "#1a1008")
  fl(c, R(c, 54, 17, 55, 17), "#e8a317"); fl(c, R(c, 47, 17, 48, 18), "#6b4a2e")
  
  -- gnome
  local _, G = gnome(c, 27, 48, { s = 1.4, d = 1, eyes = "happy", arms = { arm({ 4, 7 }, { 4, 11 }, true) } })
  local wx, wy = G.P(4, 11)
  fl(c, R(c, wx + 1, wy - 1, wx + 6, wy + 1), "#c8a060"); fl(c, R(c, wx + 1, wy - 1, wx + 6, wy - 1), "#e8d0a0"); fl(c, R(c, wx + 3, wy, wx + 4, wy), "#2a1a10")
  for i = 0, 2 do note(c, wx + 8 + i * 4, wy - 3 - i * 3, i % 2 == 0 and "#2a1a10" or "#e08a1f") end
  finish(c, "r_ee_bark_whistle")
end

-- 4. egg_patterns: shelves of painted eggs; the gnome traces a pattern in the air
function S.r_ee_egg_patterns()
  seed = 304
  local c = new()
  c:fill(R(c, 0, 0, W - 1, H - 1), "#7a4e30")
  for y = 6, 48, 6 do fl(c, R(c, 0, y, W - 1, y), "#6a4026") end
  -- shelves
  local function egg(x, y, base, pat, pc)
    part(c, c:ellipse(x, y, 2, 3), base, { shade = false })
    if pat == 1 then fl(c, R(c, x - 2, y, x + 2, y), pc)
    elseif pat == 2 then c:px(x, y - 2, pc); c:px(x - 1, y - 1, pc); c:px(x + 1, y - 1, pc); c:px(x, y, pc); c:px(x, y + 1, pc)
    elseif pat == 3 then c:px(x - 1, y - 1, pc); c:px(x + 1, y + 1, pc); c:px(x + 1, y - 1, pc); c:px(x - 1, y + 1, pc)
    else fl(c, R(c, x, y - 2, x, y + 2), pc) end
  end
  local cols = { "#e8c030", "#c0442e", "#4f9a45", "#3f8fb0", "#f4eee0", "#c070b0" }
  local pcs = { "#c0442e", "#f4eee0", "#2a1a10", "#f4eee0", "#c0442e", "#f4eee0" }
  for r = 0, 2 do
    local y = 15 + r * 12
    part(c, R(c, 5, y + 4, 68, y + 6), "#a8703e")
    for i = 0, 7 do egg(9 + i * 8 + (r % 2) * 3, y, cols[(i + r) % 6 + 1], (i + r) % 4 + 1, pcs[(i + r) % 6 + 1]) end
  end
  -- gnome: a big egg raised to the eye, tracing with the other hand
  local _, G = gnome(c, 36, 49, { s = 1.2, d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -8, 13 }, false), arm({ 4, 8 }, { 8, 12 }, true) } })
  local ex, ey = G.P(9, 14)
  part(c, c:ellipse(ex, ey, 3, 4), "#4f9a45"); fl(c, R(c, ex - 3, ey, ex + 3, ey), "#f4eee0"); fl(c, R(c, ex - 2, ey - 2, ex + 2, ey - 2), "#c0442e"); fl(c, R(c, ex - 2, ey + 2, ex + 2, ey + 2), "#c0442e")
  -- finger-traced pattern in the air
  local tx, ty = G.P(-12, 14)
  for i = 0, 4 do c:px(tx - 2 + i, ty + (i % 2 == 0 and 0 or -1), "#ffe08a") end
  sparkle(c, tx - 3, ty - 3, "#ffe08a")
  finish(c, "r_ee_egg_patterns")
end

-- 5. amber_inclusions: holding a lump of amber up to the sun; a tiny ant inside
function S.r_ee_amber_inclusions()
  seed = 305
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#f4c878", "#f8d890", "#fae6a8", "#fbefc4" }, { dir = "v" })
  c:fill(c:ellipse(36, 12, 9, 9), "#fff4c8"); c:fill(c:ellipse(36, 12, 6, 6), "#fcfcfa")
  for a = 0, 7 do
    local dx, dy = math.cos(a * math.pi / 4), math.sin(a * math.pi / 4)
    fl(c, c:line({ { rnd(36 + dx * 12), rnd(12 + dy * 12) }, { rnd(36 + dx * 16), rnd(12 + dy * 16) } }, 1), "#fff4c8")
  end
  c:fill(c:ellipse(14, 38, 30, 7), "#7a9a52"); c:fill(c:ellipse(60, 38, 30, 7), "#6a8a48")
  c:fill(R(c, 0, 37, W - 1, H - 1), "#e8d8a8"); c:fill(R(c, 0, 37, W - 1, 37), "#f4e8c0")
  for _, t in ipairs({ { 8, 38, 18 }, { 63, 38, 20 } }) do
    part(c, R(c, t[1] - 1, t[2] - t[3], t[1] + 1, t[2]), "#a0522d", { noline = true })
    leafy(c, t[1], t[2] - t[3], 5, 3, "#3f7a3a")
  end
  -- basket of amber lumps
  part(c, c:ellipse(56, 46, 8, 3), "#a8703e"); fl(c, R(c, 49, 44, 63, 44), "#c08a52")
  for _, p in ipairs({ { 52, 43 }, { 56, 42 }, { 60, 43 } }) do part(c, c:ellipse(p[1], p[2], 2, 2), "#e8a317"); c:px(p[1] - 1, p[2] - 1, "#ffe08a") end
  local _, G = gnome(c, 26, 49, { s = 1.2, d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -6, 12 }, false), arm({ 4, 8 }, { 9, 18 }, true) } })
  local ax, ay = G.P(10, 21)
  part(c, c:ellipse(ax, ay, 5, 4), "#e8a317"); c:fill(c:ellipse(ax, ay, 3, 2), "#f5b83a"); c:fill(R(c, ax - 3, ay - 2, ax - 2, ay - 2), "#ffe08a")
  -- the ant caught inside
  fl(c, R(c, ax - 2, ay, ax + 1, ay), "#4a2a10"); c:px(ax + 2, ay - 1, "#4a2a10"); c:px(ax - 2, ay + 1, "#4a2a10"); c:px(ax, ay + 1, "#4a2a10"); c:px(ax - 1, ay - 1, "#4a2a10")
  sparkle(c, ax + 7, ay - 4, "#fcfcfa"); sparkle(c, ax - 8, ay - 6, "#fcfcfa")
  finish(c, "r_ee_amber_inclusions")
end

-- 6. marsh_calls: eyes shut on the boards, a hand cupped to the ear; reeds, a crane, a frog
function S.r_ee_marsh_calls()
  seed = 306
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#b8d8d8", "#c8e0dc", "#d8e8dc" }, { dir = "v" })
  c:fill(c:ellipse(18, 10, 8, 2), "#f4eee0"); c:fill(c:ellipse(54, 14, 6, 2), "#f4eee0")
  c:fill(R(c, 0, 28, W - 1, H - 1), "#6aa8a0")
  c:fill(R(c, 0, 28, W - 1, 30), "#7a9a58")
  for y = 33, 49, 3 do for x = 6 + (y % 5), 68, 10 do fl(c, R(c, x, y, x + 3, y), "#8cc4b8") end end
  -- reeds
  local function reed(x, top, bot) fl(c, R(c, x, top, x, bot), "#6a8a3c"); part(c, R(c, x - 1, top - 4, x, top), "#8a5a35", { noline = true }) end
  for _, r in ipairs({ { 8, 20, 36 }, { 12, 24, 36 }, { 16, 18, 37 }, { 58, 22, 36 }, { 63, 17, 37 }, { 67, 24, 36 } }) do reed(r[1], r[2], r[3]) end
  -- crane wading
  fl(c, R(c, 47, 28, 47, 37), "#4a3a30"); fl(c, R(c, 50, 28, 50, 37), "#4a3a30")
  part(c, c:ellipse(50, 25, 4, 3), "#f4f4f0"); fl(c, R(c, 52, 17, 53, 24), "#f4f4f0"); fl(c, R(c, 53, 16, 58, 17), "#e8a317"); fl(c, R(c, 52, 16, 52, 17), "#c0442e")
  fl(c, R(c, 46, 25, 47, 26), "#2a2a2a")
  -- jetty boards
  part(c, R(c, 5, 40, 68, 49), "#a8703e")
  for x = 12, 66, 11 do fl(c, R(c, x, 40, x, 49), "#6b4a2e") end
  fl(c, R(c, 5, 40, 68, 40), "#c08a52")
  for x = 18, 62, 22 do part(c, R(c, x, 49, x + 2, 49), "#4a2c1a", { noline = true }) end
  -- frog on the boards
  part(c, c:ellipse(60, 42, 3, 2), "#5faa3a"); c:px(59, 40, "#f4eee0"); c:px(61, 40, "#f4eee0"); c:px(59, 40, "#1a1008")
  local _, G = gnome(c, 30, 46, { s = 1.2, d = 1, sit = true, eyes = "shut", arms = { arm({ 4, 7 }, { 7, 12 }, true) } })
  -- sound arcs and notes
  for i = 0, 2 do
    fl(c, R(c, 41 + i * 2, 17 - i, 41 + i * 2, 21 + i), "#7a98a0")
  end
  note(c, 22, 15, "#2a1a10"); note(c, 14, 10, "#e08a1f")
  finish(c, "r_ee_marsh_calls")
end

-- 7. walnut_rattle: the keeper shakes a walnut by the gnome's ear; four nuts on a stump
function S.r_ee_walnut_rattle()
  seed = 307
  local c = new()
  day(c, 30, { sky = { "#b8d8e0", "#cce2e0", "#dcecdc" }, cloud = 52, hill = "#5e8a44", hill2 = "#4e7a3c" })
  -- walnut tree
  part(c, R(c, 9, 12, 12, 38), "#6b4a2e", { noline = true })
  leafy(c, 11, 10, 11, 7, "#3f7a3a", "#4f9a45")
  for _, p in ipairs({ { 6, 14 }, { 16, 15 }, { 11, 18 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#a07a4a") end
  -- stump table
  part(c, R(c, 28, 40, 62, 44), "#a8703e"); fl(c, R(c, 28, 40, 62, 40), "#c08a52")
  part(c, R(c, 32, 45, 36, 49), "#6b4a2e", { noline = true }); part(c, R(c, 55, 45, 59, 49), "#6b4a2e", { noline = true })
  for i = 0, 3 do part(c, c:ellipse(52 + i * 4, 38, 2, 2), i == 2 and "#b08a50" or "#a07a4a"); fl(c, R(c, 52 + i * 4, 37, 52 + i * 4, 39), "#80603a") end
  -- the keeper (green hat) at the right, shaking a walnut
  local _, K = gnome(c, 45, 40, { d = -1, upper = true, hat = "#4f9a45", eyes = "open", arms = { arm({ -4, 7 }, { -8, 13 }, true) } })
  local kx, ky = K.P(-9, 14)
  part(c, c:ellipse(kx, ky, 2, 2), "#a07a4a")
  -- the gnome leaning in, ear towards the nut
  gnome(c, 25, 49, { s = 1.2, d = 1, eyes = "happy", arms = { arm({ -4, 8 }, { -6, 4 }, false) } })
  for i = 0, 1 do fl(c, R(c, kx - 6 - i, ky - 2 + i * 3, kx - 5 - i, ky - 2 + i * 3), "#2a1a10") end
  fl(c, R(c, kx - 4, ky - 4, kx - 4, ky - 3), "#2a1a10"); fl(c, R(c, kx - 5, ky + 3, kx - 5, ky + 4), "#2a1a10")
  finish(c, "r_ee_walnut_rattle")
end

-- 8. salt_tunnels: three dark galleries in pale rose salt, the middle one sparkling
function S.r_ee_salt_tunnels()
  seed = 308
  local c = new()
  c:fill(R(c, 0, 0, W - 1, H - 1), "#d8b8b0")
  for y = 7, 46, 5 do fl(c, R(c, 0, y, W - 1, y), "#c8a8a0") end
  for y = 9, 45, 5 do for x = 4 + (y % 3) * 3, 68, 11 do fl(c, R(c, x, y, x + 4, y), "#e8d0c8") end end
  -- three arches
  local function arch(x, glow)
    local m = c:rect(x - 6, 22, x + 6, 44); m:add(c:ellipse(x, 22, 6, 7))
    part(c, m:copy():grow(1), "#a88880", { noline = true })
    c:fill(m, glow and "#3a2a44" or "#2a1e24")
    if glow then
      c:fill(c:ellipse(x, 34, 4, 6), "#5a4a78")
      for _, s2 in ipairs({ { 0, 24 }, { -3, 30 }, { 3, 28 }, { -2, 37 }, { 3, 36 }, { 0, 32 } }) do sparkle(c, x + s2[1], s2[2], "#e8f4ff") end
      c:px(x, 40, "#bfe0ff"); c:px(x - 4, 33, "#bfe0ff"); c:px(x + 4, 34, "#bfe0ff")
    end
  end
  arch(14, false); arch(36, true); arch(58, false)
  -- floor
  c:fill(R(c, 5, 44, 68, 49), "#bda49c"); fl(c, R(c, 5, 44, 68, 44), "#d8c4bc")
  for x = 10, 64, 13 do fl(c, R(c, x, 47, x + 2, 47), "#a88880") end
  -- salt-lamp hanging in the hall
  fl(c, R(c, 36, 5, 36, 12), "#4a3a30"); part(c, R(c, 33, 12, 39, 16), "#3d2a1c"); fl(c, R(c, 34, 13, 38, 15), "#ffd86a")
  -- gnome with a pick over the shoulder, looking at the middle gallery
  gnome(c, 18, 49, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 7, 11 }, true) } })
  fl(c, c:line({ { 28, 33 }, { 26, 46 } }, 1), "#8a5a35"); part(c, R(c, 24, 31, 31, 33), "#8b8f96")
  finish(c, "r_ee_salt_tunnels")
end

-- 9. lucky_dumpling: the bitten dumpling shows the hidden walnut; the table cheers
function S.r_ee_lucky_dumpling()
  seed = 309
  local c = new()
  c:fill(R(c, 0, 0, W - 1, H - 1), "#9a6a42")
  for x = 5, 68, 7 do fl(c, R(c, x, 5, x, 33), "#8a5a35") end
  -- window with snow-free dusk-blue panes, hanging pans
  part(c, R(c, 10, 8, 24, 22), "#6b4a2e"); c:fill(R(c, 12, 10, 22, 20), "#a8d4e0"); fl(c, R(c, 17, 10, 17, 20), "#6b4a2e"); fl(c, R(c, 12, 15, 22, 15), "#6b4a2e")
  fl(c, R(c, 60, 7, 60, 12), "#4a3a30"); part(c, c:ellipse(60, 15, 4, 3), "#8b8f96")
  -- table with embroidered cloth
  part(c, R(c, 5, 38, 68, 49), "#f4eee0"); fl(c, R(c, 5, 38, 68, 38), "#fcfcfa")
  for x = 7, 66, 4 do fl(c, R(c, x, 46, x + 1, 46), "#c0442e"); fl(c, R(c, x + 2, 48, x + 3, 48), "#3f8fb0") end
  -- plate of dumplings
  part(c, c:ellipse(18, 42, 12, 4), "#e8e4d8"); fl(c, R(c, 8, 41, 28, 41), "#fcfcfa")
  for _, p in ipairs({ { 11, 39 }, { 17, 38 }, { 23, 39 }, { 14, 42 }, { 21, 42 } }) do
    part(c, c:ellipse(p[1], p[2], 3, 2), "#f0d8a8"); c:px(p[1] - 1, p[2] - 1, "#fcf0d0"); c:px(p[1] + 1, p[2], "#c0442e")
  end
  -- cherries on the plate edge
  part(c, c:ellipse(30, 44, 2, 2), "#c0243a"); c:px(29, 43, "#f0a0a0")
  -- gnome biting the dumpling, walnut showing
  local _, G = gnome(c, 46, 38, { s = 1.2, d = -1, upper = true, eyes = "happy", arms = { arm({ -4, 7 }, { -7, 11 }, true) } })
  local dx, dy = G.P(-9, 12)
  part(c, c:ellipse(dx, dy, 5, 4), "#f0d8a8"); c:fill(c:ellipse(dx - 2, dy, 3, 3), "#b84a5a")
  part(c, c:ellipse(dx - 2, dy, 2, 2), "#a07a4a"); c:px(dx - 2, dy - 1, "#d6b080"); c:px(dx - 1, dy, "#7a5a2a")
  fl(c, R(c, dx - 6, dy - 7, dx - 6, dy - 6), "#ffe08a"); fl(c, R(c, dx - 1, dy - 9, dx - 1, dy - 8), "#ffe08a"); fl(c, R(c, dx + 3, dy - 8, dx + 3, dy - 7), "#ffe08a")
  -- a cheering neighbour
  gnome(c, 62, 38, { s = 0.9, d = -1, upper = true, hat = "#e8a317", eyes = "happy", arms = { arm({ -4, 8 }, { -7, 15 }, true), arm({ 4, 8 }, { 7, 15 }, true) } })
  finish(c, "r_ee_lucky_dumpling")
end

-- 10. skittle_town: a thrown stick bowls through a tiny town of skittles
function S.r_ee_skittle_town()
  seed = 310
  local c = new()
  day(c, 30, { cloud = 24, hill = "#6a9a4e", hill2 = "#5e8a44" })
  c:fill(R(c, 0, 33, W - 1, H - 1), "#d8b878"); fl(c, R(c, 0, 33, W - 1, 33), "#e8cc90")
  for _, p in ipairs({ { 12, 40 }, { 30, 44 }, { 50, 47 }, { 62, 41 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#c8a060") end
  -- bunting
  fl(c, c:line({ { 5, 9 }, { 36, 14 }, { 68, 9 } }, 1), "#4a3a30")
  local cc = { "#c0442e", "#e8a317", "#3f8fb0", "#4f9a45" }
  for i = 0, 7 do local x = 9 + i * 7; local y = 10 + floor(4 * math.sin((x - 5) / 63 * math.pi)); fl(c, R(c, x, y, x + 2, y + 2), cc[i % 4 + 1]); fl(c, R(c, x + 1, y + 3, x + 1, y + 3), cc[i % 4 + 1]) end
  -- skittle town: a little cluster of skittles with a bigger "tower"
  local function skittle(x, yb, h, col, tilt)
    part(c, R(c, x - 1, yb - h, x + 1, yb), col or "#e8c48a"); fl(c, R(c, x - 1, yb - h + 2, x + 1, yb - h + 2), "#c0442e")
    part(c, c:ellipse(x, yb - h - 1, 1, 1), "#e8c48a")
  end
  for i = 0, 4 do skittle(46 + i * 4, 42, 4) end
  for i = 0, 3 do skittle(48 + i * 4, 38, 4, "#d9a660") end
  skittle(52, 34, 5, "#e8d0a0"); skittle(56, 34, 5, "#e8d0a0")
  -- flying skittles
  local function fly(x, y, ang) fl(c, c:line({ { x, y }, { x + ang, y - 3 } }, 2), "#e8c48a"); c:px(x, y, "#c0442e") end
  fly(62, 26, 3); fly(67, 33, 2); fly(42, 29, -3)
  -- thrown stick mid-air
  fl(c, c:line({ { 28, 29 }, { 41, 36 } }, 2), "#8a5a35"); fl(c, R(c, 40, 36, 41, 37), "#6b3b2a")
  for i = 0, 2 do fl(c, R(c, 24 - i * 2, 25 + i, 25 - i * 2, 25 + i), "#fcfcfa") end
  -- gnome with a throw follow-through
  gnome(c, 16, 47, { s = 1.2, d = 1, eyes = "open", arms = { arm({ -4, 9 }, { -7, 6 }, false), arm({ 4, 9 }, { 9, 15 }, true) } })
  finish(c, "r_ee_skittle_town")
end

-- 11. birch_swing: swinging high, toes reaching the ribbon in the branches
function S.r_ee_birch_swing()
  seed = 311
  local c = new()
  day(c, 38, { sky = { "#b8dcec", "#cce6ec", "#dcf0e8" }, cloud = 40, hill = "#5e8a44", hill2 = "#4e7a3c" })
  part(c, R(c, 8, 5, 12, 49), "#e8e4d8", { noline = true })
  for y = 8, 46, 4 do fl(c, R(c, 8, y, 8 + (y % 3), y), "#2a2a2a") end
  part(c, R(c, 12, 8, 64, 9), "#e8e4d8", { noline = true })
  for x = 18, 62, 6 do fl(c, R(c, x, 9, x + 1, 9), "#2a2a2a") end
  for _, l in ipairs({ { 18, 12 }, { 28, 7 }, { 52, 6 }, { 62, 12 }, { 40, 5 } }) do leafy(c, l[1], l[2], 6, 3, "#6fae4a", "#8ac85a") end
  for _, p in ipairs({ { 20, 30 }, { 14, 38 }, { 60, 40 }, { 50, 46 } }) do c:px(p[1], p[2], "#f4c0d0"); c:px(p[1] + 1, p[2], "#f4c0d0") end
  -- ribbon hanging from the end of the branch
  fl(c, R(c, 58, 10, 58, 24), "#c0442e"); fl(c, R(c, 59, 20, 60, 26), "#c0442e"); fl(c, R(c, 57, 22, 57, 28), "#e8a317")
  -- ropes and the swing board high on the arc
  fl(c, R(c, 32, 9, 32, 29), "#8a6a44"); fl(c, R(c, 44, 9, 44, 29), "#8a6a44")
  part(c, R(c, 30, 29, 46, 31), "#a8703e")
  gnome(c, 38, 29, { s = 0.95, d = 1, sit = true, eyes = "happy", arms = { arm({ -4, 6 }, { -6, 12 }, false, true), arm({ 4, 6 }, { 6, 12 }, true, true) } })
  fl(c, R(c, 32, 21, 32, 29), "#8a6a44"); fl(c, R(c, 44, 21, 44, 29), "#8a6a44")
  -- swing trail on the ground
  fl(c, R(c, 24, 44, 52, 45), "#6a9a4e")
  for _, p in ipairs({ { 22, 33 }, { 20, 37 } }) do fl(c, R(c, p[1], p[2], p[1], p[2] + 2), "#dcf0e8") end
  finish(c, "r_ee_birch_swing")
end

-- 12. wolf_king (night): a huge grey wolf howls on the ridge before the moon; the gnome listens by the fire under a blanket
function S.r_ee_wolf_king()
  seed = 312
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#0e1630", "#141e3e", "#1a2848", "#203050" }, { dir = "v" })
  for i = 1, 30 do c:px(5 + floor(rand() * 63), 5 + floor(rand() * 30), (i % 4 == 0) and "#f4eee0" or "#8a9cc0") end
  c:fill(c:ellipse(30, 20, 14, 14), "#f4eec8"); c:fill(c:ellipse(30, 20, 12, 12), "#ece4b0")
  fl(c, R(c, 24, 15, 27, 16), "#d8d09a"); fl(c, R(c, 34, 26, 37, 27), "#d8d09a"); fl(c, R(c, 28, 11, 29, 12), "#d8d09a")
  -- ridge
  c:fill(c:ellipse(26, 46, 34, 13), "#1a2a38"); c:fill(c:ellipse(62, 47, 20, 10), "#16222e")
  -- the wolf: dark against the moon, muzzle to the sky
  local W0 = "#0c1420"
  local wm = c:mask()
  wm:add(c:rect(16, 27, 30, 32))
  for _, lx in ipairs({ 16, 19, 27, 30 }) do wm:add(c:rect(lx - 1, 32, lx, 37)) end
  wm:add(c:poly({ { 15, 28 }, { 18, 28 }, { 12, 36 }, { 10, 35 } }))
  wm:add(c:poly({ { 26, 28 }, { 31, 28 }, { 35, 19 }, { 31, 17 } }))
  wm:add(c:poly({ { 31, 18 }, { 36, 11 }, { 40, 8 }, { 41, 10 }, { 37, 17 }, { 35, 20 } }))
  wm:add(c:poly({ { 31, 18 }, { 32, 13 }, { 34, 17 } }))
  c:fill(wm, W0)
  c:px(37, 14, "#e8c030")
  for _, p in ipairs({ { 44, 7, 2 }, { 46, 10, 3 }, { 48, 13, 3 } }) do fl(c, R(c, p[1], p[2], p[1] + p[3], p[2]), "#a8acb4") end
  -- foreground slope
  c:fill(R(c, 5, 41, 68, 49), "#10202e"); fl(c, R(c, 5, 41, 68, 41), "#1c3042")
  pine(c, 8, 44, 18, false); pine(c, 64, 44, 18, false); pine(c, 58, 44, 13, false)
  -- fire and gnome in a blanket
  part(c, R(c, 28, 47, 36, 48), "#4a2c1a", { noline = true })
  c:fill(c:poly({ { 32, 39 }, { 36, 47 }, { 28, 47 } }), "#e8731a"); c:fill(c:poly({ { 32, 42 }, { 34, 47 }, { 30, 47 } }), "#ffd86a")
  gnome(c, 48, 41, { d = -1, upper = true, eyes = "open", arms = {} })
  local bl = c:ellipse(48, 44, 9, 7):clip(R(c, 0, 0, W, 49))
  part(c, bl, "#8a3a5a")
  c:fill(bl:copy():clip(R(c, 0, 41, W, 42)), "#e8a317"); c:fill(bl:copy():clip(R(c, 0, 46, W, 47)), "#e8a317")
  fl(c, R(c, 44, 38, 52, 38), "#a8486a")
  finish(c, "r_ee_wolf_king")
end

-- 13. salt_whispers: a candle in a niche of rose salt; an old miner whispers close
function S.r_ee_salt_whispers()
  seed = 313
  local c = new()
  c:fill(R(c, 0, 0, W - 1, H - 1), "#c8908c")
  for y = 7, 48, 5 do fl(c, R(c, 0, y, W - 1, y), "#b87c78") end
  for y = 9, 47, 5 do for x = 3 + (y % 3) * 3, 68, 9 do fl(c, R(c, x, y, x + 3, y), "#e8b8b0") end end
  -- candle niche (carved arch)
  local m = c:rect(30, 20, 42, 34); m:add(c:ellipse(36, 20, 6, 6))
  c:fill(m, "#f4d0b8"); c:fill(c:ellipse(36, 28, 5, 6), "#fce4a0")
  part(c, R(c, 33, 30, 39, 34), "#a07a4a", { noline = true })
  part(c, R(c, 35, 24, 37, 30), "#f4eee0"); fl(c, R(c, 36, 21, 36, 23), "#ffd86a"); c:px(36, 22, "#e0501f")
  -- tiny salt bear on the shelf
  part(c, c:ellipse(53, 33, 3, 2), "#f0e0d8"); part(c, c:ellipse(56, 31, 2, 2), "#f0e0d8"); c:px(55, 29, "#f0e0d8"); c:px(57, 29, "#f0e0d8")
  part(c, R(c, 48, 35, 60, 36), "#a8605a", { noline = true })
  -- floor
  c:fill(R(c, 5, 44, 68, 49), "#a8706a"); fl(c, R(c, 5, 44, 68, 44), "#c89088")
  -- the old miner (grey beard, bowed lantern helmet) whispering to the gnome
  local _, O = gnome(c, 16, 49, { s = 1.15, d = 1, hat = "#8a8a98", eyes = "open", arms = { arm({ 4, 8 }, { 7, 12 }, true) } })
  local _, G = gnome(c, 56, 49, { s = 1.15, d = -1, eyes = "happy", arms = { arm({ -4, 7 }, { -7, 5 }, false) } })
  -- whisper marks and echo rings
  for i = 0, 2 do fl(c, R(c, 25 + i * 3, 36 - i, 25 + i * 3, 38 + i), "#fce4a0") end
  for _, p in ipairs({ { 40, 12 }, { 49, 19 }, { 28, 14 } }) do c:px(p[1], p[2], "#fce4a0"); c:px(p[1] + 1, p[2], "#fce4a0") end
  finish(c, "r_ee_salt_whispers")
end

-- 14. sunflower_whispers (dusk): gnome with a cupped ear at a bowed sunflower; one faces the moon
function S.r_ee_sunflower_whispers()
  seed = 314
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 36), { "#4a3a6a", "#7a4a78", "#b8587a", "#e08a68", "#f4b868" }, { dir = "v" })
  c:fill(c:ellipse(60, 12, 3, 3), "#f4eec8")
  for _, p in ipairs({ { 10, 8 }, { 24, 12 }, { 36, 7 }, { 48, 10 } }) do c:px(p[1], p[2], "#e8d8f0") end
  c:fill(c:ellipse(18, 36, 34, 5), "#4a5a3a"); c:fill(c:ellipse(58, 37, 30, 4), "#3a4a32")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#4a5a2e")
  for x = 5, 68, 4 do fl(c, R(c, x, 38 + (x % 3), x + 1, 39 + (x % 3)), "#5a6a38") end
  local function sunflower(x, yb, top, face, big)
    local r = big and 6 or 4
    fl(c, R(c, x, top + r, x, yb), "#3f6a2a"); fl(c, R(c, x - 3, top + r + 8, x - 1, top + r + 9), "#4f8a36")
    local hx = x + face
    c:fill(c:ellipse(hx, top, r + 2, r + 2), "#e8a317"); c:fill(c:ellipse(hx, top, r, r), "#5a3a1a")
    c:px(hx - 1, top - 1, "#7a5a2a"); c:px(hx + 1, top + 1, "#7a5a2a")
  end
  sunflower(8, 44, 22, -3); sunflower(18, 46, 28, -2); sunflower(56, 46, 26, 3); sunflower(66, 44, 22, 3)
  -- the one that faces the moon (upright, turned)
  sunflower(43, 46, 20, 3, true)
  -- gnome with a hand cupped to the ear, leaning towards a bowed flower
  local _, G = gnome(c, 30, 49, { s = 1.25, d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -6, 12 }, false) } })
  for i = 0, 2 do note(c, 36 + i * 3, 30 - i * 2, "#f4eec8") end
  finish(c, "r_ee_sunflower_whispers")
end

-- 15. stove_ledge: asleep on the quilted ledge of the big whitewashed stove while frost glazes the window
function S.r_ee_stove_ledge()
  seed = 315
  local c = new()
  c:fill(R(c, 0, 0, W - 1, H - 1), "#9a6a42")
  for x = 5, 68, 7 do fl(c, R(c, x, 5, x, 49), "#8a5a35") end
  fl(c, R(c, 5, 44, 68, 49), "#6b4a2e")
  -- frosty window
  part(c, R(c, 8, 9, 24, 27), "#6b4a2e"); c:fill(R(c, 10, 11, 22, 25), "#bcd4e4"); fl(c, R(c, 16, 11, 16, 25), "#6b4a2e"); fl(c, R(c, 10, 18, 22, 18), "#6b4a2e")
  for _, p in ipairs({ { 11, 12 }, { 14, 14 }, { 12, 22 }, { 19, 12 }, { 21, 21 }, { 18, 23 } }) do c:px(p[1], p[2], "#f4f8fa"); c:px(p[1] + 1, p[2] + 1, "#f4f8fa") end
  -- the big whitewashed stove
  part(c, R(c, 30, 8, 66, 48), "#f0e8d8", { noline = false }); fl(c, R(c, 31, 9, 31, 47), "#fcfcfa")
  for y = 14, 44, 10 do fl(c, R(c, 32, y, 65, y), "#d8cfba") end
  part(c, R(c, 60, 2, 66, 9), "#d8cfba", { noline = true })
  -- ledge: a quilted bench with a rolled blanket
  part(c, R(c, 26, 28, 56, 34), "#b87038")
  -- firebox mouth
  part(c, R(c, 52, 38, 62, 47), "#3d2a1c"); c:fill(c:ellipse(57, 45, 3, 2), "#e8731a"); c:fill(c:ellipse(57, 45, 1, 1), "#ffd86a")
  -- quilt on the ledge and the sleeping gnome
  part(c, R(c, 28, 22, 54, 28), "#8a3a5a")
  for x = 29, 53, 4 do fl(c, R(c, x, 23, x + 1, 27), (x % 8 == 1) and "#e8a317" or "#4a9ab0") end
  gnome(c, 42, 24, { s = 1.0, d = 1, upper = true, eyes = "shut", arms = {} })
  part(c, R(c, 36, 20, 52, 26), "#8a3a5a"); for x = 37, 51, 4 do fl(c, R(c, x, 21, x + 1, 25), (x % 8 == 1) and "#e8a317" or "#4a9ab0") end
  -- Zzz
  c:paint({ "zzz", "..z", ".z.", "zzz" }, 52, 8, { z = "#2a1a10" })
  c:paint({ "zz", ".z", "zz" }, 60, 3, { z = "#2a1a10" })
  finish(c, "r_ee_stove_ledge")
end

---------------------------------------------------------------- MENA scenes
local function palm(c, x, yb, h, lean)
  lean = lean or 0
  for i = 0, h - 1 do fl(c, R(c, x + rnd(lean * i / h), yb - i, x + rnd(lean * i / h), yb - i), "#6b4a2e") end
  local tx, ty = x + lean, yb - h
  for _, f in ipairs({ { -5, 1 }, { -3, -1 }, { 3, -1 }, { 5, 1 }, { 0, -2 } }) do
    fl(c, c:line({ { tx, ty }, { tx + f[1], ty + f[2] } }, 1), "#3f8a42"); c:px(tx + f[1], ty + f[2] + 1, "#3f8a42")
  end
  c:px(tx, ty + 1, "#8a5a35")
end
local function dune(c, cx, cy, rx, ry, col, hi)
  c:fill(c:ellipse(cx, cy, rx, ry), col)
  if hi then c:fill(c:ellipse(cx, cy, rx, ry):clip(R(c, 0, 0, W, cy)):clip(R(c, 0, 0, cx, H)):shrink(1), hi) end
end

-- 16. sand_wind_shutters: a wall of sand rolls in; haul the stall shutter down over the open spice bowls
function S.r_mena_sand_wind_shutters()
  seed = 401
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#e8b070", "#e8b878", "#ecc088", "#f0c890" }, { dir = "v" })
  -- the sand wall
  c:fill(c:ellipse(8, 26, 24, 26), "#a07440"); c:fill(c:ellipse(16, 22, 17, 17), "#b8844a"); c:fill(c:ellipse(8, 14, 13, 12), "#8a6234")
  c:fill(c:ellipse(30, 33, 12, 8), "#b8844a"); c:fill(c:ellipse(24, 26, 8, 8), "#c8945a")
  for _, p in ipairs({ { 8, 14 }, { 14, 22 }, { 24, 18 }, { 6, 28 } }) do fl(c, R(c, p[1], p[2], p[1] + 5, p[2]), "#d8a870") end
  c:fill(R(c, 5, 38, 68, 49), "#d8b070"); fl(c, R(c, 5, 38, 68, 38), "#e8c488")
  -- stall: back wall, counter, bowls
  part(c, R(c, 28, 14, 66, 44), "#f0dcb0", { noline = false })
  c:fill(R(c, 31, 22, 63, 38), "#4a2c1a")
  part(c, R(c, 28, 38, 66, 44), "#a8703e"); fl(c, R(c, 28, 38, 66, 38), "#c08a52")
  for i, col in ipairs({ "#c0243a", "#e8a317", "#4f9a45", "#e0501f", "#8a5a35" }) do
    local x = 32 + (i - 1) * 7
    part(c, R(c, x - 2, 36, x + 2, 38), "#d8c8a0", { noline = true }); c:fill(c:ellipse(x, 35, 2, 1), col); fl(c, R(c, x - 1, 34, x + 1, 34), col)
  end
  -- awning, flapping
  part(c, R(c, 26, 9, 68, 14), "#c0442e")
  for x = 28, 66, 6 do fl(c, R(c, x, 9, x + 2, 14), "#f4eee0") end
  fl(c, R(c, 26, 14, 68, 15), "#8a2e1e")
  -- shutter half-down
  part(c, R(c, 30, 15, 64, 27), "#8a5a35")
  for x = 33, 62, 5 do fl(c, R(c, x, 16, x, 26), "#6b4426") end
  fl(c, R(c, 30, 26, 64, 26), "#b07a45")
  -- rope to the gnome
  fl(c, R(c, 30, 27, 30, 30), "#d8c8a0"); fl(c, c:line({ { 30, 28 }, { 24, 36 } }, 1), "#d8c8a0")
  gnome(c, 18, 47, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { 6, 17 }, false), arm({ 4, 8 }, { 7, 15 }, true) } })
  -- sand streaks on the wind
  for _, p in ipairs({ { 8, 9, 7 }, { 20, 12, 5 }, { 40, 6, 6 }, { 52, 44, 7 }, { 12, 42, 6 }, { 60, 31, 5 }, { 36, 46, 5 } }) do fl(c, R(c, p[1], p[2], p[1] + p[3], p[2]), "#c8945a") end
  finish(c, "r_mena_sand_wind_shutters")
end

-- 17. goats_in_almonds: three goats perch in the blossoming almond tree while the gnome rattles a bowl of oats
function S.r_mena_goats_in_almonds()
  seed = 402
  local c = new()
  day(c, 38, { sky = { "#a8d8e8", "#bce0ec", "#d0ecee" }, cloud = 56, hill = "#8aa860", hill2 = "#7a9a58", grass = "#9ab868" })
  -- almond tree
  part(c, R(c, 36, 24, 41, 44), "#6b4a2e", { noline = true })
  fl(c, c:line({ { 38, 30 }, { 22, 22 } }, 2), "#6b4a2e"); fl(c, c:line({ { 40, 28 }, { 56, 20 } }, 2), "#6b4a2e")
  for _, b in ipairs({ { 38, 12, 20, 9 }, { 20, 18, 11, 7 }, { 58, 16, 11, 7 }, { 46, 7, 10, 5 }, { 28, 8, 9, 5 } }) do leafy(c, b[1], b[2], b[3], b[4], "#eca8c0", "#f4c4d4") end
  for _, p in ipairs({ { 24, 14 }, { 36, 10 }, { 50, 12 }, { 60, 18 }, { 30, 18 }, { 44, 17 } }) do c:px(p[1], p[2], "#e8a0b8"); c:px(p[1] + 1, p[2] + 1, "#e8a0b8") end
  -- goats on branches
  goat(c, 22, 22, 1, "#7a5230"); goat(c, 56, 21, -1, "#3a3a44"); goat(c, 39, 26, 1, "#c8a878")
  -- petals falling
  for _, p in ipairs({ { 18, 34 }, { 30, 38 }, { 52, 36 }, { 62, 42 }, { 10, 40 } }) do c:px(p[1], p[2], "#f4c0d0"); c:px(p[1] + 1, p[2], "#f4c0d0") end
  -- gnome shaking a bowl of oats overhead
  local _, G = gnome(c, 20, 48, { s = 1.2, d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 17 }, true) } })
  local bx, by = G.P(9, 19)
  part(c, R(c, bx - 3, by - 1, bx + 3, by + 1), "#a8703e", { noline = true }); fl(c, R(c, bx - 3, by - 2, bx + 3, by - 2), "#e8c868")
  for _, p in ipairs({ { -4, -4 }, { 0, -5 }, { 4, -4 } }) do c:px(bx + p[1], by + p[2], "#e8c868") end
  finish(c, "r_mena_goats_in_almonds")
end

-- 18. follow_oasis (dawn): a pool with two palms tiptoes over the far dune; the gnome shades his eyes
function S.r_mena_follow_oasis()
  seed = 403
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#6a5a8a", "#a8689a", "#e08a8a", "#f4a878", "#f8c890" }, { dir = "v" })
  c:fill(c:ellipse(38, 32, 8, 8), "#f8e0a0"); c:fill(c:ellipse(38, 32, 6, 6), "#fff0c0")
  -- dunes, far to near
  c:fill(c:ellipse(60, 38, 30, 9), "#d8886a"); c:fill(c:ellipse(14, 40, 30, 10), "#c87a62")
  -- oasis on the far dune: palms and a pool with tiny legs
  palm(c, 54, 32, 10, 1); palm(c, 63, 32, 7, -1)
  c:fill(c:ellipse(58, 34, 8, 3), "#58b4c4"); fl(c, R(c, 52, 34, 55, 34), "#a8e6e6"); fl(c, R(c, 60, 35, 63, 35), "#a8e6e6")
  fl(c, R(c, 53, 37, 53, 38), "#6b4a2e"); fl(c, R(c, 57, 37, 58, 38), "#6b4a2e"); fl(c, R(c, 62, 37, 62, 38), "#6b4a2e")
  c:fill(R(c, 5, 44, 68, 49), "#c88a62")
  c:fill(c:ellipse(36, 50, 46, 11), "#e0a070"); c:fill(c:ellipse(36, 50, 40, 8), "#e8b484")
  -- puddle footprints trailing over the near dune
  for _, p in ipairs({ { 48, 40 }, { 43, 41 }, { 38, 42 }, { 33, 43 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#58b4c4"); fl(c, R(c, p[1] + 1, p[2] - 1, p[1] + 1, p[2] - 1), "#58b4c4") end
  gnome(c, 22, 49, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 7, 13 }, true) } })
  fl(c, R(c, 29, 36, 31, 36), "#f0c8a0")
  finish(c, "r_mena_follow_oasis")
end

-- 19. fog_nets: sea fog drips from fine nets into barrels; the gnome wrings one out
function S.r_mena_fog_nets()
  seed = 404
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#c8d4d8", "#d4dee0", "#dce4e4", "#e4eaea" }, { dir = "v" })
  -- harbour in the fog
  c:fill(R(c, 5, 26, 68, 38), "#a8bcc4")
  for _, h in ipairs({ { 8, 22, 8 }, { 18, 24, 6 }, { 28, 21, 9 } }) do c:fill(R(c, h[1], h[2], h[1] + h[3], 30), "#e0e8e8"); c:fill(R(c, h[1] + 2, h[2] + 3, h[1] + 3, h[2] + 4), "#a8bcc4") end
  fl(c, R(c, 5, 31, 68, 31), "#b8cad0"); fl(c, R(c, 5, 35, 68, 35), "#b0c4cc")
  -- fog bands
  for _, b in ipairs({ { 8, 14, 22 }, { 40, 10, 18 }, { 24, 28, 26 }, { 46, 33, 18 }, { 10, 36, 14 } }) do c:fill(c:ellipse(b[1] + b[3] // 2, b[2], b[3] // 2, 1), "#f0f4f4") end
  -- cliff top
  part(c, R(c, 5, 38, 68, 49), "#8a7a62"); fl(c, R(c, 5, 38, 68, 38), "#a8987a")
  for x = 8, 64, 9 do fl(c, R(c, x, 42 + (x % 3), x + 3, 42 + (x % 3)), "#6b5a48") end
  -- net frames
  local function netframe(x0, y0, x1, y1)
    part(c, R(c, x0 - 1, y0, x0, y1 + 3), "#6b4a2e", { noline = true }); part(c, R(c, x1, y0, x1 + 1, y1 + 3), "#6b4a2e", { noline = true })
    part(c, R(c, x0, y0, x1, y0 + 1), "#6b4a2e", { noline = true })
    c:fill(R(c, x0 + 1, y0 + 2, x1 - 1, y1), "#e8eeee")
    for xx = x0 + 2, x1 - 2, 3 do fl(c, R(c, xx, y0 + 2, xx, y1), "#a8bcc4") end
    for yy = y0 + 3, y1, 3 do fl(c, R(c, x0 + 1, yy, x1 - 1, yy), "#a8bcc4") end
    for xx = x0 + 3, x1 - 3, 5 do fl(c, R(c, xx, y1 + 1, xx, y1 + 2), "#58a8d0") end
  end
  netframe(34, 8, 52, 30); netframe(56, 12, 66, 32)
  -- barrels
  part(c, R(c, 38, 34, 48, 44), "#a8703e"); fl(c, R(c, 38, 37, 48, 37), "#4a3a30"); fl(c, R(c, 38, 41, 48, 41), "#4a3a30"); c:fill(R(c, 39, 34, 47, 35), "#58a8d0")
  part(c, R(c, 56, 36, 66, 46), "#a8703e"); fl(c, R(c, 56, 39, 66, 39), "#4a3a30"); fl(c, R(c, 56, 43, 66, 43), "#4a3a30"); c:fill(R(c, 57, 36, 65, 37), "#58a8d0")
  -- the gnome wringing a net corner
  gnome(c, 20, 48, { s = 1.15, d = 1, eyes = "shut", arms = { arm({ -4, 8 }, { 5, 11 }, false), arm({ 4, 8 }, { 8, 13 }, true) } })
  part(c, R(c, 25, 15, 30, 30), "#e8eeee", { noline = true })
  for yy = 17, 29, 3 do fl(c, R(c, 25, yy, 30, yy), "#a8bcc4") end
  for _, p in ipairs({ { 27, 32 }, { 28, 36 }, { 24, 34 } }) do fl(c, R(c, p[1], p[2], p[1], p[2] + 1), "#58a8d0") end
  finish(c, "r_mena_fog_nets")
end

-- 20. saffron_dawn: a thread of red saffron held up against the rising sun, crocus rows below
function S.r_mena_saffron_dawn()
  seed = 405
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#8a78a8", "#c888a8", "#f09a88", "#f8b878", "#fad090" }, { dir = "v" })
  c:fill(c:ellipse(20, 30, 9, 9), "#fbe8a8"); c:fill(c:ellipse(20, 30, 7, 7), "#fff4d0")
  c:fill(c:ellipse(18, 31, 30, 6), "#8a78a8"); c:fill(c:ellipse(58, 32, 30, 6), "#7a6898")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#6a7a3a")
  -- crocus rows in perspective
  for r = 0, 5 do
    local y = 34 + r * 3
    for x = 5 + (r % 2) * 3, 68, 6 do
      local big = r > 2
      fl(c, R(c, x, y, x + 1, y + 1), "#7a4a9a"); c:px(x, y - 1, "#a878c8"); if big then c:px(x + 1, y - 1, "#a878c8"); c:px(x, y + 2, "#4f8a36"); c:px(x + 1, y + 2, "#4f8a36") end
    end
  end
  fl(c, R(c, 5, 31, 68, 31), "#8a9a4a")
  local _, G = gnome(c, 44, 49, { s = 1.2, d = -1, eyes = "happy", arms = { arm({ -4, 9 }, { -8, 16 }, true), arm({ 4, 8 }, { 7, 5 }, false) } })
  local tx, ty = G.P(-8, 18)
  fl(c, R(c, tx - 1, ty - 4, tx - 1, ty), "#d8202a"); fl(c, R(c, tx, ty - 5, tx, ty - 2), "#d8202a"); fl(c, R(c, tx + 1, ty - 4, tx + 1, ty), "#d8202a")
  sparkle(c, tx - 5, ty - 6, "#fff4d0")
  -- tiny basket
  local bx, by = G.P(7, 5)
  part(c, R(c, bx - 2, by, bx + 3, by + 3), "#a8703e"); fl(c, R(c, bx - 2, by - 1, bx + 3, by - 1), "#7a4a9a"); fl(c, R(c, bx - 2, by, bx - 2, by), "#d8202a")
  finish(c, "r_mena_saffron_dawn")
end

-- 21. dune_stars (night): the gnome points up the guiding star; a sledge train and a far camp wait on the dunes
function S.r_mena_dune_stars()
  seed = 406
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 38), { "#0a1230", "#101a44", "#182456", "#26346a", "#3a4a80" }, { dir = "v" })
  for i = 1, 34 do c:px(5 + floor(rand() * 63), 5 + floor(rand() * 30), (i % 5 == 0) and "#f4eee0" or "#8a9cc0") end
  -- bright guiding stars
  sparkle(c, 50, 11, "#fff4c8"); c:px(50, 8, "#fff4c8"); c:px(50, 14, "#fff4c8")
  sparkle(c, 62, 22, "#f4eee0"); sparkle(c, 14, 14, "#f4eee0"); sparkle(c, 30, 8, "#f4eee0")
  -- dunes
  c:fill(c:ellipse(16, 44, 34, 12), "#2a3a6a"); c:fill(c:ellipse(60, 46, 34, 11), "#202e58")
  c:fill(c:ellipse(40, 54, 50, 12), "#34467a")
  fl(c, R(c, 10, 34, 24, 34), "#46588e")
  -- far camp lanterns
  for _, p in ipairs({ { 8, 39 }, { 12, 38 }, { 16, 39 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#ffd86a") end
  -- sand-sledge train
  for i = 0, 2 do
    local x = 46 + i * 7
    part(c, R(c, x, 41, x + 5, 43), "#5a4a3a"); fl(c, R(c, x - 1, 44, x + 6, 44), "#8a7a5a")
    fl(c, R(c, x + 2, 36, x + 2, 40), "#4a3a30"); fl(c, R(c, x + 1, 35, x + 3, 36), "#ffd86a")
  end
  fl(c, R(c, 51, 44, 53, 44), "#8a7a5a")
  -- gnome, pointing, compass in hand
  local _, G = gnome(c, 26, 49, { s = 1.15, d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 10, 18 }, true), arm({ -4, 8 }, { -6, 11 }, false) } })
  local cx, cy = G.P(-8, 11)
  part(c, c:ellipse(cx, cy, 3, 3), "#d8a030"); c:fill(c:ellipse(cx, cy, 2, 2), "#f4eee0"); c:px(cx, cy - 1, "#c0442e"); c:px(cx, cy + 1, "#2a1a10")
  finish(c, "r_mena_dune_stars")
end

-- 22. cistern_hum: columns of the old cistern ring back the gnome's hum
function S.r_mena_cistern_hum()
  seed = 407
  local c = new()
  c:fill(R(c, 0, 0, W - 1, H - 1), "#2a3a44")
  -- vaulted back wall: arches between columns
  c:fill(R(c, 5, 5, 68, 36), "#3a4c58")
  for x = 6, 68, 12 do
    local m = c:rect(x + 2, 18, x + 9, 36); m:add(c:ellipse(x + 5, 18, 4, 5)); c:fill(m, "#1c2a34")
  end
  for y = 8, 34, 5 do for x = 5 + (y % 3) * 4, 68, 9 do fl(c, R(c, x, y, x + 3, y), "#44586a") end end
  -- columns
  for _, x in ipairs({ 12, 30, 48, 64 }) do
    part(c, R(c, x - 2, 8, x + 2, 38), "#b8a88a"); fl(c, R(c, x - 3, 8, x + 3, 9), "#d8c8a8"); fl(c, R(c, x - 3, 36, x + 3, 37), "#d8c8a8"); fl(c, R(c, x - 1, 10, x - 1, 35), "#d8c8a8")
  end
  -- light shaft from above
  c:fill(c:poly({ { 34, 5 }, { 44, 5 }, { 52, 40 }, { 30, 40 } }), "#58707a")
  c:fill(c:poly({ { 37, 5 }, { 41, 5 }, { 46, 40 }, { 35, 40 } }), "#7a949a")
  -- water floor with ripples
  c:fill(R(c, 5, 38, 68, 49), "#2f7a98"); fl(c, R(c, 5, 38, 68, 38), "#5aa8c0")
  c:fill(c:ellipse(38, 44, 18, 4), "#4a96b0")
  for _, r in ipairs({ { 38, 44, 14, 3 }, { 38, 44, 9, 2 } }) do
    for x = r[1] - r[3], r[1] + r[3] do local t = (x - r[1]) / r[3]; local y = r[2] + rnd(r[4] * math.sqrt(math.max(0, 1 - t * t))); c:px(x, y, "#a8e0e8"); c:px(x, 2 * r[2] - y, "#a8e0e8") end
  end
  -- steps and the gnome humming
  part(c, R(c, 5, 40, 26, 49), "#a8987a"); fl(c, R(c, 5, 40, 26, 40), "#c8b896"); fl(c, R(c, 5, 44, 26, 44), "#8a7a62")
  gnome(c, 16, 40, { s = 1.0, d = 1, eyes = "shut", arms = { arm({ -4, 7 }, { -5, 4 }, false), arm({ 4, 7 }, { 6, 4 }, true) } })
  for i = 0, 3 do note(c, 24 + i * 5, 34 - (i % 2) * 4 - i, "#f4e8b0") end
  finish(c, "r_mena_cistern_hum")
end

-- 23. lateen_sail: the long yard swings round and the ferry skims; the skipper's cap goes flying
function S.r_mena_lateen_sail()
  seed = 408
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#78c0e0", "#90d0e8", "#a8dcee" }, { dir = "v" })
  c:fill(c:ellipse(52, 9, 8, 2), "#f4eee0"); c:fill(c:ellipse(14, 12, 6, 2), "#f4eee0")
  -- far white town
  c:fill(R(c, 5, 25, 68, 30), "#a8c0c8")
  for _, h in ipairs({ { 6, 5 }, { 13, 6 }, { 21, 4 }, { 54, 6 }, { 62, 5 } }) do c:fill(R(c, h[1], 30 - h[2], h[1] + 5, 30), "#f4eee0"); fl(c, R(c, h[1] + 2, 30 - h[2] + 2, h[1] + 3, 30 - h[2] + 3), "#3f8fb0") end
  c:fill(R(c, 5, 30, 68, 49), "#2f8ab0")
  for y = 33, 48, 3 do for x = 6 + (y % 5), 68, 9 do fl(c, R(c, x, y, x + 3, y), "#5ab4d4") end end
  -- hull
  part(c, c:poly({ { 12, 38 }, { 64, 38 }, { 58, 46 }, { 20, 46 } }), "#a8703e")
  fl(c, R(c, 14, 39, 62, 39), "#c08a52"); fl(c, R(c, 12, 41, 63, 41), "#c0442e")
  fl(c, R(c, 20, 47, 58, 47), "#78d0e0")
  -- mast and the big slanting sail
  fl(c, R(c, 34, 8, 34, 38), "#6b4a2e")
  fl(c, c:line({ { 17, 36 }, { 56, 7 } }, 1), "#6b4a2e")
  part(c, c:poly({ { 18, 36 }, { 56, 8 }, { 50, 36 } }), "#f4eee0")
  fl(c, c:line({ { 34, 22 }, { 49, 35 } }, 1), "#e0d4b8"); fl(c, c:line({ { 34, 16 }, { 36, 36 } }, 1), "#e0d4b8")
  -- skipper (blue cap) losing his cap, gnome hauling the sheet
  gnome(c, 24, 38, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -7, 3 }, false), arm({ 4, 7 }, { 8, 11 }, true) } })
  gnome(c, 56, 38, { d = -1, s = 0.85, hat = "#3f8fb0", eyes = "open", arms = {} })
  part(c, c:poly({ { 60, 20 }, { 63, 25 }, { 57, 25 } }), "#3f8fb0")
  fl(c, R(c, 56, 24, 56, 24), "#2a1a10")
  for _, p in ipairs({ { 6, 20, 5 }, { 8, 26, 6 }, { 56, 30, 5 } }) do fl(c, R(c, p[1], p[2], p[1] + p[3], p[2]), "#f4eee0") end
  finish(c, "r_mena_lateen_sail")
end

-- 24. cedar_hugs: a ring of gnomes arm in arm around the oldest cedar
function S.r_mena_cedar_hugs()
  seed = 409
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#a8c8e0", "#bcd4e4", "#cce0e8" }, { dir = "v" })
  c:fill(c:poly({ { 5, 30 }, { 20, 12 }, { 36, 30 } }), "#8a9ab0"); c:fill(c:poly({ { 40, 30 }, { 56, 14 }, { 68, 24 }, { 68, 30 } }), "#7a8aa0")
  c:fill(c:poly({ { 20, 12 }, { 24, 17 }, { 16, 17 } }), "#eef2f4"); c:fill(c:poly({ { 56, 14 }, { 60, 19 }, { 52, 19 } }), "#eef2f4")
  c:fill(R(c, 0, 30, W - 1, H - 1), "#6a8a4a"); fl(c, R(c, 0, 30, W - 1, 30), "#8aaa5a")
  -- giant trunk and tiered foliage
  part(c, R(c, 24, 14, 48, 44), "#7a5230", { noline = true })
  for y = 16, 42, 4 do fl(c, R(c, 26, y, 26, y + 2), "#5a3a22"); fl(c, R(c, 34, y + 1, 34, y + 3), "#5a3a22"); fl(c, R(c, 42, y, 42, y + 2), "#5a3a22"); fl(c, R(c, 30, y + 2, 30, y + 3), "#9a6a40") end
  for _, t in ipairs({ { 36, 10, 24, 4 }, { 24, 6, 14, 3 }, { 50, 8, 14, 3 } }) do
    part(c, c:ellipse(t[1], t[2], t[3] // 2, t[4]), "#2f6a3a", { shade = true }); c:fill(c:ellipse(t[1], t[2] - 1, t[3] // 2 - 3, t[4] - 2), "#3f8a4a")
  end
  -- the ring of hugging gnomes
  local hats = { "#4f9a45", "#e8a317", "#c0442e", "#3f8fb0", "#8a5ab0" }
  for i = 0, 4 do
    local x = 11 + i * 12.5
    local o = { d = (x < 36) and 1 or -1, upper = true, s = 1.0, hat = hats[i + 1], eyes = "happy", arms = {
      arm({ -4, 8 }, { -8, 8 }, i % 2 == 1), arm({ 4, 8 }, { 8, 8 }, i % 2 == 0) } }
    if i == 2 then o.hat = nil end
    gnome(c, rnd(x), 49, o)
  end
  -- bark-hug tally sparkles
  sparkle(c, 54, 24, "#f4eec8"); sparkle(c, 18, 26, "#f4eec8")
  finish(c, "r_mena_cedar_hugs")
end

local order = { }
for k in pairs(S) do order[#order + 1] = k end
table.sort(order)
for _, s2 in ipairs(order) do
  if not only or only == s2 then seed = 7; S[s2]() end
end
