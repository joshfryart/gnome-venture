local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cone = c:poly({ {14,57}, {51,57}, {38,24}, {27,13}, {20,13}, {19,26} })
local twist = c:rrect(19, 7, 27, 15, 2)
local earL = c:poly({ {14,6}, {20,9}, {20,13}, {15,11} })
local earR = c:poly({ {27,9}, {33,5}, {33,10}, {27,13} })
local band = c:poly({ {16,22}, {40,22}, {41,27}, {15,27} }):clip(cone)
local ring = c:ellipse(32, 42, 10.5)
local win = c:ellipse(32, 42, 8.5)
local seed = c:ellipse(32, 43, 6)
c:build{
  { "earL", earL, "#dcb06a", { flat = true } },
  { "earR", earR, "#dcb06a", { flat = true } },
  { "cone", cone, "#f1ece0", { light = cone } },
  { "twist", twist, "#dcb06a" },
  { "band", band, "#dcb06a", { gloss = false } },
  { "ring", ring, "#7a5cc0" },
  { "win", win, "#f4f0e0", { gloss = false } },
  { "seed", seed, GV.ramp("#7a5cc0", { shade = "#4e3a8a" }) },
}
c:fill(c:poly({ {36,35}, {41,33}, {40,36}, {37,37} }), "#58a03e")
c:seam({ {19,24}, {39,24} })
-- twist creases
c:px(22, 9, "#b8861a"); c:px(23, 11, "#b8861a"); c:px(24, 13, "#b8861a")
local t = c:save(O .. "aseprite/ph/petunia-seed.aseprite", O .. "png/ph/petunia-seed.png")
print(GV.report(t))
