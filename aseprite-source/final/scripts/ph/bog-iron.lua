local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31,40,23,15)
body:add(c:ellipse(21,34,11,10)):add(c:ellipse(40,32,12,10)):add(c:ellipse(48,40,7,8))
body:add(c:rrect(9,42,54,54,5))
body:cut(c:rect(0,55,63,63))
local ridge = c:line({ {9,49},{14,47},{20,49},{26,47},{32,49},{38,47},{44,49},{50,47},{55,49} }, 3)
ridge:add(c:rect(0,51,63,55)):clip(body)
c:build{
  { "nugget", body, GV.ramp("#3f93b2"), { gloss = {20,29} } },
  { "ridge", ridge, GV.ramp("#6a6070"), { gloss = false } },
}
c:fill(c:rect(40,36,41,37), "#d0862a")
c:fill(c:rect(30,43,31,44), "#d0862a")
c:fill(c:line({ {17,39},{21,38},{25,39},{29,38},{33,39} }, 1), "#c8ecdc")
c:ground(31.5, 56, 22, 1.5)
local t = c:save(O .. "aseprite/ph/bog-iron.aseprite", O .. "png/ph/bog-iron.png")
print(GV.report(t))
