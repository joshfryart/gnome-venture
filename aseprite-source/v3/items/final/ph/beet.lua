-- beet: a round crimson beet, long tap root, two red-veined leaves, and a ringed slice leaning beside. quirk: the slice shows concentric pink rings.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("beet")
local R = D.BEET
-- leaves behind
D.scrap(27, 27, 13, 5, 4.5, D.GRN, { veins = { 5, 9, 13, 17 } })
D.scrap(31, 27, 44, 4, 5, D.GRN, { veins = { 5, 9, 13, 17 } })
D.ln(27, 28, 22, 18, R[4]) D.ln(28, 28, 23, 19, R[3]) D.ln(31, 28, 36, 17, R[4]) D.ln(32, 28, 37, 18, R[3])
-- bulb
local bulb = D.ell(28, 38, 10, 9, 0)
local tm, tn = D.tube({ {29,45}, {31,50}, {28,55}, {33,59} }, function(t) return 2.6 * (1 - t) + .4 end)
bulb:add(tm)
D.lit(bulb, R, 5, { wrap = .3 })
-- growth rings (arcs)
for _, rr in ipairs{ 5, 8 } do for a = 0.2, 1.4, .1 do
  local x, y = floor(28 + cos(a + 1.6) * rr * 1.1 + .5), floor(38 + sin(a + 1.6) * rr * .95 + .5)
  if bulb:has(x, y) then c:px(x, y, R[2]) end
end end
-- tap root hair
c:px(31, 51, R[2]) c:px(32, 52, R[2]) c:px(26, 54, R[3])
-- crown
for x = 25, 31 do c:px(x, 29, R[2]) end c:px(26, 28, R[4]) c:px(29, 28, R[4])
-- slice
local base = D.ell(47, 52, 7, 4.6, -.25)
D.lit(base, R, 2)
local face = D.ell(47, 50, 6.5, 4.4, -.25)
face:each(function(x, y)
  local dx, dy = (x - 47) / 6.5, (y - 50) / 4.4
  local r = sqrt(dx*dx + dy*dy)
  local i = floor(r * 4.2) % 2
  c:px(x, y, r > .86 and R[3] or (i == 0 and "#f4a6c0" or R[4]))
end)
c:px(47, 50, "#ffd2e0") c:px(44, 48, "#ffd2e0")
D.fin()
