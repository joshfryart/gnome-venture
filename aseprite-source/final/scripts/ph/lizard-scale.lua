local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- pointed-top hexagon shield, longer point at the bottom
local outer = c:poly({ { 32, 10 }, { 51, 20 }, { 51, 40 }, { 32, 55 }, { 13, 40 }, { 13, 20 } })
local inner = c:poly({ { 32, 17 }, { 44, 24 }, { 44, 37 }, { 32, 47 }, { 20, 37 }, { 20, 24 } })
local ridge = c:line({ { 31, 12 }, { 31, 51 } }, 2)

local dusk = GV.ramp("#7b66b4", { gloss = "#d2c4f2", dot = "#efe6ff", rim = "#a894dc" })
local p = c:build{
  { "scale", outer, dusk, { gloss = { 18, 21 } } },
  { "plate", inner, GV.ramp("#3e2f66", { rim = "#5a4a8c", shade = "#291d4a", deep = "#1e1538" }), { gloss = false, cres = 2, deep = 1 } },
}
c:fill(ridge, "#291d4a")
-- ridge highlight on its lit side
for y = 13, 50 do c:px(30, y, "#5a4a8c") end
-- facet lines from inner plate corners to outer corners (1 px, darker dusk)
c:fill(c:line({ { 20, 24 }, { 15, 21 } }, 1), "#5a4a8c")
c:fill(c:line({ { 44, 24 }, { 49, 21 } }, 1), "#5a4a8c")
c:fill(c:line({ { 20, 37 }, { 15, 40 } }, 1), "#5a4a8c")
c:fill(c:line({ { 44, 37 }, { 49, 40 } }, 1), "#5a4a8c")
-- tiny zigzag marks on the plate
c:paint({ "z...z...", ".z.z.z.z", "..z...z." }, 21, 28, { z = "#a894dc" })
c:paint({ "z...z..", ".z.z.z.", "..z...z" }, 34, 33, { z = "#a894dc" })
local t = c:save(D .. "img-redraw-full/aseprite/ph/lizard-scale.aseprite", D .. "img-redraw-full/png/ph/lizard-scale.png")
print(GV.report(t))
