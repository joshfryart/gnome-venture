-- Eightlegs Clasp (pl-sbs-4), yard sprite 64x64. Haiku first pass.
-- Uncommon, thornblade. "Eight spider legs that hold on tight and wiggle."
-- A purple spider body with eight legs gripping a twig along the bottom, one knee raised.
-- quirk: the raised, wiggling leg.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-sbs-4-yard" }

c:part(c:line({ {0,57},{63,55} }, 2), "wood", { band = 1, noshade = true, nopop = true })   -- twig
local legs = {
  { {22,24},{10,22},{4,50} },
  { {22,30},{10,30},{10,55} },   -- raised knee, wiggling
  { {23,36},{12,42},{16,56} },
  { {24,41},{16,46},{24,56} },
}
for _, l in ipairs(legs) do
  c:part(c:line(l, 2), "dusk", { band = 1, noshade = true, nopop = true })
  local m = c:line({ {64 - l[1][1], l[1][2]}, {64 - l[2][1], l[2][2]}, {64 - l[3][1], l[3][2]} }, 2)
  c:part(m, "dusk", { band = 1, noshade = true, nopop = true })
end
c:groundShadow(32, 58, 12, 2)
c:part(c:ellipse(32, 32, 11, 10), "dusk", { band = 3 })
c:part(c:ellipse(32, 44, 8, 7), "dusk", { band = 2, sep = true })             -- abdomen
c:eyeLocked(27, 30)
c:eyeLocked(35, 30)
c:fillMask(c:rect(30, 37, 33, 37), P.ink)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-sbs-4-yard.aseprite", png = out .. "pl-sbs-4-yard.png", scale = 1 }
