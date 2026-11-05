-- journal emblems 96x96 medallions. Param: name=<code> or all
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local V3 = d.."/../.."
local HP = dofile(V3.."/lib/hp.lua")
local GX = dofile(V3.."/gather/gx.lua")
local INK = "#2b1c26"
local sin, cos, rad = math.sin, math.cos, math.rad
local mix = GX.mix

local function build(name, fn)
  local c = HP.canvas{ w=96, h=96, scale=1, name=name }
  local disc = c:ellipse(48,48,44,44)
  local function clip(m) return m:clip(disc) end
  local function R(x0,y0,x1,y1,col) clip(c:rect(x0,y0,x1,y1)):each(function(x,y) c:put(x,y,col) end) end
  local function flat(m,col) clip(m):each(function(x,y) c:put(x,y,col) end) end
  -- shaded object with ink rim
  local function O(m, base, norim)
    m = clip(m)
    if not norim then c:rim(m, INK, disc) end
    local hi, sh = mix(base,"#fff2c8",.38), mix(base,"#3a2040",.38)
    c:fillMask(m, base)
    c:fillMask(m:copy():cut(m:shift(1,1)), hi)
    c:fillMask(m:copy():cut(m:shift(-1,-1)), sh)
    return m
  end
  local function E(cx,cy,rx,ry,col,nr) return O(c:ellipse(cx,cy,rx,ry), col, nr) end
  local function P(pts,col,nr) return O(c:poly(pts), col, nr) end
  local function Rc(x0,y0,x1,y1,col,nr) return O(c:rect(x0,y0,x1,y1), col, nr) end
  local function L(pts,w,col) return O(c:line(pts,w), col) end
  local function px(x,y,col) if disc:has(x,y) then c:put(x,y,col) end end
  local function leaf(x,y,ang,len,w,col)
    local a = rad(ang); local dx,dy = cos(a),sin(a)
    local mx,my = x+dx*len*.55, y+dy*len*.55 - 2
    return P({{x,y},{mx-dy*w,my+dx*w},{x+dx*len,y+dy*len+len*.3},{mx+dy*w*.4,my-dx*w*.4}}, col)
  end
  local function bg(sky,sky2,hz,gr,gr2,gy)
    R(0,0,95,hz,sky); R(0,hz*.55,95,hz,sky2)
    flat(c:rect(0,hz,95,95), gr); if gr2 then R(0,gy,95,95,gr2) end
  end
  local function ring(a,b)
    local outer, inner = c:ellipse(48,48,46,46), c:ellipse(48,48,43,43)
    local mid = c:ellipse(48,48,45,45)
    local rg = outer:copy():cut(inner)
    c:fillMask(rg, a)
    c:fillMask(rg:copy():cut(rg:shift(1,1)), mix(a,"#fff2c8",.4))
    c:fillMask(rg:copy():cut(rg:shift(-1,-1)), mix(a,"#3a2040",.4))
    c:rim(outer, INK)
    c:fillMask(inner:edge(), INK)
    local dots = 12
    for i=0,dots-1 do local t=i/dots*6.2832; px(math.floor(48+44.5*cos(t)), math.floor(48+44.5*sin(t)), b) end
  end
  fn{ c=c,R=R,flat=flat,O=O,E=E,P=P,Rc=Rc,L=L,px=px,leaf=leaf,bg=bg,disc=disc }
  return c, ring
end

local PIC = {}

PIC.ca = function(g) -- Maya pyramid + toucan
  g.bg("#8fd6b0","#c4eaa0",62,"#2f7a46","#245e3a",74)
  g.E(16,40,10,6,"#68b858",true); g.E(80,36,9,5,"#68b858",true)
  local t = {{50,12},{42,20},{34,28},{26,36}}
  for i,w in ipairs(t) do local y1 = 66-(i-1)*7; g.Rc(46-w[1]//1+25-25+ (50-w[1]) //1 - 0, y1-7, 46+w[1]//1-0, y1, "#c9b98a") end
  g.Rc(39,28,53,36,"#b8a878"); g.Rc(43,31,49,36,"#3a2840",true); g.Rc(41,24,51,28,"#d8c898")
  g.P({{42,66},{50,66},{48,36},{44,36}},"#ecdcaa")
  for y=40,64,4 do g.R(43,y,49,y,"#b8a070") end
  g.L({{56,76},{92,70}},3,"#8a5a30")
  g.P({{64,64},{72,64},{69,78}},"#3a2a48")
  g.E(70,61,6,8,"#3a2a48"); g.E(68,60,3,5,"#fff0c8",true)
  g.E(71,51,5,5,"#3a2a48")
  g.P({{74,48},{90,52},{74,57}},"#f08a2c"); g.P({{74,48},{88,51},{74,52}},"#f8d048",true)
  g.px(72,50,"#fff0c8")
end

PIC.cb = function(g) -- palm + sea turtle
  g.bg("#ffd08a","#ffb070",56,"#2fb8c8","#1f8aa8",72)
  g.E(68,36,9,9,"#ff7a48",true)
  g.E(38,64,28,6,"#f0d890")
  g.L({{34,66},{39,54},{37,42},{42,34}},4,"#8a5a30")
  for _,a in ipairs{-170,-135,-95,-55,-15,20} do g.leaf(42,34,a,20,3,"#2a9a4a") end
  g.E(40,37,2,2,"#7a4a2a"); g.E(44,37,2,2,"#7a4a2a")
  g.E(66,78,12,6,"#b0743a"); g.E(66,76,7,3,"#d89a50",true)
  g.E(80,76,4,3,"#5a9a4a"); g.px(81,75,"#2b1c26")
  g.P({{56,80},{50,86},{58,84}},"#5a9a4a"); g.P({{74,80},{80,88},{70,84}},"#5a9a4a")
end

PIC.csa = function(g) -- Andes peak, terraces, llama
  g.bg("#c8b8e8","#f0c8d8",60,"#5aa04a","#438a3c",76)
  g.P({{4,64},{40,18},{76,64}},"#8a7aa8"); g.P({{40,18},{32,32},{37,29},{41,34},{46,30},{49,27}},"#f4ecf0",true)
  g.P({{52,64},{72,32},{94,64}},"#a090b8"); g.P({{72,32},{67,40},{72,38},{76,41}},"#f4ecf0",true)
  for i=0,3 do g.Rc(6+i*4,60+i*5,56-i*2,64+i*5,"#5aa04a"); g.R(6+i*4,64+i*5,56-i*2,65+i*5,"#b8a888") end
  g.Rc(60,70,62,82,"#c8a878",true)
  g.E(70,70,10,6,"#f0dcb0"); g.P({{76,68},{80,50},{84,50},{82,68}},"#f0dcb0")
  g.E(82,49,4,3,"#f0dcb0"); g.P({{80,47},{80,42},{82,46}},"#e0c090"); g.P({{85,47},{86,42},{84,46}},"#e0c090")
  g.R(60,74,62,82,"#c8a878"); g.R(66,74,68,83,"#c8a878"); g.R(74,74,76,83,"#c8a878"); g.R(79,74,81,82,"#c8a878")
  g.px(83,49,"#2b1c26"); g.E(60,67,3,3,"#e0c090")
end

PIC.ea = function(g) -- pagoda + panda
  g.bg("#ffd6d0","#ffe8d0",62,"#6aa05a","#548a4a",78)
  g.E(62,30,10,10,"#e84a3a",true)
  g.P({{0,62},{20,48},{40,62}},"#e8a0a0",true)
  local x=34
  g.Rc(14,60,56,66,"#b8a8a0")
  for i=0,2 do
    local y=56-i*13; local hw=14-i*3
    g.Rc(x-hw+3,y-8,x+hw-3,y,"#f0e0b8"); g.Rc(x-2,y-6,x+2,y,"#7a2a2a",true)
    g.P({{x-hw-4,y-8},{x-hw+2,y-14},{x+hw-2,y-14},{x+hw+4,y-8}},"#b8322a"); g.R(x-hw-4,y-9,x+hw+4,y-8,"#f0b830")
  end
  g.Rc(x-1,14,x+1,22,"#f0b830"); 
  g.L({{86,56},{86,86}},2,"#4a8a3a"); g.L({{91,60},{91,86}},2,"#5a9a4a")
  g.E(70,74,9,9,"#f4ecdc"); g.E(70,74,9,3,"#3a2a48",true)
  g.E(62,82,3,4,"#3a2a48"); g.E(78,82,3,4,"#3a2a48")
  g.E(70,60,6,5,"#f4ecdc"); g.E(64,55,2,2,"#3a2a48"); g.E(76,55,2,2,"#3a2a48")
  g.E(67,60,2,2,"#3a2a48",true); g.E(73,60,2,2,"#3a2a48",true); g.px(70,62,"#3a2a48")
end

PIC.ee = function(g) -- onion domes + bear
  g.bg("#a8c8e8","#d8e6f0",64,"#e8f0f4","#d0dcea",80)
  local function dome(cx,by,w,h,col)
    g.Rc(cx-w//2+1,by,cx+w//2-1,by+3,"#f4d8c0")
    g.P({{cx-1,by-h},{cx+1,by-h},{cx+w*.35,by-h*.6},{cx+w/2,by-h*.3},{cx+w*.3,by},{cx-w*.3,by},{cx-w/2,by-h*.3},{cx-w*.35,by-h*.6}},col)
    g.R(cx,by-h-4,cx,by-h-1,"#f0b830"); g.R(cx-1,by-h-3,cx+1,by-h-3,"#f0b830")
  end
  g.Rc(14,50,28,68,"#f4d8c0"); g.Rc(48,50,62,68,"#f4d8c0"); g.Rc(30,36,46,68,"#f4d8c0")
  dome(21,50,12,12,"#d03a3a"); dome(55,50,12,12,"#f0b830"); dome(38,36,16,18,"#2a9a9a")
  g.Rc(35,56,41,68,"#5a2a40",true); g.R(36,48,40,50,"#5a2a40"); g.Rc(17,56,19,60,"#5a2a40",true); g.Rc(51,56,53,60,"#5a2a40",true)
  for i=0,9 do g.px(10+i*8+(i%3),70+(i*5)%9,"#fff8ee") end
  g.E(76,74,12,8,"#8a5a3a"); g.E(70,70,5,7,"#8a5a3a",true)
  g.E(84,64,5,5,"#8a5a3a"); g.E(83,60,2,2,"#8a5a3a"); g.E(87,60,2,2,"#8a5a3a")
  g.E(86,66,3,2,"#d8a878",true); g.px(86,65,"#2b1c26"); g.px(83,63,"#2b1c26")
  g.R(66,80,70,84,"#6a4228"); g.R(80,80,84,84,"#6a4228")
end

PIC.esa = function(g) -- acacia + elephant
  g.bg("#ffb050","#ffd080",64,"#d89a48","#b87838",78)
  g.E(24,50,13,13,"#ff7a3a",true)
  g.L({{28,68},{32,50}},4,"#4a3028")
  g.E(32,44,22,5,"#6a8a3a"); g.E(28,39,13,4,"#82a444")
  g.E(62,62,15,10,"#9a8a9a")
  g.R(50,66,54,80,"#8a7a8a"); g.R(58,68,62,82,"#8a7a8a"); g.R(66,68,70,82,"#8a7a8a"); g.R(74,66,78,80,"#8a7a8a")
  g.E(78,55,7,8,"#9a8a9a"); g.E(73,57,5,8,"#b49aa4")
  g.P({{80,58},{86,60},{88,74},{85,78},{83,72},{83,62}},"#9a8a9a")
  g.P({{80,63},{86,64},{83,67}},"#f4ecd0",true); g.px(80,53,"#2b1c26")
end

PIC.mena = function(g) -- pyramids + camel + crescent
  g.bg("#4a3a78","#e07a78",60,"#d8a858","#c08840",78)
  g.R(0,48,95,60,"#f0b070")
  g.E(70,24,6,6,"#fbe8b0",true); g.E(73,22,5,5,"#4a3a78",true)
  for _,p in ipairs{{20,14},{50,12},{30,30},{84,40}} do g.px(p[1],p[2],"#fbe8b0") end
  g.P({{6,68},{36,32},{66,68}},"#e8c070"); g.P({{36,32},{66,68},{40,68}},"#c89850",true)
  g.P({{50,66},{68,46},{88,66}},"#dcb060"); g.P({{68,46},{88,66},{72,66}},"#b88840",true)
  g.E(62,68,11,5,"#d8a460"); g.E(58,60,4,4,"#d8a460")
  g.P({{68,64},{74,52},{78,52},{74,66}},"#d8a460"); g.E(79,52,4,3,"#d8a460"); g.px(80,51,"#2b1c26")
  g.R(52,70,54,82,"#b8844a"); g.R(57,70,59,83,"#b8844a"); g.R(66,70,68,83,"#b8844a"); g.R(71,70,73,82,"#b8844a")
  g.P({{52,64},{48,72},{51,72}},"#b8844a")
end

PIC.na = function(g) -- mountains, pines, moose
  g.bg("#78b8e8","#b8dcf0",62,"#3a6a3a","#2a5a30",78)
  g.P({{0,62},{26,22},{56,62}},"#7a8aa8"); g.P({{26,22},{19,34},{25,31},{29,36},{34,31}},"#f4f4f4",true)
  g.P({{40,62},{64,34},{94,62}},"#8a9ab8"); g.P({{64,34},{58,42},{64,40},{68,43}},"#f0f4f8",true)
  for _,p in ipairs{{12,70,18},{24,68,14},{6,66,12}} do
    local x,y,h = p[1],p[2],p[3]
    g.P({{x,y-h},{x-7,y-h*.3},{x-3,y-h*.3},{x-9,y+2},{x+9,y+2},{x+3,y-h*.3},{x+7,y-h*.3}},"#1f5a3a")
    g.R(x-1,y+2,x+1,y+5,"#5a3a28")
  end
  g.E(66,70,12,6,"#7a4a2c"); g.E(58,64,6,5,"#7a4a2c",true)
  g.R(56,74,58,88,"#5a3420"); g.R(61,75,63,88,"#5a3420"); g.R(70,75,72,88,"#5a3420"); g.R(75,74,77,86,"#5a3420")
  g.P({{72,66},{78,54},{84,54},{82,66}},"#7a4a2c"); g.E(82,56,5,3,"#7a4a2c")
  g.P({{84,56},{90,58},{90,62},{84,60}},"#6a3e24",true)
  g.P({{78,52},{74,44},{70,40},{74,48},{80,50}},"#d8b878"); g.P({{82,52},{86,44},{90,40},{88,48},{84,50}},"#d8b878")
  g.px(83,55,"#2b1c26")
end



PIC.sa = function(g) -- Taj + peacock
  g.bg("#58c0c8","#f0d8c0",62,"#7ac070","#5aa860",78)
  g.R(0,64,95,72,"#58a8d8")
  g.Rc(8,60,52,66,"#f0e8e0"); g.Rc(24,44,50,60,"#f0e8e0")
  g.E(37,40,10,11,"#f8f0ec"); g.R(37,24,37,30,"#f0b830"); g.E(37,29,1,1,"#f0b830")
  g.Rc(31,50,43,60,"#c8c0d0",true); g.Rc(34,52,40,60,"#3a2840",true)
  for _,x in ipairs{13,57} do g.Rc(x,34,x+3,60,"#f0e8e0"); g.E(x+1,32,3,3,"#f8f0ec"); g.R(x+1,26,x+1,29,"#f0b830") end
  g.E(74,58,14,14,"#2a9a6a")
  for i=0,6 do local a=rad(190+i*25); g.px(math.floor(74+10*cos(a)),math.floor(58+10*sin(a)),"#f0d048"); g.px(math.floor(74+10*cos(a)),math.floor(59+10*sin(a)),"#2a5ad8") end
  g.E(74,74,5,7,"#2a6ad8"); g.P({{72,70},{76,70},{75,56},{73,56}},"#2a6ad8")
  g.E(74,54,3,3,"#2a6ad8"); g.P({{74,50},{73,46},{75,47}},"#2a6ad8",true); g.P({{76,53},{80,54},{76,55}},"#f0b830",true)
  g.R(72,80,73,86,"#8a6a40"); g.R(76,80,77,86,"#8a6a40")
end

PIC.se = function(g) -- Greek temple + owl + cypress
  g.bg("#58a8e0","#a8d8f0",58,"#c8a068","#b08850",78)
  g.R(0,58,95,64,"#2a7ac0")
  g.E(68,50,4,14,"#2a6a3a")
  g.Rc(6,64,60,68,"#f0e4cc"); g.Rc(8,60,58,64,"#f0e4cc")
  g.Rc(8,34,58,40,"#f0e4cc"); g.P({{6,34},{33,20},{60,34}},"#f0e4cc"); g.P({{14,33},{33,24},{52,33}},"#d8704a",true)
  for i=0,5 do g.Rc(10+i*9,40,13+i*9,60,"#f0e4cc") end
  g.E(78,68,6,8,"#9a6a40"); g.E(78,70,3,5,"#e8d0a0",true)
  g.E(78,58,6,5,"#9a6a40"); g.P({{73,55},{72,50},{76,54}},"#9a6a40"); g.P({{83,55},{84,50},{80,54}},"#9a6a40")
  g.E(75,58,2,2,"#f8e080",true); g.E(81,58,2,2,"#f8e080",true); g.px(75,58,"#2b1c26"); g.px(81,58,"#2b1c26"); g.px(78,60,"#e08a30")
end


PIC.wca = function(g) -- baobab + grey parrot
  g.bg("#f8d860","#f8a850",64,"#c8682a","#a85022",80)
  g.E(24,36,8,8,"#fbeab0",true)
  g.P({{26,68},{30,50},{32,42},{44,42},{46,50},{50,68}},"#9a7060")
  for _,b in ipairs{{34,42,24,30},{38,42,38,26},{42,42,52,32},{36,43,16,38}} do g.L({{b[1],b[2]},{b[3],b[4]}},3,"#9a7060") end
  for _,p in ipairs{{24,30,7},{38,25,7},{52,32,7},{16,38,5},{31,34,5}} do g.E(p[1],p[2],p[3],4,"#5a8a2a") end
  g.L({{58,74},{94,70}},3,"#7a4a2a")
  g.P({{70,66},{76,66},{74,84},{72,84}},"#e03a2a")
  g.E(73,60,6,9,"#9a9aa8"); g.E(75,62,3,5,"#7a7a8a",true)
  g.E(72,49,5,5,"#9a9aa8"); g.E(71,49,3,3,"#f4ecdc",true); g.px(71,49,"#2b1c26")
  g.P({{75,47},{81,49},{78,54},{76,52}},"#3a2a38")
end






PIC.sea = function(g) -- Angkor towers + water buffalo + lotus
  g.bg("#ffc890","#f8e0a0",54,"#48a8a0","#308888",72)
  g.P({{0,56},{14,48},{34,56}},"#58a888",true); g.P({{60,56},{82,46},{96,56}},"#58a888",true)
  local function tower(x,by,s)
    for i=0,3 do local w=(6-i*1.5)*s; g.Rc(x-w//1,by-(i+1)*4*s//1,x+w//1,by-i*4*s//1,"#b8a078") end
    g.P({{x,by-20*s//1},{x-2*s//1,by-15*s//1},{x+2*s//1,by-15*s//1}},"#c8b088")
  end
  g.Rc(44,52,84,58,"#a89068"); tower(52,52,1); tower(76,52,1); tower(64,52,1.4)
  g.Rc(61,49,67,52,"#3a2840",true)
  g.R(0,74,95,95,"#308888"); g.R(0,74,95,74,"#58b8b0")
  local BU, BD = "#5c6482", "#3e4560"
  for _,lx in ipairs{46,52,68,74} do g.Rc(lx,74,lx+3,84,BD) end
  g.L({{84,64},{88,70},{86,78}},2,BD); g.E(86,79,2,3,"#2b1c26",true)
  g.E(62,67,18,10,BU)
  g.E(45,62,10,9,BU)
  g.P({{36,62},{46,55},{50,71},{36,75}},BU)
  g.E(30,70,8,7,BU)
  g.E(24,75,5,4,"#9aa0b8")
  g.px(22,75,"#2b1c26"); g.px(25,75,"#2b1c26")
  g.E(37,66,3,2,BD)
  g.px(30,67,"#fff0c8"); g.px(30,68,"#2b1c26")
  -- swept-back crescent horns
  g.P({{35,63},{27,63},{22,58},{21,52},{25,57},{31,60},{36,60}},"#efe2c0")
  g.P({{38,62},{41,56},{40,50},{37,55}},"#d8c8a0")
  g.R(0,78,95,95,"#2a8a86"); g.R(40,78,86,78,"#8ad8d0"); g.R(36,82,64,82,"#58b8b0"); g.R(54,86,80,86,"#58b8b0")
  for _,p in ipairs{{12,84},{22,88},{80,90}} do g.E(p[1],p[2],5,2,"#2a7a5a",true); g.E(p[1],p[2]-2,2,2,"#f06a98") end
end

PIC.nwe = function(g) -- castle (inside the medallion) + fluffy sheep
  g.bg("#9ab0c8","#c0d0dc",56,"#5a9a5a","#488a4a",74)
  g.E(24,24,7,3,"#d8e2e8",true); g.E(31,26,7,3,"#d8e2e8",true); g.E(68,22,7,3,"#d8e2e8",true)
  g.E(48,58,28,7,"#5a9a5a",true)
  g.Rc(32,34,52,56,"#a8a0a8")
  for x=32,50,6 do g.Rc(x,30,x+3,34,"#a8a0a8") end
  g.Rc(24,38,32,56,"#b8b0b8"); g.Rc(52,38,60,56,"#b8b0b8")
  g.P({{22,38},{28,26},{34,38}},"#5a6a98"); g.P({{50,38},{56,26},{62,38}},"#5a6a98")
  g.R(28,21,28,26,"#2b1c26"); g.R(29,21,32,23,"#d03a3a"); g.R(56,21,56,26,"#2b1c26"); g.R(57,21,60,23,"#d03a3a")
  g.Rc(38,45,46,56,"#3a2840",true); g.R(39,43,45,45,"#3a2840")
  g.Rc(27,44,29,48,"#3a2840",true); g.Rc(55,44,57,48,"#3a2840",true)
  -- fluffy sheep: dark legs, many lit wool puffs, dark face with ears
  for _,lx in ipairs{42,48,60,66} do g.Rc(lx,78,lx+3,87,"#3a2c3a"); g.R(lx,87,lx+3,87,"#2b1c26") end
  local wool={{50,70,10},{60,68,11},{68,72,8},{56,76,9},{64,77,8},{46,76,7},{72,77,6},{54,64,7},{62,63,6}}
  for _,p in ipairs(wool) do g.E(p[1],p[2],p[3],p[3]-1,"#f4ecdc") end
  for _,p in ipairs{{56,60,3},{66,66,2},{48,68,2},{60,72,2},{70,74,2}} do g.E(p[1],p[2],p[3],p[3]-1,"#fffaf0",true) end
  for _,p in ipairs{{58,80},{66,82},{50,82},{44,78}} do g.R(p[1],p[2],p[1]+3,p[2],"#d0c4b4") end
  g.E(36,72,8,9,"#4a3a48")
  g.E(36,64,7,4,"#f4ecdc")
  g.P({{29,70},{23,72},{23,76},{29,76}},"#4a3a48"); g.P({{43,70},{49,72},{49,76},{43,76}},"#4a3a48")
  g.E(33,71,2,2,"#fff0c8",true); g.E(39,71,2,2,"#fff0c8",true); g.px(33,72,"#2b1c26"); g.px(39,72,"#2b1c26")
  g.E(36,78,3,2,"#c8a0a0",true); g.px(35,78,"#2b1c26"); g.px(37,78,"#2b1c26")
end

PIC.oc = function(g) -- tall Uluru + a kangaroo
  g.bg("#8ac8e8","#ffd8a0",58,"#e89a5a","#c87a40",80)
  g.R(0,50,95,58,"#f4c080")
  local m=g.P({{0,72},{4,54},{10,42},{20,32},{34,25},{48,26},{58,34},{64,46},{68,60},{72,72}},"#d8582a")
  local function paint(f,col) m:each(function(x,y) if f(x,y) then g.px(x,y,col) end end) end
  paint(function(x,y) return x<26 and (x-4)<(70-y)*.5 end,"#ee7a40")
  paint(function(x,y) return x>46+(y-26)*.1 and y>34 end,"#a83a22")
  paint(function(x,y) return x>58 end,"#7a2a22")
  for _,by in ipairs{36,45,54,63} do paint(function(x,y) return y==by+math.floor(2*math.sin(x/8)) end,"#a83a22") end
  for _,by in ipairs{40,49,58} do paint(function(x,y) return y==by+math.floor(2*math.sin(x/8+1)) and x<44 end,"#f08a50") end
  for _,vx in ipairs{16,28,40,52} do paint(function(x,y) return x==vx+(y%3)//2 and y>40 and y<66 end,"#8a2e22") end
  g.R(0,68,95,95,"#e89a5a"); g.R(0,80,95,95,"#c87a40")
  g.E(36,69,34,3,"#e89a5a",true)
  for _,p in ipairs{{10,76},{20,84},{14,88}} do g.E(p[1],p[2],4,2,"#7a9a48",true) end
  local K,KD,KL="#c88a50","#a86a3a","#f0cc90"
  g.P({{60,68},{70,74},{76,80},{70,82},{58,76}},KD)
  g.P({{48,48},{54,45},{61,54},{64,66},{60,76},{50,76},{46,66},{45,54}},K)
  g.E(57,71,7,7,K)
  g.P({{56,76},{62,76},{64,82},{44,82},{44,79},{54,79}},KD)
  g.E(48,61,3,7,KL,true)
  g.L({{48,57},{43,61}},2,KD)
  g.E(45,42,4,4,K); g.P({{44,40},{36,44},{44,47}},K)
  g.P({{44,39},{42,31},{47,38}},K); g.P({{47,39},{50,32},{50,40}},KD)
  g.px(36,44,"#2b1c26"); g.px(44,41,"#2b1c26")
end

local ORDER = {"nwe","oc","sea"}
local RING = {ca={"#d8a838","#fff0c8"},cb={"#e86a58","#fff0c8"},csa={"#8a5ab8","#f8e0f0"},ea={"#c8322a","#ffd860"},ee={"#3a6ab8","#f4f0e8"},
 esa={"#c86a1a","#ffe0a0"},mena={"#6a4aa8","#f8d870"},na={"#2a6a4a","#d8f0d0"},nwe={"#5a7a98","#e8f0f4"},oc={"#d8582a","#ffe8b0"},
 sa={"#d8508a","#fff0d0"},se={"#2a78b8","#f8f0dc"},sea={"#2a9a8a","#ffe0a0"},wca={"#a8481a","#ffd860"}}
local want = app.params.name or "all"
for _,n in ipairs(ORDER) do if want=="all" or want==n then
  local c, ring = build(n, PIC[n]); ring(RING[n][1], RING[n][2])
  c:save{aseprite=d.."/out/journal-"..n..".aseprite", png=d.."/out/journal-"..n..".png", scale=1}
end end
