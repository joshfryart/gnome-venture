-- artichoke-seed (final pass, Opus). Three artichoke achenes (blunt obovoid, grey-brown with darker mottling, a pale
-- collar on the flat top end, faint ribs) on a torn scrap of artichoke leaf: silver-green, deeply lobed with pointed
-- lobe tips, pale felted midrib and a vein into each lobe, V-fold light, cool edge on the shade side, a ragged torn
-- base showing pale fibres; AO + contact shadow under each seed. The right seed has germinated: pale stem, two thick
-- oval cotyledons and a first true leaf, lance-shaped with toothed lobes and a silvery bloom, like the parent.
-- quirk: the left seed still wears its feathery pappus, a little fan of thistle down.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "artichoke-seed"
local c = A.new(NAME)

local LEAF = { "#172a30", "#24443f", "#38644f", "#558462", "#7ea47a", "#b0caa0" }
local RIB, COOL, TORN = "#d4e0c4", "#3f6a78", "#c8d2a8"
local SEED = { "#2c1c20", "#4a302c", "#6c4a36", "#946a46", "#bc905e", "#e2c08a" }
local MOT = "#3a2426"
local STEM = { "#5a7c5c", "#8cae7c", "#bcd6a4", "#e4f0cc" }
local COT = { "#1f3c36", "#2c5a42", "#40784c", "#5e9658", "#86b46c", "#b4d290" }
local DOWN = { "#b8b0a8", "#e4dccc", "#fbf4e2" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local ltok = { r = { name = "leaf" } }

-- seeds: cx, cy, rx, ry, angle (angle = direction of the flat top end)
local seeds = { { 19, 47.5, 4.2, 2.6, pi + 0.45 }, { 30, 46, 4.3, 2.7, -0.2 }, { 40.5, 42.5, 4.0, 2.6, -1.45 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- leaf scrap: lobed artichoke pinna on the diagonal
local PER = 8.2
local lm, ln, LT, LS, len = A.blade(9, 54, 31, 51, 56, 37, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.9 + 0.1)
  return max(0.5, 10.2 * sin(pi * u ^ 1.05) ^ 0.6)
end, { fold = 0.42 })
-- pointed lobes: deep notches with a sharp tip at each lobe centre
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local ph = t * len / PER + (s > 0 and 0.5 or 0) + 0.1 - abs(s) * 0.35     -- lobes swept toward the tip
  local f = abs((ph - floor(ph)) - 0.5) * 2
  local lim = 0.98 - (1 - f) ^ 1.25 * (0.66 + 0.1 * t)
  if t > 0.1 and t < 0.95 and abs(s) > lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
-- torn base: ragged edge
local torn = {}
lm:each(function(x, y) local k = K(x, y) if LT[k] < 0.06 + 0.05 * X.hash(floor(LS[k] * 6), 0, 5) then torn[#torn + 1] = k end end)
for _, k in ipairs(torn) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.15 and t > 0.03 and t < 0.94 then c:put(x, y, s <= 0 and RIB or LEAF[4], ltok) return end
  local ph = (t * len - abs(s) * 4.6) / PER + (s > 0 and 0.5 or 0) + 0.1
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.16 and abs(s) < 0.72 and t > 0.08 and t < 0.9 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LT[k] < 0.13 then c:put(x, y, (x + y) % 2 == 0 and TORN or LEAF[5], ltok)                 -- pale torn fibres
  elseif LS[k] > 0.62 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)

-- sprout (before seeds so the coat sits over the stem foot)
local stok = { r = { name = "stem" } }
local sm = A.stem(c, { { 40, 41 }, { 39, 35 }, { 40, 30 }, { 40, 25 } }, function() return 1.05 end, STEM, { tok = stok, cut = seeds[3].m, cuts = { 0.3, 0.55, 0.8 } })
local ctok = { r = { name = "cot" } }
local function cotyledon(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 0.88 + 0.12)) ^ 0.55)
  end, { fold = 0.2 })
  m:cut(sm)
  local idx = A.toneN(c, m, n, COT, { tok = ctok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.12 and T[k] > 0.15 and T[k] < 0.7 then c:put(x, y, COT[min(6, idx[k] + 1)], ctok) end end)
  return m
end
local cl = cotyledon(39, 26, 34, 24, 29, 22, 2.3)
local cr = cotyledon(41, 26, 46, 24, 51, 22, 2.3)
-- first true leaf: lance-shaped, toothed lobes, silver
local tl, tn, TT, TS, tlen = A.blade(40, 25, 41, 18, 45, 11, function(t)
  if t > 0.985 then return -1 end
  local w = 3.3 * sin(pi * min(1, t * 0.92 + 0.06)) ^ 0.8
  return max(0.4, w)
end, { fold = 0.45 })
-- toothed margin: notch the edge every ~2.6 px, alternating sides
do local cutT = {}
  tl:edge():each(function(x, y) local k = K(x, y) local ph = (TT[k] * tlen / 2.6 + (TS[k] > 0 and 0.5 or 0)) % 1
    if TT[k] > 0.2 and TT[k] < 0.88 and ph < 0.4 and abs(TS[k]) > 0.45 then cutT[#cutT + 1] = k end end)
  for _, k in ipairs(cutT) do tl.s[k] = nil end end
tl:cut(cl):cut(cr)
local tidx = A.toneN(c, tl, tn, COT, { tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
tl:each(function(x, y) local k = K(x, y) if abs(TS[k]) < 0.15 and TT[k] > 0.05 and TT[k] < 0.85 then c:put(x, y, TS[k] <= 0 and RIB or LEAF[4], ltok) end end)
for y = 25, 27 do c:put(40, y, STEM[2], stok) end

-- quirk: pappus fan on the left seed (radiating down bristles with tiny barbs), drawn before the seed
local px0, py0 = 15, 45
local dtok = { r = { name = "down" } }
for i, a in ipairs{ -1.95, -2.45, -2.95 } do
  local L = 9 + (i % 2)
  for r = 1, L do
    local x, y = floor(px0 + cos(a) * r + 0.5), floor(py0 + sin(a) * r + 0.5)
    c:put(x, y, r < 3 and DOWN[1] or DOWN[2], dtok)
    if r > 4 and r % 4 == 1 then c:put(x + (i <= 2 and -1 or 0), y + (i <= 2 and 0 or -1), DOWN[3], dtok) end
  end
end

-- seeds last: mottled coats, pale collar at the flat top end, faint ribs
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = A.toneN(c, vis, s.n, SEED, { tok = tok, bias = sb, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.25 })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    if u > 0.72 then c:put(x, y, SEED[min(6, (idx[k] or 3) + 2)], tok)                         -- pale collar
    elseif abs(v) < 0.14 and u > -0.6 then c:put(x, y, SEED[max(1, (idx[k] or 3) - 1)], tok)   -- rib
    elseif X.hash(x, y, 13 + i) > 0.62 and u < 0.6 then c:put(x, y, (idx[k] or 3) > 4 and SEED[3] or MOT, tok) end   -- mottling
  end)
  local gx, gy = A.specAt(vis, s.n, 30) if gx then c:put(gx, gy, SEED[6], tok) end
end

A.save(c, NAME)
