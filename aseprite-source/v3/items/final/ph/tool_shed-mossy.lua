-- tool_shed-mossy (lean W2_36)
-- Lopsided lean-to shed in side view: single-pitch slate roof rising to the left, fieldstone foundation,
-- mossy cushions on the roof, a vine up the corner post, window with cross, toadstool by the door.
-- quirk: a tiny red toadstool grows right out of the roof.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w=64, h=64, scale=1, name="tool_shed-mossy" }
c:groundShadow(32,56,26,3)
local slate = { hi="#a5b0cc", base="#6f7aa0", shade="#4e5883", deep="#323a5e" }
-- foundation stones
local fnd = c:rect(12,48,52,54)
c:part(fnd, "stone", {band=2})
for _,x in ipairs{19,27,36,44} do c:line({{x,48},{x,54}},1):each(function(px,py) c:px(px,py,"#444663") end) end
c:line({{12,51},{52,51}},1):each(function(x,y) if X.hash(x,y,2)>0.3 then c:px(x,y,"#74758c") end end)
-- wall (boards)
local wall = c:poly{{14,26},{50,34},{50,48},{14,48}}
c:part(wall, "wood", {band=2})
for x=19,47,5 do c:line({{x,30},{x,47}},1):each(function(px,py) if wall:has(px,py) then c:px(px,py,"#51302b") end end) end
-- window
c:part(c:rect(33,36,43,44), "sky")
c:line({{38,36},{38,44}},1):each(function(x,y) c:px(x,y,"#864c33") end)
c:line({{33,40},{43,40}},1):each(function(x,y) c:px(x,y,"#864c33") end)
-- door (dark, ajar)
c:part(c:rect(19,32,28,47), {hi="#7a5238", base="#51302b", shade="#33201e", deep="#241719"})
c:rect(24,33,28,47):each(function(x,y) c:px(x,y,"#241719") end)
-- lean-to roof (slab sloping down to the right)
local roof = c:poly{{8,26},{58,36},{58,40},{8,30}}
c:part(roof, slate, {band=2})
c:line({{9,28},{57,38}},1):each(function(x,y) c:px(x,y,slate.deep) end)
-- moss cushions
local moss = { hi="#c4e07a", base="#7cc35a", shade="#3f9150", deep="#24544a" }
c:part(c:ellipse(18,25,6,3), moss)
c:part(c:ellipse(40,31,5,2), moss)
c:part(c:ellipse(54,38,3,2), moss)
c:part(c:ellipse(13,48,3,2), moss)
c:part(c:ellipse(46,53,4,1), moss)
-- toadstool on roof
c:part(c:rect(30,24,31,28), {hi="#fff4d6", base="#e8dcc0", shade="#c9b99a", deep="#8a7a66"})
c:part(c:ellipse(30,23,3,2), "ember")
c:px(29,22,"#fff4d6") c:px(32,23,"#fff4d6")
-- vine up the corner post
local vine = { {50,52},{51,48},{49,44},{51,40},{49,37} }
c:line(vine,1):each(function(x,y) c:px(x,y,"#3f9150") end)
for _,p in ipairs{{52,47},{48,43},{52,39},{48,38},{52,44}} do c:px(p[1],p[2],"#7cc35a") c:px(p[1]+1,p[2],"#c4e07a") end
G.save(c, "tool_shed-mossy")
