-- Guardian of Condor's Crag: the Grand Condor, legendary mountain lair boss.
-- Black-umber plumage (dusk-dark ramps), white neck ruff, bare orange-pink head with a
-- fleshy comb, huge wings half spread (mantling) with fingered primaries, perched on a crag.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- ramps: dusk-dark plumage nudged toward umber, ivory ruff, orange-pink bare skin
local wing  = GV.ramp("#3b2a48", { gloss = "#a894dc", dot = "#c3b2ea", rim = "#6e5a96", shade = "#291d3e", deep = "#1e1432", bounce = "#46344e" })
local body  = GV.R.dusk
local ruff  = "cream"
local head  = GV.ramp("#ea8a6e", { gloss = "#ffc8a0", dot = "#ffe2c0", rim = "#f6a882", shade = "#c4605a", deep = "#8a3a44", bounce = "#d47660" })
local comb  = GV.ramp("#b8452f", { shade = "#8a2a32", deep = "#6b1b2c" })
local beak  = GV.ramp("#d8ccb4", { shade = "#a89c90", deep = "#6a6070", bounce = "#b8aa98" })
local band  = GV.ramp("#d6d0c6", { shade = "#a8a2a8", deep = "#7a7088", bounce = "#b4aab0" })

local function mirror(pts) local o = {} for i, p in ipairs(pts) do o[i] = { 63 - p[1], p[2] } end return o end

-- crag: jagged dark stone peak under the perch
local crag = c:poly({ {12, 57}, {14, 51}, {18, 48}, {22, 50}, {27, 47}, {33, 48}, {38, 46}, {44, 49}, {48, 48}, {51, 52}, {52, 57} })

-- half-spread (mantling) wings: wrist high beside the head, primaries hanging down and out
local wL = { {25, 31}, {20, 22}, {14, 17}, {9, 19}, {7, 27}, {8, 38}, {13, 44}, {21, 46}, {26, 42} }
local wingL = c:poly(wL)
local wingR = c:poly(mirror(wL))
-- fingered primaries at the outer tips
local fingL = c:line({ {9, 37}, {7, 46} }, 3):add(c:line({ {13, 41}, {12, 50} }, 3)):add(c:line({ {17, 43}, {17, 51} }, 3))
local fingR = c:line({ {54, 37}, {56, 46} }, 3):add(c:line({ {50, 41}, {51, 50} }, 3)):add(c:line({ {46, 43}, {46, 51} }, 3))
-- pale secondary band across each wing (the condor's white wing patch)
local bL = { {22, 33}, {16, 25}, {11, 24}, {10, 28}, {14, 29}, {20, 37} }
local bandL = c:poly(bL):clip(wingL)
local bandR = c:poly(mirror(bL)):clip(wingR)

local bodyM = c:ellipse(31.5, 41, 11, 9)
-- white fluffy ruff with a scalloped lower edge
local ruffM = c:ellipse(31.5, 31.5, 12, 4.5)
for _, x in ipairs({ 21.5, 26.5, 31.5, 36.5, 41.5 }) do ruffM:add(c:ellipse(x, 35, 2.5, 2.5)) end
local headM = c:ellipse(31.5, 20, 10.5, 9.5)
-- fleshy comb (caruncle) on the crown, three lobes
local combM = c:ellipse(28, 10.5, 2.5, 2.5):add(c:ellipse(32, 9, 2.5, 2.5)):add(c:ellipse(36, 10.5, 2.5, 2.5)):add(c:rect(26, 10, 38, 13))
local beakM = c:poly({ {29, 22}, {35, 22}, {36, 26}, {35, 30}, {33, 32}, {31, 31}, {32, 29}, {30, 27} })
local feet = c:rrect(23, 48, 28, 51, 1):add(c:rrect(35, 48, 40, 51, 1))

local whole = wingL:copy():add(wingR):add(bodyM):add(headM)
c:build{
  { "crag",  crag,  "stone" },
  { "fingL", fingL, wing, { light = whole, gloss = false } },
  { "fingR", fingR, wing, { light = whole, gloss = false } },
  { "wingL", wingL, wing, { light = whole } },
  { "wingR", wingR, wing, { light = whole, gloss = false } },
  { "bandL", bandL, band, { light = whole, gloss = false } },
  { "bandR", bandR, band, { light = whole, gloss = false } },
  { "body",  bodyM, body, { light = whole } },
  { "feet",  feet,  "leg" },
  { "ruff",  ruffM, ruff },
  { "comb",  combM, comb, { gloss = false } },
  { "head",  headM, head },
  { "beak",  beakM, beak, { gloss = { 30, 23 } } },
}

-- stitched join: seam along the ruff hem, collar button at its centre
c:seam({ { 21, 33 }, { 42, 33 } })
c:button(30, 31)
-- talons gripping the crag
c:paint({ "t.t.t" }, 23, 52, { t = "#2a1a10" })
c:paint({ "t.t.t" }, 36, 52, { t = "#2a1a10" })

-- face: wide locked eyes, heavy scowling brows, battle scar across the bare crown
c:eye(23, 16); c:eye(35, 16)
c:paint({ "bb....", "..bbb." }, 22, 13, { b = "#8a3a44" })
c:paint({ ".bbb..", "....bb" }, 35, 13, { b = "#8a3a44" })
c:paint({ "s...", ".s..", "..s.", "...s" }, 37, 21, { s = "#fff0d8" })
-- nostril
c:px(32, 24, "#6a6070")

local t = c:save(D .. "final/aseprite/ph/creature-boss-lm-sa-2-lair-condor-s-crag.aseprite",
  PNG .. "creature-boss-lm-sa-2-lair-condor-s-crag.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
