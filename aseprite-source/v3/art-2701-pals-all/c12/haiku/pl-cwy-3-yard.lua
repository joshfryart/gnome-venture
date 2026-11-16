-- Scorch Sliver (pl-cwy-3), yard sprite 64x64. Haiku first pass.
-- Common, rootwarden. "A sharp red sliver that still smells faintly of smoke."
-- A leaning red obsidian shard with a crack down its face and a wisp of smoke off the tip.
-- quirk: the smoke curl.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-cwy-3-yard" }

c:groundShadow(32, 57, 12, 2)
c:part(c:poly({ {34,8},{42,28},{41,44},{37,56},{27,56},{23,44},{22,28},{28,16} }), "ember", { band = 3 })
c:fillMask(c:line({ {31,18},{34,30},{30,42},{33,52} }, 1), "#6e2038")         -- crack down the face
c:part(c:line({ {34,8},{39,4},{36,0} }, 2), "stone", { band = 1, noshade = true, nopop = true })  -- smoke
c:eyeLocked(25, 31)
c:eyeLocked(35, 31)
c:fillMask(c:rect(31, 41, 33, 41), P.ink)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-cwy-3-yard.aseprite", png = out .. "pl-cwy-3-yard.png", scale = 1 }
