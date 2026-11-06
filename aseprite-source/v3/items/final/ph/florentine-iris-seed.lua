-- florentine-iris-seed (final, Opus single pass). Three iris seeds (plump D-shaped, red-brown, wrinkled coat, one pale
-- hilum) on a torn strip of glaucous iris leaf (sword leaf: parallel veins, no midrib net, waxy bloom flecks, jagged
-- torn ends, AO + contact shadow under each seed). The right seed has sprouted a little equitant fan of three sword
-- leaves, violet-flushed at the base like a real iris fan, with parallel veins.
-- quirk: a scrap of pale lavender iris petal, its yellow beard showing, peeks from under the torn leaf end.
local NAME = "florentine-iris-seed"
local B = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_1.lua")
local HP, X, K = B.HP, B.X, B.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = B.new(NAME)
local LEAF = { "#1c3a40", "#285650", "#3a7464", "#56947a", "#80b694", "#b8d8b2" }
local BLOOM = "#d2e8de"
local BASE = { "#2e2440", "#463462", "#64487e", "#80689a", "#a08cb4", "#c8b8d4" }   -- violet fan base
local SEED = { "#3a1a1c", "#5e2822", "#843e28", "#a85c34", "#cc844c", "#ecb27a" }
local PET = { "#4a3a6e", "#6c5a9a", "#9483c0", "#b7a9dc", "#d6ccef", "#efe9fb" }
local BEARD = { "#e8a83a", "#ffe08a" }
local CUTS = B.CUTS

-- quirk petal first (leaf scrap overlays it)
local pm, pn = B.oval(12, 44, 5.0, 3.0, -0.5, 0.7)
local ptok = { r = { name = "petal" } }
local pidx = X.tone(c, pm, X.light(pn, { amb = 0.2, wrap = 0.3 }), PET, { cuts = CUTS, tok = ptok })
for i, p in ipairs{ { 9, 45 }, { 10, 44 }, { 11, 44 }, { 12, 43 } } do c:put(p[1], p[2], BEARD[i % 2 + 1], ptok) end

-- leaf strip
local lm, ln, LT, LS, len = B.blade(10, 53, 32, 48, 56, 39, function(t) if t > 0.995 then return -1 end return 5.0 end, { fold = 0.22 })
local cut = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  local d0 = t * len
  local d1 = (1 - t) * len
  local j0 = 1.5 + 3.2 * abs(sin(s * 6.3 + 1.1)) + (s > 0.3 and 1.5 or 0)
  local j1 = 1.2 + 3.0 * abs(sin(s * 5.1 + 0.4)) + (s < -0.4 and 2 or 0)
  if d0 < j0 or d1 < j1 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
pm:cut(lm)

local seeds = { { 21, 46, 3.6, 2.9, -0.35 }, { 31, 43, 3.8, 3.0, 0.4 }, { 42, 40, 3.5, 2.8, -0.2 } }
for _, s in ipairs(seeds) do s.m, s.n = B.oval(s[1], s[2], s[3], s[4], s[5], 0.85) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) B.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = B.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s = LS[k] local i = lidx[k]
  if bias[k] then return end
  local u = (s + 1) * 5.4
  if floor(u + 0.5) % 3 == 0 and abs(u - floor(u + 0.5)) < 0.32 then
    c:put(x, y, s < 0 and LEAF[min(6, i + 1)] or LEAF[max(1, i - 1)], ltok)
  elseif i >= 4 and X.hash(x, y, 11) > 0.9 then c:put(x, y, BLOOM, ltok) end
end)
-- torn edge: pale fibrous rim on the torn ends
lm:edge():each(function(x, y) local k = K(x, y)
  if (LT[k] < 0.18 or LT[k] > 0.85) and not bias[k] and abs(LS[k]) < 0.85 then c:put(x, y, LEAF[6], ltok) end end)

-- sprout fan (drawn before the seeds so the seed coat covers its foot)
local function sword(ax, ay, cx, cy, bx, by, w, cutm)
  local m, n, T, S = B.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.35, w * min(1, (1 - t) / 0.4) ^ 0.75) end, { fold = 0.3 })
  if cutm then m:cut(cutm) end
  local tok = { r = { name = "sword" } }
  local idx = B.toneN(c, m, n, LEAF, { amb = 0.14, wrap = 0.3, cuts = CUTS, tok = tok })
  m:each(function(x, y) local k = K(x, y) local s, t, i = S[k], T[k], idx[k]
    if t < 0.17 then c:put(x, y, BASE[i], tok)
    elseif abs(abs(s) - 0.42) < 0.14 and t < 0.86 then c:put(x, y, s < 0 and LEAF[min(6, i + 1)] or LEAF[max(1, i - 1)], tok) end
  end)
  return m
end
local mid = sword(42, 38, 42, 24, 44, 11, 2.0)
local left = sword(40, 39, 37, 28, 32, 17, 1.8, nil)
local right = sword(44, 39, 47, 31, 52, 24, 1.6, nil)
-- AO where the outer leaves wrap the centre leaf
X.ao({}, mid, left, 1, -1)
left:each(function(x, y) if mid:has(x + 1, y) and not left:has(x + 1, y) then c:put(x, y, BASE[2], { r = { name = "sword" } }) end end)

-- seeds: wrinkled coat, AO between, one pale hilum
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  s.m:each(function(x, y) local k = K(x, y)
    local w = sin(x * 1.7 + y * 0.9 + 2.0 * sin(y * 1.3 + i))
    if w > 0.72 then sb[k] = -1 end
  end)
  local idx = X.tone(c, s.m, X.light(s.n, { amb = 0.08, wrap = 0.22 }), SEED, { cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, bias = sb, tok = tok })
  local sx, sy = B.specAt(s.m, s.n, 40)
  c:put(sx, sy, "#fff0d0", tok)
end
-- hilum on the left seed
for _, h in ipairs{ { 19, 48, "#f0d8a8" }, { 20, 48, "#d8b480" } } do if seeds[1].m:has(h[1], h[2]) then c:put(h[1], h[2], h[3], { r = { name = "seed1" } }) end end
B.save(c, NAME)
