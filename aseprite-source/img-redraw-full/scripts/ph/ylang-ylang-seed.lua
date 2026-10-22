local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local env = c:rrect(20, 12, 44, 55, 3)
local flap = c:poly({ {20, 12}, {45, 12}, {32, 30} })
local win = c:rrect(24, 34, 40, 51, 5)
local seed = c:ellipse(32, 44, 5, 5)
local leaf = c:poly({ {33, 39}, {36, 34}, {40, 33}, {39, 37}, {35, 40} })
local p = c:build{
  { "env", env, GV.ramp("#f1ece0") },
  { "flap", flap, GV.ramp("#e6d9bd"), { gloss = { 24, 14 } } },
  { "win", win, GV.ramp("#f4f0e0"), { gloss = false, contour = "#dcb06a" } },
  { "seed", seed, GV.ramp("#dcb06a", { shade = "#a5663a" }) },
  { "leaf", leaf, GV.ramp("#58a03e"), { flat = true } },
}
c:fill(win:edge(), "#dcb06a")
c:fill(c:rect(32, 37, 32, 39), "#2e5a2c")
c:px(33, 38, "#2e5a2c")
c:seam({ {21, 14}, {31, 28} }); c:seam({ {43, 14}, {33, 28} })
c:button(30, 27)
c:ground(32, 56, 13, 1.5)
local t = c:save(O .. "aseprite/ph/ylang-ylang-seed.aseprite", O .. "png/ph/ylang-ylang-seed.png")
print(GV.report(t))
