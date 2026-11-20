local SOIL = "#3a2430"
local ROOFW = { hi = P.wood.hi, base = P.wood.base, shade = P.wood.shade, deep = P.wood.deep }
local X0, X1, Y, D = 20, 36, 46, 3

local function plot() return patch(5, 37, 51, 53) end

local function pinkWorm(cols, rows, sway, eyes, h)   -- standing worm, bottom row rows[2]
end

-- a standing worm: base centre (bx,by) = bottom row, h rows tall, 3 wide, tilts by sway at the top
local function wormUp(bx, by, h, sway, face)
  local m, cell = HP.mask(), {}
  for i = 0, h - 1 do
    local y = by - i
    local off = floor(sway * (i / (h - 1)) + (sway >= 0 and .5 or -.5))
    for dx = -1, 1 do m:set(bx + off + dx, y) end
    cell[i] = bx + off
  end
  ink(m)
  for i = 0, h - 1 do
    local y, cx = by - i, cell[i]
    local ring = (i % 3 == 2)
    px(cx - 1, y, ring and P.petal.base or P.petal.hi); px(cx, y, ring and P.petal.shade or P.petal.base); px(cx + 1, y, ring and P.petal.deep or P.petal.shade)
  end
  if face then
    local cx, y = cell[h - 1], by - (h - 1)
    px(cx - 1, y + 1, P.ink) px(cx + 1, y + 1, P.ink)
    px(cx, y + 2, P.ink)
  end
  return m
end

-- the box of trays (n = 1..3)
local function trayTop(k) return (k == 1) and 38 or (38 - 4 * (k - 1)) end
local function box(n)
  local yt = trayTop(n)
  local front, side, top = c:rect(X0, yt, X1, Y), sideWall(X1, yt, Y, D), topPlane(X0, X1, yt, D)
  ink(front, side, top)
  c:fillMask(front, P.sea.base) c:fillMask(side, P.sea.shade) c:fillMask(top, SOIL)
  -- soil top: crumbs and lit grains
  top:each(function(x, y) local h = hsh(x * 3, y * 7); if h < 18 then px(x, y, P.wood.deep) elseif h > 86 then px(x, y, P.wood.shade) end end)
  for k = 1, n do
    local ty = trayTop(k)
    local bot = (k == 1) and Y or (trayTop(k - 1) - 1)
    R(X0, ty, X1, ty, P.sea.hi)
    R(X0, ty + 1, X1, ty + 1, P.sea.deep)
    for i = 1, D do px(X1 + i, ty - rise(i), P.sea.base) px(X1 + i, ty + 1 - rise(i), P.sea.deep) end
    -- plank grooves on the front
    for yy = ty + 2, bot - 1 do for xx = X0 + 4, X1 - 1, 4 do if yy % 2 == 0 then px(xx, yy, lerp(P.sea.base, P.sea.shade, .5)) end end end
  end
  R(X0, Y, X1, Y, P.sea.shade)
  rimLight(front, P.sea.hi, P.sea.base)
  -- colony vents: a dark slot with a pink worm looking out
  local function vent(vx, vy)
    R(vx, vy, vx + 2, vy + 1, INTERIOR)
    px(vx, vy + 1, P.petal.base); px(vx + 1, vy + 1, P.petal.hi); px(vx + 1, vy, P.petal.base)
    R(vx - 1, vy + 2, vx + 3, vy + 2, P.sea.shade)
  end
  vent(24, 42); vent(31, 42)
  if n >= 2 then vent(27, trayTop(2) + 2) end
  if n >= 3 then vent(27, trayTop(3) + 2) end
  return yt
end

local function wormsOnTop()   -- soil squiggles on the open top
  px(23, 36, P.petal.base) px(24, 36, P.petal.hi) px(25, 37, P.petal.base)
  px(30, 37, P.petal.base) px(31, 36, P.petal.hi) px(32, 36, P.petal.base)
end

local function pail(x, y)     -- castings pail, (x,y) = bottom-left of a 7 wide x 7 tall pail
  local body = c:rect(x, y - 6, x + 6, y)
  local heap = c:rrect(x + 1, y - 9, x + 5, y - 6, 1)
  local handle = c:rect(x + 1, y - 11, x + 5, y - 10)
  ink(body, heap, handle)
  c:fillMask(handle, P.stone.shade)
  c:fillMask(heap, SOIL) px(x + 2, y - 8, P.wood.shade) px(x + 4, y - 7, P.wood.shade)
  cyl(body, x + 3, 3, SLATE, { t1 = .6 })
  R(x, y - 6, x + 6, y - 6, P.stone.hi)
  R(x, y - 3, x + 6, y - 3, SLATE.shade)
  px(x + 1, y - 5, P.cream)
end
local function spout()
  local pipe = c:rect(37, 39, 42, 40):add(c:rect(41, 41, 42, 43))
  ink(pipe)
  c:fillMask(pipe, P.stone.base)
  R(37, 39, 42, 39, P.stone.hi); R(37, 40, 42, 40, P.stone.shade); R(41, 41, 41, 43, P.stone.base); R(42, 41, 42, 43, P.stone.shade)
  px(41, 45, P.sea.hi); px(41, 46, P.sea.base)
end
local function roof()
  local yt = trayTop(3)
  for _, x in ipairs{ X0 + 1, X1 - 1 } do local m = c:rect(x, yt - 2, x, yt - 1); ink(m); c:part(m, "wood", { band = 1, nopop = true }) end
  local F, S = hipRoof(X0, X1, yt - 2, yt - 6, 2, 6, D)
  ink(F, S)
  paintRoof(F, S, ROOFW, { h = 2, w = 4, seed = 5 })
end

local function drawEmpty(k)
  newc()
  plot()
  -- corner stakes joined by a string line; stones and flowers
  sline(11, 36, 45, 36); sline(45, 36, 48, 47); sline(48, 47, 8, 47); sline(8, 47, 11, 36)
  stake(11, 36, 40); stake(45, 36, 40); stake(8, 47, 51); stake(48, 47, 51)
  stone(15, 49, 3); stone(39, 42, 2); stone(24, 51, 2)
  flower(14, 42, P.petal.base); flower(38, 50, P.gold.base); flower(20, 50, P.sky.hi); flower(43, 44, P.petal.hi)
  -- the sign: a smiling pink worm balances the board on its head
  local sw = ({ 0, 1, 0, -1 })[k]
  local mound = E(28, 44, 4, 1); ink(mound); c:part(mound, "wood", { band = 1, nopop = true })
  local cx = 28 + sw
  local head = c:rrect(cx - 3, 28, cx + 3, 33, 2)
  local body = wormUp(28, 44, 10, sw, false)   -- rows 35..44
  local bx0, by0 = 15 + sw, 14
  local board = c:rect(bx0, by0, bx0 + 24, by0 + 13)
  ink(head, board)
  c:fillMask(board, P.petal.base)
  c:fillMask(c:rect(bx0 + 1, by0 + 1, bx0 + 23, by0 + 12), P.cream)
  R(bx0 + 1, by0 + 12, bx0 + 23, by0 + 12, "#f6dfae")
  R(bx0, by0 + 13, bx0 + 24, by0 + 13, P.petal.shade)
  px(bx0, by0, P.petal.hi)
  drawBuild(bx0 + 3, by0 + 2, P.ink)
  c:part(head, "petal", { band = 2, pop = { x = cx - 2, y = 29, horizontal = true } })
  R(cx - 2, 30, cx - 2, 31, P.ink) R(cx + 2, 30, cx + 2, 31, P.ink)
  px(cx - 2, 30, P.ink) px(cx + 2, 30, P.ink)
  R(cx - 3, 32, cx - 3, 32, P.petal.hi); R(cx + 3, 32, cx + 3, 32, P.ember.hi)
  px(cx - 1, 32, P.ink) px(cx, 33, P.ink) px(cx + 1, 32, P.ink)
  -- tiny crate icon
  local ix = bx0 + 9
  R(ix, by0 + 8, ix + 6, by0 + 8, P.wood.deep); px(ix + 3, by0 + 8, P.petal.base); px(ix + 2, by0 + 8, P.petal.hi)
  R(ix, by0 + 9, ix + 6, by0 + 11, P.sea.base); R(ix, by0 + 9, ix + 6, by0 + 9, P.sea.hi); R(ix, by0 + 11, ix + 6, by0 + 11, P.sea.shade)
  px(ix + 3, by0 + 10, P.ink)
  -- a leaf drifts past
  local lx = ({ 2, 16, 30, 44 })[k]; local ly = ({ 35, 33, 35, 37 })[k]
  leaf(lx, ly)
  return c
end

local function wallLevel(n)
  newc()
  plot()
  local pitch = 8 + 4 * (n - 1)
  cast(X0, X1, Y, D, pitch, 3)
  if n >= 2 then pail(11, 46) end
  box(n)
  if n == 1 then wormsOnTop() end
  if n >= 3 then roof(); spout() end
  flower(15, 50, P.petal.base); flower(40, 50, P.gold.base); flower(46, 46, P.sky.hi)
  return c
end

local function drawReady(k)
  wallLevel(1)
  local sw1, sw2 = ({ -1, 0, 1, 0 })[k], ({ 1, 0, -1, 0 })[k]
  wormUp(24, 36, ({ 7, 8, 7, 6 })[k], sw1, true)
  wormUp(31, 36, ({ 6, 7, 8, 7 })[k], sw2, true)
  -- castings pile grows on the right
  local hgt = k + 1
  local pile = E(44, 46 - 1, 2 + k, hgt // 1 - 0 > 0 and (k + 1) // 2 + 1 or 1)
  local pm = c:rrect(41 - (k - 1), 46 - hgt, 47 + (k - 1) // 2, 46, 1)
  ink(pm); c:fillMask(pm, SOIL)
  pm:each(function(x, y) if y == 46 - hgt then px(x, y, P.wood.deep) end end)
  px(41 - (k - 1) + 1, 46 - hgt + 1, P.wood.shade); px(44, 47 - hgt + 1, P.wood.shade)
  c:sparkle(({ 14, 40, 18, 44 })[k], ({ 30, 28, 24, 34 })[k])
  c:sparkle(({ 46, 12, 38, 14 })[k], ({ 40, 38, 30, 40 })[k])
  badge(BOB[k])
  return c
end

local frames = {}
for k = 1, 4 do frames[k] = drawEmpty(k) end
saveStrip(frames, "worm_farm-empty", "empty")
savePiece(wallLevel(1), "worm_farm-l1")
savePiece(wallLevel(2), "worm_farm-l2")
savePiece(wallLevel(3), "worm_farm-l3")
frames = {}
for k = 1, 4 do frames[k] = drawReady(k) end
saveStrip(frames, "worm_farm-ready", "ready")
