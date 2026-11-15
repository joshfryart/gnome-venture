-- tower.lua : "Watchtower" stop look, Maplewold style (480x270 gate view). Haiku first pass.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/haiku/"
local F = dofile(DIR .. "_frame.lua").build{ name = "tower", out = DIR }
local c, L, part, rect, px, rimOf, hline, vline = F.c, F.L, F.part, F.rect, F.px, F.rimOf, F.hline, F.vline

-- the tower: a tall stone shaft at the road's end
local shaft = rect(218, 56, 262, 128)
rimOf(shaft, L.stone)
part(shaft, L.stone, { sep = true })
F.courses(shaft, 56, 6, 9, L.stone)
F.shadow(228, 262, 128, 10, 5)
-- battlements on top of the shaft
for x = 218, 258, 8 do
  local tooth = rect(x, 48, x + 3, 55)
  rimOf(tooth, L.stone) part(tooth, L.stone, { nopop = true })
end
-- windows up the shaft (glow for the watch)
F.window(232, 70, 238, 77, L.timber)
F.window(242, 92, 248, 99, L.timber)
F.window(226, 108, 232, 115, L.timber)
-- the door at the foot of the road
F.door(232, 110, 248, 128, L.timber, true)

-- the timber platform and rail
local deck = rect(212, 40, 268, 48)
rimOf(deck, L.timber) part(deck, L.timber, { band = 2 })
hline(212, 268, 40, L.timber.hi)
for x = 212, 268, 6 do vline(x, 32, 40, L.timber.base) end
hline(212, 268, 32, L.timber.shade)

-- the beacon basket with a fire in it
local basket = c:poly{ { 230, 30 }, { 250, 30 }, { 246, 24 }, { 234, 24 } }
rimOf(basket, L.timber) part(basket, L.timber, { nopop = true })
local flame = c:poly{ { 234, 24 }, { 240, 10 }, { 246, 24 } }
rimOf(flame, L.foliage) part(flame, L.foliage, { nopop = true })
local core = c:poly{ { 237, 24 }, { 240, 16 }, { 243, 24 } }
c:fillMask(core, L.glow.hi)
-- a flag for the wind
part(c:line({ { 258, 40 }, { 258, 14 } }, 1), L.timber, { nopop = true, noshade = true })
local flag = c:poly{ { 258, 14 }, { 268, 17 }, { 258, 20 } }
rimOf(flag, L.awnA) part(flag, L.awnA, { nopop = true })

-- a cabin at the foot, left of the road
F.building{ x0 = 52, x1 = 118, yb = 168, wh = 28, rh = 18, wall = L.plaster, roof = L.roof }
F.door(80, 142, 92, 168, L.timber, false)
F.window(60, 148, 66, 155, L.timber)

-- a signpost with two arrows on the right
F.sign(440, 140, 34, 14)
F.tree(170, 150, 28, 12)
F.tree(356, 136, 26, 13)

F.finish()
