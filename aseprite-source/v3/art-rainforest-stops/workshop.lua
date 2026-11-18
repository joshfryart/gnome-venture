-- workshop.lua : "Workshop" stop look, RAINFOREST (rainforest_canopy), 480x270 gate view.
-- Same composition as the Maplewold workshop (art-2701-batch3/stops/opus3/workshop.lua) and the forest one, re-cast
-- as a jungle woodcarver's and rope-maker's yard (carved logs, bark cloth, dyes, hanging cords):
-- road's end: a lashed bamboo gantry hoisting a chip-carved mahogany log over a yard of hardwood logs and rope coils,
-- between a canopy tree and a fig. Back left: a teal-walled bark-cloth shed with patterned sheets hanging inside, a
-- bamboo rack of dyed skeins, a log-end stack. Back right: a dugout canoe being burnt out on trestles, a bamboo clump.
-- Left hero: a stone dye hearth under a palm-thatch lean-to, three painted clay dye vats (indigo, turmeric, annatto)
-- steaming on it, dyed skeins hanging from the eave, a sloth hanging beside them, a coati asleep in the warmth, a
-- gnome beating bark cloth on a log, a water jar with a blue dart frog. Right hero: the carver's hardwood workshop
-- (green palm thatch, carved frieze, two painted totem posts), open front: carved masks, rope hanks, bench with a
-- half-carved toucan, the carver; carved paddles on the wall. Foreground: a log being carved into a caiman, a rope
-- walk (twisting wheel, three dyed strands, the top, the finished rope), rope coils, a basket of cord balls, folded
-- bark cloth, a slit drum, a gnome carrying a rope coil, log ends with a bromeliad, an indigo pot of soaking skeins.
-- Quirk: an oropendola wearing a red gnome hat clings to its long woven nest hanging from the gantry beam, two chicks
-- gaping in the doorway.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-rainforest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "workshop", out = DIR, farTrees = { 24, 52, 160, 300, 330, 440 },
  treeLineGap = { 198, 290 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local IR, G = L.iron, L.glow
local indigo = F.rp("#a6c8f2 #5e8ad6 #3c5eae #2a4080 #1a2852")
local turmeric = F.rp("#fff08a #f6c838 #d0981e #96661a #5c3e16")
local annatto = F.rp("#ffa070 #e8582e #b83a28 #7c2622 #4a1618")
local tapa = F.rp("#f6e8c2 #e0c99a #bca070 #8c7650 #5c4c34")   -- beaten bark cloth
local coir = F.rp("#e6bc80 #c0904e #966838 #6a4628 #42281a")    -- coconut-fibre rope
local clay = F.rp("#eca676 #c87644 #9e5232 #6e3626 #44221c")    -- fired clay
local steamC = { "#e4ecd6", "#d6e2c8", "#c8d6ba" }

---------------------------------------------------------------- local helpers
-- a bark-on hardwood log lying left-right, end grain on the right
local function log(x0, x1, y, r, bark)
  bark = bark or L.timber
  local m = c:rrect(x0, y - r, x1, y + r, r)
  rimOf(m, bark) part(m, bark, { nopop = true })
  m:each(function(x, yy) if hash(x // 3, yy, 17) < .18 then px(x, yy, bark.shade) elseif hash(x // 2, yy, 18) < .06 then px(x, yy, bark.hi) end end)
  hline(x0 + r, x1 - r, y - r + 1, bark.hi)
  F.logEnd(x1 - r + 1, y, r, bark)
  return m
end
-- chip-carved band across a log: pale triangles cut into the bark
local function chipBand(x0, x1, ytop, ybot)
  for x = x0, x1 do
    local t = abs((x - x0) % 6 - 3)
    for y = ytop, ybot do
      if y - ytop >= t and y - ytop <= t + 1 then px(x, y, L.board.base) elseif y - ytop == t + 2 then px(x, y, L.board.deep) end
    end
  end
  hline(x0, x1, ytop - 1, L.board.hi)
end
-- a hank of dyed cord hanging from (x,y): 3 px wide, twist ticks, a fibre tie near the top
local function skein(x, y, len, r)
  local m = rect(x - 1, y, x + 1, y + len - 1):add(rect(x, y + len, x, y + len))
  rimOf(m, r)
  m:each(function(xx, yy)
    local k = xx - x
    local h = k < 0 and r.hi or (k == 0 and r.base or r.shade)
    if (yy + xx) % 3 == 0 then h = k < 0 and r.base or r.deep end
    px(xx, yy, h)
  end)
  hline(x - 1, x + 1, y + 2, coir.deep) px(x - 1, y + 2, coir.base)
  return m
end
-- a twisted cord from (x0,y0) to (x1,y1), sagging by sag
local function cord(x0, y0, x1, y1, sag, r, thick)
  r = r or coir
  local n = math.max(1, abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do
    local t = i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + .5)
    if thick then
      px(x, y, (x % 3 == 0) and r.hi or r.base) px(x, y + 1, (x % 3 == 1) and r.deep or r.shade)
    else
      px(x, y, (x % 3 == 0) and r.deep or r.shade)
    end
  end
end
-- a flat coil of rope lying on the ground: a spiral of strands on top, a 2 px side band, a loose end
local function coil(x, yb, rx, ry, r, noShadow)
  r = r or coir
  local cy = yb - 2 - ry
  local topE = c:ellipse(x, cy, rx, ry)
  local side = topE:shift(0, 1):add(topE:shift(0, 2)):cut(topE)
  local all = union(topE, side)
  if not noShadow then F.shadow(x - rx, x + rx, yb + 1, 4, 2) end
  rimOf(all, r)
  side:each(function(xx, yy) px(xx, yy, (xx - yy) % 3 == 0 and r.deep or r.shade) end)
  topE:each(function(xx, yy)
    local dx, dy = (xx - x) / rx, (yy - cy) / math.max(1, ry)
    local d = math.sqrt(dx * dx + dy * dy)
    local ring = d * rx / 2.2 + math.atan(dy, dx) / (2 * pi)
    local f = ring - floor(ring)
    local h = f < .45 and r.base or (f < .72 and r.shade or r.deep)
    if f < .25 and dx + dy < .2 then h = r.hi end
    if (xx + yy) % 4 == 0 and h == r.base then h = r.shade end
    if d < .22 then h = r.edge end
    px(xx, yy, h)
  end)
  px(x + rx + 1, yb - 2, r.base) px(x + rx + 2, yb - 1, r.shade) px(x + rx + 3, yb - 1, r.base) px(x + rx + 4, yb, r.hi) px(x + rx + 5, yb, r.shade)
end
-- a bark-cloth (tapa) sheet: fibre texture, dark painted border triangles and a chevron field, ragged foot
local function tapaSheet(x0, y0, w, h, seed, ink)
  ink = ink or L.timber
  local m = rect(x0, y0, x0 + w, y0 + h)
  for x = x0, x0 + w do if hash(x, y0, seed) < .45 then m:set(x, y0 + h + 1) end end
  rimOf(m, tapa)
  m:each(function(x, y)
    local u, v = x - x0, y - y0
    local hh = tapa.base
    if hash(x // 2, y, seed + 1) < .14 then hh = tapa.hi elseif hash(x, y // 2, seed + 2) < .1 then hh = tapa.shade end
    if u == w or (u % 5 == 4 and v > 4) then hh = tapa.shade end -- folds
    if v == 2 or v == h - 2 then hh = ink.base end
    if v >= 3 and v <= 4 and (u % 4) >= (v - 2) * 2 then hh = ink.shade end
    if v > 6 and v < h - 4 and (u + abs((v % 6) - 3)) % 6 == 0 then hh = (v // 6) % 2 == 0 and L.redbark.shade or ink.shade end
    if v > 6 and v < h - 4 and (u + v) % 6 == 3 and (u - v) % 6 == 3 then hh = annatto.shade end
    px(x, y, hh)
  end)
  hline(x0, x0 + w, y0, tapa.hi)
  return m
end
-- a clay pot with a painted zigzag band; dye = surface ramp
local function dyePot(x, yb, rx, h, dye, o)
  o = o or {}
  local cy = yb - h // 2
  local body = c:ellipse(x, cy, rx, h // 2)
  local neck = rect(x - rx + 3, yb - h - 1, x + rx - 3, yb - h + 3)
  local lip = c:ellipse(x, yb - h - 1, rx - 1, 2)
  local sil = union(body, neck, lip)
  if not o.noShadow then F.shadow(x - rx, x + rx, yb + 1, 6, 2) end
  rimOf(sil, clay)
  part(body, clay, { nopop = true }) part(neck, clay, { nopop = true, noshade = true })
  body:each(function(xx, yy)
    local dx, dy = (xx - x) / rx, (yy - cy) / (h / 2)
    if dx + dy < -.85 then px(xx, yy, clay.hi) elseif dx + dy > .95 then px(xx, yy, clay.deep) elseif dx > .45 then px(xx, yy, clay.shade) end
  end)
  for xx = x - rx + 1, x + rx - 1 do
    local yy = cy - 2 + ((xx // 2) % 2)
    if body:has(xx, yy) then px(xx, yy, o.band or L.awnB.base) px(xx, yy + 2, o.band2 or L.timber.deep) end
  end
  fill(lip, clay.base) lip:each(function(xx, yy) if not lip:has(xx, yy - 1) then px(xx, yy, clay.hi) end end)
  local surf = c:ellipse(x, yb - h - 1, rx - 3, 1)
  fill(surf, dye.shade)
  surf:each(function(xx, yy) if hash(xx, yy, 81) < .3 then px(xx, yy, dye.base) end end)
  px(x - rx // 2, yb - h - 1, dye.hi) px(x + 1, yb - h - 1, dye.hi)
  if o.steam then
    for k = 0, 4 do
      local sx, sy = x - 1 + floor(sin(k * 1.6 + x) * 2) + k, yb - h - 4 - k * 4
      fill(c:ellipse(sx, sy, 1 + k // 2, 1), steamC[1 + k % 3])
    end
  end
  return sil
end
-- a stack of folded bark cloth: soft fold edges, each sheet's painted border showing on its front
local function tapaStack(x0, x1, yb, n)
  for k = 0, n - 1 do
    local y = yb - k * 4
    local a, b = x0 + (k % 2) * 2, x1 - (k % 2) * 2
    local fm = c:rrect(a, y - 3, b, y, 1)
    rimOf(fm, tapa) part(fm, tapa, { nopop = true, noshade = true })
    hline(a + 1, b - 1, y - 3, tapa.hi)
    local ink = ({ L.timber, L.redbark, annatto, indigo })[k % 4 + 1]
    for x = a + 1, b - 1 do
      local t = (x - a) % 4
      if t < 2 then px(x, y - 1, ink.shade) end
      if t == 0 then px(x, y - 2, ink.base) end
    end
    px(b - 1, y - 1, tapa.deep) px(b - 1, y - 2, tapa.shade)
  end
end
local function shavings(x0, x1, y0, y1, n, seed, r)
  r = r or L.board
  for i = 1, n do
    local x, y = x0 + floor(hash(i, 1, seed) * (x1 - x0)), y0 + floor(hash(i, 2, seed) * (y1 - y0))
    local d = hash(i, 3, seed) < .5 and 1 or -1
    px(x, y, r.hi) px(x + d, y, r.base) px(x + d, y - 1, r.hi)
    if hash(i, 4, seed) < .5 then px(x, y + 1, r.shade) end
  end
end
-- lashing: a few wraps of fibre rope round a joint
local function lash(x, y, w)
  for k = 0, 2 do hline(x - w, x + w, y + k, k == 1 and coir.shade or coir.base) px(x - w, y + k, coir.hi) end
end

---------------------------------------------------------------- road's end: carving-log yard + lashed bamboo gantry
F.depth(2)
F.tree(188, 128, 52, 1)
F.tree(300, 128, 48, 3)
local function crane()
  -- the yard: hardwood logs, a rope coil
  for k = 0, 2 do F.logEnd(206 + k * 7, 122, 3, L.redbark) end
  for k = 0, 1 do F.logEnd(209 + k * 7, 116, 3, L.timber) end
  F.logEnd(212, 110, 3, L.redbark)
  log(246, 278, 120, 4, L.redbark) log(250, 282, 112, 4, L.timber) log(244, 274, 104, 3, L.redbark)
  F.moss(rect(244, 116, 282, 124), .12, 30)
  local legL = line({ { 200, 126 }, { 210, 54 } }, 3):add(line({ { 220, 126 }, { 212, 54 } }, 2))
  local legR = line({ { 284, 126 }, { 274, 54 } }, 3):add(line({ { 264, 126 }, { 272, 54 } }, 2))
  local beam = rect(196, 50, 292, 54)
  local brace = line({ { 213, 70 }, { 228, 56 } }, 2):add(line({ { 271, 70 }, { 256, 56 } }, 2))
  F.shadow(200, 286, 127, 8, 3)
  rimOf(union(legL, legR, beam, brace), L.bamboo)
  part(legL, L.bamboo, { nopop = true }) part(legR, L.bamboo, { nopop = true }) part(brace, L.bamboo, { nopop = true, noshade = true })
  union(legL, legR):each(function(x, y) if y % 8 == 0 then px(x, y, L.bamboo.deep) end end)
  part(beam, L.bamboo) F.bambooWall(beam, L.bamboo, 5, true, 33)
  hline(196, 292, 50, L.bamboo.hi)
  for _, bx in ipairs({ 197, 291 }) do vline(bx, 51, 53, L.bamboo.deep) px(bx, 52, L.soil.deep) end -- open culm ends
  -- rope lashings at every joint
  lash(211, 55, 3) lash(273, 55, 3) lash(220, 62, 2) lash(264, 62, 2)
  F.moss(rect(198, 118, 224, 126):clip(legL), .3, 32) F.moss(rect(262, 118, 288, 126):clip(legR), .3, 33)
  -- wooden pulley, coir rope, a rope sling round the carved log
  local pul = c:ellipse(238, 58, 3, 3) rimOf(pul, L.timber) part(pul, L.timber) px(238, 58, L.board.hi)
  for y = 61, 78 do px(238, y, y % 3 == 0 and coir.deep or coir.shade) end
  for y = 58, 76 do px(240, y, y % 3 == 1 and coir.deep or coir.shade) end
  fill(rect(236, 79, 241, 80), L.timber.base)
  cord(226, 88, 238, 80, 0, coir) cord(238, 80, 252, 88, 0, coir)
  local lg = log(218, 262, 92, 5, L.redbark)
  chipBand(224, 232, 89, 94) chipBand(242, 250, 89, 94)
  vline(237, 87, 97, L.board.shade) vline(253, 87, 97, L.board.shade)
  -- winch: a rope-wound drum on the right leg
  local drum = rect(268, 106, 282, 112) rimOf(drum, L.timber) part(drum, coir)
  for x = 268, 282 do for y = 107, 111 do if (x + y) % 3 == 0 then px(x, y, coir.deep) end end end
  fill(rect(282, 104, 288, 105), L.timber.base) fill(rect(287, 104, 288, 112), L.timber.base)
  for y = 56, 105 do px(276, y, y % 3 == 0 and coir.deep or coir.shade) end
  F.gnome(296, 126, { small = true, hat = L.awnA, coat = L.teal, arm = "out", flip = true })
  -- a coir rope coil in the yard
  coil(232, 126, 7, 2, coir)
  F.depth(3)
  -- quirk: the long woven pouch nest of an oropendola hanging from the beam, two chicks gaping in the doorway,
  -- the parent (in a red gnome hat) clinging to its side
  local nest = poly{ { 251, 55 }, { 256, 55 }, { 258, 62 }, { 260, 72 }, { 259, 80 }, { 256, 84 }, { 252, 84 }, { 249, 80 }, { 248, 72 }, { 249, 62 } }
  rimOf(nest, coir)
  nest:each(function(x, y)
    local h = coir.base
    if ((x + y) // 2) % 2 == 0 then h = coir.shade end
    if (x - y) % 4 == 0 then h = coir.hi end
    if x >= 257 or y >= 81 then h = (x + y) % 2 == 0 and coir.deep or coir.shade end
    if x <= 249 and y > 60 then h = coir.hi end
    px(x, y, h)
  end)
  for k = 0, 3 do px(248 + k * 4, 85 + (k % 2), coir.shade) px(250 + k * 3, 86, coir.deep) end -- loose straggling fibres
  local door = c:ellipse(254, 69, 3, 3) fill(door, L.soil.deep) px(252, 67, L.soil.edge)
  F.sprite({ ".yy...", "yOOy.", ".ky.yy", "..yOOy", "...ky." }, 251, 66, { y = turmeric.hi, O = annatto.base, k = L.timber.edge }, { rim = false })
  F.sprite({
    "....R......",
    "...RRr.....",
    "..RRRRr....",
    ".hhhhhhh...",
    "..KKKKK....",
    "PPKbKKK....",
    "PPPKKKK....",
    "..KKCCC....",
    "..oKCCCC...",
    "..oCCCCC...",
    "...CCCCC...",
    "..oCCCCcC..",
    "...CCcCC...",
    "....YYYY...",
    "....YyYY...",
    "....YYyY...",
    ".....YY....",
  }, 259, 56, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, K = "#3a2e2c", b = "#6aa6e0", P = L.awnB.hi,
    C = L.redbark.shade, c = L.redbark.deep, Y = turmeric.base, y = turmeric.shade, o = L.timber.deep })
end
crane()

---------------------------------------------------------------- back-left: the bark-cloth shed, the skein rack, log stacks
F.depth(1)
F.tree(84, 130, 40, 2)
F.tree(10, 134, 38, 1)
local stop, scx, swall = F.building{ x0 = 22, x1 = 70, yb = 138, wh = 28, rh = 20, wall = L.wall2, roof = L.roof, noAttic = true, noFrame = true }
-- a wide open front with patterned bark cloth hanging to dry inside
local open = rect(28, stop + 6, 64, 137)
fill(open, L.soil.deep) hline(28, 64, stop + 6, L.timber.edge)
for x = 28, 64, 6 do vline(x, stop + 6, 137, L.timber.base) end
hline(28, 64, stop + 8, L.timber.deep)
tapaSheet(30, stop + 9, 9, 12, 3) tapaSheet(42, stop + 9, 9, 14, 5, L.redbark) tapaSheet(54, stop + 9, 8, 11, 7)
F.smoke(56, 90, 5, .6, 2)
-- a bamboo rack of dyed skeins
local rack = rect(96, 116, 98, 140):add(rect(148, 116, 150, 140)):add(rect(95, 116, 151, 117))
rimOf(rack, L.bamboo) part(rack, L.bamboo, { nopop = true, noshade = true })
local skc = { indigo, turmeric, annatto, indigo, L.teal, annatto, turmeric, indigo }
for k = 0, 7 do skein(102 + k * 6, 118, 12 + floor(hash(k, 1, 90) * 6), skc[k + 1]) end
-- log ends waiting, a stack of bark strips
F.shadow(156, 178, 141, 6, 2)
for k = 0, 2 do F.logEnd(159 + k * 7, 137, 3, L.redbark) end
for k = 0, 1 do F.logEnd(162 + k * 7, 131, 3, L.timber) end
F.logEnd(165, 125, 3, L.redbark)

---------------------------------------------------------------- back-right: a dugout canoe being burnt out on trestles
local function canoe()
  local hull = poly{ { 300, 120 }, { 306, 126 }, { 362, 126 }, { 370, 119 }, { 368, 129 }, { 360, 135 }, { 310, 135 }, { 302, 129 } }
  F.shadow(304, 364, 142, 6, 2)
  for _, tx in ipairs({ 316, 352 }) do
    local t = line({ { tx - 4, 142 }, { tx + 3, 133 } }):add(line({ { tx + 4, 142 }, { tx - 3, 133 } }))
    rimOf(t, L.timber) fill(t, L.timber.base)
  end
  rimOf(hull, L.timber) part(hull, L.timber)
  hull:each(function(x, y) if (x + y * 3) % 11 == 0 then px(x, y, L.timber.shade) end if y >= 132 and hash(x // 2, y, 91) < .4 then px(x, y, L.redbark.deep) end end)
  line({ { 302, 121 }, { 306, 126 }, { 362, 126 }, { 369, 120 } }):each(function(x, y) px(x, y, L.timber.hi) end)
  -- the hollow: charred wood, a smouldering trough of embers
  local hol = rect(310, 127, 358, 129)
  fill(hol, L.soil.edge)
  hol:each(function(x, y) local v = hash(x, y, 92) if v < .25 then px(x, y, G.shade) elseif v < .32 then px(x, y, G.base) elseif v < .36 then px(x, y, G.hi) end end)
  hline(310, 358, 130, L.timber.deep)
  F.smoke(322, 120, 4, .5, 1) F.smoke(344, 121, 4, .4, 1)
  -- the prow carved into a caiman snout
  px(369, 119, L.board.hi) px(370, 119, L.board.base) px(368, 121, L.timber.edge)
end
canoe()
F.depth(2)
F.tree(458, 142, 54, 3)
F.bamboo(424, 142, 46, 4, 61)

---------------------------------------------------------------- left hero: dye hearth under a palm-thatch lean-to
F.depth(3)
local function hearth()
  local posts = rect(92, 128, 95, 206):add(rect(186, 140, 189, 208))
  local roofm = poly{ { 82, 126 }, { 198, 139 }, { 198, 147 }, { 82, 134 } }
  local fire = rect(104, 166, 162, 202)
  local chim = rect(124, 84, 140, 166)
  F.shadow(94, 194, 208, 12, 5)
  rimOf(union(chim, fire), L.stone)
  part(chim, L.stone) F.courses(chim, 84, 6, 8, L.stone)
  fill(rect(122, 82, 142, 85), L.stone.shade) hline(122, 142, 82, L.stone.hi)
  F.moss(rect(122, 82, 142, 86), .35, 34) F.shine(chim, .05, 35)
  part(fire, L.stone, { sep = true }) F.courses(fire, 166, 6, 11, L.stone, 5) F.moss(fire, .12, 36) F.shine(fire, .05, 37)
  local mouth = c:rrect(118, 176, 150, 200, 8):clip(rect(118, 176, 150, 196))
  fill(mouth, L.soil.deep)
  local coals = c:ellipse(134, 194, 13, 4):clip(mouth)
  fill(coals, G.shade)
  coals:each(function(x, y) local v = hash(x, y, 4) if v < .3 then px(x, y, G.base) elseif v < .4 then px(x, y, G.hi) elseif v > .85 then px(x, y, G.deep) end end)
  local flame = poly{ { 124, 194 }, { 128, 184 }, { 131, 189 }, { 134, 180 }, { 138, 188 }, { 141, 183 }, { 144, 194 } }
  fill(flame, G.base) fill(poly{ { 129, 194 }, { 134, 185 }, { 139, 194 } }, G.hi)
  F.logEnd(122, 194, 2) F.logEnd(147, 194, 2, L.redbark)
  hline(114, 154, 200, L.stone.hi) hline(114, 154, 201, L.stone.deep)
  for y = 203, 214 do for x = 116 + (y - 203), 152 - (y - 203) do if hash(x, y, 7) < .35 then px(x, y, L.gold.hi) end end end
  -- three dye vats on the hearth
  dyePot(114, 170, 9, 16, indigo, { noShadow = true, steam = true, band = turmeric.base })
  dyePot(152, 170, 9, 15, annatto, { noShadow = true, steam = true, band = L.awnB.hi, band2 = indigo.shade })
  dyePot(133, 172, 10, 18, turmeric, { noShadow = true, steam = true, band = annatto.base })
  -- a stirring paddle in the turmeric vat, a skein lifted out of the indigo dripping blue
  line({ { 136, 153 }, { 141, 140 } }, 1):each(function(x, y) px(x, y, L.board.base) end) px(141, 139, L.board.hi)
  local lift = line({ { 112, 153 }, { 108, 145 } }, 1) lift:each(function(x, y) px(x, y, L.board.shade) end)
  -- posts and the palm-thatch lean-to roof, the chimney through it
  rimOf(union(posts, roofm), L.timber)
  part(posts, L.bamboo, { nopop = true })
  posts:each(function(x, y) if y % 9 == 0 then px(x, y, L.bamboo.deep) end end)
  part(roofm, L.roof, { sep = true }) F.palmThatch(roofm, L.roof, 126, 9999, 67)
  for x = 82, 198 do
    local yb = floor(134 + (x - 82) * 13 / 116 + .5)
    local len = 1 + floor(hash(x, 134, 68) * 3)
    for k = 1, len do px(x, yb + k, k == len and L.roof.edge or (k == 1 and L.roof.deep or L.roof.shade)) end
  end
  lash(93, 132, 2) lash(187, 143, 2)
  part(rect(124, 84, 140, 126):clip(chim), L.stone) F.courses(rect(124, 84, 140, 126), 84, 6, 8, L.stone)
  F.moss(rect(124, 120, 140, 126), .3, 38)
  F.smoke(132, 78, 9, .7, 3)
  -- dyed skeins hanging from the eave
  local function eave(x) return floor(134 + (x - 82) * 13 / 116 + .5) + 3 end
  local hang = { { 99, indigo, 20 }, { 104, turmeric, 16 }, { 109, annatto, 22 }, { 158, L.teal, 9 }, { 163, turmeric, 12 } }
  for _, s in ipairs(hang) do skein(s[1], eave(s[1]), s[3], s[2]) end
  -- rope loops hung on the left post
  for k = 0, 2 do
    local y = 166 + k * 10
    local o = c:ellipse(100, y, 4, 4):cut(c:ellipse(100, y, 2, 2))
    rimOf(o, coir) fill(o, k == 1 and annatto.base or coir.base)
    o:each(function(x, yy) if x + yy < 100 + y - 2 then px(x, yy, k == 1 and annatto.hi or coir.hi) elseif (x - yy) % 3 == 0 then px(x, yy, k == 1 and annatto.deep or coir.deep) end end)
  end
  -- a stack of folded bark cloth by the hearth
  F.shadow(166, 184, 203, 4, 2)
  tapaStack(166, 184, 202, 4)
  -- a three-toed sloth hanging from the roof beam by the right post
  F.sprite({
    "kk.......kk",
    ".A.......A.",
    ".AA.....AA.",
    "..AA...AA..",
    "..BBBBBBB..",
    ".BBBBBBBBB.",
    ".BBbBBBbBB.",
    ".BBBBBBBgB.",
    ".BBBbBBBBB.",
    "..BBBBBBB..",
    "..FFFFFFF..",
    ".FFeeFeeFF.",
    ".FEeFFFeEF.",
    "..FFFnFFF..",
    "...FFmFF...",
    "....FFF....",
  }, 168, eave(173) - 1, { k = L.timber.edge, A = L.palmTrunk.shade, B = L.palmTrunk.base, b = L.palmTrunk.hi, g = L.moss.shade,
    F = L.awnB.base, E = L.awnB.shade, e = L.timber.deep, n = L.timber.edge, m = L.soil.shade })
end
hearth()
-- a gnome beating bark cloth on a smooth log with a grooved beater
local function beating(x, yb)
  F.shadow(x - 14, x + 16, yb, 8, 3)
  local lg = log(x - 14, x + 18, yb - 5, 5, L.timber)
  local strip = rect(x - 10, yb - 11, x + 10, yb - 7):add(rect(x - 10, yb - 6, x - 8, yb - 2)):add(rect(x + 8, yb - 6, x + 10, yb - 3))
  rimOf(strip, tapa) part(strip, tapa, { nopop = true })
  strip:each(function(xx, yy) if xx % 2 == 0 and yy < yb - 7 then px(xx, yy, tapa.shade) end end)
  hline(x - 10, x + 10, yb - 11, tapa.hi)
  shavings(x - 16, x + 18, yb + 1, yb + 5, 10, 22, tapa)
end
beating(172, 232)
local _, hx, hy = F.gnome(148, 238, { hat = L.awnA, coat = indigo, arm = "up" })
fill(rect(hx, hy - 6, hx + 1, hy + 1), L.board.base)
local bt = rect(hx - 2, hy - 13, hx + 3, hy - 6) rimOf(bt, L.timber) part(bt, L.timber, { nopop = true })
for yy = hy - 12, hy - 7, 2 do hline(hx - 2, hx + 3, yy, L.timber.deep) end
for i = 0, 5 do px(hx + 4 + floor(hash(i, 1, 23) * 12), hy - 4 - floor(hash(i, 2, 23) * 8), tapa.hi) end
fill(rect(146, 228, 150, 235), tapa.shade) px(146, 228, tapa.base) -- bark-cloth apron
-- a coati curled asleep in the hearth's warmth, ringed tail over its nose
F.sprite({
  "....TTttTTttTT.......",
  "..ttTTttTTttTTtt.....",
  ".TTt..........TTe....",
  ".TT...CCCCCCCCtteee..",
  "tt...CCCCCCCCCCCCCe..",
  "tt..CCCcCCCCCCCCwwCn.",
  "TT.CCCCCCcCCCCCCmwmmn",
  ".TCCCCCCCCCCCcCCmmm..",
  "..CCcCCCCCCCCCCCC....",
  "....LL......LL.......",
}, 97, 205, { e = L.soil.deep, C = L.soil.base, c = L.soil.shade, m = L.awnB.base, w = L.awnB.hi, n = L.timber.edge, T = L.needle.hi,
  t = L.soil.deep, L = L.soil.deep })
-- a clay water jar with a coconut-shell dipper; a blue dart frog on its lip
dyePot(198, 238, 7, 14, L.water, { band = indigo.base })
fill(rect(201, 221, 205, 222), L.soil.base) px(201, 221, L.soil.hi) vline(205, 218, 221, L.soil.shade)
F.sprite({ "b.b.", "BkBB", "BBkB", "b..b" }, 192, 219, { b = indigo.shade, B = "#4c9ae8", k = L.timber.edge })

---------------------------------------------------------------- right hero: the carver's hardwood workshop, open front
local function workshop()
  local x0, x1, yb = 296, 446, 208
  local top, cx, wallM, roofM = F.building{ x0 = x0, x1 = x1, yb = yb, wh = 56, rh = 36, wall = L.timber, roof = L.roof2, noFrame = true }
  F.planks(rect(x0, top + 4, x1, yb), L.timber, 5, true, 31)
  wallM:each(function(x, y) if y > yb - 6 and hash(x, y // 2, 39) < .45 then px(x, y, hash(x, y, 40) < .5 and L.moss.shade or L.moss.base) end end)
  -- carved frieze under the eave: a zigzag in pale wood and annatto dots
  local fz = rect(x0 + 1, top + 6, x1 - 1, top + 12)
  fill(fz, L.timber.deep)
  for x = x0 + 1, x1 - 1 do
    local t = abs((x % 8) - 4)
    px(x, top + 7 + t, L.board.base) px(x, top + 8 + t, L.board.shade)
    if x % 8 == 0 then px(x, top + 11, annatto.base) end
    if x % 8 == 4 then px(x, top + 7, turmeric.base) end
  end
  hline(x0 + 1, x1 - 1, top + 6, L.board.hi) hline(x0 + 1, x1 - 1, top + 12, L.board.deep)
  -- the gable: woven mat with a carved sunburst
  local gab = poly{ { x0 + 5, top }, { cx, top - 36 + 8 }, { x1 - 5, top } }:cut(roofM)
  part(gab, L.timber, { nopop = true }) F.planks(gab, L.timber, 4, true, 46)
  local sy = top - 13
  for k = 0, 11 do
    local a = k * pi / 6
    line({ { cx + cos(a) * 4, sy + sin(a) * 4 }, { cx + cos(a) * 9, sy + sin(a) * 8 } }):each(function(x, y) if gab:has(x, y) then px(x, y, k % 2 == 0 and annatto.base or turmeric.shade) end end)
  end
  local sun = c:ellipse(cx, sy, 3, 3) rimOf(sun, L.timber) fill(sun, turmeric.base) px(cx - 1, sy - 1, turmeric.hi) px(cx + 1, sy + 1, turmeric.shade)
  hline(cx - 1, cx + 1, sy + 1, L.timber.deep)
  F.vines(rect(x0, top + 2, x0 + 60, top + 5), .06, 47, 9)
  -- window, left of the doorway
  F.window(300, 176, 308, 184, L.timber)
  hline(298, 310, 188, L.timber.base) for k = 0, 5 do px(300 + k * 2, 187, L.fern.base) px(301 + k * 2, 186, L.fern.hi) end
  px(303, 185, L.orchid.hi) px(304, 185, L.orchid.base) px(307, 186, L.orchid.base)
  -- big open doorway with the interior
  local dx0, dx1, dy0 = 324, 418, 166
  local fr = rect(dx0 - 3, dy0 - 3, dx1 + 3, yb)
  fill(fr, L.timber.base) hline(dx0 - 3, dx1 + 3, dy0 - 3, L.timber.hi) hline(dx0 - 3, dx1 + 3, dy0 - 1, L.timber.deep)
  fill(rect(dx0, dy0, dx1, yb), L.soil.deep)
  fill(rect(dx0, yb - 6, dx1, yb), L.soil.shade)
  for x = dx0 + 4, dx1, 8 do vline(x, dy0, yb - 7, L.soil.edge) end
  -- back wall left: three carved, painted masks
  local function mask(mx, my, paint, paint2)
    local m = c:rrect(mx - 4, my, mx + 4, my + 11, 3)
    rimOf(m, L.timber) part(m, L.redbark, { nopop = true })
    m:each(function(x, y) if x < mx - 1 and y < my + 5 then px(x, y, L.redbark.hi) end end)
    hline(mx - 3, mx - 1, my + 4, paint.base) hline(mx + 1, mx + 3, my + 4, paint.base)
    px(mx - 2, my + 5, L.timber.edge) px(mx + 2, my + 5, L.timber.edge)
    vline(mx, my + 4, my + 7, L.redbark.shade) px(mx, my + 7, L.redbark.deep)
    hline(mx - 2, mx + 2, my + 9, paint2.base) px(mx - 2, my + 9, paint2.hi)
    px(mx - 3, my + 1, paint2.base) px(mx + 3, my + 1, paint2.base) px(mx, my + 1, paint.hi)
    vline(mx, my - 2, my - 1, coir.shade) -- hanging cord
  end
  mask(334, dy0 + 5, L.awnB, annatto) mask(346, dy0 + 4, turmeric, indigo) mask(358, dy0 + 6, indigo, L.awnB)
  -- back wall right: a rail of rope hanks and coils
  hline(368, 414, dy0 + 3, L.timber.base) hline(368, 414, dy0 + 4, L.timber.edge)
  for k = 0, 2 do
    local x = 374 + k * 14
    local o = c:ellipse(x, dy0 + 12, 5, 6):cut(c:ellipse(x, dy0 + 12, 3, 4))
    local rr = ({ coir, indigo, coir })[k + 1]
    rimOf(o, rr) fill(o, rr.base)
    o:each(function(xx, yy) if xx < x - 2 and yy < dy0 + 12 then px(xx, yy, rr.hi) elseif (xx + yy * 2) % 3 == 0 then px(xx, yy, rr.deep) end end)
  end
  skein(381, dy0 + 5, 14, annatto) skein(395, dy0 + 5, 12, turmeric) skein(409, dy0 + 5, 13, L.teal)
  -- workbench with a half-carved toucan, a gourd bowl, a mallet and chisels
  local bench = rect(330, 192, 414, 196)
  local legs = rect(334, 197, 337, 208):add(rect(407, 197, 410, 208))
  rimOf(union(bench, legs), L.timber) part(bench, L.board) F.planks(bench, L.board, 3, false, 41) part(legs, L.timber, { nopop = true, noshade = true })
  F.sprite({
    "...hhh........",
    "..hhhHOOOOOo..",
    "..hkhHOOOOoo..",
    "...hhH........",
    "...BBBb.......",
    "..BBBBbb......",
    "..bBBBbbB.....",
    "..bbBBbbbB....",
    "...bbbbbb.....",
    "..dddddddd....",
  }, 344, 182, { h = L.board.hi, H = L.board.base, k = L.timber.edge, O = annatto.base, o = annatto.shade, B = L.board.shade, b = L.board.deep, d = L.timber.base })
  local bowl = c:ellipse(366, 190, 5, 2):clip(rect(361, 189, 371, 192)) rimOf(bowl, L.soil) fill(bowl, L.soil.base) hline(362, 370, 189, L.soil.hi)
  fill(rect(374, 188, 378, 191), L.timber.base) hline(379, 384, 190, L.board.base) px(374, 188, L.timber.hi)
  for k = 0, 2 do local x = 388 + k * 3 hline(x, x, 190, IR.hi) vline(x, 188, 189, L.board.base) end
  shavings(338, 412, 200, 207, 30, 42)
  shavings(358, 380, 189, 191, 5, 43)
  -- the carver at the bench
  F.gnome(400, 208, { hat = L.lav, coat = annatto, arm = "hold", flip = true, noShadow = true })
  -- a hanging oil lamp
  vline(372, 166, 168, L.timber.edge) local ln = rect(370, 169, 374, 172) rimOf(ln, clay) fill(ln, clay.base) px(372, 168, G.hi) px(371, 167, G.base) hline(371, 373, 169, G.base)
  -- two painted totem posts flanking the doorway: stacked carved faces
  for _, tx in ipairs({ dx0 - 8, dx1 + 3 }) do
    local p = rect(tx, dy0 - 10, tx + 5, yb)
    rimOf(p, L.timber) part(p, L.timber, { nopop = true })
    vline(tx, dy0 - 10, yb, L.timber.hi)
    for k = 0, 4 do
      local fy = dy0 - 8 + k * 10
      local pc = ({ turmeric, annatto, indigo, L.teal, annatto })[k + 1]
      hline(tx, tx + 5, fy, L.timber.deep)
      px(tx + 1, fy + 3, pc.base) px(tx + 4, fy + 3, pc.base) px(tx + 1, fy + 4, L.timber.edge) px(tx + 4, fy + 4, L.timber.edge)
      vline(tx + 2, fy + 4, fy + 6, L.timber.hi) px(tx + 3, fy + 6, L.timber.shade)
      hline(tx + 1, tx + 4, fy + 8, pc.shade)
    end
    fill(rect(tx - 1, dy0 - 14, tx + 6, dy0 - 11), L.timber.base) hline(tx - 1, tx + 6, dy0 - 14, L.timber.hi)
  end
  -- sign above the doorway: a carved board with a painted figure-eight knot
  local sb = rect(354, 147, 390, 159) rimOf(sb, L.timber) part(sb, L.board) F.planks(sb, L.board, 4, false, 44)
  local knot = c:ellipse(366, 153, 4, 3):cut(c:ellipse(366, 153, 2, 1)):add(c:ellipse(377, 153, 4, 3):cut(c:ellipse(377, 153, 2, 1)))
  rimOf(knot, annatto) fill(knot, annatto.base)
  knot:each(function(x, y) if y < 152 then px(x, y, annatto.hi) elseif (x + y) % 3 == 0 then px(x, y, annatto.shade) end end)
  hline(358, 361, 156, annatto.base) hline(382, 386, 150, annatto.base)
  -- carved paddles leaning on the right wall
  for k = 0, 2 do
    local x = 430 + k * 6
    local shaft = line({ { x, 166 }, { x + 1, 186 } }, 1)
    local blade = c:ellipse(x + 1, 196, 2, 10)
    rimOf(union(shaft, blade), L.timber)
    fill(shaft, L.board.base) part(blade, k == 1 and L.redbark or L.board, { nopop = true })
    hline(x - 1, x + 3, 192, ({ annatto, indigo, turmeric })[k + 1].base) hline(x, x + 2, 199, ({ indigo, turmeric, annatto })[k + 1].base)
    px(x, 165, L.board.hi)
  end
end
workshop()

---------------------------------------------------------------- the rope walk in front of the workshop
local function ropeWalk()
  -- the twisting wheel on its frame, three hooks, the crank
  local wx, wy, R = 440, 212, 10
  local frame = rect(430, 204, 432, 228):add(rect(448, 204, 450, 228)):add(rect(429, 224, 451, 225))
  local ring = c:ellipse(wx, wy, R, R):cut(c:ellipse(wx, wy, R - 2, R - 2))
  local sp = HP.mask()
  for k = 0, 5 do local a = k * pi / 3 + .3 sp:add(line({ { wx, wy }, { wx + cos(a) * (R - 1), wy + sin(a) * (R - 1) } })) end
  F.shadow(430, 452, 228, 6, 2)
  rimOf(union(frame, ring, sp), L.timber)
  part(frame, L.timber, { nopop = true, noshade = true })
  part(sp, L.board, { nopop = true, noshade = true }) part(ring, L.timber, { nopop = true })
  ring:each(function(x, y) if (x - wx) + (y - wy) < -R then px(x, y, L.timber.hi) end end)
  fill(c:ellipse(wx, wy, 2, 2), L.timber.base) px(wx - 1, wy - 1, L.board.hi)
  fill(rect(wx, wy, wx + 7, wy + 1), L.timber.base) fill(rect(wx + 6, wy + 1, wx + 7, wy + 6), L.board.base) px(wx + 6, wy + 1, L.board.hi)
  -- the three dyed strands from the hooks to the top, then the finished rope to a stake
  local hooks = { { 428, 207, indigo }, { 428, 211, coir }, { 428, 215, annatto } }
  for _, h in ipairs(hooks) do px(h[1] + 1, h[2], IR.hi) px(h[1], h[2], IR.base) cord(h[1] - 1, h[2], 388, 214, 2, h[3], true) end
  -- the top: a grooved wooden cone on a little bamboo tripod
  local top = poly{ { 382, 209 }, { 388, 211 }, { 388, 218 }, { 382, 220 } }
  local tri = line({ { 380, 228 }, { 385, 218 } }):add(line({ { 390, 228 }, { 385, 218 } }))
  rimOf(union(top, tri), L.timber)
  fill(tri, L.bamboo.base)
  part(top, L.board, { nopop = true }) for y = 211, 217, 3 do hline(383, 387, y, L.board.deep) end
  -- finished rope: three colours laid together
  for x = 322, 381 do
    local t = (381 - x) / 59
    local y = floor(214 + t * 8 + 4 * t * (1 - t) + .5)
    local k = (x // 2) % 3
    px(x, y, ({ indigo.base, coir.base, annatto.base })[k + 1]) px(x, y + 1, ({ annatto.shade, indigo.shade, coir.shade })[k + 1])
  end
  local stake = rect(319, 221, 321, 236) rimOf(stake, L.timber) part(stake, L.timber, { nopop = true, noshade = true }) px(319, 221, L.timber.hi)
  F.shadow(319, 322, 236, 3, 1)
end
ropeWalk()

---------------------------------------------------------------- foreground left: log ends, indigo pot, the caiman log
F.shadow(26, 80, 204, 8, 3)
for row = 0, 3 do for k = 0, 4 - row do
  F.logEnd(30 + k * 10 + row * 5, 198 - row * 8, 5, (k + row) % 3 == 0 and L.timber or L.redbark)
end end
F.moss(rect(40, 170, 70, 176), .15, 46)
-- a red bromeliad and an orchid sprouting from the top log
F.sprite({ "r...r.r", ".rR.Rr.", "..rRr..", ".gGgGg.", "..gGg.." }, 42, 164, { r = L.helic.shade, R = L.helic.base, g = L.vine.base, G = L.vine.hi })
F.orchid(58, 174, L.orchid, 2)
-- the indigo pot with skeins soaking, one draped over the rim
dyePot(88, 204, 8, 16, indigo, { band = L.awnB.hi })
local dr = rect(83, 187, 85, 196) rimOf(dr, indigo) part(dr, indigo, { nopop = true, noshade = true })
for y = 188, 196, 2 do px(84, y, indigo.deep) end
px(84, 198, indigo.base) px(84, 200, indigo.shade)
local function caimanLog(x0, yb)
  -- trestles
  for _, tx in ipairs({ x0 + 12, x0 + 50 }) do
    local t = line({ { tx - 5, yb }, { tx + 4, yb - 12 } }, 2):add(line({ { tx + 5, yb }, { tx - 4, yb - 12 } }, 2))
    rimOf(t, L.timber) part(t, L.timber, { nopop = true, noshade = true })
  end
  F.shadow(x0, x0 + 70, yb, 8, 3)
  -- the log: bark at the tail end, carved scales and a snout at the head end
  local body = c:rrect(x0, yb - 22, x0 + 58, yb - 11, 5)
  local snout = poly{ { x0 + 56, yb - 21 }, { x0 + 76, yb - 17 }, { x0 + 78, yb - 14 }, { x0 + 74, yb - 12 }, { x0 + 56, yb - 11 } }
  local eyes = rect(x0 + 52, yb - 24, x0 + 56, yb - 22)
  local sil = union(body, snout, eyes)
  rimOf(sil, L.timber)
  sil:each(function(x, y)
    local u = x - x0
    local h
    if u < 22 + floor(hash(0, y, 61) * 4) then
      h = L.timber.base
      if (x + y) % 3 == 0 then h = L.timber.shade end
      if y < yb - 19 then h = L.timber.hi end
      if y > yb - 13 then h = L.timber.deep end
    else
      h = L.board.base
      if y < yb - 19 then h = L.board.hi elseif y > yb - 14 then h = L.board.shade end
      if u < 56 and ((x // 3) + (y // 3)) % 2 == 0 and y > yb - 19 and y < yb - 13 then h = L.board.shade end
      if u < 56 and y == yb - 22 and x % 3 == 0 then h = L.board.deep end -- ridge scutes
    end
    px(x, y, h)
  end)
  F.logEnd(x0 + 4, yb - 16, 5)
  F.moss(rect(x0, yb - 22, x0 + 18, yb - 11):clip(body), .12, 62)
  -- carving line, eye, nostrils, teeth
  for y = yb - 21, yb - 12 do local xx = x0 + 22 + floor(hash(0, y, 61) * 4) px(xx, y, L.board.hi) px(xx - 1, y, L.timber.edge) end
  fill(rect(x0 + 53, yb - 24, x0 + 55, yb - 23), L.board.hi) px(x0 + 54, yb - 23, L.timber.edge) px(x0 + 53, yb - 24, turmeric.base)
  px(x0 + 74, yb - 17, L.board.deep) px(x0 + 76, yb - 16, L.board.deep)
  hline(x0 + 58, x0 + 75, yb - 14, L.board.deep)
  for x = x0 + 59, x0 + 73, 3 do px(x, yb - 13, L.awnB.hi) px(x + 1, yb - 15, L.awnB.hi) end
  shavings(x0 + 40, x0 + 84, yb - 2, yb + 6, 20, 63)
end
caimanLog(16, 246)
local _, ox, oy = F.gnome(108, 256, { hat = L.produce, coat = L.leaf, arm = "up", flip = true })
-- mallet raised, a chisel set to the caiman's jaw
fill(rect(ox, oy - 5, ox + 1, oy + 1), L.board.base) local ml = rect(ox - 2, oy - 9, ox + 3, oy - 6) rimOf(ml, L.timber) part(ml, L.timber, { nopop = true })
for i = 0, 3 do px(90 + floor(hash(i, 3, 53) * 6), 226 - i * 2, L.board.hi) end

---------------------------------------------------------------- foreground right: coils, a basket of cord balls, folded bark cloth
F.depth(3)
coil(306, 246, 11, 5, coir)
coil(330, 250, 9, 4, indigo)
-- a woven palm basket of balls of dyed cord
local function basket(x, yb, w, h)
  local m = c:rrect(x - w, yb - h, x + w, yb, 2)
  F.shadow(x - w, x + w, yb + 1, 4, 2)
  rimOf(m, L.needle)
  m:each(function(xx, yy)
    local ck = ((xx - x + 20) // 2 + (yy - yb + 20) // 2) % 2 == 0
    local dark = (xx - x) / w + (yy - (yb - h)) / h > 1.1
    px(xx, yy, ck and (dark and L.needle.base or L.needle.hi) or (dark and L.needle.shade or L.needle.base))
  end)
  hline(x - w, x + w, yb - h, L.needle.hi) hline(x - w, x + w, yb - h + 1, L.needle.deep)
end
basket(286, 258, 8, 7)
for k, r in ipairs({ annatto, turmeric, indigo, L.teal }) do
  local bx = 280 + (k - 1) * 4
  local b = c:ellipse(bx, 249 - (k % 2), 2, 2) rimOf(b, r) fill(b, r.base) px(bx - 1, 248 - (k % 2), r.hi) px(bx + 1, 250 - (k % 2), r.shade)
end
-- folded bark cloth, patterned edges showing
F.shadow(340, 366, 263, 5, 2)
tapaStack(340, 366, 262, 3)
F.heliconia(372, 248, 20, 54)
F.puddle(352, 236, 6, 9)
-- ferns, heliconia, big leaves, mushrooms (keep clear of the compass corner x>=380, y>=230)
for _, f in ipairs({ { 264, 262, 7 }, { 276, 266, 8 }, { 132, 262, 7 }, { 22, 264, 8 }, { 300, 214, 5 }, { 456, 226, 6 }, { 214, 214, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.heliconia(124, 266, 22, 51)
F.bigLeaf(376, 262, 14, -pi * .7, L.foliage, 52, 6, { heart = true, stem = { 378, 268 } })
F.bigLeaf(372, 266, 12, -pi * .9, L.leaf, 53, 5, { heart = true, stem = { 376, 269 } })
F.mushroom(140, 258, annatto, true) F.mushroom(145, 260, annatto) F.mushroom(296, 266, L.produce, true)
F.orchid(206, 232, L.orchid, 2)

---------------------------------------------------------------- the carrier: a gnome bringing a big rope coil along the road
local _, cx1, cy1 = F.gnome(276, 214, { hat = L.roof2, coat = turmeric, arm = "up" })
local rc = c:ellipse(cx1 - 3, cy1 + 6, 7, 5):cut(c:ellipse(cx1 - 3, cy1 + 6, 4, 2))
rimOf(rc, coir) fill(rc, coir.base)
rc:each(function(x, y) if y < cy1 + 4 then px(x, y, coir.hi) elseif (x - y * 2) % 3 == 0 then px(x, y, coir.deep) elseif y > cy1 + 8 then px(x, y, coir.shade) end end)
-- a slit drum by the road (left): a hollowed log, its slot, carved ends, two beaters
F.depth(3)
local drum = log(174, 200, 256, 6, L.redbark)
fill(rect(179, 251, 193, 252), L.soil.edge) hline(179, 193, 253, L.redbark.hi)
chipBand(178, 194, 255, 258)
F.moss(drum, .06, 55)
for _, b in ipairs({ { 184, 249, 192, 240 }, { 188, 249, 198, 242 } }) do
  line({ { b[1], b[2] }, { b[3], b[4] } }):each(function(x, y) px(x, y, L.board.base) end)
  local kb = c:ellipse(b[3], b[4], 1, 1) rimOf(kb, L.timber) fill(kb, coir.base)
end
-- a hummingbird at the heliconia, butterflies
F.sprite({ "...gg.", "kkGGg.", "...GGb", "..gGg.", "...g.." }, 128, 236, { g = L.teal.shade, G = L.teal.base, k = L.timber.edge, b = annatto.base })
for _, b in ipairs({ { 230, 196 }, { 320, 228 }, { 66, 156 } }) do
  F.sprite({ "YY.YY", "yYkYy", ".y.y." }, b[1], b[2], { Y = turmeric.hi, y = turmeric.shade, k = L.timber.edge }, { rim = false })
end
F.depth(0)
F.birds({ { 330, 34, 2, "#3a6ad0" }, { 344, 40, 1, "#3a6ad0" }, { 150, 44, 2, "#c8902a" }, { 168, 50, 1, "#2e7a46" } })
F.finish()
