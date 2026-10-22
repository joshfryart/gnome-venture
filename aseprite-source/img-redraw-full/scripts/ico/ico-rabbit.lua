local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local fur = GV.ramp("#b8d8d2")
local blue = GV.ramp("#3f93b2")
local ears = c:ellipse(25.5, 20, 4.5, 8.5):add(c:ellipse(38.5, 20, 4.5, 8.5))
local head = c:ellipse(32, 31.5, 10.5, 9.5)
local body = c:ellipse(32, 43, 12, 8.5)
local p = c:build{
  { "ears", ears, fur },
  { "tail", c:ellipse(44.5, 47, 3, 3), blue },
  { "body", body, fur },
  { "feet", c:ellipse(25.5, 50, 5, 2.5):add(c:ellipse(38.5, 50, 5, 2.5)), blue },
  { "head", head, fur },
}
c:fill(c:ellipse(25.5, 20.5, 1.5, 5.5):add(c:ellipse(38.5, 20.5, 1.5, 5.5)), "#f6b8cf")
c:paint({ ".pp", "ppp", "ppp", "ppp", "ppp", "ppp", "ppp", "ppp", "ppp", ".p." }, 24, 15, { p = "#e46a9b" })
c:paint({ "pp.", "ppp", "ppp", "ppp", "ppp", "ppp", "ppp", "ppp", "ppp", ".p." }, 37, 15, { p = "#e46a9b" })
c:fill(c:ellipse(25.5, 15.5, 0.6, 0.6), "#f6b8cf")
c:fill(c:ellipse(32, 45.5, 6.5, 4.5):cut(head), "#f8eed2")
c:fill(c:ellipse(32, 35.5, 5, 3.5), "#f8eed2")
c:eye(25, 27); c:eye(34, 27)
c:paint({ "nnn", ".n." }, 31, 33, { n = "#2a1a10" })
c:paint({ "m...m", ".m.m." }, 30, 36, { m = "#4a2c1a" })
c:paint({ "www", "...w" }, 19, 34, { w = "#4a2c1a" })
c:paint({ ".www", "w..." }, 42, 34, { w = "#4a2c1a" })
local t = c:save(O .. "aseprite/ico/ico-rabbit.aseprite", O .. "png/ico/ico-rabbit.png")
print(GV.report(t))
