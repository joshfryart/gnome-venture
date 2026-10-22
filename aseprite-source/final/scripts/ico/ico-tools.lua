local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- wrench: ring head upper left, shaft to lower right
local wrench = c:ellipse(18, 19, 9, 9):add(c:line({ { 20, 22 }, { 46, 50 } }, 5))
wrench:add(c:ellipse(46, 50, 3.5, 3.5))
wrench:cut(c:ellipse(18, 19, 3.5, 3.5))
-- open jaw notch at top-left of the ring
wrench:cut(c:poly({ { 8, 12 }, { 14, 8 }, { 19, 17 }, { 17, 19 } }))
-- hammer handle lower left to upper right
local handle = c:line({ { 13, 51 }, { 41, 21 } }, 5)
-- hammer head: long rotated block across the handle tip
local head = c:poly({ { 32, 13 }, { 40, 5 }, { 57, 22 }, { 49, 30 } })
local p = c:build{
  { "wrench", wrench, "stone", { gloss = { 12, 21 } } },
  { "handle", handle, "wood", { gloss = false } },
  { "head", head, GV.ramp("#5b6470"), { gloss = { 39, 14 } } },
}
-- grip bands
c:fill(c:line({ { 17, 43 }, { 21, 47 } }, 2):clip(handle), "#8a4f2a")
c:fill(c:line({ { 21, 39 }, { 25, 43 } }, 2):clip(handle), "#8a4f2a")
local t = c:save(B .. "aseprite/ico/ico-tools.aseprite", B .. "png/ico/ico-tools.png")
print(GV.report(t))
