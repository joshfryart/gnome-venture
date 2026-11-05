-- opening-day-bunting (lean E2_04)
local NAME = "opening-day-bunting"
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

local COLS={
 {"#5a1424","#8a1f34","#c42f40","#ec5450","#ff8468","#ffb898"},
 {"#6a4210","#a8701a","#e0a026","#fcc83c","#ffe070","#fff4b0"},
 {"#12366a","#1c58a0","#2e82d0","#4cacf0","#80ccff","#c0eaff"},
 {"#4a1458","#782088","#a838b4","#d058d0","#ec8cec","#ffc0f6"},
 {"#12462a","#1c6c3c","#2c9a4c","#4cc468","#80e48c","#c0f8c0"},
}
local ROPE={"#3a2a1c","#6a4a2c","#a07844","#c8a064"}
local function yat(x) return 9+13*(1-((x-32)/24)^2) end
-- rope
local pts={}
for x=9,55,1 do pts[#pts+1]={x,yat(x)} end
local rope=c:line(pts,1)
S(rope,ROPE,1,"rope")
rope:each(function(x,y) if (x%3)==0 then P(x,y,ROPE[1]) end end)
-- end knots
for _,x in ipairs{9,55} do local k=c:ellipse(x,floor(yat(x)),2,2); S(k,ROPE,2,"knot") end
-- pennants
local xs={15,23,32,41,49}
local hs={19,24,26,24,19}
for i,x in ipairs(xs) do
  local y=floor(yat(x))+1
  local h=hs[i]
  local m=c:poly{{x-5,y},{x+5,y},{x,y+h}}
  S(m,COLS[i],4,"flag"..i)
  -- stripe band near top
  for yy=y+3,y+4 do for xx=x-5,x+5 do if m:has(xx,yy) then P(xx,yy,COLS[i][6]) end end end
  -- dark fold along right edge
  -- tie
  P(x-1,y-1,ROPE[1]); P(x,y-1,ROPE[1]); P(x+1,y-1,ROPE[1])
end
-- quirk: heart on the middle flag
local hx,hy=32,floor(yat(32))+10
for _,p in ipairs{{-2,0},{-1,0},{1,0},{2,0},{-2,1},{-1,1},{0,1},{1,1},{2,1},{-1,2},{0,2},{1,2},{0,3}} do P(hx+p[1],hy+p[2],"#fff4f0") end
-- quirk: one flag tip flipped? small ladybug... keep heart

G.save(c, NAME)
