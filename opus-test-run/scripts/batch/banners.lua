-- banners.lua : 28 banners (9 lands, 5 places, 14 regions), 240x60 grid -> 480x120. One table drives sky/far/mid/ground colours and a
-- centrepiece plus two side props per key. Hem stitch top and bottom (banners only). Part E: opaque, no border, cap 24.
-- Usage: GV_ROOT=... Aseprite -b --script banners.lua   (env ONLY=key,key limits the run)
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local W, H = 240, 60
X.ramp("#7ab55c")   -- registers the moss gloss #bdd292 and rim #acc47d (far hills) as palette colours
local function R(base, shade, rim) return X.ramp(base, { shade = shade, deep = shade, bounce = shade, rim = rim or base, gloss = base, dot = base }) end
local OP = { gloss = false, cres = 2, deep = 0 }
local function P(c, m, r, o) c:part(m, r, o or OP) end

local RM = { -- ramps used by props (flat tones: base / shade)
  leaf = R("#7ab55c", "#4f9a45"), pine = R("#4f9a45", "#2f5a2a"), dleaf = R("#4f9a45", "#2f6a3a"), wood = R("#b07a45", "#8a4f2a", "#d9a660"),
  stone = R("#8b8f96", "#5b6470", "#c9c5bc"), cream = R("#f2e4c0", "#d8c49a"), snow = R("#f1ece0", "#c8ecdc"), red = R("#dd3a2a", "#ae2a2a", "#f2793a"),
  gold = R("#f5cf6a", "#e8a317"), sand = R("#f5cf6a", "#c9a96e"), clay = R("#e0501f", "#a8582f", "#f08a24"), water = R("#3f8fb0", "#25637d", "#a9d6ea"),
  petal = R("#e46a9b", "#b8452f", "#f6b8cf"), dusk = R("#7a5cc0", "#4e3a8a", "#c3b2ea"), teal = R("#8fcbd8", "#3f8fb0"), roof = R("#a8582f", "#8a4f2a", "#d9a660"),
}
local function tree(c, x, y, h, rr) P(c, c:rect(x - 1, y - h * 0.5, x + 1, y), RM.wood); P(c, c:ellipse(x, y - h * 0.7, h * 0.4, h * 0.35), rr or RM.leaf, { gloss = false, cres = 3, deep = 0 }) end
local function pine(c, x, y, h, rr) rr = rr or RM.pine
  P(c, c:rect(x - 1, y - 3, x + 1, y), RM.wood)
  P(c, c:poly({ { x - h * 0.3, y - 3 }, { x, y - h }, { x + h * 0.3, y - 3 } }), rr, { gloss = false, cres = 2, deep = 0 })
  P(c, c:poly({ { x - h * 0.22, y - h * 0.5 }, { x, y - h * 1.1 }, { x + h * 0.22, y - h * 0.5 } }), rr, { gloss = false, cres = 2, deep = 0 }) end
local function palm(c, x, y, h)
  P(c, c:poly({ { x, y }, { x + 2, y }, { x + 4, y - h }, { x + 2, y - h } }), RM.wood)
  for _, d in ipairs({ { -9, 3 }, { 9, 3 }, { -6, -4 }, { 6, -4 } }) do P(c, c:poly({ { x + 3, y - h }, { x + 3 + d[1], y - h + d[2] - 2 }, { x + 3 + d[1] * 1.5, y - h + d[2] + 1 }, { x + 3 + d[1] * 0.5, y - h + 2 } }), RM.pine, { gloss = false, cres = 1, deep = 0 }) end end
local function peak(c, x, top, w, base, rr, snow)
  P(c, c:poly({ { x - w, base }, { x, top }, { x + w, base } }), rr, { gloss = false, cres = 3, deep = 0 })
  if snow then c:fill(c:poly({ { x - w * 0.3, top + (base - top) * 0.3 }, { x, top }, { x + w * 0.3, top + (base - top) * 0.3 }, { x, top + (base - top) * 0.22 } }), "#f2e4c0") end end
local function house(c, x, y, w, h, wall, roof)
  P(c, c:rect(x, y - h, x + w, y), wall)
  P(c, c:poly({ { x - 2, y - h }, { x + w / 2, y - h - h * 0.7 }, { x + w + 2, y - h } }), roof, { gloss = false, cres = 2, deep = 0 })
  c:fill(c:rect(x + w / 2 - 1, y - 5, x + w / 2 + 1, y), "#8a4f2a") end
local function dome(c, x, y, r, rr) P(c, c:ellipse(x, y, r, r):cut(c:rect(x - r - 1, y + 1, x + r + 1, y + r + 2)), rr, { gloss = false, cres = 3, deep = 0 }) end
local function rock(c, x, y, rx, ry, rr) P(c, c:ellipse(x, y, rx, ry), rr or RM.stone, { gloss = false, cres = 2, deep = 0 }) end
local function cactus(c, x, y, h) local g = RM.leaf
  P(c, c:rrect(x - 2, y - h, x + 2, y, 1), g); P(c, c:rrect(x - 7, y - h * 0.6 - 6, x - 5, y - h * 0.6, 1), g, { gloss = false, flat = true }); P(c, c:rrect(x - 7, y - h * 0.6, x - 2, y - h * 0.6 + 2, 1), g, { gloss = false, flat = true })
  P(c, c:rrect(x + 5, y - h * 0.5 - 6, x + 7, y - h * 0.5, 1), g, { gloss = false, flat = true }); P(c, c:rrect(x + 2, y - h * 0.5, x + 7, y - h * 0.5 + 2, 1), g, { gloss = false, flat = true }) end
local function pagoda(c, x, y, wall, roof)
  for i = 0, 2 do local w = 9 - i * 2; local yy = y - i * 8
    P(c, c:rect(x - w + 2, yy - 7, x + w - 2, yy), wall); P(c, c:poly({ { x - w - 2, yy - 6 }, { x, yy - 11 }, { x + w + 2, yy - 6 } }), roof, { gloss = false, cres = 2, deep = 0 }) end end
local function tower(c, x, y, w, h, wall, roof)
  P(c, c:rect(x, y - h, x + w, y), wall); P(c, c:poly({ { x - 2, y - h }, { x + w / 2, y - h - 9 }, { x + w + 2, y - h } }), roof, { gloss = false, cres = 2, deep = 0 })
  c:fill(c:rect(x + w / 2 - 1, y - h + 4, x + w / 2, y - h + 7), "#f5cf6a") end
local function reed(c, x, y, h) c:fill(c:rect(x, y - h, x, y), "#4f9a45"); P(c, c:rrect(x - 1, y - h - 4, x + 1, y - h, 1), RM.wood, { gloss = false, flat = true }) end
local function sparkle(c, x, y) c:fill(c:rect(x, y - 1, x, y + 1), "#f5cf6a"); c:fill(c:rect(x - 1, y, x + 1, y), "#f5cf6a") end
local function boat(c, x, y) P(c, c:poly({ { x - 9, y - 3 }, { x + 9, y - 3 }, { x + 6, y + 1 }, { x - 6, y + 1 } }), RM.wood); c:fill(c:rect(x, y - 12, x, y - 3), "#8a4f2a"); c:fill(c:poly({ { x + 1, y - 12 }, { x + 7, y - 4 }, { x + 1, y - 4 } }), "#f2e4c0") end
local function sea(c, y0, y1, a, b) c:fill(c:rect(0, y0, W - 1, y1), a); c:fill(c:rect(0, y0, W - 1, y0 + 2), b)
  for y = y0 + 5, y1 - 1, 5 do for x = (y % 10 == 0) and 4 or 16, W - 1, 24 do c:fill(c:rect(x, y, x + 4, y), "#a9d6ea") end end end
local function flowers(c, list, col) for _, f in ipairs(list) do c:fill(c:rect(f[1], f[2], f[1] + 1, f[2] + 1), col or "#e46a9b") end end

local function facetpeak(c, x, top, w, base, lit, dark, snow)
  c:fill(c:poly({ { x - w, base }, { x, top }, { x + w, base } }), lit)
  c:fill(c:poly({ { x, top }, { x + w, base }, { x + w * 0.3, base }, { x - w * 0.1, top + (base - top) * 0.5 } }), dark)
  if snow then c:fill(c:poly({ { x - w * 0.3, top + (base - top) * 0.3 }, { x - w * 0.1, top + (base - top) * 0.22 }, { x + w * 0.05, top + (base - top) * 0.32 }, { x + w * 0.2, top + (base - top) * 0.2 }, { x, top } }), "#f2e4c0") end
end
local function mesa(c, cx, top, w, h)
  c:fill(c:poly({ { cx - w, 46 }, { cx - w + 2, top }, { cx + w - 2, top }, { cx + w, 46 } }), "#a8582f")
  for i = 0, 2 do c:fill(c:rect(cx - w + 2 - i, top + 2 + i * (h // 3), cx + w - 2 + i, top + 2 + i * (h // 3) + h // 6), ({ "#e0501f", "#f08a24", "#e0501f" })[i + 1]) end
  c:fill(c:rect(cx - w + 2, top, cx + w - 2, top), "#f08a24")
end
local function terrace(c, x0, x1, y0) for i = 0, 3 do c:fill(c:rect(x0 + i * 4, y0 + i * 4, x1 - i * 4, y0 + i * 4 + 3), i % 2 == 0 and "#a4b86a" or "#7ab55c"); c:fill(c:rect(x0 + i * 4, y0 + i * 4 + 3, x1 - i * 4, y0 + i * 4 + 3), "#9a6b3f") end end
local function llama(c, x, y) c:fill(c:rect(x, y - 5, x + 6, y - 2), "#f2e4c0"); c:fill(c:rect(x + 5, y - 9, x + 6, y - 5), "#f2e4c0"); c:fill(c:rect(x + 5, y - 10, x + 8, y - 9), "#f2e4c0"); c:fill(c:rect(x + 1, y - 2, x + 1, y), "#d8c49a"); c:fill(c:rect(x + 5, y - 2, x + 5, y), "#d8c49a") end
local function awning(c, x, y, w, a, b) for i = 0, w, 4 do c:fill(c:rect(x + i, y, x + i + 1, y + 5), a); c:fill(c:rect(x + i + 2, y, x + i + 3, y + 5), b) end; c:fill(c:rect(x, y + 5, x + w + 3, y + 5), "#8a4f2a") end
-- name = { sky = {3 band colours}, far = ridge colour, mid = ridge colour, g1 = ground, g2 = lower ground, g0 = ground edge, draw = function(c) }
local B = {}
local SKYB = { "#a9d6ea", "#c8ecdc", "#eef8f2" }
local SKYW = { "#a9d6ea", "#c8ecdc", "#f2e4c0" }   -- warm horizon
local function ground(g1, g2) return { g1 = g1, g2 = g2 } end
B.grassland = { sky = SKYB, far = "#bdd292", mid = "#a4b86a", g1 = "#7ab55c", g2 = "#4f9a45", draw = function(c) tree(c, 120, 44, 30); tree(c, 54, 46, 18, RM.pine); tree(c, 196, 46, 20); flowers(c, { { 30, 52 }, { 80, 51 }, { 156, 52 }, { 214, 51 } }) ; flowers(c, { { 100, 50 }, { 140, 53 } }, "#f5cf6a") end }
B.forest = { sky = SKYB, far = "#acc47d", mid = "#7ab55c", g1 = "#4f9a45", g2 = "#2f6a3a", draw = function(c) pine(c, 40, 46, 30); pine(c, 84, 46, 24); pine(c, 122, 46, 34); pine(c, 160, 46, 26); pine(c, 202, 46, 32); P(c, c:ellipse(104, 47, 5, 3), RM.red); end }
B.mountain = { sky = SKYB, far = "#c3b2ea", mid = "#a4b86a", g1 = "#7ab55c", g2 = "#4f9a45", draw = function(c) peak(c, 60, 12, 36, 42, RM.stone, true); peak(c, 122, 4, 44, 42, RM.dusk, true); peak(c, 186, 14, 34, 42, RM.stone, true); pine(c, 100, 47, 16); pine(c, 150, 47, 14) end }
B.wetland = { sky = SKYB, far = "#acc47d", mid = "#7ab55c", g1 = "#4f9a45", g2 = "#2f5a2a", draw = function(c) c:fill(c:rect(0, 36, W - 1, 46), "#3f8fb0"); for i = 0, 9 do c:fill(c:rect(8 + i * 24, 40, 14 + i * 24, 40), "#a9d6ea") end; for _, x in ipairs({ 60, 64, 70, 160, 166, 172 }) do reed(c, x, 46, 14 + (x % 7)) end; P(c, c:ellipse(112, 44, 6, 2), RM.leaf); P(c, c:ellipse(130, 42, 5, 2), RM.leaf) end }
B.tundra = { sky = SKYB, far = "#c8ecdc", mid = "#a9d6ea", g1 = "#f1ece0", g2 = "#c8ecdc", draw = function(c) pine(c, 50, 46, 24, RM.pine); c:fill(c:rect(46, 30, 54, 31), "#f1ece0"); pine(c, 120, 46, 30); pine(c, 190, 46, 22); rock(c, 86, 46, 7, 4, RM.teal); rock(c, 156, 47, 6, 3, RM.snow) end }
B.desert = { sky = SKYW, far = "#f5cf6a", mid = "#d9a660", g1 = "#e8a317", g2 = "#c9a96e", draw = function(c) mesa(c, 40, 20, 22, 24); mesa(c, 196, 16, 26, 28); c:fill(c:poly({ { 96, 46 }, { 116, 22 }, { 150, 46 } }), "#f5cf6a"); c:fill(c:poly({ { 116, 22 }, { 150, 46 }, { 130, 46 } }), "#c9a96e"); cactus(c, 120, 48, 26); cactus(c, 72, 49, 14); cactus(c, 172, 48, 18); rock(c, 94, 48, 6, 3); c:fill(c:ellipse(148, 47, 3, 3), "#9a6b3f") end }
B.island = { sky = SKYB, far = "#3f8fb0", mid = "#3f8fb0", g1 = "#f5cf6a", g2 = "#c9a96e", draw = function(c) sea(c, 28, 41, "#3f8fb0", "#25637d"); palm(c, 110, 49, 30); palm(c, 176, 48, 20); P(c, c:ellipse(60, 41, 14, 3), RM.leaf); rock(c, 80, 48, 5, 3) end }
B.coast = { sky = SKYB, far = "#25637d", mid = "#3f8fb0", g1 = "#c9c5bc", g2 = "#8b8f96", draw = function(c) sea(c, 26, 42, "#3f8fb0", "#25637d"); P(c, c:poly({ { 150, 42 }, { 160, 42 }, { 158, 14 }, { 152, 14 } }), RM.cream); c:fill(c:rect(152, 22, 158, 28), "#dd3a2a"); P(c, c:rect(151, 8, 159, 14), RM.gold, { gloss = false, flat = true }); P(c, c:poly({ { 150, 8 }, { 155, 2 }, { 160, 8 } }), RM.red); rock(c, 90, 48, 8, 4); rock(c, 200, 49, 6, 3); end }
B.rainforest = { sky = SKYB, far = "#7ab55c", mid = "#4f9a45", g1 = "#4f9a45", g2 = "#2f6a3a", draw = function(c) for _, x in ipairs({ 40, 100, 150, 206 }) do P(c, c:rect(x, 6, x + 4, 46), RM.wood); c:fill(c:rect(x - 8, 6, x + 12, 12), "#2f6a3a"); c:fill(c:rect(x + 8, 12, x + 8, 22), "#4f9a45") end; P(c, c:poly({ { 110, 48 }, { 122, 30 }, { 134, 48 } }), RM.dleaf); P(c, c:ellipse(122, 36, 2, 2), RM.petal) end }
B.village = { sky = SKYB, far = "#bdd292", mid = "#a4b86a", g1 = "#7ab55c", g2 = "#c9a96e", draw = function(c) house(c, 36, 48, 20, 14, RM.cream, RM.roof); house(c, 104, 48, 28, 18, RM.cream, RM.red); house(c, 178, 48, 22, 14, RM.cream, RM.roof); tree(c, 76, 48, 18); tree(c, 160, 48, 16) end }
B.haven = { sky = SKYW, far = "#a4b86a", mid = "#7ab55c", g1 = "#7ab55c", g2 = "#c9a96e", draw = function(c) house(c, 90, 48, 56, 20, RM.cream, RM.roof); c:fill(c:rect(100, 36, 103, 40), "#f5cf6a"); c:fill(c:rect(122, 36, 125, 40), "#f5cf6a"); c:fill(c:rect(110, 40, 114, 48), "#8a4f2a"); tree(c, 56, 48, 22); tree(c, 190, 48, 20); P(c, c:rect(158, 40, 160, 48), RM.wood); c:fill(c:ellipse(159, 38, 2, 2), "#f5cf6a") end }
B.wonder = { sky = SKYB, far = "#c3b2ea", mid = "#a4b86a", g1 = "#7ab55c", g2 = "#4f9a45", draw = function(c) for i, x in ipairs({ 84, 100, 116, 132, 148, 164 }) do P(c, c:rrect(x, 30 + (i % 2) * 3, x + 6, 48, 1), RM.stone) end; P(c, c:rect(86, 26, 162, 30), RM.stone); sparkle(c, 110, 18); sparkle(c, 136, 14); sparkle(c, 156, 20); sparkle(c, 96, 22) end }
B.delve = { sky = SKYB, far = "#8b8f96", mid = "#5b6470", g1 = "#8b8f96", g2 = "#5b6470", draw = function(c) P(c, c:ellipse(120, 48, 40, 34):cut(c:rect(70, 49, 170, 60)), RM.stone, { gloss = false, cres = 4, deep = 0 }); c:fill(c:ellipse(120, 48, 14, 16):cut(c:rect(100, 49, 140, 60)), "#3d2a1c"); c:fill(c:ellipse(120, 48, 8, 10):cut(c:rect(100, 49, 140, 60)), "#7a4a1f"); c:fill(c:rect(100, 36, 100, 42), "#8a4f2a"); c:fill(c:rect(99, 33, 101, 35), "#f08a24"); c:fill(c:rect(140, 36, 140, 42), "#8a4f2a"); c:fill(c:rect(139, 33, 141, 35), "#f08a24"); rock(c, 58, 48, 8, 4); rock(c, 188, 48, 7, 4) end }
B.lair = { sky = SKYW, far = "#a4b86a", mid = "#7ab55c", g1 = "#6a9a3a", g2 = "#4f9a45", draw = function(c) P(c, c:ellipse(120, 50, 46, 26):cut(c:rect(60, 51, 190, 60)), RM.leaf, { gloss = false, cres = 4, deep = 0 }); c:fill(c:ellipse(120, 49, 13, 14):cut(c:rect(100, 50, 140, 60)), "#3d2a1c"); c:fill(c:ellipse(116, 45, 2, 2), "#f08a24"); c:fill(c:ellipse(124, 45, 2, 2), "#f08a24"); rock(c, 66, 49, 6, 3); rock(c, 178, 49, 7, 4); sparkle(c, 98, 28) end }
-- regions (colour families after REGION_MAP in game/includes/maps.php, snapped to the palette)
B.NA = { sky = SKYB, far = "#c3b2ea", mid = "#a4b86a", g1 = "#7ab55c", g2 = "#4f9a45", draw = function(c) peak(c, 48, 14, 34, 42, RM.stone, true); tree(c, 118, 48, 26); pine(c, 166, 48, 24); tree(c, 206, 48, 18) end }
B.CA = { sky = SKYW, far = "#f5cf6a", mid = "#c9a96e", g1 = "#e8a317", g2 = "#c9a96e", draw = function(c) house(c, 80, 48, 26, 14, RM.sand, RM.clay); cactus(c, 140, 48, 24); cactus(c, 50, 48, 16); rock(c, 180, 48, 7, 3); dome(c, 200, 48, 7, RM.clay) end }
B.CB = { sky = SKYB, far = "#8fcbd8", mid = "#3f8fb0", g1 = "#f5cf6a", g2 = "#7ab55c", draw = function(c) sea(c, 28, 40, "#3f8fb0", "#25637d"); palm(c, 70, 50, 26); palm(c, 156, 50, 22); house(c, 104, 50, 22, 12, RM.cream, RM.leaf); boat(c, 200, 38) end }
B.SA = { sky = SKYB, far = "#7ab55c", mid = "#4f9a45", g1 = "#4f9a45", g2 = "#2f6a3a", draw = function(c) facetpeak(c, 50, 8, 34, 42, "#a4b86a", "#4f9a45", false); facetpeak(c, 120, 4, 40, 42, "#7ab55c", "#2f6a3a", true); facetpeak(c, 196, 12, 32, 42, "#a4b86a", "#4f9a45", false); palm(c, 96, 51, 24); tree(c, 150, 50, 22, RM.dleaf); P(c, c:ellipse(76, 48, 6, 3), RM.petal); c:fill(c:rect(160, 40, 160, 47), "#dd3a2a"); c:fill(c:rect(161, 40, 163, 41), "#f5cf6a") end }
B.NWE = { sky = SKYB, far = "#c9c5bc", mid = "#a4b86a", g1 = "#7ab55c", g2 = "#4f9a45", draw = function(c) tower(c, 100, 48, 14, 28, RM.stone, RM.dusk); tower(c, 130, 48, 12, 20, RM.stone, RM.dusk); c:fill(c:rect(114, 34, 130, 48), "#8b8f96"); tree(c, 54, 48, 22, RM.pine); tree(c, 196, 48, 20, RM.pine); for i = 0, 18 do c:px(10 + i * 12, 8 + (i % 3) * 10, "#a9d6ea"); c:px(11 + i * 12, 9 + (i % 3) * 10, "#a9d6ea") end end }
B.SE = { sky = SKYW, far = "#f2e4c0", mid = "#a4b86a", g1 = "#e8a317", g2 = "#a4b86a", draw = function(c) house(c, 90, 48, 30, 16, RM.cream, RM.clay); pine(c, 56, 48, 28, RM.dleaf); pine(c, 70, 48, 22, RM.dleaf); pine(c, 160, 48, 26, RM.dleaf); for x = 180, 220, 4 do c:fill(c:rect(x, 42, x + 1, 48), "#f5cf6a") end end }
B.EE = { sky = SKYB, far = "#c8ecdc", mid = "#a4b86a", g1 = "#7ab55c", g2 = "#c9a96e", draw = function(c) house(c, 40, 48, 18, 14, RM.cream, RM.roof); dome(c, 120, 36, 9, RM.petal); P(c, c:rect(111, 36, 129, 48), RM.cream); c:fill(c:rect(120, 22, 120, 27), "#f5cf6a"); for _, x in ipairs({ 170, 186, 200 }) do P(c, c:rect(x, 30, x + 1, 48), RM.snow); c:fill(c:ellipse(x + 1, 29, 5, 6), "#7ab55c") end end }
B.MENA = { sky = SKYW, far = "#f5cf6a", mid = "#c9a96e", g1 = "#f5cf6a", g2 = "#c9a96e", draw = function(c) dome(c, 100, 38, 12, RM.gold); P(c, c:rect(88, 38, 112, 48), RM.cream); P(c, c:rect(130, 14, 135, 48), RM.cream); P(c, c:poly({ { 128, 14 }, { 132.5, 6 }, { 137, 14 } }), RM.gold, { gloss = false, flat = true }); palm(c, 60, 49, 20); palm(c, 180, 49, 16) end }
B.WCA = { sky = SKYB, far = "#7ab55c", mid = "#4f9a45", g1 = "#4f9a45", g2 = "#2f6a3a", draw = function(c) house(c, 100, 48, 20, 12, RM.cream, RM.sand); house(c, 140, 48, 18, 10, RM.cream, RM.sand); tree(c, 60, 48, 28, RM.dleaf); tree(c, 190, 48, 26, RM.dleaf); for i = 0, 22 do c:px(8 + i * 10, 6 + (i % 4) * 9, "#a9d6ea"); c:px(9 + i * 10, 8 + (i % 4) * 9, "#a9d6ea") end end }
B.ESA = { sky = SKYB, far = "#c9a96e", mid = "#a4b86a", g1 = "#7ab55c", g2 = "#9a6b3f", draw = function(c) terrace(c, 20, 100, 22); terrace(c, 140, 220, 26); P(c, c:rect(112, 24, 128, 46), RM.stone); P(c, c:rect(108, 36, 132, 46), RM.stone); c:fill(c:rect(116, 28, 124, 32), "#f5cf6a"); llama(c, 60, 48); llama(c, 176, 49); tree(c, 14, 48, 18); tree(c, 228, 48, 16) end }
B.CSA = { sky = SKYW, far = "#f08a24", mid = "#c9a96e", g1 = "#c9a96e", g2 = "#a8582f", draw = function(c) pagoda(c, 120, 48, RM.cream, RM.clay); awning(c, 36, 36, 32, "#dd3a2a", "#f5cf6a"); P(c, c:rect(38, 42, 66, 48), RM.wood); awning(c, 172, 36, 32, "#f5cf6a", "#dd3a2a"); P(c, c:rect(174, 42, 202, 48), RM.wood); for i = 0, 3 do P(c, c:ellipse(44 + i * 7, 40, 3, 2), RM.gold, { gloss = false, flat = true }) end; c:fill(c:rect(80, 28, 80, 46), "#8a4f2a"); c:fill(c:poly({ { 81, 28 }, { 92, 34 }, { 81, 40 } }), "#dd3a2a") end }
B.EA = { sky = SKYB, far = "#f6b8cf", mid = "#a4b86a", g1 = "#7ab55c", g2 = "#c9a96e", draw = function(c) pagoda(c, 120, 48, RM.cream, RM.red); tree(c, 64, 48, 28, RM.petal); tree(c, 180, 48, 26, RM.petal); for i = 0, 12 do c:px(20 + i * 17, 20 + (i % 4) * 6, "#f6b8cf") end end }
B.SEA = { sky = SKYB, far = "#7ab55c", mid = "#4f9a45", g1 = "#7ab55c", g2 = "#3f8fb0", draw = function(c) for i = 0, 4 do c:fill(c:rect(30 + i * 8, 30 + i * 3, 190 - i * 8, 32 + i * 3), i % 2 == 0 and "#a4b86a" or "#7ab55c") end; house(c, 110, 38, 14, 8, RM.wood, RM.sand); palm(c, 60, 49, 24); palm(c, 190, 49, 20) end }
B.OC = { sky = SKYB, far = "#3f8fb0", mid = "#3f8fb0", g1 = "#f5cf6a", g2 = "#3f8fb0", draw = function(c) sea(c, 26, 56, "#3f8fb0", "#25637d"); P(c, c:ellipse(60, 42, 20, 4), RM.sand); palm(c, 56, 42, 18); P(c, c:ellipse(180, 44, 16, 3), RM.sand); palm(c, 178, 44, 14); boat(c, 118, 48) end }

local ORDER = { "grassland", "forest", "mountain", "wetland", "tundra", "desert", "island", "coast", "rainforest", "village", "haven", "wonder", "delve", "lair",
  "NA", "CA", "CB", "SA", "NWE", "SE", "EE", "MENA", "WCA", "ESA", "CSA", "EA", "SEA", "OC" }
local only = os.getenv("ONLY"); local want = {}
if only then for k in only:gmatch("[^,]+") do want[k] = true end end
for _, key in ipairs(ORDER) do if not only or want[key] then
  local s = B[key]
  local c = X.canvas{ mode = "scene", w = W, h = H, out = 2, ol = 1, olx = 1 }
  X.layer(c, "sky")
  c:fill(c:rect(0, 0, W - 1, 11), s.sky[1]); c:fill(c:rect(0, 12, W - 1, 23), s.sky[2]); c:fill(c:rect(0, 24, W - 1, H - 1), s.sky[3])
  for _, cl in ipairs({ { 30 + #key * 7, 6 }, { 140 + #key * 3, 4 }, { 200 - #key * 5, 10 } }) do c:fill(c:ellipse(cl[1], cl[2], 9, 2), s.sky[3]); c:fill(c:ellipse(cl[1] - 4, cl[2] - 1, 5, 2), s.sky[3]) end
  X.layer(c, "far")
  for x = 0, W - 1 do c:fill(c:rect(x, 26 + math.floor(3 * math.sin(x / 19 + #key) + 0.5), x, 50), s.far) end
  for x = 0, W - 1 do c:fill(c:rect(x, 33 + math.floor(2.5 * math.sin(x / 11 + 1 + #key) + 0.5), x, 50), s.mid) end
  X.layer(c, "ground")
  c:fill(c:rect(0, 44, W - 1, H - 1), s.g1); c:fill(c:rect(0, 51, W - 1, H - 1), s.g2)
  X.layer(c, "objects")
  s.draw(c)
  X.layer(c, "fx")
  c:seam({ { 0, 1 }, { W - 1, 1 } }, { free = true }); c:seam({ { 0, H - 2 }, { W - 1, H - 2 } }, { free = true })
  X.save(c, "banner-" .. key, "scenes", { w = 480, h = 120, cap = 24 })
end end
