-- stage-feed (ui P3pilot)
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = app.params.out
local c = HP.canvas{ w=96, h=96, scale=1, name="stage-feed" }
local L = {-0.5,-0.6,0.62}
local function shade(m, cx, cy, rx, ry, ramp, bias)
  m:each(function(x,y)
    local nx,ny=(x-cx)/rx,(y-cy)/ry
    local r2=math.min(nx*nx+ny*ny,0.98)
    local nz=math.sqrt(1-r2)
    local v=(nx*L[1]+ny*L[2]+nz*L[3])*0.5+0.5+(bias or 0)
    local i=1+math.floor(math.max(0,math.min(0.999,v))*#ramp)
    c:px(x,y,ramp[i])
  end)
end
local cop={"#4a2420","#7a3a26","#a85430","#d17a3a","#eca85a","#f8d58a"}
local soup={"#5e5a1c","#85822a","#a9a63a","#cfc95a"}
local wood={"#4a2c22","#6e4228","#94603a","#b9854e"}
local steam={"#d9a26a","#f3d9a8","#fff0cf"}
c:groundShadow(48,90,30,3)
-- legs
for _,lx in ipairs{24,45,66} do
  local m=c:rrect(lx,78,lx+5,89,1); shade(m,lx+2.5,84,4,7,cop,-0.1)
end
-- handles (rings)
for _,s in ipairs{-1,1} do
  local cx=48+s*34
  local o=c:ellipse(cx,58,6,8); local i=c:ellipse(cx,58,3,5)
  o:cut(i); shade(o,cx,58,7,9,cop,-0.05)
end
-- body
local body=c:ellipse(48,60,30,24); body:clip(c:rect(0,44,95,95)):add(HP.mask())
shade(body,45,56,31,26,cop)
-- rivet band
for x=24,72,6 do c:px(x,66,"#f8d58a"); c:px(x+1,66,"#f8d58a"); c:px(x+1,67,"#7a3a26") end
-- rim + soup
local rim=c:ellipse(48,42,32,8); shade(rim,44,40,33,9,cop,0.05)
local sp=c:ellipse(48,42,27,5); shade(sp,44,41,28,6,soup,0.1)
-- soup bubbles & quirk: carrot chunk
c:px(36,41,"#e8e08a"); c:px(37,41,"#e8e08a"); c:px(58,43,"#e8e08a"); c:px(40,44,"#6e6a22")
local car=c:poly{{51,39},{57,36},{60,38},{54,42}}
car:each(function(x,y) c:px(x,y,(x+y)%5==0 and "#e0662a" or "#f48a34") end)
c:px(52,39,"#ffc070"); c:px(55,37,"#ffc070")
c:line({{58,36},{60,34}},1):each(function(x,y) c:px(x,y,"#6fa83a") end)
-- ladle
local h=c:line({{74,10},{62,38}},3); shade(h,66,24,5,18,wood)
local bowl=c:ellipse(62,40,5,3); shade(bowl,61,39,5,3,wood)
c:px(74,10,"#b9854e")
-- steam wisps
local function wisp(x0,y0,h2)
  for t=0,h2 do
    local x=x0+math.floor(3*math.sin(t*0.45))
    local y=y0-t
    local w=(t<3 or t>h2-3) and 1 or 2
    for k=0,w do c:px(x+k,y, k==0 and steam[3] or steam[2]) end
    c:px(x+w+1,y,steam[1])
  end
end
wisp(30,34,26); wisp(44,31,28); wisp(60,32,18)
c:sparkle(18,50)
c:finish{outline=true}
HP.assertClean(c)
c:save{aseprite=OUT.."stage-feed.aseprite", png=OUT.."stage-feed.png", scale=1}
