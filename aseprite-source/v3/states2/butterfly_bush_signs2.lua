-- butterfly_bush: EMPTY state, pass 2 (small, quiet BUILD sign). 64x56, anchor (32,46).
-- A purple swallowtail pennant strung between two bare twigs, a little gold butterfly perched on
-- the right twig; the pennant tails flutter and a lilac petal drifts by.
local S = dofile("/tmp/ase/states2/q4signs2_common.lua")
local K, HP, P = S.K, S.HP, S.P
local px, R = S.px, S.R
local out = app.params.out or "/tmp/ase/states2/butterfly_bush/"
local W, H, AX, AY = 64, 56, 32, 46
local c

local CLOTH = { hi = P.dusk.base, base = P.dusk.shade, shade = "#4a3888" }

local function twigs()
  local m = c:rect(AX - 9, AY - 19, AX - 9, AY - 4):add(c:rect(AX + 9, AY - 19, AX + 9, AY - 4))
  m:set(AX - 10, AY - 20):set(AX - 8, AY - 20)        -- left fork
  m:set(AX + 10, AY - 19)                             -- right side spur under the butterfly
  K.ink(m)
  c:fillMask(m, P.wood.base)
  R(AX - 9, AY - 8, AX - 9, AY - 4, P.wood.shade) R(AX + 9, AY - 8, AX + 9, AY - 4, P.wood.shade)
  px(AX - 10, AY - 20, P.wood.hi) px(AX - 8, AY - 20, P.petal.base)   -- a pink bud on the fork
end

local function banner(k)
  local tw = ({ 0, 1, 1, 0 })[k]
  local L, Rx = AX - 10, AX + 10
  local cloth = c:rect(L, AY - 17, Rx, AY - 10)
  -- swallowtail: two points with a notch in the middle; the tips lift on frames 2-3
  for x = L, AX - 2 do cloth:set(x, AY - 9) end
  for x = AX + 2, Rx do cloth:set(x, AY - 9) end
  for x = L, AX - 5 do cloth:set(x, AY - 8) end
  for x = AX + 5, Rx do cloth:set(x, AY - 8) end
  if tw == 0 then
    for x = L, AX - 8 do cloth:set(x, AY - 7) end
    for x = AX + 8, Rx do cloth:set(x, AY - 7) end
  else
    cloth:set(L, AY - 7) cloth:set(Rx, AY - 7)
  end
  K.ink(cloth)
  c:fillMask(cloth, CLOTH.base)
  -- hem sleeve with gold running stitch, lit left edge, shaded right edge and tails
  R(L, AY - 17, Rx, AY - 17, CLOTH.hi)
  for x = L + 1, Rx - 1, 3 do px(x, AY - 17, P.gold.hi) end
  cloth:each(function(x, y)
    if y > AY - 17 and not cloth:has(x - 1, y) then px(x, y, CLOTH.hi)
    elseif y > AY - 17 and (not cloth:has(x + 1, y) or not cloth:has(x, y + 1)) then px(x, y, CLOTH.shade) end
  end)
  S.text(AX - 9, AY - 15, P.cream)
  -- ties to the twigs
  px(AX - 9, AY - 18, P.cream) px(AX + 9, AY - 18, P.cream)
end

local function drawEmpty(k)
  c = S.new(W, H, "butterfly_bush"); S.c = c
  S.smallPlot(AX, AY, 11)
  R(AX - 4, AY - 4, AX + 8, AY - 4, S.SHADOW) R(AX + 2, AY - 3, AX + 7, AY - 3, S.SHADOW)
  twigs()
  banner(k)
  -- icon: a little gold butterfly perched on the right twig
  K.sprite({ "hhkhh", "ookoo", ".o.o." }, AX + 8, AY - 21, { h = P.gold.hi, o = P.gold.base, k = P.ink })
  S.front(AX - 10, AX + 10, AY + 1, 3)
  S.pebble(AX - 6, AY, true) S.pebble(AX + 4, AY - 1)
  S.tuft(AX - 13, AY - 1) S.tuft(AX + 10, AY - 4)
  S.flower(AX + 12, AY - 2, P.dusk.hi, P.cream, -1)
  -- life: a lilac petal drifts past on the left
  local p = ({ { AX - 13, AY - 18 }, { AX - 12, AY - 15 }, { AX - 13, AY - 12 }, { AX - 12, AY - 9 } })[k]
  px(p[1], p[2], P.dusk.hi) px(p[1] + 1, p[2] + (k % 2), P.dusk.base)
  return c
end

local fr = {}
for k = 1, 4 do fr[k] = drawEmpty(k) end
S.saveStrip(out, "butterfly_bush", fr, W, H)
