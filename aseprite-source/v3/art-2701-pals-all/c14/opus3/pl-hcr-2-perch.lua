-- Shell Splinter (pl-hcr-2), perch sprite 36x36. Opus third pass (c14/opus3), hand-built at this size.
-- opus3: a few bold carapace bumps, the brow groove and a barnacle dot.
-- Domed orange shard of crab shell with rim spines on top and a jagged fracture showing the pale shell
-- thickness, two leg stubs, 2x3 pill eyes, chattering zigzag mouth.
-- quirk: shake ticks either side and a hopping crumb of shell.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_c14.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-hcr-2-perch", 36)

local SHL  = { "#5a1c26", "#97302a", "#cc4e2c", "#ec7a34", "#f8a656", "#fdd396" }
local CORE = { "#a8705a", "#d8a87c", "#f2d4a6", "#fcecc8" }
local LEG  = { "#5a1c26", "#8a2c2c", "#b84630", "#e06e3a", "#f2984e" }

c:groundShadow(17, 31, 10, 1.5)
for _, L in ipairs({ { { 13, 25 }, { 12, 28 }, { 11, 29 }, { 11, 30 } }, { { 22, 25 }, { 23, 28 }, { 24, 29 }, { 24, 30 } } }) do
  local m, n = O.tube(L, function(t) return 1.2 end)
  O.shadeN(c, m, n, LEG, { amb = .3, wrap = .4, sep = LEG[1], cuts = { .25, .45, .65, .85 } })
end
local dome = c:poly{ { 5, 18 }, { 8, 12 }, { 13, 8 }, { 19, 7 }, { 22, 11 }, { 25, 10 }, { 30, 15 }, { 28, 18 }, { 31, 22 },
                     { 26, 25 }, { 25, 28 }, { 20, 26 }, { 16, 28 }, { 12, 25 }, { 8, 26 }, { 6, 22 } }
dome:add(c:ellipse(16, 19, 11, 11):clip(c:poly{ { 0, 0 }, { 21, 0 }, { 21, 8 }, { 6, 23 }, { 0, 23 } }))
dome:set(8, 11) dome:set(13, 7)
local dI, dT = O.radial(c, dome, SHL, 11, 10, 20, { top = .93, ef = .7, edge = 3, rim = true, bounce = "#8a5a7a", bmax = 2 })
local core = {}
dome:each(function(x, y) if x + y > 30 and (not dome:has(x + 1, y + 1) or not dome:has(x, y + 1) or not dome:has(x + 1, y)) then core[#core+1] = { x, y } end end)
for _, q in ipairs(core) do O.mark(c, { q }, CORE[3]) end
O.mark(c, { { 9, 14 }, { 10, 14 }, { 25, 15 }, { 26, 15 } }, SHL[2])
O.mark(c, { { 11, 11 }, { 12, 10 }, { 13, 10 }, { 14, 9 } }, SHL[6])
for _, b in ipairs({ { 8, 18 }, { 17, 10 }, { 22, 12 }, { 27, 17 }, { 7, 22 } }) do O.bump(c, b[1], b[2], SHL, 2) end
O.nudge(c, { { 12, 13 }, { 13, 12 }, { 14, 12 }, { 15, 12 }, { 16, 12 }, { 17, 12 }, { 18, 13 } }, -2, SHL)
O.dots(c, { { 20, 8 } }, CORE[4]) O.dots(c, { { 21, 8 } }, CORE[1])

c:eyeSmall(12, 15)
c:eyeSmall(20, 15)
O.dot(c, 10, 19, P.petal.base) O.dot(c, 24, 19, P.petal.base)
O.dots(c, { { 14, 20 }, { 15, 19 }, { 16, 20 }, { 17, 19 }, { 18, 20 }, { 19, 19 } }, P.ink)

local crumb = c:poly{ { 30, 26 }, { 32, 25 }, { 33, 27 }, { 31, 28 } }
O.shade(c, crumb, SHL, { R = 1, amb = .4 })

O.done(c, "pl-hcr-2-perch", function(c)
  O.dots(c, { { 3, 15 }, { 3, 18 } }, P.ink)
  O.dots(c, { { 31, 13 }, { 32, 16 } }, P.ink)
end)
