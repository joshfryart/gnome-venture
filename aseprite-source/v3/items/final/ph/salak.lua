-- salak (first draft, Sonnet). Snake fruit: a teardrop with a pointed tip, overlapping diamond scales in brown with a
-- paler lit edge, a short stalk, and one corner peeled back to show a cream garlic-like segment with a dark seed.
-- quirk: a loose curl of scaly skin dangles from the peeled corner.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("salak")
local floor, sqrt, abs = math.floor, math.sqrt, math.abs
local m = A.HP.mask()
-- teardrop: tip at top-left (22,8), belly lower right
for y = 8, 57 do
  local w
  if y <= 40 then w = 17 * (1 - ((40 - y) / 32) ^ 1.7) ^ .6 else w = 17 * math.sqrt(math.max(0, 1 - ((y - 40) / 18) ^ 2)) end
  local cx = 22 + math.min(1, (y - 8) / 32) * 10
  for x = floor(cx - w + .5), floor(cx + w - .5) do m:set(x, y) end
end
local R = A.R("#a8683a")
A.lit(c, m, R, 7, { amb = .08, wrap = .25 })
-- scales: diamond lattice, edge darker, centre lighter
m:each(function(x, y)
  local u, v = (x + y) % 6, (x - y) % 6
  if u == 0 or v == 0 then c:px(x, y, R[2]) elseif u == 1 and v == 1 then c:px(x, y, R[5]) end
end)
-- re-light the shade side
m:each(function(x, y) if x + y * .6 > 52 and (x + y) % 6 ~= 0 and (x - y) % 6 ~= 0 then c:px(x, y, R[3]) end end)
-- stalk at tip
A.rod(c, 22, 9, 17, 3, 1.1, "#7a4a28", { amb = .1 })
-- peeled corner: cream flesh segment at lower right
local flesh = c:ellipse(34, 47, 7, 6)
flesh:clip(m)
A.lit(c, flesh, A.R("#f0e4c0"), 3, { amb = .1 })
c:px(32, 44, "#fff8e0") c:px(33, 44, "#fff8e0")
A.sph(c, 36, 49, 2.2, "#5a3020", { spec = "#c9a070" })
-- curl of skin
A.bezLine(c, { { 27, 41 }, { 23, 45 }, { 26, 52 }, { 32, 55 } }, "#7a4a28", 24)
A.bezLine(c, { { 28, 41 }, { 24, 45 }, { 27, 52 }, { 33, 55 } }, "#c08a52", 24)
c:px(22, 6, "#5fa04a")
A.fin()
