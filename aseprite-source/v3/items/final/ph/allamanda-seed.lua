-- allamanda-seed (final, Opus). Two flat allamanda seeds (brown oval body ringed by a broad golden papery wing,
-- tinted from the yellow trumpet flower) on a torn scrap of glossy allamanda leaf (elliptic, acuminate tip, midrib and
-- curved pinnate veins, waxy specular, cool reflected rim, ragged torn base). A third seed has sprouted: slim stem and
-- the first pair of opposite, pointed, glossy leaves with a tiny terminal bud.
-- quirk: a bead of white milky sap (allamanda latex) welling from a nick on the stem.
local NAME = "allamanda-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR1_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#123a30", "#1a5238", "#246c40", "#36894a", "#58aa52", "#8fcc66" }
local VEIN, COOL, GLOSS = "#b6dc84", "#3c7c86", "#e2f4b4"
local BODY = { "#3c2218", "#5a321e", "#7c4826", "#9e6232", "#c08446", "#e0ac6a" }
local WING = { "#7a5420", "#a8782c", "#cc9c3a", "#e8c058", "#f8de8a", "#fff0bc" }
local STEM = { "#3e7a48", "#68a456", "#98c870", "#cce69a" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- leaf scrap: broad ellipse, acuminate tip upper-left, torn across the base lower-right
local lm, ln, LT, LS, len = A.blade(56, 58, 32, 54, 7, 37, function(t)
  if t > 0.99 then return -1 end
  local u = min(1, t * 0.82 + 0.18)
  local w = 10.2 * sin(pi * u) ^ 0.75
  if t > 0.78 then w = w * (1 - (t - 0.78) / 0.22) ^ 0.55 end
  return max(0.4, w)
end, { fold = 0.36 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local d0 = LT[k] * len
  local j = 2.0 + 2.2 * abs(sin(LS[k] * 5.3 + 0.4)) + 1.6 * X.hash(x, y, 5) + LS[k] * 1.5
  if d0 < j then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- seeds: cx, cy, body rx, ry, angle
local seeds = { { 20, 45, 3.2, 2.0, -0.5 }, { 31, 51, 3.3, 2.1, 0.35 }, { 42, 49, 3.0, 1.9, -0.15 } }
for _, s in ipairs(seeds) do
  s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.6)
  s.wm, s.wn = A.oval(s[1] - 0.3, s[2] + 0.2, s[3] + 2.3, s[4] + 1.6, s[5], 0.35)
end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.wm, 1, -1) A.cast(bias, lm, s.wm, 1, 1, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.85 }, amb = 0.14, wrap = 0.28 })
-- midrib + curved secondary veins sweeping toward the tip
local PER = 6.2
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - (abs(s) ^ 0.8) * 7.5) / PER + (s > 0 and 0.45 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.84 and abs(s) > 0.12 and abs(s) < 0.8 and t > 0.08 and t < 0.86 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) end
end)
-- waxy gloss streak on the lit half, cool reflected rim lower-right
for _, p in ipairs{ {16, 39}, {17, 39}, {18, 40}, {14, 40} } do if lm:has(p[1], p[2]) and not bias[K(p[1], p[2])] then c:put(p[1], p[2], GLOSS, ltok) end end
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LT[k] * len < 6 then c:put(x, y, (x + y) % 2 == 0 and LEAF[2] or "#c8e49a", ltok)
  elseif LS[k] > 0.72 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end
end)

-- sprout from the right seed: stem, then a pair of opposite leaves
local stok = { r = { name = "stem" } }
local sp = { { 42, 48 }, { 41, 40 }, { 43, 32 }, { 42, 24 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function pleaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.9 + 0.1)
    local ww = w * sin(pi * u ^ 0.9) ^ 0.7
    if t > 0.75 then ww = ww * (1 - (t - 0.75) / 0.25) ^ 0.6 end
    return max(0.3, ww)
  end, { fold = 0.34 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.14 and T[k] > 0.06 and T[k] < 0.86 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  local gx, gy = A.specAt(m, n, 40)
  c:put(gx, gy, GLOSS, ltok)
  return m
end
pleaf(41, 25, 33, 20, 25, 20, 3.3)
pleaf(43, 25, 49, 18, 56, 18, 3.2)
-- terminal bud between the pair, AO at the node
c:paint({ ".b.", "bBb", ".n." }, 41, 20, { b = STEM[3], B = STEM[4], n = STEM[1] })
c:put(41, 25, STEM[1], stok) c:put(43, 25, STEM[1], stok)

-- seeds: golden papery wing (pillowed, veined radially), then the brown glossy body, AO body->wing
for i, s in ipairs(seeds) do
  local wtok = { r = { name = "wing" .. i } }
  local wm = s.wm:copy()
  if i == 3 then wm:cut(sm) end
  local wb = {}
  X.ao(wb, wm, s.m, 1, -1)
  if i == 3 then X.ao(wb, wm, sm, 1, -1) end
  A.toneN(c, wm, s.wn, WING, { tok = wtok, bias = wb, cuts = { 0.2, 0.38, 0.55, 0.72, 0.92 }, amb = 0.12, wrap = 0.3 })
  -- radial wrinkles in the wing
  wm:each(function(x, y) local k = K(x, y)
    if s.m:has(x, y) then return end
    local a = math.atan(y - s[2], x - s[1])
    if abs(sin(a * 4.5 + i)) < 0.12 then c:put(x, y, A.step(WING, c:get(x, y), -1), wtok) end
  end)
  local tok = { r = { name = "seed" .. i } }
  local body = s.m:copy()
  if i == 3 then body:cut(sm) end
  A.toneN(c, body, s.n, BODY, { tok = tok, cuts = { 0.18, 0.36, 0.54, 0.72, 0.9 }, amb = 0.08, wrap = 0.25 })
  local gx, gy = A.specAt(body, s.n, 40)
  c:put(gx, gy, "#f6dcae", tok)
end
-- stem foot over the sprouting seed
c:put(42, 48, STEM[2], stok) c:put(42, 47, STEM[3], stok) c:put(43, 48, STEM[1], stok)

-- quirk: a bead of milky latex on a nick in the stem
c:paint({ "nm.", ".SS", "SCCS", "SCcS", ".SS" }, 42, 31, { n = STEM[1], m = "#f4f0e2", S = "#d6d2c6", C = "#fbf8ec", c = "#bcb8ae" })

A.save(c, NAME)
