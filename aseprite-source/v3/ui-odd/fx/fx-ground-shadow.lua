-- fx-ground-shadow (ui P3_U4)
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
local c = HP.canvas{ w=64, h=16, scale=1, name="fx-ground-shadow" }
local o=c:ellipse(32,8,29,6); local i=c:ellipse(32,8,22,4)
o:each(function(x,y) c:px(x,y,(x+y)%2==0 and "#6a4528" or "#5a3a22") end)
o:each(function(x,y) c:px(x,y,"#5a3a22") end)
i:each(function(x,y) c:px(x,y,"#3c2518") end)
c:ellipse(32,9,14,2):each(function(x,y) c:px(x,y,"#2e1c18") end)
-- quirk: two grass blades poking from the edge
for _,p in ipairs{{50,4},{52,3},{51,5}} do c:px(p[1],p[2],"#6a9a48") end
c:px(52,2,"#8cc85c"); c:px(50,3,"#8cc85c")
c:finish{outline=true}
HP.assertClean(c)
c:save{aseprite=OUT.."fx-ground-shadow.aseprite", png=OUT.."fx-ground-shadow.png", scale=1}
