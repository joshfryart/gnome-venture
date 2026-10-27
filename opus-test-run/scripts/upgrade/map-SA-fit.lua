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
local LAY = dofile(os.getenv("GV_ROOT") .. "tools/map_layout.lua").regions.SA
local function h2(v) return math.floor(v / 2 + 0.5) end
local TOWN = { h2(LAY.town.x), h2(LAY.town.y) }
local CLR = {}; for _, q in ipairs(LAY.clear) do CLR[#CLR + 1] = { q[1] / 2, q[2] / 2, q[3] / 2 } end
CLR[#CLR + 1] = { LAY.pin.x / 2, LAY.pin.y / 2, LAY.pin.r / 2 }
local function inclear(x, y, pad) for _, q in ipairs(CLR) do local dx, dy = x - q[1], y - q[2]; if dx * dx + dy * dy < (q[3] + (pad or 0)) ^ 2 then return true end end return false end
local OLDPINS = { { 40, 100 }, { 70, 70 }, { 95, 100 }, { 120, 65 }, { 140, 98 }, { 165, 70 }, { 185, 100 }, { 205, 65 }, { 212, 100 } }   -- grid px (20x20 exported = 10x10 flat)
local ZONES = { { 40, 100, 34 }, { 95, 70, 38 }, { 150, 95, 40 }, { 205, 75, 36 } }
-- ===== SA upgrade: underground jungle cavern lit by a giant glow-mushroom canopy, glow-pool and village lanterns =====
do
  local ri, r = 4, REG[4]
  local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2, ol = 1, olx = 1 }
  X.layer(c, "sky"); rockbg(c, 240, 135)
  X.layer(c, "ground")
  local land = c:mask(); for x = 0, 239 do land:rect(x, 6 + math.floor(3 * math.sin(x / 13 + ri) + 0.5), x, 128 - math.floor(3 * math.sin(x / 9 + ri) + 0.5)) end
  land:cut(c:rect(0, 0, 3, 134)):cut(c:rect(236, 0, 239, 134))
  local river = c:mask(); local RP = {}
  for t = 0, 1, 0.01 do local x, y = math.floor(150 + 34 * math.sin(t * 4.2 + ri) + 0.5), math.floor(4 + t * 126); river:add(c:ellipse(x, y, 1, 1)); RP[#RP + 1] = { x, y } end
  river:clip(land)
  -- layout paths: roads (w3) and trails (w2), extended to the frame edge at exits
  local roadM, trailM = c:mask(), c:mask()
  for _, rd in ipairs(LAY.roads) do local pts = {}; for _, q in ipairs(rd.pts) do pts[#pts + 1] = { q[1] / 2, q[2] / 2 } end
    local e = pts[#pts]; if e[2] < 12 then pts[#pts + 1] = { e[1], -2 } elseif e[1] > 228 then pts[#pts + 1] = { 242, e[2] } elseif e[1] < 12 then pts[#pts + 1] = { -2, e[2] } elseif e[2] > 123 then pts[#pts + 1] = { e[1], 137 } end
    roadM:add(c:line(pts, 3)) end
  for _, tr in ipairs(LAY.trails) do local pts = {}; for _, q in ipairs(tr) do pts[#pts + 1] = { q[1] / 2, q[2] / 2 } end; trailM:add(c:line(pts, 2)) end
  local pathM = roadM:copy(); pathM:add(trailM)
  local lk = { 76, 124 }
  local GS = { 150, 40 }   -- giant glow mushroom
  local SMALL = { { 37, 44 }, { 88, 46 }, { 178, 88 }, { 214, 92 }, { 140, 92 }, { 30, 92 } }   -- lantern shrooms beside stops
  local SRC = { { TOWN[1], TOWN[2], 50 }, { GS[1], GS[2], 46 }, { lk[1], lk[2], 30 } }
  for _, v in ipairs(SMALL) do SRC[#SRC + 1] = { v[1], v[2], 24 } end
  local BAND = { { 36, "#a4b86a" }, { 26, "#7ab55c" }, { 16, "#4f9a45" }, { 7, "#2f6a3a" }, { -2, "#2f5a2a" }, { -1e9, "#1f3f3a" } }
  local light = {}
  local function band(L, x, y)
    for i, b in ipairs(BAND) do if L >= b[1] then
      if i > 1 and L >= b[1] + (BAND[i - 1][1] - b[1]) - 3 and (x + y) % 2 == 0 then return BAND[i - 1][2] end   -- dithered upper edge
      if L < b[1] + 2 and i < #BAND and (x + y) % 2 == 1 then return BAND[i + 1][2] end
      return b[2] end end
  end
  for y = 0, 134 do for x = 0, 239 do if land:has(x, y) then
    local L = -1e9
    for _, s in ipairs(SRC) do local dx, dy = x - s[1], (y - s[2]) * 1.4; local v = s[3] - math.sqrt(dx * dx + dy * dy); if v > L then L = v end end
    local e = math.min(y - 6, 128 - y, x - 4, 235 - x); if e < 14 then L = L - (14 - e) * 1.3 end
    light[y * 240 + x] = L
    c:px(x, y, band(L, x, y))
  end end end
  local function bandAt(x, y) return band(light[y * 240 + x] or -99, x, y) end
  local ts = ri * 17 + 3; local function trnd(n) ts = (ts * 1103515245 + 12345) % 2147483648 return ts % n end
  local DARKER = { ["#a4b86a"] = "#7ab55c", ["#7ab55c"] = "#4f9a45", ["#4f9a45"] = "#2f6a3a", ["#2f6a3a"] = "#2f5a2a", ["#2f5a2a"] = "#1f3f3a" }
  for i = 1, 160 do local x, y = 6 + trnd(228), 10 + trnd(116); if land:has(x, y) then local d = DARKER[c:get(x, y)]; if d then c:paint({ "x.x", ".x." }, x, y, { x = d }) end end end
  local zm = {}
  for zi = 4, 1, -1 do local z = ZONES[zi]; local m = c:mask(); m:add(c:ellipse(z[1], z[2], z[3], 30)); m:add(c:ellipse(z[1] + 8, z[2] - 14, z[3] * 0.6, 20)); m:clip(land); zm[zi] = m end
  for zi = 2, 4 do zm[zi]:edge():each(function(x, y) if (x + y) % 4 < 2 and land:has(x, y) then local L = light[y * 240 + x] or -99; c:px(x, y, L >= 16 and "#f5cf6a" or "#b07a10") end end) end
  -- dark underground river, lit where it passes light; glowing pool
  river:each(function(x, y) local L = light[y * 240 + x] or -99; c:px(x, y, L >= 16 and "#3f8fb0" or "#25637d"); if (x + y) % 5 == 0 then c:px(x, y, L >= 16 and "#a9d6ea" or "#3f8fb0") end end)
  local lm = c:ellipse(lk[1], lk[2], 11, 5); lm:clip(land); c:fill(lm, "#3f8fb0"); c:fill(c:ellipse(lk[1], lk[2], 7, 3), "#a9d6ea"); lm:edge():each(function(x, y) c:px(x, y, "#25637d") end); c:fill(c:rect(lk[1] - 3, lk[2], lk[1] + 2, lk[2]), "#eef8f2")
  X.layer(c, "objects")
  c:outline(land, { ol = 1, olx = 1 })
  pathM:copy():grow(1):each(function(x, y) if x >= 0 and x < 240 and y >= 0 and y < 135 then c:px(x, y, "#4a2c1a") end end)
  pathM:each(function(x, y) if x >= 0 and x < 240 and y >= 0 and y < 135 then local L = light[y * 240 + x] or -99; local a, b = "#c9a96e", "#9a6b3f"; if L >= 26 then a, b = "#f2e4c0", "#d8c49a" elseif L < 7 then a, b = "#74462a", "#4a2c1a" end; c:px(x, y, (x + y) % 6 == 0 and b or a) end end)
  local bridge = pathM:copy():clip(river:copy():grow(1)):grow(1)
  c:fill(bridge, "#74462a"); bridge:each(function(x, y) if x % 2 == 0 then c:px(x, y, "#9a6b3f") end end)
  local HOUSES = {}
  do local pg = pathM:copy():grow(1)
    local function ok(hx, hy) for yy = hy - 5, hy + 8 do for xx = hx - 1, hx + 10 do
      if pg:has(xx, yy) or not land:has(xx, yy) then return false end
      local dx, dy = xx - TOWN[1], yy - TOWN[2]; if dx * dx + dy * dy < 12 * 12 then return false end
      for i, q in ipairs(CLR) do if not (math.abs(q[1] - TOWN[1]) < 1 and math.abs(q[2] - TOWN[2]) < 1) then local ex, ey = xx - q[1], yy - q[2]; if ex * ex + ey * ey < q[3] * q[3] then return false end end end
    end end
    for _, h in ipairs(HOUSES) do if math.abs(h[1] - hx) < 12 and math.abs(h[2] - hy) < 15 then return false end end return true end
    for rad = 14, 30, 2 do for a = 0, 35 do if #HOUSES >= 7 then break end
      local hx, hy = math.floor(TOWN[1] + math.cos(a * math.pi / 18) * rad - 4.5), math.floor(TOWN[2] + math.sin(a * math.pi / 18) * rad * 0.8 - 2)
      if ok(hx, hy) then HOUSES[#HOUSES + 1] = { hx, hy } end end end end
  for _, h in ipairs(HOUSES) do P(c, c:rect(h[1], h[2], h[1] + 9, h[2] + 7), RM.cream, { gloss = false, flat = true }); P(c, c:poly({ { h[1] - 1, h[2] }, { h[1] + 4.5, h[2] - 5 }, { h[1] + 10, h[2] } }), RM.leaf, { gloss = false, flat = true }); c:fill(c:rect(h[1] + 3, h[2] + 3, h[1] + 5, h[2] + 5), "#f5cf6a"); c:px(h[1] + 4, h[2] + 4, "#fff3c8") end
  for i = 0, -1 do local x = 20 + i * 14; for dx = 0, 8, 2 do c:fill(c:rect(x + dx, 100, x + dx, 104), "#dd3a2a"); c:fill(c:rect(x + dx + 1, 100, x + dx + 1, 104), "#f2e4c0") end; c:fill(c:rect(x, 105, x + 9, 106), "#74462a"); glowdot(c, x + 4, 98) end
  -- giant glow mushroom (main light) with glow-vines draping off the cap
  c:fill(c:rect(GS[1] - 2, GS[2] - 4, GS[1] + 2, GS[2] + 8), "#f2e4c0"); c:fill(c:rect(GS[1] + 1, GS[2] - 4, GS[1] + 2, GS[2] + 8), "#d8c49a")
  c:fill(c:ellipse(GS[1], GS[2] - 7, 20, 9), "#4f9a45"); c:fill(c:ellipse(GS[1] - 1, GS[2] - 9, 17, 7), "#7ab55c"); c:fill(c:ellipse(GS[1] - 3, GS[2] - 11, 11, 4), "#a4b86a"); c:fill(c:ellipse(GS[1] - 5, GS[2] - 13, 5, 1), "#fff3c8"); c:fill(c:rect(GS[1] - 18, GS[2] - 1, GS[1] + 18, GS[2]), "#2f6a3a")
  for _, d in ipairs({ { -12, -8 }, { -4, -6 }, { 6, -11 }, { 13, -6 }, { -15, -4 }, { 2, -3 } }) do c:px(GS[1] + d[1], GS[2] + d[2], "#fff3c8"); c:px(GS[1] + d[1] + 1, GS[2] + d[2], "#f5cf6a") end
  for _, vx in ipairs({ -17, -12, -6, 6, 12, 17 }) do local len = 4 + (vx * vx) % 4; c:fill(c:rect(GS[1] + vx, GS[2] - 1, GS[1] + vx, GS[2] - 1 + len), "#4f9a45"); c:px(GS[1] + vx, GS[2] + len, "#f5cf6a") end
  for _, v in ipairs(SMALL) do shroom(c, v[1], v[2] + 3, 1.4, "#a4b86a"); glowdot(c, v[1] + 4, v[2] + 4) end
  local seed = ri * 31 + 5; local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
  local placed = 0
  local function free(x, y, pad)
    if not (land:has(x, y) and land:has(x, y + 6)) then return false end
    if inclear(x, y, 3) or inclear(x, y - 8, 2) then return false end
    for _, h in ipairs(HOUSES) do if x > h[1] - 6 and x < h[1] + 16 and y > h[2] - 8 and y < h[2] + 14 then return false end end
    if math.abs(x - GS[1]) < 24 and y > GS[2] - 16 and y < GS[2] + 14 then return false end
    for _, v in ipairs(SMALL) do if math.abs(x - v[1]) < 8 and math.abs(y - v[2]) < 8 then return false end end
    if math.abs(x - lk[1]) < 16 and math.abs(y - lk[2]) < 9 then return false end
    return not pathM:copy():grow(1):has(x, y) and not river:copy():grow(2):has(x, y)
  end
  for try = 1, 500 do
    if placed >= 44 then break end
    local x, y = 12 + rnd(216), 18 + rnd(100)
    if free(x, y) then
      local L = light[y * 240 + x] or -99
      if L >= 16 and placed % 3 ~= 2 then   -- bigger, outlined palm
        c:fill(c:rect(x - 1, y - 9, x + 1, y), "#2a1a10"); c:fill(c:rect(x, y - 9, x, y), "#b07a45")
        for _, d in ipairs({ { -5, -9, -1, -11 }, { 1, -11, 5, -9 }, { -6, -7, -3, -9 }, { 3, -9, 6, -7 } }) do c:fill(c:rect(math.min(x + d[1], x + d[3]), y + math.min(d[2], d[4]) - 1, math.max(x + d[1], x + d[3]), y + math.max(d[2], d[4]) + 1), "#1f3f3a") end
        for _, d in ipairs({ { -5, -9, -1, -11 }, { 1, -11, 5, -9 }, { -6, -7, -3, -9 }, { 3, -9, 6, -7 } }) do c:fill(c:rect(math.min(x + d[1], x + d[3]), y + math.min(d[2], d[4]), math.max(x + d[1], x + d[3]), y + math.max(d[2], d[4])), "#7ab55c") end
        c:fill(c:rect(x - 3, y - 11, x + 3, y - 10), "#a4b86a"); c:px(x, y - 11, "#f5cf6a")
      elseif L >= 6 then shroom(c, x, y, 1, placed % 2 == 0 and "#a4b86a" or "#7ab55c")
      else if placed % 2 == 0 then stalag(c, x, y, 9, "#2f5a2a", "#1f3f3a") else stalag(c, x, y, 8, "#4a2c1a", "#2a1a10") end end
      placed = placed + 1
    end
  end
  X.layer(c, "detail")
  do local pm = c:ellipse(LAY.pin.x / 2, LAY.pin.y / 2, LAY.pin.r / 2, LAY.pin.r / 2); pm:cut(pathM); c:fill(pm, "#a4b86a"); pm:edge():each(function(x, y) if (x + y) % 2 == 0 then c:px(x, y, "#7ab55c") end end) end
  local function nearexit(x) for _, e in ipairs(LAY.exits) do if e.side == "N" and math.abs(x - e.x / 2) < 7 then return true end end return false end
  -- stalactite ceiling with hanging roots (glowing tips), stalagmites on the floor edge
  for x = 2, 239, 6 do if nearexit(x) then goto cs end; local hh = 9 + (x * 13) % 8; c:fill(c:poly({ { x - 3, 0 }, { x, hh }, { x + 3, 0 } }), "#2a1a10"); c:px(x, hh - 2, "#4a2c1a"); ::cs:: end
  for x = 5, 236, 13 do if nearexit(x) then goto cr end; local len = 12 + (x * 7) % 12; for y = 4, len do c:px(x + math.floor(math.sin(y / 3 + x) + 0.5), y, "#74462a") end; c:fill(c:rect(x - 1, len + 1, x + 1, len + 1), "#f5cf6a"); c:px(x, len + 2, "#fff3c8"); c:px(x + 2, 8 + len // 3, "#74462a"); c:px(x + 3, 9 + len // 3, "#74462a"); ::cr:: end
  for x = 5, 239, 9 do if inclear(x, 128, 0) then goto cb end; local hh = 6 + (x * 7) % 6; c:fill(c:poly({ { x - 3, 134 }, { x, 134 - hh }, { x + 3, 134 } }), "#2a1a10"); ::cb:: end
  -- lanterns at stops (detail glow)
  for _, st in ipairs(LAY.stops) do if st.kind ~= "exit" then local x, y = h2(st.x) + 7, h2(st.y) - 2; c:fill(c:rect(x, y, x, y + 5), "#4a2c1a"); glowdot(c, x, y - 1) end end
  X.save(c, "map-SA-fit", "scenes", { w = 480, h = 270, cap = 32 })
end
