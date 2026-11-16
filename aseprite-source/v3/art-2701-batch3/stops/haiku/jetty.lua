-- jetty.lua : "Fishing jetty" stop look, Maplewold style (480x270 gate view). Haiku first pass.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/haiku/"
local F = dofile(DIR .. "_frame.lua").build{ name = "jetty", out = DIR }
local c, L, part, rect, px, rimOf, hline, vline = F.c, F.L, F.part, F.rect, F.px, F.rimOf, F.hline, F.vline

-- the lake fills the right-hand ground
F.pond(c:poly{ { 262, 166 }, { 462, 150 }, { 462, 262 }, { 246, 262 } })

-- the jetty: planks running out over the water from the right bank
local deck = c:poly{ { 326, 198 }, { 462, 192 }, { 462, 218 }, { 326, 222 } }
rimOf(deck, L.timber)
part(deck, L.timber, { sep = true })
for x = 330, 462, 11 do vline(x, 196, 220, L.timber.deep) end
hline(326, 462, 205, L.timber.shade)
-- piles under the deck
for _, x in ipairs({ 340, 380, 420, 452 }) do
  local pile = rect(x, 220, x + 3, 236)
  rimOf(pile, L.timber) part(pile, L.timber, { nopop = true, noshade = true })
end
-- buckets hung from the piles
for i, x in ipairs({ 360, 406 }) do
  local bucket = rect(x, 210, x + 5, 217)
  rimOf(bucket, L.accent) part(bucket, L.accent, { nopop = true })
  hline(x + 1, x + 4, 211, L.accent.hi)
end
-- a fishing rod leaning from the end of the deck
part(c:line({ { 452, 198 }, { 430, 150 }, { 412, 120 } }, 1), L.timber, { nopop = true, noshade = true })

-- the angler's hut on the left bank: green plaster, red roof
F.building{ x0 = 38, x1 = 118, yb = 162, wh = 30, rh = 18, wall = L.wall2, roof = L.roof2 }
F.door(70, 136, 82, 162, L.timber, false)
F.window(96, 140, 102, 147, L.timber)
F.window(48, 140, 54, 147, L.timber)

-- a net drying on a frame, and a sign
local postA, postB = rect(138, 150, 140, 184), rect(170, 150, 172, 184)
rimOf(F.union(postA, postB), L.timber) part(F.union(postA, postB), L.timber, { nopop = true })
local net = c:poly{ { 138, 152 }, { 172, 152 }, { 170, 176 }, { 140, 176 } }
part(net, L.leaf, { sep = true })
for y = 156, 174, 3 do for x = 141, 169, 4 do px(x + ((y // 3) % 2) * 2, y, L.leaf.deep) end end
F.sign(92, 146, 26, 12)
F.tree(214, 136, 24, 3, true)
F.tree(450, 128, 22, 4, true)
F.tree(180, 118, 20, 5, true)

F.finish()
