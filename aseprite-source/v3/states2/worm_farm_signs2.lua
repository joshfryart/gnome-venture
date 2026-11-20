-- worm_farm EMPTY state, pass 2 (small): a smiling pink worm peeks out of a hole in a small
-- cleared plot and holds up a little birch-bark BUILD plate; a tiny worm-crate glyph perches on the plate.
local K = dofile("/tmp/ase/states2/signs4_kit.lua")
local out = app.params.out or "./"
K.init(56, 56, "worm_farm", out)
local P, HP = K.P, K.HP
local px, R, E, ink, pt = K.px, K.R, K.E, K.ink, K.pt

local BARK = { hi = "#fbefd4", base = "#efdcb8", shade = "#d6bd94" }
local PINK = P.petal
local HOLE = "#3a2430"

local function plate(fx, fy)
  -- face 21 x 7 (ink rim makes 23 x 9); word with a 2 px margin
  local face = K.c:rect(fx, fy, fx + 20, fy + 6)
  ink(face)
  K.c:fillMask(face, BARK.base)
  R(fx, fy, fx + 20, fy, BARK.hi); R(fx, fy, fx, fy + 6, BARK.hi)
  R(fx, fy + 6, fx + 20, fy + 6, BARK.shade); R(fx + 20, fy, fx + 20, fy + 6, BARK.shade)
  K.word(fx + 1, fy + 1, P.ink)
end

local function charm(x, y)
  -- tiny teal worm crate hanging on a thread under the left end of the plate
  px(x + 2, y - 1, P.cream)
  K.c:paint({
    "oopoo",
    "ohhho",
    "obvbo",
    "ossso",
    "ooooo" }, x, y, { p = PINK.hi, o = P.ink, h = P.sea.hi, b = P.sea.base, s = P.sea.shade, v = "#3b2c48" })
end

local function worm(hx)
  -- head 5 x 5 (rows 35..39) on a short neck that disappears into the hole
  local head = K.c:rrect(hx, 35, hx + 4, 39, 2)
  local neck = K.c:rect(hx + 1, 40, hx + 3, 42)
  ink(head, neck)
  K.c:fillMask(head, PINK.base); K.c:fillMask(neck, PINK.base)
  head:each(function(x, y)
    if not head:has(x - 1, y) or not head:has(x, y - 1) then px(x, y, PINK.hi) end
    if not head:has(x + 1, y) then px(x, y, PINK.shade) end
  end)
  px(hx + 3, 41, PINK.shade); px(hx + 3, 42, PINK.shade); px(hx + 1, 41, PINK.hi)
  px(hx + 1, 36, P.ink); px(hx + 3, 36, P.ink)                       -- eyes
  px(hx + 1, 38, P.ink); px(hx + 2, 38, P.ink); px(hx + 3, 38, P.ink) -- smile
end

local function drawEmpty(k)
  local c = K.newc()
  local sw = ({ 0, 1, 1, 0 })[k]
  local m = K.plotMask({ { 15, 39 }, { 41, 39 }, { 42, 47 }, { 14, 47 } }, 3)
  K.plot(m, 3)
  K.corners({ { 17, 41 }, { 39, 41 }, { 40, 46 }, { 16, 46 } }, 3)
  -- the hole
  K.c:fillMask(E(28, 43, 3, 1), HOLE)
  K.shadow(K.c:poly{ { 32, 44 }, { 36, 43 }, { 37, 44 }, { 33, 45 } }, .3)
  worm(26 + sw)
  R(26, 44, 30, 44, HOLE); R(26, 45, 30, 45, K.EHI)   -- front lip of the hole in front of the neck
  plate(18 + sw, 26)
  charm(19 + ({ 0, 0, 1, 1 })[k], 35)
  K.pebble(33, 41)
  K.flower(37, 44, P.gold.base, P.gold.deep)   -- one dandelion
  -- life detail: a soil crumb flicked out of the hole
  local C = { nil, { 32, 39 }, { 34, 37 }, { 36, 38 } }
  if C[k] then px(C[k][1], C[k][2], HOLE); px(C[k][1] + 1, C[k][2], HOLE) end
  return c
end

local frames = {}
for k = 1, 4 do frames[k] = drawEmpty(k) end
K.saveStrip(frames, "worm_farm-empty", "empty")
