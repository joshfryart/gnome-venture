-- giant-allium-seed (final pass, Opus single pass). Four glossy, angular allium seeds (ink-violet with a purple sheen
-- and a cream glint) on a torn scrap of blue-green allium strap leaf (channelled V-fold, parallel veins, waxy bloom
-- speckles on the lit half, cool reflected edge, AO + contact shadow under each seed). One seed has germinated: a thin
-- tubular cotyledon bent into the allium "flag" hook and a first flat strap leaf.
-- quirk: the hooked cotyledon still wears its black seed coat on the tip like a little hat.
local NAME = "giant-allium-seed"
local B = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_0.lua")
local HP, X, K = B.HP, B.X, B.K
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local c = B.new(NAME)
local LEAF = { "#173a40", "#1f5452", "#2d6f66", "#4a8f80", "#74b3a0", "#a8d6c0" }
local BLOOM, COOL = "#cfe8e0", "#3f6a86"
local SEED = { "#1d1320", "#2c1f35", "#41304f", "#5c456f", "#866c9e", "#c3afd8" }
local STEM = { "#2f6a5a", "#4f9478", "#86bf96", "#c4e4c0" }
local LCUTS = { 0.12, 0.27, 0.43, 0.6, 0.78 }

-- strap leaf scrap, torn at both ends
local lm, ln, LT, LS, len = B.blade(6, 53, 30, 51, 58, 39, function(t)
  if t > 0.99 then return -1 end
  return 5.6
end, { fold = 0.5 })
B.tear(lm, 10, 52, -0.99, 0.1, 1.5, 7)
B.tear(lm, 55, 41, 0.92, -0.4, 1.5, 9)

-- seeds: angular polys (cx,cy + offsets)
local seeds = {
  { 15, 50, { { -3, 0 }, { -1, -2 }, { 2, -2 }, { 3, 1 }, { 0, 2 } } },
  { 23, 49, { { -2, -2 }, { 2, -2 }, { 3, 0 }, { 1, 2 }, { -2, 1 } } },
  { 30, 47, { { -3, 1 }, { -1, -2 }, { 3, -1 }, { 1, 2 } } },
  { 39, 45, { { -3, 0 }, { 0, -2 }, { 3, -1 }, { 2, 2 }, { -1, 2 } } }, -- germinating
}
for _, s in ipairs(seeds) do
  local p = {}
  for _, o in ipairs(s[3]) do p[#p + 1] = { s[1] + o[1], s[2] + o[2] } end
  s.m = c:poly(p)
end

-- sprout: hooked cotyledon (flag) and first strap leaf
local cp = { { 39, 44 }, { 35, 28 }, { 39, 14 }, { 47, 21 } }
local cm, cn, CT, CS = B.tube(cp, function(t) return 1.0 end)
local tp = { { 41, 44 }, { 45, 35 }, { 48, 27 }, { 55, 20 } }
local tm, tn, TT, TS = B.tube(tp, function(t) return t > 0.97 and 0.3 or 1.9 * (1 - t) ^ 0.35 + 0.2 end)

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) B.cast(bias, lm, s.m, 1, 2, -1) end
B.cast(bias, lm, tm, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
B.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = LCUTS, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  -- channel crease and parallel veins
  if abs(s) < 0.1 then c:put(x, y, LEAF[2], ltok) return end
  if abs(abs(s) - 0.5) < 0.09 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) return end
  -- waxy bloom: pale speckles on the lit half
  if s < -0.2 and X.hash(x, y, 13) > 0.84 then c:put(x, y, BLOOM, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.08 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end
  if (LT[k] < 0.09 or LT[k] > 0.91) and not bias[k] then c:put(x, y, LEAF[5], ltok) end  -- torn tissue
end)

-- first leaf (flat strap, behind the cotyledon)
local stok = { r = { name = "sprout" } }
tm:cut(seeds[4].m)
B.shade(c, tm, tn, LEAF, { amb = 0.15, wrap = 0.3, tok = stok, cuts = LCUTS })
tm:each(function(x, y) local k = K(x, y) if abs(TS[k]) < 0.18 and TT[k] > 0.1 and TT[k] < 0.85 then c:put(x, y, LEAF[2], stok) end end)
-- cotyledon (thin tube), with AO where it crosses the leaf
cm:cut(seeds[4].m)
local cbias = {}
B.shade(c, cm, cn, STEM, { amb = 0.15, wrap = 0.3, tok = stok, bias = cbias })
X.ao({}, tm, cm, 1, -1)
tm:each(function(x, y) if not cm:has(x, y) and cm:has(x - 1, y) and cm:has(x - 1, y - 1) then c:put(x, y, LEAF[1], stok) end end)
-- knee highlight on the hook
c:put(37, 20, STEM[4], stok) c:put(37, 21, STEM[4], stok)

-- quirk: seed-coat hat on the cotyledon tip
local hat = c:poly{ { 45, 21 }, { 48, 20 }, { 50, 23 }, { 48, 26 }, { 45, 24 } }
seeds[#seeds + 1] = { 47, 23, {}, m = hat, hat = true }

-- seeds last: faceted gloss
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local n = X.pillow(s.m, 1.6)
  local sb = {}
  if not s.hat then X.ao(sb, s.m, cm, 1, -1) end
  local idx = B.shade(c, s.m, n, SEED, { amb = 0.1, wrap = 0.2, tok = tok, bias = sb, cuts = { 0.2, 0.38, 0.56, 0.72, 0.88 } })
  -- facet ridge: one lit diagonal from upper-left vertex toward centre
  local x0, y0 = s[1] - 1, s[2] - 1
  if s.m:has(x0, y0) then c:put(x0, y0, SEED[5], tok) end
  if s.m:has(x0 + 1, y0) then c:put(x0 + 1, y0, SEED[4], tok) end
  -- violet sheen on the shade side
  if s.m:has(s[1] + 1, s[2] + 1) then c:put(s[1] + 1, s[2] + 1, SEED[3], tok) end
  -- glint
  if s.m:has(x0, y0 - 1) then c:put(x0, y0 - 1, SEED[6], tok) else c:put(x0, y0, SEED[6], tok) end
end

B.save(c, NAME)
