-- quinoa (final, Sonnet high). A slim upright quinoa plant, cut at the root: a candy-striped green and magenta stem, two
-- rhombic goosefoot leaves with toothed margins and mealy bloom, and a nodding club-shaped panicle of glossy bead-like
-- seed clusters that shade from crimson at the base through coral to gold at the bowed tip. Each bead is a lit sphere
-- with its own specular and a dark seam where it tucks behind its neighbour; the rachis shows between the beads.
-- quirk: one bead has come loose and dangles from the panicle on a hair-thin thread.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_0.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("quinoa")
local LEAF = { "#1f3b3a", "#2e5d48", "#437f53", "#62a05f", "#8fc072", "#c3de9c" }
local MEAL = "#e2f2d6"
local STEM = { "#3f7048", "#68a05a", "#98c678", "#c6e29e" }
local STRIPE, STRIPE2 = "#b23a62", "#e46c86"
local MAG   = { "#3d1230", "#6a1840", "#9b2650", "#c93a5e", "#ee6a78", "#ffa59a" }
local CORAL = { "#4a1530", "#82212f", "#b83a2c", "#e0603a", "#f98c4c", "#ffc58a" }
local GOLD  = { "#5a2a22", "#9a4a1c", "#d27a1c", "#f0a826", "#fccc4e", "#fff0a0" }
local ltok = { r = { name = "leaf" } }

-- toothed rhombic goosefoot blade on a petiole
local function gleaf(ax, ay, cx, cy, bx, by, wmax, veins)
  local bl = sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
  local m, n, T, S, len = A.tornBlade(c, ax, ay, cx, cy, bx, by, function(t)
    if t < 0.26 then return 0.55 end
    local u = (t - 0.26) / 0.74
    local w = wmax * (1 - abs((u - 0.42) / (u < 0.42 and 0.42 or 0.58))) ^ 0.85
    local saw = ((t * bl * 1.06 / 3.1) % 1) < 0.5 and 0.9 or 0
    if u > 0.12 and u < 0.9 then w = w + saw * min(1, w) end
    return max(0.5, w)
  end, { ramp = LEAF, veins = veins, sweep = 1.8, rib = 0.17, ribEnd = 0.96, cool = "#3b6d78", fold = 0.45 })
  -- mealy bloom
  m:each(function(x, y) local k = K(x, y)
    if T[k] > 0.3 and abs(S[k]) < 0.8 and X.hash(x, y, 51) > 0.86 then c:put(x, y, MEAL, ltok) end end)
  return m, T, S
end
gleaf(32, 47, 22, 42, 10, 36, 5.4, { 0.52, 0.64, 0.76 })
gleaf(32, 53, 43, 48, 54, 45, 4.8, { 0.52, 0.64, 0.76 })

-- stem: green with a magenta stripe on the shade side
local sm, sT, sS = A.stem(c, { { 32, 57 }, { 31, 50 }, { 33, 41 }, { 32, 31 } }, 1.35, 1.15, STEM, { 0.3, 0.55, 0.8 })
sm:each(function(x, y) local k = K(x, y)
  if sS[k] > 0.2 then c:put(x, y, (sT[k] * 22) % 4 < 2 and STRIPE or STRIPE2, { r = { name = "stripe" } }) end end)
-- cut base: pale pith disc, two hair roots
c:put(31, 58, "#e8d8a8") c:put(32, 58, "#cdbb88") c:put(33, 58, "#a8946c")
c:put(31, 59, "#8a6a48") c:put(30, 60, "#6e4e38") c:put(34, 59, "#8a6a48") c:put(35, 60, "#6e4e38") c:put(32, 59, "#6e4e38")

-- panicle: club along a bowed axis, beads on a staggered lattice
local ax = { { 32, 33 }, { 32, 24 }, { 33, 14 }, { 41, 12 } }
local beads = {}
local N = 8
for i = 0, N - 1 do
  local t = 0.03 + 0.94 * i / (N - 1)
  local x, y = G.bez(ax, t)
  local x2, y2 = G.bez(ax, min(1, t + 0.01))
  local x1, y1 = G.bez(ax, max(0, t - 0.01))
  local tx, ty = x2 - x1, y2 - y1
  local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  local px, py = -ty, tx
  local hw = 7.4 * sin(pi * (0.17 + 0.7 * t)) ^ 0.8
  local cnt = max(1, floor(2 * hw / 4.0 + 0.5))
  if i % 2 == 1 and cnt > 1 then cnt = cnt - 1 end
  for j = 0, cnt - 1 do
    local off = (j - (cnt - 1) / 2) * 4.1
    local jx, jy = (X.hash(i, j, 61) - 0.5) * 1.0, (X.hash(i, j, 62) - 0.5) * 1.0
    local bx, by = x + px * off + jx, y + py * off + jy
    local r = 2.25 - 0.55 * max(0, t - 0.6) / 0.4 - (t < 0.15 and 0.2 or 0)
    local pick = t + (X.hash(i, j, 63) - 0.5) * 0.28
    local ramp = pick < 0.34 and MAG or (pick < 0.66 and CORAL or GOLD)
    beads[#beads + 1] = { x = bx, y = by, r = r, ramp = ramp, t = t }
  end
end
table.sort(beads, function(a, b) return (a.x + a.y * 1.15) < (b.x + b.y * 1.15) end)
-- rachis showing through
local rm, rn = G.tube(ax, function(t) return 1.2 end)
G.toneN(c, rm, rn, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
for i, b in ipairs(beads) do
  b.m = c:ellipse(floor(b.x + 0.5), floor(b.y + 0.5), b.r, b.r)
  b.n = X.sphere(floor(b.x + 0.5) - 0.5, floor(b.y + 0.5) - 0.5, b.r, b.m)
end
for i, b in ipairs(beads) do
  local later = HP.mask()
  for j = i + 1, #beads do later:add(beads[j].m) end
  local vis = b.m:copy():cut(later)
  local bias = {}
  vis:each(function(x, y)
    if later:has(x + 1, y) or later:has(x - 1, y) or later:has(x, y + 1) or later:has(x, y - 1) then bias[K(x, y)] = -2 end
  end)
  G.toneN(c, vis, b.n, b.ramp, { cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias = bias, amb = 0.05, wrap = 0.18 })
  local sx, sy = G.specAt(vis, b.n, 26)
  if sx and not bias[K(sx, sy)] then c:px(sx, sy, A.CREAM) end
end
-- quirk: a loose bead on a hair thread
A.pline(c, { { 38, 33 }, { 38, 35 }, { 38, 36 } }, "#b8956a")
A.bead(c, 38, 38.4, 1.9, GOLD, { spec = A.CREAM })
A.save(c, "quinoa")
