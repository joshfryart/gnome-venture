-- tortoise-scute (lean W2_36)
-- A single shed carapace plate seen slightly from above: thick hexagonal slab with a raised top face,
-- concentric growth-ring grooves, darker seam rim, and a visible side thickness with layered keratin.
-- quirk: one corner is chipped off and a tiny moss sprig clings to the cut.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w=64, h=64, scale=1, name="tortoise-scute" }
c:groundShadow(32,54,20,3)
local amber = { hi="#ffe38a", base="#d9a83a", shade="#a8731f", deep="#5d3a18" }
local side  = { hi="#c89432", base="#a8731f", shade="#7a4c1a", deep="#4a2c16" }
local function hex(cx,cy,rx,ry) return c:poly{{cx-rx,cy},{cx-rx/2,cy-ry},{cx+rx/2,cy-ry},{cx+rx,cy},{cx+rx/2,cy+ry},{cx-rx/2,cy+ry}} end
-- thickness: same hex shifted down
local slab = hex(32,29,22,16)
local under = slab:copy():shift(0,6):cut(slab)
local body = slab:copy():add(slab:copy():shift(0,6))
-- chipped corner (right)
local chip = c:poly{{50,30},{56,33},{54,44},{47,40}}
body:cut(chip)
local top = slab:copy():cut(chip)
local sd = body:copy():cut(top)
c:part(sd, side, {band=2})
for y=36,40,2 do sd:each(function(x,yy) if yy==y and X.hash(x,yy,5)>0.2 then c:px(x,yy,side.deep) end end) end
c:part(top, amber, {band=3})
-- rim seam
local inner = hex(32,29,19,13):cut(chip)
top:copy():cut(inner):each(function(x,y) if X.hash(x,y,1)>0.1 then c:px(x,y,amber.shade) end end)
-- growth rings
for _,r in ipairs{{15,10,amber.deep},{10,7,amber.shade},{5,3.5,amber.deep}} do
  local o = hex(32,29,r[1],r[2]); local i = hex(32,29,r[1]-1.6,r[2]-1.2)
  o:cut(i):cut(chip):each(function(x,y) c:px(x,y,r[3]) end)
  -- highlight just inside upper-left
  i:each(function(x,y) if y<29 and x<32 and not i:copy():shrink(1):has(x,y) then c:px(x,y,amber.hi) end end)
end
c:px(31,28,amber.hi) c:px(32,28,amber.hi) c:px(25,22,"#fff6d0") c:px(26,22,"#fff6d0")
-- moss sprig on chip
c:part(c:ellipse(49,40,3,2), "moss")
c:px(48,38,"#c4e07a")
G.save(c, "tortoise-scute")
