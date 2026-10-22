local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cord = c:line({ {8,13},{14,18},{22,22},{32,24},{42,22},{50,18},{56,13} }, 2)
local tieL = c:line({ {15,18},{15,25} }, 2)
local tieC = c:line({ {31,24},{31,29} }, 2)
local tieR = c:line({ {48,18},{48,25} }, 2)
local tL = c:poly({ {9,24},{23,24},{16,42} })
local tC = c:poly({ {25,29},{39,29},{32,49} })
local tR = c:poly({ {41,24},{55,24},{48,42} })
local p = c:build{
  { "cord", cord, GV.ramp("#74462a"), { flat = true } },
  { "tieL", tieL, GV.ramp("#74462a"), { flat = true } },
  { "tieC", tieC, GV.ramp("#74462a"), { flat = true } },
  { "tieR", tieR, GV.ramp("#74462a"), { flat = true } },
  { "tL", tL, "petal" },
  { "tR", tR, "petal" },
  { "tC", tC, "gold" },
}
c:seam({ {32,31},{32,44} })
local t = c:save(O .. "aseprite/ph/wind-harp.aseprite", O .. "png/ph/wind-harp.png")
print(GV.report(t))
