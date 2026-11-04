-- nav-villagers (lean W2_11)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w=64, h=64, scale=1, name="nav-villagers" }
local function sh(m, R, ramp, amb)
  local n = X.pillow(m, R)
  X.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, { cuts = {.22,.4,.56,.72,.86} })
end
local RED  = {"#5a1c2e","#8a2535","#b8353a","#d9553f","#ee7a4d","#f7a86a"}
local BLUE = {"#1f2a5e","#2f4a8c","#3f6bb5","#5a8fd0","#82b4e4","#b4d8f2"}
local GREEN= {"#173d33","#22583c","#2f7a45","#47a04d","#6cc05a","#9ad87a"}
local YEL  = {"#6b3a1c","#9a5a20","#c98424","#e8a82e","#f6c94a","#fde88a"}
local SKINA= {"#6e3a2c","#8e5236","#ae6c44","#c98a58","#e0a870","#f2c898"}
local SKINB= {"#a45a4a","#c97a62","#e69a7a","#f4b896","#fccdb0","#ffe2cc"}
local WHITE= {"#6a6a9a","#9a9ac0","#c4c4dc","#e2e2ee","#f4f4fa","#fffaf0"}
c:groundShadow(32, 58, 26, 3)
-- left gnome body (green coat) and right gnome (yellow tunic)
sh(c:rrect(6,42,31,58,6), 9, GREEN)
sh(c:ellipse(43,50,14,9), 9, YEL)
c:rect(30,44,31,57)
-- right head + blue hat with bent tip and pompom
sh(c:ellipse(43,40,6,6), 5, SKINB)
sh(c:poly{{36,37},{50,37},{47,21},{51,13},{57,15},{53,13},{50,13},{43,22}}, 6, BLUE)
sh(c:ellipse(56,15,2,2), 2, YEL)
-- left head, beard, red hat
sh(c:ellipse(19,41,6,5), 5, SKINA)
sh(c:poly{{12,48},{26,48},{19,60},{19,60}}, 5, WHITE)
sh(c:poly{{11,38},{27,38},{20,5},{18,5}}, 8, RED)
-- hat brims
c:fillMask(c:rect(11,37,27,38), RED[1])
c:fillMask(c:rect(36,36,50,37), BLUE[1])
-- eyes, cheeks, nose
c:px(16,41,"#2b1c26") c:px(22,41,"#2b1c26") c:px(19,42,"#c07050") c:px(19,43,"#c07050")
c:px(40,40,"#2b1c26") c:px(46,40,"#2b1c26") c:px(43,43,"#d06a6a") c:px(41,43,"#f08a8a") c:px(45,43,"#f08a8a")
-- beard strands, coat buttons, tunic stitch
for y=50,57,2 do c:px(19,y,WHITE[2]) end
c:px(24,50,GREEN[5]) c:px(24,54,GREEN[5]) c:px(12,52,GREEN[1])
for x=36,54,3 do c:px(x,56,YEL[2]) end
c:px(18,10,RED[6]) c:px(19,14,RED[5]) c:px(45,24,BLUE[6])
c:sparkle(57,10)
G.save(c, "nav-villagers")
