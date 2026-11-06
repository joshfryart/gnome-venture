-- senegal-coral-tree-seed (D15 artist pass). Three glossy scarlet kidney seeds (hilum notch, cool bounce, window glint) on a torn
-- scrap of a coral-tree leaflet (broad rhomboid, pale midrib, paired veins, ochre tear). The third seed has germinated: a slim stem
-- armed with tiny black prickles, two chubby cotyledons and the first true leaf, a trifoliate of three rhomboid leaflets.
-- quirk: the empty red seed coat is still perched on a cotyledon like a little hat.
local NAME = "senegal-coral-tree-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_1.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local VEIN, COOL, OCHRE = "#c2e48c", "#3a6c72", "#a8803c"
local SEED = R.red
local STEM = { "#2e7646", "#45954c", "#6ab455", "#9dd06c" }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 15.5, 46.5, 4.9, 3.2, -0.25 }, { 28.5, 43.5, 4.8, 3.2, 0.3 }, { 43.5, 41.5, 4.4, 3.0, -0.6 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- leaf scrap
local lm, ln, LT, LS, len = A.blade(5, 50, 28, 47, 56, 40, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t ^ 0.9 * 0.97 + 0.03)
  local w = 9.2 * sin(pi * u) ^ 0.8
  if t > 0.86 then w = w * (1 - (t - 0.86) * 2.2) end
  return max(0.5, w)
end, { fold = 0.42 })
-- ragged torn base and one bite out of the lower edge
local cut, torn = {}, HP.mask()
lm:each(function(x, y) local k = K(x, y)
  local ragged = 0.07 + 0.13 * X.hash(floor(LS[k] * 6 + 8), 1, 2)
  if LT[k] < ragged then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bite = A.ell(33.5, 53.6, 3.4, 2.2, 0.1)
bite:each(function(x, y) lm.s[K(x, y)] = nil end)
local tearEdge = lm:copy()
tearEdge:each(function(x, y)
  local k = K(x, y)
  local near = false
  for dx = -1, 1 do for dy = -1, 1 do
    local xx, yy = x + dx, y + dy
    if not lm:has(xx, yy) and (LT[K(xx, yy)] or 1) < 0.2 or bite:has(xx, yy) then near = true end
  end end
  if near and (abs(dx or 0) >= 0) then torn:set(x, y) end
end)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
local VT = { 6, 11, 16, 21, 26, 31, 36, 41 }
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.15 and t > 0.1 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  for _, vt in ipairs(VT) do
    local d = t * len - (vt + abs(s) * 5.0)
    if abs(d) < 0.5 and abs(s) > 0.2 and abs(s) < 0.82 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.2 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
torn:each(function(x, y) if lm:has(x, y) then c:px(x, y, OCHRE) end end)

-- seedling: stem with prickles
local sm, sn, ST = A.tube({ {43.5, 41}, {42, 35}, {45, 29}, {44, 23} }, function(t) return 0.85 end)
sm:cut(seeds[3].m)
A.toneN(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
for _, q in ipairs{ {0.28, -1}, {0.5, 1}, {0.72, -1} } do
  local x, y = A.bez({ {43.5, 41}, {42, 35}, {45, 29}, {44, 23} }, q[1])
  x, y = floor(x + .5), floor(y + .5)
  c:px(x + q[2] * 2, y, "#2b1c26"); c:px(x + q[2] * 3, y + 1, "#6a3a30"); c:px(x + q[2] * 2, y - 1, "#2b1c26")
end
-- cotyledons
local cotL = A.leafE(c, 38.2, 35, 4.2, 2.4, -0.35, LEAF, LEAF[2])
local cotR = A.leafE(c, 50.4, 31.6, 4.2, 2.4, 0.4, LEAF, LEAF[2])
-- empty seed coat hat on the right cotyledon
local hat = A.ell(51.8, 29, 2.7, 1.7, 0.45)
hat:cut(A.ell(52.6, 30.2, 1.6, 0.9, 0.45))
A.lit2(c, hat, SEED, 1.4)
c:px(50, 28, A.CREAM)
-- trifoliate first leaf
local function leaflet(cx, cy, ang, L, Wd)
  local ux, uy = cos(ang), sin(ang)
  local vx, vy = -uy, ux
  local m = c:poly{ { cx - ux * L * 0.5, cy - uy * L * 0.5 },
                    { cx - ux * L * 0.05 + vx * Wd * 0.5, cy - uy * L * 0.05 + vy * Wd * 0.5 },
                    { cx + ux * L * 0.55, cy + uy * L * 0.55 },
                    { cx - ux * L * 0.05 - vx * Wd * 0.5, cy - uy * L * 0.05 - vy * Wd * 0.5 } }
  A.lit2(c, m, LEAF, 2.4, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
  A.ln(c, cx - ux * (L * 0.45), cy - uy * (L * 0.45), cx + ux * (L * 0.4), cy + uy * (L * 0.4), LEAF[6], m)
  return m
end
c:px(44, 22, STEM[2]); c:px(44, 21, STEM[3])
leaflet(37, 20.5, -2.6, 9.5, 6.6)
leaflet(51, 20.5, -0.55, 9.5, 6.6)
leaflet(44.5, 13.5, -1.5708, 11.5, 8)

-- seeds last
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  c:fillMask(A.ell(s[1] + 1, s[2] + 1.5, s[3] + .2, s[4] + .1, s[5]), LEAF[1])
  local tok = { r = { name = "seed" .. i } }
  local idx = A.toneN(c, vis, s.n, SEED, { cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 }, amb = 0.1, wrap = 0.3, bias = sb, tok = tok })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    if u * u + v * v > 0.52 and dx + dy > 2 and not sb[k] then c:put(x, y, "#c04a6c", tok) end   -- cool bounce rim
  end)
  -- hilum notch on the lower long side
  local hx, hy = s[1] + (-sa) * 0 + 0.8 * ca - (-s[4] + 0.6) * sa * -1 * 0, s[2] + s[4] - 1.2
  hx, hy = floor(s[1] + 0.6 * ca - (s[4] - 1.0) * sa * -1 + .5) * 0 + floor(s[1] + .5), floor(s[2] + s[4] - 0.9 + .5)
  c:px(hx, hy, "#2b1018"); c:px(hx + 1, hy, "#2b1018"); c:px(hx - 1, hy, R.red[2])
  -- window glint
  local gx, gy = floor(s[1] - s[3] * 0.45 + .5), floor(s[2] - s[4] * 0.5 + .5)
  if vis:has(gx, gy) then c:px(gx, gy, A.CREAM) end
  if vis:has(gx + 1, gy) then c:px(gx + 1, gy, "#ffd0b8") end
end
A.save2(c, NAME)
