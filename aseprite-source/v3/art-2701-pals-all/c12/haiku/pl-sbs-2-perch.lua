-- Web Snag (pl-sbs-2), perch sprite 36x36. Haiku first pass, hand-drawn at this size.
-- quirk: the small hat snagged on the web.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-sbs-2-perch" }

c:part(c:ellipse(15, 17, 10, 9), "sky", { band = 2 })
for _, p in ipairs({ {6,12},{6,22},{15,27},{24,23},{24,12},{15,8} }) do
  c:fillMask(c:line({ {15,17}, p }, 1), P.sky.shade)
end
c:fillMask(c:line({ {24,14},{25,21} }, 1), P.sky.deep)
c:part(c:rrect(23, 20, 31, 26, 2), "dusk", { band = 1 })
c:part(c:rect(21, 25, 33, 27), "dusk", { band = 1, noshade = true, nopop = true })
c:eyeSmall(12, 15)
c:eyeSmall(17, 15)
c:fillMask(c:rect(14, 20, 15, 20), P.ink)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-sbs-2-perch.aseprite", png = out .. "pl-sbs-2-perch.png", scale = 1 }
