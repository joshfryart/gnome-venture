local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cream = GV.ramp("#f8eed2")

local stem = c:poly({ {25, 33}, {38, 33}, {41, 47}, {37, 51}, {26, 51}, {22, 47} })
local cap = c:ellipse(31.5, 35, 20, 24):cut(c:rect(0, 35, 63, 63))
cap:add(c:rrect(12, 30, 51, 35, 3))
local p = c:build{
  { "stem", stem, cream, { gloss = { 26, 39 } } },
  { "cap", cap, "red" },
}
-- gill shadow line under the cap
c:fill(c:rect(15, 34, 48, 35), GV.R.red.shade)
-- three big cream spots
local spots = c:ellipse(21, 26, 4.5, 4.5):add(c:ellipse(33.5, 17.5, 5, 4.5)):add(c:ellipse(43, 27, 4, 4))
c:part(spots, cream, { gloss = false, contact = false, bounce = false, cres = 2, deep = 1 })
c:px(19, 24, "#fff3c8"); c:px(20, 23, "#fff3c8")
c:px(31, 15, "#fff3c8"); c:px(32, 14, "#fff3c8")
c:px(41, 25, "#fff3c8")
-- join seam on the stem collar
c:seam({ {26, 38}, {38, 38} })
local t = c:save(O .. "aseprite/ico/ico-mushroom.aseprite", O .. "png/ico/ico-mushroom.png")
print(GV.report(t))
