local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cone = c:poly({ {13, 27}, {51, 27}, {34, 58}, {30, 58} })
local p = c:build{
  { "leaf", c:ellipse(39, 7, 5, 2.5), "#58a03e", { flat = true } },
  { "stem", c:rect(31, 7, 33, 14), "#2e5a2c", { flat = true } },
  { "seed", c:ellipse(32, 19, 9, 8), "#f08a24" },
  { "cone", cone, "cream" },
  { "twist", c:poly({ {16, 23}, {48, 23}, {45, 31}, {19, 31} }):add(c:rrect(16, 22, 48, 26, 2)), "#dcb06a" },
}
-- pinch folds on the twist
c:line({ {22, 24}, {24, 29} }, 1); c:fill(c:line({ {22, 24}, {24, 29} }, 1), "#a5663a")
c:fill(c:line({ {41, 24}, {39, 29} }, 1), "#a5663a")
-- diagonal fold line down the cone
c:fill(c:line({ {22, 33}, {33, 53} }, 2):clip(p.cone.m), "#dcb06a")
c:seam({ {25, 33}, {35, 51} })
c:button(30, 24)
local t = c:save(O .. "aseprite/ph/snowdrop-seed.aseprite", O .. "png/ph/snowdrop-seed.png")
print(GV.report(t))
