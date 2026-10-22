local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local lwall = c:rect(11, 33, 27, 53)
local lroof = c:poly({ {9, 36}, {19, 22}, {30, 36} })
local rwall = c:rect(30, 28, 51, 53)
local rroof = c:poly({ {27, 30}, {41, 12}, {55, 30} })

local p = c:build{
  { "lwall", lwall, "#dcb06a" },
  { "lroof", lroof, "#d6322b" },
  { "rwall", rwall, "#f1ece0" },
  { "rroof", rroof, "#7a5cc0" },
}
local win = GV.ramp("#a9d6ea")
-- left house details
c:part(c:rrect(17, 42, 22, 53, 2), "#b6814d", { gloss = false })
c:part(c:rect(13, 37, 15, 39), win, { flat = true })
c:px(21, 48, GV.C.gold)
-- right house details
c:part(c:rrect(37, 41, 44, 53, 3), "#8c4a1a", { gloss = false })
c:part(c:rect(32, 33, 35, 36), win, { flat = true })
c:part(c:rect(46, 33, 49, 36), win, { flat = true })
c:px(43, 47, GV.C.gold)
-- chimney-free; round attic window on purple roof
c:part(c:ellipse(41, 23, 2, 2), win, { flat = true })
c:ground(31, 55, 21, 1.5)
local t = c:save(O .. "aseprite/ico/ico-house-row.aseprite", O .. "png/ico/ico-house-row.png")
print(GV.report(t))
