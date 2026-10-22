local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local blade = c:poly({ {48, 8}, {57, 7}, {56, 16}, {27, 45}, {19, 37} })
local guard = c:line({ {15, 33}, {31, 49} }, 5)
local grip = c:line({ {19, 45}, {12, 52} }, 5)
local pommel = c:ellipse(10, 54, 4)

local p = c:build{
  { "grip", grip, "wood", { gloss = false } },
  { "pommel", pommel, "gold" },
  { "blade", blade, GV.ramp("#dcb06a"), { gloss = { 44, 15 } } },
  { "guard", guard, "gold", { gloss = { 18, 36 } } },
}
-- fuller line along blade centre
c:line({ {26, 38}, {51, 13} }, 1):each(function(x, y) c:px(x, y, "#f5cf6a") end)
-- grip wrap
c:px(15, 48, "#5e2f1e"); c:px(16, 49, "#5e2f1e"); c:px(13, 50, "#5e2f1e"); c:px(14, 51, "#5e2f1e")
local t = c:save(O .. "aseprite/ico/ico-sword.aseprite", O .. "png/ico/ico-sword.png")
print(GV.report(t))
