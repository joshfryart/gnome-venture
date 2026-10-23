-- bell-clapper.lua : a small heavy iron bell clapper, lying on a slant (64x64 sticker)
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- iron borrowed from the stone family, its tie from wood (leather)
local iron  = GV.ramp("#5b6470")
local ironL = GV.ramp("#8b8f96")
local strap = GV.ramp("#a8582f")

-- hanging loop at the upper right (an open ring), stem down to a heavy pear bob at the lower left
local loop = c:ellipse(45.5, 15.5, 7, 7):cut(c:ellipse(45.5, 15.5, 3, 3))
local stem = c:line({ { 41, 22 }, { 27, 38 } }, 4)
local bob  = c:ellipse(21.5, 43.5, 10, 10):add(c:ellipse(25.5, 39.5, 6, 6))
-- leather tie wrapped round the neck where the loop meets the stem
local tie  = c:poly({ { 36, 22 }, { 41, 27 }, { 45, 23 }, { 40, 18 } })
local whole = loop:copy():add(stem):add(bob)

local p = c:build{
  { "loop", loop, iron,  { light = whole, gloss = { 41, 11 } } },
  { "stem", stem, iron,  { light = whole, gloss = false } },
  { "bob",  bob,  ironL, { gloss = { 16, 38 } } },
  { "tie",  tie,  strap, { gloss = false } },
}
-- the thread binding on the tie: a seam across the wrap, with a button
c:seam({ { 38, 21 }, { 42, 25 } })
-- a hammered ring round the bob's waist where the stem is set in
c:fill(c:line({ { 25, 33 }, { 31, 39 } }, 1):clip(bob:shrink(1)), "#3c3f52")
-- worn strike band on the bob, a few hammer dents
c:spot(c:ellipse(23.5, 47, 1.5, 1), "#3c3f52", "#8b8f96")
c:spot(c:ellipse(17.5, 46.5, 1, 1), "#3c3f52", "#8b8f96")

c:ground(26, 56, 13, 1.5)
local t = c:save(D .. "final/aseprite/ph/bell-clapper.aseprite", PNG .. "bell-clapper.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
