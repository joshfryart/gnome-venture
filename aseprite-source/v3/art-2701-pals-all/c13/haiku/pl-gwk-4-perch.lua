-- Crown Points (pl-gwk-4), perch 36x36. Haiku first pass.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-gwk-4-perch" }
c:part(c:rrect(5, 20, 31, 28, 2), "gold", {})
for _, p in ipairs({ { {5,21}, {8,6}, {11,21} }, { {11,21}, {15,3}, {19,21} },
                     { {19,21}, {22,4}, {26,21} }, { {26,21}, {29,6}, {31,21} } }) do
  c:part(c:poly(p), "gold", { sep = true })
end
c:part(c:rect(17, 24, 18, 25), "petal", {})
c:eyeSmall(10, 22)
c:eyeSmall(23, 22)
c:paint({ "ii" }, 15, 26, { i = "#2b1c26" })
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-gwk-4-perch.aseprite", png = out .. "pl-gwk-4-perch.png" }
