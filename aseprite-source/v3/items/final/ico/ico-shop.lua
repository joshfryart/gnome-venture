-- ico-shop first draft. little shop with striped awning, door and window. quirk: a sleepy cat curls up on the awning
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-shop")
c:groundShadow(32, 56, 24, 3)
D.lit(c, c:rect(11, 26, 53, 54), D.CRM, 4)
-- door
D.lit(c, c:rrect(25, 36, 37, 54, 1), D.BRN, 3) c:px(34, 46, "#ffd45a") c:px(34, 47, "#ffd45a")
-- windows
for _, x in ipairs{ 14, 41 } do
  D.lit(c, c:rect(x, 32, x + 8, 43), D.TEAL, 2) D.R(c, x + 4, 32, x + 4, 43, "#8a4a26") D.R(c, x, 37, x + 8, 37, "#8a4a26")
  D.R(c, x - 1, 44, x + 9, 45, "#864c33")
end
-- awning
local aw = c:poly{ {8, 14}, {56, 14}, {58, 26}, {6, 26} }
D.lit(c, aw, "ember", 4)
local st = D.mk(0, 14, 63, 28, function(x, y) return aw:has(x, y) and ((x // 6) % 2 == 0) end)
D.lit(c, st, D.CRM, 2)
for x = 6, 56, 6 do D.lit(c, c:ellipse(x + 3, 27, 3, 2), (x // 6) % 2 == 0 and D.CRM or "ember", 1) end
-- cat
D.lit(c, D.ell(45, 11, 7, 4), D.ORG, 2) 
D.lit(c, c:poly{ {38, 10}, {38, 5}, {42, 8} }, D.ORG, 1) D.lit(c, c:poly{ {44, 8}, {46, 4}, {48, 8} }, D.ORG, 1)
D.R(c, 40, 9, 41, 9, "#2b1c26") D.R(c, 44, 9, 45, 9, "#2b1c26")
D.polyline(c, { {51, 12}, {55, 10}, {56, 6} }, "#d9661f")
D.fin()
