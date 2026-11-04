-- naranjilla: a fuzzy orange fruit with a crown of purple-haired green sepals, beside a cut half showing green flesh, four chambers and pale seeds. quirk: the purple fuzz of the calyx stands up in tufts.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("naranjilla")
local OR = D.R("#ffd070", "#f08a20", "#c25a22", "#7a3022")
local GR = D.R("#e0f090", "#a0c850", "#5a9a3c", "#2f5a3c")
c:groundShadow(32, 58, 20, 2)
-- whole fruit
local f = c:ellipse(24, 33, 16, 16)
B.lit(c, f, OR, 14)
f:edge():each(function(x, y) if X.hash(x, y, 3) > .5 and x < 24 and y < 36 then c:px(x, y, "#ffe0a0") end end)
D.speck(c, f:shrink(2), "#ffc060", 4, .88)
c:px(15, 26, "#fff4d6") c:px(16, 26, "#fff4d6") c:px(15, 27, "#fff4d6")
-- calyx
for _, a in ipairs{ -2.6, -2.0, -1.57, -1.1, -0.5 } do
  local ex, ey = 24 + cos(a) * 12, 17 + sin(a) * 7
  B.lit(c, B.ell((24 + ex) / 2, (17 + ey) / 2 + 1, 6, 2.2, a), GR, 1.8)
end
B.lit(c, c:ellipse(24, 18, 4, 2.4), GR, 1.6)
for _, p in ipairs{ {18,10},{22,9},{27,9},{31,11},{20,13},{29,13},{24,12} } do c:px(p[1], p[2], "#c08af0") c:px(p[1], p[2] - 1, "#8a5ad0") end
-- cut half
local h = c:ellipse(46, 44, 11, 11)
B.lit(c, h, OR, 8)
local fl = c:ellipse(46, 44, 9, 9)
B.lit(c, fl, GR, 7)
c:fillMask(c:rect(45, 36, 46, 52), GR.shade) c:fillMask(c:rect(38, 43, 54, 44), GR.shade)
for _, p in ipairs{ {42,40},{50,40},{42,48},{50,48},{43,39},{49,47} } do c:px(p[1], p[2], "#fff4c4") c:px(p[1] + 1, p[2], "#e0d090") end
D.fin()
