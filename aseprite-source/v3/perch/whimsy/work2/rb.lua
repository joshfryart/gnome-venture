local out = app.params.out or "./"
local INK = Color{r=0x2b,g=0x1c,b=0x26}
local function hex(h) h=h:gsub("#","") return Color{r=tonumber(h:sub(1,2),16),g=tonumber(h:sub(3,4),16),b=tonumber(h:sub(5,6),16)} end
local img
local function px(x,y,c) x=math.floor(x) y=math.floor(y) if x>=0 and y>=0 and x<64 and y<64 then img:putPixel(x,y,type(c)=="string" and hex(c) or c) end end
local function rect(x0,y0,x1,y1,c) for y=y0,y1 do for x=x0,x1 do px(x,y,c) end end end
local function H(x,y) return (math.sin(x*12.9898+y*78.233)*43758.5453)%1 end
local function K(x,y) return (y+100)*512+(x+100) end
local function mset(m,x,y) m[K(x,y)]={x,y} end
local function mEll(cx,cy,rx,ry) local m={} for y=math.floor(cy-ry-1),math.ceil(cy+ry+1) do for x=math.floor(cx-rx-1),math.ceil(cx+rx+1) do local dx,dy=(x+.5-cx)/rx,(y+.5-cy)/ry if dx*dx+dy*dy<=1 then mset(m,x,y) end end end return m end
local function mRect(x0,y0,x1,y1) local m={} for y=y0,y1 do for x=x0,x1 do mset(m,x,y) end end return m end
local function mPoly(p) local m={} local y0,y1=1e9,-1e9 for _,q in ipairs(p) do y0=math.min(y0,q[2]) y1=math.max(y1,q[2]) end
  for y=math.floor(y0),math.ceil(y1) do for x=0,63 do local inside=false local n=#p local j=n
    for i=1,n do local xi,yi,xj,yj=p[i][1],p[i][2],p[j][1],p[j][2]
      if ((yi>y+.5)~=(yj>y+.5)) and (x+.5<(xj-xi)*(y+.5-yi)/(yj-yi)+xi) then inside=not inside end j=i end
    if inside then mset(m,x,y) end end end return m end
local function mLine(x0,y0,x1,y1,w0,w1) w1=w1 or w0 local m={} local n=math.max(math.abs(x1-x0),math.abs(y1-y0))*2+1
  for i=0,n do local t=i/n local x,y,w=x0+(x1-x0)*t,y0+(y1-y0)*t,w0+(w1-w0)*t
    for yy=math.floor(y-w/2-1),math.ceil(y+w/2+1) do for xx=math.floor(x-w/2-1),math.ceil(x+w/2+1) do
      if (xx+.5-x)^2+(yy+.5-y)^2<=(w/2)^2+0.25 then mset(m,xx,yy) end end end end return m end
local function mAdd(...) local m={} for _,a in ipairs{...} do for k,v in pairs(a) do m[k]=v end end return m end
local function mSub(a,b) local m={} for k,v in pairs(a) do if not b[k] then m[k]=v end end return m end
local function mInt(a,b) local m={} for k,v in pairs(a) do if b[k] then m[k]=v end end return m end
local function has(m,x,y) return m[K(x,y)]~=nil end
-- shaded fill: ramp = hl,lit,mid,shade,deep ; tex(i,x,y)->colour|nil
local function paint(m,r,tex)
  local x0,y0,x1,y1=1e9,1e9,-1e9,-1e9
  for _,p in pairs(m) do x0=math.min(x0,p[1]) y0=math.min(y0,p[2]) x1=math.max(x1,p[1]) y1=math.max(y1,p[2]) end
  local cx,cy,rx,ry=(x0+x1+1)/2,(y0+y1+1)/2,(x1-x0+1)/2,(y1-y0+1)/2
  for _,p in pairs(m) do local x,y=p[1],p[2]
    local dx,dy=(x+.5-cx)/rx,(y+.5-cy)/ry
    local l=-0.5*dx-0.65*dy-0.45*(dx*dx+dy*dy)+0.1
    if not has(m,x,y-1) or not has(m,x-1,y) then l=l+0.28 end
    if not has(m,x+1,y) or not has(m,x,y+1) then l=l-0.4 end
    local i= l>0.45 and 1 or (l>0.12 and 2 or (l>-0.25 and 3 or (l>-0.6 and 4 or 5)))
    local c=(tex and tex(i,x,y)) or r[i]
    px(x,y,c) end
end
local function flat(m,c) for _,p in pairs(m) do px(p[1],p[2],c) end end
local function blob(cx,cy,rx,ry,r,tex) local m=mEll(cx,cy,rx,ry) paint(m,r,tex) return m end
local function eye(x,y,w) rect(x,y,x+w-1,y+4,"#2b1c26"); rect(x+1,y+1,x+2,y+2,"#fff6e0"); px(x+w-2,y+3,"#d8c8f0"); px(x+1,y+4,"#6a4a7a") end
local function eyeS(x,y) rect(x,y,x+2,y+3,"#2b1c26"); px(x,y,"#fff6e0"); px(x+1,y,"#fff6e0"); px(x+2,y+2,"#d8c8f0") end
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
local function sparkle(x,y) for _,d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do px(x+d[1],y+d[2],"#ffe98a") end px(x,y,"#fffbe8") end
local function sparkles(a) for _,p in ipairs(a) do sparkle(p[1],p[2]) end end
local function save(name,sh,sp)
  outline() if sh then shadow(sh[1],sh[2],sh[3],sh[4]) end
  if sp then sparkles(sp) end
  local s=Sprite(64,64); s.cels[1].image:drawImage(img)
  s:saveCopyAs(out..name..".png")
end
local function new() img=Image(64,64) end
local function mir(p) local q={} for i,v in ipairs(p) do q[i]={63-v[1],v[2]} end return q end
local R={
 GOLD={"#fff2a8","#ffd866","#e8a83a","#b8783c","#7a5078"},
 CREAM={"#fffbe8","#f6ecd8","#dcd0d8","#b0a4c8","#7c72a8"},
 RED={"#ff9a80","#ee5a48","#c8383a","#923050","#5e2a58"},
 BROWN={"#d8a070","#b07848","#8a5a3a","#6a4440","#46304a"},
 ORANGE={"#ffd08a","#ffa04a","#ee7a2e","#b8503e","#7a3a5a"},
 GREY={"#e8e4ee","#c4c0d4","#9a98b8","#74729a","#524e80"},
 GREEN={"#d0f08a","#9ad852","#5ea84a","#3a7a50","#2e4e6a"},
 YEL={"#fffbb0","#ffec6a","#f2c92e","#c89a30","#8a6a5a"},
 BLUE={"#c8ecff","#8cc8f0","#5a9ad8","#4670b0","#3c4a88"},
 DARK={"#8a84b0","#625c8c","#463e6e","#342c58","#2e2048"},
 PINK={"#ffd0dc","#ff9ab8","#e8648c","#b04478","#6e3a6a"},
 WINE={"#d8607a","#b0384e","#8a2a48","#66264a","#46204a"},
 TAN={"#f6dcaa","#e4bc82","#c4966a","#9a6c50","#684a60"},
 SKIN={"#e8b088","#c88a5a","#a46a46","#7e4a48","#54344c"},
 WOOD={"#d8a468","#b88048","#94603c","#704438","#4a304a"},
}
----------------------------------------------------------- Trail Dassie
new()
for _,x in ipairs{22,37} do paint(mEll(x+2,55,5,3),R.BROWN) end
blob(32,45,16,11,R.BROWN,function(i,x,y) if H(x,y)<0.12 and i<=4 then return R.BROWN[i+1] end end)
paint(mEll(30,49,8,6),R.TAN)
blob(21,21,3.5,3.5,R.BROWN); blob(41,21,3.5,3.5,R.BROWN)
px(21,21,"#ff9ab8") px(41,21,"#ff9ab8")
blob(31,30,12,10,R.BROWN,function(i,x,y) if H(x,y)<0.1 and i<=4 then return R.BROWN[i+1] end end)
paint(mEll(31,34,6,4),R.TAN)
eye(24,26,3); eye(34,26,3)
rect(30,32,32,33,"#2b1c26"); px(30,32,"#fff6e0")
px(29,36,"#2b1c26") px(30,37,"#2b1c26") px(32,37,"#2b1c26") px(33,36,"#2b1c26")
px(21,32,"#ff9ab8") px(22,32,"#ff9ab8") px(41,32,"#ff9ab8") px(42,32,"#ff9ab8")
-- whiskers
for _,p in ipairs{{23,34},{22,35},{40,34},{41,35}} do px(p[1],p[2],"#f6dcaa") end
-- protea
paint(mLine(44,52,43,43,2),R.GREEN)
paint(mEll(45,38,7,7),R.PINK,function(i,x,y) local dx,dy=x-45,y-38 if dx*dx+dy*dy<=9 then return ({"#fffbe8","#ffe8d8","#f6dcaa","#d8b090","#a07a70"})[i] end
  if (x+y)%3==0 and i>=2 then return R.PINK[math.max(1,i-1)] end end)
paint(mEll(42,46,3,3),R.BROWN)
-- ash puffs
for _,p in ipairs{{12,57},{16,59},{52,58},{56,56}} do px(p[1],p[2],"#9a98b8") px(p[1]+1,p[2],"#c4c0d4") end
save("pl-fyn-6",{32,59,19,1},{{8,12},{54,12},{10,40}})

----------------------------------------------------------- Saltblock Minecart
new()
local SALT={"#fffbf4","#f6e0e4","#e0b8c8","#b890b0","#8a6a98"}
local function cube(x,y,w,h,d) -- front face x..x+w-1, y+d..y+d+h-1
  paint(mRect(x,y+d,x+w-1,y+d+h-1),SALT,nil)
  paint(mPoly{{x,y+d},{x+w,y+d},{x+w+d,y},{x+d,y}},{SALT[1],SALT[1],SALT[1],SALT[2],SALT[2]})
  paint(mPoly{{x+w,y+d},{x+w+d,y},{x+w+d,y+h-1},{x+w,y+d+h}},{SALT[3],SALT[3],SALT[4],SALT[4],SALT[5]})
  px(x+1,y+d+1,"#ffffff" == "x" and "" or "#fffbe8") end
cube(14,22,10,9,4) cube(26,19,10,10,4) cube(38,22,10,9,4) cube(20,28,10,9,4) cube(33,28,10,9,4)
-- cart
local cart=mPoly{{9,36},{55,36},{51,54},{13,54}}
paint(cart,R.WOOD,function(i,x,y) if (x%7==0) and i>=2 and i<=4 then return R.WOOD[i+1] end end)
rect(10,36,54,37,"#8a8aa8"); rect(10,36,54,36,"#c4c0d4"); rect(12,52,52,53,"#74729a")
paint(mRect(9,36,11,53),{"#8a8aa8","#74729a","#74729a","#524e80","#524e80"})
for _,x in ipairs{12,31,50} do px(x,45,"#e8a83a") end
eye(21,40,3); eye(37,40,3)
px(30,46,"#2b1c26") px(31,47,"#2b1c26") px(32,47,"#2b1c26") px(33,46,"#2b1c26")
px(17,45,"#ff9ab8") px(18,45,"#ff9ab8") px(44,45,"#ff9ab8") px(45,45,"#ff9ab8")
for _,x in ipairs{19,44} do blob(x,55,5,5,R.GREY) blob(x,55,2,2,{"#fff2a8","#ffd866","#e8a83a","#b8783c","#7a5078"}) end
-- note
rect(53,13,53,18,"#6a4a9a"); blob(51,19,2,2,{"#8a6ac0","#6a4a9a","#6a4a9a","#4a3a78","#4a3a78"}) rect(53,13,56,14,"#6a4a9a")
save("pl-smg-6",{32,60,22,1},{{6,14},{58,32},{8,48}})

----------------------------------------------------------- Songline Kangaroo
new()
local OC={"#ffd496","#f0a860","#d08044","#9a5a44","#643c56"}
paint(mPoly{{36,47},{52,54},{56,58},{44,60},{34,56}},OC)
for _,x in ipairs{22,34} do paint(mEll(x+4,58,6,2.5),OC) end
blob(30,40,10,13,OC)
paint(mEll(30,43,6,8),R.CREAM)
-- left arm on chest, right arm pointing
paint(mLine(22,38,26,44,3),OC)
paint(mLine(37,36,53,28,3,3),OC); blob(55,27,2.5,2.5,OC)
-- head
paint(mPoly{{22,17},{19,5},{25,3},{27,15}},OC); paint(mPoly{{38,17},{41,4},{35,3},{33,15}},OC)
px(24,8,"#ff9ab8") px(24,9,"#ff9ab8") px(24,10,"#ff9ab8") px(36,8,"#ff9ab8") px(36,9,"#ff9ab8") px(36,10,"#ff9ab8")
blob(30,22,9,8,OC)
paint(mEll(30,26,4,3),R.CREAM)
eye(23,19,3); eye(32,19,3)
rect(29,25,31,25,"#2b1c26"); px(30,24,"#2b1c26"); px(30,28,"#2b1c26")
px(22,25,"#ff9ab8") px(23,25,"#ff9ab8") px(37,25,"#ff9ab8") px(38,25,"#ff9ab8")
-- stitches
for y=36,48,3 do px(21,y,"#fff0c0") px(39,y,"#fff0c0") end
-- song note
rect(58,16,58,21,"#6a4a9a"); blob(56,22,2,2,{"#8a6ac0","#6a4a9a","#6a4a9a","#4a3a78","#4a3a78"})
save("pl-rrs-6",{34,60,20,1},{{8,14},{50,10},{8,50}})

----------------------------------------------------------- Hut Dweller
new()
local MUD={"#e0a478","#c2845a","#9a6046","#744448","#4a304c"}
blob(32,47,19,11,MUD,function(i,x,y) if H(x,y)<0.12 and i>=2 and i<=4 then return MUD[i+1] end if (y%4==0) and i>=2 and i<=4 and (x%3~=0) then return MUD[i+1] end end)
-- door
local door=mAdd(mRect(27,50,36,57),mEll(31.5,50,5,6))
paint(door,{"#fff2a8","#ffe08a","#ffd866","#f2a030","#c8783a"})
paint(mAdd(mRect(29,52,34,57),mEll(31.5,52,3,4)),{"#fffbe8","#fff2a8","#ffec6a","#ffd866","#f2c030"})
-- thatch roof
local roof=mPoly{{32,8},{11,36},{53,36}}
paint(roof,{"#fff0a0","#f0d070","#d8aa50","#a87a48","#6e5058"},function(i,x,y)
  if (x*2-y*3)%6==0 then return ({"#d8aa50","#b88a48","#8a6040","#6a4a50","#4a3a50"})[i] end end)
paint(mRect(9,34,55,38),{"#ffe898","#f0d070","#d8aa50","#a87a48","#6e5058"},function(i,x,y) if x%3==0 and y>35 then return "#8a6040" end end)
-- fringe
for x=10,54,3 do px(x,39,"#a87a48") px(x,40,"#6e5058") end
eye(15,44,4); eye(44,44,4)
px(16,50,"#ff9ab8") px(17,50,"#ff9ab8") px(45,50,"#ff9ab8") px(46,50,"#ff9ab8")
-- smoke twinkle in roof tip
save("pl-drmc-6",{32,60,19,1},{{8,14},{56,18},{6,52}})

----------------------------------------------------------- Abbot Lemon
new()
for _,x in ipairs{22,36} do paint(mRect(x,50,x+5,54),R.BROWN) end
local lm=mAdd(mEll(32,35,17,15),mEll(13,36,3,3),mEll(51,34,3,3))
paint(lm,R.YEL,function(i,x,y) if H(x,y)<0.12 and i>=2 and i<=4 then return R.YEL[i+1] end if H(x,y)>0.97 then return R.YEL[2] end end)
-- leaves
paint(mPoly{{31,21},{22,14},{20,19},{29,22}},R.GREEN); paint(mPoly{{32,21},{42,13},{44,18},{35,22}},R.GREEN)
paint(mLine(32,22,32,18,2),R.BROWN)
-- halo
for a=0,1,0.04 do px(32+math.cos(a*6.283)*8,9+math.sin(a*6.283)*2.2,"#fff2a8") end
-- face: open eye + wink
eye(21,29,4); 
for _,p in ipairs{{34,31},{35,30},{36,30},{37,30},{38,31}} do px(p[1],p[2],"#2b1c26") end
px(36,32,"#ff9ab8")
px(29,37,"#2b1c26") px(30,38,"#2b1c26") px(31,38,"#2b1c26") px(32,37,"#2b1c26")
px(21,36,"#ff9a80") px(22,36,"#ff9a80") px(40,36,"#ff9a80") px(41,36,"#ff9a80")
-- wise white eyebrow + whisker
rect(20,26,25,26,"#fffbe8"); rect(34,27,39,27,"#fffbe8"); px(19,27,"#fffbe8"); px(40,28,"#fffbe8")
save("pl-lemn-6",{32,56,15,1},{{8,10},{56,12},{56,50}})
