-- bell-clapper.lua : a small heavy iron bell clapper, lying on a slant (64x64 sticker)
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- iron borrowed from the stone family, its tie from wood (leather)
local iron  = GV.ramp("#5b6470", { gloss = "#c9d4d2", dot = "#eef0e6" })
local ironL = GV.ramp("#8b8f96", { gloss = "#dfe4dc", dot = "#f4f2e6" })
local strap = GV.ramp("#a8582f")

-- hanging loop at the upper right (an open ring), stem down to a heavy pear bob at the lower left
local loop = c:ellipse(45.5, 15.5, 8, 8):cut(c:ellipse(45.5, 15.5, 4.5, 4.5))
local stem = c:line({ { 40, 22 }, { 28, 36 } }, 4)
local bob  = c:ellipse(21.5, 44.5, 10, 10)
-- a flange collar where the stem is set into the ball
local collar = c:line({ { 25, 34 }, { 31, 40 } }, 3)
-- leather tie wrapped round the neck where the loop meets the stem
local tie  = c:poly({ { 35, 23 }, { 40, 28 }, { 44, 24 }, { 39, 19 } })
local whole = loop:copy():add(stem):add(bob)

local p = c:build{
  { "loop", loop, iron,  { light = whole, gloss = { 41, 11 } } },
  { "stem", stem, iron,  { light = whole, gloss = false } },
  { "bob",  bob,  ironL, { gloss = false } },
  { "collar", collar, iron, { gloss = false, cres = 2, deep = 1 } },
  { "tie",  tie,  strap, { gloss = false } },
}
-- the thread binding on the tie: a seam across the wrap
c:seam({ { 37, 22 }, { 41, 26 } })
-- enamel comma on the ball, upper left
c:paint({ "..gg", ".g..", "g...", "g..." }, 15, 37, { g = ironL.gloss })
c:px(19, 40, ironL.dot)

c:ground(22, 56, 12, 1.5)
local t = c:save(D .. "final/aseprite/ph/bell-clapper.aseprite", PNG .. "bell-clapper.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
