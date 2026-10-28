-- variety-act-g15.lua : Do-tab scenes for 15 w3 rest-stop activities -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g15.lua   (params BEFORE --script)
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

---------------------------------------------------------------- shared scene bits
local function water(c, y0, cols, hl)
  c:bands(R(c, 0, y0, W - 1, H - 1), cols or { "#5a9cc4", "#4a8ab8", "#3f7aa8", "#366a98" }, { dir = "v" })
  hl = hl or "#8fc8e0"
  for i = 1, 18 do
    local x, y = floor(rand() * 64) + 3, y0 + 2 + floor(rand() * (H - y0 - 4))
    c:fill(R(c, x, y, x + 1 + (i % 2), y), hl)
  end
end
local function lakeday(c, hor, o)
  o = o or {}
  c:bands(R(c, 0, 0, W - 1, hor), o.sky or { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  if o.cloud then c:fill(c:ellipse(o.cloud, 9, 8, 2), "#f4eee0"); c:fill(c:ellipse(o.cloud + 4, 7, 5, 2), "#f4eee0") end
  c:fill(c:ellipse(14, hor + 1, 30, 7), o.hill or "#5e8a44"); c:fill(c:ellipse(62, hor + 2, 26, 6), o.hill2 or "#4e8a3c")
  water(c, hor + 2, o.wcols)
end
local function bee(c, x, y)
  c:px(x, y, "#f5cf6a"); c:px(x + 1, y, "#2a1a10"); c:px(x + 2, y, "#f5cf6a"); c:px(x + 1, y - 1, "#e8f4f8")
end
local function reedclump(c, x, yb, h, n)
  for i = 0, n - 1 do
    local dx = (i - (n - 1) / 2) * 2
    local hh = h - (i % 2) * 3
    fl(c, R(c, x + rnd(dx), yb - hh, x + rnd(dx), yb), "#6a8a3a")
    if i % 2 == 0 then fl(c, R(c, x + rnd(dx), yb - hh - 2, x + rnd(dx), yb - hh + 1), "#7a4a2a") end
  end
end

---------------------------------------------------------------- scenes
local S = {}

-- 1. jetty_boats: gnome at the end of the jetty pointing at three differently shaped boats
function S.w3_jetty_boats()
  seed = 61
  local c = new()
  lakeday(c, 25, { cloud = 14 })
  -- sailing dinghy with a triangular sail (far)
  part(c, c:poly({ { 24, 33 }, { 40, 33 }, { 37, 37 }, { 27, 37 } }), "#f4eee0")
  fl(c, R(c, 25, 34, 39, 34), "#3f6fb0")
  fl(c, R(c, 31, 20, 31, 33), "#6b4a2e")
  part(c, c:poly({ { 32, 21 }, { 38, 31 }, { 32, 31 } }), "#f4eee0")
  fl(c, R(c, 28, 26, 30, 31), "#dd3a2a")
  -- coracle: a round basket boat
  part(c, c:ellipse(12, 33, 6, 3), "#a8703e", { shade = true })
  c:fill(c:ellipse(12, 32, 5, 1), "#6b3b2a")
  fl(c, R(c, 7, 34, 17, 34), "#8a5a35")
  -- canoe, long and pointed, striped
  part(c, c:poly({ { 8, 42 }, { 16, 39 }, { 32, 39 }, { 42, 42 }, { 36, 45 }, { 14, 45 } }), "#3f8fb0")
  fl(c, R(c, 14, 42, 36, 42), "#f4eee0")
  -- jetty
  part(c, R(c, 47, 36, 68, 40), "#a8703e")
  fl(c, R(c, 48, 37, 67, 37), "#d9a660")
  for _, x in ipairs({ 52, 58, 64 }) do fl(c, R(c, x, 38, x, 40), "#6b3b2a") end
  for _, x in ipairs({ 50, 60, 67 }) do part(c, R(c, x, 41, x + 1, 49), "#5e3f28", { noline = true }) end
  -- mooring rope
  fl(c, c:line({ { 50, 40 }, { 44, 44 }, { 40, 46 } }, 1), "#e0c88a")
  -- gnome at the end of the jetty, pointing out
  gnome(c, 54, 36, { d = -1, eyes = "open", arms = { arm({ -4, 8 }, { -10, 11 }, false), arm({ 4, 7 }, { 5, 4 }, true) } })
  finish(c, "w3_jetty_boats")
end

-- 2. bobbing_float: five floats on the water, one bobs; gnome on the bank points at his pick
function S.w3_bobbing_float()
  seed = 62
  local c = new()
  lakeday(c, 15, { cloud = 50, sky = { "#b4dcea", "#c6e4ea", "#d6ece8" } })
  -- bank with grass and the gnome
  c:fill(c:poly({ { 0, 41 }, { 22, 41 }, { 30, 50 }, { 0, 50 } }), "#7ea85a")
  c:fill(R(c, 0, 41, 22, 41), "#9cc070")
  local xs = { 28, 36, 44, 52, 60 }
  local ys = { 30, 34, 29, 35, 31 }
  for i, x in ipairs(xs) do
    local y = ys[i]
    local up = (i == 3)
    if up then y = y - 3 end
    fl(c, R(c, x, 6, x, y - 1), "#e8f0f0")
    -- float: red top, white bottom, tiny stem
    part(c, c:ellipse(x, y + 1, 1, 2), "#dd3a2a", { noline = true })
    c:px(x, y + 2, "#f4eee0"); c:px(x, y + 3, "#f4eee0")
    c:px(x - 1, y, "#ff8a6a")
    local wy = (up and ys[i] or ys[i]) + 3
    -- ripples
    local rr = up and 3 or 1
    fl(c, R(c, x - rr - 1, wy + 1, x + rr + 1, wy + 1), "#a8dcec")
    if up then fl(c, R(c, x - 5, wy + 2, x + 5, wy + 2), "#8fc8e0"); fl(c, R(c, x - 7, wy + 3, x + 7, wy + 3), "#6aaed0") end
  end
  -- splash drops around the bobbing float
  for _, p in ipairs({ { 41, 23 }, { 47, 24 }, { 44, 21 }, { 39, 26 }, { 49, 27 } }) do c:px(p[1], p[2], "#f4f8fa") end
  gnome(c, 13, 47, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 14 }, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  -- the wager toffee
  part(c, R(c, 3, 44, 5, 45), "#e8a317", { noline = true }); c:px(2, 44, "#f5cf6a"); c:px(6, 44, "#f5cf6a")
  finish(c, "w3_bobbing_float")
end

-- 3. reed_oar: foggy bank, three reed beds, an oar with a duck on it in one, gnome peering
function S.w3_reed_oar()
  seed = 63
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 24), { "#c4cece", "#cfd8d8", "#d9e0de", "#e2e8e4" }, { dir = "v" })
  c:fill(c:ellipse(40, 24, 24, 4), "#b4c0c0")
  water(c, 25, { "#a8bcc4", "#9ab0ba", "#8ea6b2", "#849eac" }, "#c4d4d8")
  -- bank
  c:fill(c:ellipse(10, 49, 24, 8), "#7a9a58"); c:fill(R(c, 0, 46, 22, 53), "#7a9a58"); c:fill(R(c, 0, 45, 14, 45), "#92b068")
  -- reed beds
  reedclump(c, 30, 40, 15, 5)
  reedclump(c, 46, 41, 17, 6)
  reedclump(c, 62, 40, 14, 5)
  c:fill(c:ellipse(30, 41, 5, 1), "#7a8a4a"); c:fill(c:ellipse(46, 42, 6, 1), "#7a8a4a"); c:fill(c:ellipse(62, 41, 5, 1), "#7a8a4a")
  -- fog banks (kept low so the oar stays readable)
  for _, b in ipairs({ { 22, 35, 36, 38 }, { 38, 40, 58, 43 }, { 2, 30, 24, 32 }, { 46, 22, 70, 24 } }) do
    c:fill(c:ellipse((b[1] + b[3]) // 2, (b[2] + b[4]) // 2, (b[3] - b[1]) // 2, (b[4] - b[2]) // 2 + 1), "#dfe6e4")
  end
  for x = 8, 66, 5 do c:px(x, 26 + (x % 3) * 2, "#eaf0ee") end
  -- the oar tangled in the right bed, with a duck on its shaft
  part(c, c:line({ { 52, 41 }, { 58, 27 } }, 2), "#d9a660")
  part(c, c:line({ { 59, 25 }, { 63, 12 } }, 3), "#c8802a")
  fl(c, c:line({ { 60, 23 }, { 63, 14 } }, 1), "#e8c48a")
  part(c, c:ellipse(54, 33, 4, 3), "#8a6a44", { shade = true })
  fl(c, R(c, 50, 33, 53, 34), "#b09468")
  fl(c, R(c, 57, 29, 58, 31), "#2f6a4a")
  fl(c, R(c, 59, 30, 60, 30), "#e8a317"); c:px(57, 29, "#1a1008")
  fl(c, R(c, 49, 42, 51, 43), "#7a8a4a")
  -- gnome peering with a hand to the brow
  gnome(c, 13, 46, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 7, 15 }, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  finish(c, "w3_reed_oar")
end

-- 4. crab_pot: gnome hauling a dripping wicker pot up on a rope; a claw waves from the pot
function S.w3_crab_pot()
  seed = 64
  local c = new()
  lakeday(c, 22, { cloud = 44, sky = { "#9ed0e2", "#b6dce6", "#cde8e8" } })
  -- far reed and a bobbing buoy
  part(c, c:ellipse(16, 30, 2, 2), "#dd3a2a", { noline = true }); c:px(16, 29, "#f4eee0")
  -- jetty top at the right
  part(c, R(c, 40, 34, 68, 38), "#a8703e")
  fl(c, R(c, 41, 35, 67, 35), "#d9a660")
  for _, x in ipairs({ 46, 52, 58, 64 }) do fl(c, R(c, x, 36, x, 38), "#6b3b2a") end
  for _, x in ipairs({ 42, 54, 66 }) do part(c, R(c, x, 39, x + 1, 49), "#5e3f28", { noline = true }) end
  -- the pot, half out of the water
  c:fill(c:ellipse(25, 44, 9, 2), "#a8dcec"); fl(c, R(c, 19, 44, 31, 44), "#d8f0f8")
  part(c, c:rrect(18, 31, 32, 43, 3), "#c8802a", { shade = true })
  for y = 34, 41, 3 do fl(c, R(c, 19, y, 31, y), "#8a4f2a") end
  for x = 21, 30, 3 do fl(c, R(c, x, 32, x, 42), "#8a4f2a") end
  fl(c, R(c, 23, 36, 26, 38), "#1a1008")
  -- crab claws poking out of the pot
  c:paint({ "r.r", "rrr", ".r." }, 19, 27, { r = "#e0501f" }); fl(c, R(c, 20, 30, 20, 31), "#e0501f")
  c:paint({ "r.r", "rrr", ".r." }, 28, 26, { r = "#e0501f" }); fl(c, R(c, 29, 29, 29, 31), "#e0501f")
  c:px(23, 33, "#ffd86a"); c:px(26, 33, "#ffd86a")
  -- drips
  for _, p in ipairs({ { 20, 44 }, { 25, 46 }, { 30, 45 }, { 18, 47 } }) do c:px(p[1], p[2], "#d8f0f8") end
  -- rope from the pot top up to the gnome's hands
  fl(c, c:line({ { 25, 30 }, { 25, 26 }, { 34, 22 }, { 42, 21 } }, 1), "#e0c88a")
  gnome(c, 50, 34, { d = -1, eyes = "shut", arms = { arm({ -4, 9 }, { -9, 12 }, false), arm({ 3, 8 }, { -6, 10 }, true) } })
  -- the rope reaches both hands; a coil of spare line at his feet
  part(c, c:ellipse(60, 33, 4, 1), "#e0c88a", { noline = true })
  finish(c, "w3_crab_pot")
end

-- 5. upturned_boat: dusk, anglers sit along an upturned hull mending lines
function S.w3_upturned_boat()
  seed = 65
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#3b2f66", "#6a3e7e", "#a24e80", "#d86e6a", "#f0925e", "#f6b472" }, { dir = "v" })
  for _, p in ipairs({ { 8, 8 }, { 20, 5 }, { 36, 9 }, { 58, 7 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(c:ellipse(50, 30, 6, 3), "#ffd48a")
  c:fill(R(c, 0, 31, W - 1, 38), "#4a3a6e")
  for x = 2, 66, 6 do c:fill(R(c, x, 33 + (x % 4), x + 3, 33 + (x % 4)), "#f08a62") end
  c:fill(R(c, 0, 39, W - 1, H - 1), "#a89070")
  c:fill(R(c, 0, 39, W - 1, 39), "#c0a684")
  for _, p in ipairs({ { 6, 46 }, { 14, 49 }, { 52, 47 }, { 64, 49 }, { 36, 48 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2]), "#8a7456") end
  -- upturned hull
  local hull = c:poly({ { 5, 24 }, { 9, 24 }, { 13, 30 }, { 22, 29 }, { 50, 29 }, { 61, 31 }, { 64, 37 }, { 64, 47 }, { 6, 47 }, { 6, 33 } })
  part(c, hull, "#3a4a6a", { shade = true })
  fl(c, R(c, 14, 31, 58, 31), "#4a5e84"); fl(c, R(c, 8, 36, 62, 36), "#2c3a56"); fl(c, R(c, 7, 41, 63, 41), "#2c3a56")
  fl(c, R(c, 14, 29, 50, 29), "#6a2a1e")
  fl(c, c:line({ { 6, 33 }, { 10, 31 }, { 13, 30 } }, 1), "#6a2a1e")
  c:fill(R(c, 4, 47, 66, 48), "#6a5a44")
  -- lantern on a post at the right
  part(c, R(c, 66, 22, 66, 40), "#3d2a1c", { noline = true }); part(c, R(c, 64, 17, 68, 22), "#ffd86a")
  -- net draped over the stern
  for x = 52, 61 do for y = 31, 44 do if (x + y) % 3 == 0 then c:px(x, y, "#c8a46a") end end end
  -- storyteller, hand up
  gnome(c, 22, 30, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 7, 15 }, true) } })
  -- mender with a green hat, line sagging from his hands
  gnome(c, 42, 30, { d = -1, sit = true, hat = "#4f9a45", eyes = "shut", arms = { arm({ -3, 7 }, { -7, 5 }, true) } })
  fl(c, c:line({ { 31, 28 }, { 34, 32 }, { 36, 33 } }, 1), "#e8d8b0")
  finish(c, "w3_upturned_boat")
end

-- 6. swarm_home: summer, bees hang from the gooseberry bush; gnome holds up a skep and hums
function S.w3_swarm_home()
  seed = 66
  local c = new()
  day(c, 35, { cloud = 14, sky = { "#9ed0ea", "#b4dcee", "#cce8ee" } })
  c:fill(c:ellipse(64, 12, 4, 4), "#f8e48a")
  -- gooseberry bush, branches and berries
  part(c, c:ellipse(53, 30, 15, 11), "#3f8a42", { shade = true })
  part(c, R(c, 52, 38, 54, 47), "#6b4a2e", { noline = true })
  for _, p in ipairs({ { 42, 27 }, { 48, 22 }, { 58, 24 }, { 63, 31 }, { 56, 35 }, { 45, 33 } }) do
    part(c, c:ellipse(p[1], p[2], 2, 2), "#b8d878", { noline = true }); c:px(p[1] - 1, p[2] - 1, "#e8f4b8")
  end
  -- the hanging swarm, a buzzing beard
  local sw = c:poly({ { 46, 31 }, { 58, 31 }, { 56, 38 }, { 52, 44 }, { 48, 38 } })
  part(c, sw, "#7a5a22")
  sw:each(function(x, y) local h = (x * 7 + y * 13) % 11; if h == 0 then c:px(x, y, "#f5cf6a") elseif h == 3 then c:px(x, y, "#2a1a10") elseif h == 6 then c:px(x, y, "#d9a640") end end)
  for _, p in ipairs({ { 40, 24 }, { 62, 38 }, { 43, 42 }, { 38, 32 }, { 58, 44 }, { 35, 38 } }) do bee(c, p[1], p[2]) end
  -- the skep, held mouth-up below the swarm
  local _, G = gnome(c, 22, 48, { d = 1, eyes = "shut", arms = { arm({ 4, 8 }, { 9, 11 }, true, true), arm({ -4, 6 }, { 2, 12 }, false, true) } })
  local sx, sy = G.P(10, 12)
  part(c, c:ellipse(sx + 3, sy + 1, 6, 5), "#d9a660", { shade = true })
  c:fill(c:ellipse(sx + 3, sy - 1, 5, 1), "#4a2c1a")
  for _, dy in ipairs({ 1, 3 }) do fl(c, R(c, sx - 2, sy + dy, sx + 8, sy + dy), "#b8803a") end
  fl(c, R(c, sx - 2, sy - 3, sx + 8, sy - 3), "#e8c48a")
  fl(c, R(c, sx - 1, sy + 3, sx, sy + 4), "#f0c8a0"); fl(c, R(c, sx + 7, sy + 3, sx + 8, sy + 4), "#f0c8a0")
  -- humming notes
  for _, p in ipairs({ { 14, 22 }, { 9, 27 } }) do
    fl(c, R(c, p[1], p[2] + 3, p[1] + 1, p[2] + 4), "#2a1a10"); fl(c, R(c, p[1] + 1, p[2], p[1] + 1, p[2] + 3), "#2a1a10"); c:px(p[1] + 2, p[2], "#2a1a10")
  end
  finish(c, "w3_swarm_home")
end

-- 7. pot_cuttings: spring; gnome behind a potting bench holds up a cutting, row of tiny pots, tray of shoots
function S.w3_pot_cuttings()
  seed = 67
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 20), { "#b8dcea", "#cce6ea", "#dcecea" }, { dir = "v" })
  -- hedge backdrop
  c:fill(R(c, 0, 17, W - 1, 38), "#4e8a3c")
  for x = 2, 70, 6 do c:fill(c:ellipse(x, 17, 4, 3), "#4e8a3c") end
  for _, p in ipairs({ { 6, 24 }, { 20, 22 }, { 34, 26 }, { 48, 22 }, { 60, 27 }, { 66, 20 } }) do
    c:fill(R(c, p[1], p[2], p[1] + 2, p[2] + 1), "#3f7a34"); c:px(p[1] + 3, p[2] - 1, "#6aa84a")
  end
  -- blossom branch in the top corner
  fl(c, c:line({ { 68, 5 }, { 60, 8 }, { 52, 6 } }, 1), "#6b4a2e")
  for _, p in ipairs({ { 66, 7 }, { 62, 9 }, { 58, 7 }, { 54, 7 }, { 64, 5 } }) do
    c:px(p[1], p[2], "#f6b8cf"); c:px(p[1] + 1, p[2], "#f6b8cf"); c:px(p[1], p[2] + 1, "#e46a9b"); c:px(p[1] - 1, p[2], "#fde4ee")
  end
  c:fill(R(c, 0, 39, W - 1, H - 1), "#7ea85a"); c:fill(R(c, 0, 44, W - 1, H - 1), "#6a9650")
  -- bench
  gnome(c, 16, 40, { d = 1, upper = true, eyes = "open", arms = { arm({ 5, 8 }, { 9, 13 }, true) } })
  part(c, R(c, 2, 38, 68, 41), "#b07a45")
  fl(c, R(c, 3, 38, 67, 38), "#d9a660")
  part(c, R(c, 4, 42, 66, 43), "#8a5a35", { noline = true })
  part(c, R(c, 6, 43, 8, 49), "#8a5a35", { noline = true }); part(c, R(c, 62, 43, 64, 49), "#8a5a35", { noline = true })
  -- the sprig being held up
  local sx, sy = 25, 27
  fl(c, R(c, sx, sy - 5, sx, sy + 2), "#5e8a3a")
  for _, p in ipairs({ { -2, -4 }, { 1, -6 }, { -2, -1 }, { 1, -2 } }) do fl(c, R(c, sx + p[1], sy + p[2], sx + p[1] + 1, sy + p[2]), "#7ab55c") end
  -- tray of cuttings
  part(c, R(c, 28, 35, 40, 37), "#a8703e")
  for _, x in ipairs({ 29, 31, 33, 35, 37 }) do fl(c, R(c, x, 30 + (x % 3), x, 34), "#5e8a3a"); fl(c, R(c, x - 1, 30 + (x % 3), x + 1, 31 + (x % 3)), "#7ab55c") end
  -- row of tiny terracotta pots: three planted, one half-filled
  for i = 0, 3 do
    local x = 44 + i * 6
    part(c, c:poly({ { x, 34 }, { x + 5, 34 }, { x + 4, 38 }, { x + 1, 38 } }), "#c4623a")
    fl(c, R(c, x, 34, x + 4, 34), "#dd8050")
    fl(c, R(c, x + 1, 35, x + 3, 35), "#4a2c1a")
    if i < 3 then
      fl(c, R(c, x + 2, 29, x + 2, 34), "#5e8a3a")
      fl(c, R(c, x + 0, 30 + (i % 2), x + 1, 31 + (i % 2)), "#7ab55c"); fl(c, R(c, x + 3, 29, x + 4, 30), "#7ab55c")
    end
  end
  c:px(66, 36, "#4a2c1a"); c:px(67, 35, "#4a2c1a")
  finish(c, "w3_pot_cuttings")
end

-- 8. mystery_weed: gnome squats in the thyme bed and peers at a strange weed through a hand lens
function S.w3_mystery_weed()
  seed = 68
  local c = new()
  day(c, 27, { cloud = 46, hill = "#5e8a44", hill2 = "#4e8a3c" })
  -- fence
  for x = 3, 70, 5 do part(c, R(c, x, 20, x + 2, 30), "#d9bc84", { noline = true }); fl(c, R(c, x, 20, x + 2, 20), "#e8d4a0") end
  fl(c, R(c, 0, 24, W - 1, 25), "#b8965c")
  -- herb bed soil with thyme cushions
  c:fill(R(c, 0, 31, W - 1, H - 1), "#6b4a2e"); c:fill(R(c, 0, 31, W - 1, 31), "#8a6240")
  for _, p in ipairs({ { 6, 36 }, { 14, 44 }, { 40, 34 }, { 58, 36 }, { 30, 46 }, { 64, 45 }, { 52, 47 } }) do c:px(p[1], p[2], "#8a6240"); c:px(p[1] + 1, p[2], "#8a6240") end
  local function thyme(x, y)
    part(c, c:ellipse(x, y, 4, 2), "#4a7a4a", { noline = true })
    c:px(x - 2, y - 1, "#b8a0d8"); c:px(x + 1, y - 2, "#b8a0d8"); c:px(x + 2, y, "#b8a0d8"); c:px(x - 1, y, "#8fc090")
  end
  thyme(10, 38); thyme(36, 36); thyme(62, 40); thyme(8, 47); thyme(66, 47); thyme(32, 48)
  -- the weed: tall, jagged, with one lilac flower
  fl(c, R(c, 48, 22, 48, 41), "#5e8a3a")
  fl(c, c:line({ { 48, 36 }, { 43, 32 }, { 41, 27 } }, 1), "#5e8a3a")
  fl(c, c:line({ { 48, 32 }, { 53, 28 }, { 55, 24 } }, 1), "#5e8a3a")
  for _, p in ipairs({ { 38, 25 }, { 41, 29 }, { 50, 37 }, { 53, 25 }, { 54, 32 }, { 44, 38 } }) do
    part(c, c:poly({ { p[1], p[2] + 3 }, { p[1] + 2, p[2] }, { p[1] + 4, p[2] + 3 }, { p[1] + 2, p[2] + 2 } }), "#6aaa44", { noline = true })
    c:px(p[1] + 2, p[2] + 1, "#9acc66")
  end
  part(c, c:ellipse(48, 21, 3, 2), "#b890e0", { noline = true }); c:px(48, 21, "#f4eee0"); c:px(46, 20, "#dcc4f4")
  -- sparkles: it might be marvellous
  for _, p in ipairs({ { 55, 17 }, { 42, 18 }, { 62, 27 } }) do
    c:px(p[1], p[2], "#fff1c8"); c:px(p[1] - 1, p[2], "#f5cf6a"); c:px(p[1] + 1, p[2], "#f5cf6a"); c:px(p[1], p[2] - 1, "#f5cf6a"); c:px(p[1], p[2] + 1, "#f5cf6a")
  end
  -- label stake
  part(c, R(c, 66, 34, 66, 42), "#8a5a35", { noline = true }); part(c, R(c, 63, 32, 68, 35), "#f4eee0")
  -- gnome crouching with a hand lens
  local _, G = gnome(c, 22, 43, { d = 1, sit = true, eyes = "open", arms = { arm({ 3, 8 }, { 9, 10 }, true, true) } })
  local lx, ly = G.P(12, 12)
  fl(c, c:line({ { lx - 5, ly + 5 }, { lx - 1, ly + 1 } }, 1), "#6b4a2e")
  part(c, c:ellipse(lx + 2, ly - 1, 4, 4), "#8a5a35", { noline = true })
  c:fill(c:ellipse(lx + 2, ly - 1, 3, 3), "#bfe6f0"); c:px(lx, ly - 3, "#f4f8fa"); c:px(lx + 1, ly - 3, "#f4f8fa")
  fl(c, R(c, lx - 6, ly + 4, lx - 4, ly + 6), "#f0c8a0")
  finish(c, "w3_mystery_weed")
end

-- 9. frost_cloches: frosty dawn, gnome lowers a jar over a seedling; others already snug under glass
function S.w3_frost_cloches()
  seed = 69
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#a8bcd8", "#c0cce0", "#dcd4e4", "#f0d8d8", "#f8e4d0" }, { dir = "v" })
  c:fill(c:ellipse(60, 28, 4, 3), "#fff0c0")
  c:fill(c:ellipse(16, 30, 30, 6), "#c8d8e4"); c:fill(c:ellipse(60, 31, 24, 5), "#d4e2ec")
  c:fill(R(c, 0, 30, W - 1, H - 1), "#e4eef4")
  c:fill(R(c, 0, 30, W - 1, 30), "#f4f8fa")
  c:fill(R(c, 0, 40, W - 1, H - 1), "#d8e6ee")
  -- frosty hedge and bean sticks
  c:fill(c:ellipse(30, 32, 30, 3), "#a8c4c8"); c:fill(c:ellipse(56, 32, 20, 2), "#b4cccc")
  for x = 4, 66, 4 do c:px(x, 32 - (x % 3), "#f4f8fa") end
  -- soil row
  c:fill(R(c, 8, 46, 70, 48), "#8a7a8a"); c:fill(R(c, 8, 46, 70, 46), "#a898a8")
  local function seedling(x, shiver)
    fl(c, R(c, x, 41, x, 46), "#4a8a4a")
    fl(c, R(c, x - 2, 41, x - 1, 42), "#5aa65a"); fl(c, R(c, x + 1, 40, x + 2, 41), "#5aa65a"); fl(c, R(c, x - 1, 39, x, 39), "#5aa65a")
    if shiver then c:px(x - 4, 42, "#78a0e0"); c:px(x + 4, 41, "#78a0e0"); c:px(x - 5, 44, "#78a0e0"); c:px(x + 5, 43, "#78a0e0") end
  end
  local function jar(x, y0, y1)
    part(c, R(c, x - 3, y0, x + 3, y1), "#d4eef4")
    fl(c, R(c, x - 2, y0 + 1, x - 2, y1 - 2), "#f4fbfd"); fl(c, R(c, x + 2, y0 + 3, x + 2, y1 - 1), "#a8d4e0")
    fl(c, R(c, x - 1, y0 + 1, x + 1, y0 + 1), "#e8f6fa")
  end
  for _, x in ipairs({ 39, 48, 57 }) do jar(x, 38, 46); seedling(x) end
  seedling(65, true)
  seedling(28, true)
  -- the jar in the gnome's hands, being lowered over the shivering one
  local _, G = gnome(c, 14, 49, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 16 }, true, true), arm({ -4, 6 }, { 9, 10 }, false, true) } })
  local jx, jy = G.P(11, 15)
  jar(jx + 2, jy - 5, jy + 4)
  fl(c, R(c, jx - 2, jy - 1, jx - 1, jy), "#f0c8a0"); fl(c, R(c, jx - 2, jy + 3, jx - 1, jy + 4), "#f0c8a0")
  -- frost sparkle and steaming breath
  seed = 70
  for i = 1, 16 do local x, y = 6 + floor(rand() * 62), 33 + floor(rand() * 15); c:px(x, y, "#f4f8fa") end
  c:fill(c:ellipse(20, 33, 2, 1), "#f4f8fa"); c:fill(c:ellipse(23, 31, 1, 1), "#f4f8fa")
  finish(c, "w3_frost_cloches")
end

-- 10. nettle_sting: a small gnome yelps in the nettle patch, the helper holds out a dock leaf and salve
function S.w3_nettle_sting()
  seed = 71
  local c = new()
  day(c, 30, { cloud = 50, hill = "#5e8a44", hill2 = "#4e8a3c" })
  c:fill(R(c, 0, 31, W - 1, H - 1), "#4a7a38")
  -- the yelper, sitting in the patch, arms flailing
  gnome(c, 26, 44, { d = 1, sit = true, hat = "#e8a317", eyes = "shut", arms = { arm({ -3, 8 }, { -8, 15 }, true), arm({ 3, 8 }, { 8, 15 }, true) } })
  fl(c, R(c, 28, 31, 29, 32), "#3a1a14")
  -- kettle-like squeal marks
  for i = 0, 2 do
    fl(c, R(c, 16 + i, 22 + i * 3, 17 + i, 23 + i * 3), "#f4f8fa"); fl(c, R(c, 36 - i, 22 + i * 3, 37 - i, 23 + i * 3), "#f4f8fa")
  end
  -- nettle leaves all around, serrated and tall
  local function nettle(x, yb, h)
    fl(c, R(c, x, yb - h, x, yb), "#2f5a2a")
    for k = 0, h - 3, 3 do
      local y = yb - k
      local dir = ((k // 3) % 2 == 0) and -1 or 1
      for t = 1, 3 do fl(c, R(c, x + dir * t, y - t // 2 - 1, x + dir * t, y - t // 2 + 1), (t == 3) and "#4e8a3c" or "#2f7a38") end
      c:px(x + dir * 4, y - 3, "#4e8a3c"); c:px(x + dir * 3, y - 2, "#7ab55c")
    end
  end
  for _, p in ipairs({ { 4, 47, 12 }, { 10, 49, 8 }, { 17, 48, 10 }, { 33, 49, 11 }, { 40, 47, 9 }, { 62, 48, 12 }, { 47, 49, 7 }, { 21, 50, 6 }, { 67, 50, 9 }, { 29, 50, 5 } }) do nettle(p[1], p[2], p[3]) end
  -- helper with dock leaf and a jar of salve
  gnome(c, 52, 47, { d = -1, eyes = "open", arms = { arm({ -4, 8 }, { -9, 10 }, true, true), arm({ 4, 6 }, { 5, 3 }, false) } })
  part(c, c:ellipse(39, 33, 5, 3), "#4e9a3c", { noline = true })
  fl(c, R(c, 35, 33, 43, 33), "#8fd070"); fl(c, c:line({ { 38, 31 }, { 40, 29 } }, 1), "#8fd070"); fl(c, c:line({ { 38, 35 }, { 40, 37 } }, 1), "#8fd070")
  fl(c, R(c, 42, 36, 43, 38), "#f0c8a0")
  part(c, R(c, 56, 41, 60, 44), "#aeb4bc"); fl(c, R(c, 56, 40, 60, 40), "#3f6fb0")
  finish(c, "w3_nettle_sting")
end

-- 11. goat_in_sage: goat munches the sage through the hedge gap; gnome offers a carrot
function S.w3_goat_in_sage()
  seed = 72
  local c = new()
  day(c, 30, { cloud = 52, hill = "#5e8a44", hill2 = "#4e8a3c" })
  -- hedge with a gap
  c:fill(R(c, 0, 20, W - 1, 33), "#2f6a32")
  for x = 3, 70, 5 do c:fill(c:ellipse(x, 20, 3, 2), "#2f6a32") end
  for _, p in ipairs({ { 3, 23 }, { 26, 22 }, { 50, 24 }, { 60, 21 }, { 36, 27 }, { 66, 28 }, { 9, 29 } }) do c:fill(R(c, p[1], p[2], p[1] + 2, p[2]), "#4e8a3c") end
  c:fill(R(c, 17, 18, 24, 34), "#7ea85a"); c:fill(R(c, 17, 30, 24, 34), "#6a9650")
  part(c, R(c, 16, 24, 16, 34), "#6b4a2e", { noline = true }); part(c, R(c, 25, 26, 25, 34), "#6b4a2e", { noline = true })
  -- bed
  c:fill(R(c, 0, 35, W - 1, H - 1), "#7a5a3a"); c:fill(R(c, 0, 35, W - 1, 35), "#9a7a52")
  local function sage(x, y, rx, ry)
    part(c, c:ellipse(x, y, rx, ry), "#8aa890", { shade = true })
    for i = -1, 1 do c:px(x + i * rx // 2, y - ry + 1, "#b8d0b8"); c:px(x + i * rx // 2, y - ry - 1, "#a890c8") end
  end
  sage(60, 42, 7, 4); sage(30, 43, 4, 2); sage(8, 44, 5, 3); sage(66, 48, 4, 2)
  -- the goat, head down in the sage
  sage(31, 45, 5, 3)
  for _, x in ipairs({ 42, 46, 53, 57 }) do
    part(c, R(c, x, 43, x + 1, 49), "#efe6d2", { noline = true }); fl(c, R(c, x, 48, x + 1, 49), "#4a3a2a")
  end
  part(c, c:rrect(42, 33, 59, 43, 4), "#efe6d2", { shade = true })
  fl(c, R(c, 45, 34, 56, 34), "#fffaf0"); fl(c, R(c, 44, 41, 57, 41), "#d8c8a8")
  part(c, c:poly({ { 42, 34 }, { 46, 34 }, { 42, 44 }, { 36, 44 } }), "#efe6d2", { noline = true })
  part(c, c:rrect(30, 42, 38, 48, 2), "#efe6d2", { shade = true })
  fl(c, R(c, 30, 46, 31, 47), "#8a7a68"); c:px(34, 44, "#2a1a10")
  fl(c, R(c, 32, 49, 33, 49), "#6a5a48")
  part(c, c:line({ { 35, 42 }, { 37, 38 }, { 40, 35 } }, 2), "#7a6a48", { noline = true }); fl(c, R(c, 40, 34, 42, 34), "#7a6a48")
  fl(c, R(c, 38, 41, 39, 42), "#d8c8a8")
  fl(c, c:line({ { 59, 36 }, { 61, 33 } }, 2), "#efe6d2")
  -- sage leaves in the mouth and flying crumbs
  c:px(29, 47, "#8aa890"); c:px(28, 45, "#8aa890"); c:px(27, 48, "#b8d0b8"); c:px(32, 40, "#8aa890")
  -- the gnome, carrot out in front
  gnome(c, 10, 48, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 9, 9 }, true, true), arm({ -4, 6 }, { -6, 3 }, false) } })
  part(c, c:poly({ { 20, 40 }, { 27, 43 }, { 20, 45 } }), "#e8801a", { noline = true })
  fl(c, R(c, 17, 40, 19, 41), "#4e9a3c"); fl(c, R(c, 16, 43, 19, 43), "#4e9a3c"); fl(c, R(c, 17, 45, 19, 45), "#4e9a3c")
  fl(c, R(c, 18, 41, 19, 44), "#f0c8a0")
  finish(c, "w3_goat_in_sage")
end

-- 12. honeycomb_press: gnome squeezes a muslin bag of comb; honey drips into a jar on the table
function S.w3_honeycomb_press()
  seed = 73
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#c9a96e")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 40), "#b8965c") end
  fl(c, R(c, 0, 38, W - 1, 40), "#a8703e")
  c:fill(R(c, 0, 41, W - 1, H - 1), "#8a5a35")
  for y = 45, 53, 4 do fl(c, R(c, 0, y, W - 1, y), "#6b3b2a") end
  -- shelf of honey jars, a skep, and a window
  part(c, R(c, 40, 17, 68, 18), "#8a5a35")
  for i, x in ipairs({ 42, 49, 56 }) do
    part(c, R(c, x, 11, x + 4, 16), "#e8a317"); fl(c, R(c, x, 11, x + 4, 12), "#8a4f2a"); c:px(x + 1, 14, "#ffe08a")
  end
  part(c, c:ellipse(64, 14, 3, 3), "#d9a660", { noline = true }); fl(c, R(c, 62, 14, 66, 14), "#b8803a")
  part(c, R(c, 6, 8, 20, 22), "#a8703e")
  c:fill(R(c, 8, 10, 18, 20), "#bcdde4"); fl(c, R(c, 13, 10, 13, 20), "#a8703e"); fl(c, R(c, 8, 15, 18, 15), "#a8703e")
  c:fill(R(c, 9, 11, 11, 13), "#e8f4f8")
  -- long low table
  part(c, R(c, 22, 42, 68, 45), "#b07a45")
  fl(c, R(c, 22, 42, 68, 42), "#d9a660")
  part(c, R(c, 26, 46, 28, 49), "#8a5a35", { noline = true }); part(c, R(c, 62, 46, 64, 49), "#8a5a35", { noline = true })
  -- the jar under the bag
  part(c, R(c, 28, 36, 35, 41), "#d4eef4")
  c:fill(R(c, 29, 38, 34, 41), "#e8a317"); fl(c, R(c, 29, 38, 34, 38), "#ffd86a"); fl(c, R(c, 29, 36, 29, 37), "#f4fbfd")
  fl(c, R(c, 31, 33, 31, 37), "#e8a317")
  -- comb chunks on a plate
  part(c, c:ellipse(52, 42, 7, 1), "#f4eee0", { noline = true })
  for i, p in ipairs({ { 48, 39 }, { 53, 38 }, { 58, 39 } }) do
    part(c, c:poly({ { p[1], p[2] + 1 }, { p[1] + 2, p[2] - 1 }, { p[1] + 4, p[2] + 1 }, { p[1] + 4, p[2] + 3 }, { p[1], p[2] + 3 } }), "#e8a317", { noline = true })
    c:px(p[1] + 1, p[2] + 1, "#b8761a"); c:px(p[1] + 3, p[2] + 2, "#b8761a"); c:px(p[1] + 2, p[2] + 2, "#ffd86a")
  end
  -- gnome pressing the bag
  local _, G = gnome(c, 17, 48, { d = 1, eyes = "shut", arms = { arm({ 4, 8 }, { 10, 17 }, true, true), arm({ 3, 7 }, { 11, 14 }, true, true) } })
  local bx, by = G.P(13, 17)
  part(c, c:ellipse(bx, by + 1, 5, 4), "#f0ead8", { noline = true })
  c:fill(c:ellipse(bx, by + 3, 4, 2), "#e8a317"); fl(c, R(c, bx - 2, by + 5, bx + 2, by + 5), "#e8a317")
  fl(c, R(c, bx - 1, by - 4, bx + 1, by - 2), "#d8cfb8")
  fl(c, R(c, bx - 4, by - 1, bx - 4, by + 1), "#fffaf0")
  fl(c, R(c, bx - 6, by + 2, bx - 5, by + 3), "#f0c8a0"); fl(c, R(c, bx + 4, by - 2, bx + 5, by - 1), "#f0c8a0")
  bee(c, 60, 28); bee(c, 66, 32)
  finish(c, "w3_honeycomb_press")
end

-- 13. ramson_pesto: spring; gnome pounds green garlic leaves in a big stone mortar on a stump
function S.w3_ramson_pesto()
  seed = 74
  local c = new()
  day(c, 30, { cloud = 20, sky = { "#b4dcea", "#c8e6e8", "#d8eeea" }, hill = "#6a9a50", hill2 = "#5a9a48" })
  -- cherry blossom petals drifting
  for _, p in ipairs({ { 12, 12 }, { 30, 8 }, { 56, 14 }, { 64, 8 }, { 40, 17 } }) do c:px(p[1], p[2], "#f6b8cf"); c:px(p[1] + 1, p[2] + 1, "#fde4ee") end
  -- stump table
  part(c, R(c, 36, 40, 60, 49), "#8a5a35")
  fl(c, R(c, 39, 43, 39, 48), "#5e2f1e"); fl(c, R(c, 47, 44, 47, 48), "#5e2f1e"); fl(c, R(c, 55, 43, 55, 48), "#5e2f1e")
  part(c, c:ellipse(48, 40, 13, 3), "#e8c48a"); c:fill(c:ellipse(48, 40, 7, 1), "#c08a52")
  -- mortar
  part(c, c:poly({ { 38, 26 }, { 58, 26 }, { 56, 36 }, { 53, 40 }, { 43, 40 }, { 40, 36 } }), "#a8aeb4", { shade = true })
  part(c, c:ellipse(48, 26, 10, 2), "#c9c5bc", { noline = true })
  c:fill(c:ellipse(48, 26, 8, 1), "#58a04a"); fl(c, R(c, 44, 26, 48, 26), "#8fd070")
  fl(c, R(c, 40, 32, 55, 32), "#8b9098")
  -- gnome with both hands on the pestle
  local _, G = gnome(c, 22, 48, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 10, 14 }, true, true), arm({ -3, 6 }, { 9, 10 }, true, true) } })
  local hx, hy = G.P(10, 14)
  part(c, c:line({ { hx - 2, hy - 5 }, { 47, 26 } }, 2), "#8a5a35")
  part(c, c:ellipse(hx - 2, hy - 5, 2, 2), "#a8703e", { noline = true })
  fl(c, R(c, hx - 1, hy - 1, hx + 1, hy + 1), "#f0c8a0")
  local h2x, h2y = G.P(9, 10)
  fl(c, R(c, h2x - 1, h2y - 1, h2x + 1, h2y + 1), "#f0c8a0")
  -- smell wisps and bits of leaf
  for i = 0, 3 do fl(c, R(c, 47 + ((i % 2) * 2 - 1), 22 - i * 3, 48 + ((i % 2) * 2 - 1), 23 - i * 3), "#a8e090") end
  c:px(40, 24, "#4e9a3c"); c:px(56, 23, "#4e9a3c"); c:px(52, 21, "#8fd070")
  -- basket of wild garlic leaves and white starry flowers
  part(c, c:rrect(60, 40, 68, 48, 2), "#c8802a")
  fl(c, R(c, 61, 43, 67, 43), "#8a4f2a")
  for _, p in ipairs({ { 61, 36, -1 }, { 64, 34, 0 }, { 66, 37, 1 }, { 62, 39, 0 } }) do
    part(c, c:poly({ { p[1], p[2] + 5 }, { p[1] + p[3], p[2] }, { p[1] + 2, p[2] + 5 } }), "#4e9a3c", { noline = true })
  end
  c:px(61, 35, "#f4eee0"); c:px(65, 33, "#f4eee0"); c:px(67, 36, "#f4eee0")
  -- loose leaves on the grass
  for _, p in ipairs({ { 8, 48 }, { 33, 49 }, { 12, 44 } }) do part(c, c:ellipse(p[1], p[2], 2, 1), "#4e9a3c", { noline = true }) end
  finish(c, "w3_ramson_pesto")
end

-- 14. dill_jars: autumn; gnome tucks a dill head into a pickle jar, cold frame open, tall yellow dill umbels
function S.w3_dill_jars()
  seed = 75
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 31), { "#e8d4a0", "#f0dcb0", "#f4e4be", "#f6e8c8" }, { dir = "v" })
  c:fill(c:ellipse(16, 31, 30, 7), "#a8883a"); c:fill(c:ellipse(60, 32, 28, 6), "#b8862a")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#8a9a4a"); c:fill(R(c, 0, 31, W - 1, 31), "#a8b05a")
  c:fill(R(c, 0, 42, W - 1, H - 1), "#7a8a3e")
  -- cold frame with its glass lid propped open, cucumbers inside
  part(c, R(c, 3, 30, 25, 41), "#a8703e")
  c:fill(R(c, 5, 32, 23, 38), "#4a7a38")
  for _, p in ipairs({ { 6, 34 }, { 12, 36 }, { 18, 34 } }) do part(c, c:ellipse(p[1] + 2, p[2], 3, 1), "#3f8a42", { noline = true }); c:px(p[1] + 1, p[2] - 1, "#8fc462") end
  part(c, c:poly({ { 3, 29 }, { 25, 29 }, { 25, 21 }, { 7, 21 } }), "#cfeaf2")
  fl(c, R(c, 8, 22, 24, 22), "#f4fbfd"); fl(c, R(c, 15, 22, 15, 28), "#a8d4e0"); fl(c, R(c, 3, 29, 25, 29), "#8a5a35")
  fl(c, R(c, 25, 29, 25, 21), "#6b4a2e")
  -- autumn leaves
  for _, p in ipairs({ { 30, 12 }, { 44, 20 }, { 10, 14 }, { 66, 18 }, { 56, 8 } }) do c:px(p[1], p[2], "#d8651a"); c:px(p[1] + 1, p[2] + 1, "#e8a317") end
  -- tall dill with yellow umbels at the right
  local function dill(x, yb, h)
    fl(c, R(c, x, yb - h, x, yb), "#7a9a3a")
    fl(c, c:line({ { x, yb - h + 4 }, { x - 4, yb - h + 1 } }, 1), "#7a9a3a")
    fl(c, c:line({ { x, yb - h + 6 }, { x + 4, yb - h + 3 } }, 1), "#7a9a3a")
    for _, e in ipairs({ { x, yb - h }, { x - 4, yb - h + 1 }, { x + 4, yb - h + 3 } }) do
      part(c, c:ellipse(e[1], e[2], 3, 2), "#f0c040", { noline = true })
      for k = -2, 2, 2 do c:px(e[1] + k, e[2] - 2, "#f8dc70"); c:px(e[1] + k, e[2] + 2, "#d8a020") end
      c:px(e[1], e[2], "#fff0a0")
    end
  end
  dill(65, 48, 22); dill(58, 49, 17)
  -- the gnome with a jar and a dill head
  local _, G = gnome(c, 30, 48, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 8, 11 }, true, true), arm({ -4, 6 }, { 9, 9 }, true, true) } })
  local jx, jy = G.P(10, 11)
  part(c, R(c, jx - 3, jy - 4, jx + 3, jy + 3), "#d4eef4")
  fl(c, R(c, jx - 2, jy - 1, jx + 2, jy + 3), "#6aa04a"); fl(c, R(c, jx - 2, jy - 3, jx - 2, jy), "#f4fbfd")
  fl(c, R(c, jx, jy - 7, jx, jy - 4), "#7a9a3a")
  part(c, c:ellipse(jx, jy - 8, 3, 2), "#f0c040", { noline = true }); c:px(jx, jy - 8, "#fff0a0"); c:px(jx - 2, jy - 10, "#f8dc70"); c:px(jx + 2, jy - 10, "#f8dc70")
  fl(c, R(c, jx - 4, jy - 1, jx - 3, jy), "#f0c8a0"); fl(c, R(c, jx + 3, jy + 1, jx + 4, jy + 2), "#f0c8a0")
  -- a row of finished jars on a crate
  part(c, R(c, 44, 44, 55, 49), "#b07a45"); fl(c, R(c, 44, 44, 55, 44), "#d9a660")
  for _, x in ipairs({ 45, 50 }) do
    part(c, R(c, x, 36, x + 4, 43), "#d4eef4"); fl(c, R(c, x + 1, 38, x + 3, 43), "#6aa04a"); fl(c, R(c, x + 1, 35, x + 3, 35), "#8a4f2a")
    c:px(x + 2, 39, "#f0c040")
  end
  finish(c, "w3_dill_jars")
end

-- 15. bee_hotel: tall bee hotel of hollow stems, gnome slides a bundle into the empty floor, a bee checks in
function S.w3_bee_hotel()
  seed = 76
  local c = new()
  day(c, 38, { cloud = 14, hill = "#5e8a44", hill2 = "#4e8a3c" })
  -- flowers behind
  for _, p in ipairs({ { 8, 40 }, { 12, 42 }, { 64, 41 } }) do c:px(p[1], p[2], "#e46a9b"); c:px(p[1] + 1, p[2], "#f6b8cf"); c:px(p[1], p[2] + 1, "#4e8a3c") end
  -- post
  part(c, R(c, 44, 41, 46, 49), "#6b4a2e", { noline = true })
  -- floors of the hotel
  local function floor_(y0, filled)
    part(c, R(c, 34, y0, 56, y0 + 7), "#a8703e")
    fl(c, R(c, 35, y0 + 1, 55, y0 + 6), "#6b3b2a")
    if filled then
      for x = 36, 53, 3 do for y = y0 + 1, y0 + 5, 2 do
        c:fill(R(c, x, y, x + 1, y + 1), "#e8c48a"); c:px(x, y, "#3a2010")
      end end
    end
  end
  floor_(18, true); floor_(26, true); floor_(34, false)
  -- bottom floor: scaffold only, a few stems already in
  for x = 36, 53, 6 do c:fill(R(c, x, 35, x + 1, 40), "#e8c48a"); c:px(x, 36, "#3a2010") end
  -- pitched roof
  part(c, c:poly({ { 45, 9 }, { 59, 17 }, { 31, 17 } }), "#c0442e")
  fl(c, R(c, 33, 16, 57, 16), "#8e2e1e"); fl(c, c:line({ { 38, 15 }, { 45, 11 } }, 1), "#dd5a42")
  -- gnome with a bundle of stems, sliding it in
  local _, G = gnome(c, 20, 48, { d = 1, eyes = "open", arms = { arm({ 4, 8 }, { 10, 11 }, true, true), arm({ -3, 7 }, { 8, 9 }, true, true) } })
  local bx, by = G.P(10, 12)
  for k = 0, 4 do
    fl(c, R(c, bx - 1 + k * 2, by - 8 - (k % 2) * 2, bx + k * 2, by + 1), "#e8c48a")
    c:px(bx - 1 + k * 2, by - 8 - (k % 2) * 2, "#3a2010")
  end
  fl(c, R(c, bx - 2, by - 2, bx + 9, by - 1), "#6b4a2e")
  fl(c, R(c, bx - 3, by - 3, bx - 2, by - 1), "#f0c8a0")
  -- pile of stems and a hand drill on the ground at right
  for k = 0, 5 do fl(c, R(c, 59 + k, 46 - (k % 3), 59 + k, 49), "#e8c48a") end
  fl(c, c:line({ { 58, 49 }, { 67, 47 } }, 1), "#d9a660")
  part(c, R(c, 64, 38, 65, 45), "#8b929c"); part(c, R(c, 62, 37, 67, 38), "#8a5a35")
  fl(c, R(c, 64, 45, 64, 47), "#3d2a1c")
  -- bees
  bee(c, 28, 24); bee(c, 60, 28); bee(c, 24, 32)
  bee(c, 52, 28)
  finish(c, "w3_bee_hotel")
end

local order = { "w3_jetty_boats", "w3_bobbing_float", "w3_reed_oar", "w3_crab_pot", "w3_upturned_boat", "w3_swarm_home", "w3_pot_cuttings", "w3_mystery_weed", "w3_frost_cloches", "w3_nettle_sting", "w3_goat_in_sage", "w3_honeycomb_press", "w3_ramson_pesto", "w3_dill_jars", "w3_bee_hotel" }
for _, s2 in ipairs(order) do
  if S[s2] and (not only or only == s2) then seed = 7; S[s2]() end
end
