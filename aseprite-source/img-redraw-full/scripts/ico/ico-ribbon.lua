local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local tails = c:line({ {30, 30}, {21, 51} }, 5):add(c:line({ {33, 30}, {42, 47} }, 5))
-- V notches at tail ends
tails:cut(c:poly({ {18, 53}, {22, 48}, {26, 53} })):cut(c:poly({ {39, 49}, {43, 44}, {47, 49} }))
local lw = c:poly({ {7, 9}, {33, 27}, {7, 45} }):shrink(1):grow(1)
local rw = c:poly({ {57, 9}, {31, 27}, {57, 45} }):shrink(1):grow(1)
local wing = GV.ramp("#d9667f")
local red = GV.ramp("#9c2a1e")
c:build{
  { "tails", tails, red },
  { "lwing", lw, wing },
  { "rwing", rw, wing, { gloss = false } },
  { "knot",  c:ellipse(31.5, 27, 7, 7), red },
}
c:fill(c:line({ {11, 18}, {24, 25} }, 2), "#b8456a")
c:fill(c:line({ {52, 18}, {39, 25} }, 2), "#b8456a")
c:button(30, 25)
local t = c:save(O .. "aseprite/ico/ico-ribbon.aseprite", O .. "png/ico/ico-ribbon.png")
print(GV.report(t))
