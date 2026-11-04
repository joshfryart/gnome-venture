-- poinsettia-seed (final pass, Sonnet). Poinsettia (Euphorbia pulcherrima): three plump, round-ish grey-brown seeds,
-- mottled with dark flecks and a pale caruncle cap, resting on a torn scrap of the lobed, pointed poinsettia leaf
-- (shallow side lobes, pale midrib reddening toward the stalk, angled veins, V fold, cool reflected lower edge,
-- AO + contact shadow under every seed). The middle seed has germinated: a rose-red stem, two broad oval cotyledons
-- and a pair of first true leaves with a pointed lobed blade, so the plant reads at a glance.
-- Material: seeds per-pixel dome light on a 6-tone ramp with hash mottle and a cream caruncle; leaf 6-tone ramp.
-- History: Sonnet draft replaced.
-- quirk: the seedling's growing tip already wears a tiny red bract star with a gold dot.
local NAME = "poinsettia-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD1t0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF  = { "#143a36", "#1f5740", "#2c7646", "#43954b", "#68b556", "#9fd26e" }
local YLEAF = { "#1d4a3a", "#2f6c42", "#478f4a", "#66b054", "#8fcc64", "#c4e688" }
local VEIN, COOL = "#c8e69a", "#3a6c72"
local SEED  = { "#2a1c1e", "#44302e", "#614640", "#80645a", "#a28a78", "#c9b6a0" }
local STEM  = { "#8a2f46", "#bc4c58", "#e07a70", "#f6ac90" }
local BRACT = { "#7a1a32", "#b82a3c", "#e04a44", "#ff7a5c" }
local GOLD  = "#ffd25a"

-- ---------------------------------------------------------------- leaf scrap (lobed, pointed blade, torn)
local PET = { 6, 57 }
local lm, ln, LT, LS, len = A.blade(8, 57, 27, 49.5, 56, 51, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 8.4 * sin(pi * min(1, t * 0.96 + 0.05)) ^ 0.8)
end, { fold = 0.38 })
local cut = {}
-- shallow lobes: wedge notches (two on the upper margin, one below), then a torn tip
local notches = { { 0.34, -1, 0.1, 0.5 }, { 0.6, -1, 0.1, 0.5 }, { 0.48, 1, 0.08, 0.5 } }
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  for _, nn in ipairs(notches) do
    local d = abs(t - nn[1])
    if (s * nn[2] > 0) and d < nn[3] and abs(s) > 1 - nn[4] * (1 - d / nn[3]) then cut[#cut + 1] = k end
  end
  local rag = 0.93 + 0.03 * X.hash(floor(s * 5), 7, 3)
  if t > rag then cut[#cut + 1] = k end
  if (x - 53) ^ 2 / 5 + (y - 55.6) ^ 2 / 3.4 < 1 then cut[#cut + 1] = k end    -- torn bite, lower right
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

local seeds = { { 16, 51, 3.5, 3.1, -0.3 }, { 29, 49, 3.7, 3.2, 0.2 }, { 44, 52, 3.4, 3.0, 0.5 } }
for _, s in ipairs(seeds) do s.m = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.64, 0.82 }, amb = 0.14, wrap = 0.3 })
-- midrib (pale, reddening toward the stalk) + angled side veins
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s, t = LS[k], LT[k]
  if abs(s) < 0.15 and t > 0.02 and t < 0.93 then
    c:put(x, y, (t < 0.3 and s <= 0) and STEM[3] or (s <= 0 and VEIN or LEAF[3]), ltok)
  else
    local ph = ((t * len - abs(s) * 5.0) % 6.2)
    if ph < 0.95 and abs(s) > 0.18 and abs(s) < 0.78 and t > 0.1 and t < 0.9 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.1 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)
-- rose-red petiole stub
for _, q in ipairs{ { 7, 57, 3 }, { 6, 58, 3 }, { 5, 58, 2 }, { 4, 59, 2 }, { 8, 58, 1 }, { 6, 59, 1 } } do c:put(q[1], q[2], STEM[q[3]], ltok) end

-- ---------------------------------------------------------------- sprout from the middle seed
local stok = { r = { name = "stem" } }
local sp = { { 29, 47 }, { 28, 38 }, { 31, 32 }, { 30, 21 } }
local sm, sn = A.tube(sp, function(t) return 1.1 end)
sm:cut(seeds[2].m)
A.shade(c, sm, sn, STEM, { amb = 0.14, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- cotyledons: broad ovals on short stalks, sagging outward
local function coty(cx, cy, ang, ra, rb)
  local m = A.rell(cx, cy, cos(ang), sin(ang), ra, rb)
  m:cut(sm)
  local n = A.dome(m, cx - 0.8, cy - 0.8, ra + 0.5, 1.6, 0.55)
  A.shade(c, m, n, YLEAF, { tok = ltok, amb = 0.08, wrap = 0.25, cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
  for t = -ra + 1, ra - 1.2, 0.5 do local x, y = floor(cx + cos(ang) * t + 0.5), floor(cy + sin(ang) * t + 0.5)
    if m:has(x, y) then c:put(x, y, YLEAF[t < 0 and 6 or 3], ltok) end end
  return m
end
coty(22.5, 36.8, 0.28, 4.8, 2.7)
coty(37.5, 35.6, -0.3, 4.8, 2.7)
-- first true leaves: pointed ovate blades with a small side lobe, rising to either side of the stem
local function tleaf(ax, ay, cx, cy, bx, by, w)
  local m, T, S, idx = A.leaf(c, ax, ay, cx, cy, bx, by, w, YLEAF, { tok = ltok, vs = 3.0, vein = VEIN, pw = 0.7 })
  return m
end
tleaf(30, 27, 22, 25, 16, 17, 3.6)
tleaf(31, 27, 38, 24, 44, 14, 3.6)
for _, q in ipairs{ { 30, 27, 3 }, { 30, 26, 2 }, { 31, 26, 3 }, { 29, 28, 2 } } do c:put(q[1], q[2], STEM[q[3]], stok) end
-- growing tip: a short stalk and the red bract star (quirk)
A.pl({ { 30, 22 }, { 30, 19 } }):each(function(x, y) c:put(x, y, STEM[3], stok) end)
c:put(31, 21, STEM[1], stok) c:put(31, 20, STEM[1], stok)
local btok = { r = { name = "bract" } }
for _, q in ipairs{ { 29, 15, 3 }, { 30, 15, 4 }, { 31, 15, 3 }, { 28, 16, 2 }, { 29, 16, 3 }, { 31, 16, 3 }, { 32, 16, 2 },
  { 30, 13, 4 }, { 30, 14, 3 }, { 29, 17, 2 }, { 31, 17, 2 }, { 27, 17, 1 }, { 33, 17, 1 }, { 30, 12, 3 } } do c:put(q[1], q[2], BRACT[q[3]], btok) end
c:put(30, 16, GOLD, btok) c:put(30, 17, "#e0922a", btok)

-- ---------------------------------------------------------------- seeds last (mottle, caruncle, glint)
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local n = A.dome(s.m, s[1] - 0.5, s[2] - 0.6, s[3] + 0.3, 1.8, 0.65)
  local idx = A.shade(c, vis, n, SEED, { tok = tok, bias = sb, amb = 0.06, wrap = 0.22, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
  vis:each(function(x, y)                                     -- dark flecks + a few pale ones (marbled coat)
    local h = X.hash(x, y, 50 + i)
    local k = K(x, y)
    if h > 0.84 and (idx[k] or 1) >= 2 then A.step(c, idx, SEED, x, y, -2, tok)
    elseif h < 0.07 and (idx[k] or 1) >= 3 then A.step(c, idx, SEED, x, y, 1, tok) end
  end)
  -- caruncle: cream cap at the blunt end
  local ca, sa = cos(s[5]), sin(s[5])
  local hx, hy = floor(s[1] + ca * (s[3] - 0.9) + 0.5), floor(s[2] + sa * (s[3] - 0.9) + 0.5)
  if i == 2 then hx, hy = floor(s[1] - ca * (s[3] - 0.9) + 0.5), floor(s[2] - sa * (s[3] - 0.9) + 0.5) end
  for _, d in ipairs{ { 0, 0 }, { 1, 0 }, { 0, 1 } } do if vis:has(hx + d[1], hy + d[2]) then c:put(hx + d[1], hy + d[2], "#f0e2c4", tok) end end
  -- one glint
  local gx, gy = floor(s[1] - 1.4 + 0.5), floor(s[2] - 1.3 + 0.5)
  if vis:has(gx, gy) then c:put(gx, gy, "#f6ead2", tok) end
end
-- germination split on the sprouting seed
c:put(28, 46, SEED[1]) c:put(29, 46, STEM[2], stok)

A.save(c, NAME)
