-- pluot-jam (lean P1b_O7)
-- Straight glass jar of glossy plum-purple jam, teal screw lid, cream label with a speckled pluot, glass rim light
-- and a streak highlight. quirk: a jam drip has run over the lid edge and down the glass.
local NAME = "pluot-jam"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local JAM  = { "#2a0f3c", "#4c1a58", "#722670", "#9a3a86", "#c25c9c", "#ea92c0" }
local LID  = { "#12383e", "#1c5658", "#2a7a70", "#40a088", "#6cc4a0", "#a6e6c0" }
local GLAS = { "#5a7894", "#8cb0c8", "#bcdcec", "#e4f6fc" }
local PAP  = { "#a89478", "#d0bc98", "#ecdcb8", "#fff4d8" }
local PLU  = { "#3a1648", "#5e2a6c", "#8a4488", "#b46ca8", "#d89ac8" }
c:groundShadow(32, 56, 17, 2)
local jar = c:rrect(15, 21, 48, 54, 5)
local neck = c:rect(17, 17, 46, 22)
local inner = jar:copy():shrink(2)
-- glass body
local gn = X.pillow(jar, 6)
G.toneN(c, jar, gn, GLAS, { cuts = { 0.4, 0.7, 0.9 }, amb = 0.3, wrap = 0.3 })
c:fillMask(neck, GLAS[2])
-- jam
local jn = X.pillow(inner, 9)
local bias = {}
X.ao(bias, inner, c:rect(0, 0, 63, 23), 2, -1)
G.toneN(c, inner, jn, JAM, { bias = bias, amb = 0.05, wrap = 0.2 })
inner:each(function(x, y) if X.hash(x, y, 7) > 0.97 and y > 26 then c:px(x, y, JAM[2]) end end)
-- label
local lab = c:rrect(19, 33, 44, 47, 2)
c:fillMask(lab, PAP[3])
lab:edge():each(function(x, y) c:px(x, y, (x + y > 70) and PAP[1] or PAP[2]) end)
for x = 21, 42, 2 do c:px(x, 35, PAP[1]) end
-- pluot: round, speckled purple with green blush, leaf
local pm = c:ellipse(31, 41, 4, 4)
local pn = X.pillow(pm, 4.5)
G.toneN(c, pm, pn, PLU, { amb = 0.1 })
pm:each(function(x, y) if X.hash(x, y, 9) > 0.85 then c:px(x, y, "#e8c8a0") end end)
c:px(29, 39, "#f4e0f4") c:px(30, 38, "#f4e0f4")
c:px(31, 36, "#3f8f4c") c:px(32, 36, "#62ad55") c:px(33, 35, "#3f8f4c") c:px(33, 36, "#2b7046")
c:px(31, 37, "#5a3a2a")
for x = 21, 42 do c:px(x, 45, PAP[2]) end
-- lid
local lid = c:rrect(14, 9, 49, 20, 3)
local ln = X.pillow(lid, 5)
local lb = {}
lid:each(function(x, y) if y == 17 or y == 12 then lb[K(x, y)] = -2 end if x % 3 == 0 and y > 13 and y < 17 then lb[K(x, y)] = -1 end end)
G.toneN(c, lid, ln, LID, { bias = lb, amb = 0.15, wrap = 0.3 })
for x = 18, 28 do c:px(x, 10, LID[6]) end
c:px(30, 10, LID[5])
-- glass streak + rim light + spec
for y = 25, 49 do c:px(17, y, GLAS[4]) end
c:px(18, 27, GLAS[4]) c:px(18, 28, GLAS[4]) c:px(19, 29, JAM[6]) c:px(19, 30, JAM[6])
for y = 24, 47 do c:px(46, y, "#7aa0c4") end
c:px(45, 44, JAM[6]) c:px(24, 29, "#fff0fa") c:px(25, 29, "#fff0fa")
for y = 23, 52 do c:px(15, y, GLAS[3]) end
-- drip quirk
for y = 20, 27 do c:px(44, y, JAM[3]) c:px(45, y, JAM[4]) end
c:px(44, 28, JAM[3]) c:px(45, 28, JAM[5]) c:px(45, 29, JAM[6]) c:px(44, 29, JAM[3]) c:px(44, 20, LID[1]) c:px(45, 20, JAM[2])
G.save(c, NAME)
