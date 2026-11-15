-- jab (tag: Quick). A mitten-quick fist shot out to the right from a blue sleeve: back of the hand, four curled
-- knuckle bumps, a thumb folded across the bottom, three speed streaks behind. Quirk: a bandage on the top knuckle.
local S = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_shade.lua")
local HP, R = S.HP, S.R
local c = S.new("jab")
-- speed streaks (stone/sky, hard)
local st = { { 3, 24, 12 }, { 5, 33, 16 }, { 3, 42, 11 } }
for _, s in ipairs(st) do c:fillMask(c:rect(s[1], s[2], s[1] + s[3], s[2] + 1), R.steel[5]) c:fillMask(c:rect(s[1] + 3, s[2] + 2, s[1] + s[3] - 2, s[2] + 2), R.steel[3]) end
-- sleeve cuff
local sl = c:rrect(14, 19, 24, 49, 2)
S.fill(c, sl, R.sea, { lx = 1, ly = 0.3 })
c:fillMask(c:rect(23, 19, 24, 49), R.sea[2])
c:fillMask(c:rect(14, 25, 24, 25), R.sea[5]) -- cuff fold
-- hand back
local hand = c:rrect(24, 21, 44, 47, 5)
S.fill(c, hand, R.skin, { lx = 0.6, ly = 1 })
-- knuckle bumps (4 fingers) and thumb
local fing = HP.mask()
for i = 0, 3 do fing:add(c:ellipse(46, 26 + i * 6.2, 6, 3.6)) end
S.fill(c, fing, R.skin, { lx = 0.5, ly = 1, bias = function(x, y) return 0 end })
local thumb = c:ellipse(37, 46, 9, 3.6)
S.fill(c, thumb, R.skin, { lx = 0.4, ly = 1, bias = function() return -1 end })
-- finger gaps and nail-side creases
for i = 0, 2 do local y = 29 + i * 6 c:fillMask(c:rect(43, y, 51, y), R.skin[2]) c:px(52, y, R.skin[3]) end
c:fillMask(c:rect(30, 44, 44, 44), R.skin[2]) -- thumb crease
c:fillMask(c:rect(28, 28, 28, 36), R.skin[3]) -- hand tendon
-- bandage on top knuckle
c:fillMask(c:rect(44, 21, 47, 26), R.gold[5]) c:fillMask(c:rect(44, 21, 47, 21), R.gold[4]) c:px(45, 23, R.gold[2]) c:px(46, 24, R.gold[2])
-- pop
c:fillMask(c:rect(46, 33, 48, 33), R.skin[6]) c:fillMask(c:rect(27, 25, 29, 25), R.skin[6])
-- impact sparkle
c:sparkle(58, 33)
S.save(c, "jab")
