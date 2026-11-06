-- sausage-tree-seed (final, Opus-level single pass). Kigelia seeds are big, hard, flattened brown ovals. Three of them sit on
-- a torn scrap of a pinnate Kigelia leaf: a pale rachis stub with a pair of oblong, leathery olive leaflets (wavy margin,
-- stippled, prominent pale chevron veins) spread in a wide V. The centre seed has split: a stout green hypocotyl, a pair
-- of fat oval cotyledons, and the first tiny pinnate leaf (terminal + two leaflets) on a petiole.
-- quirk: pale fibres of the sausage-fruit pulp still cling to the left seed like straw hair, with a blob of dried flesh.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_2.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new("sausage-tree-seed")
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local hash = X.hash

local OL = { "#1d2810", "#2f4217", "#496222", "#69872e", "#91b043", "#c0d870" }
local VEIN, COOL = "#cde48c", "#4a6a3a"
local RACH = { "#3a4a22", "#667638", "#9aa458", "#c8cc88", "#e8ecb4" }
local SEED = { "#25140f", "#432618", "#67401f", "#8f5c28", "#b98536", "#e0b062" }
local FIB = { "#7a5e3a", "#a98a52", "#d2b878", "#efdfac" }
local HYP = { "#2a4524", "#436e2e", "#6a9a40", "#98c460", "#c8e690" }
local COT = { "#1f4a2a", "#316f36", "#4a923e", "#72b450", "#a0d06e", "#d0ec9c" }
local NEW = { "#3a6a1c", "#5a9028", "#84b838", "#aed454", "#d2ea82", "#eefab8" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

local seeds = { { 14.5, 46, 5.4, 3.3, -0.42 }, { 48.5, 45.5, 5.2, 3.2, 0.5 } }
local halves = { { 27.2, 48.3, 4.0, 2.9, -0.35 }, { 35.6, 48.3, 4.0, 2.9, 0.35 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.85) end
for _, h in ipairs(halves) do h.m, h.n = A.oval(h[1], h[2], h[3], h[4], h[5], 0.85) end
local bias = {}
local ltok = { r = { name = "leaf" } }

-- ---- rachis stub (behind the leaflets), torn off at the bottom ----
local rm, rn, RT = A.tube({ { 31.5, 57 }, { 31.2, 53 }, { 31.6, 49 }, { 31.4, 45 } }, function(t) return 1.6 - 0.3 * t end)
-- ---- leaflets ----
local function leaflet(ax, ay, cx, cy, bx, by, w, seedOff)
  local m, n, T, S, len = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    local u = 0.08 + 0.9 * t
    local wave = 1 + 0.07 * sin(t * 24 + seedOff)
    return max(0.5, w * wave * max(0, sin(pi * min(1, u))) ^ 0.5)
  end, { fold = 0.4 })
  return m, n, T, S, len
end
local LL = { leaflet(31, 52.5, 17, 49, 7.5, 39.5, 7.0, 0) }
local LR = { leaflet(32.5, 52.5, 44, 50, 56.5, 40.5, 6.8, 2) }
local lmL, lmR = LL[1], LR[1]
local all = lmL:copy():add(lmR)
for _, s in ipairs(seeds) do X.ao(bias, all, s.m, 1, -1) A.cast(bias, all, s.m, 1, 2, -1) end
for _, h in ipairs(halves) do X.ao(bias, all, h.m, 1, -1) A.cast(bias, all, h.m, 1, 2, -1) end
-- the leaflets overlap at the base: right one on top. draw left first
local function paintLeaf(L, other)
  local m, n, T, S, len = L[1], L[2], L[3], L[4], L[5]
  A.toneN(c, m, n, OL, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if bias[k] then return end
    if abs(s) < 0.15 and t > 0.03 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or OL[3], ltok) return end
    local ph = (t * len - abs(s) * 3.6) / 4.2 + (s > 0 and 0.5 or 0)
    local f = ph - floor(ph)
    if f < 0.2 and abs(s) > 0.18 and abs(s) < 0.82 and t > 0.06 and t < 0.92 then
      c:put(x, y, s < 0 and OL[6] or OL[2], ltok) return end
    -- leathery stipple
    local h = hash(x, y, 13)
    if h > 0.93 then c:put(x, y, s < 0.2 and OL[5] or OL[2], ltok) end
  end)
  m:edge():each(function(x, y) local k = K(x, y)
    if not bias[k] and S[k] > 0.62 and T[k] > 0.08 and T[k] < 0.92 then c:put(x, y, COOL, ltok) end end)
end
paintLeaf(LL) paintLeaf(LR)
-- rachis over the leaf bases
local rb = {}
LL[1]:each(function(x, y) end)
X.tone(c, rm, X.light(rn, { amb = 0.18, wrap = 0.35 }), RACH, { cuts = { 0.25, 0.45, 0.65, 0.85 } })
rm:each(function(x, y) local k = K(x, y)
  if y > 55 then c:px(x, y, (x + y) % 2 == 0 and RACH[5] or RACH[4]) end        -- fibrous torn end
  if (y % 4 == 0) and RT[k] > 0.05 then c:px(x, y, RACH[1]) end                  -- node ring
end)
c:px(30, 57, RACH[4]) c:px(33, 57, RACH[5]) c:px(31, 58, RACH[3])
-- AO where the rachis meets the leaflets
for _, p in ipairs{ { 29, 50 }, { 29, 51 }, { 34, 50 }, { 34, 51 } } do c:px(p[1], p[2], OL[1]) end

-- ---- sprout ----
local stok = { r = { name = "hyp" } }
local sm, sn, ST = A.tube({ { 31.5, 46.5 }, { 30.6, 40 }, { 32.8, 32 }, { 32.2, 25 } }, function(t) return 1.45 - 0.3 * t end)
for _, h in ipairs(halves) do sm:cut(h.m) end
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), HYP, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = stok })
sm:each(function(x, y) local k = K(x, y) if abs(sn[k][1]) < 0.15 then c:put(x, y, HYP[5], stok) end end)
-- cotyledons: fat ovals, drooping a little
local ctok = { r = { name = "cot" } }
local function cot(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.6, w * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.55)
  end, { fold = 0.3 })
  m:cut(sm)
  A.toneN(c, m, n, COT, { tok = ctok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.88 then c:put(x, y, S[k] <= 0 and COT[6] or COT[2], ctok) end end)
  m:edge():each(function(x, y) if S[K(x, y)] and S[K(x, y)] > 0.6 then c:put(x, y, "#3a7a62", ctok) end end)
  return m
end
local cl = cot(31.2, 25.5, 24, 19, 15.5, 22, 3.4)
local cr = cot(33.2, 25.5, 41, 19.5, 49.5, 22.5, 3.4)
-- the first true leaf: petiole + a terminal leaflet and one pair (tiny pinnate leaf)
local pet = { { 32.4, 25 }, { 32.2, 21 }, { 32.8, 17 }, { 32.6, 14.5 } }
local pm, pn = A.tube(pet, function(t) return 0.85 end)
pm:cut(cl):cut(cr)
X.tone(c, pm, X.light(pn, { amb = 0.18, wrap = 0.3 }), HYP, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = stok })
local function lf(x, y, ux, uy, ra, rb)
  local m = A.rell(x, y, ux, uy, ra, rb)
  m:cut(pm)
  local n = X.pillow(m, 1.6)
  A.toneN(c, m, n, NEW, { tok = ctok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  -- midrib
  m:each(function(px, py)
    local dx, dy = px - x, py - y
    local across = abs(-dx * uy + dy * ux)
    if across < 0.5 and abs(dx * ux + dy * uy) < ra - 0.6 then c:put(px, py, NEW[6], ctok) end
  end)
end
do
  local a1x, a1y = A.rot(0, -1, -0.95)
  local a2x, a2y = A.rot(0, -1, 0.95)
  lf(32.6, 11.3, 0, -1, 3.3, 1.9)               -- terminal
  lf(29.8, 16.4, a1x, a1y, 3.1, 1.6)
  lf(35.4, 16.0, a2x, a2y, 3.1, 1.6)
end
-- contact shadow where cotyledons leave the stem
for _, p in ipairs{ { 30, 26 }, { 34, 26 } } do if cl:has(p[1], p[2]) or cr:has(p[1], p[2]) then c:put(p[1], p[2], COT[1], ctok) end end

-- ---- seeds ----
local function seedBody(s, i)
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  s.m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + 0.45), flip * (-dx * sa + dy * ca) / (s[4] + 0.45)
    local r2 = u * u + v * v
    local j
    if v < -0.55 then j = 5 elseif v < -0.2 then j = 4 elseif v < 0.2 then j = 3 elseif v < 0.55 then j = 2 else j = 1 end
    if r2 > 0.62 and v > 0 then j = j - 1 end                          -- shade rim, lower right
    if abs(v - 0.1) < 0.12 and abs(u) < 0.62 then j = min(6, j + 2) end -- raised raphe ridge along the long axis
    if hash(x, y, 31 + i) > 0.9 then j = j - 1 end                      -- pitted woody coat
    if v < -0.35 and u > -0.65 and u < -0.15 then j = 6 end            -- lit plane, upper left
    c:put(x, y, SEED[max(1, min(6, j))], tok)
  end)
  -- hilum: pale scar notch at the narrow end
  local hx, hy = floor(s[1] + (s[3] - 0.6) * ca + 0.5), floor(s[2] + (s[3] - 0.6) * sa + 0.5)
  c:put(hx, hy, FIB[3], tok) c:put(hx - 1, hy, SEED[1], tok)
  -- polish glint
  local gx, gy = floor(s[1] - 1.8 * ca + 1.2 * sa * flip * -1 + 0.5), floor(s[2] - 1.8 * sa - 1.2 * ca * flip + 0.5)
  if s.m:has(gx, gy) then c:put(gx, gy, "#fff0c0", tok) c:put(gx + 1, gy, "#f6d890", tok) end
end
seedBody(seeds[1], 1) seedBody(seeds[2], 2)
-- split seed: two coat halves, pale inner face along the split
for hi, h in ipairs(halves) do
  local tok = { r = { name = "half" .. hi } }
  local ca, sa = cos(h[5]), sin(h[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  h.m:each(function(x, y)
    local dx, dy = x - h[1], y - h[2]
    local u, v = (dx * ca + dy * sa) / (h[3] + 0.45), flip * (-dx * sa + dy * ca) / (h[4] + 0.45)
    local j
    if v < -0.5 then j = 5 elseif v < -0.1 then j = 4 elseif v < 0.3 then j = 3 elseif v < 0.65 then j = 2 else j = 1 end
    if abs(u) > 0.8 then j = j - 1 end
    if hash(x, y, 77 + hi) > 0.9 then j = j - 1 end
    if v < -0.4 and u > -0.6 and u < -0.1 then j = 6 end
    c:put(x, y, SEED[max(1, min(6, j))], tok)
  end)
end
-- pale inner face between the halves + contact AO under the hypocotyl
for _, p in ipairs{ { 29, 47 }, { 29, 48 }, { 30, 49 }, { 33, 47 }, { 33, 48 }, { 32, 49 } } do
  if not sm:has(p[1], p[2]) then c:put(p[1], p[2], FIB[4], { r = { name = "face" } }) end end
c:put(30, 50, FIB[2], { r = { name = "face" } }) c:put(31, 50, FIB[1], { r = { name = "face" } }) c:put(32, 50, FIB[2], { r = { name = "face" } })
-- thin dark crack line where hypocotyl leaves the coat
c:px(30, 46, HYP[1]) c:px(33, 46, HYP[1])

-- ---- quirk: fruit-pulp fibres clinging to the left seed ----
local function fibre(x0, y0, pts)
  local last = { x0, y0 }
  for j, p in ipairs(pts) do
    local x, y = x0 + p[1], y0 + p[2]
    c:px(x, y, FIB[(j % 2 == 0) and 2 or 3])
  end
  local p = pts[#pts]
  c:px(x0 + p[1], y0 + p[2], FIB[4])
end
-- fibres drape off the lower-right end of seed 1
fibre(18, 47, { { 1, 1 }, { 2, 2 }, { 2, 3 }, { 3, 4 } })
fibre(17, 48, { { 0, 1 }, { 0, 2 }, { 1, 3 }, { 1, 4 }, { 0, 5 } })
fibre(19, 46, { { 1, 0 }, { 2, 1 }, { 3, 1 }, { 4, 2 } })
fibre(16, 49, { { -1, 1 }, { -1, 2 }, { -2, 3 }, { -3, 3 } })
-- dried flesh blob + its shadow
for _, p in ipairs{ { 17, 49, 3 }, { 18, 49, 3 }, { 19, 49, 2 }, { 17, 50, 2 }, { 18, 50, 2 } } do c:put(p[1], p[2], FIB[p[3]], { r = { name = "flesh" } }) end
c:px(17, 51, FIB[1]) c:px(18, 51, FIB[1])
A.save(c, "sausage-tree-seed")
