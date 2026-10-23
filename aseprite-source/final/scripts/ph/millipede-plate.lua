-- millipede-plate.lua : one arched clay back-plate shed by the Claybound Millipede (64x64 sticker)
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- clay tones borrowed from the millipede itself (soil family)
local light = GV.ramp("#c9ae90")
local dark  = GV.ramp("#7a5442")

-- a half-ring arch (a millipede segment seen end-on), with its thick back edge peeking up-right
local function arch(cx, cy, ro, ry, ri, riy)
  return c:ellipse(cx, cy, ro, ry):cut(c:ellipse(cx, cy, ri, riy)):clip(c:rect(0, 0, 63, math.floor(cy)))
end
local back  = arch(34, 46, 21, 30, 10, 14)
local front = arch(30, 49, 21, 29, 10, 14)
-- flat feet where the plate meets the ground
front:add(c:rrect(8, 46, 21, 52, 2)):add(c:rrect(39, 46, 52, 52, 2))
back:cut(c:rect(0, 50, 63, 63))
local whole = front:copy():add(back)

local p = c:build{
  { "back",  back,  dark,  { light = whole, gloss = false } },
  { "front", front, light, { light = whole, gloss = { 16, 28 } } },
}

-- the plate is two clay bands sewn together, like the millipede's segments:
-- a seam runs along the join, with a lit lower lip, and a button at its left foot
local arc = {}
for i = 0, 24 do
  local a = math.pi * i / 24
  arc[#arc + 1] = { math.floor(30 - 16 * math.cos(a) + 0.5), math.floor(47 - 23 * math.sin(a) + 0.5) }
end
local lip = c:line(arc, 1):shift(1, 1):cut(c:line(arc, 1)):clip(front:shrink(1))
c:fill(lip, "#e6d2b8")
c:seam(arc, { gap = "#5e3a2c" })
c:button(12, 42)
-- clay knobs that make it rattle: bean markings along the outer band
c:spot(c:ellipse(31.5, 22.5, 2, 1.5), "#5e3a2c", "#9c7a62")
c:spot(c:ellipse(42, 28, 1.5, 1.5), "#5e3a2c", "#9c7a62")
c:spot(c:ellipse(47, 38.5, 1.5, 2), "#5e3a2c", "#9c7a62")

c:ground(30.5, 54, 22, 1.5)
local t = c:save(D .. "final/aseprite/ph/millipede-plate.aseprite", PNG .. "millipede-plate.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
