-- ladybird_lodge EMPTY state, pass 2 (small): a little leaf plate held up by a forked twig,
-- a tiny red bug-hotel glyph perched on its left end and a ladybird strolling on its right end.
local K = dofile("/tmp/ase/states2/signs4_kit.lua")
local out = app.params.out or "./"
K.init(56, 56, "ladybird_lodge", out)
local P, HP = K.P, K.HP
local px, R, E, ink, pt = K.px, K.R, K.E, K.ink, K.pt
local LEAF = { hi = P.moss.base, base = P.moss.shade, deep = P.moss.deep, under = "#1d4140" }

local function leaf(fx, fy)
  -- face 21 x 7 with clipped corners and a pointed tip on the right (ink rim makes 24 x 9)
  local m = K.c:rect(fx, fy, fx + 20, fy + 6)
  for _, q in ipairs{ { fx, fy }, { fx, fy + 6 }, { fx + 20, fy }, { fx + 20, fy + 6 } } do m.s[(q[2] + 256) * 1024 + (q[1] + 256)] = nil end
  m:set(fx + 21, fy + 3)
  ink(m)
  K.c:fillMask(m, LEAF.base)
  m:each(function(x, y)
    if not m:has(x - 1, y) or not m:has(x, y - 1) then px(x, y, LEAF.hi)
    elseif not m:has(x + 1, y) or not m:has(x, y + 1) then px(x, y, LEAF.deep) end
  end)
  K.word(fx + 1, fy + 1, P.cream)
end

local function hotel(x, y)   -- 5 x 6 glyph, bottom row = the leaf's ink rim
  K.c:paint({
    "..o..",
    ".ogo.",
    "ogggo",
    "orrro",
    "orkro",
    "ooooo" }, x, y, { o = P.ink, g = P.stone.base, r = P.ember.base, k = "#3b2c48" })
end

local function ladybird(x, y, flick)   -- 5 x 3 above the rim, head on the left
  K.c:paint({
    ".ooo.",
    "ohrko",
    "okrro" }, x, y, { o = P.ink, h = P.ember.hi, r = P.ember.base, k = P.ink })
  if flick then px(x + 3, y - 1, P.sky.hi); px(x + 4, y - 1, P.ink) end
end

local function drawEmpty(k)
  local c = K.newc()
  local sw = ({ 0, 1, 1, 0 })[k]
  local m = K.plotMask({ { 16, 40 }, { 40, 40 }, { 41, 47 }, { 15, 47 } }, 7)
  K.plot(m, 7)
  K.corners({ { 18, 42 }, { 38, 42 }, { 39, 46 }, { 17, 46 } }, 3)
  K.shadow(K.c:poly{ { 29, 44 }, { 36, 43 }, { 37, 44 }, { 30, 45 } }, .3)
  -- forked twig stuck in the plot, top follows the sway
  local tw = K.c:line({ { 28, 43 }, { 28 + sw, 40 } }, 1)
  tw:add(pt{ { 27 + sw, 39 }, { 26 + sw, 38 }, { 29 + sw, 39 }, { 30 + sw, 38 } })
  ink(tw); K.c:fillMask(tw, P.wood.base); px(26 + sw, 38, P.wood.hi); px(28, 43, P.wood.shade); px(28, 42, P.wood.shade)
  local fx, fy = 18 + sw, 30
  leaf(fx, fy)
  hotel(fx + 1, fy - 6)
  local lx = fx + ({ 13, 14, 14, 13 })[k]
  ladybird(lx, fy - 4, k == 3)
  K.tuft(19, 47)
  K.pebble(32, 41)
  K.flower(36, 44, P.cream, P.gold.base)   -- one daisy
  return c
end

local frames = {}
for k = 1, 4 do frames[k] = drawEmpty(k) end
K.saveStrip(frames, "ladybird_lodge-empty", "empty")
