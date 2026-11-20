-- garden-ground: volume pass on top of garden-patch3.lua (Hearth Pop v3). 240x135 grid, x2 = 480x270.
-- Volume (borrowed from the regional town scenes): 3/4 view with a lit front wall and a cool, hue-shifted right side wall
-- receding at 2:1; hip roofs with a lit front slope, a shaded hip plane, a lit ridge cap and a dark fascia; the eave throws a
-- shadow line on the wall; recessed windows and doors (dark interior, frame, sill, shutters, step); stone plinths and quoins;
-- stucco mottling on walls only; sphere / cylinder shading on round things (lit upper left, reflected light, specular dot);
-- hard cool cast shadows falling lower right with a darker contact row. Ground stays calm.
-- Run: AppRun -b --script-param out=<dir>/ --script-param look=golden --script garden-ground.lua
-- QUIRKS (one per area, drawn after the buildings so tap boxes stay tight to the silhouettes):
--   greenhouse:     a sunflower has grown up through the glass roof
--   tailor:         a washing line with one lonely striped sock
--   kitchen:        the chimney smoke curls into the shape of a spoon
--   tool_shed:      a spare gnome hat hangs on the rake handle
--   compost_bin:    a gnome naps on the warm heap with his hat over his face
--   beehive:        a bee is moving in, carrying a tiny suitcase
--   root_cellar:    a "back soon" note is pinned to the cellar door
--   worm_farm:      a worm stands beside the trays reading a tiny book
--   ladybird_lodge: a ladybird sits on top of the roof flagpole
--   snail_jar:      the snail slid the jar lid aside and heads for a puddle with an umbrella
--   rain_barrel:    a paper boat sails down the barrel's stream
--   fence:          the goat is chewing a gardening glove
--   quail_coop:     a wild quail tries the door of the empty coop, wearing an egg cup as a hat
--   silk_shelf:     a visiting silkworm in a knitted scarf looks the empty hutch over from the roof
--   tortoise_run:   the tortoise carries a potted seedling on its shell
--   butterfly_bush: a butterfly rests on the bush like a bow tie
--   frog_pond:      the frog wears a lily pad as a hat
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local ok, HP = pcall(dofile, (d or ".") .. "/../lib/hp.lua")
if not ok then HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua") end
local P = HP.P
local out = app.params.out or "./"
local look = app.params.look or "golden"
local c = HP.canvas{ w = 240, h = 135, scale = 2, name = "garden-ground-" .. look }
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
-- texture: each hedge bump gets one small 3-tone leaf cluster (lit cap + dark notch), on a regular rhythm
for x = 0, 239, 12 do px(x + 1, 32, "#94cc6c") px(x + 2, 32, "#94cc6c") px(x + 2, 33, "#94cc6c") px(x + 7, 35, "#5f9a55") px(x + 8, 34, "#5f9a55") end

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
  -- three 3-px planks with a shade seam between, grain dash and a nail dot at each end (texture pass)
  for xx = x - 4, x + 4 do R(xx, 96, xx, 101, ((xx - x + 4) % 3 == 2) and P.wood.shade or P.wood.base) end
  for _, xx in ipairs{ x - 4, x - 1, x + 2 } do R(xx, 96, xx + 1, 96, P.wood.hi) px(xx + 1, 98, P.wood.hi) px(xx, 99, P.wood.shade) px(xx, 97, P.wood.deep) px(xx, 100, P.wood.deep) end
  R(x - 4, 101, x + 4, 101, P.wood.shade)
end

------------------------------------------------------------ helpers for buildings
local boxes, AT = {}, {}
local function shadeUnder(m, t) m:each(function(x, y) local v = c:get(x, y); if v then px(x, y, lerp(v, DUSKSH, t)) end end) end
local CURSNAP   -- snapshot taken right after a building's cast shadow, so tap boxes ignore the shadow
local function snapshot() local s = {} for i, v in pairs(c.pix) do s[i] = v end return s end
-- TEXTURE helpers: shift a pixel one step along a ramp (hi=1, base=2, shade=3, deep=4), only if it is
-- currently a tone of that ramp. Darkening shade goes half way to deep, lightening hi goes half way to cream,
-- so texture never out-shouts the silhouette (ink rim stays the strongest edge).
local function rampOf(r) if type(r) == "string" then return P[r] end return r end
local function step(x, y, r, dir)
  r = rampOf(r)
  local v = c:get(x, y); if not v then return end
  local T = { r.hi, r.base, r.shade, r.deep }
  for i = 1, 4 do
    if v == T[i] then
      local n
      if dir > 0 then n = (i == 3) and lerp(r.shade, r.deep, .45) or (i == 4) and nil or T[i + 1]
      else n = (i == 1) and lerp(r.hi, P.cream, .5) or (i == 4) and r.shade or T[i - 1] end
      if n then px(x, y, n) end
      return
    end
  end
end
local dk = function(x, y, r) step(x, y, r, 1) end
local lt = function(x, y, r) step(x, y, r, -1) end
local function dkrow(x0, x1, y, r) for x = x0, x1 do dk(x, y, r) end end
local function ltrow(x0, x1, y, r) for x = x0, x1 do lt(x, y, r) end end
local function courses(m, r, x0, x1, y0, y1, h, w, opt)
  opt = opt or {}
  for y = y0, y1 do
    local row = (y - y0) % h
    local course = (y - y0) // h
    for x = x0, x1 do
      if m:has(x, y) and m:has(x, y - 1) and m:has(x - 1, y) and m:has(x + 1, y) then
        local tx = (x - x0 + (course % 2) * (w // 2))
        if row == h - 1 then dk(x, y, r)
        elseif tx % w == 0 then if not opt.nojoint then dk(x, y, r) end
        else
          local t = hsh(tx // w + 3, course + (opt.seed or 0))
          if t < (opt.light or 12) then lt(x, y, r) elseif t > 100 - (opt.dark or 8) then dk(x, y, r) end
        end
      end
    end
  end
end
local function strands(m, r, y0, y1, every, gap)
  for y = y0, y1, gap or 2 do for x = 0, 239 do
    if m:has(x, y) and m:has(x - 1, y) and m:has(x + 1, y) and m:has(x, y + 1) and (x + y) % every == 0 then dk(x, y, r) end
  end end
end
local function leaves(m, r, x0, x1, y0, y1, sx, sy)
  local inner = m:shrink(1)
  for gy = y0, y1, sy do
    local row = (gy - y0) // sy
    for gx = x0 + (row % 2) * (sx // 2), x1, sx do
      if inner:has(gx, gy) and inner:has(gx + 2, gy + 1) then
        lt(gx, gy, r) lt(gx + 1, gy, r) dk(gx + 1, gy + 1, r) dk(gx + 2, gy + 1, r)
      end
    end
  end
end
local SHEDR = { hi = P.sea.base, base = P.sea.shade, shade = P.sea.deep, deep = "#22305a" }
local SLATE = { hi = P.stone.base, base = P.stone.shade, shade = P.stone.deep, deep = "#2e2f48" }
local HEAP = { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = "#3a2430" }
local STRAW = { hi = "#fff0c0", base = "#f0d58c", shade = "#d9b46a", deep = P.gold.shade }
local THATCH = { hi = P.gold.hi, base = P.gold.base, shade = P.gold.shade, deep = P.gold.deep }
local INTERIOR = "#3b2c48"   -- dark room seen through a window or open door (cool, never black)

------------------------------------------------------------ VOLUME KIT (patch4)
-- The view is 3/4: front wall lit, right side wall receding up-right at 2:1 in cool shade, roof seen from above.
-- side(x1, yt, yb, d): the right side wall, column i rises (i+1)//2 rows.
local function rise(i) return (i + 1) // 2 end
local function sideWall(x1, yt, yb, d, extra)
  local m = HP.mask()
  for i = 1, d do local s = rise(i); for yy = yt - s - (extra or 0), yb - s do m:set(x1 + i, yy) end end
  return m
end
-- top(x0, x1, yt, d): the lid/top plane of a box, a parallelogram behind the front top edge.
local function topPlane(x0, x1, yt, d)
  local m = HP.mask()
  for i = 0, d do local s = rise(i); for yy = yt - s, yt - 1 do end end
  for j = 1, rise(d) do for xx = x0 + 2 * j - 1, x1 + math.min(d, 2 * j) do m:set(xx, yt - j) end end
  return m
end
-- hip roof: a big lit front slope (eave row ye, ridge row yr, overhang ov, ridge inset a) and the right hip plane in shade.
local function hipRoof(x0, x1, ye, yr, ov, a, d, ah)
  local rr, hd = rise(d), d // 2
  local EL, ER, BR = { x0 - ov, ye + 1 }, { x1 + ov + 1, ye + 1 }, { x1 + ov + d + 1, ye + 1 - rr }
  local RL, RR = { x0 - ov + a + hd, yr }, { x1 + ov + 1 - (ah or a + 3) + hd, yr }
  local F = c:poly{ EL, RL, RR, ER }
  local S = c:poly{ ER, RR, BR }:cut(F)
  return F, S
end
-- hard pixels, one ramp: front base, side cool (hue shifted toward violet), eave shadow tone
local function wallTones(base, lit)
  return { base = base, lite = lerp(base, lit or P.cream, .4), dark = lerp(base, DUSKSH, .12),
    eave = lerp(base, DUSKSH, .3), sbase = lerp(base, DUSKSH, .36), slite = lerp(base, DUSKSH, .27), sdark = lerp(base, DUSKSH, .47) }
end
-- stucco mottling: sparse 1-2 px specks one half-step lighter or darker, on wall pixels only
local function mottle(m, base, lite, dark, seed, dens)
  m:each(function(x, y)
    if c:get(x, y) == base then
      local h = hsh(x * 3 + seed, y * 5 + seed)
      if h < dens then px(x, y, lite) if c:get(x + 1, y) == base and h < dens // 2 then px(x + 1, y, lite) end
      elseif h > 99 - dens then px(x, y, dark) end
    end
  end)
end
local function paintWalls(front, side, W, seed)
  c:fillMask(front, W.base) c:fillMask(side, W.sbase)
  mottle(front, W.base, W.lite, W.dark, seed or 1, 7)
  mottle(side, W.sbase, W.slite, W.sdark, (seed or 1) + 9, 9)
end
-- the eave throws a 1-2 px shadow line on the wall under it (front and side)
local function eaveShadow(x0, x1, yt, d, W, rows)
  for r = 0, (rows or 1) - 1 do R(x0, yt + r, x1, yt + r, W.eave) end
  for i = 1, d do local s = rise(i); for r = 0, (rows or 1) do px(x1 + i, yt - s + r, W.sdark) end end
end
-- warm rim light on the upper-left edges of a mask (pixels whose left or top neighbour is outside)
local function rimLight(m, hex, only)
  m:each(function(x, y) if (not m:has(x - 1, y) or not m:has(x, y - 1)) and (not only or c:get(x, y) == only) then px(x, y, hex) end end)
end
-- roof: front slope base with tile courses, ridge cap and left hip edge lit, eave fascia dark; hip plane in shade
local function paintRoof(F, S, Rr, o)
  o = o or {}
  c:fillMask(F, Rr.base) c:fillMask(S, Rr.shade)
  local x0, y0, x1, y1 = F:bbox()
  if o.tex ~= false then courses(F, Rr, x0, x1, y0 + 1, y1 - 1, o.h or 3, o.w or 5, { light = o.light or 12, dark = o.dark or 6, seed = o.seed or 1 }) end
  local sx0, sy0, sx1, sy1 = S:bbox()
  if sx0 then for yy = sy0, sy1 do if (yy - y0) % (o.h or 3) == (o.h or 3) - 1 then for xx = sx0, sx1 do if S:has(xx, yy) and S:has(xx - 1, yy) then px(xx, yy, lerp(Rr.shade, Rr.deep, .45)) end end end end end
  -- edges: ridge cap + left hip catch the light; the hip line between the planes is one step lighter than the shade
  F:each(function(x, y)
    if not F:has(x, y - 1) and not S:has(x, y - 1) then px(x, y, Rr.hi)
    elseif not F:has(x - 1, y) then px(x, y, lerp(Rr.hi, Rr.base, .35)) end
  end)
  for xx = x0, x1 do if F:has(xx, y1) then px(xx, y1, lerp(Rr.shade, Rr.deep, .35)) end end   -- fascia under the eave
  if sx0 then S:each(function(x, y) if not S:has(x, y + 1) and not F:has(x, y + 1) then px(x, y, Rr.deep) end end) end
end
-- recessed window: frame, dark (or glowing) glass with a shadow on its top and left inner edge, cross bar,
-- a sill that catches light with a shadow line under it, optional shutters
local function window(wx, wy, w, h, o)
  o = o or {}
  local fr = o.frame or P.wood.base
  R(wx - 1, wy - 1, wx + w, wy + h, fr)
  local glass = o.glow and P.gold.hi or (o.glass or WIN.shade)
  R(wx, wy, wx + w - 1, wy + h - 1, glass)
  local rec = o.glow and P.gold.base or (o.rec or INTERIOR)
  R(wx, wy, wx + w - 1, wy, rec) R(wx, wy, wx, wy + h - 1, rec)
  if not o.nobar then
    local mx, my = wx + w // 2, wy + h // 2
    if w >= 5 then R(mx, wy, mx, wy + h - 1, fr) end
    if h >= 5 then R(wx, my, wx + w - 1, my, fr) end
  end
  if o.glow then px(wx + 1, wy + 1, P.cream) else px(wx + 1, wy + 1, o.glint or WIN.hi) end
  px(wx - 1, wy - 1, o.frameHi or lerp(fr, P.cream, .35))
  if not o.nosill then
    R(wx - 2, wy + h, wx + w + 1, wy + h, o.sill or P.stone.hi)
    R(wx - 1, wy + h + 1, wx + w + 1, wy + h + 1, o.sillsh)
  end
  if o.shut then
    local S = o.shut
    for _, sx in ipairs{ wx - 3, wx + w + 1 } do
      R(sx, wy - 1, sx + 1, wy + h - 1, S.base)
      for yy = wy, wy + h - 1, 2 do R(sx, yy, sx + 1, yy, S.shade) end
      px(sx, wy - 1, S.hi)
    end
    R(wx + w + 2, wy - 1, wx + w + 2, wy + h - 1, S.shade)   -- right shutter's own edge in shade
  end
end
-- recessed plank door with a frame, arch, shadowed top and left jamb, handle, and a step that catches light
local function door(dx0, dx1, dy0, yb, o)
  o = o or {}
  local Rw = o.ramp or P.wood
  local fr = o.frame or Rw.deep
  local f = c:rrect(dx0 - 1, dy0 - 1, dx1 + 1, yb, o.arch or 2)
  c:fillMask(f, fr)
  local leaf = c:rrect(dx0, dy0, dx1, yb, math.max((o.arch or 2) - 1, 0))
  c:fillMask(leaf, o.open and INTERIOR or Rw.base)
  if not o.open then
    for xx = dx0 + 2, dx1 - 1, 2 do leaf:each(function(x, y) if x == xx then px(x, y, Rw.shade) end end) end
    leaf:each(function(x, y) if not leaf:has(x, y - 1) or x == dx0 then px(x, y, lerp(Rw.shade, Rw.deep, .5)) end end)
    px(dx1 - 1, dy0 + (yb - dy0) // 2 + 1, P.gold.hi)
  else
    leaf:each(function(x, y) if x == dx1 then px(x, y, lerp(INTERIOR, Rw.shade, .4)) end end)
  end
  if o.lintel then R(dx0 - 2, dy0 - 2, dx1 + 2, dy0 - 2, o.lintel) end
  if not o.nostep then R(dx0 - 2, yb, dx1 + 2, yb, P.stone.base) R(dx0 - 2, yb, dx1 + 1, yb, P.stone.hi) end
end
-- stone plinth / base course: lit top ledge, jointed blocks, dark contact row; the side continues it in shade
local function plinth(x0, x1, yb, d, rows)
  rows = rows or 2
  R(x0, yb - rows + 1, x1, yb, P.stone.base)
  R(x0, yb - rows + 1, x1, yb - rows + 1, P.stone.hi)
  R(x0, yb, x1, yb, P.stone.shade)
  for xx = x0 + 2, x1, 5 do px(xx, yb - rows + 2 > yb and yb or yb - rows + 2, P.stone.shade) end
  for i = 1, d do local s = rise(i); for r = 0, rows - 1 do px(x1 + i, yb - s - r, (r == rows - 1) and P.stone.shade or P.stone.deep) end end
end
-- corner quoins: alternating long/short stones up a wall edge (borrowed from the town corners)
local function quoins(xc, y0, y1, dir, lite, dark)
  for yy = y0, y1, 4 do R(xc, yy, xc + dir * 2, yy + 1, lite) R(xc, yy + 2, xc + dir, yy + 3, lite) px(xc + dir * 2, yy + 1, dark) end
end
-- hard cast shadow on the ground (light upper left): a band under the footprint that slides right as it
-- comes forward, plus a wedge off the shade side; a darker contact row tucks under the front wall.
local function cast(x0, x1, yb, d, hw, L)
  L = (L or 4) + 3
  local m = HP.mask()
  for j = 1, 3 do for xx = x0 + j, x1 + d + j + 1 do m:set(xx, yb + j) end end
  local rr = rise(d)
  for yy = yb - rr - hw, yb do
    local t = (yy - (yb - rr - hw)) / (hw + rr)
    for xx = x1 + d + 1, x1 + d + 1 + floor(t * L + .5) do m:set(xx, yy) end
  end
  shadeUnder(m, .38)
  local k = HP.mask() for xx = x0 + 1, x1 + d do k:set(xx, yb + 2) end
  shadeUnder(k, .25)
  CURSNAP = snapshot()
end
local function castRound(cx, yb, rx, L)
  local m = E(cx + (L or 3), yb + 1, rx, 2)
  shadeUnder(m, .38)
  CURSNAP = snapshot()
end
-- sphere / cylinder shading quantised to 4 tones (hard pixels), with a reflected-light edge on the shade side
local LX, LY, LZ = -0.55, -0.62, 0.56
local function ball(m, cx, cy, rx, ry, T, o)
  o = o or {}
  local t1, t2, t3 = o.t1 or .62, o.t2 or .2, o.t3 or -.18
  m:each(function(x, y)
    local u, v = (x + .5 - cx - .5) / (rx + .5), (y + .5 - cy - .5) / (ry + .5)
    local q = 1 - u * u - v * v; if q < 0 then q = 0 end
    local l = LX * u + LY * v + LZ * math.sqrt(q)
    px(x, y, (l > t1 and T.hi) or (l > t2 and T.base) or (l > t3 and T.shade) or T.deep)
  end)
  if not o.norefl then   -- reflected light: the outermost lower-right edge lifts one step
    m:each(function(x, y) if (not m:has(x + 1, y) or not m:has(x, y + 1)) and c:get(x, y) == T.deep and (x - cx) + (y - cy) * (rx / math.max(ry, 1)) > rx * .5 then px(x, y, T.shade) end end)
  end
  if not o.nospec then local sx, sy = floor(cx - rx * .42 + .5), floor(cy - ry * .5 + .5); if m:has(sx, sy) then px(sx, sy, o.spec or P.cream) end end
end
local function cyl(m, cx, rx, T, o)
  o = o or {}
  m:each(function(x, y)
    local u = (x + .5 - cx - .5) / (rx + .5)
    local l = -0.72 * u + 0.69 * math.sqrt(math.max(0, 1 - u * u))
    px(x, y, (l > (o.t1 or .78) and T.hi) or (l > (o.t2 or .35) and T.base) or (l > (o.t3 or -.15) and T.shade) or T.deep)
  end)
  if not o.norefl then m:each(function(x, y) if not m:has(x + 1, y) and c:get(x, y) == T.deep then px(x, y, T.shade) end end) end
end
local function ink(...) local u = HP.mask() for _, m in ipairs{ ... } do u:add(m) end c:rim(u, P.ink) return u end

------------------------------------------------------------ BACK ROW (feet y 62)
local function greenhouse(x, y)
  local x0, x1, yt, d = x - 14, x + 10, y - 14, 4
  cast(x0, x1, y, d, 9, 4)
  local front, side = c:rect(x0, yt, x1, y), sideWall(x1, yt, y, d, 1)
  local F, S = hipRoof(x0, x1, yt - 1, y - 22, 2, 7, d)
  ink(front, side, F, S)
  -- glass walls: lit front panes, darker side panes that show the green inside, cream glazing bars
  c:fillMask(front, WIN.base) c:fillMask(side, WIN.shade)
  for xx = x0, x1 do for yy = yt, y do if (xx - x0) % 6 == 0 or yy == yt or yy == y - 7 then px(xx, yy, P.cream) end end end
  side:each(function(xx, yy) if (xx - x1) == d or yy == y - 7 - rise(xx - x1) then px(xx, yy, P.stone.hi) end end)
  -- plants inside: seen through the glass (darker green behind the side glass)
  for _, p in ipairs{ {x0 + 2, 6}, {x0 + 8, 9}, {x0 + 14, 7}, {x0 + 20, 8} } do R(p[1], y - p[2], p[1] + 2, y - 3, P.moss.base) px(p[1], y - p[2], P.moss.hi) px(p[1] + 2, y - p[2] + 2, P.moss.shade) px(p[1] + 1, y - p[2] - 1, P.petal.base) end
  side:each(function(xx, yy) if yy > y - 6 - rise(xx - x1) and yy < y - 2 - rise(xx - x1) and (xx - x1) < d then px(xx, yy, P.moss.shade) end end)
  -- glass roof: lit front slope with glazing bars, hip in shade
  local GR = { hi = P.sky.hi, base = WIN.hi, shade = WIN.base, deep = WIN.shade }
  paintRoof(F, S, GR, { tex = false })
  local fx0, fy0, fx1, fy1 = F:bbox()
  for _, xx in ipairs{ x0 + 1, x0 + 7, x0 + 13, x0 + 19 } do for yy = fy0 + 1, fy1 - 1 do if F:has(xx, yy) and F:has(xx + 1, yy) then px(xx, yy, P.cream) end end end
  -- brick plinth
  plinth(x0, x1, y, d, 2)
  for xx = x0 + 1, x1, 4 do px(xx, y, P.stone.deep) end
  -- glints: diagonal on the lit panes, one on the roof
  px(x0 + 2, yt + 2, P.cream) px(x0 + 3, yt + 1, P.cream) px(x0 + 8, yt + 3, WIN.hi) px(x0 + 9, yt + 2, WIN.hi)
  px(x0 + 3, y - 19, P.cream) px(x0 + 4, y - 20, P.cream)
end
local function tailor(x, y)
  local x0, x1, yt, d = x - 11, x + 9, y - 14, 4
  cast(x0, x1, y, d, 10, 4)
  local front, side = c:rect(x0, yt, x1, y), sideWall(x1, yt, y, d, 1)
  local F, S = hipRoof(x0, x1, yt - 1, y - 24, 3, 8, d)
  ink(front, side, F, S)
  local W = wallTones(P.dusk.base, P.dusk.hi)
  paintWalls(front, side, W, 4)
  -- side: vertical boards in the shade tone (a different texture from the front's stucco)
  side:each(function(xx, yy) if (xx - x1) % 2 == 0 then px(xx, yy, W.sdark) end end)
  -- thatch: lit front slope in straw courses with ragged strand tips; hip in shade
  paintRoof(F, S, THATCH, { tex = false })
  local fx0, fy0, fx1, fy1 = F:bbox()
  for yy = fy0 + 2, fy1 - 1, 3 do
    for xx = fx0, fx1 do
      if F:has(xx, yy) and F:has(xx - 1, yy) and F:has(xx + 1, yy) then
        if (xx + yy) % 4 ~= 0 then dk(xx, yy, THATCH) end
        if (xx + yy) % 4 == 2 then lt(xx, yy - 1, THATCH) end
      end
    end
  end
  eaveShadow(x0, x1, yt, d, W, 1)
  plinth(x0, x1, y, d, 2)
  door(x - 3, x + 1, y - 9, y, { frame = P.wood.deep, arch = 2 })
  window(x0 + 2, y - 11, 3, 4, { frame = P.cream, sill = P.cream, sillsh = W.eave, nobar = true })
  window(x + 4, y - 10, 3, 3, { frame = P.cream, sill = P.cream, sillsh = W.eave, nobar = true })
  -- striped awning over the right window (borrowed from the town shops): petal and cream, scalloped edge
  for xx = x + 3, x + 8 do local col = ((xx - x) % 2 == 0) and P.petal.base or P.cream; R(xx, y - 13, xx, y - 12, col) end
  for xx = x + 3, x + 8, 2 do px(xx, y - 11, P.petal.shade) end
  R(x + 3, y - 13, x + 8, y - 13, P.petal.hi)
  -- spool sign on the thatch
  R(x - 1, y - 21, x + 1, y - 19, P.petal.base) R(x - 1, y - 22, x + 1, y - 22, P.wood.hi) R(x - 1, y - 18, x + 1, y - 18, P.wood.shade) px(x - 1, y - 21, P.petal.hi)
end
local function kitchen(x, y)
  local x0, x1, yt, d = x - 21, x + 18, y - 24, 5
  cast(x0, x1, y, d, 16, 6)
  local front, side = c:rect(x0, yt, x1, y), sideWall(x1, yt, y, d, 1)
  local F, S = hipRoof(x0, x1, yt - 1, y - 43, 4, 18, d)
  local chim, chs = c:rect(x + 8, y - 46, x + 12, y - 32), sideWall(x + 12, y - 46, y - 33, 2)
  local cap = c:rect(x + 7, y - 48, x + 14, y - 47)
  local F2, S2 = F:copy():cut(chim):cut(chs), S:copy():cut(chim):cut(chs)
  ink(front, side, F, S, chim, chs, cap)
  local W = wallTones(PLASTER.base, P.cream)
  paintWalls(front, side, W, 2)
  paintRoof(F2, S2, ROOF, { h = 3, w = 5, light = 12, dark = 6, seed = 2 })
  -- a moss patch on the shady lower-left tiles
  px(x - 19, y - 28, P.moss.base) px(x - 18, y - 28, P.moss.base) px(x - 20, y - 27, P.moss.shade) px(x - 19, y - 27, P.moss.base) px(x - 18, y - 27, P.moss.shade)
  -- chimney: lit brick front, cool side, capped; a soot shadow where it meets the roof
  c:fillMask(chim, P.stone.base) c:fillMask(chs, P.stone.shade)
  for yy = y - 44, y - 34, 3 do R(x + 9, yy, x + 12, yy, lerp(P.stone.base, P.stone.shade, .5)) px(x + 13, yy, P.stone.deep) px(x + 14, yy - 1, P.stone.deep) end
  for yy = y - 43, y - 34, 6 do px(x + 10, yy, P.stone.hi) end
  R(x + 8, y - 46, x + 8, y - 33, P.stone.hi)
  c:fillMask(cap, P.stone.shade) R(x + 7, y - 48, x + 13, y - 48, P.stone.hi) R(x + 13, y - 47, x + 14, y - 47, P.stone.deep)
  R(x + 9, y - 48, x + 11, y - 48, P.ink)   -- flue
  -- eave shadow, quoins, plinth
  eaveShadow(x0, x1, yt, d, W, 2)
  quoins(x0, yt + 3, y - 4, 1, P.cream, W.dark)
  quoins(x1, yt + 3, y - 4, -1, P.cream, W.dark)
  plinth(x0, x1, y, d, 3)
  -- side wall: a small round window, dark, with a lit lower-right reveal
  local sx = x1 + 3
  R(sx - 1, y - 17, sx + 1, y - 14, P.wood.shade) R(sx, y - 16, sx, y - 15, INTERIOR) px(sx + 1, y - 15, P.wood.base)
  -- door: arched, recessed, with a lit step and lintel
  door(x - 4, x + 2, y - 16, y, { frame = P.wood.deep, arch = 3, lintel = P.stone.base })
  -- warm lit windows with shutters and a flower box (the hearth is on: the one glow in the picture)
  local SH = { hi = P.moss.hi, base = P.moss.base, shade = P.moss.shade }
  for _, wx in ipairs{ x - 16, x + 8 } do window(wx, y - 19, 6, 7, { glow = true, frame = P.wood.shade, shut = SH, sill = P.stone.hi, sillsh = W.eave }) end
  R(x - 17, y - 10, x - 10, y - 9, P.wood.base) R(x - 17, y - 9, x - 10, y - 9, P.wood.shade) px(x - 17, y - 10, P.wood.hi)
  for _, f in ipairs{ {x - 16, P.petal.base}, {x - 14, P.gold.hi}, {x - 12, P.petal.hi}, {x - 11, P.moss.base} } do px(f[1], y - 11, f[2]) end
  px(x - 15, y - 11, P.moss.base) px(x - 13, y - 11, P.moss.shade)
end
local function shed(x, y)
  local x0, x1, yt, d = x - 12, x + 9, y - 14, 4
  cast(x0, x1, y, d, 9, 4)
  local front, side = c:rect(x0, yt, x1, y), sideWall(x1, yt, y, d, 1)
  local F, S = hipRoof(x0, x1, yt - 1, y - 21, 3, 6, d)
  local rake = c:rect(x + 17, y - 16, x + 17, y):add(c:rect(x + 15, y - 17, x + 19, y - 17))
  ink(front, side, F, S, rake)
  local W = wallTones(P.wood.base, P.wood.hi)
  paintWalls(front, side, W, 7)
  -- front: vertical planks with grain and nails; side: horizontal weatherboards in shade (different texture)
  for xx = x0 + 3, x1 - 1, 4 do R(xx, yt, xx, y, lerp(P.wood.base, P.wood.shade, .6)) end
  for xx = x0 + 1, x1, 4 do px(xx, yt + 3, P.wood.hi) px(xx, y - 3, P.wood.hi) end
  side:each(function(xx, yy) if (yy + rise(xx - x1)) % 3 == 0 then px(xx, yy, W.sdark) end end)
  paintRoof(F, S, SHEDR, { h = 3, w = 4, light = 14, dark = 8, seed = 7 })
  eaveShadow(x0, x1, yt, d, W, 1)
  plinth(x0, x1, y, d, 1)
  door(x - 5, x + 1, y - 10, y, { ramp = { hi = P.wood.hi, base = P.wood.shade, shade = P.wood.deep, deep = "#3a2430" }, frame = P.wood.deep, arch = 0 })
  R(x - 4, y - 6, x, y - 6, P.wood.base)   -- brace
  window(x + 4, y - 11, 3, 3, { frame = P.wood.deep, sill = P.wood.hi, sillsh = W.eave, nobar = true })
  -- rake leaning on the side
  R(x + 17, y - 16, x + 17, y, P.wood.base) px(x + 17, y - 16, P.wood.hi)
  R(x + 15, y - 17, x + 19, y - 17, P.stone.base) px(x + 15, y - 17, P.stone.hi) px(x + 19, y - 17, P.stone.shade)
end
local function compost(x, y)
  local x0, x1, yt, d = x - 11, x + 7, y - 8, 4
  cast(x0, x1, y, d, 4, 3)
  local front, side = c:rect(x0, yt, x1, y), sideWall(x1, yt, y, d)
  local heap = E(x - 1, y - 10, 9, 4):cut(front)
  local top = topPlane(x0, x1, yt, d):cut(heap)
  ink(front, side, heap, top)
  -- painted green slats: lit front, cool side, a lit top rim; heap is a lit dome
  c:fillMask(front, LEAFD.base) c:fillMask(side, LEAFD.shade) c:fillMask(top, LEAFD.hi)
  for xx = x0 + 1, x1, 4 do R(xx, yt + 1, xx + 2, y - 1, P.moss.base) R(xx, yt + 1, xx, y - 1, P.moss.hi) end
  R(x0, y - 4, x1, y - 4, LEAFD.shade)
  side:each(function(xx, yy) if (yy + rise(xx - x1)) % 3 == 1 then px(xx, yy, LEAFD.deep) end end)
  R(x0, yt, x1, yt, P.moss.hi)
  R(x0, y, x1, y, LEAFD.deep)
  ball(heap, x - 1, y - 11, 9, 4, HEAP, { nospec = true })
  for _, p in ipairs{ {x - 6, y - 12}, {x - 2, y - 13}, {x + 3, y - 12}, {x + 6, y - 10}, {x - 8, y - 10} } do lt(p[1], p[2], HEAP) lt(p[1] + 1, p[2], HEAP) end
  px(x + 5, y - 13, P.ember.base) px(x - 8, y - 11, P.moss.base)
end
local function beehive(x, y)
  castRound(x, y, 8, 3)
  local l1, l2, l3 = E(x, y - 15, 4, 3), E(x, y - 11, 6, 3), E(x, y - 6, 7, 4)
  local legs = c:rect(x - 6, y - 3, x - 5, y):add(c:rect(x + 4, y - 3, x + 5, y))
  ink(l1, l2, l3, legs)
  R(x - 6, y - 3, x - 5, y, P.wood.base) R(x + 4, y - 3, x + 5, y, P.wood.shade) px(x - 6, y - 3, P.wood.hi)
  -- each straw coil is its own lit ring: lit upper left, cool lower right, a dark groove under each
  ball(l1, x, y - 15, 5, 4, THATCH, { nospec = true }) ball(l2, x, y - 11, 7, 4, THATCH, { nospec = true }) ball(l3, x, y - 6, 8, 5, THATCH, { nospec = true })
  for _, m in ipairs{ l1, l2 } do m:each(function(xx, yy) if not m:has(xx, yy + 1) and c:get(xx, yy + 1) then px(xx, yy + 1, P.gold.deep) end end) end
  strands(l3:copy():add(l2):add(l1), "gold", y - 17, y - 3, 3, 2)
  px(x - 2, y - 17, P.cream) px(x - 1, y - 17, P.cream)
  -- entrance: a dark hole with a lit lower lip
  R(x - 1, y - 5, x + 1, y - 4, INTERIOR) R(x - 1, y - 3, x + 1, y - 3, P.gold.hi)
end
------------------------------------------------------------ MIDDLE ROW (feet y 92)
local function barrel(x, y)
  castRound(x, y, 7, 3)
  local b = c:rrect(x - 6, y - 13, x + 6, y, 2)
  local top = E(x, y - 14, 6, 2)
  local tap = c:rect(x + 7, y - 6, x + 8, y - 5)
  ink(b, top, tap)
  cyl(b, x, 6, P.wood)
  -- staves: seams follow the curve; iron hoops with the same cylinder light
  for _, xx in ipairs{ x - 3, x + 1, x + 4 } do for yy = y - 11, y - 1 do if b:shrink(1):has(xx, yy) then dk(xx, yy, "wood") end end end
  for _, hy in ipairs{ y - 10, y - 4 } do
    local h = c:rect(x - 6, hy, x + 6, hy + 1):clip(b)
    cyl(h, x, 6, P.stone, { t1 = .7 })
    R(x - 5, hy + 1, x + 5, hy + 1, P.stone.deep) px(x - 3, hy, P.cream)
  end
  -- water top: rim lit on the far side, water darker under the near rim
  c:fillMask(top, P.sea.base)
  top:each(function(xx, yy) if not top:has(xx, yy - 1) then px(xx, yy, P.wood.hi) elseif not top:has(xx, yy + 1) then px(xx, yy, P.wood.shade) end end)
  px(x - 2, y - 14, P.sea.hi) px(x - 1, y - 14, P.cream)
  R(x + 7, y - 6, x + 8, y - 5, P.stone.shade) px(x + 7, y - 6, P.stone.hi)
  px(x - 4, y - 8, P.cream)   -- specular on the staves
end
local function cellar(x, y)
  castRound(x, y, 15, 4)
  local mound = E(x, y - 6, 15, 8):clip(c:rect(x - 20, y - 20, x + 20, y))
  ink(mound)
  ball(mound, x, y - 3, 15, 9, LEAFD, { nospec = true, t1 = .55 })
  leaves(mound, LEAFD, x - 14, x + 14, y - 13, y - 3, 6, 3)
  -- stone portal: front face lit, a thick right reveal in shade (the arch has depth), recessed door
  local arch = c:rrect(x - 7, y - 13, x + 7, y, 3)
  local rev = sideWall(x + 7, y - 11, y, 2)
  c:rim(arch:copy():add(rev), P.ink, mound:copy():grow(1))
  c:fillMask(arch, P.stone.base) c:fillMask(rev, P.stone.shade)
  arch:each(function(xx, yy) if not arch:has(xx - 1, yy) or not arch:has(xx, yy - 1) then px(xx, yy, P.stone.hi) end end)
  for _, xx in ipairs{ x - 4, x, x + 4 } do px(xx, y - 13, P.stone.shade) px(xx, y - 12, P.stone.shade) end
  for _, yy in ipairs{ y - 8, y - 4 } do px(x - 7, yy, P.stone.shade) px(x - 6, yy, P.stone.shade) px(x + 6, yy, P.stone.shade) px(x + 7, yy, P.stone.shade) end
  px(x + 8, y - 6, P.stone.deep) px(x + 9, y - 9, P.stone.deep)
  local dr = c:rrect(x - 5, y - 11, x + 5, y, 3)
  c:fillMask(dr, P.wood.base)
  for _, xx in ipairs{ x - 3, x, x + 3 } do dr:each(function(a, b) if a == xx then px(a, b, P.wood.shade) end end) end
  dr:each(function(a, b) if not dr:has(a, b - 1) or not dr:has(a - 1, b) then px(a, b, P.wood.deep) end end)   -- recess shadow top and left
  R(x - 4, y - 6, x + 4, y - 6, P.stone.deep) px(x - 4, y - 6, P.stone.shade)   -- iron strap
  px(x + 3, y - 4, P.gold.hi)
  R(x - 7, y, x + 7, y, P.stone.shade) R(x - 6, y, x + 6, y, P.stone.hi)   -- door step
end
local function worm(x, y)
  local x0, x1, d = x - 10, x + 6, 3
  cast(x0, x1, y, d, 6, 3)
  local front = c:rect(x0, y - 12, x1, y)
  local side = sideWall(x1, y - 12, y, d)
  local top = topPlane(x0, x1, y - 12, d)
  ink(front, side, top)
  c:fillMask(front, P.sea.base) c:fillMask(side, P.sea.shade) c:fillMask(top, P.sea.hi)
  -- three trays: lit moulded rim on each, dark gap under it, vent holes; the side repeats the rims in shade
  for _, ty in ipairs{ y - 12, y - 6 } do
    R(x0, ty, x1, ty, P.sea.hi) R(x0, ty + 1, x1, ty + 1, lerp(P.sea.base, P.sea.shade, .5))
    for i = 1, d do px(x1 + i, ty - rise(i), P.sea.base) end
  end
  R(x0, y - 7, x1, y - 7, P.sea.deep) for i = 1, d do px(x1 + i, y - 7 - rise(i), P.sea.deep) end
  for xx = x0 + 2, x1 - 1, 3 do px(xx, y - 3, P.sea.deep) px(xx + 1, y - 9, P.sea.deep) end
  R(x0, y, x1, y, P.sea.shade)
  -- lid: lit top plane with a handle groove
  R(x0 + 4, y - 14, x1 - 2, y - 14, P.sea.base) px(x0 + 4, y - 13, P.cream)
  rimLight(front, P.sea.hi, P.sea.base)
end
local function lady(x, y)
  local x0, x1, yt, d = x - 8, x + 5, y - 11, 3
  cast(x0, x1, y, d, 7, 3)
  local front, side = c:rect(x0, yt, x1, y), sideWall(x1, yt, y, d, 1)
  local F, S = hipRoof(x0, x1, yt - 1, y - 18, 2, 7, d)
  ink(front, side, F, S)
  local W = wallTones(P.ember.base, P.ember.hi)
  paintWalls(front, side, W, 11)
  paintRoof(F, S, SLATE, { h = 2, w = 3, light = 18, dark = 0, seed = 3 })
  eaveShadow(x0, x1, yt, d, W, 1)
  for yy = yt + 2, y - 1, 3 do dkrow(x0 + 1, x0 + 4, yy, "ember") end
  -- spots: ink with a lit cool edge (they sit on a round-cornered shell-like wall)
  for _, p in ipairs{ {x - 6, y - 8}, {x + 2, y - 9}, {x - 6, y - 3} } do R(p[1], p[2], p[1] + 1, p[2] + 1, P.ink) px(p[1], p[2], P.ember.deep) end
  for i = 1, d do px(x1 + i, y - 6 - rise(i), P.ink) end
  plinth(x0, x1, y, d, 1)
  door(x - 3, x, y - 7, y, { open = true, frame = P.wood.deep, arch = 2, nostep = true })
  px(x0 + 1, yt + 2, P.ember.hi) px(x0 + 2, yt + 2, P.ember.hi)
end
local function snail(x, y)
  castRound(x, y, 7, 3)
  local jar = c:rrect(x - 6, y - 13, x + 6, y, 2)
  local mouth = E(x, y - 13, 5, 1)
  local lidT, lidS = E(x + 3, y - 17, 6, 1), c:rect(x - 3, y - 16, x + 9, y - 15)
  ink(jar, mouth, lidT, lidS)
  cyl(jar, x, 6, WIN, { t1 = .8, t2 = .3 })
  -- soil and the leaf inside, then glass highlights on top
  local soil = c:rect(x - 5, y - 4, x + 5, y - 1):clip(jar)
  cyl(soil, x, 6, P.wood, { t1 = 2 })
  R(x - 5, y - 4, x + 5, y - 4, P.wood.hi)
  R(x - 2, y - 6, x, y - 5, P.moss.base) px(x - 1, y - 7, P.moss.hi) px(x + 2, y - 5, P.moss.shade)
  -- mouth: lit far rim, dark opening
  c:fillMask(mouth, WIN.deep) mouth:each(function(a, b) if not mouth:has(a, b - 1) then px(a, b, P.sky.hi) end end)
  -- lid (slid aside): lit top ellipse over a shaded edge band
  c:fillMask(lidS, P.wood.shade) R(x - 3, y - 15, x + 9, y - 15, P.wood.deep)
  c:fillMask(lidT, P.wood.base) lidT:each(function(a, b) if not lidT:has(a, b - 1) or not lidT:has(a - 1, b) then px(a, b, P.wood.hi) end end)
  -- vertical specular streak and a small reflected glint on the shade side
  R(x - 4, y - 11, x - 4, y - 7, P.cream) px(x - 3, y - 11, P.cream) px(x + 4, y - 9, WIN.hi) px(x + 4, y - 8, WIN.hi)
end
------------------------------------------------------------ FRONT ROW (feet y 122)
local function quail(x, y)
  local x0, x1, yt, d = x - 11, x + 8, y - 12, 4
  cast(x0, x1, y, d, 8, 4)
  local front, side = c:rect(x0, yt, x1, y), sideWall(x1, yt, y, d, 1)
  local F, S = hipRoof(x0, x1, yt - 1, y - 21, 2, 7, d)
  ink(front, side, F, S)
  local W = wallTones(P.wood.base, P.wood.hi)
  paintWalls(front, side, W, 13)
  for xx = x0 + 3, x1 - 1, 4 do R(xx, yt, xx, y, lerp(P.wood.base, P.wood.shade, .6)) end
  for xx = x0 + 1, x1, 4 do if math.abs(xx - x) > 4 then px(xx, yt + 3, P.wood.hi) px(xx, y - 2, P.wood.hi) end end
  side:each(function(xx, yy) if (yy + rise(xx - x1)) % 3 == 0 then px(xx, yy, W.sdark) end end)
  paintRoof(F, S, ROOF, { h = 3, w = 4, light = 14, dark = 8, seed = 9 })
  eaveShadow(x0, x1, yt, d, W, 1)
  plinth(x0, x1, y, d, 1)
  door(x - 3, x + 3, y - 9, y, { open = true, frame = P.wood.deep, arch = 2, nostep = true })
  -- ramp up to the door, lit top edge
  R(x - 3, y, x + 3, y, P.wood.hi)
end
local function silk(x, y)
  local x0, x1, yt, d = x - 10, x + 7, y - 18, 4
  cast(x0, x1, y, d, 12, 4)
  local front, side = c:rect(x0, yt, x1, y), sideWall(x1, yt, y, d, 1)
  local F, S = hipRoof(x0, x1, yt - 1, y - 25, 2, 6, d)
  ink(front, side, F, S)
  local W = wallTones(P.wood.base, P.wood.hi)
  paintWalls(front, side, W, 17)
  side:each(function(xx, yy) if (xx - x1) % 2 == 1 then px(xx, yy, W.sdark) end end)
  paintRoof(F, S, P.dusk, { h = 2, w = 3, light = 0, dark = 0 })
  eaveShadow(x0, x1, yt, d, W, 1)
  -- three open shelves: dark back, shadow from the shelf above, a lit shelf board, left inner side in shade
  for _, sy in ipairs{ y - 16, y - 10, y - 4 } do
    R(x0 + 2, sy, x1 - 2, sy + 3, "#e6d0a0")
    R(x0 + 2, sy, x1 - 2, sy, lerp("#e6d0a0", DUSKSH, .35)) R(x0 + 2, sy, x0 + 2, sy + 3, lerp("#e6d0a0", DUSKSH, .25))
    R(x0 + 2, sy + 4, x1 - 2, sy + 4, P.wood.hi) R(x0 + 2, sy + 5 <= y and sy + 5 or y, x1 - 2, sy + 5 <= y and sy + 5 or y, P.wood.shade)
  end
  for _, t in ipairs{ {x - 6, y - 14}, {x + 1, y - 13}, {x - 4, y - 8}, {x + 2, y - 7}, {x - 5, y - 2} } do
    R(t[1], t[2], t[1] + 3, t[2] + 1, P.moss.base) px(t[1], t[2], P.moss.hi) px(t[1] + 3, t[2] + 1, P.moss.shade)
  end
  for _, t in ipairs{ {x + 4, y - 14}, {x - 1, y - 8}, {x + 3, y - 2} } do px(t[1], t[2], P.cream) px(t[1] + 1, t[2], P.stone.hi) end   -- cocoons
  for yy = yt + 1, y - 1, 4 do dk(x0, yy, "wood") dk(x1, yy + 2, "wood") end
  rimLight(front, P.wood.hi, P.wood.base)
end
local function tortoise(x, y)
  local x0, x1, d = x - 14, x + 11, 3
  cast(x0, x1, y, d, 3, 3)
  local fb = c:rect(x0, y - 3, x1, y)                      -- front board
  local floorM = HP.mask() for j = 1, 6 do for xx = x0 + j // 2, x1 + math.min(d, j // 2 + 1) do floorM:set(xx, y - 3 - j) end end
  local back = c:rect(x0 + 3, y - 11, x1 + 3, y - 10)      -- back board, seen over the straw
  local side = sideWall(x1, y - 3, y, d)
  local posts = HP.mask()
  for _, p in ipairs{ {x0, y - 6}, {x1 - 1, y - 6}, {x0 + 3, y - 13}, {x1 + 2, y - 13} } do posts:add(c:rect(p[1], p[2], p[1] + 1, p[2] + 3)) end
  ink(fb, floorM, back, side, posts)
  -- straw floor is a top plane, so it is the lightest; front boards lit, side in shade
  c:fillMask(floorM, STRAW.base)
  for yy = y - 9, y - 4 do for xx = x0, x1 + d do if floorM:has(xx, yy) and (xx + yy * 2) % 6 == 0 then dk(xx, yy, STRAW) lt(xx + 1, yy - 1, STRAW) end end end
  R(x0 + 3, y - 9, x1 + 3, y - 9, STRAW.shade)   -- the back board shades the far straw
  c:fillMask(back, P.wood.shade) R(x0 + 3, y - 11, x1 + 3, y - 11, P.wood.base)
  c:fillMask(fb, P.wood.base) R(x0, y - 3, x1, y - 3, P.wood.hi) R(x0, y, x1, y, P.wood.shade)
  for xx = x0 + 3, x1, 5 do px(xx, y - 1, P.wood.shade) end
  c:fillMask(side, P.wood.shade) for i = 1, d do px(x1 + i, y - 3 - rise(i), P.wood.base) end
  posts:each(function(a, b) px(a, b, ((a - x0) % 2 == 0) and P.wood.base or P.wood.shade) end)
  for _, p in ipairs{ {x0, y - 6}, {x1 - 1, y - 6}, {x0 + 3, y - 13}, {x1 + 2, y - 13} } do px(p[1], p[2], P.wood.hi) end
  -- the tortoise: a lit dome shell with scutes, a small shadow on the straw
  local shell = E(x - 1, y - 5, 5, 3)
  shadeUnder(E(x + 1, y - 2, 5, 1):cut(fb), .25)
  c:rim(shell, P.ink) ball(shell, x - 1, y - 5, 5, 3, P.moss)
  for yy = y - 7, y - 3 do dk(x - 3, yy, "moss") dk(x + 1, yy, "moss") end
  R(x + 4, y - 5, x + 6, y - 4, P.wood.hi) px(x + 6, y - 5, P.ink) px(x + 5, y - 4, P.wood.base)
end
local function butterfly(x, y)
  castRound(x, y, 11, 4)
  local a, b, f = E(x - 6, y - 12, 6, 5), E(x + 6, y - 13, 6, 5), E(x, y - 7, 11, 6)
  ink(a, b, f)
  ball(a, x - 6, y - 12, 6, 5, LEAFD, { nospec = true }) ball(b, x + 6, y - 13, 6, 5, LEAFD, { nospec = true })
  ball(f, x, y - 7, 11, 6, LEAFD, { nospec = true })
  f:each(function(xx, yy) if not f:has(xx, yy - 1) and (a:has(xx, yy - 1) or b:has(xx, yy - 1)) then px(xx, yy - 1, LEAFD.deep) end end)
  local all = a:copy():add(b):add(f)
  leaves(all, LEAFD, x - 11, x + 11, y - 17, y - 3, 6, 4)
  for _, fl in ipairs{ {x - 7, y - 14}, {x + 3, y - 10}, {x + 7, y - 16}, {x - 2, y - 15}, {x + 6, y - 6}, {x - 8, y - 7} } do
    R(fl[1], fl[2], fl[1] + 1, fl[2] + 1, P.dusk.hi) px(fl[1], fl[2], P.cream) px(fl[1] + 1, fl[2] + 1, P.dusk.base)
  end
end
local function fence(x, y)
  cast(x - 17, x + 19, y, 0, 0, 2)
  local rail1 = c:rect(x - 17, y - 12, x + 19, y - 10)
  local rail2 = c:rect(x - 17, y - 5, x + 19, y - 3)
  local posts, pside = HP.mask(), HP.mask()
  for xx = x - 17, x + 17, 11 do posts:add(c:rect(xx, y - 16, xx + 2, y)) pside:add(c:rect(xx + 3, y - 17, xx + 3, y - 1)) end
  local hen = E(x - 12, y - 8, 4, 3)
  local goat = c:rect(x - 2, y - 12, x + 5, y - 6)
  local gh = c:rect(x + 5, y - 15, x + 9, y - 10)
  ink(rail1, rail2, posts, pside)
  -- rails: lit top edge, base face, dark underside; posts: lit left, cool side face, capped top
  for _, ry in ipairs{ y - 12, y - 5 } do R(x - 17, ry, x + 19, ry, P.wood.hi) R(x - 17, ry + 1, x + 19, ry + 1, P.wood.base) R(x - 17, ry + 2, x + 19, ry + 2, P.wood.shade) end
  for xx = x - 15, x + 15, 5 do dk(xx, y - 11, "wood") dk(xx + 2, y - 4, "wood") end
  for xx = x - 17, x + 17, 11 do
    R(xx, y - 16, xx + 2, y, P.wood.base) R(xx, y - 16, xx, y, P.wood.hi) R(xx + 3, y - 17, xx + 3, y - 1, P.wood.shade)
    R(xx, y - 16, xx + 3, y - 16, P.wood.hi) px(xx + 3, y - 17, P.wood.base) px(xx + 2, y - 13, P.wood.shade) px(xx + 1, y, P.wood.shade) R(xx, y, xx + 2, y, P.wood.shade)
  end
  c:rim(hen, P.ink) ball(hen, x - 12, y - 8, 4, 3, P.ember)
  R(x - 16, y - 13, x - 15, y - 12, P.ember.base) px(x - 16, y - 13, P.ember.hi) px(x - 9, y - 11, P.gold.hi)
  local CR = { hi = P.cream, base = lerp(P.cream, P.stone.hi, .45), shade = P.stone.hi, deep = P.stone.base }
  c:rim(goat:copy():add(gh), P.ink)
  c:fillMask(goat, CR.base) c:fillMask(gh, CR.base)
  R(x - 2, y - 12, x + 4, y - 12, P.cream) R(x - 2, y - 12, x - 2, y - 7, P.cream)
  R(x - 1, y - 6, x + 5, y - 6, CR.shade) R(x + 5, y - 9, x + 5, y - 6, CR.shade) px(x + 4, y - 6, CR.deep)
  R(x + 5, y - 15, x + 8, y - 15, P.cream) R(x + 6, y - 10, x + 9, y - 10, CR.shade) R(x + 9, y - 14, x + 9, y - 10, CR.shade)
  px(x + 6, y - 17, P.wood.base) px(x + 8, y - 17, P.wood.base) px(x + 8, y - 13, P.ink)
end
local function bigpond(x, y)
  local water = E(x, y - 7, 18, 9)
  c:rim(water, lerp(BASE.lawn2, DUSKSH, .45))
  c:fillMask(water, P.sea.base)
  -- the water sits below the grass: the far bank shows as an earth lip in shade, and the bank throws a
  -- shadow on the water along the upper left; the open water lower right catches the sky
  local lip = water:copy():cut(E(x + 1, y - 5, 18, 8))
  c:fillMask(lip, lerp(P.wood.shade, DUSKSH, .25))
  lip:each(function(a, b) if not lip:has(a, b - 1) then px(a, b, P.wood.base) end end)
  local open = water:copy():cut(lip)
  local shade = open:copy():cut(open:copy():shift(2, 2))
  c:fillMask(shade, P.sea.shade)
  open:each(function(a, b) if not open:has(a + 1, b) and not shade:has(a, b) and (a - x) + (b - y) * 2 > 0 then px(a, b, P.sea.hi) end end)
  R(x - 9, y - 11, x - 3, y - 11, P.sea.hi) R(x + 3, y - 5, x + 11, y - 5, P.sky.hi)
  E(x - 2, y - 3, 5, 1):edge():each(function(xx, yy) if yy < y - 3 and (xx + yy) % 2 == 0 and c:get(xx, yy) == P.sea.base then px(xx, yy, P.sea.hi) end end)
  -- near-bank pebbles: each a tiny lit dome
  for _, p in ipairs{ {x - 14, y - 1}, {x - 9, y + 1}, {x + 6, y + 1}, {x + 12, y} } do R(p[1], p[2], p[1] + 2, p[2] + 1, P.stone.base) R(p[1], p[2], p[1] + 1, p[2], P.stone.hi) px(p[1] + 2, p[2] + 1, P.stone.shade) end
  -- lily pads cast a small shadow on the water
  for _, l in ipairs{ {x - 8, y - 6}, {x + 7, y - 9} } do
    local pad = E(l[1], l[2], 4, 2)
    shadeUnder(pad:copy():shift(1, 1):cut(pad), .3)
    c:fillMask(pad, P.moss.base) pad:each(function(a, b) if not pad:has(a, b - 1) or not pad:has(a - 1, b) then px(a, b, P.moss.hi) elseif not pad:has(a, b + 1) then px(a, b, P.moss.shade) end end)
  end
  px(x - 8, y - 8, P.petal.base) px(x - 9, y - 8, P.petal.hi)
  local frog = E(x + 8, y - 11, 3, 2)
  c:rim(frog, P.ink) ball(frog, x + 8, y - 11, 3, 2, P.moss, { nospec = true }) px(x + 7, y - 13, P.cream) px(x + 9, y - 13, P.cream)
end
local function reeds(x, y)
  for i, xx in ipairs{ x - 20, x - 18, x - 16 } do local h = 9 + (i % 2) * 2; R(xx, y - 6 - h, xx, y - 6, P.moss.shade) R(xx, y - 8 - h, xx, y - 6 - h, P.wood.shade) px(xx, y - 8 - h, P.wood.base) end
end


------------------------------------------------------------ LIFE: fill the gaps between the clickable buildings (patch5)
-- Tap boxes of the 17 buildings (240 grid). Nothing in this section may touch them, the path, the stream or the bridge.
local EXC = { {4,39,37,64},{43,37,75,64},{95,13,148,64},{168,40,204,64},{209,47,234,64},{16,73,33,94},{44,77,77,94},{88,77,110,94},{131,73,152,94},{174,73,192,94},{211,75,228,94},{9,104,48,124},{50,100,79,124},{88,96,114,124},{125,108,156,124},{167,103,194,123},{200,109,239,130} }
local BL = {}
local PBIG = pathM:copy():add(pathM:copy():shift(0, 1))
for y = 0, 134 do for x = 0, 239 do
  local b = false
  if y < 38 or x < 1 or x > 238 or y > 133 then b = true end
  if not b and PBIG:has(x, y) then b = true end
  if not b then for _, e in ipairs(EXC) do if x >= e[1] and x < e[3] and y >= e[2] and y < e[4] then b = true break end end end
  if not b and y >= 84 and y <= 114 and math.abs(x - SX(y)) <= 4 then b = true end
  if not b and y >= 94 and y <= 104 and math.abs(x - SX(99)) <= 7 then b = true end
  if b then BL[y * 240 + x] = true end
end end
local function fits(x, y, w, h)
  for yy = y - h + 1, y do for xx = x, x + w - 1 do if BL[yy * 240 + xx] then return false end end end
  return true
end
local function claim(x, y, w, h) for yy = y - h, y do for xx = x, x + w - 1 do BL[yy * 240 + xx] = true end end end
local rn = 0
local function rand(n) rn = rn + 1; return hsh(rn * 7 + 3, rn * 13 + 5) % n end

local C = {
  r = P.ember.base, R = P.ember.shade, c = P.cream, y = P.gold.base, Y = P.gold.shade, g = P.moss.base, G = P.moss.shade, l = P.moss.hi,
  b = P.wood.base, B = P.wood.shade, p = P.petal.base, P = P.petal.shade, u = P.dusk.base, s = P.sea.base, S = P.sea.hi, k = P.stone.base, K = P.stone.shade,
  o = "#f08a30", O = "#c9611f", f = "#d9a070", F = "#8a5638", n = "#f0b98d", h = P.ember.base, a = P.sea.shade, w = "#fff4d6", e = P.ink, L = P.stone.hi,
}
local SPR = {
  mush = { ".rrr.", "rcrcr", "..c..", "..c.." },
  rock = { ".kLk..", "kkkkK.", "KKKKKK" },
  pumpkin = { "..g..", ".ooo.", "ooOoo", ".OoO." },
  hay = { ".yyyyyy.", "yyYyyYyy", "yyyyyyyy", "YyYyYyYy" },
  pot = { ".g.p.", "gggg.", ".ggg.", ".bBb.", "..B.." },
  logs = { ".bbbbbb.", "bcbbcbBb", "bBbcbbBb", ".bbbbbb." },
  cat = { "o.o....", "oooooo.", "ooOoOoo", ".oooooO" },
  hog = { ".kKkK..", "kKkKkKn", ".nn.nn." },
  rabbit = { "..f.f.", "..f.f.", ".ffff.", "fffeff", ".fcffc" },
  hen = { "...r..", "..ffy.", ".ffff.", "fffff.", ".y.y.." },
  chick = { ".y.", "yyo", ".o." },
  fern = { "l..l..", ".l.l.l", "..lgl.", "...g..", "...g.." },
  sign = { "yyyyy.", "..b...", "..b...", ".ppppp", "..b...", "..b...", "..b..." },
  bath = { "kkkkkk", ".kssk.", "..kk..", "..kk..", ".kkkk." },
  barrow = { ".p.y.p...", "rrrrrrr..", ".rrrrr.bb", "..k...k.." },
  can = { ".k....", "kkkkk.", "kkkkkk", "kkkkk." },
  gnomeA = { "..h..", ".hhh.", "hhhhh", ".nnn.", ".ccc.", ".aaa.", ".B.B." },
  gnomeB = { "..h..", ".hhh.", "hhhhh", ".nnn.", ".ccc.", "aaaaa", ".B.B." },
  lady = { "rKr", "rrr" },
  bench = { "bbbbbbbb", "BbbbbbbB", "B......B", "B......B" },
  lantern = { ".y.", "kyk", ".k.", ".k.", ".k.", ".k.", ".k.", "kkk" },
  house = { ".rr.", "rrrr", "bkkb", "bbbb", ".B..", ".B..", ".B..", ".B.." },
  mail = { "rrrr", "rccr", "rrrr", ".B..", ".B..", ".B..", ".B.." },
  frog = { ".g.g.", "ggggg", "gGgGg", "g...g" },
  snail = { "..bb.", ".bBb.", "nnnbb", "nnnnn" },
  duck = { "..yy..", ".ccyy.", "cccco.", ".ccc.." , "..o.o." },
  sparrow = { ".bb.", "bbbk", ".bb.", ".o.o" },
  picnic = { ".r.y..", "rcrcrcrc", "crcrcrcr" },
  clover = { "c.c", ".g.", "g.g" },
}
local OUTLINED = { mush = 1, rock = 1, pumpkin = 1, hay = 1, pot = 1, logs = 1, cat = 1, hog = 1, rabbit = 1, hen = 1, chick = 1, fern = 0, sign = 1, bath = 1, barrow = 1, can = 1, gnomeA = 1, gnomeB = 1, lady = 0, bench = 1, lantern = 1, house = 1, mail = 1, frog = 1, snail = 1, duck = 1, sparrow = 1, picnic = 1, clover = 0 }
local PROP = { gnomeA = function(x, y) R(x + 5, y - 3, x + 7, y - 2, C.k) px(x + 8, y - 4, C.k) end,                       -- watering can
               gnomeB = function(x, y) R(x - 3, y - 2, x - 1, y, C.b) px(x - 3, y - 3, C.r) px(x - 2, y - 3, C.y) end }   -- basket of apples
local things = {}
local function sprite(name, x, y) things[#things + 1] = { name, x, y } end
local function cands(w, h, zk)
  local list, zi = {}, zk and zidx(zk)
  for y = h + 39, 133, 2 do for x = 2, 238 - w, 2 do
    if (not zi or ZI[(y - 1) * 240 + x + w // 2] == zi) and fits(x, y, w, h) then list[#list + 1] = { x, y } end
  end end
  return list
end
local function pick(list) if #list == 0 then return nil end return list[1 + rand(#list)] end
local function try(name, zk)
  local rows = SPR[name]; local w, h = #rows[1], #rows
  local p = pick(cands(w, h, zk)); if not p then return false end
  claim(p[1], p[2], w, h); sprite(name, p[1], p[2]); return true
end
-- flowers: a tiny stem and a head, in a palette per area
local function flower(kind, col, x, y)
  px(x + 1, y, C.g) px(x + 1, y - 1, C.G)
  if kind == "daisy" then px(x + 1, y - 2, C.y) px(x, y - 2, col) px(x + 2, y - 2, col) px(x + 1, y - 3, col) px(x + 1, y - 1, col == C.c and C.l or C.G)
  elseif kind == "tulip" then px(x, y - 3, col) px(x + 2, y - 3, col) R(x, y - 2, x + 2, y - 2, col) px(x + 1, y - 1, C.g)
  elseif kind == "lav" then for i = 0, 3 do px(x + 1, y - 1 - i, i % 2 == 0 and col or C.u) end
  else px(x + 1, y - 2, col) px(x + 1, y - 3, col) px(x, y - 2, col) px(x + 2, y - 2, col) px(x + 1, y - 4, C.y) end   -- pom
end
local function bush(x, y, rx, ry, flowers)
  local m = E(x, y - ry, rx, ry)
  claim(x - rx, y, rx * 2, ry * 2)
  c:rim(m, P.ink) c:part(m, "moss", { band = 2, pop = { x - rx + 2, y - ry * 2 + 1 } })
  for i = 1, rx do px(x - rx + 1 + rand(rx * 2 - 1), y - ry * 2 + 1 + rand(ry), P.moss.hi) end
  for i = 1, flowers do px(x - rx + 2 + rand(rx * 2 - 3), y - ry * 2 + 1 + rand(ry * 2 - 2), (i % 2 == 0) and C.p or C.c) end
end
local function tree(x, y, blossom)
  local trunk = c:rect(x - 1, y - 6, x, y)
  local crown = E(x, y - 11, 5, 4):add(E(x - 3, y - 8, 3, 3)):add(E(x + 3, y - 8, 3, 3)):add(E(x, y - 14, 3, 3))
  c:fillMask(E(x + 1, y + 1, 6, 1), DUSKSH)
  c:rim(trunk:copy():add(crown), P.ink)
  c:part(trunk, "wood", { band = 1, nopop = true })
  c:part(crown, blossom and "petal" or "moss", { band = 2, pop = { x - 3, y - 14 } })
  for i = 1, 10 do local lx, ly = x - 6 + rand(13), y - 16 + rand(10); if crown:has(lx, ly) then px(lx, ly, blossom and P.petal.hi or P.moss.hi) end end
  for i = 1, 4 do local lx, ly = x - 5 + rand(11), y - 14 + rand(8); if crown:has(lx, ly) then px(lx, ly, blossom and C.c or C.r) end end
end
local function treeAt(zk, blossom)
  local p = pick(cands(13, 17, zk)); if not p then return false end
  claim(p[1], p[2], 13, 17); things[#things + 1] = { "tree", p[1] + 6, p[2], blossom }; return true
end
local function bushAt(zk, rx, ry, fl)
  local p = pick(cands(rx * 2, ry * 2, zk)); if not p then return false end
  claim(p[1], p[2], rx * 2, ry * 2); things[#things + 1] = { "bush", p[1] + rx, p[2], rx, ry, fl }; return true
end
local function flowersAt(zk, n, cols, kinds)
  for i = 1, n do
    local p = pick(cands(3, 5, zk)); if not p then return end
    claim(p[1], p[2], 3, 5); things[#things + 1] = { "flower", p[1], p[2], kinds[1 + rand(#kinds)], cols[1 + rand(#cols)] }
  end
end
local PINK, WH, YEL, BLU, VIO, RED = C.p, C.c, C.y, C.S, C.u, C.r
-- every area gets a few chosen residents, then flowers fill what is left
-- flowers first so they claim colour spots before the greenery does
for _, k in ipairs{ "greenhouse", "tailor", "kitchen", "tool_shed", "compost_bin", "beehive", "root_cellar", "worm_farm", "ladybird_lodge", "snail_jar", "rain_barrel", "fence", "quail_coop", "silk_shelf", "tortoise_run", "butterfly_bush", "frog_pond" } do
  flowersAt(k, 4, { PINK, WH, YEL, BLU, VIO, RED }, { "daisy", "tulip", "lav", "pom" })
end
for _, k in ipairs{ "compost_bin", "tool_shed", "tool_shed", "greenhouse", "beehive", "tailor", "ladybird_lodge", "snail_jar", "silk_shelf", "quail_coop", "tortoise_run", "worm_farm" } do treeAt(k, k == "greenhouse" or k == "beehive" or k == "tailor" or k == "tortoise_run") end
for _, k in ipairs{ "greenhouse", "beehive", "ladybird_lodge", "butterfly_bush", "tortoise_run", "tailor", "kitchen" } do bushAt(k, 6, 3, 4) bushAt(k, 4, 3, 3) end
for _, k in ipairs{ "compost_bin", "silk_shelf", "snail_jar", "quail_coop", "fence", "tool_shed", "worm_farm", "rain_barrel", "root_cellar", "kitchen", "tailor" } do bushAt(k, 5, 3, 0) bushAt(k, 4, 2, 0) end
-- gnomes at work, animals, and props
for _, k in ipairs{ "greenhouse", "kitchen", "root_cellar", "butterfly_bush", "worm_farm", "silk_shelf", "tool_shed" } do try(rand(2) == 0 and "gnomeA" or "gnomeB", k) end
try("cat", "tailor") try("cat", "kitchen") try("cat", "quail_coop") try("hog", "compost_bin") try("hog", "silk_shelf") try("rabbit", "beehive") try("rabbit", "ladybird_lodge") try("rabbit", "butterfly_bush") try("rabbit", "greenhouse") try("hen", "kitchen") try("hen", "fence") try("hen", "fence") try("hen", "quail_coop") try("hen", "quail_coop") try("hen", "tortoise_run")
try("chick", "quail_coop") try("chick", "quail_coop") try("chick", "fence") try("hay", "quail_coop") try("logs", "tool_shed") try("logs", "compost_bin")
try("barrow", "greenhouse") try("can", "root_cellar") try("sign", "kitchen") try("bath", "kitchen") try("pumpkin", "root_cellar") try("pumpkin", "root_cellar") try("pumpkin", "tortoise_run")
for _, k in ipairs{ "compost_bin", "worm_farm", "snail_jar", "silk_shelf", "ladybird_lodge", "tortoise_run", "quail_coop" } do try("mush", k) try("mush", k) try("mush", k) end
for _, k in ipairs{ "snail_jar", "silk_shelf", "worm_farm", "quail_coop", "rain_barrel", "ladybird_lodge", "compost_bin" } do try("fern", k) try("fern", k) end
for _, k in ipairs{ "tool_shed", "tortoise_run", "rain_barrel", "kitchen" } do try("rock", k) try("rock", k) end
for _, k in ipairs{ "tailor", "kitchen", "kitchen", "rain_barrel" } do try("pot", k) end
try("lady", "ladybird_lodge") try("lady", "ladybird_lodge")

-- patch6: more of everything, in and amongst the buildings
for _, k in ipairs{ "greenhouse", "tailor", "kitchen", "tool_shed", "compost_bin", "beehive", "root_cellar", "worm_farm", "ladybird_lodge", "snail_jar", "rain_barrel", "fence", "quail_coop", "silk_shelf", "tortoise_run", "butterfly_bush", "frog_pond" } do
  treeAt(k, k == "greenhouse" or k == "beehive" or k == "tailor" or k == "butterfly_bush" or k == "fence")
  bushAt(k, 4, 3, 2) bushAt(k, 3, 2, 0)
  try("clover", k) try("clover", k) try("sparrow", k)
end
for _, k in ipairs{ "kitchen", "tailor", "greenhouse", "tortoise_run" } do try("bench", k) end
for _, k in ipairs{ "kitchen", "tailor", "root_cellar", "snail_jar", "fence", "frog_pond", "quail_coop", "tool_shed" } do try("lantern", k) end
for _, k in ipairs{ "quail_coop", "tool_shed", "greenhouse", "silk_shelf" } do try("house", k) end
try("mail", "fence") try("mail", "kitchen")
for _, k in ipairs{ "frog_pond", "snail_jar", "rain_barrel", "silk_shelf" } do try("frog", k) try("snail", k) end
for _, k in ipairs{ "fence", "quail_coop", "frog_pond", "rain_barrel" } do try("duck", k) end
for _, k in ipairs{ "beehive", "butterfly_bush", "greenhouse" } do try("picnic", k) end
for _, k in ipairs{ "greenhouse", "kitchen", "root_cellar", "butterfly_bush", "worm_farm", "silk_shelf", "tool_shed", "fence", "quail_coop", "tailor" } do try(rand(2) == 0 and "gnomeA" or "gnomeB", k) end
for _, k in ipairs{ "beehive", "ladybird_lodge", "butterfly_bush", "greenhouse", "fence", "tortoise_run", "tailor", "kitchen" } do try("rabbit", k) try("cat", k) try("hen", k) end
for _, k in ipairs{ "root_cellar", "tortoise_run", "ladybird_lodge", "worm_farm" } do try("pumpkin", k) try("pumpkin", k) end
for _, k in ipairs{ "compost_bin", "worm_farm", "snail_jar", "silk_shelf", "ladybird_lodge", "tortoise_run", "quail_coop", "fence", "tool_shed", "root_cellar", "rain_barrel" } do try("mush", k) try("mush", k) try("fern", k) try("rock", k) end
for _, k in ipairs{ "greenhouse", "tailor", "kitchen", "tool_shed", "compost_bin", "beehive", "root_cellar", "worm_farm", "ladybird_lodge", "snail_jar", "rain_barrel", "fence", "quail_coop", "silk_shelf", "tortoise_run", "butterfly_bush", "frog_pond" } do
  flowersAt(k, 14, { PINK, WH, YEL, BLU, VIO, RED }, { "daisy", "tulip", "lav", "pom" })
end
-- flowers by area
flowersAt("beehive", 22, { PINK, WH, YEL, BLU }, { "daisy", "tulip", "lav", "pom" })
flowersAt("butterfly_bush", 18, { VIO, PINK, C.S }, { "lav", "daisy", "pom" })
flowersAt("ladybird_lodge", 14, { RED, YEL, WH }, { "daisy", "tulip" })
flowersAt("greenhouse", 12, { PINK, YEL, WH }, { "tulip", "daisy" })
flowersAt("tortoise_run", 10, { YEL, WH }, { "daisy" })
flowersAt("fence", 10, { PINK, WH, YEL }, { "daisy", "pom" })
flowersAt(nil, 400, { PINK, WH, YEL, BLU, VIO, RED }, { "daisy", "tulip", "lav", "pom" })
do local cnt = {} for _, t in ipairs(things) do cnt[t[1]] = (cnt[t[1]] or 0) + 1 end local o = {} for k, v in pairs(cnt) do o[#o + 1] = k .. "=" .. v end print("LIFE", #things, table.concat(o, " ")) local free = 0 for y = 38, 133 do for x = 1, 238 do if not BL[y * 240 + x] then free = free + 1 end end end print("free after", free) end
-- grass tufts fill the last odd gaps
for i = 1, 1200 do
  local x, y = 2 + rand(236), 40 + rand(93)
  if fits(x, y, 3, 3) then claim(x, y, 3, 3); things[#things + 1] = { "tuft", x, y } end
end
-- draw far to near
table.sort(things, function(a, b) return a[3] < b[3] end)
for _, t in ipairs(things) do
  local nm, x, y = t[1], t[2], t[3]
  if nm == "tree" then tree(x, y, t[4])
  elseif nm == "bush" then bush(x, y, t[4], t[5], t[6])
  elseif nm == "flower" then flower(t[4], t[5], x, y)
  elseif nm == "tuft" then px(x, y, C.G) px(x + 2, y, C.G) px(x + 1, y - 1, C.g) px(x + 1, y, C.g) px(x, y - 1, C.l)
  else
    local rows = SPR[nm]
    local w, h = #rows[1], #rows
    if OUTLINED[nm] == 1 then
      local m = HP.mask()
      for j, row in ipairs(rows) do for i = 1, #row do if row:sub(i, i) ~= "." then m:set(x + i - 1, y - h + j) end end end
      c:rim(m, P.ink)
    end
    c:paint(rows, x, y - h + 1, C)
    if PROP[nm] then PROP[nm](x, y) end
    local v = c:get(x + 1, y + 1); if v and nm ~= "fern" and nm ~= "lady" then for xx = x + 1, x + w - 2 do local g = c:get(xx, y + 1); if g then px(xx, y + 1, lerp(g, DUSKSH, .3)) end end end
  end
end

------------------------------------------------------------ PLACE THEM: cast shadow, then building; tap box = bbox of changed pixels after the shadow
local FEET = { 62, 92, 122 }
local POS = { fence = 27, quail_coop = 64 }
local DRAW = { greenhouse = greenhouse, tailor = tailor, kitchen = kitchen, tool_shed = shed, compost_bin = compost, beehive = beehive, root_cellar = cellar, worm_farm = worm,
  ladybird_lodge = lady, snail_jar = snail, rain_barrel = barrel, fence = fence, quail_coop = quail, silk_shelf = silk, tortoise_run = tortoise, butterfly_bush = butterfly, frog_pond = bigpond }
local NAMES = { greenhouse = "Greenhouse", tailor = "Tailor", kitchen = "Kitchen", tool_shed = "Tool Shed", compost_bin = "Compost Bin", beehive = "Beehive", root_cellar = "Root Cellar",
  worm_farm = "Worm Farm", ladybird_lodge = "Ladybird Lodge", snail_jar = "Snail Jar", rain_barrel = "Rain Barrel", fence = "The fence", quail_coop = "Quail Coop",
  silk_shelf = "Silkworm Shelf", tortoise_run = "Tortoise Run", butterfly_bush = "Butterfly Bush", frog_pond = "Frog Pond" }
for _, z in ipairs(ZONES) do
  local k = z[1]
  local x = POS[k] or z[2]
  local y = (z[3] < 70 and FEET[1]) or (z[3] < 105 and FEET[2]) or FEET[3]
  if k == "frog_pond" then y = y + 4; reeds(x, y) end
  local snap = snapshot()
  CURSNAP = nil
  -- (ground only: the building states are separate sprites)
  snap = CURSNAP or snap
  local x0, y0, x1, y1 = 999, 999, -1, -1
  for i, v in pairs(c.pix) do
    if snap[i] ~= v then local yy, xx = i // 240, i % 240; if xx < x0 then x0 = xx end if xx > x1 then x1 = xx end if yy < y0 then y0 = yy end if yy > y1 then y1 = yy end end
  end
  boxes[#boxes + 1] = { k = k, n = NAMES[k], box = { x0, y0, x1 + 1, y1 + 1 } }
  AT[k] = { x, y }
end
for i, a in ipairs(boxes) do for j = i + 1, #boxes do local b = boxes[j]
  if a.box[1] < b.box[3] and a.box[3] > b.box[1] and a.box[2] < b.box[4] and a.box[4] > b.box[2] then print("WARN box " .. a.k .. " overlaps " .. b.k) end
end end

------------------------------------------------------------ AIR: butterflies, bees, dragonflies and birds, over the free space only
do
  local function freeAt(x, y) return not BL[y * 240 + x] and not BL[(y + 1) * 240 + x] end
  local n = 0
  for t = 1, 400 do
    if n >= 36 then break end
    local x, y = 3 + rand(232), 40 + rand(92)
    if freeAt(x, y) and freeAt(x + 2, y) then
      local k = n % 4
      if k == 0 then px(x, y, C.p) px(x + 2, y, C.p) px(x + 1, y + 1, P.ink) px(x + 1, y, C.P)                    -- butterfly, pink
      elseif k == 1 then px(x, y, C.S) px(x + 2, y, C.S) px(x + 1, y + 1, P.ink)                                      -- butterfly, blue
      elseif k == 2 then px(x, y, C.y) px(x + 1, y, P.ink) px(x, y - 1, C.w)                                          -- bee
      else px(x, y, C.s) px(x + 1, y, C.s) px(x + 2, y, C.s) px(x + 1, y - 1, C.S) end                               -- dragonfly
      n = n + 1
    end
  end
  for _, b in ipairs{ { 20, 33 }, { 150, 34 }, { 226, 33 } } do R(b[1], b[2], b[1] + 3, b[2] + 1, P.ink) px(b[1] + 1, b[2], C.b) px(b[1] + 3, b[2], C.y) end   -- sparrows on the hedge
  for _, b in ipairs{ { 70, 12 }, { 76, 9 }, { 83, 13 }, { 92, 8 } } do px(b[1], b[2], P.ink) px(b[1] + 1, b[2] - 1, P.ink) px(b[1] + 2, b[2], P.ink) end    -- a small flock
end

------------------------------------------------------------ OUT
c:finish{ outline = false }
HP.assertClean(c)
local base = out .. "garden-ground"
c:save{ aseprite = base .. ".aseprite", png = base .. ".png", scale = 2 }
local f = io.open(base .. ".json", "w")
local parts = {}
for _, b in ipairs(boxes) do
  parts[#parts + 1] = string.format('{"k":"%s","n":"%s","box":[%d,%d,%d,%d]}', b.k, b.n, b.box[1] * 2, b.box[2] * 2, b.box[3] * 2, b.box[4] * 2)
end
f:write("[" .. table.concat(parts, ",") .. "]") f:close()
print(look, "ok", #boxes, "spots")
