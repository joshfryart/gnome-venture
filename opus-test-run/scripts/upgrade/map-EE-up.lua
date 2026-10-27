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
  ESA = { { "stalag", "#c9a96e", "#9a6b3f" }, { "root" } }, CSA = { { "lava" }, { "stalag", "#a8582f", "#5e2f1e" } }, EA = { { "coral", "#e46a9b" }, { "coral", "#f6b8cf" }, { "glow" } },
  SEA = { { "pool" }, { "shroom", "#7ab55c" }, { "glow" } }, OC = { { "coral", "#f08a24" }, { "pool" } } }
local function feat(c, f, x, y, mask)
  local k = f[1]
  if k == "shroom" then shroom(c, x, y, 1.3, f[2]) elseif k == "crystal" then crystalc(c, x, y, 9, f[2]) elseif k == "stalag" then stalag(c, x, y, 9, f[2], f[3])
  elseif k == "pool" then pool(c, x, y, 7) elseif k == "lava" then lava(c, x, y, 7) elseif k == "coral" then coral(c, x, y, 8, f[2]) elseif k == "glow" then glowdot(c, x, y)
  elseif k == "root" then c:fill(c:rect(x, y - 12, x, y - 2), "#8a4f2a"); c:px(x - 1, y - 8, "#8a4f2a"); c:px(x + 1, y - 5, "#8a4f2a"); c:fill(c:ellipse(x, y - 1, 2, 1), "#8a4f2a")
  elseif k == "dune" then c:fill(c:rect(x - 5, y, x + 5, y), "#f5cf6a"); c:fill(c:rect(x - 3, y + 2, x + 6, y + 2), "#f5cf6a") end
end
-- ===== regions =====
-- per region: 4 ground tints gentle -> hard, road colour, village roof ramp
local TINT = {
  NA = { "#a4b86a", "#7ab55c", "#4f9a45", "#2f5a2a" }, CA = { "#f5cf6a", "#c9a96e", "#9a6b3f", "#7a4a1f" }, CB = { "#f5cf6a", "#c8ecdc", "#7ab55c", "#4f9a45" }, SA = { "#a4b86a", "#4f9a45", "#2f6a3a", "#2f5a2a" },
  NWE = { "#bdd292", "#a4b86a", "#7ab55c", "#5b6470" }, SE = { "#f5cf6a", "#bdd292", "#a4b86a", "#c9a96e" }, EE = { "#f1ece0", "#bdd292", "#a4b86a", "#5b6470" }, MENA = { "#f5cf6a", "#d9a660", "#c9a96e", "#9a6b3f" },
  WCA = { "#7ab55c", "#4f9a45", "#2f6a3a", "#2f5a2a" }, ESA = { "#a4b86a", "#c9a96e", "#9a6b3f", "#5b6470" }, CSA = { "#f5cf6a", "#f08a24", "#e0501f", "#a8582f" }, EA = { "#f6b8cf", "#a4b86a", "#7ab55c", "#8b8f96" },
  SEA = { "#a4b86a", "#6a9a3a", "#4f9a45", "#2f6a3a" }, OC = { "#f5cf6a", "#f2e4c0", "#c8ecdc", "#7ab55c" } }
local PINS = { { 40, 100 }, { 70, 70 }, { 95, 100 }, { 120, 65 }, { 140, 98 }, { 165, 70 }, { 185, 100 }, { 205, 65 }, { 212, 100 } }   -- grid px (20x20 exported = 10x10 flat)
local ZONES = { { 40, 100, 34 }, { 95, 70, 38 }, { 150, 95, 40 }, { 205, 75, 36 } }
-- ===== EE upgrade: frost cavern, a glowing ice-crystal cluster + dome-village lanterns are the only light =====
do
  local ri, r = 7, REG[7]
  local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2, ol = 1, olx = 1 }
  X.layer(c, "sky"); rockbg(c, 240, 135)
  X.layer(c, "ground")
  local land = c:mask(); for x = 0, 239 do land:rect(x, 6 + math.floor(3 * math.sin(x / 13 + ri) + 0.5), x, 128 - math.floor(3 * math.sin(x / 9 + ri) + 0.5)) end
  land:cut(c:rect(0, 0, 3, 134)):cut(c:rect(236, 0, 239, 134))
  local river = c:mask(); local RP = {}
  for t = 0, 1, 0.01 do local x, y = math.floor(150 + 34 * math.sin(t * 4.2 + ri) + 0.5), math.floor(4 + t * 126); river:add(c:ellipse(x, y, 1, 1)); RP[#RP + 1] = { x, y } end
  river:clip(land)
  local lk = { 36, 40 }
  local CRY = { 178, 52 }   -- the great glow crystal cluster
  local SMALL = { { 214, 104, 4 }, { 120, 116, 4 }, { 112, 30, 4 } }
  local SRC = { { 22, 80, 44 }, { CRY[1], CRY[2], 50 }, { lk[1], lk[2], 26 } }
  for _, v in ipairs(SMALL) do SRC[#SRC + 1] = { v[1], v[2], 26 } end
  local BAND = { { 38, "#eef8f2" }, { 28, "#a9d6ea" }, { 18, "#bdd292" }, { 9, "#8b8f96" }, { 0, "#5b6470" }, { -1e9, "#1f3f3a" } }
  local function band(L) for i, b in ipairs(BAND) do if L >= b[1] then return i end end end
  local light = {}
  for y = 0, 134 do for x = 0, 239 do if land:has(x, y) then
    local L = -1e9
    for _, s in ipairs(SRC) do local dx, dy = x - s[1], (y - s[2]) * 1.4; local v = s[3] - math.sqrt(dx * dx + dy * dy); if v > L then L = v end end
    local e = math.min(y - 6, 128 - y, x - 4, 235 - x); if e < 16 then L = L - (16 - e) * 1.2 end
    light[y * 240 + x] = L
    local i = band(L)
    -- 2 px checker dither just above each band edge
    if i < #BAND and L - BAND[i][1] < 2.5 and (x + y) % 2 == 0 then i = i + 1 end
    c:px(x, y, BAND[i][2])
  end end end
  local ts = ri * 17 + 3; local function trnd(n) ts = (ts * 1103515245 + 12345) % 2147483648 return ts % n end
  local DARKER = { ["#eef8f2"] = "#a9d6ea", ["#a9d6ea"] = "#bdd292", ["#bdd292"] = "#8b8f96", ["#8b8f96"] = "#5b6470", ["#5b6470"] = "#1f3f3a" }
  for i = 1, 160 do local x, y = 6 + trnd(228), 10 + trnd(116); if land:has(x, y) then local d = DARKER[c:get(x, y)]; if d then c:paint({ "x.x", ".x." }, x, y, { x = d }) end end end
  local zm = {}
  for zi = 4, 1, -1 do local z = ZONES[zi]; local m = c:mask(); m:add(c:ellipse(z[1], z[2], z[3], 30)); m:add(c:ellipse(z[1] + 8, z[2] - 14, z[3] * 0.6, 20)); m:clip(land); zm[zi] = m end
  for zi = 2, 4 do zm[zi]:edge():each(function(x, y) if (x + y) % 4 < 2 and land:has(x, y) then local L = light[y * 240 + x] or -99; c:px(x, y, L >= 18 and "#f5cf6a" or "#a4b86a") end end) end
  -- frozen river and frozen lake
  c:fill(river, "#3f8fb0"); river:each(function(x, y) if (x + y) % 5 == 0 then c:px(x, y, "#eef8f2") elseif (x + y) % 5 == 2 then c:px(x, y, "#a9d6ea") end end)
  local lm = c:ellipse(lk[1], lk[2], 11, 5); lm:clip(land); c:fill(lm, "#a9d6ea"); c:fill(c:ellipse(lk[1], lk[2], 7, 3), "#eef8f2"); c:fill(c:rect(lk[1] - 4, lk[2] - 1, lk[1] + 2, lk[2] - 1), "#3f8fb0"); lm:edge():each(function(x, y) c:px(x, y, "#3f8fb0") end)
  X.layer(c, "objects")
  c:outline(land, { ol = 1, olx = 1 })
  local roadM = c:mask()
  for i = 1, #ZONES - 1 do roadM:add(c:line({ { ZONES[i][1], ZONES[i][2] }, { (ZONES[i][1] + ZONES[i + 1][1]) / 2, (ZONES[i][2] + ZONES[i + 1][2]) / 2 - 8 }, { ZONES[i + 1][1], ZONES[i + 1][2] } }, 3)) end
  roadM:add(c:line({ { ZONES[2][1], ZONES[2][2] }, { 140, 40 }, { 190, 38 } }, 3))
  roadM:add(c:line({ { ZONES[3][1], ZONES[3][2] }, { 170, 120 }, { 120, 118 } }, 3))
  roadM:each(function(x, y) if land:has(x, y) then local L = light[y * 240 + x] or -99; local a, b = "#d8c49a", "#c9a96e"; if L >= 28 then a, b = "#f2e4c0", "#d8c49a" elseif L < 9 then a, b = "#8b8f96", "#5b6470" end; if L < 0 then a, b = "#5b6470", "#1f3f3a" end; c:px(x, y, (x + y) % 6 == 0 and b or a) end end)
  local bridge = roadM:copy():clip(river:copy():grow(1)):grow(1)
  c:fill(bridge, "#8a4f2a"); bridge:each(function(x, y) if x % 2 == 0 then c:px(x, y, "#b07a45") end end)
  -- dome village: cream walls, gold domes, lit windows
  local HOUSES = { { 18, 76 }, { 30, 70 }, { 14, 94 }, { 8, 58 }, { 22, 56 }, { 6, 82 } }
  for _, h in ipairs(HOUSES) do P(c, c:rect(h[1], h[2], h[1] + 9, h[2] + 7), RM.cream, { gloss = false, flat = true }); P(c, c:ellipse(h[1] + 4.5, h[2], 5, 5):cut(c:rect(h[1] - 2, h[2] + 1, h[1] + 11, h[2] + 8)), RM.gold, { gloss = false, flat = true }); c:fill(c:rect(h[1] + 3, h[2] + 3, h[1] + 5, h[2] + 5), "#f5cf6a"); c:px(h[1] + 4, h[2] + 4, "#fff3c8") end
  for x = 4, 40, 4 do c:px(x, 112, "#8a4f2a") end; c:fill(c:rect(4, 111, 40, 111), "#d9a660")
  for i = 0, 1 do local x = 20 + i * 14; for dx = 0, 8, 2 do c:fill(c:rect(x + dx, 100, x + dx, 104), "#3f8fb0"); c:fill(c:rect(x + dx + 1, 100, x + dx + 1, 104), "#f2e4c0") end; c:fill(c:rect(x, 105, x + 9, 106), "#8a4f2a"); glowdot(c, x + 4, 98) end
  -- the great crystal cluster (light source)
  local CC = { { -8, 10, "#a9d6ea" }, { -3, 18, "#eef8f2" }, { 2, 22, "#eef8f2" }, { 7, 14, "#a9d6ea" }, { 11, 9, "#3f8fb0" }, { -12, 7, "#3f8fb0" } }
  for _, k in ipairs(CC) do local x, y, hh = CRY[1] + k[1], CRY[2] + 8, k[2]; c:fill(c:poly({ { x - 3, y }, { x - 2, y - hh * 0.75 }, { x, y - hh }, { x + 2, y - hh * 0.75 }, { x + 3, y } }), k[3]); c:fill(c:poly({ { x, y - hh }, { x + 2, y - hh * 0.75 }, { x + 3, y }, { x + 1, y } }), k[3] == "#eef8f2" and "#a9d6ea" or "#3f8fb0"); c:px(x - 1, y - hh + 3, "#fff3c8") end
  for _, v in ipairs(SMALL) do crystalc(c, v[1], v[2], 9, "#a9d6ea"); crystalc(c, v[1] + 5, v[2] + 1, 6, "#eef8f2") end
  local seed = ri * 31 + 5; local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
  local placed = 0
  local function free(x, y)
    if not (land:has(x, y) and land:has(x, y + 6)) then return false end
    for _, p in ipairs(PINS) do if math.abs(x - p[1]) < 12 and math.abs(y - p[2]) < 12 then return false end end
    for _, h in ipairs(HOUSES) do if math.abs(x - h[1]) < 14 and math.abs(y - h[2]) < 14 then return false end end
    if x < 50 and y > 90 and y < 118 then return false end
    if math.abs(x - CRY[1]) < 20 and math.abs(y - CRY[2]) < 18 then return false end
    for _, v in ipairs(SMALL) do if math.abs(x - v[1]) < 12 and math.abs(y - v[2]) < 10 then return false end end
    return not roadM:has(x, y) and not roadM:has(x, y - 3) and not river:has(x, y) and not lm:has(x, y)
  end
  for try = 1, 400 do
    if placed >= 40 then break end
    local x, y = 12 + rnd(216), 18 + rnd(100)
    if free(x, y) then
      local L = light[y * 240 + x] or -99
      if L >= 14 and placed % 3 ~= 2 then glyph(c, "dome", x, y, 0.8)
      elseif L >= 6 then crystalc(c, x, y, 7, placed % 2 == 0 and "#a9d6ea" or "#eef8f2")
      else stalag(c, x, y, 9, "#5b6470", "#1f3f3a") end
      placed = placed + 1
    end
  end
  X.layer(c, "detail")
  -- frost sparkles near the crystal
  for i = 1, 30 do local x, y = CRY[1] - 26 + trnd(52), CRY[2] - 18 + trnd(34); if land:has(x, y) and not roadM:has(x, y) and (light[y * 240 + x] or -99) >= 28 then c:px(x, y, "#fff3c8") end end
  for _, p in ipairs(PINS) do local L = light[p[2] * 240 + p[1]] or -99; c:fill(c:rect(p[1] - 5, p[2] - 5, p[1] + 4, p[2] + 4), BAND[band(L)][2]) end
  -- icicle stalactite ceiling and stalagmite floor
  for x = 2, 239, 6 do local hh = 9 + (x * 13) % 8; c:fill(c:poly({ { x - 3, 0 }, { x, hh }, { x + 3, 0 } }), "#1f3f3a"); c:fill(c:poly({ { x - 1, 0 }, { x, hh - 1 }, { x, 0 } }), "#5b6470"); c:px(x, hh - 1, "#a9d6ea") end
  for x = 5, 239, 9 do local hh = 6 + (x * 7) % 6; c:fill(c:poly({ { x - 3, 134 }, { x, 134 - hh }, { x + 3, 134 } }), "#2a1a10") end
  X.save(c, "map-EE-up", "scenes", { w = 480, h = 270, cap = 32 })
end
