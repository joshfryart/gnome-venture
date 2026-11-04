-- lavender-border-tee (final, Opus single pass). T-junction of lavender beds in 3/4 view: a run across the back and a
-- branch coming toward the viewer, all in one stone-kerbed bed. Back mounds first, branch mounds stacked in front.
-- Material: bevelled kerb blocks, crumbly soil with contact shadow, needle-leaf mounds, whorled violet spikes.
-- quirk: someone left a hand trowel lying on the path (wood handle with grain, gold ferrule, bevelled steel blade).
local NAME = "lavender-border-tee"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local c = A.new(NAME)
local soil = c:rect(9, 24, 54, 28):add(c:rect(27, 24, 36, 50))
local bed = A.bed(c, soil, { fh = 4, seed = 11 })
local bushes = {
  { 15, 28, 6, 6, { { -3, -3, 13, 6 }, { 0, 0, 17, 7 }, { 3, 3, 14, 6 } }, 21 },
  { 25, 28, 5, 6, { { -2, -2, 15, 7 }, { 1, 2, 18, 7 } }, 22 },
  { 39, 28, 5, 6, { { -1, -2, 17, 7 }, { 2, 3, 14, 6 } }, 23 },
  { 49, 28, 6, 6, { { -3, -3, 15, 6 }, { 0, 1, 18, 7 }, { 3, 4, 13, 6 } }, 24 },
  { 32, 38, 5, 6, { { -3, -4, 13, 6 }, { 0, 0, 16, 7 }, { 3, 4, 12, 6 } }, 25 },
  { 32, 49, 5, 6, { { -3, -4, 12, 6 }, { 0, 0, 15, 7 }, { 3, 4, 11, 6 } }, 26 },
}
for _, b in ipairs(bushes) do local m = A.bush(c, b[1], b[2], b[3], b[4], b[5], b[6]) A.contact(c, bed, m) end
A.refront(c, bed)

-- quirk: trowel lying on the ground at lower right (handle upper-left, blade lower-right)
local W, ST, P = A.WOOD, A.STONE, A.P
local htok, btok = { r = { name = "handle" } }, { r = { name = "blade" } }
local hm, hn, HT, HS = X.cyl(43, 38, 48.5, 43.5, function(t) return 1.3 end)
local hidx = A.shade(c, hm, hn, W, { tok = htok })
hm:each(function(x, y) local k = K(x, y) if abs(HS[k]) < 0.35 and A.h(x, y, 5) < 0.4 then c:put(x, y, W[max(1, hidx[k] - 1)], htok) end end)
c:put(43, 38, W[6], htok) c:put(42, 37, W[5], htok)                                   -- pale end grain
local fm = X.cyl(48.5, 43.5, 50.5, 45.5, function(t) return 1.5 end)
fm:each(function(x, y) local i = (x + y < 93) and P.gold.hi or ((x + y > 94) and P.gold.shade or P.gold.base) c:put(x, y, i, htok) end)
local bm, bn = A.oval(54, 49.5, 4.6, 2.6, math.pi / 4, 0.5)
bm:cut(fm)
local bv = X.light(bn, { amb = 0.08, wrap = 0.3 })
local bidx = X.tone(c, bm, bv, ST, { cuts = A.CUTS, tok = btok })
-- crease along the blade's spine, bright upper-left edge, specular
for t = 0, 7 do local x, y = 51 + t, 46 + t if bm:has(x, y) then c:put(x, y, ST[2], btok) if bm:has(x - 1, y) then c:put(x - 1, y, ST[5], btok) end end end
bm:edge():each(function(x, y) if x - y > 4 and not bm:has(x, y - 1) then c:put(x, y, ST[6], btok) end end)
c:put(54, 47, A.CREAM, btok)
-- dirt crumbs on the blade tip
c:put(56, 53, A.SOIL[3], btok) c:put(57, 52, A.SOIL[4], btok)
A.save(c, NAME)
