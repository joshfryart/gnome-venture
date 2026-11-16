-- ferry.lua : "Ferry" stop look, Maplewold (480x270 gate view). Haiku first pass (art-2701 batch 4).
-- Uses the opus3 shared frame read-only (palette, sky, hills, horizon y=112, road, gate).
-- The road ends at a river. Landmark: a shingled ferry house with a lantern pole on the far bank.
-- Set pieces: the flat ferry boat tied to a post on the river, the wooden landing and rope drum.
-- Gnomes: the ferryman poling the boat, a small gnome on the far bank.
-- Joke: a hen in a tiny hat riding the boat as a passenger.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch4/stops/haiku/"
local F = dofile("/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/opus3/_frame.lua")
  .build{ name = "ferry", out = DIR, farTrees = { 22, 46, 104, 250, 420, 452 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union

-- back row: a tall reed bank and a far cottage
F.depth(1)
F.building{ x0 = 300, x1 = 340, yb = 122, wh = 12, rh = 9, wall = L.plaster, roof = L.roof, noFrame = true, noAttic = true }
F.tree(70, 118, 24, 9, true)
F.tree(452, 118, 20, 8, true)

-- the river: a wavy band from the road's end down, the road drops into it
local river = poly{ { 0, 138 }, { 90, 134 }, { 200, 138 }, { 262, 136 }, { 360, 140 }, { 480, 136 },
  { 480, 190 }, { 380, 186 }, { 250, 196 }, { 120, 188 }, { 0, 194 } }
F.depth(2)
F.water(river, L.water, { step = 3 })
-- far-bank reeds in the water's upper edge
for x = 20, 180, 16 do vline(x, 128, 136, L.leaf.shade) px(x, 127, L.leaf.hi) px(x + 1, 127, L.leaf.base) end

-- landmark at the road's end: the ferry house with its lantern pole
F.smoke(246, 60, 4, .5, 2)
F.building{ x0 = 214, x1 = 262, yb = 136, wh = 24, rh = 16, wall = L.wall2, roof = L.roof2, chimney = true, shingle = true }
F.door(230, 120, 242, 136, L.timber, false)
F.window(218, 122, 224, 129, L.timber)
F.window(248, 122, 254, 129, L.timber)
vline(270, 100, 136, L.timber.base) vline(271, 100, 136, L.timber.hi)
local lamp = c:ellipse(270, 98, 3, 3)
rimOf(lamp, L.timber) part(lamp, L.glow, { nopop = true })
px(269, 97, L.glow.hi)

-- set piece 1: the ferry boat tied to a mooring post by a rope
F.depth(3)
local hull = poly{ { 300, 170 }, { 398, 170 }, { 388, 184 }, { 310, 184 } }
rimOf(hull, L.board) part(hull, L.board, { sep = true })
c:edgeIn(hull, L.board.deep)
F.planks(hull, L.board, 6, false, 3)
hline(302, 396, 168, L.timber.deep)
hline(300, 398, 170, L.board.hi)
vline(300, 160, 170, L.timber.base) vline(398, 160, 170, L.timber.base) hline(300, 398, 160, L.timber.base)
line({ { 232, 176 }, { 300, 176 } }, 1):each(function(x, y) px(x, y, L.timber.deep) end)
F.barrel(340, 168, L.board, 4)

-- ferryman with a long pole, and the joke: a hen in a tiny hat as a passenger
F.gnome(336, 170, { hat = L.awnA, coat = L.accent, arm = "out", flip = true })
line({ { 350, 170 }, { 372, 196 } }, 2):each(function(x, y) px(x, y, L.timber.base) end)
F.hen(372, 170, L.awnB, false)
px(369, 157, L.awnA.base) px(370, 157, L.awnA.base) px(369, 158, L.awnA.shade)

-- set piece 2: the wooden landing on the near bank, a mooring post and a rope drum
local landing = rect(120, 196, 206, 204)
rimOf(landing, L.timber) part(landing, L.board, { sep = true })
F.planks(landing, L.board, 7, false, 9)
local drum = c:ellipse(170, 194, 5, 3)
rimOf(drum, L.timber) part(drum, L.timber, { nopop = true })
vline(170, 178, 192, L.timber.base) hline(164, 176, 186, L.timber.deep)

-- near bank: a far gnome fishing and a bush and rocks
F.depth(2)
F.gnomeSmall(408, 146, { hat = L.roof, coat = L.lav, flip = true })
F.depth(3)
F.bush(440, 220, 26, 16, L.leaf, 17)
F.rock(88, 244, 10, 6)
F.rock(104, 250, 6, 4)
F.fence(8, 58, 240, 8)

F.birds({ { 120, 70, 2 }, { 360, 84, 3 } })
F.finish()
