-- cacao-seed (single pass, Opus). Two fresh cacao beans (plump almond shape, mauve-brown seed coat with a dark raphe
-- seam, one still half-wrapped in glossy white pulp) on a torn scrap of cacao leaf (V-fold, midrib, angled veins,
-- wet gloss streak, torn base, drip tip). The upper bean has germinated: a slim stem rises to the true cacao leaf
-- shape (oblong, drip tip, pale midrib). Ambient shading and contact shadows under each bean; auto-centred.
-- Draft by Sonnet replaced.
-- quirk: the newest leaf is flushed pink-bronze and hangs limp, just like real cacao flush growth.
local NAME = "cacao-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_b2g7.lua")
local HP, X, c = G.new(NAME)
local K = G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local LEAF  = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" }
local VEIN, GLOSS, COOL = "#bfe28a", "#dff2a8", "#3c6f74"
local BEAN  = { "#2a1124", "#4c1c36", "#712c46", "#964352", "#bb6564", "#e0977e" }
local PULP  = { "#a99a9a", "#cbbcb4", "#e3d6c8", "#f2e8d8", "#fbf4e6", "#fffaf0" }
local FLUSH = { "#4a1730", "#74243c", "#a23a48", "#c95c55", "#e4886a", "#f6b88e" }
local STEM  = { "#3d4a2a", "#5f6e36", "#8a9448", "#b4b86a" }

-- 1. leaf scrap: torn base at the lower left, drip tip to the right
local lm, ln, LT, LS, len = G.blade(9, 52, 30, 56, 56, 41, function(t)
  if t > 0.985 then return -1 end
  if t > 0.86 then return max(0.45, 1.6 * (1 - (t - 0.86) / 0.13)) end
  return max(0.6, 7.2 * (1 - t ^ 2.2) ^ 0.75 * (0.82 + 0.18 * sin(pi * min(1, t * 1.6))))
end, { fold = 0.42 })
-- torn base: ragged bite out of the start of the scrap
lm:each(function(x, y) local k = K(x, y)
  if LT[k] * len < 1.0 + 2.2 * (floor((LS[k] + 1) * 3.5) % 2) + X.hash(x, y, 9) then lm.s[k] = nil end end)

-- 2. beans (rotated ovals); upper-left bean is pulp-wrapped
local beans = {   -- cx, cy, rx, ry, ang, tilt x, tilt y
  { 23, 46, 7.0, 4.5, -0.3, -0.1, -0.12 },
  { 37, 42, 6.8, 4.4, -0.6, 0.1, -0.15 },
}
for _, b in ipairs(beans) do
  local m, n = G.oval(b[1], b[2], b[3], b[4], b[5], 0.8)
  for k, v in pairs(n) do n[k] = { G.norm(v[1] + b[6], v[2] + b[7], v[3]) } end
  b.m, b.n = m, n
end
local pulp, pulpN = G.oval(22.4, 45.6, 7.6, 5.2, -0.3, 1)
pulp:cut(beans[2].m)
-- leave the right end of bean 1 bare (pulp torn back): cut a bite on the right side of the pulp
pulp:each(function(x, y) if (x - 22) * 1.0 - (y - 46) * 0.6 > 0.4 + 1.1 * sin(y * 1.9) then pulp.s[K(x, y)] = nil end end)
-- pulp drip running down onto the leaf
local drip = HP.mask()
for _, p in ipairs{ {19, 49}, {19, 50}, {20, 50}, {19, 51}, {19, 52} } do drip:set(p[1], p[2]) end

-- 3. sprout stem from the top end of bean 2, curving up, two leaves
local stemM, sT = G.sweep({ { 42, 38 }, { 44, 31 }, { 38, 26 }, { 40, 18 } }, function(t) return 0.75 end, 80)
local leafA, lAn, lAT, lAS, lAlen = G.blade(40, 19, 30, 14, 18, 10, function(t)       -- mature leaf, up-left
  if t > 0.985 then return -1 end
  if t > 0.86 then return max(0.45, 1.0 * (1 - (t - 0.86) / 0.13)) end
  return max(0.6, 3.9 * sin(pi * min(1, t * 0.86 + 0.08)) ^ 0.75)
end, { fold = 0.45 })
local leafB, lBn, lBT, lBS, lBlen = G.blade(41, 19, 50, 18, 51, 31, function(t)      -- limp pink flush leaf
  if t > 0.985 then return -1 end
  if t > 0.86 then return max(0.45, 0.9 * (1 - (t - 0.86) / 0.13)) end
  return max(0.5, 3.3 * sin(pi * min(1, t * 0.86 + 0.08)) ^ 0.8)
end, { fold = 0.5 })

-- tone the leaf scrap with AO / contact shadows from beans, pulp, stem
local occ = HP.mask() for _, b in ipairs(beans) do occ:add(b.m) end occ:add(pulp):add(drip)
local lb = {}
X.ao(lb, lm, occ, 1, -1) G.cast(lb, lm, occ, 1, 2, -1) G.cast(lb, lm, occ, 2, 3, -1)
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = lb, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.2 })
local function veins(m, T, S, L, ramp, list, slant, tok, skip, vein, gloss)
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if skip and skip[k] then return end
    if abs(s) < 0.13 and t > 0.03 and t < 0.9 then c:put(x, y, s <= 0 and vein or ramp[3], tok) return end
    for _, vt in ipairs(list) do
      local d = t * L - (vt + abs(s) * slant)
      if d > -0.55 and d < 0.55 and abs(s) > 0.2 and abs(s) < 0.75 then c:put(x, y, s < 0 and ramp[6] or ramp[2], tok) return end
    end
    if gloss and s < -0.38 and s > -0.62 and t > 0.55 and t < 0.75 then c:put(x, y, gloss, tok) end
  end)
end
veins(lm, LT, LS, len, LEAF, { 6, 12, 18, 24, 30, 36 }, 5, ltok, lb, VEIN, GLOSS)
lm:edge():each(function(x, y) local k = K(x, y)
  if not lb[k] and LS[k] > 0.6 and LT[k] > 0.15 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end end)

-- beans (bean 1 first, bean 2 overlaps it)
for i, b in ipairs(beans) do
  local vis = b.m:copy()
  local bb = {}
  for j = i + 1, #beans do vis:cut(beans[j].m) X.ao(bb, b.m, beans[j].m, 1, -1) G.cast(bb, b.m, beans[j].m, 1, 1, -1) end
  if i == 2 then X.ao(bb, b.m, stemM, 1, -1) end
  local tok = { r = { name = "bean" .. i } }
  local v = X.light(b.n, { amb = 0.08, wrap = 0.25 })
  X.tone(c, vis, v, BEAN, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bb, tok = tok })
  -- raphe seam: a slightly curved dark line along the long axis, on the lit half
  local ca, sa = cos(b[5]), sin(b[5])
  for u = -b[3] + 1.5, b[3] - 1.5, 0.5 do
    local vv = -0.9 + 0.08 * u * u / b[3]
    local x, y = floor(b[1] + u * ca - vv * sa + .5), floor(b[2] + u * sa + vv * ca + .5)
    if vis:has(x, y) then c:put(x, y, BEAN[2], tok) end
  end
  local sx, sy = G.specAt(vis, b.n, 30)
  if sx then c:put(sx, sy, "#fbe6d8", tok) end
end

-- pulp: glossy white, wet edge darker, one bright spec
local pb = {}
X.ao(pb, pulp, beans[2].m, 1, -1)
local ptok = { r = { name = "pulp" } }
X.tone(c, pulp, X.light(pulpN, { amb = 0.15, wrap = 0.3 }), PULP, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = pb, tok = ptok })
-- torn pulp edge: darker lip toward the bare bean
pulp:edge():each(function(x, y) if beans[1].m:has(x + 1, y) and not pulp:has(x + 1, y) then c:put(x, y, PULP[2], ptok) end end)
c:put(19, 43, "#fffaf0", ptok) c:put(20, 43, "#fffaf0", ptok) c:put(21, 42, PULP[5], ptok)
for _, p in ipairs{ {19, 49, 4}, {19, 50, 3}, {20, 50, 2}, {19, 51, 4}, {19, 52, 5} } do c:put(p[1], p[2], PULP[p[3]], ptok) end

-- stem: 2 px, lit left edge, darker right edge
local stok = { r = { name = "stem" } }
local _, sn = nil, {}
stemM:each(function(x, y) local lft = stemM:has(x - 1, y) local rgt = stemM:has(x + 1, y)
  local col = (not lft) and STEM[4] or ((not rgt) and STEM[2] or STEM[3])
  if beans[2].m:has(x, y) then return end
  c:put(x, y, col, stok) end)

-- leaves on the sprout
local atok = { r = { name = "leafA" } }
leafA:cut(stemM)
G.toneN(c, leafA, lAn, LEAF, { tok = atok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.25 })
veins(leafA, lAT, lAS, lAlen, LEAF, { 4, 8, 12 }, 3.2, atok, nil, VEIN)
local btok = { r = { name = "leafB" } }
local bbias = {}
X.ao(bbias, leafB, stemM, 1, -1)
leafB:cut(stemM)
G.toneN(c, leafB, lBn, FLUSH, { bias = bbias, tok = btok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.25 })
veins(leafB, lBT, lBS, lBlen, FLUSH, { 4, 8 }, 3.0, btok, bbias, FLUSH[6])
-- stem tip: tiny folded bud between the two leaves
c:put(40, 17, STEM[3], stok) c:put(40, 16, FLUSH[4], stok)

G.centre(c)
G.save(c, NAME)
