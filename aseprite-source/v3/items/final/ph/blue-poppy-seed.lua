-- blue-poppy-seed (final, Opus single pass). Meconopsis: a spill of tiny slate kidney seeds pouring out of a dry,
-- ribbed, bristly pepper-pot capsule that lies on a torn glaucous poppy-leaf scrap (wavy margin, midrib, hairs,
-- V-fold light, cool edge, AO + contact shadows). One seed has sprouted: thin stem, two tiny linear cotyledons and
-- two bristly spoon-shaped first leaves in the blue-green of the Himalayan poppy rosette.
-- quirk: the capsule is tipped over like a pepper pot, still shaking seeds out of the pores under its crown.
local NAME = "blue-poppy-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR21_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#18343a", "#22504e", "#2f6c60", "#468a72", "#6aa888", "#9ccaa6" }
local VEIN, COOL, TORN, HAIR = "#bfe0bc", "#3d6a82", "#d4e8b2", "#d9e6c4"
local SPR = { "#1d4646", "#2a6456", "#3d8266", "#58a074", "#80be8a", "#b6dcac" }
local STEM = { "#3c7458", "#679e78", "#9cc898", "#d2ecc4" }
local CAP = { "#47321f", "#6c4e30", "#93703f", "#b8924f", "#d7b46e", "#f0da9c" }
local SD = { "#19152a", "#2b2742", "#403d5e", "#5b5a80", "#8584aa", "#c0bedc" }

-- leaf scrap: oblong poppy leaf, gently arched, tip right, torn off at the left
local lm, ln, LT, LS, len = A.blade(7, 52, 30, 41, 58, 47, function(t)
  if t > 0.99 then return -1 end
  local w = 8.2 * sin(pi * min(1, 0.16 + t * 0.86)) ^ 0.55
  return max(0.6, w + 0.7 * sin(t * 55 / 3.1))        -- wavy margin
end, { fold = 0.36 })
A.tear(lm, function(x, y) return LT[K(x, y)] end, 0.05, false, 0.09, 3)
local tornEdge = {}
for _, p in ipairs(A.border(lm)) do local k = K(p[1], p[2]) if LT[k] < 0.13 and p[3] <= 0 then tornEdge[k] = true end end

-- capsule (lies on the leaf, crown to the left)
local CX, CY, CRX, CRY, CA = 45.5, 38.5, 7.6, 3.7, -0.32
local capm, capn = A.oval(CX, CY, CRX, CRY, CA, 0.75)
local ca, sa = cos(CA), sin(CA)
-- crown disc at the left end
local crown = A.rell(CX - (CRX + 0.6) * ca, CY - (CRX + 0.6) * sa, ca, sa, 1.6, 3.6)
-- pedicel stub at the right end
local ped = HP.mask()
for i = 0, 5 do local x, y = CX + (CRX + i) * ca, CY + (CRX + i) * sa - i * 0.55 ped:set(floor(x + .5), floor(y + .5)) ped:set(floor(x + .5), floor(y + 1.5)) end
ped:cut(capm)

-- seeds: spill from the crown along the leaf (cx, cy, glyph)
local GH = { { 3, 5, 3 }, { 2, 2, 1 } }                -- kidney lying flat
local GV = { { 4, 3 }, { 4, 2 }, { 2, 1 } }            -- kidney on its end
local GB = { { 0, 4, 3, 0 }, { 3, 5, 3, 2 }, { 0, 2, 1, 0 } } -- larger front seed
local seeds = {
  { 34, 42, GV }, { 31, 45, GH }, { 35, 46, GH }, { 28, 43, GH }, { 26, 47, GB }, { 31, 49, GV },
  { 22, 46, GH }, { 21, 50, GH }, { 36, 50, GV }, { 25, 51, GH }, { 17, 48, GB }, { 39, 47, GH }, { 29, 52, GH },
}
local sm = HP.mask()
for _, s in ipairs(seeds) do for j, row in ipairs(s[3]) do for i, v in ipairs(row) do if v > 0 then sm:set(s[1] + i - 1, s[2] + j - 1) end end end end

-- leaf light with AO under capsule and seeds
local bias = {}
X.ao(bias, lm, capm, 1, -1) A.cast(bias, lm, capm, 1, 2, -1) A.cast(bias, lm, capm, 2, 3, -1)
A.cast(bias, lm, sm, 1, 1, -2)
local ltok = { r = { name = "leaf" } }
local lidx = A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.06 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5.5) / 6.2
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.18 and abs(s) < 0.72 and t > 0.08 and t < 0.9 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) return end
  -- leaf hairs: sparse pale specks on the lit half
  if s < -0.3 and X.hash(x, y, 7) > 0.9 and t > 0.1 then c:put(x, y, HAIR, ltok) end
end)
for _, p in ipairs(A.border(lm)) do local k = K(p[1], p[2])
  if tornEdge[k] then c:put(p[1], p[2], TORN, ltok)
  elseif not bias[k] and LS[k] > 0.62 and LT[k] > 0.12 and LT[k] < 0.9 then c:put(p[1], p[2], COOL, ltok) end end
-- edge bristles on the upper margin
for _, p in ipairs(A.border(lm)) do local k = K(p[1], p[2])
  if LS[k] < -0.7 and p[4] == -1 and LT[k] > 0.15 and LT[k] < 0.85 and (p[1] % 5 == 0) and not capm:has(p[1], p[2] - 1) then c:put(p[1], p[2] - 1, HAIR, ltok) end end

-- sprout (before the seeds so the seed coat sits over its foot)
local stok = { r = { name = "stem" } }
local sp = { { 19, 48 }, { 17, 40 }, { 21, 33 }, { 21, 27 } }
local stm, stn = A.tube(sp, function() return 1.05 end)
stm:cut(sm)
X.tone(c, stm, X.light(stn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local sptok = { r = { name = "sprout" } }
local function blade(ax, ay, cx, cy, bx, by, wmax, spoon, ramp)
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    if spoon then return max(0.45, wmax * (0.18 + 0.82 * sin(pi * min(1, t ^ 1.6 * 0.95 + 0.05)) ^ 0.6)) end
    return max(0.4, wmax * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.5)
  end, { fold = 0.32 })
  m:cut(stm)
  A.shade(c, m, n, ramp, { tok = sptok, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.14 and T[k] > 0.08 and T[k] < 0.86 then c:put(x, y, S[k] <= 0 and ramp[6] or ramp[3], sptok) end end)
  return m, T, S
end
-- cotyledons: tiny linear pair low on the stem
local c1 = blade(18, 37, 14, 34, 11, 33, 1.0, false, SPR)
local c2 = blade(19, 37, 23, 35, 26, 35, 1.0, false, SPR)
-- first true leaves: spoon-shaped, bristly
local l1, T1, S1 = blade(21, 27, 15, 22, 9, 15, 3.6, true, SPR)
local l2, T2, S2 = blade(21, 27, 28, 22, 35, 14, 3.6, true, SPR)
for _, L in ipairs{ { l1, T1, S1 }, { l2, T2, S2 } } do
  for _, p in ipairs(A.border(L[1])) do local k = K(p[1], p[2])
    if L[2][k] > 0.3 and (p[1] + p[2]) % 4 == 0 then
      local hx, hy = p[1] + p[3], p[2] + p[4]
      if not c:get(hx, hy) then c:put(hx, hy, L[3][k] < 0 and HAIR or SPR[3], sptok) end
    end end
end
-- stem top node over the leaf bases
c:put(21, 27, STEM[3], stok) c:put(21, 28, STEM[2], stok)

-- capsule: ribbed straw body, bristles, crown
local ctok = { r = { name = "capsule" } }
local cb = {}
X.ao(cb, capm, crown, 1, -1)
local cidx = A.shade(c, capm, capn, CAP, { tok = ctok, bias = cb, amb = 0.06, wrap = 0.25 })
capm:each(function(x, y) local dx, dy = x - CX, y - CY
  local u, v = (dx * ca + dy * sa) / CRX, (-dx * sa + dy * ca) / CRY
  local ph = v * 2.2 + 0.25
  if abs(ph - floor(ph + 0.5)) < 0.13 and abs(u) < 0.86 then A.step(c, cidx, CAP, x, y, -2, ctok) end
end)
-- bristles on the capsule top edge
for _, p in ipairs(A.border(capm)) do if p[4] == -1 and p[1] % 3 == 1 and p[1] > 39 then c:put(p[1], p[2] - 1, CAP[2], ctok) end end
-- crown (stigma disc) with dark pores
local crtok = { r = { name = "crown" } }
local crn = X.pillow(crown, 1.4)
local cri = A.shade(c, crown, crn, CAP, { tok = crtok, cuts = { 0.25, 0.42, 0.58, 0.74, 0.9 }, amb = 0.05, wrap = 0.2 })
local cx0, cy0, cx1, cy1 = crown:bbox()
crown:each(function(x, y) if x == cx1 or not crown:has(x + 1, y) then c:put(x, y, CAP[1], crtok) end end)
for _, q in ipairs{ { 0, -2 }, { 0, 0 }, { 0, 2 } } do
  local x, y = floor(CX - (CRX + 0.6) * ca + q[1] + .5), floor(CY - (CRX + 0.6) * sa + q[2] + .5)
  if crown:has(x, y) then c:put(x, y, SD[1], crtok) end
end
-- pedicel
local ptok = { r = { name = "pedicel" } }
ped:each(function(x, y) c:put(x, y, ped:has(x, y - 1) and CAP[2] or CAP[4], ptok) end)
-- capsule spec
c:put(42, 36, CAP[6], ctok) c:put(43, 36, CAP[6], ctok)

-- seeds
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  for j, row in ipairs(s[3]) do for ii, v in ipairs(row) do if v > 0 then c:put(s[1] + ii - 1, s[2] + j - 1, SD[v], tok) end end end
end
c:put(18, 48, SD[6], { r = { name = "seed11" } })

A.save(c, NAME)
