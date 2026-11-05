-- ginseng-seed (seed P1b_SG)
-- Ginseng root-crown: short stem forking into three prongs, each a palmate compound leaf of 5 rounded oval leaflets,
-- a central stalk topped by a red berry cluster, and 3 flat cream seeds (one split, tiny sprout) on a torn leaf scrap.
local NAME = "ginseng-seed"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local SCRAP = { "#0e2a2a", "#163f2f", "#205a35", "#2e7a3c", "#47974a", "#74b45a" }
local LEAF  = { "#1a4a30", "#26683a", "#37883f", "#53a84a", "#7ac85a", "#b4e67c" }
local SEED  = { "#7e6848", "#a98f66", "#cdb688", "#e6d4a6", "#f6e8c0", "#fff6da" }
local BERRY = { "#4a0f1e", "#7a1426", "#a81e2c", "#cf3a38", "#ee6648", "#ffa878" }
local STEM  = { "#5a2a30", "#86403a", "#a85c48", "#7a8a48", "#9cae5a" }
local ROOT  = { "#b8a488", "#e2d2b4", "#f6ecd6" }
local CUTS = { 0.2, 0.38, 0.54, 0.7, 0.86 }

local function oval(cx, cy, rl, rw, a, egg)
  local ca, sa = cos(a), sin(a)
  local m = HP.mask()
  for y = floor(cy) - 9, floor(cy) + 9 do for x = floor(cx) - 9, floor(cx) + 9 do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / rl
    local v = (-dx * sa + dy * ca) / rw
    local e = egg and (1 + egg * u) or 1
    if u * u + (v / e) * (v / e) <= 1.0 then m:set(x, y) end
  end end
  return m
end

-- torn leaf scrap -------------------------------------------------------------------------------
local lm, ln, LT, LS, len = G.blade(5, 56, 28, 51, 58, 50, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.92 + 0.08)
  return max(0.45, 6.2 * sin(pi * u ^ 1.1) ^ 0.7)
end, { fold = 0.4 })
local ltok = { r = { name = "scrap" } }
G.toneN(c, lm, ln, SCRAP, { tok = ltok, cuts = CUTS, amb = 0.1, wrap = 0.2 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if abs(s) < 0.12 and t > 0.02 and t < 0.93 then c:put(x, y, s <= 0 and SCRAP[6] or SCRAP[3], ltok) return end
  for _, vt in ipairs{ 7, 13, 19, 25, 31, 37, 43 } do
    local d = t * len - (vt + abs(s) * 4.5)
    if d > -0.55 and d < 0.55 and abs(s) > 0.2 and abs(s) < 0.72 then c:put(x, y, s < 0 and SCRAP[5] or SCRAP[2], ltok) return end
  end
end)
for _, p in ipairs{ {5, 56}, {6, 57}, {6, 55}, {7, 58} } do if lm:has(p[1], p[2]) then c:put(p[1], p[2], SCRAP[5], ltok) end end

-- stems -------------------------------------------------------------------------------------------
local stok = { r = { name = "stem" } }
local function tube(pts, w0, w1)
  local m, n, T = G.tube(pts, function(t) return w0 + (w1 - w0) * t end)
  local sv = X.light(n, { amb = 0.15, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    local lit = sv[k] > 0.55
    local col = T[k] < 0.5 and (lit and STEM[3] or STEM[2]) or (lit and STEM[5] or STEM[4])
    c:put(x, y, col, stok)
  end)
  return m
end
tube({ {32, 47}, {32, 44}, {32, 42}, {32, 39} }, 1.3, 1.1)               -- short root-crown stem
tube({ {32, 40}, {33, 32}, {31, 22}, {32, 12} }, 0.8, 0.65)              -- central berry stalk
local P = {
  tube({ {32, 40}, {26, 38}, {18, 34}, {13, 28} }, 1.0, 0.8),
  tube({ {32, 40}, {38, 38}, {46, 34}, {51, 28} }, 1.0, 0.8),
}
tube({ {32, 40}, {32, 37}, {32, 34}, {32, 31} }, 1.0, 0.8)
for _, p in ipairs{ {31, 40}, {33, 40}, {32, 41} } do c:put(p[1], p[2], STEM[1], stok) end

-- palmate compound leaves: 5 rounded oval leaflets --------------------------------------------
local n_leaf = 0
local function leaflet(cx, cy, rl, rw, a)
  n_leaf = n_leaf + 1
  local m = oval(cx, cy, rl, rw, a, 0.12)
  local n = X.pillow(m, 2.4)
  local tok = { r = { name = "lf" .. n_leaf } }
  X.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), LEAF, { cuts = CUTS, tok = tok })
  local ca, sa = cos(a), sin(a)
  m:shrink(1):each(function(x, y)       -- short midrib on the inner 2/3
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / rl
    local v = (-dx * sa + dy * ca)
    if abs(v) < 0.5 and u < 0.45 and u > -0.85 then c:put(x, y, LEAF[2], tok) end
  end)
end
local function whorl(bx, by)
  local angs = { -185, -140, -95, -50, -5 }
  local order = { 1, 5, 2, 4, 3 }
  for _, i in ipairs(order) do
    local a = angs[i] * pi / 180
    local big = (i == 3)
    local rl, rw = big and 4.2 or 3.7, big and 2.7 or 2.3
    local d = rl + 0.9
    leaflet(bx + cos(a) * d, by + sin(a) * d, rl, rw, a)
  end
  c:put(bx, by, STEM[2], stok)
end
whorl(13, 28)
whorl(51, 28)
whorl(32, 31)

-- berry cluster -----------------------------------------------------------------------------------
local berries = {}
for i = 0, 5 do
  local a = (i / 6) * 2 * pi - pi / 2 + 0.3
  berries[#berries + 1] = { 32 + cos(a) * 4.3, 10 + sin(a) * 3.9, 2.3 }
end
berries[#berries + 1] = { 32, 10, 2.5 }
table.sort(berries, function(p, q) if p[3] ~= q[3] then return p[3] < q[3] end return p[2] < q[2] end)
-- pedicels from the stalk top
for _, b in ipairs(berries) do
  if b[3] < 2.5 then c:line({ {32, 13}, {floor(b[1] + .5), floor(b[2] + .5)} }, 1):each(function(x, y) c:put(x, y, STEM[2], stok) end) end
end
for i, b in ipairs(berries) do
  local m = oval(b[1], b[2], b[3], b[3], 0)
  local n = X.pillow(m, 2.6)
  local tok = { r = { name = "berry" .. i } }
  X.tone(c, m, X.light(n, { amb = 0.08, wrap = 0.2 }), BERRY, { cuts = CUTS, tok = tok })
  local bx, by = G.specAt(m, n, 24)
  if bx then c:put(bx, by, "#ffe0cc", tok) end
end
c:put(32, 9, BERRY[1], { r = { name = "berry7" } })   -- calyx dot on the front berry

-- seeds: flat cream discs with a rim and a notch -------------------------------------------------
local seeds = { { 16, 52, 4.2, 3.6, -0.3 }, { 28, 54, 3.9, 3.4, 0.25 }, { 47, 52, 4.2, 3.6, 0.1 } }
for i, s in ipairs(seeds) do
  s.m = oval(s[1], s[2], s[3], s[4], s[5])
  s.n = X.pillow(s.m, 4.0)   -- flat: broad plateau
  local tok = { r = { name = "seed" .. i } }
  local idx = X.tone(c, s.m, X.light(s.n, { amb = 0.18, wrap = 0.3 }), SEED, { cuts = CUTS, tok = tok })
  s.m:edge():each(function(x, y) if y > s[2] or x > s[1] + 2 then c:put(x, y, SEED[2], tok) end end)   -- rim shade lower-right
  s.m:shrink(2):each(function(x, y) if x < s[1] and y < s[2] and (x + y) % 2 == 0 then c:put(x, y, SEED[6], tok) end end)   -- raised face glint
  c:put(floor(s[1] + 0.5) - 1, floor(s[2] - s[4] + 0.5), SEED[1], tok)   -- notch
end
-- the split seed (3): dark seam, open gap, cream radicle and a tiny sprout
local sp = seeds[3]
local stk = { r = { name = "seed3" } }
for y = 49, 55 do if sp.m:has(47, y) then c:put(47, y, SEED[1], stk) end end
for _, p in ipairs{ {48, 50}, {48, 51}, {46, 53}, {46, 54} } do if sp.m:has(p[1], p[2]) then c:put(p[1], p[2], SEED[2], stk) end end
for _, p in ipairs{ {47, 52}, {47, 51} } do c:put(p[1], p[2], ROOT[3], { r = { name = "root" } }) end
c:line({ {47, 55}, {48, 57}, {50, 58} }, 1):each(function(x, y) if not lm:has(x, y) or true then c:put(x, y, ROOT[2], { r = { name = "root" } }) end end)
c:put(50, 58, ROOT[1], { r = { name = "root" } })
-- sprout stem + two round seed leaves
c:line({ {47, 49}, {47, 46}, {46, 44} }, 1):each(function(x, y) c:put(x, y, STEM[5], stok) end)
for k, o in ipairs{ { 42.5, 43, -0.15 }, { 49.5, 42.5, 0.2 } } do
  local m = oval(o[1], o[2], 2.9, 1.9, o[3])
  local tok = { r = { name = "sprout" .. k } }
  X.tone(c, m, X.light(X.pillow(m, 1.9), { amb = 0.1, wrap = 0.25 }), LEAF, { cuts = CUTS, tok = tok })
end
c:put(46, 43, LEAF[5], { r = { name = "sprout1" } })
G.save(c, NAME)
