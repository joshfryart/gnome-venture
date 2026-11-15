-- herb.lua : "Herb croft" stop look, Maplewold style (480x270 gate view). Haiku first pass.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/haiku/"
local F = dofile(DIR .. "_frame.lua").build{ name = "herb", out = DIR }
local c, L, part, rect, px, rimOf, hline, vline, hash = F.c, F.L, F.part, F.rect, F.px, F.rimOf, F.hline, F.vline, F.hash

-- a cottage with a thatch roof, left of the road
F.building{ x0 = 36, x1 = 122, yb = 158, wh = 32, rh = 20, wall = L.plaster, roof = L.roof }
F.door(70, 132, 82, 158, L.timber, false)
F.window(94, 136, 100, 143, L.timber)
F.window(46, 136, 52, 143, L.timber)

-- raised herb beds with rows of leafy herbs
local function bed(x0, y0, x1, y1, seed)
  local m = rect(x0, y0, x1, y1)
  rimOf(m, L.soil) part(m, L.soil, { nopop = true })
  local x = x0 + 4
  local n = 0
  while x < x1 - 3 do
    n = n + 1
    local cx = x + 2
    local cy = y0 - 1
    F.crown(cx, cy, 5, 4, (n + seed) % 2 == 0 and L.leaf or L.foliage2, seed + n)
    x = x + 9
  end
end
bed(116, 196, 214, 206, 1)
bed(256, 196, 330, 206, 2)
bed(360, 204, 452, 214, 3)

-- drying racks with bundles of herbs hanging from the rails
for _, x in ipairs({ 300, 440 }) do
  local left, right = rect(x, 146, x + 2, 186), rect(x + 26, 146, x + 28, 186)
  local rail = rect(x, 150, x + 28, 152)
  rimOf(F.union(left, right, rail), L.timber)
  part(F.union(left, right, rail), L.timber, { nopop = true })
  for k = 0, 3 do
    local bx = x + 3 + k * 6
    local bundle = c:ellipse(bx, 158, 2, 4)
    rimOf(bundle, L.leaf) part(bundle, L.leaf, { nopop = true })
    px(bx, 153, L.leaf.hi)
  end
end

-- a hedge of lumpy leafy bushes along the back
for x = 300, 336, 12 do F.crown(x, 146, 8, 6, L.leaf, x) end

-- a sign and trees
F.sign(180, 140, 28, 12)
F.tree(170, 132, 26, 6)
F.tree(452, 136, 28, 7)
F.tree(20, 150, 14, 8)

F.finish()
