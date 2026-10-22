local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local R = GV.R

local head = c:ellipse(32, 33, 18, 17)
c:build{
  { "earL", c:poly({ {22, 21}, {8, 10}, {10, 16}, {17, 40} }), GV.ramp("#a4b86a"), { gloss = false } },
  { "earR", c:poly({ {43, 21}, {57, 10}, {55, 16}, {48, 40} }), "moss", { gloss = false } },
  { "head", head, "moss", { gloss = { 20, 19 } } },
  { "mouth", c:rrect(23, 41, 41, 47, 2), "dusk", { gloss = false, rim = false, contact = false } },
  { "fangL", c:poly({ {26, 41}, {31, 41}, {28.5, 46} }), "cream", { flat = true, contour = "#4a2c1a" } },
  { "fangR", c:poly({ {34, 41}, {39, 41}, {36.5, 46} }), "cream", { flat = true, contour = "#4a2c1a" } },
}
c:eye(22, 26); c:eye(38, 26)
-- brow ridges for mischief
c:paint({ "uu....", "..uuu." }, 20, 23, { u = R.moss.deep })
c:paint({ "....uu", ".uuu.." }, 38, 23, { u = R.moss.deep })

local t = c:save(O .. "aseprite/ico/ico-goblin.aseprite", O .. "png/ico/ico-goblin.png")
print(GV.report(t))
