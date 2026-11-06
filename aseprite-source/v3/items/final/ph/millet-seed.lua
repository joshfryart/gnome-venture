-- millet-seed (final, Opus single pass). Four tiny round proso-millet grains (glossy cream-gold, per-pixel lit,
-- a dark germ dot, one glint) huddled on a torn strip of grass leaf (strap shape, ragged torn ends, parallel veins
-- instead of a net, V-fold light, contact shadow and AO under every grain). The right grain has germinated: a
-- pale coleoptile, one narrow arching grass blade and a second shorter blade show the millet leaf; root hairs below.
-- quirk: one runaway grain has rolled off onto the torn tip of the strip and is about to fall.
local NAME = "millet-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_3.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, pi, max, min = math.floor, math.abs, math.sin, math.pi, math.max, math.min
local c = G.new2(NAME)
local LEAF = { "#1b3f2c", "#2a5a34", "#3c763c", "#589446", "#80b256", "#b4d478" }
local GRAIN = { "#6a3e1a", "#a0662a", "#d09a3e", "#eac25c", "#f8e08c", "#fff6c4" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local ROOT = "#f2ead0"

-- grains: cx, cy, r
local grains = { { 16, 40, 2.6 }, { 22, 38, 2.6 }, { 19, 44, 2.5 }, { 31, 37, 2.6 }, { 51, 33, 2.3 } }
for _, g in ipairs(grains) do g.m, g.n = G.oval(g[1], g[2], g[3] + 0.15, g[3] - 0.1, -0.3, 0.9) end

-- grass-leaf strip, torn both ends
local lm, ln, LT, LS, len = G.blade(6, 45, 30, 38, 56, 36, function(t) return 5.2 - 0.9 * t end, { fold = 0.32 })
A.tear(lm, LT, LS, len, true, true, 11)
-- a small bite-shaped tear on the lower edge
lm:each(function(x, y) if (x - 38) ^ 2 + (y - 44.5) ^ 2 < 4.5 then lm.s[K(x, y)] = nil end end)
local bias = {}
for _, g in ipairs(grains) do X.ao(bias, lm, g.m, 1, -1) G.cast(bias, lm, g.m, 1, 1, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { tok = ltok, bias = bias, cuts = { 0.14, 0.3, 0.47, 0.64, 0.82 }, amb = 0.16, wrap = 0.3 })
-- parallel veins: midrib + two lines each side running the full length
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s = LS[k]
  if abs(s) < 0.1 then c:put(x, y, LEAF[6], ltok)
  elseif abs(abs(s) - 0.45) < 0.07 or abs(abs(s) - 0.78) < 0.06 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)

-- sprout from grain 4 (drawn before the grain so the coat sits over the foot)
local stok = { r = { name = "sprout" } }
local cm, cn = A.tube({ { 32, 35 }, { 31, 29 }, { 33, 23 }, { 33, 19 } }, function(t) return 1.1 - 0.25 * t end)
X.tone(c, cm, X.light(cn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function blade(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * (1 - t) ^ 0.45 * min(1, 0.6 + t * 5))
  end, { fold = 0.45 })
  m:cut(cm)
  local b = {}
  X.ao(b, m, cm, 1, -1)
  G.toneN(c, m, n, LEAF, { tok = ltok, bias = b, cuts = { 0.16, 0.32, 0.5, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if not b[k] and abs(S[k]) < 0.17 and T[k] > 0.12 and T[k] < 0.86 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end
  end)
  return m
end
blade(33, 21, 38, 8, 50, 9, 1.9)
blade(32, 26, 26, 16, 20, 14, 1.4)
-- root hairs from grain 4 down onto the leaf
for _, p in ipairs { { 33, 40 }, { 34, 41 }, { 35, 42 }, { 36, 42 }, { 34, 42 }, { 33, 43 } } do c:put(p[1], p[2], ROOT, stok) end

-- grains last, back to front
for i, g in ipairs(grains) do
  local vis = g.m:copy()
  local gb = {}
  for j = i + 1, #grains do vis:cut(grains[j].m) X.ao(gb, g.m, grains[j].m, 1, -1) end
  if i == 4 then X.ao(gb, g.m, cm, 1, -1) end
  local tok = { r = { name = "grain" .. i } }
  G.toneN(c, vis, g.n, GRAIN, { tok = tok, bias = gb, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, amb = 0.12, wrap = 0.35 })
  -- germ: dark dot low right
  local gx, gy = floor(g[1] + 1.2 + 0.5), floor(g[2] + 1.2 + 0.5)
  if vis:has(gx, gy) then c:put(gx, gy, GRAIN[2], tok) end
  local sx, sy = floor(g[1] - 1 + 0.5), floor(g[2] - 1 + 0.5)
  if vis:has(sx, sy) then c:put(sx, sy, i == 2 and A.CREAM or GRAIN[6], tok) end
end
-- runaway grain shadow on the torn tip
c:put(52, 36, LEAF[1], ltok)

G.save2(c, NAME)
