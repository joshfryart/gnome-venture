-- mini-paper-wasp (75x56 still, side view, faces right). Haiku first pass.
-- Slim waisted wasp: banded abdomen, slim jointed legs (the fix), two clear glassy wings, one antenna curl (quirk).
local NAME = "mini-paper-wasp"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")

local c = HP.canvas{ w = 75, h = 56, scale = 1, name = NAME }
c:groundShadow(36, 52, 22, 2)
-- wings (behind)
c:part(c:poly{ { 30, 20 }, { 22, 4 }, { 40, 8 }, { 42, 18 } }, "sky", { band = 1, nopop = true })
c:part(c:poly{ { 38, 20 }, { 44, 2 }, { 56, 6 }, { 50, 18 } }, "sky", { band = 1, nopop = true })
-- legs: long, thin, bent at the knee (three per side, drawn 1 px)
local leg = P.dusk.deep
for _, l in ipairs{ { { 40, 32 }, { 36, 40 }, { 30, 47 } }, { { 46, 33 }, { 46, 42 }, { 42, 50 } }, { { 51, 32 }, { 56, 41 }, { 54, 50 } } } do
  c:fillMask(c:line({ l[1], l[2] }, 1), leg) c:fillMask(c:line({ l[2], l[3] }, 1), leg)
end
-- slim waist then the banded abdomen (points left)
c:part(c:line({ { 26, 30 }, { 34, 30 } }, 3), "gold", { band = 1, nopop = true })
local ab = c:ellipse(20, 27, 13, 8)
c:part(ab, "gold", { band = 2, pop = { x = 13, y = 21 } })
for _, x in ipairs{ 14, 19, 24 } do c:fillMask(c:line({ { x, 19 }, { x - 1, 35 } }, 1):clip(ab), P.dusk.deep) end
c:fillMask(c:line({ { 12, 27 }, { 29, 27 } }, 1):clip(ab), P.gold.deep)
-- thorax and head
c:part(c:ellipse(40, 26, 7, 6), "gold", { band = 2, pop = { x = 37, y = 21 } })
c:part(c:ellipse(51, 24, 5, 5), "gold", { band = 1, pop = { x = 49, y = 20 } })
c:fillMask(c:line({ { 37, 21 }, { 43, 21 } }, 1), P.dusk.deep)
-- stinger
c:fillMask(c:line({ { 8, 30 }, { 3, 33 } }, 1), P.dusk.deep)
-- antennae: one straight, one curled (quirk)
c:fillMask(c:line({ { 53, 19 }, { 58, 9 } }, 1), P.dusk.deep)
c:fillMask(c:line({ { 55, 21 }, { 62, 18 }, { 64, 14 }, { 61, 13 } }, 1), P.ember.base)
c:eyeSmall(56, 23)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
