-- durian-seed (ph, Opus single pass). Two big glossy chestnut durian seeds (smooth ovoids, a pale tan hilum scar on
-- one end, bright specular + waxy hi streak, cool reflected light, AO + contact shadow) on a torn scrap of durian leaf
-- (elliptic, pointed apex intact, jagged torn base, dark glossy upper side, midrib + fine pinnate veins, V-fold light).
-- The right seed has germinated: woody brown-green stem, root curling down over the leaf edge, and two elliptic
-- seedling leaves; the right one is turned to show the coppery-gold scaly underside that durian leaves have.
-- quirk: a dab of custard-yellow durian flesh is still stuck to the left seed.
local NAME = "durian-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB25_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local LEAF = { "#18362f", "#21503d", "#2c6a45", "#3f884c", "#5ea456", "#8fc468" }
local COP = { "#45262a", "#6a3c28", "#905e30", "#b4823c", "#d4a656", "#eeca84" }
local VEIN, COOL = "#a6d27a", "#36636a"
local SEED = { "#381c26", "#5a2b27", "#82412c", "#a85e35", "#cc864a", "#eeb878" }
local HIL = { "#a8814e", "#cfab72", "#ead0a0" }
local STEM = { "#4a3a2a", "#6e6a38", "#94944a", "#bcbc6a" }
local ROOT = { "#7a5a44", "#b89474", "#e2c8a2" }
local FLESH = { "#c4862e", "#e8b43e", "#f8d66a", "#ffeca6" }
local CUTS = { 0.16, 0.32, 0.48, 0.64, 0.82 }

-- seeds: cx, cy, rx, ry, ang
local seeds = { { 21, 46, 7.0, 4.5, -0.32 }, { 37, 41, 6.6, 4.4, 0.42 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.85) end

-- leaf scrap: elliptic durian leaf on the diagonal, apex upper right, base torn off lower left
local lm, ln, LT, LS, len = G.blade(7, 55, 34, 53, 58, 36, function(t)
  if t > 0.99 then return -1 end
  local u = min(1, 0.22 + t * 0.8)
  return max(0.5, 7.6 * sin(pi * u) ^ 0.8)
end, { fold = 0.34 })
local torn = {}
lm:each(function(x, y) local k = K(x, y)
  local d = LT[k] * len
  local jag = 2.2 + 3.2 * X.hash(floor(LS[k] * 4 + 9), 3, 7) + LS[k] * 2.5
  if d < jag then torn[#torn + 1] = k end
end)
for _, k in ipairs(torn) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.26, 0.42, 0.58, 0.76 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t < 0.96 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 6.5) / 5.2
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.15 and abs(s) < 0.8 and t < 0.9 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)
-- torn edge: pale bruised fibres; cool rim on the shade side; one gloss streak
for _, k in ipairs(torn) do end
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LT[k] * len < 7.5 and not lm:has(x - 1, y + 1) then c:put(x, y, "#b8c890", ltok)
  elseif LS[k] > 0.7 and LT[k] > 0.15 then c:put(x, y, COOL, ltok) end end)
for _, q in ipairs{ { 47, 37 }, { 48, 37 }, { 49, 36 } } do if lm:has(q[1], q[2]) then c:put(q[1], q[2], LEAF[6], ltok) end end

-- root of the sprouting seed, curling down over the lower leaf edge
local rp = { { 41, 44 }, { 45, 48 }, { 46, 53 }, { 43, 57 } }
local rm, rn = G.tube(rp, function(t) return 1.25 * (1 - t) ^ 0.7 + 0.3 end)
rm:cut(seeds[2].m)
local rtok = { r = { name = "root" } }
X.tone(c, rm, X.light(rn, { amb = 0.1, wrap = 0.3 }), ROOT, { cuts = { 0.35, 0.7 }, tok = rtok })
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not seeds[2].m:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
-- root hairs
c:put(47, 50, ROOT[2], rtok) c:put(44, 55, ROOT[2], rtok)

-- sprout stem
local stok = { r = { name = "stem" } }
local sp = { { 36, 38 }, { 34, 32 }, { 37, 26 }, { 35, 19 } }
local sm, sn, ST = G.tube(sp, function(t) return 1.15 - t * 0.2 end)
sm:cut(seeds[2].m)
local sidx = X.tone(c, sm, X.light(sn, { amb = 0.12, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- seedling leaves
local function sleaf(ax, ay, cx, cy, bx, by, ramp, w, under)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.92 + 0.06)) ^ 0.8)
  end, { fold = 0.4 })
  m:cut(sm)
  local tok = { r = { name = under and "leafunder" or "leafsprout" } }
  G.toneN(c, m, n, ramp, { tok = tok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.15 and T[k] > 0.04 and T[k] < 0.9 then c:put(x, y, S[k] <= 0 and ramp[6] or ramp[3], tok) return end
    local ph = (T[k] * L - abs(S[k]) * 3.6) / 3.6
    local f = abs((ph - floor(ph)) - 0.5) * 2
    if f > 0.84 and abs(S[k]) > 0.2 and abs(S[k]) < 0.75 and T[k] > 0.1 and T[k] < 0.85 then c:put(x, y, S[k] < 0 and ramp[5] or ramp[2], tok) end
    -- scaly underside: sparse pale scale dots
    if under and abs(S[k]) > 0.3 and X.hash(x, y, 5) > 0.86 then c:put(x, y, ramp[6], tok) end
  end)
  return m
end
local la = sleaf(35, 20, 26, 21, 18, 15, LEAF, 3.4, false)
local lb = sleaf(36, 19, 42, 13, 50, 13, COP, 3.0, true)
-- petiole knot
c:put(35, 19, STEM[2], stok) c:put(36, 19, STEM[3], stok) c:put(35, 20, STEM[1], stok)

-- seeds last: glossy ovoids, hilum scar, AO between them
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  if i == 1 then X.ao(sb, s.m, seeds[2].m, 1, -1) end
  local vis = s.m:copy()
  if i == 1 then vis:cut(seeds[2].m) end
  local v = X.light(s.n, { amb = 0.06, wrap = 0.2 })
  local id = X.tone(c, vis, v, SEED, { cuts = { 0.14, 0.3, 0.48, 0.66, 0.85 }, bias = sb, tok = tok })
  local ca, sa = cos(s[5]), sin(s[5])
  -- hilum: pale scar on the right end (u > 0.55)
  local rim = X.rim(s.n)
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local w = (-dx * sa + dy * ca) / (s[4] + .45)
    local sgn = i == 1 and 1 or -1
    if u * sgn > 0.64 and abs(w) < 0.5 then
      local h = (u * sgn > 0.88 or w > 0.3) and 1 or ((w < -0.15) and 3 or 2)
      c:put(x, y, HIL[h], tok)
    elseif (rim[k] or 0) > 0.75 and s.m:edge():has(x, y) and not sb[k] then c:put(x, y, "#7a4a5e", tok) end
  end)
  -- waxy hi streak + specular
  local hx, hy = floor(s[1] - 2 + .5), floor(s[2] - 2 + .5)
  c:put(hx, hy, "#fff4d6", tok) c:put(hx + 1, hy, SEED[6], tok) c:put(hx - 1, hy + 1, SEED[6], tok)
end
-- quirk: a dab of custard flesh stuck on the left seed
local fm, fn = G.oval(17, 48, 2.2, 1.5, 0.3, 0.7)
local ftok = { r = { name = "flesh" } }
X.tone(c, fm, X.light(fn, { amb = 0.15, wrap = 0.3 }), FLESH, { cuts = { 0.3, 0.55, 0.8 }, tok = ftok })
c:put(16, 47, FLESH[4], ftok)
c:put(18, 50, FLESH[1], ftok)
G.save2(c, NAME)
