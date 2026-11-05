-- fx-shield (ui P3_U4)
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = app.params.out
local function sh(c,m,cx,cy,R,ramp,bias)
  m:each(function(x,y)
    local d=math.sqrt((x-cx)^2+(y-cy)^2)/R
    local lit=((cx-x)*0.6+(cy-y)*0.6)/R
    local v=1-d*0.5+lit*0.4+(bias or 0)
    c:px(x,y,ramp[1+math.floor(math.max(0,math.min(0.999,v))*#ramp)])
  end)
end
local c = HP.canvas{ w=96, h=96, scale=1, name="fx-shield" }
local R={"#2f6f94","#3f93ba","#7cc0dc","#b6e0ee","#e6f6f4"}
local cx,cy=47.5,47.5
local ring=c:ellipse(48,48,43,43):cut(c:ellipse(48,48,40,40))
ring:each(function(x,y)
  local a=math.atan(y-cy,x-cx)
  local v=(-(math.cos(a-math.pi*1.25)))*0.5+0.5   -- 1 at upper-left
  v=1-v
  c:px(x,y,R[1+math.floor(math.min(0.999,v)*5)])
end)
-- quirk: four rivet studs on the ring
for _,a in ipairs{0.78,2.35,3.9,5.5} do
  local sx,sy=math.floor(48+41.5*math.cos(a)+.5),math.floor(48+41.5*math.sin(a)+.5)
  c:ellipse(sx,sy,2,2):each(function(x,y) c:px(x,y,R[3]) end)
  c:px(sx-1,sy-1,R[5])
end
-- glint
for _,p in ipairs{{20,22},{21,22},{22,22},{20,23},{20,24},{24,22}} do c:px(p[1],p[2],R[5]) end
c:px(20,27,R[4]);c:px(26,22,R[4])
c:finish{outline=true}
HP.assertClean(c)
c:save{aseprite=OUT.."fx-shield.aseprite", png=OUT.."fx-shield.png", scale=1}
