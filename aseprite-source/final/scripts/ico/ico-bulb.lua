local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local Y = GV.ramp("#f2d45c", { gloss = "#fff1c8", shade = "#d0862a", deep = "#b8661a" })
local S = GV.ramp("#968f96", { shade = "#5b6470" })
local glass = c:ellipse(31.5, 25, 14.5):add(c:poly({{22,32},{42,32},{38,43},{26,43}}))
local p = c:build{
  { "glass", glass, Y },
  { "ring1", c:rrect(23, 41, 40, 46, 2), S },
  { "ring2", c:rrect(26, 47, 37, 51, 2), S, { gloss = false } },
}
c:line({{28,40},{28,31}}, 1):each(function(x,y) c:px(x,y,"#b8661a") end)
c:line({{35,40},{35,31}}, 1):each(function(x,y) c:px(x,y,"#b8661a") end)
c:line({{28,30},{29,28},{30,30},{31,28},{32,30},{33,28},{34,30},{35,28}}, 1):each(function(x,y) c:px(x,y,"#fff1c8") end)
c:paint({ "ssssssssssss" }, 26, 44, { s = "#5b6470" })
local t = c:save(O .. "aseprite/ico/ico-bulb.aseprite", O .. "png/ico/ico-bulb.png")
print(GV.report(t))
