local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local H = X.hash
local INK = GX.INK
local c
local function mk() return HP.mask() end
local function E(m,cx,cy,rx,ry) return GX.disc(m,floor(cx),floor(cy),floor(rx),floor(ry or rx)) end
local function R6(R) return GX.ramp6(R) end
local function rc(x0,y0,x1,y1) return c:rect(floor(x0),floor(y0),floor(x1),floor(y1)) end
local function fill(x0,y0,x1,y1,col) c:fillMask(rc(x0,y0,x1,y1),col) end
local function px(x,y,col) c:px(floor(x),floor(y),col) end
local function L(m,R,o) o=o or {}; if o.rimlight==nil then o.rimlight=true end; return GX.lit(c,m,type(R)=="function" and R or R6(R),o) end
local function blob(cx,cy,rx,ry,R,seed,o) local m=mk(); E(m,cx,cy,rx,ry); m=GX.rough(m,seed,1); o=o or {}; o.seed=seed; o.R=o.R or max(2,min(rx,ry)); L(m,R,o); return m end
local function box(x0,y0,x1,y1,R,o) o=o or {}; o.R=o.R or 14; local m=rc(x0,y0,x1,y1); L(m,R,o); return m end
local function poly(t,R,o) o=o or {}; o.R=o.R or 16; local pp={} for i,p in ipairs(t) do pp[i]={floor(p[1]+.5),floor(p[2]+.5)} end local m=c:poly(pp); L(m,R,o); return m end
local function shadow(cx,cy,rx,ry,col) local m=mk(); E(m,cx,cy,rx,ry); m=GX.rough(m,cx,1); c:fillMask(m,col) end
local function sky(cols,y1,seed) GX.bands(c,0,y1,cols,seed or 3,.16) end
local function stars(n,ymax,seed,col)
  for i=0,n do local x,y=floor(H(i,1,seed)*478),floor(H(i,2,seed)*ymax); px(x,y,col or "#fff0d0"); if i%6==0 then px(x+1,y,"#d8c8f0"); px(x,y+1,"#d8c8f0"); px(x-1,y,"#d8c8f0"); px(x,y-1,"#d8c8f0") end end
end
local CL={hi="#ffffff",base="#fff2e0",shade="#e8c8c0",deep="#c0a0b0"}
local function cloud(cx,cy,w,R,seed) local m=mk(); for i=0,4 do E(m,cx-w+i*floor(w/2.2),cy+(i%2)*-2,floor(w/2.4),4) end m=GX.rough(m,seed,1); L(m,R or CL,{R=4,tex=.3,sc=3,seed=seed,ink=false,amb=.3}) end
local function hills(f,R,seed,ybot) local m=c:terrain(f,nil,ybot or 269); local r6=R6(R); m:each(function(x,y) local t=(y-f(x))/40; local v=.8-t*.4+(GX.vn(x,y,9,seed)-.5)*.3; px(x,y,r6[GX.idx(v)]) end); for x=0,479 do px(x,floor(f(x)+.5),r6[6]) end end
local function glow(cx,cy,rx,ry,col,t)
  for y=cy-ry,cy+ry do for x=cx-rx,cx+rx do local dd=((x-cx)/rx)^2+((y-cy)/ry)^2; local cur=c:get(x,y)
    if cur and dd<=1 then px(x,y,GX.mix(cur,col,dd<.4 and t*1.5 or (dd<.75 and t or t*.55))) end end end
end
local function lantern(x,y,r,gl,warm)
  warm=warm or "#ffa040"; if gl and gl>0 then glow(x,y,gl,gl,warm,.2) end
  local m=mk(); E(m,x,y,r,r+1); c:rim(m,INK)
  m:each(function(xx,yy) local dd=sqrt((xx-x)^2+((yy-y)*r/(r+1))^2); px(xx,yy,dd<r*.35 and "#fffbe0" or dd<r*.6 and "#ffe890" or dd<r*.85 and "#ffb848" or "#e87a38") end)
end
local function win(m,y0,y1,fr,o) -- lit window from mask
  o=o or {}; c:rim(m,INK)
  m:each(function(x,y) local t=(y-y0)/max(1,y1-y0); px(x,y,t<.3 and "#fff4b8" or t<.65 and "#ffd870" or "#f5a548") end)
  if o.bars~=false then local x0,_,x1 = m:bbox(); local mx=floor((x0+x1)/2); for y=y0,y1 do if m:has(mx,y) then px(mx,y,fr) end end; local my=floor((y0+y1)/2); for x=x0,x1 do if m:has(x,my) then px(x,my,fr) end end end
end
local function rwin(x0,y0,x1,y1,fr,sill) local m=rc(x0,y0,x1,y1); win(m,y0,y1,fr); fill(x0-2,y1+1,x1+2,y1+2,sill or fr); fill(x0-2,y1+3,x1+2,y1+3,INK) end
local function awin(x0,y0,x1,y1,fr) local m=rc(x0,floor((y0+x1-x0)/2+y0*0)+0,x1,y1); local mid=(x0+x1)/2; local r=(x1-x0)/2; local m2=rc(x0,y0+floor(r),x1,y1); E(m2,mid,y0+floor(r),floor(r),floor(r)); m2:cut(rc(x0-2,y1+1,x1+2,y1+4)); win(m2,y0,y1,fr) end
local function tuft(x,y,R) GX.tuft(c,x,y,R) end
local GRASS={hi="#c4d868",base="#78a848",shade="#3e784a",deep="#245040"}
local function round(m,n) return m end
-- critter: feet at (x,y). o: R body, belly R, ears kind, scale
local function critter(x,y,o)
  local R,B=o.R,o.belly or {hi="#fff0d0",base="#f8dcb0",shade="#d8aa88",deep="#a07070"}
  local sd=o.seed or 5
  local s=o.s or 1
  local function S(v) return floor(v*s+.5) end
  blob(x-S(7),y-S(2),S(6),S(3),R,sd+1,{R=2}); blob(x+S(7),y-S(2),S(6),S(3),R,sd+2,{R=2})
  if o.tail then o.tail(x,y,s) end
  blob(x,y-S(14),S(13),S(14),R,sd+3,{R=S(9)})
  blob(x,y-S(11),S(8),S(10),B,sd+4,{R=5,ink=false,rimlight=false})
  if o.ears=="tall" then for _,k in ipairs{-1,1} do blob(x+k*S(8),y-S(46),S(4),S(11),R,sd+5+k,{R=3}); blob(x+k*S(8),y-S(46),S(2),S(8),{hi="#ffc8c0",base="#f09898",shade="#b86878",deep="#7a4060"},sd,{R=2,ink=false,rimlight=false}) end
  elseif o.ears=="point" then for _,k in ipairs{-1,1} do poly({{x+k*S(4),y-S(40)},{x+k*S(13),y-S(52)},{x+k*S(12),y-S(37)}},R,{R=4}) end
  else for _,k in ipairs{-1,1} do blob(x+k*S(10),y-S(42),S(5),S(5),R,sd+5+k,{R=3}) end end
  blob(x,y-S(33),S(12),S(10),R,sd+6,{R=S(7)})
  if o.snout then blob(x,y-S(29),S(6),S(4),o.snout,sd+7,{R=3,ink=false}) end
  for _,k in ipairs{-1,1} do fill(x+k*S(5)-(k<0 and 1 or 0),y-S(36),x+k*S(5)-(k<0 and 1 or 0)+1,y-S(33),INK); px(x+k*S(5)-(k<0 and 1 or 0),y-S(36),"#fffae8") end
  fill(x-1,y-S(30),x,y-S(30),INK); px(x-S(8),y-S(30),"#ff9aa0"); px(x+S(8),y-S(30),"#ff9aa0")
  px(x-1,y-S(28),INK); px(x,y-S(28),INK); px(x+1,y-S(28),INK)
  if o.hat then o.hat(x,y-S(42),s) end
end
local function stack(x0,x1,y,R,rows,seed) for r=0,rows-1 do for x=x0+(r%2)*3,x1-3,6 do blob(x+3,y-r*5,3,2,R,seed+x+r,{R=2}) end end end
local function hem() c:hem(2,0,479); c:hem(267,0,479) end

local SC={}
------------------------------------------------------------------ 1 lemon grove monastery
SC["haven-lemon-grove-monastery"]=function()
  sky({"#8ab8d8","#a8c8d8","#d0d8d0","#f4dcb0","#ffd098","#ffc080"},170,2)
  cloud(80,40,24,CL,3); cloud(390,60,20,CL,4); cloud(230,28,16,CL,5)
  hills(function(x) return 150+floor(10*sin(x/50)+6*sin(x/17)) end,{hi="#b8d098",base="#7ea870",shade="#527a5c",deep="#34503e"},4,200)
  local yfn=function(x) return 212+floor(2*sin(x/40)) end
  GX.ground(c,yfn,{hi="#d8e078",base="#8ab850",shade="#4a8048",deep="#2e5238"},7,{top=.8,fall=.5})
  -- cypresses
  for _,p in ipairs{{96,212,56},{384,212,60},{40,212,44},{440,212,48}} do blob(p[1],p[2]-p[3]/2,7,p[3]/2+2,{hi="#78a858",base="#3e784a",shade="#285240",deep="#173432"},p[1],{R=5,tex=.5}) end
  -- monastery
  local wall={hi="#fff0cc",base="#f0d09c",shade="#c8946c",deep="#8a5a60"}
  local TILE={hi="#f89a60",base="#d86a44",shade="#a04048",deep="#5e2840"}
  shadow(240,212,140,5,"#5a8040")
  box(120,128,360,212,wall,{R=40,tex=.35,sc=4,seed=3})
  -- tower
  box(214,64,266,130,wall,{R=26,tex=.3,seed=5})
  poly({{208,66},{272,66},{240,28}},TILE,{R=18,seed=6})
  local bm=rc(226,82,254,112); E(bm,240,82,14,12); win(bm,70,112,"#8a5a40",{bars=false})
  blob(240,98,8,9,{hi="#fff0a0",base="#e8b838",shade="#a87030",deep="#603838"},9,{R=6}); fill(238,106,242,109,"#6a3a2a")
  fill(239,56,241,60,INK); px(240,56,"#ffe890") ; fill(238,50,242,50,INK)
  -- roofs
  poly({{112,134},{368,134},{346,112},{134,112}},TILE,{R=26,seed=7,tex=.5,fn=function(x,y) return ((y-112)%5==0) and -.12 or 0 end})
  fill(112,134,368,136,INK); fill(113,135,367,135,TILE.shade)
  -- windows (arched, lit) and door
  for _,x in ipairs{138,168,298,328} do awin(x,150,x+14,186,"#7a4a38"); fill(x-3,187,x+17,188,"#c8946c"); fill(x-3,189,x+17,189,INK) end
  local dm=rc(224,164,256,212); E(dm,240,170,16,12); dm:cut(rc(222,213,258,214)); win(dm,152,212,"#7a4a38")
  fill(218,208,262,212,"#d8b888"); fill(218,212,262,213,INK); fill(214,214,266,215,"#b89068")
  glow(240,222,34,8,"#ffc860",.35)
  lantern(206,170,4,14); lantern(274,170,4,14)
  -- arches row
  for x=134,346,16 do if x<214 or x>262 then end end
  -- lemon trees
  local LEAF={hi="#b8dc68",base="#5ea848",shade="#2e7048",deep="#1a4638"}
  local function ltree(x,by,sc)
    GX.trunk(c,x-3,x+3,by-34,by,{hi="#c8946c",base="#8e5a44",shade="#5a3a40",deep="#33222e"},x)
    GX.foliage(c,x,by-50,floor(34*sc),floor(22*sc),LEAF,x+1)
    for i=1,9 do local a=H(i,x,2)*6.28; local r=sqrt(H(i,x,3)); local lx,ly=floor(x+cos(a)*30*sc*r),floor(by-50+sin(a)*18*sc*r)
      blob(lx,ly,3,3,{hi="#fffaa0",base="#f8d838",shade="#c89828",deep="#785828"},i+x,{R=2}); px(lx-1,ly-1,"#ffffe0") end
  end
  ltree(60,226,1); ltree(430,228,1); ltree(160,240,.7); ltree(330,242,.7)
  -- crates of lemons
  for _,p in ipairs{{20,252},{454,254}} do box(p[1]-14,p[2]-12,p[1]+14,p[2],{hi="#d89860",base="#a8683c",shade="#744238",deep="#44283a"},{R=6,tex=.4}); for k=-12,10,6 do blob(p[1]+k+2,p[2]-14,3,3,{hi="#fffaa0",base="#f8d838",shade="#c89828",deep="#785828"},k,{R=2}) end end
  -- monk mouse
  critter(300,246,{R={hi="#d8b8a0",base="#a88478",shade="#745458",deep="#44303c"},ears="round",seed=4,
    hat=function(x,y,s) poly({{x-14,y+12},{x+14,y+12},{x+10,y-4},{x-10,y-4}},{hi="#b88868",base="#8a5a44",shade="#5a3a40",deep="#33222e"},{R=6}); blob(x,y-6,4,4,{hi="#fffaa0",base="#f8d838",shade="#c89828",deep="#785828"},3,{R=2}) end})
  hem()
end
------------------------------------------------------------------ 2 chilies market
SC["haven-market-of-a-thousand-chilies"]=function()
  sky({"#78c0e8","#98d0ec","#c8e4e0","#f8ecc0","#ffe0a0"},180,2)
  cloud(70,40,22,CL,3); cloud(420,52,18,CL,4)
  hills(function(x) return 150+floor(14*sin(x/70+1)+5*sin(x/13)) end,{hi="#d8a8c8",base="#a878a8",shade="#745890",deep="#4a3c70"},5,200)
  GX.ground(c,function(x) return 210+floor(2*sin(x/30)) end,{hi="#ffe8b0",base="#f0c080",shade="#c8886a",deep="#8a5a5a"},7,{top=.86,fall=.5,tex=.3})
  local AW1={hi="#ff9a88",base="#e8403c",shade="#a02c4c",deep="#601c48"}
  local CRM={hi="#fffae8",base="#ffe8b8",shade="#e0b090",deep="#a07888"}
  local CHI={hi="#ff9068",base="#e83828",shade="#a02040",deep="#5c1838"}
  local ADO={hi="#f8c898",base="#d8905c",shade="#a05c48",deep="#643c48"}
  -- back shop
  shadow(240,212,170,5,"#b88068")
  box(110,104,370,210,ADO,{R=40,tex=.4,sc=3,seed=8})
  box(140,140,340,208,{hi="#a86858",base="#6a3c48",shade="#442840",deep="#2a1c34"},{R=30,tex=.3,rimlight=false,seed=9})
  for i=0,6 do local x=150+i*26; fill(x,160,x+16,162,INK); fill(x,160,x+16,160,"#c88858"); for k=0,3 do blob(x+2+k*4,156,2,3,CHI,x+k,{R=2}) end end -- jar shelf row
  for i=0,5 do blob(158+i*30,184,6,7,{hi="#ffd890",base="#e8a048",shade="#a8604c",deep="#603844"},i,{R=4}) end
  -- awning stripes
  local aw=mk(); for x=96,384 do local y1=136+floor(2*sin(x/6)+1); for y=106,y1 do aw:set(x,y) end end; aw=GX.rough(aw,3,1)
  L(aw,function(x,y) return ((x//12)%2==0) and R6(AW1) or R6(CRM) end,{R=8,tex=.2,seed=4})
  fill(94,102,386,106,INK); fill(95,103,385,104,"#a8683c")
  -- ristras
  local function ristra(x,y,n) fill(x,y-2,x,y+n*6,INK); for i=0,n-1 do local sx=(i%2==0) and -1 or 1; blob(x+sx*2,y+4+i*6,2,4,CHI,x+i,{R=2}); px(x+sx*2,y+1+i*6,"#4a9a48") end end
  for _,x in ipairs{112,148,184,296,332,368} do ristra(x,138,6+(x%3)) end
  for _,x in ipairs{210,270} do lantern(x,146,5,18,"#ff7048") end
  -- counter
  box(150,182,330,212,{hi="#e8a868",base="#b86e44",shade="#82444a",deep="#4a2840"},{R=20,tex=.45,seed=11,fn=function(x,y) return ((y-182)//7%2)*.08 end})
  fill(148,180,332,183,INK); fill(149,181,331,181,"#f4b878")
  for i=0,9 do blob(156+i*18,176,7,5,(i%3==0) and CHI or ((i%3==1) and {hi="#ffe880",base="#f0b838",shade="#b87830",deep="#6a4030"} or {hi="#a8e078",base="#4ea048",shade="#2e7048",deep="#1a4638"}),i+3,{R=4}) end
  -- gecko shopkeeper
  critter(240,176,{R={hi="#c0e878",base="#78b850",shade="#3e8050",deep="#1e4a48"},belly={hi="#f8f8c0",base="#e8e090",shade="#b8a870",deep="#786858"},ears="x",seed=7,
    hat=function(x,y,s) poly({{x-4,y+4},{x+14,y+10},{x+16,y+4},{x-2,y-14}},CHI,{R=6}); fill(x-4,y-15,x-2,y-17,"#4a9a48") end})
  -- side crates
  for _,p in ipairs{{70,214},{410,214}} do
    box(p[1]-24,p[2]-24,p[1]+24,p[2],{hi="#d89860",base="#a8683c",shade="#744238",deep="#44283a"},{R=10,tex=.4}); for k=-20,18,6 do for j=0,2 do blob(p[1]+k+3,p[2]-28+j*2,3,3,j%2==0 and CHI or {hi="#ffa868",base="#f06028",shade="#b03030",deep="#601c40"},k+j,{R=2}) end end end
  -- side stalls awnings
  for _,s in ipairs{{-1,0,100},{1,380,480}} do local x0,x1=s[2],s[3]; local m=c:poly({{x0,60},{x1,60},{x1,90},{x0,90}}); end
  -- flag
  fill(436,70,437,120,INK); poly({{438,70},{470,78},{438,90}},{hi="#ffd870",base="#f0a030",shade="#b86030",deep="#683840"},{R=5})
  hem()
end
------------------------------------------------------------------ 3 northern lights sauna
SC["haven-northern-lights-sauna"]=function()
  sky({"#10143a","#1a2050","#242a62","#2e3a74","#3e5088"},190,2)
  stars(70,100,3)
  local AC={"#3ee8a0","#78f8b8","#a0ffc8"}
  for x=0,479 do local cy=58+floor(26*sin(x/55)+10*sin(x/19+2)); local h=44+floor(14*sin(x/31))
    for k=0,h do local y=cy-floor(h/2)+k; local t=k/h; local col=t<.15 and "#7a58c8" or (t<.3 and "#58a8d8" or (t<.75 and AC[1+((x//3)+k//7)%2] or "#2a9880"))
      if (t>.85 and (x+k)%2==0) then col=nil end; if (t<.12 and (x+k)%2==1) then col=nil end; if col then px(x,y,col) end end end
  hills(function(x) return 168+floor(8*sin(x/45)+4*sin(x/12)) end,{hi="#7888b8",base="#505c98",shade="#34407a",deep="#22285a"},4,205)
  local yfn=function(x) return 208+floor(2*sin(x/37)) end
  GX.ground(c,yfn,{hi="#f8fcff",base="#c8d8f0",shade="#8a9ccc",deep="#5a6aa0"},7,{top=.88,fall=.45,tex=.25})
  local LOG={hi="#e8a868",base="#b8683c",shade="#843c40",deep="#4a2438"}
  shadow(350,210,100,5,"#7888b8")
  box(264,128,436,210,LOG,{R=40,tex=.4,seed=3,fn=function(x,y) return ((y-128)//9%2)*.1-.05-((y-128)%9==0 and .12 or 0) end})
  for y=137,209,9 do fill(264,y,436,y,"#4a2438") end
  for y=128,200,9 do blob(264,y+4,4,4,LOG,y,{R=3}); blob(436,y+4,4,4,LOG,y+1,{R=3}) end
  -- roof with snow
  poly({{250,132},{450,132},{418,92},{282,92}},{hi="#7a5a78",base="#5a3e5e",shade="#3c2a4a",deep="#241a38"},{R=20,seed=5})
  local sn=mk(); for x=246,454 do local t=(x<350) and (x-246)/104 or (454-x)/104; local top=88+floor((1-t)*36*.4+0); for y=top,138-floor(t*0)-floor((x*7)%3) do if y<=138 and ((y<=100+floor((1-t)*30)) or H(x//4,0,3)<.5) then sn:set(x,y) end end end
  local snow=poly({{244,136},{456,136},{424,90},{276,90}},{hi="#ffffff",base="#e8f0ff",shade="#a8b8e0",deep="#6a78b0"},{R=24,seed=6,ink=true})
  for x=252,448,10 do local w=3+floor(H(x,1,2)*3); for y=136,140+floor(H(x,2,3)*5) do if (x-350)^2<(180^2) then fill(x,y,x+w,y,(y>138) and "#a8b8e0" or "#e8f0ff") end end end
  -- chimney + steam
  box(392,62,412,100,{hi="#c0a8b0",base="#8a7488",shade="#5c4a68",deep="#382c48"},{R=8,seed=7}); fill(390,60,414,64,INK); fill(391,61,413,62,"#b8a0b0")
  for i=0,5 do blob(402+floor(sin(i*1.3)*8),52-i*10,6+i,5+floor(i/2),{hi="#ffffff",base="#e8f0f8",shade="#b8c8e0",deep="#8898c0"},i+9,{R=4,ink=false}) end
  -- window + door
  local wm=rc(290,150,324,178); win(wm,150,178,"#6a3a30"); fill(286,179,328,181,"#c88858"); fill(286,182,328,182,INK); glow(307,196,34,9,"#ffb858",.3)
  local dm=rc(370,148,408,210); win(dm,148,210,"#6a3a30"); 
  fill(364,206,414,210,"#c88858"); fill(364,210,414,211,INK)
  lantern(350,160,4,16)
  -- bench with towels
  box(266,194,310,200,{hi="#e8b078",base="#b87848",shade="#82484a",deep="#4a2840"},{R=4}); fill(270,200,272,210,INK); fill(304,200,306,210,INK)
  box(420,196,432,210,{hi="#d8985c",base="#a05c40",shade="#6e3a48",deep="#3c2238"},{R=5}) -- bucket
  -- spruces
  local function spruce(cx,by,h,w)
    fill(cx-2,by-8,cx+2,by,INK); fill(cx-1,by-8,cx+1,by,"#6a3e44")
    local tiers=4
    for t=0,tiers-1 do local ty=by-8-t*floor(h/tiers); local ww=w-t*floor(w/tiers*.7); poly({{cx-ww,ty},{cx+ww,ty},{cx+3,ty-floor(h/tiers)-8},{cx-3,ty-floor(h/tiers)-8}},{hi="#78b888",base="#3e8068",shade="#26584e",deep="#173838"},{R=10,seed=t+cx})
      poly({{cx-ww+3,ty-2},{cx+ww-3,ty-2},{cx+2,ty-floor(h/tiers)-7},{cx-2,ty-floor(h/tiers)-7}},{hi="#ffffff",base="#e8f0ff",shade="#a8b8e0",deep="#6a78b0"},{R=6,ink=false,rimlight=false}) 
      fill(cx-ww,ty,cx+ww,ty,"#26584e") end
  end
  spruce(40,212,92,34); spruce(96,208,70,26); spruce(466,214,86,30)
  -- tub with bear
  shadow(170,236,52,5,"#7888b8")
  blob(170,200,22,16,{hi="#e8d0b0",base="#b88a64",shade="#7a5454",deep="#443040"},3,{R=10}) -- bear head/shoulders
  for _,k in ipairs{-1,1} do blob(170+k*17,184,6,6,{hi="#e8d0b0",base="#b88a64",shade="#7a5454",deep="#443040"},k+9,{R=3}) end
  blob(170,206,10,7,{hi="#f8e8d0",base="#e0c098",shade="#a88470",deep="#704a58"},5,{R=4,ink=false})
  fill(160,196,161,199,INK); fill(179,196,180,199,INK); px(160,196,"#fffae8"); px(179,196,"#fffae8"); fill(168,204,172,205,INK)
  -- towel hat
  box(158,176,182,186,{hi="#ffffff",base="#fff0d8",shade="#e0b8b0",deep="#a07890"},{R=4,tex=.1}); fill(158,181,182,181,"#f0585c")
  local tub=box(138,208,202,244,{hi="#d8985c",base="#a05c40",shade="#6e3a48",deep="#3c2238"},{R=22,tex=.4,fn=function(x,y) return ((x//6)%2)*.07-.035 end})
  fill(136,206,204,210,INK); fill(137,207,203,208,"#f4b878")
  fill(136,222,204,224,"#6a7098"); fill(136,236,204,238,"#6a7098")
  for i=0,3 do blob(160+i*14+floor(sin(i)*5),186-i*12-8,5,4,{hi="#ffffff",base="#e8f0f8",shade="#b8c8e0",deep="#8898c0"},i+20,{R=3,ink=false}) end
  hem()
end
------------------------------------------------------------------ 4 olive press piazza
SC["haven-olive-press-piazza"]=function()
  sky({"#6a78b8","#9a88c0","#d898a8","#f8b890","#ffd898"},150,2)
  cloud(60,40,20,{hi="#ffd8c0",base="#f0a8a8",shade="#b87898",deep="#805080"},3); cloud(400,56,22,{hi="#ffd8c0",base="#f0a8a8",shade="#b87898",deep="#805080"},4)
  local yfn=function(x) return 214 end
  GX.ground(c,yfn,{hi="#e8d8c0",base="#bfa890",shade="#8a7480",deep="#5a4a60"},7,{top=.8,fall=.5,tex=.25})
  for y=216,268,7 do for x=((y//7)%2)*7,479,14 do fill(x,y,x,y+6,"#7a6678") end; fill(0,y,479,y,"#7a6678") end
  local FR={{"#f0b878","#d08850","#9a5848","#5e3848"},{"#f8c8a0","#e0a078","#a86a68","#684050"},{"#e8a898","#c87878","#8a4a64","#522c4c"}}
  local ROOF={hi="#f89a60",base="#d86a44",shade="#a04048",deep="#5e2840"}
  local xs={0,170,330}
  for i,x0 in ipairs{ -6,166,326 } do local w=(i==2) and 156 or 160; local top=(i==2) and 82 or 108; local f=FR[i]
    box(x0,top,x0+w,214,{hi=f[1],base=f[2],shade=f[3],deep=f[4]},{R=40,tex=.35,sc=4,seed=i})
    poly({{x0-8,top+2},{x0+w+8,top+2},{x0+w-6,top-22},{x0+6,top-22}},ROOF,{R=20,seed=i,fn=function(x,y) return ((y-top)%5==0) and -.1 or 0 end})
    fill(x0-8,top+2,x0+w+8,top+4,INK)
    for k=0,2 do local wx=x0+14+k*50; local wy=top+16; if i==2 then wy=top+14 end
      rwin(wx,wy,wx+18,wy+28,"#6a4a38","#e8c8a8"); fill(wx-10,wy-2,wx-3,wy+30,"#3e8070"); fill(wx+21,wy-2,wx+28,wy+30,"#3e8070"); for yy=wy+2,wy+28,4 do fill(wx-9,yy,wx-4,yy,"#26584e"); fill(wx+22,yy,wx+27,yy,"#26584e") end
    end
  end
  -- arcade on middle: dark arches
  for k=0,2 do local ax=186+k*44; local m=rc(ax,160,ax+30,212); E(m,ax+15,160,15,14); c:rim(m,INK); m:each(function(x,y) px(x,y,(y<190) and "#8a4a4a" or "#6a3848") end); glow(ax+15,200,14,10,"#ffb858",.3) end
  fill(168,214,324,215,INK)
  lantern(176,150,4,14); lantern(318,150,4,14)
  -- bunting
  for i=0,40 do local x=floor(i*12); local y=124+floor(10*sin(i*.5)); end
  local function bunt(x0,y0,x1,y1,sag) for i=0,40 do local t=i/40; px(x0+(x1-x0)*t,y0+(y1-y0)*t+sag*4*t*(1-t),INK) end
    local cols={"#f0585c","#ffd060","#58c8d8","#f080a8"}; for i=1,10 do local t=i/11; local x=floor(x0+(x1-x0)*t); local y=floor(y0+(y1-y0)*t+sag*4*t*(1-t)); local col=cols[i%4+1]; fill(x-1,y+1,x+1,y+3,col); px(x-1,y+1,INK);px(x+1,y+1,INK); px(x,y+4,INK) end end
  bunt(10,110,236,100,14); bunt(236,100,470,110,14)
  -- olive press: millstone
  shadow(150,236,64,6,"#7a6678")
  local base=box(86,214,210,236,{hi="#d8d4e8",base="#a8a4c4",shade="#7a74a0",deep="#4a4470"},{R=20,tex=.4,seed=9}); fill(84,212,212,215,INK); fill(85,213,211,213,"#d8d4e8")
  local ms=mk(); E(ms,148,180,36,36); ms=GX.rough(ms,4,1)
  L(ms,{hi="#e8e4f0",base="#b8b4cc",shade="#8a84a8",deep="#54507a"},{R=30,tex=.5,sc=3,seed=4})
  for a=0,15 do local an=a/16*6.28; for r=8,32 do if r%3~=0 then px(148+cos(an)*r,180+sin(an)*r,"#8a84a8") end end end
  blob(148,180,7,7,{hi="#e8b078",base="#b87848",shade="#82484a",deep="#4a2840"},4,{R=4})
  fill(148,100,153,180,INK); fill(149,101,152,179,"#a05c40"); fill(149,101,149,179,"#d8985c")
  box(110,98,190,106,{hi="#e8b078",base="#b87848",shade="#82484a",deep="#4a2840"},{R=5})
  for i=0,3 do blob(96+i*4,232-i%2*3,2,2,{hi="#c8d880",base="#7a9848",shade="#4a6a48",deep="#2a4440"},i,{R=2}) end
  -- amphorae
  local function amph(x,by,h) local m=mk(); for y=by-h,by do local t=(y-(by-h))/h; local w=floor(5+8*sin(t*pi)^.8+ (t>.9 and -2 or 0)); if t<.12 then w=4 end; for xx=x-w,x+w do m:set(xx,y) end end; L(m,{hi="#f8b880",base="#d88858",shade="#a05050",deep="#603448"},{R=9,tex=.4,seed=x}); fill(x-6,by-h+h*.35,x+6,by-h+h*.35+1,"#7a3848") end
  amph(240,238,34); amph(264,236,26)
  -- olive tree right
  GX.trunk(c,396,412,148,224,{hi="#c8a888",base="#8a7078",shade="#5a4a5e",deep="#34283e"},5)
  GX.foliage(c,404,128,52,30,{hi="#c8dc98",base="#8aa86c",shade="#52786a",deep="#305048"},6)
  GX.foliage(c,374,142,26,16,{hi="#c8dc98",base="#8aa86c",shade="#52786a",deep="#305048"},9)
  for i=1,12 do local a=H(i,3,2)*6.28; local r=sqrt(H(i,5,3)); blob(floor(404+cos(a)*46*r),floor(128+sin(a)*24*r),2,2,{hi="#a8b868",base="#5a6a40",shade="#3a4a3c",deep="#22302e"},i,{R=2}) end
  -- table with oil bottles + badger
  shadow(330,248,70,5,"#7a6678")
  critter(324,236,{R={hi="#d8d4d8",base="#908c9c",shade="#5e5a74",deep="#383450"},ears="round",seed=9,
    snout={hi="#ffffff",base="#e8e4e8",shade="#b8b4c0",deep="#807c94"},
    hat=function(x,y,s) box(x-12,y+6,x+12,y+10,{hi="#fff4d8",base="#f0d8b0",shade="#c0a088",deep="#806870"},{R=3}); box(x-8,y-6,x+8,y+6,{hi="#fff4d8",base="#f0d8b0",shade="#c0a088",deep="#806870"},{R=4}) end})
  box(288,224,372,230,{hi="#e8b078",base="#b87848",shade="#82484a",deep="#4a2840"},{R=4}); fill(292,230,296,248,INK); fill(364,230,368,248,INK)
  for i=0,4 do local bx=296+i*14; fill(bx,206,bx+6,222,INK); fill(bx+1,207,bx+5,222,"#b8c848"); px(bx+2,209,"#f0f8a0"); fill(bx+2,200,bx+4,206,INK); px(bx+3,202,"#e8c878") end
  hem()
end
------------------------------------------------------------------ 5 painted egg house
SC["haven-painted-egg-house"]=function()
  sky({"#78c8f0","#98d8f4","#b8e4f0","#d8f0e8"},170,2)
  cloud(80,40,22,CL,3); cloud(380,30,26,CL,4); cloud(250,62,14,CL,5)
  hills(function(x) return 140+floor(16*sin(x/70+2)+4*sin(x/15)) end,{hi="#c8e890",base="#88c068",shade="#4e8e58",deep="#2e5a48"},3,215)
  GX.ground(c,function(x) return 212+floor(2*sin(x/35)) end,{hi="#d0ec78",base="#80bc50",shade="#44844a",deep="#2c5638"},7,{top=.8,fall=.5})
  local WH={hi="#fffaf0",base="#f8e8d0",shade="#d8b0a8",deep="#9c7488"}
  local TH={hi="#ffd878",base="#e0a050",shade="#a8684a",deep="#603a48"}
  shadow(250,214,110,5,"#4e8e58")
  box(160,140,340,214,WH,{R=40,tex=.3,seed=3})
  for x=164,336,44 do fill(x,140,x+3,214,"#a8683c"); end; fill(160,140,340,143,"#a8683c")
  -- thatch gable
  poly({{140,142},{360,142},{300,56},{200,56}},TH,{R=30,tex=.6,sc=3,seed=5,fn=function(x,y) return ((y-56)%6==0) and -.14 or ((H(x//2,y//6,3)-.5)*.2) end})
  poly({{140,142},{360,142},{352,130},{148,130}},TH,{R=6,ink=false,rimlight=false,tex=.2,seed=6})
  fill(138,142,362,145,INK)
  for x=146,354,6 do for k=0,3 do px(x+(k%2),144+k,(k<2) and TH.shade or TH.deep) end end
  fill(244,50,256,58,INK)
  -- egg emblem
  local function egg(cx,cy,rx,ry,c1,c2,pat,seed)
    local m=mk(); for y=cy-ry-1,cy+ry do for x=cx-rx,cx+rx do local ty=(y-cy)/ry; local k=(ty<0) and 1 or .82; local w=rx*sqrt(max(0,1-ty*ty))*(ty<0 and 1 or 1)*(1-(ty<0 and 0 or 0)); if abs(x-cx)<=w*(ty>0 and 1 or (1-.18*(-ty))) then m:set(x,y) end end end
    L(m,function(x,y) local t=(y-(cy-ry))/(2*ry); local band=(pat=="stripe" and floor(t*7)%2==0) and c2 or c1; if pat=="dots" and ((x+y)%6==0 or (x-y)%6==0) then band=c2 end; if pat=="zig" and floor(t*8)%2==0 then band=c2 end; return R6(band) end,{R=max(3,rx),tex=.15,seed=seed or 3})
    return m
  end
  local PINKE={hi="#ffc0d8",base="#f070a0",shade="#b04888",deep="#682c68"}
  local BLUEE={hi="#a8e0f8",base="#58a8e0",shade="#3a6ab0",deep="#26386c"}
  local YELE={hi="#fff8a0",base="#f8d048",shade="#c89030",deep="#785030"}
  local GRNE={hi="#c8f080",base="#68c050",shade="#3e8050",deep="#1e4a48"}
  local REDE={hi="#ff9a88",base="#e8403c",shade="#a02c4c",deep="#601c48"}
  egg(250,98,26,34,REDE,YELE,"zig",8)
  for y=90,108,6 do for x=236,264,7 do px(x+(y%2)*3,y,"#fffae8") end end
  -- door & windows
  local dm=rc(232,164,268,214); E(dm,250,170,18,14); dm:cut(rc(228,215,272,216)); win(dm,152,214,"#7a4a38")
  fill(226,210,274,214,"#d8b888"); fill(226,214,274,215,INK)
  for _,x in ipairs{176,304} do local m=mk(); E(m,x+10,168,12,15); win(m,153,183,"#7a4a38"); fill(x-5,183,x+25,185,"#e8c8a8"); fill(x-5,186,x+25,186,INK); glow(x+10,200,26,6,"#ffc860",.25) end
  lantern(218,166,4,12)
  -- fence with eggs
  for x=20,470,12 do if x<150 or x>350 then fill(x,200,x+6,222,INK); fill(x+1,200,x+5,222,"#f8ecd8"); fill(x+1,200,x+1,222,"#ffffff"); fill(x+5,200,x+5,222,"#d8b8a8"); end end
  fill(20,206,150,208,INK); fill(20,207,150,207,"#d8b8a8"); fill(350,206,470,208,INK); fill(350,207,470,207,"#d8b8a8")
  local ecs={{PINKE,YELE},{BLUEE,YELE},{GRNE,PINKE},{YELE,REDE},{REDE,BLUEE}}
  local i=0; for x=26,470,24 do if x<150 or x>350 then i=i+1; local e=ecs[i%5+1]; egg(x,194,5,6,e[1],e[2],"stripe",i) end end
  -- egg tree
  GX.trunk(c,56,66,70,214,{hi="#c8946c",base="#8e5a44",shade="#5a3a40",deep="#33222e"},3)
  GX.foliage(c,60,66,56,36,{hi="#c8e890",base="#78b060",shade="#3e784a",deep="#245040"},4)
  for k=0,9 do local ex=floor(18+H(k,1,2)*84); local ey=floor(60+H(k,2,2)*46); fill(ex,ey-10,ex,ey-7,INK); local e=ecs[k%5+1]; egg(ex,ey,5,7,e[1],e[2],(k%2==0) and "zig" or "dots",k) end
  -- eggs in grass, basket
  for k=0,5 do local e=ecs[k%5+1]; egg(110+k*13+floor(H(k,5,5)*6),236+floor(H(k,6,2)*12),5,6,e[1],e[2],"stripe",k+5) end
  box(396,236,432,256,{hi="#e8b868",base="#b88040",shade="#845030",deep="#4a2c34"},{R=8,tex=.5,fn=function(x,y) return (((x+y)//3)%2)*.1 end})
  for k=0,3 do egg(402+k*9,234,5,6,ecs[k+1][1],ecs[k+1][2],"stripe",k+9) end
  -- hen
  critter(330,238,{R={hi="#ffffff",base="#f8e8d8",shade="#d0b0a8",deep="#9a7088"},ears="none",seed=6,snout={hi="#ffd878",base="#f0a030",shade="#b86030",deep="#683840"},
    hat=function(x,y,s) blob(x,y+4,4,5,REDE,5,{R=3}); blob(x-5,y+6,3,3,REDE,6,{R=2}) end})
  hem()
end
------------------------------------------------------------------ 6 spice souk
SC["haven-spice-souk"]=function()
  sky({"#2a2a6a","#5a3a8a","#a85a8c","#e88a7c","#ffc080"},150,2)
  hills(function(x) return 100+floor(5*sin(x/22)) end,{hi="#a8689c",base="#7a4a8a",shade="#52387a",deep="#34285a"},3,170)
  for _,p in ipairs{{110,86,120},{190,74,140},{300,70,150},{380,84,124}} do fill(p[1],p[2],p[1]+6,p[3]+30,"#52387a"); blob(p[1]+3,p[2]-2,5,7,{hi="#ffd898",base="#e8a060",shade="#a05c5c",deep="#603c5c"},p[1],{R=3}) end
  local WL={hi="#f8d8a8",base="#e0a878",shade="#a8686c",deep="#643c58"}
  -- big wall w/ three arches cut to dusk
  local wall=box(0,0,479,214,WL,{R=60,tex=.4,sc=4,seed=3,rimlight=false})
  for _,a in ipairs{{90,70},{240,80},{390,70}} do local m=rc(a[1]-a[2]//2,70,a[1]+a[2]//2,214); E(m,a[1],70,a[2]//2,a[2]//2); end
  local function arch(cx,w,yt) local m=rc(cx-w,yt,cx+w,176); E(m,cx,yt,w,w); m:cut(rc(cx-w-2,177,cx+w+2,216))
    c:rim(m,INK); m:each(function(x,y) local v=(y<110) and "#4a3a8a" or ((y<140) and "#9a5a8c" or ((y<158) and "#e8886c" or "#ffb878")); px(x,y,v) end)
    -- skyline
    for k=0,5 do local bx=cx-w+4+k*floor(w/3); local bh=10+floor(H(k,cx,2)*24); fill(bx,176-bh,bx+8,176,"#52387a"); if k%2==0 then blob(bx+4,176-bh-2,4,5,{hi="#a8689c",base="#7a4a8a",shade="#52387a",deep="#34285a"},k,{R=3,ink=false}) end end
    local fr=mk(); fr:add(m:grow(4)); fr:cut(m); L(fr,{hi="#fff4d8",base="#e8c898",shade="#b8806c",deep="#6a4058"},{R=3,rimlight=true,seed=cx}); for a=0,20 do local an=pi+a/20*pi; local rr=w+2; px(cx+cos(an)*rr,yt+sin(an)*rr,(a%2==0) and "#3e8f9a" or "#b8386c") end
  end
  arch(80,50,86); arch(240,56,80); arch(400,50,86)
  -- ceiling fabric
  for x=0,479 do local y1=14+floor(6*sin(x/12)+2*sin(x/5)); for y=0,y1 do local band=((x+y//2)//14)%3; px(x,y,band==0 and "#e8483c" or (band==1 and "#f8c850" or "#3e8f9a")); if y>y1-2 then px(x,y,"#6a2840") end end end
  -- hanging brass lanterns
  for _,p in ipairs{{40,60},{160,70},{240,50},{320,70},{440,60}} do fill(p[1],20,p[1],p[2]-6,INK); lantern(p[1],p[2],6,22,"#ffa040"); fill(p[1]-2,p[2]-9,p[1]+2,p[2]-7,"#b88038") end
  -- shelves back-left with jars
  -- rug floor
  local rug=mk(); for y=214,269 do for x=0,479 do rug:set(x,y) end end
  L(rug,function(x,y) local k=((x//12)+(y//10))%2; return R6(k==0 and {hi="#e8685c",base="#b8384c",shade="#7a2848",deep="#4a1c40"} or {hi="#f8c870",base="#d89040",shade="#9a5a48",deep="#5a3444"}) end,{R=2,tex=.2,ink=false,rimlight=false,seed=3})
  for x=0,479,12 do px(x+6,222,"#fff0c0"); px(x+6,232,"#fff0c0") end
  fill(0,214,479,215,INK)
  -- counter
  box(60,176,420,214,{hi="#e8a868",base="#b86e44",shade="#82444a",deep="#4a2840"},{R=22,tex=.45,seed=11,fn=function(x,y) return ((y-176)//9%2)*.07 end})
  fill(58,174,422,177,INK); fill(59,175,421,175,"#f4b878")
  for x=70,410,34 do fill(x,184,x+16,206,"#4a2840"); fill(x+3,188,x+13,202,"#fff0c0"); px(x+6,192,"#4a2840") end
  -- spice cones
  local SP={{"#fff0a0","#f8c820","#c88a20","#784a28"},{"#ff9a70","#e8402c","#a02438","#601c40"},{"#e8a878","#a8683c","#744038","#44283a"},{"#b0e078","#58a048","#2e7048","#1a4638"},{"#d8a0f0","#8c4cc0","#5c2c90","#341c60"},{"#ffd090","#f08c28","#b0502c","#683038"},{"#ff90b8","#d83c80","#982858","#581c48"}}
  local pos={92,138,184,298,344,390,436}
  for i,x in ipairs(pos) do local s=SP[i]; local m=c:poly({{x-18,174},{x+18,174},{x+2,150},{x-2,150}}); L(m,{hi=s[1],base=s[2],shade=s[3],deep=s[4]},{R=14,tex=.45,seed=i}); fill(x-22,172,x+22,175,INK); fill(x-21,173,x+21,173,s[1]) ; fill(x-21,174,x+21,174,s[3]) end
  -- fennec shopkeeper
  critter(240,176,{R={hi="#fff0d0",base="#f8c890",shade="#d08868",deep="#8a5060"},belly={hi="#ffffff",base="#fff0e0",shade="#e8c8b0",deep="#a88088"},ears="tall",seed=8,
    hat=function(x,y,s) box(x-8,y+4,x+8,y+16,{hi="#ff9a88",base="#e8403c",shade="#a02c4c",deep="#601c48"},{R=4}); fill(x-1,y+2,x+1,y+4,"#ffd860"); fill(x+4,y+2,x+5,y+14,"#f8c850") end})
  glow(240,208,60,10,"#ffc060",.25)
  -- sacks
  for _,p in ipairs{{24,238},{456,238}} do local m=mk(); E(m,p[1],p[2],20,22); m=GX.rough(m,p[1],1); L(m,{hi="#f8e8c8",base="#d8b888",shade="#a08068",deep="#644858"},{R=14,tex=.4,seed=p[1]}); fill(p[1]-6,p[2]-24,p[1]+6,p[2]-20,"#a08068"); blob(p[1],p[2]-6,8,5,{hi="#ffd898",base="#e89838",shade="#a85a38",deep="#603438"},9,{R=4}) end
  hem()
end
------------------------------------------------------------------ 7 thatchtop tearoom
SC["haven-thatchtop-tearoom"]=function()
  sky({"#b8a8d8","#d0b8d8","#f0c8d0","#ffd8c0","#ffe8c8"},170,2)
  cloud(70,44,22,{hi="#fff0f0",base="#f8d0d8",shade="#d8a0b8",deep="#a07898"},3); cloud(400,36,24,{hi="#fff0f0",base="#f8d0d8",shade="#d8a0b8",deep="#a07898"},4)
  hills(function(x) return 150+floor(12*sin(x/60)+4*sin(x/14)) end,{hi="#b8d0a0",base="#78a888",shade="#4a7a74",deep="#2e5058"},3,215)
  GX.ground(c,function(x) return 214+floor(1*sin(x/35)) end,{hi="#c8e078",base="#7cb450",shade="#448048",deep="#2c5238"},7,{top=.8,fall=.5})
  local WH={hi="#fffaf0",base="#f4e0c8",shade="#d0a8a0",deep="#946e84"}
  local TH={hi="#f8d070",base="#d09848",shade="#946048",deep="#563848"}
  shadow(240,216,170,5,"#4a7a50")
  box(90,142,390,214,WH,{R=50,tex=.3,seed=3})
  for x=96,384,48 do fill(x,142,x+3,214,"#8a5a40") end; fill(90,142,390,145,"#8a5a40"); fill(90,176,390,178,"#8a5a40")
  -- hip thatch
  poly({{66,148},{414,148},{350,70},{130,70}},TH,{R=40,tex=.6,sc=3,seed=5,fn=function(x,y) return ((y-70)%6==0) and -.14 or ((H(x//2,y//6,3)-.5)*.2) end})
  fill(64,148,416,151,INK); for x=70,410,6 do for k=0,3 do px(x+(k%2),150+k,(k<2) and TH.shade or TH.deep) end end
  -- chimney
  box(332,40,356,84,{hi="#e8b098",base="#b87868",shade="#82484e",deep="#4a2c3e"},{R=8,seed=7}); fill(330,38,358,42,INK); fill(331,39,357,40,"#e8b098")
  for i=0,4 do blob(344+floor(sin(i*1.1)*8),30-i*8,5+i,4+i//2,{hi="#ffffff",base="#f4ecf0",shade="#d0b8d0",deep="#a890b8"},i+9,{R=4,ink=false}) end
  -- eyebrow dormers
  for _,x in ipairs{160,320} do local m=mk(); E(m,x,112,22,12); m:cut(rc(x-30,112,x+30,130)); m=GX.rough(m,x,1); L(m,TH,{R=8,tex=.5,seed=x}); local wm=rc(x-10,106,x+10,120); E(wm,x,108,10,6); win(wm,102,120,"#7a4a38",{bars=false}); end
  -- round windows + door
  for _,x in ipairs{128,352} do local m=mk(); E(m,x,176,16,16); m:cut(rc(x-18,176-10-40,x+18,176-17)); win(m,160,192,"#7a4a38"); local r=mk(); r:add(m:grow(3)); r:cut(m); L(r,{hi="#c8946c",base="#8e5a44",shade="#5a3a40",deep="#33222e"},{R=3,seed=x}); glow(x,222,30,6,"#ffc860",.25) end
  for _,x in ipairs{128,352} do end
  local dm=rc(220,162,260,214); E(dm,240,168,20,14); dm:cut(rc(214,215,266,216)); win(dm,148,214,"#7a4a38")
  fill(214,210,266,214,"#d8b888"); fill(214,214,266,215,INK)
  -- teapot sign
  fill(280,150,296,150,INK); fill(296,150,296,168,INK)
  local tp=mk(); E(tp,284,170,11,9); L(tp,{hi="#ffffff",base="#e8e0f0",shade="#b8a8d0",deep="#7a6898"},{R=8,seed=3}); fill(272,167,275,168,INK); blob(293,168,4,3,{hi="#ffffff",base="#e8e0f0",shade="#b8a8d0",deep="#7a6898"},4,{R=2}); fill(282,159,286,161,"#e8586c")
  lantern(206,168,4,12); lantern(274,198,3,0)
  -- stepping path
  for k=0,5 do local y=216+k*8; local w=22+k*4; blob(240+floor(sin(k*2)*8),y+4,w,4,{hi="#e8dcc8",base="#bfae98",shade="#8a7a88",deep="#5a4a64"},k+30,{R=3}) end
  -- cherry tree
  GX.trunk(c,436,446,120,224,{hi="#c8946c",base="#8e5a44",shade="#5a3a40",deep="#33222e"},3)
  GX.foliage(c,438,100,54,36,{hi="#ffe0e8",base="#f4a0c0",shade="#c0689c",deep="#7a3c78"},4)
  GX.foliage(c,404,120,26,18,{hi="#ffe0e8",base="#f4a0c0",shade="#c0689c",deep="#7a3c78"},8)
  for i=0,12 do px(400+H(i,1,1)*70,230+H(i,2,1)*30,"#f8b8d0") end
  -- tea table + hedgehog waiter
  box(396,226,442,232,{hi="#ffffff",base="#f4e8f0",shade="#c8b0d0",deep="#8a7098"},{R=4}); fill(416,232,420,254,INK); fill(417,232,419,254,"#c8b0d0")
  for _,x in ipairs{402,434} do box(x-5,216,x+5,226,{hi="#ffffff",base="#e8e0f0",shade="#b8a8d0",deep="#7a6898"},{R=4}); fill(x-3,218,x+3,219,"#a8683c") end
  critter(120,254,{R={hi="#d8b090",base="#a07858",shade="#6e4a50",deep="#40283c"},ears="round",seed=4,snout={hi="#fff0d8",base="#f0d0a8",shade="#c09078",deep="#7a5060"},
    hat=function(x,y,s) for k=-12,12,4 do poly({{x+k,y+16},{x+k+3,y+16},{x+k+10,y-6}},{hi="#c89870",base="#7a5058",shade="#4a3044",deep="#2c1c34"},{R=3,ink=false,rimlight=false}) end; box(x-8,y+10,x+8,y+14,{hi="#ffffff",base="#e8d8f0",shade="#b8a0d0",deep="#7a6898"},{R=3}) end})
  -- teapot tray
  local tp2=mk(); E(tp2,148,226,9,7); L(tp2,{hi="#ffffff",base="#e8586c",shade="#a03058",deep="#601c48"},{R=6,seed=5}); fill(138,224,140,225,INK); fill(156,224,159,227,INK); fill(146,217,150,219,INK)
  box(134,232,164,234,{hi="#fff4d8",base="#e8d0a8",shade="#b09078",deep="#6e5068"},{R=2})
  hem()
end
------------------------------------------------------------------ 8 sugar shack
SC["haven-the-sugar-shack"]=function()
  sky({"#9ac4e8","#b8d4ec","#d8e4ee","#f4e8dc","#ffe4c0"},170,2)
  cloud(80,44,22,CL,3); cloud(360,34,26,CL,4)
  hills(function(x) return 152+floor(14*sin(x/65)+4*sin(x/15)) end,{hi="#f0f0ff",base="#c0c8e0",shade="#8a90b8",deep="#586088"},3,215)
  for x=0,479,4 do if H(x,1,2)<.5 then local y=floor(152+14*sin(x/65)+4*sin(x/15)); fill(x,y+8,x+2,y+34,"#4a3448") end end
  GX.ground(c,function(x) return 212+floor(2*sin(x/38)) end,{hi="#ffffff",base="#e8eefc",shade="#a8b4dc",deep="#6e7cac"},7,{top=.9,fall=.4,tex=.2})
  local LOG={hi="#e8a868",base="#b8683c",shade="#843c40",deep="#4a2438"}
  shadow(250,214,110,5,"#9aa8d0")
  box(150,126,350,212,LOG,{R=40,tex=.4,seed=3,fn=function(x,y) return ((y-126)//9%2)*.1-.05 end})
  for y=135,211,9 do fill(150,y,350,y,"#4a2438") end
  -- roof & snow
  poly({{136,130},{364,130},{320,84},{180,84}},{hi="#c88a68",base="#8a4a4a",shade="#5a3248",deep="#34223c"},{R=26,seed=5,fn=function(x,y) return ((y-84)%6==0) and -.12 or 0 end})
  poly({{132,132},{368,132},{322,78},{178,78}},{hi="#ffffff",base="#e8f0ff",shade="#a8b8e0",deep="#6a78b0"},{R=28,seed=6})
  poly({{150,138},{350,138},{322,98},{180,98}},{hi="#c88a68",base="#8a4a4a",shade="#5a3248",deep="#34223c"},{R=26,seed=5})
  for x=140,360,9 do local w=3+floor(H(x,1,2)*3); for y=134,138+floor(H(x,2,3)*4) do fill(x,y,x+w,y,"#e8f0ff") end end
  -- cupola
  box(224,52,276,86,LOG,{R=14,seed=9}); fill(230,60,270,78,"#34223c")
  for x=232,264,6 do fill(x,58,x+3,80,"#5a3248") end
  poly({{218,54},{282,54},{262,38},{238,38}},{hi="#ffffff",base="#e8f0ff",shade="#a8b8e0",deep="#6a78b0"},{R=10})
  for i=0,6 do blob(250+floor(sin(i*1.2)*12),28-i*9,8+i,6+i//2,{hi="#ffffff",base="#f4f4fc",shade="#d0d8ec",deep="#a0acd0"},i+9,{R=5,ink=false}) end
  -- open front with fire and pan
  local op=rc(188,152,312,212); c:rim(op,INK); op:each(function(x,y) px(x,y,(y<178) and "#5a3248" or "#3c2438") end)
  glow(250,190,70,40,"#ff9040",.3)
  box(196,184,304,196,{hi="#c0c0d0",base="#8a8aa0",shade="#545470",deep="#2c2c44"},{R=6,seed=3}); fill(200,180,300,186,"#d89040"); fill(200,180,300,181,"#ffd878")
  for k=0,6 do blob(206+k*14,176-(k%2)*2,5,3,{hi="#ffffff",base="#fff0c8",shade="#e8c890",deep="#b8906c"},k,{R=3,ink=false}) end
  for k=0,5 do local fx=204+k*18; poly({{fx,212},{fx+14,212},{fx+8,198},{fx+4,196}},{hi="#fff0a0",base="#ff9a38",shade="#e8402c",deep="#8a2038"},{R=6,ink=false,rimlight=false}) end
  fill(188,208,312,212,"#3a2a38"); fill(188,212,312,213,INK)
  -- window
  local wm=rc(160,150,180,174); win(wm,150,174,"#6a3a30"); local wm2=rc(320,150,340,174); win(wm2,150,174,"#6a3a30"); fill(156,175,184,176,"#c88858"); fill(316,175,344,176,"#c88858")
  lantern(176,196,4,14)
  -- woodpile
  for r=0,3 do for k=0,6-r do blob(76+k*13+r*6,206-r*10,6,5,{hi="#e8b078",base="#b87848",shade="#82484a",deep="#4a2840"},k+r*9,{R=3}); fill(76+k*13+r*6-1,206-r*10-1,76+k*13+r*6+1,206-r*10+1,"#e8c898") end end
  -- maple trees with buckets
  local function maple(x,by,sd)
    GX.trunk(c,x-6,x+6,by-110,by,{hi="#b89888",base="#786068",shade="#4a3a50",deep="#2c2038"},sd)
    for _,b in ipairs{{-34,-92,-1},{30,-84,1},{-26,-110,-1}} do for k=0,10 do px(x+b[3]*(8+k*2.4),by+b[2]-k*3,INK); px(x+b[3]*(9+k*2.4),by+b[2]-k*3,"#4a3448") end end
    for _,b in ipairs{{-22,-56,-1},{20,-70,1}} do fill(x+b[1]-4,by+b[2]-4,x+b[1]+4,by+b[2]+8,INK); fill(x+b[1]-3,by+b[2]-3,x+b[1]+3,by+b[2]+7,"#a8aac0"); fill(x+b[1]-3,by+b[2]-3,x+b[1]-2,by+b[2]+7,"#e0e0f0"); fill(x+b[1]-3,by+b[2]-3,x+b[1]+3,by+b[2]-2,"#fff0c0") end
    GX.foliage(c,x,by-122,44,22,{hi="#ffb868",base="#e8683c",shade="#a8403e",deep="#5a2840"},sd+4)
  end
  maple(60,222,3); maple(430,226,5)
  -- barrel + squirrel
  local bar=mk(); for y=196,236 do local t=(y-196)/40; local hw=floor(18+3*sin(t*pi)); for x=396-hw,396+hw do bar:set(x,y) end end
  -- (barrel moved right of shack)
  shadow(392,238,34,4,"#9aa8d0")
  bar=mk(); for y=210,238 do local t=(y-210)/28; local hw=floor(16+3*sin(t*pi)); for x=388-hw,388+hw do bar:set(x,y) end end; L(bar,{hi="#e8a868",base="#b86e44",shade="#82444a",deep="#4a2840"},{R=16,tex=.4,seed=3,fn=function(x,y) return ((x//6)%2)*.07 end})
  for _,by in ipairs{216,232} do fill(370,by,406,by+1,"#6a7098") end
  fill(374,208,402,211,INK); fill(375,209,401,209,"#ffb838")
  critter(300,248,{R={hi="#f0b078",base="#c87848",shade="#8a4a4a",deep="#4c2c3c"},ears="point",seed=6,
    tail=function(x,y,s) blob(x+16,y-26,10,22,{hi="#f0b078",base="#c87848",shade="#8a4a4a",deep="#4c2c3c"},9,{R=6}) end,
    hat=function(x,y,s) fill(x+12,y+10,x+14,y+30,INK); fill(x+13,y+12,x+13,y+30,"#a8683c"); blob(x+13,y+8,5,4,{hi="#e0e0f0",base="#a8aac0",shade="#6a6e90",deep="#40445c"},4,{R=3}) end})
  hem()
end
------------------------------------------------------------------ 9 turtle nesting beach
SC["haven-turtle-nesting-beach"]=function()
  sky({"#161840","#201e5a","#2c2c72","#3e3c88","#5a4a98"},150,2)
  stars(90,110,4)
  local mc="#fff4c8"; local m=mk(); E(m,360,52,24,24); L(m,{hi="#fffbe8",base="#ffe898",shade="#e8b870",deep="#b88068"},{R=20,tex=.2,seed=3,ink=false,rimlight=false}); for _,p in ipairs{{352,46,4},{368,58,3},{362,40,2}} do blob(p[1],p[2],p[3],p[3],{hi="#f8d888",base="#e8b870",shade="#c89068",deep="#a07060"},p[1],{R=2,ink=false,rimlight=false}) end
  glow(360,52,50,50,"#8878d0",.1)
  GX.bands(c,150,200,{"#2c3c88","#2a4c94","#2a5c9c","#3e74ac","#5a8cb8"},5,.2)
  for i=0,40 do local y=152+floor(H(i,1,3)*40); local x=360+floor((H(i,2,3)-.5)*(14+(y-150)*1.4)); fill(x,y,x+2+i%5,y,(i%2==0) and "#fff0b0" or "#ffd880") end
  for i=0,50 do fill(floor(H(i,7,1)*470),152+floor(H(i,8,1)*44),floor(H(i,7,1)*470)+3,152+floor(H(i,8,1)*44),"#5a8cb8") end
  local yfn=function(x) return 198+floor(3*sin(x/41)+2*sin(x/11+1)) end
  GX.ground(c,yfn,{hi="#e8d8f0",base="#b8a8d8",shade="#7a6aa8",deep="#4a4078"},7,{top=.86,fall=.5,tex=.3})
  for x=0,479 do local y0=yfn(x); px(x,y0-1,"#ffffff"); px(x,y0,"#e8f0ff"); px(x,y0+1,"#8ab0d8"); if GX.vn(x,3,5,9)>.5 then px(x,y0-2,"#d0e0f8") end end
  -- hut
  local TH={hi="#ffd878",base="#e0a050",shade="#a8684a",deep="#603a48"}
  shadow(402,228,70,5,"#4a4078")
  box(350,176,440,228,{hi="#e8a868",base="#b86e44",shade="#82444a",deep="#4a2840"},{R=30,tex=.45,seed=3,fn=function(x,y) return ((x-350)//8%2)*.08 end})
  for x=350,440,8 do fill(x,176,x,228,"#4a2840") end
  poly({{336,182},{454,182},{424,134},{366,134}},TH,{R=24,tex=.6,seed=4,fn=function(x,y) return ((y-134)%6==0) and -.14 or 0 end}); fill(334,182,456,185,INK)
  local wm=rc(372,194,396,216); win(wm,194,216,"#6a3a30"); fill(368,217,400,218,"#c88858"); glow(384,236,34,7,"#ffc060",.28)
  local dm=rc(410,194,430,228); win(dm,194,228,"#6a3a30")
  lantern(344,196,4,14)
  -- campfire
  for k=-1,1 do poly({{300+k*6,228},{310+k*6,228},{306+k*6,214},{304+k*6,212}},{hi="#fff0a0",base="#ff9a38",shade="#e8402c",deep="#8a2038"},{R=6,ink=false,rimlight=false}) end
  fill(292,228,318,231,INK); fill(293,229,317,230,"#6a3e44"); glow(305,222,34,12,"#ff9040",.25)
  -- mama turtle
  local TT={hi="#c8e478",base="#6cb850",shade="#3a8050",deep="#1e4a48"}
  shadow(150,246,90,6,"#4a4078")
  blob(66,230,12,7,TT,3,{R=4}); blob(228,236,14,7,TT,4,{R=4}); blob(86,246,14,6,TT,5,{R=4}); blob(214,248,16,6,TT,6,{R=4})
  local sh=mk(); E(sh,150,208,70,38); sh:cut(rc(70,236,236,250)); sh=GX.rough(sh,8,1)
  L(sh,function(x,y) return R6({hi="#a8d870",base="#4a9448",shade="#2e6444",deep="#1a3a40"}) end,{R=34,tex=.3,sc=3,seed=8,fn=function(x,y) local u=((x+4)%24); local v=((y+((x+4)//24%2)*7)%14); return (u<2 or v<2) and -.22 or 0 end})
  fill(84,236,216,240,"#e8c878")
  local hd=blob(228,214,18,15,TT,9,{R=12}); fill(232,208,235,212,INK); px(232,208,"#fffae8"); fill(242,222,250,222,INK); fill(240,226,246,226,"#ff8aa0")
  blob(226,224,8,3,{hi="#f8f0b0",base="#e8d078",shade="#b8a068",deep="#786858"},2,{R=2,ink=false})
  -- hatchlings
  for k=0,5 do local x=256+k*34; local y=246+floor(sin(k*1.7)*6); blob(x,y,5,3,TT,k+20,{R=2}); blob(x+5,y-1,2,2,TT,k+30,{R=1}); px(x+6,y-2,INK); px(x-4,y+3,TT.shade); px(x+4,y+3,TT.shade) end
  -- eggs nest
  blob(36,244,22,6,{hi="#b89ad8",base="#8a78b8",shade="#5a4a90",deep="#38306a"},4,{R=5})
  for k=0,3 do blob(26+k*7,240-(k%2),4,5,{hi="#ffffff",base="#fff0e8",shade="#d8b8c8",deep="#9878a0"},k,{R=3}) end
  -- foam sparkles
  for i=0,12 do local x=floor(H(i,3,3)*470); c:sparkle(x,194) end
  hem()
end

local name=app.params.name or "all"
for n,f in pairs(SC) do
  if name=="all" or name==n then
    c=HP.canvas{w=480,h=270,scale=1,name=n}; f()
    c:save{aseprite=d.."/out/"..n..".aseprite",png=d.."/out/"..n..".png",scale=1}
  end
end
