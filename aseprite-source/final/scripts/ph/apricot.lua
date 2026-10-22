local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fruitR = GV.ramp("#f08a24", { shade = "#e0501f" })
local fruit = c:ellipse(31.5, 37, 17.5, 16.5)
local p = c:build{
  { "stem",  c:line({ {32, 23}, {32, 17}, {33, 14} }, 3), "#4a8a3e", { flat = true } },
  { "fruit", fruit, fruitR, { gloss = { 22, 28 } } },
  { "leaf",  c:poly({ {33, 19}, {36, 14}, {41, 11}, {48, 9}, {47, 13}, {43, 18}, {37, 21} }), "#58a03e", { gloss = false } },
}
-- leaf vein
c:fill(c:line({ {36, 18}, {41, 14}, {46, 11} }, 1), "#2f5a2a")
-- cleft: soft vertical crease down the front
local cleft = c:line({ {31, 23}, {29, 30}, {29, 39}, {30, 46}, {32, 52} }, 2):clip(fruit:shrink(1))
c:fill(cleft, "#b8661a")
c:fill(c:line({ {30, 24}, {28, 31} }, 1):clip(fruit:shrink(1)), fruitR.rim)
local t = c:save(O .. "aseprite/ph/apricot.aseprite", O .. "png/ph/apricot.png")
print(GV.report(t))
