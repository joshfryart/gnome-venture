-- interiors.lua : 5 homes, 4 shops, 10 rest stops. 240x135 grid -> 480x270, opaque, no border, cap 32. Warm light from the upper left.
-- Every scene has a foreground counter/half-wall/crate row across native y107..134 on the LEFT (exported 214..270) that hides the cut-off villager bust.
-- Shops add a counter on the right with empty space behind it. Run: GV_ROOT=... Aseprite -b --script interiors.lua  (ONLY=name,name to limit)
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local W, H = 240, 135
local function R(base, shade, rim) return X.ramp(base, { shade = shade, deep = shade, bounce = shade, rim = rim or base, gloss = base, dot = base }) end
local OP = { gloss = false, cres = 2, deep = 0 }
local function P(c, m, r, o) c:part(m, r, o or OP) end
local RM = { wood = R("#b07a45", "#8a4f2a", "#d9a660"), dwood = R("#8a4f2a", "#5e2f1e", "#b07a45"), stone = R("#8b8f96", "#5b6470", "#c9c5bc"), cream = R("#f2e4c0", "#d8c49a"),
  red = R("#dd3a2a", "#ae2a2a", "#f2793a"), gold = R("#f5cf6a", "#e8a317"), leaf = R("#7ab55c", "#4f9a45"), dleaf = R("#4f9a45", "#2f6a3a"), clay = R("#c9a96e", "#9a6b3f", "#f1ece0"),
  soil = R("#9a6b3f", "#7a4a1f", "#c9a96e"), water = R("#3f8fb0", "#25637d", "#a9d6ea"), petal = R("#e46a9b", "#b8452f", "#f6b8cf"), straw = R("#f5cf6a", "#c9a96e", "#fff3c8"), dusk = R("#7a5cc0", "#4e3a8a", "#c3b2ea") }
local function plankwall(c, a, b, step) c:fill(c:rect(0, 0, W - 1, 100), a); for x = 4, W - 1, step or 16 do c:fill(c:rect(x, 8, x, 100), b) end end
local function floor(c, a, b) c:fill(c:rect(0, 93, W - 1, H - 1), a); for i, y in ipairs({ 98, 104, 111, 119, 128 }) do c:fill(c:rect(0, y, W - 1, y), b) end end
local function lantern(c, x, y) c:fill(c:rect(x, y - 10, x, y - 6), "#4a2c1a"); P(c, c:rrect(x - 2, y - 6, x + 2, y, 1), RM.gold, { gloss = false, flat = true }); c:px(x, y - 3, "#fff3c8") end
local function window(c, x, y, w, h, sky) c:fill(c:rect(x, y, x + w, y + h), sky or "#a9d6ea"); c:fill(c:rect(x, y + h * 0.6, x + w, y + h), "#c8ecdc"); P(c, c:rect(x - 3, y - 3, x + w + 3, y):add(c:rect(x - 3, y + h, x + w + 3, y + h + 3)):add(c:rect(x - 3, y, x, y + h)):add(c:rect(x + w, y, x + w + 3, y + h)):add(c:rect(x + w / 2, y, x + w / 2 + 1, y + h)), RM.wood, { gloss = false, flat = true }) end
local function porthole(c, x, y, r) P(c, c:ellipse(x, y, r + 2, r + 2), RM.gold, { gloss = false, cres = 1, deep = 0 }); c:fill(c:ellipse(x, y, r, r), "#3f8fb0"); c:fill(c:rect(x - r, y - r + 2, x + r, y - r + 3), "#a9d6ea") end
local function jar(c, x, y, col) P(c, c:rrect(x, y - 8, x + 6, y, 2), col, { gloss = false, flat = true }); c:fill(c:rect(x + 1, y - 10, x + 5, y - 9), "#8a4f2a") end
local function shelf(c, x0, x1, y, cols) P(c, c:rect(x0, y, x1, y + 2), RM.wood, { gloss = false, flat = true }); local i = 0; for x = x0 + 4, x1 - 8, 10 do i = i + 1; jar(c, x, y, cols[(i - 1) % #cols + 1]) end end
local function counterL(c, a, b) -- the bottom-left cover: hides the cut bust
  P(c, c:rect(-3, 108, 118, H + 2), a, { gloss = false, cres = 4, deep = 0 }); P(c, c:rect(-3, 104, 121, 109), b, { gloss = false, cres = 2, deep = 0 }); c:fill(c:rect(0, 118, 115, 118), "#8a4f2a") end
local function counterR(c, a, b) P(c, c:rect(128, 98, W + 2, H + 2), a, { gloss = false, cres = 4, deep = 0 }); P(c, c:rect(125, 94, W + 2, 99), b, { gloss = false, cres = 2, deep = 0 }) end
local function hearth(c, x, y, w, h) P(c, c:rect(x, y - h, x + w, y), RM.stone, { gloss = false, cres = 3, deep = 0 }); c:fill(c:rect(x + 6, y - h * 0.6, x + w - 6, y), "#3d2a1c"); c:fill(c:poly({ { x + w / 2 - 5, y }, { x + w / 2, y - 12 }, { x + w / 2 + 5, y } }), "#f08a24"); c:fill(c:poly({ { x + w / 2 - 2, y }, { x + w / 2, y - 6 }, { x + w / 2 + 2, y } }), "#f5cf6a") end
local function sack(c, x, y, col) P(c, c:rrect(x, y - 12, x + 12, y, 3), col, { gloss = false, cres = 2, deep = 0 }); c:fill(c:rect(x + 3, y - 14, x + 9, y - 12), "#8a4f2a") end
local function plant(c, x, y, h) P(c, c:rect(x, y - 6, x + 6, y), RM.dwood, { gloss = false, flat = true }); P(c, c:ellipse(x + 3, y - 6 - h / 2, 6, h / 2), RM.leaf) end
local function mush(c, x, y, s) c:fill(c:rect(x, y - 3 * s, x + s, y), "#f2e4c0"); P(c, c:ellipse(x + s / 2, y - 3 * s, 3 * s, 2 * s), RM.red, { gloss = false, flat = true }) end
local function tree_out(c, x, y, h, rr) P(c, c:rect(x - 1, y - h * 0.5, x + 1, y), RM.wood, { gloss = false, flat = true }); P(c, c:ellipse(x, y - h * 0.7, h * 0.4, h * 0.35), rr or RM.leaf, { gloss = false, cres = 3, deep = 0 }) end

local S = {}
-- ===== homes =====
S["home-burrow"] = function(c)
  c:fill(c:rect(0, 0, W - 1, 100), "#7a4a1f"); c:fill(c:ellipse(120, 70, 118, 64), "#9a6b3f"); c:fill(c:ellipse(120, 74, 100, 54), "#c9a96e")  -- round earth chamber
  for x = 20, 220, 28 do P(c, c:rect(x, 6, x + 4, 40), RM.wood, { gloss = false, flat = true }) end     -- root beams
  c:fill(c:rect(0, 93, W - 1, H - 1), "#7a4a1f"); for y = 100, 128, 9 do c:fill(c:rect(0, y, W - 1, y), "#3d2a1c") end
  P(c, c:ellipse(190, 56, 14, 14), RM.wood, { gloss = false, cres = 3, deep = 0 }); c:fill(c:ellipse(190, 56, 9, 9), "#a9d6ea"); c:fill(c:rect(189, 47, 190, 65), "#8a4f2a")  -- round window
  lantern(c, 130, 36); lantern(c, 60, 30); mush(c, 150, 93, 3); mush(c, 160, 93, 2); plant(c, 170, 93, 10); shelf(c, 128, 180, 74, { RM.gold, RM.red, RM.leaf })
  P(c, c:rrect(206, 80, 232, 93, 3), RM.red, { gloss = false, cres = 2, deep = 0 })     -- small bed
  counterL(c, RM.dwood, RM.wood)
end
S["home-treehouse"] = function(c)
  plankwall(c, "#d9a660", "#b07a45", 14); c:fill(c:rect(0, 0, W - 1, 8), "#4f9a45")
  window(c, 150, 24, 40, 32, "#c8ecdc"); P(c, c:ellipse(170, 40, 12, 9), RM.dleaf, { gloss = false, cres = 2, deep = 0 }); P(c, c:ellipse(158, 30, 8, 6), RM.leaf)
  floor(c, "#b07a45", "#8a4f2a"); lantern(c, 70, 28); lantern(c, 120, 22); shelf(c, 20, 74, 66, { RM.gold, RM.petal, RM.leaf }); P(c, c:rect(96, 52, 98, 93), RM.wood, { gloss = false, flat = true })
  c:fill(c:rect(212, 8, 214, 60), "#d9a660"); for y = 14, 58, 8 do c:fill(c:rect(208, y, 218, y + 1), "#b07a45") end      -- rope ladder
  P(c, c:rrect(176, 78, 216, 93, 4), RM.petal, { gloss = false, cres = 2, deep = 0 })
  counterL(c, RM.wood, RM.straw)
end
S["home-hut"] = function(c)
  c:fill(c:rect(0, 0, W - 1, 100), "#f5cf6a"); for x = 0, W - 1, 6 do c:fill(c:rect(x, 0, x, 100), "#c9a96e") end; c:fill(c:rect(0, 0, W - 1, 14), "#c9a96e")     -- thatch walls
  c:fill(c:poly({ { 60, 0 }, { 120, 0 }, { 90, 30 } }), "#9a6b3f"); c:fill(c:poly({ { 120, 0 }, { 180, 0 }, { 150, 30 } }), "#9a6b3f")
  floor(c, "#c9a96e", "#9a6b3f"); window(c, 20, 30, 30, 26, "#c8ecdc")
  for i, x in ipairs({ 110, 124, 138, 152 }) do c:fill(c:rect(x, 14, x, 36), "#4f9a45"); P(c, c:ellipse(x, 38, 3, 4), RM.leaf, { gloss = false, flat = true }) end   -- hanging herbs
  P(c, c:ellipse(190, 90, 18, 5), RM.stone, { gloss = false, cres = 2, deep = 0 }); c:fill(c:poly({ { 184, 88 }, { 190, 70 }, { 196, 88 } }), "#f08a24"); c:fill(c:poly({ { 187, 88 }, { 190, 78 }, { 193, 88 } }), "#f5cf6a")     -- fire pit
  P(c, c:ellipse(140, 100, 24, 6), RM.red, { gloss = false, cres = 2, deep = 0 })
  counterL(c, RM.clay, RM.straw)
end
S["home-stone"] = function(c)
  c:fill(c:rect(0, 0, W - 1, 100), "#8b8f96"); for y = 0, 100, 10 do c:fill(c:rect(0, y, W - 1, y), "#5b6470"); for x = (y % 20 == 0) and 0 or 12, W - 1, 24 do c:fill(c:rect(x, y, x, y + 9), "#5b6470") end end
  floor(c, "#5b6470", "#3d2a1c"); hearth(c, 150, 93, 60, 56); P(c, c:rect(144, 30, 216, 38), RM.dwood, { gloss = false, cres = 2, deep = 0 })
  P(c, c:poly({ { 20, 6 }, { 70, 6 }, { 70, 60 }, { 45, 70 }, { 20, 60 } }), RM.red, { gloss = false, cres = 3, deep = 0 }); sparkleTapestry(c)
  lantern(c, 110, 24); window(c, 92, 40, 14, 24, "#a9d6ea")
  counterL(c, RM.stone, RM.wood)
end
function sparkleTapestry(c) c:fill(c:rect(40, 22, 50, 22), "#f5cf6a"); c:fill(c:rect(45, 17, 45, 27), "#f5cf6a"); c:fill(c:ellipse(45, 22, 3, 3), "#f5cf6a") end
S["home-boat"] = function(c)
  plankwall(c, "#b07a45", "#8a4f2a", 12); c:fill(c:rect(0, 0, W - 1, 8), "#5e2f1e")
  floor(c, "#8a4f2a", "#5e2f1e"); porthole(c, 70, 40, 9); porthole(c, 120, 36, 9); porthole(c, 170, 40, 9)
  for x = 8, W - 1, 32 do c:fill(c:rect(x, 8, x + 1, 100), "#5e2f1e") end                       -- ribs
  c:fill(c:rect(196, 10, 197, 70), "#d9a660"); c:fill(c:poly({ { 198, 14 }, { 226, 44 }, { 198, 44 } }), "#f2e4c0")   -- tied sail cloth corner
  lantern(c, 96, 20); lantern(c, 146, 20); P(c, c:ellipse(150, 90, 8, 8), RM.dwood, { gloss = false, cres = 2, deep = 0 }); c:fill(c:rect(142, 86, 158, 86), "#8a4f2a")
  P(c, c:rrect(190, 78, 232, 93, 4), RM.cream, { gloss = false, cres = 2, deep = 0 })       -- hammock/bunk
  counterL(c, RM.dwood, RM.gold)
end
-- ===== shops =====
local function shopback(c, a, b) plankwall(c, a, b, 20); c:fill(c:rect(0, 0, W - 1, 6), "#8a4f2a"); floor(c, "#b07a45", "#8a4f2a") end
S["shop-seeds"] = function(c)
  shopback(c, "#d9a660", "#b07a45")
  for r = 0, 2 do for i = 0, 7 do P(c, c:rect(110 + i * 14, 14 + r * 18, 122 + i * 14, 28 + r * 18), RM.wood, { gloss = false, flat = true }); c:fill(c:rect(114 + i * 14, 18 + r * 18, 118 + i * 14, 20 + r * 18), "#f5cf6a") end end
  window(c, 20, 20, 36, 30, "#c8ecdc"); P(c, c:ellipse(40, 45, 18, 6), RM.leaf, { gloss = false, flat = true })
  counterR(c, RM.wood, RM.straw); sack(c, 140, 94, RM.cream); sack(c, 158, 94, RM.straw); sack(c, 176, 94, RM.cream)
  for i = 0, 5 do c:fill(c:rect(200 + i * 5, 88, 203 + i * 5, 93), ({ "#dd3a2a", "#f5cf6a", "#7ab55c" })[i % 3 + 1]) end
  counterL(c, RM.wood, RM.straw); plant(c, 20, 104, 14)
end
S["shop-bakery"] = function(c)
  shopback(c, "#f2e4c0", "#d8c49a"); hearth(c, 130, 80, 60, 50); P(c, c:rect(124, 24, 196, 30), RM.dwood, { gloss = false, cres = 2, deep = 0 })
  for i = 0, 4 do P(c, c:ellipse(212 - 0, 20 + i * 12, 14, 4), RM.straw, { gloss = false, cres = 1, deep = 0 }) end
  P(c, c:rect(10, 20, 100, 22), RM.wood, { gloss = false, flat = true }); for i = 0, 5 do P(c, c:ellipse(18 + i * 14, 17, 6, 3), RM.straw, { gloss = false, cres = 1, deep = 0 }) end
  lantern(c, 110, 40); counterR(c, RM.wood, RM.cream); for i = 0, 3 do P(c, c:ellipse(150 + i * 18, 92, 7, 4), RM.straw, { gloss = false, cres = 1, deep = 0 }) end
  counterL(c, RM.wood, RM.cream); sack(c, 20, 104, RM.cream)
end
S["shop-herbs"] = function(c)
  shopback(c, "#a4b86a", "#7ab55c"); for i, x in ipairs({ 20, 38, 56, 74, 92, 110, 128, 146 }) do c:fill(c:rect(x, 6, x, 30 + (i % 3) * 6), "#4f9a45"); P(c, c:ellipse(x, 32 + (i % 3) * 6, 4, 5), i % 2 == 0 and RM.leaf or RM.dleaf, { gloss = false, flat = true }) end
  shelf(c, 150, 230, 52, { RM.leaf, RM.petal, RM.gold, RM.dusk }); shelf(c, 150, 230, 74, { RM.dleaf, RM.gold, RM.red })
  window(c, 24, 50, 30, 24, "#c8ecdc"); counterR(c, RM.wood, RM.straw); for i = 0, 3 do plant(c, 140 + i * 22, 94, 8) end
  counterL(c, RM.wood, RM.leaf)
end
S["shop-craft"] = function(c)
  shopback(c, "#c3b2ea", "#7a5cc0")
  for i = 0, 6 do P(c, c:rect(110 + i * 16, 14, 120 + i * 16, 24), ({ RM.red, RM.gold, RM.leaf, RM.water, RM.petal, RM.dusk, RM.cream })[i + 1], { gloss = false, cres = 1, deep = 0 }) end   -- spools
  for i = 0, 6 do P(c, c:rect(110 + i * 16, 34, 120 + i * 16, 44), ({ RM.cream, RM.petal, RM.water, RM.red, RM.leaf, RM.gold, RM.dusk })[i + 1], { gloss = false, cres = 1, deep = 0 }) end
  P(c, c:rect(110, 24, 222, 26), RM.wood, { gloss = false, flat = true }); P(c, c:rect(110, 44, 222, 46), RM.wood, { gloss = false, flat = true })
  c:fill(c:rect(24, 12, 24, 60), "#8a4f2a"); c:fill(c:rect(24, 12, 60, 12), "#8a4f2a"); for x = 28, 58, 4 do c:fill(c:rect(x, 14, x, 56), "#f5cf6a") end      -- loom
  counterR(c, RM.wood, RM.cream); P(c, c:rrect(146, 82, 172, 94, 3), RM.red, { gloss = false, cres = 2, deep = 0 }); P(c, c:rrect(180, 84, 206, 94, 3), RM.petal, { gloss = false, cres = 2, deep = 0 })
  counterL(c, RM.wood, RM.petal)
end
-- ===== rest stops (outdoor scenes keep a left foreground object over y107..134) =====
local function sky(c, a, b) c:fill(c:rect(0, 0, W - 1, H - 1), b or "#c8ecdc"); c:fill(c:rect(0, 0, W - 1, 34), a or "#a9d6ea"); c:fill(c:rect(0, 35, W - 1, 44), "#eef8f2") end
local function grass(c, a, b) c:fill(c:rect(0, 80, W - 1, H - 1), a or "#7ab55c"); c:fill(c:rect(0, 100, W - 1, H - 1), b or "#4f9a45") end
local function hedge(c) P(c, c:rrect(-3, 106, 120, H + 2, 6), RM.dleaf, { gloss = false, cres = 4, deep = 0 }); for x = 8, 112, 14 do c:fill(c:rect(x, 114, x + 2, 116), "#7ab55c") end end
local function crates(c) counterL(c, RM.wood, RM.straw) end
S["stop-camp"] = function(c) sky(c); grass(c); for x = 10, 230, 28 do tree_out(c, x, 78, 34, RM.dleaf) end
  P(c, c:poly({ { 60, 100 }, { 90, 62 }, { 120, 100 } }), RM.cream, { gloss = false, cres = 3, deep = 0 }); c:fill(c:poly({ { 84, 100 }, { 90, 82 }, { 96, 100 } }), "#3d2a1c")
  P(c, c:rect(150, 96, 182, 100), RM.wood, { gloss = false, flat = true }); c:fill(c:poly({ { 156, 96 }, { 166, 76 }, { 176, 96 } }), "#f08a24"); c:fill(c:poly({ { 161, 96 }, { 166, 84 }, { 171, 96 } }), "#f5cf6a"); hedge(c) end
S["stop-ferry"] = function(c) sky(c); c:fill(c:rect(0, 56, W - 1, 100), "#3f8fb0"); for y = 62, 98, 7 do for x = (y % 14 == 0) and 6 or 22, W - 1, 30 do c:fill(c:rect(x, y, x + 6, y), "#a9d6ea") end end
  P(c, c:poly({ { 120, 74 }, { 210, 74 }, { 200, 90 }, { 130, 90 } }), RM.wood); c:fill(c:rect(164, 40, 165, 74), "#8a4f2a"); c:fill(c:poly({ { 166, 42 }, { 192, 70 }, { 166, 70 } }), "#f2e4c0")
  grass(c); c:fill(c:rect(0, 100, W - 1, H - 1), "#4f9a45"); c:fill(c:rect(0, 80, 112, 100), "#7ab55c"); P(c, c:rect(120, 98, 150, 102), RM.wood, { gloss = false, flat = true }); crates(c) end
S["stop-herb"] = function(c) sky(c); grass(c, "#a4b86a", "#7ab55c")
  for r = 0, 3 do for i = 0, 9 do P(c, c:ellipse(124 + i * 11, 88 + r * 5, 4, 3), (i + r) % 2 == 0 and RM.leaf or RM.dleaf, { gloss = false, flat = true }) end; c:fill(c:rect(118, 91 + r * 5, 232, 91 + r * 5), "#7a4a1f") end
  P(c, c:rect(30, 56, 80, 82), RM.cream, { gloss = false, cres = 3, deep = 0 }); P(c, c:poly({ { 26, 56 }, { 55, 34 }, { 84, 56 } }), RM.straw, { gloss = false, cres = 3, deep = 0 }); c:fill(c:rect(52, 68, 58, 82), "#8a4f2a"); hedge(c) end
S["stop-inn"] = function(c) sky(c); grass(c, "#7ab55c", "#c9a96e")
  P(c, c:rect(90, 40, 210, 96), RM.cream, { gloss = false, cres = 4, deep = 0 }); P(c, c:poly({ { 84, 40 }, { 150, 12 }, { 216, 40 } }), RM.red, { gloss = false, cres = 4, deep = 0 }); c:fill(c:rect(140, 70, 160, 96), "#8a4f2a")
  for _, x in ipairs({ 106, 176 }) do c:fill(c:rect(x, 54, x + 12, 66), "#f5cf6a"); c:fill(c:rect(x + 5, 54, x + 6, 66), "#8a4f2a") end; lantern(c, 130, 80); P(c, c:rect(218, 60, 220, 96), RM.wood, { gloss = false, flat = true }); crates(c) end
S["stop-jetty"] = function(c) sky(c); c:fill(c:rect(0, 52, W - 1, H - 1), "#3f8fb0"); for y = 58, 130, 8 do for x = (y % 16 == 0) and 6 or 22, W - 1, 30 do c:fill(c:rect(x, y, x + 6, y), "#a9d6ea") end end
  P(c, c:rect(100, 88, 236, 96), RM.wood, { gloss = false, cres = 3, deep = 0 }); for x = 104, 232, 16 do P(c, c:rect(x, 96, x + 3, 118), RM.dwood, { gloss = false, flat = true }) end
  P(c, c:poly({ { 180, 70 }, { 214, 70 }, { 208, 84 }, { 186, 84 } }), RM.wood); c:fill(c:rect(196, 46, 197, 70), "#8a4f2a"); c:fill(c:poly({ { 198, 48 }, { 214, 66 }, { 198, 66 } }), "#f2e4c0"); counterL(c, RM.dwood, RM.wood) end
S["stop-market"] = function(c) sky(c); grass(c, "#c9a96e", "#9a6b3f")
  for i, x in ipairs({ 80, 136, 192 }) do P(c, c:rect(x, 66, x + 40, 96), RM.wood, { gloss = false, cres = 3, deep = 0 }); P(c, c:poly({ { x - 4, 66 }, { x + 44, 66 }, { x + 40, 50 }, { x, 50 } }), i % 2 == 0 and RM.gold or RM.red, { gloss = false, cres = 3, deep = 0 }); for j = 0, 3 do P(c, c:ellipse(x + 8 + j * 8, 64, 3, 3), ({ RM.red, RM.leaf, RM.gold })[(i + j) % 3 + 1], { gloss = false, flat = true }) end end; crates(c) end
S["stop-mill"] = function(c) sky(c); grass(c)
  P(c, c:poly({ { 100, 96 }, { 108, 50 }, { 142, 50 }, { 150, 96 } }), RM.cream, { gloss = false, cres = 3, deep = 0 }); P(c, c:poly({ { 104, 50 }, { 125, 30 }, { 146, 50 } }), RM.dwood, { gloss = false, cres = 3, deep = 0 }); c:fill(c:rect(120, 76, 130, 96), "#8a4f2a")
  for a = 0, 3 do local dx, dy = ({ { 26, -26 }, { 26, 26 }, { -26, 26 }, { -26, -26 } })[a + 1][1], ({ { 26, -26 }, { 26, 26 }, { -26, 26 }, { -26, -26 } })[a + 1][2]; c:fill(c:line({ { 125, 46 }, { 125 + dx, 46 + dy } }, 2), "#b07a45"); c:fill(c:rect(125 + dx * 0.5 - 4, 46 + dy * 0.5 - 4, 125 + dx * 0.5 + 4, 46 + dy * 0.5 + 4), "#f2e4c0") end
  hedge(c) end
S["stop-orchard"] = function(c) sky(c); grass(c); for i, x in ipairs({ 40, 96, 152, 208 }) do tree_out(c, x, 92, 48, RM.leaf); for _, d in ipairs({ { -8, -4 }, { 4, -10 }, { 8, 2 } }) do c:fill(c:rect(x + d[1] - 1, 92 - 28 + d[2], x + d[1] + 1, 92 - 28 + d[2] + 2), "#dd3a2a") end end; crates(c) end
S["stop-shrine"] = function(c) sky(c, "#c3b2ea", "#f2e4c0"); grass(c, "#a4b86a", "#7ab55c")
  P(c, c:rect(104, 50, 108, 94), RM.dwood, { gloss = false, flat = true }); P(c, c:rect(140, 50, 144, 94), RM.dwood, { gloss = false, flat = true }); P(c, c:rect(96, 44, 152, 50), RM.red, { gloss = false, cres = 2, deep = 0 }); P(c, c:rect(100, 56, 148, 60), RM.red, { gloss = false, flat = true })
  P(c, c:rrect(118, 74, 130, 94, 2), RM.stone, { gloss = false, cres = 2, deep = 0 }); c:fill(c:rect(122, 62, 126, 74), "#f5cf6a"); for x = 56, 200, 48 do tree_out(c, x, 80, 28, RM.petal) end; hedge(c) end
S["stop-spring"] = function(c) sky(c); grass(c, "#7ab55c", "#4f9a45"); P(c, c:ellipse(150, 92, 40, 10), RM.stone, { gloss = false, cres = 3, deep = 0 }); c:fill(c:ellipse(150, 92, 32, 6), "#3f8fb0"); c:fill(c:rect(126, 90, 150, 90), "#a9d6ea")
  P(c, c:poly({ { 120, 30 }, { 176, 30 }, { 188, 66 }, { 108, 66 } }), RM.stone, { gloss = false, cres = 3, deep = 0 }); c:fill(c:rect(148, 66, 150, 84), "#3f8fb0"); c:fill(c:rect(148, 66, 148, 84), "#a9d6ea"); hedge(c) end

-- ===== second pass: extra dressing for the rest stops =====
local function cloud(c, x, y, r) c:fill(c:ellipse(x, y, r, 2), "#eef8f2"); c:fill(c:ellipse(x - r * 0.4, y - 1, r * 0.5, 2), "#eef8f2"); c:fill(c:ellipse(x + r * 0.4, y - 1, r * 0.5, 3), "#eef8f2") end
local function bush(c, x, y, r) P(c, c:ellipse(x, y, r, r * 0.6), RM.dleaf, { gloss = false, cres = 2, deep = 0 }) end
local function bloom(c, list, col) for _, f in ipairs(list) do c:fill(c:rect(f[1], f[2], f[1] + 1, f[2] + 1), col); c:px(f[1], f[2], "#fff3c8") end end
local function post(c, x, y, h) P(c, c:rect(x, y - h, x + 2, y), RM.wood, { gloss = false, flat = true }) end
local function barrel(c, x, y) P(c, c:rrect(x - 4, y - 8, x + 4, y, 2), RM.wood, { gloss = false, cres = 2, deep = 0 }); c:fill(c:rect(x - 4, y - 5, x + 4, y - 5), "#8a4f2a"); c:fill(c:rect(x - 4, y - 2, x + 4, y - 2), "#8a4f2a") end
local function apple(c, x, y) c:fill(c:rect(x, y, x + 1, y + 1), "#dd3a2a") end
local STOPX = {
  ["stop-camp"] = function(c) cloud(c, 50, 14, 10); cloud(c, 170, 24, 8); barrel(c, 196, 98); P(c, c:ellipse(120, 98, 8, 2), RM.wood, { gloss = false, flat = true }); bush(c, 30, 96, 10); bush(c, 214, 94, 9); bloom(c, { { 132, 108 }, { 190, 110 }, { 150, 114 } }, "#f6b8cf"); for i = 0, 2 do c:px(166 + i * 3, 70 - i * 3, "#f2e4c0") end end,
  ["stop-ferry"] = function(c) cloud(c, 40, 16, 10); cloud(c, 190, 12, 9); post(c, 126, 98, 10); post(c, 150, 98, 10); c:fill(c:rect(127, 90, 151, 90), "#d9a660"); barrel(c, 200, 98); bush(c, 214, 92, 9); for _, g in ipairs({ { 60, 40 }, { 74, 36 } }) do c:fill(c:rect(g[1], g[2], g[1] + 2, g[2]), "#eef8f2"); c:fill(c:rect(g[1] + 3, g[2], g[1] + 5, g[2]), "#eef8f2") end end,
  ["stop-herb"] = function(c) cloud(c, 60, 14, 10); cloud(c, 180, 20, 8); P(c, c:rect(20, 86, 24, 96), RM.wood, { gloss = false, flat = true }); bush(c, 100, 98, 9); for r = 0, 2 do for i = 0, 6 do c:fill(c:rect(150 + i * 10, 104 + r * 5, 152 + i * 10, 107 + r * 5), (i + r) % 2 == 0 and "#7ab55c" or "#4f9a45") end end; bloom(c, { { 60, 100 }, { 70, 104 }, { 90, 108 } }, "#f5cf6a"); c:fill(c:ellipse(130, 98, 4, 3), "#8b8f96") end,
  ["stop-inn"] = function(c) cloud(c, 40, 14, 10); cloud(c, 200, 20, 8); P(c, c:rect(60, 62, 62, 96), RM.wood, { gloss = false, flat = true }); P(c, c:rect(50, 62, 74, 72), RM.wood, { gloss = false, cres = 2, deep = 0 }); c:fill(c:ellipse(62, 67, 3, 2), "#f5cf6a"); barrel(c, 100, 98); barrel(c, 110, 98); bush(c, 208, 96, 9); c:fill(c:rect(136, 90, 140, 96), "#f5cf6a"); for x = 96, 216, 4 do c:px(x, 100, "#c9a96e") end end,
  ["stop-jetty"] = function(c) cloud(c, 60, 14, 10); cloud(c, 160, 22, 9); barrel(c, 208, 86); P(c, c:rect(168, 82, 178, 88), RM.wood, { gloss = false, cres = 2, deep = 0 }); c:fill(c:ellipse(112, 82, 3, 3), "#dd3a2a"); c:fill(c:rect(111, 78, 113, 79), "#f2e4c0"); for _, g in ipairs({ { 50, 40 }, { 80, 30 } }) do c:fill(c:rect(g[1], g[2], g[1] + 2, g[2]), "#eef8f2"); c:fill(c:rect(g[1] + 3, g[2], g[1] + 5, g[2]), "#eef8f2") end end,
  ["stop-market"] = function(c) cloud(c, 40, 14, 10); cloud(c, 190, 20, 8); for x = 74, 236, 8 do c:px(x, 40 + math.floor(2 * math.sin(x / 20) + 0.5), "#4a2c1a") end; for i = 0, 11 do local x = 76 + i * 13; c:fill(c:poly({ { x, 41 }, { x + 5, 41 }, { x + 2.5, 46 } }), ({ "#dd3a2a", "#f5cf6a", "#3f8fb0" })[i % 3 + 1]) end; barrel(c, 70, 98); barrel(c, 228, 98) end,
  ["stop-mill"] = function(c) cloud(c, 50, 14, 10); cloud(c, 190, 18, 9); for i = 0, 3 do P(c, c:rrect(60 + i * 6, 88 - (i % 2) * 5, 66 + i * 6, 96 - (i % 2) * 5, 2), RM.cream, { gloss = false, cres = 2, deep = 0 }) end; c:fill(c:rect(170, 94, 236, 100), "#3f8fb0"); c:fill(c:rect(170, 94, 236, 94), "#a9d6ea"); bush(c, 190, 92, 9); bloom(c, { { 160, 106 }, { 200, 110 } }, "#f6b8cf") end,
  ["stop-orchard"] = function(c) cloud(c, 50, 14, 10); cloud(c, 190, 20, 9); P(c, c:rrect(120, 96, 134, 102, 2), RM.wood, { gloss = false, cres = 2, deep = 0 }); for i = 0, 3 do apple(c, 122 + i * 3, 94 + (i % 2)) end; for _, a in ipairs({ { 70, 100 }, { 100, 104 }, { 170, 102 }, { 230, 100 } }) do apple(c, a[1], a[2]) end; for i = 0, 4 do c:fill(c:rect(180 + i * 3, 70 + i * 4, 181 + i * 3, 70 + i * 4), "#b07a45") end; bush(c, 14, 98, 10) end,
  ["stop-shrine"] = function(c) cloud(c, 50, 12, 10); cloud(c, 190, 18, 8); for _, x in ipairs({ 80, 168 }) do P(c, c:rect(x - 3, 82, x + 3, 94), RM.stone, { gloss = false, cres = 2, deep = 0 }); c:fill(c:rect(x - 1, 76, x + 1, 82), "#f5cf6a"); P(c, c:poly({ { x - 5, 76 }, { x, 70 }, { x + 5, 76 } }), RM.stone, { gloss = false, flat = true }) end; for i = 0, 8 do c:px(100 + i * 14, 40 + (i % 3) * 8, "#f6b8cf") end; for x = 104, 144, 3 do c:px(x, 52 + (x % 2), "#f2e4c0") end end,
  ["stop-spring"] = function(c) cloud(c, 50, 14, 10); cloud(c, 180, 20, 9); for _, f in ipairs({ { 100, 94 }, { 190, 98 }, { 110, 110 } }) do P(c, c:poly({ { f[1], f[2] }, { f[1] + 3, f[2] - 9 }, { f[1] + 7, f[2] } }), RM.dleaf, { gloss = false, flat = true }) end; P(c, c:ellipse(200, 96, 7, 4), RM.stone, { gloss = false, cres = 2, deep = 0 }); bloom(c, { { 90, 106 }, { 210, 108 }, { 130, 112 } }, "#f6b8cf"); for i = 0, 2 do c:px(150 + i * 3, 74 - i * 3, "#eef8f2") end end,
}
local ORDER = { "home-burrow", "home-treehouse", "home-hut", "home-stone", "home-boat", "shop-seeds", "shop-bakery", "shop-herbs", "shop-craft",
  "stop-camp", "stop-ferry", "stop-herb", "stop-inn", "stop-jetty", "stop-market", "stop-mill", "stop-orchard", "stop-shrine", "stop-spring" }
local only = os.getenv("ONLY"); local want = {}
if only then for k in only:gmatch("[^,]+") do want[k] = true end end
X.ramp("#7ab55c")
for _, name in ipairs(ORDER) do if not only or want[name] then
  local c = X.canvas{ mode = "scene", w = W, h = H, out = 2, ol = 1, olx = 1 }
  X.layer(c, "far"); S[name](c)
  if STOPX[name] then X.layer(c, "objects"); STOPX[name](c) end
  X.save(c, name, "scenes", { w = 480, h = 270, cap = 32 })
end end
