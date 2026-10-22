local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local gold = GV.ramp("#dcb06a")
local fin = GV.ramp("#d9a660")
local tail = c:poly({ {41,30}, {57,19}, {52,33}, {57,46}, {41,36} })
local dorsal = c:poly({ {21,24}, {25,15}, {30,19}, {34,16}, {39,24} })
local body = c:ellipse(27, 33, 19, 11)
body:add(c:ellipse(12, 33, 5, 7))
local belly = body:copy():clip(c:ellipse(27, 45, 18, 7))
local p = c:build{
  { "tail", tail, fin },
  { "dorsal", dorsal, fin, { gloss = false } },
  { "body", body, gold, { gloss = { 22, 26 } } },
  { "belly", belly, "cream", { gloss = false, rim = false } },
}
local stripeArea = body:copy():cut(belly)
c:fill(c:rect(28, 24, 29, 38):clip(stripeArea), "#4a2c1a")
c:fill(c:rect(34, 25, 35, 37):clip(stripeArea), "#4a2c1a")
-- gill line
c:fill(c:line({ {21,27}, {22,31}, {21,36} }, 1):clip(stripeArea), "#b8661a")
c:eye(16, 30, true)
-- mouth
c:px(8, 35, "#4a2c1a"); c:px(9, 35, "#4a2c1a")
local t = c:save(O .. "aseprite/ph/perch.aseprite", O .. "png/ph/perch.png")
print(GV.report(t))
