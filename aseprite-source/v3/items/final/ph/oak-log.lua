-- oak-log (lean W2_11)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w=64, h=64, scale=1, name="oak-log" }
local BARK = {"#2e2018","#4a3426","#684a34","#86644a","#a48062","#c4a07c"}
local WOOD = {"#8a5a34","#b0804c","#d0a468","#e6c488","#f4dca4","#fff0c4"}
local MOSS = {"#1f4a2a","#2f6a34","#4a9040","#70b858"}
c:groundShadow(30, 54, 24, 3)
-- trunk body: horizontal cylinder x 6..46, y 24..50
local X0,X1,Y0,Y1 = 6,46,24,50
for y=Y0,Y1 do
  local t=(y-Y0)/(Y1-Y0)
  local v = 0.95 - 0.8*t + 0.15*math.sin(t*3)  -- lit from above
  for x=X0,X1 do
    local h = X.hash(x//3, y, 3)
    local g = X.hash(x, y//2, 7)
    local vi = v + (g-0.5)*0.25
    -- horizontal furrows
    if (y*7 + (x//9)*5) % 9 == 0 and h > 0.25 then vi = vi - 0.4 end
    local i = math.max(1, math.min(6, math.floor(vi*5.99)+1))
    c:put(x,y,BARK[i],{r={name="bark"}})
  end
end
-- cool shade row at bottom
for x=X0,X1 do c:px(x,Y1,BARK[1]) c:px(x,Y1-1,BARK[2]) end
-- broken branch stubs on top
local function stub(x0,w,h,lean)
  for y=0,h-1 do for x=0,w-1 do
    local px = x0+x+math.floor(y*lean)
    c:px(px, Y0-1-y+1, x==0 and BARK[5] or (x==w-1 and BARK[2] or BARK[4]))
  end end
  for x=0,w-1 do c:px(x0+x+math.floor(h*lean), Y0-h+1, WOOD[3]) end
end
stub(14,5,7,-0.3) stub(30,4,5,0.2)
-- moss patch low-left
for _,p in ipairs{{10,48},{11,48},{12,48},{13,48},{9,47},{10,47},{11,47},{12,47},{14,47},{11,46},{12,46},{13,46},{10,49},{12,49},{15,48}} do c:px(p[1],p[2],MOSS[2+(p[1]+p[2])%2]) end
c:px(11,46,MOSS[4]) c:px(12,47,MOSS[4]) c:px(10,48,MOSS[1])
-- end face (cut rings) ellipse at x=47
local ef = c:ellipse(47,37,8,13)
local n = X.pillow(ef, 8)
X.tone(c, ef, X.light(n,{amb=0.3,wrap=0.4}), WOOD, {cuts={.2,.38,.54,.7,.85}})
for _,r in ipairs{{6,10},{4,7},{2,4}} do
  local ring = c:ellipse(47,37,r[1],r[2]) ring:cut(c:ellipse(47,37,r[1]-1,r[2]-1))
  c:fillMask(ring, WOOD[1+(r[1]%2)])
end
c:px(47,37,WOOD[1]) c:px(46,36,WOOD[2])
-- crack from pith (quirk) and bark rim
for i=0,5 do c:px(48+i//2, 37+i//2, WOOD[1]) end
c:px(42,30,WOOD[6]) c:px(43,29,WOOD[6]) c:px(41,31,WOOD[5])
-- glint on bark
c:px(20,26,BARK[6]) c:px(21,26,BARK[6])
G.save(c, "oak-log")
