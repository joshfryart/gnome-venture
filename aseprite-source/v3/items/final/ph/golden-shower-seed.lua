-- golden-shower-seed (Opus single pass, aB35_1). Golden shower (Cassia fistula) seeds: three flat, glossy, ochre-brown
-- ovals with a dark ridge line and one bright glint each, on a torn scrap of a glossy cassia leaflet (smooth margin,
-- pinnate veins, V-fold light, cool reflected edge, AO + contact shadow under the seeds, ragged torn end).
-- The upright seed has germinated: pale green stem, two round cotyledons and a first even-pinnate leaf (three pairs of
-- smooth oval leaflets on a thin rachis) that shows the cassia leaf.
-- quirk: one fallen yellow golden-shower petal has landed on the scrap.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "golden-shower-seed"
local c = G.new2(NAME)
local LEAF = { "#163a30", "#1f5538", "#2c7440", "#43944a", "#6bb656", "#a4d672" }
local VEIN, COOL = "#b8de86", "#3a6c72"
local SEED = { "#3a2018", "#5e3624", "#8a5530", "#b27a3e", "#d6a25a", "#f2cf8e" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local PET = { "#c9781c", "#f5b82e", "#ffd94a", "#fff09a" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 20, 49, 4.2, 2.7, 0.15 }, { 31, 47, 4.3, 2.7, -0.2 }, { 41, 42, 4.0, 2.6, -1.4 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 1.1) end

-- leaf scrap: glossy cassia leaflet on the diagonal, tip torn off on the right
local lm, ln, LT, LS, len = G.blade(7, 55, 30, 52, 60, 38, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 9.4 * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.62)
end, { fold = 0.34 })
G.tear(lm, 52, 0, 1, 0.12, 1.6, 7)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- midrib + pinnate veins (swept toward the tip), lit above, shaded below the rib
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5.5) / 6.2
  local f = ph - floor(ph)
  if f < 0.13 and abs(s) > 0.18 and abs(s) < 0.78 and t > 0.06 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
-- cool reflected light on the lower edge, pale broken fibres on the torn end
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.1 and LT[k] < 0.8 then c:put(x, y, COOL, ltok) end
  if LT[k] > 0.8 and not lm:has(x + 1, y) then c:put(x, y, (x + y) % 2 == 0 and "#c9e49a" or LEAF[4], ltok) end
end)
-- glossy sheen on the lit half
for i = 0, 3 do local t = 0.18 + i * 0.03
  lm:each(function(x, y) local k = K(x, y) if abs(LT[k] - t) < 0.008 and LS[k] < -0.45 and LS[k] > -0.62 and not bias[k] then c:put(x, y, LEAF[6], ltok) end end) end
-- petiole stub
for _, q in ipairs{ { 6, 56, 3 }, { 5, 57, 2 }, { 4, 58, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- quirk: a fallen golden-shower petal on the left of the scrap (cupped, veined, cast shadow)
local ptok = { r = { name = "petal" } }
local pm = G.rell(12, 50, 0.8, -0.6, 3.4, 2.2)
pm:clip(lm)
G.cast({}, lm, pm, 1, 1, -1)
pm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not pm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
local pidx = X.tone(c, pm, X.light(X.pillow(pm, 1.6), { amb = 0.2, wrap = 0.35 }), PET, { cuts = { 0.3, 0.55, 0.8 }, tok = ptok })
c:put(11, 50, PET[2], ptok) c:put(12, 51, PET[2], ptok)

-- sprout: stem (behind seed coat), cotyledons, first pinnate leaf
local stok = { r = { name = "stem" } }
local sp = { { 41, 41 }, { 40, 36 }, { 41, 31 }, { 40, 27 } }
local sm, sn = G.tube(sp, function(t) return 1.05 end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function oval_leaf(ax, ay, cx, cy, bx, by, W, fold)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, W * sin(pi * min(1, t * 0.88 + 0.1)) ^ 0.55)
  end, { fold = fold or 0.3 })
  return m, n, T, S
end
local function paint_leaf(m, n, T, S, cut)
  if cut then m:cut(cut) end
  G.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.16 and T[k] > 0.12 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
-- rounded cotyledons (fleshy, wider)
local c1m, c1n, c1T, c1S = oval_leaf(40, 34, 36, 33, 32, 30, 2.3, 0.2)
local c2m, c2n, c2T, c2S = oval_leaf(41, 34, 45, 33, 49, 30, 2.3, 0.2)
paint_leaf(c1m, c1n, c1T, c1S, sm) paint_leaf(c2m, c2n, c2T, c2S, sm)
-- rachis + three pairs of smooth oval leaflets (even-pinnate)
local rach = { { 40, 27 }, { 40, 22 }, { 41, 18 }, { 42, 14 } }
local all = HP.mask()
local pairs_ = { { 0.22, 6.2, 1.3 }, { 0.58, 5.8, 1.2 }, { 0.95, 4.4, 0.75 } }
local leaves = {}
for _, q in ipairs(pairs_) do
  local x, y = G.bez(rach, q[1])
  for _, side in ipairs{ -1, 1 } do
    local ux, uy = G.rot(0, -1, side * q[3])
    local bx, by = x + ux * q[2], y + uy * q[2]
    local mx, my = x + ux * q[2] * 0.5 - side * 0.3, y + uy * q[2] * 0.5 - 0.6
    local m, n, T, S = oval_leaf(x + ux * 0.8, y + uy * 0.8, mx, my, bx, by, 1.55, 0.35)
    m:cut(all)
    leaves[#leaves + 1] = { m, n, T, S }
    all:add(m)
  end
end
for _, L in ipairs(leaves) do paint_leaf(L[1], L[2], L[3], L[4], c1m) end
for i = 0, 30 do local x, y = G.bez(rach, i / 30) c:put(floor(x + .5), floor(y + .5), i < 6 and STEM[2] or STEM[3], stok) end
-- AO where each leaflet meets the rachis
for i = 1, #pairs_ do local x, y = G.bez(rach, pairs_[i][1]) c:put(floor(x + .5) + 1, floor(y + .5), LEAF[2], ltok) end

-- seeds last: glossy flat ovals, dark ridge line, AO between neighbours, one glint each
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = X.tone(c, vis, X.light(s.n, { amb = 0.1, wrap = 0.3 }), SEED, { cuts = CUTS, bias = sb, tok = tok })
  local ca, sa = cos(s[5]), sin(s[5])
  -- ridge line along the long axis, slightly toward the shade side
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    if abs(v - 0.18) < 0.16 and abs(u) < 0.62 then c:put(x, y, SEED[max(1, idx[k] - 2)], tok) end
  end)
  local gx, gy = G.specAt(vis, s.n, 30)
  if gx then c:put(gx, gy, "#fff1cf", tok) if vis:has(gx + 1, gy) then c:put(gx + 1, gy, SEED[6], tok) end end
end
G.save2(c, NAME)
