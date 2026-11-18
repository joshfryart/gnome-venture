-- camp.lua : "Camp" stop look, COAST (coast_driftwood), 480x270 gate view.
-- Same composition and story as the Maplewold camp (art-2701-batch3/stops/opus3/camp.lua), re-cast for a beach camp
-- on a chalk-and-dune coast: road's end: a driftwood-framed two-peak canvas shelter (sea-blue and cream stripes,
-- crossed driftwood spars at the peaks, buoys hung from the valance), stove-pipe smoke blowing over the sea.
-- Back left: an upturned dory propped up as a shelter, a net drying over its keel; a washing line strung from a
-- wind-bent hawthorn to a driftwood pole, a gnome pegging. Right: the cream-and-blue bell tent glowing inside, its hem
-- sand- and wrack-stained; nets and buoys on drying poles behind it. Back right: a clam-bake pit steaming under wrack,
-- lobsters and clams peeking out, a gnome forking on more weed. Left: driftwood stacked between stakes, an
-- oystercatcher. Hero: a driftwood bonfire (blue-green copper flickers at its foot) in a cobble ring with a tripod pot,
-- driftwood log seats, a concertina player, a toasting gnome (marshmallow + sprat), a mug gnome, a collie asleep.
-- Bottom left: the driftwood camp-kitchen table with a basket of mussels. Marram, thrift, shells, wrack, pebbles.
-- Quirk: a raccoon climbing out of the pack with a sausage... and a herring gull has the other end in its beak.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-coast-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "camp", out = DIR, farTrees = { 24, 52, 160, 290, 318, 440 }, duneLineGap = { 194, 286 },
  boats = { { 168, 97, 7 }, { 304, 96, 6 }, { 336, 101, 9 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local G, IR = L.glow, L.iron
local blue = L.wall2

-- local helpers ------------------------------------------------------------------------
-- a driftwood stump / block: bleached grey, growth rings on top, lichen crusts
local function stump(x, yb, w, lichK, seed)
  local body = rect(x - w, yb - w, x + w, yb)
  local top = c:ellipse(x, yb - w, w, math.max(1, w // 2))
  local roots = poly{ { x - w - 2, yb }, { x - w, yb - 3 }, { x - w, yb } }:add(poly{ { x + w + 2, yb }, { x + w, yb - 3 }, { x + w, yb } })
  rimOf(union(body, top, roots), L.timber)
  part(union(body, roots), L.timber, { nopop = true })
  body:each(function(xx, yy) if (xx - x) % 3 == 0 and hash(xx, yy // 2, seed or 5) < .6 then px(xx, yy, L.timber.shade) end end)
  vline(x - w + 1, yb - w + 1, yb - 1, L.timber.hi)
  fill(top, L.board.base)
  top:each(function(xx, yy) local d = math.sqrt((xx - x) ^ 2 + ((yy - (yb - w)) * 2) ^ 2) if floor(d) % 2 == 1 then px(xx, yy, L.board.shade) end if xx - x + (yy - (yb - w)) * 2 < -w * .6 then px(xx, yy, L.board.hi) end end)
  px(x, yb - w, L.board.deep)
  if lichK then F.lichen(body, lichK, seed or 7) end
  return body, top
end
-- a round fishing buoy on a short cord; band = a cream stripe round the middle
local function buoy(x, y, r, ramp, band, cord)
  if cord then vline(x, y - r - cord, y - r - 1, L.cork.deep) end
  local m = c:ellipse(x, y, r, r)
  rimOf(m, L.tar) part(m, ramp, { nopop = true })
  if band then hline(x - r + 1, x + r - 1, y, L.awnB.hi) if r >= 3 then hline(x - r + 1, x + r - 1, y + 1, L.awnB.shade) end end
  px(x - r // 2, y - r // 2, ramp.hi)
  return m
end
local function shells(x, y) F.shell(x, y, true) F.shell(x + 4, y + 1, false) end

-- trodden sand around the fire (left of the road): a blowout in the dune turf, charcoal bits near the ring
local clear = c:ellipse(150, 214, 92, 30)
clear:each(function(x, y) if not F.roadM:has(x, y) and x < F.xl(y) - 1 then
  local v = hash(x, y, 3)
  local d = ((x - 150) / 92) ^ 2 + ((y - 214) / 30) ^ 2
  if d < .8 then
    local b = hash(x // 4, y // 2, 4)
    local h = b < .55 and L.sand.base or (b < .85 and L.sand.shade or L.wetSand.base)
    if v < .05 then h = L.sand.hi elseif v > .965 then h = (d < .3) and L.tar.shade or L.shingle.shade end
    if (y + floor(sin(x / 7) * 2)) % 5 == 0 and hash(x // 3, y, 5) < .5 then h = L.sand.shade end -- wind ripples
    px(x, y, h)
  elseif hash(x // 3, y // 2, 4) < .45 then px(x, y, L.sand.shade) end
end end)

---------------------------------------------------------------- the beach beyond: a tide line of wrack, gulls on the sea
F.depth(1)
for x = 290, 366, 5 do F.wrack(x, 108 + floor(sin(x / 13) * 1.5), 3, x) end
F.gull(196, 84, 1) F.gull(350, 86, 1) F.gull(306, 89, 1)

---------------------------------------------------------------- back trees (plane 1)
F.tree(10, 140, 40, 1)
F.tree(318, 138, 38, 0)
F.tree(452, 136, 40, 5)

---------------------------------------------------------------- road's end: the driftwood-framed canvas shelter
F.depth(2)
F.tree(292, 128, 40, 2)
do
  local cx, yb = 240, 128
  local wall = rect(cx - 34, yb - 16, cx + 34, yb)
  local roofm = poly{ { cx - 42, yb - 15 }, { cx - 16, yb - 44 }, { cx, yb - 32 }, { cx + 16, yb - 44 }, { cx + 42, yb - 15 } }
  F.shadow(cx - 34, cx + 34, yb, 10, 3)
  rimOf(union(wall, roofm), L.tar)
  roofm:each(function(x, y)
    local pk = x < cx and cx - 16 or cx + 16
    local u = (x - pk) / (y - (yb - 46))
    local k = floor(u * 5 + 20)
    local h = (k % 2 == 0) and blue.base or L.awnB.hi
    if (u * 5 + 20) % 1 < .14 then h = (k % 2 == 0) and blue.shade or L.awnB.shade end
    if x > pk + 6 and (x - pk) / 26 + (y - (yb - 44)) / 30 > .9 then h = (k % 2 == 0) and blue.shade or L.awnB.base end
    if x < pk - 2 and (pk - x) / 10 + (y - (yb - 44)) / 12 < 1.1 then h = (k % 2 == 0) and blue.hi or L.awnB.hi end
    px(x, y, h)
  end)
  -- salt bloom and a blown-sand line on the canvas
  roofm:each(function(x, y) if hash(x, y, 81) < .01 then px(x, y, L.sand.shade) end end)
  wall:each(function(x, y)
    local k = ((x - cx + 40) // 6) % 2
    local h = k == 0 and L.awnB.base or blue.hi
    if x > cx + 22 then h = k == 0 and L.awnB.shade or blue.base end
    if y >= yb - 2 and hash(x, y, 82) < .55 then h = L.sand.shade end
    px(x, y, h)
  end)
  -- scalloped valance in red
  for x = cx - 40, cx + 38, 6 do fill(poly{ { x, yb - 15 }, { x + 6, yb - 15 }, { x + 3, yb - 11 } }, L.awnA.base) px(x + 3, yb - 12, L.awnA.shade) px(x + 1, yb - 15, L.awnA.hi) end
  hline(cx - 42, cx + 42, yb - 15, L.awnA.deep)
  local door = poly{ { cx - 8, yb }, { cx - 5, yb - 12 }, { cx + 5, yb - 12 }, { cx + 8, yb } }
  fill(door, G.shade) fill(rect(cx - 3, yb - 9, cx + 3, yb), G.base) px(cx - 2, yb - 8, G.hi)
  -- the driftwood frame: corner posts, a ridge spar between the peaks, crossed spars lashed at each peak
  F.driftwood(cx - 36, yb, cx - 35, yb - 16, 2)
  F.driftwood(cx + 35, yb, cx + 36, yb - 16, 2)
  F.driftwood(cx - 16, yb - 44, cx + 16, yb - 44, 1)
  for _, pk in ipairs({ cx - 16, cx + 16 }) do
    F.driftwood(pk - 8, yb - 53, pk + 3, yb - 40, 1)
    F.driftwood(pk + 8, yb - 54, pk - 3, yb - 40, 1)
    px(pk, yb - 47, L.cork.deep) px(pk - 1, yb - 46, L.cork.base) px(pk + 1, yb - 48, L.cork.base) -- rope lashing
  end
  for _, p in ipairs({ { cx - 24, yb - 53, L.awnA }, { cx + 24, yb - 54, L.gold } }) do
    fill(poly{ { p[1] + 1, p[2] }, { p[1] + 9, p[2] + 2 }, { p[1] + 1, p[2] + 4 } }, p[3].base) px(p[1] + 2, p[2] + 1, p[3].hi)
  end
  for _, g in ipairs({ { cx - 42, cx - 50 }, { cx + 42, cx + 50 } }) do line({ { g[1], yb - 15 }, { g[2], yb + 1 } }):each(function(x, y) px(x, y, L.board.deep) end) end
  fill(rect(cx + 25, yb - 34, cx + 27, yb - 28), IR.base) px(cx + 25, yb - 34, IR.hi) hline(cx + 24, cx + 28, yb - 35, IR.deep)
  F.smoke(cx + 26, yb - 38, 5, .9, 2) -- stove pipe smoke, blown out to sea
  -- buoys hung from the valance
  buoy(cx - 30, yb - 6, 2, L.awnA, true, 3)
  buoy(cx + 30, yb - 6, 2, L.produce, false, 3)
  buoy(cx + 18, yb - 4, 2, L.gold, true, 5)
  -- a stack of driftwood log ends and a lobster pot beside the shelter
  for k = 0, 2 do F.logEnd(cx + 38 + k * 4, yb - 2, 2) end
  for k = 0, 1 do F.logEnd(cx + 40 + k * 4, yb - 6, 2) end
  F.lobsterPot(cx - 46, yb, 5)
end

---------------------------------------------------------------- back left: an upturned dory propped up as a shelter
F.depth(1)
do
  -- upturned, the sheer arches up in the middle (a dark gap under it) and the keel runs flat along the top
  local function gun(x) return floor(146 - 9 * sin(pi * math.max(0, math.min(1, (x - 14) / 64))) + .5) end
  local outline = poly{ { 13, 146 }, { 21, 129 }, { 25, 127 }, { 62, 127 }, { 67, 129 }, { 79, 146 } }
  local hull, gap = HP.mask(), HP.mask()
  outline:each(function(x, y) if y <= gun(x) then hull:set(x, y) else gap:set(x, y) end end)
  F.shadow(12, 78, 147, 10, 3)
  rimOf(outline, L.tar)
  fill(gap, L.tar.deep)
  hull:each(function(x, y)
    local d = gun(x) - y
    local h = blue.base
    if d % 3 == 2 then h = blue.shade end -- clinker strakes following the sheer
    if x < 40 and y < 134 then h = (h == blue.shade) and blue.base or blue.hi end
    if x > 64 then h = (h == blue.shade) and blue.deep or blue.shade end
    if hash(x // 2, y, 41) < .07 then h = L.plaster.shade end -- flaking paint
    if d <= 1 then h = (d == 1) and L.plaster.hi or L.plaster.base end -- white gunwale band
    px(x, y, h)
  end)
  hline(25, 62, 127, L.tar.base) hline(26, 60, 128, L.tar.shade) hline(28, 58, 127, L.tar.hi) -- tarred keel
  line({ { 67, 129 }, { 79, 146 } }):each(function(x, y) px(x, y, L.timber.base) end) -- stem post
  line({ { 21, 129 }, { 13, 146 } }):each(function(x, y) px(x, y, L.tar.base) end)  -- tombstone transom edge
  -- in the gap: a bedroll, and a canvas flap hanging from the gunwale
  fill(rect(28, 143, 38, 146), L.roof2.shade) hline(28, 38, 143, L.roof2.base)
  local flap = HP.mask()
  gap:each(function(x, y) if x >= 48 and x <= 70 then flap:set(x, y) end end)
  part(flap, L.awnB, { nopop = true })
  for x = 52, 68, 5 do flap:each(function(xx, yy) if xx == x then px(xx, yy, L.awnB.shade) end end) end
  for _, x in ipairs({ 44, 71 }) do vline(x, gun(x) + 1, 146, L.timber.base) end -- props
  F.netSwag(26, 56, 128, 5, { floatStep = 7 })
  buoy(84, 145, 2, L.awnA, true, 0)
end
F.marram(80, 150, 5) F.marram(8, 150, 4) F.thrift(86, 152, false)
F.depth(2)
do -- a bleached driftwood trunk lying in the turf, shells and thrift along it
  local fl = c:rrect(98, 151, 138, 156, 2)
  F.shadow(100, 138, 157, 5, 2)
  rimOf(fl, L.timber) part(fl, L.timber, { nopop = true }) F.logs(fl, L.timber, 151, 6) F.lichen(fl, .1, 26)
  fl:each(function(x, y) if y == 151 then px(x, y, L.timber.hi) end end)
  F.logEnd(137, 153, 2)
  -- a broken branch stub
  F.driftwood(110, 151, 106, 145, 1)
  shells(116, 151) F.shell(126, 150, true)
  F.marram(94, 158, 5) F.thrift(144, 158, true) F.pebbles(132, 159, 3, 26)
end
F.depth(1)

---------------------------------------------------------------- washing line from a hawthorn to a driftwood pole
F.tree(84, 140, 40, 0)
F.depth(2)
F.driftwood(184, 141, 182, 106, 2)
F.driftwood(182, 112, 188, 106, 1)
buoy(182, 103, 3, L.glass, false, 0) -- a green glass float on top
local function sagY(x) local t = (x - 88) / (182 - 88) return floor(108 + 8 * sin(t * pi)) end
for x = 88, 182 do px(x, sagY(x), L.awnB.deep) end
for i, it in ipairs({ { 98, L.awnA, "sock" }, { 112, blue, "shirt" }, { 132, L.gold, "sock" }, { 146, L.accent, "shirt" }, { 166, L.roof2, "sock" } }) do
  local x = it[1] local y = sagY(x) + 1 local r = it[2]
  local m
  if it[3] == "sock" then m = rect(x, y, x + 3, y + 8):add(rect(x, y + 6, x + 6, y + 9))
  else m = rect(x - 2, y, x + 10, y + 3):add(rect(x + 1, y, x + 7, y + 13)) end
  rimOf(m, r) part(m, r, { nopop = true })
  hline(x, x + 3, y, r.hi) px(x + 1, y - 1, L.timber.base)
  if it[3] == "sock" then hline(x, x + 3, y + 2, L.awnB.hi) end
  if it[3] == "shirt" and r == L.accent then for yy = y + 5, y + 12, 2 do hline(x + 1, x + 7, yy, r.shade) end end -- guernsey knit
end

---------------------------------------------------------------- right, behind the bell tent: nets and buoys on drying poles
F.depth(2)
do
  local poles = union(rect(362, 110, 363, 142), rect(404, 112, 405, 142))
  rimOf(poles, L.timber) part(poles, L.timber, { nopop = true, noshade = true })
  px(362, 110, L.timber.hi) px(404, 112, L.timber.hi)
  F.netSwag(364, 403, 114, 16, { floatStep = 6 })
  buoy(360, 124, 2, L.awnA, true, 3) buoy(408, 124, 2, L.produce, false, 3)
end

---------------------------------------------------------------- back right: the clam-bake pit steaming under wrack
F.depth(2)
do
  local cx, cy = 420, 150
  F.shadow(392, 450, 156, 8, 2)
  local pit = c:ellipse(cx, cy, 26, 6)
  local mound = c:ellipse(cx - 2, cy - 2, 18, 8):clip(rect(cx - 22, cy - 12, cx + 18, cy + 1))
  fill(pit, L.tar.shade)
  pit:each(function(x, y) if hash(x, y, 61) < .3 then px(x, y, G.deep) end end) -- hot stones glowing
  -- the cobble ring
  for k = 0, 15 do
    local a = k / 16 * 2 * pi
    local x, y = floor(cx + cos(a) * 25), floor(cy + sin(a) * 6)
    local st = c:rrect(x - 3, y - 2, x + 2, y + 2, 1)
    rimOf(st, L.stone) part(st, L.stone, { nopop = k % 3 ~= 0 })
    if sin(a) > 0 then F.barnacles(st, .15, 62 + k, 0) end
  end
  -- the steaming mound of wrack
  rimOf(mound, L.kelp)
  mound:each(function(x, y)
    local lt = (x - cx) / 18 + (y - cy) / 8 * .8
    local h = lt < -.5 and L.kelp.hi or (lt < .3 and L.kelp.base or L.kelp.shade)
    local v = hash(x, y, 63)
    if v < .12 then h = L.kelp.deep elseif v > .92 then h = L.kelp.hi end
    if (x + y * 2) % 7 == 0 then h = L.kelp.shade end
    px(x, y, h)
  end)
  -- lobsters, clams and a corn cob peeking out
  F.sprite({
    "aa....aa........",
    "aAa..aAa...aa...",
    ".aAaaaAa.aaAAa..",
    "..aaAaaaaaAAaaaa",
    ".a.aaaaaaaaaaa.a",
    "a.a.a.a.a..aa...",
  }, cx - 18, cy - 9, { a = L.awnA.base, A = L.awnA.hi }, { rimCol = L.awnA.edge })
  F.sprite({ ".ccCc.", "cCcccC", ".cccc." }, cx + 3, cy - 10, { c = L.awnB.base, C = L.awnB.hi }, { rimCol = L.awnB.edge })
  F.sprite({ ".ccCc.", "cCcccC", ".cccc." }, cx + 11, cy - 6, { c = L.awnB.base, C = L.awnB.hi }, { rimCol = L.awnB.edge })
  F.sprite({ ".ccCc.", "cCcccC", ".cccc." }, cx - 6, cy - 2, { c = L.awnB.base, C = L.awnB.hi }, { rimCol = L.awnB.edge })
  F.sprite({ "gGgGg", "GgGgG" }, cx - 4, cy - 10, { g = L.gold.base, G = L.gold.hi }, { rimCol = L.gold.edge })
  -- steam rising in pale wisps (against the sky/sea, not the chalk)
  for k = 0, 2 do
    local bx = cx - 9 + k * 8
    for t = 0, 18 + k * 3 do
      local x, y = floor(bx + sin(t * .45 + k * 2) * 1.6 + t * .3), cy - 11 - t
      if hash(t, k, 64) > .12 then
        px(x, y, t < 9 and L.cloud.top or L.cloud.mid)
        if t < 13 then px(x + 1, y, t < 6 and L.cloud.mid or L.cloud.shade) end
      end
    end
  end
  F.smoke(cx + 6, cy - 14, 4, 1.0, 1)
  -- a basket of clams
  local bk = c:rrect(386, 152, 396, 159, 2)
  rimOf(bk, L.needle) part(bk, L.needle, { nopop = true })
  bk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) end end)
  for x = 387, 395, 2 do px(x, 151, L.awnB.hi) px(x + 1, 151, L.awnB.shade) px(x, 150, L.awnB.base) end
end
F.depth(3)
-- the clam-baker forking on more wrack
do
  local _, hx, hy = F.gnome(450, 162, { hat = L.awnA, coat = L.accent, arm = "out", flip = true })
  local fork = line({ { hx + 2, hy + 4 }, { hx - 14, hy - 8 } }, 1)
  rimOf(fork, L.tar) part(fork, L.timber, { nopop = true, noshade = true })
  for k = 0, 2 do line({ { hx - 14 - k, hy - 8 + k }, { hx - 18 - k, hy - 9 + k } }):each(function(x, y) px(x, y, IR.base) end) end
  F.wrack(hx - 22, hy - 12, 6, 9) F.wrack(hx - 20, hy - 10, 4, 4)
end

---------------------------------------------------------------- right: cream-and-blue bell tent glowing inside
F.depth(3)
local mixS = F.mix(blue.hi, blue.base, .5)
local function bellTent(cx, yb)
  local wall = rect(cx - 46, yb - 26, cx + 46, yb)
  local cone = poly{ { cx - 52, yb - 24 }, { cx - 30, yb - 46 }, { cx, yb - 62 }, { cx + 30, yb - 46 }, { cx + 52, yb - 24 } }
  local pole = rect(cx - 1, yb - 74, cx, yb - 62)
  F.shadow(cx - 44, cx + 46, yb, 16, 5)
  rimOf(union(wall, cone, pole), L.tar)
  cone:each(function(x, y)
    local u = (x - cx) / (yb + 4 - y)
    local k = floor(u * 9 + 20) % 2
    local edge = (u * 9 + 20) % 1 < .12
    local lit = x < cx - 4 and (cx - x) / 30 + (y - (yb - 62)) / 22 < 1.3
    px(x, y, edge and L.awnB.deep or (k == 0 and (lit and blue.hi or mixS) or (lit and L.plaster.hi or L.awnB.hi)))
  end)
  wall:each(function(x, y)
    local k = floor((x - cx) / 10 + 20) % 2
    px(x, y, ((x - cx) % 10 == 0) and L.awnB.deep or (k == 0 and L.awnB.hi or blue.hi))
  end)
  wall:each(function(x, y) if x > cx + 30 and (x - cx) % 10 ~= 0 then px(x, y, (floor((x - cx) / 10 + 20) % 2 == 0) and L.awnB.shade or blue.base) end end)
  cone:each(function(x, y) if x > cx + 20 and (x - cx) / 52 + (y - (yb - 62)) / 40 > 1.1 and c:get(x, y) ~= L.awnB.deep then px(x, y, (floor((x - cx) / (yb + 4 - y) * 9 + 20) % 2 == 0) and blue.shade or L.awnB.shade) end end)
  -- a gull feather and salt spots on the canvas; a hem stained with blown sand and dried wrack
  cone:each(function(x, y) if hash(x, y, 84) < .004 then px(x, y, L.sand.shade) end end)
  px(cx - 20, yb - 40, L.gull.shade) px(cx - 19, yb - 41, L.gull.hi) px(cx - 18, yb - 42, L.gull.hi)
  wall:each(function(x, y)
    local hgt = 2 + floor(hash(x // 3, 0, 86) * 4)
    if y >= yb - hgt then px(x, y, hash(x, y, 87) < .45 and L.sand.shade or (hash(x, y, 88) < .6 and L.sand.deep or L.kelp.shade)) end
  end)
  hline(cx - 52, cx + 52, yb - 24, blue.deep) hline(cx - 51, cx + 51, yb - 23, blue.shade)
  for x = cx - 50, cx + 48, 6 do fill(poly{ { x, yb - 22 }, { x + 6, yb - 22 }, { x + 3, yb - 18 } }, blue.base) px(x + 3, yb - 19, blue.shade) px(x + 1, yb - 22, blue.hi) end
  part(pole, L.timber, { nopop = true, noshade = true })
  local fl = poly{ { cx + 1, yb - 74 }, { cx + 12, yb - 71 }, { cx + 1, yb - 68 } } fill(fl, L.awnA.base) px(cx + 2, yb - 73, L.awnA.hi) px(cx + 9, yb - 71, L.awnA.shade)
  -- open door with warm light, a hanging lantern inside, a rug, a bedroll
  local door = poly{ { cx - 12, yb }, { cx - 6, yb - 30 }, { cx + 6, yb - 30 }, { cx + 12, yb } }
  fill(door, G.shade) fill(poly{ { cx - 8, yb }, { cx - 4, yb - 26 }, { cx + 4, yb - 26 }, { cx + 8, yb } }, G.base)
  fill(rect(cx - 2, yb - 22, cx + 2, yb - 16), G.hi) vline(cx, yb - 26, yb - 23, L.timber.edge) px(cx - 1, yb - 21, L.awnB.hi)
  fill(rect(cx - 6, yb - 6, cx + 6, yb - 1), L.roof2.shade) hline(cx - 6, cx + 6, yb - 6, L.roof2.base)
  for x = cx - 5, cx + 5, 3 do px(x, yb - 4, L.gold.base) end
  local flapL = poly{ { cx - 12, yb }, { cx - 6, yb - 30 }, { cx - 20, yb - 2 } } fill(flapL, L.awnB.shade) c:edgeIn(flapL, L.awnB.deep)
  local flapR = poly{ { cx + 12, yb }, { cx + 6, yb - 30 }, { cx + 20, yb - 2 } } fill(flapR, L.awnB.shade) c:edgeIn(flapR, L.awnB.deep)
  for _, t in ipairs({ { cx - 14, yb - 14 }, { cx + 14, yb - 14 } }) do hline(t[1] - 1, t[1] + 1, t[2], L.roof2.base) end -- tie-backs
  for _, g in ipairs({ { cx - 52, yb - 24, cx - 66, yb + 2 }, { cx + 52, yb - 24, cx + 66, yb + 2 } }) do
    line({ { g[1], g[2] }, { g[3], g[4] } }):each(function(x, y) px(x, y, L.board.deep) end)
    fill(rect(g[3] - 1, g[4] - 2, g[3], g[4] + 1), L.timber.base) px(g[3] - 1, g[4] - 2, L.board.hi)
  end
end
bellTent(350, 196)
-- marram, thrift and shells at the tent's feet
for _, f in ipairs({ { 300, 198, 6 }, { 308, 200, 4 }, { 398, 198, 6 } }) do F.marram(f[1], f[2], f[3]) end
F.thrift(392, 201, true) shells(384, 202)

---------------------------------------------------------------- left: driftwood stacked between stakes, buoys on the stakes
local function woodStack(x0, x1, yb)
  local stakes = rect(x0 - 2, yb - 22, x0, yb):add(rect(x1, yb - 22, x1 + 2, yb))
  local stack = rect(x0 + 1, yb - 18, x1 - 1, yb)
  F.shadow(x0, x1 + 2, yb, 8, 3)
  rimOf(union(stakes, stack), L.timber)
  part(stakes, L.timber, { nopop = true, noshade = true })
  px(x0 - 2, yb - 22, L.timber.hi) px(x1, yb - 22, L.timber.hi)
  fill(stack, L.timber.edge)
  for row = 0, 3 do for k = 0, (x1 - x0) // 6 do
    local x, y = x0 + 3 + k * 6 + (row % 2) * 3, yb - 3 - row * 5
    local v = hash(k, row, 90)
    if x < x1 - 1 then F.logEnd(x, y, 2, v < .25 and L.board or (v < .4 and L.cork or L.timber)) end
  end end
  -- a tarred canvas cover weighed down with a cobble
  local lid = rect(x0 - 3, yb - 24, x1 + 3, yb - 21)
  rimOf(lid, L.tar) part(lid, L.tar, { nopop = true })
  for x = x0, x1, 7 do vline(x, yb - 23, yb - 21, L.tar.deep) end
  local cob = c:ellipse(x0 + 20, yb - 26, 3, 2) rimOf(cob, L.stone) part(cob, L.stone, { nopop = true })
  buoy(x0 - 1, yb - 14, 2, L.awnA, true, 6)
  buoy(x1 + 1, yb - 12, 2, L.gold, false, 8)
end
woodStack(22, 72, 196)
-- an oystercatcher picking at a cockle by the woodpile
F.sprite({
  "......KKK.....",
  ".....KKKKK....",
  "ROOOKeKKK.....",
  ".....KKKKKK...",
  "......KKKKKKKK",
  "......WWWWKKK.",
  ".......WWWW...",
  "........p..p..",
  ".......pp.pp..",
}, 72, 187, { K = L.tar.base, W = L.gull.hi, R = L.produce.shade, O = L.produce.base, e = L.apple.base, p = L.petal.shade }, { rimCol = L.tar.edge })
hline(79, 82, 191, L.tar.hi) -- wing sheen
F.shell(71, 196, true)
F.marram(20, 206, 7) F.marram(28, 204, 5) F.thrift(84, 204, true)
-- a gnome pegging a sock on the washing line
F.gnome(140, 134, { small = true, hat = L.produce, coat = L.leaf, arm = "up" })

---------------------------------------------------------------- the driftwood bonfire (hero) with tripod pot, log seats and a stump
local function campfire(cx, cy)
  local function seat(x0, x1, y, bark, seed)
    bark = bark or L.timber
    local m = c:rrect(x0, y - 4, x1, y + 4, 4)
    F.shadow(x0, x1, y + 6, 4, 2)
    rimOf(m, bark) part(m, bark, { nopop = true })
    F.logs(m, bark, y - 4, 9)
    hline(x0 + 4, x1 - 4, y - 3, bark.hi)
    m:each(function(x, yy) if (x * 3 + yy) % 13 == 0 then px(x, yy, bark.deep) end end)
    m:each(function(x, yy) if yy <= y - 2 and hash(x // 2, yy, x0) < .12 then px(x, yy, bark.hi) end end)
    -- worm holes and a weathered knot, sand at the foot
    for k = 0, 3 do local hx = x0 + 6 + floor(hash(k, x0, seed or 1) * (x1 - x0 - 12)) px(hx, y + floor(hash(k, 2, seed or 1) * 4) - 1, bark.edge) end
    m:each(function(x, yy) if yy >= y + 3 and hash(x, yy, x0 + 2) < .4 then px(x, yy, L.sand.shade) end end)
    F.logEnd(x1 - 3, y, 4, bark)
  end
  seat(cx - 34, cx + 38, cy - 24, L.timber, 3)
  local ring = c:ellipse(cx, cy, 24, 9):cut(c:ellipse(cx, cy, 17, 5))
  local pit = c:ellipse(cx, cy, 17, 5)
  fill(pit, L.tar.deep)
  pit:each(function(x, y) if hash(x, y, 8) < .3 then px(x, y, L.road.shade) end end) -- ash
  for k = 0, 13 do
    local a = k / 14 * 2 * pi
    local x, y = floor(cx + cos(a) * 21), floor(cy + sin(a) * 7)
    local st = c:rrect(x - 4, y - 3, x + 3, y + 2, 2)
    local r = (k % 3 == 1) and L.shingle or L.stone
    rimOf(st, r) part(st, r, { nopop = k % 3 ~= 0 })
    if sin(a) > -.2 then F.lichen(st, .12, 92 + k) end
  end
  -- the bonfire: bleached driftwood sticks leaned into a teepee
  local sticks = HP.mask()
  for _, s in ipairs({ { -14, 2, -1 }, { -9, -3, 1 }, { 12, 2, 0 }, { 8, -4, -1 }, { -3, 3, 1 }, { 4, 3, 0 } }) do
    sticks:add(line({ { cx + s[1], cy + s[2] }, { cx + s[3] + floor(s[1] * .15), cy - 24 } }, 2))
  end
  rimOf(sticks, L.timber) part(sticks, L.timber, { nopop = true })
  sticks:each(function(x, y) if hash(x, y, 93) < .2 then px(x, y, G.deep) elseif y < cy - 18 and hash(x, y, 95) < .3 then px(x, y, L.timber.hi) end end)
  pit:each(function(x, y) if hash(x, y, 9) < .25 and not sticks:has(x, y) then px(x, y, G.deep) end end)
  local fl = poly{ { cx - 12, cy }, { cx - 9, cy - 16 }, { cx - 5, cy - 9 }, { cx - 2, cy - 28 }, { cx + 2, cy - 12 }, { cx + 6, cy - 22 }, { cx + 9, cy - 8 }, { cx + 12, cy } }
  fill(fl, G.deep)
  fill(fl:shrink(1), G.shade)
  fill(poly{ { cx - 8, cy }, { cx - 3, cy - 20 }, { cx + 1, cy - 9 }, { cx + 5, cy - 15 }, { cx + 8, cy } }, G.base)
  fill(poly{ { cx - 4, cy }, { cx - 1, cy - 12 }, { cx + 3, cy } }, G.hi)
  -- salt-soaked driftwood burns with blue-green flickers at its foot
  for _, b in ipairs({ { -9, -2 }, { -7, -4 }, { 7, -3 }, { 9, -1 }, { 6, -5 }, { -10, -1 } }) do px(cx + b[1], cy + b[2], L.glass.hi) px(cx + b[1], cy + b[2] - 1, L.glass.base) end
  local front = HP.mask()
  for _, s in ipairs({ { -14, 2, -1 }, { 12, 2, 0 } }) do
    front:add(line({ { cx + s[1], cy + s[2] }, { cx + s[3] + floor(s[1] * .15), cy - 24 } }, 2))
  end
  rimOf(front, L.timber) part(front, L.timber, { nopop = true })
  front:each(function(x, y) if hash(x, y, 93) < .2 then px(x, y, G.deep) elseif y < cy - 18 and hash(x, y, 95) < .3 then px(x, y, L.timber.hi) end end)
  -- charred stick tips poking out of the flames
  px(cx - 1, cy - 25, L.tar.base) px(cx, cy - 26, L.tar.deep) px(cx + 1, cy - 24, L.tar.base)
  for i = 0, 14 do px(cx - 14 + floor(hash(i, 1, 31) * 30), cy - 32 - floor(hash(i, 2, 31) * 24), i % 3 == 0 and G.base or G.hi) end
  local tri = line({ { cx - 18, cy + 4 }, { cx, cy - 40 } }, 2):add(line({ { cx + 18, cy + 4 }, { cx, cy - 40 } }, 2)):add(line({ { cx + 4, cy - 2 }, { cx, cy - 40 } }, 1))
  rimOf(tri, L.tar) part(tri, L.timber, { nopop = true, noshade = true }) -- driftwood poles
  tri:each(function(x, y) local v = hash(x, y // 2, 94) if v < .15 then px(x, y, L.timber.shade) elseif v > .85 then px(x, y, L.timber.hi) end end)
  hline(cx - 2, cx + 2, cy - 38, L.cork.deep) -- lashing
  vline(cx, cy - 37, cy - 30, IR.deep)
  local pot = c:ellipse(cx, cy - 25, 7, 5):add(rect(cx - 7, cy - 28, cx + 7, cy - 26))
  rimOf(pot, IR) part(pot, IR) hline(cx - 7, cx + 7, cy - 28, IR.hi) fill(rect(cx - 5, cy - 29, cx + 5, cy - 29), L.sand.hi)
  px(cx - 3, cy - 29, L.accent.deep) px(cx - 2, cy - 29, L.accent.base) px(cx + 2, cy - 29, L.produce.base) px(cx + 4, cy - 30, IR.hi) -- chowder: a mussel, a carrot, a fish tail
  fill(c:ellipse(cx, cy - 29, 7, 3):cut(c:ellipse(cx, cy - 29, 6, 2)):clip(rect(cx - 8, cy - 33, cx + 8, cy - 29)), IR.deep)
  F.smoke(cx + 1, cy - 38, 8, .8, 2)
  -- warm light on the sand
  local glowM = c:ellipse(cx, cy + 4, 42, 14):cut(c:ellipse(cx, cy, 25, 10))
  glowM:each(function(x, y) if hash(x, y, 33) < .3 and not F.roadM:has(x, y) then px(x, y, hash(x, y, 34) < .5 and L.gold.hi or L.sand.hi) end end)
  seat(cx - 46, cx - 22, cy + 4, L.timber, 5)
  seat(cx + 24, cx + 50, cy + 2, L.board, 6)
  seat(cx - 16, cx + 18, cy + 20, L.timber, 7)
end
campfire(132, 214)
-- the concertina player
local _, lx, ly = F.gnome(104, 191, { hat = L.leaf, coat = L.roof2, arm = "hold", noShadow = true })
do
  local box = rect(lx - 2, ly - 3, lx + 8, ly + 2)
  rimOf(box, L.tar)
  fill(box, L.awnA.base)
  for x = lx, lx + 6, 2 do vline(x, ly - 3, ly + 2, L.awnA.shade) end
  hline(lx, lx + 6, ly - 3, L.awnA.hi)
  fill(rect(lx - 2, ly - 3, lx - 1, ly + 2), L.accent.base) fill(rect(lx + 7, ly - 3, lx + 8, ly + 2), L.accent.shade)
  px(lx - 2, ly - 3, L.accent.hi) px(lx + 7, ly - 1, L.gold.hi) px(lx - 1, ly, L.gold.hi)
end
for _, n in ipairs({ { lx + 8, ly - 14 }, { lx + 13, ly - 18 } }) do vline(n[1] + 1, n[2] - 3, n[2], L.tar.edge) fill(rect(n[1], n[2], n[1] + 1, n[2] + 1), L.tar.edge) end
local _, mx, my = F.gnome(96, 210, { hat = L.awnA, coat = blue, arm = "out" })
-- a toasting stick: a marshmallow and a little sprat skewered on it
fill(line({ { mx, my }, { mx + 10, my - 7 } }), L.board.base) fill(rect(mx + 10, my - 9, mx + 12, my - 7), L.awnB.hi) px(mx + 12, my - 7, L.sand.shade) px(mx + 10, my - 9, L.plaster.hi)
px(mx + 5, my - 4, IR.hi) px(mx + 6, my - 4, IR.base) px(mx + 7, my - 5, IR.hi) px(mx + 4, my - 5, IR.shade) px(mx + 4, my - 3, IR.shade)
local _, ux, uy = F.gnome(174, 208, { hat = L.gold, coat = L.lav, arm = "out", flip = true })
fill(rect(ux - 3, uy - 3, ux, uy + 1), L.board.hi) px(ux, uy - 2, L.board.base) px(ux - 3, uy - 3, L.board.base) px(ux - 2, uy - 5, L.cloud.top) px(ux - 1, uy - 7, L.cloud.top)
-- a black-and-white collie asleep by the fire, nose on its paws
F.sprite({
  ".ee.............",
  "eDDe....DDDDD...",
  "DDeDDDDDDDDDDD..",
  "nwDDDDDDDDdDDDt.",
  "wwwDDDDDDDDDDDtt",
  ".wwwwwddddddd...",
}, 154, 228, { e = L.tar.shade, D = L.iron.shade, d = L.tar.shade, n = L.tar.edge, w = L.gull.hi, t = L.gull.hi }, { rimCol = L.tar.edge })
hline(156, 157, 230, L.tar.edge) px(160, 229, L.iron.hi) px(166, 229, L.iron.hi) hline(162, 168, 230, L.iron.base) hline(162, 167, 229, L.iron.base)
-- a driftwood stump stool by the concertina player; pebbles and shells by the ring
stump(66, 216, 5, .12, 23)
for _, p in ipairs({ { 112, 230 }, { 158, 222 }, { 84, 222 }, { 192, 236 } }) do F.pebbles(p[1], p[2], 2, p[1]) end
F.shell(120, 236, true) F.shell(186, 228, false)

---------------------------------------------------------------- camp kitchen table, bottom-left
local tbl = rect(24, 236, 76, 239):add(rect(27, 240, 30, 252)):add(rect(70, 240, 73, 252))
F.shadow(26, 76, 252, 8, 3)
rimOf(tbl, L.timber) part(tbl, L.board, { nopop = true })
F.planks(rect(24, 236, 76, 239), L.board, 9, true, 31)
fill(rect(28, 241, 29, 252), L.timber.base) fill(rect(71, 241, 72, 252), L.timber.shade) -- driftwood legs
local ket = c:ellipse(36, 231, 5, 4):add(rect(41, 228, 44, 229)) rimOf(ket, L.accent) part(ket, L.accent) fill(rect(34, 226, 38, 227), L.accent.shade)
local pan = c:ellipse(56, 234, 7, 2) rimOf(pan, IR) part(pan, IR, { nopop = true }) fill(rect(63, 233, 70, 234), L.timber.base)
for k = 0, 1 do hline(51 + k * 6, 54 + k * 6, 233, IR.hi) px(55 + k * 6, 233, L.gold.base) px(50 + k * 6, 233, IR.shade) end -- two fried sprats
-- a woven basket of mussels
local bask = c:rrect(64, 228, 75, 235, 2)
rimOf(bask, L.needle) part(bask, L.needle, { nopop = true })
bask:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) end end)
for k = 0, 4 do local x = 65 + k * 2 px(x, 227, L.accent.deep) px(x + 1, 227, L.accent.shade) px(x, 226, L.accent.hi) end
line({ { 64, 228 }, { 69, 222 }, { 75, 228 } }):each(function(x, y) if y < 228 then px(x, y, L.needle.deep) end end)
-- under the table: a water bucket, a coil of rope; marram and thrift
local bucket = rect(40, 244, 48, 251) rimOf(bucket, L.timber) part(bucket, L.timber, { nopop = true }) hline(40, 48, 246, IR.shade) hline(41, 47, 244, L.water.base)
local coil = c:ellipse(60, 249, 5, 2)
rimOf(coil, L.cork) fill(coil, L.cork.base) hline(57, 63, 249, L.cork.shade) fill(c:ellipse(60, 249, 2, 1), L.cork.deep) px(57, 248, L.cork.hi)
F.marram(20, 254, 7) F.marram(82, 252, 6)
F.thrift(14, 244, true) F.shell(10, 248, true) F.wrack(86, 258, 6, 2)

---------------------------------------------------------------- bedrolls, packs, the raccoon ... and the gull (right of the road)
local function bedroll(x, y, r)
  local m = c:rrect(x - 14, y - 5, x + 14, y + 5, 5)
  rimOf(m, r) part(m, r)
  for k = -8, 8, 8 do vline(x + k, y - 5, y + 5, r.deep) end
  local e = c:ellipse(x + 12, y, 3, 5) fill(e, r.hi) c:ellipse(x + 12, y, 1, 3):edge():each(function(xx, yy) px(xx, yy, r.shade) end)
  hline(x - 6, x - 4, y - 5, L.timber.base)
  m:each(function(xx, yy) if (xx + yy * 2) % 7 == 0 and yy < y then px(xx, yy, r.hi) end end) -- check weave
end
bedroll(300, 230, blue) bedroll(312, 240, L.roof2)
local function pack(x, yb, r)
  local m = c:rrect(x - 8, yb - 18, x + 8, yb, 4)
  local flap = c:rrect(x - 8, yb - 20, x + 8, yb - 12, 3)
  F.shadow(x - 6, x + 8, yb, 6, 2)
  rimOf(union(m, flap), r) part(m, r) part(flap, r, { sep = true })
  fill(rect(x - 1, yb - 13, x + 1, yb - 11), L.gold.base) px(x - 1, yb - 13, L.gold.hi)
  vline(x - 5, yb - 11, yb - 2, r.deep) vline(x + 5, yb - 11, yb - 2, r.deep)
  fill(c:ellipse(x + 10, yb - 8, 4, 4), IR.base) px(x + 9, yb - 10, IR.hi) px(x + 12, yb - 6, IR.deep)
end
pack(346, 258, L.leaf)
pack(330, 262, L.roof)
F.sprite({
  ".kk..........kk.",
  "kggk........kggk",
  "kgggggggggggggk.",
  "gggwwggggggwwgg.",
  "gwwkkkwggwkkkwwg",
  "gwkkKkkwwkkKkkwg",
  ".gwkkkwwwwkkkwg.",
  "..gwwwwnnwwwwg..",
  "...gwwwwwwwwg...",
  "...gggggggggg...",
  "..pggggggggggp..",
  "SSSSSSSSSSSSSs..",
  "ssSSSSSSSSSSSS..",
  "..pg........gp..",
}, 337, 224, { k = L.stone.edge, g = L.stone.base, w = L.awnB.hi, K = L.awnB.hi, n = L.timber.edge, p = L.stone.shade, S = L.awnA.shade, s = L.awnA.hi })
F.sprite({ "gg", "kk", "gg", "kk", "gg", "kk" }, 355, 238, { g = L.stone.base, k = L.stone.edge })
-- the herring gull, neck stretched, the far end of the sausage clamped in its yellow bill
F.shadow(364, 380, 247, 4, 1)
F.sprite({
  "....WWW...............",
  "...WWWWW..............",
  "YYYWeWWWW.............",
  "rY..WWWWWW............",
  ".....WWWWWW...........",
  "......WWWWWWGGGGGG....",
  "......WWWWGGGGGGGGGGKK",
  ".......WWWGGGGGGGGKKKK",
  "........WWWWWGGGGwKKK.",
  ".........WWWWWWWWW....",
  "...........WWWWW......",
  "............p..p......",
  "............p..p......",
  "...........pp.pp......",
}, 355, 233, { W = L.gull.hi, G = L.gull.shade, K = L.tar.deep, w = L.gull.hi, Y = L.gold.base, r = L.apple.base, e = L.tar.edge, p = L.petal.shade }, { rimCol = L.gull.edge })
px(363, 239, L.gull.base) px(364, 240, L.gull.base) px(365, 242, L.gull.base) -- breast shading
-- a string of linked sausages pulled taut between the raccoon's paws and the gull's bill
F.sprite({
  ".aAAa.aAAa.",
  "aAAAAnaAAAa",
  "assssnassss",
  ".aaaa.aaaa.",
}, 345, 233, { a = L.awnA.base, A = L.awnA.hi, s = L.awnA.shade, n = L.tar.base }, { rimCol = L.awnA.edge })
px(347, 234, L.cloud.top) px(353, 234, L.cloud.top)
F.marram(364, 262, 8) F.marram(320, 268, 6) F.marram(294, 258, 5)
F.shell(304, 252, true) F.shell(372, 256, false)
F.depth(0)
F.gull(330, 40, 3) F.gull(344, 48, 2) F.gull(120, 30, 2) F.gull(420, 44, 2)
F.birds({ { 286, 52, 1 }, { 200, 30, 1 } })
F.depth(3)

---------------------------------------------------------------- near right: driftwood chopping block, sea-buckthorn, marram
F.depth(2)
F.tree(456, 206, 48, 1)
F.depth(3)
F.windTree(436, 228, 22, L.foliage2, 44)
local cs = stump(416, 224, 8, .1, 24)
-- a hatchet bitten into the block, split driftwood kindling around it
local haft = line({ { 417, 213 }, { 426, 203 } }, 1) c:rim(haft, L.timber.edge) haft:each(function(x, y) px(x, y, L.board.base) end) px(426, 203, L.board.hi)
local axe = poly{ { 410, 210 }, { 417, 211 }, { 417, 216 }, { 411, 217 } } c:rim(axe, IR.edge) fill(axe, IR.base) vline(410, 210, 217, IR.hi) px(411, 210, IR.hi) px(416, 216, IR.deep) vline(417, 211, 216, IR.shade)
for _, s in ipairs({ { 404, 224 }, { 432, 226 } }) do
  local m = poly{ { s[1], s[2] }, { s[1] + 5, s[2] - 2 }, { s[1] + 6, s[2] }, { s[1] + 1, s[2] + 2 } }
  rimOf(m, L.timber) fill(m, L.board.base) px(s[1] + 1, s[2], L.board.hi) px(s[1] + 5, s[2] - 1, L.timber.base)
end
F.marram(462, 222, 7) F.marram(470, 226, 5)
F.thrift(450, 220, true) F.pebbles(398, 222, 3, 41)

---------------------------------------------------------------- by the road: a driftwood lantern pole, the sign
F.driftwood(287, 212, 286, 177, 2)
F.lichen(rect(286, 204, 287, 212), .4, 25)
fill(rect(281, 176, 287, 177), L.timber.base) vline(281, 178, 180, L.tar.edge)
local lan = rect(278, 181, 284, 188) rimOf(lan, L.tar) fill(lan, G.base) px(279, 182, G.hi) vline(284, 182, 188, G.shade) hline(278, 284, 181, L.tar.base)
buoy(290, 196, 2, L.awnA, true, 2)
F.sign(212, 196, 20, 12, L.board)
fill(poly{ { 206, 205 }, { 212, 198 }, { 218, 205 } }, blue.base) fill(poly{ { 211, 205 }, { 212, 202 }, { 213, 205 } }, L.tar.deep) px(210, 200, blue.hi)
F.marram(204, 214, 5) F.shell(220, 212, true)
F.finish()
