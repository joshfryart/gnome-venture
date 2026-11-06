-- leek-seed (final, Opus single pass). Four black, angular, wrinkled leek seeds (6-tone violet-black, a lit facet,
-- wrinkle creases, one glint each, AO between neighbours and a contact shadow) on a torn scrap of blue-green leek
-- leaf (flat strap, parallel veins, ragged tear at both ends, V-fold light, cool lower edge). One seed has sprouted:
-- a pale stem rising in the leek seedling's "flag" crook, plus a first flat strap leaf showing the leek blade.
-- quirk: the crook still wears the black seed coat on its tip like a little hat.
local NAME = "leek-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LF   = { "#14343c", "#1d4e4c", "#2a6a56", "#3f8a62", "#64aa72", "#98c98a" }
local SEED = { "#140e18", "#241a28", "#3a2c40", "#55445c", "#7c6a86", "#ada0b8" }
local STEM = { "#5f8a5a", "#93b878", "#c4dca2", "#eaf4cc" }
local COOL = "#4f7f8a"

-- leaf scrap: a slightly curved strap with ragged torn ends
local lm, ln, LT, LS, llen = A.blade(8, 46, 32, 41, 57, 47, function(t) return 7.2 - 1.2 * abs(t - 0.5) end, { fold = 0.35 })
local cut = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  local tear0 = 0.04 + 0.05 * X.hash(floor(s * 5), 3, 1) + 0.03 * sin(s * 9)
  local tear1 = 0.95 - 0.05 * X.hash(floor(s * 5), 9, 2) - 0.025 * sin(s * 7 + 1)
  if t < tear0 or t > tear1 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- seeds: angular polygons
local seeds = {
  { { 14, 42 }, { 19, 40 }, { 21, 44 }, { 17, 47 }, { 13, 46 } },
  { { 22, 45 }, { 26, 42 }, { 29, 44 }, { 28, 48 }, { 23, 48 } },
  { { 30, 40 }, { 35, 39 }, { 36, 43 }, { 32, 45 } },
  { { 41, 43 }, { 46, 42 }, { 47, 46 }, { 43, 48 }, { 40, 46 } },
}
local sm = {}
for i, p in ipairs(seeds) do sm[i] = c:poly(p) end
local all = HP.mask() for i = 1, #sm do all:add(sm[i]) end

-- sprout from seed 3: stem up into a crook; strap leaf up-left
local stp = { { 34, 40 }, { 35, 30 }, { 33, 22 }, { 36, 15 } }
local stm, stn, STT = A.tube(stp, function(t) return 1.1 end)
local hook = { { 36, 15 }, { 38, 11 }, { 42, 11 }, { 43, 16 } }
local hm, hn = A.tube(hook, function(t) return 1.0 end)
local fl, fn, FT, FS = A.blade(33, 38, 28, 26, 22, 14, function(t)
  if t > 0.985 then return -1 end
  return max(0.4, 1.9 * (t > 0.8 and ((1 - t) / 0.2) ^ 0.7 or 1))
end, { fold = 0.45 })

-- leaf scrap paint with AO + contact shadows
local bias = {}
X.ao(bias, lm, all, 1, -1)
A.cast(bias, lm, all, 1, 2, -1)
A.cast(bias, lm, stm, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LF, { tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.3, bias = bias })
lm:each(function(x, y) local k = K(x, y) local s = LS[k] local i = lidx[k] or 3
  if bias[k] then return end
  if abs(s) < 0.1 then c:put(x, y, LF[min(6, i + 1)], ltok)
  elseif abs(abs(s) - 0.45) < 0.08 or abs(abs(s) - 0.78) < 0.07 then c:put(x, y, LF[max(1, i - 1)], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y) if LS[k] > 0.7 and not bias[k] then c:put(x, y, COOL, ltok) end end)
-- pale torn fibres at the tears
lm:edge():each(function(x, y) local k = K(x, y)
  if (LT[k] < 0.14 or LT[k] > 0.86) and abs(LS[k]) < 0.85 and X.hash(x, y, 5) > 0.5 then c:put(x, y, "#b8d8a0", ltok) end end)

-- first true leaf (behind the stem)
fl:cut(stm)
local ftok = { r = { name = "sprout" } }
local fidx = A.toneN(c, fl, fn, LF, { tok = ftok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.14, wrap = 0.3 })
fl:each(function(x, y) local k = K(x, y) if abs(FS[k]) < 0.18 and FT[k] < 0.85 then c:put(x, y, LF[min(6, (fidx[k] or 3) + 1)], ftok) end end)

-- stem + crook
local sb = {}
X.ao(sb, stm, sm[3], 1, -1)
A.shade(c, stm, stn, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3, bias = sb, tok = ftok })
hm:cut(stm)
A.shade(c, hm, hn, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3, tok = ftok })

-- seeds
local stok = { r = { name = "seed" } }
for i, m in ipairs(seeds) do
  local mk = sm[i]
  local b = {}
  for j = i + 1, #sm do X.ao(b, mk, sm[j], 1, -1) end
  local bx0, by0, bx1, by1 = mk:bbox()
  local cx, cy = (bx0 + bx1) / 2, (by0 + by1) / 2
  local n = A.body(mk, cx, cy, max(bx1 - bx0, by1 - by0) / 2 + 1, 2, 0.5)
  local idx = A.shade(c, mk, n, SEED, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.05, wrap = 0.2, bias = b, tok = stok })
  -- wrinkle creases
  mk:shrink(1):each(function(x, y) if X.hash(x, y, 30 + i) > 0.7 then A.step(c, idx, SEED, x, y, -2, stok) end end)
  -- glint
  local gx, gy = A.specAt(mk, n, 40)
  c:put(gx, gy, SEED[6], stok)
end

-- quirk: seed coat cap on the crook tip
local cap = { { 0, 0, 3 }, { 1, 0, 2 }, { -1, 1, 4 }, { 0, 1, 3 }, { 1, 1, 2 }, { 2, 1, 1 }, { 0, 2, 2 }, { 1, 2, 1 } }
for _, q in ipairs(cap) do c:put(42 + q[1], 15 + q[2], SEED[q[3]], stok) end
c:put(42, 15, SEED[6], stok)

A.save(c, NAME)
