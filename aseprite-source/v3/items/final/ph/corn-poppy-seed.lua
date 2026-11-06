-- corn-poppy-seed (final pass, Opus single pass). A small heap of tiny kidney-shaped poppy seeds (slate blue-grey,
-- each with a lit cap and a dark hilum notch) on a torn corn-poppy leaf scrap: deeply cut pinnate lobes with
-- toothed tips, grey-green and bristly (pale hairs on the margin), midrib + a vein into each lobe, AO and contact
-- shadow under the heap. From the left a seed has sprouted: a thin hairy stem, two narrow cotyledons and a first
-- true leaf that is already lobed and toothed like the parent.
-- quirk: a dried poppy pepper-pot capsule lies tipped over, still sprinkling seeds out of the pores under its crown.
local NAME = "corn-poppy-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#1e3a34", "#2d5442", "#40704c", "#5c8c58", "#84aa6e", "#b4cc92" }
local HAIR, COOL = "#dce8c0", "#466a74"
local SEED = { "#262a4a", "#424a70", "#646e98", "#8c98c0", "#b8c4e2", "#e4ecf8" }
local CAP  = { "#4a3a28", "#6e5636", "#94784a", "#b89c64", "#d6be86", "#eedcaa" }
local STEM = { "#4c7a52", "#7aa468", "#a8c88a", "#d4e6b4" }
local ltok, stok, ktok = { r = { name = "leaf" } }, { r = { name = "stem" } }, { r = { name = "capsule" } }

-- seed heap: kidney seeds (cx, cy, flip)
local SEEDS = { { 29, 45 }, { 34, 44 }, { 39, 45 }, { 31, 49 }, { 36, 48 }, { 41, 49 }, { 33, 41, 1 }, { 26, 50, 1 }, { 44, 46 } }
local heap = HP.mask()
for _, s in ipairs(SEEDS) do heap:add(c:rect(s[1] - 1, s[2] - 1, s[1] + 2, s[2] + 1)) end

-- capsule (quirk) lying tipped toward the upper right of the heap
local CX, CY = 50, 38
local ux, uy = A.norm(-0.85, 0.55, 0)    -- axis from crown toward the stalk
local cap = A.rell(CX, CY, ux, uy, 4.6, 3.4)
local crown = A.rell(CX - ux * 4.4, CY - uy * 4.4, uy, -ux, 3.6, 1.6)

-- leaf scrap: deeply lobed pinnate blade on the diagonal
local lm, ln, LT, LS, len = A.blade(7, 55, 30, 51, 57, 42, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 9.4 * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.6)
end, { fold = 0.4 })
local PER = 6.6
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local ph = t * len / PER + (s > 0 and 0.5 or 0) + 0.2
  local f = abs((ph - floor(ph)) - 0.5) * 2
  local lim = 0.95 - (1 - f) ^ 1.6 * 0.6
  if abs(s) > lim and t > 0.06 then cut[#cut + 1] = k end
  -- teeth on the lobes
  if abs(s) > 0.78 and ((x + y * 2) % 3 == 0) then cut[#cut + 1] = k end
  -- torn base on the left
  if t < 0.07 and X.hash(x, y, 4) > 0.5 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
X.ao(bias, lm, heap, 1, -1) A.cast(bias, lm, heap, 1, 2, -1)
X.ao(bias, lm, cap, 1, -1) A.cast(bias, lm, cap, 1, 2, -1)
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.03 and t < 0.94 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 4.4) / PER + (s > 0 and 0.5 or 0) + 0.2
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.88 and abs(s) > 0.16 and abs(s) < 0.72 and t < 0.92 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LS[k] > 0.62 then c:put(x, y, COOL, ltok)
  elseif LS[k] < -0.5 and X.hash(x, y, 8) > 0.62 then c:put(x, y, HAIR, ltok) end end)

-- sprout from a seed at the left of the heap
local SX, SY = 21, 48
local sm = A.stem(c, { { SX, SY - 1 }, { 19, 40 }, { 23, 33 }, { 21, 24 } }, function(t) return 0.95 end, STEM, { tok = stok })
for _, q in ipairs{ { 19, 41 }, { 21, 35 }, { 23, 32 }, { 21, 28 } } do c:put(q[1] - 1, q[2], HAIR, stok) end   -- bristles
A.leaf(c, 20, 26, 15, 23, 9, 22, 1.5, LEAF, { pw = 0.5, fold = 0.3, cut = sm, vs = 99, tok = ltok })
A.leaf(c, 22, 26, 27, 23, 32, 22, 1.5, LEAF, { pw = 0.5, fold = 0.3, cut = sm, vs = 99, tok = ltok })
-- true leaf: lanceolate, cut into toothed lobes
local tm, tn, TT, TS, tlen = A.blade(21, 25, 19, 18, 24, 12, function(t)
  if t > 0.97 then return -1 end
  return max(0.4, 3.2 * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.7)
end, { fold = 0.45 })
local tc = {}
tm:each(function(x, y) local k = K(x, y)
  local ph = TT[k] * tlen / 3.4 + (TS[k] > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if abs(TS[k]) > 0.92 - (1 - f) ^ 2 * 0.5 and TT[k] > 0.12 then tc[#tc + 1] = k end
end)
for _, k in ipairs(tc) do tm.s[k] = nil end
A.toneN(c, tm, tn, LEAF, { tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.14, wrap = 0.3 })
tm:each(function(x, y) local k = K(x, y) if abs(TS[k]) < 0.16 and TT[k] > 0.05 and TT[k] < 0.85 then c:put(x, y, TS[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
tm:edge():each(function(x, y) if TS[K(x, y)] < -0.4 and X.hash(x, y, 2) > 0.6 then c:put(x, y, HAIR, ltok) end end)

-- seeds: kidney (3x2 with a notch), lit cap upper-left, hilum dark, AO on lower neighbours
local function kidney(cx, cy, flip, tok)
  local px = {
    { -1, -1, 4 }, { 0, -1, 5 }, { 1, -1, 4 }, { 2, -1, 3 },
    { -1, 0, 3 }, { 0, 0, flip and 4 or 2 }, { 1, 0, 3 }, { 2, 0, 2 },
  }
  for _, p in ipairs(px) do c:put(cx + p[1], cy + p[2], SEED[p[3]], tok) end
  c:put(cx - 1, cy - 1, SEED[5], tok)
  c:put(cx + (flip and -1 or 1), cy + 1, SEED[2], tok)  -- swollen lobe below
end
-- sprouting seed: cracked, radicle peeking down
kidney(SX, SY + 1, false, { r = { name = "seed0" } })
c:put(SX, SY, SEED[6], { r = { name = "seed0" } })
c:put(SX - 2, SY + 2, STEM[4], stok) c:put(SX - 3, SY + 3, STEM[3], stok)
for i, s in ipairs(SEEDS) do kidney(s[1], s[2], s[3] == 1, { r = { name = "seed" .. i } }) end
-- glint on the top seed
c:put(33, 39, SEED[6], { r = { name = "seed7" } })

-- capsule body: ribbed oval, pale straw-tan, AO under the crown
local cn = {}
local cb = {}
X.ao(cb, cap, crown, 1, -1)
local nn = X.sphere(CX - 0.6, CY - 0.6, 5.2, cap)
local cidx = A.shade(c, cap, nn, CAP, { amb = 0.08, wrap = 0.25, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, tok = ktok, bias = cb })
-- ribs along the axis
cap:each(function(x, y) local k = K(x, y)
  local dx, dy = x - CX, y - CY
  local b = -dx * uy + dy * ux
  if floor(b + 10.5) % 2 == 0 and abs(b) < 3 then c:put(x, y, CAP[max(1, (cidx[k] or 3) - 1)], ktok) end
end)
-- stalk stub at the base
local bx, by = CX + ux * 5.6, CY + uy * 5.6
A.line(c, { { bx, by }, { bx + ux * 2.4, by + uy * 2.4 } }, CAP[2], ktok)
-- crown: flat disc with dark radiating rays; pores (dark dots) just under it, seeds trickling out
crown:each(function(x, y) c:put(x, y, CAP[5], ktok) end)
crown:edge():each(function(x, y) if (x + y) % 2 == 0 then c:put(x, y, CAP[3], ktok) end end)
local ccx, ccy = floor(CX - ux * 4.4 + 0.5), floor(CY - uy * 4.4 + 0.5)
c:put(ccx, ccy, CAP[2], ktok) c:put(ccx + 1, ccy - 1, CAP[6], ktok)
for _, q in ipairs{ { 1, 1 }, { -1, 2 }, { 2, -1 } } do
  local x, y = floor(CX - ux * 2.6 + q[1] * uy + 0.5), floor(CY - uy * 2.6 - q[1] * ux + q[2] * 0.3 + 0.5)
  if cap:has(x, y) then c:put(x, y, CAP[1], ktok) end
end
-- trickle: three seeds between pores and heap
for _, q in ipairs{ { 46, 43 }, { 45, 41 } } do c:put(q[1], q[2], SEED[4], { r = { name = "fall" } }) c:put(q[1] + 1, q[2], SEED[2], { r = { name = "fall" } }) end

A.save(c, NAME)
