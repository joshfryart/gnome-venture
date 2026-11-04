-- tomato (lean W2_35)
-- plump ribbed beefsteak, star calyx, curled vine stub; quirk: a tiny split showing seedy gel
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w=64, h=64, scale=1, name="tomato" }
local RD={"#4a1226","#7a1e2e","#b3302c","#dc4a30","#f27a45","#ffb070"}
local GR={"#1d3d27","#2c5a2e","#438a3a","#6ab04a","#98d062"}
c:groundShadow(32,52,15,2)
local body=c:ellipse(32,35,17,14)
body:cut(c:ellipse(32,22,4,2))
local n=X.pillow(body,14)
local bias={}
body:each(function(x,y) local d=abs(((x-32)/17))
  local lobe=sin((x-32)*0.55)
  if lobe>0.93 and y>26 then bias[K(x,y)]=-1 end end)
G.toneN(c,body,n,RD,{bias=bias})
-- calyx star
local pts={{32,24,22,22},{32,24,42,23},{32,24,25,30},{32,24,40,30},{32,24,32,31}}
for _,p in ipairs(pts) do
  local m=G.blade(p[1],p[2],(p[1]+p[3])/2,(p[2]+p[4])/2-2,p[3],p[4],function(t) return 2.2*sin(pi*(0.1+0.9*t))^0.7 end)
  G.toneN(c,m,select(2,G.blade(p[1],p[2],(p[1]+p[3])/2,(p[2]+p[4])/2-2,p[3],p[4],function(t) return 2.2*sin(pi*(0.1+0.9*t))^0.7 end)),GR,{})
end
local sm,sn=G.tube({{32,24},{32,19},{34,14},{37,12}},function(t) return 2.2-0.8*t end)
G.toneN(c,sm,sn,GR,{})
c:put(32,24,GR[1]) c:put(31,24,GR[1]) c:put(33,24,GR[1])
-- spec
for _,p in ipairs{{22,29},{23,28},{22,30},{23,29},{24,28}} do c:put(p[1],p[2],RD[6]) end
c:put(21,31,RD[5])
-- split quirk
for i=0,4 do c:put(41+floor(i*0.5),34+i,RD[1]) end
c:put(41,35,"#e8c060") c:put(42,36,"#e8c060") c:put(43,38,"#c89a3c")
G.save(c,"tomato")
