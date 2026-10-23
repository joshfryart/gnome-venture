-- Guardian of Condor's Crag: the Grand Condor, legendary mountain lair boss.
-- Black-umber plumage (dusk-dark ramps), white neck ruff, bare orange-pink head with a
-- fleshy comb, huge wings half raised in a V with fingered primaries, perched on a crag.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- ramps: dusk-dark plumage pulled toward umber, ivory ruff, orange-pink bare skin
local wing = GV.ramp("#33263f", { gloss = "#a894dc", dot = "#c3b2ea", rim = "#6e5a96", shade = "#251a33", deep = "#1a1226", bounce = "#3e2e48" })
local body = GV.ramp("#46344e", { gloss = "#a894dc", dot = "#c3b2ea", rim = "#7b66b4", shade = "#2e2038", deep = "#1e1432", bounce = "#3e2e48" })
local ruff = GV.ramp("#f1ece0", { dot = "#fff3c8", shade = "#d8c49a", bounce = "#e6d4ac", deep = "#9a6b3f" })
local head = GV.ramp("#ec8a6c", { gloss = "#ffc8a0", dot = "#ffe2c0", rim = "#f6a882", shade = "#c4605a", deep = "#8a3a44", bounce = "#d47660" })
local comb = GV.ramp("#b8452f", { shade = "#8a2a32", deep = "#6b1b2c", bounce = "#9a3a34" })
local beak = GV.ramp("#e2d2b0", { shade = "#b8a48a", deep = "#6a5a5a", bounce = "#c8b496" })

local function mirror(pts) local o = {} for i, p in ipairs(pts) do o[i] = { 63 - p[1], p[2] } end return o end
local function mx(m) local o = c:mask() m:each(function(x, y) o:set(62 - x, y) end) return o end

-- crag: jagged stone ledge with two peaks under the perch
local crag = c:poly({ {12, 57}, {13, 51}, {16, 46}, {19, 43}, {22, 48}, {27, 49}, {36, 49}, {40, 47}, {43, 42}, {47, 46}, {50, 57} })

-- left wing raised in a V: arm up beside the head, scalloped secondaries on the trailing edge
local wingL = c:poly({ {27, 42}, {23, 32}, {20, 24}, {16, 19}, {11, 20}, {8, 25}, {8, 32}, {10, 38}, {15, 43}, {21, 46} })
for _, p in ipairs({ {9, 33}, {11, 37}, {14, 41}, {18, 44} }) do wingL:add(c:ellipse(p[1], p[2], 2, 2)) end
-- fingered primaries fanning up and out from the wrist
local fingL = c:line({ {18, 20}, {18, 9} }, 3):add(c:line({ {15, 21}, {12, 10} }, 3)):add(c:line({ {12, 23}, {8, 14} }, 3)):add(c:line({ {10, 26}, {7, 21} }, 2))
local wingR, fingR = mx(wingL), mx(fingL)
-- battle damage: one right primary snapped short
fingR:cut(c:rect(47, 6, 52, 15))

local bodyM = c:ellipse(31.5, 41, 10, 8)
-- white fluffy ruff with a scalloped lower edge
local ruffM = c:ellipse(31.5, 31, 12, 4)
for _, x in ipairs({ 21.5, 26.5, 31.5, 36.5, 41.5 }) do ruffM:add(c:ellipse(x, 34, 2.5, 2.5)) end
local headM = c:ellipse(31.5, 20.5, 10, 9)
-- fleshy comb (caruncle) on the crown, three lobes
local combM = c:ellipse(29.5, 10, 2, 2):add(c:ellipse(33.5, 10, 2, 2)):add(c:ellipse(31.5, 9, 2, 2.5)):add(c:ellipse(31.5, 13.5, 2.5, 2))
local beakM = c:poly({ {28, 21}, {36, 21}, {37, 24}, {36, 27}, {34, 29}, {32, 31}, {30, 31}, {31, 29}, {29, 25} })
local feet = c:rrect(23, 47, 28, 50, 1):add(c:rrect(35, 47, 40, 50, 1))

local whole = wingL:copy():add(wingR):add(bodyM):add(headM)
c:build{
  { "fingL", fingL, wing, { light = whole, gloss = false, rim = false } },
  { "fingR", fingR, wing, { light = whole, gloss = false } },
  { "wingL", wingL, wing, { light = whole } },
  { "wingR", wingR, wing, { light = whole, gloss = false } },
  { "crag",  crag,  "stone" },
  { "body",  bodyM, body, { light = whole } },
  { "feet",  feet,  "leg" },
  { "ruff",  ruffM, ruff },
  { "head",  headM, head },
  { "comb",  combM, comb, { gloss = { 30, 9 } } },
  { "beak",  beakM, beak, { gloss = { 30, 23 } } },
}

-- covert feather chevrons on the wings
for _, p in ipairs({ {12, 26}, {15, 32}, {19, 38} }) do
  c:paint({ ".r.", "r.r" }, p[1], p[2], { r = "#5a4878" })
  c:paint({ ".r.", "r.r" }, 62 - p[1] - 2, p[2], { r = "#5a4878" })
end
-- hooked beak: dark tip and nostril
c:px(31, 30, "#6a5a5a"); c:px(32, 30, "#6a5a5a"); c:px(33, 23, "#6a5a5a")
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
c:paint({ "..s", ".s.", "s.." }, 40, 11, { s = "#8a3a44" }); c:paint({ "..s", ".s.", "s.." }, 38, 22, { s = "#8a3a44" })
-- neck wrinkles where the bare skin meets the ruff
c:paint({ "w.", ".w" }, 24, 25, { w = "#c4605a" })
c:paint({ ".w", "w." }, 38, 25, { w = "#c4605a" })

local t = c:save(D .. "final/aseprite/ph/creature-boss-lm-sa-2-lair-condor-s-crag.aseprite",
  PNG .. "creature-boss-lm-sa-2-lair-condor-s-crag.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
