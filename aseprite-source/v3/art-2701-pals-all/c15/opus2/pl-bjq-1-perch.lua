-- Tentacle Wisp (pl-bjq-1), perch sprite 36x36. Opus second pass (c15/opus2), hand-built at this size.
-- A glassy pink jelly bulb holding the face (2x3 pill eyes, small smile) with one ringed tentacle rising in an
-- S-sway and rolling into a spiral curl on top.
-- quirk: it sways to a music note only it hears.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-bjq-1-perch", 36)

local JEL = { "#6a2252", "#a83a72", "#d85a8e", "#f2829f", "#ffb4c8", "#ffe2ea" }

c:groundShadow(17, 32, 9, 1)
local spans = {
  { { 17, 21 }, { 24, 17 }, { 12, 13 }, { 15, 8 } },
  { { 15, 8 }, { 17, 3 }, { 25, 4 }, { 25, 8 } },
  { { 25, 8 }, { 25, 12 }, { 20, 12 }, { 21, 9 } },
}
local w0, w1 = { 3.4, 2.2, 1.4 }, { 2.2, 1.4, .7 }
for si = #spans, 1, -1 do
  local m, n, T = O.tube(spans[si], function(t) return w0[si] + (w1[si] - w0[si]) * t end)
  local I, Tk = O.shadeN(c, m, n, JEL, { amb = .36, wrap = .5, rim = true, sep = JEL[2] })
  O.tex(c, I, Tk, JEL, function(x, y, i) if ((T[K(x, y)] or 0) * (5 - si)) % 1 < .14 then return -1 end end)
end
O.mark(c, { { 14, 12 }, { 15, 9 } }, JEL[6])
local hI, hT = O.shade(c, c:ellipse(17, 25, 8.5, 6.5), JEL, { sphere = { 14, 21, 11 }, amb = .38, wrap = .5, rim = true, bounce = "#8a7ad0", bmax = 2, sep = JEL[2] })
O.mark(c, { { 11, 21 }, { 12, 20 } }, JEL[6])

c:eyeSmall(13, 23)
c:eyeSmall(20, 23)
O.dot(c, 11, 27, P.petal.base) O.dot(c, 23, 27, P.petal.base)
O.mark(c, { { 16, 28 }, { 17, 28 } }, P.ink)

O.done(c, "pl-bjq-1-perch", function(c)
  for _, p in ipairs({ { 6, 5 }, { 6, 6 }, { 6, 7 }, { 6, 8 }, { 7, 5 }, { 8, 6 }, { 5, 8 }, { 5, 9 }, { 6, 9 },
    { 29, 4 }, { 30, 5 }, { 30, 6 }, { 29, 7 } }) do if not c:get(p[1], p[2]) then c:put(p[1], p[2], P.ink) end end
end)
