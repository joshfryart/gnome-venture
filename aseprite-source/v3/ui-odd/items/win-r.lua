-- win-r (ui P3_U3)
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = app.params.out
local c = HP.canvas{ w=28, h=28, scale=1, name="win-r" }
local INK="#2b1c26"
local wood={"#4a2c1c","#6e4228","#a06638","#c48a4c","#e8c488"}   -- dark->light
local pane={"#a0c4cc","#c4e0e4","#e2f2f2","#eef8f8","#f8ffff"}   -- dark->light
local function h(x,y) local v=math.sin(x*12.9898+y*78.233)*43758.5453 return v-math.floor(v) end
local OFF=false
for y=0,27 do for x=0,27 do
  local col
  if x==0 or y==0 or x==27 or y==27 then
    col=INK
  else
    -- bevel: light upper-left, shade lower-right
    local t=3
    if y<=2 or x<=2 then t=4 end
    if y>=25 or x>=25 then t=2 end
    if x>=26 or y>=26 then t=1 end
    if (x<=2 and y>=25) or (y<=2 and x>=25) then t=3 end
    -- grain: horizontal on top/bottom bars, vertical on sides
    if (y<=5 or y>=22) and (x+ (y*3))%7==0 and h(x,y)>0.4 then t=math.max(1,t-1) end
    if (x<=5 or x>=22) and y>5 and y<22 and (y+x*3)%6==0 and h(x,y)>0.4 then t=math.max(1,t-1) end
    col=wood[t]
  end
  c:px(x,y,col)
end end
-- recess (inner opening 6..21) with inset shadow
for y=6,21 do for x=6,21 do
  local col=wood[1]
  if y>=7 and x>=7 then col=wood[2] end
  if y==21 or x==21 then col=wood[3] end
  if y==21 and x>=7 then col=wood[4] end
  c:px(x,y,col)
end end
-- pane 8..19 sash line, glass 9..18
for y=8,19 do for x=8,19 do c:px(x,y,pane[2]) end end
for y=9,18 do for x=9,18 do
  local t=3
  if x+y<=21 then t=4 end
  if x+y>=27 then t=2 end
  c:px(x,y,pane[t])
end end
-- glint (diagonal streak) and dot
c:px(10,10,pane[5]) c:px(11,10,pane[5]) c:px(10,11,pane[5]) c:px(12,9,pane[5]) c:px(9,12,pane[5])
c:px(16,16,pane[5])
-- nails at corners
for _,p in ipairs{{3,3},{24,3},{3,24},{24,24}} do c:px(p[1],p[2],wood[5]) c:px(p[1]+1,p[2]+1,wood[1]) end
-- quirk: wood knot on bottom bar
c:px(13,23,wood[1]) c:px(14,23,wood[1]) c:px(12,24,wood[1]) c:px(15,24,wood[2]) c:px(13,24,wood[3]) c:px(14,24,wood[2])

c:save{ aseprite=OUT.."win-r.aseprite", png=OUT.."win-r.png", scale=1 }
