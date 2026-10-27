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
local ZONES = { { 40, 100, 34 }, { 95, 70, 38 }, { 150, 95, 40 }, { 205, 75, 36 } }
-- ===== NWE fit: olive moss cavern lit by a beacon tower; markers/roads from tools/map_layout.lua (480x270 -> /2) =====
do
  local LAY = dofile(os.getenv("GV_ROOT") .. "tools/map_layout.lua").regions.NWE
  local function h(v) return math.floor(v / 2 + 0.5) end
  local TOWN = { h(LAY.town.x), h(LAY.town.y) }
  local STOPS, CLEAR = {}, {}
  for _, s in ipairs(LAY.stops) do STOPS[#STOPS + 1] = { h(s.x), h(s.y), s.r / 2, s.kind } end
  for _, q in ipairs(LAY.clear) do CLEAR[#CLEAR + 1] = { q[1] / 2, q[2] / 2, q[3] / 2 } end
  CLEAR[#CLEAR + 1] = { LAY.pin.x / 2, LAY.pin.y / 2, LAY.pin.r / 2 }
  local function hp(pts) local o = {} for _, p in ipairs(pts) do o[#o + 1] = { p[1] / 2, p[2] / 2 } end return o end
  local ROADS, TRAILS = {}, {}
  for _, r in ipairs(LAY.roads) do ROADS[#ROADS + 1] = hp(r.pts) end
  for _, t in ipairs(LAY.trails) do TRAILS[#TRAILS + 1] = hp(t) end
  -- extend each exit road to the frame edge in the exit's direction
  for _, e in ipairs(LAY.exits) do local r = ROADS[e.road + 1]; local p = r[#r]
    if e.side == "W" then r[#r + 1] = { -2, p[2] } elseif e.side == "E" then r[#r + 1] = { 242, p[2] } elseif e.side == "S" then r[#r + 1] = { p[1], 137 } else r[#r + 1] = { p[1], -2 } end end
  local function inclear(x, y, pad) for _, q in ipairs(CLEAR) do local dx, dy = x - q[1], y - q[2]; if dx * dx + dy * dy < (q[3] + pad) ^ 2 then return true end end return false end

  local ri = 5
  local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2, ol = 1, olx = 1 }
  X.layer(c, "sky"); rockbg(c, 240, 135)
  X.layer(c, "ground")
  local land = c:mask(); for x = 0, 239 do land:rect(x, 6 + math.floor(3 * math.sin(x / 13 + ri) + 0.5), x, 128 - math.floor(3 * math.sin(x / 9 + ri) + 0.5)) end
  land:cut(c:rect(0, 0, 3, 134)):cut(c:rect(236, 0, 239, 134))
  local TW = { 128, 35 }                        -- beacon tower base, just NE of the town
  local SRC = { { TW[1], TW[2] - 10, 62 }, { TOWN[1], TOWN[2], 40 } }
  for _, s in ipairs(STOPS) do if s[4] ~= "exit" then SRC[#SRC + 1] = { s[1], s[2] - 3, 22 } end end
  local BAND = { { 44, "#bdd292" }, { 32, "#a4b86a" }, { 21, "#7ab55c" }, { 11, "#4f9a45" }, { 2, "#2f6a3a" }, { -9, "#2f5a2a" }, { -1e9, "#4a2c1a" } }
  local function band(L) for _, b in ipairs(BAND) do if L >= b[1] then return b[2] end end end
  local light = {}
  local BAY = { 0, 2, 3, 1 }
  for y = 0, 134 do for x = 0, 239 do if land:has(x, y) then
    local L = -1e9
    for _, s in ipairs(SRC) do local dx, dy = x - s[1], (y - s[2]) * 1.35; local v = s[3] - math.sqrt(dx * dx + dy * dy); if v > L then L = v end end
    local e = math.min(y - 6, 128 - y, x - 4, 235 - x); if e < 16 then L = L - (16 - e) * 1.2 end
    light[y * 240 + x] = L
    c:px(x, y, band(L + (BAY[(x % 2) + (y % 2) * 2 + 1] - 1.5) * 2.2))
  end end end
  local function lt(x, y) return light[y * 240 + x] or -99 end
  local ts = ri * 17 + 3; local function trnd(n) ts = (ts * 1103515245 + 12345) % 2147483648 return ts % n end
  local DARKER = { ["#bdd292"] = "#a4b86a", ["#a4b86a"] = "#7ab55c", ["#7ab55c"] = "#4f9a45", ["#4f9a45"] = "#2f6a3a", ["#2f6a3a"] = "#2f5a2a", ["#2f5a2a"] = "#4a2c1a" }
  for i = 1, 160 do local x, y = 6 + trnd(228), 10 + trnd(116); if land:has(x, y) and not inclear(x, y, 0) then local d = DARKER[c:get(x, y)]; if d then c:paint({ "x.x", ".x." }, x, y, { x = d }) end end end
  -- underground stream: real water blue, light glints where lit
  local river = c:mask()
  for t = 0, 1, 0.005 do river:add(c:ellipse(math.floor(196 + 18 * math.sin(t * 5 + ri) + 0.5), math.floor(4 + t * 126), 1, 1)) end
  river:clip(land); c:fill(river, "#3f8fb0")
  river:each(function(x, y) if (x + 2 * y) % 7 == 0 and lt(x, y) >= 2 then c:px(x, y, "#a9d6ea") end end)
  -- small still pools, only outside keep-clear zones
  local POOLS = {}
  for _, p in ipairs({ { 40, 30, 6 }, { 30, 92, 6 }, { 200, 120, 6 }, { 60, 100, 5 }, { 225, 25, 5 }, { 100, 120, 5 } }) do
    if not inclear(p[1], p[2], p[3]) then POOLS[#POOLS + 1] = p; local m = c:ellipse(p[1], p[2], p[3], p[3] * 0.45); m:clip(land); c:fill(m, "#3f8fb0"); m:edge():each(function(x, y) c:px(x, y, "#5b6470") end); c:fill(c:rect(p[1] - p[3] + 3, p[2] - 1, p[1] - 1, p[2] - 1), "#a9d6ea") end end
  X.layer(c, "objects")
  c:outline(land, { ol = 1, olx = 1 })
  -- roads (wide) and trails (narrow): dark casing + cream/earth surface, toned by light
  local roadM, trailM = c:mask(), c:mask()
  for _, r in ipairs(ROADS) do roadM:add(c:line(r, 3)) end
  for _, t in ipairs(TRAILS) do trailM:add(c:line(t, 2)) end
  local all = roadM:copy(); all:add(trailM)
  local casing = all:copy():grow(1)
  casing:each(function(x, y) if not all:has(x, y) then c:px(x, y, lt(x, y) >= 11 and "#8a4f2a" or "#2a1a10") end end)
  local function surf(m, dash) m:each(function(x, y) local L = lt(x, y); local a, b = "#d8c49a", "#c9a96e"
    if L >= 32 then a, b = "#f2e4c0", "#d8c49a" elseif L < 2 then a, b = "#c9a96e", "#9a6b3f" end
    c:px(x, y, (x + y) % dash == 0 and b or a) end) end
  surf(trailM, 4); surf(roadM, 6)
  local bridge = all:copy():clip(river:copy():grow(1)):grow(1)
  c:fill(bridge, "#8a4f2a"); bridge:each(function(x, y) if x % 2 == 0 then c:px(x, y, "#b07a45") end end)
  -- town: ring of houses around a flat plaza (pin spot)
  local tx0, ty0 = TOWN[1], TOWN[2]
  c:fill(c:ellipse(tx0, ty0, 6, 5), "#d8c49a"); c:fill(c:ellipse(tx0, ty0, 4, 3), "#f2e4c0")
  local function house(x, y, w) w = w or 7
    P(c, c:rect(x, y, x + w, y + 5), RM.cream, { gloss = false, flat = true }); P(c, c:poly({ { x - 1, y }, { x + w / 2, y - 4 }, { x + w + 1, y } }), RM.clay, { gloss = false, flat = true })
    c:fill(c:rect(x + 2, y + 2, x + 3, y + 3), "#f5cf6a"); c:px(x + 2, y + 2, "#fff3c8") end
  for _, d in ipairs({ { -15, -10 }, { 7, -11 }, { -17, 3 }, { 9, 2 }, { -5, 7 } }) do house(tx0 + d[1], ty0 + d[2]) end
  -- small villages at stops: one or two cottages beside the stop, lantern
  for _, s in ipairs(STOPS) do
    local x, y, k = s[1], s[2], s[4]
    if k == "village" then house(x - 9, y - 9, 5); house(x + 4, y - 8, 5); glowdot(c, x, y - 6)
    elseif k == "haven" then house(x - 3, y - 9, 6); glowdot(c, x + 6, y - 4)
    elseif k == "wonder" then for _, d in ipairs({ -4, 0, 4 }) do c:fill(c:rect(x + d, y - 7 + math.abs(d) // 2, x + d + 1, y - 3), "#8b8f96"); c:px(x + d, y - 7 + math.abs(d) // 2, "#c9c5bc") end
    elseif k == "delve" or k == "lair" then c:fill(c:ellipse(x, y - 4, 4, 3), "#2a1a10"); c:fill(c:rect(x - 4, y - 4, x + 4, y - 3), "#2a1a10"); c:px(x - 5, y - 6, "#8b8f96"); c:px(x + 5, y - 6, "#8b8f96"); if k == "lair" then c:px(x - 1, y - 5, "#dd3a2a"); c:px(x + 1, y - 5, "#dd3a2a") end end
  end
  -- the beacon tower
  local tx, ty = TW[1], TW[2]
  P(c, c:rect(tx - 4, ty - 18, tx + 4, ty), RM.stone, { gloss = false, flat = true })
  for yy = ty - 16, ty - 1, 4 do c:fill(c:rect(tx - 4, yy, tx + 4, yy), "#5b6470") end
  c:fill(c:rect(tx - 1, ty - 4, tx + 1, ty), "#2a1a10")
  c:fill(c:rect(tx - 5, ty - 25, tx + 5, ty - 19), "#5b6470"); c:fill(c:rect(tx - 4, ty - 24, tx + 4, ty - 20), "#f5cf6a"); c:fill(c:rect(tx - 2, ty - 23, tx + 2, ty - 21), "#fff3c8")
  c:fill(c:poly({ { tx - 6, ty - 25 }, { tx, ty - 31 }, { tx + 6, ty - 25 } }), "#7a5cc0")
  for _, d in ipairs({ { -9, -22 }, { 9, -22 }, { -7, -27 }, { 7, -27 } }) do c:px(tx + d[1], ty + d[2], "#fff3c8") end
  -- dressing: stalagmites, crystals, shrooms only outside keep-clear zones
  local seed = ri * 31 + 5; local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
  local function free(x, y)
    if not (land:has(x, y) and land:has(x, y + 6) and land:has(x, y - 10)) then return false end
    if inclear(x, y, 4) or inclear(x, y - 8, 2) then return false end
    if math.abs(x - TW[1]) < 10 and y > TW[2] - 34 and y < TW[2] + 6 then return false end
    if math.abs(x - tx0) < 22 and math.abs(y - ty0) < 16 then return false end
    for _, p in ipairs(POOLS) do if math.abs(x - p[1]) < p[3] + 4 and math.abs(y - p[2]) < 8 then return false end end
    local g = all:copy():grow(2); if g:has(x, y) or g:has(x, y - 4) or g:has(x - 3, y) or g:has(x + 3, y) or river:has(x, y) then return false end
    return true
  end
  local placed = 0
  for try = 1, 1500 do
    if placed >= 45 then break end
    local x, y = 10 + rnd(220), 18 + rnd(104)
    if free(x, y) then
      local L = lt(x, y)
      if placed % 7 == 3 then crystalc(c, x, y, 7, "#a9d6ea"); c:px(x, y - 8, "#eef8f2")
      elseif L >= 21 then if placed % 3 == 0 then shroom(c, x, y, 1, "#c8d77a") else stalag(c, x, y, 8, "#c9c5bc", "#8b8f96") end
      elseif L >= 2 then stalag(c, x, y, 9, "#8b8f96", "#5b6470")
      else stalag(c, x, y, 10, "#5b6470", "#2a1a10") end
      placed = placed + 1
    end
  end
  X.layer(c, "detail")
  -- ceiling stalactites / floor stalagmites, kept off the exit openings
  local function nearExit(x, bottom) for _, e in ipairs(LAY.exits) do if (e.side == "S" and bottom or e.side == "N" and not bottom) and math.abs(x - e.x / 2) < 8 then return true end end return false end
  for x = 2, 239, 6 do if not nearExit(x, false) and math.abs(x - TW[1]) > 9 then local hh = 9 + (x * 13) % 8; c:fill(c:poly({ { x - 3, 0 }, { x, hh }, { x + 3, 0 } }), "#2a1a10"); c:px(x, hh - 2, "#4a2c1a") end end
  for x = 5, 239, 9 do if not nearExit(x, true) then local hh = 6 + (x * 7) % 6; c:fill(c:poly({ { x - 3, 134 }, { x, 134 - hh }, { x + 3, 134 } }), "#2a1a10") end end
  X.save(c, "map-NWE-fit", "scenes", { w = 480, h = 270, cap = 32 })
end
