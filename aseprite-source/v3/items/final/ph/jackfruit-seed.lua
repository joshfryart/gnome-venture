-- jackfruit-seed (final pass, Opus single pass). One big oblong jackfruit seed dominates: smooth tan coat with a
-- dark hilum, its left half still wrapped in the wrinkled cream papery membrane (torn, jagged edge). A smaller
-- seed sits behind on the right. Both rest on a torn scrap of glossy jackfruit leaf (midrib, veins, pale torn
-- tissue on the ripped left end, AO + contact shadows). The big seed has germinated: a stout pale hypocotyl
-- curving up into two alternate, glossy elliptic jackfruit leaves and a folded bud.
-- quirk: a sticky yellow shred of jackfruit aril still clinging to the small seed.
local NAME = "jackfruit-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new(NAME)
local LEAF = { "#123326", "#1b4a30", "#28673a", "#3c8640", "#5fa64a", "#98cc66" }
local SEED = { "#5a3a2a", "#86583a", "#b07e52", "#d2a670", "#ead0a0", "#fbefcf" }
local MEM = { "#a99c86", "#cfc3a8", "#e8dfc8", "#f8f1df" }
local STEM = { "#6a6a3a", "#8fa058", "#bcd084", "#e2efb6" }
local ARIL = { "#a8601c", "#d98d22", "#f5b82e", "#ffd860", "#fff0a8" }

-- scrap: torn at the left end
local lm, ln, LT, LS, len = A.blade(56, 49, 34, 56, 9, 50, function(t)
  if t > 0.99 then return -1 end
  return max(0.6, 6.4 * sin(pi * min(1, t * 0.8 + 0.12)) ^ 0.6)
end, { fold = 0.3 })
local torn = A.tear(lm, LT, LS, 0.85, { 0.02, -0.05, 0.04, -0.02, 0.05, -0.04, 0.01 })

-- seeds
local big = { 26, 46, 8.2, 4.6, -0.22 }
big.m, big.n = A.oval(big[1], big[2], big[3], big[4], big[5], 0.9)
local sml = { 42, 48, 5.4, 3.5, 0.35 }
sml.m, sml.n = A.oval(sml[1], sml[2], sml[3], sml[4], sml[5], 0.9)
local aril = HP.mask()
for _, q in ipairs{ { 40, 44 }, { 41, 44 }, { 42, 44 }, { 39, 45 }, { 40, 45 }, { 41, 45 }, { 42, 45 }, { 43, 45 }, { 44, 45 }, { 40, 46 }, { 41, 46 }, { 44, 46 }, { 45, 46 }, { 45, 47 } } do aril:set(q[1], q[2]) end

-- sprout: from the big seed's upper-right end
local stem = { { 32, 42 }, { 35, 33 }, { 28, 26 }, { 31, 19 } }
local sm, sn, ST = A.tube(stem, function(t) return 1.45 - t * 0.45 end)
sm:cut(big.m)

local all = HP.mask():add(big.m):add(sml.m):add(aril)
local bias = {}
X.ao(bias, lm, all, 1, -1)
A.cast(bias, lm, all, 1, 2, -1)
A.leaf(c, lm, ln, LT, LS, { ramp = LEAF, vein = "#a8d47a", cool = "#2f5f58", per = 4.4, sweep = 3.5, len = len, bias = bias, torn = torn, tissue = "#d2e6a0" })

-- stem: pale green, browner at the base
local stok = { r = { name = "stem" } }
local sidx = A.shade(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 } })
sm:each(function(x, y) if y >= 39 then c:put(x, y, ({ "#5a4a32", "#7a6640", "#a08a5a", "#c8b47e" })[sidx[K(x, y)]], stok) end end)

-- leaves: big elliptic up-left, smaller up-right, folded bud on top
local function eleaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.35, w * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.65)
  end, { fold = 0.28 })
  return m, n, T, S, L
end
local ltok = { r = { name = "sleaf" } }
local l1m, l1n, l1T, l1S, l1L = eleaf(30, 22, 22, 13, 11, 12, 4.6)
local l2m, l2n, l2T, l2S, l2L = eleaf(32, 26, 40, 22, 48, 15, 3.4)
for _, L in ipairs{ { l2m, l2n, l2T, l2S, l2L }, { l1m, l1n, l1T, l1S, l1L } } do
  local m = L[1]:copy():cut(sm)
  local lb = {} X.ao(lb, m, sm, 1, -1)
  A.leaf(c, m, L[2], L[3], L[4], { ramp = LEAF, vein = "#a8d47a", cool = "#2f5f58", per = 3.6, sweep = 2.5, len = L[5], bias = lb, tok = ltok, t0 = 0.06 })
  local gx, gy = A.specAt(m, L[2], 70) c:put(gx, gy, A.CREAM, ltok)
end
-- petioles + bud
c:put(31, 23, STEM[2], stok) c:put(32, 25, STEM[2], stok) c:put(33, 25, STEM[1], stok)
A.map(c, { ".a", "ab", "bc", "c." }, 31, 15, { a = LEAF[6], b = LEAF[4], c = LEAF[3] }, ltok)

-- small seed (behind) with aril quirk
local s2tok = { r = { name = "seed2" } }
local vis2 = sml.m:copy():cut(big.m)
local sb2 = {} X.ao(sb2, sml.m, big.m, 1, -1)
A.seed(c, vis2, sml.n, SEED, { bias = sb2, tok = s2tok, rim = "#8a8a8a", cuts = { 0.14, 0.3, 0.48, 0.66, 0.86 } })
c:put(46, 50, SEED[1], s2tok) c:put(47, 49, SEED[2], s2tok)   -- hilum
local atok = { r = { name = "aril" } }
aril:cut(big.m)
aril:each(function(x, y) local i = (y == 44 or x <= 40) and 4 or 3
  if y == 46 and x >= 44 or y == 47 then i = 2 end
  if (x + y) % 3 == 0 and i > 2 then i = i - 1 end           -- fibres
  c:put(x, y, ARIL[i], atok) end)
c:put(40, 44, ARIL[5], atok) c:put(41, 44, ARIL[5], atok)
A.contact(c, {}, SEED, vis2, aril, 1, 1, 1, s2tok)

-- big seed: coat, membrane over the left half, hilum, glint
local btok = { r = { name = "seed1" } }
local bidx = A.seed(c, big.m, big.n, SEED, { tok = btok, rim = "#8a8a8a", cuts = { 0.12, 0.28, 0.46, 0.64, 0.84 } })
local ca, sa = cos(big[5]), sin(big[5])
local JAG = { 0.1, -0.05, 0.15, 0.0, -0.1, 0.08, -0.02, 0.12, -0.06, 0.05 }
big.m:each(function(x, y) local k = K(x, y)
  local dx, dy = x - big[1], y - big[2]
  local u, v = (dx * ca + dy * sa) / big[3], (-dx * sa + dy * ca) / big[4]
  local b = floor((v + 1.2) * 4) + 1
  local edge = -0.12 + (JAG[b] or 0)
  if u < edge then
    local i = min(4, max(1, bidx[k] - 2))
    if floor((v + 2) * 3.2 + u * 1.5) % 2 == 0 then i = max(1, i - 1) end   -- wrinkles
    if u > edge - 0.14 then i = 4 end                                      -- lifted torn lip
    c:put(x, y, MEM[i], btok)
  elseif u < edge + 0.12 then
    c:put(x, y, SEED[max(1, bidx[k] - 1)], btok)                          -- shadow under the lip
  end
end)
-- hilum at the right end, glint on the bare coat
c:put(33, 43, SEED[1], btok) c:put(34, 44, SEED[2], btok)
c:put(27, 43, SEED[6], btok) c:put(28, 43, A.CREAM, btok)
A.save(c, NAME)
