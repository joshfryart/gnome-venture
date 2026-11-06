-- perilla-seed (C33 slot 2, Opus single pass). Five tiny round perilla nutlets (grey-brown, netted coat, one glint
-- each on the lit shoulder) on a torn scrap of a broad, saw-toothed shiso leaf (pale midrib, pinnate veins, V-fold
-- light, cool lower rim, AO + contact shadow under each nutlet). The right nutlet has sprouted: a thin pale stem, two
-- round seed-leaves and a first pair of serrated, purple-flushed shiso leaves.
-- quirk: the scrap's tip has curled back on itself, showing the leaf's purple underside.
local NAME = "perilla-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = G.new3(NAME)

local LEAF = { "#173d34", "#22573d", "#2f7444", "#47924b", "#6cb257", "#a2d272" }
local SHISO = { "#2e1c3e", "#4a2a58", "#6c3a72", "#8e5288", "#b277a2", "#d8a6c4" }
local SPR = { "#2a2a46", "#36504a", "#3f7a4c", "#5c9e52", "#88c264", "#bfe08c" }
local SEED = { "#2c1f22", "#46322f", "#654a3e", "#86664f", "#a88866", "#cfb28a" }
local STEM = { "#4c7e4c", "#7fb064", "#b2d48c", "#e0f0b8" }
local VEIN, COOL = "#c4e48e", "#3b6b72"

-- nutlets: cx, cy (last one sprouts)
local seeds = { { 19, 46 }, { 25, 49.5 }, { 24, 42.5 }, { 30.5, 46 }, { 37, 44 } }
local all = HP.mask()
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], 2.15, 2.0, 0, 0.9) all:add(s.m) end

-- leaf scrap: broad ovate shiso leaf, base torn off at the lower left, tip to the upper right
local lm, ln, LT, LS, len = G.leafo(6, 54, 30, 56, 57, 34, 10.5, { serr = 1.1, per = 3.4, fold = 0.42, pw = 0.85 })
G.tear(lm, 17, 61, 11, 41, 1.6, 3)
local bias = {}
X.ao(bias, lm, all, 1, -1) G.cast(bias, lm, all, 1, 1, -1) G.cast(bias, lm, all, 2, 2, -1)
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, amb = 0.12, wrap = 0.28, cuts = { 0.16, 0.32, 0.5, 0.67, 0.84 } })
local PER = 5.2
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t < 0.9 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 7) / PER + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.14 and abs(s) < 0.72 and t < 0.84 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
local rim = X.rim(ln)
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and LS[k] > 0.55 and rim[k] > 0.15 then c:put(x, y, COOL, ltok) end end)

-- quirk: tip curled back -> purple underside flap, with a dark crease and AO where it folds
local ctok = { r = { name = "curl" } }
local flap = HP.mask()
lm:each(function(x, y) local k = K(x, y) if LT[k] > 0.8 and LS[k] < 0.25 then flap:set(x, y) end end)
local fb = {}
G.toneN(c, flap, X.pillow(flap, 2), SHISO, { tok = ctok, amb = 0.15, wrap = 0.3, bias = fb, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 } })
flap:each(function(x, y) local k = K(x, y)
  if LT[k] < 0.83 then c:put(x, y, SHISO[1], ctok)                       -- crease
  elseif abs(LS[k] + 0.2) < 0.1 and LT[k] < 0.95 then c:put(x, y, SHISO[5], ctok) end -- underside midrib
end)
-- leaf just below the crease sits in the flap's shadow
lm:each(function(x, y) local k = K(x, y) if LT[k] > 0.76 and LT[k] <= 0.8 and LS[k] < 0.4 then c:put(x, y, LEAF[2], ltok) end end)

-- sprout from the last nutlet: pale stem, two round seed-leaves, first pair of serrated shiso leaves
local stok = { r = { name = "stem" } }
local sm, sn = G.tube({ { 37, 43 }, { 38.5, 36 }, { 35, 29 }, { 36, 19 } }, function(t) return 0.95 end)
sm:cut(seeds[5].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local cots = {}
for i, ct in ipairs{ { 32.2, 27.6, 3.4, 1.9, 0.35 }, { 40.6, 27.4, 3.4, 1.9, -0.35 } } do
  local m, n = G.oval(ct[1], ct[2], ct[3], ct[4], ct[5], 0.7)
  m:cut(sm)
  local b = {} X.ao(b, m, sm, 1, -1)
  G.toneN(c, m, n, LEAF, { tok = { r = { name = "cot" .. i } }, bias = b, amb = 0.14, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  cots[i] = m
end
local tls = {}
for i, L in ipairs{ { 35.5, 19.5, 29, 18, 23, 11 }, { 36.5, 19.5, 43, 18, 50, 12 } } do
  local m, n, T, S = G.leafo(L[1], L[2], L[3], L[4], L[5], L[6], 3.9, { serr = 0.8, per = 2.4, fold = 0.5, pw = 0.8 })
  m:cut(sm)
  local tok = { r = { name = "true" .. i } }
  G.toneN(c, m, n, SPR, { tok = tok, amb = 0.14, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.16 and T[k] > 0.12 and T[k] < 0.82 then c:put(x, y, S[k] <= 0 and SPR[6] or SPR[3], tok)
    elseif abs(S[k]) > 0.8 and S[k] > 0 and T[k] > 0.2 then c:put(x, y, SHISO[3], tok) end   -- purple-flushed shade margin
  end)
  tls[i] = m
end
-- tiny bud between the true leaves
c:put(36, 18, SPR[5], stok) c:put(36, 17, SPR[4], stok) c:put(35, 18, SPR[6], stok)

-- nutlets last: round, netted coat, AO between neighbours, one glint each
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local idx = G.toneN(c, vis, s.n, SEED, { tok = tok, bias = sb, amb = 0.1, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
  vis:each(function(x, y) local k = K(x, y)
    if (x + 2 * y + i) % 3 == 0 and (idx[k] or 1) > 2 then c:put(x, y, SEED[(idx[k] or 3) - 1], tok) end  -- netting
  end)
  local bx, by = G.specAt(vis, s.n, 30)
  if bx then c:put(bx, by, "#f6e6c4", tok) end
end
-- split coat on the sprouting nutlet + root tip peeking out under it
c:put(38, 42, SEED[1]) c:put(39, 43, SEED[1])
c:put(39, 46, "#efe6c8", { r = { name = "root" } }) c:put(40, 47, "#d9cba4", { r = { name = "root" } })

G.done(c, NAME)
