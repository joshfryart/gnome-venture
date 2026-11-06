-- nutmeg (C3, Opus single pass): a slim apricot-yellow nutmeg fruit split down its seam, the two halves parted to show
-- the glossy dark-brown nut wrapped in a scarlet lace of mace. Cream pericarp cut-faces line the split (lit on the right
-- lip, shaded on the left), ambient dark where flesh meets nut, contact shadow under each mace strap, lenticel
-- freckles and waxy bloom on the skin, short woody stalk with grain and one glossy leaf with veins.
-- quirk: one mace strap has slipped out of the split and curls over the lower lip.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_3.lua")
local HP, X, K, B = A.HP, A.X, A.K, A.B
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("nutmeg")
local HU = { "#7a4420", "#a8681e", "#d0942a", "#ecbc44", "#f8d870", "#fff0a8" }
local NU = { "#1e100e", "#341a14", "#4a2819", "#653620", "#844c2c", "#a8703f" }
local MA = { "#5a1424", "#8e1e2a", "#c42e2e", "#e8483a", "#ff7a5a", "#ffb08a" }
local PE = { "#b88a50", "#d8b47a", "#f0d8a0", "#fff0c8" }
local LEAF = { "#123430", "#1b4a3c", "#256346", "#347f4c", "#55a052", "#8cc866" }
local WOOD = { "#3a2420", "#51302b", "#864c33", "#b97a4a", "#d79e66", "#e8c08c" }

local cx, cy = 32, 37
-- fruit: slim egg, slightly pointed at the bottom
local fm = HP.mask()
for y = 15, 58 do for x = 14, 50 do
  local v = (y - cy) / 17.5
  local rx = 12.6 * (1 - 0.12 * v) * sqrt(max(0, 1 - v * v)) ^ (v > 0 and 0.85 or 0.95)
  if abs(x - cx) <= rx and abs(v) <= 1 then fm:set(x, y) end
end end
-- split opening: lens, widest at the middle
local y0, y1 = 22, 52
local op, lipL, lipR = HP.mask(), HP.mask(), HP.mask()
for y = y0, y1 do
  local u = (y - y0) / (y1 - y0)
  local hw = 7.2 * sin(pi * u) ^ 0.8
  for x = floor(cx - hw - 2), floor(cx + hw + 2) do
    local d = x + 0.5 - cx
    if abs(d) <= hw then op:set(x, y)
    elseif d < 0 and d >= -hw - 1.6 and hw > 1.2 then lipL:set(x, y)
    elseif d > 0 and d <= hw + 1.6 and hw > 1.2 then lipR:set(x, y) end
  end
end
op:clip(fm) lipL:clip(fm) lipR:clip(fm)
local skin = fm:copy():cut(op):cut(lipL):cut(lipR)
-- light the whole fruit as a sphere-ish egg
local fbias = {}
local stalkBase = A.ell(31, 15.5, 3, 1.8, 0)
X.ao(fbias, skin, stalkBase, 1, -1)
local ftok = A.tok("fruit")
local fidx, fnorm = A.sph(c, cx - 1, cy, 13, 18, skin, HU, { tok = ftok, bias = fbias, amb = 0.12, wrap = 0.3 })
-- lenticel freckles + waxy bloom streak
skin:shrink(2):each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 7)
  if h < 0.045 then c:put(x, y, HU[max(1, fidx[k] - 2)], ftok) end end)
for _, q in ipairs{ { 21, 27 }, { 21, 28 }, { 22, 26 }, { 21, 29 } } do if skin:has(q[1], q[2]) then c:put(q[1], q[2], HU[6], ftok) end end
c:put(22, 25, A.CREAM, ftok)
-- cool reflected light on the lower-right rim
skin:edge():each(function(x, y) local q = fnorm[K(x, y)]
  if q and q[1] * 0.6 + q[2] * 0.7 > 0.62 then c:put(x, y, "#c0866a", ftok) end end)
-- seam groove continuing above/below the split
for y = 16, 21 do c:put(cx - (y < 19 and 1 or 0), y, HU[2], ftok) end
for y = 53, 54 do if skin:has(cx, y) then c:put(cx, y, HU[2], ftok) end end
-- pericarp cut faces: left lip faces right (shaded), right lip faces the light (bright)
lipL:each(function(x, y) c:put(x, y, op:has(x + 1, y) and PE[1] or PE[2], ftok) end)
lipR:each(function(x, y) c:put(x, y, op:has(x - 1, y) and PE[4] or PE[3], ftok) end)

-- nut inside the opening, deep cavity at the ends
local ntok = A.tok("nut")
local nbias = {}
X.ao(nbias, op, lipL:copy():add(lipR), 1, -1)
op:each(function(x, y) if y < 26 or y > 48 then nbias[K(x, y)] = (nbias[K(x, y)] or 0) - 2 end end)
local nidx = A.sph(c, cx - 0.5, cy, 8, 12, op, NU, { tok = ntok, bias = nbias, amb = 0.06, wrap = 0.2 })
-- nut grain: faint furrows
op:each(function(x, y) local k = K(x, y)
  if (x + floor(y * 0.5)) % 4 == 0 and (nidx[k] or 1) >= 3 and X.hash(x, y, 3) < 0.5 then c:put(x, y, NU[nidx[k] - 1], ntok) end end)

-- mace: branching flat straps over the nut, lit by the nut normal, contact shadow below-right
local mace = HP.mask()
local function strap(pts, w)
  local m = A.tube(pts, function(t) return w end, { N = 50 })
  mace:add(m)
end
strap({ { 31, 23 }, { 27, 30 }, { 28, 38 }, { 29, 47 } }, 0.4)
strap({ { 33, 23 }, { 36, 29 }, { 37, 36 }, { 34, 46 } }, 0.4)
strap({ { 32, 24 }, { 32, 30 }, { 31, 34 }, { 32, 40 } }, 0.45)
strap({ { 28, 33 }, { 30, 34 }, { 33, 33 }, { 36, 31 } }, 0.4)
strap({ { 29, 42 }, { 31, 41 }, { 33, 42 }, { 35, 41 } }, 0.4)
strap({ { 26, 37 }, { 26, 40 }, { 27, 44 }, { 30, 49 } }, 0.4)
mace:clip(op)
mace:shift(1, 1):each(function(x, y) if op:has(x, y) and not mace:has(x, y) then c:put(x, y, NU[1], ntok) end end)
local mtok = A.tok("mace")
mace:each(function(x, y) local k = K(x, y) c:put(x, y, MA[max(2, min(6, (nidx[k] or 3) + 1))], mtok) end)
-- glossy spec on the nut
c:put(29, 28, A.CREAM, ntok) c:put(30, 28, NU[6], ntok)

-- quirk: a mace strap slips out over the lower right lip and curls
local qm, qn = A.tube({ { 34, 46 }, { 37, 50 }, { 40, 51 }, { 41, 47 } }, function(t) return 0.8 end, { N = 50 })
qm:cut(op)
qm:each(function(x, y) if skin:has(x + 1, y + 1) and not qm:has(x + 1, y + 1) then c:put(x + 1, y + 1, HU[1], ftok) end end)
A.toneN(c, qm, qn, MA, { tok = mtok, amb = 0.2 })

-- stalk with grain + end
local sm, sn, ST, SS = A.tube({ { 31, 17 }, { 31, 14 }, { 30, 12 }, { 28, 9 } }, function(t) return 1.3 - 0.3 * t end, { N = 40 })
sm:cut(skin)
local stok = A.tok("stalk")
A.toneN(c, sm, sn, WOOD, { tok = stok, amb = 0.12 })
sm:each(function(x, y) if SS[K(x, y)] and abs(SS[K(x, y)]) < 0.2 and ST[K(x, y)] < 0.8 and y % 2 == 0 then c:put(x, y, WOOD[2], stok) end end)
c:put(28, 9, WOOD[6], stok)
-- leaf from the stalk, out to the right
local lm, ln, LT, LS = A.tube({ { 31, 14 }, { 36, 10 }, { 44, 10 }, { 51, 13 } }, function(t)
  if t > 0.97 then return -1 end return max(0.5, 3.6 * sin(pi * min(1, t * 1.0 + 0.04)) ^ 0.75) end, { flat = 0.55, N = 70 })
lm:cut(sm)
local ltok = A.tok("leaf")
local lidx = A.toneN(c, lm, ln, LEAF, { tok = ltok, amb = 0.14, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if abs(s) < 0.2 and t > 0.06 and t < 0.9 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) end
  local ph = (t * 21 - abs(s) * 2.6) / 4.2
  if abs(ph - floor(ph + .5)) < 0.12 and abs(s) > 0.3 and abs(s) < 0.8 and t > 0.12 and t < 0.85 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)
c:put(39, 9, A.CREAM, ltok)
-- leaf shadow on the fruit shoulder
for _, q in ipairs{ { 33, 16 }, { 34, 16 }, { 35, 17 } } do if skin:has(q[1], q[2]) then c:put(q[1], q[2], HU[2], ftok) end end
A.shift(c, -3, 1)
A.fin()
