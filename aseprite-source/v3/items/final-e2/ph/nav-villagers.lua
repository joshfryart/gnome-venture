-- nav-villagers (lean E2_04)
local NAME = "nav-villagers"
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

local RED={"#4a1620","#7a2230","#a8332f","#d4503a","#ee7a4c","#ffa870"}
local BLU={"#1a2250","#26397a","#3a5cb0","#5486d8","#7cacee","#b0d4ff"}
local SKIN={"#6a3030","#a85a48","#d4846a","#eea488","#ffc4a4","#ffe0c8"}
local WHT={"#6c6a92","#9a98c0","#c4c4e0","#e4e4f4","#f6f4ff","#fffff0"}
local GIN={"#7a4a22","#a8682c","#d48c3c","#ecb050","#fcd078","#fff0a8"}
local GRN={"#16382e","#1f5a3e","#2e7e4a","#44a04e","#6cc064","#9ce07c"}
c:groundShadow(32,55,24,3)
-- left gnome: tall red hat
local lf = c:ellipse(19,35,8,7)
local lhat = c:poly{{19,3},{29,28},{9,28}}
local lbrim = c:rrect(7,26,31,30,1)
local lbeard = c:poly{{10,34},{28,34},{19,53}}
S(lf,SKIN,3,"lface"); S(lbeard,WHT,4,"lbeard")
local nl = c:ellipse(19,35,3,3); S(nl,SKIN,2,"lnose")
S(lhat,RED,6,"lhat"); S(lbrim,RED,2,"lbrim")
P(15,33,"#2b1c26"); P(23,33,"#2b1c26"); P(14,32,"#2b1c26");P(24,32,"#2b1c26")
for _,p in ipairs{{16,44},{21,46},{18,49},{22,41},{13,38}} do P(p[1],p[2],WHT[2]) end
-- stripe on hat
for y=14,22 do local hw=floor((y-3)*0.4) for x=19-hw,19+hw do if (y%5==0) then P(x,y,RED[2]) end end end
-- right gnome: blue floppy hat, gold bell, ginger beard
local rf = c:ellipse(45,36,8,7)
local rhat = c:poly{{47,12},{55,31},{35,31}}
local rbrim = c:rrect(33,29,57,33,1)
local rbeard = c:poly{{37,37},{54,37},{45,54}}
S(rf,SKIN,3,"rface"); S(rbeard,GIN,4,"rbeard")
local nr = c:ellipse(45,38,3,3); S(nr,SKIN,2,"rnose")
S(rhat,BLU,6,"rhat"); S(rbrim,BLU,2,"rbrim")
local droop = G.tube({{47,12},{51,10},{56,12},{57,17}}, function(t) return 1.6-0.8*t end)
S(droop,BLU,2,"droop")
local bell = c:ellipse(57,19,2,2); S(bell,GIN,2,"bell"); P(57,19,"#7a4a22")
P(41,35,"#2b1c26"); P(49,35,"#2b1c26")
for _,p in ipairs{{42,45},{47,47},{45,50},{50,42},{39,41}} do P(p[1],p[2],GIN[2]) end
-- quirk: tiny leaf tucked in the right hat band
local lf2 = c:poly{{36,30},{40,26},{40,31}}; S(lf2,GRN,1,"leaf")

G.save(c, NAME)
