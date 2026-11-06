-- broken-masterwork-gnome-seeder (aB12_0, Opus single pass). Upright hand-cranked seed drill: a gilded funnel hopper
-- (open mouth heaped with seeds) on a steel throat, a ribbed wooden metering drum with a crank and knob on the right,
-- a thin steel spout under it, two slim splayed legs with a cross-rail. Material: bevelled brass with sheen streak and
-- rivets, dark hopper interior, drum ribs, wood grain, steel collar bevel, AO where every part meets the next.
-- broken: a split runs down the hopper (gap), the right leg is snapped with its foot knocked askew, a brass chip flies.
-- quirk: one seed in the heap has already sprouted.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_0.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new("broken-masterwork-gnome-seeder")

c:groundShadow(32, 53, 17, 1)
-- legs + rail (behind)
local l1 = A.rod(c, 25, 40, 21, 52, 1.0, A.WOOD, { grain = 3 })
local l2 = A.rod(c, 38, 40, 41, 47, 1.0, A.WOOD, { grain = 5 })
-- snapped lower right leg, knocked askew
local l3 = A.rod(c, 43, 49, 45, 52, 1.0, A.WOOD, { grain = 6 })
c:px(42, 49, A.WOOD[6]) c:px(42, 48, A.WOOD[5])
local rail = A.rod(c, 23, 46, 40, 46, 0.6, A.WOOD, { grain = 8 })
-- spout
A.rod(c, 31.5, 40, 31.5, 46, 1.0, A.STEEL, {})
c:px(31, 46, A.STEEL[1]) c:px(32, 46, A.STEEL[1])
-- crank axle + arm + knob (right)
A.rod(c, 40, 36, 45, 36, 0.8, A.STEEL, {})
A.rod(c, 45, 36, 49, 29, 0.8, A.STEEL, {})
local knob = c:rrect(47, 25, 51, 29, 2)
A.lit(c, knob, A.WOOD, { R = 2 })
c:px(48, 26, A.WOOD[6])
-- metering drum (horizontal cylinder with ribs)
local drum = c:rrect(21, 32, 41, 40, 2)
local dn = {}
drum:each(function(x, y) local t = math.max(-.95, math.min(.95, ((y - 32) / 8) * 2 - 1)) dn[K(x, y)] = { -0.1, t, math.sqrt(1 - t * t) } end)
local didx = A.tone(c, drum, dn, A.WOOD, { wrap = 0.3 })
for x = 23, 39, 3 do for y = 33, 39 do local i = didx[K(x, y)] if i then c:px(x, y, A.WOOD[math.max(1, i - 2)]) c:px(x + 1, y, A.WOOD[math.min(6, i + 1)]) end end end
-- brass end caps on the drum
for _, x in ipairs{ 21, 41 } do for y = 33, 39 do local i = didx[K(x, y)] if i then c:px(x, y, A.GOLD[i]) end end end
-- throat collar
local col = c:rect(26, 29, 37, 32)
local cn = {}
col:each(function(x, y) local t = math.max(-.95, math.min(.95, ((x - 26) / 11) * 2 - 1)) cn[K(x, y)] = { t, 0, math.sqrt(1 - t * t) } end)
A.tone(c, col, cn, A.STEEL, { bias = A.ao(col, { drum }, 1, -1) })
for x = 26, 37 do c:px(x, 29, A.STEEL[6]) end
-- hopper
local hop = c:poly{ { 14, 12 }, { 50, 12 }, { 38, 30 }, { 26, 30 } }
local hidx, hn = A.lit(c, hop, A.GOLD, { R = 3, bias = A.ao(hop, { col }, 1, -1) })
A.streak(c, hop, hidx, A.GOLD, 34, 2)
for _, p in ipairs{ { 19, 16 }, { 25, 16 }, { 38, 16 }, { 44, 16 } } do A.rivet(c, p[1], p[2], A.GOLD) end
for x = 27, 37 do c:px(x, 28, A.GOLD[2]) end
-- open mouth: rolled lip + dark interior with seed heap
local mouth = c:ellipse(32, 11, 18, 3)
A.lit(c, mouth, A.GOLD, { R = 1 })
local inside = c:ellipse(32, 11, 16, 1.6)
c:fillMask(inside, A.GOLD[1])
local SEED = { "#5a3a22", "#a8743e", "#d9a85c", "#f4d28a" }
local heap = c:ellipse(32, 9.5, 11, 2.2):cut(c:rect(0, 11, 63, 63))
heap:each(function(x, y)
  local h = X.hash(x, y, 5)
  c:px(x, y, (h > 0.66) and SEED[4] or (h > 0.33 and SEED[3] or SEED[2]))
  if (x + y) % 3 == 0 then c:px(x, y, SEED[1]) end
end)
for x = 20, 44 do if inside:has(x, 11) then c:px(x, 11, SEED[1]) end end
-- damage: split down the hopper
A.gap(c, { { 37, 13 }, { 36, 17 }, { 39, 20 }, { 36, 24 }, { 37, 27 } }, 1)
A.gap(c, { { 37, 12 }, { 37, 15 } }, 2)
c:px(35, 17, A.GOLD[6]) c:px(38, 20, A.GOLD[6])
-- flying chip
A.chip(c, { { 52, 17 }, { 56, 16 }, { 55, 20 } }, A.GOLD) c:px(53, 17, A.SPEC)
-- quirk: a seed that already sprouted
c:px(27, 6, A.LEAF[3]) c:px(27, 7, A.LEAF[3]) c:px(27, 8, A.LEAF[2])
c:px(25, 5, A.LEAF[5]) c:px(26, 5, A.LEAF[4]) c:px(24, 5, A.LEAF[6])
c:px(28, 4, A.LEAF[4]) c:px(29, 4, A.LEAF[3]) c:px(28, 5, A.LEAF[3]) c:px(30, 4, A.LEAF[5])
c:px(26, 9, SEED[4]) c:px(27, 9, SEED[3]) c:px(28, 9, SEED[2])
A.save(c)
