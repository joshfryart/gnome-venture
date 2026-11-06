-- heilala-seed (final, Opus single pass). Two big glossy mahogany heilala seeds (smooth ovoids, pale hilum stripe,
-- bright specular, cool reflected light) on a torn scrap of a thick, leathery, glossy heilala leaf laid on the diagonal
-- (midrib, fine looping veins, ragged torn base, waxy sheen streak, AO + contact shadows). The upper seed has split
-- and sent up a sturdy rosy stem with a pair of opposite glossy elliptic leaves and a red tip bud; a pale root curls out.
-- quirk: one round crimson heilala flower bud has dropped onto the leaf.
local NAME = "heilala-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min = math.floor, math.abs, math.sin, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#0f2e2c", "#17463a", "#22603f", "#327d45", "#4f9c4e", "#86c464" }
local VEIN, COOL, TORN, SHEEN = "#a8d88a", "#35707a", "#cfe6a0", "#c8f0a8"
local SEED = { "#2a1214", "#4a1e1a", "#6e2e20", "#934226", "#b8602e", "#dc8a48" }
local HIL = { "#a88a6a", "#d8c09a" }
local STEM = { "#7a3a40", "#b05a58", "#d88a7c", "#f2b8a0" }
local SPR = { "#14382e", "#1e5238", "#2c6e40", "#3f8c48", "#62ae58", "#98d074" }
local RED = { "#4e1024", "#7e1a2c", "#b32a32", "#e0443a", "#ff7a5a", "#ffb48a" }
local ROOT = { "#b8a488", "#e6d8bc" }

-- leaf scrap: wide, thick, on the diagonal; torn at the base
local lm, ln, LT, LS, len = A.blade(8, 55, 29, 45, 57, 31, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 8.6 * sin(pi * min(1, t * 0.86 + 0.1)) ^ 0.6)
end, { fold = 0.28 })
local torn = A.tear(lm, LT, LS, 0.13, 0.05, 23, 0.05, true)

-- seeds
local s1 = { 21, 46, 6.4, 4.1, -0.42 }
local s2 = { 35, 39, 5.4, 3.7, -0.5 }
local m1 = A.oval(s1[1], s1[2], s1[3], s1[4], s1[5], 0.8)
local m2 = A.oval(s2[1], s2[2], s2[3], s2[4], s2[5], 0.8)
local bud = A.oval(49, 35, 2.6, 2.6, 0, 1)
-- root out of the lower end of the sprouting seed
local rp = { { 39, 41 }, { 42, 43 }, { 44, 45 }, { 47, 44 } }
local rm = A.tube(rp, function(t) return 0.9 * (1 - t) + 0.45 end)
rm:cut(m2)

local bias = {}
for _, m in ipairs{ m1, m2, bud } do X.ao(bias, lm, m, 1, -1) A.cast(bias, lm, m, 1, 2, -1) A.cast(bias, lm, m, 2, 3, -1) end
A.cast(bias, lm, rm, 1, 1, -1)
local ltok = A.tok("leaf")
A.leaf(c, lm, ln, LT, LS, len, LEAF, { bias = bias, tok = ltok, vein = VEIN, per = 5.2, sweep = 2.4, cool = COOL, vw = 0.9 })
torn:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, TORN, ltok) end end)
-- waxy sheen streak along the lit half, parallel to the midrib
lm:each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > -0.62 and LS[k] < -0.5 and LT[k] > 0.55 and LT[k] < 0.8 then c:put(x, y, SHEEN, ltok) end end)

-- root
local rtok = A.tok("root")
rm:each(function(x, y) c:put(x, y, (y <= 42 or x > 45) and ROOT[2] or ROOT[1], rtok) end)
c:put(48, 43, ROOT[1], rtok)

-- quirk: crimson flower bud, four petal seams and a glint
local btok = A.tok("bud")
local bm, bn = A.oval(49, 35, 2.6, 2.6, 0, 1)
local bidx = A.shade(c, bm, bn, RED, { tok = btok, amb = 0.12 })
for _, q in ipairs{ {49,35},{50,36},{48,36} } do c:put(q[1], q[2], RED[max(1, (bidx[K(q[1], q[2])] or 3) - 2)], btok) end
c:put(48, 33, RED[6], btok)
c:put(51, 32, SPR[3], btok) c:put(52, 31, SPR[2], btok)

-- sprout stem: rosy, out of the split top of seed 2
local sp = { { 37, 37 }, { 36, 30 }, { 39, 23 }, { 38, 15 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 1.5 - 0.4 * t end)
local stok = A.tok("stem")
sm:each(function(x, y) local k = K(x, y)
  c:put(x, y, STEM[SS[k] < -0.35 and 4 or (SS[k] < 0.2 and 3 or (SS[k] < 0.6 and 2 or 1))], stok) end)
-- a pair of opposite glossy elliptic leaves + red tip bud
local gtok = A.tok("sprout-leaf")
local ll = A.sprleaf(c, 37, 16, 30, 10, 23, 13, 3.4, SPR, gtok, { pow = 0.55, gloss = SHEEN })
local rl = A.sprleaf(c, 39, 16, 46, 10, 53, 13, 3.4, SPR, gtok, { pow = 0.55, gloss = SHEEN, cut = ll })
for _, q in ipairs{ {38,14,4},{37,13,5},{38,13,3},{38,12,6} } do c:put(q[1], q[2], RED[q[3]], gtok) end
-- ambient dark where the leaves meet the stem
c:put(37, 17, SPR[1], gtok) c:put(39, 17, SPR[1], gtok)

-- seeds last
local tok1, tok2 = A.tok("seed1"), A.tok("seed2")
local b1 = {}
X.ao(b1, m1, m2, 1, -1)
A.seed(c, s1, SEED, tok1, { bias = b1, rim = "#6a4c62", spec = "#fff0d0", spec2 = SEED[6], power = 50, cut = m2 })
local _, _, i2 = A.seed(c, s2, SEED, tok2, { rim = "#6a4c62", spec = "#fff0d0", power = 50, cut = sm })
-- hilum: a pale stripe along the lower side of each seed
for _, q in ipairs{ {17,49,1},{18,49,2},{19,49,2},{20,49,2},{21,48,2},{22,48,1} } do c:put(q[1], q[2], HIL[q[3]], tok1) end
for _, q in ipairs{ {33,42,1},{34,42,2},{35,41,2},{36,41,1} } do c:put(q[1], q[2], HIL[q[3]], tok2) end
-- split seam on the sprouting seed where the stem breaks through
for _, q in ipairs{ {35,37},{36,38},{39,36} } do if m2:has(q[1], q[2]) and not sm:has(q[1], q[2]) then c:put(q[1], q[2], SEED[1], tok2) end end

A.save(c, NAME)
