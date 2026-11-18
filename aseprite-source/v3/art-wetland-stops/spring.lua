-- spring.lua : "Spring" stop look, WETLAND (wetland_reed), 480x270 gate view.
-- Same composition as the Maplewold spring (art-2701-batch4/stops/opus3/spring.lua), re-cast for a reed fen:
-- Right hero: a fen spring mound, a hump of sedge tussocks over a cut peat face with pale tufa stones, alders and a
-- weeping willow on top. Set into it a dressed limestone face under a little reed-thatched hood, with an arched niche
-- and a carved stone gnome head; spring water arcs from its mouth into a round stone well-head kerb holding a
-- peat-brown pool, reached from the causeway by a short boardwalk. A second trickle runs from a crack in the peat into
-- a gnome's pail. The pool overflows into a peat-brown rill that winds down-left through watercress, under a timber
-- railed culvert on the causeway, into a lily pool bottom-left crossed by a boardwalk.
-- Left: a sweep well (shadoof) with a stone kerb and a gnome hauling the bucket up, alders, a pink clay-lump cottage.
-- A gnome carries two pails on a yoke down the causeway, another does the washing from a boardwalk landing, another
-- drags a water barrel on a bog sledge. Road's end: a thatched hamlet with a round-tower flint church.
-- Life: dragonflies, a kingfisher on the bridge rail, a moorhen and chicks, yellow flag iris, marsh marigolds.
-- Quirk: a big green frog in a red gnome hat sits on a lily pad in the well-head pool, eyes shut, taking a shower
-- under the spout.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-wetland-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "spring", out = DIR, farTrees = { 22, 60, 104, 150, 330, 372, 452 },
  poolK = .8, clouds = { { 140, 42, 40 }, { 280, 30, 46 }, { 400, 58, 34 }, { 30, 84, 22 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local mix = F.mix
local Wt = L.water
local PW = F.rp("#d4c69c #8a6a44 #634a30 #443222 #2c2018")   -- peat-brown spring water (tannin stained)
local GL = "#f0e8c6"                                           -- cream glint
local CL = F.rp("#eef0dc #c8d4c4 #9ab0aa #6e8684 #4a5a5c")   -- clear spring water (the jet, the trickle)
local lime = F.rp("#f0e6c6 #d4c6a0 #ae9e7e #807460 #50483e") -- dressed limestone
local tufa = F.rp("#e6dfbe #c6bb96 #a09574 #756b56 #4a4438") -- pitted spring tufa
local pink = F.rp("#f6d8c4 #e2baa2 #be947e #8c6c5e #58443e") -- pink-washed clay lump
local KF = F.rp("#a0dcec #4aa8c8 #2e7c9c #22586e #163a48")   -- kingfisher blue
local moss, peat, sedgeG, reed, rg = L.moss, L.peat, L.sedgeGround, L.reed, L.reedGreen

---------------------------------------------------------------- local helpers
-- yellow flag iris: a fan of sword leaves and a yellow flower or two on top
local function iris(x, yb, h, seed, flowers)
  for k = -2, 2 do
    local lean = k * .22 + (hash(k, 1, seed) - .5) * .2
    local hh = h - abs(k) * 2 - floor(hash(k, 2, seed) * 3)
    for t = 0, hh do
      local xx = floor(x + k * .6 + lean * t + .5)
      local col = k < 0 and rg.hi or (k == 0 and rg.base or rg.shade)
      if t < 2 then col = rg.deep end
      if t > hh - 2 then col = k <= 0 and rg.base or rg.deep end
      px(xx, yb - t, col)
    end
  end
  for f = 1, flowers or 1 do
    local fx, fy = x + (f == 1 and 1 or -2), yb - h - (f == 1 and 2 or -2)
    vline(fx, fy + 2, fy + 5, rg.shade)
    px(fx - 1, fy, L.marigold.base) px(fx, fy - 1, L.marigold.hi) px(fx + 1, fy, L.marigold.shade)
    px(fx - 2, fy + 1, L.marigold.shade) px(fx, fy, L.marigold.base) px(fx + 2, fy + 1, L.marigold.deep) px(fx, fy + 1, L.produce.shade)
  end
end
-- marsh marigold clump: round dark leaves, golden cups
local function marigolds(x, y, n, seed)
  for i = 1, n do
    local lx, ly = x + floor((hash(i, 1, seed) - .5) * n * 3), y + floor((hash(i, 2, seed) - .5) * 3)
    px(lx, ly, rg.base) px(lx + 1, ly, rg.shade) px(lx - 1, ly + 1, rg.hi) px(lx, ly + 1, rg.shade) px(lx + 1, ly + 1, rg.deep)
    if hash(i, 3, seed) < .6 then px(lx, ly - 1, L.marigold.base) px(lx - 1, ly - 1, L.marigold.hi) px(lx + 1, ly - 1, L.marigold.shade) px(lx, ly - 2, L.marigold.hi) end
  end
end
-- ragged robin: thin stems with frayed pink heads
local function robin(x, y, seed)
  for i = 0, 2 do
    local sx, h = x + i * 2 - 2, 4 + floor(hash(i, 1, seed) * 4)
    vline(sx, y - h, y, rg.shade)
    px(sx, y - h - 1, L.petal.base) px(sx - 1, y - h, L.petal.hi) px(sx + 1, y - h, L.petal.shade) px(sx, y - h - 2, L.petal.hi)
  end
end
-- watercress: low mats of round leaves with tiny white flowers
local function cress(x, y, w, seed)
  for i = 0, w do
    local yy = y + floor(hash(i, 1, seed) * 3)
    local xx = x + i
    local v = hash(i, 2, seed)
    px(xx, yy, v < .35 and "#9ab25e" or (v < .75 and "#6e8c44" or "#4e6a34"))
    if v < .5 then px(xx, yy + 1, "#4e6a34") end
    if v > .88 then px(xx, yy - 1, L.awnB.hi) end
  end
end
-- a tied bunch of cress (stall)
local function cressBunch(x, yb)
  local m = c:ellipse(x, yb - 4, 3, 3)
  c:rim(m, L.leaf.edge)
  m:each(function(xx, yy) local v = hash(xx, yy, 5) px(xx, yy, v < .3 and "#9ab25e" or (v < .7 and "#6e8c44" or "#4e6a34")) end)
  px(x - 1, yb - 6, "#c4d88a") px(x, yb - 1, L.reed.deep) px(x, yb, rg.shade) px(x + 1, yb, rg.deep)
end

---------------------------------------------------------------- back row: a thatched hamlet with a round-tower flint church
F.depth(1)
F.building{ x0 = 196, x1 = 228, yb = 126, wh = 13, rh = 11, wall = L.plaster, roof = L.roof, noFrame = true, noAttic = true, chimney = true }
F.window(204, 117, 208, 120, L.timber)
F.smoke(219, 97, 4, .5, 2)
do -- the round-tower church: a flint drum tower with a little battlement, a thatched nave
  local nave = rect(260, 112, 282, 126)
  local roof = poly{ { 257, 113 }, { 270, 101 }, { 285, 113 } }
  local tower = c:rrect(248, 92, 260, 126, 2)
  local batt = HP.mask()
  for x = 248, 260, 3 do batt:add(rect(x, 89, x + 1, 91)) end
  rimOf(union(nave, roof, tower, batt), L.stone)
  part(nave, L.stone) F.courses(nave, 112, 3, 6, L.stone)
  part(tower, L.stone, { nopop = true })
  tower:each(function(x, y) -- round: lit left, dark right; flint knaps
    local u = (x - 254) / 6
    local h = u < -.5 and L.stone.hi or (u < .3 and L.stone.base or L.stone.shade)
    if hash(x, y, 11) < .18 then h = L.stone.deep elseif hash(x, y, 12) < .06 then h = L.stone.edge end
    if (y - 92) % 9 == 0 then h = L.stone.shade end
    px(x, y, h)
  end)
  part(batt, L.stone, { nopop = true })
  part(roof, L.roof, { nopop = true }) F.thatch(roof, L.roof, 101, 270)
  hline(258, 284, 112, L.roof.deep)
  fill(c:rrect(252, 97, 255, 102, 1), L.timber.edge) px(253, 98, L.glow.shade)
  F.window(270, 116, 273, 121, L.stone, true)
  fill(rect(276, 118, 279, 126), L.timber.shade) vline(276, 118, 126, L.timber.hi)
end
F.tree(300, 128, 28, 3)
F.tree(186, 128, 30, 1)
F.fenceP(120, 132, 190, 127, 6)
F.depth(1)
F.mist(150, 246, 120, 124, 64, .4)

---------------------------------------------------------------- mid left: pink clay-lump cottage, alders
F.depth(2)
do
  local top, cx, wall, roofM = F.building{ x0 = 24, x1 = 70, yb = 136, wh = 20, rh = 17, wall = pink, roof = L.roof, chimney = true, noAttic = true, noFrame = true }
  wall:each(function(x, y) if y > 131 then px(x, y, (hash(x, y, 3) < .5) and L.stone.shade or L.stone.base) end end) -- tarred plinth
  hline(24, 70, 131, L.stone.deep)
  F.moss(roofM, .05, 4)
  F.window(30, 120, 36, 126, L.timber) F.door(50, 123, 57, 135, L.timber)
  -- a boot-scraper and a water butt by the door
  F.barrel(64, 136, L.timber, 8)
end
F.smoke(61, 88, 6, .5, 2)
F.alder(92, 150, 56, 31)
F.washing(70, 118, 90, 121, { { "shirt", L.awnA }, { "sock", L.accent }, { "trousers", L.lav } }, 3)
F.pollard(160, 140, 38, 34)
F.tree(124, 146, 40, 6)
do -- a silvered plank bench under the willow with two gnomes, a far gnome on the causeway
  local lg = rect(112, 157, 146, 159)
  local legs = rect(114, 160, 115, 163):add(rect(143, 160, 144, 163))
  rimOf(union(lg, legs), L.timber) part(lg, L.board, { nopop = true }) part(legs, L.timber, { nopop = true, noshade = true })
  hline(112, 146, 157, L.board.hi)
  F.gnome(124, 160, { small = true, hat = L.roof2, coat = L.leaf, arm = "out", noShadow = true })
  F.gnome(136, 160, { small = true, hat = L.accent, coat = L.awnA, flip = true, noShadow = true })
  F.gnome(238, 146, { small = true, hat = L.lav, coat = L.wall2, arm = "out" })
  px(248, 139, L.roof2.base) px(248, 140, L.roof2.shade)
end

---------------------------------------------------------------- right hero: the spring mound
F.depth(2)
F.tree(446, 128, 70, 8)   -- weeping willow behind the mound
F.alder(404, 106, 42, 55)
F.alder(352, 116, 34, 56)
F.alder(326, 138, 26, 57)
F.depth(3)
local boulders = {
  { 312, 158, 22, 22, 41 }, { 340, 128, 26, 24, 42 }, { 384, 114, 30, 22, 43 }, { 430, 120, 26, 24, 44 },
  { 452, 160, 20, 30, 45 }, { 300, 196, 16, 16, 46 }, { 436, 196, 26, 18, 47 },
  { 330, 190, 22, 18, 48 }, { 352, 166, 14, 16, 50 }, { 418, 150, 12, 16, 51 },
}
local isTufa = { [46] = true, [48] = true, [51] = true, [50] = true }
local rockM = HP.mask()
for _, b in ipairs(boulders) do
  local pts = {}
  for i = 0, 13 do
    local a = i / 14 * 2 * pi
    local k = .82 + .2 * hash(i, b[5], 3)
    pts[#pts + 1] = { b[1] + cos(a) * b[3] * k, b[2] + sin(a) * b[4] * k }
  end
  b.m = poly(pts)
  rockM:add(b.m)
end
local face = rect(352, 132, 420, 196)
local mass = poly{ { 294, 212 }, { 298, 172 }, { 312, 132 }, { 346, 106 }, { 388, 96 }, { 432, 98 }, { 466, 110 }, { 470, 212 } }
rockM:add(face):add(mass)
F.shadowM(c:ellipse(380, 214, 92, 5))
rimOf(rockM, peat)
-- the mound body: dark wet peat in layers, with sedge flecks and pale root threads
mass:each(function(x, y)
  local band = (y + floor(sin(x * .11) * 2 + sin(x * .37) * 1)) % 7
  local h = band < 2 and peat.shade or (band < 5 and peat.deep or peat.edge)
  local v = hash(x, y, 77)
  if v < .05 then h = peat.base elseif v > .97 then h = L.cattail.deep end
  if hash(x // 3, y // 3, 79) < .1 then h = moss.deep end
  px(x, y, h)
end)
for _, b in ipairs(boulders) do
  if isTufa[b[5]] then
    -- pale tufa stone: faceted, pitted with dark holes, lit from the upper left
    local off = hash(b[5], 1, 2) * 2 * pi
    b.m:each(function(x, y)
      local nx, ny = (x - b[1]) / b[3], (y - b[2]) / b[4]
      local r = math.sqrt(nx * nx + ny * ny)
      local a = math.atan(ny, nx)
      local sec = floor(((a + off) % (2 * pi)) / (2 * pi) * 6)
      local ca = sec / 6 * 2 * pi + pi / 6 - off
      local lit
      if r < .4 then lit = .25 - (nx * .6 + ny * .8) * .4 else lit = -(cos(ca) * .6 + sin(ca) * .8) * math.min(1, r * 1.2) end
      lit = lit + (hash(x // 2, y // 2, b[5]) - .5) * .3
      local h
      if lit > .5 then h = tufa.hi elseif lit > .05 then h = tufa.base elseif lit > -.4 then h = tufa.shade else h = tufa.deep end
      local p = hash(x, y, b[5] + 5)
      if p < .06 then h = tufa.deep; if b.m:has(x - 1, y - 1) then px(x - 1, y - 1, tufa.edge) end
      elseif p > .95 then h = tufa.hi end
      px(x, y, h)
    end)
    c:edgeIn(b.m, tufa.edge)
    for k = 1, 3 do -- lichen
      local x, y = floor(b[1] + (hash(k, b[5], 83) - .5) * b[3] * 1.2), floor(b[2] + (hash(k, b[5], 84) - .3) * b[4] * .8)
      if b.m:has(x, y) then px(x, y, "#d4dca0") px(x + 1, y, "#aebc80") px(x, y + 1, "#aebc80") end
    end
  else
    -- a sedge tussock: a skirt of combed blades (gold-olive, lit upper left) over a cut peat side with roots
    b.m:each(function(x, y)
      local nx, ny = (x - b[1]) / b[3], (y - b[2]) / b[4]
      local cap = .05 + .22 * sin(x * .5 + b[5]) * .5 + .18 * hash(x // 2, 3, b[5])
      local lt = -(nx * .6 + ny * .8)
      if ny < cap then
        local stripe = (x + floor(ny * 3)) % 3
        local rr = (hash(x // 2, 7, b[5]) < .35) and rg or reed
        local h = lt > .55 and rr.hi or (lt > .05 and rr.base or (lt > -.4 and rr.shade or rr.deep))
        if stripe == 0 then h = (h == rr.hi) and rr.base or (h == rr.base and rr.shade or rr.deep) end
        if hash(x, y, 9) < .05 then h = L.plume.base end
        px(x, y, h)
        if ny + .08 >= cap and hash(x, b[5], 10) < .5 then -- blades hanging over the peat
          local n = 1 + floor(hash(x, b[5], 11) * 4)
          for t = 1, n do if b.m:has(x, y + t) then px(x, y + t, t == n and rr.deep or rr.shade) end end
        end
      else
        local band = (y + floor(sin(x * .3 + b[5]) * 1.5)) % 5
        local h = lt > .3 and peat.base or (lt > -.2 and peat.shade or peat.deep)
        if band == 0 then h = (h == peat.base) and peat.hi or peat.base end
        if band == 3 and lt < 0 then h = peat.edge end
        if hash(x, y, b[5]) < .04 then h = L.reed.shade end -- straw / root threads
        px(x, y, h)
      end
    end)
    c:edgeIn(b.m, peat.edge)
    -- a few pale root threads dangling from the peat
    for k = 1, 3 do
      local x, y = floor(b[1] + (hash(k, b[5], 81) - .5) * b[3]), floor(b[2] + b[4] * (.15 + .3 * hash(k, b[5], 82)))
      for t = 0, 3 + k do if b.m:has(x, y + t) then px(x + (t > 2 and 1 or 0), y + t, t % 2 == 0 and L.reed.base or L.reed.shade) end end
    end
    -- sphagnum cushions (red-green) at the foot
    for k = 1, 2 do
      local x, y = floor(b[1] + (hash(k, b[5], 85) - .5) * b[3]), floor(b[2] + b[4] * .62)
      if b.m:has(x, y) then
        for d = -2, 2 do px(x + d, y, (d + k) % 2 == 0 and "#b8a24c" or "#9a8a40") px(x + d, y - 1, abs(d) < 2 and ((d + k) % 2 == 0 and "#d6c06a" or "#c26a4a") or nil) end
      end
    end
  end
end
-- sedge blades and reed sprouting on the mound's crest, marigolds and ragged robin on its ledges
F.reeds(346, 372, 108, 10, 91, { green = true })
F.reeds(424, 446, 104, 9, 92)
for _, s in ipairs({ { 318, 140, 6 }, { 300, 176, 5 }, { 458, 140, 6 }, { 426, 136, 5 }, { 336, 108, 6 }, { 466, 186, 5 } }) do F.sedge(s[1], s[2], s[3]) end
marigolds(320, 182, 4, 1) marigolds(444, 178, 4, 2) marigolds(432, 106, 3, 3)
robin(300, 186, 4) robin(460, 172, 5)
-- the dressed face: limestone ashlar, an arched niche
part(face, lime, { inner = false })
F.courses(face, 132, 7, 14, lime)
c:edgeIn(face, lime.edge)
face:each(function(x, y) if y > 186 and hash(x, y // 2, 4) < .4 then px(x, y, lime.shade) end end) -- wet foot
local niche = c:rrect(362, 136, 410, 186, 20):clip(rect(362, 136, 410, 186))
fill(niche, peat.deep) c:edgeIn(niche, lime.edge)
niche:each(function(x, y)
  if (x - 386) + (y - 160) < -14 then px(x, y, peat.shade) end
  if hash(x, y, 5) < .04 then px(x, y, peat.edge) end
  if y > 174 and hash(x // 2, y, 6) < .4 then px(x, y, (y % 2 == 0) and "#4e6a34" or moss.deep) end -- liverwort, wet
end)
c:rrect(360, 134, 412, 188, 22):clip(rect(360, 134, 412, 186)):cut(c:rrect(362, 136, 410, 188, 20)):each(function(x, y) px(x, y, ((x + y) % 5 == 0) and lime.deep or lime.hi) end)
-- a reed-thatched hood over the face on two posts
do
  local hood = poly{ { 344, 136 }, { 351, 120 }, { 421, 120 }, { 428, 136 } }
  local posts = rect(353, 136, 355, 196):add(rect(417, 136, 419, 196))
  rimOf(union(hood, posts), L.timber)
  part(posts, L.timber, { nopop = true, noshade = true }) vline(353, 137, 195, L.timber.hi)
  part(hood, L.roof, { sep = true }) F.thatch(hood, L.roof, 120, 386)
  hood:each(function(x, y) if y < 125 then px(x, y, ((x // 3) % 2 == 0 and y == 124) and L.roof2.deep or ((x + y) % 4 == 0 and L.roof2.hi or (x < 386 and L.roof2.base or L.roof2.shade))) end end)
  for x = 352, 420, 6 do px(x, 122, L.timber.hi) end -- liggers
  line({ { 345, 135 }, { 351, 121 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  hline(344, 428, 136, L.roof.deep)
  for x = 346, 426 do if hash(x, 1, 31) < .45 then px(x, 137, L.roof.shade) end end -- ragged drip
  for x = 356, 416 do px(x, 138, lime.deep) if hash(x, 2, 31) < .5 then px(x, 139, lime.shade) end end -- shadow under the eaves
  -- a little carved drop on the hood's gable board
  px(386, 128, CL.hi) px(385, 129, CL.base) px(386, 129, CL.hi) px(387, 129, CL.shade) px(386, 130, CL.shade)
  -- sedge growing in the old thatch
  for _, s in ipairs({ { 362, 124 }, { 402, 123 } }) do F.sedge(s[1], s[2], 4, rg) end
end
-- the carved stone gnome head spout
do
  local hx, hy = 386, 158
  local hat = poly{ { hx - 13, hy - 8 }, { hx + 13, hy - 8 }, { hx + 6, hy - 22 }, { hx + 11, hy - 26 }, { hx + 2, hy - 25 }, { hx - 6, hy - 18 } }
  local fc = c:rrect(hx - 11, hy - 9, hx + 11, hy + 3, 4)
  local beard = poly{ { hx - 12, hy - 1 }, { hx + 12, hy - 1 }, { hx + 9, hy + 12 }, { hx, hy + 18 }, { hx - 9, hy + 12 } }
  local head = union(hat, fc, beard)
  c:rim(head, lime.edge)
  part(fc, lime, { nopop = true }) part(beard, lime, { nopop = true }) part(hat, lime, { nopop = true })
  hline(hx - 13, hx + 13, hy - 8, lime.deep) hline(hx - 12, hx + 12, hy - 9, lime.hi)
  beard:each(function(x, y) if (x + 2 * y) % 5 == 0 and y > hy + 1 then px(x, y, lime.shade) end end)
  for _, ex in ipairs({ hx - 6, hx + 6 }) do px(ex - 2, hy - 4, lime.edge) px(ex - 1, hy - 3, lime.edge) px(ex, hy - 3, lime.edge) px(ex + 1, hy - 3, lime.edge) px(ex + 2, hy - 4, lime.edge) end
  local nose = c:ellipse(hx, hy - 1, 4, 3) c:rim(nose, lime.deep) part(nose, lime, { nopop = true }) px(hx - 2, hy - 3, lime.hi) px(hx - 1, hy - 3, lime.hi)
  px(hx - 9, hy - 1, lime.shade) px(hx + 9, hy - 1, lime.shade)
  -- a brass pipe
  local pipe = rect(hx - 2, hy + 4, hx + 4, hy + 7) c:rim(pipe, L.timber.edge) fill(pipe, L.gold.shade) hline(hx - 2, hx + 4, hy + 4, L.gold.hi) fill(rect(hx + 3, hy + 5, hx + 4, hy + 6), CL.deep)
  -- a rust-orange iron stain from the spring water (fen springs run ochre) and a tuft of liverwort on the hat
  for y = hy + 8, hy + 16 do px(hx + 1, y, (y % 2 == 0) and "#c8884c" or "#b07440") end
  px(hx + 2, hy + 9, "#d8a066") px(hx, hy + 12, "#c8884c")
  for x = hx - 3, hx + 7 do px(x, hy - 21 + floor(abs(x - hx - 2) * .6), "#6e8c44") end
  px(hx + 1, hy - 23, "#9ab25e") px(hx + 3, hy - 22, "#9ab25e")
end
-- the jet: an arc of clear water from the mouth into the pool
local JX0, JY0 = 391, 164
local function jetY(x) local t = (x - JX0) / 18 return JY0 + floor(t * t * 22 + t * 2) end
for x = JX0, JX0 + 17 do
  local y0, y1 = jetY(x), jetY(x + 1)
  for y = y0, math.max(y0 + 3, y1 + 1) do px(x, y, CL.base) px(x + 1, y, CL.base) px(x + 2, y, CL.shade) end
  px(x, y0, CL.hi) px(x, y0 - 1, CL.edge)
  if x % 3 == 0 then px(x + 1, y0 + 1, GL) end
end

---------------------------------------------------------------- the well-head pool, its overflow and the frog
F.depth(3)
local BX, BY = 392, 202
do
  local outer = c:ellipse(BX, BY, 40, 10)
  local wall = rect(BX - 40, BY, BX + 40, BY + 8)
  local inner = c:ellipse(BX, BY - 1, 35, 7)
  rimOf(union(outer, wall), L.stone)
  part(union(outer, wall), L.stone)
  F.courses(wall, BY, 4, 9, L.stone)
  wall:each(function(x, y) if (x - BX) > 20 and y > BY + 2 then px(x, y, L.stone.shade) end end)
  -- coping stones on the kerb, with joints
  outer:cut(inner):each(function(x, y)
    local h = y < BY - 2 and L.stone.hi or (y < BY + 3 and L.stone.base or L.stone.shade)
    if floor(math.atan(y - BY, (x - BX) * .25) * 7) % 3 == 0 and (x + y) % 2 == 0 and y > BY - 6 then h = L.stone.deep end
    px(x, y, h)
  end)
  F.water(inner, PW)
  -- the hood and the gnome head mirrored dark in the far half
  inner:each(function(x, y) if y < BY - 1 and abs(x - 386) < 22 and (x + y) % 2 == 0 then px(x, y, PW.deep) end end)
  for k = 0, 3 do hline(BX - 16 + k * 2, BX - 4 - k, BY - 5 + k, PW.shade) end
  -- rings spreading from the jet
  c:ellipse(409, 201, 9, 3):edge():each(function(x, y) if inner:has(x, y) and (x + y) % 2 == 0 then px(x, y, PW.hi) end end)
  c:ellipse(409, 201, 14, 5):edge():each(function(x, y) if inner:has(x, y) and hash(x, y, 4) < .4 then px(x, y, mix(PW.hi, PW.base, .5)) end end)
  -- moss and liverwort creeping up the kerb, sedge at its foot
  for x = BX - 40, BX + 40 do if hash(x, 4, 12) < .45 then local n = floor(hash(x, 5, 12) * 4) for k = 0, n do px(x, BY + 8 - k, k == n and moss.hi or moss.base) end end end
  for _, s in ipairs({ { 356, 212 }, { 372, 213 }, { 420, 212 } }) do F.sedge(s[1], s[2], 5) end
end
-- the trickle from a crack in the peat into a gnome's pail
do
  local cx, cy = 334, 168
  fill(line({ { cx - 3, cy - 4 }, { cx, cy } }, 2), peat.edge)
  for y = cy - 3, cy + 6 do px(cx - 1 + floor((y - cy + 4) * .3), y + 1, "#b07440") end -- ochre stain
  for y = cy, 196 do px(cx + floor((y - cy) * .1), y, ((y // 2) % 2 == 0) and CL.hi or CL.base) end
  local _, hx, hy = F.gnome(318, 218, { hat = L.awnA, coat = L.lav, arm = "out" })
  local pail = poly{ { hx + 1, hy - 7 }, { hx + 10, hy - 7 }, { hx + 9, hy + 3 }, { hx + 2, hy + 3 } }
  c:rim(pail, L.timber.edge) part(pail, L.board) F.planks(pail, L.board, 3, true, 31)
  hline(hx + 1, hx + 10, hy - 5, L.iron.shade) hline(hx + 2, hx + 9, hy + 1, L.iron.shade)
  hline(hx + 2, hx + 9, hy - 7, PW.hi) px(hx + 5, hy - 8, GL) px(hx + 8, hy - 9, CL.hi)
  c:ellipse(hx + 5, hy - 12, 5, 4):edge():each(function(x, y) if y < hy - 11 then px(x, y, L.iron.base) end end)
end
-- QUIRK: the frog in a red gnome hat on a lily pad in the pool, eyes shut, under the shower
do
  local pad = c:ellipse(408, 200, 10, 3):cut(poly{ { 408, 200 }, { 420, 197 }, { 420, 202 } })
  fill(pad, L.lily.base) pad:edge():each(function(x, y) if y > 200 then px(x, y, L.lily.deep) else px(x, y, L.lily.hi) end end)
  for k = 1, 4 do px(408 - k * 2, 200 - (k % 2), L.lily.shade) end -- veins
  F.sprite({
    "..........RR....",
    ".........RRr....",
    "........HRRr....",
    ".......HRRRr....",
    "......HRRRRr....",
    "......RRRRRRr...",
    ".....HRRRRRRr...",
    "...bbbbbbbbbbb..",
    "..GGgGGGGGGgGGG.",
    ".GGekeGGGGGekeG.",
    ".GgGGGGGGGGGGgGg",
    "gGGGGmmmmmmGGGGg",
    "gGGGGGmmmmGGGGgg",
    "gGGyyyyyyyyyGGgd",
    ".gGyyyyyyyyyGgdd",
    "GGgyyyyyyyyygdGG",
    "GGGgyyyyyyygdGGG",
    ".dd.ddd..ddd.dd.",
  }, 400, 181, { R = L.awnA.base, r = L.awnA.shade, H = L.awnA.hi, b = L.reed.hi, G = L.leaf.base, g = L.leaf.shade,
    d = L.leaf.deep, e = L.leaf.deep, k = L.timber.edge, m = L.apple.shade, y = L.marigold.hi })
  px(405, 191, L.leaf.deep) px(411, 190, L.leaf.deep) px(410, 192, L.leaf.shade)
  for _, p in ipairs({ { 409, 176 }, { 405, 178 }, { 413, 177 }, { 402, 181 }, { 416, 182 }, { 411, 173 }, { 399, 186 }, { 418, 186 } }) do px(p[1], p[2], CL.hi) end
  px(407, 175, GL) px(414, 175, GL)
end
-- the overflow rill winding down-left under the causeway into the lily pool
local brook = HP.mask()
do
  local pts = { { 356, 208 }, { 340, 218 }, { 318, 226 }, { 296, 232 }, { 270, 238 }, { 240, 242 }, { 210, 244 }, { 180, 247 }, { 150, 250 } }
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local w = 12 + floor(i * 1.6)
    brook:add(line({ a, b }, w))
    brook:add(c:ellipse(b[1], b[2], w // 2, w // 2))
  end
  local pond = c:ellipse(84, 252, 76, 18):clip(rect(19, 230, 200, 269))
  brook:add(pond)
end
local onRoad = HP.mask()
brook:each(function(x, y) if F.roadM:has(x, y) then onRoad:set(x, y) end end)
brook:cut(onRoad)
do
  local bank = brook:grow(2):cut(brook):cut(F.roadM)
  bank:each(function(x, y) local v = hash(x, y, 51) px(x, y, v < .45 and peat.base or (v < .65 and peat.hi or (v < .85 and sedgeG.base or rg.shade))) end)
  brook:edge():each(function(x, y) if hash(x, y, 52) < .25 then px(x, y, peat.shade) end end)
  F.water(brook, PW, { step = 3 })
  -- alder and willow reflections on the pool's far edge
  for _, rx in ipairs({ 36, 56, 92, 126 }) do for k = 0, 6 do hline(rx - 4 + k // 2, rx + 4 - k // 2, 238 + k * 2, PW.deep) end end
  brook:each(function(x, y)
    if y % 3 == 1 and hash(x // 5, y, 54) < .3 and brook:has(x - 2, y) and brook:has(x + 2, y) and brook:has(x, y + 2) then px(x, y, PW.hi) end
    if hash(x, y, 55) < .01 and brook:has(x, y - 2) then px(x, y, GL) end
  end)
  -- sunk tussocks in the rill with a cream lip on the upstream side
  for _, s in ipairs({ { 334, 220 }, { 310, 228 }, { 290, 234 }, { 186, 247 }, { 270, 241 } }) do
    local m = c:ellipse(s[1], s[2], 3, 2) rimOf(m, peat) part(m, peat, { nopop = true })
    px(s[1] - 1, s[2] - 2, reed.hi) px(s[1], s[2] - 3, reed.base) px(s[1] + 1, s[2] - 2, reed.shade) px(s[1] - 2, s[2] - 1, rg.base)
    for k = 0, 3 do px(s[1] + 3 + k, s[2] - 2 + (k % 2), GL) end hline(s[1] - 4, s[1] - 1, s[2] + 3, PW.hi)
  end
  -- watercress mats along the rill's edges
  for _, w in ipairs({ { 340, 208, 10 }, { 300, 222, 12 }, { 276, 230, 8 }, { 318, 234, 10 }, { 196, 238, 8 } }) do cress(w[1], w[2], w[3], w[1]) end
  -- spill over the kerb lip
  for y = 204, 212 do px(354 + (y - 204) // 3, y, CL.hi) px(355 + (y - 204) // 3, y, PW.base) px(356 + (y - 204) // 3, y, GL) end
end
-- the causeway culvert: timber revetments with square culvert mouths and silvered hand-rails along both road edges
do
  local Y0, Y1 = 226, 258
  local wallL = poly{ { floor(F.xl(234)) - 22, 236 }, { floor(F.xl(234)) - 6, 230 }, { floor(F.xl(256)) - 6, 258 }, { floor(F.xl(256)) - 24, 258 } }
  local wallR = poly{ { floor(F.xr(226)) + 6, 224 }, { floor(F.xr(226)) + 22, 228 }, { floor(F.xr(244)) + 22, 248 }, { floor(F.xr(244)) + 6, 248 } }
  local walls = union(wallL, wallR)
  rimOf(walls, L.timber)
  part(walls, L.timber, { nopop = true }) F.planks(walls, L.timber, 3, true, 41)
  walls:each(function(x, y) if hash(x, y // 2, 42) < .08 then px(x, y, moss.shade) end end)
  for _, a in ipairs({ { floor(F.xl(244)) - 15, 251, wallL }, { floor(F.xr(236)) + 14, 242, wallR } }) do
    local mouth = rect(a[1] - 6, a[2] - 6, a[1] + 6, a[2] + 4):clip(a[3])
    fill(mouth, PW.edge)
    mouth:each(function(x, y) if y > a[2] - 2 then px(x, y, (x + y) % 3 == 0 and PW.shade or PW.deep) end end)
    local lintel = rect(a[1] - 8, a[2] - 9, a[1] + 8, a[2] - 7):clip(a[3])
    fill(lintel, L.timber.base) lintel:each(function(x, y) if y == a[2] - 9 then px(x, y, L.timber.hi) elseif y == a[2] - 7 then px(x, y, L.timber.edge) end end)
    for k = 0, 4 do px(a[1] - 4 + k * 2, a[2] + 3, GL) end
    for k = -5, 5, 3 do local n = 1 + floor(hash(k, a[1], 61) * 3) for t = 0, n do px(a[1] + k, a[2] - 6 + t, t == n and rg.deep or rg.shade) end end
  end
  -- stake heads along the revetment tops
  for _, w in ipairs({ wallL, wallR }) do w:each(function(x, y) if not w:has(x, y - 1) and x % 4 == 0 then px(x, y - 1, L.timber.base) px(x, y - 2, L.timber.hi) end end) end
  -- hand-rails: posts every 8 rows, a top rail and a mid rail, along each road edge
  local rail, posts = HP.mask(), HP.mask()
  for _, side in ipairs({ -1, 1 }) do
    local function ex(y) return side < 0 and floor(F.xl(y)) - 3 or floor(F.xr(y) + .99) + 3 end
    rail:add(line({ { ex(Y0), Y0 - 10 }, { ex(Y1), Y1 - 10 } }, 2))
    rail:add(line({ { ex(Y0), Y0 - 5 }, { ex(Y1), Y1 - 5 } }, 1))
    for y = Y0, Y1, 8 do posts:add(rect(ex(y) - 1, y - 11, ex(y), y)) end
  end
  rimOf(union(rail, posts), L.timber)
  part(posts, L.timber, { nopop = true, noshade = true })
  posts:each(function(x, y) if not posts:has(x - 1, y) then px(x, y, L.timber.hi) end end)
  part(rail, L.board, { nopop = true, noshade = true })
  rail:each(function(x, y) if not rail:has(x, y - 1) then px(x, y, L.board.hi) end end)
end

---------------------------------------------------------------- left: a sweep well (shadoof) with a gnome hauling the bucket
F.depth(3)
do
  local WX, yb = 84, 204
  local drum = c:rrect(WX - 22, yb - 16, WX + 22, yb, 3)
  local lip = c:ellipse(WX, yb - 16, 22, 4)
  local hole = c:ellipse(WX, yb - 16, 17, 2)
  local post = rect(43, 146, 45, yb + 2)
  local fork = line({ { 44, 148 }, { 41, 142 } }):add(line({ { 44, 148 }, { 47, 142 } }))
  local pole = line({ { 20, 170 }, { WX + 4, 118 } }, 2)
  local cw = c:ellipse(20, 172, 6, 5)
  F.shadow(WX - 20, WX + 22, yb, 12, 4)
  F.shadow(36, 50, yb + 2, 6, 2)
  rimOf(union(drum, lip, post, fork, pole, cw), L.timber)
  part(drum, L.stone) F.courses(drum, yb - 16, 5, 9, L.stone)
  drum:each(function(x, y) if x > WX + 12 then px(x, y, L.stone.shade) end end)
  part(lip, L.stone, { nopop = true })
  lip:edge():each(function(x, y) if y < yb - 16 then px(x, y, L.stone.hi) end end)
  fill(hole, PW.edge) hline(WX - 14, WX + 6, yb - 16, PW.deep) px(WX - 8, yb - 16, PW.shade)
  for x = WX - 22, WX + 22 do if hash(x, 7, 61) < .45 then px(x, yb, moss.base) px(x, yb - 1, moss.hi) end end
  part(post, L.timber, { nopop = true }) vline(43, 147, yb + 1, L.timber.hi)
  part(fork, L.timber, { nopop = true, noshade = true })
  part(pole, L.board, { nopop = true, noshade = true })
  line({ { 20, 169 }, { WX + 4, 117 } }):each(function(x, y) if pole:has(x, y) then px(x, y, L.board.hi) end end)
  px(44, 151, L.iron.hi) px(44, 152, L.iron.shade) -- the pin
  -- the counterweight: a lump of tufa lashed with rope
  part(cw, tufa) px(17, 169, tufa.hi) px(18, 169, tufa.hi) px(22, 175, tufa.deep)
  vline(20, 167, 177, L.reed.deep) hline(15, 25, 172, L.reed.deep)
  -- the rope and the bucket coming up, dripping peat-brown water
  local bx = WX + 4
  vline(bx, 119, 170, L.reed.shade)
  for y = 121, 168, 4 do px(bx, y, L.reed.deep) end
  local bk = poly{ { bx - 5, 170 }, { bx + 5, 170 }, { bx + 4, 179 }, { bx - 4, 179 } }
  c:rim(bk, L.timber.edge) part(bk, L.board) F.planks(bk, L.board, 3, true, 7)
  hline(bx - 5, bx + 5, 172, L.iron.shade) hline(bx - 4, bx + 4, 177, L.iron.shade) hline(bx - 4, bx + 4, 170, PW.hi)
  c:ellipse(bx, 167, 5, 3):edge():each(function(x, y) if y < 168 then px(x, y, L.iron.base) end end)
  px(bx + 3, 182, PW.hi) px(bx - 2, 184, PW.base) px(bx + 1, 186, PW.hi)
  -- the gnome hauling on the rope
  local _, hx, hy = F.gnome(118, 208, { hat = L.awnA, coat = L.accent, arm = "up", flip = true })
  line({ { hx, hy }, { bx, 150 } }):each(function(x, y) px(x, y, L.reed.shade) end)
  -- a pail waiting and a frog on the kerb
  F.frog(70, 188, false)
end
for _, s in ipairs({ { 30, 206, 6 }, { 112, 214, 5 }, { 56, 210, 5 } }) do F.sedge(s[1], s[2], s[3]) end
marigolds(36, 212, 4, 7) robin(24, 210, 8)

---------------------------------------------------------------- road: gnome with two pails on a yoke; the spring sign
F.depth(3)
do
  local x, yb = 262, 212
  F.gnome(x, yb, { hat = L.leaf, coat = L.roof2, arm = "hold" })
  local yoke = line({ { x - 16, yb - 12 }, { x, yb - 14 }, { x + 16, yb - 12 } }, 2)
  c:rim(yoke, L.timber.edge) part(yoke, L.board, { nopop = true, noshade = true })
  for _, sx in ipairs({ -16, 16 }) do
    vline(x + sx, yb - 11, yb - 6, L.reed.shade)
    local p = poly{ { x + sx - 5, yb - 6 }, { x + sx + 5, yb - 6 }, { x + sx + 4, yb + 2 }, { x + sx - 4, yb + 2 } }
    c:rim(p, L.timber.edge) part(p, L.board) hline(x + sx - 5, x + sx + 5, yb - 4, L.iron.shade) hline(x + sx - 4, x + sx + 4, yb - 6, PW.hi)
    px(x + sx + 3, yb + 4, PW.hi)
  end
  for i = 1, 4 do px(x - 2 + (i % 2) * 4, yb - 6 - i * 7, L.road.shade) end
end
do -- the spring sign: a drop on a board under a tiny reed hood
  local post = rect(206, 168, 207, 196)
  local bd = rect(194, 156, 220, 170)
  local cap = poly{ { 191, 156 }, { 197, 149 }, { 217, 149 }, { 223, 156 } }
  rimOf(union(post, bd, cap), L.timber) part(post, L.timber, { nopop = true }) part(bd, L.board, { nopop = true }) c:edgeIn(bd, L.board.deep)
  F.planks(bd:shrink(1), L.board, 5, false, 33)
  part(cap, L.roof, { nopop = true }) F.thatch(cap, L.roof, 149, 207) hline(197, 217, 149, L.roof2.base) hline(191, 223, 156, L.roof.deep)
  local drop = poly{ { 207, 158 }, { 211, 164 }, { 203, 164 } }:add(c:ellipse(207, 165, 4, 3))
  c:rim(drop, PW.edge) fill(drop, PW.base) drop:each(function(x, y) if x > 208 then px(x, y, PW.shade) end end)
  px(205, 164, PW.hi) px(205, 165, GL) hline(206, 209, 168, PW.deep)
  F.sedge(204, 197, 5) F.sedge(210, 197, 4)
end

---------------------------------------------------------------- the stall: stoneware jugs and bunches of watercress
F.depth(3)
do
  F.gnome(156, 188, { hat = L.lav, coat = L.awnB, arm = "out", noShadow = true })
  local top = rect(132, 186, 182, 189)
  local legs = rect(135, 190, 136, 200):add(rect(178, 190, 179, 200))
  local cloth = rect(132, 190, 182, 194)
  F.shadow(134, 182, 201, 8, 3)
  rimOf(union(top, legs, cloth), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true }) part(top, L.board, { nopop = true }) hline(132, 182, 186, L.board.hi)
  fill(cloth, L.awnB.base) cloth:each(function(x, y) if ((x - 132) // 4) % 2 == 0 then px(x, y, L.accent.base) end if y == 194 then px(x, y, L.accent.deep) end end)
  for i, jx in ipairs({ 137, 147, 174 }) do
    local big = i % 2 == 1
    local jh = big and 10 or 7
    local jug = c:rrect(jx - 3, 185 - jh, jx + 3, 185, 2):add(rect(jx - 1, 183 - jh, jx + 1, 185 - jh))
    local hnd = c:ellipse(jx + 4, 180 - jh // 2, 2, 2):cut(c:ellipse(jx + 4, 180 - jh // 2, 1, 1))
    c:rim(union(jug, hnd), L.timber.edge) part(jug, L.stone) fill(hnd, L.stone.shade)
    jug:each(function(x, y) if y < 185 - jh + 3 then px(x, y, x < jx and L.soil.base or L.soil.shade) end end) -- brown-dipped neck
    px(jx - 2, 184 - jh, L.soil.hi) px(jx - 2, 182 - jh // 2, L.stone.hi)
  end
  cressBunch(162, 185) cressBunch(167, 185) cressBunch(165, 183)
  local bsk = c:rrect(150, 179, 158, 185, 2) rimOf(bsk, L.reed) part(bsk, L.reed, { nopop = true })
  bsk:each(function(x, y) if (x + y) % 2 == 0 then px(x, y, L.reed.shade) end end)
  px(152, 178, "#6e8c44") px(154, 177, "#9ab25e") px(156, 178, "#4e6a34")
end

---------------------------------------------------------------- right of the causeway: sallows and a gnome with a jug
F.depth(2)
F.bush(278, 150, 14, 12, L.willow, 61) F.bush(298, 146, 10, 10, L.foliage, 62)
F.reeds(286, 300, 152, 10, 63, { cattails = 1 })
F.depth(3)
do
  local _, hx, hy = F.gnome(286, 192, { hat = L.awnA, coat = L.accent, arm = "hold" })
  local jug = c:rrect(hx - 2, hy - 6, hx + 3, hy + 1, 2) c:rim(jug, L.timber.edge) part(jug, L.stone, { nopop = true })
  hline(hx - 2, hx + 3, hy - 6, L.soil.base) px(hx - 1, hy - 4, L.stone.hi)
end
-- the boardwalk from the causeway to the well-head pool, on stakes
do
  local bw = poly{ { 284, 199 }, { 350, 194 }, { 352, 203 }, { 286, 208 } }
  F.shadowM(poly{ { 288, 209 }, { 352, 204 }, { 352, 206 }, { 288, 211 } })
  F.boardwalk(bw, true, 51)
  bw:each(function(x, y) if not bw:has(x, y + 1) then px(x, y, L.board.deep) end end)
  for x = 290, 346, 10 do local y = floor(208 - (x - 286) * 5 / 66) vline(x, y + 1, y + 3, L.timber.base) px(x, y + 3, L.timber.edge) end
end

---------------------------------------------------------------- the lily pool: lilies, bulrushes, a boardwalk, the washer gnome
F.depth(3)
for _, p in ipairs({ { 60, 246, true, "white" }, { 98, 258, true, "white" }, { 124, 246, true }, { 40, 262, false, "yellow" }, { 150, 256, true, "white" },
  { 78, 240, false }, { 30, 250, true }, { 112, 262, false, "yellow" }, { 138, 240, false } }) do F.lily(p[1], p[2], p[3], p[4]) end
F.reeds(18, 46, 248, 22, 82, { cattails = 4, green = true })
do -- the boardwalk across the pool to the washing landing
  local walk = poly{ { 96, 269 }, { 112, 269 }, { 156, 238 }, { 146, 238 } }
  local landing = rect(146, 233, 194, 238)
  F.stilts({ 104, 118, 132, 150, 166, 182, 192 }, 238, 246, 244)
  F.boardwalk(walk, false, 61)
  F.boardwalk(landing, true, 62)
  hline(146, 194, 238, L.board.deep)
  walk:each(function(x, y) if not walk:has(x + 1, y) then px(x, y, L.board.deep) end end)
end
do -- the washer gnome on the landing with a basket of laundry and a washboard
  local _, hx, hy = F.gnome(168, 232, { hat = L.awnB, coat = L.leaf, arm = "out", flip = true, noShadow = true })
  local wb = rect(hx - 6, hy - 6, hx, hy + 4) c:rim(wb, L.timber.edge) part(wb, L.board, { nopop = true })
  for y = hy - 4, hy + 3, 2 do hline(hx - 5, hx - 1, y, L.board.deep) end
  for k = 0, 2 do hline(hx - 12 - k * 2, hx - 6 + k * 2, hy + 14 + k * 2, PW.hi) end
  local bsk = c:rrect(180, 222, 196, 233, 3) rimOf(bsk, L.reed) part(bsk, L.reed)
  bsk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.reed.shade) elseif (x - y) % 4 == 0 then px(x, y, L.reed.hi) end end)
  fill(c:ellipse(185, 221, 4, 2), L.accent.base) fill(c:ellipse(192, 220, 4, 2), L.awnA.base) px(190, 219, L.awnA.hi) px(183, 220, L.accent.hi)
end
-- a moorhen with two chicks on the pool
F.sprite({ "..kk....", ".Ykkk...", "RRkKkkk.", "..kKkKkw", "...kkkww" }, 62, 252,
  { k = "#3e4048", K = "#5c6068", R = L.apple.base, Y = L.marigold.base, w = L.awnB.hi })
for xx = 60, 72 do if hash(xx, 3, 7) < .6 then px(xx, 257, PW.hi) end end
for _, cx in ipairs({ 76, 82 }) do px(cx, 255, "#3e4048") px(cx + 1, 255, "#3e4048") px(cx, 254, "#3e4048") px(cx - 1, 254, L.apple.base) hline(cx - 1, cx + 2, 256, PW.hi) end

---------------------------------------------------------------- marsh flowers round the mound and the rill
F.depth(3)
for _, f in ipairs({ { 292, 216, 12, 1 }, { 452, 216, 14, 2 }, { 470, 222, 12, 1 }, { 228, 214, 10, 1 } }) do iris(f[1], f[2], f[3], f[1], f[4]) end
for i = 0, 8 do
  local x, y = 300 + floor(hash(i, 1, 71) * 160), 218 + floor(hash(i, 2, 71) * 10)
  if not F.roadM:has(x, y) and not brook:grow(3):has(x, y) and not (x >= 380 and y >= 228) then
    if i % 3 == 0 then robin(x, y, i) else marigolds(x, y, 3, i) end
  end
end
-- forget-me-nots by the bench and the stall
for i = 0, 6 do
  local x, y = 110 + floor(hash(i, 1, 72) * 80), 204 + floor(hash(i, 2, 72) * 10)
  if not F.roadM:has(x, y) then
    for k = -2, 2 do px(x + k, y + 1, rg.shade) end
    for _, d in ipairs({ { -2, -1 }, { 1, -2 }, { 2, 0 } }) do px(x + d[1], y + d[2], KF.hi) px(x + d[1] + 1, y + d[2], KF.base) end
  end
end

---------------------------------------------------------------- foreground life: reeds, a barrel on a bog sledge, kingfisher, dragonflies
F.depth(3)
F.reeds(342, 362, 236, 18, 21, { cattails = 2, green = true })
F.reeds(146, 168, 268, 16, 23, { cattails = 2 })
do -- a gnome dragging a water barrel on a bog sledge (wheels would sink)
  local x, yb = 322, 266
  local bar = c:rrect(334, 240, 356, 258, 5)
  local runner = poly{ { 328, 258 }, { 360, 258 }, { 362, 262 }, { 332, 262 }, { 326, 259 } }
  local rope = line({ { 330, 259 }, { 327, 255 } })
  F.shadowM(c:ellipse(346, 264, 18, 1))
  rimOf(union(bar, runner), L.timber)
  part(runner, L.board, { nopop = true }) hline(330, 360, 258, L.board.hi) hline(332, 361, 261, L.timber.deep)
  part(bar, L.timber) F.planks(bar, L.timber, 4, true, 12)
  for _, hy in ipairs({ 243, 254 }) do hline(334, 356, hy, L.iron.shade) hline(335, 355, hy - 1, L.iron.hi) end
  fill(rect(342, 238, 348, 239), PW.base) px(343, 238, PW.hi)
  for _, p in ipairs({ { 351, 237 }, { 354, 236 }, { 358, 239 }, { 360, 243 }, { 338, 237 } }) do px(p[1], p[2], CL.hi) end
  rope:each(function(xx, yy) px(xx, yy, L.reed.shade) end)
  F.gnome(x, yb, { hat = L.roof2, coat = L.wall2, arm = "out" })
  for k = 0, 5 do px(312 - k * 6, 262 + (k % 2), peat.shade) end -- sledge track in the mud
end
-- a kingfisher on the culvert rail
F.sprite({ ".bb...", "kbbB..", "OOBBbb", ".OOBb.", "..ll.." }, floor(F.xr(230)) + 2, 212,
  { b = KF.base, B = KF.shade, k = L.timber.edge, O = L.produce.base, l = L.apple.base })
px(floor(F.xr(230)) + 3, 212, KF.hi) px(floor(F.xr(230)) + 3, 214, L.produce.hi)
-- dragonflies over the water
F.dragonfly(296, 220, KF) F.dragonfly(176, 240, L.apple, true) F.dragonfly(120, 232, L.accent)
F.dragonfly(64, 228, L.marigold, true) F.dragonfly(364, 222, L.lav) F.dragonfly(438, 226, KF, true)
-- low mist on the far edge of the lily pool
for y = 236, 240 do for x = 22, 140 do if hash(x // 9, y, 93) < .35 and (x + y) % 2 == 0 and brook:has(x, y) then px(x, y, y % 2 == 0 and L.mist or L.mist2) end end end

F.depth(0)
F.birds({ { 330, 44, 2 }, { 340, 50, 1 }, { 168, 60, 2 }, { 186, 54, 2 }, { 236, 70, 1 }, { 410, 52, 2 }, { 418, 56, 2 }, { 426, 60, 2 } })
F.finish()
