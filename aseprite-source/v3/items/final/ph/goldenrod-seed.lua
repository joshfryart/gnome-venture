-- goldenrod-seed (B3, Opus single pass). Three slim ribbed goldenrod achenes, each with a creamy pappus tuft, on a
-- torn lance-shaped toothed goldenrod leaf (tip to the left, ragged torn end on the right, triple veins, V-fold
-- light, AO + contact shadow). The middle achene has sprouted: slim stem with alternate narrow lance leaves.
-- quirk: one achene has let go and is drifting off on its pappus parachute.
local NAME = "goldenrod-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#1f3d2a", "#2c5a33", "#3f7c3e", "#5e9e48", "#8cc05a", "#c4de80" }
local SEED = { "#3a2420", "#5a3a28", "#7e5634", "#a47a48", "#c8a068", "#e8cc96" }
local PAP = { "#b7ab92", "#ddd2b8", "#f6efda" }
local STEM = { "#4c7e3e", "#7aac56", "#aed482", "#dcf0ae" }

-- achenes: cx, cy, rx, ry, angle (pappus toward the -u end)
local seeds = { { 18, 45, 3.6, 1.3, 0.25 }, { 29, 43, 3.6, 1.3, -0.15 }, { 41, 45, 3.6, 1.3, 0.1 } }
local seedAll = HP.mask()
local function pappus(x, y, ux, uy, r)
  -- fan sector opening away from the seed
  local m = HP.mask()
  for yy = floor(y - r - 1), floor(y + r + 1) do for xx = floor(x - r - 1), floor(x + r + 1) do
    local dx, dy = xx - x, yy - y
    local d = math.sqrt(dx * dx + dy * dy)
    if d <= r + 0.3 and (d < 0.8 or (dx * ux + dy * uy) / d > 0.35) then m:set(xx, yy) end
  end end
  return m
end
for _, s in ipairs(seeds) do
  s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7)
  local ca, sa = cos(s[5]), sin(s[5])
  s.px, s.py, s.ux, s.uy = s[1] - (s[3] + 0.8) * ca, s[2] - (s[3] + 0.8) * sa, -ca, -sa
  s.pm = pappus(s.px, s.py, s.ux, s.uy, 2.6) s.pm:cut(s.m)
  seedAll:add(s.m):add(s.pm)
end

-- leaf: lance, tip left, torn right end, toothed margin
local lm, ln, LT, LS, len = A.blade(56, 47, 32, 41, 5, 46, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 6.6 * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.8)
end, { fold = 0.4 })
lm:cut(c:poly{ { 64, 36 }, { 53, 40 }, { 55, 43 }, { 52, 45 }, { 55, 48 }, { 53, 51 }, { 56, 54 }, { 64, 60 } })
local cut = {}
lm:edge():each(function(x, y) local k = K(x, y) if abs(LS[k]) > 0.72 and floor(LT[k] * len) % 3 == 0 and LT[k] > 0.2 then cut[#cut + 1] = k end end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
X.ao(bias, lm, seedAll, 1, -1)
A.cast(bias, lm, seedAll, 1, 2, -1)
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) if bias[k] then return end
  local s, t = LS[k], LT[k]
  if abs(s) < 0.14 and t < 0.95 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok)
  elseif abs(abs(s) - 0.5) < 0.08 and t > 0.1 and t < 0.7 then c:put(x, y, LEAF[min(6, (lidx[k] or 3) + (s < 0 and 1 or -1))], ltok) end end)

-- sprout from the middle achene
local stok = { r = { name = "stem" } }
local sm, sn = A.tube({ { 30, 42 }, { 31, 34 }, { 28, 26 }, { 30, 13 } }, function(t) return 1.05 - 0.2 * t end)
sm:cut(seedAll)
A.shade(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local leaves = HP.mask()
for _, L in ipairs{ { 30, 34, 24, 31, 18, 26, 2.2 }, { 29, 28, 35, 25, 41, 19, 2.2 }, { 29, 21, 25, 17, 22, 12, 1.7 }, { 30, 15, 33, 11, 35, 8, 1.4 } } do
  local m, n, T, S = A.blade(L[1], L[2], L[3], L[4], L[5], L[6], function(t)
    if t > 0.985 then return -1 end
    return max(0.4, L[7] * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.6)
  end, { fold = 0.35 })
  m:cut(sm) m:cut(leaves)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.15 and T[k] > 0.1 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  leaves:add(m)
end

-- achenes: ribbed (lengthwise stripes) + pappus tufts
local function achene(s, tok)
  local ca, sa = cos(s[5]), sin(s[5])
  local idx = A.toneN(c, s.m, s.n, SEED, { tok = tok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.1, wrap = 0.3 })
  s.m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local v = (-dx * sa + dy * ca)
    if abs(v) < 0.5 and abs(dx * ca + dy * sa) < s[3] - 0.5 then c:put(x, y, SEED[max(1, idx[k] - 1)], tok) end end)
  local pn = X.pillow(s.pm, 1.5)
  local pidx = X.tone(c, s.pm, X.light(pn, { amb = 0.3, wrap = 0.4 }), PAP, { cuts = { 0.5, 0.75 }, tok = tok })
  -- bristle lines: radial streaks in the shade tone
  s.pm:each(function(x, y) local dx, dy = x - s.px, y - s.py
    if abs(dx * s.uy - dy * s.ux) < 0.5 and (dx * s.ux + dy * s.uy) > 1 then c:put(x, y, PAP[2], tok) end end)
end
for i, s in ipairs(seeds) do achene(s, { r = { name = "seed" .. i } }) end

-- quirk: a drifting parachute up at the right (achene below, tuft above)
local f = { 47, 18, 2.6, 1.0, 1.35 }
f.m, f.n = A.oval(f[1], f[2], f[3], f[4], f[5], 0.7)
local ca, sa = cos(f[5]), sin(f[5])
f.px, f.py, f.ux, f.uy = f[1] - (f[3] + 0.8) * ca, f[2] - (f[3] + 0.8) * sa, -ca, -sa
f.pm = pappus(f.px, f.py, f.ux, f.uy, 3.2) f.pm:cut(f.m)
achene(f, { r = { name = "drifter" } })
A.save(c, NAME)
