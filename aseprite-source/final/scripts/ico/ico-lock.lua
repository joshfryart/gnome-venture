local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- U shackle: outer arch minus inner arch
local outer = c:ellipse(31.5, 25, 14.5, 14):add(c:rect(17, 25, 46, 32))
local inner = c:ellipse(31.5, 25, 9.5, 9):add(c:rect(22, 25, 41, 32))
outer:cut(inner)
outer:cut(c:rect(0, 0, 63, 10))
local body = c:rrect(12, 28, 51, 56, 5)
local p = c:build{
  { "shackle", outer, "stone" },
  { "body", body, GV.ramp("#dcb06a"), { gloss = { 16, 33 } } },
}
-- keyhole
c:fill(c:ellipse(31.5, 39, 4.5, 4.5), "#2a1a10")
c:fill(c:poly({ {30, 42}, {34, 42}, {35, 51}, {29, 51} }), "#2a1a10")
c:fill(c:rect(30, 37, 30, 38), "#4a2c1a")
c:fill(c:rect(18, 31, 45, 32), "#f5cf6a")
local t = c:save(O .. "aseprite/ico/ico-lock.aseprite", O .. "png/ico/ico-lock.png")
print(GV.report(t))
