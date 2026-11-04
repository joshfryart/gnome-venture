-- lime (final, Opus single pass). A slightly oval Persian lime lying on the diagonal: stem button at the upper-left pole,
-- a little blossom nipple at the lower-right pole, dimpled peel with oil-gland pores, waxy bloom on the lit shoulder,
-- one bright specular, cool reflected light on the shade side, 2-tone ground shadow. One lime leaf on a winged petiole.
-- quirk: a single bead of juice hangs from the nipple, about to drop.
local NAME = "lime"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LIME = { "#1d4a2c", "#2b6a2f", "#3f8c2f", "#62ad35", "#8ccb48", "#bfe46a" }
local LEAF = A.LEAF
local DROP = { "#3f8c5a", "#7cc07a", "#c4ecb0", "#effbe0" }

local CX, CY, RX, RY, ANG = 30, 34, 16.5, 13.8, 0.33
local ca, sa = cos(ANG), sin(ANG)
c:groundShadow(32, 49, 16, 2)

-- body + nipple
local bm, bn = A.oval(CX, CY, RX, RY, ANG, 1)
local nx, ny = CX + (RX + 0.6) * ca, CY + (RX + 0.6) * sa
local nm = A.rell(nx, ny, ca, sa, 2.2, 1.9)
nm:cut(bm)
local btok = { r = { name = "lime" } }
local bias = {}
-- stem-end dimple: AO ring around the button
local sx, sy = CX - (RX - 1.2) * ca, CY - (RX - 1.2) * sa
bm:each(function(x, y) local d = (x - sx)^2 + (y - sy)^2 if d < 6.5 and d > 1.5 then bias[K(x, y)] = -1 end end)
local idx = X.tone(c, bm, X.light(bn, { amb = 0.05, wrap = 0.22 }), LIME, { cuts = { 0.14, 0.3, 0.46, 0.63, 0.82 }, bias = bias, tok = btok })
-- dimpled peel: pores darker by one tone in the lit half, a few pale oil glands
bm:each(function(x, y) local k = K(x, y) local i = idx[k]
  local h = X.hash(x, y, 11)
  if i >= 3 and h > 0.86 and (x + y) % 2 == 0 then A.rp(c, x, y, LIME, i - 1, btok)
  elseif i >= 4 and h < 0.05 then A.rp(c, x, y, LIME, i + 1, btok) end
end)
-- waxy bloom: a pale cool-green band on the lit shoulder
bm:each(function(x, y) local k = K(x, y)
  local nn = bn[k]
  if idx[k] == 5 and nn[1] < -0.35 and nn[2] < -0.25 and X.hash(x, y, 5) > 0.45 then c:put(x, y, "#a9d88a", btok) end end)
-- cool reflected light on the lower-right rim
local rim = X.rim(bn)
bm:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.5 and idx[k] <= 2 then c:put(x, y, "#3f7d72", btok) end end)
-- nipple
X.tone(c, nm, X.light(X.sphere(nx - .4, ny - .4, 2, nm), { amb = 0.05, wrap = 0.2 }), LIME, { cuts = { 0.14, 0.3, 0.46, 0.63, 0.82 }, tok = btok })
c:put(floor(nx + 1.5), floor(ny + .5), LIME[1], btok)
-- AO crease where the nipple meets the body
nm:grow(1):each(function(x, y) if bm:has(x, y) and not nm:has(x, y) and (x - nx) * ca + (y - ny) * sa < 0 then
  local k = K(x, y) A.rp(c, x, y, LIME, idx[k] - 1, btok) end end)
-- specular: 2x1 + cream
local px, py = A.specAt(bm, bn, 28)
c:put(px, py, A.CREAM, btok) c:put(px + 1, py, LIME[6], btok) c:put(px, py + 1, LIME[6], btok)

-- leaf on a winged petiole from the stem button, sweeping up-right over the top
local ltok = { r = { name = "leaf" } }
local pm, pn, PT, PS = A.blade(16, 26, 18, 21, 22, 18, function(t) return 0.6 + t * 1.2 end, { fold = 0.2 })
pm:cut(bm)
A.shade(c, pm, pn, LEAF, { tok = ltok })
local lm, ln, LT, LS, len = A.blade(22, 18, 32, 6, 47, 12, function(t)
  if t > 0.985 then return -1 end
  return max(0.4, 5.0 * sin(pi * min(1, 0.1 + 0.9 * t)) ^ 0.7)
end, { fold = 0.42 })
local lb = {}
A.cast(lb, lm, pm, 1, 1, -1)
local lidx = A.shade(c, lm, ln, LEAF, { tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, bias = lb })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if abs(s) < 0.13 and t < 0.9 then c:put(x, y, s <= 0 and A.VEIN or LEAF[3], ltok) return end
  local ph = (t * len + abs(s) * 4.5) / 5.5 + (s > 0 and 0.5 or 0)
  local f = ph - floor(ph)
  if f < 0.14 and abs(s) > 0.16 and abs(s) < 0.75 and t > 0.06 and t < 0.86 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y) if LS[k] > 0.7 and LT[k] > 0.1 then c:put(x, y, A.COOL, ltok) end end)
-- leaf sheen glint
c:put(31, 10, A.CREAM, ltok)
-- stem button (brown, AO under it on the peel)
local stok = { r = { name = "stem" } }
for _, q in ipairs{ { 0, 0, "#5e3a2a" }, { 1, 0, "#84552f" }, { 0, -1, "#a87240" }, { -1, 0, "#3e2422" }, { 0, 1, "#3e2422" } } do
  c:put(floor(sx + .5) + q[1], floor(sy + .5) + q[2], q[3], stok) end

-- quirk: juice bead hanging off the nipple
local dtok = { r = { name = "drop" } }
local dx, dy = floor(nx + .5) + 1, floor(ny + .5) + 3
for _, q in ipairs{ { 0, 0, 2 }, { -1, 1, 2 }, { 0, 1, 3 }, { 1, 1, 1 }, { -1, 2, 2 }, { 0, 2, 2 }, { 1, 2, 1 }, { 0, 3, 1 } } do
  c:put(dx + q[1], dy + q[2], DROP[q[3]], dtok) end
c:put(dx - 1, dy + 1, DROP[4], dtok)

A.save(c, NAME)
