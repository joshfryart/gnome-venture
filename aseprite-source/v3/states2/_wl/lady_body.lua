local SOILP = "#3a2430"
local Y, D = 46, 3
local function plot() return patch(5, 37, 51, 53) end

local function ladybird(x, y, open)   -- 5 wide x 4 tall, (x,y) top-left; open = wings flicked up
  local body = c:rrect(x, y + 1, x + 4, y + 3, 1)
  local head = c:rect(x + 1, y, x + 3, y)
  local wm = HP.mask()
  if open then wm:add(c:rect(x - 1, y - 1, x, y + 1)):add(c:rect(x + 4, y - 1, x + 5, y + 1)) end
  ink(body, head, wm)
  c:fillMask(wm, P.sky.hi)
  c:fillMask(head, P.ink)
  c:fillMask(body, P.ember.base)
  px(x, y + 1, P.ember.hi); px(x + 1, y + 1, P.ember.hi); px(x + 4, y + 3, P.ember.shade)
  px(x + 2, y + 1, P.ink); px(x + 2, y + 2, P.ink); px(x + 2, y + 3, P.ink)
  px(x + 1, y + 2, P.ink); px(x + 3, y + 3, P.ink)
  px(x + 1, y, P.cream) px(x + 3, y, P.cream)
end

local function ledge(xa, xb, yy, rows)
  for r = 0, rows - 1 do
    R(xa, yy + r, xb, yy + r, (r == 0) and P.stone.base or SLATE.base)
  end
  R(xa, yy, xb, yy, P.stone.hi)
  R(xa, yy + rows - 1, xb, yy + rows - 1, SLATE.shade)
  px(xa - 1, yy, P.ink); px(xa - 1, yy + rows - 1, P.ink)
  for i = 1, D do
    for r = 0, rows - 1 do px(xb + i, yy + r - rise(i), (r == rows - 1) and SLATE.deep or SLATE.shade) end
    px(xb + i, yy - 1 - rise(i), P.ink)
  end
  px(xb + 1, yy, P.stone.base)
end

-- one storey: lit front, cool side
local function storey(x0, x1, yt, yb, seed, W)
  local front, side = c:rect(x0, yt, x1, yb), sideWall(x1, yt, yb, D, 1)
  ink(front, side)
  paintWalls(front, side, W, seed)
  eaveShadow(x0, x1, yt, D, W, 1)
  px(x0 + 1, yt + 1, P.ember.hi) px(x0 + 2, yt + 1, P.ember.hi)
  return front, side
end
local function spot(x, y) R(x, y, x + 1, y + 1, P.ink); px(x, y, P.ember.deep) end
local function roofOn(x0, x1, ye, yr, ov, a)
  local F, S = hipRoof(x0, x1, ye, yr, ov, a, D)
  ink(F, S)
  paintRoof(F, S, SLATE, { h = 2, w = 3, light = 18, dark = 0, seed = 3 })
end
local function doorway(x0)
  door(x0, x0 + 3, Y - 7, Y, { open = true, frame = P.wood.deep, arch = 2, nostep = true })
end
local WALL = wallTones(P.ember.base, P.ember.hi)
local function tier1(x0, x1, spots)
  storey(x0, x1, 35, Y, 11, WALL)
  for yy = 37, Y - 1, 3 do dkrow(x0 + 1, x0 + 4, yy, "ember") end
  for _, s in ipairs(spots) do spot(s[1], s[2]) end
  for i = 1, D do px(x1 + i, Y - 6 - rise(i), P.ink) end
  plinth(x0, x1, Y, D, 1)
  doorway(27)
end

local function lodge(n)
  newc()
  plot()
  local x0, x1 = 22, 35
  if n == 3 then x0, x1 = 20, 37 end
  cast(x0, x1, Y, D, ({ 12, 20, 32 })[n], 3)
  if n == 1 then
    tier1(x0, x1, { { 24, 38 }, { 32, 37 }, { 24, 43 } })
    roofOn(x0, x1, 34, 28, 2, 7)
  elseif n == 2 then
    tier1(x0, x1, { { 24, 38 }, { 24, 43 }, { 33, 41 } })
    storey(x0, x1, 27, 31, 21, WALL)
    for yy = 29, 30, 2 do dkrow(x0 + 1, x0 + 3, yy, "ember") end
    window(27, 28, 4, 2, { glow = true, frame = P.wood.base, nobar = true, sill = P.stone.hi, sillsh = lerp(P.ember.base, DUSKSH, .3) })
    window(24, 28, 2, 2, { frame = P.wood.base, nobar = true, nosill = true })
    ledge(x0 - 1, x1 + 1, 33, 2)
    roofOn(x0, x1, 26, 20, 2, 7)
    -- flower box under the lower right window
    R(31, 41, 35, 42, P.wood.base); R(31, 42, 35, 42, P.wood.shade)
    px(31, 40, P.petal.base) px(33, 40, P.gold.base) px(35, 40, P.petal.hi) px(32, 40, P.moss.base) px(34, 40, P.moss.base)
  else
    tier1(x0, x1, { { 22, 38 }, { 22, 43 }, { 35, 44 } })
    window(33, 38, 3, 3, { glow = true, frame = P.wood.base, nobar = true, sill = P.stone.hi, sillsh = lerp(P.ember.base, DUSKSH, .3) })
    storey(22, 35, 28, 32, 21, WALL)
    window(27, 29, 4, 2, { glow = true, frame = P.wood.base, nobar = true, nosill = true })
    ledge(x0 - 1, x1 + 1, 33, 2)
    storey(25, 32, 22, 25, 31, WALL)
    window(28, 23, 2, 2, { glow = true, frame = P.wood.base, nobar = true, nosill = true })
    ledge(23, 34, 26, 2)
    -- balcony rail on the middle storey
    R(24, 31, 33, 31, P.wood.base); R(24, 31, 33, 31, P.wood.hi)
    for _, xx in ipairs{ 24, 27, 30, 33 } do R(xx, 32, xx, 32, P.wood.shade) end
    px(34, 31, P.ink) px(23, 31, P.ink)
    roofOn(25, 32, 21, 19, 1, 1)
    -- flag
    local pole = c:rect(28, 15, 28, 18)
    local flag = HP.mask():set(29, 15):set(30, 15):set(31, 15):set(29, 16):set(30, 16):set(29, 17)
    ink(pole, flag)
    c:fillMask(pole, P.wood.deep); c:fillMask(flag, P.gold.base); px(29, 15, P.gold.hi); px(30, 16, P.gold.shade)
  end
  flower(14, 49, P.petal.base); flower(41, 50, P.gold.base); flower(46, 44, P.sky.hi)
  return c
end

local function drawEmpty(k)
  newc()
  plot()
  sline(11, 36, 45, 36); sline(45, 36, 48, 47); sline(48, 47, 8, 47); sline(8, 47, 11, 36)
  stake(11, 36, 40); stake(45, 36, 40); stake(8, 47, 51); stake(48, 47, 51)
  stone(15, 49, 3); stone(39, 42, 2); stone(24, 51, 2)
  flower(14, 42, P.petal.base); flower(38, 50, P.gold.base); flower(20, 50, P.sky.hi); flower(43, 44, P.petal.hi)
  local sw = ({ 0, 1, 0, -1 })[k]
  local cx, cy = 28 + sw, 17
  -- stake: wobbles with the board
  local stk = HP.mask()
  for y = cy + 6, 43 do
    local off = floor(sw * ((43 - y) / (43 - cy - 6)) + (sw >= 0 and .5 or -.5))
    stk:set(28 + off, y)
  end
  local mound = E(28, 43, 3, 1)
  ink(stk, mound)
  c:fillMask(mound, P.wood.base)
  stk:each(function(x, y) px(x, y, P.wood.base) end)
  -- leaf board
  local lm = E(cx, cy, 14, 7)
  lm:add(c:rect(cx + 14, cy, cx + 15, cy)):add(c:rect(cx - 15, cy + 1, cx - 14, cy + 1))   -- pointed tips
  ink(lm)
  c:part(lm, "moss", { band = 2, nopop = true })
  local pan = E(cx, cy - 1, 13, 5)
  c:fillMask(pan, P.moss.hi)
  c:fillMask(c:rect(cx - 9, cy - 5, cx + 9, cy - 1):copy(), P.moss.hi)
  px(cx - 12, cy + 1, P.moss.deep) px(cx + 12, cy + 2, P.moss.deep)   -- tiny veins at the ends
  R(cx - 4, cy + 6, cx + 4, cy + 6, P.moss.shade)
  drawBuild(cx - 9, cy - 5, P.ink)
  -- tiny lodge icon
  R(cx - 2, cy + 2, cx + 2, cy + 2, P.stone.shade); R(cx - 1, cy + 1, cx + 1, cy + 1, P.stone.base)
  R(cx - 2, cy + 3, cx + 2, cy + 4, P.ember.base); px(cx, cy + 4, P.ink); px(cx - 2, cy + 3, P.ember.hi)
  -- the ladybird on the leaf hops, flicking its wings in the air
  local hop = ({ 0, 0, 2, 0 })[k]
  ladybird(cx + 5, cy - 11 - hop, k == 3)
  -- a petal drifts past
  local pxx = ({ 3, 14, 38, 49 })[k]; local pyy = ({ 38, 36, 40, 37 })[k]
  local pm = HP.mask():set(pxx, pyy):set(pxx + 1, pyy):set(pxx + 1, pyy + 1)
  ink(pm); c:fillMask(pm, P.petal.hi); px(pxx + 1, pyy + 1, P.petal.base)
  return c
end

local function charm(x, y)   -- red lucky charm on a gold loop, 5x5 centre (x,y)
  local ring = E(x, y, 2, 2)
  ink(ring)
  c:part(ring, "ember", { band = 1, pop = { x = x - 1, y = y - 1, horizontal = true } })
  px(x, y, P.ink); px(x - 1, y + 1, P.cream); px(x + 1, y - 1, P.cream)
  R(x - 1, y - 4, x + 1, y - 3, P.gold.base); px(x - 1, y - 4, P.ink); px(x + 1, y - 4, P.ink); px(x, y - 4, P.gold.hi)
  px(x, y - 3, P.gold.hi)
end

local function drawReady(k)
  lodge(1)
  charm(28, 50 + ({ 0, -1, 0, 0 })[k])
  -- ladybird crosses the garden in hops
  local lx = ({ 5, 9, 13, 17 })[k]; local ly = ({ 41, 38, 41, 38 })[k]
  ladybird(lx, ly, k % 2 == 0)
  c:sparkle(({ 23, 33, 22, 34 })[k], ({ 49, 48, 46, 47 })[k])
  c:sparkle(({ 35, 21, 38, 24 })[k], ({ 51, 52, 52, 51 })[k])
  badge(BOB[k])
  return c
end

local frames = {}
for k = 1, 4 do frames[k] = drawEmpty(k) end
saveStrip(frames, "ladybird_lodge-empty", "empty")
savePiece(lodge(1), "ladybird_lodge-l1")
savePiece(lodge(2), "ladybird_lodge-l2")
savePiece(lodge(3), "ladybird_lodge-l3")
frames = {}
for k = 1, 4 do frames[k] = drawReady(k) end
saveStrip(frames, "ladybird_lodge-ready", "ready")
