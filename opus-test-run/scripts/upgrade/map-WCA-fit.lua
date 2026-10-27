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
local PINS_OLD = { { 40, 100 }, { 70, 70 }, { 95, 100 }, { 120, 65 }, { 140, 98 }, { 165, 70 }, { 185, 100 }, { 205, 65 }, { 212, 100 } }   -- grid px (20x20 exported = 10x10 flat)
local ZONES = { { 40, 100, 34 }, { 95, 70, 38 }, { 150, 95, 40 }, { 205, 75, 36 } }
-- ===== WCA fit: underground forest cavern refitted to tools/map_layout.lua (coords /2) =====
do
  local LY = dofile(os.getenv("GV_ROOT") .. "tools/map_layout.lua").regions.WCA
  local function h(v) return math.floor(v / 2 + 0.5) end
  local ri = 9
  local TOWN = { h(LY.town.x), h(LY.town.y) }
  local PIN = { h(LY.pin.x), h(LY.pin.y), LY.pin.r / 2 }
  local STOPS = {}; for _, s in ipairs(LY.stops) do STOPS[#STOPS + 1] = { h(s.x), h(s.y), s.r / 2, s.kind } end
  local CLEAR = {}; for _, k in ipairs(LY.clear) do CLEAR[#CLEAR + 1] = { k[1] / 2, k[2] / 2, k[3] / 2 } end
  for _, s in ipairs(STOPS) do CLEAR[#CLEAR + 1] = { s[1], s[2], s[3] + 2 } end
  CLEAR[#CLEAR + 1] = { PIN[1], PIN[2], PIN[3] + 2 }
  local function inclear(x, y, pad) for _, k in ipairs(CLEAR) do local dx, dy = x - k[1], y - k[2]; if dx * dx + dy * dy < (k[3] + pad) ^ 2 then return true end end return false end
  local function ext(pts, side)   -- extend an exit polyline to the frame edge
    local q = {}; for _, p in ipairs(pts) do q[#q + 1] = { p[1] / 2, p[2] / 2 } end
    local e = q[#q]; if side == "N" then q[#q + 1] = { e[1], -2 } elseif side == "S" then q[#q + 1] = { e[1], 137 } elseif side == "E" then q[#q + 1] = { 242, e[2] } else q[#q + 1] = { -2, e[2] } end
    return q
  end
  local ROADS = {}; for i, r in ipairs(LY.roads) do local side = (LY.exits[i] and LY.exits[i].side) or "N"; ROADS[#ROADS + 1] = ext(r.pts, side) end
  local TRAILS = {}; for _, t in ipairs(LY.trails) do local q = {}; for _, p in ipairs(t) do q[#q + 1] = { p[1] / 2, p[2] / 2 } end; TRAILS[#TRAILS + 1] = q end
  local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2, ol = 1, olx = 1 }
  X.layer(c, "sky"); rockbg(c, 240, 135)
  X.layer(c, "ground")
  local land = c:mask(); for x = 0, 239 do land:rect(x, 6 + math.floor(3 * math.sin(x / 13 + ri) + 0.5), x, 128 - math.floor(3 * math.sin(x / 9 + ri) + 0.5)) end
  land:cut(c:rect(0, 0, 3, 134)):cut(c:rect(236, 0, 239, 134))
  local pathM = c:mask(); for _, r in ipairs(ROADS) do pathM:add(c:line(r, 3)) end
  local trailM = c:mask(); for _, t in ipairs(TRAILS) do trailM:add(c:line(t, 2)) end
  local allPath = pathM:copy():add(trailM)
  for _, r in ipairs(ROADS) do land:add(c:line(r, 7)) end   -- tunnel mouths reach the frame edge
  -- find free spots far from clear circles and paths
  local function spot(cx, cy, rad, avoid)
    local best, bd = nil, 1e9
    for y = 14, 122, 2 do for x = 10, 230, 2 do
      local ok = not inclear(x, y, rad)
      if ok then for yy = y - rad, y + rad, 3 do for xx = x - rad, x + rad, 3 do if allPath:has(xx, yy) then ok = false end end end end
      if ok and avoid then for _, a in ipairs(avoid) do if math.abs(x - a[1]) < a[3] + rad and math.abs(y - a[2]) < a[3] + rad then ok = false end end end
      if ok then local d = (x - cx) ^ 2 + (y - cy) ^ 2; if d < bd then bd, best = d, { x, y } end end
    end end
    return best
  end
  local used = {}
  local TREE = spot(TOWN[1] + 12, TOWN[2] - 20, 8, used) or { 30, 40 }; used[#used + 1] = { TREE[1], TREE[2], 12 }
  local BIG = {}
  for _, t in ipairs({ { 110, 120 }, { 215, 40 } }) do local p = spot(t[1], t[2], 8, used); if p then BIG[#BIG + 1] = p; used[#used + 1] = { p[1], p[2], 10 } end end
  local lk = spot(205, 95, 8, used) or { 205, 95 }; used[#used + 1] = { lk[1], lk[2], 10 }
  local GLOW = {}
  for _, s in ipairs(STOPS) do if s[4] ~= "exit" and #GLOW < 10 then local p = spot(s[1] + 8, s[2] - 6, 3, used); if p and math.abs(p[1] - s[1]) + math.abs(p[2] - s[2]) < 26 then GLOW[#GLOW + 1] = p; used[#used + 1] = { p[1], p[2], 5 } end end end
  local SRC = { { TOWN[1], TOWN[2], 44 }, { TREE[1], TREE[2] + 4, 40 } }
  for _, s in ipairs(STOPS) do if s[4] ~= "exit" then SRC[#SRC + 1] = { s[1], s[2], s[4] == "village" and 22 or 18 } end end
  for _, g in ipairs(GLOW) do SRC[#SRC + 1] = { g[1], g[2], 24 } end
  local BAND = { { 34, "#c8d77a" }, { 24, "#7ab55c" }, { 14, "#4f9a45" }, { 5, "#2f6a3a" }, { -4, "#2f5a2a" }, { -1e9, "#1f3f3a" } }
  local BAY = { [0] = 0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5 }
  local function band(L) for _, b in ipairs(BAND) do if L >= b[1] then return b[2] end end end
  local light = {}
  for y = 0, 134 do for x = 0, 239 do if land:has(x, y) then
    local L = -1e9
    for _, s in ipairs(SRC) do local dx, dy = x - s[1], (y - s[2]) * 1.4; local v = s[3] - math.sqrt(dx * dx + dy * dy); if v > L then L = v end end
    local e = math.min(y - 6, 128 - y, x - 4, 235 - x); if e < 14 then L = L - (14 - e) * 1.2 end
    light[y * 240 + x] = L
    c:px(x, y, band(L + (BAY[(y % 4) * 4 + (x % 4)] - 7.5) * 0.6))
  end end end
  local function lit(x, y) return light[y * 240 + x] or -99 end
  local ts = ri * 17 + 3; local function trnd(n) ts = (ts * 1103515245 + 12345) % 2147483648 return ts % n end
  local DARKER = { ["#c8d77a"] = "#7ab55c", ["#7ab55c"] = "#4f9a45", ["#4f9a45"] = "#2f6a3a", ["#2f6a3a"] = "#2f5a2a", ["#2f5a2a"] = "#1f3f3a" }
  for i = 1, 200 do local x, y = 6 + trnd(228), 10 + trnd(116); if land:has(x, y) and not inclear(x, y, 0) then local d = DARKER[c:get(x, y)]; if d then c:paint({ "x.x", ".x." }, x, y, { x = d }) end end end
  -- dark pool
  local lm = c:ellipse(lk[1], lk[2], 8, 4); lm:clip(land); c:fill(lm, "#1f3f3a"); c:fill(c:rect(lk[1] - 4, lk[2] - 1, lk[1] + 1, lk[2] - 1), "#3f8fb0"); c:px(lk[1] + 3, lk[2] + 1, "#a9d6ea"); lm:edge():each(function(x, y) c:px(x, y, "#2f5a2a") end)
  X.layer(c, "objects")
  c:outline(land, { ol = 1, olx = 1 })
  -- paths: dark casing, then earth/cream fill by light
  local casing = allPath:copy():grow(1)
  casing:each(function(x, y) if not allPath:has(x, y) then c:px(x, y, lit(x, y) >= 14 and "#7a4a1f" or "#4a2c1a") end end)
  local function pathpx(x, y, road) local L = lit(x, y); local a, b = "#9a6b3f", "#7a4a1f"
    if L >= 24 then a, b = "#f2e4c0", "#d8c49a" elseif L >= 12 then a, b = "#d8c49a", "#c9a96e" elseif L >= 0 then a, b = "#c9a96e", "#9a6b3f" end
    if not road then a, b = b, (b == "#7a4a1f" and "#4a2c1a" or b) end
    c:px(x, y, (x + y) % 6 == 0 and b or a) end
  trailM:each(function(x, y) if not pathM:has(x, y) then pathpx(x, y, false) end end)
  pathM:each(function(x, y) pathpx(x, y, true) end)
  -- pin plaza: flat cobbled floor
  local plaza = c:ellipse(PIN[1], PIN[2], PIN[3] - 1, (PIN[3] - 1) * 0.75)
  c:fill(plaza, "#d8c49a"); plaza:each(function(x, y) if (x * 3 + y * 5) % 11 == 0 then c:px(x, y, "#c9a96e") end end); plaza:edge():each(function(x, y) c:px(x, y, "#9a6b3f") end)
  -- town houses ringed around the plaza
  local function house(x, y, big) local w = big and 11 or 9
    P(c, c:rect(x, y, x + w, y + 7), RM.cream, { gloss = false, flat = true }); P(c, c:poly({ { x - 1, y }, { x + w / 2, y - 5 }, { x + w + 1, y } }), RM.clay, { gloss = false, flat = true })
    c:fill(c:rect(x + 3, y + 3, x + 5, y + 5), "#f5cf6a"); c:px(x + 4, y + 4, "#fff3c8"); c:fill(c:rect(x + w - 3, y + 4, x + w - 2, y + 7), "#8a4f2a") end
  for _, a in ipairs({ 200, 250, 300, 340, 30, 100, 150 }) do local rr = PIN[3] + 5; local x, y = PIN[1] + math.cos(math.rad(a)) * rr - 5, PIN[2] + math.sin(math.rad(a)) * rr * 0.8 - 4
    if not pathM:copy():grow(1):has(math.floor(x + 5), math.floor(y + 4)) then house(math.floor(x), math.floor(y), a == 250) end end
  for _, a in ipairs({ 45, 135, 225, 315 }) do glowdot(c, math.floor(PIN[1] + math.cos(math.rad(a)) * (PIN[3] - 2)), math.floor(PIN[2] + math.sin(math.rad(a)) * (PIN[3] - 2) * 0.75)) end
  -- small huts at villages (beside, not on, the stop centre)
  for _, s in ipairs(STOPS) do if s[4] == "village" then
    for _, o in ipairs({ { -9, -7 }, { 4, -8 } }) do local x, y = s[1] + o[1], s[2] + o[2]
      c:fill(c:rect(x, y, x + 5, y + 4), "#d8c49a"); c:fill(c:poly({ { x - 1, y }, { x + 2.5, y - 3 }, { x + 6, y } }), "#a8582f"); c:px(x + 2, y + 2, "#f5cf6a") end
  end end
  -- big tree: fuller canopy, thick buttress roots
  local function bigtree(tx, ty, s, lum)
    local bark, barkD, barkL = lum and "#a4b86a" or "#7a4a1f", lum and "#4f9a45" or "#4a2c1a", lum and "#c8d77a" or "#9a6b3f"
    for _, d in ipairs({ { -14, 4 }, { -8, 7 }, { 8, 7 }, { 14, 4 }, { 1, 8 } }) do
      c:fill(c:line({ { tx, ty }, { tx + d[1] * 0.45 * s, ty + 2 + d[2] * 0.4 }, { tx + d[1] * s, ty + d[2] } }, 3), barkD)
      c:fill(c:line({ { tx, ty - 1 }, { tx + d[1] * 0.45 * s, ty + 1 + d[2] * 0.4 }, { tx + d[1] * 0.8 * s, ty + d[2] - 1 } }, 1), bark) end
    c:fill(c:rect(tx - 3, ty - 9 * s, tx + 3, ty + 2), barkD); c:fill(c:rect(tx - 2, ty - 9 * s, tx + 1, ty + 1), bark); c:fill(c:rect(tx - 1, ty - 9 * s, tx - 1, ty), barkL)
    local cy = ty - 14 * s
    for _, b in ipairs({ { -9, 2, 8, 6 }, { 9, 2, 8, 6 }, { 0, -3, 12, 7 }, { -5, -5, 7, 5 }, { 6, -6, 7, 5 } }) do c:fill(c:ellipse(tx + b[1] * s, cy + b[2] * s, b[3] * s + 1, b[4] * s + 1), "#2a1a10") end
    for _, b in ipairs({ { -9, 2, 8, 6 }, { 9, 2, 8, 6 }, { 0, -3, 12, 7 }, { -5, -5, 7, 5 }, { 6, -6, 7, 5 } }) do c:fill(c:ellipse(tx + b[1] * s, cy + b[2] * s, b[3] * s, b[4] * s), "#2f5a2a") end
    for _, b in ipairs({ { -8, 0, 5, 3 }, { 8, 0, 5, 3 }, { -1, -5, 8, 4 } }) do c:fill(c:ellipse(tx + b[1] * s, cy + b[2] * s, b[3] * s, b[4] * s), "#2f6a3a") end
    c:fill(c:ellipse(tx - 3 * s, cy - 7 * s, 4 * s, 1.5 * s), "#4f9a45")
    for i = 1, 16 do c:px(tx - 12 * s + trnd(math.floor(24 * s)), cy - 8 * s + trnd(math.floor(12 * s)), lum and (i % 3 == 0 and "#fff3c8" or "#c8d77a") or (i % 2 == 0 and "#4f9a45" or "#7ab55c")) end
    if lum then for _, d in ipairs({ -10, -4, 5, 11 }) do c:fill(c:rect(tx + d * s, cy + 4, tx + d * s, cy + 8 + (d % 3)), "#a4b86a") end end
  end
  bigtree(TREE[1], TREE[2], 1, true)
  for _, b in ipairs(BIG) do bigtree(b[1], b[2], 0.75, false) end
  for _, g in ipairs(GLOW) do for k = 0, 2 do shroom(c, g[1] - 4 + k * 4, g[2] - (k % 2) * 2, k == 1 and 1.2 or 0.9, k == 1 and "#c8d77a" or "#7ab55c") end end
  -- scatter outside clear circles
  local seed = ri * 31 + 5; local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
  local placed, PL = 0, {}
  local function free(x, y)
    if not (land:has(x, y) and land:has(x, y + 6) and land:has(x, y - 10)) then return false end
    if inclear(x, y, 3) or inclear(x, y - 6, 2) then return false end
    for _, a in ipairs(used) do if math.abs(x - a[1]) < a[3] + 4 and math.abs(y - a[2]) < a[3] + 6 then return false end end
    for _, p in ipairs(PL) do if math.abs(x - p[1]) < 6 and math.abs(y - p[2]) < 6 then return false end end
    for yy = y - 9, y + 1, 2 do for xx = x - 4, x + 4, 2 do if casing:has(xx, yy) then return false end end end
    return not lm:has(x, y)
  end
  for try = 1, 3000 do
    if placed >= 46 then break end
    local x, y = 10 + rnd(220), 18 + rnd(104)
    if free(x, y) then
      local L = lit(x, y)
      if L >= 12 and placed % 3 ~= 2 then c:fill(c:rect(x - 1, y - 3, x + 1, y), "#7a4a1f"); c:fill(c:ellipse(x, y - 8, 6, 5), "#2a1a10"); c:fill(c:ellipse(x, y - 8, 5, 4), "#2f5a2a"); c:fill(c:ellipse(x - 1, y - 9, 3, 2), "#2f6a3a"); c:px(x - 2, y - 10, "#4f9a45"); c:px(x - 2, y + 1, "#4a2c1a"); c:px(x + 2, y + 1, "#4a2c1a")
      elseif L >= 3 then shroom(c, x, y, 0.9, placed % 2 == 0 and "#c8d77a" or "#7ab55c")
      elseif placed % 2 == 0 then c:fill(c:line({ { x, y - 11 }, { x - 1, y - 5 }, { x, y } }, 2), "#7a4a1f"); c:fill(c:line({ { x, y - 1 }, { x - 4, y + 1 } }, 1), "#7a4a1f"); c:fill(c:line({ { x, y - 1 }, { x + 4, y + 1 } }, 1), "#7a4a1f")
      else stalag(c, x, y, 9, "#2f5a2a", "#1f3f3a") end
      placed = placed + 1; PL[#PL + 1] = { x, y }
    end
  end
  X.layer(c, "detail")
  for i = 1, 40 do local g = GLOW[1 + trnd(math.max(1, #GLOW))] or TREE; local x, y = g[1] - 7 + trnd(15), g[2] - 8 - trnd(5); if land:has(x, y) and not inclear(x, y, 0) then c:px(x, y, "#c8d77a") end end
  -- stalactite ceiling / floor stalagmites, skipping exit mouths
  local function mouth(x) for _, r in ipairs(ROADS) do if math.abs(x - r[#r][1]) < 7 then return true end end return false end
  for x = 2, 239, 6 do if not mouth(x) then local hh = 9 + (x * 13) % 8; c:fill(c:poly({ { x - 3, 0 }, { x, hh }, { x + 3, 0 } }), "#2a1a10"); c:px(x, hh - 2, "#4a2c1a") end end
  for x = 5, 239, 14 do if not mouth(x) then local hh = 10 + (x * 11) % 7; c:fill(c:rect(x, 0, x + 1, hh), "#4a2c1a"); c:px(x - 1, hh - 3, "#4a2c1a"); c:px(x + 2, hh - 6, "#4a2c1a"); if x % 3 == 0 then c:px(x, hh + 1, "#4f9a45") end end end
  for x = 5, 239, 9 do if not mouth(x) then local hh = 6 + (x * 7) % 6; c:fill(c:poly({ { x - 3, 134 }, { x, 134 - hh }, { x + 3, 134 } }), "#2a1a10") end end
  X.save(c, "map-WCA-fit", "scenes", { w = 480, h = 270, cap = 32 })
end
