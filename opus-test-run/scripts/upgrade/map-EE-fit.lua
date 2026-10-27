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
-- ===== EE fit: frost cavern refit to tools/map_layout.lua (L.regions.EE, 480x270 -> /2 grid) =====
do
  local LAY = dofile(os.getenv("GV_ROOT") .. "tools/map_layout.lua").regions.EE
  local function h2(p) return { p[1] / 2, p[2] / 2 } end
  local TOWN = { LAY.town.x / 2, LAY.town.y / 2 }
  local PIN = { LAY.pin.x / 2, LAY.pin.y / 2, LAY.pin.r / 2 }
  local CLEAR = {}; for _, k in ipairs(LAY.clear) do CLEAR[#CLEAR + 1] = { k[1] / 2, k[2] / 2, k[3] / 2 } end
  for _, s in ipairs(LAY.stops) do CLEAR[#CLEAR + 1] = { s.x / 2, s.y / 2, s.r / 2 + 1 } end
  local function inclear(x, y, pad) for _, k in ipairs(CLEAR) do local dx, dy = x - k[1], y - k[2]; if dx * dx + dy * dy < (k[3] + (pad or 0)) ^ 2 then return true end end return false end
  local ri = 7
  local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2, ol = 1, olx = 1 }
  X.layer(c, "sky"); rockbg(c, 240, 135)
  X.layer(c, "ground")
  -- road / trail centrelines (grid px), extended to the frame edge at exits
  local ROADS, TRAILS = {}, {}
  for _, r in ipairs(LAY.roads) do local t = {}; for _, p in ipairs(r.pts) do t[#t + 1] = h2(p) end; ROADS[#ROADS + 1] = t end
  for _, e in ipairs(LAY.exits) do local x, y = e.x / 2, e.y / 2; local t = ROADS[e.road + 1]
    if e.side == "W" then t[#t + 1] = { 0, y } elseif e.side == "E" then t[#t + 1] = { 239, y } elseif e.side == "N" then t[#t + 1] = { x, 0 } else t[#t + 1] = { x, 134 } end end
  for _, tr in ipairs(LAY.trails) do local t = {}; for _, p in ipairs(tr) do t[#t + 1] = h2(p) end; TRAILS[#TRAILS + 1] = t end
  local roadM, trailM = c:mask(), c:mask()
  for _, t in ipairs(ROADS) do roadM:add(c:line(t, 3)) end
  for _, t in ipairs(TRAILS) do trailM:add(c:line(t, 2)) end
  trailM:cut(roadM)
  local pathM = roadM:copy():add(trailM)
  local land = c:mask(); for x = 0, 239 do land:rect(x, 6 + math.floor(3 * math.sin(x / 13 + ri) + 0.5), x, 128 - math.floor(3 * math.sin(x / 9 + ri) + 0.5)) end
  land:cut(c:rect(0, 0, 3, 134)):cut(c:rect(236, 0, 239, 134))
  land:add(roadM:copy():grow(3))   -- tunnels open to the frame edge at exits
  -- frozen river kept east of the town, lake in the north-west hollow
  local river = c:mask()
  for t = 0, 1, 0.01 do local x, y = math.floor(222 + 6 * math.sin(t * 5 + ri) + 0.5), math.floor(4 + t * 126); river:add(c:ellipse(x, y, 1, 1)) end
  river:clip(land)
  local lk = { 40, 20 }
  -- light sources: town, every stop, crystal clusters
  local CRY = { 30, 120 }
  local SMALL = { { 128, 28, 4 }, { 186, 80, 4 }, { 104, 120, 4 }, { 60, 64, 4 } }
  local SRC = { { TOWN[1], TOWN[2], 48 }, { CRY[1], CRY[2] - 8, 40 }, { lk[1], lk[2], 22 } }
  for _, s in ipairs(LAY.stops) do SRC[#SRC + 1] = { s.x / 2, s.y / 2, s.kind == "exit" and 18 or 26 } end
  for _, v in ipairs(SMALL) do SRC[#SRC + 1] = { v[1], v[2], 22 } end
  local BAND = { { 36, "#eef8f2" }, { 26, "#a9d6ea" }, { 15, "#8b8f96" }, { 5, "#5b6470" }, { -1e9, "#3d2a1c" } }
  local function band(L) for i, b in ipairs(BAND) do if L >= b[1] then return i end end end
  local light = {}
  for y = 0, 134 do for x = 0, 239 do if land:has(x, y) then
    local L = -1e9
    for _, s in ipairs(SRC) do local dx, dy = x - s[1], (y - s[2]) * 1.4; local v = s[3] - math.sqrt(dx * dx + dy * dy); if v > L then L = v end end
    local e = math.min(y - 6, 128 - y, x - 4, 235 - x); if e < 14 and not roadM:has(x, y) then L = L - (14 - e) * 1.2 end
    light[y * 240 + x] = L
    local i = band(L)
    if i < #BAND and L - BAND[i][1] < 2.5 and (x + y) % 2 == 0 then i = i + 1 end
    c:px(x, y, BAND[i][2])
  end end end
  local ts = ri * 17 + 3; local function trnd(n) ts = (ts * 1103515245 + 12345) % 2147483648 return ts % n end
  local DARKER = { ["#eef8f2"] = "#a9d6ea", ["#a9d6ea"] = "#8b8f96", ["#8b8f96"] = "#5b6470", ["#5b6470"] = "#3d2a1c" }
  for i = 1, 160 do local x, y = 6 + trnd(228), 10 + trnd(116); if land:has(x, y) and not inclear(x, y, 1) then local d = DARKER[c:get(x, y)]; if d then c:paint({ "x.x", ".x." }, x, y, { x = d }) end end end
  -- flat pin floor: one tone, packed ice
  local pinM = c:ellipse(PIN[1], PIN[2], PIN[3], PIN[3]); c:fill(pinM, "#eef8f2"); pinM:edge():each(function(x, y) if (x + y) % 2 == 0 then c:px(x, y, "#a9d6ea") end end)
  c:fill(river, "#3f8fb0"); river:each(function(x, y) if (x + y) % 5 == 0 then c:px(x, y, "#eef8f2") elseif (x + y) % 5 == 2 then c:px(x, y, "#a9d6ea") end end)
  local lm = c:ellipse(lk[1], lk[2], 10, 4); lm:clip(land); c:fill(lm, "#a9d6ea"); c:fill(c:ellipse(lk[1], lk[2], 6, 2), "#eef8f2"); c:fill(c:rect(lk[1] - 4, lk[2] - 1, lk[1] + 2, lk[2] - 1), "#3f8fb0"); lm:edge():each(function(x, y) c:px(x, y, "#3f8fb0") end)
  X.layer(c, "objects")
  c:outline(land, { ol = 1, olx = 1 })
  -- paths: dark umber casing, cream/earth fill by light
  local casing = pathM:copy():grow(1):cut(pathM); casing:clip(land:copy():grow(1))
  c:fill(casing, "#4a2c1a")
  local function pathpx(x, y, trail) local L = light[y * 240 + x] or -99; local a, b = "#d8c49a", "#c9a96e"
    if L >= 26 then a, b = "#f2e4c0", "#d8c49a" elseif L < 5 then a, b = "#c9a96e", "#9a6b3f" end
    if trail then a, b = b, a end; c:px(x, y, (x + y) % 6 == 0 and b or a) end
  roadM:each(function(x, y) pathpx(x, y, false) end); trailM:each(function(x, y) pathpx(x, y, true) end)
  local bridge = pathM:copy():clip(river:copy():grow(1)):grow(1)
  c:fill(bridge, "#8a4f2a"); bridge:each(function(x, y) if x % 2 == 0 then c:px(x, y, "#b07a45") end end)
  c:fill(pinM, "#eef8f2")
  -- dome house: cream wall, umber line, gold onion dome, lit window
  local function dome(x, y, s)
    local w = s == 1 and 4 or 3
    c:fill(c:rect(x - w - 1, y - 5 - (s == 1 and 4 or 3), x + w + 1, y + 1), "#2a1a10")
    c:fill(c:rect(x - w, y - 4, x + w, y), "#f2e4c0"); c:fill(c:rect(x + w - 1, y - 4, x + w, y), "#d8c49a")
    local dh = s == 1 and 4 or 3
    c:fill(c:ellipse(x, y - 5, w, dh - 1), "#2a1a10"); c:fill(c:ellipse(x, y - 5, w - 1, dh - 2), "#e8a317"); c:px(x - 1, y - 6, "#f5cf6a"); c:px(x, y - 5 - dh, "#2a1a10"); c:px(x, y - 6 - dh, "#e8a317")
    c:fill(c:rect(x - 1, y - 2, x, y), "#f5cf6a"); c:px(x - 1, y - 2, "#fff3c8")
  end
  local placedB = {}
  local function okB(x, y, pad) if not land:has(x, y) or inclear(x, y, pad) then return false end
    for dx = -5, 5, 5 do for dy = -10, 1, 3 do if pathM:has(x + dx, y + dy) or river:has(x + dx, y + dy) then return false end end end
    for _, b in ipairs(placedB) do if math.abs(b[1] - x) < 10 and math.abs(b[2] - y) < 10 then return false end end return true end
  -- town: ring of domes hugging the pin floor
  for k = 0, 23 do local a = k / 24 * 6.283; local x, y = math.floor(TOWN[1] + math.cos(a) * 17 + 0.5), math.floor(TOWN[2] + math.sin(a) * 13 + 4.5)
    if #placedB < 7 and okB(x, y, 1) then dome(x, y, 1); placedB[#placedB + 1] = { x, y } end end
  local LANT = {}
  -- villages: 1-2 domes + lantern each, just outside their clear ring
  for _, s in ipairs(LAY.stops) do if s.kind == "village" then local sx, sy = s.x / 2, s.y / 2; local n = 0
    for k = 0, 15 do local a = k / 16 * 6.283 + 0.4; local x, y = math.floor(sx + math.cos(a) * 13 + 0.5), math.floor(sy + math.sin(a) * 11 + 4.5)
      if n < 2 and okB(x, y, 0) then dome(x, y, 2); placedB[#placedB + 1] = { x, y }; n = n + 1 end end end end
  -- great crystal cluster + small clusters (light sources)
  local CC = { { -8, 10, "#a9d6ea" }, { -3, 18, "#eef8f2" }, { 2, 22, "#eef8f2" }, { 7, 14, "#a9d6ea" }, { 11, 9, "#3f8fb0" }, { -12, 7, "#3f8fb0" } }
  for _, k in ipairs(CC) do local x, y, hh = CRY[1] + k[1], CRY[2] + 8, k[2]; c:fill(c:poly({ { x - 3, y }, { x - 2, y - hh * 0.75 }, { x, y - hh }, { x + 2, y - hh * 0.75 }, { x + 3, y } }), k[3]); c:fill(c:poly({ { x, y - hh }, { x + 2, y - hh * 0.75 }, { x + 3, y }, { x + 1, y } }), k[3] == "#eef8f2" and "#a9d6ea" or "#3f8fb0"); c:px(x - 1, y - hh + 3, "#fff3c8") end
  for _, v in ipairs(SMALL) do crystalc(c, v[1], v[2], 9, "#a9d6ea"); crystalc(c, v[1] + 5, v[2] + 1, 6, "#eef8f2") end
  -- lanterns along paths, beside each stop
  for _, s in ipairs(LAY.stops) do local sx, sy = s.x / 2, s.y / 2
    for k = 0, 11 do local a = k / 12 * 6.283; local x, y = math.floor(sx + math.cos(a) * (s.r / 2 + 3) + 0.5), math.floor(sy + math.sin(a) * (s.r / 2 + 3) + 0.5)
      if land:has(x, y) and not pathM:has(x, y) and not pathM:has(x, y + 2) and not inclear(x, y, 0) and casing:has(x, y + 1) == false then
        c:fill(c:rect(x, y - 1, x, y + 3), "#4a2c1a"); glowdot(c, x, y - 2); break end end end
  -- scatter: ice crystals / stalagmites only outside clear rings, paths, buildings
  local seed = ri * 31 + 5; local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
  local function free(x, y)
    if not (land:has(x, y) and land:has(x, y + 6)) then return false end
    if inclear(x, y, 4) or inclear(x, y - 8, 4) then return false end
    for _, b in ipairs(placedB) do if math.abs(x - b[1]) < 9 and math.abs(y - b[2]) < 12 then return false end end
    if math.abs(x - CRY[1]) < 20 and math.abs(y - CRY[2]) < 18 then return false end
    for _, v in ipairs(SMALL) do if math.abs(x - v[1]) < 12 and math.abs(y - v[2]) < 10 then return false end end
    for dy = -9, 1, 2 do if pathM:has(x, y + dy) or pathM:has(x - 3, y + dy) or pathM:has(x + 4, y + dy) then return false end end
    return not river:has(x, y) and not lm:copy():grow(2):has(x, y)
  end
  local placed = 0
  for try = 1, 600 do
    if placed >= 28 then break end
    local x, y = 10 + rnd(220), 18 + rnd(104)
    if free(x, y) then local L = light[y * 240 + x] or -99
      if L >= 12 then crystalc(c, x, y, 7, placed % 2 == 0 and "#a9d6ea" or "#eef8f2")
      elseif placed % 2 == 0 then crystalc(c, x, y, 6, "#3f8fb0") else stalag(c, x, y, 7, "#5b6470", "#2a1a10") end
      placed = placed + 1 end
  end
  X.layer(c, "detail")
  for i = 1, 40 do local x, y = 4 + trnd(232), 8 + trnd(120); if land:has(x, y) and not pathM:has(x, y) and not inclear(x, y, 0) and (light[y * 240 + x] or -99) >= 26 then c:px(x, y, "#fff3c8") end end
  -- icicle ceiling and stalagmite floor, gaps where an exit reaches the edge
  local function exitgap(x, top) for _, e in ipairs(LAY.exits) do if (e.side == "N" and top or e.side == "S" and not top) and math.abs(x - e.x / 2) < 9 then return true end end return false end
  for x = 2, 239, 6 do if not exitgap(x, true) then local hh = 8 + (x * 13) % 7; c:fill(c:poly({ { x - 3, 0 }, { x, hh }, { x + 3, 0 } }), "#2a1a10"); c:fill(c:poly({ { x - 1, 0 }, { x, hh - 1 }, { x, 0 } }), "#5b6470"); c:px(x, hh - 1, "#a9d6ea") end end
  for x = 5, 239, 9 do if not exitgap(x, false) then local hh = 6 + (x * 7) % 6; c:fill(c:poly({ { x - 3, 134 }, { x, 134 - hh }, { x + 3, 134 } }), "#2a1a10") end end
  X.save(c, "map-EE-fit", "scenes", { w = 480, h = 270, cap = 32 })
end
