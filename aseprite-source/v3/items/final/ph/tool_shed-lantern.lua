-- tool_shed-lantern (lean W2_36)
-- Front-gable plank shed, steep slate roof, iron bracket arm on the right holding a glowing hanging lantern.
-- quirk: a single mismatched light plank patched into the wall.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w=64, h=64, scale=1, name="tool_shed-lantern" }
c:groundShadow(32,56,24,3)
local slate = { hi="#a5b0cc", base="#6f7aa0", shade="#4e5883", deep="#323a5e" }
local iron  = { hi="#8c8fa8", base="#555770", shade="#3a3b52", deep="#2b2740" }
local glass = { hi="#fff6b0", base="#ffd24a", shade="#f09a26", deep="#a85a1e" }
-- walls
local wall = c:rect(14,30,50,54)
c:part(wall, "wood", {band=2})
for x=19,47,5 do c:line({{x,31},{x,53}},1):each(function(px,py) c:px(px,py,"#51302b") end) end
-- patched plank quirk
c:rect(34,38,38,50):each(function(x,y) c:px(x,y, (x==34) and "#c89a68" or "#e8b982") end)
-- door
local door = c:rect(19,38,29,54)
c:part(door, {hi="#9a6a46", base="#6d4430", shade="#51302b", deep="#33201e"})
c:line({{19,42},{29,50}},1):each(function(x,y) c:px(x,y,"#33201e") end)
c:line({{29,42},{19,50}},1):each(function(x,y) c:px(x,y,"#33201e") end)
c:px(27,46,"#ffe38a")
-- stone step
c:part(c:rect(17,54,31,55), "stone")
-- roof (gable triangle w/ overhang)
local roof = c:poly{{6,33},{32,8},{58,33}}
c:part(roof, slate, {band=3})
for y=14,32,3 do c:line({{32-(y-8)-1,y},{32+(y-8)+1,y}},1):each(function(x,yy) if roof:has(x,yy) and X.hash(x,yy,3)>0.15 then c:px(x,yy,slate.deep) end end) end
for y=12,31,3 do for x=10,54 do if roof:has(x,y) and X.hash(x,y,9)>0.93 then c:px(x,y,slate.hi) end end end
c:rect(6,32,58,33):each(function(x,y) if roof:has(x,y) or y==33 then c:px(x,y,y==33 and slate.deep or slate.shade) end end)
-- gable vent
c:part(c:rect(30,20,34,24), "wood")
-- bracket arm + chain
c:line({{50,35},{55,35}},1):each(function(x,y) c:px(x,y,iron.base) end)
c:px(50,36,iron.shade) c:px(51,36,iron.shade) c:px(52,35,iron.hi)
c:line({{55,36},{55,38}},1):each(function(x,y) c:px(x,y,iron.hi) end)
-- lantern
c:part(c:poly{{52,38},{58,38},{57,40},{53,40}}, iron)
c:part(c:rect(53,40,57,47), glass, {band=2})
c:part(c:rect(52,48,58,49), iron)
c:px(54,41,"#ffffe0") c:px(54,42,"#fff6b0")
c:line({{55,40},{55,47}},1):each(function(x,y) c:px(x,y,glass.hi) end)
c:sparkle(50,44)
G.save(c, "tool_shed-lantern")
