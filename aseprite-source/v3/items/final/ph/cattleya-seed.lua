-- cattleya-seed (ph, Opus single pass). A slim six-ribbed cattleya seed capsule (olive-green, lit ribs, dark
-- furrows) lies split on a torn, leathery orchid-leaf scrap (V-fold light, parallel veins, ragged torn end with a
-- pale fibrous edge, cool reflected rim), spilling golden dust-fine spindle seeds onto the leaf. In front a seed
-- has germinated: a round green protocorm with silvery velamen rootlets, a tiny ridged pseudobulb and one thick
-- strap-shaped cattleya leaf with a notched tip and a folded midrib.
-- quirk: the capsule still wears its withered lavender flower at the tip.
local NAME = "cattleya-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r1_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local LEAF = { "#1a3a32", "#25563c", "#367646", "#55964e", "#80b85c", "#b4d884" }
local CAP = { "#2e3424", "#4c5430", "#707a3a", "#98a04a", "#c0c468", "#e2e29a" }
local GOLD = { "#9a6420", "#e0a838", "#ffe08a" }
local PB = { "#2e5a3a", "#4e8a4a", "#7cb45e", "#a8d47c", "#d0eca0", "#f2fad0" }
local VEL = { "#8a9aa0", "#c8d4d4", "#eef2ea" }
local LAV = { "#5a3060", "#8a4e90", "#b47ab8", "#dcaad8" }

-- leaf scrap: straight-ish strap on the diagonal, torn at the right end
local lm, ln, LT, LS, len = A.blade(7, 50, 30, 50, 57, 40, function(t)
  if t > 0.995 then return -1 end
  return max(0.6, 6.6 * min(1, (t + 0.04) * 5) ^ 0.6)
end, { fold = 0.35 })
-- torn end: jagged cut, plus a bite-shaped tear on the upper edge
local torn = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  local lim = 0.86 + 0.07 * sin(s * 9) + (A.hash(floor(s * 6), 3, 8) - 0.5) * 0.06
  if t > lim then torn[#torn + 1] = k end end)
for _, k in ipairs(torn) do lm.s[k] = nil end
-- capsule geometry (on the leaf)
local CAPX, CAPY, CAPA = 27, 42, -0.42
local cm, cn = A.oval(CAPX, CAPY, 11, 3.2, CAPA, 0.9)
-- sprout geometry
local bulb, bn = A.oval(44, 41, 2.6, 3.4, 0, 1)
local proto, prn = A.oval(44, 45.5, 3.2, 2.4, 0, 1)
local sl = { A.blade(44, 38, 45, 25, 50, 12, function(t) if t > 0.99 then return -1 end
  return max(0.7, 3.2 * min(1, t * 6 + 0.25) ^ 0.5 * (1 - max(0, t - 0.8) * 2.2)) end, { fold = 0.6 }) }

local bias = {}
X.ao(bias, lm, cm, 1, -1) A.cast(bias, lm, cm, 1, 2, -1)
X.ao(bias, lm, proto, 1, -1) A.cast(bias, lm, proto, 1, 1, -1)
local ltok = A.tok("leaf")
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- parallel veins (monocot) + midrib
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if (bias[k] or 0) < 0 then return end
  if abs(s) < 0.1 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok)
  elseif abs(abs(s) - 0.5) < 0.06 then c:put(x, y, LEAF[max(1, min(6, lidx[k] + (s < 0 and 1 or -1)))], ltok) end end)
-- torn fibrous edge (pale), cool reflected rim lower edge
lm:edge():each(function(x, y) local k = K(x, y)
  if LT[k] > 0.8 then c:put(x, y, A.hash(x, y, 2) < 0.5 and "#d8e8a8" or LEAF[5], ltok)
  elseif LS[k] > 0.7 and (bias[k] or 0) == 0 and LT[k] > 0.08 then c:put(x, y, "#3c6e74", ltok) end end)
-- petiole stub left
c:put(6, 51, LEAF[3], ltok) c:put(5, 51, LEAF[2], ltok) c:put(5, 52, LEAF[2], ltok)

-- spilled seed dust: golden spindles (2x1 / 1x2) on the leaf, lots near the split
local dtok = A.tok("dust")
local dust = { { 34, 45, 1 }, { 36, 46, 0 }, { 33, 48, 1 }, { 38, 48, 0 }, { 36, 49, 1 }, { 31, 47, 0 }, { 40, 51, 1 }, { 29, 50, 0 }, { 35, 51, 0 }, { 25, 49, 1 }, { 22, 48, 0 } }
for i, d in ipairs(dust) do
  if lm:has(d[1], d[2]) then
    c:put(d[1], d[2], GOLD[2], dtok)
    if d[3] == 1 then c:put(d[1] + 1, d[2], GOLD[1], dtok) else c:put(d[1], d[2] + 1, GOLD[1], dtok) end
    if i % 3 == 1 then c:put(d[1], d[2], GOLD[3], dtok) end
  end
end

-- capsule: ribbed (6 ribs -> 3 visible), split along the lower ridge with dust inside
local ctok = A.tok("capsule")
local ca, sa = cos(CAPA), sin(CAPA)
local cidx = X.tone(c, cm, X.light(cn, { amb = 0.1, wrap = 0.25 }), CAP, { cuts = A.CUTS, tok = ctok })
cm:each(function(x, y) local k = K(x, y)
  local dx, dy = x - CAPX, y - CAPY
  local u, v = (dx * ca + dy * sa) / 11.45, (-dx * sa + dy * ca) / 3.65
  if abs(u) < 0.88 then
    if abs(v + 0.45) < 0.12 or abs(v - 0.15) < 0.12 then c:put(x, y, CAP[max(1, cidx[k] - 2)], ctok)
    elseif abs(v + 0.15) < 0.14 and v < 0 then c:put(x, y, CAP[min(6, cidx[k] + 1)], ctok) end
    -- split: open slit with golden dust
    if v > 0.42 and v < 0.78 and u > -0.35 and u < 0.6 then c:put(x, y, (A.hash(x, y, 6) < 0.5) and GOLD[2] or GOLD[1], ctok) end
  end
end)
-- stalk stub at left end, dried crown at the right
local lx, ly = floor(CAPX - ca * 12 + .5), floor(CAPY - sa * 12 + .5)
c:put(lx, ly, CAP[2], ctok) c:put(lx - 1, ly + 1, CAP[2], ctok) c:put(lx - 2, ly + 1, CAP[1], ctok)
do local bx, by = A.specAt(cm, cn, 50) c:put(bx, by, CAP[6], ctok) end

-- quirk: withered lavender flower clinging to the capsule tip
local fx, fy = floor(CAPX + ca * 11.5 + .5), floor(CAPY + sa * 11.5 + .5)
local ftok = A.tok("flower")
local map = {
  ".lL..",
  "lLmd.",
  ".mLmL",
  "dmdl.",
  ".d...",
}
local FC = { l = LAV[4], L = LAV[3], m = LAV[2], d = LAV[1] }
for yy, row in ipairs(map) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if FC[ch] then c:put(fx + xx - 2, fy + yy - 4, FC[ch], ftok) end end end

-- sprout: velamen rootlets, protocorm, pseudobulb, strap leaf
local vtok = A.tok("velamen")
for _, r in ipairs{ { { 41, 47 }, { 39, 49 }, { 38, 51 } }, { { 46, 47 }, { 48, 49 }, { 50, 50 } }, { { 44, 48 }, { 44, 50 }, { 45, 52 } } } do
  for i, q in ipairs(r) do
    local nx = r[i + 1]
    if nx then local n = max(abs(nx[1] - q[1]), abs(nx[2] - q[2]))
      for s = 0, n do c:put(floor(q[1] + (nx[1] - q[1]) * s / n + .5), floor(q[2] + (nx[2] - q[2]) * s / n + .5), (i == 1) and VEL[2] or VEL[1], vtok) end end
  end
  c:put(r[3][1], r[3][2], PB[3], vtok)
end
local stok = A.tok("pbulb")
local lb = {}
X.ao(lb, sl[1], bulb, 1, -1)
A.leaf(c, sl[1], sl[2], sl[3], sl[4], sl[5], PB, { bias = lb, per = 99, ribHi = PB[6], ribLo = PB[2], cool = "#3c6e74", tok = A.tok("sleaf"), rib = 0.12 })
-- notched tip
local tx, ty = 50, 12
c.pix[ty * 64 + tx] = nil c.own[ty * 64 + tx] = nil
local bb = {}
X.ao(bb, bulb, proto, 1, -1)
local bidx = X.tone(c, bulb, X.light(bn, { amb = 0.1, wrap = 0.3 }), PB, { cuts = A.CUTS, bias = bb, tok = stok })
bulb:each(function(x, y) if x == 43 or x == 45 then local k = K(x, y) c:put(x, y, PB[max(1, bidx[k] - 1)], stok) end end)
local ptok = A.tok("proto")
local pidx = X.tone(c, proto, X.light(prn, { amb = 0.1, wrap = 0.3 }), PB, { cuts = A.CUTS, tok = ptok })
proto:each(function(x, y) if A.hash(x, y, 12) < 0.12 then c:put(x, y, VEL[3], ptok) end end)
do local bx, by = A.specAt(bulb, bn, 40) c:put(bx, by, PB[6], stok) end
A.save2(c, NAME)
