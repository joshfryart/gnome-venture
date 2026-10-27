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
-- ===== SE fit: layout-driven (tools/map_layout.lua, frame 480x270 -> grid /2) =====
local LAY = dofile(os.getenv("GV_ROOT") .. "tools/map_layout.lua").regions.SE
local function g(v) return math.floor(v / 2 + 0.5) end
local TOWN = { g(LAY.town.x), g(LAY.town.y) }
local PIN = { g(LAY.pin.x), g(LAY.pin.y), LAY.pin.r / 2 }
local CLR = {}; for _, k in ipairs(LAY.clear) do CLR[#CLR + 1] = { k[1] / 2, k[2] / 2, k[3] / 2 } end
for _, s in ipairs(LAY.stops) do CLR[#CLR + 1] = { s.x / 2, s.y / 2, s.r / 2 + 2 } end
CLR[#CLR + 1] = { PIN[1], PIN[2], PIN[3] + 2 }
local function inclear(x, y, pad) for _, k in ipairs(CLR) do local dx, dy = x - k[1], y - k[2]; if dx * dx + dy * dy < (k[3] + pad) ^ 2 then return true end end return false end
local function gl(pts) local o = {}; for _, p in ipairs(pts) do o[#o + 1] = { g(p[1]), g(p[2]) } end return o end
do
  local ri, r = 6, REG[6]
  local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2, ol = 1, olx = 1 }
  X.layer(c, "sky"); rockbg(c, 240, 135)
  X.layer(c, "ground")
  -- exits: extend road ends to the frame edge in the exit direction
  local ROADS = {}
  for _, rd in ipairs(LAY.roads) do local p = gl(rd.pts); ROADS[#ROADS + 1] = p end
  for _, e in ipairs(LAY.exits) do local p = ROADS[e.road + 1]; local l = p[#p]
    if e.side == "N" then p[#p + 1] = { l[1], -2 } elseif e.side == "S" then p[#p + 1] = { l[1], 137 } elseif e.side == "W" then p[#p + 1] = { -2, l[2] } else p[#p + 1] = { 242, l[2] } end end
  local land = c:mask(); for x = 0, 239 do land:rect(x, 6 + math.floor(3 * math.sin(x / 13 + ri) + 0.5), x, 128 - math.floor(3 * math.sin(x / 9 + ri) + 0.5)) end
  land:cut(c:rect(0, 0, 3, 134)):cut(c:rect(236, 0, 239, 134))
  -- tunnel mouths for the exits: open the land to the edge along the exit path
  for _, e in ipairs(LAY.exits) do local x = g(e.x); if e.side == "N" then land:add(c:rect(x - 5, 0, x + 5, 12)) elseif e.side == "S" then land:add(c:rect(x - 5, 122, x + 5, 134)) end end
  local river = c:mask()
  for t = 0, 1, 0.01 do river:add(c:ellipse(math.floor(150 + 34 * math.sin(t * 4.2 + ri) + 0.5), math.floor(4 + t * 126), 1, 1)) end
  river:clip(land)
  local lk = { 66, 112 }
  -- giant glow-mushroom grove: candidates kept only outside keep-clear circles
  local GIANT = {}
  for _, cand in ipairs({ { 150, 50, 0.9 }, { 186, 68, 0.8 }, { 30, 66, 0.7 }, { 140, 120, 0.7 }, { 215, 80, 0.7 }, { 78, 28, 0.6 }, { 160, 26, 0.7 } }) do
    local s = cand[3]; local ok = true
    for dy = -24, 0, 4 do for dx = -14, 14, 4 do if inclear(cand[1] + dx * s, cand[2] + dy * s, 1) then ok = false end end end
    if ok then GIANT[#GIANT + 1] = cand end
  end
  -- light: town strongest, every stop gets a pool, giants add their own
  local SRC = { { TOWN[1], TOWN[2], 40 } }
  for _, s in ipairs(LAY.stops) do if s.kind ~= "exit" then SRC[#SRC + 1] = { g(s.x), g(s.y), s.type == "stop" and 26 or 17 } end end
  for _, gg in ipairs(GIANT) do SRC[#SRC + 1] = { gg[1], gg[2] - 6, 30 * gg[3] + 4 } end
  local BAND = { { 30, "#f5cf6a" }, { 20, "#e8a317" }, { 11, "#b07a10" }, { 3, "#7a4a1f" }, { -1e9, "#4a2c1a" } }
  local function bandc(L) for _, b in ipairs(BAND) do if L >= b[1] then return b[2] end end end
  local light = {}
  for y = 0, 134 do for x = 0, 239 do if land:has(x, y) then
    local L = -1e9
    for _, s in ipairs(SRC) do local dx, dy = x - s[1], (y - s[2]) * 1.4; local v = s[3] - math.sqrt(dx * dx + dy * dy); if v > L then L = v end end
    local e = math.min(y - 6, 128 - y, x - 4, 235 - x); if e < 14 then L = L - (14 - e) * 1.2 end
    L = L + 2.5 * math.sin(x / 7 + y / 5)
    light[y * 240 + x] = L
    local d = ((x + y) % 2 == 0) and 2 or -2
    c:px(x, y, bandc(L + d))
  end end end
  local ts = ri * 17 + 3; local function trnd(n) ts = (ts * 1103515245 + 12345) % 2147483648 return ts % n end
  local DARKER = { ["#f5cf6a"] = "#e8a317", ["#e8a317"] = "#b07a10", ["#b07a10"] = "#7a4a1f", ["#7a4a1f"] = "#4a2c1a", ["#4a2c1a"] = "#3d2a1c" }
  for i = 1, 160 do local x, y = 6 + trnd(228), 10 + trnd(116); if land:has(x, y) and not inclear(x, y, 0) then local d = DARKER[c:get(x, y)]; if d then c:paint({ "x.x", ".x." }, x, y, { x = d }) end end end
  for i = 1, 90 do local x, y = 6 + trnd(228), 10 + trnd(116); local L = light[y * 240 + x]; if L and L >= 3 and L < 18 and not inclear(x, y, 0) then c:paint({ ".x.", "x.x" }, x, y, { x = "#2f5a2a" }) end end
  -- underground stream and a still pool, both away from clear circles
  c:fill(river, "#25637d"); river:each(function(x, y) local L = light[y * 240 + x] or -99; if (x + y) % 4 == 0 then c:px(x, y, L >= 18 and "#f5cf6a" or "#3f8fb0") end end)
  local lm = c:ellipse(lk[1], lk[2], 9, 4); lm:clip(land)
  if not inclear(lk[1], lk[2], 9) then c:fill(lm, "#25637d"); c:fill(c:ellipse(lk[1] - 2, lk[2], 5, 2), "#3f8fb0"); c:fill(c:rect(lk[1] - 4, lk[2] - 1, lk[1] + 2, lk[2] - 1), "#f5cf6a"); lm:edge():each(function(x, y) c:px(x, y, "#3d2a1c") end) else lm = c:mask() end
  X.layer(c, "objects")
  c:outline(land, { ol = 1, olx = 1 })
  -- paths: roads 3px, trails 2px, dark casing, cream/earth fill tinted by light
  local roadM, trailM = c:mask(), c:mask()
  for _, p in ipairs(ROADS) do roadM:add(c:line(p, 3)) end
  for _, t in ipairs(LAY.trails) do trailM:add(c:line(gl(t), 2)) end
  local pathM = roadM:copy():add(trailM)
  pathM:copy():grow(1):cut(pathM):each(function(x, y) c:px(x, y, "#3d2a1c") end)
  local function pcol(x, y, rd) local L = light[y * 240 + x] or -99; local a, b = "#d8c49a", "#c9a96e"
    if L >= 22 then a, b = "#f2e4c0", "#d8c49a" elseif L < 3 then a, b = "#9a6b3f", "#7a4a1f" end
    if not rd then a, b = b, a end; return (x + y) % 6 == 0 and b or a end
  trailM:each(function(x, y) c:px(x, y, pcol(x, y, false)) end)
  roadM:each(function(x, y) c:px(x, y, pcol(x, y, true)) end)
  local bridge = pathM:copy():clip(river:copy():grow(1)):grow(1)
  c:fill(bridge, "#8a4f2a"); bridge:each(function(x, y) if x % 2 == 0 then c:px(x, y, "#b07a45") end end)
  -- town: flat plaza at the pin, lantern-lit houses ringed just outside it
  local pl = c:ellipse(PIN[1], PIN[2], PIN[3], PIN[3] * 0.8)
  c:fill(pl, "#d8c49a"); pl:edge():each(function(x, y) c:px(x, y, "#c9a96e") end)
  local function house(hx, hy, roof) P(c, c:rect(hx, hy, hx + 7, hy + 5), RM.cream, { gloss = false, flat = true }); P(c, c:poly({ { hx - 1, hy }, { hx + 3.5, hy - 4 }, { hx + 8, hy } }), roof, { gloss = false, flat = true }); c:fill(c:rect(hx + 3, hy + 2, hx + 4, hy + 4), "#f5cf6a"); c:px(hx + 3, hy + 3, "#fff3c8") end
  for _, a in ipairs({ 200, 240, 290, 330, 20, 60, 110, 150 }) do
    local rad = math.rad(a); local hx, hy = math.floor(TOWN[1] + math.cos(rad) * 15 - 4), math.floor(TOWN[2] + math.sin(rad) * 12 - 3)
    if not pathM:has(hx + 3, hy + 3) and not pathM:has(hx, hy) and not pathM:has(hx + 7, hy + 5) then house(hx, hy, a % 40 == 0 and RM.clay or RM.red) end
  end
  glowdot(c, TOWN[1] - 6, TOWN[2] - 7); glowdot(c, TOWN[1] + 6, TOWN[2] + 7)
  -- villages: a small hamlet hugging each stop (beside, not on, the marker)
  for _, s in ipairs(LAY.stops) do if s.kind == "village" and s.type == "stop" then local sx, sy = g(s.x), g(s.y)
    for _, o in ipairs({ { -9, -7 }, { 3, -8 } }) do local hx, hy = sx + o[1], sy + o[2]; if not pathM:has(hx + 3, hy + 3) and not pathM:has(hx, hy + 5) and not pathM:has(hx + 7, hy) then house(hx, hy, RM.red) end end
    glowdot(c, sx + 5, sy + 4) end end
  local function giant(x, y, s)
    c:fill(c:rect(x - 2 * s, y - 14 * s, x + 2 * s, y), "#f2e4c0"); c:fill(c:rect(x + 1 * s, y - 14 * s, x + 2 * s, y), "#d8c49a")
    local cap = c:ellipse(x, y - 15 * s, 13 * s, 7 * s):cut(c:rect(x - 14 * s, y - 14 * s, x + 14 * s, y)); cap:copy():grow(1):cut(cap):each(function(px, py) if py < y - 14 * s then c:px(px, py, "#7a4a1f") end end); c:fill(cap, "#e8a317")
    c:fill(c:ellipse(x - 2 * s, y - 18 * s, 8 * s, 3 * s), "#f5cf6a"); c:fill(c:rect(x - 12 * s, y - 15 * s, x + 12 * s, y - 15 * s), "#b07a10")
    for _, o in ipairs({ { -6, -18 }, { 3, -20 }, { 8, -17 }, { -2, -21 } }) do c:px(x + o[1] * s, y + o[2] * s, "#fff3c8") end
  end
  for _, gg in ipairs(GIANT) do giant(gg[1], gg[2], gg[3]) end
  local seed = ri * 31 + 5; local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
  local function free(x, y)
    if not (land:has(x, y) and land:has(x, y + 6)) then return false end
    if inclear(x, y, 4) or inclear(x, y - 8, 4) then return false end
    for _, gg in ipairs(GIANT) do if math.abs(x - gg[1]) < 15 * gg[3] and y > gg[2] - 24 * gg[3] and y < gg[2] + 4 then return false end end
    for dy = -9, 1 do for dx = -4, 4, 2 do if pathM:has(x + dx, y + dy) then return false end end end
    return not river:has(x, y) and not lm:has(x, y)
  end
  local placed = 0
  for try = 1, 900 do
    if placed >= 44 then break end
    local x, y = 12 + rnd(216), 18 + rnd(100)
    if free(x, y) then
      local L = light[y * 240 + x] or -99
      if L >= 20 then shroom(c, x, y, 1.2, placed % 2 == 0 and "#f5cf6a" or "#e8a317")
      elseif L >= 8 then if placed % 2 == 0 then glyph(c, "tree", x, y, 0.8) else shroom(c, x, y, 1, "#e8a317") end
      elseif L >= 0 then if placed % 2 == 0 then glyph(c, "tree", x, y, 0.8) else stalag(c, x, y, 8, "#7a4a1f", "#3d2a1c") end
      else stalag(c, x, y, 7 + placed % 4, "#4a2c1a", "#2a1a10") end
      placed = placed + 1
    end
  end
  X.layer(c, "detail")
  for i = 1, 70 do local s = SRC[1 + trnd(#SRC)]; local a = trnd(628) / 100; local d = 4 + trnd(math.max(2, math.floor(s[3]) - 4)); local x, y = math.floor(s[1] + math.cos(a) * d), math.floor(s[2] + math.sin(a) * d * 0.7)
    if land:has(x, y) and not pathM:has(x, y) and not inclear(x, y, 0) then local L = light[y * 240 + x] or -99; if L >= 22 then c:px(x, y, "#fff3c8") else c:px(x, y, "#f5cf6a") end end end
  -- ceiling/floor teeth, gapped where an exit tunnel leaves the frame
  local function gap(x, side) for _, e in ipairs(LAY.exits) do if e.side == side and math.abs(x - g(e.x)) < 9 then return true end end return false end
  for x = 2, 239, 6 do if not gap(x, "N") then local hh = 9 + (x * 13) % 8; c:fill(c:poly({ { x - 3, 0 }, { x, hh }, { x + 3, 0 } }), "#2a1a10"); c:px(x, hh - 2, "#4a2c1a") end end
  for x = 5, 239, 9 do if not gap(x, "S") then local hh = 6 + (x * 7) % 6; c:fill(c:poly({ { x - 3, 134 }, { x, 134 - hh }, { x + 3, 134 } }), "#2a1a10") end end
  X.save(c, "map-SE-fit", "scenes", { w = 480, h = 270, cap = 32 })
end
