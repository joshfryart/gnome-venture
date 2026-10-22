local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local head = c:poly({ {31,14}, {40,14}, {47,10}, {51,13}, {54,22}, {51,31}, {46,28}, {40,24}, {31,24} })
head:add(c:ellipse(49, 21, 4.5, 9))
head:cut(c:poly({ {50,22}, {55,20}, {55,26} }))  -- chipped notch in the edge
local p = c:build{
  { "handleT", c:line({ {28,39}, {37,15} }, 5), "wood" },
  { "handleB", c:line({ {22,52}, {26,43} }, 5), "wood" },
  { "head",    head, "stone" },
  { "band",    c:rect(31, 24, 38, 26), GV.ramp("#5b6470"), { flat = true } },
  { "splint",  c:poly({ {41,50}, {47,47}, {48,50}, {42,52} }), "wood", { flat = true } },
  { "fleck",   c:poly({ {11,48}, {15,46}, {16,49} }), "stone", { flat = true } },
}
-- crack down the upper handle
c:fill(c:line({ {34,27}, {32,31}, {33,34}, {30,37} }, 1):clip(p.handleT.m), "#2a1a10")
-- splintered ends at the snap
c:px(27, 41, "#ecc58a"); c:px(29, 40, "#ecc58a"); c:px(24, 43, "#ecc58a"); c:px(26, 43, "#ecc58a")
c:ground(32, 53, 16, 1.5)
local t = c:save(O .. "aseprite/ph/broken-fine-felling-axe.aseprite", O .. "png/ph/broken-fine-felling-axe.png")
print(GV.report(t))
