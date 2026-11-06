-- broken-masterwork-barrow (aB12_0, Opus single pass). Side view: slim gilded tray with a rolled lip, small steel-tyred
-- wheel up front on a wooden fork, one long ash handle and a thin leg out back. Material: bevelled brass tray with a
-- diagonal sheen streak + rivet row, wood grain on handle/leg, steel tyre with a spec, AO where fork and wheel meet the tray.
-- broken: a jagged split opens through the tray (gap widens at the lip), the lip corner is bent off, a brass chip and
-- a wood splinter fly away. quirk: an earthworm peeks over the lip to see what happened.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_0.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new("broken-masterwork-barrow")

c:groundShadow(31, 54, 22, 1)
-- leg + handle (behind tray)
local tray = c:poly{ { 7, 19 }, { 45, 19 }, { 38, 37 }, { 17, 37 } }
A.rod(c, 37, 34, 41, 53, 1.1, A.WOOD, { grain = 4, bias = {} })
c:fillMask(c:rect(39, 53, 43, 54), A.WOOD[2]) c:px(39, 53, A.WOOD[4]) c:px(40, 53, A.WOOD[5])
local hm = A.rod(c, 33, 33, 54, 18, 1.25, A.WOOD, { grain = 2 })
-- grip end: paler end grain
c:px(54, 17, A.WOOD[6]) c:px(55, 18, A.WOOD[5])
-- wheel fork
A.rod(c, 22, 36, 16, 46, 1.0, A.WOOD, { grain = 7 })
-- tray
local bias = A.ao(tray, { hm }, 1, -1)
local tidx, tn = A.lit(c, tray, A.GOLD, { R = 3, bias = bias, wrap = 0.3 })
A.streak(c, tray, tidx, A.GOLD, 34, 2)
-- inner side panel line (tray depth): a fold where the side meets the base
for x = 18, 37 do c:px(x, 33, A.GOLD[2]) end
for x = 19, 36 do c:px(x, 34, A.GOLD[3]) end
-- rivets
for x = 11, 41, 6 do A.rivet(c, x, 23, A.GOLD) end
-- rolled lip
local lip = A.rod(c, 6, 18.5, 46, 18.5, 1.3, A.GOLD, {})
c:px(12, 18, A.SPEC) c:px(13, 18, A.GOLD[6])
-- wheel
local wo = A.wheel(c, 15, 46, 8, { spokes = 6, rot = 0.25, hub = 2 })
-- damage: split through the tray, widening toward the lip
A.gap(c, { { 29, 18 }, { 28, 22 }, { 31, 26 }, { 28, 30 }, { 30, 34 }, { 29, 37 } }, 1)
A.gap(c, { { 29, 17 }, { 28, 21 } }, 2)
-- bright torn edges
c:px(27, 22, A.GOLD[6]) c:px(30, 26, A.GOLD[6]) c:px(27, 30, A.GOLD[5])
-- lip corner bent off: notch top-right
A.erase(c, c:poly{ { 41, 16 }, { 47, 16 }, { 47, 22 }, { 44, 22 } })
c:px(43, 20, A.GOLD[6]) c:px(42, 18, A.GOLD[5])
-- flying chip + splinter
A.chip(c, { { 48, 24 }, { 52, 23 }, { 51, 27 } }, A.GOLD)
c:px(49, 24, A.SPEC)
local spl = c:line({ { 50, 9 }, { 54, 7 } }, 1) c:fillMask(spl, A.WOOD[5]) c:px(54, 7, A.WOOD[6]) c:px(50, 9, A.WOOD[3])
-- quirk: earthworm over the lip
local WORM = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }
local wm = c:line({ { 15, 17 }, { 15, 14 }, { 16, 12 }, { 18, 12 } }, 2)
local wn = X.pillow(wm, 1)
A.tone(c, wm, wn, WORM, { cuts = { 0.3, 0.55, 0.8 } })
for _, p in ipairs{ { 15, 15 }, { 16, 13 } } do c:px(p[1], p[2], WORM[1]) end
c:px(18, 12, "#2b1c26") c:px(17, 12, WORM[4])
A.save(c)
