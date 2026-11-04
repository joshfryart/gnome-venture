-- egusi-seed (Opus single pass, aB25_3). Three big flat cream egusi seeds (oval with a pointed hilum end,
-- thick raised margin that catches the light, sunken face groove) on a torn, deeply lobed melon-leaf scrap
-- (sinuses cut into the top edge, midrib + a vein into each lobe, ragged torn base with pale fibres).
-- One seed has sprouted: a pale hooked hypocotyl, two thick oblong cucurbit cotyledons and a first
-- three-lobed palmate true leaf (the egusi melon leaf). A pale root tip pokes out under the seed.
-- quirk: a springy curled tendril has already shot out of the seedling, far too early.
local NAME = "egusi-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB25_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = G.new2(NAME)
local LEAF = { "#163a32", "#22573e", "#317548", "#4b964f", "#74b65a", "#a6d47a" }
local VEIN, COOL, FIB = "#c8e894", "#3a6e70", "#dcecb4"
local SEED = { "#5a4630", "#8c7650", "#bba57a", "#ddcca0", "#f1e6c4", "#fff8e0" }
local STEM = { "#4a7a4c", "#7cae6a", "#acd28e", "#d8eebc", "#eef8d8" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- leaf scrap: sagging blade rising to the right, lobes cut into the upper edge, torn base on the left
local lm, ln, LT, LS, len = G.blade(7, 44, 26, 58, 58, 48, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 9.0 * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.7)
end, { fold = 0.34 })
local PER = 10.5
local cut = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  if s < 0 then                                                                    -- upper edge: deep rounded sinuses
    local ph = t * len / PER + 0.1
    local f = abs((ph - floor(ph)) - 0.5) * 2
    local lim = 0.97 - (1 - f) ^ 3 * 0.6
    if t > 0.12 and t < 0.92 and -s > lim then cut[#cut + 1] = k return end
  elseif s > 0.94 + 0.05 * sin(t * len * 0.9) then cut[#cut + 1] = k return end
  if t < 0.05 + 0.03 * ((x * 5 + y * 3) % 4) then cut[#cut + 1] = k end           -- ragged tear
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

local seeds = { { 17, 47, 4.6, 2.8, 0.45 }, { 28, 51, 4.6, 2.8, -0.15 }, { 41, 47, 4.4, 2.7, -0.35 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.45) end
-- pointed hilum end
for _, s in ipairs(seeds) do local ca, sa = cos(s[5]), sin(s[5])
  s.tip = { floor(s[1] + ca * (s[3] + 1) + 0.5), floor(s[2] + sa * (s[3] + 1) + 0.5) } s.m:set(s.tip[1], s.tip[2]) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end

-- sprout from seed 3: hooked hypocotyl rising up and back to the left
local stok, ltok = { r = { name = "stem" } }, { r = { name = "leaf" } }
local sp = { { 41, 45 }, { 42, 37 }, { 36, 31 }, { 35, 24 } }
local sm, sn = G.tube(sp, function(t) return 1.25 - 0.2 * t end)
sm:cut(seeds[3].m)
G.cast(bias, lm, sm, 1, 1, -1)
-- root tip under the seed
local rp = { { 44, 49 }, { 46, 51 }, { 47, 53 }, { 49, 55 } }
local rm, rn = G.tube(rp, function(t) return 0.9 * (1 - t) + 0.3 end)
rm:cut(seeds[3].m)
X.ao(bias, lm, rm, 1, -1)

G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.07 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 6) / PER + 0.1 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.9 and abs(s) > 0.14 and abs(s) < 0.8 and t > 0.1 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LT[k] < 0.11 then c:put(x, y, FIB, ltok)
  elseif LS[k] > 0.6 then c:put(x, y, COOL, ltok) end end)
X.tone(c, rm, X.light(rn, { amb = 0.2, wrap = 0.3 }), STEM, { cuts = { 0.2, 0.4, 0.6, 0.8 }, tok = stok })

-- true leaf: three-lobed palmate melon leaf on a short petiole
local B = { 37, 17 }
local tl = G.palm(B[1], B[2], { { -1, -0.55, 9, 2.6 }, { 0.15, -1, 10, 2.8 }, { 1, -0.35, 8, 2.4 } }, 2.6)
-- cotyledons: thick oblong, rounded
local c1m, c1n = G.oval(28.5, 24.5, 5.2, 2.3, 0.28, 0.5)
local c2m, c2n = G.oval(41.5, 23.5, 5.2, 2.3, -0.32, 0.5)
local tb = {}
X.ao(tb, tl, c1m, 1, -1) X.ao(tb, tl, c2m, 1, -1)
tl:cut(c1m):cut(c2m)
G.toneN(c, tl, X.pillow(tl, 1.8), LEAF, { bias = tb, tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.25 })
for _, l in ipairs{ { -1, -0.55, 8 }, { 0.15, -1, 9 }, { 1, -0.35, 7 } } do
  local l2 = sqrt(l[1]^2 + l[2]^2)
  for i = 1, l[3] - 1 do local x, y = floor(B[1] + l[1] / l2 * i + 0.5), floor(B[2] + l[2] / l2 * i + 0.5)
    if tl:has(x, y) and not tb[K(x, y)] then c:put(x, y, i < 3 and LEAF[4] or (l[1] < 0.5 and LEAF[6] or LEAF[3]), ltok) end end
end
-- petiole from the stem top up to the leaf base
for _, q in ipairs{ { 35, 24 }, { 36, 23 }, { 36, 22 }, { 37, 21 }, { 37, 20 } } do c:put(q[1], q[2], STEM[2], stok) end
for _, q in ipairs{ { c1m, c1n }, { c2m, c2n } } do
  q[1]:cut(sm)
  G.toneN(c, q[1], q[2], LEAF, { tok = ltok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, amb = 0.16, wrap = 0.3 })
end
-- cotyledon midlines
for i = -3, 3 do
  local x, y = floor(28.5 + i * cos(0.28) + 0.5), floor(24.5 + i * sin(0.28) + 0.5) if c1m:has(x, y) then c:put(x, y, LEAF[5], ltok) end
  x, y = floor(41.5 + i * cos(-0.32) + 0.5), floor(23.5 + i * sin(-0.32) + 0.5) if c2m:has(x, y) then c:put(x, y, LEAF[3], ltok) end
end
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = stok })

-- quirk: curled tendril springing off to the left of the stem
do local tok = { r = { name = "tendril" } }
  local pts = {}
  for i = 0, 40 do local t = i / 40
    local x, y = 35 - t * 10, 31 - t * 2
    if t > 0.5 then local a = (t - 0.5) * 2 * 2.4 * pi local r = 3.2 * (1 - (t - 0.5) * 1.4)
      x, y = 25 - r * sin(a) + 0, 30 - 3.2 + r * cos(a) + 0 end
    pts[#pts + 1] = { floor(x + 0.5), floor(y + 0.5) }
  end
  local seen = {}
  for i, p in ipairs(pts) do local k = K(p[1], p[2])
    if not seen[k] and not sm:has(p[1], p[2]) and not c1m:has(p[1], p[2]) then seen[k] = true c:put(p[1], p[2], (i % 7 < 4) and STEM[3] or STEM[2], tok) end end
end

-- seeds: thick lit margin, sunken face, AO between neighbours
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  if i == 3 then X.ao(sb, s.m, sm, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = X.tone(c, vis, X.light(s.n, { amb = 0.15, wrap = 0.35 }), SEED, { cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, bias = sb, tok = tok })
  local e = vis:edge()
  local inner = vis:copy():cut(e):edge()
  inner:each(function(x, y) local k = K(x, y)
    local lit = (x - s[1]) + (y - s[2]) < 0
    c:put(x, y, SEED[max(1, min(6, (idx[k] or 4) - (lit and 1 or 0)))], tok) end)    -- groove inside the margin
  e:each(function(x, y) local k = K(x, y)
    local lit = (x - s[1]) + (y - s[2]) < 0
    c:put(x, y, SEED[max(1, min(6, (idx[k] or 4) + (lit and 1 or -1)))], tok) end)
  c:put(s.tip[1], s.tip[2], SEED[3], tok)
end
-- seed 3 coat split where the shoot leaves it
c:put(41, 45, SEED[1], { r = { name = "seed3" } }) c:put(40, 45, SEED[6], { r = { name = "seed3" } })
-- glint on the front seed
c:put(25, 50, "#fff4d6", { r = { name = "seed2" } }) c:put(26, 50, SEED[6], { r = { name = "seed2" } })

G.save2(c, NAME)
