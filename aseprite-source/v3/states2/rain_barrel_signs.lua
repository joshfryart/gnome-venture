-- rain_barrel EMPTY state only (BUILD-sign pass). 56x56, anchor (28,46)
dofile("/tmp/ase/states2/_sk4_kit.lua")
local out = app.params.out or "/tmp/ase/states2/rain_barrel/"
local W, H, AX, AY = 56, 56, 28, 46

local function rope(x0, y0, x1, y1)
  local l = c:line({ { x0, y0 }, { x1, y1 } }, 1)
  local i = 0
  l:each(function(x, y) px(x, y, ((x + y) % 2 == 0) and P.gold.base or P.gold.shade) end)
end
-- cool shadow: shade the earth, flat shadow tone on bare ground
local function cast(mk)
  mk:each(function(x, y) local v = c:get(x, y); if v then px(x, y, lerp(v, DUSKSH, .45)) else px(x, y, SHD_A) end end)
end

local SWAY = { 0, 1, 0, -1 }
local DRIP = { { 0, 0 }, { 1, 0 }, { 2, 0 }, { 3, 0 } }

local function drawEmpty(k)
  newc(W, H, "rain_barrel")
  local m = plot(6, 34, 51, 52, 9)
  footprint({ { 11, 39 }, { 43, 39 }, { 44, 49 }, { 10, 49 } }, 5)
  -- puddle the drip falls into
  local pud = E(37, 46, 4, 1)
  c:fillMask(pud, P.sea.shade)
  R(34, 45, 37, 45, P.sea.base); px(35, 45, P.sky.hi)
  -- shadows of the gallows post and of the hanging board
  local sh = HP.mask()
  for i = 0, 4 do sh:set(49 + i, 42 + i // 2); sh:set(49 + i, 43 + i // 2) end
  cast(sh)
  local bs = HP.mask()
  for xx = 22, 46 do bs:set(xx, 37) end
  for xx = 23, 46 do bs:set(xx, 38) end
  bs:clip(m:shrink(1)); shadeUnder(bs, .4)
  -- gallows: upright post, arm out to the left, diagonal brace
  local post = c:rect(47, 2, 48, 42)
  local arm = c:rect(21, 2, 48, 3)
  local brace = c:line({ { 46, 11 }, { 40, 4 } }, 1):add(c:line({ { 46, 12 }, { 39, 4 } }, 1))
  ink(post, arm, brace)
  c:fillMask(post, P.wood.base); R(48, 4, 48, 42, P.wood.shade); R(47, 4, 47, 42, P.wood.base)
  for yy = 10, 40, 6 do px(47, yy, P.wood.shade) end
  c:fillMask(arm, P.wood.base); R(21, 2, 47, 2, P.wood.hi); R(22, 3, 48, 3, P.wood.shade)
  px(21, 3, P.wood.deep); px(48, 2, P.wood.hi)
  c:fillMask(brace, P.wood.shade); px(40, 4, P.wood.base)
  -- iron peg through the joint
  px(47, 3, P.stone.hi)
  R(45, 42, 50, 42, EARTH.hi); R(46, 43, 49, 43, EARTH.base)
  -- rope loop: wraps the arm, then a V down to two holes in the board
  local dx = SWAY[k]
  px(28, 1, P.gold.base); px(29, 1, P.gold.shade)
  px(28, 4, P.gold.shade); px(29, 4, P.gold.base); px(28, 5, P.gold.base); px(29, 5, P.gold.shade)
  local bx0, by0, bx1, by1 = 14 + dx, 12, 41 + dx, 32
  rope(28, 6, bx0 + 3, by0 + 1)
  rope(29, 6, bx1 - 3, by0 + 1)
  -- the board: bare-wood frame, blue enamel face, thickness lower-right
  local board = c:rrect(bx0, by0, bx1, by1, 1)
  slab(board, P.wood.base, P.wood.deep)
  R(bx0 + 1, by0, bx1 - 1, by0, P.wood.hi)
  R(bx1, by0 + 1, bx1, by1 - 1, P.wood.shade); R(bx0 + 1, by1, bx1 - 1, by1, P.wood.shade)
  local face = c:rect(bx0 + 1, by0 + 1, bx1 - 1, by1 - 1)
  c:fillMask(face, P.sea.shade)
  R(bx0 + 1, by0 + 1, bx1 - 1, by0 + 1, P.sea.base)       -- lit top of the paint
  R(bx0 + 1, by0 + 1, bx0 + 1, by1 - 1, P.sea.base)
  R(bx0 + 2, by1 - 1, bx1 - 1, by1 - 1, lerp(P.sea.shade, P.sea.deep, .5))
  -- brush streaks + paint chips (bare wood) in the corners, outside the lettering box
  R(bx0 + 3, by0 + 4, bx0 + 7, by0 + 4, lerp(P.sea.shade, P.sea.base, .5))
  R(bx1 - 9, by0 + 6, bx1 - 4, by0 + 6, lerp(P.sea.shade, P.sea.base, .5))
  R(bx0 + 3, by1 - 3, bx0 + 6, by1 - 3, lerp(P.sea.shade, P.sea.deep, .4))
  px(bx1 - 1, by0 + 1, P.wood.base); px(bx1 - 2, by0 + 1, P.wood.base); px(bx1 - 1, by0 + 2, P.wood.hi)
  px(bx0 + 1, by1 - 1, P.wood.base); px(bx0 + 2, by1 - 1, P.wood.shade)
  -- rope holes, rope threaded through
  px(bx0 + 3, by0 + 2, P.ink); px(bx1 - 3, by0 + 2, P.ink)
  px(bx0 + 3, by0 + 1, P.gold.base); px(bx1 - 3, by0 + 1, P.gold.base)
  -- water-drop icon
  local ix, iy = 25 + dx, by0 + 3
  local DROP = { "..a..", "..a..", ".aaa.", "aaaaa", "aaaaa", "aaaaa", ".aaa." }
  local dm = HP.mask()
  for r = 1, 7 do for q = 1, 5 do if DROP[r]:sub(q, q) == "a" then dm:set(ix + q - 1, iy + r - 1) end end end
  ink(dm)
  c:fillMask(dm, P.sky.hi)
  dm:each(function(x, y) if not dm:has(x + 1, y) or not dm:has(x, y + 1) then px(x, y, P.sky.shade) end end)
  px(ix + 1, iy + 3, P.cream); px(ix + 1, iy + 4, P.cream)
  -- BUILD in cream with a deep-sea drop shadow
  word(18 + dx, by0 + 13, P.cream, P.sea.deep)
  -- the drip: a bead forms under the board, falls, splashes in the puddle
  local ddx = 37 + dx
  if k == 1 then px(ddx, by1 + 3, P.sky.hi)
  elseif k == 2 then px(ddx, by1 + 3, P.sky.hi); px(ddx, by1 + 4, P.sea.base)
  elseif k == 3 then px(37, 40, P.sky.hi); px(37, 41, P.sea.base); px(37, 42, P.sea.base)
  else px(35, 44, P.sky.hi); px(39, 44, P.sky.hi); px(37, 43, P.cream); px(36, 45, P.sky.hi); px(38, 45, P.sky.hi) end
  -- ground: pebbles, mossy stone, tufts, forget-me-nots
  pebble(15, 44, 3); pebble(26, 49, 2)
  local ms = c:rect(8, 42, 11, 43); ink(ms); c:part(ms, "stone", { band = 1, nopop = true }); R(8, 42, 10, 42, P.moss.base); px(8, 42, P.moss.hi)
  tuft(7, 39); tuft(51, 47, true); tuft(20, 52); tuft(41, 52, true)
  flower(19, 46, P.sky.base); flower(29, 42, P.sky.base); flower(50, 38, P.cream)
  return c
end

local ef = {}
for k = 1, 4 do ef[k] = drawEmpty(k) end
saveEmpty(ef, W, H, out, "rain_barrel")
