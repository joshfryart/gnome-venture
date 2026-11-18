-- tower.lua : "Watchtower" stop look, COAST (coast_driftwood), 480x270 gate view.
-- Same composition and story as the Maplewold watchtower (art-2701-batch3/stops/opus3/tower.lua), re-cast for a
-- chalk-and-dune coast: road's end: a red-and-white striped lighthouse on a granite plinth, standing on a chalk knoll
-- with surf breaking on the rocks at its feet; a railed gallery, a lamp-lit lantern with diamond astragals and a dark
-- dome, a soft lamp beam over the sea, a flagstaff with a hoist of signal flags, the keeper waving from the gallery.
-- A dry-stone flint wall runs off along the horizon. Left: the keeper's whitewashed cottage (slate roof, blue door,
-- a lifebuoy over it), washing on the line, a rack of oars and boathooks with lifebuoys, a drill dummy in oilskins
-- and a sou'wester, painted rope-ring targets with an archer. Right: the tarred boathouse with a pantile roof and a
-- net on its wall, lobster pots and an anchor, the fog bell frame with a gnome on the rope, a brass telescope on a
-- driftwood tripod, driftwood bundles, fish boxes and paraffin cans, the keeper's mate with a boathook and his dog.
-- Quirk: a carrier pigeon with a tiny scroll landing on the pigeon loft.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-coast-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "tower", out = DIR, farTrees = { 24, 52, 100, 380, 440 },
  duneLineGap = { 170, 310 }, clouds = { { 104, 40, 38 }, { 330, 34, 46 }, { 412, 70, 30 }, { 30, 82, 26 } },
  boats = { { 184, 95, 6 }, { 322, 95, 6 }, { 342, 100, 9 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local S, IR, G, T = L.stone, L.iron, L.glow, L.timber

-- a red-and-white lifebuoy ring (quartered), lit upper left
local function buoy(x, y, r, rin)
  rin = rin or floor(r * .5)
  local ring = c:ellipse(x, y, r, r):cut(c:ellipse(x, y, rin, rin))
  rimOf(ring, L.awnA)
  ring:each(function(xx, yy)
    local a = math.atan(yy - y, xx - x)
    local q = floor((a + pi + pi / 4) / (pi / 2)) % 2
    local rr = q == 0 and L.awnA or L.awnB
    local lt = (xx - x) + (yy - y)
    px(xx, yy, lt < -r * .6 and rr.hi or (lt > r * .6 and rr.shade or rr.base))
  end)
  return ring
end

---------------------------------------------------------------- the soft lamp beam over the sea (painted first, sky only)
F.depth(0)
do
  local cx, cy = 248, 28
  for x = cx + 4, 360 do
    local d = x - cx
    local up, dn = cy - d * .10, cy + d * .22
    local k = .34 * (1 - d / 116)
    for y = floor(up), floor(dn) do
      if y >= 13 and y < F.SEA_Y then
        local core = y >= cy - d * .03 and y <= cy + d * .1
        local kk = core and k or k * .5
        if kk > .03 and (core or (x + y) % 2 == 0 or kk > .08) then
          local v = c:get(x, y)
          if v then px(x, y, F.mix(v, "#fff2c4", floor(kk * 20 + .5) / 20)) end
        end
      end
    end
  end
end

---------------------------------------------------------------- dry-stone flint wall along the horizon
local function stoneWall(x0, x1, yb, h, seed)
  local m = rect(x0, yb - h, x1, yb)
  local cop = HP.mask()
  for x = x0, x1, 2 do local hh = 2 + floor(hash(x, 1, seed) * 2) cop:add(rect(x, yb - h - hh, x, yb - h - 1)) end
  F.shadow(x0, x1, yb, 4, 2)
  rimOf(union(m, cop), S)
  m:each(function(x, y)
    local row = (y - (yb - h)) // 3
    local bw = 4 + (row % 2) * 2
    local off = floor(hash(row, 1, seed) * 6) + row * 3
    local v = hash((x + off) // bw, row, seed)
    local hc = v < .22 and S.hi or (v < .58 and S.base or (v < .82 and S.shade or L.chalk.base))
    if v > .95 then hc = L.tar.base end -- a black flint
    if (y - (yb - h)) % 3 == 0 or (x + off) % bw == 0 then hc = S.deep end
    if y == yb - h + 1 and hc ~= S.deep then hc = S.hi end
    px(x, y, hc)
  end)
  cop:each(function(x, y) px(x, y, (x % 4 == 0) and S.hi or (y == yb - h - 1 and S.deep or S.shade)) end)
  F.lichen(m, .05, seed + 1)
  for i = 0, (x1 - x0) // 10 do F.marram(x0 + 3 + i * 10 + floor(hash(i, 2, seed) * 5), yb + 1, 2 + floor(hash(i, 3, seed) * 3)) end
  for i = 0, (x1 - x0) // 30 do F.thrift(x0 + 12 + i * 30, yb + 1, false) end
end
F.depth(1)
stoneWall(114, 186, 126, 9, 31)
stoneWall(294, 372, 126, 9, 37)

---------------------------------------------------------------- rocks and surf at the knoll's feet
F.depth(1)
local function surfRock(x, yb, w, h, seed)
  local m = F.rock(x, yb, w, h, S)
  m:each(function(xx, yy) if yy >= yb - 1 then px(xx, yy, hash(xx, yy, seed) < .5 and L.kelp.shade or L.kelp.deep) end end)
  F.barnacles(m, .12, seed, yb - 2)
  F.lichen(m, .05, seed + 3)
  -- foam collar and thrown spray (spray on the windward / sea side)
  for xx = x - w - 2, x + w + 2 do if hash(xx, 1, seed) < .8 then px(xx, yb + 1, L.foam) end end
  for i = 0, 8 do
    local sx = x - w + floor(hash(i, 1, seed + 5) * (2 * w))
    local sy = yb - h - 1 - floor(hash(i, 2, seed + 5) * 4)
    px(sx, sy, hash(i, 3, seed + 5) < .6 and L.foam or L.sea.hi)
  end
  return m
end
surfRock(178, 104, 6, 5, 61) surfRock(192, 103, 4, 4, 62) surfRock(166, 105, 3, 2, 63)
surfRock(292, 104, 5, 4, 64) surfRock(304, 105, 4, 3, 65) surfRock(314, 104, 2, 2, 66)

---------------------------------------------------------------- the chalk knoll under the lighthouse
F.depth(2)
do
  local knoll = poly{ { 182, 131 }, { 190, 121 }, { 198, 112 }, { 207, 106 }, { 216, 102 }, { 264, 102 }, { 273, 106 }, { 283, 112 }, { 292, 121 }, { 300, 131 } }
  rimOf(knoll, L.chalk)
  -- per column: a turf cap, then a chalk face with gullies and flint bands (same recipe as the headlands)
  local kt = {}
  for x = 182, 300 do
    local y = 100
    while not knoll:has(x, y) and y < 132 do y = y + 1 end
    kt[x] = y
    if y < 132 then
      local lit = x < 240
      local cr = lit and { hi = L.chalk.hi, base = L.chalk.base, shade = L.chalk.shade, deep = L.chalk.deep }
        or { hi = L.chalk.base, base = L.chalk.shade, shade = L.chalk.deep, deep = L.chalk.edge }
      -- the turf cap is thicker on the gentle upper slope
      local turf = 3 + floor(math.max(0, 12 - math.abs(x - 240) * .25)) + floor(hash(x // 3, 2, 70) * 3)
      F.cliffFace(x, y + turf - 2, 131, cr, lit and { L.leaf.hi, L.leaf.base } or { L.leaf.base, L.leaf.shade }, 70)
      for yy = y, y + turf - 2 do
        local v = hash(x, yy, 69)
        local h = lit and (v < .25 and L.leaf.hi or (v < .8 and L.mossGround.base or L.leaf.shade)) or (v < .2 and L.leaf.base or (v < .8 and L.mossGround.shade or L.leaf.deep))
        if yy == y then h = lit and L.leaf.hi or L.leaf.base end
        px(x, yy, h)
      end
    end
  end
  knoll:each(function(x, y) if y > 126 and hash(x, y // 2, 74) < .45 then px(x, y, L.sand.shade) end end) -- blown sand at the foot
  for i = 1, 14 do
    local x = 186 + floor(hash(i, 1, 75) * 110)
    if x < 214 or x > 266 then
      local y = 112 + floor(hash(i, 2, 75) * 16)
      while knoll:has(x, y - 1) do y = y - 1 end
      if knoll:has(x, y) then F.marram(x, y + 1, 3 + floor(hash(i, 3, 75) * 3)) end
    end
  end
  F.thrift(204, 108, true) F.thrift(278, 110, false) F.thrift(290, 120, true)
end

---------------------------------------------------------------- the lighthouse
local function lighthouse()
  F.depth(2)
  local yb, yt = 104, 48
  local function half(y) return 19 - (yb - y) * 5 / (yb - yt) end
  local body = poly{ { 221, yb }, { 259, yb }, { 255, yt }, { 225, yt } }
  local plinth = poly{ { 214, 128 }, { 266, 128 }, { 263, 104 }, { 217, 104 } }
  local pcap = rect(215, 101, 265, 104)
  local corb = rect(222, 46, 258, 48)
  local deck = rect(217, 43, 263, 45)
  local drum = rect(228, 35, 252, 42)
  local glass = rect(231, 23, 249, 34)
  local dome = c:ellipse(240, 23, 11, 8):clip(rect(229, 13, 251, 22))
  local ball = c:ellipse(240, 14, 2, 2)
  F.shadow(214, 266, 129, 12, 4)
  rimOf(union(body, plinth, pcap, corb, deck, drum, glass, dome, ball), L.tar)

  -- the tower: red and white bands (arched: we look up at it), cylinder shading lit from the left
  body:each(function(x, y)
    local hw = half(y)
    local t = (x - 240 + .5) / hw
    local yy = y + floor(2 * (1 - t * t) + .5)
    local band = ((yy - yt) // 10) % 2
    local r = band == 0 and L.awnA or L.plaster
    local h
    if t < -.62 then h = r.hi elseif t < .2 then h = r.base elseif t < .7 then h = r.shade else h = r.deep end
    if t > .2 and t < .7 and (x + y) % 2 == 0 and t < .32 then h = r.base end -- dithered terminator
    if (yy - yt) % 10 == 0 then h = (t < .2) and r.shade or r.deep end -- band seam
    if t > -.7 and t < .2 and hash(x // 2, y // 7, 76) < .05 then h = r.shade end -- weathering streaks
    if t < -.85 then h = r.base end -- reflected light on the far left edge stays soft
    px(x, y, h)
  end)
  -- rust weeps from the gallery brackets and salt streaks
  for _, sx in ipairs({ 230, 238, 247, 252 }) do
    local len = 4 + floor(hash(sx, 1, 77) * 8)
    for y = 49, 49 + len do if body:has(sx, y) and hash(sx, y, 78) < .8 then px(sx, y, y < 52 and L.produce.shade or L.awnA.shade) end end
  end
  -- windows: two small arched lights and a slit
  F.window(238, 60, 242, 65, L.wall2, true)
  F.window(238, 84, 242, 89, L.wall2, true)
  fill(rect(246, 72, 247, 77), L.tar.edge) px(246, 72, L.tar.deep)
  fill(rect(232, 74, 233, 78), L.tar.edge)
  -- corbel band under the gallery, dentils
  part(corb, L.plaster, { nopop = true })
  for x = 223, 257, 3 do px(x, 48, L.plaster.deep) px(x, 47, L.plaster.shade) end
  hline(222, 258, 46, L.plaster.hi)

  -- granite plinth with a capstone, lichen and a blue door
  part(plinth, S)
  plinth:each(function(x, y)
    local row = (y - 104) // 6
    local blk = (x + (row % 2) * 6) // 12
    local v = hash(blk, row, 79)
    if v < .25 then px(x, y, S.hi) elseif v > .82 then px(x, y, S.shade) end
    if x > 255 and (x + y) % 2 == 0 then px(x, y, S.shade) end
  end)
  F.courses(plinth, 104, 6, 12, S)
  F.lichen(plinth, .025, 80)
  plinth:each(function(x, y) if y > 124 and hash(x // 2, y, 81) < .45 then px(x, y, L.sand.shade) end end)
  part(pcap, S, { sep = true }) hline(215, 265, 101, S.hi) F.lichen(pcap, .05, 82)
  F.door(233, 112, 247, 127, L.wall2, true)
  for k = 0, 1 do hline(231 - k * 2, 249 + k * 2, 126 + k, S.hi) end
  -- a lifebuoy on a peg beside the door, a brass bell-plate on the right
  buoy(224, 114, 5, 2)
  px(224, 108, L.tar.edge)
  fill(rect(252, 114, 255, 117), L.gold.base) px(252, 114, L.gold.hi) px(255, 117, L.gold.shade)

  -- watch-room drum, gallery deck, lantern glazing, dome
  part(drum, L.awnA)
  drum:each(function(x, y) if x > 247 then px(x, y, L.awnA.shade) elseif x < 231 then px(x, y, L.awnA.hi) end end)
  fill(c:ellipse(245, 38, 1, 1), L.tar.edge) px(245, 38, G.base) -- porthole
  part(deck, L.tar, { nopop = true }) hline(217, 263, 43, L.tar.hi)
  for x = 219, 261, 5 do px(x, 45, L.tar.edge) end
  -- glazing: sky reflections, the lamp lens glowing inside, diamond astragals
  glass:each(function(x, y)
    local h = L.glass.base
    if x < 236 then h = L.glass.hi elseif x > 245 then h = L.glass.shade end
    if (x + y) % 9 == 0 and x < 240 then h = L.glass.hi end
    px(x, y, h)
  end)
  local lens = c:ellipse(240, 28, 4, 5)
  fill(lens, G.base)
  lens:each(function(x, y) if (y - 28) % 2 == 0 then px(x, y, G.shade) end if x <= 239 and y <= 27 then px(x, y, G.hi) end end)
  px(240, 28, "#fffbe8") px(239, 27, "#fffbe8") -- the flame
  glass:each(function(x, y)
    if (x - y) % 7 == 0 or (x + y) % 7 == 0 then px(x, y, L.tar.base) end
  end)
  hline(231, 249, 23, L.tar.shade) hline(231, 249, 34, L.tar.shade)
  vline(231, 23, 34, L.tar.shade) vline(249, 23, 34, L.tar.deep)
  -- the dark dome with a lit left shoulder, a vent ball
  part(dome, L.tar)
  dome:each(function(x, y) if x < 238 and y < 21 and (x - 240) + (y - 23) > -12 then px(x, y, L.tar.hi) end end)
  hline(229, 251, 22, L.tar.edge)
  fill(ball, L.tar.base) px(239, 13, L.tar.hi) px(240, 16, L.tar.deep)

  -- the keeper on the gallery, waving (drawn before the rail so the rail crosses his legs)
  F.gnome(222, 42, { small = true, hat = L.awnA, coat = L.accent, arm = "up", noShadow = true, flip = true })
  -- gallery railing
  local rail = HP.mask()
  for x = 218, 262, 4 do rail:add(rect(x, 37, x, 42)) end
  rail:add(rect(217, 37, 263, 37)):add(rect(217, 40, 263, 40))
  rail:each(function(x, y) px(x, y, (y == 37) and L.tar.hi or L.tar.edge) end)

  -- flagstaff off the gallery's right end with a yard and a hoist of signal flags
  local staff = rect(263, 16, 264, 42)
  local yard = rect(263, 16, 279, 17):add(line({ { 265, 24 }, { 271, 18 } }))
  rimOf(union(staff, yard), L.tar)
  part(staff, T, { nopop = true, noshade = true }) part(yard, T, { nopop = true, noshade = true })
  px(263, 15, L.gold.hi) px(264, 15, L.gold.base)
  vline(277, 18, 64, L.cork.deep) -- halyard
  local flags = {
    function(u, v) return (u + v < 1) and L.gold or L.awnA end,                                    -- yellow / red diagonal
    function(u, v) return (u < .25 or u > .75 or v < .25 or v > .75) and L.accent or L.awnB end,   -- blue peter
    function(u, v) return ((floor(u * 4) + floor(v * 4)) % 2 == 0) and L.accent or L.awnB end,     -- chequers
    function(u, v) return (u < .5) and L.awnB or L.awnA end,                                      -- white / red
  }
  for i, fn in ipairs(flags) do
    local fy = 22 + (i - 1) * 10
    local wv = floor(sin(i * 1.7) * 1 + .5)
    local m = rect(278, fy, 287, fy + 6)
    rimOf(m, L.tar)
    m:each(function(x, y)
      local u, v = (x - 278) / 9, (y - fy) / 6
      local r = fn(u, v)
      local fold = floor((x - 278 + wv) / 3) % 2 == 1
      px(x, y, (y == fy and not fold) and r.hi or (fold and r.shade or r.base))
    end)
    hline(278, 287, fy + 7, L.tar.edge)
  end
  -- a pennant at the head of the hoist
  local pen = poly{ { 278, 64 }, { 294, 67 }, { 278, 70 } } rimOf(pen, L.tar) part(pen, L.accent)
end
lighthouse()

---------------------------------------------------------------- signal-flag poles lining the road
local flagDesigns = {
  function(u, v) return (u + v < 1) and L.gold or L.awnA end,
  function(u, v) return (u < .5) and L.awnB or L.awnA end,
  function(u, v) return (u < .3 or u > .7 or v < .3 or v > .7) and L.accent or L.awnB end,
  function(u, v) return ((floor(u * 3) + floor(v * 3)) % 2 == 0) and L.accent or L.awnB end,
  function(u, v) return (v < .33 or v > .66) and L.accent or L.gold end,
  function(u, v) return (math.abs(u - .5) < .17 or math.abs(v - .5) < .2) and L.awnA or L.awnB end,
}
local function flagPole(x, yb, s, fn)
  local h = floor(30 * s)
  local pole = rect(x, yb - h, x + math.max(1, floor(s)), yb)
  local fw, fh = floor(10 * s), floor(8 * s)
  local fl = rect(x + 2, yb - h + 1, x + 1 + fw, yb - h + fh)
  F.shadow(x, x + 2, yb, floor(4 * s), 2)
  rimOf(union(pole, fl), L.tar)
  part(pole, T, { nopop = true, noshade = true })
  fl:each(function(xx, yy)
    local u, v = (xx - x - 2) / math.max(1, fw - 1), (yy - (yb - h + 1)) / math.max(1, fh - 1)
    local r = fn(u, v)
    local fold = floor((xx - x) / math.max(2, floor(3 * s))) % 2 == 1
    px(xx, yy, fold and r.shade or (yy == yb - h + 1 and r.hi or r.base))
  end)
  px(x, yb - h - 1, L.gold.base)
  F.marram(x - 1, yb, math.max(2, floor(5 * s)))
end
for i, p in ipairs({ { 140, .55 }, { 166, .8 }, { 206, 1.2 } }) do
  local y, s = p[1], p[2]
  flagPole(floor(F.xl(y)) - floor(14 * s) - 4, y, s, flagDesigns[i * 2 - 1])
  flagPole(floor(F.xr(y)) + floor(6 * s), y, s, flagDesigns[i * 2])
end

---------------------------------------------------------------- left: the keeper's cottage, washing, oar rack, drill dummy
F.depth(1)
F.tree(30, 140, 40, 0)
F.tree(160, 136, 30, 1)
F.depth(3)
local gt, gcx, gwall, groof = F.building{ x0 = 54, x1 = 150, yb = 168, wh = 40, rh = 26, wall = L.plaster, roof = L.roof, shingle = true, chimney = true, noFrame = true, noAttic = true }
F.lichen(groof, .07, 84)
-- a tarred plinth band along the foot of the whitewash, corner quoins
local tarBand = rect(54, 163, 150, 168) part(tarBand, L.tar, { nopop = true, noshade = true }) hline(54, 150, 163, L.tar.hi)
gwall:each(function(x, y)
  if (x <= 56 or x >= 148) and y < 163 and ((y - gt) // 4) % 2 == 0 then px(x, y, x <= 56 and L.stone.hi or L.stone.shade) end
  if y > 158 and y < 163 and hash(x, y, 85) < .2 then px(x, y, L.plaster.shade) end
end)
F.window(98, 110, 104, 116, L.wall2) -- gable window
F.door(94, 142, 108, 167, L.wall2, true)
F.smoke(141, 104, 6, 1.4, 2)
local wp = rect(17, 149, 18, 172) rimOf(wp, T) part(wp, T, { nopop = true, noshade = true })
F.washing(18, 150, 54, 146, { { "sock", L.awnA }, { "shirt", L.accent }, { "sock", L.gold } }, 5)
F.window(66, 140, 74, 147, L.wall2) F.window(126, 140, 134, 147, L.wall2)
-- the cottage's lifebuoy over the door
buoy(101, 133, 6, 3)
px(101, 126, L.tar.edge)
-- window boxes with sea thrift
for _, wx in ipairs({ 70, 130 }) do
  hline(wx - 5, wx + 5, 151, L.wall2.base) hline(wx - 5, wx + 5, 152, L.wall2.deep)
  for k = -4, 4, 2 do px(wx + k, 150, L.leaf.shade) px(wx + k + 1, 149, L.petal.base) px(wx + k, 148, L.petal.hi) end
end
-- a hand lantern on a hook by the door, a storm lamp's glow
vline(112, 144, 146, L.tar.edge)
local hl = rect(110, 147, 114, 152) rimOf(hl, L.tar) fill(hl, G.base) px(110, 147, L.tar.base) px(114, 147, L.tar.base) px(111, 148, G.hi) vline(114, 148, 152, G.shade)
-- lobster pots by the cottage corner
F.lobsterPot(40, 176, 7) F.lobsterPot(28, 180, 6)

local function rack(x0, yb)
  local posts = rect(x0, yb - 26, x0 + 2, yb):add(rect(x0 + 40, yb - 26, x0 + 42, yb))
  local rails = rect(x0, yb - 24, x0 + 42, yb - 23):add(rect(x0, yb - 8, x0 + 42, yb - 7))
  F.shadow(x0, x0 + 42, yb, 8, 3)
  rimOf(union(posts, rails), L.tar)
  for k = 0, 4 do
    local x = x0 + 6 + k * 7
    vline(x, yb - 34, yb - 1, L.board.base) vline(x + 1, yb - 34, yb - 1, L.board.shade)
    if k % 2 == 0 then -- an oar: painted blade at the top
      local bl = c:rrect(x - 1, yb - 46, x + 2, yb - 33, 1)
      rimOf(bl, L.tar) part(bl, L.wall2, { nopop = true })
      fill(rect(x - 1, yb - 46, x + 2, yb - 43), L.awnA.base) hline(x - 1, x + 2, yb - 46, L.awnA.hi)
    else -- a boathook: iron spike and hook
      fill(rect(x, yb - 38, x + 1, yb - 34), IR.base) px(x, yb - 38, IR.hi)
      px(x + 2, yb - 36, IR.base) px(x + 3, yb - 37, IR.shade) px(x + 3, yb - 38, IR.base) px(x, yb - 40, IR.hi) px(x, yb - 39, IR.base)
    end
  end
  part(posts, T, { nopop = true, noshade = true }) part(rails, T, { nopop = true, noshade = true })
  F.lichen(posts, .15, 86)
  -- two lifebuoys leaning against it
  buoy(x0 + 63, yb - 8, 7, 3)
  buoy(x0 + 77, yb - 7, 6, 3)
  -- coiled rope at the foot
  local coil = c:ellipse(x0 + 21, yb + 1, 6, 2)
  rimOf(coil, L.cork) fill(coil, L.cork.base) hline(x0 + 17, x0 + 25, yb + 1, L.cork.shade) fill(c:ellipse(x0 + 21, yb + 1, 2, 1), L.cork.deep) px(x0 + 17, yb, L.cork.hi)
end
rack(60, 200)
-- the drill dummy: a sack figure in a yellow oilskin, cork lifejacket and sou'wester
local function dummy(x, yb)
  local post = rect(x - 1, yb - 30, x + 1, yb):add(rect(x - 12, yb - 22, x + 12, yb - 20))
  local sack = c:rrect(x - 7, yb - 26, x + 7, yb - 8, 4)
  local head = c:ellipse(x, yb - 32, 5, 5)
  F.shadow(x - 6, x + 8, yb, 6, 2)
  rimOf(union(post, sack, head), L.tar)
  part(post, T, { nopop = true, noshade = true })
  part(sack, L.gold)
  sack:each(function(xx, y) if xx > x + 3 then px(xx, y, L.gold.shade) end if (y - yb) % 5 == 0 and xx > x - 6 then px(xx, y, L.gold.shade) end end)
  -- cork lifejacket blocks on the chest
  for _, bx in ipairs({ x - 5, x - 1, x + 3 }) do fill(rect(bx, yb - 23, bx + 2, yb - 18), L.cork.base) px(bx, yb - 23, L.cork.hi) vline(bx + 2, yb - 22, yb - 18, L.cork.shade) end
  hline(x - 7, x + 7, yb - 17, L.tar.edge)
  part(head, L.board)
  fill(rect(x - 2, yb - 33, x - 1, yb - 32), L.tar.edge) fill(rect(x + 2, yb - 33, x + 3, yb - 32), L.tar.edge)
  hline(x - 2, x + 2, yb - 29, L.board.deep)
  -- sou'wester: a yellow hat with a long back brim
  local hat = c:ellipse(x, yb - 36, 5, 3):clip(rect(x - 6, yb - 40, x + 6, yb - 36)):add(poly{ { x - 8, yb - 35 }, { x + 9, yb - 36 }, { x + 10, yb - 33 }, { x + 6, yb - 34 }, { x - 7, yb - 34 } })
  rimOf(hat, L.gold) part(hat, L.gold)
  hline(x - 7, x + 9, yb - 35, L.gold.deep) px(x - 2, yb - 39, L.gold.hi) px(x - 3, yb - 38, L.gold.hi)
  -- straw leaking out and a gull feather tucked in the band
  px(x - 8, yb - 12, L.marram.hi) px(x + 8, yb - 14, L.marram.hi) px(x + 9, yb - 13, L.marram.base)
  vline(x + 5, yb - 43, yb - 38, L.gull.hi) px(x + 6, yb - 43, L.gull.shade)
end
dummy(178, 208)

---------------------------------------------------------------- archery range, bottom-left: painted targets on driftwood easels
local function target(x, yb, s)
  local legs = line({ { x - 6 * s, yb }, { x, yb - 22 * s } }, 2):add(line({ { x + 6 * s, yb }, { x, yb - 22 * s } }, 2))
  local cy = floor(yb - 16 * s)
  local R = floor(10 * s)
  local face = c:ellipse(x, cy, R, R)
  F.shadow(floor(x - 6 * s), floor(x + 8 * s), yb, 6, 2)
  rimOf(union(legs, face), L.tar)
  part(legs, T, { nopop = true, noshade = true })
  -- a rope-bound cork ring painted in red and white rings
  face:each(function(xx, yy)
    local d = math.sqrt((xx - x) ^ 2 + (yy - cy) ^ 2)
    local ring = floor(d / (R / 5))
    local r = (ring % 2 == 0) and L.awnA or L.awnB
    if ring >= 4 then r = L.cork end
    if d < R * .22 then r = L.accent end
    local lt = (xx - x) + (yy - cy)
    px(xx, yy, lt < -R * .7 and r.hi or (lt > R * .6 and r.shade or r.base))
  end)
  face:each(function(xx, yy) if ((xx + yy) % 3 == 0) and math.sqrt((xx - x) ^ 2 + (yy - cy) ^ 2) > R * .8 then px(xx, yy, L.cork.deep) end end) -- rope binding
  for k = 0, 1 do local ax, ay = floor(x - 2 + k * 5), floor(cy - 2 + k * 4) fill(line({ { ax, ay }, { ax - 6, ay + 3 } }), L.board.deep) px(ax - 6, ay + 3, L.gull.hi) px(ax - 7, ay + 3, L.gull.shade) end
  F.marram(floor(x - 7 * s), yb + 1, 5) F.marram(floor(x + 8 * s), yb + 1, 4)
end
target(40, 252, 1.2) target(82, 244, .9)
local _, ax, ay = F.gnome(150, 258, { hat = L.leaf, coat = L.roof2, arm = "out", flip = true })
fill(c:ellipse(ax - 1, ay, 2, 8):cut(c:ellipse(ax, ay, 1, 7)), T.base) vline(ax - 1, ay - 7, ay + 7, L.awnB.shade) -- bow
fill(line({ { ax - 1, ay }, { ax + 8, ay } }), L.board.deep) px(ax - 2, ay, IR.hi)
-- a creel used as a quiver, arrows fletched with gull feathers
local qs = rect(164, 252, 172, 260)
rimOf(qs, L.cork) part(qs, L.cork, { nopop = true }) qs:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.cork.deep) end end)
for k = 0, 2 do vline(166 + k * 2, 244, 251, L.board.deep) px(166 + k * 2, 243, L.gull.hi) px(166 + k * 2, 244, L.gull.shade) end
-- marram, thrift, shells, driftwood and a barnacled rock along the left edge
for _, f in ipairs({ { 22, 216, 6 }, { 30, 212, 5 }, { 112, 222, 5 }, { 18, 262, 7 }, { 120, 262, 6 }, { 130, 226, 5 } }) do F.marram(f[1], f[2], f[3]) end
F.thrift(58, 262, true) F.thrift(66, 265, false) F.thrift(108, 230, true)
F.shell(52, 266, true) F.shell(48, 264, false) F.shell(128, 250, true)
F.driftwood(4, 266, 34, 261, 2)
F.barnacles(F.rock(100, 266, 8, 6), .14, 88, 0)
F.wrack(84, 262, 7, 3)

---------------------------------------------------------------- right: the boathouse, lobster pots and anchor, fog bell
local function bell(x0, yb)
  local posts = rect(x0, yb - 40, x0 + 3, yb):add(rect(x0 + 34, yb - 40, x0 + 37, yb))
  local beam = rect(x0 - 4, yb - 44, x0 + 41, yb - 40)
  local braces = line({ { x0 + 3, yb - 32 }, { x0 + 10, yb - 40 } }):add(line({ { x0 + 34, yb - 32 }, { x0 + 27, yb - 40 } }))
  local b = poly{ { x0 + 12, yb - 34 }, { x0 + 25, yb - 34 }, { x0 + 28, yb - 17 }, { x0 + 9, yb - 17 } }:add(c:rrect(x0 + 12, yb - 38, x0 + 25, yb - 31, 3))
  local lip = rect(x0 + 8, yb - 18, x0 + 29, yb - 16)
  F.shadow(x0, x0 + 40, yb, 8, 3)
  rimOf(union(posts, beam, b, braces, lip), L.tar)
  part(posts, T, { nopop = true }) part(braces, T, { nopop = true, noshade = true }) part(beam, T) hline(x0 - 4, x0 + 41, yb - 44, T.hi)
  F.lichen(beam, .12, 89) F.barnacles(posts:copy():clip(rect(x0, yb - 8, x0 + 37, yb)), .12, 90, 0)
  -- a little slate hood over the beam
  local hood = poly{ { x0 - 6, yb - 44 }, { x0 + 18, yb - 52 }, { x0 + 43, yb - 44 } }
  rimOf(hood, L.roof) part(hood, L.roof, { sep = true }) F.courses(hood, yb - 52, 3, 4, L.roof) F.lichen(hood, .1, 91)
  -- bronze fog bell with a verdigris bloom
  part(b, L.gold) part(lip, L.gold, { nopop = true }) hline(x0 + 8, x0 + 29, yb - 16, L.gold.deep)
  hline(x0 + 11, x0 + 26, yb - 26, L.gold.shade) hline(x0 + 11, x0 + 26, yb - 25, L.gold.deep)
  b:each(function(x, y)
    if x < x0 + 14 and y < yb - 20 and y > yb - 36 then px(x, y, L.gold.hi) end
    if x > x0 + 23 and hash(x, y // 2, 92) < .35 then px(x, y, L.glass.shade) end
  end)
  vline(x0 + 18, yb - 40, yb - 38, L.tar.edge)
  fill(rect(x0 + 18, yb - 16, x0 + 19, yb - 13), IR.base)
  vline(x0 + 27, yb - 17, yb - 4, L.cork.deep) -- pull rope
  F.marram(x0 - 2, yb + 1, 5) F.marram(x0 + 40, yb + 1, 4)
end
F.depth(1)
F.tree(352, 136, 40, 2)
F.tree(458, 142, 48, 0)
local st, scx, swall, sroof = F.building{ x0 = 368, x1 = 424, yb = 146, wh = 22, rh = 16, wall = L.tar, roof = L.roof2, shingle = true, noFrame = true, noAttic = true }
F.planks(swall, L.tar, 4, true, 9)
F.pantile(sroof, L.roof2, st - 16, 22)
F.lichen(sroof, .05, 93)
swall:each(function(x, y) if y > 142 and hash(x, y // 2, 94) < .4 then px(x, y, L.sand.shade) end end)
local bd = rect(386, 130, 402, 145) rimOf(bd, L.tar) part(bd, L.wall2, { nopop = true })
vline(394, 130, 145, L.wall2.deep) for x = 388, 400, 3 do vline(x, 131, 145, L.wall2.shade) end
line({ { 387, 131 }, { 393, 144 } }):each(function(x, y) px(x, y, L.wall2.hi) end) line({ { 395, 144 }, { 401, 131 } }):each(function(x, y) px(x, y, L.wall2.hi) end)
F.window(410, 131, 415, 136, L.wall2)
F.netSwag(370, 384, 128, 7, { floatStep = 5 })
F.depth(2)
-- lobster pots, a coil of rope and an old anchor by the store
F.shadow(316, 356, 172, 6, 3)
F.lobsterPot(324, 172, 7) F.lobsterPot(340, 172, 7) F.lobsterPot(332, 162, 6)
F.marram(316, 173, 5) F.marram(356, 172, 4)
do
  local ax0, ay0 = 368, 150
  local anc = rect(ax0, ay0 + 3, ax0 + 1, ay0 + 21):add(rect(ax0 - 5, ay0 + 5, ax0 + 6, ay0 + 6))
  anc:add(c:ellipse(ax0, ay0 + 1, 2, 2):cut(c:ellipse(ax0, ay0 + 1, 1, 0)))
  anc:add(line({ { ax0, ay0 + 21 }, { ax0 - 6, ay0 + 17 }, { ax0 - 7, ay0 + 14 } }, 1)):add(line({ { ax0 + 1, ay0 + 21 }, { ax0 + 7, ay0 + 17 }, { ax0 + 8, ay0 + 14 } }, 1))
  rimOf(anc, L.tar) part(anc, IR, { nopop = true, noshade = true })
  anc:each(function(x, y) if hash(x, y, 95) < .3 then px(x, y, L.produce.shade) elseif hash(x, y, 96) < .2 then px(x, y, L.produce.deep) end end) -- rust
  F.wrack(ax0 - 6, ay0 + 22, 12, 7)
end
bell(300, 196)
local _, bx, by = F.gnome(334, 206, { hat = L.produce, coat = L.wall2, arm = "up", flip = true })
F.depth(3)
local function pigeonLoft(x, yb)
  local post = rect(x - 1, yb - 40, x + 1, yb)
  local box = rect(x - 12, yb - 58, x + 12, yb - 40)
  local roofm = poly{ { x - 15, yb - 58 }, { x, yb - 68 }, { x + 15, yb - 58 } }
  F.shadow(x - 2, x + 4, yb, 6, 2)
  rimOf(union(post, box, roofm), L.tar)
  part(post, T, { nopop = true, noshade = true }) part(box, L.plaster) F.planks(box, L.plaster, 4, true, 19)
  part(roofm, L.roof, { sep = true }) F.courses(roofm, yb - 68, 3, 4, L.roof) F.lichen(roofm, .12, 97)
  for k = 0, 2 do local hx = x - 9 + k * 7 fill(c:rrect(hx, yb - 54, hx + 4, yb - 48, 2), L.tar.edge) hline(hx - 1, hx + 5, yb - 47, L.wall2.base) px(hx - 1, yb - 47, L.wall2.hi) end
  hline(x - 12, x + 12, yb - 45, L.plaster.deep)
  F.lichen(post, .2, 98) F.marram(x - 3, yb, 5) F.marram(x + 4, yb + 1, 4) F.thrift(x + 9, yb + 2, false)
  for _, p in ipairs({ { x - 6, yb - 63 }, { x + 7, yb - 61 } }) do local m = c:ellipse(p[1], p[2], 3, 2) fill(m, S.base) px(p[1] - 2, p[2] - 2, S.hi) px(p[1] - 3, p[2] - 1, L.gold.base) end
  -- quirk: the carrier pigeon landing, wings up, a cream scroll tied with a red ribbon to its leg
  F.sprite({
    "K............K",
    "KWw........wWK",
    ".KWw......wWK.",
    "..KWw....wWK..",
    "...KWwwggWK...",
    ".....wggggey..",
    "....gggPQgg...",
    "...ggggPQg....",
    ".TTgggggg.....",
    "TT..gggg......",
    ".....o.o......",
    "....sZRs......",
    "....sZZs......",
  }, x - 7, yb - 86, { K = S.deep, W = S.hi, w = S.base, g = S.base, e = L.produce.base, y = L.gold.hi, P = "#7cc0a0", Q = "#b48ac8",
    T = S.shade, o = L.apple.base, s = L.awnB.hi, Z = L.awnB.shade, R = L.awnA.base })
end
pigeonLoft(440, 196)
-- brass telescope on a driftwood tripod with a gnome lookout
local tri = line({ { 362, 214 }, { 370, 196 } }):add(line({ { 378, 214 }, { 370, 196 } })):add(line({ { 370, 214 }, { 370, 196 } }))
local tube = line({ { 362, 198 }, { 384, 186 } }, 3)
rimOf(union(tri, tube), L.tar) fill(tri, T.base) part(tube, L.gold) fill(rect(382, 184, 386, 188), L.gold.shade) px(362, 198, L.glass.hi)
hline(370, 373, 192, L.gold.deep)
F.gnome(354, 218, { hat = L.lav, coat = L.awnA, arm = "out" })
-- driftwood bundles for the keeper's stove, fish boxes, paraffin for the lamp, a barrel
for k = 0, 2 do
  local x = 300 + k * 18
  local m = rect(x, 228, x + 14, 236) rimOf(m, L.tar) part(m, T, { nopop = true })
  for y = 229, 235, 2 do hline(x + 1, x + 13, y, T.deep) end
  m:each(function(xx, y) if hash(xx // 3, y, 99 + k) < .25 then px(xx, y, T.hi) end end)
  fill(rect(x + 6, 228, x + 7, 236), L.cork.deep)
  for _, ey in ipairs({ 230, 232, 234 }) do px(x + 14, ey, L.board.hi) px(x + 15, ey, L.board.base) end
end
F.crate(300, 254, 18, 12, L.gull) F.crate(320, 256, 18, 12) F.crate(310, 242, 18, 10, L.iron)
F.barrel(346, 258, T, 12)
for k = 0, 1 do
  local cx0 = 288 + k * 7
  local can = rect(cx0, 256, cx0 + 5, 264) rimOf(can, L.awnA) part(can, L.awnA, { nopop = true })
  px(cx0 + 4, 255, IR.base) px(cx0 + 5, 254, IR.shade) hline(cx0, cx0 + 5, 258, L.awnA.deep) px(cx0 + 1, 257, L.awnA.hi)
end
-- wind-pruned scrub, marram, thrift and shells closing the right in (clear of the compass corner)
local gorse = F.bush(362, 266, 10, 10, L.foliage2, 42)
gorse:each(function(x, y) if hash(x, y, 43) < .14 then px(x, y, hash(x, y, 44) < .5 and L.gorse.base or L.gorse.hi) end end)
F.windTree(420, 228, 22, L.foliage, 47)
for _, f in ipairs({ { 446, 222, 7 }, { 456, 226, 8 }, { 286, 252, 7 }, { 352, 264, 6 }, { 398, 214, 5 } }) do F.marram(f[1], f[2], f[3]) end
F.thrift(404, 224, true) F.thrift(410, 226, false) F.shell(374, 262, true) F.shell(368, 258, false)
-- a driftwood bollard by the road with a turn of rope
local stp = rect(282, 210, 290, 218) local stt = c:ellipse(286, 210, 4, 2)
rimOf(union(stp, stt), L.tar) part(stp, T, { nopop = true }) F.planks(stp, T, 3, true, 32) fill(stt, T.hi) px(286, 210, T.shade)
hline(282, 290, 214, L.cork.deep) hline(282, 290, 215, L.cork.base)
F.barnacles(stp, .1, 33, 216)
-- the keeper's mate on the road with a boathook
local _, gx, gy = F.gnome(258, 242, { hat = L.roof2, coat = L.accent, arm = "hold" })
fill(rect(gx + 6, 202, gx + 6, 242), L.board.shade) fill(rect(gx + 6, 198, gx + 6, 201), IR.hi) px(gx + 7, 200, IR.base) px(gx + 8, 199, IR.shade) px(gx + 8, 198, IR.base)
-- the dog, and the starfish it dropped
F.sprite({
  "e.......",
  "DDe.....",
  "DnDD....",
  ".DDDDDDt",
  ".DdDDDD.",
  ".d.d.d.d",
}, 272, 236, { e = L.cork.shade, D = L.cork.base, d = L.cork.shade, n = T.edge, t = L.cork.base })
F.sprite({ "..o..", "ooOoo", ".oOo.", "o...o" }, 282, 239, { o = L.produce.base, O = L.produce.hi }, { rimCol = L.produce.edge })
F.depth(0)
-- gulls wheeling round the lantern
F.gull(204, 30, 3) F.gull(296, 50, 2) F.gull(312, 58, 1) F.gull(160, 46, 2) F.gull(190, 62, 1) F.gull(350, 74, 2)
F.finish()
