local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- jar body: wide rounded glass with short neck shoulders
local body = c:rrect(15, 21, 48, 55, 9)
body:add(c:rrect(19, 18, 44, 26, 3))
local lid = c:rrect(20, 9, 43, 17, 3)
local rim = c:rrect(18, 15, 45, 19, 2)

local p = c:build{
  { "body",  body,  GV.ramp("#fffaf0") },
  { "lid",   lid,   GV.ramp("#968f96") },
  { "rim",   rim,   GV.ramp("#8b8f96"), { gloss = false } },
  { "label", c:rrect(20, 33, 43, 49, 3), GV.ramp("#dcb06a"), { gloss = { 23, 36 } } },
}
-- lid ridges
for x = 23, 40, 4 do c:fill(c:rect(x, 11, x, 13), GV.ramp("#968f96").shade) end
c:seam({ {19, 17}, {44, 17} })
-- label: little red berry stamp
c:fill(c:ellipse(31.5, 42, 3.5, 3), "#dd3a2a")
c:px(30, 41, "#ff9158")
c:fill(c:rect(31, 37, 32, 38), "#4a8a3e")
-- glass glints on the right side
c:fill(c:rect(43, 26, 44, 30), "#fff3c8")
local t = c:save(O .. "aseprite/ico/ico-jar.aseprite", O .. "png/ico/ico-jar.png")
print(GV.report(t))
