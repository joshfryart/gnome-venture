-- npc-clover-thornwhistle portrait (npc2 P1_7) species: garden snail
-- Same design as the sprite: eyes on stalks (locked eyes on the tips), snout pad on a cream muzzle,
-- straw sun-hat with red band + clover sprig, violet poncho, red collar, spiral shell, thorn whistle.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-clover-thornwhistle"
local SKIN  = { hi = "#f6d9a2", base = "#dcaa6c", shade = "#a8744f", deep = "#6b4436" }
local SHELL = { hi = "#d9935a", base = "#a85f3a", shade = "#74393a", deep = "#4a2433" }
local MUZ   = { hi = P.cream, base = "#f7e3bc", shade = "#e0bf94", deep = "#a8744f" }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
-- shell behind right shoulder
local sh = c:ellipse(61, 68, 15, 15)
c:part(sh, SHELL, { band = 3, pop = { x = 52, y = 58 } })
c:fillMask(c:ellipse(62, 69, 10, 10):edge():cut(c:rect(52, 58, 62, 69)):clip(sh:shrink(1)), SHELL.deep)
c:fillMask(c:ellipse(63, 70, 5.5, 5.5):edge():clip(sh:shrink(1)), SHELL.shade)
c:fillMask(c:ellipse(63.5, 70.5, 2, 2):edge(), SHELL.deep)
-- poncho + collar
local pon = c:ellipse(39.5, 108, 33, 30):clip(c:rect(0, 0, 79, 99))
c:part(pon, P.dusk, { band = 3, pop = { x = 14, y = 88 } })
c:stitch{ { 12, 95 }, { 26, 86 }, { 53, 86 }, { 67, 95 } }
c:part(c:ellipse(39.5, 79, 15, 4), P.ember, { band = 1, pop = { x = 28, y = 77 } })
-- thorn whistle on a cord
c:fillMask(c:line({ { 33, 82 }, { 37, 88 } }, 1), SHELL.deep) c:fillMask(c:line({ { 46, 82 }, { 43, 88 } }, 1), SHELL.deep)
c:part(c:rrect(34, 88, 47, 92, 2), P.wood, { band = 1, pop = { x = 37, y = 88 } })
c:fillMask(c:rect(34, 89, 35, 91), P.cream) c:put(41, 90, P.ink) c:put(42, 90, P.ink)
c:part(c:poly{ { 47, 88 }, { 51, 86 }, { 48, 90 } }, P.moss, { band = 1, nopop = true })
-- eyestalks + eyeballs
c:part(c:line({ { 28, 42 }, { 23, 28 }, { 20, 18 } }, 3), SKIN, { band = 1, nopop = true })
c:part(c:line({ { 51, 42 }, { 56, 28 }, { 59, 18 } }, 3), SKIN, { band = 1, nopop = true })
c:part(c:ellipse(19.5, 14.5, 4.5, 4.5), SKIN, { band = 1, nopop = true })
c:part(c:ellipse(59.5, 14.5, 4.5, 4.5), SKIN, { band = 1, nopop = true })
c:eyeLocked(17, 12) c:eyeLocked(57, 12)
-- head
local head = c:ellipse(39.5, 55, 20, 16)
c:part(head, SKIN, { band = 3, pop = { x = 25, y = 46 } })
c:part(c:ellipse(39.5, 62, 11, 7), MUZ, { band = 2, pop = { x = 32, y = 57 } })
-- snout pad with nostrils, gentle smile
c:part(c:ellipse(39.5, 57.5, 4.5, 2.5), SKIN, { band = 1, pop = { x = 37, y = 56 } })
c:put(37, 58, SKIN.deep) c:put(42, 58, SKIN.deep)
c:paint({ "i.....i", ".i...i.", "..iii.." }, 36, 62, { i = "ink" })
c:paint({ "PPP", "PPP" }, 23, 59, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 54, 59, { P = "petal.base" })
c:put(23, 59, P.petal.hi) c:put(54, 59, P.petal.hi)
-- straw sun-hat
local hat = c:ellipse(39.5, 41, 22, 5)
hat:add(c:poly{ { 27, 41 }, { 52, 41 }, { 43, 24 }, { 36, 24 } }):add(c:ellipse(39.5, 24.5, 3.5, 2))
c:part(hat, P.gold, { band = 2, pop = { x = 33, y = 30 } })
for x = 18, 61 do if hat:has(x, 44) and x % 3 == 0 then c:put(x, 44, P.gold.shade) end end
for _, s in ipairs{ { 35, 27, 34, 34 }, { 44, 27, 46, 34 } } do
  c:line({ { s[1], s[2] }, { s[3], s[4] } }, 1):clip(hat):each(function(x, y) if c:get(x, y) == P.gold.base then c:put(x, y, P.gold.shade) end end)
end
c:rect(28, 37, 51, 39):clip(hat):each(function(x, y) c:put(x, y, y == 39 and P.ember.shade or (y == 37 and P.ember.hi or P.ember.base)) end)
for _, q in ipairs{ { 29, 34 }, { 33, 34 }, { 31, 31 } } do c:part(c:ellipse(q[1], q[2], 2, 2), P.moss, { band = 1, pop = { x = q[1] - 1, y = q[2] - 1 } }) end
c:fillMask(c:line({ { 31, 35 }, { 30, 38 } }, 1), P.moss.deep)
c:finish{ outline = true }
backdrop(P.moss)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
