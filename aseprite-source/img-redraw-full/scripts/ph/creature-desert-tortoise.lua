local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan = GV.ramp("#dcb06a")
local Y = -3 -- vertical shift
local dome = c:ellipse(28, 41 + Y, 15, 24):cut(c:rect(0, 41 + Y, 63, 63))
local rim = c:rrect(11, 39 + Y, 45, 45 + Y, 3)
local p = c:build{
  { "footB", c:ellipse(19.5, 46 + Y, 4.5, 2.5), tan },
  { "footF", c:ellipse(37.5, 46 + Y, 4.5, 2.5), tan },
  { "tail",  c:line({ {14, 41 + Y}, {10, 44 + Y} }, 3), "#c4925f", { flat = true } },
  { "neck",  c:line({ {40, 41 + Y}, {45, 37 + Y} }, 5), "#c4925f" },
  { "dome",  dome, "#a5663a" },
  { "rim",   rim, "#8c4a1a" },
  { "head",  c:ellipse(47.5, 36 + Y, 5, 4.5), tan },
}
-- scute lattice, clipped to dome interior, skipping the gloss
local L = c:mask()
L:add(c:line({ {28, 19 + Y}, {28, 39 + Y} }, 1))
L:add(c:line({ {15, 29 + Y}, {41, 29 + Y} }, 1))
L:add(c:line({ {21, 21 + Y}, {24, 29 + Y}, {21, 39 + Y} }, 1))
L:add(c:line({ {35, 21 + Y}, {32, 29 + Y}, {35, 39 + Y} }, 1))
L:clip(dome:shrink(1))
L:cut(c:ellipse(21, 23 + Y, 3, 3))
c:fill(L, "#4a2c1a")
c:seam({ {13, 41 + Y}, {43, 41 + Y} })
c:eye(48, 34 + Y, true)
c:paint({ "u..u", ".uu." }, 47, 38 + Y, { u = "#4a2c1a" })
c:ground(28, 48.5 + Y, 17, 1)
local t = c:save(O .. "aseprite/ph/creature-desert-tortoise.aseprite", O .. "png/ph/creature-desert-tortoise.png")
print(GV.report(t))
