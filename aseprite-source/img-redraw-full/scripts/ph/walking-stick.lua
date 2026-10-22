local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local shaft = c:line({ {21, 54}, {39, 17} }, 6)
shaft:add(c:ellipse(21.5, 54, 3, 3))
local twig = c:line({ {26, 42}, {18, 38} }, 4)
twig:add(c:ellipse(18, 38, 2, 2))
local knob = c:ellipse(41.5, 13, 6.5, 6.5)
local p = c:build{
  { "twig",  twig,  GV.ramp("#c4925f"), { flat = true } },
  { "shaft", shaft, "wood" },
  { "knob",  knob,  GV.ramp("#8c4a1a"), { gloss = { 38, 9 } } },
}
-- cut end of the twig
c:px(17, 37, "#8a4f2a"); c:px(17, 38, "#8a4f2a"); c:px(18, 37, "#ecc58a")
-- woodgrain bands
c:paint({ "gggg" }, 29, 32, { g = "#8a4f2a" })
c:paint({ "ggg" }, 33, 24, { g = "#8a4f2a" })
-- blunt dark tip
c:paint({ "dddd", ".dd." }, 19, 56, { d = "#5e2f1e" })
c:ground(31.5, 58, 15, 2, "#6a4528")
local t = c:save(O .. "aseprite/ph/walking-stick.aseprite", O .. "png/ph/walking-stick.png")
print(GV.report(t))
