-- brace (tag: Hold). A timber shoring frame: a stone-wall edge at left, a post at right, a top beam and a diagonal
-- strut taking the load, iron brackets with gold bolts. Quirk: a moss tuft has sprouted in the strut's foot-wedge.
local S = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_shade.lua")
local HP, R = S.HP, S.R
local c = S.new("brace")
-- wall (left) with bricks
local wall = c:rect(5, 6, 16, 56)
S.fill(c, wall, R.stone, { lx = 0.3, ly = 1 })
for y = 6, 56, 7 do c:fillMask(c:rect(5, y, 16, y), R.stone[2]) end
for k = 0, 7 do local y = 6 + k * 7 c:fillMask(c:rect(k % 2 == 0 and 10 or 13, y, k % 2 == 0 and 10 or 13, y + 6), R.stone[2]) end
-- ground sill
local sill = c:rect(5, 52, 59, 58)
S.fill(c, sill, R.wood, { lx = 0.3, ly = 1 })
c:fillMask(c:rect(5, 52, 59, 52), R.wood[5])
-- post (right)
local post = c:rect(47, 8, 55, 52)
S.fill(c, post, R.wood, { lx = 1, ly = 0.1 })
for y = 16, 46, 8 do c:px(50, y, R.wood[2]) c:px(51, y + 1, R.wood[2]) end
-- top beam
local beam = c:rect(16, 8, 55, 15)
S.fill(c, beam, R.wood, { lx = 0.1, ly = 1 })
c:fillMask(c:rect(16, 8, 55, 8), R.wood[5])
for x = 22, 44, 9 do c:px(x, 11, R.wood[2]) c:px(x + 1, 12, R.wood[2]) end
-- diagonal strut from foot (19,51) to top (46,16)
local strut = c:line({ { 22, 49 }, { 43, 17 } }, 7)
S.fill(c, strut, R.wood, { lx = 1, ly = 0.8, bias = function() return 1 end })
-- wedge under strut foot + moss
local wedge = c:poly{ { 16, 51 }, { 30, 51 }, { 30, 53 }, { 16, 53 } }
S.fill(c, wedge, R.wood, { bias = function() return 1 end })
c:fillMask(c:ellipse(25, 50, 3, 1.5), R.moss[3]) c:px(24, 48, R.moss[5]) c:px(26, 48, R.moss[4]) c:px(25, 47, R.moss[6])
-- iron brackets + bolts
local function bracket(x0, y0, x1, y1) local m = c:rect(x0, y0, x1, y1) S.fill(c, m, R.steel, { lx = 1, ly = 1 }) c:px(x0 + 1, y0 + 1, R.gold[5]) c:px(x1 - 1, y1 - 1, R.gold[3]) end
bracket(44, 8, 49, 17) bracket(46, 44, 56, 50) bracket(17, 8, 22, 17)
c:sparkle(36, 33)
S.save(c, "brace")
