-- passionflower-seed (aC32_2 final, Opus single pass). Two flat, ovate passionflower seeds (russet brown, cross-ridged
-- coat with a lit lip on each ridge, a pale hilum point) on a torn scrap of a palmate passionflower leaf: two narrow
-- finger lobes splaying from a ragged base (midrib + veins per lobe, V-fold light, cool reflected edge, AO + contact
-- shadow). The left seed has sprouted: thin stem, two cotyledons and a first true leaf fanned into five fingers (the
-- passionflower leaf shape), plus a long tendril that coils as it climbs.
-- quirk: the tendril tip has already opened a tiny blue passionflower, corona and all.
local NAME = "passionflower-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local full = c:rect(0, 0, 63, 63)
local LEAF = { "#15392f", "#1f5a3c", "#2e7a42", "#4c9a48", "#78bd56", "#b2dc78" }
local SEED = { "#2a1418", "#46201e", "#682f22", "#8c452a", "#b06636", "#d69458" }
local STEM = { "#3c744a", "#68a65a", "#9ccf78", "#d4eeaa" }
local COOL = "#3a6c72"

-- seeds: cx, cy, rx, ry, angle
local SA = { 43, 45, 5.0, 3.3, -0.5 }   -- big lying seed on the right lobe
local SB = { 19, 46, 4.0, 2.7, -1.35 }  -- sprouting seed on the left lobe, tipped on end
local mA = A.oval(SA[1], SA[2], SA[3], SA[4], SA[5], 0.8)
local mB = A.oval(SB[1], SB[2], SB[3], SB[4], SB[5], 0.8)
local onLeaf = mA:copy():add(mB)
local bias = {}
X.ao(bias, full, onLeaf, 1, -1)
A.cast(bias, full, onLeaf, 1, 2, -1)

-- leaf scrap: two finger lobes from a shared base, base torn off below
local ltok = { r = { name = "leaf" } }
local tearM = A.tear(full:copy(), 31, 54, 0.1, 1, 1.5, 9)
local lob = function(w) return function(t) if t > 0.985 then return -1 end return max(0.5, w * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.55) end end
local lmA, TA, SA_ = A.leaf(c, 30, 57, 22, 46, 8, 38, 5.6, LEAF, { cut = tearM, bias = bias, tok = ltok, vs = 3.6, fold = 0.45, wfn = lob(5.6) })
local lmB, TB, SB_ = A.leaf(c, 32, 57, 42, 48, 56, 37, 5.8, LEAF, { cut = tearM, bias = bias, tok = ltok, vs = 3.6, fold = 0.45, wfn = lob(5.8) })
-- dark sinus where the two lobes join
for _, p in ipairs{ { 31, 50 }, { 31, 51 }, { 30, 52 }, { 32, 52 }, { 31, 52 } } do if lmA:has(p[1], p[2]) or lmB:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[1], ltok) end end
-- cool reflected light on the lower-right edges
for _, L in ipairs{ { lmA, TA, SA_ }, { lmB, TB, SB_ } } do
  L[1]:edge():each(function(x, y) local k = K(x, y)
    if not bias[k] and L[3][k] > 0.6 and L[2][k] > 0.2 and L[2][k] < 0.85 then c:put(x, y, COOL, ltok) end end)
end
-- torn base: pale fibres where the leaf ripped
lmA:copy():add(lmB):edge():each(function(x, y) if tearM:has(x, y + 1) then c:put(x, y, (x % 2 == 0) and LEAF[5] or LEAF[4], ltok) end end)

-- sprout stem from seed B
local stok = { r = { name = "stem" } }
A.stem(c, { { 19, 43 }, { 20, 36 }, { 18, 28 }, { 19, 22 } }, function(t) return 1.0 end, STEM, { tok = stok })
-- tendril: leaves the stem at a node, climbs right in a loose wave, coils, ends in the bloom
local ttok = { r = { name = "tendril" } }
local tp = { { 20, 31 }, { 21, 30 }, { 22, 30 }, { 23, 29 }, { 24, 29 }, { 25, 30 }, { 26, 30 }, { 27, 29 }, { 28, 28 } }
for _, p in ipairs(tp) do c:put(p[1], p[2], STEM[3], ttok) end
local sp = A.spiral(31, 26, pi * 0.85, 3.2, -0.12, 22, -1)
for _, p in ipairs(sp) do c:put(p[1], p[2], p[2] > 26 and STEM[2] or STEM[3], ttok) end
for _, p in ipairs{ { 33, 23 }, { 34, 22 }, { 35, 21 }, { 36, 20 }, { 37, 19 }, { 38, 18 } } do c:put(p[1], p[2], STEM[3], ttok) end

-- cotyledons
local ctok = { r = { name = "cotyledon" } }
A.leaf(c, 18, 24, 14, 21, 9, 22, 2.4, LEAF, { tok = ctok, vs = 9, fold = 0.3, pw = 0.55 })
A.leaf(c, 20, 24, 24, 22, 28, 23, 2.2, LEAF, { tok = ctok, vs = 9, fold = 0.3, pw = 0.55 })
-- true leaf: five narrow fingers fanned from one point (palmate)
local hx, hy = 19, 17
for y = hy, 21 do c:put(19, y, STEM[3], stok) c:put(20, y, STEM[1], stok) end
local fing = { { -2.6, 8.2 }, { -2.08, 9.6 }, { -1.5708, 10.6 }, { -1.06, 9.6 }, { -0.54, 8.2 } }
local order = { 1, 5, 2, 4, 3 }
for _, i in ipairs(order) do local f = fing[i]
  local ex, ey = hx + cos(f[1]) * f[2], hy + sin(f[1]) * f[2]
  A.leaf(c, hx, hy, (hx + ex) / 2, (hy + ey) / 2, floor(ex + .5), floor(ey + .5), 1.15, LEAF, { tok = ctok, vs = 9, fold = 0.35, pw = 0.9 })
end
c:put(hx, hy, LEAF[2], ctok) c:put(hx + 1, hy, LEAF[1], ctok)

-- seed A: big lying seed, cross-ridged
local function ridged(S, tok)
  local m, n, idx = A.seed(c, S[1], S[2], S[3], S[4], S[5], SEED, { tok = tok, spec = false })
  local ca, sa = cos(S[5]), sin(S[5])
  local inner = m:shrink(1)
  inner:each(function(x, y)
    local u = ((x - S[1]) * ca + (y - S[2]) * sa)
    local r = floor(u + 20.5) % 3
    if r == 0 then A.step(c, idx, SEED, x, y, -1, tok) elseif r == 1 then A.step(c, idx, SEED, x, y, 1, tok) end
  end)
  -- pale hilum point at one end
  local px, py = floor(S[1] + ca * (S[3] - 0.2) + .5), floor(S[2] + sa * (S[3] - 0.2) + .5)
  c:put(px, py, SEED[6], tok)
  local gx, gy = A.specAt(inner, n, 30)
  if gx then c:put(gx, gy, A.CREAM, tok) end
  return m
end
ridged(SA, { r = { name = "seedA" } })
local tB = { r = { name = "seedB" } }
ridged(SB, tB)
-- split coat where the stem comes out
for _, p in ipairs{ { 19, 42 }, { 19, 41 }, { 20, 42 } } do c:put(p[1], p[2], STEM[2], stok) end

-- quirk: tiny passionflower at the tendril tip
local ftok = { r = { name = "bloom" } }
local PAL = { w = "#f1ecff", s = "#b9addf", p = "#5a3a9e", v = "#8a6fd0", g = "#9ccf78", y = "#ffe38a", d = "#35295f" }
A.map(c, {
  "...w.w...",
  "..wwvww..",
  ".wvpvpvw.",
  "wwpgygpws",
  ".vvygyvs.",
  "swpgdgps.",
  ".svpvps..",
  "..ss.s...",
}, 36, 10, PAL, ftok)

A.save(c, NAME)
