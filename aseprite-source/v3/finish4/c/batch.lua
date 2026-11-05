local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local H = X.hash
local INK = GX.INK
local c
local function mk() return HP.mask() end
local function E(m,cx,cy,rx,ry) return GX.disc(m,floor(cx),floor(cy),floor(rx),floor(ry or rx)) end
local function R6(R) return GX.ramp6(R) end
local function rc(x0,y0,x1,y1) return c:rect(floor(x0),floor(y0),floor(x1),floor(y1)) end
local function fill(x0,y0,x1,y1,col) c:fillMask(rc(x0,y0,x1,y1),col) end
local function px(x,y,col) c:px(floor(x),floor(y),col) end
local function L(m,R,o) o=o or {}; if o.rimlight==nil then o.rimlight=true end; return GX.lit(c,m,type(R)=="function" and R or R6(R),o) end
local function blob(cx,cy,rx,ry,R,seed,o) local m=mk(); E(m,cx,cy,rx,ry); m=GX.rough(m,seed,1); o=o or {}; o.seed=seed; o.R=o.R or max(2,min(rx,ry)); L(m,R,o); return m end
local function box(x0,y0,x1,y1,R,o) o=o or {}; o.R=o.R or 14; local m=rc(x0,y0,x1,y1); L(m,R,o); return m end
local function poly(t,R,o) o=o or {}; o.R=o.R or 16; local pp={} for i,p in ipairs(t) do pp[i]={floor(p[1]+.5),floor(p[2]+.5)} end local m=c:poly(pp); L(m,R,o); return m end
local function shadow(cx,cy,rx,ry,col) local m=mk(); E(m,cx,cy,rx,ry); m=GX.rough(m,cx,1); c:fillMask(m,col) end
local function sky(cols,y1,seed) GX.bands(c,0,y1,cols,seed or 3,.16) end
local function stars(n,ymax,seed,col)
  for i=0,n do local x,y=floor(H(i,1,seed)*478),floor(H(i,2,seed)*ymax); px(x,y,col or "#fff0d0"); if i%6==0 then px(x+1,y,"#d8c8f0"); px(x,y+1,"#d8c8f0"); px(x-1,y,"#d8c8f0"); px(x,y-1,"#d8c8f0") end end
end
local CL={hi="#ffffff",base="#fff2e0",shade="#e8c8c0",deep="#c0a0b0"}
local function cloud(cx,cy,w,R,seed) local m=mk(); for i=0,4 do E(m,cx-w+i*floor(w/2.2),cy+(i%2)*-2,floor(w/2.4),4) end m=GX.rough(m,seed,1); L(m,R or CL,{R=4,tex=.3,sc=3,seed=seed,ink=false,amb=.3}) end
local function hills(f,R,seed,ybot) local m=c:terrain(f,nil,ybot or 269); local r6=R6(R); m:each(function(x,y) local t=(y-f(x))/40; local v=.8-t*.4+(GX.vn(x,y,9,seed)-.5)*.3; px(x,y,r6[GX.idx(v)]) end); for x=0,479 do px(x,floor(f(x)+.5),r6[6]) end end
local function glow(cx,cy,rx,ry,col,t)
  for y=cy-ry,cy+ry do for x=cx-rx,cx+rx do local dd=((x-cx)/rx)^2+((y-cy)/ry)^2; local cur=c:get(x,y)
    if cur and dd<=1 then px(x,y,GX.mix(cur,col,dd<.4 and t*1.5 or (dd<.75 and t or t*.55))) end end end
end
local function lantern(x,y,r,gl,warm)
  warm=warm or "#ffa040"; if gl and gl>0 then glow(x,y,gl,gl,warm,.2) end
  local m=mk(); E(m,x,y,r,r+1); c:rim(m,INK)
  m:each(function(xx,yy) local dd=sqrt((xx-x)^2+((yy-y)*r/(r+1))^2); px(xx,yy,dd<r*.35 and "#fffbe0" or dd<r*.6 and "#ffe890" or dd<r*.85 and "#ffb848" or "#e87a38") end)
end
local function win(m,y0,y1,fr,o) -- lit window from mask
  o=o or {}; c:rim(m,INK)
  m:each(function(x,y) local t=(y-y0)/max(1,y1-y0); px(x,y,t<.3 and "#fff4b8" or t<.65 and "#ffd870" or "#f5a548") end)
  if o.bars~=false then local x0,_,x1 = m:bbox(); local mx=floor((x0+x1)/2); for y=y0,y1 do if m:has(mx,y) then px(mx,y,fr) end end; local my=floor((y0+y1)/2); for x=x0,x1 do if m:has(x,my) then px(x,my,fr) end end end
end
local function rwin(x0,y0,x1,y1,fr,sill) local m=rc(x0,y0,x1,y1); win(m,y0,y1,fr); fill(x0-2,y1+1,x1+2,y1+2,sill or fr); fill(x0-2,y1+3,x1+2,y1+3,INK) end
local function awin(x0,y0,x1,y1,fr) local m=rc(x0,floor((y0+x1-x0)/2+y0*0)+0,x1,y1); local mid=(x0+x1)/2; local r=(x1-x0)/2; local m2=rc(x0,y0+floor(r),x1,y1); E(m2,mid,y0+floor(r),floor(r),floor(r)); m2:cut(rc(x0-2,y1+1,x1+2,y1+4)); win(m2,y0,y1,fr) end
local function tuft(x,y,R) GX.tuft(c,x,y,R) end
local GRASS={hi="#c4d868",base="#78a848",shade="#3e784a",deep="#245040"}
local function round(m,n) return m end
local function stack(x0,x1,y,R,rows,seed) for r=0,rows-1 do for x=x0+(r%2)*3,x1-3,6 do blob(x+3,y-r*5,3,2,R,seed+x+r,{R=2}) end end end
local function hem() c:hem(2,0,479); c:hem(267,0,479) end

---------------------------------------------------------------- extra helpers
local function RP(hi,base,shade,deep) return {hi=hi,base=base,shade=shade,deep=deep} end
local WOOD=RP("#e8a868","#b86e44","#82444a","#4a2840")
local DWOOD=RP("#c88858","#8a5238","#5a3040","#34202e")
local CREAM=RP("#fffae8","#ffe8c0","#e0b0a0","#a07088")
local THATCH=RP("#ffd878","#e0a050","#a8684a","#603a48")
local RED=RP("#ff9a88","#e8485c","#a02c5c","#601c50")
local GRN=RP("#a8d860","#48a048","#2a6a48","#183a40")
local GRN2=RP("#88c458","#2e8444","#1c5440","#122e3a")
local STONE=RP("#d8d4e8","#a8a4c4","#7a74a0","#4a4470")
local SNOW=RP("#ffffff","#e8f0fc","#a8b8e0","#6070a8")
local GOLD=RP("#fff0a0","#f8d838","#c89828","#785828")
local function darker(R) return RP(R.base,R.shade,R.deep,R.deep) end
local function reflect(x0,x1,ytop,ybot,a)
  ytop=max(ytop,ybot-28)
  for y=ytop,ybot do local ry=ybot+1+(ybot-y)
    if ry%3~=0 and ry<268 then for x=x0,x1 do local sx=x+((ry//2)%2)
      local s,dd=c:get(x,y),c:get(sx,ry); if s and dd then px(sx,ry,GX.mix(dd,s,a or .4)) end end end end
end
local function moon(x,y,r)
  glow(x,y,r*2,r*2,"#fff0c0",.15)
  local m=mk(); E(m,x,y,r); local cut=mk(); E(cut,x+floor(r*.5),y-floor(r*.3),r); m:cut(cut); c:rim(m,INK)
  m:each(function(xx,yy) px(xx,yy,xx<x-r*.4 and "#fffbe0" or "#ffe890") end)
end
local function note(x,y)
  fill(x,y+6,x+3,y+8,INK); fill(x+1,y+6,x+2,y+7,"#fff0c0"); fill(x+3,y,x+3,y+6,INK); fill(x+3,y,x+6,y+1,INK); px(x+4,y+1,"#fff0c0")
end
local function roof(x0,x1,ytop,yb,R,seed,hm)
  local m=mk(); local mid=(x0+x1)/2
  for y=ytop,yb do local t=(y-ytop)/(yb-ytop); local hw=floor((mid-x0)*(.15+.85*t)); for x=floor(mid-hw),floor(mid+hw) do m:set(x,y) end end
  if hm then for x=x0,x1 do for k=0,2 do if H(x//3,k,seed)<.5 then m:set(x,yb+k) end end end end
  m=GX.rough(m,seed,1)
  L(m,R,{R=22,tex=.5,sc=3,seed=seed,wrap=.4,fn=function(x,y) return (H(x//2,y//4,seed)-.5)*.2-((y-ytop)%5==0 and .12 or 0) end})
  return m
end
local function limb(x0,y0,x1,y1,w0,w1,R,seed)
  local m=c:poly({{floor(x0-w0),floor(y0)},{floor(x0+w0),floor(y0)},{floor(x1+w1),floor(y1)},{floor(x1-w1),floor(y1)}})
  L(m,R,{R=max(3,floor(w0)),seed=seed or 1}); return m
end
-- flame tongue mask
local function tongue(cx,by,h,w,lean)
  local m=mk(); h=max(2,floor(h))
  for yy=0,h do local t=yy/h; local hw=floor(w*(1-t)^.8*(1+.15*sin(yy*.8))+.5); local ox=floor(lean*sin(t*2.2)*h*.28)
    for xx=-hw,hw do m:set(floor(cx)+ox+xx,floor(by)-yy) end end
  return m
end
local function fire(x,y,s,gl)
  glow(x,y-10*s,floor(26*s),floor(16*s),"#ff9030",gl or .3)
  local T={{-6,15,5,-.5},{5,18,6,.5},{0,26,7,0},{-11,9,4,-.7},{11,10,4,.7},{-3,20,4,-.2},{8,13,3,.3}}
  local lay={{1,"#d8383c"},{.8,"#ff7a30"},{.56,"#ffb83c"},{.3,"#fff0a0"}}
  for li,ly in ipairs(lay) do for _,t in ipairs(T) do
    local m=tongue(x+t[1]*s,y-2*s-(li-1)*s,t[2]*s*ly[1],t[3]*s*ly[1]+.5,t[4])
    if li==1 then c:rim(m,"#7a2438") end
    c:fillMask(m,ly[2]) end end
  for i=0,6 do px(x+floor((H(i,1,4)-.5)*30*s),y-floor((14+H(i,2,4)*30)*s),i%2==0 and "#ffd860" or "#ff9a38") end
  blob(x-8*s,y,10*s,3*s,DWOOD,50,{R=3,tex=.2}); blob(x+8*s,y,10*s,3*s,DWOOD,51,{R=3,tex=.2})
  fill(x-14*s,y-1,x-11*s,y+1,"#ffb040"); fill(x+11*s,y-1,x+14*s,y+1,"#ffb040")
end
local function ripple(x,y,w,col) fill(x-w,y,x+w,y,col); fill(x-w+3,y+2,x+w-3,y+2,col) end

-- animals ---------------------------------------------------------
local function frog(x,y,s,fh)
  local F=RP("#c8f080","#68c050","#3a8a54","#1e4c48"); local B=RP("#fffbc0","#f0e890","#c8b870","#887858")
  for _,k in ipairs{-1,1} do blob(x+k*13*s,y-6*s,8*s,6*s,F,x+k,{R=5}); blob(x+k*16*s,y-1*s,7*s,2*s,F,x+k+3,{R=2}) end
  blob(x,y-12*s,13*s,11*s,F,x,{R=9}); blob(x,y-9*s,8*s,7*s,B,x+1,{R=5,ink=false,rimlight=false})
  blob(x,y-22*s,12*s,8*s,F,x+2,{R=7})
  for _,k in ipairs{-1,1} do blob(x+k*7*s,y-29*s,4*s,4*s,F,x+k+5,{R=3}); blob(x+k*7*s,y-29*s,3*s,3*s,CREAM,x+k+6,{R=2,ink=false}); fill(x+k*7*s-1,y-30*s,x+k*7*s,y-28*s,INK); px(x+k*7*s-1,y-30*s,"#fffae8") end
  fill(x-9*s,y-19*s,x+9*s,y-19*s,INK); px(x-9*s,y-20*s,INK); px(x+9*s,y-20*s,INK); px(x-2,y-24*s,F.deep); px(x+2,y-24*s,F.deep)
  blob(x-6*s,y-14*s,6*s,2*s,{hi="#ff9aa0",base="#f06880",shade="#b04068",deep="#702848"},3,{R=2,ink=false,rimlight=false})
  for _,k in ipairs{-1,1} do blob(x+k*8*s,y-3*s,3*s,5*s,F,x+k+9,{R=2}) ; for j=-1,1 do px(x+k*8*s+j*2,y+2*s,F.hi) end end
  fill(x+fh*10*s,y-36*s,x+fh*11*s,y-31*s,"#ff6a58"); fill(x+fh*10*s,y-36*s,x+fh*12*s,y-33*s,"#ffd860")
end
local function duck(x,y,s,f)
  local D=RP("#fffbe0","#ffe890","#e0a860","#9a6a50"); local W=RP("#ffffff","#fff0b8","#d8a870","#8a6050")
  ripple(x,y+5*s,floor(13*s),"#d8f4f4")
  poly({{x-f*9*s,y-2*s},{x-f*17*s,y-9*s},{x-f*11*s,y+2*s}},D,{R=3})
  blob(x,y,12*s,7*s,D,x,{R=7}); blob(x-f*2*s,y,7*s,4*s,W,x+1,{R=3,ink=false}); fill(x-f*9*s,y,x+f*3*s,y,D.shade)
  blob(x+f*9*s,y-9*s,6*s,7*s,D,x+2,{R=4}); poly({{x+f*13*s,y-11*s},{x+f*20*s,y-8*s},{x+f*13*s,y-6*s}},RP("#ffc060","#f08a38","#b8582c","#703038"),{R=3})
  fill(x+f*10*s,y-11*s,x+f*10*s+1,y-10*s,INK); px(x+f*10*s,y-11*s,"#fffae8")
end
local function meerkat(x,y,s)
  local M=RP("#f8d8a0","#d8a470","#9a6858","#523c48"); local B=RP("#fff4d8","#f0d0a0","#c09878","#7a5a5c"); local DK=RP("#6a5060","#4a3444","#34243a","#22182a")
  limb(x+10*s,y-2*s,x+18*s,y-26*s,2,1,M,3); blob(x+19*s,y-27*s,2*s,2*s,DK,4,{R=2})   -- tail
  for _,k in ipairs{-1,1} do blob(x+k*5*s,y-1*s,5*s,2*s,DK,x+k,{R=2}); limb(x+k*4*s,y-12*s,x+k*4*s,y-3*s,3*s,2*s,M,k+5) end
  blob(x,y-20*s,9*s,14*s,M,x,{R=8})
  blob(x,y-18*s,6*s,10*s,B,x+1,{R=5,ink=false,rimlight=false})
  for k=-1,1 do fill(x+k*5*s+0,y-30*s,x+k*5*s,y-22*s,M.shade) end
  for _,k in ipairs{-1,1} do blob(x+k*7*s,y-20*s,3*s,6*s,M,x+k+9,{R=3}); blob(x+k*5*s,y-17*s,2*s,3*s,DK,x+k+4,{R=2,ink=false}) end
  blob(x,y-38*s,8*s,8*s,M,x+2,{R=6}); blob(x,y-33*s,4*s,4*s,B,x+3,{R=3,ink=false,rimlight=false})
  for _,k in ipairs{-1,1} do blob(x+k*8*s,y-41*s,2*s,3*s,DK,x+k+7,{R=2}); blob(x+k*4*s,y-39*s,3*s,3*s,DK,x+k+8,{R=2,ink=false,rimlight=false}); fill(x+k*4*s-(k<0 and 1 or 0),y-40*s,x+k*4*s-(k<0 and 1 or 0)+1,y-38*s,INK); px(x+k*4*s-(k<0 and 1 or 0),y-40*s,"#fffae8") end
  blob(x,y-34*s,2*s,2*s,DK,3,{R=2,ink=false,rimlight=false}); px(x,y-31*s,INK)
end
local function horse(x,y,s,f,R,MR)
  local function X(dx) return x+f*dx*s end
  local function Y(dy) return y+dy*s end
  local Rf=darker(R); local HV=RP("#6a5060","#44323e","#2c2030","#1c1424")
  local function leg(ax,ay,kx,ky,fx,fy,w,Rr,sd)
    limb(X(ax),Y(ay),X(kx),Y(ky),w*s,w*.62*s,Rr,sd); limb(X(kx),Y(ky),X(fx),Y(fy-3),w*.6*s,w*.5*s,Rr,sd+1)
    blob(X(fx),Y(fy-1),3.5*s,2.5*s,HV,sd+2,{R=2}) end
  leg(11,-30,12,-16,13,0,3.6,Rf,3); leg(-14,-30,-18,-17,-17,0,3.8,Rf,6)
  -- tail
  poly({{X(-21),Y(-42)},{X(-26),Y(-38)},{X(-33),Y(-12)},{X(-28),Y(-10)},{X(-24),Y(-30)}},MR,{R=6})
  blob(X(0),Y(-35),25*s,11*s,R,5,{R=10,tex=.3}); blob(X(15),Y(-36),11*s,11*s,R,6,{R=8}); blob(X(-17),Y(-34),11*s,11*s,R,7,{R=8})
  blob(X(-1),Y(-27),18*s,5*s,RP(R.base,R.shade,R.deep,R.deep),9,{R=4,ink=false,rimlight=false})
  leg(8,-28,10,-15,10,0,4,R,8); leg(-17,-26,-12,-14,-13,0,4.4,R,11)
  poly({{X(14),Y(-42)},{X(22),Y(-70)},{X(31),Y(-66)},{X(27),Y(-38)}},R,{R=8})
  blob(X(30),Y(-67),7*s,5.5*s,R,12,{R=5}); poly({{X(33),Y(-69)},{X(45),Y(-60)},{X(45),Y(-54)},{X(36),Y(-56)}},R,{R=5})
  blob(X(44),Y(-56),4*s,3.5*s,RP("#f0b898","#c88868","#8a5a58","#523444"),13,{R=3})
  px(X(33),Y(-69),INK); px(X(33)+f,Y(-69),INK); px(X(45),Y(-56),INK)
  poly({{X(25),Y(-70)},{X(26),Y(-79)},{X(29),Y(-70)}},R,{R=3})
  poly({{X(14),Y(-43)},{X(21),Y(-73)},{X(25),Y(-72)},{X(18),Y(-43)}},MR,{R=5})
  poly({{X(27),Y(-71)},{X(32),Y(-66)},{X(31),Y(-62)},{X(27),Y(-68)}},MR,{R=3})
  blob(X(-6),Y(-45),3*s,2*s,R,3,{R=2,ink=false})
end
local function cow(x,y,s,f,SP)
  local function X(dx) return x+f*dx*s end
  local function Y(dy) return y+dy*s end
  local C=RP("#ffffff","#f4eef0","#c0b0c4","#7c6c90"); local Cf=darker(C); local PK=RP("#ffc8c8","#f0a0a8","#b86c80","#704060")
  local DK=RP("#8a6a68","#5a4048","#3a2838","#221a2a")
  local function leg(lx,w,Rr) limb(X(lx),Y(-20),X(lx),Y(-4),w*s,w*.8*s,Rr,lx+3); blob(X(lx),Y(-2),w*s,2.2*s,DK,lx,{R=2}) end
  leg(14,3.6,Cf); leg(-15,3.8,Cf)
  poly({{X(-26),Y(-38)},{X(-29),Y(-34)},{X(-30),Y(-12)},{X(-28),Y(-12)},{X(-26),Y(-30)}},C,{R=3}); blob(X(-29),Y(-10),3*s,4*s,DK,5,{R=2})
  local body=blob(X(0),Y(-30),29*s,14*s,C,5,{R=12,tex=.25})
  blob(X(-13),Y(-17),5*s,4*s,PK,6,{R=3})
  leg(9,4,C); leg(-20,4.2,C)
  blob(X(21),Y(-34),11*s,11*s,C,7,{R=8}); blob(X(-20),Y(-34),9*s,11*s,C,8,{R=8})
  for i,p in ipairs(SP) do local m=mk(); E(m,X(p[1]),Y(p[2]),p[3]*s,p[4]*s); m=GX.rough(m,i+3,1)
    m:each(function(xx,yy) if body:has(xx,yy) then px(xx,yy,(xx+yy)%7==0 and DK.base or ((xx<X(p[1])-p[3]*s*.3*f and f>0 or xx>X(p[1])+p[3]*s*.3*(-f) and f<0) and "#7a5a5c" or DK.base)) end end) end
  blob(X(32),Y(-26),9*s,10*s,C,9,{R=7}); blob(X(36),Y(-18),7*s,5*s,PK,10,{R=4})
  px(X(34),Y(-17),INK); px(X(38),Y(-17),INK); fill(X(30),Y(-30),X(30)+1,Y(-29),INK); px(X(30),Y(-30),"#fffae8")
  blob(X(26),Y(-35),5*s,2.5*s,C,11,{R=2}); blob(X(41),Y(-35),4*s,2*s,C,12,{R=2})
  poly({{X(30),Y(-36)},{X(29),Y(-42)},{X(32),Y(-38)}},RP("#fff4d0","#e8d4a0","#b09870","#6a5a5c"),{R=3}); poly({{X(36),Y(-36)},{X(38),Y(-42)},{X(38),Y(-37)}},RP("#fff4d0","#e8d4a0","#b09870","#6a5a5c"),{R=3})
  blob(X(22),Y(-22),6*s,5*s,C,13,{R=4,ink=false,rimlight=false})
end
local function turtle(x,y,s,f,Rs,Rk,sd)
  local function X(dx) return x+f*dx*s end
  local function Y(dy) return y+dy*s end
  blob(X(-15),Y(-4),7*s,4*s,Rk,sd+1,{R=3}); blob(X(-26),Y(-6),4*s,2*s,Rk,sd+2,{R=2})
  blob(X(14),Y(-3),7*s,3.5*s,darker(Rk),sd+3,{R=3})
  blob(X(25),Y(-14),6*s,5*s,Rk,sd+4,{R=4}); blob(X(32),Y(-17),8*s,6*s,Rk,sd+5,{R=5}); blob(X(38),Y(-15),4*s,3*s,RP("#f8f0b0","#e8d078","#b8a068","#786858"),sd+6,{R=2})
  fill(X(33),Y(-19),X(33)+1,Y(-18),INK); px(X(33),Y(-19),"#fffae8"); fill(X(36),Y(-14),X(40),Y(-14),INK)
  local sh=mk(); E(sh,X(0),Y(-13),22*s,16*s); sh:cut(rc(x-30*s,Y(-6),x+30*s,Y(6))); sh=GX.rough(sh,sd,1)
  L(sh,Rs,{R=max(6,floor(22*s)),tex=.3,sc=3,seed=sd})
  -- domed carapace: 5 big central scutes (Voronoi on the dome surface) + 8 marginals round the rim
  local scx,scy,srx,sry=X(0),Y(-13),22*s,16*s
  local seeds={{0,-.36},{-.6,-.5},{.6,-.5},{-.42,.02},{.42,.02}}
  local function lift(u,v) return u,v,sqrt(max(0,1-u*u-v*v*.7)) end
  local S3={} for i,p in ipairs(seeds) do local a,b,cc=lift(p[1],p[2]); S3[i]={a,b,cc} end
  local id,ring,tt={}, {}, {}
  local function K(a,b) return a*4096+b end
  sh:each(function(xx,yy)
    local u,v=(xx-scx)/srx,(yy-scy)/sry; local r=sqrt(u*u+(v*sry/srx>0 and v*1.6 or v)^2)
    local e=sqrt(u*u+v*v)
    if (e>.8 and v>-.42) or v>.16 then
      local ang=math.atan(u,v+.1); local seg=floor((ang+1.85)/3.7*8); id[K(xx,yy)]=10+max(0,min(7,seg)); tt[K(xx,yy)]=(v>.16) and (v-.16)/.22 or (e-.8)/.2; ring[K(xx,yy)]=0
    else
      local a,b,cc=lift(u,v); local d1,d2,best=9,9,1
      for i,q in ipairs(S3) do local dd=sqrt((a-q[1])^2+(b-q[2])^2+(cc-q[3])^2); if dd<d1 then d2=d1; d1=dd; best=i elseif dd<d2 then d2=dd end end
      id[K(xx,yy)]=best; local t=d1/(d1+d2); tt[K(xx,yy)]=t; ring[K(xx,yy)]=floor(t*7)
    end
  end)
  local big=s>=1; local wd=s>=2 and 2 or 1
  local lf,up=nil,nil
  sh:each(function(xx,yy)
    local k=K(xx,yy); local me=id[k]; local cur=c:get(xx,yy)
    local function df(dx,dy) local o=id[K(xx+dx,yy+dy)]; return o and o~=me end
    lf,up=id[K(xx-1,yy)],id[K(xx,yy-1)]
    if df(1,0) or df(0,1) or (wd==2 and (df(2,0) or df(0,2))) then px(xx,yy,Rs.deep)       -- dark seam
    elseif df(-1,0) or df(0,-1) or (wd==2 and me<10 and (df(-2,0) or df(0,-2))) then px(xx,yy,Rs.hi) -- lit upper-left edge of each scute
    elseif me>=10 and wd==2 and (xx+yy)%5~=0 then px(xx,yy,GX.mix(cur,Rs.shade,.35))
    elseif big and (df(wd+1,0) or df(0,wd+1)) then px(xx,yy,GX.mix(cur,Rs.shade,.6)) -- shaded lower-right lip
    elseif big and me<10 and ((lf and ring[K(xx-1,yy)]~=ring[k]) or (up and ring[K(xx,yy-1)]~=ring[k])) and ring[k]>=1 and ring[k]<=2 then
      px(xx,yy,GX.mix(cur,Rs.deep,.45))                                                  -- concentric growth rings
    elseif me<10 and tt[k]<.12 then px(xx,yy,GX.mix(cur,Rs.hi,.35))                      -- scute boss catches light
    elseif me>=10 and big and (xx+yy)%5==0 and tt[k]>.5 then px(xx,yy,GX.mix(cur,Rs.shade,.5)) end
  end)
  if big then for i,p in ipairs(seeds) do local sx,sy=floor(scx+p[1]*srx*.97),floor(scy+p[2]*sry*.97); if sh:has(sx,sy) and sh:has(sx-1,sy-1) then px(sx-1,sy-1,Rs.hi); px(sx,sy-1,GX.mix(Rs.hi,Rs.base,.5)) end end end
  fill(X(-21),Y(-7),X(21),Y(-6),"#f0d890"); fill(X(-21),Y(-5),X(21),Y(-5),"#a88860")
  blob(X(18),Y(-4),7*s,4*s,Rk,sd+8,{R=3}); for j=0,2 do px(X(22)+j*f,Y(-1),Rk.hi) end
end
local function bear(x,y,s)
  local Br=RP("#e8d0b0","#b88a64","#7a5454","#443040"); local Mz=RP("#fff0d8","#e8c8a0","#b08a74","#704a58")
  blob(x,y+22*s,28*s,14*s,Br,x,{R=12});
  for _,k in ipairs{-1,1} do blob(x+k*15*s,y-12*s,6*s,6*s,Br,x+k,{R=4}); blob(x+k*15*s,y-11*s,3*s,3*s,RP("#f8c8b0","#d89488","#985c68","#582c50"),x+k+3,{R=2,ink=false,rimlight=false}) end
  blob(x,y,19*s,15*s,Br,x+4,{R=12,tex=.3}); blob(x,y+6*s,10*s,8*s,Mz,x+5,{R=6,ink=false,rimlight=false})
  blob(x,y+3*s,4*s,3*s,RP("#5a4650","#3a2a38","#2a1c2c","#1c1220"),x+6,{R=2,ink=false,rimlight=false})
  for _,k in ipairs{-1,1} do fill(x+k*8*s-2,y-3*s,x+k*8*s+2,y-3*s,INK); px(x+k*8*s-2,y-2*s,INK); px(x+k*8*s+2,y-2*s,INK) end
  fill(x-3*s,y+9*s,x+3*s,y+9*s,INK); px(x-3*s,y+8*s,INK); px(x+3*s,y+8*s,INK)
  for _,k in ipairs{-1,1} do px(x+k*13*s,y+4*s,"#ff9aa0"); px(x+k*13*s+k,y+4*s,"#ff9aa0") end
end
local function squirrel(x,y,s)
  local Sq=RP("#f0b078","#c87848","#8a4a4a","#4c2c3c"); local B=RP("#fff0d0","#f0d0a0","#c09070","#7a5058")
  for i=0,6 do local a=i/6; blob(x+14*s+sin(a*3.2)*10*s,y-8*s-a*34*s,(7-a*2)*s,6*s,Sq,i+9,{R=5,tex=.3}) end
  blob(x+17*s,y-48*s,6*s,6*s,B,4,{R=4,ink=false,rimlight=false})
  blob(x+5*s,y-2*s,9*s,3*s,Sq,5,{R=3}); blob(x,y-14*s,10*s,14*s,Sq,6,{R=9}); blob(x-2*s,y-12*s,6*s,9*s,B,7,{R=5,ink=false,rimlight=false})
  blob(x-5*s,y-31*s,8*s,7*s,Sq,8,{R=6}); blob(x-11*s,y-29*s,4*s,3*s,B,9,{R=2})
  poly({{x-9*s,y-36*s},{x-8*s,y-45*s},{x-4*s,y-37*s}},Sq,{R=3}); poly({{x-3*s,y-37*s},{x,y-45*s},{x+1*s,y-35*s}},Sq,{R=3}); px(x-8*s,y-45*s,INK); px(x,y-45*s,INK)
  fill(x-8*s,y-33*s,x-8*s+1,y-32*s,INK); px(x-8*s,y-33*s,"#fffae8"); px(x-13*s,y-29*s,INK)
  blob(x-8*s,y-20*s,3*s,2*s,Sq,3,{R=2}); blob(x-6*s,y-18*s,3*s,3*s,RP("#c89860","#8a5a38","#5a3a38","#33222e"),4,{R=2})
end
local function gecko(x,y,s)
  local G=RP("#c0e878","#78b850","#3e8050","#1e4a48"); local Bl=RP("#f8f8c0","#e8e090","#b8a870","#786858")
  blob(x,y+8*s,18*s,22*s,G,x,{R=12,tex=.3}); blob(x,y+10*s,10*s,16*s,Bl,x+1,{R=7,ink=false,rimlight=false})
  for i=0,4 do px(x-10*s+i*5*s,y-8*s+(i%2)*3,G.hi); px(x-12*s+i*6*s,y+4*s,G.deep) end
  blob(x,y-10*s,14*s,10*s,G,x+2,{R=8});
  for _,k in ipairs{-1,1} do blob(x+k*8*s,y-19*s,5*s,5*s,G,x+k,{R=3}); blob(x+k*8*s,y-19*s,4*s,4*s,RP("#fff0a0","#ffd038","#c88a20","#784a28"),x+k+2,{R=3,ink=false}); fill(x+k*8*s,y-21*s,x+k*8*s,y-17*s,INK) end
  fill(x-10*s,y-6*s,x+10*s,y-6*s,INK); px(x-11*s,y-7*s,INK); px(x+11*s,y-7*s,INK); px(x-3,y-11*s,G.deep); px(x+3,y-11*s,G.deep)
  for _,k in ipairs{-1,1} do blob(x+k*17*s,y+22*s,5*s,4*s,G,x+k+8,{R=3}); for j=-1,1 do blob(x+k*17*s+j*4,y+26*s,2,2,Bl,j+x,{R=1,ink=false}) end end
end
local CHI={hi="#ff9068",base="#e83828",shade="#a02040",deep="#5c1838"}
local CHIS={CHI,{hi="#ffc878",base="#f08428",shade="#b05030",deep="#602c40"},{hi="#c8f088",base="#58a848",shade="#2e7048",deep="#1a4638"},{hi="#fff088",base="#f0c030",shade="#b88028",deep="#6a4430"}}
local function chili(x,y,R,tilt)
  local m=c:poly({{x-2,y},{x+2,y},{x+1+tilt,y+7},{x+tilt,y+9},{x-1+tilt,y+7}}); L(m,R,{R=3,tex=0})
  px(x,y-1,"#4a9a48"); px(x+1,y-1,"#2e7048"); px(x-1,y+1,R.hi)
end
local function chiliStr(x,y,n,seed)
  fill(x,y-2,x,y+n*7+2,INK); px(x+1,y-2,"#c8946c")
  for i=0,n-1 do local R=CHIS[(floor(H(i,seed,1)*10)%4)+1]; if i<2 then R=CHIS[1] end
    chili(x-3,y+i*7,R,-1); chili(x+3,y+i*7+3,R,1) end
  fill(x-1,y+n*7+3,x+1,y+n*7+5,"#c8946c")
end
local function basket(x,y,w,h,heap,seed)
  local wv=function(xx,yy) return (((xx+yy)//3)%2)*.1-.05 end
  for i=0,floor(w*1.6) do local px0=x-w+floor(H(i,seed,5)*w*2); local py0=y-h-floor(H(i,seed,6)*7)+floor((1-abs(px0-x)/w)*3)
    local R=heap[(i%#heap)+1]; local m=c:poly({{px0-3,py0},{px0+3,py0-1},{px0+4,py0+1},{px0-2,py0+2}}); L(m,R,{R=2,tex=0}); px(px0+4,py0,"#3e8a48") end
  box(x-w,y-h,x+w,y,RP("#e8b868","#b88040","#845030","#4a2c34"),{R=8,tex=.5,fn=wv})
  fill(x-w,y-h,x+w,y-h,"#f4d088"); fill(x-w,y-floor(h/2),x+w,y-floor(h/2),"#845030")
end
local function bucket(x,y,seed)
  local B=RP("#e0e0f0","#a8aac0","#6a6e90","#40445c")
  fill(x-4,y-8,x-4,y-2,INK); fill(x+4,y-8,x+4,y-2,INK); fill(x-4,y-9,x+4,y-9,INK)
  local m=c:poly({{x-5,y},{x+5,y},{x+6,y+12},{x-6,y+12}}); L(m,B,{R=6,tex=.1,seed=seed})
  fill(x-6,y+4,x+6,y+4,B.deep); fill(x-5,y-1,x+5,y-1,"#fff0c0"); fill(x-5,y,x+5,y,"#e8b868")
  fill(x-1,y-6,x+1,y-2,INK)
end

local SC={}
---------------------------------------------------------------- drum circle market
SC["haven-drum-circle-market"]=function()
  sky({"#140c30","#201448","#301e5c","#46286c","#6a3a7c","#964c80"},185,5)
  stars(80,100,6); moon(80,50,16)
  hills(function(x) return 150+floor(9*sin(x/40+1)+4*sin(x/13)) end,{hi="#7a4a8c",base="#52307a",shade="#38245c",deep="#241848"},3,190)
  for i=0,14 do px(floor(H(i,1,3)*470),158+floor(H(i,2,3)*12),"#ffc868") end
  local yfn=function(x) return 178+floor(1.5*sin(x/37)) end
  GX.ground(c,yfn,RP("#c88858","#8a5238","#5a3040","#34202e"),6,{top=.8,fall=.55,tex=.3,sc=8})
  local COB=RP("#d8a878","#a87050","#704448","#44283a")
  for i=0,300 do local y=184+floor(H(i,1,9)*84); local x=floor(H(i,2,9)*480); local sc=(y-178)/90; local rx=3+floor(sc*4+H(i,3,9)*2)
    blob(x,y,rx,max(2,rx//2+1),COB,i,{R=2,tex=.2,ink=false}) end
  -- hut
  local function hut(x,y,w,h)
    shadow(x,y+h,w,4,"#2c1a2c")
    box(x-w+6,y,x+w-6,y+h,DWOOD,{R=10,tex=.5,fn=function(xx,yy) return ((xx-x)//6%2)*.08-.04 end})
    for k=x-w+12,x+w-8,12 do fill(k,y,k,y+h,"#34202e") end
    rwin(x-18,y+10,x-4,y+h-8,"#5a3040","#e8a868"); rwin(x+4,y+10,x+18,y+h-8,"#5a3040","#e8a868")
    roof(x-w,x+w,y-40,y+2,THATCH,x,true); fill(x-w,y+2,x+w,y+3,INK)
    glow(x,y+16,36,20,"#ffa040",.22)
  end
  hut(66,128,48,46); hut(414,128,48,46)
  -- string lights
  local function lights(x0,y0,x1,y1,sag,n) for i=0,60 do local t=i/60; px(x0+(x1-x0)*t,y0+(y1-y0)*t+sag*4*t*(1-t),INK) end
    for i=1,n do local t=i/(n+1); local lx=floor(x0+(x1-x0)*t); local ly=floor(y0+(y1-y0)*t+sag*4*t*(1-t)); lantern(lx,ly+4,2,10,({"#ffa040","#ff6a7a","#ffd860","#78e0c8"})[i%4+1]) end end
  lights(20,90,240,76,16,10); lights(240,76,460,90,16,10)
  -- cobble ring and bonfire
  for i=0,17 do local a=i/18*6.283; blob(240+cos(a)*50,236+sin(a)*13,6,4,STONE,i+70,{R=3}) end
  shadow(240,238,70,12,"#2c1a2c")
  glow(240,230,110,40,"#ff9030",.18)
  fire(240,236,2.6,.28)
  -- rugs
  local function rug(cx,cy,w,h,c1,c2,c3)
    local r1,r2,r3=R6(c1),R6(c2),R6(c3)
    local m=c:poly({{cx-w+10,cy-h},{cx+w+10,cy-h},{cx+w-10,cy+h},{cx-w-10,cy+h}})
    L(m,function(xx,yy) local u=(xx-cx)/w; local v=(yy-cy)/h
      if abs(u)>.86 or abs(v)>.78 then return r3 end
      if abs(u)+abs(v)<.35 then return r3 end
      return (floor((abs(u)+abs(v))*5)%2==0) and r1 or r2 end,{R=2,tex=.1,seed=cx})
    for k=-w,w,4 do px(cx+k-10,cy-h-1,c3.base); px(cx+k+10,cy+h+1,c3.base) end
  end
  rug(86,232,50,12,RP("#ff9a70","#d84a4a","#983a58","#582444"),RP("#ffe8a0","#f0c060","#b88050","#684050"),RP("#78d8c0","#38a898","#2a6a78","#1c3c58"))
  rug(398,236,50,12,RP("#78d8c0","#38a898","#2a6a78","#1c3c58"),RP("#fff0d0","#f0d0a0","#c89c78","#8a5a60"),RP("#e8a0f0","#b870d0","#7a48a0","#442c70"))
  -- drums
  local SK=RP("#fff0d0","#f0d0a0","#c89c78","#8a5a60")
  local function drum(x,y,w,h,R,rope)
    shadow(x+3,y+h,w+6,4,"#2c1a2c")
    local function hwf(t) return floor(w*(.8+.2*sin(pi*(.12+.76*t)))*(1-.14*t)) end
    local b=mk(); for yy=0,h do local hw=hwf(yy/h); for xx=-hw,hw do b:set(x+xx,y+yy) end end
    L(GX.rough(b,x,1),R,{R=w,tex=.4,sc=2,seed=x,fn=function(xx,yy) return (((xx-x)//4)%2)*.06-.03 end})
    for _,t in ipairs{.34,.62,.9} do local yy=y+floor(h*t); local hw=hwf(t); fill(x-hw,yy,x+hw,yy,R.deep); fill(x-hw,yy-1,x-hw+4,yy-1,R.hi); fill(x-hw,yy+1,x+hw,yy+1,R.shade) end
    for k=-w+3,w-3,4 do for dy=0,floor(h*.3) do px(x+k+((dy//2)%2)*2-1,y+5+dy,rope) end end
    local hd=mk(); E(hd,x,y,w,floor(w*.36)); L(hd,SK,{R=5,tex=.2,seed=x})
    for a=pi,2*pi,.12 do px(x+cos(a)*(w-1),y+sin(a)*w*.34,R.hi) end
    for a=0,pi,.2 do px(x+cos(a)*(w-1),y+sin(a)*w*.34,R.deep) end
    px(x-3,y-2,"#ffffff"); px(x-2,y-2,"#ffffff")
  end
  drum(132,208,22,46,RP("#ff9a70","#d84a4a","#983a58","#582444"),"#ffe090")
  drum(348,210,22,46,RP("#78d8c0","#38a898","#2a6a78","#1c3c58"),"#ffe090")
  drum(180,244,17,30,RP("#ffd878","#e8a040","#a8684a","#603a48"),"#fff4d8")
  drum(300,246,17,30,RP("#e8a0f0","#b870d0","#7a48a0","#442c70"),"#fff4d8")
  -- frog drummers with small bongos
  frog(86,262,1.15,1); frog(396,262,1.15,-1)
  drum(86,246,9,12,RP("#ffd878","#e8a040","#a8684a","#603a48"),"#fff4d8"); drum(104,248,8,10,RP("#ffd878","#e8a040","#a8684a","#603a48"),"#fff4d8")
  note(170,170); note(300,160); note(110,176); note(370,172); note(214,120)
end

---------------------------------------------------------------- kava circle
SC["haven-kava-circle"]=function()
  -- interior wall of woven mats
  for y=0,269 do for x=0,479 do px(x,y,"#5a3438") end end
  GX.bands(c,0,172,{"#6a3c3c","#7e4a42","#965a48","#ae6e50","#c4845a"},4,.12)
  for y=40,170,4 do for x=((y//4)%2)*6,479,12 do px(x,y,"#7a4440"); px(x+1,y,"#7a4440"); px(x+3,y+1,"#d8a068") end end
  -- window onto the night sea
  local op=rc(176,72,304,150); E(op,240,72,64,40);
  c:rim(op,INK); op:each(function(x,y) px(x,y,y<100 and "#2a2670" or (y<120 and "#4a3a88" or (y<136 and "#c06888" or "#e88a78"))) end)
  op:each(function(x,y) if y>=126 then px(x,y,(x+y*3)%11==0 and "#ffd8a0" or ((y%4==0) and "#9a5a98" or "#5a4a98")) end end)
  for i=0,20 do px(190+H(i,1,3)*100,78+H(i,2,3)*26,"#fff0d0") end
  moon(264,92,9)
  -- roof underside: rafters
  local rf=mk(); for y=0,64 do for x=0,479 do rf:set(x,y) end end
  L(rf,THATCH,{R=30,tex=.5,sc=3,seed=5,rimlight=false,ink=false,fn=function(x,y) return (H(x//2,y//5,3)-.5)*.2-((y%6==0) and .1 or 0) end})
  for i=-4,4 do local x1=240+i*70; for t=0,64 do px(240+(x1-240)*t/64,t,"#4a2840"); px(241+(x1-240)*t/64,t,"#82444a") end end
  box(0,56,479,70,WOOD,{R=6,tex=.4}); fill(0,70,479,71,INK)
  for x=6,479,22 do fill(x,62,x+8,62,"#82444a"); px(x+1,61,"#ffd878") end
  -- posts with carvings
  for _,x in ipairs{40,156,324,440} do
    box(x-9,60,x+9,206,RP("#ffc88a","#d08a54","#9a5a48","#5a3440"),{R=14,tex=.5,fn=function(xx,yy) return ((xx-x)//4==0 and .08 or 0)-(( (yy//10)%2==0 and (xx-x)%6==0) and .12 or 0) end})
    for yy=84,190,16 do for k=-6,6,2 do px(x+k,yy+abs(k)//2,"#5a3040"); px(x+k,yy+1+abs(k)//2,"#ffd890") end; px(x,yy+6,"#ffe8a0"); px(x-1,yy+6,"#e87a38") end
    fill(x-9,60,x-9,206,"#ffd890")
    blob(x,206,12,4,DWOOD,x,{R=3})
  end
  -- floor mat
  GX.ground(c,function(x) return 172 end,RP("#f0c080","#c08048","#8a5048","#4a3048"),5,{top=.86,fall=.5,tex=.3,sc=8})
  for y=174,268,4 do for x=((y//4)%2)*8,479,16 do fill(x,y,x+7,y,"#a06a4c") end end
  fill(0,170,479,171,"#7a4440"); fill(0,172,479,172,"#ffd890")
  glow(240,214,200,60,"#ffb050",.25)
  for _,x in ipairs{92,388} do glow(x,140,70,70,"#ffb050",.22) end
  for _,lx in ipairs{98,382} do fill(lx,72,lx,88,INK); lantern(lx,94,5,34,"#ffb050") end
  -- patterned tapa mat
  local mt=mk(); E(mt,240,232,170,28)
  local r1,r2,r3=R6(RP("#ffe090","#e0a058","#a8684c","#603a48")),R6(RP("#d07858","#a8504a","#7a3644","#4a2438")),R6(RP("#ffd8a0","#f0b070","#b8706c","#703c5c"))
  L(GX.rough(mt,4,1),function(x,y) local u=((x+y)//7+(x-y)//7)%2; local e=((x-240)/170)^2+((y-232)/28)^2; if e>.78 then return r3 end; return u==0 and r1 or r2 end,{R=16,tex=.2,seed=3})
  -- bowl (tanoa) with legs
  shadow(240,252,48,6,"#7a4040")
  local BWL=RP("#ffc070","#c87840","#8a4838","#4e2a38")
  for k=-3,3,2 do limb(240+k*10,240,240+k*12,253,3,2,BWL,k+9) end
  local bw=mk(); E(bw,240,232,44,15); bw:cut(rc(190,200,290,224)); bw=GX.rough(bw,3,1); L(bw,BWL,{R=14,tex=.3,sc=2,seed=9,fn=function(x,y) return (((x+y)//4)%2)*.05 end})
  for k=-40,40,2 do local yy=236+floor(sqrt(max(0,1-(k/44)^2))*6); px(240+k,yy,(k//2)%3==0 and "#ffe8a0" or "#8a4838") end
  for k=-38,38,8 do local yy=240+floor(sqrt(max(0,1-(k/44)^2))*5); px(240+k,yy,"#4e2a38"); px(240+k+1,yy+1,"#4e2a38"); px(240+k+2,yy,"#4e2a38") end
  local rimm=mk(); E(rimm,240,225,44,7); L(rimm,BWL,{R=4,tex=.2,seed=2})
  local lq=mk(); E(lq,240,225,38,5); L(lq,RP("#fff0c8","#e0c890","#b09868","#7a6a58"),{R=5,tex=.2,sc=2,seed=4,ink=false,rimlight=false})
  for k=-34,34,4 do px(240+k,221+floor(abs(k)/12),"#ffe8a0") end
  for k=0,3 do px(226+k*8,224+(k%2),"#fffae8") end
  fill(250,224,256,224,"#b09868"); fill(222,226,226,226,"#b09868")
  -- coconut cups
  local COCO=RP("#d8985c","#8a5438","#5e3638","#38222e")
  for _,p in ipairs{{150,238},{330,238},{184,256},{296,256}} do local m=mk(); E(m,p[1],p[2],9,7); m:cut(rc(p[1]-11,p[2]-9,p[1]+11,p[2]-3)); L(GX.rough(m,p[1],1),COCO,{R=5})
    fill(p[1]-7,p[2]-4,p[1]+7,p[2]-3,INK); fill(p[1]-6,p[2]-4,p[1]+6,p[2]-4,"#d8c090") end
  -- torches
  for _,x in ipairs{92,388} do limb(x,206,x,150,2,2,DWOOD,x); blob(x,148,5,3,DWOOD,x,{R=3}); fire(x,148,.9,.3) end
  lantern(240,76,6,30,"#ffa040"); fill(240,70,240,70,INK)
  -- turtles
  turtle(96,264,1.9,1,RP("#a8d870","#4a9448","#2e6444","#1a3a40"),RP("#c8e478","#6cb850","#3a8050","#1e4a48"),3)
  turtle(384,264,1.9,-1,RP("#f0c878","#c08a48","#8a5238","#4a2c34"),RP("#d8e090","#9ab858","#5a8050","#2e4a44"),7)
  -- tiny turtle quirk wearing a flower
  note(212,100); note(268,112)
end

---------------------------------------------------------------- floating flower market
SC["haven-floating-flower-market"]=function()
  local WC={"#58c8d8","#48b4cc","#3aa0c0","#3088b0","#2a74a0","#246090"}
  sky({"#8ac8f0","#a8d8f4","#c8e4f4","#f0e8e0","#ffe8c8"},120,3)
  local mt=mk(); for x=0,479 do local y=100-floor(46*(sin(x/70+1)*.5+.5)^1.4)+floor(3*sin(x/8)); for yy=y,122 do mt:set(x,yy) end end
  L(mt,RP("#d0e0f8","#7ca0d0","#4c70a8","#2c4078"),{R=30,tex=.3,sc=4,seed=5,rimlight=false,ink=false})
  hills(function(x) return 114+floor(5*sin(x/23)+3*sin(x/7)) end,RP("#a8d860","#48a048","#2a6a48","#183a40"),3,134)
  GX.bands(c,128,269,WC,5,.16)
  for i=0,110 do local x,y=floor(H(i,7,1)*470),132+floor(H(i,8,1)*136); fill(x,y,x+3+i%5,y,i%3==0 and "#c8f0f0" or WC[2]) end
  -- stilt houses
  for i,x in ipairs{80,240,400} do
    for k=-28,28,14 do fill(x+k,152,x+k+2,170,INK); fill(x+k,152,x+k,170,"#82444a") end
    box(x-34,122,x+34,156,i==2 and RP("#ffe0a8","#e8a868","#a8684c","#6a3a48") or WOOD,{R=16,tex=.4,fn=function(xx,yy) return ((xx-x)//6%2)*.06-.03 end})
    rwin(x-24,130,x-10,146,"#82444a","#e8a868"); rwin(x+10,130,x+24,146,"#82444a","#e8a868")
    roof(x-44,x+44,92,126,RP("#ff9a88","#d8485c","#982c5c","#581c50"),x,false)
    box(x-38,156,x+38,160,DWOOD,{R=3}); lantern(x,164,4,10)
    reflect(x-44,x+44,100,170,.3)
  end
  local FC={ {"#ffb8c8","#ff5a82","#b8306a","#6a2060"},{"#fff088","#ffc830","#c88a20","#7a5028"},{"#e8c8ff","#a878e8","#6a48b8","#38286a"},{"#ffc890","#ff8a28","#c05028","#703030"},{"#ffffff","#f4f0f8","#c8b8d0","#8a7898"} }
  local function flower(fx,fy,kind)
    local R=FC[kind]
    if kind==1 then blob(fx,fy,4,4,{hi=R[1],base=R[2],shade=R[3],deep=R[4]},fx+fy,{R=3,tex=0}); px(fx,fy,R[3]); px(fx+1,fy,R[3]); px(fx,fy+1,R[3]); px(fx-1,fy-1,R[1])
    elseif kind==2 then blob(fx,fy,5,5,{hi=R[1],base=R[2],shade=R[3],deep=R[4]},fx+fy,{R=4,tex=0}); blob(fx,fy,2,2,DWOOD,fx,{R=2,ink=false}); px(fx-1,fy-1,"#e8a868")
    elseif kind==3 then for k=0,3 do blob(fx+(k%2),fy-k*3,2,2,{hi=R[1],base=R[2],shade=R[3],deep=R[4]},fx+k,{R=2,tex=0}) end; fill(fx,fy+2,fx,fy+6,GRN.shade)
    elseif kind==4 then blob(fx,fy,4,4,{hi=R[1],base=R[2],shade=R[3],deep=R[4]},fx+fy,{R=3,tex=0}); for a=0,3 do px(fx+cos(a*1.57+.7)*2,fy+sin(a*1.57+.7)*2,R[3]) end
    else blob(fx,fy,4,4,{hi=R[1],base=R[2],shade=R[3],deep=R[4]},fx+fy,{R=3,tex=0}); blob(fx,fy,2,2,GOLD,fx,{R=2,ink=false,rimlight=false}) end
  end
  local function boat(cx,cy,w,R,sd,stripe)
    local m=mk(); for x=cx-w,cx+w do local u=(x-cx)/w; local top=cy-floor(9*u^4*(u>0 and 1 or 1)); local bot=cy+11-floor(8*abs(u)^2.2); for y=top,bot do m:set(x,y) end end
    L(GX.rough(m,sd,1),R,{R=14,tex=.4,sc=2,seed=sd,fn=function(xx,yy) return ((xx//5)%2)*.04 end})
    m:each(function(xx,yy) if yy==cy+4 or yy==cy+5 then px(xx,yy,stripe) end end)
    fill(cx-w+2,cy-3,cx+w-2,cy-3,R.hi)
  end
  local function fboat(cx,cy,w,R,sd,stripe,kinds)
    boat(cx,cy,w,R,sd,stripe)
    for k=0,floor(w/5) do blob(cx-w+8+k*10,cy-6-(k%2)*2,9,7,GRN2,sd+k,{R=5,tex=.3}) end
    for k=0,floor(w/3.2) do local fx=cx-w+6+floor(k*3.2*2*w/(w*2+0)+0)*1; fx=cx-w+7+floor(k*(2*w-14)/floor(w/3.2)); local fy=cy-12-floor(H(k,sd,2)*8)-floor((1-abs(fx-cx)/w)*4)
      flower(fx,fy,kinds[(k%#kinds)+1]) end
    reflect(cx-w,cx+w,cy-20,cy+11,.42)
  end
  fboat(110,206,66,RP("#78d8c0","#38a898","#2a6a78","#1c3c58"),3,"#fff0d0",{1,1,5,1})
  -- awning boat with lavender and daisies
  boat(244,182,44,RP("#ffd878","#e8a040","#a8684a","#603a48"),5,"#f0585c")
  for k=0,7 do blob(210+k*10,176,6,6,GRN2,k,{R=4}) end
  for k=0,6 do flower(212+k*10,168-(k%2)*3,(k%2==0) and 3 or 5) end
  fill(206,150,206,170,INK); fill(282,150,282,170,INK)
  for i=0,5 do local x0=204+i*13; poly({{x0,148},{x0+13,148},{x0+14,160},{x0-1,160}},i%2==0 and RED or CREAM,{R=5,tex=.1}) end
  reflect(200,288,150,193,.4)
  fboat(366,226,74,WOOD,4,"#ffd860",{2,2,4,2})
  fboat(444,184,34,RP("#e8a0f0","#b870d0","#7a48a0","#442c70"),6,"#fff0c0",{4,4,1})
  -- lily pads w/ blooms
  for i,p in ipairs{{40,168},{62,248},{170,250},{300,240},{20,226},{455,250}} do blob(p[1],p[2],9,3,GRN,i+30,{R=3}); fill(p[1],p[2]-1,p[1]+5,p[2],WC[3]); if i%2==0 then flower(p[1]-2,p[2]-3,1) else flower(p[1]-2,p[2]-3,5) end end
  -- duck family
  duck(150,248,1.3,1); for i=1,3 do duck(128-i*16,252+(i%2)*3,.65,1) end
  duck(300,256,1,-1)
  -- hanging lanterns on a pole
  fill(70,120,70,166,INK); lantern(70,166,5,18); fill(430,130,430,170,INK); lantern(430,170,5,18)
  for i=0,22 do px(floor(H(i,3,8)*470),140+floor(H(i,4,8)*120),FC[i%5+1][2]) end
end

---------------------------------------------------------------- gaucho gnome ranch
SC["haven-gaucho-gnome-ranch"]=function()
  sky({"#6ab4ec","#88c8f0","#a8d8f4","#d0e8f0","#f8f0d8","#ffe8b8"},170,3)
  cloud(90,40,28,CL,1); cloud(300,28,24,CL,2); cloud(410,62,22,CL,3)
  hills(function(x) return 142+floor(5*sin(x/40)+3*sin(x/13)) end,RP("#c8e090","#90b860","#5a8a54","#34543e"),2,200)
  GX.ground(c,function(x) return 160+floor(1*sin(x/50)) end,RP("#e8e078","#b8b850","#7a8a48","#4a5a3c"),7,{top=.8,fall=.5,tex=.35,sc=9})
  -- ranch house
  shadow(130,206,100,6,"#6a7040")
  box(50,128,210,200,CREAM,{R=40,tex=.2,rimlight=false})
  for x=50,210,8 do px(x,199,"#e0b0a0") end
  rwin(66,144,92,172,"#b86e44","#e8a868"); rwin(168,144,194,172,"#b86e44","#e8a868")
  local dm=rc(110,150,150,200); L(dm,RP("#e8a060","#b8643c","#7a3c44","#46243a"),{R=20,tex=.4}); rwin(118,158,142,176,"#46243a","#e8a060")
  fill(110,150,150,150,INK)
  local tile=RP("#ffa878","#e0603c","#a03c48","#5e2040")
  poly({{130-94,132},{130+94,132},{130+70,96},{130-70,96}},tile,{R=20,seed=4,tex=.3,fn=function(x,y) return ((x+(y//5)*3)%6==0) and -.12 or ((y-96)%5==0 and -.1 or 0) end})
  fill(36,132,224,134,INK)
  box(176,82,188,110,STONE,{R=4}); for k=0,2 do px(182+k,76-k*5,"#fff0c0") end
  lantern(100,138,4,12); lantern(160,138,4,12)
  -- windmill
  poly({{396,100},{420,100},{428,196},{388,196}},RP("#e8ecf8","#a8b0d0","#6c78a0","#3c4470"),{R=20,tex=.3,sc=4,seed=5})
  poly({{400,80},{416,80},{420,100},{396,100}},RP("#a8b0d0","#6c78a0","#4a5488","#2a3060"),{R=4})
  for k=0,3 do local a=k*pi/2+.5; for t=0,38 do local x,y=408+floor(cos(a)*t),88+floor(sin(a)*t); fill(x,y,x+1,y+1,t>12 and "#ffe090" or INK) end end
  blob(408,88,4,4,DWOOD,3,{R=3}); rwin(402,140,414,160,"#46243a","#e8a868")
  -- fence
  for x=20,470,30 do box(x,190,x+4,226,DWOOD,{R=4,tex=.3}) end
  box(16,200,476,204,WOOD,{R=3}); box(16,214,476,218,WOOD,{R=3})
  -- animals
  shadow(310,254,38,5,"#6a7040"); shadow(416,262,42,5,"#6a7040")
  horse(312,252,1.05,1,RP("#e8a070","#b86840","#7a3c44","#42223a"),RP("#6a4050","#3c2434","#2a1a2a","#1a1020"))
  cow(420,262,1.05,-1,{{-4,-36,9,7},{12,-30,7,8},{-18,-30,6,6},{22,-40,5,5}})
  -- asado fire: iron cross stakes and ribs
  shadow(160,264,60,6,"#4a3a3c")
  for i=0,12 do local a=i/13*6.283; blob(160+cos(a)*32,262+sin(a)*5,5,3,STONE,i+40,{R=2}) end
  glow(160,246,70,44,"#ff9030",.2)
  fire(160,262,2.2,.3)
  for _,dx in ipairs{-26,26} do fill(160+dx,214,160+dx+2,262,INK); fill(160+dx,214,160+dx,262,"#8a8aa0") ; fill(160+dx-1,214,160+dx+3,215,INK) end
  fill(134,228,186,230,INK); fill(134,228,186,228,"#a8a8c0")
  local rib=c:poly({{140,230},{180,230},{176,246},{144,246}}); L(rib,RP("#ff9a70","#c8503c","#8a3040","#4a1c38"),{R=10,tex=.4,seed=4,fn=function(x,y) return ((x//5)%2)*.1 end})
  for k=144,176,6 do fill(k,230,k,246,"#fff0d0") end
  for k=0,2 do px(150+k*10,248,"#ffd860"); px(151+k*10,250,"#ffd860") end
  for _,p in ipairs{{30,250},{100,262},{250,262},{460,264}} do tuft(p[1],p[2],GRASS) end
  -- gaucho gnome's hat quirk on the fence
  poly({{94,190},{114,190},{112,182},{96,182}},RP("#6a5060","#44323e","#2c2030","#1c1424"),{R=4}); fill(90,190,118,191,INK)
end

---------------------------------------------------------------- baobab inn
SC["haven-baobab-inn"]=function()
  sky({"#5a3c8c","#8a4c96","#c0607c","#e88a6c","#ffb470","#ffd88c","#ffeaa8"},200,4)
  glow(368,142,70,56,"#fff4c0",.25); blob(368,142,26,26,RP("#fffbe0","#ffe890","#ffc468","#f09858"),9,{R=16,tex=.1,ink=false,rimlight=false})
  for i=0,5 do local x,y=60+i*30+floor(H(i,1,2)*20),50+floor(H(i,2,2)*50); px(x,y,INK); px(x+1,y-1,INK); px(x+2,y,INK); px(x+3,y-1,INK); px(x+4,y,INK) end
  hills(function(x) return 148+floor(10*sin(x/70)+4*sin(x/19)) end,RP("#f0a8a8","#c87894","#905a82","#60406c"),2)
  hills(function(x) return 166+floor(8*sin(x/50+2)+3*sin(x/15)) end,RP("#e89080","#b86470","#804a74","#503860"),3)
  hills(function(x) return 180+floor(6*sin(x/36+1)+2*sin(x/11)) end,RP("#c8b068","#8a8a50","#58684a","#38483e"),4)
  for _,p in ipairs{{50,176},{150,172},{420,178},{462,174}} do fill(p[1],p[2]-18,p[1],p[2],"#38283e"); fill(p[1]-1,p[2]-18,p[1]+1,p[2]-14,"#38283e"); blob(p[1],p[2]-22,16,4,RP("#58684a","#38483e","#2a3040","#1c2034"),p[1],{R=3,ink=false,rimlight=false}) end
  GX.ground(c,function(x) return 196+floor(2*sin(x/41)) end,RP("#fff0c0","#f2c890","#c8946c","#8a5a60"),5,{top=.86,fall=.5,tex=.3,sc=8})
  -- trunk
  shadow(240,236,130,8,"#8a5a60")
  local tr=mk(); for y=40,238 do local t=(y-40)/198; local hw=floor(44+8*sin(y/17)+30*t^2.6); for x=240-hw,240+hw do tr:set(x,y) end end
  for k=-1,1,2 do for t=0,30 do tr:set(240+k*(86+t), 238-floor(t*.25)) end end
  L(GX.rough(tr,4,1),RP("#f0b080","#c07a58","#8a4a52","#52284a"),{R=44,tex=.5,sc=3,seed=4,fn=function(x,y) local g=(x+floor(7*sin(y/21)))%14; return g==0 and -.18 or (g==1 and .07 or 0) end})
  -- branches + crown
  for _,b in ipairs{{-20,52,-110,28},{20,50,110,30},{-6,44,-40,12},{8,44,40,10}} do limb(240+b[1],b[2]+14,240+b[3],b[4]+8,9,4,RP("#f0b080","#c07a58","#8a4a52","#52284a"),b[1]) end
  for i,p in ipairs{{120,30,34,14},{176,16,36,14},{240,10,38,14},{304,16,36,14},{362,32,34,14},{150,48,24,10},{332,50,24,10}} do blob(p[1],p[2],p[3],p[4],i%2==0 and GRN or GRN2,i*3,{R=10,tex=.4}) end
  -- door in trunk
  local dm=rc(218,164,262,238); E(dm,240,176,22,18)
  c:rim(dm,INK); dm:each(function(x,y) local t=(y-150)/88; px(x,y,t<.25 and "#fff4c0" or (t<.6 and "#ffd060" or "#f0a040")) end)
  for x=222,258,7 do fill(x,168,x,238,"#8a4a4a") end
  glow(240,230,60,26,"#ffb050",.25)
  box(208,232,272,240,WOOD,{R=4}); box(214,240,266,246,DWOOD,{R=3})
  rwin(168,128,186,150,"#82444a","#e8a868"); rwin(294,128,312,150,"#82444a","#e8a868"); rwin(214,92,230,110,"#82444a","#e8a868"); rwin(250,92,266,110,"#82444a","#e8a868")
  -- hanging lanterns on ropes
  for _,p in ipairs{{150,50,150},{330,52,166},{190,56,98},{290,56,98},{110,32,120},{372,36,120}} do fill(p[1],p[2],p[1],p[3]-6,INK); lantern(p[1],p[3],6,24) end
  -- sign
  fill(116,186,116,246,INK); box(92,172,140,196,WOOD,{R=8}); px(106,184,"#4a2840"); local mn=mk(); E(mn,112,184,6,6); local cu=mk(); E(cu,115,182,5,5); mn:cut(cu); c:fillMask(mn,"#ffe890"); fill(124,180,132,180,"#4a2840"); fill(124,186,130,186,"#4a2840")
  -- barrel table + stools
  local bar=mk(); for y=214,246 do local t=(y-214)/32; local hw=floor(15+3*sin(t*pi)); for x=380-hw,380+hw do bar:set(x,y) end end
  L(bar,WOOD,{R=16,tex=.4,seed=3,fn=function(x,y) return ((x//6)%2)*.07 end}); fill(364,222,396,222,"#6a7098"); fill(364,238,396,238,"#6a7098")
  box(362,208,398,214,DWOOD,{R=3}); blob(374,205,3,4,GOLD,3,{R=2}); blob(386,205,3,4,GOLD,4,{R=2})
  for _,x in ipairs{58,430} do fill(x-2,238,x+2,252,INK); blob(x,236,9,4,WOOD,x,{R=3}) end
  -- meerkat sentry on a mound
  blob(448,252,22,7,RP("#fff0c0","#e8b880","#b8806c","#7a5058"),3,{R=5}); meerkat(448,248,1.5)
  for _,p in ipairs{{60,230},{190,252},{300,258},{20,252}} do tuft(p[1],p[2],RP("#e8d870","#a8a048","#6e7448","#44503c")) end
end

---------------------------------------------------------------- turtle nesting beach
SC["haven-turtle-nesting-beach"]=function()
  sky({"#161840","#201e5a","#2c2c72","#3e3c88","#5a4a98"},150,2)
  stars(90,110,4)
  local m=mk(); E(m,360,52,24,24); L(m,RP("#fffbe8","#ffe898","#e8b870","#b88068"),{R=20,tex=.2,seed=3,ink=false,rimlight=false})
  for _,p in ipairs{{352,46,4},{368,58,3},{362,40,2}} do blob(p[1],p[2],p[3],p[3],RP("#f8d888","#e8b870","#c89068","#a07060"),p[1],{R=2,ink=false,rimlight=false}) end
  glow(360,52,60,60,"#8878d0",.1)
  GX.bands(c,150,200,{"#2c3c88","#2a4c94","#2a5c9c","#3e74ac","#5a8cb8"},5,.2)
  for i=0,44 do local y=152+floor(H(i,1,3)*40); local x=360+floor((H(i,2,3)-.5)*(14+(y-150)*1.4)); fill(x,y,x+2+i%5,y,(i%2==0) and "#fff0b0" or "#ffd880") end
  for i=0,50 do fill(floor(H(i,7,1)*470),152+floor(H(i,8,1)*44),floor(H(i,7,1)*470)+3,152+floor(H(i,8,1)*44),"#5a8cb8") end
  local yfn=function(x) return 198+floor(3*sin(x/41)+2*sin(x/11+1)) end
  GX.ground(c,yfn,RP("#e8d8f0","#b8a8d8","#7a6aa8","#4a4078"),7,{top=.86,fall=.5,tex=.3})
  for x=0,479 do local y0=yfn(x); px(x,y0-1,"#f4f8ff"); px(x,y0,"#e8f0ff"); px(x,y0+1,"#8ab0d8"); if GX.vn(x,3,5,9)>.5 then px(x,y0-2,"#d0e0f8") end end
  -- hut, bigger
  local HR=RP("#e8a868","#b86e44","#82444a","#4a2840")
  shadow(396,232,92,6,"#4a4078")
  for k=0,3 do fill(332+k*30,226,334+k*30,242,INK); fill(332+k*30,226,332+k*30,242,"#82444a") end
  box(326,166,466,230,HR,{R=36,tex=.45,seed=3,fn=function(x,y) return ((x-326)//8%2)*.08 end})
  for x=326,466,8 do fill(x,166,x,230,"#4a2840") end
  roof(310,482,112,170,THATCH,4,true); fill(308,170,484,173,INK)
  fill(396,100,396,114,INK); poly({{397,100},{410,104},{397,108}},RED,{R=3})
  rwin(346,184,382,214,"#6a3a30","#e8a868"); glow(364,240,50,10,"#ffc060",.3)
  local dm=rc(412,184,448,230); win(dm,184,230,"#6a3a30")
  lantern(330,196,5,18); lantern(462,196,5,18)
  box(404,230,456,236,DWOOD,{R=3})
  -- campfire
  glow(270,226,70,24,"#ff9040",.2)
  for i=0,8 do local a=i/9*6.283; blob(270+cos(a)*22,236+sin(a)*6,5,3,STONE,i+3,{R=2}) end
  fire(270,238,1.4,.3)
  -- mama turtle
  shadow(150,254,96,7,"#4a4078")
  turtle(150,256,3.3,1,RP("#a8d870","#4a9448","#2e6444","#1a3a40"),RP("#c8e478","#6cb850","#3a8050","#1e4a48"),8)
  -- tracks + hatchlings
  for k=0,14 do px(236+k*4,266-(k%2)*2,"#7a6aa8"); px(236+k*4,268-(k%2)*2,"#7a6aa8") end
  for k=0,6 do local x=246+k*30; local y=244+floor(sin(k*1.7)*5); turtle(x,y+10,.5,(k%3==2) and -1 or 1,RP("#a8d870","#4a9448","#2e6444","#1a3a40"),RP("#c8e478","#6cb850","#3a8050","#1e4a48"),k+20) end
  -- nest with eggs
  blob(40,246,26,7,RP("#b89ad8","#8a78b8","#5a4a90","#38306a"),4,{R=5})
  for k=0,4 do blob(24+k*8,240-(k%2)*2,4,5,RP("#fffaf4","#fff0e8","#d8b8c8","#9878a0"),k,{R=3}) end
  for i=0,12 do c:sparkle(floor(H(i,3,3)*470),194) end
end

---------------------------------------------------------------- market of a thousand chilies
SC["haven-market-of-a-thousand-chilies"]=function()
  sky({"#78c0e8","#98d0ec","#c8e4e0","#f8ecc0","#ffe0a0"},180,2)
  cloud(70,40,22,CL,3); cloud(420,52,18,CL,4)
  hills(function(x) return 150+floor(14*sin(x/70+1)+5*sin(x/13)) end,{hi="#d8a8c8",base="#a878a8",shade="#745890",deep="#4a3c70"},5,222)
  GX.ground(c,function(x) return 210+floor(2*sin(x/30)) end,{hi="#ffe8b0",base="#f0c080",shade="#c8886a",deep="#8a5a5a"},7,{top=.86,fall=.5,tex=.3})
  local AW1={hi="#ff9a88",base="#e8403c",shade="#a02c4c",deep="#601c48"}
  local ADO={hi="#f8c898",base="#d8905c",shade="#a05c48",deep="#643c48"}
  shadow(240,212,200,5,"#b88068")
  -- back shop
  box(126,104,354,210,ADO,{R=40,tex=.4,sc=3,seed=8})
  box(150,140,330,208,{hi="#a86858",base="#6a3c48",shade="#442840",deep="#2a1c34"},{R=30,tex=.3,rimlight=false,seed=9})
  for i=0,6 do local x=156+i*24; fill(x,160,x+16,162,INK); fill(x,160,x+16,160,"#c88858"); for k=0,3 do blob(x+2+k*4,156,2,3,CHIS[(i+k)%4+1],x+k,{R=2}) end end
  for i=0,5 do blob(164+i*30,184,6,7,{hi="#ffd890",base="#e8a048",shade="#a8604c",deep="#603844"},i,{R=4}) end
  local aw=mk(); for x=112,368 do local y1=136+floor(2*sin(x/6)+1); for y=106,y1 do aw:set(x,y) end end; aw=GX.rough(aw,3,1)
  local ra,rb=R6(AW1),R6(CREAM)
  L(aw,function(x,y) return ((x//12)%2==0) and ra or rb end,{R=8,tex=.2,seed=4})
  fill(110,102,370,106,INK); fill(111,103,369,104,"#a8683c")
  for _,x in ipairs{136,170,310,344} do chiliStr(x,138,6+(x%3),x) end
  for _,x in ipairs{210,270} do lantern(x,148,5,18,"#ff7048") end
  -- counter + gecko
  gecko(240,170,1)
  box(160,186,320,212,RP("#e8a868","#b86e44","#82444a","#4a2840"),{R=20,tex=.45,seed=11,fn=function(x,y) return ((y-186)//7%2)*.08 end})
  fill(158,184,322,187,INK); fill(159,185,321,185,"#f4b878")
  for i=0,8 do blob(168+i*16,180,7,5,CHIS[i%4+1],i+3,{R=4}) end
  -- side stalls
  local function stall(x0,x1,c1,c2,R,sd,dir)
    shadow((x0+x1)/2,214,(x1-x0)/2+6,4,"#b88068")
    for _,px0 in ipairs{x0+4,x1-8} do box(px0,100,px0+5,214,DWOOD,{R=4,tex=.3}) end
    box(x0+4,176,x1-4,214,RP("#e8a868","#b86e44","#82444a","#4a2840"),{R=18,tex=.45,seed=sd,fn=function(x,y) return ((y-176)//7%2)*.08 end}); fill(x0+2,174,x1-2,177,INK); fill(x0+3,175,x1-3,175,"#f4b878")
    local a=mk(); for x=x0-6,x1+6 do local y1=120+floor(2*sin(x/6)+1)+((x-x0)%2==0 and 0 or 0); for y=84+floor(abs(x-(x0+x1)/2)*.15*dir),y1 do a:set(x,y) end end; a=GX.rough(a,sd,1)
    local r1,r2=R6(c1),R6(c2)
    L(a,function(x,y) return ((x//10)%2==0) and r1 or r2 end,{R=8,tex=.2,seed=sd})
    for x=x0-6,x1+6,10 do fill(x,121,x+4,124,((x//10)%2==0) and c1.base or c2.base); fill(x,125,x+4,125,INK) end
    for x=x0+16,x1-14,22 do chiliStr(x,128,3+(x%2),x+sd) end
  end
  stall(4,108,AW1,CREAM,AW1,5,1)
  stall(372,476,RP("#c8f088","#58a848","#2e7048","#1a4638"),CREAM,GRN,6,-1)
  -- baskets heaped with chilies, front
  basket(40,246,26,16,{CHIS[1],CHIS[2],CHIS[1]},3); basket(86,258,20,13,{CHIS[3],CHIS[4]},4)
  basket(440,248,26,16,{CHIS[2],CHIS[4],CHIS[1]},5); basket(394,260,20,13,{CHIS[1],CHIS[3]},6)
  box(150,224,178,244,RP("#d89860","#a8683c","#744238","#44283a"),{R=8,tex=.4}); for k=0,3 do for j=0,1 do chili(156+k*6,222+j*3,CHIS[(k+j)%4+1],k%2*2-1) end end
  -- chili-pepper flag
  fill(256,60,256,102,INK); poly({{257,60},{286,68},{257,78}},RP("#ffd870","#f0a030","#b86030","#683840"),{R=5})
  -- sacks
  for _,p in ipairs{{300,238},{330,244}} do local m=mk(); E(m,p[1],p[2],14,15); L(GX.rough(m,p[1],1),RP("#f8e8c8","#d8b888","#a08068","#644858"),{R=10,tex=.4,seed=p[1]}); fill(p[1]-5,p[2]-16,p[1]+5,p[2]-13,"#a08068"); blob(p[1],p[2]-6,7,4,CHIS[2],9,{R=3}) end
end

---------------------------------------------------------------- sugar shack
SC["haven-the-sugar-shack"]=function()
  sky({"#9ac4e8","#b8d4ec","#d8e4ee","#f4e8dc","#ffe4c0"},170,2)
  cloud(80,44,22,CL,3); cloud(360,34,26,CL,4)
  hills(function(x) return 152+floor(14*sin(x/65)+4*sin(x/15)) end,{hi="#f0f0ff",base="#c0c8e0",shade="#8a90b8",deep="#586088"},3,215)
  for x=0,479,4 do if H(x,1,2)<.5 then local y=floor(152+14*sin(x/65)+4*sin(x/15)); fill(x,y+8,x+2,y+30,"#4a3448") end end
  GX.ground(c,function(x) return 212+floor(2*sin(x/38)) end,{hi="#ffffff",base="#e8eefc",shade="#a8b4dc",deep="#6e7cac"},7,{top=.9,fall=.4,tex=.2})
  local LOG={hi="#e8a868",base="#b8683c",shade="#843c40",deep="#4a2438"}
  local SNW=RP("#ffffff","#e8f0ff","#a8b8e0","#6a78b0")
  shadow(250,214,110,5,"#9aa8d0")
  -- log walls
  box(166,128,334,212,LOG,{R=40,tex=.4,seed=3,fn=function(x,y) return ((y-128)//9%2)*.1-.05 end})
  for y=137,211,9 do fill(166,y,334,y,"#4a2438") end
  for y=128,204,9 do blob(166,y+4,4,4,LOG,y,{R=3}); blob(334,y+4,4,4,LOG,y+1,{R=3}) end
  -- roof
  poly({{150,132},{350,132},{300,78},{200,78}},RP("#c88a68","#8a4a4a","#5a3248","#34223c"),{R=26,seed=5,fn=function(x,y) return ((y-78)%6==0) and -.14 or (((x+(y//6)*3)%8==0) and -.1 or 0) end})
  poly({{146,134},{354,134},{303,74},{197,74}},SNW,{R=28,seed=6,fn=function(x,y) return y>110 and 0 or 0 end})
  poly({{160,140},{340,140},{310,118},{190,118}},RP("#c88a68","#8a4a4a","#5a3248","#34223c"),{R=18,seed=7,fn=function(x,y) return ((y-118)%6==0) and -.12 or 0 end})
  for x=148,352,7 do local w=2+floor(H(x,1,2)*3); for y=134,138+floor(H(x,2,3)*8) do fill(x,y,x+w,y,(y>136) and "#bcd0f0" or "#e8f0ff") end end
  -- cupola vent
  box(226,52,274,80,LOG,{R=14,seed=9}); fill(232,58,268,74,"#34223c"); for x=234,264,6 do fill(x,58,x+3,74,"#5a3248") end
  poly({{220,54},{280,54},{262,38},{238,38}},SNW,{R=10});
  for i=0,6 do blob(250+floor(sin(i*1.2)*14),28-i*9,8+i,6+i//2,{hi="#ffffff",base="#f4f4fc",shade="#d0d8ec",deep="#a0acd0"},i+9,{R=5,ink=false}) end
  -- open front with evaporator pan
  local op=rc(196,152,304,212); c:rim(op,INK); op:each(function(x,y) px(x,y,(y<178) and "#5a3248" or "#3c2438") end)
  glow(250,196,64,36,"#ff9040",.3)
  for k=0,6 do local fx=202+k*14; local m=tongue(fx+6,208,14+(k%3)*3,5,(k%2==0) and .3 or -.3); c:fillMask(m,"#ff7a30"); c:fillMask(tongue(fx+6,208,9+(k%3)*2,3,0),"#ffd060") end
  box(196,184,304,196,{hi="#c0c0d0",base="#8a8aa0",shade="#545470",deep="#2c2c44"},{R=6,seed=3}); fill(200,179,300,185,"#d89040"); fill(200,179,300,180,"#ffd878")
  for k=0,6 do blob(206+k*14,176-(k%2)*2,5,3,{hi="#ffffff",base="#fff0c8",shade="#e8c890",deep="#b8906c"},k,{R=3,ink=false}) end
  for k=0,4 do px(210+k*20,182,"#fff0a0") end
  fill(196,208,304,212,"#3a2a38"); fill(196,212,304,213,INK)
  rwin(170,150,186,172,"#6a3a30","#c88858"); rwin(314,150,330,172,"#6a3a30","#c88858")
  lantern(188,192,4,14)
  -- woodpile left of shack
  for r=0,3 do for k=0,5-r do local bx,by=100+k*13+r*6,208-r*10; blob(bx,by,6,5,{hi="#e8b078",base="#b87848",shade="#82484a",deep="#4a2840"},k+r*9,{R=3}); fill(bx-1,by-1,bx+1,by+1,"#e8c898") end end
  -- maple trees
  local MP=RP("#b89888","#786068","#4a3a50","#2c2038")
  local function maple(x,by,sd,lean)
    local tr=mk(); for y=by-120,by do local t=(by-y)/120; local hw=floor(6+8*t^2.8+1.5*sin(y/9)); for xx=x-hw,x+hw do tr:set(xx,y) end end
    L(GX.rough(tr,sd,1),MP,{R=10,tex=.5,sc=3,seed=sd,fn=function(xx,yy) local g=(xx+floor(2*sin(yy/13)))%5; return g==0 and -.2 or (g==1 and .08 or 0) end})
    for k=0,3 do local ky=by-110+k*28; fill(x-5,ky,x-3,ky+1,MP.deep) end
    limb(x,by-112,x-34*lean,by-150,5,3,MP,sd+1); limb(x,by-112,x+30*lean,by-148,5,3,MP,sd+2); limb(x,by-90,x+36*lean,by-120,3,2,MP,sd+3)
    for _,b in ipairs{{-1,-76},{1,-58}} do
      local bx,byy=x+b[1]*9,by+b[2]
      fill(bx,byy,bx+b[1]*4,byy,INK); fill(bx,byy+1,bx+b[1]*4,byy+1,"#c8c8d8")
      bucket(bx+b[1]*8,byy+1,sd+b[2]); px(bx+b[1]*8,byy+16,"#e8b868")
    end
    GX.foliage(c,x,by-150,48,24,{hi="#ffc878",base="#f0783c",shade="#b0403e",deep="#5a2840"},sd+4)
    GX.foliage(c,x-30*lean,by-138,24,14,{hi="#ffb868",base="#e8683c",shade="#a8403e",deep="#5a2840"},sd+6)
    GX.foliage(c,x+30*lean,by-134,24,14,{hi="#ffd888",base="#f08a38",shade="#b04a3e",deep="#5a2840"},sd+7)
    for i=0,5 do px(x-30+H(i,sd,1)*60,by-124+i*12,"#f0783c") end
  end
  maple(60,226,3,1); maple(436,230,5,-1); maple(18,244,8,1)
  -- squirrel on stump + barrel
  shadow(392,240,34,4,"#9aa8d0")
  local bar=mk(); for y=210,240 do local t=(y-210)/30; local hw=floor(16+3*sin(t*pi)); for x=388-hw,388+hw do bar:set(x,y) end end
  L(bar,{hi="#e8a868",base="#b86e44",shade="#82444a",deep="#4a2840"},{R=16,tex=.4,seed=3,fn=function(x,y) return ((x//6)%2)*.07 end})
  for _,by in ipairs{216,232} do fill(370,by,406,by+1,"#6a7098") end
  fill(372,207,404,210,INK); fill(373,208,403,208,"#ffb838")
  squirrel(300,250,1.2)
  for i=0,18 do px(floor(H(i,2,6)*470),214+floor(H(i,3,6)*50),"#a8b4dc") end
end

---------------------------------------------------------------- northern lights sauna
SC["haven-northern-lights-sauna"]=function()
  sky({"#10143a","#1a2050","#242a62","#2e3a74","#3e5088"},190,2)
  stars(70,100,3)
  for pass=1,2 do
    for x=0,479 do
      local cy=(pass==1 and 70 or 52)+floor(22*sin(x/70+pass)+8*sin(x/27+2)); local h=(pass==1 and 56 or 38)+floor(10*sin(x/41))
      local ray=floor((sin(x*.5+sin(x/11)*2)*.5+.5)*2.99)
      for k=0,h do local t=k/h; local y=cy-h//2+k; local col
        if pass==1 then
          if t<.12 then col="#6a58c8" elseif t<.28 then col="#4a98d8" elseif t<.62 then col=({"#38d898","#4aeaa8","#6af8bc"})[ray+1] elseif t<.86 then col=({"#2aa888","#34b898","#3cc8a0"})[ray+1] else col="#238070" end
          if (t>.92 and x%2==0) or (t<.05 and x%2==1) then col=nil end
        else
          if t<.2 then col="#8a58c8" elseif t<.6 then col=({"#b070d8","#c880e0","#d890e8"})[ray+1] else col=({"#7a50b8","#8a5cc8","#9a68d0"})[ray+1] end
          if (t>.9 and x%2==0) or (t<.08 and x%2==1) or ray==0 and t>.7 then col=nil end
        end
        if col then px(x,y,col) end end
    end
  end
  hills(function(x) return 168+floor(8*sin(x/45)+4*sin(x/12)) end,{hi="#7888b8",base="#505c98",shade="#34407a",deep="#22285a"},4,222)
  GX.ground(c,function(x) return 208+floor(2*sin(x/37)) end,{hi="#f8fcff",base="#c8d8f0",shade="#8a9ccc",deep="#5a6aa0"},7,{top=.88,fall=.45,tex=.25})
  for x=0,479,3 do if H(x,4,2)<.3 then px(x,214+floor(H(x,5,2)*50),"#8ae8c8") end end
  local LOG={hi="#e8a868",base="#b8683c",shade="#843c40",deep="#4a2438"}
  -- sauna cabin
  shadow(366,210,96,5,"#7888b8")
  box(290,130,444,210,LOG,{R=40,tex=.4,seed=3,fn=function(x,y) return ((y-130)//9%2)*.1-.05 end})
  for y=139,209,9 do fill(290,y,444,y,"#4a2438") end
  for y=130,200,9 do blob(290,y+4,4,4,LOG,y,{R=3}); blob(444,y+4,4,4,LOG,y+1,{R=3}) end
  poly({{274,134},{460,134},{424,94},{310,94}},{hi="#7a5a78",base="#5a3e5e",shade="#3c2a4a",deep="#241a38"},{R=20,seed=5})
  poly({{270,136},{464,136},{426,88},{308,88}},SNOW,{R=24,seed=6})
  for x=272,462,8 do local w=3+floor(H(x,1,2)*3); for y=136,140+floor(H(x,2,3)*7) do fill(x,y,x+w,y,(y>138) and "#a8b8e0" or "#e8f0ff") end end
  box(402,64,422,100,{hi="#c0a8b0",base="#8a7488",shade="#5c4a68",deep="#382c48"},{R=8,seed=7}); fill(400,62,424,66,INK); fill(401,63,423,64,"#b8a0b0")
  for i=0,5 do blob(412+floor(sin(i*1.3)*8),52-i*10,6+i,5+floor(i/2),{hi="#ffffff",base="#e8f0f8",shade="#b8c8e0",deep="#8898c0"},i+9,{R=4,ink=false}) end
  rwin(306,148,338,176,"#6a3a30","#c88858"); glow(322,196,40,10,"#ffb858",.3)
  local dm=rc(384,148,422,210); win(dm,148,210,"#6a3a30"); fill(378,206,428,210,"#c88858"); fill(378,210,428,211,INK)
  lantern(364,162,4,16)
  for k=0,3 do limb(346+k*5,150,346+k*5+1,160,1,2,GRN,k) end
  box(298,196,340,202,{hi="#e8b078",base="#b87848",shade="#82484a",deep="#4a2840"},{R=4}); fill(302,202,304,210,INK); fill(334,202,336,210,INK)
  local function spruce(cx,by,h,w)
    fill(cx-2,by-8,cx+2,by,INK); fill(cx-1,by-8,cx+1,by,"#6a3e44")
    for t=0,3 do local ty=by-8-t*floor(h/4); local ww=w-t*floor(w/4*.7); poly({{cx-ww,ty},{cx+ww,ty},{cx+3,ty-floor(h/4)-8},{cx-3,ty-floor(h/4)-8}},{hi="#78b888",base="#3e8068",shade="#26584e",deep="#173838"},{R=10,seed=t+cx})
      poly({{cx-ww+3,ty-2},{cx+ww-3,ty-2},{cx+2,ty-floor(h/4)-7},{cx-2,ty-floor(h/4)-7}},SNOW,{R=6,ink=false,rimlight=false}); fill(cx-ww,ty,cx+ww,ty,"#26584e") end
  end
  spruce(30,214,96,34); spruce(262,206,60,22); spruce(468,216,88,30)
  -- firewood stack
  for r=0,2 do for k=0,3-r do blob(238+k*9+r*4,206-r*7,4,3,LOG,k+r*5,{R=2}) end end
  -- tub with bear
  shadow(130,256,76,6,"#7888b8")
  local tub=mk(); for y=198,256 do local t=(y-198)/58; local hw=floor(66+4*sin(t*pi)); for x=130-hw,130+hw do tub:set(x,y) end end
  local TB=RP("#e8a868","#b0603c","#6e3a48","#3c2238")
  bear(130,168,1.4)
  L(GX.rough(tub,3,1),TB,{R=40,tex=.4,seed=3,fn=function(x,y) return ((x//7)%2)*.08-.04 end})
  for _,yy in ipairs{212,232,250} do fill(64,yy,196,yy,"#6a7098"); fill(64,yy+1,196,yy+1,INK) end
  local rim=mk(); E(rim,130,198,68,11); L(rim,RP("#f4b878","#d89050","#9a5a48","#5a3040"),{R=10,tex=.3,seed=2})
  local wt=mk(); E(wt,130,198,58,8); wt:cut(rc(60,180,200,194))
  c:fillMask(wt,"#58d0d8"); wt:each(function(x,y) if (x+y*2)%9==0 then px(x,y,"#b8f4f0") elseif y==194 then px(x,y,"#38a0c0") end end)
  fill(72,193,188,193,INK)
  for _,k in ipairs{-1,1} do blob(130+k*34,206,7,5,RP("#e8d0b0","#b88a64","#7a5454","#443040"),k+4,{R=4}) end
  for i=0,5 do blob(100+i*14+floor(sin(i)*5),150-i*14,6+i//2,5,{hi="#ffffff",base="#e8f0f8",shade="#b8c8e0",deep="#8898c0"},i+20,{R=3,ink=false}) end
  -- towel on bear's head
  box(112,134,148,144,RP("#ffffff","#fff0d8","#e0b8b0","#a07890"),{R=4,tex=.1}); fill(112,139,148,139,"#f0585c")
  -- skis quirk
  fill(222,164,224,212,INK); fill(228,166,230,212,INK); fill(223,164,223,212,"#e8b078"); fill(229,166,229,212,"#e8b078")
end


local name=app.params.name or "all"
local names={} for n in pairs(SC) do names[#names+1]=n end table.sort(names)
for _,n in ipairs(names) do
  if name=="all" or name==n then
    c=HP.canvas{w=480,h=270,scale=1,name=n}; local ok,e=xpcall(SC[n],debug.traceback); if not ok then print("ERR "..n.." "..e) end
    hem()
    c:save{aseprite=d.."/out/"..n..".aseprite",png=d.."/out/"..n..".png",scale=1}
  end
end
