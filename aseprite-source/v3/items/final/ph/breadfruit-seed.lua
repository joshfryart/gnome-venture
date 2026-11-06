-- breadfruit-seed (final, Opus aB10_3). Two plump chestnut-brown breadnut seeds (glossy coat, pale hilum scar,
-- one specular each, AO + contact shadow) on a torn scrap of lobed breadfruit leaf (ragged torn base, midrib,
-- vein per lobe, V-fold light, cool reflected edge). The right seed has germinated: a pale root curls over the
-- leaf edge and a slim green shoot rises to one young, deeply lobed breadfruit leaf with a curled bud beside it.
-- quirk: the left seed's coat has split along a crack, showing the cream kernel inside.
local NAME = "breadfruit-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#133a32", "#1d5139", "#2b6c40", "#3f8a45", "#62a94e", "#93c965" }
local VEIN, COOL = "#b8dc84", "#2f6a66"
local SEED = { "#331c1e", "#50291f", "#743c24", "#9a5730", "#c27e46", "#e8b278" }
local HIL = { "#a88a62", "#d8c294" }
local KERN = { "#d8c08a", "#f6e6b4" }
local STEM = { "#3f7a4c", "#6fae5c", "#a6d283", "#d8efb0" }
local ROOT = { "#b49a78", "#dccaa2", "#f4ead0" }

-- seeds
local seeds = { { 19, 47, 4.6, 3.5, -0.25 }, { 32, 45, 4.8, 3.7, 0.35 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end

-- leaf scrap: lobed breadfruit leaf piece, torn across the base
local lm, ln, LT, LS, len = A.lobedLeaf(6, 49, 26, 58, 56, 45, 8.0, 2.3, { deep = 0.62, fold = 0.36 })
local torn = {}
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.1 + X.hash(floor(LS[k] * 6 + 0.5), 0, 41) * 0.07
  if LT[k] < lim then torn[#torn + 1] = k end end)
for _, k in ipairs(torn) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
-- root (radicle) from the sprouting seed, curling over the lower leaf edge
local rp = { { 34, 48 }, { 37, 51 }, { 39, 54 }, { 37, 57 } }
local rm, rn, RT = A.tube(rp, function(t) return 1.3 * (1 - t) ^ 0.7 + 0.3 end)
rm:cut(seeds[2].m)
A.cast(bias, lm, rm, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
A.lit(c, lm, ln, LEAF, { tok = ltok, bias = bias, amb = 0.14, wrap = 0.3, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 } })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = t * 2.3 - abs(s) * 0.22
  local f = ph - floor(ph)
  if (f < 0.06 or f > 0.94) and abs(s) > 0.18 and abs(s) < 0.72 and t > 0.12 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.12 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale fibre pixels on the ragged base
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] < 0.2 and not lm:has(x - 1, y) then c:put(x, y, LEAF[5], ltok) end end)

-- root
local rtok = { r = { name = "root" } }
A.lit(c, rm, rn, ROOT, { tok = rtok, amb = 0.2, wrap = 0.3, cuts = { 0.35, 0.7 } })
rm:each(function(x, y) if RT[K(x, y)] > 0.93 then c:put(x, y, ROOT[1], rtok) end end)

-- shoot: slim stem out of the right seed, leaning, to a young lobed leaf
local stok = { r = { name = "stem" } }
local sp = { { 33, 43 }, { 34, 37 }, { 31, 31 }, { 33, 25 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
sm:cut(seeds[2].m)
A.lit(c, sm, sn, STEM, { tok = stok, amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
-- young leaf, lobed, off to the upper left
local ym, yn, YT, YS = A.lobedLeaf(32, 25, 26, 13, 13, 16, 4.8, 2.2, { deep = 0.66, fold = 0.42 })
local yb = {}
A.cast(yb, ym, sm, 1, 1, -1)
A.lit(c, ym, yn, LEAF, { tok = ltok, bias = yb, amb = 0.12, wrap = 0.3, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
ym:each(function(x, y) local k = K(x, y)
  if abs(YS[k]) < 0.14 and YT[k] < 0.93 then c:put(x, y, YS[k] <= 0 and VEIN or LEAF[4], ltok) return end
  local ph = YT[k] * 2.2 - abs(YS[k]) * 0.25
  local f = ph - floor(ph)
  if (f < 0.07 or f > 0.93) and abs(YS[k]) > 0.2 and abs(YS[k]) < 0.7 and YT[k] > 0.15 then c:put(x, y, YS[k] < 0 and LEAF[6] or LEAF[2], ltok) end
end)
ym:edge():each(function(x, y) local k = K(x, y) if YS[k] > 0.66 and YT[k] > 0.15 and YT[k] < 0.85 then c:put(x, y, COOL, ltok) end end)
-- curled bud at the shoot tip, to the right
local bm, bn = A.oval(36, 22, 2.6, 1.6, -0.9, 0.8)
bm:cut(ym)
A.lit(c, bm, bn, LEAF, { tok = ltok, amb = 0.15, wrap = 0.3 })
c:put(37, 21, LEAF[6], ltok)
for _, q in ipairs{ { 33, 25, 3 }, { 34, 24, 2 } } do c:put(q[1], q[2], STEM[q[3]], stok) end

-- seeds last: glossy coat, hilum, AO between, specular
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  if i == 2 then X.ao(sb, s.m, sm, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = A.lit(c, vis, s.n, SEED, { tok = tok, bias = sb, amb = 0.08, wrap = 0.2, cuts = { 0.18, 0.34, 0.5, 0.66, 0.86 } })
  -- hilum: pale scar at the lower-right end of the long axis
  local ca, sa = cos(s[5]), sin(s[5])
  local hx, hy = s[1] + ca * (s[3] - 1.2), s[2] + sa * (s[3] - 1.2)
  local xi, yi = floor(hx + .5), floor(hy + .5)
  c:put(xi, yi, HIL[2], tok) c:put(xi, yi + 1, HIL[1], tok) c:put(xi - 1, yi, HIL[1], tok)
  -- specular
  local gx, gy = A.specAt(vis, s.n, 30)
  if gx then c:put(gx, gy, A.CREAM, tok) c:put(gx + 1, gy, SEED[6], tok) end
end
-- quirk: split coat on the left seed, cream kernel showing through the crack
local cr = { { 16, 48, 1 }, { 17, 47, 2 }, { 18, 47, 2 }, { 19, 46, 2 }, { 20, 46, 1 }, { 21, 45, 1 } }
local ktok = { r = { name = "seed1" } }
for _, q in ipairs(cr) do c:put(q[1], q[2], KERN[q[3]], ktok) end
for _, q in ipairs{ { 16, 49 }, { 17, 48 }, { 18, 48 }, { 19, 47 }, { 20, 47 }, { 21, 46 }, { 22, 45 } } do
  if seeds[1].m:has(q[1], q[2]) then c:put(q[1], q[2], SEED[1], ktok) end end

A.save(c, NAME)
