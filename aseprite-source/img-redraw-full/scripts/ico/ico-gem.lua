local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local water = GV.ramp("#3f93b2", { gloss = "#c8ecdc", shade = "#2f6290", deep = "#2a3c6c" })
local crownR = GV.ramp("#8fd0e4", { gloss = "#e4f8f0" })
local gem = c:poly({ {20, 13}, {44, 13}, {55, 26}, {32, 55}, {9, 26} })
local crown = c:poly({ {20, 13}, {44, 13}, {53, 25}, {11, 25} })
c:build{
  { "gem", gem, water, { gloss = false } },
  { "crown", crown, crownR, { light = gem, gloss = { 18, 16 } } },
}
-- pavilion facets
c:fill(c:line({ {22, 26}, {31, 52} }, 2):clip(gem), "#2f6290")
c:fill(c:line({ {41, 26}, {32, 52} }, 2):clip(gem), "#2f6290")
c:fill(c:line({ {31, 26}, {31, 52} }, 2):clip(gem), "#2a3c6c")
-- crown facets
c:fill(c:line({ {25, 14}, {22, 24} }, 1), "#3f93b2")
c:fill(c:line({ {38, 14}, {41, 24} }, 1), "#3f93b2")
c:fill(c:line({ {31, 14}, {31, 24} }, 1), "#5aaecb")
-- glint on lit pavilion facet
c:fill(c:rect(15, 29, 16, 31), "#8fd0e4")
local t = c:save(O .. "aseprite/ico/ico-gem.aseprite", O .. "png/ico/ico-gem.png")
print(GV.report(t))
