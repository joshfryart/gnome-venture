local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- slender leaf vane, pointed tip at upper right, slight curve
local vane = c:poly({ {18,51}, {14,46}, {13,38}, {16,30}, {22,22}, {31,15}, {41,10}, {52,6},
                      {48,14}, {43,24}, {37,34}, {30,43}, {23,50} })
-- notches in the barbs
vane:cut(c:poly({ {46,19}, {41,21}, {45,22} }))
vane:cut(c:poly({ {14,34}, {19,35}, {14,37} }))
local quill = c:line({ {16, 52}, {12, 57} }, 3)
local p = c:build{
  { "quill", quill, GV.ramp("#ecc58a"), { flat = true } },
  { "vane", vane, GV.ramp("#7b66b4", { gloss = "#a894dc", rim = "#a894dc", shade = "#3e2f66", deep = "#291d4a" }), { gloss = { 22, 24 } } },
}
-- shaft
c:fill(c:line({ {17, 50}, {24, 42}, {33, 30}, {42, 18}, {48, 10} }, 2), "#3e2f66")
local B = "#3e2f66"
c:fill(c:line({ {27, 38}, {21, 34} }, 1), B)
c:fill(c:line({ {33, 30}, {28, 25} }, 1), B)
c:fill(c:line({ {22, 45}, {16, 43} }, 1), B)
c:fill(c:line({ {38, 24}, {41, 28} }, 1), B)
c:fill(c:line({ {28, 37}, {32, 39} }, 1), B)
-- pale wavy ripple (down line) across the lower-middle
c:paint({
  ".aa.....aa....",
  "a..a...a..a...",
  "....a.a....aa.",
  ".....a........",
}, 16, 38, { a = "#a894dc" })
local t = c:save(O .. "aseprite/ph/heron-plume.aseprite", O .. "png/ph/heron-plume.png")
print(GV.report(t))
