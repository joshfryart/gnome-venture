-- maps.lua : map-world (320x180 grid -> 640x360), map-world-regions (flat-colour mask, same size), 14 region maps (240x135 -> 480x270).
-- Region positions/colour families follow game/includes/maps.php REGION_MAP (1000x560 -> x0.32). No text, no pins, no labels.
-- World: a flat 12x12 grid (24x24 exported) is left clear at each region centre for the pin. Regions: 4 zones (gentle, medium, medium, hard) on a path outward from a market village.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local function R(base, shade, rim) return X.ramp(base, { shade = shade, deep = shade, bounce = shade, rim = rim or base, gloss = base, dot = base }) end
X.ramp("#7ab55c")
local RM = { wood = R("#b07a45", "#8a4f2a", "#d9a660"), stone = R("#8b8f96", "#5b6470", "#c9c5bc"), cream = R("#f2e4c0", "#d8c49a"), leaf = R("#7ab55c", "#4f9a45"), dleaf = R("#4f9a45", "#2f6a3a"),
  red = R("#dd3a2a", "#ae2a2a", "#f2793a"), gold = R("#f5cf6a", "#e8a317"), petal = R("#e46a9b", "#b8452f", "#f6b8cf"), clay = R("#e0501f", "#a8582f", "#f08a24"), sand = R("#f5cf6a", "#c9a96e") }
local OP = { gloss = false, cres = 2, deep = 0 }
local function P(c, m, r, o) c:part(m, r, o or OP) end
-- name = { x, y, r (1000x560 space), colour, [glyph] }
local REG = {
  { "NA", 215, 140, 70, "#7ab55c", "peak" }, { "CA", 190, 262, 38, "#c9a96e", "cactus" }, { "CB", 318, 238, 30, "#c8ecdc", "palm" }, { "SA", 305, 390, 62, "#4f9a45", "palm" },
  { "NWE", 462, 112, 42, "#a4b86a", "tower" }, { "SE", 505, 195, 36, "#f5cf6a", "tree" }, { "EE", 612, 105, 48, "#bdd292", "dome" }, { "MENA", 560, 245, 52, "#d9a660", "dome" },
  { "WCA", 490, 315, 44, "#2f6a3a", "tree" }, { "ESA", 590, 395, 50, "#9a6b3f", "peak" }, { "CSA", 700, 225, 58, "#e0501f", "pagoda" }, { "EA", 830, 170, 55, "#f6b8cf", "pagoda" },
  { "SEA", 800, 300, 44, "#6a9a3a", "palm" }, { "OC", 885, 440, 52, "#f5cf6a", "palm" } }
local function blob(c, m, i, cx, cy, r)   -- union of circles around (cx,cy), deterministic from the region index
  local s = i * 7919 + 13; local function rnd(n) s = (s * 1103515245 + 12345) % 2147483648 return s % n end
  m:add(c:ellipse(cx, cy, r, r * 0.8))
  for k = 1, 5 do local a = rnd(628) / 100; local d = r * (0.45 + rnd(40) / 100); m:add(c:ellipse(cx + math.cos(a) * d, cy + math.sin(a) * d * 0.8, r * (0.45 + rnd(25) / 100), r * 0.4)) end
  return m
end
local function glyph(c, g, x, y, s)
  s = s or 1
  if g == "peak" then P(c, c:poly({ { x - 6 * s, y }, { x, y - 10 * s }, { x + 6 * s, y } }), RM.stone, { gloss = false, cres = 2, deep = 0 }); c:fill(c:poly({ { x - 2 * s, y - 6 * s }, { x, y - 10 * s }, { x + 2 * s, y - 6 * s } }), "#f2e4c0")
  elseif g == "cactus" then P(c, c:rrect(x - 1, y - 8 * s, x + 1, y, 1), RM.leaf, { gloss = false, flat = true }); c:fill(c:rect(x - 4, y - 5 * s, x - 2, y - 3 * s), "#7ab55c"); c:fill(c:rect(x + 2, y - 6 * s, x + 4, y - 4 * s), "#7ab55c")
  elseif g == "palm" then c:fill(c:rect(x, y - 7 * s, x + 1, y), "#8a4f2a"); for _, d in ipairs({ -4, 4 }) do c:fill(c:rect(x + 0.5 + d, y - 8 * s, x + d + 2, y - 7 * s), "#4f9a45") end; c:fill(c:rect(x - 1, y - 9 * s, x + 2, y - 8 * s), "#4f9a45")
  elseif g == "tower" then P(c, c:rect(x - 3, y - 10 * s, x + 3, y), RM.stone, { gloss = false, flat = true }); c:fill(c:poly({ { x - 4, y - 10 * s }, { x, y - 14 * s }, { x + 4, y - 10 * s } }), "#7a5cc0")
  elseif g == "tree" then c:fill(c:rect(x, y - 3 * s, x, y), "#8a4f2a"); P(c, c:ellipse(x, y - 6 * s, 4 * s, 3 * s), RM.dleaf, { gloss = false, flat = true })
  elseif g == "dome" then P(c, c:rect(x - 4, y - 4 * s, x + 4, y), RM.cream, { gloss = false, flat = true }); P(c, c:ellipse(x, y - 4 * s, 4, 4):cut(c:rect(x - 5, y - 4 * s + 1, x + 5, y)), RM.gold, { gloss = false, flat = true })
  elseif g == "pagoda" then for i = 0, 1 do c:fill(c:rect(x - 3 + i, y - 4 - i * 5, x + 3 - i, y - i * 5), "#f2e4c0"); c:fill(c:rect(x - 5 + i, y - 5 - i * 5, x + 5 - i, y - 4 - i * 5), "#dd3a2a") end end
end

-- ===== world =====
local function rockbg(c, w, h)   -- solid rock: wavy strata, pebbles, a few embedded crystals, stalactites above and stalagmites below
  c:fill(c:rect(0, 0, w - 1, h - 1), "#3d2a1c")
  for y = 0, h - 1 do for x = 0, w - 1 do
    local v = math.floor((y + 4 * math.sin(x / 38 + y / 29) + 3 * math.sin(x / 13)) / 10) % 3
    if v == 1 then c:px(x, y, "#4a2c1a") elseif v == 2 and (x * 3 + y) % 19 < 2 then c:px(x, y, "#5e2f1e") end
  end end
  local rs = 5; local function rr(n) rs = (rs * 1103515245 + 12345) % 2147483648 return rs % n end
  for i = 1, w * h // 640 do local x, y = rr(w - 2), rr(h - 2); c:px(x, y, "#5b6470"); c:px(x + 1, y, "#5b6470") end
  for i = 1, w * h // 3200 do local x, y = rr(w - 2), 8 + rr(h - 20); c:px(x, y, "#7a5cc0"); c:px(x, y - 1, "#c3b2ea") end
  for x = 0, w - 1, 7 do local hh = 5 + (x * 13) % 9; c:fill(c:poly({ { x - 3, 0 }, { x, hh }, { x + 3, 0 } }), "#2a1a10") end
  for x = 3, w - 1, 11 do local hh = 4 + (x * 7) % 7; c:fill(c:poly({ { x - 3, h - 1 }, { x, h - 1 - hh }, { x + 3, h - 1 } }), "#2a1a10") end
end
-- ===== cavern glyphs (the Hollow is underground: caverns joined by mycelium paths) =====
local function shroom(c, x, y, sc, cap) c:fill(c:rect(x, y - 4 * sc, x + 1, y), "#f2e4c0"); c:fill(c:ellipse(x + 0.5, y - 4 * sc, 3 * sc, 2 * sc), cap); c:px(x - 1, y - 4 * sc, "#fff3c8"); c:px(x + 2, y - 4 * sc - 1, "#fff3c8") end
local function crystalc(c, x, y, h, col) c:fill(c:poly({ { x - 2, y }, { x - 1, y - h * 0.7 }, { x, y - h }, { x + 1, y - h * 0.7 }, { x + 2, y } }), col); c:fill(c:poly({ { x + 2, y }, { x + 3, y - h * 0.5 }, { x + 4, y } }), col); c:px(x, y - h + 2, "#fff3c8") end
local function stalag(c, x, y, h, a, b) c:fill(c:poly({ { x - 3, y }, { x, y - h }, { x + 3, y } }), a); c:fill(c:poly({ { x, y - h }, { x + 3, y }, { x + 1, y } }), b) end
local function pool(c, x, y, rx) c:fill(c:ellipse(x, y, rx, rx * 0.45), "#3f8fb0"); c:fill(c:rect(x - rx + 2, y - 1, x - 1, y - 1), "#a9d6ea") end
local function lava(c, x, y, rx) c:fill(c:ellipse(x, y, rx, rx * 0.45), "#d6322b"); c:fill(c:ellipse(x, y, rx * 0.5, rx * 0.2), "#f08a24"); c:px(x, y, "#f5cf6a") end
local function coral(c, x, y, h, col) for i = -1, 1 do c:fill(c:poly({ { x + i * 2 - 1, y }, { x + i * 3, y - h + (i == 0 and 0 or 2) }, { x + i * 2 + 1, y } }), col) end end
local function glowdot(c, x, y) c:px(x, y, "#f5cf6a"); c:px(x - 1, y, "#fff3c8"); c:px(x + 1, y, "#fff3c8") end
local FEAT = {
  NA = { { "shroom", "#dd3a2a" }, { "shroom", "#e46a9b" }, { "glow" } }, CA = { { "crystal", "#c3b2ea" }, { "crystal", "#7a5cc0" }, { "glow" } }, CB = { { "pool" }, { "shroom", "#a9d6ea" } },
  SA = { { "root" }, { "shroom", "#4f9a45" }, { "glow" } }, NWE = { { "stalag", "#8b8f96", "#5b6470" }, { "pool" } }, SE = { { "shroom", "#f5cf6a" }, { "glow" }, { "glow" } },
  EE = { { "crystal", "#a9d6ea" }, { "crystal", "#eef8f2" } }, MENA = { { "stalag", "#e8a317", "#a8582f" }, { "dune" } }, WCA = { { "shroom", "#7ab55c" }, { "shroom", "#c8d77a" }, { "root" } },
  SEA = { { "pool" }, { "shroom", "#7ab55c" }, { "glow" } }, OC = { { "coral", "#f08a24" }, { "pool" } } }

-- ===== region OC (upgrade): underground lake cavern, lit only by glowing coral, bioluminescence and village lanterns =====
local PINS = { { 40, 100 }, { 70, 70 }, { 95, 100 }, { 120, 65 }, { 140, 98 }, { 165, 70 }, { 185, 100 }, { 205, 65 }, { 212, 100 } }
local ZONES = { { 40, 100, 34 }, { 95, 70, 38 }, { 150, 95, 40 }, { 205, 75, 36 } }
local ri = 14
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2, ol = 1, olx = 1 }
X.layer(c, "sky"); rockbg(c, 240, 135)
X.layer(c, "ground")
local land = c:mask(); for x = 0, 239 do land:rect(x, 11 + math.floor(3 * math.sin(x / 13 + ri) + 0.5), x, 126 - math.floor(3 * math.sin(x / 9 + ri) + 0.5)) end
land:cut(c:rect(0, 0, 5, 134)):cut(c:rect(234, 0, 239, 134))
-- light sources: { x, y, radius, kind } warm = lanterns/village, cool = coral lake, crystals, glow pools
local LS = { { 26, 86, 46, "w" }, { 150, 100, 26, "w" }, { 112, 34, 64, "c" }, { 206, 44, 44, "c" }, { 196, 120, 30, "c" }, { 70, 70, 26, "c" }, { 178, 84, 26, "c" }, { 222, 92, 22, "w" }, { 168, 60, 18, "c" } }
local WARM = { "#2a1a10", "#4a2c1a", "#7a4a1f", "#9a6b3f", "#c9a96e", "#d9a660" }
local COOL = { "#2a1a10", "#1f3f3a", "#2f6a3a", "#5b6470", "#8b8f96", "#c8ecdc" }
local function lit(x, y)
  local bw, bc = 0, 0
  for _, s in ipairs(LS) do
    local dx, dy = (x - s[1]), (y - s[2]) * 1.4; local d = math.sqrt(dx * dx + dy * dy) / s[3]
    local BY = { 0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5 }
    local l = math.max(0, 5 - math.floor(d * 5 + (BY[(y % 4) * 4 + (x % 4) + 1] / 16 - 0.5) * 0.9 + 0.5 * math.sin(x / 5 + y / 7) * 0.3))
    if s[4] == "w" then bw = math.max(bw, l) else bc = math.max(bc, l) end
  end
  return bw, bc
end
land:each(function(x, y)
  local bw, bc = lit(x, y); local l = math.max(bw, bc, 1)
  c:px(x, y, (bw >= bc) and WARM[l + 1 > 6 and 6 or l + 1 - (l == 5 and 1 or 0)] or COOL[l + 1 > 6 and 6 or l + 1 - (l == 5 and 1 or 0)])
end)
-- sand ripples on lit floor
local ts = ri * 17 + 3; local function trnd(n) ts = (ts * 1103515245 + 12345) % 2147483648 return ts % n end
for i = 1, 140 do local x, y = 8 + trnd(224), 14 + trnd(110); if land:has(x, y) then local bw, bc = lit(x, y); if math.max(bw, bc) >= 3 then local col = bw >= bc and WARM[3] or COOL[3]; c:px(x, y, col); c:px(x + 1, y, col) end end end
-- the underground lake (north), stream feeding south, glow pool
local lake = c:mask(); lake:add(c:ellipse(112, 34, 30, 11)); lake:add(c:ellipse(92, 40, 14, 7)); lake:add(c:ellipse(134, 40, 14, 6)); lake:clip(land)
local river = c:mask()
for t = 0, 1, 0.01 do river:add(c:ellipse(math.floor(150 + 34 * math.sin(t * 4.2 + ri) + 0.5), math.floor(4 + t * 126), 1, 1)) end
river:clip(land); river:add(c:line({ { 134, 42 }, { 145, 50 }, { 150 + 34 * math.sin(0.4 + ri) , 58 } }, 2)); river:clip(land)
c:fill(lake:copy():grow(1), "#2a1a10")
c:fill(river, "#1f3f3a"); c:fill(lake, "#1f3f3a")
local lin = lake:copy(); lin:each(function(x, y) local dx, dy = (x - 112) / 30, (y - 34) / 11; local d = dx * dx + dy * dy; if d < 0.25 then c:px(x, y, "#a9d6ea") elseif d < 0.6 then c:px(x, y, "#3f8fb0") end end)
lake:edge():each(function(x, y) if (x + y) % 3 == 0 then c:px(x, y, "#c8ecdc") end end)
river:each(function(x, y) if (x + y) % 5 == 0 then c:px(x, y, "#3f8fb0") elseif (x + y) % 11 == 0 then c:px(x, y, "#a9d6ea") end end)
local gp = c:ellipse(196, 120, 7, 2); c:fill(gp:copy():grow(1), "#2a1a10"); c:fill(gp, "#3f8fb0"); c:fill(c:ellipse(196, 120, 3, 1), "#a9d6ea"); c:px(195, 120, "#eef8f2")
X.layer(c, "objects")
c:outline(land, { ol = 1, olx = 1 })
-- roads (3 px), lit by banding: sand path pale near light, dim in shadow
local roadM = c:mask()
for i = 1, #ZONES - 1 do roadM:add(c:line({ { ZONES[i][1], ZONES[i][2] }, { (ZONES[i][1] + ZONES[i + 1][1]) / 2, (ZONES[i][2] + ZONES[i + 1][2]) / 2 - 8 }, { ZONES[i + 1][1], ZONES[i + 1][2] } }, 3)) end
roadM:add(c:line({ { ZONES[2][1], ZONES[2][2] }, { 140, 52 }, { 190, 48 } }, 3))
roadM:add(c:line({ { ZONES[3][1], ZONES[3][2] }, { 170, 120 }, { 120, 118 } }, 3))
roadM:cut(lake)
roadM:each(function(x, y) local bw, bc = lit(x, y); local l = math.max(bw, bc); c:px(x, y, l >= 4 and "#f2e4c0" or (l >= 3 and "#d8c49a" or (l >= 2 and "#9a6b3f" or "#7a4a1f"))) end)
local bridge = roadM:copy():clip(river:copy():grow(1)):grow(1)
c:fill(bridge, "#8a4f2a"); bridge:each(function(x, y) if x % 2 == 0 then c:px(x, y, "#4a2c1a") end end)
-- glowing coral ring round the lake (light source)
local CORAL = { { 80, 38, "#f08a24" }, { 86, 47, "#e46a9b" }, { 100, 48, "#f6b8cf" }, { 126, 48, "#f08a24" }, { 142, 44, "#e46a9b" }, { 140, 28, "#f6b8cf" }, { 84, 30, "#e46a9b" }, { 118, 22, "#f08a24" }, { 100, 23, "#f6b8cf" } }
for _, k in ipairs(CORAL) do coral(c, k[1], k[2], 7, k[3]); c:px(k[1], k[2] - 7, "#fff3c8"); c:px(k[1] - 3, k[2] - 5, "#ffc27a"); c:px(k[1] + 3, k[2] - 5, "#ffc27a") end
-- glow-crystal cluster (NE), cool light
for _, k in ipairs({ { 200, 46, 12, "#a9d6ea" }, { 206, 44, 16, "#c8ecdc" }, { 212, 47, 11, "#c3b2ea" }, { 196, 49, 7, "#7a5cc0" }, { 216, 50, 7, "#a9d6ea" } }) do crystalc(c, k[1], k[2], k[3], k[4]) end
c:fill(c:rect(194, 50, 220, 51), "#5b6470")
-- glowing shell/kelp clusters and glow dots across the floor, mushrooms near the village
local seed = ri * 31 + 5; local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
local HOUSES = { { 18, 76 }, { 30, 70 }, { 14, 94 }, { 8, 58 }, { 22, 56 }, { 6, 82 } }
local placed = 0
for try = 1, 260 do
  if placed >= 30 then break end
  local x, y = 12 + rnd(216), 20 + rnd(98)
  local ok = land:has(x, y) and land:has(x, y + 6) and not lake:copy():grow(4):has(x, y) and not roadM:has(x, y)
  for _, p in ipairs(PINS) do if math.abs(x - p[1]) < 12 and math.abs(y - p[2]) < 12 then ok = false end end
  for _, h in ipairs(HOUSES) do if math.abs(x - h[1]) < 14 and math.abs(y - h[2]) < 14 then ok = false end end; if x < 50 and y > 90 and y < 118 then ok = false end
  if math.abs(x - 206) < 16 and math.abs(y - 44) < 14 then ok = false end
  if ok then local k = placed % 4
    if k == 0 then coral(c, x, y, 5, placed % 8 == 0 and "#e46a9b" or "#f08a24"); c:px(x, y - 5, "#fff3c8")
    elseif k == 1 then shroom(c, x, y, 1, "#a9d6ea") elseif k == 2 then glowdot(c, x, y)
    else c:fill(c:rect(x, y - 5, x, y), "#2f6a3a"); c:px(x + 1, y - 3, "#4f9a45"); c:px(x, y - 6, "#c8ecdc") end
    placed = placed + 1 end
end
-- stalagmite outcrops in the dark east
for i = 1, 6 do local x, y = 160 + trnd(70), 60 + trnd(55); local ok = land:has(x, y) and not river:copy():grow(3):has(x, y) and not roadM:copy():grow(3):has(x, y); for _, p in ipairs(PINS) do if math.abs(x - p[1]) < 12 and math.abs(y - p[2]) < 12 then ok = false end end; if ok then stalag(c, x, y, 8, "#5b6470", "#8b8f96") end end
-- east groves: coral, kelp, glow mushrooms, stalagmites
local es = 777; local function ern(n) es = (es * 1103515245 + 12345) % 2147483648 return es % n end
local function freeE(x, y) if not (land:has(x, y) and land:has(x, y + 4)) or river:copy():grow(2):has(x, y) or roadM:copy():grow(2):has(x, y) or lake:copy():grow(3):has(x, y) then return false end
  for _, p in ipairs(PINS) do if math.abs(x - p[1]) < 13 and math.abs(y - p[2]) < 13 then return false end end
  if math.abs(x - 206) < 16 and math.abs(y - 44) < 14 then return false end; if math.abs(x - 196) < 10 and math.abs(y - 120) < 5 then return false end; return true end
local ep = 0
for try = 1, 900 do if ep >= 70 then break end
  local x, y = 150 + ern(84), 18 + ern(104)
  if freeE(x, y) then local k = ep % 5
    if k == 0 then coral(c, x, y, 5 + ern(3), ({ "#f08a24", "#e46a9b", "#f6b8cf" })[ern(3) + 1]); c:px(x, y - 5, "#fff3c8")
    elseif k == 1 then c:fill(c:rect(x, y - 6, x, y), "#2f6a3a"); c:px(x + 1, y - 3, "#4f9a45"); c:px(x - 1, y - 5, "#4f9a45"); c:px(x, y - 7, "#c8ecdc")
    elseif k == 2 then shroom(c, x, y, 1, ep % 2 == 0 and "#a9d6ea" or "#c3b2ea")
    elseif k == 3 then stalag(c, x, y, 6 + ern(5), "#5b6470", "#8b8f96")
    else glowdot(c, x, y) end
    ep = ep + 1 end
end
-- village: houses with glowing lantern windows, a hanging lantern string
for _, h in ipairs(HOUSES) do P(c, c:rect(h[1], h[2], h[1] + 9, h[2] + 7), RM.cream, { gloss = false, flat = true }); P(c, c:poly({ { h[1] - 1, h[2] }, { h[1] + 4.5, h[2] - 5 }, { h[1] + 10, h[2] } }), RM.clay, { gloss = false, flat = true }); c:fill(c:rect(h[1] + 2, h[2] + 2, h[1] + 3, h[2] + 3), "#f5cf6a"); c:px(h[1] + 2, h[2] + 2, "#fff3c8") end
for x = 6, 40, 4 do c:px(x, 112, "#8a4f2a") end; c:fill(c:rect(6, 111, 40, 111), "#9a6b3f")
for i = 0, 1 do local x = 20 + i * 14; for dx = 0, 8, 2 do c:fill(c:rect(x + dx, 100, x + dx, 104), "#dd3a2a"); c:fill(c:rect(x + dx + 1, 100, x + dx + 1, 104), "#f2e4c0") end; c:fill(c:rect(x, 105, x + 9, 106), "#8a4f2a"); c:px(x + 4, 99, "#f5cf6a") end
for _, q in ipairs({ { 42, 66 }, { 46, 86 }, { 10, 106 } }) do c:fill(c:rect(q[1], q[2] - 6, q[1], q[2]), "#4a2c1a"); c:fill(c:rect(q[1] - 1, q[2] - 9, q[1] + 1, q[2] - 7), "#f5cf6a"); c:px(q[1], q[2] - 8, "#fff3c8") end
-- stalactite ceiling lip: hanging teeth over the cavern top edge
for x = 2, 238, 5 do local hh = 6 + (x * 13) % 10; c:fill(c:poly({ { x - 3, 0 }, { x, hh }, { x + 3, 0 } }), "#2a1a10"); c:px(x - 1, 1, "#4a2c1a") end
for x = 4, 238, 9 do local hh = 3 + (x * 7) % 5; c:fill(c:poly({ { x - 3, 134 }, { x, 134 - hh }, { x + 3, 134 } }), "#2a1a10") end
X.layer(c, "detail")
for _, p in ipairs(PINS) do c:fill(c:rect(p[1] - 5, p[2] - 5, p[1] + 4, p[2] + 4), (function() local bw, bc = lit(p[1], p[2]); local l = math.max(bw, bc, 1); l = math.min(l + 1, 5); return bw >= bc and WARM[l] or COOL[l] end)())
  if not roadM:has(p[1] + 7, p[2] - 4) and land:has(p[1] + 7, p[2]) then for _, o in ipairs({ { -7, -6 }, { 7, -5 }, { -7, 5 }, { 7, 6 }, { 0, -7 }, { 0, 7 } }) do local x, y = p[1] + o[1], p[2] + o[2]
    if not roadM:has(x, y) and not lake:has(x, y) and not river:has(x, y) then c:px(x, y, "#5b6470"); c:px(x + 1, y, "#8b8f96") end end
    c:px(p[1] - 6, p[2] - 6, "#c8ecdc"); c:px(p[1] + 6, p[2] + 5, "#f6b8cf") end end
X.save(c, "map-OC-up2", "scenes", { w = 480, h = 270, cap = 32 })
