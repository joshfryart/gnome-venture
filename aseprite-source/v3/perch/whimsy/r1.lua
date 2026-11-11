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
local olive={"#c8e07a","#9cc860","#6ea24a","#487a48","#35507a"}
----------------------------------------------------------- cocopaddle
pal("ss-cocopaddle",{32,60,17,1},{{9,12},{56,7},{58,36}},function()
  sblob(32,56,25,4,2,R.blue,function(i,x,y) if i<=2 and H(x,y)<0.15 then return "#fffaf0" end end)
  -- paddle behind hull
  line(47,38,54,52,"#8f5a38",2); line(47,38,47,38,"#b87a45",1)
  poly({{51,50},{58,52},{56,58},{49,56}},R.wood)
  CL=function(x,y) return y>=41 end
  sblob(32,43,20,14,2,R.brown,function(i,x,y) if (x%5==0 and i>=2 and i<=4) then return R.brown[i+1] end if i==1 and H(x,y)<.3 then return R.brown[2] end end)
  CL=nil
  sblob(32,41,20,4,2,R.brown)
  sblob(32,41,17,3,2,R.cream)
  rect(15,41,17,41,"#fffaf0")
  box(31,8,32,41,R.wood)
  poly({{33,11},{33,36},{51,36}},R.cream)
  for k,_ in pairs(M) do local y,x=k:match("(%-?%d+),(%-?%d+)") y=tonumber(y) x=tonumber(x) if y%5==0 then px(x,y,(x>40) and "#c0689a" or "#f08aa8") end end
  poly({{31,5},{31,10},{41,7.5}},R.red)
  for _,p in ipairs{{39,26},{41,26},{38,27},{39,27},{40,27},{41,27},{42,27},{39,28},{40,28},{41,28},{40,29}} do px(p[1],p[2],"#e8523f") end
  px(39,26,"#ff9a80")
  eye(21,46,4,5); eye(37,46,4,5)
  rect(29,52,34,52,"#2b1c26"); px(28,51,"#2b1c26"); px(35,51,"#2b1c26"); rect(30,53,33,53,"#c0332f")
  px(19,51,"#f08aa8"); px(20,51,"#f08aa8"); px(42,51,"#f08aa8"); px(43,51,"#f08aa8")
end)
----------------------------------------------------------- mirage moon
pal("dw-mirage-moon",{32,60,19,1},{{8,10},{57,12},{59,40}},function()
  poly({{12,51},{52,51},{57,58},{7,58}},R.red,function(i,x,y)
    if y==54 then return (x%4<2) and "#ffd966" or "#b04880" end
    if y==56 and x%2==0 then return "#fff0a0" end end)
  for x=8,56,2 do px(x,59,"#ffd966") end
  blobf(function(x,y) return ((x-30)^2+(y-32)^2<=400) and ((x-43)^2+(y-28)^2>200) end,30,32,20,20,R.yellow,function(i,x,y)
    if (x==17 and y==40) or (x==20 and y==44) or (x==36 and y==49) then return R.yellow[4] end
    if (x==16 and y==40) or (x==19 and y==44) then return R.yellow[3] end end)
  eye(14,30,4,5)
  for _,p in ipairs{{21,33},{22,32},{23,31},{24,31},{25,32},{26,33}} do px(p[1],p[2],"#2b1c26") end
  rect(14,36,16,36,"#f5a0b8"); rect(24,36,26,36,"#f5a0b8")
  px(19,37,"#2b1c26"); px(20,38,"#2b1c26"); px(21,38,"#2b1c26"); px(22,37,"#2b1c26")
  px(47,45,"#e8b040"); px(46,46,"#b8803a")
end)
----------------------------------------------------------- bill brolly
pal("mt-bill-brolly",{31,60,13,1},{{7,48},{58,6},{57,32}},function()
  line(37,13,40,44,"#3a8a52",2); line(37,13,37,30,"#5fae4a",1)
  poly({{39,44},{55,48},{54,56},{38,52}},R.black)
  rect(46,50,54,51,"#fffaf0"); rect(46,53,53,54,"#fffaf0")
  rect(25,55,28,58,"#e87a2a"); rect(34,55,37,58,"#e87a2a"); rect(25,55,28,55,"#ffc870"); rect(34,55,37,55,"#ffc870")
  sblob(31,46,12,11,2,R.black)
  sblob(30,50,7,6,2,R.cream)
  sblob(26,31,10,9,2,R.black)
  -- beak
  poly({{20,22},{5,34},{9,39},{20,41}},R.yellow)
  line(9,38,21,40,"#b8803a",1)
  poly({{19,20},{9,27},{6,33},{15,29},{21,27}},R.orange)
  px(7,34,"#2b1c26")
  sblob(26,28,5,5,2,R.cream); eye(24,26,4,5)
  sblob(34,29,3,4,2,R.cream); eye(33,28,3,4)
  px(22,33,"#2b1c26")
  -- leaf umbrella
  CL=function(x,y) return y<=14 end
  sblob(38,14,20,10,2,R.green)
  CL=nil
  for _,i in ipairs{-14,-7,0,7,14} do line(38,14,38+i,6+math.abs(i)*0.2,"#3a8a52",1) end
  px(40,7,"#b4e873"); px(41,7,"#b4e873")
  -- frog
  sblob(49,54,6,5,2,R.green)
  sblob(46,48,2,2,2,R.green); sblob(52,48,2,2,2,R.green)
  px(46,48,"#2b1c26"); px(52,48,"#2b1c26"); px(45,47,"#fff6e0"); px(51,47,"#fff6e0")
  rect(47,55,51,55,"#2b1c26"); rect(48,56,50,56,"#c0332f")
end)
----------------------------------------------------------- mossback monitor
pal("pl-dlz-6",{32,60,19,1},{{8,14},{57,10},{58,52}},function()
  for _,b in ipairs{{47,50,6,5},{52,45,5,4},{55,40,4,4},{55,35,3,3},{53,31,2,2}} do sblob(b[1],b[2],b[3],b[4],2,olive) end
  sblob(17,51,4,4,2,olive); sblob(47,51,4,4,2,olive)
  sblob(32,46,17,10,3,olive,function(i,x,y) if i>=2 and i<=4 and x%4==0 and (y%3~=0) then return olive[i+1] end end)
  sblob(32,51,10,5,2,{"#fff0a0","#ffe08a","#e8c868","#b89a5a","#7a6a7a"})
  for x=26,38,3 do px(x,50,"#b89a5a"); px(x,53,"#b89a5a") end
  sblob(22,56,5,3,2,olive); sblob(42,56,5,3,2,olive)
  for _,x in ipairs{19,22,25,39,42,45} do px(x,58,"#35507a") end
  sblob(31,32,11,9,2,olive)
  -- moss tuft with flower
  sblob(39,39,4,2,2,{"#d8ff9a","#b4e873","#8fd05a","#5fae4a","#3a8a52"})
  px(40,37,"#ff9ab8"); px(41,37,"#ff9ab8"); px(40,36,"#fff6e0")
  eye(23,28,4,5); eye(31,28,4,5)
  px(27,34,"#35507a"); px(31,34,"#35507a")
  rect(25,38,33,38,"#2b1c26"); px(24,37,"#2b1c26"); px(34,37,"#2b1c26")
  rect(29,39,29,42,"#e8523f"); px(28,43,"#e8523f"); px(30,43,"#e8523f")
  px(22,35,"#f5a0b8"); px(23,35,"#f5a0b8")
end)
----------------------------------------------------------- lotus perch
pal("pl-jdf-6",{32,61,22,1},{{7,28},{58,22},{57,44}},function()
  sblob(32,55,26,6,2,R.green,function(i,x,y) if i<=3 and (x*3+y)%11==0 then return olive[i+1] end end)
  rect(30,50,34,60,"#35507a")
  local function petal(cx,by,w,h,tilt)
    poly({{cx-w,by},{cx-w*0.9+tilt*0.3,by-h*0.55},{cx+tilt,by-h},{cx+w*0.9+tilt*0.3,by-h*0.55},{cx+w,by}},R.pink)
    line(cx,by-3,cx+tilt*0.9,by-h+5,"#e8688f",1)
  end
  petal(21,52,9,28,-5); petal(43,52,9,28,5)
  petal(32,50,9,34,0)
  petal(25,55,10,24,-2); petal(40,55,10,24,2)
  -- face on front petals
  for _,p in ipairs{{23,44},{24,43},{25,43},{26,44}} do px(p[1],p[2],"#2b1c26") end
  for _,p in ipairs{{37,44},{38,43},{39,43},{40,44}} do px(p[1],p[2],"#2b1c26") end
  rect(21,46,23,46,"#ff9ab8"); rect(40,46,42,46,"#ff9ab8")
  px(30,47,"#2b1c26"); px(31,48,"#2b1c26"); px(32,48,"#2b1c26"); px(33,47,"#2b1c26")
  -- dragonfly nap
  rect(36,12,47,13,"#3aa8a8"); rect(36,12,47,12,"#5ccfc0"); px(47,13,"#2a7a90"); rect(40,12,40,13,"#2a7a90"); rect(44,12,44,13,"#2a7a90")
  poly({{26,12},{14,7},{15,13},{27,14}},{"#fffaf0","#eef9fc","#cfe6f2","#a8cce0","#7aa4d0"})
  poly({{30,11},{22,3},{29,5},{33,10}},{"#fffaf0","#eef9fc","#cfe6f2","#a8cce0","#7aa4d0"})
  line(15,10,26,13,"#6a8ab8",1)
  sblob(32,12,5,4,2,R.teal)
  px(29,12,"#2b1c26"); px(30,13,"#2b1c26"); px(31,13,"#2b1c26"); px(32,12,"#2b1c26")
  px(34,12,"#2b1c26"); px(35,13,"#2b1c26")
  for _,p in ipairs{{44,6},{45,6},{46,6},{45,7},{44,8},{45,8},{46,8}} do px(p[1],p[2],"#a8cce0") end
end)
