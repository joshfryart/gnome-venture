-- shrine.lua : "Wayside shrine" stop look, FOREST (forest_pinewood), 480x270 gate view.
-- Same composition as the Maplewold shrine (art-2701-batch3/stops/opus3/shrine.lua), re-cast for an old spruce wood:
-- road's end: a timber shrine hall with a steep mossy shingle roof and crossed ridge boards on a mossy stone terrace,
-- candles burning along the terrace and inside, between two old spruces. Over the road: a gate of red-bark pine logs
-- with a shingle cap. Back left: a three-tier stave tower with bark-shingle roofs. Right back: the roped sacred
-- spruce hung with ribbons (a tawny owl in it) and the bell frame. Left hero: the spring basin pavilion fed by a
-- hollow-log spout from a mossy rock. Right hero: the offering rack of carved plaques and ribbons. Bottom left: a
-- raked gravel garden edged in moss. Paired mossy stone lanterns, a censer, birches and ferns, ravens on the gate.
-- Quirk (kept): a real fox kit sits on the plinth beside the stone fox, wearing its red bib.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-forest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "shrine", out = DIR, farTrees = { 24, 150, 300, 318, 352, 440 }, treeLineGap = { 180, 300 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local RED, BARK, SH, SH2 = L.awnA, L.redbark, L.roof, L.roof2
local BRONZE = F.rp("#dcb878 #ae8a50 #82663c #5c482e #3a2e24")
local ROPE = F.rp("#ecd890 #ccb066 #a48848 #765e36 #4c3c26")
local RIB = { L.awnA, L.awnB, L.accent, L.gold, L.lav, L.petal }

-- warm candle-light spill: tint what is already there toward the glow (hard pixels, no alpha)
local function glowSpill(cx, cy, r, k)
  for y = cy - r, cy + r do for x = cx - r, cx + r do
    local d = math.sqrt((x - cx) ^ 2 + ((y - cy) * 1.4) ^ 2)
    if d <= r then local v = c:get(x, y) if v then px(x, y, F.mix(v, L.glow.hi, k * (1 - d / (r + 1)) + .04)) end end
  end end
end
local function candle(x, yb, tall)
  local h = tall or 3
  vline(x, yb - h + 1, yb, L.awnB.hi) px(x + 1, yb - h + 2, L.awnB.shade) vline(x + 1, yb - h + 2, yb, L.awnB.shade)
  px(x, yb - h, L.glow.base) px(x, yb - h - 1, L.glow.hi)
end
-- a ribbon strip fluttering down from (x,y)
local function ribbon(x, y, len, r, dir)
  dir = dir or 1
  for k = 0, len do
    local xx = x + ((k > len // 2) and dir or 0)
    px(xx, y + k, k == 0 and r.hi or r.base) px(xx + 1, y + k, k == len and r.deep or r.shade)
  end
end
-- a cord sagging from a to b with little cloth strips
local function garland(x0, y0, x1, y1, sag, every, len)
  local function ly(xx) local t = (xx - x0) / (x1 - x0) return floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + .5) end
  for xx = x0, x1 do px(xx, ly(xx), ROPE.deep) end
  local i = 0
  for xx = x0 + 3, x1 - 3, every do
    i = i + 1
    local r = RIB[i % #RIB + 1]
    local yy = ly(xx) + 1
    for k = 0, len - 1 do px(xx, yy + k, k == 0 and r.hi or r.base) px(xx + 1, yy + k, r.shade) end
    px(xx + (i % 2), yy + len, r.deep)
  end
end

-- flared shingle roof: eave from x0..x1 at y (bottom), ridge from rx0..rx1 at yt; tips curl up
local function flare(x0, x1, y, rx0, rx1, yt, r, mk, seed)
  local m = poly{ { x0 - 2, y - 3 }, { x0 + 4, y - 1 }, { rx0, yt }, { rx1, yt }, { x1 - 4, y - 1 }, { x1 + 2, y - 3 }, { x1 - 2, y + 2 }, { x0 + 2, y + 2 } }
  rimOf(m, r) part(m, r, { sep = true })
  m:each(function(x, yy)
    if yy < y then
      local row, ry = (yy - yt) // 3, (yy - yt) % 3
      if ry == 2 then px(x, yy, r.deep)
      elseif (x + row * 3) % 5 == 0 then px(x, yy, r.shade)
      elseif ry == 0 and hash(x, yy, 83) < .3 then px(x, yy, r.hi) end
    end
  end)
  F.moss(m, mk or .12, seed or 81)
  hline(rx0, rx1, yt, r.hi)
  hline(x0 + 2, x1 - 2, y + 2, r.deep) hline(x0 + 2, x1 - 2, y + 1, r.shade)
  return m
end

---------------------------------------------------------------- low mist lying in the clearing behind the shrine
F.depth(1)
for y = 115, 128 do for x = 0, 479 do
  local v = hash(x // 13, y // 2, 88)
  if v < .42 - (y - 115) * .03 and (y % 2 == 0 or hash(x, y, 89) < .45) then px(x, y, (y % 3 == 0) and L.mist2 or L.mist) end
end end

---------------------------------------------------------------- back-left: three-tier stave tower
local function stave(cx, yb)
  F.shadow(cx - 16, cx + 16, yb, 8, 3)
  local base = rect(cx - 18, yb - 4, cx + 18, yb)
  rimOf(base, L.stone) part(base, L.stone) F.courses(base, yb - 4, 5, 8, L.stone) F.moss(base, .3, 84)
  local y = yb - 4
  for i = 0, 2 do
    local w = 13 - i * 3
    local body = rect(cx - w, y - 11, cx + w, y)
    rimOf(body, L.timber) part(body, L.timber) F.planks(body, L.timber, 3, true, 20 + i)
    hline(cx - w, cx + w, y - 11, L.timber.edge) hline(cx - w, cx + w, y - 10, L.timber.deep)
    F.window(cx - 1, y - 8, cx + 1, y - 5, L.timber, true)
    y = y - 11
    flare(cx - w - 9, cx + w + 9, y, cx - w + 1, cx + w - 1, y - 7, SH2, .14, 85 + i)
    -- carved dragon-head tips curling off the eaves
    px(cx - w - 11, y - 5, BARK.deep) px(cx - w - 12, y - 6, BARK.base) px(cx + w + 11, y - 5, BARK.deep) px(cx + w + 12, y - 6, BARK.base)
    y = y - 7
  end
  local spire = rect(cx - 1, y - 16, cx, y)
  rimOf(spire, SH2) part(spire, SH2, { nopop = true, noshade = true })
  for k = 0, 3 do hline(cx - 2, cx + 1, y - 4 - k * 3, SH2.shade) end
  px(cx, y - 17, L.gold.hi) px(cx - 1, y - 17, L.gold.base)
end
F.tree(86, 128, 52, 4)
F.tree(16 + 6, 132, 34, 1)
stave(48, 134)
-- a small stacked-stone cairn by the tower
local function cairn(x, yb, s)
  local y = yb
  for k = 0, s - 1 do
    local w, h = floor((s - k) * 1.6) + 1, 2 + (s - k) // 2
    local m = c:ellipse(x + (k % 2), y - h // 2 - 1, w, math.max(1, h // 2))
    rimOf(m, L.stone) part(m, L.stone, { nopop = true })
    px(x + (k % 2) - w // 2, y - h + 1, L.stone.hi)
    if k == 0 or hash(k, x, 86) < .5 then px(x + (k % 2), y - h, L.moss.base) end
    y = y - h
  end
end
cairn(76, 136, 5)

---------------------------------------------------------------- the road's end: terrace, steps, shrine hall between two old spruces
F.depth(2)
F.tree(182, 128, 74, 2)
F.tree(300, 128, 66, 0)
local terr = poly{ { 188, 126 }, { 292, 126 }, { 288, 112 }, { 192, 112 } }
F.shadow(190, 292, 128, 8, 3)
rimOf(terr, L.stone) part(terr, L.stone) F.courses(terr, 112, 5, 12, L.stone) F.moss(terr, .2, 87)
for k = 0, 4 do
  local y = 124 - k * 3
  local m = rect(228 + k, y, 252 - k, y + 2)
  fill(m, L.road.base) hline(228 + k, 252 - k, y, L.road.hi) hline(228 + k, 252 - k, y + 2, L.road.deep)
  for x = 229 + k, 251 - k do if hash(x, y, 88) < .12 then px(x, y + 1, L.moss.base) end end
end
-- hall: weathered timber boards between red-bark posts
local hall = rect(204, 92, 276, 112)
rimOf(hall, L.timber) part(hall, L.timber) F.planks(hall, L.timber, 3, false, 21)
for _, x in ipairs({ 204, 216, 228, 252, 264, 274 }) do fill(rect(x, 92, x + 2, 112), BARK.base) vline(x, 92, 112, BARK.hi) vline(x + 2, 92, 112, BARK.shade) end
for _, d in ipairs({ { 218, 226 }, { 254, 262 } }) do
  local m = rect(d[1], 96, d[2], 110) fill(m, L.board.base)
  m:each(function(x, y) if (x - d[1]) % 3 == 0 or (y - 96) % 3 == 0 then px(x, y, L.board.deep) end end)
end
-- open middle bay: a candle-lit altar with a small carved spruce figure
fill(rect(231, 96, 249, 112), L.soil.deep)
fill(rect(234, 100, 246, 110), L.soil.shade)
fill(rect(236, 101, 244, 108), L.glow.deep) fill(rect(238, 102, 242, 106), L.glow.shade)
F.sprite({ "..g..", ".ggg.", "ggggg", ".ggg.", "ggggg", "..t.." }, 238, 101, { g = L.foliage.shade, t = L.timber.base }, { rim = false })
for _, x in ipairs({ 233, 235, 245, 247 }) do candle(x, 105 + (x % 3), 3) end
glowSpill(240, 104, 7, .35)
-- offering box + tray of berries and cones
local box = rect(232, 106, 248, 112) rimOf(box, L.timber) part(box, L.timber) for x = 234, 246, 3 do px(x, 107, L.timber.deep) end
-- big flared roof of mossy cedar shingle
flare(188, 292, 90, 214, 266, 66, SH, .2, 89)
local ridge = rect(212, 62, 268, 66) rimOf(ridge, SH) part(ridge, SH, { nopop = true }) hline(212, 268, 62, SH.hi) F.moss(ridge, .25, 90)
-- crossed ridge boards (chigi) at both ends
for _, e in ipairs({ { 210, 1 }, { 270, -1 } }) do
  local m = line({ { e[1] - 4 * e[2], 54 }, { e[1] + 3 * e[2], 66 } }, 2):add(line({ { e[1] + 4 * e[2], 54 }, { e[1] - 3 * e[2], 66 } }, 2))
  rimOf(m, L.timber) part(m, L.timber, { nopop = true, noshade = true })
end
local gab = poly{ { 228, 88 }, { 240, 72 }, { 252, 88 } } fill(gab, L.board.base) c:edgeIn(gab, L.board.deep)
F.planks(gab, L.board, 3, true, 22)
local sun = c:ellipse(240, 82, 2, 2) fill(sun, L.gold.base) px(239, 81, L.gold.hi) px(241, 83, L.gold.shade)
for _, d in ipairs({ { -4, 0 }, { 4, 0 }, { 0, -4 } }) do px(240 + d[1], 82 + d[2], L.gold.shade) end
vline(240, 91, 104, RED.base) vline(241, 91, 104, L.awnB.base)
local bell = c:ellipse(240, 93, 2, 2) fill(bell, BRONZE.base) px(239, 92, BRONZE.hi) px(241, 94, BRONZE.deep)
-- straw rope across the front with paper zigzags and cloth ribbons
for x = 206, 274 do
  local yy = 94 + floor(2 * sin((x - 206) / 68 * pi))
  px(x, yy, ROPE.shade) px(x, yy + 1, (x % 3 == 0) and ROPE.hi or ROPE.base)
end
for i, x in ipairs({ 210, 214, 222, 226, 254, 258, 266, 270 }) do
  local y = 97 + floor(2 * sin((x - 206) / 68 * pi))
  if i % 2 == 0 then fill(line({ { x, y }, { x + 2, y + 2 }, { x, y + 4 }, { x + 2, y + 6 } }), L.awnB.hi)
  else ribbon(x, y, 5, RIB[i % #RIB + 1]) end
end
-- candles along the foot of the terrace, either side of the steps
for x = 212, 225, 3 do candle(x, 129 - (x % 2), 2 + (x % 3)) end
for x = 256, 269, 3 do candle(x, 129 - (x % 2), 2 + (x % 3)) end
glowSpill(218, 127, 6, .3) glowSpill(262, 127, 6, .3)
-- offering bowls on the terrace corners: berries and pine cones
for _, b in ipairs({ { 196, 123, L.apple }, { 284, 123, L.soil } }) do
  local m = rect(b[1] - 3, b[2] - 1, b[1] + 3, b[2] + 1)
  rimOf(m, L.timber) part(m, L.board, { nopop = true })
  hline(b[1] - 2, b[1] + 2, b[2] - 2, b[3].base) px(b[1] - 1, b[2] - 3, b[3].hi) px(b[1] + 1, b[2] - 3, b[3].base) px(b[1] + 2, b[2] - 2, b[3].shade)
end

---------------------------------------------------------------- right back: the sacred spruce + bell frame
local function sacredTree()
  F.shadow(392, 434, 162, 10, 4)
  -- thick old trunk with flared roots: drawn under the boughs, then its lower part again over the conifer's own trunk
  local trunk = poly{ { 396, 162 }, { 402, 156 }, { 403, 134 }, { 405, 108 }, { 413, 108 }, { 415, 134 }, { 416, 156 }, { 424, 162 } }
  local function paintTrunk(m, again)
    if again then
      m:each(function(x, y) px(x, y, (not trunk:has(x - 1, y) or not trunk:has(x + 1, y)) and L.timber.edge or (x > 411 and L.timber.shade or L.timber.base)) end)
    else rimOf(m, L.timber) part(m, L.timber) end
    m:each(function(x, y)
      if again and (not trunk:has(x - 1, y) or not trunk:has(x + 1, y)) then return end
      if hash(x, y // 3, 34) < .22 then px(x, y, L.timber.deep) elseif x < 406 and hash(x, y // 2, 35) < .4 then px(x, y, L.timber.hi) end
      if y > 150 and hash(x // 2, y, 36) < .35 then px(x, y, hash(x, y, 37) < .5 and L.moss.base or L.moss.shade) end
    end)
  end
  paintTrunk(trunk)
  local crownM = F.conifer(410, 146, 120, L.foliage2, 33, { w = 44 })
  paintTrunk(trunk:copy():cut(crownM), true)
  -- roped trunk with zigzags
  for x = 402, 416 do px(x, 136 + (x - 402) // 6, ROPE.shade) px(x, 137 + (x - 402) // 6, (x % 3 == 0) and ROPE.hi or ROPE.base) px(x, 138 + (x - 402) // 6, ROPE.deep) end
  for _, x in ipairs({ 405, 412 }) do local y = 139 + (x - 402) // 6 fill(line({ { x, y }, { x + 2, y + 2 }, { x, y + 4 }, { x + 2, y + 6 } }), L.awnB.hi) end
  -- ribbons tied on the low boughs
  for i, p in ipairs({ { 380, 120 }, { 392, 112 }, { 432, 114 }, { 442, 122 }, { 372, 128 }, { 448, 128 }, { 422, 100 }, { 396, 94 }, { 386, 104 }, { 436, 104 } }) do
    ribbon(p[1], p[2], 5 + i % 3, RIB[i % #RIB + 1], (i % 2 == 0) and 1 or -1)
  end
  -- a tawny owl on a bough
  F.sprite({
    ".o...o.",
    ".ooooo.",
    "oYoboYo",
    "ooobooo",
    "oOoOoOo",
    ".OoOoO.",
    ".OOOOO.",
    "..k.k..",
  }, 418, 80, { o = L.needle.shade, Y = L.gold.hi, b = L.gold.shade, O = L.needle.base, k = L.gold.deep })
end
local function bellFrame(x0, yb)
  local posts = rect(x0, yb - 34, x0 + 2, yb):add(rect(x0 + 30, yb - 34, x0 + 32, yb))
  local roofm = poly{ { x0 - 8, yb - 34 }, { x0 + 4, yb - 44 }, { x0 + 28, yb - 44 }, { x0 + 40, yb - 34 }, { x0 + 38, yb - 31 }, { x0 - 6, yb - 31 } }
  local bm = poly{ { x0 + 11, yb - 28 }, { x0 + 21, yb - 28 }, { x0 + 23, yb - 12 }, { x0 + 9, yb - 12 } }:add(c:rrect(x0 + 11, yb - 31, x0 + 21, yb - 25, 3))
  F.shadow(x0, x0 + 34, yb, 8, 3)
  rimOf(union(posts, roofm, bm), L.timber)
  part(posts, BARK, { nopop = true })
  part(roofm, SH) F.courses(roofm, yb - 44, 3, 5, SH) F.moss(roofm, .2, 91) hline(x0 - 6, x0 + 38, yb - 31, SH.deep)
  part(bm, BRONZE)
  hline(x0 + 10, x0 + 22, yb - 20, BRONZE.deep) hline(x0 + 9, x0 + 23, yb - 13, BRONZE.deep)
  for y = yb - 27, yb - 22, 2 do for x = x0 + 13, x0 + 19, 2 do px(x, y, BRONZE.hi) end end
  bm:each(function(x, y) if y > yb - 20 and hash(x, y, 92) < .12 then px(x, y, L.accent.shade) end end) -- verdigris
  local log = rect(x0 + 24, yb - 22, x0 + 38, yb - 19) rimOf(log, L.timber) part(log, L.board, { nopop = true }) F.logEnd(x0 + 38, yb - 21, 2)
  vline(x0 + 27, yb - 31, yb - 23, L.timber.edge) vline(x0 + 35, yb - 31, yb - 23, L.timber.edge)
end
sacredTree()
bellFrame(300, 140)
garland(334, 107, 398, 118, 3, 6, 4)
local _, rx, ry = F.gnome(352, 142, { hat = L.lav, coat = SH2, arm = "up", flip = true })
line({ { rx, ry }, { 337, 121 } }):each(function(x, y) px(x, y, L.timber.edge) end)

---------------------------------------------------------------- the log gate over the road
local function gateLogs()
  local postL, postR = rect(204, 122, 209, 198), rect(271, 122, 276, 198)
  local kasagi = poly{ { 184, 110 }, { 194, 114 }, { 286, 114 }, { 296, 110 }, { 294, 118 }, { 186, 118 } }
  local shimaki = rect(192, 119, 288, 122)
  local nuki = rect(198, 132, 282, 136)
  local plaque = rect(234, 122, 246, 131)
  local feet = rect(202, 196, 211, 199):add(rect(269, 196, 278, 199))
  F.shadow(204, 280, 199, 10, 4)
  local sil = union(postL, postR, kasagi, shimaki, nuki, plaque, feet)
  rimOf(sil, BARK)
  for _, p in ipairs({ { postL, 204 }, { postR, 271 } }) do
    part(p[1], BARK)
    p[1]:each(function(x, y)
      local k = x - p[2]
      if k == 1 then px(x, y, BARK.hi) elseif k == 5 then px(x, y, BARK.shade)
      elseif hash(x, y // 4, 93) < .18 then px(x, y, BARK.shade) elseif hash(x, y // 3, 94) < .08 then px(x, y, BARK.hi) end
      if y > 180 and hash(x, y // 2, 95) < .3 + (y - 180) * .03 then px(x, y, hash(x, y, 96) < .5 and L.moss.base or L.moss.shade) end
    end)
  end
  part(nuki, L.timber, { nopop = true }) F.logs(nuki, L.timber, 132, 5)
  F.logEnd(198, 134, 2) F.logEnd(282, 134, 2)
  part(shimaki, L.timber, { nopop = true }) hline(192, 288, 119, L.timber.hi)
  part(kasagi, SH, { nopop = true }) F.courses(kasagi, 110, 3, 5, SH) F.moss(kasagi, .3, 97)
  hline(194, 286, 114, SH.hi) hline(186, 294, 117, SH.deep) hline(186, 294, 118, L.timber.deep)
  part(feet, L.stone, { nopop = true }) F.moss(feet, .4, 98)
  part(plaque, L.board) c:edgeIn(plaque, L.timber.base)
  F.sprite({ "..g..", ".ggg.", "ggggg", "..t.." }, 238, 124, { g = L.foliage.deep, t = L.timber.deep }, { rim = false })
  -- ribbons tied around the posts
  for i, p in ipairs({ { 204, 150 }, { 209, 162 }, { 271, 154 }, { 276, 166 } }) do
    local r = RIB[i % #RIB + 1]
    hline(p[1] - (p[1] % 2 == 0 and 0 or 5), p[1] + (p[1] % 2 == 0 and 5 or 0), p[2], r.base)
    ribbon(p[1] + (i % 2 == 0 and 1 or -1), p[2] + 1, 6, r, i % 2 == 0 and 1 or -1)
  end
end

---------------------------------------------------------------- mossy stone lantern, scaled by depth, candle-lit
local function toro(x, yb, s)
  local function R(a, b, cc, d) return rect(floor(x + a * s), floor(yb + b * s), floor(x + cc * s), floor(yb + d * s)) end
  local base = R(-5, -3, 5, 0)
  local post = R(-2, -14, 2, -3)
  local fire = R(-5, -21, 5, -14)
  local cap = poly{ { x - 8 * s, yb - 21 * s }, { x - 3 * s, yb - 26 * s }, { x + 3 * s, yb - 26 * s }, { x + 8 * s, yb - 21 * s }, { x + 7 * s, yb - 20 * s }, { x - 7 * s, yb - 20 * s } }
  local knob = R(-1, -29, 1, -26)
  F.shadow(floor(x - 4 * s), floor(x + 5 * s), yb, floor(5 * s), floor(2 * s))
  rimOf(union(base, post, fire, cap, knob), L.stone)
  part(base, L.stone) part(post, L.stone, { nopop = true }) part(fire, L.stone, { sep = true })
  local win = R(-2, -19, 2, -16) fill(win, L.glow.base) px(floor(x - 2 * s), floor(yb - 19 * s), L.glow.hi)
  win:each(function(xx, y) if not win:has(xx + 1, y) or not win:has(xx, y + 1) then px(xx, y, L.glow.shade) end end)
  part(cap, L.stone, { sep = true }) part(knob, L.stone, { nopop = true })
  cap:each(function(xx, y) if hash(xx, y, 61) < .4 then px(xx, y, hash(xx, y, 62) < .4 and L.moss.hi or L.moss.base) end end)
  base:each(function(xx, y) if hash(xx, y, 63) < .3 then px(xx, y, L.moss.shade) end end)
end

---------------------------------------------------------------- left hero: spring basin pavilion
local function chozuya()
  local x0, x1, yt, yb = 96, 184, 150, 214
  local posts = rect(x0 + 6, yt + 8, x0 + 9, yb):add(rect(x1 - 9, yt + 8, x1 - 6, yb))
  F.shadow(x0 + 6, x1, yb, 12, 5)
  rimOf(posts, BARK) part(posts, BARK, { nopop = true })
  posts:each(function(x, y) if hash(x, y // 3, 64) < .2 then px(x, y, BARK.shade) end if y > 204 and hash(x, y, 65) < .5 then px(x, y, L.moss.base) end end)
  flare(x0 - 6, x1 + 6, yt + 8, x0 + 16, x1 - 16, yt - 14, SH2, .16, 66)
  local rid = rect(x0 + 14, yt - 18, x1 - 14, yt - 14) rimOf(rid, SH2) part(rid, SH2, { nopop = true }) F.moss(rid, .3, 67)
  local tri = poly{ { 128, yt + 4 }, { 140, yt - 10 }, { 152, yt + 4 } } fill(tri, L.board.base) c:edgeIn(tri, L.board.deep)
  F.planks(tri, L.board, 3, true, 23)
  F.sprite({ ".k.k.", "kk.kk", ".kkk.", "..k.." }, 138, yt - 4, { k = L.timber.deep }, { rim = false }) -- carved antler mark
  -- mossy stone basin
  local front = rect(112, 190, 168, 208)
  local topm = poly{ { 108, 190 }, { 172, 190 }, { 168, 182 }, { 112, 182 } }
  rimOf(union(front, topm), L.stone)
  part(front, L.stone) F.courses(front, 190, 9, 14, L.stone, 3) F.moss(front, .16, 68)
  part(topm, L.stone, { sep = true }) F.moss(topm, .12, 69)
  local wat = poly{ { 114, 188 }, { 166, 188 }, { 163, 184 }, { 117, 184 } } F.water(wat, L.water, { step = 2 })
  -- floating birch leaves
  for _, k in ipairs({ { 124, 186 }, { 140, 187 }, { 156, 185 } }) do px(k[1], k[2], L.birchLeaf.hi) px(k[1] + 1, k[2], L.birchLeaf.base) end
  -- mossy rock spring with a hollow-log spout and a trickle
  F.moss(F.rock(178, 190, 9, 14), .6, 70)
  local sp = rect(148, 168, 176, 171)
  rimOf(sp, L.timber) part(sp, L.timber, { nopop = true }) hline(149, 175, 168, L.board.shade) hline(149, 175, 169, L.water.base)
  F.logEnd(148, 170, 2)
  F.moss(rect(160, 167, 176, 168), .4, 71)
  vline(148, 172, 184, L.water.hi) vline(149, 173, 184, L.water.base)
  px(147, 184, L.water.hi) px(151, 184, L.water.hi)
  -- prop stick under the spout
  vline(164, 172, 181, L.timber.base) vline(165, 172, 181, L.timber.deep)
  -- birch-bark ladles laid across
  for k = 0, 2 do
    local lx = 118 + k * 10
    fill(line({ { lx, 181 }, { lx + 10, 178 } }), L.birch.base)
    local cup = rect(lx - 2, 180, lx + 1, 183) fill(cup, L.birch.shade) px(lx - 2, 180, L.birch.hi) px(lx, 182, L.birch.edge)
  end
  -- a little frog on the basin rim
  F.sprite({ ".e..e.", "GGGGGG", "GgGGgG", "gg..gg" }, 160, 179, { e = L.gold.hi, G = L.leaf.base, g = L.leaf.deep })
end

---------------------------------------------------------------- right hero: offering rack of plaques and ribbons
local function emaRack()
  local x0, x1, yt, yb = 300, 384, 160, 214
  local posts = rect(x0, yt, x0 + 3, yb):add(rect(x1 - 3, yt, x1, yb))
  local roofm = poly{ { x0 - 6, yt }, { x0 + 4, yt - 8 }, { x1 - 4, yt - 8 }, { x1 + 6, yt }, { x1 + 4, yt + 3 }, { x0 - 4, yt + 3 } }
  local rails = rect(x0, 172, x1, 173):add(rect(x0, 190, x1, 191))
  F.shadow(x0, x1, yb, 12, 4)
  rimOf(union(posts, roofm, rails), L.timber)
  part(posts, BARK, { nopop = true }) part(rails, L.timber, { nopop = true, noshade = true })
  part(roofm, SH2) F.courses(roofm, yt - 8, 3, 5, SH2) F.moss(roofm, .18, 72) hline(x0 - 4, x1 + 4, yt + 3, SH2.deep)
  -- top row: little carved pentagon plaques; bottom row: cloth ribbons and a few plaques
  local cols = { L.awnA, L.accent, L.produce, L.lav, L.fern }
  for row = 0, 1 do
    local yy = row == 0 and 174 or 192
    for k = 0, 9 do
      local x = x0 + 5 + k * 8 + (row == 1 and 3 or 0)
      if x + 6 < x1 - 3 then
        if row == 1 and k % 3 ~= 1 then
          for j = 0, 2 do ribbon(x + j * 2, yy, 7 + (j + k) % 4, RIB[(k + j) % #RIB + 1]) end
        else
          local m = poly{ { x, yy + 2 }, { x + 3, yy }, { x + 6, yy + 2 }, { x + 6, yy + 9 }, { x, yy + 9 } }
          c:rim(m, L.board.edge) fill(m, L.board.hi) hline(x, x + 6, yy + 9, L.board.shade) vline(x + 6, yy + 2, yy + 9, L.board.base)
          local cr = cols[(k + row * 2) % 5 + 1]
          if k % 2 == 0 then -- a painted little spruce
            px(x + 3, yy + 3, cr.base) hline(x + 2, x + 4, yy + 5, cr.base) hline(x + 1, x + 5, yy + 7, cr.shade) px(x + 3, yy + 8, L.timber.base)
          else -- a scribbled wish
            px(x + 2, yy + 4, cr.base) px(x + 3, yy + 4, cr.base) px(x + 3, yy + 5, cr.shade) px(x + 2, yy + 6, cr.base) px(x + 4, yy + 7, cr.shade)
          end
          px(x + 3, yy + 1, RED.base)
        end
      end
    end
  end
end
local function fox(x, yb, flip, real, bare)
  local s = flip and -1 or 1
  local r = real and L.produce or L.stone
  local body = poly{ { x - 4 * s, yb }, { x - 4 * s, yb - 10 }, { x - 2 * s, yb - 14 }, { x + 3 * s, yb - 14 }, { x + 4 * s, yb } }
  local head = poly{ { x - 3 * s, yb - 14 }, { x - 3 * s, yb - 20 }, { x - 1 * s, yb - 18 }, { x + 2 * s, yb - 18 }, { x + 3 * s, yb - 21 }, { x + 4 * s, yb - 16 }, { x + 7 * s, yb - 15 }, { x + 3 * s, yb - 13 } }
  local tail = line({ { x - 4 * s, yb - 2 }, { x - 8 * s, yb - 6 }, { x - 7 * s, yb - 12 } }, 3)
  local m = union(body, head, tail)
  rimOf(m, r) part(m, r)
  px(x + 1 * s, yb - 16, r.edge) px(x + 7 * s, yb - 15, L.timber.edge)
  if not real then
    m:each(function(xx, y) if not m:has(xx, y - 1) and hash(xx, y, 74) < .6 then px(xx, y, L.moss.hi) elseif hash(xx // 2, y // 2, 75) < .12 then px(xx, y, L.moss.shade) end end)
    if not bare then local bib = poly{ { x - 3 * s, yb - 13 }, { x + 3 * s, yb - 13 }, { x, yb - 8 } } fill(bib, RED.base) px(x, yb - 12, RED.hi) end
  end
end
local function plinth(x, yb, w, h)
  local m = rect(x - w, yb - h, x + w, yb) rimOf(m, L.stone) part(m, L.stone) hline(x - w, x + w, yb - h, L.stone.hi) F.moss(m, .25, 76 + x)
end

---------------------------------------------------------------- raked gravel garden edged in moss (bottom-left)
local function gravel()
  local g = poly{ { 20, 230 }, { 150, 226 }, { 162, 264 }, { 20, 266 } }
  local edge = g:grow(3):cut(g)
  edge:each(function(x, y) local v = hash(x // 2, y // 2, 77) px(x, y, v < .4 and L.moss.base or (v < .7 and L.moss.shade or L.moss.hi)) end)
  g:each(function(x, y) px(x, y, L.road.hi) end)
  local rocks = { { 56, 246, 10 }, { 120, 248, 8 } }
  g:each(function(x, y)
    local best = 1e9
    for _, r in ipairs(rocks) do best = math.min(best, math.sqrt(((x - r[1]) / 1.6) ^ 2 + ((y - r[2])) ^ 2) - r[3] * .55) end
    if best < 14 then if floor(best) % 3 == 0 then px(x, y, L.road.base) end
    elseif (y + floor(sin(x / 20) * 1.5)) % 3 == 0 then px(x, y, L.road.base) end
    if hash(x, y, 78) < .015 then px(x, y, L.needle.base) end -- a few fallen needles on the gravel
  end)
  F.moss(F.rock(56, 250, 12, 12), .35, 79) F.moss(F.rock(120, 251, 9, 9), .35, 80) F.moss(F.rock(129, 252, 5, 5), .3, 81)
  -- moss creeping in from the edge
  g:each(function(x, y) if edge:has(x - 2, y) or edge:has(x, y + 2) or edge:has(x + 2, y) then if hash(x // 2, y, 82) < .45 then px(x, y, L.moss.base) end end end)
  for _, f in ipairs({ { 18, 232, 6 }, { 24, 228, 5 }, { 160, 228, 6 }, { 166, 262, 7 } }) do F.fern(f[1], f[2], f[3]) end
end

---------------------------------------------------------------- compose
F.depth(3)
-- bronze censer with a smoke curl (left middle), a mossy cairn beside it
do
  local legs = rect(54, 214, 55, 220):add(rect(66, 214, 67, 220))
  local bowl = c:rrect(50, 204, 71, 215, 4)
  local lid = poly{ { 53, 204 }, { 61, 196 }, { 68, 204 } }
  F.shadow(52, 70, 220, 6, 2)
  rimOf(union(legs, bowl, lid), L.timber)
  part(legs, BRONZE, { nopop = true }) part(bowl, BRONZE) part(lid, BRONZE, { sep = true })
  hline(50, 71, 208, BRONZE.deep) for x = 53, 68, 3 do px(x, 211, BRONZE.hi) end
  bowl:each(function(x, y) if y > 210 and hash(x, y, 83) < .15 then px(x, y, L.accent.shade) end end)
  F.smoke(61, 190, 7, -.3, 2)
  cairn(38, 222, 6)
end
chozuya()
emaRack()
for _, p in ipairs({ { 146, .5, 11 }, { 182, .7, 22 }, { 252, 1.3, 22 } }) do
  local y = p[1]
  toro(floor(F.xl(y)) - p[3], y, p[2])
  toro(floor(F.xr(y)) + p[3], y, p[2])
end
gateLogs()
plinth(194, 214, 7, 6) fox(194, 208, false)
plinth(291, 214, 14, 6) fox(283, 208, true, false, true)
-- quirk: a real fox kit poses on the plinth beside the stone fox, wearing its red bib (the stone fox's neck is bare)
F.sprite({
  ".o....o........",
  ".oO..Oo........",
  ".OOOOOO........",
  "OOOOOOOO.......",
  "OeOOOeOO.......",
  "OOwwwOOO.......",
  ".wwnwwO........",
  "..wwwO.....OO..",
  "..RRRRR...OOOO.",
  ".RRrRRRR..OOOO.",
  "..RRRRR...OOO..",
  "..OwwOO...OO...",
  "..OwwwOO..OO...",
  "..OwwwOOOOOO...",
  "..OwwwOOOOWW...",
  "..OOOOOOOWWW...",
  "..kk..kk.......",
}, 291, 191, { o = L.timber.edge, O = L.produce.base, e = L.timber.edge, w = L.awnB.hi, n = L.timber.edge, R = RED.base, r = RED.hi, W = L.awnB.base, k = L.timber.deep })
gravel()
-- birches and a young spruce at the right edge (replacing the bamboo)
F.conifer(424, 226, 34, L.foliage, 52)
F.birch(440, 228, 58, 53)
F.birch(455, 226, 70, 54)
for i = 0, 14 do local x, y = 420 + floor(hash(i, 1, 55) * 44), 214 + floor(hash(i, 2, 55) * 14)
  px(x, y, L.birchLeaf.hi) px(x + 1, y, L.birchLeaf.shade) end
for _, f in ipairs({ { 414, 230, 7 }, { 432, 230, 8 }, { 448, 229, 6 }, { 300, 224, 6 }, { 290, 232, 7 } }) do F.fern(f[1], f[2], f[3]) end
F.mushroom(404, 226, L.apple, true) F.mushroom(409, 228, L.apple)
-- moss mounds and a gnome sweeping fallen needles by the right lanterns
F.bush(406, 232, 14, 8, L.moss, 12)
local _, bx, by = F.gnome(348, 238, { hat = RED, coat = L.wall2, flip = true, arm = "hold" })
fill(line({ { bx + 1, by - 6 }, { bx - 6, by + 6 } }, 1), L.timber.base)
local broom = poly{ { bx - 11, by + 6 }, { bx - 3, by + 6 }, { bx - 4, by + 10 }, { bx - 12, by + 10 } }
rimOf(broom, ROPE) part(broom, ROPE, { nopop = true }) for x = bx - 11, bx - 4, 2 do vline(x, by + 7, by + 10, ROPE.deep) end
-- the heap of needles and cones he is sweeping up
for i = 0, 34 do local x, y = 314 + floor(hash(i, 1, 5) * 14), 240 + floor(hash(i, 2, 5) * 5) - (i % 3)
  local r = L.needle px(x, y, i % 3 == 0 and r.hi or r.base) px(x + 1, y, r.shade) end
for _, p in ipairs({ { 318, 238 }, { 325, 240 } }) do px(p[1], p[2], L.soil.base) px(p[1], p[2] + 1, L.soil.shade) px(p[1] + 1, p[2] + 1, L.soil.deep) end
-- a gnome tying a ribbon on the rack
local _, ex, ey = F.gnome(392, 214, { hat = L.fern, coat = L.lav, arm = "up", flip = true })
ribbon(ex, ey - 1, 7, L.awnA)
-- ravens on the gate cap and birds over the hall
F.depth(0)
F.sprite({ ".kk.", "kkkk", "kkkkk", ".y.." }, 196, 106, { k = "#3c3a44", y = L.gold.shade })
F.sprite({ "..kk", "kkkk", "kkkkk", ".y.y" }, 276, 106, { k = "#3c3a44", y = L.gold.shade })
F.birds({ { 330, 38, 2 }, { 342, 44, 1 }, { 150, 52, 2 }, { 160, 46, 1 } })
F.depth(3)
-- fallen cones and yellow birch leaves scattered around
for i = 0, 50 do
  local x, y = 20 + floor(hash(i, 1, 77) * 440), 130 + floor(hash(i, 2, 77) * 130)
  if not (x > 378 and y > 228) then
    if i % 3 == 0 then px(x, y, L.soil.base) px(x, y + 1, L.soil.deep) px(x - 1, y, L.soil.hi)
    else px(x, y, L.birchLeaf.base) px(x + 1, y, L.birchLeaf.shade) end
  end
end
F.finish()
