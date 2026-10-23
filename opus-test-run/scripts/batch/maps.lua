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
local function world(mask)
  local c = X.canvas{ mode = "scene", w = 320, h = 180, out = 2, ol = 1, olx = 1 }
  X.layer(c, "sky")
  if mask then c:fill(c:rect(0, 0, 319, 179), "#101010") else
    c:fill(c:rect(0, 0, 319, 179), "#3f8fb0"); for y = 6, 178, 9 do for x = ((y // 9) % 2) * 11, 319, 22 do c:fill(c:rect(x, y, x + 5, y), "#a9d6ea") end end
    c:fill(c:rect(0, 0, 319, 2), "#25637d"); c:fill(c:rect(0, 177, 319, 179), "#25637d") end
  X.layer(c, "ground")
  local land = c:mask()
  for i, r in ipairs(REG) do
    local m = blob(c, c:mask(), i, r[2] * 0.32, r[3] * 0.32, r[4] * 0.32 * 0.9)
    land:add(m)
    c:fill(m, mask and string.format("#%02x%02x%02x", (i * 61) % 256, (i * 137) % 256, (i * 199) % 256) or r[5])
  end
  if not mask then
    -- Mossbottom hub island
    local hub = c:ellipse(126, 150, 9, 5); land:add(hub); c:fill(hub, "#7ab55c")
    X.layer(c, "objects")
    c:outline(land, { ol = 1, olx = 1 })
    -- mycelium paths between neighbours (3 px, cream)
    local links = { { 1, 5 }, { 5, 7 }, { 7, 11 }, { 2, 3 }, { 3, 9 }, { 9, 8 }, { 8, 10 }, { 1, 2 }, { 4, 9 }, { 6, 8 }, { 11, 13 }, { 12, 13 }, { 13, 14 }, { 4, 10 } }
    for _, l in ipairs(links) do
      local a, b = REG[l[1]], REG[l[2]]
      c:fill(c:line({ { a[2] * 0.32, a[3] * 0.32 }, { b[2] * 0.32, b[3] * 0.32 } }, 3), "#f2e4c0")
    end
    X.layer(c, "detail")
    for i, r in ipairs(REG) do   -- pin spot stays flat: glyph sits 11 px off-centre
      local gx, gy = r[2] * 0.32 + 11, r[3] * 0.32 + 6
      glyph(c, r[6], gx, gy, 1)
      c:fill(c:rect(r[2] * 0.32 - 6, r[3] * 0.32 - 6, r[2] * 0.32 + 5, r[3] * 0.32 + 5), r[5])   -- re-flatten the 12x12 pin spot to the region colour
    end
    c:fill(c:rect(0, 0, 0, 0), "#25637d")
  end
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
  X.layer(c, "sky"); c:fill(c:rect(0, 0, 239, 134), "#3f8fb0"); for y = 6, 134, 9 do for x = ((y // 9) % 2) * 11, 239, 22 do c:fill(c:rect(x, y, x + 5, y), "#a9d6ea") end end
  X.layer(c, "ground")
  local land = c:mask(); for x = 0, 239 do land:rect(x, 6 + math.floor(3 * math.sin(x / 13 + ri) + 0.5), x, 128 - math.floor(3 * math.sin(x / 9 + ri) + 0.5)) end
  land:cut(c:rect(0, 0, 3, 134)):cut(c:rect(236, 0, 239, 134))
  c:fill(land, tint[1])
  for zi = 4, 1, -1 do   -- hardest zone painted first so gentle zones overlap toward the village
    local z = ZONES[zi]; local m = c:mask()
    m:add(c:ellipse(z[1], z[2], z[3], 30)); m:add(c:ellipse(z[1] + 8, z[2] - 14, z[3] * 0.6, 20)); m:clip(land)
    c:fill(m, tint[zi])
  end
  X.layer(c, "objects")
  c:outline(land, { ol = 1, olx = 1 })
  -- roads (3 px) village -> zones (path progression outward)
  for i = 1, #ZONES - 1 do c:fill(c:line({ { ZONES[i][1], ZONES[i][2] }, { (ZONES[i][1] + ZONES[i + 1][1]) / 2, (ZONES[i][2] + ZONES[i + 1][2]) / 2 - 8 }, { ZONES[i + 1][1], ZONES[i + 1][2] } }, 3), "#f2e4c0") end
  c:fill(c:line({ { ZONES[2][1], ZONES[2][2] }, { 140, 40 }, { 190, 38 } }, 3), "#f2e4c0")
  -- market village at the start: three houses (kept clear of the first pin spots by 12 px)
  for _, h in ipairs({ { 18, 76 }, { 30, 70 }, { 14, 94 } }) do P(c, c:rect(h[1], h[2], h[1] + 9, h[2] + 7), RM.cream, { gloss = false, flat = true }); P(c, c:poly({ { h[1] - 1, h[2] }, { h[1] + 4.5, h[2] - 5 }, { h[1] + 10, h[2] } }), ri % 2 == 0 and RM.red or RM.clay, { gloss = false, flat = true }) end
  -- region glyphs scattered, skipping pin spots (12 px) and roads' middle
  local seed = ri * 31 + 5; local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
  local placed = 0
  for try = 1, 80 do
    if placed >= 24 then break end
    local x, y = 12 + rnd(216), 18 + rnd(100)
    local ok = land:has(x, y) and land:has(x, y + 6)
    for _, p in ipairs(PINS) do if math.abs(x - p[1]) < 12 and math.abs(y - p[2]) < 12 then ok = false end end
    for _, h in ipairs({ { 18, 76 }, { 30, 70 }, { 14, 94 } }) do if math.abs(x - h[1]) < 14 and math.abs(y - h[2]) < 14 then ok = false end end
    if ok and c:get(x, y) ~= "#f2e4c0" then glyph(c, r[6], x, y, 0.8); placed = placed + 1 end
  end
  X.layer(c, "detail")
  for _, p in ipairs(PINS) do c:fill(c:rect(p[1] - 5, p[2] - 5, p[1] + 4, p[2] + 4), c:get(p[1] - 7, p[2] - 7) or tint[1]) end   -- flat 10x10 pin spots (20x20 exported)
  X.save(c, "map-" .. code, "scenes", { w = 480, h = 270, cap = 32 })
end
