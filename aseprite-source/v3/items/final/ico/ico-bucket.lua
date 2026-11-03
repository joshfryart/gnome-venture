-- ico-bucket first draft (Sonnet). quirk: a fish tail flopping out of the bucket
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-bucket"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

D.lit(c:poly{{37,26},{35,16},{41,20},{45,13},{44,26}}, EM, 1.5)
local ar = c:line({{14,27},{13,18},{20,9},{32,6},{44,9},{51,18},{50,27}}, 2) D.lit(ar, ST, 1)
local body = c:poly{{13,26},{51,26},{47,55},{17,55}}
D.cyl(body, W, 13, 51)
for _, x in ipairs{19,25,32,38,45} do for y = 27, 54 do if body:has(x,y) then c:px(x,y,W[2]) end end end
for _, r in ipairs{{29,32},{47,50}} do D.cyl(D.isect(body, c:rect(0,r[1],63,r[2])), ST, 13, 51) end
local rim = B.ell(32,26,19,4.5) D.lit(rim, W, 2)
local wt = B.ell(32,26,16,3) D.lit(wt, SE, 1.5)
D.fill(c:rect(13,25,16,28), W[4])
c:px(24,25,D.CR) c:px(25,25,D.CR)
D.fill(c:rect(10,31,11,34), SE[4]) c:px(10,31,SE[6])
D.fin()
