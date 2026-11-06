-- red-hot-poker-seed (final, Sonnet high, D12-1). A torn scrap of glaucous red-hot-poker (Kniphofia) strap leaf lying on
-- a slant: keeled midrib, fine parallel veins, ragged torn ends, cool reflected edge, waxy bloom. Four small angular
-- dark-brown wedge seeds (two facets, amber glint, pale hilum tip) lie on it with contact shadows; a fifth has
-- germinated: a pale sheath foot and three narrow keeled strap blades arching out like a tiny grass tuft.
-- quirk: the tallest blade tip glows ember-orange like a lit match head, with one rising spark.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_1.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("red-hot-poker-seed")
local LEAF = { "#14363a", "#205852", "#32806e", "#52a088", "#82c2a0", "#c0e4c2" }
local COOL, FIBRE, BLOOM = "#3a6a82", "#e0f0d0", "#a8d0bc"
local SEED = { "#1a0f12", "#331e1a", "#51312a", "#744a30", "#9c6c3e", "#cc9a52" }
local EMBER = { "#7a1f1c", "#c03a1e", "#ee6a1c", "#fba02a", "#ffd25a", "#fff0a8" }
local STEM = { "#7a9a4a", "#a8c670", "#cde495", "#eef6c4" }
local ltok = { r = { name = "leaf" } }
local cap = HP.mask() cap:add(c:rect(0, 0, 63, 63))

-- seeds (cx, cy, ang, scale)
local seeds = {
  { 14, 54, 0.45, 1.0 }, { 23, 56, -0.3, 1.0 }, { 30, 53, 2.6, 1.0 }, { 20, 49, 1.2, 0.95 },
}
local sprout = { 41, 51, 0.2 }
local VERTS = {}
for _, v in ipairs{ { -3.4, 0.2 }, { -1.2, -2.3 }, { 2.6, -2.0 }, { 3.4, 0.4 }, { 2.4, 2.3 }, { -1.0, 2.2 } } do VERTS[#VERTS + 1] = { v[1] * 1.25, v[2] * 1.25 } end
for _, s in ipairs(seeds) do s.m, s.n = A.facet(s[1], s[2], s[3], VERTS, 0.6, 2.0) end
sprout.m, sprout.n = A.facet(sprout[1], sprout[2], sprout[3], VERTS, 0.6, 2.0)

-- leaf scrap: slanted strap, jagged torn ends, torn lower edge
local HW = 6.4
local function wfn(t)
  if t < 0.02 or t > 0.985 then return -1 end
  local w = HW * (1 - 0.18 * t)
  if t < 0.12 then w = w * (0.5 + 0.5 * A.noise1(t * 40, 11)) * (0.55 + t * 3.6) end
  if t > 0.86 then w = w * (0.35 + 0.65 * A.noise1(t * 40, 5)) * (1 - (t - 0.86) * 3.2) end
  return max(0.5, w)
end
local bias = {}
local all = { sprout }
for _, s in ipairs(seeds) do all[#all + 1] = s end
for _, s in ipairs(all) do X.ao(bias, cap, s.m, 1, -1) G.cast(bias, cap, s.m, 1, 2, -1) end
local lm, ln, LT, LS, len, torn = A.tornBlade(c, 8, 50, 26, 58, 56, 52, wfn, {
  ramp = LEAF, veins = {}, rib = 0.1, ribEnd = 0.9, fibre = FIBRE, cool = COOL, bias = bias, fold = 0.5,
  tear = { [1] = { depth = 0.38, t0 = 0.12, t1 = 0.88 }, [-1] = { depth = 0.22, t0 = 0.2, t1 = 0.8 } } })
-- parallel veins + waxy bloom
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s, t = LS[k], LT[k]
  if t > 0.06 and t < 0.92 then
    for _, s0 in ipairs{ -0.62, -0.34, 0.3, 0.58 } do
      if abs(s - s0) < 0.075 then c:put(x, y, s0 < 0 and LEAF[5] or LEAF[2], ltok) end
    end
    if abs(s) > 0.15 and abs(s) < 0.85 and A.noise1(x * 0.9 + y * 0.4, 4) > 0.8 and X.hash(x, y, 31) > 0.5 then c:put(x, y, BLOOM, ltok) end
  end
end)

-- sprout: sheath foot + three keeled strap blades
local sx, sy = sprout[1], sprout[2]
local function strap(ax, ay, cx, cy, bx, by, w0, hot)
  local m, n, T, S = A.tornBlade(c, ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    local w = w0 * (1 - t ^ 1.6 * 0.82) + 0.35
    return w
  end, { ramp = LEAF, veins = {}, rib = 0.2, ribEnd = 0.97, cool = COOL, fold = 0.7, amb = 0.12 })
  return m, T, S
end
local sheath, shn = G.tube({ { sx, sy }, { sx, sy - 2 }, { sx + 0.5, sy - 4 }, { sx + 0.5, sy - 6 } }, function(t) return 1.7 - t * 0.5 end)
sheath:cut(sprout.m)
A.shade(c, sheath, shn, STEM, { cuts = { 0.3, 0.55, 0.8 } })
local b1 = strap(sx - 1, sy - 4, sx - 7, sy - 27, sx - 21, sy - 30, 1.6)
local b2 = strap(sx + 1, sy - 4, sx + 6, sy - 24, sx + 19, sy - 24, 1.5)
local bc, bT = strap(sx, sy - 5, sx - 4, sy - 22, sx + 3, sy - 37, 1.8)
-- ember tip on the tallest blade (quirk)
do
  local pts = {}
  bc:each(function(x, y) local k = K(x, y) if bT[k] > 0.9 then pts[#pts + 1] = { x, y, bT[k] } end end)
  for _, p in ipairs(pts) do
    local d = (p[3] - 0.9) / 0.1
    c:put(p[1], p[2], d > 0.6 and EMBER[6] or (d > 0.25 and EMBER[5] or EMBER[4]), ltok)
  end
  -- ember colour creeping down the edge
  bc:each(function(x, y) local k = K(x, y) if bT[k] > 0.82 and bT[k] <= 0.9 then c:put(x, y, (x + y) % 2 == 0 and EMBER[3] or LEAF[3], ltok) end end)
  local tx, ty
  local best = 1e9
  for _, p in ipairs(pts) do if p[2] < best then best, tx, ty = p[2], p[1], p[2] end end
  if tx then c:put(tx, ty - 2, EMBER[5]) c:put(tx + 2, ty - 4, EMBER[3]) end
end

-- seeds, back to front
local function paintSeed(s, vis, sb)
  local tok = { r = { name = "seed" } }
  A.shade(c, vis, s.n, SEED, { cuts = { 0.3, 0.5, 0.68, 0.84, 0.95 }, bias = sb, tok = tok, amb = 0.06, wrap = 0.15 })
  local sx0, sy0 = A.specAt(vis, s.n, 24)
  if sx0 then c:put(sx0, sy0, SEED[6], tok) c:put(sx0 + 1, sy0, SEED[5], tok) end
  -- pale hilum at the narrow tip
  local ca, sa = cos(s[3]), sin(s[3])
  local hx, hy = floor(s[1] - 4.5 * ca + .5), floor(s[2] - 4.5 * sa + .5)
  if vis:has(hx, hy) then c:put(hx, hy, "#d8b888", tok) end
end
local order = {}
for _, s in ipairs(all) do order[#order + 1] = s end
table.sort(order, function(a, b) return a[2] < b[2] end)
for i, s in ipairs(order) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #order do vis:cut(order[j].m) X.ao(sb, s.m, order[j].m, 1, -1) end
  paintSeed(s, vis, sb)
end
-- split coat on the sprouting seed: pale sheath pokes out
c:put(sx - 1, sy - 1, SEED[1]) c:put(sx, sy - 1, STEM[1]) c:put(sx + 1, sy - 1, SEED[1])
A.save(c, "red-hot-poker-seed")
