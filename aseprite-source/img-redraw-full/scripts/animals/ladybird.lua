local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local red = GV.ramp("#d6322b")
local dark = GV.ramp("#35161f", { rim = "#5e2a3a", gloss = "#7b66b4" })
-- legs first (behind shell)
c:limb({ {16, 30}, {12, 28}, {10, 30} })
c:limb({ {48, 30}, {52, 28}, {54, 30} })
c:limb({ {16, 44}, {12, 46}, {10, 49} })
c:limb({ {48, 44}, {52, 46}, {54, 49} })
local p = c:build{
  { "antL", c:line({ {28, 12}, {24, 9}, {20, 8} }, 2), dark, { flat = true } },
  { "antR", c:line({ {36, 12}, {40, 9}, {44, 8} }, 2), dark, { flat = true } },
  { "clubL", c:rrect(16, 5, 19, 8, 1), dark, { flat = true } },
  { "clubR", c:rrect(45, 5, 48, 8, 1), dark, { flat = true } },
  { "head", c:ellipse(32, 18, 9, 8), dark },
  { "shell", c:ellipse(32, 37, 20, 19), red, { gloss = { 18, 27 } } },
}
-- centre seam (wing split)
c:fill(c:line({ {32, 22}, {32, 55} }, 2):shift(-1, 0):add(c:line({ {32, 22}, {32, 55} }, 1)):clip(p.shell.m), "#35161f")
-- spots: beans, two bigger upper, two smaller lower
c:spot(c:ellipse(23, 32, 3.5, 3.5))
c:spot(c:ellipse(41, 32, 3.5, 3.5))
c:spot(c:ellipse(23.5, 45, 3, 2.5))
c:spot(c:ellipse(40.5, 45, 3, 2.5))
-- face
c:eye(26, 15, true); c:eye(35, 15, true)
local t = c:save(O .. "aseprite/animals/ladybird.aseprite", O .. "png/animals/ladybird.png")
print(GV.report(t))
