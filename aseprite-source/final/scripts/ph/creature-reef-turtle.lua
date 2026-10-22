local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local green = GV.ramp("#58a03e")
local rimR  = GV.ramp("#3f7a34")
local dark  = "#2e5a2c"

local shell = c:ellipse(27, 37, 17, 18):cut(c:rect(0, 37, 63, 63))
local p = c:build{
  { "tail",   c:line({ {13, 38}, {9, 41} }, 3), rimR, { flat = true } },
  { "backfl", c:ellipse(16, 42, 4.5, 3), green },
  { "frontfl",c:poly({ {33, 39}, {43, 39}, {46, 45}, {40, 46}, {34, 43} }), green },
  { "neck",   c:rrect(40, 30, 47, 39, 2), green },
  { "head",   c:ellipse(48, 28.5, 5, 5), green },
  { "shell",  shell, green },
  { "rim",    c:rrect(9, 36, 45, 40, 2), rimR },
}
-- scute lines, clipped inside the dome
local inner = p.shell.m:shrink(2)
local sc = c:line({ {27, 19}, {27, 36} }, 2)
sc:add(c:line({ {13, 28}, {41, 28} }, 2))
sc:add(c:line({ {19, 21}, {22, 28}, {19, 36} }, 2))
sc:add(c:line({ {35, 21}, {32, 28}, {35, 36} }, 2))
sc:clip(inner)
c:fill(sc, dark)
c:gloss(p.shell.m, green)
-- stitches along the rim join
c:seam({ {11, 37}, {44, 37} })
-- face
c:eye(48, 26, true)
c:paint({ "m...m", ".mmm." }, 47, 30, { m = "umber" })
c:ground(27, 46, 19, 1.5)
local t = c:save(O .. "aseprite/ph/creature-reef-turtle.aseprite", O .. "png/ph/creature-reef-turtle.png")
print(GV.report(t))
