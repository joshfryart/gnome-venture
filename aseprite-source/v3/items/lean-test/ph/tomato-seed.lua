-- tomato-seed (lean L1_0)
-- Five tiny flat straw-gold fuzzy tomato seeds on a torn, deeply lobed tomato leaflet; one has split: red-purple
-- hairy stem, two long thin strap cotyledons and a first serrated true leaf. quirk: a clear gel bead glints beside a seed.
local NAME = "tomato-seed"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local LEAF  = { "#1d3c3a", "#2c5a45", "#40764d", "#5c9258", "#82ae68", "#acc886" }
local SLEAF = { "#1e4a3c", "#2e6a46", "#468a4e", "#68a85a", "#92c46c", "#c0e08a" }
local SEED  = { "#6b5a3a", "#9a8450", "#c4aa68", "#dcc680", "#ecd9a0", "#f8ecc4" }
local STEM  = { "#4a2038", "#7a3452", "#a4506a", "#6e8c52", "#98b468" }
local ROOT  = { "#b8a488", "#e2d2b4", "#f6ecd6" }
local VEIN, COOL = "#c0dc9a", "#3a6a78"

local function seedMask(cx, cy, rl, rw, a)
  local ca, sa = cos(a), sin(a)
  local m = HP.mask()
  for y = floor(cy) - 5, floor(cy) + 5 do for x = floor(cx) - 5, floor(cx) + 5 do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (rl + 0.4)
    local v = (-dx * sa + dy * ca)
    if abs(u) <= 1 then
      local hw = (rw + 0.4) * sqrt(1 - u * u) * (1 - 0.18 * u)
      if abs(v) <= hw then m:set(x, y) end
    end
  end end
  return m
end
local seeds = {
  { 14, 48, 3.4, 2.6, 0.5 },
  { 24, 51, 3.3, 2.5, -0.4 },   -- sprouts
  { 35, 52, 3.4, 2.6, 2.4 },
  { 45, 49, 3.3, 2.5, 1.2 },
  { 31, 46, 3.2, 2.4, -2.4 },
}
-- deeply lobed leaflet, tip at left
local lm, ln, LT, LS, len = G.blade(56, 52, 33, 58, 6, 47, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.95 + 0.05)
  local lobe = 0.62 + 0.38 * abs(sin(t * 20))
  return max(0.45, 6.6 * sin(pi * u ^ 0.9) ^ 0.7 * lobe)
end, { fold = 0.4 })
do local cm = HP.mask() lm:each(function(x, y) if LT[K(x, y)] < 0.07 and X.hash(x, y, 9) > 0.45 then cm:set(x, y) end end) lm:cut(cm) end
local sm = {}
local bias = {}
for i, s in ipairs(seeds) do sm[i] = seedMask(s[1], s[2], s[3], s[4], s[5]) X.ao(bias, lm, sm[i], 1, -1) G.cast(bias, lm, sm[i], 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.2 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.02 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  for _, vt in ipairs{ 4, 9, 14, 19, 24, 29, 34, 39 } do
    local d = t * len - (vt + abs(s) * 3.0)
    if d > -0.5 and d < 0.5 and abs(s) > 0.15 and abs(s) < 0.6 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) return end
  end
  if X.hash(x, y, 3) > 0.93 then c:put(x, y, LEAF[5], ltok) end   -- leaf fuzz
end)
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and LS[k] > 0.6 and LT[k] > 0.1 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end end)

-- radicle
local rm = c:line({ {22, 53}, {21, 55}, {18, 56}, {16, 55} }, 1)
rm:each(function(x, y) c:put(x, y, ROOT[2], { r = { name = "root" } }) end)
c:put(22, 53, ROOT[3]) c:put(21, 55, ROOT[3]) c:put(16, 55, ROOT[1])

-- stem
local stm, stn, ST = G.tube({ {25, 48}, {26, 40}, {22, 32}, {23, 23} }, function(t) return 0.9 - 0.15 * t end)
local stok = { r = { name = "stem" } }
local sv2 = X.light(stn, { amb = 0.15, wrap = 0.3 })
stm:each(function(x, y) local k = K(x, y) local lit = sv2[k] > 0.55
  local col = ST[k] < 0.6 and (lit and STEM[3] or STEM[2]) or (lit and STEM[5] or STEM[4])
  if X.hash(x, y, 5) > 0.88 then col = "#e8d8d0" end   -- fine hairs
  c:put(x, y, col, stok) end)

local function blade(ax, ay, cx, cy, bx, by, w, pw, veins, name, lobed)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.9 + 0.1)
    local lb = lobed and (0.7 + 0.3 * abs(sin(t * 16))) or 1
    return max(0.45, w * sin(pi * u) ^ pw * lb)
  end, { fold = 0.5 })
  m:cut(stm)
  local tok = { r = { name = name } }
  G.toneN(c, m, n, SLEAF, { tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.2 and t > 0.05 and t < 0.9 then c:put(x, y, s <= 0 and SLEAF[6] or SLEAF[2], tok) return end
    for _, vt in ipairs(veins) do
      local d = t * L - (vt + abs(s) * 3.0)
      if d > -0.5 and d < 0.5 and abs(s) > 0.3 and abs(s) < 0.7 then c:put(x, y, s < 0 and SLEAF[6] or SLEAF[2], tok) return end
    end
  end)
  m:edge():each(function(x, y) local k = K(x, y) if S[k] > 0.6 and T[k] > 0.15 and T[k] < 0.85 then c:put(x, y, COOL, tok) end end)
  return m
end
-- strap cotyledons arch out and down; true leaf serrated, rising
blade(23, 24, 24, 14, 24, 8, 2.8, 0.6, { 3, 6 }, "tl", true)
blade(22, 24, 14, 12, 7, 17, 1.8, 0.35, {}, "co1")
blade(24, 24, 33, 12, 47, 14, 1.8, 0.35, {}, "co2")
c:put(23, 24, STEM[1], stok) c:put(24, 24, STEM[1], stok)

-- seeds: flat straw-gold fuzzy teardrops with a notch hilum
for i, s in ipairs(seeds) do
  local m = sm[i]
  local n = X.pillow(m, 2.2)
  local tok = { r = { name = "seed" .. i } }
  X.tone(c, m, X.light(n, { amb = 0.08, wrap = 0.25 }), SEED, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 }, tok = tok })
  local inner = m:shrink(1)
  m:each(function(x, y) if not inner:has(x, y) and X.hash(x, y, 40 + i) > 0.55 then c:put(x, y, "#fff6d8", tok) end end)
  local hx, hy = floor(s[1] + cos(s[5]) * (s[3] - 0.5) + .5), floor(s[2] + sin(s[5]) * (s[3] - 0.5) + .5)
  if m:has(hx, hy) then c:put(hx, hy, SEED[1], tok) end
  local bx, by = G.specAt(m, n, 30)
  if bx then c:put(bx, by, "#fffbe8", tok) end
end
c:put(23, 50, SEED[1], { r = { name = "seed2" } })
-- quirk: clear gel bead with glint
local GEL = { "#5a9a8a", "#8cc8b0", "#c0eadc", "#f2fff6" }
local gt = { r = { name = "gel" } }
for _, p in ipairs{ {41,54,1},{42,54,2},{43,54,1},{40,55,1},{41,55,2},{42,55,3},{43,55,2},{44,55,1},{41,56,1},{42,56,1},{43,56,1} } do c:put(p[1], p[2], GEL[p[3]], gt) end
c:put(41, 55, GEL[4], gt)
G.save(c, NAME)
