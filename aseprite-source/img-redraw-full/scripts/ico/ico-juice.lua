local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local box = c:rrect(16, 22, 47, 57, 3)
-- carton top gable strip
local top = c:rrect(16, 18, 47, 24, 2)
local straw = c:line({ {38, 22}, {38, 9}, {27, 9} }, 4)

local p = c:build{
  { "straw", straw, GV.ramp("#d6322b"), { gloss = false } },
  { "top",   top,   "gold", { gloss = false } },
  { "box",   box,   "gold" },
  { "badge", c:ellipse(31.5, 41, 8, 8), GV.ramp("#d6322b") },
}
-- leaf on badge
c:paint({ ".gg", "gg." }, 32, 32, { g = "#4a8a3e" })
c:seam({ {18, 24}, {45, 24} })
local t = c:save(O .. "aseprite/ico/ico-juice.aseprite", O .. "png/ico/ico-juice.png")
print(GV.report(t))
