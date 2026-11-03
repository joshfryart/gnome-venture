-- apricot-seed (final, Opus). Two apricot stones on a torn apricot-leaf scrap. Stones: flattened almond shapes,
-- 6-tone tan-brown, a pale sharp keel along the upper edge, a groove along the face, fine pitting, AO + contact
-- shadow on the leaf. Leaf scrap: broad ovate apricot leaf, fine teeth, midrib + veins, V-fold light, ragged torn
-- base, cool reflected edge. The right stone has split: a pale radicle out the bottom, a stem with two fleshy round
-- cotyledons and a first pair of true leaves (ovate, toothed, drip tip, reddish petioles) showing the apricot leaf.
-- quirk: the empty half of the shell sits on the left cotyledon like a little hat.
local NAME = "apricot-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = A.new(NAME)

local LEAF  = { "#173d3a", "#215842", "#2f7548", "#47944e", "#6cb258", "#9fcf70" }
local YLEAF = { "#2a5a3e", "#3e7c46", "#5a9e4c", "#80bc58", "#a8d46e", "#d2ec98" }
local COT   = { "#3e6a3c", "#5e8e44", "#86b052", "#b0cc66", "#d4e48c" }
local STONE = { "#3c2220", "#5e3828", "#865632", "#ad7a46", "#cfa064", "#ecc890" }
local STEM  = { "#6e7a4a", "#9cae6a", "#c6d692", "#ecf2c4" }
local ROOT  = { "#9a8a78", "#c8b8a0", "#ece0c8" }
local PET, COOL = "#a3463a", "#3a6c72"
local ltok = { r = { name = "leaf" } }

-- stones (geometry first so the leaf can take their AO / cast shadow)
local S1 = { 19, 45.5, 6.4, 3.9, -0.32 }
local S2a = { 33.6, 42, 3.0, 4.4, -0.25 }    -- split stone: left half (front)
local S2b = { 39.6, 41.2, 2.8, 4.2, 0.2 }    -- right half
-- almond-shaped pips: blunt end + pointed tip; U along, V across (<0 lit)
local s1m, s1n, U1, V1 = A.pip(S1[1], S1[2], cos(S1[5]), sin(S1[5]), S1[3], S1[4], 0.9, 0.75)
local s2am, s2an, U2a, V2a = A.pip(S2a[1], S2a[2], sin(S2a[5]), -cos(S2a[5]), S2a[4], S2a[3], 0.9, 0.75)
local s2bm, s2bn, U2b, V2b = A.pip(S2b[1], S2b[2], sin(S2b[5]), -cos(S2b[5]), S2b[4], S2b[3], 0.9, 0.75)
local stones = HP.mask():add(s1m):add(s2am):add(s2bm)

-- leaf scrap: broad ovate, tip to the right, base torn off on the left
local lm, ln, LT, LS, len = A.blade(7, 52, 28, 50, 56, 39, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 10.2 * sin(pi * min(1, t * 0.9 + 0.1) ^ 0.85) ^ 0.6)
end, { fold = 0.4 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  -- ragged tear across the base
  local jag = 0.1 + 0.05 * sin(s * 9.0) + 0.03 * X.hash(floor(s * 6), 3, 2)
  if t < jag then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
-- fine teeth along the margin
local teeth = {}
lm:edge():each(function(x, y) local k = K(x, y)
  local ph = LT[k] * len / 2.4 + (LS[k] > 0 and 0.5 or 0)
  if LT[k] > 0.2 and LT[k] < 0.94 and (ph - floor(ph)) < 0.3 and abs(LS[k]) > 0.6 then teeth[#teeth + 1] = k end
end)
for _, k in ipairs(teeth) do lm.s[k] = nil end
local bias = {}
X.ao(bias, lm, stones, 1, -1)
A.cast(bias, lm, stones, 1, 2, -1)
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 and t < 0.92 then c:put(x, y, s <= 0 and "#c2e48c" or LEAF[3], ltok) return end
  if t > 0.14 and t < 0.86 and abs(s) > 0.22 and abs(s) < 0.76 then
    local d = (t * len - abs(s) * 7.5 + (s > 0 and 1.7 or 0)) % 4.4
    if d < 0.9 then c:put(x, y, s < 0 and LEAF[min(6, (lidx[k] or 3) + 1)] or LEAF[max(1, (lidx[k] or 3) - 1)], ltok) end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.2 and LT[k] < 0.86 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale broken tissue on the tear
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] < 0.17 and not bias[k] then c:put(x, y, YLEAF[5], ltok) end end)

-- radicle from the split stone, over the lower leaf edge
local rtok = { r = { name = "root" } }
local rm = A.stem(c, { { 36.5, 45 }, { 37, 49 }, { 39, 52 }, { 42, 54 } }, function(t) return 1.2 * (1 - t) + 0.35 end, ROOT, { tok = rtok, cuts = { 0.35, 0.65 } })
A.cast({}, lm, rm, 1, 1, -1)
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not stones:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
c:put(42, 55, ROOT[1], rtok) c:put(40, 53, ROOT[3], rtok)

-- sprout stem, cotyledons, true leaves
local stok = { r = { name = "stem" } }
local sm = A.stem(c, { { 36.5, 42 }, { 36, 34 }, { 37, 27 }, { 36.5, 19 } }, function(t) return 1.15 - 0.2 * t end, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 } })
local ctok = { r = { name = "cot" } }
local function cot(cx, cy, ux, uy)
  local m = A.rell(cx, cy, ux, uy, 4.6, 2.5)
  m:cut(sm)
  local n = X.pillow(m, 2.2)
  local idx = A.toneN(c, m, n, COT, { tok = ctok, cuts = { 0.24, 0.44, 0.64, 0.82 }, amb = 0.14, wrap = 0.3 })
  -- fleshy midline crease
  for i = -3, 2 do local x, y = floor(cx + ux * i + 0.5), floor(cy + uy * i + 0.5)
    if m:has(x, y) then c:put(x, y, COT[max(1, (idx[K(x, y)] or 3) - 1)], ctok) end end
  return m
end
local lx, ly = A.rot(-1, 0, 0.42)
local cl = cot(31.5, 29.6, lx, ly)
local rx, ry = A.rot(1, 0, -0.36)
local cr = cot(41.6, 29.4, rx, ry)
-- AO where the cotyledons meet the stem
for _, p in ipairs{ { 35, 30 }, { 38, 30 }, { 35, 31 }, { 38, 31 } } do if not sm:has(p[1], p[2]) then c:put(p[1], p[2], COT[1], ctok) end end
-- first true leaves: ovate, toothed, reddish petiole
local function tleaf(ax, ay, cx, cy, bx, by, w)
  local wf = function(t)
    if t > 0.985 then return -1 end
    if t < 0.18 then return 0.5 end
    local u = (t - 0.18) / 0.82
    return max(0.5, w * sin(pi * min(1, u * 0.92 + 0.05) ^ 0.75) ^ 0.7)
  end
  local m, T = A.leaf(c, ax, ay, cx, cy, bx, by, w, YLEAF, { tok = ltok, wfn = wf, teeth = 2.0, vs = 2.6, cut = sm })
  m:each(function(x, y) if T[K(x, y)] < 0.18 then c:put(x, y, PET, ltok) end end)
  return m
end
local tl = tleaf(36, 20, 31, 15, 24, 11, 3.6)
local tr = tleaf(37, 20, 42, 14, 50, 12, 3.9)
-- terminal bud
A.map(c, { ".a.", "aba" }, 35, 17, { a = YLEAF[3], b = YLEAF[5] }, ltok)

-- stones: almond light, raised keel (pale ridge + dark groove beside it), face seam, pitting, AO between halves
local function stone(m, n, U, V, tok, keelSide)
  local bb = {}
  X.ao(bb, m, sm, 1, -1)
  local idx = A.toneN(c, m, n, STONE, { tok = tok, bias = bb, cuts = { 0.16, 0.32, 0.5, 0.66, 0.84 }, amb = 0.08, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    local u, v, i = U[k], V[k] * keelSide, idx[k]
    if abs(u) < 0.86 then
      if v < -0.72 then c:put(x, y, STONE[min(6, i + 1)], tok)            -- keel ridge catches light
      elseif v < -0.46 then c:put(x, y, STONE[max(1, i - 2)], tok)       -- groove beside the keel
      elseif X.hash(x, y, 13) > 0.84 and abs(v) < 0.8 then c:put(x, y, STONE[max(1, i - 1)], tok) end  -- pitting
    end
  end)
  return idx
end
local t1 = { r = { name = "stone1" } }
stone(s1m, s1n, U1, V1, t1, 1)
c:put(15, 45, A.CREAM, t1) c:put(16, 44, STONE[6], t1)
-- split stone: halves open like a clam, dark inner seam, the stem rising from the gap
local t2 = { r = { name = "stone2" } }
local s2bv = s2bm:copy():cut(s2am):cut(sm)
stone(s2bv, s2bn, U2b, V2b, t2, -1)
local s2av = s2am:copy():cut(sm)
stone(s2av, s2an, U2a, V2a, t2, 1)
s2bv:each(function(x, y) if s2am:has(x - 1, y) or sm:has(x - 1, y) then c:put(x, y, STONE[1], t2) end end)
s2av:each(function(x, y) if sm:has(x + 1, y) then c:put(x, y, STONE[2], t2) end end)

-- quirk: empty shell half sitting on the left cotyledon like a hat
local htok = { r = { name = "hat" } }
A.map(c, {
  "..aabb..",
  ".acddbbe",
  "acddddbe",
  "eeffffee",
}, 25, 24, { a = STONE[5], b = STONE[4], c = STONE[6], d = STONE[3], e = STONE[2], f = STONE[1] }, htok)
for x = 26, 31 do if cl:has(x, 28) then c:put(x, 28, COT[1], ctok) end end   -- hat shadow on the cotyledon

A.save(c, NAME)
