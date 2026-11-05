-- fx-snack (ui P3_U4)
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
local c = HP.canvas{ w=192, h=48, scale=1, name="fx-snack" }
local R={"#8a5a2e","#b9803f","#dca862","#f0cf8c","#fbeac0"}
local function crumb(cx,cy,rx,ry,rot)
  local m=c:ellipse(cx,cy,rx,ry); sh(c,m,cx,cy,rx+1,R,0.05)
  c:px(cx-1,cy-1,R[5])
  if rx>=3 then c:px(cx+1,cy+ry-1,R[1]) end
end
-- flight: crumb arcs up, tumbling
crumb(8,36,3,2); c:px(20,40,R[2]); c:px(3,40,R[3])
crumb(48+22,20,4,3); c:px(48+12,28,R[3]); c:px(48+8,34,R[2]); c:px(48+34,30,R[4])
crumb(96+16,12,3,2); c:px(96+34,16,R[3]); c:px(96+8,24,R[2]); c:px(96+24,24,R[4])
-- frame 3: loaf with a bite
local ox=144
local loaf=c:rrect(ox+9,20,ox+39,36,6):cut(c:ellipse(ox+37,19,5,4))
sh(c,loaf,ox+18,24,22,R,-0.05)
c:rrect(ox+11,31,ox+37,36,2):each(function(x,y) c:px(x,y,R[2]) end)
for _,s in ipairs{{15,23},{22,22},{29,23}} do   -- scoring slashes
  c:line({{ox+s[1],s[2]},{ox+s[1]+3,s[2]+4}},1):each(function(x,y) c:px(x,y,R[1]) end)
end
c:px(ox+17,22,R[5]);c:px(ox+18,22,R[5])
-- quirk: the bite and a crumb trail
for _,p in ipairs{{40,26},{43,29},{6,12},{4,30}} do c:px(ox+p[1],p[2],R[3]) end
c:px(ox+42,22,R[2]); c:px(ox+39,15,R[4])
c:finish{outline=true}
HP.assertClean(c)
c:save{aseprite=OUT.."fx-snack.aseprite", png=OUT.."fx-snack.png", scale=1}
