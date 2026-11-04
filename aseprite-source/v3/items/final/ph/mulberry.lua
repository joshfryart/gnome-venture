-- mulberry: elongated dark-purple drupelet cluster, green calyx stem and a lobed leaf. quirk: one drupelet is still red and unripe.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("mulberry")
local LF = D.R("#c4e07a", "#7cc35a", "#3f9150", "#24544a")
local BR = D.R("#b49af0", "#6a4cb8", "#42307e", "#241a4e")
local RD = D.R("#ffa07a", "#e8493b", "#b52e3f", "#6e2038")
D.heart(c, 47, 14, 9, 0.5, LF, true)
D.stem(c, { {33,18}, {35,12}, {40,12} }, 2, "#5a9a46", "#a0d070")
local row = 0
for y = 22, 52, 4 do
  local half = ({ 1, 2, 2, 2, 2, 2, 2, 1 })[row + 1] or 1
  row = row + 1
  for i = -half, half do
    local x = 31 + i * 4.6 + (row % 2) * 2.2
    local rd = (row == 4 and i == 1)
    B.lit(c, c:ellipse(floor(x), y, 2.3, 2.3), rd and RD or BR, 2)
  end
end
for _, p in ipairs{ {28,26},{33,30},{27,38} } do c:px(p[1], p[2], "#e0d4ff") end
local cal = c:poly{ {28,20}, {31,18}, {34,20}, {36,19}, {35,23}, {29,24} }
B.lit(c, cal, LF, 1.6)
D.fin()
