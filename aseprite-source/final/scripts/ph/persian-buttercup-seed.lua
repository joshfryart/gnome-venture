local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local p = c:build{
  { "env",    c:rrect(20, 10, 44, 52, 2), "#f1ece0", { pale = true } },
  { "window", c:rrect(24, 31, 40, 47, 4), "#f08a24", { gloss = false } },
  { "pane",   c:rrect(26, 33, 38, 45, 3), "#f4f0e0", { pale = true, gloss = false, rim = false } },
  { "seed",   c:ellipse(32, 39.5, 4.5, 5), "#f08a24" },
  { "flap",   c:poly({{20,10},{45,10},{32,27}}), "#dcb06a" },
  { "seal",   c:ellipse(32, 26, 3), "#f08a24", { gloss = { 31, 25 } } },
}
c:part(c:ellipse(36, 34, 2, 1), "#58a03e", { flat = true, contact = false })
c:seam({ {21,11}, {31,24} }); c:seam({ {43,11}, {33,24} })
c:fill(c:rect(25, 49, 39, 50), "#dcb06a")
local t = c:save(O .. "aseprite/ph/persian-buttercup-seed.aseprite", O .. "png/ph/persian-buttercup-seed.png")
print(GV.report(t))
