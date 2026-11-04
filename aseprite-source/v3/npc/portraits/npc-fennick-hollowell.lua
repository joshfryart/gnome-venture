-- npc-fennick-hollowell portrait (npc2 P1_10) species: garden snail
-- Same snail as the sprite: tan body, brown spiral shell behind the right shoulder, eye stalks through the brim
-- of a crooked blue pointy hat with a gold band; prop: gold bell on the hat tip.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-fennick-hollowell"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
-- shell
local shell = c:ellipse(60, 70, 15, 16)
c:part(shell, "wood", { band = 3, pop = { 52, 59 } })
local pts = {}
for i = 0, 50 do local t = i / 50 local a = math.rad(200 + t * 560) local r = 13 * (1 - t * 0.85)
  pts[#pts + 1] = { 61 + math.cos(a) * r, 71 + math.sin(a) * r } end
c:fillMask(c:line(pts, 1):clip(shell:shrink(1)), P.wood.deep)
-- body + neck
local body = c:ellipse(39.5, 108, 28, 26):clip(c:rect(0, 0, 79, 99))
body:add(c:rrect(25, 62, 54, 99, 8))
c:part(body, "skinA", { band = 3, sep = true })
-- head
local head = c:ellipse(39.5, 59, 20, 14)
c:part(head, "skinA", { band = 3, sep = true, pop = { 25, 53 } })
-- muzzle + nose + smile
c:part(c:ellipse(39.5, 64, 8, 4.5), CR, { band = 1, nopop = true })
c:part(c:rrect(37, 59, 42, 61, 1), "wood", { band = 1, pop = { 38, 59 } })
for x = 35, 44 do c:put(x, 67, P.ink) end c:put(34, 66, P.ink) c:put(45, 66, P.ink)
c:cheek(25, 62) c:cheek(53, 62)
-- cord collar with bead
c:fillMask(c:line({ { 27, 78 }, { 39.5, 82 }, { 52, 78 } }, 1), P.sea.deep)
c:part(c:ellipse(39.5, 83, 2, 2), "gold", { band = 1 })
-- hat
local hat = c:ellipse(39.5, 45, 25.5, 4.5)
hat:add(c:poly{ { 24, 45 }, { 55, 45 }, { 44, 19 }, { 39, 12 } })
hat:add(c:line({ { 40, 13 }, { 36, 7 }, { 30, 5 } }, 3))
c:part(hat, "sea", { band = 3, pop = { 36, 25 } })
for x = 13, 66 do if hat:has(x, 48) and not hat:has(x, 49) then c:put(x, 48, P.sea.deep) end end
c:stitch{ { 25, 42 }, { 32, 43 }, { 39, 43 }, { 47, 43 }, { 54, 42 } }
c:put(43, 26, P.sea.shade) c:put(43, 27, P.sea.shade) c:put(42, 28, P.sea.shade)
c:part(c:ellipse(28.5, 7, 2.5, 2.5), "gold", { band = 1 })
-- eye stalks
c:part(c:line({ { 31, 52 }, { 25, 33 } }, 2), "skinA", { band = 1, nopop = true, sep = true })
c:part(c:line({ { 48, 52 }, { 54, 33 } }, 2), "skinA", { band = 1, nopop = true, sep = true })
for _, e in ipairs{ { 24, 30 }, { 55, 30 } } do
  c:part(c:ellipse(e[1] + 0.5, e[2] + 0.5, 4.5, 4.5), "skinA", { band = 1, nopop = true, sep = true })
  c:eyeLocked(e[1] - 2, e[2] - 2)
end
c:finish{ outline = true }
backdrop(P.moss)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
