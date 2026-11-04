-- rosemary-seed (final pass, Sonnet). Five tiny mottled-brown rosemary nutlets (pale basal scar) lying along a
-- torn strap of a real rosemary leaf: dark glossy upper face with a sunk midrib groove, rolled margin showing the
-- silver underside, the left end curled over to show the white felted underside. The right seed has germinated: a
-- slim stem with two small round cotyledons and opposite pairs of needle leaves that shorten toward a bud.
-- quirk: a dewdrop hangs from the tip of one sprout needle.
local NAME = "rosemary-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_3.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local LEAF = { "#102a2e", "#17413a", "#235c46", "#37795a", "#58997a", "#8cbf9c" }
local SILV = { "#6e8a8c", "#93aeaa", "#b8cfc6", "#d6e6dc", "#eaf3ea", "#f8fcf4" }
local NEED = { "#27583a", "#3c7a44", "#58a050", "#7cc462", "#a8dc7e", "#d4f0a0" }
local STEM = { "#5a4a6a", "#7e9a6a", "#a6c88a", "#cde4a8" }
local SEED = { "#241510", "#40261b", "#63402a", "#865a38", "#ab7c4c", "#d6a870" }
local DROP = { "#2d4f86", "#4f86c8", "#8cc4f0", "#d2f2ff" }
local CUTS = A.CUTS
local ltok = { r = { name = "leaf" } }

local seeds = { { 19, 54, 3.2, 2.2, 0.15 }, { 26, 52.5, 3.2, 2.2, -0.3 }, { 33, 53.5, 3.2, 2.2, 0.4 }, { 39.5, 51.5, 3.1, 2.1, -0.15 },
  { 47, 50, 3.3, 2.3, -1.45 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.85) end

-- leaf strap
local lm, ln, LT, LS, len = G.blade(7, 56, 30, 49, 54, 53, function(t)
  if t > 0.99 then return -1 end
  return max(0.6, 4.8 * sin(pi * (0.07 + 0.86 * t)) ^ 0.32)
end, { fold = 0.3 })
local tear = HP.mask()
lm:each(function(x, y) local k = K(x, y)
  local t = LT[k]
  -- ragged diagonal tear at the right end
  if t > 0.9 - 0.035 * ((x * 2 + y) % 4) - 0.02 * (LS[k] + 1) then tear:set(x, y) end
end)
lm:cut(tear)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if t < 0.17 then   -- curled-over end: white felted underside
    c:put(x, y, SILV[max(1, min(6, 2 + floor((1 - (s + 1) / 2) * 3.4 + (X.hash(x, y, 2) > 0.7 and 1 or 0))))], ltok)
    if abs(t - 0.165) < 0.012 then c:put(x, y, LEAF[1], ltok) end
    return
  end
  if bias[k] then return end
  if abs(s) < 0.11 then c:put(x, y, LEAF[1], ltok) return end             -- sunk midrib groove
  if abs(s) < 0.24 and s < 0 then c:put(x, y, LEAF[5], ltok) return end    -- lit lip of the groove
  if s > 0.8 and (x + y) % 2 == 0 then c:put(x, y, SILV[2], ltok) return end   -- rolled margin: silver peeking under
  if s < -0.82 then c:put(x, y, LEAF[6], ltok) return end
  if X.hash(x, y, 7) > 0.93 then c:put(x, y, LEAF[5], ltok) end           -- waxy fleck
end)
-- torn fibres
lm:each(function(x, y) local k = K(x, y)
  if LT[k] > 0.78 and not lm:has(x + 1, y) and X.hash(x, y, 9) > 0.5 and not bias[k] then c:put(x, y, SILV[3], ltok) end end)

-- sprout from germinated seed
local stok = { r = { name = "stem" } }
local D = seeds[5]
local sm, sn = G.tube({ { 47, 47 }, { 46, 38 }, { 47, 27 }, { 46, 15 } }, function(t) return 1.05 - 0.3 * t end)
sm:cut(D.m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function cot(ax, ay, cx, cy, bx, by)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.6, 2.0 * sin(pi * min(1, t * 0.88 + 0.1)) ^ 0.5)
  end, { fold = 0.3 })
  m:cut(sm)
  G.toneN(c, m, n, NEED, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  return m
end
cot(46, 45, 41, 43.5, 37, 45)
cot(48, 45, 53, 43.5, 57, 45)
-- opposite needle pairs, shortening upward
local ntok = { r = { name = "needle" } }
local pairsY = { { 40, 8.5, 1.0 }, { 35, 8, 0.95 }, { 30.5, 7, 0.9 }, { 26, 6, 0.85 }, { 22, 5, 0.8 }, { 18.5, 4, 0.75 } }
local dropx, dropy
for i, p in ipairs(pairsY) do
  local y, L, a = p[1], p[2], p[3]
  local x = 46 + (46.5 - 46) * (i / 6)
  A.needle(c, x, y, -pi / 2 - a, L, 0.8, NEED, ntok, { bias = -1 })
  A.needle(c, x, y, -pi / 2 + a, L, 0.8, NEED, ntok)
  if i == 2 then dropx, dropy = floor(x + cos(-pi / 2 - a) * L + 0.5), floor(y + sin(-pi / 2 - a) * L + 0.5) end
end
A.needle(c, 46, 15, -pi / 2, 4, 0.7, NEED, ntok)
A.needle(c, 46, 15, -pi / 2 - 0.5, 3, 0.6, NEED, ntok) A.needle(c, 46, 15, -pi / 2 + 0.5, 3, 0.6, NEED, ntok)
-- dewdrop (quirk)
do
  local dm = c:ellipse(dropx + 0.5, dropy + 2.5, 1.5, 1.5)
  local dn = X.sphere(dropx + 0.5, dropy + 2.5, 1.6, dm)
  local dtok = { r = { name = "drop" } }
  G.toneN(c, dm, dn, DROP, { tok = dtok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.1, wrap = 0.3 })
  c:put(dropx, dropy + 1, DROP[4], dtok)
end

-- seeds: tiny mottled nutlets with a pale scar
for i, s in ipairs(seeds) do
  local sb = {}
  for j = i + 1, #seeds do X.ao(sb, s.m, seeds[j].m, 1, -1) end
  s.m:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 30 + i)
    sb[k] = (sb[k] or 0) + (h < 0.2 and -1 or (h > 0.82 and 1 or 0)) end)
  local tok = { r = { name = "seed" .. i } }
  G.toneN(c, s.m, s.n, SEED, { bias = sb, tok = tok, cuts = CUTS, amb = 0.12, wrap = 0.3 })
  local ca, sa = cos(s[5]), sin(s[5])
  local bx, by = floor(s[1] - ca * (s[3] - 0.4) + 0.5), floor(s[2] - sa * (s[3] - 0.4) + 0.5)
  if i < 5 and s.m:has(bx, by) then c:put(bx, by, "#f0e4c0", tok) end
  local sx, sy = G.specAt(s.m, s.n, 30)
  if sx then c:put(sx, sy, SEED[6], tok) end
end
-- cracked seed: pale kernel at the stem foot
c:put(47, 47, "#efe2b0", { r = { name = "kernel" } }) c:put(46, 47, "#cdb982", { r = { name = "kernel" } })
G.save2(c, NAME)
