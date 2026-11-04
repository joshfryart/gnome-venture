-- daikon-seed (final, Opus single pass). A dried, beaked daikon seed pod (straw-coloured, bead-constricted, with a
-- longitudinal seam and a split showing a seed inside) lying across a torn round end-lobe of a radish leaf (wavy
-- margin, pale midrib, pinnate veins, cool edge). Two loose round red-brown seeds sit beside it, and a third has
-- germinated: pink-flushed stem, fuzzy white root, and the two notched heart-shaped cotyledons of a radish sprout.
-- quirk: the right cotyledon still wears its cracked seed coat like a little cap.
local NAME = "daikon-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#183b30", "#22553a", "#2f7042", "#488e48", "#6eae55", "#a2cc78" }
local VEIN, COOL, TORN = "#c4e292", "#376a6c", "#d8eaa6"
local SEED = { "#3a1818", "#5c2822", "#823e2c", "#a65838", "#c97c50", "#eab282" }
local POD = { "#4e3a2a", "#7c603a", "#a5864e", "#c8aa68", "#e2c98c", "#f6e8bc" }
local STEM = { "#6e2a4a", "#a8486a", "#d07c90", "#f0b6bc" }
local COT = { "#1f4a34", "#2c6640", "#3f844a", "#5ea452", "#88c260", "#bce08a" }
local ROOT = { "#a89c80", "#d6ccb0", "#f6f0de" }

-- leaf scrap: the round end lobe of a lyrate radish leaf, torn base at the right
local lm, ln, LT, LS, len = A.blade(53, 50, 34, 48, 11, 38, function(t)
  if t > 0.99 then return -1 end
  local w = 9.2 * sin(pi * min(1, t ^ 1.35)) ^ 0.5
  return max(0.5, w * (0.9 + 0.1 * sin(t * 2 * pi * 4.2)))
end, { fold = 0.38 })
local torn = A.tear(lm, LT, LS, len, true, 3.0, 21)

-- pod: beaked silique, constricted between seeds; beak overhangs the leaf tip
local pp = { { 37, 45.5 }, { 30, 43 }, { 20, 39.5 }, { 8, 37 } }
local pm, pn, PTT, PS = A.tube(pp, function(t)
  if t > 0.72 then return 2.2 * (1 - (t - 0.72) / 0.28) ^ 1.3 + 0.35 end
  return 2.55 * (0.8 + 0.2 * abs(cos(pi * t / 0.24)))
end)
-- loose seeds + sprouting seed
local seeds = { { 29.5, 50.5, 2.3 }, { 36, 51.5, 2.4 }, { 44.5, 46, 2.4 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[3] - 0.15, 0, 0.9) end
local bias = {}
X.ao(bias, lm, pm, 1, -1) A.cast(bias, lm, pm, 1, 2, -1)
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 1, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 and t > 0.03 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 7) / 6.5 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.14 and abs(s) < 0.75 and t > 0.08 and t < 0.9 then
    c:put(x, y, s < 0 and LEAF[min(6, lidx[k] + 1)] or LEAF[max(1, lidx[k] - 1)], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.15 and LT[k] < 0.92 then c:put(x, y, COOL, ltok) end end)
torn:each(function(x, y) if lm:has(x, y) then local k = K(x, y) c:put(x, y, LS[k] < 0.4 and TORN or LEAF[4], ltok) end end)

-- pod: bead shading (constrictions darker), seam line, split with a seed inside
local ptok = { r = { name = "pod" } }
local pb = {}
pm:each(function(x, y) local k = K(x, y) local t = PTT[k]
  if t < 0.72 and abs(cos(pi * t / 0.24)) < 0.22 then pb[k] = -1 end end)
local pidx = A.toneN(c, pm, pn, POD, { bias = pb, tok = ptok, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, amb = 0.14, wrap = 0.3 })
pm:each(function(x, y) local k = K(x, y)
  if abs(PS[k] + 0.05) < 0.12 and PTT[k] > 0.02 and PTT[k] < 0.92 then c:put(x, y, POD[max(1, pidx[k] - 2)], ptok) end end)
-- split: open slot over the middle bead with a seed glowing inside
local sx, sy = A.bez(pp, 0.36)
local slot = A.rell(sx, sy, 0.95, 0.33, 2.3, 1.4):clip(pm)
slot:each(function(x, y) c:put(x, y, POD[1], ptok) end)
local im, inn = A.oval(sx + 0.4, sy + 0.2, 1.4, 1.2, 0, 0.9)
im:clip(slot)
A.toneN(c, im, inn, SEED, { tok = ptok, cuts = { 0.2, 0.4, 0.6, 0.75, 0.9 }, amb = 0.2, wrap = 0.4 })
-- split lips catch the light
slot:grow(1):cut(slot):each(function(x, y) if pm:has(x, y) and y < sy then c:put(x, y, POD[6], ptok) end end)
-- beak tip glint, stalk stub at the base
A.glint(c, pm, pn, "#fff4d6", ptok, false)

-- sprout: fuzzy root, pink stem, heart cotyledons
local stok = { r = { name = "sprout" } }
local rm, rn = A.tube({ { 45.5, 48 }, { 46.5, 51 }, { 48.5, 53 }, { 48.5, 57 } }, function(t) return 1.0 * (1 - t) + 0.35 end)
rm:cut(seeds[3].m)
X.tone(c, rm, X.light(rn, { amb = 0.2, wrap = 0.3 }), ROOT, { cuts = { 0.35, 0.65 }, tok = stok })
for _, q in ipairs{ { 45, 51 }, { 49, 51 }, { 50, 54 }, { 47, 55 } } do if not rm:has(q[1], q[2]) then c:put(q[1], q[2], ROOT[2], stok) end end
local sp = { { 45, 43.5 }, { 46.5, 34 }, { 43, 27 }, { 44, 20 } }
local sm, sn, ST = A.tube(sp, function(t) return 1.0 end)
sm:cut(seeds[3].m)
local sidx = X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function heart(ax, ay, cx, cy, bx, by)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    return max(0.6, 4.0 * sin(pi * min(1, t ^ 0.75 * 0.92 + 0.04)) ^ 0.55)
  end, { fold = 0.3 })
  local cut = {}
  m:each(function(x, y) local k = K(x, y) if T[k] > 0.8 and abs(S[k]) < 0.3 * (T[k] - 0.8) / 0.2 + 0.05 then cut[#cut + 1] = k end end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  m:cut(sm)
  local idx = A.toneN(c, m, n, COT, { tok = stok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.7 then c:put(x, y, S[k] <= 0 and COT[6] or COT[3], stok) end end)
  A.reflect(c, m, n, COOL, stok, 0.55)
  return m, n
end
local cl = heart(43.5, 20, 37, 17, 31, 18)
local cr, crn = heart(44.5, 20, 50, 16.5, 56, 16)
-- quirk: seed-coat cap on the right cotyledon tip, cracked
local capm, capn = A.oval(55, 15, 2.6, 1.9, -0.35, 0.8)
A.toneN(c, capm, capn, SEED, { tok = stok, cuts = A.CUTS, amb = 0.12, wrap = 0.3 })
c:put(55, 15, SEED[1], stok) c:put(56, 16, SEED[1], stok)
A.glint(c, capm, capn, SEED[6], stok, false)

-- loose seeds last: round, satin red-brown, a faint hilum scar, one glint each
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local m, n = A.seed(c, s[1], s[2], s[3], s[3] - 0.15, 0, SEED, { tok = tok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, flat = 0.9 })
  A.reflect(c, m, n, "#6c5a7a", tok, 0.5)
  c:put(floor(s[1] + 1.5), floor(s[2] + 0.5), SEED[2], tok)   -- hilum
  A.glint(c, m, n, "#fff4d6", tok, false)
end
A.save2(c, NAME)
