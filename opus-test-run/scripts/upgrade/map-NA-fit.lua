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
-- fixed layout (480x270 frame -> 240x135 grid, /2)
local LAY = dofile(os.getenv("GV_ROOT") .. "tools/map_layout.lua").regions.NA
local function H(v) return math.floor(v / 2 + 0.5) end
local TOWN = { H(LAY.town.x), H(LAY.town.y) }
local PIN = { H(LAY.pin.x), H(LAY.pin.y), LAY.pin.r / 2 }
local CLR = {}; for _, k in ipairs(LAY.clear) do CLR[#CLR + 1] = { k[1] / 2, k[2] / 2, k[3] / 2 } end
for _, s in ipairs(LAY.stops) do CLR[#CLR + 1] = { s.x / 2, s.y / 2, s.r / 2 + 2 } end
CLR[#CLR + 1] = { PIN[1], PIN[2], PIN[3] + 2 }
local function free(x, y, m) m = m or 3; for _, k in ipairs(CLR) do local dx, dy = x - k[1], y - k[2]; if dx * dx + dy * dy < (k[3] + m) ^ 2 then return false end end return true end
local function hpts(pts) local o = {}; for _, p in ipairs(pts) do o[#o + 1] = { H(p[1]), H(p[2]) } end return o end
local ZONES = { { TOWN[1], TOWN[2], 34 }, { 60, 95, 38 }, { 150, 95, 40 }, { 190, 40, 36 } }
local ri, r = 1, REG[1]
do
  local code = r[1]; local tint = { "#a4b86a", "#7ab55c", "#4f9a45", "#2f6a3a" }
  local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2, ol = 1, olx = 1 }
  X.layer(c, "sky"); rockbg(c, 240, 135)
  X.layer(c, "ground")
  local land = c:mask(); for x = 0, 239 do land:rect(x, 12 + math.floor(3 * math.sin(x / 13 + ri) + 0.5), x, 126 - math.floor(3 * math.sin(x / 9 + ri) + 0.5)) end
  land:cut(c:rect(0, 0, 3, 134)):cut(c:rect(236, 0, 239, 134))
  c:fill(land, tint[1])
  local zm = {}
  for zi = 4, 1, -1 do
    local z = ZONES[zi]; local m = c:mask()
    m:add(c:ellipse(z[1], z[2], z[3], 30)); m:add(c:ellipse(z[1] + 8, z[2] - 14, z[3] * 0.6, 20)); m:clip(land)
    c:fill(m, tint[zi]); zm[zi] = m
  end
  local G0 = { ["#a4b86a"] = 1, ["#7ab55c"] = 1, ["#4f9a45"] = 1, ["#2f6a3a"] = 1 }
  local ts = ri * 17 + 3; local function trnd(n) ts = (ts * 1103515245 + 12345) % 2147483648 return ts % n end
  for i = 1, 110 do local x, y = 6 + trnd(228), 14 + trnd(110); if land:has(x, y) then c:paint({ "x.x", ".x." }, x, y, { x = tint[math.min(4, (zm[2] and zm[2]:has(x, y)) and 3 or ((zm[3] and zm[3]:has(x, y)) and 4 or 2))] }) end end
  for zi = 2, 4 do zm[zi]:edge():each(function(x, y) if (x + y) % 4 < 2 and land:has(x, y) then c:px(x, y, "#f2e4c0") end end) end
  -- underground stream: runs between the Mistmoor road and the southern stops
  local river = c:mask()
  for t = 0, 1, 0.01 do river:add(c:ellipse(math.floor(178 + 22 * math.sin(t * 3.4 + 1.3) + 0.5), math.floor(4 + t * 126), 1, 1)) end
  river:clip(land); c:fill(river, "#3f8fb0")
  river:each(function(x, y) if (x + y) % 5 == 0 then c:px(x, y, "#a9d6ea") end end)
  local LAKE = { 214, 112 }
  local lm = c:ellipse(LAKE[1], LAKE[2], 11, 5); lm:clip(land); c:fill(lm, "#3f8fb0"); lm:edge():each(function(x, y) c:px(x, y, "#a9d6ea") end); c:fill(c:rect(LAKE[1] - 4, LAKE[2] - 1, LAKE[1] + 2, LAKE[2] - 1), "#a9d6ea")
  X.layer(c, "objects")
  c:outline(land, { ol = 1, olx = 1 })
  -- paths from the layout: roads 3px, trails 2px, dark casing; exits run on to the frame edge
  local roadM, trailM = c:mask(), c:mask()
  for _, rd in ipairs(LAY.roads) do local p = hpts(rd.pts); roadM:add(c:line(p, 3)) end
  for _, ex in ipairs(LAY.exits) do local x, y = H(ex.x), H(ex.y)
    if ex.side == "S" then roadM:add(c:line({ { x, y }, { x, 134 } }, 3)) elseif ex.side == "N" then roadM:add(c:line({ { x, y }, { x, 0 } }, 3))
    elseif ex.side == "E" then roadM:add(c:line({ { x, y }, { 239, y } }, 3)) else roadM:add(c:line({ { x, y }, { 0, y } }, 3)) end end
  for _, tr in ipairs(LAY.trails) do trailM:add(c:line(hpts(tr), 2)) end
  local allP = roadM:copy():add(trailM)
  c:fill(allP:copy():grow(1), "#5e2f1e")
  c:fill(trailM, "#c9a96e"); c:fill(roadM, "#d9a660")
  roadM:each(function(x, y) if (x + y) % 6 == 0 then c:px(x, y, "#f2e4c0") end end)
  trailM:each(function(x, y) if (x * 3 + y) % 7 == 0 then c:px(x, y, "#9a6b3f") end end)
  local bridge = allP:copy():clip(river:copy():add(lm):grow(1)):grow(1)
  c:fill(bridge, "#b07a45"); bridge:each(function(x, y) if x % 2 == 0 then c:px(x, y, "#8a4f2a") end end)
  -- exit mouths: tunnel arches at the frame edge
  for _, ex in ipairs(LAY.exits) do local x, y = H(ex.x), H(ex.y)
    if ex.side == "S" then c:fill(c:rect(x - 5, 129, x - 3, 134), "#5b6470"); c:fill(c:rect(x + 3, 129, x + 5, 134), "#5b6470"); c:fill(c:rect(x - 5, 128, x + 5, 128), "#8b8f96")
    elseif ex.side == "E" then c:fill(c:rect(234, y - 5, 239, y - 3), "#5b6470"); c:fill(c:rect(234, y + 3, 239, y + 5), "#5b6470") end end
  -- market village: mushroom-cap houses in a ring centred on the town point (inner pin floor left flat)
  local HOUSES = {}
  for k = 0, 6 do local a = -2.6 + k * 0.92; local rx = PIN[3] + 7; HOUSES[#HOUSES + 1] = { math.floor(TOWN[1] + math.cos(a) * rx * 1.25 - 4.5 + 0.5), math.floor(TOWN[2] + math.sin(a) * rx - 3.5 + 0.5) } end
  local function onpath(x0, y0, x1, y1) for y = y0, y1 do for x = x0, x1 do if allP:has(x, y) then return true end end end return false end
  local built = {}
  for _, h in ipairs(HOUSES) do if not onpath(h[1], h[2] - 3, h[1] + 9, h[2] + 7) then built[#built + 1] = h
    P(c, c:rect(h[1] + 1, h[2], h[1] + 8, h[2] + 7), RM.cream, { gloss = false, flat = true }); P(c, c:ellipse(h[1] + 4.5, h[2], 6, 3.5):cut(c:rect(h[1] - 3, h[2] + 1, h[1] + 12, h[2] + 5)), RM.red, { gloss = false, flat = true })
    c:px(h[1] + 2, h[2] - 2, "#fff3c8"); c:px(h[1] + 6, h[2] - 1, "#fff3c8"); c:fill(c:rect(h[1] + 3, h[2] + 3, h[1] + 4, h[2] + 4), "#f5cf6a") end end
  -- lantern posts: by the market and beside a few road stops
  local LANT = { { TOWN[1] - 15, TOWN[2] + 6 }, { TOWN[1] + 16, TOWN[2] - 6 } }
  for _, s in ipairs(LAY.stops) do if s.kind == "village" and s.road then local x, y = H(s.x) + 10, H(s.y) - 2; if free(x, y, 0) and not allP:has(x, y) and land:has(x, y) then LANT[#LANT + 1] = { x, y } end end end
  local function lantern(l) c:fill(c:rect(l[1], l[2] - 4, l[1], l[2]), "#8a4f2a"); c:fill(c:rect(l[1] - 1, l[2] - 6, l[1] + 1, l[2] - 5), "#f5cf6a"); c:px(l[1], l[2] - 6, "#fff3c8") end
  -- cavern dressing, only outside clear circles / stops / pin and off the paths
  local seed = ri * 31 + 5; local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
  local LIGHT = { 96, 22 }; local LAVA = { 120, 116 }
  local function okspot(x, y, m) if not (land:has(x, y) and land:has(x, y + 4) and land:has(x, y - 10) and free(x, y, m)) then return false end
    for yy = y - 10, y + 2 do for xx = x - 4, x + 4 do if allP:has(xx, yy) or river:has(xx, yy) or lm:has(xx, yy) then return false end end end
    for _, h in ipairs(built) do if math.abs(x - h[1] - 4) < 9 and math.abs(y - h[2]) < 10 then return false end end
    if math.abs(x - LIGHT[1]) < 14 and math.abs(y - LIGHT[2]) < 12 then return false end
    if math.abs(x - LAVA[1]) < 12 and math.abs(y - LAVA[2]) < 8 then return false end
    return true end
  local placed = 0
  for try = 1, 900 do
    if placed >= 30 then break end
    local x, y = 8 + rnd(224), 20 + rnd(100)
    if okspot(x, y, 3) then
      local k = placed % 4
      if k == 0 then shroom(c, x, y, 1, "#e46a9b") elseif k == 1 then shroom(c, x, y, 1, "#dd3a2a")
      elseif k == 2 then crystalc(c, x, y, 7, (x < 120) and "#a9d6ea" or "#c3b2ea") else stalag(c, x, y, 8, "#8b8f96", "#5b6470") end
      placed = placed + 1
    end
  end
  for k = 1, 7 do local x, y = 20 + trnd(200), 20 + trnd(95)
    for st = 1, 26 do x = x + (trnd(3) - 1); y = y + (trnd(3) - 1) * 0.5 + ((st % 3 == 0) and 1 or 0); local ix, iy = math.floor(x), math.floor(y)
      if land:has(ix, iy) and not allP:has(ix, iy) and not river:has(ix, iy) and G0[c:get(ix, iy)] and st % 2 == 0 and free(ix, iy, 0) then c:px(ix, iy, "#f2e4c0") end end end
  local sg = 0; for i = 1, 200 do if sg >= 12 then break end local x, y = 8 + trnd(224), 26 + trnd(96); if okspot(x, y, 2) and G0[c:get(x, y)] then stalag(c, x, y, 6 + trnd(6), "#8b8f96", "#5b6470"); sg = sg + 1 end end
  -- lava seep (warm light source south-west)
  lava(c, LAVA[1], LAVA[2], 7)
  -- stepped, dithered light bands
  local RAMPS = { { "#3d2a1c", "#2f5a2a", "#2f6a3a", "#4f9a45", "#7ab55c", "#a4b86a", "#c8d77a" },
    { "#3d2a1c", "#5e2f1e", "#9a6b3f", "#c9a96e", "#d9a660", "#f2e4c0" }, { "#3d2a1c", "#5b6470", "#3f8fb0", "#a9d6ea" },
    { "#4a2c1a", "#9a6b3f", "#d8c49a", "#f2e4c0" }, { "#3d2a1c", "#5b6470", "#8b8f96" }, { "#5e2f1e", "#8a4f2a", "#b07a45" } }
  local RI = {}; for ri2, rp in ipairs(RAMPS) do for i, col in ipairs(rp) do if not RI[col] then RI[col] = { ri2, i } end end end
  RI["#f2e4c0"] = { 4, 4 }; RI["#3d2a1c"] = nil
  local SRC = { { LIGHT[1], LIGHT[2], 120, 1.0 }, { TOWN[1], TOWN[2], 58, 0.95 }, { LAVA[1], LAVA[2], 44, 0.75 } }
  for i = 3, #LANT do SRC[#SRC + 1] = { LANT[i][1], LANT[i][2] - 4, 34, 0.7 } end
  local BY = { 0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5 }
  X.layer(c, "detail")
  local cur = {}; for y = 0, 134 do for x = 0, 239 do cur[y * 240 + x] = c:get(x, y) end end
  for y = 0, 134 do for x = 0, 239 do if land:has(x, y) or allP:has(x, y) then
    local L = 0
    for _, s in ipairs(SRC) do local dx, dy = x - s[1], (y - s[2]) * 1.5; local v = (1 - math.sqrt(dx * dx + dy * dy) / s[3]) * s[4]; if v > L then L = v end end
    local band = math.floor(L * 5 + (BY[(y % 4) * 4 + x % 4 + 1] / 16 - 0.5) * 0.9)
    if band < 0 then band = 0 elseif band > 4 then band = 4 end
    if allP:has(x, y) and band < 1 then band = 1 end   -- paths stay readable to the edge
    local col = cur[y * 240 + x]; local e = RI[col]
    if e then local rp = RAMPS[e[1]]; local shift = band - 3; if e[1] == 1 then shift = band - 2 end
      local idx = math.max(1, math.min(#rp, e[2] + shift)); if shift < 0 then idx = math.max(1, math.min(e[2], idx)) end
      if e[1] == 3 and idx < 2 then idx = 2 end
      if e[1] == 1 and idx == 1 and band > 0 then idx = 2 end
      if e[1] == 1 and idx == 1 and (x + y) % 2 == 0 and L > 0.05 then idx = 2 end
      if e[1] == 2 and allP:has(x, y) and idx < 3 then idx = 3 end
      if rp[idx] ~= col then c:px(x, y, rp[idx]) end end
  end end end
  -- self-lit things after shading
  for _, l in ipairs(LANT) do lantern(l) end
  lava(c, LAVA[1], LAVA[2], 7)
  for x = 9, 232, 13 do local hh = 8 + (x * 7) % 14; c:fill(c:rect(x, 6, x, 6 + hh), "#5e2f1e"); c:px(x + 1, 6 + hh // 2, "#5e2f1e"); c:px(x - 1, 6 + hh - 3, "#8a4f2a") end
  local gl = 0; for i = 1, 200 do if gl >= 14 then break end local x, y = 10 + trnd(220), 22 + trnd(100)
    if okspot(x, y, 2) then gl = gl + 1; c:fill(c:rect(x, y - 2, x, y), "#d8c49a"); c:fill(c:rect(x - 1, y - 3, x + 1, y - 3), "#a9d6ea"); c:px(x, y - 4, "#eef8f2")
      c:px(x - 2, y, "#3f8fb0"); c:px(x + 2, y - 1, "#3f8fb0"); c:px(x - 1, y - 5, "#3f8fb0") end end
  local LX, LY = LIGHT[1], LIGHT[2]
  c:fill(c:ellipse(LX, LY + 4, 9, 3), "#4f9a45"); c:fill(c:ellipse(LX, LY + 3, 7, 2), "#7ab55c")
  crystalc(c, LX - 5, LY + 4, 9, "#a9d6ea"); crystalc(c, LX + 4, LY + 4, 8, "#a9d6ea"); crystalc(c, LX, LY + 3, 14, "#eef8f2"); c:fill(c:rect(LX, LY - 9, LX, LY), "#fff3c8")
  for _, d in ipairs({ { -10, -6 }, { 11, -4 }, { -3, -14 }, { 7, -12 }, { -12, 2 }, { 13, 3 } }) do c:px(LX + d[1], LY + d[2], "#fff3c8") end
  for x = 2, 238, 5 do local hh = 6 + (x * 13) % 8; c:fill(c:poly({ { x - 3, 0 }, { x, hh + 8 }, { x + 3, 0 } }), (x % 2 == 0) and "#4a2c1a" or "#3d2a1c"); c:px(x, hh + 6, "#5e2f1e") end
  -- re-assert the exit road on the east edge over the stalactite fringe
  -- pin spot: flat lit moss floor, paths crossing it redrawn
  local pm = c:ellipse(PIN[1], PIN[2], PIN[3], PIN[3])
  c:fill(pm, "#7ab55c"); local pp = allP:copy():clip(pm); c:fill(pp, "#f2e4c0")
  X.save(c, "map-" .. code .. "-fit", "scenes", { w = 480, h = 270, cap = 32 })
end
