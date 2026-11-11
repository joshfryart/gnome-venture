local out = app.params.out or "./"
local INK = Color{r=0x2b,g=0x1c,b=0x26}
local function hex(h) h=h:gsub("#","") return Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16)} end
local img
local SH=function(y) return 0 end
local CL=nil
local function px(x,y,c) x=x+SH(y) if x>=0 and y>=0 and x<64 and y<64 and (not CL or CL(x,y)) then img:putPixel(x,y,type(c)=="string" and hex(c) or c) end end
local function rect(x0,y0,x1,y1,c) for y=y0,y1 do for x=x0,x1 do px(x,y,c) end end end
local function H(x,y) return (math.sin(x*12.9898+y*78.233)*43758.5453)%1 end
local M={}
local function inM(x,y,k) k=k or 0 return M[(y)..","..(x)] and M[y..","..(x-k)] and M[y..","..(x+k)] and M[(y-k)..","..x] and M[(y+k)..","..x] end
local function tone(l) return l>0.5 and 1 or (l>0.1 and 2 or (l>-0.35 and 3 or (l>-0.75 and 4 or 5))) end
-- squircle body, ramp = hl,lit,mid,shade,deep ; tex(i,x,y)->colour|nil
local function sblob(cx,cy,rx,ry,pw,r,tex)
  M={}
  for y=math.floor(cy-ry),math.ceil(cy+ry) do for x=math.floor(cx-rx),math.ceil(cx+rx) do
    local dx,dy=(x-cx+0.5)/rx,(y-cy+0.5)/ry
    local d=(math.abs(dx)^pw+math.abs(dy)^pw)^(1/pw)
    if d<=1 then
      M[y..","..x]=true
      local i=tone(-0.55*dx-0.75*dy-0.55*d*d*d)
      px(x,y,(tex and tex(i,x,y)) or r[i]) end end end
end
-- arbitrary mask: inside(x,y); lit about centre (cx,cy,rx,ry)
local function blobf(inside,cx,cy,rx,ry,r,tex)
  M={}
  for y=math.floor(cy-ry),math.ceil(cy+ry) do for x=math.floor(cx-rx),math.ceil(cx+rx) do
    if inside(x+0.5,y+0.5) then
      local dx,dy=(x-cx+0.5)/rx,(y-cy+0.5)/ry; local d=math.min(1,math.sqrt(dx*dx+dy*dy))
      M[y..","..x]=true
      local i=tone(-0.55*dx-0.75*dy-0.55*d*d*d)
      px(x,y,(tex and tex(i,x,y)) or r[i]) end end end
end
-- convex/any polygon, shaded by position along light axis
local function poly(pts,r,tex)
  M={}
  local x0,y0,x1,y1=99,99,-1,-1
  for _,p in ipairs(pts) do x0=math.min(x0,p[1]) y0=math.min(y0,p[2]) x1=math.max(x1,p[1]) y1=math.max(y1,p[2]) end
  local dmin,dmax=1e9,-1e9
  for _,p in ipairs(pts) do local d=p[1]*0.6+p[2]*0.8 dmin=math.min(dmin,d) dmax=math.max(dmax,d) end
  for y=math.floor(y0),math.ceil(y1) do for x=math.floor(x0),math.ceil(x1) do
    local X,Y=x+0.5,y+0.5
    local ins=false; local n=#pts; local j=n
    for i=1,n do local a,b=pts[i],pts[j]
      if (a[2]>Y)~=(b[2]>Y) and X<(b[1]-a[1])*(Y-a[2])/(b[2]-a[2])+a[1] then ins=not ins end j=i end
    if ins then
      M[y..","..x]=true
      local t=(X*0.6+Y*0.8-dmin)/math.max(1,dmax-dmin)
      local i= t<0.18 and 1 or (t<0.42 and 2 or (t<0.66 and 3 or (t<0.86 and 4 or 5)))
      px(x,y,(tex and tex(i,x,y)) or r[i]) end end end
end
local function box(x0,y0,x1,y1,r) poly({{x0,y0},{x1+1,y0},{x1+1,y1+1},{x0,y1+1}},r) end
local function line(x0,y0,x1,y1,c,w)
  w=w or 1; local n=math.max(math.abs(x1-x0),math.abs(y1-y0),1)
  for i=0,n do local x=math.floor(x0+(x1-x0)*i/n+0.5) local y=math.floor(y0+(y1-y0)*i/n+0.5)
    for a=0,w-1 do for b=0,w-1 do px(x+a,y+b,c) end end end
end
local function outline()
  local o=Image(64,64)
  for y=0,63 do for x=0,63 do
    if img:getPixel(x,y)&0xff000000==0 then
      for _,d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do
        local a,b=x+d[1],y+d[2]
        if a>=0 and b>=0 and a<64 and b<64 and img:getPixel(a,b)&0xff000000~=0 then o:putPixel(x,y,INK) break end end end end end
  for y=0,63 do for x=0,63 do if o:getPixel(x,y)&0xff000000~=0 then img:putPixel(x,y,INK) end end end
end
local function shadow(cx,cy,rx,ry)
  for y=cy-ry,cy+ry do for x=cx-rx,cx+rx do
    local dx,dy=(x-cx)/rx,(y-cy)/ry; local d=dx*dx+dy*dy
    if d<=1 and x>=0 and x<64 and y<64 and img:getPixel(x,y)&0xff000000==0 then img:putPixel(x,y,hex(d<0.45 and "#4a3a68" or "#6e5e8e")) end end end
end
local function eye(x,y,w,h)
  h=h or 5
  rect(x,y,x+w-1,y+h-1,"#2b1c26")
  if w>=4 then rect(x+1,y+1,x+2,y+2,"#fff6e0"); px(x+w-2,y+h-2,"#d8c8f0"); px(x+1,y+h-1,"#6a4a7a")
  else px(x+1,y+1,"#fff6e0"); px(x,y+h-1,"#6a4a7a") end
end
local function sparkle(x,y) for _,d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do px(x+d[1],y+d[2],"#ffe98a") end px(x,y,"#fffbe8") end
local function new() img=Image(64,64) SH=function() return 0 end CL=nil M={} end
local function save(name,sh,sp)
  SH=function() return 0 end CL=nil
  outline() if sh then shadow(sh[1],sh[2],sh[3],sh[4]) end
  sp=sp or {{7,10},{57,8},{58,52}}
  for _,p in ipairs(sp) do sparkle(p[1],p[2]) end
  local s=Sprite(64,64); s.cels[1].image:drawImage(img)
  s:saveCopyAs(out..name..".png"); s:close()
end
local function pal(name,sh,sp,fn) new() local ok,e=pcall(fn) if not ok then print("ERR "..name..": "..tostring(e)) end save(name,sh,sp) end
-- ramps
local R={
 wood={"#d9a066","#b87a45","#8f5a38","#6b4030","#4a2f45"},
 cream={"#fffaf0","#f6ecd8","#dcccc4","#b4a4c0","#7a6a98"},
 green={"#b4e873","#8fd05a","#5fae4a","#3a8a52","#35507a"},
 yellow={"#fff0a0","#ffd966","#e8b040","#b8803a","#7a5a7a"},
 red={"#ff9a80","#e8523f","#c0332f","#8a2a40","#55284f"},
 blue={"#bfe8ff","#7ac0ea","#4a8ad0","#3a5aa8","#35306e"},
 pink={"#ffc8dc","#ff9ab8","#e8688f","#b04880","#6a3a7a"},
 orange={"#ffc870","#ffa040","#e87a2a","#b8503a","#6a3a55"},
 grey={"#e4e8f0","#c0c8d8","#9aa4be","#707a9c","#4a4a72"},
 brown={"#c9a068","#9a6a45","#7a4e32","#5b3a2c","#43292a"},
 dark={"#7a8098","#58607e","#40466a","#2f3258","#242246"},
 teal={"#a8f0e0","#5ccfc0","#3aa8a8","#2a7a90","#2a4a7a"},
 purple={"#d8a8ff","#a878e8","#7e54c0","#5a3a98","#3a2a6a"},
 black={"#6a6088","#4a4268","#3a3256","#2e2648","#261c3c"},
 skin={"#ffe0c0","#f8c8a0","#e0a070","#b87a60","#7a5070"},
}
