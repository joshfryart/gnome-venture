-- ico-moon first draft (Sonnet). quirk: the crescent moon wears a nightcap and snores a tiny z
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-moon")
local MN = { "#b08a3a", "#d9a935", "#f5c84a", "#ffe38a", "#fff0b0", "#fffadc" }
local cres = D.ell(30, 34, 19, 19):cut(D.ell(40, 30, 16, 16))
D.lit(cres, MN, 6, { amb = .15 })
-- craters
D.fill(D.ell(20, 38, 2, 2), MN[2]) D.fill(D.ell(24, 46, 2, 1), MN[2]) D.fill(D.ell(18, 30, 1, 1), MN[2])
c:px(19, 37, MN[5])
-- sleeping eye
D.fill(c:rect(22, 33, 25, 33), "#7a4a1f") c:px(22, 34, "#7a4a1f") c:px(25, 34, "#7a4a1f")
D.fill(c:rect(22, 40, 24, 40), "#c94f84")
-- nightcap on top tip
local cap = c:poly{ {22, 18}, {36, 12}, {42, 7}, {44, 13}, {38, 19}, {28, 24} }
D.lit(cap, D.PURP, 2.5)
D.fill(c:rect(24, 19, 37, 21), D.CREAM[4]) 
D.fill(D.ell(45, 9, 3, 3), CR)
c:px(44, 8, "#ffffff" == nil and CR or "#fbfcff")
-- z and star
for _, p in ipairs{ {47,24},{48,24},{49,24},{48,25},{47,26},{47,27},{48,27},{49,27} } do c:px(p[1], p[2], "#8f77d0") end
c:sparkle(52, 44)
D.fin()
