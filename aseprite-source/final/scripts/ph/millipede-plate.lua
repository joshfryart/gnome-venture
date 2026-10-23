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
  return c:ellipse(cx, cy, ro, ry):cut(c:ellipse(cx, cy, ri, riy)):cut(c:rect(0, math.floor(cy) + 1, 63, 63))
end
local back  = arch(34.5, 47, 25, 32, 12, 15)
local front = arch(30.5, 50, 24, 31, 12, 15)
-- flat feet where the plate meets the ground
front:add(c:rrect(6, 46, 20, 52, 2)):add(c:rrect(41, 46, 55, 52, 2))
back:cut(c:rect(0, 50, 63, 63))
local whole = front:copy():add(back)

local p = c:build{
  { "back",  back,  dark,  { light = whole, gloss = false } },
  { "front", front, light, { light = whole, gloss = { 14, 31 } } },
}

-- clay grooves: three radial ribs across the face, dark clay with a lit lower lip
local ribs = {
  { { 13, 37 }, { 21, 41 } },
  { { 30, 20 }, { 30, 34 } },
  { { 47, 37 }, { 39, 41 } },
}
for _, r in ipairs(ribs) do
  c:fill(c:line(r, 2):clip(front:shrink(2)), "#5e3a2c")
end
-- a few crackle ticks in the glaze, like baked clay
c:paint({ "k.", ".k", ".k" }, 21, 26, { k = "#9c7a62" })
c:paint({ ".k", "k.", "k." }, 38, 27, { k = "#9c7a62" })

-- hem seam where the front face meets the dark back edge, button at its head
c:seam({ { 9, 44 }, { 9, 36 }, { 12, 28 }, { 17, 22 }, { 23, 19 } })
c:button(25, 17)

c:ground(31.5, 54, 24, 1.5)
local t = c:save(D .. "final/aseprite/ph/millipede-plate.aseprite", PNG .. "millipede-plate.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
