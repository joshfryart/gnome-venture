-- broken-masterwork-rain-wand (aB12_0, Opus single pass). Slim diagonal wand: a leather-wrapped grip (twist) with a
-- brass pommel, an ash shaft with brass ferrules, and a gilded claw cradling a raindrop of sea glass at the tip.
-- Material: glass with a bright rim, pale core and a spec; wood grain; leather wrap twist; bevelled brass with AO
-- where the claw grips the drop.
-- broken: the shaft is snapped clean through mid-length (gap with splintered teeth), the drop is cracked and a glass
-- chip flies off. quirk: a tiny raincloud hovers beside it, still dripping.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_0.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new("broken-masterwork-rain-wand")

-- shaft (lower) and grip
local s1 = A.rod(c, 15, 53, 27, 41, 1.4, A.LEATH, { twist = 3 })
local s2 = A.rod(c, 27, 41, 31, 37, 1.25, A.WOOD, { grain = 2 })
-- pommel
local pom = c:ellipse(13.5, 54.5, 2, 2)
A.tone(c, pom, X.sphere(13, 54, 2, pom), A.GOLD) c:px(12, 53, A.GOLD[6])
-- ferrule on grip top
A.rod(c, 26, 42, 28, 40, 1.8, A.GOLD, {}) c:px(25, 41, A.GOLD[6])
-- upper shaft
local s3 = A.rod(c, 31, 37, 42, 26, 1.2, A.WOOD, { grain = 5 })
-- snapped: gap across the shaft with splinter teeth
A.erase(c, c:poly{ { 28.5, 35 }, { 33, 32.5 }, { 36.5, 36 }, { 32, 40 } })
c:px(33, 33, A.WOOD[6]) c:px(34, 34, A.WOOD[5]) c:px(36, 35, A.WOOD[3])
c:px(29, 38, A.WOOD[6]) c:px(30, 39, A.WOOD[4])
-- claw collar
A.rod(c, 41, 27, 44, 24, 1.9, A.GOLD, {}) c:px(40, 26, A.GOLD[6])
-- raindrop glass
local drop = c:ellipse(49, 18, 5, 5):add(c:poly{ { 44.5, 16 }, { 53.5, 16 }, { 49, 6 } })
local dn = X.pillow(drop, 4)
local didx = A.tone(c, drop, dn, A.GLASS, { wrap = 0.35, amb = 0.1 })
-- pale core + bright rim
for _, p in ipairs{ { 48, 18 }, { 49, 18 }, { 48, 19 }, { 49, 17 } } do c:px(p[1], p[2], A.GLASS[5]) end
drop:edge():each(function(x, y) if x + y < 64 then c:px(x, y, A.GLASS[6]) end end)
c:px(47, 13, A.SPEC) c:px(47, 14, A.SPEC)
c:px(52, 21, A.GLASS[4]) c:px(53, 20, A.GLASS[4])
-- claw prongs around the drop
local pr1 = c:line({ { 43, 23 }, { 43, 19 }, { 44, 16 } }, 2)
local pr2 = c:line({ { 44, 25 }, { 48, 25 }, { 52, 23 } }, 2)
for _, m in ipairs{ pr1, pr2 } do A.lit(c, m, A.GOLD, { R = 1 }) end
c:px(43, 19, A.GOLD[6]) c:px(47, 25, A.GOLD[6])
-- AO: glass beside prongs
drop:each(function(x, y) if (pr1:has(x - 1, y) or pr2:has(x, y + 1)) and not pr1:has(x, y) and not pr2:has(x, y) then c:px(x, y, A.GLASS[2]) end end)
-- crack in the drop
A.gap(c, { { 51, 8 }, { 50, 11 }, { 52, 14 }, { 51, 17 } }, 1)
c:px(49, 11, A.GLASS[6]) c:px(51, 14, A.GLASS[6])
-- glass chip flying
A.chip(c, { { 56, 10 }, { 59, 11 }, { 57, 13 } }, A.GLASS) c:px(57, 11, A.GLASS[6])
-- quirk: tiny raincloud with drips
local cl = c:ellipse(20, 22, 5, 2.5):add(c:ellipse(18, 20, 2.5, 2.5)):add(c:ellipse(22, 19, 3, 3)):cut(c:rect(0, 24, 63, 63))
local cn = X.pillow(cl, 2)
A.tone(c, cl, cn, A.CLOUD, { wrap = 0.4, amb = 0.15 })
c:px(15, 23, A.CLOUD[2])
for _, p in ipairs{ { 17, 27 }, { 22, 28 } } do c:px(p[1], p[2], A.GLASS[4]) c:px(p[1], p[2] + 1, A.GLASS[3]) end
A.save(c)
