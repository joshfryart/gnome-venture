-- spring.lua : "Spring" stop look, RAINFOREST (rainforest_canopy), 480x270 gate view.
-- Same composition, hotspots and story as the Maplewold spring (art-2701-batch4/stops/opus3/spring.lua) and the forest
-- spring, re-cast for a jungle: Right hero: a dark columnar basalt cliff under the canopy, draped in moss, ferns and
-- hanging vines; a waterfall pours from a notch in its top into a jade plunge pool rimmed with wet boulders, throwing
-- up spray. Set into the cliff is an old overgrown temple stone carved as a gnome head, strangler-fig roots over it;
-- a bamboo spout from its mouth pours into the pool, a second bamboo spout drips into a gnome's bamboo pail. The pool
-- overflows into a brook that winds down-left, under a bamboo-railed bridge on the road, into a lotus pond bottom-left
-- (an egret wading, a gnome doing the washing). Left: a bamboo well-head under palm thatch with a gnome winding the
-- bucket up, pale figs (a sloth hanging from one) and a stilt hut. A gnome carries two bamboo water tubes on a yoke,
-- another hauls a clay water urn on a cart, a jug stall sells clay jugs and green coconuts. Road's end: a stilt hut
-- and a two-tier thatched shrine. Kingfisher on the bridge rail, poison-dart frogs, dragonflies, light shafts.
-- Quirk: a big green frog in a red gnome hat sits on a lotus pad in the pool, eyes shut, showering under the spout.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-rainforest-stops/"
local F = dofile(DIR .. "_frame.lua")
  .build{ name = "spring", out = DIR, farTrees = { 22, 60, 104, 150, 330, 372, 452 }, treeLineGap = { 188, 290 },
    clouds = { { 130, 42, 40 }, { 290, 30, 46 }, { 404, 58, 30 }, { 30, 82, 24 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local mix = F.mix
local Wt = L.water
local GL = "#e6f4e2"   -- water glint / foam
local FOAM = "#d4ece0"
local moss = L.moss
local rock = F.rp("#a8bcae #7a9286 #587066 #3c5250 #24343a")  -- dark wet columnar basalt
local carve = F.rp("#d8d4a2 #b0ac7e #888a64 #62684e #3e4636") -- weathered temple sandstone, green-stained
local clay = F.rp("#f0b07c #d0804e #a65a38 #763c2c #4a2420")   -- terracotta
local nut = F.rp("#d6e47a #a8c450 #7c9a3a #56702e #344820")    -- green coconut

-- a vertical bamboo tube vessel (a culm section, open top, node band); returns its mask
local function tube(x0, yTop, w, h, water)
  local m = rect(x0, yTop, x0 + w, yTop + h)
  rimOf(m, L.bamboo)
  m:each(function(x, y)
    local k = x - x0
    local col = k == 0 and L.bamboo.hi or (k >= w - 1 and L.bamboo.shade or L.bamboo.base)
    if y == yTop + h - 2 or y == yTop + 2 then col = L.bamboo.deep end
    px(x, y, col)
  end)
  if water then hline(x0 + 1, x0 + w - 1, yTop, Wt.hi) px(x0 + 1, yTop, GL) end
  return m
end
-- a bamboo pipe from a to b, w px thick, nodes every 7 px, an open cut end at b
local function pipe(a, b, w)
  local m = line({ a, b }, w)
  rimOf(m, L.timber)
  local dx, dy = b[1] - a[1], b[2] - a[2]
  local len = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / len, dx / len
  m:each(function(x, y)
    local along = ((x - a[1]) * dx + (y - a[2]) * dy) / len
    local across = (x - a[1]) * nx + (y - a[2]) * ny
    local col = across < -w * .2 and L.bamboo.hi or (across > w * .25 and L.bamboo.shade or L.bamboo.base)
    if floor(along) % 7 == 0 then col = L.bamboo.deep end
    px(x, y, col)
  end)
  px(b[1], b[2], L.bamboo.edge) px(b[1], b[2] - 1, L.soil.deep)
  return m
end
-- a wet faceted boulder (pool rim / foreground): 6 facets lit from the upper left, moss cap, wet glints
local function boulder(x, y, rx, ry, seed, r)
  r = r or rock
  local pts = {}
  for i = 0, 11 do
    local a = i / 12 * 2 * pi
    local k = .84 + .2 * hash(i, seed, 3)
    pts[#pts + 1] = { x + cos(a) * rx * k, y + sin(a) * ry * k }
  end
  local m = poly(pts)
  rimOf(m, r)
  local off = hash(seed, 1, 2) * 2 * pi
  m:each(function(xx, yy)
    local nx, ny = (xx - x) / rx, (yy - y) / ry
    local rr = math.sqrt(nx * nx + ny * ny)
    local sec = floor(((math.atan(ny, nx) + off) % (2 * pi)) / (2 * pi) * 6)
    local ca = sec / 6 * 2 * pi + pi / 6 - off
    local lit = rr < .4 and (.3 - (nx * .6 + ny * .8) * .4) or (-(cos(ca) * .6 + sin(ca) * .8) * math.min(1, rr * 1.2))
    lit = lit + (hash(xx // 2, yy // 2, seed) - .5) * .25
    local h = lit > .55 and r.hi or (lit > .1 and r.base or (lit > -.4 and r.shade or r.deep))
    if hash(xx, yy, seed) > .97 then h = r.deep end
    px(xx, yy, h)
  end)
  m:each(function(xx, yy)
    local ny = (yy - y) / ry
    if ny < -.35 + .25 * sin(xx * .9 + seed) and (xx - x) / rx < .6 then
      px(xx, yy, not m:has(xx, yy - 1) and moss.edge or (hash(xx, yy, 9) < .2 and moss.hi or moss.base))
    end
  end)
  F.shine(m, .14, seed)
  return m
end

---------------------------------------------------------------- back row: a stilt hut and a two-tier shrine at the road's end
F.depth(1)
do
  local st = HP.mask()
  for _, sx in ipairs({ 199, 211, 224 }) do st:add(rect(sx, 118, sx + 1, 128)) end
  F.shadow(198, 228, 129, 6, 2)
  rimOf(st, L.timber) part(st, L.bamboo, { nopop = true })
  F.building{ x0 = 196, x1 = 228, yb = 118, wh = 12, rh = 12, wall = L.plaster, roof = L.roof, noFrame = true, noAttic = true, noShadow = true }
  local deck = rect(194, 118, 230, 119) rimOf(deck, L.timber) part(deck, L.bamboo, { nopop = true, noshade = true })
  F.window(204, 109, 208, 112, L.timber)
  F.door(216, 108, 221, 117, L.timber)
end
F.smoke(212, 92, 4, .5, 2)
do -- a little two-tier palm-thatched shrine with a gold finial right of the road
  local base = rect(255, 114, 277, 126)
  local tower = rect(261, 94, 271, 106)
  local roof1 = poly{ { 249, 117 }, { 266, 104 }, { 283, 117 } }:add(poly{ { 247, 118 }, { 250, 113 }, { 253, 117 } }):add(poly{ { 285, 118 }, { 282, 113 }, { 279, 117 } })
  local roof2 = poly{ { 256, 99 }, { 266, 85 }, { 276, 99 } }:add(poly{ { 254, 100 }, { 256, 96 }, { 259, 99 } }):add(poly{ { 278, 100 }, { 276, 96 }, { 273, 99 } })
  local fin = rect(266, 78, 266, 85)
  rimOf(union(base, tower, roof1, roof2, fin), L.timber)
  part(base, L.bamboo) F.bambooWall(base, L.bamboo, 3, false, 24)
  part(tower, L.board, { nopop = true }) F.bambooWall(tower, L.board, 3, false, 25)
  fill(c:rrect(264, 96, 268, 102, 1), L.glow.shade) px(265, 97, L.glow.base)
  part(roof1, L.roof2, { nopop = true }) F.palmThatch(roof1, L.roof2, 104, 266, 26)
  part(roof2, L.roof2, { nopop = true }) F.palmThatch(roof2, L.roof2, 85, 266, 27)
  for x = 249, 283 do if hash(x, 1, 28) < .7 then px(x, 118, L.roof2.deep) end end
  vline(266, 78, 84, L.gold.base) px(266, 77, L.gold.hi) px(265, 80, L.gold.hi) px(267, 80, L.gold.shade) px(266, 82, L.gold.shade)
  F.window(263, 118, 268, 123, L.timber, true)
end
F.tree(300, 128, 28, 3)
F.palm(186, 128, 32, 6, { lean = -4 })
F.fenceP(120, 132, 182, 127, 6)

---------------------------------------------------------------- mid left: a stilt hut, pale figs, a palm, bamboo
F.depth(2)
F.bamboo(14, 160, 58, 4, 37)
do
  local st = HP.mask()
  for _, sx in ipairs({ 26, 39, 54, 67 }) do st:add(rect(sx, 128, sx + 1, 140)) end
  F.shadow(22, 70, 141, 8, 3)
  rimOf(st, L.timber) part(st, L.bamboo, { nopop = true })
  st:each(function(x, y) if y % 6 == 0 then px(x, y, L.bamboo.deep) end end)
  F.building{ x0 = 24, x1 = 70, yb = 128, wh = 20, rh = 18, wall = L.plaster, roof = L.roof, noShadow = true, noAttic = true }
  local deck = rect(20, 128, 74, 130) rimOf(deck, L.timber) part(deck, L.timber, { nopop = true }) F.bambooWall(deck, L.bamboo, 2, true, 38)
  F.window(30, 114, 35, 119, L.timber) F.door(50, 116, 57, 127, L.timber)
  local lad = line({ { 58, 140 }, { 56, 131 } }):add(line({ { 63, 140 }, { 61, 131 } }))
  for y = 133, 139, 3 do lad:add(rect(57, y, 62, y)) end
  rimOf(lad, L.timber) part(lad, L.bamboo, { nopop = true, noshade = true })
  -- orchids in a coconut-shell pot hung by the window, a fern at the stilts
  vline(38, 109, 112, L.needle.deep) fill(c:ellipse(38, 114, 2, 2), L.soil.base) px(37, 113, L.soil.hi)
  px(37, 111, L.orchid.hi) px(39, 111, L.orchid.base) px(38, 110, L.orchid.hi)
  F.fern(32, 142, 4) F.fern(68, 142, 4)
end
F.smoke(47, 86, 6, .5, 2)
F.birch(92, 150, 56, 31)
F.washing(70, 112, 91, 116, { { "shirt", L.awnA }, { "sock", L.accent }, { "trousers", L.lav } }, 3)
F.birch(160, 140, 44, 33)
F.tree(124, 146, 40, 6)
do -- a sloth hugging the fig's trunk, peering round at the road
  F.sprite({
    "...BBB...",
    "..BfffB..",
    ".BkkfkkB.",
    ".BffnffB.",
    "..BfffB..",
    "cBBBBBBBc",
    "cbBBBBBbc",
    "..BBBBB..",
    "..BbBbB..",
    "..BBBBB..",
    ".cB...Bc.",
  }, 156, 116, { c = L.timber.edge, B = L.palmTrunk.base, b = L.palmTrunk.shade, f = L.plaster.hi, k = L.timber.deep, n = L.timber.edge })
end

---------------------------------------------------------------- right hero: the basalt cliff under the canopy
F.depth(2)
F.tree(446, 128, 70, 1)
F.palm(338, 126, 46, 5, { lean = -8 })
F.conifer(404, 106, 40, L.foliage2, 55)
F.treeFern(316, 140, 26, 56)
F.depth(3)
local bumps = {
  { 312, 158, 22, 22, 41 }, { 340, 128, 26, 24, 42 }, { 384, 112, 30, 20, 43 }, { 456, 118, 20, 22, 44 },
  { 458, 160, 18, 30, 45 }, { 300, 194, 14, 16, 46 }, { 418, 108, 10, 10, 51 },
}
local rockM = HP.mask()
for _, b in ipairs(bumps) do
  local pts = {}
  for i = 0, 13 do
    local a = i / 14 * 2 * pi
    local k = .82 + .2 * hash(i, b[5], 3)
    pts[#pts + 1] = { b[1] + cos(a) * b[3] * k, b[2] + sin(a) * b[4] * k }
  end
  rockM:add(poly(pts))
end
local mass = poly{ { 294, 212 }, { 298, 172 }, { 312, 132 }, { 346, 106 }, { 388, 96 }, { 420, 102 }, { 448, 98 }, { 466, 108 }, { 470, 212 } }
rockM:add(mass)
rockM:clip(rect(0, 0, 470, 212))
F.shadowM(c:ellipse(382, 214, 92, 5))
rimOf(rockM, rock)
-- columnar basalt: leaning vertical columns ~8 px, each lit on its left face, broken by joints; the cliff darkens
-- toward the lower right, wet glints on the column lips
rockM:each(function(x, y)
  local sx = x + floor((y - 96) * .14)
  local ci, k = sx // 8, sx % 8
  local per = 14 + floor(hash(ci, 2, 5) * 18)
  local ry = (y + floor(hash(ci, 1, 5) * 13)) % per
  local t
  if k == 0 then t = 4 elseif k == 1 then t = 0 elseif k <= 3 then t = 1 elseif k <= 5 then t = 2 else t = 3 end
  local g = (y - 96) / 116 * .7 + (x - 296) / 174 * .5
  if g > .75 and t < 3 and hash(x, y, 6) < .7 then t = t + 1 end
  if g < .3 and t > 1 and t < 4 and hash(x, y, 7) < .5 then t = t - 1 end
  local seg = (y + floor(hash(ci, 1, 5) * 13)) // per
  if ry == 0 then t = k == 0 and 4 or 3 elseif ry == 1 and k <= 3 and hash(ci, seg, 4) < .5 then t = 0 end
  if hash(x, y, 8) > .975 then t = 4 end
  local col = ({ rock.hi, rock.base, rock.shade, rock.deep, rock.edge })[t + 1]
  if t == 0 and hash(x, y, 9) < .12 then col = L.wet end
  px(x, y, col)
end)
-- moss: thick cushions along the cliff top and on ledges (ragged hanging lower edge), damp patches down the face
local topBand = HP.mask()
rockM:each(function(x, y)
  local d = 2 + floor(hash(x // 2, 1, 11) * 4)
  for q = 1, d do if not rockM:has(x, y - q) then topBand:set(x, y) return end end
end)
topBand:each(function(x, y)
  local edge = not rockM:has(x, y - 1)
  px(x, y, edge and moss.hi or (topBand:has(x, y + 1) and (hash(x, y, 12) < .3 and moss.hi or moss.base) or moss.shade))
  if not topBand:has(x, y + 1) and hash(x, 2, 13) < .4 then px(x, y + 1, moss.deep) end
end)
rockM:each(function(x, y)
  local v = hash(x // 4, y // 3, 14)
  if v < .08 and y > 116 and hash(x, y, 15) < .75 - ((y % 3) * .2) then px(x, y, rockM:has(x, y - 1) and hash(x, y, 16) < .7 and moss.shade or moss.base) end
  if v > .98 and hash(x, y, 17) < .4 then px(x, y, moss.hi) end
end)
-- ledges sprouting ferns and bromeliads
for i, p in ipairs({ { 322, 150 }, { 342, 132 }, { 300, 186 }, { 452, 140 }, { 464, 176 }, { 408, 124 }, { 330, 180 } }) do
  F.fern(p[1], p[2], 5 + i % 3, i % 2 == 0 and L.fern or L.vine)
end
for _, p in ipairs({ { 314, 168 }, { 460, 152 }, { 350, 120 } }) do
  local x, y = p[1], p[2]
  px(x, y, L.helic.base) px(x - 1, y - 1, L.helic.hi) px(x + 1, y - 1, L.helic.shade) px(x - 2, y - 2, L.leaf.base) px(x + 2, y - 2, L.leaf.shade) px(x, y + 1, L.vine.deep)
end

-- the old temple stone set into the cliff, carved as a gnome head; strangler-fig roots over it
local face = rect(350, 124, 404, 188)
local HX, HY = 377, 154
do
  local slab = face:copy():cut(c:rrect(350, 124, 356, 130, 4)) -- a broken corner
  rimOf(slab, carve)
  part(slab, carve, { inner = false })
  F.courses(slab, 124, 9, 15, carve, 3)
  c:edgeIn(slab, carve.edge)
  slab:each(function(x, y)
    if (x - 350) + (y - 124) > 70 and hash(x, y, 21) < .5 then px(x, y, carve.shade) end      -- darker lower right
    if hash(x // 3, y // 2, 22) < .08 then px(x, y, moss.base) end                                -- moss in the joints
    if hash(x, y, 23) < .015 then px(x, y, "#c8c070") end                                        -- lichen
  end)
  -- a deep arched niche the head is carved in, with a ring of voussoirs
  local niche = c:rrect(HX - 19, 129, HX + 19, 184, 14):clip(rect(HX - 19, 129, HX + 19, 184))
  fill(niche, rock.deep) c:edgeIn(niche, carve.edge)
  niche:each(function(x, y) if (x - HX) + (y - 156) < -18 then px(x, y, rock.shade) end if hash(x, y, 27) < .05 then px(x, y, rock.edge) end if y > 178 and hash(x, y, 28) < .4 then px(x, y, moss.shade) end end)
  c:rrect(HX - 21, 127, HX + 21, 186, 16):clip(rect(HX - 21, 127, HX + 21, 184)):cut(c:rrect(HX - 19, 129, HX + 19, 186, 14)):each(function(x, y)
    px(x, y, (math.atan(y - 156, x - HX) * 5 // 1) % 2 == 0 and carve.hi or carve.base) end)
  -- a carved lotus band along the top
  for x = 356, 400, 6 do px(x, 127, carve.deep) px(x + 1, 126, carve.deep) px(x + 2, 127, carve.deep) px(x + 1, 128, carve.hi) end
  -- the head
  local hat = poly{ { HX - 14, HY - 8 }, { HX + 14, HY - 8 }, { HX + 7, HY - 22 }, { HX + 12, HY - 27 }, { HX + 2, HY - 26 }, { HX - 6, HY - 18 } }
  local fc = c:rrect(HX - 12, HY - 9, HX + 12, HY + 3, 4)
  local beard = poly{ { HX - 13, HY - 1 }, { HX + 13, HY - 1 }, { HX + 10, HY + 13 }, { HX, HY + 20 }, { HX - 10, HY + 13 } }
  c:rim(union(hat, fc, beard), carve.edge)
  part(fc, carve, { nopop = true }) part(beard, carve, { nopop = true }) part(hat, carve, { nopop = true })
  fc:each(function(x, y) px(x, y, (x - HX) + (y - HY) < 4 and carve.hi or carve.base) end)
  hat:each(function(x, y) px(x, y, (x - HX) < (HY - y) * .3 - 3 and carve.base or carve.shade) end)
  hat:edge():each(function(x, y) if x - HX < 2 then px(x, y, carve.hi) end end)
  beard:each(function(x, y)
    local col = (x - HX) < -2 and carve.base or carve.shade
    if (x + 2 * y) % 5 == 0 and y > HY + 1 then col = carve.deep end
    px(x, y, col)
  end)
  hline(HX - 14, HX + 14, HY - 8, carve.edge) hline(HX - 13, HX + 13, HY - 9, carve.hi) hline(HX - 13, HX + 13, HY - 10, carve.deep)
  for _, ex in ipairs({ HX - 6, HX + 6 }) do px(ex - 2, HY - 4, carve.edge) px(ex - 1, HY - 3, carve.edge) px(ex, HY - 3, carve.edge) px(ex + 1, HY - 3, carve.edge) px(ex + 2, HY - 4, carve.edge) hline(ex - 2, ex + 2, HY - 6, carve.deep) end
  px(HX - 9, HY - 1, "#e0a088") px(HX + 9, HY - 1, carve.shade) -- a trace of old pink paint on the cheek
  local nose = c:ellipse(HX, HY - 1, 4, 3) c:rim(nose, carve.deep) part(nose, carve, { nopop = true }) px(HX - 2, HY - 3, carve.hi) px(HX - 1, HY - 3, carve.hi)
  fill(c:ellipse(HX, HY + 5, 3, 2), carve.edge) px(HX - 1, HY + 4, rock.edge)
  -- moss on the hat brim and tip, a bromeliad in the hat's fold, green water stains under the eyes
  for x = HX - 4, HX + 9 do px(x, HY - 21 + floor(abs(x - HX - 2) * .6), moss.base) px(x, HY - 22 + floor(abs(x - HX - 2) * .6), moss.hi) end
  for x = HX - 13, HX + 13 do if hash(x, 3, 24) < .5 then px(x, HY - 7, moss.base) end end
  for _, ex in ipairs({ HX - 7, HX + 7 }) do for y = HY - 2, HY + 4 do if hash(ex, y, 25) < .6 then px(ex, y, carve.shade) end end end
  px(HX + 10, HY - 26, L.helic.base) px(HX + 9, HY - 27, L.helic.hi) px(HX + 11, HY - 27, L.helic.shade) px(HX + 8, HY - 26, L.leaf.base) px(HX + 12, HY - 26, L.leaf.shade)
  -- strangler-fig roots creeping down both sides of the stone
  local roots = HP.mask()
  for i, r0 in ipairs({ { 354, 118, 66 }, { 360, 120, 22 }, { 398, 116, 70 }, { 392, 118, 26 }, { 403, 120, 40 } }) do
    local x0, y0, len = r0[1], r0[2], r0[3]
    local pts = {}
    for k = 0, len, 4 do pts[#pts + 1] = { x0 + sin(k / 9 + i) * 3 + (i % 2 == 0 and k * .12 or -k * .04), y0 + k } end
    roots:add(line(pts, i <= 3 and 2 or 1))
  end
  roots:add(line({ { 354, 150 }, { 346, 156 } }, 1)):add(line({ { 399, 160 }, { 408, 166 } }, 1))
  rimOf(roots, L.birch)
  roots:each(function(x, y) px(x, y, roots:has(x - 1, y) and (roots:has(x + 1, y) and L.birch.base or L.birch.shade) or L.birch.hi) if hash(x, y // 3, 26) < .12 then px(x, y, moss.base) end end)
end
-- vines hanging off the cliff top and over the stone
F.vines(topBand, .05, 31, 26)
for _, v in ipairs({ { 352, 122, 18 }, { 366, 120, 9 }, { 401, 121, 20 } }) do F.vine(v[1], v[2], v[3], v[1], nil, L.orchid) end

-- jungle overhanging the cliff top: leafy clumps breaking its line, vines and an orchid spray dropping from them
for i, b in ipairs({ { 308, 138, 9, 5 }, { 330, 117, 13, 6 }, { 360, 104, 15, 6 }, { 396, 99, 13, 5 }, { 458, 104, 11, 6 } }) do
  local m = F.crown(b[1], b[2], b[3], b[4], i % 2 == 0 and L.foliage or L.leaf, 100 + i)
  F.vines(m, .1, 110 + i, 14)
end
F.orchid(372, 108, L.orchid, 3) F.orchid(338, 122, L.petal, 2, true)
-- two big mossy boulders at the cliff's foot, left of the pool
boulder(300, 196, 14, 14, 59) boulder(330, 192, 18, 14, 60)
-- the bamboo spout from the mouth, and its stream onto the frog
pipe({ HX + 2, HY + 5 }, { HX + 26, HY + 15 }, 3)
local function lashing(x, y) px(x, y, L.needle.base) px(x, y + 1, L.needle.shade) px(x + 1, y, L.needle.hi) end
lashing(HX + 6, HY + 5)
do -- a forked bamboo prop holding the spout end
  local prop = line({ { HX + 20, HY + 14 }, { HX + 18, 196 } }, 1) rimOf(prop, L.timber) fill(prop, L.bamboo.shade)
  for y = HY + 17, 196, 6 do px(HX + 19 - (y - HY) // 20, y, L.bamboo.deep) end
end
for y = HY + 15, 184 do
  local x = HX + 27 + floor((y - HY - 15) * .15)
  px(x, y, Wt.base) px(x + 1, y, (y % 3 == 0) and GL or Wt.hi) px(x + 2, y, Wt.shade)
end

-- the second bamboo spout: a trickle from a seep in the cliff into a gnome's bamboo pail
pipe({ 346, 162 }, { 335, 172 }, 2)
fill(line({ { 348, 160 }, { 352, 156 } }, 2), rock.edge)
for y = 174, 202 do px(334, y, ((y // 2) % 2 == 0) and Wt.hi or Wt.base) end
do
  local _, hx, hy = F.gnome(318, 218, { hat = L.awnA, coat = L.lav, arm = "out" })
  tube(hx + 1, hy - 7, 8, 10, true)
  px(hx + 3, hy - 9, Wt.hi) px(hx + 6, hy - 8, GL)
  c:ellipse(hx + 5, hy - 11, 5, 4):edge():each(function(x, y) if y < hy - 10 then px(x, y, L.needle.shade) end end) -- rattan handle
end

---------------------------------------------------------------- the waterfall from the cliff's notch
local fall = poly{ { 423, 100 }, { 445, 100 }, { 449, 140 }, { 452, 196 }, { 414, 196 }, { 418, 140 } }
do
  -- dark wet rock right behind the falling water
  local wet = fall:grow(2):cut(fall):clip(rockM)
  fill(wet, rock.edge) wet:each(function(x, y) if hash(x, y, 41) < .2 then px(x, y, rock.deep) end end)
  local x0, _, x1 = fall:bbox()
  fall:each(function(x, y)
    local ph = floor(hash(x, 0, 42) * 30)
    local col
    local s = hash(x, (y + ph) // (6 + floor(hash(x, 1, 42) * 10)), 43)
    if s < .32 then col = Wt.hi elseif s < .5 then col = GL elseif s < .8 then col = Wt.base else col = Wt.shade end
    local lft = not fall:has(x - 1, y) or not fall:has(x - 2, y)
    local rgt = not fall:has(x + 1, y) or not fall:has(x + 2, y)
    if lft then col = (y % 3 == 0) and Wt.hi or GL end
    if rgt then col = (y % 4 == 0) and Wt.base or Wt.shade end
    if y < 104 then col = (x % 2 == 0) and GL or Wt.hi end -- the lip: smooth bright water pouring over
    px(x, y, col)
  end)
  -- a ledge half way down breaks it: a foamy collar, a lit rock lip poking out on the left
  for x = 416, 450 do if fall:has(x, 140) then px(x, 140, GL) px(x, 141, hash(x, 1, 44) < .6 and FOAM or GL) if hash(x, 2, 44) < .5 then px(x, 139, FOAM) end end end
  local lip = boulder(415, 142, 6, 4, 45)
  -- moss and ferns on the notch shoulders
  F.fern(420, 104, 6, L.fern) F.fern(449, 104, 6, L.vine)
  for x = 414, 456 do if not fall:has(x, 100) and rockM:has(x, 101) then px(x, 100, moss.hi) end end
end
-- spray cloud at the foot: a ring of foam lumps and humid mist, dithered (every pixel opaque)
do
  local spray = c:ellipse(433, 194, 26, 9)
  spray:each(function(x, y)
    local d = ((x - 433) / 26) ^ 2 + ((y - 194) / 9) ^ 2
    local n = hash(x // 3, y // 2, 46)
    if d < .35 then px(x, y, n < .5 and GL or FOAM)
    elseif d < .7 and (x + y) % 2 == 0 then px(x, y, n < .5 and L.mist2 or FOAM)
    elseif d < 1 and (x + y) % 4 == 0 and n < .6 then px(x, y, L.mist) end
  end)
  for i = 0, 18 do px(410 + floor(hash(i, 1, 47) * 48), 172 + floor(hash(i, 2, 47) * 18), i % 3 == 0 and L.mist2 or GL) end
end

---------------------------------------------------------------- the plunge pool, its rim of wet boulders, the frog
F.depth(3)
local BX, BY = 398, 203
local pool = c:ellipse(BX, BY, 56, 10):clip(rect(0, 0, 469, 269))
do
  local rimRing = pool:grow(2):cut(pool)
  rimRing:each(function(x, y) px(x, y, hash(x, y, 51) < .5 and rock.base or moss.base) end)
  F.water(pool, Wt)
  -- dark reflections of the cliff, foam rings spreading from the falls, the spout's ripple
  pool:each(function(x, y)
    if y < BY - 4 and hash(x // 4, 0, 52) < .5 then px(x, y, Wt.shade) end
    local d = math.sqrt(((x - 433) / 2.6) ^ 2 + (y - 197) ^ 2)
    if floor(d) % 4 == 0 and d < 14 and hash(x, y, 53) < .7 then px(x, y, FOAM) end
  end)
  for _, r in ipairs({ 3, 6 }) do c:ellipse(404, 201, r * 2, r // 2 + 1):edge():each(function(x, y) if pool:has(x, y) then px(x, y, Wt.hi) end end) end
  -- boulders on the near rim (keeping clear of the compass corner)
  boulder(344, 210, 9, 6, 54) boulder(362, 214, 8, 4, 55) boulder(420, 214, 11, 5, 56) boulder(452, 210, 11, 7, 57) boulder(470, 200, 8, 10, 58)
end
-- QUIRK: the frog in a red gnome hat on a lotus pad, eyes shut, under the spout's shower
do
  local pad = c:ellipse(406, 202, 11, 3):cut(poly{ { 406, 202 }, { 418, 199 }, { 418, 204 } })
  c:rim(pad, L.leaf.edge) fill(pad, L.leaf.base)
  pad:each(function(x, y) if not pad:has(x, y - 1) then px(x, y, L.leaf.hi) elseif not pad:has(x, y + 1) then px(x, y, L.leaf.deep) elseif (x - 406) % 4 == 0 then px(x, y, L.leaf.shade) end end)
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
    "oGgyyyyyyyyygdGo",
    "GoGgyyyyyyygdGoG",
    ".dd.ddd..ddd.dd.",
  }, 398, 184, { R = L.awnA.base, r = L.awnA.shade, H = L.awnA.hi, b = L.gold.hi, G = L.leaf.base, g = L.leaf.shade,
    d = L.leaf.deep, e = L.leaf.deep, k = L.timber.edge, m = L.apple.shade, y = L.roof.hi, o = L.produce.base })
  for _, p in ipairs({ { 409, 181 }, { 404, 183 }, { 413, 182 }, { 401, 186 }, { 416, 187 }, { 411, 178 } }) do px(p[1], p[2], Wt.hi) end
  px(406, 180, GL) px(414, 180, GL)
  -- a pink lotus open beside him
  F.sprite({ ".p.p.", "pPhPp", ".pPp.", "..g.." }, 384, 197, { p = L.petal.base, P = L.petal.hi, h = L.gold.hi, g = L.leaf.deep })
end
-- a blue poison-dart frog on a rim boulder, a golden one on the left boulder
F.sprite({ "k.k.", "BBBB", "BkBB", "b..b" }, 448, 200, { k = L.timber.edge, B = "#4a8ad8", b = "#2c4c9c" })
F.sprite({ "k.k.", "YYYY", "YkYk", "y..y" }, 326, 176, { k = L.timber.edge, Y = L.gold.hi, y = L.gold.shade })

---------------------------------------------------------------- the overflow brook down-left under the road into the pond
local brook = HP.mask()
do
  local pts = { { 348, 208 }, { 336, 218 }, { 316, 226 }, { 296, 232 }, { 270, 238 }, { 240, 242 }, { 210, 244 }, { 180, 247 }, { 150, 250 } }
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local w = 12 + floor(i * 1.6)
    brook:add(line({ a, b }, w))
    brook:add(c:ellipse(b[1], b[2], w // 2, w // 2))
  end
  brook:add(c:ellipse(84, 252, 76, 18):clip(rect(19, 230, 200, 269)))
end
local onRoad = HP.mask()
brook:each(function(x, y) if F.roadM:has(x, y) then onRoad:set(x, y) end end)
brook:cut(onRoad)
do
  local bank = brook:grow(2):cut(brook):cut(F.roadM)
  bank:each(function(x, y) local v = hash(x, y, 51) px(x, y, v < .35 and L.stone.base or (v < .5 and L.wet or (v < .8 and moss.base or L.soil.shade))) end)
  brook:edge():each(function(x, y) if hash(x, y, 52) < .3 then px(x, y, L.stone.hi) end end)
  F.water(brook, Wt, { step = 3 })
  -- canopy reflections in the pond and current lines in the brook
  for _, rx in ipairs({ 44, 70, 132 }) do for k = 0, 5 do hline(rx - 4 + k // 2, rx + 4 - k // 2, 238 + k * 2, Wt.shade) end end
  brook:each(function(x, y)
    if y % 3 == 1 and x > 150 and hash(x // 5, y, 54) < .3 and brook:has(x - 2, y) and brook:has(x + 2, y) and brook:has(x, y + 2) then px(x, y, Wt.hi) end
    if hash(x, y, 55) < .012 and brook:has(x, y - 2) then px(x, y, GL) end
  end)
  for _, s in ipairs({ { 330, 220 }, { 308, 228 }, { 290, 234 }, { 186, 247 } }) do
    local m = c:ellipse(s[1], s[2], 3, 2) rimOf(m, rock) part(m, rock, { nopop = true }) px(s[1] - 1, s[2] - 1, L.wet)
    px(s[1] - 2, s[2] - 2, moss.base)
    for k = 0, 3 do px(s[1] + 3 + k, s[2] - 2 + (k % 2), GL) end hline(s[1] - 4, s[1] - 1, s[2] + 3, Wt.hi)
  end
  for y = 206, 214 do px(348 - (y - 206) // 3, y, Wt.hi) px(349 - (y - 206) // 3, y, GL) end
end
-- the bridge: wet stone abutments with arched mouths, bamboo rails lashed to hardwood posts along both road edges
do
  local Y0, Y1 = 226, 258
  local wallL = poly{ { floor(F.xl(234)) - 22, 236 }, { floor(F.xl(234)) - 4, 230 }, { floor(F.xl(256)) - 4, 258 }, { floor(F.xl(256)) - 24, 258 } }
  local wallR = poly{ { floor(F.xr(226)) + 4, 224 }, { floor(F.xr(226)) + 22, 228 }, { floor(F.xr(244)) + 22, 248 }, { floor(F.xr(244)) + 4, 248 } }
  local walls = union(wallL, wallR)
  rimOf(walls, L.stone)
  part(walls, L.stone, { nopop = true }) F.courses(walls, 236, 4, 8, L.stone) F.moss(walls, .3, 61) F.shine(walls, .1, 62)
  for _, a in ipairs({ { floor(F.xl(244)) - 14, 251, wallL }, { floor(F.xr(236)) + 13, 242, wallR } }) do
    local arch = c:ellipse(a[1], a[2], 7, 9):clip(rect(a[1] - 7, a[2] - 9, a[1] + 7, a[2] + 4)):clip(a[3])
    fill(arch, Wt.edge)
    arch:each(function(x, y) if y > a[2] - 2 then px(x, y, (x + y) % 3 == 0 and Wt.shade or Wt.deep) end end)
    c:ellipse(a[1], a[2], 9, 11):cut(c:ellipse(a[1], a[2], 7, 9)):clip(rect(a[1] - 9, a[2] - 11, a[1] + 9, a[2])):clip(a[3]):each(function(x, y)
      px(x, y, (math.atan(y - a[2], x - a[1]) * 4 // 1) % 2 == 0 and L.stone.hi or moss.base) end)
    for k = 0, 4 do px(a[1] - 4 + k * 2, a[2] + 3, GL) end
    F.vine(a[1] + 6, a[2] - 10, 7, a[1], nil, nil)
  end
  local rails, posts = HP.mask(), HP.mask()
  local function ex(sd, y) return sd < 0 and floor(F.xl(y)) - 3 or floor(F.xr(y) + .99) + 3 end
  for _, sd in ipairs({ -1, 1 }) do
    for y = Y0 - 2, Y1, 8 do posts:add(rect(ex(sd, y) - 1, y - 12, ex(sd, y), y)) end
    for _, h in ipairs({ 10, 5 }) do rails:add(line({ { ex(sd, Y0 - 2), Y0 - 2 - h }, { ex(sd, Y1), Y1 - h } }, 2)) end
  end
  rimOf(union(rails, posts), L.timber)
  part(posts, L.timber, { nopop = true, noshade = true })
  posts:each(function(x, y) if not posts:has(x, y - 1) then px(x, y, L.timber.hi) end end)
  rails:each(function(x, y) px(x, y, (x * 3 + y) % 11 == 0 and L.bamboo.deep or (rails:has(x, y - 1) and L.bamboo.shade or L.bamboo.hi)) end)
  posts:each(function(x, y) if rails:has(x, y) and not rails:has(x, y - 1) then px(x, y, L.needle.base) px(x, y + 1, L.needle.shade) end end)
  -- a kingfisher on the right rail
  F.sprite({ "..BBB.", "kkBwB.", "..OOBb", "..OOBbb", "...ll.." }, floor(F.xr(236)) + 1, 220,
    { B = "#3c9cd0", b = "#24608e", k = L.timber.edge, w = L.awnB.hi, O = L.produce.base, l = L.apple.shade })
end

---------------------------------------------------------------- left: the bamboo well-head under palm thatch, a gnome winding
F.depth(3)
do
  local x0, x1, yb = 52, 104, 204
  local cx = (x0 + x1) // 2
  local wall = c:rrect(x0, yb - 18, x1, yb, 3)
  local postL, postR = rect(x0 + 4, yb - 52, x0 + 7, yb - 18), rect(x1 - 7, yb - 52, x1 - 4, yb - 18)
  local roof = poly{ { x0 - 8, yb - 46 }, { cx, yb - 70 }, { x1 + 8, yb - 46 } }:add(rect(x0 - 8, yb - 47, x1 + 8, yb - 44))
  local axle = rect(x0 + 4, yb - 36, x1 - 4, yb - 34)
  local crank = line({ { x1 - 2, yb - 35 }, { x1 + 4, yb - 35 }, { x1 + 4, yb - 29 } }, 2)
  F.shadow(x0 + 2, x1, yb, 12, 4)
  rimOf(union(wall, postL, postR, roof, axle, crank), L.timber)
  part(wall, L.stone) F.courses(wall, yb - 18, 5, 9, L.stone) F.moss(wall, .28, 63) F.shine(wall, .1, 64)
  hline(x0 + 2, x1 - 2, yb - 18, L.stone.hi)
  for _, p in ipairs({ postL, postR }) do part(p, L.bamboo, { nopop = true }) p:each(function(x, y) if y % 8 == 0 then px(x, y, L.bamboo.deep) elseif y % 8 == 1 then px(x, y, L.shine) end end) end
  part(roof, L.roof, { sep = true }) F.palmThatch(roof, L.roof, yb - 70, cx, 65)
  line({ { x0 - 8, yb - 46 }, { cx, yb - 70 } }):each(function(x, y) if roof:has(x, y) then px(x, y, L.roof.hi) end end)
  for x = x0 - 8, x1 + 8 do local len = 1 + floor(hash(x, 4, 66) * 3) for k = 1, len do px(x, yb - 44 + k, k == len and L.roof.edge or (k == 1 and L.roof.deep or L.roof.shade)) end end
  px(cx, yb - 71, L.bamboo.hi) px(cx - 1, yb - 70, L.bamboo.shade) px(cx + 1, yb - 70, L.bamboo.shade)
  part(axle, L.bamboo, { nopop = true, noshade = true }) for x = x0 + 4, x1 - 4, 7 do vline(x, yb - 36, yb - 34, L.bamboo.deep) end
  fill(rect(cx - 4, yb - 37, cx + 4, yb - 33), L.needle.base) -- palm-fibre rope wound on the axle
  for x = cx - 4, cx + 4, 2 do vline(x, yb - 37, yb - 33, L.needle.shade) end
  part(crank, L.timber, { nopop = true, noshade = true })
  vline(cx, yb - 32, yb - 27, L.needle.deep)
  tube(cx - 4, yb - 26, 8, 9, true)
  px(cx + 3, yb - 14, Wt.hi) px(cx - 2, yb - 12, Wt.base)
  local _, hx, hy = F.gnome(x1 + 14, yb + 4, { hat = L.roof2, coat = L.accent, arm = "up", flip = true })
  fill(line({ { hx, hy }, { x1 + 4, yb - 29 } }), L.skin.base)
  -- a vine with orchids climbing the left post, a heliconia and ferns at the well's foot
  for y = yb - 50, yb - 19 do local vx = x0 + 3 + floor(sin(y / 4) * 1.4 + .5) px(vx, y, L.vine.shade) if y % 4 == 0 then px(vx - 1, y, L.vine.hi) end end
  px(x0 + 2, yb - 40, L.orchid.hi) px(x0 + 3, yb - 40, L.orchid.base) px(x0 + 2, yb - 39, L.orchid.deep)
  F.heliconia(44, 206, 22, 67)
  F.fern(58, 208, 6) F.fern(98, 208, 5, L.vine)
end

---------------------------------------------------------------- road: gnome with two bamboo water tubes on a yoke; the spring sign
F.depth(3)
do
  local x, yb = 262, 212
  F.gnome(x, yb, { hat = L.leaf, coat = L.roof2, arm = "hold" })
  local yoke = line({ { x - 16, yb - 12 }, { x, yb - 14 }, { x + 16, yb - 12 } }, 2)
  c:rim(yoke, L.timber.edge) part(yoke, L.bamboo, { nopop = true, noshade = true })
  for _, sx in ipairs({ -16, 16 }) do
    vline(x + sx, yb - 11, yb - 9, L.needle.deep)
    tube(x + sx - 3, yb - 8, 6, 11, true)
    px(x + sx + 2, yb + 5, Wt.hi)
  end
  for i = 1, 4 do px(x - 2 + (i % 2) * 4, yb - 6 - i * 7, L.road.shade) end
end
do -- the spring sign: a bamboo post, a hardwood board with a blue drop, a leaf roof
  local post = rect(205, 168, 207, 196)
  local bd = rect(194, 156, 220, 170)
  rimOf(union(post, bd), L.timber) part(post, L.bamboo, { nopop = true }) for y = 172, 196, 7 do hline(205, 207, y, L.bamboo.deep) end
  part(bd, L.timber, { nopop = true }) F.planks(bd, L.timber, 4, false, 71) c:edgeIn(bd, L.timber.edge)
  local drop = poly{ { 207, 158 }, { 211, 164 }, { 203, 164 } }:add(c:ellipse(207, 165, 4, 3))
  c:rim(drop, Wt.edge) fill(drop, Wt.base) px(205, 164, Wt.hi) px(205, 165, GL) hline(206, 209, 168, Wt.shade)
  F.bigLeaf(206, 155, 15, -pi * .92, L.leaf, 72, 4, { droop = .25 }) F.bigLeaf(208, 155, 14, -pi * .08, L.foliage, 73, 4, { droop = .3 })
  F.orchid(208, 194, L.orchid, 2)
end

---------------------------------------------------------------- the jug stall: clay jugs, green coconuts, bamboo cups; a seller behind
F.depth(3)
do
  F.gnome(156, 188, { hat = L.lav, coat = L.awnB, arm = "out", noShadow = true })
  local top = rect(132, 186, 182, 189)
  local legs = rect(135, 190, 136, 200):add(rect(178, 190, 179, 200))
  local cloth = rect(132, 190, 182, 195)
  F.shadow(134, 182, 201, 8, 3)
  rimOf(union(top, legs, cloth), L.timber)
  part(legs, L.bamboo, { nopop = true, noshade = true })
  part(top, L.bamboo, { nopop = true }) F.bambooWall(top, L.bamboo, 2, true, 74)
  -- a woven ikat cloth: red, teal and gold diamonds
  cloth:each(function(x, y)
    local d = (abs((x - 132) % 8 - 4) + abs(y - 192))
    local col = d <= 1 and L.gold.base or (d <= 3 and L.awnA.base or L.accent.shade)
    if y == 195 then col = L.awnA.deep end
    if y == 190 then col = L.awnA.shade end
    px(x, y, col)
  end)
  for x = 133, 181, 3 do px(x, 196, L.gold.shade) end -- tassels
  for i, jx in ipairs({ 137, 165, 174 }) do
    local jh = i % 2 == 1 and 10 or 7
    local jug = c:rrect(jx - 3, 185 - jh, jx + 3, 185, 2):add(rect(jx - 1, 183 - jh, jx + 1, 185 - jh))
    local hnd = c:ellipse(jx + 4, 180 - jh // 2, 2, 2):cut(c:ellipse(jx + 4, 180 - jh // 2, 1, 1))
    c:rim(union(jug, hnd), L.timber.edge) part(jug, clay) fill(hnd, clay.shade)
    hline(jx - 3, jx + 3, 182 - jh // 2, L.awnB.base) px(jx - 2, 184 - jh, clay.hi)
    for k = -2, 2, 2 do px(jx + k, 183 - jh // 2, clay.deep) end
  end
  -- green coconuts, one opened with a straw; bamboo cups
  for k, nx in ipairs({ 145, 151 }) do
    local m = c:ellipse(nx, 182, 3, 3) c:rim(m, nut.edge) part(m, nut, { nopop = true }) px(nx - 1, 180, nut.hi)
    if k == 2 then fill(rect(nx - 1, 179, nx + 1, 179), L.awnB.hi) line({ { nx, 179 }, { nx + 2, 174 } }):each(function(x, y) px(x, y, L.awnA.base) end) end
  end
  tube(158, 180, 3, 5, true) tube(184 - 1, 194, 4, 6, true)
end

---------------------------------------------------------------- mid: a mossy log bench under the figs, a far gnome on the road
F.depth(2)
do
  local lg = rect(112, 158, 146, 162) rimOf(lg, L.timber) part(lg, L.redbark, { nopop = true }) F.logs(lg, L.redbark, 158, 5) F.moss(lg, .25, 75)
  F.logEnd(112, 160, 2)
  F.gnome(124, 160, { small = true, hat = L.roof2, coat = L.leaf, arm = "out", noShadow = true })
  F.gnome(136, 160, { small = true, hat = L.accent, coat = L.awnA, flip = true, noShadow = true })
  F.gnome(238, 146, { small = true, hat = L.lav, coat = L.roof, arm = "out" })
  px(248, 139, nut.base) px(248, 140, nut.shade)
  F.fern(110, 166, 4) F.fern(150, 164, 5, L.vine)
end
F.depth(3)
for _, s in ipairs({ { 200, 206 }, { 186, 210 }, { 170, 212 }, { 150, 210 }, { 132, 208 } }) do
  local m = c:ellipse(s[1], s[2], 5, 2) rimOf(m, L.stone) part(m, L.stone, { nopop = true }) px(s[1] - 2, s[2] - 1, L.wet) px(s[1] - 1, s[2] - 1, L.shine)
end

---------------------------------------------------------------- right of the road: heliconias, a gnome with a clay jug
F.depth(2)
F.heliconia(276, 156, 20, 76) F.bigLeaf(292, 150, 14, -pi * .7, L.foliage, 77, 5, { heart = true, stem = { 296, 156 } })
F.depth(3)
do
  local _, hx, hy = F.gnome(286, 192, { hat = L.awnA, coat = L.accent, arm = "hold" })
  local jug = c:rrect(hx - 2, hy - 6, hx + 3, hy + 1, 2) c:rim(jug, L.timber.edge) part(jug, clay, { nopop = true }) px(hx - 1, hy - 5, clay.hi)
end
for i, s in ipairs({ { 292, 206 }, { 306, 202 }, { 322, 204 } }) do
  local m = c:ellipse(s[1], s[2], 5, 2) rimOf(m, L.stone) part(m, L.stone, { nopop = true }) px(s[1] - 2, s[2] - 1, L.wet) F.moss(m, .2, 80 + i)
end

---------------------------------------------------------------- the lotus pond: pads, lotus flowers and seed heads, an egret, the washer
F.depth(3)
local function lotusPad(x, y, rx)
  local m = c:ellipse(x, y, rx, math.max(1, rx // 3)):cut(poly{ { x, y }, { x + rx + 1, y - 2 }, { x + rx + 1, y + 1 } })
  c:rim(m, L.leaf.edge) fill(m, L.leaf.base)
  m:each(function(xx, yy)
    if not m:has(xx, yy - 1) then px(xx, yy, L.leaf.hi) elseif not m:has(xx, yy + 1) then px(xx, yy, L.leaf.deep)
    elseif (xx - x) % 3 == 0 then px(xx, yy, L.leaf.shade) end
  end)
  px(x - 1, y, L.wet)
end
for _, p in ipairs({ { 60, 246, 6 }, { 98, 258, 7 }, { 124, 246, 5 }, { 40, 260, 6 }, { 150, 254, 6 }, { 78, 240, 4 } }) do lotusPad(p[1], p[2], p[3]) end
-- lotus flowers on stalks, a bud, a seed head, two cupped leaves standing out of the water
local function lotus(x, y, h)
  vline(x, y - h, y, L.vine.shade)
  F.sprite({ "..P..", ".pPp.", "pPhPp", ".ppp." }, x - 2, y - h - 4, { p = L.petal.base, P = L.petal.hi, h = L.gold.hi })
end
lotus(66, 246, 7) lotus(104, 256, 9) lotus(46, 258, 5)
vline(132, 240, 246, L.vine.shade) F.sprite({ ".P.", "pPp", "ppp" }, 131, 237, { p = L.petal.shade, P = L.petal.base })
vline(88, 244, 250, L.vine.shade) F.sprite({ "ggg", "gGg" }, 87, 242, { g = L.leaf.shade, G = L.leaf.deep })
for _, cl in ipairs({ { 140, 252, 10 }, { 30, 248, 12 } }) do
  vline(cl[1], cl[2] - cl[3], cl[2], L.vine.base)
  local cup = c:ellipse(cl[1], cl[2] - cl[3] - 2, 5, 2):add(poly{ { cl[1] - 5, cl[2] - cl[3] - 2 }, { cl[1] + 5, cl[2] - cl[3] - 2 }, { cl[1], cl[2] - cl[3] + 2 } })
  c:rim(cup, L.leaf.edge) fill(cup, L.leaf.base)
  cup:each(function(x, y) if y <= cl[2] - cl[3] - 3 then px(x, y, L.leaf.hi) elseif x > cl[1] then px(x, y, L.leaf.shade) end end)
  px(cl[1] - 1, cl[2] - cl[3] - 2, L.wet)
end
-- an egret wading, a fish in its bill's sights
F.sprite({
  "...WWW.....",
  "yyyWkWW....",
  "....WWW....",
  ".....WW....",
  ".....WW....",
  "....WW.....",
  "....WW.....",
  "....WWWWW..",
  "...WWWWWWWw",
  "...wWWWWWww",
  "....wwwww..",
  ".....l..l..",
  ".....l..l..",
  ".....l..l..",
}, 112, 224, { W = L.awnB.hi, w = L.awnB.shade, k = L.timber.edge, y = L.gold.base, l = L.timber.deep })
hline(114, 120, 238, Wt.hi) hline(110, 112, 239, Wt.hi)
F.sprite({ ".ff.", "fFFf" }, 102, 232, { f = L.produce.shade, F = L.produce.base })
-- torch ginger and arrowroot at the pond's left
do
  for k, a in ipairs({ -pi * .62, -pi * .5, -pi * .38 }) do F.bigLeaf(22 + k * 3, 244, 14 + k * 2, a, k == 2 and L.foliage or L.leaf, 80 + k, 3, { stem = { 24 + k * 3, 250 } }) end
  vline(36, 226, 250, L.vine.shade) vline(37, 228, 250, L.vine.deep)
  F.sprite({ ".rRr.", "rRHRr", "rRHRr", ".rrr.", "..r.." }, 34, 221, { r = L.apple.base, R = L.apple.hi, H = L.petal.hi })
end
do -- the washer gnome on a flat stone with a bamboo washboard and a woven basket
  local st = c:ellipse(170, 236, 12, 3) rimOf(st, L.stone) part(st, L.stone, { nopop = true }) F.shine(st, .2, 81)
  local _, hx, hy = F.gnome(168, 232, { hat = L.awnB, coat = L.leaf, arm = "out", flip = true, noShadow = true })
  local wb = rect(hx - 6, hy - 6, hx, hy + 4) c:rim(wb, L.timber.edge) part(wb, L.bamboo, { nopop = true })
  for y = hy - 4, hy + 3, 2 do hline(hx - 5, hx - 1, y, L.bamboo.deep) end
  for k = 0, 2 do hline(hx - 12 - k * 2, hx - 6 + k * 2, hy + 7 + k * 2, Wt.hi) end
  local bsk = c:rrect(184, 222, 202, 234, 3) rimOf(bsk, L.needle) part(bsk, L.roof)
  bsk:each(function(x, y) if ((x + y) // 2) % 2 == ((x - y) // 2) % 2 then px(x, y, L.roof.shade) end end)
  fill(c:ellipse(189, 221, 4, 2), L.accent.base) fill(c:ellipse(196, 220, 4, 2), L.awnA.base) px(194, 219, L.awnA.hi) px(187, 220, L.accent.hi)
end

---------------------------------------------------------------- ferns, impatiens, fungi round the rocks; a path of stepping stones
F.depth(3)
F.fern(292, 214, 7) F.fern(306, 222, 6, L.vine) F.fern(376, 224, 6) F.fern(120, 208, 6) F.fern(462, 218, 7)
F.treeFern(468, 226, 24, 82)
for i = 0, 11 do
  local x, y = 290 + floor(hash(i, 1, 71) * 90), 218 + floor(hash(i, 2, 71) * 12)
  if not F.roadM:has(x, y) and not brook:grow(3):has(x, y) and not pool:grow(4):has(x, y) then
    for k = -3, 3 do px(x + k, y + 1, L.leaf.shade) if k % 2 == 0 then px(x + k, y, L.leaf.base) end end
    local fr = i % 3 == 0 and L.helic or L.petal
    for _, d in ipairs({ { -2, -1 }, { 1, -2 }, { 3, -1 } }) do
      local fx, fy = x + d[1], y + d[2]
      px(fx - 1, fy, fr.base) px(fx + 1, fy, fr.shade) px(fx, fy - 1, fr.hi) px(fx, fy + 1, fr.shade) px(fx, fy, L.gold.hi)
    end
  end
end
F.mushroom(440, 222, L.produce, true) F.mushroom(446, 224, L.produce) F.mushroom(300, 230, L.helic)

---------------------------------------------------------------- foreground: taro clumps, a gnome hauling a clay water urn on a cart
F.depth(3)
local function taro(x, yb, n, s, seed)
  for i = 1, n do
    local a = -pi / 2 + (i - (n + 1) / 2) * .55
    local len = s + floor(hash(i, 1, seed) * 4)
    local sx, sy = x + floor(cos(a) * 4), yb - floor(s * .5)
    F.bigLeaf(sx, sy - 2, len, a + (a < -pi / 2 and -.6 or .6), i % 2 == 0 and L.foliage or L.leaf, seed + i, floor(len * .4), { heart = true, droop = .2, stem = { x, yb } })
  end
end
taro(352, 238, 3, 11, 91) taro(372, 264, 3, 12, 92) taro(156, 268, 3, 10, 93)
do
  local x, yb = 322, 266
  local urn = c:rrect(330, 238, 352, 258, 7):add(rect(337, 234, 345, 238))
  local bed = rect(328, 256, 356, 259)
  local shaft = line({ { 330, 257 }, { 324, 259 } }, 2)
  local wh = c:ellipse(342, 262, 6, 6)
  F.shadowM(c:ellipse(346, 268, 16, 1))
  rimOf(union(urn, bed, shaft, wh), L.timber)
  part(urn, clay)
  urn:each(function(xx, yy) if xx < 336 and yy > 240 and yy < 254 then px(xx, yy, clay.hi) end if yy == 244 or yy == 245 then px(xx, yy, (xx // 2) % 2 == 0 and clay.deep or L.gold.shade) end end)
  hline(337, 345, 234, clay.hi) fill(rect(338, 233, 344, 233), Wt.hi) px(339, 233, GL)
  part(bed, L.bamboo, { nopop = true }) F.bambooWall(bed, L.bamboo, 2, true, 94)
  part(shaft, L.bamboo, { nopop = true, noshade = true })
  part(wh, L.timber, { nopop = true }) fill(c:ellipse(342, 262, 3, 3), L.timber.shade)
  vline(342, 257, 267, L.timber.deep) hline(337, 347, 262, L.timber.deep) px(342, 262, L.iron.hi)
  for _, p in ipairs({ { 348, 232 }, { 351, 234 }, { 334, 233 }, { 353, 238 } }) do px(p[1], p[2], Wt.hi) end
  tube(352, 246, 4, 10, true)
  F.gnome(x, yb, { hat = L.awnA, coat = L.board, arm = "out" })
end
-- dragonflies over the water
for i, d in ipairs({ { 296, 222 }, { 228, 236 }, { 92, 230 }, { 370, 186 } }) do
  local x, y = d[1], d[2]
  local body = ({ L.apple, L.accent, L.helic, L.teal })[i]
  hline(x - 3, x + 3, y, Wt.hi) px(x - 2, y - 1, GL) px(x + 2, y - 1, GL)
  vline(x, y - 1, y + 4, body.shade) px(x, y - 1, body.hi) px(x, y + 4, body.deep)
end
-- humid mist lying on the brook and pond (solid dithered streaks)
brook:each(function(x, y)
  local band = (y + floor(sin(x / 17) * 2)) % 9
  if band < 2 and hash(x // 11, y // 9, 90) < .5 and (x + y) % 2 == 0 then
    local v = c:get(x, y)
    if v == Wt.hi or v == Wt.base or v == Wt.shade or v == mix(Wt.hi, Wt.base, .5) then px(x, y, band == 0 and L.mist2 or L.mist) end
  end
end)

F.depth(0)
F.birds({ { 330, 44, 2, "#2e7a46" }, { 340, 50, 1, "#2e7a46" }, { 168, 60, 2, "#b03a36" }, { 186, 54, 2, "#2e7a46" }, { 236, 70, 1, "#4a8ad8" } })
F.finish()
