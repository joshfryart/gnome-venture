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

local function world(mask)
  local c = X.canvas{ mode = "scene", w = 320, h = 180, out = 2, ol = 1, olx = 1 }
  X.layer(c, "sky")
  if mask then c:fill(c:rect(0, 0, 319, 179), "#101010") else
    -- solid rock all round: wavy strata bands, pebbles, embedded crystals, a ceiling edge with stalactites, floor stalagmites
    c:fill(c:rect(0, 0, 319, 179), "#3d2a1c")
    for y = 0, 179 do for x = 0, 319 do
      local v = math.floor((y + 4 * math.sin(x / 38 + y / 29) + 3 * math.sin(x / 13)) / 10) % 3
      if v == 1 then c:px(x, y, "#4a2c1a") elseif v == 2 and (x * 3 + y) % 19 < 2 then c:px(x, y, "#5e2f1e") end
    end end
    local rs = 5; local function rr(n) rs = (rs * 1103515245 + 12345) % 2147483648 return rs % n end
    for i = 1, 90 do local x, y = rr(318), rr(178); c:px(x, y, "#5b6470"); c:px(x + 1, y, "#5b6470") end
    for i = 1, 14 do local x, y = rr(318), 8 + rr(160); c:px(x, y, "#7a5cc0"); c:px(x, y - 1, "#c3b2ea") end
    for x = 0, 319, 7 do local h = 5 + (x * 13) % 9; c:fill(c:poly({ { x - 3, 0 }, { x, h }, { x + 3, 0 } }), "#2a1a10") end                 -- ceiling stalactites
    for x = 3, 319, 11 do local h = 4 + (x * 7) % 7; c:fill(c:poly({ { x - 3, 179 }, { x, 179 - h }, { x + 3, 179 } }), "#2a1a10") end              -- floor stalagmites
  end
  X.layer(c, "ground")
  local land = c:mask(); local RMASK = {}
  for i, r in ipairs(REG) do
    local m = blob(c, c:mask(), i, r[2] * 0.32, r[3] * 0.32, r[4] * 0.32 * 1.1)
    land:add(m); RMASK[i] = m
    if mask then c:fill(m, string.format("#%02x%02x%02x", (i * 61) % 256, (i * 137) % 256, (i * 199) % 256)) end
  end
  if mask then return c end
  -- tunnels first (so caverns open into them): a dark carved passage with a lit edge, then the mycelium thread inside it
  local links = { { 1, 5 }, { 5, 7 }, { 7, 11 }, { 2, 3 }, { 3, 9 }, { 9, 8 }, { 8, 10 }, { 1, 2 }, { 4, 9 }, { 6, 8 }, { 11, 13 }, { 12, 13 }, { 13, 14 }, { 4, 10 }, { 5, 6 }, { 6, 7 }, { 8, 13 }, { 12, 11 } }
  local function pts(l) local a, b = REG[l[1]], REG[l[2]]; local x0, y0, x1, y1 = a[2] * 0.32, a[3] * 0.32, b[2] * 0.32, b[3] * 0.32
    local dx, dy = x1 - x0, y1 - y0; local len = math.sqrt(dx * dx + dy * dy); local nx, ny = -dy / len, dx / len; local off = ((l[1] * 7 + l[2] * 3) % 9 - 4) * 1.6
    return { { x0, y0 }, { x0 + dx * 0.33 + nx * off, y0 + dy * 0.33 + ny * off }, { x0 + dx * 0.66 - nx * off, y0 + dy * 0.66 - ny * off }, { x1, y1 } } end
  for _, l in ipairs(links) do c:fill(c:line(pts(l), 7), "#2a1a10") end
  for _, l in ipairs(links) do c:fill(c:line(pts(l), 5), "#7a4a1f") end
  for i, r in ipairs(REG) do c:fill(RMASK[i], r[5]) end
  c:outline(land, { ol = 1, olx = 1 })
  -- cavern floor texture and a lit inner rim
  local ws = 11; local function wrnd(n) ws = (ws * 1103515245 + 12345) % 2147483648 return ws % n end
  local DARK = { NA = true, SA = true, WCA = true, SEA = true, CSA = true, ESA = true }
  for i, r in ipairs(REG) do
    local fleck = DARK[r[1]] and "#fff3c8" or "#9a6b3f"
    for k = 1, 70 do local x, y = wrnd(318), wrnd(178); if RMASK[i]:has(x, y) and c:get(x, y) == r[5] then c:px(x, y, fleck) end end
  end
  X.layer(c, "objects")
  -- mycelium: a cream thread with side tendrils, spore dots and glowing nodes along each tunnel
  for _, l in ipairs(links) do
    local p = pts(l); c:fill(c:line(p, 3), "#f2e4c0"); c:fill(c:line(p, 1), "#fff3c8")
    for t = 0.12, 0.9, 0.13 do local i = math.floor(t * 3) + 1; local f = t * 3 - (i - 1); local x = p[i][1] + (p[i + 1][1] - p[i][1]) * f; local y = p[i][2] + (p[i + 1][2] - p[i][2]) * f
      glowdot(c, math.floor(x), math.floor(y) - 3 + (math.floor(t * 100) % 2) * 6); c:px(math.floor(x) + 1, math.floor(y) - 2, "#f2e4c0"); c:px(math.floor(x) + 2, math.floor(y) - 3, "#f2e4c0") end
  end
  -- Mossbottom: the hub grotto, a giant mushroom lit from within, threads reaching out
  local hub = c:ellipse(126, 150, 10, 6); c:fill(hub, "#4f9a45"); hub:copy():grow(1):cut(hub):each(function(x, y) c:px(x, y, "#2a1a10") end)
  c:fill(c:rect(125, 142, 127, 150), "#f2e4c0"); c:fill(c:ellipse(126, 141, 6, 4), "#dd3a2a"); c:px(123, 140, "#fff3c8"); c:px(129, 141, "#fff3c8"); c:px(126, 138, "#fff3c8"); glowdot(c, 119, 148); glowdot(c, 133, 148)
  for _, t in ipairs({ { 126, 144, 150, 120 }, { 126, 144, 96, 130 }, { 126, 144, 166, 110 } }) do c:fill(c:line({ { t[1], t[2] }, { (t[1] + t[3]) / 2, (t[2] + t[4]) / 2 + 6 }, { t[3], t[4] } }, 1), "#f2e4c0") end
  -- cavern features, kept 9 px off the pin spot
  X.layer(c, "detail")
  local gs = 23; local function grnd(n) gs = (gs * 1103515245 + 12345) % 2147483648 return gs % n end
  for i, r in ipairs(REG) do
    local px, py = r[2] * 0.32, r[3] * 0.32; local n = 0; local fl = FEAT[r[1]]
    for try = 1, 120 do
      if n >= 7 then break end
      local x, y = math.floor(px - 15 + grnd(31)), math.floor(py - 12 + grnd(25))
      if RMASK[i]:has(x, y) and RMASK[i]:has(x, y + 3) and RMASK[i]:has(x - 5, y) and RMASK[i]:has(x + 5, y) and (math.abs(x - px) > 9 or math.abs(y - py) > 9) and c:get(x, y) == r[5] then feat(c, fl[n % #fl + 1], x, y); n = n + 1 end
    end
  end
  for i, r in ipairs(REG) do c:fill(c:rect(r[2] * 0.32 - 6, r[3] * 0.32 - 6, r[2] * 0.32 + 5, r[3] * 0.32 + 5), r[5]) end   -- flat 12x12 pin spots
  return c
end

-- ===== regions =====
-- per region: 4 ground tints gentle -> hard, road colour, village roof ramp
local TINT = {
  NA = { "#a4b86a", "#7ab55c", "#4f9a45", "#2f5a2a" }, CA = { "#f5cf6a", "#c9a96e", "#9a6b3f", "#7a4a1f" }, CB = { "#f5cf6a", "#c8ecdc", "#7ab55c", "#4f9a45" }, SA = { "#a4b86a", "#4f9a45", "#2f6a3a", "#2f5a2a" },
  NWE = { "#bdd292", "#a4b86a", "#7ab55c", "#5b6470" }, SE = { "#f5cf6a", "#bdd292", "#a4b86a", "#c9a96e" }, EE = { "#f1ece0", "#bdd292", "#a4b86a", "#5b6470" }, MENA = { "#f5cf6a", "#d9a660", "#c9a96e", "#9a6b3f" },
  WCA = { "#7ab55c", "#4f9a45", "#2f6a3a", "#2f5a2a" }, ESA = { "#a4b86a", "#c9a96e", "#9a6b3f", "#5b6470" }, CSA = { "#f5cf6a", "#f08a24", "#e0501f", "#a8582f" }, EA = { "#f6b8cf", "#a4b86a", "#7ab55c", "#8b8f96" },
  SEA = { "#a4b86a", "#6a9a3a", "#4f9a45", "#2f6a3a" }, OC = { "#f5cf6a", "#f2e4c0", "#c8ecdc", "#7ab55c" } }
local ZONES = { { 40, 100, 34 }, { 95, 70, 38 }, { 150, 95, 40 }, { 205, 75, 36 } }
-- ===== CB fit: underground turquoise lagoon cavern refitted to tools/map_layout.lua (grid = layout / 2) =====
do
  local LY = dofile(os.getenv("GV_ROOT") .. "tools/map_layout.lua").regions.CB
  local ri = 3
  local function g(v) return v / 2 end
  local T = { g(LY.town.x), g(LY.town.y) }
  local PIN = { g(LY.pin.x), g(LY.pin.y), g(LY.pin.r) }
  local CLR = {}
  for _, k in ipairs(LY.clear or {}) do CLR[#CLR + 1] = { g(k[1] or k.x), g(k[2] or k.y), g(k[3] or k.r) } end
  for _, s in ipairs(LY.stops) do CLR[#CLR + 1] = { g(s.x), g(s.y), g(s.r) } end
  CLR[#CLR + 1] = PIN
  local function inclear(x, y, m) for _, k in ipairs(CLR) do local dx, dy = x - k[1], y - k[2]; if dx * dx + dy * dy < (k[3] + (m or 0)) ^ 2 then return true end end return false end
  local function gp(pts) local o = {} for _, p in ipairs(pts) do o[#o + 1] = { g(p[1]), g(p[2]) } end return o end
  local ROADS, TRAILS = {}, {}
  for _, r in ipairs(LY.roads) do ROADS[#ROADS + 1] = gp(r.pts) end
  for _, t in ipairs(LY.trails) do TRAILS[#TRAILS + 1] = gp(t.pts or t) end
  -- push exits to the frame edge in their direction
  for _, e in ipairs(LY.exits) do
    local ex, ey = g(e.x), g(e.y)
    local tx, ty = ex, ey
    if e.side == "W" then tx = -2 elseif e.side == "E" then tx = 241 elseif e.side == "N" then ty = -2 else ty = 136 end
    for _, r in ipairs(ROADS) do local q = r[#r]; if math.abs(q[1] - ex) < 1 and math.abs(q[2] - ey) < 1 then r[#r + 1] = { tx, ty } end end
  end
  local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2, ol = 1, olx = 1 }
  X.layer(c, "sky"); rockbg(c, 240, 135)
  X.layer(c, "ground")
  local land = c:mask(); for x = 0, 239 do land:rect(x, 6 + math.floor(3 * math.sin(x / 13 + ri) + 0.5), x, 128 - math.floor(3 * math.sin(x / 9 + ri) + 0.5)) end
  land:cut(c:rect(0, 0, 3, 134)):cut(c:rect(236, 0, 239, 134))
  local roadM, trailM = c:mask(), c:mask()
  for _, r in ipairs(ROADS) do roadM:add(c:line(r, 4)) end
  for _, t in ipairs(TRAILS) do trailM:add(c:line(t, 2)) end
  land:add(roadM:copy():grow(2))   -- exits cut through the rock wall to the frame edge
  -- glowing pools in the big dark gaps, a glow-stream from the Singing Waterfall
  local POOLS = { { 42, 100, 15, 6 }, { 142, 110, 11, 5 }, { 214, 22, 10, 4 }, { 70, 30, 8, 3 } }
  local water = c:mask()
  for _, p in ipairs(POOLS) do water:add(c:ellipse(p[1], p[2], p[3], p[4])); water:add(c:ellipse(p[1] + p[3] * 0.4, p[2] + 2, p[3] * 0.6, p[4] * 0.7)) end
  local RP = {}
  for t = 0, 1, 0.02 do local x, y = 124 + 16 * t + 3 * math.sin(t * 7), 82 + 26 * t; RP[#RP + 1] = { math.floor(x + 0.5), math.floor(y + 0.5) } end
  local river = c:mask(); for _, p in ipairs(RP) do river:add(c:ellipse(p[1], p[2], 1, 1)) end
  water:clip(land); river:clip(land)
  local WET = water:copy():add(river); WET:cut(roadM:copy():grow(2)); WET:cut(trailM:copy():grow(1))
  local KEEP = c:mask(); for _, k in ipairs(CLR) do KEEP:add(c:ellipse(k[1], k[2], k[3], k[3])) end
  WET:cut(KEEP)
  -- light: town, road villages, pools, crystals
  local CRY = { { 208, 34 }, { 196, 72 }, { 22, 82 }, { 64, 76 }, { 106, 104 }, { 116, 38 }, { 150, 96 }, { 34, 30 } }
  local SRC = { { T[1], T[2], 48 } }
  for _, s in ipairs(LY.stops) do if s.kind == "village" and s.type == "stop" then SRC[#SRC + 1] = { g(s.x), g(s.y), 30 } elseif s.kind ~= "exit" then SRC[#SRC + 1] = { g(s.x), g(s.y), 18 } end end
  for _, p in ipairs(POOLS) do SRC[#SRC + 1] = { p[1], p[2], 34 } end
  for _, v in ipairs(CRY) do SRC[#SRC + 1] = { v[1], v[2], 22 } end
  local BAND = { { 36, "#c8ecdc" }, { 26, "#a9d6ea" }, { 16, "#3f8fb0" }, { 7, "#25637d" }, { -2, "#1f3f3a" }, { -1e9, "#2a1a10" } }
  local light = {}
  local function bayer(x, y) return ({ 0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5 })[(y % 4) * 4 + (x % 4) + 1] / 16 * 4 - 2 end
  for y = 0, 134 do for x = 0, 239 do if land:has(x, y) then
    local L = -1e9
    for _, s in ipairs(SRC) do local dx, dy = x - s[1], (y - s[2]) * 1.4; local v = s[3] - math.sqrt(dx * dx + dy * dy); if v > L then L = v end end
    for _, p in ipairs(RP) do local dx, dy = x - p[1], y - p[2]; if math.abs(dx) < 24 and math.abs(dy) < 24 then local v = 20 - math.sqrt(dx * dx + dy * dy); if v > L then L = v end end end
    local e = math.min(y - 6, 128 - y, x - 4, 235 - x); if e < 14 then L = L - (14 - e) * 1.2 end
    light[y * 240 + x] = L
    local Ld = L + bayer(x, y)
    for _, b in ipairs(BAND) do if Ld >= b[1] then c:px(x, y, b[2]); break end end
  end end end
  local function bandAt(x, y) local L = light[y * 240 + x] or -99; for _, b in ipairs(BAND) do if L >= b[1] then return b[2] end end return "#2a1a10" end
  local ts = ri * 17 + 3; local function trnd(n) ts = (ts * 1103515245 + 12345) % 2147483648 return ts % n end
  local DARKER = { ["#c8ecdc"] = "#a9d6ea", ["#a9d6ea"] = "#3f8fb0", ["#3f8fb0"] = "#25637d", ["#25637d"] = "#1f3f3a", ["#1f3f3a"] = "#2a1a10" }
  for i = 1, 160 do local x, y = 6 + trnd(228), 10 + trnd(116); if land:has(x, y) and not inclear(x, y, 1) then local d = DARKER[c:get(x, y)]; if d then c:paint({ "x.x", ".x." }, x, y, { x = d }) end end end
  -- water
  c:fill(WET, "#a9d6ea"); WET:each(function(x, y) if (x + y) % 5 == 0 then c:px(x, y, "#eef8f2") elseif (x + y) % 5 == 2 then c:px(x, y, "#c8ecdc") end end)
  water:copy():clip(WET):edge():each(function(x, y) c:px(x, y, "#3f8fb0") end)
  X.layer(c, "objects")
  c:outline(land, { ol = 1, olx = 1 })
  -- paths: dark casing, then cream (roads) / earth (trails), shaded by the light bands
  local roadC, trailC = roadM:copy():grow(1), trailM:copy():grow(1)
  trailC:clip(land); roadC:clip(land)
  c:fill(trailC, "#3d2a1c"); c:fill(roadC, "#2a1a10")
  trailM:each(function(x, y) if land:has(x, y) and not roadC:has(x, y) then local L = light[y * 240 + x] or -99; c:px(x, y, L >= 16 and ((x + y) % 5 == 0 and "#c9a96e" or "#d8c49a") or (L >= 0 and "#c9a96e" or "#9a6b3f")) end end)
  roadM:each(function(x, y) local L = light[y * 240 + x] or -99; local a, b = "#d8c49a", "#c9a96e"; if L >= 26 then a, b = "#f2e4c0", "#d8c49a" elseif L < 0 then a, b = "#c9a96e", "#9a6b3f" end; c:px(x, y, (x + y) % 6 == 0 and b or a) end)
  -- town: flat lit plaza on the pin, lantern-lit houses ringed around it
  local plaza = c:ellipse(T[1], T[2], PIN[3], PIN[3] * 0.8)
  c:fill(plaza, bandAt(math.floor(T[1]), math.floor(T[2])))
  local HOUSES = {}
  for k = 0, 7 do local a = k / 8 * 2 * math.pi + 0.35; local hx, hy = math.floor(T[1] + math.cos(a) * 18 - 4.5), math.floor(T[2] + math.sin(a) * 13 - 3)
    local cx, cy = hx + 4.5, hy + 3
    if not roadM:copy():grow(1):has(math.floor(cx), math.floor(cy)) and not roadM:has(hx, hy + 7) and not roadM:has(hx + 9, hy + 7) and not roadM:has(hx, hy) and not roadM:has(hx + 9, hy) and hy > 9 and not inclear(cx, cy, -9) then HOUSES[#HOUSES + 1] = { hx, hy } end end
  for _, h in ipairs(HOUSES) do P(c, c:rect(h[1], h[2], h[1] + 9, h[2] + 7), RM.cream, { gloss = false, flat = true }); P(c, c:poly({ { h[1] - 1, h[2] }, { h[1] + 4.5, h[2] - 5 }, { h[1] + 10, h[2] } }), RM.clay, { gloss = false, flat = true }); c:fill(c:rect(h[1] + 3, h[2] + 3, h[1] + 5, h[2] + 5), "#f5cf6a"); c:px(h[1] + 4, h[2] + 4, "#fff3c8") end
  -- lanterns beside the road villages, just outside their keep-clear
  for _, s in ipairs(LY.stops) do if s.kind == "village" and s.type == "stop" then
    for _, o in ipairs({ { 1, -1 }, { -1, 1 } }) do
      local lx, ly = math.floor(g(s.x) + o[1] * (g(s.r) + 6)), math.floor(g(s.y) + o[2] * 3)
      if not inclear(lx, ly, 1) and not inclear(lx, ly + 6, 1) and not roadC:has(lx, ly + 6) and not trailC:has(lx, ly + 6) then c:fill(c:rect(lx, ly, lx, ly + 6), "#8a4f2a"); glowdot(c, lx, ly - 1) end
    end end end
  -- glow-crystal clusters
  for _, v in ipairs(CRY) do if not inclear(v[1], v[2], 4) then crystalc(c, v[1], v[2], 10, "#a9d6ea"); crystalc(c, v[1] - 4, v[2] + 1, 6, "#c8ecdc"); c:px(v[1], v[2] - 9, "#eef8f2") end end
  local seed = ri * 31 + 5; local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
  local BLOCK = roadC:copy():grow(2):add(trailC:copy():grow(2)):add(water:copy():grow(1)):add(river:copy():grow(1))
  local function free(x, y)
    if not (land:has(x, y) and land:has(x, y + 6)) or y < 18 then return false end
    for dy = -10, 1, 3 do for dx = -3, 3, 3 do if inclear(x + dx, y + dy, 2) then return false end end end
    for _, h in ipairs(HOUSES) do if math.abs(x - h[1] - 4) < 9 and math.abs(y - h[2] - 3) < 10 then return false end end
    for _, v in ipairs(CRY) do if math.abs(x - v[1]) < 8 and math.abs(y - v[2]) < 8 then return false end end
    if BLOCK:has(x, y) or BLOCK:has(x, y - 5) then return false end
    return true
  end
  local placed = 0
  for try = 1, 1500 do
    if placed >= 60 then break end
    local x, y = 8 + rnd(224), 14 + rnd(110)
    if free(x, y) then
      local L = light[y * 240 + x] or -99
      if L >= 14 and placed % 2 == 0 then glyph(c, "palm", x, y, 0.8)
      elseif L >= 6 then shroom(c, x, y, 1, placed % 3 == 0 and "#c8ecdc" or "#a9d6ea")
      elseif L >= -2 then stalag(c, x, y, 8, "#25637d", "#1f3f3a")
      else stalag(c, x, y, 10, "#3d2a1c", "#2a1a10") end
      placed = placed + 1
    end
  end
  X.layer(c, "detail")
  for i = 1, 24 do local p = RP[1 + trnd(#RP)]; local x, y = p[1] + trnd(7) - 3, p[2] - 1 - trnd(3); if land:has(x, y) and not BLOCK:has(x, y) and not inclear(x, y) then c:px(x, y, "#eef8f2") end end
  local open = roadM:copy():grow(2)
  for x = 2, 239, 6 do local hh = 9 + (x * 13) % 8; if not open:has(x, 1) and not inclear(x, hh, 2) then c:fill(c:poly({ { x - 3, 0 }, { x, hh }, { x + 3, 0 } }), "#2a1a10"); c:px(x, hh - 2, "#4a2c1a") end end
  for x = 5, 239, 9 do local hh = 6 + (x * 7) % 6; if not open:has(x, 133) and not open:has(x - 3, 133) and not open:has(x + 3, 133) and not inclear(x, 134 - hh, 2) then c:fill(c:poly({ { x - 3, 134 }, { x, 134 - hh }, { x + 3, 134 } }), "#2a1a10") end end
  X.save(c, "map-CB-fit", "scenes", { w = 480, h = 270, cap = 32 })
end
