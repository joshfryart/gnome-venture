-- grape (final pass, Opus aB35_4). A slim tapering bunch of oval purple grapes hanging from a woody, twisted stem,
-- a 5-lobed serrated vine leaf behind at the upper right and a coiled green tendril on the left.
-- Material: per-pixel spheres (6-tone violet), dusty waxy bloom speckle, one glint per berry, cool reflected rim
-- lower-right, dark separation + AO where berries overlap, darker half-hidden berries behind. Stem: wood ramp with
-- twist marks and a knot. Leaf: palmate veins, AO under the berries.
-- quirk: one grape has dropped off and sits beside the bunch, still wearing its tiny stalk.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("grape")
local BER  = { "#22143a", "#3a2262", "#573a8e", "#7656b6", "#9a7ed8", "#c6b2f4" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local WOOD = { "#3a2420", "#56352a", "#7a5034", "#9c6c40", "#c08c55", "#e0b77a" }
local BLOOM_HI, BLOOM_LO, COOL, GLINT = "#b9addf", "#7b6cb2", "#5568b4", "#fff4d6"

-- leaf (behind everything)
local lm, ln, inf = A.vine(37, 15, -0.35, 12.5)
local lbias = {}
local cluster = c:ellipse(31, 38, 11, 16)
X.ao(lbias, lm, cluster, 1, -1) A.cast(lbias, lm, cluster, 1, 2, -1)
A.leafPaint(c, lm, ln, inf, LEAF, { bias = lbias, tok = A.tok("leaf") })
-- leaf petiole to the stem
for i, p in ipairs{ { 35, 14 }, { 34, 14 }, { 36, 15 } } do c:put(p[1], p[2], i == 1 and LEAF[4] or LEAF[3]) end

-- tendril: corkscrew coil off to the left (2-tone for the twist)
do
  local pts = {}
  for i = 0, 70 do
    local t = i / 70
    local a = t * 3.2 * pi
    local r = 4.2 - t * 2.6
    pts[#pts + 1] = { 25 - t * 3 + cos(a + pi) * r * 0.9 + 4.2, 14 + sin(a + pi) * r * 0.8 - t * 2 }
  end
  table.insert(pts, 1, { 31, 13 })
  local tm = A.path(pts)
  local tt = A.tok("tendril")
  local i = 0
  tm:each(function(x, y) c:put(x, y, ((x + y) % 3 == 0) and LEAF[3] or LEAF[5], tt) end)
end

-- rachis: twisted woody stem from the top down into the bunch, with pedicels to the top berries
local stok = A.tok("stem")
local sm, sn = A.tube({ { 34, 7 }, { 32.5, 11 }, { 33.5, 16 }, { 32.2, 22 } }, function(t) return 1.35 - t * 0.35 end)
local sidx = A.shade(c, sm, sn, WOOD, { tok = stok, amb = 0.12, wrap = 0.3 })
sm:each(function(x, y) if (y * 2 + x) % 4 == 0 and (sidx[K(x, y)] or 1) >= 3 then c:put(x, y, WOOD[2], stok) end end)
c:put(34, 6, WOOD[1], stok) c:put(35, 6, WOOD[2], stok) c:put(33, 6, WOOD[3], stok) -- cut end
c:put(33, 7, WOOD[6], stok)
c:put(34, 12, WOOD[5], stok) c:put(35, 12, WOOD[2], stok) -- knot
for _, p in ipairs{ { { 32, 21 }, { 28, 22 }, { 26, 23 } }, { { 33, 21 }, { 37, 22 }, { 39, 23 } }, { { 32, 22 }, { 32, 24 } } } do
  A.path(p):each(function(x, y) c:put(x, y, WOOD[3], stok) end)
end

-- berries
local bidx, bown = {}, {}
local nB = 0
local function berry(cx, cy, rx, ry, back, glint)
  nB = nB + 1
  local tok = A.tok("berry" .. nB)
  local m, n = A.oval(cx, cy, rx, ry, 0.12, 1)
  -- separation line + AO on berries already drawn
  local r1 = m:grow(1) r1:cut(m)
  local r2 = m:grow(2) r2:cut(m:grow(1))
  r2:each(function(x, y) local k = K(x, y) if bidx[k] and bidx[k] > 2 and (x >= cx - 1 or y >= cy) then
    bidx[k] = bidx[k] - 1 c:put(x, y, BER[bidx[k]], bown[k]) end end)
  r1:each(function(x, y) local k = K(x, y) if bidx[k] then bidx[k] = 1 c:put(x, y, BER[1], bown[k]) end end)
  local b = {}
  if back then m:each(function(x, y) b[K(x, y)] = -1 end) end
  local idx = A.shade(c, m, n, BER, { tok = tok, bias = b, amb = 0.05, wrap = 0.2 })
  -- waxy bloom speckle
  m:each(function(x, y) local k = K(x, y) local i = idx[k]
    if X.hash(x, y, 7) < 0.2 and i >= 3 and i <= 5 then c:put(x, y, i >= 4 and BLOOM_HI or BLOOM_LO, tok) idx[k] = i end end)
  -- cool reflected light on the lower-right edge
  local rim = X.rim(n)
  m:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.62 and idx[k] <= 3 and not back then c:put(x, y, COOL, tok) end end)
  -- glint
  local gx, gy = A.specAt(m, n, 40)
  if gx then c:put(gx, gy, back and BER[5] or GLINT, tok) if glint then c:put(gx + 1, gy, BER[6], tok) end end
  m:each(function(x, y) local k = K(x, y) bidx[k] = idx[k] bown[k] = tok end)
  return m
end
local RX, RY = 3.3, 3.9
for _, p in ipairs{ { 35.6, 27 }, { 29, 27 }, { 32.2, 32.5 }, { 25.8, 38 }, { 38.5, 38 }, { 29.6, 43.5 }, { 35.4, 43.5 }, { 31.5, 49 } } do
  berry(p[1], p[2], RX - 0.3, RY - 0.3, true)
end
local rows = {
  { 25, 26.2, 32.6, 39 },
  { 30.5, 23, 29.4, 35.8, 41.6 },
  { 36, 26.2, 32.6, 38.8 },
  { 41.5, 23.6, 30, 36.4 },
  { 47, 27, 33.4 },
  { 52.5, 30.2 },
}
for ri, r in ipairs(rows) do
  for j = 2, #r do berry(r[j] + ((ri + j) % 2) * 0.3, r[1] + ((j % 2 == 0) and 0 or 0.4), RX, RY, false, ri == 2 and j == 3) end
end

-- quirk: a fallen grape beside the bunch, still on its little stalk
local fm = berry(45, 52.5, 3.1, 3.4, false)

for _, p in ipairs{ { 46, 48 }, { 47, 47 } } do c:put(p[1], p[2], WOOD[3], A.tok("stub")) end
c:put(48, 46, WOOD[5], A.tok("stub"))
A.save(c, "grape")
