-- riddle (ui P3_U6)
local NAME="riddle" local W,H=96,96
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
local g={"#17402c","#256a3a","#3f9a47","#6ec15a","#a7e07a"}
local ax,ay,bx,by=22,76,76,20
local dx,dy=bx-ax,by-ay local L=math.sqrt(dx*dx+dy*dy) local ux,uy=dx/L,dy/L
local function tp(x,y) local t=((x-ax)*ux+(y-ay)*uy)/L local s=(x-ax)*(-uy)+(y-ay)*ux return t,s end
local m=mk(function(x,y) local t,s=tp(x+0.5,y+0.5) if t<0 or t>1 then return false end local w=math.sin(math.pi*t)^0.75*22 return math.abs(s)<=w end,10,8,90,90)
shape(m,g,{fn=function(x,y,i) local t,s=tp(x+0.5,y+0.5) if math.abs(s)<1 and t>0.05 and t<0.93 then return 2 end
  if i==3 and math.abs(s)>6 and ((math.floor(t*14)%2==0) and math.abs(math.abs(s)-6-(t*14%2)*3)<0.8) then return 2 end end})
-- stitched edge dots
for t=0.12,0.9,0.07 do local w=math.sin(math.pi*t)^0.75*22-3 for _,sg in ipairs{-1,1} do local x=ax+ux*L*t-uy*w*sg local y=ay+uy*L*t+ux*w*sg P(math.floor(x+0.5),math.floor(y+0.5),g[5]) end end
local q={".XXXX.","XX..XX","XX..XX","....XX","...XX.","..XX..","..XX..","......","..XX..","..XX.."}
bitmap(q,39,30,3,"#1f5a38") bitmap(q,38,29,3,"#f4ecd0")
-- stem curl tip
line(22,76,17,82,"#6e4128") line(17,82,13,83,"#6e4128") P(12,82,"#6e4128") P(22,77,"#6e4128") P(18,81,"#935a33")
-- quirk: dewdrop
shape(ellM(62,60,3,3.5),{"#3a6a9a","#5a9ac8","#8ac8e8","#b8e8f8","#e8f8ff"})
outline()
save()
