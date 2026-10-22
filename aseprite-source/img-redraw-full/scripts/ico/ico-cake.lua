local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local sponge = c:rrect(12, 32, 52, 52, 5)
local icing = c:rrect(11, 26, 53, 34, 4)
-- scallops hanging below: drips between dips at 22, 32, 42
for _, x in ipairs({ 16.5, 27, 37, 47.5 }) do icing:add(c:ellipse(x, 34, 4.5, 4)) end
icing:add(c:rrect(25, 33, 28, 42, 2)) -- one long drip
local candle = c:rrect(30, 14, 33, 27, 1)
local flame = c:ellipse(31.5, 12, 3, 3.5):add(c:poly({ {29, 11}, {31, 5}, {32, 5}, {35, 11} }))
local p = c:build{
  { "sponge", sponge, GV.ramp("#dcb06a") },
  { "icing", icing, GV.ramp("#f08a24") },
  { "candle", candle, "petal", { gloss = false } },
  { "flame", flame, "gold", { gloss = { 30, 10 } } },
}
-- candle stripes
c:px(31, 18, "#e46a9b"); c:px(32, 19, "#e46a9b"); c:px(31, 22, "#e46a9b"); c:px(32, 23, "#e46a9b")
-- sponge crumbs (carrot flecks)
for _, q in ipairs({ {18, 46}, {30, 48}, {41, 45}, {46, 49}, {23, 49} }) do c:px(q[1], q[2], "#b07a45") end
c:seam({ {14, 51}, {50, 51} })
local t = c:save(O .. "aseprite/ico/ico-cake.aseprite", O .. "png/ico/ico-cake.png")
print(GV.report(t))
