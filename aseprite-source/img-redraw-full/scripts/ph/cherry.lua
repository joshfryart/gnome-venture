local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local stems = c:line({ {22, 36}, {23, 29}, {26, 21}, {30, 14}, {32, 11} }, 2)
stems:add(c:line({ {42, 38}, {41, 30}, {38, 21}, {34, 14}, {32, 11} }, 2))
local leaf = c:poly({ {33, 12}, {36, 8}, {41, 5}, {48, 5}, {46, 10}, {40, 14} })
local left = c:ellipse(21.5, 44, 11, 11)
local right = c:ellipse(42.5, 46, 10, 10)
right:cut(left:grow(1))

c:build{
  { "stems", stems, "#2f5a2a", { flat = true } },
  { "leaf", leaf, "#7ab55c", { gloss = false } },
  { "left", left, "#d6322b" },
  { "right", right, "#dd3a2a" },
}
-- leaf vein
for _, p in ipairs({ {35, 11}, {36, 10}, {37, 10}, {38, 9}, {39, 8}, {40, 8}, {41, 7}, {42, 7}, {43, 6} }) do
  c:px(p[1], p[2], "#2f5a2a")
end
-- dimples
c:paint({ "ddd", ".d." }, 21, 34, { d = "#6b1b2c" })
c:paint({ "ddd", ".d." }, 41, 37, { d = "#6b1b2c" })

c:ground(32, 56, 18, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/cherry.aseprite", D .. "img-redraw-full/png/ph/cherry.png")
print(GV.report(t))
