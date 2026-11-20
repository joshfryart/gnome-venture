-- tortoise_run: EMPTY state only (craft pass on the BUILD sign). 64x48, anchor (32,38).
local S = dofile("/tmp/ase/states2/q4signs_common.lua")
local K, HP, P = S.K, S.HP, S.P
local px, R = S.px, S.R
local lerp = K.lerp
local out = app.params.out or "/tmp/ase/states2/tortoise_run/"
local W, H, AX, AY = 64, 48, 32, 38
local c

local BOARD = { hi = "#fbe2b8", base = "#f0cfa0", shade = "#dcae7e", edge = "#b98a5c", edged = "#8c5e3e" }
local LEATHER = { hi = "#c47f50", base = P.wood.shade, shade = "#6a3a2c", deep = P.wood.deep }
local SHELL = {
  "...hhh...",
  ".hhgdgss.",
  "hgdgggdgs",
  "ggdgggdss",
  "rrrrrrrrr",
  ".k.....k.",
}
local SHELLMAP = { h = P.moss.hi, g = P.moss.base, d = P.moss.deep, s = P.moss.shade, r = P.gold.shade, k = P.wood.shade }
local BIRD = { ".hb....", "yebbb..", ".bcbbbt", "..ccbb.", "..k.k.." }
local BIRDMAP = { h = P.wood.hi, b = P.wood.base, y = P.gold.base, e = P.ink, c = P.cream, t = P.wood.shade, k = P.wood.deep }

local BM
local function boulder()
  local m = c:ellipse(25, 18, 22, 12):add(c:ellipse(32, 10, 11, 5)):add(c:ellipse(12, 22, 10, 8))
  BM = m
  K.ink(m)
  K.ball(m, 25, 16, 22, 15, P.stone, { t1 = .68, t2 = .2, t3 = -.25, nospec = true })
  -- cracks, chips and a moss cap
  for _, p in ipairs{ { 4, 24 }, { 5, 25 }, { 5, 26 }, { 45, 19 }, { 46, 20 }, { 10, 10 }, { 11, 9 }, { 41, 27 }, { 42, 28 }, { 18, 29 }, { 26, 5 }, { 40, 7 } } do px(p[1], p[2], P.stone.shade) end
  R(14, 7, 20, 7, P.moss.base) R(12, 8, 17, 8, P.moss.shade) R(21, 6, 25, 6, P.moss.base) px(22, 5, P.moss.hi) px(15, 7, P.moss.hi) px(23, 6, P.moss.hi)
  R(31, 5, 35, 5, P.stone.hi)
end
local function span(y)
  local a, b
  for x = 0, 63 do if BM:has(x, y) then a = a or x b = x end end
  return a, b
end

local function strap(y, x0, x1)
  R(x0, y, x1, y + 1, LEATHER.base)
  R(x0, y, x1, y, LEATHER.hi)
  R(x0, y + 1, x1, y + 1, LEATHER.base)
  for x = x0 + 1, x1 - 1, 3 do px(x, y + 1, LEATHER.shade) end   -- stitching
end

local function sign(sw)
  local x0, y0 = 7, 11
  local x1, y1 = x0 + 35, y0 + 15
  local plate = c:rect(x0, y0, x1, y1 - 1)
  local thick = c:rect(x0 + 1, y1, x1 + 1, y1):add(c:rect(x1 + 1, y0 + 1, x1 + 1, y1))
  -- strap mask: two bands across the boulder face (ends tucked at the boulder silhouette)
  local sT, sB = y0 + 1, y0 + 12
  local a1, b1 = span(sT + 1)
  local a2, b2 = span(sB + 1)
  local straps = c:rect(a1, sT, b1, sT + 1):add(c:rect(a2, sB, b2, sB + 1))
  local bk = x1 + 2
  local buckle = c:rect(bk, sT - 1, bk + 3, sT + 2)
  local tail = HP.mask():set(bk + 3, sT + 3):set(bk + 3 + sw, sT + 4):set(bk + 3 + sw, sT + 5)
  K.ink(plate, thick, straps, buckle, tail)
  -- board: pale planed wood, lit top/left edge, grain only in the margins
  c:fillMask(plate, BOARD.base)
  R(x0, y0, x1, y0, BOARD.hi) R(x0, y0, x0, y1 - 1, BOARD.hi)
  R(x0 + 1, y1 - 1, x1, y1 - 1, BOARD.shade)
  c:fillMask(thick, BOARD.edge) R(x0 + 1, y1, x1 + 1, y1, BOARD.edged)
  for _, g in ipairs{ { x0 + 14, y0 + 3, 6 }, { x0 + 24, y0 + 3, 8 }, { x0 + 4, y0 + 11, 7 }, { x0 + 22, y0 + 11, 9 } } do
    R(g[1], g[2], g[1] + g[3] - 1, g[2], BOARD.shade)
  end
  px(x0 + 33, y0 + 4, BOARD.edge) px(x0 + 2, y0 + 11, BOARD.edge)  -- knots
  -- icon + lettering (ink on pale wood, warm shadow)
  K.sprite(SHELL, x0 + 2, y0 + 4, SHELLMAP, true)
  S.text(x0 + 13, y0 + 5, P.ink, BOARD.shade)
  -- leather straps over the top and bottom margins, rivets where they cross the board edge
  strap(sT, a1, b1) strap(sB, a2, b2)
  for _, x in ipairs{ x0 + 1, x1 - 1 } do px(x, sT, P.stone.hi) px(x, sB, P.stone.hi) end
  -- iron buckle with a lit corner, loose strap tail swinging
  R(bk, sT - 1, bk + 3, sT + 2, P.stone.shade) R(bk + 1, sT, bk + 2, sT + 1, LEATHER.base) px(bk, sT - 1, P.stone.hi) px(bk + 1, sT - 1, P.stone.hi)
  px(bk + 1, sT, LEATHER.shade)
  c:fillMask(tail, LEATHER.base) px(bk + 3, sT + 3, LEATHER.hi)
end

local function drawEmpty(k)
  c = S.new(W, H, "tortoise_run"); S.c = c
  S.plot(7, 26, 58, 46, 5)
  S.footprint(13, 50, 31, 10, 53, 44, 5)
  -- boulder contact shadow on the plot, then the boulder and its sign
  R(12, 31, 49, 32, S.SHADOW) R(20, 33, 44, 33, S.SHADOW)
  boulder()
  sign(({ 0, 1, 1, 0 })[k])
  -- pebbles, clover, flowers
  S.pebble(28, 38, true) S.pebble(38, 42) S.pebble(17, 40)
  S.tuft(7, 40) S.tuft(56, 41) S.tuft(31, 46) S.tuft(55, 30)
  px(37, 41, P.moss.base) px(38, 40, P.moss.hi) px(39, 41, P.moss.base) px(38, 41, P.moss.shade)  -- clover
  S.flower(6, 41, P.gold.base, P.gold.deep, 1)
  S.flower(58, 36, P.petal.hi, P.gold.base, -1)
  -- life: a little sparrow hops on top of the boulder
  local hy = ({ 0, -2, -1, 0 })[k]
  local bx = ({ 46, 45, 44, 44 })[k]
  if hy == 0 then R(bx + 1, 41, bx + 5, 41, S.SHADOW) else R(bx + 2, 41, bx + 4, 41, S.SHADOW) end
  K.sprite(BIRD, bx, 36 + hy, BIRDMAP)
  return c
end

local fr = {}
for k = 1, 4 do fr[k] = drawEmpty(k) end
S.saveStrip(out, "tortoise_run", fr, W, H)
