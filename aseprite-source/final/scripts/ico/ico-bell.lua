local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- dome: rounded cap flaring into a skirt
local body = c:ellipse(31.5, 25, 12.5, 11):cut(c:rect(0, 26, 63, 63))
body:add(c:poly({ { 19, 25 }, { 45, 25 }, { 46, 32 }, { 49, 38 }, { 52, 42 }, { 12, 42 }, { 15, 38 }, { 18, 32 } }))
local p = c:build{
  { "clapper", c:ellipse(31.5, 48, 4.5, 4.5), GV.ramp("#b8893f"), { gloss = { 29, 47 } } },
  { "body",    body, GV.ramp("#dcb06a"), { light = body:copy():add(c:rect(12, 40, 52, 45)) } },
  { "rim",     c:rrect(12, 40, 52, 45, 2), "gold", { gloss = { 15, 41 } } },
  { "nub",     c:ellipse(31.5, 13, 3, 2.5), GV.ramp("#d0862a"), { gloss = false } },
}
c:seam({ { 15, 41 }, { 49, 41 } })
local t = c:save(O .. "aseprite/ico/ico-bell.aseprite", O .. "png/ico/ico-bell.png")
print(GV.report(t))
