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
----------------------------------------------------------- Starwise Cheerer
new()
for _,x in ipairs{23,36} do paint(mRect(x,56,x+5,58),R.BROWN) end
local SK=R.SKIN
-- arms up
paint(mLine(23,37,13,26,5,4),SK); paint(mLine(41,37,51,26,5,4),SK)
blob(12,23,3.5,3.5,SK); blob(52,23,3.5,3.5,SK)
-- starry robe
local NIGHT={"#6a6ac0","#4a4aa0","#38388a","#2a2a6a","#241c52"}
paint(mPoly{{22,35},{42,35},{47,57},{17,57}},NIGHT,function(i,x,y) if H(x,y)>0.93 then return "#ffe98a" end end)
for _,p in ipairs{{26,44},{37,48},{30,52},{41,41}} do sparkle(p[1],p[2]) end
paint(mRect(21,35,43,37),{"#ff9a80","#ee5a48","#c8383a","#923050","#5e2a58"})
-- head
blob(32,23,10,10,SK)
-- hair
paint(mEll(32,15,10,4.5),{"#6a5a7a","#463e6e","#342c58","#2e2048","#241c38"})
-- headband
paint(mRect(22,18,42,20),{"#ff9a80","#ee5a48","#c8383a","#923050","#5e2a58"})
blob(32,19,3,3,R.GOLD); px(32,17,"#fffbe8")
-- happy closed eyes
for _,p in ipairs{{26,25},{27,24},{28,24},{29,25},{35,25},{36,24},{37,24},{38,25}} do px(p[1],p[2],"#2b1c26") end
rect(30,28,34,29,"#2b1c26"); rect(31,29,33,30,"#c8383a"); px(31,28,"#fff6e0")
px(24,28,"#ff9a80") px(25,28,"#ff9a80") px(39,28,"#ff9a80") px(40,28,"#ff9a80")
save("pl-wsta-6",{32,60,16,1},{{6,12},{58,12},{8,52}})

----------------------------------------------------------- Plumetail Digger
new()
-- crate
paint(mRect(8,49,38,59),R.WOOD,function(i,x,y) if y==54 or (x-8)%10==0 then return R.WOOD[4] end end)
paint(mPoly{{8,49},{38,49},{43,45},{13,45}},{"#f0c888","#d8a468","#b88048","#94603c","#704438"})
paint(mPoly{{38,49},{43,45},{43,56},{38,59}},{"#94603c","#94603c","#704438","#704438","#4a304a"})
px(10,51,"#e8a83a") px(36,51,"#e8a83a") px(10,57,"#e8a83a") px(36,57,"#e8a83a")
-- amber
local AM={"#fff2a8","#ffd45a","#f2a030","#c8683a","#8a3a50"}
for a=0,1,0.04 do px(50+math.cos(a*6.283)*8,52+math.sin(a*6.283)*6,"#ffe98a") end
blob(50,52,6,5,AM)
px(47,49,"#fffbe8") px(48,49,"#fffbe8") px(47,50,"#fffbe8") px(52,55,"#ffd45a")
-- tail plume
local ORR={"#ffc08a","#f08a4a","#d0602e","#9a4040","#623a58"}
paint(mAdd(mEll(46,29,9,17),mEll(42,13,5,5)),ORR,function(i,x,y) if (x-y)%5==0 and i>=2 and i<=4 then return ORR[i+1] end end)
paint(mEll(48,15,3,3),R.CREAM)
-- body
blob(26,37,9,10,ORR)
paint(mEll(26,40,5,7),R.CREAM)
blob(26,46,6,2.5,ORR)
-- head
paint(mPoly{{17,15},{15,5},{21,10}},ORR); paint(mPoly{{35,15},{37,5},{31,10}},ORR)
px(16,8,"#4a304a") px(36,8,"#4a304a")
blob(26,22,9,8,ORR)
paint(mEll(26,26,5,3.5),R.CREAM)
eye(19,18,4); eye(28,18,4)
rect(25,24,26,25,"#2b1c26"); px(25,24,"#fff6e0")
px(24,28,"#2b1c26") px(27,28,"#2b1c26") rect(25,29,26,29,"#2b1c26")
-- pick
paint(mLine(15,42,13,32,2),R.WOOD)
paint(mPoly{{8,31},{18,30},{18,32},{8,33}},R.GREY); px(8,31,"#e8e4ee")
paint(mLine(16,41,19,40,3),ORR)
save("pl-ambr-6",{26,60,20,1},{{6,10},{56,8},{58,38}})

----------------------------------------------------------- Twinhump Stroller
new()
for _,x in ipairs{20,25,37,43} do paint(mRect(x,48,x+3,57),TAN==nil and R.TAN or R.TAN) end
for _,x in ipairs{19,24,36,42} do paint(mRect(x,56,x+5,58),R.BROWN) end
-- neck + head
paint(mLine(20,38,16,24,7,6),R.TAN)
blob(15,21,9,7,R.TAN)
paint(mEll(12,25,5,3),{"#fff0d0","#f6dcaa","#e4bc82","#c4966a","#9a6c50"})
paint(mEll(8,15,2.5,3),R.TAN); paint(mEll(22,15,2.5,3),R.TAN)
px(8,15,"#ff9ab8") px(22,15,"#ff9ab8")
-- body
blob(35,42,17,9,R.TAN)
-- humps
blob(28,31,6,7,R.TAN) blob(42,31,6,7,R.TAN)
for _,p in ipairs{{26,26},{27,25},{40,26},{41,25},{44,26}} do px(p[1],p[2],"#fff0d0") end
-- red blanket
paint(mPoly{{24,36},{48,36},{51,47},{22,47}},R.RED)
for x=23,50,3 do px(x,47,"#ffd866") px(x,48,"#b8783c") end
for x=25,48,4 do px(x,41,"#ffd866") px(x+1,42,"#ffd866") px(x+2,41,"#ffd866") end
rect(24,36,48,36,"#ffd866")
-- face
eye(10,17,3); eye(16,17,3)
rect(10,26,12,26,"#2b1c26") px(9,25,"#2b1c26") px(13,25,"#2b1c26")
px(9,22,"#2b1c26") px(10,22,"#2b1c26")
-- tail tuft
paint(mEll(53,40,2.5,4),R.BROWN)
save("pl-oasi-6",{32,60,20,1},{{8,6},{56,8},{54,54}})

----------------------------------------------------------- Scarlet Riddlecaller
new()
-- perch
paint(mLine(8,54,56,53,5,5),R.WOOD,function(i,x,y) if x%9==0 then return R.WOOD[4] end end)
-- tail
paint(mPoly{{27,46},{38,46},{43,57},{34,60}},R.RED)
paint(mPoly{{34,52},{40,52},{43,57},{36,60}},R.BLUE)
-- body
blob(30,37,12,15,R.RED,function(i,x,y) if (x+y)%6==0 and i>=2 and i<=4 then return R.RED[i+1] end end)
-- wing
paint(mPoly{{34,30},{43,34},{44,46},{36,48}},R.RED)
paint(mPoly{{34,36},{44,38},{44,43},{35,42}},R.YEL); paint(mPoly{{35,42},{44,43},{44,48},{36,48}},R.BLUE)
-- feet
for _,x in ipairs{25,32} do rect(x,48,x+2,51,"#c4a8a0"); rect(x,52,x+3,52,"#c4a8a0") end
-- head
blob(29,20,10,9,R.RED)
paint(mEll(24,21,5.5,5),{"#ffffff"=="" and "" or "#fffbf4","#fffbf4","#f0e8ec","#d0c4d8","#a898c4"})
for _,p in ipairs{{21,20},{22,22},{23,24},{25,25}} do px(p[1],p[2],"#d0c4d8") end
eye(21,17,3)
px(23,23,"#ff9ab8")
-- open beak
paint(mPoly{{27,20},{34,20},{36,26},{34,28},{29,26}},{"#fffbe8","#f6ecd8","#dcd0d8","#b0a4c8","#7c72a8"})
paint(mPoly{{29,28},{34,28},{33,32},{30,31}},{"#f6ecd8","#dcd0d8","#b0a4c8","#b0a4c8","#7c72a8"})
rect(30,26,34,27,"#923050"); px(32,27,"#ff9a80")
-- riddle mark
rect(47,12,50,12,"#ffd866"); px(51,13,"#ffd866"); px(51,14,"#ffd866"); px(50,15,"#ffd866"); px(49,16,"#ffd866"); px(49,17,"#ffd866"); px(49,19,"#ffd866"); px(49,20,"#ffd866")
px(48,13,"#fff2a8") px(47,13,"#ffd866")
save("pl-step-6",{32,60,17,1},{{8,10},{12,34},{56,30}})
