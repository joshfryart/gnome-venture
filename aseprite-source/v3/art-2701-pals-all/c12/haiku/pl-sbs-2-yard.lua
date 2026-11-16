-- Web Snag (pl-sbs-2), yard sprite 64x64. Haiku first pass.
-- Common, wayfinder. "A loose thread of web that snags hats, then hands them back."
-- A round sheet of web with spokes, a hat caught on one edge, a loose thread hanging off the other.
-- quirk: the hat snagged on the web.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-sbs-2-yard" }

c:groundShadow(30, 58, 13, 2)
c:part(c:ellipse(30, 30, 17, 16), "sky", { band = 2 })
for _, p in ipairs({ {14,20},{14,36},{30,46},{46,40},{46,20},{30,14} }) do
  c:fillMask(c:line({ {30,30}, p }, 1), P.sky.shade)                       -- web spokes
end
c:fillMask(c:line({ {46,28},{47,37} }, 1), P.sky.deep)                       -- thread to the hat
c:fillMask(c:line({ {14,44},{11,52},{14,58} }, 1), P.sky.base)               -- loose thread
c:part(c:rrect(41, 35, 53, 44, 3), "dusk", { band = 2 })                     -- the snagged hat
c:part(c:rect(38, 43, 57, 46), "dusk", { band = 1, noshade = true })         -- its brim
c:eyeLocked(24, 27)
c:eyeLocked(34, 27)
c:fillMask(c:rect(28, 35, 31, 35), P.ink)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-sbs-2-yard.aseprite", png = out .. "pl-sbs-2-yard.png", scale = 1 }
