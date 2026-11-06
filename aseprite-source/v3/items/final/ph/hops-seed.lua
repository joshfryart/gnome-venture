-- hops-seed (final, Opus single pass). Three small round hop seeds (dark brown, glossy lit cap, pale hilum point) on a
-- torn scrap of hop leaf (saw-toothed lower margin, ragged torn upper edge, midrib + swept veins, V-fold light, cool
-- reflected edge, AO + contact shadow under each seed). The right seed has germinated: pale stem, two strap
-- cotyledons and a first true leaf with the hop's three serrated lobes; the bine tip already coils to climb.
-- quirk: the split seed coat is still stuck on the tip of the left cotyledon like a little cap.
local NAME = "hops-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local VEIN, COOL = "#c2e48c", "#3a6c72"
local SEED = { "#2a1a1c", "#40281f", "#5c3a26", "#7c5232", "#a47444", "#d0a46c" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }

local seeds = { { 18, 50, 2.7, 2.2, 0.3 }, { 27, 49, 2.8, 2.3, -0.2 }, { 39, 45, 2.7, 2.3, -1.2 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end

-- leaf scrap: hop leaf piece on the diagonal, saw teeth on the lower side, torn upper side
local lm, ln, LT, LS, len = A.blade(8, 53, 30, 59, 55, 44, function(t)
  if t > 0.985 then return -1 end
  local base = 8.4 * sin(pi * min(1, t * 0.95 + 0.04)) ^ 0.7
  return max(0.5, base)
end, { fold = 0.38 })
local cut = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  if s > 0 then
    local saw = (t * len / 3.2) % 1
    if s > 0.95 - 0.28 * saw and t > 0.08 and t < 0.92 then cut[#cut + 1] = k end
  else
    local seg = floor(t * len / 3.4)
    local lim = 0.5 + 0.38 * X.hash(seg, 7, 3) + 0.08 * ((t * len / 3.4) % 1)
    if -s > lim and t > 0.1 and t < 0.9 then cut[#cut + 1] = k end
  end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 4.0) / 5.2
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.16 and abs(s) < 0.66 and t > 0.06 and t < 0.9 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
-- torn edge: pale broken tissue along the ragged top; cool bounce on the lower edge
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LS[k] < -0.45 and LT[k] > 0.12 and LT[k] < 0.88 then c:put(x, y, "#b8d88a", ltok)
  elseif LS[k] > 0.6 and LT[k] > 0.1 and LT[k] < 0.86 then c:put(x, y, COOL, ltok) end end)
for _, q in ipairs{ { 7, 54, 4 }, { 6, 55, 3 }, { 5, 56, 3 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout
local stok = { r = { name = "stem" } }
local sp = { { 39, 43 }, { 37, 37 }, { 38, 31 }, { 37, 24 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
sm:cut(seeds[3].m)
A.tone(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
local function cot(ax, ay, cx, cy, bx, by)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, 1.8 * sin(pi * min(1, t * 0.9 + 0.12)) ^ 0.5)
  end, { fold = 0.3 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local cl = cot(37, 31, 31, 29, 25, 25)
local cr = cot(38, 31, 44, 30, 50, 27)
-- first true leaf: three serrated hop lobes
local tl = A.hopLeaf(c, 37, 23, -pi / 2, 9.5, LEAF, ltok, { w = 0.42, bend = 0.3, vein = VEIN })
for _, p in ipairs{ { 37, 24 }, { 37, 25 }, { 38, 26 } } do c:put(p[1], p[2], STEM[3], stok) end
-- bine shoot coiling out to the right (hooked climbing tip)
local coil = { { 39, 27 }, { 40, 26 }, { 41, 25 }, { 42, 24 }, { 43, 23 }, { 44, 22 }, { 45, 22 }, { 46, 23 }, { 46, 24 }, { 45, 25 }, { 44, 24 } }
for i, p in ipairs(coil) do if not tl:has(p[1], p[2]) or i > 3 then c:put(p[1], p[2], (i % 3 == 0) and STEM[1] or STEM[3], stok) end end
c:put(47, 23, STEM[1], stok) c:put(47, 24, STEM[1], stok)

-- seeds last
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  A.tone(c, vis, s.n, SEED, { tok = tok, bias = sb, cuts = { 0.15, 0.3, 0.46, 0.62, 0.8 } })
  -- pale hilum point at one end, specular on the lit cap
  local ca, sa = cos(s[5]), sin(s[5])
  local hx, hy = floor(s[1] + ca * (s[3] + 0.2) + .5), floor(s[2] + sa * (s[3] + 0.2) + .5)
  if vis:has(hx, hy) then c:put(hx, hy, SEED[6], tok) end
  local bx, by = A.specAt(vis, s.n, 30)
  if bx then c:put(bx, by, (i == 2) and A.CREAM or SEED[6], tok) end
end
-- germinated seed: split line where the stem pushes out
c:put(39, 44, SEED[1], { r = { name = "seed3" } })

-- quirk: seed-coat cap on the left cotyledon tip
local qtok = { r = { name = "cap" } }
for _, q in ipairs{ { 24, 24, 4 }, { 25, 24, 5 }, { 26, 24, 4 }, { 24, 25, 3 }, { 25, 25, 2 }, { 23, 25, 3 }, { 26, 23, 6 }, { 25, 23, 5 } } do
  c:put(q[1], q[2], SEED[q[3]], qtok) end
A.save2(c, NAME)
