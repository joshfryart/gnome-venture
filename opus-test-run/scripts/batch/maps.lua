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
local c = world(false); X.save(c, "map-world", "scenes", { w = 640, h = 360, cap = 40 })
c = world(true); X.save(c, "map-world-regions", "scenes", { w = 640, h = 360, cap = 40 })

-- ===== regions =====
-- per region: 4 ground tints gentle -> hard, road colour, village roof ramp
local TINT = {
  NA = { "#a4b86a", "#7ab55c", "#4f9a45", "#2f5a2a" }, CA = { "#f5cf6a", "#c9a96e", "#9a6b3f", "#7a4a1f" }, CB = { "#f5cf6a", "#c8ecdc", "#7ab55c", "#4f9a45" }, SA = { "#a4b86a", "#4f9a45", "#2f6a3a", "#2f5a2a" },
  NWE = { "#bdd292", "#a4b86a", "#7ab55c", "#5b6470" }, SE = { "#f5cf6a", "#bdd292", "#a4b86a", "#c9a96e" }, EE = { "#f1ece0", "#bdd292", "#a4b86a", "#5b6470" }, MENA = { "#f5cf6a", "#d9a660", "#c9a96e", "#9a6b3f" },
  WCA = { "#7ab55c", "#4f9a45", "#2f6a3a", "#2f5a2a" }, ESA = { "#a4b86a", "#c9a96e", "#9a6b3f", "#5b6470" }, CSA = { "#f5cf6a", "#f08a24", "#e0501f", "#a8582f" }, EA = { "#f6b8cf", "#a4b86a", "#7ab55c", "#8b8f96" },
  SEA = { "#a4b86a", "#6a9a3a", "#4f9a45", "#2f6a3a" }, OC = { "#f5cf6a", "#f2e4c0", "#c8ecdc", "#7ab55c" } }
local PINS = { { 40, 100 }, { 70, 70 }, { 95, 100 }, { 120, 65 }, { 140, 98 }, { 165, 70 }, { 185, 100 }, { 205, 65 }, { 212, 100 } }   -- grid px (20x20 exported = 10x10 flat)
local ZONES = { { 40, 100, 34 }, { 95, 70, 38 }, { 150, 95, 40 }, { 205, 75, 36 } }
for ri, r in ipairs(REG) do
  local code, tint = r[1], TINT[r[1]]
  local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2, ol = 1, olx = 1 }
  X.layer(c, "sky"); rockbg(c, 240, 135)
  X.layer(c, "ground")
  local land = c:mask(); for x = 0, 239 do land:rect(x, 6 + math.floor(3 * math.sin(x / 13 + ri) + 0.5), x, 128 - math.floor(3 * math.sin(x / 9 + ri) + 0.5)) end
  land:cut(c:rect(0, 0, 3, 134)):cut(c:rect(236, 0, 239, 134))
  c:fill(land, tint[1])
  local zm = {}
  for zi = 4, 1, -1 do   -- hardest zone painted first so gentle zones overlap toward the village
    local z = ZONES[zi]; local m = c:mask()
    m:add(c:ellipse(z[1], z[2], z[3], 30)); m:add(c:ellipse(z[1] + 8, z[2] - 14, z[3] * 0.6, 20)); m:clip(land)
    c:fill(m, tint[zi]); zm[zi] = m
  end
  -- grass texture: dashes of the next-darker tint scattered over each zone
  local ts = ri * 17 + 3; local function trnd(n) ts = (ts * 1103515245 + 12345) % 2147483648 return ts % n end
  for i = 1, 110 do local x, y = 6 + trnd(228), 10 + trnd(116); if land:has(x, y) then c:paint({ "x.x", ".x." }, x, y, { x = tint[math.min(4, (zm[2] and zm[2]:has(x, y)) and 3 or ((zm[3] and zm[3]:has(x, y)) and 4 or 2))] }) end end
  -- thread-gold stitched zone borders (embroidery look)
  for zi = 2, 4 do zm[zi]:edge():each(function(x, y) if (x + y) % 4 < 2 and land:has(x, y) then c:px(x, y, "#f5cf6a") end end) end
  -- a river from the north coast to the south coast, and a lake
  local river = c:mask()
  for t = 0, 1, 0.01 do river:add(c:ellipse(math.floor(150 + 34 * math.sin(t * 4.2 + ri) + 0.5), math.floor(4 + t * 126), 1, 1)) end
  river:clip(land); c:fill(river, "#3f8fb0")
  river:each(function(x, y) if (x + y) % 5 == 0 then c:px(x, y, "#a9d6ea") end end)
  local lk = ({ { 60, 118 }, { 206, 112 }, { 120, 30 }, { 36, 40 } })[(ri % 4) + 1]
  local lm = c:ellipse(lk[1], lk[2], 11, 5); lm:clip(land); c:fill(lm, "#3f8fb0"); lm:edge():each(function(x, y) c:px(x, y, "#a9d6ea") end); c:fill(c:rect(lk[1] - 4, lk[2] - 1, lk[1] + 2, lk[2] - 1), "#a9d6ea")
  X.layer(c, "objects")
  c:outline(land, { ol = 1, olx = 1 })
  -- roads (3 px) village -> zones (path progression outward)
  local roadM = c:mask()
  for i = 1, #ZONES - 1 do roadM:add(c:line({ { ZONES[i][1], ZONES[i][2] }, { (ZONES[i][1] + ZONES[i + 1][1]) / 2, (ZONES[i][2] + ZONES[i + 1][2]) / 2 - 8 }, { ZONES[i + 1][1], ZONES[i + 1][2] } }, 3)) end
  roadM:add(c:line({ { ZONES[2][1], ZONES[2][2] }, { 140, 40 }, { 190, 38 } }, 3))
  roadM:add(c:line({ { ZONES[3][1], ZONES[3][2] }, { 170, 120 }, { 120, 118 } }, 3))
  c:fill(roadM, "#f2e4c0")
  roadM:each(function(x, y) if (x + y) % 6 == 0 then c:px(x, y, "#d8c49a") end end)      -- worn cart ruts
  local bridge = roadM:copy():clip(river:copy():grow(1)):grow(1)
  c:fill(bridge, "#b07a45"); bridge:each(function(x, y) if x % 2 == 0 then c:px(x, y, "#8a4f2a") end end)
  -- market village at the start: three houses (kept clear of the first pin spots by 12 px)
  local HOUSES = { { 18, 76 }, { 30, 70 }, { 14, 94 }, { 8, 58 }, { 22, 56 }, { 6, 82 } }
  for _, h in ipairs(HOUSES) do P(c, c:rect(h[1], h[2], h[1] + 9, h[2] + 7), RM.cream, { gloss = false, flat = true }); P(c, c:poly({ { h[1] - 1, h[2] }, { h[1] + 4.5, h[2] - 5 }, { h[1] + 10, h[2] } }), ri % 2 == 0 and RM.red or RM.clay, { gloss = false, flat = true }) end
  for x = 4, 40, 4 do c:px(x, 112, "#8a4f2a") end; c:fill(c:rect(4, 111, 40, 111), "#d9a660")      -- village fence
  -- market square: two striped stalls
  for i = 0, 1 do local x = 20 + i * 14; for dx = 0, 8, 2 do c:fill(c:rect(x + dx, 100, x + dx, 104), "#dd3a2a"); c:fill(c:rect(x + dx + 1, 100, x + dx + 1, 104), "#f2e4c0") end; c:fill(c:rect(x, 105, x + 9, 106), "#8a4f2a") end
  -- region glyphs scattered, skipping pin spots (12 px) and roads' middle
  local seed = ri * 31 + 5; local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
  local placed = 0
  for try = 1, 220 do
    if placed >= 34 then break end
    local x, y = 12 + rnd(216), 18 + rnd(100)
    local ok = land:has(x, y) and land:has(x, y + 6)
    for _, p in ipairs(PINS) do if math.abs(x - p[1]) < 12 and math.abs(y - p[2]) < 12 then ok = false end end
    for _, h in ipairs(HOUSES) do if math.abs(x - h[1]) < 14 and math.abs(y - h[2]) < 14 then ok = false end end; if x < 50 and y > 90 and y < 118 then ok = false end
    if ok and c:get(x, y) ~= "#f2e4c0" then glyph(c, r[6], x, y, 0.8); placed = placed + 1 end
  end
  -- stone outcrops in the hard zone
  for i = 1, 8 do local x, y = 160 + trnd(70), 40 + trnd(70); if zm[4]:has(x, y) and c:get(x, y) ~= "#f2e4c0" then local ok = true; for _, p in ipairs(PINS) do if math.abs(x - p[1]) < 12 and math.abs(y - p[2]) < 12 then ok = false end end; if ok then P(c, c:ellipse(x, y, 4, 2), RM.stone, { gloss = false, cres = 1, deep = 0 }) end end end
  X.layer(c, "detail")
  for _, p in ipairs(PINS) do c:fill(c:rect(p[1] - 5, p[2] - 5, p[1] + 4, p[2] + 4), c:get(p[1] - 7, p[2] - 7) or tint[1]) end   -- flat 10x10 pin spots (20x20 exported)
  X.save(c, "map-" .. code, "scenes", { w = 480, h = 270, cap = 32 })
end
