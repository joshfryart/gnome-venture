-- ico-rod first draft. slim fishing rod, cork grip, reel, line, bobber. quirk: an old boot is hooked instead of a fish
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-rod")
-- line first
D.polyline(c, { {50, 9}, {52, 16}, {52, 28} }, "#fff4d6")
D.tube(c, { {9, 56}, {20, 43} }, 4, D.TAN, 2)
local rod = D.tube(c, { {20, 43}, {40, 20}, {49, 9}, {53, 8} }, 3, D.BRN, 1.6)
D.R(c, 21, 40, 24, 41, "#c98a54")
D.lit(c, c:ellipse(25, 43, 4, 4), D.GRY, 3)
c:px(24, 42, "#eef0fa")
D.lit(c, c:ellipse(52, 31, 4, 4), D.RED, 3)
D.lit(c, c:rect(49, 32, 55, 35):clip(c:ellipse(52, 31, 4, 4)), D.CRM, 1)
-- boot
D.lit(c, c:poly{ {47, 40}, {53, 40}, {54, 49}, {58, 52}, {58, 56}, {46, 56}, {46, 49} }, D.BRN, 2.2)
D.R(c, 46, 39, 54, 41, "#c98a54")
D.R(c, 46, 54, 58, 56, "#2b1c26")
D.pts(c, { {50, 44}, {51, 46} }, "#fff4d6")
D.fin()
