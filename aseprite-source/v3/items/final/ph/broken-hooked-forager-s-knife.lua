-- broken-hooked-forager-s-knife (aB11_5, Opus single pass). Lying knife: cherrywood handle lower-left with a
-- lanyard hole and two brass pins, brass bolster, then a slim steel blade sweeping right and up into a hawkbill hook
-- (edge on the inside of the curve). Material: per-pixel lit 6-tone steel with a bright ground edge bevel, a darker
-- spine with a swedge line, specular streak; cherry grain; brass ring with AO on both sides.
-- broken: the hook tip has snapped off and flies away, a nick is chipped from the edge, a hairline crack at the break.
-- quirk: a green pea tendril has curled itself around the bolster.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_5.lua")
local HP, X, c = A.new("broken-hooked-forager-s-knife")
local K = A.K
local W, S, Br = A.CHERRY, A.STEEL, A.BRASS
local floor, max, min, abs = math.floor, math.max, math.min, math.abs

-- blade (hawkbill), drawn first so the bolster sits over its root
local bp = { {29,41}, {45,42}, {57,31}, {47,16} }
local function bw(t) return 2.9 * (1 - t) ^ 0.75 + 0.45 end
local BRK = 0.8
local bm, bn, bT, bS, bsm = A.tubeGeo(bp, bw, function(t, s, x, y)
  if t > BRK + 0.04 * (((x + 2 * y) % 3) - 1) then return false end
  if t > 0.36 and t < 0.43 and s < -0.45 then return false end        -- nick in the edge
  return true end)
-- edge bevel (inner side, S<0) faces up-left more: tilt normals
bm:each(function(x, y) local k = K(x, y) local s = bS[k]
  if s < -0.3 then local nn = bn[k] bn[k] = { nn[1] * 0.5 - 0.35, nn[2] * 0.5 - 0.35, 0.8 } end end)
local bb = {}
bm:each(function(x, y) local k = K(x, y) if bS[k] > 0.72 then bb[k] = -1 end end)
local bidx = A.shade(c, bm, bn, S, { bias = bb, amb = 0.12 })
local L = A.blen(bsm)
-- bright edge line, ridge where bevel meets flat, swedge line near spine
bm:each(function(x, y) local k = K(x, y) local s, t = bS[k], bT[k]
  if s < -0.72 then A.set(c, bidx, S, x, y, 6)
  elseif s > -0.3 and s < -0.12 and t < 0.7 then A.bump(c, bidx, S, x, y, -1)
  elseif s > 0.45 and s < 0.6 and t < 0.55 then A.bump(c, bidx, S, x, y, 1) end end)
-- specular streak on the flat of the belly
for _, t in ipairs{ 0.16, 0.19, 0.22, 0.25 } do
  local s = bsm[floor(t * 160) + 1]
  A.set(c, bidx, S, floor(s.x + s.px * s.w * -0.05 + .5), floor(s.y + s.py * s.w * -0.05 + .5), 6)
end
do local s = bsm[floor(0.55 * 160) + 1] c:put(floor(s.x - s.px * s.w * 0.85 + .5), floor(s.y - s.py * s.w * 0.85 + .5), A.CREAM) end
-- hairline crack at the break
do local s = bsm[floor((BRK - 0.06) * 160) + 1]
  A.crack(c, { { floor(s.x + .5), floor(s.y + .5) }, { floor(s.x - s.px * 2 + .5), floor(s.y - s.py * 2 + 0.5) } }, bidx, S) end

-- flying hook tip: the rest of the curve, knocked up-left and rotated a little
local tp = {}
for i = 1, 4 do tp[i] = { bp[i][1] - 6, bp[i][2] - 4 } end
local tm, tn, tT, tS = A.tubeGeo(tp, bw, function(t) return t > BRK + 0.06 end)
local tidx = A.shade(c, tm, tn, S, { amb = 0.15 })
tm:each(function(x, y) if tS[K(x, y)] < -0.6 then A.set(c, tidx, S, x, y, 6) end end)

-- handle
local hp = A.seg(8, 49, 27, 42)
local function hw(t) return 2.2 + 0.6 * math.sin(math.pi * (0.2 + 0.7 * t)) end
local hm, hn, hT, hS, hsm = A.tubeGeo(hp, hw)
local hb = {}
hm:each(function(x, y) if hT[K(x, y)] > 0.9 then hb[K(x, y)] = -1 end end)   -- AO at the bolster
local hidx = A.shade(c, hm, hn, W, { bias = hb })
A.grain(c, hm, hT, hS, hidx, W, { -0.35, 0.25 }, A.blen(hsm), 5)
-- lanyard hole + two brass pins
local function at(t, s) local q = hsm[floor(t * 160) + 1] return floor(q.x + q.px * q.w * s + .5), floor(q.y + q.py * q.w * s + .5) end
do local x, y = at(0.08, 0) A.set(c, hidx, W, x, y, 1) A.set(c, hidx, W, x + 1, y, 2) A.set(c, hidx, W, x - 1, y - 1, 5) end
for _, t in ipairs{ 0.38, 0.72 } do local x, y = at(t, -0.05)
  c:put(x, y, Br[5]) c:put(x + 1, y, Br[3]) c:put(x, y + 1, Br[2]) c:put(x + 1, y + 1, W[1]) end

-- brass bolster
local bo = A.seg(26.5, 42.5, 30.5, 41.2)
local om, on, oT = A.tubeGeo(bo, function(t) return 3.1 end)
local oidx = A.shade(c, om, on, Br, { amb = 0.1 })
om:each(function(x, y) local t = oT[K(x, y)] if t > 0.4 and t < 0.6 then A.bump(c, oidx, Br, x, y, -1) end end)
-- AO on the blade root right after the bolster
bm:each(function(x, y) local k = K(x, y) if not om:has(x, y) and bT[k] < 0.06 then A.bump(c, bidx, S, x, y, -1) end end)

-- quirk: pea tendril curled round the bolster, one tiny leaf
local G1, G2, G3 = A.MOSS[3], A.MOSS[5], A.MOSS[6]
for _, p in ipairs{ {27,38},{28,38},{29,39},{29,40},{28,44},{29,45},{30,45},{31,44} } do c:put(p[1], p[2], G2) end
for _, p in ipairs{ {26,37},{25,36},{25,35},{26,34} } do c:put(p[1], p[2], G1) end
c:put(27, 34, G2)
A.map(c, { ".ab", "abc", "bc." }, 31, 45, { a = G3, b = A.MOSS[4], c = G1 })
A.fin(c)
