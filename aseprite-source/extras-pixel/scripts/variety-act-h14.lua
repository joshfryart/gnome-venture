-- variety-act-h14.lua : regional (ESA) Do-tab scenes -> act-<slug>.png (144x108, drawn on 72x54, out=2). Param only=<slug>, out=<dir>/
-- Copied from variety-act-g5.lua (gnome sprite, frame copy, helpers).
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
local order = {}
local S = setmetatable({}, { __newindex = function(t, k, v) rawset(t, k, v); order[#order + 1] = k end })

---------------------------------------------------------------- shared props
local function acacia(c, x, yb, w, h)
  part(c, R(c, x - 1, yb - h, x, yb), "#6b4a2e", { noline = true })
  fl(c, c:line({ { x, yb - h + 2 }, { x - w + 3, yb - h - 2 } }, 1), "#6b4a2e")
  fl(c, c:line({ { x - 1, yb - h + 2 }, { x + w - 3, yb - h - 2 } }, 1), "#6b4a2e")
  part(c, c:ellipse(x, yb - h - 2, w, 3), "#5a8a3a", { shade = true })
  c:fill(c:ellipse(x - 1, yb - h - 3, w - 3, 1), "#86b050")
end
local function hut(c, cx, yb, w, wh, rh, roofc, ringc)
  part(c, R(c, cx - w, yb - wh, cx + w, yb), "#c08a58")
  fl(c, R(c, cx - 1, yb - wh + 3, cx + 1, yb), "#3d2a1c")
  local top = yb - wh - rh
  part(c, c:poly({ { cx, top }, { cx + w + 2, yb - wh + 1 }, { cx - w - 2, yb - wh + 1 } }), roofc or "#d9b85a")
  for k = 1, 3 do
    local y = top + floor(k * (rh + 1) / 4)
    local hw = floor((y - top) * (w + 2) / (rh + 1))
    if hw > 1 then fl(c, R(c, cx - hw + 1, y, cx + hw - 1, y), ringc or "#b08a36") end
  end
end
local function puff(c, x, y, col) c:fill(c:ellipse(x, y, 2, 1), col or "#f4f8fa"); c:fill(R(c, x - 1, y + 1, x, y + 1), "#dfe8ea") end
local function flame(c, x, y, h)
  part(c, c:poly({ { x, y - h }, { x + 4, y - 3 }, { x + 4, y }, { x - 4, y }, { x - 4, y - 3 } }), "#e0501f")
  c:fill(c:poly({ { x, y - h + 3 }, { x + 2, y - 2 }, { x + 2, y }, { x - 2, y }, { x - 2, y - 2 } }), "#ffd86a")
end
local function stones3(c, x, y)
  for i = -1, 1 do part(c, c:ellipse(x + i * 6, y, 3, 2), "#8b8f96", { shade = true }) end
end
local function hand(c, x, y) fl(c, R(c, x - 1, y - 1, x + 1, y + 1), "#f0c8a0") end
local function cloudy(c, g, x) c:fill(c:ellipse(x, 10, 8, 2), "#f4eee0"); c:fill(c:ellipse(x + 4, 8, 5, 2), "#f4eee0") end
local function hill(c, g, col, col2)
  c:fill(c:ellipse(18, g + 2, 34, 11), col); c:fill(c:ellipse(60, g + 3, 30, 9), col2)
end
local function drycolors() return { sky = { "#e8d9a8", "#efe2b4", "#f4eac4" }, hill = "#b89a5a", hill2 = "#a8884a", grass = "#c9a96e", edge = "#dcc088" } end

-- 1. sorghum porridge: stirring a big pot with a long paddle
function S.r_esa_sorghum_porridge()
  seed = 1; local c = new()
  day(c, 34, { cloud = 52 })
  hut(c, 14, 37, 8, 8, 9)
  stones3(c, 50, 47)
  flame(c, 50, 46, 7)
  part(c, c:ellipse(50, 41, 9, 7), "#9a4e30", { shade = true })
  part(c, c:ellipse(50, 36, 9, 2), "#7a3a24")
  c:fill(c:ellipse(50, 36, 7, 1), "#e8c070")
  puff(c, 47, 31); puff(c, 52, 28); puff(c, 48, 25)
  local _, G = gnome(c, 30, 47, { s = 1.15, d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 8, 10 }, true) } })
  local hx, hy = G.P(8, 10)
  fl(c, c:line({ { hx + 4, hy - 6 }, { 49, 38 } }, 2), "#a8703e"); fl(c, R(c, hx + 3, hy - 8, hx + 5, hy - 6), "#a8703e")
  hand(c, hx, hy)
  -- sorghum sack and milk jug
  part(c, c:ellipse(64, 45, 5, 5), "#d9b070"); fl(c, R(c, 62, 39, 66, 40), "#8a5a35")
  for _, p in ipairs({ { 62, 44 }, { 65, 46 }, { 63, 47 } }) do c:px(p[1], p[2], "#a8442e") end
  part(c, R(c, 19, 42, 22, 47), "#f4eee0"); fl(c, R(c, 19, 41, 22, 41), "#8a5a35")
  finish(c, "r_esa_sorghum_porridge")
end

-- 2. enset fibre: scraping a green stem, pale fibres, cord coil, river and raft
function S.r_esa_enset_fibre()
  seed = 2; local c = new()
  day(c, 33, { cloud = 14 })
  c:fill(R(c, 0, 33, W - 1, 38), "#58a4b8"); fl(c, R(c, 6, 35, 10, 35), "#a8dce4"); fl(c, R(c, 40, 37, 46, 37), "#a8dce4")
  part(c, R(c, 52, 30, 68, 33), "#a8703e"); fl(c, R(c, 52, 31, 68, 31), "#8a5a35")
  fl(c, R(c, 62, 22, 62, 30), "#6b4a2e"); part(c, c:poly({ { 62, 22 }, { 68, 29 }, { 56, 29 } }), "#e8d8b0")
  -- enset plant (big leaves) at left
  for _, l in ipairs({ { 9, 31, 4 }, { 14, 28, 5 }, { 5, 30, 5 } }) do
    fl(c, c:line({ { 9, 40 }, { l[1], l[2] } }, 1), "#4e8a3c")
    part(c, c:ellipse(l[1], l[2] - 2, l[3], 2), "#5ea04a", { shade = true })
  end
  -- stem on a slanted board, with pale fibres
  part(c, c:poly({ { 36, 46 }, { 58, 38 }, { 61, 41 }, { 38, 49 } }), "#8a5a35")
  part(c, c:ellipse(52, 41, 11, 3), "#7ab55c")
  c:fill(c:ellipse(51, 40, 8, 1), "#a8d880")
  for i = 0, 5 do fl(c, c:line({ { 44 + i * 2, 44 - i }, { 41 + i * 2, 49 } }, 1), "#f0e4c0") end
  for i = 0, 3 do fl(c, R(c, 60 + i, 43 + i * 2, 61 + i, 44 + i * 2), "#f0e4c0") end
  local _, G = gnome(c, 24, 47, { s = 1.15, d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 7 }, { 8, 8 }, true) } })
  local hx, hy = G.P(8, 8)
  fl(c, c:line({ { hx, hy }, { hx + 9, hy - 2 } }, 2), "#d9c090"); hand(c, hx, hy)
  -- coil of cord
  part(c, c:ellipse(11, 46, 5, 3), "#f0e4c0"); c:fill(c:ellipse(11, 46, 2, 1), "#a8703e"); fl(c, R(c, 8, 45, 14, 45), "#d9c090")
  finish(c, "r_esa_enset_fibre")
end

-- 3. fruit bowl: behind a board table, splitting a watermelon, bananas
function S.r_esa_fruit_bowl()
  seed = 3; local c = new()
  day(c, 30, { cloud = 50, sky = { "#9ccfe0", "#b4dce4", "#cfe8e6" } })
  for _, t in ipairs({ { 9, 36 }, { 62, 35 } }) do
    part(c, R(c, t[1] - 1, t[2] - 12, t[1] + 1, t[2]), "#6b4a2e", { noline = true })
    part(c, c:ellipse(t[1], t[2] - 15, 7, 6), "#3f8a42", { shade = true })
    for _, p in ipairs({ { -3, -16 }, { 2, -13 }, { 4, -17 } }) do c:px(t[1] + p[1], t[2] + p[2], "#e8a317") end
  end
  gnome(c, 34, 41, { upper = true, s = 1.2, d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -9, 3 }, true), arm({ 4, 8 }, { 8, 4 }, true) } })
  part(c, R(c, 2, 38, 69, 48), "#b07a45"); fl(c, R(c, 3, 38, 68, 39), "#d9a660")
  for _, x in ipairs({ 14, 30, 46, 60 }) do fl(c, R(c, x, 41, x, 47), "#8a4f2a") end
  -- watermelon halves
  part(c, c:ellipse(18, 36, 8, 4), "#2f7a3a")
  c:fill(c:ellipse(18, 35, 7, 3), "#e8504a"); c:fill(c:ellipse(18, 35, 5, 2), "#ff6a60")
  for _, x in ipairs({ 14, 17, 20, 22 }) do c:px(x, 35, INK) end
  part(c, c:poly({ { 49, 38 }, { 61, 38 }, { 58, 32 }, { 52, 32 } }), "#2f7a3a")
  c:fill(c:poly({ { 51, 37 }, { 59, 37 }, { 57, 33 }, { 53, 33 } }), "#e8504a")
  c:px(54, 35, INK); c:px(57, 35, INK)
  -- banana bunch + knife
  fl(c, c:line({ { 26, 34 }, { 31, 37 } }, 2), "#f2d04a"); fl(c, c:line({ { 25, 36 }, { 30, 38 } }, 2), "#f2d04a")
  c:px(25, 33, "#6b4a2e"); c:px(25, 34, "#6b4a2e")
  fl(c, R(c, 42, 37, 46, 37), "#cfd6dc"); fl(c, R(c, 47, 37, 48, 37), "#6b3b2a")
  -- drips
  c:px(18, 40, "#ff6a60"); c:px(55, 40, "#e8504a")
  finish(c, "r_esa_fruit_bowl")
end

-- 4. peanut and collard stew: tasting a spoonful, camp tent, collard basket
function S.r_esa_peanut_collards()
  seed = 4; local c = new()
  day(c, 33, { cloud = 56 })
  part(c, c:poly({ { 15, 18 }, { 26, 33 }, { 4, 33 } }), "#e8d2a0")
  c:fill(c:poly({ { 15, 24 }, { 19, 33 }, { 11, 33 } }), "#6b3b2a")
  stones3(c, 50, 46); flame(c, 50, 45, 6)
  part(c, c:ellipse(50, 40, 9, 6), "#3a3a42", { shade = true })
  part(c, c:ellipse(50, 35, 9, 2), "#2a2a30")
  c:fill(c:ellipse(50, 35, 7, 1), "#8a5a2a"); c:fill(c:ellipse(48, 35, 3, 1), "#4e9a48")
  puff(c, 46, 30); puff(c, 52, 27)
  -- collard basket
  part(c, c:ellipse(63, 45, 5, 3), "#b07a45")
  for _, p in ipairs({ { 60, 40 }, { 63, 38 }, { 66, 40 } }) do part(c, c:ellipse(p[1], p[2], 2, 3), "#4e9a48", { noline = true }) end
  for _, p in ipairs({ { 8, 47 }, { 11, 48 }, { 14, 47 } }) do part(c, c:ellipse(p[1], p[2], 1, 1), "#c08a52") end
  local _, G = gnome(c, 33, 47, { s = 1.2, d = 1, eyes = "happy", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 7, 15 }, true, true) } })
  local hx, hy = G.P(7, 15)
  fl(c, R(c, hx, hy - 1, hx + 4, hy), "#a8703e"); part(c, c:ellipse(hx + 5, hy - 1, 2, 1), "#6b3b2a", { noline = true })
  fl(c, R(c, hx - 1, hy, hx + 1, hy + 2), "#f0c8a0")
  finish(c, "r_esa_peanut_collards")
end

-- 5. winnow teff: tossing grain from a flat basket, chaff blows away
function S.r_esa_winnow_teff()
  seed = 5; local c = new()
  day(c, 35, { cloud = 20, sky = { "#b0d8e0", "#c4e0e2", "#d8ecde" } })
  fl(c, R(c, 0, 36, W - 1, H - 1), "#c9a96e")
  fl(c, R(c, 20, 44, 52, 49), "#e8d8b0")
  c:fill(c:ellipse(38, 44, 9, 3), "#a8442e"); c:fill(c:ellipse(38, 43, 6, 2), "#c4623a")
  hut(c, 62, 37, 6, 7, 8)
  local _, G = gnome(c, 25, 47, { s = 1.15, d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 8, 13 }, true, true) } })
  local hx, hy = G.P(8, 13)
  part(c, c:ellipse(hx + 1, hy, 5, 2), "#b07a45"); fl(c, R(c, hx - 4, hy - 1, hx + 6, hy - 1), "#d9a660")
  hand(c, hx - 3, hy + 1)
  -- falling grain stream (to the pile) and chaff blown right
  for i = 0, 8 do c:px(hx + 2 + floor(i * 0.9), hy + 2 + i, "#a8442e") end
  for _, p in ipairs({ { 36, 22 }, { 40, 19 }, { 44, 23 }, { 48, 17 }, { 52, 21 }, { 56, 15 }, { 43, 27 }, { 51, 28 } }) do
    fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#f0e4c0")
  end
  for _, y in ipairs({ 20, 25, 30 }) do fl(c, R(c, 34 + y % 7, y + 1, 41 + y % 7, y + 1), "#dfeaee") end
  finish(c, "r_esa_winnow_teff")
end

-- 6. shade terraces: stepped coffee terraces, planting a sapling
function S.r_esa_shade_terraces()
  seed = 6; local c = new()
  c:bands(R(c, 0, 0, W - 1, 22), { "#b8d4de", "#cfe0e4", "#e0ece8" }, { dir = "v" })
  c:fill(c:ellipse(60, 20, 22, 9), "#8aa8c0"); c:fill(c:ellipse(12, 22, 26, 8), "#98b4c8")
  c:fill(c:ellipse(30, 11, 10, 2), "#f4f8f6")
  local rows = { { 22, "#4e8a3c" }, { 31, "#5e9a46" }, { 40, "#4e8a3c" } }
  c:fill(R(c, 0, 22, W - 1, H - 1), "#6a4a34")
  for i, r in ipairs(rows) do
    c:fill(R(c, 0, r[1], W - 1, r[1] + 7), r[2])
    fl(c, R(c, 0, r[1], W - 1, r[1]), "#7ab55c")
    fl(c, R(c, 0, r[1] + 8, W - 1, r[1] + 9), "#6a4a34")
    for x = 4 + i * 2, 66, 8 do
      part(c, c:ellipse(x, r[1] + 3, 3, 2), "#2f6a2f", { noline = true })
      c:px(x - 1, r[1] + 3, "#d83a3a"); c:px(x + 1, r[1] + 2, "#d83a3a")
    end
  end
  fl(c, R(c, 0, 49, W - 1, H - 1), "#4e8a3c")
  -- young shade trees planted along the middle terrace
  for _, x in ipairs({ 12, 44, 62 }) do
    fl(c, R(c, x, 25, x, 31), "#7a4a2a"); part(c, c:ellipse(x, 24, 3, 3), "#3f8a42", { noline = true })
  end
  local _, G = gnome(c, 28, 47, { s = 1.2, d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 7 }, { 9, 5 }, true) } })
  local hx, hy = G.P(9, 5)
  fl(c, R(c, hx + 1, hy - 4, hx + 1, hy + 3), "#7a4a2a"); part(c, c:ellipse(hx + 1, hy - 6, 3, 3), "#3f8a42", { noline = true })
  hand(c, hx, hy)
  part(c, c:ellipse(hx + 1, hy + 5, 4, 1), "#4a2f1e", { noline = true })
  -- watering can bit and shovel
  fl(c, c:line({ { 8, 48 }, { 14, 42 } }, 1), "#8a5a35"); fl(c, R(c, 6, 47, 9, 49), "#aeb4bc")
  finish(c, "r_esa_shade_terraces")
end

-- 7. rethatch: a round hut half thatched, ladder, gnome with grass bundle
function S.r_esa_rethatch()
  seed = 7; local c = new()
  day(c, 38, { cloud = 14, sky = { "#b0d4e4", "#c4e0e4", "#d8ecdc" } })
  -- big round hut
  part(c, R(c, 30, 30, 56, 47), "#c08a58")
  for _, y in ipairs({ 34, 38, 42 }) do fl(c, R(c, 31, y, 55, y), "#a8703e") end
  fl(c, R(c, 40, 38, 46, 47), "#3d2a1c")
  -- poles bare at top, thatch rings below
  local top = 9
  part(c, c:poly({ { 43, top }, { 61, 31 }, { 25, 31 } }), "#d9b85a")
  c:fill(c:poly({ { 43, top + 1 }, { 46, 18 }, { 40, 18 } }), "#8a5a35")
  for k = 1, 4 do fl(c, c:line({ { 43, top }, { 25 + k * 7, 31 } }, 1), "#6b4a2e") end
  for _, y in ipairs({ 25, 28 }) do
    local hw = floor((y - top) * 18 / 22)
    fl(c, R(c, 43 - hw + 1, y, 43 + hw - 1, y), "#b08a36")
  end
  fl(c, R(c, 28, 30, 58, 31), "#b08a36")
  -- ladder
  part(c, R(c, 59, 20, 60, 47), "#8a5a35", { noline = true }); part(c, R(c, 64, 20, 65, 47), "#8a5a35", { noline = true })
  for y = 24, 46, 5 do fl(c, R(c, 61, y, 63, y), "#a8703e") end
  local _, G = gnome(c, 17, 47, { s = 1.2, d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 10, 16 }, true) } })
  local hx, hy = G.P(10, 16)
  part(c, c:poly({ { hx - 2, hy + 4 }, { hx + 5, hy + 4 }, { hx + 3, hy - 6 }, { hx, hy - 6 } }), "#e8d078")
  fl(c, R(c, hx - 2, hy + 1, hx + 5, hy + 1), "#8a5a35")
  for i = 0, 3 do fl(c, R(c, hx + i, hy - 8 + (i % 2), hx + i, hy - 6), "#e8d078") end
  hand(c, hx - 1, hy + 4)
  for _, p in ipairs({ { 8, 47 }, { 12, 48 }, { 24, 48 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#e8d078") end
  fl(c, R(c, 5, 22, 6, 23), "#c8802a"); c:px(8, 26, "#c8802a")
  finish(c, "r_esa_rethatch")
end

-- 8. firebreak: raking dry brush off a wide trail among proteas, summer heat
function S.r_esa_firebreak()
  seed = 8; local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#f0e0a8", "#f4e8b8", "#f6eec8" }, { dir = "v" })
  c:fill(c:ellipse(58, 11, 5, 5), "#fff1c8"); c:fill(c:ellipse(58, 11, 3, 3), "#fff8e0")
  c:fill(c:ellipse(18, 32, 34, 12), "#8a8a6a"); c:fill(c:ellipse(56, 33, 26, 8), "#9a9a74")
  -- lookout tower on the ridge
  part(c, R(c, 8, 20, 10, 32), "#6b4a2e", { noline = true }); part(c, R(c, 5, 15, 13, 20), "#a8703e")
  part(c, c:poly({ { 9, 11 }, { 15, 15 }, { 3, 15 } }), "#8a4f2a")
  c:fill(R(c, 0, 32, W - 1, H - 1), "#7a8a4a")
  -- pale trail winding down
  c:fill(c:poly({ { 28, 32 }, { 44, 32 }, { 68, 54 }, { 6, 54 } }), "#d9c090")
  c:fill(c:poly({ { 31, 32 }, { 41, 32 }, { 58, 52 }, { 16, 52 } }), "#e4cfa0")
  -- brush piles at the trail edges, proteas on the scrub
  for _, p in ipairs({ { 20, 38 }, { 56, 36 }, { 12, 46 }, { 62, 44 } }) do
    part(c, c:ellipse(p[1], p[2], 4, 3), "#8a6a34", { shade = true }); fl(c, R(c, p[1] - 2, p[2], p[1] + 2, p[2]), "#6b4a24")
  end
  for _, p in ipairs({ { 9, 40 }, { 66, 40 }, { 4, 34 }, { 48, 34 } }) do
    fl(c, R(c, p[1], p[2], p[1], p[2] + 4), "#4e6a34"); part(c, c:ellipse(p[1], p[2], 2, 2), "#d85a7a", { noline = true }); c:px(p[1], p[2], "#f6c8d4")
  end
  local _, G = gnome(c, 36, 47, { s = 1.2, d = -1, walk = -1, eyes = "open", arms = { arm({ -4, 7 }, { -9, 6 }, true), arm({ 4, 6 }, { -3, 4 }, false) } })
  local hx, hy = G.P(-9, 6)
  fl(c, c:line({ { hx - 1, hy - 9 }, { hx - 5, hy + 7 } }, 1), "#8a5a35")
  fl(c, R(c, hx - 9, hy + 6, hx - 2, hy + 8), "#6b4a24"); for x = hx - 8, hx - 2, 2 do c:px(x, hy + 9, "#6b4a24") end
  hand(c, hx, hy)
  for i = 0, 3 do fl(c, R(c, 44 + i * 5, 24 - (i % 2), 46 + i * 5, 24 - (i % 2)), "#f8f0c0") end
  finish(c, "r_esa_firebreak")
end

-- 9. seed pits: mancala board in the foreground, sowing seeds into a pit, inn wall behind
function S.r_esa_seed_pits()
  seed = 9; local c = new()
  c:fill(R(c, 0, 0, W - 1, 34), "#c9a96e")
  for x = 0, W - 1, 6 do fl(c, R(c, x, 0, x, 34), "#b8965c") end
  fl(c, R(c, 0, 6, W - 1, 6), "#8a5a35")
  c:fill(R(c, 0, 35, W - 1, H - 1), "#8a5a35")
  -- window with warm light
  part(c, R(c, 52, 10, 64, 24), "#a8703e"); c:fill(R(c, 54, 12, 62, 22), "#a8d4e0"); fl(c, R(c, 58, 12, 58, 22), "#a8703e")
  gnome(c, 28, 38, { upper = true, s = 1.2, d = 1, eyes = "open", arms = { arm({ 5, 7 }, { 10, 9 }, true) } })
  -- the board with two rows of pits
  part(c, R(c, 4, 36, 67, 49), "#a8582f")
  fl(c, R(c, 5, 37, 66, 37), "#c87a42")
  for i = 0, 5 do
    for r = 0, 1 do
      local x, y = 11 + i * 10, 40 + r * 6
      part(c, c:ellipse(x, y, 4, 2), "#5e2f1e", { noline = true })
      local n = (i * 2 + r * 3) % 4
      for k = 0, n - 1 do c:px(x - 1 + (k % 2) * 2, y - (k > 1 and 1 or 0), (k % 2 == 0) and "#f4eee0" or "#d9a660") end
    end
  end
  -- the seeds being sown
  fl(c, R(c, 40, 29, 42, 31), "#f0c8a0")
  for _, p in ipairs({ { 41, 33 }, { 43, 35 }, { 44, 31 } }) do c:px(p[1], p[2], "#f4eee0") end
  finish(c, "r_esa_seed_pits")
end

-- 10. clap song: a ring of three, centre gnome clapping, two small kids with their own hat colours
function S.r_esa_clap_song()
  seed = 10; local c = new()
  day(c, 33, { cloud = 50 })
  acacia(c, 62, 36, 10, 14)
  gnome(c, 12, 47, { s = 0.85, d = 1, eyes = "happy", hat = "#e8a317", arms = { arm({ 3, 8 }, { 6, 9 }, true) } })
  gnome(c, 58, 47, { s = 0.85, d = -1, eyes = "happy", hat = "#3f8fb0", arms = { arm({ -3, 8 }, { -6, 9 }, true) } })
  local _, G = gnome(c, 33, 47, { s = 1.2, d = 1, eyes = "happy", arms = { arm({ -4, 8 }, { -7, 17 }, true), arm({ 4, 8 }, { 7, 17 }, true) } })
  local hx, hy = G.P(0, 22)
  for _, p in ipairs({ { hx - 7, hy + 1 }, { hx - 1, hy - 3 }, { hx + 5, hy + 1 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#f5cf6a") end
  -- notes
  for _, p in ipairs({ { 20, 18 }, { 50, 16 }, { 56, 24 } }) do
    fl(c, R(c, p[1], p[2], p[1], p[2] + 4), "#6b3b2a"); fl(c, R(c, p[1] - 1, p[2] + 4, p[1], p[2] + 5), "#6b3b2a"); fl(c, R(c, p[1] + 1, p[2], p[1] + 2, p[2] + 1), "#6b3b2a")
  end
  for _, x in ipairs({ 7, 15, 20, 52, 60 }) do c:px(x, 44, "#9cc070") end
  -- dust ring
  for _, p in ipairs({ { 24, 48 }, { 46, 48 }, { 29, 49 }, { 41, 49 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#d9c090") end
  finish(c, "r_esa_clap_song")
end

-- 11. hippo, heron, fish: hand signs on a jetty, a yawning hippo and a heron beyond
function S.r_esa_hippo_heron()
  seed = 11; local c = new()
  c:bands(R(c, 0, 0, W - 1, 24), { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  c:fill(c:ellipse(14, 10, 8, 2), "#f4eee0")
  c:fill(c:ellipse(60, 25, 30, 5), "#5e8a44")
  c:fill(R(c, 0, 24, W - 1, H - 1), "#4a9ab8")
  for _, p in ipairs({ { 8, 28 }, { 28, 30 }, { 44, 27 }, { 60, 31 }, { 20, 34 }, { 50, 36 } }) do fl(c, R(c, p[1], p[2], p[1] + 4, p[2]), "#8ccbdc") end
  -- hippo in the water at right, mouth open
  part(c, c:ellipse(56, 32, 11, 6), "#8a6a84", { shade = true })
  part(c, c:ellipse(60, 28, 7, 5), "#9a7a94")
  c:fill(c:poly({ { 58, 29 }, { 68, 25 }, { 68, 32 } }), "#d86a7a")
  c:fill(R(c, 62, 27, 63, 28), "#f4eee0"); c:fill(R(c, 65, 29, 66, 30), "#f4eee0")
  part(c, R(c, 52, 23, 53, 25), "#8a6a84", { noline = true }); part(c, R(c, 57, 22, 58, 24), "#8a6a84", { noline = true })
  c:px(56, 26, INK); c:px(57, 26, "#f4eee0")
  -- heron on a post
  part(c, R(c, 36, 24, 37, 34), "#6b4a2e", { noline = true })
  part(c, c:ellipse(36, 20, 3, 3), "#aeb4bc", { noline = true })
  fl(c, R(c, 36, 12, 36, 18), "#aeb4bc"); fl(c, R(c, 37, 12, 40, 12), "#e8a317"); c:px(35, 12, "#2a1a10")
  fl(c, R(c, 36, 23, 36, 26), "#e8a317")
  -- jetty
  part(c, R(c, 0, 40, 40, 44), "#a8703e"); fl(c, R(c, 0, 40, 40, 40), "#c89050")
  for _, x in ipairs({ 6, 20, 34 }) do part(c, R(c, x, 44, x + 1, 52), "#6b4a2e", { noline = true }) end
  gnome(c, 18, 40, { s = 1.2, d = 1, sit = true, eyes = "open", arms = { arm({ -3, 6 }, { -4, 3 }, false), arm({ 4, 8 }, { 7, 15 }, true, true) } })
  -- hand sign: fish wriggling in the water, splash
  fl(c, R(c, 25, 24, 27, 26), "#f0c8a0")
  part(c, c:ellipse(46, 46, 4, 2), "#7aa8d0", { noline = true }); fl(c, R(c, 49, 45, 51, 47), "#7aa8d0"); c:px(44, 45, INK)
  finish(c, "r_esa_hippo_heron")
end

-- 12. hand shadows: dusk hut interior, lamp on a stool, a giraffe shadow on the wall
function S.r_esa_hand_shadows()
  seed = 12; local c = new()
  c:fill(R(c, 0, 0, W - 1, 40), "#5a3a2e")
  for x = 0, W - 1, 5 do fl(c, R(c, x, 0, x, 40), "#4a2f26") end
  -- lamp-lit wall glow
  c:fill(c:ellipse(40, 22, 28, 18), "#8a5a3a"); c:fill(c:ellipse(40, 22, 22, 14), "#b07a4a"); c:fill(c:ellipse(40, 22, 14, 9), "#d9a060")
  c:fill(R(c, 0, 41, W - 1, H - 1), "#3a2418")
  fl(c, R(c, 0, 41, W - 1, 41), "#2a1a10")
  -- giraffe shadow
  local sh = "#2a1a10"
  fl(c, R(c, 38, 25, 46, 31), sh); fl(c, R(c, 40, 31, 41, 36), sh); fl(c, R(c, 44, 31, 45, 36), sh)
  fl(c, c:line({ { 40, 25 }, { 36, 11 } }, 2), sh); fl(c, R(c, 33, 9, 38, 11), sh); c:px(34, 8, sh); c:px(36, 7, sh); c:px(47, 26, sh); c:px(48, 27, sh)
  -- stool + lamp
  part(c, R(c, 50, 40, 58, 46), "#6b4a2e"); fl(c, R(c, 50, 40, 58, 40), "#8a5a35")
  part(c, R(c, 52, 33, 56, 39), "#8a5a35"); part(c, c:ellipse(54, 31, 3, 3), "#ffd86a", { noline = true }); c:px(54, 31, "#fff8e0")
  fl(c, R(c, 53, 28, 55, 28), "#3d2a1c")
  for _, p in ipairs({ { 48, 29 }, { 60, 31 }, { 51, 26 } }) do c:px(p[1], p[2], "#f8c070") end
  -- gnome with a raised hand
  gnome(c, 18, 47, { s = 1.2, d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 9 }, { 9, 17 }, true) } })
  fl(c, R(c, 4, 6, 6, 7), "#f5e6a8"); fl(c, R(c, 62, 8, 64, 9), "#f5e6a8")
  finish(c, "r_esa_hand_shadows")
end

-- 13. migration: lookout platform, spyglass, a long herd on the plain
function S.r_esa_migration()
  seed = 13; local c = new()
  c:bands(R(c, 0, 0, W - 1, 28), { "#e8c88a", "#f0d49a", "#f4e0b0" }, { dir = "v" })
  c:fill(c:ellipse(20, 11, 7, 7), "#fff1c8")
  c:fill(c:ellipse(34, 29, 40, 5), "#c9a06a")
  c:fill(R(c, 0, 29, W - 1, H - 1), "#c9a96e")
  fl(c, R(c, 0, 29, W - 1, 29), "#dcc088")
  acacia(c, 62, 30, 8, 10)
  -- the herd: rows of dark shapes, zebra stripes, giraffes
  local function gnu(x, y) fl(c, R(c, x, y, x + 3, y + 1), "#4a3a34"); fl(c, R(c, x + 3, y - 1, x + 4, y), "#4a3a34"); fl(c, R(c, x, y + 2, x, y + 3), "#4a3a34"); fl(c, R(c, x + 3, y + 2, x + 3, y + 3), "#4a3a34") end
  local function zeb(x, y) fl(c, R(c, x, y, x + 3, y + 1), "#f4eee0"); fl(c, R(c, x + 3, y - 1, x + 4, y), "#f4eee0"); fl(c, R(c, x, y + 2, x, y + 3), "#f4eee0"); fl(c, R(c, x + 3, y + 2, x + 3, y + 3), "#f4eee0"); c:px(x + 1, y, INK); c:px(x + 2, y + 1, INK) end
  for _, p in ipairs({ { 28, 33 }, { 40, 34 }, { 52, 33 }, { 34, 38 }, { 58, 38 }, { 46, 42 }, { 30, 44 }, { 62, 45 }, { 18, 41 } }) do gnu(p[1], p[2]) end
  for _, p in ipairs({ { 24, 36 }, { 46, 36 }, { 38, 41 }, { 54, 43 }, { 36, 47 } }) do zeb(p[1], p[2]) end
  for _, p in ipairs({ { 50, 30 }, { 66, 32 } }) do fl(c, R(c, p[1], p[2] - 6, p[1], p[2]), "#d9a640"); fl(c, R(c, p[1] - 1, p[2] - 7, p[1] + 1, p[2] - 6), "#d9a640"); fl(c, R(c, p[1] - 2, p[2], p[1] + 2, p[2] + 2), "#d9a640") end
  -- dust haze
  for _, p in ipairs({ { 30, 31 }, { 44, 32 }, { 56, 32 } }) do fl(c, R(c, p[1], p[2], p[1] + 4, p[2]), "#f0dcaa") end
  -- lookout platform on posts, gnome with a long spyglass
  part(c, R(c, 3, 28, 4, 46), "#6b4a2e", { noline = true }); part(c, R(c, 19, 28, 20, 46), "#6b4a2e", { noline = true })
  part(c, R(c, 0, 26, 24, 29), "#a8703e")
  fl(c, R(c, 0, 26, 24, 26), "#c89050")
  for y = 31, 42, 6 do fl(c, c:line({ { 4, y }, { 19, y + 5 } }, 1), "#8a5a35") end
  local _, G = gnome(c, 12, 26, { s = 1.0, d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 11 }, { 8, 12 }, true) } })
  local hx, hy = G.P(8, 12)
  part(c, c:line({ { hx, hy }, { hx + 10, hy - 2 } }, 2), "#6b4a2e", { noline = true }); fl(c, R(c, hx + 10, hy - 3, hx + 12, hy - 1), "#e8a317")
  hand(c, hx - 1, hy)
  finish(c, "r_esa_migration")
end

-- 14. fynbos: a gnome sniffing a king protea, flat mountain behind
function S.r_esa_fynbos()
  seed = 14; local c = new()
  day(c, 34, { cloud = 50, hill = "#7a8a5a", hill2 = "#6a8a50", grass = "#8aa05a" })
  c:fill(R(c, 14, 14, 46, 28), "#8a98a8"); c:fill(c:poly({ { 8, 28 }, { 14, 14 }, { 46, 14 }, { 54, 28 } }), "#8a98a8")
  c:fill(R(c, 16, 14, 44, 16), "#a8b4c0"); c:fill(c:ellipse(24, 14, 10, 1), "#f4f8f6"); c:fill(c:ellipse(40, 13, 8, 1), "#f4f8f6")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#8aa05a"); fl(c, R(c, 0, 34, W - 1, 34), "#a8b870")
  -- king protea big
  local function protea(x, y, r)
    fl(c, R(c, x, y + 2, x, 48), "#4e6a34"); fl(c, R(c, x - 3, y + 8, x - 1, y + 9), "#4e8a3c"); fl(c, R(c, x + 1, y + 12, x + 4, y + 13), "#4e8a3c")
    part(c, c:ellipse(x, y, r, r - 1), "#e0607a", { shade = true })
    c:fill(c:ellipse(x, y - 1, r - 2, r - 3), "#f6c8d0"); c:fill(c:ellipse(x, y - 1, r - 4, r - 5), "#f4eee0")
    fl(c, R(c, x - 1, y - 2, x + 1, y), "#8a4a5a")
  end
  protea(54, 36, 6); protea(64, 40, 4); protea(8, 42, 4)
  for _, p in ipairs({ { 24, 40 }, { 30, 44 }, { 46, 45 }, { 62, 47 } }) do c:px(p[1], p[2], "#e8a317"); c:px(p[1] + 1, p[2], "#f5cf6a"); c:px(p[1], p[2] + 1, "#d83a3a") end
  gnome(c, 32, 47, { s = 1.2, d = 1, eyes = "shut", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 8 }, { 8, 13 }, true) } })
  -- the flower in hand: pincushion
  fl(c, R(c, 43, 28, 43, 34), "#4e6a34"); part(c, c:ellipse(43, 27, 3, 3), "#f08a24", { noline = true }); c:px(43, 27, "#ffd86a")
  hand(c, 43, 33)
  finish(c, "r_esa_fynbos")
end

-- 15. rift cichlids: cross-section, gnome on the jetty looking down at colourful fish
function S.r_esa_rift_cichlids()
  seed = 15; local c = new()
  c:bands(R(c, 0, 0, W - 1, 22), { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  c:fill(c:ellipse(60, 10, 9, 2), "#f4eee0")
  c:fill(c:ellipse(30, 26, 40, 4), "#5e8a44")
  c:bands(R(c, 0, 27, W - 1, H - 1), { "#58b4c4", "#4aa4b8", "#3a94ac", "#2e7a9a" }, { dir = "v" })
  fl(c, R(c, 0, 27, W - 1, 27), "#a8e6e6")
  fl(c, R(c, 0, 45, W - 1, H - 1), "#a88a5a")
  for _, p in ipairs({ { 8, 44 }, { 30, 45 }, { 58, 44 } }) do part(c, c:ellipse(p[1], p[2], 4, 3), "#7a8a8a", { shade = true }) end
  -- jetty top left
  part(c, R(c, 0, 24, 32, 28), "#a8703e"); fl(c, R(c, 0, 24, 32, 24), "#c89050")
  for _, x in ipairs({ 5, 28 }) do part(c, R(c, x, 28, x + 1, 42), "#6b4a2e", { noline = true }) end
  gnome(c, 14, 24, { s = 1.0, d = 1, sit = true, eyes = "open", arms = { arm({ -3, 6 }, { -4, 3 }, false), arm({ 4, 7 }, { 6, 4 }, true) } })
  -- fish
  local function fish(x, y, col, d, stripe)
    part(c, c:ellipse(x, y, 4, 2), col, { noline = true })
    fl(c, R(c, x + (d > 0 and -6 or 4), y - 1, x + (d > 0 and -4 or 6), y + 1), col)
    c:px(x + (d > 0 and 2 or -2), y - 1, INK)
    if stripe then c:px(x, y - 1, stripe); c:px(x, y, stripe); c:px(x - 1, y + 1, stripe) end
  end
  fish(46, 33, "#3a7ae0", 1, "#9ac8ff"); fish(28, 36, "#f5d03a", -1); fish(58, 38, "#e04a3a", 1, "#8a2a20")
  fish(40, 42, "#f08a24", -1, "#2a1a10"); fish(20, 35, "#4abfa0", 1, "#2a6a60"); fish(62, 31, "#f5d03a", -1, "#2a1a10")
  for _, p in ipairs({ { 36, 33 }, { 52, 34 }, { 24, 40 }, { 66, 34 } }) do c:px(p[1], p[2], "#d8f6f8"); c:px(p[1] + 1, p[2] - 2, "#d8f6f8") end
  finish(c, "r_esa_rift_cichlids")
end

-- 16. cool gourd: four gourds hang in the shade, a hot day; gnome feels one
function S.r_esa_cool_gourd()
  seed = 16; local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#f6e8a8", "#f8eeb8", "#f8f2c8" }, { dir = "v" })
  c:fill(c:ellipse(60, 12, 5, 5), "#fff4c8")
  c:fill(c:ellipse(18, 33, 34, 8), "#d8c080")
  c:fill(R(c, 0, 33, W - 1, H - 1), "#d4b878"); fl(c, R(c, 0, 33, W - 1, 33), "#e6d094")
  -- tree limb / pole with shade and four gourds
  part(c, R(c, 3, 12, 4, 46), "#6b4a2e", { noline = true })
  part(c, R(c, 3, 12, 50, 14), "#7a5434")
  part(c, c:ellipse(28, 11, 24, 4), "#5a8a3a", { shade = true })
  for i = 0, 3 do
    local x = 14 + i * 11
    fl(c, R(c, x, 14, x, 17), "#a8703e")
    local g = i == 2 and "#8ec4d0" or "#c8a050"
    part(c, c:ellipse(x, 21, 3, 4), g, { noline = false }); part(c, c:ellipse(x, 18, 1, 1), g, { noline = true })
    if i == 2 then c:px(x - 1, 20, "#e8f8fc"); c:px(x + 1, 22, "#e8f8fc"); c:px(x, 26, "#9ae0f0"); c:px(x, 28, "#9ae0f0"); c:px(x + 4, 17, "#e8f8fc") end
  end
  -- heat shimmer
  for _, p in ipairs({ { 44, 40 }, { 56, 38 }, { 62, 44 } }) do fl(c, R(c, p[1], p[2], p[1] + 3, p[2]), "#f6e8b0"); fl(c, R(c, p[1] + 1, p[2] - 2, p[1] + 4, p[2] - 2), "#f6e8b0") end
  gnome(c, 36, 47, { s = 1.2, d = -1, eyes = "happy", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 3, 12 }, { -6, 19 }, true) } })
  hand(c, 29, 24)
  fl(c, R(c, 36, 29, 38, 29), "#9ae0f0")
  finish(c, "r_esa_cool_gourd")
end

-- 17. termite mound: three tall red mounds, ear pressed to the middle one
function S.r_esa_termite_mound()
  seed = 17; local c = new()
  day(c, 34, { cloud = 50, sky = { "#e8c88a", "#f0d49a", "#f4e0b0" }, hill = "#b89a5a", hill2 = "#a8884a", grass = "#c9a96e", edge = "#dcc088" })
  acacia(c, 62, 36, 8, 12)
  local function mound(cx, yb, w, h)
    part(c, c:poly({ { cx - 1, yb - h }, { cx + 1, yb - h }, { cx + w, yb }, { cx - w, yb } }), "#b4522e", { shade = true })
    fl(c, R(c, cx - 1, yb - h + 3, cx - 1, yb - 3), "#8a3a22"); fl(c, R(c, cx + 2, yb - h + 6, cx + 2, yb - 2), "#d27a4a")
    c:px(cx, yb - h, "#8a3a22")
  end
  mound(48, 47, 6, 20); mound(15, 46, 5, 14); mound(63, 47, 5, 12)
  local _, G = gnome(c, 37, 47, { s = 1.2, d = 1, eyes = "shut", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 9 }, { 7, 13 }, true, true) } })
  -- tick marks coming out of the busy mound
  for _, p in ipairs({ { 52, 22 }, { 54, 26 }, { 58, 24 }, { 59, 28 } }) do fl(c, R(c, p[1], p[2], p[1], p[2] + 1), "#f5cf6a") end
  finish(c, "r_esa_termite_mound")
end

-- 18. baobab pod: shaking a velvety pod by the ear under a fat baobab
function S.r_esa_baobab_pod()
  seed = 18; local c = new()
  day(c, 35, { cloud = 56, sky = { "#a8d4e0", "#bcdde4", "#d8e8d8" } })
  -- baobab: fat trunk, spidery crown with pods
  part(c, c:poly({ { 6, 49 }, { 9, 24 }, { 22, 24 }, { 26, 49 } }), "#9a8470", { shade = true })
  fl(c, R(c, 12, 28, 12, 44), "#7a6654"); fl(c, R(c, 18, 30, 18, 46), "#7a6654")
  for _, l in ipairs({ { 9, 24, 2, 10 }, { 15, 24, 14, 6 }, { 22, 24, 30, 12 }, { 15, 24, 8, 13 } }) do fl(c, c:line({ { l[1], l[2] }, { l[3], l[4] } }, 2), "#7a6654") end
  for _, p in ipairs({ { 2, 10 }, { 14, 6 }, { 30, 12 }, { 8, 13 } }) do part(c, c:ellipse(p[1], p[2] - 1, 4, 3), "#5a8a3a", { noline = true }) end
  for _, p in ipairs({ { 4, 15 }, { 11, 11 }, { 17, 11 }, { 27, 17 }, { 22, 15 } }) do
    fl(c, R(c, p[1], p[2] - 3, p[1], p[2]), "#6b4a2e"); part(c, c:ellipse(p[1], p[2] + 2, 1, 2), "#b8a070", { noline = true }); c:px(p[1], p[2] + 2, "#d8c490")
  end
  -- gnome with the pod at his ear
  local _, G = gnome(c, 45, 47, { s = 1.2, d = -1, eyes = "happy", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ -3, 9 }, { -6, 15 }, true, true) } })
  local hx, hy = G.P(-6, 15)
  part(c, c:ellipse(hx - 1, hy - 2, 2, 5), "#b8a070"); fl(c, R(c, hx - 2, hy - 2, hx - 2, hy + 1), "#d8c490")
  hand(c, hx + 1, hy)
  -- rattle marks
  for _, p in ipairs({ { hx - 6, hy - 6 }, { hx - 7, hy - 1 }, { hx - 6, hy + 4 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#f5cf6a") end
  -- fruit seller's crate with pods
  part(c, R(c, 58, 42, 67, 48), "#b07a45"); fl(c, R(c, 58, 42, 67, 42), "#d9a660")
  for _, x in ipairs({ 60, 64 }) do part(c, c:ellipse(x, 40, 2, 2), "#b8a070", { noline = true }) end
  finish(c, "r_esa_baobab_pod")
end

-- 19. windpump: lattice windmill, a goat trough, the gnome working the handle
function S.r_esa_windpump()
  seed = 19; local c = new()
  day(c, 36, { cloud = 14, sky = { "#a8d4e0", "#bcdde4", "#dce8d4" }, hill = "#b89a5a", hill2 = "#a8884a", grass = "#d4b878", edge = "#e6d094" })
  c:fill(c:ellipse(56, 34, 14, 5), "#9a7a4a")
  -- tower
  for _, l in ipairs({ { 50, 47, 54, 20 }, { 62, 47, 58, 20 } }) do fl(c, c:line({ { l[1], l[2] } , { l[3], l[4] } }, 1), "#6b6e76") end
  for y = 24, 44, 5 do local hw = floor(2 + (y - 20) * 0.22); fl(c, R(c, 56 - hw, y, 56 + hw, y), "#8a8e96") end
  -- wheel with blades and tail vane
  local wx, wy = 56, 14
  for i = 0, 7 do
    local a = i * math.pi / 4
    fl(c, c:line({ { wx, wy }, { wx + rnd(math.cos(a) * 9), wy + rnd(math.sin(a) * 9) } }, 1), "#aeb4bc")
  end
  c:fill(c:ellipse(wx, wy, 9, 9):clip(R(c, 0, 0, 0, 0)), "#aeb4bc")
  part(c, c:ellipse(wx, wy, 2, 2), "#6b6e76", { noline = true })
  fl(c, R(c, wx + 3, wy - 1, wx + 14, wy), "#8a8e96"); part(c, R(c, wx + 9, wy - 4, wx + 14, wy + 2), "#c0442e")
  -- water flowing into the trough
  part(c, R(c, 36, 41, 52, 47), "#8a5a35"); c:fill(R(c, 37, 41, 51, 43), "#58b4c4")
  fl(c, R(c, 43, 29, 43, 41), "#58b4c4"); part(c, R(c, 40, 24, 46, 29), "#aeb4bc")
  fl(c, R(c, 40, 22, 40, 24), "#aeb4bc"); fl(c, R(c, 39, 21, 47, 22), "#6b3b2a")
  -- goats
  local function goat(x, y)
    fl(c, R(c, x, y - 3, x + 5, y), "#f4eee0"); fl(c, R(c, x + 5, y - 5, x + 7, y - 2), "#f4eee0"); fl(c, R(c, x + 6, y - 7, x + 6, y - 5), "#8a6a44")
    fl(c, R(c, x, y, x, y + 1), "#8a6a44"); fl(c, R(c, x + 4, y, x + 4, y + 1), "#8a6a44"); c:px(x + 6, y - 4, INK)
  end
  goat(60, 47); goat(65, 44)
  local _, G = gnome(c, 20, 47, { s = 1.2, d = 1, eyes = "open", arms = { arm({ -4, 6 }, { -5, 3 }, false), arm({ 4, 7 }, { 9, 9 }, true) } })
  local hx, hy = G.P(9, 9)
  fl(c, c:line({ { hx, hy }, { 33, 33 } }, 2), "#8a5a35"); fl(c, R(c, 32, 31, 35, 34), "#6b6e76")
  hand(c, hx, hy)
  for _, p in ipairs({ { 29, 22 }, { 33, 18 }, { 24, 18 } }) do fl(c, R(c, p[1], p[2], p[1] + 4, p[2]), "#eef4f0") end
  finish(c, "r_esa_windpump")
end

-- 20. pound sorghum: pestle taller than the gnome, a second gnome pounding in time
function S.r_esa_pound_sorghum()
  seed = 20; local c = new()
  day(c, 33, { cloud = 52 })
  hut(c, 14, 36, 7, 7, 8)
  local function mortar(x, yb) part(c, c:poly({ { x - 5, yb - 14 }, { x + 5, yb - 14 }, { x + 4, yb }, { x - 4, yb } }), "#a8703e"); c:fill(c:ellipse(x, yb - 14, 4, 1), "#4a2f1e"); fl(c, R(c, x - 3, yb - 8, x - 3, yb - 2), "#c08a52") end
  mortar(41, 47)
  local _, G = gnome(c, 25, 47, { s = 1.2, d = 1, eyes = "open", arms = { arm({ 4, 9 }, { 11, 17 }, true), arm({ 3, 8 }, { 11, 12 }, true) } })
  part(c, R(c, 38, 8, 40, 34), "#c08a52"); fl(c, R(c, 38, 31, 40, 34), "#a8703e")
  hand(c, 37, 26); hand(c, 37, 32)
  -- second, small gnome on the right
  mortar(56, 47)
  gnome(c, 64, 47, { s = 0.85, d = -1, eyes = "happy", hat = "#3f8fb0", arms = { arm({ -3, 9 }, { -6, 14 }, true) } })
  part(c, R(c, 55, 22, 56, 32), "#c08a52", { noline = true })
  -- grain dust and motion
  for _, p in ipairs({ { 36, 32 }, { 45, 30 }, { 43, 27 }, { 55, 30 }, { 58, 28 } }) do c:px(p[1], p[2], "#e8d078") end
  fl(c, R(c, 34, 8, 35, 10), "#f5cf6a"); fl(c, R(c, 43, 10, 44, 12), "#f5cf6a")
  finish(c, "r_esa_pound_sorghum")
end

-- 21. baobab tales: a baobab's hollow glows, the gnome tells a story inside
function S.r_esa_baobab_tales()
  seed = 21; local c = new()
  c:bands(R(c, 0, 0, W - 1, 22), { "#2a3558", "#3a4a78", "#5a5a88", "#c8788a", "#f0a868" }, { dir = "v" })
  c:fill(R(c, 0, 36, W - 1, H - 1), "#5a7a44"); fl(c, R(c, 0, 36, W - 1, 36), "#7aa05a")
  for _, p in ipairs({ { 8, 6 }, { 26, 4 }, { 60, 8 }, { 66, 18 } }) do c:px(p[1], p[2], "#f4eee0") end
  -- giant trunk filling the middle
  part(c, c:poly({ { 8, 49 }, { 14, 14 }, { 58, 14 }, { 64, 49 } }), "#9a8470", { shade = true })
  for _, x in ipairs({ 19, 26, 46, 53 }) do fl(c, R(c, x, 16, x - 1 + (x > 36 and 2 or 0), 46), "#7a6654") end
  for _, l in ipairs({ { 18, 14, 6, 6 }, { 36, 14, 36, 4 }, { 54, 14, 66, 6 } }) do fl(c, c:line({ { l[1], l[2] }, { l[3], l[4] } }, 2), "#8a7662") end
  for _, p in ipairs({ { 6, 6 }, { 36, 4 }, { 66, 6 } }) do part(c, c:ellipse(p[1], p[2] - 1, 4, 2), "#5a8a3a", { noline = true }) end
  -- the hollow: warm arch
  c:fill(c:poly({ { 26, 49 }, { 26, 30 }, { 29, 24 }, { 43, 24 }, { 46, 30 }, { 46, 49 } }), "#4a2f1e")
  c:fill(c:poly({ { 28, 49 }, { 28, 31 }, { 31, 26 }, { 41, 26 }, { 44, 31 }, { 44, 49 } }), "#d98a40")
  c:fill(c:ellipse(36, 40, 7, 8), "#f0b060")
  fl(c, R(c, 28, 45, 44, 49), "#8a5a35")
  -- seated gnome telling, arm out; lamp beside
  gnome(c, 36, 47, { s = 0.95, d = 1, sit = true, eyes = "open", arms = { arm({ 3, 7 }, { 8, 13 }, true) } })
  -- speech wisps and fruit bats hanging
  for _, p in ipairs({ { 50, 28 }, { 53, 31 }, { 56, 28 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#f5cf6a") end
  for _, x in ipairs({ 22, 50 }) do fl(c, R(c, x, 14, x, 17), "#3a2a2a"); part(c, c:ellipse(x, 19, 1, 2), "#4a3a3a", { noline = true }) end
  c:px(10, 40, "#ffe08a"); c:px(62, 42, "#ffe08a")
  finish(c, "r_esa_baobab_tales")
end

-- 22. coffee smoke: roasting beans in a long-handled pan, smoke curling to a cloud, jebena pot and cups
function S.r_esa_coffee_smoke()
  seed = 22; local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#b8cfd8", "#cfdcdc", "#e0e6e0" }, { dir = "v" })
  c:fill(c:ellipse(14, 28, 30, 9), "#7a9a8a"); c:fill(c:ellipse(60, 30, 26, 8), "#6a8a78")
  c:fill(R(c, 0, 30, W - 1, H - 1), "#5a7a4a"); fl(c, R(c, 0, 30, W - 1, 30), "#7aa05a")
  c:fill(c:ellipse(34, 48, 36, 4), "#c9a96e")
  -- coals
  part(c, c:ellipse(46, 44, 8, 3), "#3a2a24"); for _, p in ipairs({ { 42, 44 }, { 46, 43 }, { 50, 44 }, { 44, 45 } }) do c:px(p[1], p[2], "#e0501f"); c:px(p[1] + 1, p[2], "#ffd86a") end
  -- pan with beans
  part(c, c:ellipse(46, 40, 8, 2), "#3a3a42"); c:fill(c:ellipse(46, 40, 6, 1), "#6b3b2a")
  for _, p in ipairs({ { 43, 39 }, { 46, 40 }, { 49, 39 } }) do c:px(p[1], p[2], "#8a5a35") end
  fl(c, c:line({ { 39, 40 }, { 29, 33 } }, 2), "#6b4a2e")
  -- smoke curls rising to a soft cloud
  local sx = 46
  for i = 0, 7 do fl(c, R(c, sx + floor(math.sin(i * 0.9) * 3), 36 - i * 3, sx + floor(math.sin(i * 0.9) * 3) + 1, 37 - i * 3), "#d8dcdc") end
  c:fill(c:ellipse(48, 9, 9, 3), "#e8ecec"); c:fill(c:ellipse(53, 7, 5, 2), "#f4f8f8")
  -- jebena pot and cups on a mat
  part(c, R(c, 56, 47, 68, 48), "#c0442e", { noline = true })
  part(c, c:ellipse(62, 43, 4, 4), "#2f2a2a"); part(c, R(c, 61, 33, 63, 39), "#2f2a2a"); fl(c, R(c, 59, 33, 61, 33), "#2f2a2a"); fl(c, R(c, 66, 38, 67, 44), "#2f2a2a")
  for _, x in ipairs({ 55, 58 }) do part(c, R(c, x, 46, x + 1, 47), "#f4eee0", { noline = true }) end
  local _, G = gnome(c, 22, 46, { s = 1.15, d = 1, sit = true, eyes = "shut", arms = { arm({ 3, 8 }, { 8, 8 }, true) } })
  hand(c, 28, 33)
  finish(c, "r_esa_coffee_smoke")
end

-- 23. flamingo tales: dusk on the shallows, big low sun, flamingos wading, gnome on the ferry deck
function S.r_esa_flamingo_tales()
  seed = 23; local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#5a4a88", "#8a5a94", "#c8688a", "#e88a6a", "#f5b070" }, { dir = "v" })
  c:fill(c:ellipse(40, 31, 9, 9), "#ffd890"); c:fill(c:ellipse(40, 31, 6, 6), "#fff1c8")
  c:fill(R(c, 0, 31, W - 1, H - 1), "#c8688a")
  c:bands(R(c, 0, 31, W - 1, H - 1), { "#e88a8a", "#d8708a", "#b0608a", "#8a5a8a" }, { dir = "v" })
  for _, p in ipairs({ { 30, 34, 20 }, { 34, 38, 14 }, { 36, 42, 9 } }) do fl(c, R(c, p[1], p[2], p[1] + p[3], p[2]), "#ffd890") end
  c:fill(c:ellipse(60, 31, 14, 2), "#6a4a7a")
  local function fla(x, y, d)
    fl(c, R(c, x, y - 8, x, y), "#e08aa0"); fl(c, R(c, x - 1, y - 9, x, y - 9), "#e08aa0")
    part(c, c:ellipse(x, y - 11, 4, 3), "#f0a0b4", { noline = true })
    fl(c, R(c, x + d * 3, y - 14, x + d * 3, y - 11), "#f0a0b4"); fl(c, R(c, x + d * 3, y - 15, x + d * 4 , y - 15), "#f0a0b4"); c:px(x + d * 5, y - 14, INK)
    fl(c, R(c, x + d * 3, y - 14, x + d * 4, y - 14), "#f0a0b4"); c:px(x + d * 5, y - 13, "#2a1a10")
    fl(c, R(c, x - 3, y, x + 3, y), "#ffd8e0")
  end
  fla(14, 38, 1); fla(23, 40, 1); fla(56, 37, -1); fla(63, 40, -1)
  -- ferry deck
  part(c, R(c, 0, 42, 72, 49), "#8a5a35"); fl(c, R(c, 0, 42, 72, 42), "#b07a45")
  for x = 8, 66, 12 do fl(c, R(c, x, 43, x, 48), "#5e2f1e") end
  part(c, R(c, 66, 30, 67, 42), "#6b4a2e", { noline = true })
  gnome(c, 40, 42, { s = 1.15, d = 1, sit = true, eyes = "open", arms = { arm({ -3, 6 }, { -4, 3 }, false), arm({ 4, 8 }, { 8, 14 }, true) } })
  finish(c, "r_esa_flamingo_tales")
end

-- 24. acacia shade: dozing against the trunk in the round shadow, a giraffe nibbling overhead
function S.r_esa_acacia_shade()
  seed = 24; local c = new()
  day(c, 38, { cloud = 14, sky = { "#f0e0a8", "#f4e8b8", "#f6eec8" }, hill = "#b89a5a", hill2 = "#a8884a", grass = "#d4b878", edge = "#e6d094" })
  c:fill(c:ellipse(60, 10, 5, 5), "#fff4c8")
  -- round shade on the ground
  c:fill(c:ellipse(34, 45, 28, 5), "#b49a5a")
  -- giraffe behind: legs, body, neck up into the canopy
  fl(c, R(c, 50, 40, 51, 48), "#d9a640"); fl(c, R(c, 58, 40, 59, 48), "#d9a640")
  part(c, R(c, 49, 30, 62, 40), "#d9a640", { noline = false })
  fl(c, c:line({ { 51, 31 }, { 47, 13 } }, 3), "#d9a640")
  for _, p in ipairs({ { 52, 33 }, { 57, 36 }, { 55, 31 }, { 48, 20 }, { 49, 25 } }) do c:px(p[1], p[2], "#8a5a2a"); c:px(p[1] + 1, p[2], "#8a5a2a") end
  part(c, R(c, 44, 10, 50, 13), "#d9a640", { noline = false }); c:px(45, 11, INK); fl(c, R(c, 46, 8, 46, 9), "#8a5a2a")
  -- tree: trunk left of centre, flat canopy
  part(c, R(c, 20, 20, 23, 46), "#6b4a2e", { noline = true })
  fl(c, c:line({ { 22, 22 }, { 10, 15 } }, 2), "#6b4a2e"); fl(c, c:line({ { 22, 22 }, { 50, 14 } }, 2), "#6b4a2e")
  part(c, c:ellipse(34, 12, 28, 4), "#5a8a3a", { shade = true })
  c:fill(c:ellipse(30, 11, 22, 2), "#86b050")
  for _, p in ipairs({ { 28, 18 }, { 40, 17 } }) do c:px(p[1], p[2], "#5a8a3a"); c:px(p[1] + 1, p[2] + 1, "#5a8a3a") end
  -- dozing gnome sitting against the trunk
  gnome(c, 31, 46, { s = 1.1, d = 1, sit = true, eyes = "shut", arms = { arm({ -3, 6 }, { 2, 4 }, true, true) } })
  fl(c, R(c, 38, 29, 39, 29), "#f4eee0"); fl(c, R(c, 40, 29, 40, 29), "#f4eee0"); fl(c, R(c, 40, 30, 41, 30), "#f4eee0"); fl(c, R(c, 38, 31, 41, 31), "#f4eee0")
  fl(c, R(c, 43, 24, 44, 24), "#f4eee0"); fl(c, R(c, 44, 25, 44, 25), "#f4eee0"); fl(c, R(c, 43, 26, 44, 26), "#f4eee0")
  finish(c, "r_esa_acacia_shade")
end

-- @@END
for _, s2 in ipairs(order) do
  if not only or only == s2 then seed = 7; S[s2]() end
end
