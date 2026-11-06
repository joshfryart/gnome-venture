-- daikon (final, Opus single pass). One long, slim, gently S-curved white radish: pale-green sun-kissed shoulder
-- fading into creamy white, cool violet shade side, waxy sheen streak, faint horizontal ring scars with lenticel
-- dots, a few rootlet stubs, AO under the crown. Crown of four lyrate leaves (narrow petiole, paired side lobes,
-- big rounded end lobe) with pale midribs; the back leaves sit darker where the front ones overlap.
-- quirk: the fine root tip curls into a tiny pig's-tail loop.
local NAME = "daikon"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local WH = { "#6c6890", "#9c9ab8", "#c8c6d6", "#e6e2dc", "#f6f1e2", "#fffaec" }
local GR = { "#3f6a52", "#6a9a6a", "#9cc488", "#c4e0a2", "#def0c2", "#f0f8da" }
local LEAF = { "#173d32", "#21573c", "#2e7444", "#46924a", "#6cb256", "#a2d27a" }
local VEIN, COOLL = "#c8e696", "#36686a"
local COOL, SCAR, HAIR = "#a6bcdc", "#b0a890", "#b8ad90"

-- root
local rp = { { 32, 21 }, { 29, 33 }, { 36, 43 }, { 32, 53 } }
local rm, rn, RT, RS = A.tube(rp, function(t)
  return 5.3 * (1 - t ^ 2.3) ^ 0.85 + 0.3
end)
-- leaves (masks first, so AO can be computed between all parts)
local function lyrate(ax, ay, cx, cy, bx, by, size)
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    if t < 0.26 then return 0.8 end
    local u = (t - 0.26) / 0.74
    local e = (1.0 + 2.5 * size * sin(pi * min(1, u * 0.8 + 0.2)) ^ 0.6)
    if u < 0.6 then e = e * (0.45 + 0.55 * abs(sin(pi * u * 3.2))) end
    return max(0.8, e)
  end, { fold = 0.4 })
  return { m = m, n = n, T = T, S = S }
end
local back = { lyrate(31, 18, 27, 11, 24, 6, 0.95), lyrate(33, 18, 38, 11, 41, 6, 0.95) }
local front = { lyrate(31, 19, 22, 16, 12, 9, 1.0), lyrate(33, 19, 43, 16, 51, 10, 1.0) }
local all = HP.mask()
for _, L in ipairs(back) do all:add(L.m) end
for _, L in ipairs(front) do all:add(L.m) end

local ltok = { r = { name = "leaves" } }
local function paintLeaf(L, bias, tokn)
  local tok = { r = { name = tokn } }
  local idx = A.toneN(c, L.m, L.n, LEAF, { bias = bias, tok = tok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
  L.m:each(function(x, y) local k = K(x, y)
    if bias[k] then return end
    if abs(L.S[k]) < 0.18 and L.T[k] < 0.9 then c:put(x, y, L.S[k] <= 0 and VEIN or LEAF[3], tok) end
  end)
  A.reflect(c, L.m, L.n, COOLL, tok, 0.5)
end
-- back leaves: AO + contact shadow where the front leaves cover them
for i, L in ipairs(back) do
  local b = {}
  for _, F in ipairs(front) do X.ao(b, L.m, F.m, 1, -1) A.cast(b, L.m, F.m, 1, 1, -1) end
  for _, F in ipairs(front) do L.m:cut(F.m) end
  paintLeaf(L, b, "leafB" .. i)
end
for i, F in ipairs(front) do paintLeaf(F, {}, "leafF" .. i) end

-- root painted under the crown: cut by leaves, AO around the leaf bases
rm:cut(all)
local rb = {}
X.ao(rb, rm, all, 2, -1)
local rtok = { r = { name = "root" } }
local v = X.light(rn, { amb = 0.12, wrap = 0.3 })
local ridx = {}
rm:each(function(x, y) local k = K(x, y)
  local i = 1
  for j, t in ipairs{ 0.16, 0.32, 0.5, 0.68, 0.85 } do if v[k] >= t then i = j + 1 end end
  i = max(1, min(6, i + (rb[k] or 0)))
  ridx[k] = i
  -- pale-green shoulder fading out with a ragged edge
  local g = RT[k] < 0.13 + 0.06 * X.hash(x, 0, 2)
  c:put(x, y, g and GR[i] or WH[i], rtok)
end)
-- waxy sheen streak on the lit flank
rm:each(function(x, y) local k = K(x, y)
  if RS[k] < -0.35 and RS[k] > -0.62 and RT[k] > 0.2 and RT[k] < 0.58 and not rb[k] then c:put(x, y, WH[6], rtok) end end)
-- ring scars + lenticel dots
local seen = {}
for _, tr in ipairs{ 0.27, 0.37, 0.48, 0.6, 0.71 } do
  local x0, y0 = A.bez(rp, tr)
  rm:each(function(x, y) local k = K(x, y)
    if abs(RT[k] - tr) < 0.009 and RS[k] > -0.75 and RS[k] < 0.7 and X.hash(x, y, 8) > 0.2 then
      c:put(x, y, (RS[k] < -0.2) and WH[3] or WH[max(1, ridx[k] - 1)], rtok) end end)
end
for _, q in ipairs{ { 33, 31 }, { 29, 37 }, { 36, 44 }, { 33, 49 } } do if rm:has(q[1], q[2]) then c:put(q[1], q[2], SCAR, rtok) end end
-- cool reflected light on the shade flank
rm:edge():each(function(x, y) local k = K(x, y)
  if RS[k] > 0.75 and RT[k] > 0.15 and RT[k] < 0.85 then c:put(x, y, COOL, rtok) end end)
-- rootlet stubs (1-2 px, off the flanks)
for _, q in ipairs{ { 26, 36 }, { 25, 37 }, { 38, 40 }, { 39, 41 }, { 30, 47 } } do
  if not rm:has(q[1], q[2]) then c:put(q[1], q[2], HAIR, rtok) end end
-- one specular glint on the shoulder
c:put(29, 26, "#fff4d6", rtok)
-- quirk: pig's-tail curl at the tip
for _, q in ipairs{ { 32, 54 }, { 33, 55 }, { 34, 56 }, { 35, 56 }, { 36, 55 }, { 36, 54 }, { 35, 53 } } do
  if not rm:has(q[1], q[2]) then c:put(q[1], q[2], (q[2] >= 55) and WH[2] or WH[4], rtok) end end
A.save2(c, NAME)
