-- ackee-seed (final pass, Opus). Three glossy black ackee seeds lying along a torn ackee leaflet (elliptic, glossy,
-- net-veined: midrib + curved side veins, a natural tip on the left, a ragged torn edge on the right). The left seed
-- has germinated: a pale shoot with a dark collar, and the seedling's first leaf pair plus a folded new pair at the top,
-- the ackee's paired elliptic leaflets in miniature.
-- Material: seeds per-pixel sphere light on a near-black violet ramp, a bright glint each and a violet rim light; pale
-- hilum scar; leaf V-fold light with cool reflected edge, AO + contact shadow under every seed.
-- History: Sonnet draft replaced.
-- quirk: the right seed still wears a scrap of its creamy aril, like a little cap.
local NAME = "ackee-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR1_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local SPR  = { "#24543c", "#357a44", "#4f9a4c", "#72b858", "#9ccf6c", "#c8e690" }
local VEIN, COOL = "#b8dc8a", "#3a6c72"
local SEED = { "#1e1622", "#2e2234", "#403048", "#584466", "#7a6896", "#b0a4d0" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local ARL  = { "#b08040", "#d8b050", "#f0d070", "#fae79a", "#fff6cc" }
local CREAM = "#fff4d6"

local seeds = { { 22, 44, 4.4 }, { 33, 46, 4.7 }, { 44, 43.5, 4.0 } }
for _, s in ipairs(seeds) do s.m = c:ellipse(s[1], s[2], s[3], s[3] - 0.4) end

-- leaflet scrap: natural tip at the left, torn at the right
local lm, ln, LT, LS, len = A.blade(56, 46, 34, 53, 7, 50, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.8 + 0.2)
  return max(0.5, 7.6 * sin(pi * u) ^ 0.6)
end, { fold = 0.4 })
local cut = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  local d = t * len
  local rag = 1.0 + 2.6 * X.hash(floor(s * 5 + 0.5), 3, 11) + 1.0 * abs(sin(s * 9))
  if d < rag then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 and t > 0.03 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- curved side veins sweeping toward the tip, looping near the margin
  local ph = (t * len + abs(s) * 5.5) / 6.2
  local f = ph - floor(ph)
  if f < 0.16 and abs(s) > 0.14 and abs(s) < 0.78 and t > 0.05 and t < 0.9 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.66 and LT[k] > 0.1 and LT[k] < 0.92 then c:put(x, y, COOL, ltok) end end)

-- sprout from the left seed
local stok = { r = { name = "shoot" } }
local sp = { { 22, 41 }, { 21, 34 }, { 24, 28 }, { 23, 21 } }
local sm, sn = A.tube(sp, function(t) return 1.2 - 0.25 * t end)
sm:cut(seeds[1].m)
A.shade(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function leaflet(ax, ay, cx, cy, bx, by, w, ramp)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.98 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.92 + 0.06)) ^ 0.65)
  end, { fold = 0.3 })
  m:cut(sm)
  A.shade(c, m, n, ramp, { tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
  local L = sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.13 and t > 0.08 and t < 0.86 then c:put(x, y, s <= 0 and ramp[6] or ramp[3], ltok) end
    local ph = (t * L - abs(s) * 2.2) / 3.2
    if ph - floor(ph) < 0.2 and abs(s) > 0.3 and abs(s) < 0.75 and t > 0.15 and t < 0.8 then c:put(x, y, s < 0 and ramp[5] or ramp[2], ltok) end
  end)
  return m
end
local L1 = leaflet(22, 28, 16, 25, 9, 27, 3.3, SPR)
local L2 = leaflet(24, 27, 31, 22, 38, 23, 3.3, SPR)
-- new pair at the top, still folded upward
local L3 = leaflet(23, 22, 20, 18, 18, 13, 1.8, SPR)
local L4 = leaflet(23, 22, 26, 18, 28, 13, 1.8, SPR)
-- node collars
for _, p in ipairs{ { 22, 28, 1 }, { 23, 28, 2 }, { 23, 22, 1 } } do c:put(p[1], p[2], STEM[p[3]], stok) end

-- seeds
for i, s in ipairs(seeds) do
  local m = s.m
  local tok = { r = { name = "seed" .. i } }
  local n = X.sphere(s[1] - 0.4, s[2] - 0.5, s[3] + 0.3, m)
  local idx = A.shade(c, m, n, SEED, { amb = 0.02, wrap = 0.15, tok = tok, cuts = { 0.34, 0.54, 0.7, 0.83, 0.93 } })
  m:edge():each(function(x, y) if (x - s[1]) + (y - s[2]) > s[3] * 0.95 then c:put(x, y, SEED[4], tok) end end)
  local gx, gy = floor(s[1] - s[3] * 0.45 + 0.5), floor(s[2] - s[3] * 0.5 + 0.5)
  c:put(gx, gy, CREAM, tok) c:put(gx + 1, gy, SEED[6], tok) c:put(gx, gy + 1, SEED[5], tok)
  -- small pale hilum on the lower-right of the middle seed
  if i == 2 then c:put(s[1] + 2, s[2] + 2, SEED[5], tok) c:put(s[1] + 3, s[2] + 1, SEED[4], tok) end
end
-- germination pore on the left seed
c:put(21, 40, SEED[2]) c:put(23, 40, SEED[2]) c:put(22, 40, STEM[2])

-- quirk: aril scrap on the right seed (creamy lumpy cap, AO under it)
local s3 = seeds[3]
local cap = c:ellipse(s3[1] + 0.5, s3[2] - 3.2, 3.6, 1.8)
local atok = { r = { name = "aril" } }
cap:each(function(x, y)
  local i = 3
  if y < s3[2] - 3.8 then i = 4 end
  if x < s3[1] - 1 and y < s3[2] - 3 then i = 5 end
  if x > s3[1] + 2 then i = i - 1 end
  if y > s3[2] - 2.6 then i = 2 end
  if (x + y) % 3 == 0 and i > 2 then i = i - 1 end
  c:put(x, y, ARL[max(1, i)], atok)
end)
cap:shift(0, 1):cut(cap):each(function(x, y) if s3.m:has(x, y) then c:put(x, y, SEED[1], { r = { name = "seed3" } }) end end)

A.save(c, "ph", NAME)
