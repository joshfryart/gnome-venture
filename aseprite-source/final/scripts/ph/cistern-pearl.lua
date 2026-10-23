-- cistern-pearl: a cloudy, sour, plum-sized pearl resting in an old stone cistern dish with a puddle of stale water
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- pale pearl ramp with a sour olive cast in the shadow
local pearlR = GV.ramp("#eee8d4", { shade = "#d0cca4", deep = "#a8a476", bounce = "#dcd8b0", dot = "#fff8e0" })
local stoneR = GV.ramp("#8b8f96", { gloss = "#e4e0d6", rim = "#c9c5bc", shade = "#5b6470", deep = "#3c4250", bounce = "#6c7480" })

-- shallow stone basin: back rim, then the pearl, then the front lip and bowl
local back  = c:ellipse(31.5, 42, 22, 5)
local pearl = c:ellipse(31.5, 29, 15, 14.5):add(c:ellipse(29.5, 31, 14, 12.5))
pearl:cut(c:rect(31, 14, 32, 15))                       -- small dimple where it once hung
local front = c:ellipse(31.5, 43, 22, 5):cut(c:rect(0, 0, 63, 42))
front:add(c:poly({ { 10, 43 }, { 54, 43 }, { 47, 53 }, { 17, 53 } }))
front:add(c:rrect(20, 51, 43, 55, 2))                    -- squat foot

c:build{
  { "back", back, stoneR, { gloss = false } },
}
-- stale cistern water pooled in the basin
c:fill(c:ellipse(31.5, 42, 19, 3), "#2f6290")
c:fill(c:ellipse(30.5, 41.5, 17, 2):cut(c:rect(0, 42, 63, 63)), "#3f8fb0")
c:build{
  { "pearl", pearl, pearlR, { gloss = { 22, 21 } } },
  { "front", front, stoneR, { gloss = { 14, 45 } } },
}

-- cloudy patches in the nacre (beans, evenly spread)
local cloud = "#dcd8bc"
c:fill(c:ellipse(36, 22, 3, 1.5), cloud)
c:fill(c:ellipse(25, 33, 3.5, 2), cloud)
c:fill(c:ellipse(37, 33, 2.5, 2), cloud)
c:fill(c:ellipse(30, 27, 2, 1), cloud)
-- sour sallow tinge low on the shaded side
c:fill(c:ellipse(39, 39, 2.5, 1.5):clip(pearl:shrink(2)), "#c9c48a")
c:fill(c:ellipse(21, 40, 2, 1):clip(pearl:shrink(2)), "#d0cca4")

-- basin lip seam with a pin button
c:seam({ { 12, 45 }, { 18, 47 }, { 25, 48 }, { 31, 48 }, { 38, 48 }, { 45, 47 }, { 51, 45 } })
-- chipped notch and wear lines on the old stone bowl
c:fill(c:rect(23, 50, 24, 50), "#5b6470"); c:fill(c:rect(39, 50, 40, 50), "#5b6470")

local t = c:save(D .. "final/aseprite/ph/cistern-pearl.aseprite", PNG .. "cistern-pearl.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
