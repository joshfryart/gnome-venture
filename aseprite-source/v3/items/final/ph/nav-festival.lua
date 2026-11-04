-- nav-festival (dC25 first draft, Sonnet). A sagging line of six bunting flags with two paper lanterns hanging below. quirk: one flag has lost its corner and flutters as a swallowtail.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC25.lua")
local c = D.new("nav-festival") local B, R, HP = D.B, D.R, D.HP
local cols = {R.red, R.sun, R.sprout, R.blue, R.petal, R.dusk}
local function y_at(x) return 10 + 14 * (1 - ((x - 32) / 26) ^ 2) end
for x = 6, 58 do c:px(x, math.floor(y_at(x) + .5) - 2 + 2, R.wood and R.brown[3] or "#b97a4a") end
for i = 0, 5 do
  local x = 9 + i * 8.4 local y = y_at(x + 3)
  local m = c:poly{{x, y - 1}, {x + 7, y - 1}, {x + 3.5, y + 12 + (i == 3 and 0 or 0)}}
  if i == 3 then m = c:poly{{x, y - 1}, {x + 7, y - 1}, {x + 7, y + 6}, {x + 3.5, y + 11}, {x, y + 6}} end
  B.lit(c, m, cols[i + 1], 3)
end
B.ln(c, 22, 28, 22, 36, R.brown[3]) B.ln(c, 42, 28, 42, 34, R.brown[3])
B.lit(c, c:ellipse(22, 42, 6, 6), R.red, 3) c:px(19, 39, "#fff4d6")
B.lit(c, c:ellipse(42, 40, 5, 5), R.sun, 3) c:px(39, 37, "#fff4d6")
D.line(c, {{20, 49}, {24, 49}}, 1, R.gold[4]) D.line(c, {{41, 46}, {43, 46}}, 1, R.gold[1])
D.fin()
