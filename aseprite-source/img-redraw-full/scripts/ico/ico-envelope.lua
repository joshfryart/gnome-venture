local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local body = c:rrect(8, 14, 55, 51, 4)
local flap = c:poly({ {9, 16}, {55, 16}, {32, 40} })
local p = c:build{
  { "envelope", body, GV.ramp("#f1e2bd", { pale = true }) },
  { "flap", flap, GV.ramp("#e9d29c"), { light = body, gloss = false } },
}
-- lower fold lines
c:fill(c:line({ {10, 49}, {23, 38} }, 2), "#d6bb82")
c:fill(c:line({ {53, 49}, {40, 38} }, 2), "#d6bb82")
c:build{
  { "seal", c:ellipse(32, 40, 7, 6.5), GV.ramp("#b8312a") },
  { "stamp", c:rrect(43, 19, 53, 31, 1), GV.ramp("#fff3c8", { pale = true }), { gloss = false, bounce = false } },
}
c:fill(c:rrect(46, 22, 50, 28, 1), "#6aa84f")
c:px(46, 22, "#a4cf7a"); c:px(47, 22, "#a4cf7a"); c:px(46, 23, "#a4cf7a")
c:seam({ {44, 20}, {52, 20}, {52, 30}, {44, 30}, {44, 20} }, { free = true })
c:paint({ ".mm.", "m..m", "m...", "m..m", ".mm." }, 31, 38, { m = "#e86a5c" })
local t = c:save(O .. "aseprite/ico/ico-envelope.aseprite", O .. "png/ico/ico-envelope.png")
print(GV.report(t))
