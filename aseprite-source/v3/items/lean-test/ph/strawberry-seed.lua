-- strawberry-seed (lean L1_1)
-- Four tiny golden achenes (the "seeds" on a strawberry's skin) on a broad serrated strawberry leaflet; one achene has split
-- and sends up a short stem with two round cotyledons and a tiny three-part true leaf.
-- quirk: a glassy dewdrop sits on the leaf edge and magnifies a bit of the vein.
local NAME = "strawberry-seed"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local LEAF  = { "#15363a", "#1d5240", "#2c6e44", "#43904a", "#6aae54", "#a0cc68" }
local SLEAF = { "#18403a", "#256045", "#368449", "#56a652", "#80c15c", "#b4dc7c" }
local ACH   = { "#4a2a18", "#7a4a20", "#a8702a", "#cf9a38", "#ecc254", "#fbe896" }
local STEM  = { "#4e2c2c", "#7a443a", "#a05e48", "#6e8a48", "#98b05a" }
local VEIN, GLOSS, COOL, RED = "#c8e690", "#e6f6b0", "#3a6a78", "#a8443e"

local function seedMask(cx, cy, rl, rw, a)
  local ca, sa = cos(a), sin(a)
  local m = HP.mask()
  for y = floor(cy) - 5, floor(cy) + 5 do for x = floor(cx) - 5, floor(cx) + 5 do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (rl + 0.4)
    local v = (-dx * sa + dy * ca)
    if abs(u) <= 1 then
      local hw = (rw + 0.4) * sqrt(1 - u * u) * (1 - 0.3 * u)
      if abs(v) <= hw then m:set(x, y) end
    end
  end end
  return m
end
local seeds = {
  { 15, 50, 3.4, 2.3, -0.5 },
  { 29, 52, 3.2, 2.2, 0.5 },
  { 24, 45, 3.4, 2.3, 2.2 },   -- sprouts
  { 40, 47, 3.3, 2.2, -2.3 },
}
for _, s in ipairs(seeds) do s.m = seedMask(s[1], s[2], s[3], s[4], s[5]) s.n = X.pillow(s.m, 2.4) end

-- broad serrated leaflet
local lm, ln, LT, LS, len = G.blade(7, 53, 30, 56, 57, 42, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.94 + 0.06)
  return max(0.5, 8.2 * sin(pi * u ^ 0.85) ^ 0.62)
end, { fold = 0.3 })
local nib = HP.mask()
lm:edge():each(function(x, y) local k = K(x, y)
  local p = (LT[k] * len) % 4
  if abs(LS[k]) > 0.55 and LT[k] > 0.12 and LT[k] < 0.94 and p < 1.0 then nib:set(x, y) end end)
lm:cut(nib)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) G.cast(bias, lm, s.m, 2, 2, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.2 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 and t > 0.02 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  for _, vt in ipairs{ 7, 12, 17, 22, 27, 32, 37, 42 } do   -- straight parallel lateral veins to each tooth
    local d = t * len - (vt + abs(s) * 4.2)
    if d > -0.5 and d < 0.5 and abs(s) > 0.16 and abs(s) < 0.8 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) return end
  end
  if s < -0.4 and s > -0.62 and t > 0.55 and t < 0.75 then c:put(x, y, GLOSS, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LS[k] > 0.62 and LT[k] > 0.1 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end
  if LT[k] < 0.06 then c:put(x, y, LEAF[2], ltok) end
end)

-- dewdrop quirk (glass: bright rim, pale core, one glint)
local dm = c:ellipse(49, 40, 2, 2)
local dtok = { r = { name = "dew" } }
dm:each(function(x, y) c:put(x, y, "#9fd8e0", dtok) end)
dm:edge():each(function(x, y) c:put(x, y, "#2f7a88", dtok) end)
c:put(48, 39, "#f2feff", dtok) c:put(50, 41, "#6cb8c6", dtok) c:put(49, 42, "#8fcad4", dtok)
for _, p in ipairs{ {49, 43}, {50, 43} } do if lm:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[1], ltok) end end

-- sprout
local stm, stn, ST = G.tube({ {23, 42}, {22, 36}, {26, 30}, {26, 22} }, function(t) return 0.95 end)
local stok = { r = { name = "stem" } }
local sv = X.light(stn, { amb = 0.15, wrap = 0.3 })
stm:each(function(x, y) local k = K(x, y) local lit = sv[k] > 0.55
  local col
  if ST[k] < 0.5 then col = lit and STEM[3] or STEM[2] else col = lit and STEM[5] or STEM[4] end
  c:put(x, y, col, stok) end)
local function sleaf(name, ax, ay, cx, cy, bx, by, w, veins)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.9 + 0.1)
    return max(0.5, w * sin(pi * u ^ 1.0) ^ 0.6)
  end, { fold = 0.4 })
  m:cut(stm)
  local tok = { r = { name = name } }
  G.toneN(c, m, n, SLEAF, { tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.14 and t > 0.08 and t < 0.9 then c:put(x, y, s <= 0 and SLEAF[6] or SLEAF[2], tok) return end
    for _, vt in ipairs(veins) do
      local d = t * L - (vt + abs(s) * 2.6)
      if d > -0.5 and d < 0.5 and abs(s) > 0.3 and abs(s) < 0.7 then c:put(x, y, s < 0 and SLEAF[6] or SLEAF[2], tok) return end
    end
  end)
  m:edge():each(function(x, y) local k = K(x, y) if S[k] > 0.6 and T[k] > 0.15 and T[k] < 0.85 then c:put(x, y, COOL, tok) end end)
end
-- two round cotyledons
sleaf("cotl", 25, 26, 20, 28, 13, 25, 3.6, { 5 })
sleaf("cotr", 27, 26, 33, 28, 39, 24, 3.6, { 5 })
-- tiny trifoliate true leaf
sleaf("tl", 26, 22, 21, 19, 17, 17, 2.6, { 3 })
sleaf("tr", 26, 22, 31, 19, 36, 16, 2.6, { 3 })
sleaf("tc", 26, 22, 25, 15, 27, 8, 2.8, { 3, 5 })
for _, p in ipairs{ {25, 24}, {27, 24}, {26, 24} } do if stm:has(p[1], p[2]) then c:put(p[1], p[2], STEM[1], stok) end end

-- achenes
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = X.tone(c, s.m, X.light(s.n, { amb = 0.06, wrap = 0.22 }), ACH, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 }, tok = tok })
  s.m:shrink(1):each(function(x, y) local k = K(x, y)
    if idx[k] >= 3 and idx[k] <= 5 and X.hash(x, y, 7 + i) > 0.8 then c:put(x, y, ACH[idx[k] - 1], tok) end end)
  local tx, ty = floor(s[1] + cos(s[5]) * (s[3] - 0.5) + .5), floor(s[2] + sin(s[5]) * (s[3] - 0.5) + .5)
  if s.m:has(tx, ty) then c:put(tx, ty, RED, tok) end   -- reddish pointed tip
  local bx, by = G.specAt(s.m, s.n, 30)
  if bx then c:put(bx, by, "#fffbe8", tok) end
end
for _, p in ipairs{ {22, 44}, {24, 44}, {23, 45} } do if seeds[3].m:has(p[1], p[2]) then c:put(p[1], p[2], ACH[1], { r = { name = "seed3" } }) end end
c:put(23, 44, STEM[2], { r = { name = "seed3" } })
G.save(c, NAME)
