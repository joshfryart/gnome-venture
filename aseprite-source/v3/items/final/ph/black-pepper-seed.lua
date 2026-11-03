local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("black-pepper-seed")
-- black-pepper-seed: five wrinkled peppercorns on a scrap of black-pepper leaf; vine sprout with a glossy heart leaf. quirk: one corn is still red-ripe.
D.scrap(6, 56, 56, 46, 8, D.LEAF)
local PP = {"#14100e","#2a2220","#463a34","#675750","#8a7a70","#b0a094"}
local RP = D.RED
local pts = {{13,51,PP},{23,53,PP},{33,52,PP},{43,50,RP},{51,53,PP}}
for i, p in ipairs(pts) do
  D.seed(p[1], p[2], 3.4, 3.2, 0, p[3])
  D.px(p[1]-1, p[2]+1, p[3][2]) D.px(p[1]+1, p[2], p[3][2]) D.px(p[1], p[2]-1, p[3][2])
end
D.stem2(33, 48, 33, 30)
D.P({{33,12},{40,17},{41,25},{34,31},{33,30},{26,26},{25,18}}, D.LEAF2, 3)
D.ln(33, 14, 33, 29, "#bfe688") D.ln(33, 20, 38, 18, "#bfe688") D.ln(33, 20, 28, 18, "#bfe688") D.ln(33, 24, 37, 23, "#5a9a50")
D.px(29, 17, "#fff4d6")
D.fin()
