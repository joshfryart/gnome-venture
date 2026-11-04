-- pomato (final pass, Sonnet). The tomato-potato graft fruit: a squat, faintly ribbed, waxy pale-green tomato whose
-- lower right has turned to russet potato skin, with a ragged wavy border between the two and dark potato eyes.
-- Per-pixel dome light on two 6-tone ramps (green fruit, tan skin), rib grooves that follow the curve, waxy bloom
-- specks, one specular, cool reflected light low-right, AO under the sepals. A five-point calyx of curled sepals
-- (midrib + veins) sits in a dimple, with a thin stalk bending to a small serrated potato leaflet.
-- History: Sonnet draft replaced.
-- quirk: one potato eye on the russet patch has sprouted a pink shoot with two tiny curled leaves.
local NAME = "pomato"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD1t0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local FRUIT = { "#2c5a36", "#44803e", "#66a448", "#8cc656", "#b6e074", "#e2f6a6" }
local TAN   = { "#53392c", "#7a5640", "#a67f52", "#c9a26c", "#e4c78c", "#f8e6b8" }
local CAL   = { "#17402e", "#245c3a", "#357e45", "#4f9e50", "#78c060", "#aee084" }
local STEM  = { "#2f6a3e", "#4c8e4c", "#7eb862", "#b4da86" }
local PINK  = { "#7a2a52", "#b04a78", "#dc7aa0", "#f6aac4" }
local COOL, SPEC = "#6cb0a0", "#fffbe8"
local ftok, ttok, ctok = { r = { name = "fruit" } }, { r = { name = "skin" } }, { r = { name = "calyx" } }

-- ---------------------------------------------------------------- body
local CX, CY, RX, RY = 30, 42, 16.4, 14.2
local fm = HP.mask()
for y = floor(CY - RY - 2), floor(CY + RY + 2) do for x = floor(CX - RX - 2), floor(CX + RX + 2) do
  local u, v = (x - CX) / RX, (y - CY) / RY
  local r = sqrt(u * u + v * v)
  local th = math.atan(v, u)
  local lim = 1 - 0.035 * (1 - abs(cos(2.5 * th))) + (v > 0.5 and -0.04 or 0)
  if r <= lim then fm:set(x, y) end
end end
fm:cut(A.rell(CX, CY - RY - 0.2, 1, 0, 4.2, 1.9))              -- stem dimple
local n = A.dome(fm, CX - 1.5, CY - 1.5, 16, 5, 0.72)
local v = X.light(n, { amb = 0.06, wrap = 0.22 })
-- potato patch: wavy border, lower right
local tm = HP.mask()
fm:each(function(x, y)
  local d = (x - CX) * 0.58 + (y - CY) * 0.81
  local wob = 2.2 * sin(x * 0.55 + 1.0) + 1.6 * sin(y * 0.8) + 3.0 * (X.hash(floor(x / 2), floor(y / 2), 9) - 0.5)
  if d + wob > 3.2 then tm:set(x, y) end
end)
local gm = fm:copy():cut(tm)
local cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local gidx = X.tone(c, gm, v, FRUIT, { cuts = cuts, tok = ftok })
local tidx = X.tone(c, tm, v, TAN, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, tok = ttok })
-- rib grooves following the curve (3 grooves), lit lip beside each
for _, u0 in ipairs{ -0.58, 0.02, 0.6 } do
  fm:each(function(x, y) local k = K(x, y)
    local vy = (y - CY) / RY
    local half = RX * sqrt(max(0.06, 1 - vy * vy))
    local un = (x - CX) / half
    if abs(vy) < 0.9 and abs(un - u0) < 0.075 and not tm:has(x, y) then
      A.step(c, gidx, FRUIT, x, y, -2, ftok)
    elseif abs(vy) < 0.9 and un > u0 - 0.2 and un < u0 - 0.1 and not tm:has(x, y) and v[k] > 0.45 then
      A.step(c, gidx, FRUIT, x, y, 1, ftok)
    end
  end)
end
-- border line between green and tan: dark tan rind along the seam
tm:edge():each(function(x, y) end)
tm:each(function(x, y)
  if gm:has(x - 1, y) or gm:has(x, y - 1) then c:put(x, y, TAN[2], ttok) end
end)
gm:each(function(x, y)
  if tm:has(x + 1, y) or tm:has(x, y + 1) then c:put(x, y, FRUIT[2], ftok) end
end)
-- russet grain: short flecks on the potato skin
tm:each(function(x, y) local h = X.hash(x, y, 21)
  if h > 0.86 then A.step(c, tidx, TAN, x, y, -1, ttok) elseif h < 0.06 and (tidx[K(x, y)] or 1) >= 3 then A.step(c, tidx, TAN, x, y, 1, ttok) end end)
-- potato eyes (dark dimple with lit lip below)
for _, e in ipairs{ { 40, 47 }, { 33, 53 }, { 44, 51 } } do
  if fm:has(e[1] + 2, e[2] + 2) and fm:has(e[1] - 1, e[2]) then
  c:put(e[1], e[2], TAN[1], ttok) c:put(e[1] + 1, e[2], TAN[1], ttok) c:put(e[1], e[2] + 1, TAN[5], ttok) c:put(e[1] + 1, e[2] + 1, TAN[4], ttok)
  end
end
-- waxy bloom specks on the lit green
gm:each(function(x, y) local k = K(x, y)
  if v[k] > 0.62 and X.hash(x, y, 33) > 0.9 and gidx[k] and gidx[k] >= 3 then c:put(x, y, FRUIT[6], ftok) end end)
-- cool reflected light low-right
local rim = X.rim(n)
fm:edge():each(function(x, y) if rim[K(x, y)] and rim[K(x, y)] > 0.75 and y > CY then if not tm:has(x, y) then c:put(x, y, COOL, ftok) end end end)
-- specular: 2x1 + stray
c:put(19, 35, SPEC, ftok) c:put(20, 35, SPEC, ftok) c:put(19, 36, FRUIT[6], ftok) c:put(21, 34, FRUIT[6], ftok)

-- ---------------------------------------------------------------- calyx (five curled sepals) + stalk
local function sepal(ax, ay, cx, cy, bx, by, w, o) return A.leaf(c, ax, ay, cx, cy, bx, by, w, CAL, { tok = ctok, vs = 2.6, vein = CAL[6], pw = 0.6, fold = 0.4 }) end
local back = sepal(29, 26, 25, 20, 20, 19, 1.7)
-- stalk (behind the front sepals)
local stm, sn = A.tube({ { 30, 28 }, { 30, 21 }, { 33, 15 }, { 38, 13 } }, function(t) return 1.5 - 0.3 * t end)
A.shade(c, stm, sn, STEM, { amb = 0.14, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "stalk" } } })
stm:each(function(x, y) if (x + 2 * y) % 5 == 0 then c:put(x, y, STEM[4], { r = { name = "stalk" } }) end end)   -- hairs
-- potato leaflet at the end of the stalk, serrated edge
local lm, T, S = A.leaf(c, 37, 13.5, 42, 7, 51, 9, 3.6, CAL, { tok = ctok, vs = 3.0, vein = CAL[6], pw = 0.65 })
lm:edge():each(function(x, y) if (x * 3 + y) % 4 == 0 then c:put(x, y, CAL[1], ctok) end end)
sepal(30, 28, 22, 26, 14, 30, 2.2)
sepal(31, 28, 39, 26, 47, 30, 2.2)
sepal(30, 29, 26, 34, 21, 38, 2.0)
sepal(31, 29, 35, 34, 40, 38, 2.0)
-- hub where the sepals meet: ambient dark + a lit knob
for _, q in ipairs{ { 29, 28, 1 }, { 30, 28, 1 }, { 31, 28, 1 }, { 30, 29, 2 }, { 29, 29, 2 }, { 31, 29, 2 } } do c:put(q[1], q[2], CAL[q[3]], ctok) end
c:put(30, 27, CAL[5], ctok)
-- AO on the fruit where sepals rest
for _, q in ipairs{ { 26, 33, 1 }, { 34, 33, 1 }, { 22, 31, 1 }, { 39, 31, 1 }, { 24, 38, 1 }, { 38, 38, 1 } } do
  if fm:has(q[1], q[2]) then A.step(c, tm:has(q[1], q[2]) and tidx or gidx, tm:has(q[1], q[2]) and TAN or FRUIT, q[1], q[2], -1, ftok) end end

-- ---------------------------------------------------------------- quirk: sprouted potato eye (pink shoot, two curled leaves)
local pk = { r = { name = "shoot" } }
local sm2, sn2 = A.tube({ { 39, 46 }, { 43, 44 }, { 46, 41 }, { 46, 36 } }, function(t) return 1.35 - 0.35 * t end)
A.shade(c, sm2, sn2, PINK, { amb = 0.14, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = pk })
for _, q in ipairs{ { 45, 35, 3 }, { 46, 35, 4 }, { 44, 34, 2 }, { 45, 34, 3 }, { 46, 34, 3 }, { 47, 34, 2 }, { 43, 33, 2 }, { 44, 33, 3 }, { 45, 33, 4 },
  { 47, 36, 2 }, { 48, 35, 3 }, { 49, 34, 3 }, { 50, 34, 2 }, { 48, 34, 4 }, { 49, 33, 2 }, { 46, 32, 3 }, { 47, 32, 2 } } do c:put(q[1], q[2], PINK[q[3]], pk) end
c:put(38, 46, TAN[1], ttok) c:put(39, 47, TAN[1], ttok) c:put(38, 47, TAN[1], ttok)

A.save(c, NAME)
