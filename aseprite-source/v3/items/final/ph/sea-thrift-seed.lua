-- sea-thrift-seed (D15, final pass, Sonnet). Torn scrap of a thrift (Armeria) strap leaf, blue-green and fleshy, with
-- parallel veins and a ragged cream fibre edge at the tear. On it: two bare tan seeds, one seed still wrapped in its
-- papery pink-silver ribbed calyx funnel, and a germinating seed that has split its coat and sent up a fan of narrow
-- grass-like blades (the thrift tuft) plus a white radicle curling over the leaf. Each seed has ribbed back, pale
-- hilum, bevel light and a contact shadow cast on the leaf.
-- quirk: the seedling has jumped the gun: a tiny pink pom-pom flower already tops a thin scape between the blades.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_0.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("sea-thrift-seed")

local LEAF = { "#173a45", "#1f5560", "#2b7573", "#3f9a86", "#6cbd9a", "#a8e0b8" }
local TAN = { "#3e241e", "#64402c", "#8c5e3a", "#b48650", "#d6ac6c", "#f2d49a" }
local PAP = { "#76506e", "#a47c94", "#cca6b6", "#ecc8cc", "#f8e4dc", "#fff6ee" }
local PINK = { "#7d2c5e", "#a8467a", "#d4659a", "#f5809f", "#ffa8c0", "#ffd8e4" }
local BLD = { "#1a4a48", "#256a5e", "#38907a", "#58b496", "#88d4ac", "#c0f0c8" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local ltok, btok = { r = { name = "leaf" } }, { r = { name = "blade" } }

-- parts that sit on the leaf (masks first so the leaf can take their shadows) -----------------------------------------
local seeds = {
  { 15, 51, 4.0, 2.4, -0.25 }, { 24, 54.5, 3.7, 2.2, 0.35 }, { 51, 49, 3.9, 2.3, -0.4 },
}
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end
-- germinating seed (centre)
local gs = { 32, 50, 3.9, 2.6, 0.1 }
gs.m, gs.n = G.oval(gs[1], gs[2], gs[3], gs[4], gs[5], 0.8)
-- calyx funnel
local cal = { { 39, 54 }, { 41, 52 }, { 44, 50 }, { 46, 47 } }
local cm, cn, CT, CS = G.tube(cal, function(t) return 1.3 + 1.9 * t end)
local allTop = HP.mask()
for _, s in ipairs(seeds) do allTop:add(s.m) end
allTop:add(gs.m):add(cm)

-- leaf scrap ----------------------------------------------------------------------------------------------------------
local lm, ln, LT, LS, len = G.blade(7, 50, 30, 56, 58, 47, function(t)
  if t > 0.99 then return -1 end
  local w = 5.4 + 0.5 * sin(t * 3.2)
  if t > 0.8 then w = w * (1 - ((t - 0.8) / 0.2) ^ 1.6 * 0.9) end   -- pointed leaf tip on the right
  return max(0.5, w)
end, { fold = 0.18 })
-- torn left end: ragged boundary
local tear = {}
lm:each(function(x, y)
  local xt = 9 + ((y * 7 + 3) % 6) - 2 + (y > 50 and 1 or 0)
  if x < xt then tear[#tear + 1] = { x, y } end
end)
for _, p in ipairs(tear) do lm.s[K(p[1], p[2])] = nil end
local lbias = {}
X.ao(lbias, lm, allTop, 1, -1)
G.cast(lbias, lm, allTop, 1, 2, -1)
local lidx = G.toneN(c, lm, ln, LEAF, { bias = lbias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.15, wrap = 0.28 })
-- parallel veins (linear leaf) + pale midrib
lm:each(function(x, y) local k = K(x, y)
  if lbias[k] then return end
  local s, t = LS[k], LT[k]
  local i = lidx[k] or 3
  if abs(s) < 0.1 and t > 0.05 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok)
  elseif (abs(abs(s) - 0.52) < 0.09) and t > 0.08 and t < 0.9 then c:put(x, y, s < 0 and LEAF[min(6, i + 1)] or LEAF[max(1, i - 1)], ltok) end
end)
-- cool reflected edge + cream torn fibres
lm:edge():each(function(x, y) local k = K(x, y)
  if LS[k] > 0.7 and LT[k] > 0.2 and not lbias[k] then c:put(x, y, "#3e8c92", ltok) end end)
lm:each(function(x, y)
  if not lm:has(x - 1, y) and LT[K(x, y)] < 0.15 then c:put(x, y, X.hash(x, y, 2) > 0.5 and "#e4f0d0" or "#c0d8b0", ltok) end end)
c:put(9, 53, "#e4f0d0", ltok)

-- radicle curling over the leaf (white root with tiny hairs)
local rad, rn, RT, RS = G.tube({ { 29, 51 }, { 27, 53 }, { 24, 52 }, { 22, 50 } }, function(t) return 0.9 - 0.3 * t end)
rad:cut(gs.m):cut(seeds[2].m)
X.tone(c, rad, X.light(rn, { amb = 0.2, wrap = 0.3 }), { "#9a8a78", "#d8cdb4", "#f2ead2", "#fffaec" }, { cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "root" } } })
c:put(25, 51, "#f2ead2") c:put(23, 51, "#d8cdb4")

-- sprout: fan of narrow blades + scape + pom-pom (behind the germinating seed) --------------------------------------
local function blade(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    return max(0.45, w * (1 - t ^ 2.2) + 0.35)
  end, { fold = 0.3 })
  local idx = G.toneN(c, m, n, BLD, { tok = btok, cuts = CUTS, amb = 0.12, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.17 and T[k] > 0.05 and T[k] < 0.92 then c:put(x, y, S[k] <= 0 and BLD[6] or BLD[3], btok) end end)
  return m
end
local sbases = {
  { 31, 49, 22, 40, 12, 22, 1.5 },   -- far left, leaning out
  { 31, 49, 28, 34, 22, 10, 1.7 },   -- left, upright
  { 33, 49, 39, 34, 45, 11, 1.7 },   -- right, upright
  { 34, 49, 44, 40, 53, 23, 1.5 },   -- far right
}
local bladeM = {}
for _, b in ipairs(sbases) do bladeM[#bladeM + 1] = blade(b[1], b[2], b[3], b[4], b[5], b[6], b[7]) end
-- scape
local sc, scn = G.tube({ { 32, 49 }, { 32, 40 }, { 33, 30 }, { 32, 21 } }, function(t) return 0.95 end)
X.tone(c, sc, X.light(scn, { amb = 0.15, wrap = 0.3 }), { "#3a6a52", "#6aa078", "#a4c88c", "#d4e8a8" }, { cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "scape" } } })
-- pom-pom head: pink sphere with floret bumps
local hx, hy, hr = 32, 16, 4.4
local hm = c:ellipse(hx, hy, hr, hr)
local hv = X.light(X.sphere(hx, hy, hr, hm), { amb = 0.06, wrap = 0.2 })
local htok = { r = { name = "pom" } }
local hidx = X.tone(c, hm, hv, PINK, { cuts = CUTS, tok = htok })
hm:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 31)
  if h > 0.72 then c:put(x, y, PINK[min(6, (hidx[k] or 3) + 1)], htok) elseif h < 0.2 then c:put(x, y, PINK[max(1, (hidx[k] or 3) - 1)], htok) end end)
-- papery sheath cup under the head
for _, p in ipairs{ { 30, 20 }, { 31, 20 }, { 32, 20 }, { 33, 20 }, { 34, 20 }, { 31, 21 }, { 32, 21 }, { 33, 21 } } do c:put(p[1], p[2], p[1] < 32 and PAP[5] or PAP[3], htok) end
c:put(30, 12, PINK[6], htok) c:put(31, 12, PINK[6], htok) c:put(30, 13, A.CREAM, htok)

-- seed painter (ribbed back, pale hilum, bevel, bristle-free) -----------------------------------------------------------
local function paintSeed(s, mask, i)
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  mask:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), flip * (-dx * sa + dy * ca) / (s[4] + .45)
    local t
    if v < -0.6 then t = 5 elseif v < -0.1 then t = 4 elseif v < 0.3 then t = 3 elseif v < 0.65 then t = 3 else t = 2 end
    -- fine lengthwise ridges: dark line at v ~ 0.1 and 0.5
    if abs(v - 0.12) < 0.1 and abs(u) < 0.8 then t = 2 end
    if abs(u) > 0.88 then t = max(1, t - 1) end
    if u < -0.2 and u > -0.7 and v < -0.15 and v > -0.6 then t = 6 end
    -- hilum scar on the lower tip
    if u > 0.78 and abs(v) < 0.4 then t = 6 end
    c:put(x, y, TAN[max(1, min(6, t))], tok)
  end)
end
for i, s in ipairs(seeds) do paintSeed(s, s.m, i) end

-- calyx funnel (papery, ribbed, translucent look) -----------------------------------------------------------------------
do
  local tok = { r = { name = "calyx" } }
  local v = X.light(cn, { amb = 0.12, wrap = 0.3 })
  local idx = X.tone(c, cm, v, PAP, { cuts = CUTS, tok = tok })
  cm:each(function(x, y) local k = K(x, y)
    local i = idx[k] or 3
    local rib = (CS[k] * 3.4) % 1
    if rib < 0.22 then c:put(x, y, PAP[max(1, i - 2)], tok) end
    if CT[k] > 0.84 then c:put(x, y, PAP[min(6, i + 1)], tok) end      -- frilly lip
  end)
  -- dark mouth with the tan seed top inside
  for _, p in ipairs{ { 45, 46 }, { 46, 46 }, { 47, 46 }, { 46, 45 }, { 47, 45 }, { 47, 47 } } do if cm:has(p[1], p[2]) then c:put(p[1], p[2], "#4a2e3a", tok) end end
  c:put(46, 46, TAN[4], tok) c:put(47, 45, TAN[5], tok)
end

-- germinating seed: split coat with the sprout poking out ----------------------------------------------------------------
paintSeed(gs, gs.m, 9)
for _, p in ipairs{ { 31, 49 }, { 32, 49 }, { 33, 49 }, { 31, 50 }, { 32, 50 } } do c:put(p[1], p[2], p[2] == 49 and "#d4e8a8" or "#6aa078", btok) end
c:put(34, 51, TAN[1]) c:put(30, 51, TAN[1])      -- split seam in the coat

-- glints on the front seed
c:put(51 - 2, 49 - 1, "#fff4d6") c:put(15 - 2, 51 - 1, "#fff4d6")
A.save(c, "sea-thrift-seed")
