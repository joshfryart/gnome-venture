-- delve-sea-cave-smugglers-run: moonlit cliff, a tide-timed sea cave, a smuggler's rowboat with barrels. NWE, night.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, W, H = L.GV, L.W, L.H
local c = L.new()
local HOR = 74

L.sky(c, "night", HOR)
L.stars(c, 40, 50, 11)
-- moon (full, upper left) with a cool ring
c:fill(c:ellipse(34, 26, 11, 11), "#4a428e"); c:fill(c:ellipse(34, 26, 9, 9), "#fff1c8"); c:fill(c:ellipse(34, 26, 9, 9):clip(c:rect(0, 29, W, 60)), "#f5cf6a")
for _, p in ipairs({ {31,22},{37,27},{33,30} }) do c:fill(c:rect(p[1], p[2], p[1] + 2, p[2] + 1), "#f5cf6a") end
L.cloud(c, 90, 44, 16, "#3e3680", "#322c6c"); L.cloud(c, 22, 56, 12, "#3e3680", "#322c6c")
-- sea
L.water(c, HOR + 1, "night")
-- moon path on the water, in dashes
for i, y in ipairs({ 78, 82, 86, 91, 96, 102 }) do
  local w = 14 - i
  c:fill(c:rect(34 - w // 2 + (i % 2) * 3, y, 34 + w // 2 + (i % 2) * 3, y), (i % 2 == 0) and "#c3b2ea" or "#8c6ab8")
end

-- cliff -------------------------------------------------------------------------------------------------
local cliff = c:poly({ {240,H},{240,26},{214,24},{196,30},{170,28},{140,32},{112,40},{92,52},{82,70},{78,90},{74,106},{70,H} })
c:part(cliff, GV.ramp("#5b6470"), { cres = 8, deep = 13, gloss = false })
-- grass cap and a little lookout hut on the top
c:fill(c:poly({ {240,26},{214,24},{196,30},{170,28},{140,32},{112,40},{100,47},{112,45},{140,38},{170,34},{196,36},{214,30},{240,32} }), "#2f5a2a")
c:fill(c:poly({ {240,26},{214,24},{196,30},{170,28},{140,32},{128,34},{140,35},{170,31},{196,33},{214,27},{240,29} }), "#4a8a3e")
-- strata lines
for _, l in ipairs({ { {96,58},{120,56},{132,60} }, { {150,44},{176,42},{200,46} }, { {196,60},{222,58},{238,62} }, { {170,76},{196,74},{214,78} }, { {84,80},{96,78},{106,82} } }) do
  c:seam(l, { free = true, on = 4, off = 0, gap = "#2a2a3a" })
end
for _, l in ipairs({ { {98,56},{118,54} }, { {152,42},{174,40} }, { {198,58},{220,56} } }) do c:seam(l, { free = true, on = 4, off = 0, gap = "#8b8f96" }) end
-- pine hut and light on the clifftop
c:part(c:rect(196, 14, 216, 26), GV.ramp("#a8582f"), { cres = 3, deep = 5, gloss = false })
c:part(c:poly({ {193,15},{206,6},{219,15} }), GV.ramp("#5e2f1e"), { cres = 3, deep = 5, gloss = false })
c:fill(c:rect(203, 18, 208, 22), "#f5cf6a"); c:px(203, 18, "#fff1c8"); c:fill(c:rect(205, 18, 205, 22), "#b8661a")

-- the cave mouth: tall arch, dark inside, a warm glow deeper in ----------------------------------------
local mouth = c:poly({ {104,H},{104,92},{110,70},{124,58},{146,54},{168,58},{182,70},{188,92},{188,H} })
c:part(mouth, GV.ramp("#1c1a48"), { cres = 2, deep = 3, gloss = false, rim = false })
c:fill(c:poly({ {112,H},{112,92},{118,74},{128,66},{146,62},{164,66},{174,74},{180,92},{180,H} }), "#141234")
-- inner chamber glow (lantern light on far wall)
c:fill(c:ellipse(146, 92, 18, 22):clip(c:rect(0, 0, W, 104)), "#3a2a3a")
c:fill(c:ellipse(146, 94, 13, 17):clip(c:rect(0, 0, W, 104)), "#7a4a3a")
c:fill(c:ellipse(146, 96, 8, 11):clip(c:rect(0, 0, W, 104)), "#c98a4a")
c:fill(c:ellipse(146, 98, 4, 6):clip(c:rect(0, 0, W, 104)), "#f5cf6a")
-- stalactites
for _, p in ipairs({ {118,68,5},{128,63,6},{138,60,4},{150,60,6},{162,63,5},{172,69,6} }) do
  c:fill(c:poly({ {p[1]-2,p[2]},{p[1],p[2]+p[3]},{p[1]+2,p[2]} }), "#5b6470"); c:px(p[1]-1, p[2], "#8b8f96")
end
-- cave water: tide in the mouth, with glow reflected
c:bands(c:rect(104, 100, 188, H - 1), { "#2a3c6c", "#25446e", "#1e3466" }, { dir = "v" })
for i, w in ipairs({ 6, 10, 14, 8 }) do c:fill(c:rect(146 - w // 2 + i, 100 + i * 2, 146 + w // 2 + i, 100 + i * 2), (i % 2 == 0) and "#f5cf6a" or "#e39a86") end
-- tide ledge (stone shelf) with barrels, right inside the mouth
local ledge = c:poly({ {160,100},{172,96},{188,94},{188,108},{176,106},{160,104} })
c:part(ledge, GV.ramp("#8b8f96"), { cres = 3, deep = 4, gloss = false })
local function barrel(x, y, w, h)
  c:part(c:rrect(x, y, x + w, y + h, 3), GV.ramp("#b07a45"), { cres = 2, deep = 3, gloss = false })
  c:fill(c:rect(x, y + 2, x + w, y + 2), "#5e2f1e"); c:fill(c:rect(x, y + h - 2, x + w, y + h - 2), "#5e2f1e")
  c:px(x + 2, y + h // 2, "#ecc58a")
end
barrel(166, 84, 9, 12); barrel(177, 86, 9, 11); barrel(171, 76, 9, 9)

-- tide pole at the cave mouth with notches (the tide timing) ----------------------------------------------
c:part(c:rect(98, 66, 101, 112), GV.ramp("#7a4a1f"), { cres = 1, gloss = false, rim = false })
for y = 70, 108, 6 do c:fill(c:rect(94, y, 97, y), "#f5cf6a"); end
c:fill(c:rect(94, 100, 97, 101), "#e0501f")
c:part(c:ellipse(99, 62, 3, 3), GV.ramp("#f5cf6a"), { flat = true })
-- foam at the cliff base
for i, x in ipairs({ 74, 90, 104, 190, 206, 222, 232 }) do c:fill(c:rect(x, H - 14 + (i % 3) * 2, x + 8, H - 14 + (i % 3) * 2), "#8fcbd8") end

-- the rowboat -----------------------------------------------------------------------------------------------------
local BX, BY = 48, 114
c:part(c:poly({ {BX-30,BY},{BX+30,BY},{BX+36,BY-6},{BX+28,BY+10},{BX-22,BY+10} }), GV.ramp("#a8582f"), { cres = 4, deep = 6, gloss = false })
c:seam({ {BX-24, BY+3}, {BX+26, BY+3} }, { free = true, on = 3, off = 1, gap = "#5e2f1e" })
c:fill(c:rect(BX-28, BY, BX+30, BY), "#d9a660")
-- two barrels aboard, and a sack
barrel(BX - 22, BY - 14, 12, 14); barrel(BX - 8, BY - 12, 11, 12)
c:part(c:ellipse(BX + 14, BY - 5, 6, 5), GV.ramp("#d9c89a"), { cres = 2, gloss = false }); c:fill(c:rect(BX + 12, BY - 11, BX + 16, BY - 9), "#b07a45")
-- smuggler gnome at the stern with a hooded lantern (the glow warms the water)
local GX, GY = BX + 26, BY - 1
c:part(c:poly({ {GX-7,GY},{GX-4,GY-12},{GX+4,GY-12},{GX+7,GY} }), GV.ramp("#3e2f66"), { cres = 3, deep = 5, gloss = false })
c:part(c:ellipse(GX, GY - 14, 8, 7), GV.ramp("#e9b98a"), { cres = 3, deep = 4 })
c:eye(GX - 6, GY - 18); c:eye(GX + 1, GY - 18)   -- big watchful eyes
c:part(c:poly({ {GX-8,GY-20},{GX+1,GY-34},{GX+8,GY-20} }), GV.ramp("#291d4a"), { cres = 3, deep = 5, gloss = false })
c:fill(c:rect(GX - 9, GY - 21, GX + 9, GY - 20), "#3e2f66")
c:fill(c:rect(GX - 4, GY - 11, GX + 4, GY - 9), "#cfd6e8") -- beard tuft
-- lantern on a pole
c:fill(c:line({ {GX + 9, GY - 4}, {GX + 11, GY - 22} }, 2), "#5e2f1e")
c:part(c:rect(GX + 8, GY - 30, GX + 15, GY - 22), GV.ramp("#e8a317"), { cres = 1, gloss = false })
c:fill(c:rect(GX + 10, GY - 28, GX + 13, GY - 24), "#fff1c8")
-- oar
c:fill(c:line({ {BX - 12, BY - 2}, {BX - 30, BY + 16} }, 2), "#d9a660"); c:fill(c:ellipse(BX - 32, BY + 18, 3, 2), "#b07a45")
-- boat glow and ripples
for i, w in ipairs({ 30, 40, 24 }) do c:fill(c:rect(BX - w // 2, BY + 13 + i * 3, BX + w // 2, BY + 13 + i * 3), (i == 1) and "#8c6ab8" or "#3e3680") end
c:fill(c:rect(BX + 20, BY + 12, BX + 34, BY + 12), "#f5cf6a"); c:fill(c:rect(BX + 22, BY + 14, BX + 32, BY + 14), "#e39a86")

L.finish(c, "delve-sea-cave-smugglers-run")
