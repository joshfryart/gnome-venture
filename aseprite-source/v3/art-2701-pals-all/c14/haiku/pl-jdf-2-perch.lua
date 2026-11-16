-- Reedleg Cling (pl-jdf-2), perch 36x36. Haiku first pass.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-jdf-2-perch" }
c:part(c:rect(2, 0, 4, 35), "moss", {})
c:part(c:rect(31, 0, 33, 35), "moss", {})
for _, y in ipairs({ 13, 18, 23 }) do
  c:fillMask(c:line({{10, y}, {4, y - 1}}, 1), "#3a2420")
  c:fillMask(c:line({{25, y}, {32, y - 1}}, 1), "#3a2420")
end
c:part(c:ellipse(18, 18, 8, 9), "wood", {})
c:eyeSmall(15, 15)
c:eyeSmall(20, 15)
c:px(16, 21, "#2b1c26")
c:px(19, 21, "#2b1c26")
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-jdf-2-perch.aseprite", png = out .. "pl-jdf-2-perch.png" }
