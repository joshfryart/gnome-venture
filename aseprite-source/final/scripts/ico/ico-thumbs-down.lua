local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-hybrid/"
local GV = dofile(D .. "gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local fist = c:rrect(14, 17, 50, 37, 6)
local whole = fist:copy():add(c:rrect(17, 30, 26, 51, 5))
c:build{
  { "b1", c:ellipse(20.5, 17, 4.5), "skin", { gloss = false, light = whole } },
  { "b2", c:ellipse(28.5, 15.5, 4.5), "skin", { gloss = false, light = whole } },
  { "b3", c:ellipse(36.5, 15.5, 4.5), "skin", { gloss = false, light = whole } },
  { "b4", c:ellipse(44, 17, 4.5), "skin", { gloss = false, light = whole } },
  { "fist", fist, "skin", { light = whole } },
  { "thumb", c:rrect(17, 30, 26, 51, 5), "skin", { light = whole } },
}
c:fill(c:line({ {40, 24}, {44, 23}, {48, 24} }, 2), "#c47a52")
c:fill(c:line({ {40, 30}, {44, 29}, {48, 30} }, 2), "#c47a52")
local t = c:save(O .. "aseprite/ico/ico-thumbs-down.aseprite", O .. "png/ico/ico-thumbs-down.png")
print(GV.report(t))
