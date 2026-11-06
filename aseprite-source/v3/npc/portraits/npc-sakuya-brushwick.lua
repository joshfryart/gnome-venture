-- npc-sakuya-brushwick portrait (npc2 P1_33) species: frog
-- 80x100 head+shoulders, ember backdrop disc. Same design as the sprite: wide straw kasa, grumpy lidded bulging eyes,
-- plum haori + cream belly + ember sash, ink brush raised in hand, ink smudge on the cheek.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-sakuya-brushwick"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local FROG = { hi = "#b6d86a", base = "#7cae44", shade = "#4f8048", deep = "#355a44" }
local BELLY = { hi = P.cream, base = "#f0dca0", shade = "#c8ad7c", deep = "#94786a" }
local STRAW = { hi = "#f2d690", base = "#d6aa5a", shade = "#a87844", deep = "#6e4c40" }
local BRISTLE = { hi = "#6e5a78", base = "#4c3c58", shade = "#3a2c46", deep = "#2f2238" }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local function inked(m) c:fillMask(m:copy():grow(1), P.ink) end
-- haori
local body = c:ellipse(39.5, 108, 31, 32):clip(c:rect(0, 76, 79, 99))
c:part(body, P.dusk, { band = 3, pop = { x = 16, y = 88 } })
local v = c:poly{ { 31, 76 }, { 48, 76 }, { 41, 93 }, { 38, 93 } }:clip(body)
c:part(v, BELLY, { band = 1, nopop = true })
c:fillMask(c:line({ { 31, 76 }, { 38, 93 } }, 2), P.dusk.hi)
c:fillMask(c:line({ { 48, 76 }, { 41, 93 } }, 2), P.dusk.hi)
c:part(c:rect(0, 93, 79, 96):clip(body), P.ember, { band = 1, nopop = true })
c:part(c:rect(36, 92, 43, 97), P.ember, { band = 1, pop = { x = 36, y = 92 } })
-- prop: ink brush raised in the left hand
local hd = c:line({ { 19, 92 }, { 12, 62 } }, 3)
inked(hd) c:part(hd, P.wood, { band = 1, nopop = true })
for _, y in ipairs{ 68, 76, 84 } do c:line({ { 10, y }, { 22, y + 1 } }, 1):clip(hd):each(function(x, yy) c:put(x, yy, P.wood.deep) end) end
local fe = c:rect(9, 58, 14, 61)
inked(fe) c:part(fe, P.stone, { band = 1, pop = { x = 9, y = 58 } })
local br = c:poly{ { 9, 57 }, { 14, 57 }, { 13, 52 }, { 11.5, 46 }, { 10, 52 } }
inked(br) c:part(br, BRISTLE, { band = 1, pop = { x = 10, y = 53 } })
c:put(11, 47, BRISTLE.deep) c:put(12, 48, BRISTLE.deep)
local hand = c:ellipse(18, 86, 3.5, 3)
for _, q in ipairs{ { 15, 84 }, { 21, 84 }, { 15, 88 } } do hand:add(HP.ellipse(q[1], q[2], 1.3, 1.3)) end
inked(hand) c:part(hand, FROG, { band = 1, pop = { x = 16, y = 84 } })
-- head
local head = c:ellipse(39.5, 58, 21, 13.5)
head:add(c:ellipse(28, 47, 7, 6)) head:add(c:ellipse(51, 47, 7, 6))
c:part(head, FROG, { band = 3, pop = { x = 24, y = 46 } })
c:part(c:ellipse(39.5, 70, 16, 6):clip(head), BELLY, { band = 1, nopop = true })
for _, q in ipairs{ { 24, 58, 1.5 }, { 22, 62, 1 }, { 56, 56, 1.2 }, { 58, 61, 1 }, { 33, 52, 1 } } do
  HP.ellipse(q[1], q[2], q[3], q[3]):clip(head):each(function(x, y) c:put(x, y, FROG.shade) end)
end
local sn = c:ellipse(39.5, 55, 6, 3)
c:part(sn, FROG, { band = 1, pop = { x = 36, y = 53 } })
c:put(36, 56, P.ink) c:put(43, 56, P.ink)
c:fillMask(c:line({ { 21, 64 }, { 25, 62 }, { 54, 62 }, { 58, 64 } }, 1), P.ink)
c:paint({ "BBB", ".BB" }, 52, 60, { B = "dusk.deep" })
c:put(52, 60, BRISTLE.base) c:put(53, 60, BRISTLE.base) c:put(54, 60, BRISTLE.base) c:put(53, 61, BRISTLE.base) c:put(54, 61, BRISTLE.shade)
-- kasa
local hm = c:ellipse(39.5, 38, 29, 5.5)
local cone = c:poly{ { 14, 38 }, { 65, 38 }, { 39.5, 10 } } cone:add(c:ellipse(39.5, 10.5, 2, 2))
hm:add(cone)
c:part(hm, STRAW, { band = 3, pop = { x = 31, y = 22 } })
local inner = hm:copy():shrink(1)
for _, bx in ipairs{ 14, 22, 30, 38, 46, 54, 62 } do
  c:line({ { 39.5, 13 }, { bx, 42 } }, 1):clip(inner):each(function(x, y) if (x + y) % 2 == 0 then c:put(x, y, STRAW.shade) end end)
end
c:fillMask(c:line({ { 18, 35 }, { 39.5, 37 }, { 61, 35 } }, 2):clip(inner), P.ember.base)
hm:each(function(x, y) if not hm:has(x, y + 1) then c:put(x, y, STRAW.deep)
  for k = 1, 2 do if head:has(x, y + k) and not hm:has(x, y + k) then c:put(x, y + k, FROG.shade) end end end end)
-- eyes + grumpy lids
c:eyeLocked(26, 46) c:eyeLocked(49, 46)
for _, q in ipairs{ { 24, 44 }, { 25, 44 }, { 26, 45 }, { 27, 45 }, { 28, 45 }, { 29, 45 }, { 30, 45 }, { 31, 46 } } do
  c:put(q[1], q[2], FROG.deep) c:put(79 - q[1], q[2], FROG.deep)
end
c:finish{ outline = true }
backdrop(P.ember)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
