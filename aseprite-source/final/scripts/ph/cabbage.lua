-- ph/cabbage : pointed shield-shaped head with dark veins
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local N = "ph/cabbage"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local head = c:poly({
  {32,7}, {36,10}, {43,16}, {50,23}, {54,30}, {56,36}, {55,43}, {51,49}, {44,54}, {32,56},
  {20,54}, {13,49}, {9,43}, {8,36}, {10,30}, {14,23}, {21,16}, {28,10},
})
local p = c:build{
  { "head", head, "moss", { cres = 6, deep = 3, gloss = { 21, 21 } } },
}
local V = "#2f5a2a"
local function vein(pts, w) local m = c:line(pts, w or 2):clip(p.head.m:shrink(2)); c:fill(m, V) end
-- leaf-fold arc (overlapping outer leaf)
c:fill(c:line({ {13,34}, {18,30}, {25,27}, {32,26}, {39,27}, {45,29}, {51,32} }, 1):clip(p.head.m:shrink(1)), "#4a8a3e")
vein({ {32,15}, {32,52} })
vein({ {32,39}, {27,35}, {22,31} })
vein({ {32,31}, {37,26}, {41,22} })
vein({ {32,45}, {28,41}, {24,38} })
vein({ {33,47}, {38,42}, {43,39} })
c:ground(32, 57, 18, 2, "#8a4f2a")
local t = c:save(O .. "aseprite/" .. N .. ".aseprite", O .. "png/" .. N .. ".png")
print(GV.report(t))
