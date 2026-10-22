-- ph/beehive-2 : three stepped golden skep tiers on a plinth, arch door, bees, red pennant
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-full/"

local tan  = GV.ramp("#c4925f")   -- soil family
local foot = GV.ramp("#b6814d")
local gold = "gold"
local knob = GV.ramp("#b07a10")   -- gold family
local flag = GV.ramp("#d6322b")   -- ember family
local pole = GV.ramp("#44281c")
local line = "#b07a10"

local whole = c:rrect(14, 38, 49, 49, 6):add(c:rrect(18, 28, 45, 39, 6))
  :add(c:rrect(22, 19, 41, 30, 6)):add(c:ellipse(31.5, 18, 8.5, 6))

c:build{
  { "pole",  c:rect(48, 26, 49, 41), pole, { flat = true } },
  { "flag",  c:poly({ {50, 26}, {57, 29}, {50, 33} }), flag, { gloss = false } },
  { "feet",  c:rect(17, 54, 21, 57):add(c:rect(42, 54, 46, 57)), foot, { gloss = false } },
  { "plinth",c:rrect(13, 49, 50, 55, 2), tan, { gloss = false } },
  { "tier1", c:rrect(14, 38, 49, 49, 6), gold, { light = whole, gloss = false } },
  { "tier2", c:rrect(18, 28, 45, 39, 6), gold, { light = whole, gloss = false } },
  { "dome",  c:rrect(22, 19, 41, 30, 6):add(c:ellipse(31.5, 18, 8.5, 6)), gold, { light = whole, gloss = { 26, 15 } } },
  { "knob",  c:rrect(30, 9, 33, 13, 1), knob, { flat = true } },
}

-- woven skep coil lines within each tier
for x = 16, 47 do if c:get(x, 44) ~= nil then c:px(x, 44, line) end end
for x = 20, 43 do c:px(x, 34, line) end
for x = 24, 39 do c:px(x, 25, line) end

-- arched entrance
c:paint({
  "..dddd..",
  ".dddddd.",
  "dddddddd",
  "dddddddd",
  "dddddddd",
}, 28, 44, { d = "#44281c" })
c:px(29, 46, "#2a1a10"); c:px(30, 45, "#2a1a10")

-- bees: 3x3 orange dots with dark centre, with tiny cream wings
local function bee(x, y)
  c:part(c:rect(x, y, x + 2, y + 2), GV.ramp("#f08a24"), { flat = true, contact = false })
  c:px(x + 1, y + 1, "#2a1a10")
end
bee(10, 28); bee(53, 41)

-- plinth seam
c:seam({ {16, 54}, {47, 54} })

local t = c:save(O .. "aseprite/ph/beehive-2.aseprite", O .. "png/ph/beehive-2.png")
print(GV.report(t))
