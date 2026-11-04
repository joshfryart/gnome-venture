-- lychee (aC21_4, Opus single pass). Two lychees hanging from a slim forked woody twig with one glossy lanceolate
-- leaflet. Big fruit: slightly heart-shaped, crimson shell of polygonal tubercles (each bump lit upper-left, dark
-- creases between, a pale point on lit bumps), one bright specular, cool reflected light lower right, dark stalk cavity.
-- Small fruit: half peeled, the shell torn back to a pale inner membrane rim, glossy translucent white aril inside.
-- quirk: a bead of juice drips off the peeled fruit.
local NAME = "lychee"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local RED = { "#4e1028", "#7c1830", "#ad2338", "#d63c44", "#ef6a5c", "#ff9f86" }
local TIP, COOL = "#ffc6a8", "#7a3a6a"
local FLESH = { "#8e98a8", "#b4bec6", "#d4dcda", "#e8eee6", "#f6f8ee", "#fffdf2" }
local PITH = "#f4c8b4"
local WOOD = { "#3e2622", "#5e3a2a", "#84583a", "#a87a50", "#c8a070" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local tw, lt = { r = { name = "twig" } }, { r = { name = "leaf" } }

-- leaf (behind twig)
A.leaf(c, 37, 14, 28, 9, 16, 13, 3.2, { ramp = LEAF, tok = lt, veins = true, vein = "#c2e48c", per = 3.0 })

-- twig: main + two stalks
local function stalk(p, w, a)
  local m, n = A.tube(p, function(t) return w * (1 - 0.25 * t) end)
  X.tone(c, m, X.light(n, { amb = 0.15, wrap = 0.3 }), WOOD, { cuts = { 0.22, 0.42, 0.62, 0.82 }, tok = tw })
  return m
end
local sm = stalk({ { 39, 9 }, { 38, 13 }, { 36, 17 }, { 34, 21 } }, 1.3)
local s1 = stalk({ { 34, 21 }, { 31, 23 }, { 29, 25 }, { 28, 29 } }, 0.95)
local s2 = stalk({ { 34, 21 }, { 40, 24 }, { 46, 30 }, { 48, 39 } }, 0.95)
-- leaf node bump + bark notch
c:put(37, 14, WOOD[2], tw) c:put(38, 11, WOOD[5], tw) c:put(33, 21, WOOD[2], tw)

-- fruit skin painter
local function fruit(cx, cy, rx, ry, seed, keep)
  local m, n, U = A.egg(cx, cy, rx, ry, 0.2)
  local bb = { cx - rx, cy - ry, cx + rx, cy + ry }
  local P = A.cells(bb[1], bb[2], bb[3], bb[4], 3.7, 1.4, seed)
  local nb, cr, tip = A.bumpy(m, n, P, 0.22, 0.85)
  local vis = m:copy() if keep then vis:clip(keep) end
  local tok = { r = { name = "fruit" .. seed } }
  local v = X.light(nb, { amb = 0.1, wrap = 0.28 })
  local bias = {}
  vis:each(function(x, y) local k = K(x, y)
    if cr[k] then bias[k] = (U[k][3] > 0.8) and -1 or -2 end
  end)
  local idx = X.tone(c, vis, v, RED, { cuts = { 0.16, 0.3, 0.45, 0.6, 0.78 }, bias = bias, tok = tok })
  local rim = X.rim(n)
  vis:each(function(x, y) local k = K(x, y)
    if tip[k] and not cr[k] and idx[k] >= 5 then c:put(x, y, TIP, tok)
    elseif tip[k] and not cr[k] and idx[k] == 4 then c:put(x, y, RED[5], tok) end
    if U[k][3] > 0.7 and rim[k] > 0.55 and idx[k] <= 3 and not cr[k] then c:put(x, y, COOL, tok) end
  end)
  return m, n, tok, idx
end

-- big fruit
local m1, n1, t1 = fruit(27, 40, 12, 12, 3)
-- stalk cavity + shoulder AO
for _, q in ipairs{ { 27, 28, 1 }, { 28, 28, 1 }, { 26, 29, 2 }, { 27, 29, 1 }, { 28, 29, 1 }, { 29, 29, 2 } } do c:put(q[1], q[2], RED[q[3]], t1) end
c:put(28, 27, WOOD[3], tw)
-- specular: 2x1 cream + hi
local gx, gy = A.specAt(m1, n1, 30)
c:put(gx, gy, A.CREAM, t1) c:put(gx + 1, gy, A.CREAM, t1) c:put(gx, gy + 1, RED[6], t1)

-- small fruit, peeled on the lower-right
local cx2, cy2 = 49, 47
local m2, n2, U2 = A.egg(cx2, cy2, 7.5, 8, 0.15)
local fl = HP.mask()
m2:each(function(x, y)
  local d = (x - cx2) * 0.62 + (y - cy2) * 0.78
  local j = (X.hash(floor((x - y) / 2), 3, 5) - 0.5) * 1.6
  if d > -0.5 + j then fl:set(x, y) end
end)
local shell = m2:copy():cut(fl)
local _, _, t2 = fruit(cx2, cy2, 7.5, 8, 11, shell)
-- aril: glossy, translucent (darker toward the shade side, cool core)
local ftok = { r = { name = "aril" } }
local fn = {}
fl:each(function(x, y) local k = K(x, y) local b = n2[k] fn[k] = { A.norm(b[1] * 0.85, b[2] * 0.85, b[3] * 1.1) } end)
local fidx = X.tone(c, fl, X.light(fn, { amb = 0.2, wrap = 0.35 }), FLESH, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }, tok = ftok })
-- membrane rim where shell meets aril
local rim = HP.mask()
fl:each(function(x, y) if shell:has(x - 1, y) or shell:has(x, y - 1) then rim:set(x, y) end end)
rim:each(function(x, y) c:put(x, y, PITH, ftok) end)
-- aril AO under the rim, faint vertical juice streaks, glossy specular
rim:shift(1, 1):each(function(x, y) if fl:has(x, y) and not rim:has(x, y) then
  local i = fidx[K(x, y)] or 3 c:put(x, y, FLESH[max(1, i - 1)], ftok) end end)
local fx, fy = A.specAt(fl:copy():cut(rim):shrink(1), fn, 25)
if fx then c:put(fx, fy, A.CREAM, ftok) c:put(fx, fy + 1, FLESH[6], ftok) end
-- stalk end over the small fruit's shoulder
c:put(48, 39, WOOD[2], tw) c:put(48, 40, RED[1], t2)
-- contact shadow from the stalk on the big fruit shoulder: none needed (air). Ambient row where s1 meets fruit 1
c:put(28, 28, RED[1], t1)

-- quirk: juice drip off the bottom of the aril
local dtok = { r = { name = "drip" } }
local bx, by = 0, -1
fl:each(function(x, y) if y > by or (y == by and x < bx) then bx, by = x, y end end)
c:put(bx, by + 1, FLESH[4], dtok)
c:put(bx, by + 2, FLESH[5], dtok) c:put(bx + 1, by + 2, FLESH[3], dtok)
c:put(bx, by + 3, FLESH[3], dtok) c:put(bx + 1, by + 3, FLESH[2], dtok)
c:put(bx, by + 2, A.CREAM, dtok)

A.save2(c, NAME)
