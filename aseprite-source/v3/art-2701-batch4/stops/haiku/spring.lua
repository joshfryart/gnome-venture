-- spring.lua : "Spring" stop look, Maplewold (480x270 gate view). Haiku first pass (art-2701 batch 4).
-- Uses the opus3 shared frame read-only (palette, sky, hills, horizon y=112, road, gate).
-- Landmark: a stone arch at the road's end with a spout, the spring house beyond it.
-- Set pieces: a stone basin pool with lily pads at the front, a wooden well-head with a bucket on the right.
-- Gnomes: one drawing water into a pail at the basin, one hauling the well rope.
-- Joke: a frog in a red hat sitting on the basin rim.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch4/stops/haiku/"
local F = dofile("/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/opus3/_frame.lua")
  .build{ name = "spring", out = DIR, farTrees = { 30, 80, 176, 220, 268, 350, 412 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union

-- back row: ferns and a low hedge of bushes, hazed
F.depth(1)
F.bush(120, 118, 46, 12, L.foliage2, 5)
F.bush(372, 116, 40, 10, L.foliage, 6)

-- the landmark at the road's end: a stone arch with a spout behind it
F.depth(2)
local lint = rect(210, 98, 270, 106)
local pl = rect(210, 106, 218, 130)
local pr = rect(262, 106, 270, 130)
local arch = union(lint, pl, pr)
rimOf(arch, L.stone) part(arch, L.stone)
F.courses(arch, 98, 6, 8, L.stone)
-- the spring house roof, tiled
local roof = poly{ { 206, 100 }, { 240, 84 }, { 274, 100 } }
rimOf(roof, L.roof2) part(roof, L.roof2, { sep = true })
F.courses(roof, 84, 3, 5, L.roof2)
-- niche with a spout and a falling thread of water
fill(rect(230, 108, 250, 130), L.stone.shade)
fill(rect(234, 112, 246, 126), L.stone.deep)
vline(240, 112, 120, L.water.hi) vline(241, 112, 120, L.water.base)
fill(rect(237, 124, 244, 128), L.water.base) hline(237, 244, 124, L.water.hi)
F.smoke(268, 74, 3, .4, 1)

-- set piece 1: the basin pool at the front-left, stone rim and lily pads
F.depth(3)
local rimM = c:ellipse(150, 218, 44, 14)
rimOf(rimM, L.stone) part(rimM, L.stone, { nopop = true })
local water = c:ellipse(150, 218, 37, 10)
F.water(water, L.water, { step = 3 })
for _, p in ipairs({ { 132, 216 }, { 158, 222 } }) do fill(c:ellipse(p[1], p[2], 3, 1), L.leaf.base) px(p[1] - 1, p[2] - 1, L.leaf.hi) end
-- the frog: a leaf-green frog in a red hat on the rim
local frog = c:ellipse(186, 206, 4, 3)
rimOf(frog, L.leaf) part(frog, L.leaf, { nopop = true })
px(184, 203, L.leaf.hi) px(189, 203, L.leaf.hi) px(184, 204, L.timber.edge) px(189, 204, L.timber.edge)
fill(rect(183, 200, 189, 201), L.apple.base) px(184, 200, L.apple.hi)

-- set piece 2: the wooden well-head with a bucket on the right
local postL = rect(330, 160, 332, 192)
local postR = rect(358, 160, 360, 192)
local beam = rect(328, 158, 362, 161)
local wellM = union(postL, postR, beam)
rimOf(wellM, L.timber) part(wellM, L.timber, { nopop = true })
local wroof = poly{ { 324, 158 }, { 345, 146 }, { 366, 158 } }
rimOf(wroof, L.roof) part(wroof, L.roof, { nopop = true })
vline(345, 152, 158, L.timber.deep)
vline(345, 159, 176, L.board.deep)
local bucket = rect(340, 176, 350, 184)
rimOf(bucket, L.iron) part(bucket, L.iron, { nopop = true })
hline(340, 350, 180, L.iron.hi)

-- gnomes: one at the basin with a pail, one hauling the rope at the well
F.depth(3)
local _, hx, hy = F.gnome(200, 246, { hat = L.awnA, coat = L.accent, arm = "out" })
fill(rect(hx, hy - 3, hx + 3, hy), L.iron.base) px(hx, hy - 3, L.iron.hi)
F.gnome(304, 206, { hat = L.roof2, coat = L.produce, arm = "up", flip = true })

-- foreground: stepping stones, a rock garden, ferns along the bottom
for _, s in ipairs({ { 100, 252, 9 }, { 118, 258, 7 }, { 92, 264, 6 } }) do F.rock(s[1], s[2], s[3], 4) end
F.bush(60, 230, 22, 14, L.leaf, 21)
F.bush(430, 216, 24, 14, L.leaf, 22)

F.birds({ { 214, 60, 2 }, { 60, 70, 2 }, { 420, 52, 2 } })
F.finish()
