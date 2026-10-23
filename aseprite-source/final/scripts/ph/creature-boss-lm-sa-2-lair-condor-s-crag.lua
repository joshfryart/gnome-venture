-- Guardian of Condor's Crag: the Grand Condor, legendary mountain lair boss.
-- Black-umber plumage (dusk-dark ramps), white neck ruff, bare orange-pink head with a
-- fleshy comb, huge wings half raised in a V with fingered primaries, perched on a crag.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- ramps: dusk-dark plumage pulled toward umber, ivory ruff, orange-pink bare skin
local wing = GV.ramp("#33263f", { gloss = "#a894dc", dot = "#c3b2ea", rim = "#6e5a96", shade = "#251a33", deep = "#1a1226", bounce = "#3e2e48" })
local body = GV.ramp("#3c2c50", { gloss = "#a894dc", dot = "#c3b2ea", rim = "#7b66b4", shade = "#291d3e", deep = "#1e1432", bounce = "#46344e" })
local ruff = GV.ramp("#f1ece0", { dot = "#fff3c8", shade = "#d8c49a", bounce = "#e6d4ac", deep = "#9a6b3f" })
local head = GV.ramp("#ec8a6c", { gloss = "#ffc8a0", dot = "#ffe2c0", rim = "#f6a882", shade = "#c4605a", deep = "#8a3a44", bounce = "#d47660" })
local comb = GV.ramp("#b8452f", { shade = "#8a2a32", deep = "#6b1b2c", bounce = "#9a3a34" })
local beak = GV.ramp("#d8ccb4", { shade = "#a89c90", deep = "#6a6070", bounce = "#b8aa98" })
local band = GV.ramp("#d6d0c6", { shade = "#a8a2a8", deep = "#7a7088", bounce = "#b4aab0" })

local function mirror(pts) local o = {} for i, p in ipairs(pts) do o[i] = { 63 - p[1], p[2] } end return o end
local function mx(m) local o = c:mask() m:each(function(x, y) o:set(63 - x, y) end) return o end

-- crag: jagged stone ledge with two peaks under the perch
local crag = c:poly({ {12, 57}, {13, 51}, {16, 46}, {19, 44}, {22, 49}, {27, 49}, {36, 49}, {40, 48}, {44, 43}, {48, 46}, {51, 57} })

-- left wing raised in a V: arm up beside the head, scalloped secondaries on the trailing edge
local wingL = c:poly({ {27, 42}, {23, 32}, {19, 24}, {16, 17}, {12, 14}, {9, 16}, {7, 22}, {7, 30}, {10, 37}, {15, 43}, {21, 46} })
for _, p in ipairs({ {8, 31}, {10, 36}, {13, 40}, {17, 43} }) do wingL:add(c:ellipse(p[1], p[2], 2, 2)) end
-- fingered primaries fanning up and out from the wrist
local fingL = c:line({ {16, 15}, {16, 7} }, 3):add(c:line({ {12, 15}, {10, 8} }, 3)):add(c:line({ {9, 18}, {7, 13} }, 2))
-- pale secondary band (the condor's white wing patch)
local bandL = c:line({ {23, 40}, {18, 30}, {15, 22} }, 4):clip(wingL)
local wingR, fingR, bandR = mx(wingL), mx(fingL), mx(bandL)

local bodyM = c:ellipse(31.5, 41, 10, 8)
-- white fluffy ruff with a scalloped lower edge
local ruffM = c:ellipse(31.5, 31, 12, 4)
for _, x in ipairs({ 21.5, 26.5, 31.5, 36.5, 41.5 }) do ruffM:add(c:ellipse(x, 34, 2.5, 2.5)) end
local headM = c:ellipse(31.5, 20.5, 10, 9)
-- fleshy comb (caruncle) on the crown, three lobes
local combM = c:ellipse(31.5, 9.5, 2.5, 2.5):add(c:ellipse(31.5, 14, 2.5, 2)):add(c:rect(30, 9, 33, 21))
local beakM = c:poly({ {28, 21}, {36, 21}, {37, 24}, {36, 28}, {34, 31}, {31, 33}, {30, 31}, {32, 29}, {29, 25} })
local feet = c:rrect(23, 47, 28, 50, 1):add(c:rrect(35, 47, 40, 50, 1))

local whole = wingL:copy():add(wingR):add(bodyM):add(headM)
c:build{
  { "crag",  crag,  "stone" },
  { "fingL", fingL, wing, { light = whole, gloss = false, rim = false } },
  { "fingR", fingR, wing, { light = whole, gloss = false } },
  { "wingL", wingL, wing, { light = whole } },
  { "wingR", wingR, wing, { light = whole, gloss = false } },
  { "bandL", bandL, band, { light = whole, gloss = false } },
  { "bandR", bandR, band, { light = whole, gloss = false } },
  { "body",  bodyM, body, { light = whole } },
  { "feet",  feet,  "leg" },
  { "ruff",  ruffM, ruff },
  { "head",  headM, head },
  { "comb",  combM, comb, { gloss = { 30, 9 } } },
  { "beak",  beakM, beak, { gloss = { 30, 23 } } },
}

-- crag cracks
c:paint({ "k..", ".k.", ".k.", "..k" }, 19, 51, { k = "#4a2c1a" })
c:paint({ "..k", ".k.", "k.." }, 44, 50, { k = "#4a2c1a" })
-- stitched join: seam along the ruff hem, collar button at its centre
c:seam({ { 21, 33 }, { 42, 33 } })
c:button(30, 32)
-- talons gripping the crag
c:paint({ "t.t.t" }, 23, 51, { t = "#2a1a10" })
c:paint({ "t.t.t" }, 36, 51, { t = "#2a1a10" })

-- face: wide locked eyes, heavy scowling brows, battle scar across the bare cheek
c:eye(23, 17); c:eye(35, 17)
c:paint({ "bbb.....", ".bbbbb..", "...bbbbb" }, 21, 14, { b = "#4a2c1a" })
c:paint({ ".....bbb", "..bbbbb.", "bbbbb..." }, 35, 14, { b = "#4a2c1a" })
c:paint({ "s....", ".s...", "..s..", "...s.", "....s" }, 36, 22, { s = "#8a3a44" })
-- neck wrinkles where the bare skin meets the ruff
c:paint({ "w.", ".w" }, 24, 25, { w = "#c4605a" })
c:paint({ ".w", "w." }, 38, 25, { w = "#c4605a" })

local t = c:save(D .. "final/aseprite/ph/creature-boss-lm-sa-2-lair-condor-s-crag.aseprite",
  PNG .. "creature-boss-lm-sa-2-lair-condor-s-crag.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
