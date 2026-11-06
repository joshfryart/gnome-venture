-- bok-choy-seed (final pass, Opus). Three tiny round brassica seeds (glossy red-brown spheres, faint net coat, one
-- glint each) on a torn scrap of bok choy leaf: dark glossy blade, a broad pale-white midrib, side veins, ragged torn
-- base, cool reflected edge, AO + contact shadow under each seed. The right seed has germinated: pale stem, two
-- kidney-shaped notched brassica cotyledons, and a first true leaf that is a tiny spoon of bok choy (white petiole,
-- dark green round blade).
-- quirk: flea-beetle shot-holes nibbled through the leaf scrap.
local NAME = "bok-choy-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR21_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#14382f", "#1d5236", "#2a6c3c", "#3f8a43", "#62a84c", "#94c967" }
local RIB = { "#5e8a62", "#88b07a", "#b4d49a", "#d6ebb8", "#eef7d6", "#fbfde8" }
local COOL = "#3a6c72"
local SEED = { "#2a1418", "#44201e", "#6a3224", "#8c4a2c", "#b0683a", "#d69458" }
local STEM = { "#5e8a62", "#9cc07c", "#cde4a8", "#eef6d2" }
local TL = { "#1d5236", "#2a6c3c", "#3f8a43", "#5aa24a", "#86c05e", "#b6dc82" }

-- leaf scrap: a spoon-shaped bok choy blade on the diagonal, torn ragged at the base
local lm, ln, LT, LS, len = A.blade(7, 52, 30, 54, 56, 43, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 8.2 * sin(pi * min(1, t * 0.82 + 0.14)) ^ 0.55)
end, { fold = 0.32 })
-- torn base: jagged bite across the first part
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local tear = 0.06 + 0.05 * abs(sin(s * 9.7 + 1.3)) + 0.03 * ((floor((s + 1) * 6)) % 2)
  if t < tear then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
-- quirk: flea-beetle shot-holes (tiny gaps -> outline turns them into dark pinholes)
local holes = { { 22, 55 }, { 46, 51 }, { 47, 52 }, { 30, 44 } }
for _, h in ipairs(holes) do lm.s[K(h[1], h[2])] = nil end

-- seeds: cx, cy, r
local seeds = { { 19, 48, 2.6 }, { 27, 51, 2.5 }, { 39, 46, 2.7 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[3], 0, 1.0) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end

local ltok = { r = { name = "leaf" } }
local rtok = { r = { name = "rib" } }
local lidx = A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- broad pale midrib (bok choy's white rib), widest at the base, tapering to the tip
local rib = HP.mask()
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local w = 0.3 * (1 - t) ^ 0.8 + 0.06
  if abs(s) < w and t < 0.93 then rib:set(x, y) end
end)
local rb = {}
for k in pairs(rib.s) do rb[k] = bias[k] end
local rn = {}
rib:each(function(x, y) local k = K(x, y) local nn = ln[k]
  local t, s = LT[k], LS[k]
  local w = 0.3 * (1 - t) ^ 0.8 + 0.06
  local q = max(-0.95, min(0.95, s / (w + 0.04)))
  rn[k] = { A.norm(nn[1] * 0.3 + q * 0.55, nn[2] * 0.3 + q * 0.55, 1) } end)
A.shade(c, rib, rn, RIB, { bias = rb, tok = rtok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.2, wrap = 0.3 })
-- separation: darker leaf row along the rib edges
lm:each(function(x, y) local k = K(x, y)
  if rib:has(x, y) or bias[k] then return end
  if rib:has(x - 1, y) or rib:has(x + 1, y) or rib:has(x, y - 1) or rib:has(x, y + 1) then
    if LS[k] > 0 then c:put(x, y, LEAF[max(1, lidx[k] - 1)], ltok) end
  end
  -- side veins: pale on the lit half, dark on the shade half, swept toward the tip
  local t, s = LT[k], LS[k]
  local ph = (t * len - abs(s) * 5.0) / 6.5 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.88 and abs(s) > 0.32 and abs(s) < 0.82 and t > 0.1 and t < 0.88 and not rib:has(x, y) then
    c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
-- puckered blade: a few savoy bumps as hi/low pairs
for _, b in ipairs{ { 16, 45 }, { 34, 47 }, { 44, 43 }, { 25, 56 } } do
  local k = K(b[1], b[2])
  if lm:has(b[1], b[2]) and not rib:has(b[1], b[2]) and not bias[k] then
    c:put(b[1], b[2], LEAF[min(6, (lidx[k] or 3) + 1)], ltok)
    if lm:has(b[1] + 1, b[2] + 1) and not rib:has(b[1] + 1, b[2] + 1) then c:put(b[1] + 1, b[2] + 1, LEAF[max(1, (lidx[k] or 3) - 1)], ltok) end
  end
end
-- cool reflected light on the lower-right edge
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.12 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
-- glossy leaf glint (one 2x1 hi mark on the lit half)
c:put(44, 39, LEAF[6], ltok) c:put(45, 39, "#c8e88c", ltok)

-- sprout: stem from the right seed, up to the cotyledons
local stok = { r = { name = "stem" } }
local sp = { { 39, 44 }, { 38, 37 }, { 40, 31 }, { 39, 25 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
sm:cut(seeds[3].m)
A.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok, amb = 0.15, wrap = 0.3 })

-- kidney cotyledon: wide ellipse with a notch at the outer end, on a short petiole
local ctok = { r = { name = "cot" } }
local function cotyledon(px, py, cx, cy, ang)
  local ux, uy = cos(ang), sin(ang)
  local m = A.rell(cx, cy, ux, uy, 4.6, 3.3)
  -- notch at the outer tip
  local nx, ny = cx + ux * 4.4, cy + uy * 4.4
  m:cut(A.rell(nx, ny, ux, uy, 1.6, 1.1))
  -- petiole
  local pm = HP.mask()
  for i = 0, 12 do local f = i / 12 pm:set(floor(px + (cx - ux * 3 - px) * f + .5), floor(py + (cy - uy * 3 - py) * f + .5)) end
  pm:cut(m)
  local n = X.pillow(m, 2.2)
  local idx = A.shade(c, m, n, LEAF, { tok = ctok, cuts = { 0.16, 0.32, 0.5, 0.66, 0.82 }, amb = 0.14, wrap = 0.3 })
  pm:each(function(x, y) c:put(x, y, STEM[3], stok) end)
  -- midrib, pale, from petiole to the notch
  for i = 1, 7 do local f = i / 8
    local x, y = floor(cx - ux * 3.6 + ux * 7.2 * f + .5), floor(cy - uy * 3.6 + uy * 7.2 * f + .5)
    if m:has(x, y) then c:put(x, y, i < 5 and LEAF[6] or LEAF[5], ctok) end
  end
  return m
end
local cl = cotyledon(39, 26, 31, 24, pi + 0.25)
local cr = cotyledon(39, 26, 47, 23, -0.2)
-- contact shade where the cotyledons meet the stem top
c:put(37, 25, LEAF[2], ctok) c:put(41, 25, LEAF[2], ctok)

-- first true leaf: a tiny bok choy spoon, white petiole + round dark blade
local ptok = { r = { name = "tleaf" } }
local pet = { { 39, 25 }, { 39, 22 }, { 40, 19 }, { 40, 17 } }
local pm, pn = A.tube(pet, function(t) return 1.0 end)
pm:cut(cl):cut(cr)
A.shade(c, pm, pn, RIB, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = rtok, amb = 0.2, wrap = 0.3 })
local bm = A.rell(40.5, 13, 0.1, -1, 4.4, 3.4)
bm:cut(pm)
local bidx = A.shade(c, bm, X.pillow(bm, 2.4), TL, { tok = ptok, cuts = { 0.16, 0.32, 0.5, 0.66, 0.82 }, amb = 0.14, wrap = 0.3 })
-- pale rib running up into the blade, AO row at the base where blade meets petiole
for y = 11, 16 do c:put(40, y, y > 13 and RIB[5] or RIB[4], ptok) end
c:put(39, 17, TL[1], ptok) c:put(42, 17, TL[1], ptok)
c:put(38, 11, TL[6], ptok) c:put(38, 12, TL[6], ptok)

-- seeds last: glossy red-brown spheres with a faint net coat and one glint each
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, vis, s.n, SEED, { tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.1, wrap = 0.2 })
  -- reticulate coat: a couple of dark net pixels in the mid tones
  vis:each(function(x, y) local k = K(x, y)
    if idx[k] >= 3 and idx[k] <= 5 and X.hash(x, y, i) > 0.72 then c:put(x, y, SEED[idx[k] - 1], tok) end end)
  -- cool bounce on the lower right
  c:put(floor(s[1] + 1.5), floor(s[2] + 1.5), "#6a4a5c", tok)
  -- glint
  c:put(floor(s[1] - 1), floor(s[2] - 1), "#ffe8c0", tok)
end
-- hilum scar on the sprouting seed where the stem leaves
c:put(39, 44, SEED[2], { r = { name = "seed3" } })

A.save(c, NAME)
