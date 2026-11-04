-- grapefruit-marmalade (dC10 first draft): glass jar of ruby marmalade, gold lid, cream label with a fruit half.
-- quirk: a sticky drip has run over the lid rim and down the glass.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC10.lua")
local B, H, HP, X, K = D.B, D.H, D.HP, D.X, D.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new('grapefruit-marmalade')
local JAM = { '#5a1830', '#8e2644', '#c0394f', '#e0566a', '#f47c86', '#ffb0a8' }
c:groundShadow(32, 54, 15, 2.5)
local body = c:rrect(18, 21, 45, 53, 5)
D.cyl(c, body, JAM, 18, 45)
-- peel strands in the jam
for _, p in ipairs{ {22,28},{30,26},{38,30},{25,46},{35,48},{41,42} } do
  c:px(p[1], p[2], '#f5b23e') c:px(p[1]+1, p[2], '#f5b23e') c:px(p[1]+2, p[2]+1, '#de8a34')
end
-- glass rim and gleam
for y = 24, 49 do c:px(19, y, '#ffd8d0') end
c:px(21, 25, D.CREAM) c:px(21, 26, D.CREAM)
-- lid
local lid = D.rrect(c, 19, 14, 44, 21, 2, 'gold', 2)
for x = 21, 42, 3 do c:px(x, 17, '#8f4a1f') end
c:px(22, 15, D.CREAM) c:px(23, 15, D.CREAM)
-- label
local lab = c:rect(24, 31, 39, 44) B.lit(c, lab, 'wood', 2)
c:fillMask(c:rect(25, 32, 38, 43), '#fff4d6')
c:fillMask(c:ellipse(31.5, 38, 4.5, 4.5), '#f5809f')
c:fillMask(c:ellipse(31.5, 38, 3, 3), '#ffc4d8')
for _, p in ipairs{ {31,35,31,41}, {28,38,35,38}, {29,36,34,40}, {34,36,29,40} } do B.ln(c, p[1], p[2], p[3], p[4], '#f5809f') end
c:px(25, 33, '#d98322') c:px(38, 42, '#d98322')
-- quirk: drip
for y = 21, 29 do c:px(43, y, JAM[4]) end c:px(44, 22, JAM[4]) c:px(43, 30, JAM[3]) c:px(43, 31, JAM[2]) c:px(42, 30, JAM[5])
D.fin()
