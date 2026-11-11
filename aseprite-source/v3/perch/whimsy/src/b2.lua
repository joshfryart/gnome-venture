local out = app.params.out or "./"
local INK = Color{r=0x2b,g=0x1c,b=0x26}
local function hex(h) h=h:gsub("#","") return Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16)} end
local img
local floor,ceil,abs,sqrt=math.floor,math.ceil,math.abs,math.sqrt
local function px(x,y,c) if x>=0 and y>=0 and x<64 and y<64 then img:putPixel(x,y,type(c)=="string" and hex(c) or c) end end
local function rect(x0,y0,x1,y1,c) for y=y0,y1 do for x=x0,x1 do px(x,y,c) end end end
local function H(x,y) return (math.sin(x*12.9898+y*78.233)*43758.5453)%1 end
local R={
 brown={"#d9a46a","#b87a46","#8f5a38","#684030","#46324f"},
 tan={"#f0d0a0","#d8aa70","#b88450","#8a6040","#5a4458"},
 cream={"#fff3d6","#f6e0b4","#e0c090","#b8946e","#7a6488"},
 grey={"#e4e8f0","#c4c8d8","#9a9ebb","#727694","#4e4a72"},
 red={"#ff8a6a","#e8503f","#c03040","#8f2a46","#5a2a55"},
 orange={"#ffc47a","#ff9a45","#e0702f","#b04a3a","#6a3558"},
 yellow={"#fff29a","#ffd84a","#e8b02f","#b9802f","#7a5048"},
 green={"#c4ee82","#8fd05a","#5fae4a","#3a8a52","#2f4f6a"},
 olive={"#cfe07a","#a8c050","#7f9a3a","#58763a","#35505a"},
 teal={"#7fdcc8","#3fb0a8","#2a8a9a","#2a6482","#34426e"},
 blue={"#bfe4ff","#8ac4f0","#5a96d6","#406ab0","#383a78"},
 ice={"#f4fcff","#d0f0fa","#9fd8ee","#6aa8d8","#4a6ab0"},
 pink={"#ffd0e0","#ff9ec0","#f06a98","#c04a7e","#7a3a72"},
 purple={"#d8b0f0","#b080d8","#8a5cb8","#64428f","#42306e"},
 navy={"#7a8ab8","#566494","#3e4a78","#2e3860","#241f4a"},
 white={"#fffaf0","#f0ecf4","#d8d4e8","#b0acd0","#807ca8"},
 peach={"#ffe0c4","#ffc49a","#e89a70","#c0705a","#7a4a62"},
 dark={"#8a7aa8","#665a88","#4a4068","#3a3058","#2e2446"},
}
R.wood={"#e0b074","#bf8450","#946040","#6e4434","#4a3452"}
local M={}
-- masks return fn(x,y)->inside,dx,dy,d
local function E(cx,cy,rx,ry,pw) pw=pw or 2.4
  return {x0=floor(cx-rx)-1,x1=ceil(cx+rx)+1,y0=floor(cy-ry)-1,y1=ceil(cy+ry)+1,f=function(x,y)
    local dx,dy=(x-cx+0.5)/rx,(y-cy+0.5)/ry; local d=(abs(dx)^pw+abs(dy)^pw)^(1/pw); return d<=1,dx,dy,d end} end
local function B(x0,y0,x1,y1,rd) rd=rd or 1
  local cx,cy,rx,ry=(x0+x1+1)/2,(y0+y1+1)/2,(x1-x0+1)/2,(y1-y0+1)/2
  return {x0=x0,x1=x1,y0=y0,y1=y1,f=function(x,y)
    if x<x0 or x>x1 or y<y0 or y>y1 then return false,0,0,1 end
    local dx,dy=(x-cx+0.5)/rx,(y-cy+0.5)/ry
    local ex=math.min(x-x0,x1-x); local ey=math.min(y-y0,y1-y)
    if ex+ey<rd then return false,dx,dy,1 end
    return true,dx,dy,math.max(abs(dx),abs(dy))*0.9 end} end
local function P(pts)
  local x0,y0,x1,y1=99,99,-99,-99
  for _,p in ipairs(pts) do x0=math.min(x0,p[1]) x1=math.max(x1,p[1]) y0=math.min(y0,p[2]) y1=math.max(y1,p[2]) end
  local cx,cy,rx,ry=(x0+x1)/2,(y0+y1)/2,math.max(1,(x1-x0)/2),math.max(1,(y1-y0)/2)
  return {x0=floor(x0)-1,x1=ceil(x1)+1,y0=floor(y0)-1,y1=ceil(y1)+1,f=function(x,y)
    local X,Y=x+0.5,y+0.5; local ins=false; local n=#pts; local j=n
    for i=1,n do local a,b=pts[i],pts[j]
      if ((a[2]>Y)~=(b[2]>Y)) and (X<(b[1]-a[1])*(Y-a[2])/(b[2]-a[2])+a[1]) then ins=not ins end j=i end
    local dx,dy=(X-cx)/rx,(Y-cy)/ry
    return ins,dx,dy,math.min(1,sqrt(dx*dx+dy*dy)*0.8) end} end
-- fill mask with 5-tone ramp; tex(i,x,y)->colour|nil
local function F(m,r,tex)
  if type(r)=="string" then r=R[r] end
  local S={}
  for y=m.y0,m.y1 do for x=m.x0,m.x1 do local ok=m.f(x,y) if ok then S[y..","..x]=true end end end
  for y=m.y0,m.y1 do for x=m.x0,m.x1 do
    if S[y..","..x] then
      local _,dx,dy,d=m.f(x,y)
      local l=-0.55*dx-0.75*dy-0.5*d*d*d
      local i= l>0.55 and 1 or (l>0.12 and 2 or (l>-0.32 and 3 or (l>-0.72 and 4 or 5)))
      if not S[(y+1)..","..(x+1)] and i<4 then i=4 end
      if not S[(y+1)..","..x] and not S[y..","..(x+1)] and i<5 and H(x,y)>0.0 then i=math.max(i,5) end
      if not S[(y-1)..","..(x-1)] and i>2 then i=2 end
      local c=(tex and tex(i,x,y)) or r[i]
      px(x,y,c) end end end
  M=S
  return S
end
local function inS(S,x,y) return S[y..","..x] end
local function L(x0,y0,x1,y1,w,c) -- thick line
  local n=math.max(abs(x1-x0),abs(y1-y0)); if n==0 then n=1 end
  for i=0,n do local x=floor(x0+(x1-x0)*i/n+0.5); local y=floor(y0+(y1-y0)*i/n+0.5)
    for a=0,w-1 do for b=0,w-1 do px(x+a,y+b,c) end end end
end
local function LR(x0,y0,x1,y1,w,r) -- thick line shaded by ramp: lit upper-left edge, shade lower-right
  local rr=type(r)=="string" and R[r] or r
  L(x0,y0,x1,y1,w,rr[3]); L(x0,y0,x1,y1,1,rr[2]) 
  if w>=3 then L(x0+w-1,y0+w-1,x1+w-1,y1+w-1,1,rr[4]) end
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
local function eye(x,y,w) w=w or 4
  rect(x,y,x+w-1,y+4,"#2b1c26"); rect(x+1,y+1,x+2,y+2,"#fff6e0"); px(x+w-2,y+3,"#d8c8f0"); px(x+1,y+4,"#6a4a7a")
end
local function reye(cx,cy,r,ring) -- round eye: pale ring, ink pupil, big highlight
  F(E(cx,cy,r,r,2),ring or "cream")
  rect(cx-1,cy-1,cx+1,cy+1,"#2b1c26"); px(cx-1,cy-1,"#fff6e0"); px(cx,cy-1,"#fff6e0")
end
local function happy(x,y,w) -- closed smiling eye arc
  for i=0,w-1 do local dy=(i==0 or i==w-1) and 1 or 0; px(x+i,y+dy,"#2b1c26") end
end
local function smile(x,y,w) px(x,y,"#2b1c26"); px(x+w-1,y,"#2b1c26"); for i=1,w-2 do px(x+i,y+1,"#2b1c26") end end
local function blush(x,y) px(x,y,"#ff9ec0"); px(x+1,y,"#ff9ec0") end
local function sparkle(x,y) for _,d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do px(x+d[1],y+d[2],"#ffe98a") end px(x,y,"#fffbe8") end
local function twinkle(x,y) px(x,y,"#fffbe8"); px(x+1,y,"#ffe98a"); px(x-1,y,"#ffe98a"); px(x,y+1,"#ffe98a"); px(x,y-1,"#ffe98a") end
local function save(name,sh,sp)
  outline() if sh then shadow(sh[1],sh[2],sh[3],sh[4]) end
  for _,p in ipairs(sp or {}) do sparkle(p[1],p[2]) end
  local s=Sprite(64,64); s.cels[1].image:drawImage(img)
  s:saveCopyAs(out..name..".png"); s:close()
end
local function new() img=Image(64,64) end
local function pal(name,fn) new() local ok,err=pcall(fn) if not ok then print("FAIL "..name..": "..tostring(err)) end end
R.wingb={"#b87a46","#8f5a38","#684030","#46324f","#2e2446"}
R.gold={"#fff29a","#ffd84a","#e8b02f","#b9802f","#7a5048"}
pal("pl-bvd-6",function()
  F(E(49,53,8,4,2),R.wingb,function(i,x,y) if (x+y)%3==0 and i>=2 and i<5 then return R.wingb[i+1] end end)
  px(57,47,"#fff3d6"); px(58,45,"#fff3d6"); px(59,49,"#fff3d6"); rect(57,43,58,43,"#fff3d6")
  F(E(26,57,4,2,2),"brown"); F(E(38,57,4,2,2),"brown")
  F(E(32,44,11,11,2.2),"brown"); F(E(32,48,7,7,2),"tan")
  F(E(24,22,3,3,2),"brown"); F(E(40,22,3,3,2),"brown")
  F(E(32,29,10,9,2.2),"brown"); F(E(32,33,6,4,2),"tan")
  eye(25,25,4); eye(35,25,4)
  F(E(32,31,2,1,2),"dark"); rect(31,34,32,37,"#fff3d6"); px(31,37,"#d8c8f0"); px(32,37,"#d8c8f0"); px(32,34,"#b8946e")
  -- captain cap
  F(E(32,22,12,2,2),"navy"); F(B(23,12,41,21,2),"navy"); rect(31,15,33,17,"#e8b02f"); px(31,15,"#fff29a")
  rect(23,20,41,20,"#e8b02f")
  -- log being chewed
  F(B(19,41,45,47,2),"wood",function(i,x,y) if (x+y)%5==0 and i>=2 and i<5 then return R.brown[i+1] end end)
  F(E(20,44,2,3,2),"cream"); px(25,43,"#e0c090")
  F(E(23,47,3,3,2),"brown"); F(E(41,47,3,3,2),"brown")
  px(15,39,"#fff3d6"); px(47,39,"#fff3d6")
  save("pl-bvd-6",{32,60,14,2},{{8,14},{55,12},{10,56}})
end)
pal("pl-pgg-6",function()
  L(28,48,28,57,2,"#e0702f"); L(36,48,36,57,2,"#e0702f")
  rect(25,57,30,58,"#e0702f"); rect(33,57,38,58,"#e0702f"); rect(25,58,30,58,"#b04a3a"); rect(33,58,38,58,"#b04a3a")
  F(E(23,40,4,9,2),"grey"); F(E(41,40,4,9,2),"grey")
  F(E(32,38,10,11,2.2),"white")
  F(E(32,25,8,8,2.2),"white")
  eye(26,22,3); eye(35,22,3)
  F(P{{29,28},{35,28},{32,34}},"orange"); px(32,34,"#2b1c26"); px(33,33,"#b04a3a")
  -- tricorn
  F(P{{16,21},{32,6},{48,21},{45,23},{32,16},{19,23}},"dark")
  L(18,22,32,9,1,"#e8b02f"); L(32,9,46,22,1,"#b9802f")
  rect(30,12,33,15,"#fffaf0"); px(30,13,"#2b1c26"); px(33,13,"#2b1c26"); px(31,15,"#2b1c26"); px(32,15,"#2b1c26")
  -- coins
  F(E(50,56,5,2,2),"gold"); F(E(50,53,4,2,2),"gold"); px(49,52,"#fffbe8")
  px(14,56,"#ffd84a"); px(15,56,"#e8b02f")
  save("pl-pgg-6",{30,60,17,2},{{8,16},{56,14},{10,50}})
end)
pal("pl-tcb-6",function()
  L(7,32,7,57,2,R.brown[3]); L(56,32,56,57,2,R.brown[3])
  L(8,36,22,47,1,R.cream[2]); L(22,47,32,48,1,R.cream[2]); L(32,48,42,47,1,R.cream[2]); L(42,47,56,36,1,R.cream[2])
  F(E(32,43,11,11,2.2),"tan"); F(E(32,47,6,6,2),"cream")
  L(22,41,25,16,3,R.tan[3]); L(41,41,39,16,3,R.tan[3]); L(22,41,25,16,1,R.tan[2])
  F(E(25,15,2,2,2),"tan"); F(E(39,15,2,2,2),"tan")
  F(E(26,56,3,2,2),"tan"); F(E(38,56,3,2,2),"tan")
  F(E(24,24,3,3,2),"tan"); F(E(40,24,3,3,2),"tan")
  F(E(32,30,9,8,2.2),"tan"); F(E(32,34,5,3,2),"cream")
  eye(26,26,3); eye(35,26,3); F(E(32,32,2,1,2),"dark"); rect(31,35,32,36,"#fff3d6"); smile(30,36,1)
  -- walnut prize
  F(E(32,10,6,5,2),"brown"); L(32,5,32,15,1,R.brown[4]); px(29,7,"#fff3d6"); px(30,7,"#fff3d6")
  F(B(3,54,60,58,1),"wood",function(i,x,y) if x%8==0 and y>54 then return R.brown[5] end if y==54 then return R.brown[1] end end)
  save("pl-tcb-6",{32,61,17,1},{{8,8},{56,10},{12,24}})
end)
pal("pl-cblo-6",function()
  F(B(17,37,47,57,1),"cream"); L(17,38,17,57,2,R.brown[3]); L(46,38,46,57,2,R.brown[3]); rect(17,38,47,39,"#8f5a38")
  F(P{{8,37},{15,28},{49,28},{56,37},{50,39},{14,39}},"red",function(i,x,y) if y%3==0 and i>=2 and i<5 then return R.red[i+1] end end)
  F(E(8,35,2,2,2),"red"); F(E(56,35,2,2,2),"red")
  F(P{{19,29},{25,19},{39,19},{45,29}},"red",function(i,x,y) if y%3==1 and i>=2 and i<5 then return R.red[i+1] end end)
  F(E(20,28,2,2,2),"red"); F(E(44,28,2,2,2),"red")
  L(32,11,32,19,1,"#e8b02f"); F(E(32,10,2,2,2),"yellow")
  -- window eyes
  for _,cx in ipairs{25,39} do F(E(cx,46,4,4,2),"yellow"); L(cx-4,46,cx+3,46,1,"#8f5a38"); L(cx,42,cx,49,1,"#8f5a38"); px(cx-2,44,"#fffbe8") end
  F(B(28,50,35,57,3),"wood"); px(33,54,"#ffd84a")
  smile(29,48,5)
  -- swaying lantern
  L(53,38,53,41,1,"#8f5a38"); F(E(53,43,2,3,2),"red"); px(53,43,"#ffd84a")
  -- steam
  px(33,6,"#fffaf0"); px(34,5,"#fffaf0"); px(33,4,"#fffaf0"); px(32,3,"#fffaf0")
  save("pl-cblo-6",{32,60,18,2},{{8,16},{55,18},{9,52}})
end)
pal("pl-gaun-6",function()
  for _,x in ipairs{14,19,35,41} do F(B(x,49,x+2,58,0),"brown"); rect(x,57,x+2,58,"#46324f") end
  F(P{{14,40},{5,48},{8,54},{16,46}},R.wingb)
  F(E(26,45,14,8,2.4),"brown")
  F(P{{33,43},{39,27},{47,29},{43,47}},"brown"); L(40,27,34,41,2,R.wingb[3])
  F(P{{41,24},{43,20},{46,26}},"brown")
  F(E(48,31,6,5,2),"brown"); F(E(53,34,3,3,2),"tan")
  rect(47,29,48,31,"#2b1c26"); px(47,29,"#fff6e0"); px(54,34,"#46324f"); px(50,35,"#46324f")
  -- saddle blanket
  F(B(20,38,33,46,2),"red"); L(21,45,32,45,1,"#ffd84a")
  -- gnome
  F(E(26,35,6,6,2),"red"); L(22,38,30,38,1,"#ffd84a")
  L(30,33,34,23,2,R.red[3]); F(E(35,21,2,2,2),"peach")
  F(E(26,26,5,4,2),"peach"); F(E(26,31,4,4,2),"white")
  rect(23,25,24,27,"#2b1c26"); px(23,25,"#fff6e0"); rect(28,25,29,27,"#2b1c26"); px(28,25,"#fff6e0"); px(26,28,"#e89a70")
  F(E(26,22,5,2,2),"white")
  -- lifted gaucho hat
  F(E(37,17,7,2,2),"dark"); F(E(37,14,3,3,2),"dark"); L(34,16,40,16,1,"#e8b02f")
  save("pl-gaun-6",{28,60,18,2},{{8,10},{56,12},{56,50}})
end)
