-- collard-seed (Opus single pass). Three tiny round brassica seeds (glossy red-brown spheres, pale hilum dot) on a
-- torn strip of blue-green collard leaf (pale midrib, paired veins, ragged torn ends, cool reflected edge, AO and
-- contact shadow under each seed). The fourth seed has sprouted: pale root with root hairs over the leaf edge,
-- purple-tinged stem, two notched heart-shaped brassica cotyledons and a first wavy blue-green true leaf.
-- quirk: the split seed coat is still stuck on the tip of the left cotyledon like a little cap.
local NAME = "collard-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local LEAF = { "#11283a", "#1b4248", "#285e58", "#3b7d69", "#5d9f82", "#93c3a6" }
local RIB = { "#5f8d6e", "#8dba92", "#bcdcb4", "#e2f2d2" }
local COOL = "#3d7286"
local COT = { "#183f2e", "#25603a", "#3a8444", "#5aa64e", "#86c463", "#bfe08a" }
local SEED = { "#1d0d10", "#371816", "#55271d", "#7a3b26", "#a45a34", "#d38e58" }
local STEM = { "#4c3f5e", "#76708a", "#9fb48a", "#d2e6b4" }
local ROOT = { "#b8a890", "#e4dcc4", "#fbf3dc" }

-- leaf scrap: broad strip, torn at both ends
local lm, ln, LT, LS, len = G.blade(6, 50, 30, 42, 58, 47, function(t)
  if t > 0.99 then return -1 end
  return max(0.6, 8.8 * sin(pi * min(1, 0.1 + t * 0.85)) ^ 0.45)
end, { fold = 0.3 })
G.tear(lm, function(x, y) return x - (11 + (y - 46) * 0.5) end, 1.6, 2, 4)
G.tear(lm, function(x, y) return (53 + (y - 46) * 0.35) - x end, 1.6, 2, 9)
-- a torn bite out of the upper edge
lm:cut(c:ellipse(46, 38.5, 3, 2))

local seeds = { { 17, 45 }, { 23, 48 }, { 28, 44 } }
local SPX, SPY = 36, 45            -- sprouting seed
local smask = {}
for i, s in ipairs(seeds) do smask[i] = G.oval(s[1], s[2], 2.2, 2.0, 0, 0.9) end
local spm = G.oval(SPX, SPY, 2.4, 2.1, 0, 0.9)

-- root (drawn into the bias before toning the leaf)
local rp = { { 37, 47 }, { 40, 50 }, { 43, 52 }, { 47, 56 } }
local rm, rn, RT, RS = G.tube(rp, function(t) return 0.95 * (1 - t) + 0.3 end)
rm:cut(spm)
local bias = {}
for _, m in ipairs(smask) do X.ao(bias, lm, m, 1, -1) G.cast(bias, lm, m, 1, 1, -1) end
X.ao(bias, lm, spm, 1, -1) G.cast(bias, lm, spm, 1, 1, -1)
G.cast(bias, lm, rm, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
local lidx = G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.18, 0.36, 0.54, 0.72, 0.9 }, amb = 0.12, wrap = 0.3 })
-- midrib + veins (skip shadowed pixels)
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s, t = LS[k], LT[k]
  if abs(s) < 0.11 then c:put(x, y, s <= 0 and RIB[3] or RIB[1], ltok) return end
  local ph = (t * len - abs(s) * 6) / 6.2 + (s > 0 and 0.4 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.14 and abs(s) < 0.78 then c:put(x, y, s < 0 and RIB[2] or LEAF[min(6, (lidx[k] or 3) + 1)], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and (lidx[k] or 1) <= 3 then c:put(x, y, COOL, ltok) end end)
-- torn ends: pale bruised fibre pixels along the tear
lm:edge():each(function(x, y) local k = K(x, y)
  if (LT[k] < 0.12 or LT[k] > 0.86) and abs(LS[k]) < 0.7 and X.hash(x, y, 2) > 0.45 then c:put(x, y, RIB[2], ltok) end end)

-- root with hairs, hanging over the leaf edge
local rtok = { r = { name = "root" } }
X.tone(c, rm, X.light(rn, { amb = 0.2, wrap = 0.3 }), ROOT, { cuts = { 0.4, 0.7 }, tok = rtok })
for _, h in ipairs{ { 41, 50 }, { 44, 55 }, { 45, 52 } } do c:put(h[1], h[2], ROOT[2], rtok) end

-- stem
local stok = { r = { name = "stem" } }
local sp = { { 36, 43 }, { 35, 36 }, { 37, 29 }, { 36, 22 } }
local sm, sn = G.tube(sp, function(t) return 1.0 end)
sm:cut(spm)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })

-- heart-shaped (notched) cotyledons on short petioles
local function cotyledon(cx, cy, side)
  local m, n = G.oval(cx, cy, 4.3, 3.2, side * 0.18, 0.7)
  -- notch at the outer tip
  m:cut(G.oval(cx + side * 4.3, cy - 0.6, 1.4, 1.2, 0, 1))
  local tok = { r = { name = "cot" .. side } }
  local idx = G.toneN(c, m, n, COT, { tok = tok, amb = 0.12, wrap = 0.3, cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 } })
  -- midvein toward the notch
  for i = -3, 2 do local x = floor(cx + side * i + 0.5) local y = floor(cy - 0.6 + i * side * 0.18 + 0.5)
    if m:has(x, y) then c:put(x, y, (idx[K(x, y)] or 4) >= 4 and COT[6] or COT[4], tok) end end
  return m, tok
end
-- petioles
for _, q in ipairs{ { { 36, 23 }, { 34, 22 }, { 32, 22 } }, { { 37, 23 }, { 39, 22 }, { 40, 21 } } } do
  for _, p in ipairs(q) do c:put(p[1], p[2], STEM[3], stok) end
end
local clm, cltok = cotyledon(28, 21.5, -1)
local crm = cotyledon(44.5, 20.5, 1)

-- first true leaf: small upright, wavy margin, blue-green with a midrib
local ttok = { r = { name = "true" } }
local tm, tn, TT, TS = G.blade(36, 22, 35, 16, 37, 9, function(t)
  if t > 0.97 then return -1 end
  return max(0.5, 2.9 * sin(pi * min(1, 0.12 + t * 0.9)) ^ 0.6 * (1 + 0.12 * sin(t * 30)))
end, { fold = 0.4 })
tm:cut(clm):cut(crm)
local tidx = G.toneN(c, tm, tn, LEAF, { tok = ttok, amb = 0.15, wrap = 0.3, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
tm:each(function(x, y) local k = K(x, y) if abs(TS[k]) < 0.16 and TT[k] < 0.85 then c:put(x, y, TS[k] <= 0 and RIB[3] or RIB[1], ttok) end end)
-- AO where the true leaf meets the stem top
for _, p in ipairs{ { 35, 21 }, { 37, 21 } } do if tm:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[2], ttok) end end

-- seeds last: glossy spheres, hilum dot, one glint
local function seed(m, cx, cy, tok)
  local n = X.sphere(cx - 0.4, cy - 0.5, 2.3, m)
  G.toneN(c, m, n, SEED, { tok = tok, amb = 0.1, wrap = 0.25, cuts = { 0.2, 0.36, 0.52, 0.7, 0.88 } })
  c:put(floor(cx) - 1, floor(cy) - 1, "#fff4d6", tok)
  c:put(floor(cx) + 1, floor(cy) + 1, SEED[3], tok)
end
for i, s in ipairs(seeds) do seed(smask[i], s[1], s[2], { r = { name = "seed" .. i } }) end
-- sprouting seed: split coat (pale crack where the stem leaves)
seed(spm, SPX, SPY, { r = { name = "sprout" } })
c:put(36, 43, STEM[3], stok) c:put(35, 43, SEED[2], stok)

-- quirk: seed coat cap on the left cotyledon's tip
local qtok = { r = { name = "cap" } }
for _, p in ipairs{ { 23, 18, 4 }, { 24, 18, 5 }, { 22, 19, 3 }, { 23, 19, 4 }, { 24, 19, 3 }, { 22, 20, 2 }, { 25, 18, 3 } } do
  c:put(p[1], p[2], SEED[p[3]], qtok)
end
c:put(23, 18, SEED[6], qtok)

G.save2(c, NAME)
