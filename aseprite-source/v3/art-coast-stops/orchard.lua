-- orchard.lua : "Orchard" stop look, COAST (coast_driftwood), 480x270 gate view.
-- Same composition as the Maplewold orchard (art-2701-batch3/stops/opus3/orchard.lua), re-cast as a windswept
-- coastal orchard on the dune turf above the sea: the inner rows are wind-bent free-standing trees (round apples,
-- tall pears, low gnarled quinces with golden fruit, young staked trees behind wattle hurdles), every crown swept
-- downwind with a clipped windward face; the outer rows are fan-trained espaliers on low drystone walls that run
-- back to the dunes. A silver sea-buckthorn windbreak (orange berries) along the back, the sea behind.
-- Road's end: a great old wind-bent apple tree against the sea, lichened, a little owl in its hollow, a rope swing
-- (a little gnome). Back right: a salt-scoured whitewashed cottage with a slate roof and a blue door, a ladder and
-- a stack of baskets. Left hero: a driftwood screw cider press under a slate hood, juice into a bucket, a turning
-- gnome, heaps of apples and quinces, crates, stoneware jugs on a plank table, oak cider barrels.
-- Right hero: a picker on a ladder at a big front apple tree, crates by the road with a herring gull eyeing them,
-- a barrow of apples, a gnome with a basket of sea-buckthorn berries. A Gloucester Old Spot pig at the windfalls,
-- a jackdaw pecking a windfall. Quirk (kept): a hedgehog trundling off with an apple, a leaf and a sprig of sea
-- thrift stuck on its spines.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-coast-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "orchard", out = DIR, farTrees = { 24, 52, 100, 380, 410, 440 },
  clouds = { { 96, 46, 40 }, { 330, 36, 56 }, { 420, 70, 34 }, { 22, 84, 26 }, { 160, 78, 20 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local AP, IR = L.apple, L.iron
-- coastal orchard greens: a fresh salt-tolerant apple green, a felty silver quince green, a deep wind-dark green
local LF = F.rp("#c6d894 #96b468 #6c8e50 #4a6a42 #2e4634")   -- apple green
local LF2 = F.rp("#ccd6b6 #a2b490 #7a9072 #586c58 #384a3e")  -- silver-felted quince
local LF3 = F.rp("#e0dc8c #b8b85c #8c9446 #626c3a #3c4628")  -- yellowing, salt-burnt
local LF4 = F.rp("#a8c894 #76a26c #567e58 #3c5e4a #263e36")  -- deep wind-dark (pear)
local PEAR = F.rp("#eef09a #c8d062 #9aa44a #6a7438 #404a26")
local QUINCE = F.rp("#f8e886 #e8c848 #c09a34 #8a6a2a #5a441e")
local BERRY = L.produce -- sea-buckthorn orange
local WICK = F.rp("#d8b47c #b48a52 #8c683c #644a30 #3e2e22") -- wicker / wattle
local CIDER = F.rp("#f6e49a #e6c058 #c0963a #8c6a2c #5a4422")
local OAK = L.cork

local function fruitDot(ax, ay, s, fr)
  if s > 1.1 then fill(rect(ax, ay, ax + 1, ay + 1), fr.base) px(ax, ay, fr.hi) px(ax + 1, ay + 1, fr.shade)
  else px(ax, ay, fr.base) if s > .7 then px(ax + 1, ay, fr.shade) end end
end
-- wind comb: windward (left) top edge gets lit twig tips, the lee underside drips dark
local function windComb(m, cx, r, seed)
  m:each(function(xx, yy)
    if not m:has(xx, yy - 1) and hash(xx, yy, seed + 9) < .4 then px(xx, yy - 1, xx < cx and r.hi or r.shade) end
    if not m:has(xx, yy + 1) and xx > cx and hash(xx, yy, seed + 8) < .5 then px(xx, yy + 1, r.edge) end
  end)
end
local function lichenTrunk(m, seed, k)
  m:each(function(x, y) if hash(x // 2, y // 2, seed) < (k or .14) then
    local w = hash(x, y, seed + 1) px(x, y, w < .3 and L.lichen.shade or (w < .6 and L.moss.base or L.moss.shade)) end end)
end

-- free-standing wind-bent fruit trees, four kinds:
--   1 round apple (three lobes streaming downwind), 2 tall pear (narrow, leaning), 3 low gnarled quince (golden
--   fruit, silver leaf, long lee limb), 4 young staked tree behind a little wattle hurdle on its windward side.
local function fruitTree(x, yb, s, seed, kind)
  kind = kind or (seed % 4) + 1
  local lr = ({ LF, LF3, LF, LF4 })[(seed // 4) % 4 + 1]
  local fr = AP
  if kind == 1 and seed % 3 == 0 then fr = QUINCE lr = LF2 end
  if kind == 2 then lr = LF4 fr = PEAR end
  if kind == 3 then lr = LF2 fr = QUINCE end
  local lean = (2.5 + hash(seed, 1, 9) * 1.5) * s
  local w2 = math.max(1, floor(2 * s))
  local crownM = HP.mask()
  if kind == 1 then
    local tr = poly{ { x - 3 * s, yb }, { x - 1 * s + lean, yb - 12 * s }, { x + 2 * s + lean, yb - 12 * s }, { x + 3 * s, yb } }
    local brs = line({ { x + lean, yb - 10 * s }, { x - 5 * s, yb - 17 * s } }, w2):add(line({ { x + lean, yb - 10 * s }, { x + 13 * s, yb - 19 * s } }, w2))
    F.shadowM(c:ellipse(x + 6 * s, yb, 14 * s, 2 * s))
    rimOf(union(tr, brs), L.timber) part(tr, L.timber, { nopop = true }) part(brs, L.timber, { nopop = true, noshade = true })
    if s > .8 then lichenTrunk(tr, seed) end
    crownM:add(F.crown(x - 6 * s, yb - 20 * s, 8 * s, 6 * s, lr, seed))
    crownM:add(F.crown(x + 17 * s, yb - 21 * s, 8 * s, 6 * s, lr, seed + 1))
    crownM:add(F.crown(x + 5 * s, yb - 26 * s, 12 * s, 8 * s, lr, seed + 2))
    windComb(crownM, x + 5 * s, lr, seed)
    for i = 1, floor(10 * s * s) + 3 do local a, rr = hash(i, seed, 1) * 2 * pi, math.sqrt(hash(i, seed, 2)) * .95 fruitDot(floor(x + 5 * s + cos(a) * rr * 18 * s), floor(yb - 23 * s + sin(a) * rr * 7 * s), s, fr) end
  elseif kind == 2 then
    local tr = poly{ { x - 2 * s, yb }, { x - 1 * s + lean * .6, yb - 14 * s }, { x + 1 * s + lean * .6, yb - 14 * s }, { x + 2 * s, yb } }
    F.shadowM(c:ellipse(x + 4 * s, yb, 9 * s, 2 * s))
    rimOf(tr, L.timber) part(tr, L.timber, { nopop = true })
    crownM:add(F.crown(x + lean * .7, yb - 23 * s, 7 * s, 9 * s, lr, seed))
    crownM:add(F.crown(x + lean * 1.3 + 2 * s, yb - 34 * s, 5 * s, 6 * s, lr, seed + 1))
    windComb(crownM, x + lean, lr, seed)
    for i = 1, floor(7 * s * s) + 2 do local ax, ay = floor(x + lean + (hash(i, seed, 1) - .5) * 12 * s), floor(yb - 17 * s - hash(i, seed, 2) * 20 * s)
      fruitDot(ax, ay, s, fr) if s > .9 then px(ax, ay - 1, fr.shade) end end
  elseif kind == 3 then
    local tr = poly{ { x - 4 * s, yb }, { x - 2 * s, yb - 8 * s }, { x + 4 * s, yb - 8 * s }, { x + 4 * s, yb } }
    local brs = line({ { x, yb - 7 * s }, { x - 8 * s, yb - 12 * s } }, w2 + 1):add(line({ { x + 2 * s, yb - 7 * s }, { x + 18 * s, yb - 12 * s } }, w2 + 1))
    F.shadowM(c:ellipse(x + 6 * s, yb, 18 * s, 2 * s))
    rimOf(union(tr, brs), L.timber) part(tr, L.timber, { nopop = true }) part(brs, L.timber, { nopop = true, noshade = true })
    if s > .6 then F.lichen(union(tr, brs), .12, seed) end
    crownM:add(F.crown(x - 7 * s, yb - 16 * s, 7 * s, 5 * s, lr, seed))
    crownM:add(F.crown(x + 17 * s, yb - 17 * s, 9 * s, 6 * s, lr, seed + 1))
    crownM:add(F.crown(x + 5 * s, yb - 21 * s, 12 * s, 7 * s, lr, seed + 2))
    windComb(crownM, x + 5 * s, lr, seed)
    for i = 1, floor(10 * s * s) + 3 do local a, rr = hash(i, seed, 1) * 2 * pi, hash(i, seed, 2) fruitDot(floor(x + 5 * s + cos(a) * rr * 20 * s), floor(yb - 18 * s + sin(a) * rr * 6 * s), s, fr) end
  else
    local tr = line({ { x, yb }, { x + lean * .5, yb - 14 * s } }, math.max(1, floor(s)))
    local stake = rect(floor(x - 3 * s), floor(yb - 12 * s), floor(x - 3 * s), yb)
    local tie = line({ { x - 3 * s, yb - 10 * s }, { x + lean * .35, yb - 10 * s } })
    F.shadowM(c:ellipse(x + 3 * s, yb, 7 * s, 1 + s))
    rimOf(union(tr, stake), L.timber) part(tr, L.timber, { nopop = true, noshade = true }) part(stake, L.board, { nopop = true, noshade = true })
    tie:each(function(xx, yy) px(xx, yy, WICK.deep) end)
    crownM:add(F.crown(x + lean * .6 + 1, yb - 18 * s, 6 * s, 5 * s, (seed % 2 == 0) and LF or LF4, seed))
    windComb(crownM, x + lean * .6, LF, seed)
    if s > .7 then -- a little wattle hurdle on the windward side
      local hur = rect(floor(x - 8 * s), floor(yb - 7 * s), floor(x - 5 * s), yb)
      rimOf(hur, WICK) fill(hur, WICK.base)
      hur:each(function(xx, yy) local k = (xx + (yy // 2) * 2) % 4 if k == 0 then px(xx, yy, WICK.hi) elseif k == 2 then px(xx, yy, WICK.deep) end end)
    end
    for i = 1, 3 do fruitDot(floor(x + lean * .6 + (hash(i, seed, 1) - .5) * 8 * s), floor(yb - 18 * s + (hash(i, seed, 2) - .5) * 6 * s), s, AP) end
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
  rows[#rows + 1] = { F.xl(y) - 70 - 110 * t, y + 2, s, wall = -1, t = t }
  rows[#rows + 1] = { F.xr(y) + 70 + 110 * t, y + 2, s, wall = 1, t = t }
end
-- turf rides (green strips) between the rows over the dune grass, a darker band under each row
for y = 116, 229 do
  local d = y - 108
  local band = floor(60 / d * 6)
  if band % 2 == 0 then
    for x = 18, 461 do
      if not F.roadM:has(x, y) then
        local v = hash(x // 3, y, 91)
        if v < .55 then px(x, y, L.mossGround.base) elseif v < .68 then px(x, y, L.mossGround.hi) elseif v > .97 then px(x, y, L.petal.base) end
      end
    end
  end
end
for _, r in ipairs(rows) do
  local y = floor(r[2])
  for x = 18, 461 do if not F.roadM:has(x, y + 1) and hash(x, y, 92) < .5 then px(x, y + 1, L.mossGround.shade) px(x, y + 2, F.mix(L.mossGround.shade, L.ground.base, .5)) end end
end
-- sand blown in low streaks across the far rides
for _, m in ipairs({ { 40, 176, 128 }, { 300, 440, 127 }, { 70, 150, 138 }, { 320, 410, 137 } }) do
  for x = m[1], m[2] do
    if not F.roadM:has(x, m[3]) and hash(x // 4, m[3], 93) < .55 then px(x, m[3], L.sand.hi) end
    if (x - m[1]) % 7 < 3 and hash(x // 3, m[3], 94) < .5 then px(x, m[3] + 1, L.sand.base) end
  end
end

---------------------------------------------------------------- sea-buckthorn windbreak along the back, both sides
F.depth(1)
local function hedge(x0, x1, yb, h, seed)
  local m = HP.mask()
  for x = x0, x1, 7 do
    local hh = h + floor(hash(x, 1, seed) * 3)
    m:add(F.crown(x, yb - hh // 2, 5, hh // 2 + 1, L.foliage, seed + x))
  end
  windComb(m, x0 - 99, L.foliage, seed)
  m:each(function(x, y) if hash(x, y, seed + 3) < .07 then px(x, y, hash(x, y, seed + 4) < .5 and BERRY.base or BERRY.hi) end end)
  return m
end
hedge(26, 196, 121, 6, 301)
hedge(286, 396, 121, 6, 302)

---------------------------------------------------------------- drystone walls with espaliers (the outer rows)
local function rowX(t, side)
  local y = 122 + t * t * 70
  if side < 0 then return F.xl(y) - 70 - 110 * t, y + 2 end
  return F.xr(y) + 70 + 110 * t, y + 2
end
local function wallH(t) local s = .45 + t * t * .75 return floor(3 + 10 * s) end
local function drystone(side, tEnd)
  local m, tops = HP.mask(), {}
  local t = -.02
  while t <= tEnd do
    local tt = math.max(0, t)
    local x, yb = rowX(tt, side)
    local h = wallH(tt)
    local xi, yi = floor(x), floor(yb)
    m:add(rect(xi, yi - h, xi, yi))
    if not tops[xi] or yi - h < tops[xi] then tops[xi] = yi - h end
    t = t + .0015
  end
  local r = L.stone
  rimOf(m, r) part(m, r, { nopop = true })
  -- drystone: irregular stones in courses with dark gaps; a lit coping on top, the face in light shade
  m:each(function(x, y)
    local top = tops[x] or y
    local ry = y - top
    local h
    if ry <= 1 then h = (ry == 0) and r.hi or (hash(x // 2, 1, 72) < .5 and r.hi or r.base) -- coping stones on edge
      if ry == 1 and x % 3 == 0 then h = r.shade end
    else
      local cr = (ry - 2) // 3
      local off = floor(hash(cr, top // 4, 74) * 4)
      local bx = (x + off + cr * 2) // (3 + cr % 2)
      local v = hash(bx, cr * 7 + top // 3, 71)
      if (ry - 2) % 3 == 2 or (x + off + cr * 2) % (3 + cr % 2) == 0 then h = r.deep
      else h = v < .25 and r.base or (v < .7 and r.shade or (v < .88 and F.mix(r.shade, L.sand.shade, .45) or r.base)) end
    end
    if not m:has(x, y + 1) then h = r.edge end
    px(x, y, h)
  end)
  F.lichen(m, .07, 73 + side)
  return m
end
F.depth(1)
drystone(-1, 1.06)
drystone(1, .87)
-- a fan-trained espalier against the wall: arms run along the wall in perspective
local function espalier(t, side, seed)
  local x, yb = rowX(t, side)
  local s = .45 + t * t * .75
  local x2, y2 = rowX(math.min(1.1, t + .05), side)
  local dx, dy = x2 - x, y2 - yb
  local n = math.sqrt(dx * dx + dy * dy)
  dx, dy = dx / n, dy / n
  local fr = (seed % 3 == 0) and PEAR or ((seed % 3 == 1) and AP or QUINCE)
  local lr = (fr == QUINCE) and LF2 or ((fr == PEAR) and LF4 or LF)
  local h = floor(18 * s + 2)
  local trunk = rect(floor(x), floor(yb - h), floor(x) + (s > .9 and 1 or 0), floor(yb))
  local arms = HP.mask()
  local armLen = 9 * s + 3
  for k = 1, 3 do
    local ty = yb - h * k / 3.4
    for sg = -1, 1, 2 do
      arms:add(line({ { x, ty }, { x + dx * armLen * sg, ty + dy * armLen * sg - 1 } }, 1))
    end
  end
  arms:add(line({ { x, yb - h }, { x - 2 * s, yb - h - 3 * s } })):add(line({ { x + 1, yb - h }, { x + 3 * s, yb - h - 3 * s } }))
  -- leaf clumps along the arms (a rimmed leaf mask), wood showing through, fruit hanging under the arms
  local leafM = HP.mask()
  local big = s > .8 and 1 or 0
  arms:each(function(ax, ay)
    if hash(ax, ay, seed) < .7 then leafM:add(rect(ax - big, ay - 1 - big, ax + big, ay + (hash(ax, ay, seed + 5) < .5 and 1 or 0))) end
  end)
  rimOf(union(trunk, arms), L.timber)
  part(trunk, L.timber, { nopop = true, noshade = true }) part(arms, L.timber, { nopop = true, noshade = true })
  rimOf(leafM, lr)
  leafM:each(function(ax, ay)
    local v = hash(ax, ay, seed + 3)
    local up = not leafM:has(ax, ay - 1)
    local dn = not leafM:has(ax, ay + 1)
    px(ax, ay, up and (v < .5 and lr.hi or lr.glint or lr.hi) or (dn and lr.deep or (v < .4 and lr.base or lr.shade)))
  end)
  arms:each(function(ax, ay) if hash(ax, ay, seed + 4) < .3 then px(ax, ay, L.timber.base) end end)
  trunk:each(function(ax, ay) px(ax, ay, ax == floor(x) and L.timber.base or L.timber.shade) end)
  local k = 0
  arms:each(function(ax, ay)
    if hash(ax, ay, seed + 2) < (s > .8 and .16 or .12) and not arms:has(ax, ay + 1) then
      if s > 1 then fill(rect(ax, ay + 1, ax + 1, ay + 2), fr.base) px(ax, ay + 1, fr.hi) px(ax + 1, ay + 2, fr.shade)
      else px(ax, ay + 1, fr.base) end
    end
  end)
end

table.sort(rows, function(a, b) return a[2] < b[2] end)
---------------------------------------------------------------- great old wind-bent apple at the road's end (farthest, drawn first)
F.depth(2)
local function oldTree()
  local tr = poly{ { 224, 127 }, { 232, 108 }, { 235, 96 }, { 236, 84 }, { 256, 82 }, { 252, 96 }, { 251, 108 }, { 258, 127 } }
  local roots = poly{ { 218, 128 }, { 228, 120 }, { 231, 128 } }:add(poly{ { 252, 128 }, { 255, 119 }, { 264, 128 } })
  local brs = line({ { 238, 92 }, { 202, 72 } }, 3):add(line({ { 250, 88 }, { 282, 70 } }, 3)):add(line({ { 252, 86 }, { 298, 76 } }, 2)):add(line({ { 244, 86 }, { 254, 60 } }, 2))
  F.shadow(220, 268, 129, 10, 3)
  local all = union(tr, roots, brs)
  rimOf(all, L.timber) part(tr, L.timber) part(roots, L.timber, { nopop = true }) part(brs, L.timber, { nopop = true })
  -- deep twisted bark, salt-grey, crusted with lichen on the sea side
  tr:each(function(x, y) if (x * 2 + y) % 9 == 0 or ((x + y // 3) % 6 == 0 and y > 100) then px(x, y, L.timber.deep) end end)
  tr:each(function(x, y) if x < 238 and hash(x // 2, y // 2, 61) < .4 then local w = hash(x, y, 62) px(x, y, w < .12 and L.lichen.base or (w < .3 and L.lichen.shade or (w < .7 and L.moss.base or L.moss.shade))) end end)
  F.lichen(union(roots, brs), .16, 63)
  -- the hollow with a little owl looking out
  local hol = c:ellipse(244, 101, 4, 5)
  fill(hol, L.timber.edge)
  F.sprite({ ".o.o.", "ooOoo", "yEoEy", "oOvOo", "OoOoO", ".ooo." }, 242, 97, { o = L.needle.base, O = L.board.hi, y = L.gold.hi, E = L.timber.edge, v = L.gold.base }, { rim = false })
  -- crown streaming downwind (to the right), windward side low and clipped
  local cm = HP.mask()
  cm:add(F.crown(210, 68, 18, 10, LF, 51))
  cm:add(F.crown(288, 64, 24, 12, LF4, 52))
  cm:add(F.crown(248, 52, 30, 15, LF, 53))
  cm:add(F.crown(306, 74, 13, 7, LF, 55))
  cm:add(F.crown(250, 74, 20, 9, LF3, 54))
  windComb(cm, 236, LF, 56)
  for i = 1, 56 do
    local ax, ay = 196 + floor(hash(i, 3, 1) * 120), 38 + floor(hash(i, 4, 1) * 44)
    if cm:has(ax, ay) and cm:has(ax + 1, ay + 1) then
      local fr = (i % 6 == 0) and QUINCE or AP
      fill(rect(ax, ay, ax + 1, ay + 1), fr.base) px(ax, ay, fr.hi) px(ax + 1, ay + 1, fr.shade)
    end
  end
  -- rope swing hanging from the low windward limb
  vline(206, 74, 112, WICK.deep) vline(218, 80, 112, WICK.deep)
  for y = 78, 110, 4 do px(206, y, WICK.base) px(218, y + 2, WICK.base) end
  local seat = rect(204, 112, 220, 114) rimOf(seat, L.timber) part(seat, L.board, { nopop = true })
  F.gnome(212, 112, { small = true, hat = L.awnA, coat = L.wall2, noShadow = true }) -- a little one swinging
end
oldTree()

local esp = 0
for i, r in ipairs(rows) do
  F.depth(r[2] < 140 and 1 or (r[2] < 170 and 2 or 3))
  local x = floor(r[1])
  if x > 0 and x < 480 and not (x > 370 and r[2] > 175) then
    if r.wall then
      esp = esp + 1
      if x > 18 and x < 462 then espalier(r.t, r.wall, 300 + esp * 7) end
    else
      fruitTree(x, r[2], r[3], i * 7 + 1, (i * 3 + x // 50) % 4 + 1)
    end
  end
end
-- far wind-bent hawthorns standing at the ends of the windbreak
F.depth(1)
F.tree(150, 124, 30, 2) F.tree(338, 122, 32, 0)

---------------------------------------------------------------- back-right: salt-scoured cottage (between the rows)
local function cottage()
  local top, cx, wallM, roofM = F.building{ x0 = 404, x1 = 462, yb = 140, wh = 30, rh = 22, wall = L.plaster, roof = L.roof, shingle = true, chimney = true, noFrame = true, noAttic = true }
  F.lichen(roofM, .08, 81)
  -- salt scour: the windward (left) end of the wall weathered grey, flaking whitewash showing stone
  wallM:each(function(x, y)
    if x < 414 and hash(x, y, 82) < .35 then px(x, y, L.plaster.shade) end
    if hash(x // 3, y // 2, 83) < .05 then fill(rect(x, y, x + 1, y), L.stone.base) px(x, y + 1, L.stone.shade) end
    if y > 135 and hash(x // 2, y, 84) < .35 then px(x, y, L.sand.shade) end
  end)
  F.door(420, 118, 432, 139, L.wall2)
  F.window(440, 120, 448, 127, L.wall2)
  F.window(408, 120, 414, 127, L.wall2)
  F.window(430, 98, 435, 102, L.wall2)
  -- a round apple sign over the door
  local pl = c:ellipse(426, 113, 3, 3) rimOf(pl, L.tar) part(pl, L.wall2)
  px(426, 113, AP.base) px(425, 112, AP.hi) px(427, 114, AP.shade) px(426, 111, LF.base)
  F.smoke(452, 84, 5, 1.6, 2)
  -- a ladder leaning on the wall, a stack of empty baskets
  local lad = line({ { 398, 140 }, { 406, 112 } }):add(line({ { 402, 140 }, { 410, 112 } }))
  for k = 1, 6 do local tt = k / 7 lad:add(line({ { 398 + 8 * tt, 140 - 28 * tt }, { 402 + 8 * tt, 140 - 28 * tt } })) end
  c:rim(lad, L.timber.edge) fill(lad, L.board.base)
  for k = 0, 2 do
    local bm = poly{ { 440, 141 - k * 3 }, { 452, 141 - k * 3 }, { 451, 136 - k * 3 }, { 441, 136 - k * 3 } }
    rimOf(bm, WICK) part(bm, WICK, { nopop = true }) hline(441, 451, 136 - k * 3, WICK.hi)
  end
end
cottage()

---------------------------------------------------------------- left hero: driftwood cider press under a slate hood
F.depth(2)
F.tree(198, 182, 34, 1)
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
  rimOf(union(posts, beam, screw, bar, plate, tub, base, spout), L.tar)
  rimOf(roofM, L.roof)
  part(roofM, L.roof, { sep = true }) F.courses(roofM, yb - 70, 3, 5, L.roof) F.lichen(roofM, .12, 82)
  -- bleached driftwood posts, salt-grey with dark cracks
  part(posts, L.timber) posts:each(function(x, y) if hash(x, y // 3, 83) < .2 then px(x, y, L.timber.shade) elseif hash(x, y // 2, 84) < .06 then px(x, y, L.timber.edge) end end)
  part(beam, L.timber) F.planks(beam, L.timber, 3, false, 85) hline(x0 - 4, x0 + 54, yb - 56, L.timber.hi)
  part(screw, IR, { nopop = true }) for y = yb - 49, yb - 29, 2 do hline(x0 + 23, x0 + 27, y, IR.deep) px(x0 + 23, y + 1, IR.hi) end
  part(bar, L.board, { nopop = true }) part(plate, L.board)
  part(tub, OAK) for x = x0 + 10, x0 + 40, 6 do vline(x, yb - 23, yb - 7, OAK.deep) end
  hline(x0 + 7, x0 + 43, yb - 20, IR.shade) hline(x0 + 8, x0 + 42, yb - 10, IR.shade)
  -- pulp oozing out under the plate
  for x = x0 + 9, x0 + 41, 2 do px(x, yb - 23, CIDER.shade) if x % 4 == 1 then px(x, yb - 22, CIDER.base) end end
  part(base, L.stone, { nopop = true }) F.courses(base, yb - 6, 3, 7, L.stone) F.lichen(base, .1, 86)
  part(spout, L.timber, { nopop = true })
  -- juice pouring into a bucket
  vline(x0 + 60, yb - 7, yb + 4, CIDER.base) vline(x0 + 61, yb - 7, yb + 4, CIDER.hi)
  local bk = poly{ { x0 + 54, yb + 4 }, { x0 + 68, yb + 4 }, { x0 + 66, yb + 14 }, { x0 + 56, yb + 14 } }
  rimOf(bk, L.tar) part(bk, L.wall2) hline(x0 + 55, x0 + 67, yb + 5, CIDER.base) hline(x0 + 56, x0 + 66, yb + 6, CIDER.shade) hline(x0 + 55, x0 + 67, yb + 8, L.wall2.deep)
  -- a wasp at the sweet spout
  px(x0 + 64, yb - 12, L.gold.base) px(x0 + 65, yb - 12, L.timber.edge) px(x0 + 64, yb - 13, L.mist2)
end
press(92, 206)
-- a gnome turning the press bar
local _, tx, ty = F.gnome(80, 210, { hat = L.lav, coat = L.accent, arm = "up" })
fill(line({ { tx, ty }, { 98, 166 } }), L.board.base)
-- heaps of apples and quinces beside the press
local function heap(x0, x1, yb, fr, lf)
  local m = poly{ { x0, yb }, { x0 + 4, yb - 7 }, { (x0 + x1) // 2, yb - 11 }, { x1 - 4, yb - 7 }, { x1, yb } }
  rimOf(m, fr) fill(m, fr.base)
  m:each(function(x, y) local k = (x + (y % 2) * 2) % 4 if k == 0 then px(x, y, fr.hi) elseif k == 3 then px(x, y, fr.shade) end end)
  for x = x0 + 4, x1 - 4, 7 do px(x, yb - 8 + (x % 3), lf.base) px(x + 1, yb - 9 + (x % 3), lf.hi) end
end
heap(30, 84, 214, AP, LF)
heap(18, 44, 206, QUINCE, LF2)
F.crate(24, 232, 22, 12, AP) F.crate(50, 234, 22, 12, PEAR) F.crate(36, 220, 22, 10, QUINCE)
-- a wicker basket of sea-buckthorn berries against the crates
local function basket(x, yb, w, h, fr)
  local m = poly{ { x - w, yb - h }, { x + w, yb - h }, { x + w - 2, yb }, { x - w + 2, yb } }
  local handle = c:ellipse(x, yb - h, w - 2, h - 1):cut(c:ellipse(x, yb - h, w - 4, h - 3)):clip(rect(x - w, yb - 2 * h, x + w, yb - h - 1))
  rimOf(union(m, handle), WICK) part(handle, WICK, { nopop = true, noshade = true })
  part(m, WICK, { nopop = true })
  m:each(function(xx, yy) if (xx + yy) % 3 == 0 then px(xx, yy, WICK.shade) elseif (xx - yy) % 5 == 0 then px(xx, yy, WICK.hi) end end)
  for xx = x - w + 1, x + w - 1, 2 do px(xx, yb - h - 1, fr.base) px(xx + 1, yb - h - 1, fr.shade) px(xx, yb - h - 2, fr.hi) end
  if fr == BERRY then px(x - 2, yb - h - 3, L.foliage.hi) px(x - 1, yb - h - 3, L.foliage.base) px(x + 2, yb - h - 2, L.foliage.shade) end
end
basket(80, 226, 7, 6, BERRY)
-- salt-glazed stoneware cider jugs on a plank table
local tbl = rect(118, 226, 182, 229):add(rect(121, 230, 123, 242)):add(rect(177, 230, 179, 242))
F.shadow(120, 182, 242, 8, 3)
rimOf(tbl, L.timber) part(tbl, L.board, { nopop = true })
for k = 0, 3 do
  local x = 126 + k * 14
  local jr = ({ L.awnB, L.wall2, L.awnB, L.stone })[k + 1]
  local jug = c:rrect(x - 4, 214, x + 4, 225, 3):add(rect(x - 2, 210, x + 2, 214))
  rimOf(jug, L.tar) part(jug, jr)
  hline(x - 3, x + 3, 216, (k % 2 == 0) and L.needle.shade or L.accent.shade)
  if k % 2 == 0 then px(x - 1, 220, L.accent.base) px(x, 219, L.accent.base) px(x + 1, 220, L.accent.base) end -- a blue fish daub
  fill(rect(x + 4, 216, x + 6, 221), L.tar.edge) fill(rect(x + 4, 217, x + 5, 220), jr.shade)
  fill(rect(x - 2, 209, x + 2, 210), OAK.shade) px(x - 2, 209, OAK.hi) -- cork
end
px(176, 224, CIDER.hi) px(177, 224, CIDER.base) fill(rect(176, 225, 178, 225), L.awnB.shade)
-- oak cider barrels and a stick of driftwood
F.barrel(196, 250, OAK, 14) F.barrel(186, 262, OAK, 12)
F.lichen(rect(184, 236, 208, 240), .06, 86)
F.driftwood(146, 262, 170, 257, 2)
F.thrift(176, 258, true) F.shell(158, 266, true)

---------------------------------------------------------------- right hero: picker on a ladder at a big front apple tree
fruitTree(404, 226, 2.3, 77, 1)
local lad = line({ { 352, 236 }, { 370, 168 } }, 2):add(line({ { 364, 238 }, { 382, 170 } }, 2))
for k = 0, 8 do local t = k / 8 lad:add(line({ { 352 + 18 * t, 236 - 68 * t }, { 364 + 18 * t, 238 - 68 * t } })) end
rimOf(lad, L.tar) part(lad, L.timber, { nopop = true, noshade = true })
F.lichen(line({ { 352, 236 }, { 356, 222 } }, 2), .4, 87)
local _, phx, phy = F.gnome(375, 190, { hat = L.awnA, coat = L.wall2, arm = "up", noShadow = true })
fill(rect(phx, phy - 2, phx + 1, phy - 1), AP.base) px(phx, phy - 2, AP.hi) -- an apple just picked
local bas = poly{ { 368, 186 }, { 380, 186 }, { 378, 194 }, { 370, 194 } } rimOf(bas, WICK) part(bas, WICK)
bas:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, WICK.shade) end end)
for k = 0, 4 do fill(rect(369 + k * 2, 184, 370 + k * 2, 185), AP.base) px(369 + k * 2, 184, AP.hi) end
-- crates by the road (right)
F.crate(290, 226, 22, 12, AP) F.crate(314, 228, 22, 12, QUINCE) F.crate(300, 213, 22, 11, PEAR)
basket(330, 214, 6, 5, AP)
-- a herring gull on the crates, eyeing the apples
F.sprite({
  ".......WWW....",
  "......WWWWW...",
  "......WWWeWY..",
  ".....WWWWWYYr.",
  "....WWWWWW....",
  "...WWWWWWW....",
  "..GGGGGGGWW...",
  ".GGGGGGGGWW...",
  "KKwGGGGGWW....",
  "KKKwKGWWW.....",
  ".KK..WWW......",
  "......p.p.....",
}, 300, 190, { W = L.gull.hi, G = L.gull.shade, K = L.tar.deep, w = L.gull.hi, Y = L.gold.base, r = AP.base, e = L.tar.edge, p = L.petal.shade }, { rimCol = L.gull.edge })
px(309, 196, L.gull.base) px(310, 197, L.gull.base)
-- a gnome carrying a basket of sea-buckthorn berries in from the windbreak
local _, ghx, ghy = F.gnome(336, 256, { hat = L.gorse, coat = L.roof2, arm = "out", flip = true })
local mb = poly{ { ghx - 6, ghy - 1 }, { ghx + 2, ghy - 1 }, { ghx + 1, ghy + 4 }, { ghx - 5, ghy + 4 } }
rimOf(mb, WICK) part(mb, WICK, { nopop = true })
for xx = ghx - 5, ghx + 1 do px(xx, ghy - 2, (xx % 2 == 0) and BERRY.base or BERRY.hi) end
px(ghx - 3, ghy - 3, BERRY.hi) px(ghx - 1, ghy - 3, L.foliage.hi) px(ghx, ghy - 3, L.foliage.base) px(ghx - 4, ghy - 3, L.foliage.shade)
-- wheelbarrow of apples
local wb = poly{ { 282, 246 }, { 312, 246 }, { 306, 256 }, { 288, 256 } }
local wbh = line({ { 282, 250 }, { 270, 256 } }, 2):add(rect(296, 256, 297, 262))
local wbw = c:ellipse(310, 260, 4, 4)
F.shadow(276, 314, 264, 6, 2)
rimOf(union(wb, wbh, wbw), L.tar) part(wbh, L.timber, { nopop = true, noshade = true }) part(wb, L.wall2) part(wbw, L.timber, { nopop = true })
F.planks(wb, L.wall2, 3, false, 23)
fill(c:ellipse(310, 260, 1, 1), L.iron.base)
for x = 285, 309, 3 do local fr = (x % 2 == 0) and AP or QUINCE fill(rect(x, 243, x + 1, 245), fr.base) px(x, 243, fr.hi) px(x + 1, 245, fr.shade) end
px(292, 242, LF.base) px(293, 241, LF.hi)

---------------------------------------------------------------- dune life in the orchard: marram, thrift, shells
for _, f in ipairs({ { 22, 196, 6 }, { 28, 200, 5 }, { 110, 196, 5 }, { 268, 200, 5 }, { 458, 210, 6 }, { 450, 214, 5 },
  { 214, 236, 6 }, { 30, 250, 7 }, { 66, 254, 6 }, { 352, 210, 5 } }) do F.marram(f[1], f[2], f[3]) end
for i = 0, 7 do local a = i / 8 * 2 * pi F.thrift(floor(150 + cos(a) * 12), floor(186 + sin(a) * 4), i % 3 == 0) end
for _, m in ipairs({ { 120, 252 }, { 236, 222 }, { 274, 232 }, { 96, 248 }, { 446, 202 } }) do F.shell(m[1], m[2], true) end
F.pebbles(262, 214, 3, 5) F.pebbles(108, 246, 3, 9)
-- a sea-buckthorn bush with orange berries closing in on the near left
local sb = F.bush(28, 268, 18, 22, L.foliage, 44)
windComb(sb, 20, L.foliage, 45)
sb:each(function(x, y) if hash(x, y, 46) < .1 then px(x, y, hash(x, y, 47) < .5 and BERRY.base or BERRY.hi) if hash(x, y, 48) < .3 then px(x + 1, y, BERRY.shade) end end end)

---------------------------------------------------------------- windfalls + quirk hedgehog
for i = 0, 40 do
  local x, y = 20 + floor(hash(i, 5, 7) * 440), 150 + floor(hash(i, 6, 7) * 110)
  local fr = (i % 4 == 0) and PEAR or ((i % 4 == 1) and QUINCE or AP)
  if not F.roadM:has(x, y) and not (x > 378 and y > 228) then px(x, y, fr.base) px(x + 1, y, fr.shade) px(x, y - 1, fr.hi) end
end
-- quirk: a hedgehog trundling off with an apple, a leaf and a sprig of sea thrift stuck on its spines
F.shadowM(c:ellipse(222, 263, 13, 1))
F.sprite({
  "......llaaa...mM......",
  ".....lLaAAaa.MmmM.....",
  "......aAaaaaa..g......",
  "...sssaaaaaaasgsS.....",
  "..sSsSaaaaaSsSsss.....",
  ".sSsSssaaasSsSsSss....",
  "sSsSsSsSsSsSsSsSsfff..",
  "sssSsSsSsSsSsSssffeff.",
  "ssssssssssssssssfffffn",
  ".sssssssssssssssfffff.",
  "...ff.......ff..ff....",
}, 206, 252, { l = LF.base, L = LF.hi, a = AP.base, A = AP.hi, s = L.soil.shade, S = L.soil.hi, f = L.board.hi, e = L.timber.edge, n = L.timber.edge,
  m = L.petal.base, M = L.petal.hi, g = L.leaf.deep })
-- a Gloucester Old Spot (the orchard pig) snuffling the windfalls under the far-left trees
F.sprite({
  "..e...........",
  ".ePe.pPPPPPP..",
  "pPPPPPPkkPPPp.",
  "nPEPPPPkkkPPPp",
  "nnPPPPPPPPkPPq",
  ".pPPkkPPPPPPp.",
  "..dd.dd..dd.d.",
}, 58, 162, { p = L.petal.base, P = L.petal.hi, k = L.tar.base, E = L.timber.edge, n = L.petal.shade, q = L.petal.shade, e = L.petal.shade, d = L.petal.deep })
for _, a in ipairs({ { 52, 167 }, { 55, 169 }, { 76, 168 } }) do px(a[1], a[2], AP.base) px(a[1] + 1, a[2], AP.shade) px(a[1], a[2] - 1, AP.hi) end
-- a jackdaw (grey nape, pale eye) pecking a windfall by the road
F.sprite({ ".kg...", "kgwkk.", "kkkkky", ".k.k.." }, 182, 192, { k = L.tar.deep, g = L.tar.hi, w = L.chalk.hi, y = L.tar.base })
px(180, 195, AP.base) px(179, 195, AP.shade)
F.depth(0)
F.gull(330, 40, 3) F.gull(346, 48, 2) F.gull(120, 30, 2) F.gull(170, 88, 1) F.gull(300, 86, 1)
F.finish()
