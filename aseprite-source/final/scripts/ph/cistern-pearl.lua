-- cistern-pearl: a cloudy, sour, plum-sized pearl sunk in a squat stone cistern cup of stale water
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- pale pearl ramp with a sour olive cast in the shadow (no pure white: warm dot)
local pearlR = GV.ramp("#eee8d4", { shade = "#cdc796", deep = "#9e9868", bounce = "#d8d2a6", dot = "#fff8e0" })
local stoneR = GV.ramp("#8b8f96", { gloss = "#e4e0d6", rim = "#c9c5bc", shade = "#5b6470", deep = "#3c4250", bounce = "#6c7480" })

-- squat stone cup: back rim, then the pearl, then the front wall
local back  = c:ellipse(31.5, 39, 19, 4)
local pearl = c:ellipse(31.5, 27, 15, 14.5):add(c:ellipse(30, 29, 14, 12))
pearl:cut(c:rect(31, 12, 32, 13))                        -- small dimple at the crown
local front = c:ellipse(31.5, 40, 19, 4):cut(c:rect(0, 0, 63, 39))
front:add(c:poly({ { 13, 40 }, { 51, 40 }, { 46, 53 }, { 17, 53 } }))
front:add(c:ellipse(31.5, 51, 14.5, 3))
front:add(c:rrect(21, 52, 42, 55, 1))                     -- squat foot

c:build{ { "back", back, stoneR, { gloss = false } } }
-- stale cistern water inside the cup
c:fill(c:ellipse(31.5, 39, 15, 2.5), "#2f6290")
c:fill(c:ellipse(30.5, 38.5, 13, 1.5):cut(c:rect(0, 39, 63, 63)), "#3f8fb0")
c:build{
  { "pearl", pearl, pearlR, { gloss = { 21, 19 }, cres = 6, deep = 2 } },
  { "front", front, stoneR, { gloss = { 17, 46 } } },
}

-- cloudy milk wisps in the nacre (long beans, evenly spread)
local cloud = "#dedac2"
c:fill(c:ellipse(35, 19, 4, 1), cloud)
c:fill(c:ellipse(26, 27, 5, 1), cloud)
c:fill(c:ellipse(38, 28, 3, 1), cloud)
c:fill(c:ellipse(31, 34, 5, 1), cloud)
-- sour sallow tinge low on the shaded side
c:fill(c:ellipse(40, 34, 2, 1):clip(pearl:shrink(2)), "#c4be86")

-- carved band round the cup with a thread-gold seam and a button at its head
c:fill(c:rect(16, 46, 47, 46), "#6c7480")
c:seam({ { 19, 45 }, { 47, 45 } })
c:button(16, 43)
-- worn grooves on the stone
c:fill(c:rect(23, 50, 25, 50), "#5b6470"); c:fill(c:rect(37, 50, 39, 50), "#5b6470")

local t = c:save(D .. "final/aseprite/ph/cistern-pearl.aseprite", PNG .. "cistern-pearl.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
