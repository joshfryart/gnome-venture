-- npc-quill-brambleby portrait (npc2 P1_31) species: field mouse
-- 80x100 head-and-shoulders, bleeds off the bottom. Golden field mouse, round pink-lined ears, buck teeth,
-- red smock with leaf-garland collar, holding a fat blackberry. Backdrop: moss disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-quill-brambleby"
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local FUR = P.gold
local MUZ = { hi = P.cream, base = P.gold.hi, shade = P.gold.base, deep = P.gold.shade }
-- smock
local body = c:ellipse(39.5, 106, 29, 33):clip(c:rect(0, 70, 79, 99))
c:part(body, "ember", { band = 3, pop = { x = 18, y = 84 } })
c:stitch{ {14,96},{24,99} }
c:button(39, 84) c:button(39, 93)
-- leaf garland collar
for i = 0, 7 do local x = 26 + i * 4
  c:part(c:ellipse(x, 73 + ((i == 0 or i == 7) and 0 or (i == 1 or i == 6) and 1 or 2), 2.2, 1.3), "moss", { band = 1, nopop = i % 2 == 1 }) end
-- blackberry held up at lower right, paw under it
c:fillMask(c:line({ {58,79},{61,74} }, 1), P.wood.shade)
local berry = c:ellipse(57, 86, 6.5, 6.5)
c:part(berry, "dusk", { band = 2, nopop = true })
berry:shrink(1):each(function(x, y) if (x + y) % 3 == 0 and (x - y) % 2 == 0 then
  c:put(x, y, (x < 58 and y < 86) and P.dusk.hi or P.dusk.deep) end end)
berry:shrink(1):each(function(x, y) if (x + y) % 3 == 1 and (x - y) % 2 == 1 and x < 57 and y < 85 then c:put(x, y, P.dusk.base) end end)
c:paint({ "m...m", ".mMm.", "..M.." }, 55, 78, { m = "moss.base", M = "moss.shade" })
c:part(c:ellipse(51, 93, 4.5, 3.5), FUR, { band = 1, pop = { x = 48, y = 91 } })
-- ears
c:part(c:ellipse(20.5, 27, 9.5, 9.5), FUR, { band = 2, pop = { x = 15, y = 22 } })
c:part(c:ellipse(58.5, 27, 9.5, 9.5), FUR, { band = 2 })
c:part(c:ellipse(21.5, 28.5, 5.5, 5.5), "petal", { band = 2, pop = { x = 18, y = 26 } })
c:part(c:ellipse(57.5, 28.5, 5.5, 5.5), "petal", { band = 2, nopop = true })
-- head with cheek fluff and a forehead tuft
local head = c:ellipse(39.5, 47, 20.5, 17)
for _, q in ipairs{ {19,52},{20,56},{59,52},{58,56} } do head:add(c:ellipse(q[1], q[2], 2, 2)) end
head:add(c:poly{ {36,31},{38,26},{40,30},{43,27},{43,32} })
c:part(head, FUR, { band = 3, pop = { x = 27, y = 36 } })
for _, q in ipairs{ {28,34},{29,33},{33,32},{34,31},{46,32},{47,33} } do c:put(q[1], q[2], P.gold.hi) end
for _, q in ipairs{ {24,40},{25,41},{54,44},{55,45},{30,61},{49,60} } do c:put(q[1], q[2], P.gold.shade) end
c:part(c:ellipse(39.5, 57, 10.5, 6.5), MUZ, { band = 2, pop = { x = 32, y = 53 } })
-- nose: pink button with glint and a shade underside
local nose = c:ellipse(39.5, 52.5, 3.5, 2.5)
c:part(nose, "petal", { band = 1, pop = { x = 37, y = 51 } })
c:paint({ ".....ii.....", "..i..ii..i..", "...iiDDii...", "....iCCi....", ".....ii....." }, 34, 55,
  { i = "ink", D = "ember.deep", C = "cream" })
c:eyeLocked(28, 43) c:eyeLocked(47, 43)
c:paint({ "PPP", "PPP" }, 23, 53, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 54, 53, { P = "petal.base" })
c:put(23, 53, P.petal.hi) c:put(54, 53, P.petal.hi)
c:finish{ outline = true }
-- whiskers
c:fillMask(c:line({ {29,56},{14,53} }, 1), P.wood.deep) c:fillMask(c:line({ {29,58},{14,60} }, 1), P.wood.deep)
c:fillMask(c:line({ {50,56},{65,53} }, 1), P.wood.deep) c:fillMask(c:line({ {50,58},{65,60} }, 1), P.wood.deep)
backdrop(c, P.moss)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
