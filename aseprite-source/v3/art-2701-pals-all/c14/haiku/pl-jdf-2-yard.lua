-- Reedleg Cling (pl-jdf-2), yard 64x64. Haiku first pass.
-- Seedkeeper, common. Holds onto the reeds with six tiny legs and will not let go.
-- quirk: three legs gripping each reed, with cream toe pads.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-jdf-2-yard" }
c:part(c:rect(7, 0, 10, 63), "moss", {})
c:part(c:rect(53, 0, 56, 63), "moss", {})
for _, y in ipairs({ 24, 32, 40 }) do
  c:fillMask(c:line({{21, y}, {10, y - 3}}, 1), "#3a2420")
  c:fillMask(c:line({{43, y}, {53, y - 3}}, 1), "#3a2420")
  c:px(9, y - 3, "#fff4d6")
  c:px(54, y - 3, "#fff4d6")
end
c:part(c:ellipse(32, 30, 12, 14), "wood", {})
c:eyeLocked(26, 22)
c:eyeLocked(35, 22)
c:paint({ "i..i", ".ii." }, 29, 31, { i = "#2b1c26" })
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-jdf-2-yard.aseprite", png = out .. "pl-jdf-2-yard.png" }
