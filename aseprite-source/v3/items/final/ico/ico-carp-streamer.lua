local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-carp-streamer")
local CR, INK, ell = D.CR, D.INK, D.ell
-- ico-carp-streamer: koinobori windsock on a wooden pole, red fish body with scale rows, white mouth ring, fish tail.
-- quirk: a tiny swallow rests on the pole top.
D.lit(c:rect(7, 8, 10, 59), D.WOODR, 1.8)
D.lit(c:ellipse(8.5, 8, 3, 3), D.YEL, 2.5)
local m, T = D.H.sweep({ {14, 25}, {26, 20}, {40, 29}, {47, 32} }, function(t) return 10 - 6 * t end, 50)
D.lit(m, D.RED, 5, { amb = 0.1 })
D.lit(c:ellipse(13, 26, 4, 8):clip(c:rect(0, 0, 14, 63)), D.CREAM, 2, { amb = 0.2 })
D.fill(c:ellipse(14, 26, 2, 6), "#2a1620")
D.fill(c:poly{ {46, 31}, {58, 20}, {55, 33}, {59, 45} }, "#d4403a")
D.lit(c:poly{ {46, 31}, {58, 20}, {55, 33}, {59, 45} }, D.RED, 2)
for _, p in ipairs{ {26, 24}, {32, 27}, {38, 30} } do
  for dy = -1, 1 do D.px(p[1] + (dy == 0 and 1 or 0), p[2] + dy * 3, D.RED[2]) D.px(p[1] - 1 + (dy == 0 and 1 or 0), p[2] + dy * 3 + 1, D.RED[2]) end
end
D.fill(c:rect(22, 20, 23, 22), D.CR) D.px(21, 19, INK) D.px(22, 19, INK)
D.fill(c:rect(21, 18, 24, 19), "#2a1620"); D.px(22, 18, "#8bc4ea")
-- swallow
D.fill(c:ellipse(8, 3, 3, 2), "#35295f"); D.px(5, 3, "#35295f"); D.px(6, 2, "#ffa6bd") D.px(10, 4, "#35295f") D.px(11, 5, "#35295f")
D.fin()
