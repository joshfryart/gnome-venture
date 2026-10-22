local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wood = GV.ramp("#b6814d")
local frame = c:rrect(15, 8, 19, 26, 2)
frame:add(c:rrect(45, 8, 49, 26, 2))
frame:add(c:line({ {16,24}, {18,28}, {21,31}, {25,33}, {39,33}, {43,31}, {46,28}, {48,24} }, 4))
local p = c:build{
  { "handle", c:rrect(29, 31, 34, 56, 2), wood },
  { "frame",  frame, wood, { gloss = { 16, 12 } } },
  { "tine",   c:rrect(30, 8, 34, 34, 2), wood, { gloss = false } },
}
-- lit edge strip on each prong
for y = 10, 23 do c:px(16, y, "#f0d49a"); c:px(46, y, "#f0d49a"); c:px(31, y, "#f0d49a") end
c:seam({ {26, 36}, {38, 36} })
local t = c:save(O .. "aseprite/ph/broadfork.aseprite", O .. "png/ph/broadfork.png")
print(GV.report(t))
