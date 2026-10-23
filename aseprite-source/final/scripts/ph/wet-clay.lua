-- ph/wet-clay : a cold blue-grey lump of clay sitting in its own little puddle,
-- slumped to the right with a hanging drip, a deep finger-dent and a wet shine
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- puddle the lump has leaked (behind, flat)
local puddle = c:ellipse(32, 48, 24, 5)
-- lump: tall rounded peak on the left, slumping shoulder on the right
local lump = c:ellipse(30, 36, 17, 13)
lump:add(c:ellipse(26, 25, 11, 11))
lump:add(c:ellipse(41, 38, 10, 9))
lump:cut(c:rect(0, 47, 63, 63))
lump:add(c:rrect(14, 42, 49, 47, 3))
-- sticky drip hanging off the right shoulder
local drip = c:rrect(48, 36, 50, 45, 1):add(c:ellipse(49.5, 46, 2.5, 2.5))

local clay = GV.ramp("#8b8f96", { gloss = "#e6f8ee", dot = "#f8fcf4", rim = "#c9c5bc" })
local p = c:build{
  { "puddle", puddle, "water", { gloss = false, cres = 2, deep = 1 } },
  { "drip", drip, clay, { flat = true } },
  { "lump", lump, clay, { gloss = { 17, 19 }, cres = 5 } },
}

-- finger-dent: a hollow, so it is dark on its upper-left inside and lit on its lower-right lip
local dent = c:ellipse(34, 33, 5, 4)
c:fill(dent, clay.shade)
c:fill(dent:copy():cut(dent:copy():shift(1, 1)), clay.deep)
c:fill(dent:copy():shift(1, 1):cut(dent), clay.rim)
-- fingerprint whorls inside the dent
c:paint({
  ".ddd.",
  "d...d",
  ".dd..",
}, 32, 32, { d = clay.deep })

-- wet shine: a long streak down the lit side and two drop glints
c:fill(c:line({ { 16, 29 }, { 16, 35 }, { 18, 39 } }, 1), "#e6f8ee")
c:fill(c:line({ { 31, 18 }, { 34, 17 } }, 1), "#e6f8ee")
c:px(43, 33, "#e6f8ee"); c:px(42, 34, "#c9c5bc")
c:px(48, 44, "#e6f8ee")
-- puddle ripples
c:fill(c:line({ { 11, 48 }, { 14, 48 } }, 1), "#8fcbd8")
c:fill(c:line({ { 51, 49 }, { 53, 49 } }, 1), "#8fcbd8")

local t = c:save(D .. "final/aseprite/ph/wet-clay.aseprite", PNG .. "wet-clay.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
