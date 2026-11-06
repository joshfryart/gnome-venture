-- kohlrabi (final pass, Opus single pass). A purple kohlrabi bulb (squat sphere, 6-tone violet ramp, waxy grey-lilac
-- bloom speckle on the lit shoulder, cream specular, cool blue reflected light on the shade side) with four slim
-- purple petioles springing straight out of the bulb's shoulders, each with a pale leaf-scar crescent and AO at its
-- foot, ending in blue-green glaucous ovate leaves (wavy margin, pale midrib, pinnate veins). Two old healed leaf scars
-- low on the bulb, and a thin pale taproot with a side hair.
-- quirk: one leaf has a round bite out of its edge, and the culprit (a tiny green caterpillar) sits beside it.
local NAME = "kohlrabi"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local PUR = { "#2c1846", "#46266a", "#62358e", "#8048b0", "#a574d0", "#cba8ea" }
local BLOOM, BOUNCE, SCAR = "#b8a6d6", "#5d6cae", "#d9c6ee"
local PET = { "#3a2058", "#5a3482", "#7a4ca8", "#9c70c8", "#c09ce0" }
local LEAF = { "#1c3640", "#28524e", "#3a705e", "#55906a", "#7fb27c", "#b2d4a0" }
local ROOT = { "#7a5a48", "#a8866a", "#d0b490", "#ecdcbc" }
local CUTS = A.CUTS

-- bulb
local BX, BY, BR = 32, 40, 10.5
local bm = A.oval(BX, BY, 11.2, 10.0, 0, 1)
local bn = X.sphere(BX - 0.3, BY - 0.6, 11, bm)

-- taproot (behind the bulb)
local rtok = { r = { name = "root" } }
local rm, rn = A.tube({ { 32, 49 }, { 33, 52 }, { 31, 54 }, { 29, 56 } }, function(t) return 1.3 * (1 - t) + 0.25 end)
rm:cut(bm)
X.tone(c, rm, X.light(rn, { amb = 0.15, wrap = 0.3 }), ROOT, { cuts = { 0.3, 0.55, 0.8 }, tok = rtok })
for _, q in ipairs{ { 34, 53 }, { 35, 54 } } do c:put(q[1], q[2], ROOT[2], rtok) end

local btok = { r = { name = "bulb" } }
local bias = {}
-- petioles: base on the bulb shoulder, then out and up to the leaf
local pets = {
  { { 26, 33 }, { 23, 28 }, { 19, 25 }, { 16, 22 } },
  { { 30, 31 }, { 29, 25 }, { 27, 20 }, { 26, 16 } },
  { { 35, 31 }, { 36, 25 }, { 38, 20 }, { 40, 16 } },
  { { 39, 34 }, { 43, 30 }, { 46, 28 }, { 49, 25 } },
}
local blades = {
  { 16, 22, 11, 17, 9, 9 },
  { 26, 16, 25, 11, 21, 5 },
  { 40, 16, 43, 11, 44, 5 },
  { 49, 25, 54, 21, 57, 14 },
}
local pmask = HP.mask()
local pm, pn = {}, {}
for i, p in ipairs(pets) do
  pm[i], pn[i] = A.tube(p, function(t) return t < 0.12 and 1.5 - t * 3 or 1.0 - t * 0.25 end)
  pmask:add(pm[i])
end
X.ao(bias, bm, pmask, 1, -1)
local bidx = A.shade(c, bm, bn, PUR, { bias = bias, tok = btok, amb = 0.05, wrap = 0.2, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
-- cool reflected light lower-right rim, waxy bloom speckle on the lit shoulder, specular
bm:edge():each(function(x, y) local dx, dy = x - BX, y - BY
  if dx + dy > 6 and dy > 1 and dx > 0 then c:put(x, y, BOUNCE, btok) end end)
bm:each(function(x, y) local k = K(x, y) local dx, dy = x - BX, y - BY
  local i = bidx[k] or 1
  if i >= 4 and not bias[k] and (x * 7 + y * 13) % 11 == 0 then c:put(x, y, BLOOM, btok) end
  if i == 3 and (x * 5 + y * 3) % 13 == 0 and dy > 0 then c:put(x, y, PUR[4], btok) end
end)
c:put(26, 36, "#fff4d6", btok) c:put(27, 36, "#fff4d6", btok) c:put(26, 37, PUR[6], btok)
-- healed old leaf scars low on the bulb: pale crescent over a dark notch
for _, s in ipairs{ { 25, 43 }, { 37, 45 }, { 33, 47 } } do
  c:put(s[1], s[2], PUR[2], btok) c:put(s[1] + 1, s[2], PUR[2], btok)
  c:put(s[1] - 1, s[2] - 1, SCAR, btok) c:put(s[1], s[2] - 1, SCAR, btok) c:put(s[1] + 1, s[2] - 1, PUR[5], btok)
end

-- leaves (behind petioles)
local ltok = { r = { name = "leaf" } }
local leafM = {}
for i, b in ipairs(blades) do
  local m, n, T, S, len = A.blade(b[1], b[2], b[3], b[4], b[5], b[6], function(t)
    if t > 0.985 then return -1 end
    local w = 4.4 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.75
    return max(0.5, w * (1 + 0.1 * sin(t * 26 + i)))
  end, { fold = 0.4 })
  if i == 4 then -- quirk: bite out of the upper edge
    local bite = HP.ellipse(54, 16, 2, 2)
    m:cut(bite)
  end
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.13 and t > 0.03 and t < 0.88 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
    local ph = (t * len - abs(s) * 3.2) / 3.4
    local f = abs((ph - floor(ph)) - 0.5) * 2
    if f > 0.82 and abs(s) > 0.2 and abs(s) < 0.78 and t > 0.12 and t < 0.86 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
  end)
  leafM[i] = m
end

-- petioles over the leaves and bulb
local ptok = { r = { name = "petiole" } }
for i = 1, #pets do
  local m = pm[i]:copy()
  X.tone(c, m, X.light(pn[i], { amb = 0.12, wrap = 0.3 }), PET, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = ptok })
  -- leaf scar crescent at the foot (pale lilac under the stalk)
  local p = pets[i][1]
  c:put(p[1] - 1, p[2] + 2, SCAR, btok) c:put(p[1], p[2] + 2, SCAR, btok) c:put(p[1] + 1, p[2] + 2, PUR[5], btok)
end

-- caterpillar beside the bite: 4 round segments, head with eye
local ctok = { r = { name = "cat" } }
for i, q in ipairs{ { 50, 19, "#9ad05a" }, { 51, 19, "#7cbc48" }, { 52, 18, "#9ad05a" }, { 53, 18, "#7cbc48" } } do
  c:put(q[1], q[2], q[3], ctok) c:put(q[1], q[2] + 1, "#4e8a3a", ctok)
end
c:put(54, 18, "#c8ea7a", ctok) c:put(54, 19, "#2b1c26", ctok)

A.save(c, NAME)
