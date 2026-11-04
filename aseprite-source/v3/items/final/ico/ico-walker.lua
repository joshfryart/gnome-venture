-- ico-walker (final, Opus). A gnome hiker striding right mid-step: tall red felt hat flopping back, round nose,
-- fluffy beard, green tunic with a belt, slim legs and boots, a pack with a rolled blanket, a knobbly walking staff.
-- Material: pillow light per part (6-tone ramps); felt hat with a crease fold and a darker brim band; beard locks
-- (wavy strands); tunic weave diagonals; leather belt with a brass buckle; canvas pack with a flap seam stitch;
-- wood staff with grain, a pale knob and a twine wrap at the grip. AO under the hat brim, beard and belt.
-- quirk: a tin camping mug dangles from the pack on a bit of string.
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR0_5.lua")
local HP, X, K = R.HP, R.X, R.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = R.new("ico-walker")
local HAT   = { "#5e1a30", "#8e2434", "#c23a3a", "#e8593e", "#ff8a5c", "#ffb88a" }
local SKIN  = { "#7a3a30", "#b86a4c", "#e8946a", "#f5b890", "#ffd2ae", "#ffe8d0" }
local BEARD = { "#5e5a78", "#8c8aa6", "#b8b6cc", "#dcdae6", "#eeedf4", "#fbf8f2" }
local TUNIC = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local PANTS = { "#2a2440", "#3e3660", "#564e84", "#7068a4", "#8e88c0", "#b0acd8" }
local BOOT  = { "#2e1a1c", "#4a2a26", "#6a3e2e", "#8c563a", "#ab744c", "#c89466" }
local PACK  = { "#5a3418", "#8a5626", "#b47a34", "#d69c48", "#ecbe66", "#f8dc96" }
local ROLL  = { "#2a4a7a", "#3a6a9a", "#4f8cba", "#6aaed2", "#94cce6", "#c4e6f4" }
local WOOD  = { "#4a2a26", "#70402c", "#995a34", "#c07e46", "#dca263", "#f2c98c" }
local TIN   = { "#2a2c42", "#454a66", "#69708e", "#939bb6", "#c2cade", "#eef2f8" }
local T = function(n) return { r = { name = n } } end
local tHat, tSk, tBd, tTu, tPa, tBo, tPk, tRo, tWo, tTi = T"hat", T"skin", T"beard", T"tunic", T"pants", T"boot", T"pack", T"roll", T"wood", T"tin"

c:groundShadow(32, 56, 16, 1)

---------------------------------------------------------------- quirk (behind the pack): tin mug on a string
local mug = HP.rect(12, 41, 16, 45)
local mn = R.vcylN(mug, 12, 16, 0)
local midx = R.shade(c, mug, mn, TIN, { amb = 0.1, wrap = 0.3, tok = tTi })
for x = 12, 16 do c:put(x, 41, x < 14 and TIN[5] or TIN[4], tTi) end           -- rolled rim
c:put(13, 42, TIN[6], tTi)
c:put(12, 45, TIN[2], tTi) c:put(16, 45, TIN[1], tTi)
-- dent in the mug
c:put(15, 43, TIN[2], tTi)
-- string from the pack corner
c:put(16, 40, PACK[2], tPk) c:put(17, 39, PACK[2], tPk)

---------------------------------------------------------------- back leg + boot (far side, darker)
local legB, lnB = X.cyl(30, 43, 23.5, 52, function(t) return 1.9 end)
local bootB = HP.rrect(18, 51, 26, 55, 1)
legB:cut(bootB)
local pbi = R.shade(c, legB, lnB, PANTS, { amb = 0.06, wrap = 0.2, tok = tPa, bias = {} })
legB:each(function(x, y) R.step(c, pbi, PANTS, x, y, -1, tPa) end)
local bbi = R.pil(c, bootB, BOOT, 1.6, { amb = 0.08, wrap = 0.25, tok = tBo })
for x = 18, 26 do c:put(x, 55, BOOT[1], tBo) end                               -- sole
R.sepLine(c, legB, bootB, PANTS[1], tPa)

---------------------------------------------------------------- pack + rolled blanket
local pack = HP.rrect(17, 29, 27, 44, 2)
local pki = R.pil(c, pack, PACK, 2.4, { amb = 0.08, wrap = 0.25, tok = tPk })
-- flap with stitch seam
for x = 18, 26 do c:put(x, 35, PACK[2], tPk) end
for x = 18, 26 do c:put(x, 34, PACK[4], tPk) end
c:stitch{ { 18, 37 }, { 26, 37 } }
-- canvas weave: faint diagonals
pack:each(function(x, y) if y > 37 and (x + y) % 4 == 0 then R.step(c, pki, PACK, x, y, -1, tPk) end end)
-- pocket button
c:put(22, 40, PACK[1], tPk) c:put(22, 39, PACK[6], tPk)
local roll = HP.rrect(15, 24, 29, 29, 2)
local rn = {}
roll:each(function(x, y) local t = max(-.95, min(.95, (y + .5 - 26.5) / 3)) rn[K(x, y)] = { R.norm(-0.15, t, sqrt(1 - t * t)) } end)
local rli = R.shade(c, roll, rn, ROLL, { amb = 0.1, wrap = 0.3, tok = tRo })
-- spiral end on the left + strap
for y = 25, 28 do c:put(15, y, ROLL[2], tRo) end c:put(16, 26, ROLL[5], tRo) c:put(16, 27, ROLL[3], tRo)
for y = 24, 29 do c:put(20, y, PACK[2], tPk) c:put(25, y, PACK[2], tPk) end
-- AO on the pack under the roll
pack:each(function(x, y) if y == 30 then R.step(c, pki, PACK, x, y, -2, tPk) end end)

---------------------------------------------------------------- front leg + boot
local legF, lnF = X.cyl(35, 43, 42.5, 51, function(t) return 1.9 end)
local bootF = HP.rrect(39, 50, 47, 54, 1)
bootF:add(HP.rect(46, 52, 48, 54))
legF:cut(bootF)
R.shade(c, legF, lnF, PANTS, { amb = 0.08, wrap = 0.25, tok = tPa })
local bfi = R.pil(c, bootF, BOOT, 1.6, { amb = 0.08, wrap = 0.25, tok = tBo })
for x = 39, 48 do c:put(x, 54, BOOT[1], tBo) end
for x = 40, 43 do c:put(x, 51, BOOT[5], tBo) end                               -- boot cuff lit
R.sepLine(c, legF, bootF, PANTS[1], tPa)

---------------------------------------------------------------- tunic + belt
local tunic = HP.rrect(26, 30, 39, 45, 3)
tunic:add(c:poly{ { 26, 41 }, { 40, 41 }, { 41, 46 }, { 25, 46 } })            -- flared hem
local tb = {}
local tui = R.shade(c, tunic, X.pillow(tunic, 3), TUNIC, { amb = 0.08, wrap = 0.25, tok = tTu, bias = tb })
tunic:each(function(x, y) if (x - y) % 4 == 0 and y > 33 then R.step(c, tui, TUNIC, x, y, -1, tTu) end end)
-- AO where the tunic meets the pack
R.sepLine(c, tunic, pack, TUNIC[1], tTu)
-- belt
for x = 26, 40 do if tunic:has(x, 40) then c:put(x, 40, BOOT[3], tTu) c:put(x, 41, BOOT[1], tTu) end end
for x = 26, 40 do if tunic:has(x, 39) then R.step(c, tui, TUNIC, x, 39, -1, tTu) end end
c:fillMask(HP.rect(34, 39, 36, 41), PACK[4]) c:put(35, 40, PACK[1], tTu) c:put(34, 39, PACK[6], tTu)
-- hem darker band
for x = 24, 41 do if tunic:has(x, 46) then c:put(x, 46, TUNIC[2], tTu) end end
-- AO on legs under hem
for x = 22, 44 do for _, y in ipairs{ 47 } do if legF:has(x, y) or legB:has(x, y) then c:put(x, y, PANTS[1], tPa) end end end

---------------------------------------------------------------- face, nose
local face = c:ellipse(35, 25, 4.6, 4.2)
local fi, fn = R.pil(c, face, SKIN, 2.6, { amb = 0.12, wrap = 0.3, tok = tSk })
local nose = c:ellipse(40, 26.5, 2.2, 2.0)
local ni, nn = R.pil(c, nose, SKIN, 1.6, { amb = 0.16, wrap = 0.3, tok = tSk })
for x = 38, 42 do if nose:has(x, 28) then c:put(x, 28, SKIN[2], tSk) end end      -- dark underside
c:put(39, 25, SKIN[6], tSk) c:put(40, 25, SKIN[6], tSk)                            -- lit tip
c:put(41, 28, SKIN[1], tSk)                                                        -- nostril
R.sepLine(c, nose, face, SKIN[3], tSk)
c:eyeSmall(36, 22)
c:put(34, 25, "#f5809f", tSk) c:put(35, 25, "#f5809f", tSk)                       -- cheek

---------------------------------------------------------------- beard (over face bottom + tunic top)
local beard = c:poly{ { 29, 26 }, { 33, 28 }, { 38, 29 }, { 42, 28 }, { 41, 32 }, { 38, 36 }, { 35, 39 }, { 32, 36 }, { 29, 31 } }
beard:cut(nose)
local bi = R.pil(c, beard, BEARD, 2.4, { amb = 0.12, wrap = 0.3, tok = tBd })
-- wavy locks
beard:each(function(x, y) if (x * 2 + y) % 5 == 0 and y > 29 then R.step(c, bi, BEARD, x, y, -1, tBd) end end)
-- moustache shadow under the nose
for x = 37, 40 do if beard:has(x, 29) then c:put(x, 29, BEARD[2], tBd) end end
-- AO on the tunic under the beard
R.castOn(c, tui, TUNIC, tunic, beard, 1, 1, -2, tTu)

---------------------------------------------------------------- hat (felt cone flopping back)
local hat = c:poly{ { 27, 22.5 }, { 44, 22.5 }, { 41, 17 }, { 37, 11 }, { 32, 8 }, { 26, 8 }, { 23, 10 }, { 27, 11 }, { 31, 14 } }
local hb = {}
local hi, hn = R.pil(c, hat, HAT, 2.6, { amb = 0.08, wrap = 0.25, tok = tHat, bias = hb })
-- crease where the tip folds over
for _, p in ipairs{ { 31, 12 }, { 32, 12 }, { 33, 13 }, { 34, 14 } } do c:put(p[1], p[2], HAT[2], tHat) end
for _, p in ipairs{ { 32, 11 }, { 33, 11 } } do c:put(p[1], p[2], HAT[5], tHat) end
-- brim band
for x = 27, 44 do if hat:has(x, 21) then c:put(x, 21, HAT[2], tHat) end if hat:has(x, 22) then c:put(x, 22, HAT[1], tHat) end end
-- AO on face under the brim
for x = 30, 41 do if face:has(x, 23) and not hat:has(x, 23) then R.step(c, fi, SKIN, x, 23, -2, tSk) end end
c:put(24, 9, HAT[5], tHat)

---------------------------------------------------------------- staff + front arm
local staff, sn, ST, SS = X.cyl(46, 14, 52, 56, function(t) return 1.25 end)
local wi = R.shade(c, staff, sn, WOOD, { amb = 0.1, wrap = 0.25, tok = tWo })
staff:each(function(x, y) local k = K(x, y) if abs(SS[k] - 0.4) < 0.2 and X.hash(x, y, 5) > 0.35 then R.step(c, wi, WOOD, x, y, -1, tWo) end end)
-- knots (bumps) on the staff
for _, p in ipairs{ { 49, 25 }, { 52, 45 } } do c:put(p[1], p[2], WOOD[2], tWo) end
local knob = c:ellipse(46, 13, 2.2, 2.2)
local ki, kn = R.pil(c, knob, WOOD, 1.6, { amb = 0.12, wrap = 0.3, tok = tWo })
c:put(45, 12, WOOD[6], tWo)
-- twine grip wrap
for y = 33, 37 do for x = 46, 50 do if staff:has(x, y) then c:put(x, y, (y % 2 == 0) and PACK[5] or PACK[3], tWo) end end end
local arm, an = X.cyl(36, 33, 45, 37, function(t) return 1.7 end)
local ai = R.shade(c, arm, an, TUNIC, { amb = 0.1, wrap = 0.25, tok = tTu })
R.sepLine(c, arm, tunic, TUNIC[1], tTu)
local hand = c:ellipse(47.5, 36, 2, 2)
R.pil(c, hand, SKIN, 1.4, { amb = 0.12, wrap = 0.3, tok = tSk })
c:put(48, 38, SKIN[2], tSk) c:put(46, 35, SKIN[5], tSk)
-- contact shadow of the hand on the staff
for y = 38, 39 do for x = 48, 50 do if staff:has(x, y) and not hand:has(x, y) then R.step(c, wi, WOOD, x, y, -2, tWo) end end end

R.save(c, "ico-walker")
