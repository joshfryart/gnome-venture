-- dendrobium-seed (final, Opus single pass). Orchid seed is dust, so the "seed" is the ripe ribbed capsule: a
-- spindle pod (six ribs, withered flower stub at the tip, pedicel stub) lying on a torn dendrobium leaf scrap (oblong,
-- leathery, glossy, midrib channel, unequal two-lobed tip), split open along one slit and spilling golden seed dust.
-- Sprout: a tiny jointed cane (pseudobulb, pale node rings) with three oblong leathery leaves, alternate.
-- quirk: a silvery aerial root with a green tip curls off the cane base and over the leaf edge.
local NAME = "dendrobium-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#163a2c", "#1f5436", "#2c703c", "#469046", "#74b250", "#b2d878" }
local POD = { "#3c2a1a", "#5e4424", "#86662e", "#ad8c3c", "#d0b25a", "#f0d88a" }
local DUST = { "#d98322", "#f5b82e", "#ffe38a" }
local CANE = { "#4a5e2a", "#6f8a36", "#98b04a", "#c4d478", "#e6eeaa" }
local ROOT = { "#7c8a90", "#b0bcc0", "#dde6e4" }
local CUTS = A.CUTS

-- capsule: spindle along an axis
local PX, PY, PA, PL, PW = 22, 45, -0.32, 10.5, 3.6
local pca, psa = cos(PA), sin(PA)
local pod, pn, PU, PV = HP.mask(), {}, {}, {}
for y = 30, 60 do for x = 5, 40 do
  local dx, dy = x - PX, y - PY
  local u, v = (dx * pca + dy * psa) / PL, (-dx * psa + dy * pca)
  if abs(u) <= 1 then
    local w = PW * (1 - abs(u) ^ 2.2) ^ 0.7 + 0.3
    if abs(v) <= w then
      local k = K(x, y) pod:set(x, y)
      local sv = v / (w + 0.4)
      local nz = sqrt(max(0.05, 1 - sv * sv))
      local along = u * 0.5
      local nx, ny = -psa * sv + pca * along, pca * sv + psa * along
      local l = sqrt(nx * nx + ny * ny + nz * nz)
      pn[k] = { nx / l, ny / l, nz / l } PU[k], PV[k] = u, sv
    end
  end
end end
-- pedicel stub (left, lower end) and withered flower remnant (right tip)
local ped = HP.line({ { PX - 11 * pca, PY - 11 * psa }, { PX - 14 * pca + 0.5, PY - 14 * psa + 1.5 } }, 2)
local tipx, tipy = PX + 11 * pca, PY + 11 * psa
local wither = HP.poly({ { tipx - 1, tipy - 1 }, { tipx + 2, tipy - 3 }, { tipx + 3, tipy - 1.5 }, { tipx + 0.5, tipy + 1 } })
wither:cut(pod) ped:cut(pod)

-- sprout: cane with nodes + 3 leaves, root
local caneP = { { 43, 47 }, { 43, 42 }, { 44, 36 }, { 44, 30 } }
local cm, cn, CT, CS = A.tube(caneP, function(t) return 1.9 - 0.6 * t end)
local function leaf(ax, ay, cx, cy, bx, by, w)
  return A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 0.8 + 0.1)) ^ 0.35)
  end, { fold = 0.3 })
end
local L1, L1n, L1T, L1S = leaf(43, 40, 37, 36, 31, 28, 2.4)
local L2, L2n, L2T, L2S = leaf(45, 35, 51, 31, 54, 23, 2.4)
local L3, L3n, L3T, L3S = leaf(44, 30, 42, 22, 38, 16, 2.2)
L1:cut(cm) L2:cut(cm) L3:cut(cm)
local rootP = { { 44, 47 }, { 49, 49 }, { 53, 53 }, { 51, 57 } }
local rm, rn, RT = A.tube(rootP, function(t) return 1.05 end)
rm:cut(cm)

-- scrap: oblong dendrobium leaf, torn base at left, two-lobed tip at right
local lm, ln, LT, LS = A.scrap(7, 50, 31, 58, 57, 46, { w = 5.6, tornA = 0.04, seed = 9, fold = 0.5,
  shape = function(t) return min(1, (1 - t) * 7) ^ 0.6 * (0.8 + 0.2 * sin(pi * t)) end })
-- unequal bilobed notch at the tip
lm:each(function(x, y) local k = K(x, y) if LT[k] > 0.93 and LS[k] > -0.25 and LS[k] < 0.05 then lm.s[k] = nil end end)
local bias = {}
X.ao(bias, lm, pod, 1, -1) A.cast(bias, lm, pod, 1, 2, -1) A.cast(bias, lm, cm, 1, 1, -1) X.ao(bias, lm, rm, 1, -1)
A.cast(bias, lm, rm, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 and t < 0.92 then c:put(x, y, LEAF[2], ltok)                     -- midrib channel
  elseif s < -0.1 and s > -0.22 and t < 0.9 then c:put(x, y, LEAF[5], ltok) end    -- lit lip of the channel
end)
-- glossy leathery streak
lm:each(function(x, y) local k = K(x, y) if not bias[k] and LS[k] < -0.5 and LS[k] > -0.7 and LT[k] > 0.25 and LT[k] < 0.55 then
  c:put(x, y, LEAF[6], ltok) end end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.1 and LT[k] < 0.9 then c:put(x, y, "#3a6a6e", ltok) end end)

-- spilled seed dust on the leaf (golden specks trailing from the slit toward lower right)
local dtok = { r = { name = "dust" } }
for i, q in ipairs{ { 26, 47 }, { 28, 48 }, { 27, 50 }, { 30, 49 }, { 29, 51 }, { 32, 50 }, { 31, 52 }, { 34, 51 }, { 33, 53 },
  { 36, 52 }, { 24, 49 }, { 35, 49 }, { 38, 51 } } do
  if lm:has(q[1], q[2]) and not pod:has(q[1], q[2]) then
    c:put(q[1], q[2], DUST[(i % 3) + 1], dtok) end end

-- root (silvery velamen, green tip, ringed)
local rtok = { r = { name = "root" } }
local ridx = X.tone(c, rm, X.light(rn, { amb = 0.15, wrap = 0.3 }), ROOT, { cuts = { 0.35, 0.65 }, tok = rtok })
rm:each(function(x, y) local k = K(x, y) if RT[k] > 0.86 then c:put(x, y, (ridx[k] or 2) > 1 and LEAF[5] or LEAF[3], rtok) end end)

-- leaves
local ftok = { r = { name = "frond" } }
local function tl(m, n, T, S, extra)
  local b = extra or {}
  A.toneN(c, m, n, LEAF, { bias = b, tok = ftok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.13 and T[k] > 0.08 and T[k] < 0.8 then
    c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ftok) end end)
end
local b1 = {} X.ao(b1, L1, cm, 1, -1)
local b2 = {} X.ao(b2, L2, cm, 1, -1)
local b3 = {} X.ao(b3, L3, cm, 1, -1)
tl(L1, L1n, L1T, L1S, b1) tl(L2, L2n, L2T, L2S, b2) tl(L3, L3n, L3T, L3S, b3)

-- cane: cylinder with pale node rings and dark sheath line under each node
local ctok = { r = { name = "cane" } }
local cidx = X.tone(c, cm, X.light(cn, { amb = 0.12, wrap = 0.3 }), CANE, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = ctok })
cm:each(function(x, y) local k = K(x, y) local t = CT[k]
  for _, nt in ipairs{ 0.3, 0.62 } do
    if abs(t - nt) < 0.025 then c:put(x, y, CANE[5], ctok) elseif t - nt > 0.025 and t - nt < 0.06 then c:put(x, y, CANE[max(1, cidx[k] - 2)], ctok) end
  end
end)

-- capsule: ribs, split slit with dust inside
local ptok = { r = { name = "pod" } }
local pbias = {}
X.ao(pbias, pod, cm, 1, 0)
local pidx = A.toneN(c, pod, pn, POD, { tok = ptok, cuts = CUTS, amb = 0.1, wrap = 0.3 })
pod:each(function(x, y) local k = K(x, y) local u, v = PU[k], PV[k]
  local r = (v + 1) * 3
  local f = r - floor(r)
  if f < 0.22 and abs(u) < 0.85 then c:put(x, y, POD[max(1, pidx[k] - 2)], ptok) end      -- rib grooves
  -- dehiscence slit on the upper side: dark gap, golden dust showing
  if v < -0.12 and v > -0.42 and u > -0.45 and u < 0.35 then
    if v > -0.3 or X.hash(x, y, 4) > 0.45 then c:put(x, y, POD[1], ptok) else c:put(x, y, DUST[3], ptok) end
  end
end)
-- lit ridge glint
c:put(16, 45, POD[6], ptok) c:put(17, 45, POD[6], ptok)
-- pedicel + wither
local wtok = { r = { name = "wither" } }
ped:each(function(x, y) c:put(x, y, (x + y) % 2 == 0 and POD[3] or POD[2], wtok) end)
wither:each(function(x, y) c:put(x, y, (y < tipy - 1) and "#8a5a3a" or "#5e3a2a", wtok) end)

A.save(c, NAME)
