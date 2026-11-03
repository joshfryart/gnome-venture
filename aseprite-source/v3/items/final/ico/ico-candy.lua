local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-candy")
local CR, INK, ell = D.CR, D.INK, D.ell
-- ico-candy: wrapped sweet, glossy red-and-cream swirl body, twisted crinkle wrappers both ends.
-- quirk: a tiny ant is carrying off a crumb on the bottom edge.
local wl = c:poly{ {4, 22}, {17, 29}, {17, 37}, {4, 44}, {8, 33} }
local wr = c:poly{ {60, 22}, {47, 29}, {47, 37}, {60, 44}, {56, 33} }
D.lit(wl, D.SKY, 3) D.lit(wr, D.SKY, 3)
for _, y in ipairs{ 28, 33, 38 } do D.poly(c, { {7, y}, {16, y} }, "#8bc4ea"); D.poly(c, { {48, y}, {57, y} }, "#8bc4ea") end
local body = ell(32, 33, 17, 11, 0)
D.lit(body, D.RED, 7, { amb = 0.1 })
for _, s in ipairs{ -12, -4, 5, 13 } do
  local m = c:poly{ {32 + s, 20}, {32 + s + 5, 20}, {32 + s + 1, 46}, {32 + s - 4, 46} }:clip(body)
  D.lit(m, D.CREAM, 3, { amb = 0.15 })
end
D.px(24, 27, "#fffdf2") D.px(25, 27, "#fffdf2")
D.ant(27, 46)
D.fin()
