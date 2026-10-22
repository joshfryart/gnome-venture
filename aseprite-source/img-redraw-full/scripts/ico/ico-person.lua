local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- shoulders: wide dome, flat base
local sh = c:ellipse(32, 51, 20, 15):cut(c:rect(-10, 52, 80, 90))
-- hair cap and face
local hair = c:ellipse(32, 23, 11, 11)
local face = c:ellipse(32, 28, 8.5, 8):cut(c:ellipse(32, 17, 12, 6))

c:build{
  { "shoulders", sh, GV.ramp("#3f93b2") },
  { "hair", hair, GV.ramp("#3a2236") },
  { "face", face, "skin", { gloss = { 27, 24 } } },
}
-- collar seam on the shoulders
c:seam({ {19, 43}, {25, 40}, {39, 40}, {45, 43} })
-- locked small eyes
c:eye(26, 26, true); c:eye(35, 26, true)
c:paint({ "m...m", ".mmm." }, 30, 31, { m = "umber" })

local t = c:save(O .. "aseprite/ico/ico-person.aseprite", O .. "png/ico/ico-person.png")
print(GV.report(t))
