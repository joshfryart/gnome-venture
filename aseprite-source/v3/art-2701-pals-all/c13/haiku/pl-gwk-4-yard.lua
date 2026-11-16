-- Crown Points (pl-gwk-4), yard 64x64. Haiku first pass.
-- Thornblade, uncommon. A gold crown band with four sharp points and a face.
-- quirk: a petal-pink jewel set in each end of the band.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-gwk-4-yard" }
c:part(c:rrect(9, 34, 55, 50, 4), "gold", {})
for _, p in ipairs({ { {9,36}, {12,12}, {18,36} }, { {18,36}, {26,8}, {34,36} },
                     { {34,36}, {40,10}, {46,36} }, { {46,36}, {52,12}, {55,36} } }) do
  c:part(c:poly(p), "gold", { sep = true })
end
c:part(c:rect(12, 40, 13, 41), "petal", {})
c:part(c:rect(50, 40, 51, 41), "petal", {})
c:eyeLocked(20, 39)
c:eyeLocked(37, 39)
c:paint({ "..iii.." }, 28, 45, { i = "#2b1c26" })
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-gwk-4-yard.aseprite", png = out .. "pl-gwk-4-yard.png" }
