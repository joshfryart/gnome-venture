-- orchard.lua : "Orchard" stop look, FOREST (forest_pinewood), 480x270 gate view.
-- Same composition as the Maplewold orchard (art-2701-batch3/stops/opus3/orchard.lua), re-cast as a woodland-clearing
-- orchard at the forest edge: rows of wild fruit and nut trees (round crabapples, coppiced hazels with nut clusters,
-- tall wild plums in dusky purple, old mossy spreaders, young staked whips in woven withy guards) running to the
-- misted tree line, with spruces and pines standing in among the rows. Mossy rides between the rows.
-- Road's end: a great old mossy crab tree with bracket fungi, an owl in its hollow and a rope swing (a little gnome).
-- Back right: a log barn with a red-bark shingle roof. Left hero: a log-built screw cider press, a tub of crabs,
-- juice running into a bucket, a turning gnome, heaps and crates, stoneware jugs on a plank table, barrels.
-- Right hero: a picker on a ladder at a big front crab tree, a basket, crates by the road, a barrow of crabs, a
-- gnome with a basket of mushrooms. A boar piglet at the windfalls, a blackbird, a red squirrel with a hazelnut.
-- Quirk (kept): a hedgehog trundling off with a crabapple, a leaf and a little mushroom stuck on its spines.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-forest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "orchard", out = DIR, farTrees = { 24, 52, 100, 380, 410, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local AP, IR = L.apple, L.iron
-- broadleaf ramps for the forest edge: cool misted greens, a yellowing hazel and a turning russet
local LF = F.rp("#bcd486 #88ac5c #608a48 #42683e #283f2e")   -- cool orchard green
local LF2 = F.rp("#dcdc8a #b4b65a #8a9446 #606c38 #3a4628")  -- yellowing (hazel)
local LF3 = F.rp("#e8b878 #c48a4c #9a663c #6c4632 #442c24")  -- turning russet
local LF4 = F.rp("#a8c890 #78a46c #567e56 #3c5e48 #263e34")  -- deep blue-green (plum)
local PLUM = F.rp("#c4a8d4 #8a68a8 #644a84 #46325e #2c203e")  -- wild plum, dusky bloom
local GOLD = F.rp("#f4e08a #e0b448 #b8862e #865c24 #563a1a") -- golden crab
local NUT = F.rp("#e4dc96 #c0b864 #94884a #6a5a34 #463822")  -- hazel husk
local WICK = F.rp("#d8b47c #b48a52 #8c683c #644a30 #3e2e22") -- wicker / withy
local CIDER = F.rp("#f6e49a #e6c058 #c0963a #8c6a2c #5a4422")

local function fruitDot(ax, ay, s, fr)
  if s > 1.1 then fill(rect(ax, ay, ax + 1, ay + 1), fr.base) px(ax, ay, fr.hi) px(ax + 1, ay + 1, fr.shade)
  else px(ax, ay, fr.base) if s > .7 then px(ax + 1, ay, fr.shade) end end
end
local function nutDot(ax, ay, s)
  -- a hazel cluster: two or three husked nuts, brown tips
  if s > 1 then px(ax, ay, NUT.hi) px(ax + 1, ay, NUT.base) px(ax, ay + 1, NUT.shade) px(ax + 1, ay + 1, L.needle.shade) px(ax - 1, ay + 1, NUT.base)
  else px(ax, ay, NUT.hi) if s > .7 then px(ax + 1, ay, L.needle.shade) end end
end
local function mossTrunk(m, seed, k)
  m:each(function(x, y) if not m:has(x + 1, y) or hash(x // 2, y // 2, seed) < (k or .18) then
    if hash(x, y, seed + 1) < .5 then px(x, y, L.moss.shade) end end end)
end

-- fruit and nut trees, four kinds so the rows never repeat one shape:
--   1 round crabapple (three clumps, red or gold crabs), 2 coppiced hazel (several thin stems, broad low crown, nuts),
--   3 old mossy spreader (low heavy limbs, wild plum or crab), 4 young staked whip in a woven withy guard.
local function fruitTree(x, yb, s, seed, kind)
  kind = kind or (seed % 4) + 1
  local lr = ({ LF, LF4, LF3, LF })[(seed // 4) % 4 + 1]
  local fr = ({ AP, NUT, PLUM, GOLD })[kind]
  if kind == 1 and seed % 3 == 0 then fr = GOLD end
  if kind == 2 then lr = LF2 end
  if kind == 3 then lr = (seed % 2 == 0) and LF4 or LF fr = (seed % 2 == 0) and PLUM or AP end
  local lean = (hash(seed, 1, 9) - .5) * 4 * s
  local w2 = math.max(1, floor(2 * s))
  if kind == 1 then
    local tr = poly{ { x - 3 * s, yb }, { x - 2 * s + lean, yb - 12 * s }, { x + 2 * s + lean, yb - 12 * s }, { x + 3 * s, yb } }
    local brs = line({ { x + lean, yb - 10 * s }, { x - 8 * s, yb - 18 * s } }, w2):add(line({ { x + lean, yb - 10 * s }, { x + 8 * s, yb - 19 * s } }, w2))
    F.shadowM(c:ellipse(x + 4 * s, yb, 13 * s, 2 * s))
    rimOf(union(tr, brs), L.timber) part(tr, L.timber, { nopop = true }) part(brs, L.timber, { nopop = true, noshade = true })
    if s > .8 then mossTrunk(tr, seed) end
    F.crown(x - 6 * s, yb - 22 * s, 9 * s, 7 * s, lr, seed) F.crown(x + 6 * s, yb - 23 * s, 9 * s, 7 * s, lr, seed + 1) F.crown(x + lean, yb - 29 * s, 10 * s, 7 * s, lr, seed + 2)
    for i = 1, floor(9 * s * s) + 3 do local a, rr = hash(i, seed, 1) * 2 * pi, math.sqrt(hash(i, seed, 2)) * .95 fruitDot(floor(x + cos(a) * rr * 13 * s), floor(yb - 25 * s + sin(a) * rr * 9 * s), s, fr) end
  elseif kind == 2 then
    -- coppice stools: 4 thin stems fanning from one mossy base
    local st = HP.mask()
    for k = -2, 2 do if k ~= 0 or s > .8 then st:add(line({ { x + k * s, yb }, { x + k * 4 * s + lean * .5, yb - 15 * s } }, math.max(1, floor(s)))) end end
    local stool = c:ellipse(x, yb, 3 * s + 1, math.max(1, s))
    F.shadowM(c:ellipse(x + 4 * s, yb, 13 * s, 2 * s))
    rimOf(stool, L.timber) part(stool, L.moss, { nopop = true, noshade = true })
    st:each(function(xx, yy) px(xx, yy, st:has(xx - 1, yy) and L.timber.shade or (hash(xx, yy // 2, seed) < .4 and L.birch.shade or L.timber.hi)) end)
    F.crown(x - 9 * s, yb - 20 * s, 8 * s, 7 * s, lr, seed) F.crown(x + 9 * s, yb - 21 * s, 8 * s, 7 * s, lr, seed + 1) F.crown(x + lean, yb - 25 * s, 10 * s, 8 * s, lr, seed + 2)
    for i = 1, floor(8 * s * s) + 3 do local a, rr = hash(i, seed, 1) * 2 * pi, hash(i, seed, 2) nutDot(floor(x + cos(a) * rr * 15 * s), floor(yb - 22 * s + sin(a) * rr * 8 * s), s) end
    -- catkin tassels hanging under the crown edge
    if s > .7 then for i = 1, floor(4 * s) do local cx = floor(x + (hash(i, seed, 5) - .5) * 26 * s) local cy = floor(yb - 15 * s + hash(i, seed, 6) * 2) vline(cx, cy, cy + floor(s), NUT.base) end end
  elseif kind == 3 then
    local tr = poly{ { x - 4 * s, yb }, { x - 3 * s, yb - 8 * s }, { x + 3 * s, yb - 8 * s }, { x + 4 * s, yb } }
    local brs = line({ { x, yb - 7 * s }, { x - 13 * s, yb - 13 * s } }, w2 + 1):add(line({ { x, yb - 7 * s }, { x + 13 * s, yb - 12 * s } }, w2 + 1))
    F.shadowM(c:ellipse(x + 4 * s, yb, 17 * s, 2 * s))
    rimOf(union(tr, brs), L.timber) part(tr, L.timber, { nopop = true }) part(brs, L.timber, { nopop = true, noshade = true })
    if s > .6 then F.moss(union(tr, brs), .22, seed) end
    F.crown(x - 11 * s, yb - 18 * s, 9 * s, 7 * s, lr, seed) F.crown(x + 11 * s, yb - 18 * s, 9 * s, 7 * s, lr, seed + 1) F.crown(x, yb - 24 * s, 12 * s, 9 * s, lr, seed + 2)
    for i = 1, floor(10 * s * s) + 3 do local a, rr = hash(i, seed, 1) * 2 * pi, hash(i, seed, 2) fruitDot(floor(x + cos(a) * rr * 19 * s), floor(yb - 20 * s + sin(a) * rr * 7 * s), s, fr) end
  else
    local tr = rect(floor(x), floor(yb - 14 * s), floor(x + math.max(1, s)), yb)
    local stake = rect(floor(x + 3 * s), floor(yb - 12 * s), floor(x + 3 * s), yb)
    local guard = rect(floor(x - 2 * s), floor(yb - 5 * s), floor(x + 2 * s + 1), yb)
    F.shadowM(c:ellipse(x + 3 * s, yb, 7 * s, 1 + s))
    rimOf(union(tr, stake), L.timber) part(tr, L.timber, { nopop = true, noshade = true }) part(stake, L.board, { nopop = true, noshade = true })
    F.crown(x, yb - 18 * s, 6 * s, 6 * s, (seed % 2 == 0) and LF or LF4, seed)
    if s > .7 then -- woven withy guard
      rimOf(guard, WICK) fill(guard, WICK.base)
      guard:each(function(xx, yy) local k = (xx + (yy // 2) * 2) % 4 if k == 0 then px(xx, yy, WICK.hi) elseif k == 2 then px(xx, yy, WICK.deep) end end)
    end
    for i = 1, 3 do fruitDot(floor(x + (hash(i, seed, 1) - .5) * 8 * s), floor(yb - 18 * s + (hash(i, seed, 2) - .5) * 6 * s), s, (seed % 2 == 0) and AP or PLUM) end
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
-- mossy rides (grass strips) between the tree rows, and a darker damp band under each row
for y = 116, 229 do
  local d = y - 108
  local band = floor(60 / d * 6)
  if band % 2 == 0 then
    for x = 18, 461 do
      if not F.roadM:has(x, y) then
        local v = hash(x // 3, y, 91)
        if v < .55 then px(x, y, L.mossGround.base) elseif v < .68 then px(x, y, L.mossGround.hi) end
      end
    end
  end
end
for _, r in ipairs(rows) do
  local y = floor(r[2])
  for x = 18, 461 do if not F.roadM:has(x, y + 1) and hash(x, y, 92) < .5 then px(x, y + 1, L.mossGround.shade) px(x, y + 2, F.mix(L.mossGround.shade, L.ground.base, .5)) end end
end
-- low mist lying in the far rows
for _, m in ipairs({ { 30, 186, 130 }, { 294, 452, 128 }, { 60, 170, 141 }, { 316, 430, 139 } }) do
  for x = m[1], m[2] do
    if not F.roadM:has(x, m[3]) and hash(x // 4, m[3], 93) < .8 then px(x, m[3], L.mist) end
    if (x - m[1]) % 7 < 4 and hash(x // 3, m[3], 94) < .6 then px(x, m[3] + 1, L.mist2) end
  end
end

F.depth(2)
---------------------------------------------------------------- great old crab tree at the road's end (farthest, drawn first)
local function oldTree()
  local tr = poly{ { 226, 126 }, { 233, 104 }, { 234, 96 }, { 230, 84 }, { 250, 84 }, { 246, 96 }, { 247, 104 }, { 254, 126 } }
  local roots = poly{ { 220, 127 }, { 230, 120 }, { 232, 127 } }:add(poly{ { 248, 127 }, { 251, 119 }, { 260, 127 } })
  local brs = line({ { 236, 90 }, { 212, 70 } }, 3):add(line({ { 246, 88 }, { 270, 68 } }, 3)):add(line({ { 240, 86 }, { 238, 66 } }, 2))
  F.shadow(222, 262, 128, 10, 3)
  local all = union(tr, roots, brs)
  rimOf(all, L.timber) part(tr, L.timber) part(roots, L.timber, { nopop = true }) part(brs, L.timber, { nopop = true })
  -- deep fissured bark, moss on the shaded side and in the crotch
  tr:each(function(x, y) if (x * 2 + y) % 9 == 0 or ((x + y // 3) % 6 == 0 and y > 100) then px(x, y, L.timber.deep) end end)
  tr:each(function(x, y) if x > 245 and hash(x // 2, y // 2, 61) < .55 then px(x, y, hash(x, y, 62) < .5 and L.moss.base or L.moss.shade) end end)
  F.moss(union(roots, brs), .25, 63)
  -- the hollow with a tawny owl looking out
  local hol = c:ellipse(240, 101, 4, 5)
  fill(hol, L.timber.edge)
  F.sprite({ "o...o", "OoOoO", "yEoEy", "oOvOo", "ooOoo", ".ooo." }, 238, 97, { o = L.needle.base, O = L.needle.hi, y = L.gold.hi, E = L.timber.edge, v = L.gold.base }, { rim = false })
  -- bracket fungi stepping up the trunk
  for _, b in ipairs({ { 232, 112 }, { 230, 116 }, { 253, 118 } }) do
    hline(b[1] - 2, b[1] + 2, b[2], L.board.hi) hline(b[1] - 2, b[1] + 2, b[2] + 1, L.needle.base) hline(b[1] - 1, b[1] + 1, b[2] + 2, L.needle.shade)
  end
  F.crown(210, 62, 24, 16, LF, 51) F.crown(270, 60, 24, 16, LF4, 52) F.crown(240, 48, 30, 18, LF, 53) F.crown(240, 72, 20, 10, LF2, 54)
  for i = 1, 46 do
    local ax, ay = 188 + floor(hash(i, 3, 1) * 104), 34 + floor(hash(i, 4, 1) * 48)
    if (ax - 240) ^ 2 / 2400 + (ay - 58) ^ 2 / 500 < 1 then
      local fr = (i % 5 == 0) and GOLD or AP
      fill(rect(ax, ay, ax + 1, ay + 1), fr.base) px(ax, ay, fr.hi) px(ax + 1, ay + 1, fr.shade)
    end
  end
  -- rope swing
  vline(216, 72, 112, WICK.deep) vline(228, 74, 112, WICK.deep)
  for y = 76, 110, 4 do px(216, y, WICK.base) px(228, y + 2, WICK.base) end
  local seat = rect(214, 112, 230, 114) rimOf(seat, L.timber) part(seat, L.board, { nopop = true })
  F.gnome(222, 112, { small = true, hat = L.awnA, coat = L.wall2, noShadow = true }) -- a little one swinging
end
oldTree()
table.sort(rows, function(a, b) return a[2] < b[2] end)
for i, r in ipairs(rows) do
  F.depth(r[2] < 140 and 1 or (r[2] < 170 and 2 or 3))
  local x = floor(r[1])
  if x > 0 and x < 480 and not (x > 370 and r[2] > 175) then
    if i % 5 == 3 and x > 20 and x < 460 then
      -- a conifer standing in the row: spruce or fir (no pines here, they need headroom)
      local sd = (i % 2 == 0) and 2 or 1
      F.tree(x, r[2], floor(56 * r[3]), sd + 4 * i)
    else
      fruitTree(x, r[2], r[3], i * 7 + 1, (i * 3 + x // 50) % 4 + 1)
    end
  end
end
-- forest edge pines framing the far right and left rows
F.depth(1)
F.tree(150, 124, 46, 3) F.tree(338, 122, 48, 7)

---------------------------------------------------------------- back-right: log barn (between the rows)
local function barn()
  local top, cx, wallM, roofM = F.building{ x0 = 404, x1 = 462, yb = 140, wh = 30, rh = 22, wall = L.timber, roof = L.roof2, shingle = true, noFrame = true, noAttic = true }
  F.logs(wallM, L.timber, top, 3)
  for y = top + 1, 138, 3 do F.logEnd(403, y, 1) F.logEnd(463, y, 1) end
  F.moss(roofM, .14, 81)
  local gab = poly{ { 406, top }, { 433, top - 20 }, { 460, top } }:cut(roofM)
  part(gab, L.board, { nopop = true }) F.planks(gab, L.board, 3, true, 24)
  hline(404, 462, top, L.timber.edge)
  local dm = rect(420, 118, 444, 139) fill(rect(419, 117, 445, 139), L.timber.edge) fill(dm, L.redbark.shade) F.planks(dm, L.redbark, 4, true, 21)
  local xb = line({ { 421, 119 }, { 443, 138 } }, 2):add(line({ { 443, 119 }, { 421, 138 } }, 2)):add(rect(420, 127, 444, 129)):clip(dm)
  fill(xb, L.board.base) xb:each(function(x, y) if not xb:has(x, y - 1) then px(x, y, L.board.hi) elseif not xb:has(x, y + 1) then px(x, y, L.board.deep) end end)
  vline(432, 118, 139, L.timber.edge) px(430, 132, L.iron.hi) px(434, 132, L.iron.hi)
  -- hay loft with a bundle of hazel withies
  local hay = rect(428, 104, 436, 110) fill(hay, L.soil.deep) fill(rect(428, 108, 436, 110), WICK.base) hline(428, 436, 108, WICK.hi)
  -- a ladder leaning on the barn and a stack of empty baskets
  local lad = line({ { 400, 140 }, { 408, 112 } }):add(line({ { 404, 140 }, { 412, 112 } }))
  for k = 1, 6 do local t = k / 7 lad:add(line({ { 400 + 8 * t, 140 - 28 * t }, { 404 + 8 * t, 140 - 28 * t } })) end
  c:rim(lad, L.timber.edge) fill(lad, L.board.base)
end
barn()

---------------------------------------------------------------- left hero: log cider press
F.depth(2)
F.birch(198, 182, 40, 45)
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
  local roofM = poly{ { x0 - 10, yb - 56 }, { x0 + 25, yb - 70 }, { x0 + 60, yb - 56 } }
  F.shadow(x0, x0 + 56, yb, 12, 4)
  rimOf(union(posts, beam, screw, bar, plate, tub, base, spout, roofM), L.timber)
  -- a little shingle hood keeps the rain off the screw
  part(roofM, L.roof, { sep = true }) F.courses(roofM, yb - 70, 3, 5, L.roof) F.moss(roofM, .25, 82)
  part(posts, L.redbark) posts:each(function(x, y) if hash(x, y // 3, 83) < .2 then px(x, y, L.redbark.shade) end end)
  part(beam, L.timber) F.logs(beam, L.timber, yb - 56, 7) F.logEnd(x0 - 4, yb - 53, 3) F.moss(beam, .15, 84)
  part(screw, IR, { nopop = true }) for y = yb - 49, yb - 29, 2 do hline(x0 + 23, x0 + 27, y, IR.deep) px(x0 + 23, y + 1, IR.hi) end
  part(bar, L.board, { nopop = true }) part(plate, L.board)
  part(tub, L.board) for x = x0 + 10, x0 + 40, 6 do vline(x, yb - 23, yb - 7, L.board.deep) end
  hline(x0 + 7, x0 + 43, yb - 20, IR.shade) hline(x0 + 8, x0 + 42, yb - 10, IR.shade)
  -- pulp oozing out under the plate
  for x = x0 + 9, x0 + 41, 2 do px(x, yb - 23, CIDER.shade) if x % 4 == 1 then px(x, yb - 22, CIDER.base) end end
  part(base, L.timber, { nopop = true }) F.logs(base, L.timber, yb - 6, 3) F.moss(base, .2, 85)
  part(spout, L.timber, { nopop = true })
  -- juice pouring into a bucket
  vline(x0 + 60, yb - 7, yb + 4, CIDER.base) vline(x0 + 61, yb - 7, yb + 4, CIDER.hi)
  local bk = poly{ { x0 + 54, yb + 4 }, { x0 + 68, yb + 4 }, { x0 + 66, yb + 14 }, { x0 + 56, yb + 14 } }
  rimOf(bk, L.timber) part(bk, L.board) hline(x0 + 55, x0 + 67, yb + 5, CIDER.base) hline(x0 + 56, x0 + 66, yb + 6, CIDER.shade) hline(x0 + 55, x0 + 67, yb + 8, IR.shade)
  -- a wasp at the sweet spout
  px(x0 + 64, yb - 12, L.gold.base) px(x0 + 65, yb - 12, L.timber.edge) px(x0 + 64, yb - 13, L.mist2)
end
press(92, 206)
-- a gnome turning the press bar
local _, tx, ty = F.gnome(80, 210, { hat = L.lav, coat = L.leaf, arm = "up" })
fill(line({ { tx, ty }, { 98, 166 } }), L.board.base)
-- heaps of crabs beside the press
local function heap(x0, x1, yb, fr)
  local m = poly{ { x0, yb }, { x0 + 4, yb - 7 }, { (x0 + x1) // 2, yb - 11 }, { x1 - 4, yb - 7 }, { x1, yb } }
  rimOf(m, fr) fill(m, fr.base)
  m:each(function(x, y) local k = (x + (y % 2) * 2) % 4 if k == 0 then px(x, y, fr.hi) elseif k == 3 then px(x, y, fr.shade) end end)
  for x = x0 + 4, x1 - 4, 7 do px(x, yb - 8 + (x % 3), LF.base) px(x + 1, yb - 9 + (x % 3), LF.hi) end
end
heap(30, 84, 214, AP)
heap(18, 44, 206, GOLD)
F.crate(24, 232, 22, 12, AP) F.crate(50, 234, 22, 12, PLUM) F.crate(36, 220, 22, 10, GOLD)
-- a wicker basket of hazelnuts against the crates
local function basket(x, yb, w, h, fr, nuts)
  local m = poly{ { x - w, yb - h }, { x + w, yb - h }, { x + w - 2, yb }, { x - w + 2, yb } }
  local handle = c:ellipse(x, yb - h, w - 2, h - 1):cut(c:ellipse(x, yb - h, w - 4, h - 3)):clip(rect(x - w, yb - 2 * h, x + w, yb - h - 1))
  rimOf(union(m, handle), WICK) part(handle, WICK, { nopop = true, noshade = true })
  part(m, WICK, { nopop = true })
  m:each(function(xx, yy) if (xx + yy) % 3 == 0 then px(xx, yy, WICK.shade) elseif (xx - yy) % 5 == 0 then px(xx, yy, WICK.hi) end end)
  for xx = x - w + 1, x + w - 1, 2 do
    if nuts then px(xx, yb - h - 1, NUT.base) px(xx + 1, yb - h - 1, L.needle.base) px(xx, yb - h - 2, NUT.hi)
    else px(xx, yb - h - 1, fr.base) px(xx + 1, yb - h - 1, fr.shade) px(xx, yb - h - 2, fr.hi) end
  end
end
basket(14 + 66, 226, 7, 6, nil, true)
-- stoneware cider jugs on a plank table
local tbl = rect(118, 226, 182, 229):add(rect(121, 230, 123, 242)):add(rect(177, 230, 179, 242))
F.shadow(120, 182, 242, 8, 3)
rimOf(tbl, L.timber) part(tbl, L.board, { nopop = true })
for k = 0, 3 do
  local x = 126 + k * 14
  local jr = ({ L.awnB, L.wall2, L.awnB, L.stone })[k + 1]
  local jug = c:rrect(x - 4, 214, x + 4, 225, 3):add(rect(x - 2, 210, x + 2, 214))
  rimOf(jug, L.timber) part(jug, jr)
  -- salt-glaze shoulder band
  hline(x - 3, x + 3, 216, (k % 2 == 0) and L.needle.shade or L.accent.shade)
  fill(rect(x + 4, 216, x + 6, 221), L.timber.edge) fill(rect(x + 4, 217, x + 5, 220), jr.shade)
  fill(rect(x - 2, 209, x + 2, 210), L.board.shade) px(x - 2, 209, L.board.hi) -- cork
end
-- a cup of cider and a little dish of crabs on the table
px(176, 224, CIDER.hi) px(177, 224, CIDER.base) fill(rect(176, 225, 178, 225), L.awnB.shade)
F.barrel(196, 250, L.timber, 14) F.barrel(186, 262, L.board, 12)
F.moss(rect(184, 236, 208, 240), .12, 86)
F.mushroom(206, 252, L.apple, true) F.mushroom(210, 254, L.apple)

---------------------------------------------------------------- right hero: picker on a ladder at a big front crab tree
fruitTree(408, 226, 2.3, 77, 1)
local lad = line({ { 352, 236 }, { 370, 168 } }, 2):add(line({ { 364, 238 }, { 382, 170 } }, 2))
for k = 0, 8 do local t = k / 8 lad:add(line({ { 352 + 18 * t, 236 - 68 * t }, { 364 + 18 * t, 238 - 68 * t } })) end
rimOf(lad, L.timber) part(lad, L.board, { nopop = true, noshade = true })
F.moss(line({ { 352, 236 }, { 356, 222 } }, 2), .5, 87)
local _, phx, phy = F.gnome(375, 190, { hat = L.awnA, coat = L.wall2, arm = "up", noShadow = true })
fill(rect(phx, phy - 2, phx + 1, phy - 1), AP.base) px(phx, phy - 2, AP.hi) -- a crab just picked
local bas = poly{ { 368, 186 }, { 380, 186 }, { 378, 194 }, { 370, 194 } } rimOf(bas, WICK) part(bas, WICK)
bas:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, WICK.shade) end end)
for k = 0, 4 do fill(rect(369 + k * 2, 184, 370 + k * 2, 185), AP.base) px(369 + k * 2, 184, AP.hi) end
-- crates by the road (right)
F.crate(290, 226, 22, 12, AP) F.crate(314, 228, 22, 12, GOLD) F.crate(300, 213, 22, 11, PLUM)
basket(330, 214, 6, 5, nil, true)
-- a gnome carrying a basket of mushrooms in from the wood
local _, ghx, ghy = F.gnome(336, 256, { hat = L.foliage, coat = L.roof2, arm = "out", flip = true })
local mb = poly{ { ghx - 6, ghy - 1 }, { ghx + 2, ghy - 1 }, { ghx + 1, ghy + 4 }, { ghx - 5, ghy + 4 } }
rimOf(mb, WICK) part(mb, WICK, { nopop = true })
F.mushroom(ghx - 4, ghy - 1, L.apple) F.mushroom(ghx - 1, ghy - 2, L.needle) F.mushroom(ghx + 1, ghy - 1, L.apple)
-- wheelbarrow of crabs
local wb = poly{ { 282, 246 }, { 312, 246 }, { 306, 256 }, { 288, 256 } }
local wbh = line({ { 282, 250 }, { 270, 256 } }, 2):add(rect(296, 256, 297, 262))
local wbw = c:ellipse(310, 260, 4, 4)
F.shadow(276, 314, 264, 6, 2)
rimOf(union(wb, wbh, wbw), L.timber) part(wbh, L.timber, { nopop = true, noshade = true }) part(wb, L.redbark) part(wbw, L.timber, { nopop = true })
F.planks(wb, L.redbark, 3, false, 23)
fill(c:ellipse(310, 260, 1, 1), L.iron.base)
for x = 285, 309, 3 do local fr = (x % 2 == 0) and AP or GOLD fill(rect(x, 243, x + 1, 245), fr.base) px(x, 243, fr.hi) px(x + 1, 245, fr.shade) end
px(292, 242, LF.base) px(293, 241, LF.hi)

---------------------------------------------------------------- forest-floor life in the orchard
-- ferns and young bracken at the row ends, mushroom rings in the damp rides
for _, f in ipairs({ { 22, 196, 6 }, { 28, 200, 5 }, { 110, 196, 5 }, { 268, 200, 5 }, { 458, 210, 6 }, { 450, 214, 5 },
  { 214, 236, 6 }, { 30, 250, 7 }, { 66, 254, 6 }, { 352, 210, 5 } }) do F.fern(f[1], f[2], f[3]) end
for i = 0, 7 do local a = i / 8 * 2 * pi F.mushroom(floor(150 + cos(a) * 12), floor(184 + sin(a) * 4), (i % 3 == 0) and L.needle or L.apple) end
for _, m in ipairs({ { 120, 252 }, { 236, 222 }, { 274, 232 }, { 96, 248 }, { 446, 202 } }) do F.mushroom(m[1], m[2], L.needle, true) end
-- a young spruce and a birch closing in on the near left
F.conifer(14 + 8, 268, 30, L.foliage2, 44)

---------------------------------------------------------------- windfalls + quirk hedgehog
for i = 0, 40 do
  local x, y = 20 + floor(hash(i, 5, 7) * 440), 150 + floor(hash(i, 6, 7) * 110)
  local fr = (i % 4 == 0) and PLUM or ((i % 4 == 1) and GOLD or AP)
  if not F.roadM:has(x, y) and not (x > 378 and y > 228) then px(x, y, fr.base) px(x + 1, y, fr.shade) px(x, y - 1, fr.hi) end
end
-- quirk: a hedgehog trundling off with a crab, a leaf and a little red mushroom stuck on its spines
F.shadowM(c:ellipse(222, 263, 13, 1))
F.sprite({
  "......llaaa...mm......",
  ".....lLaAAaa.mMmm.....",
  "......aAaaaaa..w......",
  "...sssaaaaaaasssS.....",
  "..sSsSaaaaaSsSsss.....",
  ".sSsSssaaasSsSsSss....",
  "sSsSsSsSsSsSsSsSsfff..",
  "sssSsSsSsSsSsSssffeff.",
  "ssssssssssssssssfffffn",
  ".sssssssssssssssfffff.",
  "...ff.......ff..ff....",
}, 206, 252, { l = LF.base, L = LF.hi, a = AP.base, A = AP.hi, s = L.soil.shade, S = L.soil.hi, f = L.board.hi, e = L.timber.edge, n = L.timber.edge,
  m = AP.shade, M = AP.hi, w = L.awnB.base })
-- a boar piglet (humbug stripes) snuffling the windfalls under the far-left trees
F.sprite({
  "..e...........",
  ".eBe.bBBBBB...",
  "bBBBBSSSSSSBb.",
  "nBEBBBBBBBBBBb",
  "nnBBBSSSSSSSBq",
  ".bBBBBBBBBBBb.",
  "..dd.dd..dd.d.",
}, 58, 162, { b = L.soil.shade, B = L.soil.base, S = L.needle.hi, E = L.timber.edge, n = L.petal.shade, q = L.soil.deep, e = L.soil.deep, d = L.timber.edge })
for _, a in ipairs({ { 52, 167 }, { 55, 169 }, { 76, 168 } }) do px(a[1], a[2], AP.base) px(a[1] + 1, a[2], AP.shade) px(a[1], a[2] - 1, AP.hi) end
-- a blackbird pecking a windfall by the road
F.sprite({ ".kk...", "kkkkk.", "kkkkky", ".k.k.." }, 182, 192, { k = "#3c3640", y = L.gold.base })
px(180, 195, AP.base) px(179, 195, AP.shade)
-- a red squirrel on the crate stack with a hazelnut
F.sprite({
  ".TTT......",
  "TTttT.....",
  "TTttT..r.r",
  "TTttTTrrRr",
  ".TTttTrRRe",
  "..TTtrrRrN",
  "...TrRrrNN",
  "...rrRRr..",
  "...rr.rr..",
}, 302, 193, { T = L.redbark.hi, t = L.redbark.shade, r = L.redbark.base, R = L.redbark.hi, e = L.timber.edge, N = NUT.base })
F.depth(0)
F.birds({ { 330, 40, 2 }, { 120, 48, 2 }, { 132, 42, 1 } })
F.finish()
