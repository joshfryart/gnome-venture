-- peach-seed (aC32_3 final, Opus single pass). A whole peach stone (pointed oval, keel ridge round the rim, deep
-- sinuous pits and furrows, 6-tone red-brown per-pixel light) lying on a torn scrap of peach leaf (long lanceolate,
-- finely toothed margin, midrib + swept veins, ragged torn base, V-fold light, cool edge, AO + contact shadow under the
-- stones). Behind it a split half-stone has germinated: pale radicle down into the leaf, a thick stem, two fleshy
-- cotyledons and a first true leaf that is a tiny slim, toothed peach leaf.
-- History: Sonnet draft replaced.
-- quirk: a last scrap of orange peach flesh still clings to the tip of the whole stone.
local NAME = "peach-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_3.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local VEIN, COOL = "#c2e48c", "#3a6c72"
local PIT   = { "#3a1c22", "#5c2a28", "#84402e", "#a8603c", "#c88552", "#e8b07a" }
local KERN  = { "#7a5a3c", "#b48c5c", "#dcbc88", "#f4e2b4" }
local STEM  = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local ROOT  = { "#8a7058", "#bca487", "#e2d2b4", "#fbf0d6" }
local FLESH = { "#c2363e", "#f07a34", "#ffa94a", "#ffd27a" }

-- whole stone and split half
local s1m, s1n = G.oval(23, 45, 8.6, 5.6, -0.22, 0.75)
local s2m, s2n = G.oval(41, 42, 6.2, 4.6, 0.35, 0.6)

-- leaf scrap: long diagonal blade, torn ragged at the lower-left
local lm, ln, LT, LS, len = G.blade(6, 55, 30, 52, 58, 41, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 8.0 * sin(pi * min(1, t * 0.75 + 0.25)) ^ 0.8)
end, { fold = 0.4 })
-- tear: jagged cut across the base
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local jag = 0.08 + 0.05 * sin(LS[k] * 9) + 0.03 * sin(LS[k] * 23)
  if LT[k] < jag then cut[#cut + 1] = k end
  -- serrated margin: tiny notches along the edge
  if abs(LS[k]) > 0.86 and floor(LT[k] * len) % 3 == 0 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, m in ipairs{ s1m, s2m } do X.ao(bias, lm, m, 1, -1) G.cast(bias, lm, m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.1 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local d = (t * len - abs(s) * 6.0) % 4.2
  if d < 0.8 and abs(s) > 0.2 and abs(s) < 0.75 and t > 0.12 and t < 0.9 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.15 then c:put(x, y, COOL, ltok) end end)
-- torn fibres: pale broken ends on the tear
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] < 0.2 and abs(LS[k]) < 0.7 and X.hash(x, y, 2) > 0.5 then c:put(x, y, LEAF[6], ltok) end end)

-- sprout (behind the half stone): radicle, stem, cotyledons, true leaf
local rm = A.stem(c, { { 44, 45 }, { 47, 48 }, { 48, 51 }, { 51, 53 } }, function(t) return 1.3 * (1 - t) + 0.35 end, ROOT, { cut = s2m, cuts = { 0.3, 0.55, 0.8 } })
G.cast({}, lm, rm, 1, 1, -1)
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not s2m:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
local stokm = A.stem(c, { { 40, 39 }, { 39, 33 }, { 41, 27 }, { 40, 21 } }, function(t) return 1.25 - 0.25 * t end, STEM, { cut = s2m, cuts = { 0.3, 0.55, 0.8 } })
local function coty(ax, ay, cx, cy, bx, by)
  local m = A.leaf(c, ax, ay, cx, cy, bx, by, 2.6, LEAF, { vs = 99, fold = 0.25, pw = 0.5, cut = stokm })
  return m
end
local cl = coty(39, 28, 33, 26, 28, 27)
local cr = coty(41, 28, 47, 26, 51, 27)
-- true leaf: slim lanceolate peach leaf in miniature, toothed edge
local tm, TT, TS = A.leaf(c, 40, 22, 43, 15, 49, 9, 2.4, LEAF, { vs = 2.6, fold = 0.5, pw = 0.9, cut = stokm })
tm:edge():each(function(x, y) local k = K(x, y)
  if TT[k] and TT[k] > 0.2 and TT[k] < 0.88 and (x + y) % 3 == 0 then c:px(x, y, TS[k] < 0 and LEAF[6] or LEAF[2]) end end)
local tm2 = A.leaf(c, 40, 22, 36, 17, 33, 12, 1.8, LEAF, { vs = 2.6, fold = 0.5, pw = 0.9, cut = stokm:copy():add(tm) })
-- AO where cotyledons meet the stem
for _, p in ipairs{ {39, 29}, {41, 29}, {40, 23} } do c:px(p[1], p[2], STEM[1]) end

-- half stone: rough outer shell rim (upper) and smooth hollow with a pale kernel (open face toward viewer)
do
  local tok = { r = { name = "half" } }
  local sb = {}
  X.ao(sb, s2m, stokm, 1, -1)
  local idx = A.shade(c, s2m, s2n, PIT, { amb = 0.08, wrap = 0.25, bias = sb, tok = tok })
  -- hollow: inner oval, darker cup with a pale kernel sliver
  local hol = HP.mask()
  s2m:each(function(x, y) local dx, dy = x - 41.6, y - 42.6
    local u, v = (dx * cos(0.35) + dy * sin(0.35)) / 4.6, (-dx * sin(0.35) + dy * cos(0.35)) / 3.0
    if u*u + v*v <= 1 then hol:set(x, y) end end)
  hol:each(function(x, y) c:put(x, y, (y < 42) and PIT[2] or PIT[3], tok) end)
  local ker = HP.mask()
  hol:each(function(x, y) local dx, dy = x - 42.2, y - 43.2
    local u, v = (dx * cos(0.35) + dy * sin(0.35)) / 3.0, (-dx * sin(0.35) + dy * cos(0.35)) / 1.7
    if u*u + v*v <= 1 then ker:set(x, y) end end)
  local kidx = A.shade(c, ker, X.pillow(ker, 1.5), KERN, { amb = 0.2, cuts = { 0.3, 0.55, 0.8 }, tok = tok })
  c:px(41, 42, KERN[4])
  -- shell rim texture
  s2m:edge():each(function(x, y) if X.hash(x, y, 31) > 0.6 and not hol:has(x, y) then A.step(c, idx, PIT, x, y, -1, tok) end end)
end

-- whole stone: wrinkled furrows, keel ridge, tip
do
  local tok = { r = { name = "stone" } }
  local sb = {}
  local ca, sa = cos(-0.22), sin(-0.22)
  s1m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - 23, y - 45
    local u, v = (dx * ca + dy * sa) / 9, (-dx * sa + dy * ca) / 6
    -- sinuous furrows running round the stone
    local f = sin(u * 9.5 + sin(v * 7 + u * 3) * 1.6) + 0.6 * sin(v * 11 - u * 4)
    if f > 1.05 then sb[k] = -2 elseif f > 0.75 then sb[k] = -1 elseif f < -1.2 then sb[k] = 1 end
    -- keel ridge near the upper rim
    if v < -0.55 and v > -0.78 then sb[k] = 1 end
  end)
  local idx = A.shade(c, s1m, s1n, PIT, { amb = 0.08, wrap = 0.25, bias = sb, tok = tok })
  -- pits: a few deep holes
  for _, p in ipairs{ {19, 44}, {25, 47}, {28, 43}, {22, 49}, {17, 47} } do if s1m:has(p[1], p[2]) then c:px(p[1], p[2], PIT[1]) end end
  -- glint on the keel
  c:px(18, 40, PIT[6]) c:px(19, 40, PIT[6]) c:px(17, 41, "#fff0d8")
  -- quirk: clinging peach flesh on the right tip
  local fl = HP.mask()
  for _, p in ipairs{ {29, 43}, {30, 43}, {31, 43}, {30, 44}, {31, 44}, {32, 44}, {31, 45}, {32, 45}, {30, 42} } do fl:set(p[1], p[2]) end
  fl:each(function(x, y) c:put(x, y, FLESH[3], tok) end)
  c:px(30, 42, FLESH[4]) c:px(31, 43, FLESH[4]) c:px(32, 45, FLESH[1]) c:px(31, 45, FLESH[2]) c:px(32, 44, FLESH[2])
end
A.save(c, NAME)
