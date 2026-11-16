-- Dewweb Eye (pl-sbs-5), yard 64x64. Haiku first pass.
-- Bloomcaller, uncommon. A round silk web-disc with a dew-ringed hole for a face.
-- quirk: a dew drop about to fall from the lower right.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-sbs-5-yard" }
c:part(c:ellipse(32, 33, 21, 20), "sky", {})
local ring = c:ellipse(32, 33, 15, 14); ring:cut(c:ellipse(32, 33, 13, 12))
c:part(ring, "stone", {})
for _, p in ipairs({ {13,33}, {19,20}, {45,20}, {51,33}, {45,46}, {32,52} }) do
  c:part(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), "sea", {})
end
c:part(c:ellipse(32, 33, 8, 7), "dusk", {})
c:eyeLocked(25, 29)
c:eyeLocked(35, 29)
c:paint({ "..ccc.." }, 28, 37, { c = "#fff4d6" })
c:part(c:rect(57, 44, 58, 47), "sea", {})
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-sbs-5-yard.aseprite", png = out .. "pl-sbs-5-yard.png" }
