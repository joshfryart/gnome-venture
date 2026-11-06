-- oregano-seed (final, Opus single pass aC31_3). A torn scrap of a broad ovate oregano leaf lying on the diagonal
-- (ragged tear at the base, V-fold light, midrib + paired veins, cool reflected edge, fuzz on the lit rim). On it a
-- little heap of tiny glossy dark-brown oregano seeds (each lit as a bead, AO between them, contact shadow on the
-- leaf). The middle seed has germinated: a hair-thin red-violet stem, two round cotyledons and the first pair of
-- ovate, finely veined oregano leaves with a bud between them.
-- quirk: one seed has rolled right off the scrap and sits alone past the leaf tip.
local NAME = "oregano-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new(NAME)

local LEAF = { "#1b382f", "#2a553b", "#3f7445", "#5c924d", "#84b062", "#b2d088" }
local VEIN, COOL, FUZZ = "#c4dc98", "#3d6e70", "#d6e8b0"
local SEED = { "#28161a", "#432420", "#64372a", "#875234", "#ad7346", "#d39e68" }
local STEM = { "#5a2e40", "#8a4a58", "#b77474", "#dba49a" }
local CUTS = { 0.18, 0.33, 0.5, 0.67, 0.84 }

-- leaf scrap (tip to the right)
local lm, ln, LT, LS, len = G.blade(9, 50, 28, 40, 53, 44, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 9.0 * sin(pi * min(1, t * 0.78 + 0.22)) ^ 0.6)
end, { fold = 0.36 })
-- torn base: ragged zig-zag tear across the leaf near the base
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local d = LT[k] * len
  local z = 3.5 + 2.2 * abs(((LS[k] * 4.3) % 2) - 1) + (LS[k] > 0.3 and 1.5 or 0)
  if d < z then cut[#cut + 1] = k end
  -- a small bite of tear on the lower edge too
  if LS[k] > 0.72 and d > 14 and d < 19 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- seeds: cx, cy, rx, ry, angle
local seeds = {
  { 20, 46, 1.9, 1.3, 0.4 }, { 24, 49, 1.9, 1.3, -0.3 }, { 25, 44, 1.8, 1.25, 0.9 },
  { 29, 47, 2.0, 1.35, 0.1 }, { 33, 49, 1.8, 1.25, -0.6 }, { 36, 45, 1.9, 1.3, 0.3 },
}
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end
local stray = { 56, 50, 1.9, 1.3, 0.2 }
stray.m, stray.n = G.oval(stray[1], stray[2], stray[3], stray[4], stray[5], 0.7)

-- sprout from seed 4 (29,47)
local sp = { { 29, 45 }, { 27, 34 }, { 33, 24 }, { 30, 13 } }
local sm, sn = G.tube(sp, function(t) return 0.95 end)
local seedAll = HP.mask() for _, s in ipairs(seeds) do seedAll:add(s.m) end

-- leaf tone with AO + contact shadow under seeds and stem foot
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 1, -1) end
G.cast(bias, lm, sm, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.3, 0.46, 0.6, 0.74, 0.88 }, amb = 0.1, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.06 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- paired veins sweeping to the tip
  local ph = (t * len - abs(s) * 6.0) / 7.0
  local f = ph - floor(ph)
  if f < 0.12 and abs(s) > 0.15 and abs(s) < 0.78 and t > 0.08 and t < 0.86 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LS[k] > 0.62 and LT[k] > 0.15 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end
  if LS[k] < -0.62 and LT[k] > 0.2 and LT[k] < 0.85 and (x + y) % 2 == 0 then c:put(x, y, FUZZ, ltok) end
end)

-- sprout stem (behind seeds)
local stok = { r = { name = "stem" } }
local smv = sm:copy():cut(seedAll)
G.toneN(c, smv, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })

-- cotyledons: two round little leaves at the stem's mid point
local function seedLeaf(ax, ay, bx, by, w, ramp)
  local cx, cy = (ax + bx) / 2, (ay + by) / 2 - 1
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.86 + 0.1)) ^ 0.5)
  end, { fold = 0.3 })
  m:cut(sm)
  return m, n, T, S
end
local cx0, cy0 = G.bez(sp, 0.6)
local cot = {}
cot[1] = { seedLeaf(cx0 - 0.5, cy0, cx0 - 7, cy0 - 2, 2.2) }
cot[2] = { seedLeaf(cx0 + 0.5, cy0, cx0 + 7, cy0 - 3, 2.2) }
local tx0, ty0 = G.bez(sp, 1)
local tru = {}
tru[1] = { seedLeaf(tx0 - 0.5, ty0, tx0 - 8, ty0 - 6, 2.8) }
tru[2] = { seedLeaf(tx0 + 0.5, ty0, tx0 + 8, ty0 - 7, 2.8) }
for _, L in ipairs(cot) do
  G.toneN(c, L[1], L[2], LEAF, { tok = ltok, cuts = { 0.26, 0.42, 0.57, 0.72, 0.87 }, amb = 0.16, wrap = 0.3 })
  L[1]:each(function(x, y) local k = K(x, y) if abs(L[4][k]) < 0.15 and L[3][k] > 0.15 and L[3][k] < 0.7 then c:put(x, y, LEAF[5], ltok) end end)
end
for _, L in ipairs(tru) do
  G.toneN(c, L[1], L[2], LEAF, { tok = ltok, cuts = { 0.26, 0.42, 0.57, 0.72, 0.87 }, amb = 0.16, wrap = 0.3 })
  L[1]:each(function(x, y) local k = K(x, y) local s, t = L[4][k], L[3][k]
    if abs(s) < 0.14 and t > 0.1 and t < 0.85 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) end
    local f = (t * 8 - abs(s) * 2.2) % 3
    if f < 0.35 and abs(s) > 0.25 and abs(s) < 0.75 and t > 0.2 and t < 0.8 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
  end)
  L[1]:edge():each(function(x, y) local k = K(x, y) if L[4][k] < -0.6 and L[3][k] > 0.3 and L[3][k] < 0.8 and (x + y) % 2 == 0 then c:put(x, y, FUZZ, ltok) end end)
end
-- terminal bud between the true leaves
local bud, bdn = G.oval(tx0, ty0 - 2.2, 1.0, 1.7, 0, 0.8)
G.toneN(c, bud, bdn, LEAF, { tok = ltok, cuts = CUTS, amb = 0.2, wrap = 0.3 })
c:put(floor(tx0), floor(ty0 - 4), LEAF[6], ltok)

-- seeds last: glossy beads, AO between neighbours (back to front by y)
local order = {}
for i, s in ipairs(seeds) do order[i] = s end
order[#order + 1] = stray
table.sort(order, function(a, b) return a[2] < b[2] end)
for i, s in ipairs(order) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #order do vis:cut(order[j].m) X.ao(sb, vis, order[j].m, 1, -1) end
  local tok = { r = { name = "seed" } }
  G.toneN(c, vis, s.n, SEED, { tok = tok, bias = sb, cuts = { 0.12, 0.3, 0.48, 0.66, 0.84 }, amb = 0.1, wrap = 0.3 })
  -- hilum: a pale scar dot at one end, and a glint
  local hx, hy = floor(s[1] + cos(s[5]) * s[3] * 0.7 + 0.5), floor(s[2] + sin(s[5]) * s[3] * 0.7 + 0.5)
  if vis:has(hx, hy) and not (hx == floor(s[1]) and hy == floor(s[2])) then c:put(hx, hy, SEED[2], tok) end
  local gx, gy = G.specAt(vis, s.n, 30)
  if gx then c:put(gx, gy, "#f2d6a6", tok) end
end
-- split seed coat at the sprout foot
c:put(29, 46, SEED[6]) c:put(30, 46, SEED[5])

G.save(c, NAME)
