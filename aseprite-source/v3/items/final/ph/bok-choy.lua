-- bok-choy (Opus single pass, aR21_2). An upright head: five slim, pale spoon-shaped stalks rising from a
-- narrow cut base and fanning out into dark glossy oval leaves. Stalks: per-pixel tube light (6-tone pale
-- celadon) with faint ribs; leaves: 6-tone curved blades with a pale midrib carried up from the stalk, paired
-- veins, overlap AO and dark separation lines; cut base shows a tan end with rings.
-- quirk: a caterpillar has nibbled a bite out of the right leaf and is still sitting in it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR21_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.pi, math.sqrt
local c = A.new2("bok-choy")
local LEAF  = { "#11321f", "#1b4a30", "#28673b", "#3a8545", "#58a550", "#8ccb66" }
local STALK = { "#6c8a6c", "#93b48e", "#b9d6aa", "#d8ecc4", "#eef8e0", "#fdfbea" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
-- leaves back to front: {curve, blade half-width, blade start t}
local L = {
  { { {30, 53}, {25, 44}, {16, 36}, {12, 22} }, 5.0, 0.38 },
  { { {34, 53}, {40, 44}, {48, 36}, {52, 23} }, 5.0, 0.38 },
  { { {31, 53}, {29, 42}, {24, 30}, {22, 14} }, 5.4, 0.42 },
  { { {33, 53}, {36, 42}, {41, 30}, {43, 15} }, 5.4, 0.42 },
  { { {32, 54}, {32, 42}, {32, 28}, {32, 10} }, 5.6, 0.45 },
}
local parts = {}
for i, l in ipairs(L) do
  local p, W, t0 = l[1], l[2], l[3]
  local bm, bn, BT, BS, bs = A.tube(p, function(t)
    if t < t0 then return -1 end
    local u = (t - t0) / (1.02 - t0)
    return W * sin(pi * min(u, 0.999)) ^ 0.55 + 0.2
  end)
  local sm, sn, ST, SS = A.tube(p, function(t)
    if t > t0 + 0.12 then return -1 end
    return 1.3 + 1.2 * min(1, t / 0.5)
  end)
  local len = 0
  for j = 2, #bs do len = len + sqrt((bs[j].x - bs[j-1].x)^2 + (bs[j].y - bs[j-1].y)^2) end
  parts[i] = { bm = bm, bn = bn, BT = BT, BS = BS, sm = sm, sn = sn, ST = ST, SS = SS, len = len, t0 = t0, all = bm:copy():add(sm) }
end
-- quirk: bite out of the right leaf edge
local bite = c:ellipse(55, 29, 2, 2)
parts[2].bm:cut(bite) parts[2].all:cut(bite)
for i, P in ipairs(parts) do
  local bias, sbias = {}, {}
  for j = i + 1, #parts do
    local F = parts[j].all
    A.cast(bias, P.bm, F, 1, 1, -1)
    A.cast(sbias, P.sm, F, 1, 1, -1)
    F:grow(1):cut(F):each(function(x, y) local k = K(x, y)
      if P.bm:has(x, y) then bias[k] = -3 end
      if P.sm:has(x, y) then sbias[k] = -2 end end)
  end
  local ltok = { r = { name = "leaf" .. i } }
  local stok = { r = { name = "stalk" .. i } }
  -- blade
  local idx = X.tone(c, P.bm, X.light(P.bn, { amb = 0.1, wrap = 0.3 }), LEAF, { cuts = CUTS, bias = bias, tok = ltok })
  P.bm:each(function(x, y) local k = K(x, y)
    local s, t = P.BS[k], P.BT[k]
    if (bias[k] or 0) <= -2 then return end
    if abs(s) < 0.16 and t < 0.93 then c:put(x, y, s <= 0 and STALK[4] or STALK[2], ltok) return end
    for _, vt in ipairs{ 0.56, 0.68, 0.8 } do
      local d = (t - vt) * P.len - abs(s) * 3.2
      if d > -0.5 and d < 0.5 and abs(s) > 0.25 and abs(s) < 0.78 then
        c:put(x, y, LEAF[max(1, min(6, idx[k] + (s < 0 and 1 or -1)))], ltok) end
    end
  end)
  -- stalk over the blade base
  local sidx = X.tone(c, P.sm, X.light(P.sn, { amb = 0.12, wrap = 0.3 }), STALK, { cuts = CUTS, bias = sbias, tok = stok })
  P.sm:each(function(x, y) local k = K(x, y)
    local s, t = P.SS[k], P.ST[k]
    if abs(s - 0.45) < 0.12 and t > 0.12 and (sbias[k] or 0) == 0 then c:put(x, y, STALK[max(1, sidx[k] - 1)], stok) end
    if t > P.t0 + 0.06 and abs(s) > 0.5 then c:put(x, y, LEAF[5], stok) end
  end)
end
-- specular on the front leaf
local P5 = parts[5]
local gx, gy = A.specAt(P5.bm, P5.bn, 40) c:put(gx, gy, LEAF[6]) c:put(gx + 1, gy, "#e8f6c0")
-- cut base: tan end with growth ring and dark heart
local base = c:ellipse(32, 55, 4, 1)
base:each(function(x, y) c:put(x, y, "#d9c28c", { r = { name = "base" } }) end)
for x = 29, 35 do c:put(x, 56, "#a8875a", { r = { name = "base" } }) end
c:put(32, 55, "#7b6040", { r = { name = "base" } }) c:put(30, 55, "#f0e0b0", { r = { name = "base" } })
-- caterpillar in the bite
local cat = { {54, 28, "#9ad04a"}, {55, 28, "#c6ec6a"}, {56, 29, "#9ad04a"}, {55, 29, "#6fa83a"}, {56, 30, "#6fa83a"}, {53, 28, "#2b1c26"} }
for _, q in ipairs(cat) do c:put(q[1], q[2], q[3], { r = { name = "cat" } }) end
A.save2(c, "bok-choy")
