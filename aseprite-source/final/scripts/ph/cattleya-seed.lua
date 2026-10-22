local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leaf = c:poly({ {33,10}, {37,6}, {42,6}, {40,9}, {35,11} }):add(c:ellipse(39, 7.5, 2.5, 1.5))
local env = c:rrect(21, 22, 42, 54, 2)
local flap = c:poly({ {21,22}, {43,22}, {32,36} })
local p = c:build{
  { "stem", c:rect(31, 7, 33, 12), "#2e5a2c", { flat = true } },
  { "leaf", leaf, "#58a03e", { gloss = false } },
  { "ball", c:ellipse(32, 18.5, 8, 7.5), "#e8a317" },
  { "env", env, "#f4f0e0", { stitch = false } },
  { "flap", flap, "#e6d6b4", { gloss = false } },
  { "seal", c:ellipse(32, 35, 3), "#dd3a2a", { gloss = { 31, 34 } } },
}
c:seam({ {23,24}, {31,34} }); c:seam({ {41,24}, {33,34} })
c:fill(c:line({ {25,44}, {38,44} }, 2), "#8c4a1a")
c:fill(c:line({ {25,49}, {34,49} }, 2), "#8c4a1a")
-- seed-ball dimples
local bs = GV.R.gold.shade
c:px(35, 19, bs); c:px(30, 20, bs); c:px(34, 15, bs)
local t = c:save(O .. "aseprite/ph/cattleya-seed.aseprite", O .. "png/ph/cattleya-seed.png")
print(GV.report(t))
