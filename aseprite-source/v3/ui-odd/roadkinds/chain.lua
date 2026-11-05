-- chain (ui P3_U5)
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
local c = HP.canvas{ w=96, h=96, scale=1, name="chain" }
local nut={"#4a2812","#6e4020","#9a5e2c","#c4833c","#e6aa5c"}
local cap={"#3a2214","#5a3820","#7c502c","#a06c3c","#c48c52"}
local gold={"#6a3c14","#a8661e","#d8962c","#f2c84a","#fde58c"}
local lf={"#1f4a24","#2f7a34","#4aa044","#7cc85a"}
local TH=math.rad(45); local ct,st=cos(TH),sin(TH)
local function loc(cx,cy,x,y) local dx,dy=x-cx,y-cy return dx*ct+dy*st, -dx*st+dy*ct end
c:groundShadow(40,90,26,3)
local function acorn(cx,cy,sprout)
  local nm=fn(cx-20,cy-20,cx+20,cy+20,function(x,y)
    local lx,ly=loc(cx,cy,x,y)
    local e=(lx/8.5)^2+((ly-5)/10.5)^2<=1
    local tip=ly>=8 and ly<=17 and math.abs(lx)<=(17-ly)*0.7
    return e or tip end)
  shade(c,nm,cx-3,cy-1,12,14,nut)
  local cm=fn(cx-20,cy-20,cx+20,cy+20,function(x,y)
    local lx,ly=loc(cx,cy,x,y)
    return (lx/10)^2+((ly+4)/7)^2<=1 and ly<=1.5 end)
  shade(c,cm,cx-3,cy-6,12,9,cap,0.05)
  cm:each(function(x,y)
    local lx,ly=loc(cx,cy,x,y)
    if (floor((lx+20)/3)+floor((ly+20)/3))%2==0 then c:px(x,y,cap[2]) end
  end)
  -- cap rim highlight
  nm:each(function(x,y) end)
  local stem=fn(cx-20,cy-20,cx+20,cy+20,function(x,y)
    local lx,ly=loc(cx,cy,x,y) return math.abs(lx)<=1.2 and ly>=-14 and ly<=-9 end)
  lin(c,stem,cx-2,cy,cx+2,cy,cap)
  -- spec on nut
  local sx,sy=cx-3-0,cy+3
  c:px(floor(cx-3),floor(cy+4),nut[5]); c:px(floor(cx-3),floor(cy+5),nut[5])
  if sprout then
    local tx,ty=cx+floor(14*st),cy-floor(14*ct)
    c:fillMask(c:line({{tx,ty},{tx+1,ty-4}},1),lf[2])
    c:fillMask(c:poly{{tx+1,ty-4},{tx-4,ty-8},{tx-5,ty-4}},lf[3]); c:px(tx-3,ty-6,lf[4])
    c:fillMask(c:poly{{tx+1,ty-4},{tx+6,ty-9},{tx+7,ty-4}},lf[3]); c:px(tx+4,ty-7,lf[4])
  end
end
local function lring(cx,cy)
  local m=fn(cx-14,cy-14,cx+14,cy+14,function(x,y)
    local dx,dy=x-cx,y-cy
    local u=(dx*ct-dy*st)  -- along (cos,-sin)? rotate to long axis
    local a= dx*st*(-1)+dy*ct*(-1)
    local p=( dx*0.7071-dy*0.7071)
    local q=( dx*0.7071+dy*0.7071)
    local e=(p/8.5)^2+(q/5.2)^2
    return e<=1 and e>=0.26 end)
  lin(c,m,cx-6,cy-6,cx+6,cy+6,gold)
  c:px(cx-5,cy+4,gold[5])
end
acorn(16,78,false); acorn(44,50,false); acorn(72,22,true)
lring(30,64); lring(58,36)
c:sparkle(80,60)
c:finish{outline=true}
HP.assertClean(c)
c:save{aseprite=OUT.."chain.aseprite", png=OUT.."chain.png", scale=1}
