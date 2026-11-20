-- snail_jar EMPTY state, pass 2 (small): a garden snail on the plot carries a little gold-rimmed
-- cream label on a peg stuck in its shell; a tiny jar charm dangles from the label's right end.
local K = dofile("/tmp/ase/states2/signs4_kit.lua")
local out = app.params.out or "./"
K.init(56, 56, "snail_jar", out)
local P, HP = K.P, K.HP
local px, R, E, ink, pt = K.px, K.R, K.E, K.ink, K.pt
local BODY = { hi = "#fff0cf", base = "#f2d6a4", shade = "#d9b07c" }
local FACE = "#fbecc8"
local SLIME, SLIMEHI = "#9fc9c0", P.sky.hi

local function plate(fx, fy)
  -- face 21 x 7 inside a 1 px gold enamel band, ink rim outside: 23 x 9 in all
  local m = K.c:rect(fx, fy, fx + 20, fy + 6)
  ink(m)
  K.c:fillMask(m, FACE)
  m:each(function(x, y)
    if not m:has(x - 1, y) or not m:has(x, y - 1) then px(x, y, P.gold.hi)
    elseif not m:has(x + 1, y) or not m:has(x, y + 1) then px(x, y, P.gold.shade) end
  end)
  K.word(fx + 1, fy + 1, P.ink)
end

local function charm(x, y)   -- tiny glass jar with a wooden lid and a gold snail inside
  px(x + 2, y - 1, P.gold.shade)
  K.c:paint({
    "oLLLo",
    "osSso",
    "osgso",
    "osSso",
    "ooooo" }, x, y, { o = P.ink, L = P.wood.base, s = P.sea.base, S = P.sky.hi, g = P.gold.base })
end

local function snail()
  local foot = K.c:rrect(18, 42, 32, 43, 1)
  local neck = K.c:rrect(18, 39, 21, 43, 1)
  local shell = E(27, 39.5, 3, 2.5)
  ink(foot, neck, shell)
  K.c:fillMask(foot, BODY.base); K.c:fillMask(neck, BODY.base)
  R(19, 43, 32, 43, BODY.shade)
  px(18, 39, BODY.hi); px(19, 39, BODY.hi); px(18, 40, BODY.hi)
  -- eye stalks with ink tips
  px(18, 38, BODY.shade); px(17, 37, P.ink); px(20, 38, BODY.shade); px(21, 37, P.ink)
  px(19, 41, P.ink)                                  -- a tiny smile
  K.ball(shell, 27, 39.5, 3, 2.5, P.gold)
  px(27, 40, P.gold.deep); px(28, 39, P.gold.deep); px(27, 38, P.gold.deep)  -- spiral
end

local function drawEmpty(k)
  local c = K.newc()
  local sw = ({ 0, 1, 1, 0 })[k]
  local m = K.plotMask({ { 16, 40 }, { 40, 40 }, { 41, 47 }, { 15, 47 } }, 11)
  K.plot(m, 11)
  K.corners({ { 18, 42 }, { 38, 42 }, { 39, 46 }, { 17, 46 } }, 3)
  K.shadow(K.c:poly{ { 27, 45 }, { 34, 44 }, { 35, 45 }, { 28, 46 } }, .3)
  -- slime trail behind the snail with a travelling glint (the life detail)
  R(32, 45, 36, 45, SLIME)
  px(({ 32, 33, 34, 35 })[k], 45, P.cream)
  -- peg from the shell up to the label (drawn first, the shell covers its foot)
  local peg = K.c:rect(27, 33, 27, 36)
  ink(peg); K.c:fillMask(peg, P.wood.base)
  snail()
  local fx = 18 + sw
  plate(fx, 26)
  charm(fx + 15 + ({ 0, 0, 0, 1 })[k], 35)
  K.pebble(22, 46)
  K.flower(37, 44, P.dusk.base, P.gold.hi)   -- one violet
  return c
end

local frames = {}
for k = 1, 4 do frames[k] = drawEmpty(k) end
K.saveStrip(frames, "snail_jar-empty", "empty")
