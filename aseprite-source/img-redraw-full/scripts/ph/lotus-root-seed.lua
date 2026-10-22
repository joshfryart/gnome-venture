local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local green = GV.ramp("#58a03e")
local lsprout = c:poly({ {31, 15}, {25, 6}, {21, 8}, {24, 15}, {29, 18} })
local rsprout = c:poly({ {33, 15}, {39, 5}, {43, 7}, {40, 15}, {35, 18} })
local root = c:poly({ {22, 15}, {42, 15}, {38, 34}, {26, 34} })
root:add(c:ellipse(32, 15.5, 10, 3))
local p = c:build{
  { "lsprout", lsprout, green, { flat = true } },
  { "rsprout", rsprout, green, { flat = true } },
  { "root",  root, "petal", { gloss = { 25, 18 } } },
  { "body",  c:rrect(12, 36, 52, 57, 3), "#8b8f96" },
  { "lid",   c:rrect(10, 27, 54, 37, 3), GV.ramp("#c9c5bc"), { gloss = { 14, 30 } } },
}
-- lotus root holes
c:fill(c:rect(27, 20, 28, 21), "#2a1a10"); c:fill(c:rect(35, 20, 36, 21), "#2a1a10")
c:fill(c:rect(31, 23, 32, 24), "#2a1a10")
-- sprout veins
c:px(26, 10, "#2e5a2c"); c:px(28, 13, "#2e5a2c"); c:px(39, 9, "#2e5a2c"); c:px(37, 12, "#2e5a2c")
-- hinge pin
c:fill(c:rect(49, 29, 50, 35), "#5b6470")
-- body ridges
c:fill(c:rect(16, 45, 48, 45), "#6c7078"); c:fill(c:rect(16, 50, 48, 50), "#6c7078")
c:seam({ {14, 38}, {50, 38} })
c:button(30, 35)
local t = c:save(O .. "aseprite/ph/lotus-root-seed.aseprite", O .. "png/ph/lotus-root-seed.png")
print(GV.report(t))
