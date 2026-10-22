local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- kidney nut: hanging C-curl with a notch bite on the right
local nut = c:ellipse(30, 42, 11, 11)
nut:add(c:ellipse(37, 50, 8, 5))
nut:cut(c:ellipse(42, 40, 6.5, 5.5))
nut:cut(c:rect(0, 0, 63, 27))
local cap = c:ellipse(32.5, 23, 13, 10)
local stem = c:rrect(31, 8, 34, 15, 1)
local p = c:build{
  { "nut",  nut,  GV.ramp("#dcb06a") },
  { "stem", stem, "moss", { flat = true } },
  { "cap",  cap,  "red", { gloss = {25,18} } },
}
-- leaf nub on the stem
c:fill(c:poly({{35,9},{40,7},{38,11}}), "#7ab55c")
-- nut crease
c:fill(c:line({{24,44},{27,48},{32,50},{37,49},{40,47}}, 1):clip(p.nut.m:shrink(1)), "#8a4f2a")
local t = c:save(O .. "aseprite/ph/cashew.aseprite", O .. "png/ph/cashew.png")
print(GV.report(t))
