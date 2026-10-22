local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- crossed charcoal sticks poking out of the top (behind the mound)
local s1 = c:line({ {21, 32}, {36, 11} }, 3)
local s2 = c:line({ {26, 12}, {42, 32} }, 3)

-- low flat-bottomed ash heap
local mound = c:ellipse(31.5, 43, 24, 17):cut(c:rect(0, 43, 63, 63))
mound:add(c:rrect(8, 35, 55, 43, 4))

-- ring of dark stones round the base
local st1 = c:ellipse(10.5, 42.5, 4.5, 3.5)
local st2 = c:ellipse(31.5, 45.5, 5.5, 3.5)
local st3 = c:ellipse(52.5, 42.5, 4.5, 3.5)
local st4 = c:ellipse(20.5, 45, 4, 3)
local st5 = c:ellipse(42.5, 45, 4, 3)

local char = GV.ramp("#35161f")
c:build{
  { "s1", s1, char, { flat = true } },
  { "s2", s2, char, { flat = true } },
  { "mound", mound, GV.ramp("#968f96"), { gloss = { 17, 31 } } },
  { "st1", st1, "stone" },
  { "st3", st3, "stone" },
  { "st4", st4, GV.ramp("#5b6470") },
  { "st5", st5, GV.ramp("#5b6470") },
  { "st2", st2, "stone" },
}

-- burnt stick ends on the stick tips
c:paint({ "gg" }, 35, 11, { g = "#5e2a3a" })
c:paint({ "gg" }, 26, 12, { g = "#5e2a3a" })

-- soft pale ash drifts on the heap
c:paint({ ".hhh.", "hhhhh" }, 29, 30, { h = "#c9c5bc" })
c:paint({ ".hh.", "hhhh" }, 43, 35, { h = "#c9c5bc" })
c:paint({ "hhh" }, 20, 36, { h = "#c9c5bc" })

local t = c:save(O .. "aseprite/ph/old-campfire-ash.aseprite", O .. "png/ph/old-campfire-ash.png")
print(GV.report(t))
