-- hydrangea-seed (final, Opus single pass aC12_5). A dried hydrangea seed capsule (small ribbed tan urn with two
-- curled style horns) tipped on its side, spilling a trail of tiny slender brown seeds (winged tips, lit ridge)
-- across a torn piece of broad hydrangea leaf (ovate, sharply serrated margin, deep pinnate veins, crinkled between
-- them, pale torn edge on the right, cool reflected lower edge, AO + contact shadows). One seed at the left has
-- sprouted: pale stem, two small round cotyledons, then a pair of opposite, serrated, veined ovate true leaves,
-- the hydrangea leaf in miniature.
-- quirk: a single blue four-sepal hydrangea floret has drifted onto the leaf, a pink blush at its centre.
local NAME = "hydrangea-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local LEAF = { "#163a36", "#1e5440", "#2a7048", "#3e8e4e", "#62ae58", "#94cc6c" }
local VEIN, COOL, TORN = "#b8de88", "#3a6c72", "#b4d690"
local SEED = { "#3a2220", "#5c3426", "#84502e", "#aa723e", "#cc9a5c", "#ecc890" }
local CAP = { "#4a3024", "#70503a", "#9a7652", "#c09e70", "#dcc090", "#f4e0b4" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local FL = { "#2a4a7a", "#3a86b0", "#5fb0d8", "#9ad4f0", "#d4f0ff" }
local ltok, stok = { r = { name = "leaf" } }, { r = { name = "sprout" } }

-- broad ovate leaf scrap on the diagonal, serrated margin, torn off at the tip end
local lm, ln, LT, LS, len = A.blade(6, 55, 26, 56, 58, 38, function(t)
  if t > 0.985 then return -1 end
  local base = 11 * sin(pi * min(1, t * 0.82 + 0.1)) ^ 0.6
  local saw = (t * 60 / 2.4) % 1
  return max(0.5, base - 0.9 * saw)
end, { fold = 0.3 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  if x > 47 + 3 * X.hash(0, floor(y / 2), 13) + 1.5 * sin(y * 1.1) then cut[#cut + 1] = k end end)
for _, k in ipairs(cut) do lm.s[k] = nil end
-- crinkle between veins
for k, v in pairs(ln) do local w = sin(LT[k] * len / 5.2 * 2 * pi - abs(LS[k]) * 4) * 0.22
  ln[k] = { A.norm(v[1] + w * 0.5, v[2] - w * 0.5, v[3]) } end

-- spilled seeds: slender ovals with winged tips
local seeds = {
  { 30, 46, 0.5 }, { 35, 47, -0.2 }, { 39, 44, 0.9 }, { 27, 51, 0.1 }, { 33, 51, -0.6 }, { 20, 48, 0.3 },
}
local smask = {}
for i, s in ipairs(seeds) do
  local ca, sa = cos(s[3]), sin(s[3])
  local m = HP.mask()
  for y = s[2] - 3, s[2] + 3 do for x = s[1] - 3, s[1] + 3 do
    local u, v = ((x - s[1]) * ca + (y - s[2]) * sa) / 2.6, (-(x - s[1]) * sa + (y - s[2]) * ca) / 1.1
    if u * u + v * v <= 1 then m:set(x, y) end end end
  smask[i] = m
end
-- capsule: tipped ribbed urn, mouth facing lower-left toward the spill
local capm = HP.mask()
for y = 34, 46 do for x = 38, 52 do
  local u, v = (x + 0.5 - 46) / 5.2, (y + 0.5 - 39.5) / 3.6
  if u * u + v * v <= 1 then capm:set(x, y) end end end
local bias = {}
for _, m in ipairs(smask) do X.ao(bias, lm, m, 1, -1) A.cast(bias, lm, m, 1, 1, -1) end
X.ao(bias, lm, capm, 1, -1) A.cast(bias, lm, capm, 1, 2, -1)
local lidx = A.shade(c, lm, ln, LEAF, { tok = ltok, bias = bias, amb = 0.14, wrap = 0.3, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 } })
-- midrib + pinnate veins (deep, sunken: lit vein with a dark groove below)
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s, t = LS[k], LT[k]
  if abs(s) < 0.1 and t > 0.03 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 6.5) / 5.2
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.88 and abs(s) > 0.12 and abs(s) < 0.82 and t > 0.06 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not lm:has(x + 1, y) and x > 44 then c:put(x, y, TORN, ltok)
  elseif LS[k] > 0.62 and not bias[k] then c:put(x, y, COOL, ltok) end end)
-- petiole stub
for _, q in ipairs{ { 6, 55, 4 }, { 5, 56, 3 }, { 4, 56, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- capsule
local ctok = { r = { name = "capsule" } }
local cn = {}
capm:each(function(x, y) local u, v = (x + 0.5 - 46) / 5.8, (y + 0.5 - 39.5) / 4.2
  cn[K(x, y)] = { A.norm(u * 0.8, v, sqrt(max(0.05, 1 - u * u - v * v))) } end)
local cidx = A.shade(c, capm, cn, CAP, { tok = ctok, amb = 0.12, wrap = 0.3 })
capm:each(function(x, y) local k = K(x, y)        -- longitudinal ribs
  if (y == 37 or y == 40 or y == 43) and x > 41 then c:put(x, y, CAP[max(1, (cidx[k] or 3) - 2)], ctok) end
  if (y == 36 or y == 39) and x > 42 and x < 49 and (cidx[k] or 3) >= 4 then c:put(x, y, CAP[6], ctok) end end)
-- open mouth on the left end (dark hollow + lit rim), curled style horns on the right
for _, q in ipairs{ { 41, 38 }, { 41, 39 }, { 41, 40 }, { 41, 41 }, { 42, 39 }, { 42, 40 } } do c:put(q[1], q[2], CAP[1], ctok) end
for _, q in ipairs{ { 41, 37 }, { 40, 38 }, { 40, 39 }, { 40, 40 } } do c:put(q[1], q[2], CAP[5], ctok) end
A.paint(c, { "ab.", "..b", "..b", "cc." }, 51, 34, { a = CAP[5], b = CAP[3], c = CAP[2] }, ctok)
A.paint(c, { ".b", "b.", "bc" }, 52, 40, { b = CAP[3], c = CAP[1] }, ctok)

-- sprout from the left seed
local SX, SY = 20, 47
local sm = A.stem(c, { { SX, SY }, { 19, 40 }, { 21, 33 }, { 20, 24 } }, function(t) return 1.0 end, STEM, { tok = stok })
local function cot(cx, cy)
  local m = A.ball(c, cx, cy, 2.6, 1.6, LEAF, ltok, { cut = sm, amb = 0.16, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
  return m
end
cot(16, 37) cot(24, 36)
local function trueLeaf(ax, ay, bx, by, bend)
  local m, n, T, S, L = A.blade(ax, ay, (ax + bx) / 2 + bend, (ay + by) / 2 - 1, bx, by, function(t)
    if t > 0.985 then return -1 end
    local base = 3.6 * sin(pi * min(1, t * 0.88 + 0.08)) ^ 0.65
    local saw = (t * 14 / 1.8) % 1
    return max(0.4, base - 0.6 * saw * min(1, t * 5))
  end, { fold = 0.42 })
  m:cut(sm)
  local idx = A.shade(c, m, n, LEAF, { tok = ltok, amb = 0.14, wrap = 0.3, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.15 and T[k] < 0.88 then c:put(x, y, S[k] <= 0 and VEIN or LEAF[3], ltok) return end
    local ph = (T[k] * L - abs(S[k]) * 2.4) / 3.0
    local f = abs((ph - floor(ph)) - 0.5) * 2
    if f > 0.86 and abs(S[k]) > 0.25 and abs(S[k]) < 0.75 and T[k] < 0.82 then c:put(x, y, LEAF[max(1, min(6, (idx[k] or 3) + (S[k] < 0 and 1 or -1)))], ltok) end
  end)
  return m
end
trueLeaf(19, 26, 8, 16, -1)
trueLeaf(21, 26, 32, 15, 1)
c:put(20, 23, STEM[3], stok) c:put(20, 22, LEAF[5], ltok) c:put(21, 22, LEAF[4], ltok) c:put(20, 21, LEAF[5], ltok)

-- seeds last
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[3]), sin(s[3])
  smask[i]:each(function(x, y)
    local u = ((x - s[1]) * ca + (y - s[2]) * sa) / 2.6
    local v = (-(x - s[1]) * sa + (y - s[2]) * ca) / 1.1
    local lit = -(u * (ca - sa) * 0.3 + v * 0.9)
    local ii = lit > 0.35 and 5 or (lit > -0.2 and 4 or 2)
    if abs(u) > 0.7 then ii = 3 end             -- papery winged tips
    if lit > 0.6 and abs(u) < 0.4 then ii = 6 end
    c:put(x, y, SEED[ii], tok)
  end)
end
c:put(20, 46, STEM[2], stok)

-- quirk: drifted blue floret (four sepals, pink-blush eye)
local ftok = { r = { name = "floret" } }
A.paint(c, {
  "..ab...",
  ".abbc..",
  "bbbdccc",
  "abdpdcc",
  ".bcdcd.",
  "..cdd..",
  "...d...",
}, 30, 52, { a = FL[5], b = FL[4], c = FL[3], d = FL[2], p = "#f5809f" }, ftok)
A.save(c, NAME)
