-- gerbera-seed (final pass, Opus single pass). Two slim ribbed gerbera achenes, each with a cream pappus tuft, lying on a
-- torn scrap of gerbera leaf (shallow rounded lobes, pale midrib + a vein into each lobe, V-fold light, cool reflected
-- edge, AO + contact shadow under every part). The third seed has germinated: pale stem, two round cotyledons and a
-- first true leaf with the gerbera's wavy-lobed spoon shape.
-- quirk: a single pink ray petal from the mother flower has stuck to the leaf.
local NAME = "gerbera-seed"
local B = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_0.lua")
local HP, X, K = B.HP, B.X, B.K
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local c = B.new(NAME)
local LEAF = { "#163a33", "#1f5540", "#2b7148", "#3f914e", "#62b05a", "#97cf70" }
local VEIN, COOL = "#c0e490", "#3b6b74"
local SEED = { "#2e1d22", "#4a2e2a", "#6c4733", "#906446", "#b48a62", "#d8b78a" }
local PAP = { "#a8977e", "#d7cbb0", "#fff4d6" }
local STEM = { "#4a8452", "#83b76a", "#b6db90", "#e0f2ba" }
local PET = { "#7d2c5e", "#c94f6f", "#f07a86", "#ffb0a8" }
local LCUTS = { 0.12, 0.27, 0.43, 0.6, 0.78 }

-- leaf scrap: lobed oblong, torn across at the left end
local PER = 6.2
local lm, ln, LT, LS, len = B.blade(6, 51, 30, 56, 58, 45, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 7.4 * sin(pi * min(1, t * 0.7 + 0.3)) ^ 0.6)
end, { fold = 0.36 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local ph = t * len / PER + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  local lim = 0.98 - (1 - f) ^ 2.2 * 0.38
  if t > 0.12 and t < 0.95 and abs(s) > lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
B.tear(lm, 11, 51, -0.97, -0.25, 1.6, 3)

-- seeds: straight spindles (A -> B), pappus at B
local seeds = {
  { 14, 51, 25, 49 },
  { 26, 56, 37, 54 },
  { 41, 50, 47, 45 },  -- germinating
}
for _, s in ipairs(seeds) do
  local p = { { s[1], s[2] }, { s[1] + (s[3] - s[1]) / 3, s[2] + (s[4] - s[2]) / 3 }, { s[1] + 2 * (s[3] - s[1]) / 3, s[2] + 2 * (s[4] - s[2]) / 3 }, { s[3], s[4] } }
  s.p = p
  s.m, s.n, s.T, s.S = B.tube(p, function(t) return 1.75 * sin(pi * (0.1 + t * 0.8)) ^ 0.7 end)
end
-- sprout stem
local sp = { { 46, 45 }, { 47, 39 }, { 43, 33 }, { 44, 27 } }
local sm, sn = B.tube(sp, function(t) return 1.05 end)

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) B.cast(bias, lm, s.m, 1, 2, -1) end
-- petal quirk mask (drawn later) also shadows the leaf
local pm, pn, PT, PS = B.tube({ { 16, 55 }, { 19, 57 }, { 22, 57 }, { 25, 56 } }, function(t) return t > 0.95 and 0.4 or 1.25 end)
X.ao(bias, lm, pm, 1, -1)
local ltok = { r = { name = "leaf" } }
B.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = LCUTS, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.06 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5.0) / PER + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.16 and abs(s) < 0.72 and t > 0.08 and t < 0.9 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.12 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale broken tissue on the tear
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] < 0.11 and not bias[k] then c:put(x, y, LEAF[5], ltok) end end)

-- petal (quirk): strap with a centre groove and a notched tip
local ptok = { r = { name = "petal" } }
B.shade(c, pm, pn, PET, { amb = 0.15, wrap = 0.3, tok = ptok })
pm:each(function(x, y) local k = K(x, y) if abs(PS[k]) < 0.2 and PT[k] > 0.15 and PT[k] < 0.85 then c:put(x, y, PET[2], ptok) end end)

-- sprout stem
local stok = { r = { name = "stem" } }
sm:cut(seeds[3].m)
B.shade(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, tok = stok })
-- cotyledons: round-oval pads
local function pad(cx, cy, ux, uy, ra, rb)
  local m = B.rell(cx, cy, ux, uy, ra, rb)
  m:cut(sm)
  local n = X.pillow(m, 2.2)
  B.toneN(c, m, n, LEAF, { tok = ltok, cuts = LCUTS, amb = 0.14, wrap = 0.3 })
  return m
end
local cl = pad(38.5, 27, -0.92, 0.38, 5.0, 2.6)
local cr = pad(49.5, 26.5, 0.94, 0.34, 4.6, 2.5)
-- midline crease on cotyledons
for _, q in ipairs{ { 37, 27 }, { 36, 28 }, { 35, 28 }, { 50, 26 }, { 51, 27 }, { 52, 27 } } do c:put(q[1], q[2], LEAF[3], ltok) end
-- true leaf: spoon-shaped wavy-lobed blade rising up-right from the stem top
local tm, tn, TT, TS, tlen = B.blade(44, 26, 45, 19, 51, 12, function(t)
  if t > 0.985 then return -1 end
  if t < 0.3 then return 0.6 end
  local u = (t - 0.3) / 0.7
  local w = 4.0 * sin(pi * min(1, u * 0.75 + 0.18)) ^ 0.7
  return max(0.6, w * (0.85 + 0.15 * cos(t * 26)))
end, { fold = 0.4 })
tm:cut(cl):cut(cr)
local tbias = {}
X.ao(tbias, tm, sm, 1, -1)
B.toneN(c, tm, tn, LEAF, { tok = ltok, cuts = LCUTS, amb = 0.14, wrap = 0.3, bias = tbias })
tm:each(function(x, y) local k = K(x, y)
  if abs(TS[k]) < 0.16 and TT[k] > 0.25 and TT[k] < 0.88 then c:put(x, y, TS[k] <= 0 and VEIN or LEAF[3], ltok) end end)

-- seeds last: ribbed spindle + pappus tuft
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = B.shade(c, s.m, s.n, SEED, { amb = 0.08, wrap = 0.25, tok = tok })
  s.m:each(function(x, y) local k = K(x, y)
    if abs(s.S[k] - 0.15) < 0.22 and s.T[k] > 0.12 and s.T[k] < 0.88 then c:put(x, y, SEED[max(1, (idx[k] or 3) - 2)], tok) end  -- rib groove
  end)
  -- one lit 2x1 mark on the upper ridge
  local bx, by = B.bez(s.p, 0.38)
  c:put(floor(bx + .5), floor(by - 0.6), SEED[6], tok)
  c:put(floor(bx + .5) - 1, floor(by - 0.6), SEED[5], tok)
  if i < 3 then
    -- pappus: fan of bristles from end B
    local dx, dy = s[3] - s[1], s[4] - s[2]
    local l = sqrt(dx * dx + dy * dy) dx, dy = dx / l, dy / l
    for j, a in ipairs{ -0.62, -0.25, 0.12, 0.5 } do
      local ux, uy = B.rot(dx, dy, a)
      local L = (j == 2 or j == 3) and 5.4 or 4.3
      for r = 1, L do
        local x, y = floor(s[3] + ux * r + .5), floor(s[4] + uy * r + .5)
        if not s.m:has(x, y) then c:put(x, y, r < 2 and PAP[1] or (a < 0 and PAP[3] or PAP[2]), tok) end
      end
    end
  else
    -- germinated: split seed coat, root stub into the leaf
    c:put(46, 46, STEM[3], tok)
    for _, q in ipairs{ { 40, 51 }, { 39, 52 }, { 38, 52 } } do c:put(q[1], q[2], q[1] == 40 and STEM[2] or STEM[1], tok) end
  end
end
c:sparkle(31, 47)

B.save(c, NAME)
