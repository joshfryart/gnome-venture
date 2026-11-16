-- smash (tag: Heavy). A stone-headed maul slammed into the ground: wooden haft, iron-banded stone head, a cracked
-- slab splitting from the impact and chips in the air. Quirk: a bewildered worm is poking out of the crack.
local S = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_shade.lua")
local HP, R = S.HP, S.R
local c = S.new("smash")
local floor, cos, sin = math.floor, math.cos, math.sin
-- ground slab with cracks
local slab = c:poly{ { 4, 48 }, { 60, 48 }, { 62, 56 }, { 2, 56 } }
S.fill(c, slab, R.stone, { lx = 0.3, ly = 1, bias = function() return -1 end })
c:fillMask(c:rect(4, 48, 60, 48), R.stone[5])
local crack = { { 24, 52 }, { 18, 50 }, { 12, 55 }, { 8, 52 }, { 24, 52 }, { 30, 55 }, { 38, 51 }, { 46, 55 }, { 53, 50 } }
c:fillMask(c:line(crack, 1), R.stone[1])
-- worm
c:fillMask(c:line({ { 52, 50 }, { 53, 45 }, { 51, 42 } }, 2), R.petal and R.ember[5] or R.ember[5]) c:px(51, 41, R.ember[6]) c:px(51, 44, R.ember[3])
-- haft (rotated: from (54,6) down-left to (26,38))
local haft = c:line({ { 54, 7 }, { 27, 38 } }, 5)
S.fill(c, haft, R.wood, { lx = 1, ly = 1 })
haft:each(function(x, y) if (x + 2 * y) % 9 == 0 then c:px(x, y, R.wood[2]) end end)
-- head: oriented block, centre (21,40), along (0.8,0.6) half 14, thickness half 7 along (-0.6,0.8)
local function P(a, b) return { floor(21 + 0.8 * a - 0.6 * b + .5), floor(40 + 0.6 * a + 0.8 * b + .5) } end
local head = c:poly{ P(-14, -7), P(14, -7), P(14, 7), P(-14, 7) }
S.fill(c, head, R.stone, { lx = 1, ly = 0.2 })
-- iron bands
for _, a in ipairs{ -11, 11 } do
  local band = c:poly{ P(a - 2, -7), P(a + 2, -7), P(a + 2, 7), P(a - 2, 7) }
  S.fill(c, band, R.steel, { lx = 1, ly = 0.5 })
end
-- chips and puff
for _, p in ipairs{ { 8, 38 }, { 12, 31 }, { 5, 29 }, { 50, 33 }, { 57, 40 } } do c:fillMask(c:rect(p[1], p[2], p[1] + 2, p[2] + 2), R.stone[4]) c:px(p[1], p[2], R.stone[6]) c:px(p[1] + 2, p[2] + 2, R.stone[2]) end
c:fillMask(c:line({ { 4, 44 }, { 9, 44 } }, 1), R.steel[5]) c:fillMask(c:line({ { 55, 45 }, { 60, 45 } }, 1), R.steel[5])
S.save(c, "smash")
