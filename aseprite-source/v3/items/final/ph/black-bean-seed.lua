-- black-bean-seed (final, Opus aR20_2). Glossy black kidney beans (violet-black sphere light, cream specular,
-- white hilum eye, AO + contact shadow) on a torn scrap of an ovate, pointed bean leaflet (V-fold light, midrib
-- and swept veins, jagged torn base, cool reflected edge). The right bean has germinated: a pale hypocotyl,
-- two thick fleshy cotyledons split from the bean, and the first pair of pointed heart-shaped bean leaves.
-- quirk: the split black seed coat is still perched on the shoot tip like a little hat.
local NAME = "black-bean-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = A.new(NAME)
local LEAF = { "#163a30", "#1f5638", "#2c7440", "#46944a", "#6eb656", "#a4d474" }
local LEAF2 = { "#1a4a34", "#27663c", "#3a8646", "#5aa650", "#88c660", "#bce284" }
local BK = { "#130d18", "#211727", "#33253c", "#4a3a58", "#6a5a80", "#9e8cb8" }
local COTY = { "#4a5a2a", "#76863a", "#a0b052", "#c4cc74", "#e0e49a", "#f4f4c8" }
local STEM = { "#5a7a48", "#8aae6a", "#b8d692", "#e2f0c0" }
local COOL, HIL, HILD = "#3a6c72", "#f0eadc", "#b8aca0"
local BCOOL = "#3e4a6c"

-- leaf scrap: ovate leaflet, pointed tip right, torn base left
local lm, ln, LT, LS, len = A.blade(6, 50, 30, 41, 57, 47, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 9.4 * sin(pi * min(1, t * 0.82 + 0.18)) ^ 0.8)
end, { fold = 0.35 })
A.tear(lm, 13, 62, 9, 36, 1.8, 4)

-- beans: cx, cy, rx, ry, angle
local beans = { { 21, 47, 5.2, 3.4, 0.2 }, { 33, 49, 5.4, 3.5, -0.15 }, { 45, 44, 5.0, 3.3, -0.5, sprout = true } }
for _, b in ipairs(beans) do
  local m, n = A.oval(b[1], b[2], b[3], b[4], b[5], 0.75)
  local ca, sa = cos(b[5]), sin(b[5])
  m:cut(A.rell(b[1] - sa * (b[4] + 1.5), b[2] + ca * (b[4] + 1.5), ca, sa, 2.4, 1.4))
  b.m, b.n = m, n
end
-- the sprouting bean is split open: its top half is gone (cotyledons spread from it)
local sb = beans[3]
local bias = {}
for _, b in ipairs(beans) do X.ao(bias, lm, b.m, 1, -1) A.cast(bias, lm, b.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.tone(c, lm, ln, LEAF, { bias = bias, tok = ltok, amb = 0.18, wrap = 0.3, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 } })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 and t < 0.92 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  for _, vt in ipairs{ 0.22, 0.4, 0.58, 0.74 } do
    local d = t * len - (vt * len + abs(s) * 5.5)
    if d > -0.5 and d < 0.5 and abs(s) > 0.18 and abs(s) < 0.8 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and LS[k] > 0.6 and LT[k] > 0.15 then c:put(x, y, COOL, ltok) end end)

-- hypocotyl: rises out of the bean, leans left, ends in the leaf pair
local stok = { r = { name = "stem" } }
local sp = { { 45, 42 }, { 46, 34 }, { 40, 28 }, { 39, 19 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 1.35 - t * 0.3 end)
A.tone(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- primary leaves: two pointed hearts on short petioles
local ptok = { r = { name = "pleaf" } }
local function pleaf(bx, by, cx, cy, tx, ty, w)
  local m, n, T, S, L = A.blade(bx, by, cx, cy, tx, ty, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.9 + 0.1)
    return max(0.4, w * sin(pi * u ^ 0.75) ^ 0.7)
  end, { fold = 0.42 })
  m:cut(sm)
  local idx = A.tone(c, m, n, LEAF2, { tok = ptok, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.15 and T[k] > 0.05 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and LEAF2[6] or LEAF2[3], ptok) end
    local d = T[k] * L - (0.45 * L + abs(S[k]) * 3)
    if d > -0.5 and d < 0.5 and abs(S[k]) > 0.25 and abs(S[k]) < 0.75 then c:put(x, y, S[k] < 0 and LEAF2[5] or LEAF2[2], ptok) end
  end)
  return m
end
local pl = pleaf(38, 19, 31, 18, 22, 11, 4.6)
local pr = pleaf(40, 19, 47, 16, 55, 10, 4.6)

-- cotyledons: two thick bean halves opening at the stem's knee
local ctok = { r = { name = "coty" } }
local cots = HP.mask()
for _, q in ipairs{ { 41.5, 33, 3.6, 2.4, 0.5 }, { 49, 32, 3.6, 2.4, -0.55 } } do
  local m, n = A.oval(q[1], q[2], q[3], q[4], q[5], 0.7)
  m:cut(sm)
  local cb = {}
  X.ao(cb, m, sm, 1, -1)
  local idx = A.tone(c, m, n, COTY, { tok = ctok, bias = cb, amb = 0.1, wrap = 0.3 })
  -- flat inner face: one darker line along the split
  local ca, sa = cos(q[5]), sin(q[5])
  for u = -2, 2 do local x, y = floor(q[1] + u * ca + sa * 1.2 + .5), floor(q[2] + u * sa - ca * 1.2 + .5)
    if m:has(x, y) then c:put(x, y, COTY[3], ctok) end end
  cots:add(m)
end

-- beans last
for i, b in ipairs(beans) do
  local tok = { r = { name = "bean" .. i } }
  local bb = {}
  if b.sprout then X.ao(bb, b.m, sm, 1, -1) end
  local vis = b.m:copy()
  if b.sprout then vis:cut(sm:copy():clip(c:rect(0, 0, 63, floor(b[2] - 2)))) end
  A.tone(c, vis, b.n, BK, { tok = tok, bias = bb, amb = 0.02, wrap = 0.15, cuts = { 0.3, 0.52, 0.7, 0.84, 0.94 } })
  local rim = X.rim(b.n)
  vis:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.72 and not bb[k] then c:put(x, y, BCOOL, tok) end end)
  local sx, sy = floor(b[1] - b[3] * 0.4 + .5), floor(b[2] - b[4] * 0.45 + .5)
  if vis:has(sx, sy) then c:put(sx, sy, A.CREAM, tok) c:put(sx + 1, sy, BK[6], tok) c:put(sx, sy + 1, BK[5], tok) end
  local ca, sa = cos(b[5]), sin(b[5])
  local hv = b[4] - 2.2
  local hx, hy = b[1] - sa * hv, b[2] + ca * hv
  local hm = A.rell(hx + 0.5, hy, ca, sa, 1.8, 0.8)
  hm:clip(vis)
  hm:each(function(x, y) c:put(x, y, HIL, tok) end)
  for u = -1, 1 do local x, y = floor(hx + u * ca + 1), floor(hy + u * sa + .5) if hm:has(x, y) then c:put(x, y, HILD, tok) end end
end
-- the bean's split: a pale crack where the coat opened round the shoot
for _, d in ipairs{ { -2, -3 }, { -1, -3 }, { 2, -3 } } do
  local x, y = floor(sb[1] + d[1] + .5), floor(sb[2] + d[2] + .5)
  if sb.m:has(x, y) and not sm:has(x, y) then c:put(x, y, COTY[4], { r = { name = "crack" } }) end
end

-- quirk: the black seed coat cap perched on the shoot tip
local hat = A.rell(39, 17, 1, 0, 3.2, 2.0)
hat:cut(c:rect(0, 18, 63, 63))
local htok = { r = { name = "hat" } }
A.tone(c, hat, X.pillow(hat, 1.4), BK, { tok = htok, amb = 0.05, wrap = 0.2 })
c:put(37, 15, A.CREAM, htok) c:put(38, 15, BK[6], htok)
-- frayed lower rim of the cap
c:put(36, 17, BK[3], htok) c:put(41, 17, BK[2], htok)
A.fin(c, NAME)
