-- ph/garden-gate-cross : plus-shaped picket junction, bleeds all edges
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon", bleed = "lrtb" }
local cream = GV.ramp("#f4f0e0")
local grey  = GV.ramp("#968f96")

local rails = c:rect(28, 0, 31, 63):add(c:rect(35, 0, 38, 63))
rails:add(c:rect(0, 28, 63, 31)):add(c:rect(0, 35, 63, 38))

local pick = c:rect(25, 0, 41, 22):add(c:rect(25, 44, 41, 63))
pick:add(c:rect(0, 25, 22, 41)):add(c:rect(44, 25, 63, 41))
local post = c:rrect(24, 24, 42, 42, 4)
c:build{
  { "rails", rails, grey, { gloss = false } },
  { "pick",  pick,  cream, { gloss = false } },
  { "post",  post,  GV.ramp("#d6c9b6") },
}
-- post cap: inner raised top
c:part(c:rrect(28, 27, 38, 37, 2), cream, { gloss = { 30, 29 } })
-- picket divisions: 1 px gaps in the cream run, with pointed slat tips toward the post
local gap = GV.ramp("#f4f0e0").shade
for _, y in ipairs({ 5, 11, 17, 49, 55, 61 }) do c:fill(c:rect(27, y, 39, y), gap) end
for _, x in ipairs({ 5, 11, 17, 49, 55, 61 }) do c:fill(c:rect(x, 27, x, 39), gap) end
c:seam({ {33, 1}, {33, 21} }); c:seam({ {33, 45}, {33, 62} })
c:seam({ {1, 33}, {21, 33} }); c:seam({ {45, 33}, {62, 33} })
c:seam({ {29, 39}, {37, 39} })
local t = c:save(O .. "aseprite/ph/garden-gate-cross.aseprite", O .. "png/ph/garden-gate-cross.png")
print(GV.report(t))
