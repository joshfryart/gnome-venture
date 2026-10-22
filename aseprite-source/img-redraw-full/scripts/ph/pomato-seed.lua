local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cone = c:poly({ {14, 18}, {51, 18}, {35, 55}, {30, 55} })
cone:add(c:ellipse(32.5, 53, 2.5, 2))
cone = cone:closed(2)
local twist = c:ellipse(32.5, 17, 15, 4)
local earL = c:poly({ {13, 9}, {19, 12}, {22, 16}, {15, 17} })
local earR = c:poly({ {52, 9}, {46, 12}, {43, 16}, {50, 17} })
local fruit = c:ellipse(32, 35, 7, 7)
local p = c:build{
  { "earL", earL, GV.ramp("#f1ece0"), { gloss = false } },
  { "earR", earR, GV.ramp("#f1ece0"), { gloss = false } },
  { "cone", cone, GV.ramp("#f1ece0"), { gloss = { 19, 22 } } },
  { "twist", twist, GV.ramp("#dcb06a"), { gloss = false } },
  { "potato", fruit:copy():clip(c:rect(0, 0, 31, 63)), GV.ramp("#dcb06a"), { gloss = { 27, 31 } } },
  { "tomato", fruit:copy():clip(c:rect(32, 0, 63, 63)), "red", { gloss = { 35, 31 } } },
}
-- seeds peeking out of the twist
for _, d in ipairs({ {26,16},{32,14},{38,16} }) do
  c:fill(c:rect(d[1], d[2], d[1] + 1, d[2] + 1), "#7ab55c")
  c:px(d[1], d[2], "#c8d77a")
end
-- twist pleats
for _, x in ipairs({ 22, 28, 37, 43 }) do c:px(x, 18, "#b8661a"); c:px(x, 19, "#b8661a") end
-- spiral fold lines (avoid fruit)
local fold = c:line({ {18, 22}, {26, 27} }, 1):add(c:line({ {40, 43}, {34, 47} }, 1)):add(c:line({ {23, 43}, {30, 48} }, 1))
fold:cut(fruit:grow(1))
c:fill(fold, "#dcb06a")
-- split line, potato eyes, tomato specks
c:fill(c:rect(31, 29, 31, 41), "#4a2c1a")
c:px(28, 36, "#8a4f2a"); c:px(27, 39, "#8a4f2a")
c:px(35, 37, "#ffc27a")
-- leaf
c:paint({ ".l.", "lll", ".l." }, 30, 26, { l = "#6a9a3a" })
c:px(31, 26, "#a4b86a")
-- seam down right edge
c:seam({ {48, 22}, {37, 49} })
local t = c:save(O .. "aseprite/ph/pomato-seed.aseprite", O .. "png/ph/pomato-seed.png")
print(GV.report(t))
