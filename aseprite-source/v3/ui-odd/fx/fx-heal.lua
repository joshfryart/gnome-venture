-- fx-heal (ui P3_U4)
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
local c = HP.canvas{ w=192, h=48, scale=1, name="fx-heal" }
local R={"#3f7a3c","#5e9e48","#8cc85c","#c4e88a","#f4ffd0"}
local motes={{10,34,0},{22,26,1},{34,36,2},{16,14,3},{30,10,1},{38,22,0}}
local function plus(cx,cy,s)
  c:px(cx,cy,R[5])
  for k=1,s do
    local col=R[(k==s) and 2 or 3]
    c:px(cx+k,cy,col); c:px(cx-k,cy,R[(k==s) and 3 or 4]); c:px(cx,cy+k,col); c:px(cx,cy-k,R[(k==s) and 3 or 4])
  end
end
local sz={1,2,2,1}
for f=0,3 do
  local ox=f*48
  for n,m in ipairs(motes) do
    local y=m[2]-f*4-((n%2)*f)
    local s=sz[((f+m[3])%4)+1]
    if n==3 then
      -- quirk: one mote is a tiny tumbling leaf
      local x=ox+m[1]+f; 
      c:px(x,y,R[2]);c:px(x+1,y-1,R[3]);c:px(x+2,y-1,R[4]);c:px(x-1,y+1,R[1]);c:px(x+1,y,R[2])
    elseif f<3 or n%2==0 then plus(ox+m[1]+((n%2==0) and f or -f),y,s) end
  end
end
c:finish{outline=true}
HP.assertClean(c)
c:save{aseprite=OUT.."fx-heal.aseprite", png=OUT.."fx-heal.png", scale=1}
