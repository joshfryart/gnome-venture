-- petal (ui P3_U1)
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local c=HP.canvas{ w=18, h=20, scale=1, name="petal" }
local r={"#7a2448","#b03c6c","#dc5e8e","#f088aa","#fcc0d0"}
-- teardrop petal, tip up, notched tip (quirk)
local P=c:poly{{9,1},{12,4},{15,9},{16,13},{14,17},{9,19},{4,17},{2,13},{3,9},{6,4}}
P:each(function(x,y)
  local v=1-((x-2)+(y-1))/30
  c:px(x,y,r[1+math.floor(math.max(0,math.min(0.999,v))*5)])
end)
for y=4,16 do c:px(9,y,r[2]) end         -- midrib
for _,p in ipairs{{7,8},{7,12},{11,8},{11,12}} do c:px(p[1],p[2],r[2]) c:px(p[1]+(p[1]<9 and 1 or -1),p[2]+1,r[2]) end
c:px(9,1,r[1]); c:px(9,2,r[1])            -- tip notch
c:px(5,7,r[5]); c:px(5,8,r[5]); c:px(6,6,r[5])
c:px(13,15,r[1])
c:finish{outline=true}
HP.assertClean(c)
c:save{aseprite=app.params.out.."petal.aseprite", png=app.params.out.."petal.png", scale=1}
