local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local ball = c:ellipse(31.5, 35.5, 15.5, 15.5)
local leaf = c:poly({ {32, 20}, {36, 13}, {43, 9}, {48, 9}, {46, 14}, {40, 19}, {34, 22} })
local orng = GV.ramp("#f08a24", { shade = "#e0501f" })
local p = c:build{
  { "leaf", leaf, "moss", { gloss = false } },
  { "body", ball, orng },
}
-- stem nub
c:part(c:rect(30, 18, 33, 21), GV.ramp("#2f5a2a"), { flat = true })
-- leaf vein
c:fill(c:line({ {37, 16}, {45, 11} }, 1), "#4a8a3e")
-- cut wedge: lower-right quarter showing flesh, 2 px rind kept on the arc
local cx, cy = 34, 38
local flesh = ball:shrink(2):clip(c:rect(cx, cy, 63, 63))
c:part(flesh, GV.ramp("#ffc27a"), { gloss = false, rim = false, cres = 2, deep = 1 })

local seg = "#f2793a"
c:fill(c:line({ {cx, cy}, {cx + 13, cy + 5} }, 1):clip(flesh), seg)
c:fill(c:line({ {cx, cy}, {cx + 5, cy + 13} }, 1):clip(flesh), seg)
c:px(cx, cy, "#fff3c8")
-- dimples on the lit side
c:px(22, 38, "#e0501f"); c:px(26, 44, "#e0501f"); c:px(35, 27, "#e0501f")
local t = c:save(O .. "aseprite/ico/ico-orange.aseprite", O .. "png/ico/ico-orange.png")
print(GV.report(t))
