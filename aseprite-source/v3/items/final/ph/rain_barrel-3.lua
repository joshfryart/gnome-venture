-- rain_barrel-3 (artist pass aD11_2). Tier 3: the cask stands on a chiselled stone plinth, hoops turn polished steel, the water
-- brims over the lip and pours down the front in a bright ribbon, and a rain chain of copper cups hangs from a gutter spout on the left.
-- Material: lit staves + bevelled seams + grain, copper hoops with rivets, convex brimming water with a wet lip, glassy stream with
-- glints and a splash puddle, plinth with a lit top face, chiselled bevel, seams and speckle, contact shadow under the barrel.
-- quirk: a pink-shelled snail is climbing the front of the barrel, right across the wet streak.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_2.lua")
local G, X = A.G, A.X
local c = A.new("rain_barrel-3")
local cx, yt = 30, 23
local VERD = A.STONE
local S = A.STONE
-- plinth: top face, bevel lip, front face with seams
c:groundShadow(cx, 57, 16, 2)
local top = c:rect(cx - 15, 47, cx + 15, 52)
top:each(function(x, y) local h = X.hash(x, y, 8) c:px(x, y, S[(h > .93) and 4 or (h < .06 and 6 or 5)]) end)
local front = c:rect(cx - 15, 53, cx + 15, 56)
front:each(function(x, y)
  local i = (x < cx - 15) and 5 or (x > cx + 12 and 2 or 4)
  if y == 53 then i = 6 elseif y == 56 then i = 2 elseif y == 55 and x > cx then i = 3 end
  local h = X.hash(x, y, 14) if h > .9 and y > 53 then i = i - 1 elseif h < .05 and y > 53 then i = i + 1 end
  c:px(x, y, S[math.max(1, math.min(6, i))])
end)
for _, sx in ipairs{ cx - 6, cx + 7 } do for y = 54, 56 do c:px(sx, y, S[2]) c:px(sx + 1, y, S[5]) end end
c:px(cx - 15, 52, S[3]) c:px(cx + 15, 52, S[3])
-- contact shadow under the barrel on the slab
c:fillMask(c:ellipse(cx, 50, 11, 3), S[2])
local b = A.cask(c, { cx = cx, yt = yt, yb = 47, wt = 8, wb = 7, bulge = 3, ry = 6, ryb = 3, nst = 7, lv = 0, brim = true, ripple = .5,
  knot = { cx - 4, 36 },
  hoops = { { y = 26, ramp = VERD, rivets = { -5, 1, 6 }, rivetC = A.BRASS[4] }, { y = 40, ramp = VERD, rivets = { -5, 3, 6 }, rivetC = A.BRASS[4] } } })
local wr = A.WATER
-- spill ribbon down the front from the lip
local sx0 = cx + 6
local prev
for y = 27, 49 do
  local x = sx0 + math.floor(.7 * math.sin(y / 3.3) + .5)
  c:px(x - 1, y, wr[5]) c:px(x, y, wr[4]) c:px(x + 1, y, wr[3])
  if y % 5 == 1 then c:px(x - 1, y, wr[6]) c:px(x - 1, y + 1, wr[6]) end
  if y % 7 == 3 then c:px(x + 1, y, wr[2]) end
  prev = x
end
-- splash puddle + flying droplets
c:fillMask(c:ellipse(sx0 + 1, 51, 6, 1), wr[3])
c:fillMask(c:ellipse(sx0, 50, 4, 0), wr[4])
c:px(sx0 - 3, 51, wr[5]) c:px(sx0 - 2, 51, wr[6])
c:px(sx0 + 8, 47, wr[5]) c:px(sx0 + 9, 46, wr[4]) c:px(sx0 + 4, 46, wr[5]) c:px(sx0 - 4, 47, wr[4])
-- gutter spout from the left, funnel, rain chain with copper cups into the water
A.rod(c, 6, 7, 24, 10, 1.7, S, { amb = .1 })
c:fillMask(c:rect(10, 7, 12, 11), S[2]) c:fillMask(c:rect(10, 7, 11, 8), S[5]) c:px(10, 7, S[6])  -- strap
local BR = A.BRASS
G.disc(c, 26, 11, 2.8, BR)
c:px(26, 10, BR[1]) c:px(27, 10, BR[1]) c:px(25, 10, BR[2])                          -- dark funnel mouth
local chx = 26
for y = 14, 28 do c:px(chx, y, (y % 2 == 0) and A.IRON[5] or A.IRON[2]) end
local function cup(x, y)
  local P = { ".vvvvv.", "vyBBBBd", ".bBBBd.", "..ddd.." }
  local m = { v = BR[5], y = BR[6], b = BR[4], B = BR[3], d = BR[2] }
  for r, row in ipairs(P) do for q = 1, 7 do local ch = row:sub(q, q) if m[ch] then c:px(x - 3 + q - 1, y + r - 1, m[ch]) end end end
end
cup(chx, 14) cup(chx, 20)
c:px(chx - 4, 29, wr[5]) c:px(chx - 3, 29, wr[6]) c:px(chx + 3, 29, wr[5])           -- ripple where the chain meets the water
-- snail climbing the front, head right
local PINK = { "#6e2038", "#a83a5c", "#d65a7e", "#f088a4", "#ffb4c8", "#ffe0ea" }
local SKIN = { "#6a5a60", "#8c7c80", "#b4a498", "#d4c8b8", "#eee2cc", "#fff4e2" }
local sx, sy = cx - 6, 34
A.lit(c, c:ellipse(sx + 4, sy + 3, 5, 1), SKIN, 1.2)
A.lit(c, c:ellipse(sx + 8, sy + 2, 1, 1), SKIN, 1)
c:px(sx + 9, sy, A.INK) c:px(sx + 8, sy, SKIN[3]) c:px(sx + 7, sy + 1, SKIN[3])       -- eye stalks
local shell = c:ellipse(sx + 1, sy, 3, 3)
A.lit(c, shell, PINK, 3)
for _, p in ipairs{ {0, 0}, {1, 0}, {1, -1}, {0, -1}, {-1, -1}, {-2, 0}, {-1, 1} } do c:px(sx + 1 + p[1], sy + p[2], PINK[2]) end
c:px(sx + 1, sy, PINK[1]) c:px(sx - 1, sy - 2, PINK[6])
A.fin(c, "rain_barrel-3")
