-- pl-bvd-2-perch.lua : pal "pl-bvd-2" (pot-hut creature) on a small wooden stump perch
-- PHASE: BLOCK-IN (flat silhouettes only)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-bvd-2-perch-20261120-170900/"
local GV = dofile(D .. "gvlib/gvlib.lua")

-- palette (pal's key colours, quantized to spec): plum outline, purple roof, mint/teal pot,
-- wood stump/staff, lilac pennant, blue drop, pale grey-cream glints
GV.C.ol1, GV.C.ol2, GV.C.ol3 = "#2b1c26", "#2b1c26", "#2b1c26"

local prPurple = GV.ramp("#582b7f")
local ROOF = GV.ramp("#674074", { gloss = "#dbb1d4", rim = "#dbb1d4", shade = "#582b7f",
                                  deep = prPurple.deep, bounce = prPurple.bounce, pale = false })
local POT = GV.ramp("#86cebe", { shade = "#4b9383", deep = "#3f6972", bounce = "#528f87" })
local FOOT = GV.ramp("#205252", { rim = "#3f6972", gloss = false })
local STUMP = GV.ramp("#8a6a58", { gloss = false, rim = "#dab48d", shade = "#5a4050",
                                   deep = GV.ramp("#8a6a58").deep, bounce = "#6e5147" })
local POLE = GV.ramp("#9a6a45", { gloss = false, rim = "#b48a70", shade = "#5b3a2c" })
local FLAG = GV.ramp("#dbb1d4", { gloss = false })
local DROP = GV.ramp("#7ac8f0", { gloss = false })

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 0 }

c:ground(18.5, 30, 8, 1.5, "#4a3a68")   -- soft shadow ellipse under the perch

-- stump perch: rounded wooden block, top face ellipse
local stump = c:rrect(13, 24, 24, 31, 2):add(c:ellipse(18.5, 24.5, 5.5, 2))
-- pot: rounded barrel body, gently tapering to the foot
local potm = c:rrect(10, 10, 27, 24, 4)
-- pot foot band (dark pot bottom)
local footm = c:rect(12, 22, 25, 24)
-- roof: wide felt slab, overhangs the body
local roofm = c:rrect(8, 5, 27, 11, 1)
-- staff + pennant (pal's stick, left side, in front)
local polem = c:rect(9, 4, 10, 10)
local flagm = c:rect(5, 5, 8, 5):add(c:rect(5, 4, 7, 4))
-- floating blue drop accent (right of body)
local dropm = c:rect(30, 13, 30, 13):add(c:rect(29, 14, 31, 14):add(c:rect(30, 15, 30, 15)))

local p = c:build{
  { "stump", stump, STUMP, { cres = 1, deep = 0 } },
  { "pot", potm, POT, { cres = 3, deep = 1, gloss = { 12, 14 } } },
  { "foot", footm, FOOT, { flat = true } },
  { "roof", roofm, ROOF, { cres = 2, deep = 1, gloss = { 10, 7 } } },
  { "pole", polem, POLE, { flat = true, rim = false } },
  { "flag", flagm, FLAG, { flat = true } },
  { "drop", dropm, DROP, { flat = true } },
}

-- stump top face (lit from above)
c:fill(c:ellipse(18.5, 24.5, 4.5, 1.5), "#b48a70")
c:fill(c:ellipse(17.5, 24, 3.5, 1):clip(stump), "#dab48d")

-- face: big dark eyes + glints, mouth, cheeks
c:fill(c:rect(14, 13, 16, 16), "#2b1c26")
c:fill(c:rect(21, 13, 23, 16), "#2b1c26")
c:px(14, 14, "#d2d9d5")
c:px(21, 14, "#d2d9d5")
c:fill(c:rect(17, 19, 18, 19), "#2b1c26")

-- TEXTURE: hand-placed, tone-on-tone, <=1 shade step, follows the form
c:px(23, 18, "#4b9383"); c:px(24, 21, "#4b9383"); c:px(24, 15, "#4b9383") -- pot: dither at shade border
c:px(15, 25, "#b48a70"); c:px(21, 25, "#b48a70"); c:px(17, 23, "#b48a70") -- stump: growth-ring marks
c:px(16, 29, "#5a4050"); c:px(21, 29, "#5a4050"); c:px(19, 27, "#5a4050") -- stump: wall grain
c:px(16, 9, "#582b7f"); c:px(21, 9, "#582b7f")                            -- roof: felt speckle
c:px(13, 27, "#dab48d"); c:px(24, 28, "#dab48d")                          -- stump: edge wear
c:px(9, 4, "#b48a70"); c:px(10, 4, "#b48a70")                             -- staff: lit top
for y = 5, 10 do c:px(10, y, "#5b3a2c") end                               -- staff: shade on right
c:px(29, 14, "#d2d9d5")                                                   -- drop: glint

c:fill(c:rect(12, 17, 13, 18), "#dbb1d4")
c:fill(c:rect(22, 17, 23, 18), "#dbb1d4")

local t = c:save(D .. "out/pl-bvd-2-perch.aseprite", D .. "out/pl-bvd-2-perch.png")
assert(t.semi == 0 and t.margin >= 1, "CHECK FAIL margin=" .. t.margin .. " semi=" .. t.semi)
pcall(function()
  local f = io.open(D .. "out/report.txt", "w")
  f:write(GV.report(t), "\n", "bbox ", t.bbox[1], ",", t.bbox[2], "..", t.bbox[3], ",", t.bbox[4], "\n")
  f:close()
end)
print(GV.report(t))
