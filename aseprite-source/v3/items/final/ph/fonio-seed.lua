-- fonio-seed (final, Opus aB32_2). Five tiny fonio grains (plump pale-gold ovoids, husk seam, pale tip) on a torn
-- strip of fonio grass leaf (parallel veins, ragged torn end, V-fold light, cool edge, AO + contact shadow under each
-- grain). The right grain has sprouted: a hair-thin stem and three slender grass blades, the fonio plant's leaf.
-- quirk: the tallest blade already carries a miniature two-finger fonio seed head.
local NAME = "fonio-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_2.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF  = { "#18403a", "#235a43", "#2f7848", "#479a4e", "#6eb957", "#a3d570" }
local VEIN, COOL = "#c4e68e", "#3c6e78"
local GRAIN = { "#5a3420", "#8a5528", "#b98232", "#dcae48", "#f2d276", "#fff0b4" }
local STEM  = { "#3f7a4c", "#6fa760", "#a6d083", "#d9efb2" }
local HEAD  = { "#6a4a2a", "#a87a3a", "#d8b05a", "#f6e08e" }

-- grains: cx, cy, rx, ry, angle
local grains = { { 15, 46, 2.6, 2.0, 0.3 }, { 22, 45, 2.7, 2.0, -0.2 }, { 19, 41, 2.6, 2.0, 0.5 },
                 { 29, 43, 2.6, 1.9, -0.4 }, { 41, 40, 2.7, 2.0, -0.1 } }
for _, s in ipairs(grains) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end

-- leaf strip: long, narrow, diagonal; ragged torn end on the left, natural taper to the right
local lm, ln, LT, LS, len = G.blade(9, 50, 31, 46, 55, 37, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 5.6 * min(1, (1 - t) / 0.4) ^ 0.7)
end, { fold = 0.35 })
-- torn end: jagged bite out of the base
local torn = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local lim = 0.035 + 0.05 * abs(sin(s * 7.3 + 1.1)) + 0.03 * X.hash(floor(s * 4), 0, 3)
  if t < lim then torn[#torn + 1] = k end
end)
for _, k in ipairs(torn) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(grains) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- parallel veins (grass leaf): midrib + two side veins running the length
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.06 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok)
  elseif abs(abs(s) - 0.55) < 0.09 and t > 0.08 and t < 0.8 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.15 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end end)
-- torn fibres: two pale strands sticking out of the torn end
c:put(8, 49, LEAF[5], ltok) c:put(7, 49, LEAF[4], ltok) c:put(9, 52, LEAF[4], ltok)

-- sprout: thin stem out of the right grain + three slender grass blades
local stok = { r = { name = "stem" } }
local function blade(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.35, w * sin(pi * min(1, t * 0.75 + 0.25)) ^ 0.6)
  end, { fold = 0.3 })
  G.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.15 and T[k] > 0.1 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local sm, sn = G.tube({ { 42, 38 }, { 42, 34 }, { 41, 31 }, { 42, 28 } }, function(t) return 0.9 end)
A.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok, amb = 0.15, wrap = 0.3 })
blade(42, 29, 34, 22, 27, 21, 1.5)
blade(42, 29, 49, 24, 54, 26, 1.4)
local tall = blade(42, 30, 43, 18, 47, 8, 1.6)
-- quirk: tiny two-finger seed head at the tip of the tallest blade (bead rows)
for i, p in ipairs{ { 47, 8 }, { 46, 6 }, { 45, 4 }, { 44, 3 } } do c:put(p[1], p[2], i == 1 and STEM[2] or HEAD[2], stok) end
for i, p in ipairs{ { 48, 7 }, { 49, 5 }, { 50, 4 }, { 51, 3 } } do c:put(p[1], p[2], HEAD[2], stok) end
for _, p in ipairs{ { 44, 4 }, { 46, 5 }, { 49, 4 }, { 51, 4 } } do c:put(p[1], p[2], HEAD[3], stok) end
c:put(45, 3, HEAD[4], stok) c:put(50, 3, HEAD[4], stok)
-- root hair out of the sprouting grain
for _, p in ipairs{ { 44, 42 }, { 45, 43 }, { 46, 43 }, { 47, 44 } } do c:put(p[1], p[2], STEM[3], stok) end

-- grains last, back to front: husk seam, pale tip, AO between neighbours, a waxy glint
table.sort(grains, function(a, b) return a[2] < b[2] end)
for i, s in ipairs(grains) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #grains do vis:cut(grains[j].m) X.ao(sb, s.m, grains[j].m, 1, -1) end
  local tok = { r = { name = "grain" .. i } }
  local idx = A.shade(c, vis, s.n, GRAIN, { bias = sb, tok = tok, amb = 0.1, wrap = 0.25, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    -- husk seam: a darker line along the long axis, just below centre
    if abs(v - 0.25) < 0.2 and abs(u) < 0.6 then c:put(x, y, GRAIN[max(1, (idx[k] or 3) - 2)], tok) end
  end)
  -- pale tip (embryo end) and one 1px glint
  local tx, ty = floor(s[1] - s[3] * ca * 0.9 + .5), floor(s[2] - s[3] * sa * 0.9 + .5)
  if vis:has(tx, ty) then c:put(tx, ty, GRAIN[5], tok) end
  local gx, gy = G.specAt(vis, s.n, 30)
  if gx then c:put(gx, gy, GRAIN[6], tok) end
end

A.save(c, NAME)
