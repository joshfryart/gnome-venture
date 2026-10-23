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
local loop = c:ellipse(45.5, 15.5, 8, 8):cut(c:ellipse(45.5, 15.5, 4.5, 4.5))
local stem = c:line({ { 40, 22 }, { 28, 36 } }, 4)
local bob  = c:ellipse(21, 45, 9.5, 9):add(c:ellipse(25.5, 39.5, 6.5, 6.5)):add(c:ellipse(29.5, 35.5, 3.5, 3.5))
-- leather tie wrapped round the neck where the loop meets the stem
local tie  = c:poly({ { 35, 23 }, { 40, 28 }, { 44, 24 }, { 39, 19 } })
local whole = loop:copy():add(stem):add(bob)

local p = c:build{
  { "loop", loop, iron,  { light = whole, gloss = { 41, 11 } } },
  { "stem", stem, iron,  { light = whole, gloss = false } },
  { "bob",  bob,  ironL, { gloss = { 16, 38 } } },
  { "tie",  tie,  strap, { gloss = false } },
}
-- the thread binding on the tie: a seam across the wrap
c:seam({ { 37, 22 }, { 41, 26 } })
-- a hammered collar line where the stem is set into the bob
c:fill(c:line({ { 26, 32 }, { 33, 39 } }, 1):clip(bob:shrink(1)), "#3c3f52")

c:ground(22, 56, 12, 1.5)
local t = c:save(D .. "final/aseprite/ph/bell-clapper.aseprite", PNG .. "bell-clapper.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
