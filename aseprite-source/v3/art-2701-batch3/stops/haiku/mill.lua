-- mill.lua : "Old mill" stop look, Maplewold style (480x270 gate view). Haiku first pass.
--   /home/user/.../aseprite -b --script mill.lua   (writes mill.aseprite + mill.png next to this file)
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/haiku/"
local F = dofile(DIR .. "_frame.lua").build{ name = "mill", out = DIR }
local c, L, part, rect, px, rimOf, hline, vline = F.c, F.L, F.part, F.rect, F.px, F.rimOf, F.hline, F.vline

-- stream by the mill, bottom-right under the wheel
F.pond(c:poly{ { 352, 226 }, { 462, 218 }, { 462, 262 }, { 340, 262 } })
F.pond(c:poly{ { 18, 232 }, { 102, 226 }, { 110, 250 }, { 92, 262 }, { 18, 262 } })

-- the mill house: plaster walls, thatch roof
F.building{ x0 = 320, x1 = 412, yb = 166, wh = 46, rh = 22, wall = L.plaster }
F.door(366, 138, 378, 166, L.timber, false)
F.window(338, 130, 344, 137, L.timber)
F.window(392, 130, 398, 137, L.timber)

-- the great wheel on the mill's end wall
local hub = { 440, 178 }
local outer = c:ellipse(hub[1], hub[2], 17, 25)
local inner = c:ellipse(hub[1], hub[2], 12, 20)
local ring = outer:copy():cut(inner)
rimOf(outer, L.timber)
part(ring, L.timber, { nopop = true })
local spokes = F.HP.mask()
for i = 0, 5 do
  local a = i / 6 * math.pi * 2
  spokes:add(c:line({ { hub[1], hub[2] }, { hub[1] + math.cos(a) * 13, hub[2] + math.sin(a) * 21 } }, 1))
end
part(spokes, L.timber, { nopop = true, noshade = true })
-- buckets along the rim
for i = 0, 3 do
  local a = i / 4 * math.pi * 2 + .4
  local bx, by = math.floor(hub[1] + math.cos(a) * 16), math.floor(hub[2] + math.sin(a) * 24)
  part(rect(bx - 2, by - 1, bx + 2, by + 2), L.roof, { nopop = true })
end
c:fillMask(rect(hub[1] - 2, hub[2] - 2, hub[1] + 2, hub[2] + 2), L.timber.hi)

-- flour sacks by the door
for _, s in ipairs({ { 306, 204 }, { 316, 206 }, { 310, 196 } }) do
  local sack = c:ellipse(s[1], s[2], 6, 5)
  rimOf(sack, L.plaster) part(sack, L.plaster)
end
-- tall hopper pipe from the wheel to the house
part(c:line({ { 428, 146 }, { 412, 150 } }, 2), L.timber, { nopop = true })

-- a sign, a hand cart of sacks and a tree on the left
F.sign(92, 138, 30, 14)
local bed = rect(124, 184, 152, 194)
rimOf(bed, L.timber) part(bed, L.board, { sep = true })
for _, wx in ipairs({ 130, 148 }) do
  local wheel = c:ellipse(wx, 198, 4, 4)
  rimOf(wheel, L.timber) part(wheel, L.timber, { nopop = true })
end
for k = 0, 2 do F.speckle(rect(126 + k * 9, 183, 132 + k * 9, 184), L.plaster, .5, 70 + k) end
F.tree(44, 152, 30, 3)
F.tree(150, 136, 26, 4)

F.finish()
