-- sesame-seed (D15 redraw, single pass). Seven tiny flat teardrop sesame seeds (cream, two black) on a torn scrap of
-- sesame leaf: a long lance blade curling up to the right, ragged fibrous tear at the left end, midrib + angled veins,
-- V-fold light, cool bounce edge, contact shadow under every seed. One seed has sprouted: a pale stem, two fat oval seed
-- leaves, then a pair of toothed lance true-leaves that show the sesame leaf shape. Cracked coat halves cradle the stem foot.
-- quirk: the sprout is still wearing its seed coat like a tiny hat on the tip of one seed leaf.
local NAME = "sesame-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local FRESH = A.R.fresh
local VEIN, COOL, FIB = "#c2e48c", "#3a6c72", "#d6e6a2"
local CREAM = { "#7a6046", "#a88a62", "#cfb584", "#e8d4a2", "#f6e8c0", "#fff6dc" }
local BLK = { "#14101c", "#221c2a", "#342c3e", "#4a4058", "#6a5e78", "#a498b4" }
local STEM = { "#5a7a48", "#86a860", "#b4cf86", "#dcebaa" }
local ltok = { r = { name = "leaf" } }

-- leaf scrap -------------------------------------------------------------------------------------------
local lm, ln, LT, LS, len = A.blade(5, 52, 28, 55, 59, 40, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, 0.3 + 0.7 * t)
  return max(0.5, 6.8 * sin(pi * u ^ 0.9) ^ 0.75)
end, { fold = 0.4 })
local function TH(s) return 0.03 + 0.1 * ((s + 1) / 2) + 0.025 * (floor((s + 1) * 4) % 2) end
lm:each(function(x, y) local k = K(x, y) if LT[k] < TH(LS[k]) then lm.s[k] = nil end end)
local torn = HP.mask()
lm:each(function(x, y) local k = K(x, y) if LT[k] < TH(LS[k]) + 0.04 then torn:set(x, y) end end)

-- seeds: cx, cy, angle, kind
local seeds = {
  { 13, 50.5, -0.3, "c" }, { 19.5, 49.5, 0.35, "b" }, { 26, 50.2, -0.2, "c" }, { 32.5, 48.3, 0.4, "c" },
  { 16.5, 55, 0.3, "c" }, { 23, 55, -0.25, "c" }, { 29.5, 54.3, 0.2, "b" },
}
local allseeds = HP.mask()
for _, s in ipairs(seeds) do
  s.m = A.ell(s[1], s[2], 2.7, 1.7, s[3])
  local tx, ty = floor(s[1] + cos(s[3]) * 3.1 + 0.5), floor(s[2] + sin(s[3]) * 3.1 + 0.5)
  s.tip = { tx, ty }
  s.m:set(tx, ty)
  allseeds:add(s.m)
end

local idx = A.toneN(c, lm, ln, LEAF, { tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
local shade = A.ring(lm, allseeds, 1):add(A.under(lm, allseeds, 1, 2))
A.darken(c, shade, idx, LEAF, ltok)
A.veins(c, lm, LT, LS, len, LEAF, { 0.2, 0.32, 0.44, 0.56, 0.68, 0.8 }, ltok, shade)
lm:edge():each(function(x, y) local k = K(x, y)
  if not shade:has(x, y) and LS[k] > 0.66 and LT[k] > 0.14 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale fibres
torn:each(function(x, y) local k = K(x, y)
  if lm:has(x, y) then c:put(x, y, X.hash(x, y, 2) > 0.4 and FIB or VEIN, ltok) end end)
-- a few fibre threads hanging off the tear
for _, q in ipairs{ { 7, 50 }, { 8, 53 }, { 7, 56 } } do
  if not lm:has(q[1], q[2]) and lm:has(q[1] + 1, q[2]) then c:put(q[1], q[2], FIB, ltok) end
end

-- sprout ------------------------------------------------------------------------------------------------
local stok = { r = { name = "stem" } }
local sp = { { 40.5, 48 }, { 38.5, 41 }, { 42, 30 }, { 40.5, 22.5 } }
local sm, sn = A.tube(sp, function(t) return 1.15 - 0.2 * t end)
-- shadow of the sprout on the leaf
A.darken(c, A.ring(lm, sm, 1):add(A.under(lm, sm, 1, 1)), idx, LEAF, ltok)
A.toneN(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.14, wrap = 0.3 })
-- upper stem
local sp2 = { { 40.5, 22.5 }, { 40, 19 }, { 41, 16 }, { 40.5, 13 } }
local sm2, sn2 = A.tube(sp2, function(t) return 0.95 end)
A.toneN(c, sm2, sn2, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.14, wrap = 0.3 })
-- true leaves (toothed lance) first so cotyledons sit in front
local function lance(a, cc, b, w)
  local m, id, _, T, S, ln2 = A.leafB(c, a[1], a[2], cc[1], cc[2], b[1], b[2], w, { ramp = FRESH, serr = 2.2, tok = ltok })
  A.veins(c, m, T, S, ln2, FRESH, { 0.3, 0.5, 0.7 }, ltok)
  return m
end
lance({ 40, 15 }, { 35, 9.5 }, { 28.5, 11.5 }, 2.4)
lance({ 41, 14.5 }, { 46, 8.5 }, { 53, 10.5 }, 2.6)
-- seed leaves (cotyledons): fat ovals with a crease
local function coty(cx, cy, ang)
  local m = A.ell(cx, cy, 5.2, 2.9, ang)
  A.lit2(c, m, FRESH, 2.6, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
  A.ln(c, cx - cos(ang) * 4.4, cy - sin(ang) * 4.4, cx + cos(ang) * 4, cy + sin(ang) * 4, FRESH[2], m)
  return m
end
local cl = coty(34.5, 22.5, 0.3)
local cr = coty(46.5, 21.5, -0.3)
A.darken(c, A.ring(sm, cl, 1), {}, STEM, stok)
-- cracked coat halves cradling the stem foot
local ck = { r = { name = "coat" } }
for _, h in ipairs{ { 37.2, 48.6, -0.5 }, { 43.8, 48.8, 0.5 } } do
  local m = A.ell(h[1], h[2], 2.7, 1.6, h[3])
  A.lit2(c, m, CREAM, 1.6, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
  A.seam(c, m, sm, CREAM[2])
end
-- radicle threads into the leaf
for _, q in ipairs{ { 40, 50 }, { 39, 51 }, { 41, 51 }, { 38, 52 } } do c:put(q[1], q[2], STEM[3], stok) end
-- quirk: seed coat worn as a hat on the left cotyledon tip
c:put(27, 20, CREAM[4], ck) c:put(28, 20, CREAM[6], ck) c:put(29, 20, CREAM[5], ck)
c:put(27, 21, CREAM[2], ck) c:put(28, 21, CREAM[3], ck) c:put(29, 21, CREAM[2], ck)
c:put(30, 20, CREAM[1], ck)

-- seeds last: flat teardrops with bevel, hilum tip, glint
for _, s in ipairs(seeds) do
  local ramp = s[4] == "b" and BLK or CREAM
  local tok = { r = { name = "seed" } }
  local id2 = A.lit2(c, s.m, ramp, 1.7, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
  c:put(s.tip[1], s.tip[2], s[4] == "b" and BLK[3] or "#9a7048", tok)
  c:put(floor(s[1] - 1), floor(s[2] - 0.6), ramp[6], tok)
end

A.save2(c, NAME)
