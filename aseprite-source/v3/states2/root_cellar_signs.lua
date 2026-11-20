-- root_cellar EMPTY state only (BUILD-sign pass). 72x56, anchor (36,46)
dofile("/tmp/ase/states2/_sk4_kit.lua")
local out = app.params.out or "/tmp/ase/states2/root_cellar/"
local W, H, AX, AY = 72, 56, 36, 46

local CAR = { hi = P.gold.hi, base = lerp(P.ember.hi, P.gold.base, .35), shade = P.ember.base }

-- arrow pointing down: shaft (x0..x1, y0..ys) then a head down to a 2 px tip at row yt
local function arrowMask(dx)
  local M = c:rect(22 + dx, 6, 49 + dx, 18)
  local hy0, hy1 = 19, 33
  for y = hy0, hy1 do
    local r = y - hy0
    local hw = 18.5 - r * 18 / 14
    for x = math.ceil(35.5 - hw), math.floor(35.5 + hw) do M:set(x + dx, y) end
  end
  return M
end

local function carrot(x, y)
  local rows = {
    "G.GG.G",
    ".GgGG.",
    "..Gg..",
    ".OOOo.",
    ".hOOo.",
    ".OlOo.",
    "..Oo..",
    "..Oo..",
    "..lo..",
    "..o...",
  }
  local m = HP.mask()
  for r = 1, #rows do for q = 1, 6 do if rows[r]:sub(q, q) ~= "." then m:set(x + q - 1, y + r - 1) end end end
  ink(m)
  c:paint(rows, x, y, { G = P.moss.base, g = P.moss.shade, O = CAR.base, o = CAR.shade, h = CAR.hi, l = CAR.shade })
  px(x, y, P.moss.hi)
end

local function lace(x, y)   -- Queen Anne's lace: flat cream umbel on a thin stem
  local head = c:rect(x - 2, y, x + 2, y):add(c:rect(x - 1, y - 1, x + 1, y - 1))
  local stem = c:rect(x, y + 1, x, y + 4)
  ink(head, stem)
  c:fillMask(stem, P.moss.shade); c:fillMask(head, P.cream)
  px(x - 2, y, P.stone.hi); px(x + 2, y, P.stone.hi); px(x, y - 1, P.gold.hi)
end
local function sprout(x, y)   -- feathery carrot-top sprout
  local m = HP.mask():set(x, y):set(x - 1, y - 1):set(x + 1, y - 1):set(x, y - 2):set(x - 2, y - 2):set(x + 2, y - 2)
  ink(m); c:fillMask(m, P.moss.base); px(x, y, P.moss.shade); px(x - 2, y - 2, P.moss.hi); px(x, y - 2, P.moss.hi)
end

local SWAY = { 0, 1, 1, 0 }
local PUFF = {
  {},
  { { 45, 43, P.stone.hi }, { 48, 43, EARTH.hi }, { 46, 42, P.cream } },
  { { 43, 41, P.stone.hi }, { 50, 40, P.stone.hi }, { 47, 39, P.cream }, { 44, 39, EARTH.hi }, { 49, 42, EARTH.hi } },
  { { 42, 43, EARTH.hi }, { 51, 42, EARTH.hi }, { 47, 41, P.stone.hi } },
}

local function drawEmpty(k)
  newc(W, H, "root_cellar")
  local m = plot(11, 34, 61, 52, 13)
  footprint({ { 16, 39 }, { 56, 39 }, { 57, 49 }, { 15, 49 } }, 5)
  -- cool shadow of the arrow on the earth, lower right of its foot
  local sh = HP.mask()
  for i = 0, 9 do sh:set(39 + i, 36 + i // 3); sh:set(39 + i, 37 + i // 3) end
  sh:clip(m:shrink(1)); shadeUnder(sh, .45)
  -- the arrow sign, painted dusk-purple with a gold pinstripe and a visible thickness
  local dx = SWAY[k]
  local M = arrowMask(dx)
  slab(M, P.dusk.base, P.dusk.deep)
  M:edge():each(function(x, y)
    if not M:has(x, y - 1) or not M:has(x - 1, y) then px(x, y, P.dusk.hi) else px(x, y, P.dusk.shade) end
  end)
  M:shrink(1):edge():each(function(x, y) px(x, y, P.gold.base) end)
  -- worn paint: bare wood showing at a few edge chips, brush streaks in the margins
  for _, p in ipairs{ { 48, 6 }, { 49, 7 }, { 17, 19 }, { 54, 19 }, { 18, 19 } } do px(p[1] + dx, p[2], P.wood.base) end
  px(48 + dx, 7, P.wood.hi)
  R(21 + dx, 21, 23 + dx, 21, lerp(P.dusk.base, P.dusk.hi, .4)); R(41 + dx, 18, 45 + dx, 18, P.dusk.shade)
  R(25 + dx, 24, 29 + dx, 24, lerp(P.dusk.base, P.dusk.hi, .4)); R(44 + dx, 23, 48 + dx, 23, P.dusk.shade)
  -- two nail heads holding the shaft's battens
  px(20 + dx, 20, P.stone.hi); px(21 + dx, 20, P.stone.deep); px(51 + dx, 20, P.stone.hi); px(52 + dx, 20, P.stone.deep)
  -- BUILD (cream, deep shadow) on the shaft, carrot in the head
  word(26 + dx, 10, P.cream, P.dusk.deep)
  carrot(33 + dx, 20)
  -- soil heaped round the buried tip
  local mound = c:rect(31, 33, 40, 34):add(c:rect(29, 35, 42, 35)):cut(c:rect(31, 33, 31, 33)):cut(c:rect(40, 33, 40, 33))
  ink(mound)
  c:fillMask(mound, EARTH.base)
  R(32, 33, 36, 33, EARTH.hi); px(30, 35, EARTH.hi); R(37, 34, 41, 34, EARTH.shade); R(38, 35, 42, 35, EARTH.shade)
  -- ground details
  pebble(20, 44, 3); pebble(52, 41, 2); pebble(31, 49, 3)
  sprout(24, 47); sprout(41, 49)
  tuft(12, 40); tuft(61, 46, true); tuft(22, 52, true); tuft(50, 52)
  lace(14, 44); lace(59, 39); flower(37, 44, P.dusk.hi)
  -- life: a molehill heaves and puffs crumbs
  local mh = c:rect(45, 46, 48, 46):add(c:rect(46, 45, 47, 45))
  ink(mh); c:fillMask(mh, EARTH.base); px(46, 45, EARTH.hi); px(45, 46, EARTH.hi); px(48, 46, EARTH.shade)
  for _, p in ipairs(PUFF[k]) do px(p[1], p[2], p[3]) end
  return c
end

local ef = {}
for k = 1, 4 do ef[k] = drawEmpty(k) end
saveEmpty(ef, W, H, out, "root_cellar")
