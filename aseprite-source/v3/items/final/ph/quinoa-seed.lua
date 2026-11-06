-- quinoa-seed (final, Sonnet high). A torn diamond goosefoot leaf scrap standing on its tip (toothed right margin, ragged
-- torn left edge with a pale fibre rim, midrib + swept veins, mealy bloom). A loose heap of flat cream quinoa discs with
-- a pale equatorial rim, two with a germ ring tail, each casting a contact shadow on the leaf. One seed has sprouted: a
-- rose-pink hypocotyl, two narrow cotyledons and the first diamond-shaped, toothed true leaves with mealy dust.
-- quirk: the empty seed coat is still perched on a cotyledon tip like a little hat.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_0.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("quinoa-seed")
local LEAF = { "#1f3b3a", "#2e5d48", "#437f53", "#62a05f", "#8fc072", "#c3de9c" }
local MEAL = "#e2f2d6"
local ROSE = { "#4a1830", "#7e2c50", "#ac4864", "#d46c82", "#f09aa6", "#ffc8c8" }
local CREAM = { "#6b5a4e", "#968068", "#c0a984", "#e2d0a6", "#f6e8c4", "#fffaf0" }
local ltok = { r = { name = "leaf" } }

-- seeds: cx, cy, rx, ry, ang
local seeds = {
  { 23, 51, 2.7, 2.0, 0.1 }, { 29, 52, 2.7, 2.0, -0.2 }, { 34, 52, 2.7, 2.0, 0.25 },
  { 20, 46, 2.7, 2.0, -0.3 }, { 26, 47, 2.7, 2.0, 0.2 }, { 32, 46, 2.7, 2.0, -0.1 },
  { 23, 42, 2.6, 1.9, 0.4 }, { 29, 42, 2.6, 1.9, -0.25 },
  { 43, 44, 2.6, 2.0, -0.35 },
}
local spr = { 40, 48, 3.0, 2.2, 0.15 }   -- the sprouting seed, drawn separately (its coat is split)
local all = {}
for i, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.8) all[#all + 1] = s end
spr.m, spr.n = G.oval(spr[1], spr[2], spr[3], spr[4], spr[5], 0.8)
all[#all + 1] = spr
local sm = HP.mask() for _, s in ipairs(all) do sm:add(s.m) end

-- leaf scrap: diamond with teeth, standing on its tip
local len0 = 28
local function sw(t)
  if t < 0.04 then return 0.6 end
  local u = t
  local w = 14.5 * (1 - abs((u - 0.46) / (u < 0.46 and 0.46 or 0.54))) ^ 0.9
  local saw = ((t * len0 / 4.2) % 1) < 0.5 and 1.4 or 0
  if t > 0.14 and t < 0.92 then w = w + saw end
  return max(0.5, w)
end
local bias = {}
for _, s in ipairs(all) do X.ao(bias, HP.mask():add(c:rect(0, 0, 63, 63)), s.m, 1, -1) G.cast(bias, HP.mask():add(c:rect(0, 0, 63, 63)), s.m, 1, 2, -1) end
local lm, ln, LT, LS, len, torn = A.tornBlade(c, 31, 58, 29, 44, 34, 30, sw, {
  ramp = LEAF, veins = { 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8 }, sweep = 3.2, rib = 0.1, ribEnd = 0.95, fibre = "#e4eec8", cool = "#3b6d78",
  bias = bias, veinMax = 0.85, fold = 0.5,
  tear = { [-1] = { depth = 0.55, t0 = 0.3, t1 = 0.85 } } })
lm:each(function(x, y) local k = K(x, y)
  if not bias[k] and LT[k] > 0.2 and abs(LS[k]) < 0.9 and X.hash(x, y, 71) > 0.88 then c:put(x, y, MEAL, ltok) end end)

-- sprout: rose hypocotyl, cotyledons, true leaves
local hm, hT, hS = A.stem(c, { { 40, 47 }, { 38, 41 }, { 39, 34 }, { 38, 27 } }, 1.2, 0.95, ROSE, { 0.22, 0.4, 0.58, 0.78, 0.9 })
local function cot(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.tornBlade(c, ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.55)
  end, { ramp = LEAF, veins = {}, rib = 0.15, cool = "#3b6d78", fold = 0.35 })
  -- reddish blush at the base
  m:each(function(x, y) local k = K(x, y) if T[k] < 0.12 and abs(S[k]) < 0.5 then c:put(x, y, S[k] < 0 and ROSE[4] or ROSE[3], ltok) end end)
  return m
end
local cl = cot(38, 27, 33, 23, 26, 23.5, 2.1)
local cr = cot(38, 27, 43, 22, 50, 21.5, 2.1)
A.stem(c, { { 38, 27 }, { 38, 23 }, { 38, 19 }, { 38, 16 } }, 0.85, 0.7, ROSE, { 0.3, 0.55, 0.8 })
local function dleaf(ax, ay, cx, cy, bx, by, w, veins)
  local bl = sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
  local m, n, T, S, ll = A.tornBlade(c, ax, ay, cx, cy, bx, by, function(t)
    if t < 0.15 then return 0.55 end
    local u = (t - 0.15) / 0.85
    local ww = w * (1 - abs((u - 0.4) / (u < 0.4 and 0.4 or 0.6))) ^ 0.85
    if u > 0.2 and u < 0.8 and ((t * bl * 1.05 / 3.0) % 1) < 0.5 then ww = ww + 0.8 end
    return max(0.5, ww)
  end, { ramp = LEAF, veins = veins, sweep = 1.8, rib = 0.17, cool = "#3b6d78", fold = 0.45 })
  m:each(function(x, y) local k = K(x, y) if T[k] > 0.3 and abs(S[k]) < 0.8 and X.hash(x, y, 72) > 0.86 then c:put(x, y, MEAL, ltok) end end)
  return m
end
dleaf(38, 17, 43, 11, 51, 10, 4.3, { 0.5, 0.64, 0.78 })
dleaf(37, 18, 33, 13, 27, 13, 3.4, { 0.55, 0.7 })

-- seeds back to front
table.sort(all, function(a, b) return a[2] < b[2] end)
local function seedPaint(s, vis, sb)
  local tok = { r = { name = "seed" } }
  G.toneN(c, vis, s.n, CREAM, { cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias = sb, tok = tok, amb = 0.06, wrap = 0.2 })
  -- equatorial rim: lit upper-left edge, shaded lower-right edge, a faint ring just inside
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    local q = u * u + v * v
    if q > 0.62 then
      local lit = (u * -0.55 + v * -0.7) > 0.25
      local shade = (u * 0.55 + v * 0.7) > 0.3
      if lit then c:put(x, y, CREAM[6], tok) elseif shade then c:put(x, y, CREAM[2], tok) end
    elseif q > 0.3 and q <= 0.62 and (u * 0.55 + v * 0.7) > 0.2 then c:put(x, y, CREAM[3], tok) end
  end)
end
for i, s in ipairs(all) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #all do vis:cut(all[j].m) X.ao(sb, s.m, all[j].m, 1, -1) end
  seedPaint(s, vis, sb)
end
-- split coat on the sprouting seed: dark gap where the hypocotyl leaves
for _, q in ipairs{ { 39, 46 }, { 40, 46 }, { 41, 46 } } do c:put(q[1], q[2], CREAM[1]) end
c:put(39, 47, ROSE[2]) c:put(40, 47, ROSE[3]) c:put(41, 47, ROSE[2])
-- germ ring tails on two seeds
for _, q in ipairs{ { 24, 57, 4 }, { 25, 58, 3 }, { 26, 58, 3 }, { 34, 56, 4 }, { 35, 57, 4 }, { 36, 57, 3 } } do end
A.pline(c, { { 31, 54 }, { 32, 55 }, { 33, 55 } }, CREAM[5])
A.pline(c, { { 17, 47 }, { 16, 48 }, { 16, 49 } }, CREAM[5])
-- quirk: the empty seed coat as a hat on the right cotyledon tip
local hat = { 50, 20, 2.3, 1.7, -0.5 }
hat.m, hat.n = G.oval(hat[1], hat[2], hat[3], hat[4], hat[5], 0.8)
local sbh = {}
seedPaint(hat, hat.m, sbh)
c:put(50, 21, CREAM[1])
A.save(c, "quinoa-seed")
