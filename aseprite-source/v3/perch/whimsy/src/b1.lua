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
R.giraffe={"#ffe890","#fbc850","#e0a040","#b87a3a","#6a4a62"}
R.thread={"#f4f4fc","#d8dcec","#b4bad4","#8a90b4","#5a5a8a"}
pal("mm-gatepost-hoot",function()
  -- gatepost
  F(B(22,46,41,58,1),"brown",function(i,x,y) if x%4==0 and i>=2 and i<5 then return R.brown[i+1] end end)
  F(B(19,43,44,48,2),"tan")
  -- ear tufts + feather quirk
  F(P{{21,18},{28,23},{21,28}},"brown"); F(P{{43,18},{36,23},{43,28}},"brown")
  F(P{{31,10},{34,10},{33,17},{30,17}},"brown")
  -- body + wings
  F(E(32,36,12,10,2.2),"brown")
  F(E(21,36,4,8,2),R.wingb); F(E(43,36,4,8,2),R.wingb)
  F(E(32,40,7,7,2),"cream",function(i,x,y) if (x+y*2)%5==0 and i>=2 and i<5 then return R.cream[i+1] end end)
  F(E(32,25,12,9,2.2),"brown")
  reye(26,25,5,"yellow"); reye(38,25,5,"yellow")
  px(25,22,"#fff6e0")
  F(P{{30,29},{34,29},{32,34}},"orange"); px(32,34,"#2b1c26")
  rect(27,45,30,46,"#e0702f"); rect(34,45,37,46,"#e0702f"); rect(27,46,30,46,"#b04a3a"); rect(34,46,37,46,"#b04a3a")
  save("mm-gatepost-hoot",{32,60,12,2},{{8,12},{55,16},{54,50}})
end)
pal("th-tall-tiptoe",function()
  -- legs
  for _,x in ipairs{20,26,35,41} do F(B(x,51,x+3,58,0),"giraffe"); rect(x,57,x+3,58,"#684030") end
  F(P{{18,40},{12,50},{15,52}},"brown") -- tail
  L(17,44,13,53,1,R.brown[3]); F(E(13,54,2,2,2),"dark")
  F(E(30,46,14,8,2.4),"giraffe",function(i,x,y) local cx,cy=x//5,y//5
    local dx,dy=x-(cx*5+2.5)+(H(cx,cy)-.5)*2,y-(cy*5+2.5)
    if dx*dx+dy*dy<=4.2 and H(cx+3,cy+9)<0.8 then return ({"#c08850","#a8673a","#8a4a32","#6a3a3a","#46324f"})[i] end end)
  F(P{{33,42},{36,24},{44,24},{43,44}},"giraffe",function(i,x,y) local cx,cy=x//5,y//5
    local dx,dy=x-(cx*5+2.5),y-(cy*5+2.5)
    if dx*dx+dy*dy<=3.4 and H(cx+3,cy+9)<0.7 then return ({"#c08850","#a8673a","#8a4a32","#6a3a3a","#46324f"})[i] end end)
  L(36,26,37,40,1,"#8a4a32")
  -- twig with leaves
  L(46,6,58,6,1,R.brown[3]); F(E(50,4,3,2,2),"green"); F(E(56,4,3,2,2),"green")
  L(41,13,40,8,1,R.brown[3]); L(47,12,48,8,1,R.brown[3]); F(E(40,7,2,2,2),"brown"); F(E(48,7,2,2,2),"brown")
  F(E(40,16,3,3,2),"giraffe")
  F(E(44,17,7,6,2.2),"giraffe"); F(E(50,20,5,4,2),"cream")
  rect(44,14,45,17,"#2b1c26"); px(44,14,"#fff6e0"); px(45,16,"#d8c8f0")
  px(53,19,"#6a3a3a"); smile(48,23,3); blush(43,20)
  -- leaf in mouth
  F(E(54,22,3,2,2),"green"); L(50,23,53,22,1,"#3a8a52")
  save("th-tall-tiptoe",{30,60,16,2},{{8,14},{22,6},{56,46}})
end)
pal("pl-frt-6",function()
  for _,s in ipairs{{18,30},{25,25},{32,19},{39,25},{46,30}} do F(P{{s[1]-4,44},{s[1],s[2]},{s[1]+4,44}},"ice") end
  -- icicles
  for _,s in ipairs{{19,60},{31,59},{43,60}} do F(P{{s[1]-2,52},{s[1],s[2]-1},{s[1]+2,52}},"ice") end
  F(B(14,41,49,53,2),"ice",function(i,x,y) if y==44 and x%3==0 and i<5 then return R.ice[1] end end)
  rect(15,52,48,53,"#6aa8d8")
  -- gems on spike tips
  px(32,22,"#ff9ec0"); px(32,23,"#c04a7e"); px(18,32,"#ffd84a"); px(46,32,"#ffd84a")
  -- toad eyes
  reye(22,40,5,"green"); reye(42,40,5,"green")
  px(21,37,"#fffaf0")
  -- wide toad grin + tongue
  smile(24,47,17); F(E(32,51,2,2,2),"pink"); px(32,49,"#c04a7e")
  px(28,44,"#9fd8ee"); px(36,44,"#9fd8ee")
  -- warts
  px(17,45,"#9fd8ee"); px(46,50,"#6aa8d8"); px(19,50,"#6aa8d8")
  save("pl-frt-6",{32,61,17,1},{{8,18},{55,16},{56,52}})
end)
pal("pl-sbs-6",function()
  for i=0,3 do local Y=34+i*4
    L(18,Y,9,Y-7,2,R.dark[3]); L(9,Y-7,3+i*2,53+i,2,R.dark[3]); L(18,Y,9,Y-7,1,R.dark[2])
    L(45,Y,54,Y-7,2,R.dark[3]); L(54,Y-7,60-i*2,53+i,2,R.dark[3]); L(45,Y,54,Y-7,1,R.dark[2]) end
  -- fuzzy silver tuft
  for _,x in ipairs{22,27,32,37,42} do F(P{{x-2,24},{x+1,17+(x%3)*2},{x+3,24}},"thread") end
  F(B(17,24,46,29,2),"brown")
  F(B(20,29,43,50,0),"thread",function(i,x,y) if y%2==0 and i>=2 and i<5 then return R.thread[i+1] end end)
  F(B(17,50,46,55,2),"brown")
  rect(18,51,45,51,"#b87a46")
  reye(27,38,4,"white"); reye(37,38,4,"white")
  px(30,33,"#2b1c26"); px(34,33,"#2b1c26"); px(29,32,"#2b1c26"); px(35,32,"#2b1c26")
  smile(29,43,5); px(29,45,"#fff6e0"); px(33,45,"#fff6e0")
  -- humming notes
  rect(52,12,52,19,"#ffe98a"); F(E(50,20,2,2,2),"yellow"); px(53,12,"#ffe98a"); px(54,13,"#ffe98a")
  save("pl-sbs-6",{32,60,16,2},{{8,12},{14,56},{57,48}})
end)
pal("pl-smk-6",function()
  for _,p in ipairs{{23,56},{38,56},{11,55}} do F(E(p[1],p[2],3,2,2),"orange") end
  -- tail curl
  LR(44,47,52,44,4,"orange"); LR(52,44,55,38,4,"orange"); LR(55,38,52,32,3,"orange")
  F(E(51,29,3,4,2),"yellow"); F(E(51,30,1,2,2),"red")
  F(E(30,48,16,8,2.4),"orange",function(i,x,y)
    if y>=53 and i<5 then return R.cream[math.max(1,i-1)] end
    for _,p in ipairs{{28,45},{33,47},{38,44},{24,48},{41,49}} do if (x-p[1])^2+(y-p[2])^2<=2 then return R.yellow[math.min(5,i)] end end end)
  F(E(15,45,9,8,2.2),"orange"); F(E(11,50,4,3,2),"orange")
  happy(10,43,4); happy(18,43,4); blush(9,47); blush(20,47); px(8,49,"#2b1c26"); smile(11,51,3)
  px(7,47,"#6a3558")
  -- smoke puffs and z
  F(E(9,40,2,2,2),"white"); F(E(7,34,3,3,2),"white"); F(E(11,26,4,4,2),"grey")
  rect(17,18,20,18,"#fffaf0"); px(19,19,"#fffaf0"); px(18,20,"#fffaf0"); rect(17,21,20,21,"#fffaf0")
  save("pl-smk-6",{30,60,17,2},{{6,14},{56,12},{56,54}})
end)
