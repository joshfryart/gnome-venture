local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- tapered pill bar: round top cap, narrowing to a round bottom
local bar = c:poly({ {25, 13}, {40, 13}, {37, 38}, {28, 38} })
bar:add(c:ellipse(32, 14, 7.5, 6))
bar:add(c:ellipse(32, 38, 4.5, 3.5))
local dot = c:ellipse(32, 50, 6.5, 6.5)

local red = GV.ramp("#9c2a1e")
c:build{
  { "bar", bar, red, { gloss = { 28, 11 } } },
  { "dot", dot, red },
}
local t = c:save(O .. "aseprite/ico/ico-exclaim.aseprite", O .. "png/ico/ico-exclaim.png")
print(GV.report(t))
