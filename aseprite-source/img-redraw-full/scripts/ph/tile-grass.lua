local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "scene" }
local O = D .. "img-redraw-full/"

c:fill(c:rect(0, 0, 63, 63), "#7ab55c")
-- soft lighter patch, upper right, two stepped tones
c:fill(c:ascii({
  "......xxxxxx......",
  "...xxxxxxxxxxxx...",
  ".xxxxxxxxxxxxxxxx.",
  "xxxxxxxxxxxxxxxxxx",
  "xxxxxxxxxxxxxxxxxx",
  ".xxxxxxxxxxxxxxxx.",
  "..xxxxxxxxxxxxxx..",
  "....xxxxxxxxxx....",
  ".......xxxx.......",
}, 37, 10), "#8fbf60")
c:fill(c:ascii({
  "...xxxxx...",
  ".xxxxxxxxx.",
  "xxxxxxxxxxx",
  ".xxxxxxxxx.",
  "...xxxx....",
}, 41, 12), "#a4b86a")

-- tufts: three blades, 5 px tall, base point given
local tuft = { "x...x", ".x.x.", ".x.x.", "..x..", ".xxx." }
local alt  = { "..x..", "x.x..", ".xx.x", ".xxx.", ".xxx." }
local pts = { {33,36}, {20,13}, {50,22}, {14,43}, {35,19}, {38,14}, {27,53}, {38,38} }
for i, p in ipairs(pts) do
  local rows = (i % 2 == 0) and alt or tuft
  c:paint(rows, p[1] - 2, p[2] - 4, { x = "#4a8a3e" })
end
-- dark specks
local sp = { {12,20,4}, {44,8,3}, {26,46,4}, {52,38,3}, {8,56,4}, {36,28,3} }
for _, s in ipairs(sp) do
  for k = 0, s[3] - 1 do c:px(s[1] + k, s[2], "#2f5a2a") end
end

local t = c:save(O .. "aseprite/ph/tile-grass.aseprite", O .. "png/ph/tile-grass.png")
print(GV.report(t))
