-- mamey-seed (final, Opus single pass). One big glossy mamey-sapote seed (slim spindle, chestnut lacquer, a broad pale
-- matte hilum scar down its lower flank) lying on a torn scrap of mamey leaf (obovate, leathery, dense parallel
-- side veins, ragged torn edge, cool reflected rim, AO + contact shadow under the seed). From the seed's upper end
-- a sprout climbs: bronze-green stem and two obovate young leaves with the same dense parallel venation.
-- quirk: a single dewdrop bead sitting on the leaf scrap, catching the light.
local NAME = "mamey-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new(NAME)

local LEAF = { "#15392f", "#1f5440", "#2c7046", "#43904d", "#68b157", "#9cce6e" }
local LVEIN, COOL = "#bfe08a", "#3b6a74"
local YOUNG = { "#3a2a2a", "#5c3b2c", "#7f5a32", "#a27c3c", "#c7a352", "#e6cd7c" } -- bronze young flush
local SEED = { "#211217", "#3f1f1d", "#663523", "#91512b", "#bc763d", "#e9b47c" }
local HIL = { "#9c7d58", "#c2a276", "#e3cc9e" }
local STEM = { "#4c5a32", "#7c8a44", "#adb862", "#d8de94" }
local DROP = { "#3a86b0", "#8fd6dc", "#d8fbf2" }

-- seed
local SX, SY, SRX, SRY, SANG = 30, 41, 10.5, 5.2, -0.32
local sm, sn = A.oval(SX, SY, SRX, SRY, SANG, 1)
local ca, sa = cos(SANG), sin(SANG)
-- pointed ends (spindle)
local tip = {}
sm:each(function(x, y) local dx, dy = x - SX, y - SY
  local u = (dx * ca + dy * sa) / SRX local v = (-dx * sa + dy * ca) / SRY
  if abs(u) > 0.6 and abs(v) > 1 - (abs(u) - 0.6) * 1.4 then tip[#tip + 1] = K(x, y) end end)
for _, k in ipairs(tip) do sm.s[k] = nil end

-- leaf scrap: obovate mamey leaf piece on a shallow diagonal, torn off at the tip end (ragged)
local lm, ln, LT, LS, len = A.blade(6, 52, 30, 44, 58, 45, function(t)
  if t > 0.86 then return -1 end
  return max(0.6, 11.5 * sin(pi * min(1, 0.12 + t * 0.62)) ^ 0.8)
end, { fold = 0.32 })
-- tear: jagged bite out of the end and a nick in the lower edge
local cut = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  local j = ((x * 7 + y * 3) % 5) / 5
  if t > 0.74 + 0.05 * j + 0.06 * abs(s) then cut[#cut + 1] = k end
  if s > 0.7 and t > 0.32 and t < 0.4 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
X.ao(bias, lm, sm, 1, -1)
A.cast(bias, lm, sm, 1, 2, -1)
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.28, 0.44, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.02 then c:put(x, y, s <= 0 and LVEIN or LEAF[3], ltok) return end
  -- dense, parallel side veins swept toward the tip
  local d = (t * len - abs(s) * 7) % 2.6
  if d < 0.85 and abs(s) > 0.14 and abs(s) < 0.88 then c:put(x, y, s < 0 and LEAF[min(6, (lidx[k] or 4) + 1)] or LEAF[max(1, (lidx[k] or 3) - 1)], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] < 0.7 then c:put(x, y, COOL, ltok) end
  if LT[k] > 0.7 and LS[k] < 0.5 then c:put(x, y, LEAF[2], ltok) end -- torn edge: dark fibrous break
end)
-- petiole stub
for _, q in ipairs{ { 5, 53, 4 }, { 4, 54, 3 }, { 3, 55, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout from the seed's upper (right) end
local ex, ey = SX + ca * (SRX - 1.5), SY + sa * (SRX - 1.5)
local stok = { r = { name = "stem" } }
local sp = { { ex, ey }, { ex + 2, ey - 6 }, { ex - 2, ey - 12 }, { ex - 1, ey - 20 } }
local stm, stn = A.tube(sp, function(t) return 1.1 - 0.25 * t end)
stm:cut(sm)
A.shade(c, stm, stn, STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok, amb = 0.15, wrap = 0.3 })
local topx, topy = A.bez(sp, 1)
local ytok = { r = { name = "young" } }
local function young(bx, by, cx, cy, tx, ty, w)
  local m, n, T, S, L = A.blade(bx, by, cx, cy, tx, ty, function(t)
    if t > 0.97 then return -1 end
    return max(0.4, w * sin(pi * min(1, t ^ 0.75 * 0.9 + 0.05)) ^ 0.7)   -- obovate: widest past the middle
  end, { fold = 0.4 })
  m:cut(stm)
  local idx = A.toneN(c, m, n, YOUNG, { tok = ytok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.15 and t > 0.08 and t < 0.9 then c:put(x, y, s <= 0 and YOUNG[6] or YOUNG[3], ytok)
    elseif abs(s) > 0.25 and abs(s) < 0.8 and t > 0.15 and t < 0.85 and (t * L - abs(s) * w * 0.9) % 2.4 < 0.8 then
      c:put(x, y, s < 0 and YOUNG[min(6, (idx[k] or 4) + 1)] or YOUNG[max(1, (idx[k] or 3) - 1)], ytok) end
  end)
  return m
end
local yl = young(topx, topy + 1, topx - 7, topy - 2, topx - 14, topy + 3, 3.6)
local yr = young(topx, topy, topx + 5, topy - 7, topx + 13, topy - 8, 3.4)
-- bud between them
c:put(floor(topx + 0.5), floor(topy - 1.5), YOUNG[5], ytok)

-- seed last
local ab = {}
X.ao(ab, sm, stm, 1, -1)
local tok = { r = { name = "seed" } }
local idx = A.shade(c, sm, sn, SEED, { amb = 0.05, wrap = 0.15, tok = tok, bias = ab, cuts = { 0.12, 0.28, 0.46, 0.66, 0.86 } })
-- broad matte hilum scar on the lower flank, with fibrous edge
sm:each(function(x, y) local dx, dy = x - SX, y - SY
  local u = (dx * ca + dy * sa) / (SRX + 0.45) local v = (-dx * sa + dy * ca) / (SRY + 0.45)
  if v > 0.36 and v < 0.84 and abs(u) < 0.8 then
    local i = (u < -0.25) and 3 or ((u < 0.3) and 2 or 1)
    if v > 0.7 then i = max(1, i - 1) end
    if X.hash(x, y, 5) < 0.18 then i = max(1, i - 1) end
    c:put(x, y, HIL[i], tok)
  elseif v > 0.25 and v <= 0.36 and abs(u) < 0.75 then c:put(x, y, SEED[2], tok) end
end)
-- lacquer glint: long streak + cream point
local gx, gy = A.specAt(sm, sn, 25)
c:put(gx, gy, A.CREAM, tok) c:put(gx + 1, gy, SEED[6], tok) c:put(gx + 2, gy, SEED[6], tok) c:put(gx - 1, gy + 1, SEED[5], tok)

-- quirk: dewdrop on the scrap
local dx, dy = 15, 46
local dtok = { r = { name = "dew" } }
c:put(dx, dy, DROP[2], dtok) c:put(dx + 1, dy, DROP[2], dtok) c:put(dx, dy + 1, DROP[2], dtok) c:put(dx + 1, dy + 1, DROP[1], dtok)
c:put(dx, dy - 1, DROP[3], dtok) c:put(dx - 1, dy, DROP[3], dtok) c:put(dx + 2, dy + 1, LEAF[1], ltok) c:put(dx + 1, dy + 2, LEAF[1], ltok)

A.save(c, NAME)
