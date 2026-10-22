local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local cream = GV.ramp("#d6c9b6")
-- loop handle on the right
local handle = c:ellipse(46.5, 36, 8, 8.5):cut(c:ellipse(46.5, 36, 4, 4.5))
-- U-shaped cup
local cup = c:rect(13, 24, 45, 40):add(c:ellipse(29, 39, 16, 15):clip(c:rect(13, 39, 45, 54)))
cup:add(c:rrect(13, 24, 45, 44, 2))

local p = c:build{
  { "handle", handle, cream, { gloss = false } },
  { "cup",    cup,    cream },
}
-- tea surface lens
local tea = c:ellipse(29, 29, 13, 5)
c:part(tea, GV.ramp("#7ab55c"), { contact = false, gloss = { 20, 27 } })
-- rim ring around the tea
c:fill(c:rect(14, 24, 44, 25):cut(c:rect(17, 24, 41, 24)), "#968f96")
-- tea glint arc
c:paint({ "..ggggg...ggggg..", "gg.............gg" }, 21, 31, { g = "#4a8a3e" })

local t = c:save(O .. "aseprite/ico/ico-tea.aseprite", O .. "png/ico/ico-tea.png")
print(GV.report(t))
