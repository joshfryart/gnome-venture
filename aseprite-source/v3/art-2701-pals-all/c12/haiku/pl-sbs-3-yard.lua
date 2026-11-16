-- Buttress Tangle (pl-sbs-3), yard sprite 64x64. Haiku first pass.
-- Common, rootwarden. "A knot of silk tucked in the buttress roots, guarding a good hiding spot."
-- A golden silk knot sitting between two buttress roots, with a dark hollow under it.
-- quirk: the hollow behind the knot, guarded by a strand across it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-sbs-3-yard" }

c:groundShadow(32, 58, 22, 2)
c:part(c:poly({ {4,58},{10,40},{22,46},{24,58} }), "wood", { band = 2 })     -- left buttress root
c:part(c:poly({ {60,58},{54,40},{42,46},{40,58} }), "wood", { band = 2 })    -- right buttress root
c:fillMask(c:ellipse(32, 55, 8, 5), P.wood.deep)                              -- the hiding spot
c:part(c:ellipse(32, 30, 16, 14), "gold", { band = 3 })                      -- silk knot
c:fillMask(c:line({ {18,36},{28,44},{44,36} }, 1), P.gold.deep)              -- tangled threads
c:fillMask(c:line({ {20,24},{32,38},{46,24} }, 1), P.gold.shade)
c:fillMask(c:line({ {24,47},{30,52} }, 1), P.gold.deep)                       -- guard strand over the hollow
c:eyeLocked(24, 27)
c:eyeLocked(35, 27)
c:fillMask(c:rect(29, 35, 33, 35), P.ink)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-sbs-3-yard.aseprite", png = out .. "pl-sbs-3-yard.png", scale = 1 }
