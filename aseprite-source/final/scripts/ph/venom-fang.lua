local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local fang = c:poly({
  {16, 55}, {14, 47}, {15, 38}, {18, 29}, {22, 21}, {27, 13}, {32, 7}, {33, 8},
  {33, 15}, {33, 23}, {34, 31}, {36, 39}, {38, 47}, {37, 55},
})
fang:add(c:ellipse(26, 52, 11.5, 4))

local p = c:build{
  { "fang", fang, GV.ramp("#dcb06a"), { gloss = { 20, 27 } } },
}

-- bone-white venom groove down the left face
local g = c:line({ {19, 49}, {18, 41}, {19, 34}, {22, 27}, {26, 20} }, 3)
g:clip(p.fang.m:shrink(2))
c:fill(g, "#f1ece0")
-- three small tick marks
for y = 34, 38 do c:px(29, y, "#2a1a10") end
for y = 20, 23 do c:px(30, y, "#2a1a10") end
for y = 42, 46 do c:px(32, y, "#2a1a10") end

local t = c:save(O .. "aseprite/ph/venom-fang.aseprite", O .. "png/ph/venom-fang.png")
print(GV.report(t))
