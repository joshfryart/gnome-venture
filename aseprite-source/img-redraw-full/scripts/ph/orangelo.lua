local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fruitR = GV.ramp("#f08a24")
local fruit = c:ellipse(31.5, 38, 21, 15)
local nub = c:rrect(26, 20, 37, 27, 3)
local leaf = c:poly({ {34,18}, {37,12}, {42,8}, {49,6}, {48,11}, {44,16}, {38,19} })
local p = c:build{
  { "nub", nub, GV.ramp("#e0501f"), { gloss = false } },
  { "fruit", fruit, fruitR, { light = fruit:copy():add(nub) } },
  { "stem", c:rrect(30, 14, 33, 22, 1), "#2f5a2a", { flat = true } },
  { "leaf", leaf, "moss", { gloss = false } },
}
-- paler yellow lit half
local lit = c:ellipse(24, 32, 8, 5):clip(fruit:shrink(2))
c:fill(lit, "#f5cf6a")
c:gloss(fruit, GV.ramp("#f5cf6a"), { 18, 30 })
-- leaf vein
for _, pt in ipairs({ {38,16},{40,14},{42,12},{44,10},{46,8} }) do c:px(pt[1], pt[2], "#4a8a3e") end
-- dimples
for _, pt in ipairs({ {36,33},{42,38},{30,44},{39,46},{24,40},{46,32} }) do c:px(pt[1], pt[2], "#d0862a") end
local t = c:save(O .. "aseprite/ph/orangelo.aseprite", O .. "png/ph/orangelo.png")
print(GV.report(t))
