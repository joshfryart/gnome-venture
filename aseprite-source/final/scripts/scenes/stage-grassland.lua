-- scenes/stage-grassland : 480x270, drawn 240x135 written 2x. Family: moss + water + soil, day light.
local H = dofile(os.getenv("GV_ROOT") .. "aseprite-source/final/scripts/scenes/head.lua")
local GV = H.GV
local c = GV.canvas{ w = 240, h = 135, mode = "scene", out = 2, ol = 1, olx = 1 }
local W = 240
local function hills(base, amp, per, ph, y1, col)   -- hard-edged rolling band from a sine top edge down to y1
  for x = 0, W - 1 do
    local top = math.floor(base + amp * math.sin(x / per + ph) + 0.5)
    c:fill(c:rect(x, top, x, y1), col)
  end
end
-- sky: 5 hard bands, warm at the horizon
c:bands(c:rect(0, 0, W - 1, 79), { "#a9d6ea", "#bfe3ee", "#d3ecea", "#e6f0d6", "#f3efc9" })
c:fill(c:ellipse(40, 22, 6, 6), "#fff3c8")                                        -- sun
for _, cl in ipairs({ { 120, 24, 14, 4 }, { 196, 38, 11, 3 }, { 82, 50, 9, 2 } }) do
  c:fill(c:ellipse(cl[1], cl[2], cl[3], cl[4]), "#f7f1e0")
  c:fill(c:rect(cl[1] - cl[3] + 2, cl[2] + 1, cl[1] + cl[3] - 2, cl[2] + cl[4]), "#dfe6e0")  -- flat shaded underside
end
-- far hills (pale, desaturated), mid hills
hills(66, 6, 17, 0.6, 100, "#a9cfa6")
hills(76, 5, 13, 2.1, 100, "#8dbf88")
-- ground: walkable strip y 92..108 (exported 184..216), then near turf
c:fill(c:rect(0, 90, W - 1, 108), "#7ab55c")
c:fill(c:rect(0, 90, W - 1, 91), "#98c868")                                       -- lit top edge
c:fill(c:rect(0, 109, W - 1, 118), "#6a9a3a")
c:fill(c:rect(0, 119, W - 1, 127), "#4a8a3e")
c:fill(c:rect(0, 128, W - 1, 134), "#3f7a38")
-- thin path winding across the middle
for x = 70, 170 do c:fill(c:rect(x, 99 + math.floor(2 * math.sin(x / 11) + 0.5), x, 101 + math.floor(2 * math.sin(x / 11) + 0.5)), "#c9a96e") end
-- raised objects behind the ground line (centre only, sides stay calm): tree, bushes, fence
c:part(c:rect(112, 64, 115, 93), "wood", { gloss = false, cres = 2 })
c:part(c:ellipse(113.5, 56, 13, 11), "moss", { cres = 5, deep = 2 })
c:part(c:ellipse(150, 90, 8, 5), "moss", { gloss = false, cres = 3 })
c:part(c:ellipse(92, 91, 6, 4), "moss", { gloss = false, cres = 2 })
-- flowers (petal) and tufts, sparse and small
for _, f in ipairs({ { 20, 118 }, { 36, 124 }, { 58, 114 }, { 184, 121 }, { 206, 115 }, { 224, 126 }, { 100, 122 }, { 140, 119 } }) do
  c:fill(c:rect(f[1], f[2], f[1] + 1, f[2] + 1), "#e46a9b"); c:px(f[1], f[2], "#f6b8cf")
end
for _, t in ipairs({ { 14, 97 }, { 30, 103 }, { 46, 95 }, { 196, 98 }, { 214, 104 }, { 230, 96 } }) do
  c:fill(c:rect(t[1], t[2], t[1], t[2] + 2), "#4a8a3e"); c:fill(c:rect(t[1] + 2, t[2] + 1, t[1] + 2, t[2] + 2), "#4a8a3e")
end
-- a small bird (4 px) in the sky
c:paint({ "u.u", ".u." }, 156, 30, { u = "#4a2c1a" })
H.done(c, "stage-grassland", "scenes/stage-grassland.png", 32, true)
