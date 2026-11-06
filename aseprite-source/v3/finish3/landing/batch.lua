-- landing illustrations v3. Param: name=almanac|cook|games|garden|roads|stats|hero|all
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local H, INK, vn = X.hash, GX.INK, GX.vn
local c
local function r(v) return floor(v + .5) end
local function R6(hi, base, shade, deep) return GX.ramp6{hi=hi, base=base, shade=shade, deep=deep} end
local mix = GX.mix
local RED = R6("#ff8a5c","#e8493b","#b52e3f","#6e2038")
local GRN = R6("#c8f070","#58b050","#2e7648","#1c4a40")
local YEL = R6("#fff0a0","#f5c43a","#d0802a","#8f4a1f")
local CRM = R6("#fff6dc","#f4dcaa","#c89a74","#7e5460")
local WOOD= R6("#e8aa6a","#b8703c","#7e4434","#442636")
local PNK = R6("#ffb0d0","#e8589a","#a83a7e","#5e2460")
local BLU = R6("#8ac0f0","#4a78d0","#3a4a98","#222a5c")
local PUR = R6("#d8a8f0","#9a58c8","#683a98","#38225e")
local IRN = R6("#9a98b4","#625e82","#403a60","#241c34")
local ORG = R6("#ffc070","#f08a30","#c2562c","#703028")
local SKN = R6("#ffd9b0","#f2a878","#c46c5a","#7a3c48")
local WHT = R6("#fffaf0","#ece4e0","#b8aac4","#7a6a8c")
local SOIL= R6("#8a5a44","#5e3a38","#3e2430","#241620")
local SNL = R6("#ffd070","#e89a38","#b8602e","#6a3030")
local PEA = R6("#ffd0b8","#f09a88","#c0605e","#703048")

local function M() return HP.mask() end
local function E(cx,cy,rx,ry) return c:ellipse(cx,cy,rx,ry) end
local function Pl(p) return c:poly(p) end
local function Rc(x0,y0,x1,y1) return c:rect(x0,y0,x1,y1) end
local function Rr(x0,y0,x1,y1,k) return c:rrect(x0,y0,x1,y1,k) end
local function obj(m, R, seed, o)
  o = o or {}
  return GX.lit(c, m, R, { R=o.R or 5, seed=seed or 1, tex=o.tex or .2, amb=.25, wrap=.3, rimlight=o.rim, fn=o.fn, ink=o.ink })
end
local function px(x,y,col) c:px(r(x),r(y),col) end
local function L(x0,y0,x1,y1,col,w) c:fillMask(c:line({{x0,y0},{x1,y1}}, w or 1), col) end

local function bg(y0,y1,cols,seed,tex)
  for y=y0,y1 do for x=0,c.w-1 do
    local t=(y-y0)/(y1-y0)+(vn(x,y,18,seed)-.5)*(tex or .12)
    c:px(x,y,cols[max(1,min(#cols,floor(t*#cols)+1))])
  end end
end
local function hills(yfn,R,seed,o)
  o=o or {}
  local R6s=R
  for x=0,c.w-1 do
    local y0=r(yfn(x))
    for y=y0,c.h-1 do
      local t=(y-y0)/max(1,c.h-y0)
      local v=(o.top or .8)-(o.fall or .45)*t+(vn(x,y,6,seed)-.5)*.4
      if y==y0 then v=.95 end
      c:px(x,y,R6s[GX.idx(v)])
    end
  end
end
local function border(col, inset)
  inset=inset or 4
  for x=inset,c.w-1-inset do if (x%5)<3 then c:px(x,inset,col); c:px(x,c.h-1-inset,col) end end
  for y=inset,c.h-1-inset do if (y%5)<3 then c:px(inset,y,col); c:px(c.w-1-inset,y,col) end end
end
local function spark(x,y,s,col)
  local k=s*.3
  local m=Pl{{x,y-s},{x+k,y-k},{x+s,y},{x+k,y+k},{x,y+s},{x-k,y+k},{x-s,y},{x-k,y-k}}
  c:rim(m,INK); c:fillMask(m,col or YEL[5]); px(x,y,"#fff6dc")
end
local function tuft(x,y) GX.tuft(c,x,y,{shade="#3f8a4c",base="#6cbc58",hi="#b0e070"}) end
local function shadow(cx,cy,rx,ry,col)
  local m=E(cx,cy,rx,ry); c:fillMask(m,col)
end

-- props
local function mush(cx,by,w,h,R,seed,spots,stemR)
  local sw=r(w*.34)
  local stem=Rr(cx-sw,by-r(h*.55),cx+sw,by,3)
  obj(stem,stemR or CRM,seed+1,{R=3})
  local cap=GX.disc(M(),cx,by-r(h*.5),r(w/2),r(h*.5))
  cap:clip(Rc(cx-w,by-h,cx+w,by-r(h*.5)+1))
  obj(cap,R,seed,{R=6,rim=true})
  for _,s in ipairs(spots or {}) do
    local sm=E(cx+s[1],by-r(h*.5)+s[2],s[3],max(1,s[3]-1)); sm:clip(cap)
    c:fillMask(sm,CRM[6])
  end
end
local function sprout(x,by,s)
  s=s or 1
  L(x,by,x,by-r(7*s),GRN[2],2)
  local a=Pl{{x,by-r(6*s)},{x-r(9*s),by-r(10*s)},{x-r(6*s),by-r(4*s)}}
  local b=Pl{{x+1,by-r(7*s)},{x+r(9*s),by-r(12*s)},{x+r(6*s),by-r(5*s)}}
  obj(a,GRN,3,{R=2}); obj(b,GRN,4,{R=2})
end
local function tomato(cx,cy,rad,seed)
  obj(GX.disc(M(),cx,cy,rad,rad),RED,seed,{R=rad})
  local lf=Pl{{cx-r(rad*.6),cy-rad},{cx,cy-rad-2},{cx+r(rad*.6),cy-rad},{cx,cy-rad+2}}
  c:fillMask(lf,GRN[4]); px(cx,cy-rad-3,GRN[2]); px(cx,cy-rad-4,GRN[2])
end
local function carrot(cx,top,len,w,seed)
  for i=-1,1 do
    local lf=E(cx+i*4,top-6,2,6); obj(lf,GRN,seed+i+5,{R=2})
  end
  local m=Pl{{cx-w,top},{cx+w,top},{cx+1,top+len},{cx-1,top+len}}
  obj(m,ORG,seed,{R=w})
  for k=1,3 do local y=top+r(len*k/4); L(cx-w+2,y,cx-1,y,ORG[3],1) end
end
local function bread(cx,cy,rx,ry,seed)
  obj(E(cx,cy,rx,ry),SNL,seed,{R=6})
  for k=-1,1 do L(cx+k*6-2,cy-ry+3,cx+k*6+2,cy+ry-4,SNL[2],1) end
end
local function coin(cx,cy,rad,seed)
  obj(GX.disc(M(),cx,cy,rad,rad),YEL,seed,{R=rad})
  local ring=GX.disc(M(),cx,cy,rad-3,rad-3); ring:cut(GX.disc(M(),cx,cy,rad-4,rad-4)); c:fillMask(ring,YEL[3])
  c:fillMask(Rc(cx-1,cy-4,cx+1,cy+4),YEL[3]); c:fillMask(Rc(cx-4,cy-1,cx+4,cy+1),YEL[3])
end
local function crescent(cx,cy,rad,col)
  local m=GX.disc(M(),cx,cy,rad,rad); m:cut(GX.disc(M(),cx+r(rad*.55),cy-r(rad*.3),r(rad*.85),r(rad*.85)))
  obj(m,col,9,{R=4})
end

local function gnome(cx,fy,u,o)
  o=o or {}
  local function q(dx,dy) return {r(cx+dx*u),r(fy+dy*u)} end
  local function e(dx,dy,rx,ry) return E(r(cx+dx*u),r(fy+dy*u),max(1,r(rx*u)),max(1,r(ry*u))) end
  obj(e(-7,-3,6,3.5),WOOD,2,{R=3}); obj(e(7,-3,6,3.5),WOOD,3,{R=3})
  obj(e(0,-17,15,14),o.coat or BLU,4,{R=8})
  local belt=Rc(r(cx-14*u),r(fy-14*u),r(cx+14*u),r(fy-12*u+.5)); belt:clip(e(0,-17,15,14)); c:fillMask(belt,WOOD[3])
  c:fillMask(Rc(r(cx-1*u),r(fy-15*u),r(cx+1*u),r(fy-11*u)),YEL[5])
  obj(e(-15,-20,5,5),SKN,5,{R=3}); obj(e(15,-20,5,5),SKN,6,{R=3})
  obj(e(0,-50,10,9),SKN,7,{R=5})
  local bd=Pl{q(-10,-47),q(10,-47),q(9,-36),q(4,-25),q(0,-20),q(-4,-25),q(-9,-36)}
  obj(bd,WHT,8,{R=5,tex=.12})
  obj(e(0,-47,3.5,3),SKN,9,{R=2})
  local ew=max(1,r(1.5*u))
  c:fillMask(Rc(r(cx-5*u),r(fy-53*u),r(cx-5*u)+ew-1,r(fy-53*u)+ew),INK)
  c:fillMask(Rc(r(cx+4*u),r(fy-53*u),r(cx+4*u)+ew-1,r(fy-53*u)+ew),INK)
  local hat=Pl{q(-14,-58),q(14,-58),q(10,-78),q(5,-97),q(-1,-97),q(-7,-78)}
  obj(hat,o.hat or RED,10,{R=7,rim=true})
  obj(e(0,-58,16,4),R6("#f06a50","#c8383a","#8a2840","#4e1c34"),11,{R=3})
  obj(e(2,-98,4,4),YEL,12,{R=3})
end

----------------------------------------------------------------------- scenes
local S={}

function S.almanac()
  bg(0,159,{"#fbefd8","#f8e6c8","#f4dcb4"},1,.1)
  hills(function(x) return 112+sin(x*.03)*2 end,R6("#e8b878","#c48c54","#94603c","#5e3a34"),3)
  border("#e2c090")
  shadow(120,134,86,10,"#8a5a3c")
  -- cover
  local cov=Pl{{36,46},{120,54},{204,46},{204,112},{120,120},{36,112}}
  obj(cov,WOOD,2,{R=4})
  local lp=Pl{{44,48},{118,55},{118,112},{44,106}}
  local rp=Pl{{122,55},{196,48},{196,106},{122,112}}
  local pg=function(x,y) return 0 end
  obj(lp,CRM,3,{R=3,tex=.08}); obj(rp,CRM,4,{R=3,tex=.08})
  for _,yy in ipairs{114,116} do L(44,yy-4,196,yy-4,CRM[3],1) end
  c:fillMask(Rc(119,54,121,113),WOOD[2])
  -- text lines
  for i=0,3 do L(52,60+i*6,98-(i%2)*10,61+i*6,CRM[3],1) end
  for i=0,2 do L(132,62+i*6,184-(i%2)*10,60+i*6,CRM[3],1) end
  sprout(80,100,1.4)
  c:fillMask(E(80,102,10,2),SOIL[3])
  mush(160,100,26,22,RED,5,{{-6,-1,2},{4,-4,2},{7,1,1}})
  -- bookmark + quirk
  local rb=Pl{{128,112},{136,112},{136,134},{132,129},{128,134}}
  obj(rb,RED,6,{R=3})
  obj(GX.disc(M(),184,66,3,2),RED,7,{R=2}); px(183,66,INK); px(185,66,INK); px(184,64,INK)
  spark(60,24,7,PNK[5]); spark(190,26,9,YEL[5])
end

function S.cook()
  local m=Rr(0,0,239,159,11)
  m:each(function(x,y)
    local t=y/159+(vn(x,y,18,2)-.5)*.1
    c:px(x,y,t<.4 and "#fbe3b4" or (t<.75 and "#f8d49c" or "#f4c188"))
  end)
  for x=6,233 do if x%5<3 then c:px(x,4,"#e8a468"); c:px(x,155,"#e8a468") end end
  for y=6,153 do if y%5<3 then c:px(4,y,"#e8a468"); c:px(235,y,"#e8a468") end end
  shadow(118,146,64,6,"#d89a64")
  -- steam
  for i=0,2 do
    local x0=96+i*22
    for y=20,56 do
      local x=x0+r(sin((y+i*9)*.3)*4)
      c:px(x-1,y,"#e8b890"); c:px(x,y,"#fff6e0"); c:px(x+1,y,"#fff6e0"); c:px(x+2,y,"#e8b890")
    end
  end
  coin(36,34,11,1); bread(208,36,15,10,2)
  -- legs + body
  obj(Rr(76,126,90,142,3),IRN,3,{R=3}); obj(Rr(146,126,160,142,3),IRN,4,{R=3})
  for _,sx in ipairs{-1,1} do obj(GX.disc(M(),118+sx*60,82,7,7),IRN,5+sx,{R=4}); c:fillMask(GX.disc(M(),118+sx*60,82,3,3),IRN[1]) end
  obj(E(118,100,52,40),IRN,6,{R=12,rim=true})
  obj(E(118,68,58,10),IRN,7,{R=4,rim=true})
  local soup=E(118,69,51,7); c:fillMask(soup,"#3a6a3a"); c:fillMask(E(118,69,51,7):cut(E(118,70,49,6)),"#3a6a3a")
  c:fillMask(E(118,69,48,5),"#7ec858"); c:fillMask(E(112,68,22,2),"#a8e070")
  for _,b in ipairs{{90,69},{140,68},{148,70}} do c:fillMask(E(b[1],b[2],2,1),"#c8f080") end
  -- eyes peeking
  for _,x in ipairs{111,124} do c:fillMask(Rc(x,63,x+3,68),INK); c:fillMask(Rc(x+1,64,x+2,65),"#fff6dc") end
  -- ladle
  L(150,64,176,32,WOOD[3],4); L(150,64,176,32,WOOD[5],2)
  obj(E(180,28,8,7),WOOD,8,{R=5})
  -- foods
  tomato(34,112,11,9); tomato(52,124,9,10)
  carrot(206,96,40,7,11)
end

function S.games()
  bg(0,159,{"#fbf0d4","#f8e8cc","#f4e0c0"},3,.1)
  hills(function(x) return 100+sin(x*.035+1)*6 end,R6("#c8ec84","#7cc05c","#4a9050","#2e5c48"),4)
  border("#e6c896")
  for _,p in ipairs{{20,130},{48,142},{200,134},{222,146},{150,148}} do tuft(p[1],p[2]) end
  -- speed lines + dust
  for i=0,3 do L(28,84+i*7,58-(i%2)*8,84+i*7,"#d8b890",1) end
  for _,p in ipairs{{62,128,4},{52,132,3},{70,134,2}} do obj(GX.disc(M(),p[1],p[2],p[3],p[3]),CRM,p[1],{R=3}) end
  -- snail
  shadow(118,128,54,5,"#4a9050")
  local body=Pl{{70,120},{86,112},{150,110},{160,112},{162,124},{70,126}}
  obj(body,PEA,2,{R=5,rim=true})
  obj(E(154,104,9,11),PEA,3,{R=5})
  for _,t in ipairs{{160,86,158,100},{170,88,164,100}} do
    L(t[3],t[4],t[1],t[2],INK,3); L(t[3],t[4],t[1],t[2],PEA[4],1)
    obj(GX.disc(M(),t[1],t[2]-1,3,3),CRM,t[1],{R=2}); px(t[1]+1,t[2]-1,INK); px(t[1]+1,t[2],INK)
  end
  px(160,106,INK); c:fillMask(Rc(163,108,168,108),PEA[2])
  local cx,cy=112,84
  obj(GX.disc(M(),cx,cy,26,25),SNL,5,{R=12,rim=true,fn=function(x,y)
    local dx,dy=x-cx,y-cy
    local t=(sqrt(dx*dx+dy*dy)/6.5-math.atan(dy,dx)/(2*pi))%1
    return t<.2 and -.38 or 0 end})
  -- flag
  L(212,122,212,146,INK,3); L(212,122,212,146,WOOD[4],1)
  local fl=Pl{{213,122},{232,127},{213,134}}; obj(fl,RED,6,{R=3})
  -- die
  local die=Rr(184,22,222,60,6); obj(die,CRM,7,{R=8,tex=.08})
  for _,p in ipairs{{192,30},{213,30},{203,41},{192,52},{213,52}} do c:fillMask(Rc(p[1],p[2],p[1]+3,p[2]+3),INK); px(p[1]+1,p[2]+1,"#7e5460") end
  mush(36,56,26,22,RED,8,{{-6,-1,2},{4,-4,2}})
  spark(14,18,8,YEL[5]); spark(168,50,5,PNK[5])
end

function S.garden()
  bg(0,159,{"#f6f0d0","#eef0c4","#e2eab8"},5,.1)
  hills(function(x) return 112+sin(x*.03)*6 end,R6("#cdea86","#86c460","#4a9450","#2e5c48"),6,{top=.8})
  border("#cfd89a")
  for _,p in ipairs{{14,134},{40,148},{214,142},{228,152}} do tuft(p[1],p[2]) end
  shadow(110,146,86,6,"#3a8a4c")
  obj(Rc(40,134,52,150),WOOD,2,{R=3}); obj(Rc(170,134,182,150),WOOD,3,{R=3})
  obj(Rr(28,36,192,140,5),WOOD,4,{R=6,rim=true})
  local ix0,iy0=36,44
  for row=0,2 do for col=0,3 do
    local x0,y0=ix0+col*39,iy0+row*31
    local cell=Rc(x0,y0,x0+36,y0+28)
    c:rim(cell,INK)
    cell:each(function(x,y)
      local v=(y-y0)/28+(vn(x,y,3,col*7+row)-.5)*.5
      c:px(x,y,SOIL[v<.35 and 4 or (v<.8 and 3 or 2)])
      if y==y0 or y==y0+1 then c:px(x,y,SOIL[2]) end
    end)
    local cx,by=x0+18,y0+26
    local k=(col+row*2)%4
    if k==0 then sprout(cx,by-4,1.3) elseif k==1 then tomato(cx,by-8,8,col*3+row); sprout(cx-12,by-2,.8)
    elseif k==2 then carrot(cx,by-22,17,5,col+row) else sprout(cx,by-4,1.6) end
  end end
  -- worm quirk
  local wm=M(); for t=0,10 do wm:set(150+t,35-r(sin(t*.7)*2),0) end
  for t=0,10 do local x,y=150+t,35-r(sin(t*.7)*2); c:px(x,y-1,INK); c:px(x,y+1,INK) end
  for t=0,10 do c:px(150+t,35-r(sin(t*.7)*2),PNK[5]) end
  px(160,33,INK)
  -- sun badge
  local b=GX.disc(M(),208,50,15,15); obj(b,YEL,8,{R=8,rim=true})
  c:fillMask(Rc(206,40,210,60),YEL[2]); c:fillMask(Rc(198,48,218,52),YEL[2])
  c:fillMask(Rc(207,41,209,59),YEL[3]); c:fillMask(Rc(199,49,217,51),YEL[3])
  spark(224,22,6,YEL[5])
end

function S.roads()
  bg(0,159,{"#1c1840","#262052","#322a64","#443474"},7,.12)
  for i=1,26 do
    local x,y=r(H(i,3,1)*236+2),r(H(i,3,2)*80+4)
    px(x,y,i%4==0 and "#ffe38a" or "#a8a0d8")
    if i%6==0 then px(x+1,y,"#ffe38a"); px(x,y+1,"#ffe38a") end
  end
  crescent(190,34,14,YEL)
  hills(function(x) return 92+sin(x*.025+2)*10 end,R6("#6a4a74","#46325e","#30224a","#1e1634"),8,{top=.7})
  hills(function(x) return 116+sin(x*.03)*5 end,R6("#8a5a58","#5e3a48","#3e2638","#241824"),9,{top=.75})
  border("#5a4888")
  -- path
  local pts={{14,152},{50,138},{90,130},{130,126},{170,120},{206,112},{238,108}}
  for i=1,#pts-1 do
    local a,b=pts[i],pts[i+1]; local n=max(abs(b[1]-a[1]),1)
    for s=0,n do
      local t=s/n; local x=a[1]+(b[1]-a[1])*t; local y=a[2]+(b[2]-a[2])*t
      local w=4-r(i*.3)
      if (r(x)%5)<3 then c:fillMask(Rc(r(x),r(y),r(x)+1,r(y)+1),"#ffd070"); px(r(x),r(y)+2,"#c8802e") end
    end
  end
  mush(132,112,44,40,PNK,3,{{-10,0,3},{8,-8,3},{12,2,2},{-2,-14,2}})
  mush(82,102,26,22,PUR,4,{{-6,-1,2},{5,-3,2}})
  mush(206,94,28,24,YEL,5,{},R6("#fff6dc","#f4dcaa","#c89a74","#7e5460"))
  gnome(48,140,.42)
  for _,p in ipairs{{150,70},{160,60},{60,100},{22,80},{176,90}} do px(p[1],p[2],"#ffe38a"); px(p[1]+1,p[2],"#c8802e") end
end

function S.stats()
  bg(0,159,{"#fbefdc","#f8e6cc","#f4dcc0"},9,.1)
  hills(function(x) return 124+sin(x*.03+1)*4 end,R6("#d8ee98","#8cc864","#52985a","#2e5c48"),10)
  border("#e2c0a0")
  tuft(24,146); tuft(222,148)
  shadow(62,146,34,5,"#3a8a4c")
  gnome(62,146,.88)
  -- panel
  local pn=Rr(116,34,216,112,6); obj(pn,R6("#8a5a6a","#5e3a4e","#3e2438","#241622"),2,{R=5,rim=true})
  local cols={PNK,R6("#a0f0f0","#48c8d8","#3a88a8","#24506a"),YEL,GRN}
  local lens={72,52,64,34}
  for i=0,3 do
    local y=42+i*17
    c:fillMask(Rr(124,y,208,y+10,3),"#241622")
    local f=Rr(125,y+1,125+lens[i+1],y+9,3); GX.lit(c,f,cols[i+1],{R=4,seed=i,ink=false,tex=.1})
    c:px(125+lens[i+1]-3,y+3,"#fff6dc")
  end
  spark(214,32,9,YEL[5])
  -- berry
  local bx,by=176,134
  obj(GX.disc(M(),bx,by,10,10),PNK,5,{R=9})
  local lf=Pl{{bx-4,by-10},{bx,by-14},{bx+5,by-10},{bx,by-8}}; obj(lf,GRN,6,{R=2})
  px(bx-4,by-3,PNK[6]); px(bx-3,by-4,PNK[6])
  c:fillMask(Rc(bx+3,by+1,bx+4,by+2),PNK[2])
end

function S.hero()
  bg(0,169,{"#f0f4d8","#e8f0cc","#dcecc4"},11,.1)
  -- sun
  local sx,sy=300,40
  for a=0,15 do local ang=a*pi/8; for t=21,25 do px(sx+cos(ang)*t,sy+sin(ang)*t,"#ffe38a") end end
  obj(GX.disc(M(),sx,sy,16,16),YEL,1,{R=10,rim=true})
  c:cloud(30,52,40,"#fff6e6","#f0d8c0"); c:cloud(92,38,30,"#fff6e6","#f0d8c0"); c:cloud(220,60,36,"#fff6e6","#f0d8c0")
  hills(function(x) return 100+sin(x*.02)*10 end,R6("#cfe8a0","#a4d078","#6eac64","#3e7a56"),2,{top=.78,fall=.3})
  hills(function(x) return 130+sin(x*.03+2)*6 end,R6("#c0e888","#88c860","#4e9852","#2e5c48"),3,{top=.8})
  shadow(180,162,50,6,"#3a8a4c")
  gnome(180,162,1.1)
  -- left
  mush(52,162,40,34,RED,4,{{-9,0,3},{6,-6,3},{11,3,2},{-2,-12,2}})
  sprout(88,158,1.6)
  for _,p in ipairs{{104,158},{116,162}} do
    tomato(p[1],p[2],8,p[1])
  end
  -- right
  carrot(248,134,26,7,5)
  mush(274,162,22,18,YEL,6,{{-4,-1,2}})
  mush(318,162,34,30,PUR,7,{{-8,0,3},{6,-6,3},{10,2,2}})
  for _,p in ipairs{{20,160},{150,166},{214,164},{340,164},{8,150},{240,168}} do tuft(p[1],p[2]) end
  spark(130,70,7,YEL[5]); spark(230,100,5,PNK[5])
end

local names={"almanac","cook","games","garden","roads","stats","hero"}
local want=app.params.name or "all"
for _,n in ipairs(names) do
  if want=="all" or want==n then
    c=HP.canvas{w=(n=="hero") and 360 or 240,h=(n=="hero") and 170 or 160,scale=1,name=n}
    S[n]()
    c:save{aseprite=d.."/out/"..n..".aseprite",png=d.."/out/"..n..".png",scale=1}
  end
end
