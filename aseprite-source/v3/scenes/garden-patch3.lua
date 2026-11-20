-- garden-patch3: texture + quirk pass on top of garden-patch2.lua (Hearth Pop v3). 240x135 grid, x2 = 480x270.
-- Texture: roof tile courses (light, dark and mossy tiles), thatch and shingle bands, brick and stone courses,
-- plank grain and nail dots, glass mullions and glints, barrel staves and bevelled hoops, 3-tone leaf clusters,
-- straw strands, pond ripples. Every texture mark is one ramp step from the pixel it replaces; ground stays flat.
-- Run: AppRun -b --script-param out=<dir>/ --script-param look=golden --script garden-patch3.lua
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
local c = HP.canvas{ w = 240, h = 135, scale = 2, name = "garden-patch3-" .. look }
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
local function shadow(x, y, rx) shadeUnder(E(x, y, rx, 2), .26) end
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
-- tile/shingle courses inside a mask: a darker course line every `h` rows, staggered joints every `w` px,
-- and a few lighter and darker whole tiles picked by hash (not random noise: one tile in ~7).
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
local function obj(parts)
  local u = HP.mask()
  for _, p in ipairs(parts) do u:add(p[1]:copy()) end
  c:rim(u, P.ink)
  for _, p in ipairs(parts) do c:part(p[1], p[2], p[3] or {}) end
end

------------------------------------------------------------ BACK ROW (feet y 62)
-- small texture recipes reused below
local function strands(m, r, y0, y1, every, gap)   -- short straw / grain dashes on a staggered regular grid
  for y = y0, y1, gap or 2 do for x = 0, 239 do
    if m:has(x, y) and m:has(x - 1, y) and m:has(x + 1, y) and m:has(x, y + 1) and (x + y) % every == 0 then dk(x, y, r) end
  end end
end
local function leaves(m, r, x0, x1, y0, y1, sx, sy)   -- 3-tone leaf clusters: lit cap over a dark underside
  for gy = y0, y1, sy do
    local row = (gy - y0) // sy
    for gx = x0 + (row % 2) * (sx // 2), x1, sx do
      if m:shrink(1):has(gx, gy) and m:shrink(1):has(gx + 2, gy + 1) then
        lt(gx, gy, r) lt(gx + 1, gy, r) dk(gx + 1, gy + 1, r) dk(gx + 2, gy + 1, r)
      end
    end
  end
end
local SHEDR = { hi = P.sea.base, base = P.sea.shade, shade = P.sea.deep, deep = "#22305a" }
local SLATE = { hi = P.stone.base, base = P.stone.shade, shade = P.stone.deep, deep = "#2e2f48" }
local HEAP = { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = "#3a2430" }
local STRAW = { hi = "#fff0c0", base = "#f0d58c", shade = "#d9b46a", deep = P.gold.shade }

local function greenhouse(x, y)
  local body = c:rect(x - 13, y - 14, x + 13, y)
  local roof = c:poly{ {x - 15, y - 14}, {x, y - 23}, {x + 15, y - 14} }
  obj{ { body, WIN, { nopop = true } }, { roof, WIN, { nopop = true } } }
  -- roof glazing bars (lit glass tone, one step) and a horizontal transom across the walls
  for _, xx in ipairs{ x - 8, x - 1, x + 1, x + 8 } do for yy = y - 22, y - 15 do if roof:shrink(1):has(xx, yy) then lt(xx, yy, WIN) end end end
  ltrow(x - 12, x + 12, y - 8, WIN)
  for xx = x - 13, x + 13, 6 do R(xx, y - 14, xx, y, P.cream) end
  R(x - 13, y - 14, x + 13, y - 14, P.cream) R(x - 13, y - 1, x + 13, y, P.stone.base)
  for xx = x - 11, x + 13, 4 do dk(xx, y - 1, "stone") dk(xx + 2, y, "stone") end   -- brick sill joints
  for _, p in ipairs{ {x - 10, 8}, {x - 3, 11}, {x + 6, 9} } do R(p[1], y - p[2], p[1] + 2, y - 1, P.moss.base) px(p[1] + 1, y - p[2] - 1, P.petal.base) px(p[1] + 2, y - p[2] + 3, P.moss.shade) end
  -- glints: one diagonal per lit pane (upper left) and a small one lower right
  px(x - 11, y - 12, P.cream) px(x - 10, y - 13, P.cream)
  px(x - 5, y - 12, WIN.hi) px(x - 4, y - 13, WIN.hi)
  px(x - 6, y - 19, P.cream)
end
local function tailor(x, y)
  local wall = c:rect(x - 10, y - 14, x + 10, y)
  local roof = c:poly{ {x - 13, y - 14}, {x, y - 24}, {x + 13, y - 14} }
  obj{ { wall, "dusk", { band = 2 } }, { roof, "gold", { band = 2, nopop = true } } }
  -- thatch: a darker band every 3 rows with ragged straw ends, lit strand tips above each band
  for yy = y - 21, y - 15, 3 do
    for xx = x - 13, x + 13 do
      if roof:shrink(1):has(xx, yy) then
        if (xx + yy) % 4 ~= 0 then dk(xx, yy, "gold") end
        if (xx + yy) % 4 == 2 then lt(xx, yy - 1, "gold") end
      end
    end
  end
  -- wall: board seams in the cloth-dyed plaster, one step
  for _, xx in ipairs{ x - 4, x + 4 } do for yy = y - 13, y - 2 do dk(xx, yy, "dusk") end end
  R(x - 3, y - 9, x + 3, y, P.wood.deep)
  for _, yy in ipairs{ y - 7, y - 3 } do R(x - 2, yy, x + 2, yy, P.wood.shade) end   -- door plank seams
  for _, wx in ipairs{ x - 8, x + 5 } do
    R(wx, y - 11, wx + 3, y - 7, WIN.base) R(wx, y - 9, wx + 3, y - 9, WIN.shade) R(wx + 2, y - 11, wx + 2, y - 7, WIN.shade)   -- mullions
    px(wx, y - 11, WIN.hi)
  end
  R(x - 1, y - 21, x + 1, y - 18, P.petal.base) px(x, y - 22, P.cream)
  c:stitch{ { x - 9, y - 1 }, { x + 9, y - 1 } }
end
local function kitchen(x, y)
  local wall = c:rect(x - 20, y - 24, x + 20, y)
  local roof = c:poly{ {x - 26, y - 24}, {x, y - 43}, {x + 26, y - 24} }
  local chim = c:rect(x + 9, y - 45, x + 15, y - 28)
  obj{ { wall, PLASTER, { band = 3, nopop = true } }, { roof, ROOF, { band = 3 } }, { chim, "stone", { nopop = true } } }
  -- roof: tile courses (a darker course line every 3 rows, staggered joints, a few lighter and darker tiles),
  -- kept off the chimney so its stack stays one clean shape
  local tiles = roof:copy():cut(chim:grow(1))
  courses(tiles, ROOF, x - 26, x + 26, y - 42, y - 25, 3, 5, { light = 12, dark = 5, seed = 2 })
  -- a moss patch on the shady lower-left course
  px(x - 19, y - 28, P.moss.base) px(x - 18, y - 28, P.moss.base) px(x - 20, y - 27, P.moss.shade) px(x - 19, y - 27, P.moss.base)
  px(x - 18, y - 27, P.moss.shade) px(x - 17, y - 27, P.moss.shade)
  -- chimney: brick courses, staggered joints
  courses(chim, "stone", x + 9, x + 15, y - 44, y - 29, 3, 4, { light = 10, dark = 0, seed = 5 })
  R(x + 8, y - 46, x + 16, y - 45, P.stone.hi) dkrow(x + 9, x + 16, y - 45, "stone")
  for _, xx in ipairs{ x - 18, x - 8, x + 6, x + 16 } do R(xx, y - 22, xx, y - 1, P.wood.base) px(xx, y - 22, P.wood.shade) px(xx, y - 1, P.wood.shade) end
  -- plaster: a stone plinth course along the foot
  for xx = x - 19, x + 19 do if (xx - x) % 5 ~= 0 then dk(xx, y - 2, PLASTER) end end
  R(x - 4, y - 16, x + 4, y, P.wood.shade) R(x - 3, y - 15, x + 3, y, P.wood.base) px(x + 2, y - 8, P.gold.hi)
  for yy = y - 14, y - 1 do dk(x - 1, yy, "wood") end
  for _, yy in ipairs{ y - 12, y - 4 } do px(x - 3, yy, P.wood.hi) px(x + 1, yy, P.wood.hi) end   -- nail dots on the battens
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
  obj{ { wall, "wood", { band = 2, nopop = true } }, { roof, SHEDR, { band = 2, nopop = true } } }
  courses(roof, SHEDR, x - 14, x + 14, y - 20, y - 15, 3, 4, { light = 14, dark = 8, seed = 7 })   -- shingle bands
  for xx = x - 8, x + 8, 4 do R(xx, y - 13, xx, y - 1, P.wood.shade) end
  for xx = x - 10, x + 10, 4 do lt(xx, y - 12, "wood") if math.abs(xx - x) > 5 then lt(xx, y - 2, "wood") end end   -- nail dots
  for _, p in ipairs{ {x - 7, y - 9}, {x + 6, y - 6} } do dk(p[1], p[2], "wood") dk(p[1], p[2] + 1, "wood") end    -- grain knots
  R(x - 4, y - 10, x + 4, y, P.wood.deep) R(x - 3, y - 9, x + 3, y, P.wood.shade) px(x + 2, y - 5, P.gold.hi)
  for yy = y - 8, y - 1 do dk(x, yy, "wood") end
  local rake = c:rect(x + 14, y - 16, x + 14, y):add(c:rect(x + 12, y - 17, x + 16, y - 17))
  c:rim(rake, P.ink) R(x + 14, y - 16, x + 14, y, P.wood.base) R(x + 12, y - 17, x + 16, y - 17, P.stone.base)
end
local function compost(x, y)
  local bin = c:rect(x - 10, y - 8, x + 10, y)
  local heap = E(x, y - 9, 9, 4)
  obj{ { bin, LEAFD, { band = 2, nopop = true } }, { heap, HEAP, { band = 1, nopop = true } } }
  for xx = x - 7, x + 7, 4 do R(xx, y - 7, xx, y - 1, P.moss.base) end
  dkrow(x - 9, x + 9, y - 4, LEAFD)   -- board seam across the painted slats
  -- heap: straw and peel bits, one step from the soil
  for _, p in ipairs{ {x - 6, y - 10}, {x - 2, y - 9}, {x + 3, y - 10}, {x + 6, y - 9}, {x - 4, y - 7}, {x + 1, y - 7} } do lt(p[1], p[2], HEAP) lt(p[1] + 1, p[2], HEAP) end
  px(x + 7, y - 11, P.ember.base) px(x - 8, y - 9, P.moss.base)
end
local function beehive(x, y)
  local m = HP.mask()
  m:add(E(x, y - 6, 7, 4)) m:add(E(x, y - 11, 6, 3)) m:add(E(x, y - 15, 4, 3))
  obj{ { m, "gold", { band = 2 } } }
  strands(m, "gold", y - 16, y - 3, 3, 2)   -- coiled straw strands
  R(x - 6, y - 4, x - 5, y, P.wood.base) R(x + 5, y - 4, x + 6, y, P.wood.base)
  R(x - 1, y - 6, x + 1, y - 5, P.ink)
  R(x - 5, y - 9, x + 5, y - 9, P.gold.shade) R(x - 4, y - 13, x + 4, y - 13, P.gold.shade)
end
------------------------------------------------------------ MIDDLE ROW (feet y 92)
local function barrel(x, y)
  local b = c:rrect(x - 6, y - 14, x + 6, y, 2)
  local top = E(x, y - 14, 6, 2)
  obj{ { b, "wood", { band = 2 } }, { top, "sea", { band = 1, nopop = true } } }
  -- staves: one-step seams between the hoops
  for _, xx in ipairs{ x - 3, x + 1, x + 4 } do for yy = y - 12, y - 1 do if b:shrink(1):has(xx, yy) and not top:has(xx, yy) then dk(xx, yy, "wood") end end end
  -- iron hoops with a lit bevel on top and a rivet
  for _, hy in ipairs{ y - 11, y - 4 } do
    R(x - 6, hy, x + 6, hy + 1, P.stone.deep) R(x - 5, hy, x + 4, hy, P.stone.shade) px(x - 3, hy, P.stone.base) px(x - 4, hy + 1, P.stone.hi)
  end
  px(x - 2, y - 15, P.cream) px(x + 3, y - 14, P.sea.hi) px(x - 4, y - 14, P.sea.hi)
  R(x + 7, y - 6, x + 8, y - 5, P.stone.shade)   -- tap
end
local function cellar(x, y)
  local mound = E(x, y - 6, 15, 8):clip(c:rect(x - 20, y - 20, x + 20, y))
  local door = c:rrect(x - 5, y - 10, x + 5, y, 3)
  obj{ { mound, LEAFD, { band = 2 } } }
  leaves(mound, LEAFD, x - 14, x + 14, y - 12, y - 3, 6, 3)   -- turf clusters
  local arch = c:rect(x - 7, y - 12, x + 7, y)
  c:fillMask(arch, P.stone.base) R(x - 7, y - 12, x + 7, y - 11, P.stone.hi)
  -- arch stones: voussoir joints over the door, block courses down the jambs
  for _, xx in ipairs{ x - 4, x, x + 4 } do px(xx, y - 12, P.stone.base) px(xx, y - 11, P.stone.base) end
  for _, yy in ipairs{ y - 8, y - 4 } do dk(x - 7, yy, "stone") dk(x - 6, yy, "stone") dk(x + 6, yy, "stone") dk(x + 7, yy, "stone") end
  for _, yy in ipairs{ y - 6, y - 2 } do lt(x - 7, yy, "stone") lt(x + 6, yy, "stone") end
  c:part(door, "wood", { band = 1, nopop = true })
  R(x - 1, y - 9, x - 1, y - 1, P.wood.deep) px(x + 2, y - 5, P.gold.hi)
  for _, xx in ipairs{ x - 3, x + 2 } do for yy = y - 8, y - 1 do if door:shrink(1):has(xx, yy) then dk(xx, yy, "wood") end end end
end
local function worm(x, y)
  local t1 = c:rect(x - 9, y - 5, x + 9, y)
  local t2 = c:rect(x - 8, y - 10, x + 8, y - 6)
  local lid = c:rect(x - 9, y - 12, x + 9, y - 11)
  obj{ { t1, "sea", { band = 1, nopop = true } }, { t2, "sea", { band = 1, nopop = true, sep = true } }, { lid, { hi = P.sea.hi, base = P.sea.hi, shade = P.sea.base, deep = P.sea.shade }, { nopop = true, noshade = true } } }
  R(x - 6, y - 3, x + 6, y - 3, P.sea.deep) R(x - 5, y - 8, x + 5, y - 8, P.sea.deep)
  for xx = x - 6, x + 6, 3 do px(xx, y - 3, P.sea.base) px(xx + 1, y - 8, P.sea.base) end   -- vent holes, not one slot
  ltrow(x - 8, x + 8, y - 5, "sea")   -- moulded rim on the lower tray
end
local function lady(x, y)
  local wall = c:rect(x - 7, y - 11, x + 7, y)
  local roof = c:poly{ {x - 10, y - 11}, {x, y - 18}, {x + 10, y - 11} }
  obj{ { wall, "ember", { band = 2, nopop = true } }, { roof, SLATE, { band = 1, nopop = true } } }
  courses(roof, SLATE, x - 10, x + 10, y - 18, y - 12, 2, 3, { light = 18, dark = 0, seed = 3 })   -- slates
  for _, p in ipairs{ {x - 5, y - 9}, {x + 3, y - 9}, {x - 2, y - 5}, {x + 4, y - 4} } do R(p[1], p[2], p[1] + 1, p[2] + 1, P.ink) px(p[1], p[2], P.ember.deep) end
  for yy = y - 10, y - 1, 3 do dkrow(x - 6, x - 3, yy, "ember") dkrow(x + 2, x + 6, yy, "ember") end   -- boards
  R(x - 2, y - 7, x + 1, y, P.wood.deep) px(x - 6, y - 4, P.cream)
end
local function snail(x, y)
  local jar = c:rrect(x - 6, y - 13, x + 6, y, 2)
  local lid = c:rect(x - 3, y - 16, x + 9, y - 14)   -- slid aside (the escape)
  obj{ { jar, WIN, { band = 2, nopop = true } }, { lid, "wood", { band = 1, nopop = true } } }
  for xx = x - 2, x + 8, 3 do dk(xx, y - 15, "wood") end   -- lid grain
  R(x - 5, y - 4, x + 5, y - 1, P.wood.base) R(x - 5, y - 4, x + 5, y - 4, P.wood.shade)
  R(x - 2, y - 6, x, y - 5, P.moss.base) px(x - 1, y - 7, P.moss.hi) px(x + 2, y - 5, P.moss.shade)   -- the leaf it left behind
  -- glass: bright rim down the lit side, pale core glints, slime trail up the inside to the gap
  for yy = y - 11, y - 3 do lt(x - 5, yy, WIN) end
  px(x - 3, y - 11, P.cream) px(x - 3, y - 10, P.cream)
  px(x + 3, y - 10, WIN.hi) px(x + 4, y - 11, WIN.hi) px(x + 4, y - 12, WIN.hi)
end
------------------------------------------------------------ FRONT ROW (feet y 122)
local function quail(x, y)
  local coop = c:rect(x - 10, y - 12, x + 10, y)
  local roof = c:poly{ {x - 13, y - 12}, {x, y - 19}, {x + 13, y - 12} }
  obj{ { coop, "wood", { band = 2, nopop = true } }, { roof, ROOF, { band = 2, nopop = true } } }
  courses(roof, ROOF, x - 13, x + 13, y - 19, y - 13, 3, 4, { light = 14, dark = 8, seed = 9 })
  for xx = x - 7, x + 7, 4 do R(xx, y - 11, xx, y - 1, P.wood.shade) end
  for xx = x - 9, x + 9, 4 do if math.abs(xx - x) > 4 then lt(xx, y - 10, "wood") lt(xx, y - 2, "wood") end end   -- nail dots
  R(x - 3, y - 9, x + 3, y, P.wood.deep)
end
local function silk(x, y)
  -- a tall hutch with a little roof, mulberry leaves on the shelves, cocoons: unlike the fence
  local body = c:rect(x - 9, y - 18, x + 9, y)
  local roof = c:poly{ {x - 12, y - 18}, {x, y - 25}, {x + 12, y - 18} }
  obj{ { body, { hi = P.wood.hi, base = P.wood.base, shade = P.wood.shade, deep = P.wood.deep }, { nopop = true, band = 2 } }, { roof, "dusk", { band = 1, nopop = true } } }
  courses(roof, "dusk", x - 12, x + 12, y - 25, y - 19, 2, 3, { light = 0, dark = 0, nojoint = false })
  for _, sy in ipairs{ y - 16, y - 10, y - 4 } do R(x - 7, sy, x + 7, sy + 4, "#f2e2b8") R(x - 7, sy + 4, x + 7, sy + 4, P.wood.shade) R(x - 7, sy, x + 7, sy, "#e6d0a0") end
  for _, t in ipairs{ {x - 6, y - 14}, {x + 1, y - 13}, {x - 4, y - 8}, {x + 2, y - 7}, {x - 5, y - 2} } do
    R(t[1], t[2], t[1] + 3, t[2] + 1, P.moss.base) px(t[1], t[2], P.moss.hi) px(t[1] + 3, t[2] + 1, P.moss.shade)
  end
  for _, t in ipairs{ {x + 4, y - 15}, {x - 1, y - 9}, {x + 3, y - 2} } do R(t[1], t[2], t[1] + 1, t[2], P.cream) end   -- cocoons
  for yy = y - 17, y - 1, 4 do dk(x - 8, yy, "wood") dk(x + 8, yy + 2, "wood") end   -- frame grain
end
local function tortoise(x, y)
  local floorM = c:rect(x - 14, y - 7, x + 14, y)
  obj{ { floorM, STRAW, { band = 1, nopop = true } } }
  -- straw strands: short diagonal dashes on a regular staggered grid
  for yy = y - 6, y - 2, 2 do for xx = x - 13, x + 13 do if (xx + yy * 2) % 6 == 0 then dk(xx, yy, STRAW) lt(xx + 1, yy - 1, STRAW) end end end
  R(x - 14, y - 8, x + 14, y - 7, P.wood.base) R(x - 14, y - 1, x + 14, y, P.wood.base)
  for xx = x - 12, x + 12, 5 do dk(xx, y - 8, "wood") end
  for xx = x - 14, x + 14, 7 do R(xx, y - 11, xx, y - 7, P.wood.shade) px(xx, y - 11, P.wood.base) end
  local shell = E(x - 1, y - 4, 5, 3)
  c:rim(shell, P.ink) c:part(shell, "moss", { band = 1, nopop = true })
  for yy = y - 6, y - 2 do dk(x - 3, yy, "moss") dk(x + 1, yy, "moss") end   -- scutes
  lt(x - 5, y - 5, "moss") lt(x - 1, y - 6, "moss")
  R(x + 4, y - 4, x + 6, y - 3, P.wood.hi) px(x + 6, y - 4, P.ink)
end
local function butterfly(x, y)
  local m = HP.mask()
  m:add(E(x, y - 8, 11, 7)) m:add(E(x - 6, y - 12, 6, 5)) m:add(E(x + 6, y - 13, 6, 5))
  obj{ { m, LEAFD, { band = 3 } } }
  leaves(m, LEAFD, x - 11, x + 11, y - 17, y - 3, 6, 4)
  for _, f in ipairs{ {x - 7, y - 11}, {x + 3, y - 10}, {x + 7, y - 15}, {x - 2, y - 16}, {x + 6, y - 5} } do R(f[1], f[2], f[1] + 1, f[2] + 1, P.dusk.hi) px(f[1], f[2], P.cream) end
end
local function fence(x, y)
  local rail1 = c:rect(x - 17, y - 12, x + 17, y - 10)
  local rail2 = c:rect(x - 17, y - 5, x + 17, y - 3)
  local posts = HP.mask()
  for xx = x - 17, x + 17, 11 do posts:add(c:rect(xx, y - 16, xx + 2, y)) end
  obj{ { rail1, "wood", { nopop = true, noshade = true } }, { rail2, "wood", { nopop = true, noshade = true } }, { posts, "wood", { nopop = true } } }
  for xx = x - 15, x + 15, 5 do dk(xx, y - 11, "wood") dk(xx + 2, y - 4, "wood") end   -- rail grain
  for xx = x - 17, x + 17, 11 do lt(xx + 1, y - 11, "wood") lt(xx + 1, y - 4, "wood") dk(xx, y - 14, "wood") dk(xx, y - 13, "wood") end   -- nails, post grain
  local hen = E(x - 12, y - 8, 4, 3)
  c:rim(hen, P.ink) c:part(hen, "ember", { band = 1, nopop = true }) R(x - 16, y - 13, x - 15, y - 12, P.ember.base) px(x - 9, y - 11, P.gold.hi)
  local goat = c:rect(x - 2, y - 12, x + 5, y - 6)
  local gh = c:rect(x + 5, y - 15, x + 9, y - 10)
  local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
  c:rim(goat:copy():add(gh), P.ink) c:part(goat, CR, { band = 1, nopop = true }) c:part(gh, CR, { band = 1, nopop = true })
  px(x + 6, y - 17, P.wood.base) px(x + 8, y - 17, P.wood.base) px(x + 8, y - 13, P.ink)
end
local function bigpond(x, y)
  local water = E(x, y - 7, 18, 9)
  c:rim(water, lerp(BASE.lawn2, DUSKSH, .45))
  c:part(water, "sea", { band = 3, nopop = true })
  -- wet shine: a lit sky streak along the top, two broken ripple rings, reed reflections
  R(x - 11, y - 13, x - 4, y - 13, P.sea.hi) R(x - 13, y - 12, x - 11, y - 12, P.sea.hi)
  R(x + 3, y - 6, x + 11, y - 6, P.sea.hi)
  local i = 0
  E(x - 2, y - 3, 5, 1):edge():each(function(xx, yy) if yy < y - 3 and (xx + yy) % 2 == 0 and c:get(xx, yy) == P.sea.base then px(xx, yy, P.sea.hi) end end)
  E(x + 8, y - 9, 6, 2):edge():each(function(xx, yy) if (xx + yy) % 3 == 0 and c:get(xx, yy) == P.sea.base then px(xx, yy, P.sky.hi) end end)
  for _, xx in ipairs{ x - 16, x - 14 } do dk(xx, y - 5, "sea") dk(xx, y - 3, "sea") end
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
  AT[k] = { x, y }
end

------------------------------------------------------------ QUIRKS: one small story per area, drawn after every building
-- so the tap boxes above stay tight to the silhouettes. Each is 2 to 10 px and is checked against the other boxes.
local function inked(parts)   -- parts: { {mask, hex}, ... } ; one ink ring round the union, then flat fills
  local u = HP.mask()
  for _, p in ipairs(parts) do u:add(p[1]) end
  c:rim(u, P.ink)
  for _, p in ipairs(parts) do c:fillMask(p[1], p[2]) end
end
local function pt(list) local m = HP.mask() for _, q in ipairs(list) do m:set(q[1], q[2]) end return m end
local Q = {}
Q.greenhouse = function(x, y)   -- a sunflower has grown up through the glass roof
  local head = c:rrect(x + 5, y - 27, x + 9, y - 23, 1)
  c:rim(head, P.ink)
  R(x + 7, y - 22, x + 7, y - 10, P.moss.shade) px(x + 8, y - 16, P.moss.base) px(x + 6, y - 13, P.moss.base)
  c:fillMask(head, P.gold.base) px(x + 6, y - 27, P.gold.hi) px(x + 5, y - 25, P.gold.hi)
  R(x + 6, y - 26, x + 8, y - 24, P.wood.shade) px(x + 6, y - 26, P.wood.base)
  px(x + 8, y - 20, P.cream)   -- the lifted pane's edge
end
Q.tailor = function(x, y)   -- a washing line with one lonely striped sock
  local post = c:rect(x + 24, y - 14, x + 24, y)
  c:rim(post, P.ink) c:fillMask(post, P.wood.base) px(x + 24, y - 14, P.wood.hi)
  for xx = x + 12, x + 23 do px(xx, (xx >= x + 15 and xx <= x + 20) and y - 12 or y - 13, P.wood.shade) end
  local sock = pt{ {x + 17, y - 11}, {x + 18, y - 11}, {x + 17, y - 10}, {x + 18, y - 10}, {x + 17, y - 9}, {x + 18, y - 9}, {x + 17, y - 8}, {x + 18, y - 8}, {x + 19, y - 8}, {x + 18, y - 7}, {x + 19, y - 7} }
  c:rim(sock, P.ink) c:fillMask(sock, P.petal.base)
  R(x + 17, y - 11, x + 18, y - 11, P.cream) R(x + 17, y - 9, x + 18, y - 9, P.cream) px(x + 19, y - 7, P.petal.shade)
  px(x + 17, y - 12, P.wood.hi)   -- peg
end
Q.kitchen = function(x, y)   -- the chimney smoke curls into the shape of a spoon
  for _, q in ipairs{ {x + 12, y - 47}, {x + 13, y - 48}, {x + 13, y - 49}, {x + 14, y - 50}, {x + 15, y - 51}, {x + 15, y - 52}, {x + 16, y - 53}, {x + 16, y - 54}, {x + 17, y - 55}, {x + 17, y - 56} } do px(q[1], q[2], P.cream) end
  R(x + 16, y - 61, x + 18, y - 61, P.cream) R(x + 15, y - 60, x + 19, y - 58, P.cream) R(x + 16, y - 57, x + 18, y - 57, P.cream)
  px(x + 18, y - 58, P.petal.hi) px(x + 17, y - 57, P.petal.hi) px(x + 19, y - 59, P.petal.hi) px(x + 18, y - 57, P.petal.hi)
end
Q.tool_shed = function(x, y)   -- a spare gnome hat hangs on the rake handle
  local hat = c:poly{ {x + 12, y - 18}, {x + 14, y - 23}, {x + 16, y - 18} }
  c:rim(hat, P.ink) c:part(hat, "ember", { band = 1, nopop = true })
  R(x + 12, y - 18, x + 16, y - 18, P.ember.shade) px(x + 13, y - 20, P.ember.hi)
end
Q.compost_bin = function(x, y)   -- a gnome naps on the warm heap with his hat over his face
  local boots = c:rect(x - 8, y - 17, x - 7, y - 14)
  local body = c:rect(x - 6, y - 16, x - 2, y - 13)
  local beard = pt{ {x - 1, y - 16}, {x - 1, y - 15}, {x - 1, y - 14}, {x - 1, y - 13}, {x, y - 15}, {x, y - 14}, {x, y - 13}, {x + 1, y - 14}, {x + 1, y - 13} }
  local hat = c:poly{ {x + 1, y - 13}, {x + 4, y - 20}, {x + 7, y - 13} }
  inked{ { boots, P.wood.deep }, { body, P.sea.shade }, { beard, P.cream }, { hat, P.ember.base } }
  R(x - 6, y - 16, x - 3, y - 16, P.sea.base) R(x - 3, y - 16, x - 3, y - 13, P.gold.base) px(x - 8, y - 17, P.wood.shade)
  R(x + 5, y - 15, x + 6, y - 14, P.ember.shade) px(x + 6, y - 13, P.ember.shade) px(x + 3, y - 17, P.ember.hi)
  R(x - 1, y - 16, x - 1, y - 15, P.skinA.base)   -- a bit of nose peeking out
  R(x + 8, y - 22, x + 10, y - 22, P.dusk.shade) px(x + 9, y - 21, P.dusk.shade) R(x + 8, y - 20, x + 10, y - 20, P.dusk.shade)   -- one small z
end
Q.beehive = function(x, y)   -- a bee is moving in, carrying a tiny suitcase
  local case = c:rect(x + 10, y - 13, x + 12, y - 12)
  c:rim(case, P.ink) c:fillMask(case, P.wood.base) px(x + 10, y - 13, P.wood.hi) px(x + 12, y - 12, P.wood.shade)
  px(x + 11, y - 14, P.ink)
  R(x + 10, y - 16, x + 12, y - 15, P.gold.base) R(x + 11, y - 16, x + 11, y - 15, P.ink)
  px(x + 10, y - 17, P.cream) px(x + 12, y - 17, P.cream)
end
Q.root_cellar = function(x, y)   -- a "back soon" note pinned to the cellar door
  R(x + 1, y - 8, x + 4, y - 6, P.cream) R(x + 2, y - 7, x + 3, y - 7, P.ink) px(x + 1, y - 6, P.ink) px(x + 3, y - 8, P.petal.base)
  R(x + 2, y - 5, x + 4, y - 5, P.wood.deep)
end
Q.worm_farm = function(x, y)   -- a worm stands beside the trays reading a tiny book
  local body = pt{ {x + 13, y - 8}, {x + 13, y - 7}, {x + 13, y - 6}, {x + 12, y - 5}, {x + 12, y - 4}, {x + 12, y - 3}, {x + 13, y - 2}, {x + 13, y - 1}, {x + 14, y - 1} }
  local book = c:rect(x + 14, y - 7, x + 18, y - 5)
  inked{ { body, P.petal.base }, { book, P.cream } }
  px(x + 13, y - 8, P.petal.hi) px(x + 12, y - 3, P.petal.shade)
  R(x + 14, y - 5, x + 18, y - 5, P.dusk.base) R(x + 16, y - 7, x + 16, y - 6, P.wood.shade)
  px(x + 15, y - 6, P.stone.base) px(x + 17, y - 6, P.stone.base)
end
Q.ladybird_lodge = function(x, y)   -- a ladybird sits on top of the roof flagpole
  local pole = c:rect(x, y - 22, x, y - 19)
  local flag = pt{ {x + 1, y - 22}, {x + 2, y - 22}, {x + 1, y - 21} }
  local bug = c:rrect(x - 2, y - 26, x + 2, y - 23, 1)
  inked{ { pole, P.wood.deep }, { flag, P.gold.base }, { bug, P.ember.base } }
  R(x - 1, y - 27, x + 1, y - 27, P.ink) R(x, y - 26, x, y - 23, P.ember.deep)
  px(x - 1, y - 25, P.ink) px(x + 1, y - 24, P.ink) px(x - 2, y - 25, P.ember.hi) px(x + 2, y - 24, P.ember.shade)
end
Q.snail_jar = function(x, y)   -- the snail slipped out and heads for a puddle with an umbrella
  R(x + 20, y, x + 24, y, P.sea.base) px(x + 21, y, P.sea.hi) R(x + 21, y + 1, x + 23, y + 1, P.sea.shade)
  local shell = c:rrect(x + 11, y - 5, x + 14, y - 2, 1)
  local foot = c:rect(x + 10, y - 1, x + 17, y - 1)
  local neck = pt{ {x + 16, y - 2}, {x + 16, y - 3}, {x + 17, y - 4}, {x + 15, y - 4} }
  local canopy = pt{ {x + 12, y - 11}, {x + 13, y - 11}, {x + 14, y - 11}, {x + 11, y - 10}, {x + 12, y - 10}, {x + 13, y - 10}, {x + 14, y - 10}, {x + 15, y - 10},
    {x + 10, y - 9}, {x + 11, y - 9}, {x + 12, y - 9}, {x + 13, y - 9}, {x + 14, y - 9}, {x + 15, y - 9}, {x + 16, y - 9} }
  local handle = c:rect(x + 13, y - 8, x + 13, y - 6)
  inked{ { shell, P.gold.base }, { foot, P.cream }, { neck, P.cream }, { canopy, P.petal.base }, { handle, P.wood.deep } }
  px(x + 12, y - 4, P.gold.shade) px(x + 13, y - 3, P.gold.shade) px(x + 12, y - 3, P.gold.deep) px(x + 11, y - 5, P.gold.hi)
  px(x + 12, y - 11, P.petal.hi) px(x + 11, y - 10, P.petal.hi) R(x + 15, y - 9, x + 16, y - 9, P.petal.shade) px(x + 13, y - 9, P.petal.shade)
end
Q.rain_barrel = function(x, y)   -- a paper boat sails down the barrel's stream
  local by = 105
  local bx = SX(by)
  local hull = c:rect(bx - 1, by, bx + 2, by):add(c:rect(bx, by + 1, bx + 1, by + 1))
  local sail = pt{ {bx, by - 1}, {bx, by - 2}, {bx + 1, by - 1} }
  inked{ { hull, P.cream }, { sail, P.cream } }
  px(bx + 1, by + 1, P.stone.hi) px(bx + 1, by - 1, P.stone.hi)
end
Q.fence = function(x, y)   -- the goat is chewing a gardening glove
  local glove = pt{ {x + 10, y - 11}, {x + 11, y - 11}, {x + 12, y - 11}, {x + 10, y - 10}, {x + 11, y - 10}, {x + 12, y - 10}, {x + 13, y - 10},
    {x + 10, y - 9}, {x + 11, y - 9}, {x + 12, y - 9}, {x + 10, y - 8}, {x + 12, y - 8} }
  c:rim(glove, P.ink, HP.mask():add(glove:grow(1)):cut(c:rect(x + 9, y - 12, x + 9, y - 10)))
  c:fillMask(glove, P.gold.base) px(x + 10, y - 11, P.gold.hi) px(x + 12, y - 9, P.gold.shade) px(x + 12, y - 8, P.gold.shade)
  R(x + 10, y - 11, x + 12, y - 11, P.sea.base)   -- cuff
end
Q.quail_coop = function(x, y)   -- the quail peeks out wearing an egg cup as a hat
  local body = c:rect(x - 2, y - 3, x + 1, y - 1):add(c:rect(x, y - 5, x + 2, y - 4))
  local cup = pt{ {x - 1, y - 6}, {x, y - 6}, {x + 1, y - 6}, {x + 2, y - 6}, {x, y - 7}, {x + 1, y - 7}, {x - 1, y - 8}, {x, y - 8}, {x + 1, y - 8}, {x + 2, y - 8} }
  inked{ { body, P.wood.hi }, { cup, P.cream } }
  px(x - 1, y - 2, P.wood.base) px(x + 1, y - 2, P.wood.base) px(x + 2, y - 5, P.ink) px(x + 3, y - 4, P.gold.base)
  R(x - 1, y - 6, x + 2, y - 6, P.petal.hi) px(x + 1, y - 7, P.stone.hi)
end
Q.silk_shelf = function(x, y)   -- a silkworm on the roof wears a knitted scarf
  R(x - 9, y - 19, x - 4, y - 19, P.cream) R(x - 7, y - 20, x - 5, y - 20, P.cream)   -- humped body
  px(x - 8, y - 19, P.stone.hi) px(x - 6, y - 19, P.stone.hi)
  R(x - 3, y - 20, x - 2, y - 19, P.stone.hi) px(x - 2, y - 20, P.ink)   -- head
  R(x - 4, y - 20, x - 4, y - 19, P.ember.base) px(x - 5, y - 21, P.ember.hi) px(x - 6, y - 21, P.ember.base)   -- scarf, tail blowing back
end
Q.tortoise_run = function(x, y)   -- the tortoise carries a potted seedling on its shell
  local pot = c:rect(x - 6, y - 10, x - 2, y - 10):add(c:rect(x - 5, y - 9, x - 3, y - 8))
  local sprout = pt{ {x - 4, y - 11}, {x - 4, y - 12}, {x - 5, y - 13}, {x - 6, y - 13}, {x - 3, y - 13}, {x - 2, y - 13} }
  inked{ { pot, P.wood.base }, { sprout, P.moss.base } }
  R(x - 6, y - 10, x - 2, y - 10, P.wood.hi) px(x - 3, y - 8, P.wood.shade) px(x - 3, y - 9, P.wood.shade)
  px(x - 4, y - 11, P.moss.shade) px(x - 6, y - 13, P.moss.hi) px(x - 3, y - 13, P.moss.hi)
end
Q.butterfly_bush = function(x, y)   -- a butterfly rests on the bush like a bow tie
  for _, q in ipairs{ {x - 3, y - 6}, {x - 2, y - 6}, {x - 3, y - 5}, {x - 2, y - 5}, {x - 1, y - 5}, {x - 3, y - 4}, {x - 2, y - 4},
    {x + 3, y - 6}, {x + 2, y - 6}, {x + 3, y - 5}, {x + 2, y - 5}, {x + 1, y - 5}, {x + 3, y - 4}, {x + 2, y - 4} } do px(q[1], q[2], P.petal.base) end
  px(x - 3, y - 6, P.petal.hi) px(x + 2, y - 6, P.petal.hi) px(x - 2, y - 4, P.gold.hi) px(x + 3, y - 4, P.gold.hi)
  R(x, y - 6, x, y - 4, P.ink) px(x - 1, y - 7, P.ink) px(x + 1, y - 7, P.ink)
end
Q.frog_pond = function(x, y)   -- the frog wears a lily pad as a hat
  -- the pad sits one row above the head so the frog keeps its own outline and eyes
  local pad = c:rect(x + 3, y - 16, x + 13, y - 16):add(c:rect(x + 4, y - 15, x + 12, y - 15)):cut(pt{ {x + 10, y - 16} })
  c:rim(pad, P.ink) c:fillMask(pad, P.moss.hi)
  R(x + 4, y - 15, x + 12, y - 15, P.moss.base) px(x + 12, y - 15, P.moss.shade) px(x + 4, y - 16, P.cream)
end
local qboxes = {}
for _, b in ipairs(boxes) do
  local k = b.k
  local snap = {}
  for i, v in pairs(c.pix) do snap[i] = v end
  Q[k](AT[k][1], AT[k][2])
  local x0, y0, x1, y1, n = 999, 999, -1, -1, 0
  for i, v in pairs(c.pix) do
    if snap[i] ~= v then n = n + 1; local yy, xx = i // 240, i % 240; if xx < x0 then x0 = xx end if xx > x1 then x1 = xx end if yy < y0 then y0 = yy end if yy > y1 then y1 = yy end end
  end
  qboxes[k] = { x0, y0, x1 + 1, y1 + 1 }
  for _, o in ipairs(boxes) do
    if o.k ~= k then
      local a = o.box
      if x0 < a[3] and x1 + 1 > a[1] and y0 < a[4] and y1 + 1 > a[2] then print("WARN quirk " .. k .. " overlaps box " .. o.k) end
    end
  end
  print(string.format("quirk %-15s %3d px  box %d,%d-%d,%d", k, n, x0, y0, x1 + 1, y1 + 1))
end

------------------------------------------------------------ OUT
c:finish{ outline = false }
HP.assertClean(c)
local base = out .. "garden-patch3"
c:save{ aseprite = base .. ".aseprite", png = base .. ".png", scale = 2 }
local f = io.open(base .. ".json", "w")
local parts = {}
for _, b in ipairs(boxes) do
  parts[#parts + 1] = string.format('{"k":"%s","n":"%s","box":[%d,%d,%d,%d]}', b.k, b.n, b.box[1] * 2, b.box[2] * 2, b.box[3] * 2, b.box[4] * 2)
end
f:write("[" .. table.concat(parts, ",") .. "]") f:close()
print(look, "ok", #boxes, "spots")
