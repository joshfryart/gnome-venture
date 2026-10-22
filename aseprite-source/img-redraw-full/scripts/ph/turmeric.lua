local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leafL = c:poly({ {31, 22}, {27, 17}, {23, 11}, {24, 7}, {28, 10}, {32, 16}, {33, 22} })
local leafR = c:poly({ {31, 22}, {32, 16}, {36, 10}, {40, 7}, {41, 11}, {37, 17}, {34, 22} })
local root = c:poly({ {22, 23}, {42, 23}, {40, 35}, {36, 47}, {33, 57}, {31, 57}, {28, 47}, {24, 35} })
root:add(c:ellipse(32, 23.5, 10, 4.5))
local knob = c:ellipse(44, 31, 5, 3.5):add(c:poly({ {38, 29}, {44, 28}, {41, 36}, {37, 37} }))
c:build{
  { "leafL", leafL, GV.ramp("#58a03e"), { gloss = false } },
  { "leafR", leafR, GV.ramp("#58a03e"), { gloss = false } },
  { "knob", knob, GV.ramp("#f0b030"), { gloss = false } },
  { "root", root, GV.ramp("#f0b030"), { gloss = { 26, 26 } } },
}
c:line({ {30, 20}, {25, 9} }, 1)  -- placeholder removed below
-- leaf midribs
for _, p in ipairs({ {30,19},{29,17},{28,15},{27,13},{26,11} }) do c:px(p[1], p[2], "#2f5a2a") end
for _, p in ipairs({ {33,19},{34,17},{35,15},{36,13},{37,11} }) do c:px(p[1], p[2], "#2f5a2a") end
-- ring marks
local E = "#d0862a"
c:paint({ "eeee.ee" }, 26, 30, { e = E })
c:paint({ "ee.eee" }, 30, 39, { e = E })
c:paint({ "eee" }, 43, 30, { e = E })
c:paint({ "eee" }, 31, 48, { e = E })
local t = c:save(O .. "aseprite/ph/turmeric.aseprite", O .. "png/ph/turmeric.png")
print(GV.report(t))
