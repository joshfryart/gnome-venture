local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local paper = GV.ramp("#f1ece0", { shade = "#dcb06a" })
local pink = GV.ramp("#e46a9b", { deep = "#a8241f" })
-- cone body (wide top, narrowing to a point)
local cone = c:poly({ {13, 26}, {51, 26}, {35, 52}, {29, 52} })
-- twisted tip curl
local tip = c:poly({ {29, 50}, {35, 50}, {34, 55}, {36, 58}, {31, 58}, {32, 55} })
-- fruit with hair tufts
local fruit = c:ellipse(32, 20, 10, 9)
fruit:add(c:rect(21, 15, 22, 16)); fruit:add(c:rect(42, 14, 43, 15))
fruit:add(c:rect(26, 9, 27, 10)); fruit:add(c:rect(37, 9, 38, 10))
fruit:add(c:rect(20, 21, 21, 22)); fruit:add(c:rect(43, 20, 44, 21))
local rim = c:ellipse(31.5, 26, 19, 4):cut(c:rect(0, 0, 63, 25))
rim:add(c:rect(13, 24, 50, 26))
local leaf = c:ellipse(33.5, 9, 3, 2)
local p = c:build{
  { "tip", tip, paper, { gloss = false } },
  { "cone", cone, paper },
  { "fruit", fruit, pink },
  { "rim", rim, paper, { gloss = false } },
  { "leaf", leaf, "#58a03e", { flat = true } },
}
-- hair strokes on fruit
c:paint({ "h.h", ".h." }, 27, 14, { h = "#f6b8cf" })
c:paint({ "h.h", ".h." }, 35, 16, { h = "#ae2a2a" })
c:paint({ "h.h" }, 30, 19, { h = "#f6b8cf" })
-- spiral fold seam
c:seam({ {18, 30}, {26, 36}, {38, 42}, {32, 49} })
c:button(42, 24)
c:ground(32, 58, 8, 1.5)
local t = c:save(O .. "aseprite/ph/rambutan-seed.aseprite", O .. "png/ph/rambutan-seed.png")
print(GV.report(t))
