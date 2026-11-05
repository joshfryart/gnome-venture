-- peanut-toast (lean E2_04)
local NAME = "peanut-toast"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function U(...) local m = HP.mask() for _, x in ipairs{...} do m:add(x) end return m end
local function S(m, ramp, R, name, amb)
  local n = X.pillow(m, R or 3)
  return X.tone(c, m, X.light(n, { amb = amb or 0.08, wrap = 0.25 }), ramp, { cuts = CUTS, tok = { r = { name = name or "p" } } }), n
end
local function P(x, y, col) c:put(x, y, col, { r = { name = "d" } }) end
local function spec(m, n, col) local x, y = G.specAt(m, n, 30) if x then P(x, y, col or "#fffbe8") end end

local CR={"#4a2a10","#7a4a1c","#a86c2c","#cc8c3c","#e4a850","#f8c878"}
local CB={"#b8843c","#d8a458","#ecc078","#f8d896","#fff0b8","#fffadc"}
local PB={"#6a3a14","#92561e","#b87a2c","#d89c3c","#ecbc58","#fcdc88"}
local NT={"#6a4a28","#946a3c","#bc9054","#d8b074","#ecc994","#fae6b8"}
c:groundShadow(30,57,24,3)
local bread = U(c:rrect(9,14,51,52,5), c:ellipse(19,15,10,7), c:ellipse(41,15,10,7))
-- bite out of the lower right
for _,b in ipairs{{50,46,6},{46,52,5},{53,38,4}} do bread:cut(c:ellipse(b[1],b[2],b[3],b[3])) end
local bi,bn=S(bread,CR,13,"crust",0.1)
local crumb=bread:copy():shrink(3)
S(crumb,CB,9,"crumb",0.2)
-- crumb pores
crumb:each(function(x,y) if X.hash(x,y,4)>0.93 then P(x,y,CB[2]) end end)
-- peanut butter, slightly irregular, with a drip over the crust at left
local pbm=U(c:rrect(14,19,43,45,6), c:ellipse(29,24,13,7))
pbm:cut(c:ellipse(46,44,9,9))
local pbi,pbn=S(pbm,PB,10,"pb",0.1)
-- swirl
for _,p in ipairs{{20,28},{22,26},{25,25},{29,25},{33,26},{22,33},{26,35},{30,34},{34,33},{37,30},{24,40},{28,41},{32,40}} do if pbm:has(p[1],p[2]) then P(p[1],p[2],PB[2]); P(p[1]-1,p[2]-1,PB[6]) end end
spec(pbm,pbn,"#fffbe0")
-- quirk drip
local drip=c:rrect(12,38,16,50,1)
local dr=U(drip,c:ellipse(14,50,2,2))
S(dr,PB,2,"drip")
P(13,43,PB[6]); P(13,44,PB[6])
-- peanuts in front
local function nut(cx,cy,ang)
  local m=U(c:ellipse(cx-3,cy,4,3),c:ellipse(cx+3,cy,4,3),c:rect(cx-3,cy-2,cx+3,cy+2))
  S(m,NT,3,"pn"..cx)
  m:each(function(x,y) if ((x+y)%3==0) and X.hash(x,y,5)>0.4 then P(x,y,NT[2]) end end)
  P(cx,cy-3,NT[1]); P(cx,cy+3,NT[1]); P(cx,cy-2,NT[2]); P(cx,cy+2,NT[2])
  P(cx-4,cy-1,NT[6])
end
nut(52,53,0)
nut(46,22+36,0)

G.save(c, NAME)
