-- mossy-shell: lavender scallop shell wearing a cushion of moss. quirk: a tiny fern frond unrolls from the moss.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("mossy-shell")
local SH = D.R("#f6dcf2", "#c8a0e0", "#9068b8", "#523a7e")
c:groundShadow(32, 56, 17, 2)
local fan = c:ellipse(32, 36, 21, 19):cut(c:rect(0, 40, 63, 63))
fan:add(c:poly{ {14,38}, {50,38}, {40,52}, {24,52} })
B.lit(c, fan, SH, 9, { amb = .12 })
for i = -5, 5 do
  local a = -pi / 2 + i * 0.27
  B.ln(c, 32 + cos(a) * 4, 51 + sin(a) * 4, 32 + cos(a) * 30, 51 + sin(a) * 30, i % 2 == 0 and SH.deep or SH.hi, fan)
end
-- growth arcs
for _, r in ipairs{ 9, 15, 21 } do
  for i = -20, 20 do local a = -pi / 2 + i * 0.075 local x, y = floor(32 + cos(a) * r + .5), floor(51 + sin(a) * r * .95 + .5)
    if fan:has(x, y) and i % 2 == 0 then c:px(x, y, SH.shade) end end
end
local hinge = c:rrect(25, 51, 39, 56, 2)
B.lit(c, hinge, SH, 2)
B.ln(c, 27, 54, 37, 54, SH.deep, hinge)
-- moss cushion
local MS = D.R("#d4f08a", "#7cc35a", "#3f9150", "#24544a")
for _, p in ipairs{ {34,22,5}, {40,26,6}, {45,31,5}, {30,24,4}, {38,20,4}, {43,23,4} } do
  local m = c:ellipse(p[1], p[2], p[3], p[3] * .8)
  B.lit(c, m, MS, 2.4)
  D.speck(c, m, MS.hi, p[1] * 3, .85)
end
-- fern frond
D.stem(c, { {40,19}, {41,12}, {45,9}, {48,11}, {47,13} }, 1, "#3f9150", "#7cc35a")
for _, p in ipairs{ {41,16}, {42,13}, {44,10} } do c:px(p[1] - 2, p[2], "#7cc35a") c:px(p[1] + 2, p[2], "#7cc35a") end
D.fin()
