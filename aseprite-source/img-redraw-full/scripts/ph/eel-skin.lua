local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- pelt body with wavy top
local pelt = c:poly({ {13, 20}, {51, 20}, {55, 48}, {9, 48} })
pelt:add(c:ellipse(17.5, 20, 5.5, 5)); pelt:add(c:ellipse(32, 18, 6, 5)); pelt:add(c:ellipse(46.5, 20, 5.5, 5))
pelt:cut(c:ellipse(25, 13, 3, 4)); pelt:cut(c:ellipse(39, 13, 3, 4))
-- side notches
pelt:cut(c:ellipse(9, 31, 3, 3)); pelt:cut(c:ellipse(55, 35, 3, 3))
-- scalloped hem with deep V fin notch
pelt:add(c:ellipse(15, 48, 6, 5)); pelt:add(c:ellipse(49, 48, 6, 5))
pelt:add(c:ellipse(24, 50, 4.5, 4)); pelt:add(c:ellipse(40, 50, 4.5, 4))
pelt:cut(c:poly({ {27, 56}, {32, 45}, {38, 56} }))
c:build{
  { "pelt", pelt, "petal", { gloss = { 17, 24 } } },
}
c:fill(c:rrect(36, 23, 47, 26, 2), "#f6b8cf")
local d = "#2a1a10"
c:fill(c:line({ {16, 32}, {19, 29}, {22, 32}, {25, 29} }, 2), d)
c:fill(c:line({ {32, 35}, {35, 32}, {38, 35}, {41, 32} }, 2), d)
c:fill(c:line({ {19, 41}, {22, 38}, {25, 41}, {28, 38} }, 2), d)
local t = c:save(O .. "aseprite/ph/eel-skin.aseprite", O .. "png/ph/eel-skin.png")
print(GV.report(t))
