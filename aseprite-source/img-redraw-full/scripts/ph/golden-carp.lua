local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- plump body, head on the left, tapering to the tail root
local body = c:ellipse(25, 32, 16, 10)
body:add(c:poly({ {30, 25}, {44, 29}, {44, 36}, {30, 41} }))
-- forked fan tail
local tail = c:poly({ {41, 30}, {54, 20}, {57, 22}, {51, 32}, {57, 43}, {54, 45}, {41, 35} })
-- dorsal fin bump
local fin = c:poly({ {21, 24}, {27, 17}, {36, 20}, {37, 26} })

local p = c:build{
  { "tail", tail, "gold", { gloss = false } },
  { "fin",  fin, GV.ramp("#b8661a"), { flat = true } },
  { "body", body, "gold", { gloss = { 16, 25 } } },
}
-- cream belly crescent
local belly = c:ellipse(25, 32, 15, 9):clip(c:poly({ {9, 35}, {42, 33}, {42, 43}, {9, 43} }))
belly:cut(c:ellipse(26, 30, 15, 9))
c:fill(belly, "#f4f0e0")
-- gill stripes
c:fill(c:rect(27, 26, 28, 37), "#b07a10")
c:fill(c:rect(32, 27, 33, 36), "#b07a10")
-- tiny mouth
c:px(10, 34, "#7a3a14")
-- locked small eye
c:eye(15, 28, true)

local t = c:save(O .. "aseprite/ph/golden-carp.aseprite", O .. "png/ph/golden-carp.png")
print(GV.report(t))
