local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local side = c:rect(13, 24, 51, 51):add(c:ellipse(32, 51, 19, 6))
local stripe = c:rect(13, 37, 51, 41):clip(side)
local wood = GV.ramp("#a8582f")
local sr = c:line({ {46, 10}, {33, 22} }, 3):add(c:ellipse(47, 9, 2.5))
local sl = c:line({ {18, 10}, {31, 22} }, 3):add(c:ellipse(17, 9, 2.5))
c:build{
  { "side", side, GV.ramp("#dd3a2a", { rim = "#f2793a", shade = "#ae2a2a" }) },
  { "stripe", stripe, "gold", { gloss = false } },
  { "head", c:ellipse(32, 24, 19, 7), GV.ramp("#f8eed2") },
  { "sr", sr, wood, { gloss = false } },
  { "sl", sl, wood, { gloss = false } },
}
c:seam({ {16, 29}, {48, 29} })
local t = c:save(O .. "aseprite/ico/ico-drum.aseprite", O .. "png/ico/ico-drum.png")
print(GV.report(t))
