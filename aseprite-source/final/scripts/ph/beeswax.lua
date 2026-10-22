local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local drop = c:ellipse(31.5, 43, 17, 13)
drop:add(c:poly({ {31,9},{33,9},{44,26},{48,36},{15,36},{19,26} }))
drop:add(c:poly({ {30,10},{34,10},{47,33},{16,33} }))
local ramp = GV.ramp("#f2d488", { pale = true, gloss = "#fff3c8", dot = "#ffffff", rim = "#f5b860", shade = "#d0862a" })
local p = c:build{
  { "drop", drop, ramp, { gloss = {23, 24} } },
}
-- pooled base ring
local ring = c:ellipse(31.5, 48, 11, 3.5):cut(c:ellipse(31.5, 47.5, 9, 2))
c:fill(ring, "#a5663a")
-- stamp diamond
c:paint({ ".bb.", "bbbb", "bbbb", ".bb." }, 30, 36, { b = "#b07a45" })
local t = c:save(O .. "aseprite/ph/beeswax.aseprite", O .. "png/ph/beeswax.png")
print(GV.report(t))
