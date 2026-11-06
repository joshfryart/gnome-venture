-- pigeon-pea-seed (final pass, Opus). Three round pigeon peas (cream-beige coat, purple-brown mottling, a pale
-- oval hilum each) on a torn scrap of a lanceolate pigeon-pea leaflet (grey-green, pinnate veins, pale midrib,
-- ragged torn base, intact pointed tip, V-fold light, cool reflected edge, AO + contact shadow under each pea).
-- The right pea has germinated: a slim stem with the plant's trifoliate leaf (three narrow lanceolate leaflets).
-- quirk: the sprouting pea's pale root curls into a little pigtail hook over the leaf edge.
-- History: Sonnet draft replaced.
local NAME = "pigeon-pea-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#1e3c36", "#2b5843", "#3d744c", "#589257", "#7fb06a", "#b0cf8e" }
local VEIN, COOL = "#c6e2a0", "#3a6a72"
local PEA  = { "#4a2c2c", "#7a503c", "#a87c52", "#cca46e", "#e6c896", "#f8e8c0" }
local MOT  = { "#3a2030", "#56303e", "#744652", "#90606a" }
local STEM = { "#4a7e50", "#7eae66", "#b2d48c", "#def0b8" }
local ROOT = { "#9a7c62", "#ccb08c", "#eedcb8", "#fff4d6" }

local seeds = { { 17, 48, 3.7, 3.3 }, { 27, 45, 3.8, 3.4 }, { 39, 42, 3.6, 3.3 } }
for _, s in ipairs(seeds) do s.m = c:ellipse(s[1], s[2], s[3], s[4]) end

-- leaflet scrap: torn base on the left, pointed tip on the right
local lm, ln, LT, LS, len = A.blade(7, 52, 32, 52, 58, 38, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 7.4 * sin(pi * min(1, t * 0.82 + 0.18)) ^ 0.9)
end, { fold = 0.4 })
local cut = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  local d = t * len
  local rag = 1.0 + 2.6 * X.hash(floor(s * 4 + 0.5), 3, 11) + 1.0 * abs(sin(s * 6))
  if d < rag then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.04 and t < 0.93 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local d = (t * len - abs(s) * 6.5) % 5.2
  if d < 0.9 and abs(s) > 0.15 and abs(s) < 0.78 and t > 0.08 and t < 0.86 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.1 and LT[k] < 0.92 then c:put(x, y, COOL, ltok) end end)

-- quirk: pigtail root from the sprouting pea, hooking over the lower leaf edge
local rtok = { r = { name = "root" } }
local rm, rn = A.tube({ { 41, 45 }, { 44, 52 }, { 50, 53 }, { 48, 48 } }, function(t) return 1.1 * (1 - t) + 0.45 end)
rm:cut(seeds[3].m)
A.shade(c, rm, rn, ROOT, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = rtok })
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not seeds[3].m:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- sprout: stem + trifoliate leaf
local stok = { r = { name = "stem" } }
local sm, sn = A.tube({ { 39, 40 }, { 38, 33 }, { 40, 27 }, { 39, 21 } }, function(t) return 1.05 end)
sm:cut(seeds[3].m)
A.shade(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function leaflet(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.86 + 0.1)) ^ 0.7)
  end, { fold = 0.35 })
  m:cut(sm)
  local idx = A.shade(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.16 and T[k] > 0.08 and T[k] < 0.85 then
    c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local tl = leaflet(39, 20, 39, 14, 40, 7, 2.6)
local ll = leaflet(38, 21, 33, 19, 27, 14, 2.3)
local rl = leaflet(40, 21, 45, 20, 51, 16, 2.3)
-- pulvinus knot where the leaflets meet
c:put(39, 21, STEM[2], stok) c:put(40, 21, STEM[1], stok) c:put(39, 20, STEM[3], stok)

-- peas last: sphere light, mottling, hilum, glint
for i, s in ipairs(seeds) do
  local m = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do m:cut(seeds[j].m) end
  if i < #seeds then X.ao(sb, m, seeds[i + 1].m, 1, -1) end
  local n = X.sphere(s[1] - 0.3, s[2] - 0.3, s[3] + 0.3, m)
  local tok = { r = { name = "pea" .. i } }
  local idx = A.shade(c, m, n, PEA, { amb = 0.05, wrap = 0.22, tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, bias = sb })
  m:each(function(x, y) local k = K(x, y)
    local h = X.hash(floor((x + i) / 2), floor((y + i * 3) / 2), 5 + i)
    if h > 0.68 and idx[k] and idx[k] < 6 then
      local j = max(1, min(4, idx[k] - 1)) c:put(x, y, MOT[j], tok)
    end
  end)
  -- hilum: pale 2x1 oval with a dark lip, on the lower-right face
  local hx, hy = s[1] + 1, s[2] + 1
  if i == 3 then hx, hy = s[1] - 2, s[2] + 1 end
  c:put(hx, hy, PEA[6], tok) c:put(hx + 1, hy, PEA[5], tok) c:put(hx, hy + 1, PEA[2], tok) c:put(hx + 1, hy + 1, PEA[2], tok)
  -- glint
  c:put(s[1] - 2, s[2] - 2, "#fff4d6", tok) c:put(s[1] - 1, s[2] - 2, PEA[6], tok)
end
-- germination split at the stem foot
c:px(38, 39, PEA[2]) c:px(40, 39, PEA[2]) c:px(39, 39, STEM[2])

A.save(c, NAME)
