local out = app.params.out or "./"
local INK = Color{r=0x2b,g=0x1c,b=0x26}
local function hex(h) h=h:gsub("#","") return Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16)} end
local img
local function px(x,y,c) x=math.floor(x) y=math.floor(y) if x>=0 and y>=0 and x<64 and y<64 then img:putPixel(x,y,type(c)=="string" and hex(c) or c) end end
local function rect(x0,y0,x1,y1,c) for y=y0,y1 do for x=x0,x1 do px(x,y,c) end end end
local function H(x,y) return (math.sin(x*12.9898+y*78.233)*43758.5453)%1 end
local function K(x,y) return (y+100)*512+(x+100) end
local function mset(m,x,y) m[K(x,y)]={x,y} end
local function mEll(cx,cy,rx,ry) local m={} for y=math.floor(cy-ry-1),math.ceil(cy+ry+1) do for x=math.floor(cx-rx-1),math.ceil(cx+rx+1) do local dx,dy=(x+.5-cx)/rx,(y+.5-cy)/ry if dx*dx+dy*dy<=1 then mset(m,x,y) end end end return m end
local function mRect(x0,y0,x1,y1) local m={} for y=y0,y1 do for x=x0,x1 do mset(m,x,y) end end return m end
local function mPoly(p) local m={} local y0,y1=1e9,-1e9 for _,q in ipairs(p) do y0=math.min(y0,q[2]) y1=math.max(y1,q[2]) end
  for y=math.floor(y0),math.ceil(y1) do for x=0,63 do local inside=false local n=#p local j=n
    for i=1,n do local xi,yi,xj,yj=p[i][1],p[i][2],p[j][1],p[j][2]
      if ((yi>y+.5)~=(yj>y+.5)) and (x+.5<(xj-xi)*(y+.5-yi)/(yj-yi)+xi) then inside=not inside end j=i end
    if inside then mset(m,x,y) end end end return m end
local function mLine(x0,y0,x1,y1,w0,w1) w1=w1 or w0 local m={} local n=math.max(math.abs(x1-x0),math.abs(y1-y0))*2+1
  for i=0,n do local t=i/n local x,y,w=x0+(x1-x0)*t,y0+(y1-y0)*t,w0+(w1-w0)*t
    for yy=math.floor(y-w/2-1),math.ceil(y+w/2+1) do for xx=math.floor(x-w/2-1),math.ceil(x+w/2+1) do
      if (xx+.5-x)^2+(yy+.5-y)^2<=(w/2)^2+0.25 then mset(m,xx,yy) end end end end return m end
local function mAdd(...) local m={} for _,a in ipairs{...} do for k,v in pairs(a) do m[k]=v end end return m end
local function mSub(a,b) local m={} for k,v in pairs(a) do if not b[k] then m[k]=v end end return m end
local function mInt(a,b) local m={} for k,v in pairs(a) do if b[k] then m[k]=v end end return m end
local function has(m,x,y) return m[K(x,y)]~=nil end
-- shaded fill: ramp = hl,lit,mid,shade,deep ; tex(i,x,y)->colour|nil
local function paint(m,r,tex)
  local x0,y0,x1,y1=1e9,1e9,-1e9,-1e9
  for _,p in pairs(m) do x0=math.min(x0,p[1]) y0=math.min(y0,p[2]) x1=math.max(x1,p[1]) y1=math.max(y1,p[2]) end
  local cx,cy,rx,ry=(x0+x1+1)/2,(y0+y1+1)/2,(x1-x0+1)/2,(y1-y0+1)/2
  for _,p in pairs(m) do local x,y=p[1],p[2]
    local dx,dy=(x+.5-cx)/rx,(y+.5-cy)/ry
    local l=-0.5*dx-0.65*dy-0.45*(dx*dx+dy*dy)+0.1
    if not has(m,x,y-1) or not has(m,x-1,y) then l=l+0.28 end
    if not has(m,x+1,y) or not has(m,x,y+1) then l=l-0.4 end
    local i= l>0.45 and 1 or (l>0.12 and 2 or (l>-0.25 and 3 or (l>-0.6 and 4 or 5)))
    local c=(tex and tex(i,x,y)) or r[i]
    px(x,y,c) end
end
local function flat(m,c) for _,p in pairs(m) do px(p[1],p[2],c) end end
local function blob(cx,cy,rx,ry,r,tex) local m=mEll(cx,cy,rx,ry) paint(m,r,tex) return m end
local function eye(x,y,w) rect(x,y,x+w-1,y+4,"#2b1c26"); rect(x+1,y+1,x+2,y+2,"#fff6e0"); px(x+w-2,y+3,"#d8c8f0"); px(x+1,y+4,"#6a4a7a") end
local function eyeS(x,y) rect(x,y,x+2,y+3,"#2b1c26"); px(x,y,"#fff6e0"); px(x+1,y,"#fff6e0"); px(x+2,y+2,"#d8c8f0") end
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
local function sparkle(x,y) for _,d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do px(x+d[1],y+d[2],"#ffe98a") end px(x,y,"#fffbe8") end
local function sparkles(a) for _,p in ipairs(a) do sparkle(p[1],p[2]) end end
local function save(name,sh,sp)
  outline() if sh then shadow(sh[1],sh[2],sh[3],sh[4]) end
  if sp then sparkles(sp) end
  local s=Sprite(64,64); s.cels[1].image:drawImage(img)
  s:saveCopyAs(out..name..".png")
end
local function new() img=Image(64,64) end
local function mir(p) local q={} for i,v in ipairs(p) do q[i]={63-v[1],v[2]} end return q end
local R={
 GOLD={"#fff2a8","#ffd866","#e8a83a","#b8783c","#7a5078"},
 CREAM={"#fffbe8","#f6ecd8","#dcd0d8","#b0a4c8","#7c72a8"},
 RED={"#ff9a80","#ee5a48","#c8383a","#923050","#5e2a58"},
 BROWN={"#d8a070","#b07848","#8a5a3a","#6a4440","#46304a"},
 ORANGE={"#ffd08a","#ffa04a","#ee7a2e","#b8503e","#7a3a5a"},
 GREY={"#e8e4ee","#c4c0d4","#9a98b8","#74729a","#524e80"},
 GREEN={"#d0f08a","#9ad852","#5ea84a","#3a7a50","#2e4e6a"},
 YEL={"#fffbb0","#ffec6a","#f2c92e","#c89a30","#8a6a5a"},
 BLUE={"#c8ecff","#8cc8f0","#5a9ad8","#4670b0","#3c4a88"},
 DARK={"#8a84b0","#625c8c","#463e6e","#342c58","#2e2048"},
 PINK={"#ffd0dc","#ff9ab8","#e8648c","#b04478","#6e3a6a"},
 WINE={"#d8607a","#b0384e","#8a2a48","#66264a","#46204a"},
 TAN={"#f6dcaa","#e4bc82","#c4966a","#9a6c50","#684a60"},
 SKIN={"#e8b088","#c88a5a","#a46a46","#7e4a48","#54344c"},
 WOOD={"#d8a468","#b88048","#94603c","#704438","#4a304a"},
}
