-- Karst Yawn (pl-dlz-5), perch sprite 36x36. Opus second pass (c11/opus2), hand-built at this size.
-- Lumpy lilac limestone boulder on stubby feet, strata lines, an ochre streak, moss and a fern frond on the right
-- bump. 2x3 pill eyes above a huge yawning den mouth with two stalactite and two stalagmite teeth.
-- quirk: the yawn; closer look: the little sleeping bat (3 px) hanging in the mouth.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-dlz-5-perch", 36)

local LIME = { "#3a2e44", "#5a4c62", "#7e7084", "#a496a2", "#c8bcbc", "#e8dece" }
local OCHR = { "#8a5a34", "#b8844a" }
local CAVE = { "#1e1426", "#2c1c34", "#3e2a44" }
local MOSS = { "#2a4428", "#3e6a30", "#5e963c", "#94c458" }
local BAT  = { "#6a4a6a", "#9a6e8a" }

c:groundShadow(18, 33, 12, 1)
for _, fx in ipairs({ 12, 24 }) do O.shade(c, c:ellipse(fx, 31, 3, 2), LIME, { sphere = { fx - 1, 30, 4 }, amb = .3, wrap = .4, sep = LIME[1] }) end
local rock = c:ellipse(18, 20, 12, 10)
rock:add(c:ellipse(12, 12, 5, 4)) rock:add(c:ellipse(23, 11, 6, 4.5)) rock:add(c:ellipse(18, 26, 11, 4.5))
rock:cut(c:rect(0, 31, 35, 35))
local rI, rT = O.shade(c, rock, LIME, { sphere = { 13, 11, 18 }, amb = .32, wrap = .42, rim = true, sep = LIME[1] })
O.tex(c, rI, rT, LIME, function(x, y, i) if (y + math.floor(math.sin(x * .5))) % 5 == 0 and (x < 12 or x > 25 or y < 15) then return -1 end end)
for j = 0, 4 do O.mark(c, { { 28 + (j // 3), 15 + j } }, OCHR[j % 2 + 1]) end
-- yawning mouth
local mouth = c:ellipse(18, 22, 6, 6)
mouth:add(c:ellipse(18, 25, 6.5, 3))
O.flat(c, mouth, CAVE[1], "mouth")
mouth:edge():each(function(x, y) c.pix[y * c.w + x] = (y < 22 and LIME[2] or CAVE[3]) end)
O.flat(c, c:rect(16, 27, 20, 27), CAVE[2], "throat")
O.dots(c, { { 15, 17 }, { 16, 17 }, { 15, 18 }, { 20, 17 }, { 21, 17 }, { 21, 18 } }, LIME[5]) -- stalactites
O.dots(c, { { 15, 27 }, { 15, 26 }, { 21, 27 }, { 21, 26 } }, LIME[4]) -- stalagmites
O.dots(c, { { 18, 19 }, { 18, 20 }, { 18, 21 } }, BAT[2]) O.dots(c, { { 17, 20 }, { 19, 20 } }, BAT[1])
-- moss and a fern on the right bump
for x = 19, 28 do
  for y = 0, 35 do if rock:has(x, y) then O.mark(c, { { x, y } }, MOSS[3]) if x % 2 == 0 then O.mark(c, { { x, y + 1 } }, MOSS[2]) end break end end
end
local fr, fn = O.tube({ { 23, 7 }, { 23, 4 }, { 27, 3 }, { 29, 5 } }, function(t) return .8 end)
O.shadeN(c, fr, fn, MOSS, { amb = .4, wrap = .45, cuts = { .25, .5, .78 } })
O.dots(c, { { 22, 5 }, { 25, 2 }, { 28, 3 } }, MOSS[4])
c:eyeSmall(11, 11)
c:eyeSmall(23, 11)
O.dot(c, 9, 15, P.petal.base) O.dot(c, 27, 15, P.petal.base)

O.done(c, "pl-dlz-5-perch", function(c)
  for _, p in ipairs({ { 32, 20 }, { 33, 19 } }) do c:put(p[1], p[2], LIME[5]) end
end)
