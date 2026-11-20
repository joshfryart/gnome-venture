-- tortoise_run: EMPTY state, pass 2 (small, quiet BUILD sign). 64x48, anchor (32,38).
-- A pale board strapped to a low boulder with a leather band and buckle; a tiny tortoise
-- sits on top of the boulder and nods; the loose strap end flicks.
local S = dofile("/tmp/ase/states2/q4signs2_common.lua")
local K, HP, P = S.K, S.HP, S.P
local px, R = S.px, S.R
local out = app.params.out or "/tmp/ase/states2/tortoise_run/"
local W, H, AX, AY = 64, 48, 32, 38
local c

local BOARD = { hi = "#fbe2b8", base = "#f0cfa0", shade = "#d9a978" }
local LEATHER = { hi = "#c47f50", base = P.wood.shade, shade = "#6a3a2c" }

local function sign(k)
  local sw = ({ 0, 1, 1, 0 })[k]
  local nod = ({ 0, 0, 1, 1 })[k]
  -- boulder (only its dome shows above the board)
  local rock = c:ellipse(AX, AY - 10, 10, 8):clip(c:rect(0, 0, W - 1, AY - 5))
  K.ink(rock)
  K.ball(rock, AX, AY - 12, 10, 7, P.stone, { t1 = .62, t2 = .12, t3 = -.3, nospec = true })
  px(AX - 7, AY - 15, P.stone.base) px(AX + 4, AY - 17, P.stone.base) px(AX + 7, AY - 15, P.stone.deep) px(AX - 3, AY - 16, P.stone.shade)
  -- leather band round the boulder, buckle on the right, two loops holding the board
  R(AX - 9, AY - 14, AX + 9, AY - 14, LEATHER.hi)
  R(AX - 9, AY - 13, AX + 9, AY - 13, LEATHER.base)
  for x = AX - 8, AX + 8, 3 do px(x, AY - 13, LEATHER.shade) end
  R(AX + 5, AY - 14, AX + 6, AY - 13, P.gold.base) px(AX + 5, AY - 14, P.gold.hi) px(AX + 6, AY - 13, P.gold.shade)
  -- board
  local plate = c:rect(AX - 10, AY - 11, AX + 10, AY - 4)
  K.ink(plate)
  c:fillMask(plate, BOARD.base)
  R(AX - 10, AY - 11, AX + 10, AY - 11, BOARD.hi) R(AX - 10, AY - 11, AX - 10, AY - 4, BOARD.hi)
  R(AX - 9, AY - 4, AX + 10, AY - 4, BOARD.shade) R(AX + 10, AY - 10, AX + 10, AY - 4, BOARD.shade)
  S.text(AX - 9, AY - 10, P.ink)
  -- loops over the board's top edge
  for _, x in ipairs{ AX - 7, AX + 3 } do px(x, AY - 12, LEATHER.base) px(x, AY - 11, LEATHER.shade) end
  -- loose strap end hanging from the buckle, flicks 1 px
  px(AX + 7, AY - 13, LEATHER.base) px(AX + 7 + sw, AY - 12, LEATHER.shade)
  -- icon: a tiny tortoise sitting on the boulder, head nods
  local T = { ".gGg..", "gGgGgh" }
  local TM = { g = P.moss.base, G = P.moss.shade, h = P.wood.hi }
  local tx, ty = AX - 4, AY - 21
  local m = HP.mask()
  for j, row in ipairs(T) do for i = 1, #row do if row:sub(i, i) ~= "." then m:set(tx + i - 1, ty + j - 1) end end end
  local hx, hy = tx + 5, ty + 1 - nod
  if nod == 1 then m:set(hx, hy) end
  K.ink(m)
  c:paint(T, tx, ty, TM)
  px(tx + 2, ty, P.moss.hi)
  if nod == 1 then px(hx, hy, P.wood.hi) px(hx, ty + 1, P.moss.shade) end
end

local function drawEmpty(k)
  c = S.new(W, H, "tortoise_run"); S.c = c
  S.smallPlot(AX, AY, 5)
  R(AX + 4, AY - 2, AX + 12, AY - 2, S.SHADOW) R(AX + 6, AY - 1, AX + 11, AY - 1, S.SHADOW)
  sign(k)
  S.front(AX - 10, AX + 10, AY + 1, 3)
  S.pebble(AX - 6, AY, true) S.pebble(AX + 5, AY + 1)
  px(AX - 1, AY, P.moss.base) px(AX, AY - 1, P.moss.hi) px(AX + 1, AY, P.moss.base) px(AX, AY, P.moss.shade)  -- clover
  S.tuft(AX - 13, AY - 1) S.tuft(AX + 10, AY - 4)
  S.flower(AX + 12, AY - 1, P.gold.base, P.gold.deep, -1)
  return c
end

local fr = {}
for k = 1, 4 do fr[k] = drawEmpty(k) end
S.saveStrip(out, "tortoise_run", fr, W, H)
