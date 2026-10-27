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
-- ===== MENA fit: amber dune cavern refit to tools/map_layout.lua (frame 480x270 -> grid /2) =====
local LAY = dofile(os.getenv("GV_ROOT") .. "tools/map_layout.lua").regions.MENA
local function H(v) return math.floor(v / 2 + 0.5) end
do
  local ri = 8
  local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2, ol = 1, olx = 1 }
  X.layer(c, "sky"); rockbg(c, 240, 135)
  X.layer(c, "ground")
  local TX, TY = H(LAY.town.x), H(LAY.town.y)
  local PX, PY, PR = H(LAY.pin.x), H(LAY.pin.y), LAY.pin.r / 2
  local CLR = {}; for _, k in ipairs(LAY.clear) do CLR[#CLR + 1] = { k[1] / 2, k[2] / 2, k[3] / 2 } end
  local STOPS = {}; for _, s in ipairs(LAY.stops) do STOPS[#STOPS + 1] = { H(s.x), H(s.y), s.r / 2, s.kind } end
  local land = c:mask(); for x = 0, 239 do land:rect(x, 6 + math.floor(3 * math.sin(x / 13 + ri) + 0.5), x, 128 - math.floor(3 * math.sin(x / 9 + ri) + 0.5)) end
  land:cut(c:rect(0, 0, 3, 134)):cut(c:rect(236, 0, 239, 134))
  -- exits: open the cave wall where a road leaves the frame
  local EXITS = {}
  for _, e in ipairs(LAY.exits) do
    local x, y = H(e.x), H(e.y); local ex, ey = x, y
    if e.side == "N" then ey = 0 elseif e.side == "S" then ey = 134 elseif e.side == "E" then ex = 239 else ex = 0 end
    EXITS[#EXITS + 1] = { x, y, ex, ey }
    land:add(c:line({ { x, y }, { ex, ey } }, 9))
  end
  -- road + trail masks from the layout polylines
  local roadM, trailM = c:mask(), c:mask()
  for _, rd in ipairs(LAY.roads) do local pts = {}; for _, p in ipairs(rd.pts) do pts[#pts + 1] = { H(p[1]), H(p[2]) } end; roadM:add(c:line(pts, 3)) end
  for _, e in ipairs(EXITS) do roadM:add(c:line({ { e[1], e[2] }, { e[3], e[4] } }, 3)) end
  for _, tr in ipairs(LAY.trails) do local pts = {}; for _, p in ipairs(tr) do pts[#pts + 1] = { H(p[1]), H(p[2]) } end; trailM:add(c:line(pts, 2)) end
  trailM:cut(roadM)
  local pathM = roadM:copy():add(trailM)
  local river = c:mask()
  for t = 0, 1, 0.01 do local x, y = math.floor(150 + 34 * math.sin(t * 4.2 + ri) + 0.5), math.floor(4 + t * 126); river:add(c:ellipse(x, y, 1, 1)) end
  river:clip(land)
  for _, k in ipairs(CLR) do river:cut(c:ellipse(k[1], k[2], k[3] - 2, k[3] - 2)) end
  local lk = { 152, 122 }
  local BRAZ = { TX + 15, TY + 5 }
  local CRYS = { { 196, 30 }, { 222, 70 }, { 60, 18 }, { 12, 40 }, { 175, 100 }, { 70, 70 }, { 132, 22 }, { 22, 88 } }
  local LAMPS = {}
  for _, s in ipairs(STOPS) do if s[4] ~= "exit" then LAMPS[#LAMPS + 1] = { s[1] + 5, s[2] - 4 } end end
  local SRC = { { TX, TY, 50 }, { BRAZ[1], BRAZ[2], 34 } }
  for _, v in ipairs(CRYS) do SRC[#SRC + 1] = { v[1], v[2], 22 } end
  for _, l in ipairs(LAMPS) do SRC[#SRC + 1] = { l[1], l[2], 24 } end
  local BAND = { { 36, "#f5cf6a" }, { 26, "#e8a317" }, { 16, "#d9a660" }, { 7, "#9a6b3f" }, { -2, "#7a4a1f" }, { -1e9, "#4a2c1a" } }
  local light = {}
  for y = 0, 134 do for x = 0, 239 do if land:has(x, y) then
    local L = -1e9
    for _, s in ipairs(SRC) do local dx, dy = x - s[1], (y - s[2]) * 1.4; local v = s[3] - math.sqrt(dx * dx + dy * dy); if v > L then L = v end end
    L = L + 3 * math.sin(x / 9 + y / 5 + math.sin(y / 11) * 2)
    local e = math.min(y - 6, 128 - y, x - 4, 235 - x); if e < 14 then L = L - (14 - e) end
    light[y * 240 + x] = L
    local Ld = L + (((x + y) % 2 == 0) and 1.6 or -1.6)
    for _, b in ipairs(BAND) do if Ld >= b[1] then c:px(x, y, b[2]); break end end
  end end end
  local function bandAt(x, y) local L = light[y * 240 + x] or -99; for _, b in ipairs(BAND) do if L >= b[1] then return b[2] end end end
  -- stronger dune crests: a 2-px lit crest plus a shadow line beneath
  local LIGHTER = { ["#4a2c1a"] = "#7a4a1f", ["#7a4a1f"] = "#9a6b3f", ["#9a6b3f"] = "#d9a660", ["#d9a660"] = "#e8a317", ["#e8a317"] = "#f5cf6a", ["#f5cf6a"] = "#fff3c8" }
  local DARKER = { ["#fff3c8"] = "#f5cf6a", ["#f5cf6a"] = "#e8a317", ["#e8a317"] = "#d9a660", ["#d9a660"] = "#9a6b3f", ["#9a6b3f"] = "#7a4a1f", ["#7a4a1f"] = "#4a2c1a", ["#4a2c1a"] = "#3d2a1c" }
  local function inClear(x, y, pad) for _, k in ipairs(CLR) do local dx, dy = x - k[1], y - k[2]; if dx * dx + dy * dy < (k[3] + pad) ^ 2 then return true end end; return false end
  for y = 8, 126 do for x = 5, 234 do if land:has(x, y) and not inClear(x, y, -3) then
    local ph = (x / 9 + y / 5 + math.sin(y / 11) * 2) % 6.283
    if ph > 1.3 and ph < 1.75 and (x % 4 ~= 0) then local l = LIGHTER[c:get(x, y)]; if l then c:px(x, y, l) end
    elseif ph >= 1.75 and ph < 1.95 and (x % 2 == 0) then local d = DARKER[c:get(x, y)]; if d then c:px(x, y, d) end end
  end end end
  local ts = ri * 17 + 3; local function trnd(n) ts = (ts * 1103515245 + 12345) % 2147483648 return ts % n end
  for i = 1, 140 do local x, y = 6 + trnd(228), 10 + trnd(116); if land:has(x, y) and not inClear(x, y, 0) then local d = DARKER[c:get(x, y)]; if d then c:paint({ "x.x", ".x." }, x, y, { x = d }) end end end
  river:each(function(x, y) local L = light[y * 240 + x] or -99; c:px(x, y, L >= 16 and "#3f8fb0" or "#25637d"); if (x + y) % 7 == 0 and L >= 16 then c:px(x, y, "#a9d6ea") end end)
  local lm = c:ellipse(lk[1], lk[2], 10, 4); lm:clip(land); c:fill(lm, "#25637d"); c:fill(c:rect(lk[1] - 3, lk[2] - 1, lk[1] + 1, lk[2] - 1), "#3f8fb0"); lm:edge():each(function(x, y) c:px(x, y, "#3d2a1c") end)
  X.layer(c, "objects")
  c:outline(land, { ol = 1, olx = 1 })
  -- paths: dark casing, then cream/earth fill shaded by light
  local casing = pathM:copy():grow(1); casing:cut(pathM)
  casing:each(function(x, y) if land:has(x, y) and not river:has(x, y) then c:px(x, y, "#3d2a1c") end end)
  local function paint(m, cream)
    m:each(function(x, y) if land:has(x, y) or y <= 1 or y >= 133 or x >= 237 then local L = light[y * 240 + x] or -99; local a, b
      if cream then a, b = "#d8c49a", "#c9a96e"; if L >= 28 then a, b = "#f2e4c0", "#d8c49a" elseif L < 4 then a, b = "#9a6b3f", "#7a4a1f" end
      else a, b = "#c9a96e", "#9a6b3f"; if L < 4 then a, b = "#7a4a1f", "#4a2c1a" end end
      c:px(x, y, (x + y) % 6 == 0 and b or a) end end)
  end
  paint(trailM, false); paint(roadM, true)
  local bridge = roadM:copy():clip(river:copy():grow(1)):grow(1)
  c:fill(bridge, "#8a4f2a"); bridge:each(function(x, y) if x % 2 == 0 then c:px(x, y, "#7a4a1f") end end)
  -- pin plaza: flat simple floor at the town point
  local plaza = c:ellipse(PX, PY, PR - 1, PR - 1)
  c:fill(plaza, "#d8c49a"); plaza:edge():each(function(x, y) c:px(x, y, "#c9a96e") end)
  -- dome village ringed around the plaza (outside the pin circle, off the roads)
  local function dome(x, y) P(c, c:rect(x - 4, y - 3, x + 4, y + 3), RM.cream, { gloss = false, flat = true }); P(c, c:ellipse(x, y - 3, 4, 4):cut(c:rect(x - 5, y - 2, x + 5, y + 4)), RM.gold, { gloss = false, flat = true }); c:fill(c:rect(x - 1, y, x + 1, y + 3), "#f08a24"); c:px(x, y + 1, "#fff3c8") end
  local function otherClear(x, y) for i = 2, #CLR do local k = CLR[i]; local dx, dy = x - k[1], y - k[2]; if dx * dx + dy * dy < (k[3] + 5) ^ 2 then return true end end; return false end
  for a = 0, 350, 25 do
    local t = math.rad(a); local x, y = math.floor(TX + math.cos(t) * 17 + 0.5), math.floor(TY + math.sin(t) * 14 + 0.5)
    if not otherClear(x, y) and not (math.abs(x - BRAZ[1]) < 8 and math.abs(y - BRAZ[2]) < 10) and not roadM:has(x, y) and not roadM:has(x, y - 4) and not roadM:has(x - 4, y) and not roadM:has(x + 4, y) then dome(x, y) end
  end
  -- oil lamps on posts beside each village stop
  for _, l in ipairs(LAMPS) do if not pathM:has(l[1], l[2]) then c:fill(c:rect(l[1], l[2] - 5, l[1], l[2]), "#3d2a1c"); c:fill(c:rect(l[1] - 1, l[2] - 7, l[1] + 1, l[2] - 5), "#f08a24"); c:px(l[1], l[2] - 6, "#fff3c8") end end
  local bx, by = BRAZ[1], BRAZ[2]
  c:fill(c:rect(bx - 3, by - 1, bx + 3, by + 1), "#5b6470"); c:fill(c:rect(bx - 2, by + 2, bx - 2, by + 4), "#3d2a1c"); c:fill(c:rect(bx + 2, by + 2, bx + 2, by + 4), "#3d2a1c")
  c:fill(c:poly({ { bx - 3, by - 1 }, { bx, by - 8 }, { bx + 3, by - 1 } }), "#e0501f"); c:fill(c:poly({ { bx - 2, by - 1 }, { bx, by - 6 }, { bx + 2, by - 1 } }), "#f08a24"); c:fill(c:rect(bx, by - 4, bx, by - 2), "#fff3c8")
  for _, v in ipairs(CRYS) do crystalc(c, v[1] - 3, v[2] + 3, 9, "#e8a317"); crystalc(c, v[1] + 2, v[2] + 4, 6, "#f5cf6a"); c:px(v[1] - 3, v[2] - 3, "#fff3c8") end
  local seed = ri * 31 + 5; local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
  local placed = 0
  local function free(x, y)
    if not (land:has(x, y) and land:has(x, y - 10) and land:has(x, y + 2)) then return false end
    for _, yy in ipairs({ y, y - 5, y - 9 }) do if inClear(x, yy, 3) then return false end end
    if math.abs(x - bx) < 9 and math.abs(y - by) < 12 then return false end
    for _, v in ipairs(CRYS) do if math.abs(x - v[1]) < 9 and math.abs(y - v[2]) < 10 then return false end end
    for dy = -10, 2, 2 do for dx = -4, 4, 2 do if pathM:has(x + dx, y + dy) or river:has(x + dx, y + dy) or lm:has(x + dx, y + dy) then return false end end end
    return true
  end
  for try = 1, 900 do
    if placed >= 46 then break end
    local x, y = 8 + rnd(224), 16 + rnd(110)
    if free(x, y) then
      local L = light[y * 240 + x] or -99
      if L >= 6 then stalag(c, x, y, 8, "#e8a317", "#9a6b3f")
      elseif L >= -4 then stalag(c, x, y, 9, "#9a6b3f", "#4a2c1a")
      else if placed % 3 == 0 then crystalc(c, x, y, 6, "#b07a10") else stalag(c, x, y, 10, "#7a4a1f", "#3d2a1c") end end
      placed = placed + 1
    end
  end
  X.layer(c, "detail")
  for i = 1, 14 do local x, y = bx + trnd(9) - 4, by - 9 - trnd(8); c:px(x, y, i % 3 == 0 and "#fff3c8" or "#f08a24") end
  local function onExit(x) for _, e in ipairs(EXITS) do if math.abs(x - e[3]) < 7 then return true end end; return false end
  for x = 2, 239, 6 do if not onExit(x) then local hh = 9 + (x * 13) % 8; c:fill(c:poly({ { x - 3, 0 }, { x, hh }, { x + 3, 0 } }), "#2a1a10"); c:px(x, hh - 2, "#4a2c1a") end end
  for x = 5, 239, 9 do if not onExit(x) then local hh = 6 + (x * 7) % 6; c:fill(c:poly({ { x - 3, 134 }, { x, 134 - hh }, { x + 3, 134 } }), "#2a1a10") end end
  X.save(c, "map-MENA-fit", "scenes", { w = 480, h = 270, cap = 32 })
end
