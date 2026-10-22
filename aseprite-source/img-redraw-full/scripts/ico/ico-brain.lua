local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local O = D .. "img-redraw-full/"

local pink = GV.ramp("#d9667f")
-- six round bumps for a scalloped cloud outline
local lobes = c:ellipse(18, 27, 9)
lobes:add(c:ellipse(29, 18, 9))
lobes:add(c:ellipse(41, 19, 9))
lobes:add(c:ellipse(48, 31, 8))
lobes:add(c:ellipse(19, 40, 8))
lobes:add(c:ellipse(32, 41, 9))
lobes:add(c:ellipse(32, 30, 12))
local stem = c:rrect(38, 41, 47, 54, 3)

local p = c:build{
  { "stem",  stem,  GV.ramp("#b8506a") },
  { "brain", lobes, pink, { gloss = false } },
}
-- grooves: dark channel with a lighter 1px lip on the lit (upper-left) side
local function groove(pts)
  c:fill(c:line(pts, 2):shift(-1, -1):clip(p.brain.m), pink.rim)
  c:fill(c:line(pts, 2):clip(p.brain.m), "#a8456a")
end
groove({ {35, 11}, {34, 17}, {36, 23} })
groove({ {12, 31}, {18, 32}, {24, 30}, {27, 34} })
groove({ {24, 13}, {24, 20}, {28, 24} })
groove({ {44, 25}, {41, 30}, {43, 35} })
groove({ {24, 44}, {26, 40}, {31, 38}, {36, 41} })
c:gloss(c:ellipse(18, 25, 6, 5), pink, { 14, 22 })
local t = c:save(O .. "aseprite/ico/ico-brain.aseprite", O .. "png/ico/ico-brain.png")
print(GV.report(t))
