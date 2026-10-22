local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local frill = c:poly({ {40,24}, {50,14}, {50,23}, {56,20}, {53,30}, {57,34}, {51,40}, {53,47}, {42,46} })
local hornL = c:poly({ {20,27}, {17,10}, {32,22} })
local hornR = c:poly({ {38,23}, {47,10}, {47,28} })
local head = c:ellipse(34, 36, 16, 15)
local snout = c:ellipse(19, 43, 11, 8)
local p = c:build{
  { "frill", frill, GV.ramp("#b8452f", { deep = "#6b1b2c" }) },
  { "hornL", hornL, GV.ramp("#f8eed2"), { gloss = false } },
  { "hornR", hornR, GV.ramp("#f8eed2"), { gloss = false } },
  { "head", head, GV.ramp("#e0501f") },
  { "snout", snout, GV.ramp("#e0501f"), { light = head:copy():add(snout), gloss = { 14, 39 } } },
}
c:fill(c:ellipse(12.5, 44.5, 1.5, 1.5), "#6b1b2c")
c:part(c:ellipse(36, 30, 5, 5), GV.ramp("#f8eed2"), { flat = true, contour = GV.C.umber })
c:eye(34, 28)
c:paint({ "u....u", ".uuuu." }, 15, 47, { u = "#6b1b2c" })
local t = c:save(O .. "aseprite/ico/ico-dragon.aseprite", O .. "png/ico/ico-dragon.png")
print(GV.report(t))
