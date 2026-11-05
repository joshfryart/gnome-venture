-- gem-c (ui P3pilot)
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = app.params.out
local c = HP.canvas{ w=26, h=26, scale=1, name="gem-c" }
local gold={"#6a3c1c","#9a5e22","#c88a30","#e8b44a","#f8dc84"}
local gem={"#143c4e","#1f6a78","#2c9a9a","#58c8b4","#a4ecd0"}
local function oct(cx,cy,r)
  local k=r*0.42
  return c:poly{{cx-k,cy-r},{cx+k,cy-r},{cx+r,cy-k},{cx+r,cy+k},{cx+k,cy+r},{cx-k,cy+r},{cx-r,cy+k},{cx-r,cy-k}}
end
local cx,cy=12.5,12.5
local bez=oct(cx,cy,11.4)
bez:each(function(x,y)
  local v=((cx-x)+(cy-y))/22*0.5+0.5
  c:px(x,y,gold[1+math.floor(math.max(0,math.min(0.999,v))*#gold)])
end)
-- bezel prongs (quirk: one notch/prong chip on lower right)
local inn=oct(cx,cy,8.4)
inn:each(function(x,y)
  local dx,dy=x-cx,y-cy
  local ang=math.atan(dy,dx)
  local sec=math.floor(((ang+math.pi)/(2*math.pi))*8)%8
  -- sectors: lit upper-left lighter
  local tone={[0]=3,[1]=2,[2]=3,[3]=2,[4]=1,[5]=1,[6]=2,[7]=4}
  -- atan2: sector 0 = left(-pi..-3pi/4), 1= up-left, 2=up, 3=up-right, 4=right,5=down-right,6=down,7=down-left
  local t=({[0]=4,[1]=5,[2]=4,[3]=3,[4]=2,[5]=1,[6]=2,[7]=3})[sec]
  local d=math.sqrt(dx*dx+dy*dy)
  if d<4.6 then t=math.min(5,t+1) end
  c:px(x,y,gem[t])
end)
-- dark table ring
local tab=c:ellipse(cx,cy,5,5)
tab:edge():each(function(x,y) c:px(x,y,gem[2]) end)
-- engraved C
local C={"..CCC","CC...","C....","C....","C....","CC...","..CCC"}
for j,row in ipairs(C) do for i=1,#row do if row:sub(i,i)=="C" then
  c:px(10+i-1,9+j-1,"#fff2c8") end end end
-- glints
c:px(7,6,"#fff2c8"); c:px(8,6,"#fff2c8"); c:px(7,7,"#fff2c8")
c:px(17,18,"#143c4e")
c:finish{outline=true}
HP.assertClean(c)
c:save{aseprite=OUT.."gem-c.aseprite", png=OUT.."gem-c.png", scale=1}
