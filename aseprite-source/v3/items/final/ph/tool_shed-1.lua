-- tool_shed-1 (lean W2_35)
-- slate-roofed plank shed with X-braced double door, round window, hung shovel and rake; quirk: a chimney-less weathervane hen
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w=64, h=64, scale=1, name="tool_shed-1" }
local WD={"#3a2316","#5b3820","#7d5230","#a06c3f","#c28c52"}
local SL={"#2e3348","#454c68","#5f6788","#7f87a8","#a3abc8"}
local MT={"#4a4f5e","#7a8196","#aeb5c6","#e0e5f0"}
c:groundShadow(32,54,24,2)
-- walls
local wall=c:rect(12,28,51,52)
wall:each(function(x,y)
  local plank=floor((x-12)/5)
  local base=3+((plank%3==1) and 0 or 1)
  local col=WD[base]
  if (x-12)%5==0 then col=WD[1] end
  if x<20 and (x-12)%5~=0 then col=WD[min(5,base+1)] end
  if y>48 then col=WD[max(1,base-1)] end
  if X.hash(x,y,5)>0.93 and (x-12)%5~=0 then col=WD[1] end
  c:put(x,y,col)
end)
-- roof
local roof=c:poly{{32,6},{56,28},{8,28}}
roof:cut(c:rect(0,0,63,5))
roof:each(function(x,y)
  local row=floor((y-6)/3)
  local col=SL[3]
  if (y-6)%3==2 then col=SL[1] elseif (y-6)%3==0 then col=SL[4] end
  if x<32-(y-6)*0.5 +4 then col=SL[min(5,((y-6)%3==2) and 2 or 4)] end
  if (x+row*3)%7==0 and (y-6)%3~=2 then col=SL[2] end
  c:put(x,y,col)
end)
for x=7,56 do c:put(x,29,SL[1]) end
-- door
local door=c:rect(24,36,39,52)
door:each(function(x,y) c:put(x,y,(x==31 or x==32) and WD[1] or WD[2]) end)
for i=0,15 do
  local y=36+floor(i*16/16)
  c:put(24+i,y,WD[4]) c:put(39-i,y,WD[4])
end
for y=36,52 do c:put(24,y,WD[4]) c:put(39,y,WD[1]) end
for x=24,39 do c:put(x,36,WD[4]) end
c:put(30,44,MT[4]) c:put(33,44,MT[4])
-- window (round) in gable
local win=c:ellipse(32,19,4,4)
G.toneN(c,win,X.pillow(win,4),{"#2a4a6a","#3f7396","#6fa8c8","#a6d6ea","#e6f6fb","#f4fbff"},{})
for y=15,23 do c:put(32,y,SL[1]) end
for x=28,36 do c:put(x,19,SL[1]) end
-- shovel on wall
for y=31,44 do c:put(17,y,WD[1]) c:put(16,y,WD[5]) end
local blade=c:ellipse(16,47,3,4)
G.toneN(c,blade,X.pillow(blade,4),MT,{})
-- rake on wall
for y=31,45 do c:put(46,y,WD[1]) c:put(45,y,WD[5]) end
for x=43,49 do c:put(x,46,MT[2]) end
for x=43,49,2 do c:put(x,47,MT[2]) c:put(x,48,MT[1]) end
-- step
for x=22,41 do c:put(x,53,"#8d8a9c") c:put(x,54,"#5f5c70") end
-- quirk: tiny weathervane hen on peak
c:put(32,5,MT[3]) c:put(33,4,"#d9482f") c:put(34,4,"#d9482f") c:put(33,3,"#d9482f") c:put(35,3,"#f2b632")
G.save(c,"tool_shed-1")
