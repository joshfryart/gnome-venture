local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local cactus = "#58a03e"
local sun = c:ellipse(50, 14, 4.5, 4.5)

-- L-shaped arms, 4 px wide, round tips
local armL = c:line({ {27, 37}, {18, 37}, {18, 27} }, 4)
armL:add(c:ellipse(19.5, 26, 2.5, 2.5))
armL:add(c:ellipse(19.5, 37, 2.5, 2.5))
local armR = c:line({ {36, 31}, {44, 31}, {44, 26} }, 4)
armR:add(c:ellipse(45.5, 25, 2.5, 2.5))
armR:add(c:ellipse(45.5, 31, 2.5, 2.5))

local trunk = c:rrect(26, 12, 36, 51, 5)

local dune = c:poly({ {8, 53}, {11, 49}, {16, 45}, {22, 43}, {30, 44}, {38, 46}, {44, 44}, {49, 44}, {54, 48}, {57, 53} })
dune:add(c:rect(8, 51, 57, 53))

local p = c:build{
  { "sun",   sun,   GV.ramp("#e8892a") },
  { "armL",  armL,  GV.ramp(cactus) },
  { "armR",  armR,  GV.ramp(cactus) },
  { "trunk", trunk, GV.ramp(cactus) },
  { "dune",  dune,  GV.ramp("#dcb06a") },
}
-- cactus ribs
local rib = GV.ramp(cactus).shade
for y = 16, 41, 3 do c:px(29, y, rib); c:px(33, y, rib) end
c:seam({ {12, 48}, {22, 45}, {30, 46}, {38, 48}, {48, 46}, {54, 50} })

local t = c:save(O .. "aseprite/ico/ico-desert.aseprite", O .. "png/ico/ico-desert.png")
print(GV.report(t))
