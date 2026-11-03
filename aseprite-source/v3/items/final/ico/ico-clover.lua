local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-clover")
local CR, INK, ell = D.CR, D.INK, D.ell
-- ico-clover: four heart-shaped leaves with pale centre veins, a bold curved stem down to the lower-left.
-- quirk: a round dewdrop sits on the upper-left leaf, a gold fleck inside it.
D.lit(c:line({ {32, 32}, {34, 44}, {28, 56}, {24, 60} }, 3), D.GREEN, 1.5)
local function heart(cx, cy, ang)
  local m = D.ell(cx - 3.6 * math.cos(ang) , cy - 3.6 * math.sin(ang), 6, 6.5, ang + 0.4)
  m:add(D.ell(cx + 3.6 * math.cos(ang), cy + 3.6 * math.sin(ang), 6, 6.5, ang - 0.4))
  return m
end
local leaves = { {21, 21, 0.7}, {43, 21, -0.7}, {21, 43, -0.7}, {43, 43, 0.7} }
for _, l in ipairs(leaves) do
  local m = D.ell(l[1], l[2], 9, 9, 0)
  D.lit(m, D.GREEN, 7, { amb = 0.1 })
  D.poly(c, { {l[1], l[2]}, {32, 32} }, D.GREEN[6])
  D.px(l[1] + (l[1] < 32 and -2 or 2), l[2] + (l[2] < 32 and -2 or 2), D.GREEN[6])
  D.px(l[1] + (l[1] < 32 and -3 or 3), l[2] + (l[2] < 32 and -3 or 3), D.GREEN[6])
end
D.fill(c:poly{ {32, 32}, {32, 28}, {35, 32} }, D.GREEN[2])
D.lit(ell(32, 32, 2.5, 2.5, 0), D.GREEN, 2)
D.fill(c:ellipse(17, 17, 3, 3), "#b6f0e0"); D.px(16, 16, D.CR) D.px(18, 18, "#f5b82e") D.fill(c:rect(18, 19, 19, 19), "#5fc4c8")
D.fin()
