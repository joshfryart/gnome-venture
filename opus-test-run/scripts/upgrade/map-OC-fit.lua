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

-- ===== region OC (fit): underground lake cavern refit to tools/map_layout.lua (L.regions.OC, 480x270 -> /2) =====
local L = dofile(os.getenv("GV_ROOT") .. "tools/map_layout.lua").regions.OC
local function h2(p) return { p[1] / 2, p[2] / 2 } end
local TX, TY = L.town.x / 2, L.town.y / 2
local CLR = {}; for _, k in ipairs(L.clear) do CLR[#CLR + 1] = { k[1] / 2, k[2] / 2, k[3] / 2 } end
for _, k in ipairs(L.stops) do CLR[#CLR + 1] = { k.x / 2, k.y / 2, k.r / 2 + 2 } end
CLR[#CLR + 1] = { L.pin.x / 2, L.pin.y / 2, L.pin.r / 2 + 1 }
local function inclear(x, y, m) for _, k in ipairs(CLR) do local dx, dy = x - k[1], y - k[2]; if dx * dx + dy * dy < (k[3] + (m or 0)) ^ 2 then return true end end return false end
local ri = 14
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2, ol = 1, olx = 1 }
X.layer(c, "sky"); rockbg(c, 240, 135)
X.layer(c, "ground")
-- path polylines (grid space); exits extended to the frame edge in their direction
local ROADS, TRAILS = {}, {}
for _, r in ipairs(L.roads) do local pl = {}; for _, p in ipairs(r.pts) do pl[#pl + 1] = h2(p) end; ROADS[#ROADS + 1] = pl end
for _, e in ipairs(L.exits) do local pl = ROADS[e.road + 1]; local q = pl[#pl]
  if e.side == "W" then pl[#pl + 1] = { -2, q[2] } elseif e.side == "E" then pl[#pl + 1] = { 242, q[2] } elseif e.side == "N" then pl[#pl + 1] = { q[1], -2 } else pl[#pl + 1] = { q[1], 137 } end end
for _, t in ipairs(L.trails) do TRAILS[#TRAILS + 1] = { h2(t[1]), h2(t[2]) } end
local roadM, trailM = c:mask(), c:mask()
for _, pl in ipairs(ROADS) do roadM:add(c:line(pl, 3)) end
for _, pl in ipairs(TRAILS) do trailM:add(c:line(pl, 2)) end
local pathM = roadM:copy(); pathM:add(trailM)
local land = c:mask(); for x = 0, 239 do land:rect(x, 11 + math.floor(3 * math.sin(x / 13 + ri) + 0.5), x, 126 - math.floor(3 * math.sin(x / 9 + ri) + 0.5)) end
land:cut(c:rect(0, 0, 5, 134)):cut(c:rect(234, 0, 239, 134))
land:add(roadM:copy():grow(2))   -- tunnel mouths at the exits
-- light sources: town lanterns (warm), stop lanterns, lake glow, crystal cluster, glow pool, coral
local LAKE = { 52, 36 }
local LS = { { TX, TY, 44, "w" }, { 100, 95, 26, "w" }, { 49, 89, 24, "w" }, { 140, 52, 24, "w" }, { 169, 76, 22, "w" },
  { LAKE[1], LAKE[2], 54, "c" }, { 206, 26, 40, "c" }, { 222, 112, 26, "c" }, { 151, 95, 22, "c" }, { 116, 31, 26, "c" } }
local WARM = { "#2a1a10", "#4a2c1a", "#7a4a1f", "#9a6b3f", "#c9a96e", "#d9a660" }
local COOL = { "#2a1a10", "#1f3f3a", "#2f6a3a", "#5b6470", "#8b8f96", "#c8ecdc" }
local BY = { 0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5 }
local function lit(x, y)
  local bw, bc = 0, 0
  for _, s in ipairs(LS) do
    local dx, dy = (x - s[1]), (y - s[2]) * 1.4; local d = math.sqrt(dx * dx + dy * dy) / s[3]
    local l = math.max(0, 5 - math.floor(d * 5 + (BY[(y % 4) * 4 + (x % 4) + 1] / 16 - 0.5) * 0.9 + 0.5 * math.sin(x / 5 + y / 7) * 0.3))
    if s[4] == "w" then bw = math.max(bw, l) else bc = math.max(bc, l) end
  end
  return bw, bc
end
local function floorcol(x, y) local bw, bc = lit(x, y); local l = math.max(bw, bc, 1); local i = l + 1 > 6 and 6 or l + 1 - (l == 5 and 1 or 0); return (bw >= bc) and WARM[i] or COOL[i] end
land:each(function(x, y) c:px(x, y, floorcol(x, y)) end)
local ts = ri * 17 + 3; local function trnd(n) ts = (ts * 1103515245 + 12345) % 2147483648 return ts % n end
for i = 1, 140 do local x, y = 8 + trnd(224), 14 + trnd(110); if land:has(x, y) and not inclear(x, y, 0) then local bw, bc = lit(x, y); if math.max(bw, bc) >= 3 then local col = bw >= bc and WARM[3] or COOL[3]; c:px(x, y, col); c:px(x + 1, y, col) end end end
-- the underground lake (north-west, off all paths and clear zones)
local lake = c:mask(); lake:add(c:ellipse(LAKE[1], LAKE[2], 26, 10)); lake:add(c:ellipse(36, 42, 12, 6)); lake:add(c:ellipse(70, 40, 12, 6)); lake:clip(land)
lake:cut(pathM:copy():grow(3))
c:fill(lake:copy():grow(1), "#2a1a10"); c:fill(lake, "#1f3f3a")
lake:each(function(x, y) local dx, dy = (x - LAKE[1]) / 26, (y - LAKE[2]) / 10; local d = dx * dx + dy * dy; if d < 0.25 then c:px(x, y, "#a9d6ea") elseif d < 0.6 then c:px(x, y, "#3f8fb0") end end)
lake:edge():each(function(x, y) if (x + y) % 3 == 0 then c:px(x, y, "#c8ecdc") end end)
local gp = c:ellipse(222, 112, 7, 2); c:fill(gp:copy():grow(1), "#2a1a10"); c:fill(gp, "#3f8fb0"); c:fill(c:ellipse(222, 112, 3, 1), "#a9d6ea"); c:px(221, 112, "#eef8f2")
X.layer(c, "objects")
c:outline(land, { ol = 1, olx = 1 })
-- paths: dark casing, then a lit cream/earth surface; small clearings at every stop
local casing = pathM:copy():grow(1); c:fill(casing, "#2a1a10")
local function pathcol(x, y, trail) local bw, bc = lit(x, y); local l = math.max(bw, bc)
  if trail then return l >= 4 and "#d8c49a" or (l >= 2 and "#9a6b3f" or "#7a4a1f") end
  return l >= 4 and "#f2e4c0" or (l >= 3 and "#d8c49a" or (l >= 2 and "#9a6b3f" or "#7a4a1f")) end
trailM:each(function(x, y) c:px(x, y, pathcol(x, y, true)) end)
roadM:each(function(x, y) c:px(x, y, pathcol(x, y, false)) end)
for _, s in ipairs(L.stops) do if s.kind ~= "exit" then local e = c:ellipse(s.x / 2, s.y / 2, 4, 3); c:fill(e:copy():grow(1), "#2a1a10"); e:each(function(x, y) c:px(x, y, pathcol(x, y, s.type == "off")) end) end end
-- town plaza: flat, simple floor under the pin
local plaza = c:ellipse(TX, TY, 11, 9); c:fill(plaza:copy():grow(1), "#7a4a1f"); c:fill(plaza, "#c9a96e")
plaza:edge():each(function(x, y) if (x + y) % 4 == 0 then c:px(x, y, "#9a6b3f") end end)
-- decoration helper: only outside clear circles, stops, pin, paths, lake
local function free(x, y, m) return land:has(x, y) and land:has(x, y + 4) and not inclear(x, y, m or 2) and not pathM:copy():grow(2):has(x, y) and not lake:copy():grow(3):has(x, y) and not (math.abs(x - 222) < 10 and math.abs(y - 112) < 5) end
local PM = pathM:copy():grow(2); local LM = lake:copy():grow(3)
free = function(x, y, m) return land:has(x, y) and land:has(x, y + 4) and not inclear(x, y, m or 2) and not PM:has(x, y) and not PM:has(x, y - 6) and not LM:has(x, y) and not (math.abs(x - 222) < 10 and math.abs(y - 112) < 5) end
-- glowing coral ring round the lake (light source)
for _, k in ipairs({ { 24, 40, "#f08a24" }, { 30, 50, "#e46a9b" }, { 46, 50, "#f6b8cf" }, { 66, 49, "#f08a24" }, { 82, 44, "#e46a9b" }, { 78, 30, "#f6b8cf" }, { 30, 30, "#e46a9b" }, { 60, 25, "#f08a24" }, { 42, 25, "#f6b8cf" } }) do
  if free(k[1], k[2], 1) then coral(c, k[1], k[2], 7, k[3]); c:px(k[1], k[2] - 7, "#fff3c8"); c:px(k[1] - 3, k[2] - 5, "#ffc27a"); c:px(k[1] + 3, k[2] - 5, "#ffc27a") end end
-- glow-crystal cluster (NE), cool light
for _, k in ipairs({ { 200, 28, 12, "#a9d6ea" }, { 206, 26, 16, "#c8ecdc" }, { 212, 29, 11, "#c3b2ea" }, { 196, 31, 7, "#7a5cc0" }, { 216, 32, 7, "#a9d6ea" } }) do crystalc(c, k[1], k[2], k[3], k[4]) end
c:fill(c:rect(194, 32, 220, 33), "#5b6470")
-- small crystal/coral lights beside stops (outside their clear circles)
for _, k in ipairs({ { 160, 100, "#a9d6ea" }, { 124, 22, "#c3b2ea" } }) do if free(k[1], k[2], 1) then crystalc(c, k[1], k[2], 9, k[3]) end end
-- scattered glow life + stalagmites everywhere free
local seed = ri * 31 + 5; local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
local placed = 0
for try = 1, 3000 do if placed >= 95 then break end
  local x, y = 8 + rnd(224), 18 + rnd(104)
  if free(x, y) and not (math.abs(x - 206) < 16 and y < 36) then local k = placed % 5
    if k == 0 then coral(c, x, y, 5 + rnd(3), ({ "#f08a24", "#e46a9b", "#f6b8cf" })[rnd(3) + 1]); c:px(x, y - 5, "#fff3c8")
    elseif k == 1 then c:fill(c:rect(x, y - 6, x, y), "#2f6a3a"); c:px(x + 1, y - 3, "#4f9a45"); c:px(x - 1, y - 5, "#4f9a45"); c:px(x, y - 7, "#c8ecdc")
    elseif k == 2 then shroom(c, x, y, 1, placed % 2 == 0 and "#a9d6ea" or "#c3b2ea")
    elseif k == 3 then stalag(c, x, y, 6 + rnd(5), "#5b6470", "#8b8f96")
    else glowdot(c, x, y) end
    placed = placed + 1 end
end
-- town: houses ringed round the plaza (centred on the town point), lantern windows, lantern posts, market stalls
local HOUSES = { { 2, -16 }, { 13, -9 }, { 14, 4 }, { 4, 12 }, { -12, 11 }, { -9, -17 } }
for _, o in ipairs(HOUSES) do local hx, hy = math.floor(TX + o[1] - 4.5), math.floor(TY + o[2] - 3.5)
  P(c, c:rect(hx, hy, hx + 9, hy + 7), RM.cream, { gloss = false, flat = true }); P(c, c:poly({ { hx - 1, hy }, { hx + 4.5, hy - 5 }, { hx + 10, hy } }), RM.clay, { gloss = false, flat = true })
  c:fill(c:rect(hx + 2, hy + 2, hx + 3, hy + 3), "#f5cf6a"); c:px(hx + 2, hy + 2, "#fff3c8"); c:fill(c:rect(hx + 6, hy + 4, hx + 7, hy + 7), "#8a4f2a") end
for i = 0, 1 do local x = math.floor(TX + 16 + i * 0); local y = math.floor(TY + 14 + i * 0); if i == 1 then x, y = math.floor(TX - 24), math.floor(TY + 18) end
  for dx = 0, 8, 2 do c:fill(c:rect(x + dx, y, x + dx, y + 4), "#dd3a2a"); c:fill(c:rect(x + dx + 1, y, x + dx + 1, y + 4), "#f2e4c0") end; c:fill(c:rect(x, y + 5, x + 9, y + 6), "#8a4f2a"); c:px(x + 4, y - 1, "#f5cf6a") end
local function lantern(x, y) x, y = math.floor(x), math.floor(y); c:fill(c:rect(x, y - 6, x, y), "#4a2c1a"); c:fill(c:rect(x - 1, y - 9, x + 1, y - 7), "#f5cf6a"); c:px(x, y - 8, "#fff3c8") end
for _, q in ipairs({ { TX - 13, TY - 4 }, { TX + 10, TY + 13 }, { TX - 4, TY - 20 } }) do lantern(q[1], q[2]) end
for _, s in ipairs(L.stops) do if s.type == "stop" and s.kind == "village" then lantern(s.x / 2 + 7, s.y / 2 - 3) end end
-- stalactite ceiling lip / floor teeth, leaving the exit tunnels open
local function nearexit(x, y) for _, e in ipairs(L.exits) do if math.abs(x - e.x / 2) < 8 and math.abs(y - e.y / 2) < 12 then return true end end return false end
for x = 2, 238, 5 do if not nearexit(x, 4) then local hh = 6 + (x * 13) % 10; c:fill(c:poly({ { x - 3, 0 }, { x, hh }, { x + 3, 0 } }), "#2a1a10"); c:px(x - 1, 1, "#4a2c1a") end end
for x = 4, 238, 9 do local hh = 3 + (x * 7) % 5; c:fill(c:poly({ { x - 3, 134 }, { x, 134 - hh }, { x + 3, 134 } }), "#2a1a10") end
X.layer(c, "detail")
X.save(c, "map-OC-fit", "scenes", { w = 480, h = 270, cap = 32 })
