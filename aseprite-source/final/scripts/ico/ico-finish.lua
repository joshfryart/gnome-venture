local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local flag = c:rect(22, 13, 53, 36)
local checks = c:rect(22, 13, 32, 24)
checks:add(c:rect(43, 13, 53, 24))
checks:add(c:rect(33, 25, 42, 36))

c:build{
  { "pole",   c:rect(15, 12, 21, 54), GV.ramp("#c4925f") },
  { "flag",   flag,   "#f8eed2" },
  { "checks", checks, "#3a2e2a", { light = flag, contour = false, contact = false, gloss = false, rim = false } },
  { "cap",    c:ellipse(18, 9, 3, 3), "gold", { gloss = false } },
}
c:px(17, 8, GV.R.gold.gloss)
c:seam({ {24, 14}, {24, 35} }, { free = true })
c:ground(18, 55, 8, 1.5)
local t = c:save(O .. "aseprite/ico/ico-finish.aseprite", O .. "png/ico/ico-finish.png")
print(GV.report(t))
