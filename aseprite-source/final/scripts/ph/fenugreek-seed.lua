local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- cone: wide rounded bottom, narrowing up
local cone = c:poly({ {13,52}, {51,52}, {38,18}, {26,18} })
cone:add(c:rrect(13, 44, 51, 56, 5))
cone:cut(c:rect(0, 57, 63, 63))

-- twisted pigtail tip, leaning right
local tip = c:poly({ {27,20}, {37,20}, {36,13}, {29,13} })
tip:add(c:ellipse(33, 11, 3, 2.5))
tip:add(c:line({ {34,10}, {38,7}, {41,8} }, 3))

local leaf = c:poly({ {32,30}, {38,36}, {39,42}, {36,49}, {32,53}, {28,49}, {25,42}, {26,36} })

local p = c:build{
  { "cone",  cone, "#f1ece0", { pale = true } },
  { "tip",   tip, "#dcb06a" },
  { "label", c:ellipse(32, 42, 11, 10), "#f4f0e0", { pale = true, gloss = false } },
  { "leaf",  leaf, "#58a03e", { gloss = { 28, 36 } } },
}
-- fold crease on the left of the cone
c:fill(c:line({ {20,55}, {28,24} }, 2):cut(c:ellipse(32, 42, 12, 11)), "#dcb06a")
-- veins
c:fill(c:line({ {32,33}, {32,51} }, 2), "#2e5a2c")
c:fill(c:line({ {32,40}, {28,37} }, 1), "#2e5a2c")
c:fill(c:line({ {33,40}, {36,37} }, 1), "#2e5a2c")
c:fill(c:line({ {32,46}, {28,43} }, 1), "#2e5a2c")
c:fill(c:line({ {33,46}, {36,43} }, 1), "#2e5a2c")

c:seam({ {27,20}, {37,20} })
c:button(30, 22)
-- seed dots peeking along the bottom hem
for _, x in ipairs({ 22, 41 }) do c:paint({ "ss", "ss" }, x, 53, { s = "#8c4a1a" }) end

local t = c:save(O .. "aseprite/ph/fenugreek-seed.aseprite", O .. "png/ph/fenugreek-seed.png")
print(GV.report(t))
