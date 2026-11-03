-- bambara-seed (final, aR3_2 single pass). Two glossy maroon bambara seeds, each with its white hilum eye, resting on
-- a torn trifoliate leaflet scrap (elliptic, pointed, V-fold light, midrib + paired pinnate veins, ragged tear, cool
-- reflected edge, AO and contact shadow under each seed). The right seed has split its coat: a pale curved shoot rises
-- and opens the bambara's three-leaflet leaf (long elliptic leaflets, each with a midrib) on a short petiole, and a
-- pale root tip creeps out over the leaf.
-- quirk: a single round dewdrop sits on the leaf scrap, with a bright rim, a pale core and a glint.
local NAME = "bambara-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local LEAF = { "#173f36", "#22583f", "#2f7446", "#46934c", "#6ab354", "#9ccf6a" }
local YL = { "#24503c", "#357046", "#4e9150", "#72b25a", "#9ccc6c", "#cbe690" }   -- young sprout leaf (yellower)
local VEIN, COOL = "#c0e28a", "#3a6a72"
local RED = { "#2e1020", "#4e1828", "#742432", "#9c3438", "#c4544a", "#e8866a" }
local STEM = { "#6a8a4a", "#9cbc6c", "#c8dc96", "#eef4c4" }
local ROOT = { "#9a8460", "#cbb68a", "#ece0b8" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- seeds
local seeds = { { 22, 46, 4.7, 3.9, -0.2 }, { 35, 43, 4.5, 3.7, -0.35 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.85) end

-- leaf scrap: a bambara leaflet on the diagonal, torn off at the base
local lm, ln, LT, LS, len = G.blade(7, 53, 30, 54, 56, 40, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 8.0 * sin(pi * min(1, t * 0.92 + 0.1)) ^ 0.75)
end, { fold = 0.4 })
G.tear(lm, 13, 50, -0.92, 0.38, 1.4, 5)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.03 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- paired pinnate veins swept toward the tip
  local d = (t * len - abs(s) * 5.0) / 5.2 + (s > 0 and 0.35 or 0)
  local f = d - floor(d)
  if f < 0.16 and abs(s) > 0.18 and abs(s) < 0.78 and t > 0.1 and t < 0.88 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.12 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale fibrous rim along the tear
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] < 0.17 and not bias[k] then c:put(x, y, LEAF[5], ltok) end end)

-- quirk: dewdrop
do
  local dtok = { r = { name = "dew" } }
  local cx, cy = 46, 43
  for _, q in ipairs{ { 0, -1, "#d8f4ec" }, { 1, -1, "#b6e6dc" }, { -1, 0, "#d8f4ec" }, { 0, 0, "#fff4d6" }, { 1, 0, "#8fd0c4" },
                      { 2, 0, "#5a9ea4" }, { -1, 1, "#8fd0c4" }, { 0, 1, "#b6f0e0" }, { 1, 1, "#e4fbf4" }, { 2, 1, "#5a9ea4" },
                      { 0, 2, "#3a7a84" }, { 1, 2, "#3a7a84" } } do c:put(cx + q[1], cy + q[2], q[3], dtok) end
  for _, q in ipairs{ { 1, 3 }, { 2, 3 }, { 3, 2 } } do if lm:has(cx + q[1], cy + q[2]) then c:put(cx + q[1], cy + q[2], LEAF[2], ltok) end end
end

-- root tip from the sprouting seed, creeping down-right over the leaf
local rp = { { 38, 46 }, { 40, 48 }, { 42, 48.5 }, { 44, 50 } }
local rm, rn = G.tube(rp, function(t) return 1.0 * (1 - t) + 0.35 end)
rm:cut(seeds[2].m)
local rtok = { r = { name = "root" } }
X.tone(c, rm, X.light(rn, { amb = 0.2, wrap = 0.3 }), ROOT, { cuts = { 0.35, 0.7 }, tok = rtok })
rm:shift(0, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not seeds[2].m:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- sprout stem
local stok = { r = { name = "stem" } }
local sp = { { 35, 40 }, { 36.5, 34 }, { 34, 28 }, { 34.5, 22 } }
local sm, sn = G.tube(sp, function(t) return 1.1 - 0.15 * t end)
sm:cut(seeds[2].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- trifoliate leaf
local function leaflet(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.97 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.95 + 0.08)) ^ 0.7)
  end, { fold = 0.35 })
  m:cut(sm)
  G.toneN(c, m, n, YL, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.16 and T[k] > 0.12 and T[k] < 0.82 then c:put(x, y, S[k] <= 0 and YL[6] or YL[3], ltok) end end)
  return m
end
local la = leaflet(33, 22, 28, 22, 21, 17, 2.6)
local lb = leaflet(36, 22, 41, 22, 48, 17, 2.6)
local lc = leaflet(34.5, 21, 35, 16, 35.5, 9, 2.5)
-- ambient seat where the leaflets join the petiole
for _, q in ipairs{ { 34, 22 }, { 35, 22 } } do c:put(q[1], q[2], STEM[1], stok) end

-- seeds last
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local tok = { r = { name = "seed" .. i } }
  G.toneN(c, vis, s.n, RED, { tok = tok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.06, wrap = 0.2 })
  vis:edge():each(function(x, y) local dx, dy = x - s[1], y - s[2] if dx > 0 and dy > 0 and dx + dy > 3 then c:put(x, y, "#7a3a5a", tok) end end)
  local bx, by = G.specAt(vis, s.n, 50)
  if bx then c:put(bx, by, "#fff4d6", tok) c:put(bx + 1, by, RED[6], tok) end
  -- hilum eye
  local ex, ey = s[1] + 0.8, s[2] + 1.0
  local ca, sa = cos(s[5]), sin(s[5])
  local em = G.rell(ex, ey, ca, sa, 1.9, 0.9)
  em:grow(1):cut(em):each(function(x, y) if vis:has(x, y) then c:put(x, y, RED[1], tok) end end)
  em:each(function(x, y) if vis:has(x, y) then c:put(x, y, ((x - ex) + (y - ey) < 0) and "#f4ead2" or "#cdbfa8", tok) end end)
  c:put(floor(ex + .5), floor(ey + .5), "#7a5a52", tok)
end
-- split coat on the sprouting seed: a pale crack where the shoot came out
for _, q in ipairs{ { 34, 40, "#cdbfa8" }, { 35, 40, "#2e1020" }, { 36, 40, "#cdbfa8" } } do c:put(q[1], q[2], q[3], { r = { name = "crack" } }) end

G.save2(c, NAME)
