local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local ribbon = c:rect(28, 22, 36, 56)
ribbon:add(c:rect(12, 41, 52, 46))
local loopL = c:ellipse(22, 14, 9, 7)
local loopR = c:ellipse(42, 14, 9, 7)

local p = c:build{
  { "box",    c:rect(12, 30, 52, 56), "red" },
  { "lid",    c:rrect(9, 22, 55, 32, 1), GV.ramp("#e8553a") },
  { "ribbon", ribbon, "gold" },
  { "loopL",  loopL, GV.ramp("#f5c45a") },
  { "loopR",  loopR, GV.ramp("#f5c45a") },
  { "knot",   c:ellipse(32, 17, 5, 5), "wood" },
}
-- hollow loop centres
c:fill(c:ellipse(23, 15, 4, 3), "#b8661a")
c:fill(c:ellipse(24, 16, 3, 2), "#7a3a14")
c:fill(c:ellipse(41, 15, 4, 3), "#b8661a")
c:fill(c:ellipse(40, 16, 3, 2), "#7a3a14")

c:seam({ {12, 33}, {52, 33} })
c:button(30, 15)

local t = c:save(O .. "aseprite/ico/ico-gift.aseprite", O .. "png/ico/ico-gift.png")
print(GV.report(t))
