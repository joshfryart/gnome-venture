-- variety-act-g8.lua : Do-tab scenes for 15 wave-1 rest-stop activities -> act-<slug>.png (144x108, 72x54 grid, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g8.lua   (params BEFORE --script)
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
  local ase, png = ASE .. "variety-act-w1_" .. slug .. ".aseprite", OUT .. "act-w1_" .. slug .. ".png"
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

local function stonelamp(c, x, yb, glow)
  part(c, R(c, x - 2, yb - 1, x + 2, yb), "#9a9ea6")
  part(c, R(c, x - 1, yb - 5, x + 1, yb - 2), "#a8aeb4")
  part(c, R(c, x - 2, yb - 9, x + 2, yb - 5), "#8b8f96")
  fl(c, R(c, x - 1, yb - 8, x + 1, yb - 6), glow or "#ffd86a")
  part(c, R(c, x - 4, yb - 11, x + 4, yb - 10), "#a8aeb4")
  part(c, R(c, x - 2, yb - 13, x + 2, yb - 12), "#9a9ea6")
end

local function paperlamp(c, x, y, col, rx, ry)
  fl(c, R(c, x, y - 3, x, y), "#3d2a1c")
  part(c, c:ellipse(x, y + ry, rx or 2, ry or 3), col)
  fl(c, R(c, x - 1, y + 1, x, y + 2), "#fff1c8")
end

-- 1. shrine_lanterns: stone steps up to a gate, many different lanterns; gnome holds up a brand-new one
function S.shrine_lanterns()
  seed = 61
  local c = new()
  day(c, 26, { cloud = 52, hill = "#5e8a44", hill2 = "#4e8a3c" })
  c:fill(R(c, 0, 26, W - 1, H - 1), "#6a9a52")
  pine(c, 8, 28, 15, false); pine(c, 64, 29, 16, false)
  -- steps: five tiers narrowing upward
  for i = 0, 4 do
    local y0 = 46 - i * 4
    part(c, R(c, 14 + i * 3, y0, 58 - i * 3, y0 + 3), (i % 2 == 0) and "#a8aeb4" or "#9a9ea6")
    fl(c, R(c, 15 + i * 3, y0, 57 - i * 3, y0), "#c9c5bc")
  end
  -- gate at the top: two red posts and two beams
  part(c, R(c, 28, 12, 30, 28), "#c0442e", { noline = true }); part(c, R(c, 42, 12, 44, 28), "#c0442e", { noline = true })
  part(c, R(c, 24, 9, 48, 11), "#8e2e1e"); part(c, R(c, 27, 14, 45, 15), "#c0442e")
  -- hanging lanterns of every kind under the beams
  paperlamp(c, 32, 16, "#e8a317", 2, 3)
  paperlamp(c, 36, 16, "#dd3a2a", 2, 4)
  paperlamp(c, 40, 16, "#3f8fb0", 2, 3)
  -- stone lanterns on the steps, jar lamp, shell lamp on the ground
  stonelamp(c, 20, 38); stonelamp(c, 52, 38)
  part(c, R(c, 25, 33, 28, 37), "#b8e0e8"); fl(c, R(c, 26, 35, 27, 36), "#ffd86a"); fl(c, R(c, 25, 32, 28, 32), "#8a5a35")
  part(c, R(c, 45, 33, 47, 37), "#f4eee0"); fl(c, R(c, 46, 34, 46, 36), "#ffd86a")
  part(c, c:ellipse(36, 30, 2, 1), "#e8c48a"); fl(c, R(c, 36, 29, 36, 29), "#ffd86a")
  -- gnome at the foot, holding up a new lantern
  gnome(c, 17, 48, { d = 1, eyes = "happy", arms = { arm({ -4, 6 }, { -6, 3 }, false), arm({ 4, 8 }, { 7, 15 }, true) } })
  paperlamp(c, 26, 25, "#f08a24", 3, 4)
  c:fill(R(c, 25, 26, 27, 27), "#fff1c8")
  local function spark(x, y) c:px(x, y, "#fff1c8"); c:px(x - 1, y, "#f5cf6a"); c:px(x + 1, y, "#f5cf6a"); c:px(x, y - 1, "#f5cf6a"); c:px(x, y + 1, "#f5cf6a") end
  spark(28, 22); spark(18, 20)
  finish(c, "shrine_lanterns")
end

-- 2. rake_gravel: dawn; raked ripples behind the gnome, a snail sitting in the clean part
function S.rake_gravel()
  seed = 62
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#5a4a82", "#7a5a8e", "#b45a7c", "#e8825e", "#f0a868", "#f8cf88" }, { dir = "v" })
  c:fill(c:ellipse(52, 30, 7, 7), "#ffe8a0")
  c:fill(c:ellipse(18, 31, 30, 7), "#4a4a78"); c:fill(c:ellipse(62, 32, 26, 6), "#3e3e6a")
  for _, p in ipairs({ { 10, 8 }, { 24, 7 }, { 36, 10 } }) do c:px(p[1], p[2], "#f4eee0") end
  -- stone wall + one pine behind the garden
  c:fill(R(c, 0, 31, W - 1, 35), "#6a6a88")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 33, x + 5, 33), "#585876"); fl(c, R(c, x + 3, 31, x + 3, 32), "#585876") end
  pine(c, 9, 35, 17, false)
  -- gravel
  c:fill(R(c, 0, 36, W - 1, H - 1), "#e8dcc4")
  -- raked ripples on the right: runs of wavy lines
  for k = 0, 5 do
    local y = 37 + k * 2 + 1
    for x = 38, 67 do c:px(x, y + ((floor(x / 4) % 2 == 0) and 0 or -1), (k % 2 == 0) and "#c8bea6" or "#f6efdc") end
  end
  -- stone island with ripples around it
  c:fill(c:ellipse(14, 43, 9, 4), "#e8dcc4")
  for x = 5, 23 do c:px(x, 39, "#c8bea6"); c:px(x, 47, "#c8bea6") end
  c:px(4, 43, "#c8bea6"); c:px(24, 43, "#c8bea6")
  part(c, c:ellipse(13, 42, 4, 3), "#8b8f96", { shade = true })
  part(c, c:ellipse(19, 44, 2, 1), "#9a9ea6")
  c:fill(R(c, 11, 39, 14, 39), "#6a9a52")
  -- gnome walking left, dragging the rake ahead of him
  local _, G = gnome(c, 42, 47, { d = -1, eyes = "open", walk = 1, arms = { arm({ -4, 7 }, { -7, 5 }, true) } })
  local hx, hy = G.P(-7, 5)
  c:fill(c:line({ { hx, hy }, { hx - 8, hy + 5 } }, 1), "#8a5a35")
  fl(c, R(c, hx - 14, hy + 5, hx - 6, hy + 6), "#8a5a35")
  for x = hx - 14, hx - 6, 2 do c:px(x, hy + 7, "#6b3b2a") end
  for x = hx - 13, hx - 6, 2 do c:px(x, hy + 5, "#a8703e") end
  -- the snail, already on the clean part, trailing across the ripples
  part(c, c:ellipse(58, 42, 2, 2), "#c88a52"); c:px(58, 42, "#8a4f2a")
  fl(c, R(c, 53, 43, 57, 43), "#b8c8a0"); c:px(53, 42, "#b8c8a0"); c:px(52, 41, "#b8c8a0")
  for x = 60, 67 do c:px(x, 44, "#b8965c") end
  finish(c, "rake_gravel")
end

-- 3. leaf_sweep: autumn; shrine steps buried in leaves, gnome with a twig broom, a big pile
function S.leaf_sweep()
  seed = 63
  local c = new()
  day(c, 31, { cloud = 40, sky = { "#c8d8d8", "#dce4d4", "#ecead0" }, hill = "#a08a3c", hill2 = "#8a7a34", grass = "#b8a050", edge = "#d0b860" })
  -- maple, letting go
  part(c, R(c, 6, 18, 9, 36), "#6b4a2e", { noline = true })
  part(c, c:ellipse(8, 14, 10, 8), "#d8661c", { shade = true })
  c:fill(c:ellipse(5, 12, 4, 3), "#e8a317"); c:fill(c:ellipse(12, 16, 3, 2), "#c0442e")
  -- shrine steps, two tiers
  part(c, R(c, 26, 28, 56, 32), "#a8aeb4"); part(c, R(c, 22, 33, 60, 37), "#9a9ea6")
  fl(c, R(c, 27, 28, 55, 28), "#c9c5bc"); fl(c, R(c, 23, 33, 59, 33), "#c9c5bc")
  fl(c, R(c, 27, 31, 55, 31), "#7a8088"); fl(c, R(c, 23, 36, 59, 36), "#7a8088")
  stonelamp(c, 62, 37)
  -- leaves lying over the steps
  local lc = { "#d8661c", "#e8a317", "#c0442e", "#b8661a" }
  for i = 1, 26 do
    local x, y = 24 + floor(rand() * 36), 29 + floor(rand() * 9)
    fl(c, R(c, x, y, x + 1, y), lc[i % 4 + 1])
  end
  -- the pile
  part(c, c:ellipse(52, 46, 12, 5), "#d8661c", { shade = true })
  for i = 1, 22 do
    local x, y = 43 + floor(rand() * 20), 42 + floor(rand() * 8)
    if ((x - 52) / 12) ^ 2 + ((y - 46) / 5) ^ 2 < 0.85 then fl(c, R(c, x, y, x + 1, y), lc[i % 4 + 1]) end
  end
  -- gnome sweeping with a twig broom
  local _, G = gnome(c, 26, 47, { d = 1, eyes = "open", walk = 1, arms = { arm({ 4, 7 }, { 9, 6 }, true) } })
  local hx, hy = G.P(9, 6)
  c:fill(c:line({ { hx, hy - 3 }, { hx + 6, hy + 4 } }, 1), "#8a5a35")
  fl(c, c:poly({ { hx + 5, hy + 3 }, { hx + 10, hy + 3 }, { hx + 13, hy + 8 }, { hx + 5, hy + 8 } }), "#b07a45")
  for x = hx + 5, hx + 12, 2 do fl(c, R(c, x, hy + 6, x, hy + 7), "#8a5a35") end
  -- leaves flying off the broom and falling
  for _, p in ipairs({ { 40, 41 }, { 43, 38 }, { 38, 43 }, { 20, 22 }, { 30, 18 }, { 44, 14 }, { 56, 20 }, { 64, 26 }, { 14, 28 } }) do
    fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), lc[(p[1] % 4) + 1]); c:px(p[1] + 1, p[2] + 1, lc[(p[2] % 4) + 1])
  end
  finish(c, "leaf_sweep")
end

-- 4. pilgrim_tales: sat on a stone bench, a dusty pilgrim with a pack tells of the road
function S.pilgrim_tales()
  seed = 64
  local c = new()
  day(c, 30, { cloud = 46, hill = "#6a9a52", hill2 = "#5e8a44" })
  -- a long winding road to the horizon
  c:fill(c:poly({ { 40, 30 }, { 44, 30 }, { 62, 49 }, { 30, 49 } }), "#d9bc84")
  c:fill(c:poly({ { 41, 32 }, { 43, 32 }, { 50, 44 }, { 42, 44 } }), "#e8d2a0")
  c:fill(R(c, 8, 38, 9, 38), "#d9bc84")
  -- shrine bell on a frame
  part(c, R(c, 55, 17, 56, 36), "#8a5a35", { noline = true }); part(c, R(c, 66, 17, 67, 36), "#8a5a35", { noline = true })
  part(c, R(c, 53, 14, 69, 16), "#a8703e")
  part(c, c:poly({ { 60, 21 }, { 64, 21 }, { 66, 27 }, { 58, 27 } }), "#e8a317")
  fl(c, R(c, 61, 17, 61, 20), "#6b3b2a"); fl(c, R(c, 61, 28, 61, 29), "#6b3b2a")
  -- stone bench
  part(c, R(c, 6, 41, 40, 44), "#a8aeb4"); fl(c, R(c, 7, 41, 39, 41), "#c9c5bc")
  part(c, R(c, 9, 45, 12, 48), "#8b8f96"); part(c, R(c, 34, 45, 37, 48), "#8b8f96")
  -- pilgrim (left): green hat, pack, telling with a raised hand
  fl(c, R(c, 4, 33, 8, 41), "#8a5a35"); fl(c, R(c, 4, 33, 8, 34), "#a8703e")
  part(c, R(c, 5, 31, 8, 33), "#c8802a")
  gnome(c, 12, 41, { d = 1, sit = true, hat = "#4f9a45", eyes = "open", arms = { arm({ 3, 8 }, { 7, 14 }, true) } })
  -- walking staff against the bench
  c:fill(c:line({ { 3, 28 }, { 2, 47 } }, 1), "#8a5a35")
  -- dust at the boots
  for _, p in ipairs({ { 22, 46 }, { 24, 47 }, { 20, 47 }, { 26, 45 } }) do c:px(p[1], p[2], "#e8d2a0") end
  -- me, listening: hat tipped, eyes shut with a smile
  gnome(c, 35, 41, { d = -1, sit = true, eyes = "open", arms = { arm({ 4, 5 }, { 6, 3 }, true, true) } })
  -- little story marks above the pilgrim
  c:px(24, 20, "#f5cf6a"); c:px(27, 17, "#f5cf6a"); c:px(21, 17, "#f5cf6a")
  finish(c, "pilgrim_tales")
end

-- 5. meadowsweet_tea: at a plank table, pouring from a teapot into a cup; frothy cream meadowsweet behind
function S.meadowsweet_tea()
  seed = 65
  local c = new()
  day(c, 30, { cloud = 14, hill = "#5e8a44", hill2 = "#4e8a3c" })
  -- frothy meadowsweet
  local function ms(x, h)
    fl(c, R(c, x, 30 - h, x, 36), "#4e8a3c")
    fl(c, R(c, x - 1, 32 - h / 2, x - 1, 33 - h / 2 + 1), "#5e9a48")
    for _, o in ipairs({ { 0, 0 }, { -2, 1 }, { 2, 1 }, { -1, -1 }, { 1, -1 }, { 0, 2 }, { -3, 2 }, { 3, 2 } }) do
      c:fill(c:ellipse(x + o[1], 30 - h + o[2], 1, 1), "#f4eee0")
    end
    c:px(x, 30 - h - 1, "#fffaf0"); c:px(x - 2, 30 - h + 1, "#e8d2a0"); c:px(x + 2, 30 - h + 2, "#e8d2a0")
  end
  ms(9, 12); ms(16, 17); ms(61, 14); ms(67, 10); ms(54, 18)
  fl(c, R(c, 0, 36, W - 1, 37), "#7ea85a")
  -- picket fence far left
  -- table
  part(c, R(c, 8, 38, 66, 41), "#b07a45"); fl(c, R(c, 9, 38, 65, 38), "#d9a660")
  part(c, R(c, 11, 42, 14, 49), "#8a5a35", { noline = true }); part(c, R(c, 60, 42, 63, 49), "#8a5a35", { noline = true })
  -- gnome behind the table, upper body, pouring (left hand bracing the lid)
  local _, G = gnome(c, 22, 43, { d = 1, upper = true, s = 1.25, eyes = "open", arms = { arm({ 4, 6 }, { 9, 10 }, true) } })
  local px, py = G.P(10, 10)
  -- teapot tipped, spout to the right
  part(c, c:ellipse(px + 3, py - 1, 4, 3), "#e8ecf0", { shade = true })
  fl(c, R(c, px + 1, py - 3, px + 4, py - 3), "#aeb4bc"); fl(c, R(c, px + 2, py - 5, px + 3, py - 4), "#3f8fb0")
  part(c, c:line({ { px + 6, py - 1 }, { px + 10, py + 1 } }, 2), "#e8ecf0", { noline = true })
  fl(c, R(c, px - 2, py - 2, px - 1, py + 1), "#3f8fb0")
  fl(c, R(c, px - 1, py + 1, px + 1, py + 2), "#f0c8a0")
  -- stream, cup and saucer
  c:fill(R(c, px + 10, py + 2, px + 10, 37), "#b8661a")
  part(c, R(c, px + 7, 34, px + 13, 37), "#f4eee0"); fl(c, R(c, px + 8, 34, px + 12, 34), "#b8661a")
  fl(c, R(c, px + 14, 35, px + 15, 36), "#f4eee0")
  part(c, R(c, px + 5, 38, px + 15, 38), "#3f8fb0", { noline = true })
  -- steam
  for i = 0, 3 do fl(c, R(c, px + 8 + (i % 2) * 2, 30 - i * 3, px + 9 + (i % 2) * 2, 31 - i * 3), "#f4f8fa") end
  -- sugar bowl / jar of dried flowers on the table
  part(c, R(c, 46, 31, 52, 37), "#b8e0e8"); fl(c, R(c, 47, 32, 51, 32), "#f4eee0"); fl(c, R(c, 47, 29, 51, 31), "#f4eee0")
  fl(c, R(c, 48, 33, 50, 36), "#e8d2a0")
  c:px(57, 36, "#f4eee0"); c:px(58, 37, "#f4eee0")
  finish(c, "meadowsweet_tea")
end

-- 6. moth_count: dusk, a lit sheet crowded with moths; the forager notes them down
function S.moth_count()
  seed = 66
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#2a2a5a", "#3b2f66", "#5a3a78", "#8a4a82", "#c0587c" }, { dir = "v" })
  for _, p in ipairs({ { 8, 8 }, { 20, 6 }, { 30, 12 }, { 46, 8 }, { 62, 10 }, { 66, 22 }, { 14, 20 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(c:ellipse(16, 36, 30, 8), "#26284f"); c:fill(c:ellipse(60, 36, 26, 7), "#2c2a58")
  c:fill(R(c, 0, 35, W - 1, H - 1), "#2f4a3e")
  c:fill(R(c, 0, 35, W - 1, 35), "#3f6048")
  -- the sheet: two poles, a cloth, a lantern on top making it glow
  part(c, R(c, 34, 12, 35, 44), "#6b4a2e", { noline = true }); part(c, R(c, 62, 12, 63, 44), "#6b4a2e", { noline = true })
  c:fill(R(c, 33, 12, 64, 12), "#5e3f28")
  part(c, R(c, 36, 13, 61, 36), "#f4eee0")
  c:fill(c:ellipse(48, 22, 11, 8), "#fbf3d8")
  c:fill(R(c, 36, 36, 61, 36), "#d8cfb8")
  for x = 38, 59, 6 do c:px(x, 13, "#d8cfb8"); c:px(x, 14, "#d8cfb8") end
  part(c, R(c, 47, 5, 50, 11), "#ffd86a", { shade = true, cres = 1 }); fl(c, R(c, 48, 7, 49, 9), "#fff1c8")
  fl(c, R(c, 47, 4, 50, 4), "#3d2a1c"); fl(c, R(c, 48, 11, 49, 12), "#3d2a1c")
  local function moth(x, y, col, sz)
    c:px(x - 1, y - 1, col); c:px(x + 1, y - 1, col); c:px(x - 2, y, col); c:px(x + 2, y, col)
    c:px(x, y, "#5e3f28"); c:px(x, y + 1, "#5e3f28")
    if sz then c:px(x - 1, y, col); c:px(x + 1, y, col) end
  end
  moth(41, 17, "#a8aeb4"); moth(47, 24, "#c9a96e", true); moth(54, 18, "#e8a317"); moth(42, 28, "#b8c8a0"); moth(57, 29, "#a8aeb4", true)
  moth(51, 31, "#d9bc84")
  -- the one in a velvet cape
  moth(38, 23, "#e8d2a0"); fl(c, R(c, 38, 24, 39, 27), "#c0442e")
  moth(30, 20, "#f4eee0"); c:px(26, 22, "#f5e6a8"); c:px(28, 24, "#f5e6a8")
  moth(68, 16, "#f4eee0")
  -- night-scented flowers
  for _, x in ipairs({ 40, 46, 52, 58 }) do
    fl(c, R(c, x, 40, x, 46), "#4e8a3c")
    c:fill(c:ellipse(x, 39, 1, 1), "#f4eee0"); c:px(x, 39, "#f5e6a8")
  end
  -- the forager with notebook and pencil
  local _, G = gnome(c, 18, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 7, 11 }, true), arm({ -4, 6 }, { 2, 8 }, true, true) } })
  local bx, by = G.P(0, 9)
  part(c, R(c, bx - 4, by - 2, bx + 2, by + 3), "#e8d2a0"); fl(c, R(c, bx - 3, by, bx + 1, by), "#8a5a35"); fl(c, R(c, bx - 3, by + 2, bx + 1, by + 2), "#8a5a35")
  local hx, hy = G.P(7, 11)
  c:fill(c:line({ { hx, hy }, { hx + 3, hy - 4 } }, 1), "#e8a317")
  c:px(hx + 3, hy - 5, "#dd3a2a")
  finish(c, "moth_count")
end

-- 7. leaf_shapes: pressed leaves in a fat book, the gnome compares a fresh one against the page
function S.leaf_shapes()
  seed = 67
  local c = new()
  day(c, 30, { cloud = 50, hill = "#5e8a44", hill2 = "#4e8a3c", grass = "#7ea85a" })
  -- an apple tree behind
  part(c, R(c, 8, 14, 11, 33), "#6b4a2e", { noline = true })
  part(c, c:ellipse(10, 11, 11, 8), "#3f8a42", { shade = true })
  for _, p in ipairs({ { 5, 10 }, { 12, 8 }, { 14, 13 }, { 8, 14 } }) do c:px(p[1], p[2], "#dd3a2a"); c:px(p[1] + 1, p[2], "#dd3a2a") end
  -- table
  part(c, R(c, 4, 36, 68, 40), "#b07a45"); fl(c, R(c, 5, 36, 67, 36), "#d9a660")
  part(c, R(c, 8, 41, 11, 49), "#8a5a35", { noline = true }); part(c, R(c, 61, 41, 64, 49), "#8a5a35", { noline = true })
  -- the fat open book: two pages, thick cover edge
  part(c, R(c, 27, 22, 66, 36), "#6b3b2a")
  part(c, R(c, 29, 23, 46, 35), "#f4eee0"); part(c, R(c, 47, 23, 64, 35), "#f0e4c8")
  fl(c, R(c, 46, 23, 46, 35), "#c9b88a")
  fl(c, R(c, 29, 35, 64, 35), "#d8cfb8")
  local function leaf(x, y, kind, col)
    if kind == "heart" then c:paint({ ".g.g.", "ggggg", "ggggg", ".ggg.", "..g.." }, x, y, { g = col })
    elseif kind == "round" then c:paint({ ".ggg.", "ggggg", "ggggg", "ggggg", ".ggg." }, x, y, { g = col })
    elseif kind == "needle" then c:paint({ ".g.", ".g.", ".g.", ".g.", ".g.", ".g." }, x + 1, y, { g = col })
    elseif kind == "feather" then c:paint({ "..g..", ".ggg.", "ggggg", ".ggg.", "..g..", "..g.." }, x, y, { g = col })
    elseif kind == "arrow" then c:paint({ "..g..", ".ggg.", "ggggg", "..g..", "..g.." }, x, y, { g = col }) end
    c:px(x + 2, y + 2, "#f4eee0")
  end
  leaf(31, 25, "heart", "#4e8a3c"); leaf(38, 25, "round", "#6aa04a"); leaf(32, 31, "feather", "#3f7a38"); leaf(39, 31, "needle", "#5e9a48")
  leaf(50, 25, "arrow", "#7ab55c"); leaf(57, 25, "heart", "#4e8a3c"); leaf(50, 31, "round", "#3f7a38")
  c:fill(R(c, 57, 30, 62, 33), "#e8dcc0"); fl(c, R(c, 57, 30, 62, 30), "#d8cfb8"); fl(c, R(c, 57, 33, 62, 33), "#d8cfb8")
  -- gnome behind the table holding a fresh leaf against the page
  local _, G = gnome(c, 20, 40, { d = 1, upper = true, eyes = "open", arms = { arm({ 4, 6 }, { 8, 11 }, true) } })
  local hx, hy = G.P(8, 11)
  c:paint({ ".g.g.", "ggggg", "ggggg", ".ggg.", "..g.." }, hx - 1, hy - 7, { g = "#7ab55c" })
  fl(c, R(c, hx + 1, hy - 2, hx + 1, hy - 1), "#4e8a3c")
  part(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0", { noline = true })
  c:px(hx + 1, hy - 5, "#a8d890")
  finish(c, "leaf_shapes")
end

-- 8. sniff_jars: a rack of unlabelled jars; the gnome sniffs one hard, eyes shut
function S.sniff_jars()
  seed = 68
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#c9a96e")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 38), "#b8965c") end
  c:fill(R(c, 0, 39, W - 1, H - 1), "#8a5a35")
  for y = 43, 51, 4 do fl(c, R(c, 0, y, W - 1, y), "#6b3b2a") end
  -- drying beam with herb bundles
  part(c, R(c, 5, 6, 68, 8), "#6b3b2a")
  local hc = { "#8a5ab0", "#4e8a3c", "#c0a040", "#8a5ab0", "#4e8a3c", "#6a9a52" }
  for i, x in ipairs({ 10, 20, 30, 43, 53, 63 }) do
    fl(c, R(c, x, 9, x, 10), "#5e3f28")
    c:fill(c:poly({ { x - 2, 10 }, { x + 3, 10 }, { x + 1, 17 }, { x, 17 } }), hc[i])
    fl(c, R(c, x - 1, 12, x + 1, 12), "#5e3f28")
  end
  -- rack with three jars on it
  part(c, R(c, 44, 24, 66, 40), "#a8703e")
  fl(c, R(c, 45, 31, 65, 32), "#6b3b2a"); fl(c, R(c, 45, 24, 65, 25), "#d9a660")
  local function jar(x, y, col, lid)
    part(c, R(c, x, y, x + 5, y + 6), col)
    fl(c, R(c, x + 1, y - 2, x + 4, y - 1), lid or "#8a5a35")
    fl(c, R(c, x + 1, y + 1, x + 1, y + 4), "#fff8e0")
  end
  jar(46, 26, "#c0a0e0"); fl(c, R(c, 48, 22, 49, 24), "#8a5ab0"); c:px(48, 21, "#8a5ab0"); c:px(49, 22, "#8a5ab0")
  jar(55, 26, "#a8d890", "#6b3b2a"); jar(61, 26, "#e8c48a", "#6b3b2a")
  jar(47, 34, "#e8a317"); jar(57, 34, "#8fcbd8")
  -- the gnome, big, jar under the nose
  local _, G = gnome(c, 26, 48, { d = 1, s = 1.25, eyes = "shut", arms = { arm({ 3, 7 }, { 7, 13 }, true, true), arm({ -3, 7 }, { 5, 10 }, false, true) } })
  local jx, jy = G.P(8, 13)
  part(c, R(c, jx - 1, jy - 3, jx + 4, jy + 3), "#c0a0e0")
  fl(c, R(c, jx, jy - 5, jx + 3, jy - 4), "#8a5a35"); fl(c, R(c, jx, jy - 8, jx + 1, jy - 6), "#8a5ab0"); c:px(jx + 2, jy - 7, "#8a5ab0")
  fl(c, R(c, jx + 1, jy - 2, jx + 1, jy + 1), "#fff8e0")
  local hx, hy = G.P(8, 13)
  fl(c, R(c, hx - 2, hy - 1, hx, hy + 2), "#f0c8a0")
  -- scent curls
  for i = 0, 4 do fl(c, R(c, jx + 6 + (i % 2) * 2, jy - 10 - i * 2, jx + 7 + (i % 2) * 2, jy - 9 - i * 2), "#c0a0e0") end
  finish(c, "sniff_jars")
end

-- 9. fog_horn: fog, a jetty, a big brass horn; sound rings go out into the white
function S.fog_horn()
  seed = 69
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#a8b4b8", "#b8c4c8", "#c4ced0", "#d0d8d8", "#dce2e0" }, { dir = "v" })
  c:fill(R(c, 0, 34, W - 1, H - 1), "#9cb0b4")
  for y = 36, 50, 3 do for x = (y % 2) * 3, W - 1, 8 do c:fill(R(c, x, y, x + 3, y), "#b4c4c6") end end
  -- a ghost of a lighthouse far away, boat light, and the far shore
  c:fill(c:ellipse(60, 34, 14, 3), "#b0bcc0")
  c:fill(c:poly({ { 58, 14 }, { 62, 14 }, { 64, 33 }, { 56, 33 } }), "#b4c0c4")
  c:fill(R(c, 57, 11, 63, 13), "#bcc8cc"); c:fill(R(c, 59, 8, 61, 10), "#c8d2d4")
  c:px(14, 33, "#f5cf6a"); c:px(15, 33, "#f5cf6a")
  -- fog streaks over everything far
  c:fill(R(c, 0, 24, 40, 25), "#dce2e0"); c:fill(R(c, 36, 30, 70, 31), "#dce2e0"); c:fill(R(c, 4, 18, 30, 18), "#dce2e0")
  -- jetty
  part(c, R(c, 5, 38, 52, 42), "#8a5a35"); fl(c, R(c, 6, 38, 51, 38), "#a8703e")
  for x = 12, 48, 9 do fl(c, R(c, x, 39, x, 41), "#5e3f28") end
  for _, x in ipairs({ 9, 28, 46 }) do part(c, R(c, x, 43, x + 2, 49), "#5e3f28", { noline = true }) end
  part(c, R(c, 47, 30, 49, 38), "#6b4a2e", { noline = true }); fl(c, R(c, 46, 29, 50, 29), "#6b4a2e")
  -- gnome with the horn
  local _, G = gnome(c, 16, 38, { d = 1, s = 1, eyes = "open", arms = { arm({ 4, 7 }, { 7, 11 }, true, true), arm({ -3, 7 }, { 4, 9 }, true, true) } })
  local mx, my = G.P(5, 10)
  part(c, c:poly({ { mx, my }, { mx + 3, my - 1 }, { mx + 14, my - 6 }, { mx + 14, my + 7 }, { mx + 3, my + 2 } }), "#e8a317", { shade = true })
  fl(c, R(c, mx + 14, my - 5, mx + 15, my + 6), "#8a5a1a")
  fl(c, R(c, mx + 4, my, mx + 12, my), "#f5cf6a")
  fl(c, R(c, mx + 3, my - 2, mx + 6, my - 2), "#f5cf6a")
  -- sound arcs
  local ex, ey = mx + 14, my
  for k = 1, 3 do
    local r = 5 + k * 5
    local ring = c:ellipse(ex, ey, r, r + 2):cut(c:ellipse(ex, ey, r - 1, r + 1)):clip(R(c, ex + 2, 5, W - 1, 49))
    c:fill(ring, (k == 3) and "#8aa0a8" or "#6a8490")
  end
  finish(c, "fog_horn")
end

-- 10. flag_duel: top platform of the tower, two gnomes with flags, swoop against twirl
function S.flag_duel()
  seed = 70
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#7ab4d8", "#9cc8e0", "#bcdde4", "#d8eaea" }, { dir = "v" })
  c:fill(c:ellipse(12, 28, 20, 6), "#8aa8c0"); c:fill(c:ellipse(56, 30, 24, 7), "#7a9ab8")
  c:fill(c:ellipse(34, 12, 9, 2), "#f4eee0"); c:fill(c:ellipse(40, 10, 5, 2), "#f4eee0"); c:fill(c:ellipse(60, 20, 6, 2), "#f4eee0")
  -- parapet
  part(c, R(c, 5, 33, 68, 38), "#a8aeb4")
  for x = 6, 64, 8 do part(c, R(c, x, 29, x + 4, 32), "#a8aeb4") end
  fl(c, R(c, 5, 35, 68, 35), "#8b8f96")
  -- planks
  c:fill(R(c, 5, 39, 68, 49), "#b07a45")
  for y = 42, 48, 3 do fl(c, R(c, 5, y, 68, y), "#8a5a35") end
  fl(c, R(c, 5, 39, 68, 39), "#d9a660")
  -- left gnome: swoop, flag low and long
  local _, G = gnome(c, 18, 48, { d = 1, eyes = "open", arms = { arm({ 4, 6 }, { 9, 4 }, true), arm({ -4, 6 }, { -6, 2 }, false) } })
  local hx, hy = G.P(9, 4)
  c:fill(c:line({ { hx, hy }, { hx + 3, hy + 3 } }, 1), "#8a5a35")
  c:fill(c:line({ { hx, hy }, { hx - 1, hy - 8 } }, 1), "#8a5a35")
  part(c, c:poly({ { hx - 1, hy - 8 }, { hx + 11, hy - 6 }, { hx - 1, hy - 2 } }), "#dd3a2a")
  -- right gnome: twirl, flag up in the air spinning
  local _, G2 = gnome(c, 54, 48, { d = -1, hat = "#3f8a52", eyes = "open", arms = { arm({ -4, 6 }, { -8, 15 }, true), arm({ 4, 6 }, { 6, 2 }, false) } })
  local tx, ty = G2.P(-8, 15)
  c:fill(c:line({ { tx, ty }, { tx - 4, ty - 7 } }, 1), "#8a5a35")
  part(c, c:poly({ { tx - 4, ty - 7 }, { tx - 11, ty - 11 }, { tx - 5, ty - 14 }, { tx + 1, ty - 12 } }), "#f5cf6a")
  fl(c, R(c, tx - 7, ty - 11, tx - 5, ty - 11), "#dd3a2a")
  -- twirl motion marks
  c:px(tx + 4, ty - 5, "#f4eee0"); c:px(tx + 5, ty - 7, "#f4eee0"); c:px(tx - 13, ty - 4, "#f4eee0"); c:px(tx - 12, ty - 2, "#f4eee0")
  finish(c, "flag_duel")
end

-- 11. beacon_winch: inside the tower top; the gnome cranks the winch, a rope climbs to the beacon basket
function S.beacon_winch()
  seed = 71
  local c = new()
  c:fill(R(c, 0, 0, W - 1, H - 1), "#8b8f96")
  for y = 6, 48, 5 do
    fl(c, R(c, 0, y, W - 1, y), "#6e727a")
    for x = ((y / 5) % 2 == 0 and 3 or 9), W - 1, 12 do fl(c, R(c, x, y + 1, x, y + 4), "#6e727a") end
  end
  -- little window with sky
  part(c, R(c, 9, 12, 16, 24), "#7ab4d8"); fl(c, R(c, 10, 13, 15, 16), "#bcdde4"); fl(c, R(c, 12, 12, 12, 24), "#5e5a56"); fl(c, R(c, 9, 18, 16, 18), "#5e5a56")
  -- floor
  c:fill(R(c, 0, 44, W - 1, H - 1), "#a8703e")
  for y = 46, 49, 3 do fl(c, R(c, 0, y, W - 1, y), "#8a5a35") end
  fl(c, R(c, 0, 44, W - 1, 44), "#d9a660")
  -- overhead beam with a pulley and the unlit basket hanging from the rope
  part(c, R(c, 38, 4, 68, 7), "#8a5a35")
  part(c, c:ellipse(56, 10, 3, 3), "#5e5a56"); fl(c, R(c, 56, 10, 56, 10), "#aeb4bc")
  c:fill(R(c, 59, 11, 59, 36), "#e0c88a")
  part(c, R(c, 52, 12, 61, 14), "#3d2a1c")
  part(c, R(c, 53, 15, 60, 24), "#4a4640")
  for x = 54, 59, 2 do fl(c, R(c, x, 15, x, 24), "#8b8f96") end
  fl(c, R(c, 54, 18, 59, 19), "#6b3b2a"); fl(c, R(c, 55, 20, 58, 21), "#a8703e")
  fl(c, R(c, 55, 12, 55, 13), "#e0c88a"); fl(c, R(c, 56, 11, 56, 12), "#e0c88a")
  -- winch frame and drum
  part(c, R(c, 42, 28, 45, 44), "#8a5a35"); part(c, R(c, 62, 28, 65, 44), "#8a5a35")
  part(c, R(c, 44, 32, 63, 38), "#b07a45", { shade = true })
  for x = 47, 60, 3 do fl(c, R(c, x, 33, x, 37), "#e0c88a") end
  c:fill(R(c, 59, 35, 59, 37), "#e0c88a")
  -- crank: handle wheel on the left of the drum
  part(c, R(c, 38, 34, 43, 36), "#5e5a56")
  -- gnome turning the crank, leaning into it
  local _, G = gnome(c, 26, 48, { d = 1, eyes = "open", walk = 1, arms = { arm({ 4, 8 }, { 8, 12 }, true), arm({ -3, 6 }, { 9, 5 }, true) } })
  local hx, hy = G.P(9, 12)
  local ax, ay = G.P(9, 5)
  part(c, R(c, hx + 2, hy - 1, hx + 3, ay + 1), "#5e5a56", { noline = true })
  fl(c, R(c, hx + 2, hy - 1, hx + 4, hy), "#e8c48a")
  -- motion arcs
  for _, p in ipairs({ { 38, 27 }, { 40, 24 }, { 36, 30 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#d0d6da") end
  finish(c, "beacon_winch")
end

-- 12. redraw_map: the cartographer's desk; the gnome inks one empty corner, a tea mug has left its ring
function S.redraw_map()
  seed = 72
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 32), "#b8a070")
  for y = 6, 30, 6 do fl(c, R(c, 0, y, W - 1, y), "#a08a5c") end
  for y = 6, 30, 12 do for x = 4, W, 14 do fl(c, R(c, x, y + 1, x, y + 5), "#a08a5c") end end
  for y = 12, 30, 12 do for x = 11, W, 14 do fl(c, R(c, x, y + 1, x, y + 5), "#a08a5c") end end
  -- sunny window
  part(c, R(c, 5, 8, 20, 24), "#8ac0e0"); fl(c, R(c, 6, 9, 19, 13), "#bcdde4"); fl(c, R(c, 12, 8, 13, 24), "#8a5a35"); fl(c, R(c, 5, 16, 20, 17), "#8a5a35")
  fl(c, R(c, 8, 10, 10, 10), "#f4eee0")
  -- pinned finished maps on the wall
  part(c, R(c, 55, 8, 66, 20), "#e8d2a0"); fl(c, R(c, 57, 11, 61, 13), "#6aa04a"); fl(c, R(c, 60, 15, 64, 17), "#3f8fb0"); c:px(56, 9, "#dd3a2a"); c:px(65, 9, "#dd3a2a")
  fl(c, R(c, 56, 18, 64, 18), "#8a5a35")
  -- desk
  c:fill(R(c, 0, 33, W - 1, H - 1), "#a8703e")
  fl(c, R(c, 0, 33, W - 1, 34), "#d9a660")
  -- the map
  part(c, R(c, 16, 35, 64, 48), "#e8d2a0")
  fl(c, R(c, 17, 36, 63, 36), "#f0e0b8")
  -- hills, forest, river
  for _, p in ipairs({ { 20, 41 }, { 25, 43 } }) do c:fill(c:poly({ { p[1], p[2] - 4 }, { p[1] + 3, p[2] }, { p[1] - 3, p[2] } }), "#8a8a7a") end
  c:fill(c:ellipse(46, 40, 5, 2), "#6aa04a"); c:fill(c:ellipse(40, 44, 4, 2), "#4e8a3c")
  c:fill(c:line({ { 30, 36 }, { 33, 39 }, { 31, 42 }, { 36, 45 }, { 40, 48 } }, 2), "#3f8fb0")
  -- empty corner with a pencil sketch
  c:fill(R(c, 51, 43, 62, 47), "#ecdcb4")
  for x = 52, 61, 3 do c:px(x, 45, "#b8a070") end
  c:px(58, 44, "#b8a070"); c:px(59, 43, "#b8a070")
  -- tea mug and its ring
  part(c, R(c, 4, 38, 11, 45), "#c0442e"); fl(c, R(c, 11, 40, 13, 42), "#8e2e1e"); fl(c, R(c, 5, 38, 10, 38), "#6b3b2a")
  for i = 0, 1 do fl(c, R(c, 8 + i, 33 - i * 3, 9 + i, 34 - i * 3), "#f4f8fa") end
  c:fill(c:ellipse(25, 39, 4, 2):cut(c:ellipse(25, 39, 2, 1)), "#b8661a"); c:px(21, 40, "#b8661a")
  -- inkwell
  part(c, R(c, 67, 38, 68, 42), "#2a3558", { noline = true })
  -- gnome behind the desk, big, inking the corner
  local _, G = gnome(c, 42, 38, { d = 1, upper = true, eyes = "open", arms = { arm({ 4, 6 }, { 8, 3 }, true) } })
  local hx, hy = G.P(8, 3)
  c:fill(c:line({ { hx, hy }, { hx + 5, hy + 6 } }, 1), "#f4eee0")
  c:px(hx + 6, hy + 7, "#2a3558"); c:px(hx + 5, hy + 7, "#2a3558")
  c:fill(c:line({ { hx - 1, hy - 1 }, { hx - 5, hy - 5 } }, 1), "#f4eee0")
  finish(c, "redraw_map")
end

-- 13. supper_rush: dusk in the common room, four steaming bowls stacked on one arm, a hat stand at the table
function S.supper_rush()
  seed = 73
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#8a5a35")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 0, x, 38), "#6b3b2a") end
  fl(c, R(c, 0, 26, W - 1, 27), "#a8703e")
  -- dusk window
  part(c, R(c, 30, 8, 46, 24), "#6a4a88")
  c:bands(R(c, 31, 9, 45, 23), { "#5a3a78", "#8a4a82", "#c0587c", "#e8825e" }, { dir = "v" })
  fl(c, R(c, 38, 8, 39, 24), "#5e3f28"); fl(c, R(c, 30, 16, 46, 17), "#5e3f28")
  -- hanging lantern and its glow
  fl(c, R(c, 15, 5, 15, 9), "#3d2a1c"); part(c, R(c, 12, 10, 18, 16), "#ffd86a", { shade = true, cres = 1 }); fl(c, R(c, 14, 11, 16, 14), "#fff1c8")
  c:px(10, 12, "#f8c070"); c:px(20, 12, "#f8c070"); c:px(15, 18, "#f8c070")
  -- floor
  c:fill(R(c, 0, 39, W - 1, H - 1), "#b07a45")
  for y = 42, 50, 4 do fl(c, R(c, 0, y, W - 1, y), "#8a5a35") end
  -- table with a bowl and a hat stand customer
  part(c, R(c, 50, 35, 70, 38), "#c9a96e"); fl(c, R(c, 51, 35, 69, 35), "#e8c48a")
  part(c, R(c, 53, 39, 55, 46), "#8a5a35", { noline = true }); part(c, R(c, 66, 39, 68, 46), "#8a5a35", { noline = true })
  part(c, R(c, 56, 18, 57, 35), "#4a3a2a", { noline = true })
  part(c, R(c, 52, 33, 61, 34), "#4a3a2a", { noline = true })
  part(c, c:ellipse(56, 17, 4, 2), "#3d4a6a"); part(c, R(c, 53, 12, 58, 16), "#3d4a6a")
  fl(c, R(c, 53, 15, 58, 15), "#e8a317")
  part(c, c:ellipse(64, 34, 4, 2), "#f4eee0"); fl(c, R(c, 62, 33, 66, 33), "#c4623a")
  -- the server: striding, four bowls stacked on a raised hand
  local _, G = gnome(c, 28, 49, { d = 1, walk = 1, s = 1.1, eyes = "open", arms = { arm({ 4, 8 }, { 7, 17 }, true, true), arm({ -4, 7 }, { -6, 4 }, false) } })
  local bx, by = G.P(7, 17)
  local cols = { "#f4eee0", "#d9a660", "#f4eee0", "#aeb4bc" }
  for i = 0, 3 do
    part(c, R(c, bx - 4, by - 3 * i - 2, bx + 4, by - 3 * i), cols[i + 1])
    fl(c, R(c, bx - 3, by - 3 * i - 2, bx + 3, by - 3 * i - 2), "#c4623a")
  end
  fl(c, R(c, bx - 1, by + 1, bx + 1, by + 2), "#f0c8a0")
  for i = 0, 2 do fl(c, R(c, bx - 1 + (i % 2) * 2, by - 14 - i * 3, bx + (i % 2) * 2, by - 13 - i * 3), "#f4f8fa") end
  finish(c, "supper_rush")
end

-- 14. spoon_game: night at the inn, two gnomes across a little table, one shows a spoon, one a mug
function S.spoon_game()
  seed = 74
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 39), "#3a2a3a")
  for x = 0, W - 1, 8 do fl(c, R(c, x, 0, x, 39), "#2e2030") end
  -- night window with moon
  part(c, R(c, 28, 6, 44, 22), "#2a3558")
  c:fill(R(c, 29, 7, 43, 21), "#2a3a68"); c:fill(c:ellipse(38, 12, 3, 3), "#f5e6a8"); c:fill(c:ellipse(40, 11, 2, 2), "#2a3a68")
  for _, p in ipairs({ { 31, 10 }, { 33, 18 }, { 42, 18 }, { 35, 8 } }) do c:px(p[1], p[2], "#f4eee0") end
  fl(c, R(c, 36, 6, 37, 22), "#4a2c1a"); fl(c, R(c, 28, 14, 44, 15), "#4a2c1a")
  -- floor
  c:fill(R(c, 0, 40, W - 1, H - 1), "#5e3f28")
  for y = 44, 52, 4 do fl(c, R(c, 0, y, W - 1, y), "#4a2c1a") end
  -- candle on the table and its glow
  part(c, R(c, 34, 29, 37, 36), "#f4eee0"); fl(c, R(c, 35, 26, 36, 28), "#ffd86a"); c:px(35, 25, "#e8a317"); c:px(35, 27, "#fff1c8")
  for _, p in ipairs({ { 31, 27 }, { 40, 27 }, { 35, 22 } }) do c:px(p[1], p[2], "#f8c070") end
  -- gnomes
  local _, GA = gnome(c, 14, 43, { d = 1, upper = true, eyes = "open", arms = { arm({ 4, 6 }, { 9, 12 }, true) } })
  local sx, sy = GA.P(9, 12)
  c:fill(c:line({ { sx, sy - 1 }, { sx + 1, sy - 8 } }, 1), "#d0d6da")
  part(c, c:ellipse(sx + 1, sy - 10, 2, 3), "#d0d6da")
  part(c, R(c, sx - 1, sy - 1, sx + 1, sy + 1), "#f0c8a0", { noline = true })
  local _, GB = gnome(c, 58, 43, { d = -1, hat = "#4f9a45", upper = true, eyes = "open", arms = { arm({ -4, 6 }, { -9, 12 }, true) } })
  local mx, my = GB.P(-9, 12)
  part(c, R(c, mx - 3, my - 6, mx + 1, my - 1), "#aeb4bc"); fl(c, R(c, mx - 3, my - 6, mx + 1, my - 6), "#6b3b2a"); fl(c, R(c, mx - 5, my - 5, mx - 4, my - 3), "#8b929c")
  part(c, R(c, mx - 1, my - 1, mx + 1, my + 1), "#f0c8a0", { noline = true })
  -- table with a saucer
  part(c, R(c, 4, 38, 68, 42), "#a8703e"); fl(c, R(c, 5, 38, 67, 38), "#d9a660")
  part(c, R(c, 6, 43, 9, 50), "#6b3b2a", { noline = true }); part(c, R(c, 63, 43, 66, 50), "#6b3b2a", { noline = true })
  part(c, c:ellipse(36, 37, 5, 1), "#f4eee0"); fl(c, R(c, 33, 37, 39, 37), "#c9c5bc")
  -- rattle marks
  for _, p in ipairs({ { 24, 36 }, { 26, 34 }, { 46, 36 }, { 48, 34 }, { 22, 38 }, { 50, 38 } }) do c:px(p[1], p[2], "#d9a660") end
  finish(c, "spoon_game")
end

-- 15. leek_soup: the big inn pot in the hearth, leeks and potatoes waiting, the gnome stirs and tastes
function S.leek_soup()
  seed = 75
  local c = new()
  c:fill(R(c, 0, 0, W - 1, H - 1), "#9a9ea6")
  for y = 6, 48, 6 do
    fl(c, R(c, 0, y, W - 1, y), "#7a8088")
    for x = ((y / 6) % 2 == 0 and 2 or 8), W - 1, 12 do fl(c, R(c, x, y + 1, x, y + 5), "#7a8088") end
  end
  -- hearth arch
  part(c, R(c, 34, 12, 68, 49), "#585a62")
  c:fill(R(c, 37, 15, 65, 49), "#2a1a14")
  c:fill(c:ellipse(51, 15, 14, 3), "#2a1a14")
  -- fire
  part(c, c:line({ { 41, 47 }, { 61, 45 } }, 2), "#6b3b2a", { noline = true })
  c:fill(c:poly({ { 51, 38 }, { 56, 44 }, { 58, 48 }, { 44, 48 }, { 46, 44 } }), "#e0501f")
  c:fill(c:poly({ { 51, 42 }, { 54, 45 }, { 55, 48 }, { 47, 48 }, { 48, 45 } }), "#f08a24")
  c:fill(c:ellipse(51, 46, 2, 2), "#ffd86a")
  -- chain and big pot
  fl(c, R(c, 51, 12, 51, 22), "#aeb4bc")
  part(c, c:ellipse(51, 31, 11, 9), "#3d3a40", { shade = true })
  part(c, c:ellipse(51, 24, 10, 3), "#4a4640")
  c:fill(c:ellipse(51, 24, 8, 2), "#cde6a0")
  for _, p in ipairs({ { 47, 24 }, { 53, 24 }, { 56, 24 }, { 50, 23 } }) do c:px(p[1], p[2], "#f4f8e0"); c:px(p[1] + 1, p[2], "#8fc462") end
  fl(c, R(c, 41, 24, 41, 26), "#3d3a40"); fl(c, R(c, 61, 24, 61, 26), "#3d3a40")
  for i = 0, 3 do fl(c, R(c, 47 + (i % 2) * 6, 19 - i * 3, 48 + (i % 2) * 6, 20 - i * 3), "#f4f8fa") end
  -- floor + low counter with leeks and potatoes
  c:fill(R(c, 0, 45, W - 1, H - 1), "#8a5a35")
  fl(c, R(c, 0, 45, W - 1, 45), "#a8703e")
  part(c, R(c, 4, 38, 30, 44), "#b07a45"); fl(c, R(c, 5, 38, 29, 38), "#d9a660")
  for i = 0, 2 do
    fl(c, R(c, 8 + i * 4, 31 + i, 9 + i * 4, 37), "#f4eee0"); fl(c, R(c, 8 + i * 4, 28 + i, 9 + i * 4, 31 + i), "#4e8a3c")
    c:px(8 + i * 4 + 2, 28 + i, "#6aa04a")
  end
  part(c, c:ellipse(21, 36, 3, 2), "#c9a96e"); part(c, c:ellipse(26, 36, 2, 2), "#b8965c")
  fl(c, R(c, 22, 35, 22, 35), "#8a5a35")
  -- gnome with a long wooden spoon, stirring
  local _, G = gnome(c, 34, 48, { d = 1, eyes = "happy", walk = 1, arms = { arm({ 4, 8 }, { 8, 14 }, true) } })
  local hx, hy = G.P(8, 14)
  c:fill(c:line({ { hx, hy }, { hx + 9, hy - 8 } }, 1), "#a8703e")
  part(c, c:ellipse(hx + 11, hy - 9, 2, 1), "#a8703e", { noline = true })
  finish(c, "leek_soup")
end

local order = { "shrine_lanterns", "rake_gravel", "leaf_sweep", "pilgrim_tales", "meadowsweet_tea", "moth_count", "leaf_shapes", "sniff_jars", "fog_horn", "flag_duel", "beacon_winch", "redraw_map", "supper_rush", "spoon_game", "leek_soup" }
for _, s2 in ipairs(order) do
  if S[s2] and (not only or only == s2) then seed = 7; S[s2]() end
end
