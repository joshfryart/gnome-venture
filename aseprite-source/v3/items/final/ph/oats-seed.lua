-- oats-seed (final, Opus C3 single pass). Three slender hulled oat grains (straw lemma with fine lengthwise veins,
-- pointed ends, a dark groove, AO where they touch) on a torn strap of oat leaf (parallel veins, no midrib branching,
-- V-fold light, cool reflected edge, jagged torn end, contact shadow under each grain). The right grain has sprouted:
-- pale coleoptile, then two narrow grassy oat blades, the tall one twisting so its paler underside shows; white root hairs.
-- quirk: the left grain still carries its long awn, bent at the knee and twisted like a corkscrew.
local NAME = "oats-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#183a36", "#24553f", "#337248", "#4b9150", "#72b35c", "#a5d27c" }
local UNDER = { "#2e5a48", "#467a56", "#6a9c68", "#94bf82", "#bcdca2", "#dcf0c4" }
local VEIN, COOL = "#b9df90", "#3c6c70"
local GR = { "#5e3c22", "#8c6332", "#b78e48", "#d6b465", "#ecd38c", "#fbf0be" }
local AWN = { "#4a2c1e", "#7a5232", "#a87c48" }
local ROOT = { "#c8bca0", "#ece4cc" }

-- leaf strap: torn end lower-left, pointed tip upper-right
local lm, ln, LT, LS, len = A.blade(6, 53, 30, 50, 58, 37, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 7.2 * (1 - t ^ 3.2) ^ 0.8)
end, { fold = 0.3 })
A.tear(lm, 9, 52, -0.9, 0.15, 1.4, 4)
-- a bite-shaped nick on the upper edge
lm:each(function(x, y) if (x - 22) ^ 2 + (y - 41.5) ^ 2 < 3.2 then lm.s[K(x, y)] = nil end end)

-- grains: cx, cy, rx, ry, angle
local grains = { { 18, 46, 6.0, 2.1, -0.32 }, { 29, 46.5, 6.2, 2.2, -0.12 }, { 39, 42, 5.8, 2.1, -0.52 } }
for _, g in ipairs(grains) do g.m, g.n = A.oval(g[1], g[2], g[3], g[4], g[5], 0.75)
  -- sharpen the ends into points
  local ca, sa = cos(g[5]), sin(g[5])
  local cut = {}
  g.m:each(function(x, y) local dx, dy = x - g[1], y - g[2]
    local u, v = (dx * ca + dy * sa) / g[3], (-dx * sa + dy * ca) / g[4]
    if abs(u) > 0.7 and abs(v) > (1 - abs(u)) * 2.6 then cut[#cut + 1] = K(x, y) end end)
  for _, k in ipairs(cut) do g.m.s[k] = nil end
end

-- sprout masks first (needed for AO / cast on the leaf)
local stok, ltok = A.tok("sprout"), A.tok("leaf")
local col = { { 41, 41 }, { 41, 38 }, { 40, 35 }, { 40, 32 } }
local cm, cn = A.tube(col, function(t) return 1.1 end)
-- tall blade: rises, leans left, twists (underside shows past the twist), tip curls right
local b1 = { { 40, 33 }, { 37, 23 }, { 31, 16 }, { 36, 9 } }
local b1m, b1n, B1T, B1S = A.tube(b1, function(t) return max(0.3, 1.75 * (1 - t) ^ 0.55 + 0.1) end)
-- short blade arching right
local b2 = { { 41, 33 }, { 45, 26 }, { 50, 22 }, { 55, 22 } }
local b2m, b2n, B2T, B2S = A.tube(b2, function(t) return max(0.3, 1.5 * (1 - t) ^ 0.6) end)
b2m:cut(b1m)

local bias = {}
for _, g in ipairs(grains) do X.ao(bias, lm, g.m, 1, -1) A.cast(bias, lm, g.m, 1, 2, -1) end
X.ao(bias, lm, cm, 1, -1)
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
-- parallel veins (grass: many fine lines, a slightly stronger centre line)
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 and t > 0.06 and t < 0.92 then c:put(x, y, VEIN, ltok)
  elseif t > 0.05 and t < 0.9 and (abs(abs(s) - 0.42) < 0.07 or abs(abs(s) - 0.72) < 0.06) then
    A.step(c, lidx, LEAF, x, y, s < 0 and 1 or -1, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.12 and LT[k] < 0.86 then c:put(x, y, COOL, ltok) end end)

-- coleoptile (pale sheath) and blades
A.shade(c, cm, cn, { "#5f7d58", "#86a676", "#a8c890", "#c8e2ac", "#e2f2cc", "#f2fae0" }, { tok = stok })
local function blade(m, n, T, S, twistAt)
  local idx = A.shade(c, m, n, LEAF, { tok = stok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if twistAt and T[k] > twistAt and T[k] < twistAt + 0.3 then c:put(x, y, UNDER[max(1, min(6, idx[k]))], stok)
    elseif abs(S[k]) < 0.2 and T[k] < 0.85 then A.step(c, idx, LEAF, x, y, 1, stok) end
  end)
  return idx
end
blade(b2m, b2n, B2T, B2S)
blade(b1m, b1n, B1T, B1S, 0.42)
-- ligule notch where the short blade leaves the sheath
c:put(41, 32, "#e2f2cc", stok)

-- root hairs from the sprouting grain, over the leaf edge
for _, q in ipairs{ { 44, 44, 1 }, { 45, 45, 2 }, { 46, 46, 1 }, { 46, 47, 2 }, { 45, 47, 1 }, { 47, 48, 2 } } do
  c:put(q[1], q[2], ROOT[q[3]], A.tok("root")) end

-- quirk: knee-bent twisted awn from the left grain's back
local aw = { { 15, 44 }, { 12, 40 }, { 10, 37 }, { 9, 35 }, { 9, 33 }, { 10, 31 }, { 12, 29 }, { 14, 27 }, { 16, 25 } }
local atok = A.tok("awn")
for i, p in ipairs(aw) do c:put(p[1], p[2], (i <= 5) and AWN[(i % 2) + 1] or AWN[(i % 2 == 0) and 3 or 2], atok) end
for _, p in ipairs{ { 11, 39 }, { 10, 36 }, { 13, 41 } } do c:put(p[1], p[2], AWN[(p[2] % 2) + 1], atok) end

-- grains last, back to front
for i, g in ipairs(grains) do
  local vis = g.m:copy()
  local gb = {}
  for j = i + 1, #grains do vis:cut(grains[j].m) X.ao(gb, g.m, grains[j].m, 1, -1) end
  if i == 3 then X.ao(gb, g.m, cm, 1, -1) end
  local tok = A.tok("grain" .. i)
  local idx = A.toneN(c, vis, g.n, GR, { bias = gb, tok = tok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, amb = 0.12, wrap = 0.3 })
  local ca, sa = cos(g[5]), sin(g[5])
  vis:each(function(x, y) local dx, dy = x - g[1], y - g[2]
    local u, v = (dx * ca + dy * sa) / g[3], (-dx * sa + dy * ca) / g[4]
    if abs(v - 0.15) < 0.22 and abs(u) < 0.62 then A.step(c, idx, GR, x, y, -2, tok)             -- crease groove
    elseif abs(v + 0.55) < 0.16 and abs(u) < 0.75 and (x + y) % 2 == 0 then A.step(c, idx, GR, x, y, -1, tok) end -- lemma vein
    if abs(u) > 0.82 then A.step(c, idx, GR, x, y, -1, tok) end
  end)
  -- glint on the lit shoulder
  local gx = floor(g[1] - 2 * ca + 1.4 * sa + 0.5) local gy = floor(g[2] - 2 * sa - 1.4 * ca + 0.5)
  if vis:has(gx, gy) then c:put(gx, gy, GR[6], tok) end
end
c:put(29, 45, "#fffbe0", A.tok("grain2"))

A.save(c, NAME)
