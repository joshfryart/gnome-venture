local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local cloudR = GV.ramp("#8c9ca6", { shade = "#5b6470", deep = "#3a4452" })
local boltR  = GV.ramp("#f2b830", { shade = "#d0862a", gloss = "#fff1c8" })

local cloud = c:ellipse(23, 26, 7)
cloud:add(c:ellipse(33, 21, 10))
cloud:add(c:ellipse(43, 26, 7))
cloud:add(c:rrect(15, 25, 50, 36, 5))

local bolt = c:poly({ {35, 26}, {23, 42}, {31, 42}, {26, 53}, {44, 35}, {36, 35}, {42, 26} })

c:build{
  { "cloud", cloud, cloudR, { gloss = { 27, 15 } } },
  { "bolt",  bolt,  boltR },
}

local t = c:save(O .. "aseprite/ico/ico-storm.aseprite", O .. "png/ico/ico-storm.png")
print(GV.report(t))
