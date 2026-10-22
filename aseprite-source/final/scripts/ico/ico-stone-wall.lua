local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local light = GV.ramp("#968f96", { shade = "#5b6470", gloss = "#c9c5bc", rim = "#b4aeb2" })
local dark  = GV.ramp("#6a6070", { shade = "#3e3a48", rim = "#857c8a" })

local parts = {
  { "mortar", c:rect(8, 12, 56, 52), "#4a2c1a", { flat = true, rim = false, gloss = false } },
  { "r1a", c:rrect(9, 13, 30, 24, 3), light, { gloss = { 13, 16 } } },
  { "r1b", c:rrect(33, 13, 55, 24, 3), dark, { gloss = false } },
  { "r2a", c:rrect(9, 27, 18, 38, 3), dark, { gloss = false } },
  { "r2b", c:rrect(21, 27, 41, 38, 3), light, { gloss = false } },
  { "r2c", c:rrect(44, 27, 55, 38, 3), dark, { gloss = false } },
  { "r3a", c:rrect(9, 41, 30, 51, 3), light, { gloss = false } },
  { "r3b", c:rrect(33, 41, 55, 51, 3), dark, { gloss = false } },
}
for i = 2, #parts do parts[i][4].cres = 2; parts[i][4].deep = 1; parts[i][4].contour = false; parts[i][4].contact = false end
c:build(parts)
-- a few chips and pebbles for texture
c:px(24, 18, "#7a7480"); c:px(25, 18, "#7a7480")
c:px(49, 31, "#544c5c"); c:px(36, 31, "#7a7480")
c:px(14, 46, "#7a7480"); c:px(15, 47, "#7a7480")
c:px(46, 45, "#544c5c"); c:px(41, 18, "#544c5c")

local t = c:save(B .. "aseprite/ico/ico-stone-wall.aseprite", B .. "png/ico/ico-stone-wall.png")
print(GV.report(t))
