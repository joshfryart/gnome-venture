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
------------------------------------------------ anaconda
new()
ell(32,52,21,7,0,2.4,GR,function(i,x,y) if H(x/3,y/3)<0.16 and i<=4 then return GR[i+1] end end)
ell(32,45,16,6,0,2.4,GR,function(i,x,y) if H(x/3+9,y/3)<0.18 and i<=4 then return GR[i+1] end end)
tube({{38,42},{36,34},{30,28}},5,5,GR)
-- belly stripe on neck
tube({{29,41},{29,36},{27,31}},1.5,1.5,{"#f3ffc0","#e8f59a","#c8e47a","#8fc870","#5a9a7a"})
ell(28,22,11,8,-0.1,2.3,GR)
-- eyes high on head
ell(22,15,4,4,0,2,GR); ell(33,15,4,4,0,2,GR)
eye(20,12,4); eye(31,12,4)
-- giant grin
rect(19,24,37,24,"#2b1c26"); px(18,23,"#2b1c26"); px(38,23,"#2b1c26"); rect(20,25,36,26,"#7a2a3a"); rect(21,25,35,25,"#fff6e0")
rect(27,27,28,31,"#e8584a"); px(26,32,"#e8584a"); px(29,32,"#e8584a")
blush(19,20,3); blush(35,20,3)
-- heart
poly({{50,22},{54,19},{58,22},{54,27}},{"#ffd0e0","#ff9ab8","#e8688c","#b8487a","#6e3a7a"})
save("pl-ana-6",{32,60,22,2},{{8,12},{56,36},{8,38}})
------------------------------------------------ mangrove
new()
ell(32,57,22,4,0,2,{"#8fe0e8","#5ab8d0","#3f8aa8","#2f5a86","#2a3a66"})
rect(14,57,20,57,"#cfeaf4"); rect(40,59,47,59,"#cfeaf4")
-- stilt roots arching
local RT={"#c9a068","#9a6a45","#7a4e32","#5b3a2c","#43292a"}
tube({{32,40},{20,42},{14,57}},1.8,1.2,RT); tube({{32,40},{26,50},{24,57}},1.6,1.2,RT)
tube({{32,40},{40,50},{41,57}},1.6,1.2,RT); tube({{32,40},{44,42},{50,57}},1.8,1.2,RT)
tube({{18,48},{26,46},{34,52}},1.1,1.1,RT)
tube({{31,36},{32,44},{32,52}},3,3,RT)
tube({{32,52},{32,57}},1.6,1.6,RT)
-- canopy
ell(32,24,20,14,0,2.6,GR,function(i,x,y) if H(x/2,y/2)<0.12 and i<=4 then return GR[i+1] end end)
ell(32,12,11,8,0,2.2,GR)
poly({{26,8},{32,0},{38,8}},GR)
eye(22,22,5); eye(34,22,5); px(26,25,"#fff6e0"); blush(19,28,3); blush(41,28,3)
rect(29,30,33,30,"#2b1c26")
-- ? mark
rect(52,8,55,8,"#2b1c26") px(56,9,"#2b1c26") px(55,10,"#2b1c26") px(54,11,"#2b1c26") px(54,13,"#2b1c26")
save("pl-mgr-6",nil,{{8,10},{8,36},{56,26}})
------------------------------------------------ snow leopard
new()
ell(32,57,25,4,0,2,ST)
local SPOT=function(i,x,y) if H(x/2,y/2)<0.12 and i>=2 and i<=4 then return WH[i+2>5 and 5 or i+2] end end
ell(34,45,20,12,0,2.4,WH,SPOT)
-- head
ell(21,38,11,9,0,2.2,WH,SPOT)
poly({{12,32},{13,24},{19,30}},WH); poly({{24,29},{29,23},{29,32}},WH)
rect(14,28,15,29,"#e8a8b8"); rect(26,28,27,29,"#e8a8b8")
sleepy(14,38,5); sleepy(24,38,5); px(20,42,"#e8688c"); px(21,42,"#e8688c"); rect(19,41,22,41,"#ffd0e0"); blush(11,42,2); blush(28,42,2)
-- fluffy tail wrapping the front
tube({{50,48},{46,56},{30,56},{16,52}},5,4,WH,function(i,x,y) if (x%5==0) and i>=2 and i<=4 then return WH[4] end end)
-- rosettes
for _,p in ipairs{{40,40},{46,44},{36,46},{30,41}} do rect(p[1],p[2],p[1]+2,p[2]+1,"#6f6f9a"); px(p[1]+1,p[2],"#c8d0e2") end
-- zz
rect(8,16,10,16,"#fff0d0"); px(10,17,"#fff0d0"); rect(8,18,10,18,"#fff0d0")
save("pl-sll-6",{32,61,22,1},{{54,26},{8,50},{52,12}})
------------------------------------------------ baobab
new()
-- branches + tufts
tube({{32,26},{22,18},{16,12}},1.8,1.2,BR); tube({{32,24},{32,16},{32,8}},1.8,1.2,BR); tube({{32,26},{42,18},{48,12}},1.8,1.2,BR)
ell(16,10,6,4,0,2,GR); ell(32,6,6,4,0,2,GR); ell(48,10,6,4,0,2,GR)
-- trunk bottle
poly({{24,26},{40,26},{42,34},{47,46},{50,57},{14,57},{17,46},{22,34}},BR,function(i,x,y) if (x+y*0)%6==2 and y>30 and i>=2 and i<=4 then return BR[i+1] end end)
-- glowing arched door
poly({{26,57},{26,49},{29,45},{35,45},{38,49},{38,57}},{"#fffbe8","#ffe98a","#ffc94a","#e8963a","#a8523a"})
rect(31,46,32,56,"#fff0a0"); rect(26,56,38,57,"#e8963a")
-- face
eye(24,30,5); eye(34,30,5); blush(22,36,3); blush(39,36,3); rect(30,37,33,37,"#2b1c26"); rect(31,38,32,38,"#7a2a3a")
-- sign
rect(44,38,50,41,"#e0b878"); rect(44,41,50,41,"#9a6a45"); px(46,39,"#7a4e32") px(48,39,"#7a4e32")
save("pl-baob-6",{32,60,19,2},{{8,30},{56,24},{8,52}})
------------------------------------------------ noodle skipper
new()
-- boat hull
poly({{8,44},{56,44},{50,54},{14,54}},WD)
rect(12,47,52,48,"#5a90d8"); rect(12,47,52,47,"#8fc0f0"); rect(14,48,50,48,"#4a62b0")
rect(18,55,46,56,"#4a3040")
-- body
ell(32,42,11,6,0,2,{"#8fd0a0","#5fae8a","#3a8a7a","#2f6a7a","#2a4a6a"})
-- face + beard
ell(32,34,9,7,0,2,{"#ffe0c0","#ffd0a8","#f0b088","#c88a70","#8a5a6a"})
eye(25,32,4); eye(34,32,4); rect(31,35,32,36,"#e8688c"); blush(24,36,2); blush(38,36,2)
ell(32,41,8,5,0,2,WH)
-- straw hat
poly({{32,5},{54,29},{10,29}},{"#fff0a0","#ffe08a","#e8c060","#c09040","#7a5a3a"},function(i,x,y) if (x+y)%3==0 and i>=2 and i<=4 then return YE[i+1] and "#a87a40" end end)
rect(10,29,54,30,"#a87a40"); rect(10,29,54,29,"#e8c060"); rect(12,30,52,30,"#7a5a3a")
-- bowl with noodles and chopsticks
ell(49,43,6,4,0,2,CR)
rect(45,40,53,41,"#ffe08a"); rect(46,40,52,40,"#fff0a0"); px(48,41,"#c09040") px(51,41,"#c09040")
line(50,40,56,30,"#c9a068"); line(52,40,58,32,"#9a6a45")
rect(44,45,54,45,"#5a90d8")
-- steam
px(46,36,"#fff0d0"); px(47,34,"#fff0d0"); px(46,32,"#fff0d0")
save("pl-flmk-6",{32,60,22,2},{{6,12},{56,10},{6,52}})
