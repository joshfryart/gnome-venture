-- Puddle Croak (pl-frt-2), perch sprite 36x36. Opus richness pass (c08/opus3), hand-built at this size: a wide warty slate-green
-- frost toad (eye bumps, parotoid bulges, frosted wart flecks) sunk to its belly in an icy puddle with a pale ice rim,
-- 2x3 pill eyes under heavy lid lines, a long closed smile.
-- Richness kept bold: hue-shifted ramps, a frost crust on the head top, a few darker blotches, the toad's dark
-- reflection in the puddle, ice-crust glints.
-- quirk: humming a lullaby: one gold eighth note drifting up.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("pl-frt-2-perch", 36)
local TOAD = { "#1a2438", "#283e52", "#3e5e6a", "#5e8682", "#8eb4a0", "#cce4c8" }
local POOL = { "#1e3466", "#2c5294", "#3a7ab0", "#5fa8cc", "#9ad2e4" }
local GOLD = { "#7a3a1c", "#b85c1f", "#e08a26", "#f5b82e", "#ffd970", "#fff0b0" }

local pool = c:ellipse(17, 30, 15, 3.5)
O.shade(c, pool, POOL, { R = 2, amb = .35, cuts = { .3, .5, .7, .86 } })
local rim = {} pool:edge():each(function(x, y) if y <= 30 then rim[#rim+1] = { x, y } end end)
O.mark(c, rim, "#d4eef8")
for k, q in ipairs(rim) do if k % 4 == 0 then O.mark(c, { q }, "#f4fbf6") end end
local refl = {} for x = 10, 24 do if pool:has(x, 31) then refl[#refl+1] = { x, 31 } end end
O.mark(c, refl, POOL[2])
local body = c:ellipse(17, 24, 10, 6):add(c:ellipse(17, 19, 8, 5.5))
body:add(c:ellipse(12, 15, 3, 2.5)):add(c:ellipse(22, 15, 3, 2.5)):add(c:ellipse(8, 19, 2.5, 2)):add(c:ellipse(26, 19, 2.5, 2))
body:cut(c:rect(0, 30, 35, 35))
O.shade(c, body, TOAD, { sphere = { 14, 15, 13 }, amb = .3, wrap = .4, sep = TOAD[1], rim = true, bounce = "#3a6a9a", bmax = 2 })
do
  local fl = {}
  body:each(function(x, y) if y < 18 and not body:has(x, y - 1) and (x + y) % 3 ~= 0 then fl[#fl+1] = { x, y } end end)
  O.mark(c, fl, "#e2f2f2")
end
O.mark(c, { { 10, 24 }, { 11, 24 }, { 23, 23 }, { 24, 23 }, { 26, 22 } }, TOAD[3])
O.mark(c, { { 9, 23 }, { 24, 25 }, { 15, 26 }, { 27, 21 }, { 7, 19 }, { 20, 27 } }, TOAD[6])
O.shade(c, c:ellipse(17, 27, 4.5, 2.5):cut(c:rect(0, 29, 35, 35)), { "#b4c2ae", "#d8e2cc", "#eef4e2" }, { R = 1, amb = .45, cuts = { .4, .75 } })
O.flat(c, c:rect(8, 29, 26, 29), POOL[4], "waterline")
O.dots(c, { { 10, 29 }, { 18, 29 }, { 24, 29 } }, POOL[5])
c:eyeSmall(11, 15)
c:eyeSmall(21, 15)
O.dots(c, { { 10, 14 }, { 11, 13 }, { 12, 13 }, { 13, 14 }, { 20, 14 }, { 21, 13 }, { 22, 13 }, { 23, 14 } }, TOAD[1])
O.dots(c, { { 8, 20 }, { 25, 20 } }, "#f5809f")
O.dots(c, { { 10, 20 }, { 11, 21 }, { 12, 21 }, { 13, 21 }, { 14, 21 }, { 15, 21 }, { 16, 21 }, { 17, 21 }, { 18, 21 }, { 19, 21 }, { 20, 21 }, { 21, 21 }, { 22, 21 }, { 23, 20 } }, P.ink)
-- note
O.shade(c, c:ellipse(28, 10, 1.5, 1), GOLD, { R = 1, amb = .4, sep = GOLD[1] })
O.flat(c, c:rect(29, 4, 29, 10), GOLD[3], "stem")
O.flat(c, c:line({ { 30, 5 }, { 31, 6 }, { 31, 8 } }, 1), GOLD[4], "flag")
O.shift(c, 0, -1)
O.done(c, "pl-frt-2-perch")
