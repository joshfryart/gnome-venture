local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- boat hull: flat-ish top, round belly, tail flicked up at the left
local body = c:ellipse(31, 41, 21, 12):cut(c:rect(0, 0, 63, 33))
body:add(c:poly({ {8, 30}, {22, 36}, {20, 44}, {11, 42} }))
body:add(c:ellipse(38, 40, 14, 9))
local head = c:ellipse(37, 20, 11, 11)
local wing = c:poly({ {16, 41}, {22, 38}, {34, 38}, {38, 42}, {34, 47}, {24, 48} })
local p = c:build{
  { "body", body, "gold" },
  { "head", head, "gold" },
  { "bill", c:rrect(45, 19, 57, 26, 3), GV.ramp("#d0862a") },
  { "wing", wing, GV.ramp("#d0862a"), { gloss = false } },
}
c:eye(34, 16, true)
local t = c:save(O .. "aseprite/ico/ico-duck.aseprite", O .. "png/ico/ico-duck.png")
print(GV.report(t))
