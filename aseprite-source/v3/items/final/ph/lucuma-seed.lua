-- lucuma-seed (aC21_3, Opus single pass). Two glossy chestnut lucuma stones (buckeye-like: polished brown shell,
-- broad pale matte hilum scar along one side, one bright specular) on a torn scrap of lucuma leaf (dark glossy green,
-- obovate, pale midrib + pinnate veins, cool reflected edge, AO + contact shadow under each stone). The small stone has
-- sprouted: a slim brown-green stem with two elliptic seed leaves and an upright first true leaf, veined like the tree.
-- quirk: a smear of golden lucuma flesh still clings to the big stone.
local NAME = "lucuma-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local LEAF = { "#132f2c", "#1b4a38", "#256640", "#3a8548", "#5ea75a", "#94cc78" }
local VEIN, COOL, FIBRE = "#b8dc8c", "#3b6a6e", "#c9dc98"
local SEED = { "#2a1214", "#48201a", "#6e3220", "#97492a", "#bf6a3a", "#e39a5e" }
local HIL = { "#8a6a4e", "#b8946c", "#d8bc90", "#ecd8b0" }
local FLESH = { "#c8701e", "#f0a22c", "#ffd25a" }
local STEM = { "#4a3a2a", "#6e5a38", "#8a8048", "#b0b068" }
local ltok, stok = { r = { name = "leaf" } }, { r = { name = "stem" } }
local CUTS = { 0.16, 0.32, 0.48, 0.64, 0.82 }

-- stones: cx, cy, rx, ry, angle
local seeds = { { 23, 47, 7.2, 5.0, -0.22 }, { 37, 46, 5.0, 3.7, 0.45 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.75) end
local allS = HP.mask() for _, s in ipairs(seeds) do allS:add(s.m) end

-- leaf scrap: obovate lucuma leaf on the diagonal, base end torn off
local lm, ln, LT, LS, len = A.blade(6, 60, 28, 56, 54, 43, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 8.2 * sin(pi * min(1, t ^ 0.75 * 0.97 + 0.03)) ^ 0.6)
end, { fold = 0.35 })
local torn = A.tear(lm, 12, 49, 17, 63, 1.3, 4)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
local PER = 4.6
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5.5) / PER
  local f = ph - floor(ph)
  if f < 0.16 and abs(s) > 0.15 and abs(s) < 0.82 and t < 0.92 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and not torn:has(x, y) and LS[k] > 0.62 then c:put(x, y, COOL, ltok) end end)
torn:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, FIBRE, ltok) end end)
-- leaf gloss: one short hi streak on the lit half
for _, q in ipairs{ { 41, 46 }, { 42, 46 }, { 43, 45 } } do if lm:has(q[1], q[2]) and not bias[K(q[1], q[2])] then c:put(q[1], q[2], LEAF[6], ltok) end end

-- sprout from the small stone
local sp = { { 37, 44 }, { 35, 36 }, { 39, 31 }, { 37, 23 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
sm:cut(seeds[2].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function leaf(ax, ay, cx, cy, bx, by, w, veins)
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.45, w * sin(pi * min(1, t * 0.94 + 0.06)) ^ 0.7)
  end, { fold = 0.32 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.15 and t > 0.06 and t < 0.86 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
    if veins then
      local f = ((t * L - abs(s) * 3) / 3.2) % 1
      if f < 0.22 and abs(s) > 0.2 and abs(s) < 0.75 and t > 0.12 and t < 0.8 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
    end
  end)
  return m
end
local l1 = leaf(36, 27, 29, 23, 20, 25, 3.0, true)
local l2 = leaf(38, 27, 45, 22, 53, 23, 3.0, true)
local l3 = leaf(37, 23, 36, 18, 40, 12, 2.5, true)
-- AO where seed leaves meet the stem
for _, q in ipairs{ { 35, 27 }, { 39, 27 } } do c:put(q[1], q[2], LEAF[1], ltok) end

-- stones last: polished shell + matte hilum band on the lower side
for i, s in ipairs(seeds) do
  local tok = { r = { name = "stone" .. i } }
  local vis, sb = s.m:copy(), {}
  if i == 1 then X.ao(sb, s.m, seeds[2].m, 1, -1) end
  if i == 2 then vis:cut(HP.mask()) end
  local idx = A.toneN(c, vis, s.n, SEED, { tok = tok, bias = sb, cuts = { 0.14, 0.3, 0.46, 0.62, 0.84 }, amb = 0.1, wrap = 0.22 })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local v = (-dx * sa + dy * ca) / (s[4] + .45)
    if v > 0.32 and u > -0.35 and u < 0.85 then
      local hi = 1 + min(3, max(0, (idx[k] or 2) - 1))
      if v > 0.8 then hi = max(1, hi - 1) end
      c:put(x, y, HIL[hi], tok)
    elseif v > 0.18 and v <= 0.32 and abs(u) < 0.86 then
      c:put(x, y, SEED[3], tok)            -- soft lip where shell meets the scar
    end
  end)
  local gx, gy = A.specAt(vis, s.n, 40)
  c:put(gx, gy, A.CREAM, tok) c:put(gx + 1, gy, SEED[6], tok)
  if i == 1 then c:put(gx - 1, gy + 1, SEED[6], tok) end
end
-- quirk: flesh smear on the big stone (upper right of the shell)
local ftok = { r = { name = "stone1" } }
for _, q in ipairs{ { 26, 43, 2 }, { 27, 43, 3 }, { 28, 44, 2 }, { 27, 44, 2 }, { 29, 44, 1 }, { 26, 44, 1 } } do
  c:put(q[1], q[2], FLESH[q[3]], ftok)
end

A.save2(c, NAME)
