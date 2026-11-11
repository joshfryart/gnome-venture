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
------------------------------------------------ stork
new()
-- roof
poly({{4,57},{12,49},{52,49},{60,57}},{"#ff9a70","#d8584a","#b0383f","#8a2a4a","#5a2a4a"},function(i,x,y) if (x+(y//2)*3)%6==0 then return "#5a2a4a" end end)
rect(8,57,56,58,"#6e2a4a")
-- legs
rect(28,50,29,56,"#e89a3a"); rect(34,50,35,56,"#e89a3a"); rect(26,56,30,57,"#ffc15a"); rect(33,56,37,57,"#ffc15a")
-- body & tail
poly({{40,40},{50,34},{48,44}},{"#2b1c26","#3a2f58","#3a2f58","#2c3470","#241f4a"})
ell(31,40,13,11,0,2.2,WH)
-- wing with black flight feathers
ell(37,40,9,6,0.2,2,WH)
poly({{30,43},{46,38},{46,45},{34,48}},{"#7a7a98","#5a5a78","#3a3a58","#2c2c48","#1c1c2c"})
-- neck + head
tube({{26,36},{22,28},{25,20}},3.2,2.6,WH)
ell(24,16,6,5,0,2,WH)
-- beak long
tube({{19,17},{12,20}},1.9,1.2,{"#ffb890","#ff8a60","#e8584a","#c0383f","#8a2a4a"})
eye(24,13,4); blush(22,19,2)
-- parcel on string
line(12,21,12,27,"#fff0d0")
rect(6,27,17,36,"#c9a068"); rect(6,27,9,36,"#e0b878"); rect(14,27,17,36,"#7a4e32"); rect(6,36,17,36,"#5b3a2c")
rect(11,27,12,36,"#e8584a"); rect(6,31,17,32,"#e8584a")
save("pl-stkv-6",{32,60,24,1},{{8,8},{56,16},{58,42}})
------------------------------------------------ swallow
new()
-- ruin stone block
poly({{20,50},{44,50},{46,58},{18,58}},ST,function(i,x,y) if y==54 or (y<54 and (x==31)) or (y>54 and x==38) then return ST[4] end end)
rect(22,49,28,50,"#8fd05a")
-- forked tail swept back
tube({{20,38},{12,44},{6,52}},2.6,1,NV); tube({{22,40},{16,48},{14,56}},2.2,1,NV)
-- body
ell(33,36,15,10,-0.3,2.2,NV)
ell(37,42,9,5,-0.3,2,CR)
-- tucked wing
poly({{22,30},{40,28},{34,42},{20,40}},{"#7a9ae8","#4a6ac0","#3a4a98","#2c3470","#241f4a"})
line(26,32,34,38,"#7a9ae8")
-- head
ell(44,31,8,7,0,2.2,NV)
ell(46,36,5,3,0,2,{"#ffb890","#ff8a60","#e8584a","#c0383f","#8a2a4a"})
-- beak with seed
tube({{51,32},{57,34}},1.8,1,YE); px(58,35,"#5fae4a"); rect(57,36,59,37,"#e0b878")
eye(45,27,4); blush(41,33,2)
save("pl-hang-6",{32,60,16,1},{{8,16},{54,16},{10,40}})
------------------------------------------------ bluebird
new()
-- waterfall strip
rect(50,22,55,50,"#8fc0f0"); rect(50,22,51,50,"#cfe8ff"); rect(54,22,55,50,"#5a90d8"); for y=24,48,4 do rect(52,y,52,y+1,"#fbfcff") end
-- cliff
poly({{32,4},{40,14},{50,26},{52,42},{46,55},{18,55},{12,42},{14,26},{24,14}},GR,function(i,x,y) if H(x/2,y/2)<0.1 and i<=3 then return GR[i+1] end end)
-- hollow
ell(32,38,12,14,0,2.2,DK)
-- bird
ell(32,43,8,10,0,2.2,{"#cfe8ff","#8fc0f0","#5a90d8","#4a62b0","#3a3a7a"})
ell(32,48,5,6,0,2,{"#fff0d0","#ffc15a","#ff9a50","#d8683a","#8a3a4a"})
eye(26,34,4); eye(33,34,4)
poly({{30,39},{34,39},{32,43}},YE)
-- ledge
ell(32,57,19,3,0,2,ST)
-- note
rect(52,5,53,12,"#2b1c26"); rect(54,4,57,6,"#2b1c26"); rect(49,11,52,13,"#2b1c26")
save("pl-sing-6",nil,{{6,14},{8,46},{58,52}})
------------------------------------------------ chipmunk
new()
-- stump
ell(32,56,17,5,0,2.4,WD,function(i,x,y) local d=sqrt(((x-32)/17)^2+((y-56)/5)^2) if abs(d-0.55)<0.07 then return WD[min(5,i+1)] end end)
-- tail
tube({{40,50},{50,44},{50,30}},4,3.5,BR,function(i,x,y) if (y%4==0) and i>=2 and i<=4 then return "#43292a" end end)
-- feet
rect(24,53,28,56,"#8a5ac0"); rect(35,53,39,56,"#8a5ac0"); rect(24,53,28,53,"#b898e8")
ell(32,43,11,12,0,2.2,BR)
ell(32,46,6,8,0,2,CR)
-- head + ears
ell(32,26,13,10,0,2.2,BR,function(i,x,y) if abs(x-32)<=0 and y<20 then return "#43292a" end if (abs(x-27)==0 or abs(x-37)==0) and y<20 and i>=2 then return "#43292a" end end)
poly({{19,22},{20,10},{27,18}},BR); poly({{45,22},{44,10},{37,18}},BR)
poly({{21,19},{21,13},{25,18}},{"#f0c8a8","#e0a888","#c88a70","#a86a60","#8a4a50"}); poly({{43,19},{43,13},{39,18}},{"#f0c8a8","#e0a888","#c88a70","#a86a60","#8a4a50"})
px(20,9,"#e0b878") px(44,9,"#e0b878"); px(19,10,"#e0b878"); px(45,10,"#e0b878")
-- eyes looking up
eye(24,23,5); eye(35,23,5); px(26,23,"#fff6e0")
ell(32,31,6,4,0,2,CR); rect(31,28,33,29,"#2b1c26"); rect(32,32,32,33,"#2b1c26")
blush(21,29,3); blush(40,29,3)
-- orb held
ell(32,44,4.5,4.5,0,2,{"#fbfcff","#f0f4ff","#d8e0f4","#b0b8e0","#8a8ac0"}); px(30,42,"#ffffff") 
tube({{23,40},{27,45}},1.8,1.8,BR); tube({{41,40},{37,45}},1.8,1.8,BR)
save("pl-trng-6",{32,60,19,1},{{8,12},{56,14},{56,50}})
