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
-- ===== SEA upgrade: underground jungle cavern lit by glowing lagoon pools, bioluminescent shroom-palms and village lanterns =====
local function spalm(c, x, y, s, cap, gl)   -- mushroom "palm": curved stalk, drooping frond cap with glowing spots
  c:fill(c:rect(x, y - 7 * s, x, y), "#c9a96e"); c:px(x + 1, y - 3 * s, "#c9a96e"); c:px(x - 1, y, "#9a6b3f")
  local ty = math.floor(y - 7 * s)
  c:fill(c:ellipse(x, ty, 4 * s, 1.5 * s), cap)
  for _, d in ipairs({ -1, 1 }) do c:px(x + d * math.floor(4 * s), ty + 1, cap); c:px(x + d * math.floor(4 * s + 1), ty + 2, cap) end
  c:px(x - 2, ty, gl); c:px(x + 2, ty - 1, gl)
end
local function gpool(c, x, y, rx)   -- glowing lagoon pool
  c:fill(c:ellipse(x, y, rx, rx * 0.45), "#25637d"); c:fill(c:ellipse(x, y, rx * 0.7, rx * 0.3), "#3f8fb0"); c:fill(c:rect(x - rx * 0.5, y - 1, x, y - 1), "#a9d6ea"); c:px(x + 1, y, "#c8ecdc")
end
local LAY = dofile(os.getenv("GV_ROOT") .. "tools/map_layout.lua").regions.SEA
local function H(v) return math.floor(v / 2 + 0.5) end
do
  local ri = 13
  local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2, ol = 1, olx = 1 }
  X.layer(c, "sky"); rockbg(c, 240, 135)
  X.layer(c, "ground")
  local land = c:mask(); for x = 0, 239 do land:rect(x, 6 + math.floor(3 * math.sin(x / 13 + ri) + 0.5), x, 128 - math.floor(3 * math.sin(x / 9 + ri) + 0.5)) end
  land:cut(c:rect(0, 0, 3, 134)):cut(c:rect(236, 0, 239, 134))
  local T = { H(LAY.town.x), H(LAY.town.y) }
  local CL = {}; for _, q in ipairs(LAY.clear) do CL[#CL + 1] = { H(q[1]), H(q[2]), q[3] / 2 } end
  local ST = {}; for _, s in ipairs(LAY.stops) do ST[#ST + 1] = { H(s.x), H(s.y), s.r / 2, s.kind } end
  ST[#ST + 1] = { T[1], T[2], LAY.pin.r / 2, "town" }
  local function inclear(x, y, m) for _, q in ipairs(CL) do local dx, dy = x - q[1], y - q[2]; if dx * dx + dy * dy < (q[3] + m) ^ 2 then return true end end return false end
  local ROADS = {}
  for _, rd in ipairs(LAY.roads) do local pts = {}; for _, p in ipairs(rd.pts) do pts[#pts + 1] = { H(p[1]), H(p[2]) } end; ROADS[#ROADS + 1] = pts end
  for _, e in ipairs(LAY.exits) do local pts = ROADS[e.road + 1]; local l = pts[#pts]; local x, y = l[1], l[2]
    if e.side == "W" then x = -2 elseif e.side == "E" then x = 241 elseif e.side == "N" then y = -2 else y = 136 end; pts[#pts + 1] = { x, y } end
  local TRAILS = {}; for _, t in ipairs(LAY.trails) do local pts = {}; for _, p in ipairs(t) do pts[#pts + 1] = { H(p[1]), H(p[2]) } end; TRAILS[#TRAILS + 1] = pts end
  for _, e in ipairs(LAY.exits) do local pts = ROADS[e.road + 1]; land:add(c:line({ pts[#pts - 1], pts[#pts] }, 9)) end
  local lk = { 76, 24 }
  local river = c:mask(); local RP = {}
  for t = 0, 1, 0.02 do local x, y = math.floor(100 - 20 * t + 4 * math.sin(t * 7) + 0.5), math.floor(t * 22); river:add(c:ellipse(x, y, 1, 1)); RP[#RP + 1] = { x, y } end
  land:add(c:ellipse(lk[1], lk[2], 16, 8))
  local POOLS = {}
  for _, v in ipairs({ { 40, 100, 5 }, { 110, 116, 5 }, { 226, 58, 5 }, { 182, 121, 4 }, { 128, 20, 4 }, { 20, 64, 4 }, { 160, 102, 4 }, { 92, 96, 4 } }) do
    if not inclear(v[1], v[2], v[3] + 1) then POOLS[#POOLS + 1] = v end end
  local SRC = { { lk[1], lk[2], 40 } }
  for _, s in ipairs(ST) do SRC[#SRC + 1] = { s[1], s[2], s[4] == "town" and 46 or s[4] == "exit" and 26 or 34 } end
  for _, v in ipairs(POOLS) do SRC[#SRC + 1] = { v[1], v[2], 26 } end
  local BAND = { { 36, "#a4b86a" }, { 27, "#6a9a3a" }, { 18, "#4f9a45" }, { 9, "#2f6a3a" }, { 0, "#2f5a2a" }, { -1e9, "#1f3f3a" } }
  local light = {}
  local function bandAt(L, x, y)
    for i, b in ipairs(BAND) do if L >= b[1] then
      if i < #BAND and L < b[1] + 3 and (x + y) % 2 == 0 then return BAND[i + 1][2] end
      return b[2] end end
  end
  for y = 0, 134 do for x = 0, 239 do if land:has(x, y) then
    local L = -1e9
    for _, s in ipairs(SRC) do local dx, dy = x - s[1], (y - s[2]) * 1.1; local v = s[3] - math.sqrt(dx * dx + dy * dy); if v > L then L = v end end
    for _, p in ipairs(RP) do local dx, dy = x - p[1], y - p[2]; if math.abs(dx) < 24 and math.abs(dy) < 24 then local v = 18 - math.sqrt(dx * dx + dy * dy); if v > L then L = v end end end
    local e = math.min(y - 6, 128 - y, x - 4, 235 - x); if e < 14 then L = L - (14 - e) * 1.3 end
    light[y * 240 + x] = L
    c:px(x, y, bandAt(L, x, y))
  end end end
  local ts = ri * 17 + 3; local function trnd(n) ts = (ts * 1103515245 + 12345) % 2147483648 return ts % n end
  local DARKER = { ["#a4b86a"] = "#6a9a3a", ["#6a9a3a"] = "#4f9a45", ["#4f9a45"] = "#2f6a3a", ["#2f6a3a"] = "#2f5a2a", ["#2f5a2a"] = "#1f3f3a", ["#1f3f3a"] = "#3d2a1c" }
  for i = 1, 150 do local x, y = 6 + trnd(228), 10 + trnd(116); if land:has(x, y) and not inclear(x, y, 0) then local d = DARKER[c:get(x, y)]; if d then c:paint({ "x.x", ".x." }, x, y, { x = d }) end end end
  c:fill(river, "#25637d"); river:each(function(x, y) if (x + y) % 5 == 0 then c:px(x, y, "#a9d6ea") elseif (x + y) % 5 == 2 then c:px(x, y, "#3f8fb0") end end)
  local lm = c:ellipse(lk[1], lk[2], 12, 6); c:fill(lm, "#3f8fb0"); c:fill(c:ellipse(lk[1], lk[2], 8, 3), "#a9d6ea"); c:fill(c:rect(lk[1] - 5, lk[2] - 1, lk[1] + 2, lk[2] - 1), "#c8ecdc"); lm:edge():each(function(x, y) c:px(x, y, "#25637d") end)
  for _, v in ipairs(POOLS) do gpool(c, v[1], v[2], v[3]) end
  X.layer(c, "objects")
  c:outline(land, { ol = 1, olx = 1 })
  local roadM, trailM = c:mask(), c:mask()
  for _, pts in ipairs(ROADS) do roadM:add(c:line(pts, 3)) end
  for _, pts in ipairs(TRAILS) do trailM:add(c:line(pts, 2)) end
  local casing = roadM:copy():add(trailM):grow(1)
  c:fill(casing, "#3d2a1c")
  local function pathpx(x, y, trail) local L = light[y * 240 + x] or -99; local a, b = "#c9a96e", "#9a6b3f"
    if trail then a, b = "#9a6b3f", "#74462a"; if L >= 27 then a, b = "#c9a96e", "#9a6b3f" end
    elseif L >= 27 then a, b = "#f2e4c0", "#d8c49a" elseif L < 9 then a, b = "#9a6b3f", "#74462a" end
    c:px(x, y, (x + y) % 6 == 0 and b or a) end
  trailM:each(function(x, y) pathpx(x, y, true) end)
  roadM:each(function(x, y) pathpx(x, y, false) end)
  local bridge = roadM:copy():add(trailM):clip(river:copy():add(lm):grow(1)):grow(1)
  c:fill(bridge, "#9a6b3f"); bridge:each(function(x, y) if x % 2 == 0 then c:px(x, y, "#74462a") end end)
  local PR = LAY.pin.r / 2
  local floor = c:ellipse(H(LAY.pin.x), H(LAY.pin.y), PR, PR * 0.85); c:fill(floor, "#a4b86a"); floor:edge():each(function(x, y) if (x + y) % 2 == 0 then c:px(x, y, "#6a9a3a") end end)
  local function house(hx, hy)
    hx, hy = math.floor(hx - 4), math.floor(hy - 6)
    P(c, c:rect(hx, hy, hx + 8, hy + 6), RM.cream, { gloss = false, flat = true }); P(c, c:poly({ { hx - 1, hy }, { hx + 4, hy - 5 }, { hx + 9, hy } }), RM.wood, { gloss = false, flat = true }); c:fill(c:rect(hx + 3, hy + 3, hx + 5, hy + 5), "#f5cf6a"); c:px(hx + 4, hy + 4, "#fff3c8") end
  local function lantern(x, y) c:fill(c:rect(x, y - 4, x, y), "#74462a"); c:px(x, y - 5, "#f5cf6a"); c:px(x - 1, y - 5, "#fff3c8"); c:px(x + 1, y - 5, "#fff3c8") end
  local used = c:mask()
  local function okspot(x, y, m) if inclear(x, y, m) then return false end; if used:has(x, y) or casing:has(x, y) or river:has(x, y) or lm:has(x, y) then return false end; for _, v in ipairs(POOLS) do if math.abs(x - v[1]) < v[3] + 3 and math.abs(y - v[2]) < 5 then return false end end; return land:has(x, y) end
  -- houses ring the town floor (centred on the town point)
  local hn = 0
  for _, rad in ipairs({ 15, 20, 25 }) do for k = 0, 47 do local a = k / 48 * 6.283; local hx, hy = T[1] + math.cos(a) * rad, T[2] + 5 + math.sin(a) * rad * 0.75
    local okh = true; for dx = -5, 5, 2 do for dy = -11, 1, 2 do local x, y = math.floor(hx + dx), math.floor(hy + dy)
      if floor:has(x, y) or used:has(x, y) or casing:has(x, y) or not land:has(x, y) then okh = false end
      for qi = 2, #CL do local q = CL[qi]; if (x - q[1]) ^ 2 + (y - q[2]) ^ 2 < q[3] ^ 2 then okh = false end end end end
    if okh and hn < 8 then house(hx, hy); used:add(c:rect(math.floor(hx) - 7, math.floor(hy) - 13, math.floor(hx) + 7, math.floor(hy) + 3)); hn = hn + 1 end end end
  for _, s in ipairs(ST) do
    local n = (s[4] == "exit") and 2 or (s[4] == "town") and 6 or 3
    local got = 0
    for k = 0, 23 do if got >= n then break end
      local a = k * 2.4 + s[1]; local d = s[3] + 2; local x, y = math.floor(s[1] + math.cos(a) * d + 0.5), math.floor(s[2] + math.sin(a) * d * 0.9 + 0.5)
      if okspot(x, y, -1) and okspot(x, y - 4, -1) then if got % 2 == 0 then lantern(x, y) else shroom(c, x, y, 0.8, "#3f8fb0"); c:px(x, y - 4, "#c8ecdc") end; used:add(c:rect(x - 2, y - 6, x + 2, y + 1)); got = got + 1 end end
  end
  local seed = ri * 31 + 5; local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
  local placed = 0
  local function free(x, y)
    if not (land:has(x, y) and land:has(x, y + 6)) then return false end
    if inclear(x, y, 4) or inclear(x, y - 7, 4) or used:has(x, y) or used:has(x, y - 6) then return false end
    for _, v in ipairs(POOLS) do if math.abs(x - v[1]) < v[3] + 5 and math.abs(y - v[2]) < 7 then return false end end
    for dy = -8, 1, 3 do if casing:has(x, y + dy) or casing:has(x - 4, y + dy) or casing:has(x + 4, y + dy) then return false end end
    if river:has(x, y) or lm:has(x, y) or lm:has(x, y - 6) or river:has(x, y - 3) then return false end
    return true
  end
  for try = 1, 2000 do
    if placed >= 60 then break end
    local x, y = 8 + rnd(224), 16 + rnd(110)
    if free(x, y) then
      local L = light[y * 240 + x] or -99
      if L >= 18 then spalm(c, x, y, 1, placed % 3 == 0 and "#7ab55c" or "#4f9a45", "#c8ecdc")
      elseif L >= 6 then if placed % 2 == 0 then spalm(c, x, y, 0.9, "#2f6a3a", "#a9d6ea") else shroom(c, x, y, 1, "#3f8fb0") end
      else stalag(c, x, y, 8 + placed % 4, "#3d2a1c", "#2a1a10") end
      used:add(c:rect(x - 4, y - 8, x + 4, y + 1)); placed = placed + 1
    end
  end
  X.layer(c, "detail")
  for i = 1, 40 do local p = RP[1 + trnd(#RP)]; local x, y = p[1] + trnd(15) - 7, p[2] + trnd(8); if land:has(x, y) and not casing:has(x, y) and not inclear(x, y, 0) then c:px(x, y, "#c8ecdc") end end
  for i = 1, 24 do local x, y = lk[1] + trnd(29) - 14, lk[2] - 8 + trnd(5); if land:has(x, y) and not casing:has(x, y) and not lm:has(x, y) then c:px(x, y, "#c8ecdc") end end
  for x = 2, 239, 6 do local hh = 9 + (x * 13) % 8; local ok = true; for dx = -3, 3 do for y = 0, hh do if casing:has(x + dx, y) then ok = false end end end; if ok then c:fill(c:poly({ { x - 3, 0 }, { x, hh }, { x + 3, 0 } }), "#2a1a10"); c:px(x, hh - 2, "#4a2c1a") end end
  for x = 5, 239, 9 do local hh = 6 + (x * 7) % 6; local ok = true; for dx = -3, 3 do for y = 134 - hh, 134 do if casing:has(x + dx, y) then ok = false end end end; if ok then c:fill(c:poly({ { x - 3, 134 }, { x, 134 - hh }, { x + 3, 134 } }), "#2a1a10") end end
  X.save(c, "map-SEA-fit", "scenes", { w = 480, h = 270, cap = 32 })
end
