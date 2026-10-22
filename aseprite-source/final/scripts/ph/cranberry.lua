local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dark = GV.ramp("#a8241f")
local light = "red"
local r = 6.5
local leaf = c:poly({ {33,17}, {36,11}, {41,9}, {44,10}, {41,15}, {36,18} })
local p = c:build{
  { "stem", c:rect(31, 14, 33, 22), GV.ramp("#2e5a2c"), { flat = true } },
  { "leaf", leaf, "leaf", { gloss = false } },
  { "top",  c:ellipse(31.5, 27, r), light },
  { "m1",   c:ellipse(25, 37, r), dark },
  { "m2",   c:ellipse(38, 37, r), light },
  { "b1",   c:ellipse(18.5, 46, r), light },
  { "b2",   c:ellipse(31.5, 46, r), dark },
  { "b3",   c:ellipse(44.5, 46, r), light },
}
c:px(38, 14, GV.R.leaf.shade); c:px(39, 13, GV.R.leaf.shade)
-- blossom-end pits
for _, q in ipairs({ {34, 30}, {40, 40}, {21, 49}, {47, 49} }) do
  c:paint({ ".p.", "p.p" }, q[1] - 1, q[2], { p = "#6b1b2c" })
end
local t = c:save(O .. "aseprite/ph/cranberry.aseprite", O .. "png/ph/cranberry.png")
print(GV.report(t))
