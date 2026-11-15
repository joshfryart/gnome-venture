-- sting (tag: Poison). A wasp's curved stinger on a striped gold-and-brown abdomen, a drop of green venom swelling at
-- the tip and one drip falling. Quirk: where the drip lands it has eaten a small bubbling pit in the ground.
local S = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_shade.lua")
local HP, R = S.HP, S.R
local c = S.new("sting")
-- abdomen
local ab = c:ellipse(18, 47, 16, 9)
S.fill(c, ab, R.gold, { lx = 0.3, ly = 1 })
for _, x in ipairs{ 9, 16, 23 } do
  local band = c:rect(x, 0, x + 3, 63):clip(ab)
  S.fill(c, band, R.amber, { lx = 0.3, ly = 1, bias = function() return -2 end })
end
c:fillMask(c:rect(8, 41, 12, 41), R.gold[6]) -- glossy
-- stinger (curved cone)
local sp = c:poly{ { 30, 52 }, { 31, 42 }, { 34, 33 }, { 40, 24 }, { 47, 17 }, { 56, 12 }, { 50, 20 }, { 45, 29 }, { 42, 38 }, { 41, 48 } }
S.fill(c, sp, R.amber, { lx = 1, ly = 0.6 })
c:fillMask(c:line({ { 33, 44 }, { 36, 34 }, { 41, 26 }, { 49, 17 } }, 1), R.amber[6])
-- venom bulb at tip
local drop = c:poly{ { 55, 16 }, { 52, 21 }, { 51, 25 }, { 53, 28 }, { 57, 28 }, { 59, 25 }, { 58, 21 } }
S.fill(c, drop, R.moss, { bias = function() return 0 end })
c:fillMask(c:rect(54, 21, 55, 23), R.moss[6])
-- falling drip
c:fillMask(c:ellipse(48, 41, 2, 3), R.moss[4]) c:px(47, 40, R.moss[6]) c:px(48, 44, R.moss[3])
-- ground pit w/ bubbles
local pit = c:ellipse(48, 55, 9, 3)
S.fill(c, pit, R.moss, { bias = function() return -2 end })
c:fillMask(c:ellipse(46, 55, 4, 1), R.moss[3])
c:fillMask(c:ellipse(53, 53, 2, 2), R.moss[5]) c:px(52, 52, R.moss[6])
c:fillMask(c:ellipse(43, 52, 1, 1), R.moss[5])
S.save(c, "sting")
