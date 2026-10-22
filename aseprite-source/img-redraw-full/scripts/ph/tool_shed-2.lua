-- ph/tool_shed-2 : wide wooden hut, low slate trapezoid roof, red pennant on mast
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-full/"

local slate = GV.ramp("#968f96")   -- stone family
local lip   = GV.ramp("#6a6070")   -- stone family, darker
local wall  = GV.ramp("#a5663a")   -- wood family
local door  = GV.ramp("#8c4a1a")   -- wood family
local flag  = GV.ramp("#d6322b")   -- ember family
local pole  = GV.ramp("#5e2f1e")

local roof = c:poly({ {9, 35}, {17, 20}, {48, 20}, {56, 35} })

c:build{
  { "mast",  c:rect(31, 10, 32, 21), pole, { flat = true } },
  { "flag",  c:poly({ {33, 10}, {43, 14}, {33, 18} }), flag, { gloss = false } },
  { "wall",  c:rrect(12, 31, 52, 55, 2), wall },
  { "door",  c:rect(24, 39, 40, 55), door, { gloss = false } },
  { "roof",  roof, slate },
  { "lip",   c:rect(9, 33, 55, 36), lip, { gloss = false } },
  { "rpole", c:rect(48, 39, 49, 55), pole, { flat = true } },
  { "rhead", c:rrect(46, 36, 51, 40, 1), slate, { gloss = false } },
  { "lpole", c:rect(15, 39, 16, 55), pole, { flat = true } },
  { "lblade",c:rrect(13, 37, 18, 41, 1), slate, { gloss = false } },
}

-- plank lines on the walls (skip door and tools)
for _, y in ipairs({ 44, 49 }) do
  for x = 19, 22 do c:px(x, y, wall.shade) end
  for x = 42, 45 do c:px(x, y, wall.shade) end
end
-- door cross braces + centre line
c:fill(c:line({ {26, 41}, {38, 53} }, 1), "#5e2f1e")
c:fill(c:line({ {38, 41}, {26, 53} }, 1), "#5e2f1e")
c:fill(c:rect(32, 39, 32, 54), "#5e2f1e")
c:fill(c:rect(25, 39, 39, 39), "#5e2f1e")
-- slate courses on the roof
for x = 16, 49 do if x % 6 ~= 0 then c:px(x, 27, slate.shade) end end
-- hem seams: eave lip and sill
c:seam({ {11, 34}, {53, 34} })
c:seam({ {13, 54}, {51, 54} })
c:px(28, 34, slate.base)

local t = c:save(O .. "aseprite/ph/tool_shed-2.aseprite", O .. "png/ph/tool_shed-2.png")
print(GV.report(t))
