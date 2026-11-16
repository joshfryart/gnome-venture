-- Jadewing Quartet (pl-jdf-4), perch sprite 36x36. Opus second pass (c15/opus2), hand-built at this size.
-- Round jade dragonfly chick: big head with 2x3 pill eyes and a grin, ringed tail with a gold thorn tip, and its
-- four veined glass wings all crowded to the front-right side.
-- quirk: the four wings jostle forward at once (hurry ticks behind).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-jdf-4-perch", 36)

local JADE = { "#16403a", "#1f6650", "#2f9460", "#55bf6a", "#9ae07c", "#d8f6aa" }
local WING = { "#2e5c78", "#4c8aa6", "#7ab8c8", "#a6dcd8", "#cdf0e6", "#eefcf2" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

c:groundShadow(16, 32, 9, 1)
local tail, tn, tT = O.tube({ { 13, 22 }, { 12, 27 }, { 8, 30 }, { 6, 26 } }, function(t) return 2.2 - t * 1.2 end)
local tI = O.shadeN(c, tail, tn, JADE, { amb = .3, wrap = .4, rim = true })
tail:each(function(x, y) local t = tT[K(x, y)] or 0 if (t > .3 and t < .38) or (t > .6 and t < .68) then c.pix[y * c.w + x] = GOLD[3] end end)
O.flat(c, c:rect(5, 23, 6, 24), GOLD[3], "thorn") O.dot(c, 5, 22, GOLD[4]) O.dot(c, 6, 24, GOLD[2])

local wings = {
  { { 19, 15 }, { 22, 9 }, { 25, 6 }, { 28, 4 } },
  { { 20, 16 }, { 25, 12 }, { 29, 10 }, { 32, 9 } },
  { { 20, 18 }, { 25, 17 }, { 29, 17 }, { 32, 17 } },
  { { 19, 20 }, { 24, 22 }, { 27, 24 }, { 30, 26 } },
}
for _, wp in ipairs(wings) do
  local m, n, T, S = O.tube(wp, function(t) return .8 + 1.5 * math.sin(math.pi * math.min(1, t * .95 + .08)) end)
  local I, Tk = O.shadeN(c, m, n, WING, { amb = .5, wrap = .5, sep = WING[1] })
  O.tex(c, I, Tk, WING, function(x, y, i) local s = S[K(x, y)] or 0 if math.abs(s) < .3 and (T[K(x, y)] or 0) > .1 then return -2 end end)
  local sx, sy = O.bez(wp, .88)
  O.mark(c, { { math.floor(sx), math.floor(sy) } }, GOLD[3])
end
O.shade(c, c:ellipse(16, 20, 3.5, 3), JADE, { R = 2, amb = .3, wrap = .4, sep = JADE[2] })
O.shade(c, c:ellipse(13, 14, 7, 6.5), JADE, { sphere = { 11, 11, 9 }, amb = .28, wrap = .4, rim = true, bounce = "#3a6a8a", bmax = 2, sep = JADE[2] })
O.flat(c, c:rect(9, 7, 9, 8), JADE[4], "ant") O.flat(c, c:rect(16, 7, 16, 8), JADE[4], "ant")

c:eyeSmall(10, 12)
c:eyeSmall(15, 12)
O.dot(c, 8, 16, P.petal.base) O.dot(c, 18, 16, P.petal.base)
O.mark(c, { { 12, 17 }, { 13, 18 }, { 14, 17 } }, P.ink)

O.done(c, "pl-jdf-4-perch", function(c)
  for _, p in ipairs({ { 2, 11 }, { 3, 11 }, { 2, 14 }, { 3, 14 }, { 4, 14 } }) do c:put(p[1], p[2], P.ink) end
end)
