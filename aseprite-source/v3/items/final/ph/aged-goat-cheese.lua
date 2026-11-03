local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- aged-goat-cheese: a wedge cut from a small wheel: crumbly ivory paste with eyes, wrinkled ash-grey rind, one cut crumb. quirk: a mouse looks out of a hole.
local c = D.new("aged-goat-cheese")
c:groundShadow(32, 56, 22, 2)
local CH = {"#a88a52","#c8aa68","#e4cc84","#f2dea0","#fae8b8","#fff4d6"}
local RD = {"#3a3236","#544a4c","#746a68","#948a84","#b4aaa0","#d2c8bc"}
local top = c:poly{{8,30},{34,14},{56,24},{34,36}}
local front = c:poly{{8,30},{34,36},{34,52},{8,46}}
local side = c:poly{{34,36},{56,24},{56,40},{34,52}}
D.lit(top, CH, 6) 
D.lit(front, CH, 3, {nospec=true}) 
D.lit(side, RD, 3, {nospec=true})
-- rind top rim
for x = 8, 56 do end
D.ln(8,30,34,36,RD[4]) D.ln(8,31,34,37,RD[3]) D.ln(34,36,56,24,RD[3])
for _, p in ipairs{{40,34},{46,32},{50,29},{42,42},{49,38},{38,46}} do c:px(p[1], p[2], RD[2]) c:px(p[1]+1, p[2], RD[5]) end
-- paste eyes on the front
for _, e in ipairs{{14,39,2},{20,43,1.4},{27,40,1.8},{24,48,1.2}} do
  c:fillMask(c:ellipse(e[1], e[2], e[3], e[3]), "#a88a52") c:px(e[1], e[2]-1, "#c8aa68")
end
-- mouse in the big hole
c:fillMask(c:ellipse(14,39,2.6,2.6), "#6f4033")
c:px(13,38,"#aa9a9a") c:px(15,38,"#aa9a9a") c:px(13,39,"#2b1c26") c:px(15,39,"#2b1c26") c:px(14,40,"#f08aa4")
c:px(11,36,"#d9b3b3") c:px(12,36,"#d9b3b3") c:px(16,36,"#d9b3b3") c:px(17,36,"#d9b3b3")
-- crumbs
c:px(52,48,"#f2dea0") c:px(54,50,"#e4cc84") c:px(50,51,"#fae8b8")
D.fin()
