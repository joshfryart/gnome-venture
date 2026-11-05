-- stage-light (ui P3_U5)
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
local c = HP.canvas{ w=96, h=96, scale=1, name="stage-light" }
local iron={"#241f30","#3a3450","#524b6c","#6f688c","#8e88aa"}
local glow={"#a8541e","#d47a2c","#f0a838","#fbc850","#fddf84"}
c:groundShadow(48,91,28,3)
-- handle ring
local ring=c:ellipse(48,13,13,10); ring:cut(c:ellipse(48,14,9,6)); shade(c,ring,44,10,14,11,iron)
-- cap and collar
local cap=c:poly{{39,22},{57,22},{71,35},{25,35}}; lin(c,cap,25,22,71,35,iron,0.05)
c:fillMask(c:line({{40,24},{30,33}},1),iron[5])
local col=c:rect(37,18,59,23); lin(c,col,0,18,0,24,iron,0.1)
-- glass
local gl=c:rect(33,36,63,69)
gl:each(function(x,y)
  local d=sqrt(((x-48)/1.0)^2+((y-54)/1.3)^2)
  local i=d<6 and 5 or d<11 and 4 or d<16 and 3 or d<21 and 2 or 1
  c:px(x,y,glow[i])
end)
for y=40,48 do c:px(36,y,glow[5]) end
c:px(37,39,glow[5]); c:px(36,50,glow[4])
-- flame
c:fillMask(c:poly{{48,40},{54,49},{55,57},{48,64},{41,57},{42,49}},"#f08a30")
c:fillMask(c:poly{{48,44},{52,51},{52,57},{48,62},{44,57},{45,51}},"#fbc040")
c:fillMask(c:poly{{48,50},{50,55},{48,60},{46,55}},"#fff0b0")
c:px(48,65,"#4a3a40"); c:px(48,66,"#4a3a40")
-- frame
for _,r in ipairs{{30,34,33,72},{63,34,66,72},{30,34,66,36},{30,68,66,71}} do
  local m=c:rect(r[1],r[2],r[3],r[4]); lin(c,m,r[1],r[2],r[3]+1,r[4]+1,iron,0.05)
end
c:px(31,38,iron[5]); c:px(31,50,iron[5])
-- base and feet
local base=c:rrect(24,71,72,80,2); lin(c,base,0,71,0,81,iron,0.08)
for x=28,68,6 do c:px(x,75,iron[2]) end
for _,x in ipairs{28,62} do local f=c:rect(x,80,x+6,84); lin(c,f,0,80,0,85,iron) end
-- quirk: moth
c:fillMask(c:poly{{74,30},{80,34},{80,42},{73,40}},"#d8c4ec"); c:fillMask(c:poly{{86,30},{80,34},{80,42},{87,40}},"#b8a0d4")
c:fillMask(c:rect(79,33,80,44),"#6a4a50"); c:px(78,31,"#6a4a50"); c:px(81,31,"#6a4a50")
c:px(75,33,"#f4e8fc"); c:px(76,34,"#f4e8fc")
c:finish{outline=true}
HP.assertClean(c)
c:save{aseprite=OUT.."stage-light.aseprite", png=OUT.."stage-light.png", scale=1}
