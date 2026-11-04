-- lettuce-seed (final, Opus single pass). Slender ribbed lettuce achenes (pale grey-cream, pointed, 6-7 ribs read as
-- 2 dark grooves) on a torn, ruffled lime lettuce-leaf scrap (scalloped wavy margin, fat pale midrib, veins).
-- The left seed has sprouted: pale stem, two round-spoon cotyledons and a first frilly true leaf.
-- quirk: one seed still wears its pappus, a tiny cream parachute on a thin beak.
local NAME = "lettuce-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#1f4a2c", "#2f6a32", "#4a8c36", "#6eae3e", "#9ccd52", "#d2ea86" }
local RIB = "#e6f4b4"
local TORN = "#eef7c4"
local SEED = { "#40362e", "#665747", "#8f7f68", "#b4a68a", "#d6caaa", "#f2e9cc" }
local STEM = { "#5e9a4a", "#8ec45e", "#bfe08a", "#ecf7c6" }
local PAP = { "#b9ae98", "#e9dfc4", "#fff4d6" }

-- leaf scrap: ruffled lettuce leaf on a diagonal, base torn at lower right, tip upper left
local PER = 4.2
local lm, ln, LT, LS, len = A.blade(56, 51, 34, 52, 9, 37, function(t)
  if t > 0.985 then return -1 end
  local w = 7.6 * sin(pi * min(1, t * 0.78 + 0.22)) ^ 0.7
  return max(0.5, w)
end, { fold = 0.3 })
-- scalloped ruffle on the margin
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local ph = t * len / PER + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if t > 0.12 and abs(s) > 0.97 - (1 - f) ^ 2 * 0.3 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local tornE = A.tear(lm, LT, LS, 0.08, 0.1, 9)

-- seeds: slender ovals (cx, cy, rx, ry, ang)
local seeds = { { 22, 41, 4.6, 1.5, -0.55 }, { 31, 45, 4.8, 1.5, 0.15 }, { 41, 47, 4.6, 1.5, -0.35 } }
local sms = {}
for i, s in ipairs(seeds) do sms[i] = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end
local bias = {}
for i = 1, 3 do X.ao(bias, lm, sms[i], 1, -1) A.cast(bias, lm, sms[i], 1, 2, -1) end
-- pappus beak shadow
A.toneN(c, lm, ln, LEAF, { bias = bias, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.2, wrap = 0.3 })
A.veins(c, lm, LT, LS, len, LEAF, { skip = bias, per = 6, sweep = 5, rib = 0.17, ribLit = RIB })
-- crinkle: short pale blister marks between the veins
lm:each(function(x, y) local k = K(x, y)
  if not bias[k] and abs(LS[k]) > 0.3 and abs(LS[k]) < 0.8 and X.hash(x, y, 5) < 0.06 then
    c:put(x, y, LS[k] < 0 and LEAF[5] or LEAF[3]) end end)
tornE:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, TORN) end end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.15 then c:put(x, y, "#3f7a62") end end)

-- sprout from the left seed (drawn before seeds)
local sp = { { 20, 40 }, { 18, 32 }, { 22, 28 }, { 20, 22 } }
local stm, stn = A.tube(sp, function(t) return 1.1 - t * 0.3 end)
stm:cut(sms[1])
X.tone(c, stm, X.light(stn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 } })
-- cotyledons: round spoons
local cotL = A.leaflet(c, 14, 21, -0.85, -0.5, 4.4, 2.8, LEAF, { R = 2, ribTone = 6 })
local cotR = A.leaflet(c, 27, 20, 0.88, -0.45, 4.4, 2.8, LEAF, { R = 2, ribTone = 6 })
-- first true leaf: a small frilly lettuce leaf standing up between them
local tl, tn, TT, TS, tlen = A.blade(20, 22, 21, 17, 21, 12, function(t)
  if t > 0.98 then return -1 end
  local w = 2.8 * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.6
  return max(0.4, w + (t > 0.35 and 0.6 * sin(t * 22) or 0))
end, { fold = 0.25 })
tl:cut(cotL):cut(cotR)
A.toneN(c, tl, tn, LEAF, { cuts = A.CUTS, amb = 0.2, wrap = 0.3 })
tl:each(function(x, y) local k = K(x, y) if abs(TS[k]) < 0.2 and TT[k] < 0.8 then c:put(x, y, RIB) end end)
for _, p in ipairs{ { 20, 22 }, { 20, 23 } } do c:put(p[1], p[2], STEM[3]) end

-- quirk: pappus on the right seed: thin beak up and a little parachute of radiating cream bristles
local pb = A.pline(c, { { 44, 45 }, { 46, 40 }, { 47, 34 } }, SEED[5])
local tuft = { { 47, 33 }, { 45, 31 }, { 44, 30 }, { 49, 31 }, { 50, 30 }, { 46, 30 }, { 48, 30 }, { 47, 29 },
  { 43, 30 }, { 51, 30 }, { 44, 29 }, { 50, 29 } }
for i, p in ipairs(tuft) do c:put(p[1], p[2], i <= 2 and PAP[1] or (p[2] <= 29 and PAP[3] or PAP[2])) end
c:put(47, 33, PAP[1])
-- beak shadow on the leaf
for _, p in ipairs{ { 45, 46 }, { 46, 45 } } do if lm:has(p[1], p[2]) and not sms[3]:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[1]) end end

-- seeds: ribbed, pointed
for i, s in ipairs(seeds) do
  local m, n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.6)
  local vis = m:copy()
  local idx = A.toneN(c, vis, n, SEED, { cuts = A.CUTS, amb = 0.12, wrap = 0.3 })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local v = (-dx * sa + dy * ca) / (s[4] + .45)
    local j = idx[k]
    if abs(u) > 0.78 then j = j - 1 end                         -- pointed ends darker
    if v > 0.35 then j = min(j, 3) end                          -- groove / shade rib
    if v < -0.2 and abs(u) < 0.55 then j = max(j, 5) end      -- lit rib
    c:put(x, y, SEED[max(1, min(6, j))])
  end)
  c:put(floor(s[1] - ca * 1.5 + .5), floor(s[2] - sa * 1.5 - 0.5 + .5), SEED[6])
end
c:put(29, 44, A.CREAM)

A.save(c, NAME)
