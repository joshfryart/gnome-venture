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
