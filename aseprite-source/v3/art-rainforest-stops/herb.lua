-- herb.lua : "Herb garden" stop look, RAINFOREST (rainforest_canopy), 480x270 gate view.
-- Same composition as the Maplewold herb (art-2701-batch3/stops/opus3/herb.lua) and the forest herb, re-cast for a
-- medicinal garden under the canopy:
-- right: rows of lemongrass and purple holy basil on wet red earth running back to the canopy wall (replaces the
-- lavender), two far gnomes gathering. Road's end: a bamboo arch climbed by a passionflower vine (flowers and
-- passion fruit), a woven lattice gate ajar, a pale fig and a tree fern either side.
-- Back left: a bamboo shade house with a slatted roof, tiers of potted orchids and hanging fern baskets.
-- Left hero: the herbalist's thatched drying hut on a bamboo deck: woven palm-mat walls in a bamboo frame, propped
-- shutters, herb bundles, chilli strings and ginger roots drying under the eave, a round teal door with a leaf wreath,
-- a carved mortar-and-pestle sign, a gecko. Bamboo-fronted beds (aloe, turmeric, chillies, cat's whiskers), a bamboo
-- potting bench with coconut-shell orchid pots and tincture jars, calabash stingless-bee hives, a mossy stone herb
-- spiral (gotu kola, coleus, a bromeliad), torch gingers and heliconias along the left, glazed pots of aloe,
-- lemongrass and an orchid, a drying tray of turmeric and chillies, leafcutter ants, hummingbirds, a dart frog.
-- Quirk: an ocelot in a red gnome hat asleep in the cat's-whiskers bed, a butterfly on the hat tip.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-rainforest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "herb", out = DIR, farTrees = { 24, 52, 160, 196, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local HAZE = "#d4e2bc"
-- local ramps
local BAS = F.rp("#ecc4f4 #bc84d8 #8c5aaa #5e3c7c #3a2450")   -- holy basil flower spikes
local LEM = F.rp("#e8f49a #c2dc6c #94b84c #66903c #3e6030")   -- lemongrass blades
local TUR = F.rp("#ffd27a #f4a43a #d27a24 #9a5220 #5e3218")   -- turmeric root / slices
local ALOE = F.rp("#cce8c4 #94c6a4 #6aa284 #46786a #2a4e48")         -- aloe grey-green
local CAL = F.rp("#f0dc94 #d4b460 #aa8a40 #7a6030 #4c3c22")    -- calabash gourd
local OCE = F.rp("#f6d494 #e6b062 #bc823e #84562c #4e321c")    -- ocelot tawny
local GLZ = F.rp("#8ae0d6 #3cb2b0 #24888e #1a5e6c #10384a")    -- glazed pot teal-blue
local CHL = L.apple

---------------------------------------------------------------- local helpers
local function bambooEnd(x, y, rr, r)
  r = r or L.board
  local m = c:ellipse(x, y, rr, rr)
  c:rim(m, L.timber.edge) fill(m, r.base)
  m:each(function(xx, yy) if (xx - x) + (yy - y) < -rr * .5 then px(xx, yy, r.hi) elseif (xx - x) + (yy - y) > rr * .6 then px(xx, yy, r.shade) end end)
  if rr >= 2 then fill(c:ellipse(x, y, rr - 1, rr - 1), L.soil.deep) px(x - 1, y - 1, L.soil.shade) end
  return m
end
local function coconutPot(x, yb, w)
  -- a half coconut shell used as a pot: hairy brown husk, a lit lip
  local m = c:ellipse(x, yb - 2, w, 3):clip(rect(x - w, yb - 3, x + w, yb + 1))
  c:rim(m, L.soil.edge) part(m, L.soil, { nopop = true })
  m:each(function(xx, yy) if hash(xx, yy, 7) < .3 then px(xx, yy, L.needle.shade) end end)
  hline(x - w + 1, x + w - 1, yb - 3, L.needle.base) px(x - w + 1, yb - 3, L.needle.hi)
  return m
end
-- a torch ginger: a leafy cane with alternate lance leaves and, on its own bare stalk, a waxy torch flower
local function torchGinger(x, yb, h, seed, r)
  r = r or L.petal
  local stem = rect(x, yb - h, x, yb)
  rimOf(stem, L.vine) fill(stem, L.vine.shade)
  for k = 0, 3 do
    local y = yb - floor(h * (.35 + k * .17))
    local s = (k + seed) % 2 == 0 and -1 or 1
    F.bigLeaf(x + s, y, 9 + (k == 0 and 2 or 0), s < 0 and -pi * .92 or -pi * .08, (k % 2 == 0) and L.foliage or L.leaf, seed * 5 + k, 2, { droop = .5 })
  end
  -- the flower stalk and torch, in front of the cane
  local fx, fh = x + 3, floor(h * .62)
  vline(fx, yb - fh, yb, L.vine.deep) vline(fx + 1, yb - fh + 3, yb, L.vine.shade)
  local ty = yb - fh - 4
  local flare = c:ellipse(fx, ty + 5, 4, 1)
  local cone = c:ellipse(fx, ty, 3, 5)
  rimOf(union(flare, cone), r)
  fill(flare, r.shade) px(fx - 3, ty + 5, r.base) px(fx + 4, ty + 6, r.deep) px(fx - 5, ty + 6, r.shade)
  cone:each(function(xx, yy)
    local d = (xx - fx) + (yy - ty)
    local h2 = d < -2 and r.hi or (d < 2 and r.base or r.shade)
    if (yy - ty + (xx % 2)) % 3 == 0 then h2 = d < 0 and r.base or r.deep end -- waxy bract scales
    px(xx, yy, h2)
  end)
  px(fx - 1, ty - 3, r.hi) px(fx, ty - 4, r.base)
  for q = -1, 1 do px(fx + q * 2, ty + 3, L.gold.hi) end
end
-- a hummingbird hovering: green back, ruby throat, needle bill, wing blur
local function hummer(x, y, flip)
  local s = flip and -1 or 1
  local rows = { "..ww...", ".wwGG..", "..GGGGb", ".tGRr..", "tt.g..." }
  for j, row in ipairs(rows) do
    for i = 1, #row do
      local ch = row:sub(i, i)
      local col = ({ w = L.wet, G = L.teal.base, g = L.teal.shade, R = L.apple.base, r = L.apple.shade, b = L.timber.edge, t = L.teal.deep })[ch]
      if col then px(x + s * (i - 1), y + j - 1, col) end
    end
  end
  px(x + s * 7, y + 2, L.timber.edge) px(x + s * 8, y + 2, L.timber.edge) px(x + s * 4, y + 1, L.timber.edge)
end
local function butterfly(x, y, a, b)
  F.sprite({ "a.a", ".k.", "b.b" }, x, y, { a = a, b = b, k = L.timber.edge }, { rim = false })
end

---------------------------------------------------------------- right: lemongrass and holy-basil rows to the canopy wall
-- Rows run across the view; band height grows with nearness (d^2 / C). Thin far rows are a solid hazed band with
-- horizontal texture only (no shimmer); near rows are lemongrass fountains (spiky tops, vertical blades) or round
-- basil mounds crusted with purple spikes, with wet red-earth furrows between them.
local C = 190
local function rowOf(y) return floor(C / (y - 109)) end
for y = 114, 160 do
  local row = rowOf(y)
  local y0 = y while y0 > 114 and rowOf(y0 - 1) == row do y0 = y0 - 1 end
  local y1 = y while y1 < 160 and rowOf(y1 + 1) == row do y1 = y1 + 1 end
  local hgt = y1 - y0 + 1
  local lemon = row % 3 == 0
  local R = lemon and LEM or BAS
  for x = 262, 479 do
    if x > F.xr(y) + 6 then
      local h
      local v = hash(x, y, 18 + row)
      if hgt < 3 then
        -- far rows: one hazed green band (no row-by-row stripes), flecks of basil bloom and lemongrass tips
        h = (y % 2 == 0) and F.mix(L.foliage.base, HAZE, .3) or F.mix(L.foliage.shade, HAZE, .28)
        local f = hash(x // 3, y, 3)
        if f < .14 then h = F.mix(BAS.base, HAZE, .25) elseif f < .2 then h = F.mix(LEM.base, HAZE, .25) end
      elseif lemon then
        -- lemongrass: each clump a fountain of blades; spiky top line, vertical blade stripes lit on the left
        local bw = math.max(4, floor(hgt * 1.3))
        local xx = x + row * 5
        local fx = (xx % bw) / bw
        local ty = y0 + floor(hgt * (.15 + .45 * abs(2 * fx - 1)) + (hash(x, row, 21) < .35 and 1 or 0))
        local ry = (y - y0) / hgt
        if y < ty then
          h = (ry < .25) and L.soil.deep or L.soil.shade
          if hash(x, y, 12) < .1 then h = L.litter.shade end
        elseif y == y1 then h = L.soil.deep
        else
          local stripe = (x + (y - ty) // 3) % 2
          if y == ty then h = (fx < .5) and LEM.hi or LEM.base
          elseif fx < .4 then h = stripe == 0 and LEM.hi or LEM.base
          elseif fx < .75 then h = stripe == 0 and LEM.base or LEM.shade
          else h = stripe == 0 and LEM.shade or LEM.deep end
          if ry > .8 then h = (v < .5) and LEM.deep or L.vine.deep end
        end
      else
        -- holy basil: dark round mounds, a crust of purple flower spikes on the lit upper left, freckled
        local bw0 = math.max(5, floor(hgt * 1.7))
        local xx = x + row * 3
        local bi = xx // bw0
        local fx = (xx % bw0) / bw0
        local hk = .3 + .35 * hash(bi, row, 16)
        local ty = y0 + floor(hgt * hk * (1 - math.sqrt(math.max(0, 1 - (2 * fx - 1) ^ 2))) + (hash(bi, row, 17) < .3 and 1 or 0) + .5)
        local ry = (y - y0) / hgt
        if y < ty then
          h = (ry < .2) and L.soil.deep or L.soil.shade
          if hash(x, y, 12) < .12 then h = L.litter.shade end
        elseif y == y1 then h = L.soil.deep
        else
          local lit = (1 - fx) * .8 - ry * 1.1 + (v - .5) * .7
          if y == ty then h = (fx < .55) and BAS.hi or BAS.base
          elseif lit > .5 then h = BAS.hi
          elseif lit > .05 then h = (v < .55) and BAS.base or L.foliage.base
          elseif lit > -.4 then h = (v < .5) and L.foliage.shade or BAS.shade
          else h = (v < .5) and L.foliage.deep or BAS.deep end
          if ry > .8 then h = (v < .5) and L.foliage.deep or L.foliage.edge end
          if v > .94 and y > ty then h = L.leaf.base end
        end
      end
      px(x, y, h)
    end
  end
end
-- a low bamboo edging closing the near edge of the field
for x = 262, 479 do
  if x > F.xr(161) + 4 then
    local nd = (x + 3) % 11 == 0
    px(x, 162, L.timber.edge) px(x, 161, nd and L.bamboo.deep or L.bamboo.shade) px(x, 160, nd and L.bamboo.deep or L.bamboo.base)
    px(x, 159, nd and L.bamboo.shade or L.bamboo.hi)
  end
end

---------------------------------------------------------------- road's end: bamboo arch with a passionflower vine
local function arch()
  local pL, pR = rect(216, 76, 219, 126), rect(261, 76, 264, 126)
  local top = c:ellipse(240, 80, 24, 18):cut(c:ellipse(240, 80, 20, 14)):clip(rect(214, 58, 266, 80))
  F.shadow(216, 266, 126, 6, 3)
  local frame = union(pL, pR, top)
  rimOf(frame, L.timber)
  part(frame, L.bamboo, { nopop = true, noshade = true })
  -- living bamboo: lit left lip, shaded right, node rings every 7 px (on the bend: radial ticks)
  frame:each(function(x, y)
    if not frame:has(x - 1, y) or not frame:has(x, y - 1) then px(x, y, L.bamboo.hi) end
    if not frame:has(x + 1, y) or not frame:has(x, y + 1) then px(x, y, L.bamboo.shade) end
  end)
  for y = 80, 124, 7 do hline(216, 219, y, L.bamboo.deep) hline(261, 264, y, L.bamboo.deep) px(216, y + 1, L.shine) px(261, y + 1, L.shine) end
  for k = 1, 6 do
    local a = pi + k / 7 * pi
    for rr = 20, 24 do local x, y = floor(240 + cos(a) * rr + .5), floor(80 + sin(a) * rr * .75 + .5) if top:has(x, y) then px(x, y, L.bamboo.deep) end end
  end
  -- lashings where the bend meets the posts
  for _, lx in ipairs({ 216, 261 }) do hline(lx, lx + 3, 79, L.needle.deep) hline(lx, lx + 3, 81, L.needle.base) end
  -- woven lattice gate, ajar
  local gm = rect(222, 108, 238, 124)
  local lat = HP.mask()
  gm:each(function(x, y) if (x + y) % 5 == 0 or (x - y) % 5 == 0 or x == 222 or x == 238 or y == 108 or y == 124 then lat:set(x, y) end end)
  rimOf(lat, L.timber)
  lat:each(function(x, y) px(x, y, (x == 222 or y == 108) and L.board.hi or (((x + y) % 5 == 0) and L.board.base or L.board.shade)) end)
  -- the passionflower vine: leaf clumps along the arch and posts, open flowers and hanging passion fruit
  local clumps = { { 214, 120 }, { 220, 106 }, { 214, 94 }, { 220, 80 }, { 225, 68 }, { 233, 62 }, { 246, 62 }, { 255, 67 }, { 262, 80 }, { 266, 94 }, { 260, 108 }, { 266, 120 } }
  for i, p in ipairs(clumps) do
    F.crown(p[1], p[2], 5, 4, (i % 2 == 0) and L.vine or L.foliage, 200 + i)
    if i % 3 == 1 then
      -- passionflower: pale petals, a purple-banded corona, a gold centre
      local fx, fy = p[1] + (i % 2 == 0 and -2 or 2), p[2] - 1
      for _, d in ipairs({ { -2, 0 }, { 2, 0 }, { 0, -2 }, { 0, 2 }, { -1, -1 }, { 1, 1 }, { 1, -1 }, { -1, 1 } }) do px(fx + d[1], fy + d[2], (d[1] + d[2] < 0) and L.awnB.hi or L.awnB.shade) end
      px(fx - 1, fy, BAS.base) px(fx + 1, fy, BAS.shade) px(fx, fy - 1, BAS.hi) px(fx, fy + 1, BAS.deep) px(fx, fy, L.gold.hi)
    elseif i % 3 == 2 then
      local bx, by = p[1] + (i % 2 == 0 and 2 or -2), p[2] + 3
      fill(rect(bx, by, bx + 1, by + 2), BAS.shade) px(bx, by, BAS.base) px(bx + 1, by + 2, BAS.deep) px(bx, by - 1, L.vine.deep)
    else
      local bx, by = p[1], p[2] + 2
      fill(rect(bx, by, bx + 1, by + 1), L.produce.base) px(bx, by, L.produce.hi) px(bx + 1, by + 1, L.produce.shade)
    end
  end
  -- tendrils and vines hanging off the crown of the arch, one ending in a flower
  for i, t in ipairs({ { 230, 70, 8 }, { 250, 69, 10 }, { 240, 66, 5 } }) do
    F.vine(t[1], t[2], t[3], t[1], L.vine, i == 2 and L.orchid or nil)
  end
end

---------------------------------------------------------------- back-left: bamboo shade house of orchids
local function shadeHouse(x0, x1, yb)
  local wh, rh = 20, 14
  local top, cx = yb - wh, (x0 + x1) // 2
  local roofm = poly{ { x0 - 3, top + 1 }, { cx, top - rh }, { x1 + 3, top + 1 } }
  local inside = rect(x0, top + 1, x1, yb)
  local posts = HP.mask()
  for _, x in ipairs({ x0, x0 + 18, x1 - 18 - 1, x1 - 1 }) do posts:add(rect(x, top, x + 1, yb)) end
  F.shadow(x0 + 2, x1, yb, 8, 4)
  rimOf(union(roofm, inside), L.timber)
  -- deep green shade inside, dappled by the slats
  inside:each(function(x, y) px(x, y, ((x + floor(y * .5)) % 6 < 2 and y < top + 10) and L.mossGround.shade or L.mossGround.deep) end)
  -- tiered benches of potted orchids
  for t = 0, 1 do
    local by = yb - 3 - t * 7
    local bx0, bx1 = x0 + 2 + t * 6, x1 - 2 - t * 6
    hline(bx0, bx1, by, L.bamboo.hi) hline(bx0, bx1, by + 1, L.bamboo.shade)
    for x = bx0 + 3, bx1 - 3, 6 do
      fill(rect(x - 1, by - 2, x + 1, by - 1), L.soil.base) px(x - 1, by - 2, L.soil.hi)
      local fr = ({ L.orchid, L.petal, L.awnB, BAS })[((x + t) // 6) % 4 + 1]
      px(x, by - 3, L.vine.base) px(x - 1, by - 4, L.vine.hi) px(x + 1, by - 4, L.vine.shade)
      px(x - 1, by - 5, fr.hi) px(x, by - 5, fr.base) px(x + 1, by - 6, fr.base) px(x + 1, by - 5, fr.shade)
    end
  end
  part(posts, L.bamboo, { nopop = true, noshade = true })
  posts:each(function(x, y) if (y - top) % 6 == 0 then px(x, y, L.bamboo.deep) end end)
  -- slatted split-bamboo roof: lit slats with dark gaps, a bamboo ridge, a ragged leaf fringe
  roofm:each(function(x, y)
    local k = (x - cx + 40) % 4
    local h = (k == 3) and L.foliage.deep or (k == 0 and L.board.hi or (x < cx and L.board.base or L.board.shade))
    if k ~= 3 and (y + x // 4) % 6 == 0 then h = L.board.deep end
    px(x, y, h)
  end)
  line({ { x0 - 3, top + 1 }, { cx, top - rh } }):each(function(x, y) px(x, y, L.bamboo.hi) end)
  line({ { cx, top - rh }, { x1 + 3, top + 1 } }):each(function(x, y) px(x, y, L.bamboo.shade) end)
  hline(x0 - 3, x1 + 3, top + 1, L.bamboo.deep) hline(x0 - 2, x1 + 2, top + 2, L.timber.deep)
  -- hanging fern baskets from the eave beam
  for _, hx in ipairs({ x0 + 9, cx, x1 - 9 }) do
    vline(hx, top + 3, top + 5, L.needle.deep)
    local bk = c:ellipse(hx, top + 7, 3, 2) c:rim(bk, L.timber.edge) part(bk, L.needle, { nopop = true })
    for q = -4, 4, 2 do px(hx + q, top + 9 + abs(q) // 2, L.fern.base) px(hx + q, top + 10 + abs(q) // 2, L.fern.shade) end
    px(hx - 1, top + 5, L.fern.hi) px(hx + 1, top + 5, L.fern.base)
  end
  -- moss and a bromeliad on the ridge
  F.moss(roofm, .08, 31)
  px(cx, top - rh - 1, L.helic.base) px(cx - 1, top - rh - 2, L.helic.hi) px(cx + 1, top - rh - 2, L.helic.shade) px(cx, top - rh - 2, L.helic.base)
end

---------------------------------------------------------------- left hero: the herbalist's thatched drying hut on a bamboo deck
local function hut()
  F.shadow(92, 190, 186, 10, 4)
  -- stilts and deck first
  local stilts = HP.mask()
  for _, sx in ipairs({ 96, 116, 158, 180 }) do stilts:add(rect(sx, 180, sx + 2, 187)) end
  rimOf(stilts, L.timber) part(stilts, L.timber, { nopop = true, noshade = true })
  stilts:each(function(x, y) if x % 2 == 0 and y < 182 then px(x, y, L.timber.deep) end end)
  local top, cx, wallM, roofM = F.building{ x0 = 96, x1 = 182, yb = 176, wh = 40, rh = 32, wall = L.plaster, roof = L.roof, noShadow = true, noAttic = true }
  local deck = rect(92, 177, 186, 180)
  rimOf(deck, L.timber) part(deck, L.board, { nopop = true }) F.bambooWall(deck, L.board, 2, true, 27)
  for x = 94, 186, 9 do bambooEnd(x, 178, 1) end
  -- two bamboo steps up to the door
  local steps = rect(126, 181, 150, 183):add(rect(124, 184, 152, 186))
  rimOf(steps, L.timber) part(steps, L.board, { nopop = true }) F.bambooWall(steps, L.board, 3, true, 28)
  -- moss and leaf litter on the thatch
  F.moss(roofM, .07, 41)
  for i = 0, 14 do local x, y = 100 + floor(hash(i, 1, 41) * 78), top - 6 - floor(hash(i, 2, 41) * 20) if roofM:has(x, y) and roofM:has(x + 1, y) then px(x, y, L.litter.base) px(x + 1, y, L.litter.shade) end end
  -- woven palm-mat gable with bamboo purlins
  local gableM = poly{ { 101, top }, { cx, top - 32 + 8 }, { 177, top } }:shrink(2)
  gableM:each(function(x, y)
    local h = (((x + y) // 2) % 2 == ((x - y) // 2) % 2) and L.plaster.base or L.plaster.shade
    if (y - top) % 8 == 0 then h = ((x + y) % 9 == 0) and L.bamboo.deep or L.bamboo.base elseif (y - top) % 8 == 1 then h = L.plaster.deep end
    if hash(x // 3, y // 2, 46) < .05 then h = L.plaster.hi end
    px(x, y, h)
  end)
  -- woven gable: a diamond vent with smoke, a carved leaf boss
  local gv = poly{ { cx, top - 20 }, { cx + 5, top - 15 }, { cx, top - 10 }, { cx - 5, top - 15 } }
  rimOf(gv, L.timber) fill(gv, L.timber.edge) px(cx - 1, top - 17, L.glow.deep) px(cx, top - 15, L.glow.shade)
  for k = -2, 2 do px(cx + k, top - 6 - abs(k), L.vine.base) end px(cx, top - 4, L.vine.shade) px(cx - 3, top - 4, L.vine.hi) px(cx + 3, top - 4, L.vine.deep)
  -- damp moss along the foot of the walls
  wallM:each(function(x, y) if y > 171 and hash(x // 2, y, 42) < .3 then px(x, y, hash(x, y, 43) < .5 and L.moss.shade or L.moss.base) end end)
  -- round teal door: painted bamboo slats, a leaf wreath with orchids, a brass latch
  local d = c:rrect(130, 150, 146, 176, 8):clip(rect(130, 150, 146, 176))
  rimOf(d, L.teal) part(d, L.teal) c:edgeIn(d, L.teal.edge)
  for x = 133, 144, 3 do vline(x, 153, 175, L.teal.shade) end
  d:each(function(x, y) if (x - 131) % 3 == 0 and x < 140 and hash(x, y // 4, 44) < .3 then px(x, y, L.teal.hi) end end)
  fill(c:ellipse(143, 165, 1, 1), L.gold.base) px(142, 164, L.gold.hi)
  local wr = c:ellipse(138, 158, 3, 3):cut(c:ellipse(138, 158, 1, 1))
  wr:each(function(x, y) px(x, y, (x + y) % 2 == 0 and L.vine.base or L.vine.shade) end)
  px(136, 155, L.orchid.hi) px(137, 155, L.orchid.base) px(140, 161, L.helic.base) px(141, 160, L.helic.hi)
  -- windows with propped bamboo shutters and coconut-husk window boxes of chillies and orchids
  for _, wx in ipairs({ 104, 158 }) do
    F.window(wx + 2, 144, wx + 12, 152, L.timber)
    local sh = poly{ { wx, 141 }, { wx + 14, 141 }, { wx + 16, 136 }, { wx + 2, 136 } }
    rimOf(sh, L.timber) part(sh, L.bamboo, { nopop = true }) F.bambooWall(sh, L.board, 3, false, wx)
    line({ { wx + 1, 142 }, { wx + 3, 150 } }):each(function(x, y) px(x, y, L.timber.base) end)
    local bx = rect(wx, 154, wx + 14, 157) rimOf(bx, L.soil) part(bx, L.needle, { nopop = true })
    bx:each(function(x, y) if hash(x, y, wx) < .35 then px(x, y, L.needle.shade) end end)
    for k = 0, 6 do
      local fx = wx + 1 + k * 2
      px(fx, 153, L.leaf.base) px(fx + 1, 152, L.leaf.hi) px(fx, 152, L.leaf.shade)
      if k % 3 == 0 then px(fx, 151, L.orchid.base) px(fx + 1, 150, L.orchid.hi)
      elseif k % 3 == 1 then px(fx + 1, 153, CHL.base) px(fx + 1, 154, CHL.shade) end
    end
  end
  -- the drying line under the eave: herb bundles, chilli strings, ginger hands, lemongrass sheaves
  hline(98, 180, top + 5, L.bamboo.shade) hline(98, 180, top + 4, L.bamboo.hi)
  for k = 0, 10 do
    local x = 100 + k * 8
    local kind = k % 4
    if kind == 1 then
      -- a string of red chillies
      vline(x, top + 6, top + 18, L.needle.deep)
      for j = 0, 3 do local yy = top + 7 + j * 3 px(x - 1, yy, CHL.base) px(x - 1, yy + 1, CHL.shade) px(x + 1, yy + 1, CHL.hi) px(x + 1, yy + 2, CHL.base) end
    elseif kind == 3 then
      -- knobbly ginger and turmeric hands on a cord
      vline(x, top + 6, top + 8, L.needle.deep)
      local g = c:ellipse(x, top + 11, 2, 2):add(rect(x - 3, top + 12, x - 2, top + 13)):add(rect(x + 2, top + 9, x + 3, top + 10))
      rimOf(g, L.palmTrunk) part(g, (k == 3) and L.palmTrunk or TUR, { nopop = true })
      px(x - 1, top + 10, ((k == 3) and L.palmTrunk or TUR).hi)
    else
      local r = ({ L.leaf, BAS, LEM, L.wall2, L.fern, BAS })[(k // 2) % 6 + 1]
      vline(x, top + 6, top + 6, L.timber.edge)
      local b = poly{ { x - 2, top + 7 }, { x + 2, top + 7 }, { x + 1, top + 15 }, { x - 1, top + 15 } }
      rimOf(b, r) fill(b, r.base) px(x - 1, top + 8, r.hi) px(x - 1, top + 11, r.hi) vline(x + 1, top + 9, top + 14, r.shade)
      hline(x - 2, x + 2, top + 7, L.needle.deep) px(x, top + 15, r.deep)
    end
  end
  -- carved hardwood mortar-and-pestle sign hanging from a bamboo bracket
  local br = rect(183, 140, 200, 141)
  rimOf(br, L.timber) part(br, L.bamboo, { nopop = true, noshade = true })
  vline(188, 142, 145, L.needle.deep) vline(196, 142, 145, L.needle.deep)
  local mortar = poly{ { 185, 148 }, { 199, 148 }, { 197, 155 }, { 193, 158 }, { 191, 158 }, { 187, 155 } }
  local pestle = line({ { 196, 146 }, { 201, 140 } }, 2)
  rimOf(union(mortar, pestle), L.timber) part(mortar, L.timber) part(pestle, L.board, { nopop = true })
  hline(185, 199, 148, L.timber.hi) hline(187, 197, 149, L.timber.deep)
  mortar:each(function(x, y) if y > 150 and (x + y) % 4 == 0 then px(x, y, L.timber.shade) end end)
  px(189, 147, L.leaf.hi) px(190, 146, L.leaf.base) px(192, 147, L.leaf.hi) px(191, 146, L.fern.hi)
  -- a gecko on the wall by the left window
  F.sprite({ "g...g", ".ggg.", "..G..", ".ggg.", "g.G.g", "..G..", "..g..", "...g." }, 120, 158,
    { g = L.vine.base, G = L.vine.hi }, { rim = false })
  px(122, 157, L.vine.base) px(121, 157, L.timber.edge)
  -- vines over the eave, an orchid spray on the right corner post
  F.vines(rect(96, top + 3, 128, top + 6), .07, 34, 8)
  F.orchid(180, 166, L.orchid, 2, true)
  return top
end

---------------------------------------------------------------- bamboo-fronted raised beds in perspective (right of road)
local function bed(x0, x1, y0, y1, plant, seed)
  local soil = poly{ { x0 + 4, y0 }, { x1, y0 }, { x1 + 4, y1 }, { x0, y1 } }
  local front = rect(x0, y1, x1 + 4, y1 + 4)
  F.shadow(x0, x1 + 4, y1 + 4, 6, 2)
  rimOf(union(soil, front), L.timber)
  fill(soil, L.soil.shade)
  soil:each(function(x, y) local v = hash(x, y, seed) if v < .2 then px(x, y, L.soil.deep) elseif v > .9 then px(x, y, L.litter.base) elseif v > .86 then px(x, y, L.soil.base) end end)
  F.bambooWall(front, L.board, 5, true, seed)
  front:each(function(x, y) if hash(x // 3, y, seed + 9) < .08 then px(x, y, L.moss.base) end end)
  bambooEnd(x0, y1 + 2, 2) bambooEnd(x1 + 4, y1 + 2, 2)
  local n = (x1 - x0) // 7
  for k = 0, n - 1 do plant(x0 + 6 + k * 7, y0 + (y1 - y0) // 2 + 2, k) end
end
local function aloe(x, y, k)
  -- compact outlined rosette (clean read at distance)
  F.sprite({ "h.b.b.s", "hhbbbss", "hbbhbbs", ".bbbbs." }, x - 3, y - 4, { h = ALOE.hi, b = ALOE.base, s = ALOE.shade })
  if k % 3 == 1 then vline(x + 1, y - 9, y - 6, ALOE.deep) px(x + 1, y - 10, L.produce.base) px(x + 2, y - 9, L.produce.shade) end
end
local function aloeOld(x, y, k)
  -- spiky grey-green rosette: blades fanning up and out, lit left, pale speckles
  for _, b in ipairs({ { -4, -3 }, { -3, -5 }, { -1, -6 }, { 1, -6 }, { 3, -5 }, { 4, -3 } }) do
    line({ { x, y }, { x + b[1], y + b[2] } }):each(function(xx, yy) px(xx, yy, b[1] < 0 and ALOE.base or ALOE.shade) end)
    px(x + b[1], y + b[2], b[1] < 0 and ALOE.hi or ALOE.base)
  end
  px(x, y - 1, ALOE.deep) px(x - 1, y - 3, ALOE.hi)
  if k % 3 == 1 then vline(x + 1, y - 9, y - 6, ALOE.deep) px(x + 1, y - 10, L.produce.base) px(x + 2, y - 9, L.produce.shade) end
end
local function turmeric(x, y, k)
  -- tall lance leaves, a pink-white flower cone in the middle now and then
  local m1 = line({ { x, y }, { x - 3, y - 7 }, { x - 4, y - 10 } }, 2)
  local m2 = line({ { x + 1, y }, { x + 3, y - 6 }, { x + 5, y - 8 } }, 2)
  rimOf(union(m1, m2), L.foliage) part(m1, L.leaf, { nopop = true }) part(m2, L.foliage, { nopop = true })
  vline(x, y - 9, y, L.foliage.deep)
  if k % 2 == 0 then fill(rect(x, y - 9, x + 1, y - 7), L.petal.hi) px(x + 1, y - 7, L.petal.base) px(x, y - 10, L.awnB.hi) end
  if k % 3 == 0 then px(x - 2, y, TUR.base) px(x - 1, y, TUR.hi) end
end
local function chilli(x, y, k)
  -- a bushy dark plant with red and orange chillies hanging
  local m = c:ellipse(x, y - 4, 4, 3)
  c:rim(m, L.foliage.edge) fill(m, L.foliage.shade)
  m:each(function(xx, yy) if (xx - x) + (yy - y + 4) < -1 then px(xx, yy, L.foliage.base) end if hash(xx, yy, 66) < .15 then px(xx, yy, L.foliage.deep) end end)
  px(x - 2, y - 6, L.foliage.hi) px(x - 3, y - 5, L.foliage.base)
  local cols = { CHL, L.produce, CHL, L.gold }
  for j, d in ipairs({ { -2, -3 }, { 1, -2 }, { 3, -4 }, { 0, -6 } }) do
    local r = cols[(j + k) % 4 + 1]
    px(x + d[1], y + d[2], r.base) px(x + d[1], y + d[2] + 1, r.shade) px(x + d[1], y + d[2] - 1, L.vine.deep)
    if j == 1 then px(x + d[1] - 1, y + d[2], r.hi) end
  end
end
local function whiskers(x, y, k)
  -- cat's whiskers (Orthosiphon): a soft green mound with white flower spikes and long lilac stamens
  local m = c:ellipse(x, y - 3, 3, 3) fill(m, L.vine.base)
  m:each(function(xx, yy) if (xx - x) + (yy - y + 3) < 0 then px(xx, yy, L.vine.hi) elseif (xx - x) + (yy - y + 3) > 2 then px(xx, yy, L.vine.shade) end end)
  vline(x - 1, y - 9, y - 5, L.vine.shade)
  for j = 0, 2 do px(x - 1, y - 9 + j * 2, L.awnB.hi) px(x - 2, y - 10 + j * 2, BAS.hi) px(x, y - 10 + j * 2, BAS.hi) end
  px(x - 3, y - 11, BAS.base) px(x + 1, y - 11, BAS.base)
  if k % 2 == 0 then vline(x + 2, y - 7, y - 5, L.vine.shade) px(x + 2, y - 7, L.awnB.hi) px(x + 3, y - 8, BAS.hi) end
end

---------------------------------------------------------------- compose: back to front
F.depth(1)
F.canopy(86, 128, 48, L.foliage2, 5, { w = 20 })
F.treeFern(12, 142, 34, 51)
shadeHouse(22, 76, 140)
-- two far gnomes gathering in the basil
F.gnome(420, 150, { small = true, hat = L.awnA, coat = L.wall2, arm = "out" })
F.gnome(352, 138, { small = true, hat = L.leaf, coat = L.produce, flip = true })
-- a low shrubbery behind the hut: ginger clumps and young leaves, a banana leaf or two
for x = 104, 206, 10 do F.bush(x, 134 + (x % 3), 6, 7, (x % 20 == 4) and L.foliage or L.leaf, x) end
F.bigLeaf(150, 118, 14, -pi * .8, L.foliage, 61, 4, { torn = true, droop = .3 })
F.bigLeaf(150, 118, 14, -pi * .25, L.leaf, 62, 4, { torn = true, droop = .35 })
F.depth(2)
F.canopy(198, 128, 50, L.leaf, 3, { w = 20, bark = L.redbark })
F.treeFern(284, 132, 34, 9)
arch()
F.canopy(462, 168, 66, L.foliage, 7, { w = 26 })
F.depth(3)
local htop = hut()
F.smoke(139, htop - 22, 6, .5, 2)
-- herb drying A-frame rack near the road (left): bundles and a turmeric garland
local function dryRack(x0, yb)
  local legs = line({ { x0, yb }, { x0 + 6, yb - 26 }, { x0 + 12, yb } }, 2):add(line({ { x0 + 30, yb }, { x0 + 36, yb - 26 }, { x0 + 42, yb } }, 2))
  local bar = rect(x0 + 4, yb - 26, x0 + 38, yb - 25)
  F.shadow(x0, x0 + 42, yb, 6, 2)
  rimOf(union(legs, bar), L.timber) part(legs, L.bamboo, { nopop = true, noshade = true }) part(bar, L.bamboo, { nopop = true, noshade = true })
  union(legs, bar):each(function(x, y) if (x + y) % 7 == 0 then px(x, y, L.bamboo.deep) end end)
  hline(x0 + 4, x0 + 38, yb - 26, L.bamboo.hi)
  for k = 0, 5 do
    local x = x0 + 9 + k * 5
    local r = ({ BAS, LEM, L.leaf, L.wall2, L.fern, BAS })[k + 1]
    vline(x, yb - 24, yb - 22, L.timber.edge)
    local b = poly{ { x - 2, yb - 21 }, { x + 2, yb - 21 }, { x + 1, yb - 12 }, { x - 1, yb - 12 } }
    rimOf(b, r) fill(b, r.base) px(x - 1, yb - 20, r.hi) px(x - 1, yb - 17, r.hi) vline(x + 1, yb - 19, yb - 13, r.shade)
    hline(x - 2, x + 2, yb - 21, L.needle.deep)
  end
  -- a sagging garland of chillies below
  for xx = x0 + 6, x0 + 36 do
    local t = (xx - x0 - 6) / 30
    local yy = floor(yb - 9 + 4 * 4 * t * (1 - t))
    px(xx, yy, L.needle.deep)
    if (xx - x0) % 3 == 0 then local r = ((xx - x0) % 6 == 0) and CHL or L.produce px(xx, yy + 1, r.base) px(xx, yy + 2, r.shade) px(xx - 1, yy + 1, r.hi) end
  end
end
dryRack(160, 214)
-- a woven drying tray of turmeric slices and chillies on the ground beside the rack
do
  local tray = c:ellipse(182, 223, 13, 3)
  F.shadow(170, 196, 226, 4, 1)
  c:rim(tray, L.timber.edge) part(tray, L.needle, { nopop = true })
  tray:each(function(x, y) if (x + y * 2) % 4 == 0 then px(x, y, L.needle.shade) end end)
  c:edgeIn(tray, L.needle.deep)
  for i = 0, 15 do
    local x, y = 172 + floor(hash(i, 1, 81) * 20), 222 + floor(hash(i, 2, 81) * 3)
    if i % 4 == 0 then px(x, y, CHL.base) px(x + 1, y, CHL.shade) else px(x, y, TUR.base) px(x + 1, y, TUR.hi) end
  end
end
-- the beds on the right, near ones larger
bed(276, 360, 166, 174, aloe, 3)
bed(282, 380, 182, 192, turmeric, 4)
bed(290, 400, 202, 214, chilli, 5)
bed(300, 376, 228, 242, whiskers, 6)
-- quirk: an ocelot in a red gnome hat, curled up asleep in the cat's whiskers, a butterfly on the hat tip
do
  F.sprite({
    "................Rr....",
    "...............RR.....",
    "..............RRr.....",
    ".............RRRr.....",
    "............RRRRr.....",
    "...........RRRRRRr....",
    "..........hhhhhhhhh...",
    "....tttttt.tTTTTTTt...",
    "..ttsttsttttTTTTTTTt..",
    ".tsttdttsttTeeTTeeTt..",
    "ttttsttttsttTwwnwwTt..",
    "tsttttsttttttwwwwwtt..",
    "tttsttdttsttttttttdt..",
    ".tttttttttttttttdddt..",
    "..kttkttkttkttkwwddt..",
    "...ddddddddddddddd....",
  }, 332, 217, { t = OCE.base, T = OCE.hi, d = OCE.shade, s = L.timber.deep, w = L.awnB.hi, e = L.timber.edge, n = "#e88a8a",
    k = L.timber.shade, R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep })
  -- rosette centres (tawny inside the dark spots) and a hat highlight
  for _, s in ipairs({ { 337, 225 }, { 340, 227 }, { 344, 228 }, { 336, 229 }, { 341, 230 } }) do px(s[1], s[2], OCE.shade) end
  px(345, 221, L.awnA.hi) px(344, 222, L.awnA.hi)
  -- a julia butterfly (orange) on the hat tip
  butterfly(348, 212, L.produce.hi, L.produce.shade)
  -- sleepy bubble
  local bub = c:ellipse(326, 222, 2, 2) fill(bub, L.water.hi) px(325, 221, L.wet)
  px(330, 225, L.water.hi)
end
-- bamboo potting bench: coconut-shell orchid pots, tincture jars, a stone mortar
local function pottingBench()
  local top = rect(402, 172, 452, 175)
  local legs = rect(405, 176, 407, 196):add(rect(447, 176, 449, 196))
  local shelf = rect(404, 188, 450, 189)
  F.shadow(404, 452, 196, 8, 3)
  rimOf(union(top, legs, shelf), L.timber)
  part(legs, L.bamboo, { nopop = true, noshade = true }) part(shelf, L.bamboo, { nopop = true, noshade = true }) part(top, L.board)
  F.bambooWall(top, L.board, 2, true, 21)
  legs:each(function(x, y) if y % 6 == 0 then px(x, y, L.bamboo.deep) end end)
  for k = 0, 2 do
    local x = 410 + k * 11
    coconutPot(x, 171, 4)
    local rr = ({ L.orchid, L.petal, L.awnB })[k + 1]
    vline(x, 163, 168, L.vine.shade) px(x - 1, 168, L.vine.base) px(x + 1, 167, L.vine.hi) px(x - 2, 167, L.vine.shade)
    for j = 0, 1 do local fx, fy = x + 1 + j * 2, 162 + j * 2 px(fx, fy, rr.base) px(fx - 1, fy, rr.hi) px(fx + 1, fy, rr.shade) px(fx, fy + 1, rr.deep) px(fx, fy - 1, rr.hi) end
  end
  -- tincture jars: amber turmeric, green, violet
  for k = 0, 2 do
    local x = 438 + k * 5
    local jar = rect(x - 2, 164, x + 1, 171)
    c:rim(jar, L.timber.edge) fill(jar, L.water.hi)
    fill(rect(x - 1, 167, x + 1, 171), ({ TUR, L.leaf, BAS })[k + 1].base) px(x + 1, 170, ({ TUR, L.leaf, BAS })[k + 1].shade)
    hline(x - 2, x + 1, 164, L.soil.base) px(x - 2, 166, L.wet)
  end
  -- on the shelf: a stone mortar with a pestle, banana-leaf parcels, bamboo tubes
  local mo = poly{ { 410, 183 }, { 420, 183 }, { 418, 187 }, { 412, 187 } }
  rimOf(mo, L.stone) part(mo, L.stone) hline(410, 420, 183, L.stone.hi) line({ { 418, 182 }, { 422, 178 } }):each(function(x, y) px(x, y, L.board.base) end)
  for k = 0, 1 do local x = 426 + k * 8 local p = rect(x, 183, x + 6, 187) rimOf(p, L.foliage) part(p, L.leaf, { nopop = true }) vline(x + 3, 183, 187, L.needle.deep) end
  for k = 0, 2 do local x = 442 + k * 3 vline(x, 180 + k, 187, L.bamboo.base) vline(x + 1, 180 + k, 187, L.bamboo.shade) px(x, 180 + k, L.bamboo.hi) px(x + 1, 184, L.bamboo.deep) end
  -- terracotta seedling trays under the bench
  for k = 0, 2 do local x = 410 + k * 12 local pot = rect(x, 192, x + 8, 195) fill(pot, L.soil.shade) hline(x, x + 8, 192, L.soil.base) px(x + 2, 191, L.leaf.hi) px(x + 5, 191, L.leaf.base) end
end
pottingBench()
-- calabash stingless-bee hives on a bamboo bench at the right edge, palm-leaf caps
local function hives()
  local bench = rect(410, 214, 462, 216):add(rect(412, 217, 414, 224)):add(rect(458, 217, 460, 224))
  F.shadow(410, 462, 224, 6, 2)
  rimOf(bench, L.timber) part(bench, L.bamboo, { nopop = true, noshade = true }) hline(410, 462, 214, L.bamboo.hi)
  for k = 0, 2 do
    local x = 420 + k * 16
    local gd = c:ellipse(x, 206, 7, 7):add(c:ellipse(x, 199, 3, 3))
    local cap = poly{ { x - 7, 196 }, { x, 189 }, { x + 7, 196 } }:add(rect(x - 7, 196, x + 7, 197))
    rimOf(union(gd, cap), L.timber)
    part(gd, CAL)
    gd:each(function(xx, yy)
      if (xx - x) + (yy - 206) < -6 then px(xx, yy, CAL.hi) end
      if hash(xx // 2, yy // 2, 40 + k) < .06 then px(xx, yy, L.moss.base) end
    end)
    hline(x - 5, x + 5, 199, CAL.deep) hline(x - 6, x + 6, 202, CAL.shade) hline(x - 7, x + 7, 211, CAL.shade) hline(x - 5, x + 5, 213, CAL.shade)
    part(cap, L.roof, { nopop = true }) F.palmThatch(cap, L.roof, 190, x, 70 + k)
    for xx = x - 6, x + 6, 2 do px(xx, 198, L.roof.deep) end
    -- the little wax entrance tube
    fill(rect(x - 2, 206, x + 2, 209), L.produce.shade) hline(x - 2, x + 2, 206, L.produce.base) fill(rect(x - 1, 207, x + 1, 208), L.timber.edge) hline(x - 3, x + 3, 210, L.board.base) px(x - 3, 211, L.timber.edge)
  end
  for i = 0, 9 do local bx, by = 412 + floor(hash(i, 1, 3) * 50), 182 + floor(hash(i, 2, 3) * 14) px(bx, by, L.timber.deep) px(bx, by - 1, L.wet) end
end
hives()
-- mossy stone herb spiral, bottom-left: gotu kola, coleus, a bromeliad on top
local function spiral(cx, cy)
  F.shadow(cx - 36, cx + 40, cy + 14, 8, 3)
  local COL1 = F.rp("#f2a0b4 #c8507a #96305e #682246 #44162e") -- coleus magenta
  local tiers = { { 40, 13, 0, L.fern }, { 28, 9, 9, COL1 }, { 16, 6, 17, L.leaf } }
  for i, t in ipairs(tiers) do
    local rx, ry, up, rr = t[1], t[2], t[3], t[4]
    local top = c:ellipse(cx, cy - up - 4, rx, ry)
    local body = union(top, c:ellipse(cx, cy - up, rx, ry))
    rimOf(body, L.stone)
    local face = c:ellipse(cx, cy - up, rx, ry):cut(top)
    face:each(function(x, y)
      local k = (x + (y % 4 < 2 and 0 or 3)) % 6
      px(x, y, (k == 0 or y % 4 == 0) and L.stone.deep or ((x < cx - rx // 2) and L.stone.hi or L.stone.base))
    end)
    F.moss(face, .26, 50 + i)
    F.shine(face, .1, 55 + i)
    fill(top, L.soil.shade)
    top:each(function(x, y)
      local v = hash(x, y, i * 7)
      if v < .45 then px(x, y, rr.base) elseif v < .55 then px(x, y, rr.hi) elseif v < .7 then px(x, y, rr.shade) end
      if i == 2 and hash(x, y, 77) < .12 then px(x, y, L.leaf.hi) end         -- coleus lime margins
      if i == 1 and hash(x, y, 78) < .05 then px(x, y, L.vine.hi) end         -- round gotu kola leaves
    end)
    c:edgeIn(top, L.stone.base)
  end
  -- a red bromeliad crowning the spiral
  local bx, by = cx, cy - 22
  for _, b in ipairs({ { -5, -2 }, { -3, -5 }, { 0, -6 }, { 3, -5 }, { 5, -2 } }) do
    line({ { bx, by }, { bx + b[1], by + b[2] } }):each(function(x, y) px(x, y, b[1] <= 0 and L.leaf.base or L.leaf.shade) end)
    px(bx + b[1], by + b[2], L.leaf.hi)
  end
  fill(rect(bx - 1, by - 4, bx + 1, by - 1), L.helic.shade) px(bx - 1, by - 4, L.helic.hi) px(bx, by - 3, L.helic.base) px(bx + 1, by - 1, L.helic.deep)
  for _, p in ipairs({ { cx - 28, cy - 6 }, { cx + 18, cy - 4 }, { cx - 8, cy - 16 } }) do px(p[1], p[2], L.orchid.hi) px(p[1] + 1, p[2], L.gold.hi) end
end
spiral(74, 248)
-- torch gingers and heliconias along the left
torchGinger(26, 206, 44, 1, L.petal)
F.heliconia(38, 209, 26, 71)
torchGinger(50, 208, 50, 2, L.apple)
F.heliconia(64, 206, 22, 72)
torchGinger(78, 209, 40, 3, L.petal)
-- ferns tucked along the hut foot and the left edge
for _, f in ipairs({ { 90, 190, 6 }, { 190, 190, 5 }, { 12, 216, 7 }, { 98, 214, 5 }, { 214, 238, 6 } }) do F.fern(f[1], f[2], f[3]) end
F.puddle(118, 200, 7, 4) F.puddle(250, 196, 4, 5)
-- gnome harvesting with a woven basket of herbs and chillies
local _, gx, gy = F.gnome(268, 218, { hat = BAS, coat = L.fern, arm = "out" })
local bsk = poly{ { gx - 1, gy - 1 }, { gx + 11, gy - 1 }, { gx + 9, gy + 6 }, { gx + 1, gy + 6 } } rimOf(bsk, L.needle) part(bsk, L.needle)
bsk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) elseif (x - y) % 4 == 0 then px(x, y, L.needle.hi) end end)
for k = 0, 4 do
  local col = ({ BAS, L.leaf, CHL, LEM, TUR })[k + 1]
  px(gx + 1 + k * 2, gy - 2, col.base) px(gx + 1 + k * 2, gy - 3, col.hi)
end
px(gx + 4, gy - 4, LEM.hi) px(gx + 5, gy - 5, LEM.base)
-- the waterer, tipping a bamboo water tube over the herb spiral
local _, wx, wy = F.gnome(164, 254, { hat = L.awnA, coat = L.wall2, arm = "out", flip = true })
local tube = line({ { wx + 2, wy + 1 }, { wx - 14, wy - 5 } }, 3)
rimOf(tube, L.timber) part(tube, L.bamboo, { nopop = true })
tube:each(function(x, y) if (x - wx) % 6 == 0 then px(x, y, L.bamboo.deep) end end)
line({ { wx + 1, wy - 1 }, { wx - 13, wy - 6 } }):each(function(x, y) if tube:has(x, y) then px(x, y, L.bamboo.hi) end end)
for k = 0, 5 do px(wx - 16 - k, wy - 4 + k * 2, L.water.hi) px(wx - 15 - k, wy - 3 + k * 2, L.water.base) end
-- a blue poison-dart frog on the near bed's bamboo edge
F.sprite({ "..BBB.", ".BkBkB", "BBYBBb", "bBBBbb", "b.b.bb" }, 335, 237, { B = "#4a8ad8", k = L.timber.edge, b = "#2c4c9c", Y = L.gold.hi })
-- leafcutter ants carrying leaf bits from the beds across the road
for i = 0, 14 do
  local t = i / 14
  local x, y = floor(296 - t * 70 + sin(t * 9) * 2 + .5), floor(250 + t * 6 + .5)
  px(x, y, L.timber.edge) px(x + 1, y, L.timber.edge) px(x - 1, y + 1, L.timber.edge) px(x + 1, y + 1, L.timber.edge)
  if i % 2 == 0 then px(x, y - 1, L.leaf.hi) px(x + 1, y - 1, L.leaf.base) px(x, y - 2, L.leaf.base) px(x + 1, y - 2, L.leaf.shade) end
end
-- a fairy ring of orange jungle fungi by the hut
for k = 0, 7 do
  local a = k / 8 * 2 * pi
  F.mushroom(floor(132 + cos(a) * 12 + .5), floor(206 + sin(a) * 3 + .5), (k % 3 == 0) and L.helic or L.produce, false)
end
F.mushroom(206, 222, L.apple, true) F.mushroom(211, 224, L.produce)
-- an orchid-wreathed mossy stump by the shade house with a trug of cut lemongrass
do
  local body = rect(36, 152, 45, 162)
  local tp = c:ellipse(40, 152, 5, 2)
  rimOf(union(body, tp), L.timber) part(body, L.timber, { nopop = true })
  body:each(function(x, y) if x > 42 then px(x, y, L.timber.shade) end end)
  fill(tp, L.board.base) px(40, 152, L.board.shade) px(37, 151, L.board.hi)
  F.moss(body, .3, 91)
  F.orchid(44, 158, L.orchid, 2)
  local tr = poly{ { 52, 156 }, { 64, 156 }, { 62, 162 }, { 54, 162 } }
  rimOf(tr, L.needle) part(tr, L.needle) tr:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) end end)
  line({ { 53, 156 }, { 58, 151 }, { 63, 156 } }):each(function(x, y) if y < 156 then px(x, y, L.needle.deep) end end)
  for k = 0, 4 do vline(54 + k * 2, 150 + (k % 2), 155, LEM.base) px(54 + k * 2, 150 + (k % 2), LEM.hi) end
  for _, f in ipairs({ { 28, 162, 6 }, { 70, 160, 5 }, { 82, 166, 4 } }) do F.fern(f[1], f[2], f[3]) end
  F.mushroom(48, 164, L.helic, true)
end
F.depth(0)
-- stingless bees over the hives and the basil, butterflies, hummingbirds at the torch gingers and the passionflower
for i = 0, 14 do local bx, by = 300 + floor(hash(i, 1, 33) * 170), 140 + floor(hash(i, 2, 33) * 80) px(bx, by, L.gold.shade) px(bx + 1, by, L.timber.edge) px(bx, by - 1, L.wet) end
butterfly(330, 128, L.gold.hi, L.gold.base)
butterfly(120, 196, L.produce.hi, L.produce.shade)
butterfly(240, 196, "#5aa8f0", "#2c62b4")
hummer(56, 146)
hummer(206, 92, true)
F.birds({ { 330, 44, 2 }, { 344, 40, 1 }, { 120, 60, 2 } })
-- glazed pots of aloe, lemongrass and an orchid, bottom-right
F.depth(3)
for k, x in ipairs({ 300, 316, 366 }) do
  local pot = poly{ { x - 7, 252 }, { x + 7, 252 }, { x + 5, 264 }, { x - 5, 264 } }
  rimOf(pot, GLZ) part(pot, GLZ) hline(x - 7, x + 7, 252, GLZ.hi) hline(x - 7, x + 7, 254, GLZ.deep)
  pot:each(function(xx, yy) if yy > 255 and (xx + yy) % 5 == 0 and yy < 262 then px(xx, yy, GLZ.shade) end end)
  F.shine(pot, .12, 90 + k)
  if k == 1 then
    for j, b in ipairs({ { -6, -6 }, { -4, -10 }, { -1, -13 }, { 2, -12 }, { 5, -9 }, { 6, -5 } }) do
      line({ { x, 251 }, { x + b[1], 251 + b[2] } }, 2):each(function(xx, yy) px(xx, yy, b[1] < 0 and ALOE.base or ALOE.shade) end)
      px(x + b[1], 251 + b[2], ALOE.hi)
      if j % 2 == 0 then px(x + b[1] // 2, 251 + b[2] // 2, ALOE.hi) end
    end
  elseif k == 2 then
    for j = -3, 3 do
      local tx, ty = x + j * 2 + (j < 0 and -1 or 1) * (abs(j) // 2), 251 - 18 + abs(j) * 2
      line({ { x + j // 2, 251 }, { tx, ty } }):each(function(xx, yy) px(xx, yy, j <= 0 and LEM.base or LEM.shade) end)
      px(tx, ty, LEM.hi)
    end
  else
    F.bigLeaf(x - 1, 248, 12, -pi * .7, L.foliage, 93, 4, { heart = true, stem = { x, 251 } })
    F.orchid(x + 1, 244, L.orchid, 2)
  end
end
F.finish()
