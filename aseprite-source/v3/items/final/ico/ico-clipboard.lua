local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-clipboard")
local CR, INK = D.CR, D.INK
-- ico-clipboard: wooden board with a steel clip, cream sheet, three check rows: two green ticks and one empty box.
-- quirk: a pencil is tucked behind the clip, and the third row is still unticked.
local pn = c:poly{ {49, 4}, {52, 6}, {47, 18}, {44, 15} }
D.lit(c:rrect(11, 8, 53, 58, 4), D.WOODR, 4)
D.lit(c:rect(15, 13, 49, 54), D.CREAM, 2, { amb = 0.1 })
for i, y in ipairs{ 20, 32, 44 } do
  D.fill(c:rect(18, y, 25, y + 7), "#7b8aa6"); D.fill(c:rect(19, y + 1, 24, y + 6), "#f6e6bf")
  D.rect(29, y + 2, 45, y + 3, "#9aa8bf") D.rect(29, y + 6, 40, y + 6, "#c9d2e0")
  if i < 3 then D.poly(c, { {19, y + 3}, {21, y + 6}, {26, y - 1} }, "#2f8450"); D.poly(c, { {19, y + 4}, {21, y + 7}, {26, y} }, "#3fa862") end
end
D.lit(c:rrect(23, 3, 41, 13, 2), D.GRY, 2)
D.fill(c:rect(29, 6, 35, 8), D.GRY[1]) D.px(26, 5, D.GRY[6]) D.px(27, 5, D.GRY[6])
D.lit(pn, D.YEL, 1.5); D.fill(c:poly{ {47, 18}, {44, 15}, {44, 20} }, "#ffd98a"); D.px(44, 19, INK)
D.fin()
