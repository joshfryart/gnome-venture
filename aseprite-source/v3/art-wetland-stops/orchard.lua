-- orchard.lua : "Orchard" stop look, WETLAND (wetland_reed), 480x270 gate view.
-- Same composition as the Maplewold orchard (art-2701-batch3/stops/opus3/orchard.lua), re-cast as a carr orchard
-- on raised dry banks in the fen: rows of apple trees stand on long banks with still dykes between them (mist lying
-- on the far ones, plank bridges, duck pairs), cranberry bog mats in the low strips, pollard willows, alders and
-- weeping willows standing in among the rows. Old trees carry grey lichen, crutch props and mistletoe.
-- Road's end: a great old lichened apple on a raised mound with mistletoe and a rope swing (a little gnome).
-- Back right: a weatherboard apple store raised on staddle stones, a ladder to its loft. Left hero: a silvered-board
-- screw cider press under a little reed hood on a boardwalk deck over a dark pool, a turning gnome, apple heaps on a
-- withy hurdle, crates, a basket of cranberries, stoneware jugs on a plank table, barrels.
-- Right hero: a picker on a willow-pole ladder at a big front apple on its own mound, crates, a cranberry scoop with a
-- kingfisher on it; in the near right a gnome wades a flooded cranberry bed raking floating berries behind a boom.
-- A water deer at the windfalls, a moorhen by the road. Quirk (kept): a hedgehog trundling off with an apple, a
-- willow leaf and a sprig of cranberries stuck on its spines.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-wetland-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "orchard", out = DIR, farTrees = { 24, 52, 100, 380, 410, 440 }, poolK = .81 }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local AP, IR = L.apple, L.iron
-- fen orchard ramps: olive apple green, lichen-grey green for the old trees, a yellowing crown
local LF = F.rp("#d0d486 #a4b05e #788a46 #546638 #344228")   -- olive orchard green
local LFG = F.rp("#cfd2a4 #a6ac7c #7e885e #5a6448 #3a4232")  -- grey-green (old lichened trees)
local LFY = F.rp("#e6dc84 #c2b85a #948c44 #686436 #403e26")  -- yellowing
local RUSSET = F.rp("#f0c486 #cc8e4c #a06636 #6e4428 #462a1e") -- russet apple
local GREEN = F.rp("#eaee9e #bcc65c #8e9c42 #626e34 #3e4628")  -- green cooking apple
local CRAN = F.rp("#ff9a90 #d63c4a #a42438 #6e1a2e #46121e")   -- cranberry
local BOG = F.rp("#a8a066 #8a7c4e #6c5842 #503e36 #34282a")    -- cranberry bog mat
local MIST = F.rp("#f6f29a #d8d23c #aab028 #6e7a20 #3e4a18")   -- mistletoe
local WICK = F.rp("#dccc94 #b69c64 #8e7648 #665436 #403428")   -- withy / wicker
local CIDER = F.rp("#f6e49a #e6c058 #c0963a #8c6a2c #5a4422")
local LICH = { "#c8cfb0", "#a8b094", "#d8d6a6" }               -- grey and yellow lichen

local function nearRoad(x, y, m) return x >= F.xl(y) - (m or 7) and x <= F.xr(y) + (m or 7) end
local function fruitDot(ax, ay, s, fr)
  if s > 1.1 then fill(rect(ax, ay, ax + 1, ay + 1), fr.base) px(ax, ay, fr.hi) px(ax + 1, ay + 1, fr.shade)
  else px(ax, ay, fr.base) if s > .7 then px(ax + 1, ay, fr.shade) end end
end
local function lichen(m, k, seed)
  m:each(function(x, y) if hash(x // 2, y // 2, seed) < k then
    local v = hash(x, y, seed + 1)
    if v < .5 then px(x, y, LICH[1]) elseif v < .8 then px(x, y, LICH[2]) else px(x, y, LICH[3]) end
  end end)
end
-- a ball of mistletoe in a crown: round tuft, forked sprigs at its edge, pale berries
local function mistletoe(x, y, r)
  r = r + 1
  local m = c:ellipse(x, y, r, math.max(1, r - 1))
  rimOf(m, MIST)
  m:each(function(xx, yy)
    local d = (xx - x) + (yy - y)
    local h = d < -r * .5 and MIST.hi or (d > r * .5 and MIST.shade or MIST.base)
    if (xx + yy * 2) % 4 == 0 then h = MIST.deep end
    px(xx, yy, h)
  end)
  for k = 0, 7 do
    local a = k * pi / 4 + .3
    local ex, ey = floor(x + cos(a) * (r + 1.6) + .5), floor(y + sin(a) * (r + .6) + .5)
    if not m:has(ex, ey) and (k + r) % 3 ~= 0 then px(ex, ey, (ex < x) and MIST.shade or MIST.deep) end
  end
  if r >= 2 then px(x - 1, y - 1, "#f2eedc") px(x + 1, y, "#e8e2c8") end
  if r >= 3 then px(x, y + 1, "#f2eedc") px(x - r - 1, y - 1, MIST.base) px(x + r + 1, y - 1, MIST.shade) end
  return m
end
-- a wicker basket (withy), filled with fruit
local function basket(x, yb, w, h, fr)
  local m = poly{ { x - w, yb - h }, { x + w, yb - h }, { x + w - 2, yb }, { x - w + 2, yb } }
  local handle = c:ellipse(x, yb - h, w - 2, h - 1):cut(c:ellipse(x, yb - h, w - 4, h - 3)):clip(rect(x - w, yb - 2 * h, x + w, yb - h - 1))
  rimOf(union(m, handle), WICK) part(handle, WICK, { nopop = true, noshade = true })
  part(m, WICK, { nopop = true })
  m:each(function(xx, yy) if (xx + yy) % 3 == 0 then px(xx, yy, WICK.shade) elseif (xx - yy) % 5 == 0 then px(xx, yy, WICK.hi) end end)
  for xx = x - w + 1, x + w - 1, 2 do px(xx, yb - h - 1, fr.base) px(xx + 1, yb - h - 1, fr.shade) px(xx, yb - h - 2, fr.hi) end
end

-- fruit trees in four kinds so the rows never repeat one shape:
--   1 round apple (red / russet, now and then a ball of mistletoe), 2 old leaning apple on a forked crutch prop,
--   lichened, green cookers, 3 wide old lichened spreader with mistletoe, 4 young whip in a woven withy guard.
local function fruitTree(x, yb, s, seed, kind, lrO)
  kind = kind or (seed % 4) + 1
  local lr = lrO or ({ LF, LFY, LF, LFG })[(seed // 4) % 4 + 1]
  local fr = ({ AP, GREEN, AP, RUSSET })[kind]
  if kind == 1 and seed % 3 == 0 then fr = RUSSET end
  if kind == 2 then lr = (seed % 2 == 0) and LFG or LF end
  if kind == 3 then lr = LFG end
  local lean = (hash(seed, 1, 9) - .5) * 4 * s
  local w2 = math.max(1, floor(2 * s))
  if kind == 1 then
    local tr = poly{ { x - 3 * s, yb }, { x - 2 * s + lean, yb - 12 * s }, { x + 2 * s + lean, yb - 12 * s }, { x + 3 * s, yb } }
    local brs = line({ { x + lean, yb - 10 * s }, { x - 8 * s, yb - 18 * s } }, w2):add(line({ { x + lean, yb - 10 * s }, { x + 8 * s, yb - 19 * s } }, w2))
    F.shadowM(c:ellipse(x + 4 * s, yb, 13 * s, 2 * s))
    rimOf(union(tr, brs), L.willowBark) part(tr, L.willowBark, { nopop = true }) part(brs, L.willowBark, { nopop = true, noshade = true })
    if s > .8 then lichen(tr, .25, seed) end
    F.crown(x - 6 * s, yb - 22 * s, 9 * s, 7 * s, lr, seed) F.crown(x + 6 * s, yb - 23 * s, 9 * s, 7 * s, lr, seed + 1) F.crown(x + lean, yb - 29 * s, 10 * s, 7 * s, lr, seed + 2)
    for i = 1, floor(9 * s * s) + 3 do local a, rr = hash(i, seed, 1) * 2 * pi, math.sqrt(hash(i, seed, 2)) * .95 fruitDot(floor(x + cos(a) * rr * 13 * s), floor(yb - 25 * s + sin(a) * rr * 9 * s), s, fr) end
    if seed % 5 == 1 and s > .6 then mistletoe(floor(x + 5 * s), floor(yb - 28 * s), math.max(1, floor(2 * s))) end
  elseif kind == 2 then
    -- an old tree leaning hard to one side, its low limb held up on a forked crutch prop
    local dir = (seed % 2 == 0) and 1 or -1
    local tr = poly{ { x - 3 * s, yb }, { x + 3 * s, yb }, { x + (2 + 7 * dir) * s, yb - 12 * s }, { x + (-2 + 7 * dir) * s, yb - 12 * s } }
    local limb = line({ { x + 6 * dir * s, yb - 10 * s }, { x + 16 * dir * s, yb - 12 * s } }, w2)
    local px0 = floor(x + 14 * dir * s)
    local prop = line({ { px0, yb }, { px0, yb - 11 * s } }):add(line({ { px0, floor(yb - 10 * s) }, { px0 - 1, floor(yb - 12 * s) } })):add(line({ { px0, floor(yb - 10 * s) }, { px0 + 1, floor(yb - 12 * s) } }))
    F.shadowM(c:ellipse(x + 6 * dir * s + 3 * s, yb, 15 * s, 2 * s))
    rimOf(union(tr, limb), L.willowBark) part(tr, L.willowBark, { nopop = true }) part(limb, L.willowBark, { nopop = true, noshade = true })
    if s > .6 then c:rim(prop, L.timber.edge) fill(prop, L.board.base) prop:each(function(xx, yy) if hash(xx, yy, seed) < .4 then px(xx, yy, L.board.shade) end end) end
    if s > .7 then lichen(union(tr, limb), .3, seed) end
    F.crown(x + 8 * dir * s, yb - 20 * s, 10 * s, 7 * s, lr, seed) F.crown(x + 15 * dir * s, yb - 16 * s, 7 * s, 5 * s, lr, seed + 1) F.crown(x + 4 * dir * s, yb - 25 * s, 8 * s, 6 * s, lr, seed + 2)
    for i = 1, floor(8 * s * s) + 3 do local a, rr = hash(i, seed, 1) * 2 * pi, math.sqrt(hash(i, seed, 2)) * .9 fruitDot(floor(x + 9 * dir * s + cos(a) * rr * 13 * s), floor(yb - 20 * s + sin(a) * rr * 7 * s), s, fr) end
  elseif kind == 3 then
    local tr = poly{ { x - 4 * s, yb }, { x - 3 * s, yb - 8 * s }, { x + 3 * s, yb - 8 * s }, { x + 4 * s, yb } }
    local brs = line({ { x, yb - 7 * s }, { x - 13 * s, yb - 13 * s } }, w2 + 1):add(line({ { x, yb - 7 * s }, { x + 13 * s, yb - 12 * s } }, w2 + 1))
    F.shadowM(c:ellipse(x + 4 * s, yb, 17 * s, 2 * s))
    rimOf(union(tr, brs), L.willowBark) part(tr, L.willowBark, { nopop = true }) part(brs, L.willowBark, { nopop = true, noshade = true })
    if s > .6 then lichen(union(tr, brs), .35, seed) end
    F.crown(x - 11 * s, yb - 18 * s, 9 * s, 7 * s, lr, seed) F.crown(x + 11 * s, yb - 18 * s, 9 * s, 7 * s, lr, seed + 1) F.crown(x, yb - 24 * s, 12 * s, 9 * s, lr, seed + 2)
    for i = 1, floor(10 * s * s) + 3 do local a, rr = hash(i, seed, 1) * 2 * pi, hash(i, seed, 2) fruitDot(floor(x + cos(a) * rr * 19 * s), floor(yb - 20 * s + sin(a) * rr * 7 * s), s, fr) end
    if s > .55 then mistletoe(floor(x - 9 * s), floor(yb - 20 * s), math.max(1, floor(2 * s))) mistletoe(floor(x + 6 * s), floor(yb - 27 * s), math.max(1, floor(1.5 * s))) end
  else
    local tr = rect(floor(x), floor(yb - 14 * s), floor(x + math.max(1, s)), yb)
    local stake = rect(floor(x + 3 * s), floor(yb - 12 * s), floor(x + 3 * s), yb)
    local guard = rect(floor(x - 2 * s), floor(yb - 5 * s), floor(x + 2 * s + 1), yb)
    F.shadowM(c:ellipse(x + 3 * s, yb, 7 * s, 1 + s))
    rimOf(union(tr, stake), L.timber) part(tr, L.willowBark, { nopop = true, noshade = true }) part(stake, L.board, { nopop = true, noshade = true })
    F.crown(x, yb - 18 * s, 6 * s, 6 * s, (seed % 2 == 0) and LF or LFY, seed)
    if s > .7 then -- woven withy guard
      rimOf(guard, WICK) fill(guard, WICK.base)
      guard:each(function(xx, yy) local k = (xx + (yy // 2) * 2) % 4 if k == 0 then px(xx, yy, WICK.hi) elseif k == 2 then px(xx, yy, WICK.deep) end end)
    end
    for i = 1, 3 do fruitDot(floor(x + (hash(i, seed, 1) - .5) * 8 * s), floor(yb - 18 * s + (hash(i, seed, 2) - .5) * 6 * s), s, (seed % 2 == 0) and AP or GREEN) end
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
-- the strips between the banks: mown sedge on some, cranberry bog mats on others
local function bogPx(x, y)
  local v = hash(x // 2, y, 95)
  local h = v < .4 and BOG.base or (v < .7 and BOG.shade or (v < .85 and BOG.hi or CRAN.deep))
  if (x + y * 3) % 7 == 0 then h = BOG.deep end
  local near = (y - 112) / 158
  if hash(x, y, 96) < .05 + near * .1 then h = CRAN.base if hash(x, y, 97) < .4 then px(x, y - 1, CRAN.hi) end end
  px(x, y, h)
end
for y = 116, 229 do
  local d = y - 108
  local band = floor(60 / d * 6)
  for x = 14, 465 do
    if not nearRoad(x, y, 6) and not F.poolAt(x, y) then
      if (y >= 135 and y <= 139) or (y >= 168 and y <= 177) then
        if hash(x // 9, y // 3, 98) < .82 then bogPx(x, y) end
      elseif band % 2 == 0 and hash(x // 3, y, 91) < .7 then
        px(x, y, hash(x, y, 99) < .5 and L.sedgeGround.hi or F.mix(L.ground.base, L.sedgeGround.hi, .5))
      end
    end
  end
end
-- each row stands on a raised bank: a lit top lip, a darker band of shade under the trees
for _, r in ipairs(rows) do
  local y = floor(r[2])
  for x = 14, 465 do if not nearRoad(x, y + 1, 6) and hash(x, y, 92) < .55 then px(x, y + 1, L.sedgeGround.shade) px(x, y + 2, F.mix(L.sedgeGround.shade, L.ground.base, .5)) end end
end
-- the dykes between the banks: bank face, dark lip, sky streaks, a muddy near edge
local dykes = { { 129, 1, 1 }, { 141, 2, 1 }, { 157, 2, 2 }, { 180, 3, 2 } }
local function dyke(yd, w, dep)
  F.depth(dep)
  for x = 12, 467 do
    if not nearRoad(x, yd, 5) then
      px(x, yd - 1, (x % 5 == 0) and L.peat.deep or L.peat.shade)
      if w >= 2 then px(x, yd - 2, hash(x, yd, 101) < .5 and L.peat.base or L.sedgeGround.shade) end
      for k = 0, w - 1 do
        local y = yd + k
        local col
        if k == 0 then col = L.water.deep
        else
          local v = hash((x + y * 7) // 7, y, 102)
          col = v < .35 and F.SKYREF or (v < .5 and L.water.hi or L.water.base)
        end
        px(x, y, col)
      end
      px(x, yd + w, hash(x, yd, 103) < .6 and L.peat.hi or L.peat.base)
    end
  end
end
for _, dk in ipairs(dykes) do dyke(dk[1], dk[2], dk[3]) end
-- low mist lying on the far dykes
F.depth(1)
F.mist(14, 200, 127, 131, 93, .55) F.mist(282, 466, 127, 131, 94, .55)
F.mist(20, 180, 139, 142, 95, .4) F.mist(300, 460, 139, 142, 96, .4)

F.depth(2)
---------------------------------------------------------------- great old lichened apple on a mound at the road's end
local function oldTree()
  -- the mound, a raised island of turf with a peat face and dyke water on either side
  local mound = c:ellipse(240, 126, 28, 4)
  rimOf(mound, L.peat)
  mound:each(function(x, y)
    local h = (y >= 128) and (hash(x, y, 111) < .5 and L.peat.base or L.peat.shade) or (hash(x // 2, y, 112) < .3 and L.sedgeGround.hi or L.sedgeGround.base)
    if y == 127 then h = L.peat.hi end
    px(x, y, h)
  end)
  for _, w in ipairs({ { 204, 214 }, { 266, 276 } }) do hline(w[1], w[2], 129, L.water.deep) hline(w[1] + 1, w[2] - 1, 130, F.SKYREF) end
  local tr = poly{ { 226, 126 }, { 233, 104 }, { 234, 96 }, { 230, 84 }, { 250, 84 }, { 246, 96 }, { 247, 104 }, { 254, 126 } }
  local roots = poly{ { 218, 127 }, { 230, 119 }, { 232, 127 } }:add(poly{ { 248, 127 }, { 251, 118 }, { 262, 127 } })
  local brs = line({ { 236, 90 }, { 212, 70 } }, 3):add(line({ { 246, 88 }, { 270, 68 } }, 3)):add(line({ { 240, 86 }, { 238, 66 } }, 2))
  F.shadow(222, 262, 125, 10, 2)
  local all = union(tr, roots, brs)
  rimOf(all, L.willowBark) part(tr, L.willowBark) part(roots, L.willowBark, { nopop = true }) part(brs, L.willowBark, { nopop = true })
  -- deep twisting fissures, grey lichen on the lit side, a split and a wound
  tr:each(function(x, y) if (x * 2 + y) % 9 == 0 or ((x - y // 4) % 7 == 0 and y > 98) then px(x, y, L.willowBark.deep) end end)
  tr:each(function(x, y) if x < 238 and hash(x // 2, y // 3, 113) < .2 then px(x, y, hash(x, y, 114) < .6 and LICH[1] or LICH[2]) end end)
  tr:each(function(x, y) if x > 246 and hash(x // 2, y // 3, 115) < .15 then px(x, y, LICH[3]) end end)
  lichen(roots, .3, 116)
  fill(c:ellipse(241, 108, 1, 3), L.timber.edge) px(240, 106, L.willowBark.shade)
  F.crown(210, 62, 24, 16, LF, 51) F.crown(270, 60, 24, 16, LFG, 52) F.crown(240, 48, 30, 18, LF, 53) F.crown(240, 72, 20, 10, LFY, 54)
  for i = 1, 46 do
    local ax, ay = 188 + floor(hash(i, 3, 1) * 104), 34 + floor(hash(i, 4, 1) * 48)
    if (ax - 240) ^ 2 / 2400 + (ay - 58) ^ 2 / 500 < 1 then
      local fr = (i % 5 == 0) and RUSSET or AP
      fill(rect(ax, ay, ax + 1, ay + 1), fr.base) px(ax, ay, fr.hi) px(ax + 1, ay + 1, fr.shade)
    end
  end
  -- three balls of mistletoe high in the old crown
  mistletoe(258, 46, 4) mistletoe(222, 56, 3) mistletoe(278, 66, 2)
  -- rope swing (reed-twist rope)
  vline(216, 72, 112, L.reed.deep) vline(228, 74, 112, L.reed.deep)
  for y = 76, 110, 3 do px(216, y, L.reed.shade) px(228, y + 1, L.reed.shade) end
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
      -- a carr tree standing in the row: weeping willow, alder or pollard willow
      F.tree(x, r[2], floor(54 * r[3]), i * 3)
    else
      fruitTree(x, r[2], r[3], i * 7 + 1, (i * 3 + x // 50) % 4 + 1)
    end
  end
end
-- pollard willows at the dyke ends, a windbreak along the far banks
F.depth(1)
F.pollard(150, 141, 36, 7) F.pollard(338, 141, 36, 11)
F.depth(2)
F.pollard(186, 157, 30, 15)
-- plank bridges over the dykes
local function bridge(x, yd, w, dep)
  F.depth(dep)
  local x1 = x + 8 + w * 2
  local m = rect(x, yd - 3, x1, yd + w + 1)
  rimOf(m, L.timber) part(m, L.board, { nopop = true })
  for xx = x, x1, 3 do vline(xx, yd - 3, yd + w + 1, L.board.deep) end
  hline(x, x1, yd - 3, L.board.hi) hline(x, x1, yd + w + 1, L.timber.deep)
  vline(x, yd - 6, yd - 3, L.timber.base) vline(x1, yd - 6, yd - 3, L.timber.base) hline(x, x1, yd - 6, L.timber.hi) -- hand rail
end
bridge(64, 141, 2, 1) bridge(404, 141, 2, 1) bridge(110, 157, 2, 2) bridge(370, 157, 2, 2)
-- a pair of mallards on the right near dyke
F.depth(2)
local function mallard(x, y, drake)
  local rows_ = {
    ".....gg.",
    "....gGgy",
    "bbbbwg..",
    "BBBBBBb.",
    ".BBBBB..",
  }
  local map = drake and { g = "#3c6e54", G = "#5c9a72", y = L.marigold.base, w = L.awnB.hi, b = L.soil.base, B = L.goose.hi }
    or { g = L.goose.shade, G = L.goose.base, y = L.produce.shade, w = L.goose.base, b = L.goose.shade, B = L.goose.base }
  F.sprite(rows_, x, y - 4, map)
  for xx = x - 2, x + 9 do if hash(xx, y, 117) < .6 then px(xx, y + 1, xx < x + 3 and L.water.hi or F.SKYREF) end end
end
mallard(292, 181, true) mallard(304, 182, false)

-- ladders: willow-pole rails, lashed rungs
local function ladder(x0, y0, x1, y1, w, n, pole)
  local dx, dy = x1 - x0, y1 - y0
  local rails = line({ { x0, y0 }, { x1, y1 } }, pole or 1):add(line({ { x0 + w, y0 + 1 }, { x1 + w, y1 + 1 } }, pole or 1))
  local rungs = HP.mask()
  for k = 1, n do local t = k / (n + 1) rungs:add(line({ { floor(x0 + dx * t) + 1, floor(y0 + dy * t) }, { floor(x0 + w + dx * t) - 1, floor(y0 + 1 + dy * t) } })) end
  rungs:cut(rails)
  return union(rails, rungs), rails, rungs
end
F.depth(2)
do
end
-- a second ladder, leaning in a tree among the rows
F.depth(2)
do
  local lm = ladder(204, 160, 210, 134, 5, 5, 1)
  rimOf(lm, L.timber) part(lm, L.willowBark, { nopop = true, noshade = true })
end

F.depth(1)
---------------------------------------------------------------- back-right: weatherboard apple store on staddle stones
local function store()
  fill(rect(404, 134, 462, 140), L.shadow)
  for y = 135, 140 do for x = 404, 462 do if hash(x // 3, y, 121) < .25 then px(x, y, L.peat.deep) end end end
  local top, cx, wallM, roofM = F.building{ x0 = 404, x1 = 462, yb = 133, wh = 24, rh = 20, wall = L.wall2, roof = L.roof, noFrame = true, noAttic = true, noShadow = true }
  F.planks(wallM:copy():clip(rect(404, top + 2, 462, 133)), L.wall2, 3, false, 7)
  F.moss(roofM, .08, 122)
  -- staddle stones (stone mushrooms keep the apples off the damp)
  for _, sx in ipairs({ 407, 419, 431, 443, 457 }) do
    local st = rect(sx - 1, 136, sx + 1, 140):add(rect(sx - 3, 134, sx + 3, 135))
    rimOf(st, L.stone) part(st, L.stone, { nopop = true }) hline(sx - 3, sx + 3, 134, L.stone.hi) px(sx - 1, 137, L.stone.hi)
  end
  -- double doors with ledge-and-brace, a hay-loft hatch, steps
  local dm = rect(422, 112, 442, 133)
  fill(rect(421, 111, 443, 133), L.timber.edge) fill(dm, L.board.shade) F.planks(dm, L.board, 3, true, 21)
  local xb = line({ { 423, 114 }, { 431, 131 } }, 1):add(line({ { 441, 114 }, { 433, 131 } }, 1)):add(rect(422, 116, 442, 117)):add(rect(422, 128, 442, 129)):clip(dm)
  fill(xb, L.board.base) xb:each(function(x, y) if not xb:has(x, y - 1) then px(x, y, L.board.hi) end end)
  vline(432, 112, 133, L.timber.edge) px(430, 122, L.iron.hi) px(434, 122, L.iron.hi)
  local hatch = rect(428, top - 10, 436, top - 3) fill(hatch, L.timber.edge) fill(rect(429, top - 9, 435, top - 3), L.soil.deep)
  fill(rect(429, top - 6, 435, top - 3), AP.shade) for x = 429, 435, 2 do px(x, top - 6, AP.base) px(x, top - 7, AP.hi) end
  local steps = rect(426, 134, 438, 135):add(rect(424, 137, 440, 138))
  rimOf(steps, L.timber) part(steps, L.board, { nopop = true })
  -- a ladder leaning up to the loft, apple crates stacked at the corner
  local lad, ra, ru = ladder(397, 140, 409, 110, 5, 6)
  c:rim(lad, L.timber.edge) fill(ra, L.willowBark.base) fill(ru, L.board.hi)
  F.crate(446, 140, 12, 6, AP) F.crate(448, 133, 10, 5, GREEN)
end
store()

---------------------------------------------------------------- left hero: cider press on a boardwalk deck over a dark pool
F.depth(2)
F.tree(198, 186, 44, 1) -- an alder by the near dyke
F.depth(3)
local dpool = poly{ { 70, 211 }, { 170, 210 }, { 172, 219 }, { 150, 224 }, { 96, 224 }, { 72, 220 } }
rimOf(dpool, L.peat)
F.water(dpool, L.water, { dark = true })
for _, sx in ipairs({ 80, 98, 118, 138, 158 }) do for y = 214, 222, 2 do if dpool:has(sx, y) then px(sx, y, L.water.deep) px(sx + 1, y, L.water.shade) end end end
F.stilts({ 76, 94, 114, 134, 154, 164 }, 210, 220, 215)
local deck = rect(70, 205, 168, 210)
F.boardwalk(deck, true, 33)
hline(70, 168, 210, L.board.deep)
local function press(x0, yb)
  local posts = rect(x0, yb - 52, x0 + 4, yb):add(rect(x0 + 46, yb - 52, x0 + 50, yb))
  local beam = rect(x0 - 4, yb - 56, x0 + 54, yb - 50)
  local screw = rect(x0 + 23, yb - 50, x0 + 27, yb - 28)
  local bar = rect(x0 + 6, yb - 42, x0 + 44, yb - 40)
  local plate = rect(x0 + 10, yb - 28, x0 + 40, yb - 24)
  local tub = poly{ { x0 + 6, yb - 24 }, { x0 + 44, yb - 24 }, { x0 + 42, yb - 6 }, { x0 + 8, yb - 6 } }
  local base = rect(x0 - 4, yb - 6, x0 + 54, yb)
  local spout = rect(x0 + 52, yb - 10, x0 + 60, yb - 8)
  local roofM = poly{ { x0 - 10, yb - 55 }, { x0 + 25, yb - 72 }, { x0 + 60, yb - 55 }, { x0 + 60, yb - 53 }, { x0 - 10, yb - 53 } }
  rimOf(union(posts, beam, screw, bar, plate, tub, base, spout, roofM), L.timber)
  -- a little reed-thatched hood keeps the rain off the screw, with a sedge ridge
  part(roofM, L.roof, { sep = true }) F.thatch(roofM, L.roof, yb - 72, x0 + 25)
  line({ { x0 - 9, yb - 55 }, { x0 + 25, yb - 72 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  roofM:each(function(x, y) if y <= yb - 69 then px(x, y, x < x0 + 25 and L.roof2.base or L.roof2.shade) end end)
  hline(x0 - 10, x0 + 60, yb - 53, L.roof.deep)
  px(x0 + 25, yb - 73, L.roof2.hi)
  -- silvered willow-board posts and a tarred beam, lichen on the weather side
  part(posts, L.board) posts:each(function(x, y) if (x == x0 + 2 or x == x0 + 48) and hash(x, y // 3, 83) < .5 then px(x, y, L.board.shade) end end)
  lichen(posts, .12, 84)
  part(beam, L.willowBark) hline(x0 - 4, x0 + 54, yb - 52, L.willowBark.hi) for x = x0, x0 + 50, 10 do px(x, yb - 51, L.iron.hi) end
  part(screw, IR, { nopop = true }) for y = yb - 49, yb - 29, 2 do hline(x0 + 23, x0 + 27, y, IR.deep) px(x0 + 23, y + 1, IR.hi) end
  part(bar, L.board, { nopop = true }) part(plate, L.willowBark)
  part(tub, L.board) for x = x0 + 10, x0 + 40, 6 do vline(x, yb - 23, yb - 7, L.board.deep) end
  hline(x0 + 7, x0 + 43, yb - 20, IR.shade) hline(x0 + 8, x0 + 42, yb - 10, IR.shade)
  hline(x0 + 7, x0 + 43, yb - 21, IR.hi)
  -- pomace oozing out under the plate
  for x = x0 + 9, x0 + 41, 2 do px(x, yb - 23, CIDER.shade) if x % 4 == 1 then px(x, yb - 22, GREEN.shade) end end
  part(base, L.willowBark, { nopop = true }) F.planks(base, L.willowBark, 3, false, 25)
  part(spout, L.willowBark, { nopop = true })
  -- juice pouring into a bucket
  vline(x0 + 60, yb - 7, yb + 4, CIDER.base) vline(x0 + 61, yb - 7, yb + 4, CIDER.hi)
  local bk = poly{ { x0 + 54, yb + 4 }, { x0 + 68, yb + 4 }, { x0 + 66, yb + 14 }, { x0 + 56, yb + 14 } }
  rimOf(bk, L.timber) part(bk, L.board) hline(x0 + 55, x0 + 67, yb + 5, CIDER.base) hline(x0 + 56, x0 + 66, yb + 6, CIDER.shade) hline(x0 + 55, x0 + 67, yb + 8, IR.shade)
  -- a wasp at the sweet spout
  px(x0 + 64, yb - 12, L.gold.base) px(x0 + 65, yb - 12, L.timber.edge) px(x0 + 64, yb - 13, L.mist2)
end
press(92, 204)
-- a gnome turning the press bar
local _, tx, ty = F.gnome(80, 209, { hat = L.lav, coat = L.accent, arm = "up" })
fill(line({ { tx, ty }, { 98, 164 } }), L.board.base)
-- heaps of apples on a withy hurdle beside the press
local function heap(x0, x1, yb, fr)
  local m = poly{ { x0, yb }, { x0 + 4, yb - 7 }, { (x0 + x1) // 2, yb - 11 }, { x1 - 4, yb - 7 }, { x1, yb } }
  rimOf(m, fr) fill(m, fr.base)
  m:each(function(x, y) local k = (x + (y % 2) * 2) % 4 if k == 0 then px(x, y, fr.hi) elseif k == 3 then px(x, y, fr.shade) end end)
  for x = x0 + 4, x1 - 4, 7 do px(x, yb - 8 + (x % 3), LF.base) px(x + 1, yb - 9 + (x % 3), LF.hi) end
end
local hurdle = rect(14, 213, 70, 217)
F.shadow(16, 72, 217, 6, 2)
rimOf(hurdle, WICK) fill(hurdle, WICK.base)
hurdle:each(function(x, y) local k = (x + (y % 2) * 2) % 4 if k == 0 then px(x, y, WICK.hi) elseif k == 2 then px(x, y, WICK.deep) end end)
for x = 16, 68, 8 do vline(x, 211, 219, L.willowBark.shade) px(x, 211, L.willowBark.hi) end
heap(30, 70, 214, AP)
heap(14, 40, 208, GREEN)
F.crate(24, 232, 22, 12, AP) F.crate(50, 234, 22, 12, CRAN) F.crate(36, 220, 22, 10, RUSSET)
basket(84, 230, 7, 6, CRAN)
-- stoneware cider jugs on a plank table, a dish of cranberries
local tbl = rect(118, 226, 182, 229):add(rect(121, 230, 123, 242)):add(rect(177, 230, 179, 242))
F.shadow(120, 182, 242, 8, 3)
rimOf(tbl, L.timber) part(tbl, L.board, { nopop = true })
for k = 0, 3 do
  local x = 126 + k * 14
  local jr = ({ L.awnB, L.wall2, L.plaster, L.stone })[k + 1]
  local jug = c:rrect(x - 4, 214, x + 4, 225, 3):add(rect(x - 2, 210, x + 2, 214))
  rimOf(jug, L.timber) part(jug, jr)
  hline(x - 3, x + 3, 216, (k % 2 == 0) and L.willowBark.shade or L.accent.shade)
  fill(rect(x + 4, 216, x + 6, 221), L.timber.edge) fill(rect(x + 4, 217, x + 5, 220), jr.shade)
  fill(rect(x - 2, 209, x + 2, 210), L.board.shade) px(x - 2, 209, L.board.hi) -- cork
end
local dish = c:ellipse(174, 224, 4, 1) rimOf(dish, L.timber) fill(dish, L.awnB.shade)
for x = 171, 177, 2 do px(x, 223, CRAN.base) px(x + 1, 223, CRAN.shade) px(x, 222, CRAN.hi) end
-- a boardwalk path from the press deck down across the wet ground
do
  local bw = poly{ { 98, 224 }, { 112, 224 }, { 108, 269 }, { 88, 269 } }
  F.shadow(90, 112, 269, 3, 1)
  F.boardwalk(bw, false, 37)
  bw:each(function(x, y) if (y - 224) % 4 == 0 and (x == 98 + floor((y - 224) * -.22) or x == 111 - floor((y - 224) * .09)) then px(x, y, L.iron.shade) end end)
  for _, sx in ipairs({ 90, 109 }) do for y = 232, 266, 11 do vline(sx + floor((y - 232) * (sx == 90 and -.05 or -.04)), y - 3, y + 1, L.timber.base) px(sx, y - 3, L.timber.hi) end end
end
F.frog(26, 252, false)
F.barrel(196, 250, L.timber, 14) F.barrel(186, 262, L.board, 12)
lichen(rect(182, 238, 210, 240), .12, 86)
for _, m in ipairs({ { 206, 252 }, { 211, 254 } }) do F.sedge(m[1], m[2], 5) px(m[1] - 1, m[2] - 4, L.marigold.base) px(m[1], m[2] - 5, L.marigold.hi) px(m[1] + 1, m[2] - 4, L.marigold.shade) end

---------------------------------------------------------------- right hero: picker on a ladder at a big front apple on its mound
F.depth(3)
do
  local mnd = c:ellipse(410, 224, 42, 5)
  rimOf(mnd, L.peat)
  mnd:each(function(x, y)
    local h = (y >= 227) and (hash(x, y, 131) < .5 and L.peat.base or L.peat.shade) or (hash(x // 2, y, 132) < .35 and L.sedgeGround.hi or L.sedgeGround.base)
    if y == 226 then h = L.peat.hi end
    px(x, y, h)
  end)
  for k = 0, 6 do F.sedge(372 + k * 11, 223 + (k % 2), 4) end
end
fruitTree(408, 226, 2.3, 77, 1, LF)
mistletoe(436, 168, 3)
local lad = ladder(352, 236, 370, 168, 12, 8, 2)
rimOf(lad, L.timber) part(lad, L.willowBark, { nopop = true, noshade = true })
for k = 1, 8 do local t = k / 9 local lx, ly = floor(352 + 18 * t), floor(236 - 68 * t) px(lx - 1, ly, L.reed.deep) px(lx + 13, ly + 1, L.reed.deep) end
local _, phx, phy = F.gnome(375, 190, { hat = L.awnA, coat = L.wall2, arm = "up", noShadow = true })
fill(rect(phx, phy - 2, phx + 1, phy - 1), AP.base) px(phx, phy - 2, AP.hi) -- an apple just picked
local bas = poly{ { 368, 186 }, { 380, 186 }, { 378, 194 }, { 370, 194 } } rimOf(bas, WICK) part(bas, WICK)
bas:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, WICK.shade) end end)
for k = 0, 4 do fill(rect(369 + k * 2, 184, 370 + k * 2, 185), AP.base) px(369 + k * 2, 184, AP.hi) end
-- crates by the road (right)
F.crate(290, 226, 22, 12, AP) F.crate(314, 228, 22, 12, CRAN) F.crate(300, 213, 22, 11, RUSSET)
-- a cranberry scoop (a toothed wooden box on a handle) leaning on the crates, a kingfisher on its handle
do
  local sc = poly{ { 336, 216 }, { 348, 214 }, { 349, 225 }, { 337, 227 } }
  local hd = line({ { 346, 215 }, { 344, 196 } }, 2)
  rimOf(union(sc, hd), L.timber) part(hd, L.board, { nopop = true, noshade = true }) part(sc, L.board, { nopop = true })
  F.planks(sc, L.board, 3, false, 41)
  for x = 337, 348, 2 do px(x, 228, L.board.deep) end
  for x = 338, 347, 3 do px(x, 216, CRAN.base) px(x + 1, 216, CRAN.shade) px(x, 215, CRAN.hi) end
  F.sprite({
    "..BBb..",
    ".BBBBb.",
    "BBkBBbb",
    "Y.OOBb.",
    "...OOBb",
    "...OOb.",
    "....bb.",
    "....bb.",
  }, 340, 188, { B = "#4aa0b0", b = "#2e6e86", k = L.timber.edge, Y = L.timber.edge, O = L.produce.base })
end
-- a flooded cranberry bed in the near right: a gnome wading, raking the floating berries in behind a boom
F.depth(3)
local bed = poly{ { 322, 244 }, { 336, 240 }, { 356, 241 }, { 368, 245 }, { 374, 254 }, { 372, 264 }, { 364, 269 }, { 318, 269 }, { 312, 259 }, { 314, 250 } }
rimOf(bed, L.peat)
local bbank = bed:grow(2):cut(bed)
bbank:each(function(x, y) local v = hash(x, y, 141) px(x, y, v < .4 and L.peat.base or (v < .65 and L.peat.hi or L.sedgeGround.base)) end)
F.water(bed, L.water)
local function berries(m, k)
  m:each(function(x, y)
    local mat = hash(x // 4 + (y % 2), y // 2, 145)
    if y > 246 and hash(x, y, 142) < k * (mat < .55 and 1.6 or .25) then px(x, y, CRAN.base) if hash(x, y, 143) < .5 then px(x - 1, y, CRAN.hi) else px(x + 1, y, CRAN.shade) end end
  end)
end
berries(bed:copy():clip(rect(310, 246, 351, 269)), .28)
berries(bed:copy():clip(rect(353, 246, 380, 269)), .06)
local boom = line({ { 352, 246 }, { 346, 268 } }, 2)
rimOf(boom, L.timber) part(boom, L.board, { nopop = true, noshade = true })
local _, rgx, rgy = F.gnome(336, 256, { hat = L.leaf, coat = L.roof2, arm = "out", flip = true, noShadow = true })
-- wading: water and berries over the boots
for y = 252, 257 do for x = 326, 346 do if bed:has(x, y) and y >= 253 then
  local v = hash(x, y, 144)
  px(x, y, v < .28 and CRAN.base or (y == 253 and L.water.hi or L.water.base))
end end end
hline(328, 344, 253, L.water.hi)
-- the rake: a long pole and a toothed head in the water
line({ { rgx, rgy }, { 320, 258 } }):each(function(x, y) px(x, y, L.board.base) end)
local rh = rect(316, 257, 322, 259) rimOf(rh, L.timber) fill(rh, L.board.shade)
for x = 316, 322, 2 do px(x, 260, L.board.deep) end
-- wheelbarrow of apples and cranberries
local wb = poly{ { 282, 246 }, { 312, 246 }, { 306, 256 }, { 288, 256 } }
local wbh = line({ { 282, 250 }, { 270, 256 } }, 2):add(rect(296, 256, 297, 262))
local wbw = c:ellipse(310, 260, 4, 4)
F.shadow(276, 314, 264, 6, 2)
rimOf(union(wb, wbh, wbw), L.timber) part(wbh, L.timber, { nopop = true, noshade = true }) part(wb, L.board) part(wbw, L.willowBark, { nopop = true })
F.planks(wb, L.board, 3, false, 23)
fill(c:ellipse(310, 260, 1, 1), L.iron.base)
for x = 285, 309, 3 do local fr = (x % 2 == 0) and AP or GREEN fill(rect(x, 243, x + 1, 245), fr.base) px(x, 243, fr.hi) px(x + 1, 245, fr.shade) end
for x = 296, 304, 2 do px(x, 242, CRAN.base) px(x + 1, 242, CRAN.shade) end
px(292, 242, LF.base) px(293, 241, LF.hi)

---------------------------------------------------------------- fen life along the banks and dykes
F.depth(3)
F.reeds(14, 30, 196, 18, 151, { cattails = 2, green = true })
F.reeds(450, 466, 214, 20, 152, { cattails = 2 })
F.reeds(170, 186, 222, 12, 153, { green = true })
for _, f in ipairs({ { 104, 238 }, { 66, 252 }, { 30, 250 }, { 230, 214 }, { 268, 206 }, { 454, 230 } }) do F.sedge(f[1], f[2], 6) px(f[1] - 1, f[2] - 5, L.marigold.base) px(f[1] + 2, f[2] - 4, L.marigold.hi) end
F.cattail(158, 236, 16, true) F.cattail(162, 238, 12)
F.dragonfly(186, 208, L.accent) F.dragonfly(298, 236, L.apple, true) F.dragonfly(52, 196, L.accent, true)
F.frog(166, 218, false)
-- a kingfisher-blue damselfly pair over the bed
F.dragonfly(364, 236, L.accent, true)

---------------------------------------------------------------- windfalls + quirk hedgehog
for i = 0, 40 do
  local x, y = 20 + floor(hash(i, 5, 7) * 440), 150 + floor(hash(i, 6, 7) * 110)
  local fr = (i % 4 == 0) and GREEN or ((i % 4 == 1) and RUSSET or AP)
  if not F.roadM:has(x, y) and not (x > 378 and y > 228) and not F.poolAt(x, y) then px(x, y, fr.base) px(x + 1, y, fr.shade) px(x, y - 1, fr.hi) end
end
-- quirk: a hedgehog trundling off with an apple, a willow leaf and a sprig of cranberries stuck on its spines
F.shadowM(c:ellipse(222, 263, 13, 1))
F.sprite({
  ".....lL.......c.c.....",
  "....lLlaaa...cCcCc....",
  ".....lLaAAaa..t.t.....",
  "......aAaaaaa.t.t.....",
  "...sssaaaaaaasssS.....",
  "..sSsSaaaaaSsSsss.....",
  ".sSsSssaaasSsSsSss....",
  "sSsSsSsSsSsSsSsSsfff..",
  "sssSsSsSsSsSsSssffeff.",
  "ssssssssssssssssfffffn",
  ".sssssssssssssssfffff.",
  "...ff.......ff..ff....",
}, 206, 251, { l = L.willow.base, L = L.willow.hi, a = AP.base, A = AP.hi, s = L.soil.shade, S = L.soil.hi, f = L.board.hi, e = L.timber.edge, n = L.timber.edge,
  c = CRAN.base, C = CRAN.hi, t = L.reedGreen.shade })
-- a Chinese water deer (little tusks, round ears) nibbling the windfalls under the far-left trees
F.sprite({
  ".ee.ee............",
  "eEEeEEe...........",
  ".DDDDDD.BBBBBBBB..",
  "DkDDDDDBBBBBBBBBB.",
  "nDDDDDDBbBBBBBBBBw",
  ".tDDDD.BbBBBBBBBw.",
  "..DD...BbbbbbbBB..",
  ".......d.d....d.d.",
  ".......d.d....d.d.",
  "......dd.d...dd.d.",
}, 40, 156, { D = L.needle.hi, B = L.needle.base, b = L.needle.shade, k = L.timber.edge, n = L.timber.edge, e = L.needle.deep, E = L.awnB.base, t = L.awnB.hi, w = L.awnB.hi, d = L.needle.deep })
for _, a in ipairs({ { 36, 166 }, { 32, 164 }, { 60, 167 } }) do px(a[1], a[2], AP.base) px(a[1] + 1, a[2], AP.shade) px(a[1], a[2] - 1, AP.hi) end
-- a moorhen pecking a windfall by the road
F.sprite({ ".kk....", "kkkkk..", "kwkkkr.", "kkkkk..", ".y.y..." }, 181, 190, { k = "#3c3a44", w = L.awnB.base, r = L.awnA.base, y = L.reedGreen.base })
px(179, 194, AP.base) px(178, 194, AP.shade)
F.depth(0)
F.birds({ { 330, 40, 2 }, { 120, 48, 2 }, { 132, 42, 1 }, { 340, 46, 1 } })
F.finish()
