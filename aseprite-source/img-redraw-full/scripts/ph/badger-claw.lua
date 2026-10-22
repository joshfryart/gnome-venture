local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:poly({ {16,55},{14,46},{14,38},{16,30},{19,22},{23,15},{28,9},{31,6},{33,6},
  {33,10},{32,16},{32,24},{33,32},{35,40},{37,48},{38,55} })
local ridge = body:copy():cut(body:shift(-5,0))
ridge:cut(c:rect(0,0,63,11))
local stripe = c:line({ {18,49},{17,42},{18,35},{20,28},{23,21},{26,16} }, 3):clip(body:shrink(1))
local baseCut = c:rect(0,52,63,55):clip(body)
c:build{
  { "claw", body, GV.ramp("#dcb06a"), { gloss = {19,22}, cres = 3 } },
  { "ridge", ridge, GV.ramp("#a5663a"), { flat = true } },
  { "stripe", stripe, "cream", { flat = true } },
  { "base", baseCut, GV.ramp("#8a4f2a"), { flat = true } },
}
c:seam({ {15,49},{37,49} })
c:ground(26, 56, 13, 1.5)
local t = c:save(O .. "aseprite/ph/badger-claw.aseprite", O .. "png/ph/badger-claw.png")
print(GV.report(t))
