-- broken-compost-scoop (aB11_0, Opus single pass). A galvanised flour-style scoop lying on its side: an obliquely cut
-- tube heaped with crumbly compost, brass ferrule, slim ash handle with a round knob. Material: per-pixel cylinder light
-- (6-tone cool steel), rolled bright rim, specular streak, rivets, wood grain, AO where the parts meet.
-- broken: a torn split runs down from the lip (real gap), a steel chip flies off and compost crumbs spill out.
-- quirk: a pink worm curls up out of the heap.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.start("broken-compost-scoop")
local S, W, B, SO = A.GALV, A.WOOD, A.BRASS, A.SOIL

-- handle (behind the cup's back end)
local hm, hn, HT, HS = X.cyl(38, 32, 53, 32, function(t) return 1.6 + t * 0.3 end)
local hb = {}
hm:each(function(x, y) if x <= 41 then hb[K(x, y)] = -1 end end)
local hidx = A.toneN(c, hm, hn, W, { bias = hb })
A.grain(c, hm, HT, HS, 15, W, 3, hidx)
-- knob
local km = c:ellipse(54, 32, 2.5, 3)
local kn = X.sphere(53.6, 31.4, 3, km)
A.toneN(c, km, kn, W, { tok = { r = { name = "knob" } } })
c:px(53, 30, W[6])
-- brass ferrule
local fm, fn = X.cyl(36, 32, 40, 32, function() return 2.6 end)
A.toneN(c, fm, fn, B)
for y = 30, 34 do c:px(39, y, B[2]) end
c:px(37, 30, B[6])

-- cup: horizontal tube, cut obliquely at the front
local function cutY(x) return 35 - (x - 9) * (13 / 27) end
local bm, bn, BT, BS = X.cyl(8, 32, 36, 32, function(t) return 9.6 end)
local cut = HP.mask()
bm:each(function(x, y) if y + 0.5 < cutY(x + 0.5) then cut:set(x, y) end end)
bm:cut(cut)
local bb = {}
X.ao(bb, bm, fm, 2, -1)
local bidx = A.toneN(c, bm, bn, S, { bias = bb, amb = 0.1 })
-- rolled back bead + seam
bm:each(function(x, y)
  if x == 34 then c:px(x, y, S[max(1, (bidx[K(x, y)] or 3) - 2)]) end
  if x == 33 then c:px(x, y, S[min(6, (bidx[K(x, y)] or 3) + 1)]) end
end)
-- specular streak on the lit upper flank
for x = 12, 31 do
  local y = 26
  if bm:has(x, y) and x % 7 ~= 0 then c:px(x, y, S[6]) end
end
c:px(22, 27, A.CREAM) c:px(23, 27, A.CREAM)
-- rivets near the back
for _, p in ipairs{ { 31, 28 }, { 31, 36 } } do c:px(p[1], p[2], S[1]) c:px(p[1] - 1, p[2] - 1, S[6]) end

-- mouth: an ellipse along the cut, inner wall dark
local ux, uy = 27, -13
local l = math.sqrt(ux * ux + uy * uy) ux, uy = ux / l, uy / l
local mouth = A.frame(22.5, 28.6, ux, uy, function(a, b) return (a / 14.6) ^ 2 + (b / 3.4) ^ 2 <= 1 end, 18)
mouth:each(function(x, y) c:px(x, y, S[2]) end)
local medge = mouth:edge()
medge:each(function(x, y)
  -- near (lower) half of the rim is bright, far half is darker
  if y + 0.5 >= cutY(x + 0.5) - 0.4 then c:px(x, y, S[6]) else c:px(x, y, S[4]) end
end)
-- compost heap: fills the mouth and mounds above it
local heap = mouth:copy():shrink(1)
heap:add(c:ellipse(21, 25.5, 10, 3.6))
heap:cut(medge)
local hpb = {}
local hn2 = X.pillow(heap, 2.5)
local sidx = A.toneN(c, heap, hn2, SO, { bias = hpb, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
heap:each(function(x, y)
  local h = X.hash(x, y, 11)
  local i = sidx[K(x, y)] or 3
  if h > 0.8 then c:px(x, y, SO[min(6, i + 1)]) elseif h < 0.18 then c:px(x, y, SO[max(1, i - 1)]) end
end)
-- bits in the compost: straw, eggshell, a green scrap
c:px(14, 27, "#d8b060") c:px(15, 27, "#a8803c")
c:px(27, 24, "#f2e6c8") c:px(28, 24, "#c8b898")
c:px(18, 23, "#7cc35a") c:px(19, 23, "#3f9150")
-- quirk: worm curling up out of the heap
A.map(c, 22, 19, {
  ".pP.",
  "p..P",
  "...d",
  "..dd",
}, { p = A.PINK[4], P = A.PINK[3], d = A.PINK[2] })
c:px(23, 18, A.PINK[3])

-- broken: torn split down from the lip, flap edge lit, far edge dark
local gapPts = { { 18, 31 }, { 20, 34 }, { 19, 37 }, { 21, 40 } }
A.gap(c, gapPts, 1)
for _, p in ipairs{ { 17, 32 }, { 18, 34 }, { 18, 36 }, { 19, 38 } } do if bm:has(p[1], p[2]) then c:px(p[1], p[2], S[6]) end end
for _, p in ipairs{ { 20, 32 }, { 21, 35 }, { 20, 37 }, { 22, 39 } } do if bm:has(p[1], p[2]) then c:px(p[1], p[2], S[1]) end end
-- crumbs spilling from the split
A.map(c, 19, 44, { "ab", "bb" }, { a = SO[5], b = SO[3] })
A.map(c, 22, 47, { "ab" }, { a = SO[4], b = SO[2] })
-- flying steel chip
A.map(c, 6, 41, {
  "ab.",
  "bcd",
}, { a = S[6], b = S[4], c = S[3], d = S[2] })
A.save(c, "broken-compost-scoop")
