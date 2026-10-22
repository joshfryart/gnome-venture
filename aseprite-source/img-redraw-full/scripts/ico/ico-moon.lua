local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local moon = c:ellipse(30, 32, 23, 23):cut(c:ellipse(44, 25, 18, 18))
local gold = GV.ramp("#f2b830")
local p = c:build{
  { "moon", moon, gold, { gloss = { 16, 20 } } },
}
-- craters
c:fill(c:ellipse(15, 33, 2, 2), "#d0862a"); c:px(14, 32, "#b8661a")
c:fill(c:ellipse(23, 46, 2.5, 2), "#d0862a"); c:px(22, 45, "#b8661a")
c:fill(c:ellipse(33, 52, 1.5, 1.5), "#d0862a")
-- inner shade along concave edge
local inner = c:ellipse(44, 25, 20, 20):clip(moon)
c:fill(inner, "#b8661a")
local t = c:save(D .. "img-redraw-full/aseprite/ico/ico-moon.aseprite", D .. "img-redraw-full/png/ico/ico-moon.png")
print(GV.report(t))
