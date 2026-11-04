-- lm-haven (aC21_0, Opus single pass). A tall, slim A-frame canvas tent seen three-quarter: lit front face with
-- radiating fold creases and a gold-stitched corner seam, a shaded side panel, the door flap rolled back (pale
-- lining, twisted tie-rope) onto a warm lantern-lit inside; a thin pole with a brass knob; a small campfire of
-- crossed logs (pale end grain) in a pebble ring; grass mound with contact shadow. quirk: a striped sock flies
-- from the pole instead of a pennant.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_0.lua")
local R, K = A.R, A.K
local c = A.new("lm-haven")
local CV, WD, GD, LF, BN, ST, EM, SE = R.canvas, R.wood, R.gold, R.leaf, R.bone, R.stone, R.ember, R.sea

-- grass mound
local grass = c:ellipse(33, 51.5, 24, 2.5)
A.lit(c, grass, LF, 1.5)
-- side panel (shade side)
local side = c:poly{ { 24, 13 }, { 31, 11 }, { 46, 49 }, { 38, 52 } }
local bias = {}
side:each(function(x, y) bias[K(x, y)] = -2 end)
A.lit(c, side, CV, 3, { bias = bias })
for _, f in ipairs{ { 28, 14, 41, 50 }, { 30, 14, 44, 49 } } do A.ln(c, f[1], f[2], f[3], f[4], CV[2], side) end
-- front face
local front = c:poly{ { 24, 12 }, { 9.5, 52 }, { 38.5, 52 } }
A.lit(c, front, CV, 4)
for _, f in ipairs{ { 13, 51 }, { 34, 51 }, { 17, 51 } } do
  A.ln(c, 24, 15, f[1], f[2], CV[3], front)
  A.ln(c, 24, 15, f[1] + 1, f[2], CV[5], front)
end
-- seam between front and side, gold stitch just inside the front
A.ln(c, 24, 12, 38, 51, CV[1])
c:stitch{ { 25, 17 }, { 36, 48 } }
-- doorway: warm inside
local door = c:poly{ { 24, 24 }, { 19.5, 52 }, { 31.5, 52 } }
door:each(function(x, y)
  local col = y < 33 and CV[1] or (y < 40 and "#7a2a22" or (y < 46 and GD[2] or GD[3]))
  c:px(x, y, col)
end)
for y = 44, 51 do c:px(26, y, GD[5]) end c:px(26, 43, GD[6]) c:px(27, 45, GD[4]) -- lantern glow inside
c:px(26, 42, A.CREAM)
-- rolled flap with pale lining
local flap = c:poly{ { 24, 23 }, { 16.5, 52 }, { 20.5, 52 } }
A.lit(c, flap, BN, 1.2)
A.ln(c, 23, 26, 18, 50, BN[2], flap)
-- twisted tie rope
for i, p in ipairs{ { 17, 39 }, { 18, 39 }, { 19, 39 }, { 20, 39 }, { 21, 39 } } do c:px(p[1], p[2], i % 2 == 0 and GD[5] or GD[3]) end
c:px(21, 40, GD[2])
-- contact shadow at the base
for x = 10, 46 do if not door:has(x, 52) then c:px(x, 53, LF[1]) end end
-- pole + knob
for y = 5, 12 do c:px(24, y, WD[5]) c:px(25, y, WD[3]) end
c:px(24, 4, GD[6]) c:px(25, 4, GD[4]) c:px(24, 3, GD[5]) c:px(25, 3, GD[3])
-- quirk: striped sock as flag (leg out to the right, foot hanging down)
local sock = c:rect(26, 5, 31, 7):add(c:rect(30, 8, 33, 10))
sock:each(function(x, y)
  local band = ((x + (y > 7 and 0 or 0)) // 2) % 2 == 0
  local col = band and BN[5] or SE[3]
  if y == 7 or y == 10 or x == 33 then col = band and BN[3] or SE[2] end
  if y == 5 and band then col = BN[6] end
  c:px(x, y, col)
end)
c:px(26, 5, EM[4]) c:px(26, 6, EM[3]) c:px(26, 7, EM[2]) -- red cuff tied to the pole
-- campfire
for _, p in ipairs{ { 45, 50 }, { 49, 51 }, { 53, 51 }, { 56, 49 } } do
  local m = c:ellipse(p[1], p[2], 1.5, 1)
  A.lit(c, m, ST, 1)
end
local log1 = c:line({ { 46, 47 }, { 55, 50 } }, 2)
local log2 = c:line({ { 46, 50 }, { 55, 46 } }, 2)
A.lit(c, log1, WD, 1) A.lit(c, log2, WD, 1)
c:px(55, 46, WD[6]) c:px(56, 46, WD[5]) c:px(56, 47, WD[4]) -- end grain
c:px(55, 50, WD[6]) c:px(56, 50, WD[5]) c:px(56, 51, WD[4])
local fl = c:poly{ { 51, 33 }, { 54, 39 }, { 55, 44 }, { 53, 48 }, { 49, 48 }, { 47, 44 }, { 48, 40 }, { 50, 41 } }
c:fillMask(fl, EM[4])
fl:each(function(x, y) if not fl:has(x + 1, y) or not fl:has(x, y + 1) then c:px(x, y, EM[3]) end end)
local fi = c:poly{ { 51, 38 }, { 53, 43 }, { 52, 48 }, { 50, 48 }, { 49, 44 } }
c:fillMask(fi, GD[4])
fi:each(function(x, y) if not fi:has(x - 1, y) then c:px(x, y, GD[5]) end end)
c:px(51, 45, GD[6]) c:px(51, 46, A.CREAM) c:px(51, 47, GD[6])
A.ao(c, side, fl:copy():add(log1):add(log2), CV[1])
A.fin()
