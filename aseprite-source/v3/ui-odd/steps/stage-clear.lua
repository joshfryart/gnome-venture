-- stage-clear (ui P3_U5)
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
local c = HP.canvas{ w=96, h=96, scale=1, name="stage-clear" }
local wood={"#3e2418","#5e3a22","#82532f","#a8764a","#c9985f"}
local steel={"#2e3a4c","#4a5e78","#6e88a6","#97b0c8","#c4d8e8"}
local leather={"#4a1820","#7a2a2c","#a8443a","#cc6648"}
local leaf={"#1f4a24","#2f7a34","#4aa044","#7cc85a"}
c:groundShadow(48,90,36,3)
-- wood chips
for _,p in ipairs{{58,82},{70,86},{80,80},{64,88},{86,87}} do
  c:fillMask(c:rect(p[1],p[2],p[1]+3,p[2]+1),wood[4]); c:fillMask(c:rect(p[1]+1,p[2]+2,p[1]+3,p[2]+2),wood[2]); c:px(p[1],p[2],wood[5])
end
-- sprout
for y=82,86 do c:px(35,y,leaf[2]) end
c:fillMask(c:rect(32,81,34,82),leaf[3]); c:fillMask(c:rect(36,80,38,81),leaf[4]); c:px(33,81,leaf[4]); c:px(37,80,leaf[3])
-- handle
local h=c:line({{23,83},{56,30}},6)
lin(c,h,36,54,42,58,wood)
h:each(function(x,y)
  local s=(x-23)*0.529+(y-83)*(-0.849)
  if s>12 and s<33 and floor(s/3)%2==0 then
    local t=((x-39)*0.85+(y-56)*0.52)/6+0.5
    c:px(x,y,leather[1+floor(max(0,min(0.999,t))*#leather)])
  elseif s>3 and s<62 and ((x*7+y*3)%11==0) then c:px(x,y,wood[2]) end
end)
local knob=c:ellipse(22,85,4,3); shade(c,knob,21,84,4,3,wood)
-- poll + blade
local poll=c:poly{{43,22},{54,19},{57,33},{46,33}}
lin(c,poll,43,19,57,33,steel,-0.1)
local blade=c:poly{{50,22},{62,11},{82,7},{89,20},{83,40},{66,46},{58,38}}
blade:cut(c:rect(87,25,91,28))
lin(c,blade,50,10,86,44,steel)
-- bevel and edge
c:fillMask(c:line({{84,9},{88,20},{86,24}},1):clip(blade),steel[5])
c:fillMask(c:line({{86,29},{84,38}},1):clip(blade),steel[5])
c:fillMask(c:line({{62,14},{80,10}},1):clip(blade),steel[4])
c:fillMask(c:line({{58,38},{66,44},{82,39}},1):clip(blade),steel[1])
c:fillMask(c:line({{60,26},{70,22},{74,32}},1):clip(blade),steel[2])
c:px(64,21,steel[5]); c:px(64,31,steel[5]); c:px(63,26,steel[1])
c:sparkle(76,16)
c:finish{outline=true}
HP.assertClean(c)
c:save{aseprite=OUT.."stage-clear.aseprite", png=OUT.."stage-clear.png", scale=1}
