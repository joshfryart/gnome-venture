-- picket-fence-cross (lean E2_04)
local NAME = "picket-fence-cross"
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

local WD={"#6c6a92","#9490b8","#c0bcd8","#e0dcf0","#f4f0fc","#fffff0"}
local RL={"#4a2a18","#6e4428","#946238","#b88450"}
local PO={"#7a4a2a","#a8703c","#cc9858","#e4b878","#f4d49c","#fff0c8"}
local CAPC={"#1a3a6a","#2a5a9c","#4284cc","#6cacee","#a8d4ff","#e0f4ff"}
c:groundShadow(32,56,26,3)
local cx,cy=32,32
-- rails first (under pickets)
local hr=c:rect(8,cy-2,56,cy+1); local vr=c:rect(cx-2,8,cx+1,56)
S(hr,RL,2,"hrail"); S(vr,RL,2,"vrail")
-- pickets: 6x6 boards with a pointed lit top row
local function pk(x0,y0,i)
  local m=c:rrect(x0,y0,x0+5,y0+5,1)
  S(m,WD,3,"pk"..i,0.12)
  P(x0+1,y0+1,WD[6]); P(x0+1,y0+2,WD[5])
  P(x0+4,y0+4,WD[1]); P(x0+3,y0+5,WD[1])
end
local n=0
for _,o in ipairs{10,17,24} do
  n=n+1; pk(cx-o-3,cy-3+0,n) -- left
  n=n+1; pk(cx+o-2,cy-3,n)   -- right
  n=n+1; pk(cx-3+0,cy-o-3,n)  -- up
  n=n+1; pk(cx-3,cy+o-2,n)    -- down
end
-- centre post with blue cap
local post=c:rrect(cx-6,cy-6,cx+5,cy+5,2)
S(post,WD,6,"post",0.15)
local cap=c:rrect(cx-4,cy-4,cx+3,cy+3,1)
S(cap,CAPC,4,"cap")
P(cx-2,cy-2,CAPC[6]); P(cx-3,cy-3,CAPC[5])
-- quirk: ladybug on an upper picket
local lb=c:ellipse(cx+1,cy-19,2,2); S(lb,{"#5a1018","#8a1a24","#c42f38","#ec4a48","#ff7a68","#ffa890"},2,"lady")
P(cx+1,cy-21,"#2b1c26"); P(cx+1,cy-19,"#2b1c26"); P(cx,cy-18,"#2b1c26")

G.save(c, NAME)
