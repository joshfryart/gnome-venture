-- inn.lua : "Inn" stop look, WETLAND (wetland_reed), 480x270 gate view.
-- Same composition as the Maplewold inn (art-2701-batch4/stops/opus3/inn.lua), re-cast for a reed fen:
-- left hero: a big two-storey fen inn standing on a stilted pier over a dyke. Clay-daub ground floor in a silver
-- timber frame with glowing bay windows, an upper floor of silver weatherboard with teal shutters and marigold
-- boxes, a deep golden water-reed thatch with a dark sedge ridge cap and eyebrow dormers, two brick chimneys with
-- peat smoke. A landing stage juts out in front of the door with lantern posts and steps to the bank; punts are
-- moored under the deck among eel traps and lilies. A peat-turf stack against the left gable.
-- A gallows sign post by the road hangs the EEL PIE board (a pie with an eel poking out of the crust).
-- Right: a beer garden under a big weeping willow, a long trestle table with three gnomes raising mugs, lantern
-- festoons across the road, a barrel stack, a waiter. Road's end: a reed-thatched boathouse on stilts.
-- Mid right: a dyke with a punt loaded with reed bundles. Greylag geese glean crumbs; a goose tugs a mooring rope.
-- Quirk: an otter in a red gnome hat asleep on top of the inn sign, tail hanging down over the pie, "z z" rising.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-wetland-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "inn", out = DIR, farTrees = { 24, 150, 206, 300, 340, 380, 452 },
  poolK = .8, clouds = { { 150, 40, 44 }, { 300, 28, 50 }, { 410, 62, 30 }, { 230, 70, 22 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local mix = F.mix
local BRICK = F.rp("#d49a76 #b0704e #8a5240 #643a32 #40242a")  -- soft fen brick
local EEL = F.rp("#b4b88c #868e64 #626c4a #444e38 #2a3226")    -- eel olive

-- a lantern on a post: square glowing box with a cap, a ring, and a warm pool of light on what's around it
local function lanternPost(x, ytop, yb, r)
  r = r or L.timber
  local post = rect(x, ytop + 8, x + 1, yb)
  local cap = rect(x - 3, ytop, x + 4, ytop + 1)
  local box = rect(x - 2, ytop + 2, x + 3, ytop + 7)
  rimOf(union(post, cap, box), r)
  part(post, r, { nopop = true, noshade = true })
  part(cap, r, { nopop = true, noshade = true }) px(x - 3, ytop, r.hi)
  fill(box, L.glow.base) px(x - 1, ytop + 3, L.glow.hi) px(x - 1, ytop + 4, L.glow.hi) vline(x + 3, ytop + 3, ytop + 7, L.glow.shade)
  vline(x + 1, ytop + 2, ytop + 7, r.deep)
  px(x, ytop - 1, L.iron.base)
end
-- an eel trap: a wicker cone (side view) from (x, y) pointing right, len long
local function eelTrap(x, y, len, flip)
  local s = flip and -1 or 1
  local m = poly{ { x, y - 3 }, { x + s * len, y - 1 }, { x + s * len, y }, { x, y + 3 } }
  rimOf(m, L.reed) part(m, L.reed, { nopop = true })
  m:each(function(xx, yy) if (xx * s) % 3 == 0 then px(xx, yy, L.reed.shade) elseif (xx + yy) % 2 == 0 and yy < y then px(xx, yy, L.reed.hi) end end)
  vline(x, y - 3, y + 3, L.timber.base)
  return m
end
-- a cut end of a reed bundle, face on
local function bundleEnd(x, y, r)
  local m = c:ellipse(x, y, r, r)
  c:rim(m, L.reed.edge)
  m:each(function(xx, yy)
    local d = (xx - x) + (yy - y)
    local col = d < -r * .6 and L.reed.hi or (d > r * .6 and L.reed.shade or L.reed.base)
    if (xx + yy * 2) % 3 == 0 then col = (d < 0) and L.reed.base or L.reed.deep end
    px(xx, yy, col)
  end)
  px(x, y, L.reed.deep)
end

---------------------------------------------------------------- back row: a stilted boathouse at the road's end, a far fen cottage
F.depth(1)
F.tree(300, 128, 34, 3)
F.tree(236, 126, 30, 1)
do
  -- the strip of dyke the boathouse stands over
  local dk = poly{ { 242, 126 }, { 296, 126 }, { 298, 131 }, { 244, 131 } }
  F.water(dk, L.water, { dark = true })
  local top, _, bwall, broof = F.building{ x0 = 248, x1 = 290, yb = 124, wh = 15, rh = 14, wall = L.board, roof = L.roof2, noFrame = true, noAttic = true, noShadow = true }
  F.planks(bwall, L.board, 3, true, 4)
  F.stilts({ 250, 262, 276, 288 }, 125, 131, 129)
  -- big open water arch with the nose of a punt showing
  local d = c:rrect(259, 112, 279, 132, 6):clip(rect(259, 112, 279, 124))
  fill(d, L.water.edge) c:edgeIn(d, L.timber.hi)
  fill(rect(263, 121, 275, 123), L.timber.base) hline(263, 275, 121, L.timber.hi) px(268, 117, L.glow.shade) px(269, 117, L.glow.base)
  F.moss(broof, .08, 31)
end
do
  local dk = poly{ { 410, 124 }, { 462, 124 }, { 464, 129 }, { 412, 129 } }
  F.water(dk, L.water, { dark = true })
  local top, _, cwall, croof = F.building{ x0 = 416, x1 = 456, yb = 121, wh = 13, rh = 11, wall = L.plaster, roof = L.roof, noFrame = true, noAttic = true, chimney = true, noShadow = true }
  F.stilts({ 418, 430, 442, 454 }, 122, 129, 127)
  F.window(424, 112, 428, 115, L.timber) F.window(446, 112, 450, 115, L.timber)
end
F.smoke(447, 92, 4, .5, 2)
F.fenceP(300, 132, 408, 129, 10)
F.reeds(296, 410, 131, 6, 21)
-- the boathouse washing line: aprons and tea towels (the inn's laundry), hazed with the back row
do local wp = rect(318, 112, 319, 130) rimOf(wp, L.timber) part(wp, L.timber, { nopop = true, noshade = true }) end
F.washing(293, 114, 318, 113, { { "sheet", L.awnB }, { "shirt", L.awnA }, { "sock", L.accent } }, 3)
F.mist(140, 226, 116, 120, 64, .45)

---------------------------------------------------------------- mid right: alder + pollards, a dyke with a punt loaded with reed bundles
F.depth(2)
F.tree(352, 150, 50, 1)
F.tree(324, 142, 30, 3)
F.tree(384, 152, 34, 3)
do
  local dyke = poly{ { 292, 150 }, { 396, 147 }, { 402, 158 }, { 384, 166 }, { 304, 168 }, { 294, 160 } }
  rimOf(dyke, L.peat)
  local bank = dyke:grow(2):cut(dyke)
  bank:each(function(x, y) local v = hash(x, y, 53) px(x, y, v < .4 and L.peat.base or (v < .65 and L.peat.hi or L.sedgeGround.base)) end)
  F.water(dyke, L.water)
  -- the reed lighter: a long punt piled with reed bundles, moored to a lantern post
  F.punt(304, 360, 162, L.timber)
  local pile = poly{ { 308, 158 }, { 356, 158 }, { 352, 150 }, { 312, 150 } }
  rimOf(pile, L.reed) part(pile, L.reed, { nopop = true })
  pile:each(function(x, y) if y % 2 == 0 then px(x, y, x < 330 and L.reed.hi or L.reed.base) end if (x - 308) % 10 == 5 then px(x, y, L.timber.deep) end end)
  for k = 0, 4 do bundleEnd(311 + k * 9, 155, 3) end
  for k = 0, 3 do bundleEnd(316 + k * 9, 150, 3) end
  for k = 0, 6 do px(360 + k, 150 + k // 2, L.plume.base) px(361 + k, 149 + k // 2, L.plume.hi) end -- plumes over the stern
  lanternPost(370, 132, 164)
  line({ { 358, 158 }, { 370, 150 } }):each(function(x, y) px(x, y, L.board.deep) end)
  hline(368, 374, 160, L.water.hi)
  -- a kingfisher on the lantern cap
  F.sprite({ ".bb..", "bBBko", "bWW..", ".tt.." }, 368, 127, { b = L.accent.shade, B = L.accent.hi, k = L.timber.edge, o = L.timber.deep, W = L.produce.base, t = L.accent.deep })
  F.reeds(386, 404, 158, 12, 22, { cattails = 2 })
  F.reeds(290, 302, 166, 10, 23, { green = true })
  F.lily(390, 162, false) F.lily(298, 154, false, "white")
end
F.mist(296, 402, 140, 142, 66, .35)

---------------------------------------------------------------- the beer-garden willow (behind the table)
F.depth(3)
F.shadowM(c:ellipse(430, 203, 34, 3))
F.willow(432, 200, 108, 18)
for _, cr in ipairs({ { 410, 112, 20, 9, L.willow, 5 }, { 452, 106, 20, 9, L.foliage2, 6 }, { 430, 96, 18, 7, L.willow, 7 }, { 400, 128, 12, 6, L.foliage2, 8 } }) do F.crown(cr[1], cr[2], cr[3], cr[4], cr[5], cr[6]) end

---------------------------------------------------------------- the inn's dyke: water under the pier, stilts, punts
F.depth(3)
local water = poly{ { 8, 184 }, { 188, 184 }, { 190, 198 }, { 186, 210 }, { 160, 219 }, { 120, 218 }, { 80, 222 }, { 40, 224 }, { 8, 226 } }
rimOf(water, L.peat)
do
  local bank = water:grow(2):cut(water)
  bank:each(function(x, y) if y > 186 then local v = hash(x, y, 51) px(x, y, v < .4 and L.peat.base or (v < .65 and L.peat.hi or L.sedgeGround.base)) end end)
end
F.water(water, L.water)
F.water(water:copy():clip(rect(8, 184, 192, 197)), L.water, { dark = true })
-- the lit windows and lanterns mirrored in the still water: broken warm streaks
for _, s in ipairs({ { 40, 76 }, { 134, 170 } }) do
  for y = 199, 211, 2 do
    for x = s[1] + (y % 4), s[2] - (y % 4), 1 do
      if water:has(x, y) and hash(x // 3, y, 88) < .45 then px(x, y, (y < 204) and L.glow.shade or L.glow.deep) end
    end
  end
end
F.stilts({ 18, 32, 46, 60, 150, 164, 178 }, 186, 210, 197)
for _, sx in ipairs({ 18, 32, 46, 60, 150, 164, 178 }) do for y = 207, 213, 2 do if water:has(sx, y) then px(sx, y, L.water.deep) px(sx + 1, y, L.water.shade) end end end

---------------------------------------------------------------- the inn (left hero)
F.depth(3)
local function inn()
  local X0, X1 = 30, 184
  local GTOP, YB = 142, 180          -- ground floor
  local UX0, UX1, UTOP = 25, 189, 106 -- jettied upper floor
  local ground = rect(X0, GTOP, X1, YB)
  local upper = rect(UX0, UTOP, UX1, GTOP - 1)
  local roof = poly{ { 14, UTOP + 1 }, { 200, UTOP + 1 }, { 178, 64 }, { 36, 64 } }
  local ch1, ch2 = rect(52, 48, 61, 70), rect(152, 44, 161, 70)
  local dorm = {}
  for _, dx in ipairs({ 74, 140 }) do
    local hump = c:ellipse(dx, 98, 15, 13):clip(rect(dx - 16, 84, dx + 16, 98))
    dorm[#dorm + 1] = { x = dx, m = hump }
  end
  local sil = union(ground, upper, roof, ch1, ch2)
  rimOf(sil, L.timber)
  -- chimneys: soft fen brick with a corbelled cap and a clay pot
  for _, ch in ipairs({ ch1, ch2 }) do part(ch, BRICK) F.courses(ch, 44, 3, 6, BRICK) end
  for _, cx in ipairs({ 51, 151 }) do
    local cy = (cx == 51) and 47 or 43
    fill(rect(cx, cy, cx + 11, cy + 2), BRICK.deep) hline(cx, cx + 11, cy, BRICK.hi)
    local pot = rect(cx + 4, cy - 4, cx + 7, cy - 1) c:rim(pot, BRICK.edge) fill(pot, BRICK.base) vline(cx + 4, cy - 4, cy - 1, BRICK.hi) vline(cx + 7, cy - 4, cy - 1, BRICK.shade)
  end
  -- roof: deep golden water-reed, combed courses, a dark sedge ridge with a scalloped lower edge and liggers
  part(roof, L.roof, { band = 3 })
  F.thatch(roof, L.roof, 64, 9999)
  roof:each(function(x, y)
    local d = y - 64
    local sc = 7 + ((x // 4) % 2) * 2
    if d < sc then
      local h = (d == sc - 1) and L.roof2.edge or ((x + y) % 4 == 0 and L.roof2.hi or (x < 107 and L.roof2.base or L.roof2.shade))
      if d == 2 and x % 7 == 0 then h = L.timber.hi end
      if d == 3 and x % 7 == 1 then h = L.timber.base end
      px(x, y, h)
    elseif d == sc and x % 4 == 1 then px(x, y, L.roof.deep) end
    -- hipped ends: the right slope turns away from the light, the left one catches it
    local lx = 36 - d * 22 / 43
    local rx = 178 + d * 22 / 43
    if d >= sc and x > rx - 12 and hash(x, y, 9) < .7 then px(x, y, (d % 4 == 3) and L.roof.edge or L.roof.deep) end
    if d >= sc and x < lx + 6 and d % 4 ~= 3 and hash(x, y, 10) < .5 then px(x, y, L.roof.hi) end
    -- older greyer patches of reed, and a weathered streak down the slope
    if d > sc and hash((x + d // 4 * 3) // 6, d // 4, 11) < .07 and d % 4 ~= 3 then px(x, y, mix(L.roof.base, L.roof2.base, .5)) end
  end)
  hline(36, 178, 64, L.roof2.hi)
  -- moss and a few young sedge sprouts in the old thatch on the shady lower slope
  for i, b in ipairs({ { 52, 100, 8 }, { 112, 98, 6 }, { 168, 96, 7 }, { 30, 104, 5 }, { 182, 102, 5 } }) do
    roof:each(function(x, y)
      local dd = ((x - b[1]) / b[3]) ^ 2 + ((y - b[2]) / (b[3] * .6)) ^ 2
      if dd < 1 and hash(x, y, 30 + i) < .8 then
        local h = (y - b[2]) < -b[3] * .2 and L.moss.hi or (dd > .6 and L.moss.shade or L.moss.base)
        if (y - 64) % 4 == 3 then h = L.moss.deep end
        px(x, y, h)
      end
    end)
  end
  -- a pied wagtail on the ridge
  F.sprite({ "..kk....", ".kWkk...", "kkkkkkkk", ".WWWkk..", "..t.t..." }, 116, 59, { k = L.timber.edge, W = L.awnB.hi, t = L.timber.deep })
  -- thick eave: the reed ends cut square, a deep shadow line
  hline(14, 200, UTOP + 1, L.roof.edge) hline(15, 199, UTOP, L.roof.deep)
  for x = 15, 199 do
    if x % 2 == 0 then px(x, UTOP - 1, L.roof.shade) end
    if x % 3 == 0 then px(x, UTOP + 2, L.roof.deep) end
    if x % 5 == 0 then px(x, UTOP + 3, L.roof.edge) end
  end
  -- eyebrow dormers: the thatch rolls up over low wide windows
  for _, d in ipairs(dorm) do
    rimOf(d.m, L.roof)
    part(d.m, L.roof, { nopop = true })
    d.m:each(function(x, y)
      local u = ((x - d.x) / 15) ^ 2 + ((y - 98) / 13) ^ 2
      local ring = floor((1 - u) * 6)
      if ring % 2 == 0 then px(x, y, (x < d.x) and L.roof.hi or L.roof.base) else px(x, y, (x < d.x) and L.roof.base or L.roof.shade) end
      if (x + y * 3) % 5 == 0 then px(x, y, L.roof.shade) end
      if u > .8 and x < d.x - 4 then px(x, y, L.roof.hi) end
    end)
    local win = rect(d.x - 8, 92, d.x + 8, 98)
    fill(win:grow(1), L.timber.edge)
    fill(win, L.glow.base)
    win:each(function(x, y)
      if (x - d.x) % 4 == 0 then px(x, y, L.timber.base) elseif y == 98 or (x - d.x) % 4 == 3 then px(x, y, L.glow.shade) end
      if y == 92 and (x - d.x) % 4 == 1 then px(x, y, L.glow.hi) end
    end)
    hline(d.x - 9, d.x + 9, 91, L.roof.deep) hline(d.x - 10, d.x + 10, 90, L.roof.edge)
    for x = d.x - 10, d.x + 10, 2 do px(x, 89, L.roof.deep) end
  end
  -- upper floor: silver weatherboard (lapped boards, lit top edge, a shadow under each lap), corner posts
  part(upper, L.board, { nopop = true })
  upper:each(function(x, y)
    local k = (y - UTOP) % 4
    local h = L.board.base
    if k == 0 then h = L.board.hi elseif k == 3 then h = L.board.shade end
    if k == 1 and hash(x // 7, (y - UTOP) // 4, 46) < .2 then h = L.board.hi end
    if k == 2 and hash(x // 3, (y - UTOP) // 4, 47) < .06 then h = L.board.deep end
    if y <= UTOP + 4 then h = (k == 3) and L.board.edge or L.board.deep end -- eave shadow
    if y >= GTOP - 6 and hash(x, y, 45) < .25 then h = L.board.shade end
    px(x, y, h)
  end)
  local posts = union(rect(UX0, UTOP, UX0 + 2, GTOP - 1), rect(UX1 - 2, UTOP, UX1, GTOP - 1), rect(106, UTOP, 107, GTOP - 1))
  part(posts, L.timber, { nopop = true, noshade = true })
  hline(UX0, UX1, GTOP - 3, L.timber.hi)
  -- jetty beam with joist ends and the shadow it throws on the ground floor
  local jet = rect(UX0 - 1, GTOP - 1, UX1 + 1, GTOP + 1)
  part(jet, L.timber, { nopop = true, noshade = true }) hline(UX0 - 1, UX1 + 1, GTOP - 1, L.timber.hi)
  for x = UX0 + 2, UX1 - 2, 6 do fill(rect(x, GTOP, x + 2, GTOP + 1), L.timber.edge) px(x, GTOP, L.timber.base) end
  -- upper windows: lit casements with teal shutters and a marigold box
  for _, wx in ipairs({ 40, 62, 90, 150, 174 }) do
    F.window(wx - 3, UTOP + 14, wx + 3, UTOP + 23, L.timber)
    for y = UTOP + 15, UTOP + 22, 2 do px(wx - 2, y, L.glow.shade) px(wx + 2, y + 1, L.glow.shade) end
    for _, sx in ipairs({ wx - 8, wx + 5 }) do
      local sh = rect(sx, UTOP + 13, sx + 3, UTOP + 24)
      c:rim(sh, L.accent.edge) part(sh, L.accent, { nopop = true })
      vline(sx + 2, UTOP + 14, UTOP + 23, L.accent.shade) hline(sx, sx + 3, UTOP + 18, L.accent.deep) hline(sx, sx + 3, UTOP + 13, L.accent.hi)
      px(sx + 1, UTOP + 21, L.accent.deep) -- a little fish cut-out
    end
    local bx = rect(wx - 5, UTOP + 27, wx + 5, UTOP + 29)
    rimOf(bx, L.timber) part(bx, L.timber, { nopop = true, noshade = true })
    for k = -4, 4 do
      px(wx + k, UTOP + 26, (k % 2 == 0) and L.reedGreen.base or L.reedGreen.shade)
      if k % 3 == 0 then px(wx + k, UTOP + 25, L.marigold.base) px(wx + k + 1, UTOP + 25, L.marigold.hi) end
    end
  end
  -- ground floor: warm clay daub in a silver timber frame, damp tide-mark low down, a tarred sill on the deck
  part(ground, L.plaster)
  ground:each(function(x, y)
    if y <= GTOP + 3 then px(x, y, L.plaster.shade) end
    if y == GTOP + 4 then px(x, y, L.plaster.deep) end
    if hash(x // 4, y, 41) < .03 then px(x, y, L.plaster.hi) end
    if hash(x // 2, y // 3, 48) < .025 then px(x, y, L.plaster.shade) end
    if y >= YB - 9 and hash(x, y // 2, 42) < .25 + (y - YB + 9) * .06 then px(x, y, mix(L.plaster.shade, L.moss.shade, .4)) end
  end)
  local frame = union(rect(X0, GTOP + 2, X0 + 1, YB), rect(X1 - 1, GTOP + 2, X1, YB), rect(84, GTOP + 2, 85, YB), rect(126, GTOP + 2, 127, YB))
  part(frame, L.board, { nopop = true, noshade = true })
  frame:each(function(x, y) if hash(x, y // 3, 49) < .2 then px(x, y, L.board.shade) end end)
  local sill = rect(X0, YB - 3, X1, YB)
  part(sill, L.timber, { nopop = true, noshade = true }) hline(X0, X1, YB - 3, L.timber.hi) hline(X0, X1, YB, L.timber.deep)
  -- porch: a little reed-thatched hood over the door, posts of peeled willow
  F.door(99, 154, 115, YB - 1, L.accent, true)
  local hood = poly{ { 90, 153 }, { 107, 142 }, { 124, 153 } }:add(rect(90, 151, 124, 154))
  rimOf(hood, L.roof) part(hood, L.roof, { nopop = true }) F.thatch(hood, L.roof, 142, 107)
  line({ { 90, 153 }, { 107, 142 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  hline(90, 124, 154, L.roof.deep) for x = 90, 124, 2 do px(x, 155, L.roof.edge) end
  for _, p0 in ipairs({ 93, 120 }) do local p = rect(p0, 156, p0 + 1, YB) part(p, L.willowBark, { nopop = true, noshade = true }) vline(p0, 156, YB, L.willowBark.hi) end
  -- an eel trap hung over the door like a horseshoe, and a bunch of dried reed plumes
  eelTrap(102, 150, 10)
  for k = 0, 3 do px(116 + k, 147 - k % 2, L.plume.base) px(116 + k, 146 - k % 2, L.plume.hi) vline(117 + k // 2, 148, 151, L.reed.shade) end
  -- bay windows: wide, many panes, warm glow, a window box of irises and marsh marigolds
  local function bay(x0, x1, y0, y1)
    local m = rect(x0, y0, x1, y1)
    fill(m:grow(1), L.timber.edge)
    fill(m, L.glow.base)
    m:each(function(x, y)
      if (x - x0) % 6 == 0 or (y - y0) % 5 == 0 then px(x, y, L.timber.base)
      elseif (x - x0) % 6 == 1 and (y - y0) % 5 == 1 then px(x, y, L.glow.hi)
      elseif (x - x0) % 6 == 5 or (y - y0) % 5 == 4 then px(x, y, L.glow.shade) end
    end)
    hline(x0 - 2, x1 + 2, y0 - 2, L.board.base) hline(x0 - 2, x1 + 2, y0 - 3, L.timber.edge) hline(x0 - 1, x1 + 1, y0 - 2, L.board.hi)
    local box = rect(x0 - 2, y1 + 2, x1 + 2, y1 + 5)
    rimOf(box, L.timber) part(box, L.board, { nopop = true }) F.planks(box, L.board, 4, true, 2)
    for x = x0 - 1, x1 + 1 do
      local h = hash(x, y1, 12)
      px(x, y1 + 1, L.reedGreen.shade)
      if h < .22 then px(x, y1, L.lav.base) px(x, y1 - 1, (h < .1) and L.lav.hi or L.reedGreen.base) px(x, y1 - 2, L.reedGreen.hi)
      elseif h < .45 then px(x, y1, L.marigold.base) px(x, y1 - 1, L.marigold.hi)
      elseif h < .8 then px(x, y1, L.reedGreen.base) if h < .6 then px(x, y1 - 1, L.reedGreen.hi) px(x, y1 - 2, L.reedGreen.base) end end
    end
  end
  bay(40, 76, 154, 167)
  bay(134, 170, 154, 167)
  -- drinkers' silhouettes inside the panes
  F.sprite({ "..ss..", ".ssss.", "ssssss", ".sss..", "sssss.", "sssss." }, 142, 159, { s = L.glow.deep }, { rim = false })
  F.sprite({ ".ss.", "ssss", ".ss.", "ssss" }, 60, 161, { s = L.glow.deep }, { rim = false })
  -- a lantern on a bracket by the door, its glow on the daub
  fill(rect(122, 146, 130, 146), L.iron.shade) vline(129, 147, 148, L.iron.shade)
  local lam = rect(127, 149, 131, 155) rimOf(lam, L.timber) fill(lam, L.glow.base) px(128, 150, L.glow.hi) vline(131, 150, 155, L.glow.shade)
  for _, p in ipairs({ { 125, 157 }, { 133, 157 }, { 125, 151 }, { 133, 152 }, { 129, 158 } }) do px(p[1], p[2], L.glow.deep) end
  -- hop bine climbing the right corner post
  for i = 0, 34 do
    local y = YB - 4 - i
    local x = X1 - 3 + floor(2 * sin(i * .5))
    px(x, y, L.leaf.shade)
    if i % 4 == 0 then px(x - 1, y, L.leaf.base) px(x + 1, y - 1, L.leaf.hi) end
    if i % 6 == 3 then px(x - 1, y, L.birchLeaf.hi) px(x - 1, y + 1, L.birchLeaf.base) end
  end
  F.smoke(57, 42, 7, .5, 2) F.smoke(156, 38, 8, .8, 3)
  -- a gnome leaning out of the upstairs window, beating a striped rush mat, dust flying
  F.gnome(98, 137, { small = true, hat = L.leaf, coat = L.awnA, arm = "out" })
  local rug = rect(104, 133, 116, 149)
  c:rim(rug, L.timber.edge) fill(rug, L.reed.base)
  rug:each(function(x, y)
    if (x + y) % 2 == 0 then px(x, y, L.reed.hi) end
    if ((y - 133) // 3) % 3 == 1 then px(x, y, (x % 2 == 0) and L.awnA.base or L.awnA.shade) end
    if x == 116 then px(x, y, L.reed.shade) end
  end)
  for x = 104, 116, 2 do px(x, 150, L.reed.shade) end
  for _, p in ipairs({ { 119, 138 }, { 121, 135 }, { 120, 142 }, { 123, 139 }, { 118, 146 }, { 122, 145 } }) do px(p[1], p[2], "#e2dcc4") px(p[1] + 1, p[2], "#cfc8ae") end
end

-- the deck the inn stands on: silver planks, front face, a rope rail along it
do
  local deck = rect(12, 181, 196, 185)
  F.boardwalk(deck, true, 31)
  hline(12, 196, 186, L.timber.deep) hline(12, 196, 181, L.board.hi)
end
inn()

-- peat turves stacked against the left gable under the eave, with a reed hat of their own
do
  local X0, X1, Y0, Y1 = 14, 29, 146, 180
  local back = rect(X0, Y0, X1, Y1)
  rimOf(back, L.peat) fill(back, L.peat.deep)
  for y = Y0 + 1, Y1, 4 do
    local row = (y - Y0) // 4
    for x = X0 + 1 - (row % 2) * 3, X1, 6 do
      local m = rect(math.max(X0 + 1, x), y, math.min(X1 - 1, x + 4), y + 2)
      fill(m, (hash(x, y, 6) < .3) and L.peat.shade or L.peat.base)
      hline(math.max(X0 + 1, x), math.min(X1 - 1, x + 4), y, L.peat.hi)
      if hash(x, y, 7) < .3 then px(math.max(X0 + 1, x) + 1, y + 1, L.cattail.deep) end
    end
  end
  local cap = poly{ { X0 - 2, Y0 + 1 }, { X1 + 2, Y0 + 1 }, { X1, Y0 - 5 }, { X0, Y0 - 5 } }
  rimOf(cap, L.roof2) part(cap, L.roof2, { nopop = true }) F.thatch(cap, L.roof2, Y0 - 5, 21)
  -- a turf spade leaning on it
  line({ { 33, 180 }, { 37, 160 } }):each(function(x, y) px(x, y, L.board.base) end)
  fill(rect(35, 157, 39, 159), L.board.base) px(35, 157, L.board.hi)
  fill(rect(31, 180, 34, 184), L.iron.base) px(31, 180, L.iron.hi)
end

---------------------------------------------------------------- the landing stage in front of the door, lanterns, steps, punts
F.depth(3)
do
  local stage = rect(72, 181, 144, 202)
  F.boardwalk(stage, false, 41)
  local face = rect(72, 203, 144, 205)
  rimOf(face, L.timber) part(face, L.timber, { nopop = true, noshade = true }) hline(72, 144, 203, L.timber.hi)
  F.stilts({ 74, 94, 122, 142 }, 206, 214, 210)
  -- steps down to the bank
  for k = 0, 2 do
    local st = rect(97 - k, 206 + k * 3, 119 + k, 207 + k * 3)
    rimOf(st, L.board) part(st, L.board, { nopop = true }) hline(97 - k, 119 + k, 206 + k * 3, L.board.hi)
  end
  lanternPost(73, 158, 182)
  lanternPost(142, 158, 182)
  -- a rope rail between them along the left edge, sagging
  for x = 75, 141 do end
  -- coiled mooring rope on the stage
  local coil = c:ellipse(136, 198, 4, 2)
  c:rim(coil, L.board.edge) fill(coil, L.board.base) hline(133, 139, 198, L.board.shade) px(134, 197, L.board.hi) px(136, 198, L.board.deep)
end
-- moored punts: one under the deck to the left (tied to a stilt, a lantern on its pole), one to the right carrying ale casks
do
  F.punt(12, 66, 210, L.timber)
  line({ { 24, 205 }, { 32, 196 } }):each(function(x, y) px(x, y, L.board.deep) end)
  fill(rect(40, 202, 48, 205), L.reed.base) hline(40, 48, 202, L.reed.hi) vline(44, 202, 205, L.timber.deep) -- a reed bundle aboard
  F.punt(148, 190, 212, L.timber)
  F.barrel(160, 209, L.timber, 8) F.barrel(172, 209, L.board, 8)
  line({ { 184, 207 }, { 179, 197 } }):each(function(x, y) px(x, y, L.board.deep) end)
end
-- lilies, reeds and bulrushes along the dyke
for _, p in ipairs({ { 66, 212, true, "white" }, { 146, 200, false }, { 128, 212, true }, { 84, 210, false, "yellow" }, { 20, 212, false } }) do F.lily(p[1], p[2], p[3], p[4]) end
F.reeds(4, 14, 214, 16, 24, { cattails = 2, green = true })
F.reeds(184, 194, 206, 12, 25, { cattails = 1 })
F.frog(128, 210, true)
F.dragonfly(56, 200, L.accent) F.dragonfly(160, 196, L.apple, true)
eelTrap(152, 194, 9) eelTrap(57, 198, 9, true)

-- the innkeeper in her apron with a mug, on the landing stage
F.depth(3)
local _, ihx, ihy = F.gnome(130, 197, { hat = L.awnA, coat = L.awnB, arm = "out" })
do local mug = rect(ihx, ihy - 5, ihx + 3, ihy) rimOf(mug, L.timber) part(mug, L.glow, { nopop = true }) hline(ihx, ihx + 3, ihy - 5, L.awnB.hi) px(ihx + 4, ihy - 3, L.glow.shade) end
-- a slate board on the stage: a chalk eel and a pie
do
  local leg = line({ { 82, 198 }, { 86, 180 } }, 1):add(line({ { 96, 198 }, { 92, 180 } }, 1))
  local bd = rect(80, 178, 98, 192)
  rimOf(union(bd, leg), L.timber) part(leg, L.timber, { nopop = true, noshade = true })
  fill(bd, L.iron.deep) c:edgeIn(bd, L.timber.base)
  for i = 0, 10 do px(83 + i, 183 + floor(1.5 * sin(i * .9)), L.awnB.base) end px(83, 182, L.awnB.base) px(94, 183, L.awnB.shade) -- eel
  for x = 86, 93 do px(x, 189, L.awnB.base) end for x = 87, 92 do px(x, 187, L.awnB.shade) end px(86, 188, L.awnB.base) px(93, 188, L.awnB.base)
end

---------------------------------------------------------------- the gallows sign post and its EEL PIE board
F.depth(3)
local SX0, SX1, SY0, SY1 = 202, 240, 128, 152
do
  local post = rect(194, 96, 197, 196)
  local arm = rect(194, 96, 246, 99)
  local brace = line({ { 198, 118 }, { 218, 100 } }, 2)
  local foot = rect(189, 192, 202, 198)
  F.shadowM(c:ellipse(204, 199, 12, 2))
  rimOf(union(post, arm, brace, foot), L.timber)
  part(post, L.timber, { nopop = true }) part(arm, L.timber, { nopop = true, noshade = true }) part(brace, L.timber, { nopop = true, noshade = true })
  post:each(function(x, y) if hash(x, y // 3, 37) < .15 then px(x, y, L.timber.shade) end if y > 186 and hash(x, y, 39) < .4 then px(x, y, L.moss.shade) end end)
  part(foot, L.stone, { nopop = true }) hline(189, 202, 192, L.stone.hi) F.moss(foot, .25, 38)
  hline(194, 246, 96, L.timber.hi)
  -- a bulrush-head finial
  local fin = rect(244, 89, 246, 95) c:rim(fin, L.timber.edge) fill(fin, L.cattail.base) vline(244, 89, 95, L.cattail.hi) px(245, 88, L.reedGreen.shade)
  -- chains
  for y = 100, SY0 - 1 do if y % 2 == 0 then px(SX0 + 3, y, L.iron.shade) px(SX1 - 3, y, L.iron.shade) else px(SX0 + 3, y, L.iron.hi) px(SX1 - 3, y, L.iron.hi) end end
  -- the board: teal frame, cream field, a golden pie with an eel poking out of the crust
  local board = rect(SX0, SY0, SX1, SY1)
  rimOf(board, L.accent) part(board, L.accent, { nopop = true })
  local field = rect(SX0 + 3, SY0 + 3, SX1 - 3, SY1 - 3)
  fill(field, L.plaster.hi) field:each(function(x, y) if hash(x, y, 6) < .06 then px(x, y, L.plaster.base) end end)
  hline(SX0, SX1, SY0, L.accent.hi) vline(SX0, SY0, SY1, L.accent.hi)
  -- reed sprigs painted in the corners
  F.sprite({ "p.p", "g.g", ".g." }, SX0 + 4, SY1 - 7, { g = L.reedGreen.shade, p = L.plume.shade }, { rim = false })
  F.sprite({ "p.p", "g.g", ".g." }, SX1 - 6, SY1 - 7, { g = L.reedGreen.shade, p = L.plume.shade }, { rim = false })
  -- the dish and the pie
  local dish = c:ellipse(221, 146, 12, 2)
  local crust = c:ellipse(221, 143, 10, 7):clip(rect(208, 134, 234, 145))
  c:rim(union(dish, crust), L.timber.edge)
  fill(dish, L.iron.base) hline(211, 231, 146, L.iron.hi) hline(212, 230, 147, L.iron.shade)
  part(crust, L.gold, { nopop = true })
  crust:each(function(x, y)
    if (x - 221) + (y - 140) * 1.3 < -7 then px(x, y, L.gold.hi) end
    if (x - 221) > 4 and y > 140 then px(x, y, L.gold.shade) end
    if y == 145 then px(x, y, (x % 2 == 0) and L.gold.shade or L.gold.deep) end -- crimped rim
  end)
  for _, s in ipairs({ { 214, 141 }, { 226, 140 }, { 219, 143 } }) do px(s[1], s[2], L.gold.deep) px(s[1] + 1, s[2] - 1, L.gold.deep) end -- slashes
  -- the eel: up through a hole in the crust, curling, with a beady eye
  local eel = line({ { 220, 138 }, { 218, 135 }, { 220, 133 }, { 224, 133 } }, 2):add(c:ellipse(227, 134, 3, 2))
  c:rim(eel, L.timber.edge) fill(eel, EEL.shade)
  eel:each(function(x, y) if not eel:has(x, y - 1) then px(x, y, EEL.hi) elseif not eel:has(x, y + 1) then px(x, y, EEL.deep) end end)
  px(228, 133, L.gold.hi) px(229, 133, L.timber.edge) hline(228, 230, 135, L.timber.edge) -- eye and grin
  fill(c:ellipse(220, 138, 2, 1), L.gold.deep)
  -- and its tail flicking out of the side of the pie
  local tl = line({ { 211, 141 }, { 208, 138 }, { 209, 134 } }, 1)
  c:rim(tl, L.timber.edge) fill(tl, EEL.shade) px(208, 137, EEL.hi) px(209, 134, EEL.hi)
  -- steam
  for _, p in ipairs({ { 216, 136 }, { 215, 134 }, { 216, 132 }, { 232, 137 }, { 233, 135 } }) do px(p[1], p[2], L.awnB.shade) end
end
-- QUIRK: an otter in a red gnome hat asleep on top of the board, tail hanging down over the pie, "z z" rising
do
  local by = SY0 - 1
  local O = L.soil
  local body = c:ellipse(224, by - 4, 15, 5):clip(rect(200, by - 12, 245, by))
  local head = c:ellipse(206, by - 5, 6, 5):clip(rect(198, by - 12, 214, by))
  local snout = c:ellipse(200, by - 3, 3, 2)
  local tail = line({ { 238, by - 2 }, { 241, by + 3 }, { 240, by + 9 }, { 237, by + 13 } }, 3):add(line({ { 237, by + 13 }, { 235, by + 16 } }, 1))
  local paws = rect(209, by + 1, 211, by + 3):add(rect(214, by + 1, 216, by + 2))
  local hat = poly{ { 200, by - 8 }, { 212, by - 8 }, { 209, by - 15 }, { 204, by - 21 }, { 198, by - 22 }, { 196, by - 19 }, { 201, by - 17 }, { 203, by - 12 } }
  local otter = union(body, head, snout, tail, paws)
  c:rim(union(otter, hat), L.timber.edge)
  part(union(body, tail), O, { nopop = true })
  body:each(function(x, y)
    if y <= by - 7 and hash(x, y, 3) < .5 then px(x, y, O.hi) end
    if y >= by - 1 then px(x, y, O.shade) end
    if (x + y) % 6 == 0 and y > by - 7 and y < by - 1 then px(x, y, O.shade) end -- wet fur clumps
  end)
  tail:each(function(x, y) if x >= 240 or y > by + 9 then px(x, y, O.shade) end end)
  part(head, O, { nopop = true })
  head:each(function(x, y) if y <= by - 8 then px(x, y, O.hi) end end)
  fill(snout, L.plaster.base) px(198, by - 4, L.plaster.hi) hline(199, 202, by - 2, L.plaster.shade)
  fill(c:ellipse(212, by - 2, 4, 1), L.plaster.base) -- pale chest
  part(paws, O, { nopop = true }) px(209, by + 3, O.deep) px(214, by + 2, O.deep)
  px(197, by - 4, L.timber.edge) px(198, by - 5, L.timber.edge) -- nose
  -- closed eye: a smiling arc; a round little ear
  px(203, by - 7, L.timber.edge) px(204, by - 6, L.timber.edge) px(205, by - 7, L.timber.edge)
  px(209, by - 9, O.shade) px(210, by - 9, O.deep)
  hline(193, 196, by - 3, L.awnB.shade) hline(193, 196, by - 1, L.awnB.shade) -- whiskers
  -- the red gnome hat, flopped over its brow
  part(hat, L.awnA, { nopop = true })
  hat:each(function(x, y) if x < 204 and y < by - 15 then px(x, y, L.awnA.hi) end if x > 207 then px(x, y, L.awnA.shade) end end)
  hline(200, 212, by - 8, L.awnA.deep) hline(201, 211, by - 9, L.awnA.shade)
  px(196, by - 20, L.awnB.hi) px(195, by - 19, L.awnB.base) -- bobble
  -- a little fish-bone it fell asleep over
  hline(228, 234, by - 10, L.awnB.base) for x = 229, 233, 2 do px(x, by - 11, L.awnB.shade) px(x, by - 9, L.awnB.shade) end px(235, by - 11, L.awnB.base) px(235, by - 9, L.awnB.base)
  local function zed(x, y, s, col)
    for i = 0, s do px(x + i, y, col) px(x + i, y + s, col) px(x + s - i, y + i, col) end
  end
  local function zz(x, y, s)
    for _, o in ipairs({ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 }, { 1, 1 }, { -1, -1 } }) do zed(x + o[1], y + o[2], s, L.timber.base) end
    zed(x, y, s, L.awnB.hi)
  end
  zz(211, by - 33, 3) zz(218, by - 41, 4) zz(227, by - 51, 5)
end

---------------------------------------------------------------- beer garden (right): festoons, table, drinkers
F.depth(3)
local function festoon(x0, y0, x1, y1, sag, step, startI)
  local function ly(x) local t = (x - x0) / (x1 - x0) return floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + .5) end
  for x = x0, x1 do px(x, ly(x), L.timber.deep) end
  local cols = { L.awnA, L.glow, L.accent, L.glow, L.marigold }
  local i = startI or 0
  for x = x0 + 8, x1 - 6, step do
    i = i + 1
    local y = ly(x) + 1
    local r = cols[i % #cols + 1]
    local m = c:rrect(x - 2, y + 1, x + 2, y + 6, 1)
    c:rim(m, L.timber.edge) fill(m, r.base) px(x - 1, y + 2, r.hi) vline(x + 2, y + 2, y + 5, r.shade) px(x, y, L.timber.deep)
    px(x, y + 7, r.deep)
  end
end
do
  local pole = rect(288, 116, 289, 196)
  rimOf(pole, L.timber) part(pole, L.timber, { nopop = true, noshade = true })
  F.sprite({ "p.p", ".g." }, 287, 113, { p = L.plume.base, g = L.reedGreen.base }) -- reed plumes tied to the pole top
  festoon(289, 117, 412, 128, 3, 12, 0)
  festoon(246, 100, 288, 117, 4, 11, 2)
end
-- barrel stack against the pole
F.barrel(300, 206, L.timber, 12) F.barrel(312, 207, L.board, 12) F.barrel(306, 194, L.timber, 11)
F.moss(rect(295, 202, 317, 207), .08, 39)
local function mugAt(x, y)
  local m = rect(x, y - 5, x + 3, y)
  c:rim(m, L.timber.edge) part(m, L.glow, { nopop = true }) hline(x, x + 3, y - 5, L.awnB.hi) hline(x - 1, x + 4, y - 6, L.awnB.base) px(x + 4, y - 3, L.glow.shade)
end
do
  local g1 = { 338, 210, L.roof2, L.leaf, "up" }
  local g2 = { 366, 209, L.lav, L.wall2, "up" }
  local g3 = { 394, 210, L.leaf, L.awnA, "out" }
  for i, g in ipairs({ g1, g2, g3 }) do
    local _, hx, hy = F.gnome(g[1], g[2], { hat = g[3], coat = g[4], arm = g[5], flip = (i == 3), noShadow = true })
    mugAt(hx - 1, hy)
  end
  for _, p in ipairs({ { 356, 186 }, { 352, 184 }, { 358, 182 } }) do px(p[1], p[2], L.awnB.hi) end
  -- the table: a silver plank top on trestles, a plank bench
  local top = rect(322, 209, 414, 213)
  local legs = rect(328, 214, 330, 228):add(rect(406, 214, 408, 228)):add(line({ { 329, 222 }, { 407, 222 } }))
  local bench = rect(318, 224, 418, 226):add(rect(322, 227, 323, 231)):add(rect(413, 227, 414, 231))
  F.shadow(324, 414, 231, 10, 3)
  rimOf(union(top, legs, bench), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true })
  part(bench, L.board, { nopop = true }) F.planks(bench, L.board, 7, false, 5)
  part(top, L.board) F.planks(top, L.board, 9, false, 7) hline(322, 414, 209, L.board.hi) hline(322, 414, 213, L.timber.base)
  mugAt(348, 208) mugAt(380, 208)
  -- a big eel pie, cut, on a pewter plate
  local plate = c:ellipse(362, 207, 7, 2) fill(plate, L.iron.base) hline(356, 368, 206, L.iron.hi)
  local pie = c:ellipse(362, 205, 5, 3):clip(rect(356, 200, 368, 207)):cut(poly{ { 362, 205 }, { 368, 202 }, { 368, 207 } })
  c:rim(pie, L.timber.edge) part(pie, L.gold, { nopop = true }) px(359, 203, L.gold.hi) px(360, 202, L.gold.hi)
  px(365, 205, EEL.base) px(366, 205, L.awnB.base) px(364, 206, EEL.shade)
  -- a bowl of whelks / cockles and a hunk of bread
  local bowl = c:ellipse(334, 207, 5, 2) fill(bowl, L.awnB.base) fill(c:ellipse(334, 205, 4, 1), L.plaster.shade) for k = 0, 3 do px(331 + k * 2, 204, L.awnB.hi) end
  local ch = poly{ { 389, 208 }, { 400, 208 }, { 400, 202 } } rimOf(ch, L.produce) part(ch, L.produce, { nopop = true }) px(397, 206, L.produce.shade) px(398, 204, L.produce.shade)
  -- a candle in a jar
  fill(rect(371, 204, 373, 208), L.awnB.hi) px(372, 203, L.glow.hi) px(372, 202, L.glow.base)
end
-- the waiter crossing the road with a tray of mugs
F.depth(3)
do
  local _, hx, hy = F.gnome(268, 232, { hat = L.accent, coat = L.awnA, arm = "up", flip = true })
  local tray = rect(hx - 9, hy - 1, hx + 5, hy)
  rimOf(tray, L.iron) part(tray, L.iron, { nopop = true, noshade = true })
  mugAt(hx - 8, hy - 2) mugAt(hx - 3, hy - 2) mugAt(hx + 2, hy - 2)
end

---------------------------------------------------------------- foreground left: mooring rail, eel hives, peat, barrel roller
F.depth(3)
do -- the mooring rail along the bank, a rope down to the punt
  local rail = rect(22, 222, 104, 224):add(rect(26, 222, 28, 236)):add(rect(98, 222, 100, 236)):add(rect(62, 222, 64, 236))
  rimOf(rail, L.timber) part(rail, L.timber, { nopop = true, noshade = true }) hline(22, 104, 222, L.timber.hi)
  rail:each(function(x, y) if y > 231 and hash(x, y, 70) < .5 then px(x, y, L.moss.shade) end end)
  line({ { 40, 224 }, { 34, 214 }, { 30, 208 } }):each(function(x, y) px(x, y, L.board.deep) end) -- rope to the punt
  -- wicker eel hives lying on the bank below the rail
  F.shadow(32, 92, 244, 6, 2)
  eelTrap(34, 238, 16) eelTrap(52, 240, 16) eelTrap(70, 238, 16) eelTrap(44, 233, 14)
end
do -- a stack of cut peat turves by the road, drying
  local stackM = rect(146, 218, 184, 232)
  F.shadow(146, 186, 233, 6, 3)
  rimOf(stackM, L.peat) fill(stackM, L.peat.deep)
  for row = 0, 2 do for k = 0, 6 do
    local tx, ty = 147 + k * 6 - (row % 2) * 3, 219 + row * 5
    if tx >= 147 and tx <= 180 then
      local m = rect(tx, ty, tx + 4, ty + 3)
      fill(m, (hash(k, row, 8) < .3) and L.peat.shade or L.peat.base)
      hline(tx, tx + 4, ty, L.peat.hi) px(tx + 4, ty + 3, L.peat.deep)
      if hash(k, row, 9) < .4 then px(tx + 1, ty + 1, L.cattail.deep) end
    end
  end end
  local lean = poly{ { 142, 218 }, { 188, 214 }, { 188, 217 }, { 142, 221 } }
  rimOf(lean, L.roof2) part(lean, L.roof2, { nopop = true }) F.thatch(lean, L.roof2, 214, 165)
end
-- a gnome rolling a barrel along toward the inn
do
  local _, hx, hy = F.gnome(176, 256, { hat = L.roof2, coat = L.accent, arm = "out", flip = true })
  local b = c:rrect(152, 244, 166, 258, 4)
  F.shadowM(c:ellipse(160, 259, 9, 1))
  rimOf(b, L.timber) part(b, L.timber)
  vline(155, 245, 257, L.iron.shade) vline(163, 245, 257, L.iron.shade) hline(153, 165, 250, L.timber.hi)
  for _, p in ipairs({ { 146, 254 }, { 144, 250 }, { 143, 257 } }) do px(p[1], p[2], L.ground.hi) end
end
-- crate of green bottles, sacks, a basket of eels, bottom left
do
  F.crate(40, 262, 26, 12)
  for k = 0, 5 do
    local bx = 43 + k * 4
    local b = rect(bx, 244, bx + 2, 250):add(rect(bx + 1, 241, bx + 1, 243))
    c:rim(b, L.timber.edge) fill(b, L.leaf.shade) px(bx, 245, L.leaf.hi) px(bx + 1, 241, L.produce.base)
  end
  F.sack(86, 262, L.awnB, 7)
  -- a round reed basket of eels
  local bk = c:ellipse(110, 258, 9, 5):clip(rect(100, 254, 120, 264))
  rimOf(bk, L.reed) part(bk, L.reed, { nopop = true })
  bk:each(function(x, y) if (x + (y % 2) * 2) % 4 == 0 then px(x, y, L.reed.shade) end end)
  local rimB = c:ellipse(110, 254, 9, 2)
  c:rim(rimB, L.reed.edge) fill(rimB, EEL.deep)
  for k = 0, 3 do local ex = 103 + k * 4 px(ex, 253 + k % 2, EEL.hi) px(ex + 1, 253 + (k + 1) % 2, EEL.base) px(ex + 2, 253 + k % 2, EEL.base) end
  line({ { 112, 253 }, { 116, 248 }, { 120, 247 } }, 1):each(function(x, y) px(x, y, EEL.base) end) px(121, 247, L.gold.hi)
  F.moss(F.rock(130, 266, 8, 6), .35, 43)
  F.reeds(4, 18, 252, 20, 26, { cattails = 2 })
  for _, f in ipairs({ { 24, 250 }, { 70, 268 }, { 134, 250 }, { 20, 266 } }) do F.sedge(f[1], f[2], 7) end
  for _, f in ipairs({ { 30, 256 }, { 126, 244 }, { 140, 262 } }) do F.sedge(f[1], f[2], 6) px(f[1] - 1, f[2] - 5, L.marigold.base) px(f[1] + 2, f[2] - 4, L.marigold.hi) end
end
-- a half-barrel tub of yellow flag irises and marsh marigolds by the road
do
  local tub = c:rrect(210, 226, 228, 240, 3)
  F.shadowM(c:ellipse(222, 241, 10, 1))
  rimOf(tub, L.timber) part(tub, L.timber) hline(210, 228, 230, L.iron.shade) hline(210, 228, 237, L.iron.shade)
  for k = 0, 8 do
    local x = 211 + k * 2
    local h = 6 + floor(hash(k, 1, 5) * 7)
    for t = 0, h do px(x + ((t > h - 3 and k % 2 == 0) and 1 or 0), 225 - t, (k < 4) and L.reedGreen.base or L.reedGreen.shade) end
    if k % 2 == 1 then px(x, 224 - h, L.marigold.base) px(x + 1, 225 - h, L.marigold.hi) px(x - 1, 225 - h, L.marigold.shade) end
  end
  for i = 0, 6 do local fx, fy = 212 + floor(hash(i, 1, 6) * 14), 222 + floor(hash(i, 2, 6) * 3) px(fx, fy, L.marigold.hi) px(fx + 1, fy, L.marigold.base) end
end

-- greylag geese gleaning crumbs dropped from the table
F.depth(3)
F.goose(318, 254, false) F.goose(344, 260, true) F.goose(364, 248, true)
for _, g in ipairs({ { 326, 254 }, { 332, 256 }, { 336, 251 }, { 350, 255 }, { 329, 250 } }) do px(g[1], g[2], L.gold.hi) end
-- a coil of rope and an eel trap leaning on the barrels
do
  local coil = c:ellipse(290, 216, 6, 3)
  c:rim(coil, L.board.edge) fill(coil, L.board.base) fill(c:ellipse(290, 216, 3, 1), L.board.deep) hline(285, 295, 214, L.board.hi)
  eelTrap(284, 208, 12, true)
end
-- sedge, reeds and marigolds round the garden (clear of the compass corner)
F.reeds(450, 470, 214, 20, 27, { cattails = 2, green = true })
for _, f in ipairs({ { 304, 262 }, { 290, 250 }, { 374, 262 }, { 432, 222 }, { 284, 236 } }) do F.sedge(f[1], f[2], 6) end
for _, f in ipairs({ { 300, 240 }, { 376, 244 } }) do px(f[1], f[2], L.marigold.base) px(f[1] + 1, f[2], L.marigold.hi) px(f[1], f[2] + 1, L.reedGreen.base) end
-- a goose at the mooring rail, tugging the rope
F.depth(3)
F.goose(116, 236, false)
for x = 104, 110 do px(x, 225 + (x - 104), L.board.deep) end
-- the dog asleep under the table between the legs
F.sprite({
  "....bb..........",
  "...bBBb.....bb..",
  "..bBkBBBBBBBBBb.",
  "dbBBBBBBBBBBBBBb",
  ".dddBBbbBBBBbbBt",
  "...ddd..ddddd.tt",
}, 364, 217, { b = L.soil.base, B = L.soil.hi, d = L.soil.shade, k = L.timber.edge, t = L.soil.shade })

F.depth(0)
F.birds({ { 330, 52, 2 }, { 342, 46, 1 }, { 120, 52, 2 }, { 380, 78, 2 } })
-- a skein of geese far off
F.birds({ { 280, 40, 1 }, { 286, 43, 1 }, { 292, 46, 1 }, { 274, 43, 1 } })
F.finish()
