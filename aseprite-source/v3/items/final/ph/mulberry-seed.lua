-- mulberry-seed (final, Opus single pass). Three tiny tan mulberry seeds (plump tear-drops with a pointed end, a
-- dark hilum dot and a lit ridge) on a torn scrap of mulberry leaf (serrated margin, midrib + swept veins, V-fold
-- light, jagged torn end with a pale torn edge, AO + contact shadow under each seed). The front seed has sprouted:
-- pale stem, two round cotyledons and a first true leaf that is a tiny heart-shaped, toothed mulberry leaf.
-- quirk: a purple juice stain on the scrap where a ripe drupelet got squashed.
local NAME = "mulberry-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#173f36", "#225a40", "#2f7848", "#47974e", "#6cb656", "#9fd26e" }
local TORN, COOL = "#d6e9a4", "#3a6c72"
local SEED = { "#4a2c24", "#6e4630", "#96683e", "#bc8e56", "#dcb878", "#f4dca6" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local JUICE = { "#3a1846", "#5a2466", "#7c3a84" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- seeds: cx, cy, rx, ry, angle (pointed end toward +u)
local seeds = { { 17, 50, 3.2, 2.2, 0.35 }, { 26, 47, 3.0, 2.1, -0.5 }, { 36, 45, 3.2, 2.3, 0.15 } }
for _, s in ipairs(seeds) do
  s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9)
  -- tear-drop: trim the corners of the pointed end
  local ca, sa = cos(s[5]), sin(s[5])
  s.m:each(function(x, y) local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    if u > 0.25 and abs(v) > 1.05 - u * 0.9 then s.m.s[K(x, y)] = nil end end)
end

-- leaf scrap: base (cordate lobe) lower-left, torn across upper-right
local lm, ln, LT, LS, len = A.leaf(8, 53, 30, 54, 57, 40, function(t)
  if t > 0.99 then return -1 end
  return max(0.6, 8.6 * sin(pi * min(1, 0.2 + t * 0.85)) ^ 0.6)
end, { per = 3.4, depth = 0.18, fold = 0.38 })
-- torn end: jagged line across at t ~ 0.8
local torn = HP.mask()
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.8 + 0.045 * sin(LS[k] * 9.5) + 0.03 * (X.hash(x, y, 3) - 0.5)
  if LT[k] > lim then lm.s[k] = nil end
end)
lm:each(function(x, y) if not lm:has(x + 1, y) and LT[K(x, y)] > 0.7 or not lm:has(x, y - 1) and LT[K(x, y)] > 0.74 then torn:set(x, y) end end)

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
A.veins(c, lm, LT, LS, len, LEAF, ltok, { per = 5.6, skip = bias, rib = "#c4e490" })
-- cool reflected light on the lower-right margin
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.12 and LT[k] < 0.75 then c:put(x, y, COOL, ltok) end end)
-- pale torn edge (exposed leaf tissue)
torn:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, TORN, ltok) end end)
-- petiole stub at the base
for _, q in ipairs{ { 7, 54, 4 }, { 6, 55, 3 }, { 5, 56, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- quirk: purple juice stain, squashed drupelet (irregular blot with a darker rim and a wet glint)
local jtok = { r = { name = "juice" } }
local jm = HP.mask()
for _, b in ipairs{ { 45, 46, 2.2 }, { 47.5, 45, 1.6 }, { 44, 48, 1.3 } } do
  for y = floor(b[2] - 3), floor(b[2] + 3) do for x = floor(b[1] - 3), floor(b[1] + 3) do
    if (x - b[1]) ^ 2 + (y - b[2]) ^ 2 <= b[3] ^ 2 + 0.6 then jm:set(x, y) end end end
end
jm:clip(lm)
jm:each(function(x, y) c:put(x, y, JUICE[2], jtok) end)
jm:edge():each(function(x, y) if x + y > 92 then c:put(x, y, JUICE[1], jtok) end end)
c:put(44, 45, JUICE[3], jtok) c:put(45, 45, "#b48ac0", jtok)

-- sprout from the front seed: stem up, two round cotyledons, heart-shaped toothed true leaf
local stok = { r = { name = "stem" } }
local sm, sn = A.tube({ { 36, 44 }, { 35, 37 }, { 37, 31 }, { 36, 24 } }, function(t) return 1.05 end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function coty(cx, cy, ang)
  local m, n = A.oval(cx, cy, 3.4, 2.2, ang, 0.7)
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  return m
end
local cl = coty(31, 30, 0.35)
local cr = coty(41, 31, -0.4)
-- shade where cotyledons meet the stem
for _, q in ipairs{ { 34, 31 }, { 38, 31 } } do c:put(q[1], q[2], LEAF[2], ltok) end
-- true leaf: heart base at the stem top, tip up-right
local tm, tn, TT, TS, tlen = A.leaf(36, 24, 36, 15, 43, 9, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 5.6 * sin(pi * min(1, 0.2 + t * 0.85)) ^ 0.6 * (1 - 0.2 * t))
end, { per = 2.8, depth = 0.22, fold = 0.35, t0 = 0.15 })
tm:each(function(x, y) local k = K(x, y) if TT[k] < 0.06 and abs(TS[k]) < 0.4 then tm.s[k] = nil end end)
tm:cut(cl):cut(cr)
A.toneN(c, tm, tn, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
A.veins(c, tm, TT, TS, tlen, LEAF, ltok, { per = 4.2, sweep = 3, rib = "#c4e490" })

-- seeds last: tear-drop coats with lit ridge, hilum at the blunt end, AO between neighbours
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  if i == 3 then X.ao(sb, s.m, sm, 1, -1) end
  local idx = A.toneN(c, s.m, s.n, SEED, { tok = tok, bias = sb, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.1, wrap = 0.25 })
  local ca, sa = cos(s[5]), sin(s[5])
  -- hilum: dark dot at the blunt end
  local hx, hy = floor(s[1] - ca * (s[3] - 0.6) + .5), floor(s[2] - sa * (s[3] - 0.6) + .5)
  if s.m:has(hx, hy) then c:put(hx, hy, SEED[1], tok) end
  -- shade-side seam line along the body
  for u = -0.3, 0.6, 0.3 do
    local x, y = floor(s[1] + ca * u * s[3] - sa * 0.9 * -1 + .5), floor(s[2] + sa * u * s[3] + ca * 0.9 + .5)
    if s.m:has(x, y) then c:put(x, y, SEED[2], tok) end
  end
  -- glint
  local gx, gy = A.specAt(s.m, s.n, 30)
  if gx then c:put(gx, gy, i == 3 and A.CREAM or SEED[6], tok) end
end

A.save2(c, NAME)
