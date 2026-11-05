-- felt-light (ui P3_U6)
local NAME="felt-light" local W,H=32,32
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
local c={"#cfc5ab","#e9e2d0","#f6f1e3"}
for y=0,31 do for x=0,31 do
 local d=(x+y)%4 local i=2
 if d==3 then i=1 elseif d==0 then i=3 end
 if ((x//4+y//4)%2==1) and i==3 then i=2 end
 local h=hash(x,y,7) if h>0.965 then i=3 elseif h<0.03 then i=1 end
 P(x,y,c[i]) end end
save()
