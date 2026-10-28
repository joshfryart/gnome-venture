-- variety-act-g22.lua : Do-tab scenes for 15 hot-spring rest-stop activities (w5_*) -> act-<slug>.png (144x108, drawn on 72x54, out=2)
-- Run: AppRun -b --script-param out=<dir>/ [--script-param only=<slug>] --script variety-act-g22.lua   (params BEFORE --script)
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
  if o.mouth then
    local my0, my1 = ry(7, 8)
    c:fill(c:rect(ox - 1, my0, ox, my1), "#6b2a22")
    if o.mouth == "wide" then c:fill(c:rect(ox - 2, my0, ox + 1, my1), "#6b2a22") end
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

local S = {}

---------------------------------------------------------------- shared hot-spring props
local function wisp(c, x, y0, n, col, dir)
  col = col or "#f4f8fa"
  for i = 0, n do
    local sx = x + ((i % 2 == 0) and 0 or (dir or 1))
    fl(c, R(c, sx, y0 - i * 2, sx + 1, y0 - i * 2 + 1), col)
  end
end
-- stone-rimmed pool seen from slightly above
local function pool(c, cx, cy, rx, ry, water, rim)
  part(c, c:ellipse(cx, cy, rx, ry), rim or "#8b8f96", { shade = true })
  c:fill(c:ellipse(cx, cy, rx - 3, math.max(1, ry - 2)), water or "#58b4c4")
  c:fill(R(c, cx - rx + 5, cy, cx - rx + 8, cy), "#a8e6e6")
  if rx > 10 then c:fill(R(c, cx + 2, cy + 1, cx + 6, cy + 1), "#7ccfd4") end
end
local function hut(c, x, y, w, h, snow)
  part(c, R(c, x, y, x + w, y + h), "#b07a45")
  for i = 3, w - 1, 3 do fl(c, R(c, x + i, y + 1, x + i, y + h - 1), "#8a5a35") end
  part(c, R(c, x + math.floor(w / 2) - 2, y + 3, x + math.floor(w / 2) + 2, y + h), "#4a2c1a")
  part(c, c:poly({ { x + math.floor(w / 2), y - 6 }, { x + w + 3, y }, { x - 3, y } }), snow and "#e8eef4" or "#a8442e")
  if not snow then fl(c, R(c, x - 2, y - 1, x + w + 2, y - 1), "#c0442e") end
end

---------------------------------------------------------------- scenes
-- 1. snowy_path: shovelling the path between hut and pools while snow falls
function S.w5_snowy_path()
  seed = 5
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 33), { "#8ea4bd", "#9db1c6", "#adbfd1", "#bccbda", "#cdd9e4" }, { dir = "v" })
  c:fill(c:ellipse(14, 36, 30, 10), "#d3deea"); c:fill(c:ellipse(60, 36, 26, 8), "#dae4ee")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#eef3f7")
  pine(c, 66, 35, 14, true)
  hut(c, 9, 24, 11, 10, true)
  pool(c, 56, 38, 12, 4, "#58b4c4", "#c8d2dc")
  wisp(c, 52, 35, 5); wisp(c, 60, 35, 6, nil, -1)
  -- cleared path: dark wet stones between snow banks
  c:fill(R(c, 0, 41, W - 1, 46), "#8a8f94")
  c:fill(R(c, 0, 41, W - 1, 41), "#a8aeb4")
  for x = 3, 66, 5 do c:px(x, 43, "#6e7378"); c:px(x + 2, 45, "#6e7378") end
  -- snow bank and the pile in front of the cleared bit
  c:fill(R(c, 0, 40, W - 1, 40), "#fbfdfe")
  c:fill(c:ellipse(62, 44, 9, 4), "#f4f8fa"); c:fill(c:ellipse(62, 43, 5, 2), "#fbfdfe")
  c:fill(R(c, 56, 46, 70, 49), "#f4f8fa")
  local _, G = gnome(c, 30, 47, { s = 1.25, d = 1, eyes = "open", arms = { arm({ -4, 6 }, { 0, 7 }, false), arm({ 3, 6 }, { 6, 4 }, true) } })
  local hx, hy = G.P(-3, 11); local bx, by = G.P(10, 0)
  fl(c, c:line({ { hx, hy }, { bx, by } }, 1), "#8a5a35")
  part(c, R(c, bx, by - 1, bx + 4, by + 1), "#a8b0b8")
  fl(c, R(c, bx, by - 3, bx + 3, by - 2), "#fbfdfe")
  -- flung snow
  for _, p in ipairs({ { 46, 42 }, { 49, 39 }, { 52, 37 }, { 48, 41 }, { 54, 39 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2] + 1), "#fbfdfe") end
  seed = 11
  for i = 1, 26 do
    local x, y = 6 + floor(rand() * 62), 6 + floor(rand() * 40)
    c:px(x, y, "#fbfdfe")
    if i % 4 == 0 then c:px(x + 1, y, "#fbfdfe"); c:px(x, y + 1, "#fbfdfe") end
  end
  finish(c, "w5_snowy_path")
end

-- 2. steam_fortune: dawn, tall silver steam shapes, one a basket
function S.w5_steam_fortune()
  seed = 9
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 36), { "#4a4a78", "#6a5a8e", "#9a6a98", "#d07a90", "#ee9a82", "#f8c07a" }, { dir = "v" })
  for _, p in ipairs({ { 9, 8 }, { 30, 6 }, { 58, 9 }, { 40, 12 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:fill(c:ellipse(46, 37, 9, 7), "#ffd86a"); c:fill(c:ellipse(46, 37, 6, 5), "#fff0b0")
  c:fill(c:ellipse(14, 40, 30, 9), "#3d5a5a"); c:fill(c:ellipse(60, 40, 30, 8), "#34524e")
  c:fill(R(c, 0, 38, W - 1, H - 1), "#4a6a52")
  pool(c, 38, 44, 20, 6, "#7ac0cc", "#6e7078")
  c:fill(R(c, 28, 44, 36, 44), "#e8c8b0")
  -- steam columns
  local function puffy(x, y, r, col) c:fill(c:ellipse(x, y, r, math.max(1, r - 1)), col) end
  local pale, mid = "#e4ecf2", "#c0ccdc"
  -- a basket heaped with eggs: bowl, rim, handle arc
  puffy(40, 24, 7, pale); fl(c, R(c, 34, 22, 46, 23), pale); fl(c, R(c, 35, 24, 45, 25), pale); fl(c, R(c, 37, 26, 43, 26), pale)
  fl(c, R(c, 35, 24, 45, 24), mid); fl(c, R(c, 37, 26, 43, 26), mid); fl(c, R(c, 36, 22, 44, 22), mid)
  for _, x in ipairs({ 36, 40, 44 }) do fl(c, R(c, x - 1, 19, x + 1, 21), pale); c:px(x - 1, 21, mid) end
  c:px(38, 18, pale); c:px(42, 18, pale)
  fl(c, R(c, 35, 14, 35, 18), pale); fl(c, R(c, 45, 14, 45, 18), pale); fl(c, R(c, 36, 12, 44, 12), pale); fl(c, R(c, 36, 13, 36, 13), pale); fl(c, R(c, 44, 13, 44, 13), pale)
  -- columns feeding it
  for _, col in ipairs({ { 37, 40 }, { 40, 39 }, { 43, 40 } }) do
    for y = col[2], 27, -1 do fl(c, R(c, col[1] + ((y % 4 < 2) and 0 or 1), y, col[1] + 1, y), (y % 3 == 0) and mid or pale) end
  end
  -- drifting side puffs
  puffy(56, 26, 4, mid); puffy(59, 22, 3, pale); puffy(54, 20, 2, pale)
  puffy(20, 26, 4, mid); puffy(17, 21, 3, pale); puffy(21, 17, 2, pale)
  -- gnome, chin in hand, gazing up
  gnome(c, 15, 47, { s = 1, d = 1, eyes = "open", arms = { arm({ 4, 6 }, { 3, 9 }, true), arm({ -4, 6 }, { -3, 3 }, false) } })
  finish(c, "w5_steam_fortune")
end

-- 3. warm_curds: stirring a pot of goat milk on warm rocks, cheese round waiting
function S.w5_warm_curds()
  seed = 13
  local c = new()
  day(c, 28, { cloud = 50, sky = { "#b4d8e2", "#c4e0e6", "#d4ecea" } })
  pool(c, 52, 33, 15, 4, "#58b4c4", "#8b8f96")
  wisp(c, 46, 30, 6); wisp(c, 58, 30, 5, nil, -1)
  -- hot rocks and the pot
  for _, r in ipairs({ { 33, 44, 6, 4, "#7a7e86" }, { 46, 45, 5, 4, "#8b8f96" }, { 40, 47, 6, 3, "#6e727a" }, { 28, 47, 4, 3, "#8b8f96" }, { 50, 48, 3, 2, "#7a7e86" } }) do
    part(c, c:ellipse(r[1], r[2], r[3], r[4]), r[5], { shade = true })
  end
  part(c, c:ellipse(40, 36, 8, 9), "#3a3a42")
  c:fill(c:ellipse(40, 33, 7, 3), "#f0e6cf"); c:fill(c:ellipse(40, 33, 4, 1), "#fffaf0")
  c:px(37, 33, "#f0e6cf"); fl(c, R(c, 44, 34, 45, 34), "#e0d4b8")
  fl(c, R(c, 33, 38, 33, 41), "#5a5a66")
  part(c, R(c, 31, 33, 32, 35), "#3a3a42"); part(c, R(c, 48, 33, 49, 35), "#3a3a42")
  -- steam from pot
  wisp(c, 38, 30, 4); wisp(c, 43, 29, 3, nil, -1)
  -- gnome stirring with a long spoon
  local _, G = gnome(c, 20, 48, { s = 1.25, d = 1, eyes = "happy", arms = { arm({ -4, 7 }, { 0, 9 }, false), arm({ 4, 7 }, { 8, 10 }, true) } })
  local sx, sy = G.P(10, 12)
  fl(c, c:line({ { sx, sy }, { 38, 31 } }, 1), "#c08a52")
  fl(c, R(c, 38, 30, 40, 32), "#a8703e")
  -- hearts: nice things said to the milk
  c:paint({ ".p.p.", "ppppp", ".ppp.", "..p.." }, 26, 20, { p = "#e8708a" })
  -- finished cheese on a plank, cloth knotted
  part(c, R(c, 55, 44, 66, 46), "#a8703e")
  part(c, c:ellipse(60, 42, 5, 3), "#f4e6b8"); c:fill(c:ellipse(60, 41, 3, 1), "#fff6d8")
  c:fill(R(c, 55, 42, 56, 43), "#f4eee0"); c:fill(R(c, 64, 42, 65, 43), "#f4eee0")
  fl(c, R(c, 59, 38, 61, 38), "#f4eee0"); c:px(60, 39, "#f4eee0")
  finish(c, "w5_warm_curds")
end

-- 4. mineral_silt: sieving silt beside the hot runoff
function S.w5_mineral_silt()
  seed = 17
  local c = new()
  day(c, 27, { cloud = 12, hill = "#6e7e4e", hill2 = "#5e7442", grass = "#c8b48a", edge = "#d8c8a0" })
  -- the grass here is silty sand; a hot runoff stream
  c:fill(c:poly({ { 52, 28 }, { 60, 28 }, { 70, 49 }, { 54, 49 } }), "#58b4c4")
  c:fill(c:poly({ { 55, 28 }, { 57, 28 }, { 62, 49 }, { 58, 49 } }), "#7ccfd4")
  for _, p in ipairs({ { 55, 33 }, { 58, 38 }, { 62, 43 }, { 59, 46 } }) do fl(c, R(c, p[1], p[2], p[1] + 2, p[2]), "#b8ecec") end
  wisp(c, 54, 27, 5); wisp(c, 58, 27, 4, nil, -1)
  -- drying trays of silt on a rack, back left
  part(c, R(c, 8, 30, 10, 36), "#8a5a35", { noline = true }); part(c, R(c, 22, 30, 24, 36), "#8a5a35", { noline = true })
  part(c, R(c, 7, 28, 25, 31), "#b07a45")
  part(c, R(c, 9, 25, 15, 27), "#e8d8b0"); part(c, R(c, 17, 25, 23, 27), "#e8d8b0")
  -- gnome with a round sieve, tilting it
  local _, G = gnome(c, 30, 48, { s = 1.25, d = 1, eyes = "open", arms = { arm({ -4, 7 }, { 2, 10 }, false), arm({ 4, 7 }, { 8, 11 }, true) } })
  local tx, ty = G.P(11, 11)
  part(c, c:ellipse(tx, ty, 7, 2), "#a8703e")
  c:fill(c:ellipse(tx, ty, 5, 1), "#e8d8b0")
  for i = 0, 4 do c:px(tx - 4 + i * 2, ty, "#8a7a5a") end
  -- falling rock dust, sparkling
  for _, p in ipairs({ { tx - 2, ty + 3 }, { tx + 1, ty + 5 }, { tx - 1, ty + 7 }, { tx + 1, ty + 9 }, { tx, ty + 11 }, { tx - 1, ty + 13 } }) do c:px(p[1], p[2], "#f4eee0") end
  c:px(tx + 3, ty + 4, "#fbfdfe"); c:px(tx - 3, ty + 8, "#ffe9a8")
  -- pouch and mound
  part(c, c:poly({ { tx - 6, 49 }, { tx + 6, 49 }, { tx + 4, 45 }, { tx - 4, 45 } }), "#c8a064")
  fl(c, R(c, tx - 3, 44, tx + 3, 44), "#f4eee0"); fl(c, R(c, tx - 4, 45, tx + 4, 45), "#8a5a35")
  c:px(tx + 4, 40, "#fbfdfe"); c:px(tx - 4, 42, "#ffe9a8")
  finish(c, "w5_mineral_silt")
end

-- 5. buried_cornbread: digging up a pot from the hot sand
function S.w5_buried_cornbread()
  seed = 21
  local c = new()
  day(c, 25, { cloud = 44, hill = "#5e8a44", hill2 = "#4e8a3c", grass = "#dcc088", edge = "#ecd49c" })
  pool(c, 17, 31, 13, 4, "#58b4c4", "#8b8f96")
  wisp(c, 11, 28, 5); wisp(c, 21, 28, 6, nil, -1)
  -- sand ripples
  for _, p in ipairs({ { 8, 42 }, { 50, 40 }, { 60, 45 }, { 14, 47 }, { 30, 44 } }) do fl(c, R(c, p[1], p[2], p[1] + 4, p[2]), "#c8a870") end
  -- hole and pot with golden loaf showing
  c:fill(c:ellipse(34, 43, 11, 4), "#8a6a40"); c:fill(c:ellipse(34, 43, 9, 3), "#5e4a2e")
  part(c, R(c, 27, 36, 41, 44), "#3a3a42")
  part(c, R(c, 25, 35, 43, 37), "#4a4a54")
  c:fill(c:ellipse(34, 35, 7, 2), "#d9a050"); c:fill(c:ellipse(34, 34, 5, 1), "#f0c070")
  for _, x in ipairs({ 31, 34, 37 }) do c:px(x, 34, "#a8702e") end
  -- sand heap beside
    -- steam out of the pot and sand
  wisp(c, 30, 32, 5); wisp(c, 36, 31, 6, nil, -1); wisp(c, 40, 32, 4)
  fl(c, R(c, 28, 43, 29, 43), "#f4f8fa"); fl(c, R(c, 52, 47, 53, 47), "#f4f8fa")
  -- gnome with a spade, facing the pot
  local _, G = gnome(c, 59, 48, { s = 1.25, d = -1, eyes = "open", arms = { arm({ 4, 7 }, { 0, 6 }, false), arm({ -4, 7 }, { -8, 5 }, true) } })
  local hx, hy = G.P(1, 12); local bx, by = G.P(-10, 0)
  fl(c, c:line({ { hx, hy }, { bx, by } }, 1), "#8a5a35")
  part(c, R(c, bx - 3, by - 1, bx, by + 1), "#a8b0b8")
  for _, p in ipairs({ { 47, 39 }, { 50, 37 }, { 45, 38 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#e8cc90") end
  finish(c, "w5_buried_cornbread")
end

-- 6. pool_wall: setting a stone into the gap of a slumped wall, water trickling out
function S.w5_pool_wall()
  seed = 23
  local c = new()
  day(c, 22, { cloud = 52 })
  -- pool behind the wall
  c:fill(R(c, 5, 22, 68, 31), "#58b4c4")
  c:fill(R(c, 5, 22, 68, 22), "#a8e6e6")
  for _, p in ipairs({ { 10, 26 }, { 22, 28 }, { 50, 25 }, { 60, 29 } }) do fl(c, R(c, p[1], p[2], p[1] + 4, p[2]), "#7ccfd4") end
  wisp(c, 14, 21, 4); wisp(c, 58, 21, 5, nil, -1)
  -- the stone wall: two courses, top course missing a block at x 40..46
  local greys = { "#8b8f96", "#9a9ea6", "#7a7e86", "#a4a8ae" }
  local x = 5; local i = 0
  while x < 69 do
    local w = 6 + (i * 3) % 4
    part(c, R(c, x, 36, math.min(68, x + w - 1), 41), greys[i % 4 + 1]); x = x + w; i = i + 1
  end
  x = 3; i = 2
  while x < 69 do
    local w = 6 + (i * 5) % 4
    if not (x + w > 38 and x < 48) then
      part(c, R(c, math.max(5, x), 30, math.min(68, x + w - 1), 35), greys[i % 4 + 1])
    end
    x = x + w; i = i + 1
  end
  -- gap: water pours through
  c:fill(R(c, 40, 30, 46, 35), "#58b4c4"); c:fill(R(c, 41, 30, 41, 35), "#a8e6e6")
  c:fill(R(c, 41, 36, 45, 41), "#7ccfd4"); c:fill(R(c, 42, 36, 42, 41), "#b8ecec")
  c:fill(c:ellipse(43, 46, 9, 3), "#58b4c4"); c:fill(c:ellipse(43, 45, 5, 1), "#7ccfd4")
  c:fill(R(c, 41, 42, 45, 44), "#58b4c4")
  -- spare stones heaped at right
  for _, st in ipairs({ { 58, 47, 5, 3 }, { 64, 46, 4, 3 }, { 61, 43, 4, 2 } }) do part(c, c:ellipse(st[1], st[2], st[3], st[4]), "#9a9ea6", { shade = true }) end
  -- gnome with a stone held up to the gap
  local _, G = gnome(c, 26, 48, { s = 1.25, d = 1, eyes = "open", arms = { arm({ -4, 7 }, { 4, 10 }, false, true), arm({ 4, 7 }, { 8, 10 }, true, true) } })
  local sx, sy = G.P(8, 14)
  part(c, R(c, sx - 1, sy - 2, sx + 8, sy + 4), "#a4a8ae")
  fl(c, R(c, sx, sy - 2, sx + 6, sy - 2), "#c8ccd2")
  fl(c, R(c, sx - 2, sy + 1, sx - 1, sy + 3), "#f0c8a0"); fl(c, R(c, sx + 8, sy + 1, sx + 9, sy + 3), "#f0c8a0")
  finish(c, "w5_pool_wall")
end

-- 7. darn_robes: winter, hut interior, seated gnome sewing a purple patch
function S.w5_darn_robes()
  seed = 27
  local c = new()
  c:fill(R(c, 0, 0, W - 1, 38), "#8a5e3c")
  for x = 5, 68, 7 do fl(c, R(c, x, 5, x, 38), "#6a4428") end
  c:fill(R(c, 0, 38, W - 1, H - 1), "#b8864e")
  for y = 41, 49, 4 do fl(c, R(c, 0, y, W - 1, y), "#9a6c3a") end
  fl(c, R(c, 0, 38, W - 1, 38), "#5e3f28")
  -- window onto the snow
  part(c, R(c, 56, 11, 67, 27), "#5e3f28")
  c:fill(R(c, 58, 13, 65, 25), "#bcd0e4"); c:fill(R(c, 58, 20, 65, 25), "#eef3f7")
  fl(c, R(c, 61, 13, 61, 25), "#5e3f28"); fl(c, R(c, 58, 19, 65, 19), "#5e3f28")
  c:px(59, 15, "#fbfdfe"); c:px(63, 16, "#fbfdfe"); c:px(60, 17, "#fbfdfe"); c:px(64, 14, "#fbfdfe")
  fl(c, R(c, 59, 22, 60, 22), "#fbfdfe"); fl(c, R(c, 63, 23, 64, 23), "#fbfdfe")
  -- robes on pegs along the wall, patches in purple
  fl(c, R(c, 24, 12, 52, 12), "#5e3f28")
  local function robe(x, col, patch)
    part(c, R(c, x, 14, x + 6, 29), col)
    fl(c, R(c, x + 3, 14, x + 3, 22), "#d8dce2")
    fl(c, R(c, x, 21, x + 6, 21), "#b8bcc4")
    if patch then fl(c, R(c, x + 1, patch, x + 2, patch + 2), "#8a5ab4") end
    c:px(x + 3, 12, "#2a1a10")
  end
  robe(26, "#f4eee0", 24); robe(35, "#e8d8c0", nil); robe(44, "#f4eee0", 17)
  -- stool and the gnome seated, robe over the lap
  part(c, R(c, 7, 37, 19, 41), "#a8703e")
  part(c, R(c, 8, 41, 10, 47), "#8a5a35", { noline = true }); part(c, R(c, 16, 41, 18, 47), "#8a5a35", { noline = true })
  local _, G = gnome(c, 14, 38, { s = 1, d = 1, sit = true, eyes = "open", arms = { arm({ 4, 6 }, { 7, 3 }, true) } })
  part(c, R(c, 11, 33, 26, 40), "#f4eee0")
  fl(c, R(c, 11, 33, 26, 33), "#d8dce2")
  fl(c, R(c, 19, 35, 22, 37), "#8a5ab4"); c:px(20, 36, "#c8a8e8"); c:px(22, 35, "#c8a8e8")
  -- needle and thread
  fl(c, c:line({ { 17, 33 }, { 23, 31 } }, 1), "#c8ccd2")
  fl(c, c:line({ { 23, 31 }, { 26, 36 }, { 22, 37 } }, 1), "#c8a8e8")
  -- hatch of cold: stove and basket of spare cloth
  part(c, R(c, 56, 38, 67, 48), "#6a6e76")
  c:fill(R(c, 59, 41, 64, 46), "#ffb03a"); c:fill(R(c, 60, 43, 63, 46), "#ffe08a")
  fl(c, R(c, 55, 37, 68, 37), "#4a4e56")
  fl(c, R(c, 61, 28, 61, 36), "#4a4e56")
  finish(c, "w5_darn_robes")
end

-- 8. towel_flick: two soakers duel with rolled towels at poolside
function S.w5_towel_flick()
  seed = 29
  local c = new()
  day(c, 30, { cloud = 30 })
  -- pool behind with stone rim
  part(c, R(c, 5, 26, 68, 34), "#8b8f96")
  c:fill(R(c, 7, 28, 66, 33), "#58b4c4"); c:fill(R(c, 8, 28, 20, 28), "#a8e6e6"); c:fill(R(c, 42, 30, 52, 30), "#7ccfd4")
  wisp(c, 12, 25, 3); wisp(c, 60, 25, 3, nil, -1)
  -- bench with spare towels
  part(c, R(c, 28, 35, 44, 36), "#8a5a35", { noline = true })
  -- left gnome, red hat, towel flick across
  local _, GL = gnome(c, 17, 48, { s = 1.25, d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -2, 9 }, false), arm({ 4, 7 }, { 8, 12 }, true) } })
  local _, GR = gnome(c, 56, 48, { s = 1.25, d = -1, hat = "#4f9a45", eyes = "open", arms = { arm({ 4, 7 }, { 2, 3 }, false), arm({ -4, 7 }, { -6, 5 }, true) } })
  local hx, hy = GL.P(8, 12)
  -- rolled towel whip: from the hand out to the middle
  local function towel(x0, y0, x1, y1)
    fl(c, c:line({ { x0, y0 }, { x1, y1 } }, 2), "#f4eee0")
    local n = 6
    for i = 1, n - 1 do
      local t = i / n
      local px, py = rnd(x0 + (x1 - x0) * t), rnd(y0 + (y1 - y0) * t)
      c:px(px, py, "#dd3a2a")
    end
  end
  towel(hx, hy, 36, 31)
  -- the pop
  local px, py = 38, 30
  for _, d in ipairs({ { 0, -3 }, { 0, 3 }, { -3, 0 }, { 3, 0 }, { 2, 2 }, { -2, -2 }, { 2, -2 }, { -2, 2 } }) do fl(c, R(c, px + d[1], py + d[2], px + d[1], py + d[2]), "#ffd86a") end
  fl(c, R(c, px - 1, py - 1, px + 1, py + 1), "#fff4c0")
  -- opponent's towel trailing, ready to twirl
  local ox, oy = GR.P(-6, 5)
  local ring = c:ellipse(ox - 2, oy - 2, 4, 3); ring:cut(c:ellipse(ox - 2, oy - 2, 2, 1))
  fl(c, ring, "#d8e8f4")
  c:px(ox - 6, oy - 2, "#3f8fb0"); c:px(ox + 2, oy - 2, "#3f8fb0"); c:px(ox - 2, oy - 5, "#3f8fb0")
  for _, d in ipairs({ { -8, -6 }, { 4, -6 }, { -9, 1 } }) do c:px(ox + d[1], oy + d[2], "#fbfdfe") end
  finish(c, "w5_towel_flick")
end

-- 9. steam_singing: three heads in the pool, the middle one belting a yodel
function S.w5_steam_singing()
  seed = 31
  local c = new()
  day(c, 27, { cloud = 14, sky = { "#b4d8e2", "#c4e0e6", "#d4ecea" } })
  c:fill(R(c, 0, 25, W - 1, 28), "#8b8f96")
  -- three singers
  gnome(c, 13, 44, { s = 1, d = 1, upper = true, hat = "#e8a317", eyes = "shut", mouth = "small" })
  gnome(c, 59, 44, { s = 1, d = -1, upper = true, hat = "#4f9a45", eyes = "happy" })
  gnome(c, 36, 46, { s = 1.25, d = 1, upper = true, eyes = "open", mouth = "wide" })
  -- the pool in front
  c:fill(R(c, 5, 40, 68, 49), "#58b4c4")
  c:fill(R(c, 5, 40, 68, 40), "#a8e6e6")
  for _, w in ipairs({ { 8, 43, 7 }, { 22, 45, 6 }, { 46, 44, 8 }, { 58, 46, 6 }, { 28, 47, 5 } }) do fl(c, R(c, w[1], w[2], w[1] + w[3], w[2]), "#7ccfd4") end
  part(c, R(c, 4, 47, 69, 51), "#8b8f96")
  -- hum (left): small note;  yodel (middle): big notes;  gargle (right): bubbles
  local function note(x, y, col)
    fl(c, R(c, x, y, x + 1, y + 1), col); fl(c, R(c, x + 2, y - 5, x + 2, y + 1), col); fl(c, R(c, x + 2, y - 5, x + 4, y - 4), col)
  end
  note(9, 24, "#e8a317"); note(44, 14, "#e0501f"); note(28, 10, "#d8a020"); note(37, 8, "#e0501f"); note(50, 18, "#d8a020")
  for _, b in ipairs({ { 53, 33 }, { 56, 30 }, { 52, 27 }, { 58, 26 } }) do fl(c, R(c, b[1], b[2], b[1] + 1, b[2] + 1), "#e8f8f4") end
  finish(c, "w5_steam_singing")
end

-- 10. pool_crusts: terraced pools in many colours, gnome with a magnifier
function S.w5_pool_crusts()
  seed = 33
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 24), { "#a8d4e0", "#bcdde4", "#cfe8e6" }, { dir = "v" })
  c:fill(c:ellipse(60, 24, 30, 9), "#6e8a58"); c:fill(R(c, 0, 24, W - 1, H - 1), "#8a9a6a")
  -- terraces stepping down to the left: crust rim colour, then water
  local tiers = {
    { 57, 26, 11, 4, "#e8d040", "#5ec0c0" },
    { 51, 32, 13, 5, "#c8582a", "#6ac0b8" },
    { 45, 38, 14, 5, "#3aa890", "#5aa8c8" },
    { 39, 44, 15, 5, "#f0eadc", "#88c8e0" },
  }
  for _, t in ipairs(tiers) do
    part(c, c:ellipse(t[1], t[2], t[3], t[4]), t[5])
    c:fill(c:ellipse(t[1], t[2], t[3] - 3, t[4] - 2), t[6])
    c:fill(R(c, t[1] - 4, t[2], t[1] - 1, t[2]), "#d8f4f4")
  end
  -- coloured stain flecks
  for _, p in ipairs({ { 48, 21 }, { 62, 21 }, { 66, 33 }, { 24, 40 }, { 10, 33 } }) do c:px(p[1], p[2], "#e8d040"); c:px(p[1] + 1, p[2], "#c8582a") end
  wisp(c, 54, 23, 3); wisp(c, 60, 23, 3, nil, -1)
  -- gnome pointing, magnifier up
  local _, G = gnome(c, 15, 48, { s = 1.25, d = 1, eyes = "open", arms = { arm({ -4, 7 }, { -2, 4 }, false), arm({ 4, 7 }, { 8, 12 }, true, true) } })
  local gx, gy = G.P(9, 14)
  fl(c, c:line({ { gx - 2, gy + 4 }, { gx + 1, gy + 1 } }, 1), "#8a5a35")
  part(c, c:ellipse(gx + 4, gy - 2, 4, 4), "#c0a040", { shade = false })
  c:fill(c:ellipse(gx + 4, gy - 2, 3, 3), "#d8f0f4"); c:px(gx + 3, gy - 3, "#fbfdfe"); c:px(gx + 2, gy - 2, "#fbfdfe")
  fl(c, R(c, gx - 3, gy + 2, gx - 2, gy + 4), "#f0c8a0")
  finish(c, "w5_pool_crusts")
end

-- 11. bathers_hats: a crowd of heads in the pool, each with a daft hat
function S.w5_bathers_hats()
  seed = 37
  local c = new()
  day(c, 18, { cloud = 46, sky = { "#b4d8e2", "#c4e0e6", "#d4ecea" } })
  c:fill(R(c, 0, 18, W - 1, H - 1), "#7ea85a")
  part(c, c:ellipse(36, 34, 31, 15), "#8b8f96", { shade = true })
  c:fill(c:ellipse(36, 34, 28, 12), "#58b4c4")
  c:fill(R(c, 14, 28, 20, 28), "#a8e6e6"); c:fill(R(c, 50, 40, 58, 40), "#7ccfd4"); c:fill(R(c, 20, 42, 26, 42), "#7ccfd4")
  local function head(cx, cy)
    c:fill(c:ellipse(cx, cy + 5, 5, 1), "#b8ecec")
    part(c, R(c, cx - 3, cy + 2, cx + 3, cy + 4), "#f4eee0")
    part(c, R(c, cx - 3, cy - 2, cx + 3, cy + 1), "#f0c8a0")
    c:px(cx - 2, cy - 1, INK); c:px(cx + 2, cy - 1, INK); c:px(cx, cy, "#e08a7a")
  end
  -- 1: lily pad
  head(14, 36)
  part(c, c:ellipse(14, 33, 5, 2), "#3f9a45"); fl(c, R(c, 16, 32, 17, 33), "#7ccfd4")
  c:fill(R(c, 13, 31, 15, 32), "#e8708a"); c:px(14, 30, "#e8708a"); c:px(14, 31, "#ffd86a")
  -- 2: our red-hatted gnome with a bobble hat
  head(38, 40)
  part(c, c:poly({ { 34, 37 }, { 42, 37 }, { 40, 31 }, { 37, 31 } }), "#c0442e")
  part(c, R(c, 33, 36, 43, 37), "#8e2e1e")
  part(c, R(c, 36, 29, 39, 31), "#f4eee0"); fl(c, R(c, 37, 30, 38, 30), "#fbfdfe")
  -- 3: upturned teacup
  head(50, 31)
  part(c, R(c, 47, 26, 53, 29), "#f4eee0"); fl(c, R(c, 47, 27, 53, 27), "#3f8fb0")
  part(c, R(c, 53, 26, 55, 28), "#f4eee0"); c:px(54, 27, "#58b4c4")
  part(c, R(c, 45, 29, 55, 29), "#d8dce2")
  -- 4: flowerpot
  head(60, 40)
  part(c, c:poly({ { 56, 37 }, { 64, 37 }, { 63, 32 }, { 57, 32 } }), "#c4623a")
  fl(c, R(c, 56, 32, 64, 32), "#8a3f22")
  fl(c, R(c, 60, 28, 60, 31), "#3f9a45")
  fl(c, R(c, 59, 26, 61, 28), "#ffd86a"); c:px(60, 27, "#c0442e"); c:px(58, 27, "#e8708a"); c:px(62, 27, "#e8708a")
  -- 5: paper boat
  head(26, 29)
  part(c, c:poly({ { 23, 25 }, { 29, 25 }, { 28, 27 }, { 24, 27 } }), "#f4eee0")
  part(c, c:poly({ { 26, 20 }, { 29, 25 }, { 23, 25 } }), "#fbfdfe")
  fl(c, R(c, 26, 22, 26, 24), "#c8ccd2")
  wisp(c, 10, 22, 3); wisp(c, 62, 22, 3, nil, -1)
  -- spare hats on the bank
  part(c, c:ellipse(7, 46, 4, 2), "#e8c04a"); fl(c, R(c, 5, 44, 9, 44), "#c0442e")
  part(c, c:ellipse(66, 46, 3, 2), "#4f9a45")
  finish(c, "w5_bathers_hats")
end

-- 12. just_right_pool: too hot, too cold, just right; the gnome sinks into the middle one
function S.w5_just_right_pool()
  seed = 41
  local c = new()
  day(c, 24, { cloud = 10 })
  c:fill(R(c, 0, 24, W - 1, H - 1), "#8aa860")
  part(c, R(c, 5, 22, 68, 26), "#9a9ea6")
  -- pennants on poles
  local function pole(x, col)
    fl(c, R(c, x, 12, x, 27), "#5e3f28")
    part(c, c:poly({ { x + 1, 12 }, { x + 7, 14 }, { x + 1, 16 } }), col)
  end
  pole(13, "#dd3a2a"); pole(36, "#4f9a45"); pole(59, "#3f8fb0")
  -- left: too hot, bubbling and orange-ish
  part(c, c:ellipse(13, 40, 11, 6), "#8b8f96", { shade = true })
  c:fill(c:ellipse(13, 40, 8, 4), "#e07a52"); c:fill(R(c, 8, 39, 12, 39), "#f0a070")
  for _, b in ipairs({ { 10, 41 }, { 15, 40 }, { 13, 42 }, { 17, 41 } }) do c:px(b[1], b[2], "#ffd8b0"); c:px(b[1] + 1, b[2], "#ffd8b0") end
  wisp(c, 9, 35, 8); wisp(c, 14, 35, 7, nil, -1); wisp(c, 18, 36, 6)
  -- right: too cold, ice floes and frost
  part(c, c:ellipse(59, 40, 11, 6), "#b8c4d4", { shade = true })
  c:fill(c:ellipse(59, 40, 8, 4), "#6aa4d8"); c:fill(R(c, 55, 39, 59, 39), "#a8cef0")
  
  c:paint({ "..x..", ".xxx.", "xxxxx", ".xxx.", "..x.." }, 60, 28, { x = "#d8ecf8" })
  c:px(56, 33, "#fbfdfe"); c:px(65, 34, "#fbfdfe"); c:px(52, 30, "#fbfdfe")
  c:fill(c:poly({ { 55, 42 }, { 57, 38 }, { 59, 42 } }), "#e8f4fa"); c:fill(c:poly({ { 61, 41 }, { 64, 37 }, { 66, 41 } }), "#e8f4fa"); c:px(57, 40, "#a8cef0"); c:px(64, 39, "#a8cef0")
  -- middle: just right, with the gnome in it up to the nose
  part(c, c:ellipse(36, 41, 13, 7), "#8b8f96", { shade = true })
  c:fill(c:ellipse(36, 41, 10, 5), "#58b4c4")
  local _, G = gnome(c, 36, 43, { s = 1, d = 1, upper = true, eyes = "happy" })
  c:fill(c:ellipse(36, 41, 10, 5):clip(R(c, 0, 33, W, 60)), "#58b4c4")
  for x = 28, 44 do if x % 3 ~= 0 then c:px(x, 33, "#a8e6e6") end end
  fl(c, R(c, 29, 37, 33, 37), "#7ccfd4"); fl(c, R(c, 39, 38, 43, 38), "#7ccfd4")
  for _, st in ipairs({ { 25, 46 }, { 30, 48 }, { 36, 49 }, { 42, 48 }, { 47, 46 } }) do part(c, c:ellipse(st[1], st[2], 3, 2), "#9a9ea6", { shade = true }) end
  c:paint({ ".p.p.", "ppppp", ".ppp.", "..p.." }, 44, 22, { p = "#e8708a" })
  finish(c, "w5_just_right_pool")
end

-- 13. dry_towel: rainy day, one fluffy dry towel found in a soaked pile
function S.w5_dry_towel()
  seed = 43
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 30), { "#6e7e90", "#7c8c9c", "#8a9aaa", "#98a8b6" }, { dir = "v" })
  c:fill(R(c, 0, 30, W - 1, H - 1), "#6a7e5a")
  -- back wall under the bench roof, dim planks
  c:fill(R(c, 8, 12, 65, 36), "#6a4a30")
  for x = 12, 64, 6 do fl(c, R(c, x, 12, x, 36), "#523a24") end
  -- floor of the shelter
  c:fill(R(c, 5, 36, 68, 49), "#9a6c3a")
  for y = 40, 48, 4 do fl(c, R(c, 5, y, 68, y), "#7e5a30") end
  -- roof and posts
  part(c, R(c, 6, 5, 7, 36), "#8a5a35", { noline = true }); part(c, R(c, 66, 5, 67, 36), "#8a5a35", { noline = true })
  part(c, c:poly({ { 3, 14 }, { 36, 4 }, { 70, 14 } }), "#a8442e")
  for x = 12, 62, 8 do fl(c, R(c, x, 11, x + 2, 11), "#8a2e1e") end
  fl(c, R(c, 4, 13, 69, 13), "#c85a3a")
  -- drips from the eave and puddles
  for _, x in ipairs({ 12, 22, 31, 44, 53, 62 }) do fl(c, R(c, x, 16, x, 17), "#9ec8e8") end
  -- the soaked pile on a shelf at right
  part(c, R(c, 34, 38, 64, 41), "#8a5a35")
  part(c, R(c, 36, 33, 62, 38), "#4a6e8a"); fl(c, R(c, 36, 35, 62, 35), "#3a5a76")
  part(c, R(c, 38, 29, 60, 33), "#58809c"); fl(c, R(c, 38, 31, 60, 31), "#46687e")
  part(c, R(c, 42, 25, 58, 29), "#4a6e8a"); fl(c, R(c, 42, 27, 58, 27), "#3a5a76")
  for _, d in ipairs({ { 40, 39 }, { 50, 42 }, { 60, 40 }, { 46, 43 }, { 56, 44 } }) do fl(c, R(c, d[1], d[2], d[1], d[2] + 1), "#9ec8e8") end
  -- the dry one, golden and fluffy, held up by the gnome
  local _, G = gnome(c, 22, 48, { s = 1.25, d = 1, eyes = "happy", arms = { arm({ -4, 7 }, { 2, 12 }, false, true), arm({ 4, 7 }, { 8, 12 }, true, true) } })
  local tx, ty = G.P(5, 16)
  part(c, R(c, tx - 5, ty - 2, tx + 5, ty + 3), "#f8d878")
  for i = -4, 4, 2 do c:px(tx + i, ty - 3, "#f8d878"); fl(c, R(c, tx + i, ty - 3, tx + i, ty - 3), "#f8d878") end
  fl(c, R(c, tx - 4, ty - 1, tx + 4, ty - 1), "#fff0b0"); fl(c, R(c, tx - 4, ty + 1, tx + 4, ty + 1), "#e8b848")
  fl(c, R(c, tx - 6, ty - 2, tx - 5, ty), "#f0c8a0"); fl(c, R(c, tx + 5, ty - 2, tx + 6, ty), "#f0c8a0")
  for _, p in ipairs({ { tx - 7, ty - 6 }, { tx + 8, ty - 5 }, { tx, ty - 8 } }) do
    c:px(p[1], p[2], "#fff0b0"); c:px(p[1] - 1, p[2], "#ffd86a"); c:px(p[1] + 1, p[2], "#ffd86a"); c:px(p[1], p[2] - 1, "#ffd86a"); c:px(p[1], p[2] + 1, "#ffd86a")
  end
  -- rain beyond the shelter, puddles
  seed = 5
  for i = 1, 22 do
    local x = 5 + floor(rand() * 63); local y = 6 + floor(rand() * 40)
    if x < 6 or x > 66 or y > 30 and (x < 8 or x > 64) then c:px(x, y, "#b8d4ec"); c:px(x - 1, y + 1, "#b8d4ec") end
  end
  for _, x in ipairs({ 5, 7, 66, 68 }) do for y = 18, 46, 6 do c:px(x, y + (x % 3), "#b8d4ec") end end
  fl(c, R(c, 60, 47, 66, 48), "#8ab4d4")
  finish(c, "w5_dry_towel")
end

-- 14. spring_pump: heaving a hand pump to fill the top pool
function S.w5_spring_pump()
  seed = 47
  local c = new()
  day(c, 26, { cloud = 12, hill = "#5e8a44", hill2 = "#4e8a3c" })
  -- stone terrace on the right with the top pool
  part(c, R(c, 43, 28, 68, 49), "#8b8f96")
  for y = 33, 45, 5 do fl(c, R(c, 43, y, 68, y), "#6e727a") end
  for _, p in ipairs({ { 50, 28 }, { 58, 33 }, { 48, 38 }, { 62, 43 }, { 54, 43 } }) do fl(c, R(c, p[0 + 1], p[2], p[1], p[2] + 4), "#6e727a") end
  part(c, c:ellipse(56, 25, 14, 4), "#9a9ea6")
  c:fill(c:ellipse(56, 25, 11, 2), "#58b4c4"); c:fill(R(c, 50, 25, 55, 25), "#a8e6e6")
  wisp(c, 60, 23, 3)
  -- a soaker raising a cup
  part(c, R(c, 62, 19, 66, 23), "#f0c8a0"); fl(c, R(c, 62, 22, 66, 23), "#f4eee0")
  c:px(63, 21, INK); c:px(65, 21, INK)
  part(c, c:poly({ { 61, 19 }, { 67, 19 }, { 64, 13 } }), "#4f9a45")
  -- pump with its long handle
  part(c, R(c, 8, 30, 13, 46), "#3a3a42"); part(c, R(c, 6, 44, 15, 48), "#4a4a54")
  part(c, R(c, 4, 33, 8, 35), "#3a3a42")
  part(c, R(c, 9, 27, 12, 30), "#4a4a54")
  fl(c, c:line({ { 11, 28 }, { 28, 37 } }, 2), "#8a5a35")
  c:px(11, 28, "#c8ccd2")
  -- pipe to the pool
  fl(c, c:line({ { 14, 45 }, { 40, 45 }, { 40, 29 }, { 45, 27 } }, 2), "#6a6e76")
  fl(c, R(c, 14, 44, 40, 44), "#9aa0a8")
  -- the gush
  fl(c, R(c, 46, 26, 47, 26), "#a8e6e6"); fl(c, R(c, 48, 27, 49, 27), "#58b4c4"); c:px(47, 28, "#a8e6e6"); c:px(49, 29, "#a8e6e6")
  -- the gnome hauling the handle down
  local _, G = gnome(c, 34, 48, { s = 1.25, d = -1, eyes = "shut", arms = { arm({ 4, 7 }, { -4, 9 }, false), arm({ -4, 7 }, { -6, 9 }, true) } })
  -- drops and effort puffs
  for _, p in ipairs({ { 18, 22 }, { 22, 20 }, { 38, 24 } }) do fl(c, R(c, p[1], p[2], p[1] + 1, p[2]), "#f4f8fa") end
  finish(c, "w5_spring_pump")
end

-- 15. steam_stories: night, heads in the pool, a tale told under a steam cloud
function S.w5_steam_stories()
  seed = 53
  local c = new()
  c:bands(R(c, 0, 0, W - 1, 34), { "#10163a", "#18204a", "#222c58", "#2e386a", "#3c4878" }, { dir = "v" })
  seed = 4
  for i = 1, 26 do c:px(5 + floor(rand() * 63), 5 + floor(rand() * 20), "#f4eee0") end
  c:fill(c:ellipse(60, 12, 4, 4), "#f4eee0"); c:fill(c:ellipse(62, 11, 3, 3), "#18204a")
  c:fill(c:ellipse(14, 36, 30, 8), "#1a2a42"); c:fill(c:ellipse(60, 36, 28, 7), "#162438")
  c:fill(R(c, 0, 34, W - 1, H - 1), "#1c2e3c")
  -- lanterns on posts
  for _, x in ipairs({ 9, 64 }) do
    fl(c, R(c, x, 26, x, 40), "#4a3a2a")
    part(c, R(c, x - 2, 22, x + 2, 26), "#ffd86a"); fl(c, R(c, x - 1, 23, x + 1, 25), "#fff4c0")
    fl(c, R(c, x - 3, 21, x + 3, 21), "#4a3a2a")
  end
  -- the big steam cloud, with a tiny gnome riding it
  local cl, cs = "#c8d4e4", "#a8b8d0"
  c:fill(c:ellipse(36, 17, 12, 4), cl); c:fill(c:ellipse(28, 15, 6, 3), cl); c:fill(c:ellipse(44, 15, 6, 3), cl); c:fill(c:ellipse(36, 13, 6, 3), cl)
  c:fill(R(c, 26, 19, 46, 20), cs); c:fill(R(c, 30, 21, 42, 21), cs)
  c:paint({ "..rr..", ".rrrr.", "rrrrrr", ".hhhh.", ".wwww.", "wwwwww", ".wwww.", "bb..bb", "bb..bb" }, 33, 7, { r = "#c0442e", h = "#f0c8a0", w = "#f4eee0", b = "#5a3a22" })
  c:fill(R(c, 30, 13, 40, 14), cl)
  c:fill(R(c, 28, 16, 31, 16), cl); c:fill(R(c, 40, 16, 44, 16), cl)
  -- steam rising from the pool up into it
  wisp(c, 24, 39, 9, cl); wisp(c, 30, 38, 8, cs, -1); wisp(c, 42, 38, 8, cs); wisp(c, 48, 39, 9, cl, -1)
  -- the heads in the water
  gnome(c, 15, 45, { s = 1, d = 1, upper = true, hat = "#e8a317", eyes = "open" })
  gnome(c, 58, 45, { s = 1, d = -1, upper = true, hat = "#4f9a45", eyes = "open" })
  gnome(c, 36, 47, { s = 1.25, d = 1, upper = true, eyes = "open", mouth = "wide", arms = { arm({ 4, 6 }, { 8, 14 }, true) } })
  c:fill(R(c, 5, 40, 68, 49), "#2e7a8c"); c:fill(R(c, 5, 40, 68, 40), "#58b4c4")
  for _, w in ipairs({ { 8, 43, 7 }, { 22, 45, 6 }, { 48, 44, 8 }, { 58, 46, 6 }, { 28, 47, 5 } }) do fl(c, R(c, w[1], w[2], w[1] + w[3], w[2]), "#4a9ab0") end
  fl(c, R(c, 8, 42, 14, 42), "#ffd86a"); fl(c, R(c, 60, 43, 63, 43), "#ffd86a")
  part(c, R(c, 4, 47, 69, 51), "#5a5e66")
  finish(c, "w5_steam_stories")
end

local order = { "w5_snowy_path", "w5_steam_fortune", "w5_warm_curds", "w5_mineral_silt", "w5_buried_cornbread", "w5_pool_wall", "w5_darn_robes", "w5_towel_flick", "w5_steam_singing", "w5_pool_crusts", "w5_bathers_hats", "w5_just_right_pool", "w5_dry_towel", "w5_spring_pump", "w5_steam_stories" }
for _, s2 in ipairs(order) do
  if S[s2] and (not only or only == s2) then seed = 7; S[s2]() end
end
