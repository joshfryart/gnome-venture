-- clove-seed (final, Opus single pass). Two oblong "mother of clove" seeds (glossy plum-brown, a tiny four-point
-- crown at one end, 2x1 glint, AO + contact shadow) on a torn scrap of glossy clove leaf (lanceolate, pale midrib,
-- side veins, ragged torn edge in pale tissue). The right seed has sprouted: slim stem, one pair of narrow
-- elliptic leaves with midribs, and a tiny new pair at the tip.
-- quirk: the newest leaf pair flushes coral-pink, exactly as young clove leaves do.
local NAME = "clove-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#13332d", "#1c4a37", "#286640", "#3a8649", "#5aa853", "#93cc6a" }
local TORN = "#cfe3a0"
local SEED = { "#24121e", "#41202c", "#622e36", "#87413e", "#ac5f4c", "#d18b68" }
local STEM = { "#3f6e3c", "#5e9446", "#8cbc5e", "#c4e08c" }
local PINK = { "#5a1c30", "#842a3e", "#b0414a", "#d6635a", "#f08c76", "#ffc0a0" }
local CUT6 = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- seeds
local seeds = { { 20, 47, 5.2, 2.7, -0.15 }, { 34, 48, 5.0, 2.6, 0.35 } }
local sall = HP.mask()
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) sall:add(s.m) end

-- leaf scrap: wide torn base on the left, pointed tip on the right
local lm, ln, LT, LS, len = A.blade(4, 50, 30, 60, 58, 44, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 8.4 * sin(pi * (0.32 + 0.68 * t)) ^ 0.65)
end, { fold = 0.36 })
local tear = HP.mask()
lm:each(function(x, y) local j = floor(X.hash(0, y, 5) * 3) + (y % 3 == 0 and 1 or 0)
  if x < 9 + j - floor((y - 50) * 0.3) then tear:set(x, y) end end)
lm:cut(tear)
-- a small bite torn out of the upper edge
lm:each(function(x, y) if (x - 26)^2 + (y - 46.5)^2 < 4.5 and LS[K(x, y)] < -0.6 then lm.s[K(x, y)] = nil end end)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t < 0.95 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[4], ltok) return end
  local d = (t * len - abs(s) * 6.5) % 5.2
  if d < 0.85 and abs(s) > 0.18 and abs(s) < 0.78 and t < 0.88 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)
-- torn edge: pale broken tissue
lm:edge():each(function(x, y)
  if tear:has(x - 1, y) or tear:has(x, y - 1) or tear:has(x, y + 1) then c:put(x, y, TORN, ltok)
  elseif (x - 26)^2 + (y - 46.5)^2 < 9 then c:put(x, y, TORN, ltok) end end)
-- gloss streak on the lit half of the leaf
lm:each(function(x, y) local k = K(x, y) if LS[k] > -0.7 and LS[k] < -0.5 and LT[k] > 0.55 and LT[k] < 0.72 and not bias[k] then c:put(x, y, LEAF[6], ltok) end end)

-- sprout (behind the seeds' tops)
local stok = { r = { name = "stem" } }
local sp = { { 36, 46 }, { 35, 38 }, { 38, 30 }, { 37, 20 } }
local sm, sn = A.tube(sp, function(t) return 1.15 - 0.25 * t end)
sm:cut(sall)
A.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok, amb = 0.15, wrap = 0.3 })
local function lf(ax, ay, cx, cy, bx, by, w, ramp, name)
  local tok = { r = { name = name } }
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end return max(0.4, w * sin(pi * min(1, t * 0.92 + 0.06)) ^ 0.7) end, { fold = 0.42 })
  m:cut(sm)
  local idx = A.toneN(c, m, n, ramp, { tok = tok, cuts = CUT6, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.15 and T[k] > 0.06 and T[k] < 0.86 then c:put(x, y, S[k] <= 0 and ramp[6] or ramp[3], tok)
    elseif abs(S[k]) > 0.3 and abs(S[k]) < 0.75 and T[k] > 0.15 and T[k] < 0.8 and (T[k] * L - abs(S[k]) * w) % 3.6 < 0.8 then
      c:put(x, y, ramp[max(1, idx[k] - 1)], tok) end end)
  return m
end
local l1 = lf(36, 33, 28, 26, 18, 28, 3.3, LEAF, "lfL")
local l2 = lf(37, 33, 45, 25, 55, 24, 3.3, LEAF, "lfR")
-- ambient shading where the leaf pair meets the stem
for _, q in ipairs{ { 35, 34 }, { 38, 34 } } do if l1:has(q[1], q[2]) or l2:has(q[1], q[2]) then c:put(q[1], q[2], LEAF[2], { r = { name = "lfL" } }) end end
local p1 = lf(37, 21, 33, 16, 31, 12, 1.7, PINK, "pkL")
local p2 = lf(37, 21, 41, 15, 44, 12, 1.7, PINK, "pkR")
c:put(37, 19, PINK[5], { r = { name = "bud" } }) c:put(37, 18, PINK[4], { r = { name = "bud" } })

-- seeds last
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  for j = i + 1, #seeds do X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local vis = s.m:copy()
  for j = i + 1, #seeds do vis:cut(seeds[j].m) end
  local idx = A.shade(c, vis, s.n, SEED, { bias = sb, tok = tok, amb = 0.1, wrap = 0.3 })
  -- waxy bloom: pale specks on the lit upper half
  vis:each(function(x, y) local k = K(x, y)
    if idx[k] and idx[k] >= 4 and X.hash(x, y, 11 + i) > 0.82 then c:put(x, y, SEED[min(6, idx[k] + 1)], tok) end end)
  -- cool bounce on the shade rim
  local rim = X.rim(s.n)
  vis:edge():each(function(x, y) if rim[K(x, y)] > 0.7 then c:put(x, y, "#6c5a80", tok) end end)
  -- crown at the right end: a dark eye with four tiny points
  local ca, sa = cos(s[5]), sin(s[5])
  local ex, ey = floor(s[1] + ca * (s[3] - 0.6) + .5), floor(s[2] + sa * (s[3] - 0.6) + .5)
  c:put(ex, ey, SEED[1], tok)
  c:put(ex + 1, ey - 1, SEED[3], tok) c:put(ex + 1, ey + 1, SEED[2], tok) c:put(ex + 1, ey, SEED[4], tok)
  -- glint
  local gx, gy = A.specAt(vis, s.n, 30)
  c:put(gx, gy, "#fff4d6", tok) c:put(gx + 1, gy, SEED[6], tok)
end

A.save(c, NAME)
