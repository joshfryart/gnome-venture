-- wonder-the-amber-woods.lua : golden-hour Baltic woods; amber glows in sap with seeds inside; a big piece half-dug, brush and trowel beside it.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, c, W, H = L.GV, L.new(), L.W, L.H
local SLUG = "wonder-the-amber-woods"
local AMB = GV.ramp("#f0a020", { gloss = "#ffe49a", dot = "#fff3c8", rim = "#ffd070", shade = "#c8721a", deep = "#8a4a14", bounce = "#e08a28" })

L.sky(c, "warm", 70)
c:fill(c:ellipse(150, 40, 14, 14), "#fdf2d8")
-- far tree line: layered dark-green pine silhouettes
local function pineflat(x, y, h, col)
  for k = 0, 3 do
    local w = 2 + (3 - k) * 2; local yy = y - k * (h // 4)
    c:fill(c:poly({ {x - w, yy}, {x, yy - h // 3}, {x + w + 1, yy} }), col)
  end
  c:fill(c:rect(x, y, x, y + 4), col)
end
c:fill(L.below(c, function(x) return 70 - 3 * math.sin(x / 11) end), "#8fa860")
for i = 0, 15 do pineflat(8 + i * 15 + (i % 3) * 3, 72, 20 + (i % 3) * 6, "#6f9658") end
c:fill(L.below(c, function(x) return 80 + 2 * math.sin(x / 9 + 1) end), "#5c8a48")
for i = 0, 11 do pineflat(14 + i * 21 + (i % 2) * 6, 82, 24 + (i % 4) * 4, "#3f7040") end
-- forest floor
local floor = L.below(c, function(x) return 86 + 2 * math.sin(x / 20) end)
c:part(floor, GV.ramp("#7a8a40"), { cres = 6, deep = 9, outline = false, gloss = false })
c:fill(L.below(c, function(x) return 108 + 3 * math.sin(x / 16 + 1) end), "#9a6b3f")
-- golden light shafts through the trunks
for _, x in ipairs({ 40, 76, 170, 206 }) do
  for y = 20, 110 do c:px(x + (y - 20) // 4, y, "#f8dba8") end
end

-- birch trunks (cream, dark marks) with amber beads in sap runs
local function birch(x, w, top)
  c:part(c:rect(x, top, x + w - 1, 112), GV.ramp("#f2ead0", { shade = "#c8bc9a", deep = "#8a7e68" }), { cres = math.max(2, w // 3), deep = w // 2, gloss = false, outline = false, contour = false })
  for y = top + 6, 106, 9 do c:fill(c:rect(x + 1, y, x + w - 2, y), "#4a3a30"); c:px(x + 2, y + 1, "#4a3a30") end
end
local function bead(x, y, r)
  c:part(c:ellipse(x, y, r, r * 1.2), AMB, { cres = 2, deep = 3, gloss = false, outline = false, contour = "#8a4a14" })
  c:px(x - 1, y - 1, "#fff3c8")
end
birch(22, 8, 0); birch(54, 6, 0); birch(94, 7, 0); birch(150, 8, 0); birch(190, 6, 0); birch(226, 9, 0)
bead(25, 40, 2); bead(26, 62, 3); bead(56, 30, 2); bead(96, 50, 2); bead(153, 36, 3); bead(152, 70, 2); bead(192, 58, 2); bead(229, 46, 3); bead(231, 74, 2)
-- sap run lines
for _, r in ipairs({ {25,42,52},{26,65,74},{153,39,48},{229,49,60} }) do c:fill(c:rect(r[1], r[2], r[1], r[3]), "#e8a317") end
-- pine trunks and canopy at the sides, dark framing
local function bigpine(x, top)
  c:part(c:rect(x - 3, top, x + 3, 120), GV.ramp("#7a4a1f"), { cres = 3, deep = 5, gloss = false, outline = false, contour = false })
  for k = 0, 4 do
    local w = 10 + (4 - k) * 6; local yy = top + 12 + k * 10
    c:part(c:poly({ {x - w, yy}, {x, yy - 14}, {x + w, yy} }), GV.ramp("#2f5a2a"), { cres = 3, deep = 5, gloss = false, outline = false })
  end
end
bigpine(8, 0); bigpine(238, -6)
-- ferns and mushrooms
local function fern(x, y)
  for k = -3, 3 do c:px(x + k, y - 3 + math.abs(k), "#4f9a45"); c:px(x + k, y - 2 + math.abs(k), "#7ab55c") end
  c:px(x, y - 4, "#a4b86a")
end
for _, p in ipairs({ {40,100},{74,104},{168,102},{208,106},{120,92},{136,94},{30,118},{222,120} }) do fern(p[1], p[2]) end
local function shroom(x, y)
  c:part(c:rect(x - 1, y, x + 1, y + 4), GV.ramp("#f2e4c0"), { flat = true, gloss = false, outline = false })
  c:part(c:ellipse(x, y, 4, 3):cut(c:rect(x - 5, y + 1, x + 5, y + 5)), GV.ramp("#d6322b"), { cres = 1, deep = 2, gloss = false, outline = false })
  c:px(x - 2, y - 1, "#f2e4c0"); c:px(x + 1, y - 2, "#f2e4c0")
end
shroom(60, 114); shroom(66, 118); shroom(190, 116)
-- amber nuggets scattered on the ground, a few with seeds
local function nugget(x, y, rx, ry, seed)
  c:part(c:ellipse(x, y, rx, ry), AMB, { cres = 2, deep = 4, gloss = false })
  if seed then c:px(x, y, "#4a2c1a"); c:px(x + 1, y, "#4a2c1a"); c:px(x, y + 1, "#7a4a1f") end
  c:px(x - rx + 2, y - 1, "#fff3c8")
end
nugget(44, 122, 4, 3, true); nugget(88, 126, 3, 2, false); nugget(176, 124, 4, 3, true); nugget(210, 128, 3, 2, false); nugget(18, 126, 3, 2, false)

-- THE focal piece: big amber chunk half out of a dug hole, with a seed inside
local AX, AY = 120, 106
local hole = c:ellipse(AX, AY + 8, 34, 14)
c:part(hole, GV.ramp("#7a4a1f", { shade = "#5a3416", deep = "#3d2a1c" }), { cres = 7, deep = 11, gloss = false, outline = false, contour = false })
-- spilled soil mound
c:part(c:ellipse(AX - 38, AY + 18, 12, 5), GV.ramp("#9a6b3f"), { cres = 2, deep = 4, gloss = false })
c:part(c:ellipse(AX + 40, AY + 17, 10, 4), GV.ramp("#9a6b3f"), { cres = 2, deep = 4, gloss = false })
-- roots over the hole
c:limb({ {AX - 30, AY + 4}, {AX - 20, AY + 12}, {AX - 8, AY + 18} }, 3)
local chunk = c:poly({ {AX - 20, AY + 8}, {AX - 22, AY - 6}, {AX - 12, AY - 18}, {AX + 4, AY - 22}, {AX + 18, AY - 14}, {AX + 24, AY}, {AX + 18, AY + 12}, {AX, AY + 16}, {AX - 14, AY + 14} })
c:part(chunk, AMB, { cres = 8, deep = 12 })
-- inner layers: a paler band for the glow
c:fill(c:ellipse(AX - 4, AY - 8, 8, 5), "#f8c04a")
-- the seed: a little plump seed with a leaf-sprig frozen in the resin
c:part(c:ellipse(AX, AY - 1, 6, 4), GV.ramp("#4a2c1a", { rim = "#7a4a1f" }), { flat = true, gloss = false, outline = false })
c:px(AX - 2, AY - 2, "#9a6b3f"); c:px(AX - 1, AY - 3, "#9a6b3f")
c:fill(c:rect(AX + 6, AY - 4, AX + 10, AY - 4), "#4f9a45"); c:px(AX + 8, AY - 6, "#4f9a45"); c:px(AX + 10, AY - 6, "#4f9a45"); c:px(AX + 9, AY - 5, "#4f9a45")
-- tiny air bubbles in the resin
c:px(AX - 12, AY + 4, "#ffe49a"); c:px(AX + 12, AY + 6, "#ffe49a"); c:px(AX + 14, AY - 8, "#ffe49a")
-- glints (big: this is the jewel)
for _, p in ipairs({ {AX - 14, AY - 12}, {AX - 13, AY - 12}, {AX - 14, AY - 11} }) do c:px(p[1], p[2], "#fff3c8") end
c:px(AX - 18, AY - 20, "#fff3c8"); c:px(AX - 18, AY - 21, "#fff3c8"); c:px(AX - 19, AY - 20, "#fff3c8"); c:px(AX - 17, AY - 20, "#fff3c8"); c:px(AX - 18, AY - 19, "#fff3c8")
-- a tiny soft brush and trowel laid beside
c:part(c:rect(AX + 30, AY + 14, AX + 46, AY + 16), GV.ramp("#c9a96e"), { cres = 1, deep = 2, gloss = false, outline = false, contour = "#4a2c1a" })
c:part(c:rect(AX + 44, AY + 12, AX + 50, AY + 18), GV.ramp("#f2e4c0"), { flat = true, gloss = false, outline = false, contour = "#4a2c1a" })
c:part(c:rect(AX - 54, AY + 18, AX - 40, AY + 19), GV.ramp("#7a4a1f"), { cres = 1, deep = 1, gloss = false, outline = false })
c:part(c:poly({ {AX - 40, AY + 16}, {AX - 32, AY + 18.5}, {AX - 40, AY + 21} }), GV.ramp("#b8bcc4"), { flat = true, gloss = false, outline = false, contour = "#2a1a10" })

-- a curious red squirrel on a stump at the right
c:part(c:rect(172, 98, 190, 112), GV.ramp("#9a6b3f"), { cres = 4, deep = 6, gloss = false })
c:part(c:ellipse(181, 98, 9, 2), GV.ramp("#c9a96e"), { flat = true, gloss = false, outline = false })
local SX, SY = 181, 90
c:part(c:ellipse(SX + 8, SY - 6, 5, 11), GV.ramp("#f08a24"), { cres = 2, deep = 4, gloss = false })
c:part(c:ellipse(SX, SY, 5, 6), GV.ramp("#d6602a"), { cres = 2, deep = 4, gloss = false })
c:part(c:ellipse(SX - 1, SY - 8, 5, 4.5), GV.ramp("#d6602a"), { cres = 2, deep = 4, gloss = false })
c:part(c:poly({ {SX - 5, SY - 11}, {SX - 4, SY - 15}, {SX - 2, SY - 11} }), GV.ramp("#d6602a"), { flat = true, gloss = false })
c:part(c:poly({ {SX + 1, SY - 11}, {SX + 2, SY - 15}, {SX + 4, SY - 11} }), GV.ramp("#d6602a"), { flat = true, gloss = false })
c:eye(SX - 5, SY - 10, true); c:eye(SX - 1, SY - 10, true)
c:part(c:ellipse(SX - 2, SY - 4, 3, 2), GV.ramp("#f2e4c0"), { flat = true, gloss = false, outline = false })
c:px(SX - 3, SY - 6, "#2a1a10")
c:ground(AX, AY + 24, 36, 3)

L.finish(c, SLUG)
