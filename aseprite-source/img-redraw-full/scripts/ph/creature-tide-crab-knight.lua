local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local LEG, RED, PINK, STEEL = "#bf6f4f", GV.ramp("#d6322b"), GV.ramp("#f6b8cf"), GV.ramp("#a38f80")

local legs = c:line({ {19,42}, {13,45}, {11,51} }, 3)
legs:add(c:line({ {23,46}, {19,50}, {17,53} }, 3))
legs:add(c:line({ {44,42}, {50,45}, {52,51} }, 3))
legs:add(c:line({ {40,46}, {44,50}, {46,53} }, 3))
local arms = c:line({ {20,35}, {16,30}, {15,24} }, 3)
arms:add(c:line({ {43,35}, {47,30}, {48,24} }, 3))
local clawL = c:ellipse(15, 18, 5.5, 7.5):cut(c:poly({ {14,9}, {21,9}, {16,18} }))
local clawR = c:ellipse(48, 18, 5.5, 7.5):cut(c:poly({ {42,9}, {49,9}, {47,18} }))
local stalks = c:line({ {25,25}, {25,17} }, 2):add(c:line({ {38,25}, {38,17} }, 2))
local dome = c:ellipse(31.5, 37, 13, 14):cut(c:rect(0, 38, 63, 63))
local brim = c:rrect(16, 36, 47, 40, 2)
local plume = c:line({ {32,23}, {33,20}, {36,18}, {39,18}, {41,20} }, 2)

local p = c:build{
  { "legs",  legs, LEG, { flat = true } },
  { "arms",  arms, LEG, { flat = true } },
  { "clawL", clawL, RED },
  { "clawR", clawR, RED },
  { "body",  c:ellipse(31.5, 38, 16, 10), RED },
  { "belly", c:ellipse(31.5, 43, 10, 5), PINK, { flat = true } },
  { "stalks", stalks, LEG, { flat = true } },
  { "bulbL", c:ellipse(25, 15, 3.5, 3.5), RED, { gloss = false } },
  { "bulbR", c:ellipse(38, 15, 3.5, 3.5), RED, { gloss = false } },
  { "dome",  dome, STEEL },
  { "brim",  brim, STEEL, { light = dome:copy():add(brim) } },
  { "plume", plume, RED, { flat = true } },
}
-- visor slit
c:fill(c:rect(31, 27, 32, 35), "#2a1a10")
c:px(31, 27, "#4a2c1a")
-- claw notch lines
c:fill(c:line({ {12,22}, {13,16} }, 1), "#9c2a1e")
c:fill(c:line({ {51,22}, {50,16} }, 1), "#9c2a1e")
c:seam({ {17, 38}, {46, 38} })
c:eye(23, 13); c:eye(36, 13)
c:ground(31.5, 54, 17, 1.5)
local t = c:save(O .. "aseprite/ph/creature-tide-crab-knight.aseprite", O .. "png/ph/creature-tide-crab-knight.png")
print(GV.report(t))
