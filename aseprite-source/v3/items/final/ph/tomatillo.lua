-- tomatillo (lean W2_35)
-- papery lantern husk with ribs, green fruit peeking below; quirk: a torn husk slit showing fruit
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w=64, h=64, scale=1, name="tomatillo" }
local HUSK={"#6b5238","#98794f","#c4a56e","#e0c88f","#f0e0aa","#fff3cc"}
local FR={"#1f4a2c","#2f6b34","#4d9140","#76b84c","#a3d462","#d2ee8c"}
local ST={"#3b4f26","#5f7a32","#8fa84a","#bcd075"}
c:groundShadow(32,54,13,2)
local fruit=c:ellipse(32,43,11,9)
G.toneN(c,fruit,X.pillow(fruit,9),FR,{})
local husk=c:ellipse(32,32,13,16):add(c:poly{{32,12},{26,20},{38,20}})
husk:cut(c:rect(0,45,63,63))
-- scalloped bottom
for x=19,45 do local s=floor(abs(((x-19)%6)-3)*0.8) for y=44-s+1,46 do husk:cut(c:rect(x,y,x,y)) end end
local hn=X.pillow(husk,13)
G.toneN(c,husk,hn,HUSK,{})
-- ribs
husk:each(function(x,y)
  local u=(x-32)/13
  for _,r in ipairs{-0.8,-0.45,-0.12,0.22,0.58,0.88} do
    local rx=32+r*13*sqrt(max(0,1-((y-32)/16)^2))*1.0
    if abs(x-rx)<0.5 and y>16 and y<44 then c:put(x,y, r>0.1 and HUSK[1] or HUSK[2]) end
  end
  if (y*3+x)%11==0 and X.hash(x,y,3)>0.6 and u<0.3 then c:put(x,y,HUSK[5]) end
end)
-- torn slit quirk showing fruit
for i=0,5 do c:put(36+floor(i*0.4),36+i,FR[4]) c:put(37+floor(i*0.4),36+i,FR[2]) end
c:put(36,36,FR[6])
-- glint
c:put(25,26,HUSK[6]) c:put(26,25,HUSK[6]) c:put(25,27,HUSK[5])
-- stem
local sm,sn=G.tube({{32,12},{32,9},{34,6},{36,5}},function(t) return 1.8-0.5*t end)
G.toneN(c,sm,sn,ST,{})
c:put(30,13,HUSK[1]) c:put(34,13,HUSK[1])
G.save(c,"tomatillo")
