-- lm-lair (aC21_0, Opus single pass). A tall, hunched violet crag with a gaping round mouth: four slim red crystals
-- (two-face facets, bright ridge, dark roots where they sink into the rock), knobbly rock with seams, a lit inner
-- rim on the right, ivory fangs hanging from the top and rising from the floor, and two slit-pupil amber eyes
-- glowing in the black. quirk: a neat woven welcome mat lies at the threshold.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_0.lua")
local R, K = A.R, A.K
local c = A.new("lm-lair")
local LR, EM, GD, BN, ST = R.lair, R.ember, R.gold, R.bone, R.stone

-- crystals first (rock covers their roots)
local cry = A.HP.mask()
for _, q in ipairs{ { { 20, 28 }, { 15, 13 }, 2.5 }, { { 27, 24 }, { 25, 7 }, 3 }, { { 36, 23 }, { 39, 9 }, 3 }, { { 44, 28 }, { 49, 17 }, 2.5 } } do
  cry:add(A.crystal(c, q[1], q[2], q[3], EM))
end
-- the crag
local mound = c:ellipse(32, 41, 19, 20):add(c:ellipse(21, 33, 6, 6)):add(c:ellipse(44, 35, 6, 5))
mound:clip(c:rect(0, 0, 63, 52))
A.lit(c, mound, LR, 6, { amb = 0.1 })
A.ao(c, cry, mound, EM[1])
-- rock seams with lit lips
for _, s in ipairs{ { { 15, 40 }, { 18, 37 }, { 19, 33 } }, { { 47, 44 }, { 46, 40 }, { 49, 37 } }, { { 28, 25 }, { 33, 24 }, { 36, 26 } } } do
  A.polyline(c, s, LR[2], mound)
  local sh = {} for i, p in ipairs(s) do sh[i] = { p[1] + 1, p[2] + 1 } end
  A.polyline(c, sh, LR[5], mound)
end
c:px(17, 46, LR[2]) c:px(18, 46, LR[2]) c:px(45, 48, LR[2])
-- mouth
local mouth = c:ellipse(32, 46, 10, 12):clip(c:rect(0, 0, 63, 52))
mouth:each(function(x, y) c:px(x, y, y < 38 and "#120b1c" or A.VOID) end)
-- inner rim: right side catches light, left side in shade
mound:copy():cut(mouth):each(function(x, y)
  if mouth:has(x - 1, y) or mouth:has(x + 1, y) or mouth:has(x, y - 1) then
    c:px(x, y, x > 32 and LR[5] or LR[2])
  end
end)
-- eyes (amber, slit pupils, dark-red glow ring)
for _, e in ipairs{ { 27, 42 }, { 35, 42 } } do
  local x, y = e[1], e[2]
  for _, p in ipairs{ { -1, 0 }, { 4, 0 }, { 0, -1 }, { 3, -1 }, { 0, 2 }, { 3, 2 }, { -1, 1 }, { 4, 1 } } do c:px(x + p[1], y + p[2], EM[1]) end
  c:px(x + 1, y - 1, EM[2]) c:px(x + 2, y - 1, EM[2])
  c:px(x, y, GD[5]) c:px(x + 1, y, GD[6]) c:px(x + 2, y, A.VOID) c:px(x + 3, y, GD[4])
  c:px(x, y + 1, GD[3]) c:px(x + 1, y + 1, GD[4]) c:px(x + 2, y + 1, A.VOID) c:px(x + 3, y + 1, GD[3])
  c:px(x + 1, y + 2, EM[3]) c:px(x + 2, y + 2, EM[2])
end
-- fangs
local function fang(x, y, h, down)
  for i = 0, h - 1 do
    local yy = down and (y + i) or (y - i)
    local w = (i < h - 2) and 1 or 0
    if w == 1 then c:px(x - 1, yy, BN[5]) c:px(x, yy, BN[4]) c:px(x + 1, yy, BN[2])
    else c:px(x, yy, i == h - 1 and BN[3] or BN[4]) end
  end
  if down then c:px(x - 1, y, BN[6]) end
end
fang(26, 35, 5, true) fang(31, 34, 6, true) fang(37, 35, 4, true)
fang(25, 52, 5, false) fang(34, 52, 4, false) fang(39, 52, 5, false)
-- rocky floor strip
local floor_ = c:rect(11, 53, 53, 55):cut(c:rect(11, 55, 12, 55)):cut(c:rect(52, 55, 53, 55))
A.lit(c, floor_, ST, 1.4)
for x = 13, 51 do if mound:has(x, 52) then c:px(x, 53, ST[1]) end end
-- quirk: woven welcome mat
local mat = c:rect(24, 54, 40, 56)
mat:each(function(x, y)
  local w = (x + y) % 3
  local col = w == 0 and GD[3] or (w == 1 and EM[4] or EM[3])
  if y == 54 then col = w == 0 and GD[5] or EM[5] end
  if y == 56 then col = EM[2] end
  c:px(x, y, col)
end)
for _, x in ipairs{ 23, 41 } do c:px(x, 54, GD[4]) c:px(x, 56, GD[3]) end -- fringe
A.fin()
