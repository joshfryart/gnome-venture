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
local jag={"#ffd68a","#ffb04a","#e8872a","#b8603a","#6a3a55"}
----------------------------------------------------------- scarab
pal("pl-scr-6",{32,61,16,1},{{7,14},{57,8},{58,50}},function()
  local lc="#35306e"
  for _,l in ipairs{{19,36,8,29},{17,44,6,46},{19,52,9,58}} do
    line(l[1],l[2],l[3],l[4],lc,2); line(63-l[1],l[2],63-l[3],l[4],lc,2)
    px(l[3],l[4],"#6a6fb0"); px(63-l[3],l[4],"#6a6fb0") end
  sblob(32,44,15,15,2,R.blue,function(i,x,y)
    if x==31 or x==32 then return R.blue[5] end
    if i==1 and (x<30 and y<40) then return "#e8f8ff" end end)
  for y=34,56,3 do px(24,y,"#ffd966"); px(39,y,"#ffd966") end
  for x=22,41,3 do px(x,58,"#ffd966") end
  px(23,37,"#fff6e0"); px(24,36,"#fff6e0")
  sblob(32,26,9,7,2,R.blue)
  eye(25,24,4,5); eye(35,24,4,5)
  px(31,30,"#2b1c26"); px(32,31,"#2b1c26"); px(33,30,"#2b1c26")
  px(27,31,"#f5a0b8"); px(37,31,"#f5a0b8")
  poly({{29,20},{35,20},{32,12}},R.blue)
  sblob(32,18,3,3,2,{"#ffc0b0","#ff6a5a","#d8332f","#9a2a40","#55284f"}); px(31,17,"#fff6e0")
  px(26,32,"#35306e"); px(38,32,"#35306e")
end)
----------------------------------------------------------- jaguar
pal("pl-jrc-6",{32,61,22,1},{{7,16},{57,10},{58,36}},function()
  sblob(32,55,23,6,2,R.grey,function(i,x,y) if i<=2 and H(x,y)<0.2 then return "#8fd05a" end end)
  for _,b in ipairs{{49,50,3,5},{52,43,3,5},{51,36,3,4}} do sblob(b[1],b[2],b[3],b[4],2,jag) end
  sblob(50,32,3,3,2,R.black)
  sblob(32,47,10,10,2,jag)
  sblob(32,50,6,6,2,R.cream)
  px(27,44,"#2b1c26"); px(28,44,"#2b1c26"); px(37,45,"#2b1c26"); px(36,45,"#2b1c26"); px(25,49,"#2b1c26"); px(40,49,"#2b1c26")
  sblob(26,55,4,3,2,R.cream); sblob(38,55,4,3,2,R.cream)
  sblob(21,19,4,4,2,jag); sblob(43,19,4,4,2,jag); px(21,20,"#f5a0b8"); px(22,20,"#f5a0b8"); px(43,20,"#f5a0b8"); px(42,20,"#f5a0b8")
  sblob(32,30,14,11,2,jag)
  sblob(32,35,6,4,2,R.cream)
  for _,e in ipairs{22,37} do
    rect(e,25,e+4,30,"#8fd05a"); rect(e,25,e+4,25,"#c8f08a"); rect(e+2,25,e+2,30,"#2b1c26"); rect(e+1,26,e+3,29,"#2b1c26")
    px(e+1,26,"#fff6e0"); px(e,26,"#fff6e0"); px(e+3,29,"#d8f0a8")
  end
  line(21,23,26,24,"#6a3a55",1); line(37,24,42,23,"#6a3a55",1)
  rect(31,33,32,33,"#e8688f"); px(31,34,"#2b1c26"); px(32,34,"#2b1c26"); px(29,35,"#2b1c26"); px(30,35,"#2b1c26"); px(33,35,"#2b1c26"); px(34,35,"#2b1c26")
  for _,p in ipairs{{31,20},{32,20},{32,21},{28,21},{36,21},{18,28},{46,28}} do px(p[1],p[2],"#6a3a55") end
  px(18,33,"#fff6e0"); px(19,34,"#fff6e0"); px(46,33,"#fff6e0"); px(45,34,"#fff6e0")
end)
----------------------------------------------------------- barrel
pal("pl-scg-6",{31,61,18,1},{{8,20},{57,12},{58,44}},function()
  sblob(32,41,17,17,3,R.wood,function(i,x,y) if x%6==0 and i>=2 and i<=4 then return R.wood[i+1] end end)
  for k,_ in pairs(M) do local y,x=k:match("(%-?%d+),(%-?%d+)") y=tonumber(y) x=tonumber(x)
    if y==30 or y==52 then px(x,y,"#9aa4be") elseif y==31 or y==53 then px(x,y,"#707a9c") elseif y==29 or y==51 then if x<34 then px(x,y,"#e4e8f0") end end end
  sblob(32,25,15,5,2,{"#e0b078","#c8905a","#a8683c","#7a4a38","#4a2f45"})
  sblob(32,25,12,3,2,{"#fffbe8","#fff0a0","#ffe08a","#d8c868","#9a8a5a"})
  -- peeking moon
  blobf(function(x,y) return ((x-32)^2+(y-17)^2<=36) and ((x-35)^2+(y-14)^2>20) end,32,17,6,6,{"#fffbe8","#fff6c8","#ffe98a","#e8c868","#b89a6a"})
  px(30,13,"#fffbe8")
  eye(23,37,4,5); eye(36,37,4,5)
  px(31,43,"#2b1c26"); px(32,44,"#2b1c26"); px(33,44,"#2b1c26"); px(34,43,"#2b1c26")
  rect(21,43,23,43,"#e8688f"); rect(40,43,42,43,"#e8688f")
  rect(49,41,54,44,"#9aa4be"); rect(49,41,54,41,"#e4e8f0"); rect(49,44,54,44,"#4a4a72"); rect(52,45,53,46,"#9aa4be")
  px(53,48,"#ffe98a"); px(53,49,"#ffe98a"); px(53,50,"#fffbe8")
end)
----------------------------------------------------------- fox
pal("pl-aurc-6",{32,60,22,1},{{8,16},{57,12},{58,38}},function()
  sblob(38,47,19,11,2,R.orange)
  sblob(22,44,11,10,2,R.orange)
  sblob(18,48,7,5,2,R.cream)
  px(12,47,"#2b1c26"); px(13,47,"#2b1c26"); px(12,48,"#2b1c26")
  sblob(34,55,17,5,2,{"#ffd090","#ffb860","#f08a3a","#b8603a","#6a3a55"})
  sblob(51,54,5,5,2,R.cream)
  for _,p in ipairs{{16,43},{17,44},{18,44},{19,43}} do px(p[1],p[2],"#2b1c26") end
  for _,p in ipairs{{25,42},{26,43},{27,43},{28,42}} do px(p[1],p[2],"#2b1c26") end
  rect(15,46,16,46,"#f5a0b8"); rect(27,47,28,47,"#f5a0b8")
  -- cap
  poly({{13,36},{14,31},{31,30},{31,36}},R.cream)
  poly({{18,31},{32,29},{47,39},{45,45},{30,36}},R.blue)
  for _,p in ipairs{{26,32},{33,34},{39,38}} do px(p[1],p[2],"#fff6e0") end
  sblob(46,46,3,3,2,R.cream)
  poly({{12,35},{12,26},{19,32}},R.orange); px(14,31,"#f5a0b8"); px(14,32,"#f5a0b8")
  poly({{27,32},{30,26},{34,32}},R.orange)
  for _,p in ipairs{{8,36},{9,36},{10,36},{10,35},{9,34},{8,33},{9,33},{10,33}} do px(p[1],p[2]+0,"#d8c8f0") end
  rect(6,57,9,58,"#e8523f"); px(7,56,"#ffc870"); px(8,57,"#ffe98a")
end)
----------------------------------------------------------- marigold
pal("pl-flfm-6",{32,60,20,1},{{6,40},{57,8},{58,34}},function()
  line(49,48,58,58,"#8f5a38",2); poly({{54,54},{60,56},{57,62},{52,59}},R.wood)
  for a=0,11 do local t=a*math.pi/6
    sblob(32+math.cos(t)*13,32+math.sin(t)*12,6,6,2,(a%2==0) and R.orange or R.yellow) end
  sblob(32,32,12,11,2,R.yellow)
  eye(25,30,4,5); eye(35,30,4,5)
  px(31,37,"#2b1c26"); px(32,38,"#2b1c26"); px(33,38,"#2b1c26"); px(34,37,"#2b1c26")
  rect(22,36,24,36,"#ff9ab8"); rect(40,36,42,36,"#ff9ab8")
  sblob(32,20,13,3,2,R.pink)
  poly({{23,19},{29,3},{34,2},{37,6},{41,19}},R.pink)
  rect(24,17,40,18,"#ffd966"); px(33,3,"#ffc8dc")
  CL=function(x,y) return y>=50 end
  sblob(32,55,20,9,2,R.wood,function(i,x,y) if y%4==0 and i<=4 then return R.wood[i+1] end end)
  CL=nil
  for i=0,8 do local x=14+i*4.5 local y=51+math.sin(i/8*math.pi)*3
    sblob(x,y,2.5,2.5,2,(i%3==0) and R.pink or ((i%3==1) and R.orange or R.yellow)) end
  line(14,50,50,50,"#3a8a52",1)
end)
