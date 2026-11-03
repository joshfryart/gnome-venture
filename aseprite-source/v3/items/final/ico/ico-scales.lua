-- ico-scales first draft. brass balance on a post, tilted beam, two pans. quirk: a feather in one pan outweighs the coins in the other
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-scales")
c:groundShadow(32, 56, 16, 3)
local G = D.GOLD
D.lit(c, c:poly{ {22, 56}, {42, 56}, {38, 50}, {26, 50} }, G, 2.5)
D.lit(c, c:rect(29, 16, 35, 50), G, 3)
-- beam
D.tube(c, { {12, 22}, {32, 16}, {52, 10} }, 4, G, 2)
D.lit(c, c:ellipse(32, 14, 4, 4), G, 3) c:px(31, 13, "#fff0a0")
-- chains
for _, ch in ipairs{ { {12, 23}, {5, 38}, {19, 38} }, { {52, 11}, {46, 28}, {58, 28} } } do
  D.polyline(c, { ch[1], ch[2] }, "#8f4a1f") D.polyline(c, { ch[1], ch[3] }, "#8f4a1f")
end
-- pans
D.lit(c, D.ell(12, 38, 8, 6):clip(c:rect(0, 38, 63, 63)):add(c:rect(4, 38, 20, 39)), G, 3)
D.lit(c, D.ell(52, 28, 8, 6):clip(c:rect(0, 28, 63, 63)):add(c:rect(44, 28, 60, 29)), G, 3)
-- feather in the low pan
D.lit(c, D.ell(12, 33, 6, 2.4, -0.4), D.CRM, 1.5) D.polyline(c, { {7, 36}, {17, 31} }, "#d4b48a")
-- coins in the high pan
D.lit(c, c:ellipse(49, 24, 3, 3), D.YEL, 1.5) D.lit(c, c:ellipse(55, 24, 3, 3), D.YEL, 1.5)
D.fin()
