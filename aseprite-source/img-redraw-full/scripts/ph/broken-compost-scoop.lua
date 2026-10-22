local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local handle = c:line({ {37, 33}, {47, 52} }, 6)
handle:add(c:ellipse(47.5, 52, 3.5, 3))
handle:cut(c:poly({ {44, 44}, {49, 46}, {46, 48} }))       -- nick in the handle
local bowl = c:poly({ {8, 12}, {20, 9}, {32, 13}, {41, 23}, {41, 33}, {33, 41}, {22, 41}, {13, 33}, {9, 22} })
bowl:cut(c:poly({ {11, 30}, {16, 34}, {14, 38}, {10, 36} }))  -- chip left
local piece = c:poly({ {8, 42}, {12, 41}, {12, 46}, {8, 46} })

local p = c:build{
  { "handle", handle, "#b6814d" },
  { "bowl",   bowl,   "#8c4a1a" },
  { "piece",  piece,  "#8c4a1a", { flat = true } },
}
-- scoop hollow: darker inner dish
c:fill(c:poly({ {14, 16}, {22, 14}, {31, 18}, {36, 27}, {32, 35}, {23, 36}, {16, 29} }), "#6b3814")
-- handle highlight edge
c:fill(c:line({ {39, 37}, {45, 49} }, 1), "#f0d49a")
-- crack
c:fill(c:line({ {27, 12}, {31, 20}, {25, 27}, {31, 33}, {28, 40} }, 2), "#2a1a10")

local t = c:save(O .. "aseprite/ph/broken-compost-scoop.aseprite", O .. "png/ph/broken-compost-scoop.png")
print(GV.report(t))
