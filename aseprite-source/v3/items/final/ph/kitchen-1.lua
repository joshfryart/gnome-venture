-- kitchen-1 (final, Opus single pass). First kitchen tier: a narrow plank hut seen 3/4 (lit gable front, shaded
-- side wall), steep red clay-tile roof with ridge cap, stone footing, round-top plank door with iron straps, one
-- small lit window, a round gable vent and a thin tin stovepipe with a cone hat puffing smoke.
-- Material: plank grain + staggered joints, tile courses with lip shadow and glaze glints, bevelled barge boards,
-- cylinder-lit tin pipe with bands, glass rim + pale core. AO under eaves, under the sill and where the pipe meets
-- the roof. quirk: a soup ladle hangs from the left eave like a wind chime.
local NAME = "kitchen-1"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_2.lua")
local c = A.new(NAME)
local M, T = A.METAL, A.TRIM

local H = A.house(c, { x0 = 19, x1 = 35, yt = 37, yb = 55, ya = 24, d = 10, ov = 2, found = 3 })
-- door + stone step
A.door(c, 21, 26, 42, 54)
for x = 20, 27 do c:px(x, 55, A.STONE[x < 22 and 5 or (x > 25 and 3 or 4)]) end
-- window
A.window(c, 28, 40, 7, 7)
for x = 27, 35 do c:px(x, 48, A.WALL[2]) end         -- shadow under the sill
-- round gable vent
for _, p in ipairs{ {27, 29, 4}, {26, 30, 5}, {28, 30, 3}, {27, 31, 3} } do c:px(p[1], p[2], T[p[3]]) end
c:px(27, 30, T[1])

-- tin stovepipe standing on the roof slope
local px0, px1 = 37, 39
local base = H.roofTop(38) + 2
for y = 14, base do
  for x = px0, px1 do
    local i = (x == px0) and 5 or (x == px1 and 2 or 4)
    if (y - 14) % 5 == 4 then i = i == 2 and 1 or i - 1 end          -- seam bands
    if y == base or (y == base - 1 and x == px1) then i = 1 end       -- AO at the roof
    c:px(x, y, M[A.cl(i)])
  end
end
c:px(px0, 16, M[6]) c:px(px0, 17, M[6])                               -- specular streak
-- flashing collar
for x = px0 - 1, px1 + 1 do c:px(x, base - 1, M[x <= px0 and 4 or 3]) end
-- cone hat on three legs
for x = 35, 41 do c:px(x, 12, M[x < 37 and 5 or (x > 39 and 2 or 4)]) end
for x = 36, 40 do c:px(x, 11, M[x < 38 and 6 or (x > 39 and 3 or 5)]) end
for x = 37, 39 do c:px(x, 10, M[x == 37 and 6 or 4]) end
c:px(38, 9, M[5])
c:px(37, 13, M[1]) c:px(39, 13, M[1])
-- smoke curling up-right
A.puff(c, 42.5, 9, 1.6)
A.puff(c, 45.5, 7, 1.1)
-- tile shadow under the pipe on the down-slope side
for y = base + 1, base + 2 do for x = px0, px1 + 1 do if H.roof:has(x, y) then c:px(x, y, A.ROOF[2]) end end end

-- quirk: ladle on a hook under the left eave
c:px(17, 39, M[3]) c:px(17, 40, M[4]) c:px(17, 41, M[4]) c:px(17, 42, M[3])
for _, p in ipairs{ {16, 43, 5}, {17, 43, 4}, {18, 43, 3}, {16, 44, 4}, {17, 44, 3}, {18, 44, 2}, {17, 45, 2} } do
  c:px(p[1], p[2], M[p[3]]) end
c:px(16, 43, A.CREAM)

A.save2(c, NAME)
