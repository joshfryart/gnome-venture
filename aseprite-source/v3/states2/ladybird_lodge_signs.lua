-- ladybird_lodge EMPTY state: a big leaf sign cradled in two forked twigs, a ladybird strolling along its top edge.
local K = dofile("/tmp/ase/states2/signs4_kit.lua")
local out = app.params.out or "./"
K.init(56, 56, "ladybird_lodge", out)
local P, HP = K.P, K.HP
local px, R, E, ink, pt = K.px, K.R, K.E, K.ink, K.pt
local LEAF = { hi = P.moss.base, base = P.moss.shade, shade = "#337a48", deep = P.moss.deep, under = "#1d4140" }
local INTERIOR = "#3b2c48"

local function leafMask(dx)
  local q = { { 10, 22 }, { 12, 17 }, { 18, 13 }, { 28, 12 }, { 37, 12 }, { 44, 15 }, { 49, 19 }, { 45, 24 }, { 38, 29 }, { 28, 31 }, { 18, 30 }, { 12, 27 } }
  for _, p in ipairs(q) do p[1] = p[1] + dx end
  local m = K.c:poly(q)
  -- serrations: tiny notches along the edge
  for _, n in ipairs{ { 15, 15 }, { 24, 12 }, { 41, 13 }, { 47, 21 }, { 42, 27 }, { 22, 31 }, { 13, 25 } } do m.s[(n[2] + 256) * 1024 + (n[1] + dx + 256)] = nil end
  return m
end

local function twig(xb, yb, xt, yt)
  local mid = { xb + (xb < 28 and -2 or 2), (yb + yt) // 2 + 1 }
  local m = K.c:line({ { xb, yb }, mid, { xt, yt } }, 1)
  m:set(mid[1] + (xb < 28 and -1 or 1), mid[2] - 1)   -- a snapped-off side shoot
  return m
end

local function ladybird(x, y, open)   -- (x, y) = top-left of the 6x4 body; head on the left
  local shell = K.c:rrect(x + 1, y, x + 6, y + 3, 2)
  local head = K.c:rect(x, y + 1, x + 1, y + 3)
  local legs = pt{ { x + 2, y + 4 }, { x + 4, y + 4 }, { x + 6, y + 4 } }
  local wings = HP.mask()
  if open then wings = pt{ { x + 6, y - 2 }, { x + 7, y - 2 }, { x + 7, y - 1 }, { x + 8, y - 1 }, { x + 5, y - 1 }, { x + 6, y - 1 } } end
  ink(shell, head, wings)
  K.c:fillMask(wings, P.sky.hi); px(x + 8, y - 1, P.sky.base)
  K.c:fillMask(shell, P.ember.base)
  shell:each(function(a, b) if not shell:has(a + 1, b) or not shell:has(a, b + 1) then px(a, b, P.ember.shade) end end)
  px(x + 2, y, P.ember.hi); px(x + 3, y, P.ember.hi)
  px(x + 2, y + 2, P.ink); px(x + 5, y + 1, P.ink); px(x + 4, y + 3, P.ink)   -- spots
  K.c:fillMask(head, P.ink); px(x, y + 2, P.cream)                            -- eye
  K.c:fillMask(legs, P.ink)
end

local function drawEmpty(k)
  local c = K.newc()
  local sw = ({ 0, 1, 1, 0 })[k]
  local m = K.plotMask({ { 12, 35 }, { 44, 35 }, { 47, 50 }, { 9, 50 } }, 7)
  K.plot(m, 7)
  K.corners({ { 15, 39 }, { 41, 39 }, { 44, 47 }, { 12, 47 } }, 5)
  -- leaf shadow on the ground, lower right
  K.shadow(E(33, 45, 11, 1), .32)
  -- twigs (behind the leaf), stuck in the plot
  local tl, tr = twig(18, 45, 17 + sw, 29), twig(37, 45, 38 + sw, 29)
  ink(tl, tr)
  K.c:fillMask(tl, P.wood.shade); K.c:fillMask(tr, P.wood.shade)
  px(18, 45, P.wood.deep); px(37, 45, P.wood.deep)
  -- the leaf: underside rim (thickness), blade, lit and shaded edges
  local lm = leafMask(sw)
  local under = lm:copy():shift(0, 1):cut(lm)
  ink(lm, under)
  K.c:fillMask(under, LEAF.under)
  K.c:fillMask(lm, LEAF.base)
  lm:each(function(x, y)
    if not lm:has(x - 1, y) or not lm:has(x, y - 1) then px(x, y, LEAF.hi)
    elseif not lm:has(x + 1, y) or not lm:has(x, y + 1) then px(x, y, LEAF.deep) end
  end)
  -- stem and midrib at both ends, side veins, all clear of the lettering
  local stem = K.c:line({ { 6 + sw, 24 }, { 10 + sw, 22 } }, 1)
  ink(stem); K.c:fillMask(stem, P.moss.base)
  R(11 + sw, 22, 16 + sw, 22, LEAF.hi); R(41 + sw, 20, 47 + sw, 20, LEAF.hi)
  for _, v in ipairs{ { 13, 21, 14, 19 }, { 14, 23, 15, 25 }, { 43, 19, 42, 17 }, { 44, 21, 43, 23 }, { 15, 21, 16, 20 } } do
    K.c:fillMask(K.c:line({ { v[1] + sw, v[2] }, { v[3] + sw, v[4] } }, 1), LEAF.shade)
  end
  px(20 + sw, 14, P.moss.hi); px(21 + sw, 14, P.moss.hi)   -- dew glint
  -- lettering: cream on dark leaf, deep drop shadow
  K.word(19 + sw, 15, P.cream, LEAF.under)
  -- icon: the little red bug hotel
  K.c:paint({
    "...a...",
    "..aba..",
    ".aaaaa.",
    "aaaaaaa",
    ".hrrrr.",
    ".rrdrs.",
    ".rrdrs." }, 25 + sw, 22, { a = P.stone.shade, b = P.stone.hi, h = P.ember.hi, r = P.ember.base, s = P.ember.shade, d = INTERIOR })
  -- fork prongs in front of the leaf edge, tied with grass twine
  for _, fx in ipairs{ 17 + sw, 38 + sw } do
    local pr = pt{ { fx - 1, 29 }, { fx - 1, 28 }, { fx + 1, 29 }, { fx + 1, 28 }, { fx - 2, 27 }, { fx + 2, 27 } }
    K.c:fillMask(pr, P.wood.base)
    px(fx - 2, 27, P.wood.hi); px(fx + 2, 27, P.wood.hi)
    R(fx - 1, 30, fx + 1, 30, P.gold.hi); px(fx + 1, 30, P.gold.shade)
  end
  -- the ladybird strolls along the top edge, flicks her wings on frame 3
  local lx = ({ 31, 32, 33, 32 })[k] + sw
  ladybird(lx, 7, k == 3)
  -- garden bits: daisies, tufts, a pebble
  K.flower(7, 44, P.cream, P.gold.base)
  K.flower(50, 45, P.cream, P.gold.base)
  K.flower(24, 42, P.petal.hi, P.gold.base)
  K.tuft(3, 51); K.tuft(46, 52); K.tuft(30, 37)
  K.pebble(32, 43)
  return c
end

local frames = {}
for k = 1, 4 do frames[k] = drawEmpty(k) end
K.saveStrip(frames, "ladybird_lodge-empty", "empty")
