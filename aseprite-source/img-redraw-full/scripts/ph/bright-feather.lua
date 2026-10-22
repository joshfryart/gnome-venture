local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local vane = c:poly({ {53,7}, {52,16}, {48,26}, {42,35}, {34,43}, {25,49}, {18,52}, {14,50},
                      {12,43}, {13,35}, {18,25}, {26,17}, {36,11}, {46,7} })
vane:cut(c:poly({ {52,21}, {43,26}, {50,30} }))   -- V notch
local quill = c:line({ {12,57}, {48,12} }, 3)
local p = c:build{
  { "vane",  vane,  GV.ramp("#b0bc66"), { gloss = { 22, 23 } } },
  { "quill", quill, GV.ramp("#58a03e"), { flat = true } },
}
local barbs = c:line({ {27,40}, {35,37} }, 2)
barbs:add(c:line({ {33,32}, {41,29} }, 2))
barbs:add(c:line({ {22,46}, {28,44} }, 2))
barbs:add(c:line({ {38,26}, {44,22} }, 2))
barbs:cut(quill)
c:fill(barbs:clip(vane), "#3e7a34")
local t = c:save(O .. "aseprite/ph/bright-feather.aseprite", O .. "png/ph/bright-feather.png")
print(GV.report(t))
