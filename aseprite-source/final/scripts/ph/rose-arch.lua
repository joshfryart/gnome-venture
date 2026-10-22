local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local post = GV.ramp("#8c4a1a")
local rail = GV.ramp("#c4925f", { rim = "#f0d49a" })
c:build{
  { "p1", c:rrect(11, 12, 16, 55, 1), post, { gloss = false } },
  { "p2", c:rrect(29, 12, 34, 55, 1), post, { gloss = false } },
  { "p3", c:rrect(47, 12, 52, 55, 1), post, { gloss = false } },
  { "r1", c:rrect(7, 20, 56, 26, 3), rail, { gloss = { 12, 22 } } },
  { "r2", c:rrect(7, 38, 56, 44, 3), rail },
}
-- post caps: small cut tops read as stakes
c:button(30, 22)
local t = c:save(O .. "aseprite/ph/rose-arch.aseprite", O .. "png/ph/rose-arch.png")
print(GV.report(t))
