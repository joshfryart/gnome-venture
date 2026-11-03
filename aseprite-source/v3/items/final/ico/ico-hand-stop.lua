local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-hand-stop: open flat hand held up, palm out. quirk: a plaster on the little finger and a tiny crease heart on the palm.
local c = D.new("ico-hand-stop")
local SK = { "#9a4f45", "#c9786a", "#e69a82", "#f4b79a", "#ffd2b4", "#ffe6cf" }
local m = D.c:rrect(19, 30, 43, 53, 5)
for _, f in ipairs({ { 19, 23, 19 }, { 25, 29, 7 }, { 31, 35, 4 }, { 37, 41, 9 } }) do m:add(D.c:rrect(f[1], f[3], f[2] + 1, 36, 2)) end
m:add(D.ell(15, 41, 4, 7, -.6)):add(D.ell(15, 45, 3, 4))
m:add(D.rect(24, 52, 38, 57))
D.lit(m, SK, 5, { amb = 0.1 })
for _, x in ipairs({ 24, 30, 36 }) do for y = 26, 36 do if D.c:rect(0,0,0,0) then end end end
for _, x in ipairs({ 24, 30, 36 }) do for y = 30, 36 do D.px(x + 1, y, SK[2]) end end
-- crease lines
D.ln(24, 43, 30, 41, SK[2]) D.ln(30, 41, 38, 42, SK[2])
-- plaster on pinky
D.fill(D.rect(37, 22, 41, 26), "#e8c488") D.fill(D.rect(37, 23, 41, 23), "#c89a5e") D.px(39, 25, "#f6e0b0") D.px(38, 24, "#c89a5e") D.px(40, 24, "#c89a5e")
-- cuff
D.lit(D.rect(22, 54, 40, 58), D.BLUE, 3)
D.px(24, 55, D.BLUE[6]) D.px(25, 55, D.BLUE[6])
D.fin()
