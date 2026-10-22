local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fruitR = GV.ramp("#7a5cc0", { rim = "#7b66b4", gloss = "#a894dc", deep = "#291d4a" })
local bellyR = GV.ramp("#4e3a8a", { rim = "#5d4aa0", deep = "#291d4a" })
-- fig: round belly tapering to a neck at the top
local fruit = c:ellipse(31.5, 38, 17, 15)
fruit:add(c:poly({ {22, 30}, {28, 19}, {35, 19}, {41, 30} }))
fruit:add(c:ellipse(31.5, 21, 4, 3))
local belly = fruit:copy():clip(c:ellipse(31.5, 52, 22, 10))
local stem = c:line({ {31, 18}, {32, 12} }, 3)
local leaf = c:poly({ {33, 16}, {37, 9}, {44, 5}, {46, 7}, {43, 13}, {36, 17} })
local p = c:build{
  { "stem", stem, "#2e5a2c", { flat = true } },
  { "fruit", fruit, fruitR, { gloss = { 24, 29 } } },
  { "belly", belly, bellyR, { light = fruit, gloss = false } },
  { "leaf", leaf, "#58a03e", { gloss = { 40, 9 } } },
}
-- leaf vein
for _, q in ipairs({ {37,14},{38,13},{39,12},{40,11},{41,10},{42,9} }) do c:px(q[1], q[2], "#3f7a2e") end
-- cream squiggle across belly
c:paint({ "cc...cc...cc...cc...c", "..c.c..c.c..c.c..c.c." }, 21, 41, { c = "#f4f0e0" })
c:ground(31.5, 56, 17, 2.5)
local t = c:save(O .. "aseprite/ph/fig.aseprite", O .. "png/ph/fig.png")
print(GV.report(t))
