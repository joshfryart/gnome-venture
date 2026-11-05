-- fx-ko (ui P3pilot)
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = app.params.out
local c = HP.canvas{ w=48, h=48, scale=1, name="fx-ko" }
local ramp={"#b8421e","#e0702a","#f6a834","#fbd45a","#fff0b8"}
local function burst(cx,cy,n,ro,ri,rot)
  local p={}
  for i=0,2*n-1 do
    local a=rot+i*math.pi/n; local r=(i%2==0) and ro or ri
    p[#p+1]={cx+r*math.cos(a),cy+r*math.sin(a)}
  end
  return c:poly(p)
end
local function tone(m,cx,cy,R,sh)
  m:each(function(x,y)
    local d=math.sqrt((x-cx)^2+(y-cy)^2)/R
    local lit=((cx-x)*0.6+(cy-y)*0.6)/R
    local v=1-d*0.6+lit*0.35+(sh or 0)
    local i=1+math.floor(math.max(0,math.min(0.999,v))*#ramp)
    c:px(x,y,ramp[i])
  end)
end
local big=burst(24,23,9,20,10,-0.3); tone(big,24,23,20,-0.15)
local mid=burst(24,23,9,14,7,-0.3+0.17); tone(mid,24,23,14,0.1)
c:ellipse(24,23,6,6):each(function(x,y) c:px(x,y,"#fff0b8") end)
c:ellipse(24,23,6,6):edge():each(function(x,y) c:px(x,y,"#fbd45a") end)
-- dizzy X eyes of the impact (quirk): two crossed ink-brown strokes
for _,p in ipairs{{20,20},{28,20}} do
  c:px(p[1],p[2],"#7a2a1e");c:px(p[1]+2,p[2],"#7a2a1e");c:px(p[1]+1,p[2]+1,"#7a2a1e");c:px(p[1],p[2]+2,"#7a2a1e");c:px(p[1]+2,p[2]+2,"#7a2a1e")
end
c:line({{20,28},{23,30},{26,28},{29,30}},1):each(function(x,y) c:px(x,y,"#7a2a1e") end)
-- orbit stars
for _,s in ipairs{{4,5},{43,6},{44,41},{5,42}} do
  c:px(s[1],s[2],"#fff0b8")
  for _,d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do c:px(s[1]+d[1],s[2]+d[2],"#f6a834") end
end
c:finish{outline=true}
HP.assertClean(c)
c:save{aseprite=OUT.."fx-ko.aseprite", png=OUT.."fx-ko.png", scale=1}
