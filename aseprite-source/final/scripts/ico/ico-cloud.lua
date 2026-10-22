local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cl = GV.ramp("#dfe8ec")
local whole = c:ellipse(21, 36, 10):add(c:ellipse(33.5, 29, 13)):add(c:ellipse(46, 37, 9)):add(c:rrect(10, 38, 55, 48, 6))
c:build{ { "cloud", whole, cl, { gloss = { 26, 20 } } } }
-- inner contours: upper arcs of the side bumps where they cross the centre bump
local C = c:ellipse(33.5, 29, 13):shrink(1)
local function arc(cx, cy, r, hex)
  local e = c:ellipse(cx, cy, r):edge()
  e:clip(C); e:cut(c:rect(0, cy + 1, 63, 63))
  e:each(function(x, y) c:px(x, y, hex) end)
end
arc(21, 36, 10, "#4a2c1a")
arc(46, 37, 9, "#2a1a10")
local t = c:save(O .. "aseprite/ico/ico-cloud.aseprite", O .. "png/ico/ico-cloud.png")
print(GV.report(t))
