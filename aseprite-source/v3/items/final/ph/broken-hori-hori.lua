-- broken-hori-hori (aB11_5, Opus single pass). Japanese soil knife on the diagonal: dished steel blade (tip upper-
-- left) with a serrated left edge, etched depth ticks on the right edge and a central fuller; steel bolster; ash
-- handle with two brass pins and a brass butt cap (handle lower-right).
-- Material: concave per-pixel lighting on the blade (lit lower-right wall), bright edge, specular, grain + AO.
-- broken: the tip has snapped off and flies away up-left, with a crack running back from the jagged break.
-- quirk: an earthworm wriggles out of a clump of soil still stuck to the blade.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_5.lua")
local HP, X, c = A.new("broken-hori-hori")
local K = A.K
local W, S, Br, So = A.ASH, A.STEEL, A.BRASS, A.SOIL
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt

-- blade: tip (12,12) -> bolster (32,32)
local TIPX, TIPY, BX, BY = 12, 12, 32, 32
local function bw(t) if t < 0.32 then return 0.3 + 3.3 * (t / 0.32) ^ 0.8 end return 3.6 - 0.3 * (t - 0.32) end
local BRK = 0.2
local function bladeGeo(dx, dy, keep)
  local m, n, T, S_ = A.tubeGeo(A.seg(TIPX + dx, TIPY + dy, BX + dx, BY + dy), bw, keep)
  -- concave dish: invert the cylinder normal
  for k, nn in pairs(n) do local s = S_[k]
    local ox, oy = -nn[1], -nn[2]
    n[k] = { ox * 0.75, oy * 0.75, nn[3] } end
  return m, n, T, S_
end
local bm, bn, bT, bS = bladeGeo(0, 0, function(t, s, x, y)
  if t < BRK + 0.02 * (((x * 2 + y) % 3) - 1) then return false end
  if s > 0.7 and floor(t * 44) % 2 == 0 and t > 0.5 then return false end      -- serrations on one edge
  return true end)
local bb = {}
bm:each(function(x, y) local k = K(x, y) if abs(bS[k]) > 0.8 then bb[k] = 1 end end)
local bidx = A.shade(c, bm, bn, S, { amb = 0.15, bias = bb })
-- fuller down the middle, depth ticks on the plain edge, bright plain edge
bm:each(function(x, y) local k = K(x, y) local s, t = bS[k], bT[k]
  if abs(s) < 0.14 and t > 0.38 then A.bump(c, bidx, S, x, y, -1) end
  if s < -0.82 then A.set(c, bidx, S, x, y, 6) end
  if s < -0.35 and s > -0.82 and t > 0.35 and floor(t * 28 + 0.5) % 2 == 0 and (t * 28 + 0.5) % 1 < 0.25 then A.bump(c, bidx, S, x, y, -2) end
end)
-- specular dot on the lit dish wall
c:put(23, 21, S[6]) c:put(24, 22, S[6]) c:put(20, 21, A.CREAM)
-- crack back from the break
A.crack(c, { {17,15},{19,18},{21,19} }, bidx, S)

-- flying tip
local tm, tn, tT, tS = bladeGeo(-4, -3, function(t) return t < BRK - 0.04 end)
local tidx = A.shade(c, tm, tn, S, { amb = 0.2 })
tm:each(function(x, y) if tS[K(x, y)] < -0.6 then A.set(c, tidx, S, x, y, 6) end end)

-- steel bolster
local om, on = A.tubeGeo(A.seg(31, 31, 35, 35), function() return 3.4 end)
local oidx = A.shade(c, om, on, A.IRON, { amb = 0.1 })
-- handle
local hm, hn, hT, hS, hsm = A.tubeGeo(A.seg(34.5, 34.5, 51, 51), function(t) return 2.6 + 0.3 * math.sin(math.pi * t) end)
local hb = {}
hm:each(function(x, y) if hT[K(x, y)] < 0.08 then hb[K(x, y)] = -1 end end)
X.ao(hb, hm, om, 1, -1)
local hidx = A.shade(c, hm, hn, W, { bias = hb })
A.grain(c, hm, hT, hS, hidx, W, { -0.4, 0.1, 0.55 }, 24, 9)
for _, t in ipairs{ 0.3, 0.62 } do local q = hsm[floor(t * 160) + 1] local x, y = floor(q.x + .5), floor(q.y + .5)
  c:put(x, y, Br[5]) c:put(x + 1, y, Br[3]) c:put(x, y + 1, Br[3]) c:put(x + 1, y + 1, W[1]) end
-- brass butt cap
local cm, cn = A.tubeGeo(A.seg(50, 50, 53, 53), function() return 2.9 end)
A.shade(c, cm, cn, Br)
-- AO on blade root before bolster
bm:each(function(x, y) if bT[K(x, y)] > 0.9 and not om:has(x, y) then A.bump(c, bidx, S, x, y, -1) end end)

-- quirk: soil clump on the blade + earthworm
local clump = c:ellipse(27, 24, 2.6, 1.8) clump:add(c:ellipse(25, 25.5, 1.6, 1.4))
A.shade(c, clump, X.pillow(clump, 1.4), So, { amb = 0.15 })
c:put(26, 23, So[6]) c:put(28, 25, So[2])
local P = A.PETAL
for _, q in ipairs{ {29,23,4},{30,22,5},{31,22,5},{32,21,4},{33,21,5},{34,20,5},{35,20,6} } do c:put(q[1], q[2], P[q[3]]) end
for _, q in ipairs{ {30,23,2},{31,23,3},{33,22,2},{34,21,3} } do c:put(q[1], q[2], P[q[3]]) end
c:put(35, 21, P[3])
A.fin(c)
