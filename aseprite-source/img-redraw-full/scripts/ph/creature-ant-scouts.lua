local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local brown = GV.ramp("#8c4a1a")   -- wood family
local feel = GV.ramp("#5e2f1e")    -- wood deep, antennae

-- legs first (behind bodies)
-- upper ant (bigger, right)
c:limb({ {28,24}, {24,27}, {22,31} })
c:limb({ {31,24}, {32,28}, {30,31} })
c:limb({ {34,23}, {39,27}, {41,31} })
-- lower ant (smaller, left)
c:limb({ {21,45}, {18,48}, {16,51} })
c:limb({ {23,45}, {24,49}, {22,52} })
c:limb({ {26,44}, {30,48}, {32,52} })

-- antennae with 4x4 clubs
local antU = c:line({ {17,16}, {14,12}, {11,11} }, 2):add(c:rrect(8, 9, 11, 12, 1))
antU:add(c:line({ {21,16}, {22,11}, {25,9} }, 2)):add(c:rrect(25, 7, 28, 10, 1))
local antL = c:line({ {12,39}, {10,36}, {8,35} }, 2):add(c:rrect(5, 33, 8, 36, 1))
antL:add(c:line({ {16,39}, {17,36}, {19,34} }, 2)):add(c:rrect(19, 32, 22, 35, 1))

c:build{
  { "antU",  antU, feel, { flat = true } },
  { "abdU",  c:ellipse(41, 20.5, 8.5, 6.5), brown, { stitch = { side = "lit" } } },
  { "thxU",  c:ellipse(29.5, 22, 4, 3), brown },
  { "headU", c:ellipse(19, 20.5, 5.5, 5), brown },
  { "antL",  antL, feel, { flat = true } },
  { "abdL",  c:ellipse(31.5, 43.5, 6.5, 5), brown },
  { "thxL",  c:ellipse(22.5, 44, 3, 2.5), brown },
  { "headL", c:ellipse(14, 43, 4.5, 4.5), brown },
}
-- mandibles
c:paint({ "m.", ".m" }, 13, 24, { m = "#5e2f1e" })
c:paint({ "m.", ".m" }, 9, 46, { m = "#5e2f1e" })
-- eyes (small heads)
c:eye(14, 18, true); c:eye(19, 18, true)
c:eye(10, 41, true); c:eye(14, 41, true)

local t = c:save(O .. "aseprite/ph/creature-ant-scouts.aseprite", O .. "png/ph/creature-ant-scouts.png")
print(GV.report(t))
