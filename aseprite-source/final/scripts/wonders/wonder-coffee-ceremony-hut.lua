-- wonder-coffee-ceremony-hut.lua : night; a round thatched hut glows, the host pours coffee (jebena) into three small cups: wake, talk, bless.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, c, W, H = L.GV, L.new(), L.W, L.H
local SLUG = "wonder-coffee-ceremony-hut"
local SKIN = GV.ramp("#8a5a3a", { rim = "#b88058", shade = "#6a4028", deep = "#4a2c1a" })
local WHT = GV.ramp("#f6f0e0", { shade = "#d0c4b0", deep = "#a89888", rim = "#fff3c8", dot = "#fff3c8", gloss = "#fff3c8" })

L.sky(c, "night", 84)
L.stars(c, 40, 60, 11)
for _, p in ipairs({ {30,12},{150,20},{210,10} }) do c:px(p[1]-1,p[2],"#fff1c8"); c:px(p[1]+1,p[2],"#fff1c8"); c:px(p[1],p[2]-1,"#fff1c8"); c:px(p[1],p[2]+1,"#fff1c8"); c:px(p[1],p[2],"#fffaf0") end
-- crescent moon
local moon = c:ellipse(200, 26, 8, 8); moon:cut(c:ellipse(204, 23, 7, 7)); c:fill(moon, "#fff1c8")
-- far hills + acacia silhouette
c:fill(L.below(c, function(x) return 78 - 6 * math.sin(x / 28 + 1) end), "#2a2a5a")
c:fill(L.below(c, function(x) return 86 - 3 * math.sin(x / 14) end), "#26224e")
c:fill(c:rect(196, 64, 197, 76), "#14102c"); c:fill(c:ellipse(197, 62, 12, 3), "#14102c")
-- small distant hut with a lit window
c:fill(c:poly({ {214, 82}, {222, 72}, {230, 82} }), "#14102c"); c:fill(c:rect(215, 82, 229, 88), "#1c1840"); c:fill(c:rect(220, 83, 222, 86), "#f5cf6a")
-- ground
c:part(L.below(c, function(x) return 90 end), GV.ramp("#5a4a3a", { shade = "#3a3028", deep = "#2a2018" }), { cres = 6, deep = 9, outline = false, gloss = false })
c:fill(L.below(c, function(x) return 108 + 2 * math.sin(x / 18) end), "#4a3a30")

-- the hut: mud walls, conical thatch roof, glowing round-arched door ------------------------------------
local HX = 66
c:part(c:rect(HX - 30, 70, HX + 30, 112), GV.ramp("#b8784a", { shade = "#8a5030", deep = "#5a341c" }), { cres = 5, deep = 9, gloss = false })
-- painted band on the wall (Ethiopian-style zigzag)
for x = HX - 28, HX + 28, 4 do c:px(x, 76, "#e8a317"); c:px(x + 1, 77, "#e8a317"); c:px(x + 2, 76, "#d6322b"); c:px(x + 3, 77, "#d6322b") end
-- roof
c:part(c:poly({ {HX - 38, 74}, {HX, 30}, {HX + 38, 74} }), GV.ramp("#c9a050", { shade = "#8a6a30", deep = "#5a4220", rim = "#f0d890" }), { cres = 8, deep = 13, gloss = false })
for k = 1, 5 do local yy = 30 + k * 8; local hw = k * 6; c:fill(c:rect(HX - hw, yy, HX + hw, yy), "#8a6a30"); end
for k = 0, 8 do c:px(HX - 30 + k * 7, 72, "#8a6a30") end
c:part(c:ellipse(HX, 30, 2, 2), GV.ramp("#e8a317"), { flat = true })
-- doorway: lit warm interior
c:part(c:rrect(HX - 9, 84, HX + 9, 112, 8), GV.ramp("#f08a24", { shade = "#d6602a", deep = "#a8381f" }), { cres = 3, deep = 5, gloss = false, outline = false })
c:fill(c:rect(HX - 6, 94, HX + 6, 112), "#f8c060")
-- silhouettes inside: a stool and hanging pots
c:fill(c:rect(HX - 4, 104, HX + 3, 106), "#7a4a1f"); c:fill(c:rect(HX - 3, 106, HX - 3, 112), "#7a4a1f"); c:fill(c:rect(HX + 2, 106, HX + 2, 112), "#7a4a1f")
c:fill(c:ellipse(HX + 1, 98, 2, 2), "#4a2c1a")
-- window
c:part(c:rect(HX + 16, 86, HX + 23, 94), GV.ramp("#f5cf6a"), { flat = true, gloss = false, outline = false, contour = "#2a1a10" })
-- warm rim glow on the wall from the fire (hard dashes)
for y = 96, 110, 3 do c:px(HX + 24, y, "#f0a050"); c:px(HX + 25, y, "#f0a050") end

-- woven red mat on the ground (the ceremony floor)
local mat = c:ellipse(150, 118, 70, 11)
c:part(mat, GV.ramp("#a8241f"), { cres = 4, deep = 6, gloss = false, outline = false, contour = false })
for x = 84, 214, 8 do c:fill(c:rect(x, 111, x + 3, 125), "#e8a317"):seam({ {x, 112}, {x, 124} }, { free = true, on = 1, off = 1, gap = "#6a1a14" }) end
-- fresh-cut grass strewn on the floor
for _, p in ipairs({ {96,120},{110,126},{134,127},{160,126},{184,124},{200,120},{120,114},{176,112},{90,116} }) do
  c:px(p[1], p[2], "#7ab55c"); c:px(p[1] + 1, p[2] - 1, "#a4b86a"); c:px(p[1] + 2, p[2], "#7ab55c")
end

-- brazier with glowing coals (left of the mat)
local BX, BY = 112, 108
c:part(c:poly({ {BX - 8, BY - 2}, {BX + 8, BY - 2}, {BX + 5, BY + 8}, {BX - 5, BY + 8} }), GV.ramp("#4a4a56", { shade = "#2e2e3a", deep = "#1c1c28" }), { cres = 2, deep = 4, gloss = false })
c:fill(c:ellipse(BX, BY - 2, 7, 2), "#e0501f"); for _, x in ipairs({ BX - 4, BX - 1, BX + 3 }) do c:px(x, BY - 3, "#f8c060"); c:px(x + 1, BY - 2, "#f5cf6a") end
for _, p in ipairs({ {BX - 3, BY - 8}, {BX + 2, BY - 12}, {BX - 2, BY - 15} }) do c:px(p[1], p[2], "#f08a24") end
-- incense smoke curling up
for k = 0, 14 do local x = BX + 9 + math.floor(math.sin(k / 2) * 2 + 0.5); c:px(x, BY - 8 - k, (k % 3 == 2) and "#8a8ab0" or "#b8b8d8") end
-- pan roasting? small clay censer next to the brazier
c:part(c:ellipse(BX + 10, BY + 6, 4, 3), GV.ramp("#2a2230"), { cres = 1, deep = 2, gloss = false, outline = false })

-- tray of three small cups with gold rims, on a low stool
local TX, TY = 176, 116
c:part(c:ellipse(TX, TY + 3, 17, 4), GV.ramp("#b07a45"), { cres = 2, deep = 4, gloss = false })
for i = -1, 1 do
  local cx = TX + i * 10
  c:part(c:rect(cx - 3, TY - 4, cx + 3, TY + 2), GV.ramp("#fffaf0", { shade = "#d0c4b0", deep = "#a89888" }), { flat = true, gloss = false, outline = false, contour = "#4a2c1a" })
  c:fill(c:rect(cx - 2, TY - 4, cx + 2, TY - 4), "#4a2c1a"); c:px(cx - 3, TY - 4, "#e8a317"); c:px(cx + 3, TY - 4, "#e8a317")
  c:px(cx - 2, TY - 2, "#fffaf0")
  -- little steam
  c:px(cx, TY - 8, "#b8b8d8"); c:px(cx + 1, TY - 10, "#8a8ab0"); c:px(cx, TY - 12, "#b8b8d8")
end
-- three tiny blessings floating over the cups: spark (wake), speech dots (talk), star halo (bless)
local function bolt(x, y) c:px(x + 1, y, "#f5cf6a"); c:px(x, y + 1, "#f5cf6a"); c:px(x + 1, y + 1, "#fff1c8"); c:px(x + 2, y + 1, "#f5cf6a"); c:px(x + 1, y + 2, "#f5cf6a") end
bolt(TX - 12, TY - 22)
c:fill(c:rect(TX - 2, TY - 22, TX + 3, TY - 20), "#f2e4c0"); c:px(TX - 1, TY - 19, "#f2e4c0"); c:px(TX, TY - 21, "#4a6ea8"); c:px(TX + 2, TY - 21, "#4a6ea8")
c:fill(c:ellipse(TX + 10, TY - 22, 3, 1), "#f5cf6a"); c:px(TX + 10, TY - 24, "#fff1c8"); c:px(TX + 10, TY - 20, "#fff1c8")

-- the host: kneeling on the left of the tray, white netela shawl with a coloured border, holds the jebena high
local KX, KY = 146, 104
c:part(c:ellipse(KX, KY + 6, 12, 9), WHT, { cres = 4, deep = 7, gloss = false })
c:fill(c:rect(KX - 11, KY + 8, KX + 11, KY + 9), "#d6322b"); c:fill(c:rect(KX - 11, KY + 10, KX + 11, KY + 10), "#e8a317")
c:part(c:ellipse(KX - 2, KY - 8, 5, 6), WHT, { cres = 2, deep = 4, gloss = false })
-- head and hair, headband
c:part(c:ellipse(KX - 1, KY - 18, 9, 8), SKIN, { cres = 3, deep = 5, gloss = false })
c:part(c:ellipse(KX - 1, KY - 24, 9, 4), GV.ramp("#2a1a10", { rim = "#5a4030" }), { cres = 1, deep = 2, gloss = false, outline = false, contour = false })
c:fill(c:rect(KX - 9, KY - 22, KX + 7, KY - 22), "#e8a317")
c:eye(KX - 6, KY - 20); c:eye(KX + 1, KY - 20)
c:px(KX - 3, KY - 13, "#2a1a10"); c:px(KX - 2, KY - 12, "#2a1a10"); c:px(KX - 1, KY - 12, "#2a1a10"); c:px(KX, KY - 13, "#2a1a10")
-- arm raised with the jebena (clay pot, long neck, spout tilted)
c:part(c:ellipse(KX + 10, KY - 3, 5, 4), SKIN, { flat = true, gloss = false })
local JX, JY = KX + 17, KY - 14
c:part(c:ellipse(JX, JY + 6, 7, 7), GV.ramp("#3a2a30", { rim = "#6a5a60", shade = "#2a1c22", deep = "#1c1218" }), { cres = 3, deep = 5, gloss = false })
c:part(c:poly({ {JX - 3, JY - 2}, {JX + 3, JY - 2}, {JX + 2, JY + 6}, {JX - 3, JY + 6} }), GV.ramp("#3a2a30", { rim = "#6a5a60" }), { flat = true, gloss = false, outline = false })
c:part(c:ellipse(JX, JY - 4, 3, 2), GV.ramp("#3a2a30"), { flat = true, gloss = false, outline = false })
c:fill(c:rect(JX - 5, JY - 4, JX - 4, JY + 4), "#7a4a1f")                   -- handle
c:fill(c:rect(JX + 6, JY + 2, JX + 8, JY + 3), "#3a2a30"); c:px(JX + 9, JY + 4, "#3a2a30")  -- spout
c:px(JX - 4, JY + 2, "#e8a317"); c:px(JX, JY + 8, "#e8a317"); c:px(JX + 4, JY + 8, "#e8a317")  -- decorative bands
-- the thin stream of coffee from spout into the middle cup
for y = JY + 5, TY - 4 do c:px(TX + 0 + 0, y, "#6a3a1a"); end
for k = 0, 4 do c:px(JX + 9 - k * 2, JY + 5 + k, "#6a3a1a") end

-- popcorn bowl and tiny roasting pan in the foreground
local PX2, PY2 = 64, 124
c:part(c:ellipse(PX2, PY2, 11, 5), GV.ramp("#b07a45"), { cres = 2, deep = 4, gloss = false })
for _, p in ipairs({ {-6,-4},{-2,-6},{3,-5},{7,-3},{0,-3},{-4,-2},{5,-1} }) do c:part(c:ellipse(PX2 + p[1], PY2 + p[2], 2, 2), GV.ramp("#fff3d0", { shade = "#e8d8a8", deep = "#c0a870" }), { flat = true, gloss = false, outline = false }) end
c:ground(PX2, PY2 + 6, 13, 2)
-- fire light spill: warm pixels on the mat near the brazier
for _, p in ipairs({ {BX - 10, 118}, {BX - 6, 121}, {BX + 8, 119}, {BX + 14, 117} }) do c:px(p[1], p[2], "#f08a24"); c:px(p[1] + 1, p[2], "#f5cf6a") end

L.finish(c, SLUG)
