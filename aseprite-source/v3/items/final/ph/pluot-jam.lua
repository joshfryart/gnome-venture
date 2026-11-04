-- pluot-jam (lean W2_14)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pluot-jam" }
local JAM  = { "#2a0f33", "#4a1950", "#712468", "#9a3a7c", "#c05a8a", "#e68aa0" }
local GLASS= { "#5a6a8e", "#8798b8", "#b3c4da", "#d9e6f0", "#f1f8fb", "#f8fcff" }
local LID  = { "#6a4414", "#98661f", "#c68d32", "#e6b24e", "#f6d27e", "#fff0b4" }
local PAPER= { "#b8a47c", "#d8c79c", "#efe2bc", "#fbf3d8" }
local CUT = { 0.2, 0.38, 0.55, 0.72, 0.87 }
c:groundShadow(32, 54, 15, 3)
-- jar glass outline
local jar = c:rrect(17, 22, 47, 53, 5)
local jn = X.pillow(jar, 9)
G.tone(c, jar, X.light(jn, { amb = 0.35, wrap = 0.3 }), GLASS, CUT)
-- jam fill
local fill = c:rrect(19, 26, 45, 51, 4)
local fn = X.pillow(fill, 9)
G.tone(c, fill, X.light(fn, { amb = 0.1, wrap = 0.3 }), JAM, CUT)
fill:each(function(x, y) if X.hash(x, y, 7) > 0.93 and y > 28 then c:px(x, y, JAM[5]) end end)
-- label: paper with a plum half
local lab = c:rect(22, 34, 42, 46)
G.tone(c, lab, X.light(X.pillow(lab, 6), { amb = 0.6, wrap = 0.2 }), PAPER, { 0.3, 0.6, 0.85 })
local pl = c:ellipse(32, 40, 4, 4)
G.tone(c, pl, X.light(X.pillow(pl, 4), { amb = 0.1, wrap = 0.3 }), JAM, CUT)
c:px(30, 38, JAM[6]) c:px(32, 36, "#4b9650") c:px(33, 35, "#70b45a")
for x = 23, 41, 2 do c:px(x, 35, PAPER[1]) end
-- glass streak + spec
for y = 28, 48 do c:px(20, y, GLASS[5]) end
c:px(21, 27, GLASS[6]) c:px(22, 27, GLASS[6])
-- lid
local lid = c:rrect(18, 15, 46, 23, 2)
G.tone(c, lid, X.light(X.pillow(lid, 5), { amb = 0.2, wrap = 0.3 }), LID, CUT)
for x = 20, 44, 3 do c:px(x, 19, LID[2]) end
c:px(21, 16, LID[6]) c:px(22, 16, LID[6])
-- quirk: a drip of jam over the rim
for y = 22, 28 do c:px(41, y, JAM[3]) c:px(42, y, JAM[2]) end
c:fillMask(c:ellipse(42, 29, 1.5, 1.8), JAM[4]) c:px(41, 28, JAM[6])
G.fin(c, "pluot-jam")
