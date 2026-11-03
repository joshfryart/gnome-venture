local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local floor = math.floor
local c = D.new("apricot")
-- apricot: two velvety orange apricots, one whole with a blushed cheek and cleft, one halved showing its stone. quirk: a stray fuzz of peach down catches the light on the whole one.
D.shadow(32, 56, 20, 2.5)
-- half (right, behind)
D.E(41, 36, 12, 12, 0, D.ORG, 6)
D.E(41, 37, 8.5, 8.5, 0, {"#c25a24","#e8782e","#ff9a3c","#ffb450","#ffcc70","#ffe08a"}, 4)
D.E(41, 38, 4, 5, 0.2, D.BRN, 2.5)
D.px(39, 35, "#e4a874") D.px(40, 34, "#e4a874")
-- whole (left front)
local w = c:ellipse(23, 40, 12, 11.5)
D.lit(w, {"#a83a1c","#d05a22","#f0802c","#ffa040","#ffc060","#ffe08a"}, 6)
-- red blush
for y = 36, 52 do for x = 27, 34 do if w:has(x, y) and ((x + y) % 2 == 0) and x - 25 + (y - 36) * 0.3 > 4 then D.px(x, y, "#e8503a") end end end
-- cleft
D.ln(25, 30, 27, 38, "#c25a24") D.ln(27, 38, 27, 46, "#a83a1c")
-- stem + leaf
D.ln(23, 30, 22, 25, "#51302b") D.scrap(23, 26, 12, 14, 3.5, D.LEAF)
D.px(17, 36, "#fff4d6") D.px(18, 36, "#fff4d6") D.px(17, 37, "#fff4d6")
for _, p in ipairs{{15,42},{16,45},{20,31}} do D.px(p[1], p[2], "#ffd890") end
D.fin()
