local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local tan = GV.ramp("#c78b45")
local lite = GV.ramp("#dcb06a")
local face = GV.ramp("#ecc27c")
-- syrup: pool on the top face plus drips of different lengths
local syr = c:ellipse(31.5, 25, 13, 4)
syr:add(c:rrect(14, 25, 16, 33, 1))
syr:add(c:rrect(23, 26, 25, 37, 1))
syr:add(c:rrect(37, 26, 39, 31, 1))
syr:add(c:rrect(44, 25, 46, 41, 1))
syr:add(c:ellipse(45, 41, 2, 2))
syr:add(c:ellipse(24, 37, 1.5, 1.5))
c:build{
  { "bottom", c:rrect(11, 41, 52, 51, 5), tan },
  { "middle", c:rrect(13, 32, 50, 42, 5), lite },
  { "top",    c:rrect(12, 23, 51, 33, 5), tan },
  { "face",   c:ellipse(31.5, 26, 19, 4.5), face, { cres = 2, deep = 1 } },
  { "syrup",  syr, GV.ramp("#c0601a"), { gloss = { 20, 25 } } },
  { "butter", c:rrect(25, 14, 38, 24, 2), GV.ramp("#f2cf4a") },
}
local t = c:save(O .. "aseprite/ico/ico-pancakes.aseprite", O .. "png/ico/ico-pancakes.png")
print(GV.report(t))
