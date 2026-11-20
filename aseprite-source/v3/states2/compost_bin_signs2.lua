-- compost_bin EMPTY state, pass 2 (SMALLER). 64x56, anchor (32,46)
-- a cardboard crate-lid leaning on a short stake, an apple core perched on the stake, a corner flap flutters, a leaf tumbles
dofile("/tmp/ase/states2/_sk5_kit.lua")
local out = app.params.out or "/tmp/ase/states2/compost_bin/"
local W, H, AX, AY = 64, 56, 32, 46

local CB = { hi = lerp(P.wood.hi, P.cream, .35), base = lerp(P.wood.hi, P.gold.hi, .25), shade = lerp(P.wood.hi, P.wood.base, .55), deep = P.wood.base }

local FLAP = { 0, 1, 1, 0 }
local LEAF = { { 24, 26 }, { 25, 27 }, { 24, 28 }, { 25, 29 } }

local function drawEmpty(k)
  newc(W, H, "compost_bin")
  local m = smallPlot(AX - 12, 38, AX + 12, 48, 5)
  smallFootprint(AX - 10, 41, AX + 10, 47, 3)
  -- cool shadow of the leaning lid on the earth
  local sh = HP.mask()
  for xx = AX - 9, AX + 11 do sh:set(xx, 43) end
  sh:clip(m:shrink(1)); shadeUnder(sh, .45)
  -- the stake behind the lid's right end
  local stake = c:rect(AX + 8, 29, AX + 9, 40)
  ink(stake)
  c:fillMask(stake, P.wood.base); R(AX + 9, 29, AX + 9, 40, P.wood.shade); px(AX + 8, 29, P.wood.hi)
  -- apple core perched on the stake top
  glyph({ ".s.", "RRr", ".C.", ".C.", "RRr" }, AX + 7, 24, { s = P.wood.deep, R = P.ember.base, r = P.ember.shade, C = P.gold.hi })
  px(AX + 7, 25, P.ember.hi); px(AX + 9, 24, P.moss.base)
  -- the lid: plain card face, lit lip, folded rim at the bottom; thickness lower right
  local T, B = 33, 39
  local plate = c:rect(AX - 11, T, AX + 9, B)
  local f = FLAP[k]
  plate:cut(c:rect(AX - 11, T, AX - 9, T))                -- the corner flap lives separately
  local flap = HP.mask():set(AX - 11, T - f):set(AX - 10, T - f):set(AX - 9, T - f)
  slab(plate:copy():add(flap), CB.base, CB.deep)
  R(AX - 8, T, AX + 9, T, CB.hi)
  R(AX - 11, B, AX + 9, B, CB.shade)
  px(AX - 8, B, CB.deep); px(AX - 2, B, CB.deep); px(AX + 4, B, CB.deep)
  c:fillMask(flap, CB.hi)
  if f == 1 then R(AX - 11, T, AX - 9, T, CB.shade) end
  -- twine tie from the lid to the stake
  px(AX + 10, 35, P.gold.base); px(AX + 10, 36, P.gold.shade)
  word(AX - 10, T + 1, P.ink)
  -- ground: two pebbles holding the lid, one nasturtium, eggshell, tufts
  pebble(AX - 8, 42, 3); pebble(AX + 3, 42, 2)
  px(AX + 6, 46, P.cream); px(AX + 7, 45, P.cream)
  tuft(AX - 10, 47); tuft(AX + 11, 46, true)
  flower(AX - 3, 44, P.ember.hi)
  -- life: a little leaf tumbling down past the lid's left end
  local lx, ly = LEAF[k][1], LEAF[k][2]
  local lf
  if k % 2 == 1 then lf = HP.mask():set(lx, ly):set(lx + 1, ly):set(lx + 1, ly + 1)
  else lf = HP.mask():set(lx + 1, ly):set(lx, ly + 1):set(lx + 1, ly + 1) end
  ink(lf); c:fillMask(lf, P.gold.base); px(lx + 1, ly + (k % 2 == 1 and 1 or 0), P.gold.shade)
  return c
end

local ef = {}
for k = 1, 4 do ef[k] = drawEmpty(k) end
saveEmpty(ef, W, H, out, "compost_bin")
