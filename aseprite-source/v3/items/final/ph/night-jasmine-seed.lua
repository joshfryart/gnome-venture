-- night-jasmine-seed (final, Opus single pass). Night jasmine (Nyctanthes): one flat, round-hearted papery seed
-- capsule split along its seam (pale papery rim, darker swollen seed lobes, fine radial veining) and one loose round
-- seed beside it, on a torn rough night-jasmine leaf scrap (ovate, pointed, sandpapery specks, midrib + arching veins,
-- ragged torn base with pale fibres, AO + contact shadows). The capsule has germinated: a slim green stem rising
-- with two opposite pairs of ovate, pointed leaves.
-- quirk: a single fallen night-jasmine flower (white star, orange tube) lies on the leaf.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "night-jasmine-seed"
local c = A.new(NAME)
local LEAF = { "#18363a", "#22503f", "#306c45", "#4a8a4a", "#6fa854", "#9cc56c" }
local SPR  = { "#1d4a3a", "#2e6a44", "#47904e", "#6fb45a", "#a2d474", "#d0eca0" }
local CAP  = { "#3a2626", "#5c3a2e", "#86583a", "#ad7c4c", "#d0a66a", "#ecd29a" }
local STEM = { "#3b6449", "#5b8d5a", "#88b46e", "#b9d793" }
local COOL, FIBRE, SPEC = "#4a6a80", "#d6e4a6", "#fff4d6"

-- leaf scrap: from the torn base at lower right, tip toward upper left
local ltok = { r = { name = "leaf" } }
local lm, ln, LT, LS, len = A.blade(53, 57, 34, 58, 9, 40, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 9.4 * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.62 * (1 - 0.25 * t))
end, { fold = 0.42 })
local torn = {}
lm:each(function(x, y)
  local d = (49 - x) + (y - 50) * 0.35 + (X.hash(x, y, 31) - 0.5) * 2.4 + 1.1 * sin(y * 1.9)
  if d < 0 then torn[#torn + 1] = K(x, y) end
end)
for _, k in ipairs(torn) do lm.s[k] = nil end

-- capsule: flat round heart, split seam
local CXc, CYc = 33, 48
local cap = HP.mask()
for y = CYc - 7, CYc + 6 do for x = CXc - 8, CXc + 8 do
  local dx, dy = (x - CXc) / 7.4, (y - CYc) / 6.0
  local r = sqrt(dx * dx + dy * dy)
  local notch = (dy < -0.6 and abs(dx) < 0.18)
  if r <= 1 and not notch and not (dy > 0.75 and abs(dx) > 0.35) then cap:set(x, y) end
end end
local loose, lnn = A.oval(20, 50, 2.6, 2.3, 0.3, 0.7)

local bias = {}
X.ao(bias, lm, cap, 1, -1) A.cast(bias, lm, cap, 1, 2, -1)
X.ao(bias, lm, loose, 1, -1) A.cast(bias, lm, loose, 1, 1, -1)
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.1 and t < 0.93 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[2], ltok) return end
  -- arching veins
  local d = (t * len - abs(s) ^ 0.7 * 9) % 7
  if d < 0.85 and abs(s) > 0.15 and abs(s) < 0.82 and t > 0.12 and t < 0.86 then c:put(x, y, s < 0 and LEAF[min(6, lidx[k] + 1)] or LEAF[max(1, lidx[k] - 1)], ltok) return end
  -- sandpapery specks
  if X.hash(x, y, 17) > 0.9 and lidx[k] >= 3 then c:put(x, y, LEAF[lidx[k] + ((s < 0) and 1 or -1)] or LEAF[3], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.12 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)
for _, k in ipairs(torn) do local x, y = k % 1024 - 256, k // 1024 - 256
  for _, d in ipairs{ { -1, 0 }, { 0, -1 } } do
    if lm:has(x + d[1], y + d[2]) and X.hash(x, y, 6) > 0.35 then c:put(x + d[1], y + d[2], FIBRE, ltok) end end
end

-- sprout: slim stem from the capsule notch up, two opposite pairs of ovate pointed leaves
local stok = { r = { name = "stem" } }
local sp = { { 33, 42 }, { 34, 34 }, { 31, 26 }, { 33, 17 } }
local sm = A.stem(c, sp, function(t) return 1.1 - 0.2 * t end, STEM, { tok = stok, cut = cap })
local spm = HP.mask()
local function pleaf(ax, ay, bx, by, w)
  local mx, my = (ax + bx) / 2, (ay + by) / 2
  local m = A.leaf(c, ax, ay, mx + (by - ay) * 0.12, my - (bx - ax) * 0.12 , bx, by, w, SPR, { pw = 0.7, fold = 0.5, cut = sm })
  spm:add(m)
  return m
end
pleaf(33, 32, 23, 27, 2.8)
pleaf(34, 31, 44, 29, 2.8)
pleaf(32, 19, 25, 13, 2.3)
pleaf(33, 19, 41, 14, 2.3)
c:put(33, 17, STEM[4], stok) c:put(33, 16, SPR[5], stok)

-- capsule tone: papery rim + swollen lobes, seam down the middle
local ctok = { r = { name = "capsule" } }
local cn = X.pillow(cap, 3)
local lobeN = {}
for k, nn in pairs(cn) do local x, y = k % 1024 - 256, k // 1024 - 256
  local side = x < CXc and -1 or 1
  local lx, ly = CXc + side * 3.4, CYc + 0.5
  local dx, dy = (x - lx) / 3.6, (y - ly) / 4.4
  local q = dx * dx + dy * dy
  if q < 1 then lobeN[k] = true cn[k] = { A.norm(nn[1] + dx * 0.9, nn[2] + dy * 0.9, nn[3]) } end
end
local cb = {}
X.ao(cb, cap, sm, 1, -1)
local cidx = A.shade(c, cap, cn, CAP, { amb = 0.08, wrap = 0.25, bias = cb, tok = ctok })
cap:each(function(x, y) local k = K(x, y)
  if x == CXc then c:put(x, y, CAP[1], ctok)
  elseif x == CXc + 1 then c:put(x, y, CAP[max(1, cidx[k] - 1)], ctok)
  elseif not lobeN[k] then
    c:put(x, y, CAP[min(6, cidx[k] + 1)], ctok)                          -- papery rim, paler
    local a = math.atan(y - CYc, x - CXc)
    if (a * 9) % 2 < 0.45 then c:put(x, y, CAP[max(2, cidx[k] - 1)], ctok) end   -- radial veins
  end
end)
local gx, gy = A.specAt(cap, cn, 40) c:put(gx, gy, SPEC, ctok)

-- loose seed
local otok = { r = { name = "seed" } }
A.toneN(c, loose, lnn, CAP, { tok = otok, cuts = A.CUTS, amb = 0.08, wrap = 0.25 })
c:put(19, 49, CAP[6], otok)

-- quirk: fallen flower, white star with orange tube
local ftk = { r = { name = "flower" } }
local W, WS, OR, ORD = "#f6f2ea", "#cfc6da", "#f08a24", "#b8501e"
local FX, FY = 16, 41
for _, q in ipairs{ { -1, -1 }, { -2, -2 }, { 1, -1 }, { 2, -2 }, { -1, 1 }, { -2, 1 }, { 1, 1 }, { 2, 2 }, { 0, -1 }, { -1, 0 }, { 1, 0 } } do
  c:put(FX + q[1], FY + q[2], (q[2] > 0 and q[1] > 0) and WS or W, ftk) end
c:put(FX, FY, "#f8c048", ftk)
for i, q in ipairs{ { 1, 1 }, { 2, 3 }, { 3, 4 }, { 4, 4 } } do
  if not (q[1] == 1 and q[2] == 1) then c:put(FX + q[1], FY + q[2] - 1, i % 2 == 0 and OR or ORD, ftk) end end
c:put(FX + 3, FY + 2, OR, ftk)

A.save(c, NAME)
