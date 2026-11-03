-- ico-roadworks first draft. striped barrier on two legs with an amber lamp. quirk: a gnome-sized lamp with sleepy flicker rays
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-roadworks")
c:groundShadow(32, 54, 22, 3)
for _, x in ipairs{ 14, 45 } do
  D.lit(c, c:rect(x, 30, x + 5, 52), "wood", 2.5)
  D.lit(c, c:rect(x - 3, 50, x + 8, 54), "wood", 1.8)
end
local board = c:rrect(8, 17, 56, 33, 2)
D.lit(c, board, "ember", 4)
local st = D.mk(9, 18, 55, 32, function(x, y) return (((x + y) // 6) % 2 == 0) and board:copy():shrink(1):has(x, y) end)
D.lit(c, st, D.CRM, 2)
D.R(c, 9, 17, 55, 17, "#ff8a5c")
-- lamp
D.R(c, 28, 14, 36, 16, "#74758c")
D.lit(c, c:ellipse(32, 10, 4, 4), D.ORG, 3)
c:px(30, 8, "#fff4d6")
D.pts(c, { {23, 9}, {24, 9}, {40, 9}, {41, 9}, {25, 4}, {39, 4} }, "#ffd080")
D.fin()
