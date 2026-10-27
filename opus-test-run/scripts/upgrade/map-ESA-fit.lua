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
-- ===== ESA fit: sandstone cavern lit by a copper-green crystal seam and forge lanterns, fitted to tools/map_layout.lua =====
do
  local LY = dofile(os.getenv("GV_ROOT") .. "tools/map_layout.lua").regions.ESA
  local function g(v) return math.floor(v / 2 + 0.5) end
  local TX, TY = g(LY.town.x), g(LY.town.y)
  local PX, PY, PR = g(LY.pin.x), g(LY.pin.y), LY.pin.r / 2
  local CLR = {}; for _, k in ipairs(LY.clear) do CLR[#CLR + 1] = { k[1] / 2, k[2] / 2, k[3] / 2 } end
  local STOPS = {}; for _, s in ipairs(LY.stops) do STOPS[#STOPS + 1] = { g(s.x), g(s.y), s.r / 2, s.kind } end
  local function inclear(x, y, pad) for _, k in ipairs(CLR) do local dx, dy = x - k[1], y - k[2]; if dx * dx + dy * dy < (k[3] + pad) ^ 2 then return true end end; return false end
  local ri = 10
  local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2, ol = 1, olx = 1 }
  X.layer(c, "sky"); rockbg(c, 240, 135)
  X.layer(c, "ground")
  local land = c:mask(); for x = 0, 239 do land:rect(x, 6 + math.floor(3 * math.sin(x / 13 + ri) + 0.5), x, 128 - math.floor(3 * math.sin(x / 9 + ri) + 0.5)) end
  land:cut(c:rect(0, 0, 3, 134)):cut(c:rect(236, 0, 239, 134))
  -- exit mouths: open the cavern up to the frame edge where the roads leave
  for _, e in ipairs(LY.exits) do land:add(c:ellipse(g(e.x), 4, 9, 7)) end
  -- crystal seam: thick jagged vein through the open middle-north, kept off stops/clear zones
  local seam = c:mask(); local SP = {}
  for t = 0, 1, 0.006 do
    local x, y = math.floor(8 + t * 222 + 0.5), math.floor(36 + 9 * math.sin(t * 9 + ri) - t * 6 + 0.5)
    if not inclear(x, y, 4) then seam:add(c:ellipse(x, y, 1, 1.5)); if math.floor(t * 1000) % 30 < 2 then seam:add(c:ellipse(x, y - 2, 1, 2)) end; SP[#SP + 1] = { x, y } end
  end
  seam:clip(land)
  -- forge lanterns: big one at the town, small ones at every village/stop
  local FORGE = { { TX, TY, 46 } }
  for _, s in ipairs(STOPS) do if s[4] ~= "exit" then FORGE[#FORGE + 1] = { s[1], s[2], s[4] == "village" and 26 or 20 } else FORGE[#FORGE + 1] = { s[1], s[2] + 4, 18 } end end
  local BAND = { { 36, "#f2e4c0" }, { 26, "#d9a660" }, { 17, "#b07a45" }, { 8, "#8a4f2a" }, { -2, "#4a2c1a" }, { -1e9, "#3d2a1c" } }
  local light = {}
  for y = 0, 134 do for x = 0, 239 do if land:has(x, y) then
    local L = -1e9
    for _, s in ipairs(FORGE) do local dx, dy = x - s[1], (y - s[2]) * 1.4; local v = s[3] - math.sqrt(dx * dx + dy * dy); if v > L then L = v end end
    for k = 1, #SP, 3 do local p = SP[k]; local dx, dy = x - p[1], (y - p[2]) * 1.3; if math.abs(dx) < 40 and math.abs(dy) < 40 then local v = 34 - math.sqrt(dx * dx + dy * dy); if v > L then L = v end end end
    local e = math.min(y - 6, 128 - y, x - 4, 235 - x); if e < 16 then L = L - (16 - e) * 1.3 end
    light[y * 240 + x] = L
    for bi, b in ipairs(BAND) do if L >= b[1] then
      local col = b[2]; if bi < #BAND and L < b[1] + 2.5 and (x + y) % 2 == 0 then col = BAND[bi + 1][2] end
      c:px(x, y, col); break end end
  end end end
  local ts = ri * 17 + 3; local function trnd(n) ts = (ts * 1103515245 + 12345) % 2147483648 return ts % n end
  local DARKER = { ["#f2e4c0"] = "#d9a660", ["#d9a660"] = "#b07a45", ["#b07a45"] = "#8a4f2a", ["#8a4f2a"] = "#4a2c1a", ["#4a2c1a"] = "#3d2a1c", ["#3d2a1c"] = "#2a1a10" }
  for i = 1, 220 do local x, y = 6 + trnd(228), 10 + trnd(116); if land:has(x, y) and not inclear(x, y, 1) then local d = DARKER[c:get(x, y)]; if d then c:paint({ "x.x", ".x." }, x, y, { x = d }) end end end
  -- copper-green glow dither around the seam
  for y = 0, 134 do for x = 0, 239 do local L = light[y * 240 + x]; if L and L >= 18 and (x * 3 + y) % 5 == 0 and not inclear(x, y, 0) then local near = false; for k = 1, #SP, 3 do local p = SP[k]; if math.abs(x - p[1]) < 9 and math.abs(y - p[2]) < 6 then near = true break end end; if near then c:px(x, y, "#a4b86a") end end end end
  -- the seam: bright green crystal with dark core and pale facets
  local seamE = seam:copy():grow(1):clip(land); seamE:each(function(x, y) if not seam:has(x, y) and (x + y) % 2 == 0 then c:px(x, y, "#2f6a3a") end end)
  c:fill(seam, "#4f9a45"); seam:each(function(x, y) local m = (x * 2 + y) % 5; if m == 0 then c:px(x, y, "#c8ecdc") elseif m == 2 or m == 3 then c:px(x, y, "#7ab55c") end end)
  X.layer(c, "objects")
  c:outline(land, { ol = 1, olx = 1 })
  -- paths from the layout: roads (width 3) and trails (width 2), warm cream/earth with dark casing
  local roadM, trailM = c:mask(), c:mask()
  for _, r in ipairs(LY.roads) do local pts = {}; for _, p in ipairs(r.pts) do pts[#pts + 1] = { g(p[1]), g(p[2]) } end
    local last = pts[#pts]; if last[2] <= 10 then pts[#pts + 1] = { last[1], -2 } end
    roadM:add(c:line(pts, 3)) end
  for _, t in ipairs(LY.trails) do local pts = {}; for _, p in ipairs(t) do pts[#pts + 1] = { g(p[1]), g(p[2]) } end; trailM:add(c:line(pts, 2)) end
  local pathM = roadM:copy():add(trailM)
  local casing = pathM:copy():grow(1)
  casing:each(function(x, y) if not pathM:has(x, y) then c:px(x, y, "#4a2c1a") end end)
  pathM:each(function(x, y) local L = light[y * 240 + x] or 0; local a, b = "#d9a660", "#b07a45"
    if roadM:has(x, y) then if L >= 26 then a, b = "#f2e4c0", "#d8c49a" elseif L >= 8 then a, b = "#d8c49a", "#c9a96e" end
    else if L >= 20 then a, b = "#d8c49a", "#c9a96e" elseif L < 4 then a, b = "#b07a45", "#9a6b3f" end end
    c:px(x, y, (x * 2 + y) % 7 == 0 and b or a) end)
  local bridge = roadM:copy():clip(seam:copy():grow(1)):grow(1)
  c:fill(bridge, "#8a4f2a"); bridge:each(function(x, y) if x % 2 == 0 then c:px(x, y, "#b07a45") end end)
  -- flat floor at stops and the pin (simple tamped earth, no dressing)
  for _, s in ipairs(STOPS) do if s[4] ~= "exit" then local m = c:ellipse(s[1], s[2], s[3] * 0.7, s[3] * 0.55):clip(land); m:each(function(x, y) if not pathM:has(x, y) then c:px(x, y, (light[y * 240 + x] or 0) >= 26 and "#d8c49a" or "#c9a96e") end end) end end
  local pm = c:ellipse(PX, PY, PR, PR * 0.8); c:fill(pm:copy():grow(1), "#8a4f2a"); c:fill(pm, "#d8c49a")
  -- town: lantern-lit houses ringed around the plaza, centred on the town point
  local HOUSES = {}
  for i = 0, 7 do local a = i / 8 * 2 * math.pi + 0.3; local hx, hy = TX + math.cos(a) * (PR + 7) - 4.5, TY + math.sin(a) * (PR * 0.8 + 6) - 3
    hx, hy = math.floor(hx + 0.5), math.floor(hy + 0.5); if hy + 7 < 129 then HOUSES[#HOUSES + 1] = { hx, hy } end end
  table.sort(HOUSES, function(a, b) return a[2] < b[2] end)
  for _, h in ipairs(HOUSES) do P(c, c:rect(h[1], h[2], h[1] + 9, h[2] + 7), RM.cream, { gloss = false, flat = true }); P(c, c:poly({ { h[1] - 1, h[2] }, { h[1] + 4.5, h[2] - 5 }, { h[1] + 10, h[2] } }), RM.wood, { gloss = false, flat = true }); c:fill(c:rect(h[1] + 3, h[2] + 3, h[1] + 5, h[2] + 5), "#f5cf6a"); c:px(h[1] + 4, h[2] + 4, "#fff3c8") end
  -- forge lanterns at stops (small post + glow), set beside the flat spot
  for _, s in ipairs(STOPS) do if s[4] ~= "exit" then local lx, ly = math.floor(s[1] + s[3] + 1), math.floor(s[2] - 1)
    if land:has(lx, ly) and not pathM:has(lx, ly) then c:fill(c:rect(lx, ly - 3, lx, ly + 1), "#2a1a10"); glowdot(c, lx, ly - 4) end end end
  local seed = ri * 31 + 5; local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
  local casG = casing:copy():grow(2)
  local placedPts = {}
  local function free(x, y)
    if not (land:has(x, y) and land:has(x, y - 10)) then return false end
    for dy = 0, 10 do for dx = -4, 4, 4 do if inclear(x + dx, y - dy, 2) or casG:has(x + dx, y - dy) or seam:has(x + dx, y - dy) then return false end end end
    for _, h in ipairs(HOUSES) do if math.abs(x - h[1] - 4) < 12 and math.abs(y - h[2]) < 12 then return false end end
    for _, p in ipairs(placedPts) do if math.abs(x - p[1]) < 7 and math.abs(y - p[2]) < 6 then return false end end
    return true
  end
  for try = 1, 4000 do
    if #placedPts >= 80 then break end
    local x, y = 8 + rnd(224), 16 + rnd(110)
    if free(x, y) then
      local L = light[y * 240 + x] or -99
      if L >= 20 then if #placedPts % 2 == 0 then crystalc(c, x, y, 8, "#7ab55c") else stalag(c, x, y, 10, "#d9a660", "#9a6b3f") end
      elseif L >= 8 then if #placedPts % 4 == 0 then pool(c, x, y - 1, 4) else stalag(c, x, y, 11, "#c9a96e", "#8a4f2a") end
      elseif L >= 0 then if #placedPts % 3 == 0 then crystalc(c, x, y, 6, "#4f9a45") else stalag(c, x, y, 9, "#9a6b3f", "#4a2c1a") end
      else if #placedPts % 3 == 0 then feat(c, { "root" }, x, y) else stalag(c, x, y, 8, "#8a4f2a", "#2a1a10") end end
      placedPts[#placedPts + 1] = { x, y }
    end
  end
  X.layer(c, "detail")
  for i = 1, 40 do local p = SP[1 + trnd(#SP)]; local x, y = p[1] + trnd(9) - 4, p[2] - 3 - trnd(5); if land:has(x, y) and not pathM:has(x, y) and not inclear(x, y, 0) then c:px(x, y, "#c8ecdc") end end
  -- ceiling stalactites + hanging roots (gaps left at exit mouths), floor-edge stalagmites
  local function nearExit(x) for _, e in ipairs(LY.exits) do if math.abs(x - g(e.x)) < 11 then return true end end return false end
  for x = 2, 239, 6 do if not nearExit(x) then local hh = 9 + (x * 13) % 8; c:fill(c:poly({ { x - 3, 0 }, { x, hh }, { x + 3, 0 } }), "#2a1a10"); c:px(x, hh - 2, "#4a2c1a") end end
  for x = 5, 239, 23 do if not nearExit(x) then local hh = 12 + (x * 7) % 9; c:fill(c:rect(x, 0, x, hh), "#5e2f1e"); c:px(x + 1, hh - 3, "#5e2f1e"); c:px(x - 1, hh - 6, "#5e2f1e") end end
  for x = 5, 239, 9 do local hh = 6 + (x * 7) % 6; c:fill(c:poly({ { x - 3, 134 }, { x, 134 - hh }, { x + 3, 134 } }), "#2a1a10"); c:px(x, 136 - hh, "#4a2c1a") end
  -- re-assert exit paths over the ceiling teeth
  roadM:each(function(x, y) if y < 14 then c:px(x, y, "#d8c49a") end end)
  X.save(c, "map-ESA-fit", "scenes", { w = 480, h = 270, cap = 32 })
end
