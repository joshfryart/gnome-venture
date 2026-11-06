-- asparagus-seed (ph, Opus single pass, aR3_0). Three glossy black asparagus seeds (round, one flat facet, violet
-- bounce light, bright specular each: glossy material) on a torn leaf scrap (ragged tear on the right end and a nibble
-- on the top edge, V-fold light, midrib + swept veins, cool rim, AO and contact shadow under each seed). The middle
-- seed has germinated: a slim wiry stem with a purple spear-tip bud and whorls of fine needle cladodes, the ferny
-- asparagus foliage in miniature.
-- quirk: the seeds came from the split red berry still lying at the end of the leaf, one seed left in its cup.
local NAME = "asparagus-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local LEAF  = { "#1b4236", "#255c40", "#347a46", "#4f9a4c", "#78ba5a", "#aad677" }
local VEIN, COOL = "#cbe79a", "#3b6b74"
local SEED  = { "#1c1424", "#2b1f35", "#3d2c4a", "#54405f", "#75607e", "#a594b0" }
local NEED  = { "#2c6a3e", "#4f9a4c", "#8cc664", "#c4e68e" }
local BUD   = { "#3a2a5a", "#65478a", "#9a7cbc", "#d4bfe2" }
local BER   = { "#4f1430", "#7e1c34", "#b02a38", "#d8463e", "#f0705a", "#ffb08a" }
local FLESH = { "#c98a70", "#e8b494", "#f8dcc0" }
local CUTS  = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- seeds (cx, cy, r) and the berry
local seeds = { { 16, 47, 2.8 }, { 24, 50, 3.0 }, { 31, 46, 2.7 } }
for _, s in ipairs(seeds) do
  s.m = c:ellipse(s[1], s[2], s[3], s[3] - 0.3)
  s.n = X.sphere(s[1] - 0.3, s[2] - 0.3, s[3], s.m)
end
local BX, BY, BR = 46, 45, 5
local berry = c:ellipse(BX, BY, BR, BR - 0.5)

-- leaf scrap -----------------------------------------------------------------------------------------------------
local lm, ln, LT, LS, len = G.blade(6, 50, 30, 40, 58, 47, function(t)
  if t > 0.99 then return -1 end
  return max(0.6, 9.6 * sin(pi * min(1, t * 0.82 + 0.1)) ^ 0.65)
end, { fold = 0.42 })
G.tear(lm, 52, 0, 1, 0.08, 1.6, 3)            -- ragged torn end on the right
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, berry, 1, -1) G.cast(bias, lm, berry, 1, 2, -1)
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.16, 0.32, 0.5, 0.7, 0.9 }, amb = 0.08, wrap = 0.25 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 and t < 0.97 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5.0) / 6.5
  local f = ph - floor(ph)
  if f < 0.12 and abs(s) > 0.16 and abs(s) < 0.78 and t > 0.05 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.08 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale fibrous rim on the tear
lm:edge():each(function(x, y) if x >= 50 and not bias[K(x, y)] then c:put(x, y, (y % 2 == 0) and LEAF[6] or VEIN, ltok) end end)
-- petiole stub
for _, q in ipairs{ { 5, 51, 4 }, { 4, 52, 3 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout (from the middle seed) ---------------------------------------------------------------------------------
local stok = { r = { name = "sprout" } }
local sp = { { 31, 45 }, { 29, 34 }, { 35, 25 }, { 31, 11 } }
local stem = {}
for i = 0, 80 do local t = i / 80 local x, y = G.bez(sp, t)
  local xi, yi = floor(x + .5), floor(y + .5)
  stem[#stem + 1] = { xi, yi, t }
  c:put(xi, yi, NEED[3], stok)
  if t < 0.5 then c:put(xi + 1, yi, NEED[1], stok) end
end
-- needle whorls: fine 1 px cladodes sprayed upward at the nodes
local function needle(x, y, ang, L, col, tipcol)
  for i = 1, L do
    local px, py = floor(x + cos(ang) * i + .5), floor(y + sin(ang) * i + .5)
    c:put(px, py, (i == L) and tipcol or col, stok)
  end
end
-- feathery sprays of needle cladodes: paired needles every 3 px, long and drooping low, short near the tip,
-- with a short side spray branching off low on the left
local n = 0
for t = 0.32, 0.92, 0.085 do
  n = n + 1
  local x, y = G.bez(sp, t)
  x, y = floor(x + .5), floor(y + .5)
  local L = max(2, floor(9 - (t - 0.32) * 11 + .5))
  local droop = (1 - t) * 18
  needle(x - 1, y, math.rad(-152 + droop), L, NEED[3], NEED[4])
  needle(x + 1, y, math.rad(-28 - droop), L - 1, NEED[2], NEED[3])
end
-- spear-tip bud at the top: tight purple scales
local tx, ty = G.bez(sp, 1)
tx, ty = floor(tx + .5), floor(ty + .5)
G.map(c, tx - 1, ty - 3, {
  ".d.",
  "dcb",
  "bab",
  "aNb",
}, { a = BUD[1], b = BUD[2], c = BUD[4], d = BUD[3], N = NEED[2] }, stok)

-- berry (quirk): split red sphere, front cut away to pale flesh with one seed in the cup --------------------------
local btok = { r = { name = "berry" } }
local bn = X.sphere(BX - 0.5, BY - 0.5, BR, berry)
X.tone(c, berry, X.light(bn, { amb = 0.08, wrap = 0.2 }), BER, { cuts = CUTS, tok = btok })
-- split along a crack down the front: dark seam, pale flesh lips, one black seed squeezing out at its foot
for _, q in ipairs{ { -1, -3 }, { 0, -2 }, { 0, -1 }, { 1, 0 }, { 1, 1 } } do
  c:put(BX + q[1], BY + q[2], BER[1], btok) c:put(BX + q[1] - 1, BY + q[2], FLESH[3], btok) c:put(BX + q[1] + 1, BY + q[2], FLESH[1], btok)
end
for _, q in ipairs{ { 1, 2, SEED[4] }, { 2, 2, SEED[2] }, { 1, 3, SEED[2] }, { 2, 3, SEED[1] }, { 0, 2, FLESH[2] }, { 3, 2, FLESH[1] } } do
  c:put(BX + q[1], BY + q[2], q[3], btok) end
c:put(BX + 1, BY + 2, SEED[6], btok)
-- dried calyx stub on top
c:put(BX + 1, BY - 5, "#5a4030", btok) c:put(BX + 2, BY - 6, "#7a5a3a", btok) c:put(BX + 2, BY - 5, "#3e2c24", btok)
-- berry calyx scar and specular
c:put(BX - 3, BY - 3, BER[6], btok) c:put(BX - 2, BY - 4, "#fff4d6", btok)
c:put(BX - 4, BY + 1, BER[2], btok)

-- seeds last: glossy black, flat facet, violet bounce, one specular each ----------------------------------------
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local v = X.light(s.n, { amb = 0.05, wrap = 0.15 })
  local idx = X.tone(c, s.m, v, SEED, { cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 }, tok = tok })
  -- flat facet: a straight darker chord on the lower right
  s.m:each(function(x, y) local dx, dy = x - s[1], y - s[2]
    if dx + dy > s[3] * 0.9 and dx + dy < s[3] * 0.9 + 1.1 then c:put(x, y, SEED[2], tok) end
    if dx + dy >= s[3] * 0.9 + 1.1 then c:put(x, y, SEED[3], tok) end end)
  local hx, hy = floor(s[1] - s[3] * 0.4 + .5), floor(s[2] - s[3] * 0.45 + .5)
  c:put(hx, hy, "#fff4d6", tok) c:put(hx + 1, hy, SEED[6], tok)
end
G.save2(c, NAME)
