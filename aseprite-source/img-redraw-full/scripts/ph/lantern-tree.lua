local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local trunk = c:rrect(28, 36, 35, 51, 1):add(c:poly({{26,52},{38,52},{36,48},{28,48}}))
local canopy = c:ellipse(32.5, 27, 15, 14)
local light = c:ellipse(23, 31, 8, 7.5)
local dark = c:ellipse(42, 22, 6.5, 6)
c:build{
  { "trunk", trunk, "wood" },
  { "canopy", canopy, GV.ramp("#58a03e"), { gloss = {26, 17} } },
  { "light", light, GV.ramp("#7ab55c"), { gloss = false } },
  { "dark", dark, GV.ramp("#2f5a2a"), { gloss = false } },
  { "lan1", c:rrect(28, 35, 32, 40, 1), GV.ramp("#f5cf6a"), { flat = true } },
  { "lan2", c:rrect(40, 31, 44, 36, 1), GV.ramp("#f5cf6a"), { flat = true } },
}
c:px(30, 34, "#4a2c1a"); c:px(31, 34, "#4a2c1a"); c:px(30, 33, "#4a2c1a")
c:px(41, 30, "#4a2c1a"); c:px(42, 30, "#4a2c1a"); c:px(41, 29, "#4a2c1a")
c:paint({ "gg" }, 29, 37, { g = "#fff1c8" })
c:paint({ "gg" }, 41, 33, { g = "#fff1c8" })
c:ground(31.5, 52, 10, 1.5)
local t = c:save(O .. "aseprite/ph/lantern-tree.aseprite", O .. "png/ph/lantern-tree.png")
print(GV.report(t))
