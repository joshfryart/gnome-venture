-- Parameterised Puzzle Pal perch generator. Reads a Lua table file (params.lua, from build_params.py).
-- --script-param out=<dir>/  data=<params.lua>  [only=key1,key2]  [aseprite=1]
local out = app.params.out or "./"
local DATA = app.params.data or "params.lua"
local ONLY = nil
if app.params.only and app.params.only ~= "" then ONLY = {} for k in app.params.only:gmatch("[^,]+") do ONLY[k] = true end end
local SAVE_ASE = app.params.aseprite == "1"

local INK = Color{r=0x2b,g=0x1c,b=0x26}
local function hex(h) h=h:gsub("#","") return Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16)} end
local img, M, BODY, KN
local SH = function(y) return 0 end
local REC = false
local function px(x,y,c)
  x = x + SH(y)
  if x>=0 and y>=0 and x<64 and y<64 then
    img:putPixel(x,y,type(c)=="string" and hex(c) or c)
    if REC then BODY[y..","..x]=true end
  end
end
local function rect(x0,y0,x1,y1,c) for y=y0,y1 do for x=x0,x1 do px(x,y,c) end end end
local function H(x,y) return (math.sin(x*12.9898+y*78.233)*43758.5453)%1 end
local function inM(x,y,k) k=k or 0 return M[y..","..x] and M[y..","..(x-k)] and M[y..","..(x+k)] and M[(y-k)..","..x] and M[(y+k)..","..x] end

-- squircle body lit upper-left; r = {hl,lit,mid,shade,deep}
local function sblob(cx,cy,rx,ry,pw,r,tex)
  M={}
  for y=math.floor(cy-ry),math.ceil(cy+ry) do for x=math.floor(cx-rx),math.ceil(cx+rx) do
    local dx,dy=(x-cx+0.5)/rx,(y-cy+0.5)/ry
    local d=(math.abs(dx)^pw+math.abs(dy)^pw)^(1/pw)
    if d<=1 then
      M[y..","..x]=true
      local l=-0.55*dx-0.75*dy-0.55*d*d*d
      local i= l>0.5 and 1 or (l>0.1 and 2 or (l>-0.35 and 3 or (l>-0.75 and 4 or 5)))
      px(x,y,(tex and tex(i,x,y)) or r[i]) end end end
end
-- accessory blob: does not disturb the body mask
local function blob(cx,cy,rx,ry,pw,r,tex) local o=M sblob(cx,cy,rx,ry,pw,r,tex) M=o end
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
local function sparkle(x,y) local s=SH SH=function() return 0 end for _,d in ipairs{{0,0},{1,0},{-1,0},{0,1},{0,-1}} do px(x+d[1],y+d[2],"#ffe98a") end px(x,y,"#fffbe8") SH=s end
local function twinkle(x,y) local s=SH SH=function() return 0 end px(x,y,"#fffbe8") px(x,y-1,"#ffe98a") px(x,y+1,"#ffe98a") SH=s end
local function ring(cx,cy,r0,r1,fn) for y=cy-6,cy+6 do for x=cx-6,cx+6 do local d=math.sqrt((x-cx)^2+(y-cy)^2) if d>=r0 and d<=r1 then px(x,y,fn(x-cx,y-cy)) end end end end
local E="#2b1c26"
local CR="#fff6e0"

----------------------------------------------------------------- faces
local function eyeRound(x,y) rect(x,y,x+4,y+4,E) rect(x+1,y+1,x+2,y+2,CR) px(x+3,y+3,"#d8c8f0") px(x+1,y+4,"#6a4a7a") end
local function eyeDot(x,y) rect(x+1,y+1,x+3,y+4,E) px(x+1,y+1,CR) px(x+3,y+4,"#6a4a7a") end
local function eyeHappy(x,y) px(x,y+3,E) px(x+1,y+2,E) px(x+2,y+1,E) px(x+3,y+2,E) px(x+4,y+3,E) px(x+2,y+2,E) end
local function eyeClosed(x,y) px(x,y+2,E) px(x+1,y+3,E) px(x+2,y+3,E) px(x+3,y+3,E) px(x+4,y+2,E) end
local function eyeWide(x,y) rect(x,y,x+4,y+5,CR) rect(x+1,y+1,x+3,y+4,E) px(x+1,y+1,CR) px(x+3,y+3,"#6a4a7a") end
local function eyeWink(x,y) eyeClosed(x,y) end
local EYEF={round=eyeRound,dot=eyeDot,happy=eyeHappy,closed=eyeClosed,wide=eyeWide,sharp=eyeRound,wink=eyeRound}
local function mouth(t,mx,my)
  if t=="smile" then px(mx,my,E) px(mx+4,my,E) rect(mx+1,my+1,mx+3,my+1,E)
  elseif t=="open" then rect(mx,my,mx+4,my,E) rect(mx,my+1,mx+4,my+1,"#c0392b") rect(mx+1,my+2,mx+3,my+2,"#7a2a3a") px(mx,my+1,E) px(mx+4,my+1,E)
  elseif t=="flat" then rect(mx+1,my,mx+3,my,E)
  elseif t=="cat" then px(mx,my,E) px(mx+1,my+1,E) px(mx+2,my,E) px(mx+3,my+1,E) px(mx+4,my,E)
  elseif t=="tongue" then px(mx,my,E) px(mx+4,my,E) rect(mx+1,my+1,mx+3,my+1,E) rect(mx+2,my+2,mx+3,my+2,"#f08aa0")
  elseif t=="o" then rect(mx+1,my,mx+2,my+1,E) px(mx+1,my,"#7a2a3a")
  else rect(mx,my,mx+4,my+1,E) rect(mx+1,my,mx+3,my,CR) end -- grin
end

----------------------------------------------------------------- hats (hx centre, b brim row, w half width, a accent ramp)
local GOLD={"#fff0a0","#ffd84a","#e8b030","#b07a1c","#7a4e1a"}
local GREEN={"#c8f08a","#8fd05a","#5fae4a","#3f8a4a","#35507a"}
local STRAW={"#f6dc92","#e8c870","#d0a24a","#a8773a","#7a5034"}
local WOOD={"#c9a068","#9a6a45","#7a4e32","#5b3a2c","#43292a"}
local STEEL={"#eef2f8","#c8d0e0","#9aa4c0","#707a9c","#4e5478"}
local WHITE={"#fff6e0","#f0e8dc","#d8d0e0","#b8b0cc","#9890b4"}
local function band(y0,y1,a,w) for y=y0,y1 do for x=31-w-2,31+w+2 do if M[y..","..x] then px(x,y,(y==y0) and a[1] or ((y==y1) and a[4] or a[2])) end end end end
local function flower(x,y,pr,ctr) px(x,y-1,pr) px(x-1,y,pr) px(x+1,y,pr) px(x,y+1,pr) px(x,y,ctr or "#ffd84a") end
local function leaf(x,y,h) -- small leaf pointing up
  rect(x,y,x+2,y+h,GREEN[3]) rect(x,y,x,y+h,GREEN[2]) rect(x+2,y,x+2,y+h,GREEN[4]) px(x+1,y-1,GREEN[2]) px(x+1,y+1,GREEN[1]) end
local HAT={}
function HAT.mushroom(hx,b,w,a)
  blob(hx,b-7,w+3,9,2,a) rect(hx-w-3,b-2,hx+w+3,b,a[4]) rect(hx-w-2,b-2,hx+w+2,b-2,a[3]) rect(hx-w-3,b,hx+w+3,b,a[5])
  for _,p in ipairs{{-8,-12,2},{0,-14,2},{8,-10,1},{-3,-7,1},{5,-6,1},{-11,-6,1}} do rect(hx+p[1],b+p[2],hx+p[1]+p[3],b+p[2]+p[3]-(p[3]>1 and 0 or 1),"#fff1d6") end end
function HAT.crown(hx,b,w,a)
  rect(hx-8,b-3,hx+8,b,GOLD[3]) rect(hx-8,b-3,hx+8,b-3,GOLD[1]) rect(hx-8,b,hx+8,b,GOLD[4])
  for i=0,4 do local x=hx-8+i*4 local t=(i%2==0) and 7 or 5 rect(x,b-t,x+1,b-4,GOLD[2]) px(x,b-t,GOLD[1]) px(x+1,b-t-1,GOLD[1]) end
  px(hx,b-2,a[2]) px(hx-4,b-2,"#ff6a6a") px(hx+4,b-2,"#6ac8ff") end
function HAT.wizard(hx,b,w,a)
  for y=0,15 do local hw=math.max(1,math.floor((w+1)*(1-y/16)+0.5)) local ox=math.floor(y*y/60) rect(hx-hw+ox-0,b-y-1,hx+hw+ox-1,b-y-1,(y>8 and a[2]) or a[3]) px(hx-hw+ox,b-y-1,a[1]) px(hx+hw+ox-1,b-y-1,a[4]) end
  rect(hx-w-3,b-2,hx+w+2,b,a[3]) rect(hx-w-3,b-2,hx+w+2,b-2,a[2]) rect(hx-w-3,b,hx+w+2,b,a[5])
  px(hx-1,b-6,"#ffe98a") px(hx-2,b-6,"#ffe98a") px(hx-1,b-7,"#ffe98a") px(hx+3,b-10,"#ffe98a") end
function HAT.chefhat(hx,b,w,a)
  blob(hx-5,b-8,5,5,2,WHITE) blob(hx+5,b-8,5,5,2,WHITE) blob(hx,b-10,6,5,2,WHITE)
  rect(hx-8,b-4,hx+8,b,WHITE[2]) rect(hx-8,b-4,hx+8,b-4,WHITE[1]) rect(hx-8,b,hx+8,b,WHITE[4]) rect(hx+4,b-3,hx+8,b-1,WHITE[3]) end
function HAT.minerhat(hx,b,w,a)
  local Y={"#fff0a0","#ffd84a","#e8b030","#b07a1c","#7a4e1a"}
  blob(hx,b-3,w-1,6,2,Y) rect(hx-w-1,b-1,hx+w,b,Y[3]) rect(hx-w-1,b,hx+w,b,Y[4])
  rect(hx-2,b-8,hx+2,b-5,STEEL[3]) rect(hx-2,b-8,hx+2,b-8,STEEL[1]) px(hx,b-7,"#fffbe8") px(hx-1,b-7,"#ffe98a") px(hx+1,b-7,"#ffe98a") px(hx,b-9,"#ffe98a") end
function HAT.tuft(hx,b,w,a)
  band(b,b+3,a,w)
  for i,x in ipairs{hx-12,hx-7,hx-2,hx+3,hx+8} do local h=(i==3) and 11 or ((i%2==1) and 8 or 9)
    rect(x,b-1-h,x+3,b-1,"#c58a3a") rect(x,b-1-h,x,b-1,"#e8b84a") rect(x+3,b-1-h,x+3,b-1,"#8a5a34")
    for yy=b-h,b-2,2 do px(x+1,yy,"#7a4e32") px(x+2,yy+1,"#e8b84a") end px(x+1,b-2-h,"#e8b84a") end
  rect(hx-14,b-1,hx+13,b-1,"#8a5a34") end
function HAT.straw(hx,b,w,a)
  blob(hx,b-5,w-2,6,2,STRAW) rect(hx-w-5,b-2,hx+w+4,b,STRAW[3]) rect(hx-w-5,b-2,hx+w+4,b-2,STRAW[1]) rect(hx-w-5,b,hx+w+4,b,STRAW[5])
  rect(hx-w+2,b-4,hx+w-3,b-3,a[3]) rect(hx-w+2,b-4,hx+w-3,b-4,a[1])
  for x=hx-w-4,hx+w+3,3 do px(x,b-1,STRAW[4]) end end
function HAT.acorncap(hx,b,w,a)
  blob(hx,b-3,w-2,5,2,WOOD,function(i,x,y) if (x+y)%3==0 and i<5 then return WOOD[math.min(5,i+1)] end end)
  rect(hx-w+1,b-2,hx+w-2,b-1,WOOD[4]) px(hx,b-9,WOOD[3]) px(hx,b-8,WOOD[2]) rect(hx-1,b-8,hx+1,b-8,WOOD[3]) end
function HAT.leafcrown(hx,b,w,a)
  band(b,b+1,GREEN,w)
  for i=-3,3 do leaf(hx+i*4-1,b-3-(3-math.abs(i))//2,3) end
  px(hx-8,b-3,"#ff8a8a") px(hx+7,b-4,"#ffe98a") end
function HAT.flowercrown(hx,b,w,a)
  band(b,b+1,GREEN,w)
  for _,p in ipairs{{-8,"#ffffff"},{-1,a[2]},{7,"#ff9ab8"}} do flower(hx+p[1],b-2,p[2],"#ffd84a") end
  leaf(hx-5,b-4,2) leaf(hx+3,b-4,2) end
function HAT.feather(hx,b,w,a)
  band(b,b+2,a,w)
  local x0=hx+w-3
  for k=0,13 do local x=x0+k//5 local y=b-k px(x,y,a[4]) local vw=math.min(3,k//2+1,(13-k)//2+1) for d=1,vw do px(x-d,y,a[2]) px(x+d,y,(d==vw) and a[3] or a[1]) end end end
function HAT.tophat(hx,b,w,a)
  local T={"#6a5a80","#4e4066","#3a2c52","#2e2242","#241a36"}
  rect(hx-6,b-12,hx+6,b-2,T[3]) rect(hx-6,b-12,hx-5,b-2,T[1]) rect(hx+5,b-12,hx+6,b-2,T[4]) rect(hx-6,b-12,hx+6,b-12,T[2])
  rect(hx-6,b-5,hx+6,b-3,a[3]) rect(hx-6,b-5,hx+6,b-5,a[1])
  rect(hx-10,b-1,hx+10,b,T[2]) rect(hx-10,b,hx+10,b,T[4]) end
function HAT.snowcap(hx,b,w,a)
  blob(hx,b-2,w-1,7,2,a) rect(hx-w,b-1,hx+w-1,b+1,a[1]) rect(hx-w,b+1,hx+w-1,b+1,a[3])
  for x=hx-w+1,hx+w-2,2 do px(x,b,a[2]) end
  blob(hx,b-9,3,3,2,WHITE) end
function HAT.conehat(hx,b,w,a)
  for y=0,9 do local hw=math.floor((w+5)*(1-y/11)+0.5) rect(hx-hw,b-y,hx+hw-1,b-y,(y%3==2) and STRAW[4] or STRAW[3]) px(hx-hw,b-y,STRAW[1]) px(hx+hw-1,b-y,STRAW[5]) end
  rect(hx-1,b-11,hx,b-10,STRAW[2]) rect(hx-w-5,b,hx+w+4,b,STRAW[5]) px(hx-w+1,b+1,a[3]) end
function HAT.fez(hx,b,w,a)
  local R={"#ff9a70","#e8503a","#c0392b","#8a2a3a","#5a1a3a"}
  for y=0,8 do local hw=7-y//4 rect(hx-hw,b-y-1,hx+hw,b-y-1,R[3]) px(hx-hw,b-y-1,R[2]) px(hx+hw,b-y-1,R[4]) end
  rect(hx-6,b-10,hx+6,b-10,R[4]) rect(hx-7,b,hx+7,b,R[4]) rect(hx-1,b-9,hx+1,b-9,R[2])
  for y=b-9,b-1 do px(hx+7+(y>b-5 and 1 or 0),y,"#ffd84a") end px(hx+8,b,"#b07a1c") px(hx+8,b+1,"#ffd84a") end
function HAT.antlers(hx,b,w,a)
  for _,s in ipairs{-1,1} do local x=hx+s*(w-4) for k=0,10 do px(x+s*(k//3),b-1-k,WOOD[2]) px(x+s*(k//3)+1,b-1-k,WOOD[3]) end
    for k=0,3 do px(x+s*(3+k),b-6-k,WOOD[2]) end px(x+s*7,b-10,WOOD[1]) px(x+s*4,b-12,WOOD[1]) px(x+s*3,b-11,WOOD[2]) px(x+s*2,b-12,WOOD[2]) end end
function HAT.helmet(hx,b,w,a)
  blob(hx,b-3,w+1,7,2,STEEL) rect(hx-w-1,b-1,hx+w,b+1,STEEL[4]) rect(hx-w-1,b-1,hx+w,b-1,STEEL[2]) rect(hx-w-1,b+1,hx+w,b+1,STEEL[5])
  rect(hx-1,b-9,hx,b-1,STEEL[2]) px(hx-4,b-1,STEEL[1]) px(hx+3,b-1,STEEL[1]) rect(hx-1,b-12,hx,b-9,a[2]) px(hx-1,b-13,a[1]) end
function HAT.bow(hx,b,w,a)
  local x=hx+w-7
  blob(x-4,b-3,4,3,2,a) blob(x+4,b-3,4,3,2,a) rect(x-1,b-5,x+1,b-1,a[4]) px(x-1,b-5,a[2]) end
function HAT.ears(hx,b,w,a)
  for _,s in ipairs{-1,1} do local x=hx+s*(w-3) blob(x,b-3,4,4,2,a) blob(x,b-2,2,2,2,{"#ffc8d8","#ffb0c4","#f08aa0","#d06a86","#a04a6a"}) end end
function HAT.bucket(hx,b,w,a)
  for y=0,5 do rect(hx-w+2+y//3-0,b-y-1,hx+w-3-y//3,b-y-1,(y%2==0) and a[3] or a[2]) end
  rect(hx-w+2,b-6,hx+w-3,b-6,a[1]) rect(hx-w-2,b-1,hx+w+1,b+1,a[3]) rect(hx-w-2,b-1,hx+w+1,b-1,a[2]) rect(hx-w-2,b+1,hx+w+1,b+1,a[5])
  rect(hx-w+2,b-3,hx+w-3,b-3,a[4]) end
function HAT.flame(hx,b,w,a)
  local F={"#fff0a0","#ffd84a","#ff9a30","#e8502a","#a8323f"}
  blob(hx,b-5,5,6,2,F) blob(hx-6,b-3,3,4,2,F) blob(hx+6,b-3,3,4,2,F)
  px(hx,b-12,F[3]) px(hx,b-13,F[2]) px(hx-1,b-11,F[3]) px(hx+1,b-11,F[3]) rect(hx-1,b-6,hx+1,b-4,F[1]) end
function HAT.sprout(hx,b,w,a)
  rect(hx,b-6,hx+1,b-1,GREEN[3]) px(hx,b-6,GREEN[2])
  blob(hx-4,b-8,4,3,2,GREEN) blob(hx+5,b-9,4,3,2,GREEN) px(hx+1,b-9,GREEN[2]) end
function HAT.bandana(hx,b,w,a)
  band(b,b+3,a,w) for x=hx-w,hx+w,3 do if M[(b+2)..","..x] then px(x,b+2,a[1]) end end
  local x=hx+w+1 rect(x,b+1,x+2,b+7,a[3]) rect(x+1,b+3,x+3,b+9,a[4]) px(x,b+1,a[2]) end
function HAT.fruit(hx,b,w,a)
  for _,s in ipairs{-1,1} do local x=hx+s*4 for k=0,5 do px(x-s*(k//2)+s,b-1-k,GREEN[4]) end blob(x+s,b-1,3,3,2,a) px(x+s-1,b-3,a[1]) end
  leaf(hx-1,b-9,2) end
function HAT.beret(hx,b,w,a)
  blob(hx+1,b-3,w+1,5,2,a) rect(hx-w+1,b-1,hx+w,b,a[4]) px(hx+2,b-9,a[4]) px(hx+2,b-8,a[3]) px(hx-3,b-6,a[1]) px(hx-4,b-5,a[1]) end
function HAT.beanie(hx,b,w,a)
  blob(hx,b-3,w-1,7,2,a) rect(hx-w,b-1,hx+w-1,b+1,a[2]) rect(hx-w,b+1,hx+w-1,b+1,a[4]) rect(hx-w,b-1,hx+w-1,b-1,a[1])
  for x=hx-w+1,hx+w-2,2 do px(x,b,a[3]) end blob(hx,b-10,3,3,2,a) end

----------------------------------------------------------------- face accessories (cx eye geometry: ex1,ex2 = eye x, fy = eye y)
local FACE={}
function FACE.glasses(x1,x2,fy)
  local function lens(cx,cy) ring(cx,cy,3.3,4.6,function(dx,dy) if dx+dy<=-3 then return GOLD[1] elseif dx+dy>=3 then return "#a86a1c" else return "#d99a32" end end)
    px(cx-3,cy-2,"#fffbe8") px(cx+2,cy+1,"#cfe8f4") end
  lens(x1+2,fy+2) lens(x2+2,fy+2) rect(x1+6,fy+1,x2-2,fy+1,"#d99a32") end
function FACE.monocle(x1,x2,fy)
  ring(x2+2,fy+2,3.3,4.6,function(dx,dy) return (dx+dy<=-2) and GOLD[1] or "#d99a32" end) px(x2+5,fy+5,"#fffbe8")
  for k=0,6 do px(x2+6,fy+5+k,"#d99a32") end end
function FACE.eyepatch(x1,x2,fy)
  rect(x1-1,fy-1,x1+5,fy+5,"#3a2c46") rect(x1-1,fy-1,x1+5,fy-1,"#5a4a6a") px(x1+1,fy+1,"#6a5a80")
  for k=0,5 do px(x1-2-k//2,fy-1-k,"#3a2c46") px(x1+6+k//2+0,fy-1-k+2,"#3a2c46") end end
function FACE.mask(x1,x2,fy)
  for y=fy-1,fy+6 do for x=x1-3,x2+7 do if M[y..","..x] then px(x,y,(y==fy-1) and "#5a4a7a" or ((y>=fy+6) and "#241a36" or "#3a2c52")) end end end end
local NECK={}
function NECK.scarf(cx,ny,a,side)
  for y=ny,ny+2 do for x=cx-16,cx+16 do if M[y..","..x] then px(x,y,(y==ny) and a[1] or ((y==ny+2) and a[4] or a[2])) end end end
  for x=cx-16,cx+16,4 do if M[(ny+1)..","..x] then px(x,ny+1,a[3]) px(x+1,ny+1,a[3]) end end
  local tx=cx+side*5 rect(tx,ny+3,tx+3,ny+9,a[3]) rect(tx,ny+3,tx,ny+9,a[2]) rect(tx+3,ny+3,tx+3,ny+9,a[4]) rect(tx,ny+6,tx+3,ny+6,a[4]) for x=tx,tx+3,2 do px(x,ny+10,a[4]) end end
function NECK.bowtie(cx,ny,a)
  for s=-1,1,2 do for k=0,4 do rect(cx+s*(k+1)-(s<0 and 0 or 0),ny+1-(k//2),cx+s*(k+1),ny+3+(k//2),(k<2) and a[2] or a[3]) end end rect(cx-1,ny+1,cx,ny+3,a[4]) px(cx-4,ny,a[1]) px(cx+4,ny,a[1]) end
function NECK.bell(cx,ny,a)
  rect(cx-9,ny,cx+9,ny,a[3]) rect(cx-9,ny,cx+9,ny,a[3]) rect(cx-3,ny,cx+3,ny,a[2])
  blob(cx,ny+3,3,3,2,GOLD) px(cx,ny+5,E) px(cx-1,ny+2,"#fffbe8") end
function NECK.beads(cx,ny,a)
  for i=-6,6 do local y=ny+(i*i)//12 local c=(i%2==0) and a[2] or GOLD[2] px(cx+i*2-(i>0 and 0 or 0),y,c) px(cx+i*2,y+1,(i%2==0) and a[4] or GOLD[4]) px(cx+i*2-1,y,(i%2==0) and a[1] or GOLD[1]) end end

----------------------------------------------------------------- back items (drawn behind body, unsheared). x = pole column, d = side (away from knob)
local BACK={}
local function pole(x,y0,y1,c) rect(x,y0,x+1,y1,c[3]) rect(x,y0,x,y1,c[2]) rect(x+1,y0,x+1,y1,c[4]) end
function BACK.staff(x,d,a) pole(x,24,60,WOOD) blob(x+1,22,3,3,2,a) px(x,20,a[1]) end
function BACK.shovel(x,d,a) pole(x,26,60,WOOD) rect(x-2,20,x+3,26,STEEL[3]) rect(x-2,20,x-2,26,STEEL[1]) rect(x+3,20,x+3,26,STEEL[4]) rect(x-1,19,x+2,19,STEEL[2]) rect(x-1,27,x+2,27,STEEL[4]) end
function BACK.rod(x,d,a) pole(x,16,60,WOOD) for k=0,22 do px(x+d*(2+k//6),16+k//2*0+k,"#d8c8f0") end px(x+d*6,40,"#ffe98a") px(x+d*6,41,"#c8c8d8") end
function BACK.flag(x,d,a) pole(x,16,60,WOOD) for y=0,6 do rect(x+(d>0 and 2 or -2-(8-y//2)),17+y,x+(d>0 and (10-y) or -2),17+y,(y%3==1) and a[2] or a[3]) end px(x,15,GOLD[1]) end
function BACK.umbrella(x,d,a) pole(x,22,60,WOOD) blob(x+1,20,9,6,2,a,function(i,xx,yy) if yy>20 then return nil end end) rect(x-8,20,x+10,21,a[4]) for k=-8,10,4 do px(x+k,22,a[4]) end px(x,14,GOLD[2]) end
function BACK.lantern(x,d,a) pole(x,18,60,WOOD) rect(x-3,19,x+4,19,STEEL[4]) rect(x-3,20,x+4,27,"#ffd84a") rect(x-1,21,x+2,25,"#fff6c0") rect(x-3,20,x-3,27,"#e8b030") rect(x+4,20,x+4,27,"#b07a1c") rect(x-3,28,x+4,28,STEEL[4]) px(x,17,STEEL[3]) end
function BACK.sword(x,d,a) rect(x,20,x+1,48,STEEL[2]) rect(x+1,20,x+1,48,STEEL[4]) rect(x,20,x,48,STEEL[1]) px(x,19,STEEL[1]) rect(x-3,49,x+4,50,GOLD[3]) rect(x-3,49,x+4,49,GOLD[1]) rect(x,51,x+1,56,WOOD[3]) blob(x+1,58,2,2,2,GOLD) end
function BACK.broom(x,d,a) pole(x,18,50,WOOD) for k=-5,6 do rect(x+k,51+(math.abs(k)>3 and 0 or 0),x+k,58-(math.abs(k)//3),(k%2==0) and STRAW[3] or STRAW[2]) end rect(x-4,50,x+5,52,a[3]) end

----------------------------------------------------------------- quirks (qx,qy; unsheared)
local QK={}
function QK.pollen(x,y) for _,p in ipairs{{0,0},{3,-2},{5,1},{2,3},{-2,2},{6,-4}} do px(x+p[1],y+p[2],"#ffe98a") end px(x+3,y-2,"#fffbe8") end
function QK.note(x,y) rect(x,y+3,x+1,y+4,E) rect(x+1,y-3,x+1,y+3,E) px(x+2,y-3,E) px(x+3,y-2,E) px(x,y+3,"#6a4a7a") end
function QK.heart(x,y) for _,p in ipairs{{0,0},{1,0},{3,0},{4,0},{0,1},{1,1},{2,1},{3,1},{4,1},{1,2},{2,2},{3,2},{2,3}} do px(x+p[1],y+p[2],"#f06a8a") end px(x,y,"#ffb0c4") px(x+1,y,"#ffb0c4") px(x+4,y+1,"#c0455f") px(x+2,y+3,"#c0455f") end
function QK.butterfly(x,y) rect(x,y,x+1,y+2,"#7ac8f0") rect(x+3,y,x+4,y+2,"#f08aa0") px(x+2,y,E) px(x+2,y+1,E) px(x+2,y+2,E) px(x,y,"#d8f4ff") px(x+3,y,"#ffc8d8") px(x+1,y-1,E) px(x+3,y-1,E) end
function QK.drop(x,y) px(x+1,y,"#7ac8f0") rect(x,y+1,x+2,y+3,"#7ac8f0") px(x+1,y+4,"#7ac8f0") px(x,y+2,"#d8f4ff") px(x+2,y+3,"#4a8ac0") end
function QK.star(x,y) sparkle(x+1,y+1) end
function QK.leaf(x,y) rect(x,y,x+3,y+1,GREEN[2]) rect(x+1,y+2,x+4,y+3,GREEN[3]) px(x+4,y+2,GREEN[4]) px(x,y,GREEN[1]) px(x+1,y+1,GREEN[3]) end
function QK.bubbles(x,y) for _,p in ipairs{{0,4,2},{4,1,3},{7,5,1}} do local r=p[3] for dy=-r,r do for dx=-r,r do local d=math.sqrt(dx*dx+dy*dy) if d<=r+0.3 and d>=r-0.9 then px(x+p[1]+dx,y+p[2]+dy,"#cfeaf8") end end end px(x+p[1]-1,y+p[2]-1,CR) end end

----------------------------------------------------------------- knobs: drawn BEFORE body, unsheared, buried 2px into the body edge at row ky
local function edgeX(ky,side)
  local mn,mx=99,-99
  for x=0,63 do if M[ky..","..x] then if x<mn then mn=x end if x>mx then mx=x end end end
  local sh=math.floor((46-ky)/(M.ldiv or 12)*(M.lean or 1)+0.5)
  return (side>0 and mx or mn)+sh
end
local function drawKnob(kind,ex,ky,d,kr)
  local s=SH SH=function() return 0 end
  if kind=="peg" then
    local x0,x1=ex-2*d,ex+4*d if x0>x1 then x0,x1=x1,x0 end
    rect(x0,ky-2,x1,ky+2,kr[3]) rect(x0,ky-2,x1,ky-2,kr[1]) rect(x0,ky-1,x1,ky-1,kr[2]) rect(x0,ky+2,x1,ky+2,kr[4]) rect(x0,ky+1,x1,ky+1,kr[4])
    local fx=(d>0) and x1 or x0 rect(fx,ky-2,fx,ky+2,kr[2]) px(fx,ky-2,kr[1])
  elseif kind=="round" then blob(ex+2*d,ky,4,4,2,kr)
  elseif kind=="double" then blob(ex+2*d,ky-4,3,3,2,kr) blob(ex+2*d,ky+3,3,3,2,kr) rect(ex-1*d,ky-1,ex+d,ky+1,kr[3])
  elseif kind=="tri" then blob(ex+2*d,ky-5,2.5,2.5,2,kr) blob(ex+4*d,ky,2.5,2.5,2,kr) blob(ex+2*d,ky+5,2.5,2.5,2,kr) rect(ex-1*d,ky-4,ex+2*d,ky+4,kr[3])
  elseif kind=="hook" then
    local x0,x1=ex-2*d,ex+3*d if x0>x1 then x0,x1=x1,x0 end
    rect(x0,ky,x1,ky+2,kr[3]) rect(x0,ky,x1,ky,kr[1]) rect(x0,ky+2,x1,ky+2,kr[4])
    local hx0=(d>0) and (ex+3*d-2) or (ex+3*d) rect(hx0,ky-6,hx0+2,ky+2,kr[3]) rect(hx0,ky-6,hx0,ky+2,kr[2]) rect(hx0+2,ky-6,hx0+2,ky+2,kr[4]) rect(hx0,ky-6,hx0+2,ky-6,kr[1])
  else -- keyhole: neck + round head with a keyhole slot
    local x0,x1=ex-2*d,ex+2*d if x0>x1 then x0,x1=x1,x0 end
    rect(x0,ky-1,x1,ky+1,kr[3]) rect(x0,ky-1,x1,ky-1,kr[2]) rect(x0,ky+1,x1,ky+1,kr[4])
    blob(ex+5*d,ky,4,4,2,kr) local cx=ex+5*d px(cx-(d>0 and 1 or 0),ky-1,E) px(cx-(d>0 and 1 or 0),ky,E) px(cx-(d>0 and 1 or 0),ky+1,E) px(cx-(d>0 and 1 or 0)+(d>0 and 0 or -1),ky+1,E) end
  SH=s
end

----------------------------------------------------------------- main
local FEET={{"#6b4430","#9a6a45","#4a3040"},{"#8a6a58","#b48a70","#5a4050"},{"#4a5a6a","#7a8a9a","#2e3a4a"},{"#7a3a3a","#a85a52","#4a2430"},{"#3f5a3a","#6a8a50","#2a3a2a"},{"#8a7a4a","#b8a468","#5a4a30"}}
local function foot(x,y,c,lift) rect(x,y-lift,x+6,y+2-lift,c[1]) rect(x,y-lift,x+5,y-lift,c[2]) rect(x+1,y+2-lift,x+6,y+2-lift,c[3]) end

local function gen(p)
  img=Image(64,64) BODY={} REC=false SH=function() return 0 end
  local r=p.ramp
  local ry=p.ry
  local cy=56.5-ry
  local lean,ldiv=p.lean,p.ldiv
  -- feet
  local fc=FEET[p.foot%6+1]
  foot(20,57,fc,(p.lift==0) and 1 or 0) foot(35,57,fc,(p.lift==1) and 1 or 0)
  -- measure body mask once (dry run) so knob/back can anchor to the leaning edge
  local lt=function(y) return math.floor((46-y)/ldiv*lean+0.5) end
  local r2=p.r2
  local function tex(i,x,y)
    if i<2 or i>4 then return nil end
    local pt=p.pattern
    if pt=="speckle" then if H(x,y)<0.08 then return r[math.min(5,i+1)] end
    elseif pt=="belly" then local dx,dy=(x-31.5)/9,(y-(cy+ry*0.45))/(ry*0.55) if dx*dx+dy*dy<1 then return r2[i] end
    elseif pt=="stripes" then if y>cy+1 and (x//3)%3==0 then return r2[i] end
    elseif pt=="spots" then local bx,by=x//3,y//3 if H(bx,by)<0.2 and x%3<2 and y%3<2 then return r2[i] end
    elseif pt=="weave" then if (x+y)%4==0 and x%2==0 then return r[i-1] end end
    if i==5 then return nil end
  end
  img=Image(64,64)
  SH=lt sblob(31.5,cy,p.rx,ry,p.pw,r,tex) -- dry run on a scratch image to get M
  M.ldiv=ldiv M.lean=lean
  local MM=M
  img=Image(64,64)
  local foot2=FEET[p.foot%6+1]
  foot(20,57,fc,(p.lift==0) and 1 or 0) foot(35,57,fc,(p.lift==1) and 1 or 0)
  local ty=99 for k,_ in pairs(MM) do local yy=tonumber(k:match("^(%-?%d+),")) if yy and yy<ty then ty=yy end end
  local d=p.side
  local ky=math.floor(cy+2+p.kdy)
  local ex=edgeX(ky,d)
  -- back item behind the body, on the opposite side to the knob
  local acc=p.acc
  if p.back~="" then
    local ex2=edgeX(math.floor(cy),-d)
    local x=(-d>0) and (ex2+2) or (ex2-3)
    SH=function() return 0 end
    BACK[p.back](x,-d,acc)
  end
  -- knob first (buried into body edge), tracked
  KN={}
  local before=Image(img)
  drawKnob(p.knob,ex,ky,d,r2)
  for y=0,63 do for x=0,63 do if img:getPixel(x,y)~=before:getPixel(x,y) then KN[y..","..x]=true end end end
  -- body
  BODY={} REC=true SH=lt
  sblob(31.5,cy,p.rx,ry,p.pw,r,tex) REC=false
  M.ldiv=ldiv M.lean=lean
  -- ink seam where body meets knob
  for k,_ in pairs(KN) do local y,x=k:match("(%-?%d+),(%-?%d+)") x=tonumber(x) y=tonumber(y)
    if not BODY[k] then for _,dd in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do if BODY[(y+dd[2])..","..(x+dd[1])] then img:putPixel(x,y,INK) break end end end end
  SH=lt
  local fy=ty+6
  local mx=p.mouth=="o" and 29 or 28
  -- face
  local x1,x2=22,33
  local fk=p.face
  if fk=="mask" then FACE.mask(x1,x2,fy) end
  local ef=EYEF[p.eyes] or eyeRound
  if p.eyes=="wink" then ef(x1,fy) eyeClosed(x2,fy) else ef(x1,fy) ef(x2,fy) end
  if p.eyes=="sharp" then
    for i=0,4 do px(x1+i,fy-2+(i>=3 and 1 or 0)+(i>=4 and 1 or 0)-(i<=1 and 0 or 0)+((4-i)>=3 and 0 or 0),E) end
    for i=0,4 do px(x2+4-i,fy-2+(i>=3 and 1 or 0)+(i>=4 and 1 or 0),E) end
  end
  if p.blush==1 then rect(x1,fy+6,x1+1,fy+6,"#f5a0b8") rect(x2+3,fy+6,x2+4,fy+6,"#f5a0b8") end
  mouth(p.mouth,mx,fy+7)
  if fk~="" and fk~="mask" then FACE[fk](x1,x2,fy) end
  if p.neck~="" then NECK[p.neck](31,fy+10,acc,d) end
  -- hat
  HAT[p.hat](31,ty+1,p.rx,acc)
  -- unsheared overlays
  SH=function() return 0 end
  -- quirk beside the knob, above it
  local qx=(d>0) and 52 or 8
  QK[p.quirk](qx,math.floor(cy-ry*0.3)-1+p.q2)
  -- rarity sparkles
  local corners={{{8,12},{56,10},{9,56}},{{56,12},{7,10},{55,56}},{{7,28},{57,24},{56,56}},{{57,28},{8,22},{8,56}}}
  local cs=corners[p.sp%4+1]
  if p.rarity=="rare" then for _,c in ipairs(cs) do sparkle(c[1],c[2]) end
  elseif p.rarity=="uncommon" then twinkle(cs[1][1],cs[1][2]) end
  outline() shadow(31,60,18,2)
  local s=Sprite(64,64) s.cels[1].image:drawImage(img)
  s:saveCopyAs(out..p.key..".png")
  if SAVE_ASE then s:saveAs(out..p.key..".aseprite") end
  s:close()
end

local pals=dofile(DATA)
local n=0
for _,p in ipairs(pals) do
  if (not ONLY) or ONLY[p.key] then
    local ok,err=pcall(gen,p)
    if ok then n=n+1 else print("FAIL "..p.key..": "..tostring(err)) end
  end
end
print("rendered "..n)
