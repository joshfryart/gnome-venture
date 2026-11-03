local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- agapanthus-seed: flat black papery-winged seeds spilling from a split three-valve capsule, on a long strap leaf; sprout is two grassy strap blades. quirk: a seed is stuck to the capsule rim.
local c = D.new("agapanthus-seed")
D.scrap(4, 55, 58, 48, 6.5, D.LEAF, {norib=false})
for i = 0, 5 do D.ln(10+i*8, 54-floor(i*.9), 14+i*8, 51-floor(i*.9), "#6ab455") end
local BK = {"#0e0a10","#1e1620","#32283a","#4a4058","#6a6078","#948aa4"}
for _, s in ipairs{{16,51,4,2.6,0.3},{25,52,4,2.6,-0.2},{34,51,3.8,2.5,0.5}} do
  local m = D.seed(s[1], s[2], s[3], s[4], s[5], BK)
end
-- capsule: three valves
local CV = {"#5e4630","#7e6a3c","#a08e52","#c0b070","#dccc90","#f0e4b4"}
D.lit(c:poly{{44,50},{40,34},{44,28},{48,36},{48,50}}, CV, 2)
D.lit(c:poly{{48,50},{52,36},{56,30},{58,38},{54,50}}, CV, 2)
D.lit(c:poly{{40,34},{36,30},{42,24},{46,26}}, CV, 2)
D.ln(48,36,48,50,"#5e4630") D.ln(49,40,52,36,"#5e4630")
c:fillMask(c:rect(47,36,49,44), "#2a2030")
c:px(40,44,"#32283a") c:px(39,44,"#32283a") c:px(39,45,"#4a4058")
-- sprout blades
D.leaf = nil
local function strap(x0,y0,x1,y1) local m = B.blade(c, x0,y0,x1,y1, 1.8, D.LEAF2, {norib=true}) end
strap(24,48,14,24) strap(26,48,28,18) strap(28,48,40,22)
D.fin()
