-- Barrow Icecrown (pl-frt-6), perch sprite 36x36. Opus richness pass (c09/opus3), hand-built at this size.
-- opus3: faceted points (shaded right face), bigger cut gems (opus2's 2x2 gems were lost at 36 px: now a 5x7 centre
-- diamond and 3x5 side diamonds with a glint and a dark lower facet), rime specks, freckled sac.
-- Ice crown: curved band, five icicle points (middle tallest) with pale core streaks, violet gems, sparkle.
-- quirk: croaking, a wide toad mouth over a green throat sac ballooning out of its chin.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-frt-6-perch", 36)
local ICE = { "#2a3f7a", "#3a63a8", "#5f9ad0", "#8bc4ea", "#c4ecfa", "#eefaff" }
local GEM = { "#2f2257", "#55409a", "#8668d0", "#c4a8f2" }
local SAC = { "#2e5a48", "#4a7d52", "#76a35e", "#a8c97a", "#d4e6a6", "#eef6cc" }
c:groundShadow(18, 31, 10, 1.5)
local pts = { { 7, 12 }, { 12, 8 }, { 18, 4 }, { 24, 8 }, { 29, 12 } }
local sp = HP.mask()
for _, p in ipairs(pts) do sp:add(c:poly({ { p[1] - 3, 19 }, { p[1] + .5, p[2] }, { p[1] + 3.5, 19 } })) end
local kI, kT = O.shade(c, sp, ICE, { R = 2, amb = .3, wrap = .5, rim = true, sep = ICE[2] })
O.tex(c, kI, kT, ICE, function(x, y, i) for _, p in ipairs(pts) do
  if x == p[1] and y > p[2] + 1 and y < 18 then return 2 end
  if x > p[1] and x <= p[1] + 3 and y > p[2] + 2 and i >= 3 then return -1 end
end end)
local band = HP.mask()
for x = 6, 30 do local d = (x - 18) / 13 for y = 17 - math.floor(d * d * 2 + .5), 26 - math.floor(d * d * 3 + .5) do band:set(x, y) end end
local bI, bT = O.shade(c, band, ICE, { sphere = { 14, 16, 16 }, amb = .3, wrap = .5, rim = true, bounce = "#7a6fc0", bmax = 3, sep = ICE[1] })
for _, g in ipairs({ { 8, 20 }, { 28, 20 } }) do
  O.flat(c, c:poly({ { g[1], g[2] - 2 }, { g[1] + 1, g[2] }, { g[1], g[2] + 2 }, { g[1] - 1, g[2] } }), GEM[3], "gem")
  O.dots(c, { { g[1], g[2] + 1 }, { g[1] + 1, g[2] }, { g[1], g[2] + 2 } }, GEM[2]) O.dot(c, g[1], g[2] - 1, GEM[4])
end
local cgm = c:poly({ { 18, 13 }, { 20.5, 16.5 }, { 18, 20 }, { 15.5, 16.5 } })
O.flat(c, cgm, GEM[3], "cgem")
O.dots(c, { { 17, 15 }, { 17, 16 } }, GEM[4]) O.dots(c, { { 19, 17 }, { 18, 19 }, { 19, 18 } }, GEM[2])
cgm:edge():each(function(x, y) if x > 18 or y > 17 then O.dot(c, x, y, GEM[1]) end end)
O.dots(c, { { 9, 25 }, { 13, 26 }, { 24, 26 }, { 27, 25 } }, ICE[6])
local sac = c:ellipse(18, 27, 4, 3)
O.shade(c, sac, SAC, { sphere = { 16, 25, 5 }, amb = .3, wrap = .5, rim = true, sep = SAC[1] })
O.dots(c, { { 16, 25 }, { 17, 25 } }, SAC[6]) O.dots(c, { { 19, 28 }, { 15, 28 } }, SAC[2])
c:eyeSmall(12, 19) c:eyeSmall(22, 19)
O.dot(c, 10, 23, P.petal.base) O.dot(c, 25, 23, P.petal.base)
O.dots(c, { { 15, 23 }, { 16, 24 }, { 17, 24 }, { 18, 24 }, { 19, 24 }, { 20, 24 }, { 21, 23 } }, P.ink)
O.done(c, "pl-frt-6-perch", function(c) c:sparkle(30, 6) end)
