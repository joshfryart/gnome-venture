-- clay-pot: a small round-bellied pot fresh off the wheel, lopsided on purpose
-- (belly sags right, neck and lip tilt left), with throwing rings and a seamed foot.
-- Family: wood/soil clay tan, GV.ramp("#c47a52") (skin-shade terracotta run through the recipe).
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local clay = GV.ramp("#c47a52")
local lipR = GV.ramp("#d9885a")

-- belly: a squat ball that sags to the right
local belly = c:ellipse(31, 41, 17, 13):add(c:ellipse(36, 44, 15, 10)):closed(2)
-- neck: short, leaning left
local neck = c:poly({ {22, 21}, {37, 19}, {39, 31}, {22, 31} })
-- lip: a flared ring, tilted (left side higher)
local lip = c:poly({ {16, 17}, {30, 13}, {43, 12}, {45, 15}, {44, 19}, {30, 21}, {17, 23}, {15, 20} }):closed(2)
-- foot ring
local foot = c:rrect(24, 53, 44, 57, 2)

local p = c:build{
  { "foot",  foot,  clay, { gloss = false } },
  { "belly", belly, clay, { gloss = { 20, 34 } } },
  { "neck",  neck,  clay, { gloss = false } },
  { "lip",   lip,   lipR, { gloss = { 20, 18 } } },
}
-- the mouth: dark tilted opening inside the lip
local mouth = c:poly({ {20, 18}, {31, 15}, {41, 14}, {42, 16}, {31, 18}, {20, 20} }):closed(1)
c:fill(mouth, "#5e2f1e")
c:fill(c:poly({ {23, 19}, {31, 17}, {40, 16}, {40, 17}, {31, 18}, {23, 20} }), "#2a1a10")
-- throwing rings: two shallow grooves round the belly, following its sag
local G = clay.shade
c:fill(c:line({ {17, 38}, {24, 39}, {33, 39}, {41, 40}, {47, 41} }, 1):clip(belly:shrink(2)), G)
c:fill(c:line({ {19, 46}, {27, 47}, {37, 48}, {45, 48} }, 1):clip(belly:shrink(2)), G)
-- a thumb dent on the sagging side
c:fill(c:ellipse(43, 35, 1.5, 1), clay.shade)
c:px(42, 34, clay.deep); c:px(43, 34, clay.deep)
-- foot join: a seam round the plinth lip
c:seam({ {25, 54}, {43, 54} })

c:ground(33, 58, 15, 1.5)
local t = c:save(D .. "final/aseprite/ph/clay-pot.aseprite", PNG .. "clay-pot.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
