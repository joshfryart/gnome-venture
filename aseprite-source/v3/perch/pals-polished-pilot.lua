local out = app.params.out or "./"
local INK = Color{r=0x2b,g=0x1c,b=0x26}
local function hex(h) h=h:gsub("#","") return Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16)} end
local img
local SH=function(y) return 0 end   -- per-row lean (body group only)
local function px(x,y,c) x=x+SH(y) if x>=0 and y>=0 and x<64 and y<64 then img:putPixel(x,y,type(c)=="string" and hex(c) or c) end end
local function rect(x0,y0,x1,y1,c) for y=y0,y1 do for x=x0,x1 do px(x,y,c) end end end
local function H(x,y) return (math.sin(x*12.9898+y*78.233)*43758.5453)%1 end
local M -- last body mask (pre-shear coords)
local function inM(x,y,k) k=k or 0 return M[(y)..","..(x)] and M[y..","..(x-k)] and M[y..","..(x+k)] and M[(y-k)..","..x] and M[(y+k)..","..x] end
-- squircle body, lit upper-left, ramp5 = hl,lit,mid,shade,deep(cool violet); tex(i,x,y)->colour or nil
local function sblob(cx,cy,rx,ry,pw,r,tex)
  M={}
  for y=math.floor(cy-ry),math.ceil(cy+ry) do for x=math.floor(cx-rx),math.ceil(cx+rx) do
    local dx,dy=(x-cx+0.5)/rx,(y-cy+0.5)/ry
    local d=(math.abs(dx)^pw+math.abs(dy)^pw)^(1/pw)
    if d<=1 then
      M[y..","..x]=true
      local l=-0.55*dx-0.75*dy-0.55*d*d*d
      local i= l>0.5 and 1 or (l>0.1 and 2 or (l>-0.35 and 3 or (l>-0.75 and 4 or 5)))
      local c=(tex and tex(i,x,y)) or r[i]
      px(x,y,c) end end end
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
local function shadow(cx,cy,rx,ry) -- 2-tone contact shadow on empty pixels, after outline
  for y=cy-ry,cy+ry do for x=cx-rx,cx+rx do
    local dx,dy=(x-cx)/rx,(y-cy)/ry; local d=dx*dx+dy*dy
    if d<=1 and x>=0 and x<64 and y<64 and img:getPixel(x,y)&0xff000000==0 then img:putPixel(x,y,hex(d<0.45 and "#4a3a68" or "#6e5e8e")) end end end
end
local function eye(x,y,w) -- dark eye, big 2x2 highlight + small second glint
  rect(x,y,x+w-1,y+4,"#2b1c26"); rect(x+1,y+1,x+2,y+2,"#fff6e0"); px(x+w-2,y+3,"#d8c8f0"); px(x+1,y+4,"#6a4a7a")
end
local function sparkle(x,y) SH=function() return 0 end for _,d in ipairs{{0,0},{1,0},{-1,0},{0,1},{0,-1}} do px(x+d[1],y+d[2],"#ffe98a") end px(x,y,"#fffbe8") end
local function save(name,sh)
  outline() if sh then shadow(sh[1],sh[2],sh[3],sh[4]) end
  local s=Sprite(64,64); s.cels[1].image:drawImage(img)
  s:saveCopyAs(out..name..".png"); s:saveAs(out..name..".aseprite")
end
local function new() img=Image(64,64) SH=function() return 0 end end
local function ring(cx,cy,r0,r1,fn) for y=cy-6,cy+6 do for x=cx-6,cx+6 do local d=math.sqrt((x-cx)^2+(y-cy)^2) if d>=r0 and d<=r1 then px(x,y,fn(x-cx,y-cy)) end end end end

----------------------------------------------------------- Acorn Nip
new()
rect(20,57,26,59,"#6b4430"); rect(20,57,25,57,"#9a6a45"); rect(21,59,26,59,"#4a3040")
rect(35,56,41,58,"#6b4430"); rect(35,56,40,56,"#9a6a45"); rect(36,58,41,58,"#4a3040")  -- right foot lifted
SH=function(y) return math.floor((46-y)/13+0.5) end   -- lean right at the top
local ar={"#b4e873","#8fd05a","#5fae4a","#3a8a52","#35507a"}
sblob(30.5,44,15,12.5,4,ar,function(i,x,y)
  if (x+y)%4==0 and (x%2==0) and i>=2 and i<=4 then return ({"#a8e468","#7fc455","#4e9a48"})[i-1] end -- weave
  if i==5 and H(x,y)<0.3 then return "#3a6a62" end end)
-- stitch seam inset 3px
for k,_ in pairs(M) do local y,x=k:match("(%-?%d+),(%-?%d+)"); x=tonumber(x) y=tonumber(y)
  if inM(x,y,3) and not inM(x,y,4) and (x+y)%2==0 and y<48 or (inM(x,y,3) and not inM(x,y,4) and (x+y)%2==0 and y>52) then px(x,y,"#e8d46a") end end
-- belt following the body
for y=49,51 do for x=10,52 do if M[y..","..x] then px(x,y,(y==49) and "#8a5c3a" or (y==50 and "#6b4430" or "#4a3040")) end end end
rect(27,48,32,52,"#e8b84a"); rect(27,48,29,48,"#ffe08a"); rect(28,49,31,51,"#b8862a"); px(29,50,"#6b4430"); rect(31,52,32,52,"#8a5a1a")
-- face + round gold glasses
eye(22,38,5); eye(33,38,5)
local function lens(cx,cy)
  ring(cx,cy,3.3,4.6,function(dx,dy) if dx+dy<=-3 then return "#ffe08a" elseif dx+dy>=3 then return "#a86a1c" else return "#d99a32" end end)
  px(cx-3,cy-2,"#fffbe8"); px(cx-2,cy-3,"#fffbe8")          -- rim glint
  px(cx+2,cy+1,"#cfe8f4"); px(cx+1,cy+2,"#cfe8f4")          -- lens glint
end
lens(24,40); lens(35,40); rect(28,39,31,39,"#d99a32"); px(29,38,"#ffe08a")
px(25,44,"#fff6e0"); px(34,44,"#fff6e0")
rect(28,44,32,44,"#c0392b"); rect(29,45,31,45,"#7a2a3a") -- open mouth
-- knob with acorn on right
local kb={"#c9a068","#9a6a45","#7a4e32","#5b3a2c","#43292a"}
sblob(52,44,4,4,2,kb)
-- mushroom cap hat
sblob(30,26,18,10,2,{"#ff9a70","#ff7a5a","#d8453a","#a8323f","#6e2a4a"})
rect(14,29,46,31,"#a8323f"); rect(15,29,45,29,"#d8453a"); rect(14,31,46,31,"#6e2a4a")
for _,p in ipairs{{23,20,2},{32,18,2},{40,23,1},{27,25,1},{36,26,1},{19,26,1}} do rect(p[1],p[2],p[1]+p[3],p[2]+p[3]-(p[3]>1 and 0 or 1),"#fff1d6") end
-- quirk: acorn peeking from cap
sblob(45,21,4,4,2,{"#e0b878","#c9a068","#9a6a45","#7a4e32","#5b3a2c"}); rect(42,17,48,19,"#6b4430"); rect(42,17,44,17,"#9a6a45"); px(45,14,"#6b4430")
save("mw-acorn-nip",{31,60,17,2})

----------------------------------------------------------- Catkin Crown
new()
rect(21,57,27,59,"#8a6a58"); rect(35,57,41,59,"#8a6a58"); rect(21,57,26,57,"#b48a70"); rect(35,57,40,57,"#b48a70"); rect(22,59,27,59,"#5a4050"); rect(36,59,41,59,"#5a4050")
SH=function(y) return -math.floor((46-y)/13+0.5) end  -- lean left
local sr={"#f3f6f8","#dde5ec","#c0cbd8","#9ba3c4","#6f6f9a"}
sblob(14,46,4,4,2,sr); sblob(49,46,4,4,2,sr)
sblob(30.5,43.5,13.5,13.5,4,sr,function(i,x,y)
  local h=H(x,y)
  if h<0.10 and i<=4 then return sr[math.min(5,i+1)] elseif h>0.93 and i>=2 then return sr[i-1] end end)
-- cracks
for _,p in ipairs{{20,42},{21,43},{21,44},{22,45},{40,52},{39,53},{39,54}} do px(p[1],p[2],"#8a8fb4") end
-- blue vein streak (wobbly)
for y=40,56 do local w=(y<46) and 4 or 3; local x0=28+((y//5)%2) for x=x0,x0+w do if M[y..","..x] then px(x,y,(x==x0) and "#bfe4f4" or (x==x0+w and "#7fb4d8" or "#9fd0ea")) end end end
-- moss patches (lit, upper-left and low)
local function moss(cx,cy,r) for y=cy-r,cy+r do for x=cx-r,cx+r do if M[y..","..x] and ((x-cx)^2+(y-cy)^2)<=r*r+H(x,y)*3-1 then px(x,y,(x+y)%3==0 and "#8fd05a" or ((y>cy) and "#3f8a4a" or "#5fae4a")) end end end end
moss(19,36,2); moss(21,53,2); moss(40,53,2); moss(41,37,1); moss(19,46,1)
-- face
eye(22,38,5); eye(33,38,5)
rect(29,43,33,46,"#2b1c26"); rect(30,44,32,45,"#7a2a3a"); px(30,43,"#fff6e0")  -- ah-choo mouth
-- green headband (clipped to body)
for y=31,34 do for x=10,52 do if M[y..","..x] then px(x,y,(y==31) and "#c8f08a" or (y==34 and "#3f8a4a" or "#8fd05a")) end end end
-- catkin crown: 5 golden-brown catkins, rounded tips, scale texture
for i,x in ipairs{19,24,29,34,39} do
  local h=(i==3) and 11 or ((i%2==1) and 8 or 9)
  rect(x,30-h,x+3,30,"#c58a3a"); rect(x,30-h,x,30,"#e8b84a"); rect(x+3,30-h,x+3,30,"#8a5a34")
  for yy=30-h+1,29,2 do px(x+1,yy,"#7a4e32") px(x+2,yy+1,"#e8b84a") end
  px(x+1,30-h-1,"#e8b84a"); px(x,30-h,"#c58a3a"); px(x+3,30-h,"#8a5a34")
end
rect(17,30,44,30,"#8a5a34")
-- quirk: sneeze pollen puff
SH=function() return 0 end
for _,p in ipairs{{46,40},{49,38},{52,41},{48,43},{51,36},{54,38},{50,45}} do px(p[1],p[2],"#ffe98a") end px(49,38,"#fffbe8") px(48,43,"#fffbe8")
sparkle(48,24); sparkle(10,34)
save("bb-catkin-crown",{31,60,18,2})

----------------------------------------------------------- Dragon Dart
new()
-- veined translucent wing: root (rx,ry) to tip (tx,ty), half-width wmax
local function wing(rx,ry,tx,ty,wmax)
  local ax,ay=tx-rx,ty-ry; local L=math.sqrt(ax*ax+ay*ay); local ux,uy=ax/L,ay/L; local nx,ny=-uy,ux
  for y=math.min(ry,ty)-wmax-1,math.max(ry,ty)+wmax+1 do for x=math.min(rx,tx)-wmax-1,math.max(rx,tx)+wmax+1 do
    local vx,vy=x+0.5-rx,y+0.5-ry
    local t=(vx*ux+vy*uy)/L; local s=vx*nx+vy*ny
    if t>=0 and t<=1 then
      local w=wmax*(math.sin(math.pi*math.min(1,t^0.6*0.92+0.04)))
      if t<0.12 then w=wmax*0.32+t*4 end
      if math.abs(s)<=w then
        local u=s/math.max(w,0.1)
        local lit= (-0.6*(x-rx)-0.8*(y-ry))/L
        local c = (u<0) and "#eef9fc" or "#cfe6f2"       -- translucent panes: lit / shade half
        if lit>0.35 and u<0 then c="#fff6e0" end
        if math.abs(u)>0.82 then c="#4a7ab0"                -- leading + trailing vein
        elseif math.abs(s)<0.6 then c="#5a8ac0"             -- mid vein
        else
          local k=(t*L)%5
          if k<1 then c="#7aa4d0" end                       -- cross veins
        end
        if t>0.82 and math.abs(u)<0.6 then c="#f5a0b8" end  -- pterostigma tint
        px(x,y,c) end end end end
end
wing(28,35,4,25,5); wing(36,35,60,25,5); wing(28,41,7,47,4); wing(36,41,57,47,4)
-- tapered striped abdomen to bottom centre
for y=40,58 do local w=math.max(1,math.floor(4-(y-40)*3/17+0.5))
  for x=32-w,31+w do
    local band=((y//3)%2==0); local c=band and "#a8d4ea" or "#e8f0f6"
    if y%3==2 and y>45 then c="#6a7ab0" end
    if x<=32-w then c=band and "#cfe9f6" or "#fff6e0" end
    if x>=31+w then c=band and "#6a8ab8" or "#a898c4" end
    px(x,y,c) end end
px(31,59,"#7a6aa6"); px(32,59,"#6a5a96")
-- thorax + head
local function tb(cx,cy,rx,ry,r) sblob(cx,cy,rx,ry,2,r) end
tb(32,38,7,6,{"#e8f8fc","#d8f0fa","#a8d4ea","#7aa4d0","#6a7ab0"})
tb(32,25,11,10,{"#e8f8fc","#d8f0fa","#a8d4ea","#7ea8d4","#6a7ab0"})
-- wing root joints on thorax
for _,p in ipairs{{26,35},{38,35},{26,41},{38,41}} do rect(p[1],p[2],p[1]+1,p[2]+1,"#6a5a9a"); px(p[1],p[2],"#a898d0") end
-- antennae
px(28,14,"#6a7ab0") px(27,12,"#6a7ab0") px(27,11,"#ffe98a") px(36,14,"#6a7ab0") px(37,12,"#6a7ab0") px(37,11,"#ffe98a")
-- big eyes: left wide open, right winks
rect(24,21,29,27,"#2b1c26"); rect(25,22,27,23,"#fff6e0"); px(28,22,"#fff6e0"); px(26,25,"#6a4a7a"); px(28,26,"#d8c8f0")
for _,p in ipairs{{35,25},{36,24},{37,23},{38,23},{39,24},{40,25}} do px(p[1],p[2],"#2b1c26") end
rect(36,27,38,27,"#f5a0b8")
px(30,30,"#2b1c26"); px(31,31,"#2b1c26"); px(32,31,"#2b1c26"); px(33,30,"#2b1c26")
px(31,17,"#ffffff"); px(32,16,"#fff6e0")
sparkle(6,14); sparkle(58,14); sparkle(8,56); px(56,52,"#ffe98a")
save("br-dragon-dart",{32,61,7,1})
