local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- knobbly ginger: a horizontal hand with three bumps
local root = c:ellipse(31.5, 19, 11, 5)
root:add(c:ellipse(24, 14, 4, 4)):add(c:ellipse(33, 12, 4, 5)):add(c:ellipse(40, 16, 3.5, 3.5))
local p = c:build{
  { "root", root, "#dcb06a" },
}
c:fill(c:line({ {33, 7}, {33, 4} }, 2), "#58a03e")
c:fill(c:line({ {35, 5}, {37, 3} }, 2), "#58a03e")
c:px(23, 18, "#a8582f"); c:px(30, 20, "#a8582f"); c:px(38, 19, "#a8582f")
c:build{
  { "tin", c:rrect(12, 28, 51, 54, 4), "stone" },
  { "lid", c:rrect(10, 21, 53, 32, 4), GV.ramp("#c9c5bc", { gloss = "#eeeae2" }) },
}
c:seam({ {14, 32}, {49, 32} })
c:fill(c:rect(17, 29, 19, 31), "#5b6470"); c:px(17, 29, "#8b8f96")
c:fill(c:rect(44, 29, 46, 31), "#5b6470"); c:px(44, 29, "#8b8f96")
c:part(c:rrect(29, 33, 34, 39, 1), "gold", { gloss = false, cres = 2 })
c:px(31, 37, "#8a4a1c"); c:px(32, 37, "#8a4a1c")
c:button(30, 30)
c:part(c:rect(18, 41, 45, 50), "#f1ece0", { gloss = false })
c:paint({ "kkkkkkkkkkkkkkkk", "................","kkkkkkkkkk..kkkk" }, 23, 44, { k = "#4a2c1a" })
c:ground(31.5, 57, 18, 1.5)
local t = c:save(O .. "aseprite/ph/ginger-seed.aseprite", O .. "png/ph/ginger-seed.png")
print(GV.report(t))
