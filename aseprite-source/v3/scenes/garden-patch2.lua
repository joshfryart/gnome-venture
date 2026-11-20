-- garden-patch2: calmer refinement of garden-patch.lua (Hearth Pop v3). 240x135 grid, x2 = 480x270.
-- Same 17 spots, same patchwork idea, but: flat low-contrast ground with one shared warm undertone, seams that
-- step through three flat tones (no speckle), texture only as a few larger shapes per patch (flower drift, tilled
-- bed, stone pad, reed bank), the kitchen as the hero on the lightest flagstones, one wide cream path that snakes
-- through all three rows with rounded turns, and a stream from the rain barrel under a plank bridge into the pond.
-- Run: AppRun -b --script-param out=<dir>/ --script-param look=golden --script garden-patch2.lua
-- quirk: a gnome naps on the compost heap with his hat over his face.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local ok, HP = pcall(dofile, (d or ".") .. "/../lib/hp.lua")
if not ok then HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua") end
local P = HP.P
local out = app.params.out or "./"
local look = app.params.look or "golden"
local c = HP.canvas{ w = 240, h = 135, scale = 2, name = "garden-patch2-" .. look }
local sin, floor, sqrt = math.sin, math.floor, math.sqrt
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local px = function(x, y, hex) c:px(x, y, hex) end

local function hexrgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function lerp(a, b, t)
  local r1, g1, b1 = hexrgb(a); local r2, g2, b2 = hexrgb(b)
  return string.format("#%02x%02x%02x", floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
end
local function hsh(x, y)
  local h = (x * 374761393 + y * 668265263) & 0xffffffff
  h = ((h ~ (h >> 13)) * 1274126177) & 0xffffffff
  return (h ~ (h >> 16)) % 100
end

------------------------------------------------------------ LOOK (golden only is tuned; others fall back to it)
local K = {
  sky = { P.sky.shade, "#e9a8ae", "#f9cdd2", "#ffe3a0", "#fff0c4" }, skyw = { 3, 3, 3, 3, 4 },
  sun = { 196, 38, P.gold.base, P.gold.hi }, cloud = { P.cream, P.petal.hi },
  far1 = "#c3b0e0", far2 = "#ab98c8",
}
local WARM = "#f0c88a"   -- the shared undertone every ground colour leans toward
local DUSKSH = "#5a4660" -- cool violet used for contact shadows (hue-shifted, never black)
local ROOF = { hi = P.ember.hi, base = P.ember.base, shade = P.ember.shade, deep = P.ember.deep }
local PLASTER = { hi = P.cream, base = "#f6dfae", shade = P.wood.hi, deep = P.wood.base }
local WIN = { hi = P.sky.hi, base = P.sea.hi, shade = P.sea.base, deep = P.sea.shade }
local LEAFD = { hi = P.moss.base, base = P.moss.shade, shade = P.moss.deep, deep = "#1f3f3a" }

------------------------------------------------------------ SKY AND BACK HEDGE
c:stripes(0, 36, K.sky, K.skyw)
c:fillMask(E(K.sun[1], K.sun[2], 8, 8), K.sun[3]) c:fillMask(E(K.sun[1] - 1, K.sun[2] - 1, 5, 5), K.sun[4])
c:cloud(36, 14, 30, K.cloud[1], K.cloud[2]) c:cloud(150, 10, 22, K.cloud[1], K.cloud[2])
c:terrain(function(x) return 28 + 4 * sin(x / 29 + .5) + 2 * sin(x / 11) end, K.far1)
c:terrain(function(x) return 33 + 3 * sin(x / 21 + 2) + 2 * sin(x / 8) end, K.far2)
local hedge0 = HP.mask()
for x = 0, 239, 12 do hedge0:add(E(x + 5, 35, 8, 4)) end
c:fillMask(hedge0, "#5f9a55") c:fillMask(hedge0:copy():shift(-1, -1), "#7cb860")

------------------------------------------------------------ PATCHWORK GROUND
-- zone seeds: {key, cx, cy, weight, style}
local ZONES = {
  { "greenhouse", 20, 54, 1, "lawn" }, { "tailor", 58, 54, 1, "cobble" }, { "kitchen", 120, 52, 1.35, "flag" }, { "tool_shed", 183, 54, 1, "dirt" }, { "compost_bin", 221, 55, 1, "loam" },
  { "beehive", 24, 88, 1, "meadow" }, { "root_cellar", 60, 86, 1, "furrow" }, { "worm_farm", 99, 88, 1, "soil" }, { "ladybird_lodge", 141, 86, 1, "tall" }, { "snail_jar", 181, 88, 1, "moss" }, { "rain_barrel", 218, 86, 1, "wet" },
  { "fence", 24, 119, 1, "lawn2" }, { "quail_coop", 62, 118, 1, "sand" }, { "silk_shelf", 100, 120, 1, "shade" }, { "tortoise_run", 140, 118, 1, "sun" }, { "butterfly_bush", 180, 120, 1, "bed" }, { "frog_pond", 219, 118, 1, "lawn2" },
}
-- base colours: light, mid-saturation, all pulled 14% toward WARM so neighbours share an undertone.
local BASE = {
  lawn = "#a8cc70", lawn2 = "#9cc56a", cobble = "#d9c8a0", flag = "#ecdfba", dirt = "#d6b886", loam = "#bc9a6e",
  meadow = "#a3c96c", furrow = "#a8c86c", soil = "#c2a274", tall = "#95c064", moss = "#8fbe72", wet = "#c9c3b6",
  sand = "#ead49c", shade = "#8ab864", sun = "#b8d474", bed = "#a6ca6e",
}
for k, v in pairs(BASE) do BASE[k] = lerp(v, WARM, .14) end
local ZI, ZM = {}, {}   -- per pixel: owning zone, depth into it (distance from the seam)
local seeds = {}
for i, z in ipairs(ZONES) do seeds[i] = { z[2], z[3], z[4] } end
for y = 35, 134 do
  for x = 0, 239 do
    local wx = x + 5 * sin(y / 8 + x / 37)
    local wy = y + 4 * sin(x / 10 + y / 29)
    local d1, d2, i1, i2 = 1e9, 1e9, 0, 0
    for i, s in ipairs(seeds) do
      local dx, dy = (wx - s[1]) * .8, (wy - s[2]) * 1.45
      local dd = sqrt(dx * dx + dy * dy) / s[3]
      if dd < d1 then d2, i2, d1, i1 = d1, i1, dd, i elseif dd < d2 then d2, i2 = dd, i end
    end
    local m = d2 - d1
    local a, b = BASE[ZONES[i1][5]], BASE[ZONES[i2][5]]
    local col = a
    if m < 1.6 then col = lerp(a, b, .5) elseif m < 3.2 then col = lerp(a, b, .25) end   -- three flat steps, no texture in the seam
    px(x, y, col)
    ZI[y * 240 + x], ZM[y * 240 + x] = i1, m
  end
end
-- is (x,y) solidly inside zone zi (past the seam band)?
local function inz(zi, x, y, pad) local k = y * 240 + x; return x >= 0 and x < 240 and y >= 37 and y < 135 and ZI[k] == zi and ZM[k] >= (pad or 4) end
local function zidx(key) for i, z in ipairs(ZONES) do if z[1] == key then return i end end end
local function zpx(zi, x, y, col) if inz(zi, x, y) then px(x, y, col) end end

------------------------------------------------------------ CALM TEXTURE: sparse, ordered marks, close in value to the base
for zi, z in ipairs(ZONES) do
  local st = z[5]; local b = BASE[st]
  local hi, lo = lerp(b, "#fff4d6", .28), lerp(b, DUSKSH, .12)
  if st == "cobble" or st == "flag" or st == "wet" then
    -- separate stones on a loose grid (a few larger shapes, not a wall of mortar)
    local sw, sh = (st == "flag") and 10 or 8, (st == "flag") and 5 or 4
    local light = lerp(b, "#fff4d6", .35)
    for gy = 37, 134, sh + 2 do for gx = 0, 239, sw + 2 do
      local ox = ((gy // (sh + 2)) % 2) * ((sw + 2) // 2)
      if hsh(gx, gy) < 62 then
        local x0, y0 = gx + ox - 4, gy
        local okk = true
        for yy = y0, y0 + sh do for xx = x0, x0 + sw do if not inz(zi, xx, yy) then okk = false end end end
        if okk then
          R(x0 + 1, y0, x0 + sw - 1, y0 + sh - 1, light)
          R(x0 + 1, y0 + sh, x0 + sw - 1, y0 + sh, lo) R(x0 + sw, y0 + 1, x0 + sw, y0 + sh - 1, lo)
        end
      end
    end end
  elseif st == "soil" or st == "loam" then
    for y = 38, 134, 4 do for x = 0, 239 do if hsh(x // 9, y) > 18 then zpx(zi, x, y, lo) end end end
  elseif st == "dirt" or st == "sand" then
    for gy = 37, 134, 7 do for gx = 0, 239, 9 do
      if hsh(gx, gy) < 35 then local x, y = gx + hsh(gy, gx) % 6, gy + hsh(gx + 3, gy) % 4; zpx(zi, x, y, lo) zpx(zi, x + 1, y, lo) zpx(zi, x, y - 1, hi) end
    end end
  else   -- grass family: a few lit tufts on a loose grid
    local dens = ({ tall = 70, meadow = 45, shade = 30, moss = 30 })[st] or 38
    for gy = 39, 134, 6 do for gx = 0, 239, 8 do
      if hsh(gx, gy) < dens then
        local x, y = gx + hsh(gy, gx) % 5, gy + hsh(gx + 1, gy) % 3
        if st == "tall" then zpx(zi, x, y, lo) zpx(zi, x, y - 1, lo) zpx(zi, x + 1, y - 2, hi)
        elseif st == "moss" then zpx(zi, x, y, hi) zpx(zi, x + 1, y, hi) zpx(zi, x - 1, y + 1, lo)
        else zpx(zi, x, y, hi) zpx(zi, x + 1, y - 1, hi) zpx(zi, x + 2, y, hi) end
      end
    end end
  end
end

------------------------------------------------------------ FEATURE SHAPES (one or two per patch, larger and calm)
-- a drift = a soft leafy clump (one flat darker-green shape) dotted with 2x2 blooms: reads as one shape, not speckle
local function drift(cx, cy, rx, ry, cols)
  local clump = E(cx, cy, rx, ry)
  c:fillMask(clump, lerp(BASE.meadow, P.moss.shade, .45))
  c:fillMask(clump:copy():shift(0, 1):cut(clump), lerp(BASE.meadow, DUSKSH, .3))
  local i = 0
  for y = cy - ry + 1, cy + ry - 2, 3 do for x = cx - rx + 2 + ((y // 3) % 2) * 2, cx + rx - 2, 4 do
    if clump:shrink(1):has(x, y) and clump:shrink(1):has(x + 1, y + 1) then
      i = i + 1
      local col = cols[(i % #cols) + 1]
      px(x, y, col) px(x + 1, y, col) px(x, y + 1, col) px(x + 1, y + 1, lerp(col, DUSKSH, .25))
    end
  end end
end
-- meadow flower drift beside the beehive
drift(9, 83, 8, 5, { P.petal.base, P.cream, P.gold.hi })
-- tilled bed beside the root cellar
do
  local bx0, bx1 = 78, 88
  for y = 79, 91 do for x = bx0, bx1 do px(x, y, (y % 3 == 0) and "#a98559" or "#c4a174") end end
  for y = 80, 91, 3 do for x = bx0 + 1, bx1 - 1, 3 do px(x, y - 1, "#7cc35a") end end
  R(bx0, 92, bx1, 92, "#8f6e4c")
end
-- stone pad under the rain barrel
do
  local pad = E(218, 91, 13, 4)
  c:fillMask(pad, lerp(BASE.wet, "#fff4d6", .25))
  R(205, 91, 231, 91, lerp(BASE.wet, DUSKSH, .15)) R(212, 87, 212, 95, lerp(BASE.wet, DUSKSH, .15)) R(224, 87, 224, 95, lerp(BASE.wet, DUSKSH, .15))
end
-- dust bath beside the quail coop
c:fillMask(E(80, 120, 5, 2), lerp(BASE.sand, DUSKSH, .1)) px(78, 119, "#fff4d6")
-- butterfly flower drift
drift(164, 117, 6, 4, { P.dusk.hi, P.petal.hi, P.cream })
-- shade patch: a mulberry tree's dappled shadow (flat ellipse, one tone)
c:fillMask(E(118, 112, 9, 3), lerp(BASE.shade, DUSKSH, .12))

------------------------------------------------------------ STREAM (under the path; a plank bridge crosses it)
local SX = function(y) return 225 + floor(2.2 * sin((y - 88) / 5)) - floor((y - 88) / 6) end
for y = 86, 113 do local x = SX(y); R(x - 2, y, x + 2, y, P.sea.shade) R(x - 1, y, x + 1, y, P.sea.base) if y % 3 == 0 then px(x - 1, y, P.sea.hi) end end

------------------------------------------------------------ THE PATH: one wide cream ribbon, three lanes, rounded turns
local PATH, PATHE = "#f6e8c2", "#d2b78a"
local pathM = HP.mask()
do
  local pts = {}
  local function add(x, y) pts[#pts + 1] = { x, y } end
  local function arc(cx, cy, r, a0, a1) for i = 0, 8 do local a = a0 + (a1 - a0) * i / 8; add(cx + r * math.cos(a), cy + r * sin(a)) end end
  local L0 = function(x) return 69 + 1.5 * sin(x / 13) end
  local L1 = function(x) return 99 + 1.5 * sin(x / 11) end
  local L2 = function(x) return 129 + 1.2 * sin(x / 12) end
  local r = 6
  for x = 0, 229 - r, 2 do add(x, L0(x)) end
  arc(229 - r, 69 + r, r, -math.pi / 2, 0)
  for y = 69 + r, 99 - r, 2 do add(229, y) end
  arc(229 - r, 99 - r, r, 0, math.pi / 2)
  for x = 229 - r, 5 + r, -2 do add(x, L1(x)) end
  arc(5 + r, 99 + r, r, -math.pi / 2, -math.pi)
  for y = 99 + r, 129 - r, 2 do add(5, y) end
  arc(5 + r, 129 - r, r, math.pi, math.pi / 2)
  for x = 5 + r, 239, 2 do add(x, L2(x)) end
  pathM = c:line(pts, 4)
  pathM:add(c:rect(116, 63, 124, 68))   -- the kitchen doorstep joins the lane
  c:fillMask(pathM:shift(0, 1):cut(pathM), PATHE)   -- lower edge only (light from upper left)
  c:fillMask(pathM, PATH)
  for i = 1, #pts, 7 do local p = pts[i]; local x, y = floor(p[1] + .5), floor(p[2] + .5); if pathM:has(x + 1, y) then px(x, y, "#e6d3a6") end end   -- a few worn pebbles
end
-- plank bridge where the stream meets the middle lane
do
  local x = SX(99)
  local deck = c:rect(x - 4, 96, x + 4, 101)
  c:rim(deck, P.ink)
  for xx = x - 4, x + 4 do R(xx, 96, xx, 101, (xx % 2 == 0) and P.wood.hi or P.wood.base) end
  R(x - 4, 101, x + 4, 101, P.wood.shade)
end

------------------------------------------------------------ helpers for buildings
local boxes = {}
local function shadeUnder(m, t) m:each(function(x, y) local v = c:get(x, y); if v then px(x, y, lerp(v, DUSKSH, t)) end end) end
local function shadow(x, y, rx) shadeUnder(E(x, y, rx, 2), .26) end
local function obj(parts)
  local u = HP.mask()
  for _, p in ipairs(parts) do u:add(p[1]:copy()) end
  c:rim(u, P.ink)
  for _, p in ipairs(parts) do c:part(p[1], p[2], p[3] or {}) end
end

------------------------------------------------------------ BACK ROW (feet y 62)
local function greenhouse(x, y)
  local body = c:rect(x - 13, y - 14, x + 13, y)
  local roof = c:poly{ {x - 15, y - 14}, {x, y - 23}, {x + 15, y - 14} }
  obj{ { body, WIN, { nopop = true } }, { roof, WIN, { nopop = true } } }
  for xx = x - 13, x + 13, 6 do R(xx, y - 14, xx, y, P.cream) end
  R(x - 13, y - 14, x + 13, y - 14, P.cream) R(x - 13, y - 1, x + 13, y, P.stone.base)
  for _, p in ipairs{ {x - 10, 8}, {x - 3, 11}, {x + 6, 9} } do R(p[1], y - p[2], p[1] + 2, y - 1, P.moss.base) px(p[1] + 1, y - p[2] - 1, P.petal.base) end
  px(x - 11, y - 12, P.cream) px(x - 10, y - 13, P.cream)
end
local function tailor(x, y)
  local wall = c:rect(x - 10, y - 14, x + 10, y)
  local roof = c:poly{ {x - 13, y - 14}, {x, y - 24}, {x + 13, y - 14} }
  obj{ { wall, "dusk", { band = 2 } }, { roof, "gold", { band = 2, nopop = true } } }
  R(x - 3, y - 9, x + 3, y, P.wood.deep)
  R(x - 8, y - 11, x - 5, y - 7, WIN.base) R(x + 5, y - 11, x + 8, y - 7, WIN.base)
  R(x - 1, y - 21, x + 1, y - 18, P.petal.base) px(x, y - 22, P.cream)
  c:stitch{ { x - 9, y - 1 }, { x + 9, y - 1 } }
end
local function kitchen(x, y)
  local wall = c:rect(x - 20, y - 24, x + 20, y)
  local roof = c:poly{ {x - 26, y - 24}, {x, y - 43}, {x + 26, y - 24} }
  local chim = c:rect(x + 9, y - 45, x + 15, y - 28)
  obj{ { wall, PLASTER, { band = 3, nopop = true } }, { roof, ROOF, { band = 3 } }, { chim, "stone", { nopop = true } } }
  for r = 0, 4 do
    local yy = y - 27 - r * 3
    local half = 24 - r * 4
    R(x - half, yy, x + half, yy, P.ember.shade)
  end
  R(x + 8, y - 46, x + 16, y - 45, P.stone.hi)
  for _, s in ipairs{ {x + 12, y - 49, 3}, {x + 14, y - 53, 2}, {x + 11, y - 57, 2} } do R(s[1], s[2], s[1] + s[3], s[2] + 1, P.cream) end
  for _, xx in ipairs{ x - 18, x - 8, x + 6, x + 16 } do R(xx, y - 22, xx, y - 1, P.wood.base) end
  R(x - 4, y - 16, x + 4, y, P.wood.shade) R(x - 3, y - 15, x + 3, y, P.wood.base) px(x + 2, y - 8, P.gold.hi)
  -- warm lit windows: the hearth is on, the one glow in the picture
  for _, wx in ipairs{ x - 15, x + 10 } do
    R(wx, y - 19, wx + 5, y - 12, P.gold.hi) R(wx, y - 15, wx + 5, y - 15, P.wood.base) R(wx + 2, y - 19, wx + 2, y - 12, P.wood.base)
    px(wx, y - 19, P.cream)
  end
  R(x - 16, y - 11, x - 9, y - 10, P.wood.base) px(x - 15, y - 12, P.petal.base) px(x - 12, y - 12, P.gold.base) px(x - 10, y - 12, P.petal.hi)
end
local function shed(x, y)
  local wall = c:rect(x - 11, y - 14, x + 11, y)
  local roof = c:poly{ {x - 14, y - 14}, {x - 11, y - 20}, {x + 11, y - 20}, {x + 14, y - 14} }
  obj{ { wall, "wood", { band = 2, nopop = true } }, { roof, { hi = P.sea.base, base = P.sea.shade, shade = P.sea.deep, deep = "#22305a" }, { band = 2, nopop = true } } }
  for xx = x - 8, x + 8, 4 do R(xx, y - 13, xx, y - 1, P.wood.shade) end
  R(x - 4, y - 10, x + 4, y, P.wood.deep) R(x - 3, y - 9, x + 3, y, P.wood.shade) px(x + 2, y - 5, P.gold.hi)
  local rake = c:rect(x + 14, y - 16, x + 14, y):add(c:rect(x + 12, y - 17, x + 16, y - 17))
  c:rim(rake, P.ink) R(x + 14, y - 16, x + 14, y, P.wood.base) R(x + 12, y - 17, x + 16, y - 17, P.stone.base)
end
local function compost(x, y)
  local bin = c:rect(x - 10, y - 8, x + 10, y)
  local heap = E(x, y - 9, 9, 4)
  obj{ { bin, LEAFD, { band = 2, nopop = true } }, { heap, { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = "#3a2430" }, { band = 1, nopop = true } } }
  for xx = x - 7, x + 7, 4 do R(xx, y - 7, xx, y - 1, P.moss.base) end
  R(x - 4, y - 12, x - 3, y - 11, P.moss.base) R(x + 3, y - 12, x + 4, y - 11, P.ember.base) px(x, y - 13, P.gold.base)
  local hat = c:poly{ {x + 5, y - 9}, {x + 13, y - 11}, {x + 10, y - 16} }
  c:rim(hat, P.ink) c:part(hat, "ember", { band = 1, nopop = true })
  R(x + 4, y - 9, x + 12, y - 8, P.cream)
end
local function beehive(x, y)
  local m = HP.mask()
  m:add(E(x, y - 6, 7, 4)) m:add(E(x, y - 11, 6, 3)) m:add(E(x, y - 15, 4, 3))
  obj{ { m, "gold", { band = 2 } } }
  R(x - 6, y - 4, x - 5, y, P.wood.base) R(x + 5, y - 4, x + 6, y, P.wood.base)
  R(x - 1, y - 6, x + 1, y - 5, P.ink)
  R(x - 5, y - 9, x + 5, y - 9, P.gold.shade) R(x - 4, y - 13, x + 4, y - 13, P.gold.shade)
  px(x + 10, y - 14, P.ink) px(x + 11, y - 14, P.gold.hi) px(x + 12, y - 15, P.cream)
end
------------------------------------------------------------ MIDDLE ROW (feet y 92)
local function barrel(x, y)
  local b = c:rrect(x - 6, y - 14, x + 6, y, 2)
  local top = E(x, y - 14, 6, 2)
  obj{ { b, "wood", { band = 2 } }, { top, "sea", { band = 1, nopop = true } } }
  R(x - 6, y - 11, x + 6, y - 10, P.stone.deep) R(x - 6, y - 4, x + 6, y - 3, P.stone.deep)
  px(x - 2, y - 15, P.cream) px(x + 3, y - 14, P.sea.hi)
  R(x + 7, y - 6, x + 8, y - 5, P.stone.shade)   -- tap
end
local function cellar(x, y)
  local mound = E(x, y - 6, 15, 8):clip(c:rect(x - 20, y - 20, x + 20, y))
  local door = c:rrect(x - 5, y - 10, x + 5, y, 3)
  obj{ { mound, LEAFD, { band = 2 } } }
  c:fillMask(c:rect(x - 7, y - 12, x + 7, y), P.stone.base) R(x - 7, y - 12, x + 7, y - 11, P.stone.hi)
  c:part(door, "wood", { band = 1, nopop = true })
  R(x - 1, y - 9, x - 1, y - 1, P.wood.deep) px(x + 2, y - 5, P.gold.hi)
end
local function worm(x, y)
  local t1 = c:rect(x - 9, y - 5, x + 9, y)
  local t2 = c:rect(x - 8, y - 10, x + 8, y - 6)
  local lid = c:rect(x - 9, y - 12, x + 9, y - 11)
  obj{ { t1, "sea", { band = 1, nopop = true } }, { t2, "sea", { band = 1, nopop = true, sep = true } }, { lid, { hi = P.sea.hi, base = P.sea.hi, shade = P.sea.base, deep = P.sea.shade }, { nopop = true, noshade = true } } }
  R(x - 6, y - 3, x + 6, y - 3, P.sea.deep) R(x - 5, y - 8, x + 5, y - 8, P.sea.deep)
  px(x + 10, y - 7, P.petal.base) px(x + 11, y - 8, P.petal.base) px(x + 11, y - 9, P.petal.hi)   -- a worm waves from the side
end
local function lady(x, y)
  local wall = c:rect(x - 7, y - 11, x + 7, y)
  local roof = c:poly{ {x - 10, y - 11}, {x, y - 18}, {x + 10, y - 11} }
  obj{ { wall, "ember", { band = 2, nopop = true } }, { roof, { hi = P.stone.base, base = P.stone.shade, shade = P.stone.deep, deep = "#2e2f48" }, { band = 1, nopop = true } } }
  for _, p in ipairs{ {x - 5, y - 9}, {x + 3, y - 9}, {x - 2, y - 5}, {x + 4, y - 4} } do R(p[1], p[2], p[1] + 1, p[2] + 1, P.ink) end
  R(x - 2, y - 7, x + 1, y, P.wood.deep) px(x - 6, y - 4, P.cream)
end
local function snail(x, y)
  local jar = c:rrect(x - 6, y - 13, x + 6, y, 2)
  local lid = c:rect(x - 7, y - 16, x + 7, y - 13)
  obj{ { jar, WIN, { band = 2, nopop = true } }, { lid, "wood", { band = 1, nopop = true } } }
  R(x - 5, y - 4, x + 5, y - 1, P.wood.base) R(x - 5, y - 4, x + 5, y - 4, P.wood.shade)
  c:part(E(x - 1, y - 7, 3, 3), "gold", { band = 1, nopop = true }) px(x - 1, y - 7, P.gold.shade)
  R(x + 2, y - 5, x + 5, y - 5, P.cream) px(x + 5, y - 6, P.cream) px(x + 5, y - 8, P.cream)
  px(x - 3, y - 11, P.cream) px(x - 3, y - 10, P.cream)
end
------------------------------------------------------------ FRONT ROW (feet y 122)
local function quail(x, y)
  local coop = c:rect(x - 10, y - 12, x + 10, y)
  local roof = c:poly{ {x - 13, y - 12}, {x, y - 19}, {x + 13, y - 12} }
  obj{ { coop, "wood", { band = 2, nopop = true } }, { roof, ROOF, { band = 2, nopop = true } } }
  for xx = x - 7, x + 7, 4 do R(xx, y - 11, xx, y - 1, P.wood.shade) end
  R(x - 3, y - 9, x + 3, y, P.wood.deep)
end
local function silk(x, y)
  -- a tall hutch with a little roof, mulberry leaves on the shelves, cocoons: unlike the fence
  local body = c:rect(x - 9, y - 18, x + 9, y)
  local roof = c:poly{ {x - 12, y - 18}, {x, y - 25}, {x + 12, y - 18} }
  obj{ { body, { hi = P.wood.hi, base = P.wood.base, shade = P.wood.shade, deep = P.wood.deep }, { nopop = true, band = 2 } }, { roof, "dusk", { band = 1, nopop = true } } }
  for _, sy in ipairs{ y - 16, y - 10, y - 4 } do R(x - 7, sy, x + 7, sy + 4, "#f2e2b8") R(x - 7, sy + 4, x + 7, sy + 4, P.wood.shade) end
  for _, t in ipairs{ {x - 6, y - 14}, {x + 1, y - 13}, {x - 4, y - 8}, {x + 2, y - 7}, {x - 5, y - 2} } do R(t[1], t[2], t[1] + 3, t[2] + 1, P.moss.base) px(t[1], t[2], P.moss.hi) end
  for _, t in ipairs{ {x + 4, y - 15}, {x - 1, y - 9}, {x + 3, y - 2} } do R(t[1], t[2], t[1] + 1, t[2], P.cream) end   -- cocoons
end
local function tortoise(x, y)
  local floorM = c:rect(x - 14, y - 7, x + 14, y)
  obj{ { floorM, { hi = "#fff0c0", base = "#f0d58c", shade = "#d9b46a", deep = P.gold.shade }, { band = 1, nopop = true } } }
  R(x - 14, y - 8, x + 14, y - 7, P.wood.base) R(x - 14, y - 1, x + 14, y, P.wood.base)
  for xx = x - 14, x + 14, 7 do R(xx, y - 11, xx, y - 7, P.wood.shade) end
  local shell = E(x - 1, y - 4, 5, 3)
  c:rim(shell, P.ink) c:part(shell, "moss", { band = 1, nopop = true })
  c:fillMask(E(x - 1, y - 5, 3, 1), P.gold.base)
  R(x + 4, y - 4, x + 6, y - 3, P.wood.hi) px(x + 6, y - 4, P.ink)
end
local function butterfly(x, y)
  local m = HP.mask()
  m:add(E(x, y - 8, 11, 7)) m:add(E(x - 6, y - 12, 6, 5)) m:add(E(x + 6, y - 13, 6, 5))
  obj{ { m, LEAFD, { band = 3 } } }
  for _, f in ipairs{ {x - 7, y - 11}, {x + 2, y - 9}, {x + 7, y - 14}, {x - 2, y - 16}, {x - 4, y - 5} } do R(f[1], f[2], f[1] + 1, f[2] + 1, P.dusk.hi) px(f[1], f[2], P.cream) end
  -- one butterfly lifts off
  px(x + 11, y - 19, P.petal.base) px(x + 12, y - 20, P.petal.hi) px(x + 14, y - 19, P.petal.base) px(x + 13, y - 18, P.ink)
end
local function fence(x, y)
  local rail1 = c:rect(x - 17, y - 12, x + 17, y - 10)
  local rail2 = c:rect(x - 17, y - 5, x + 17, y - 3)
  local posts = HP.mask()
  for xx = x - 17, x + 17, 11 do posts:add(c:rect(xx, y - 16, xx + 2, y)) end
  obj{ { rail1, "wood", { nopop = true, noshade = true } }, { rail2, "wood", { nopop = true, noshade = true } }, { posts, "wood", { nopop = true } } }
  local hen = E(x - 12, y - 8, 4, 3)
  c:rim(hen, P.ink) c:part(hen, "ember", { band = 1, nopop = true }) R(x - 16, y - 13, x - 15, y - 12, P.ember.base) px(x - 9, y - 11, P.gold.hi)
  local goat = c:rect(x - 2, y - 12, x + 5, y - 6)
  local gh = c:rect(x + 5, y - 15, x + 9, y - 10)
  local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
  c:rim(goat:copy():add(gh), P.ink) c:part(goat, CR, { band = 1, nopop = true }) c:part(gh, CR, { band = 1, nopop = true })
  px(x + 6, y - 17, P.wood.base) px(x + 8, y - 17, P.wood.base) px(x + 8, y - 13, P.ink)
  local pig = E(x + 13, y - 19, 3, 2)
  c:rim(pig, P.ink) c:part(pig, "stone", { band = 1, nopop = true }) px(x + 15, y - 20, P.ink) px(x + 10, y - 18, P.cream)
end
local function bigpond(x, y)
  local water = E(x, y - 7, 18, 9)
  c:rim(water, lerp(BASE.lawn2, DUSKSH, .45))
  c:part(water, "sea", { band = 3, nopop = true })
  R(x - 11, y - 10, x - 5, y - 10, P.sea.hi) R(x + 3, y - 6, x + 11, y - 6, P.sea.hi)
  c:part(E(x - 8, y - 6, 4, 2), "moss", { band = 1, nopop = true }) c:part(E(x + 7, y - 9, 4, 2), "moss", { band = 1, nopop = true })
  px(x - 8, y - 8, P.petal.base) px(x - 9, y - 8, P.petal.hi)
  local frog = E(x + 8, y - 11, 3, 2)
  c:rim(frog, P.ink) c:part(frog, "moss", { band = 1, nopop = true }) px(x + 7, y - 13, P.cream) px(x + 9, y - 13, P.cream)
end
local function reeds(x, y)   -- reed bank on the pond's left shore (feature shape, not part of the tap box)
  for i, xx in ipairs{ x - 20, x - 18, x - 16 } do local h = 9 + (i % 2) * 2; R(xx, y - 6 - h, xx, y - 6, P.moss.shade) R(xx, y - 8 - h, xx, y - 6 - h, P.wood.shade) end
end

------------------------------------------------------------ PLACE THEM: shadow, then building; tap box = bbox of changed pixels
local FEET = { 62, 92, 122 }
local POS = { fence = 27, quail_coop = 64 }
local SHW = { greenhouse = 16, tailor = 13, kitchen = 26, tool_shed = 14, compost_bin = 13, beehive = 9, root_cellar = 16, worm_farm = 12, ladybird_lodge = 10,
  snail_jar = 8, rain_barrel = 8, fence = 18, quail_coop = 14, silk_shelf = 11, tortoise_run = 16, butterfly_bush = 12 }
local DRAW = { greenhouse = greenhouse, tailor = tailor, kitchen = kitchen, tool_shed = shed, compost_bin = compost, beehive = beehive, root_cellar = cellar, worm_farm = worm,
  ladybird_lodge = lady, snail_jar = snail, rain_barrel = barrel, fence = fence, quail_coop = quail, silk_shelf = silk, tortoise_run = tortoise, butterfly_bush = butterfly, frog_pond = bigpond }
local NAMES = { greenhouse = "Greenhouse", tailor = "Tailor", kitchen = "Kitchen", tool_shed = "Tool Shed", compost_bin = "Compost Bin", beehive = "Beehive", root_cellar = "Root Cellar",
  worm_farm = "Worm Farm", ladybird_lodge = "Ladybird Lodge", snail_jar = "Snail Jar", rain_barrel = "Rain Barrel", fence = "The fence", quail_coop = "Quail Coop",
  silk_shelf = "Silkworm Shelf", tortoise_run = "Tortoise Run", butterfly_bush = "Butterfly Bush", frog_pond = "Frog Pond" }
for _, z in ipairs(ZONES) do
  local k = z[1]
  local x = POS[k] or z[2]
  local y = (z[3] < 70 and FEET[1]) or (z[3] < 105 and FEET[2]) or FEET[3]
  if k == "frog_pond" then y = y + 4; reeds(x, y) elseif SHW[k] then shadow(x, y + 1, SHW[k]) end
  local snap = {}
  for i, v in pairs(c.pix) do snap[i] = v end
  DRAW[k](x, y)
  local x0, y0, x1, y1 = 999, 999, -1, -1
  for i, v in pairs(c.pix) do
    if snap[i] ~= v then local yy, xx = i // 240, i % 240; if xx < x0 then x0 = xx end if xx > x1 then x1 = xx end if yy < y0 then y0 = yy end if yy > y1 then y1 = yy end end
  end
  if k == "kitchen" then y0 = y - 46 end   -- smoke wisps are not part of the tap target
  boxes[#boxes + 1] = { k = k, n = NAMES[k], box = { x0, y0, x1 + 1, y1 + 1 } }
end

------------------------------------------------------------ OUT
c:finish{ outline = false }
HP.assertClean(c)
local base = out .. "garden-patch2-" .. look
c:save{ aseprite = base .. ".aseprite", png = base .. ".png", scale = 2 }
local f = io.open(base .. ".json", "w")
local parts = {}
for _, b in ipairs(boxes) do
  parts[#parts + 1] = string.format('{"k":"%s","n":"%s","box":[%d,%d,%d,%d]}', b.k, b.n, b.box[1] * 2, b.box[2] * 2, b.box[3] * 2, b.box[4] * 2)
end
f:write("[" .. table.concat(parts, ",") .. "]") f:close()
print(look, "ok", #boxes, "spots")
