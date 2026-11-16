-- roll (tag: Evade). A pill-bug curled into a ball and tumbling left to right: curved overlapping plates in dusk
-- purple, a sleepy eye and two tiny feet peeking out, dust puffs and speed arcs behind. Quirk: a leaf is stuck on top.
local S = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_shade.lua")
local HP, R = S.HP, S.R
local c = S.new("roll")
-- dust puffs (left, bottom)
for _, p in ipairs{ { 7, 52, 5 }, { 15, 56, 4 } } do
  local m = c:ellipse(p[1], p[2], p[3], p[3] - 1)
  S.fill(c, m, R.stone, { lx = 0.5, ly = 1, bias = function() return 1 end })
end
-- speed arcs
c:fillMask(c:line({ { 4, 22 }, { 6, 18 }, { 11, 15 } }, 1), R.steel[5]) c:fillMask(c:line({ { 2, 34 }, { 6, 30 } }, 1), R.steel[4])
-- body ball
local cx, cy, r = 36, 33, 20
local ball = c:ellipse(cx, cy, r, r)
-- plates: rings around an off-centre pivot so the bands curve
local ox, oy = 12, 16
S.fill(c, ball, R.dusk, { lx = 1, ly = 1, bias = function(x, y)
  local d = math.sqrt((x - ox) ^ 2 + (y - oy) ^ 2)
  local band = math.floor(d / 7.5)
  local f = (d / 7.5) - band
  if f < 0.16 then return -2 end
  return (band % 2 == 0) and 0 or -1
end })
-- plate edge highlight (top of each ring)
ball:each(function(x, y)
  local d = math.sqrt((x - ox) ^ 2 + (y - oy) ^ 2)
  local f = d / 7.5 - math.floor(d / 7.5)
  if f >= 0.16 and f < 0.3 and ball:shrink(2):has(x, y) then c:px(x, y, R.dusk[5]) end
end)
-- specular
c:fillMask(c:rect(26, 22, 29, 22), R.dusk[6]) c:fillMask(c:rect(24, 24, 25, 25), R.dusk[6])
-- face peeking at right: sleepy eye
c:fillMask(c:ellipse(51, 38, 4, 5), R.dusk[2])
c:fillMask(c:rect(50, 35, 53, 38), R.cream or "#fff4d6") c:fillMask(c:rect(51, 36, 52, 38), "#2b1c26") c:px(51, 36, "#fff4d6")
c:fillMask(c:rect(49, 34, 54, 34), R.dusk[1])
-- feet
c:fillMask(c:ellipse(46, 53, 2, 1.5), R.dusk[4]) c:fillMask(c:ellipse(54, 51, 2, 1.5), R.dusk[3])
-- stuck leaf
local leaf = c:poly{ { 33, 13 }, { 39, 8 }, { 46, 9 }, { 44, 15 }, { 38, 17 } }
S.fill(c, leaf, R.moss, { lx = 1, ly = 1 })
c:fillMask(c:line({ { 35, 15 }, { 44, 10 } }, 1), R.moss[2])
S.save(c, "roll")
