local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local hex = c:poly({ {10,22},{32,13},{55,22},{55,49},{32,58},{10,49} })
local left = c:poly({ {10,22},{32,31},{32,58},{10,49} })
local top = c:poly({ {10,22},{32,13},{55,22},{32,31} })
local right = c:poly({ {32,31},{55,22},{55,49},{32,58} })

local p = c:build{
  { "left",  left,  GV.ramp("#dcb06a"), { light = hex, gloss = false } },
  { "right", right, GV.ramp("#b07a45"), { light = hex, gloss = false, rim = false } },
  { "top",   top,   GV.ramp("#ecc58a"), { gloss = { 18, 21 } } },
}
-- centre Y edge
c:fill(c:line({ {11,23},{32,31},{54,23} }, 2), "#8a4f2a")
c:fill(c:line({ {32,31},{32,57} }, 2), "#8a4f2a")
-- tape strip running down the lid seam and over the front edge
local tape = c:poly({ {28,15},{33,13},{38,16},{33,18} })
-- tilted cream label on the left face
local label = c:poly({ {14,33},{27,38},{27,45},{14,40} })
c:part(label, "cream", { contour = "#74462a", gloss = false, cres = 2, deep = 1 })
c:fill(c:line({ {17,37},{24,40} }, 1), "#c9a96e")
c:fill(c:line({ {17,40},{22,42} }, 1), "#c9a96e")
c:fill(tape, "#f1ece0")
c:px(31, 15, "#fff3c8"); c:px(32, 15, "#fff3c8")

local t = c:save(O .. "aseprite/ico/ico-box.aseprite", O .. "png/ico/ico-box.png")
print(GV.report(t))
