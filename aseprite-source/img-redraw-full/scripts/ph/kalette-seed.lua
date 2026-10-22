local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cone = c:poly({ {11,23}, {54,23}, {33,58} })
local twist = c:poly({ {20,7}, {45,7}, {37,15}, {41,25}, {24,25}, {28,15} })
local stripe = c:line({ {14,30}, {40,56} }, 3):clip(cone)
local leaf = c:poly({ {22,46}, {26,36}, {33,30}, {42,27}, {41,35}, {36,42}, {28,46} })
leaf:add(c:ellipse(25, 39, 2, 2)); leaf:add(c:ellipse(31, 33, 2, 2)); leaf:add(c:ellipse(38, 30, 2, 2))
leaf:add(c:ellipse(40, 37, 2, 2)); leaf:add(c:ellipse(34, 43, 2, 2))
local p = c:build{
  { "cone", cone, GV.ramp("#f1ece0") },
  { "stripe", stripe, GV.ramp("#7ab55c"), { flat = true } },
  { "leaf", leaf, GV.ramp("#58a03e") },
  { "twist", twist, GV.ramp("#dcb06a") },
}
c:line({ {23,48}, {39,30} }, 2):each(function(x, y) if leaf:has(x, y) then c:px(x, y, "#2e5a2c") end end)
c:paint({ "f.....", ".f....", "..f...", "...f.." }, 29, 9, { f = "#a5663a" })
c:paint({ "..f", ".f.", "f.." , ".f."}, 33, 17, { f = "#a5663a" })
for _, x in ipairs({ 27, 33, 39 }) do c:fill(c:rect(x, 27, x + 1, 28), "#8c4a1a") end
c:seam({ {51, 27}, {34, 55} })
c:button(31, 22)
local t = c:save(O .. "aseprite/ph/kalette-seed.aseprite", O .. "png/ph/kalette-seed.png")
print(GV.report(t))
