local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-calendar")
local CR, INK = D.CR, D.INK
-- ico-calendar: tear-off wall calendar, red header, two binder rings, 3x3 grid of big date squares.
-- quirk: the bottom-right page corner curls up, and one date is circled in pencil-red.
c:groundShadow(32, 58, 18, 2)
local page = c:rrect(10, 12, 53, 55, 3)
page:cut(c:poly{ {53, 46}, {53, 56}, {44, 56} })
D.lit(page, D.CREAM, 3, { amb = 0.1 })
D.lit(c:rrect(10, 12, 53, 25, 3):clip(c:rect(0, 0, 63, 25)), D.RED, 3)
D.fill(c:poly{ {53, 46}, {44, 56}, {44, 46} }, "#ffd98a")
D.poly(c, { {44, 46}, {53, 46} }, "#c9a98a") D.poly(c, { {44, 46}, {44, 55} }, "#c9a98a")
for r = 0, 2 do for q = 0, 2 do
  local x, y = 15 + q * 12, 29 + r * 8
  if not (r == 2 and q == 2) then D.fill(c:rect(x, y, x + 6, y + 5), "#7b8aa6"); D.fill(c:rect(x, y, x + 5, y + 4), "#b6c4d8") end
end end
D.fill(c:rect(15, 37, 20, 41), "#b6c4d8")
D.poly(c, { {37, 36}, {42, 36}, {43, 38}, {42, 41}, {37, 42}, {35, 39}, {36, 36}, {39, 35} }, "#e8493b")
for _, x in ipairs{ 20, 40 } do
  D.lit(c:rect(x, 7, x + 2, 17), D.GRY, 1.2)
end
D.fin()
