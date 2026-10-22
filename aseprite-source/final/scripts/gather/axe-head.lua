local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
-- half-size grid 32x48, written 2x
local c = GV.canvas{ w = 32, h = 48, mode = "sticker", out = 2 }
local steel = GV.ramp("#c9d3da", { gloss = "#f5f9fb" })
local dark = GV.ramp("#7f8c94")

local blade = c:poly({
  {9, 15}, {14, 16}, {19, 17}, {22, 17}, {24, 16}, {25, 18}, {26, 22}, {27, 27},
  {27, 32}, {26, 37}, {25, 41}, {22, 39}, {19, 36}, {15, 33}, {12, 31}, {9, 30},
})

c:build{
  { "handle", c:rrect(6, 5, 9, 42, 2), "wood" },
  { "blade",  blade, steel, { gloss = false } },
  { "collar", c:rrect(4, 18, 11, 32, 1), dark, { gloss = false } },
}
-- handle lit stripe
c:fill(c:rect(7, 6, 7, 16), "#d09a60"); c:fill(c:rect(7, 34, 7, 41), "#d09a60")
-- upper bevel band
c:fill(c:poly({ {12, 18}, {22, 19}, {24, 18}, {25, 21}, {21, 22}, {12, 21} }), "#e8eef2")
-- bright cutting edge
c:fill(c:line({ {25, 19}, {26, 23}, {26, 31}, {25, 36}, {24, 39} }, 1), "#f5f9fb")
-- gloss streak
c:fill(c:line({ {14, 24}, {18, 25}, {21, 26} }, 1), "#f5f9fb")
-- collar lit strip + rivets
c:fill(c:rect(5, 19, 5, 31), "#a9b4bb")
c:px(9, 21, GV.C.gold); c:px(9, 29, GV.C.gold)

c:ground(8, 44, 5, 1)
local t = c:save(O .. "aseprite/gather/axe-head.aseprite", O .. "png/gather/axe-head.png")
print(GV.report(t))
