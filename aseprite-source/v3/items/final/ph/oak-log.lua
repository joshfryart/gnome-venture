-- oak-log (lean E2_04)
local NAME = "oak-log"
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

local BK={"#2a1a16","#442a20","#664030","#8a5a40","#ac7a58","#d0a078"}
local WD={"#7a4a2a","#a8703c","#cc9858","#e4b878","#f4d49c","#fff0c8"}
local GR={"#4a3a1c","#6a5a28","#8c8c3c"}
local AC={"#5a3418","#8a5224","#b87a34","#dca050"}
local CAP={"#3a2a1c","#5a4028","#7e5a38"}
c:groundShadow(30,54,26,3)
-- branch stub on top left
local stub = c:rrect(12,10,19,26,2)
S(stub,BK,3,"stub")
local stubtop = c:ellipse(15,11,4,2); S(stubtop,WD,2,"stubtop"); P(15,11,WD[2])
-- body
local body = c:rrect(7,21,45,49,5)
local bi,bn = S(body,BK,8,"bark",0.06)
-- bark furrows
for _,col in ipairs{{12,0,30},{18,1,31},{24,2,29},{30,0,31},{36,1,30},{41,2,29}} do
  local x=col[1]
  for y=24,46 do if X.hash(x,y,col[2])>0.18 then local xx=x+floor(sin(y*0.5+x)*1.2); if body:has(xx,y) then P(xx,y,BK[1]); if body:has(xx-1,y) and X.hash(x,y,7)>0.5 then P(xx-1,y,BK[5]) end end end end
end
-- moss patch
for _,p in ipairs{{9,44},{10,44},{11,45},{12,45},{10,45},{9,45},{13,46},{14,46},{11,46}} do if body:has(p[1],p[2]) then P(p[1],p[2],GR[1+(p[1]+p[2])%3]) end end
-- cut end with rings
local face = c:ellipse(46,35,8,14)
S(face,WD,9,"face",0.15)
for _,r in ipairs{{12,6},{8,4},{4,2}} do
  local ring=c:ellipse(46,35,r[2],r[1])
  ring:edge():each(function(x,y) if face:has(x,y) then P(x,y,WD[2]) end end)
end
P(46,35,WD[1]); P(47,35,WD[1])
for y=24,32 do P(46,y,WD[1]) end
-- crack
-- quirk: acorn resting on the log
local nut = c:ellipse(30,15,4,5)
S(nut,AC,3,"acorn")
local cap = c:rrect(25,9,35,14,2)
S(cap,CAP,2,"cap")
for x=26,34,2 do P(x,12,CAP[1]) end
P(30,7,CAP[2]); P(30,8,CAP[1])
spec(nut,X.pillow(nut,3),"#ffe8b0")
spec(body,bn,"#e0b890")

G.save(c, NAME)
