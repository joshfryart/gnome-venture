-- bukhara-iris-seed (final, Opus aB13_3 single pass). Three chestnut Juno-iris seeds, each with a cream aril, on a torn
-- strip of glossy channelled iris leaf (parallel veins, pale horny margin, ragged torn ends, AO + contact shadow under
-- seeds). The right seed has sprouted a fan of three sword leaves (channelled, glossy streak, parallel veins).
-- quirk: a tiny furled yellow-and-cream iris bud is already peeking from the leaf axil.
local NAME = "bukhara-iris-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB13_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min = math.floor, math.abs, math.sin, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#173d35", "#1f5a3e", "#2c7a45", "#46a04e", "#74c25a", "#b4e07e" }
local MARGIN = "#e4f2c0"
local SEED = { "#331a1e", "#58291f", "#7e3f24", "#a65e30", "#c98448", "#e9b678" }
local ARIL = { "#c8b48e", "#e9dbb6", "#fff4d6" }
local STEM = { "#5f9a5a", "#a6d48a", "#d8efb4" }
local YEL = { "#8f4a1f", "#d98322", "#f5b82e", "#ffd856", "#ffeb9a", "#fff4d6" }

-- leaf scrap: a straight strap of iris leaf, both ends torn
local lm, ln, LT, LS = A.blade(6, 51, 31, 46, 57, 50, function(t) return 5.4 end, { fold = 0.45 })
A.tear(lm, 10, 51, -1, 0.12, 2.6, 2.3, 4)
A.tear(lm, 53, 50, 1, 0.05, 2.8, 2.1, 9)
local seeds = { { 17, 47, 3.3, 2.6, 0.25 }, { 27, 45, 3.4, 2.6, -0.35 }, { 39, 44, 3.5, 2.7, 0.1 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.15, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  local as = abs(s)
  if abs(as - 0.45) < 0.08 or abs(as - 0.78) < 0.07 then c:put(x, y, s < 0 and LEAF[4] or LEAF[2], ltok) end
  if s > -0.32 and s < -0.18 and t > 0.25 and t < 0.6 and (x + y) % 5 ~= 0 then c:put(x, y, LEAF[6], ltok) end -- gloss streak
  if abs(s) < 0.06 then c:put(x, y, LEAF[2], ltok) end -- channel keel
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if LS[k] < -0.8 and not bias[k] then c:put(x, y, MARGIN, ltok) end
  if LS[k] > 0.85 and not bias[k] then c:put(x, y, "#3a6c72", ltok) end
end)

-- sprout leaves (fan of swords) behind the third seed
local stok = { r = { name = "sprout" } }
local function sword(ax, ay, cx, cy, bx, by, W)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    if t < 0.12 then return W * 0.6 + W * 0.4 * t / 0.12 end
    return max(0.35, W * (1 - ((t - 0.12) / 0.88) ^ 2.3))
  end, { fold = 0.5 })
  return m, n, T, S
end
local sw = {
  { 37, 41, 29, 31, 21, 21, 2.0 },
  { 41, 41, 48, 34, 53, 27, 1.8 },
  { 39, 41, 39, 25, 42, 9, 2.6 },
}
local prev = HP.mask()
local masks = {}
for i, q in ipairs(sw) do
  local m, n, T, S = sword(q[1], q[2], q[3], q[4], q[5], q[6], q[7])
  local b = {}
  X.ao(b, m, prev, 1, -1)
  for _, mm in ipairs(masks) do X.ao(b, mm, m, 1, -1) end
  A.shade(c, m, n, LEAF, { tok = stok, bias = b, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if b[k] then return end
    local as = abs(S[k])
    if as < 0.1 and T[k] > 0.08 and T[k] < 0.9 then c:put(x, y, LEAF[2], stok)
    elseif S[k] < -0.35 and S[k] > -0.75 and T[k] > 0.2 and T[k] < 0.7 then c:put(x, y, LEAF[6], stok) end
  end)
  masks[#masks + 1] = m
  prev:add(m)
end
-- contact shadow of sprout base on the leaf scrap
prev:shift(1, 1):each(function(x, y) if lm:has(x, y) and not prev:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
-- stem foot (pale) between seed and fan
for _, p in ipairs{ { 39, 40, 2 }, { 40, 40, 1 }, { 39, 39, 3 }, { 40, 39, 2 } } do c:put(p[1], p[2], STEM[p[3]], stok) end

-- quirk: furled iris bud from the right axil
local bm, bn = A.oval(45.5, 30.5, 1.7, 3.2, 0.62, 0.8)
bm:cut(masks[3])
local btok = { r = { name = "bud" } }
A.shade(c, bm, bn, YEL, { tok = btok, amb = 0.12, wrap = 0.35 })
c:put(46, 28, YEL[6], btok) c:put(47, 27, YEL[5], btok)
c:put(44, 33, LEAF[3], btok) c:put(43, 34, LEAF[2], btok) -- green sheath at the bud foot

-- seeds: chestnut, wrinkled coat, cream aril at one end
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) end
  local idx = A.shade(c, vis, s.n, SEED, { tok = tok, bias = sb, amb = 0.06, wrap = 0.2, cuts = { 0.12, 0.3, 0.48, 0.66, 0.84 } })
  vis:each(function(x, y) local k = K(x, y)
    if (idx[k] or 1) >= 3 and (idx[k] or 1) <= 5 and X.hash(x, y, i) > 0.78 then c:put(x, y, SEED[(idx[k]) - 1], tok) end end)
  local bx, by = A.specAt(vis, s.n, 30)
  c:put(bx, by, SEED[6], tok) c:put(bx + 1, by, SEED[6], tok)
  -- aril on the right/lower end
  local ca, sa = math.cos(s[5]), math.sin(s[5])
  local ax, ay = floor(s[1] + ca * (s[3] - 0.2) + 0.5), floor(s[2] + sa * (s[3] - 0.2) + 0.5)
  if i < 3 then
    c:put(ax, ay, ARIL[2], tok) c:put(ax + 1, ay, ARIL[1], tok) c:put(ax, ay - 1, ARIL[3], tok) c:put(ax + 1, ay - 1, ARIL[2], tok)
  end
end
-- sprouting seed: split coat along the top where the stem leaves it
c:put(39, 41, SEED[1], { r = { name = "seed3" } }) c:put(40, 41, STEM[2], stok) c:put(38, 41, SEED[2], { r = { name = "seed3" } })

A.fin(c, NAME)
