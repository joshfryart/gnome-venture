-- sketch (ui P3_U6)
local NAME="sketch" local W,H=96,96
local INK="#2b1c26"
local function rgb(h) h=h:gsub("#","") return app.pixelColor.rgba(tonumber(h:sub(1,2),16),tonumber(h:sub(3,4),16),tonumber(h:sub(5,6),16),255) end
local img=Image(W,H,ColorMode.RGBA)
local function P(x,y,c) if x>=0 and y>=0 and x<W and y<H then img:putPixel(x,y,rgb(c)) end end
local function key(x,y) return y*1000+x end
-- mask builders: return set table
local function mk(fn,x0,y0,x1,y1) local m={} for y=y0,y1 do for x=x0,x1 do if fn(x,y) then m[key(x,y)]=true end end end return m end
local function rectM(x0,y0,x1,y1) return mk(function() return true end,x0,y0,x1,y1) end
local function ellM(cx,cy,rx,ry) return mk(function(x,y) return ((x-cx)/rx)^2+((y-cy)/ry)^2<=1 end,math.floor(cx-rx)-1,math.floor(cy-ry)-1,math.ceil(cx+rx)+1,math.ceil(cy+ry)+1) end
local function polyM(pts) local x0,y0,x1,y1=1e9,1e9,-1e9,-1e9 for _,p in ipairs(pts) do x0=math.min(x0,p[1]) y0=math.min(y0,p[2]) x1=math.max(x1,p[1]) y1=math.max(y1,p[2]) end
 return mk(function(x,y) local c=false local px,py=x+0.5,y+0.5 local j=#pts for i=1,#pts do local a,b=pts[i],pts[j] if ((a[2]>py)~=(b[2]>py)) and (px<(b[1]-a[1])*(py-a[2])/(b[2]-a[2])+a[1]) then c=not c end j=i end return c end,x0,y0,x1,y1) end
local function sub(a,b) local m={} for k in pairs(a) do if not b[k] then m[k]=true end end return m end
local function has(m,x,y) return m[key(x,y)] end
-- bevel shade: ramp = 5 tones dark->light
local function shape(m,r,o) o=o or {}
 for k in pairs(m) do local x,y=k%1000,k//1000
  local up=not has(m,x,y-1) or not has(m,x-1,y)
  local dn=not has(m,x,y+1) or not has(m,x+1,y)
  local i=3
  if up and dn then i=2 elseif up then i=4 elseif dn then i=2 end
  if dn and (not has(m,x,y+1) and not has(m,x+1,y)) then i=1 end
  if up and not has(m,x-1,y-1) and not has(m,x,y-1) and not has(m,x-1,y) then i=5 end
  if o.fn then i=o.fn(x,y,i) or i end
  P(x,y,r[i]) end end
local function line(x0,y0,x1,y1,c) local n=math.max(math.abs(x1-x0),math.abs(y1-y0)) for i=0,n do local t=n==0 and 0 or i/n P(math.floor(x0+(x1-x0)*t+0.5),math.floor(y0+(y1-y0)*t+0.5),c) end end
local function outline()
 local add={} for y=0,H-1 do for x=0,W-1 do if img:getPixel(x,y)==0 then
  for _,d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do local nx,ny=x+d[1],y+d[2]
   if nx>=0 and ny>=0 and nx<W and ny<H and app.pixelColor.rgbaA(img:getPixel(nx,ny))>0 then add[#add+1]={x,y} break end end end end end
 for _,a in ipairs(add) do P(a[1],a[2],INK) end end
local function bitmap(rows,x0,y0,s,c) for j,r in ipairs(rows) do for i=1,#r do if r:sub(i,i)=="X" then for a=0,s-1 do for b=0,s-1 do P(x0+(i-1)*s+a,y0+(j-1)*s+b,c) end end end end end end
local function hash(x,y,s) local h=(x*374761393+y*668265263+s*2147483647)&0xffffffff h=((h~(h>>13))*1274126177)&0xffffffff return ((h~(h>>16))&0xffff)/65535 end
local function save() local spr=Sprite(W,H,ColorMode.RGBA) spr.cels[1].image:drawImage(img)
 local o=app.params.out spr:saveAs(o..NAME..".aseprite") spr:saveCopyAs(o..NAME..".png") end
local red={"#5e1620","#8e2229","#c13a2f","#e0583d","#f58a62"}
local cr={"#a89270","#c9b48c","#e6d6aa","#f3e8c4","#fbf3da"}
local gr={"#1f4a33","#2f6d3b","#4b9648","#7cbf5a","#b0de7c"}
-- ribbon bookmark (quirk)
shape(polyM{{34,76},{40,76},{40,86},{37,83},{34,86}},gr)
shape(rectM(26,14,70,78),cr)
shape(rectM(22,10,64,74),red)
for y=16,68,8 do shape(ellM(26,y,1.7,1.7),{"#6a4a10","#b8861c","#e8b030","#f6d060","#fff0a0"}) end
for y=10,74 do P(32,y,red[2]) end
shape(rectM(38,20,58,40),cr)
for y=25,35,4 do for x=42,54 do P(x,y,"#98794a") end end
for x=42,50 do P(x,38,"#98794a") end
-- pencil
local ax,ay,bx,by=84,40,56,80
local dx,dy=bx-ax,by-ay local L=math.sqrt(dx*dx+dy*dy) local ux,uy=dx/L,dy/L
local pm=mk(function(x,y) local px,py=x+0.5-ax,y+0.5-ay local t=(px*ux+py*uy)/L local s=px*(-uy)+py*ux if t<0 or t>1 then return false end local w=3.4 if t>0.78 then w=3.4*(1-t)/0.22 end return math.abs(s)<=w+0.3 end,40,30,95,90)
for k in pairs(pm) do local x,y=k%1000,k//1000 local px,py=x+0.5-ax,y+0.5-ay local t=(px*ux+py*uy)/L local s=px*(-uy)+py*ux
 local c
 if t<0.1 then c={"#a8404e","#d8607a","#f08aa0","#f8b0c0"} elseif t<0.16 then c={"#6a6a78","#9a9aa8","#c8c8d4","#e4e4ec"} elseif t<0.78 then c={"#a8700c","#d8980e","#f2b81c","#fcd84c"} elseif t<0.9 then c={"#a8744a","#c8946a","#e4b88c","#f4d4ac"} else c={"#3a3440","#3a3440","#56505c","#56505c"} end
 local i=2 if s>1.3 then i=4 elseif s>-0.5 then i=3 end if s<-2 then i=1 end
 P(x,y,c[i]) end
outline()
save()
