local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- ackee-seed: glossy black seeds each with a pale yellow aril cap, on a pinnate ackee leaf scrap; sprout shows paired oval leaflets. quirk: an aril is shaped like a little smile.
local c = D.new("ackee-seed")
D.scrap(6, 54, 56, 49, 7.5, D.LEAF, {})
local BLK = {"#0e0a10","#1c1418","#2e242c","#463a46","#665866","#8e808e"}
for _, s in ipairs{{20,50},{32,51},{44,49}} do
  local sd = D.seed(s[1], s[2], 4.4, 5, 0, BLK)
  local ar = c:ellipse(s[1], s[2]+4, 4.8, 2.2):clip(c:rect(0, s[2]+1, 63, 63)) D.lit(ar, D.YEL, 2)
end
c:px(31,54,"#8f5a1f") c:px(32,55,"#8f5a1f") c:px(33,54,"#8f5a1f")
D.stem(32, 45, 32, 24, "#86b86c") D.stem(33, 45, 33, 24, "#6a9a58")
for _, L in ipairs{{26,40,4.2,2.2,-0.4},{39,40,4.2,2.2,0.4},{26,32,4.2,2.2,-0.4},{39,32,4.2,2.2,0.4},{27,26,3.6,1.9,-0.5},{38,26,3.6,1.9,0.5},{32,19,2.2,3.6,0}} do D.lf(L[1], L[2], L[3], L[4], L[5], D.LEAF2) end
D.fin()
