-- ph/wet-clay : a cold blue-grey lump of clay sitting in its own little puddle,
-- slumped to the right with a hanging drip, a deep finger-dent and a wet shine
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- puddle the lump has leaked (behind, flat)
local puddle = c:ellipse(32, 49, 23, 4)
-- lump: a soft squat dollop, peak leaning left, a second soft bulge right,
-- its bottom lip sagging out over the puddle
local lump = c:ellipse(31, 36, 18, 11)
lump:add(c:ellipse(26, 27, 11, 10))
lump:add(c:ellipse(39, 30, 9, 8))
lump:cut(c:rect(0, 45, 63, 63))
lump:add(c:ellipse(31, 44, 20, 3))
-- sticky drip hanging off the right lip into the puddle
local drip = c:rrect(43, 44, 45, 49, 1):add(c:ellipse(44, 50, 2, 2))

local clay = GV.ramp("#8b8f96", { gloss = "#e6f8ee", dot = "#f8fcf4", rim = "#c9c5bc" })
local p = c:build{
  { "puddle", puddle, "water", { gloss = false, cres = 2, deep = 1 } },
  { "lump", lump, clay, { gloss = { 17, 22 }, cres = 6 } },
  { "drip", drip, clay, { flat = true } },
}

-- finger-dent: a hollow, so it is dark on its upper-left inside and lit on its lower-right lip
local dent = c:ellipse(34, 34, 5, 4)
c:fill(dent, clay.shade)
c:fill(dent:copy():cut(dent:copy():shift(1, 1)), clay.deep)
c:fill(dent:copy():shift(1, 1):cut(dent), "#e6f8ee")
-- fingerprint whorl inside the dent
c:paint({
  ".ddd.",
  "d....",
  "..dd.",
}, 33, 33, { d = clay.deep })

-- wet shine: streak down the lit flank, glints on each bulge, runnels down the front
c:fill(c:line({ { 15, 31 }, { 15, 36 }, { 17, 40 } }, 1), "#e6f8ee")
c:fill(c:line({ { 34, 24 }, { 37, 23 } }, 1), "#e6f8ee")
c:px(46, 34, "#e6f8ee")
c:fill(c:line({ { 24, 39 }, { 24, 42 } }, 1), clay.shade)
c:px(24, 38, "#e6f8ee")
c:fill(c:line({ { 41, 39 }, { 41, 42 } }, 1), clay.deep)
c:px(43, 48, "#e6f8ee")
-- puddle ripples
c:fill(c:line({ { 12, 49 }, { 15, 49 } }, 1), "#8fcbd8")
c:fill(c:line({ { 49, 50 }, { 51, 50 } }, 1), "#8fcbd8")

local t = c:save(D .. "final/aseprite/ph/wet-clay.aseprite", PNG .. "wet-clay.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
