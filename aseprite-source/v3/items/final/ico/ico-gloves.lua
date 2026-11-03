local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-gloves: chunky yellow garden glove with green cuff. quirk: a worn hole at the index fingertip with a pink fingertip poking out.
local c = D.new("ico-gloves")
local YEL = { "#7a4a1c", "#b0701f", "#d9962a", "#f2bb3e", "#fcd86a", "#fff0a8" }
local m = D.rect(17, 30, 44, 50)
for i, f in ipairs({ { 17, 22, 18 }, { 24, 29, 11 }, { 31, 36, 8 }, { 38, 43, 14 } }) do m:add(D.c:rrect(f[1], f[3], f[2], 36, 2)) end
m:add(D.ell(14, 40, 4, 7, -.5)):add(D.ell(13, 44, 4, 6, -.3))
D.lit(m, YEL, 5, { amb = 0.1 })
-- finger seams
for _, x in ipairs({ 23, 30, 37 }) do for y = 24, 36 do D.px(x, y, YEL[2]) end end
for _, x in ipairs({ 23, 30, 37 }) do D.px(x, 37, YEL[2]) end
-- hole + pink fingertip
D.fill(D.c:rrect(24, 11, 28, 15, 1), "#e89a8a") D.px(25, 12, "#ffd0bc") D.fill(D.rect(24, 15, 28, 15), "#b56a5e")
-- cuff
local cuff = D.rect(16, 50, 45, 58)
D.lit(cuff, D.GREEN, 4)
D.px(20, 52, D.GREEN[6]) D.px(21, 52, D.GREEN[6])
c:stitch({ { 18, 56 }, { 43, 56 } })
D.fin()
