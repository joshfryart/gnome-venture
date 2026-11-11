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
----------------------------------------------------------- stonehead
pal("pl-wsto-6",{32,60,18,1},{{7,14},{57,10},{58,40}},function()
  sblob(32,54,17,5,2,R.grey)
  sblob(32,35,14,19,3,R.grey,function(i,x,y) if H(x,y)<0.07 and i<=4 then return R.grey[i+1] end end)
  for _,p in ipairs{{20,28},{21,29},{21,30},{22,31},{42,40},{41,41},{41,42},{40,43}} do px(p[1],p[2],"#707a9c") end
  for _,p in ipairs{{22,40},{23,40},{22,41},{42,26},{43,26},{43,27}} do px(p[1],p[2],"#5fae4a") end
  px(22,40,"#8fd05a")
  eye(23,31,5,5)
  for _,p in ipairs{{36,33},{37,32},{38,32},{39,32},{40,33}} do px(p[1],p[2],"#2b1c26") end
  rect(21,38,23,39,"#f5a0b8"); rect(40,38,42,39,"#f5a0b8")
  rect(31,34,32,40,"#9aa4be"); rect(32,34,33,40,"#707a9c")
  rect(27,44,36,44,"#2b1c26"); sblob(33,47,2,3,2,R.yellow); px(33,46,"#fffbe8")
  sblob(33,53,2,2,2,R.yellow); sblob(22,56,2,2,2,R.yellow); sblob(44,56,2,2,2,R.yellow)
  sblob(32,16,12,5,2,R.red); sblob(32,13,8,4,2,R.red)
  rect(21,19,43,20,"#3a8a52"); rect(21,19,43,19,"#8fd05a")
  px(30,11,"#ff9a80"); px(31,10,"#ff9a80")
end)
----------------------------------------------------------- zebra
pal("pl-migr-6",{33,60,24,1},{{7,12},{58,12},{57,36}},function()
  local bl={"#6a5a8a","#4a3e6a","#382e56","#2b2244","#2b1c26"}
  local function st(i,x,y) if ((x+(y//3))%5)<2 then return bl[i] end end
  line(55,40,59,50,"#2b2244",2); sblob(59,52,2,3,2,bl)
  sblob(51,55,2,3,2,R.cream,st)
  box(46,50,49,58,R.cream); box(47,50,49,58,R.cream); box(26,51,29,58,R.cream)
  for y=50,58 do if y%3==0 then rect(46,y,49,y,bl[3]); rect(26,y,29,y,bl[3]) end end
  rect(46,58,49,58,"#2b1c26"); rect(26,58,29,58,"#2b1c26")
  sblob(38,44,17,11,2,R.cream,st)
  -- raised front leg
  box(36,50,39,55,R.cream); rect(36,55,39,56,"#2b1c26"); rect(36,52,39,52,bl[3])
  sblob(30,36,7,8,2,R.cream,st)
  poly({{22,19},{29,21},{35,34},{29,37}},bl)
  sblob(20,30,11,10,2,R.cream,st)
  poly({{13,24},{14,13},{20,20}},bl); poly({{21,19},{27,12},{29,22}},bl); px(15,17,"#f5a0b8"); px(16,18,"#f5a0b8")
  sblob(12,37,6,5,2,{"#9a9ac0","#7a7aa8","#5a5a88","#43406e","#2b2244"})
  px(10,36,"#2b1c26"); px(13,36,"#2b1c26"); px(11,40,"#2b1c26"); px(12,40,"#2b1c26"); px(13,40,"#2b1c26")
  sblob(17,29,4,4,2,R.cream); sblob(25,29,4,4,2,R.cream)
  eye(15,27,4,5); eye(23,27,4,5)
  px(19,36,"#f5a0b8"); px(27,36,"#f5a0b8")
  sblob(5,59,3,2,2,R.cream); sblob(10,60,3,1,2,R.grey); sblob(58,59,2,1,2,R.grey)
end)
----------------------------------------------------------- merchant
pal("pl-silk-6",{32,61,20,1},{{8,16},{57,12},{58,36}},function()
  sblob(26,59,4,2,2,R.brown); sblob(38,59,4,2,2,R.brown)
  poly({{25,37},{39,37},{53,58},{11,58}},R.pink,function(i,x,y) if y>=52 and y<=53 then return R.yellow[i<=2 and 2 or 3] end end)
  sblob(51,49,5,5,2,R.yellow); rect(49,43,53,44,"#8f5a38"); px(50,43,"#d9a066"); rect(49,48,50,49,"#fff0a0"); px(52,51,"#b8803a")
  line(40,44,46,48,"#e8688f",3); sblob(46,48,3,3,2,R.skin)
  sblob(32,31,8,7,2,R.skin)
  sblob(32,34,3,2,2,{"#ffc0a0","#ff9a80","#e87a70","#b84a5a","#7a3a5a"})
  poly({{24,35},{40,35},{38,44},{32,53},{26,44}},R.cream)
  eye(27,28,3,4); eye(34,28,3,4)
  line(26,26,29,27,"#f6ecd8",1); line(35,27,38,26,"#f6ecd8",1)
  px(29,38,"#dcccc4"); px(35,38,"#dcccc4")
  sblob(32,27,13,3,2,R.purple)
  poly({{22,27},{29,13},{39,5},{45,8},{40,13},{42,27}},R.purple)
  rect(22,25,42,26,"#ffd966"); sblob(45,7,2,2,2,R.yellow)
  px(30,20,"#ffe98a"); px(35,15,"#ffe98a"); px(37,22,"#ffe98a")
  px(23,48,"#ffd966"); px(24,49,"#ffd966")
end)
----------------------------------------------------------- gatecat
pal("pl-gate-6",{32,60,17,1},{{7,14},{57,10},{58,40}},function()
  sblob(47,53,3,6,2,R.cream); sblob(45,57,4,2,2,R.cream)
  sblob(32,47,11,12,2,R.cream)
  sblob(26,57,4,3,2,R.cream); sblob(38,57,4,3,2,R.cream)
  poly({{18,23},{19,7},{29,17}},R.cream); poly({{35,17},{45,7},{46,23}},R.cream)
  poly({{21,19},{21,12},{27,17}},R.pink); poly({{37,17},{43,12},{43,19}},R.pink)
  sblob(32,28,15,12,2,R.cream)
  for _,p in ipairs{{29,18},{29,19},{32,16},{32,17},{32,18},{35,18},{35,19},{18,26},{19,27},{46,26},{45,27}} do px(p[1],p[2],"#a898b8") end
  eye(23,25,5,6); eye(36,25,5,6)
  rect(31,32,32,32,"#e8688f"); px(31,33,"#2b1c26"); px(32,33,"#2b1c26"); px(29,34,"#2b1c26"); px(30,34,"#2b1c26"); px(33,34,"#2b1c26"); px(34,34,"#2b1c26")
  line(12,31,19,32,"#b4a4c0",1); line(12,35,19,34,"#b4a4c0",1); line(45,32,52,31,"#b4a4c0",1); line(45,34,52,35,"#b4a4c0",1)
  rect(24,38,40,40,"#c0332f"); rect(24,38,40,38,"#ff7a5a"); rect(24,40,40,40,"#8a2a40")
  sblob(32,43,3,3,2,R.yellow); px(32,43,"#7a5a7a"); px(31,42,"#fffbe8")
  poly({{29,17},{32,9},{36,11},{35,16}},R.green); line(32,15,34,11,"#3a8a52",1)
end)
