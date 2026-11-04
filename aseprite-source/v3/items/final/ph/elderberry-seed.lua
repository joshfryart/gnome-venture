-- elderberry-seed (final, Opus single pass). Three small ochre elder seeds (ovoid, flattened, crossed by fine
-- transverse wrinkles) on a torn elder leaflet scrap (lanceolate, saw-toothed margin, midrib + swept veins,
-- ragged torn base, V-fold light, cool reflected edge, AO + contact shadow under each seed). The upright seed has
-- germinated: a wine-red elder stem, two smooth ovate cotyledons and a first pinnate true leaf (a pair of
-- serrated leaflets + a terminal leaflet) that shows the elder's compound leaf.
-- quirk: one ripe glossy elderberry (with its little star scar) has rolled in and left a purple juice stain.
local NAME = "elderberry-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB2r0_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new2(NAME)
local LEAF = { "#173a34", "#1f5440", "#2c7046", "#438f4c", "#68ad56", "#9ccb6c" }
local SPR = { "#1d4a3a", "#2a6a44", "#3f8a4a", "#5ea952", "#8cc860", "#bfe282" }
local VEIN, COOL = "#c4e48e", "#3c6a78"
local SEED = { "#3c2418", "#5e3a20", "#86592a", "#ad7f3c", "#cfa35a", "#ecca8a" }
local STEM = { "#4e2236", "#7e3448", "#a8505c", "#d07c7c", "#eeb0a0" }
local BER = { "#1c1030", "#2b1846", "#422464", "#5e3486", "#8256ae", "#b294dc" }
local BLOOM, STAIN, STAIN2 = "#8f88c6", "#4a2a52", "#6a3a6a"
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 17, 47, 3.4, 2.2, 0.35 }, { 26, 50, 3.5, 2.3, -0.25 }, { 37, 45, 3.3, 2.3, -1.45 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end
-- quirk berry
local BX, BY, BR = 48, 46, 3.3
local bm, bn = A.oval(BX, BY, BR, BR, 0, 1)

-- leaf scrap: one elder leaflet lying left->right, torn at its base (left), tip right
local bias = {}
local lm = A.blade(9, 49, 30, 57, 56, 45, function(t) if t > 0.985 then return -1 end
  return max(0.5, 7 * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.75) end, { fold = 0.4 })
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, bm, 1, -1) A.cast(bias, lm, bm, 1, 2, -1) A.cast(bias, lm, bm, 2, 3, -1)
local ltok = { r = { name = "leaf" } }
local LM, lidx, LT, LS = A.serrate(c, 9, 49, 30, 57, 56, 45, LEAF, {
  wfn = function(t) if t > 0.985 then return -1 end return max(0.5, 7 * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.75) end,
  per = 3.4, depth = 0.24, tear = 4.5, veinPer = 5, bias = bias, tok = ltok, vein = VEIN, t0 = 0.12 })
-- cool reflected light on the lower-right rim
LM:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] and LS[k] > 0.6 and LT[k] > 0.15 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)
-- juice stain: a blot left of the berry and a thin run toward the leaf edge
local stain = HP.mask()
for _, p in ipairs{ {42,48},{43,48},{43,49},{42,49},{41,49},{44,49},{42,50},{43,50},{41,50},{44,50},{43,51},{42,51},{43,52},{44,52},{44,53},{40,48} } do stain:set(p[1], p[2]) end
stain:clip(LM) stain:cut(bm) stain:cut(seeds[3].m)
stain:each(function(x, y) local k = K(x, y)
  c:put(x, y, ((lidx[k] or 3) >= 4 and not bias[k]) and STAIN2 or STAIN, ltok) end)

-- sprout: hypocotyl out of the upright seed, cotyledons, then pinnate first leaf
local stok = { r = { name = "stem" } }
local sp = { { 37, 43 }, { 36, 37 }, { 35, 32 }, { 35, 28 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = stok })
local function coty(ax, ay, cx, cy, bx, by)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, 2.3 * sin(pi * min(1, t * 0.88 + 0.12)) ^ 0.6) end, { fold = 0.25 })
  m:cut(sm)
  local idx = A.toneN(c, m, n, SPR, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.14 and T[k] > 0.12 and T[k] < 0.8 then c:put(x, y, SPR[max(2, (idx[k] or 3) - 1)], ltok) end end)
  return m
end
local cl = coty(34, 29, 29, 26, 24, 28)
local cr = coty(36, 29, 41, 26, 46, 28)
-- petiole (rachis) of the first true leaf
local rach = { { 35, 28 }, { 35, 23 }, { 36, 18 }, { 36, 15 } }
local rm = HP.mask()
for i = 0, 40 do local x, y = A.bez(rach, i / 40) rm:set(floor(x + .5), floor(y + .5)) end
-- leaflets: a lower pair and a terminal one, each saw-toothed with a midrib
local leafl = HP.mask()
local function leaflet(ax, ay, cx, cy, bx, by, w)
  local m = A.serrate(c, ax, ay, cx, cy, bx, by, SPR, { w = w, per = 2.4, depth = 0.42, veinPer = 3.2, tok = ltok,
    cut = HP.mask():add(rm):add(cl):add(cr), t0 = 0.22, t1 = 0.9 })
  leafl:add(m)
  return m
end
local L1 = leaflet(35, 20, 30, 17, 25, 19, 2.3)
local L2 = leaflet(36, 19, 41, 16, 46, 18, 2.3)
local L3 = leaflet(36, 15, 35, 12, 37, 8, 2.2)
-- AO on cotyledons under the leaflet pair
for _, m in ipairs{ cl, cr } do m:each(function(x, y)
  if leafl:shift(0, 1):has(x, y) and not leafl:has(x, y) then c:put(x, y, SPR[1], ltok) end end) end
rm:each(function(x, y) local yy = y if not leafl:has(x, y) then c:put(x, y, yy > 24 and STEM[3] or STEM[4], stok) end end)
c:put(35, 27, STEM[2], stok) -- node shadow between the cotyledons

-- seeds: ochre ovoids with fine transverse wrinkles
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  local idx = A.toneN(c, s.m, s.n, SEED, { tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.1, wrap = 0.2, bias = sb })
  local ca, sa = cos(s[5]), sin(s[5])
  s.m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local v = (-dx * sa + dy * ca) / (s[4] + .45)
    -- wrinkles: rows across the long axis every ~1.6 px, skipped on the rim
    local ph = (u * (s[3] + .45) + 0.3 * v) / 1.6
    local f = ph - floor(ph)
    if abs(u) < 0.78 and abs(v) < 0.75 and f < 0.3 then c:put(x, y, SEED[max(1, (idx[k] or 3) - 1)], tok) end
  end)
  -- pale hilum dot at one end
  local hx, hy = floor(s[1] + ca * (s[3] - 0.6) + .5), floor(s[2] + sa * (s[3] - 0.6) + .5)
  if s.m:has(hx, hy) then c:put(hx, hy, SEED[6], tok) end
end

-- berry: glossy purple-black sphere, waxy bloom, cream specular, star scar, cool bounce
do
  local tok = { r = { name = "berry" } }
  local bidx = X.tone(c, bm, X.light(bn, { amb = 0.08, wrap = 0.25 }), BER, { cuts = { 0.15, 0.3, 0.46, 0.64, 0.84 }, tok = tok })
  bm:edge():each(function(x, y) if x > BX and y > BY then c:put(x, y, "#4a4a8c", tok) end end)
  for _, p in ipairs{ {46,44},{49,47},{47,48} } do if bm:has(p[1], p[2]) then c:put(p[1], p[2], BLOOM, tok) end end
  c:put(46, 45, "#fff4d6", tok) c:put(47, 44, BER[6], tok)
  -- star scar (calyx remnant) upper right
  c:put(49, 44, BER[1], tok) c:put(50, 44, BER[2], tok) c:put(49, 43, BER[2], tok) c:put(48, 44, BER[2], tok)
  -- tiny dry pedicel stub
  c:put(50, 42, "#7a5a3a", tok) c:put(51, 41, "#a8844e", tok)
end

A.save2(c, NAME)
