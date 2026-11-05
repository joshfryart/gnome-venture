-- pear (lean E2_04)
local NAME = "pear"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function U(...) local m = HP.mask() for _, x in ipairs{...} do m:add(x) end return m end
local function S(m, ramp, R, name, amb)
  local n = X.pillow(m, R or 3)
  return X.tone(c, m, X.light(n, { amb = amb or 0.08, wrap = 0.25 }), ramp, { cuts = CUTS, tok = { r = { name = name or "p" } } }), n
end
local function P(x, y, col) c:put(x, y, col, { r = { name = "d" } }) end
local function spec(m, n, col) local x, y = G.specAt(m, n, 30) if x then P(x, y, col or "#fffbe8") end end

local PR={"#4a5a10","#728a1c","#9ab62c","#c0d444","#e0ec6c","#f8fca0"}
local BL={"#8a3a1c","#b85a2a","#dc7c3a","#f09c4c"}
local LF={"#123a30","#1c5a3c","#2a7e48","#3ea052","#62c068","#98e080"}
local ST={"#3a2418","#5e3c24","#8a5c38"}
c:groundShadow(30,55,16,3)
local body=U(c:ellipse(30,41,16,13), c:ellipse(30,25,8,10), c:poly{{22,28},{38,28},{46,41},{14,41}})
local bi,bn=S(body,PR,12,"pear",0.06)
-- blush on lit lower-right? warm blush upper-left cheek
body:each(function(x,y) local k=K(x,y) if x>34 and y>34 and X.hash(x,y,2)>0.55 and bi[k]>=2 then P(x,y,BL[bi[k]>3 and 3 or 2]) end end)
-- lenticel freckles
for _,p in ipairs{{22,38},{26,45},{32,48},{38,42},{27,30},{33,34},{20,46},{40,50},{30,40},{35,28},{25,52}} do if body:has(p[1],p[2]) then P(p[1],p[2],PR[2]); P(p[1]+1,p[2]-1,PR[5]) end end
spec(body,bn,"#fffff0")
P(23,35,"#fffff0"); P(24,35,"#fffff0")
-- calyx dimple at bottom
P(29,52,PR[1]);P(30,52,PR[1]);P(31,52,PR[1]);P(30,51,PR[2])
-- stem + leaf
local stm=G.tube({{31,15},{31,11},{34,8},{37,8}},function(t) return 1.7 end)
S(stm,ST,1,"stem")
local lm,ln,LT,LS=G.blade(34,11,43,6,53,11,function(t) if t>0.985 then return -1 end return max(0.5,4.6*sin(pi*min(1,t*0.9+0.1))^0.7) end,{fold=0.4})
G.toneN(c,lm,ln,LF,{tok={r={name="leaf"}},cuts=CUTS,amb=0.1,wrap=0.2})
lm:each(function(x,y) local k=K(x,y) if abs(LS[k])<0.14 and LT[k]>0.05 and LT[k]<0.9 then P(x,y,LS[k]<=0 and "#b8f090" or LF[2]) end end)
-- quirk: worm peeking from a hole on the right
for _,p in ipairs{{40,36},{41,36},{40,37},{41,37}} do P(p[1],p[2],"#2a1a10") end
P(41,35,"#f4a0a8");P(42,34,"#f4a0a8");P(42,35,"#e07888");P(43,33,"#f4a0a8");P(43,32,"#f4a0a8");P(44,31,"#fcc4c8");P(43,31,"#e07888")
P(44,32,"#2b1c26")

G.save(c, NAME)
