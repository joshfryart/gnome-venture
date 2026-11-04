-- lungwort-seed (aC21_4, Opus single pass). Four small glossy near-black lungwort nutlets, each with its cream
-- elaiosome nub, scattered on a torn scrap of broad, bristly lungwort leaf (dark green splashed with silver spots,
-- pale midrib, side veins, pale hairs on the lit edge, cool rim, AO + contact shadow under each nutlet). One nutlet has
-- sprouted: slim stem, two round seed leaves and an upright elliptic first leaf already silver-spotted like the plant.
-- quirk: a tiny ant is hauling off a fifth nutlet by its elaiosome (lungwort seeds are ant-sown).
local NAME = "lungwort-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local LEAF = { "#14302a", "#1c4634", "#28603c", "#3a7c44", "#589a50", "#88be6a" }
local SPOT = { "#7aa894", "#a6ccb4", "#d4ecd6" }
local VEIN, COOL, FIBRE, HAIR = "#b4d690", "#3a5e6c", "#c4d89a", "#cfe6b8"
local NUT = { "#1c1418", "#2e2026", "#463038", "#5e4248", "#7e5c5c", "#a88078" }
local ELA = { "#bba878", "#e0d2a0", "#f6ecc4" }
local STEM = { "#4a6e44", "#76a060", "#a6c886", "#d6eab4" }
local ANT = { "#2e1a1c", "#5a2e28", "#8a4a3a", "#c07a5e" }
local ltok, stok, atok = { r = { name = "leaf" } }, { r = { name = "stem" } }, { r = { name = "ant" } }

-- nutlets: cx, cy, rx, ry, angle, elaiosome side (+1 = toward +u)
local nuts = { { 18, 50, 2.9, 2.0, 0.3, 1 }, { 25, 47, 2.9, 2.0, -0.5, -1 }, { 30, 51, 2.8, 2.0, 0.1, 1 }, { 37, 45, 2.9, 2.1, -1.2, 1 } }
local allN = HP.mask()
for _, s in ipairs(nuts) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7) allN:add(s.m) end
-- ant + carried nutlet masks (for leaf shadows)
local antM = HP.mask()
local abd, abn = A.oval(44, 49, 2.3, 1.7, -0.2, 0.7)
local hed, hen = A.oval(49.5, 47.5, 1.5, 1.3, 0, 0.8)
local cn, cnn = A.oval(53, 46, 1.9, 1.4, -0.6, 0.7)
antM:add(abd):add(hed):add(cn)

-- leaf scrap: broad elliptic lungwort leaf, tip torn away
local lm, ln, LT, LS, len = A.blade(8, 54, 30, 56, 56, 44, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 7.6 * sin(pi * min(1, t * 0.96 + 0.04)) ^ 0.55)
end, { fold = 0.3 })
local torn = A.tear(lm, 51, 57, 54, 39, 1.3, 9)
local bias = {}
X.ao(bias, lm, allN, 1, -1) A.cast(bias, lm, allN, 1, 2, -1)
A.cast(bias, lm, antM, 1, 1, -1)
local idx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
local P = A.cells(0, 36, 64, 64, 4.6, 2.2, 31)
local PER = 5.6
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local d1, _, ci = A.near2(P, x, y)
  if X.hash(ci, 1, 7) < 0.45 and d1 < 1.0 and abs(s) > 0.18 then
    local i = idx[k] or 3
    c:put(x, y, SPOT[i >= 5 and 3 or (i >= 3 and 2 or 1)], ltok) return
  end
  local f = ((t * len - abs(s) * 7) / PER) % 1
  if f < 0.1 and abs(s) > 0.15 and abs(s) < 0.8 and t < 0.9 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] or torn:has(x, y) then return end
  if LS[k] < -0.6 and X.hash(x, y, 4) < 0.5 then c:put(x, y, HAIR, ltok)
  elseif LS[k] > 0.62 then c:put(x, y, COOL, ltok) end
end)
torn:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, FIBRE, ltok) end end)
-- petiole stub
for _, q in ipairs{ { 8, 54, 2 }, { 7, 55, 3 }, { 6, 56, 3 } } do c:put(q[1], q[2], STEM[q[3]], ltok) end

-- sprout from the top nutlet
local sp = { { 37, 43 }, { 35, 37 }, { 39, 31 }, { 37, 24 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
sm:cut(nuts[4].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
for _, q in ipairs{ { 31, 32, 0.35 }, { 43.5, 30.5, -0.3 } } do
  local m, n = A.oval(q[1], q[2], 3.8, 2.3, q[3], 0.7)
  m:cut(sm)
  local b = {} X.ao(b, m, sm, 1, -1)
  A.toneN(c, m, n, LEAF, { tok = ltok, bias = b, cuts = { 0.12, 0.28, 0.44, 0.6, 0.8 }, amb = 0.14, wrap = 0.3 })
  local mx, my = q[1] + (q[1] < 37 and -1 or 1), q[2]
  c:put(floor(mx + .5), floor(my + .5), VEIN, ltok)
end
-- first true leaf: elliptic, spotted
local tm, TT, TS = A.leaf(c, 37, 26, 35, 19, 39, 12, 3.7, { ramp = LEAF, tok = ltok, veins = true, vein = VEIN, per = 3.4, cut = sm, pw = 0.55 })
local P2 = A.cells(30, 6, 46, 26, 3.4, 1.4, 41)
tm:each(function(x, y) local k = K(x, y)
  if abs(TS[k]) < 0.18 then return end
  local d1, _, ci = A.near2(P2, x, y)
  if X.hash(ci, 2, 7) < 0.55 and d1 < 0.8 then c:put(x, y, TS[k] < 0 and SPOT[3] or SPOT[1], ltok) end
end)
c:put(36, 27, LEAF[1], ltok) c:put(38, 27, LEAF[1], ltok)

-- nutlets: glossy dark coats, cream elaiosome at one end
local function nut(cx, cy, rx, ry, ang, side, m, n, tok)
  local i = A.toneN(c, m, n, NUT, { tok = tok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.82 }, amb = 0.1, wrap = 0.22 })
  local ca, sa = cos(ang), sin(ang)
  local ex, ey = cx + side * (rx + 0.3) * ca, cy + side * (rx + 0.3) * sa
  local e = HP.mask()
  for _, d in ipairs{ { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } } do e:set(floor(ex + d[1] - 0.5 + .5), floor(ey + d[2] - 0.5 + .5)) end
  e:each(function(x, y) c:put(x, y, (x + y) % 3 == 0 and ELA[3] or ((y > ey) and ELA[1] or ELA[2]), tok) end)
  local gx, gy = A.specAt(m, n, 40)
  c:put(gx, gy, A.CREAM, tok)
end
for i, s in ipairs(nuts) do nut(s[1], s[2], s[3], s[4], s[5], s[6], s.m, s.n, { r = { name = "nut" .. i } }) end

-- quirk: ant carrying a nutlet to the right
-- legs first (1px, dark), then body parts
for _, q in ipairs{ { 45, 51, 44, 53 }, { 47, 50, 47, 53 }, { 48, 50, 50, 52 }, { 46, 47, 45, 45 }, { 48, 47, 49, 45 } } do
  A.ln(c, q[1], q[2], q[3], q[4], ANT[1], atok) end
A.toneN(c, abd, abn, ANT, { tok = atok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.1 })
c:put(46, 48, ANT[2], atok) c:put(47, 48, ANT[2], atok) c:put(48, 48, ANT[3], atok)
A.toneN(c, hed, hen, ANT, { tok = atok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.1 })
c:put(50, 45, ANT[1], atok) c:put(51, 44, ANT[1], atok) -- antenna
local ab, bb = A.specAt(abd, abn, 30) c:put(ab, bb, ANT[4], atok)
nut(53, 46, 1.9, 1.4, -0.6, -1, cn, cnn, { r = { name = "carried" } })

A.save2(c, NAME)
