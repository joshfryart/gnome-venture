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
-- ===== EA fit: underground blossom grotto refit to tools/map_layout.lua (480x270 layout -> 240x135 grid, /2) =====
do
  local LAY = dofile(os.getenv("GV_ROOT") .. "tools/map_layout.lua").regions.EA
  local function h(v) return math.floor(v / 2 + 0.5) end
  local TX, TY = h(LAY.town.x), h(LAY.town.y)
  local CLR = {}; for _, q in ipairs(LAY.clear) do CLR[#CLR + 1] = { q[1] / 2, q[2] / 2, q[3] / 2 } end
  CLR[#CLR + 1] = { LAY.pin.x / 2, LAY.pin.y / 2, LAY.pin.r / 2 }
  for _, st in ipairs(LAY.stops) do CLR[#CLR + 1] = { st.x / 2, st.y / 2, st.r / 2 } end
  local ri, r = 12, REG[12]
  local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2, ol = 1, olx = 1 }
  X.layer(c, "sky"); rockbg(c, 240, 135)
  X.layer(c, "ground")
  local land = c:mask(); for x = 0, 239 do land:rect(x, 6 + math.floor(3 * math.sin(x / 13 + ri) + 0.5), x, 128 - math.floor(3 * math.sin(x / 9 + ri) + 0.5)) end
  land:cut(c:rect(0, 0, 3, 134)):cut(c:rect(236, 0, 239, 134))
  -- paths from the layout (roads wide, trails narrow); exits pushed to the frame edge
  local function edgept(e) local x, y = h(e.x), h(e.y); if e.side == "W" then return { 0, y } elseif e.side == "E" then return { 239, y } elseif e.side == "N" then return { x, 0 } else return { x, 134 } end end
  local roadM, trailM = c:mask(), c:mask()
  for ri2, rd in ipairs(LAY.roads) do local pts = {}; for _, p in ipairs(rd.pts) do pts[#pts + 1] = { h(p[1]), h(p[2]) } end
    for _, e in ipairs(LAY.exits) do if e.road == ri2 - 1 then pts[#pts + 1] = edgept(e) end end
    roadM:add(c:line(pts, 3)) end
  for _, t in ipairs(LAY.trails) do trailM:add(c:line({ { h(t[1][1]), h(t[1][2]) }, { h(t[2][1]), h(t[2][2]) } }, 2)) end
  local pathM = roadM:copy():add(trailM)
  local function dseg(px, py, ax, ay, bx, by) local dx, dy = bx - ax, by - ay; local t = ((px - ax) * dx + (py - ay) * dy) / math.max(1e-6, dx * dx + dy * dy); t = math.max(0, math.min(1, t)); local ex, ey = ax + t * dx - px, ay + t * dy - py; return math.sqrt(ex * ex + ey * ey) end
  local SEGS = {}
  for _, rd in ipairs(LAY.roads) do for k = 1, #rd.pts - 1 do SEGS[#SEGS + 1] = { rd.pts[k][1] / 2, rd.pts[k][2] / 2, rd.pts[k + 1][1] / 2, rd.pts[k + 1][2] / 2 } end end
  for _, t in ipairs(LAY.trails) do SEGS[#SEGS + 1] = { t[1][1] / 2, t[1][2] / 2, t[2][1] / 2, t[2][2] / 2 } end
  for _, e in ipairs(LAY.exits) do local q = edgept(e); SEGS[#SEGS + 1] = { e.x / 2, e.y / 2, q[1], q[2] } end
  local function pathd(x, y) local m = 1e9; for _, s in ipairs(SEGS) do local d = dseg(x, y, s[1], s[2], s[3], s[4]); if d < m then m = d end end; return m end
  local function clr(x, y, pad) for _, q in ipairs(CLR) do local dx, dy = x - q[1], y - q[2]; if dx * dx + dy * dy < (q[3] + pad) ^ 2 then return true end end; return false end
  -- underground stream: stays west of the market, bridged where paths cross
  local river = c:mask()
  for t = 0, 1, 0.01 do river:add(c:ellipse(math.floor(118 + 20 * math.sin(t * 4.2 + ri) + 0.5), math.floor(4 + t * 126), 1, 1)) end
  river:clip(land)
  -- pick light-source spots near the town and stops, outside every keep-clear circle and off the paths
  local PAG, COR, used = {}, {}, {}
  local function okspot(x, y, pad)
    if x < 8 or x > 231 or y < 22 or y > 124 or not land:has(x, y) then return false end
    if clr(x, y, pad) or clr(x, y - 9, pad) or clr(x, y - 16, 2) or pathd(x, y) < pad + 1 or pathd(x, y - 10, 0) < pad or river:has(x, y) then return false end
    for _, u in ipairs(used) do if math.abs(x - u[1]) < 13 and math.abs(y - u[2]) < 15 then return false end end
    return true
  end
  local anchors = { { TX, TY, 11 } }; for _, st in ipairs(LAY.stops) do if st.kind ~= "exit" then anchors[#anchors + 1] = { st.x / 2, st.y / 2, st.r / 2 } end end
  for ai, a in ipairs(anchors) do
    for k = 0, 23 do local ang = (k * 37 + ai * 71) % 360 * math.pi / 180
      for dd = a[3] + 7, a[3] + 16, 3 do local x, y = math.floor(a[1] + math.cos(ang) * dd + 0.5), math.floor(a[2] + math.sin(ang) * dd * 0.8 + 0.5)
        if okspot(x, y, 6) then used[#used + 1] = { x, y }; if ai % 2 == 1 then PAG[#PAG + 1] = { x, y } else COR[#COR + 1] = { x, y } end; goto nexta end end end
    ::nexta::
  end
  for ai, a in ipairs(anchors) do if ai > 1 then for k = 0, 23 do local ang = (k * 53 + ai * 29) % 360 * math.pi / 180
    local x, y = math.floor(a[1] + math.cos(ang) * (a[3] + 10) + 0.5), math.floor(a[2] + math.sin(ang) * (a[3] + 10) * 0.8 + 0.5)
    if okspot(x, y, 6) then used[#used + 1] = { x, y }; COR[#COR + 1] = { x, y }; break end end end end
  local lk = { 60, 112 }
  for _ = 1, 40 do if okspot(lk[1], lk[2], 9) then break end; lk[1] = lk[1] + 7; if lk[1] > 220 then lk[1] = 30; lk[2] = lk[2] - 6 end end
  local SRC = { { TX, TY - 2, 44 } }
  for _, p in ipairs(PAG) do SRC[#SRC + 1] = { p[1], p[2] - 4, 34 } end
  for _, p in ipairs(COR) do SRC[#SRC + 1] = { p[1], p[2] - 3, 25 } end
  -- falloff: pink -> magenta -> a thin violet -> umber -> rock
  local BAND = { { 32, "#f6b8cf" }, { 23, "#e46a9b" }, { 16, "#7a5cc0" }, { 9, "#5e2f1e" }, { 3, "#4a2c1a" }, { -1e9, "#3d2a1c" } }
  local DK = { ["#f6b8cf"] = "#e46a9b", ["#e46a9b"] = "#7a5cc0", ["#7a5cc0"] = "#5e2f1e", ["#5e2f1e"] = "#4a2c1a", ["#4a2c1a"] = "#3d2a1c", ["#3d2a1c"] = "#2a1a10" }
  local light = {}
  local function band(L) for _, b in ipairs(BAND) do if L >= b[1] then return b[2] end end end
  for y = 0, 134 do for x = 0, 239 do if land:has(x, y) then
    local L = -1e9
    for _, s in ipairs(SRC) do local dx, dy = x - s[1], (y - s[2]) * 1.4; local v = s[3] - math.sqrt(dx * dx + dy * dy); if v > L then L = v end end
    local e = math.min(y - 6, 128 - y, x - 4, 235 - x); if e < 14 then L = L - (14 - e) * 1.2 end
    light[y * 240 + x] = L
    local d = ((x + y) % 2 == 0) and 1.5 or -1.5
    c:px(x, y, band(L + d))
  end end end
  local ts = ri * 17 + 3; local function trnd(n) ts = (ts * 1103515245 + 12345) % 2147483648 return ts % n end
  for i = 1, 170 do local x, y = 6 + trnd(228), 10 + trnd(116); if land:has(x, y) and not clr(x, y, 2) then local dd = DK[c:get(x, y)]; if dd then c:paint({ "x.x", ".x." }, x, y, { x = dd }) end end end
  c:fill(river, "#25637d"); river:each(function(x, y) local L = light[y * 240 + x] or -99; if (x + y) % 5 == 0 then c:px(x, y, L >= 18 and "#f6b8cf" or "#3f8fb0") end end)
  local lm = c:ellipse(lk[1], lk[2], 9, 4); lm:clip(land); c:fill(lm, "#25637d"); lm:edge():each(function(x, y) c:px(x, y, "#3f8fb0") end); c:fill(c:rect(lk[1] - 4, lk[2] - 1, lk[1] + 2, lk[2] - 1), "#f6b8cf")
  X.layer(c, "objects")
  c:outline(land, { ol = 1, olx = 1 })
  -- path casing then fill; colour follows the light
  local casing = pathM:copy():grow(1)
  c:fill(casing, "#2a1a10")
  local function pathpx(x, y) local L = light[y * 240 + x] or -99; local a, b = "#c9a96e", "#9a6b3f"; if L >= 24 then a, b = "#f2e4c0", "#d8c49a" elseif L < 6 then a, b = "#9a6b3f", "#5e2f1e" end; c:px(x, y, (x + y) % 6 == 0 and b or a) end
  pathM:each(pathpx)
  local bridge = pathM:copy():clip(river:copy():grow(1)):grow(1)
  c:fill(bridge, "#8a4f2a"); bridge:each(function(x, y) if x % 2 == 0 then c:px(x, y, "#b07a45") end end)
  -- market plaza: flat floor under the pin, ringed by lantern-lit houses
  local plaza = c:ellipse(TX, TY, 11, 10); c:fill(plaza:copy():grow(1), "#9a6b3f"); c:fill(plaza, "#d8c49a")
  local HOUSES = {}
  for k = 0, 47 do local ang = k * 7.5 * math.pi / 180; local rr = 16 + (k % 3) * 3; local hx, hy = math.floor(TX + math.cos(ang) * rr + 0.5) - 4, math.floor(TY + math.sin(ang) * rr * 0.85 + 0.5) - 3
    local ok = true; for dx = 0, 9 do for dy = -5, 7 do if casing:has(hx + dx, hy + dy) or plaza:has(hx + dx, hy + dy) then ok = false end end end
    for _, o in ipairs(HOUSES) do if math.abs(o[1] - hx) < 12 and math.abs(o[2] - hy) < 13 then ok = false end end
    if ok then for _, st in ipairs(LAY.stops) do local dx, dy = hx + 4 - st.x / 2, hy + 2 - st.y / 2; if dx * dx + dy * dy < (st.r / 2 + 6) ^ 2 then ok = false end end; for _, u in ipairs(used) do if math.abs(hx + 4 - u[1]) < 10 and math.abs(hy - u[2]) < 14 then ok = false end end end
    if ok then HOUSES[#HOUSES + 1] = { hx, hy } end end
  for _, hh in ipairs(HOUSES) do P(c, c:rect(hh[1], hh[2], hh[1] + 9, hh[2] + 7), RM.cream, { gloss = false, flat = true }); P(c, c:poly({ { hh[1] - 1, hh[2] }, { hh[1] + 4.5, hh[2] - 5 }, { hh[1] + 10, hh[2] } }), RM.red, { gloss = false, flat = true }); c:fill(c:rect(hh[1] + 3, hh[2] + 3, hh[1] + 5, hh[2] + 5), "#f5cf6a"); c:px(hh[1] + 4, hh[2] + 4, "#fff3c8") end
  local function bigpagoda(x, y)
    for i = 0, 2 do local w = 5 - i; c:fill(c:rect(x - w + 1, y - 4 - i * 5, x + w - 1, y - i * 5), "#f2e4c0"); c:fill(c:rect(x - w - 1, y - 5 - i * 5, x + w + 1, y - 4 - i * 5), "#dd3a2a"); c:px(x - w - 2, y - 4 - i * 5, "#dd3a2a"); c:px(x + w + 2, y - 4 - i * 5, "#dd3a2a")
      c:px(x - w - 1, y - 3 - i * 5, "#f5cf6a"); c:px(x - w - 1, y - 2 - i * 5, "#f08a24"); c:px(x + w + 1, y - 3 - i * 5, "#f5cf6a"); c:px(x + w + 1, y - 2 - i * 5, "#f08a24") end
    c:fill(c:rect(x, y - 18, x, y - 15), "#b07a10"); c:fill(c:rect(x - 1, y - 2, x + 1, y), "#8a4f2a"); c:px(x, y - 8, "#fff3c8")
  end
  local function gcoral(x, y) coral(c, x, y, 9, "#e46a9b"); coral(c, x + 1, y, 6, "#f6b8cf"); c:px(x, y - 9, "#fff3c8"); c:px(x - 3, y - 7, "#fff3c8"); c:px(x + 3, y - 7, "#fff3c8") end
  for _, p in ipairs(PAG) do bigpagoda(p[1], p[2]) end
  for _, p in ipairs(COR) do gcoral(p[1], p[2]) end
  local seed = ri * 31 + 5; local function rnd(n) seed = (seed * 1103515245 + 12345) % 2147483648 return seed % n end
  local function free(x, y)
    if not (land:has(x, y) and land:has(x, y + 6)) then return false end
    if clr(x, y, 4) or clr(x, y - 8, 3) or pathd(x, y) < 4 or pathd(x, y - 6) < 3 then return false end
    for _, hh in ipairs(HOUSES) do if math.abs(x - hh[1] - 4) < 10 and math.abs(y - hh[2]) < 12 then return false end end
    for _, u in ipairs(used) do if math.abs(x - u[1]) < 9 and math.abs(y - u[2]) < 12 then return false end end
    if river:has(x, y) or lm:has(x, y) or lm:has(x, y + 2) then return false end
    return true
  end
  local placed = 0
  for try = 1, 900 do
    if placed >= 42 then break end
    local x, y = 10 + rnd(220), 20 + rnd(100)
    if free(x, y) then
      local L = light[y * 240 + x] or -99
      if L >= 20 then shroom(c, x, y, 1, "#f6b8cf")
      elseif L >= 10 then if placed % 2 == 0 then coral(c, x, y, 7, "#e46a9b") else shroom(c, x, y, 1, "#e46a9b") end
      elseif L >= 0 then stalag(c, x, y, 8, "#5b6470", "#3d2a1c")
      else if placed % 3 == 0 then crystalc(c, x, y, 7, "#7a5cc0") else stalag(c, x, y, 10, "#4a2c1a", "#2a1a10") end end
      used[#used + 1] = { x, y }; placed = placed + 1
    end
  end
  X.layer(c, "detail")
  for i = 1, 60 do local x, y = 6 + trnd(228), 10 + trnd(116); if land:has(x, y) and (light[y * 240 + x] or -99) >= 16 and not casing:has(x, y) and not clr(x, y, 0) and c:get(x, y) ~= "#f2e4c0" then c:px(x, y, "#f6b8cf") end end
  -- rock fringes; skip where a path leaves the frame
  local function nearexit(x, top) for _, e in ipairs(LAY.exits) do if (top and e.side == "N" or (not top) and e.side == "S") and math.abs(x - h(e.x)) < 8 then return true end end; return false end
  for x = 2, 239, 6 do if not nearexit(x, true) then local hh = 9 + (x * 13) % 8; c:fill(c:poly({ { x - 3, 0 }, { x, hh }, { x + 3, 0 } }), "#2a1a10"); c:px(x, hh - 2, "#4a2c1a") end end
  for x = 5, 239, 9 do if not nearexit(x, false) then local hh = 6 + (x * 7) % 6; c:fill(c:poly({ { x - 3, 134 }, { x, 134 - hh }, { x + 3, 134 } }), "#2a1a10") end end
  -- repaint exit spurs on top so they read through the fringe
  for _, e in ipairs(LAY.exits) do local q = edgept(e); local m = c:line({ { h(e.x), h(e.y) }, q }, 3); c:fill(m:copy():grow(1), "#2a1a10"); m:each(pathpx) end
  X.save(c, "map-EA-fit", "scenes", { w = 480, h = 270, cap = 32 })
end
