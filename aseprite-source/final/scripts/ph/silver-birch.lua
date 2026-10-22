local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local trunk = c:rrect(29, 36, 35, 55, 2)
trunk:add(c:poly({ {26, 56}, {38, 56}, {35, 50}, {29, 50} }))
local crown = c:ellipse(32, 23, 17, 14)
local left = c:ellipse(18, 29, 8, 7)
local right = c:ellipse(45, 20, 7, 6.5)

local p = c:build{
  { "trunk", trunk, GV.ramp("#d9c9a0", { gloss = "#fff3c8", rim = "#f0d49a" }), { gloss = false } },
  { "crown", crown, GV.ramp("#58a03e"), { gloss = { 22, 14 } } },
  { "left",  left,  "moss" },
  { "right", right, GV.ramp("#2e5a2c") },
}
-- bark dashes on the trunk
c:fill(c:rect(30, 40, 32, 40), "#2a1a10")
c:fill(c:rect(32, 45, 34, 45), "#2a1a10")
c:fill(c:rect(30, 50, 32, 50), "#2a1a10")
-- canopy crease
c:fill(c:line({ {26, 31}, {32, 29}, {38, 30} }, 1):clip(p.crown.m), "#2f5a2a")
c:ground(32, 57, 10, 1.5)

local t = c:save(O .. "aseprite/ph/silver-birch.aseprite", O .. "png/ph/silver-birch.png")
print(GV.report(t))
