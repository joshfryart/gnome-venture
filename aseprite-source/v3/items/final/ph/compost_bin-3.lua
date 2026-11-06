-- compost_bin-3 (tier 3, Opus single pass). The finished rig: a closed bin of vertical boards between square posts,
-- a riveted iron band, a plank lid swung back and held on a steel stay, the heap rising out of the open top, and a
-- framed harvest hatch at the foot with strap hinges and a brass pull.
-- Material: bevelled vertical boards with grain and knots, shaded lid underside, iron band bevel + rivets + glint,
-- recessed hatch with AO frame, brass specular; AO where the heap meets the rim and the boards meet the posts.
-- quirk: a tiny toadstool has sprouted from the side of the left post.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_2.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new2("compost_bin-3")
local W, S, B = A.WOOD, A.STEEL, A.BRASS
c:groundShadow(32, 57, 23, 2)
-- lid swung back (underside facing us, in shade)
local lid = c:poly{ {14, 27}, {49, 27}, {46, 11}, {17, 11} }
local lb = {}
lid:each(function(x, y) lb[K(x, y)] = -1 end)
local lidx = A.lit(c, lid, W, { R = 2, bias = lb })
lid:each(function(x, y)  -- board seams on the lid, converging slightly
  local u = (x - 32) / (1 + (27 - y) * 0.0)
  if y > 11 and (x == 23 or x == 31 or x == 39) then c:px(x, y, W[1]) end
  if y == 11 or y == 12 then c:px(x, y, y == 11 and W[6] or W[5]) end
end)
for y = 16, 26 do if X.hash(27, y, 1) > 0.4 then c:px(27, y, W[2]) end if X.hash(35, y, 2) > 0.5 then c:px(36, y, W[2]) end end
-- steel stay holding the lid
for i = 0, 12 do local x, y = 46 - i * 0.25, 28 - i do c:px(math.floor(x + .5), y, i % 3 == 0 and S[5] or S[4]) end end
-- heap
local hp = A.heap(c, 32, 29, 16, 8, { {24,25,"egg"}, {33,23,"leaf"}, {38,25,"peel"}, {28,27,"twig"}, {21,27,"crumb"}, {43,27,"crumb"} }, { seed = 13 })
-- vertical boards
local xs = { 15, 21, 27, 33, 39, 44 }
for i, x0 in ipairs(xs) do
  local x1 = (xs[i + 1] or 49) - 1
  A.plank(c, x0, 29, x1, 55, W, { seed = i * 3 + 1, R = 1.4 })
end
for x = 15, 48 do if hp:has(x, 28) then c:px(x, 29, A.SOIL[1]) end end
-- iron band
local band = c:rect(14, 33, 49, 36)
A.lit(c, band, S, { R = 1.5 })
for x = 14, 49 do c:px(x, 37, W[1]) end
for _, x in ipairs{ 18, 25, 38, 45 } do c:px(x, 34, S[1]) c:px(x - 1, 34, S[6]) end
c:px(20, 33, A.CREAM)
-- harvest hatch: recessed frame, two boards, strap hinges, brass pull
for x = 23, 40 do c:px(x, 41, A.SOIL[1]) c:px(x, 54, W[5]) end
for y = 41, 54 do c:px(23, y, A.SOIL[1]) c:px(40, y, W[5]) end
local hb = {}
c:rect(24, 42, 39, 53):each(function(x, y) if x == 24 or y == 42 then hb[K(x, y)] = -1 end end)
A.plank(c, 24, 42, 31, 53, A.WOODG, { seed = 21, R = 1.3, bias = hb })
A.plank(c, 32, 42, 39, 53, A.WOODG, { seed = 22, R = 1.3, bias = hb })
for _, y in ipairs{ 44, 50 } do A.lit(c, c:rect(22, y, 30, y + 1), S, { R = 1 }) c:px(23, y, S[1]) c:px(28, y, S[1]) end
local pull = c:ellipse(37, 47.5, 1, 1.5)
A.lit(c, pull, B, { R = 1.5 }) c:px(36, 46, B[6]) c:px(37, 49, B[1])
-- posts
A.plank(c, 10, 25, 13, 57, W, { seed = 2, cap = true, R = 1.4 })
A.plank(c, 50, 25, 53, 57, W, { seed = 3, cap = true, R = 1.4 })
for y = 29, 55 do c:px(14, y, W[1]) c:px(49, y, W[2]) end
for _, y in ipairs{ 31, 52 } do A.nail(c, 12, y) A.nail(c, 52, y) end
-- quirk: toadstool on the side of the left post
A.map(c, {
  ".hhR.",
  "hcRRr",
  "RRrcr",
  ".dsd.",
  "..sS.",
}, 6, 39, { h = "#ff8a5c", c = "#fff4d6", R = "#e8493b", r = "#b52e3f", d = "#6e2038", s = "#f0e2c4", S = "#c9b48e" })
c:px(9, 44, "#c9b48e")
A.save2(c, "compost_bin-3")
