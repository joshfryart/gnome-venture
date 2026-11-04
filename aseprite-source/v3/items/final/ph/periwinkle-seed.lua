-- periwinkle-seed (C33 slot 2, Opus single pass). A slender periwinkle follicle (pale tan-green, split open along its
-- top seam, papery inner lining) lying on a torn scrap of a glossy, dark, entire-edged vinca leaf (pale midrib, faint
-- arched veins, wet specular streak, cool lower rim, AO + contact shadow). Three small black, furrowed seeds have
-- spilled out; the right one has sprouted a thin stem and a pair of glossy oval leaves.
-- quirk: the seedling is far too young to flower, but has already opened one tiny blue pinwheel periwinkle bloom.
local NAME = "periwinkle-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = G.new3(NAME)

local LEAF = { "#0f2e2c", "#173f36", "#22573d", "#2f7144", "#4a904c", "#79b45c" }
local GLOSS = "#cfeaa8"
local POD = { "#4e4a2c", "#76703e", "#9c9550", "#bdb56a", "#d9d28e", "#f1ecbc" }
local LINE = { "#c9b88a", "#efe2bc" }
local SEED = { "#140e18", "#211826", "#332638", "#4a3a50", "#6a586e", "#988aa0" }
local STEM = { "#4c7a4a", "#7aa85e", "#a9cc84", "#d8ecb0" }
local SPR = { "#14382f", "#1f5038", "#2c6a40", "#3f8848", "#62a854", "#9ccc74" }
local PERI = { "#262466", "#373c98", "#5058c2", "#7180de", "#9eacf2", "#d0dafe" }
local COOL = "#3a6870"

-- seeds: cx, cy, rx, ry, angle (last one sprouts)
local seeds = { { 22, 39.5, 2.6, 1.4, 0.25 }, { 29, 42.5, 2.6, 1.4, -0.35 }, { 37, 40.5, 2.6, 1.5, 0.1 } }
local all = HP.mask()
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.8) all:add(s.m) end

-- follicle pod path (over the leaf, lower part)
local pp = { { 13, 47 }, { 21, 53 }, { 34, 54 }, { 46, 49 } }
local pm, pn, PT, PS = G.tube(pp, function(t) return 0.6 + 1.6 * sin(pi * min(1, t * 1.05)) ^ 0.6 end)

-- leaf scrap: glossy elliptic vinca leaf, petiole end at the right, tip torn off at the left
local lm, ln, LT, LS, len = G.leafo(58, 52, 34, 34, 7, 41, 9.6, { serr = 0, fold = 0.3, pw = 1.0, round = 0.62, stalk = true })
G.tear(lm, 13, 58, 15, 26, 1.7, 5)
local bias = {}
X.ao(bias, lm, all, 1, -1) G.cast(bias, lm, all, 1, 1, -1) G.cast(bias, lm, all, 2, 2, -1)
X.ao(bias, lm, pm, 1, -1) G.cast(bias, lm, pm, 1, 2, -1)
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, amb = 0.1, wrap = 0.25, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 and t < 0.97 then c:put(x, y, s <= 0 and "#9ccc80" or LEAF[3], ltok) return end
  -- arched side veins, faint (one tone shift), curving toward the tip
  local ph = (t * len + (abs(s) ^ 0.7) * 9) / 6.5
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.88 and abs(s) > 0.12 and abs(s) < 0.78 then c:put(x, y, s < 0 and LEAF[5] or LEAF[3], ltok) end
end)
-- wet gloss streak on the lit half, parallel to the midrib
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if not bias[k] and s < -0.3 and s > -0.52 and t > 0.22 and t < 0.62 then c:put(x, y, (t > 0.32 and t < 0.48) and GLOSS or LEAF[6], ltok) end end)
local rim = X.rim(ln)
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and LS[k] > 0.6 and rim[k] > 0.1 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)

-- follicle: slender, ridged, split along the top seam with a pale papery lining and one seed still inside
local ptok = { r = { name = "pod" } }
local pidx = G.toneN(c, pm, pn, POD, { tok = ptok, amb = 0.12, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.68, 0.86 } })
pm:each(function(x, y) local k = K(x, y) local s, t = PS[k], PT[k]
  if t > 0.28 and t < 0.86 and s > -0.62 and s < -0.08 then
    c:put(x, y, (s < -0.4) and LINE[2] or LINE[1], ptok)                -- open seam, lining
  elseif abs(s - 0.45) < 0.12 and t > 0.1 and t < 0.92 then c:put(x, y, POD[max(1, (pidx[k] or 3) - 1)], ptok) end -- ridge
end)
-- seed left in the pod
for _, q in ipairs{ { 26, 51, 2 }, { 27, 51, 3 }, { 28, 51, 2 }, { 27, 52, 1 } } do if pm:has(q[1], q[2]) then c:put(q[1], q[2], SEED[q[3]], ptok) end end
-- twisted beak at the pod tip
c:put(47, 48, POD[3], ptok) c:put(48, 47, POD[2], ptok)

-- sprout from the last seed
local stok = { r = { name = "stem" } }
local sm, sn = G.tube({ { 38, 39.5 }, { 40, 33 }, { 36.5, 27 }, { 38.5, 18 } }, function(t) return 0.85 end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
for i, L in ipairs{ { 37.5, 26.5, 32, 26, 25.5, 21 }, { 38.5, 26.5, 44, 25, 50, 20 } } do
  local m, n, T, S = G.leafo(L[1], L[2], L[3], L[4], L[5], L[6], 3.1, { serr = 0, fold = 0.35, pw = 1.0, round = 0.6 })
  m:cut(sm)
  local tok = { r = { name = "pair" .. i } }
  G.toneN(c, m, n, SPR, { tok = tok, amb = 0.12, wrap = 0.28, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.18 and T[k] > 0.12 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and SPR[6] or SPR[3], tok) end end)
  local bx, by = G.specAt(m, n, 25) if bx then c:put(bx, by, GLOSS, tok) end
end

-- quirk: one tiny pinwheel periwinkle bloom on the seedling's tip
local fx, fy = 38.5, 13.5
local fl = HP.mask()
local petals = {}
for i = 0, 4 do
  local a = -pi / 2 + i * 2 * pi / 5 + 0.25
  local ux, uy = cos(a), sin(a)
  local pmk = G.rell(fx + ux * 2.9 - uy * 0.6, fy + uy * 2.9 + ux * 0.6, ux, uy, 2.4, 1.75)
  petals[#petals + 1] = pmk fl:add(pmk)
end
local ftok = { r = { name = "bloom" } }
local fn = X.pillow(fl, 1.6)
G.toneN(c, fl, fn, PERI, { tok = ftok, amb = 0.16, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.68, 0.86 } })
-- pinwheel creases: each petal's trailing edge one tone darker
for i, pmk in ipairs(petals) do
  local nxt = petals[i % 5 + 1]
  pmk:each(function(x, y) if nxt:grow(1):has(x, y) and not nxt:has(x, y) then c:put(x, y, PERI[2], ftok) end end)
end
-- pale eye ring + magenta-dark throat
for _, q in ipairs{ { 38, 13, "#eef0ff" }, { 39, 13, "#d6dcff" }, { 38, 14, "#d6dcff" }, { 39, 14, "#6a2a6a" } } do c:put(q[1], q[2], q[3], ftok) end
c:put(37, 12, PERI[6], ftok)

-- seeds last: black, furrowed, matte with one dull glint
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local vis = s.m:copy()
  local idx = G.toneN(c, vis, s.n, SEED, { tok = tok, amb = 0.1, wrap = 0.3, cuts = { 0.2, 0.38, 0.56, 0.72, 0.88 } })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local dx, dy = x - s[1], y - s[2]
    local v = -dx * sa + dy * ca
    if abs(v) < 0.5 and abs(dx * ca + dy * sa) < s[3] - 0.6 then c:put(x, y, SEED[max(1, (idx[K(x, y)] or 2) - 1)], tok) end end)
  local bx, by = G.specAt(vis, s.n, 30) if bx then c:put(bx, by, SEED[6], tok) end
end
-- split coat on the sprouting seed
c:put(39, 39, SEED[4])
G.done(c, NAME)
