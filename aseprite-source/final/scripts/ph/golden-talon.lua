local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- whole claw: sickle, needle tip top, thick root bottom-left
local claw = c:poly({ {30,8},{33,11},{37,17},{40,25},{41,33},{39,41},{35,48},{29,53},{22,56},{13,56},
  {11,52},{13,47},{17,41},{21,33},{24,24},{27,16},{29,10} })
local front = c:poly({ {30,8},{32,13},{34,21},{35,29},{33,37},{29,45},{23,52},{17,56},{13,56},
  {11,52},{13,47},{17,41},{21,33},{24,24},{27,16},{29,10} }):clip(claw)
local back = claw:copy():cut(front)
local all = claw
local p = c:build{
  { "back",  back,  "#c07a2a", { light = all, gloss = false } },
  { "front", front, "gold", { light = all, gloss = { 23, 27 } } },
}
-- cream stripe along the inner curve
local stripe = c:line({ {19, 48}, {21, 42}, {23, 36}, {25, 30} }, 2):clip(p.front.m:shrink(1))
c:fill(stripe, "#f1ece0")
-- base band (root ring)
c:fill(c:line({ {13, 52}, {22, 52} }, 1):clip(claw), GV.C.umber)
c:ground(26, 58, 12, 1.5)
local t = c:save(O .. "aseprite/ph/golden-talon.aseprite", O .. "png/ph/golden-talon.png")
print(GV.report(t))
