local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- left villager: lower and larger
local lsh = c:ellipse(24, 52, 12, 11):cut(c:rect(0, 49, 63, 63))
local lhead = c:ellipse(23, 30, 9)
local lhair = c:ellipse(23, 28, 10, 9):cut(c:rect(0, 26, 63, 63))
lhair:add(c:rect(14, 26, 15, 29))
-- right villager: slightly higher, smaller
local rsh = c:ellipse(41, 50, 10, 11):cut(c:rect(0, 49, 63, 63))
local rhead = c:ellipse(41, 27, 8)
local rhair = c:ellipse(41, 25, 9, 8.5):cut(c:rect(0, 23, 63, 63))
rhair:add(c:rect(48, 23, 49, 27))

c:build{
  { "lsh",   lsh,   GV.ramp("#58a03e") },
  { "lhead", lhead, GV.ramp("#dcb06a") },
  { "lhair", lhair, GV.ramp("#8c4a1a") },
  { "rsh",   rsh,   GV.ramp("#7a5cc0") },
  { "rhead", rhead, GV.ramp("#f1ece0") },
  { "rhair", rhair, GV.ramp("#b07a10") },
}
c:seam({ {17, 44}, {31, 44} })
c:eye(19, 30, true); c:eye(25, 30, true)
c:eye(37, 27, true); c:eye(43, 27, true)
c:paint({ "u...u", ".uuu." }, 21, 34, { u = "umber" })
c:paint({ "u..u", ".uu." }, 39, 31, { u = "umber" })

local t = c:save(O .. "aseprite/ph/nav-villagers.aseprite", O .. "png/ph/nav-villagers.png")
print(GV.report(t))
