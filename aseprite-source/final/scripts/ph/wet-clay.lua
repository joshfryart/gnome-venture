-- ph/wet-clay : a cold blue-grey lump of clay sitting in its own little puddle,
-- slumped to the right with a hanging drip, a deep finger-dent and a wet shine
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- puddle the lump has leaked (behind, flat)
local puddle = c:ellipse(32, 49, 23, 4)
-- lump: a soft slumped dollop whose pinched peak flops over to the right,
-- with two soft lobes sagging out over the puddle at the bottom
local lump = c:ellipse(31, 39, 18, 8)
lump:add(c:ellipse(28, 31, 13, 9))
lump:add(c:line({ { 25, 24 }, { 28, 18 }, { 33, 15 }, { 38, 16 }, { 40, 19 } }, 6))
lump:add(c:ellipse(40.5, 21, 3, 3)):add(c:ellipse(36, 25, 5, 4)):add(c:ellipse(32, 22, 5, 4))
lump:cut(c:rect(0, 46, 63, 63))
lump:add(c:ellipse(21, 45, 8, 2.5)):add(c:ellipse(38, 45.5, 9, 2.5))
-- sticky drip hanging off the right lobe into the puddle
local drip = c:rrect(44, 45, 46, 49, 1):add(c:ellipse(45.5, 50, 2, 2))

local clay = GV.ramp("#8b8f96", { gloss = "#e6f8ee", dot = "#f8fcf4", rim = "#c9c5bc" })
local p = c:build{
  { "puddle", puddle, "water", { gloss = false, cres = 2, deep = 1 } },
  { "lump", lump, clay, { gloss = false, cres = 6 } },
  { "drip", drip, clay, { flat = true } },
}

-- finger-dent: a hollow, so it is dark on its upper-left inside and lit on its lower-right lip
local dent = c:ellipse(33, 36, 5, 4)
c:fill(dent, clay.shade)
c:fill(dent:copy():cut(dent:copy():shift(1, 1)), clay.deep)
c:fill(dent:copy():shift(1, 1):cut(dent), "#e6f8ee")
-- fingerprint whorl inside the dent
c:paint({
  ".ddd.",
  "d....",
  "..dd.",
}, 32, 35, { d = clay.deep })

-- wet shine: a big enamel comma on the lit shoulder, a streak down the flank,
-- glints along the flopped peak, runnels down the front
c:paint({
  "..gg",
  ".ggg",
  "gg..",
  "g...",
  "g...",
}, 18, 25, { g = "#e6f8ee" })
c:px(18, 31, "#f8fcf4")
c:fill(c:line({ { 15, 35 }, { 15, 38 }, { 17, 41 } }, 1), "#e6f8ee")
c:fill(c:line({ { 28, 17 }, { 30, 16 }, { 33, 15 } }, 1), "#e6f8ee")
c:px(37, 16, "#c9c5bc")
-- fold where the flopped peak lies over the body
c:fill(c:line({ { 30, 24 }, { 34, 25 }, { 38, 25 } }, 1), clay.deep)
c:fill(c:line({ { 30, 23 }, { 34, 24 } }, 1), "#c9c5bc")
c:px(43, 31, "#e6f8ee"); c:px(44, 32, "#e6f8ee")
c:fill(c:line({ { 25, 40 }, { 25, 43 } }, 1), clay.shade)
c:px(25, 39, "#e6f8ee")
c:fill(c:line({ { 42, 39 }, { 42, 43 } }, 1), clay.deep)
c:px(44, 48, "#e6f8ee")
-- puddle ripples
c:fill(c:line({ { 12, 49 }, { 15, 49 } }, 1), "#8fcbd8")
c:fill(c:line({ { 49, 50 }, { 51, 50 } }, 1), "#8fcbd8")

local t = c:save(D .. "final/aseprite/ph/wet-clay.aseprite", PNG .. "wet-clay.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
