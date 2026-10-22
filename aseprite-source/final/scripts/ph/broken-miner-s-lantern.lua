local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- hoop handle: ring on top
local hoop = c:ellipse(31.5, 11, 7, 6):cut(c:ellipse(31.5, 11, 4, 3)):cut(c:rect(0, 15, 63, 63))
hoop:add(c:rect(24, 11, 26, 16)); hoop:add(c:rect(37, 11, 39, 16))
-- glass with chipped upper-right corner
local glass = c:rrect(22, 22, 41, 49, 4):cut(c:poly({ {36, 21}, {42, 21}, {42, 29} }))
local wood = GV.ramp("#b6814d")
local p = c:build{
  { "hoop",  hoop, GV.ramp("#c4925f") },
  { "glass", glass, "gold" },
  { "flame", c:ellipse(31.5, 36, 6, 7), GV.ramp("#e8a317") },
  { "top",   c:rrect(20, 16, 43, 21, 3), wood },
  { "bot",   c:rrect(20, 50, 43, 55, 3), wood },
  { "brk",   c:poly({ {45, 50}, {51, 51}, {50, 55}, {45, 55} }), wood },
  { "chip",  c:poly({ {9, 45}, {14, 44}, {13, 48}, {9, 48} }), wood, { flat = true } },
}
-- inner flame core
c:fill(c:ellipse(31.5, 38, 2.5, 3), "#d0862a")
-- crack zigzag over glass
local crack = c:line({ {35, 23}, {38, 28}, {33, 34}, {37, 41}, {34, 48} }, 2):clip(glass:shrink(1))
c:fill(crack, "#2a1a10")
-- snapped stub on bottom cap right side
c:px(43, 52, "#2a1a10"); c:px(43, 53, "#2a1a10")

c:ground(31.5, 57, 13, 1.5)
local t = c:save(O .. "aseprite/ph/broken-miner-s-lantern.aseprite", O .. "png/ph/broken-miner-s-lantern.png")
print(GV.report(t))
