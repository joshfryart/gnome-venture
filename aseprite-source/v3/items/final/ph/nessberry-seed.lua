-- nessberry-seed (final, Opus single pass). Three small tan nessberry pits (kidney-shaped, honeycomb-pitted coat)
-- on a torn bramble-leaflet scrap (serrated margin, sunken midrib + parallel veins, ragged torn base with pale
-- fibres, cool reflected edge, AO + contact shadow under each seed). The right pit has germinated: a reddish prickly
-- stem, two round cotyledons and a first true leaf of three serrated leaflets, the bramble leaf in miniature.
-- quirk: one glossy dark-purple drupelet of the berry is still stuck to the left pit.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "nessberry-seed"
local c = A.new(NAME)
local LEAF = { "#163a34", "#20553d", "#2c7345", "#41924b", "#66b254", "#98cf6a" }
local YL   = { "#1e4a3a", "#2f6c44", "#4b9450", "#74b85c", "#a6d878", "#d2ee9e" }
local SEED = { "#3e2420", "#62402c", "#8a5c36", "#b07e48", "#d2a466", "#efcf96" }
local STEM = { "#5a2a34", "#8a3c3c", "#b86450", "#dc9478" }
local DRU  = { "#1a0f2a", "#341a4e", "#55287a", "#7c3ea4", "#b07ad4" }
local COOL, FIBRE, SPEC = "#3a6c72", "#cfe3a0", "#fff4d6"

-- leaf scrap: bramble leaflet on a shallow diagonal, serrated
local ltok = { r = { name = "leaf" } }
local seeds = { { 18, 47, 3.3, 2.3, 0.35 }, { 27, 45, 3.2, 2.2, -0.25 }, { 37, 42, 3.3, 2.3, 0.15 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.85) end
local lm, ln, LT, LS, len = A.blade(8, 53, 30, 52, 56, 37, function(t)
  if t > 0.985 then return -1 end
  local w = 9.0 * sin(pi * min(1, t * 0.93 + 0.07)) ^ 0.75
  if t > 0.12 and t < 0.94 and (t * 34) % 2 < 0.7 then w = w - 0.9 end   -- serration teeth
  return max(0.5, w)
end, { fold = 0.4 })
-- torn base: ragged diagonal cut removing the petiole end
local torn = {}
lm:each(function(x, y)
  local d = (x - 13) + (y - 52) * 0.6 + (X.hash(x, y, 21) - 0.5) * 2.4 + 1.2 * sin(y * 1.7)
  if d < 0 then torn[#torn + 1] = K(x, y) end
end)
for _, k in ipairs(torn) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.08 and t < 0.94 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[2], ltok) return end
  local d = (t * len - abs(s) * 6.5) % 4.4
  if d < 0.85 and abs(s) > 0.18 and abs(s) < 0.78 and t > 0.1 and t < 0.88 then c:put(x, y, s < 0 and LEAF[min(6, lidx[k] + 1)] or LEAF[max(1, lidx[k] - 1)], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.15 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end end)
-- pale torn fibres along the cut
for _, k in ipairs(torn) do local x, y = k % 1024 - 256, k // 1024 - 256
  for _, d in ipairs{ { 1, 0 }, { 0, -1 } } do
    if lm:has(x + d[1], y + d[2]) and X.hash(x, y, 8) > 0.35 then c:put(x + d[1], y + d[2], FIBRE, ltok) end end
end

-- sprout from the right pit: reddish prickly stem, cotyledons, three-leaflet true leaf
local stok = { r = { name = "stem" } }
local sp = { { 38, 41 }, { 37, 35 }, { 39, 29 }, { 38, 23 } }
local sm = A.stem(c, sp, function(t) return 1.05 end, STEM, { tok = stok, cut = seeds[3].m })
for _, q in ipairs{ { 0.3, -1 }, { 0.55, 1 } } do       -- prickles
  local x, y = A.bez(sp, q[1]) c:put(floor(x + 0.5) + q[2] * 2, floor(y + 0.5) - 1, STEM[q[2] < 0 and 4 or 2], stok) end
local function coty(cx, cy, ang)
  local m, n = A.oval(cx, cy, 3.6, 2.1, ang, 0.8)
  m:cut(sm)
  local i = A.toneN(c, m, n, YL, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  return m
end
local cl = coty(33.5, 29.5, 0.45)
local cr = coty(43, 29, -0.4)
-- true leaf: three serrated leaflets at the stem top
local tl = HP.mask()
local lfl = { { 38, 23, 31, 18, 2.6 }, { 38, 23, 40, 12, 2.9 }, { 38, 23, 46, 17, 2.6 } }
local tll = {}
for _, f in ipairs(lfl) do
  local m, n, T, S, L = A.blade(f[1], f[2], (f[1] + f[3]) / 2 + 0.5, (f[2] + f[4]) / 2 - 0.5, f[3], f[4], function(t)
    if t < 0.18 or t > 0.985 then return -1 end
    local w = f[5] * sin(pi * min(1, (t - 0.18) / 0.82 * 0.92 + 0.08)) ^ 0.7
    if (t * 22) % 2 < 0.6 and t > 0.35 then w = w - 0.7 end
    return max(0.3, w)
  end, { fold = 0.5 })
  m:cut(cl):cut(cr)
  tll[#tll + 1] = { m, n, T, S }
end
for _, f in ipairs(tll) do
  local i = A.toneN(c, f[1], f[2], LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  f[1]:each(function(x, y) local k = K(x, y) if abs(f[4][k]) < 0.14 and f[3][k] < 0.88 then c:put(x, y, f[4][k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
end
c:put(38, 23, STEM[3], stok) c:put(38, 24, STEM[3], stok)

-- seeds: kidney pits with honeycomb pitting
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  -- kidney notch on the lower side
  local ca, sa = cos(s[5]), sin(s[5])
  local nx, ny = s[1] + sa * (s[4] + 0.6), s[2] + ca * (s[4] + 0.6)
  s.m:each(function(x, y) if (x - nx)^2 + (y - ny)^2 < 1.3 then s.m.s[K(x, y)] = nil end end)
  local idx = A.toneN(c, s.m, s.n, SEED, { tok = tok, cuts = A.CUTS, amb = 0.08, wrap = 0.25, bias = sb })
  s.m:each(function(x, y) local k = K(x, y)
    if idx[k] >= 3 and idx[k] <= 5 and (x * 2 + y * 3 + i) % 5 == 0 and s.m:has(x + 1, y) and s.m:has(x, y + 1) then c:put(x, y, SEED[idx[k] - 1], tok) end end)
  local gx, gy = A.specAt(s.m, s.n, 40)
  c:put(gx, gy, SEED[6], tok)
end
c:put(26, 43, SPEC, { r = { name = "seed2" } })

-- quirk: drupelet stuck to the left pit
local dtok = { r = { name = "drupelet" } }
local dm, dn = A.oval(14.5, 44.5, 1.9, 1.9, 0, 1)
local di = A.toneN(c, dm, dn, DRU, { tok = dtok, cuts = { 0.25, 0.45, 0.65, 0.85 }, amb = 0.1, wrap = 0.25 })
c:put(14, 44, SPEC, dtok)

A.save(c, NAME)
