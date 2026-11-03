local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-egg: bold cream egg standing on a soft shadow, freckled.
-- quirk: a zigzag crack with a tiny orange beak poking out.
local c = D.new("ico-egg")
c:groundShadow(32, 57, 13, 2)
local m = c:ellipse(32, 37, 15, 18):add(c:ellipse(32, 27, 11, 14))
D.lit(m, D.CREAM, 9, { amb = 0.05 })
for _, p in ipairs{ {24,40},{27,47},{38,44},{22,33},{40,34},{33,51},{29,36} } do
  if m:has(p[1], p[2]) then c:px(p[1], p[2], "#a37a52") c:px(p[1]+1, p[2], "#a37a52") end
end
D.poly(c, { {35,22},{38,26},{34,29},{39,33},{35,36},{38,40} }, "#6f4033")
c:fillMask(c:rect(36, 28, 38, 29), "#f28a34") c:px(36, 28, "#ffc060")
c:px(26, 22, CR) c:px(27, 22, CR) c:px(25, 24, CR)
D.fin()
