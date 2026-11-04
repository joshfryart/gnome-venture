-- broccoflower-seed (Opus single pass, aB10_4). Three round, glossy russet brassica seeds on a torn scrap of
-- blue-green brassica leaf (ragged tear on the right, petiole stub on the left, pale midrib + swept veins, waxy
-- bloom specks, cool reflected edge, AO + contact shadow under each seed). The back seed has germinated: a pale
-- stem curving up to two notched, heart-shaped brassica cotyledons and a first true leaf with a wavy margin and a
-- tiny pointed lime romanesco bud at its base to name the crop.
-- quirk: the split seed coat is still stuck on the left cotyledon like a little cap.
local NAME = "broccoflower-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local LEAF = { "#173440", "#22524e", "#317060", "#4a8e6c", "#72ae84", "#a6d2a2" }
local SPR  = { "#2a5a34", "#3f7c36", "#62a03c", "#8ec448", "#b8e06a", "#e2f4a8" }
local SEED = { "#2e1418", "#4e2020", "#74302a", "#9a4630", "#c06c44", "#e6a070" }
local STEM = { "#5a8a5a", "#8cb874", "#bcdc98", "#e6f4c4" }
local VEIN, BLOOM, COOL = "#cfe8bc", "#9ec8c4", "#3a6880"
local ltok = { r = { name = "leaf" } }
local stok = { r = { name = "stem" } }
local ptok = { r = { name = "sprout" } }

-- seeds: cx, cy, r
local seeds = { { 21, 47, 2.6 }, { 29, 50, 2.6 }, { 40, 45, 2.7 } }
for _, s in ipairs(seeds) do s.m = c:ellipse(s[1], s[2], s[3], s[3]) end

-- torn leaf scrap
local lm, ln, LT, LS, len = G.blade(7, 50, 30, 54, 57, 41, function(t)
  if t > 0.97 then return -1 end
  local w = 7.2 * sin(pi * min(1, t * 0.62 + 0.2)) ^ 0.5
  return max(1.2, w + 0.5 * sin(t * 52 * 1.1))
end, { fold = 0.32 })
-- ragged tear across the right end
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local tear = 0.82 + 0.05 * sin(s * 9.0) + 0.035 * X.hash(floor(s * 6), 3, 1)
  if t > tear then cut[#cut + 1] = k end
  if t < 0.05 and abs(s) > 0.3 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 }, amb = 0.14, wrap = 0.3 })
local tearEdge = {}
lm:each(function(x, y) local k = K(x, y)
  local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t < 0.86 then c:put(x, y, s <= 0 and VEIN or LEAF[4], ltok) return end
  local ph = (t * len - abs(s) * 4.5) / 6
  if (ph - floor(ph)) < 0.15 and abs(s) > 0.18 and abs(s) < 0.72 and t > 0.06 and t < 0.84 then
    c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) end
  if s < -0.15 and X.hash(x, y, 9) > 0.9 then c:put(x, y, BLOOM, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LT[k] > 0.76 then c:put(x, y, LEAF[5], ltok)                      -- pale torn fibres
  elseif LS[k] > 0.7 and LT[k] > 0.1 then c:put(x, y, COOL, ltok) end
end)
-- petiole stub
for _, q in ipairs{ { 6, 50, 4 }, { 5, 50, 3 }, { 4, 51, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout stem out of the back seed
local sp = { { 40, 44 }, { 39, 36 }, { 34, 30 }, { 35, 21 } }
local sm, sn = G.tube(sp, function(t) return 1.0 end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
X.ao(bias, lm, sm, 1, -1)

-- heart-shaped (notched) cotyledon: stalk + two lobes at the outer end
local function coty(bx, by, ux, uy, L)
  local px, py = -uy, ux
  local m = HP.mask()
  local ex, ey = bx + ux * L, by + uy * L
  m:add(G.rell(ex - ux * 0.6 + px * 1.9, ey - uy * 0.6 + py * 1.9, ux, uy, 2.6, 2.4))
  m:add(G.rell(ex - ux * 0.6 - px * 1.9, ey - uy * 0.6 - py * 1.9, ux, uy, 2.6, 2.4))
  m:add(G.rell(bx + ux * L * 0.45, by + uy * L * 0.45, ux, uy, L * 0.45, 1.4))
  -- notch at the outer tip
  for d = 0, 1 do m.s[K(floor(ex + ux * (1.6 - d) + 0.5), floor(ey + uy * (1.6 - d) + 0.5))] = nil end
  local n = X.pillow(m, 1.8)
  G.toneN(c, m, n, SPR, { tok = ptok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.28 })
  -- midrib
  for i = 1, floor(L) do c:put(floor(bx + ux * i + 0.5), floor(by + uy * i + 0.5), i < L * 0.5 and STEM[3] or SPR[5], ptok) end
  return m, ex, ey
end
local cl, lx, ly = coty(34, 21, -0.92, -0.38, 9)
local cr, rx, ry = coty(36, 21, 0.92, -0.4, 9)
-- first true leaf: small, upright, wavy margin, veins
local tl, tn, TT, TS, tlen = G.blade(35, 20, 34, 15, 37, 9, function(t)
  if t > 0.98 then return -1 end
  local w = 3.4 * sin(pi * min(1, t * 0.85 + 0.1)) ^ 0.6
  return max(0.6, w + 0.4 * sin(t * 22))
end, { fold = 0.4 })
tl:cut(cl):cut(cr)
G.toneN(c, tl, tn, SPR, { tok = ptok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.12, wrap = 0.28 })
tl:each(function(x, y) local k = K(x, y)
  if abs(TS[k]) < 0.15 and TT[k] < 0.85 then c:put(x, y, TS[k] <= 0 and SPR[6] or SPR[3], ptok) end end)
-- AO where the leaves meet the stem top
c:put(35, 22, STEM[1], stok) c:put(34, 22, STEM[2], stok)
-- tiny romanesco bud at the true leaf base (pointed, lime)
for _, p in ipairs{ { 37, 19, 4 }, { 38, 19, 3 }, { 37, 18, 5 }, { 38, 20, 2 }, { 37, 20, 3 } } do c:put(p[1], p[2], SPR[p[3]], ptok) end

-- quirk: split seed coat cap on the left cotyledon tip
do
  local cx, cy = floor(lx - 0.3 + 0.5), floor(ly - 1.5 + 0.5)
  local cap = { { -1, 0, 4 }, { 0, 0, 5 }, { 1, 0, 4 }, { -2, 1, 3 }, { -1, 1, 3 }, { 0, -1, 4 }, { 1, 1, 2 }, { 2, 1, 2 } }
  for _, p in ipairs(cap) do c:put(cx + p[1], cy + p[2], SEED[p[3]], { r = { name = "cap" } }) end
  c:put(cx, cy - 1, SEED[6], { r = { name = "cap" } })
end

-- seeds last: glossy spheres, AO where they touch, one glint each, cool bounce lower-right
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  if i == 3 then vis:cut(sm) end
  local n = X.sphere(s[1] - 0.3, s[2] - 0.3, s[3], vis)
  local tok = { r = { name = "seed" .. i } }
  X.tone(c, vis, X.light(n, { amb = 0.08, wrap = 0.2 }), SEED, { cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 }, bias = sb, tok = tok })
  local r = X.rim(n)
  vis:each(function(x, y) if (r[K(x, y)] or 0) > 0.75 then c:put(x, y, "#7a5a6a", tok) end end)
  c:put(floor(s[1] - 1 + 0.5), floor(s[2] - 1 + 0.5), "#fff0dc", tok)
  -- hilum: tiny pale scar
  c:put(floor(s[1] + 1 + 0.5), floor(s[2] + 0.5), SEED[5], tok)
end
-- the sprouting seed's coat is split: dark slit where the stem leaves it
c:put(40, 43, SEED[1], { r = { name = "seed3" } })

G.save2(c, NAME)
