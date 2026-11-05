-- stage-gather (ui P3_U5)
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = app.params.out
local floor,max,min,sqrt,sin,cos=math.floor,math.max,math.min,math.sqrt,math.sin,math.cos
local L = {-0.5,-0.6,0.62}
local function shade(c,m, cx, cy, rx, ry, ramp, bias)
  m:each(function(x,y)
    local nx,ny=(x-cx)/rx,(y-cy)/ry
    local r2=min(nx*nx+ny*ny,0.98)
    local nz=sqrt(1-r2)
    local v=(nx*L[1]+ny*L[2]+nz*L[3])*0.5+0.5+(bias or 0)
    c:px(x,y,ramp[1+floor(max(0,min(0.999,v))*#ramp)])
  end)
end
local function lin(c,m,x0,y0,x1,y1,ramp,bias)
  local dx,dy=x1-x0,y1-y0; local l2=dx*dx+dy*dy
  m:each(function(x,y)
    local t=((x-x0)*dx+(y-y0)*dy)/l2+(bias or 0)
    c:px(x,y,ramp[1+floor(max(0,min(0.999,t))*#ramp)])
  end)
end
local function fn(x0,y0,x1,y1,f)
  local m=HP.mask()
  for y=y0,y1 do for x=x0,x1 do if f(x,y) then m:set(x,y) end end end
  return m
end
local c = HP.canvas{ w=96, h=96, scale=1, name="stage-gather" }
local wood={"#4a2c1a","#6e4426","#9a6a38","#c4924e","#e0b872"}
local lf={"#1f4a24","#2f7a34","#4aa044","#7cc85a"}
local mush={"#9a7a5a","#c8a47a","#e8d0a8","#f8ecd0"}
local red={"#5a1420","#8a2030","#c0343a","#e8604a"}
c:groundShadow(48,90,38,3)
local o=c:ellipse(48,40,28,28); o:cut(c:ellipse(48,42,22,23)); o:clip(c:rect(0,0,95,50))
shade(c,o,44,34,29,30,wood)
-- contents
local l1=c:poly{{20,52},{24,36},{37,28},{41,44}}; lin(c,l1,20,30,41,50,lf)
c:fillMask(c:line({{24,50},{34,34}},1):clip(l1),lf[4])
local l2=c:poly{{56,50},{64,34},{78,30},{76,48}}; lin(c,l2,56,30,78,50,lf)
c:fillMask(c:line({{60,48},{72,34}},1):clip(l2),lf[1])
local st=c:rect(41,42,48,52); lin(c,st,41,0,48,0,mush,0.1)
local cap=c:ellipse(44,42,12,8):clip(c:rect(0,0,95,43)); shade(c,cap,42,43,12,8,mush,0.1)
c:px(40,38,mush[2]); c:px(46,37,mush[2]); c:px(44,40,mush[2])
local pep=c:poly{{51,34},{57,26},{63,34},{60,50},{53,50}}; shade(c,pep,56,38,7,12,red)
c:fillMask(c:rect(58,22,60,26),lf[2]); c:px(60,21,lf[3])
-- body
local body=c:poly{{12,52},{84,52},{80,86},{16,86}}
body:each(function(x,y)
  local ry=(y-56)%5; local r=floor((y-56)/5)
  local col=wood[3]
  if ry==0 then col=wood[2]
  elseif ry==1 then col=wood[4]
  elseif (x+(r%2)*5)%10==0 then col=wood[2] end
  if x>72 and ry~=0 then col=(ry==1) and wood[3] or wood[2] end
  if y>80 then col=(col==wood[4]) and wood[3] or wood[2] end
  c:px(x,y,col)
end)
for x=16,80 do c:px(x,52,wood[2]); c:px(x,53,wood[2]) end
-- rim
local rim=c:rrect(8,46,88,56,2); lin(c,rim,0,46,0,57,wood,0.12)
for x=10,86,4 do c:px(x,50,wood[2]); c:px(x+1,51,wood[2]) end
for x=9,86 do c:px(x,47,wood[5]) end
-- quirk: ladybug on rim
local lb=c:ellipse(70,46,3,2); shade(c,lb,69,45,3,2,red,0.1)
c:px(70,44,"#2b1c26"); c:px(68,46,"#2b1c26"); c:px(71,47,"#2b1c26"); c:px(73,45,"#2b1c26")
c:sparkle(14,38)
c:finish{outline=true}
HP.assertClean(c)
c:save{aseprite=OUT.."stage-gather.aseprite", png=OUT.."stage-gather.png", scale=1}
