-- mandarin (final, Opus single pass). A squat (oblate) mandarin: glossy dimpled peel (oil-gland pits, waxy bloom
-- on the lit shoulder, cool reflected light low right), a sunken stem well with a 5-point calyx and a short twig
-- carrying one slim pointed leaf (midrib + veins). A peeled segment leans on the fruit lower left: juice-vesicle
-- streaks, a white pith thread, AO + contact shadow where it touches the peel.
-- quirk: a caterpillar has nibbled a round notch out of the leaf margin.
local NAME = "mandarin"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = A.new(NAME)

local PEEL = { "#7a2a2c", "#b2402a", "#de5f1e", "#f5851f", "#ffad3a", "#ffd677" }
local BLOOM, COOL = "#ffe9a8", "#b8607a"
local SEG = { "#a33a22", "#d45a22", "#ef7f2c", "#ffa344", "#ffc670", "#ffe6a8" }
local PITH = "#fff0cf"
local LEAF = { "#163d33", "#1f5a40", "#2d7a48", "#47994f", "#6cb957", "#a2d672" }
local STEM = { "#3c4a2c", "#5e7038", "#8a9c4a", "#b9c876" }

-- fruit: oblate, slightly flattened top
local FX, FY, FRX, FRY = 33, 34, 16, 13
local fm = HP.mask()
for y = FY - FRY - 1, FY + FRY + 1 do for x = FX - FRX - 1, FX + FRX + 1 do
  local u, v = (x - FX) / (FRX + 0.5), (y - FY) / (FRY + 0.5)
  if u * u + v * v <= 1 and not (v < -0.93 and abs(u) < 0.22) then fm:set(x, y) end
end end
local fn = A.body(fm, FX - 0.5, FY + 1, 15.5, 6, 0.65)

-- segment leaning lower left (crescent)
local GX, GY = 16, 46
local gm, gn = A.oval(GX, GY, 8, 4.8, -0.5, 0.9)
local inner = A.oval(GX + 1.2, GY - 4.4, 7.5, 2.4, -0.5, 1)
gm:cut(inner)

-- leaf + twig from the stem well, up and to the right
local stok = { r = { name = "twig" } }
local tw = { { 33, 22 }, { 34, 19 }, { 35, 17 }, { 37, 15 } }
local twm = A.stem(c, tw, function(t) return 1.2 end, STEM, { tok = stok })
local ltok = { r = { name = "leaf" } }
local notch = HP.mask()
for y = 4, 16 do for x = 40, 56 do if (x - 48) ^ 2 + (y - 4.2) ^ 2 <= 5.2 then notch:set(x, y) end end end
local lm, LT, LS, lidx = A.leaf(c, 36, 16, 45, 6, 57, 9, 4.6, LEAF, { tok = ltok, cut = notch, vs = 3, fold = 0.5 })
-- nibble edge: pale chewed rim
notch:grow(1):each(function(x, y) if lm:has(x, y) and not notch:has(x, y) then c:put(x, y, LEAF[5], ltok) end end)

-- peel tone with AO from the segment and the twig
local fvis = fm:copy():cut(gm)
local bias = {}
X.ao(bias, fvis, gm, 2, -1)
A.cast(bias, fvis, gm, 1, 1, -1)
local ptok = { r = { name = "peel" } }
local idx, v = A.shade(c, fvis, fn, PEEL, { amb = 0.1, wrap = 0.28, bias = bias, tok = ptok, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 } })
-- dimples: oil-gland pits (tone down) with a lit lip just above-left (tone up) on lit areas
fvis:each(function(x, y) local k = K(x, y) local i = idx[k]
  if bias[k] then return end
  local h = X.hash(x, y, 13)
  if h < 0.07 and i >= 2 then c:put(x, y, PEEL[i - 1], ptok)
    if i >= 4 and fvis:has(x - 1, y - 1) and not bias[K(x - 1, y - 1)] then c:put(x - 1, y - 1, PEEL[min(6, (idx[K(x - 1, y - 1)] or i) + 1)], ptok) end
  end
end)
-- cool reflected light low right
local r = X.rim(fn)
fvis:each(function(x, y) local k = K(x, y)
  if (r[k] or 0) > 0.72 and idx[k] <= 2 and not bias[k] and not fvis:edge():has(x, y) then c:put(x, y, COOL, ptok) end end)
-- waxy bloom: a few pale pixels on the lit shoulder, then the main glint
for _, q in ipairs{ { 23, 26 }, { 25, 24 }, { 22, 29 }, { 27, 23 }, { 21, 31 } } do c:put(q[1], q[2], BLOOM, ptok) end
c:put(24, 27, A.CREAM, ptok) c:put(25, 27, PEEL[6], ptok) c:put(24, 28, PEEL[6], ptok)
-- stem well: dark ring + 5-point calyx
local ctok = { r = { name = "calyx" } }
for _, q in ipairs{ { 31, 22, 1 }, { 32, 22, 2 }, { 34, 22, 2 }, { 35, 22, 1 }, { 32, 23, 1 }, { 33, 23, 1 }, { 34, 23, 1 } } do c:put(q[1], q[2], PEEL[q[3]], ptok) end
for _, q in ipairs{ { 31, 21, 3 }, { 35, 21, 2 }, { 32, 21, 4 }, { 33, 21, 3 }, { 34, 21, 2 }, { 33, 20, 3 } } do c:put(q[1], q[2], STEM[q[3]], ctok) end

-- segment: membrane-lit, vesicle streaks along its length, pith thread on the back
local gtok = { r = { name = "segment" } }
local gb = {}
local gidx = A.shade(c, gm, gn, SEG, { amb = 0.2, wrap = 0.4, tok = gtok, bias = gb, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
local gca, gsa = cos(-0.5), sin(-0.5)
gm:each(function(x, y) local k = K(x, y)
  local u = (x - GX) * gca + (y - GY) * gsa
  local w = -(x - GX) * gsa + (y - GY) * gca
  if (floor(w * 1.3 + u * 0.25) % 2 == 0) and X.hash(x, y, 4) < 0.45 then c:put(x, y, SEG[max(1, (gidx[k] or 3) - 1)], gtok) end
  if abs(w - 2.6 + u * u * 0.04) < 0.5 and abs(u) < 5 then c:put(x, y, PITH, gtok) end
end)
do local sx, sy = A.specAt(gm, gn, 20) c:put(sx, sy, A.CREAM, gtok) if gm:has(sx + 1, sy) then c:put(sx + 1, sy, SEG[6], gtok) end end

A.save(c, NAME)
