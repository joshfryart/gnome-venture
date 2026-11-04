-- npc-hazel-dewberry portrait (npc2 P1_14) species: frog
-- 80x100 head+shoulders: wide green frog, eye domes poking out under a straw boater (petal band, dewberry pin),
-- raised snout with nostril slits, wide smile, red dress + cream bib apron. prop: dewberry basket lower right. backdrop petal.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-hazel-dewberry"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local CR = { hi = P.cream, base = "#f3e6c8", shade = P.stone.hi, deep = P.stone.base }
local THR = { hi = P.cream, base = P.moss.hi, shade = P.moss.base, deep = P.moss.shade }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
-- shoulders: red dress
local body = c:ellipse(39.5, 104, 32, 28):clip(c:rect(0, 76, 79, 99))
c:part(body, P.ember, { band = 3, pop = { x = 16, y = 86 } })
-- bib apron
local bib = c:rrect(30, 82, 49, 99, 3)
c:part(bib, CR, { band = 2, nopop = true })
c:part(c:line({ {32,83},{29,77} }, 2), CR, { band = 1, nopop = true })
c:part(c:line({ {47,83},{50,77} }, 2), CR, { band = 1, nopop = true })
c:part(c:rrect(34, 91, 45, 97, 2), CR, { band = 1, nopop = true })
c:stitch{ {35,92},{44,92} }
c:stitch{ {32,84},{47,84} }
-- head
local head = c:ellipse(39.5, 58, 21, 14)
c:part(head, P.moss, { band = 3, pop = { x = 24, y = 50 } })
c:part(c:ellipse(39.5, 68, 12, 4.5):clip(head), THR, { band = 2, nopop = true, inner = false })
for _, q in ipairs{ {21,58},{56,55},{54,63},{24,67} } do for dx = 0, 1 do for dy = 0, 1 do c:put(q[1]+dx, q[2]+dy, P.moss.shade, true) end end end
-- raised snout with nostril slits
local sn = c:ellipse(39.5, 54, 5, 2)
sn:each(function(x, y) if not sn:has(x, y - 1) then c:put(x, y, P.moss.hi, true) elseif not sn:has(x, y + 1) then c:put(x, y, P.moss.shade, true) end end)
for _, x in ipairs{ 36, 37, 42, 43 } do c:put(x, 55, P.moss.deep, true) end
-- wide smile
for x = 22, 57 do c:put(x, 62 + math.floor(2 * (1 - ((x - 39.5) / 17.5) ^ 2) + .5), P.ink, true) end
c:put(21, 61, P.ink, true) c:put(58, 61, P.ink, true)
c:paint({ "PPP", "PPP" }, 23, 64, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 54, 64, { P = "petal.base" })
c:put(23, 64, P.petal.hi) c:put(54, 64, P.petal.hi)
-- straw boater
local brim = c:ellipse(39.5, 36, 23, 4.5)
c:part(brim, P.gold, { band = 2, pop = { x = 20, y = 34 } })
local crown = c:rrect(27, 19, 52, 35, 5)
c:part(crown, P.gold, { band = 2, pop = { x = 30, y = 22 } })
brim:copy():cut(crown):add(crown):each(function(x, y) if (x * 2 + y) % 5 == 0 and c:get(x, y) == P.gold.base then c:put(x, y, P.gold.shade, true) end end)
c:part(c:rect(27, 30, 52, 33):clip(crown), P.petal, { band = 1, nopop = true })
c:part(c:ellipse(47, 31, 1.5, 1.5), P.dusk, { band = 1, nopop = true })
c:put(46, 30, P.dusk.hi, true)
-- eye domes in front of the brim
for _, ex in ipairs{ 28, 51 } do c:part(c:ellipse(ex, 42, 7, 6), P.moss, { band = 2, pop = { x = ex - 5, y = 38 } }) end
for _, ex in ipairs{ 26, 49 } do c:eyeLocked(ex, 41) for i = 0, 4 do c:put(ex + i, 40, P.moss.deep, true) end end
-- dewberry basket (prop) lower right
c:part(c:line({ {57,81},{58,74},{63,70},{68,74},{70,81} }, 2), P.wood, { band = 1, nopop = true })
for _, q in ipairs{ {59,79},{63,78},{67,79},{61,81},{65,81},{70,80} } do
  c:part(c:ellipse(q[1], q[2], 2, 2), P.dusk, { band = 1, nopop = true, sep = true })
  c:put(q[1] - 1, q[2] - 1, P.dusk.hi, true)
end
c:part(c:poly{ {71,79},{77,74},{78,78},{74,82} }, P.moss, { band = 1, nopop = true })
local bk = c:rrect(54, 82, 74, 96, 3)
c:part(bk, P.wood, { band = 2, nopop = true })
bk:each(function(x, y) if y > 84 and ((x + (y // 2) * 2) % 4 < 2) and c:get(x, y) == P.wood.base then c:put(x, y, P.wood.shade, true) end end)
c:part(c:rrect(53, 81, 75, 84, 1), P.wood, { band = 1, pop = { x = 56, y = 82 } })
c:part(c:ellipse(55, 88, 3, 3), P.moss, { band = 1, pop = { x = 53, y = 86 } })
c:finish{ outline = true }
backdrop(P.petal)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
