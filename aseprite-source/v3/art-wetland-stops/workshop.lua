-- workshop.lua : "Workshop" stop look, WETLAND (wetland_reed), 480x270 gate view.
-- Same composition as the Maplewold workshop (art-2701-batch3/stops/opus3/workshop.lua), re-cast as a fen
-- basket-weaver's and thatcher's yard:
-- road's end: the timber gantry hoisting a great reed bundle over a yard of bundles stacked end-on, drying rush
-- bunches hung from the beam. Back left: a tarred withy shed, a soaking pit of osier bundles standing in water, a
-- peat stack. Back right: a punt under construction on trestles (ribs up, one strake short), a boat-builder at the
-- stern with a tar pot, an osier holt of coppiced willow stools behind. Left hero: the withy boiler: a brick peat
-- hearth under a sedge-thatched lean-to, a riveted copper tank with rods steaming in it, chimney with peat smoke,
-- coils of rods hung on the posts; a gnome stripping bark through a willow brake (curls flying), a heap of buff
-- stripped rods, a soaking tub; an otter asleep in the warmth. Right hero: the weaver's wattle-and-daub workshop with
-- golden thatch and an open front: baskets, a creel, a trug and an eel trap hung on the back wall, the weaver at a
-- half-made basket, rod bundles inside, a basket sign. Foreground: a thatcher dressing a reed bundle on a trestle with
-- a leggett, a big peat clamp with a reed cap, a creel of turves, a spar block with billhook and hazel spars, a stack
-- of finished baskets, a soaking pool with coiled withies and a moorhen, a big log basket half woven, a gnome
-- carrying three baskets on his head.
-- Quirk: a reed warbler has woven its nest (three gaping chicks) round reed stems tied to the gantry beam - the
-- parent, in a tiny red gnome hat, brings a blue damselfly.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-wetland-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "workshop", out = DIR, farTrees = { 24, 52, 160, 300, 330, 440 },
  treeLineGap = { 198, 290 }, poolK = .8 }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, max, min = math.floor, math.sin, math.cos, math.pi, math.max, math.min
local IR, G = L.iron, L.glow
local TAR = F.rp("#8a8c80 #64685e #4a4e48 #363a36 #24282a")      -- tarred weatherboard
local OSIER = F.rp("#c8968a #9a665c #764a46 #553436 #382426")    -- purple osier rods, bark on
local BUFF = F.rp("#f0deb0 #d6bc86 #b09664 #84704c #544632")     -- boiled and stripped buff rods
local TURF = F.rp("#8e6e52 #664a36 #4c362a #34261e #22181a")     -- cut peat turves
local BRICK = F.rp("#d8a282 #b4765a #8c5646 #643c34 #402624")    -- soft red hearth brick
local WATTLE = F.rp("#cdb48a #a88e66 #84704e #5e4e3a #3c3228")    -- hazel wattle under daub
local COPPER = F.rp("#f2b47e #cc7c4c #a05836 #703c2c #48261e")   -- the boiling copper

---------------------------------------------------------------- local helpers
local LV = { "deep", "shade", "base", "hi" }
-- basket weave over a mask: horizontal weavers 2 px tall passing over/under stakes every sw px, lit on the left
local function weave(m, r, cx, w, y0, sw)
  sw = sw or 3
  m:each(function(x, y)
    local row = (y - y0) // 2
    local seg = (x + 300) // sw
    local u = (x - cx) / max(1, w)
    local lv = 3
    if u < -.4 then lv = 4 elseif u > .45 then lv = 2 end
    if (seg + row) % 2 == 0 then if (y - y0) % 2 == 0 then lv = lv + 1 end
    else lv = lv - 1 if (x + 300) % sw == 0 then lv = lv - 1 end end
    px(x, y, r[LV[max(1, min(4, lv))]])
  end)
end
-- a basket seen from the front: tapered woven body, twisted rim border, optional handle / lid / unwoven stakes
-- o.handle, o.lid, o.stakes = fraction woven (0..1: above it only the stakes stand up), o.fill = function(x0,x1,y)
local function basket(x, yb, w, h, r, o)
  o = o or {}
  local top = yb - h
  local body = poly{ { x - w + 2, yb }, { x + w - 2, yb }, { x + w, top }, { x - w, top } }
  local woven, stakes = body, HP.mask()
  if o.stakes then
    local wy = floor(yb - h * o.stakes)
    woven = body:copy():clip(rect(x - w - 1, wy, x + w + 1, yb))
    for sx = x - w + 1, x + w - 1, 3 do
      local lean = (sx - x) / w
      stakes:add(line({ { sx, wy }, { floor(sx + lean * 3 + .5), top - 3 } }))
    end
  end
  local band = o.stakes and HP.mask() or rect(x - w - 1, top - 2, x + w + 1, top)
  local handle = HP.mask()
  if o.handle then handle = c:ellipse(x, top - 1, w - 2, floor(h * .7)):cut(c:ellipse(x, top - 1, w - 4, floor(h * .7) - 2)):clip(rect(x - w, top - h, x + w, top - 2)) end
  local lid = HP.mask()
  if o.lid then lid = c:rrect(x - w - 1, top - 5, x + w + 1, top - 2, 2) end
  local sil = union(woven, stakes, band, handle, lid)
  rimOf(sil, r)
  weave(woven, r, x, w, top)
  if not o.stakes then
    band:each(function(xx, yy) px(xx, yy, yy == top and r.deep or (((xx + yy) // 2) % 2 == 0 and r.hi or r.shade)) end)
    if o.fill then o.fill(x - w, x + w, top - 2) end
  end
  stakes:each(function(xx, yy) px(xx, yy, (xx < x) and r.hi or r.base) end)
  handle:each(function(xx, yy) px(xx, yy, ((xx + yy) % 3 == 0) and r.shade or ((xx < x) and r.hi or r.base)) end)
  if o.lid then weave(lid, r, x, w, top - 5, 4) hline(x - w, x + w, top - 2, r.deep) fill(rect(x - 1, top - 7, x + 1, top - 6), r.shade) end
  hline(x - w + 3, x + w - 3, yb, r.deep)
  return sil
end
-- an eel trap (grig): a wicker cone lying left-right, mouth (dark) on the left, hoops round it, tied tail
local function eelTrap(x0, x1, y, rad, r)
  local m = poly{ { x0, y - rad }, { x1 - 3, y - 1 }, { x1, y }, { x1 - 3, y + 1 }, { x0, y + rad } }
  rimOf(m, r)
  m:each(function(x, yy)
    local t = (x - x0) / max(1, x1 - x0)
    local h = (yy < y - rad * (1 - t) * .3) and r.hi or (yy > y + rad * (1 - t) * .4 and r.shade or r.base)
    if (x + (yy - y) // 2) % 3 == 0 then h = r.shade end
    if (x - x0) % 6 == 2 then h = r.deep end
    px(x, yy, h)
  end)
  local mo = c:ellipse(x0, y, 1, max(1, rad - 1)) fill(mo, L.soil.deep)
  px(x1 + 1, y, L.timber.deep)
  return m
end
-- a tied reed sheaf standing (side view)
local function sheaf(x, yb, h, r)
  r = r or L.reed
  local w = max(2, h // 4)
  local m = poly{ { x - w, yb }, { x + w, yb }, { x + w - 1, yb - h + 2 }, { x, yb - h }, { x - w + 1, yb - h + 2 } }
  rimOf(m, r) part(m, r, { nopop = true })
  m:each(function(xx, yy) if (xx - x) % 2 == 0 and yy > yb - h + 2 then px(xx, yy, xx < x and r.hi or r.shade) end end)
  local by = yb - floor(h * .45)
  hline(x - w, x + w, by, L.timber.deep) hline(x - w + 1, x + w - 1, by - 1, L.timber.base)
  return m
end
-- the cut end of a reed bundle seen face-on
local function bundleEnd(x, y, r, rr)
  rr = rr or L.reed
  local m = c:ellipse(x, y, r, r)
  c:rim(m, rr.edge)
  m:each(function(xx, yy)
    local d = (xx - x) + (yy - y)
    local col = d < -r * .6 and rr.hi or (d > r * .6 and rr.shade or rr.base)
    if (xx + yy * 2) % 3 == 0 then col = (d < 0) and rr.base or rr.deep end
    px(xx, yy, col)
  end)
  px(x, y, rr.deep)
  return m
end
-- a reed bundle lying left-right: plume (head) end tapering on the left, two bands, the butt disc on the right
local function bundleSide(x0, x1, y, r, rr)
  rr = rr or L.reed
  local m = poly{ { x0, y - r + 2 }, { x1 - r, y - r }, { x1 - r, y + r }, { x0, y + r - 1 } }
  rimOf(m, rr) part(m, rr, { nopop = true })
  m:each(function(x, yy)
    if (yy + x // 9) % 2 == 0 then px(x, yy, yy < y and rr.hi or rr.base) end
    if yy >= y + r - 1 then px(x, yy, rr.shade) end
  end)
  for _, bx in ipairs({ x0 + (x1 - x0) // 3, x0 + 2 * (x1 - x0) // 3 }) do vline(bx, y - r + 1, y + r - 1, L.timber.deep) vline(bx + 1, y - r + 1, y + r - 1, L.timber.base) end
  for k = 0, r do px(x0 - 1 - (k % 2), y - r // 2 + k, k % 2 == 0 and L.plume.base or L.plume.hi) end
  bundleEnd(x1 - r, y, r, rr)
  return m
end
-- a rod bundle standing upright (osier withies), tied twice, tips fanning
local function rodBundle(x, yb, h, r, w)
  w = w or 2
  local m = poly{ { x - w, yb }, { x + w, yb }, { x + w + 1, yb - h }, { x - w - 1, yb - h } }
  rimOf(m, r)
  m:each(function(xx, yy) px(xx, yy, ((xx - x) % 2 == 0) and ((xx < x) and r.hi or r.base) or r.shade) end)
  for _, by in ipairs({ yb - h // 4, yb - (h * 2) // 3 }) do hline(x - w - 1, x + w + 1, by, L.timber.deep) end
  for k = -w - 1, w + 1, 2 do px(x + k + (k > 0 and 1 or (k < 0 and -1 or 0)), yb - h - 1, r.base) px(x + k + (k > 0 and 1 or 0), yb - h - 2, r.hi) end
  return m
end
-- one peat turf (cut block): lit top face, fibrous speckle, root threads
local function turfFace(x0, y0, w, h)
  local m = rect(x0, y0, x0 + w - 1, y0 + h - 1)
  m:each(function(x, y)
    local v = hash(x, y, 91)
    local col = (y == y0) and TURF.hi or ((x == x0 + w - 1 or y == y0 + h - 1) and TURF.deep or TURF.base)
    if y > y0 and y < y0 + h - 1 and x < x0 + w - 1 then
      if v < .12 then col = TURF.shade elseif v > .93 then col = TURF.hi elseif v > .9 then col = L.peat.hi end
    end
    px(x, y, col)
  end)
  return m
end
-- a stacked turf clamp: rows of turves in brick bond, narrowing upward
local function peatStack(x0, yb, n, tw, th, cap)
  local m, cells = HP.mask(), {}
  for row = 0, n - 1 do
    local cnt = n - row
    for k = 0, cnt - 1 do
      local x = x0 + row * (tw // 2) + k * tw
      local y = yb - (row + 1) * th
      m:add(rect(x, y, x + tw - 1, y + th - 1))
      cells[#cells + 1] = { x, y }
    end
  end
  F.shadow(x0, x0 + n * tw, yb, 8, 3)
  rimOf(m, TURF)
  for _, cl in ipairs(cells) do turfFace(cl[1], cl[2], tw, th) end
  if cap then -- a little reed thatch cap on top
    local cx = x0 + (n * tw) // 2
    local ty = yb - n * th
    local cm = poly{ { cx - tw - 3, ty + 2 }, { cx, ty - 7 }, { cx + tw + 3, ty + 2 } }
    rimOf(cm, L.roof) part(cm, L.roof, { nopop = true }) F.thatch(cm, L.roof, ty - 7, cx)
    hline(cx - tw - 2, cx + tw + 2, ty + 2, L.roof.deep)
    px(cx, ty - 8, L.timber.base)
  end
  return m
end
-- a bunch of rushes hung upside down to dry: tied knot at the top, stems spreading down
local function hangBunch(x, y, len, r)
  for k = -2, 2 do
    line({ { x, y + 1 }, { x + k, y + len - math.abs(k) } }):each(function(xx, yy) px(xx, yy, k < 0 and r.hi or (k == 0 and r.base or r.shade)) end)
  end
  px(x, y, L.timber.deep) px(x, y + 1, L.timber.base) px(x - 1, y + 1, L.timber.deep) px(x + 1, y + 1, L.timber.deep)
  vline(x, y - 3, y - 1, L.board.deep)
end
-- a coil of soaked rods (a ring seen at an angle)
local function coil(x, y, rx, ry, r)
  for k = 0, 2 do
    local m = c:ellipse(x, y - k, rx - k, ry):cut(c:ellipse(x, y - k, rx - k - 2, max(0, ry - 2)))
    m:each(function(xx, yy) px(xx, yy, (yy < y - k) and (xx < x and r.hi or r.base) or (k % 2 == 0 and r.shade or r.deep)) end)
  end
end

---------------------------------------------------------------- far right: osier holt (coppiced willow stools in rows)
F.depth(1)
F.mist(150, 196, 116, 120, 64, .5)
for row = 0, 2 do
  local y = 120 + row * 7
  for x = 386 + row * 3, 470, 9 do
    local s = hash(x, row, 70)
    local h = 7 + floor(s * 5) + row
    fill(rect(x - 1, y - 1, x + 1, y), L.willowBark.shade) px(x - 1, y - 1, L.willowBark.hi)
    for k = -3, 3 do
      local tx = x + k * 2 + (k > 0 and 1 or 0)
      local r = ((k + row + floor(s * 3)) % 3 == 0) and L.reedGreen or OSIER
      line({ { x + (k > 0 and 1 or 0), y - 1 }, { tx, y - h + math.abs(k) } }):each(function(xx, yy) px(xx, yy, k < 0 and r.base or r.shade) end)
      px(tx, y - h + math.abs(k) - 1, L.willow.hi) px(tx + 1, y - h + math.abs(k), L.willow.base)
    end
  end
end

---------------------------------------------------------------- back-left: tarred withy shed, soaking pit, peat stack
F.depth(1)
F.tree(84, 130, 40, 0)
local _, _, shWall = F.building{ x0 = 22, x1 = 70, yb = 138, wh = 26, rh = 20, wall = TAR, roof = L.roof2, noAttic = true, noFrame = true }
F.planks(shWall:copy():clip(rect(22, 114, 70, 138)), TAR, 4, true, 23)
F.door(36, 120, 50, 137, L.timber)
hangBunch(58, 117, 9, L.reed) hangBunch(64, 117, 8, L.reedGreen)
eelTrap(54, 68, 131, 3, BUFF)
-- the soaking pit: osier bundles standing in water to keep them supple
peatStack(156, 138, 4, 9, 4, true)

---------------------------------------------------------------- road's end: reed-bundle yard + gantry hoist
F.depth(2)
local function gantry()
  -- bundles stacked end-on (left) and lying (right)
  for row = 0, 3 do for k = 0, 4 - row do bundleEnd(207 + k * 7 + row * 3, 122 - row * 6, 3) end end
  bundleSide(244, 282, 121, 4) bundleSide(248, 284, 113, 4) bundleSide(244, 276, 105, 3)
  local legL = line({ { 200, 126 }, { 210, 54 } }, 3):add(line({ { 220, 126 }, { 212, 54 } }, 2))
  local legR = line({ { 284, 126 }, { 274, 54 } }, 3):add(line({ { 264, 126 }, { 272, 54 } }, 2))
  local beam = rect(198, 50, 290, 55)
  local brace = line({ { 213, 70 }, { 228, 56 } }, 2):add(line({ { 271, 70 }, { 256, 56 } }, 2))
  F.shadow(200, 286, 127, 8, 3)
  rimOf(union(legL, legR, beam, brace), L.timber)
  part(legL, L.timber, { nopop = true }) part(legR, L.timber, { nopop = true }) part(brace, L.timber, { nopop = true, noshade = true })
  part(beam, L.timber) hline(198, 290, 50, L.timber.hi)
  for x = 200, 288, 11 do px(x, 53, L.timber.deep) px(x + 1, 52, L.moss.base) end
  -- rush bunches drying under the beam
  for _, b in ipairs({ { 231, 57, 9, L.reedGreen }, { 248, 57, 10, L.reed }, { 253, 57, 8, L.reedGreen } }) do hangBunch(b[1], b[2], b[3], b[4]) end
  -- pulley, rope, sling, the hoisted reed bundle
  local pul = c:ellipse(238, 58, 3, 3) rimOf(pul, IR) part(pul, IR)
  vline(238, 61, 80, L.board.deep) vline(240, 58, 78, L.board.deep)
  fill(rect(236, 80, 241, 81), IR.base)
  fill(line({ { 224, 86 }, { 238, 81 }, { 254, 86 } }), L.board.deep)
  bundleSide(214, 264, 92, 6)
  hline(222, 226, 86, L.board.deep) vline(224, 86, 98, L.board.deep) vline(254, 86, 98, L.board.deep)
  for k = 0, 3 do px(216 + k * 3, 99 + (k % 2), L.reed.hi) end -- loose straws falling
  -- winch drum at the right leg
  local drum = rect(268, 106, 282, 112) rimOf(drum, L.timber) part(drum, L.board) for x = 270, 280, 2 do vline(x, 106, 112, L.board.deep) end
  fill(rect(282, 104, 288, 105), IR.base) fill(rect(287, 104, 288, 112), IR.base)
  vline(276, 56, 105, L.board.deep)
  F.gnome(296, 126, { small = true, hat = L.roof2, coat = L.leaf, arm = "out", flip = true })
  F.depth(3)
  -- quirk: a reed warbler's woven nest slung on three reed stems tied to the beam, three chicks gaping
  for _, sx in ipairs({ 263, 272, 281 }) do vline(sx, 36, 49, L.reedGreen.base) px(sx, 35, L.plume.base) px(sx + 1, 34, L.plume.hi) end
  F.sprite({
    "..y.......y.......y...",
    ".yYy.....yYy.....yYy..",
    "..gg......gg......gg..",
    ".gegg....gegg....gegg.",
    "nnggnnnnnnggnnnnnnggnn",
    "nNnnHnNnnNnnHnNnnNnnHn",
    ".nNHnnNnHnNnnHNnnNnHn.",
    "..nnNnHnNnnnNnHnNnn...",
  }, 262, 42, { y = L.marigold.hi, Y = L.produce.shade, g = L.goose.base, e = L.timber.edge, n = L.reed.base, N = L.reed.deep, H = L.reed.hi })
  -- the parent warbler in a tiny red gnome hat, a damselfly in its beak
  F.sprite({
    ".......R.........",
    "......RRr........",
    ".....RRRr........",
    "....RRRRRr.......",
    "....hhhhhhh......",
    "....bbebbbkkdddDD",
    "...bbbbbbbk......",
    "..BBwwwwbb.......",
    ".BBBwwwwwb.......",
    "BBBBwwwbbb.......",
    "..BB.bbb.........",
    ".....o.o.........",
  }, 286, 36, { b = L.reed.shade, B = L.reed.deep, e = L.timber.edge, k = L.timber.deep, w = L.awnB.base, R = L.awnA.base, r = L.awnA.shade,
    h = L.awnA.deep, d = L.accent.base, D = L.accent.hi, o = L.timber.shade })
  px(298, 40, "#e4e2d0") px(299, 40, "#e4e2d0") px(298, 42, "#c8c8b8") px(299, 42, "#c8c8b8") -- damselfly wings
end
gantry()

---------------------------------------------------------------- back-right: punt under construction, tar pot, alder
F.depth(2)
local function puntBuild()
  -- the boat-builder behind the hull, mallet raised
  F.gnome(322, 124, { hat = L.awnA, coat = L.wall2, arm = "up" })
  fill(rect(327, 95, 332, 98), L.timber.base) px(327, 95, L.board.hi) rimOf(rect(327, 95, 332, 98), L.timber) vline(330, 99, 101, L.board.base)
  local hull = poly{ { 298, 117 }, { 304, 121 }, { 340, 121 }, { 348, 116 }, { 350, 118 }, { 342, 130 }, { 306, 130 }, { 296, 119 } }
  local ribs = HP.mask()
  for x = 322, 340, 5 do ribs:add(rect(x, 115, x, 120)) end
  local keel = rect(306, 131, 342, 132)
  F.shadow(300, 348, 138, 8, 3)
  rimOf(union(hull, ribs, keel), L.timber)
  part(hull, TAR, { nopop = true }) F.planks(hull, TAR, 3, false, 11)
  -- the upper strake is new bare board on the bow half only; ribs stand up where it is still missing
  local fresh = hull:copy():clip(rect(296, 116, 320, 124))
  fill(fresh, L.board.base) fresh:each(function(x, y) if y == 121 or (y < 121 and not hull:has(x, y - 1)) then px(x, y, L.board.hi) elseif y == 124 then px(x, y, L.board.deep) end end)
  hline(296, 348, 125, TAR.deep)
  for x = 300, 318, 4 do px(x, 122, IR.base) end
  ribs:each(function(x, y) px(x, y, y == 115 and L.board.hi or L.board.base) end)
  part(keel, L.timber, { nopop = true, noshade = true })
  hline(321, 340, 121, L.board.hi)
  -- trestles, a plank and a pot of tar
  for _, x in ipairs({ 310, 336 }) do fill(rect(x, 133, x + 2, 138), L.timber.base) fill(rect(x - 2, 138, x + 4, 139), L.timber.deep) end
  local pl = rect(312, 139, 334, 140) rimOf(pl, L.timber) part(pl, L.board, { nopop = true, noshade = true }) hline(312, 334, 139, L.board.hi)
  local pot = c:rrect(288, 130, 297, 138, 3) rimOf(pot, IR) part(pot, IR, { nopop = true }) hline(289, 296, 130, G.base) hline(290, 295, 131, TAR.edge) px(290, 132, IR.hi) px(291, 133, IR.hi) px(292, 129, L.mist) px(293, 127, L.mist2) px(292, 125, L.mist)
  vline(295, 126, 131, L.timber.base)
end
puntBuild()
F.tree(464, 142, 48, 1)
-- the soaking pit beside the causeway: osier bundles standing in water to keep them supple
F.depth(2)
local pit = poly{ { 199, 150 }, { 219, 148 }, { 222, 168 }, { 201, 170 } }
local pitBank = pit:grow(2):cut(pit)
pitBank:each(function(x, y) local v = hash(x, y, 89) px(x, y, v < .45 and L.peat.base or (v < .7 and L.peat.hi or L.peat.shade)) end)
rimOf(pit, L.peat)
F.water(pit, L.water)
for k = 0, 3 do rodBundle(204 + k * 5, 165 - (k % 2) * 2, 15 + (k % 2) * 3, (k % 2 == 1) and BUFF or OSIER, 1) end
for x = 200, 221 do if hash(x, 1, 88) < .5 then px(x, 166, L.water.hi) end end

---------------------------------------------------------------- left hero: the withy boiler
F.depth(3)
local function boiler()
  local posts = rect(92, 128, 95, 206):add(rect(186, 140, 189, 208))
  local roofm = poly{ { 82, 124 }, { 198, 136 }, { 198, 147 }, { 82, 136 } }
  local hearth = rect(100, 164, 168, 202)
  local chim = rect(124, 84, 140, 150)
  local tank = rect(98, 148, 170, 164)
  F.shadow(94, 194, 208, 12, 5)
  rimOf(union(chim, hearth), BRICK)
  part(chim, BRICK) F.courses(chim, 84, 4, 7, BRICK)
  fill(rect(122, 82, 142, 85), BRICK.shade) hline(122, 142, 82, BRICK.hi) hline(122, 142, 85, BRICK.deep)
  part(hearth, BRICK, { sep = true }) F.courses(hearth, 164, 4, 8, BRICK, 3)
  -- the fire mouth: glowing turves
  local mouth = c:rrect(116, 172, 152, 200, 8):clip(rect(116, 172, 152, 194))
  fill(mouth, L.soil.deep)
  hline(114, 154, 171, BRICK.deep) for x = 116, 152, 4 do px(x, 171, BRICK.hi) end
  for k = 0, 5 do
    local tx, ty = 120 + k * 5 + (k % 2), 188 - (k % 2) * 3
    local t = rect(tx, ty, tx + 5, ty + 3)
    fill(t, TURF.deep) hline(tx, tx + 5, ty, G.shade) px(tx + 1, ty, G.base) px(tx + 5, ty + 1, G.shade)
  end
  local flame = poly{ { 122, 188 }, { 126, 180 }, { 129, 184 }, { 133, 176 }, { 137, 183 }, { 141, 178 }, { 146, 188 } }
  fill(flame, G.base) fill(poly{ { 128, 188 }, { 133, 180 }, { 138, 188 } }, G.hi)
  for x = 120, 148 do if hash(x, 2, 44) < .4 then px(x, 192, G.shade) end end
  hline(112, 156, 196, BRICK.hi) hline(112, 156, 197, BRICK.deep)
  -- the riveted copper tank on the hearth, rods steaming in it
  F.depth(3)
  rimOf(tank, COPPER)
  part(tank, COPPER)
  vline(99, 149, 163, COPPER.hi) vline(100, 150, 162, COPPER.hi)
  for _, y in ipairs({ 150, 162 }) do hline(98, 170, y + (y == 150 and 1 or 0), COPPER.shade) for x = 101, 168, 5 do px(x, y, COPPER.hi) px(x, y + 1, COPPER.deep) end end
  tank:each(function(x, y) if y > 152 and y < 161 and hash(x // 3, y, 45) < .07 then px(x, y, L.accent.shade) end end) -- verdigris
  hline(98, 170, 148, COPPER.hi)
  fill(rect(100, 146, 168, 147), L.water.shade) hline(102, 166, 146, L.water.base)
  -- rods leaning out of the boil
  for k = 0, 11 do
    local x0 = 104 + k * 5
    local lean = (k < 6) and -1 or 1
    local x1, y1 = x0 + lean * (6 + (k % 3) * 2), 132 + (k % 4) * 2
    local r = (k % 3 == 0) and BUFF or OSIER
    line({ { x0, 147 }, { x1, y1 } }):each(function(xx, yy) px(xx, yy, r.base) end)
    line({ { x0 + 1, 147 }, { x1 + 1, y1 } }):each(function(xx, yy) px(xx, yy, ((xx + yy) % 3 == 0) and r.deep or r.shade) end)
  end
  -- steam under the roof
  for _, s in ipairs({ { 108, 142, 4 }, { 120, 139, 3 }, { 150, 141, 4 }, { 162, 140, 3 }, { 114, 136, 2 }, { 156, 135, 2 } }) do
    local m = c:ellipse(s[1], s[2], s[3], max(1, s[3] - 1))
    fill(m, L.mist2) m:each(function(x, y) if not m:has(x + 1, y + 1) then px(x, y, L.mist) end end) px(s[1] - 1, s[2] - 1, "#eee6cc")
  end
  -- lean-to roof of old sedge thatch on posts
  rimOf(union(posts, roofm), L.timber)
  part(posts, L.timber, { nopop = true })
  posts:each(function(x, y) if hash(x, y // 3, 46) < .15 then px(x, y, L.timber.shade) end end)
  part(roofm, L.roof2, { sep = true }) F.thatch(roofm, L.roof2, 124)
  line({ { 82, 124 }, { 198, 136 } }):each(function(x, y) px(x, y, L.roof2.hi) end)
  line({ { 82, 136 }, { 198, 147 } }):each(function(x, y) px(x, y, L.roof2.deep) px(x, y - 1, L.roof2.shade) end)
  for x = 84, 196, 3 do local y = floor(136 + (x - 82) * 11 / 116) + 1 if hash(x, 1, 47) < .6 then px(x, y, L.roof2.shade) if hash(x, 2, 47) < .4 then px(x, y + 1, L.roof2.deep) end end end
  F.moss(roofm:copy():clip(rect(82, 125, 120, 140)), .07, 48)
  -- chimney passes the roof
  local chUp = rect(124, 84, 140, 129)
  part(chUp, BRICK) F.courses(chUp, 84, 4, 7, BRICK)
  vline(124, 86, 129, BRICK.hi)
  F.smoke(132, 78, 9, .7, 3)
  -- coils of rods and a little basket on the left post, a rush bunch and a bodkin on the right post
  for k = 0, 1 do coil(94, 154 + k * 11, 5, 4, k == 0 and OSIER or BUFF) end
  basket(94, 186, 4, 6, BUFF, { handle = true })
  hangBunch(184, 148, 12, L.reedGreen) hangBunch(191, 150, 10, L.reed)
  vline(188, 166, 174, IR.hi) px(188, 165, L.timber.base) px(187, 165, L.timber.base)
  -- fuel turves piled by the hearth
  peatStack(168, 204, 3, 6, 4)
  -- glow cast on the ground
  for y = 203, 214 do for x = 112 + (y - 203), 156 - (y - 203) do if hash(x, y, 7) < .3 then px(x, y, L.roof.hi) elseif hash(x, y, 8) < .08 then px(x, y, G.hi) end end end
end
boiler()

-- an otter asleep in the warmth of the boiler, curled with its tail round its nose
F.sprite({
  "..............hh....",
  "......hhhhhhhhhhhh...",
  "....hhhhhhhhhhhhhhe..",
  "..hhhhhhhhhhhhhhhEe..",
  ".hhhhOOOOOOOOOOcccn..",
  "hhhOOOOOOOOOOOcccccd.",
  "OOOOOOOOOOOOOOOcccdd.",
  "TOOOOOOOOOOOOOOOOdd..",
  ".TTTTTTTTTTTTTTTTd...",
  "..TTT.............",
}, 98, 204, { e = L.soil.deep, E = L.soil.shade, O = L.soil.base, h = L.soil.hi, c = L.awnB.base, d = L.board.shade, n = L.timber.edge, T = L.soil.shade })
for _, p2 in ipairs({ { 101, 208 }, { 103, 207 }, { 106, 206 }, { 110, 206 } }) do px(p2[1], p2[2], L.soil.shade) end
hline(111, 113, 207, L.timber.edge) hline(116, 118, 208, L.awnB.hi) -- shut eye, whiskers -- shut eye
for k = 0, 2 do px(120 + k * 3, 202 - k * 3, L.mist) px(121 + k * 3, 202 - k * 3, L.mist) px(120 + k * 3, 201 - k * 3, L.mist) end -- z z
-- the willow brake: a post with an iron V; a gnome pulling a rod through it, bark curls flying
local function brake(x, yb)
  local post = rect(x - 2, yb - 16, x + 2, yb)
  local prong = line({ { x - 2, yb - 16 }, { x - 4, yb - 23 } }, 2):add(line({ { x + 1, yb - 16 }, { x + 3, yb - 23 } }, 2))
  F.shadow(x - 4, x + 4, yb, 6, 2)
  rimOf(union(post, prong), L.timber)
  part(post, L.timber, { nopop = true }) hline(x - 2, x + 2, yb - 16, L.board.hi)
  part(prong, IR, { nopop = true, noshade = true }) px(x - 4, yb - 23, IR.hi) px(x + 3, yb - 23, IR.hi)
  for k = 0, 2 do fill(rect(x - 2, yb - 12 + k * 4, x + 2, yb - 12 + k * 4), L.timber.deep) end
end
brake(168, 232)
local _, hx, hy = F.gnome(148, 238, { hat = L.awnA, coat = L.soil, arm = "up" })
fill(rect(146, 228, 150, 235), L.soil.shade) px(146, 228, L.soil.base) -- leather apron
-- the rod through the brake: stripped (buff) on the gnome's side, bark still on beyond
line({ { hx - 6, hy + 3 }, { 192, 202 } }):each(function(x, y) local r = (x < 168) and BUFF or OSIER px(x, y, (x < 168) and r.hi or r.base) end)
line({ { hx - 6, hy + 4 }, { 192, 203 } }):each(function(x, y) local r = (x < 168) and BUFF or OSIER px(x, y, r.shade) end)
for i = 0, 10 do
  local cx, cy = 164 + floor(hash(i, 1, 23) * 18), 206 + floor(hash(i, 2, 23) * 22)
  px(cx, cy, OSIER.base) px(cx + 1, cy - 1, OSIER.shade) if i % 2 == 0 then px(cx - 1, cy - 1, OSIER.hi) end
end
-- heap of stripped buff rods on the ground
local heap = poly{ { 108, 238 }, { 112, 232 }, { 138, 229 }, { 142, 234 }, { 140, 238 } }
rimOf(heap, BUFF)
heap:each(function(x, y)
  local k = (y * 3 + x // 11) % 4
  px(x, y, (y <= 231 or (k == 0 and x < 124)) and BUFF.hi or (k == 1 and BUFF.shade or (k == 3 and BUFF.deep or BUFF.base)))
end)
for k = 0, 4 do local y = 230 + k * 2 px(106 - (k % 2), y + 3, BUFF.base) px(143 + (k % 2), y + 1, BUFF.shade) end
-- the soaking tub of rods waiting their turn
local tub = F.barrel(198, 238, F.rp("#d8a870 #b07c48 #8a5a38 #623e2a #3e281c"), 12)
for k = 0, 8 do
  local x0 = 193 + k
  line({ { x0, 226 }, { x0 + (k - 4) * 2, 202 + (k % 3) * 3 } }):each(function(x, y) px(x, y, (k % 2 == 0) and OSIER.base or OSIER.shade) end)
end
fill(rect(193, 225, 203, 226), L.water.base) px(194, 225, L.water.hi) px(200, 225, L.water.hi)

---------------------------------------------------------------- right hero: the weaver's wattle-and-daub workshop
local function workshop()
  local x0, x1, yb = 296, 446, 208
  local top, cx, wallM = F.building{ x0 = x0, x1 = x1, yb = yb, wh = 56, rh = 36, wall = L.plaster, roof = L.roof }
  -- daub fallen away in patches, the wattle hurdle showing through
  for _, p in ipairs({ { 300, 160, 318, 176, 1 }, { 424, 158, 442, 172, 2 }, { 340, 157, 352, 163, 3 } }) do
    local wm = HP.mask()
    rect(p[1], p[2], p[3], p[4]):each(function(x, y)
      local ex = min(x - p[1], p[3] - x, (y - p[2]) * 2, (p[4] - y) * 2)
      if ex > 2 or hash(x, y, 30 + p[5]) < ex / 3 then wm:set(x, y) end
    end)
    wm:clip(wallM)
    weave(wm, WATTLE, (p[1] + p[3]) // 2, (p[3] - p[1]) // 2, p[2], 3)
    wm:grow(1):cut(wm):clip(wallM):each(function(x, y) px(x, y, L.plaster.deep) end)
  end
  -- the gable infilled with bundled reed, hazel liggers across it
  local gab = poly{ { x0 + 6, top - 1 }, { cx, top - 36 + 9 }, { x1 - 6, top - 1 } }
  gab:each(function(x, y)
    local h = (x % 2 == 0) and ((x < cx) and L.reed.hi or L.reed.base) or ((x < cx) and L.reed.base or L.reed.shade)
    if (y - top) % 7 == 0 then h = L.timber.base elseif (y - top) % 7 == 1 then h = L.reed.deep end
    px(x, y, h)
  end)
  F.window(cx - 3, top - 17, cx + 2, top - 13, L.timber)
  -- big open front with the interior
  local dx0, dx1, dy0 = 322, 420, 166
  fill(rect(dx0 - 2, dy0 - 2, dx1 + 2, yb), L.timber.base) hline(dx0 - 2, dx1 + 2, dy0 - 2, L.timber.hi)
  fill(rect(dx0, dy0, dx1, yb), L.soil.deep)
  fill(rect(dx0, yb - 6, dx1, yb), L.soil.shade)
  rect(dx0, yb - 6, dx1, yb):each(function(x, y) if hash(x, y, 31) < .1 then px(x, y, L.soil.base) end end)
  -- back wall: a peg rail with the stock hung up
  local bw = rect(dx0 + 2, dy0 + 2, dx1 - 2, dy0 + 26)
  fill(bw, L.soil.base)
  bw:each(function(x, y) if (x - dx0) % 8 == 0 then px(x, y, L.soil.shade) end end)
  hline(dx0 + 2, dx1 - 2, 170, L.timber.base) hline(dx0 + 2, dx1 - 2, 171, L.timber.deep)
  for x = dx0 + 6, dx1 - 6, 10 do px(x, 169, L.timber.hi) end
  basket(334, 185, 6, 10, OSIER, { handle = true })
  basket(351, 188, 6, 13, BUFF, { lid = true })
  vline(362, 166, 169, L.timber.edge) local ln = rect(360, 170, 364, 174) rimOf(ln, IR) fill(ln, G.base) px(361, 171, G.hi) px(363, 173, G.shade)
  basket(374, 181, 8, 5, BUFF, { handle = true })
  eelTrap(386, 406, 179, 4, OSIER)
  basket(412, 186, 4, 9, OSIER)
  for _, x in ipairs({ 334, 351, 374, 396, 412 }) do px(x, 172, L.timber.edge) end
  -- rod bundles leaning on the inside walls
  rodBundle(327, 207, 30, OSIER, 2) rodBundle(332, 207, 26, BUFF, 2)
  rodBundle(416, 207, 28, BUFF, 2)
  -- the weaver at a half-made basket on a low block, offcuts on the floor
  local blk = rect(362, 200, 382, 207) rimOf(blk, L.timber) part(blk, L.timber) hline(362, 382, 200, L.timber.hi)
  basket(372, 199, 10, 14, BUFF, { stakes = .5 })
  local _, wx, wy = F.gnome(398, 208, { hat = L.lav, coat = L.awnB, arm = "hold", flip = true, noShadow = true })
  line({ { wx, wy }, { 383, 193 } }):each(function(x, y) px(x, y, BUFF.hi) end)
  line({ { wx + 1, wy }, { 404, 204 }, { 412, 199 }, { 418, 196 } }):each(function(x, y) px(x, y, BUFF.base) end)
  for k = 0, 7 do local sx = 340 + k * 9 px(sx, 205, BUFF.hi) px(sx + 1, 204, OSIER.base) px(sx + 3, 206, BUFF.shade) end
  -- sign: a basket on a board above the doorway
  local sb = rect(354, 150, 388, 161) rimOf(sb, L.timber) part(sb, L.board)
  F.sprite({
    "....kkkkkk....",
    "...k......k...",
    "..k........k..",
    "bbbbbbbbbbbbbb",
    ".BbBbBbBbBbBb.",
    ".bBbBbBbBbBbB.",
    "..BbBbBbBbBb..",
  }, 364, 152, { k = OSIER.base, b = BUFF.base, B = OSIER.shade }, { rim = false })
  -- under the eaves: drying rush bunches
  for _, b in ipairs({ { 302, 157, 8, L.reed }, { 309, 157, 10, L.reedGreen }, { 432, 157, 9, L.reed }, { 439, 157, 8, L.reedGreen } }) do hangBunch(b[1], b[2], b[3], b[4]) end
  -- against the outside walls: reed bundle ends (left), finished baskets piled (right)
  for row = 0, 2 do for k = 0, 2 - row do bundleEnd(302 + k * 7 + row * 3, 204 - row * 6, 3) end end
  basket(430, 208, 6, 9, OSIER) basket(442, 208, 5, 8, BUFF) basket(436, 197, 5, 8, BUFF, { handle = true })
end
workshop()

---------------------------------------------------------------- foreground left: peat clamp, creel of turves, thatcher at the trestle
F.depth(3)
peatStack(16, 206, 6, 10, 6, true)
basket(88, 206, 6, 12, OSIER, { fill = function(xa, xb, y)
  for k = 0, 2 do turfFace(xa + 1 + k * 4, y - 3 - (k % 2), 4, 3) end
end })
local function trestle(x0, yb)
  local legs = line({ { x0, yb }, { x0 + 5, yb - 14 }, { x0 + 10, yb } }, 2):add(line({ { x0 + 50, yb }, { x0 + 55, yb - 14 }, { x0 + 60, yb } }, 2))
  local bar = rect(x0 + 2, yb - 16, x0 + 58, yb - 14)
  F.shadow(x0, x0 + 62, yb, 8, 3)
  rimOf(union(legs, bar), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true }) part(bar, L.timber, { nopop = true })
  bundleSide(x0 - 8, x0 + 70, yb - 23, 7)
  -- trimmed straws fallen below
  for k = 0, 14 do
    local sx, sy = x0 + 4 + floor(hash(k, 1, 25) * 56), yb - 4 + floor(hash(k, 2, 25) * 8)
    line({ { sx, sy }, { sx + 3, sy - 1 } }):each(function(x, y) px(x, y, k % 2 == 0 and L.reed.hi or L.reed.base) end)
  end
end
trestle(28, 248)
local _, tx1, ty1 = F.gnome(110, 258, { hat = L.leaf, coat = L.accent, arm = "up", flip = true })
-- the leggett: a grooved board dressing the butts, handle to the thatcher's hand
local lface = rect(98, 216, 101, 233)
local lhan = line({ { 101, 228 }, { tx1, ty1 } }, 2)
rimOf(union(lface, lhan), L.timber)
part(lface, L.board, { nopop = true }) for y = 217, 232, 2 do px(98, y, L.board.deep) px(99, y, L.board.shade) end vline(101, 216, 233, L.board.shade)
part(lhan, L.timber, { nopop = true, noshade = true })

---------------------------------------------------------------- foreground: spar block, stacked baskets, soaking pool, log basket
-- spar-making block with a billhook, a bundle of split hazel spars twisted into pins
local blkM = c:rrect(176, 248, 198, 262, 3)
rimOf(blkM, L.willowBark) part(blkM, L.willowBark, { nopop = true })
blkM:each(function(x, y) if y > 251 and hash(x // 2, y // 3, 27) < .3 then px(x, y, L.willowBark.deep) elseif x < 179 then px(x, y, L.willowBark.hi) end end)
local top = c:ellipse(187, 249, 10, 3) fill(top, L.board.base) c:edgeIn(top, L.board.shade) px(184, 248, L.board.hi) px(185, 248, L.board.hi)
c:ellipse(187, 249, 5, 1):edge():each(function(x, y) px(x, y, L.board.shade) end)
local hook = line({ { 182, 248 }, { 188, 238 } }, 2) rimOf(hook, L.timber) fill(hook, L.board.base)
fill(poly{ { 186, 237 }, { 194, 234 }, { 196, 238 }, { 193, 241 }, { 194, 238 }, { 189, 240 } }, IR.base) px(194, 234, IR.hi) px(195, 235, IR.hi)
for k = 0, 5 do
  local sx, sy = 156 + k * 3, 258 + (k % 2)
  line({ { sx, sy }, { sx + 4, sy - 12 } }):each(function(x, y) px(x, y, L.board.hi) end)
  line({ { sx + 1, sy }, { sx + 5, sy - 12 } }):each(function(x, y) px(x, y, L.board.shade) end)
end
hline(155, 175, 252, L.timber.deep) hline(156, 174, 251, L.timber.base)
-- the carrier: a gnome with three baskets stacked on his head
local _, chx, chy = F.gnome(276, 216, { hat = L.produce, coat = L.wall2, arm = "up" })
basket(277, 193, 8, 8, BUFF)
basket(277, 183, 7, 8, OSIER)
basket(277, 173, 6, 7, BUFF, { handle = true })
line({ { chx, chy }, { 285, 190 } }):each(function(x, y) px(x, y, L.wall2.base) end)
-- finished baskets stacked beside the road
basket(304, 240, 7, 10, BUFF) basket(320, 240, 7, 10, OSIER) basket(312, 228, 6, 9, BUFF, { handle = true })
eelTrap(318, 344, 233, 5, BUFF)
-- red tool chest with shears and a bodkin
local tb = rect(286, 250, 306, 260) rimOf(tb, L.timber) part(tb, L.awnA) hline(286, 306, 253, L.awnA.deep)
fill(rect(294, 245, 298, 246), IR.base) vline(294, 246, 249, IR.base) vline(298, 246, 249, IR.base)
line({ { 288, 249 }, { 300, 247 } }):each(function(x, y) px(x, y, IR.hi) end) px(301, 247, L.timber.base) px(302, 248, L.timber.base)
-- the soaking pool with coiled withies and a moorhen
local spool = poly{ { 330, 248 }, { 356, 242 }, { 374, 246 }, { 377, 258 }, { 366, 266 }, { 338, 266 }, { 328, 258 } }
rimOf(spool, L.peat)
local sb2 = spool:grow(2):cut(spool)
sb2:each(function(x, y) if x < 379 then local v = hash(x, y, 53) px(x, y, v < .4 and L.peat.base or (v < .65 and L.peat.hi or L.sedgeGround.base)) end end)
F.water(spool, L.water)
coil(343, 259, 8, 4, OSIER) coil(357, 255, 7, 4, BUFF)
for x = 334, 350 do if hash(x, 4, 54) < .5 then px(x, 259, L.water.hi) end end
F.sprite({
  "..kk......",
  ".kkkk.....",
  "Rkekk.....",
  "OKKKKKKw..",
  ".KKKKKKKww",
  "..KKKKKKK.",
}, 362, 247, { k = L.timber.edge, e = L.marigold.hi, R = L.apple.base, O = L.marigold.base, K = TAR.deep, w = L.awnB.base })
hline(361, 372, 253, L.water.hi)
F.lily(372, 262, false) F.lily(334, 252, true, "yellow")
F.reeds(322, 330, 262, 14, 86, { cattails = 1, green = true })
-- a big log basket half woven, a coil of rods waiting beside it
basket(442, 228, 13, 18, OSIER, { stakes = .55 })
coil(418, 227, 8, 4, BUFF)
F.reeds(456, 470, 226, 18, 87, { cattails = 2, green = true })
-- sedge, marigolds, offcuts in the yard
for _, f in ipairs({ { 214, 216 }, { 300, 214 }, { 90, 214 }, { 16, 222 }, { 352, 218 }, { 456, 206 } }) do F.sedge(f[1], f[2], 6) px(f[1] - 1, f[2] - 5, L.marigold.base) px(f[1] + 2, f[2] - 4, L.marigold.hi) end
for i = 0, 18 do
  local x, y = floor(hash(i, 1, 26) * 470) + 4, 214 + floor(hash(i, 2, 26) * 50)
  if not F.roadM:has(x, y) and not (x >= 378 and y >= 228) then px(x, y, i % 2 == 0 and BUFF.hi or OSIER.base) px(x + 1, y, i % 2 == 0 and BUFF.shade or OSIER.shade) end
end
F.dragonfly(232, 204, L.accent) F.dragonfly(392, 222, L.apple, true)
F.frog(372, 241, false)
F.depth(0)
F.birds({ { 330, 34, 2 }, { 344, 40, 1 }, { 180, 44, 2 }, { 168, 50, 1 }, { 400, 30, 2 }, { 408, 34, 2 }, { 416, 38, 2 } })
F.finish()
