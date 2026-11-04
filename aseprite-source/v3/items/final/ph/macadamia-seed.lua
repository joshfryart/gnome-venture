-- macadamia-seed (final pass, Opus aC21_5). Two macadamia nuts (the seed) on a torn scrap of leathery macadamia
-- leaf: spiny toothed margin, V fold, pale midrib + veins, a ragged torn end with pale fibre. The left nut is whole
-- (glossy brown ball, pale hilum, suture, specular, cool rim); the right nut has split along its suture and sprouts:
-- a pale stem rising to a whorl of three narrow spiny-toothed leaves (macadamia leaves grow in threes), and a short
-- radicle curling down over the leaf. AO + contact shadow under each nut.
-- History: Sonnet draft (dC21) replaced.
-- quirk: a single round dewdrop sits on the left sprout leaf.
local NAME = "macadamia-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF  = { "#16382e", "#1f5038", "#2c6a40", "#43874a", "#66a656", "#94c46c" }
local YL    = { "#1e4a32", "#2c6a3c", "#408a44", "#5ea84c", "#86c45e", "#b4dc7e" }   -- young sprout leaves
local SHELL = { "#3a2018", "#5c3220", "#82502e", "#a8703e", "#cc9658", "#ecc488" }
local STEM  = { "#4f7a4a", "#7aa862", "#a8cc84", "#d8ecb0" }
local ROOT  = { "#a07a58", "#d0b088", "#f0dcb4" }
local VEIN, COOL, FIBRE, CREAM = "#c2e48c", "#4a6a7a", "#d8e2a0", "#fff4d6"
local WATER = { "#5f9ad0", "#b9e2f5", "#e4f6ff" }

local function spiny(m, LT, LS, len, per, depth)
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local ph = (LT[k] * len) / per + (LS[k] > 0 and 0.5 or 0)
    local f = ph - floor(ph)
    if abs(LS[k]) > depth + (1 - depth) * f and LT[k] > 0.1 and LT[k] < 0.9 then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
end

-- leaf scrap: broad base at left, torn ragged at right
local lm, ln, LT, LS, len = A.blade(7, 50, 30, 52, 56, 41, function(t)
  local u = min(1, t * 1.6 + 0.08)
  return max(0.6, 8.2 * sin(pi * 0.5 * u) ^ 0.8)
end, { fold = 0.4 })
spiny(lm, LT, LS, len, 5.0, 0.62)
local torn = {}
lm:each(function(x, y) local k = K(x, y)
  local lim = len - 1.5 - 3.5 * X.hash(0, y, 11) - 1.5 * X.hash(0, floor(y / 2), 5)
  if LT[k] * len > lim then torn[#torn + 1] = k end
end)
for _, k in ipairs(torn) do lm.s[k] = nil end

local N1 = { 21, 45, 6 }
local N2 = { 36, 42, 6 }
local m1 = c:ellipse(N1[1], N1[2], N1[3], N1[3])
local m2 = c:ellipse(N2[1], N2[2], N2[3], N2[3])

-- sprout parts (masks)
local sp = { { 37, 37 }, { 38, 30 }, { 36, 24 }, { 37, 18 } }
local stm, stn = A.tube(sp, function(t) return 1.1 - 0.2 * t end)
local rp = { { 40, 46 }, { 43, 49 }, { 44, 53 }, { 41, 56 } }
local rm, rn = A.tube(rp, function(t) return 1.3 * (1 - t) + 0.4 end)
rm:cut(m2)

local lb = {}
for _, m in ipairs{ m1, m2 } do X.ao(lb, lm, m, 1, -1) A.cast(lb, lm, m, 1, 2, -1) end
X.ao(lb, lm, rm, 1, -1) A.cast(lb, lm, rm, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
A.shade(c, lm, ln, LEAF, { bias = lb, tok = ltok, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  if lb[k] then return end
  local s, t = LS[k], LT[k]
  if abs(s) < 0.14 and t < 0.97 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 4.0) / 5.0 + (s > 0 and 0.5 or 0)
  local f = ph - floor(ph)
  if f > 0.86 and abs(s) > 0.2 and abs(s) < 0.62 and t > 0.08 and t < 0.92 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
-- torn edge fibre + cool reflected lower edge
lm:edge():each(function(x, y) local k = K(x, y)
  if lb[k] then return end
  if LT[k] * len > len - 7.5 and not lm:has(x + 1, y) then c:put(x, y, FIBRE, ltok)
  elseif LS[k] > 0.7 and LT[k] > 0.1 then c:put(x, y, COOL, ltok) end end)
-- petiole stub
c:put(6, 50, LEAF[3], ltok) c:put(5, 50, LEAF[4], ltok) c:put(4, 51, LEAF[3], ltok)

-- radicle
A.shade(c, rm, rn, ROOT, { tok = { r = { name = "root" } }, cuts = { 0.35, 0.65 }, amb = 0.15, wrap = 0.3 })
c:put(41, 56, ROOT[1], { r = { name = "root" } })

-- stem
local stok = { r = { name = "stem" } }
local sm2 = stm:copy():cut(m2)
A.shade(c, sm2, stn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })

-- whorl of three spiny leaves
local ytok = { r = { name = "sprout" } }
local function yleaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.7)
  end, { fold = 0.4 })
  spiny(m, T, S, L, 3.2, 0.55)
  m:cut(sm2)
  A.shade(c, m, n, YL, { tok = ytok, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.18 and T[k] > 0.06 and T[k] < 0.88 then c:put(x, y, S[k] <= 0 and YL[6] or YL[3], ytok) end end)
  return m
end
local yl = yleaf(36, 19, 29, 15, 20, 18, 3.0)
local yr = yleaf(38, 19, 45, 16, 53, 20, 3.0)
local yc = yleaf(37, 18, 36, 13, 39, 7, 2.4)
-- AO where the leaves meet the stem tip
for _, q in ipairs{ { 35, 19 }, { 39, 19 }, { 37, 20 } } do if yl:has(q[1], q[2]) or yr:has(q[1], q[2]) then c:put(q[1], q[2], YL[1], ytok) end end

-- nuts
local function nut(mm, N, name, split)
  local tok = { r = { name = name } }
  local nn = X.sphere(N[1], N[2], N[3], mm)
  local b = {}
  if split then X.ao(b, mm, stm, 1, -1) X.ao(b, mm, rm, 1, -1) end
  if name == "n1" then X.ao(b, mm, m2, 1, -1) end
  local vis = mm:copy()
  if name == "n1" then vis:cut(m2) end
  local idx = A.shade(c, vis, nn, SHELL, { bias = b, tok = tok, amb = 0.08, wrap = 0.25, cuts = { 0.16, 0.32, 0.5, 0.68, 0.85 } })
  vis:each(function(x, y) if X.hash(x, y, 9) > 0.9 and (idx[K(x, y)] or 1) > 2 then A.step(c, idx, SHELL, x, y, -1, tok) end end)
  -- suture
  for y = N[2] - N[3] + 1, N[2] + N[3] - 1 do local x = floor(N[1] - 0.5 - 2.2 * sin((y - N[2] + N[3]) / (2 * N[3]) * pi) + .5)
    if vis:has(x, y) then local i = idx[K(x, y)] or 3 c:put(x, y, SHELL[min(6, i + 1)], tok) end end
  local gx, gy = A.specAt(vis, nn, 50)
  c:put(gx, gy, CREAM, tok) c:put(gx + 1, gy, SHELL[6], tok)
  vis:edge():each(function(x, y) if (x - N[1]) + (y - N[2]) > N[3] * 1.05 then c:put(x, y, COOL, tok) end end)
  return idx, tok
end
nut(m1, N1, "n1")
local i2, t2 = nut(m2, N2, "n2", true)
-- hilum on whole nut
c:put(20, 39, SHELL[6], { r = { name = "n1" } }) c:put(21, 39, CREAM, { r = { name = "n1" } })
-- split shell on the sprouting nut: dark gap at the top where the stem exits, pale kernel edge
for _, q in ipairs{ { 35, 36 }, { 36, 37 }, { 38, 37 }, { 39, 38 } } do c:put(q[1], q[2], SHELL[1], t2) end
c:put(37, 38, "#ead6a4", t2) c:put(36, 38, SHELL[2], t2)

-- quirk: dewdrop on the left sprout leaf
local dtok = { r = { name = "dew" } }
c:put(26, 16, WATER[2], dtok) c:put(27, 16, WATER[1], dtok) c:put(26, 17, WATER[1], dtok) c:put(27, 17, WATER[1], dtok)
c:put(26, 15, WATER[3], dtok)

A.save(c, "ph", NAME)
