-- variety-act-g14.lua : Do-tab scenes for the w3 shrine/jetty activities -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g14.lua   (params BEFORE --script)
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


---------------------------------------------------------------- shared scene helpers
local function stars(c, list, col) for _, p in ipairs(list) do c:px(p[1], p[2], col or "#f4eee0") end end

-- harbour: sky bands down to hy, water bands below with a few glints
local function sea(c, hy, o)
  o = o or {}
  c:bands(R(c, 0, 0, W - 1, hy), o.sky or { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  c:bands(R(c, 0, hy + 1, W - 1, H - 1), o.water or { "#4c88b4", "#427aa8", "#386c9a", "#2f6290" }, { dir = "v" })
  local gl = o.glint or "#8fcbd8"
  seed = o.seed or 5
  for i = 1, o.n or 12 do
    local x, y = floor(rand() * 64) + 4, hy + 3 + floor(rand() * (H - hy - 5))
    fl(c, R(c, x, y, x + 2 + floor(rand() * 2), y), gl)
  end
end

-- jetty seen side-on: deck top row yt (deck face yt..yt+1 light, front board yt+2..yt+4), posts to the water
local function jetty(c, x0, x1, yt, o)
  o = o or {}
  local pl, pf, pg = o.top or "#b07a45", o.face or "#8a5a35", o.gap or "#5e3f28"
  for x = x0 + 3, x1 - 2, o.step or 14 do
    part(c, R(c, x, yt + 4, x + 1, o.post or (yt + 12)), "#6b4a2e", { noline = true })
  end
  part(c, R(c, x0, yt, x1, yt + 4), pf)
  fl(c, R(c, x0 + 1, yt, x1 - 1, yt + 1), pl)
  for x = x0 + 5, x1 - 3, 7 do fl(c, R(c, x, yt, x, yt + 4), pg) end
  fl(c, R(c, x0 + 1, yt + 2, x1 - 1, yt + 2), pg)
end

local function bubble(c, x, y) c:px(x, y, "#e8f8f4"); c:px(x + 1, y, "#cfe8e8"); c:px(x, y + 1, "#cfe8e8") end
local function gull(c, x, y, d)
  -- small white gull in flight: body + two raised wing pixels
  part(c, R(c, x, y, x + 3, y + 1), "#f4f8fa")
  fl(c, R(c, x - 2, y - 2, x - 1, y - 1), "#f4f8fa"); fl(c, R(c, x + 4, y - 2, x + 5, y - 1), "#f4f8fa")
  c:px(x + 1, y - 1, "#f4f8fa")
  fl(c, R(c, x + (d > 0 and 4 or -1), y, x + (d > 0 and 4 or -1), y), "#e8a317")
  c:px(x + (d > 0 and 3 or 0), y, INK)
end

local S = {}

-- 1. moss_roller: shoving a big stone roller along a mossy shrine path; flattened stripes behind, bumpy moss ahead
function S.moss_roller()
  seed = 61
  local c = new()
  day(c, 27, { cloud = 20, hill = "#5e8a44", hill2 = "#4e8a3c", grass = "#6a9a50", edge = "#8fc462" })
  -- little stone shrine on the hill
  part(c, R(c, 47, 17, 62, 27), "#a8aeb4", { shade = true })
  fl(c, R(c, 47, 21, 62, 21), "#8b8f96"); fl(c, R(c, 47, 24, 62, 24), "#8b8f96")
  part(c, c:poly({ { 54, 9 }, { 66, 17 }, { 43, 17 } }), "#5a7a4a")
  fl(c, R(c, 47, 16, 62, 16), "#3f5a34")
  fl(c, R(c, 51, 10, 52, 10), "#7ab55c"); fl(c, R(c, 58, 14, 60, 14), "#7ab55c")
  part(c, R(c, 52, 20, 57, 27), "#3d2a1c")
  fl(c, R(c, 53, 22, 56, 27), "#ffd86a")
  part(c, R(c, 50, 27, 59, 28), "#9a9ea6", { noline = true })
  -- the path: pale springy moss band front
  fl(c, R(c, 0, 33, W - 1, H - 1), "#8fc462")
  fl(c, R(c, 0, 33, W - 1, 33), "#a8d878")
  c:fill(c:ellipse(0, 31, 14, 3), "#4e8a3c"); c:fill(c:ellipse(71, 31, 14, 3), "#4e8a3c")
  fl(c, R(c, 0, 49, W - 1, H - 1), "#4e8a3c")
  -- rolled stripes left (flat), lumpy ahead (right)
  for y = 36, 46, 3 do fl(c, R(c, 4, y, 30, y), "#7ab55c") end
  seed = 70
  for i = 1, 16 do
    local x, y = 46 + floor(rand() * 21), 36 + floor(rand() * 12)
    c:fill(c:ellipse(x, y, 2, 1), "#4e8a3c"); c:px(x, y - 1, "#6aa050")
  end
  -- roller: stone circle end, hub, moss on the top
  part(c, c:ellipse(46, 41, 7, 7), "#9a9ea6", { shade = true })
  c:fill(c:ellipse(46, 41, 4, 4), "#8b8f96")
  c:fill(c:ellipse(46, 41, 1, 1), "#6b6f76")
  c:fill(R(c, 41, 35, 50, 35), "#4e8a3c"); c:fill(R(c, 43, 34, 48, 34), "#6aa050")
  c:px(40, 38, "#4e8a3c"); c:px(52, 44, "#4e8a3c"); c:px(51, 38, "#6aa050")
  -- long wooden handle from the hub to the gnome's hands
  part(c, c:line({ { 46, 41 }, { 25, 34 } }, 2), "#a8703e", { noline = true })
  fl(c, c:line({ { 46, 41 }, { 25, 34 } }, 1), "#c08a52")
  c:fill(c:line({ { 26, 34 }, { 24, 33 } }, 2), "#6b3b2a")
  -- gnome shoving, leaning forward
  gnome(c, 20, 47, { d = 1, walk = 1, eyes = "open", arms = { arm({ 3, 9 }, { 8, 11 }, true), arm({ -2, 8 }, { 5, 10 }, false) } })
  -- puffs of effort behind
  c:px(7, 44, "#f4eee0"); c:px(8, 44, "#f4eee0"); c:px(6, 46, "#f4eee0")
  finish(c, "w3_moss_roller")
end

-- 2. moss_remembers: starry night, gnome seated before a boulder whose moss glows; a memory (walnut) floats up in a bubble
function S.moss_remembers()
  seed = 71
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 36), { "#1e2848", "#27345a", "#32426a", "#3f5078" }, { dir = "v" })
  stars(c, { { 8, 8 }, { 20, 11 }, { 33, 7 }, { 45, 12 }, { 11, 20 }, { 62, 8 }, { 66, 20 }, { 38, 20 }, { 26, 18 } })
  c:fill(c:ellipse(11, 13, 3, 3), "#f5e6a8"); c:fill(c:ellipse(12, 12, 3, 3), "#27345a")
  c:fill(c:ellipse(18, 37, 32, 9), "#1e2c4c"); c:fill(c:ellipse(62, 37, 28, 8), "#22305a")
  c:fill(R(c, 0, 36, W - 1, H - 1), "#2c4a3a")
  c:fill(R(c, 0, 36, W - 1, 36), "#3a5e46")
  seed = 72
  for i = 1, 12 do local x, y = 4 + floor(rand() * 64), 38 + floor(rand() * 11); c:px(x, y, "#3f6a4c"); c:px(x + 1, y - 1, "#3f6a4c") end
  -- shrine steps behind
  part(c, R(c, 5, 31, 30, 38), "#59616f"); part(c, R(c, 8, 27, 27, 31), "#6b7482")
  fl(c, R(c, 5, 34, 30, 34), "#46505e")
  -- the big old stone, moss glowing
  part(c, c:ellipse(51, 40, 14, 9), "#59616f", { shade = true })
  c:fill(c:ellipse(51, 33, 11, 4), "#3a8a6a")
  for _, p in ipairs({ { 44, 34 }, { 50, 32 }, { 57, 34 }, { 47, 38 }, { 55, 37 }, { 52, 43 }, { 60, 40 }, { 43, 42 } }) do
    c:fill(c:ellipse(p[1], p[2], 2, 1), "#58d8a0"); c:px(p[1], p[2], "#bff5d8")
  end
  -- rising memory motes and a bubble holding a walnut
  for _, p in ipairs({ { 47, 28 }, { 53, 26 }, { 58, 29 } }) do c:px(p[1], p[2], "#8ff0c0") end
  part(c, c:ellipse(52, 17, 8, 6), "#e8f4ea")
  c:fill(c:ellipse(46, 25, 1, 1), "#e8f4ea"); c:fill(c:ellipse(49, 23, 2, 1), "#e8f4ea")
  part(c, c:ellipse(52, 17, 3, 3), "#a8703e"); c:fill(c:ellipse(52, 17, 1, 1), "#c08a52")
  fl(c, R(c, 52, 13, 52, 14), "#5a8a3a"); c:px(53, 14, "#5a8a3a")
  -- gnome, seated in the grass, chin up
  gnome(c, 22, 43, { d = 1, sit = true, eyes = "open", arms = { arm({ -3, 6 }, { -5, 3 }, true) } })
  c:px(36, 22, "#ffe08a"); c:px(37, 22, "#f5cf6a"); c:px(32, 14, "#f5cf6a")
  finish(c, "w3_moss_remembers")
end

-- 3. bellringer_hours: dawn on the top step, gnome with a hot mug, the knotted bell rope beside him
function S.bellringer_hours()
  seed = 81
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#6a6aa0", "#9a7aa8", "#d08aa0", "#f0a888", "#f8c890", "#fce0a0" }, { dir = "v" })
  c:fill(c:ellipse(20, 33, 8, 7), "#fce890"); c:fill(c:ellipse(20, 33, 5, 5), "#fff4c0")
  stars(c, { { 9, 8 }, { 28, 6 }, { 50, 9 }, { 62, 7 } }, "#e8e0f0")
  c:fill(c:ellipse(14, 37, 30, 8), "#6a5a8a"); c:fill(c:ellipse(56, 36, 26, 7), "#7a6890")
  c:fill(R(c, 0, 35, W - 1, H - 1), "#4a5a50")
  -- stone steps rising to the right
  part(c, R(c, 0, 44, 68, 49), "#8a8f9a")
  fl(c, R(c, 0, 44, 68, 44), "#a8aeb8"); fl(c, R(c, 0, 47, 68, 47), "#70757f")
  part(c, R(c, 17, 40, 68, 44), "#9a9ea8")
  fl(c, R(c, 17, 40, 68, 40), "#b8bcc6")
  -- bell frame, bell, rope with three knots
  part(c, R(c, 42, 10, 43, 40), "#6b4a2e", { noline = true }); part(c, R(c, 62, 10, 63, 40), "#6b4a2e", { noline = true })
  part(c, R(c, 40, 8, 65, 10), "#8a5a35")
  part(c, c:poly({ { 52, 11 }, { 56, 17 }, { 58, 24 }, { 60, 25 }, { 44, 25 }, { 46, 24 }, { 48, 17 } }), "#d8a038")
  fl(c, R(c, 49, 16, 49, 22), "#f0c860"); fl(c, R(c, 45, 24, 59, 24), "#a8761e")
  c:px(52, 26, "#6b3b2a"); c:px(52, 27, "#6b3b2a")
  fl(c, R(c, 52, 9, 52, 10), "#3d2a1c")
  fl(c, R(c, 48, 25, 48, 38), "#e0c88a"); c:px(48, 28, "#a8703e"); c:px(48, 32, "#a8703e"); c:px(48, 36, "#a8703e")
  fl(c, R(c, 47, 38, 49, 39), "#c8a460")
  -- mug beside the gnome with a coil of steam
  gnome(c, 30, 40, { d = 1, sit = true, eyes = "shut", arms = { arm({ 3, 7 }, { 6, 8 }, true, true) } })
  local mx, my = 36, 31
  part(c, R(c, mx, my, mx + 4, my + 4), "#c0442e"); fl(c, R(c, mx + 5, my + 1, mx + 6, my + 3), "#c0442e")
  fl(c, R(c, mx - 1, my + 2, mx, my + 3), "#f0c8a0")
  fl(c, R(c, mx + 1, my, mx + 3, my), "#6b3b2a")
  for i, y in ipairs({ my - 3, my - 6, my - 9 }) do fl(c, R(c, mx + 1 + (i % 2), y, mx + 2 + (i % 2), y + 1), "#fbf4f0") end
  finish(c, "w3_bellringer_hours")
end

-- 4. landing_net: dusk, a bent rod, the old angler shouts, the gnome swings a long net under a leaping silver fish
function S.landing_net()
  seed = 91
  local c = new()
  sea(c, 30, { sky = { "#5a4a8a", "#8a5a98", "#c8708a", "#e8946e", "#f4b078" }, water = { "#7a5a90", "#5a5a88", "#3f5a84", "#34507a" }, glint = "#f4b078", n = 14 })
  c:fill(c:ellipse(52, 30, 8, 6):clip(R(c, 0, 0, 72, 30)), "#fcd890")
  for x = 43, 61, 3 do fl(c, R(c, x, 31, x + 1, 31), "#f4b078") end
  for x = 45, 59, 4 do fl(c, R(c, x, 34, x + 2, 34), "#f4b078") end
  stars(c, { { 8, 8 }, { 22, 6 }, { 36, 10 }, { 12, 17 } }, "#e8d8f0")
  jetty(c, 4, 40, 40, { top = "#a8703e", face = "#7a4a2a", gap = "#4e2f1e", post = 49 })
  -- old angler (grey hat, rod bent right, line taut to the fish)
  gnome(c, 12, 39, { d = 1, hat = "#8a8f9a", eyes = "open", arms = { arm({ 4, 7 }, { 7, 9 }, true) } })
  c:fill(c:line({ { 20, 32 }, { 26, 18 }, { 32, 11 } }, 1), "#5e3f28")
  c:fill(c:line({ { 32, 11 }, { 46, 30 } }, 1), "#e8e0d0")
  -- the fish, big, silver, arcing
  part(c, c:ellipse(48, 33, 6, 3), "#c8d4dc")
  c:fill(c:ellipse(48, 32, 4, 1), "#e8f0f4"); c:fill(R(c, 51, 33, 54, 33), "#8a98a6")
  c:fill(c:poly({ { 54, 31 }, { 58, 29 }, { 58, 36 }, { 54, 34 } }), "#a8b6c2")
  c:px(44, 32, INK)
  for _, p in ipairs({ { 42, 37 }, { 55, 38 }, { 49, 38 }, { 60, 34 } }) do c:px(p[1], p[2], "#f4f8fa") end
  -- gnome holding the long net out
  gnome(c, 31, 39, { d = 1, eyes = "open", arms = { arm({ 3, 8 }, { 8, 11 }, true), arm({ -3, 8 }, { 5, 8 }, false) } })
  c:fill(c:line({ { 38, 31 }, { 44, 35 } }, 2), "#6b3b2a")
  part(c, c:ellipse(48, 38, 7, 3), "#e8e0c8")
  c:fill(c:ellipse(48, 38, 5, 1), "#34507a")
  for x = 43, 53, 2 do c:px(x, 40, "#c8c0a8") end
  finish(c, "w3_landing_net")
end

-- 5. read_tide: dawn, gnome licks a finger and holds it up; weedy post, slack water, the boat waiting to launch
function S.read_tide()
  seed = 101
  local c = new()
  sea(c, 27, { sky = { "#8a8ac0", "#c89ac0", "#f0a8a8", "#f8c8a0", "#fce0b0" }, water = { "#e8b8a8", "#9aa8c8", "#6a88b8", "#4a74a8", "#3f6a9e" }, glint = "#fce0b0", n = 10 })
  c:fill(c:ellipse(46, 27, 8, 6):clip(R(c, 0, 0, 72, 27)), "#fff0b8")
  for x = 36, 56, 4 do fl(c, R(c, x, 29, x + 2, 29), "#fce0b0") end
  for x = 39, 53, 5 do fl(c, R(c, x, 32, x + 2, 32), "#fce0b0") end
  c:fill(c:ellipse(10, 27, 18, 3), "#6a6a98")
  -- the waiting boat, bow rope to the post
  part(c, c:poly({ { 49, 36 }, { 69, 36 }, { 66, 43 }, { 53, 43 } }), "#a8703e")
  fl(c, R(c, 50, 36, 68, 36), "#d9a660"); fl(c, R(c, 53, 40, 66, 40), "#7a4a2a")
  part(c, R(c, 58, 24, 59, 36), "#6b4a2e", { noline = true })
  fl(c, R(c, 60, 25, 65, 28), "#f4eee0")
  fl(c, R(c, 48, 44, 70, 44), "#6a88b8"); fl(c, R(c, 52, 46, 64, 46), "#8fb0cc")
  -- jetty and the weedy post
  jetty(c, 4, 44, 39, { top = "#b07a45", face = "#8a5a35", gap = "#5e3f28", post = 49, step = 17 })
  part(c, R(c, 42, 25, 45, 49), "#6b4a2e")
  fl(c, R(c, 43, 26, 43, 40), "#8a5a35")
  fl(c, R(c, 42, 43, 45, 43), "#3f8a42")
  for _, p in ipairs({ { 42, 44 }, { 44, 44 }, { 43, 45 }, { 45, 45 }, { 42, 46 }, { 44, 47 } }) do fl(c, R(c, p[1], p[2], p[1], p[2] + 1), "#4e9a48") end
  fl(c, R(c, 46, 43, 47, 43), "#3f8a42")
  fl(c, R(c, 40, 43, 41, 43), "#a8d4d8"); fl(c, R(c, 46, 44, 49, 44), "#a8d4d8")
  fl(c, R(c, 46, 27, 47, 27), "#d9a660")
  -- gnome, finger raised to test the air
  gnome(c, 24, 38, { d = 1, eyes = "open", arms = { arm({ 3, 8 }, { 6, 14 }, true), arm({ -3, 7 }, { -5, 4 }, false) } })
  c:px(31, 27, "#f0c8a0")
  c:px(33, 31, "#f4f8fa"); c:px(35, 29, "#f4f8fa"); c:px(34, 24, "#f4f8fa")
  gull(c, 12, 14, 1)
  finish(c, "w3_read_tide")
end

-- 6. sprat_rack: silver sprats on strings, a gull helping itself, the gnome flapping a red flag
function S.sprat_rack()
  seed = 111
  local c = new()
  sea(c, 27, { sky = { "#a8d4e0", "#bcdde4", "#cfe8e6" }, water = { "#5a98b8", "#4c88b4", "#427aa8" }, n = 6 })
  c:fill(c:ellipse(56, 12, 7, 2), "#f4eee0"); c:fill(c:ellipse(60, 10, 4, 2), "#f4eee0")
  fl(c, R(c, 0, 33, W - 1, H - 1), "#e0c890")
  fl(c, R(c, 0, 33, W - 1, 33), "#f0dca8")
  for _, p in ipairs({ { 6, 44 }, { 12, 47 }, { 22, 46 }, { 64, 47 }, { 52, 48 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#c8a868") end
  -- drying rack
  part(c, c:line({ { 31, 44 }, { 38, 16 } }, 2), "#8a5a35", { noline = true })
  part(c, c:line({ { 63, 44 }, { 56, 16 } }, 2), "#8a5a35", { noline = true })
  part(c, R(c, 36, 15, 58, 17), "#a8703e")
  part(c, R(c, 33, 29, 61, 30), "#a8703e")
  local function sprat(x, y)
    fl(c, R(c, x, y, x + 1, y + 2), "#9fb4c6"); fl(c, R(c, x, y + 2, x + 1, y + 2), "#e8f0f4"); c:px(x, y, "#4a5a6a")
    c:px(x, y + 3, "#7c92a6"); c:px(x + 1, y + 3, "#7c92a6")
  end
  for k, x in ipairs({ 40, 45, 50, 55 }) do
    fl(c, R(c, x, 18, x, 28), "#e0d8c0")
    for y = 19, 27, 4 do if not (x == 55 and y >= 23) then sprat(x, y) end end
    fl(c, R(c, x, 31, x, 40), "#e0d8c0")
    for y = 32, 38, 4 do sprat(x, y) end
  end
  -- gulls: one perched, one stealing, one circling
  part(c, R(c, 44, 11, 49, 14), "#f4f8fa"); fl(c, R(c, 48, 10, 50, 11), "#f4f8fa"); c:px(49, 10, INK); c:px(51, 11, "#e8a317"); fl(c, R(c, 44, 12, 45, 13), "#9aa8b4")
  gull(c, 62, 25, 1); fl(c, R(c, 66, 26, 68, 26), "#9fb4c6")
  gull(c, 14, 15, 1)
  -- the gnome waves a flag on a stick
  gnome(c, 18, 47, { d = 1, eyes = "open", arms = { arm({ 4, 7 }, { 7, 13 }, true), arm({ -4, 7 }, { -6, 4 }, false) } })
  c:fill(c:line({ { 25, 31 }, { 27, 22 } }, 1), "#6b3b2a")
  part(c, c:poly({ { 27, 22 }, { 34, 20 }, { 33, 24 }, { 27, 26 } }), "#dd3a2a")
  c:px(37, 18, "#f4eee0")
  finish(c, "w3_sprat_rack")
end

-- 7. gale_moor: storm light, boats shoving the jetty, the gnome hauling a second rope tight
function S.gale_moor()
  seed = 121
  local c = new()
  sea(c, 24, { sky = { "#6a7488", "#7a8498", "#8a94a6", "#9aa4b4" }, water = { "#4a6678", "#425e72", "#3a566c", "#324c62" }, glint = "#c8d4dc", n = 14 })
  -- whitecaps
  for _, p in ipairs({ { 8, 27 }, { 28, 29 }, { 56, 27 }, { 14, 34 }, { 40, 31 }, { 62, 33 }, { 50, 40 }, { 6, 44 }, { 30, 47 } }) do
    fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#e8f0f4"); fl(c, R(c, p[1] + 1, p[2] - 1, p[1] + 2, p[2] - 1), "#e8f0f4")
  end
  -- jetty on the left, flag stiff in the wind
  jetty(c, 4, 36, 38, { top = "#a8703e", face = "#6b4a2e", gap = "#4e2f1e", post = 49, step = 15 })
  part(c, R(c, 6, 20, 7, 38), "#4e3a28", { noline = true })
  part(c, c:poly({ { 8, 21 }, { 17, 22 }, { 8, 26 } }), "#dd3a2a")
  -- two boats, tilting, ropes taut to the deck
  part(c, c:poly({ { 40, 41 }, { 58, 38 }, { 56, 46 }, { 44, 47 } }), "#a8703e")
  fl(c, R(c, 41, 41, 57, 39), "#d9a660"); fl(c, c:line({ { 42, 43 }, { 56, 41 } }, 1), "#7a4a2a")
  part(c, c:poly({ { 60, 31 }, { 70, 32 }, { 68, 38 }, { 61, 37 } }), "#8a6a4a")
  fl(c, R(c, 61, 31, 69, 31), "#b08a5c")
  c:fill(c:line({ { 41, 41 }, { 34, 38 } }, 1), "#e0c88a")
  c:fill(c:line({ { 60, 33 }, { 52, 36 }, { 40, 38 } }, 1), "#e0c88a")
  part(c, R(c, 35, 36, 37, 38), "#3d2a1c")
  -- gnome pulling the extra rope, feet braced
  gnome(c, 24, 37, { d = 1, walk = -1, eyes = "open", arms = { arm({ 3, 8 }, { 8, 5 }, true), arm({ -3, 7 }, { 6, 5 }, false) } })
  c:fill(c:line({ { 33, 33 }, { 38, 37 }, { 43, 42 } }, 1), "#e0c88a")
  -- rain streaks and flying hat-tip leaf
  seed = 122
  for i = 1, 22 do
    local x, y = 8 + floor(rand() * 60), 6 + floor(rand() * 40)
    c:px(x, y, "#c8d4dc"); c:px(x - 1, y + 1, "#c8d4dc")
  end
  fl(c, R(c, 46, 14, 50, 14), "#aeb8c4"); fl(c, R(c, 14, 18, 18, 18), "#aeb8c4"); fl(c, R(c, 52, 20, 57, 20), "#aeb8c4")
  finish(c, "w3_gale_moor")
end

-- 8. dropped_kettle: cross-section, clear green water, the gnome diving down for a tin kettle on the sand
function S.dropped_kettle()
  seed = 131
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 15), { "#88c8e0", "#a8d8e8", "#c8e8ec" }, { dir = "v" })
  c:fill(c:ellipse(62, 8, 5, 5), "#fce890")
  c:bands(R(c, 0, 16, W - 1, 42), { "#5ecbb0", "#4cbaa4", "#3ca8a0", "#2f9498", "#287f8c" }, { dir = "v" })
  c:fill(R(c, 0, 16, W - 1, 16), "#cff4e8")
  for x = 4, 66, 6 do fl(c, R(c, x, 16, x + 2, 16), "#f4fffa") end
  -- light rays
  for _, x in ipairs({ 14, 30, 48 }) do
    for y = 18, 40 do if (y % 2 == 0) then c:px(x + floor((y - 18) / 4), y, "#78d8c0") end end
  end
  fl(c, R(c, 0, 43, W - 1, H - 1), "#e0c890"); fl(c, R(c, 0, 43, W - 1, 43), "#f0dca8")
  fl(c, R(c, 0, 49, W - 1, 49), "#c8a868")
  -- jetty above with posts in the water
  part(c, R(c, 5, 10, 68, 14), "#8a5a35")
  fl(c, R(c, 6, 10, 67, 11), "#b07a45")
  for x = 12, 62, 7 do fl(c, R(c, x, 10, x, 14), "#5e3f28") end
  part(c, R(c, 10, 15, 12, 42), "#6b4a2e", { noline = true }); part(c, R(c, 60, 15, 62, 42), "#6b4a2e", { noline = true })
  fl(c, R(c, 10, 30, 12, 31), "#2f7a52")
  -- empty angler's mug on the deck, tea stain
  part(c, R(c, 24, 6, 27, 9), "#aeb4bc"); fl(c, R(c, 28, 7, 28, 8), "#8b929c")
  -- weed on the seabed
  for _, x in ipairs({ 8, 17, 52, 58, 65 }) do
    fl(c, R(c, x, 36, x, 43), "#2f7a42"); fl(c, R(c, x + 1, 38, x + 1, 42), "#3f8a52"); c:px(x - 1, 37, "#2f7a42")
  end
  -- the kettle on the sand
  part(c, c:rrect(39, 38, 50, 45, 3), "#aeb4bc", { shade = true })
  part(c, R(c, 41, 36, 48, 38), "#8b929c")
  fl(c, R(c, 43, 35, 46, 35), "#6b3b2a")
  part(c, c:poly({ { 50, 40 }, { 54, 37 }, { 55, 39 }, { 50, 43 } }), "#aeb4bc")
  c:fill(c:line({ { 40, 37 }, { 44, 33 }, { 47, 33 }, { 49, 37 } }, 1), "#8a5a35")
  c:px(41, 41, "#e8ecf0"); c:px(41, 42, "#e8ecf0")
  -- a small crab with an opinion
  part(c, c:ellipse(30, 44, 3, 2), "#dd5a3a"); fl(c, R(c, 26, 41, 27, 42), "#dd5a3a"); fl(c, R(c, 33, 41, 34, 42), "#dd5a3a")
  c:px(29, 43, INK); c:px(31, 43, INK)
  -- diver gnome, reaching down
  gnome(c, 25, 37, { d = 1, walk = 1, eyes = "open", arms = { arm({ 3, 7 }, { 9, 2 }, true), arm({ -3, 7 }, { -7, 11 }, false) } })
  for _, p in ipairs({ { 22, 25 }, { 28, 22 }, { 24, 19 } }) do bubble(c, p[1], p[2]) end
  bubble(c, 36, 30); bubble(c, 50, 24)
  finish(c, "w3_dropped_kettle")
end

-- 9. smoke_trout: oak-smoked trout in a barrel smoke-box, the gnome proudly holds up a leaf-wrapped one
function S.smoke_trout()
  seed = 141
  local c = new()
  sea(c, 26, { n = 6 })
  c:fill(c:ellipse(12, 12, 7, 2), "#f4eee0"); c:fill(c:ellipse(16, 10, 4, 2), "#f4eee0")
  jetty(c, 4, 68, 40, { top = "#b07a45", face = "#8a5a35", gap = "#5e3f28", post = 49, step = 17 })
  -- the barrel with its door open and embers, a chimney of smoke
  part(c, R(c, 39, 22, 55, 39), "#8a5a35")
  fl(c, R(c, 40, 22, 54, 22), "#a8703e")
  fl(c, R(c, 39, 25, 55, 25), "#5e3f28"); fl(c, R(c, 39, 36, 55, 36), "#5e3f28")
  fl(c, R(c, 42, 22, 42, 39), "#6b4a2e"); fl(c, R(c, 52, 22, 52, 39), "#6b4a2e")
  part(c, R(c, 44, 27, 51, 35), "#2a1a14")
  fl(c, R(c, 45, 34, 50, 34), "#e0501f"); fl(c, R(c, 46, 33, 49, 33), "#f08a24"); c:px(47, 33, "#ffd86a")
  fl(c, R(c, 45, 28, 50, 28), "#6b3b2a")
  for _, x in ipairs({ 46, 49 }) do
    fl(c, R(c, x, 29, x, 30), "#c8a460"); fl(c, R(c, x - 1, 31, x + 1, 32), "#e8a317"); c:px(x, 33, "#c88a1a")
  end
  part(c, R(c, 38, 20, 56, 21), "#6b4a2e")
  -- smoke puffs
  local function puff(x, y, r) c:fill(c:ellipse(x, y, r, r - 1), "#c8ccd2"); c:fill(c:ellipse(x - 1, y - 1, r - 1, math.max(1, r - 2)), "#e0e4e8") end
  puff(49, 17, 2); puff(51, 13, 3); puff(54, 9, 3); puff(58, 7, 2)
  -- oak logs stacked at the right
  local function logend(x, y) part(c, c:ellipse(x, y, 3, 3), "#a8703e"); c:fill(c:ellipse(x, y, 1, 1), "#e8c48a") end
  logend(61, 37); logend(66, 37); logend(63, 32)
  fl(c, R(c, 59, 38, 59, 38), "#6b4a2e")
  -- gnome with the wrapped trout held high
  gnome(c, 17, 39, { d = 1, eyes = "happy", arms = { arm({ 4, 8 }, { 8, 14 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  local hx, hy = 25, 25
  part(c, c:ellipse(hx + 2, hy - 4, 7, 3), "#e8a317")
  c:fill(c:ellipse(hx + 2, hy - 5, 5, 1), "#f5cf6a")
  c:fill(c:poly({ { hx + 8, hy - 4 }, { hx + 12, hy - 8 }, { hx + 12, hy } }), "#c88a1a")
  c:px(hx - 3, hy - 5, INK); c:px(hx + 4, hy - 7, "#c88a1a"); c:px(hx + 6, hy - 7, "#c88a1a")
  part(c, R(c, hx, hy - 7, hx + 3, hy - 1), "#4e9a48")
  c:px(hx + 1, hy - 5, "#7ab55c"); c:px(hx + 2, hy - 3, "#7ab55c")
  c:px(hx + 8, hy - 11, "#f5cf6a"); c:px(hx + 13, hy - 4, "#f5cf6a"); c:px(hx - 5, hy - 9, "#f5cf6a")
  finish(c, "w3_smoke_trout")
end

-- 10. samphire_salad: front-on, gnome behind a plank table squeezes a lemon over a bowl of salty green samphire
function S.samphire_salad()
  seed = 151
  local c = new()
  sea(c, 22, { n = 5, water = { "#5a98b8", "#4c88b4", "#427aa8" } })
  c:fill(c:ellipse(60, 10, 5, 5), "#fce890")
  -- stone slipway behind and quay
  c:fill(c:poly({ { 0, 30 }, { 72, 30 }, { 72, 24 }, { 40, 24 } }), "#9a9ea6")
  fl(c, R(c, 0, 30, W - 1, H - 1), "#a8aeb4")
  for x = 2, 70, 8 do fl(c, R(c, x, 32, x + 3, 32), "#8b8f96"); fl(c, R(c, x + 4, 36, x + 7, 36), "#8b8f96") end
  fl(c, R(c, 0, 30, W - 1, 30), "#c9c5bc")
  -- samphire clumps along the foot of the slipway
  for _, x in ipairs({ 8, 17, 58, 65 }) do
    fl(c, R(c, x - 2, 29, x + 2, 29), "#5aa84a")
    for k = -2, 2 do fl(c, R(c, x + k, 27 - (k % 2 == 0 and 1 or 0), x + k, 28), "#5aa84a") end
    c:px(x, 26, "#8fc462"); c:px(x - 2, 27, "#8fc462")
  end
  -- gnome behind the table, lemon half squeezed over the bowl
  local _, G = gnome(c, 24, 40, { d = 1, upper = true, s = 1.25, eyes = "open", arms = { arm({ 4, 6 }, { 8, 12 }, true) } })
  -- table: planks on two barrels
  part(c, R(c, 4, 40, 67, 43), "#b07a45")
  fl(c, R(c, 5, 40, 66, 40), "#d9a660")
  part(c, R(c, 6, 44, 18, 49), "#8a5a35"); part(c, R(c, 52, 44, 64, 49), "#8a5a35")
  fl(c, R(c, 6, 46, 18, 46), "#5e3f28"); fl(c, R(c, 52, 46, 64, 46), "#5e3f28")
  -- big bowl heaped with samphire
  part(c, c:ellipse(43, 39, 12, 4), "#d9a660")
  c:fill(c:ellipse(43, 38, 10, 3), "#b07a45")
  for x = 34, 52 do
    local h = 3 + ((x * 7) % 4)
    fl(c, R(c, x, 36 - h, x, 37), ((x % 3) == 0) and "#8fc462" or "#5aa84a")
  end
  for _, x in ipairs({ 37, 43, 49 }) do c:px(x, 29, "#8fc462") end
  -- lemon half in hand and a drip
  local lx, ly = G.P(9, 12)
  part(c, c:ellipse(lx + 1, ly - 1, 3, 2), "#f5cf6a"); c:fill(c:ellipse(lx + 1, ly - 1, 1, 1), "#fff1a8")
  fl(c, R(c, lx - 1, ly + 1, lx, ly + 2), "#f0c8a0")
  c:px(lx + 3, ly + 3, "#f5e050"); c:px(lx + 4, ly + 6, "#f5e050"); c:px(lx + 4, ly + 9, "#f5e050")
  -- bucket and a whole lemon on the table
  part(c, R(c, 56, 34, 62, 40), "#8a5a35"); fl(c, R(c, 56, 36, 62, 36), "#5e3f28")
  for x = 57, 61, 2 do fl(c, R(c, x, 31, x, 34), "#5aa84a") end
  part(c, c:ellipse(10, 38, 3, 2), "#f5cf6a"); c:px(11, 37, "#fff1a8")
  part(c, c:ellipse(16, 39, 3, 2), "#f5cf6a")
  finish(c, "w3_samphire_salad")
end

-- 11. crab_shell_meal: mallet raised over a crab shell on a stump, shell shards flying, a sack and a little bag of meal
function S.crab_shell_meal()
  seed = 161
  local c = new()
  sea(c, 27, { sky = { "#b8d8e4", "#c8e2e8", "#d8ecea" }, n = 6 })
  c:fill(c:ellipse(52, 11, 8, 2), "#f4eee0"); c:fill(c:ellipse(48, 9, 4, 2), "#f4eee0")
  fl(c, R(c, 0, 34, W - 1, H - 1), "#e0c890")
  fl(c, R(c, 0, 34, W - 1, 34), "#f0dca8")
    for _, p in ipairs({ { 6, 44 }, { 20, 49 }, { 48, 46 }, { 64, 44 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#c8a868") end
  -- burlap sack of shells on the left, red edges peeking out
  part(c, c:rrect(6, 36, 17, 48, 3), "#c8a46a", { shade = true })
  fl(c, R(c, 7, 38, 16, 38), "#8a6a3a")
  fl(c, R(c, 7, 34, 16, 36), "#dd5a3a"); c:px(9, 33, "#f08a6a"); c:px(13, 33, "#dd5a3a"); c:px(15, 34, "#f08a6a")
  -- chopping stump with a crab shell
  part(c, R(c, 40, 40, 51, 48), "#8a5a35")
  part(c, c:ellipse(45.5, 40, 6, 2), "#c08a52"); c:fill(c:ellipse(45.5, 40, 3, 1), "#e8c48a")
  part(c, c:ellipse(45.5, 37, 5, 3), "#dd5a3a")
  c:fill(c:ellipse(45.5, 36, 3, 1), "#f08a6a"); fl(c, R(c, 40, 38, 41, 38), "#dd5a3a"); fl(c, R(c, 50, 38, 51, 38), "#dd5a3a")
  -- shards flying
  for _, p in ipairs({ { 38, 32 }, { 52, 33 }, { 55, 38 }, { 37, 39 }, { 47, 30 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#dd5a3a"); c:px(p[1], p[2], "#f08a6a") end
  -- gnome with the mallet up
  local _, G = gnome(c, 29, 47, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 8, 17 }, true, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  local hx, hy = G.P(8, 16)
  part(c, c:line({ { hx + 1, hy + 2 }, { hx + 5, hy - 7 } }, 2), "#a8703e", { noline = true })
  part(c, R(c, hx + 1, hy - 14, hx + 9, hy - 9), "#8a5a35")
  fl(c, R(c, hx + 2, hy - 13, hx + 8, hy - 13), "#a8703e")
  fl(c, R(c, hx - 1, hy - 1, hx + 2, hy + 2), "#f0c8a0")
  c:px(hx + 11, hy - 8, "#f4eee0"); c:px(hx + 12, hy - 7, "#f4eee0")
  -- small bag of finished meal with a shell on it
  part(c, c:rrect(57, 38, 67, 48, 2), "#e8e0cc", { shade = true })
  fl(c, R(c, 58, 38, 66, 39), "#b8a878")
  c:paint({ ".sss.", "sssss", "s.s.s" }, 60, 41, { s = "#dd5a3a" })
  for x = 58, 66, 2 do c:px(x, 46, "#c8bea0") end
  c:px(67, 49, "#c8bea0"); c:px(55, 49, "#c8bea0"); c:px(60, 49, "#c8bea0")
  finish(c, "w3_crab_shell_meal")
end

-- 12. tar_rowboat: upturned rowboat on trestles, half freshly tarred, seams still gaping; tar pot on the ground
function S.tar_rowboat()
  seed = 171
  local c = new()
  sea(c, 24, { n = 5 })
  c:fill(c:ellipse(14, 10, 8, 2), "#f4eee0"); c:fill(c:ellipse(18, 8, 4, 2), "#f4eee0")
  fl(c, R(c, 0, 33, W - 1, H - 1), "#d8bc82")
  fl(c, R(c, 0, 33, W - 1, 33), "#ecd49a")
  for _, p in ipairs({ { 4, 44 }, { 14, 48 }, { 60, 47 }, { 66, 41 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#b8965c") end
  -- trestles
  part(c, R(c, 12, 38, 15, 48), "#6b4a2e"); part(c, R(c, 40, 38, 43, 48), "#6b4a2e")
  -- upturned hull: dome, keel on top
  local hull = c:poly({ { 4, 35 }, { 7, 39 }, { 48, 39 }, { 51, 35 }, { 44, 28 }, { 32, 24 }, { 22, 24 }, { 11, 28 } })
  part(c, hull, "#a8703e")
  -- planks
  for y = 27, 37, 3 do fl(c, R(c, 8, y, 47, y), "#7a4a2a") end
  fl(c, R(c, 22, 24, 32, 24), "#6b3b2a")
  -- tarred half (left): glossy black
  local tm = c:mask()
  for y = 22, 41 do tm:add(R(c, 0, y, 24 + ((y * 3) % 5), y)) end
  local tar = hull:clip(tm)
  c:fill(tar, "#2e2c34")
  for y = 27, 37, 3 do fl(c, R(c, 8, y, 26, y), "#1a181e") end
  fl(c, R(c, 10, 30, 14, 30), "#5a566a"); fl(c, R(c, 16, 33, 22, 33), "#5a566a"); fl(c, R(c, 12, 36, 17, 36), "#5a566a")
  -- gaping seams (right half): dark slits with light edge
  for _, p in ipairs({ { 31, 26 }, { 36, 30 }, { 42, 32 }, { 34, 35 }, { 45, 36 } }) do
    fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#2a1a10"); fl(c, R(c, p[1], p[2] + 1, p[2] > 0 and p[1] + 3 or p[1], p[2] + 1), "#d9a660")
  end
  -- gnome brushing tar, arm out
  gnome(c, 62, 47, { d = -1, eyes = "open", arms = { arm({ -4, 7 }, { -9, 9 }, true) } })
  part(c, c:line({ { 53, 38 }, { 50, 36 } }, 2), "#a8703e", { noline = true })
  part(c, R(c, 47, 34, 50, 38), "#2e2c34")
  -- tar pot warming on a stone ring with a little fire
  part(c, c:ellipse(30, 47, 6, 2), "#8b8f96", { shade = true })
  part(c, c:rrect(26, 41, 34, 47, 2), "#3d3a44", { shade = true })
  fl(c, R(c, 27, 41, 33, 41), "#2e2c34"); fl(c, R(c, 28, 40, 32, 40), "#5a566a")
  fl(c, R(c, 28, 47, 32, 47), "#e0501f"); c:px(30, 46, "#ffd86a")
  c:px(30, 36, "#e8e8ec"); c:px(31, 34, "#e8e8ec"); c:px(30, 32, "#e8e8ec")
  finish(c, "w3_tar_rowboat")
end

-- 13. loose_planks: gnome hammers a lifted plank on the jetty deck; a gap shows the water; the grandson keeps a tally
function S.loose_planks()
  seed = 181
  local c = new()
  sea(c, 22, { n = 8 })
  c:fill(c:ellipse(14, 12, 8, 2), "#f4eee0"); c:fill(c:ellipse(18, 10, 4, 2), "#f4eee0")
  -- deck seen from a high angle: surface band then the front board, posts in the water
  for x = 8, 62, 18 do part(c, R(c, x, 44, x + 2, 49), "#6b4a2e", { noline = true }) end
  part(c, R(c, 5, 43, 68, 46), "#6b4a2e")
  fl(c, R(c, 6, 43, 67, 43), "#8a5a35")
  fl(c, R(c, 5, 29, 68, 42), "#b07a45")
  fl(c, R(c, 5, 29, 68, 29), "#d9a660")
  for x = 9, 66, 6 do fl(c, R(c, x, 30, x, 42), "#7a4a2a") end
  fl(c, R(c, 5, 30, 68, 30), "#8a5a35")
  for _, x in ipairs({ 12, 62 }) do part(c, R(c, x, 25, x + 2, 30), "#6b4a2e"); fl(c, R(c, x, 26, x + 2, 26), "#e0c88a") end
  fl(c, R(c, 14, 27, 61, 27), "#e0c88a")
  -- the gap: one plank missing, water shows
  fl(c, R(c, 45, 30, 50, 42), "#2f6290"); fl(c, R(c, 46, 33, 49, 33), "#4c88b4"); fl(c, R(c, 46, 38, 49, 38), "#4c88b4")
  fl(c, R(c, 45, 30, 45, 42), "#4e2f1e"); fl(c, R(c, 50, 30, 50, 42), "#4e2f1e")
  -- splash from the gap
  for _, p in ipairs({ { 46, 25 }, { 48, 22 }, { 50, 26 }, { 44, 28 }, { 52, 29 } }) do c:px(p[1], p[2], "#e8f8f4") end
  fl(c, R(c, 46, 28, 49, 28), "#cfe8e8")
  -- loose plank, one end lifted and crooked, nail sticking up
  local lp = c:poly({ { 33, 31 }, { 38, 29 }, { 39, 39 }, { 33, 42 } })
  part(c, lp, "#d9a660")
  fl(c, R(c, 36, 31, 36, 38), "#b07a45")
  c:px(35, 28, "#aeb4bc"); c:px(35, 27, "#aeb4bc")
  fl(c, R(c, 34, 43, 38, 44), "#4e2f1e")
  -- gnome with the hammer raised
  local _, G = gnome(c, 23, 41, { d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 8, 15 }, true, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  local hx, hy = G.P(8, 15)
  part(c, c:line({ { hx + 1, hy + 1 }, { hx + 3, hy - 6 } }, 2), "#a8703e", { noline = true })
  part(c, R(c, hx - 1, hy - 10, hx + 7, hy - 6), "#8b929c")
  fl(c, R(c, hx - 1, hy - 1, hx + 2, hy + 2), "#f0c8a0")
  -- the grandson on the right, counting; tally marks on the front board
  gnome(c, 60, 41, { d = -1, s = 0.7, eyes = "open", hat = "#4f9a45", arms = { arm({ 3, 8 }, { 6, 12 }, true) } })
  for x = 53, 57, 1 do fl(c, R(c, x * 1, 44, x * 1, 45), "#f4eee0") end
  fl(c, R(c, 52, 45, 58, 45), "#f4eee0")
  finish(c, "w3_loose_planks")
end

-- 14. shadow_puppets: night, a glowing sail on two poles, a crab shadow nipping a gull that snaps a fish, lantern glow at its feet
function S.shadow_puppets()
  seed = 191
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#1a2240", "#232e54", "#2c3a62", "#36466e" }, { dir = "v" })
  stars(c, { { 8, 8 }, { 18, 15 }, { 32, 6 }, { 62, 8 }, { 66, 18 }, { 10, 24 }, { 66, 28 } })
  c:fill(c:ellipse(11, 14, 3, 3), "#f5e6a8"); c:fill(c:ellipse(12, 13, 3, 3), "#232e54")
  c:bands(R(c, 0, 35, W - 1, H - 1), { "#27406a", "#223a62", "#1d3258", "#192c50" }, { dir = "v" })
  for _, p in ipairs({ { 8, 38 }, { 20, 41 }, { 60, 39 }, { 66, 44 }, { 12, 47 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#3a5a8a") end
  jetty(c, 4, 68, 42, { top = "#8a5a35", face = "#5e3f28", gap = "#3d2a1c", post = 49, step = 17 })
  -- the sail on two poles, warmly lit from behind
  part(c, R(c, 25, 8, 26, 42), "#6b4a2e", { noline = true }); part(c, R(c, 63, 8, 64, 42), "#6b4a2e", { noline = true })
  part(c, R(c, 25, 11, 64, 38), "#f0dca0")
  fl(c, R(c, 28, 14, 61, 35), "#f8e8b8")
  fl(c, R(c, 33, 18, 56, 31), "#fff4cc")
  -- lantern glow along the bottom corners
  for x = 27, 62 do
    if x < 34 or x > 55 then fl(c, R(c, x, 36, x, 37), "#e8a860") end
  end
  c:fill(c:ellipse(29, 37, 4, 2), "#e8a860"); c:fill(c:ellipse(60, 37, 4, 2), "#e8a860")
  -- shadows
  local K = { k = "#5a3a2c" }
  c:paint({ "kk.......kk", ".kkk...kkk.", "..kkkkkkk..", "....kkk...." }, 34, 18, K)
  c:paint({ "..kkkk....k.", ".kkkkkkk.kk.", "kkkkkkkkkkk.", ".kkkkkkk.kk.", "..kkkk....k." }, 46, 17, K)
  c:paint({ "kk.......kk", "kkk.....kkk", ".kk.....kk.", "..kkkkkkk..", ".kkkkkkkkk.", "kk.k...k.kk" }, 40, 25, K)
  -- the gnome puppeteer, hand held up making a claw
  gnome(c, 13, 41, { d = 1, eyes = "happy", arms = { arm({ 4, 8 }, { 8, 13 }, true), arm({ -4, 6 }, { -5, 3 }, false) } })
  -- the lanterns
  part(c, R(c, 58, 39, 62, 41), "#ffd86a", { shade = true, cres = 1 })
  part(c, R(c, 28, 39, 32, 41), "#ffd86a", { shade = true, cres = 1 })
  c:px(35, 6, "#f5cf6a"); c:px(68, 22, "#f5cf6a")
  finish(c, "w3_shadow_puppets")
end

-- 15. coracle_race: round boats spinning round a flagged post in the shallows, the gnome paddling hard in front
function S.coracle_race()
  seed = 201
  local c = new()
  sea(c, 20, { n = 14, water = { "#5aa0c0", "#4c92b8", "#4284ac", "#38769e" }, glint = "#a8dcea" })
  c:fill(c:ellipse(16, 10, 8, 2), "#f4eee0"); c:fill(c:ellipse(22, 8, 4, 2), "#f4eee0")
  fl(c, R(c, 0, 20, W - 1, 20), "#5e8a44")
  c:fill(c:ellipse(60, 20, 14, 3), "#5e8a44")
  -- the post with a flag
  part(c, R(c, 53, 18, 54, 34), "#6b4a2e", { noline = true })
  part(c, c:poly({ { 55, 18 }, { 63, 20 }, { 55, 23 } }), "#dd3a2a")
  c:fill(c:ellipse(54, 35, 6, 2), "#cfe8f0"); fl(c, R(c, 49, 35, 59, 35), "#e8f4f8")
  -- far coracle with a tiny sail
  local function coracle(cx, cy, rx, ry, g, o)
    part(c, c:ellipse(cx, cy, rx, ry), "#c08a52")
    c:fill(c:ellipse(cx, cy, rx - 2, ry - 1), "#5e3f28")
    if g then g() end
    local fr = c:ellipse(cx, cy + 2, rx, ry + 1):clip(R(c, cx - rx - 1, cy + 1, cx + rx + 1, cy + ry + 6))
    part(c, fr, "#c08a52")
    fl(c, R(c, cx - rx + 2, cy + 1, cx + rx - 2, cy + 1), "#e8c48a")
    fl(c, R(c, cx - rx + 2, cy + ry + 1, cx + rx - 2, cy + ry + 1), "#8a5a35")
  end
  coracle(30, 28, 7, 2, function()
    part(c, R(c, 30, 14, 30, 28), "#6b4a2e", { noline = true })
    part(c, c:poly({ { 31, 15 }, { 40, 25 }, { 31, 25 } }), "#f4eee0")
  end)
  -- middle coracle with a child poling, green hat
  coracle(51, 41, 8, 3, function()
    gnome(c, 51, 41, { d = -1, upper = true, s = 0.8, hat = "#4f9a45", eyes = "open", arms = { arm({ 4, 6 }, { 8, 2 }, true, true) } })
  end)
  c:fill(c:line({ { 43, 31 }, { 45, 44 } }, 1), "#8a5a35")
  -- my coracle in front, spinning, paddle in the water
  coracle(22, 44, 11, 4, function()
    gnome(c, 22, 44, { d = 1, upper = true, eyes = "open", arms = { arm({ 4, 7 }, { 8, 6 }, true, true), arm({ -4, 6 }, { -6, 4 }, false, true) } })
  end)
  part(c, c:line({ { 32, 40 }, { 35, 49 } }, 2), "#a8703e", { noline = true })
  part(c, c:ellipse(35, 48, 2, 2), "#a8703e")
  -- spin arcs and splashes
  for _, p in ipairs({ { 7, 40 }, { 8, 42 }, { 9, 44 }, { 37, 46 }, { 39, 44 }, { 40, 41 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#e8f4f8") end
  fl(c, R(c, 5, 47, 9, 47), "#e8f4f8"); fl(c, R(c, 36, 49, 40, 49), "#e8f4f8")
  finish(c, "w3_coracle_race")
end

local order = { "moss_roller", "moss_remembers", "bellringer_hours", "landing_net", "read_tide", "sprat_rack", "gale_moor", "dropped_kettle", "smoke_trout", "samphire_salad", "crab_shell_meal", "tar_rowboat", "loose_planks", "shadow_puppets", "coracle_race" }
for _, s2 in ipairs(order) do
  if not only or only == "w3_" .. s2 or only == s2 then seed = 7; S[s2]() end
end
