-- bash / Shield Bash (tag: Bash). A heater shield thrust forward with a gold impact burst behind it: blue field,
-- steel cross-strap and boss, rivets. Quirk: a fresh dent bulges in the upper corner and a tooth flies off.
local S = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_shade.lua")
local HP, R = S.HP, S.R
local c = S.new("bash")
-- starburst behind
local pts = {}
for i = 0, 15 do local a = i * math.pi / 8 - math.pi / 2 local r = (i % 2 == 0) and 31 or 21 pts[#pts + 1] = { 32 + r * math.cos(a), 33 + r * math.sin(a) } end
local burst = c:poly(pts)
S.fill(c, burst, R.gold, { bias = function() return 0 end })
-- shield
local shield = c:poly{ { 16, 17 }, { 48, 17 }, { 49, 33 }, { 44, 46 }, { 32, 57 }, { 20, 46 }, { 15, 33 } }
S.fill(c, shield, R.sea, { bias = function() return 0 end })
local inner = shield:shrink(3)
S.fill(c, shield:copy():cut(inner), R.steel)
-- cross strap
local cross = c:rect(30, 20, 34, 54):add(c:rect(18, 29, 46, 33)):clip(inner)
S.fill(c, cross, R.steel, { lx = 1, ly = 0.4 })
-- boss
local boss = c:ellipse(32, 31, 6, 6)
S.fill(c, boss, R.gold)
c:fillMask(c:ellipse(32, 31, 2, 2), R.gold[2]) c:px(29, 28, R.gold[6]) c:px(30, 28, R.gold[6])
-- rivets
for _, p in ipairs{ { 20, 21 }, { 44, 21 }, { 20, 36 }, { 44, 36 } } do c:px(p[1], p[2], R.steel[6]) c:px(p[1] + 1, p[2] + 1, R.steel[2]) end
-- dent (upper right)
c:fillMask(c:ellipse(40, 24, 3, 3), R.sea[2]) c:fillMask(c:ellipse(39, 23, 2, 2), R.sea[1]) c:px(42, 25, R.sea[5])
c:fillMask(c:line({ { 41, 22 }, { 45, 19 } }, 1), R.sea[1])
-- flying tooth
local tooth = c:poly{ { 56, 8 }, { 60, 8 }, { 61, 12 }, { 59, 15 }, { 58, 12 }, { 57, 15 }, { 55, 12 } }
S.fill(c, tooth, R.stone, { bias = function() return 2 end })
S.save(c, "bash")
