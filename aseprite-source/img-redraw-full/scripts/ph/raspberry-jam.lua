local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local R = GV.R
local pink = GV.ramp("#e46a9b")
-- squat round-bellied jar with a short neck
local jar = c:ellipse(32, 40, 15, 14):add(c:rect(21, 22, 43, 30))
c:build{
  { "glass", jar, GV.ramp("#a9d6ea", { gloss = "#c8ecdc" }), { gloss = { 22, 31 } } },
  { "jam",   c:ellipse(32, 41, 12.5, 11.5):add(c:rect(23, 31, 41, 36)), pink, { contour = pink.deep, gloss = false } },
  { "label", c:rrect(21, 36, 43, 46, 2), "cream", { gloss = false, contact = false } },
  { "lid",   c:rrect(18, 14, 46, 24, 4), "gold" },
}
c:fill(c:rect(24, 31, 40, 31), pink.rim)
c:seam({ {20, 23}, {44, 23} })
c:button(21, 17)
-- leaf on lid
c:paint({ "..ll", ".lLl", "lLl.", "s..." }, 39, 10, { l = "#7ab55c", L = "#c8d77a", s = "#4a8a3e" })
-- raspberry cluster doodle on label
c:paint({
  "...g...",
  ".rrgrr.",
  "rOrsrrs",
  "rrsrrss",
  ".rrrrs.",
  "..rss..",
}, 29, 37, { r = R.red.base, s = R.red.deep, O = R.red.dot, g = "#4a8a3e" })
local t = c:save(O .. "aseprite/ph/raspberry-jam.aseprite", O .. "png/ph/raspberry-jam.png")
print(GV.report(t))
