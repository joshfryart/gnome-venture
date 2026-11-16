-- Last Forge Flame (pl-cwy-6), perch sprite 36x36. Opus second pass (c12/opus2), hand-built at this size.
-- Low round flame curled in a small iron forge dish, three licks on its back, tail tongue wrapped round the
-- right side; edge-in heat (deep red rim, orange body, gold core at the back). Drowsy face: 2x3 pills with a
-- lid line above each. Rare: one sparkle.
-- quirk: a small dream bubble with a tiny violet dragon.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-cwy-6-perch", 36)

local FL   = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a3c", "#ffc048", "#ffe89a" }
local IRON = { "#241c2e", "#352a40", "#4c3e56", "#685a72", "#8c7e94", "#b4a8b8" }
local BUB  = { "#5f7fb8", "#8bb0dc", "#b9d6ef", "#dceef8", "#eef8fc" }

c:groundShadow(16, 33, 11, 1)
local bowl = c:ellipse(16, 28, 11, 4.5)
bowl:cut(c:rect(0, 0, 35, 27))
O.shade(c, bowl, IRON, { R = 2, amb = .25, wrap = .4, rim = true })
for _, x in ipairs({ 10, 16, 22 }) do O.mark(c, { { x, 29 } }, IRON[2]) end
local coals = O.unionCircles({ { 8, 27, 2, 1.5 }, { 24, 27, 2, 1.5 } })
O.shade(c, coals, { "#2a1c26", "#3a2630", "#4e3238", "#6a4040", "#8a5248", "#a8644e" }, { R = 1, amb = .2, sep = "#2a1c26" })
O.mark(c, { { 8, 27 }, { 24, 26 } }, "#ff8a3c")

local body = c:ellipse(16, 21, 8.5, 6)
body:add(c:poly{ { 9, 19 }, { 7, 11 }, { 12, 16 } })
body:add(c:poly{ { 12, 16 }, { 14, 8 }, { 18, 15 } })
body:add(c:poly{ { 17, 16 }, { 21, 10 }, { 22, 17 } })
local d = X.dist(body)
local tok = { r = { name = "flame" } }
body:each(function(x, y)
  local v = d[K(x, y)] or 0
  local i = v < 1.5 and 1 or v < 2.5 and 2 or v < 3.5 and 3 or 4
  if v >= 3.5 and y < 20 then i = 5 end
  if v < 2.5 and (x - 16) + (y - 19) < -7 then i = math.min(6, i + 1) end
  c:put(x, y, FL[i], tok)
end)
local tail, tn, tT = O.tube({ { 24, 24 }, { 28, 21 }, { 28, 16 }, { 25, 13 } }, function(t) return 2.2 * (1 - t) + .4 end)
local td = X.dist(tail)
local tt = { r = { name = "tail" } }
tail:each(function(x, y)
  local v = td[K(x, y)] or 0
  local i = v < 1.5 and 2 or 4
  if body:has(x, y) and not tail:has(x - 1, y) then i = 1 end
  c:put(x, y, FL[i], tt)
end)
O.dot(c, 11, 24, P.petal.base) O.dot(c, 21, 24, P.petal.base)
O.dots(c, { { 15, 24 }, { 16, 25 }, { 17, 24 } }, P.ink)

-- dream bubble + tiny dragon
O.flat(c, c:ellipse(25, 10, .6, .6), BUB[3])
local bub = O.unionCircles({ { 29, 6, 4.5, 3.8 } })
O.shade(c, bub, BUB, { sphere = { 28, 4, 7 }, amb = .55, wrap = .5, cuts = { .3, .5, .7, .85 } })
c:paint({
  "a..a...",
  "ab.ab.b",
  ".bbbbbb",
  "..b.b..",
}, 26, 4, { a = P.dusk.base, b = P.dusk.shade })

O.done(c, "pl-cwy-6-perch", function(c)
  c:eyeSmall(12, 20)
  c:eyeSmall(19, 20)
  c:put(11, 19, P.ink) c:put(12, 19, P.ink) c:put(13, 19, P.ink)
  c:put(18, 19, P.ink) c:put(19, 19, P.ink) c:put(20, 19, P.ink)
  c:put(12, 20, FL[4]) c:put(19, 20, FL[4])
  c:put(13, 21, P.cream) c:put(20, 21, P.cream)
  c:sparkle(4, 5)
end)
