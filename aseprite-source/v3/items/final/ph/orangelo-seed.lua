-- orangelo-seed (final, Opus aC31_2 single pass). A grapefruit-type leaf torn lengthwise down its midrib (only the lit
-- half left, ragged fibrous tear along the vein line) lies on the diagonal. Two plump warm-cream orangelo pips rest on it
-- (wrinkled coat, AO + contact shadow on the leaf); the third pip at the tip has germinated.
-- Leaf shape cue: the sprout leaves have the big heart-shaped winged petiole of grapefruit/orangelo.
-- quirk: citrus seeds are polyembryonic, so the sprouting pip pushes up TWIN seedlings, one tall and one short.
local NAME = "orangelo-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)

local P = { { 17, 47, 4.8, 3.1, -0.55 }, { 26, 42, 4.8, 3.1, -0.75 } }
local P3 = { 37, 41, 4.4, 2.9, 2.8 }
local pm = {}
for i, s in ipairs(P) do pm[i] = A.pip(A.new("tmp"), s[1], s[2], s[3], s[4], s[5], A.SEEDY) end
pm[3] = A.pip(A.new("tmp"), P3[1], P3[2], P3[3], P3[4], P3[5], A.SEEDY)

-- half leaf: blade along the diagonal; keep the upper-left (lit) half plus a ragged strip past the midrib
local tear = function(t, s, x, y)
  local band = floor(t * 22)
  return s > -0.12 + X.hash(band, 1, 11) * 0.42
end
local LA = { 9, 56, 22, 42, 49, 38 }
local probe = A.leaf(A.new("tmp"), LA[1], LA[2], LA[3], LA[4], LA[5], LA[6], 11.5, { tear = tear, spec = false })
local bias = {}
for i = 1, 3 do X.ao(bias, probe, pm[i], 1, -1) A.cast(bias, probe, pm[i], 1, 2, -1) end
local lm, LT, LS = A.leaf(c, LA[1], LA[2], LA[3], LA[4], LA[5], LA[6], 11.5,
  { bias = bias, tear = tear, per = 5.6, sweep = 4.2, cuts = { 0.45, 0.6, 0.72, 0.84, 0.94 } })
-- torn edge: pale fibres + exposed midrib stub where the half ripped away
lm:edge():each(function(x, y) local k = K(x, y)
  if LS[k] > 0.0 and LT[k] > 0.04 and LT[k] < 0.95 and not bias[k] then c:put(x, y, (X.hash(x, y, 3) < 0.5) and "#c6e398" or "#a9d878") end end)
for _, q in ipairs{ { 8, 57, 3 }, { 7, 58, 2 }, { 9, 57, 4 } } do c:put(q[1], q[2], A.LEAF[q[3]]) end

-- twin seedlings from pip 3
local stok = { r = { name = "stem" } }
local s1 = { { 38, 39 }, { 37, 31 }, { 34, 24 }, { 35, 16 } }
local m1, n1 = A.tube(s1, function(t) return 1.1 - 0.25 * t end)
A.shade(c, m1, n1, A.STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local s2 = { { 40, 39 }, { 42, 35 }, { 45, 32 }, { 47, 29 } }
local m2, n2 = A.tube(s2, function(t) return 0.95 - 0.2 * t end)
A.shade(c, m2, n2, A.STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "stem2" } } })
-- tall twin: two winged leaves + tip bud
A.leaf(c, 35, 23, 27, 20, 17, 13, 4.6, { wing = 0.3, per = 3.4, name = "t1" })
A.leaf(c, 35, 17, 42, 11, 51, 12, 4.4, { wing = 0.3, per = 3.4, name = "t2" })
A.leaf(c, 35, 16, 33, 11, 35, 7, 1.9, { veins = false, spec = false, name = "bud" })
-- short twin: one small winged leaf
A.leaf(c, 47, 29, 52, 27, 56, 22, 3.0, { wing = 0.3, veins = false, name = "t3" })
for _, q in ipairs{ { 34, 23 }, { 36, 17 }, { 47, 30 } } do c:put(q[1], q[2], A.STEM[1]) end
local sm = m1:copy():add(m2)

-- pips
for i, s in ipairs{ P[1], P[2], P3 } do
  local b = {}
  if i < 3 then X.ao(b, pm[i], pm[i + 1], 1, -1) end
  if i == 3 then X.ao(b, pm[3], sm, 1, -1) end
  local cm = HP.mask() for j = i + 1, 3 do cm:add(pm[j]) end
  A.pip(c, s[1], s[2], s[3], s[4], s[5], A.SEEDY, { bias = b, cutm = cm, R = 2.6, name = "pip" .. i })
end
-- split seed coat where the twins emerge, radicle tip
c:put(38, 40, A.SEEDY[1]) c:put(39, 40, A.SEEDY[2]) c:put(40, 40, A.SEEDY[1])
c:put(15, 45, "#fffbe8") c:put(16, 44, "#fffbe8")

A.save(c, NAME)
