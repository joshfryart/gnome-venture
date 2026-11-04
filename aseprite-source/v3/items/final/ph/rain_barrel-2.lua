-- rain_barrel-2 (artist pass aD11_2). Tier 2: the cask gets three iron hoops with brass rivets, wooden skids, a plank lid slid over the left half,
-- a brass tap low on the front with a drip, and a measuring staff strapped to its side. The downspout now comes from the right.
-- Material: per-pixel lit staves + grain + bevelled seams, three iron hoops with brass rivets with rivets and glints, plank lid with nails and a
-- visible edge thickness, ticked staff, notched red pennant, rippled water with a ring where the drip lands.
-- quirk: the pennant has been mended with a yellow patch.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_2.lua")
local G, X = A.G, A.X
local c = A.new("rain_barrel-2")
local cx, yt = 30, 26
c:groundShadow(cx + 1, 55, 15, 2)
-- measuring staff (behind barrel, left side) with ticks and a pennant
local SW = A.WOOD
A.rod(c, 15, 12, 15, 48, 1.5, A.OLD, { amb = .12 })
for y = 17, 45, 4 do c:px(14, y, A.OLD[1]) if (y - 17) % 8 == 0 then c:px(15, y, A.OLD[1]) end end
-- skids (feet)
for _, x0 in ipairs{ 22, 34 } do A.lit(c, c:rrect(x0, 50, x0 + 6, 54, 1), A.OLD, 1.6) end
local b = A.cask(c, { cx = cx, yt = yt, yb = 50, wt = 8, wb = 7, bulge = 3, ry = 6, ryb = 3, nst = 7, lv = 2, ripple = .5,
  knot = { cx - 5, 40 },
  hoops = { { y = 28, rivetC = A.BRASS[5], rivets = { -5, 2, 6 } }, { y = 33, rivetC = A.BRASS[5], rivets = { -4, 4 } }, { y = 46, rivetC = A.BRASS[5], rivets = { -5, 0, 5 } } } })
-- strap holding the staff to the barrel
c:fillMask(c:rect(14, 32, 17, 33), A.IRON[3]) c:fillMask(c:rect(14, 32, 17, 32), A.IRON[5]) c:px(14, 33, A.IRON[1]) c:px(15, 32, A.IRON[6])
c:fillMask(c:rect(14, 42, 17, 43), A.IRON[3]) c:fillMask(c:rect(14, 42, 17, 42), A.IRON[5]) c:px(14, 43, A.IRON[1])
-- pennant on the staff top (points right), notched tail, yellow patch
local fl = c:poly({ {16, 8}, {27, 9}, {24, 12}, {27, 15}, {16, 16} })
A.lit(c, fl, A.RED, 1.8, { amb = .1 })
c:fillMask(c:rect(19, 11, 21, 13), A.BRASS[5]) c:fillMask(c:rect(19, 13, 21, 13), A.BRASS[3]) c:px(19, 11, A.BRASS[6])
c:px(20, 12, A.BRASS[4]) c:px(22, 11, A.RED[1]) c:px(18, 12, A.RED[1])                               -- stitches round the patch
-- lid slid over the left half: raised disc with plank lines and a visible edge
local lm = c:ellipse(cx, yt - 2, 9, 6)
local clip = c:rect(cx - 12, yt - 12, cx + 1, yt + 6)
lm:clip(clip)
local edge = lm:shift(0, 2):cut(lm)
edge:each(function(x, y) c:put(x, y, A.WOOD[(x < cx - 7) and 2 or 1], { r = { name = "lidedge" } }) end)
A.lit(c, lm, A.WOOD, 2.2, { amb = .12, cuts = { .22, .4, .58, .74, .9 } })
for x = cx - 9, cx, 3 do lm:each(function(xx, yy) if xx == x then c:px(xx, yy, A.WOOD[2]) end end) end
lm:each(function(x, y) if x == cx - 8 or x == cx - 5 or x == cx - 2 then if y == yt - 7 or y == yt + 1 then c:px(x, y, A.IRON[5]) end end end)
c:px(cx - 11, yt - 3, A.WOOD[6]) c:px(cx - 10, yt - 4, A.WOOD[6])
-- iron pull ring on the lid
for _, p in ipairs{ {cx - 6, yt - 5}, {cx - 5, yt - 5}, {cx - 7, yt - 4}, {cx - 4, yt - 4}, {cx - 6, yt - 3}, {cx - 5, yt - 3} } do c:px(p[1], p[2], A.IRON[4]) end
c:px(cx - 6, yt - 5, A.IRON[6]) c:px(cx - 5, yt - 4, A.IRON[1])
-- downspout from the right
local Z = A.STONE
A.rod(c, 47, 8, 47, 14, 1.5, Z, { amb = .1 })
A.rod(c, 47, 14, 35, 14, 1.5, Z, { amb = .1 })
A.rod(c, 35, 14, 35, 19, 1.5, Z, { amb = .1 })
G.disc(c, 47, 14, 2.6, Z)
c:fillMask(c:rect(45, 10, 49, 10), Z[2]) c:fillMask(c:rect(45, 9, 49, 9), Z[5])
A.collar(c, 41, 13, 0, Z, 3)
c:px(34, 19, Z[1]) c:px(35, 19, Z[1]) c:px(36, 19, Z[2])
A.drop(c, 35, 21, A.WATER)
-- brass tap, front, on the right of centre
local T = {
  ".yyyy.",
  "..bb..",
  "hbbbBS",
  "hBBBBS",
  "..dBd.",
  "...dd.",
}
local m = { y = A.BRASS[6], h = A.BRASS[6], b = A.BRASS[5], B = A.BRASS[4], S = A.BRASS[3], d = A.BRASS[2] }
local tx, ty = cx + 2, 40
-- dark halo so the brass pops off the oak
for r, row in ipairs(T) do for q = 1, #row do if m[row:sub(q, q)] then for dy = -1, 1 do for dx = -1, 1 do c:px(tx + q - 1 + dx, ty + r - 1 + dy, A.WOOD[1]) end end end end end
for r, row in ipairs(T) do for q = 1, #row do local ch = row:sub(q, q) if m[ch] then c:px(tx + q - 1, ty + r - 1, m[ch]) end end end
c:px(tx + 1, ty, A.BRASS[4]) c:px(tx + 4, ty, A.BRASS[3])
A.tinydrop(c, tx + 3, ty + 7, A.WATER)
A.fin(c, "rain_barrel-2")
