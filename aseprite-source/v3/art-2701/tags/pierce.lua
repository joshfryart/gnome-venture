-- pierce (tag: Pierce). A round plank shield skewered by a spear: the shaft goes in at a splintered hole on the
-- front, the steel leaf head pokes out past the far rim. Quirk: one plank has popped loose and hangs off a nail.
local S = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_shade.lua")
local HP, R = S.HP, S.R
local c = S.new("pierce")
local cx, cy = 29, 36
local sh = c:ellipse(cx, cy, 20, 20)
-- planks: vertical, alternate tone offset
S.fill(c, sh, R.wood, { bias = function(x, y) return ((math.floor((x - 9) / 8)) % 2 == 0) and 0 or -1 end })
for _, x in ipairs{ 17, 25, 33, 41 } do for y = 16, 56 do if sh:has(x, y) then c:px(x, y, R.wood[1]) end end end
-- iron rim
local rim = sh:copy():cut(sh:shrink(3))
S.fill(c, rim, R.steel)
for a = 0, 11 do local t = a * math.pi / 6 + 0.3 c:px(math.floor(cx + 18.2 * math.cos(t) + .5), math.floor(cy + 18.2 * math.sin(t) + .5), R.steel[6]) end
-- loose plank flap at lower-left
local flap = c:poly{ { 10, 44 }, { 15, 40 }, { 18, 55 }, { 13, 55 } }
S.fill(c, flap, R.wood, { bias = function() return 1 end })
c:px(15, 41, R.steel[5])
-- hole + splinters
c:fillMask(c:ellipse(30, 35, 4, 3.5), R.wood[1])
local spl = { { 24, 29 }, { 27, 26 }, { 36, 28 }, { 38, 33 }, { 25, 41 }, { 34, 43 } }
for _, p in ipairs(spl) do c:fillMask(c:line({ { 30, 35 }, { p[1], p[2] } }, 1), R.wood[5]) end
c:fillMask(c:ellipse(30, 35, 2, 1.5), R.wood[1])
-- shaft entering the hole from lower left (in front)
local shaft = c:line({ { 5, 57 }, { 30, 35 } }, 3)
S.fill(c, shaft, R.wood, { lx = 1, ly = -1, bias = function() return 1 end })
-- shaft tip peeking through then head beyond the far rim
local head = c:poly{ { 38, 29 }, { 43, 21 }, { 52, 9 }, { 56, 5 }, { 55, 14 }, { 47, 28 }, { 43, 31 } }
S.fill(c, head, R.steel, { lx = 1, ly = 0.4 })
c:fillMask(c:line({ { 41, 27 }, { 54, 8 } }, 1), R.steel[2])
c:fillMask(c:line({ { 42, 25 }, { 52, 11 } }, 1), R.steel[6])
-- socket ring
c:fillMask(c:line({ { 37, 31 }, { 41, 33 } }, 2), R.gold[3]) c:px(37, 30, R.gold[5])
-- sparkle on the tip
c:sparkle(58, 3 + 3)
S.save(c, "pierce")
