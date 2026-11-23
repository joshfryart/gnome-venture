-- pl-bvd-4 perch: chibi hermit-potato pal on a small sandy mound perch (36x36)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-bvd-4-perch-20261120-171412/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1 }

local tan  = GV.ramp("#c9934c")
local sand = GV.ramp("#a9593f")
local gold = GV.ramp("#cdb369")
local blue = GV.ramp("#71bde3")
local dark = GV.ramp("#762125")

local glow = c:mask(); glow:set(4, 5); glow:set(4, 6)

local claw1 = c:ellipse(27, 13, 2.5, 2)
local claw2 = c:ellipse(28.5, 16.5, 2.5, 2)
claw1:add(claw2)
local crab = c:ellipse(29, 30, 2, 1)

local parts = c:build{
  { "sparkle", glow, "gold", { flat = true, gloss = false, solid = false } },
  { "mound", c:rrect(8, 26, 27, 31, 3), sand, { gloss = false } },
  { "footL", c:rrect(9, 22, 12, 26, 1), dark, { flat = true, gloss = false } },
  { "footR", c:rrect(23, 22, 26, 26, 1), dark, { flat = true, gloss = false } },
  { "crab", crab, dark, { flat = true, gloss = false } },
  { "blob", c:ellipse(17.5, 17.5, 10, 8), tan, { gloss = { 13, 12 }, cres = 3 } },
  { "claw", claw1, gold, { flat = true, gloss = { 26, 11 } } },
  { "earL", c:ellipse(9.5, 8.5, 3.5, 3), blue, { cres = 1, gloss = false } },
  { "earR", c:ellipse(23.5, 8, 4, 3), blue, { cres = 1, gloss = false } },
}

-- face: two big round eyes, tiny line mouth, 1px lashes
c:eye(11, 12); c:eye(21, 12)
c:px(17, 19, "#762125"); c:px(18, 19, "#762125")
c:px(10, 11, "#2a1a10"); c:px(26, 11, "#2a1a10")

-- texture: potato speckle on blob (tone-on-tone, follows curvature)
c:px(14, 20, GV.R.gold.shade)
c:px(21, 13, GV.R.gold.shade)
c:px(19, 22, GV.R.gold.shade)
c:px(15, 15, GV.R.gold.shade)
c:px(24, 19, GV.R.gold.shade)
c:px(12, 18, GV.R.gold.bounce)
c:px(20, 20, GV.R.gold.bounce)
-- sand grains on the mound
c:px(12, 28, "#8b4c34"); c:px(17, 29, "#8b4c34"); c:px(23, 28, "#8b4c34")
c:px(11, 30, "#c59c63"); c:px(19, 30, "#c59c63"); c:px(25, 30, "#c59c63")
-- 1px dither at blob light/shade border
c:px(23, 22, "#9a7139")

-- claw notch + crab face/glint + sparkle glint
c:px(28, 15, "#2a1a10")
c:px(28, 29, "#4a2c1a"); c:px(30, 29, "#4a2c1a"); c:px(29, 30, "#39a1d5")
c:px(4, 7, "#f2e4c0")

-- critique fixes: lit sand lip on mound top (left half), small sheen on each ear
for x = 11, 19 do c:px(x, 26, "#cdb369") end
c:px(10, 26, "#d5c081"); c:px(12, 27, "#c59c63")
c:px(7, 7, "#9ff1f1"); c:px(8, 6, "#9ff1f1")
c:px(22, 6, "#9ff1f1"); c:px(23, 7, "#9ff1f1")

-- soft ground shadow
c:ground(17.5, 31.5, 12, 1.5)

local t = c:save(D .. "out/pl-bvd-4-perch.aseprite", D .. "out/pl-bvd-4-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 1)
