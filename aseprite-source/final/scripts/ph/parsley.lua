local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leaf = c:ellipse(32, 35, 11, 16)
leaf:add(c:ellipse(32, 13, 5, 6))
leaf:add(c:ellipse(25, 21, 6, 5)); leaf:add(c:ellipse(39, 21, 6, 5))
leaf:add(c:ellipse(19, 32, 7, 6)); leaf:add(c:ellipse(45, 32, 7, 6))
leaf:add(c:ellipse(21, 44, 7, 6)); leaf:add(c:ellipse(43, 44, 7, 6))
leaf:add(c:ellipse(32, 47, 9, 4))
local dk = "#2e5a2c"
c:build{
  { "stalk", c:rect(31, 48, 33, 56), GV.ramp(dk), { flat = true } },
  { "leaf", leaf, GV.ramp("#58a03e"), { gloss = {20, 25} } },
}
c:fill(c:line({ {32, 16}, {32, 52} }, 2), dk)
c:fill(c:line({ {32, 40}, {21, 32} }, 2), dk)
c:fill(c:line({ {32, 28}, {26, 22} }, 2), dk)
c:fill(c:line({ {32, 34}, {43, 27} }, 2), dk)
c:fill(c:line({ {32, 46}, {41, 40} }, 2), dk)
local t = c:save(O .. "aseprite/ph/parsley.aseprite", O .. "png/ph/parsley.png")
print(GV.report(t))
