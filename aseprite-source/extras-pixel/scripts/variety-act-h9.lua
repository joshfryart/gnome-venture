-- variety-act-h9.lua : regional rest-stop scenes (group h9) -> act-<slug>.png. Run: AppRun -b --script-param out=<dir>/ --script-param only=<slug[,slug]> --script variety-act-h9.lua
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

---------------------------------------------------------------- extra helpers
local function sparkle(c, x, y, a, b)
  a, b = a or "#fff1c8", b or "#f5cf6a"
  c:px(x, y, a); c:px(x - 1, y, b); c:px(x + 1, y, b); c:px(x, y - 1, b); c:px(x, y + 1, b)
end
local function puff(c, x, y, col) c:fill(c:ellipse(x, y, 2, 1), col or "#f4f8fa"); c:fill(R(c, x - 1, y + 1, x, y + 1), col or "#f4f8fa") end
local function tree(c, x, yb, rw, rh, col, trunk)
  part(c, R(c, x - 1, yb - rh, x + 1, yb), trunk or "#6b4a2e", { noline = true })
  part(c, c:ellipse(x, yb - rh - 2, rw, rh), col or "#3f8a42", { shade = true })
end
local function night(c, g, bands, stars)
  c:bands(R(c, 0, 0, W - 1, g), bands, { dir = "v" })
  for _, st in ipairs(stars or {}) do c:px(st[1], st[2], "#f4eee0") end
end
local function stork(c, x, y, up)
  local W1, K = "#f8f4ec", "#2a1a10"
  part(c, c:ellipse(x, y, 3, 1), W1, { noline = true })
  if up then
    fl(c, c:line({ { x - 1, y }, { x - 4, y - 4 } }, 2), W1); fl(c, c:line({ { x + 1, y }, { x + 4, y - 4 } }, 2), W1)
    c:px(x - 5, y - 5, K); c:px(x - 4, y - 5, K); c:px(x + 5, y - 5, K); c:px(x + 4, y - 5, K)
  else
    fl(c, c:line({ { x - 1, y }, { x - 5, y + 1 } }, 2), W1); fl(c, c:line({ { x + 1, y }, { x + 5, y + 1 } }, 2), W1)
    c:px(x - 6, y + 1, K); c:px(x + 6, y + 1, K); c:px(x - 5, y + 2, K); c:px(x + 5, y + 2, K)
  end
  fl(c, R(c, x + 3, y - 1, x + 6, y - 1), "#dd3a2a")  -- beak
  fl(c, R(c, x - 5, y, x - 3, y), "#dd3a2a")           -- legs trailing
  c:px(x + 3, y - 2, W1)
end
local function wall(c, y1, base, line)
  c:fill(R(c, 0, 0, W - 1, y1), base)
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, y1), line) end
end
local function floorboards(c, y0, base, line)
  c:fill(R(c, 0, y0, W - 1, H - 1), base)
  for y = y0 + 3, H - 2, 4 do fl(c, R(c, 0, y, W - 1, y), line) end
end

local S = {}

-- 1. wyrm bedtime: night, gnome whispering on a blanket beside a huge sleeping wyrm
function S.r_se_wyrm_bedtime()
  seed = 61
  local c = new()
  night(c, 36, { "#161c3a", "#1e2848", "#283258", "#343e66" }, { { 9, 8 }, { 22, 12 }, { 40, 7 }, { 58, 10 }, { 66, 20 }, { 14, 24 }, { 50, 20 } })
  c:fill(c:ellipse(60, 12, 3, 3), "#f5e6a8"); c:fill(c:ellipse(61, 11, 2, 2), "#283258")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#26402f"); c:fill(R(c, 0, 36, W - 1, 36), "#35563c")
  -- coiled wyrm back (humps) and spines
  for i, h in ipairs({ { 12, 39, 10, 9 }, { 28, 41, 8, 6 } }) do
    part(c, c:ellipse(h[1], h[2], h[3], h[4]), "#3d6a64", { shade = true })
    for k = -1, 1 do c:fill(c:poly({ { h[1] + k * 4 - 1, h[2] - h[4] + 2 }, { h[1] + k * 4, h[2] - h[4] - 1 }, { h[1] + k * 4 + 1, h[2] - h[4] + 2 } }), "#d8c890") end
  end
  for _, p in ipairs({ { 8, 38 }, { 10, 40 }, { 16, 37 }, { 28, 40 }, { 30, 42 } }) do c:px(p[1], p[2], "#f08a24"); c:px(p[1] + 1, p[2], "#e0501f") end
  -- sleeping head on the right
  part(c, c:ellipse(55, 42, 12, 6), "#3d6a64", { shade = true })
  part(c, c:poly({ { 46, 38 }, { 49, 31 }, { 51, 38 } }), "#e8dcb0"); part(c, c:poly({ { 56, 38 }, { 59, 32 }, { 61, 38 } }), "#e8dcb0")
  fl(c, R(c, 52, 39, 56, 39), INK); c:px(51, 38, INK); c:px(57, 38, INK); c:px(52, 40, INK); c:px(56, 40, INK)
  fl(c, R(c, 63, 41, 66, 42), "#f08a24"); c:px(64, 41, "#ffd86a")
  for i, p in ipairs({ { 66, 36 }, { 65, 32 }, { 67, 28 } }) do puff(c, p[1], p[2], "#8a94a8") end
  for _, p in ipairs({ { 62, 44 }, { 66, 46 } }) do c:px(p[1], p[2], "#f08a24") end
  -- blanket + whispering gnome
  part(c, R(c, 17, 45, 42, 48), "#c0442e"); for x = 19, 40, 4 do fl(c, R(c, x, 46, x + 1, 47), "#f4eee0") end
  gnome(c, 27, 42, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 4, 11 }, true) } })
  c:px(34, 24, "#f4eee0"); c:px(36, 22, "#f4eee0")
  sparkle(c, 44, 28, "#ffd86a", "#f08a24")
  finish(c, "r_se_wyrm_bedtime")
end

-- 2. lemon grove tales: dawn, sweeping the path between lemon trees
function S.r_se_lemon_grove_tales()
  seed = 62
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 32), { "#f2b896", "#f6c8a0", "#f8d8b0", "#fae6c4" }, { dir = "v" })
  c:fill(c:ellipse(36, 32, 9, 7), "#ffe08a"); c:fill(c:ellipse(36, 32, 6, 4), "#fff4c0")
  c:fill(c:ellipse(20, 32, 30, 7), "#7a9a58"); c:fill(c:ellipse(56, 33, 26, 6), "#6a8c4c")
  c:fill(R(c, 0, 32, W - 1, H - 1), "#8aac5c")
  c:fill(c:poly({ { 32, 32 }, { 42, 32 }, { 62, 54 }, { 10, 54 } }), "#d8bc84")
  c:fill(c:poly({ { 34, 34 }, { 40, 34 }, { 52, 52 }, { 22, 52 } }), "#e4cc98")
  local function lemontree(x, yb, r)
    part(c, R(c, x - 1, yb - 9, x + 1, yb), "#6b4a2e", { noline = true })
    part(c, c:ellipse(x, yb - 12, r, r - 2), "#4e8a3c", { shade = true })
    for _, d in ipairs({ { -3, -2 }, { 2, -4 }, { 4, 0 }, { -1, 1 }, { 0, -6 } }) do
      local ly = yb - 12 + math.max(d[2], -3); c:px(x + d[1], ly, "#f5d63a"); c:px(x + d[1] + 1, ly, "#e8b820")
    end
  end
  lemontree(10, 40, 9); lemontree(63, 42, 10); lemontree(24, 33, 5); lemontree(50, 33, 5)
  part(c, c:rrect(54, 44, 66, 49, 2), "#b07a45")
  for i = 0, 3 do c:fill(c:ellipse(56 + i * 3, 44, 1, 1), "#f5d63a") end
  local _, G = gnome(c, 28, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 8, 6 }, true) } })
  local x0, y0 = G.P(8, 8)
  part(c, c:line({ { x0, y0 - 6 }, { x0 + 3, y0 + 4 } }, 1), "#8a5a35", { noline = true })
  part(c, c:poly({ { x0 + 1, y0 + 4 }, { x0 + 6, y0 + 4 }, { x0 + 8, y0 + 9 }, { x0 - 1, y0 + 9 } }), "#d9a660"); fl(c, R(c, x0 + 1, y0 + 6, x0 + 6, y0 + 6), "#b07a45")
  for _, p in ipairs({ { 43, 46 }, { 45, 45 }, { 47, 47 } }) do c:px(p[1], p[2], "#e4cc98"); c:px(p[1], p[2] - 1, "#e4cc98") end
  finish(c, "r_se_lemon_grove_tales")
end

-- 3. drifting isles: dusk ferry, ferryman points at floating isles
function S.r_se_drifting_isles()
  seed = 63
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#4e3a78", "#8a4a88", "#c4607c", "#f08a64", "#f8b070" }, { dir = "v" })
  c:fill(c:ellipse(40, 30, 8, 6), "#ffd890")
  c:fill(R(c, 0, 30, W - 1, H - 1), "#2f4a70")
  for y = 31, 48, 3 do c:fill(R(c, 5 + (y * 7) % 20, y, 12 + (y * 7) % 20, y), "#f08a64"); c:fill(R(c, 40 + (y * 5) % 18, y + 1, 48 + (y * 5) % 18, y + 1), "#4a6a90") end
  local function isle(x, y, w, tr)
    part(c, c:poly({ { x - w, y }, { x + w, y }, { x + w - 2, y + 3 }, { x + 1, y + 7 }, { x - w + 3, y + 3 } }), "#7a5a48")
    part(c, c:ellipse(x, y, w, 2), "#5e9a48", { shade = true })
    if tr then part(c, c:ellipse(x - 1, y - 4, 2, 3), "#3f7a3a") ; fl(c, R(c, x - 1, y - 2, x - 1, y - 1), "#6b4a2e") end
  end
  isle(14, 12, 8, true); isle(44, 9, 6, true); isle(60, 19, 7, false)
  fl(c, R(c, 16, 15, 16, 20), "#a8e0f0"); fl(c, R(c, 62, 22, 62, 26), "#a8e0f0")
  -- jetty post and rope
  part(c, R(c, 64, 31, 66, 46), "#5e3f28"); part(c, R(c, 60, 46, 68, 49), "#5e3f28")
  c:fill(c:line({ { 64, 36 }, { 56, 39 } }, 1), "#e0c88a")
  -- boat
  part(c, c:poly({ { 12, 38 }, { 56, 38 }, { 51, 46 }, { 17, 46 } }), "#8a5a35", { shade = true })
  fl(c, R(c, 12, 38, 56, 38), "#b07a45")
  gnome(c, 22, 38, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 7 }, { 4, 4 }, true) } })
  local _, G = gnome(c, 46, 38, { d = -1, hat = "#4f9a45", eyes = "open", arms = { arm({ -4, 8 }, { -9, 14 }, true) } })
  fl(c, R(c, 40, 47, 48, 47), "#f08a64")
  finish(c, "r_se_drifting_isles")
end

-- 4. noon shade: nap under a vine arbour, heat outside
function S.r_se_noon_shade()
  seed = 64
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#fbf3c4", "#fcf6d2", "#fdf8de" }, { dir = "v" })
  c:fill(c:ellipse(58, 11, 6, 6), "#fffbe8"); c:fill(c:ellipse(58, 11, 4, 4), "#fff6c0")
  for _, p in ipairs({ { 58, 2 }, { 58, 20 }, { 47, 11 }, { 69, 11 }, { 50, 4 }, { 66, 4 }, { 50, 18 }, { 66, 18 } }) do c:px(p[1], p[2], "#f5cf6a") end
  c:fill(c:ellipse(14, 34, 26, 5), "#e8d898"); c:fill(R(c, 0, 34, W - 1, H - 1), "#ead08a")
  c:fill(R(c, 0, 34, W - 1, 34), "#f6e4a8")
  for x = 40, 66, 5 do c:fill(R(c, x, 31, x + 2, 31), "#fffbe8"); c:fill(R(c, x + 2, 30, x + 4, 30), "#fffbe8") end
  c:fill(c:ellipse(30, 46, 28, 4), "#c8a868")
  -- arbour: posts and vine roof with grapes
  part(c, R(c, 5, 16, 8, 47), "#8a5a35", { noline = true }); part(c, R(c, 58, 16, 61, 47), "#8a5a35", { noline = true })
  part(c, R(c, 5, 12, 64, 16), "#a8703e")
  for x = 6, 62, 5 do c:fill(c:ellipse(x, 11, 4, 3), "#4e8a3c"); c:fill(c:ellipse(x, 10, 2, 1), "#6aa84c") end
  for _, x in ipairs({ 12, 22, 33, 45, 54 }) do
    fl(c, R(c, x, 14, x + 1, 17), "#4e8a3c")
    for k = 0, 2 do c:px(x + (k % 2), 18 + k, "#7a3a8a"); c:px(x + 1 - (k % 2), 18 + k, "#9a56a8") end
  end
  -- sleeper against a post
  part(c, R(c, 10, 42, 40, 45), "#c0442e"); for x = 12, 38, 4 do fl(c, R(c, x, 43, x + 1, 44), "#f4eee0") end
  gnome(c, 20, 41, { d = 1, sit = true, eyes = "shut", arms = { arm({ 3, 6 }, { 6, 3 }, true) } })
  for i, z in ipairs({ { 33, 28, 2 }, { 37, 23, 3 }, { 42, 17, 4 } }) do
    local x, y, s = z[1], z[2], z[3]
    fl(c, R(c, x, y, x + s, y), "#6b7aa8"); fl(c, c:line({ { x + s, y }, { x, y + s } }, 1), "#6b7aa8"); fl(c, R(c, x, y + s, x + s, y + s), "#6b7aa8")
  end
  -- stone jug and dog? just a jug
  part(c, c:rrect(50, 40, 55, 47, 2), "#c4623a"); fl(c, R(c, 51, 38, 54, 39), "#8a3a1e")
  finish(c, "r_se_noon_shade")
end

-- 5. stork return: rooftops, gnome shading eyes at the sky, storks arriving
function S.r_ee_stork_return()
  seed = 65
  local c = new()
  day(c, 38, { sky = { "#98cce6", "#b0daec", "#cae8ee" }, cloud = 12, hill = "#6a9a4c", hill2 = "#58884a" })
  c:fill(R(c, 0, 40, W - 1, H - 1), "#c4623a")
  for y = 42, 48, 3 do for x = (y % 2 == 0) and 0 or 2, W - 1, 4 do fl(c, R(c, x, y, x + 2, y), "#a84a2a") end end
  fl(c, R(c, 0, 40, W - 1, 41), "#e08a54")
  -- stork chimney with nest
  part(c, R(c, 52, 24, 60, 40), "#b04a3a"); fl(c, R(c, 52, 29, 60, 30), "#f4eee0"); fl(c, R(c, 52, 34, 60, 35), "#f4eee0")
  part(c, c:ellipse(56, 23, 6, 2), "#8a5a35"); for x = 51, 61, 2 do c:px(x, 21 + (x % 3), "#a8703e") end
  -- blossom
  part(c, R(c, 8, 28, 9, 40), "#6b4a2e", { noline = true }); part(c, c:ellipse(9, 24, 7, 6), "#f2b8cc", { shade = true })
  c:px(7, 22, "#fff0f4"); c:px(11, 25, "#e888a8")
  stork(c, 38, 13, true); stork(c, 24, 8, false); stork(c, 50, 8, false)
  gnome(c, 28, 40, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -5, 4 }, false), arm({ 4, 9 }, { 7, 14 }, true) } })
  c:px(35, 37, "#f0c8a0")
  finish(c, "r_ee_stork_return")
end

-- 6. birch sap: spout, tin cup and a falling drop
function S.r_ee_birch_sap()
  seed = 66
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#bcd6e0", "#cde0e4", "#dce8e4" }, { dir = "v" })
  c:fill(R(c, 0, 34, W - 1, H - 1), "#8a8458"); c:fill(R(c, 0, 34, W - 1, 34), "#a09a68")
  for _, sn in ipairs({ { 8, 46, 7, 2 }, { 20, 38, 5, 1 }, { 58, 48, 8, 2 }, { 36, 36, 4, 1 } }) do c:fill(c:ellipse(sn[1], sn[2], sn[3], sn[4]), "#f0f4f6") end
  for _, p in ipairs({ { 14, 42 }, { 28, 44 }, { 62, 40 }, { 26, 38 } }) do c:px(p[1], p[2], "#7ab55c"); c:px(p[1] + 1, p[2] - 1, "#9cc86c") end
  -- distant birches
  for _, x in ipairs({ 9, 17, 27 }) do part(c, R(c, x, 8, x + 1, 36), "#f0eee8", { noline = true }); for y = 12, 34, 7 do c:px(x, y, "#2a1a10") end; fl(c, R(c, x - 3, 8, x + 4, 12), "#cfe0a0") end
  -- big birch
  part(c, R(c, 44, 5, 54, 48), "#f4f0e8")
  for _, y in ipairs({ 9, 15, 21, 38, 43 }) do fl(c, R(c, 45 + (y % 5), y, 48 + (y % 4), y + 1), "#2a1a10") end
  fl(c, R(c, 51, 27, 52, 28), "#2a1a10")
  fl(c, R(c, 41, 29, 43, 29), "#8b929c")                 -- spout
  part(c, R(c, 37, 35, 42, 41), "#aeb4bc"); fl(c, R(c, 38, 36, 41, 36), "#c8e8f0")
  fl(c, R(c, 36, 31, 37, 35), "#6b3b2a")
  c:px(42, 30, "#c8ecf4"); c:px(42, 32, "#c8ecf4"); c:px(42, 33, "#e8f8fc")
  fl(c, R(c, 56, 12, 58, 12), "#cfe0a0"); fl(c, R(c, 47, 6, 52, 7), "#cfe0a0")
  gnome(c, 26, 43, { d = 1, sit = true, eyes = "happy", arms = { arm({ 3, 8 }, { 8, 8 }, true) } })
  finish(c, "r_ee_birch_sap")
end

-- 7. sunflower stakes: storm sky, leaning sunflowers, gnome with twine
function S.r_ee_sunflower_stakes()
  seed = 67
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#4a5268", "#5c6680", "#707a92", "#8892a4" }, { dir = "v" })
  for _, cl in ipairs({ { 12, 10, 12, 4 }, { 40, 7, 14, 4 }, { 62, 14, 10, 3 } }) do c:fill(c:ellipse(cl[1], cl[2], cl[3], cl[4]), "#363c50") end
  c:fill(c:ellipse(30, 36, 40, 5), "#6a7a50")
  c:fill(R(c, 0, 35, W - 1, H - 1), "#7a8a52"); c:fill(R(c, 0, 35, W - 1, 35), "#8a9a5c")
  for y = 40, 49, 4 do for x = (y * 3) % 7, W - 1, 8 do c:fill(R(c, x, y, x + 3, y), "#6a7a44") end end
  local function flower(x, yb, lean, hh)
    local hx = x + lean
    part(c, c:line({ { x, yb }, { x + lean // 2, yb - hh // 2 }, { hx, yb - hh } }, 2), "#4e8a3c", { noline = true })
    c:fill(c:ellipse(x + lean // 3 - 2, yb - hh // 2 + 2, 3, 1), "#4e8a3c")
    for k = 0, 7 do
      local a = k * math.pi / 4
      c:fill(c:ellipse(hx + rnd(math.cos(a) * 5), yb - hh + rnd(math.sin(a) * 5), 2, 2), "#f5c42a")
    end
    part(c, c:ellipse(hx, yb - hh, 3, 3), "#5e3418"); c:px(hx - 1, yb - hh - 1, "#8a5a35")
  end
  flower(36, 48, 8, 28); flower(48, 48, 9, 30); flower(60, 48, 7, 26)
  part(c, R(c, 29, 24, 30, 48), "#a8703e", { noline = true })
  c:fill(c:line({ { 30, 30 }, { 37, 31 } }, 1), "#e0c88a")
  gnome(c, 22, 48, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -6, 3 }, false), arm({ 4, 8 }, { 9, 10 }, true) } })
  c:fill(c:line({ { 31, 30 }, { 33, 28 } }, 1), "#e0c88a")
  for _, w in ipairs({ { 8, 18, 14 }, { 12, 26, 18 }, { 6, 33, 12 }, { 50, 14, 16 }, { 56, 20, 10 } }) do fl(c, R(c, w[1], w[2], w[1] + w[3] - 8, w[2]), "#cfd8e4") end
  finish(c, "r_ee_sunflower_stakes")
end

-- 8. amber polish: close-up, glowing amber held up
function S.r_ee_amber_polish()
  seed = 68
  local c = new()
  wall(c, 36, "#b8905a", "#a8804c")
  fl(c, R(c, 0, 14, W - 1, 15), "#6b4a2e")
  for i, p in ipairs({ { 8, "#d9b878" }, { 16, "#e8c060" }, { 56, "#d9b878" }, { 63, "#cfa860" } }) do
    part(c, c:ellipse(p[1], 12, 3, 2), p[2]); c:px(p[1] - 1, 11, "#f4eee0")
  end
  c:fill(R(c, 0, 37, W - 1, H - 1), "#7a4a2a"); c:fill(R(c, 0, 37, W - 1, 38), "#a8703e")
  part(c, R(c, 4, 40, 18, 48), "#e8d6b0"); fl(c, R(c, 4, 40, 18, 40), "#f4eee0")  -- felt cloth
  local _, G = gnome(c, 28, 47, { d = 1, s = 1.4, upper = true, eyes = "open", arms = { arm({ -4, 7 }, { 4, 6 }, true), arm({ 4, 7 }, { 12, 17 }, true) } })
  local ax, ay = 46, 24
  for k = 0, 7 do local a = k * math.pi / 4; sparkle(c, ax + rnd(math.cos(a) * 11), ay + rnd(math.sin(a) * 10), "#ffe8a0", "#f5cf6a") end
  part(c, c:ellipse(ax, ay, 7, 6), "#e8a317"); c:fill(c:ellipse(ax - 1, ay - 1, 5, 4), "#f5c040"); c:fill(c:ellipse(ax - 3, ay - 2, 1, 1), "#fff1c8")
  c:px(ax + 2, ay + 1, "#6b3b2a"); c:px(ax + 3, ay + 1, "#6b3b2a")
  fl(c, R(c, 38, 29, 41, 31), "#f0c8a0")
  part(c, c:ellipse(60, 44, 4, 3), "#d9b878"); c:px(59, 43, "#f4eee0")
  finish(c, "r_ee_amber_polish")
end

-- 9. steam hut: log hut venting steam, gnome with a leafy birch whisk, snowdrift
function S.r_ee_steam_whisk()
  seed = 69
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#b4cce0", "#c4d8e8", "#d4e4ee", "#e2edf2" }, { dir = "v" })
  c:fill(c:ellipse(14, 34, 30, 7), "#d8e4ee"); c:fill(R(c, 0, 34, W - 1, H - 1), "#eef3f7"); c:fill(R(c, 0, 45, W - 1, H - 1), "#e0e9f0")
  for _, x in ipairs({ 6, 62 }) do pine(c, x, 38, 16, true) end
  -- hut
  part(c, R(c, 12, 26, 38, 44), "#8a5a35")
  for y = 29, 41, 3 do fl(c, R(c, 12, y, 38, y), "#6b3b2a") end
  part(c, c:poly({ { 10, 27 }, { 25, 15 }, { 40, 27 } }), "#6b4a2e")
  c:fill(c:poly({ { 12, 26 }, { 25, 17 }, { 38, 26 } }), "#f4f8fa")
  part(c, R(c, 16, 12, 20, 22), "#8b8f96")
  part(c, R(c, 19, 31, 28, 44), "#f08a24"); fl(c, R(c, 21, 33, 26, 44), "#ffd86a")
  for i, p in ipairs({ { 18, 9 }, { 20, 5 } }) do puff(c, p[1], p[2]) end
  for _, p in ipairs({ { 30, 34 }, { 32, 31 }, { 17, 28 } }) do puff(c, p[1], p[2], "#fbfdfe") end
  c:fill(c:ellipse(30, 45, 12, 2), "#f4f8fa")
  gnome(c, 50, 47, { d = -1, eyes = "happy", arms = { arm({ 4, 7 }, { 5, 4 }, true), arm({ -4, 8 }, { -9, 15 }, true) } })
  -- the whisk
  part(c, c:line({ { 41, 33 }, { 41, 27 } }, 1), "#6b4a2e", { noline = true })
  part(c, c:poly({ { 40, 28 }, { 42, 28 }, { 46, 20 }, { 45, 15 }, { 41, 13 }, { 37, 15 }, { 36, 20 } }), "#5e9a44")
  for _, p in ipairs({ { 39, 17 }, { 42, 15 }, { 44, 19 }, { 38, 22 }, { 41, 22 }, { 40, 26 } }) do c:px(p[1], p[2], "#8fc462"); c:px(p[1] + 1, p[2] + 1, "#3f7a3a") end
  fl(c, R(c, 40, 28, 42, 28), "#c0442e")
  seed = 40
  for i = 1, 16 do c:px(6 + floor(rand() * 62), 6 + floor(rand() * 40), "#fbfdfe") end
  finish(c, "r_ee_steam_whisk")
end

-- 10. salt grade: three crates pink / grey / pearl, a lump going into the pink one
function S.r_ee_salt_grade()
  seed = 70
  local c = new()
  day(c, 30, { cloud = 56, sky = { "#b4d4e0", "#c8e0e6", "#dcecea" } })
  c:fill(R(c, 0, 30, W - 1, H - 1), "#d4b87c"); c:fill(R(c, 0, 30, W - 1, 30), "#e4cc98")
  -- awning
  local n = 0
  for x = 5, 68, 4 do fl(c, R(c, x, 5, x + 3, 9), (n % 2 == 0) and "#c0442e" or "#f4eee0"); n = n + 1 end
  part(c, R(c, 5, 10, 68, 10), "#6b3b2a", { noline = true })
  -- cart on the right
  part(c, R(c, 52, 32, 68, 40), "#8a5a35")
  for _, p in ipairs({ { 54, 31 }, { 58, 29 }, { 62, 31 }, { 66, 30 }, { 60, 32 } }) do part(c, c:ellipse(p[1], p[2], 3, 2), "#a8acb4") end
  part(c, c:ellipse(58, 43, 6, 6), "#6b4a2e"); c:fill(c:ellipse(58, 43, 4, 4), "#b07a45"); c:fill(c:ellipse(58, 43, 1, 1), "#4a2c1a")
  fl(c, R(c, 52, 36, 68, 36), "#6b3b2a")
  -- three crates
  local function crate(x, col, lc, hi)
    part(c, R(c, x, 36, x + 10, 46), "#b07a45")
    fl(c, R(c, x, 40, x + 10, 40), "#8a5a35"); fl(c, R(c, x, 44, x + 10, 44), "#8a5a35")
    for k, d in ipairs({ { 1, 1 }, { 4, 0 }, { 7, 1 }, { 2, -1 }, { 6, -1 } }) do
      part(c, c:ellipse(x + d[1] + 1, 35 + d[2], 2, 2), col); c:px(x + d[1], 34 + d[2], hi)
    end
  end
  crate(22, "#e8a0a8", "", "#fcd8dc"); crate(34, "#aab0b8", "", "#dce0e4"); crate(46, "#f2f2ec", "", "#f8f8f4")
  gnome(c, 12, 47, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 8, 13 }, true) } })
  part(c, c:ellipse(23, 33, 3, 2), "#e8a0a8"); c:px(22, 32, "#fcd8dc")
  sparkle(c, 26, 29, "#f8f8f4", "#fcd8dc")
  finish(c, "r_ee_salt_grade")
end

-- 11. ridge howl: night, wolf and gnome both singing at the moon
function S.r_ee_ridge_howl()
  seed = 71
  local c = new()
  night(c, 40, { "#0e1430", "#141c3c", "#1c2648", "#26305a" }, { { 8, 8 }, { 18, 18 }, { 56, 8 }, { 64, 18 }, { 26, 9 }, { 12, 24 }, { 60, 26 } })
  c:fill(c:ellipse(36, 14, 9, 9), "#f5e6a8"); c:fill(c:ellipse(33, 12, 3, 3), "#e8d490"); c:fill(c:ellipse(39, 17, 2, 2), "#e8d490")
  c:fill(c:ellipse(14, 40, 30, 12), "#1c2a40"); c:fill(c:ellipse(60, 42, 26, 12), "#202e46")
  c:fill(R(c, 0, 42, W - 1, H - 1), "#1a2438")
  for _, p in ipairs({ { 4, 36 }, { 66, 34 } }) do
    c:fill(c:poly({ { p[1], p[2] - 12 }, { p[1] + 3, p[2] - 4 }, { p[1] + 5, p[2] }, { p[1] - 5, p[2] } }), "#0e1a24")
  end
  -- rock + wolf at left
  part(c, c:ellipse(18, 47, 14, 6), "#4a5468", { shade = true })
  local WC = "#7a8498"
  part(c, c:poly({ { 6, 44 }, { 4, 38 }, { 7, 40 }, { 9, 43 } }), WC)                                   -- tail
  part(c, c:ellipse(13, 42, 6, 5), WC)
  part(c, c:poly({ { 15, 44 }, { 17, 34 }, { 20, 30 }, { 23, 26 }, { 28, 22 }, { 29, 25 }, { 26, 29 }, { 24, 34 }, { 22, 44 } }), WC)
  part(c, R(c, 18, 40, 20, 46), WC)
  part(c, c:poly({ { 20, 28 }, { 21, 25 }, { 23, 27 } }), WC)
  c:px(25, 25, INK)
  fl(c, R(c, 17, 36, 18, 38), "#c8ccd4")
  -- gnome at right, cupped hands
  part(c, c:ellipse(56, 48, 12, 4), "#4a5468", { shade = true })
  gnome(c, 54, 46, { d = -1, eyes = "open", arms = { arm({ -4, 8 }, { -6, 13 }, true), arm({ 4, 8 }, { 6, 13 }, true) } })
  for k = 0, 2 do c:px(40 + k, 22 - k * 2, "#f4eee0") end
  c:px(48, 18, "#f4eee0"); c:px(46, 22, "#f4eee0"); c:px(31, 24, "#f4eee0"); c:px(33, 26, "#f4eee0")
  finish(c, "r_ee_ridge_howl")
end

-- 12. reed punt: poling a basket down a green reed channel
function S.r_ee_reed_punt()
  seed = 72
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 22), { "#b8dce0", "#cde6e2", "#e0efe4" }, { dir = "v" })
  c:fill(R(c, 0, 22, W - 1, H - 1), "#4e8a6a")
  -- water channel
  c:fill(c:poly({ { 24, 24 }, { 48, 24 }, { 72, 49 }, { 0, 49 } }), "#6ab4b8")
  for y = 28, 48, 4 do fl(c, R(c, 28 - y // 3 + (y % 8), y, 34 - y // 3 + (y % 8), y), "#a8e0e0"); fl(c, R(c, 50 + (y % 7), y + 1, 56 + (y % 7), y + 1), "#4e9aa4") end
  -- reed walls
  seed = 9
  for i = 1, 36 do
    local x = (i % 2 == 0) and floor(rand() * 26) or (46 + floor(rand() * 26))
    local top = 8 + floor(rand() * 10)
    local yb = 26 + floor(rand() * 10)
    local lean = (x < 36) and 0 or 0
    fl(c, R(c, x, top, x, yb), (i % 3 == 0) and "#7aa04a" or "#8aae52")
    if i % 4 == 0 then fl(c, R(c, x, top - 1, x, top + 2), "#6b3b2a") end
  end
  c:fill(R(c, 0, 33, 22, 34), "#3a6a50"); c:fill(R(c, 50, 33, 72, 34), "#3a6a50")
  -- punt
  part(c, c:poly({ { 12, 42 }, { 58, 42 }, { 54, 47 }, { 17, 47 } }), "#6b4a2e", { shade = true })
  fl(c, R(c, 12, 42, 58, 42), "#a8703e")
  part(c, c:ellipse(49, 41, 5, 3), "#c8a060"); fl(c, R(c, 45, 40, 53, 40), "#e0c88a"); fl(c, R(c, 47, 41, 47, 43), "#a8803c"); fl(c, R(c, 51, 41, 51, 43), "#a8803c")
  fl(c, R(c, 46, 36, 52, 37), "#c0442e")
  gnome(c, 24, 42, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { 0, 12 }, true), arm({ 4, 8 }, { 7, 4 }, true) } })
  part(c, c:line({ { 27, 30 }, { 38, 47 } }, 1), "#8a5a35", { noline = true })
  fl(c, R(c, 36, 48, 41, 48), "#a8e0e0")
  for _, p in ipairs({ { 18, 46 }, { 60, 45 } }) do fl(c, R(c, p[1], p[2], p[1] + 4, p[2]), "#a8e0e0") end
  finish(c, "r_ee_reed_punt")
end

-- 13. beaver post: autumn, a beaver gnawing the ferry post, gnome offering a branch
function S.r_ee_beaver_post()
  seed = 73
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 32), { "#d4c4a0", "#dcd0ac", "#e4dcbc" }, { dir = "v" })
  for _, t in ipairs({ { 8, 32, 8 }, { 24, 31, 6 }, { 60, 32, 8 }, { 48, 31, 5 } }) do
    part(c, R(c, t[1], 22, t[1] + 1, t[2]), "#6b4a2e", { noline = true })
    part(c, c:ellipse(t[1], 20, t[3], 8), (t[1] % 3 == 0) and "#d9822a" or "#c8501f", { shade = true })
    c:fill(c:ellipse(t[1] - 2, 17, 2, 1), "#f0b040")
  end
  c:fill(R(c, 0, 33, W - 1, H - 1), "#4a7a88")
  for y = 35, 47, 4 do fl(c, R(c, (y * 5) % 15 + 4, y, (y * 5) % 15 + 11, y), "#7ab0b8") end
  -- jetty
  part(c, R(c, 4, 40, 68, 44), "#a8703e"); fl(c, R(c, 4, 40, 68, 40), "#c89050")
  for x = 12, 62, 10 do fl(c, R(c, x, 41, x, 43), "#6b3b2a") end
  part(c, R(c, 10, 44, 11, 49), "#5e3f28", { noline = true }); part(c, R(c, 61, 44, 62, 49), "#5e3f28", { noline = true })
  -- the post: gnawed hourglass waist
  part(c, c:poly({ { 33, 12 }, { 41, 12 }, { 41, 24 }, { 39, 27 }, { 39, 32 }, { 41, 36 }, { 41, 40 }, { 33, 40 }, { 33, 36 }, { 35, 32 }, { 35, 27 }, { 33, 24 } }), "#8a5a35")
  fl(c, R(c, 34, 12, 35, 24), "#a8703e"); fl(c, R(c, 36, 27, 38, 32), "#e8c48a")
  for _, p in ipairs({ { 30, 34 }, { 28, 38 }, { 44, 38 }, { 31, 32 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#e8c48a") end
  c:fill(c:line({ { 41, 15 }, { 56, 22 } }, 1), "#e0c88a")
  -- beaver, up on its hind legs
  local BR = "#8a5a35"
  part(c, c:ellipse(23, 33, 4, 6), BR, { shade = true }); fl(c, R(c, 21, 31, 24, 38), "#c89050")
  part(c, c:ellipse(28, 27, 4, 3), BR)
  part(c, R(c, 30, 28, 32, 29), "#f5b02a", { noline = true }); fl(c, R(c, 31, 28, 31, 29), "#fff1c8")
  c:px(28, 26, INK); part(c, R(c, 25, 24, 26, 25), BR, { noline = true })
  part(c, c:ellipse(17, 39, 4, 2), "#5e3f28"); c:px(15, 39, "#8a5a35"); c:px(18, 39, "#8a5a35")
  fl(c, R(c, 29, 33, 31, 34), BR)
  gnome(c, 52, 40, { d = -1, eyes = "open", arms = { arm({ -4, 7 }, { -9, 9 }, true) } })
  -- leafy branch offered
  fl(c, c:line({ { 41, 31 }, { 47, 30 } }, 1), "#6b4a2e")
  for _, p in ipairs({ { 40, 29 }, { 42, 28 }, { 44, 29 } }) do part(c, c:ellipse(p[1], p[2], 2, 1), "#d9a02a", { noline = true }) end
  c:px(34, 20, "#f4eee0")
  finish(c, "r_ee_beaver_post")
end

-- 14. black earth: gnome squeezes a fistful of black soil, three bowls of soil beside
function S.r_ee_black_earth()
  seed = 74
  local c = new()
  day(c, 26, { cloud = 50, sky = { "#b4d4e0", "#c8e0e6", "#dcecea" }, hill = "#a8a860", hill2 = "#b8b46c", grass = "#2a2018", edge = "#a8a860" })
  c:fill(R(c, 0, 26, W - 1, H - 1), "#2e2218")
  for y = 29, 49, 4 do fl(c, R(c, 0, y, W - 1, y), "#3e3024"); fl(c, R(c, 0, y + 1, W - 1, y + 1), "#1c140e") end
  c:fill(R(c, 0, 26, W - 1, 26), "#a8a860")
  -- plank with bowls
  part(c, R(c, 38, 36, 68, 40), "#a8703e"); fl(c, R(c, 38, 36, 68, 36), "#c89050")
  part(c, R(c, 40, 40, 41, 49), "#6b4a2e", { noline = true }); part(c, R(c, 65, 40, 66, 49), "#6b4a2e", { noline = true })
  for i, col in ipairs({ "#a8703e", "#6a4a2e", "#1a120c" }) do
    local x = 44 + (i - 1) * 9
    part(c, c:rrect(x - 4, 31, x + 4, 36, 2), "#c9c5bc")
    fl(c, R(c, x - 3, 30, x + 3, 31), col); fl(c, R(c, x - 2, 29, x + 2, 29), col)
    if i == 3 then c:px(x - 1, 30, "#4a4038") end
  end
  gnome(c, 20, 48, { d = 1, s = 1.4, eyes = "open", arms = { arm({ -4, 8 }, { -5, 4 }, false), arm({ 4, 10 }, { 8, 17 }, true) } })
  fl(c, c:ellipse(30, 32, 3, 3), "#f0c8a0"); fl(c, c:ellipse(30, 32, 2, 2), "#e0b088")
  part(c, c:ellipse(30, 29, 3, 2), "#1a120c", { noline = true })
  for _, p in ipairs({ { 28, 36 }, { 31, 39 }, { 29, 43 }, { 32, 41 } }) do c:px(p[1], p[2], "#6a5438") end
  c:px(33, 29, "#4a3a28"); c:px(26, 30, "#4a3a28")
  finish(c, "r_ee_black_earth")
end

-- 15. buckwheat kasha: toasted-grain kitchen, stirring a pot on a big brick stove
function S.r_ee_buckwheat_kasha()
  seed = 75
  local c = new()
  wall(c, 38, "#e8d6b0", "#dcc89c")
  fl(c, R(c, 0, 10, W - 1, 11), "#c0442e")
  floorboards(c, 39, "#8a5a35", "#6b3b2a")
  -- shelf with bowls
  part(c, R(c, 6, 22, 30, 23), "#8a5a35")
  for _, x in ipairs({ 9, 16, 23 }) do part(c, c:rrect(x, 17, x + 5, 21, 2), (x % 2 == 0) and "#3f6fb0" or "#f4eee0") end
  -- stove
  part(c, R(c, 40, 24, 68, 48), "#b8745a")
  for y = 27, 45, 4 do fl(c, R(c, 40, y, 68, y), "#8e4a3a") end
  for y = 25, 45, 4 do for x = 44 + (y % 8), 66, 8 do fl(c, R(c, x, y + 1, x, y + 3), "#8e4a3a") end end
  part(c, R(c, 40, 22, 68, 24), "#5a4038")
  part(c, c:poly({ { 49, 46 }, { 49, 38 }, { 53, 35 }, { 57, 38 }, { 57, 46 } }), "#2a1a10"); c:fill(c:poly({ { 51, 46 }, { 51, 40 }, { 53, 38 }, { 55, 40 }, { 55, 46 } }), "#f08a24"); c:fill(R(c, 52, 43, 54, 46), "#ffd86a")
  part(c, c:rrect(46, 12, 62, 22, 3), "#4a4a52", { shade = true }); fl(c, R(c, 45, 13, 45, 15), "#4a4a52"); fl(c, R(c, 63, 13, 63, 15), "#4a4a52")
  fl(c, R(c, 48, 13, 60, 13), "#c8a060")
  for _, p in ipairs({ { 51, 9 }, { 55, 6 }, { 58, 9 } }) do puff(c, p[1], p[2], "#f4f8fa") end
  -- sack + jug
  part(c, c:poly({ { 7, 48 }, { 8, 36 }, { 12, 34 }, { 22, 34 }, { 25, 36 }, { 26, 48 } }), "#c8a060")
  fl(c, R(c, 12, 33, 21, 34), "#a8803c")
  for i = 0, 4 do c:px(11 + i * 2, 33, "#8a5a35"); c:px(12 + i * 2, 32, "#8a5a35") end
  fl(c, R(c, 14, 40, 18, 41), "#a8803c")
  part(c, c:rrect(30, 41, 34, 47, 1), "#f4eee0"); fl(c, R(c, 31, 39, 33, 40), "#f4eee0")
  gnome(c, 38, 48, { d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 8, 12 }, true) } })
  part(c, c:line({ { 46, 36 }, { 52, 19 } }, 1), "#a8703e", { noline = true })
  finish(c, "r_ee_buckwheat_kasha")
end

-- 16. plum butter: autumn orchard, big paddle in a copper pot over the fire
function S.r_ee_plum_butter()
  seed = 76
  local c = new()
  day(c, 34, { sky = { "#c8d8d0", "#d8e0c8", "#e4e4c0" }, cloud = false, hill = "#8a8a44", hill2 = "#7a8a40", grass = "#8a9a4c", edge = "#a8b060" })
  -- plum tree
  part(c, R(c, 11, 18, 14, 38), "#6b4a2e")
  part(c, c:ellipse(12, 14, 12, 9), "#6a8a3a", { shade = true })
  for _, p in ipairs({ { 6, 13 }, { 10, 18 }, { 15, 12 }, { 18, 17 }, { 12, 9 }, { 8, 20 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#7a3a8a", { noline = true }); c:px(p[1], p[2], "#a858b0") end
  -- fire + pot
  for _, x in ipairs({ 42, 48, 54, 60 }) do part(c, c:ellipse(x, 48, 3, 2), "#8b8f96", { shade = true }) end
  part(c, c:poly({ { 51, 38 }, { 56, 44 }, { 58, 48 }, { 44, 48 }, { 46, 44 } }), "#e0501f"); c:fill(c:poly({ { 51, 42 }, { 54, 46 }, { 55, 48 }, { 47, 48 }, { 48, 46 } }), "#ffd86a")
  part(c, c:ellipse(51, 33, 12, 8), "#c8703a", { shade = true })
  c:fill(c:ellipse(51, 28, 10, 2), "#4a1e3a"); c:fill(R(c, 44, 28, 47, 28), "#8a4a7a"); c:px(55, 27, "#8a4a7a")
  fl(c, R(c, 39, 28, 41, 30), "#8a4a1e"); fl(c, R(c, 61, 28, 63, 30), "#8a4a1e")
  for _, p in ipairs({ { 52, 22 }, { 56, 18 }, { 52, 14 } }) do puff(c, p[1], p[2], "#f4f8fa") end
  gnome(c, 28, 47, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { 2, 11 }, true), arm({ 4, 8 }, { 8, 12 }, true) } })
  part(c, c:line({ { 38, 36 }, { 52, 24 } }, 2), "#a8703e", { noline = true })
  part(c, R(c, 49, 25, 53, 28), "#c89050")
  part(c, c:rrect(6, 42, 18, 48, 2), "#b07a45")
  for i = 0, 3 do part(c, c:ellipse(8 + i * 3, 42, 1, 1), "#7a3a8a", { noline = true }) end
  finish(c, "r_ee_plum_butter")
end

-- 17. elder cordial: herbalist shelf, ladling dark syrup into bottles
function S.r_ee_elder_cordial()
  seed = 77
  local c = new()
  wall(c, 36, "#c4a070", "#b48f5e")
  fl(c, R(c, 0, 5, W - 1, 8), "#6b4a2e")
  -- hanging elderberry sprigs
  for _, x in ipairs({ 10, 22, 40, 58, 66 }) do
    fl(c, R(c, x, 9, x, 13), "#4e8a3c")
    for k = 0, 4 do c:fill(c:ellipse(x - 2 + (k % 3) * 2, 15 + k // 2 * 2, 1, 1), "#3a2a5a"); c:px(x - 2 + (k % 3) * 2, 14 + k // 2 * 2, "#6a52a0") end
  end
  floorboards(c, 37, "#8a5a35", "#6b3b2a")
  fl(c, R(c, 0, 37, W - 1, 38), "#b07a45")
  -- bottles
  local function bottle(x, fill)
    part(c, R(c, x, 30, x + 4, 38), fill and "#6a2e7a" or "#b8e0e8"); part(c, R(c, x + 1, 26, x + 3, 29), fill and "#6a2e7a" or "#b8e0e8"); fl(c, R(c, x + 1, 25, x + 3, 25), "#c8a060")
    c:px(x + 1, 32, "#a868b8")
  end
  bottle(43, true); bottle(51, true); bottle(59, false)
  -- pot on the left with steam
  part(c, c:rrect(6, 30, 24, 38, 3), "#4a4a52", { shade = true }); fl(c, R(c, 8, 29, 22, 29), "#2a1a3a"); c:fill(c:ellipse(15, 30, 7, 1), "#4a2a6a")
  for _, p in ipairs({ { 11, 25 }, { 17, 22 }, { 12, 19 } }) do puff(c, p[1], p[2], "#e8dcf0") end
  -- ladling gnome behind the table
  gnome(c, 33, 47, { d = 1, upper = true, s = 1.25, eyes = "open", arms = { arm({ 5, 7 }, { 9, 12 }, true), arm({ -5, 7 }, { -9, 11 }, true) } })
  part(c, c:line({ { 41, 29 }, { 46, 36 } }, 1), "#8a5a35", { noline = true })
  part(c, c:ellipse(41, 28, 2, 1), "#aeb4bc")
  c:px(47, 32, "#8a3aa0"); c:px(47, 34, "#8a3aa0")
  part(c, R(c, 4, 39, 68, 42), "#d9a660"); fl(c, R(c, 4, 39, 68, 39), "#e8c48a")
  part(c, R(c, 4, 43, 68, 49), "#a8703e")
  part(c, c:rrect(28, 39, 32, 41, 1), "#3a2a5a", { noline = true })
  finish(c, "r_ee_elder_cordial")
end

-- 18. sunflower toast: shaking seeds in a pan over a camp fire, big seed head beside
function S.r_ee_sunflower_toast()
  seed = 78
  local c = new()
  day(c, 34, { cloud = 50, sky = { "#a8d4e0", "#bcdde4", "#cfe8e6" } })
  -- big seed head leaning on a log at the right
  part(c, R(c, 52, 42, 68, 47), "#8a5a35"); fl(c, R(c, 52, 42, 68, 42), "#a8703e")
  part(c, c:ellipse(60, 33, 9, 9), "#f5c42a"); c:fill(c:ellipse(60, 33, 6, 6), "#5e3418")
  for k = 0, 4 do c:px(57 + k, 31 + (k % 2), "#8a5a35"); c:px(56 + k, 34 - (k % 2), "#8a5a35"); c:px(58 + k, 36, "#8a5a35") end
  -- fire ring
  for _, x in ipairs({ 30, 36, 42 }) do part(c, c:ellipse(x, 48, 3, 2), "#8b8f96", { shade = true }) end
  part(c, c:poly({ { 36, 38 }, { 40, 43 }, { 42, 48 }, { 30, 48 }, { 32, 43 } }), "#e0501f"); c:fill(c:poly({ { 36, 42 }, { 38, 45 }, { 39, 48 }, { 33, 48 }, { 34, 45 } }), "#ffd86a")
  -- pan
  part(c, c:ellipse(36, 35, 9, 2), "#4a4a52", { shade = true }); fl(c, R(c, 29, 34, 43, 34), "#6a6a72")
  gnome(c, 14, 43, { d = 1, sit = true, eyes = "happy", arms = { arm({ 3, 8 }, { 10, 6 }, true) } })
  part(c, c:line({ { 25, 35 }, { 30, 35 } }, 1), "#6b4a2e", { noline = true })
  -- popping seeds
  for _, p in ipairs({ { 31, 30 }, { 35, 27 }, { 39, 31 }, { 42, 26 }, { 33, 23 }, { 38, 22 }, { 28, 26 }, { 45, 30 } }) do
    fl(c, R(c, p[1], p[2], p[1], p[2] + 1), "#4a4038"); c:px(p[1] + 1, p[2], "#d8d0c0")
  end
  for _, p in ipairs({ { 20, 47 }, { 24, 48 }, { 46, 46 } }) do c:px(p[1], p[2], "#4a4038") end
  for _, p in ipairs({ { 36, 17 }, { 40, 14 }, { 36, 11 } }) do puff(c, p[1], p[2], "#f4f8fa") end
  finish(c, "r_ee_sunflower_toast")
end

-- 19. stuffed peppers: tray of red/yellow/green peppers, gnome spooning in cheese
function S.r_ee_stuffed_peppers()
  seed = 79
  local c = new()
  wall(c, 38, "#f0e4c4", "#e4d4ac")
  fl(c, R(c, 0, 13, W - 1, 14), "#4e8a3c")
  -- window with checked curtains
  part(c, R(c, 5, 17, 20, 30), "#a8d4e0"); fl(c, R(c, 12, 17, 13, 30), "#8a5a35"); fl(c, R(c, 5, 23, 20, 24), "#8a5a35")
  for y = 17, 21, 2 do for x = 5, 8, 2 do fl(c, R(c, x, y, x + 1, y + 1), "#c0442e") end end
  fl(c, R(c, 16, 25, 19, 28), "#c0442e")
  -- garlic braid
  fl(c, R(c, 62, 8, 62, 12), "#8a5a35"); for k = 0, 3 do part(c, c:ellipse(62 + (k % 2) * 2 - 1, 13 + k * 3, 2, 2), "#f4eee0", { noline = true }) end
  floorboards(c, 39, "#8a5a35", "#6b3b2a")
  part(c, R(c, 0, 37, W - 1, 41), "#d9a660"); fl(c, R(c, 0, 37, W - 1, 37), "#e8c48a")
  -- tray of peppers like lanterns
  local function pepper(x, col, hi, cheese)
    part(c, c:rrect(x, 29, x + 7, 39, 3), col); fl(c, R(c, x + 1, 31, x + 1, 36), hi)
    part(c, R(c, x + 2, 27, x + 5, 29), "#4e8a3c", { noline = true }); fl(c, R(c, x + 2, 29, x + 5, 30), cheese)
    c:px(x + 3, 29, "#4e8a3c")
  end
  pepper(32, "#dd3a2a", "#ff8a6a", "#f4eee0"); pepper(42, "#f5b02a", "#ffe08a", "#f4eee0"); pepper(52, "#6ab04a", "#a8d878", "#f4eee0"); pepper(61, "#dd3a2a", "#ff8a6a", "#f4eee0")
  part(c, R(c, 29, 39, 69, 40), "#aeb4bc")
  -- bowl of cheese
  part(c, c:rrect(8, 36, 20, 42, 3), "#f4eee0"); c:fill(c:ellipse(14, 36, 5, 1), "#fff8d8")
  part(c, c:rrect(4, 42, 68, 48, 0), "#a8703e")
  gnome(c, 19, 47, { d = 1, upper = true, s = 1.2, eyes = "open", arms = { arm({ 5, 8 }, { 10, 14 }, true) } })
  part(c, c:line({ { 26, 33 }, { 33, 28 } }, 1), "#aeb4bc", { noline = true }); fl(c, R(c, 32, 27, 35, 28), "#fff8d8")
  sparkle(c, 46, 22, "#fff8d8", "#f5cf6a")
  finish(c, "r_ee_stuffed_peppers")
end

-- 20. wax egg: kistka in the candle flame, painted eggs on the rack
function S.r_ee_wax_egg()
  seed = 80
  local c = new()
  wall(c, 36, "#c88a5a", "#b87a4a")
  fl(c, R(c, 0, 8, W - 1, 8), "#6b3b2a")
  -- rack of finished eggs
  part(c, R(c, 6, 22, 46, 23), "#6b4a2e")
  local cols = { { "#dd3a2a", "#f5cf6a" }, { "#3f6fb0", "#f4eee0" }, { "#e8a317", "#c0442e" }, { "#4e8a3c", "#f5cf6a" }, { "#7a3a8a", "#f4eee0" } }
  for i, cc in ipairs(cols) do
    local x = 8 + (i - 1) * 8
    part(c, c:ellipse(x, 18, 3, 4), cc[1]); fl(c, R(c, x - 2, 17, x + 2, 17), cc[2]); c:px(x, 15, cc[2]); c:px(x, 19, cc[2])
  end
  fl(c, R(c, 0, 37, W - 1, H - 1), "#7a4a2a"); fl(c, R(c, 0, 37, W - 1, 38), "#a8703e")
  -- dye cups
  for i, col in ipairs({ "#dd3a2a", "#3f6fb0", "#e8a317" }) do
    local x = 8 + (i - 1) * 8
    part(c, R(c, x, 41, x + 5, 47), "#f4eee0"); fl(c, R(c, x + 1, 42, x + 4, 43), col)
  end
  -- candle
  part(c, R(c, 56, 34, 59, 46), "#f4eee0"); fl(c, R(c, 57, 36, 57, 46), "#e8dcc0")
  part(c, c:poly({ { 57, 27 }, { 60, 33 }, { 56, 33 } }), "#f08a24"); c:fill(c:poly({ { 57, 30 }, { 58, 33 }, { 56, 33 } }), "#ffe08a")
  part(c, c:ellipse(57, 47, 6, 2), "#8a5a35")
  gnome(c, 38, 47, { d = 1, upper = true, s = 1.25, eyes = "open", arms = { arm({ 5, 7 }, { 8, 12 }, true), arm({ -4, 6 }, { 5, 11 }, true) } })
  -- egg held in the hand, stylus to the flame
  local ex, ey = 52, 33
  part(c, c:ellipse(ex, ey, 4, 5), "#f4eee0"); fl(c, R(c, ex - 3, ey - 1, ex + 3, ey - 1), "#dd3a2a"); fl(c, R(c, ex - 3, ey + 1, ex + 3, ey + 1), "#dd3a2a")
  for k = -3, 3, 2 do c:px(ex + k, ey - 2, "#dd3a2a"); c:px(ex + k, ey + 2, "#dd3a2a") end
  fl(c, R(c, 47, 31, 47, 31), "#f0c8a0")
  sparkle(c, 62, 24, "#fff1c8", "#f5cf6a")
  finish(c, "r_ee_wax_egg")
end

-- 21. stork wheel: gnome up a ladder lifting an old cart wheel onto a pole, a stork circling
function S.r_ee_stork_wheel()
  seed = 81
  local c = new()
  day(c, 38, { sky = { "#98cce6", "#b0daec", "#cae8ee" }, cloud = 52, hill = "#6a9a4c", hill2 = "#58884a" })
  -- pole
  part(c, R(c, 40, 14, 43, 47), "#6b4a2e")
  -- wheel on top
  part(c, c:ellipse(42, 12, 12, 4), "#a8703e", { shade = true }); c:fill(c:ellipse(42, 12, 8, 2), "#d9a660")
  for k = -2, 2 do fl(c, c:line({ { 42, 12 }, { 42 + k * 4, 12 + (k % 2) } }, 1), "#8a5a35") end
  for _, p in ipairs({ { 36, 10 }, { 44, 9 }, { 40, 8 }, { 47, 11 }, { 35, 12 } }) do fl(c, R(c, p[0 + 1], p[2], p[1] + 2, p[2]), "#8a5a35") end
  -- ladder and gnome
  part(c, c:line({ { 22, 47 }, { 38, 18 } }, 2), "#a8703e", { noline = true }); part(c, c:line({ { 28, 47 }, { 44, 18 } }, 2), "#a8703e", { noline = true })
  for k = 0, 4 do local y = 44 - k * 6; local x0 = 22 + (47 - y) * 16 // 29; fl(c, R(c, x0, y, x0 + 6, y), "#c89050") end
  gnome(c, 30, 34, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 8, 15 }, true), arm({ -4, 8 }, { -6, 12 }, false) } })
  fl(c, R(c, 36, 17, 40, 18), "#8a5a35")
  stork(c, 60, 14, true)
  c:px(54, 21, "#f4eee0")
  for _, p in ipairs({ { 8, 46 }, { 56, 44 }, { 64, 47 } }) do c:fill(c:ellipse(p[1], p[2], 2, 1), "#9cc070") end
  part(c, c:ellipse(12, 44, 6, 3), "#6a9a4c"); part(c, R(c, 52, 42, 66, 47), "#b07a45")
  part(c, c:ellipse(58, 41, 6, 6), "#a8703e"); c:fill(c:ellipse(58, 41, 4, 4), "#d9a660"); c:fill(c:ellipse(58, 41, 1, 1), "#6b4a2e")
  finish(c, "r_ee_stork_wheel")
end

-- 22. hay rick: summer, pitching hay up around the pole
function S.r_ee_hay_rick()
  seed = 82
  local c = new()
  day(c, 32, { sky = { "#9cd0ea", "#b4dcee", "#d0eaee" }, cloud = 14, hill = "#a8a050", hill2 = "#98a048", grass = "#d8bc5a", edge = "#ecd078" })
  for y = 36, 49, 4 do for x = (y * 3) % 9, W - 1, 9 do c:fill(R(c, x, y, x + 4, y), "#c8a848") end end
  -- the rick
  part(c, c:poly({ { 46, 4 }, { 57, 28 }, { 62, 40 }, { 62, 47 }, { 30, 47 }, { 30, 40 }, { 35, 28 } }), "#e0b84a", { shade = true })
  c:fill(c:ellipse(46, 40, 16, 3), "#d0a83a")
  for _, p in ipairs({ { 40, 30 }, { 50, 33 }, { 36, 40 }, { 46, 38 }, { 55, 42 }, { 44, 22 }, { 49, 26 } }) do fl(c, R(c, p[1], p[2], p[1] + 4, p[2]), "#f4d870"); fl(c, R(c, p[1] + 1, p[2] + 1, p[1] + 3, p[2] + 1), "#b8902a") end
  fl(c, R(c, 45, 1, 46, 6), "#6b4a2e")
  gnome(c, 18, 47, { d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -5, 4 }, false), arm({ 4, 8 }, { 9, 12 }, true) } })
  -- pitchfork with a heap of hay
  part(c, c:line({ { 25, 36 }, { 35, 20 } }, 1), "#8a5a35", { noline = true })
  part(c, c:ellipse(36, 17, 5, 3), "#e0b84a", { noline = true }); fl(c, R(c, 33, 16, 38, 16), "#f4d870")
  for _, p in ipairs({ { 30, 14 }, { 41, 15 }, { 33, 11 }, { 27, 19 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#f4d870") end
  part(c, c:ellipse(8, 46, 6, 2), "#e0b84a", { noline = true })
  fl(c, R(c, 62, 44, 66, 44), "#f4d870"); fl(c, R(c, 60, 46, 65, 46), "#c8a848")
  finish(c, "r_ee_hay_rick")
end

-- 23. reed thatch: boathouse roof half golden, gnome tying on a bundle
function S.r_ee_reed_thatch()
  seed = 83
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 32), { "#b4d8e4", "#c8e2e8", "#dcecec" }, { dir = "v" })
  c:fill(R(c, 0, 33, W - 1, H - 1), "#5a9aa0")
  for y = 36, 48, 4 do fl(c, R(c, (y * 5) % 17 + 40, y, (y * 5) % 17 + 48, y), "#8accd0") end
  c:fill(c:ellipse(60, 33, 20, 3), "#6a9a58")
  for x = 52, 68, 3 do fl(c, R(c, x, 22, x, 33), "#8aae52") end
  -- jetty
  part(c, R(c, 4, 44, 50, 47), "#a8703e"); fl(c, R(c, 4, 44, 50, 44), "#c89050")
  for x = 8, 48, 12 do part(c, R(c, x, 47, x + 1, 50), "#5e3f28", { noline = true }) end
  -- boathouse wall
  part(c, R(c, 10, 30, 42, 44), "#8a5a35")
  for x = 14, 40, 4 do fl(c, R(c, x, 31, x, 43), "#6b3b2a") end
  part(c, R(c, 20, 34, 32, 44), "#2a1a10")
  -- roof: old grey half and new golden half
  local roof = c:poly({ { 6, 31 }, { 26, 12 }, { 46, 31 } })
  part(c, roof, "#8a8a68")
  c:fill(c:poly({ { 6, 31 }, { 26, 12 }, { 46, 31 } }):clip(R(c, 27, 0, 60, 40)), "#e0b84a")
  local rp = { { 6, 31 }, { 26, 12 }, { 46, 31 } }
  for y = 16, 30, 3 do fl(c, R(c, 27 + (y % 2), y, 46, y):clip(c:poly(rp)), "#b8902a") end
  for y = 18, 28, 3 do fl(c, R(c, 6, y, 25, y):clip(c:poly(rp)), "#6a6a50") end
  for _, p in ipairs({ { 29, 19 }, { 33, 22 }, { 36, 25 }, { 31, 27 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]):clip(c:poly(rp)), "#f4d870") end
  fl(c, R(c, 25, 11, 27, 12), "#8a5a35")
  -- gnome on the roof ridge side, bundles on the jetty
  part(c, c:poly({ { 54, 47 }, { 56, 34 }, { 60, 34 }, { 62, 47 } }), "#e0b84a"); fl(c, R(c, 55, 40, 61, 40), "#c0442e")
  part(c, c:poly({ { 62, 47 }, { 63, 38 }, { 66, 38 }, { 68, 47 } }), "#d0a83a"); fl(c, R(c, 63, 42, 67, 42), "#c0442e")
  gnome(c, 30, 44, { d = 1, eyes = "open", arms = { arm({ -4, 8 }, { -5, 12 }, true), arm({ 4, 8 }, { 8, 14 }, true) } })
  part(c, c:poly({ { 37, 31 }, { 40, 29 }, { 44, 28 }, { 44, 31 }, { 40, 33 } }), "#f4d870"); fl(c, R(c, 38, 30, 38, 31), "#c0442e")
  finish(c, "r_ee_reed_thatch")
end

-- 24. stork, frog, reed: hand game on the landing
function S.r_ee_stork_frog_reed()
  seed = 84
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#b8dce0", "#cde6e2", "#e0efe4" }, { dir = "v" })
  c:fill(R(c, 0, 28, W - 1, H - 1), "#5a9aa0")
  for y = 30, 40, 4 do fl(c, R(c, (y * 5) % 17 + 40, y, (y * 5) % 17 + 48, y), "#8accd0") end
  for i = 0, 7 do local x = 6 + i * 3 + (i % 3); fl(c, R(c, x, 14 + (i % 3) * 2, x, 28), "#8aae52"); if i % 3 == 0 then fl(c, R(c, x, 12, x, 15), "#6b3b2a") end end
  for i = 0, 5 do local x = 52 + i * 3; fl(c, R(c, x, 15 + (i % 2) * 3, x, 28), "#7aa04a") end
  part(c, R(c, 4, 40, 68, 44), "#a8703e"); fl(c, R(c, 4, 40, 68, 40), "#c89050")
  for x = 12, 62, 10 do fl(c, R(c, x, 41, x, 43), "#6b3b2a") end
  part(c, R(c, 8, 44, 9, 49), "#5e3f28", { noline = true }); part(c, R(c, 62, 44, 63, 49), "#5e3f28", { noline = true })
  -- the three cards on a line above
  local function card(x, bg) part(c, R(c, x, 8, x + 11, 20), bg) end
  card(14, "#e8f0d8"); card(30, "#e8f0d8"); card(46, "#e8f0d8")
  -- stork card
  fl(c, R(c, 17, 14, 22, 15), "#f8f4ec"); fl(c, R(c, 22, 13, 24, 13), "#dd3a2a"); fl(c, R(c, 18, 16, 18, 19), "#dd3a2a"); fl(c, R(c, 20, 16, 20, 19), "#dd3a2a"); c:px(17, 13, "#2a1a10")
  fl(c, R(c, 19, 10, 21, 13), "#f8f4ec"); c:px(20, 10, INK)
  -- frog card
  part(c, c:ellipse(36, 16, 4, 3), "#4e9a48", { noline = true }); fl(c, R(c, 33, 12, 34, 13), "#4e9a48"); fl(c, R(c, 38, 12, 39, 13), "#4e9a48"); c:px(33, 12, INK); c:px(39, 12, INK); fl(c, R(c, 34, 17, 38, 17), "#8fc462")
  -- reed card
  for x = 50, 54, 2 do fl(c, R(c, x, 11, x, 19), "#7aa04a"); fl(c, R(c, x, 10, x, 13), "#6b3b2a") end
  gnome(c, 22, 40, { d = 1, hat = nil, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 9, 11 }, true) } })
  gnome(c, 50, 40, { d = -1, hat = "#e8a317", eyes = "open", arms = { arm({ 4, 6 }, { 5, 3 }, false), arm({ -4, 8 }, { -9, 11 }, true) } })
  sparkle(c, 36, 34, "#fff1c8", "#f5cf6a")
  finish(c, "r_ee_stork_frog_reed")
end

local order = {}
for k in pairs(S) do order[#order + 1] = k end
table.sort(order)
for _, s2 in ipairs(order) do
  if not only or (("," .. only .. ","):find("," .. s2 .. ",", 1, true)) then seed = 7; S[s2]() end
end
