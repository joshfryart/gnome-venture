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

local function drawL2(o)
  o = o or {}
  newc()
  local x = 35
  K.cast(x - 18, x + 8, AY, 4, 8, 4)
  nestbox(x - 18, x - 12, x - 11, AY, true)
  local x0, x1, yt, mx, ry = coop(x, AY, { l = 11, r = 8, h = 12, rh = 8 })
  cupola(mx, ry)
  quail(x - 4, AY - 6)
  -- feeder in front of the right wall with a feeding quail behind it
  quail(x + 5, AY - 3 + (o.hop or 0))
  trough(x + 3, AY + 1)
  tuft(14, AY + 3); flower(18, AY + 3, P.petal.base)
  return c
end

local function drawL3(o)
  o = o or {}
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
  quail(x + 12, AY - 2 + (o.hop or 0))
  penFence(14, 50, AY + 7)
  straw(30, AY + 4); straw(40, AY + 5)
  return c
end

local BOB = { 0, -1, 0, 1 }
local HOP = { 0, -2, -3, -1 }
local WOB = { 0, -1, 0, 0 }
local function puff(px0, py0, k)
  local pf = { { { 0, 0 }, { 5, 0 } }, { { -1, -2 }, { 6, -2 } }, { { -2, -4 }, { 7, -4 } }, { { -2, -5 }, { 7, -5 } } }
  for _, q in ipairs(pf[k]) do px(px0 + q[1], py0 + q[2], P.cream); if k <= 2 then px(px0 + q[1] + 1, py0 + q[2], P.cream) end end
end
local function readyLevel(lv, k)
  local hop = HOP[k]
  local bx, by, hx, hy, sp
  if lv == 2 then
    drawL2({ hop = hop })
    bx, by = 51, AY - 1
    hx, hy = 40, AY - 3 + hop
    sp = { { 54, AY - 8 }, { 59, AY - 8 }, { 56, AY - 10 }, { 52, AY - 9 } }
  else
    drawL3({ hop = hop })
    bx, by = 52, AY - 1
    hx, hy = 43, AY - 2 + hop
    sp = { { 55, AY - 8 }, { 60, AY - 8 }, { 57, AY - 10 }, { 53, AY - 9 } }
  end
  basket(bx, by, true, WOB[k])
  puff(hx, hy + 6, k)
  -- feather drifts up from the nest-box quail
  local FP = { { 20, AY - 9 }, { 19, AY - 11 }, { 20, AY - 13 }, { 19, AY - 15 } }
  px(FP[k][1], FP[k][2], P.cream); px(FP[k][1] + 1, FP[k][2] - 1, P.cream)
  c:sparkle(sp[k][1], sp[k][2])
  K.badge(W, BOB[k])
  return c
end
for _, lv in ipairs{ 2, 3 } do
  local rf = {}
  for k = 1, 4 do rf[k] = readyLevel(lv, k) end
  K.strip(out, "quail_coop-ready-l" .. lv, rf, W, H, "ready")
end
