-- longan-seed (final, Opus single pass). Three glossy round longan seeds (near-black brown, each with the pale
-- tan "dragon eye" hilum disc ringed in dark) on a torn longan-leaf scrap (smooth margin, V-fold light, pinnate
-- veins, jagged torn end with a paler torn edge, cool reflected rim, AO + contact shadow under each seed). The right
-- seed has germinated: slim stem, first paripinnate leaf in two pairs of narrow leaflets, the lower pair green and the
-- new upper pair in longan's coppery-red flush.
-- quirk: the left seed still wears a glassy sliver of leftover pearl flesh.
local NAME = "longan-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local VEIN, COOL, TORN = "#c2e48c", "#3a6c72", "#b8d88a"
local SEED = { "#170e14", "#2a181c", "#432622", "#62382a", "#86523a", "#b07850" }
local EYE = { "#8a6440", "#c49a66", "#e6c890" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92" }
local BRONZE = { "#4a1a26", "#7a2a2e", "#a8443a", "#cc6848", "#e8945e", "#f8c48a" }
local PEARL = { "#b8c0c8", "#e2e8e2", "#f8f8ee" }

local seeds = { { 18.5, 47.5, 4.3 }, { 29.5, 44.5, 4.3 }, { 41.5, 41.5, 4.5 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[3] * 0.92, 0, 1) end

-- leaf scrap, diagonal, torn at the upper-right end
local lm, ln, LT, LS, len = A.blade(7, 54, 30, 50, 57, 41, function(t)
  if t > 0.99 then return -1 end
  return max(0.6, 8.2 * sin(pi * min(1, t * 0.7 + 0.08)) ^ 0.6)
end, { fold = 0.4 })
-- torn edge: jagged cut line across the blade near the end
local torn = HP.mask()
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local j = 0.8 + 0.035 * sin(s * 9.0) + 0.025 * (X.hash(floor(s * 6), 1, 5) - 0.5) * 2 + 0.03 * s
  if t > j then lm.s[k] = nil end
end)
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local j = 0.8 + 0.035 * sin(s * 9.0) + 0.025 * (X.hash(floor(s * 6), 1, 5) - 0.5) * 2 + 0.03 * s
  if t > j - 0.022 then torn:set(x, y) end
end)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 6) / 5.2
  local f = ph - floor(ph)
  if f < 0.16 and abs(s) > 0.16 and abs(s) < 0.82 and t > 0.06 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.08 and LT[k] < 0.75 then c:put(x, y, COOL, ltok) end end)
torn:each(function(x, y) if lm:has(x, y) and not bias[K(x, y)] then c:put(x, y, TORN, ltok) end end)
-- petiole stub
for _, q in ipairs{ { 6, 55, 4 }, { 5, 56, 3 }, { 4, 57, 3 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout: stem from the top of the right seed, two pairs of narrow leaflets
local stok = { r = { name = "stem" } }
local sp = { { 41.5, 38 }, { 41, 32 }, { 42, 26 }, { 41.5, 17 } }
local sm, sn = A.tube(sp, function(t) return 1.0 - 0.25 * t end, 80)
sm:cut(seeds[3].m)
local function leaflet(ax, ay, bx, by, cx, cy, w, ramp, tok)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.98 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.7)
  end, { fold = 0.35 })
  m:cut(sm)
  A.shade(c, m, n, ramp, { tok = tok, amb = 0.14, wrap = 0.3, cuts = A.CUTS6 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.16 and T[k] > 0.08 and T[k] < 0.86 then c:put(x, y, S[k] <= 0 and ramp[6] or ramp[3], tok) end end)
  return m
end
local gtok, btok = { r = { name = "lflt" } }, { r = { name = "flush" } }
leaflet(40, 29, 30, 26, 34, 25, 2.0, LEAF, gtok)
leaflet(43, 29, 53, 27, 49, 25, 2.0, LEAF, gtok)
leaflet(40, 21, 33, 15, 35, 17, 1.8, BRONZE, btok)
leaflet(43, 21, 51, 15, 48, 17, 1.8, BRONZE, btok)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.35, 0.65 }, tok = stok })
c:put(41, 16, BRONZE[4], btok) c:put(41, 15, BRONZE[5], btok)       -- curled terminal bud

-- seeds: glossy, dark, hilum eye on the lower-left face
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, s.m, s.n, SEED, { amb = 0.06, wrap = 0.2, tok = tok })
  local rim = X.rim(s.n)
  s.m:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.6 and idx[k] <= 2 then c:put(x, y, "#4a3a4e", tok) end end)
  -- eye: pale disc + darker ring, placed on the front-lower side
  local ex, ey = floor(s[1] - 0.5 + (i == 3 and 1 or 0)), floor(s[2] + 1.2)
  local eye = HP.mask()
  for _, q in ipairs{ { 0, 0 }, { 1, 0 }, { -1, 0 }, { 0, 1 }, { 1, 1 }, { -1, 1 }, { 0, -1 } } do eye:set(ex + q[1], ey + q[2]) end
  eye:clip(s.m)
  eye:each(function(x, y) local dx, dy = x - ex, y - ey
    c:put(x, y, (dy < 0 or dx < 0) and EYE[3] or ((dy > 0 and dx > 0) and EYE[1] or EYE[2]), tok) end)
  A.touch(s.m:copy():cut(eye), eye):each(function(x, y) if idx[K(x, y)] > 2 then c:put(x, y, SEED[2], tok) end end)
  -- glossy specular (2x1 + sparkle pixel)
  local hx, hy = A.specAt(s.m, s.n, 40)
  c:put(hx, hy, "#fff0e0", tok) c:put(hx + 1, hy, SEED[6], tok) c:put(hx, hy + 1, SEED[5], tok)
end
-- quirk: glassy sliver of pearl flesh on the left seed (upper-right shoulder)
do local s = seeds[1] local ptok = { r = { name = "aril" } }
  for _, q in ipairs{ { 2, -3, 3 }, { 3, -2, 2 }, { 3, -1, 2 }, { 1, -4, 3 }, { 2, -2, 1 } } do
    local x, y = floor(s[1] + q[1]), floor(s[2] + q[2])
    if s.m:has(x, y) then c:put(x, y, PEARL[q[3]], ptok) end
  end
end

A.save(c, NAME)
