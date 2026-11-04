-- moth-orchid-seed (final pass, Opus). Orchid seed is dust, so: a slim dried seed capsule (six-ribbed, split along
-- one seam) lies on a torn scrap of thick waxy phalaenopsis leaf (keeled V fold, parallel veins, long waxy bloom
-- streak, ragged torn end), spilling golden dust seeds that each cast a 1px contact shadow. At the right a seedling
-- grows from a green protocorm: two broad oblong moth-orchid leaves with a keel groove and a small new leaf between.
-- quirk: a silvery aerial root with a green growing tip curls off the leaf edge into a little loop.
local NAME = "moth-orchid-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#123a30", "#1c5236", "#28703f", "#3d904a", "#66b45a", "#a8dc80" }
local BLOOM = "#cdeaa8"
local SPR  = { "#1f4f36", "#2e7044", "#45924e", "#6bb35c", "#9bd275", "#d2f0a4" }
local POD  = { "#3e2a22", "#5e4030", "#86603e", "#ad8650", "#d2ad72", "#f0d69c" }
local DUST = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local ROOT = { "#4a5c5c", "#7a948e", "#a8c2b6", "#d8ebe0" }

-- leaf scrap: torn left end, natural obtuse tip right
local lm, ln, LT, LS, llen = A.blade(7, 53, 28, 57, 55, 42, function(t)
  if t > 0.4 then local q = (t - 0.4) / 0.6 return 5.6 * sqrt(max(0, 1 - q ^ 2.2)) end
  return 5.0 + 0.6 * t / 0.4
end, { fold = 0.3 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  -- ragged tear: a zigzag across the base
  local z = 0.035 + 0.035 * abs(((LS[k] * 3.3) % 2) - 1) + 0.02 * X.hash(x, y, 3)
  if LT[k] < z then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- pod, sprout and root masks first (for AO / contact shadow on the leaf)
local podPts = { { 11, 50 }, { 17, 46 }, { 25, 45 }, { 31, 48 } }
local pm, pn, PT, PS = A.tube(podPts, function(t) return 0.3 + 2.4 * sin(pi * t) ^ 0.55 end)
local rootPts = { { 45, 48 }, { 50, 49 }, { 53, 54 }, { 50, 57 } }
local rm, rn, RT, RS = A.tube(rootPts, function(t) return t > 0.97 and 0.5 or 1.05 end)
local proto = A.rell(43.5, 46.5, 1, 0, 2.6, 2.1)

local bias = {}
for _, m in ipairs{ pm, rm, proto } do X.ao(bias, lm, m, 1, -1) A.cast(bias, lm, m, 1, 1, -1) end
local ltok = { r = { name = "leaf" } }
A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, amb = 0.14, wrap = 0.3, cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 } })
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s, t = LS[k], LT[k]
  -- keel (midrib groove) and parallel veins
  if abs(s) < 0.1 and t > 0.08 and t < 0.92 then c:put(x, y, LEAF[2], ltok) return end
  if (abs(abs(s) - 0.5) < 0.07) and t > 0.1 and t < 0.86 then c:put(x, y, s < 0 and LEAF[5] or LEAF[3], ltok) return end
  -- waxy bloom streak on the lit half
  if s > -0.42 and s < -0.24 and t > 0.3 and t < 0.66 then c:put(x, y, BLOOM, ltok) end
end)
-- torn edge: pale fibrous rim
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] < 0.11 then c:put(x, y, (X.hash(x, y, 8) > 0.5) and LEAF[6] or BLOOM, ltok) end end)
-- cool reflected light on the lower shade edge
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and LS[k] > 0.7 and LT[k] > 0.14 and LT[k] < 0.85 then c:put(x, y, "#3c6e74", ltok) end end)

-- spilled dust seeds on the leaf (seed + contact shadow)
local dtok = { r = { name = "dust" } }
for _, d in ipairs{ { 21, 46, 2 }, { 24, 48, 1 }, { 27, 46, 2 }, { 30, 49, 1 }, { 33, 46, 2 }, { 19, 49, 1 }, { 35, 50, 1 }, { 26, 51, 1 }, { 37, 47, 1 } } do
  local x, y = d[1], d[2] + 4
  if not lm:has(x, y) then goto continue end
  if lm:has(x + 1, y + 1) then c:put(x + 1, y + 1, LEAF[1], ltok) end
  c:put(x, y, DUST[3], dtok)
  if d[3] == 2 then c:put(x + 1, y, DUST[2], dtok) if lm:has(x + 2, y + 1) then c:put(x + 2, y + 1, LEAF[1], ltok) end end
  ::continue::
end

-- pod: ribbed, split seam with gold seeds inside
local ptok = { r = { name = "pod" } }
local pidx = A.shade(c, pm, pn, POD, { tok = ptok, amb = 0.1, wrap = 0.3 })
pm:each(function(x, y) local k = K(x, y)
  local s, t = PS[k], PT[k]
  if abs(s + 0.45) < 0.12 and t > 0.12 and t < 0.88 then c:put(x, y, POD[max(1, pidx[k] - 2)], ptok) end   -- rib groove
  if abs(s - 0.4) < 0.12 and t > 0.12 and t < 0.88 then c:put(x, y, POD[max(1, pidx[k] - 1)], ptok) end
  if abs(s) < 0.14 and t > 0.3 and t < 0.74 then  -- split seam
    c:put(x, y, (X.hash(x, y, 4) > 0.45) and DUST[3] or POD[1], ptok)
  end
end)
-- dried pedicel at the right end, withered flower column at the left
c:put(32, 49, POD[2], ptok) c:put(33, 50, POD[1], ptok)
c:put(10, 50, POD[1], ptok) c:put(9, 49, POD[2], ptok) c:put(10, 49, POD[3], ptok)
-- glint on the capsule
c:put(18, 45, POD[6], ptok) c:put(19, 45, POD[6], ptok)

-- aerial root (quirk): silvery velamen, green tip, curls into a loop past the leaf edge
local rtok = { r = { name = "root" } }
local ridx = X.tone(c, rm, X.light(rn, { amb = 0.15, wrap = 0.3 }), ROOT, { cuts = { 0.3, 0.55, 0.8 }, tok = rtok })
rm:each(function(x, y) local k = K(x, y) if RT[k] > 0.84 then c:put(x, y, (RS[k] < 0) and SPR[5] or SPR[3], rtok) end end)
-- loop: little curl at the end
A.map(c, 47, 57, { ".ab", "a.." , ".a." }, { a = ROOT[2], b = SPR[4] }, rtok)

-- seedling leaves
local stok = { r = { name = "sprout" } }
local function leaf(ax, ay, cx, cy, bx, by, W)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.95 + 0.08)
    return max(0.6, W * sin(pi * u) ^ 0.45)
  end, { fold = 0.35 })
  m:cut(proto)
  A.shade(c, m, n, SPR, { tok = stok, amb = 0.12, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.12 and T[k] > 0.08 and T[k] < 0.86 then c:put(x, y, S[k] <= 0 and SPR[3] or SPR[2], stok) end end)
  return m, n
end
local lL, nL = leaf(42, 45, 35, 35, 26, 31, 3.4)
local lR, nR = leaf(45, 44, 51, 33, 58, 30, 3.2)
local lN = leaf(43, 44, 42, 40, 44, 36, 1.4)
-- AO where leaves meet the protocorm, deep line between the middle leaf and the big leaves
for _, m in ipairs{ lL, lR } do lN:grow(1):cut(lN):each(function(x, y) if m:has(x, y) then c:put(x, y, SPR[1], stok) end end) end
-- waxy spec on the left leaf
local sx, sy = A.specAt(lL, nL, 30)
c:put(sx, sy, SPR[6], stok) c:put(sx - 1, sy, SPR[6], stok)

-- protocorm: small green bulb with a pale fuzz rim
local ctok = { r = { name = "proto" } }
A.shade(c, proto, X.sphere(43.5, 46.5, 2.6, proto), SPR, { tok = ctok, amb = 0.1, wrap = 0.2 })
proto:edge():each(function(x, y) if y >= 48 then c:put(x, y, SPR[2], ctok) end end)

A.save(c, NAME)
