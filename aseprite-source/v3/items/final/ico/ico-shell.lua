-- ico-shell first draft. spiral conch with a pink lip. quirk: a tiny red hermit crab peeks out of the opening
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-shell")
local SH = D.CRM
D.lit(c, c:ellipse(32, 29, 18, 18), SH, 7, { amb = 0.1 })
-- spiral
D.spiral(c, 32, 29, 16, 2.2, "#c9a98a", c:ellipse(32, 29, 18, 18), 0.4)
D.spiral(c, 32, 29, 16, 2.2, "#fffbe8", c:ellipse(32, 29, 18, 18).shift and c:ellipse(32, 29, 18, 18):shift(-1, -1) or nil, 0.4)
-- lip
D.lit(c, D.ell(20, 47, 11, 8, -0.4), D.PINK, 3)
D.lit(c, D.ell(18, 48, 6, 4, -0.4), { "#4a1630", "#6e2150", "#a33468", "#d4527e", "#f27a9a", "#ffa4bc" }, 1.5)
-- crab
D.lit(c, D.ell(16, 49, 4, 3), D.RED, 2)
D.R(c, 13, 45, 13, 47, "#d4403a") D.R(c, 17, 45, 17, 47, "#d4403a")
c:px(13, 44, "#2b1c26") c:px(17, 44, "#2b1c26")
D.lit(c, c:ellipse(10, 51, 3, 2), D.RED, 1)
c:px(32, 22, "#fffbe8") c:px(33, 22, "#fffbe8")
D.fin()
