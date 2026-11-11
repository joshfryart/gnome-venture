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
------------------------------------------------ towel bear
new()
ell(22,57,5,3,0,2,BR); ell(42,57,5,3,0,2,BR)
-- steam
for _,p in ipairs{{8,12,3},{12,6,2},{52,8,3},{56,14,2}} do ell(p[1],p[2],p[3],p[3]-0.5,0,2,{"#fbfcff","#eef0fa","#d8dcf0","#c0c4e0","#a8a8d0"}) end
ell(32,44,15,13,0,2.2,BR)
ell(32,26,13,11,0,2.2,BR)
ell(20,16,4.5,4.5,0,2,BR); ell(44,16,4.5,4.5,0,2,BR)
ell(20,16,2,2,0,2,{"#f0c8a8","#e0a888","#c88a70","#a86a60","#8a4a50"}); ell(44,16,2,2,0,2,{"#f0c8a8","#e0a888","#c88a70","#a86a60","#8a4a50"})
ell(33,31,6,4.5,0,2,{"#fff0d0","#f0d8b0","#e0b890","#c89a78","#8a6a6a"})
rect(32,29,34,30,"#2b1c26"); rect(33,31,33,32,"#7a4e32")
sleepy(22,25,5); sleepy(35,25,5); blush(19,30,3); blush(42,30,3)
-- towel wrap
poly({{17,40},{47,40},{49,56},{15,56}},{"#ffd0e0","#ff9ab8","#e8688c","#b8487a","#6e3a7a"})
rect(16,45,48,46,"#8fe0c8"); rect(16,45,48,45,"#c8f8e8"); rect(16,46,48,46,"#3fa896")
rect(16,51,48,52,"#8fe0c8"); rect(16,51,48,51,"#c8f8e8"); rect(16,52,48,52,"#3fa896")
rect(29,40,35,43,"#b8487a"); rect(30,40,32,40,"#e8688c")
-- waving arm
tube({{45,40},{52,36},{55,28}},3.5,3.2,BR)
ell(55,26,3.5,3.5,0,2,BR)
save("pl-aurs-6",{32,60,20,2},{{8,36},{56,44},{50,6}})
------------------------------------------------ maple mayor
new()
-- stem legs
tube({{32,44},{32,50},{32,57}},2.6,2.6,RD)
rect(26,58,29,59,"#4a3040"); rect(35,58,38,59,"#4a3040")
local LF=function(i,x,y) if M[y..","..x] and (abs(x-32)<=0 or abs(x-32-(y-34)*0.7)<=0 and y<40 or abs(x-32+(y-34)*0.7)<=0 and y<40) then return RD[min(5,i+1)] end end
poly({{32,13},{36,22},{43,18},{41,29},{52,29},{45,37},{50,45},{38,44},{33,50},{31,50},{26,44},{14,45},{19,37},{12,29},{23,29},{21,18},{28,22}},{"#ff9a70","#f06848","#c8403a","#8a2a4a","#5a2a4a"},LF)
-- sash
line(20,34,40,46,"#ffe98a") line(20,35,40,47,"#e8963a")
-- top hat
rect(24,9,40,10,"#4a3a68"); rect(26,1,38,9,"#3a2f58"); rect(26,1,28,9,"#5a4a88"); rect(26,7,38,8,"#ffc94a")
-- face
eye(24,24,5); eye(33,24,5); blush(22,30,3); blush(38,30,3); rect(29,31,33,32,"#7a2a3a"); px(30,32,"#fff6e0"); px(32,32,"#fff6e0")
-- syrup jar
rect(48,32,54,40,"#ffc15a"); rect(48,32,49,40,"#fff0a0"); rect(53,32,54,40,"#c8803a"); rect(48,40,54,40,"#a8523a"); rect(49,30,53,31,"#9a6a45"); px(50,36,"#fffbe8")
line(46,36,48,36,"#c8403a")
save("pl-sugr-6",{32,61,14,1},{{8,10},{56,10},{8,50}})
------------------------------------------------ pinkcap
new()
-- stem body
ell(32,44,10,12,0,2.2,CR)
ell(24,57,4,2.5,0,2,BR); ell(37,56,4,2.5,0,2,BR)
-- arms: left holds gift, right waves up
tube({{23,44},{17,42},{14,38}},2.2,2,CR)
tube({{41,42},{48,36},{50,26}},2.2,2,CR)
-- gift
rect(7,31,16,39,"#b898e8"); rect(7,31,9,39,"#e0c8ff"); rect(14,31,16,39,"#6a4a98"); rect(11,31,12,39,"#ffe98a"); rect(7,35,16,36,"#ffe98a"); px(10,30,"#ffe98a") px(13,30,"#ffe98a")
-- cap
ell(32,22,20,13,0,2.2,PK)
rect(12,29,52,32,"#b8487a"); rect(13,29,51,29,"#e8688c"); rect(12,32,52,32,"#6e3a7a")
for _,p in ipairs{{22,14,2},{30,10,2},{39,16,2},{26,22,1},{44,24,1},{18,24,1},{34,26,1}} do rect(p[1],p[2],p[1]+p[3],p[2]+p[3]-(p[3]>1 and 0 or 1),"#fff1d6") end
happy(25,36,5); happy(35,36,5); blush(22,40,3); blush(39,40,3); rect(30,40,34,41,"#7a2a3a"); rect(31,40,33,40,"#e8688c")
sparkle(53,18)
save("pl-wfri-6",{32,60,17,2},{{6,10},{58,34},{8,52}})
------------------------------------------------ wishlight
new()
-- water
ell(32,57,24,3,0,2,{"#8fe0e8","#5ab8d0","#3f8aa8","#2f5a86","#2a3a66"}); rect(10,57,16,57,"#cfeaf4"); rect(46,58,52,58,"#cfeaf4")
-- boat
poly({{14,45},{50,45},{44,54},{20,54}},WD); rect(14,45,50,46,"#c9a068"); rect(20,53,44,54,"#4a3040")
-- lantern
tube({{32,6},{32,10}},1.5,1.5,WD)
ell(32,4,3,2,0,2,YE)
rect(24,9,40,12,"#7a4e32"); rect(24,9,40,9,"#c9a068")
ell(32,28,14,17,0,2.2,OR,function(i,x,y) if (x-32)%7==0 and i>=2 and i<=4 then return OR[i+1] end end)
ell(32,32,8,10,0,2.2,YE)
rect(24,44,40,46,"#7a4e32"); rect(24,44,40,44,"#c9a068")
-- star wish in belly
px(32,37,"#fffbe8"); px(31,38,"#fffbe8") px(32,38,"#fffbe8") px(33,38,"#fffbe8") px(32,39,"#fffbe8")
eye(24,24,5); eye(35,24,5); blush(22,31,3); blush(40,31,3); rect(30,30,34,30,"#2b1c26"); px(29,29,"#2b1c26"); px(35,29,"#2b1c26")
save("pl-wlfe-6",nil,{{8,16},{56,18},{8,46}})
------------------------------------------------ boto
new()
ell(32,57,23,4,0,2,{"#8fe0e8","#5ab8d0","#3f8aa8","#2f5a86","#2a3a66"}); rect(12,57,19,57,"#cfeaf4"); rect(42,59,49,59,"#cfeaf4")
-- tail + flukes
tube({{20,46},{12,40},{9,30}},3.5,2,PK)
poly({{9,30},{3,24},{6,31},{3,36},{11,32}},PK)
-- body
ell(30,44,16,10,-0.25,2.2,PK)
ell(33,48,11,5,-0.2,2,{"#fff0f0","#ffd8e4","#f0b0c8","#d890a8","#a8688a"})
-- dorsal + flipper
poly({{28,34},{32,24},{37,36}},PK)
poly({{36,52},{44,56},{34,57}},{"#e8688c","#e8688c","#c8487a","#b8487a","#6e3a7a"})
-- head
ell(44,38,9,8,0,2.2,PK)
tube({{50,42},{57,44}},2.6,2,PK)
rect(51,46,57,46,"#ffd8e4")
-- seed on beak
ell(59,41,2,2.6,0,2,YE); px(59,38,"#5fae4a"); px(60,37,"#5fae4a")
eye(43,33,4); blush(46,41,3)
rect(52,45,54,45,"#2b1c26")
save("pl-wdol-6",nil,{{8,12},{40,10},{56,52}})
