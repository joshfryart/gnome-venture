-- herb.lua : "Herb garden" stop look, Maplewold (480x270 gate view). Opus second pass.
-- Read: rows of lavender running to the hills, a rose trellis arch over the road's end, the herbalist's thatched
-- cottage hung with drying bundles and a mortar-and-pestle sign, a glasshouse, raised beds of different herbs in
-- perspective, a potting table, straw bee skeps and a stone herb spiral. Quirk: a cat asleep in the catnip bed.
-- opus3 richness pass: lavender rows rebuilt so they never shimmer (a solid haze band until a row is 5+ px wide,
-- then rounded lit mounds with green furrows), swaying hollyhocks with graded blooms, bees and butterflies, three
-- 28 px gnomes, depth planes. The cat is now a big ginger tabby curled in a catnip bed with a butterfly on its ear.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/opus3/"
local F = dofile(DIR .. "_frame.lua").build{ name = "herb", out = DIR, farTrees = { 24, 52, 160, 196, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local LV = L.lav

---------------------------------------------------------------- lavender rows (right, to the hills)
-- Rows converge on the vanishing point. Where a row would be thinner than 5 px it is drawn as a solid lavender band
-- with only horizontal texture, so nothing beats against the pixel grid (the old shimmer).
local farC = F.mix(LV.base, "#ecdcd8", .35)
-- Rows run across the view (like the ploughed rows of the market), each one a line of round lavender bushes;
-- row depth grows with nearness: band height = d^2 / C.
local C = 190
local function rowOf(y) return floor(C / (y - 109)) end
for y = 114, 160 do
  local d = y - 109
  local row = rowOf(y)
  local y0 = y while y0 > 114 and rowOf(y0 - 1) == row do y0 = y0 - 1 end
  local y1 = y while y1 < 160 and rowOf(y1 + 1) == row do y1 = y1 + 1 end
  local hgt = y1 - y0 + 1
  for x = 262, 479 do
    if x > F.xr(y) + 6 then
      local h
      if hgt < 3 then
        h = (y % 2 == 0) and F.mix(LV.shade, "#ecdcd8", .3) or farC
        if hash(x // 4, y, 3) < .15 then h = F.mix(LV.hi, "#ecdcd8", .3) end
      else
        local bw = math.max(5, floor(hgt * 1.7))
        local fx = ((x + row * 3) % bw) / bw
        local ty = y0 + floor(hgt * .45 * (1 - math.sqrt(math.max(0, 1 - (2 * fx - 1) ^ 2))) + .5)
        local ry = (y - y0) / hgt
        if y < ty then
          h = (ry < .2) and L.leaf.deep or L.leaf.shade
          if hgt > 4 and y >= ty - 2 and (x + row) % 2 == 0 and fx > .12 and fx < .88 then h = (y == ty - 2) and "#ece0fa" or LV.base end
        elseif y == y1 then h = L.leaf.deep
        elseif y == ty then h = fx < .5 and "#ece0fa" or LV.hi
        elseif fx < .35 then h = LV.hi
        elseif fx < .72 then h = LV.base
        else h = LV.shade end
        if ry > .78 and h ~= L.leaf.deep then h = LV.deep end
        if hgt > 6 and y > ty and y < y1 - 2 and (x + y) % 4 == 0 and fx < .6 then h = "#ece0fa" end
      end
      px(x, y, h)
    end
  end
end
-- a low clipped hedge closing the near edge of the field
for x = 262, 479 do
  if x > F.xr(160) + 4 then px(x, 161, L.leaf.deep) px(x, 160, (x % 3 == 0) and L.leaf.shade or L.leaf.base) if x % 5 == 0 then px(x, 159, L.leaf.hi) end end
end

---------------------------------------------------------------- rose trellis arch at the road's end
local function arch()
  local pL, pR = rect(216, 76, 219, 126), rect(261, 76, 264, 126)
  local top = c:ellipse(240, 80, 24, 18):cut(c:ellipse(240, 80, 20, 14)):clip(rect(214, 58, 266, 80))
  local gateM = rect(222, 108, 258, 124)
  F.shadow(216, 266, 126, 6, 3)
  rimOf(union(pL, pR, top), L.timber)
  part(pL, L.awnB) part(pR, L.awnB) part(top, L.awnB, { nopop = true })
  for y = 80, 124, 4 do hline(216, 219, y, L.awnB.shade) hline(261, 264, y, L.awnB.shade) end
  -- little picket gate, ajar
  for x = 222, 236, 4 do local m = poly{ { x, 110 }, { x + 1, 108 }, { x + 2, 110 }, { x + 2, 124 }, { x, 124 } } fill(m, L.awnB.base) vline(x + 2, 110, 124, L.awnB.shade) end
  hline(222, 238, 113, L.awnB.shade) hline(222, 238, 120, L.awnB.shade)
  -- climbing rose: leaf clumps along the arch and posts with blooms
  local clumps = { { 214, 120 }, { 220, 104 }, { 214, 92 }, { 220, 78 }, { 226, 66 }, { 240, 62 }, { 254, 66 }, { 262, 80 }, { 266, 94 }, { 260, 108 }, { 266, 120 } }
  for i, p in ipairs(clumps) do
    local m = c:ellipse(p[1], p[2], 5, 4)
    rimOf(m, L.leaf) part(m, L.leaf)
    m:each(function(x, y) if hash(x, y, 9) < .14 then px(x, y, L.leaf.hi) end end)
    local r = (i % 3 == 0) and L.awnB or L.petal
    local bx, by = p[1] + (i % 2 == 0 and 2 or -2), p[2] - 1
    fill(rect(bx, by, bx + 1, by + 1), r.base) px(bx, by, r.hi) px(bx + 1, by + 1, r.shade)
  end
end
L.petal = F.rp("#ffc4d8 #f5809f #c94f84 #7d2c5e #5a1e44")

---------------------------------------------------------------- back-left: glasshouse
local function glasshouse(x0, x1, yb)
  local wh, rh = 20, 14
  local top, cx = yb - wh, (x0 + x1) // 2
  local wall = rect(x0, top, x1, yb)
  local roofm = poly{ { x0 - 2, top + 1 }, { cx, top - rh }, { x1 + 2, top + 1 } }
  local sill = rect(x0 - 1, yb - 5, x1 + 1, yb)
  F.shadow(x0 + 2, x1, yb, 8, 4)
  rimOf(union(wall, roofm, sill), L.awnB)
  fill(wall, L.water.hi) fill(roofm, L.water.base)
  -- plants inside
  for x = x0 + 3, x1 - 3, 6 do local m = c:ellipse(x, yb - 9, 3, 4) fill(m, L.leaf.base) px(x - 1, yb - 11, L.leaf.hi) px(x + 1, yb - 7, L.leaf.shade) end
  part(sill, L.stone) F.courses(sill, yb - 5, 3, 6, L.stone)
  -- white mullions
  for x = x0, x1, 7 do vline(x, top, yb - 6, L.awnB.base) end
  hline(x0, x1, top, L.awnB.base) hline(x0, x1, top + 10, L.awnB.base)
  for k = 0, 4 do line({ { x0 - 1 + k * (cx - x0) // 4, top - k * rh // 4 }, { x0 - 1 + k * (cx - x0) // 4, top } }):each(function(x, y) if roofm:has(x, y) then px(x, y, L.awnB.base) end end) end
  for k = 0, 4 do line({ { x1 + 1 - k * (x1 - cx) // 4, top - k * rh // 4 }, { x1 + 1 - k * (x1 - cx) // 4, top } }):each(function(x, y) if roofm:has(x, y) then px(x, y, L.awnB.shade) end end) end
  line({ { x0 - 2, top + 1 }, { cx, top - rh } }):each(function(x, y) px(x, y, L.awnB.hi) end)
  line({ { cx, top - rh }, { x1 + 2, top + 1 } }):each(function(x, y) px(x, y, L.awnB.shade) end)
  -- glints
  for _, g in ipairs({ { x0 + 3, top + 3 }, { x0 + 10, top + 4 }, { cx - 6, top - 6 } }) do px(g[1], g[2], L.cream or "#fff4d6") px(g[1] + 1, g[2] + 1, L.water.hi) end
end

---------------------------------------------------------------- left hero: herbalist's cottage
local function cottage()
  local top, cx, wallM, roofM = F.building{ x0 = 96, x1 = 182, yb = 182, wh = 46, rh = 32, wall = L.plaster, roof = L.roof, chimney = true }
  -- moss tufts on the thatch
  for i = 0, 12 do local x, y = 100 + floor(hash(i, 1, 41) * 78), top - 6 - floor(hash(i, 2, 41) * 18) if roofM:has(x, y) then px(x, y, L.leaf.base) px(x + 1, y, L.leaf.hi) px(x, y + 1, L.leaf.shade) end end
  -- round green door
  local d = c:rrect(130, 156, 146, 181, 8):clip(rect(130, 156, 146, 181))
  rimOf(d, L.leaf) part(d, L.leaf) c:edgeIn(d, L.leaf.deep)
  for x = 134, 143, 3 do vline(x, 160, 180, L.leaf.shade) end
  fill(c:ellipse(138, 169, 1, 1), L.roof.base) px(138, 168, L.roof.hi)
  F.window(106, 148, 116, 156, L.timber) F.window(160, 148, 170, 156, L.timber)
  -- window boxes with flowers
  for _, wx in ipairs({ 104, 158 }) do
    local bx = rect(wx, 160, wx + 14, 163) rimOf(bx, L.timber) part(bx, L.board, { nopop = true })
    for k = 0, 6 do local fx = wx + 1 + k * 2 px(fx, 159, (k % 2 == 0) and L.petal.base or L.produce.base) px(fx, 158, L.leaf.base) end
  end
  -- drying bundles hanging under the eave
  for k = 0, 10 do
    local x = 100 + k * 8
    local r = ({ L.leaf, LV, L.wall2, L.produce })[k % 4 + 1]
    vline(x, top + 4, top + 6, L.timber.edge)
    local b = poly{ { x - 2, top + 7 }, { x + 2, top + 7 }, { x + 1, top + 14 }, { x - 1, top + 14 } }
    fill(b, r.base) px(x - 1, top + 8, r.hi) vline(x + 1, top + 9, top + 13, r.shade) hline(x - 2, x + 2, top + 7, L.timber.base)
  end
  -- hanging mortar & pestle sign
  hline(184, 198, 152, L.timber.base) hline(184, 198, 153, L.timber.deep)
  vline(192, 154, 157, L.timber.edge)
  local mortar = poly{ { 185, 160 }, { 199, 160 }, { 197, 167 }, { 193, 170 }, { 191, 170 }, { 187, 167 } }
  local pestle = line({ { 196, 158 }, { 201, 152 } }, 2)
  rimOf(union(mortar, pestle), L.stone) part(mortar, L.stone) part(pestle, L.board, { nopop = true })
  hline(185, 199, 160, L.stone.hi) hline(187, 197, 161, L.stone.deep)
end

---------------------------------------------------------------- raised beds in perspective (right of road)
local function bed(x0, x1, y0, y1, plant, seed)
  local soil = poly{ { x0 + 4, y0 }, { x1, y0 }, { x1 + 4, y1 }, { x0, y1 } }
  local front = rect(x0, y1, x1 + 4, y1 + 4)
  F.shadow(x0, x1 + 4, y1 + 4, 6, 2)
  rimOf(union(soil, front), L.timber)
  fill(soil, L.soil.base) soil:each(function(x, y) if hash(x, y, seed) < .18 then px(x, y, L.soil.deep) end end)
  part(front, L.timber, { nopop = true }) hline(x0, x1 + 4, y1 + 2, L.timber.deep)
  for x = x0 + 1, x1 + 3, 12 do vline(x, y1, y1 + 4, L.timber.deep) end
  local n = (x1 - x0) // 7
  for k = 0, n - 1 do plant(x0 + 6 + k * 7, y0 + (y1 - y0) // 2 + 2, k) end
end
local function chard(x, y, k)
  for d = -2, 2, 2 do vline(x + d // 2, y - 6, y, L.awnA.base) end
  local m = c:ellipse(x, y - 7, 3, 3) fill(m, L.leaf.shade) px(x - 1, y - 9, L.leaf.base) px(x - 2, y - 8, L.leaf.hi) px(x + 1, y - 6, L.leaf.deep)
end
local function marigold(x, y, k)
  local m = c:ellipse(x, y - 3, 3, 2) fill(m, L.leaf.shade)
  fill(rect(x - 2, y - 6, x - 1, y - 5), L.produce.base) px(x - 2, y - 6, L.produce.hi)
  fill(rect(x + 1, y - 5, x + 2, y - 4), L.roof.base) px(x + 1, y - 5, L.roof.hi)
end
local function sage(x, y, k)
  local m = c:ellipse(x, y - 3, 4, 3) fill(m, L.wall2.base)
  m:each(function(xx, yy) if hash(xx, yy, 6) < .3 then px(xx, yy, L.wall2.hi) elseif hash(xx, yy, 7) < .2 then px(xx, yy, L.wall2.deep) end end)
end
local function poppy(x, y, k)
  vline(x, y - 7, y, L.leaf.shade) vline(x + 2, y - 5, y, L.leaf.shade)
  fill(rect(x - 1, y - 9, x + 1, y - 7), L.awnA.base) px(x - 1, y - 9, L.awnA.hi) px(x, y - 8, L.timber.edge)
  fill(rect(x + 2, y - 7, x + 3, y - 6), L.awnA.shade)
end

---------------------------------------------------------------- compose: back to front
F.depth(1)
glasshouse(22, 76, 140)
F.tree(86, 130, 40, 2)
-- a far gnome cutting lavender in the field, with a basket
F.gnome(420, 150, { small = true, hat = L.awnA, coat = L.awnB, arm = "out" })
F.gnome(352, 138, { small = true, hat = L.leaf, coat = L.produce, flip = true })
-- thyme/rosemary hedge along the left back
for x = 104, 206, 10 do F.bush(x, 134 + (x % 3), 6, 7, L.wall2, x) end
F.depth(2)
arch()
F.depth(3)
cottage()
F.smoke(171, 126, 7, .5, 2)
-- herb drying A-frame rack near the road (left)
local function dryRack(x0, yb)
  local legs = line({ { x0, yb }, { x0 + 6, yb - 26 }, { x0 + 12, yb } }, 2):add(line({ { x0 + 30, yb }, { x0 + 36, yb - 26 }, { x0 + 42, yb } }, 2))
  local bar = rect(x0 + 4, yb - 26, x0 + 38, yb - 25)
  F.shadow(x0, x0 + 42, yb, 6, 2)
  rimOf(union(legs, bar), L.timber) part(legs, L.timber, { nopop = true, noshade = true }) part(bar, L.timber, { nopop = true, noshade = true })
  for k = 0, 5 do
    local x = x0 + 9 + k * 5
    local r = ({ LV, L.leaf, L.produce, L.wall2 })[k % 4 + 1]
    vline(x, yb - 24, yb - 22, L.timber.edge)
    local b = poly{ { x - 2, yb - 21 }, { x + 2, yb - 21 }, { x + 1, yb - 12 }, { x - 1, yb - 12 } }
    rimOf(b, r) fill(b, r.base) px(x - 1, yb - 20, r.hi) vline(x + 1, yb - 19, yb - 13, r.shade)
  end
end
dryRack(160, 214)
-- the beds on the right, near ones larger
bed(276, 360, 166, 174, sage, 3)
bed(282, 380, 182, 192, chard, 4)
bed(290, 400, 202, 214, marigold, 5)
local function catnip(x, y, k)
  local m = c:ellipse(x, y - 3, 3, 3) fill(m, L.wall2.hi) px(x - 1, y - 5, "#e6f4d2") px(x + 1, y - 2, L.wall2.base) px(x, y - 6, LV.hi)
end
bed(300, 376, 228, 242, catnip, 6)
-- quirk: a ginger tabby curled up asleep in the catnip at the near bed's end, a butterfly resting on its ear
do
  F.sprite({
    "......o..o..........",
    "......oooo..........",
    "....ttttttttt.......",
    "..tTtTttTtttTtt.....",
    ".tttttttttttttttt...",
    "tTttTttTtTttwwwttt..",
    "tttttttttttwwlwwttt.",
    "tttTtttTttwwjjjwtTt.",
    ".tttttttttwwwwwwttt.",
    "..ttttttttttttttTTt.",
    "...TTTTTTTTTTTTTTt..",
  }, 334, 227, { o = L.timber.edge, t = L.produce.base, T = L.produce.shade, w = L.awnB.hi, l = L.produce.deep, j = L.produce.deep })
  -- closed eye lines and pink nose
  hline(347, 348, 233, L.timber.edge) px(345, 235, "#f08a9a")
  -- butterfly on its ear
  F.sprite({ "a.a", ".k.", "a.a" }, 339, 223, { a = L.awnB.hi, k = L.timber.edge }, { rim = false })
  px(338, 223, L.lav.base) px(342, 223, L.lav.base)
  -- sleepy bubble
  local bub = c:ellipse(328, 222, 2, 2) fill(bub, L.water.hi) px(327, 221, "#fff0d0")
  px(332, 225, L.water.hi)
end
-- potting table with pots, jars and a mortar
local function pottingTable()
  local top = rect(402, 172, 452, 175)
  local legs = rect(405, 176, 407, 196):add(rect(447, 176, 449, 196))
  local shelf = rect(404, 188, 450, 189)
  F.shadow(404, 452, 196, 8, 3)
  rimOf(union(top, legs, shelf), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true }) part(shelf, L.timber, { nopop = true, noshade = true }) part(top, L.board)
  for k = 0, 2 do
    local x = 406 + k * 12
    local pot = poly{ { x, 165 }, { x + 8, 165 }, { x + 7, 171 }, { x + 1, 171 } }
    rimOf(pot, L.roof2) part(pot, L.roof2, { nopop = true }) hline(x, x + 8, 165, L.roof2.hi)
    local pl = c:ellipse(x + 4, 161, 3, 3) fill(pl, ({ L.leaf, L.wall2, LV })[k + 1].base) px(x + 3, 159, ({ L.leaf, L.wall2, LV })[k + 1].hi)
  end
  for k = 0, 1 do
    local x = 442 + k * 6
    local jar = rect(x - 2, 164, x + 2, 171) fill(jar, L.water.hi) fill(rect(x - 1, 167, x + 1, 171), ({ L.produce, LV })[k + 1].base) hline(x - 2, x + 2, 164, L.timber.base) px(x - 2, 166, "#fff4d6")
  end
  for k = 0, 3 do local x = 408 + k * 10 local pot = rect(x, 184, x + 6, 187) fill(pot, L.roof2.shade) hline(x, x + 6, 184, L.roof2.base) end
end
pottingTable()
-- bee skeps on a bench at the right edge
local function skeps()
  local bench = rect(410, 214, 462, 216):add(rect(412, 217, 414, 224)):add(rect(458, 217, 460, 224))
  F.shadow(410, 462, 224, 6, 2)
  rimOf(bench, L.timber) part(bench, L.timber, { nopop = true, noshade = true })
  for k = 0, 2 do
    local x = 420 + k * 16
    local m = c:ellipse(x, 206, 7, 9):clip(rect(x - 8, 196, x + 8, 213))
    rimOf(m, L.roof) part(m, L.roof)
    for y = 199, 212, 3 do hline(x - 7, x + 7, y, L.roof.shade) end
    m:each(function(xx, y) if y % 3 == 1 and hash(xx, y, k) < .25 then px(xx, y, L.roof.hi) end end)
    fill(rect(x - 1, 210, x + 1, 213), L.timber.edge)
  end
  for i = 0, 7 do local bx, by = 414 + floor(hash(i, 1, 3) * 48), 186 + floor(hash(i, 2, 3) * 12) px(bx, by, L.roof.base) px(bx + 1, by, L.timber.edge) end
end
skeps()
-- stone herb spiral, bottom-left
local function spiral(cx, cy)
  -- a three-tier stone herb mound, each ring planted differently
  F.shadow(cx - 36, cx + 40, cy + 14, 8, 3)
  local tiers = { { 40, 13, 0, L.leaf }, { 28, 9, 9, L.wall2 }, { 16, 6, 17, LV } }
  for i, t in ipairs(tiers) do
    local rx, ry, up, rr = t[1], t[2], t[3], t[4]
    local top = c:ellipse(cx, cy - up - 4, rx, ry)
    local wall = rect(cx - rx, cy - up - 4, cx + rx, cy - up):clip(c:ellipse(cx, cy - up, rx, ry):add(rect(cx - rx, cy - up - 4, cx + rx, cy - up)))
    local body = union(top, c:ellipse(cx, cy - up, rx, ry))
    rimOf(body, L.stone)
    -- stone face
    c:ellipse(cx, cy - up, rx, ry):cut(top):each(function(x, y)
      local k = (x + (y % 4 < 2 and 0 or 3)) % 6
      px(x, y, (k == 0 or y % 4 == 0) and L.stone.deep or ((x < cx - rx // 2) and L.stone.hi or L.stone.base))
    end)
    -- planted top
    fill(top, L.soil.base)
    top:each(function(x, y)
      local v = hash(x, y, i * 7)
      if v < .45 then px(x, y, rr.base) elseif v < .55 then px(x, y, rr.hi) elseif v < .7 then px(x, y, rr.shade) end
    end)
    c:edgeIn(top, L.stone.base)
  end
  local sprig = c:ellipse(cx, cy - 26, 3, 5) fill(sprig, L.leaf.base) px(cx - 1, cy - 29, L.leaf.hi) px(cx + 1, cy - 23, L.leaf.deep)
  for _, p in ipairs({ { cx - 28, cy - 6 }, { cx + 18, cy - 4 }, { cx - 8, cy - 16 } }) do px(p[1], p[2], L.produce.base) px(p[1] + 1, p[2], L.produce.hi) end
end
spiral(74, 248)
-- hollyhocks along the left: swaying stems, big open blooms low, smaller ones and green buds toward the tip
for k, x in ipairs({ 26, 36, 46, 58, 70, 82 }) do
  local yb, h = 206 + (k % 2) * 3, 32 + floor(hash(k, 1, 5) * 20)
  local r = (k % 3 == 0) and L.awnB or ((k % 3 == 1) and L.petal or L.awnA)
  local function sx(y) return x + floor(sin((yb - y) / h * 2.2 + k) * 2 * (yb - y) / h + .5) end
  for y = yb - h, yb do px(sx(y), y, L.leaf.shade) px(sx(y) + 1, y, L.leaf.deep) end
  -- heart leaves at the base
  for _, lf in ipairs({ { -5, -6 }, { 3, -10 }, { -4, -14 } }) do
    local m = c:ellipse(sx(yb + lf[2]) + lf[1] + 1, yb + lf[2], 3, 2) c:rim(m, L.leaf.edge) part(m, L.leaf, { nopop = true }) px(sx(yb + lf[2]) + lf[1], yb + lf[2] - 1, L.leaf.hi)
  end
  local i = 0
  for y = yb - 16, yb - h + 2, -3 do
    i = i + 1
    local t = (yb - 18 - y) / math.max(1, h - 20)
    local o = (i % 2 == 0) and -2 or 2
    local cx = sx(y) + o
    if t < .62 then
      local rr = t < .3 and 3 or 2
      local m = c:ellipse(cx, y, rr, rr - 1)
      c:rim(m, r.edge) fill(m, r.base) px(cx - 1, y - 1, r.hi) px(cx + 1, y + 1, r.shade) px(cx, y, L.roof.base)
      if rr == 3 then px(cx - 2, y, r.hi) px(cx + 2, y + 1, r.deep) end
    elseif t < .85 then
      fill(rect(cx, y, cx + 1, y + 1), r.base) px(cx, y, r.hi) px(cx + 1, y + 1, r.shade) px(cx - 1, y + 1, L.leaf.base)
    else
      fill(rect(cx, y, cx + 1, y + 1), L.leaf.base) px(cx, y, r.base)
    end
  end
  px(sx(yb - h), yb - h - 1, L.leaf.base)
end
-- gnome harvesting with a basket, gnome watering
local _, gx, gy = F.gnome(268, 218, { hat = LV, coat = L.leaf, arm = "out" })
local bsk = poly{ { gx - 1, gy - 1 }, { gx + 11, gy - 1 }, { gx + 9, gy + 6 }, { gx + 1, gy + 6 } } rimOf(bsk, L.board) part(bsk, L.roof)
bsk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.roof.shade) end end)
for k = 0, 4 do px(gx + 1 + k * 2, gy - 2, (k % 2 == 0) and LV.base or L.leaf.base) px(gx + 1 + k * 2, gy - 3, (k % 2 == 0) and LV.hi or L.leaf.hi) end
-- the waterer, tipping a can over the herb spiral
local _, wx, wy = F.gnome(164, 254, { hat = L.awnA, coat = L.board, arm = "out", flip = true })
local wcan = rect(wx - 8, wy - 3, wx - 1, wy + 3):add(line({ { wx - 8, wy }, { wx - 14, wy - 4 } }, 2))
rimOf(wcan, L.accent) part(wcan, L.accent) fill(rect(wx - 16, wy - 6, wx - 13, wy - 4), L.accent.shade)
for k = 0, 4 do px(wx - 17 - k, wy - 3 + k * 2, L.water.hi) px(wx - 15 - k, wy - 2 + k * 2, L.water.base) end
F.depth(0)
-- bees over the skeps and the lavender, white butterflies
for i = 0, 14 do local bx, by = 300 + floor(hash(i, 1, 33) * 170), 140 + floor(hash(i, 2, 33) * 80) px(bx, by, L.roof.base) px(bx + 1, by, L.timber.edge) px(bx, by - 1, L.water.hi) end
F.sprite({ "a.a", ".k.", "a.a" }, 330, 128, { a = L.awnB.hi, k = L.timber.edge }, { rim = false })
F.sprite({ "a.a", ".k.", "a.a" }, 120, 200, { a = L.awnB.hi, k = L.timber.edge }, { rim = false })
F.sprite({ "a.a", ".k.", "a.a" }, 240, 196, { a = L.roof.hi, k = L.timber.edge }, { rim = false })
F.birds({ { 330, 44, 2 }, { 344, 40, 1 }, { 120, 60, 2 } })
-- foxglove spires in big pots, bottom-right
for k, x in ipairs({ 300, 316, 368 }) do
  local pot = poly{ { x - 7, 252 }, { x + 7, 252 }, { x + 5, 264 }, { x - 5, 264 } }
  rimOf(pot, L.roof2) part(pot, L.roof2) hline(x - 7, x + 7, 252, L.roof2.hi) hline(x - 7, x + 7, 254, L.roof2.deep)
  local h = 18 + k * 3
  vline(x, 252 - h, 252, L.leaf.shade)
  for y = 252 - h, 246, 3 do
    local r = (k == 2) and L.awnB or L.petal
    px(x - 1, y, r.base) px(x + 1, y + 1, r.shade) px(x - 1, y + 1, r.shade)
  end
  local lf = c:ellipse(x, 249, 5, 2) fill(lf, L.leaf.base) px(x - 3, 248, L.leaf.hi)
end
F.finish()
