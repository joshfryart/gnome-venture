-- broken-garden-snips (aB11_3, Opus single pass). Bypass pruning snips, jaws open: two slim curved steel blades
-- (bevel, bright edge, specular streak) on a brass pivot bolt with a slot, slim steel shanks into red lacquered grips
-- with ribbed grooves. Back pair gets ambient shade where the front pair crosses it.
-- broken: the hooked lower blade has snapped near the tip (tip lies knocked out of line beyond a gap) and a small
-- steel chip flies off; a crack runs into the front grip.
-- quirk: a freshly snipped leaf is still caught in the jaws.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_3.lua")
local HP, X, K, G = A.HP, A.X, A.K, A.G
local S, B, R = A.STEEL, A.BRASS, A.GRIP
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new("broken-garden-snips")
local PX, PY = 32, 30

local function bladeW(t) return 2.6 * (1 - t) ^ 0.75 + 0.45 end
-- front pair: upper blade + handle to lower-left; back pair: hooked blade + handle to the left
local b1P = { { PX, PY }, { 38, 22 }, { 45, 15 }, { 49, 8 } }
local b2P = { { PX, PY }, { 41, 28 }, { 50, 24 }, { 55, 16 } }
local h1P = { { PX, PY }, { 27, 37 }, { 22, 44 }, { 16, 51 } }
local h2P = { { PX, PY }, { 24, 33 }, { 16, 35 }, { 9, 41 } }
local function handleW(t) if t < 0.3 then return 1.25 end return 2.15 - max(0, t - 0.9) * 4 end

local b1m, b1n, b1T, b1S = G.tube(b1P, bladeW)
local b2m, b2n, b2T, b2S = G.tube(b2P, function(t) if t > 0.7 then return 0 end return bladeW(t) end)
local tm, tn, tT, tS = G.tube({ { PX + 2, PY - 2 }, { 43, 26 }, { 52, 22 }, { 57, 14 } }, function(t) if t < 0.8 then return 0 end return bladeW(t) end)
local h1m, h1n, h1T, h1S = G.tube(h1P, handleW)
local h2m, h2n, h2T, h2S = G.tube(h2P, handleW)
local front = b1m:copy():add(h1m)

local function steel(m, n, T, Sd, bias, edgeSide)
  local idx = A.tone(c, m, n, S, { bias = bias, tok = { r = { name = "steel" } } })
  -- bevel: bright cutting edge on one side, darker spine on the other
  m:each(function(x, y) local k = K(x, y)
    if Sd[k] * edgeSide > 0.62 and T[k] > 0.12 then c:put(x, y, S[edgeSide < 0 and 6 or 5])
    elseif Sd[k] * edgeSide < -0.7 and T[k] > 0.12 then c:put(x, y, S[max(1, idx[k] - 1)]) end end)
  return idx
end
local function grip(m, n, T, Sd, bias, from)
  local gm = HP.mask() m:each(function(x, y) if T[K(x, y)] >= from then gm:set(x, y) end end)
  local sm = m:copy():cut(gm)
  A.tone(c, sm, n, S, { bias = bias, tok = { r = { name = "steel" } } })
  local idx = A.tone(c, gm, n, R, { bias = bias, tok = { r = { name = "grip" } } })
  -- ferrule ring where steel enters the grip
  gm:each(function(x, y) local k = K(x, y) if T[k] < from + 0.05 then c:put(x, y, R[max(1, idx[k] - 2)]) end end)
  -- ribs: groove + lit lip every ~3 px
  gm:each(function(x, y) local k = K(x, y)
    local q = (T[k] - from) * 28
    local f = q - floor(q)
    if T[k] > from + 0.12 and T[k] < 0.88 and abs(Sd[k]) < 0.85 then
      if f < 0.22 then c:put(x, y, R[max(1, idx[k] - 1)]) elseif f < 0.44 and Sd[k] < 0 then c:put(x, y, R[min(6, idx[k] + 1)]) end
    end end)
  return gm, idx
end

-- back pair (ambient shade where the front pair overlaps it)
local bias2 = {}
X.ao(bias2, b2m, front, 1, -2) X.ao(bias2, h2m, front, 1, -2)
grip(h2m, h2n, h2T, h2S, bias2, 0.3)
steel(b2m, b2n, b2T, b2S, bias2, -1)
steel(tm, tn, tT, tS, {}, -1)
-- broken faces: pale fresh steel on both sides of the snap
b2m:each(function(x, y) local k = K(x, y) if b2T[k] > 0.64 then c:put(x, y, S[5]) end end)
tm:each(function(x, y) local k = K(x, y) if tT[k] < 0.84 then c:put(x, y, S[4]) end end)
-- the flying chip
c:paint({ ".a", "bc" }, 55, 26, { a = S[6], b = S[4], c = S[2] })

-- quirk: snipped leaf caught in the jaws (painted before the front blade so the blade sits over its stem end)
local lm = G.rell(41.5, 23.5, 0.55, -0.83, 4.2, 2.1)
local ln = X.pillow(lm, 1.5)
A.tone(c, lm, ln, A.LEAF, { tok = { r = { name = "leaf" } } })
for i = -3, 4 do local x, y = floor(41.5 + 0.55 * i + .5), floor(23.5 - 0.83 * i + .5) if lm:has(x, y) then c:put(x, y, A.LEAF[3]) end end
c:put(43, 21, A.LEAF[6]) c:put(40, 25, A.LEAF[2])

-- front pair
local bias1 = {}
X.ao(bias1, h1m, b1m, 1, -1)
local g1 = grip(h1m, h1n, h1T, h1S, bias1, 0.3)
steel(b1m, b1n, b1T, b1S, {}, 1)
-- specular streak on the front blade
for _, t in ipairs{ 0.3, 0.36, 0.42, 0.48 } do
  local x, y = G.bez(b1P, t) c:put(floor(x - 0.6), floor(y - 0.4), S[6]) end
do local x, y = G.bez(b1P, 0.39) c:put(floor(x - 0.6), floor(y - 0.4), A.SPEC) end
-- crack into the front grip
for _, p in ipairs{ { 21, 45 }, { 22, 46 }, { 21, 47 }, { 22, 48 } } do if h1m:has(p[1], p[2]) then c:put(p[1], p[2], R[1]) end end
-- pivot bolt: brass with a slot, dark recess ring
local bm = c:ellipse(PX, PY, 2.5, 2.5)
bm:edge():each(function(x, y) end)
c:fillMask(c:ellipse(PX, PY, 3, 3):clip(front:copy():add(b2m):add(h2m)), S[1])
G.disc(c, PX, PY, 2.4, B)
c:put(PX - 1, PY + 1, B[1]) c:put(PX, PY, B[1]) c:put(PX + 1, PY - 1, B[1])
c:put(PX - 1, PY - 1, B[6])
A.save(c)
