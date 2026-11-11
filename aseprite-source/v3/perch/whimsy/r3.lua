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
----------------------------------------------------------- chili
pal("pl-chil-6",{32,60,17,1},{{7,18},{57,10},{58,38}},function()
  sblob(26,57,4,2,2,R.brown); sblob(38,57,4,2,2,R.brown)
  blobf(function(x,y)
    if y<=38 then return ((x-32)/14)^2+((y-38)/16)^2<=1 end
    local t=(y-38)/17 if t>1 then return false end
    local w=14*(1-t*t*0.8); local cx=32+t*2
    return math.abs(x-cx)<=w end,32,40,14,17,R.red,function(i,x,y) if i==1 and H(x,y)<0.25 then return R.red[2] end end)
  px(23,34,"#ffc8b8"); px(24,33,"#ffc8b8"); px(22,36,"#ff9a80"); px(23,37,"#ff9a80")
  sblob(32,24,8,4,2,R.green); line(30,22,36,17,"#3a8a52",2); px(37,16,"#5fae4a")
  poly({{26,21},{26,11},{29,15},{32,9},{35,15},{38,11},{38,21}},R.yellow)
  rect(26,19,38,20,"#e8b040"); px(32,10,"#fffbe8"); px(26,12,"#ffe98a"); px(32,16,"#e8523f"); px(28,18,"#4a8ad0"); px(36,18,"#4a8ad0")
  eye(24,35,4,5); eye(35,35,4,5)
  px(30,42,"#2b1c26"); px(31,43,"#2b1c26"); px(32,43,"#2b1c26"); px(33,42,"#2b1c26")
  rect(21,41,23,41,"#ff9ab8"); rect(40,41,42,41,"#ff9ab8")
  for _,p in ipairs{{50,40},{51,39},{51,38},{52,37},{50,36},{49,35},{49,37},{50,38}} do px(p[1],p[2],"#ffa040") end
  px(50,38,"#ffe98a"); px(50,39,"#ffe98a"); px(51,38,"#e8523f")
end)
----------------------------------------------------------- hedgehog
pal("pl-thch-6",{32,60,21,1},{{7,20},{57,12},{58,46}},function()
  sblob(22,58,4,2,2,R.brown); sblob(38,58,4,2,2,R.brown); sblob(48,56,3,2,2,R.brown)
  sblob(34,44,21,14,2,R.brown,function(i,x,y) if H(x,y)<0.35 and i>=2 and i<=4 then return R.brown[i+1] end if (x+y)%3==0 and i<=3 then return R.brown[i-1<1 and 1 or i-1] end end)
  local keys={} for k,_ in pairs(M) do keys[#keys+1]=k end
  for _,k in ipairs(keys) do local y,x=k:match("(%-?%d+),(%-?%d+)") y=tonumber(y) x=tonumber(x)
    if not M[(y-1)..","..x] and H(x,y)<0.55 then px(x,y-1,R.brown[3]); if H(y,x)<0.4 then px(x,y-2,R.brown[2]) end end end
  local sk={"#ffe0b8","#f0c890","#d8a470","#a87a5a","#6a4a5a"}
  sblob(18,49,10,9,2,sk)
  sblob(12,41,3,3,2,sk); sblob(24,41,3,3,2,sk)
  px(12,41,"#f5a0b8"); px(24,41,"#f5a0b8")
  sblob(10,52,3,2,2,{"#6a4a5a","#4a3a52","#3a2a46","#2b1c26","#2b1c26"}); px(9,51,"#fff6e0")
  eye(13,44,4,5); eye(21,44,4,5)
  px(15,55,"#2b1c26"); px(16,56,"#2b1c26"); px(17,56,"#2b1c26"); px(18,55,"#2b1c26")
  rect(11,50,12,50,"#2b1c26")
  rect(10,53,11,53,"#ff9ab8"); rect(22,53,24,53,"#ff9ab8")
  -- tray + teacup
  rect(31,28,47,29,"#9aa4be"); rect(31,28,47,28,"#e4e8f0"); rect(31,29,47,29,"#707a9c")
  poly({{33,21},{42,21},{41,28},{34,28}},R.cream)
  rect(34,21,41,22,"#b8602a"); rect(34,23,41,23,"#ff9ab8")
  px(43,22,"#dcccc4"); px(44,23,"#dcccc4"); px(44,24,"#b4a4c0"); px(43,25,"#b4a4c0")
  sblob(45,25,3,3,2,R.pink); px(45,22,"#e8523f"); px(44,24,"#fffaf0")
  px(36,19,"#fffaf0"); px(37,18,"#fffaf0"); px(38,17,"#dcccc4")
end)
----------------------------------------------------------- host
pal("pl-wcof-6",{32,61,24,1},{{7,12},{57,10},{58,36}},function()
  sblob(32,57,26,4,2,R.cream)
  rect(8,58,56,58,"#e8523f")
  local robe={"#f0a070","#d8704a","#b04a3f","#7a3a4a","#4a2f55"}
  sblob(20,44,11,12,2,robe,function(i,x,y) if y==52 then return "#ffd966" end end)
  sblob(14,56,4,2,2,R.brown); sblob(27,56,4,2,2,R.brown)
  sblob(21,17,9,5,2,R.black)
  local cocoa={"#c98a5a","#a8683f","#8a4f32","#5b3a2c","#43292a"}
  sblob(20,26,10,10,2,cocoa)
  for k,_ in pairs(M) do local y,x=k:match("(%-?%d+),(%-?%d+)") y=tonumber(y) x=tonumber(x)
    if y>=19 and y<=22 then px(x,y,((x//3)%2==0) and "#e8523f" or "#fff0d0") end end
  rect(10,23,29,23,"#8a2a40")
  eye(14,27,4,4); eye(23,27,4,4)
  rect(14,27,17,27,"#8a4f32"); rect(23,27,26,27,"#8a4f32")
  px(18,33,"#2b1c26"); px(19,34,"#2b1c26"); px(20,34,"#2b1c26"); px(21,33,"#2b1c26")
  rect(11,31,13,31,"#e8688f"); rect(26,31,28,31,"#e8688f")
  line(28,40,38,35,robe[3],3); px(28,40,robe[2])
  sblob(39,34,3,3,2,cocoa)
  -- teapot
  sblob(43,29,6,5,2,R.dark); poly({{38,27},{34,31},{36,32},{39,31}},R.dark)
  rect(41,23,45,24,"#e8b040"); px(43,22,"#ffd966"); px(40,26,"#a8b0c8"); px(41,26,"#a8b0c8")
  line(49,26,52,29,"#40466a",1); line(52,29,49,32,"#40466a",1)
  line(35,32,35,48,"#d88a3a",1); px(35,36,"#ffd966"); px(35,42,"#ffd966")
  for _,cx in ipairs{35,43,50} do
    poly({{cx-2,48},{cx+3,48},{cx+2,53},{cx-1,53}},R.cream)
    rect(cx-2,48,cx+2,48,"#d88a3a")
  end
  px(36,48,"#ffd966"); px(44,48,"#ffd966")
end)
----------------------------------------------------------- gorilla
pal("pl-wgor-6",{32,60,22,1},{{7,14},{58,10},{57,40}},function()
  sblob(22,57,6,3,2,R.dark); sblob(42,57,6,3,2,R.dark)
  sblob(32,44,16,14,2,R.dark,function(i,x,y) if y<37 and i<=3 then return R.grey[i+1] end end)
  sblob(32,50,9,7,2,{"#7a8098","#58607e","#4a5078","#3a3e66","#2f3258"})
  sblob(14,45,7,12,2,R.dark); sblob(50,45,7,12,2,R.dark)
  sblob(14,55,5,3,2,R.black); sblob(50,55,5,3,2,R.black)
  sblob(32,22,7,4,2,R.grey)
  sblob(32,26,10,9,2,R.dark)
  sblob(32,29,7,6,2,{"#9a8aa8","#7a6a88","#5a4a70","#4a3a5e","#3a2e4a"})
  eye(26,26,3,3); eye(35,26,3,3)
  line(25,24,29,25,"#2f2440",1); line(35,25,39,24,"#2f2440",1)
  px(31,30,"#2b1c26"); px(33,30,"#2b1c26")
  rect(30,33,34,33,"#2b1c26"); px(29,34,"#2b1c26"); px(35,34,"#2b1c26")
  px(23,26,"#9a8aa8"); px(41,26,"#9a8aa8")
  sblob(51,56,4,4,2,R.orange); px(50,54,"#ffe0a0"); px(51,51,"#3a8a52"); px(52,51,"#5fae4a")
  sblob(10,59,2,1,2,R.orange)
end)
----------------------------------------------------------- diver
pal("pl-wpea-6",{31,61,24,1},{{7,38},{57,6},{58,44}},function()
  sblob(32,59,27,3,2,R.blue,function(i,x,y) if i<=2 and H(x,y)<0.2 then return "#fffaf0" end end)
  sblob(32,56,23,3,2,R.wood,function(i,x,y) if x%7==0 then return R.wood[4] end end)
  local tl={"#8ae8d8","#4cc4b8","#2f9aa4","#2a7090","#2a4a7a"}
  sblob(18,43,4,8,2,tl)
  sblob(30,43,12,13,2,tl)
  rect(19,47,41,47,"#6b4030"); rect(19,47,41,47,"#6b4030"); rect(29,46,31,48,"#ffd966")
  sblob(41,50,4,4,2,R.brown); px(41,46,"#ffd966"); px(40,47,"#4a2f45")
  sblob(25,56,4,2,2,R.brown); sblob(35,56,4,2,2,R.brown)
  line(38,37,45,28,tl[3],4); line(39,36,44,29,tl[2],2)
  line(46,26,47,20,tl[3],4)
  sblob(47,18,3,3,2,R.skin)
  sblob(48,11,4,4,2,{"#fffaf0","#f6ecd8","#e8d4e4","#c8b4d8","#8a7aa8"}); px(46,9,"#fffbe8"); px(47,9,"#fffbe8"); px(46,10,"#fffbe8")
  sblob(30,21,10,8,2,tl)
  sblob(30,26,7,6,2,R.skin)
  poly({{22,30},{38,30},{35,40},{30,44},{25,40}},R.cream)
  rect(20,23,40,23,"#7a5a34")
  for _,cx in ipairs{25,35} do sblob(cx,24,4,4,2,R.yellow); sblob(cx,24,3,3,2,{"#e8faff","#a8e0f8","#7ac0ea","#4a8ad0","#3a5aa8"}); px(cx,25,"#2b1c26"); px(cx,24,"#2b1c26"); px(cx-1,23,"#fffbe8") end
  px(29,33,"#e8a0a0"); px(30,33,"#e8a0a0")
end)
