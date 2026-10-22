local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local peach = GV.ramp("#f4936b")
local body = c:ellipse(25.5, 38, 17, 16.5):add(c:ellipse(38.5, 38, 17, 16.5))
body:add(c:ellipse(32, 44, 18, 11))
local stem = c:line({ {32, 24}, {32, 14} }, 4)
local lf = c:poly({ {34, 17}, {38, 11}, {44, 7}, {51, 6}, {49, 12}, {44, 16}, {38, 18} })
c:build{
  { "stem", stem, GV.ramp("#a27e55"), { flat = true } },
  { "leaf", lf, GV.ramp("#58a03e") },
  { "body", body, peach },
}
-- cleft
c:line({ {32, 23}, {30, 30}, {29, 38}, {30, 46}, {32, 53} }, 2)
c:fill(c:line({ {32, 23}, {30, 30}, {29, 38}, {30, 46}, {32, 53} }, 2):clip(body), "#c4502f")
c:fill(c:line({ {33, 25}, {31, 31}, {30, 38}, {31, 45}, {33, 51} }, 1):clip(body), "#ffc27a")
-- midrib
c:fill(c:line({ {37, 15}, {49, 8} }, 1), "#4a8a3e")
local t = c:save(O .. "aseprite/ico/ico-peach.aseprite", O .. "png/ico/ico-peach.png")
print(GV.report(t))
