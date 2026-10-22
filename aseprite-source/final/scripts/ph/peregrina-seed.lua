local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local jar = c:rrect(17, 20, 47, 56, 6)
local neck = c:rrect(22, 14, 42, 22, 1)
local cork = c:rrect(24, 6, 40, 15, 2)
local p = c:build{
  { "jar", jar, "glass", { gloss = false } },
  { "neck", neck, "glass", { gloss = false } },
  { "cork", cork, "wood" },
  { "seed", c:ellipse(32, 42, 9, 9), "#3f93b2", { gloss = { 27, 37 } } },
  { "leaf", c:ellipse(39, 32.5, 3, 2), "#58a03e", { flat = true } },
}
c:fill(c:rect(31, 30, 32, 33), "#2e5a2c")
-- glass side shade
c:fill(c:rect(43, 27, 44, 51), "#8fcbd8")
-- label rib
c:fill(c:rect(19, 24, 45, 25), "#dcb06a")
-- vertical glint upper left
c:fill(c:rect(20, 28, 21, 35), "#fff1c8")
c:px(20, 38, "#fff1c8"); c:px(20, 39, "#fff1c8")
-- cork lines and seam at the cork join
c:px(28, 9, "#8a4f2a"); c:px(35, 11, "#8a4f2a"); c:px(31, 12, "#8a4f2a")
c:seam({ {24, 15}, {40, 15} }, { free = true })
local t = c:save(O .. "aseprite/ph/peregrina-seed.aseprite", O .. "png/ph/peregrina-seed.png")
print(GV.report(t))
