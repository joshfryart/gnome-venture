-- silk_shelf: EMPTY state, pass 2 (small, quiet BUILD sign). 64x64, anchor (32,54).
-- A full reel of white silk on a short spindle peg, BUILD on the silk, a mulberry leaf tied at the knob;
-- the loose silk end swings and a silk moth flutters past.
local S = dofile("/tmp/ase/states2/q4signs2_common.lua")
local K, HP, P = S.K, S.HP, S.P
local px, R = S.px, S.R
local out = app.params.out or "/tmp/ase/states2/silk_shelf/"
local W, H, AX, AY = 64, 64, 32, 54
local c

local SILK = { hi = P.cream, base = "#f7e9c6", shade = "#e3cb98", line = "#ead6a8" }
local LEAF = { "lg.g", "gggs", ".ss." }
local LEAFMAP = { l = P.moss.hi, g = P.moss.base, s = P.moss.shade }

local function spool(sw)
  local L, Rx = AX - 10, AX + 10
  local face = HP.mask()
  for x = L + 2, Rx - 2 do face:set(x, AY - 18) end
  for x = L, Rx do face:set(x, AY - 17) face:set(x, AY - 16) end
  local body = c:rect(L, AY - 14, Rx, AY - 8):add(c:rect(L + 1, AY - 15, Rx - 1, AY - 15)):add(c:rect(L + 1, AY - 7, Rx - 1, AY - 7))
  local fB = c:rect(L, AY - 6, Rx, AY - 6):add(c:rect(L + 1, AY - 5, Rx - 1, AY - 5))
    local peg = c:rect(AX - 1, AY - 4, AX, AY - 3)
  local tail = c:line({ { AX + 6, AY - 4 }, { AX + 6 + sw, AY - 2 } }, 1):add(c:rect(AX + 6 + sw, AY - 1, AX + 6 + sw, AY - 1))
  K.ink(tail)
  K.ink(face, body, fB, peg)
  -- wooden flanges: lit top face with the spindle hole, shaded edge
  c:fillMask(face, P.wood.hi)
  R(L, AY - 16, Rx, AY - 16, P.wood.base) R(Rx - 3, AY - 16, Rx, AY - 16, P.wood.shade)
  R(Rx - 2, AY - 17, Rx, AY - 17, P.wood.base)
  c:fillMask(fB, P.wood.base) R(L + 1, AY - 5, Rx - 1, AY - 5, P.wood.shade) R(Rx - 3, AY - 6, Rx, AY - 6, P.wood.shade)
  c:fillMask(peg, P.wood.base) px(AX - 1, AY - 4, P.wood.shade) px(AX, AY - 4, P.wood.shade)
  -- wound silk: lit left, shaded right, winding lines in the margins only
  c:fillMask(body, SILK.base)
  R(L, AY - 14, L, AY - 8, SILK.hi) px(L + 1, AY - 15, SILK.hi)
  R(Rx, AY - 14, Rx, AY - 8, SILK.shade) R(L + 1, AY - 7, Rx - 1, AY - 7, SILK.shade) R(L + 1, AY - 15, Rx - 1, AY - 15, SILK.shade)
  for x = L + 2, Rx - 2, 2 do px(x, AY - 14, SILK.line) px(x + 1, AY - 8, SILK.line) end
  S.text(AX - 9, AY - 13, P.ink)
  -- loose silk end
  c:fillMask(tail, SILK.hi) px(AX + 6 + sw, AY - 1, SILK.shade)
  -- icon: a mulberry leaf tied to the knob
  K.sprite(LEAF, AX - 2, AY - 19, LEAFMAP)
end

local function drawEmpty(k)
  c = S.new(W, H, "silk_shelf"); S.c = c
  S.smallPlot(AX, AY, 7)
  R(AX + 1, AY - 2, AX + 6, AY - 2, S.SHADOW) R(AX + 2, AY - 1, AX + 4, AY - 1, S.SHADOW)
  spool(({ 0, 1, 1, 0 })[k])
  S.front(AX - 10, AX + 10, AY + 1, 3)
  S.pebble(AX - 7, AY - 1, true) S.pebble(AX + 6, AY)
  px(AX - 2, AY + 1, P.dusk.shade) px(AX - 1, AY + 1, P.dusk.deep) px(AX - 2, AY, P.dusk.hi)   -- fallen mulberry
  S.tuft(AX - 13, AY - 1) S.tuft(AX + 10, AY - 4)
  S.flower(AX + 12, AY - 1, P.dusk.hi, P.gold.hi, -1)
  -- life: a silk moth flutters by on the left
  local m = ({ { AX - 13, AY - 17 }, { AX - 12, AY - 19 }, { AX - 13, AY - 16 }, { AX - 12, AY - 14 } })[k]
  if k % 2 == 1 then px(m[1], m[2], P.cream) px(m[1] + 2, m[2], P.cream) px(m[1] + 1, m[2] + 1, P.wood.shade)
  else px(m[1], m[2] + 1, P.cream) px(m[1] + 1, m[2], P.cream) px(m[1] + 2, m[2] + 1, P.cream) px(m[1] + 1, m[2] + 1, P.wood.shade) end
  return c
end

local fr = {}
for k = 1, 4 do fr[k] = drawEmpty(k) end
S.saveStrip(out, "silk_shelf", fr, W, H)
