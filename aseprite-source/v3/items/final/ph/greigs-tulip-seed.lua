-- greigs-tulip-seed (aC10_3 Opus pass). Three flat, papery tulip seeds (rounded D shapes, tan wing round a darker
-- embryo ridge, pale rim) on a torn scrap of Greig's tulip leaf: glaucous blue-green, wavy margin, parallel monocot
-- veins and the plant's hallmark maroon stripes; ragged pale torn end, V-fold light, cool reflected edge, AO + contact
-- shadows under the seeds. The middle seed has sprouted: pale stem, the first broad lanceolate leaf with maroon stripes.
-- quirk: the thread-thin cotyledon still wears the empty seed coat on its tip like a little hat.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_3.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = D.new("greigs-tulip-seed")
local LEAF = { "#1c3a46", "#2a5658", "#3c7468", "#56927a", "#7cb28e", "#acd2aa" }   -- glaucous tulip green
local MAR  = { "#3e1630", "#5e1e3a", "#7e2a46" }                                       -- greigii stripes
local TORN, COOL = "#d8ecc0", "#4a6c86"
local SEED = { "#4a2c26", "#6e4632", "#96663e", "#bc8c56", "#dcb47c", "#f4dcaa" }
local STEM = { "#4c7a5a", "#7aa676", "#a8cc96", "#d6ecc0" }

-- leaf scrap: long blade lying left->right, rising slightly; base end (left) torn ragged
local lm, ln, LT, LS, len = G.blade(7, 50, 30, 54, 57, 41, function(t)
  if t > 0.98 then return -1 end
  local w = 7.2 * sin(pi * min(1, t * 0.82 + 0.18)) ^ 0.75
  return max(0.5, w + 0.5 * sin(t * 40))                           -- wavy margin
end, { fold = 0.42 })
-- tear: jagged cut across the left end
local cut, tornEdge = {}, {}
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.1 + 0.05 * X.hash(floor(LS[k] * 6), 1, 4) + 0.02 * ((y % 2 == 0) and 1 or 0)
  if LT[k] < lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 18, 47, 4.6, 3.4, -0.35 }, { 30, 47, 4.4, 3.3, 0.25 }, { 43, 44, 4.5, 3.3, -0.2 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.35) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = D.tok("leaf")
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.29, 0.45, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  -- midrib
  if abs(s) < 0.13 and t < 0.95 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  -- parallel veins
  if (abs(s) > 0.38 and abs(s) < 0.46) or (abs(s) > 0.7 and abs(s) < 0.77) then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
  -- maroon stripes: broken dashes along the vein lines
  local d = t * len
  if abs(s) > 0.2 and abs(s) < 0.34 and (d % 7) < 3.2 then c:put(x, y, MAR[(s < 0) and 3 or 2], ltok) end
  if abs(s) > 0.52 and abs(s) < 0.64 and ((d + 3) % 8) < 2.5 then c:put(x, y, MAR[(s < 0) and 3 or 1], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if LT[k] < 0.17 then c:put(x, y, TORN, ltok)                                        -- torn pale tissue
  elseif not bias[k] and LS[k] > 0.7 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end
end)

-- sprout from the middle seed: stem, first leaf, cotyledon whip
local stok = D.tok("stem")
local sm, sn = G.tube({ { 31, 46 }, { 31, 40 }, { 30, 34 }, { 31, 28 } }, function() return 1.05 end)
sm:cut(seeds[2].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- true leaf: broad lanceolate, gently curved up-left, clasping the stem
local tm, tn, TT, TS, tlen = G.blade(31, 31, 30, 18, 22, 8, function(t)
  if t > 0.985 then return -1 end
  return max(0.4, 4.3 * sin(pi * min(1, t * 0.92 + 0.06)) ^ 0.7)
end, { fold = 0.5 })
tm:cut(sm)
local tbias = {}
X.ao(tbias, tm, sm, 1, -1)
G.toneN(c, tm, tn, LEAF, { tok = ltok, bias = tbias, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, amb = 0.14, wrap = 0.3 })
tm:each(function(x, y) local k = K(x, y) local s, t = TS[k], TT[k]
  if abs(s) < 0.13 and t > 0.05 and t < 0.9 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  local d = t * tlen
  if abs(s) > 0.3 and abs(s) < 0.48 and t > 0.12 and t < 0.82 and (d % 6) < 2.6 then c:put(x, y, MAR[(s < 0) and 3 or 2], ltok) end
end)
tm:edge():each(function(x, y) local k = K(x, y) if TS[k] > 0.72 and TT[k] > 0.2 and TT[k] < 0.85 then c:put(x, y, COOL, ltok) end end)
-- cotyledon whip: thin arc to the right with the seed-coat hat on its tip
local wm, wn = G.tube({ { 32, 34 }, { 36, 26 }, { 41, 21 }, { 45, 22 } }, function(t) return 0.55 end)
wm:cut(sm):cut(tm)
X.tone(c, wm, X.light(wn, { amb = 0.2, wrap = 0.3 }), STEM, { cuts = { 0.25, 0.5, 0.75 }, tok = stok })
local hat = G.oval(46, 23, 2.6, 1.7, 0.5, 0.4)
local hn = select(2, G.oval(46, 23, 2.6, 1.7, 0.5, 0.4))
local htok = D.tok("hat")
G.toneN(c, hat, hn, SEED, { tok = htok, amb = 0.1, wrap = 0.3 })
c:put(45, 22, SEED[6], htok) c:put(47, 25, SEED[2], htok)

-- seeds last: papery wing, darker embryo ridge, pale rim, AO between neighbours
for i, s in ipairs(seeds) do
  local tok = D.tok("seed" .. i)
  local ca, sa = cos(s[5]), sin(s[5])
  local sb = {}
  if i == 2 then X.ao(sb, s.m, sm, 1, -1) end
  local v = X.light(s.n, { amb = 0.1, wrap = 0.3 })
  s.m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, w = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    local q = u * u + w * w
    local idx = floor(v[k] * 4.2) + 2                                              -- wing: 2..6
    if q < 0.3 and abs(w + 0.1) < 0.32 then idx = (w < -0.1) and 4 or 2 end      -- embryo ridge
    if q > 0.72 then idx = idx + 1 end                                             -- thin translucent rim
    if sb[k] then idx = idx - 1 end
    c:put(x, y, SEED[max(1, min(6, idx))], tok)
  end)
  -- papery wrinkle and a glint
  local gx, gy = floor(s[1] - 2 * ca + 0.5), floor(s[2] - 2 * sa - 1.5 + 0.5)
  c:put(gx, gy, SEED[6], tok)
end
-- sprouting seed: split coat line where the stem leaves
c:put(31, 45, SEED[1], D.tok("split"))
D.save(c, "greigs-tulip-seed")
