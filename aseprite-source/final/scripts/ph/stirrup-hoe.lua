local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wood  = GV.ramp("#b6814d")
local steel = GV.ramp("#d6c9b6")
local dark  = GV.ramp("#5b6470")
local shaft = c:line({ { 17, 50 }, { 38, 14 } }, 5)
-- stirrup blade: open trapezoid loop held sideways
local blade = c:poly({ { 33, 9 }, { 55, 9 }, { 52, 22 }, { 31, 22 } })
blade:cut(c:poly({ { 37, 13 }, { 51, 13 }, { 49, 19 }, { 36, 19 } }))
local edge = c:poly({ { 32, 19 }, { 53, 19 }, { 52, 22 }, { 31, 22 } })
local collar = c:rrect(34, 10, 41, 15, 1)
local cap = c:ellipse(16.5, 51.5, 4, 4)
c:build{
  { "shaft",  shaft,  wood },
  { "blade",  blade,  steel, { gloss = { 44, 10 } } },
  { "edge",   edge,   GV.ramp("#8b8f96"), { flat = true } },
  { "collar", collar, dark, { gloss = false } },
  { "cap",    cap,    GV.ramp("#a8582f"), { gloss = false } },
}
-- wood grain dashes
c:px(26, 35, wood.shade); c:px(27, 34, wood.shade)
c:px(31, 28, wood.shade); c:px(32, 27, wood.shade)
local t = c:save(O .. "aseprite/ph/stirrup-hoe.aseprite", O .. "png/ph/stirrup-hoe.png")
print(GV.report(t))
