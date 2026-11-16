-- Sherbet Sip (dw-sherbet-sip), perch sprite 36x36. Opus second pass, hand-built at this size.
-- Peach Moroccan teapot with one gold band, domed gold lid, mint leaf, looped handle, pill eyes; the spout swoops
-- above its head and a 2 px stream drops into a gold-rimmed glass. quirk: one drop hopping out of the glass.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("dw-sherbet-sip-perch", 36)

local PCH  = { "#7a3434", "#b85a48", "#e08060", "#f4a67a", "#fac69c", "#fee6cc" }
local GOLD = { "#6a3e12", "#a0701c", "#d4a032", "#f0cc5a", "#fbe8a0" }
local MINT = { "#24563a", "#3e8a48", "#6cbc5a", "#a8e07a" }
local TEA  = { "#6a6a1e", "#a8a83a", "#dcd878" }
local GLS  = { "#4a6a7a", "#8ab4be", "#cde6e6" }

c:groundShadow(18, 32, 13, 1.5)
local hnd = c:ellipse(5.5, 21, 2.5, 3.5) hnd:cut(c:rect(5, 20, 6, 22))
O.shade(c, hnd, GOLD, { R = 1, amb = .3, cuts = { .25, .5, .72, .9 } })
O.shade(c, c:poly{ { 10, 27 }, { 18, 27 }, { 19, 30 }, { 9, 30 } }, GOLD, { R = 1, amb = .3, cuts = { .25, .5, .72, .9 }, sep = GOLD[1] })
local body = c:ellipse(14, 22, 7.5, 5.5) body:add(c:ellipse(14, 17.5, 5, 2.5))
local bI, bT = O.shade(c, body, PCH, { sphere = { 12, 19, 9 }, amb = .2, wrap = .4, sep = PCH[1], rim = true, bounce = "#9a7ab8", bmax = 2 })
for x = 6, 22 do if body:has(x, 25) then c:put(x, 25, GOLD[3], bT) end end
O.shade(c, c:ellipse(14, 14, 4, 2):add(c:rect(10, 14, 18, 15)), GOLD, { R = 1, amb = .3, cuts = { .25, .5, .72, .9 }, sep = GOLD[1] })
O.flat(c, c:rect(14, 9, 14, 11), GOLD[3], "finial") O.dot(c, 14, 9, GOLD[5])
O.shade(c, c:poly{ { 16, 11 }, { 18, 9 }, { 20, 9 }, { 18, 11 } }, MINT, { R = 1, amb = .35, cuts = { .3, .55, .8 } })
local sp, sn = O.tube({ { 20, 23 }, { 27, 23 }, { 23, 8 }, { 29, 6 } }, function(t) return 1.6 - t * .7 end)
O.shadeN(c, sp, sn, PCH, { amb = .3, wrap = .4, sep = PCH[1] })
O.dots(c, { { 29, 5 }, { 30, 6 } }, GOLD[4])
c:eyeSmall(10, 19) c:eyeSmall(16, 19)
O.dot(c, 8, 23, "#f5809f") O.dot(c, 19, 23, "#f5809f")
O.dots(c, { { 12, 23 }, { 13, 24 }, { 14, 24 }, { 15, 23 } }, P.ink)
local gl = c:poly{ { 27, 26 }, { 33, 26 }, { 32, 31 }, { 28, 31 } }
O.shade(c, gl, GLS, { R = 1, amb = .4, cuts = { .35, .7 }, sep = GLS[1] })
O.dots(c, { { 28, 28 }, { 29, 29 }, { 30, 28 }, { 31, 29 }, { 32, 28 } }, GOLD[3])
O.dots(c, { { 29, 30 }, { 30, 30 }, { 31, 30 } }, TEA[2])
O.dots(c, { { 27, 26 }, { 28, 26 }, { 29, 26 }, { 30, 26 }, { 31, 26 }, { 32, 26 }, { 33, 26 } }, GOLD[4])
O.dots(c, { { 28, 27 }, { 29, 27 }, { 31, 27 }, { 32, 27 } }, TEA[2])
O.done(c, "dw-sherbet-sip-perch", function(c)
  for y = 7, 25 do c:put(30, y, TEA[3]) c:put(31, y, TEA[2]) end
  c:put(34, 22, TEA[3]) c:put(34, 23, TEA[2])
end)
