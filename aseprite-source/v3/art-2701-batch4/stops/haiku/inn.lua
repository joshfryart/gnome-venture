-- inn.lua : "Inn" stop look, Maplewold (480x270 gate view). Haiku first pass (art-2701 batch 4).
-- Uses the opus3 shared frame read-only (palette, sky, hills, horizon y=112, road, gate).
-- Landmark: a two-storey plaster inn with a thatch-and-tile roof at the road's end, porch awning.
-- Set pieces: the hanging tankard sign (a cat asleep on top), a hay cart with barrels.
-- Gnomes: the innkeeper with a mug in the porch, a gnome steadying the hay cart.
-- Joke: the cat on the sign.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch4/stops/haiku/"
local F = dofile("/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/opus3/_frame.lua")
  .build{ name = "inn", out = DIR, farTrees = { 14, 58, 150, 330, 404, 466 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union

-- back row: a stable and two cottages, small and hazed
F.depth(1)
F.tree(132, 118, 20, 6, true)
F.building{ x0 = 36, x1 = 86, yb = 124, wh = 14, rh = 10, wall = L.wall2, roof = L.roof, noFrame = true, noAttic = true }
F.building{ x0 = 418, x1 = 462, yb = 124, wh = 14, rh = 10, wall = L.plaster, roof = L.roof2, noFrame = true, noAttic = true, chimney = true }

-- the landmark at the road's end: the inn
F.depth(2)
F.smoke(274, 72, 5, .6, 2)
F.building{ x0 = 196, x1 = 284, yb = 128, wh = 34, rh = 20, wall = L.plaster, roof = L.roof2, chimney = true, shingle = true }
F.door(232, 112, 246, 128, L.timber, true)
F.window(206, 102, 212, 109, L.timber)
F.window(268, 102, 274, 109, L.timber)
-- porch awning over the door
local awn = poly{ { 224, 110 }, { 256, 110 }, { 260, 114 }, { 220, 114 } }
rimOf(awn, L.awnA) part(awn, L.awnA, { nopop = true })
for x = 221, 258, 4 do px(x, 115, L.awnA.deep) end
-- a flower box under the right window
fill(rect(266, 111, 276, 113), L.foliage.base) hline(266, 276, 110, L.foliage.hi)

-- set piece 1: the hanging tankard sign, a cat asleep on its top edge
F.depth(3)
F.sign(186, 100, 16, 12, L.roof)
fill(rect(183, 103, 189, 110), L.awnB.base) hline(183, 189, 103, L.awnB.hi) px(189, 106, L.awnB.shade)
local cat = union(c:ellipse(182, 97, 5, 2), c:ellipse(187, 94, 2, 2))
rimOf(cat, L.produce) part(cat, L.produce, { nopop = true })
px(186, 92, L.produce.deep) px(188, 92, L.produce.deep) px(186, 93, L.produce.deep)
vline(176, 99, 99, L.timber.deep)

-- set piece 2: a hay cart with barrels, right side
local bed = rect(330, 160, 392, 168)
rimOf(bed, L.timber) part(bed, L.board, { sep = true })
c:edgeIn(bed, L.board.deep)
local hay = c:ellipse(361, 160, 26, 6)
rimOf(hay, L.roof) part(hay, L.roof, { nopop = true })
hline(340, 380, 157, L.roof.hi)
for _, wx in ipairs({ 340, 384 }) do
  local w = c:ellipse(wx, 178, 7, 7)
  rimOf(w, L.timber) part(w, L.timber, { nopop = true })
  fill(c:ellipse(wx, 178, 3, 3), L.timber.shade)
  vline(wx, 172, 184, L.timber.deep) hline(wx - 6, wx + 6, 178, L.timber.deep)
end
part(line({ { 330, 168 }, { 306, 178 } }, 2), L.timber, { nopop = true })
F.barrel(414, 186, L.timber, 12)
F.barrel(424, 188, L.timber, 10)
F.sack(404, 204, L.awnB, 5)

-- gnomes
F.depth(3)
local kx, ky = 268, 150
local _, hx, hy = F.gnome(kx, ky, { hat = L.awnB, coat = L.awnA, arm = "out", flip = true })
fill(rect(hx - 3, hy - 4, hx, hy), L.glow.base) px(hx - 3, hy - 4, L.glow.hi) -- mug
F.gnome(330, 192, { hat = L.roof2, coat = L.lav, arm = "hold" })

-- foreground: a horse trough, a crate, a bush, a few stones
local trough = rect(24, 210, 84, 218)
rimOf(trough, L.stone) part(trough, L.stone)
fill(rect(27, 211, 81, 213), L.water.base) hline(27, 81, 211, L.water.hi)
F.crate(112, 236, 16, 10, L.produce)
F.sack(94, 240, L.awnB, 5)
F.bush(440, 220, 26, 16, L.leaf, 11)
F.rock(164, 248, 9, 6)
F.rock(176, 252, 6, 4)

F.birds({ { 150, 66, 2 }, { 318, 58, 2 }, { 96, 46, 2 } })
F.finish()
