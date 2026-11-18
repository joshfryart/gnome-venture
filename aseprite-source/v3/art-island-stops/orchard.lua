-- orchard.lua : "Orchard" stop look, ISLAND (island_palm), 480x270 gate view.
-- Same composition as the Maplewold orchard (art-2701-batch3/stops/opus3/orchard.lua), re-cast as a tropical
-- fruit grove behind a coral-sand beach: rows of mango (dark glossy domes, bronze new leaves, fruit on long
-- stalks), papaya (slim ringed trunks under an umbrella of hand leaves, fruit hugging the trunk), breadfruit
-- (wide spreaders, big lobed leaves, round green knobbly fruit) and banana plants, with coconut palms standing in
-- the rows. Beach-grass rides between the rows.
-- Road's end: a great old mango tree on buttress roots, fruit bats hanging in it, a rope swing (a little gnome).
-- Back right: a fruit store on bamboo stilts, banana hands hanging under the thatch. Left hero: a driftwood screw
-- press under a palm-thatch hood squeezing mangoes, juice running into a calabash, a turning gnome, a gecko,
-- heaps of mangoes and breadfruit, bamboo crates, gourds, a cut papaya and coconut cups on a bamboo table.
-- Right hero: a picker on a bamboo ladder at a big front mango tree, a pandanus basket, a scarlet macaw; crates by
-- the road, a gnome with a stem of bananas, a turquoise barrow of fruit. A black island pig at the windfalls, a
-- myna, a junglefowl, lories. Quirk (kept): a giant tortoise in a red gnome hat trundling off with a mango and a
-- hibiscus riding on its shell.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-island-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "orchard", out = DIR, farTrees = { 24, 52, 100, 380, 410, 440 }, volcanoX = 346 }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi

-- tropical grove ramps
local MLF = F.rp("#c4ea84 #7cc055 #46944a #2a6c40 #163f2e")    -- mango leaf, deep glossy
local MLF2 = F.rp("#f2bc8a #d6845a #aa5a42 #7a3c34 #4a2626")   -- mango new leaf flush (bronze)
local BLF = F.rp("#d4ec86 #94c854 #5ea040 #3a7836 #204c28")    -- breadfruit leaf, bright
local MANGO = F.rp("#ffe27a #ffae3a #ee6e30 #b44628 #722a20")  -- ripe mango
local MANGOG = F.rp("#e4ee8e #b2d058 #80a63e #56782e #304a22") -- green mango
local PAPAYA = F.rp("#ffe890 #f8bc44 #e08a30 #a65a26 #683820")
local PAPG = F.rp("#d8ea84 #a4cc52 #74a43e #4c7a30 #2c4c22")
local BREAD = F.rp("#eaf49c #bcd860 #8cb446 #5e8834 #385624")
local PBARK = F.rp("#e6e0c8 #c0b89c #968e76 #6c6656 #443e36")  -- papaya trunk, pale ringed
local MBARK = F.rp("#b49a7c #886c52 #644e3c #46362c #2c221c")  -- mango bark, dark
local JUICE = F.rp("#ffe48a #ffbc44 #f08c2c #b85c22 #763a1c")
local WEAVE = L.rope
-- mango new-leaf flush: bronze-pink sprays along the top lip of a crown
local function flush(m, seed, k)
  m:each(function(x, y)
    if not m:has(x, y - 2) and m:has(x, y + 2) and hash(x // 2, y, seed) < (k or .3) * 1.6 then
      px(x, y, hash(x, y, seed + 1) < .5 and MLF2.base or MLF2.hi)
      if m:has(x, y + 1) then px(x, y + 1, MLF2.shade) end
    end
  end)
end

---------------------------------------------------------------- fruit
-- a hanging mango: a stalk pixel and a drop-shaped fruit, bigger with s
local function mangoAt(x, y, s, fr, stalk)
  fr = fr or MANGO
  if stalk and stalk > 0 then vline(x, y - stalk, y - 1, MBARK.shade) end
  if s >= 2 then
    fill(rect(x - 1, y, x + 1, y + 3), fr.base) px(x, y + 4, fr.shade)
    px(x - 1, y, fr.hi) px(x - 1, y + 1, fr.hi) px(x + 1, y + 2, fr.shade) px(x + 1, y + 3, fr.deep) px(x, y + 3, fr.shade)
    px(x - 1, y + 3, fr.base) px(x + 1, y, fr.base)
    if fr == MANGO then px(x + 1, y + 1, MANGOG.base) end -- green shoulder
    px(x - 2, y + 1, fr.edge) px(x - 2, y + 2, fr.edge) px(x + 2, y + 1, fr.edge) px(x + 2, y + 2, fr.edge) px(x + 2, y + 3, fr.edge)
    px(x - 1, y + 4, fr.edge) px(x + 1, y + 4, fr.edge) px(x, y + 5, fr.edge)
  elseif s > 1.1 then
    px(x, y, fr.hi) px(x + 1, y, fr.base) px(x, y + 1, fr.base) px(x + 1, y + 1, fr.shade) px(x, y + 2, fr.shade)
  elseif s > .7 then px(x, y, fr.base) px(x, y + 1, fr.shade)
  else px(x, y, fr.base) end
end
-- a round breadfruit: knobbly green ball (dot texture)
local function breadAt(x, y, s)
  if s >= 1.2 then
    local m = c:ellipse(x, y, 2, 2)
    c:rim(m, BREAD.edge) fill(m, BREAD.base)
    px(x - 1, y - 1, BREAD.hi) px(x, y - 1, BREAD.hi) px(x + 1, y + 1, BREAD.shade) px(x, y + 1, BREAD.shade)
    px(x + 1, y - 1, BREAD.shade) px(x - 1, y + 1, BREAD.base) px(x, y - 3, MBARK.shade)
  elseif s > .7 then px(x, y, BREAD.hi) px(x + 1, y, BREAD.base) px(x, y + 1, BREAD.base) px(x + 1, y + 1, BREAD.shade)
  else px(x, y, BREAD.base) end
end
-- papaya: an oval hugging the trunk, green or ripening
local function papayaAt(x, y, s, ripe)
  local fr = ripe and PAPAYA or PAPG
  local w, h = math.max(1, floor(1.2 * s)), math.max(1, floor(2.2 * s))
  if s > .8 then
    local m = c:ellipse(x, y, w, h)
    c:rim(m, fr.edge) fill(m, fr.base)
    m:each(function(xx, yy) if xx < x and yy < y then px(xx, yy, fr.hi) elseif xx > x or yy > y + h // 2 then px(xx, yy, fr.shade) end end)
    if ripe then px(x, y + h, PAPG.shade) end
  else px(x, y, fr.base) px(x, y + 1, fr.shade) end
end

---------------------------------------------------------------- the grove trees, four kinds
--   1 mango (three dark domes + a bronze flush, fruit on stalks), 2 papaya (slim ringed trunk, hand leaves,
--   fruit round the trunk), 3 breadfruit (wide spreader, lobed leaves, round fruit), 4 banana plant.
local function papayaTree(x, yb, s, seed)
  local th = floor(30 * s)
  local tw = math.max(1, floor(1.6 * s))
  local lean = floor((hash(seed, 3, 9) - .5) * 4 * s)
  local trunk = HP.mask()
  for y = yb - th, yb do
    local t = (yb - y) / th
    local cx = x + floor(lean * t * t + .5)
    local w = tw + (t < .1 and 1 or 0)
    trunk:add(rect(cx - w // 2, y, cx - w // 2 + w, y))
  end
  F.shadowM(c:ellipse(x + 4 * s, yb, 8 * s, math.max(1, s)))
  rimOf(trunk, PBARK) part(trunk, PBARK, { nopop = true })
  trunk:each(function(xx, yy)
    if not trunk:has(xx - 1, yy) then px(xx, yy, PBARK.hi) elseif not trunk:has(xx + 1, yy) then px(xx, yy, PBARK.shade) end
    if (yy + seed) % 3 == 0 and s > .6 then px(xx, yy, PBARK.deep) end -- leaf scars
  end)
  local tx, ty = x + lean, yb - th
  -- leaf stalks fanning up and out, a hand leaf on each
  local n = s > .8 and 8 or 6
  local leaves = {}
  for k = 1, n do
    local a = -pi + (k - .5) / n * pi + (hash(k, seed, 4) - .5) * .4
    local len = (8 + 4 * hash(k, seed, 5)) * s
    local ex, ey = tx + cos(a) * len, ty + sin(a) * len * .7 + (math.abs(cos(a)) > .7 and 2 * s or 0)
    leaves[#leaves + 1] = { ex, ey, a }
    if s > .6 then line({ { tx, ty }, { ex, ey } }):each(function(xx, yy) px(xx, yy, PAPG.shade) end) end
  end
  for i, lf in ipairs(leaves) do
    local rx, ry = 4.2 * s + 1, 2.6 * s + 1
    local m = F.crown(lf[1], lf[2], rx, ry, (i % 3 == 0) and L.foliage or L.leaf, seed + i * 3)
    -- hand leaf: dark slits between the lobes, radiating from the stalk end
    if s > .8 then
      for q = -2, 2 do
        local qa = -pi / 2 + q * .55
        local lx, ly = floor(lf[1] + cos(qa) * rx * .7 + .5), floor(lf[2] + sin(qa) * ry * .7 + 1.5)
        if m:has(lx, ly) then px(lx, ly, L.leaf.deep) end
      end
      px(floor(lf[1]), floor(lf[2]), L.leaf.hi)
    end
  end
  -- fruit hugging the trunk under the leaves: ripe at the bottom
  local nf = s > .8 and 7 or 4
  for k = 1, nf do
    local side = (k % 2 == 0) and -1 or 1
    local fx = tx + side * floor((1.2 + .8 * hash(k, seed, 6)) * s + .5)
    local fy = ty + floor((2 + (k // 2) * 2.4) * s)
    papayaAt(fx, fy, s, k > nf - 3 and hash(k, seed, 7) < .7)
  end
  -- a little crown tuft at the very top
  px(tx, ty - 1, L.leaf.hi) px(tx - 1, ty - 1, L.leaf.base) px(tx + 1, ty - 1, L.leaf.shade)
end

local function grove(x, yb, s, seed, kind)
  kind = kind or (seed % 4) + 1
  local lean = (hash(seed, 1, 9) - .5) * 4 * s
  local w2 = math.max(1, floor(2 * s))
  if kind == 1 then
    -- mango: short stout trunk, a dense dark dome in three clumps and a bronze flush on the top
    local tr = poly{ { x - 3 * s, yb }, { x - 2 * s + lean, yb - 11 * s }, { x + 2 * s + lean, yb - 11 * s }, { x + 3 * s, yb } }
    local brs = line({ { x + lean, yb - 9 * s }, { x - 9 * s, yb - 17 * s } }, w2):add(line({ { x + lean, yb - 9 * s }, { x + 9 * s, yb - 18 * s } }, w2))
    F.shadowM(c:ellipse(x + 4 * s, yb, 15 * s, 2 * s))
    rimOf(union(tr, brs), MBARK) part(tr, MBARK, { nopop = true }) part(brs, MBARK, { nopop = true, noshade = true })
    local m = F.crown(x - 8 * s, yb - 21 * s, 10 * s, 7 * s, MLF, seed)
    m:add(F.crown(x + 8 * s, yb - 22 * s, 10 * s, 7 * s, MLF, seed + 1))
    m:add(F.crown(x + lean, yb - 28 * s, 12 * s, 8 * s, MLF, seed + 2))
    if s > 1.5 then m:add(F.crown(x - 13 * s, yb - 16 * s, 6 * s, 4 * s, MLF, seed + 4)) m:add(F.crown(x + 12 * s, yb - 15 * s, 6 * s, 4 * s, MLF, seed + 5)) end
    if s > .6 then flush(m, seed + 3, s > 1.5 and .22 or .3) end
    local nf = s > 1.5 and floor(5 * s * s) or floor(9 * s * s) + 3
    for i = 1, nf do
      local a, rr = (hash(i, seed, 1) * 1.4 - .2) * pi, math.sqrt(hash(i, seed, 2)) * .95
      local fx, fy = floor(x + cos(a) * rr * 17 * s), floor(yb - 24 * s + sin(a) * rr * 9 * s)
      if m:has(fx, fy) then mangoAt(fx, fy, s, (i % 4 == 0) and MANGOG or MANGO, s > 1 and floor(s) or 0) end
    end
  elseif kind == 2 then
    papayaTree(x, yb, s, seed)
  elseif kind == 3 then
    -- breadfruit: pale trunk, low wide limbs, a big bright crown of lobed leaves, knobbly green fruit
    local tr = poly{ { x - 3 * s, yb }, { x - 2 * s, yb - 10 * s }, { x + 2 * s, yb - 10 * s }, { x + 3 * s, yb } }
    local brs = line({ { x, yb - 9 * s }, { x - 14 * s, yb - 16 * s } }, w2 + 1):add(line({ { x, yb - 9 * s }, { x + 14 * s, yb - 15 * s } }, w2 + 1))
    F.shadowM(c:ellipse(x + 4 * s, yb, 18 * s, 2 * s))
    rimOf(union(tr, brs), L.timber) part(tr, L.timber, { nopop = true }) part(brs, L.timber, { nopop = true, noshade = true })
    local m = F.crown(x - 12 * s, yb - 21 * s, 9 * s, 7 * s, BLF, seed)
    m:add(F.crown(x + 12 * s, yb - 21 * s, 9 * s, 7 * s, BLF, seed + 1))
    m:add(F.crown(x, yb - 28 * s, 13 * s, 9 * s, BLF, seed + 2))
    -- big lobed leaves: dark lobe slits fanning down from bright tips
    if s > .7 then
      for i = 1, floor(8 * s * s) + 2 do
        local lx, ly = floor(x + (hash(i, seed, 11) - .5) * 40 * s), floor(yb - 32 * s + hash(i, seed, 12) * 16 * s)
        if m:has(lx, ly) and m:has(lx, ly + 3) then
          px(lx, ly, BLF.glint or BLF.hi) px(lx - 1, ly + 1, BLF.hi) px(lx + 1, ly + 1, BLF.hi)
          px(lx - 1, ly + 2, BLF.deep) px(lx + 1, ly + 2, BLF.deep) px(lx, ly + 2, BLF.base) px(lx - 2, ly + 2, BLF.base) px(lx + 2, ly + 2, BLF.shade)
        end
      end
    end
    for i = 1, floor(8 * s * s) + 3 do
      local a, rr = hash(i, seed, 1) * 2 * pi, hash(i, seed, 2)
      breadAt(floor(x + cos(a) * rr * 20 * s), floor(yb - 22 * s + sin(a) * rr * 7 * s), s)
    end
  else
    local h = floor(40 * s)
    F.shadowM(c:ellipse(x + 3 * s, yb, 9 * s, math.max(1, s)))
    F.banana(x, yb, h, seed, { noBunch = h < 26 })
  end
end

---------------------------------------------------------------- the rows (back to front)
local rows = {}
for k = 0, 5 do
  local t = k / 5
  local y = floor(122 + t * t * 70)
  local s = .45 + t * t * .75
  rows[#rows + 1] = { F.xl(y) - 18 - 60 * t, y, s }
  rows[#rows + 1] = { F.xr(y) + 18 + 60 * t, y, s }
  rows[#rows + 1] = { F.xl(y) - 70 - 110 * t, y + 2, s }
  rows[#rows + 1] = { F.xr(y) + 70 + 110 * t, y + 2, s }
end
-- beach-grass rides between the tree rows, a shaded leaf-litter band under each row
for y = 116, 229 do
  local d = y - 108
  local band = floor(60 / d * 6)
  if band % 2 == 0 then
    for x = 18, 461 do
      if not F.roadM:has(x, y) then
        local v = hash(x // 3, y, 91)
        if v < .5 then px(x, y, L.mossGround.base) elseif v < .64 then px(x, y, L.mossGround.hi) elseif v < .68 then px(x, y, L.seagrass.base) end
      end
    end
  end
end
for _, r in ipairs(rows) do
  local y = floor(r[2])
  for x = 18, 461 do
    if not F.roadM:has(x, y + 1) and hash(x, y, 92) < .5 then
      px(x, y + 1, L.mossGround.shade) px(x, y + 2, F.mix(L.mossGround.shade, L.ground.base, .5))
      if hash(x, y, 93) < .06 then px(x, y + 2, L.needle.base) end -- dry leaves
    end
  end
end

F.depth(2)
---------------------------------------------------------------- great old mango tree at the road's end (farthest, drawn first)
local function oldTree()
  local tr = poly{ { 228, 126 }, { 233, 104 }, { 234, 94 }, { 230, 84 }, { 250, 84 }, { 246, 94 }, { 247, 104 }, { 252, 126 } }
  -- buttress roots flaring out
  local roots = poly{ { 220, 127 }, { 230, 114 }, { 232, 127 } }:add(poly{ { 248, 127 }, { 250, 113 }, { 261, 127 } })
  local brs = line({ { 236, 90 }, { 210, 70 } }, 3):add(line({ { 246, 88 }, { 272, 68 } }, 3)):add(line({ { 240, 86 }, { 238, 64 } }, 2))
  F.shadow(220, 262, 128, 8, 2)
  local all = union(tr, roots, brs)
  rimOf(all, MBARK) part(tr, MBARK) part(roots, MBARK, { nopop = true }) part(brs, MBARK, { nopop = true })
  tr:each(function(x, y) if (x * 2 + y) % 9 == 0 or ((x + y // 3) % 7 == 0 and y > 98) then px(x, y, MBARK.deep) end end)
  roots:each(function(x, y) if not roots:has(x - 1, y) then px(x, y, MBARK.hi) elseif (x + y) % 5 == 0 then px(x, y, MBARK.deep) end end)
  -- pale lichen patches on the bark
  tr:each(function(x, y) if hash(x // 2, y // 2, 61) < .12 then px(x, y, PBARK.base) end end)
  -- a hollow with a coconut-shell offering bowl
  local hol = c:ellipse(240, 101, 3, 4) fill(hol, MBARK.edge)
  fill(rect(238, 103, 242, 105), L.coconut.base) hline(238, 242, 103, L.coconut.hi) px(240, 102, L.awnA.base) px(239, 102, L.awnA.hi)
  -- the dome: dark glossy clumps with bronze flush on top and at the tips
  local dome = F.crown(208, 62, 25, 16, MLF, 51)
  dome:add(F.crown(272, 60, 25, 16, MLF, 52)) dome:add(F.crown(240, 48, 31, 19, MLF, 53)) dome:add(F.crown(240, 73, 21, 10, MLF, 54))
  flush(dome, 55, .26)

  -- mangoes on long stalks under the crown
  for i = 1, 44 do
    local ax, ay = 188 + floor(hash(i, 3, 1) * 104), 40 + floor(hash(i, 4, 1) * 44)
    if (ax - 240) ^ 2 / 2400 + (ay - 60) ^ 2 / 480 < 1 and (ay > 54 or hash(i, 5, 1) < .3) then
      mangoAt(ax, ay, 1.5, (i % 5 == 0) and MANGOG or MANGO, 1 + i % 3)
    end
  end
  -- fruit bats hanging upside down from the lower limbs
  for _, b in ipairs({ { 204, 74 }, { 280, 72 } }) do
    F.sprite({ ".k.k.", "kKKKk", "kKOKk", ".KKK.", ".kOk.", "..e.." }, b[1], b[2], { k = L.lava.deep, K = L.lava.shade, O = L.hibiscus.shade, e = L.coconut.base })
  end
  -- rope swing
  vline(216, 72, 112, WEAVE.shade) vline(228, 74, 112, WEAVE.shade)
  for y = 76, 110, 4 do px(216, y, WEAVE.hi) px(228, y + 2, WEAVE.hi) end
  local seat = rect(214, 112, 230, 114) rimOf(seat, L.timber) part(seat, L.board, { nopop = true })
  F.gnome(222, 112, { small = true, hat = L.awnA, coat = L.wall2, noShadow = true }) -- a little one swinging
  -- a rainbow lory in the crown
  F.parrot(262, 50, "lory", true)
end
oldTree()
table.sort(rows, function(a, b) return a[2] < b[2] end)
for i, r in ipairs(rows) do
  F.depth(r[2] < 128 and 1 or (r[2] < 170 and 2 or 3))
  local x = floor(r[1])
  if x > 0 and x < 480 and not (x > 370 and r[2] > 175) then
    if i % 5 == 3 and x > 20 and x < 460 then
      F.palm(x, r[2], floor(58 * r[3]), (i % 2 == 0) and L.foliage or L.foliage2, 3 + i * 4)
    else
      grove(x, r[2], r[3], i * 7 + 1, (i * 3 + x // 50) % 4 + 1)
    end
  end
end

---------------------------------------------------------------- back-right: fruit store on bamboo stilts (between the rows)
F.depth(1)
local function store()
  -- stilts
  local stilts = HP.mask()
  for _, sx in ipairs({ 406, 420, 446, 460 }) do stilts:add(rect(sx, 128, sx + 1, 142)) end
  stilts:add(line({ { 406, 140 }, { 420, 130 } })):add(line({ { 446, 130 }, { 460, 140 } }))
  rimOf(stilts, L.timber) part(stilts, L.board, { nopop = true, noshade = true })
  F.shadow(406, 462, 142, 8, 3)
  local top, cx, wallM, roofM = F.building{ x0 = 404, x1 = 462, yb = 130, wh = 22, rh = 22, wall = L.board, roof = L.roof, noFrame = true, noAttic = true, noShadow = true }
  F.bamboo(wallM:copy():clip(rect(404, top + 4, 462, 130)), L.board, 3)
  hline(404, 462, 130, L.timber.deep) hline(404, 462, top + 4, L.timber.base)
  -- wide open front: shade inside, banana hands hanging, a woven door mat rolled up
  local dm = rect(420, 112, 444, 129)
  fill(rect(419, 111, 445, 129), L.timber.edge) fill(dm, L.soil.deep)
  hline(420, 444, 112, WEAVE.shade) hline(420, 444, 113, WEAVE.deep)
  for k = 0, 2 do
    local bx = 425 + k * 7
    vline(bx, 114, 116, WEAVE.base)
    local b = c:rrect(bx - 2, 117, bx + 2, 124, 2)
    fill(b, (k == 1) and L.gold.base or L.leaf.base)
    b:each(function(xx, yy) if (yy % 2 == 0) then px(xx, yy, (k == 1) and L.gold.shade or L.leaf.shade) elseif xx < bx then px(xx, yy, (k == 1) and L.gold.hi or L.leaf.hi) end end)
  end
  -- crates of fruit on the floor
  fill(rect(421, 125, 431, 129), L.board.shade) for x = 422, 430, 2 do px(x, 125, MANGO.base) px(x + 1, 125, MANGO.shade) end
  fill(rect(434, 125, 443, 129), L.board.shade) for x = 435, 442, 2 do px(x, 125, BREAD.base) px(x + 1, 125, BREAD.shade) end
  -- gable vent with a woven panel, ridge knot
  local gab = poly{ { 410, top }, { 433, top - 18 }, { 456, top } }:cut(roofM)
  gab:each(function(x, y) px(x, y, ((x // 2 + y // 2) % 2 == 0) and WEAVE.base or WEAVE.shade) end)
  -- a bamboo ladder up to the door
  local lad = line({ { 418, 142 }, { 424, 128 } }):add(line({ { 422, 142 }, { 428, 128 } }))
  for k = 1, 4 do local t = k / 5 lad:add(line({ { 418 + 6 * t, 142 - 14 * t }, { 422 + 6 * t, 142 - 14 * t } })) end
  c:rim(lad, L.timber.edge) fill(lad, L.board.hi)
  -- green coconuts heaped against a stilt
  for k = 0, 2 do F.coconut(450 + k * 4, 140, 2, k ~= 1) end F.coconut(452, 137, 2, true)
end
store()

---------------------------------------------------------------- left hero: driftwood screw press under a thatch hood
F.depth(2)
F.plumeria(198, 182, 34, 45)
F.depth(3)
local function press(x0, yb)
  local posts = rect(x0, yb - 52, x0 + 4, yb):add(rect(x0 + 46, yb - 52, x0 + 50, yb))
  local beam = rect(x0 - 4, yb - 56, x0 + 54, yb - 50)
  local screw = rect(x0 + 23, yb - 50, x0 + 27, yb - 28)
  local bar = rect(x0 + 6, yb - 42, x0 + 44, yb - 40)
  local plate = rect(x0 + 10, yb - 28, x0 + 40, yb - 24)
  local tub = poly{ { x0 + 6, yb - 24 }, { x0 + 44, yb - 24 }, { x0 + 42, yb - 6 }, { x0 + 8, yb - 6 } }
  local base = rect(x0 - 4, yb - 6, x0 + 54, yb)
  local spout = rect(x0 + 52, yb - 10, x0 + 60, yb - 8)
  local hood = poly{ { x0 - 12, yb - 55 }, { x0 + 25, yb - 72 }, { x0 + 62, yb - 55 } }
  F.shadow(x0, x0 + 56, yb, 12, 4)
  rimOf(union(posts, beam, screw, bar, plate, tub, base, spout, hood), L.timber)
  -- palm-thatch hood, ragged fringe of frond tips
  part(hood, L.roof, { sep = true }) F.thatch(hood, L.roof, yb - 72, x0 + 25)
  line({ { x0 - 10, yb - 56 }, { x0 + 24, yb - 71 } }):each(function(x, y) if hood:has(x, y) then px(x, y, L.roof.hi) end end)
  for x = x0 - 10, x0 + 60, 3 do vline(x, yb - 55, yb - 54 + (x % 2), L.roof.shade) end
  fill(rect(x0 + 24, yb - 75, x0 + 26, yb - 72), WEAVE.base) px(x0 + 24, yb - 75, WEAVE.hi)
  -- driftwood posts with rope lashings, a bamboo cross beam
  part(posts, L.timber) posts:each(function(x, y) if hash(x, y // 3, 83) < .2 then px(x, y, L.timber.shade) elseif hash(x, y // 4, 84) < .06 then px(x, y, L.timber.hi) end end)
  part(beam, L.board) F.bamboo(beam, L.board, 3, { horizontal = true })
  for _, lx in ipairs({ x0, x0 + 46 }) do for y = yb - 50, yb - 47 do hline(lx, lx + 4, y, (y % 2 == 0) and WEAVE.base or WEAVE.shade) end end
  part(screw, L.timber, { nopop = true }) for y = yb - 49, yb - 29, 2 do hline(x0 + 23, x0 + 27, y, L.timber.deep) px(x0 + 23, y + 1, L.timber.hi) end
  part(bar, L.board, { nopop = true }) F.bamboo(bar, L.board, 3) part(plate, L.timber)
  -- the tub: a hollowed log, rope-bound, mango pulp oozing under the plate
  part(tub, L.timber) tub:each(function(x, y) if (x + y // 3) % 7 == 0 then px(x, y, L.timber.shade) end end)
  hline(x0 + 7, x0 + 43, yb - 20, WEAVE.shade) hline(x0 + 8, x0 + 42, yb - 10, WEAVE.shade)
  hline(x0 + 7, x0 + 43, yb - 19, WEAVE.deep) hline(x0 + 8, x0 + 42, yb - 9, WEAVE.deep)
  for x = x0 + 9, x0 + 41, 2 do px(x, yb - 23, JUICE.shade) if x % 4 == 1 then px(x, yb - 22, JUICE.base) end end
  for x = x0 + 12, x0 + 38, 5 do mangoAt(x, yb - 27, 1.2, MANGO) end
  part(base, L.lava, { nopop = true }) F.courses(base, yb - 6, 3, 8, L.lava)
  part(spout, L.board, { nopop = true }) hline(x0 + 52, x0 + 60, yb - 10, L.board.hi)
  -- juice pouring into a calabash
  vline(x0 + 60, yb - 7, yb + 4, JUICE.base) vline(x0 + 61, yb - 7, yb + 4, JUICE.hi)
  local bk = c:ellipse(x0 + 61, yb + 9, 7, 5):clip(rect(x0 + 50, yb + 4, x0 + 72, yb + 15))
  rimOf(bk, L.coconut) part(bk, L.gold) hline(x0 + 55, x0 + 67, yb + 5, JUICE.base) hline(x0 + 56, x0 + 66, yb + 6, JUICE.shade)
  bk:each(function(x, y) if y > yb + 7 and (x + y) % 4 == 0 then px(x, y, L.gold.shade) end end)
  -- a green day gecko on the right post
  F.sprite({ "..g..", ".gGg.", "..g..", ".gGg.", "..g..", "..g..", ".g..." }, x0 + 46, yb - 40, { g = L.foliage.shade, G = L.foliage.hi })
  px(x0 + 48, yb - 40, L.awnA.base)
end
press(92, 206)
-- a gnome turning the press bar
local _, tx, ty = F.gnome(80, 210, { hat = L.lav, coat = L.hibiscus, arm = "up" })
fill(line({ { tx, ty }, { 98, 166 } }), L.board.base)
-- heaps beside the press: mangoes and breadfruit
local function heap(x0, x1, yb, fr, lf)
  local m = poly{ { x0, yb }, { x0 + 4, yb - 7 }, { (x0 + x1) // 2, yb - 11 }, { x1 - 4, yb - 7 }, { x1, yb } }
  rimOf(m, fr) fill(m, fr.base)
  m:each(function(x, y)
    local k = (x + (y // 2 % 2) * 2) % 4
    if k == 0 then px(x, y, fr.hi) elseif k == 3 or (y % 2 == 1 and k == 2) then px(x, y, fr.shade) end
  end)
  for x = x0 + 4, x1 - 4, 7 do px(x, yb - 8 + (x % 3), lf.base) px(x + 1, yb - 9 + (x % 3), lf.hi) px(x + 2, yb - 9 + (x % 3), lf.base) end
end
heap(30, 84, 214, MANGO, MLF)
heap(16, 44, 206, BREAD, BLF)
F.crate(24, 232, 22, 12, MANGO) F.crate(50, 234, 22, 12, PAPAYA) F.crate(36, 220, 22, 10, MANGOG)
-- a pandanus basket of breadfruit against the crates
local function basket(x, yb, w, h, fr)
  local m = poly{ { x - w, yb - h }, { x + w, yb - h }, { x + w - 2, yb }, { x - w + 2, yb } }
  local handle = c:ellipse(x, yb - h, w - 2, h - 1):cut(c:ellipse(x, yb - h, w - 4, h - 3)):clip(rect(x - w, yb - 2 * h, x + w, yb - h - 1))
  rimOf(union(m, handle), WEAVE) part(handle, WEAVE, { nopop = true, noshade = true })
  part(m, WEAVE, { nopop = true })
  m:each(function(xx, yy) if ((xx // 2 + yy // 2) % 2 == 0) then px(xx, yy, WEAVE.shade) elseif (xx + yy) % 5 == 0 then px(xx, yy, WEAVE.hi) end end)
  hline(x - w + 1, x + w - 1, yb - h, WEAVE.deep)
  for xx = x - w + 1, x + w - 2, 3 do px(xx, yb - h - 1, fr.base) px(xx + 1, yb - h - 1, fr.shade) px(xx, yb - h - 2, fr.hi) px(xx + 1, yb - h - 2, fr.base) end
end
basket(80, 226, 7, 6, BREAD)
-- calabash gourds, coconut cups and a cut papaya on a bamboo table
local tbl = rect(118, 226, 182, 229):add(rect(121, 230, 123, 242)):add(rect(177, 230, 179, 242))
F.shadow(120, 182, 242, 8, 3)
rimOf(tbl, L.timber) part(tbl, L.board, { nopop = true }) F.bamboo(rect(118, 226, 182, 229), L.board, 2, { horizontal = true })
for k = 0, 2 do
  local x = 126 + k * 13
  local jr = ({ L.gold, L.coconut, L.gold })[k + 1]
  local g = c:ellipse(x, 220, 5, 5):add(c:ellipse(x, 212, 2, 3)):add(rect(x - 1, 207, x + 1, 210))
  rimOf(g, L.coconut) part(g, jr)
  g:each(function(xx, yy) if yy > 214 and (xx - x) * (xx - x) + (yy - 220) ^ 2 < 9 and yy == 220 then px(xx, yy, L.coconut.deep) end end) -- woven sling
  hline(x - 4, x + 4, 219, WEAVE.shade) px(x, 216, WEAVE.shade) px(x - 2, 217, WEAVE.shade) px(x + 2, 217, WEAVE.shade)
  fill(rect(x - 1, 206, x + 1, 207), L.leaf.shade) px(x - 1, 206, L.leaf.hi) -- leaf stopper
end
-- half a papaya, orange flesh full of black seeds
local pap = c:ellipse(170, 222, 7, 3):clip(rect(162, 219, 178, 225))
rimOf(pap, PAPG) fill(pap, PAPAYA.base)
pap:each(function(x, y) if y == 219 or y == 220 and (x < 165 or x > 175) then px(x, y, PAPG.base) end end)
fill(c:ellipse(170, 222, 3, 1), PAPAYA.shade)
for _, s in ipairs({ { 168, 222 }, { 170, 221 }, { 172, 222 }, { 169, 223 }, { 171, 223 } }) do px(s[1], s[2], L.lava.deep) end
px(166, 221, PAPAYA.hi)
-- two coconut cups of juice
for _, cx in ipairs({ 156, 112 }) do
  local cupY = cx == 112 and 238 or 224
  local cup = c:ellipse(cx, cupY, 3, 2):clip(rect(cx - 3, cupY - 1, cx + 3, cupY + 2))
  rimOf(cup, L.coconut) fill(cup, L.coconut.base) hline(cx - 2, cx + 2, cupY - 1, JUICE.hi) px(cx - 2, cupY, L.coconut.hi)
end
F.barrel(196, 250, L.timber, 14)
hline(192, 200, 239, JUICE.base) -- juice stain round the bung
-- painted turquoise band and a bright lid ring so the barrel reads against the road
hline(191, 201, 244, L.wall2.base) hline(191, 201, 245, L.wall2.hi) hline(191, 201, 246, L.wall2.shade)
hline(193, 199, 238, L.timber.hi) px(197, 241, JUICE.hi) px(197, 242, JUICE.base)
basket(186, 264, 7, 6, MANGO)

---------------------------------------------------------------- right hero: picker on a bamboo ladder at a big front mango tree
grove(408, 226, 2.3, 77, 1)
local lad = line({ { 352, 236 }, { 370, 168 } }, 2):add(line({ { 364, 238 }, { 382, 170 } }, 2))
local rungs = HP.mask()
for k = 0, 8 do local t = k / 8 rungs:add(line({ { 352 + 18 * t, 236 - 68 * t }, { 364 + 18 * t, 238 - 68 * t } })) end
lad:add(rungs)
rimOf(lad, L.timber) part(lad, L.board, { nopop = true, noshade = true })
F.bamboo(line({ { 352, 236 }, { 370, 168 } }, 2):add(line({ { 364, 238 }, { 382, 170 } }, 2)), L.board, 2)
-- rope lashings where the rungs cross the rails
for k = 0, 8 do local t = k / 8 px(floor(352 + 18 * t), floor(236 - 68 * t), WEAVE.shade) px(floor(364 + 18 * t), floor(238 - 68 * t), WEAVE.shade) end
local _, phx, phy = F.gnome(375, 190, { hat = L.awnA, coat = L.wall2, arm = "up", noShadow = true })
mangoAt(phx, phy - 4, 1.5, MANGO) -- a mango just picked
local bas = poly{ { 366, 186 }, { 380, 186 }, { 378, 195 }, { 368, 195 } } rimOf(bas, WEAVE) part(bas, WEAVE)
bas:each(function(x, y) if ((x // 2 + y // 2) % 2 == 0) then px(x, y, WEAVE.shade) end end)
for k = 0, 5 do local fr = (k % 3 == 2) and MANGOG or MANGO fill(rect(367 + k * 2, 184, 368 + k * 2, 185), fr.base) px(367 + k * 2, 184, fr.hi) end
-- a scarlet macaw in the front tree
F.parrot(430, 182, "macaw", true)
vline(431, 193, 197, L.awnA.shade) vline(432, 193, 196, "#3c78c8")
-- crates by the road (right): mangoes, papayas, green breadfruit
F.crate(290, 226, 22, 12, MANGO) F.crate(314, 228, 22, 12, PAPAYA) F.crate(300, 213, 22, 11, BREAD)
basket(330, 214, 6, 5, MANGOG)
-- a gnome with a stem of bananas over his shoulder
local _, ghx, ghy = F.gnome(336, 256, { hat = L.leaf, coat = L.roof2, arm = "up", flip = true })
local stem = line({ { ghx + 6, ghy - 3 }, { ghx - 4, ghy + 4 } }, 1)
c:rim(stem, L.foliage2.edge) fill(stem, L.foliage2.shade)
local bunch = c:rrect(ghx - 3, ghy - 1, ghx + 5, ghy + 9, 3)
c:rim(bunch, L.leaf.edge) fill(bunch, L.leaf.base)
bunch:each(function(xx, yy) if (yy - ghy) % 3 == 0 then px(xx, yy, L.leaf.shade) elseif xx < ghx then px(xx, yy, L.leaf.hi) elseif (xx + yy) % 4 == 0 then px(xx, yy, L.gold.base) end end)
local bud = c:ellipse(ghx + 1, ghy + 11, 1, 2) c:rim(bud, L.lav.edge) fill(bud, L.lav.deep) px(ghx + 1, ghy + 10, L.lav.shade)
-- turquoise barrow of mangoes with a papaya on top
local wb = poly{ { 282, 246 }, { 312, 246 }, { 306, 256 }, { 288, 256 } }
local wbh = line({ { 282, 250 }, { 270, 256 } }, 2):add(rect(296, 256, 297, 262))
local wbw = c:ellipse(310, 260, 4, 4)
F.shadow(276, 314, 264, 6, 2)
rimOf(union(wb, wbh, wbw), L.timber) part(wbh, L.timber, { nopop = true, noshade = true }) part(wb, L.accent) part(wbw, L.timber, { nopop = true })
F.planks(wb, L.accent, 3, false, 23)
fill(c:ellipse(310, 260, 1, 1), L.iron.base)
for x = 285, 309, 3 do local fr = (x % 2 == 0) and MANGO or MANGOG fill(rect(x, 243, x + 1, 245), fr.base) px(x, 243, fr.hi) px(x + 1, 245, fr.shade) end
papayaAt(298, 240, 1.6, true)
px(290, 242, MLF.base) px(291, 241, MLF.hi)

---------------------------------------------------------------- tropical life and flowers in the grove
for _, f in ipairs({ { 22, 196, 6 }, { 28, 200, 5 }, { 110, 196, 5 }, { 268, 200, 5 }, { 458, 210, 6 }, { 450, 214, 5 },
  { 214, 236, 6 }, { 30, 250, 7 }, { 66, 254, 6 }, { 352, 210, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.hibiscus(150, 190, 8, 9, 31)
F.hibiscus(272, 196, 6, 7, 32, "orange")
-- fallen plumeria and hibiscus under the trees
for _, fl in ipairs({ { 120, 252, "plumeria" }, { 236, 222, "hibiscus" }, { 274, 232, "plumeria" }, { 96, 248, "orange" }, { 446, 202, "plumeria" }, { 60, 244, "white" } }) do F.flower(fl[1], fl[2], fl[3], true) end
-- a junglefowl rooster scratching by the right crates
F.hen(346, 236, L.hibiscus, true)
px(350, 229, L.foliage2.base) px(351, 230, L.foliage2.shade) px(350, 230, L.foliage2.deep) -- dark green tail
-- butterflies: little pairs of wings over the flowers
for _, b in ipairs({ { 156, 176, L.gold }, { 278, 186, L.wall2 }, { 104, 186, L.hibiscus } }) do
  px(b[1], b[2], b[3].hi) px(b[1] + 2, b[2], b[3].base) px(b[1] + 1, b[2] + 1, L.timber.edge) px(b[1], b[2] + 1, b[3].shade) px(b[1] + 2, b[2] + 1, b[3].shade)
end

---------------------------------------------------------------- windfalls + quirk tortoise
for i = 0, 40 do
  local x, y = 20 + floor(hash(i, 5, 7) * 440), 150 + floor(hash(i, 6, 7) * 110)
  local fr = (i % 4 == 0) and MANGOG or ((i % 4 == 1) and PAPAYA or MANGO)
  if not F.roadM:has(x, y) and not (x > 378 and y > 228) then px(x, y, fr.base) px(x + 1, y, fr.shade) px(x, y - 1, fr.hi) if i % 3 == 0 then px(x + 2, y, MLF.shade) end end
end
-- quirk: a giant tortoise in a red gnome hat, trundling off with a mango and a hibiscus riding on its shell
local function tortoise(cx, cy)
  local SK = F.rp("#d6cfac #ada483 #827a62 #5a5442 #38342a")
  F.shadowM(c:ellipse(cx + 3, cy + 5, 17, 2))
  local dome = c:ellipse(cx, cy, 12, 9):clip(rect(cx - 12, cy - 9, cx + 12, cy + 1))
  local skirt = rect(cx - 13, cy + 1, cx + 13, cy + 2)
  local head = c:ellipse(cx + 17, cy - 1, 3, 2):add(rect(cx + 11, cy - 1, cx + 15, cy + 2))
  local legs = rect(cx - 10, cy + 2, cx - 7, cy + 5):add(rect(cx - 3, cy + 3, cx, cy + 5)):add(rect(cx + 5, cy + 3, cx + 8, cy + 5)):add(rect(cx + 10, cy + 2, cx + 12, cy + 4))
  local tail = rect(cx - 15, cy, cx - 13, cy + 1)
  local hat = poly{ { cx + 13, cy - 3 }, { cx + 21, cy - 3 }, { cx + 19, cy - 8 }, { cx + 20, cy - 12 }, { cx + 23, cy - 14 }, { cx + 17, cy - 12 }, { cx + 15, cy - 7 } }
  rimOf(union(dome, skirt, head, legs, tail, hat), L.coconut)
  part(union(head, legs, tail), SK, { nopop = true })
  legs:each(function(x, y) if y == cy + 5 and x % 2 == 0 then px(x, y, SK.deep) end end)
  -- domed shell: raised scutes, each lit upper left with a dark seam, growth rings
  part(dome, L.coconut, { nopop = true })
  dome:each(function(x, y)
    local row = (cy - y) // 4
    local off = (row % 2) * 3
    local u = (x - cx + 30 + off) % 6
    local v = (cy - y) % 4
    local h
    if v == 0 or u == 0 then h = L.coconut.deep
    elseif u == 1 and v == 3 then h = L.coconut.hi
    elseif u == 3 and v == 2 then h = L.coconut.shade end
    if not h and (x - cx) + (y - cy) * 1.4 < -12 then h = L.coconut.hi end
    if not h and (x - cx) > 6 and (y - cy) > -4 then h = L.coconut.shade end
    if h then px(x, y, h) end
  end)
  part(skirt, L.coconut, { nopop = true }) hline(cx - 12, cx + 12, cy + 1, L.coconut.hi)
  for x = cx - 12, cx + 12, 4 do px(x, cy + 2, L.coconut.deep) end
  px(cx + 18, cy - 2, L.timber.edge) px(cx + 19, cy, SK.deep) hline(cx + 17, cx + 19, cy + 1, SK.shade)
  px(cx + 20, cy - 1, SK.shade)
  -- the red gnome hat
  part(hat, L.awnA, { nopop = true })
  hat:each(function(x, y) if x < cx + 17 and y > cy - 9 then px(x, y, L.awnA.hi) end end)
  hline(cx + 13, cx + 21, cy - 3, L.awnA.deep)
  -- riding on top: a mango and a hibiscus
  local mg = c:ellipse(cx - 3, cy - 12, 4, 3)
  rimOf(mg, MANGO) fill(mg, MANGO.base)
  mg:each(function(x, y) if (x - cx + 3) + (y - cy + 12) < -2 then px(x, y, MANGO.hi) elseif (x - cx + 3) + (y - cy + 12) > 2 then px(x, y, MANGO.shade) end end)
  px(cx, cy - 13, MANGOG.base) px(cx + 1, cy - 12, MANGOG.shade) px(cx - 5, cy - 13, "#fff0b0")
  px(cx - 3, cy - 16, MBARK.shade) px(cx - 2, cy - 17, MLF.base) px(cx - 1, cy - 17, MLF.hi) px(cx, cy - 17, MLF.shade)
  F.flower(cx + 4, cy - 10, "hibiscus")
end
tortoise(218, 259)
-- a black island pig and her spotted piglet snuffling the windfalls under the far-left trees
F.sprite({
  "..e...........",
  ".eBe.bBBBBB...",
  "bBBBBBBBBBBBb.",
  "nBEBBBBBBBBBBb",
  "nnBBBBBBBBBBBq",
  ".bBBBBBBBBBBb.",
  "..dd.dd..dd.d.",
}, 58, 162, { b = L.lava.deep, B = L.lava.shade, E = L.timber.edge, n = L.petal.shade, q = L.lava.deep, e = L.lava.deep, d = L.timber.edge })
F.sprite({ ".bBBb..", "nBPBBb.", "nBBPBB.", ".d..d.." }, 76, 166, { b = L.lava.deep, B = L.petal.base, P = L.lava.shade, n = L.petal.shade, d = L.timber.edge })
for _, a in ipairs({ { 52, 167 }, { 55, 169 }, { 86, 168 } }) do px(a[1], a[2], MANGO.base) px(a[1] + 1, a[2], MANGO.shade) px(a[1], a[2] - 1, MANGO.hi) end
-- a myna pecking a fallen mango by the road
F.sprite({ ".kk...", "kkYkk.", "bbbbby", ".b.b.." }, 182, 192, { k = "#3c3640", Y = L.gold.base, b = L.needle.shade, y = L.gold.base })
px(180, 195, MANGO.base) px(179, 195, MANGO.shade) px(180, 194, MANGO.hi)
F.depth(0)
F.birds({ { 330, 40, 2 }, { 120, 48, 2 }, { 132, 42, 1 }, { 150, 30, 3 } })
F.finish()
