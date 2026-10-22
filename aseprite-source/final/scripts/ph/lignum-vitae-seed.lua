local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cone = c:poly({ {14, 21}, {51, 21}, {32, 56} })
local fold = c:poly({ {14, 21}, {24, 21}, {32, 56} }):clip(cone)
local bud = c:ellipse(40, 10, 4, 2.5)
local p = c:build{
  { "stem", c:line({ {32, 10}, {33, 8}, {36, 7} }, 2), "#2f5a2a", { flat = true } },
  { "bud", bud, GV.ramp("#58a03e"), { gloss = false } },
  { "seed", c:ellipse(32, 16, 10, 9), GV.ramp("#2f7a3a") },
  { "cone", cone, GV.ramp("#f1ece0") },
  { "fold", fold, GV.ramp("#dcb06a"), { gloss = false, light = cone } },
  { "lip", c:ellipse(32, 21, 18, 3):cut(c:rect(0, 0, 63, 20)), GV.ramp("#dcb06a"), { gloss = false } },
}
c:seam({ { 22, 25 }, { 31, 54 } })
local t = c:save(O .. "aseprite/ph/lignum-vitae-seed.aseprite", O .. "png/ph/lignum-vitae-seed.png")
print(GV.report(t))
