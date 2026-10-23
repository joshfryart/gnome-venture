-- Great White Owl (boss, tundra lair "Den of the Great White Owl"): a round-headed snowy owl
-- mantling, both wings raised high and spread like a cape, gripping a frost rock with dark talons.
-- No ear tufts, no crown (unlike the snow-owl monarch). Fierce gold-ringed eyes under angled brows,
-- dark flecked barring, and a faint aurora (mint green / violet bands) stitched along the wing edges.
-- Families: soil palest #f1ece0 (pale cream plumage, cream-safe gloss), gold (eye rings),
-- dusk (beak), stone (rock, flecks); aurora borrowed from water gloss #c8ecdc and dusk rim #a894dc.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local FILE = "creature-boss-lm-na-4-lair-den-of-the-great-white-owl"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function mir(pts) local o = {} for i, p in ipairs(pts) do o[i] = { 64 - p[1], p[2] } end return o end

-- raised wing (left), fingers pointing out to the left; right wing mirrored
local wingPts = {
  { 26, 31 }, { 18, 19 }, { 10, 8 }, { 8, 14 }, { 11, 17 }, { 8, 23 }, { 12, 26 },
  { 9, 32 }, { 13, 35 }, { 11, 41 }, { 16, 42 }, { 16, 47 }, { 25, 45 },
}
local wingL = c:poly(wingPts)
local wingR = c:poly(mir(wingPts))

-- aurora bands follow the outer (finger) edge: violet outermost, mint inside
local function bands(w, dx)
  local v = w:copy():cut(w:shift(dx * 3, 0))
  local g = w:copy():cut(w:shift(dx * 6, 0)):cut(v)
  return v, g
end
local vL, gL = bands(wingL, 1)
local vR, gR = bands(wingR, -1)

local rock = c:poly({ { 13, 57 }, { 16, 51 }, { 24, 49 }, { 33, 50 }, { 41, 48 }, { 49, 51 }, { 52, 57 } })
local body = c:ellipse(31.5, 40, 12, 11)
local footL = c:rrect(22, 47, 28, 52, 2)
local footR = c:rrect(35, 47, 41, 52, 2)
local head = c:ellipse(31.5, 22, 14, 11.5)
local ringL = c:ellipse(24, 23, 4.5, 4.5)
local ringR = c:ellipse(39, 23, 4.5, 4.5)
local beak = c:poly({ { 29, 26 }, { 35, 26 }, { 33, 32 }, { 31, 32 } })

local cream  = GV.ramp("#f1ece0")
local wingC  = GV.ramp("#e8e0cc")
local mint   = GV.ramp("#c8ecdc")
local violet = GV.ramp("#a894dc")
local stone  = GV.ramp("#5b6470")

local p = c:build{
  { "rock",  rock, stone },
  { "wingL", wingL, wingC },
  { "wingR", wingR, wingC },
  { "gL", gL, mint,   { light = wingL, contour = false, gloss = false, contact = false } },
  { "vL", vL, violet, { light = wingL, contour = false, gloss = false, contact = false } },
  { "gR", gR, mint,   { light = wingR, contour = false, gloss = false, contact = false } },
  { "vR", vR, violet, { light = wingR, contour = false, gloss = false, contact = false } },
  { "body",  body, cream, { stitch = { side = "lit" } } },
  { "footL", footL, cream, { gloss = false } },
  { "footR", footR, cream, { gloss = false } },
  { "head",  head, cream },
  { "ringL", ringL, "gold", { flat = true, gloss = false } },
  { "ringR", ringR, "gold", { flat = true, gloss = false } },
  { "beak",  beak, "dusk", { flat = true } },
}

-- dark bean flecks (snowy owl barring), evenly varied
local fleck, glint = "#5b6470", "#8b8f96"
for _, f in ipairs({ { 18, 30 }, { 21, 37 }, { 15, 22 }, { 45, 30 }, { 42, 37 }, { 48, 22 } }) do
  c:spot(c:rect(f[1], f[2], f[1] + 2, f[2] + 1), fleck, glint)
end
for _, f in ipairs({ { 27, 40 }, { 35, 40 }, { 31, 45 } }) do
  c:paint({ "b.b", ".b." }, f[1], f[2], { b = fleck })
end

-- stitched aurora join: seam down the inner edge of the mint band
-- (seam lands only on parts)
c:seam({ { 16, 44 }, { 14, 36 }, { 15, 27 }, { 14, 18 } })
c:seam({ { 47, 44 }, { 49, 36 }, { 48, 27 }, { 49, 18 } })

-- fierce brows
c:paint({ "bbb.....", ".bbbbb..", "....bbbb" }, 19, 16, { b = "#4a2c1a" })
c:paint({ ".....bbb", "..bbbbb.", "bbbb...." }, 36, 16, { b = "#4a2c1a" })

-- eyes
c:eye(22, 21); c:eye(37, 21)

-- talons
for _, x in ipairs({ 22, 25, 28, 35, 38, 41 }) do c:paint({ "t", "t" }, x, 52, { t = "#2a1a10" }) end

local t = c:save(D .. "final/aseprite/ph/" .. FILE .. ".aseprite", PNG .. FILE .. ".png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
