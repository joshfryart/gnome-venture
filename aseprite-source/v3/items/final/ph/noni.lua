-- noni (lean E2_04)
local NAME = "noni"
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

local SK={"#4a5a2a","#6c8238","#92a84a","#bac864","#d8e48a","#f2f4b8"}
local LF={"#123a30","#1c5a3c","#2a7e48","#3ea052","#62c068","#98e080"}
local ST={"#4a2a22","#6e4430","#946444"}
c:groundShadow(31,56,16,3)
local body = U(c:ellipse(30,36,15,18), c:ellipse(33,32,13,17))
local idx,n = S(body,SK,13,"noni",0.06)
-- warty pits: staggered grid, dark pit with a lit bump above-left
for gy=0,9 do for gx=0,8 do
  local x = 14+gx*4 + (gy%2)*2 + floor(X.hash(gx,gy,3)*2)
  local y = 20+gy*4 + floor(X.hash(gx,gy,9)*2)
  if body:has(x,y) and body:has(x+2,y+2) and body:has(x-1,y-1) then
    P(x,y,SK[1]); P(x+1,y,SK[2]); P(x,y+1,SK[2])
    P(x-1,y-1,SK[6]); P(x,y-1,SK[5])
  end
end end
spec(body,n,"#fffff0")
-- ripe translucent patch lower right
for _,p in ipairs{{40,48},{41,48},{40,49},{41,49},{42,49},{39,50},{40,50},{41,50}} do if body:has(p[1],p[2]) then P(p[1],p[2],"#9a8a52") end end
-- stem + leaf
local stm = G.tube({{32,19},{32,14},{35,10},{39,8}}, function(t) return 1.6 end)
S(stm,ST,1,"stem")
local lm, ln, LT, LS, len = G.blade(37,9,48,2,58,9,function(t) if t>0.985 then return -1 end return max(0.5,5*sin(pi*min(1,t*0.9+0.1))^0.7) end,{fold=0.4})
G.toneN(c,lm,ln,LF,{tok={r={name="leaf"}},cuts=CUTS,amb=0.1,wrap=0.2})
lm:each(function(x,y) local k=K(x,y) if abs(LS[k])<0.14 and LT[k]>0.05 and LT[k]<0.9 then P(x,y,LS[k]<=0 and "#b8f090" or LF[2]) end end)

G.save(c, NAME)
