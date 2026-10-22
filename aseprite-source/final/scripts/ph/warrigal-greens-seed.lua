local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- tall felt pouch, scalloped top
local pouch = c:rrect(14, 18, 48, 56, 9)
for _, x in ipairs({ 18, 26, 34, 42 }) do pouch:add(c:ellipse(x + 0.5, 15, 3.5, 3.5)) end
pouch:add(c:rect(15, 18, 47, 20))
local leaf = c:poly({ {31, 52}, {22, 44}, {21, 34}, {31, 25}, {41, 34}, {40, 44} })
local p = c:build{
  { "pouch", pouch, "moss", { stitch = { side = "lit" } } },
  { "leaf", leaf, GV.ramp("#3f8a34"), { gloss = { 26, 33 } } },
}
-- drawstring cord across the neck
c:fill(c:rect(14, 22, 48, 23), "#f5cf6a")
c:fill(c:rect(14, 23, 48, 23), "#e8a317")
-- veins
c:fill(c:rect(30, 28, 31, 49), "#2e5a2c")
c:fill(c:line({ {29, 37}, {25, 34} }, 1), "#2e5a2c")
c:fill(c:line({ {32, 35}, {37, 32} }, 1), "#2e5a2c")
c:fill(c:line({ {29, 44}, {25, 41} }, 1), "#2e5a2c")
c:fill(c:line({ {32, 42}, {37, 39} }, 1), "#2e5a2c")
-- long tassel cord hanging off the right side
c:part(c:line({ {47, 23}, {53, 38} }, 2), "gold", { flat = true })
c:part(c:rrect(51, 38, 55, 40, 1), "gold", { flat = true })
c:part(c:poly({ {51, 41}, {56, 41}, {57, 52}, {50, 52} }), "gold", { gloss = false, cres = 2, deep = 1 })
for x = 51, 55, 2 do c:fill(c:rect(x, 44, x, 51), "#b8661a") end
c:button(30, 21)
local t = c:save(O .. "aseprite/ph/warrigal-greens-seed.aseprite", O .. "png/ph/warrigal-greens-seed.png")
print(GV.report(t))
