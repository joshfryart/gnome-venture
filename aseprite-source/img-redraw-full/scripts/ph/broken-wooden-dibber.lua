local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local shaftR = GV.ramp("#b6814d", { rim = "#f0d49a" })
local handR = GV.ramp("#8c4a1a")
local shaft = c:poly({ {28,24}, {37,24}, {42,41}, {40,44}, {38,42}, {35,45}, {33,40} })
local tip = c:poly({ {37,48}, {39,46}, {41,48}, {43,47}, {44,50}, {45,54}, {44,55} })
local hand = c:ellipse(27, 18, 9.5, 8)
hand:add(c:ellipse(32, 25, 6, 3.5))
hand:cut(c:poly({ {33,9}, {38,12}, {34,14} }))
local p = c:build{
  { "tip", tip, shaftR },
  { "shaft", shaft, shaftR },
  { "handle", hand, handR, { gloss = { 21, 13 } } },
}
c:part(c:line({ {46,34}, {49,37} }, 2), shaftR, { flat = true })
c:part(c:line({ {14,36}, {18,38} }, 2), shaftR, { flat = true })
local g = "#4a2c1a"
c:line({ {27,13}, {31,15} }, 1):each(function(x,y) c:px(x,y,g) end)
c:line({ {20,20}, {24,22} }, 1):each(function(x,y) c:px(x,y,g) end)
c:line({ {30,21}, {33,23} }, 1):each(function(x,y) c:px(x,y,g) end)
-- crack across shaft
c:line({ {34,31}, {37,34}, {34,37}, {37,40} }, 1):each(function(x,y) if p.shaft.m:has(x,y) then c:px(x,y,"#2a1a10") end end)
local t = c:save(O .. "aseprite/ph/broken-wooden-dibber.aseprite", O .. "png/ph/broken-wooden-dibber.png")
print(GV.report(t))
