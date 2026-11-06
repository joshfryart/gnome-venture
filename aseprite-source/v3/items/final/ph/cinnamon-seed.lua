-- cinnamon-seed (Opus single pass). On a torn scrap of glossy cinnamon leaf (three main veins running base to tip,
-- jagged torn end, V-fold light, cool reflected edge, contact shadows): one ripe blue-black cinnamon berry still in
-- its pale six-toothed cup, and one cleaned brown seed (ribbed, pale hilum) that has germinated. Sprout: slim stem,
-- a coppery-red flush leaf and a green leaf, both lanceolate with the cinnamon triple vein.
-- quirk: a tiny rolled cinnamon quill (bark stick, spiral end) lies on the leaf.
local NAME = "cinnamon-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local LEAF = { "#163a33", "#1f5640", "#2d7448", "#47944e", "#6fb658", "#a6d672" }
local RED = { "#4a1626", "#7a2630", "#a83c34", "#cc5c3c", "#e8844e", "#ffb47a" }
local BER = { "#140f24", "#262046", "#3a3468", "#56508c", "#7c78b0", "#b4b2dc" }
local CUP = { "#4a4a2a", "#7a7442", "#a8a062", "#c8c084", "#e2daa6", "#f8f0cc" }
local SEED = { "#3a2020", "#5e3426", "#84502e", "#a86e3e", "#c8925a", "#e8bc86" }
local BARK = { "#4a2016", "#7a3a22", "#a65a32", "#c87a44", "#e4a066", "#f6c890" }
local STEM = { "#5a4a2a", "#8a7a44", "#b8a868", "#e0d498" }
local VEIN = "#c8e890"

-- torn leaf scrap: blade lower-left -> right, torn end jagged
local lm, ln, LT, LS, len = A.blade(7, 52, 30, 60, 57, 46, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 8.2 * sin(pi * min(1, t * 0.82 + 0.08)) ^ 0.6)
end, { fold = 0.36 })
local tear = {}
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.8 + 0.07 * sin(LS[k] * 9.5) + 0.04 * sin(LS[k] * 23 + 1)
  if LT[k] > lim then tear[#tear + 1] = k end
end)
for _, k in ipairs(tear) do lm.s[k] = nil end

-- seeds
local berry = { m = nil } berry.m, berry.n = A.oval(20, 44, 3.4, 4.0, 0, 0.9)
local cup, cupn = A.oval(20, 48.5, 4.6, 2.1, 0, 0.7)
local seed, seedn = A.oval(34, 49.5, 4.6, 2.9, -0.32, 0.8)
-- quill
local qp = { { 42, 52 }, { 46, 51 }, { 50, 49.6 }, { 54, 48 } }
local qm, qn, QT, QS = A.tube(qp, function(t) return 1.55 end, 80)

local bias = {}
for _, m in ipairs{ berry.m, cup, seed, qm } do X.ao(bias, lm, m, 1, -1) A.cast(bias, lm, m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- triple veins: midrib + two laterals following the margin
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.03 and t < 0.8 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  if abs(abs(s) - 0.56) < 0.08 and t > 0.08 and t < 0.78 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) return end
  -- fine net: faint cross veinlets
  if abs(s) > 0.15 and abs(s) < 0.5 and floor(t * len / 4.2 + abs(s) * 2) % 2 == 0 and X.hash(x, y, 11) > 0.82 then c:put(x, y, s < 0 and LEAF[5] or LEAF[3], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.1 and LT[k] < 0.76 then c:put(x, y, "#3a6c72", ltok) end
  if LT[k] > 0.74 and not bias[k] then c:put(x, y, LEAF[4], ltok) end  -- pale torn fibre edge
end)
for _, q in ipairs{ {6, 52, 3}, {5, 53, 2}, {4, 53, 2} } do c:put(q[1], q[2], LEAF[q[3]], ltok) end  -- petiole stub

-- quill: rolled bark tube, grain lines along, spiral end at the right
local qtok = { r = { name = "quill" } }
local qidx = A.shade(c, qm, qn, BARK, { tok = qtok, cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 } })
qm:each(function(x, y) local k = K(x, y)
  if abs(QS[k] - 0.3) < 0.14 and X.hash(x, y, 5) > 0.35 then c:put(x, y, BARK[max(1, (qidx[k] or 3) - 1)], qtok) end end)
c:put(54, 47, BARK[2], qtok) c:put(55, 48, BARK[5], qtok) c:put(54, 48, BARK[1], qtok) c:put(55, 47, BARK[3], qtok) c:put(54, 49, BARK[4], qtok)

-- sprout from the cleaned seed: stem + two lanceolate leaves (triple veined)
local stok = { r = { name = "stem" } }
local sp = { { 35, 47 }, { 36, 40 }, { 33, 33 }, { 34, 26 } }
local sm, sn = A.tube(sp, function(t) return 1.0 end)
sm:cut(seed)
A.shade(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 } })
local function lance(ax, ay, cx, cy, bx, by, w, ramp, tag, folded)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.88 + 0.1)) ^ 0.75)
  end, { fold = folded })
  m:cut(sm)
  local tok = { r = { name = tag } }
  local idx = A.toneN(c, m, n, ramp, { tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.13 and t > 0.06 and t < 0.86 then c:put(x, y, s <= 0 and ramp[6] or ramp[3], tok)
    elseif abs(abs(s) - 0.55) < 0.1 and t > 0.1 and t < 0.7 then c:put(x, y, s < 0 and ramp[5] or ramp[2], tok) end
  end)
  return m
end
local red = lance(33, 27, 26, 19, 17, 15, 3.6, RED, "flush", 0.32)
local green = lance(35, 28, 44, 21, 53, 17, 4.2, LEAF, "leaf2", 0.36)
-- AO at the leaf bases on the stem
c:put(34, 27, STEM[1], stok) c:put(34, 28, STEM[1], stok)
-- tip bud between the leaves
c:put(34, 24, RED[4], stok) c:put(34, 23, RED[5], stok) c:put(35, 24, RED[3], stok)

-- cup (behind the berry), berry, seed
local ctok = { r = { name = "cup" } }
local cidx = A.shade(c, cup, cupn, CUP, { tok = ctok, cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 } })
-- cup teeth on the rim: alternating pale points above the cup edge
for _, p in ipairs{ {15, 46}, {17, 45}, {23, 45}, {25, 46} } do c:put(p[1], p[2], CUP[5], ctok) end
for x = 16, 24 do if cup:has(x, 50) and x % 3 == 0 then c:put(x, 50, CUP[2], ctok) end end  -- ribs
local btok = { r = { name = "berry" } }
local bvis = berry.m:copy() bvis:cut(cup:copy():cut(berry.m:shift(0, -1)))
local bm2 = berry.m:copy() bm2:cut(HP.rect(10, 48, 30, 52))
A.shade(c, bm2, berry.n, BER, { tok = btok, rim = "#4a7aa0", rimT = 0.5, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
-- berry gloss + waxy bloom flecks + cup-shadow row
c:put(18, 41, "#fffaf0", btok) c:put(19, 41, BER[6], btok) c:put(18, 42, BER[6], btok)
c:put(21, 43, BER[5], btok) c:put(17, 45, BER[4], btok)
for x = 17, 23 do if bm2:has(x, 47) then c:put(x, 47, BER[1], btok) end end
-- cleaned seed: ribbed oval, pale hilum
local sdtok = { r = { name = "seed" } }
local sidx = A.shade(c, seed, seedn, SEED, { tok = sdtok, rim = "#6a5a7a", rimT = 0.6, cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 } })
seed:each(function(x, y) local k = K(x, y)
  local dx, dy = x + 0.5 - 34, y + 0.5 - 49.5
  local ca, sa = cos(-0.32), sin(-0.32)
  local v = (-dx * sa + dy * ca) / 3.3
  if abs(v - 0.05) < 0.14 and abs(dx * ca + dy * sa) < 3.4 then c:put(x, y, SEED[max(1, (sidx[k] or 3) - 1)], sdtok) end
end)
c:put(30, 49, SEED[6], sdtok) c:put(31, 48, SEED[6], sdtok) c:put(32, 48, SEED[6], sdtok)  -- lit ridge
c:put(37, 47, "#f0dcb0", sdtok) c:put(38, 47, "#f0dcb0", sdtok)                           -- hilum
-- tiny radicle out of the seed's tip curling over the leaf
for _, p in ipairs{ {39, 51, 3}, {40, 52, 3}, {40, 53, 2}, {41, 54, 2} } do c:put(p[1], p[2], STEM[p[3]], stok) end

A.run(c, NAME)
