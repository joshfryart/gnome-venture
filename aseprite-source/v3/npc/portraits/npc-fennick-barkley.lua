-- npc-fennick-barkley portrait (npc2 P1_10) species: frog
-- Same frog as the sprite: red knitted hood with peak, purple smock, gold bead collar, steaming bark-tea mug.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-fennick-barkley"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local PALE = { hi = P.cream, base = P.moss.hi, shade = P.moss.base, deep = P.moss.shade }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
-- smock
local body = c:ellipse(39.5, 106, 31, 26):clip(c:rect(0, 0, 79, 99))
c:part(body, "dusk", { band = 3 })
for _, x in ipairs{ 22, 30, 50, 58 } do c:put(x, 92, P.dusk.shade) c:put(x, 93, P.dusk.shade) end
-- hood with peak and shoulder flaps
local hood = c:ellipse(39.5, 50, 24.5, 21)
hood:add(c:poly{ { 33, 31 }, { 46, 31 }, { 41, 22 }, { 38, 22 } })
hood:add(c:rrect(14, 52, 25, 84, 4)) hood:add(c:rrect(54, 52, 65, 84, 4))
c:part(hood, "ember", { band = 3, pop = { 22, 36 } })
for y = 58, 80, 4 do c:put(18, y, P.ember.shade) c:put(19, y, P.ember.shade) c:put(59, y, P.ember.deep) c:put(60, y, P.ember.deep) end
c:put(39, 23, P.ember.hi)
-- head
local head = c:ellipse(39.5, 56, 20, 14)
c:part(head, "moss", { band = 3, pop = { 25, 49 } })
c:part(c:ellipse(39.5, 66, 11, 4):clip(head), PALE, { band = 1, nopop = true, inner = false })
for _, ex in ipairs{ 28.5, 50.5 } do c:part(c:ellipse(ex, 43, 7, 6), "moss", { band = 2, sep = true, nopop = true }) end
c:put(25, 40, P.moss.hi) c:put(26, 39, P.moss.hi) c:put(47, 40, P.moss.hi) c:put(48, 39, P.moss.hi)
c:eyeLocked(26, 41) c:eyeLocked(48, 41)
-- snout ridge + nostrils
for x = 36, 43 do c:put(x, 52, P.moss.hi) end
c:put(36, 54, P.ink) c:put(43, 54, P.ink) c:put(37, 54, P.moss.deep) c:put(42, 54, P.moss.deep)
-- wide mouth
for x = 24, 55 do c:put(x, 61, P.ink) end
c:put(23, 60, P.ink) c:put(56, 60, P.ink) c:put(38, 62, P.moss.shade) c:put(41, 62, P.moss.shade)
c:cheek(23, 57) c:cheek(55, 57)
-- bead collar
c:stitch{ { 26, 78 }, { 32, 81 }, { 39, 82 }, { 47, 81 }, { 53, 78 } }
-- mug prop
local mug = c:rrect(54, 74, 64, 89, 2)
c:part(mug, "wood", { band = 2 })
for y = 77, 85 do c:put(65, y, P.wood.shade) c:put(66, y, P.wood.shade) end
for _, y in ipairs{ 77, 85 } do c:put(67, y, P.wood.deep) end for y = 78, 84 do c:put(68, y, P.wood.deep) end
for x = 55, 63 do c:put(x, 81, P.wood.deep) end for x = 56, 62, 3 do c:put(x, 85, P.wood.shade) end
c:part(c:rect(55, 74, 63, 76), CR, { band = 1, nopop = true })
c:part(c:ellipse(54.5, 84, 3.5, 3), "moss", { band = 1, sep = true, nopop = true })
c:finish{ outline = true }
for _, q in ipairs{ { 58, 71 }, { 59, 70 }, { 58, 69 }, { 59, 68 }, { 61, 72 }, { 62, 71 } } do c:put(q[1], q[2], P.stone.hi) end
backdrop(P.petal)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
