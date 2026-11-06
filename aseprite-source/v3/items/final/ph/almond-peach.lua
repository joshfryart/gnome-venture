-- almond-peach (final, Opus). A slim, almond-shaped peach (round shoulder, soft beak at the bottom) on a short twig
-- with two long serrated peach leaves. The velvet skin is lit per pixel (6-tone gold-orange + 6-tone rose blush that
-- frays into speckles), with a fuzz of pale bloom specks, one soft specular on the shoulder, cool reflected light on
-- the lower right and a sunken stem cavity in AO. The suture crease runs down the front and has split open near the
-- beak, showing creamy flesh and the pitted, almond-shaped stone inside (the "almond" in the name).
-- quirk: a tiny ladybird walking along the long leaf.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "almond-peach"
local c = A.new(NAME)

local PEACH = { "#7a3530", "#b5552f", "#e2843a", "#f6a94a", "#ffc96e", "#ffe6a2" }
local BLUSH = { "#561c38", "#8c2640", "#c43c4a", "#e65f56", "#fb8a6c", "#ffb894" }
local LEAF  = { "#163c36", "#205640", "#2c7446", "#43934c", "#68b356", "#9ccf6c" }
local WOOD  = { "#3e2422", "#5e3a2a", "#86562f", "#b07a46" }
local STONE = { "#3a1f1e", "#5c3326", "#80492e", "#a3683e", "#c48a56", "#e0b27a" }
local FLESH = { "#e8a450", "#f9cf74", "#ffeaa8" }
local BOUNCE, SPEC = "#c48aa6", "#fff4d6"

-- leaves first (the fruit shoulder overlaps their bases)
local ltok = { r = { name = "leaf" } }
local leafL = A.leaf(c, 33, 19, 45, 8, 57, 12, 4.2, LEAF, { tok = ltok, teeth = 2.4, amb = 0.22 })
local leafS = A.leaf(c, 30, 19, 24, 11, 14, 12, 3.0, LEAF, { tok = ltok, teeth = 2.4, cut = leafL, amb = 0.22 })

-- twig: short woody stem with a node ring
local wtok = { r = { name = "twig" } }
local tw = A.stem(c, { { 31, 26 }, { 31, 22 }, { 32, 19 }, { 34, 15 } }, function(t) return 1.35 - 0.3 * t end, WOOD, { tok = wtok })
c:put(32, 19, WOOD[1], wtok) c:put(31, 20, WOOD[2], wtok)
c:put(34, 15, WOOD[4], wtok)

-- fruit body: almond outline, blunt top, soft beak bottom-right
local ax, ay = A.norm(0.26, 0.97, 0)
local body, bn0 = A.almond(31, 39, ax, ay, 17.4, 11.8, 0.85)
local bn = A.body(body, 29, 36, 13, 6, 0.55)
local bias = {}
-- stem cavity AO
local cav = c:ellipse(31, 24, 3, 1)
X.ao(bias, body, cav, 2, -1)
local v = X.light(bn, { amb = 0.06, wrap = 0.2 })
-- blush region (pigment on the sunny upper-left / top), frayed edge + speckles
local blush, gold = HP.mask(), HP.mask()
body:each(function(x, y)
  local f = -(x - 31) * 0.6 - (y - 38) * 0.8 + (X.hash(x, y, 3) - 0.5) * 5
  local isB = f > 1
  if not isB and f > -6 and X.hash(x, y, 9) > 0.8 then isB = true end
  if isB then blush:set(x, y) else gold:set(x, y) end
end)
-- fuzz: pale specks on lit skin, dark specks on shade
local fz = {}
body:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 21)
  if v[k] > 0.62 and h > 0.86 then fz[k] = 1 elseif v[k] < 0.4 and h > 0.9 then fz[k] = -1 end
  if bias[k] then fz[k] = (fz[k] or 0) + bias[k] end
end)
local btok, gtok = { r = { name = "blush" } }, { r = { name = "peach" } }
local cutsB = { 0.14, 0.3, 0.5, 0.7, 0.86 }
local bidx = X.tone(c, blush, v, BLUSH, { cuts = cutsB, bias = fz, tok = btok })
local gidx = X.tone(c, gold, v, PEACH, { cuts = { 0.12, 0.27, 0.42, 0.58, 0.76 }, bias = fz, tok = gtok })

-- suture: crease from cavity down the front to the beak; dark groove, lit lip on the left
local sut = { { 30, 25 }, { 25, 34 }, { 27, 47 }, { 37, 55 } }
local groove = {}
for i = 0, 120 do local t = i / 120
  local x, y = A.bez(sut, t)
  local xi, yi = floor(x + .5), floor(y + .5)
  groove[K(xi, yi)] = t
end
for k, t in pairs(groove) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  if body:has(x, y) and t > 0.03 and t < 0.97 then
    local isB = blush:has(x, y)
    local idx = isB and bidx or gidx
    local R = isB and BLUSH or PEACH
    local i = max(1, (idx[k] or 3) - 2)
    c:put(x, y, R[i], isB and btok or gtok)
    -- lit lip one px left
    local lk = K(x - 1, y)
    if body:has(x - 1, y) and not groove[lk] and t < 0.55 then
      local li = min(6, ((isB and bidx or gidx)[lk] or 3) + 1)
      c:put(x - 1, y, R[li], isB and btok or gtok)
    end
  end
end

-- the split: a lens opening on the suture near the beak, flesh rim + pitted stone inside
local split = HP.mask()
for i = 0, 100 do local t = 0.55 + 0.33 * i / 100
  local x, y = A.bez(sut, t)
  local w = 2.3 * sin(pi * (t - 0.55) / 0.33) ^ 0.8
  for dx = -3, 3 do
    if abs(dx) <= w then split:set(floor(x + dx + 0.5), floor(y + .5)) end
  end
end
split:clip(body:copy():shrink(1))
local inside = split:copy():shrink(1)
local rim = split:copy():cut(inside)
rim:each(function(x, y)
  -- flesh rim: lit upper-left part pale, lower-right deeper
  local nb = (x - 30) + (y - 49)
  c:put(x, y, nb < -1 and FLESH[3] or (nb < 4 and FLESH[2] or FLESH[1]), gtok)
end)
local stok = { r = { name = "stone" } }
inside:each(function(x, y)
  local i = 3
  local h = X.hash(x, y, 33)
  if h > 0.66 then i = 1 elseif h > 0.4 then i = 2 elseif h < 0.12 then i = 4 end
  if not inside:has(x - 1, y - 1) then i = i + 1 end
  c:put(x, y, STONE[max(1, min(6, i))], stok)
end)
-- AO under the split lip (contact shadow on the skin below-right)
split:shift(1, 1):each(function(x, y) if body:has(x, y) and not split:has(x, y) then
  local k = K(x, y)
  if blush:has(x, y) then c:put(x, y, BLUSH[max(1, (bidx[k] or 3) - 1)], btok) else c:put(x, y, PEACH[max(1, (gidx[k] or 3) - 1)], gtok) end end end)

-- cool reflected light lower-right
local rim2 = X.rim(bn)
body:edge():each(function(x, y) local k = K(x, y)
  if rim2[k] > 0.72 and not split:has(x, y) and y > 36 then c:put(x, y, BOUNCE, gtok) end end)
-- stem cavity: dark dimple
for _, p in ipairs{ { 29, 25, 1 }, { 30, 25, 1 }, { 31, 25, 1 }, { 32, 25, 2 }, { 33, 25, 2 }, { 30, 26, 2 }, { 31, 26, 2 } } do
  c:put(p[1], p[2], BLUSH[p[3]], btok) end
-- soft specular on the shoulder (velvet: one 2x1 + a pale halo pixel)
c:put(21, 31, SPEC, btok) c:put(22, 31, SPEC, btok) c:put(21, 32, BLUSH[6], btok) c:put(23, 30, BLUSH[6], btok)

-- quirk: ladybird on the long leaf
local lb = { { 47, 9, "#c43c4a" }, { 48, 9, "#e65f56" }, { 49, 9, "#c43c4a" }, { 47, 10, "#8c2640" }, { 48, 10, "#2b1c26" }, { 49, 10, "#8c2640" }, { 50, 10, "#2b1c26" } }
for _, p in ipairs(lb) do c:put(p[1], p[2], p[3], ltok) end
c:put(48, 8, "#2b1c26", ltok)

A.save(c, NAME)
