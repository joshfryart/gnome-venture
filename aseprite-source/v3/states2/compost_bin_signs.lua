-- compost_bin EMPTY state only (BUILD-sign pass). 64x56, anchor (32,46)
dofile("/tmp/ase/states2/_sk4_kit.lua")
local out = app.params.out or "/tmp/ase/states2/compost_bin/"
local W, H, AX, AY = 64, 56, 32, 46

-- corrugated cardboard ramp (hue-shifted tan)
local CB = { hi = lerp(P.wood.hi, P.cream, .35), base = lerp(P.wood.hi, P.gold.hi, .25), shade = lerp(P.wood.hi, P.wood.base, .55), deep = P.wood.base }
local TAPE = lerp(P.gold.base, P.wood.base, .45)

local function appleCore(x, y)
  local rows = {
    "..s..",
    ".RRr.",
    "RRRRr",
    ".CdC.",
    "..C..",
    ".CdC.",
    "RRRRr",
  }

  local m = HP.mask()
  for r = 1, #rows do for q = 1, 5 do if rows[r]:sub(q, q) ~= "." then m:set(x + q - 1, y + r - 1) end end end
  ink(m)
  c:paint(rows, x, y, { s = P.wood.deep, R = P.ember.base, r = P.ember.shade, C = P.gold.hi, c = lerp(P.gold.hi, P.wood.hi, .5), d = P.wood.deep })
  px(x + 1, y + 1, P.ember.hi); px(x + 1, y + 2, P.ember.hi)
  px(x + 3, y, P.moss.base)                    -- tiny leaf on the stem
end
local function leafIcon(x, y)
  local rows = {
    ".....LL",
    "...LLlL",
    ".LLLlL.",
    "LLlLL..",
    "LlLL...",
    "s......",
  }
  local m = HP.mask()
  for r = 1, #rows do for q = 1, 7 do if rows[r]:sub(q, q) ~= "." then m:set(x + q - 1, y + r - 1) end end end
  ink(m)
  c:paint(rows, x, y, { L = P.moss.base, l = P.moss.deep, s = P.moss.shade })
  px(x + 1, y + 2, P.moss.hi); px(x + 2, y + 2, P.moss.hi); px(x, y + 3, P.moss.hi)
  px(x + 4, y + 3, P.moss.shade); px(x + 3, y + 4, P.moss.shade)
end

local FLAP = { 0, 1, 1, 0 }
local LEAF = { { 3, 21 }, { 6, 24 }, { 4, 27 }, { 7, 30 } }

local function drawEmpty(k)
  newc(W, H, "compost_bin")
  local m = plot(12, 34, 53, 52, 5)
  footprint({ { 17, 39 }, { 48, 39 }, { 49, 49 }, { 16, 49 } }, 5)
  -- cool shadow of the leaning lid on the earth
  local sh = HP.mask()
  for xx = 24, 49 do sh:set(xx, 40) end
  for xx = 26, 51 do sh:set(xx, 41) end
  sh:clip(m:shrink(1)); shadeUnder(sh, .45)
  -- the stake the lid leans on (behind, right)
  local stake = c:rect(44, 9, 45, 39)
  ink(stake)
  c:fillMask(stake, P.wood.base); R(45, 9, 45, 39, P.wood.shade); px(44, 9, P.wood.hi)
  R(42, 40, 47, 40, EARTH.hi)
  -- the crate lid: torn top-left corner, a torn top-right flap that flutters
  local f = FLAP[k]
  local T, B = 16, 36                                                -- plate top / bottom rows
  local plate = c:rect(17, T, 43, B)
  plate:cut(c:rect(17, T, 18, T)):cut(c:rect(17, T + 1, 17, T + 1))     -- torn corner
  plate:cut(c:rect(38, T, 43, T + 2))                                 -- flap lives separately
  local flap = c:rect(38, T - f, 43, T + 2 - f):cut(c:rect(43, T - f, 43, T - f))
  local side = c:rect(44, T + 3, 44, B)                               -- edge thickness on the right
  local bottom = c:rect(18, B + 1, 44, B + 1)
  ink(plate, flap, side, bottom)
  c:fillMask(side, CB.deep); c:fillMask(bottom, CB.deep)
  c:fillMask(plate, CB.base)
  -- top edge: lit lip, then the exposed corrugation flutes
  plate:each(function(x, y)
    if not plate:has(x, y - 1) then px(x, y, CB.hi)
    elseif not plate:has(x, y - 2) then px(x, y, (x % 2 == 0) and P.wood.shade or CB.hi) end
    if not plate:has(x - 1, y) and plate:has(x, y - 2) then px(x, y, CB.hi) end
  end)
  -- the folded rim of the lid along the bottom (2 rows) with crease marks
  R(17, B - 1, 43, B - 1, CB.shade); R(17, B, 43, B, CB.deep)
  for xx = 21, 41, 6 do px(xx, B - 1, CB.deep) end
  -- flap: lit, with its own flutes; a dark tear where it lifts off
  c:fillMask(flap, CB.base)
  R(38, T - f, 42, T - f, CB.hi)
  for xx = 38, 43 do px(xx, T + 1 - f, (xx % 2 == 0) and P.wood.shade or CB.hi) end
  R(38, T + 2 - f, 43, T + 2 - f, CB.shade)
  R(37, T, 37, T + 2, P.ink)
  if f == 1 then R(38, T + 2, 43, T + 2, P.wood.shade) end
  -- tape strip over the left edge
  R(19, T, 21, T + 7, TAPE); R(19, T, 19, T + 7, lerp(TAPE, P.cream, .4)); px(21, T + 7, CB.shade); px(20, T + 8, CB.shade)
  -- coffee-ring stain, upper right
  for _, p in ipairs{ { 39, 20 }, { 40, 20 }, { 41, 21 }, { 41, 22 }, { 40, 23 }, { 39, 23 }, { 38, 22 }, { 38, 21 } } do px(p[1], p[2], CB.shade) end
  -- punched hole + twine wrapped twice round the stake
  px(42, 21, P.ink); px(42, 20, CB.shade)
  local TW, TWH = P.gold.base, P.gold.hi
  c:fillMask(c:line({ { 43, 21 }, { 46, 19 } }, 1), TW)
  R(44, 19, 46, 19, TW); R(44, 22, 46, 22, TW); px(44, 19, TWH); px(44, 22, TWH)
  R(46, 19, 46, 22, TW); px(47, 23, TW); px(47, 24, P.gold.shade)
  -- icons + marker lettering
  leafIcon(23, 19)
  appleCore(32, 18)
  word(21, 28, P.ink)
  -- pebbles keep the lid from sliding
  pebble(20, 38, 3); pebble(36, 38, 4)
  -- ground: eggshells, a banana-yellow peel bit, tufts, nasturtium + clover
  px(28, 46, P.cream); px(29, 46, P.stone.hi); px(28, 45, P.cream)
  px(43, 48, P.cream); px(44, 47, P.cream); px(44, 48, P.stone.hi)
  chip(22, 44, EARTH.hi)
  tuft(13, 41); tuft(53, 45, true); tuft(25, 52, true); tuft(44, 52)
  flower(14, 46, P.ember.hi); flower(51, 40, P.petal.hi); flower(34, 50, P.ember.hi)
  -- a leaf tumbling past on the breeze (flips every frame)
  local lx, ly = LEAF[k][1], LEAF[k][2]
  local lf
  if k % 2 == 1 then lf = HP.mask():set(lx + 1, ly):set(lx + 2, ly):set(lx, ly + 1):set(lx + 1, ly + 1):set(lx + 2, ly + 1):set(lx + 3, ly + 1):set(lx + 1, ly + 2):set(lx + 2, ly + 2)
  else lf = HP.mask():set(lx + 2, ly):set(lx + 1, ly + 1):set(lx + 2, ly + 1):set(lx, ly + 2):set(lx + 1, ly + 2) end
  ink(lf); c:fillMask(lf, P.gold.base)
  lf:each(function(x, y) if not lf:has(x + 1, y) or not lf:has(x, y + 1) then px(x, y, P.gold.shade) end end)
  lf:each(function(x, y) if not lf:has(x - 1, y) and not lf:has(x, y - 1) then px(x, y, P.gold.hi) end end)
  return c
end

local ef = {}
for k = 1, 4 do ef[k] = drawEmpty(k) end
saveEmpty(ef, W, H, out, "compost_bin")
