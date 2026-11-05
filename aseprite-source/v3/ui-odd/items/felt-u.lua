-- felt-u (ui P3_U1)
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local c=HP.canvas{ w=36, h=36, scale=1, name="felt-u" }
local f={"#2c5a3a","#3a7248","#4a8a56","#5ea268"}
local function h(x,y) return (math.sin(x*12.9898+y*78.233)*43758.5453)%1 end
for y=0,35 do for x=0,35 do
  local v=h(x,y); local t=v<0.12 and 1 or (v<0.6 and 2 or (v<0.9 and 3 or 4))
  if (x+y)%7==0 and v>0.5 then t=math.max(1,t-1) end
  c:px(x,y,f[t])
end end
-- bevel: light top edge, dark bottom/right edge
for i=0,35 do c:px(i,0,"#8cc27c"); c:px(i,35,"#1c3a28"); c:px(35,i,"#1c3a28"); c:px(0,i,"#6eaa72") end
c:px(0,0,"#8cc27c"); c:px(35,0,"#6eaa72"); c:px(0,35,"#2c5a3a")
-- stitch rectangle
for i=4,31 do if i%4<2 then c:px(i,4,"#d8c47c"); c:px(i,31,"#a89458") end end
for j=4,31 do if j%4<2 then c:px(4,j,"#d8c47c"); c:px(31,j,"#a89458") end end
-- quirk: lost button thread tuft + snagged white-ish fibre
c:px(17,17,"#e8d8a0"); c:px(18,18,"#e8d8a0"); c:px(18,17,"#a89458"); c:px(19,19,"#a89458")
c:finish{outline=false}
HP.assertClean(c)
c:save{aseprite=app.params.out.."felt-u.aseprite", png=app.params.out.."felt-u.png", scale=1}
