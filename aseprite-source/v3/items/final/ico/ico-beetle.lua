-- ico-beetle first draft (Sonnet). quirk: a leaf worn as a tiny hat
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-beetle"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

local function legs(pts) D.lit(c:line(pts, 2), D.DKP, 1) D.lit(c:line((function() local t={} for i,p in ipairs(pts) do t[i]={63-p[1],p[2]} end return t end)(), 2), D.DKP, 1) end
legs{{22,31},{14,27},{9,29}} legs{{21,38},{12,38},{8,41}} legs{{22,45},{14,50},{10,54}}
legs{{29,13},{26,8},{24,5}}
local sh = B.ell(32,38,12,15) D.lit(sh, D.TEAL, 5)
for y = 24, 52 do if sh:has(32,y) then c:px(32,y,D.TEAL[1]) end end
c:px(27,30,D.CR) c:px(28,30,D.CR) c:px(27,31,D.CR)
D.lit(B.ell(32,23,8,5), D.DKP, 2.5)
D.lit(B.ell(32,16,5.5,4.5), D.DKP, 2)
D.fill(c:rect(28,15,29,16), D.CR) D.fill(c:rect(34,15,35,16), D.CR)
local lf = B.ell(37,11,6,2.8,-0.45) D.lit(lf, MO, 1.5)
D.ln(c,32,13,42,9,MO[2])
D.fin()
