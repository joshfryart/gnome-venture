-- orchard.lua : "Orchard" stop look, Maplewold (480x270 gate view). Opus second pass.
-- Read: rows of apple trees heavy with red fruit running to the horizon on both sides, a great old apple tree
-- with a rope swing where the road ends, a screw cider press with a tub of apples, a picker on a ladder, crates,
-- baskets, cider barrels, a red barn and windfalls in the grass. Quirk: a hedgehog with an apple stuck on its spines.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/opus2/"
local F = dofile(DIR .. "_frame.lua").build{ name = "orchard", out = DIR, farTrees = { 24, 52, 100, 380, 410, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local AP, LF, IR = L.apple, L.leaf, L.iron
local LF2 = F.rp("#e0dc78 #b8b84e #8c9440 #5e6c36 #384428") -- yellowing leaf

-- an apple tree: short trunk, wide rounded crown, apples
local function appleTree(x, yb, s, seed)
  local tr = poly{ { x - 3 * s, yb }, { x - 2 * s, yb - 12 * s }, { x + 2 * s, yb - 12 * s }, { x + 3 * s, yb } }
  local brs = line({ { x, yb - 10 * s }, { x - 8 * s, yb - 18 * s } }, math.max(1, floor(2 * s))):add(line({ { x, yb - 10 * s }, { x + 8 * s, yb - 19 * s } }, math.max(1, floor(2 * s))))
  F.shadowM(c:ellipse(x + 4 * s, yb, 13 * s, 2 * s))
  rimOf(union(tr, brs), L.timber) part(tr, L.timber, { nopop = true }) part(brs, L.timber, { nopop = true, noshade = true })
  local r = (seed % 3 == 0) and LF2 or LF
  local m = F.crown(x - 6 * s, yb - 22 * s, 9 * s, 7 * s, r, seed)
  F.crown(x + 6 * s, yb - 23 * s, 9 * s, 7 * s, r, seed + 1)
  F.crown(x, yb - 29 * s, 10 * s, 7 * s, r, seed + 2)
  -- apples
  local n = floor(9 * s * s) + 3
  for i = 1, n do
    local a, rr = hash(i, seed, 1) * 2 * pi, hash(i, seed, 2)
    local ax, ay = floor(x + cos(a) * rr * 13 * s), floor(yb - 25 * s + sin(a) * rr * 9 * s)
    if s > 1.1 then fill(rect(ax, ay, ax + 1, ay + 1), AP.base) px(ax, ay, AP.hi) px(ax + 1, ay + 1, AP.shade)
    else px(ax, ay, AP.base) if s > .7 then px(ax + 1, ay, AP.shade) end end
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
end
oldTree()
table.sort(rows, function(a, b) return a[2] < b[2] end)
for i, r in ipairs(rows) do
  if r[1] > 0 and r[1] < 480 and not (r[1] > 370 and r[2] > 175) then appleTree(floor(r[1]), r[2], r[3], i * 3) end
end

---------------------------------------------------------------- back-right barn (between rows)
local function barn()
  local top = F.building{ x0 = 404, x1 = 462, yb = 140, wh = 30, rh = 22, wall = L.roof2, roof = L.board, shingle = true, noFrame = true, noAttic = true }
  local dm = rect(420, 118, 444, 139) fill(dm, L.awnB.base) c:edgeIn(dm, L.awnB.deep)
  fill(line({ { 421, 119 }, { 443, 138 } }), L.awnB.deep) fill(line({ { 443, 119 }, { 421, 138 } }), L.awnB.deep)
  local hay = rect(428, 104, 436, 110) fill(hay, L.soil.deep) fill(rect(428, 108, 436, 110), L.roof.base)
end
barn()

---------------------------------------------------------------- left hero: cider press
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
appleTree(408, 226, 2.3, 77)
local lad = line({ { 352, 236 }, { 370, 168 } }, 2):add(line({ { 364, 238 }, { 382, 170 } }, 2))
for k = 0, 8 do local t = k / 8 lad:add(line({ { 352 + 18 * t, 236 - 68 * t }, { 364 + 18 * t, 238 - 68 * t } })) end
rimOf(lad, L.timber) part(lad, L.board, { nopop = true, noshade = true })
F.gnome(376, 186, { hat = L.awnA, coat = L.wall2, arm = "up", noShadow = true })
local bas = poly{ { 380, 188 }, { 392, 188 }, { 390, 196 }, { 382, 196 } } rimOf(bas, L.board) part(bas, L.roof)
fill(rect(382, 186, 383, 187), AP.base) fill(rect(386, 186, 387, 187), AP.base) vline(386, 182, 187, L.board.deep)
-- crates by the road (right)
F.crate(290, 226, 22, 12, AP) F.crate(314, 228, 22, 12, AP) F.crate(300, 213, 22, 11, LF2)
F.gnome(330, 252, { hat = L.leaf, coat = L.roof, arm = "out", flip = true })
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
local function hedgehog(x, yb)
  local body = c:ellipse(x, yb - 4, 8, 4):clip(rect(x - 9, yb - 9, x + 9, yb))
  local snout = poly{ { x + 6, yb - 4 }, { x + 12, yb - 2 }, { x + 6, yb } }
  rimOf(union(body, snout), L.timber)
  part(body, L.soil)
  body:each(function(xx, y) if (xx + y * 2) % 3 == 0 then px(xx, y, L.soil.deep) elseif (xx + y) % 5 == 0 then px(xx, y, L.soil.hi) end end)
  part(snout, L.board, { nopop = true }) px(x + 12, yb - 2, L.timber.edge) px(x + 8, yb - 3, L.timber.edge)
  local ap = c:ellipse(x - 1, yb - 10, 3, 3) rimOf(ap, AP) part(ap, AP) vline(x - 1, yb - 15, yb - 13, L.timber.base) px(x, yb - 14, LF.base)
end
hedgehog(214, 262)
F.finish()
