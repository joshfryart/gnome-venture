-- parsley-seed (final, Opus single pass aC32_1). Three tiny ribbed parsley seeds (grey-brown ovoids, five pale ribs,
-- dark furrows) on a torn scrap of a flat-leaf parsley leaflet (three toothed lobes, pale midrib + veins, V-fold light,
-- cool reflected edge, ragged tear at the stalk end, AO + contact shadow under each seed). The right seed has sprouted:
-- pale stem, two long strap cotyledons and a first true leaf of three toothed, wedge-shaped parsley leaflets.
-- quirk: a single dewdrop sits on the tip of the left cotyledon.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "parsley-seed"
local c = A.new(NAME)
local LEAF = { "#123a2c", "#1c5634", "#28733b", "#3c9340", "#5fb347", "#93d260" }
local VEIN, COOL = "#b9e27e", "#356a70"
local SEED = { "#33282a", "#4f3f37", "#6e5a47", "#8f7a5c", "#b2a07a", "#d6c9a0" }
local STEM = { "#3f7a4a", "#79ad62", "#acd387", "#dcefb2" }
local DEW = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0", "#fff4d6" }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 17, 45, 4.2, 2.5, 0.35 }, { 27, 48, 4.2, 2.5, -0.15 }, { 39, 42, 4.0, 2.4, -1.25 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- leaf scrap: broad parsley leaflet, three lobes, toothed margin, torn at the left (stalk) end
local lm, ln, LT, LS, len = A.blade(8, 48, 30, 56, 56, 42, function(t)
  if t > 0.99 then return -1 end
  local u = min(1, t * 0.92 + 0.1)
  local w = 7.4 * sin(pi * u ^ 1.05) ^ 0.6
  -- two lobe notches
  for _, q in ipairs{ 0.5, 0.76 } do local d = abs(t - q) if d < 0.07 then w = w - (0.07 - d) / 0.07 * 4.4 end end
  return max(0.5, w)
end, { fold = 0.4 })
-- teeth: small notches every 3.4 px along each margin
do local cut = {}
  lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
    local ph = t * len / 3.4 + (s > 0 and 0.5 or 0)
    local f = (ph - floor(ph))
    if t > 0.12 and abs(s) > 0.7 and f < 0.45 then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do lm.s[k] = nil end
end
A.tear(lm, 13, 48, -0.85, -0.5, 1.4, 7)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.06 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- secondary veins into each lobe, swept toward the tip
  for _, q in ipairs{ 0.3, 0.62, 0.86 } do
    local tv = q - abs(s) * 0.12
    if abs(t - tv) < 0.012 and abs(s) > 0.15 and abs(s) < 0.72 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.15 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)

-- sprout from seed 3
local stok = { r = { name = "stem" } }
local sp = { { 40, 40 }, { 41, 35 }, { 38, 30 }, { 39, 25 } }
local sm, sn = A.tube(sp, function(t) return 1.0 end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function strap(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.88 + 0.12)) ^ 0.45)
  end, { fold = 0.3 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.12 and T[k] < 0.82 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local cl = strap(38, 29, 32, 27, 25, 20, 1.7)
local cr = strap(40, 29, 46, 28, 53, 22, 1.7)

-- first true leaf: petiole + three wedge leaflets, each with three toothed lobes
local pet = { { 39, 25 }, { 39, 22 }, { 40, 20 }, { 40, 19 } }
for i = 0, 24 do local x, y = A.bez(pet, i / 24) c:put(floor(x + .5), floor(y + .5), STEM[3], stok) end
local function wedge(bx, by, ang, L, W)
  local ux, uy = cos(ang), sin(ang)
  local m, n, T, S = A.blade(bx, by, bx + ux * L * 0.5, by + uy * L * 0.5, bx + ux * L, by + uy * L, function(t)
    if t > 0.99 then return -1 end
    local w = 0.6 + W * t ^ 0.7
    if t > 0.72 then local f = (t - 0.72) / 0.28 w = w * (1 - f * f * 0.2) end
    return w
  end, { fold = 0.35 })
  -- three lobes at the broad end: notch out two V cuts, plus a tooth on each lobe
  local cut = {}
  m:each(function(x, y) local k = K(x, y) local t, s = T[k], S[k]
    if t > 0.7 and (abs(abs(s) - 0.42) < (t - 0.7) * 0.9) then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  return m, n, T, S
end
local tl, tn, TT, TS = HP.mask(), {}, {}, {}
for _, q in ipairs{ { 40, 18, -pi / 2, 7.5, 2.9 }, { 38, 21, -pi / 2 - 1.2, 7.0, 2.6 }, { 42, 21, -pi / 2 + 1.2, 7.0, 2.6 } } do
  local m, n, T, S = wedge(q[1], q[2], q[3], q[4], q[5])
  m:each(function(x, y) local k = K(x, y) if not tl:has(x, y) then tl:set(x, y) tn[k], TT[k], TS[k] = n[k], T[k], S[k] end end)
end
tl:cut(cl):cut(cr)
local tb = {}
X.ao(tb, tl, sm, 1, -1)
A.toneN(c, tl, tn, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3, bias = tb })
tl:each(function(x, y) local k = K(x, y) if abs(TS[k]) < 0.12 and TT[k] > 0.15 and TT[k] < 0.8 then c:put(x, y, TS[k] <= 0 and VEIN or LEAF[3], ltok) end end)

-- seeds last: five ribs (pale ridge / dark furrow rows along the seed), AO between neighbours, one glint
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  local v0 = X.light(s.n, { amb = 0.1, wrap = 0.3 })
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), flip * (-dx * sa + dy * ca) / (s[4] + .45)
    local i = 1 + floor(v0[k] * 4.6)
    local band = floor((v + 1) * 2.5) -- 0..4 rib rows
    if band % 2 == 1 then i = i - 1 else i = i + 1 end
    if abs(u) > 0.8 then i = i - 1 end
    if sb[k] then i = i - 1 end
    c:put(x, y, SEED[max(1, min(6, i))], tok)
  end)
end
-- glint on the front seed
c:put(25, 47, SEED[6], { r = { name = "seed2" } }) c:put(26, 47, "#efe6c4", { r = { name = "seed2" } })

-- quirk: dewdrop on the left cotyledon tip
local dm = HP.mask() for _, p in ipairs{ {24,17},{25,17},{23,18},{24,18},{25,18},{24,19} } do dm:set(p[1], p[2]) end
local dtok = { r = { name = "dew" } }
for _, p in ipairs{ {24,17,4},{25,17,3},{23,18,3},{24,18,3},{25,18,2},{24,19,2} } do c:put(p[1], p[2], DEW[p[3]], dtok) end
c:put(24, 17, DEW[5], dtok)
A.save(c, NAME)
