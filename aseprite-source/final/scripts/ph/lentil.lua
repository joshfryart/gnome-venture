local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pod = c:poly({ {9, 43}, {12, 35}, {19, 27}, {28, 21}, {38, 16}, {47, 13}, {53, 13}, {57, 16},
  {55, 22}, {49, 29}, {41, 36}, {31, 42}, {21, 46}, {13, 47} })
c:part(c:line({ {11, 43}, {6, 48} }, 3), GV.ramp("#2e5a2c"), { flat = true })
local p = c:part(pod, GV.ramp("#f08a24"), { gloss = { 22, 28 } })
c:fill(c:line({ {15, 40}, {26, 33}, {38, 27}, {51, 21} }, 2), "#8a4f2a")
local sr = GV.ramp("#8c4a1a", { rim = "#b07a45" })
for _, s in ipairs({ { 23, 34 }, { 33, 29 }, { 43, 24 } }) do
  c:part(c:ellipse(s[1], s[2], 3.5, 3.5), sr)
end
c:ground(31, 50, 18, 1.5)
local t = c:save(O .. "aseprite/ph/lentil.aseprite", O .. "png/ph/lentil.png")
print(GV.report(t))
