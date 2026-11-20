-- snail_jar EMPTY state: a big garden snail beside the plot carries the sign on its shell:
-- a gold-rimmed enamel jar label on two little posts, strapped round the shell.
local K = dofile("/tmp/ase/states2/signs4_kit.lua")
local out = app.params.out or "./"
K.init(56, 56, "snail_jar", out)
local P, HP = K.P, K.HP
local px, R, E, ink, pt = K.px, K.R, K.E, K.ink, K.pt
local BODY = { hi = "#fff0cf", base = "#f2d6a4", shade = "#d9b07c", deep = "#a97c58" }
local FACE, FACESH = "#fbecc8", "#ecd3a2"
local SLIME, SLIMEHI = "#9fc9c0", P.sky.hi

local function snail(k)
  local st = ({ 0, 0, 1, 1 })[k]
  local foot = K.c:rrect(33, 46, 54, 50, 2)
  local neck = K.c:rrect(32, 40, 37, 50, 2)
  local st1 = K.c:line({ { 33, 40 }, { 31 - st, 36 } }, 1)
  local st2 = K.c:line({ { 36, 40 }, { 38 - st, 35 } }, 1)
  local tip1, tip2 = K.c:rect(30 - st, 34, 31 - st, 35), K.c:rect(38 - st, 33, 39 - st, 34)
  local shell = E(45, 41, 6, 6)
  ink(foot, neck, st1, st2, tip1, tip2, shell)
  K.c:fillMask(foot, BODY.base); K.c:fillMask(neck, BODY.base)
  R(34, 50, 53, 50, BODY.deep); R(35, 49, 53, 49, BODY.shade)
  neck:each(function(x, y) if not neck:has(x - 1, y) or not neck:has(x, y - 1) then px(x, y, BODY.hi) end end)
  for x = 40, 52, 3 do px(x, 48, BODY.shade) end
  K.c:fillMask(st1, BODY.shade); K.c:fillMask(st2, BODY.shade)
  K.c:fillMask(tip1, P.ink); K.c:fillMask(tip2, P.ink); px(30 - st, 34, P.cream); px(38 - st, 33, P.cream)
  -- face: smile, cheek
  px(33, 44, P.ink); px(34, 45, P.ink); px(35, 45, P.ink); px(36, 44, P.ink)
  px(37, 43, P.petal.base); px(32, 43, P.petal.base)
  -- shell: glossy amber with one clean spiral groove
  K.ball(shell, 45, 41, 6, 6, P.gold)
  local SP = { { 0, 0 }, { 1, 0 }, { 1, 1 }, { 0, 2 }, { -1, 2 }, { -2, 1 }, { -2, 0 }, { -2, -1 }, { -1, -2 }, { 0, -3 }, { 1, -3 }, { 2, -3 }, { 3, -2 }, { 4, -1 }, { 4, 0 }, { 4, 1 }, { 4, 2 }, { 3, 3 } }
  for i, q in ipairs(SP) do px(45 + q[1], 41 + q[2], P.gold.deep) end
  px(41, 37, P.cream); px(42, 37, P.gold.hi)
  return shell
end

local function plate(x0, y0)
  -- 35 x 13 stadium label, gold enamel rim, cream face; jar icon left, word right
  local x1, y1 = x0 + 34, y0 + 12
  local m = K.c:rrect(x0, y0, x1, y1, 5)
  local thick = m:copy():shift(0, 1):cut(m)
  ink(m, thick)
  K.c:fillMask(thick, P.gold.deep)
  K.c:fillMask(m, P.gold.base)
  local face = m:shrink(1)
  m:edge():each(function(x, y)
    if (not m:has(x - 1, y) or not m:has(x, y - 1)) and (x < x0 + 26 and y < y0 + 9) then px(x, y, P.gold.hi) end
    if (not m:has(x + 1, y) or not m:has(x, y + 1)) and not (x < x0 + 8 and y < y0 + 6) then px(x, y, P.gold.shade) end
  end)
  K.c:fillMask(face, FACE)
  face:each(function(x, y) if not face:has(x, y - 1) then px(x, y, FACESH) end end)   -- the rim's lip shades the face top
  -- brass rivets on the rim
  px(x0 + 1, y0 + 6, P.cream); px(x1 - 1, y0 + 6, P.gold.shade)
  -- icon: a glass jar with a tiny snail inside
  K.c:paint({
    ".LLL.",
    "dlllD",
    "sSSws",
    "sSoSs",
    "sbbbs",
    ".sss." }, x0 + 3, y0 + 3, { L = P.wood.hi, l = P.wood.base, d = P.wood.shade, D = P.wood.deep, s = P.sea.deep, S = P.sea.base, w = P.cream, o = P.gold.base, b = P.wood.shade })
  K.word(x0 + 11, y0 + 4, P.ink)
end

local function drawEmpty(k)
  local c = K.newc()
  local dy = ({ 0, 0, 1, 1 })[k]
  local m = K.plotMask({ { 8, 34 }, { 37, 34 }, { 39, 50 }, { 4, 50 } }, 11)
  K.plot(m, 11)
  K.corners({ { 12, 38 }, { 33, 38 }, { 30, 47 }, { 9, 47 } }, 5)
  -- cast shadow of snail and sign, lower right
  K.shadow(K.c:poly{ { 35, 51 }, { 55, 51 }, { 55, 53 }, { 37, 53 } }, .38)
  -- slime trail behind the snail with a travelling glint
  R(50, 52, 55, 52, SLIME)
  local gx = ({ 50, 52, 54, 52 })[k]; px(gx, 52, SLIMEHI)
  -- posts strapped to the shell, then the snail, then the label on top
  local pl, pr = K.c:rect(41, 25 + dy, 41, 36), K.c:rect(48, 25 + dy, 48, 36)
  ink(pl, pr); K.c:fillMask(pl, P.wood.base); K.c:fillMask(pr, P.wood.shade)
  snail(k)
  -- leather strap round the shell holding the posts, with a buckle
  for x = 40, 49 do px(x, 36, P.wood.shade) end
  R(41, 35, 41, 36, P.wood.base); R(48, 35, 48, 36, P.wood.shade)
  px(40, 36, P.ember.deep); px(49, 36, P.ember.deep); px(44, 36, P.gold.hi); px(45, 36, P.gold.shade)
  plate(20, 12 + dy)
  -- garden bits: violets, tufts, pebbles
  K.flower(3, 41, P.dusk.base, P.gold.hi)
  K.flower(26, 51, P.dusk.hi, P.gold.base)
  K.tuft(1, 51); K.tuft(16, 53); K.tuft(24, 35)
  K.pebble(22, 42); K.pebble(13, 43)
  -- a leaf drifts past on the left
  local L = { { 4, 22 }, { 7, 25 }, { 10, 24 }, { 13, 27 } }
  local lm = pt{ { L[k][1], L[k][2] }, { L[k][1] + 1, L[k][2] }, { L[k][1] + 1, L[k][2] + 1 }, { L[k][1] + 2, L[k][2] + 1 } }
  ink(lm); K.c:fillMask(lm, P.moss.base); px(L[k][1], L[k][2], P.moss.hi)
  return c
end

local frames = {}
for k = 1, 4 do frames[k] = drawEmpty(k) end
K.saveStrip(frames, "snail_jar-empty", "empty")
