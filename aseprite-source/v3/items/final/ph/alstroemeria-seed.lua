-- alstroemeria-seed (final, Opus). Three round, warty brown alstroemeria seeds on a torn lanceolate leaf scrap
-- (grey-green, parallel veins either side of a pale midrib, jagged torn end with pale broken tissue, cool reflected
-- edge, AO + contact shadow under each seed). The right seed has split and sprouted: a slim pale stem with three
-- narrow lanceolate leaves, each twisted at the base (resupinate, as alstroemeria leaves are) so the pale underside
-- shows first, then the leaf turns over.
-- quirk: a dry capsule valve, curled into a little spring the way they coil when the pod pops, lies on the leaf.
local NAME = "alstroemeria-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min = math.floor, math.abs, math.sin, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#163636", "#1f4f42", "#2b6a4c", "#3f8758", "#62a56a", "#94c48a" }
local UND  = { "#3f6a62", "#5e8a7a", "#82aa92", "#a9c8aa", "#cde2c2" }
local VEIN, COOL, TORN = "#b4d8a0", "#3a6c78", "#d2e6b0"
local SEED = { "#2e1a20", "#4a2a26", "#6c3f2c", "#8f5a36", "#b47e4c", "#dcae76" }
local STEM = { "#4f8a5a", "#80b672", "#b2d896", "#def0c0" }
local TAN  = { "#5e3a2a", "#8a5e3c", "#b88a58", "#e0bc84" }

-- seeds (spheres): cx, cy, r
local seeds = { { 15.5, 47.5, 3.2 }, { 24.5, 46, 3.3 }, { 36, 43, 3.1 } }
for _, s in ipairs(seeds) do
  s.m = c:ellipse(s[1], s[2], s[3], s[3])
  s.n = X.sphere(s[1] - 0.3, s[2] - 0.3, s[3], s.m)
end

-- leaf scrap: narrow lanceolate on a rising diagonal, base lower-left, torn off toward the tip
local lm, ln, LT, LS, len = A.blade(6, 52, 30, 52, 58, 37, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 6.4 * sin(pi * min(1, t * 0.9 + 0.06)) ^ 0.55)
end, { fold = 0.34 })
local tornEdge = A.tear(lm, LT, LS, 0.84, "hi", 0.05, 7)
local bias = {}
for _, s in ipairs(seeds) do A.contact(bias, lm, s.m, 2) end
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.8 }, amb = 0.12, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  local as = abs(s)
  if as < 0.13 and t > 0.03 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok)
  elseif (abs(as - 0.45) < 0.08 or abs(as - 0.76) < 0.07) and t > 0.08 then   -- parallel veins
    c:put(x, y, LEAF[max(1, min(6, lidx[k] + (s < 0 and 2 or -1)))], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.12 and not tornEdge:has(x, y) then c:put(x, y, COOL, ltok) end end)
tornEdge:each(function(x, y) c:put(x, y, (LS[K(x, y)] < 0.2) and TORN or LEAF[5], ltok) end)
c:put(5, 53, LEAF[3], ltok) c:put(4, 54, LEAF[2], ltok)   -- petiole stub

-- quirk: coiled capsule valve (a little dry spring) on the scrap, right of the sprout
local ttok = { r = { name = "valve" } }
c:paint({
  ".aab.",
  "a.dbc",
  "b.c.c",
  ".bc.c",
  "...c.",
}, 42, 40, { a = TAN[4], b = TAN[3], c = TAN[2], d = TAN[1] })
for y = 40, 44 do for x = 42, 46 do if c:get(x, y) then c.own[y * c.w + x] = ttok end end end

-- sprout from the right seed: stem, three twisted lanceolate leaves
local stok = { r = { name = "stem" } }
local sp = { { 36, 41 }, { 38, 33 }, { 35, 25 }, { 37, 15 } }
local sm, sn = A.tube(sp, function(t) return 1.0 - 0.15 * t end)
sm:cut(seeds[3].m)
A.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3, tok = stok })
local function tleaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    if t < 0.3 then return 0.5 + 0.9 * abs(t - 0.27) / 0.27 * min(1, t * 6) end
    return max(0.5, w * sin(pi * min(1, (t - 0.24) / 0.76 * 0.95 + 0.06)) ^ 0.6)
  end, { fold = 0.3 })
  m:cut(sm)
  local twist, rest = HP.mask(), HP.mask()
  m:each(function(x, y) if T[K(x, y)] < 0.27 then twist:set(x, y) else rest:set(x, y) end end)
  A.toneN(c, twist, n, UND, { tok = ltok, cuts = { 0.25, 0.45, 0.65, 0.82 }, amb = 0.2, wrap = 0.3 })
  local idx = A.toneN(c, rest, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  rest:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.15 and T[k] < 0.88 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok)
    elseif abs(abs(S[k]) - 0.58) < 0.1 and T[k] > 0.35 and T[k] < 0.8 and S[k] < 0 then c:put(x, y, LEAF[min(6, idx[k] + 1)], ltok) end
  end)
  -- the turn-over line where the twist ends
  m:each(function(x, y) local t = T[K(x, y)] if t >= 0.26 and t < 0.3 then c:put(x, y, LEAF[2], ltok) end end)
  return m
end
tleaf(37, 32, 29, 31, 20, 24, 2.8)
tleaf(37, 25, 45, 24, 53, 16, 2.7)
tleaf(37, 16, 37, 12, 40, 6, 2.0)

-- seeds last: warty matte coat, AO toward the leaf, one small hi each; the sprouting one split at the top
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  s.m:each(function(x, y) local k = K(x, y)
    local h = X.hash(x, y, 31 + i)
    if h > 0.82 and not s.m:edge():has(x, y) then sb[k] = -1 end
    if y >= s[2] + s[3] - 1 then sb[k] = (sb[k] or 0) - 1 end
  end)
  local idx = A.shade(c, s.m, s.n, SEED, { bias = sb, tok = tok, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, amb = 0.05, wrap = 0.2 })
  local hx, hy = floor(s[1] - s[3] * 0.45 + 0.5), floor(s[2] - s[3] * 0.5 + 0.5)
  c:put(hx, hy, SEED[6], tok) c:put(hx + 1, hy, SEED[6], tok)
  c:put(floor(s[1] + 1.5), floor(s[2] + 1.5), "#7a5a5a", tok)   -- faint cool bounce
end
-- split coat on the sprouting seed, pale tissue inside
c:put(35, 40, SEED[1]) c:put(36, 40, STEM[3]) c:put(37, 40, SEED[2]) c:put(36, 41, STEM[2])
A.save(c, NAME)
