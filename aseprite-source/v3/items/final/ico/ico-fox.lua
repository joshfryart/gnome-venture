local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-fox: front-facing fox head, pointed ears, cream cheeks and muzzle.
-- quirk: a stray green leaf is caught between its ears.
local c = D.new("ico-fox")
local head = c:ellipse(32, 36, 19, 14)
head:add(c:poly{ {12,28},{13,5},{29,19} }):add(c:poly{ {52,28},{51,5},{35,19} })
local cheeks = c:poly{ {11,36},{23,35},{32,40},{41,35},{53,36},{46,50},{32,58},{18,50} }
head:add(cheeks)
D.lit(head, D.FOX, 14, { amb = 0.05 })
D.lit(c:poly{ {16,24},{16,12},{25,20} }, { "#2a1218", "#4a2024", "#6a2a2a", "#8a3a30", "#a85a40", "#c87a50" }, 3)
D.lit(c:poly{ {48,24},{48,12},{39,20} }, { "#2a1218", "#4a2024", "#6a2a2a", "#8a3a30", "#a85a40", "#c87a50" }, 3)
local wh = D.isect(cheeks, c:poly{ {11,38},{23,36},{32,42},{41,36},{53,38},{46,50},{32,58},{18,50} })
wh:cut(c:rect(0, 0, 63, 36))
D.lit(wh, D.CREAM, 8, { amb = 0.05 })
D.ln(c, 13, 37, 23, 36, D.FOX[2], D.isect(wh:copy():grow(1), head)) D.ln(c, 51, 37, 41, 36, D.FOX[2])
c:eyeSmall(21, 31) c:eyeSmall(41, 31)
D.fill(c:rect(29, 47, 34, 50), INK) D.fill(c:rect(30, 51, 33, 51), INK) c:px(30, 47, CR)
D.poly(c, { {32,52},{32,53},{29,55} }, INK) D.poly(c, { {32,53},{35,55} }, INK)
c:cheek(16, 43) c:cheek(46, 43)
D.leaf(c, 28, 17, 40, 10, 3, D.GREEN, { 3 })
D.fin()
