----------------------------------------------------------- Popcorn Moon
new()
local feet=function() for _,x in ipairs{22,34} do local m=mRect(x,50,x+5,54) paint(m,R.BROWN) end end
feet()
local cres=mSub(mEll(29,33,17,18),mEll(41,28,13,14))
paint(cres,R.GOLD,function(i,x,y) if (x*7+y*13)%23==0 and i>=2 and i<=4 then return R.GOLD[i+1] end end)
-- craters
for _,c in ipairs{{15,42,2},{22,47,1},{17,25,1}} do local m=mEll(c[1],c[2],c[3]+0.6,c[3]+0.6) for k,p in pairs(m) do if has(cres,p[1],p[2]) then px(p[1],p[2],"#c08a3a") end end px(c[1],c[2]+c[3],"#ffe08a") end
eye(15,30,4); eye(22,30,4)
px(16,31,"#fff6e0")
rect(18,37,20,37,"#2b1c26"); px(17,36,"#2b1c26"); px(21,36,"#2b1c26"); rect(18,38,20,38,"#c8383a")
px(14,35,"#ff9a80"); px(15,35,"#ff9a80"); px(24,35,"#ff9a80"); px(25,35,"#ff9a80")
-- popcorn burst at top tip
local CORN={"#fffbe8","#fff0c0","#f6dc9a","#d8b060","#a07a50"}
for _,k in ipairs{{37,18,4},{43,14,3},{33,12,3},{44,21,3}} do
  blob(k[1],k[2],k[3],k[3],CORN)
  blob(k[1]-2,k[2]-1,2,2,CORN) blob(k[1]+2,k[2]-1,2,2,CORN) end
px(40,16,"#e8a83a"); px(35,15,"#e8a83a"); px(45,18,"#e8a83a")
save("mh-popcorn-moon",{29,56,15,1},{{8,14},{56,36},{54,52}})

----------------------------------------------------------- Homing Stork
new()
-- legs
for _,l in ipairs{{30,50,28,58},{37,50,38,58}} do paint(mLine(l[1],l[2],l[3],l[4],2),R.RED) end
paint(mRect(24,58,29,59),R.RED); paint(mRect(36,58,41,59),R.RED)
local body=mEll(32,42,14,10)
paint(body,R.CREAM)
-- tail feathers + wing (dark)
local wing=mPoly{{30,36},{44,35},{55,42},{47,49},{34,47}}
paint(wing,R.DARK,function(i,x,y) if (x+y)%5==0 and i<=3 then return R.DARK[i+1] end end)
local neck=mPoly{{22,36},{21,24},{30,23},{31,32},{30,38}}
paint(mAdd(neck),R.CREAM)
paint(mEll(25,18,6.5,6),R.CREAM)
-- beak
local beak=mPoly{{20,16},{6,23},{7,25},{21,22}}
paint(beak,R.RED)
for x=8,19 do px(x,23+(x<14 and 0 or -1)-math.floor((x-8)/3),R.RED[4]) end
eye(22,14,3)
px(21,19,"#ff9ab8") px(22,19,"#ff9ab8")
-- bundle hanging from beak
rect(8,26,8,28,"#6a4a7a")
local bun=blob(9,33,5,5,R.BLUE)
rect(7,28,11,28,"#ffd866"); px(6,27,"#ffd866"); px(12,27,"#ffd866")
for _,p in ipairs{{8,32},{11,34},{9,36}} do px(p[1],p[2],"#fff6e0") end
save("bb-homing-stork",{32,60,15,1},{{52,14},{54,28},{12,50}})

----------------------------------------------------------- Great White Plumelet
new()
local vane={} local cxf=function(y) return 38-(y-8)*8/47 end
for y=8,55 do local t=(y-8)/47 local w=11.5*math.sin(math.pi*math.min(1,t^0.75))
  for x=math.floor(cxf(y)-w),math.ceil(cxf(y)+w) do if math.abs(x+.5-cxf(y))<=w then mset(vane,x,y) end end end
-- notches on right edge
for _,y in ipairs{30,40} do for x=44,52 do vane[K(x,y)]=nil end end
paint(mLine(30,52,29,58,2),R.GOLD)
paint(vane,R.CREAM,function(i,x,y)
  local t=(y-8)/47
  if t<0.1 then return ({"#ffd0f0","#f0a0e0","#c880e0","#9a6ad0","#6a52b0"})[i] end
  if t<0.2 then return ({"#e0c8ff","#b898f8","#9a7ae0","#7a62c8","#5a4ca8"})[i] end
  if t<0.3 then return ({"#c8fff0","#80f0d0","#50d8b8","#3ab0a0","#3a7a98"})[i] end
  if (x*2+y)%7==0 and i>=2 and i<=4 then return R.CREAM[i+1] end end)
-- rachis
for y=14,56 do local x=math.floor(cxf(y)) if not (y>=27 and y<=39) and has(vane,x,y) then px(x,y,"#b0a4c8") px(x-1,y,"#fffbe8") end end
local ex=math.floor(cxf(32))
eye(ex-7,27,4); eye(ex+3,27,4)
px(ex-1,33,"#f2a030"); px(ex,33,"#f2a030"); px(ex-1,34,"#c8783a"); px(ex,34,"#c8783a")
px(ex-8,32,"#ff9ab8"); px(ex-7,32,"#ff9ab8"); px(ex+6,32,"#ff9ab8"); px(ex+7,32,"#ff9ab8")
save("pl-owl-6",{30,60,7,1},{{12,12},{54,50},{10,46}})

----------------------------------------------------------- Gale Islander (crab)
new()
for _,x in ipairs{16,22,38,44} do paint(mRect(x,52,x+3,56),R.RED) end
for _,x in ipairs{14,46} do paint(mLine(x+2,50,x+(x<30 and -2 or 6),55,3),R.RED) end
-- arms + claws
paint(mLine(17,42,10,35,4),R.RED); paint(mLine(47,42,54,35,4),R.RED)
for _,s in ipairs{-1,1} do local cx=s<0 and 9 or 54
  paint(mEll(cx,30,5,5),R.RED); paint(mEll(cx+s*1,25,3,3),R.RED)
  px(cx,25,"#5e2a58"); px(cx,26,"#5e2a58") end
local body=blob(32,45,17,9,R.RED,function(i,x,y) if (x+y)%6==0 and i>=2 and i<=4 then return R.RED[i+1] end end)
eye(24,42,4); eye(34,42,4)
rect(29,49,31,49,"#2b1c26"); px(28,48,"#2b1c26"); px(32,48,"#2b1c26")
px(21,48,"#ff9a80"); px(22,48,"#ff9a80"); px(40,48,"#ff9a80"); px(41,48,"#ff9a80")
-- island on back
paint(mEll(32,38,15,5),{"#ffeeb0","#f0d890","#d8b470","#a88060","#6a4a60"})
paint(mEll(32,35,11,5),R.GREEN)
-- palms
paint(mLine(27,34,25,21,2),R.BROWN); paint(mLine(37,34,39,26,2),R.BROWN)
for _,l in ipairs{{25,21,19,24},{25,21,20,18},{25,21,26,16},{25,21,31,19},{25,21,31,24},{39,26,34,29},{39,26,34,23},{39,26,39,20},{39,26,44,23},{39,26,44,28}} do paint(mLine(l[1],l[2],l[3],l[4],2),R.GREEN) end
px(25,21,"#ffd866")
rect(30,26,30,33,"#6a4440"); rect(31,26,34,28,"#ffd866"); px(31,26,"#fff2a8")
save("pl-hcr-6",{32,58,19,1},{{6,12},{58,14},{32,6}})

----------------------------------------------------------- Tiger Moth Locket
new()
local WING={"#ffb860","#ee7a2e","#c8503a","#8e2f48","#5e2a58"}
local function wing(p,eyec) local m=mPoly(p) paint(m,WING,function(i,x,y)
  if (x+y*2)%9==0 and i<=3 then return "#fff0c0" end end) return m end
local uw={{27,32},{8,15},{4,25},{9,38},{27,41}}
local lw={{27,39},{9,42},{12,55},{27,49}}
wing(uw) wing(mir(uw)) wing(lw) wing(mir(lw))
-- dark tiger stripes on upper wings
for _,s in ipairs{{1,22,28,"#5e2a58"},{1,16,24,"#5e2a58"}} do end
for _,p in ipairs{{12,22},{13,23},{14,24},{16,26},{18,28},{20,30},{14,31},{16,32},{18,33},{9,29},{10,31}} do px(p[1],p[2],"#5e2a58"); px(63-p[1],p[2],"#5e2a58") end
-- locket eyespots on lower wings
local function spot(cx,cy) blob(cx,cy,5,5,{"#fffbe8","#ffec6a","#f2c92e","#c89a30","#8a6a5a"})
  for a=0,1,0.05 do local x,y=cx+math.cos(a*6.283)*5.5,cy+math.sin(a*6.283)*5.5 px(x,y,"#5e2a58") end
  px(cx-2,cy-2,"#fffbe8") px(cx-1,cy-2,"#fffbe8") px(cx+1,cy+2,"#ffec6a") end
spot(16,46) spot(47,46)
-- body
paint(mEll(32,42,5,11),R.CREAM,function(i,x,y) if y%3==0 and i>=2 then return R.CREAM[math.min(5,i+1)] end end)
paint(mEll(32,28,7,6),R.CREAM)
eye(27,26,3); eye(33,26,3)
px(31,31,"#2b1c26") px(32,31,"#2b1c26")
-- antennae
for _,s in ipairs{-1,1} do for i=0,6 do px(32+s*(3+i*0.7),22-i,"#7a4e32") end for i=1,3 do px(32+s*(3+i*1.5)+s,22-i*2,"#b8783c") end px(32+s*8,15,"#ffe98a") end
paint(mLine(30,51,29,55,2),R.BROWN); paint(mLine(34,51,35,55,2),R.BROWN)
save("pl-tgm-6",{32,57,9,1},{{6,8},{58,10},{32,6}})
