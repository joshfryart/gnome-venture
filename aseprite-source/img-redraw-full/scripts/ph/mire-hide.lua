local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- pelt: central body with wavy top/bottom and four paw corners
local hide = c:rrect(15, 16, 48, 54, 5)
-- wavy top: neck bump in middle
hide:add(c:ellipse(31.5, 15, 7, 4))
hide:cut(c:ellipse(21, 14, 4, 2.5)); hide:cut(c:ellipse(42, 14, 4, 2.5))
-- wavy bottom scallops
hide:add(c:ellipse(22, 54, 5, 3)); hide:add(c:ellipse(41, 54, 5, 3))
hide:cut(c:ellipse(31.5, 57, 4, 3))
-- four paw corners (lower pair belongs to body)
local paws = c:poly({ {16, 41}, {8, 46}, {7, 51}, {12, 52}, {17, 49} })
paws:add(c:poly({ {47, 41}, {55, 46}, {56, 51}, {51, 52}, {46, 49} }))
paws:add(c:poly({ {16, 18}, {9, 15}, {7, 19}, {10, 24}, {16, 26} }))
paws:add(c:poly({ {47, 18}, {54, 15}, {56, 19}, {53, 24}, {47, 26} }))
-- side flaps
local flaps = c:rrect(8, 27, 17, 34, 3):add(c:rrect(46, 27, 55, 34, 3))

local p = c:build{
  { "paws", paws, GV.ramp("#6a9a3a"), { gloss = false } },
  { "flaps", flaps, GV.ramp("#6a9a3a"), { gloss = false } },
  { "hide", hide, "moss", { stitch = { side = "lit" }, gloss = { 20, 21 } } },
}
-- mud blotches (beans)
c:spot(c:ellipse(23, 29, 3, 2), "#4a2c1a", "#7a4a1f")
c:spot(c:ellipse(39, 36, 3, 2.5), "#4a2c1a", "#7a4a1f")
c:spot(c:ellipse(25, 45, 2.5, 2), "#4a2c1a", "#7a4a1f")
c:spot(c:ellipse(40, 23, 2, 1.5), "#4a2c1a", "#7a4a1f")
-- wet streak
c:fill(c:line({ {19, 39}, {24, 38}, {28, 39} }, 1), "#2f5a2a")
c:fill(c:line({ {35, 44}, {40, 45}, {44, 44} }, 1), "#2f5a2a")

c:seam({ {31, 18}, {31, 52} })

local t = c:save(O .. "aseprite/ph/mire-hide.aseprite", O .. "png/ph/mire-hide.png")
print(GV.report(t))
