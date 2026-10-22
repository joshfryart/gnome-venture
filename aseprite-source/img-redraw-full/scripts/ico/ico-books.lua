local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local pg = GV.ramp("#f8eed2")
local p = c:build{
  { "botPg", c:rect(50, 44, 55, 53), pg },
  { "bot", c:rrect(7, 41, 51, 55, 2), "#3f8fb0" },
  { "midPg", c:rect(9, 28, 14, 37), pg },
  { "mid", c:rrect(13, 25, 57, 39, 2), "#7ab55c" },
  { "topPg", c:rect(50, 12, 55, 21), pg },
  { "top", c:rrect(7, 9, 51, 23, 2), "#dd3a2a" },
}
-- page lines on page blocks
for _, y in ipairs({ 14, 17, 20 }) do c:fill(c:rect(52, y, 54, y), "#e0c890") end
for _, y in ipairs({ 30, 33, 36 }) do c:fill(c:rect(10, y, 12, y), "#e0c890") end
for _, y in ipairs({ 46, 49, 52 }) do c:fill(c:rect(52, y, 54, y), "#e0c890") end
-- spine bands
c:seam({ {45, 10}, {45, 22} })
c:seam({ {19, 26}, {19, 38} })
c:seam({ {45, 42}, {45, 54} })
local t = c:save(O .. "aseprite/ico/ico-books.aseprite", O .. "png/ico/ico-books.png")
print(GV.report(t))
