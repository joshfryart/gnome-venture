local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local face = c:ellipse(31.5, 39, 9.5, 8)
-- beard: rounded top widening then tapering to a point at bottom
local beard = c:ellipse(31.5, 46, 13, 5.5)
beard:add(c:poly({ {19, 46}, {45, 46}, {33, 57}, {31, 57} }))
beard:cut(c:rect(0, 0, 63, 41))
beard:add(c:ellipse(31.5, 44, 8.5, 3))
beard:cut(c:rect(0, 0, 63, 40))
local cone = c:poly({ {31, 8}, {33, 8}, {45, 31}, {18, 31} })
local brim = c:rrect(12, 27, 51, 33, 3)
local star = c:ellipse(31.5, 20, 3)

local bramp = GV.ramp("#f2e4c0", { shade = "#968f96", deep = "#6e6870", bounce = "#a89ea4" })
local hat = GV.ramp("#4a8cc0")
c:build{
  { "face",  face,  "skin" },
  { "beard", beard, bramp, { pale = true } },
  { "cone",  cone,  hat },
  { "brim",  brim,  hat },
  { "star",  star,  "gold", { gloss = false } },
}
c:seam({ {14, 28}, {49, 28} })
c:eye(26, 35, true); c:eye(35, 35, true)
c:paint({ "nn", "nn" }, 31, 38, { n = "#d9885a" })
local t = c:save(O .. "aseprite/ico/ico-wizard.aseprite", O .. "png/ico/ico-wizard.png")
print(GV.report(t))
