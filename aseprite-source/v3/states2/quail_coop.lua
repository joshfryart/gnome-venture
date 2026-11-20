-- Quail coop state sprites (64x56, ground centre at (32,46)). Hearth Pop v3.
local K = dofile("/tmp/ase/states2/qs_common.lua")
local HP, P = K.HP, K.P
local out = app.params.out or "/tmp/ase/states2/quail_coop/"
local W, H = 64, 56
local AX, AY = 32, 46
local c
local px, E, R, ink, lerp = K.px, K.E, K.R, K.ink, K.lerp
local sqrt, floor = math.sqrt, math.floor
local ROOF = K.ROOF
local function newc() c = K.newc(W, H, "quail_coop") return c end

local SOIL = { hi = "#d6b080", base = "#b98a5c", shade = "#996a48", deep = "#6f4535" }
local EGGR = { hi = P.cream, base = "#fbe9c0", shade = "#e8c48a", deep = "#b97a4a" }
local QMAP = { B = "wood.base", H = "wood.hi", S = "wood.shade", D = "wood.deep", g = "gold.base", e = P.ink, c = P.cream, w = "#f6dfae" }

---------------------------------------------------------------- props
-- a quail facing right, 7x6, top-left (x,y)
local QR = { ".....DD.", "..HHHBBB", ".HBBBBeg", "HBcBBBww", "BBBcSSww", ".SSSSSS." }
local function quail(x, y) K.sprite(QR, x, y, QMAP) end
-- peeking head, 4x3
local QH = { "HBB.", "BeBg", "BBB." }
local function qhead(x, y) c:paint(QH, x, y, QMAP) end
local function stone(x, y) K.sprite({ ".hh.", "hbbs", "ssss" }, x, y, { h = P.stone.hi, b = P.stone.base, s = P.stone.shade }) end
local function flower(x, y, col)
  local head = HP.mask():set(x, y - 1):set(x - 1, y):set(x, y):set(x + 1, y):set(x, y + 1)
  local stem = c:rect(x, y + 2, x, y + 3)
  c:rim(HP.mask():add(head):add(stem), P.ink)
  c:fillMask(stem, P.moss.base); c:fillMask(head, col); px(x, y, P.gold.hi)
end
local function leaf(x, y) K.sprite({ ".ml", "mmm", "sm." }, x, y, { m = P.moss.base, l = P.moss.hi, s = P.moss.shade }) end
local EGGM = { h = P.cream, b = "#f6dfae", s = "#e8c48a", k = P.wood.shade }
local function egg(x, y) K.sprite({ ".hb.", "hbkb", "bbbs", ".ss." }, x, y, EGGM) end
local function basket(x, y, withEggs, wob)
  if withEggs then
    egg(x + 1, y - 3); egg(x + 6, y - 3 + (wob or 0)); egg(x + 3, y - 4)
  end
  local m = c:rrect(x, y, x + 10, y + 5, 1)
  ink(m)
  c:part(m, "wood", { band = 2, pop = { x = x + 2, y = y + 1, horizontal = true } })
  for yy = y + 1, y + 5 do for xx = x + 1, x + 9 do if (xx + yy) % 3 == 0 and m:has(xx, yy) and c:get(xx, yy) ~= P.wood.hi then px(xx, yy, P.wood.deep) end end end
  R(x, y, x + 10, y, P.gold.shade); px(x, y, P.gold.base)
end
local function straw(x, y) px(x, y, P.gold.hi) px(x + 1, y, P.gold.base) px(x + 2, y, P.gold.hi) px(x + 1, y - 1, P.gold.base) end

---------------------------------------------------------------- the coop
local function wallPlanks(front, side, W_, x0, x1, yt, y, d, x, o)
  for xx = x0 + 3, x1 - 1, 4 do R(xx, yt, xx, y, lerp(P.wood.base, P.wood.shade, .6)) end
  for xx = x0 + 1, x1, 4 do if math.abs(xx - x) > 4 then px(xx, yt + 3, P.wood.hi) px(xx, y - 2, P.wood.hi) end end
  side:each(function(xx, yy) if (yy + K.rise(xx - x1)) % 3 == 0 then px(xx, yy, W_.sdark) end end)
end
-- opts: l,r (half widths), h (wall height), rh (roof rise), vent, win
local function coop(x, y, o)
  local x0, x1, yt, d = x - o.l, x + o.r, y - o.h, 4
  local front, side = c:rect(x0, yt, x1, y), K.sideWall(x1, yt, y, d, 1)
  local F, S = K.hipRoof(x0, x1, yt - 1, yt - 1 - o.rh, 2, 7, d)
  ink(front, side, F, S)
  local W_ = K.wallTones(P.wood.base, P.wood.hi)
  K.paintWalls(front, side, W_, 13)
  wallPlanks(front, side, W_, x0, x1, yt, y, d, x, o)
  K.paintRoof(F, S, ROOF, { h = 3, w = 4, light = 14, dark = 8, seed = 9 })
  K.eaveShadow(x0, x1, yt, d, W_, 1)
  K.plinth(x0, x1, y, d, 1)
  K.door(x - 3, x + 3, y - 9, y, { open = true, frame = P.wood.deep, arch = 2, nostep = true })
  R(x - 3, y, x + 3, y, P.wood.hi)
  if o.win then K.window(o.win[1], o.win[2], 4, 4, { nobar = false, glow = false }) end
  local rx0, ry = F:bbox()
  return x0, x1, yt, (x0 + 7 + x1 - 5) // 2, yt - 1 - o.rh   -- ridge mid x, ridge y
end
local function cupola(mx, ry)
  K.sprite({ "..L..", ".LRL.", "RRRRR", "wDDDw", "wwwww" }, mx - 2, ry - 3, { L = P.ember.hi, R = P.ember.base, w = "wood.hi", D = "wood.deep" })
end
local function vane(mx, ry)
  local pole = c:rect(mx, ry - 7, mx, ry)
  ink(pole); R(mx, ry - 7, mx, ry, P.wood.deep)
  K.sprite({ ".gg.", "gggg", ".gg." }, mx - 1, ry - 9, { g = "gold.base" })
  px(mx, ry - 9, P.gold.hi)
end
-- nest-box extension on the left: front rect xe0..xe1, lean-to roof, hatch
local function nestbox(xe0, xe1, x0, y, withBird)
  local yt2 = y - 8
  local front = c:rect(xe0, yt2, xe1, y)
  local F2 = c:poly{ { xe0 - 2, yt2 + 1 }, { x0, yt2 - 5 }, { x0, yt2 + 1 } }
  ink(front, F2)
  local W_ = K.wallTones(P.wood.base, P.wood.hi)
  c:fillMask(front, W_.base)
  for xx = xe0 + 2, xe1, 3 do R(xx, yt2, xx, y, lerp(P.wood.base, P.wood.shade, .6)) end
  K.paintRoof(F2, HP.mask(), ROOF, { h = 3, w = 4, light = 14, dark = 8, seed = 5 })
  R(xe0, yt2 + 1, xe1, yt2 + 1, W_.eave)
  K.plinth(xe0, xe1, y, 0, 1)
  -- round hatch with a lit lip and straw
  local hx = xe0 + (xe1 - xe0) // 2 - 1
  R(hx - 1, y - 7, hx + 3, y - 2, P.wood.deep)
  R(hx, y - 6, hx + 2, y - 3, K.INTERIOR)
  R(hx - 1, y - 2, hx + 3, y - 2, P.wood.hi)
  straw(hx, y - 3)
  if withBird then qhead(hx - 1, y - 6) end
end
local function trough(x, y)  -- 10 wide feeder on two legs, full of seed
  local legs = c:rect(x + 1, y + 2, x + 2, y + 4):add(c:rect(x + 7, y + 2, x + 8, y + 4))
  local body = c:rrect(x, y, x + 9, y + 2, 1)
  ink(legs, body)
  c:part(legs, "wood", { band = 1, nopop = true })
  c:part(body, "wood", { band = 1, pop = { x = x + 1, y = y, horizontal = true } })
  R(x + 1, y, x + 8, y, P.gold.base); px(x + 2, y, P.gold.hi); px(x + 5, y, P.gold.hi); px(x + 7, y, P.gold.shade)
end
local function hangfeeder(x, ytop, ybot)   -- chain from the eave to a tube feeder with a tray
  local chain = c:rect(x + 2, ytop, x + 2, ybot - 7)
  local tube = c:rrect(x, ybot - 6, x + 4, ybot - 2, 1)
  local tray = c:rect(x - 1, ybot - 1, x + 5, ybot)
  ink(chain, tube, tray)
  R(x + 2, ytop, x + 2, ybot - 7, P.stone.shade)
  c:part(tube, "gold", { band = 2, pop = { x = x + 1, y = ybot - 5, horizontal = true } })
  c:part(tray, "wood", { band = 1, nopop = true })
  R(x, ybot - 3, x + 4, ybot - 3, P.wood.deep)
end
local function penFence(xa, xb, fy)
  local rails = c:rect(xa, fy - 4, xb, fy - 4):add(c:rect(xa, fy - 1, xb, fy - 1))
  local posts = HP.mask()
  for xx = xa, xb, 7 do posts:add(c:rect(xx, fy - 6, xx + 1, fy)) end
  posts:add(c:rect(xb - 1, fy - 6, xb, fy))
  ink(rails, posts)
  c:part(rails, "wood", { band = 1, nopop = true })
  c:part(posts, "wood", { band = 1, nopop = true })
  posts:each(function(xx, yy) if yy == fy - 6 then px(xx, yy, P.wood.hi) end end)
end
local function tuft(x, y) px(x, y, P.moss.base) px(x + 1, y - 1, P.moss.hi) px(x + 2, y, P.moss.base) end

---------------------------------------------------------------- pieces
local function drawL1(opt)
  opt = opt or {}
  newc()
  K.cast(AX - 11, AX + 8, AY, 4, 8, 4)
  local x0, x1, yt, mx, ry = coop(AX, AY, { l = 11, r = 8, h = 12, rh = 8 })
  if not opt.nobird then quail(AX - 3, AY - 6) end
  tuft(15, AY + 2); tuft(46, AY + 3); flower(14, AY - 2, P.petal.base)
  return c
end

local function drawL2()
  newc()
  local x = 35
  K.cast(x - 18, x + 8, AY, 4, 8, 4)
  nestbox(x - 18, x - 12, x - 11, AY, true)
  local x0, x1, yt, mx, ry = coop(x, AY, { l = 11, r = 8, h = 12, rh = 8 })
  cupola(mx, ry)
  quail(x - 4, AY - 6)
  -- feeder in front of the right wall with a feeding quail behind it
  quail(x + 5, AY - 3)
  trough(x + 3, AY + 1)
  tuft(14, AY + 3); flower(18, AY + 3, P.petal.base)
  return c
end

local function drawL3()
  newc()
  local x = 31
  K.cast(x - 11, x + 10, AY, 4, 8, 4)
  nestbox(x - 18, x - 12, x - 11, AY, true)
  local x0, x1, yt, mx, ry = coop(x, AY, { l = 11, r = 10, h = 16, rh = 9, win = { x - 8, AY - 12 } })
  vane(mx, ry)
  quail(x - 4, AY - 6)
  hangfeeder(x + 6, yt + 1, AY - 3)
  -- run: two quails behind a front fence
  quail(x - 10, AY - 3)
  quail(x + 12, AY - 2)
  penFence(14, 50, AY + 7)
  straw(30, AY + 4); straw(40, AY + 5)
  return c
end

-- ready
local BOB = { 0, -1, 0, 1 }
local HOP = { 0, -2, -3, -1 }
local function drawReady(k)
  drawL1({ nobird = true })
  -- eggs in a basket by the coop, one egg wobbles
  basket(11, AY - 1, true, ({ 0, -1, 0, 0 })[k])
  -- hopping quail on the right
  local hy = AY - 5 + HOP[k]
  quail(45, hy)
  local pf = { { { 45, AY + 1 }, { 53, AY + 1 }, { 49, AY + 2 } }, { { 44, AY - 1 }, { 54, AY - 1 } }, { { 43, AY - 3 } }, { { 55, AY - 3 } } }
  for _, q in ipairs(pf[k]) do px(q[1], q[2], P.cream); if k <= 2 then px(q[1] + 1, q[2], P.cream) end end
  -- glints on the eggs
  local SP = { { 14, AY - 8 }, { 19, AY - 8 }, { 16, AY - 10 }, { 12, AY - 9 } }
  c:sparkle(SP[k][1], SP[k][2])
  K.badge(W, BOB[k])
  return c
end

-- empty: plot, stakes, string, stones, flowers, egg sign
local SIGNICON = { "..RR..", ".RRRR.", "RRRRRR", "wwDDww", "wwDDww" }
local function eggMask(cx, top, cy0, a, hh)
  local m = HP.mask()
  for y = top, top + 2 * hh do
    local t = (y - cy0) / hh
    if t > -1 and t < 1 then
      local hw = floor(a * sqrt(1 - t * t) * (1 + 0.18 * t) + .5)
      for xx = cx - hw, cx + hw - 1 do m:set(xx, y) end
    end
  end
  return m
end
local function eggSign(dx)
  local cx = AX + dx
  local stick = c:rect(AX - 1, 31, AX, 41)
  local egg_ = eggMask(cx, 5, 18, 12.5, 13)
  ink(stick, egg_)
  c:part(stick, "wood", { band = 1, nopop = true })
  c:part(egg_, EGGR, { band = 3, nopop = true })
  -- speckles away from the writing
  for _, s in ipairs{ { -8, 8 }, { 5, 7 }, { 9, 10 }, { -9, 14 }, { 8, 15 }, { -2, 5 }, { 10, 27 - 6 }, { -10, 25 } } do
    local sx, sy = cx + s[1], 5 + s[2]
    if egg_:has(sx, sy) and (sy < 20 or sy > 26) then px(sx, sy, P.wood.hi) end
  end
  c:paint(SIGNICON, cx - 3, 12, { R = P.ember.base, w = "wood.base", D = "wood.deep" })
  px(cx - 3, 14, P.ember.hi); px(cx - 2, 13, P.ember.hi)
  K.build(cx - 9, 21, P.ink)
end
local function stake(x, y1)
  local m = c:rect(x, y1 - 5, x, y1)
  ink(m); c:part(m, "wood", { band = 1, nopop = true })
end
local function drawEmpty(k)
  newc()
  -- plot of cleared earth
  local m = E(32, 39, 27, 8)
  ink(m)
  c:part(m, SOIL, { band = 3, nopop = true })
  for _, p in ipairs{ { 10, 40 }, { 18, 43 }, { 27, 45 }, { 38, 45 }, { 47, 43 }, { 53, 40 }, { 22, 36 }, { 42, 36 }, { 33, 34 } } do
    R(p[1], p[2], p[1] + 3, p[2], SOIL.hi); R(p[1] + 1, p[2] + 1, p[1] + 3, p[2] + 1, SOIL.shade)
  end
  local function sl(x0, y0, x1, y1) c:fillMask(c:line({ { x0, y0 }, { x1, y1 } }, 1), P.cream) end
  sl(14, 34, 50, 34); sl(50, 34, 52, 40); sl(52, 40, 12, 40); sl(12, 40, 14, 34)
  stake(14, 38); stake(50, 38); stake(12, 44); stake(52, 44)
  px(14, 33, P.wood.hi); px(50, 33, P.wood.hi); px(12, 39, P.wood.hi); px(52, 39, P.wood.hi)
  stone(18, 43); stone(42, 44); K.sprite({ "hb", "ss" }, 22, 36, { h = P.stone.hi, b = P.stone.base, s = P.stone.shade })
  flower(8, 40, P.cream); flower(56, 41, P.petal.base); flower(28, 44, P.gold.base)
  -- small cast shadow of the sign on the soil, then the sign
  R(AX + 1, 42, AX + 7, 43, K.SHADOW)
  eggSign(({ 0, 1, 0, -1 })[k])
  -- life: a quail hops on the plot, a leaf blows past
  local hy = ({ 0, -2, -3, -1 })[k]
  quail(43, 33 + hy)
  local LP = { { 3, 20 }, { 8, 17 }, { 13, 19 }, { 18, 16 } }
  leaf(LP[k][1], LP[k][2])
  return c
end

---------------------------------------------------------------- output
local fr = {}
for k = 1, 4 do fr[k] = drawEmpty(k) end
K.strip(out, "quail_coop-empty", fr, W, H, "empty")
K.save(out, "quail_coop-l1", drawL1())
K.save(out, "quail_coop-l2", drawL2())
K.save(out, "quail_coop-l3", drawL3())
local rf = {}
for k = 1, 4 do rf[k] = drawReady(k) end
K.strip(out, "quail_coop-ready", rf, W, H, "ready")
