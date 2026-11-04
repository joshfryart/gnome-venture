-- guaria-morada-seed (aC10_3 Opus pass). A ripe Guarianthe capsule (six-ribbed, green ripening to tan, one slit split
-- open) lying across a thick, leathery orchid-leaf scrap (keeled midrib, glossy wax sheen, notched tip, torn base),
-- spilling a drift of golden dust-fine orchid seed. Beside it a seedling: a round green protocorm sending up two fleshy
-- oblong leaves (the orchid's own leaf shape) and one silver velamen root. AO + contact shadows where parts meet.
-- quirk: the withered purple flower is still clinging to the capsule's tip like a crumpled party hat.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_3.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = D.new("guaria-morada-seed")
local LEAF = { "#173a30", "#22543a", "#2f7244", "#46904c", "#6cb058", "#a6d478" }
local POD  = { "#3e3a22", "#5e5a2c", "#848032", "#a8a044", "#c8be66", "#e6dc98" }
local TAN  = { "#4a3222", "#6e4c2e", "#946a3c", "#b88c52", "#d8b070", "#f0d49c" }
local PURP = { "#3a1a4a", "#5c2470", "#843696", "#a856b8", "#cc86d6", "#ecbcef" }
local DUST = { "#c88a2a", "#eebc4a", "#ffe08a" }
local VEL  = { "#7e8a92", "#b4c0c4", "#e2ece8" }
local COOL = "#3e6a74"

-- leaf scrap: thick strap on the diagonal (upper-left -> lower-right), notched tip lower-right, torn upper-left
local lm, ln, LT, LS, len = G.blade(9, 30, 26, 50, 56, 54, function(t)
  if t > 0.99 then return -1 end
  local w = 7.4 - 1.2 * t
  if t > 0.86 then w = w * (1 - ((t - 0.86) / 0.14) ^ 2) ^ 0.5 end
  return max(0.5, w)
end, { fold = 0.3 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  if LT[k] < 0.07 + 0.06 * X.hash(floor(LS[k] * 5), 3, 9) then cut[#cut + 1] = k end
  if LT[k] > 0.95 and abs(LS[k]) < 0.18 then cut[#cut + 1] = k end                -- notched tip
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- capsule: ellipsoid lying across the leaf (lower-left -> upper-right), withered flower at upper-right tip
local PA, PB = { 15, 47 }, { 38, 33 }
local pm, pn, PT, PS = X.cyl(PA[1], PA[2], PB[1], PB[2], function(t)
  return 4.6 * sin(pi * min(1, t * 0.94 + 0.04)) ^ 0.55 + 0.3
end)
-- short stalk at the lower-left end
local km, kn = X.cyl(10, 50, 15, 47, function() return 0.9 end)
km:cut(pm)

-- protocorm + seedling at the right of the capsule
local pc = G.oval(46, 42, 3.1, 2.7, 0, 1)
local pcn = select(2, G.oval(46, 42, 3.1, 2.7, 0, 1))

local bias = {}
X.ao(bias, lm, pm, 1, -1) G.cast(bias, lm, pm, 1, 2, -1)
X.ao(bias, lm, pc, 1, -1) G.cast(bias, lm, pc, 1, 1, -1)
local ltok = D.tok("leaf")
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.14, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t < 0.94 then c:put(x, y, LEAF[2], ltok) return end           -- keel groove
  if s < 0 and s > -0.24 and t < 0.94 then c:put(x, y, LEAF[5], ltok) end          -- lit keel shoulder
  if (abs(s) > 0.55 and abs(s) < 0.62) then c:put(x, y, s < 0 and LEAF[5] or LEAF[3], ltok) end
end)
-- wax sheen: short pale streak along the lit half
for i = 0, 6 do local t = 0.3 + i * 0.03 c:put(floor(9 + (56 - 9) * t * 0.95 - 1), floor(30 + (54 - 30) * t + 1.4 + 0.5) - 3, LEAF[6], ltok) end
lm:edge():each(function(x, y) local k = K(x, y)
  if LT[k] < 0.15 then c:put(x, y, "#cfe6b0", ltok)
  elseif not bias[k] and LS[k] > 0.66 and LT[k] < 0.92 then c:put(x, y, COOL, ltok) end
end)

-- stalk
X.tone(c, km, X.light(kn, { amb = 0.15, wrap = 0.3 }), TAN, { cuts = { 0.2, 0.4, 0.58, 0.74, 0.88 }, tok = D.tok("stalk") })
-- capsule body: ribs, green->tan ripening, split slit with dust
local ptok = D.tok("pod")
local pv = X.light(pn, { amb = 0.1, wrap = 0.25 })
local plen = math.sqrt((PB[1] - PA[1]) ^ 2 + (PB[2] - PA[2]) ^ 2)
local slit = {}
pm:each(function(x, y) local k = K(x, y)
  local s, t = PS[k], PT[k]
  local i = 1
  for j, ct in ipairs{ 0.18, 0.34, 0.5, 0.66, 0.82 } do if pv[k] >= ct then i = j + 1 end end
  -- ribs: three lines along the pod
  if abs(s - (-0.5)) < 0.1 or abs(s - 0.05) < 0.1 then i = i + 1 end
  if abs(s - 0.55) < 0.1 then i = i - 1 end
  local R = (t > 0.62 or (t + X.hash(x, y, 5) * 0.12) > 0.66) and TAN or POD
  -- slit: between ribs on the upper half, gaping open
  if s > -0.34 and s < -0.14 and t > 0.22 and t < 0.74 then slit[#slit + 1] = { x, y, t } return end
  c:put(x, y, R[max(1, min(6, i))], ptok)
end)
for _, q in ipairs(slit) do
  local x, y = q[1], q[2]
  c:put(x, y, (X.hash(x, y, 2) < 0.45) and DUST[2] or TAN[1], ptok)
end
-- specular on the lit shoulder
c:put(22, 39, POD[6], ptok) c:put(23, 38, POD[6], ptok)
-- quirk: withered purple flower crumpled on the tip
local fl = HP.mask()
fl:add(G.rell(40, 31, 0.8, -0.6, 3.0, 2.0)):add(G.rell(42, 29, 0.3, -1, 2.4, 1.3)):add(G.rell(41, 33, 1, 0.2, 1.8, 1.1))
fl:cut(pm)
local ftok = D.tok("flower")
G.toneN(c, fl, X.pillow(fl, 1.4), PURP, { tok = ftok, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, amb = 0.12, wrap = 0.3 })
fl:each(function(x, y) if X.hash(x, y, 13) < 0.18 then D.shift(c, x, y, PURP, -2) end end)  -- crinkles
c:put(43, 27, PURP[6], ftok) c:put(44, 28, "#f5d24a", ftok)                                -- lip tip + gold throat speck

-- dust drift: tiny clusters spilling out of the slit onto the leaf
local dtok = D.tok("dust")
for _, p in ipairs{ { 24, 44 }, { 25, 45 }, { 27, 46 }, { 28, 45 }, { 30, 47 }, { 26, 48 }, { 31, 45 }, { 33, 47 }, { 29, 49 } } do
  if lm:has(p[1], p[2]) and not pm:has(p[1], p[2]) then
    c:put(p[1], p[2], DUST[(p[1] + p[2]) % 3 + 1], dtok)
  end
end

-- seedling: velamen root, protocorm, two fleshy leaves
local rm, rn = G.tube({ { 48, 44 }, { 51, 46 }, { 53, 49 }, { 52, 52 } }, function(t) return 0.9 - 0.3 * t end)
rm:cut(pc)
X.tone(c, rm, X.light(rn, { amb = 0.15, wrap = 0.3 }), VEL, { cuts = { 0.35, 0.7 }, tok = D.tok("root") })
c:put(52, 52, "#9cc46a", D.tok("rtip"))                                                     -- green root tip
local stok = D.tok("seedling")
local lfA, lnA, TA, SA = G.blade(45, 40, 40, 30, 38, 20, function(t) if t > 0.985 then return -1 end
  return max(0.5, 2.9 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.5) end, { fold = 0.35 })
local lfB, lnB, TB, SB = G.blade(47, 40, 52, 31, 56, 24, function(t) if t > 0.985 then return -1 end
  return max(0.5, 2.6 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.5) end, { fold = 0.35 })
lfA:cut(fl) lfB:cut(lfA)
local sb = {}
X.ao(sb, lfB, lfA, 1, -1)
G.toneN(c, lfA, lnA, LEAF, { tok = stok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, amb = 0.14, wrap = 0.3 })
G.toneN(c, lfB, lnB, LEAF, { tok = stok, bias = sb, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, amb = 0.14, wrap = 0.3 })
lfA:each(function(x, y) local k = K(x, y) if abs(SA[k]) < 0.14 and TA[k] < 0.88 then c:put(x, y, LEAF[2], stok) end end)
lfB:each(function(x, y) local k = K(x, y) if abs(SB[k]) < 0.14 and TB[k] < 0.88 then c:put(x, y, LEAF[2], stok) end end)
local pbias = {}
X.ao(pbias, pc, lfA, 1, -1) X.ao(pbias, pc, lfB, 1, -1)
G.toneN(c, pc, pcn, { "#2a4a2a", "#3e6a36", "#5a8c44", "#7eae56", "#a6cc72", "#d2e8a0" },
  { tok = D.tok("protocorm"), bias = pbias, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.1, wrap = 0.3 })
c:put(44, 41, "#eef6c8", stok)                                                               -- glint
-- rhizoid hairs at the protocorm foot
c:put(43, 45, VEL[3], stok) c:put(45, 45, VEL[2], stok)
D.save(c, "guaria-morada-seed")
