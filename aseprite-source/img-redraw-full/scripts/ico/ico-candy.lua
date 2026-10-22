local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local pink = GV.ramp("#e89a8c")
local bodym = c:ellipse(31.5, 32, 14, 11)
local p = c:build{
  { "lwrap", c:poly({ {11,18}, {25,30}, {25,35}, {11,47} }), pink },
  { "rwrap", c:poly({ {53,18}, {39,30}, {39,35}, {53,47} }), pink },
  { "candy", bodym, GV.ramp("#d6322b") },
}
local stripe = c:line({ {22,25}, {41,40} }, 5):clip(bodym:shrink(1))
c:fill(stripe, "#fff3c8")
c:fill(c:line({ {16,23}, {16,42} }, 2):clip(p.lwrap.m:shrink(1)), "#dd3a2a")
c:fill(c:line({ {47,23}, {47,42} }, 2):clip(p.rwrap.m:shrink(1)), "#dd3a2a")
c:gloss(bodym, GV.ramp("#d6322b"), { 24, 25 })
local t = c:save(O .. "aseprite/ico/ico-candy.aseprite", O .. "png/ico/ico-candy.png")
print(GV.report(t))
