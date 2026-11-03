-- broken-seed-drill (aB12_2, Opus single pass). Side view hand seed drill: planked wooden hopper heaped with seeds,
-- brass drop tube down to a steel furrow shoe, small steel-tyred wheel, long ash push handle with a cross grip.
-- Material: plank grain + iron straps with rivets, brass tube bevel, tyre spec, AO where box, tube and wheel meet.
-- broken: the front plank split open (gap) with seeds trickling out, a spoke missing, a wood splinter flies.
-- quirk: a seed has already sprouted on the hopper rim.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_2.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new("broken-seed-drill")
local SEED = { "#5e3a2e", "#8a5638", "#b57850", "#d9a070", "#f0c890", "#fff4d6" }

c:groundShadow(28, 55, 22, 1)
local box = c:poly{ { 9, 15 }, { 37, 15 }, { 33, 33 }, { 13, 33 } }
-- handle (behind)
local hm = A.rod(c, 32, 26, 54, 9, 1.3, A.WOOD, { grain = 3 })
A.rod(c, 51, 6, 57, 12, 1.2, A.WOOD, { grain = 9 })
c:px(57, 12, A.WOOD[6])
-- drop tube + shoe
local tube = A.rod(c, 25, 32, 33, 50, 1.4, A.GOLD, { bias = {} })
local shoe = c:poly{ { 31, 48 }, { 36, 48 }, { 38, 53 }, { 33, 52 } }
A.lit(c, shoe, A.STEEL, { R = 1 })
-- wheel
local wo = A.wheel(c, 17, 45, 8, { spokes = 6, rot = 0.1, hub = 2, miss = 2, felloe = true })
-- hopper box
local bias = A.ao(box, { hm }, 1, -1)
local bi = A.lit(c, box, A.WOOD, { R = 2, bias = bias, wrap = 0.3 })
-- plank seams + grain
for _, y in ipairs{ 21, 27 } do box:each(function(x, yy) if yy == y then c:px(x, y, A.WOOD[2]) end end) end
box:each(function(x, y) if y ~= 21 and y ~= 27 and X.hash(x // 4, y, 7) > 0.8 and bi[K(x, y)] > 2 then c:px(x, y, A.WOOD[bi[K(x, y)] - 1]) end end)
-- iron corner straps + rivets
for y = 16, 32 do local xl = math.floor(9 + (y - 15) * 4 / 18 + 0.5) + 1
  c:px(xl, y, A.STEEL[4]) c:px(xl + 1, y, A.STEEL[3]) end
for y = 16, 32 do local xr = math.floor(37 - (y - 15) * 4 / 18 + 0.5) - 2
  c:px(xr, y, A.STEEL[3]) c:px(xr + 1, y, A.STEEL[2]) end
for _, y in ipairs{ 18, 24, 30 } do A.rivet(c, math.floor(9 + (y - 15) * 4 / 18 + 0.5) + 1, y, A.STEEL) end
-- rim plank on top
local rim = c:rect(8, 13, 38, 14)
A.lit(c, rim, A.WOOD, { R = 1 })
for x = 9, 37 do c:px(x, 13, A.WOOD[6]) end
-- seed heap peeking above rim
local heap = c:ellipse(22, 13, 11, 3):cut(c:rect(0, 13, 63, 63))
heap:each(function(x, y) local h = X.hash(x, y, 3)
  c:px(x, y, (h > 0.66 and SEED[5]) or (h > 0.33 and SEED[4]) or SEED[3]) end)
heap:each(function(x, y) if (x + y) % 3 == 0 then c:px(x, y, SEED[2]) end end)
c:px(18, 10, SEED[6])
-- AO under rim
box:each(function(x, y) if y == 15 then c:px(x, y, A.WOOD[2]) end end)
-- damage: split front plank
A.gap(c, { { 26, 15 }, { 24, 19 }, { 27, 23 }, { 25, 27 }, { 26, 33 } }, 1)
c:px(23, 19, A.WOOD[6]) c:px(26, 23, A.WOOD[6]) c:px(24, 27, A.WOOD[5])
-- seeds trickling from the split
for _, p in ipairs{ { 27, 35 }, { 28, 38 }, { 27, 41 } } do c:px(p[1], p[2], SEED[4]) c:px(p[1] + 1, p[2], SEED[2]) c:px(p[1], p[2] - 1, SEED[5]) end
-- flying splinter
local spl = c:line({ { 42, 24 }, { 46, 21 } }, 1) c:fillMask(spl, A.WOOD[5]) c:px(46, 21, A.WOOD[6]) c:px(42, 24, A.WOOD[3])
-- quirk: sprout on the rim
local st = c:line({ { 34, 12 }, { 34, 8 } }, 1) c:fillMask(st, "#3f9150")
c:fillMask(c:poly{ { 33, 8 }, { 30, 6 }, { 31, 9 } }, A.LEAF[4]) c:px(31, 7, A.LEAF[6])
c:fillMask(c:poly{ { 35, 8 }, { 38, 5 }, { 37, 8 } }, A.LEAF[3]) c:px(36, 7, A.LEAF[5])
A.save(c)
