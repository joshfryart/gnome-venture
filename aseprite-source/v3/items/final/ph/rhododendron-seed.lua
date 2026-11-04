-- rhododendron-seed (final D12, Sonnet high). A torn scrap of a leathery rhododendron leaf (long pointed ellipse, glossy
-- dark green, pale midrib, curved side veins, cool rim) carrying a split woody seed capsule and four seeds: slim tan
-- spindles with papery wings at both ends. The right seed has germinated: pale stem, two cotyledons and the first pair of
-- pointed glossy true leaves. quirk: a pink flower petal is stuck to the empty capsule.
local NAME = "rhododendron-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local LEAF = { "#14352f", "#1d4f3a", "#2a6a40", "#3e8a46", "#5eab50", "#8ccb68" }
local VEIN, COOL = "#c8e08c", "#3a6c78"
local SEED = { "#3a2220", "#5a3a2a", "#80532f", "#a67440", "#caa062", "#ecd098" }
local WING = { "#9a7a5a", "#bf9f76", "#dcc79a", "#ecdcb6", "#f7ecd0", "#fff6e2" }
local WOOD = { "#2b1a16", "#4a2e26", "#6e4a34", "#92683f", "#b88a52", "#dcb27a" }
local STEM = { "#5a7a4a", "#86a463", "#b6cc82", "#e0eaa8" }
local COT  = { "#24544a", "#3a8049", "#559e4c", "#76bb56", "#a2d46a", "#cdea92" }
local TRUE = { "#10302c", "#1a4a36", "#276a3e", "#3a8a46", "#58aa52", "#88ca6a" }
local PET  = { "#7d2c5e", "#b04080", "#d86a98", "#f08cb2", "#ffb4cc", "#ffdce8" }
local ltok = { r = { name = "leaf" } }

-- ---------- masks first (for contact shadows)
local seeds = { { 25, 47, -0.45 }, { 31, 53, 0.25 }, { 36, 47, -0.12 } }
for _, s in ipairs(seeds) do
  local ux, uy = cos(s[3]), sin(s[3])
  s.ux, s.uy = ux, uy
  s.wm = G.rell(s[1], s[2], ux, uy, 6.4, 1.9)
  s.bm, s.bn = G.oval(s[1], s[2], 3.5, 1.7, s[3], 0.9)
end
local germ = { 43, 46, -0.6 }
germ.bm, germ.bn = G.oval(germ[1], germ[2], 3.6, 2.3, germ[3], 0.9)
local cap = { 15.5, 50.5, -0.3 }
cap.m, cap.n = G.oval(cap[1], cap[2], 5.8, 2.9, cap[3], 0.8)

-- ---------- leaf scrap
local lm, ln, LT, LS, len = G.blade(8, 54, 28, 52, 58, 38, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 8.4 * sin(pi * min(1, 0.06 + 0.92 * t)) ^ 0.62)
end, { fold = 0.42 })
-- torn left end: ragged diagonal bite
lm:each(function(x, y)
  local jag = ({ 0, 2, 1, 3, 1, 0, 2 })[(y % 7) + 1]
  if x + 0.45 * (y - 50) < 11.5 + jag then lm.s[K(x, y)] = nil end
end)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.bm, 1, -1) G.cast(bias, lm, s.wm, 1, 1, -1) end
X.ao(bias, lm, germ.bm, 1, -1) X.ao(bias, lm, cap.m, 1, -1) G.cast(bias, lm, cap.m, 1, 2, -1)
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.2, 0.36, 0.54, 0.72, 0.88 }, amb = 0.12, wrap = 0.25 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.02 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- curved pinnate side veins, sweeping toward the tip
  local ph = (t * len - abs(s) * 3.4) / 5.4
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.9 and abs(s) > 0.2 and abs(s) < 0.82 and t > 0.06 and t < 0.9 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
  -- glossy sheen streak on the lit half
  if s > -0.66 and s < -0.46 and t > 0.28 and t < 0.44 and not (abs(s) < 0.14) then c:put(x, y, LEAF[6], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.08 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale fibre pixels along the rip
lm:each(function(x, y)
  if (not lm:has(x - 1, y) or not lm:has(x, y + 1)) and x + 0.45 * (y - 50) < 15 and X.hash(x, y, 5) > 0.45 then c:put(x, y, LEAF[6], ltok) end
end)

-- ---------- sprout (stem, cotyledons, true leaves)
local stok = { r = { name = "stem" } }
local sm, sn = G.tube({ { 43, 45 }, { 40, 38 }, { 45, 32 }, { 43, 24 } }, function(t) return 1.1 end)
sm:cut(germ.bm)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function cot(px, py, dir)
  local ux, uy = G.rot(dir, 0, dir * -0.42 * -1)
  local ux2, uy2 = dir * cos(0.4), -sin(0.4)
  local m = G.rell(px + ux2 * 3.2, py + uy2 * 3.2, ux2, uy2, 3.6, 1.7)
  m:cut(sm)
  G.toneN(c, m, X.pillow(m, 1.7), COT, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.12, wrap = 0.25 })
  G.ln(c, px + ux2 * 1.6, py + uy2 * 1.6, px + ux2 * 5.2, py + uy2 * 5.2, COT[6], m)
  return m
end
cot(41.6, 34, -1) cot(44.2, 33, 1)
local function tleaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    if t < 0.16 then return 0.55 end
    return max(0.5, w * sin(pi * min(1, (t - 0.1) / 0.9)) ^ 0.6)
  end, { fold = 0.4 })
  G.toneN(c, m, n, TRUE, { tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.12, wrap = 0.28 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.16 and T[k] > 0.12 and T[k] < 0.92 then c:put(x, y, S[k] <= 0 and VEIN or TRUE[3], ltok) end end)
  return m
end
tleaf(43, 26, 38, 20, 32, 13, 3.2)
tleaf(43, 26, 48, 19, 53, 12, 3.0)
tleaf(43, 26, 43, 21, 43, 15, 2.0)
c:px(43, 25, STEM[2]) c:px(43, 26, STEM[2])

-- ---------- capsule: woody ovoid, ribbed, split apex, dry calyx stub
do
  local m, n = cap.m, cap.n
  local tok = { r = { name = "capsule" } }
  local ca, sa = cos(cap[3]), sin(cap[3])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  G.toneN(c, m, n, WOOD, { tok = tok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.1, wrap = 0.25 })
  m:each(function(x, y)
    local dx, dy = x - cap[1], y - cap[2]
    local u = (dx * ca + dy * sa) / 6.2
    local v = flip * (-dx * sa + dy * ca) / 3.3
    local k = K(x, y)
    local ci = c:get(x, y)
    if abs(v - 0.1) < 0.14 or abs(v + 0.62) < 0.1 or abs(v - 0.7) < 0.1 then
      if abs(u) < 0.86 then c:put(x, y, WOOD[2], tok) end                       -- lengthwise rib grooves
    end
    if u > 0.78 and abs(v) < 0.46 then c:put(x, y, u > 0.9 and "#1c0f0c" or WOOD[1], tok) end  -- split apex mouth
    if u > 0.7 and abs(v) > 0.46 and abs(v) < 0.62 then c:put(x, y, WOOD[2], tok) end
  end)
  -- a glint on the lit rib
  c:px(floor(cap[1] - 2.6), floor(cap[2] - 1.8), WOOD[6]) c:px(floor(cap[1] - 1.6), floor(cap[2] - 1.9), WOOD[6])
  -- calyx stub at the base
  local bx, by = cap[1] - 6.2 * ca, cap[2] - 6.2 * sa
  c:px(floor(bx + .5), floor(by + .5), WOOD[3]) c:px(floor(bx - 0.5), floor(by + 0.5), WOOD[2])
  c:px(floor(bx + .5), floor(by + 1.5), WOOD[2])
end
-- quirk: pink petal stuck on the capsule
do
  local m = G.rell(11.2, 52.4, 0.8, -0.6, 2.9, 1.8)
  local pn = X.pillow(m, 1.6)
  G.toneN(c, m, pn, PET, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.1, wrap = 0.25 })
  c:px(12, 52, PET[2]) c:px(10, 53, PET[1]) c:px(12, 51, PET[6])
end

-- ---------- seeds: winged spindles
local function drawSeed(s, i)
  local tok = { r = { name = "seed" .. i } }
  local wm = s.wm:copy():cut(s.bm)
  G.toneN(c, s.wm, X.pillow(s.wm, 1.6), WING, { tok = tok, cuts = { 0.15, 0.3, 0.46, 0.62, 0.8 }, amb = 0.25, wrap = 0.35 })
  -- wing ribs along the axis, fading at the tips
  G.ln(c, s[1] - s.ux * 6.2, s[2] - s.uy * 6.2, s[1] + s.ux * 6.2, s[2] + s.uy * 6.2, WING[2], wm)
  -- wing tip edges slightly darker
  for _, sg in ipairs{ -1, 1 } do
    local x, y = floor(s[1] + s.ux * 6.3 * sg + .5), floor(s[2] + s.uy * 6.3 * sg + .5)
    if s.wm:has(x, y) then c:put(x, y, WING[2], tok) end
  end
  G.toneN(c, s.bm, s.bn, SEED, { tok = tok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.1, wrap = 0.25 })
  local ca, sa = cos(s[3]), sin(s[3])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  s.bm:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local v = flip * (-dx * sa + dy * ca) / 1.9
    local u = (dx * ca + dy * sa) / 3.9
    if abs(v) < 0.22 and abs(u) < 0.8 then c:put(x, y, SEED[2], tok) end        -- dark back seam
  end)
  c:px(floor(s[1] - s.ux * 1.8 - 0.3), floor(s[2] - s.uy * 1.8 - 1.0), SEED[6])
end
for i, s in ipairs(seeds) do drawSeed(s, i) end
-- germinated seed: split coat, root tip peeking, sprout emerges
do
  local tok = { r = { name = "germ" } }
  G.toneN(c, germ.bm, germ.bn, SEED, { tok = tok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.1, wrap = 0.25 })
  local ca, sa = cos(germ[3]), sin(germ[3])
  germ.bm:each(function(x, y)
    local dx, dy = x - germ[1], y - germ[2]
    local u = (dx * ca + dy * sa) / 4.0
    local v = (-dx * sa + dy * ca) / 2.4
    if u > 0.62 then c:put(x, y, SEED[2], tok) end                                  -- split lip
    if abs(v) < 0.2 and u < 0.5 then c:put(x, y, SEED[2], tok) end
  end)
  c:px(41, 44, SEED[6]) c:px(40, 45, SEED[5])
  -- pale rootlet curling out toward the lower-left
  for _, p in ipairs{ { 40, 48, STEM[3] }, { 39, 49, STEM[3] }, { 38, 50, STEM[2] }, { 36, 50, STEM[2] } } do c:put(p[1], p[2], p[3]) end
end
G.save2(c, NAME)
