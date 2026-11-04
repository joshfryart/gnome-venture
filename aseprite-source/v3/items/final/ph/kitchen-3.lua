-- kitchen-3 (final, Opus single pass). Third kitchen tier: a two-storey kitchen house. Stone ground floor with a
-- wide arched plank door and a hanging lantern, oak jetty beam, plank upper storey with two lit windows, round
-- gable window, red clay-tile roof and a tall brick chimney with twin pots.
-- Material: coursed stone with mortar, beam end-grain, plank grain, tile courses + glaze glints, bricks, glass rim
-- + pale core, lantern glow. AO under eaves, under the jetty and at the chimney foot.
-- quirk: the weathervane on the gable tip is a fork.
local NAME = "kitchen-3"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_2.lua")
local c = A.new(NAME)
local T, M, ST = A.TRIM, A.METAL, A.STONE

local x0, x1, yt, yb, d = 20, 38, 31, 55, 10
local H = A.house(c, { x0 = x0, x1 = x1, yt = yt, yb = yb, ya = 20, d = d, ov = 2, found = 12 })
-- jetty beam between storeys (front + side), with end-grain discs
local yj = yb - 12
for x = x0 - 1, x1 do c:px(x, yj, T[x == x0 - 1 and 6 or 5]) c:px(x, yj + 1, T[3]) end
for i = 0, d - 1 do local x = x1 + 1 + i local s = math.floor((i + 1) / 2)
  c:px(x, yj - s, T[3]) c:px(x, yj + 1 - s, T[1]) end
for x = x0, x1 do c:px(x, yj + 2, ST[2]) end                         -- AO under the jetty
for _, bx in ipairs{ x0 + 4, x0 + 9, x0 + 14 } do c:px(bx, yj, T[6]) c:px(bx, yj + 1, T[2]) end
-- upper windows
A.window(c, x0 + 2, 34, 5, 6)
A.window(c, x1 - 6, 34, 5, 6)
-- round gable window
local gx, gy = 29, 27
for _, p in ipairs{ {gx - 1, gy - 2, 5}, {gx, gy - 2, 5}, {gx + 1, gy - 2, 4}, {gx - 2, gy - 1, 5}, {gx + 2, gy - 1, 3},
                    {gx - 2, gy, 4}, {gx + 2, gy, 3}, {gx - 1, gy + 1, 3}, {gx, gy + 1, 3}, {gx + 1, gy + 1, 2} } do
  c:px(p[1], p[2], T[p[3]]) end
c:px(gx - 1, gy - 1, A.GLASS[6]) c:px(gx, gy - 1, A.GLASS[5]) c:px(gx + 1, gy - 1, A.GLASS[4])
c:px(gx - 1, gy, A.GLASS[4]) c:px(gx, gy, A.GLASS[3]) c:px(gx + 1, gy, A.GLASS[2])
-- ground floor: wide arched door, small window, lantern
A.door(c, 25, 31, 46, 54)
for x = 24, 32 do c:px(x, 55, ST[x < 26 and 6 or (x > 30 and 3 or 5)]) end
A.window(c, 33, 47, 4, 5, { mull = false })
-- lantern on a bracket left of the door
c:px(21, 45, M[4]) c:px(22, 45, M[3]) c:px(23, 45, M[2]) c:px(22, 46, M[3])
for _, p in ipairs{ {21, 47, M[4]}, {22, 47, M[3]}, {23, 47, M[2]}, {21, 48, A.GLASS[6]}, {22, 48, A.GLASS[5]}, {23, 48, A.GLASS[3]},
                    {21, 49, A.GLASS[5]}, {22, 49, A.GLASS[4]}, {23, 49, A.GLASS[2]}, {21, 50, M[3]}, {22, 50, M[2]}, {23, 50, M[1]} } do
  c:px(p[1], p[2], p[3]) end

-- tall brick chimney with twin pots
local cb = H.roofTop(42) + 2
A.chimney(c, 40, 43, 14, cb)
for _, px in ipairs{ 40, 43 } do
  c:px(px, 11, A.BRICK[5]) c:px(px + 1, 11, A.BRICK[3])
  c:px(px, 10, A.BRICK[6]) c:px(px + 1, 10, A.BRICK[4])
end
A.puff(c, 47, 8, 1.4)

-- quirk: fork weathervane on the gable tip
local ax = 29
for y = 13, 18 do c:px(ax, y, M[y < 15 and 5 or 4]) end
c:px(ax - 1, 18, M[3]) c:px(ax + 1, 18, M[2])
-- fork lying sideways: three tines pointing left, bridge, handle to the right
for x = ax - 1, ax + 4 do c:px(x, 13, M[x < ax + 2 and 5 or 4]) end
for y = 11, 15 do c:px(ax - 2, y, M[y < 13 and 5 or 3]) end
for _, ty in ipairs{ 11, 13, 15 } do for x = ax - 6, ax - 3 do c:px(x, ty, M[ty == 11 and 6 or (ty == 13 and 5 or 3)]) end end
c:px(ax - 6, 11, A.CREAM)

A.save2(c, NAME)
