local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- hook: thick ring arc (upper part) plus a descending tail
local outer = c:ellipse(31.5, 23, 13, 12)
local inner = c:ellipse(31.5, 23, 5, 4.5)
local ring = outer:copy():cut(inner)
-- remove lower-left quadrant of the ring to open the hook
ring:cut(c:poly({ {14, 25}, {31, 25}, {31, 40}, {14, 40} }))
-- round cap on the left end
ring:add(c:ellipse(22.5, 25, 4, 3))
-- tail down from the right side
local tail = c:rrect(28, 30, 36, 42, 3)
ring:add(tail)
ring:cut(c:rect(0, 43, 63, 63))

local dot = c:ellipse(31.5, 51.5, 5.5, 5.5)

c:build{
  { "hook", ring, GV.ramp("#3f93b2") },
  { "dot",  dot,  GV.ramp("#3f93b2") },
}

local t = c:save(O .. "aseprite/ico/ico-question.aseprite", O .. "png/ico/ico-question.png")
print(GV.report(t))
