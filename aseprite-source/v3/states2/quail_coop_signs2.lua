-- quail_coop: EMPTY state, pass 2 (small, quiet BUILD sign). 64x56, anchor (32,46).
-- Speckled egg-shaped plate on a short stick, tiny nest perched on top; a feather drifts down.
local S = dofile("/tmp/ase/states2/q4signs2_common.lua")
local K, HP, P = S.K, S.HP, S.P
local px, R = S.px, S.R
local out = app.params.out or "/tmp/ase/states2/quail_coop/"
local W, H, AX, AY = 64, 56, 32, 46
local c

local EGG = { hi = P.cream, base = "#f6e3b4", shade = "#e2c08e" }
local SPAN = { { -7, 6 }, { -9, 8 }, { -10, 10 }, { -10, 10 }, { -10, 10 }, { -10, 10 }, { -10, 10 }, { -9, 8 }, { -7, 5 } }
local NEST = { ".cE..", "wcewW", ".WWW." }
local NESTMAP = { c = P.cream, e = EGG.base, E = EGG.shade, w = P.wood.base, W = P.wood.shade }

local function sign(dx)
  local y0 = AY - 17
  local plate = HP.mask()
  for i, s in ipairs(SPAN) do for x = AX + s[1] + dx, AX + s[2] + dx do plate:set(x, y0 + i - 1) end end
  local stick = c:rect(AX - 1, AY - 8, AX, AY - 4)
  K.ink(stick, plate)
  c:fillMask(stick, P.wood.base) R(AX - 1, AY - 8, AX - 1, AY - 4, P.wood.hi) px(AX, AY - 4, P.wood.shade)
  c:fillMask(plate, EGG.base)
  -- light from the upper left, shade on the lower right rim
  plate:each(function(x, y)
    if not plate:has(x, y - 1) and x < AX + 3 + dx then px(x, y, EGG.hi)
    elseif not plate:has(x - 1, y) and y < y0 + 5 then px(x, y, EGG.hi)
    elseif not plate:has(x, y + 1) or (not plate:has(x + 1, y) and y > y0 + 2) then px(x, y, EGG.shade) end
  end)
  -- quail speckles, margins only
  for _, s in ipairs{ { 2, 0, P.wood.shade }, { -5, 1, P.wood.base }, { 6, 1, P.wood.shade }, { -4, 7, P.wood.shade }, { 4, 7, P.wood.base }, { 0, 8, P.wood.shade } } do
    px(AX + s[1] + dx, y0 + s[2], s[3])
  end
  S.text(AX - 9 + dx, y0 + 2, P.ink)
  -- tiny nest perched on the egg's crown
  K.sprite(NEST, AX - 7 + dx, AY - 21, NESTMAP)
end

local function drawEmpty(k)
  c = S.new(W, H, "quail_coop"); S.c = c
  S.smallPlot(AX, AY, 3)
  R(AX + 1, AY - 3, AX + 5, AY - 3, S.SHADOW) R(AX + 2, AY - 2, AX + 4, AY - 2, S.SHADOW)
  sign(({ 0, 0, 1, 1 })[k])
  S.front(AX - 10, AX + 10, AY + 1, 3)
  S.pebble(AX - 7, AY - 2, true) S.pebble(AX + 5, AY)
  S.tuft(AX - 13, AY - 1) S.tuft(AX + 10, AY - 4)
  S.flower(AX + 12, AY - 3, P.cream, P.gold.base, -1)
  -- life: a little quail feather drifts down past the sign
  local f = ({ { AX - 13, AY - 16 }, { AX - 12, AY - 13 }, { AX - 13, AY - 10 }, { AX - 12, AY - 7 } })[k]
  px(f[1], f[2], P.wood.hi) px(f[1] + 1, f[2] + 1, P.wood.base) px(f[1] + 1, f[2], P.wood.shade)
  return c
end

local fr = {}
for k = 1, 4 do fr[k] = drawEmpty(k) end
S.saveStrip(out, "quail_coop", fr, W, H)
