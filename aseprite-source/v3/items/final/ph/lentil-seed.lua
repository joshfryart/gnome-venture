-- lentil-seed (final, Opus single pass). Three lens-shaped lentils (flat biconvex discs, khaki-brown, speckled, keel rim)
-- lie on a torn, bluish lentil-leaf scrap laid flat (midrib, pinnate veins, pale torn fibres on the left).
-- The middle lentil has germinated: a slim stem rising to a pinnate lentil leaf (three pairs of small oval leaflets)
-- ending in a curled tendril. quirk: the right lentil is a split red lentil half, orange face up.
local NAME = "lentil-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min = math.floor, math.abs, math.sin, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#173a37", "#235442", "#33704f", "#4b8f5c", "#71ad6c", "#a6cf8e" }
local TORN = "#cfe6a8"
local SEED = { "#3a2a1e", "#5c4429", "#806338", "#a6874c", "#c7aa66", "#e6d095" }
local RED = { "#6e2a24", "#a8402a", "#d8622e", "#f08a3c", "#ffb25c", "#ffd99c" }
local STEM = { "#3f7a4e", "#68a35e", "#9ccc7c", "#d4ecaa" }

-- leaf scrap: broad blade, gently arched, lying across the bottom; torn at the left end
local lm, ln, LT, LS, len = A.blade(6, 50, 32, 41, 58, 47, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 8.2 * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.75)
end, { fold = 0.35 })
local tornE = A.tear(lm, LT, LS, 0.1, 0.09, 4)

-- seeds (cx, cy, rx, ry, ang)
local S1 = { 21, 45, 4.2, 3.0, -0.25 }
local S2 = { 32, 42, 4.4, 2.6, 0.1 }
local S3 = { 44, 44, 4.0, 3.0, 0.3 }
local sm = {}
for i, s in ipairs{ S1, S2, S3 } do sm[i] = A.oval(s[1], s[2], s[3], s[4], s[5], 0.5) end
local bias = {}
for i = 1, 3 do X.ao(bias, lm, sm[i], 1, -1) A.cast(bias, lm, sm[i], 1, 2, -1) end
A.toneN(c, lm, ln, LEAF, { bias = bias, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
A.veins(c, lm, LT, LS, len, LEAF, { skip = bias, per = 5, sweep = 4, ribLit = LEAF[6] })
tornE:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, TORN) end end)
-- cool reflected light along the lower (shade) rim
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.2 and LT[k] < 0.9 then c:put(x, y, "#3c6f7a") end end)

-- sprout from the middle seed: slim stem, pinnate leaf with tendril (drawn before seed so coat overlaps the foot)
local sp = { { 33, 41 }, { 34, 32 }, { 30, 24 }, { 32, 14 } }
local stm, stn = A.tube(sp, function(t) return 1.05 - t * 0.35 end)
stm:cut(sm[2])
X.tone(c, stm, X.light(stn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 } })
-- leaflet pairs along the upper stem
local pairs_ = { { 0.42, 4.0, 1.9 }, { 0.62, 3.7, 1.8 }, { 0.8, 3.2, 1.6 } }
local lfm = HP.mask()
for _, q in ipairs(pairs_) do
  local x, y = A.bez(sp, q[1])
  for _, side in ipairs{ -1, 1 } do
    local ux, uy = A.rot(0, -1, side * 1.05)
    local cx, cy = x + ux * (q[2] + 0.6), y + uy * (q[2] + 0.6)
    lfm:add(A.leaflet(c, cx, cy, ux, uy, q[2], q[3], LEAF, { cut = stm }))
  end
end
-- stem drawn again over leaflet bases
stm:each(function(x, y) if lfm:has(x, y) then c:put(x, y, STEM[2]) end end)
-- tendril curl at the tip
A.pline(c, { { 32, 14 }, { 32.5, 11 }, { 34, 9 }, { 36, 9 }, { 37, 10.5 }, { 36, 12 }, { 35, 11 } }, STEM[3])

-- seeds
A.lens(c, S1[1], S1[2], S1[3], S1[4], S1[5], SEED, { speck = 0.14, seed = 1 })
local m2 = A.lens(c, S2[1], S2[2], S2[3], S2[4], S2[5], SEED, { speck = 0.14, seed = 2 })
-- split coat where the sprout emerges: pale crack on top of the middle seed
for _, p in ipairs{ { 33, 40 }, { 34, 40 }, { 32, 40 } } do if m2:has(p[1], p[2]) then c:put(p[1], p[2], STEM[3]) end end
-- quirk: split red lentil half, flat orange face with a pale germ notch
local m3, n3 = A.oval(S3[1], S3[2], S3[3], S3[4], S3[5], 1.4)
A.toneN(c, m3, n3, RED, { cuts = A.CUTS, amb = 0.15, wrap = 0.35 })
m3:edge():each(function(x, y) if (x - S3[1]) + (y - S3[2]) > 0 then c:put(x, y, RED[2]) else c:put(x, y, RED[4]) end end)
c:put(S3[1] - 2, S3[2] - 1, RED[6]) c:put(S3[1] - 1, S3[2] - 1, RED[6])
c:put(S3[1] + 2, S3[2] + 1, RED[5])
-- glint on the front lentil
c:put(S1[1] - 2, S1[2] - 1, A.CREAM)

A.save(c, NAME)
