-- golden-wattle-seed (B3, Opus single pass). Three glossy black-brown wattle seeds, each wearing a folded
-- orange-gold aril cap, on a torn sickle-shaped blue-green phyllode scrap (midrib, faint parallel veins, V-fold
-- light, ragged torn base, AO + contact shadow under each seed). The right seed has sprouted: slim stem, two fleshy
-- cotyledons and the first feathery bipinnate wattle leaf.
-- quirk: an ant is hauling the left seed away by its aril.
local NAME = "golden-wattle-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#1b3b3c", "#275448", "#357055", "#4f905e", "#7bb172", "#b2d39a" }
local SEED = { "#1e1214", "#33201e", "#4b2f26", "#6a4430", "#8f6448", "#c7a07a" }
local ARIL = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local STEM = { "#4a7a50", "#7aa868", "#aed08a", "#def0b4" }

local seeds = { { 19, 50, 3.8, 2.2, -0.12 }, { 30, 48, 3.8, 2.2, -0.2 }, { 41, 45, 3.7, 2.2, -0.35 } }
local seedAll = HP.mask()
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) seedAll:add(s.m) end
-- aril caps at the +u end of each seed
for _, s in ipairs(seeds) do
  local ca, sa = cos(s[5]), sin(s[5])
  s.am, s.an = A.oval(s[1] - (s[3] + 0.6) * ca, s[2] - (s[3] + 0.6) * sa, 1.7, 1.9, s[5], 0.8)
  seedAll:add(s.am)
end

-- phyllode scrap: falcate blade, torn base
local lm, ln, LT, LS, len = A.blade(6, 55, 30, 54, 58, 41, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 6.4 * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.6)
end, { fold = 0.42 })
lm:cut(c:poly{ { 0, 40 }, { 9, 47 }, { 8, 50 }, { 11, 52 }, { 9, 54 }, { 12, 57 }, { 10, 59 }, { 12, 62 }, { 0, 63 } })
-- second small tear bite on the lower margin
lm:cut(c:poly{ { 33, 60 }, { 36, 55 }, { 38, 57 }, { 40, 54 }, { 43, 60 } })
local bias = {}
X.ao(bias, lm, seedAll, 1, -1)
A.cast(bias, lm, seedAll, 1, 2, -1)
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) if bias[k] then return end
  local s, t = LS[k], LT[k]
  if abs(s) < 0.14 and t < 0.95 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok)
  elseif abs(abs(s) - 0.55) < 0.09 and t > 0.2 and t < 0.85 then c:put(x, y, LEAF[min(6, (lidx[k] or 3) + (s < 0 and 1 or -1))], ltok) end end)
-- gland on the upper margin (wattle tell)
c:put(26, 49, LEAF[6], ltok)

-- sprout from the right seed
local stok = { r = { name = "stem" } }
local sm, sn = A.tube({ { 41, 43 }, { 41, 36 }, { 38, 30 }, { 39, 22 } }, function(t) return 1.0 end)
sm:cut(seedAll)
A.shade(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- cotyledons: fleshy oblongs
local cots = HP.mask()
for _, q in ipairs{ { 35, 25, -0.95, -0.32 }, { 43, 24, 0.95, -0.32 } } do
  local m, n = A.oval(q[1], q[2], 3.4, 1.6, math.atan(q[4], q[3]), 0.8)
  m:cut(sm) cots:add(m)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
end
-- true leaf: bipinnate. rachis up-right, pinnae combed with leaflets
local rach = { { 39, 22 }, { 40, 17 }, { 43, 13 }, { 47, 11 } }
local function pt(x, y, col) if not cots:has(x, y) then c:put(x, y, col, ltok) end end
for i = 0, 20 do local x, y = A.bez(rach, i / 20) pt(floor(x + .5), floor(y + .5), STEM[2]) end
local function pinna(x0, y0, dx, dy, n)
  for j = 1, n do
    local x, y = floor(x0 + dx * j + .5), floor(y0 + dy * j + .5)
    pt(x, y, LEAF[3])
    -- leaflets either side (perpendicular), lit side paler
    local px, py = (dy > 0.5 or dy < -0.5) and 1 or 0, (dy > 0.5 or dy < -0.5) and 0 or 1
    if j % 1 == 0 then pt(x - px, y - py, LEAF[5]) pt(x + px, y + py, LEAF[2]) end
  end
end
pinna(40, 18, -1, -0.6, 5)
pinna(41, 15, 0.9, 0.55, 5)
pinna(43, 13, -0.55, -1, 3)
pinna(46, 11, 1, -0.2, 4)
pt(47, 10, LEAF[6])

-- seeds + arils
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = A.toneN(c, s.m, s.n, SEED, { tok = tok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }, amb = 0.08, wrap = 0.25 })
  local sx, sy = A.specAt(s.m, s.n, 40)
  c:put(sx, sy, "#fff4d6", tok) c:put(sx + 1, sy, SEED[6], tok)
  -- hilum line along the back
  local am = s.am:copy():cut(s.m)
  A.toneN(c, am, s.an, ARIL, { tok = tok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
end
-- quirk: ant tugging the left seed's aril (to the left of it)
local ant = { r = { name = "ant" } }
local ax, ay = seeds[1][1] - 9, seeds[1][2] - 1
for _, q in ipairs{ { 0, 0, "#9a3a28" }, { 1, 0, "#6a2420" }, { -1, 0, "#6a2420" }, { -2, 0, "#8a3224" }, { -3, 0, "#6a2420" }, { -3, -1, "#c2603e" },
    { 1, -1, "#c2603e" }, { 2, -1, "#9a3a28" }, { 3, 0, "#9a3a28" }, { 2, 0, "#6a2420" } } do c:put(ax + q[1], ay + q[2], q[3], ant) end
A.save(c, NAME)
