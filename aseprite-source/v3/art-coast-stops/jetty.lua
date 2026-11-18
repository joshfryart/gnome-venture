-- jetty.lua : "Harbour jetty" stop look, COAST (coast_driftwood), 480x270 gate view.
-- Same composition as the Maplewold jetty (art-2701-batch3/stops/opus3/jetty.lua), re-cast for a working harbour on
-- a chalk-and-dune coast: right half: the harbour basin behind a granite harbour wall (a beacon on its round head,
-- spray thrown over the parapet, a lugger moored alongside with her sail furled), a red-and-white lighthouse on the
-- far headland; a bleached plank jetty on tarred, barnacled piles with a moored blue dory, a lamp post with a gull on
-- it and a gnome in a yellow oilskin fishing off the end; a tarred fish-shed on piles; a lugger under tan sails coming
-- in through the harbour mouth; a grey seal, a cormorant drying its wings on a mooring post, buoys.
-- Left: a tall tarred net loft, a rack of split herring drying, nets drying on poles with cork floats, an upturned
-- boat being tarred, lobster pots, a cat eyeing the fish box. Quirk (kept): a grey heron helping itself to the fish
-- bucket.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-coast-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "jetty", out = DIR, farTrees = { 24, 52, 120, 196 },
  duneLineGap = { 220, 490 }, -- the right half is harbour water
  boats = { { 176, 96, 7 }, { 214, 99, 9 }, { 330, 96, 6 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local mix, rp = F.mix, F.rp
local S = L.sea

local fishR = rp("#dceef0 #9cc4cc #5e8ea2 #3a6276 #22404e") -- mackerel / herring silver-blue
local function lum(h)
  local r, g, b = tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16)
  return (r * .3 + g * .59 + b * .11) / 255
end

---------------------------------------------------------------- the harbour basin (+ the harbour mouth up to the sea)
local WL = 117 -- foot of the harbour wall
local lake = poly{ { 252, 101 }, { 479, 101 }, { 479, 228 }, { 372, 228 }, { 350, 220 }, { 326, 202 }, { 304, 176 }, { 288, 150 }, { 276, 130 }, { 263, 113 } }
-- shingle beach along the diagonal shore: pebbles, a wet band at the water, a wrack line higher up
local beach = lake:grow(9):cut(lake):clip(rect(0, 101, 479, 269))
local wetB = lake:grow(3):cut(lake)
beach:each(function(x, y)
  local v = hash(x, y, 5)
  local h = v < .3 and L.shingle.base or (v < .55 and L.shingle.shade or (v < .8 and L.shingle.hi or L.sand.base))
  if hash(x // 2, y // 2, 6) < .12 then h = L.stone.shade end
  if wetB:has(x, y) then h = v < .5 and L.wetSand.base or (v < .8 and L.wetSand.shade or L.shingle.shade) end
  px(x, y, h)
end)
for k = 0, 40 do
  local t = k / 40
  local wx, wy = floor(268 + t * 104), floor(116 + t * 108)
  wx = wx - floor(t * t * 18) - 7
  if beach:has(wx, wy) and not wetB:has(wx, wy) and hash(k, 1, 7) < .6 then F.wrack(wx - 2, wy, 3, k) end
end
local T1 = mix(S.hi, L.sky[4], .35)
local T2 = mix(S.hi, S.base, .45)
local T3 = mix(S.base, L.glass.base, .18)
local T4 = mix(T3, S.shade, .5)
local T5 = mix(S.shade, S.deep, .3)
local shallowC = mix(S.hi, L.shingle.base, .45)
local shallow2 = mix(T3, L.sand.shade, .35)
lake:shrink(1):each(function(x, y)
  local d = y - WL
  local h
  if y <= 106 then -- the harbour mouth: open sea running in
    h = hash(x // 4, y, 11) < .5 and "#86c0c8" or S.base
  elseif d < 3 then h = T1
  elseif d < 14 then h = hash(x // 7, y, 14) < .55 and T1 or T2
  elseif d < 30 then h = hash(x // 7, y, 14) < .5 and T2 or T3
  elseif d < 58 then h = T3
  elseif d < 85 then h = hash(x // 6, y // 2, 15) < .55 and T3 or T4
  else h = hash(x // 6, y // 2, 16) < .3 and T4 or T5 end
  if not lake:has(x - 7, y) or not lake:has(x, y + 7) or not lake:has(x + 5, y + 5) then h = shallow2 end
  if not lake:has(x - 4, y) or not lake:has(x, y + 4) or not lake:has(x + 3, y + 3) then h = shallowC end
  px(x, y, h)
end)
-- a lacy foam lip where the swell runs up the shingle
lake:edge():each(function(x, y) if y > 101 and hash(x, y, 9) < .75 then px(x, y, L.foam) end end)
-- swell coming in through the mouth: whitecap dashes
for y = 102, 116 do
  for x = 254, 300 do
    if lake:has(x, y) and hash((x + y * 5) // 4, y, 12) < .08 then px(x, y, L.foam) if lake:has(x, y + 1) then px(x, y + 1, S.shade) end end
  end
end

---------------------------------------------------------------- the far headland: lighthouse and keeper's cottage
F.depth(1)
do
  local lhx = 454
  local lhy = floor(F.fFar(lhx)) + 1
  -- keeper's cottage
  local ck = rect(436, lhy - 5, 446, lhy)
  local ckr = poly{ { 435, lhy - 5 }, { 447, lhy - 5 }, { 444, lhy - 9 }, { 438, lhy - 9 } }
  rimOf(union(ck, ckr), L.tar)
  fill(ck, L.plaster.hi) vline(446, lhy - 5, lhy, L.plaster.shade) fill(ckr, L.roof2.base) hline(437, 445, lhy - 8, L.roof2.hi)
  px(439, lhy - 3, L.wall2.base) px(443, lhy - 3, L.wall2.base)
  -- tower: tapered, red and white bands, gallery, lantern, dome
  local tw = poly{ { lhx - 4, lhy }, { lhx + 3, lhy }, { lhx + 2, lhy - 22 }, { lhx - 3, lhy - 22 } }
  local gal = rect(lhx - 5, lhy - 24, lhx + 4, lhy - 23)
  local lan = rect(lhx - 3, lhy - 29, lhx + 2, lhy - 25)
  local dome = poly{ { lhx - 4, lhy - 30 }, { lhx + 3, lhy - 30 }, { lhx, lhy - 33 }, { lhx - 1, lhy - 33 } }
  rimOf(union(tw, gal, lan, dome), L.tar)
  tw:each(function(x, y)
    local band = ((lhy - y) // 5) % 2 == 1
    local h = band and L.awnA.base or L.chalk.hi
    if x >= lhx + 1 then h = band and L.awnA.shade or L.chalk.shade elseif x <= lhx - 3 then h = band and L.awnA.hi or "#f8f6ee" end
    px(x, y, h)
  end)
  fill(gal, L.tar.base) hline(lhx - 5, lhx + 4, lhy - 24, L.tar.hi)
  fill(lan, L.glow.base) vline(lhx - 2, lhy - 29, lhy - 25, L.glow.hi) vline(lhx + 2, lhy - 29, lhy - 25, L.glow.shade) vline(lhx, lhy - 29, lhy - 25, L.tar.base)
  fill(dome, L.tar.base) px(lhx - 2, lhy - 31, L.tar.hi) px(lhx, lhy - 34, L.tar.deep)
  -- a faint beam of light swept out to sea
  for k = 1, 9 do if k % 2 == 1 then px(lhx - 4 - k, lhy - 27 + k // 4, L.glow.hi) end end
  px(lhx - 5, lhy - 31, L.tar.edge)
end
F.depth(0)

---------------------------------------------------------------- the granite harbour wall, its round head and beacon
F.depth(2)
local hwall = rect(301, 102, 479, WL)
local head = c:ellipse(300, 110, 7, 8):clip(rect(290, 102, 310, WL))
local wallAll = union(hwall, head)
rimOf(wallAll, L.stone)
part(wallAll, L.stone, { nopop = true })
wallAll:each(function(x, y)
  local h
  if y <= 103 then h = (y == 102) and L.stone.hi or L.stone.base                        -- parapet cap
  elseif y == 104 then h = L.stone.shade                                                  -- the parapet's shadow line
  elseif y <= 107 then local v = hash(x // 5, y, 31) h = v < .3 and L.road.hi or (v < .8 and L.road.base or L.road.shade) -- walkway slabs
    if (x % 9 == 0) then h = L.road.deep end
  else
    -- the face: courses, lit left on each block, darker low down, weed and barnacles at the tide line
    local row = (y - 108) // 3
    local bx = (x + (row % 2) * 4) // 8
    local ry = (y - 108) % 3
    h = (ry == 0) and L.stone.deep or ((x + (row % 2) * 4) % 8 == 0 and L.stone.deep or (hash(bx, row, 32) < .3 and L.stone.base or L.stone.shade))
    if ry == 1 and (x + (row % 2) * 4) % 8 == 1 then h = L.stone.hi end
    if y >= WL - 3 then local v = hash(x // 2, y, 33) h = v < .45 and L.kelp.shade or (v < .7 and L.kelp.deep or L.stone.deep) end
  end
  px(x, y, h)
end)
F.lichen(wallAll:copy():clip(rect(290, 108, 479, WL - 4)), .07, 34)
F.barnacles(wallAll, .12, 35, WL - 5)
-- the round head: the walkway curves round, the face rounds into shade
head:each(function(x, y) if x < 296 and y > 107 and hash(x, y, 36) < .4 then px(x, y, L.stone.base) end end)
-- iron mooring rings, a ladder down the face, bollards on the walkway
for _, rx in ipairs({ 322, 372 }) do px(rx, 111, L.iron.shade) px(rx - 1, 112, L.iron.shade) px(rx + 1, 112, L.iron.deep) px(rx, 113, L.iron.deep) end
for y = 108, WL - 1, 2 do hline(340, 343, y, L.iron.shade) end vline(339, 106, WL, L.iron.deep) vline(344, 106, WL, L.iron.deep)
for _, bx in ipairs({ 314, 334, 360, 452 }) do fill(rect(bx, 104, bx + 1, 106), L.tar.base) px(bx, 104, L.tar.hi) end
-- beacon on the head: an iron post with a red lantern
do
  local post = rect(299, 89, 300, 104)
  local lamp = rect(297, 84, 302, 89)
  local cap = rect(296, 82, 303, 83)
  rimOf(union(post, lamp, cap), L.tar)
  part(post, L.iron, { nopop = true, noshade = true })
  fill(lamp, L.awnA.base) vline(297, 84, 89, L.awnA.hi) vline(302, 84, 89, L.awnA.deep) hline(297, 302, 87, L.tar.base)
  fill(cap, L.tar.base) px(299, 81, L.tar.base) px(300, 81, L.tar.deep)
  px(298, 85, L.produce.hi)
end
-- spray thrown over the parapet by the swell outside
local function spray(x0, w, hh, seed)
  for k = 0, w * hh do
    local dx = floor(hash(k, 1, seed) * w)
    local t = 1 - math.abs(dx - w / 2) / (w / 2)
    local dy = floor(hash(k, 2, seed) * hh * (0.3 + t))
    if dy > 0 then px(x0 + dx, 102 - dy, hash(k, 3, seed) < .6 and L.foam or L.cloud.mid) end
  end
  for dx = 0, w do if hash(dx, 4, seed) < .7 then px(x0 + dx, 101, L.foam) end end
end
spray(310, 14, 9, 41) spray(352, 8, 5, 42) spray(448, 12, 8, 43)
F.depth(0)

-- the wall's reflection in the basin: mirrored, sunk into the water colour, broken by ripple rows
for x = 290, 479 do
  for k = 1, 16 do
    local sy, dy = WL - k + 1, WL + k
    if lake:has(x, dy) and wallAll:has(x, sy) then
      local v = c:get(x, sy)
      if v and not (dy % 3 == 0 and hash(x // 4, dy, 84) < .55) then
        local h = mix(v, T4, .45 + k * .015)
        if (x + dy) % 2 == 0 and k > 11 then h = mix(h, T2, .4) end
        px(x, dy, h)
      end
    end
  end
end
-- lit ripple pairs, longer and wider apart nearer
for y = 134, 226 do
  local d = y - 112
  local gap = 2 + d // 18
  if y % gap == 0 then
    local len = 2 + d // 9
    local x0 = 268 + floor(hash(y, 1, 13) * 30)
    while x0 < 478 do
      if hash(x0 // 9, y, 16) < .45 then
        for xx = x0, x0 + len do if lake:has(xx, y) and lake:has(xx, y + 1) and not beach:has(xx, y) then
          px(xx, y, y < 150 and T1 or S.hi) if d > 30 then px(xx, y + 1, T5) end end end
      end
      x0 = x0 + len + 6 + floor(hash(x0, y, 17) * 18)
    end
  end
end
-- cat's-paws of wind: a few small whitecaps inside the basin
for k = 0, 16 do local gx, gy = 280 + floor(hash(k, 1, 19) * 190), 134 + floor(hash(k, 2, 19) * 80)
  if lake:has(gx, gy) and lake:has(gx + 3, gy) then hline(gx, gx + 1 + k % 3, gy, L.foam) px(gx + 1, gy + 1, T4) end end
-- sun glints
for k = 0, 30 do local gx, gy = 276 + floor(hash(k, 1, 18) * 200), 122 + floor(hash(k, 2, 18) * 96) if lake:has(gx, gy) then px(gx, gy, "#f8f2dc") px(gx + 1, gy, S.hi) end end
-- floating wrack and mooring buoys
for _, p in ipairs({ { 312, 170 }, { 330, 194 }, { 296, 158 } }) do F.wrack(p[1], p[2], 4, p[1]) end
local function buoy(x, y, r)
  local m = c:ellipse(x, y, 2, 2)
  rimOf(m, r) part(m, r, { nopop = true }) px(x - 1, y - 1, r.hi)
  hline(x - 3, x + 3, y + 3, S.hi) hline(x - 2, x + 2, y + 4, mix(r.base, T3, .6))
  vline(x, y - 4, y - 3, L.tar.base)
end
buoy(316, 136, L.produce) buoy(372, 152, L.awnA) buoy(470, 160, L.produce)

---------------------------------------------------------------- the grey seal (bobbing head) and a cormorant on a post
do
  local sx, sy = 322, 150
  F.sprite({
    "..gggg...",
    ".gGGGGg..",
    "gGeGGeGg.",
    "gGGGGGGgg",
    "gGGnnGGGg",
    ".gGwwGGg.",
    "..ggggg..",
  }, sx, sy, { g = L.iron.shade, G = L.iron.base, e = L.tar.edge, n = L.tar.deep, w = L.iron.hi }, { rimCol = L.tar.deep })
  px(sx + 2, sy + 1, L.iron.hi) px(sx + 3, sy + 1, L.iron.hi) -- wet shine on the crown
  px(sx - 1, sy + 4, L.iron.hi) px(sx + 10, sy + 5, L.iron.hi) -- whiskers
  c:ellipse(sx + 4, sy + 7, 8, 1):edge():each(function(x, y) px(x, y, S.hi) end)
  c:ellipse(sx + 4, sy + 8, 12, 2):edge():each(function(x, y) if (x // 2) % 2 == 0 and lake:has(x, y) then px(x, y, T1) end end)
end
do -- cormorant drying its wings on a tarred mooring post
  local px0, py0 = 372, 128
  local post = rect(px0 + 4, py0 + 10, px0 + 6, py0 + 24)
  rimOf(post, L.tar) part(post, L.tar, { nopop = true }) vline(px0 + 4, py0 + 10, py0 + 24, L.tar.hi)
  F.barnacles(post, .25, 37, py0 + 19)
  for y = py0 + 25, py0 + 30, 2 do hline(px0 + 3, px0 + 7, y, T5) end
  F.sprite({
    "......kk.....",
    "......kkyo...",
    "KK....kk.....",
    "KKK..kkk...KK",
    ".KKK.kkk..KK.",
    "..KKKkKkKKK..",
    "...KKkkkKK...",
    "......kk.....",
    "......kk.....",
    ".....y..y....",
  }, px0, py0, { K = L.tar.base, k = L.tar.shade, y = L.gold.base, o = L.gold.hi }, { rimCol = L.tar.edge })
  px(px0 + 6, py0, L.tar.hi) px(px0 + 1, py0 + 3, L.tar.hi) px(px0 + 2, py0 + 4, L.tar.hi) px(px0 + 7, py0 + 1, L.awnB.hi)
end

---------------------------------------------------------------- a lugger moored alongside the wall, sail furled
local function mooredLugger(x, yb, len)
  local h = 5
  local x0, x1 = x - len // 2, x + len // 2
  local hull = poly{ { x0 - 2, yb - h - 1 }, { x1 + 3, yb - h - 2 }, { x1 - 2, yb }, { x0 + 3, yb } }
  local mast = rect(x - 3, yb - 34, x - 2, yb - h)
  local mast2 = rect(x0 + 3, yb - 18, x0 + 3, yb - h)
  local furl = line({ { x - 9, yb - 21 }, { x + 7, yb - 25 } }, 2)
  local m = union(hull, mast, mast2, furl)
  rimOf(m, L.tar)
  part(hull, L.tar, { nopop = true })
  hull:each(function(xx, yy) if yy <= yb - h then px(xx, yy, L.wall2.base) end if yy == yb - h - 1 or yy == yb - h - 2 then px(xx, yy, L.wall2.hi) end end)
  hline(x0 + 2, x1 - 2, yb - 2, L.tar.shade)
  part(mast, L.timber, { nopop = true, noshade = true }) vline(x - 3, yb - 34, yb - h, L.timber.hi)
  part(mast2, L.timber, { nopop = true, noshade = true })
  part(furl, L.roof2, { nopop = true }) furl:each(function(xx, yy) if (xx % 3) == 0 then px(xx, yy, L.roof2.deep) end end)
  -- rigging: forestay and backstay, a little pennant
  line({ { x - 2, yb - 33 }, { x1 + 2, yb - h - 2 } }):each(function(xx, yy) if not m:has(xx, yy) then px(xx, yy, L.tar.shade) end end)
  line({ { x - 3, yb - 33 }, { x0 - 1, yb - h - 1 } }):each(function(xx, yy) if not m:has(xx, yy) then px(xx, yy, L.tar.shade) end end)
  hline(x - 1, x + 2, yb - 34, L.awnA.base) px(x - 1, yb - 33, L.awnA.shade)
  -- registration number on the bow (pale dashes) and her reflection
  hline(x1 - 7, x1 - 6, yb - 3, L.awnB.hi) hline(x1 - 4, x1 - 3, yb - 3, L.awnB.hi)
  for k = 0, 2 do hline(x0 + 3 + k, x1 - 3 - k, yb + 1 + k * 2, T5) end
  for yy = yb + 2, yb + 12, 2 do px(x - 3, yy, T4) end
  return m
end
F.depth(2)
mooredLugger(352, 124, 30)
F.depth(0)

---------------------------------------------------------------- the tarred fish-shed on piles
F.depth(2)
local function fishShed()
  local top, _, wallM, roofM = F.building{ x0 = 388, x1 = 444, yb = 140, wh = 26, rh = 20, wall = L.tar, roof = L.roof2,
    noShadow = true, noFrame = true, noAttic = true, shingle = true }
  F.planks(wallM, L.tar, 4, true, 51)
  F.pantile(roofM, L.roof2, top - 20, 52)
  F.lichen(roofM, .05, 53)
  F.window(424, 120, 430, 125, L.wall2)
  -- big water door, the dark water inside, a dory stowed
  local d = rect(396, 124, 416, 140) fill(d, L.tar.edge) fill(rect(398, 134, 414, 140), S.deep)
  hline(399, 413, 136, S.edge) hline(398, 414, 124, L.wall2.hi) vline(396, 124, 140, L.wall2.base) vline(416, 124, 140, L.wall2.shade)
  hline(400, 412, 132, L.wall2.base) hline(401, 411, 133, L.wall2.shade) px(400, 131, L.wall2.hi)
  -- a lifebuoy on the wall
  local lb = c:ellipse(434, 132, 4, 4):cut(c:ellipse(434, 132, 1, 1))
  rimOf(lb, L.tar)
  lb:each(function(x, y) local q = ((x < 434) and 0 or 1) + ((y < 132) and 0 or 1) px(x, y, (q % 2 == 0) and L.awnA.base or L.awnB.hi) end)
  px(431, 129, L.awnA.hi) px(437, 135, L.awnA.shade)
  -- a hoist beam over the door with a fish basket on the hook
  local hb = rect(404, 108, 420, 109) rimOf(hb, L.tar) fill(hb, L.timber.base) hline(404, 420, 108, L.timber.hi)
  vline(418, 110, 116, L.cork.deep)
  -- stovepipe
  local pipe = rect(434, top - 14, 436, top - 2) rimOf(pipe, L.iron) part(pipe, L.iron, { nopop = true })
  local piles = HP.mask()
  for x2 = 390, 442, 8 do piles:add(rect(x2, 141, x2 + 1, 150)) end
  rimOf(piles, L.tar) part(piles, L.tar, { nopop = true, noshade = true })
  piles:each(function(x2, y2) if y2 > 145 then px(x2, y2, hash(x2, y2, 86) < .5 and L.kelp.shade or L.awnB.shade) end end)
  for x2 = 390, 442, 8 do for y2 = 152, 160, 2 do px(x2, y2, T5) end end
  for y2 = 152, 158, 2 do hline(392, 440, y2, (y2 % 4 == 0) and T4 or T3) end
  F.smoke(436, top - 18, 5, 1.1, 2)
end
fishShed()
F.depth(0)

---------------------------------------------------------------- a lugger under tan sails coming in through the mouth
F.depth(2)
F.boat(292, 136, 22, { hull = L.tar, band = L.awnB })
for k = 0, 2 do hline(282 + k * 2, 302 - k * 2, 138 + k * 2, T5) end
for k = 0, 3 do hline(278 - k * 3, 282 - k * 2, 136 + k, L.foam) end -- bow wave / wake
F.depth(0)

---------------------------------------------------------------- the jetty, moored dory, lamp post, fisher gnome
local function dory(x0, x1, y)
  local hull = poly{ { x0 - 4, y - 3 }, { x0, y }, { x1, y }, { x1 + 4, y - 3 }, { x1 - 5, y + 8 }, { x0 + 6, y + 8 } }
  local inside = c:ellipse((x0 + x1) / 2, y - 2, (x1 - x0) / 2 - 1, 2)
  rimOf(union(hull, inside), L.tar)
  part(hull, L.wall2) hline(x0 + 1, x1 - 1, y + 1, L.awnB.hi) hline(x0 + 2, x1 - 2, y + 2, L.awnB.base)
  hull:each(function(x2, y2) if y2 > y + 5 then px(x2, y2, hash(x2, y2, 89) < .3 and L.kelp.shade or L.roof2.shade) end end) -- red bottom, weedy
  F.barnacles(hull, .08, 88, y + 6)
  fill(inside, L.timber.shade) c:edgeIn(inside, L.board.base)
  vline(x0 + 16, y - 4, y, L.board.hi) vline(x1 - 16, y - 4, y, L.board.hi)
  fill(line({ { x0 + 8, y - 2 }, { x1 + 6, y + 6 } }), L.board.shade) fill(rect(x1 + 4, y + 5, x1 + 8, y + 7), L.board.base)
  for k = 0, 3 do hline(x0 + 6 + k, x1 - 6 - k, y + 9 + k * 2, T5) end
  for k = 0, 2 do hline(x0 + 10 + k * 2, x1 - 18 - k * 2, y + 10 + k * 2, mix(L.wall2.base, T4, .55)) end
end
F.depth(3)
local deck = rect(300, 178, 470, 185)
local face = rect(300, 186, 470, 188)
local piles = HP.mask()
for x2 = 312, 466, 18 do piles:add(rect(x2, 189, x2 + 2, 206)) end
for x2 = 312, 466, 18 do for y2 = 208, 220, 3 do if lake:has(x2, y2) and lake:has(x2 + 1, y2 + 1) then px(x2, y2, S.deep) px(x2 + 1, y2 + 1, T5) end end end
rimOf(union(deck, face, piles), L.tar)
part(piles, L.tar, { nopop = true, noshade = true })
piles:each(function(x2, y2)
  if (x2 % 18) == 312 % 18 and y2 < 200 then px(x2, y2, L.tar.hi) end
  if y2 > 196 and hash(x2, y2, 90) < .6 then px(x2, y2, y2 > 201 and L.kelp.shade or L.kelp.base) end
end)
F.barnacles(piles, .22, 91, 197)
for x2 = 312, 466, 18 do hline(x2, x2 + 2, 204, L.foam) end
part(deck, L.board)
F.planks(deck, L.board, 5, true, 21)
F.lichen(deck, .012, 92)
hline(300, 470, 178, L.board.hi)
for x2 = 300, 470 do if (x2 // 3) % 2 == 0 then px(x2, 189, T5) end end
part(face, L.timber, { nopop = true })
for x2 = 302, 470, 10 do px(x2, 187, L.iron.hi) end
dory(368, 422, 212)
fill(line({ { 366, 210 }, { 360, 189 } }), L.cork.deep) -- painter (mooring rope)
-- lamp post at the end of the jetty, a herring gull standing on its arm
local lp = rect(460, 140, 461, 177) rimOf(lp, L.tar) part(lp, L.timber, { nopop = true, noshade = true })
local arm = rect(452, 140, 461, 141) fill(arm, L.tar.base)
local lam = rect(450, 143, 455, 150) rimOf(lam, L.tar) fill(lam, L.glow.base) px(451, 144, L.glow.hi) vline(455, 144, 150, L.glow.shade)
hline(450, 455, 142, L.tar.deep) px(452, 151, L.tar.deep)
F.sprite({
  "..WW....",
  ".WeWW...",
  "YYWWW...",
  "..WWWGG.",
  "..WWGGGK",
  "...WWGKK",
  "....p.p.",
}, 452, 133, { W = L.gull.hi, G = L.gull.shade, K = L.tar.deep, Y = L.gold.base, e = L.tar.edge, p = L.petal.shade }, { rimCol = L.gull.edge })
-- fisher gnome in a yellow oilskin on a fish box, rod out over the water, a float bobbing on the line
F.crate(424, 177, 12, 6)
local _, fhx, fhy = F.gnome(430, 171, { hat = L.awnA, coat = L.gorse, arm = "out", noShadow = true })
fill(line({ { fhx, fhy }, { 448, 152 }, { 452, 146 } }), L.timber.deep)
vline(452, 147, 176, L.awnB.shade) vline(452, 189, 213, L.awnB.shade) fill(rect(451, 213, 453, 215), L.awnA.base) px(451, 213, L.awnA.hi) px(452, 215, L.awnB.hi)
for k = 0, 2 do hline(448 - k * 2, 456 + k * 2, 217 + k * 2, S.hi) end
-- on the deck: a herring barrel, a fish box of mackerel, a stack of lobster pots, a bollard with a rope coil
F.barrel(316, 177, L.timber, 9)
F.crate(328, 177, 12, 7, fishR)
F.lobsterPot(352, 177, 6) F.lobsterPot(366, 177, 6) F.lobsterPot(359, 170, 5)
local bol = rect(388, 171, 393, 177) local bolT = c:ellipse(390, 171, 3, 1)
rimOf(union(bol, bolT), L.tar) part(bol, L.tar, { nopop = true }) fill(bolT, L.tar.hi)
local rc = c:ellipse(400, 176, 4, 1) rimOf(rc, L.cork) fill(rc, L.cork.base) px(400, 176, L.cork.deep) px(397, 175, L.cork.hi)
local tb = rect(406, 172, 414, 177) rimOf(tb, L.tar) part(tb, L.accent, { nopop = true }) hline(406, 414, 174, L.accent.deep) px(410, 173, L.gold.hi)

---------------------------------------------------------------- shore wedge: heron at the fish bucket (quirk), rope, anchor
F.eraseGround(rect(300, 236, 324, 251)) -- keep the bucket's silhouette clear
local bucket = poly{ { 304, 252 }, { 318, 252 }, { 316, 264 }, { 306, 264 } }
rimOf(bucket, L.tar) part(bucket, L.board) hline(304, 318, 255, L.iron.shade) hline(305, 317, 261, L.iron.shade)
for k = 0, 3 do local fx = 306 + k * 3 fill(rect(fx, 248 - (k % 2), fx + 1, 252), fishR.base) px(fx, 248 - (k % 2), fishR.deep) px(fx + 1, 249, fishR.deep) px(fx, 250, fishR.hi) px(fx + 1, 251, fishR.shade) end
F.shadowM(c:ellipse(294, 263, 10, 1))
F.sprite({
  ".............kkkk...............",
  "...........kkwwwwk..............",
  "..............wwwwwyyyy.........",
  "..............wwwewyyyyyyy......",
  "...............wwwwYYYYYYYYYff..",
  "...............wwww........fFff.",
  "...............wwww.........ff..",
  "..............wwww..............",
  ".............wwww...............",
  "............wwwkw...............",
  "............wwww................",
  "...........wwwkw................",
  "...........wwww.................",
  "...........wwww.................",
  ".....GGGGGgwwww.................",
  "...GGGGgggggwww.................",
  "..GGggggggggggw.................",
  ".Gggggggdddgggg.................",
  ".gggggdddddggggg................",
  "kgggddddddddgggg................",
  "kkggdddDDddddggd................",
  ".kkgdddDDDdddddd................",
  "..kkddDDDDDdddd.................",
  "...kkdDDDDDddd..................",
  ".....DDDDDDdd...................",
  "........l..l....................",
  "........l..l....................",
  "........l..l....................",
  "........l..l....................",
  "........l..l....................",
  "........l..l....................",
  ".......ll.ll....................",
  "......l.l.l.l...................",
}, 284, 230, { k = L.tar.deep, w = L.gull.hi, e = L.tar.edge, y = L.gold.hi, Y = L.gold.shade, f = fishR.base, F = fishR.deep,
  G = L.stone.hi, g = L.stone.base, d = L.stone.shade, D = L.stone.deep, l = L.gold.deep })
-- coiled rope + anchor, barnacled boulders, marram, thrift, shells and a crab on the shingle
local coil = c:ellipse(354, 248, 9, 4) rimOf(coil, L.cork) part(coil, L.cork) fill(c:ellipse(354, 248, 4, 1), L.cork.deep)
for k = 0, 2 do c:ellipse(354, 248, 8 - k * 2, 3 - k // 2):edge():each(function(x2, y2) if y2 > 247 then px(x2, y2, L.cork.shade) end end) end
local anc = rect(336, 230, 337, 244):add(line({ { 330, 240 }, { 336, 245 }, { 343, 240 } }, 2)):add(rect(333, 232, 340, 233))
rimOf(anc, L.iron) part(anc, L.iron, { nopop = true }) fill(c:ellipse(336, 228, 2, 2):cut(c:ellipse(336, 228, 1, 1)), L.iron.base)
anc:each(function(x2, y2) if y2 > 241 and hash(x2, y2, 93) < .4 then px(x2, y2, L.roof2.shade) end end) -- rust
F.barnacles(F.rock(368, 262, 9, 8), .16, 94, 0)
F.lichen(F.rock(326, 268, 6, 5), .2, 95)
for _, f in ipairs({ { 372, 250, 8 }, { 346, 264, 6 }, { 276, 248, 7 }, { 362, 236, 5 } }) do F.marram(f[1], f[2], f[3]) end
F.thrift(292, 214, true) F.thrift(286, 218, false) F.thrift(376, 264, false)
F.shell(326, 236, true) F.shell(331, 239, false) F.shell(298, 222, true)
F.sprite({ "c.......c", "Cc.e.e.cC", ".CCCCCCC.", "C.c.c.c.C" }, 316, 222, { C = L.roof2.base, c = L.roof2.shade, e = L.tar.edge }, { rimCol = L.roof2.edge })
F.sprite({ "..o..", "ooOoo", ".oOo.", "o...o" }, 342, 220, { o = L.produce.base, O = L.produce.hi }, { rimCol = L.produce.edge }) -- a starfish

---------------------------------------------------------------- left: the tall tarred net loft, a herring rack
F.depth(1)
F.tree(84, 128, 38, 2)
F.tree(10, 134, 40, 1)
local ctop, _, cwall, croof = F.building{ x0 = 22, x1 = 66, yb = 136, wh = 36, rh = 20, wall = L.tar, roof = L.roof, shingle = true, noFrame = true, noAttic = true }
F.planks(cwall, L.tar, 4, true, 96)
F.lichen(croof, .07, 97)
-- the loft door high up with a hoist beam, a ground door in sea blue, a little window
local ld = rect(38, ctop + 3, 48, ctop + 12) fill(ld, L.tar.edge) hline(38, 48, ctop + 3, L.wall2.hi) vline(38, ctop + 3, ctop + 12, L.wall2.base) vline(48, ctop + 3, ctop + 12, L.wall2.shade)
hline(39, 47, ctop + 8, L.accent.shade) for xx = 39, 47, 2 do px(xx, ctop + 9, L.accent.base) px(xx + 1, ctop + 10, L.accent.shade) end -- nets inside
fill(rect(42, ctop - 2, 44, ctop - 1), L.timber.base) vline(43, ctop, ctop + 2, L.cork.deep)
F.door(46, 122, 54, 135, L.wall2)
F.window(26, 120, 31, 125, L.wall2)
-- a fish-shaped sign on the loft
local fs = c:ellipse(33, 130, 5, 2):add(poly{ { 37, 130 }, { 41, 127 }, { 41, 133 } })
rimOf(fs, L.wall2) part(fs, L.wall2) px(30, 129, L.tar.edge)
local function fishRack(x0, x1, yb)
  local posts = rect(x0, yb - 22, x0 + 1, yb):add(rect(x1, yb - 22, x1 + 1, yb))
  local bar = rect(x0 - 2, yb - 22, x1 + 3, yb - 21)
  F.shadow(x0, x1, yb, 6, 3)
  rimOf(union(posts, bar), L.tar) part(posts, L.timber, { nopop = true, noshade = true }) part(bar, L.timber, { nopop = true, noshade = true })
  for x2 = x0 + 4, x1 - 2, 5 do
    vline(x2, yb - 20, yb - 19, L.tar.edge)
    local fsh = poly{ { x2 - 1, yb - 18 }, { x2 + 2, yb - 18 }, { x2 + 2, yb - 9 }, { x2, yb - 7 }, { x2 - 1, yb - 9 } }
    local tl = poly{ { x2 - 2, yb - 7 }, { x2 + 3, yb - 7 }, { x2, yb - 9 } }
    local kipper = (x2 // 5) % 2 == 0
    fill(union(fsh, tl), kipper and L.cork.base or fishR.base) vline(x2 + 2, yb - 18, yb - 10, kipper and L.cork.deep or fishR.deep) px(x2, yb - 16, L.tar.edge)
    if not kipper then vline(x2 - 1, yb - 17, yb - 11, fishR.hi) else vline(x2, yb - 14, yb - 11, L.produce.base) end
  end
end
fishRack(96, 150, 140)
-- fish boxes and lobster pots stacked against the loft, a bollard with an old anchor chain
F.depth(2)
F.crate(70, 146, 12, 6, fishR) F.crate(72, 139, 10, 6)
F.lobsterPot(88, 146, 5)
F.depth(1)
for _, f in ipairs({ { 18, 140, 4 }, { 74, 150, 4 }, { 94, 144, 3 } }) do F.marram(f[1], f[2], f[3]) end
F.thrift(62, 141, false)
F.depth(3)

---------------------------------------------------------------- left hero: nets drying on poles with cork floats
local function netFrame(x0, x1, yt, yb)
  local posts = rect(x0, yt, x0 + 3, yb):add(rect(x1 - 3, yt, x1, yb)):add(rect((x0 + x1) // 2 - 1, yt, (x0 + x1) // 2 + 1, yb))
  local bar = rect(x0 - 3, yt, x1 + 3, yt + 3)
  F.shadow(x0, x1, yb, 14, 5)
  rimOf(union(posts, bar), L.tar)
  part(posts, L.timber, { nopop = true }) part(bar, L.timber, { nopop = true })
  F.lichen(posts:copy():clip(rect(x0, yb - 16, x1, yb)), .2, 98)
  F.lichen(bar, .1, 99)
  local function sag(x2) local t = ((x2 - x0) % ((x1 - x0) // 2)) / ((x1 - x0) // 2) return floor(yb - 14 - 10 * sin(t * pi)) end
  for x2 = x0 + 4, x1 - 4 do
    local y1 = sag(x2)
    local left = x2 < (x0 + x1) // 2
    for y2 = yt + 4, y1 do
      local a, b = (x2 + y2) % 5, (x2 - y2) % 5
      if a == 0 or b == 0 then px(x2, y2, left and L.accent.shade or L.tar.base) elseif hash(x2, y2, 2) < .08 then px(x2, y2, left and L.accent.base or L.tar.hi) end
    end
    px(x2, y1, L.cork.deep)
    if x2 % 7 == 0 then fill(rect(x2 - 1, y1 + 1, x2 + 1, y1 + 3), (x2 % 14 == 0) and L.awnA.base or L.cork.base) px(x2 - 1, y1 + 1, (x2 % 14 == 0) and L.awnA.hi or L.cork.hi) px(x2 + 1, y1 + 3, (x2 % 14 == 0) and L.awnA.deep or L.cork.deep) end
  end
  -- a hank of wrack and a crab snagged in the net
  px(120, 170, L.kelp.base) px(121, 171, L.kelp.shade) px(120, 172, L.kelp.deep) px(160, 176, L.roof2.base) px(161, 176, L.roof2.shade) px(159, 177, L.roof2.deep) px(162, 177, L.roof2.deep)
  -- a glass float in a rope cage hung on the middle post
  local gx, gy = (x0 + x1) // 2 + 6, yt + 12
  local gm = c:ellipse(gx, gy, 3, 3) rimOf(gm, L.glass) part(gm, L.glass, { nopop = true })
  px(gx - 1, gy - 1, L.glass.hi) vline(gx, gy - 3, gy + 3, L.cork.deep) hline(gx - 3, gx + 3, gy, L.cork.deep) vline(gx, yt + 4, gy - 4, L.cork.deep)
end
netFrame(92, 192, 150, 214)
F.barrel(110, 222, L.timber, 11) F.barrel(124, 224, L.board, 9)
px(108, 210, fishR.hi) px(110, 210, fishR.base) px(112, 210, fishR.hi) -- herring heaped in the barrel
-- a fish box of mackerel
local bk = poly{ { 160, 214 }, { 182, 214 }, { 180, 224 }, { 162, 224 } }
rimOf(bk, L.timber) part(bk, L.board) bk:each(function(x2, y2) if (x2 - 160) % 7 == 0 then px(x2, y2, L.board.deep) end end)
for k = 0, 4 do local fx = 162 + k * 4 fill(c:ellipse(fx, 212, 2, 1), fishR.base) px(fx - 1, 212, fishR.hi) px(fx + 2, 212, fishR.deep) px(fx, 211, fishR.deep) end
-- oars leaning
fill(line({ { 194, 228 }, { 186, 176 } }, 2), L.board.base) fill(c:rrect(184, 168, 189, 182, 2), L.wall2.base) vline(184, 169, 181, L.wall2.hi)
-- a tabby cat sitting by the box, eyeing the fish
F.sprite({
  "o...o..",
  "oo.oo..",
  "ttttt..",
  "tetet..",
  "ttntt..",
  ".ttt...",
  ".tTtt..",
  "tTttt..",
  "tTTttt.",
  "tTttttt",
  "tttttt.",
  "wt.tw..",
}, 148, 212, { o = L.tar.edge, t = L.produce.shade, T = L.produce.deep, e = L.leaf.hi, n = L.apple.shade, w = L.awnB.hi })

---------------------------------------------------------------- bottom-left: hawthorn, upturned boat on trestles, tar pot, lobster pots
F.tree(44, 206, 54, 0)
F.barrel(64, 210, L.timber, 10) F.barrel(76, 212, L.timber, 10) F.barrel(70, 201, L.board, 9)
local function upBoat()
  local pts = { { 24, 242 } }
  for x2 = 24, 136, 4 do pts[#pts + 1] = { x2, 242 - floor(16 * sin((x2 - 20) / 120 * pi) ^ .6) - (x2 > 120 and (x2 - 120) // 2 or 0) } end
  pts[#pts + 1] = { 138, 230 } pts[#pts + 1] = { 132, 242 }
  local hull = poly(pts)
  local tre = rect(36, 242, 38, 256):add(rect(110, 240, 112, 256)):add(rect(30, 252, 44, 253)):add(rect(104, 252, 118, 253))
  F.shadow(26, 136, 258, 6, 3)
  rimOf(union(hull, tre), L.tar)
  part(tre, L.timber, { nopop = true, noshade = true })
  part(hull, L.accent)
  hull:each(function(x2, y2)
    local k = 242 - floor(16 * sin((x2 - 20) / 120 * pi) ^ .6)
    if (y2 - k) % 5 == 4 then px(x2, y2, L.accent.deep) end
    if x2 < 64 and y2 > k + 4 then px(x2, y2, (y2 - k) % 5 == 4 and L.tar.edge or L.tar.deep) end -- fresh tar
    if x2 > 100 and y2 > k + 2 and hash(x2 // 2, y2, 99) < .12 then px(x2, y2, L.accent.hi) end -- worn paint
  end)
  hline(24, 132, 241, L.awnA.base) hline(24, 132, 242, L.awnA.deep) -- red gunwale stripe
  local pot = rect(56, 250, 64, 258) rimOf(pot, L.iron) part(pot, L.iron) hline(56, 64, 250, L.tar.edge)
  fill(line({ { 62, 250 }, { 68, 244 } }), L.board.base)
  px(58, 259, L.glow.base) px(60, 259, L.glow.shade) px(62, 259, L.glow.base) px(59, 260, L.glow.hi) px(61, 260, L.produce.base)
  local _, thx, thy = F.gnome(82, 266, { hat = L.wall2, coat = L.roof2, arm = "out", flip = true })
  fill(line({ { thx, thy }, { thx - 6, thy - 3 } }), L.board.base) fill(rect(thx - 9, thy - 6, thx - 6, thy - 3), L.tar.edge) -- tar brush
end
upBoat()
px(59, 247, L.cloud.shade) px(61, 245, L.cloud.mid) px(60, 243, L.cloud.shade) -- steam off the tar
F.lobsterPot(160, 262, 7) F.lobsterPot(176, 262, 7) F.lobsterPot(168, 252, 6)
for _, f in ipairs({ { 14, 222, 7 }, { 146, 246, 6 }, { 190, 256, 8 }, { 200, 238, 6 }, { 140, 266, 7 } }) do F.marram(f[1], f[2], f[3]) end
F.thrift(196, 264, true) F.thrift(204, 266, false) F.shell(150, 256, true) F.shell(154, 258, false)
F.driftwood(2, 228, 20, 232, 2)
-- barnacled rocks and wrack along the waterline, rock pools in the corner by the jetty foot
local function wetRock(x, yb, w, h, seed)
  local m = F.rock(x, yb, w, h, L.stone)
  F.barnacles(m, .18, seed, yb - h // 2)
  m:each(function(xx, yy) if yy >= yb - 1 and hash(xx, yy, seed + 1) < .6 then px(xx, yy, L.kelp.shade) end end)
  return m
end
wetRock(296, 172, 5, 4, 101) wetRock(308, 190, 6, 5, 103) wetRock(332, 214, 5, 4, 105) wetRock(352, 226, 7, 5, 107) wetRock(280, 140, 4, 3, 109)
for k = 0, 5 do F.wrack(268 + k * 6, 128 + k * 9, 4, k) end
-- signpost with a hanging fish board by the road
F.sign(206, 148, 18, 10, L.board)
F.lichen(F.rock(222, 196, 6, 5), .3, 110)
F.marram(206, 176, 6) F.marram(214, 210, 7)
F.depth(0)
F.gull(360, 60, 3) F.gull(376, 52, 2) F.gull(300, 72, 2) F.gull(160, 30, 2) F.gull(232, 46, 1) F.gull(410, 84, 1)
-- a gull diving for fish over the basin
F.sprite({ "K.....K", ".W...W.", "..WWW..", "...W...", "...Y..." }, 338, 160, { K = L.gull.edge, W = L.gull.hi, Y = L.gold.base }, { rimCol = L.gull.deep })
fill(c:ellipse(205, 153, 5, 2):add(poly{ { 209, 153 }, { 212, 150 }, { 212, 156 } }), fishR.base) px(202, 152, L.tar.edge) px(203, 152, fishR.hi)
F.finish()
