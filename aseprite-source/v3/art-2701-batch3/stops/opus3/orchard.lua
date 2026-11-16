-- orchard.lua : "Orchard" stop look, Maplewold (480x270 gate view). Opus second pass.
-- Read: rows of apple trees heavy with red fruit running to the horizon on both sides, a great old apple tree
-- with a rope swing where the road ends, a screw cider press with a tub of apples, a picker on a ladder, crates,
-- baskets, cider barrels, a red barn and windfalls in the grass. Quirk: a hedgehog with an apple stuck on its spines.
-- opus3 richness pass: four tree kinds in the rows (round apple, tall pear, wide old spreader, staked young tree)
-- with red, gold and green fruit and three leaf ramps; mown stripes and tree shadows between the rows; depth planes;
-- 28 px gnomes (picker, crate packer, press turner, a little one on the swing); a pig at the windfalls; a big hedgehog.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/opus3/"
local F = dofile(DIR .. "_frame.lua").build{ name = "orchard", out = DIR, farTrees = { 24, 52, 100, 380, 410, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local AP, LF, IR = L.apple, L.leaf, L.iron
local LF2 = F.rp("#e0dc78 #b8b84e #8c9440 #5e6c36 #384428") -- yellowing leaf

-- fruit trees in four kinds so the rows never repeat one shape:
--   kind 1 round apple (three clumps), 2 tall pear (narrow, gold-green fruit), 3 wide old spreader (low heavy limbs),
--   4 young staked tree (thin, a few fruit, tree guard). Leaf ramp and fruit colour vary too.
local LF3 = F.rp("#ffd070 #e8a040 #c07432 #8a4e2a #5a3020") -- turning orange
local PEAR = F.rp("#f0f09a #c8d060 #98a44a #6a7438 #404a26")
local GOLD = F.rp("#fff0a0 #f5c840 #d0902a #8f5a20 #5e3a18")
local function fruitDot(ax, ay, s, fr)
  if s > 1.1 then fill(rect(ax, ay, ax + 1, ay + 1), fr.base) px(ax, ay, fr.hi) px(ax + 1, ay + 1, fr.shade)
  else px(ax, ay, fr.base) if s > .7 then px(ax + 1, ay, fr.shade) end end
end
local function appleTree(x, yb, s, seed, kind)
  kind = kind or (seed % 4) + 1
  local lr = ({ LF, LF2, LF3 })[(seed // 4) % 3 + 1]
  local fr = ({ AP, GOLD, AP, PEAR })[kind]
  if kind == 2 then lr = LF fr = PEAR end
  local lean = (hash(seed, 1, 9) - .5) * 4 * s
  local w2 = math.max(1, floor(2 * s))
  if kind == 1 then
    local tr = poly{ { x - 3 * s, yb }, { x - 2 * s + lean, yb - 12 * s }, { x + 2 * s + lean, yb - 12 * s }, { x + 3 * s, yb } }
    local brs = line({ { x + lean, yb - 10 * s }, { x - 8 * s, yb - 18 * s } }, w2):add(line({ { x + lean, yb - 10 * s }, { x + 8 * s, yb - 19 * s } }, w2))
    F.shadowM(c:ellipse(x + 4 * s, yb, 13 * s, 2 * s))
    rimOf(union(tr, brs), L.timber) part(tr, L.timber, { nopop = true }) part(brs, L.timber, { nopop = true, noshade = true })
    F.crown(x - 6 * s, yb - 22 * s, 9 * s, 7 * s, lr, seed) F.crown(x + 6 * s, yb - 23 * s, 9 * s, 7 * s, lr, seed + 1) F.crown(x + lean, yb - 29 * s, 10 * s, 7 * s, lr, seed + 2)
    for i = 1, floor(9 * s * s) + 3 do local a, rr = hash(i, seed, 1) * 2 * pi, hash(i, seed, 2) fruitDot(floor(x + cos(a) * rr * 13 * s), floor(yb - 25 * s + sin(a) * rr * 9 * s), s, fr) end
  elseif kind == 2 then
    local tr = poly{ { x - 2 * s, yb }, { x - 1 * s, yb - 14 * s }, { x + 1 * s, yb - 14 * s }, { x + 2 * s, yb } }
    F.shadowM(c:ellipse(x + 3 * s, yb, 8 * s, 2 * s))
    rimOf(tr, L.timber) part(tr, L.timber, { nopop = true })
    F.crown(x + lean * .5, yb - 24 * s, 7 * s, 9 * s, lr, seed) F.crown(x + lean, yb - 36 * s, 5 * s, 7 * s, lr, seed + 1)
    for i = 1, floor(7 * s * s) + 2 do local ax, ay = floor(x + (hash(i, seed, 1) - .5) * 12 * s), floor(yb - 18 * s - hash(i, seed, 2) * 20 * s)
      fruitDot(ax, ay, s, fr) if s > .9 then px(ax, ay - 1, fr.shade) end end
  elseif kind == 3 then
    local tr = poly{ { x - 4 * s, yb }, { x - 3 * s, yb - 8 * s }, { x + 3 * s, yb - 8 * s }, { x + 4 * s, yb } }
    local brs = line({ { x, yb - 7 * s }, { x - 13 * s, yb - 13 * s } }, w2 + 1):add(line({ { x, yb - 7 * s }, { x + 13 * s, yb - 12 * s } }, w2 + 1))
    F.shadowM(c:ellipse(x + 4 * s, yb, 17 * s, 2 * s))
    rimOf(union(tr, brs), L.timber) part(tr, L.timber, { nopop = true }) part(brs, L.timber, { nopop = true, noshade = true })
    F.crown(x - 11 * s, yb - 18 * s, 9 * s, 7 * s, lr, seed) F.crown(x + 11 * s, yb - 18 * s, 9 * s, 7 * s, lr, seed + 1) F.crown(x, yb - 24 * s, 12 * s, 9 * s, lr, seed + 2)
    for i = 1, floor(10 * s * s) + 3 do local a, rr = hash(i, seed, 1) * 2 * pi, hash(i, seed, 2) fruitDot(floor(x + cos(a) * rr * 19 * s), floor(yb - 20 * s + sin(a) * rr * 7 * s), s, fr) end
  else
    local tr = rect(floor(x), floor(yb - 14 * s), floor(x + math.max(1, s)), yb)
    local stake = rect(floor(x + 3 * s), floor(yb - 12 * s), floor(x + 3 * s), yb)
    local guard = rect(floor(x - 2 * s), floor(yb - 5 * s), floor(x + 2 * s + 1), yb)
    F.shadowM(c:ellipse(x + 3 * s, yb, 7 * s, 1 + s))
    rimOf(union(tr, stake), L.timber) part(tr, L.timber, { nopop = true, noshade = true }) part(stake, L.board, { nopop = true, noshade = true })
    F.crown(x, yb - 18 * s, 6 * s, 6 * s, lr, seed)
    if s > .7 then rimOf(guard, L.board) fill(guard, L.awnB.shade) guard:each(function(xx, yy) if (xx + yy) % 2 == 0 then px(xx, yy, L.awnB.deep) end end) end
    for i = 1, 3 do fruitDot(floor(x + (hash(i, seed, 1) - .5) * 8 * s), floor(yb - 18 * s + (hash(i, seed, 2) - .5) * 6 * s), s, fr) end
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
-- mown stripes between the tree rows and a darker grass band under each row
for y = 116, 229 do
  local d = y - 108
  local band = floor(60 / d * 6)
  if band % 2 == 0 then
    for x = 18, 461 do if not F.roadM:has(x, y) and hash(x // 3, y, 91) < .7 then px(x, y, F.mix(L.ground.base, L.ground.hi, .5)) end end
  end
end
for _, r in ipairs(rows) do
  local y = floor(r[2])
  for x = 18, 461 do if not F.roadM:has(x, y + 1) and hash(x, y, 92) < .5 then px(x, y + 1, L.ground.shade) px(x, y + 2, F.mix(L.ground.shade, L.ground.base, .5)) end end
end
F.depth(2)
-- great old tree at the road's end (drawn first: it is farthest)
local function oldTree()
  local tr = poly{ { 228, 126 }, { 234, 96 }, { 230, 84 }, { 250, 84 }, { 246, 96 }, { 252, 126 } }
  local brs = line({ { 236, 90 }, { 212, 70 } }, 3):add(line({ { 246, 88 }, { 270, 68 } }, 3))
  F.shadow(228, 256, 127, 10, 3)
  rimOf(union(tr, brs), L.timber) part(tr, L.timber) part(brs, L.timber, { nopop = true })
  tr:each(function(x, y) if (x * 2 + y) % 9 == 0 then px(x, y, L.timber.deep) end end)
  F.crown(210, 62, 24, 16, LF, 51) F.crown(270, 60, 24, 16, LF2, 52) F.crown(240, 48, 30, 18, LF, 53) F.crown(240, 72, 20, 10, LF2, 54)
  for i = 1, 40 do
    local ax, ay = 190 + floor(hash(i, 3, 1) * 100), 36 + floor(hash(i, 4, 1) * 44)
    if (ax - 240) ^ 2 / 2400 + (ay - 58) ^ 2 / 500 < 1 then fill(rect(ax, ay, ax + 1, ay + 1), AP.base) px(ax, ay, AP.hi) end
  end
  -- rope swing
  vline(216, 72, 112, L.board.deep) vline(228, 74, 112, L.board.deep)
  local seat = rect(214, 112, 230, 114) rimOf(seat, L.timber) part(seat, L.board, { nopop = true })
  F.gnome(222, 112, { small = true, hat = L.awnA, coat = L.roof, noShadow = true }) -- a little one swinging
end
oldTree()
table.sort(rows, function(a, b) return a[2] < b[2] end)
for i, r in ipairs(rows) do
  F.depth(r[2] < 140 and 1 or (r[2] < 170 and 2 or 3))
  if r[1] > 0 and r[1] < 480 and not (r[1] > 370 and r[2] > 175) then appleTree(floor(r[1]), r[2], r[3], i * 7 + 1, (i * 3 + floor(r[1]) // 50) % 4 + 1) end
end
F.depth(1)

---------------------------------------------------------------- back-right barn (between rows)
local function barn()
  local top = F.building{ x0 = 404, x1 = 462, yb = 140, wh = 30, rh = 22, wall = L.roof2, roof = L.board, shingle = true, noFrame = true, noAttic = true }
  local dm = rect(420, 118, 444, 139) fill(dm, L.awnB.base) c:edgeIn(dm, L.awnB.deep)
  fill(line({ { 421, 119 }, { 443, 138 } }), L.awnB.deep) fill(line({ { 443, 119 }, { 421, 138 } }), L.awnB.deep)
  local hay = rect(428, 104, 436, 110) fill(hay, L.soil.deep) fill(rect(428, 108, 436, 110), L.roof.base)
end
barn()

---------------------------------------------------------------- left hero: cider press
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
  F.shadow(x0, x0 + 56, yb, 12, 4)
  rimOf(union(posts, beam, screw, bar, plate, tub, base, spout), L.timber)
  part(posts, L.timber) part(beam, L.timber) hline(x0 - 4, x0 + 54, yb - 56, L.timber.hi)
  part(screw, IR, { nopop = true }) for y = yb - 49, yb - 29, 2 do hline(x0 + 23, x0 + 27, y, IR.deep) px(x0 + 23, y + 1, IR.hi) end
  part(bar, L.board, { nopop = true }) part(plate, L.board)
  part(tub, L.board) for x = x0 + 10, x0 + 40, 6 do vline(x, yb - 23, yb - 7, L.board.deep) end
  hline(x0 + 7, x0 + 43, yb - 20, IR.shade) hline(x0 + 8, x0 + 42, yb - 10, IR.shade)
  part(base, L.timber, { nopop = true })
  part(spout, L.timber, { nopop = true })
  -- juice pouring into a bucket
  vline(x0 + 60, yb - 7, yb + 4, L.roof.base) vline(x0 + 61, yb - 7, yb + 4, L.roof.hi)
  local bk = poly{ { x0 + 54, yb + 4 }, { x0 + 68, yb + 4 }, { x0 + 66, yb + 14 }, { x0 + 56, yb + 14 } }
  rimOf(bk, L.timber) part(bk, L.board) hline(x0 + 55, x0 + 67, yb + 5, L.roof.base) hline(x0 + 55, x0 + 67, yb + 7, IR.shade)
end
press(92, 206)
-- a gnome turning the press bar
local _, tx, ty = F.gnome(80, 210, { hat = L.lav, coat = L.board, arm = "up" })
fill(line({ { tx, ty }, { 98, 166 } }), L.board.base)
-- heaps of apples beside the press
local function heap(x0, x1, yb)
  local m = poly{ { x0, yb }, { x0 + 4, yb - 7 }, { (x0 + x1) // 2, yb - 11 }, { x1 - 4, yb - 7 }, { x1, yb } }
  rimOf(m, AP) fill(m, AP.base)
  m:each(function(x, y) local k = (x + (y % 2) * 2) % 4 if k == 0 then px(x, y, AP.hi) elseif k == 3 then px(x, y, AP.shade) end end)
  for x = x0 + 4, x1 - 4, 7 do px(x, yb - 8 + (x % 3), LF.base) end
end
heap(30, 84, 214)
F.crate(24, 232, 22, 12, AP) F.crate(50, 234, 22, 12, LF2) F.crate(36, 220, 22, 10, AP)
-- cider barrels and jugs on a plank table
local tbl = rect(118, 226, 182, 229):add(rect(121, 230, 123, 242)):add(rect(177, 230, 179, 242))
F.shadow(120, 182, 242, 8, 3)
rimOf(tbl, L.timber) part(tbl, L.board, { nopop = true })
for k = 0, 3 do
  local x = 126 + k * 14
  local jug = c:rrect(x - 4, 214, x + 4, 225, 3):add(rect(x - 2, 210, x + 2, 214))
  rimOf(jug, L.timber) part(jug, (k % 2 == 0) and L.roof or L.awnB)
  fill(rect(x + 4, 216, x + 6, 221), L.timber.edge) fill(rect(x + 4, 217, x + 5, 220), (k % 2 == 0) and L.roof.shade or L.awnB.shade)
  fill(rect(x - 2, 209, x + 2, 210), L.timber.base)
end
F.barrel(196, 250, L.timber, 14) F.barrel(186, 262, L.board, 12)

---------------------------------------------------------------- right hero: picker on a ladder at a big front tree, crates
appleTree(408, 226, 2.3, 77, 1)
local lad = line({ { 352, 236 }, { 370, 168 } }, 2):add(line({ { 364, 238 }, { 382, 170 } }, 2))
for k = 0, 8 do local t = k / 8 lad:add(line({ { 352 + 18 * t, 236 - 68 * t }, { 364 + 18 * t, 238 - 68 * t } })) end
rimOf(lad, L.timber) part(lad, L.board, { nopop = true, noshade = true })
local _, phx, phy = F.gnome(375, 190, { hat = L.awnA, coat = L.wall2, arm = "up", noShadow = true })
fill(rect(phx, phy - 2, phx + 1, phy - 1), AP.base) px(phx, phy - 2, AP.hi) -- an apple just picked
local bas = poly{ { 368, 186 }, { 380, 186 }, { 378, 194 }, { 370, 194 } } rimOf(bas, L.board) part(bas, L.roof)
bas:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.roof.shade) end end)
for k = 0, 4 do fill(rect(369 + k * 2, 184, 370 + k * 2, 185), AP.base) px(369 + k * 2, 184, AP.hi) end
-- crates by the road (right)
F.crate(290, 226, 22, 12, AP) F.crate(314, 228, 22, 12, AP) F.crate(300, 213, 22, 11, LF2)
local _, ghx, ghy = F.gnome(336, 256, { hat = L.leaf, coat = L.roof, arm = "out", flip = true })
fill(rect(ghx - 1, ghy - 1, ghx, ghy), AP.base) px(ghx - 1, ghy - 1, AP.hi)
-- wheelbarrow of apples
local wb = poly{ { 282, 246 }, { 312, 246 }, { 306, 256 }, { 288, 256 } }
local wbh = line({ { 282, 250 }, { 270, 256 } }, 2):add(rect(296, 256, 297, 262))
local wbw = c:ellipse(310, 260, 4, 4)
F.shadow(276, 314, 264, 6, 2)
rimOf(union(wb, wbh, wbw), L.timber) part(wbh, L.timber, { nopop = true, noshade = true }) part(wb, L.accent) part(wbw, L.timber, { nopop = true })
for x = 285, 309, 3 do fill(rect(x, 243, x + 1, 245), AP.base) px(x, 243, AP.hi) end

---------------------------------------------------------------- windfalls + quirk hedgehog
for i = 0, 34 do
  local x, y = 20 + floor(hash(i, 5, 7) * 440), 150 + floor(hash(i, 6, 7) * 110)
  if not F.roadM:has(x, y) and not (x > 378 and y > 228) then px(x, y, AP.base) px(x + 1, y, AP.shade) px(x, y - 1, AP.hi) end
end
-- quirk: a hedgehog trundling off with an apple (and a leaf) stuck on its spines
F.shadowM(c:ellipse(222, 263, 13, 1))
F.sprite({
  "......llaaa...........",
  ".....lLaAAaa..........",
  "......aAaaaaa.........",
  "...sssaaaaaaasss......",
  "..sSsSaaaaaSsSsss.....",
  ".sSsSssaaasSsSsSss....",
  "sSsSsSsSsSsSsSsSsfff..",
  "sssSsSsSsSsSsSssffeff.",
  "ssssssssssssssssfffffn",
  ".sssssssssssssssfffff.",
  "...ff.......ff..ff....",
}, 206, 252, { l = L.leaf.base, L = L.leaf.hi, a = AP.base, A = AP.hi, s = L.soil.shade, S = L.soil.hi, f = L.board.hi, e = L.timber.edge, n = L.timber.edge })
-- a pig snuffling the windfalls under the far-left trees
F.sprite({
  "..pp..........",
  ".pPPpppppppp..",
  "pPPPPPPPPPPPp.",
  "nPePPPPPPPPPPq",
  "nnPPPPPPPPPPp.",
  ".pPPPPPPPPPp..",
  "..pp..pp.pp...",
}, 38, 160, { p = L.petal and L.petal.shade or "#c94f84", P = "#f5a0b0", e = L.timber.edge, n = "#e07890", q = "#c94f84" })
for _, a in ipairs({ { 30, 165 }, { 34, 167 }, { 56, 166 } }) do px(a[1], a[2], AP.base) px(a[1] + 1, a[2], AP.shade) px(a[1], a[2] - 1, AP.hi) end
-- a blackbird pecking a windfall by the road
F.sprite({ ".kk...", "kkkkk.", "kkkkky", ".k.k.." }, 182, 192, { k = "#4a3a4a", y = L.roof.base })
px(180, 195, AP.base) px(179, 195, AP.shade)
F.depth(0)
F.birds({ { 330, 40, 2 }, { 120, 48, 2 }, { 132, 42, 1 } })
F.finish()
