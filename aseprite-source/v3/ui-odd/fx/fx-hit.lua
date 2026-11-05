-- fx-hit (ui P3_U4)
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
local c = HP.canvas{ w=192, h=48, scale=1, name="fx-hit" }
local R={"#b8421e","#e0702a","#f6a834","#fbd45a","#fff0b8"}
local function burst(cx,cy,n,ro,ri,rot)
  local p={}
  for i=0,2*n-1 do local a=rot+i*math.pi/n; local r=(i%2==0) and ro or ri; p[#p+1]={cx+r*math.cos(a),cy+r*math.sin(a)} end
  return c:poly(p)
end
local specs={{8,4,6,0},{19,6,9,0.1},{20,3,12,0.2},{0,0,0,0}}
for f=0,3 do
  local cx,cy=24+f*48,24
  if f<=2 then
    local sp=specs[f+1]
    local b=burst(cx,cy,8,sp[1]+ (f==0 and 6 or 0),sp[3]*0.6+2,-0.2+f*0.2)
    if f==2 then b=burst(cx,cy,8,19,4,0.1) end
    sh(c,b,cx,cy,sp[1]+8,R,f==2 and -0.2 or 0)
    c:ellipse(cx,cy,f==0 and 3 or 4,f==0 and 3 or 4):each(function(x,y) c:px(x,y,R[5]) end)
  end
  -- quirk: flung pebbles beyond the spokes
  local rr={14,19,21,22}
  for k=0,3 do
    local a=0.4+k*math.pi/2
    c:px(math.floor(cx+rr[f+1]*math.cos(a)+0.5),math.floor(cy+rr[f+1]*math.sin(a)+0.5),(f==3) and R[2] or R[4])
  end
  if f==3 then for k=0,7 do local a=k*math.pi/4; c:px(math.floor(cx+16*math.cos(a)+.5),math.floor(cy+16*math.sin(a)+.5),R[3]) end end
end
c:finish{outline=true}
HP.assertClean(c)
c:save{aseprite=OUT.."fx-hit.aseprite", png=OUT.."fx-hit.png", scale=1}
