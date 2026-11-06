-- copihue-seed (final pass, Opus single pass). Three plump, rounded tan copihue seeds (glossy, a dark hilum scar on
-- each, AO and contact shadow onto the leaf) resting on a torn scrap of leathery, dark glossy lapageria leaf with the
-- plant's arcuate parallel veins converging to the tip and a ragged tear at the base. The right seed has sprouted a
-- slim twining vine: a pointed ovate leaf with the same arcuate veins, a smaller second leaf and a curled tip.
-- quirk: a tiny closed crimson bell bud (the copihue flower) already dangles from the seedling.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "copihue-seed"
local c = A.new(NAME)
local LEAF = { "#12302c", "#1b4a36", "#266640", "#38844a", "#5aa858", "#94cf78" }
local GLOSS, COOL = "#d6f0a8", "#356a74"
local SEED = { "#4a2e22", "#7a5236", "#a87c4e", "#cfa76c", "#ecd29a", "#fff0c8" }
local STEM = { "#2f5a3a", "#4f8a4a", "#7cb662", "#b4dc8a" }
local BUD = { "#5a1428", "#8f1f33", "#c9303e", "#ec5c58", "#ff9a8a" }
local ltok = { r = { name = "leaf" } }
local stok = { r = { name = "stem" } }

-- seeds (defined first, painted last)
local seeds = { { 18, 45, 3.3, 2.6, 0.3 }, { 27, 42, 3.4, 2.7, -0.2 }, { 37, 44, 3.2, 2.6, 0.5 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end

-- leaf scrap: broad end at the torn base (left), tapering to the tip (right)
local lm, ln, LT, LS, len = A.blade(7, 50, 30, 36, 56, 42, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 7.6 * sin(pi * (0.34 + 0.66 * t)) ^ 0.75)
end, { fold = 0.3 })
-- ragged tear at the base
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local s, t = LS[k], LT[k]
  local z = 0.05 + 0.045 * (((floor((s + 1) * 4.5)) % 2 == 0) and 1 or 0) + 0.02 * (((floor((s + 1) * 9)) % 3 == 0) and 1 or 0)
  if t < z then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
-- a small bite out of the upper margin
lm:each(function(x, y) if (x - 40) ^ 2 + (y - 33.5) ^ 2 < 4.5 then lm.s[K(x, y)] = nil end end)

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.3, 0.46, 0.6, 0.74, 0.88 }, amb = 0.1, wrap = 0.3 })
-- arcuate veins: midrib + two pairs of parallel veins that converge at the tip
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  local i = lidx[k] or 3
  if t > 0.04 and t < 0.95 then
    if abs(s) < 0.12 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok)
    elseif (abs(abs(s) - 0.42) < 0.07 or abs(abs(s) - 0.72) < 0.06) and t < 0.9 then
      c:put(x, y, s < 0 and LEAF[min(6, i + 1)] or LEAF[max(1, i - 1)], ltok) end
  end
end)
-- glossy leathery highlights on the lit half
for _, q in ipairs{ { 14, 43 }, { 15, 43 }, { 33, 37 }, { 47, 37 } } do if lm:has(q[1], q[2]) then c:put(q[1], q[2], GLOSS, ltok) end end
-- cool reflected light on the lower edge
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.12 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale broken tissue on the tear
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] < 0.14 and abs(LS[k]) < 0.85 and not lm:has(x - 1, y) then c:put(x, y, LEAF[5], ltok) end end)

-- sprout: twining stem out of the right seed, curling at the top
local sp = { { 38, 42 }, { 42, 34 }, { 34, 26 }, { 37, 16 } }
local sm, sn, SST, SSS, ssamp = A.tube(sp, function(t) return 1.0 end)
sm:cut(seeds[3].m)
A.shade(c, sm, sn, STEM, { tok = stok, amb = 0.15, wrap = 0.3 })
-- curl at the top (twining tip)
local curl = { { 37, 15 }, { 37, 14 }, { 38, 13 }, { 39, 13 }, { 40, 14 }, { 40, 15 }, { 39, 16 } }
for i, q in ipairs(curl) do c:put(q[1], q[2], (i < 4) and STEM[3] or STEM[2], stok) end

-- leaves on the vine: ovate pointed, arcuate veins
local function vleaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.6 * (1 - 0.35 * t))
  end, { fold = 0.4 })
  m:cut(sm)
  local idx = A.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.24, 0.4, 0.55, 0.7, 0.86 }, amb = 0.12, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if t > 0.08 and t < 0.88 then
      if abs(s) < 0.13 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok)
      elseif abs(abs(s) - 0.55) < 0.09 and t > 0.15 and t < 0.75 then c:put(x, y, s < 0 and LEAF[min(6, (idx[k] or 3) + 1)] or LEAF[max(1, (idx[k] or 3) - 1)], ltok) end
    end end)
  return m
end
vleaf(39, 28, 46, 22, 54, 23, 3.6)
vleaf(36, 20, 31, 17, 26, 18, 2.3)
-- glossy glint on the big vine leaf
c:put(45, 22, GLOSS, ltok)

-- quirk: closed crimson bell bud hanging on a thin pedicel from the node at (35,24)
local btok = { r = { name = "bud" } }
for _, q in ipairs{ { 34, 23 }, { 33, 22 }, { 32, 22 }, { 31, 23 } } do c:put(q[1], q[2], STEM[2], stok) end
local bud = {
  ".ab.",
  "abcd",
  "abcd",
  "bbcd",
  ".cd.",
}
local bp = { a = BUD[5], b = BUD[4], c = BUD[3], d = BUD[2] }
for yy, row in ipairs(bud) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if bp[ch] then c:put(29 + xx, 23 + yy, bp[ch], btok) end end end
c:put(31, 24, STEM[1], btok) c:put(32, 24, STEM[3], btok)   -- green calyx cap

-- seeds last: round, glossy, hilum scar, AO between neighbours
for i, s in ipairs(seeds) do
  local sb = {}
  for j = i + 1, #seeds do X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, s.m, s.n, SEED, { tok = tok, bias = sb, amb = 0.08, wrap = 0.25, cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 } })
  local gx, gy = A.specAt(s.m, s.n, 30)
  if gx then c:put(gx, gy, SEED[6], tok) c:put(gx + 1, gy, SEED[6], tok) end
  -- hilum: small dark scar on the lower-right
  local hx, hy = floor(s[1] + 1.5 + .5), floor(s[2] + 1 + .5)
  if s.m:has(hx, hy) then c:put(hx, hy, SEED[1], tok) if s.m:has(hx - 1, hy) then c:put(hx - 1, hy, SEED[2], tok) end end
end
c:sparkle(14, 39)

A.save(c, NAME)
