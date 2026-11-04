-- noni (lean W2_11)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w=64, h=64, scale=1, name="noni" }
local FR  = {"#5a6a2a","#84944a","#aab868","#cad88a","#e4eeb0","#f8fbd8"}
local LF  = {"#1b3b3c","#255644","#32764b","#4b9650","#70b45a","#9ccd6c"}
local STM = {"#4a3a22","#6a5a30","#8a7a44","#b0a064"}
c:groundShadow(32, 58, 14, 2)
-- stem + leaf
local sm, sn = G.tube({{32,16},{32,13},{34,10},{36,8}}, function(t) return 1.6 - 0.4*t end)
G.toneN(c, sm, sn, STM, {})
local lm, ln, T, S = G.blade(36,9, 44,0, 58,9, function(t) return 6*math.sin(math.pi*t)^0.7 end, {})
G.toneN(c, lm, ln, LF, {})
lm:each(function(x,y) local k=K(x,y) if math.abs(S[k])<0.15 and T[k]>0.05 and T[k]<0.9 then c:px(x,y,LF[6]) end end)
-- lumpy ovoid fruit
local fm = c:ellipse(32,36,13,20)
for _,b in ipairs{{20,28,3},{44,26,3},{19,40,3},{45,40,3},{24,53,3},{40,54,3},{32,17,3}} do fm:add(c:ellipse(b[1],b[2],b[3],b[3])) end
local n = X.pillow(fm, 10)
local v = X.light(n, {amb=0.1, wrap=0.25})
X.tone(c, fm, v, FR, {cuts={.2,.38,.54,.7,.85}})
-- polygonal eyes (dark pits ringed lighter)
for _,e in ipairs{{26,22},{37,24},{31,29},{23,34},{40,34},{29,40},{36,43},{24,46},{41,46},{31,51},{37,32},{27,27}} do
  local x,y=e[1],e[2]
  c:px(x,y,FR[1]) c:px(x+1,y,FR[1]) c:px(x,y+1,FR[2]) c:px(x+1,y+1,FR[2])
  c:px(x-1,y-1,FR[5]) c:px(x,y-1,FR[5])
end
-- bite-sized pale wart quirk: a tiny cut showing cream flesh
for _,p in ipairs{{41,30},{42,30},{41,31},{42,31},{43,31}} do c:px(p[1],p[2],"#fbf3cf") end
c:px(41,32,FR[2]) c:px(42,32,FR[2])
-- spec
c:px(25,25,"#fffaf0") c:px(26,25,"#fffaf0") c:px(25,26,FR[6])
G.save(c, "noni")
