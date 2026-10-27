-- map-world-up4.lua (from up3: same 19 roads; thin packed-earth tunnels lit by the glows, up2 cavern dressing restored) : map-world (320x180 grid -> 640x360), map-world-regions (flat-colour mask, same size), 14 region maps (240x135 -> 480x270).
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
  local L   -- light field (set by the sky pass, reused to light the tunnels)
  X.layer(c, "sky")
  if mask then c:fill(c:rect(0, 0, 319, 179), "#101010") else
    -- lit cavern rock: light pools from glowers (hub mushroom, regions, lava), stepped + dithered falloff to deep dark at the edges
    -- per-cavern coloured glow: each source has its own tint ramp; falloff is squared so rock between caverns drops to deep dark
    local TINT = {
      warm = { "#2a1a10", "#3d2a1c", "#4a2c1a", "#74462a", "#9a6b3f", "#c9a96e" },
      hub  = { "#2a1a10", "#3d2a1c", "#74462a", "#9a6b3f", "#e8a317", "#f5cf6a" },
      lava = { "#2a1a10", "#4a2c1a", "#5e2f1e", "#a8241f", "#e0501f", "#f08a24" },
      cool = { "#2a1a10", "#3d2a1c", "#25637d", "#3f8fb0", "#a9d6ea", "#eef8f2" },
      pink = { "#2a1a10", "#3d2a1c", "#4e3a8a", "#7b66b4", "#e46a9b", "#f6b8cf" },
      violet = { "#2a1a10", "#3d2a1c", "#4e3a8a", "#7b66b4", "#7a5cc0", "#c3b2ea" },
      moss = { "#2a1a10", "#3d2a1c", "#4a2c1a", "#2f6a3a", "#4f9a45", "#7ab55c" } }
    local RT = { CSA = "lava", EE = "cool", CB = "cool", NWE = "cool", EA = "pink", CA = "violet", OC = "hub", SE = "hub", SA = "moss", WCA = "moss", SEA = "moss", MENA = "lava" }
    local SRC = { { 126, 150, 48, 1.0, "hub" } }
    for _, r in ipairs(REG) do SRC[#SRC + 1] = { r[2] * 0.32, r[3] * 0.32, r[4] * 0.32 * 1.1 + 36, r[1] == "CSA" and 1.0 or 0.85, RT[r[1]] or "warm" } end
    L = function(x, y)
      local best, tint = 0, "warm"
      for _, s in ipairs(SRC) do local dx, dy = (x - s[1]) / s[3], (y - s[2]) / (s[3] * 0.85); local d = math.sqrt(dx * dx + dy * dy)
        if d < 1 then local v = s[4] * (1 - d) ^ 1.6; if v > best then best, tint = v, s[5] end end end
      local ex = math.min(x, 319 - x, y * 1.6, (179 - y) * 1.6) / 40; if ex < 1 then best = best * ex end
      return best, tint
    end
    local B4 = { { 0, 8, 2, 10 }, { 12, 4, 14, 6 }, { 3, 11, 1, 9 }, { 15, 7, 13, 5 } }
    for y = 0, 179 do for x = 0, 319 do
      local strata = math.sin(x / 38 + y / 29) * 4 + math.sin(x / 13) * 3
      local band = math.floor((y + strata) / 9) % 4
      local lv, tn = L(x, y); local RAMP = TINT[tn]
      local l = lv * 7.5 + 1.0 + (band == 1 and 0.25 or (band == 3 and -0.2 or 0))
      local i = math.floor(l); local f = l - i
      if f * 16 > B4[y % 4 + 1][x % 4 + 1] then i = i + 1 end
      i = math.max(1, math.min(#RAMP, i)); c:px(x, y, RAMP[i])
      if band == 2 and math.floor(y + strata) % 9 == 0 and i > 2 then c:px(x, y, RAMP[i - 1]) end
    end end
    local rs = 5; local function rr(n) rs = (rs * 1103515245 + 12345) % 2147483648 return rs % n end
    for i = 1, 90 do local x, y = rr(318), rr(178); if L(x, y) > 0.15 then c:px(x, y, "#5b6470"); c:px(x + 1, y, "#8b8f96") end end
    -- crystal veins: jagged purple seams with glinting nodes (self-lit, so they show in the dark)
    for i = 1, 11 do local x, y = rr(310) + 4, 12 + rr(150); local dx = rr(2) == 0 and 1 or -1
      for k = 0, 10 + rr(14) do c:px(x, y, "#4e3a8a"); if k % 3 == 0 then c:px(x, y - 1, "#7a5cc0") end; x = x + dx; y = y + (rr(3) - 1) end
      c:px(x, y, "#c3b2ea"); c:px(x, y - 1, "#fff3c8") end
    -- ceiling stalactites with cast shadow + drips, floor stalagmites with lit edge
    for x = 0, 319, 7 do local h = 6 + (x * 13) % 10
      c:fill(c:poly({ { x - 2, 0 }, { x + 2, h + 3 }, { x + 4, 0 } }), "#2a1a10")
      c:fill(c:poly({ { x - 3, 0 }, { x, h }, { x + 3, 0 } }), "#4a2c1a"); c:fill(c:poly({ { x - 3, 0 }, { x - 1, h - 2 }, { x - 1, 0 } }), "#74462a"); c:px(x, h - 1, "#9a6b3f")
      if x % 21 == 0 then c:px(x, h + 3, "#a9d6ea"); c:px(x, h + 5, "#3f8fb0"); c:px(x, h + 6, "#3f8fb0") elseif x % 21 == 14 then c:px(x, h + 2, "#3f8fb0") end end
    for x = 3, 319, 11 do local h = 5 + (x * 7) % 8
      c:fill(c:poly({ { x - 1, 179 }, { x + 5, 179 - h + 2 }, { x + 7, 179 } }), "#2a1a10")
      c:fill(c:poly({ { x - 3, 179 }, { x, 179 - h }, { x + 3, 179 } }), "#4a2c1a"); c:fill(c:poly({ { x - 3, 179 }, { x, 179 - h }, { x - 1, 179 } }), "#74462a"); c:px(x, 179 - h, "#9a6b3f")
      if x % 22 == 3 then c:px(x, 179 - h - 3, "#a9d6ea") end end
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
  -- v3: tunnels = the game's 19 ROAD_PAIRS (game/includes/roads.php), each a quadratic curve with the same control point as road_ctrl() in maps.php
  local IDX = {}; for i, r in ipairs(REG) do IDX[r[1]] = i end
  local PAIRS = { { "NA", "CA" }, { "NA", "NWE" }, { "NA", "EA" }, { "CA", "CB" }, { "CA", "SA" }, { "CB", "SA" }, { "SA", "OC" },
    { "NWE", "SE" }, { "NWE", "EE" }, { "SE", "MENA" }, { "EE", "CSA" }, { "MENA", "WCA" }, { "MENA", "CSA" },
    { "WCA", "ESA" }, { "ESA", "CSA" }, { "CSA", "EA" }, { "CSA", "SEA" }, { "EA", "SEA" }, { "SEA", "OC" } }
  local links = {}; for _, p in ipairs(PAIRS) do links[#links + 1] = { IDX[p[1]], IDX[p[2]] } end
  local function bez(l, t) local a, b = REG[l[1]], REG[l[2]]
    local mx, my = (a[2] + b[2]) / 2 + (b[3] - a[3]) * 0.15, (a[3] + b[3]) / 2 - (b[2] - a[2]) * 0.15   -- road_ctrl, 1000x560 space
    local m = 1 - t; return (m * m * a[2] + 2 * m * t * mx + t * t * b[2]) * 0.32 - 0.5, (m * m * a[3] + 2 * m * t * my + t * t * b[3]) * 0.32 - 0.5 end   -- -0.5: pixel i covers [i, i+1), so the thread is centred on the road
  local function pts(l) local o = {}; for k = 0, 24 do local x, y = bez(l, k / 24); o[#o + 1] = { x, y } end return o end
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
    c:fill(c:line(pts(l), 5), "#2a1a10") end   -- v4: 1 px dark casing
  local body, core = c:mask(), c:mask()
  for _, l in ipairs(links) do body:add(c:line(pts(l), 3)); core:add(c:line(pts(l), 1)) end
  body:each(function(x, y) local v = L(x, y); c:px(x, y, v > 0.68 and "#9a6b3f" or (v > 0.3 and "#7a4a1f" or "#4a2c1a")) end)   -- packed earth, lit near a glow
  core:each(function(x, y) local v = L(x, y); c:px(x, y, v > 0.74 and "#fff3c8" or (v > 0.5 and "#f2e4c0" or (v > 0.24 and "#c9a96e" or "#9a6b3f"))) end)   -- mycelium centre line
  for _, l in ipairs(links) do
    for t = 0.12, 0.9, 0.13 do if math.abs(t * 4 - math.floor(t * 4 + 0.5)) > 0.12 then   -- keep clear of the road stops (t = 1/4, 1/2, 3/4)
      local x, y = bez(l, t); x, y = math.floor(x + 0.5), math.floor(y + 0.5); local s = (math.floor(t * 100) % 2) * 2 - 1
      glowdot(c, x, y + s * 4); c:px(x, y + s * 3, "#c9a96e") end end   -- spore node on a tendril, beside the tunnel
  end
  -- Mossbottom: the hub grotto, a giant mushroom lit from within, threads reaching out
  local hub = c:ellipse(126, 150, 10, 6); c:fill(hub, "#4f9a45"); hub:copy():grow(1):cut(hub):each(function(x, y) c:px(x, y, "#2a1a10") end)
  c:fill(c:rect(125, 142, 127, 150), "#f2e4c0"); c:fill(c:ellipse(126, 141, 6, 4), "#dd3a2a"); c:px(123, 140, "#fff3c8"); c:px(129, 141, "#fff3c8"); c:px(126, 138, "#fff3c8"); glowdot(c, 119, 148); glowdot(c, 133, 148)
  for _, t in ipairs({ { 126, 144, 150, 120 }, { 126, 144, 96, 130 }, { 126, 144, 166, 110 } }) do c:fill(c:line({ { t[1], t[2] }, { (t[1] + t[3]) / 2, (t[2] + t[4]) / 2 + 6 }, { t[3], t[4] } }, 1), "#f2e4c0") end
  -- cavern features, kept 9 px off the pin spot
  X.layer(c, "detail")
  local thr = c:mask(); for _, l in ipairs(links) do thr:add(c:line(pts(l), 5)) end   -- v3: keep scenery off the mycelium threads
  local function clear(x, y) for _, d in ipairs({ { 0, 0 }, { -5, 0 }, { 5, 0 }, { -3, -4 }, { 3, -4 }, { 0, -5 }, { 0, -10 }, { -3, -8 }, { 3, -8 }, { 0, 2 }, { -7, 0 }, { 7, 0 } }) do if thr:has(x + d[1], y + d[2]) then return false end end return true end
  local gs = 23; local function grnd(n) gs = (gs * 1103515245 + 12345) % 2147483648 return gs % n end
  for i, r in ipairs(REG) do
    local px, py = r[2] * 0.32, r[3] * 0.32; local n = 0; local fl = FEAT[r[1]]
    local placed = {}; local function apart(x, y) for _, q in ipairs(placed) do if math.abs(q[1] - x) < 8 and math.abs(q[2] - y) < 10 then return false end end return true end
    local rr = math.max(15, math.floor(r[4] * 0.32))   -- v3: search the whole cavern (the threads take the middle)
    for try = 1, 600 do
      if n >= 8 then break end
      local x, y = math.floor(px - rr + grnd(2 * rr + 1)), math.floor(py - rr * 0.8 + grnd(math.floor(rr * 1.6) + 1))
      if RMASK[i]:has(x, y) and RMASK[i]:has(x, y + 3) and RMASK[i]:has(x - 5, y) and RMASK[i]:has(x + 5, y) and (math.abs(x - px) > 9 or math.abs(y - py) > 9) and clear(x, y) and apart(x, y) then feat(c, fl[n % #fl + 1], x, y); n = n + 1; placed[#placed + 1] = { x, y } end
    end
  end
  for i, r in ipairs(REG) do c:fill(c:rect(r[2] * 0.32 - 6, r[3] * 0.32 - 6, r[2] * 0.32 + 5, r[3] * 0.32 + 5), r[5]) end   -- flat 12x12 pin spots
  return c
end
local c = world(false); X.save(c, "map-world-up4", "scenes", { w = 640, h = 360, cap = 40 })
