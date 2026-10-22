local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local w = GV.ramp("#b6814d")
local p = c:build{
  { "bladeR",  c:poly({ {30,37}, {38,31}, {51,12}, {47,9} }), w },
  { "handleL", c:line({ {33,35}, {24,52} }, 5), w },
  { "handleR", c:line({ {34,35}, {40,46} }, 5), w },
  { "tipR",    c:line({ {44,50}, {47,53} }, 5), w },
  { "bladeL",  c:poly({ {38,37}, {30,31}, {17,12}, {21,9} }), w },
  { "pivot",   c:ellipse(34, 33, 3.5), GV.ramp("#a5663a") },
  { "loose",   c:poly({ {10,47}, {17,45}, {18,48}, {11,50} }), w, { flat = true } },
}
-- grips
c:fill(c:rect(0, 45, 32, 54):clip(p.handleL.m:shrink(1)), "#8a4f2a")
c:fill(c:rect(43, 51, 63, 56):clip(p.tipR.m:shrink(1)), "#8a4f2a")
c:fill(c:rect(0, 47, 20, 50):clip(p.loose.m), "#8a4f2a")
c:px(34, 33, "#4a2c1a")
-- crack across the left blade
c:fill(c:line({ {22,15}, {26,20}, {23,24}, {29,30} }, 1):clip(p.bladeL.m), "#2a1a10")
-- splinters at the snap
c:px(40, 46, "#ecc58a"); c:px(42, 47, "#ecc58a"); c:px(44, 49, "#ecc58a")
c:ground(32, 54, 15, 1.5)
local t = c:save(O .. "aseprite/ph/broken-garden-snips.aseprite", O .. "png/ph/broken-garden-snips.png")
print(GV.report(t))
