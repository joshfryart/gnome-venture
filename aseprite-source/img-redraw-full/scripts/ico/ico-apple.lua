local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local red = GV.ramp("#d6322b")
-- body: two overlapping lobes with a top notch and a dimple at the base
local body = c:ellipse(31.5, 37, 18, 16.5)
body:add(c:ellipse(24, 33, 11, 11)):add(c:ellipse(39, 33, 11, 11))
body:cut(c:ellipse(31.5, 18, 4, 3))      -- top notch
body:cut(c:ellipse(31.5, 56, 3, 2.5))    -- base dimple
local stem = c:line({ {31, 26}, {31, 19}, {33, 13} }, 3)
local leaf = c:poly({ {34, 20}, {37, 13}, {42, 9}, {48, 8}, {47, 13}, {43, 18}, {37, 21} })
local p = c:build{
  { "stem", stem, "wood", { flat = true } },
  { "body", body, red, { gloss = { 22, 27 } } },
  { "leaf", leaf, "moss" },
}
-- leaf vein
c:fill(c:line({ {37, 19}, {41, 15}, {45, 11} }, 1), "#4a8a3e")
local t = c:save(O .. "aseprite/ico/ico-apple.aseprite", O .. "png/ico/ico-apple.png")
print(GV.report(t))
