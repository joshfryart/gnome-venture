-- Howl Echo (pl-gwk-5), perch sprite 36x36. Opus second pass (c13/opus2), hand-built at this size.
-- A round twilight-blue sound wisp with a flame tip, 2x3 pill eyes and a big "O" howl; its tail rings once round
-- behind it.
-- quirk: the end of the ring comes back as a small echo wisp with a tiny howl, upper left.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-gwk-5-perch", 36)

local WISP = { "#1c2458", "#2c4486", "#3d6cb0", "#58a0d2", "#8ccde8", "#cdeef6" }
local RING = { "#2a2a66", "#3e4e96", "#5a7cc0", "#80aedc", "#b0d8ee", "#e0f4fa" }
local MOUTH = "#3a1e4a"

c:groundShadow(17, 33, 9, 1)
for _, sg in ipairs({
  { { { 21, 25 }, { 28, 29 }, { 32, 23 }, { 31, 15 } }, function(t) return 2.4 - t * .5 end },
  { { { 31, 15 }, { 30, 7 }, { 23, 3 }, { 16, 4 } }, function(t) return 1.9 - t * .5 end },
  { { { 16, 4 }, { 12, 4 }, { 9, 6 }, { 7, 8 } }, function(t) return 1.4 end },
}) do
  local m, n = O.tube(sg[1], sg[2])
  O.shadeN(c, m, n, RING, { amb = .32, wrap = .5, rim = true })
end
local echo = c:ellipse(6, 10, 3.5, 3)
O.shade(c, echo, WISP, { sphere = { 4, 8, 5 }, amb = .35, wrap = .5, rim = true, sep = RING[1] })
O.dot(c, 6, 11, MOUTH)
local head = c:ellipse(15, 21, 9, 8.5)
head:add(c:poly{ { 10, 14 }, { 17, 13 }, { 11, 8 }, { 13, 12 } })
O.shade(c, head, WISP, { sphere = { 11, 17, 13 }, amb = .3, wrap = .5, rim = true, bounce = "#9a7ad0", bmax = 3, sep = RING[1] })

c:eyeSmall(10, 18)
c:eyeSmall(17, 17)
O.dot(c, 8, 22, P.petal.base) O.dot(c, 21, 21, P.petal.base)
O.flat(c, c:rect(15, 22, 17, 25), MOUTH, "mouth")
O.dots(c, { { 15, 22 }, { 17, 22 }, { 15, 25 }, { 17, 25 } }, WISP[3])
O.dots(c, { { 16, 21 }, { 14, 23 }, { 14, 24 }, { 18, 23 }, { 18, 24 }, { 16, 26 } }, P.ink)
O.dot(c, 16, 25, "#e0708e")

O.done(c, "pl-gwk-5-perch", function(c)
  for _, p in ipairs({ { 25, 17 }, { 26, 16 }, { 26, 15 } }) do if not c:get(p[1], p[2]) then c:put(p[1], p[2], RING[6]) end end
end)
