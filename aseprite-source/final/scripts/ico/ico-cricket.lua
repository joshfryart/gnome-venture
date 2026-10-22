local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local R = GV.R

-- legs (behind)
c:limb({ {16, 41}, {11, 46}, {8, 51} }, 3)
c:limb({ {22, 43}, {19, 47}, {18, 52} }, 3)
c:limb({ {35, 43}, {39, 47}, {40, 52} }, 3)
c:limb({ {41, 41}, {46, 45}, {49, 50} }, 3)
-- antennae
local ant = c:line({ {48, 24}, {51, 19}, {55, 15}, {57, 13} }, 2):add(c:line({ {46, 23}, {45, 18}, {46, 13} }, 2))
ant:add(c:rect(56, 11, 58, 13)):add(c:rect(45, 10, 47, 12))

c:build{
  { "ant",  ant, "#4a2c1a", { flat = true, contour = false } },
  { "body", c:ellipse(28, 34.5, 16, 10.5), GV.ramp("#a8582f", { shade = "#8a4f2a" }) },
  { "wing", c:ellipse(27, 31.5, 11, 5.5), "wood", { contact = false } },
  { "head", c:ellipse(47.5, 30, 6.5, 6.5), GV.ramp("#8a4f2a"), { gloss = { 45, 26 } } },
}
-- wing veins
c:paint({ "u...", ".u..", "..u." }, 22, 31, { u = R.wood.deep })
c:paint({ "u...", ".u..", "..u." }, 29, 31, { u = R.wood.deep })
c:eye(48, 27, true)

local t = c:save(O .. "aseprite/ico/ico-cricket.aseprite", O .. "png/ico/ico-cricket.png")
print(GV.report(t))
