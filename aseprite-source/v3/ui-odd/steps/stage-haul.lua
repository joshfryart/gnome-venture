-- stage-haul (ui P3_U5)
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
local c = HP.canvas{ w=96, h=96, scale=1, name="stage-haul" }
local cloth={"#5e3e22","#8a6234","#b58a4c","#d6ae6c","#ecd092"}
local rope={"#4a2c14","#7a5226","#a87a3c"}
local bark={"#3a2218","#5a3624","#7c4e30","#9c6a40"}
c:groundShadow(48,91,44,3)
-- sack
local body=c:ellipse(30,64,21,21)
local neck=c:poly{{24,47},{36,47},{39,38},{21,38}}
local tuft=c:ellipse(30,34,12,5)
for _,m in ipairs{tuft,neck,body} do shade(c,m,24,52,26,26,cloth) end
for _,p in ipairs{{20,32},{40,33},{24,29},{36,29}} do c:px(p[1],p[2],cloth[2]) end
c:fillMask(c:line({{28,30},{26,34}},1),cloth[5])
-- folds
c:fillMask(c:line({{27,50},{22,62},{21,70}},1):clip(body),cloth[2])
c:fillMask(c:line({{35,50},{40,60},{42,72}},1):clip(body),cloth[2])
c:fillMask(c:line({{23,52},{17,62}},1):clip(body),cloth[4])
-- rope tie
local tie=c:rect(21,44,38,47)
tie:each(function(x,y) c:px(x,y,rope[((x+y)%3)+1]) end)
for x=22,37 do c:px(x,44,rope[3]) end
c:fillMask(c:line({{37,47},{41,52},{39,56}},1),rope[2])
-- patch with stitches
local pt=c:rect(32,66,44,77); c:fillMask(pt,"#6f8a58")
c:fillMask(c:rect(32,66,44,67),"#8caa6c"); c:fillMask(c:rect(32,76,44,77),"#4a6240")
for x=32,44,3 do c:px(x,66,"#e8c860"); c:px(x,77,"#e8c860") end
for y=67,77,3 do c:px(32,y,"#e8c860"); c:px(44,y,"#e8c860") end
-- logs
local function logEnd(cx,cy,r,crack)
  local b=c:ellipse(cx,cy,r,r); shade(c,b,cx-2,cy-2,r+2,r+2,bark)
  local w=c:ellipse(cx,cy,r-2,r-2)
  w:each(function(x,y)
    local d=sqrt((x-cx)^2+(y-cy)^2)
    local lit=(x+y<cx+cy)
    local k=floor(d/2.3)%2
    local col
    if k==0 then col=lit and "#f0cf8c" or "#d6a864" else col=lit and "#d6a864" or "#b4824a" end
    c:px(x,y,col)
  end)
  c:px(cx,cy,"#8a5a30")
  if crack then c:fillMask(c:line({{cx+1,cy+1},{cx+r-3,cy+3}},1),"#8a5a30") end
end
logEnd(62,78,10,false); logEnd(82,78,10,true); logEnd(72,60,10,false)
-- quirk: a sprig of leaf poking from top log's bark
c:fillMask(c:poly{{76,49},{80,44},{84,46},{80,51}},"#4aa044"); c:px(79,47,"#7cc85a"); c:px(81,47,"#2f7a34")
c:sparkle(10,56)
c:finish{outline=true}
HP.assertClean(c)
c:save{aseprite=OUT.."stage-haul.aseprite", png=OUT.."stage-haul.png", scale=1}
