-- broken-bug-net (final, Opus single pass). A tilted steel hoop (bevel light, bright upper edge, one glint) with a
-- string-mesh bag drooping to the lower right (diamond lattice, lighter knots, dark interior seen through the
-- opening), on a slim wooden handle (grain, steel ferrule, twisted twine grip). Damage: a ragged hole torn in the
-- bag with frayed string ends and one strand dangling below, the handle split lengthwise with a splinter lifting
-- out, and a wood chip flying off.
-- quirk: a small blue butterfly flutters away from the hole it escaped through.
local NAME = "broken-bug-net"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local WOOD = { "#3d2224", "#5e3529", "#83502f", "#a86e3c", "#c99256", "#e8bb82" }
local STEEL = { "#2f3248", "#4c5068", "#71758e", "#9a9db2", "#c6c8d6", "#eef0f4" }
local NET = { "#34405a", "#56677e", "#7d92a2", "#a6bcc2", "#cde0da", "#eef6e8" }
local TW = { "#5e3f22", "#8f6a34", "#c49a52", "#e6c983" }
local HX, HY, RX, RY = 40, 17, 13, 9

-- net bag
local ntok = { r = { name = "net" } }
local open = HP.ellipse(HX, HY, RX - 2, RY - 2)
local bag = HP.ellipse(41, 28, 11, 11):add(HP.ellipse(45, 37, 6, 6)):add(HP.ellipse(43, 33, 9, 8))
bag:clip(HP.rect(0, HY, 63, 63)):add(open)
local hole = HP.poly{ { 41, 30 }, { 44, 28 }, { 46, 30 }, { 49, 29 }, { 48, 33 }, { 49, 36 }, { 45, 35 }, { 42, 37 }, { 41, 34 }, { 39, 33 } }
local bn = X.pillow(bag, 5)
local bb = {}
bag:each(function(x, y) local k = K(x, y)
  if open:has(x, y) then bb[k] = -3 end
  if hole:has(x, y) then bb[k] = -3 end
end)
local bidx = A.shade(c, bag, bn, NET, { tok = ntok, bias = bb, amb = 0.12, wrap = 0.3 })
bag:each(function(x, y) local k = K(x, y)
  local a, b = (x + y) % 4 == 0, (x - y) % 4 == 0
  local i = bidx[k]
  if hole:has(x, y) then
    c:put(x, y, ((a and b) and NET[2]) or A.INK, ntok)
  elseif open:has(x, y) then
    if a and b then c:put(x, y, NET[min(6, i + 2)], ntok) elseif a or b then c:put(x, y, NET[min(6, i + 1)], ntok) end
  else
    if a and b then c:put(x, y, NET[min(6, i + 2)], ntok)
    elseif a or b then c:put(x, y, NET[min(6, i + 1)], ntok)
    else c:put(x, y, NET[max(1, i - 1)], ntok) end
  end
end)
-- frayed string ends poking into the hole
for _, q in ipairs{ { 42, 30 }, { 43, 29 }, { 47, 30 }, { 48, 34 }, { 47, 35 }, { 40, 33 }, { 43, 36 } } do c:put(q[1], q[2], NET[5], ntok) end
c:put(44, 30, NET[4], ntok) c:put(46, 34, NET[4], ntok)
-- a torn strand dangling below the bag
for _, q in ipairs{ { 46, 44, 4 }, { 46, 45, 3 }, { 47, 46, 4 }, { 47, 47, 3 }, { 48, 48, 2 } } do c:put(q[1], q[2], NET[q[3]], ntok) end

-- hoop: steel ring, bevel from pillow normals
local htok = { r = { name = "hoop" } }
local ring = HP.ellipse(HX, HY, RX, RY):cut(open)
local rn = X.pillow(ring, 1.1)
local rb = {} ring:each(function(x, y) rb[K(x, y)] = -1 end)
local ridx = A.shade(c, ring, rn, STEEL, { tok = htok, bias = rb, amb = 0.1, wrap = 0.2 })
ring:edge():each(function(x, y) if open:has(x - 1, y) or open:has(x + 1, y) or open:has(x, y - 1) or open:has(x, y + 1) then c:put(x, y, STEEL[2], htok) end end)
-- upper rim bright edge, lower inside edge dark (the far side of the ring)
ring:each(function(x, y)
  local ang = math.atan(y - HY, x - HX)
  if y < HY - 4 and x < HX + 4 and not ring:has(x, y - 1) then c:put(x, y, STEEL[5], htok) end
  if y > HY + 3 and open:has(x, y - 1) then c:put(x, y, STEEL[2], htok) end
end)
c:put(31, 11, STEEL[6], htok) c:put(32, 10, STEEL[6], htok) c:put(30, 12, A.CREAM, htok)

-- handle
local wtok = { r = { name = "wood" } }
local hp = { { 31, 24 }, { 26, 33 }, { 20, 43 }, { 14, 54 } }
local hm, hn, HT, HS = A.tube(hp, function(t) return 1.7 end)
hm:cut(ring)
local hb = {}
hm:each(function(x, y) local k = K(x, y) if HT[k] < 0.14 then hb[k] = -1 end end)
local hidx = A.shade(c, hm, hn, WOOD, { tok = wtok, bias = hb, amb = 0.08, wrap = 0.22 })
-- grain: broken lines along the shaft
hm:each(function(x, y) local k = K(x, y)
  if HT[k] > 0.12 and abs(HS[k] - 0.2) < 0.14 and A.hash(floor(y / 2), x, 3) > 0.35 then A.step(c, hidx, WOOD, x, y, -1, wtok) end
end)
-- steel ferrule where the handle meets the hoop
local ftok = { r = { name = "ferrule" } }
hm:each(function(x, y) local k = K(x, y)
  if HT[k] < 0.1 then
    local s = HS[k]
    local i = s < -0.4 and 5 or (s < 0.2 and 4 or (s < 0.6 and 3 or 2))
    if HT[k] > 0.085 then i = 1 end
    c:put(x, y, STEEL[i], ftok)
  end
end)
-- twisted twine grip near the butt
local gtok = { r = { name = "twine" } }
local LEN = 34
hm:each(function(x, y) local k = K(x, y)
  local t, s = HT[k], HS[k]
  if t > 0.7 and t < 0.9 then
    local ph = (t * LEN + s * 2.2) % 2.6
    local i = ph < 0.9 and 1 or (s < -0.3 and 4 or (s < 0.4 and 3 or 2))
    c:put(x, y, TW[i], gtok)
  end
end)
-- pale end grain on the butt
c:put(14, 55, WOOD[6], wtok) c:put(13, 55, WOOD[5], wtok)

-- damage: lengthwise split with a splinter lifting out on the lit side
for _, q in ipairs{ { 24, 37 }, { 23, 38 }, { 23, 39 }, { 22, 40 }, { 22, 41 } } do c:put(q[1], q[2], WOOD[1], wtok) end
c:put(24, 38, WOOD[3], wtok)
local spl = HP.mask()
for _, q in ipairs{ { 21, 40, 6 }, { 20, 39, 5 }, { 19, 38, 5 }, { 18, 37, 4 } } do spl:set(q[1], q[2]) c:put(q[1], q[2], WOOD[q[3]], wtok) end
-- flying chip
A.map(c, 13, 33, { ".ab", "abc", "cd." }, { a = WOOD[6], b = WOOD[5], c = WOOD[4], d = WOOD[2] }, wtok)

-- quirk: a blue butterfly escaping up and away from the hole
local BF = { K = A.INK, B = "#3a86b0", b = "#7fd0e6", w = "#c4f0f4", p = "#2a4a7a" }
A.map(c, 52, 32, {
  "bB.Bb",
  "wbKbB",
  ".BKp.",
  ".p.p.",
}, BF, { r = { name = "fly" } })
A.save(c, NAME)
