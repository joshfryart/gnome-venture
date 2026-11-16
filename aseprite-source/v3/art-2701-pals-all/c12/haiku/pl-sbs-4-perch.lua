-- Eightlegs Clasp (pl-sbs-4), perch sprite 36x36. Haiku first pass, hand-drawn at this size.
-- quirk: the raised, wiggling leg.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-sbs-4-perch" }

c:part(c:line({ {0,31},{35,30} }, 1), "wood", { band = 1, noshade = true, nopop = true })   -- twig
local legs = {
  { {11,12},{5,11},{2,25} },
  { {11,15},{5,14},{4,29} },   -- raised knee, wiggling
  { {11,19},{6,22},{8,31} },
  { {12,22},{8,25},{12,31} },
}
for _, l in ipairs(legs) do
  c:part(c:line(l, 1), "dusk", { band = 1, noshade = true, nopop = true })
  c:part(c:line({ {35 - l[1][1], l[1][2]}, {35 - l[2][1], l[2][2]}, {35 - l[3][1], l[3][2]} }, 1), "dusk", { band = 1, noshade = true, nopop = true })
end
c:groundShadow(18, 33, 7, 1)
c:part(c:ellipse(18, 14, 7, 6), "dusk", { band = 2 })
c:part(c:ellipse(18, 22, 5, 4), "dusk", { band = 1, sep = true })   -- abdomen
c:eyeSmall(15, 13)
c:eyeSmall(19, 13)
c:fillMask(c:rect(17, 19, 18, 19), P.ink)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-sbs-4-perch.aseprite", png = out .. "pl-sbs-4-perch.png", scale = 1 }
