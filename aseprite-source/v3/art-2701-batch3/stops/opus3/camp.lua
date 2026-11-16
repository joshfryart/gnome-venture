-- camp.lua : "Camp" stop look, Maplewold (480x270 gate view). Opus second pass.
-- Read: a big campfire in a stone ring with a pot on a tripod and log seats where gnomes warm up, a striped bell
-- tent glowing from inside, small ridge tents, a canvas-covered wagon, a washing line between trees, firewood
-- stacked between stakes, a camp kitchen table, bedrolls and packs. Quirk: a raccoon in a backpack with a sausage.
-- opus3 richness pass: a striped two-peak mess marquee replaces the weak far ridge tent as the road's-end landmark;
-- the back log seat is long and visible; depth planes; real smoke from the fire; four 28 px gnomes (toasting,
-- mug, lute player on the back seat, one pegging washing); a dog asleep by the fire, a rabbit
-- by the woodpile. The raccoon is now big: bandit mask, ringed tail over the pack's rim, sausage in its paws.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/opus3/"
local F = dofile(DIR .. "_frame.lua").build{ name = "camp", out = DIR, farTrees = { 24, 52, 160, 196, 290, 318, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local G, IR = L.glow, L.iron

-- trodden earth clearing around the fire (left of the road)
local clear = c:ellipse(150, 214, 92, 30)
clear:each(function(x, y) if not F.roadM:has(x, y) and x < F.xl(y) - 1 then
  local v = hash(x, y, 3)
  if v < .05 then px(x, y, L.soil.hi) elseif v > .93 then px(x, y, L.ground.deep) elseif v > .55 then px(x, y, L.ground.shade) end
end end)

---------------------------------------------------------------- small ridge tents (back)
local function ridgeTent(x, yb, w, h, r, flap)
  local front = poly{ { x - w, yb }, { x, yb - h }, { x + w, yb } }
  local side = poly{ { x, yb - h }, { x + w + 18, yb - h + 4 }, { x + w + 22, yb - 2 }, { x + w, yb } }
  local door = poly{ { x - w // 3, yb }, { x, yb - h * 2 // 3 }, { x + w // 3, yb } }
  F.shadow(x - w, x + w + 22, yb, 10, 3)
  rimOf(union(front, side), r)
  part(side, r, { noshade = true }) side:each(function(xx, y) if (xx - x) % 6 == 0 then px(xx, y, r.shade) end end)
  part(front, r, { sep = true })
  fill(door, r.deep) fill(poly{ { x - 1, yb }, { x, yb - h * 2 // 3 }, { x + w // 3, yb } }, L.soil.deep)
  if flap then fill(poly{ { x, yb - h * 2 // 3 }, { x - w // 3 - 4, yb - 2 }, { x - w // 3, yb } }, r.hi) end
  vline(x, yb - h - 4, yb - h, L.timber.base)
  line({ { x - w - 4, yb + 1 }, { x - w + 2, yb - 4 } }):each(function(xx, y) px(xx, y, L.board.shade) end)
  line({ { x + w + 26, yb + 1 }, { x + w + 18, yb - 6 } }):each(function(xx, y) px(xx, y, L.board.shade) end)
end
F.depth(2)
-- the road's end: a striped two-peak mess marquee with pennants
do
  local cx, yb = 240, 128
  local wall = rect(cx - 34, yb - 16, cx + 34, yb)
  local roofm = poly{ { cx - 42, yb - 15 }, { cx - 16, yb - 44 }, { cx, yb - 32 }, { cx + 16, yb - 44 }, { cx + 42, yb - 15 } }
  local poles = rect(cx - 17, yb - 54, cx - 16, yb - 44):add(rect(cx + 16, yb - 54, cx + 17, yb - 44))
  F.shadow(cx - 34, cx + 34, yb, 10, 3)
  rimOf(union(wall, roofm, poles), L.awnB)
  roofm:each(function(x, y)
    local pk = x < cx and cx - 16 or cx + 16
    local u = (x - pk) / (y - (yb - 46))
    local k = floor(u * 5 + 20)
    local h = (k % 2 == 0) and L.awnA.base or L.awnB.hi
    if (u * 5 + 20) % 1 < .14 then h = (k % 2 == 0) and L.awnA.shade or L.awnB.shade end
    if x > pk + 6 and (x - pk) / 26 + (y - (yb - 44)) / 30 > .9 then h = (k % 2 == 0) and L.awnA.shade or L.awnB.base end
    px(x, y, h)
  end)
  wall:each(function(x, y) local k = ((x - cx + 40) // 6) % 2 px(x, y, k == 0 and L.awnB.base or L.awnA.hi) if x > cx + 22 then px(x, y, k == 0 and L.awnB.shade or L.awnA.base) end end)
  for x = cx - 40, cx + 38, 6 do fill(poly{ { x, yb - 15 }, { x + 6, yb - 15 }, { x + 3, yb - 11 } }, L.accent.base) px(x + 3, yb - 12, L.accent.shade) end
  hline(cx - 42, cx + 42, yb - 15, L.accent.deep)
  local door = poly{ { cx - 8, yb }, { cx - 5, yb - 12 }, { cx + 5, yb - 12 }, { cx + 8, yb } }
  fill(door, G.shade) fill(rect(cx - 3, yb - 9, cx + 3, yb), G.base) px(cx - 2, yb - 8, G.hi)
  part(poles, L.timber, { nopop = true, noshade = true })
  for _, p in ipairs({ { cx - 16, L.accent }, { cx + 17, L.produce } }) do fill(poly{ { p[1] + 1, yb - 54 }, { p[1] + 10, yb - 52 }, { p[1] + 1, yb - 49 } }, p[2].base) px(p[1] + 2, yb - 53, p[2].hi) end
  for _, g in ipairs({ { cx - 42, cx - 50 }, { cx + 42, cx + 50 } }) do line({ { g[1], yb - 15 }, { g[2], yb + 1 } }):each(function(x, y) px(x, y, L.board.deep) end) end
  F.smoke(cx + 26, yb - 34, 5, .6, 2) -- stove pipe smoke
  fill(rect(cx + 25, yb - 34, cx + 27, yb - 28), L.iron.base)
end
F.depth(1)
ridgeTent(36, 146, 14, 18, L.roof2, true)

---------------------------------------------------------------- washing line between two trees (back-left)
F.tree(84, 138, 44, 4)
F.tree(186, 136, 40, 7)
F.depth(2)
local function sagY(x) local t = (x - 88) / (182 - 88) return floor(108 + 8 * sin(t * pi)) end
for x = 88, 182 do px(x, sagY(x), L.awnB.deep) end
for i, it in ipairs({ { 98, L.awnA, "sock" }, { 112, L.accent, "shirt" }, { 132, L.roof, "sock" }, { 146, L.awnB, "shirt" }, { 166, L.lav, "sock" } }) do
  local x = it[1] local y = sagY(x) + 1 local r = it[2]
  local m
  if it[3] == "sock" then m = rect(x, y, x + 3, y + 8):add(rect(x, y + 6, x + 6, y + 9))
  else m = rect(x - 2, y, x + 10, y + 3):add(rect(x + 1, y, x + 7, y + 13)) end
  rimOf(m, r) part(m, r, { nopop = true })
  hline(x, x + 3, y, r.hi) px(x + 1, y - 1, L.timber.base)
end

---------------------------------------------------------------- right: striped bell tent glowing inside
F.depth(3)
local function bellTent(cx, yb)
  local wall = rect(cx - 46, yb - 26, cx + 46, yb)
  local cone = poly{ { cx - 52, yb - 24 }, { cx - 30, yb - 46 }, { cx, yb - 62 }, { cx + 30, yb - 46 }, { cx + 52, yb - 24 } }
  local pole = rect(cx - 1, yb - 74, cx, yb - 62)
  F.shadow(cx - 44, cx + 46, yb, 16, 5)
  rimOf(union(wall, cone, pole), L.awnB)
  -- stripes follow the cone
  cone:each(function(x, y)
    local u = (x - cx) / (yb + 4 - y)
    local k = floor(u * 9 + 20) % 2
    local edge = (u * 9 + 20) % 1 < .12
    px(x, y, edge and L.awnB.deep or (k == 0 and L.awnB.base or L.awnB.hi))
  end)
  wall:each(function(x, y)
    local k = floor((x - cx) / 10 + 20) % 2
    px(x, y, ((x - cx) % 10 == 0) and L.awnB.deep or (k == 0 and L.awnB.hi or L.awnB.base))
  end)
  wall:each(function(x, y) if x > cx + 30 and (x - cx) % 10 ~= 0 then px(x, y, L.awnB.shade) end end)
  cone:each(function(x, y) if x > cx + 20 and (x - cx) / 52 + (y - (yb - 62)) / 40 > 1.1 then px(x, y, L.awnB.shade) end end)
  for x = cx - 46, cx + 46, 7 do px(x, yb - 2, L.awnA.base) end
  hline(cx - 52, cx + 52, yb - 24, L.accent.deep) hline(cx - 51, cx + 51, yb - 23, L.accent.shade)
  -- scalloped valance
  for x = cx - 50, cx + 48, 6 do fill(poly{ { x, yb - 22 }, { x + 6, yb - 22 }, { x + 3, yb - 18 } }, L.accent.base) px(x + 3, yb - 19, L.accent.shade) end
  part(pole, L.timber, { nopop = true, noshade = true })
  local fl = poly{ { cx + 1, yb - 74 }, { cx + 12, yb - 71 }, { cx + 1, yb - 68 } } fill(fl, L.awnA.base) px(cx + 2, yb - 73, L.awnA.hi)
  -- open door with warm light and a hanging lantern
  local door = poly{ { cx - 12, yb }, { cx - 6, yb - 30 }, { cx + 6, yb - 30 }, { cx + 12, yb } }
  fill(door, G.shade) fill(poly{ { cx - 8, yb }, { cx - 4, yb - 26 }, { cx + 4, yb - 26 }, { cx + 8, yb } }, G.base)
  fill(rect(cx - 2, yb - 22, cx + 2, yb - 16), G.hi) vline(cx, yb - 26, yb - 23, L.timber.edge)
  fill(rect(cx - 6, yb - 6, cx + 6, yb - 1), L.awnA.shade) hline(cx - 6, cx + 6, yb - 6, L.awnA.base) -- rug
  local flapL = poly{ { cx - 12, yb }, { cx - 6, yb - 30 }, { cx - 20, yb - 2 } } fill(flapL, L.awnB.shade) c:edgeIn(flapL, L.awnB.deep)
  local flapR = poly{ { cx + 12, yb }, { cx + 6, yb - 30 }, { cx + 20, yb - 2 } } fill(flapR, L.awnB.shade) c:edgeIn(flapR, L.awnB.deep)
  -- guy ropes and pegs
  for _, g in ipairs({ { cx - 52, yb - 24, cx - 66, yb + 2 }, { cx + 52, yb - 24, cx + 66, yb + 2 } }) do
    line({ { g[1], g[2] }, { g[3], g[4] } }):each(function(x, y) px(x, y, L.board.deep) end) fill(rect(g[3] - 1, g[4] - 2, g[3], g[4] + 1), L.timber.base)
  end
end
bellTent(350, 196)

---------------------------------------------------------------- back-right: canvas-covered wagon
local function wagon(x0, yb)
  local bed = rect(x0, yb - 16, x0 + 56, yb - 8)
  local cover = HP.mask()
  for k = 0, 3 do cover:add(c:ellipse(x0 + 7 + k * 14, yb - 22, 9, 14):clip(rect(x0, yb - 40, x0 + 56, yb - 16))) end
  cover:add(rect(x0 + 2, yb - 28, x0 + 54, yb - 16))
  local shaft = line({ { x0, yb - 10 }, { x0 - 16, yb - 4 } }, 2)
  F.shadow(x0, x0 + 58, yb, 10, 3)
  rimOf(union(bed, cover, shaft), L.timber)
  part(shaft, L.timber, { nopop = true, noshade = true })
  part(cover, L.awnB)
  for k = 1, 3 do vline(x0 + k * 14, yb - 34, yb - 17, L.awnB.shade) end
  part(bed, L.accent) hline(x0, x0 + 56, yb - 12, L.accent.deep)
  for _, wx in ipairs({ x0 + 10, x0 + 46 }) do
    local w = c:ellipse(wx, yb - 6, 7, 7) rimOf(w, L.timber) part(w, L.timber, { nopop = true }) fill(c:ellipse(wx, yb - 6, 4, 4), L.timber.shade)
    vline(wx, yb - 12, yb, L.timber.deep) hline(wx - 6, wx + 6, yb - 6, L.timber.deep) px(wx, yb - 6, IR.hi)
  end
  -- pots hanging off the back
  fill(c:ellipse(x0 + 58, yb - 18, 3, 3), IR.base) px(x0 + 57, yb - 19, IR.hi)
end
F.depth(2)
wagon(400, 152)
F.tree(468, 150, 46, 3)
F.depth(3)

---------------------------------------------------------------- firewood stacked between stakes
local function woodStack(x0, x1, yb)
  local stakes = rect(x0 - 2, yb - 22, x0, yb):add(rect(x1, yb - 22, x1 + 2, yb))
  local stack = rect(x0 + 1, yb - 18, x1 - 1, yb)
  F.shadow(x0, x1 + 2, yb, 8, 3)
  rimOf(union(stakes, stack), L.timber)
  part(stakes, L.timber, { nopop = true, noshade = true })
  fill(stack, L.timber.deep)
  for row = 0, 3 do for k = 0, (x1 - x0) // 6 do
    local x, y = x0 + 3 + k * 6 + (row % 2) * 3, yb - 3 - row * 5
    if x < x1 - 1 then local e = c:ellipse(x, y, 2, 2) fill(e, L.board.hi) px(x, y, L.board.shade) px(x + 1, y + 1, L.board.base) end
  end end
end
woodStack(22, 72, 196)
-- a rabbit at the woodpile
F.sprite({ ".ee.", ".ee.", "eDDd", "DnDDDw", ".DDDDD", "..d.d." }, 76, 190, { e = L.board.hi, D = L.board.base, d = L.board.shade, n = L.timber.edge, w = L.awnB.hi })
-- a gnome pegging a sock on the washing line
F.gnome(140, 134, { small = true, hat = L.produce, coat = L.leaf, arm = "up" })

---------------------------------------------------------------- the campfire (hero) with tripod pot and log seats
local function campfire(cx, cy)
  -- log seats around (back ones first)
  local function seat(x0, x1, y)
    local m = c:rrect(x0, y - 4, x1, y + 4, 4)
    F.shadow(x0, x1, y + 6, 4, 2)
    rimOf(m, L.timber) part(m, L.timber, { nopop = true }) hline(x0 + 4, x1 - 4, y - 3, L.timber.hi)
    local e = c:ellipse(x1 - 3, y, 3, 4) fill(e, L.board.hi) c:edgeIn(e, L.board.shade)
    m:each(function(x, yy) if (x * 3 + yy) % 13 == 0 then px(x, yy, L.timber.deep) end end)
  end
  seat(cx - 34, cx + 38, cy - 24)
  -- stone ring
  local ring = c:ellipse(cx, cy, 24, 9):cut(c:ellipse(cx, cy, 17, 5))
  local pit = c:ellipse(cx, cy, 17, 5)
  fill(pit, L.soil.deep)
  for k = 0, 13 do
    local a = k / 14 * 2 * pi
    local x, y = floor(cx + cos(a) * 21), floor(cy + sin(a) * 7)
    local st = c:rrect(x - 4, y - 3, x + 3, y + 2, 2)
    rimOf(st, S or L.stone) part(st, L.stone, { nopop = k % 3 ~= 0 })
  end
  -- logs crossed + embers
  local logs = line({ { cx - 12, cy + 2 }, { cx + 10, cy - 4 } }, 3):add(line({ { cx - 10, cy - 4 }, { cx + 12, cy + 2 } }, 3))
  rimOf(logs, L.timber) part(logs, L.timber, { nopop = true })
  pit:each(function(x, y) if hash(x, y, 9) < .25 and not logs:has(x, y) then px(x, y, G.deep) end end)
  -- flames
  local fl = poly{ { cx - 12, cy }, { cx - 9, cy - 16 }, { cx - 5, cy - 9 }, { cx - 2, cy - 28 }, { cx + 2, cy - 12 }, { cx + 6, cy - 22 }, { cx + 9, cy - 8 }, { cx + 12, cy } }
  fill(fl, G.deep)
  fill(fl:shrink(1), G.shade)
  fill(poly{ { cx - 8, cy }, { cx - 3, cy - 20 }, { cx + 1, cy - 9 }, { cx + 5, cy - 15 }, { cx + 8, cy } }, G.base)
  fill(poly{ { cx - 4, cy }, { cx - 1, cy - 12 }, { cx + 3, cy } }, G.hi)
  for i = 0, 12 do px(cx - 14 + floor(hash(i, 1, 31) * 30), cy - 32 - floor(hash(i, 2, 31) * 22), i % 3 == 0 and G.base or G.hi) end
  -- tripod and pot
  local tri = line({ { cx - 18, cy + 4 }, { cx, cy - 40 } }, 2):add(line({ { cx + 18, cy + 4 }, { cx, cy - 40 } }, 2)):add(line({ { cx + 4, cy - 2 }, { cx, cy - 40 } }, 1))
  rimOf(tri, L.timber) part(tri, L.timber, { nopop = true, noshade = true })
  vline(cx, cy - 39, cy - 30, IR.deep)
  local pot = c:ellipse(cx, cy - 25, 7, 5):add(rect(cx - 7, cy - 28, cx + 7, cy - 26))
  rimOf(pot, IR) part(pot, IR) hline(cx - 7, cx + 7, cy - 28, IR.hi) fill(rect(cx - 5, cy - 29, cx + 5, cy - 29), L.produce.base)
  fill(c:ellipse(cx, cy - 29, 7, 3):cut(c:ellipse(cx, cy - 29, 6, 2)):clip(rect(cx - 8, cy - 33, cx + 8, cy - 29)), IR.deep)
  F.smoke(cx + 1, cy - 38, 8, .5, 2)
  -- warm light on the ground
  local glowM = c:ellipse(cx, cy + 4, 40, 13):cut(c:ellipse(cx, cy, 25, 10))
  glowM:each(function(x, y) if hash(x, y, 33) < .3 and not F.roadM:has(x, y) then px(x, y, L.roof.hi) end end)
  seat(cx - 46, cx - 22, cy + 4)
  seat(cx + 24, cx + 50, cy + 2)
  seat(cx - 16, cx + 18, cy + 20)
end
campfire(132, 214)
-- gnomes on the seats: one toasting a marshmallow, one with a mug
-- (the back gnome sits on the back seat, playing a lute)
local _, lx, ly = F.gnome(104, 191, { hat = L.leaf, coat = L.roof2, arm = "hold", noShadow = true })
local lute = c:ellipse(lx + 2, ly, 4, 3):add(line({ { lx + 5, ly - 1 }, { lx + 12, ly - 6 } }, 1))
rimOf(lute, L.timber) part(lute, L.board, { nopop = true }) fill(c:ellipse(lx + 2, ly, 1, 1), L.timber.edge) px(lx + 12, ly - 7, L.timber.base)
for _, n in ipairs({ { lx + 8, ly - 14 }, { lx + 13, ly - 18 } }) do vline(n[1] + 1, n[2] - 3, n[2], L.timber.edge) fill(rect(n[1], n[2], n[1] + 1, n[2] + 1), L.timber.edge) end -- music notes
local _, mx, my = F.gnome(96, 210, { hat = L.awnA, coat = L.accent, arm = "out" })
fill(line({ { mx, my }, { mx + 10, my - 7 } }), L.board.base) fill(rect(mx + 10, my - 9, mx + 12, my - 7), L.awnB.hi) px(mx + 12, my - 7, L.roof.shade)
local _, ux, uy = F.gnome(174, 208, { hat = L.roof, coat = L.lav, arm = "out", flip = true })
fill(rect(ux - 3, uy - 3, ux, uy + 1), L.board.hi) px(ux, uy - 2, L.board.base) px(ux - 2, uy - 5, L.cloud.top) px(ux - 1, uy - 7, L.cloud.top)
-- a dog asleep by the fire, nose on its paws
F.sprite({
  ".ee.............",
  "eDDe....DDDDD...",
  "DDeDDDDDDDDDDD..",
  "nwDDDDDDDDdDDDt.",
  "wwwDDDDDDDDDDDtt",
  ".wwdddddddddd...",
}, 154, 228, { e = L.timber.base, D = L.board.base, d = L.board.shade, n = L.timber.edge, w = L.awnB.hi, t = L.board.hi })
hline(156, 157, 230, L.timber.edge) -- closed eye

---------------------------------------------------------------- camp kitchen table, bottom-left
local tbl = rect(24, 236, 76, 239):add(rect(27, 240, 30, 252)):add(rect(70, 240, 73, 252))
F.shadow(26, 76, 252, 8, 3)
rimOf(tbl, L.timber) part(tbl, L.board, { nopop = true })
local ket = c:ellipse(36, 231, 5, 4):add(rect(41, 228, 44, 229)) rimOf(ket, L.accent) part(ket, L.accent) fill(rect(34, 226, 38, 227), L.accent.shade)
local pan = c:ellipse(56, 234, 7, 2) rimOf(pan, IR) part(pan, IR, { nopop = true }) fill(rect(63, 233, 70, 234), L.timber.base)
for k = 0, 2 do px(52 + k * 3, 233, L.produce.base) end
local loaf = c:ellipse(68, 232, 4, 3) rimOf(loaf, L.board) part(loaf, L.roof)

---------------------------------------------------------------- bedrolls, packs and the raccoon (bottom-right of the road)
local function bedroll(x, y, r)
  local m = c:rrect(x - 14, y - 5, x + 14, y + 5, 5)
  rimOf(m, r) part(m, r)
  for k = -8, 8, 8 do vline(x + k, y - 5, y + 5, r.deep) end
  local e = c:ellipse(x + 12, y, 3, 5) fill(e, r.hi) c:ellipse(x + 12, y, 1, 3):edge():each(function(xx, yy) px(xx, yy, r.shade) end)
  hline(x - 6, x - 4, y - 5, L.timber.base)
end
bedroll(300, 230, L.accent) bedroll(312, 240, L.roof2)
local function pack(x, yb, r, coon)
  local m = c:rrect(x - 8, yb - 18, x + 8, yb, 4)
  local flap = c:rrect(x - 8, yb - 20, x + 8, yb - 12, 3)
  F.shadow(x - 6, x + 8, yb, 6, 2)
  rimOf(union(m, flap), r) part(m, r) part(flap, r, { sep = true })
  fill(rect(x - 1, yb - 13, x + 1, yb - 11), L.roof.base)
  fill(c:ellipse(x + 10, yb - 8, 4, 4), IR.base) px(x + 9, yb - 10, IR.hi) -- tin cup
end
pack(346, 258, L.leaf)
pack(330, 262, L.roof)
-- quirk: a raccoon climbing out of the green pack, sausage in its paws, ringed tail over the rim
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
F.depth(0)
F.birds({ { 330, 40, 2 }, { 344, 48, 1 }, { 120, 56, 2 } })
F.depth(3)
-- lantern on a pole by the road
local lp = rect(286, 176, 287, 212) rimOf(lp, L.timber) part(lp, L.timber, { nopop = true, noshade = true })
fill(rect(281, 176, 287, 177), L.timber.base) vline(281, 178, 180, L.timber.edge)
local lan = rect(278, 181, 284, 188) rimOf(lan, L.timber) fill(lan, G.base) px(279, 182, G.hi) vline(284, 182, 188, G.shade)
-- sign with a tent pictogram
F.sign(212, 196, 20, 12, L.board)
fill(poly{ { 206, 205 }, { 212, 198 }, { 218, 205 } }, L.awnA.base) fill(poly{ { 211, 205 }, { 212, 202 }, { 213, 205 } }, L.timber.deep)
-- fallen leaves
for i = 0, 40 do
  local x, y = 20 + floor(hash(i, 1, 55) * 440), 140 + floor(hash(i, 2, 55) * 120)
  if not (x > 378 and y > 228) then local r = (i % 2 == 0) and L.foliage or L.foliage2 px(x, y, r.base) px(x + 1, y, r.shade) end
end
F.finish()
