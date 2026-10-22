local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local claw = c:poly({ {17, 52}, {13, 46}, {12, 38}, {14, 30}, {19, 22}, {25, 16}, {31, 12}, {37, 11},
  {35, 14}, {31, 18}, {28, 24}, {27, 31}, {29, 37}, {33, 43}, {33, 48}, {29, 51}, {23, 53} })
local cuff = c:line({ {11, 46}, {35, 42} }, 3):clip(claw)
local ridge = c:line({ {19, 45}, {17, 38}, {18, 31}, {22, 24}, {27, 18} }, 2)
c:build{
  { "claw", claw, GV.ramp("#dcb06a"), { cres = 5, gloss = { 16, 34 } } },
  { "ridge", ridge, GV.ramp("#f1ece0"), { flat = true, contour = false, contact = false } },
  { "cuff", cuff, "wood", { flat = true } },
}
local t = c:save(O .. "aseprite/ph/digging-claw.aseprite", O .. "png/ph/digging-claw.png")
print(GV.report(t))
