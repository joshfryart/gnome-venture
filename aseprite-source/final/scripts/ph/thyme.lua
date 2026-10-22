local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leaf = c:ellipse(31.5, 36, 20, 18)
leaf:add(c:poly({ {32, 7}, {12, 34}, {52, 34} }))
leaf:add(c:poly({ {32, 7}, {20, 22}, {16, 30}, {48, 30}, {44, 22} }))
c:build{
  { "leaf", leaf, "moss", { gloss = { 21, 21 } } },
}
local V = GV.R.moss.deep
local function vein(pts) c:fill(c:line(pts, 2):clip(leaf:shrink(3)), V) end
vein({ {31, 15}, {31, 51} })
vein({ {31, 40}, {20, 31} })
vein({ {32, 31}, {41, 22} })
vein({ {31, 47}, {22, 40} })
local t = c:save(O .. "aseprite/ph/thyme.aseprite", O .. "png/ph/thyme.png")
print(GV.report(t))
