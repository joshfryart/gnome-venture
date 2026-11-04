-- ico-carrot (final, Opus). Bold icon carrot on the diagonal: crown upper-right, tapered tip lower-left, three chunky
-- leaf sprigs fanning up out of a sunken crown. Root = per-pixel tube light (6-tone orange, violet shade), raised
-- growth rings (dark groove + lit lip), waxy specular streak, cool bounce light lower-right, AO at the crown.
-- Leaves = 6-tone folded blades with a lit midrib and side veins, dark where they meet the crown.
-- quirk: a rabbit-sized bite out of the side near the tip, showing the paler core rings.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA2_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new("ico-carrot")
local OR    = { "#6a2236", "#a2332e", "#d04b25", "#ee6c22", "#fb983a", "#ffc874" }
local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#a6d672" }
local CORE  = { "#e8661f", "#ffb257", "#ffe3a3" }
local SPEC, BOUNCE = "#fff1cf", "#b04a5c"

local CX, CY = 41, 23
-- leaves first (root paints over their bases)
local ltok = A.tok("leaf")
local function leaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t < 0.2 then return 0.8 + t * 2.5 end
    local u = (t - 0.2) / 0.8
    local env = w * (math.sin(math.pi * (u * 0.82 + 0.1))) ^ 0.9 * (1 - u * 0.35)
    return env * (0.72 + 0.28 * abs(math.cos(u * math.pi * 2.5))) + 0.35
  end, { fold = 0.6 })
  local bias = {}
  m:each(function(x, y) local k = K(x, y) if T[k] < 0.16 then bias[k] = -2 elseif T[k] < 0.28 then bias[k] = -1 end end)
  local idx = A.shade(c, m, n, LEAF, { tok = ltok, bias = bias, amb = 0.04, wrap = 0.15, cuts = { 0.22, 0.4, 0.58, 0.76, 0.92 } })
  -- midrib (lit) + side veins (one tone darker), pairs angled toward the tip
  m:each(function(x, y) local k = K(x, y) local t, s = T[k], S[k]
    if abs(s) < 0.16 and t > 0.12 and t < 0.92 then A.set(c, idx, LEAF, x, y, min(6, max(idx[k], 4) + 1), ltok)
    else
      local ph = (t * 5.2 - abs(s) * 0.55) % 1
      if t > 0.28 and t < 0.86 and abs(s) > 0.28 and abs(s) < 0.8 and ph < 0.13 then A.step(c, idx, LEAF, x, y, -1, ltok) end
    end end)
  return m
end
leaf(CX - 1, CY, 33, 15, 23, 11, 3.6)
leaf(CX, CY - 1, 42, 14, 45, 6, 3.6)
leaf(CX + 1, CY, 51, 18, 58, 15, 3.4)

-- root
local p = { { CX, CY + 1 }, { 34, 31 }, { 25, 42 }, { 15, 56 } }
local function hw(t)
  if t < 0.06 then return 5.6 + (t / 0.06) * 2.2 end
  return 7.8 * ((1 - t) / 0.94) ^ 0.82 + 0.5
end
local rm, rn, RT, RS, samp = A.tube(p, hw)
-- bite: two overlapping scallops out of the upper-left edge near the tip
local s0 = samp[floor(0.56 * 160) + 1]
local bite = A.ell(s0.x + s0.px * (s0.w + 0.6), s0.y + s0.py * (s0.w + 0.6), 2.2, 2.2)
bite:add(A.ell(s0.x + s0.px * (s0.w + 0.9) - s0.tx * 3.3, s0.y + s0.py * (s0.w + 0.9) - s0.ty * 3.3, 2.0, 2.0))
rm:cut(bite)
local v = X.light(rn, { amb = 0.06, wrap = 0.22 })
local bias = {}
rm:each(function(x, y) local k = K(x, y) if RT[k] < 0.035 then bias[k] = -1 end end)
local rtok = A.tok("root")
local idx = X.tone(c, rm, v, OR, { cuts = { 0.18, 0.36, 0.53, 0.7, 0.88 }, bias = bias, tok = rtok })
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
-- growth rings (short grooves, bowed with the cylinder), lit lip on the crown side
local rings = { { 0.17, -0.7, 0.75 }, { 0.29, -0.25, 0.9 }, { 0.41, -0.75, 0.35 }, { 0.53, -0.15, 0.9 }, { 0.65, -0.6, 0.6 }, { 0.84, -0.4, 0.8 } }
rm:each(function(x, y) local k = K(x, y)
  local t, s = RT[k], RS[k]
  for _, r in ipairs(rings) do
    local d = (t - r[1]) * LEN + s * s * 1.6
    if s > r[2] and s < r[3] then
      local cur = idx[k] or 3
      if d > -0.5 and d < 0.5 then A.set(c, idx, OR, x, y, max(1, cur - 2), rtok)
      elseif d >= -1.5 and d <= -0.5 and s < 0 and cur >= 4 then A.set(c, idx, OR, x, y, min(6, cur + 1), rtok) end
    end
  end
end)
-- bite flesh: paler core rings just inside the cut
local bring = bite:grow(1):cut(bite)
local bring2 = bite:grow(2):cut(bite):cut(bring)
local btok = A.tok("bite")
bring:each(function(x, y) if rm:has(x, y) then c:put(x, y, CORE[3], btok) end end)
bring2:each(function(x, y) if rm:has(x, y) then c:put(x, y, CORE[2], btok) end end)
-- cool reflected light lower-right edge
local rim = X.rim(rn)
rm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.7 and RS[k] > 0.8 and RT[k] > 0.1 and RT[k] < 0.82 then c:put(x, y, BOUNCE, rtok) end end)
-- waxy specular streak on the lit shoulder + one glint
for _, q in ipairs{ { 0.1, -0.52 }, { 0.13, -0.52 }, { 0.16, -0.5 }, { 0.19, -0.48 }, { 0.22, -0.46 } } do
  local s = samp[floor(q[1] * 160) + 1]
  c:put(floor(s.x + s.px * s.w * q[2] + .5), floor(s.y + s.py * s.w * q[2] + .5), OR[6], rtok)
end
do local s = samp[floor(0.14 * 160) + 1]
  c:put(floor(s.x + s.px * s.w * -0.5 + .5) - 1, floor(s.y + s.py * s.w * -0.5 + .5), SPEC, rtok) end
-- sunken crown: dark cup + stalk stubs
local crown = A.rell(CX, CY + 0.6, 0.62, 0.78, 2.4, 1.1)
crown:each(function(x, y) if rm:has(x, y) then c:put(x, y, OR[1], rtok) end end)
c:put(CX - 1, CY + 1, LEAF[3], ltok) c:put(CX, CY, LEAF[4], ltok) c:put(CX + 1, CY + 1, LEAF[3], ltok)
A.save(c, "ico-carrot")
