-- black-pepper (final, Opus single pass). A slim sprig of Piper nigrum: thin woody twig, one heart-shaped pepper leaf
-- (pointed drip tip, arcuate veins from the base), and a hanging spike of dried, wrinkled black peppercorns on a pale
-- rachis; two loose corns rest below. Per-pixel sphere light, wrinkle pits, a cool bounce on the shade side, AO where
-- corns crowd. quirk: the lower-right loose corn has cracked open, showing the pale white-pepper core, a chip flying off.
local NAME = "black-pepper"
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_3.lua")
local HP, X, K = R.HP, R.X, R.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = R.new(NAME)
local CORN = { "#120c14", "#1e1420", "#2f202b", "#46323a", "#655058", "#927a7c" }
local BOUNCE = "#4b4a6c"
local LEAF = { "#173f36", "#22593f", "#2f7745", "#46964b", "#6cb653", "#a2d36c" }
local VEIN = "#c6e690"
local TWIG = { "#3e2a26", "#5e3f2e", "#86603e", "#a98455", "#c9a86e" }
local RACH = { "#5a6a3a", "#7f8f4c", "#a7b066", "#cdd08c" }
local CORE = { "#b89a6e", "#dcc69a", "#f3e6c2" }

-- twig: from upper-left, arching to the node where leaf and spike meet
local tw = { { 9, 9 }, { 16, 5 }, { 25, 6 }, { 30, 14 } }
local tm, tn = R.tube(tw, function(t) return 1.25 - t * 0.2 end)
local ttok = { r = { name = "twig" } }
local tidx = R.shade(c, tm, tn, TWIG, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = ttok })
-- bark ticks (grain) and a pale cut end
for _, p in ipairs{ { 14, 6 }, { 20, 5 }, { 26, 8 } } do if tm:has(p[1], p[2] + 1) then c:put(p[1], p[2] + 1, TWIG[2], ttok) end end
c:put(9, 9, TWIG[5], ttok) c:put(9, 10, TWIG[4], ttok)

-- leaf: ovate-cordate, base at the node, drip tip to the right
local L0x, L0y = 31, 14
local lm, ln, LT, LS, llen = R.blade(L0x, L0y, 42, 11, 54, 19, function(t)
  if t > 0.99 then return -1 end
  local w = 6.8 * sin(pi * min(1, (t + 0.06) / 1.0)) ^ 0.65 * (1 - 0.35 * t)
  if t > 0.8 then w = w * (1 - (t - 0.8) / 0.2 * 0.75) end
  return max(0.4, w)
end, { fold = 0.42 })
-- cordate notch at the base
local ltok = { r = { name = "leaf" } }
local lbias = {}
R.shade(c, lm, ln, LEAF, { tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- midrib + arcuate veins (curving from the base toward the tip)
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if abs(s) < 0.13 and t > 0.04 and t < 0.9 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  for _, a in ipairs{ 0.55 } do
    local target = a * sin(pi * min(1, t / 0.92)) ^ 0.8
    if t > 0.08 and t < 0.82 and abs(abs(s) - target) < 0.07 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y) if LS[k] > 0.7 and LT[k] > 0.15 and LT[k] < 0.85 then c:put(x, y, "#3c6e74", ltok) end end)

-- rachis: pale green-gold thread hanging from the node
local rp = { { 30, 15 }, { 31, 22 }, { 30, 32 }, { 28, 44 } }
local rm, rn = R.tube(rp, function(t) return 0.7 end)
local rtok = { r = { name = "rachis" } }
R.shade(c, rm, rn, RACH, { cuts = { 0.3, 0.55, 0.8 }, tok = rtok })

-- corns along the spike (staggered), smaller toward the tip, plus two loose ones
local corns = {}
for i = 0, 6 do
  local t = 0.12 + i / 6 * 0.84
  local x, y = R.bez(rp, t)
  local r = 2.55 - i * 0.12
  local side = (i % 2 == 0) and -1 or 1
  corns[#corns + 1] = { x + side * 2.3, y, r }
  if i < 6 then
    local x2, y2 = R.bez(rp, t + 0.07)
    corns[#corns + 1] = { x2 - side * 2.3, y2, r - 0.1 }
  end
end
table.sort(corns, function(a, b) return a[2] < b[2] end)
corns[#corns + 1] = { 18.5, 50, 2.9, loose = true }
corns[#corns + 1] = { 39.5, 51, 3.0, loose = true, cracked = true }
for _, q in ipairs(corns) do q.m = c:ellipse(q[1], q[2], q[3], q[3]) end

-- contact shadow under the loose corns on nothing: no ground shadow (it's not standing); AO between crowded corns
for i, q in ipairs(corns) do
  local vis = q.m:copy()
  local bias = {}
  for j = i + 1, #corns do vis:cut(corns[j].m) X.ao(bias, q.m, corns[j].m, 1, -1) end
  local n = X.sphere(q[1], q[2], q[3], q.m)
  local v = X.light(n, { amb = 0.05, wrap = 0.2 })
  local rim = X.rim(n)
  local tok = { r = { name = "corn" .. i } }
  vis:each(function(x, y) local k = K(x, y)
    local val = v[k]
    local ii = 1
    for jj, ct in ipairs{ 0.18, 0.36, 0.54, 0.72, 0.88 } do if val >= ct then ii = jj + 1 end end
    -- wrinkle pits: reticulate dark pocks on the lit half
    if ii >= 3 and ii <= 5 and X.hash(x, y, i * 7) > 0.66 then ii = ii - 2 end
    if bias[k] then ii = ii + bias[k] end
    ii = max(1, min(6, ii))
    local col = CORN[ii]
    if ii <= 2 and rim[k] > 0.55 and not bias[k] then col = BOUNCE end
    c:put(x, y, col, tok)
  end)
  -- one glint per corn (glossy-ish oil), cream on the biggest
  local gx, gy = floor(q[1] - q[3] * 0.45 + .5), floor(q[2] - q[3] * 0.5 + .5)
  if vis:has(gx, gy) then c:put(gx, gy, i == #corns - 1 and "#fff4d6" or CORN[6], tok) end
end

-- quirk: cracked corn. wedge out of the upper-right quarter, pale core showing, chip flying up-right
local q = corns[#corns]
local tok = { r = { name = "core" } }
local wedge = c:poly{ { q[1] + 0.2, q[2] - 0.4 }, { q[1] + 4, q[2] - 4.2 }, { q[1] + 4.5, q[2] + 0.6 } }
wedge:clip(q.m)
wedge:each(function(x, y) c.pix[y * c.w + x] = nil end)
local core = c:ellipse(q[1] + 0.5, q[2] - 0.5, 1.6, 1.6):clip(wedge:grow(1)):cut(q.m:edge())
core:each(function(x, y)
  local d = (x - q[1]) + (q[2] - y)
  c:put(x, y, d > 2.2 and CORE[3] or (d > 1 and CORE[2] or CORE[1]), tok)
end)
-- crack line into the hull
c:put(floor(q[1] - 1), floor(q[2] + 1), CORN[1], tok) c:put(floor(q[1] - 2), floor(q[2] + 2), CORN[1], tok)
-- flying chip
c:put(46, 44, CORN[4], tok) c:put(47, 44, CORN[3], tok) c:put(46, 45, CORN[2], tok)

R.finish(c)
