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

local CAT = { grassland = "trees", forest = "trees", mountain = "trees", wetland = "reeds", tundra = "snow", desert = "sand", island = "sea", coast = "sea", rainforest = "trees",
  village = "roofs", haven = "roofs", wonder = "trees", delve = "rock", lair = "trees", NA = "trees", CA = "sand", CB = "sea", SA = "trees", NWE = "trees", SE = "trees", EE = "trees", MENA = "sand",
  WCA = "trees", ESA = "trees", CSA = "sand", EA = "trees", SEA = "trees", OC = "sea" }
-- ===== second-tier decor per banner (props, flora, small life) =====
local function fence(c, x0, x1, y) for x = x0, x1, 5 do c:fill(c:rect(x, y - 4, x + 1, y), "#8a4f2a") end; c:fill(c:rect(x0, y - 3, x1 + 1, y - 3), "#d9a660"); c:fill(c:rect(x0, y - 1, x1 + 1, y - 1), "#d9a660") end
local function smoke(c, x, y) c:fill(c:ellipse(x, y, 2, 1), "#f2e4c0"); c:fill(c:ellipse(x + 2, y - 3, 3, 2), "#f2e4c0"); c:fill(c:ellipse(x + 1, y - 7, 3, 2), "#eef8f2") end
local function barrel(c, x, y) P(c, c:rrect(x - 3, y - 6, x + 3, y, 2), RM.wood, { gloss = false, cres = 2, deep = 0 }); c:fill(c:rect(x - 3, y - 4, x + 3, y - 4), "#8a4f2a") end
local function well(c, x, y) P(c, c:rect(x - 5, y - 6, x + 5, y), RM.stone, { gloss = false, cres = 2, deep = 0 }); c:fill(c:rect(x - 3, y - 7, x + 3, y - 6), "#3f8fb0"); P(c, c:rect(x - 6, y - 14, x - 5, y - 6), RM.wood, { gloss = false, flat = true }); P(c, c:rect(x + 5, y - 14, x + 6, y - 6), RM.wood, { gloss = false, flat = true }); P(c, c:poly({ { x - 8, y - 14 }, { x, y - 19 }, { x + 8, y - 14 } }), RM.roof, { gloss = false, cres = 2, deep = 0 }) end
local function lamp(c, x, y) c:fill(c:rect(x, y - 12, x, y), "#4a2c1a"); P(c, c:rrect(x - 2, y - 16, x + 2, y - 12, 1), RM.gold, { gloss = false, flat = true }); c:px(x, y - 14, "#fff3c8") end
local function crystalp(c, x, y, h, col) c:fill(c:poly({ { x - 2, y }, { x, y - h }, { x + 2, y } }), col); c:px(x, y - h + 2, "#fff3c8") end
local function butterfly(c, x, y, col) c:fill(c:rect(x, y, x + 1, y + 1), col); c:fill(c:rect(x + 3, y, x + 4, y + 1), col); c:px(x + 2, y + 1, "#4a2c1a") end
local DEC = {
  grassland = function(c) for x = 70, 160 do c:fill(c:rect(x, 50 + math.floor(2 * math.sin(x / 9) + 0.5), x, 51 + math.floor(2 * math.sin(x / 9) + 0.5)), "#c9a96e") end; fence(c, 168, 220, 53); butterfly(c, 90, 30, "#f6b8cf"); butterfly(c, 150, 24, "#f5cf6a"); flowers(c, { { 60, 53 }, { 100, 54 }, { 180, 55 } }, "#f2e4c0") end,
  forest = function(c) for _, m in ipairs({ { 30, 52 }, { 140, 53 }, { 190, 52 } }) do c:fill(c:rect(m[1], m[2] - 3, m[1] + 1, m[2]), "#f2e4c0"); c:fill(c:ellipse(m[1] + 0.5, m[2] - 3, 3, 2), "#dd3a2a") end; P(c, c:rrect(55, 51, 80, 54, 1), RM.wood, { gloss = false, cres = 1, deep = 0 }); c:fill(c:rect(170, 44, 172, 50), "#2f6a3a") end,
  mountain = function(c) c:fill(c:rect(96, 26, 99, 44), "#a9d6ea"); c:fill(c:rect(97, 26, 97, 44), "#eef8f2"); c:fill(c:ellipse(98, 46, 7, 2), "#eef8f2"); pine(c, 28, 50, 14); pine(c, 214, 50, 12); flowers(c, { { 80, 53 }, { 170, 54 } }, "#f5cf6a") end,
  wetland = function(c) for _, x in ipairs({ 20, 24, 210, 215 }) do reed(c, x, 47, 15) end; P(c, c:ellipse(150, 43, 5, 2), RM.leaf); c:fill(c:rect(80, 33, 84, 33), "#a9d6ea"); c:fill(c:rect(82, 34, 84, 34), "#3f8fb0"); P(c, c:ellipse(124, 40, 2, 1), RM.petal, { gloss = false, flat = true }) end,
  tundra = function(c) P(c, c:ellipse(40, 49, 10, 7):cut(c:rect(20, 50, 60, 60)), RM.snow, { gloss = false, cres = 3, deep = 0 }); c:fill(c:rect(37, 46, 43, 49), "#3d2a1c"); for _, p in ipairs({ { 70, 53 }, { 90, 55 }, { 170, 52 }, { 200, 54 } }) do c:paint({ "xx" }, p[1], p[2], { x = "#c8ecdc" }) end; for _, sp in ipairs({ { 60, 22 }, { 180, 18 }, { 120, 12 } }) do c:px(sp[1], sp[2], "#eef8f2"); c:px(sp[1] - 1, sp[2], "#eef8f2"); c:px(sp[1] + 1, sp[2], "#eef8f2") end end,
  desert = function(c) palm(c, 20, 52, 18); palm(c, 26, 52, 12); c:fill(c:ellipse(22, 52, 9, 2), "#3f8fb0"); butterfly(c, 100, 22, "#f2e4c0"); c:fill(c:rect(60, 30, 68, 30), "#fff3c8"); c:fill(c:rect(160, 28, 170, 28), "#fff3c8") end,
  island = function(c) c:fill(c:ellipse(30, 50, 3, 2), "#f6b8cf"); for i = 0, 4 do local a = i * 1.2566; c:px(math.floor(210 + math.cos(a) * 3 + 0.5), math.floor(52 + math.sin(a) * 3 + 0.5), "#dd3a2a") end; boat(c, 170, 36); c:fill(c:ellipse(150, 53, 7, 2), "#fff3c8"); c:fill(c:rect(70, 12, 72, 12), "#4a2c1a") end,
  coast = function(c) boat(c, 40, 34); boat(c, 200, 38); c:fill(c:ellipse(60, 50, 3, 3), "#dd3a2a"); c:fill(c:rect(59, 47, 61, 47), "#f2e4c0"); for _, g in ipairs({ { 80, 12 }, { 96, 8 }, { 110, 14 } }) do c:fill(c:rect(g[1], g[2], g[1] + 2, g[2]), "#f2e4c0"); c:fill(c:rect(g[1] + 3, g[2], g[1] + 5, g[2]), "#f2e4c0"); c:px(g[1] + 2, g[2] - 1, "#f2e4c0") end; P(c, c:rrect(112, 52, 130, 54, 1), RM.wood, { gloss = false, cres = 1, deep = 0 }) end,
  rainforest = function(c) for _, x in ipairs({ 56, 100, 170 }) do c:fill(c:rect(x, 8, x, 20 + x % 9), "#4f9a45"); c:fill(c:ellipse(x, 21 + x % 9, 2, 2), "#7ab55c") end; P(c, c:poly({ { 70, 50 }, { 84, 38 }, { 96, 50 } }), RM.dleaf); P(c, c:poly({ { 150, 50 }, { 162, 40 }, { 176, 50 } }), RM.dleaf); P(c, c:ellipse(80, 40, 2, 2), RM.red, { gloss = false, flat = true }); c:fill(c:rect(190, 18, 192, 19), "#dd3a2a"); c:px(193, 18, "#f5cf6a") end,
  village = function(c) barrel(c, 78, 52); barrel(c, 86, 52) end,
  haven = function(c) P(c, c:rect(200, 44, 238, 47), RM.wood, { gloss = false, cres = 2, deep = 0 }); for x = 204, 236, 8 do P(c, c:rect(x, 47, x + 1, 56), RM.wood, { gloss = false, flat = true }) end; barrel(c, 214, 44); barrel(c, 224, 44); lamp(c, 40, 52); for x = 40, 190, 10 do c:px(x, 12 + math.floor(2 * math.sin(x / 20) + 0.5), "#4a2c1a") end; smoke(c, 134, 22) end,
  wonder = function(c) for _, p in ipairs({ { 50, 20 }, { 70, 14 }, { 100, 10 }, { 176, 12 }, { 196, 20 }, { 214, 26 } }) do sparkle(c, p[1], p[2]) end; P(c, c:rrect(40, 36, 46, 40, 1), RM.stone, { gloss = false, cres = 1, deep = 0 }); P(c, c:rrect(196, 30, 202, 34, 1), RM.stone, { gloss = false, cres = 1, deep = 0 }); flowers(c, { { 70, 52 }, { 80, 53 }, { 162, 52 }, { 172, 53 } }, "#f6b8cf") end,
  delve = function(c) crystalp(c, 36, 50, 12, "#a9d6ea"); crystalp(c, 42, 50, 8, "#a9d6ea"); crystalp(c, 206, 50, 12, "#c3b2ea"); crystalp(c, 212, 50, 8, "#c3b2ea"); P(c, c:poly({ { 164, 44 }, { 184, 44 }, { 180, 52 }, { 168, 52 } }), RM.wood, { gloss = false, cres = 2, deep = 0 }); c:fill(c:ellipse(170, 54, 2, 2), "#2a1a10"); c:fill(c:ellipse(180, 54, 2, 2), "#2a1a10"); lamp(c, 150, 52) end,
  lair = function(c) for _, e in ipairs({ { 60, 50 }, { 70, 52 }, { 66, 47 } }) do P(c, c:ellipse(e[1], e[2], 4, 5), RM.cream, { gloss = false, cres = 1, deep = 0 }) end; for i = 0, 6 do c:fill(c:ellipse(190 + (i % 3) * 5, 52 - (i // 3) * 3, 2, 1), "#f5cf6a") end; sparkle(c, 140, 26); sparkle(c, 100, 22) end,
  NA = function(c) fence(c, 20, 50, 53); c:fill(c:poly({ { 190, 50 }, { 196, 42 }, { 202, 50 } }), "#f08a24"); c:fill(c:poly({ { 193, 50 }, { 196, 45 }, { 199, 50 } }), "#f5cf6a"); P(c, c:rect(182, 49, 190, 51), RM.wood, { gloss = false, flat = true }) end,
  CA = function(c) house(c, 180, 49, 22, 12, RM.sand, RM.clay); for _, x in ipairs({ 34, 44 }) do P(c, c:poly({ { x - 3, 50 }, { x - 4, 44 }, { x + 4, 44 }, { x + 3, 50 } }), RM.clay, { gloss = false, cres = 2, deep = 0 }) end; c:fill(c:ellipse(150, 50, 3, 3), "#9a6b3f") end,
  CB = function(c) palm(c, 36, 52, 20); palm(c, 220, 52, 18); boat(c, 70, 38); c:fill(c:ellipse(140, 53, 7, 2), "#fff3c8"); P(c, c:ellipse(170, 50, 5, 2), RM.petal, { gloss = false, flat = true }) end,
  SA = function(c) c:fill(c:rect(168, 24, 171, 40), "#a9d6ea"); c:fill(c:rect(169, 24, 169, 40), "#eef8f2"); for _, p in ipairs({ { 40, 50, 18 }, { 214, 50, 20 } }) do tree(c, p[1], p[2], p[3], RM.dleaf) end; c:fill(c:rect(100, 22, 102, 23), "#dd3a2a"); c:fill(c:rect(104, 26, 106, 27), "#3f8fb0") end,
  NWE = function(c) for _, f in ipairs({ { 104, 24 }, { 134, 28 } }) do c:fill(c:rect(f[1], f[2] - 6, f[1], f[2]), "#4a2c1a"); c:fill(c:poly({ { f[1] + 1, f[2] - 6 }, { f[1] + 7, f[2] - 4 }, { f[1] + 1, f[2] - 2 } }), "#dd3a2a") end; fence(c, 20, 50, 53); P(c, c:ellipse(80, 50, 6, 3), RM.leaf); c:fill(c:rect(160, 38, 180, 38), "#c9c5bc") end,
  SE = function(c) for _, x in ipairs({ 140, 160, 180 }) do pine(c, x, 52, 20, RM.dleaf) end; for i = 0, 5 do c:fill(c:rect(30 + i * 6, 44, 31 + i * 6, 50), "#7ab55c"); P(c, c:ellipse(30 + i * 6, 43, 2, 2), RM.dusk, { gloss = false, flat = true }) end end,
  EE = function(c) for _, x in ipairs({ 30, 54 }) do P(c, c:rect(x, 38, x + 1, 48), RM.snow, { gloss = false, flat = true }); c:fill(c:ellipse(x + 1, 37, 4, 5), "#7ab55c") end; dome(c, 200, 48, 6, RM.petal); P(c, c:rect(194, 48, 206, 52), RM.cream, { gloss = false, flat = true }); c:fill(c:ellipse(160, 52, 8, 2), "#f1ece0") end,
  MENA = function(c) c:fill(c:ellipse(40, 51, 12, 3), "#3f8fb0"); c:fill(c:rect(30, 50, 40, 50), "#a9d6ea"); dome(c, 186, 46, 8, RM.cream); P(c, c:rect(178, 46, 194, 52), RM.sand, { gloss = false, flat = true }); c:fill(c:rect(150, 46, 150, 40), "#8a4f2a"); c:fill(c:rect(146, 38, 154, 40), "#4f9a45") end,
  WCA = function(c) for _, x in ipairs({ 40, 190 }) do P(c, c:rect(x, 40, x + 14, 46), RM.wood, { gloss = false, cres = 2, deep = 0 }); P(c, c:poly({ { x - 2, 40 }, { x + 7, 33 }, { x + 16, 40 } }), RM.sand, { gloss = false, cres = 2, deep = 0 }); for dx = 1, 13, 4 do c:fill(c:rect(x + dx, 46, x + dx, 52), "#8a4f2a") end end; P(c, c:ellipse(120, 53, 7, 2), RM.leaf) end,
  ESA = function(c) llama(c, 100, 50); P(c, c:ellipse(130, 50, 4, 3), RM.dleaf); for i = 0, 3 do c:fill(c:rect(60 + i * 4, 44, 61 + i * 4, 48), "#4f9a45") end; flowers(c, { { 150, 52 }, { 160, 53 } }, "#f6b8cf") end,
  CSA = function(c) for i = 0, 4 do P(c, c:ellipse(90 + i * 6, 50, 3, 2), ({ RM.red, RM.gold, RM.clay })[i % 3 + 1], { gloss = false, flat = true }) end; lamp(c, 20, 52); lamp(c, 224, 52); for x = 20, 224, 12 do c:px(x, 10 + (x // 12) % 3, "#f5cf6a") end end,
  EA = function(c) for i = 0, 10 do c:px(30 + i * 18, 14 + (i % 4) * 6, "#f6b8cf"); c:px(31 + i * 18, 15 + (i % 4) * 6, "#f6b8cf") end; P(c, c:poly({ { 160, 50 }, { 166, 44 }, { 184, 44 }, { 190, 50 } }), RM.red, { gloss = false, cres = 2, deep = 0 }); c:fill(c:rect(168, 44, 169, 50), "#4a2c1a"); c:fill(c:rect(180, 44, 181, 50), "#4a2c1a") end,
  SEA = function(c) boat(c, 40, 44); c:fill(c:ellipse(150, 51, 6, 2), "#3f8fb0"); P(c, c:ellipse(210, 48, 5, 3), RM.petal, { gloss = false, flat = true }); c:fill(c:rect(80, 20, 82, 21), "#dd3a2a"); c:px(83, 20, "#f5cf6a") end,
  OC = function(c) boat(c, 30, 52); P(c, c:ellipse(220, 48, 12, 3), RM.sand); palm(c, 218, 48, 12); c:fill(c:ellipse(90, 52, 8, 2), "#fff3c8"); c:fill(c:rect(140, 16, 142, 16), "#4a2c1a") end,
}
-- the Hollow is underground: every banner "sky" is cave air under a rock ceiling with stalactites
local CAVE = { amber = { "#3d2a1c", "#7a4a1f", "#9a6b3f", "#c9a96e" }, green = { "#3d2a1c", "#2f5a2a", "#4f9a45", "#a4b86a" }, violet = { "#3d2a1c", "#4e3a8a", "#7a5cc0", "#c3b2ea" },
  blue = { "#3d2a1c", "#25637d", "#3f8fb0", "#a9d6ea" }, ember = { "#3d2a1c", "#a8582f", "#d9885a", "#f5cf6a" }, pink = { "#3d2a1c", "#4e3a8a", "#e46a9b", "#f6b8cf" } }
local THEME = { grassland = "amber", forest = "green", mountain = "violet", wetland = "blue", tundra = "blue", desert = "ember", island = "blue", coast = "blue", rainforest = "green",
  village = "amber", haven = "amber", wonder = "violet", delve = "violet", lair = "ember", NA = "green", CA = "ember", CB = "blue", SA = "green", NWE = "violet", SE = "amber", EE = "blue",
  MENA = "ember", WCA = "green", ESA = "amber", CSA = "ember", EA = "pink", SEA = "green", OC = "blue" }
local ORDER = { "grassland", "forest", "mountain", "wetland", "tundra", "desert", "island", "coast", "rainforest", "village", "haven", "wonder", "delve", "lair",
  "NA", "CA", "CB", "SA", "NWE", "SE", "EE", "MENA", "WCA", "ESA", "CSA", "EA", "SEA", "OC" }
local only = os.getenv("ONLY"); local want = {}
if only then for k in only:gmatch("[^,]+") do want[k] = true end end
for _, key in ipairs(ORDER) do if not only or want[key] then
  local s = B[key]
  local c = X.canvas{ mode = "scene", w = W, h = H, out = 2, ol = 1, olx = 1 }
  X.layer(c, "sky")
  local pal = CAVE[THEME[key]]; s.sky = { pal[2], pal[3], pal[4] }
  c:fill(c:rect(0, 0, W - 1, 11), s.sky[1]); c:fill(c:rect(0, 12, W - 1, 23), s.sky[2]); c:fill(c:rect(0, 24, W - 1, H - 1), s.sky[3])
  for x = 0, W - 1 do c:fill(c:rect(x, 0, x, 4 + math.floor(1.5 * math.sin(x / 7) + 0.5)), "#3d2a1c") end
  for x = 4, W - 1, 8 do local h = 4 + (x * 7 + #key) % 8; if (x // 8) % 5 == 0 then h = h + 6 end; c:fill(c:poly({ { x - 3, 5 }, { x, 5 + h }, { x + 3, 5 } }), "#2a1a10"); c:fill(c:poly({ { x - 3, 5 }, { x - 1, 5 + h * 0.6 }, { x - 1, 5 } }), "#4a2c1a") end
  for _, cl in ipairs({ { 30 + #key * 7, 6 }, { 140 + #key * 3, 4 }, { 200 - #key * 5, 10 } }) do c:fill(c:ellipse(cl[1], cl[2], 9, 2), s.sky[3]); c:fill(c:ellipse(cl[1] - 4, cl[2] - 1, 5, 2), s.sky[3]) end
  X.layer(c, "far")
  for x = 0, W - 1 do c:fill(c:rect(x, 26 + math.floor(3 * math.sin(x / 19 + #key) + 0.5), x, 50), s.far) end
  for x = 0, W - 1 do c:fill(c:rect(x, 33 + math.floor(2.5 * math.sin(x / 11 + 1 + #key) + 0.5), x, 50), s.mid) end
  local cat = CAT[key]
  -- far treeline / roofline bumps rising from the mid ridge (same colour, so no new palette entries)
  if cat == "trees" or cat == "reeds" then for x = 5, W - 1, 11 do local y = 33 + math.floor(2.5 * math.sin(x / 11 + 1 + #key) + 0.5); c:fill(c:ellipse(x, y - 1, 3 + (x // 11) % 2, 3), s.mid); c:fill(c:rect(x, y, x, y + 3), s.mid) end
  elseif cat == "roofs" then for x = 8, W - 1, 24 do local y = 33 + math.floor(2.5 * math.sin(x / 11 + 1 + #key) + 0.5); c:fill(c:rect(x, y - 4, x + 7, y + 2), s.mid); c:fill(c:poly({ { x - 1, y - 4 }, { x + 3.5, y - 8 }, { x + 9, y - 4 } }), s.mid) end end
  X.layer(c, "ground")
  c:fill(c:rect(0, 44, W - 1, H - 1), s.g1); c:fill(c:rect(0, 51, W - 1, H - 1), s.g2)
  for i = 0, 17 do local x = 6 + i * 13 + (i * 5) % 7; c:paint({ "x.x", ".x." }, x, 46 + (i % 3), { x = s.g2 }) end   -- tufts on the front ground
  X.layer(c, "objects")
  s.draw(c)
  if DEC[key] then DEC[key](c) end
  -- foreground corner props (outside the centre, framing the picture)
  for _, fx in ipairs({ { 12, 54, 9 }, { 229, 54, 8 } }) do
    if cat == "trees" or cat == "reeds" then P(c, c:ellipse(fx[1], fx[2], fx[3], 3), RM.leaf, { gloss = false, cres = 2, deep = 0 })
    elseif cat == "sand" or cat == "sea" or cat == "rock" then rock(c, fx[1], fx[2], fx[3] - 2, 3)
    elseif cat == "snow" then P(c, c:ellipse(fx[1], fx[2], fx[3], 3), RM.snow, { gloss = false, cres = 2, deep = 0 })
    else P(c, c:rrect(fx[1] - 5, fx[2] - 5, fx[1] + 5, fx[2] + 2, 1), RM.wood, { gloss = false, cres = 2, deep = 0 }); c:fill(c:rect(fx[1] - 4, fx[2] - 2, fx[1] + 4, fx[2] - 2), "#8a4f2a") end
  end
  X.layer(c, "fx")
  c:seam({ { 0, 1 }, { W - 1, 1 } }, { free = true }); c:seam({ { 0, H - 2 }, { W - 1, H - 2 } }, { free = true })
  X.save(c, "banner-" .. key, "scenes", { w = 480, h = 120, cap = 24 })
end end
