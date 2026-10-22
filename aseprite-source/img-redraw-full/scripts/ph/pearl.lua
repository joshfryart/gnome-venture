local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local disc = c:ellipse(31.5, 31.5, 16.5, 16.5)
local p = c:build{
  { "pearl", disc, GV.ramp("#f4f0e0", { shade = "#d9d0b8", deep = "#b8a888" }), { gloss = { 23, 23 } } },
}
-- sage sheen crescent on the left rim (inside the 1px rim), lower-left half
local sage = disc:shrink(1):cut(disc:shift(4, 0)):clip(c:rect(0, 30, 31, 63))
c:fill(sage, "#c8d9b0")
local t = c:save(O .. "aseprite/ph/pearl.aseprite", O .. "png/ph/pearl.png")
print(GV.report(t))
