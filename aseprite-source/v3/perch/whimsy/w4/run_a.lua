local out = app.params.out or "./"
local INK = Color{r=0x2b,g=0x1c,b=0x26}
local floor,ceil,sqrt,abs,cos,sin,max,min=math.floor,math.ceil,math.sqrt,math.abs,math.cos,math.sin,math.max,math.min
local function hex(h) h=h:gsub("#","") return Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16)} end
local img
local function px(x,y,c) x=floor(x) y=floor(y) if x>=0 and y>=0 and x<64 and y<64 then img:putPixel(x,y,type(c)=="string" and hex(c) or c) end end
local function rect(x0,y0,x1,y1,c) for y=y0,y1 do for x=x0,x1 do px(x,y,c) end end end
local function H(x,y) return (math.sin(x*12.9898+y*78.233)*43758.5453)%1 end
local M={}
local function inM(x,y,k) k=k or 0 return M[y..","..x] and M[y..","..(x-k)] and M[y..","..(x+k)] and M[(y-k)..","..x] and M[(y+k)..","..x] end
local function lv(l) return l>0.5 and 1 or (l>0.1 and 2 or (l>-0.35 and 3 or (l>-0.75 and 4 or 5))) end
-- rotated superellipse, lit upper-left; r={hl,lit,mid,shade,deep}; tex(i,x,y)->colour|nil
local function ell(cx,cy,rx,ry,ang,pw,r,tex)
  M={} ang=ang or 0 pw=pw or 2
  local ca,sa=cos(ang),sin(ang); local R=max(rx,ry)+1; local B=R+2
  for y=floor(cy-B),ceil(cy+B) do for x=floor(cx-B),ceil(cx+B) do
    local dx,dy=x-cx+0.5,y-cy+0.5
    local u=(dx*ca+dy*sa)/rx; local v=(-dx*sa+dy*ca)/ry
    local d=(abs(u)^pw+abs(v)^pw)^(1/pw)
    if d<=1 then M[y..","..x]=true
      local l=-0.55*dx/R*1.1-0.75*dy/R*1.1-0.55*d*d*d
      local i=lv(l); px(x,y,(tex and tex(i,x,y)) or r[i]) end end end
end
local function poly(pts,r,tex)
  M={}; local x0,y0,x1,y1=99,99,-9,-9
  for _,p in ipairs(pts) do x0=min(x0,p[1]) y0=min(y0,p[2]) x1=max(x1,p[1]) y1=max(y1,p[2]) end
  local cx,cy=(x0+x1)/2,(y0+y1)/2; local R=max(x1-x0,y1-y0)/2
  local function inside(x,y) local c=false local n=#pts local j=n
    for i=1,n do local a,b=pts[i],pts[j]
      if ((a[2]>y)~=(b[2]>y)) and (x<(b[1]-a[1])*(y-a[2])/(b[2]-a[2])+a[1]) then c=not c end j=i end return c end
  local S={}
  for y=floor(y0),ceil(y1) do for x=floor(x0),ceil(x1) do if inside(x+0.5,y+0.5) then S[y..","..x]=true end end end
  for k,_ in pairs(S) do local y,x=k:match("(%-?%d+),(%-?%d+)") x=tonumber(x) y=tonumber(y)
    M[k]=true
    local l=-0.55*(x-cx)/R-0.7*(y-cy)/R
    if not S[(y+1)..","..(x+1)] then l=l-0.45 end
    if not S[y..","..(x+1)] then l=l-0.25 end
    if not S[(y-1)..","..(x-1)] or not S[y..","..(x-1)] then l=l+0.3 end
    l=l+0.2
    local i=lv(l); px(x,y,(tex and tex(i,x,y)) or r[i]) end
end
-- tube along polyline pts {{x,y},..} radius w0->w1
local function tube(pts,w0,w1,r,tex)
  M={}; local sm={}; local tot=0
  for i=1,#pts-1 do tot=tot+sqrt((pts[i+1][1]-pts[i][1])^2+(pts[i+1][2]-pts[i][2])^2) end
  local acc=0
  for i=1,#pts-1 do local a,b=pts[i],pts[i+1]; local L=sqrt((b[1]-a[1])^2+(b[2]-a[2])^2); local n=max(1,ceil(L*3))
    for k=0,n do local t=k/n; local ta=(acc+t*L)/tot
      sm[#sm+1]={a[1]+(b[1]-a[1])*t,a[2]+(b[2]-a[2])*t,w0+(w1-w0)*ta} end acc=acc+L end
  local x0,y0,x1,y1=99,99,-9,-9
  for _,s in ipairs(sm) do x0=min(x0,s[1]-s[3]) y0=min(y0,s[2]-s[3]) x1=max(x1,s[1]+s[3]) y1=max(y1,s[2]+s[3]) end
  for y=floor(y0)-1,ceil(y1)+1 do for x=floor(x0)-1,ceil(x1)+1 do
    local best,bs=9,nil
    for _,s in ipairs(sm) do local d=sqrt((x+0.5-s[1])^2+(y+0.5-s[2])^2)/s[3] if d<best then best,bs=d,s end end
    if best<=1 then M[y..","..x]=true
      local l=-0.55*(x+0.5-bs[1])/bs[3]-0.75*(y+0.5-bs[2])/bs[3]-0.55*best^3
      local i=lv(l*0.9); px(x,y,(tex and tex(i,x,y)) or r[i]) end end end
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
local function eye(x,y,w) rect(x,y,x+w-1,y+4,"#2b1c26"); rect(x+1,y+1,x+2,y+2,"#fff6e0"); px(x+w-2,y+3,"#d8c8f0"); px(x+1,y+4,"#6a4a7a") end
local function sleepy(x,y,w) px(x,y,"#2b1c26"); rect(x+1,y+1,x+w-2,y+1,"#2b1c26"); px(x+w-1,y,"#2b1c26") end
local function happy(x,y,w) px(x,y+1,"#2b1c26"); rect(x+1,y,x+w-2,y,"#2b1c26"); px(x+w-1,y+1,"#2b1c26") end
local function blush(x,y,w) rect(x,y,x+(w or 2)-1,y,"#ff8aa8") end
local function line(x0,y0,x1,y1,c) local n=max(abs(x1-x0),abs(y1-y0)) for i=0,n do local t=n==0 and 0 or i/n px(floor(x0+(x1-x0)*t+0.5),floor(y0+(y1-y0)*t+0.5),c) end end
local function sparkle(x,y) for _,d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do px(x+d[1],y+d[2],"#ffe98a") end px(x,y,"#fffbe8") end
local function new() img=Image(64,64) end
local function save(name,sh,sp)
  outline() if sh then shadow(sh[1],sh[2],sh[3],sh[4]) end
  for _,p in ipairs(sp or {}) do sparkle(p[1],p[2]) end
  local s=Sprite(64,64); s.cels[1].image:drawImage(img)
  s:saveCopyAs(out..name..".png")
end
local GR={"#c8f08a","#8fd05a","#5fae4a","#3a8a52","#35507a"}
local TL={"#a8f0d0","#6fd0b0","#3fa896","#2f7a86","#35507a"}
local OR={"#fff0a0","#ffc15a","#ff8a3a","#d8503a","#7a2a5a"}
local YE={"#fffbe8","#ffe98a","#ffc94a","#e8963a","#a8523a"}
local BR={"#d8a878","#b07a50","#8a5a3a","#5b3a2c","#43292a"}
local WH={"#fbfcff","#e6ecf4","#c8d0e2","#9ba3c4","#6f6f9a"}
local PK={"#ffd0e0","#ff9ab8","#e8688c","#b8487a","#6e3a7a"}
local BL={"#cfe8ff","#8fc0f0","#5a90d8","#4a62b0","#3a3a7a"}
local RD={"#ff9a70","#e8584a","#c0383f","#8a2a4a","#5a2a4a"}
local CR={"#fffbe8","#fff0d0","#f0d8b0","#c8a890","#8a6a84"}
local NV={"#7a9ae8","#4a6ac0","#3a4a98","#2c3470","#241f4a"}
local WD={"#e0b878","#c9a068","#9a6a45","#7a4e32","#4a3040"}
local PU={"#e0c8ff","#b898e8","#8a6ac0","#6a4a98","#46306e"}
local ST={"#d8d4e0","#b8b4c8","#9890ac","#74708c","#544e6c"}
local DK={"#4a6a5a","#2f4a48","#26373e","#212a36","#1c1c2c"}
------------------------------------------------ frog
new()
-- leaf umbrella stalk + leaf (behind)
tube({{40,40},{44,26},{47,18}},1.2,1.2,WD)
ell(48,14,10,5,-0.45,2,GR,function(i,x,y) if M[y..","..x] and abs((x-48)*0.45+(y-14))<0.6 then return "#2f7a46" end end)
-- legs
ell(16,55,6,3,0,2,GR); ell(47,55,6,3,0,2,GR)
ell(31,46,17,11,0,2.5,GR,function(i,x,y) if H(x,y)<0.07 and i<=3 then return GR[i+1] end end)
ell(31,51,10,6,0,2.2,{"#f3ffc0","#d8f59a","#b8e47a","#8fc870","#5a9a7a"})
ell(21,56,5,3,0,2,GR); ell(42,56,5,3,0,2,GR)
-- glowing spots
for _,p in ipairs{{20,42},{26,39},{36,40},{42,43},{31,36},{24,47},{39,47}} do rect(p[1],p[2],p[1]+1,p[2]+1,"#a8f8f0"); px(p[1],p[2],"#fffbe8") end
-- head bumps and eyes
ell(23,31,6,6,0,2,GR); ell(40,31,6,6,0,2,GR)
eye(20,28,5); eye(38,28,5)
-- mouth
rect(26,41,36,41,"#2b1c26"); px(25,40,"#2b1c26"); px(37,40,"#2b1c26"); rect(28,42,34,42,"#e8688c")
blush(22,38,3); blush(39,38,3)
-- music note
rect(8,20,9,24,"#ffe98a") px(10,19,"#ffe98a") rect(6,23,8,25,"#ffc94a")
save("rr-glimmer-frog",{32,60,18,2},{{8,8},{56,34},{6,44}})
------------------------------------------------ parrot
new()
-- pennant pole + flag
rect(49,16,50,58,"#9a6a45"); rect(49,16,49,58,"#c9a068"); rect(50,16,50,58,"#7a4e32")
poly({{50,10},{62,14},{50,22}},RD)
rect(50,15,60,15,"#ffe98a")
-- tail
tube({{32,48},{36,56},{38,60}},4,2.5,{"#ff9a70","#e8584a","#c0383f","#8a2a4a","#5a2a4a"})
-- feet
rect(26,57,29,59,"#e89a3a"); rect(34,57,37,59,"#e89a3a")
ell(31,40,13,17,0,2.4,GR)
ell(31,45,8,11,0,2.2,{"#e8ffc0","#c8f08a","#a8dc72","#7fc455","#4e9a58"})
-- wing (blue-green), holds pole
ell(40,43,6,12,-0.15,2,TL,function(i,x,y) if M[y..","..x] and (y%3==0) and i>=2 then return TL[i+1] or TL[5] end end)
ell(46,36,4,3,0,2,TL)
-- head
ell(29,24,11,10,0,2.2,GR)
rect(22,13,35,14,"#ff7a5a") ell(30,13,6,3,0,2,RD)
eye(22,20,5); eye(31,20,5)
-- beak
ell(27,29,5,4,0,2,{"#e8e0f0","#b8b0c8","#8a8098","#5a5070","#3a2f4a"})
px(25,30,"#2b1c26")
-- loud open mouth
rect(25,33,29,34,"#7a2a3a")
sparkle(8,12); 
save("gc-parrot-pennant",{31,60,18,2},{{8,12},{14,36},{58,32}})
------------------------------------------------ turtle
new()
-- flippers
ell(14,38,7,3.5,-0.5,2,TL); ell(50,38,7,3.5,0.5,2,TL)
ell(21,54,6,3.5,0.4,2,TL); ell(43,54,6,3.5,-0.4,2,TL)
tube({{32,50},{32,56},{33,59}},3,1,TL)
-- shell
ell(32,41,16,12,0,2.4,{"#d8a878","#b07a50","#8a5a3a","#5b3a2c","#43292a"},function(i,x,y)
  local dx,dy=x-32,y-41
  if (abs(dx)==9 and abs(dy)<8) or (abs(dy)==3 and abs(dx)<9) or (abs(dy)==8 and abs(dx)<12 and abs(dx)>4) then return "#43292a" end
  if H(x,y)<0.06 then return "#b8d898" end end)
-- moss + barnacle
for _,p in ipairs{{22,46},{23,47},{22,48},{40,36},{41,37}} do px(p[1],p[2],"#8fd05a") end
px(41,47,"#fff0d0") px(42,47,"#fff0d0") px(42,46,"#c8a890")
-- head and scarf
ell(32,25,8,7,0,2,TL)
rect(24,31,40,33,"#e8688c"); rect(24,31,40,31,"#ff9ab8"); rect(24,33,40,33,"#b8487a"); rect(38,34,40,37,"#e8688c"); rect(38,37,40,37,"#b8487a")
eye(25,22,5); happy(35,24,5); blush(24,28,3); blush(38,28,3)
rect(30,29,33,29,"#2b1c26")
save("cs-keel-drift",{32,60,19,2},{{8,18},{56,22},{54,52}})
------------------------------------------------ flame
new()
-- dragon wings
poly({{16,40},{4,30},{8,46},{16,48}},PU); poly({{48,40},{60,30},{56,46},{48,48}},PU)
-- ember base
ell(32,56,16,3,0,2,{"#7a4e32","#5b3a2c","#43292a","#3a2430","#2b1c26"})
-- outer flame
ell(32,44,15,13,0,2.2,OR)
poly({{19,36},{22,22},{28,32}},OR); poly({{45,36},{43,20},{36,32}},OR)
poly({{24,34},{32,4},{40,34}},OR)
ell(32,48,9,8,0,2.2,YE)
poly({{27,40},{32,22},{37,40}},YE)
-- horns
poly({{22,24},{20,18},{26,22}},{"#fffbe8","#f0d8b0","#e0c8a0","#c8a890","#8a6a84"})
-- sleeping face
sleepy(25,44,5); sleepy(34,44,5); blush(23,48,3); blush(38,48,3)
rect(31,49,33,49,"#7a2a3a")
-- zz
rect(46,10,48,10,"#fff0d0"); px(48,11,"#fff0d0"); rect(46,12,48,12,"#fff0d0")
save("pl-cwy-6",{32,60,17,2},{{10,12},{54,50},{8,56}})
------------------------------------------------ box jelly
new()
-- tentacles
for k,x in ipairs{22,29,36,43} do
  for y=42,58 do local wx=x+((floor((y+k*2)/3)%2==0) and 0 or 1)
    rect(wx,y,wx+1,y,(y>50) and "#a898e0" or "#8a6ac0"); px(wx,y,"#d8c8ff") end end
-- cube faces
poly({{18,18},{25,11},{50,11},{43,18}},BL)
poly({{43,18},{50,11},{50,36},{43,43}},{"#8fc0f0","#5a90d8","#4a62b0","#3a3a7a","#2f2f6a"})
poly({{18,18},{43,18},{43,43},{18,43}},BL,function(i,x,y) if i==1 and (x+y)%5==0 then return "#fbfcff" end end)
rect(20,20,22,20,"#fbfcff") rect(20,21,20,24,"#fbfcff")
-- crown
poly({{27,11},{27,4},{31,8},{35,3},{39,8},{43,4},{43,11}},YE)
rect(27,10,43,11,"#e8963a"); px(35,5,"#fff6e0"); px(27,6,"#e8688c"); px(43,6,"#5a90d8")
-- face
eye(24,26,4); eye(35,26,4); blush(22,32,3); blush(38,32,3); rect(30,33,33,33,"#2b1c26"); px(29,32,"#2b1c26"); px(34,32,"#2b1c26")
save("pl-bjq-6",{32,60,15,2},{{8,20},{56,48},{10,52}})
