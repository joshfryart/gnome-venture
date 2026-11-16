-- mini-blight-mother (101x81 still, side view, faces right). Haiku first pass.
-- Bloated violet brood-body cracked open with ember light, sky-glass wings, a sickly moss bud on the back (quirk).
local NAME = "mini-blight-mother"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")

local c = HP.canvas{ w = 101, h = 81, scale = 1, name = NAME }
c:groundShadow(50, 76, 36, 3)
-- wings: two glassy fans behind the body
c:part(c:poly{ { 40, 42 }, { 30, 12 }, { 22, 6 }, { 36, 24 }, { 44, 36 } }, "sky", { band = 1, nopop = true })
c:part(c:poly{ { 58, 38 }, { 64, 8 }, { 74, 4 }, { 68, 26 }, { 64, 40 } }, "sky", { band = 1, nopop = true })
-- legs: three jointed pairs, dark dusk
for _, l in ipairs{ { { 30, 60 }, { 22, 68 }, { 16, 74 } }, { { 42, 62 }, { 40, 71 }, { 46, 76 } },
                    { { 56, 58 }, { 62, 68 }, { 58, 75 } }, { { 66, 56 }, { 74, 64 }, { 78, 72 } } } do
  c:part(c:line(l, 2), "dusk", { band = 1, nopop = true })
end
-- bloated abdomen, thorax, head
c:part(c:ellipse(38, 50, 24, 16), "dusk", { band = 3, pop = { x = 26, y = 40 } })
c:part(c:ellipse(68, 46, 11, 10), "dusk", { band = 2, pop = { x = 62, y = 40 } })
c:part(c:ellipse(84, 49, 8, 8), "dusk", { band = 2, pop = { x = 80, y = 44 } })
-- back spikes
c:part(c:poly{ { 24, 38 }, { 28, 26 }, { 33, 38 } }, "stone", { band = 1, nopop = true })
c:part(c:poly{ { 36, 35 }, { 41, 22 }, { 47, 35 } }, "stone", { band = 1, nopop = true })
c:part(c:poly{ { 50, 36 }, { 56, 27 }, { 58, 40 } }, "stone", { band = 1, nopop = true })
-- ember cracks across the abdomen (the blight light)
c:fillMask(c:line({ { 22, 48 }, { 29, 54 }, { 27, 60 }, { 34, 65 } }, 1), P.ember.hi)
c:fillMask(c:line({ { 44, 40 }, { 49, 46 }, { 46, 52 } }, 1), P.ember.base)
c:put(29, 54, P.ember.hi)
-- sickly bud on the back (quirk)
c:part(c:line({ { 47, 26 }, { 48, 19 } }, 1), "moss", { band = 1, nopop = true })
c:part(c:ellipse(48, 17, 3, 2.5), "moss", { band = 1, pop = { x = 46, y = 16 } })
-- the one eye and a mouth-slit
c:eyeSmall(87, 46)
c:fillMask(c:line({ { 86, 53 }, { 91, 53 } }, 1), P.ember.deep)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
