-- sausage-tree-seed (first draft, Sonnet). Three chunky flat tan Kigelia seeds (ribbed, pale rim) on a broad elliptic
-- leaflet scrap; right seed sprouted a slim pinnate seedling leaf (stem, three leaflet pairs, terminal leaflet).
-- quirk: a little sausage-shaped fruit hangs from the seedling on a thin cord.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("sausage-tree-seed")
local floor = math.floor
local LF = A.R("#4a8a3c")
A.scrap(c, 5, 57, 52, 53, 9.5, LF, { 6, 11, 16, 21, 26, 31, 36, 41 })
local sd = A.R("#b88a56")
for _, s in ipairs{ { 14, 54, 5.2, 3.6, -.18 }, { 26, 53, 5.0, 3.6, .14 }, { 38, 51, 5.2, 3.7, -.1 } } do
  A.seed(c, s[1], s[2], s[3], s[4], s[5], sd, LF[1], "#fff0c8")
  for dx = -2, 2 do c:px(s[1] + dx * 2, s[2] - 1 + (dx % 2), sd[2]) c:px(s[1] + dx * 2, s[2] + 1, sd[2]) end
end
-- pinnate seedling
local pts = { { 38, 48 }, { 38, 40 }, { 38, 32 }, { 38, 14 } }
A.rod(c, 38, 48, 38, 14, 1.0, "#a3ad58", { amb = .1 })
for i, y in ipairs{ 38, 28, 20 } do
  local L = 11 - i * 2
  A.blade(c, 38, y, 38 - L, y - 3, 2.6, "#4a8a3c", { veins = { 3 }, slant = 2 })
  A.blade(c, 38, y, 38 + L, y - 3, 2.6, "#5ea04a", { veins = { 3 }, slant = 2 })
end
A.blade(c, 38, 16, 38, 6, 2.4, "#74b456", { veins = { 3 }, slant = 2 })
-- cord + tiny sausage fruit
for y = 30, 34 do c:px(52, y, "#a88a5a") end
A.lit(c, c:rrect(49, 34, 55, 46, 3), A.R("#a6704a"), 2.2, { amb = .1 })
for y = 36, 44, 3 do c:px(52, y, "#e8c9a0") end
c:px(50, 36, "#ffe0b0")
B = nil
A.rod(c, 38, 24, 52, 30, .5, "#a88a5a")
A.fin()
