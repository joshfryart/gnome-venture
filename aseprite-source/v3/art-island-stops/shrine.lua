-- shrine.lua : "Wayside shrine" stop look, ISLAND (island_palm), 480x270 gate view.
-- Same composition as the Maplewold shrine (art-2701-batch3/stops/opus3/shrine.lua), re-cast for a coral island:
-- road's end: a small shrine hall of cream coral stone between black lava posts, on a lava-block platform, under a
-- steep palm-thatch roof with a bound ridge roll and frond horns, hung with flower leis; candles, a pink conch on
-- the altar, shell and coconut offerings on the platform, between two leaning coconut palms. Over the road: a gate
-- of silver driftwood posts lashed with sennit rope, a bamboo tie beam, a thatched cap and a shell plaque, draped in
-- leis. Back left: a three-tier keeper tower (lava, coral, bamboo) under thatch, a conch finial. Right back: the
-- sacred banyan with hanging aerial roots, roped and hung with leis (a lory in it), and the drum frame: a carved
-- slit-log drum and a conch horn under thatch, struck by a gnome. Left hero: a giant-clam basin on a lava pedestal
-- fed by a bamboo spout, under thatch (a gecko on the rim). Right hero: an offering rack of painted shell plaques
-- and hanging shell strings. Bottom left: a raked white coral-sand garden with lava rocks. Bamboo torches line the
-- road; frangipani at the right edge; fairy terns on the gate.
-- Quirk (kept): the stone turtle guardian on the right has lost its hibiscus lei: a real turtle hatchling sits
-- beside it on the plinth wearing the lei and a little red gnome hat.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-island-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "shrine", out = DIR, farTrees = { 24, 150, 330, 352, 440 },
  treeLineGap = { 176, 304 }, volcanoX = 138, volcanoTop = 62 }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local TH, LAVA, CS, DW = L.roof, L.lava, L.stone, L.timber
local ROPE = L.rope
local LEI = { L.awnA, L.hibiscus, L.petal, L.gold, L.shell, L.hibiscus }

-- warm light spill: tint what is already there toward the glow (hard pixels, no alpha)
local function glowSpill(cx, cy, r, k)
  for y = cy - r, cy + r do for x = cx - r, cx + r do
    local d = math.sqrt((x - cx) ^ 2 + ((y - cy) * 1.4) ^ 2)
    if d <= r then local v = c:get(x, y) if v then px(x, y, F.mix(v, L.glow.hi, k * (1 - d / (r + 1)) + .04)) end end
  end end
end
local function candle(x, yb, tall)
  local h = tall or 3
  vline(x, yb - h + 1, yb, L.awnB.hi) vline(x + 1, yb - h + 2, yb, L.awnB.shade)
  px(x, yb - h, L.glow.base) px(x, yb - h - 1, L.glow.hi)
end
-- a flower lei sagging from (x0,y0) to (x1,y1): runs of blossoms in hibiscus red / orange / plumeria pink / gold /
-- cream, a dark underside, leaf tips peeping out
local function lei(x0, y0, x1, y1, sag, seed, cols)
  cols = cols or LEI
  local function ly(xx) local t = (xx - x0) / math.max(1, x1 - x0) return floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + .5) end
  for xx = x0, x1 do
    local yy = ly(xx)
    local seg = (xx - x0) // 3
    local r = cols[floor(hash(seg, seed, 3) * #cols) + 1]
    local k = (xx - x0) % 3
    px(xx, yy - 1, k == 1 and r.hi or (k == 0 and r.base or r.shade))
    px(xx, yy, k == 0 and r.hi or (k == 1 and r.base or r.shade))
    px(xx, yy + 1, k == 2 and r.deep or r.shade)
    if k == 1 and hash(seg, seed, 4) < .3 then px(xx, yy, L.gold.hi) end
    if hash(xx, seed, 5) < .14 then px(xx, yy + 2, L.foliage.shade) end
  end
  return ly
end
-- a lei hanging straight down from (x, y)
local function leiDrop(x, y, len, seed)
  for k = 0, len do
    local r = LEI[floor(hash(k // 2, seed, 6) * #LEI) + 1]
    px(x, y + k, (k % 2 == 0) and r.hi or r.base) px(x + 1, y + k, (k % 2 == 0) and r.base or r.shade)
  end
  px(x, y + len + 1, L.foliage.base) px(x + 1, y + len + 1, L.foliage.shade)
end
-- a string of little shells hanging from (x, y)
local function shellString(x, y, len, seed)
  for k = 0, len do px(x, y + k, ROPE.shade) end
  for k = 2, len, 3 do
    local kind = hash(k, seed, 7)
    if kind < .4 then px(x - 1, y + k, L.shell.hi) px(x + 1, y + k, L.shell.shade) px(x, y + k, L.shell.base)
    elseif kind < .7 then px(x - 1, y + k, L.coral.hi) px(x + 1, y + k, L.coral.shade) px(x, y + k + 1, L.coral.deep)
    else px(x, y + k, L.coconut.hi) px(x + 1, y + k, L.coconut.base) end
  end
end
-- a conch shell (spire left, pink lip right), ~10x6 (big) or ~6x4
local function conch(x, y, big, flip)
  local s = flip and -1 or 1
  local rows = big and { "..sSS.....", ".sSSSSSs..", "sSSShSSSpP", ".hSShhSpPp", "..hhhdpPp.", "....dd...." }
    or { ".sSS..", "sSSSpP", ".hhdPp", "..dd.." }
  local map = { s = L.shell.hi, S = L.shell.base, h = L.shell.shade, d = L.shell.deep, p = L.petal.base, P = L.petal.hi }
  local w = #rows[1]
  local m = HP.mask()
  for j, row in ipairs(rows) do for i = 1, #row do if map[row:sub(i, i)] then m:set(x + (i - 1 - w // 2) * s, y + j - 1) end end end
  c:rim(m, L.shell.edge)
  for j, row in ipairs(rows) do for i = 1, #row do local col = map[row:sub(i, i)] if col then px(x + (i - 1 - w // 2) * s, y + j - 1, col) end end end
  return m
end
-- a woven pandanus mat over a mask: two-tone basket weave
local function weave(m, a, b)
  m:each(function(x, y)
    local wv = ((x // 2 + y // 2) % 2 == 0)
    px(x, y, wv and (((x + y) % 2 == 0) and a.hi or a.base) or (((x + y) % 2 == 0) and b.base or b.shade))
  end)
end
-- a palm-thatch roof: straight hips (no curled tips), thick combed courses, a ragged fringe hanging under the eave
local function thatchRoof(x0, x1, y, rx0, rx1, yt, r, seed)
  local m = poly{ { x0, y }, { rx0, yt }, { rx1, yt }, { x1, y }, { x1 - 1, y + 2 }, { x0 + 1, y + 2 } }
  rimOf(m, r) part(m, r, { sep = true })
  F.thatch(m, r, yt, (rx0 + rx1) // 2)
  m:each(function(x, yy)
    if yy < y and hash(x, yy // 2, seed) < .07 then px(x, yy, r.hi) end
    -- lit left hip, shaded right hip
    local cx = (rx0 + rx1) / 2
    if x < rx0 and (rx0 - x) > (yy - yt) * (rx0 - x0) / math.max(1, y - yt) - 2 and hash(x, yy, seed + 1) < .5 then px(x, yy, r.hi) end
    if x > rx1 + 1 and hash(x, yy, seed + 2) < .35 then px(x, yy, r.deep) end
  end)
  hline(rx0, rx1, yt, r.hi)
  hline(x0 + 1, x1 - 1, y + 2, r.edge) hline(x0 + 1, x1 - 1, y + 1, r.deep)
  for x = x0 + 1, x1 - 1 do
    local n = floor(hash(x, seed, 7) * 3)
    for k = 0, n do px(x, y + 3 + k, k == n and r.edge or r.deep) end
  end
  return m
end
-- a bound ridge roll on top of a thatch roof
local function ridgeRoll(x0, x1, y0, y1, r)
  local m = rect(x0, y0, x1, y1)
  rimOf(m, r) part(m, r, { nopop = true })
  hline(x0, x1, y0, r.hi)
  for x = x0 + 3, x1 - 2, 6 do vline(x, y0, y1, ROPE.base) vline(x + 1, y0, y1, ROPE.shade) px(x, y0, ROPE.hi) end
  return m
end

---------------------------------------------------------------- back-left: three-tier keeper tower under thatch
local function tower(cx, yb)
  F.shadow(cx - 16, cx + 16, yb, 8, 3)
  local base = rect(cx - 18, yb - 4, cx + 18, yb)
  rimOf(base, LAVA) part(base, LAVA) F.courses(base, yb - 4, 5, 8, LAVA)
  local y = yb - 4
  for i = 0, 2 do
    local w = 13 - i * 3
    local body = rect(cx - w, y - 11, cx + w, y)
    if i == 0 then
      rimOf(body, CS) part(body, CS) F.courses(body, y - 11, 4, 7, CS)
      body:each(function(x, yy) if hash(x // 4, yy // 4, 21) < .12 and (yy - y) % 4 ~= 0 then px(x, yy, LAVA.base) end end)
    else
      rimOf(body, L.board) part(body, L.board) F.bamboo(body, L.board, 3)
    end
    hline(cx - w, cx + w, y - 11, TH.deep) hline(cx - w, cx + w, y - 10, TH.edge)
    F.window(cx - 1, y - 8, cx + 1, y - 5, DW, true)
    -- lava corner posts
    vline(cx - w, y - 9, y, LAVA.base) vline(cx + w, y - 9, y, LAVA.deep)
    y = y - 11
    thatchRoof(cx - w - 8, cx + w + 8, y, cx - w + 1, cx + w - 1, y - 8, TH, 22 + i)
    y = y - 8
  end
  local spire = rect(cx - 1, y - 12, cx, y)
  rimOf(spire, DW) part(spire, DW, { nopop = true, noshade = true })
  for k = 0, 2 do hline(cx - 2, cx + 1, y - 3 - k * 3, ROPE.base) end
  conch(cx, y - 17, false)
  leiDrop(cx - 11, yb - 26, 6, 31) leiDrop(cx + 10, yb - 26, 6, 32)
end
F.depth(1)
F.tree(86, 128, 52, 4)
F.tree(22, 132, 34, 1)
tower(48, 134)
-- a little stacked lava cairn by the tower, a white coral piece on top
local function cairn(x, yb, s)
  local y = yb
  for k = 0, s - 1 do
    local w, h = floor((s - k) * 1.6) + 1, 2 + (s - k) // 2
    local m = c:ellipse(x + (k % 2), y - h // 2 - 1, w, math.max(1, h // 2))
    rimOf(m, LAVA) part(m, LAVA, { nopop = true })
    px(x + (k % 2) - w // 2, y - h + 1, LAVA.hi)
    y = y - h
  end
  F.coral(x, y, 4, L.shell)
end
cairn(76, 136, 5)

---------------------------------------------------------------- the road's end: lava platform, steps, coral-stone shrine hall, two palms
F.depth(2)
F.palm(178, 128, 74, L.foliage, 2, { lean = -18 })
F.palm(304, 128, 66, L.foliage2, 6, { lean = 16 })
local terr = poly{ { 188, 126 }, { 292, 126 }, { 288, 112 }, { 192, 112 } }
F.shadow(190, 292, 128, 8, 3)
rimOf(terr, LAVA) part(terr, LAVA) F.courses(terr, 112, 5, 12, LAVA)
terr:each(function(x, y) if hash(x, y, 40) < .08 then px(x, y, LAVA.deep) elseif hash(x, y, 41) < .03 then px(x, y, LAVA.hi) end end)
hline(192, 288, 112, LAVA.hi)
-- coral-stone steps up the middle, sand drifted on the treads
for k = 0, 4 do
  local y = 124 - k * 3
  local m = rect(228 + k, y, 252 - k, y + 2)
  fill(m, L.road.base) hline(228 + k, 252 - k, y, L.road.hi) hline(228 + k, 252 - k, y + 2, L.road.deep)
  for x = 229 + k, 251 - k do if hash(x, y, 42) < .14 then px(x, y + 1, L.ground.shade) end end
end
-- hall: cream coral-stone courses between black lava posts
local hall = rect(204, 92, 276, 112)
rimOf(hall, CS) part(hall, CS) F.courses(hall, 92, 4, 9, CS)
hall:each(function(x, y) if hash(x, y, 43) < .04 then px(x, y, L.coral.hi) end end)
for _, x in ipairs({ 204, 216, 228, 252, 264, 274 }) do
  fill(rect(x, 92, x + 2, 112), LAVA.base) vline(x, 92, 112, LAVA.hi) vline(x + 2, 92, 112, LAVA.deep)
  for y = 95, 111, 4 do px(x + 1, y, LAVA.shade) end
end
-- woven pandanus-mat screens either side
for _, d in ipairs({ { 218, 226 }, { 254, 262 } }) do
  local m = rect(d[1], 96, d[2], 110) weave(m, ROPE, L.needle)
  hline(d[1], d[2], 96, DW.deep) hline(d[1], d[2], 110, DW.deep)
end
-- open middle bay: candle-lit altar with a big pink conch and flowers
fill(rect(231, 96, 249, 112), L.soil.deep)
fill(rect(234, 100, 246, 110), L.soil.shade)
fill(rect(236, 101, 244, 108), L.glow.deep) fill(rect(238, 102, 242, 106), L.glow.shade)
conch(240, 101, true)
for _, x in ipairs({ 233, 235, 245, 247 }) do candle(x, 105 + (x % 3), 3) end
glowSpill(240, 104, 7, .35)
-- offering box with coconuts and bananas on a ti leaf
local box = rect(232, 106, 248, 112) rimOf(box, DW) part(box, DW) for x = 234, 246, 3 do px(x, 107, DW.deep) end
hline(233, 247, 105, L.foliage.base) px(233, 104, L.foliage.hi)
F.coconut(236, 103, 1) F.coconut(239, 103, 1, true)
for k = 0, 3 do px(242 + k, 103 + (k % 2), L.gold.base) px(242 + k, 102 + (k % 2), L.gold.hi) end
-- steep palm-thatch roof, a bound ridge roll, frond horns at the ridge ends
thatchRoof(186, 294, 90, 216, 264, 64, TH, 44)
ridgeRoll(212, 268, 60, 65, TH)
F.frond(213, 61, -2.45, 16, .55, L.foliage, 51, { wide = .28 })
F.frond(267, 61, -.7, 16, .55, L.foliage, 52, { wide = .28 })
-- gable of woven mat with a shell sun
local gab = poly{ { 226, 89 }, { 240, 70 }, { 254, 89 } }
weave(gab, ROPE, L.needle) c:edgeIn(gab, TH.deep)
local sunM = c:ellipse(240, 81, 3, 3) c:rim(sunM, L.shell.edge) fill(sunM, L.shell.base) px(239, 80, L.shell.hi) px(240, 79, L.shell.hi) px(241, 82, L.shell.shade)
for _, d in ipairs({ { -5, 0 }, { 5, 0 }, { 0, -5 }, { -4, -4 }, { 4, -4 } }) do px(240 + d[1], 81 + d[2], L.coral.base) end
-- rope with a shell rattle at the door
vline(240, 91, 104, ROPE.shade) vline(241, 91, 104, L.hibiscus.base)
px(239, 93, L.shell.hi) px(242, 94, L.shell.base) px(240, 95, L.coral.base)
-- a flower lei swagged across the front, with hanging ends
lei(206, 93, 274, 93, 1.2, 61)
for i, x in ipairs({ 206, 222, 258, 273 }) do leiDrop(x, 95, 5 + i % 2 * 2, 70 + i) end
-- candles and small bamboo torches along the platform foot
for x = 212, 225, 3 do candle(x, 129 - (x % 2), 2 + (x % 3)) end
for x = 256, 269, 3 do candle(x, 129 - (x % 2), 2 + (x % 3)) end
glowSpill(218, 127, 6, .25) glowSpill(262, 127, 6, .25)
-- offerings on the platform corners: shells on a ti leaf, a coconut and a banana hand
for _, b in ipairs({ { 197, 123 }, { 283, 123 } }) do
  hline(b[1] - 4, b[1] + 4, b[2] + 1, L.foliage.shade) hline(b[1] - 3, b[1] + 3, b[2], L.foliage.base) px(b[1] - 4, b[2], L.foliage.hi)
end
conch(197, 119, false) F.coconut(281, 120, 2) for k = 0, 3 do px(284 + k, 121 - (k % 2), L.gold.base) px(284 + k, 120 - (k % 2), L.gold.hi) end

---------------------------------------------------------------- right back: the sacred banyan + the drum frame
local function banyan()
  F.shadow(388, 438, 162, 10, 4)
  -- aerial roots hanging from the boughs (drawn first: trunk and canopy cover their tops); old ones thickened into pillars
  for i, r in ipairs({ { 366, 96, 150, 1 }, { 376, 100, 152, 1 }, { 386, 98, 146, 0 }, { 392, 104, 156, 1 }, { 430, 100, 154, 1 }, { 438, 98, 150, 0 },
      { 446, 96, 148, 1 }, { 454, 94, 132, 0 }, { 358, 92, 126, 0 }, { 424, 100, 124, 0 }, { 370, 96, 118, 0 }, { 450, 96, 116, 0 }, { 382, 96, 128, 0 }, { 434, 98, 122, 0 } }) do
    local x, y0, y1, thick = r[1], r[2], r[3], r[4] == 1
    for y = y0, y1 do
      local xx = x + floor(sin(y / 9 + i) * 1.4)
      if thick then
        local w = y > y1 - 8 and 2 or 1
        for k = -w - 1, w do px(xx + k, y, k == -w - 1 and DW.edge or (k == -w and DW.base or (k == w and DW.edge or DW.shade))) end
        if hash(xx, y // 3, 301) < .2 then px(xx, y, DW.deep) end
      else
        px(xx, y, (y % 5 == 0) and DW.shade or DW.deep)
      end
    end
    if thick then hline(x - 4, x + 4, y1 + 1, DW.deep) px(x - 3, y1, DW.base) px(x + 3, y1, DW.shade)
    else px(x - 1, y1 + 1, L.needle.shade) px(x + 1, y1 + 1, L.needle.base) px(x, y1 + 2, L.needle.deep) end
  end
  local trunk = poly{ { 396, 162 }, { 401, 154 }, { 402, 128 }, { 400, 98 }, { 418, 98 }, { 416, 128 }, { 417, 154 }, { 424, 162 } }
  rimOf(trunk, DW) part(trunk, DW)
  -- fluted, buttressed trunk: twisting root strands
  trunk:each(function(x, y)
    local f = (x + floor(sin(y / 6) * 2)) % 4
    if f == 0 then px(x, y, DW.deep) elseif f == 1 and x < 410 then px(x, y, DW.hi) end
  end)
  local brs = line({ { 404, 106 }, { 384, 86 } }, 3):add(line({ { 414, 102 }, { 436, 84 } }, 3)):add(line({ { 402, 112 }, { 368, 100 } }, 2)):add(line({ { 416, 110 }, { 450, 98 } }, 2))
  rimOf(brs, DW) part(brs, DW, { nopop = true })
  -- the canopy: many overlapping leaf clumps, the high ones sunlit, the low ones deep
  local cl = {}
  for i = 1, 30 do
    local a, d = hash(i, 1, 300) * 2 * pi, math.sqrt(hash(i, 2, 300))
    cl[i] = { 408 + cos(a) * 50 * d, 76 + sin(a) * 26 * d, 9 + hash(i, 3, 300) * 6 }
  end
  table.sort(cl, function(a, b) return a[2] < b[2] end)
  for i, k in ipairs(cl) do
    local ramp = (k[2] < 62 or (k[1] < 392 and k[2] < 74)) and L.foliage or L.foliage2
    F.crown(floor(k[1]), floor(k[2]), floor(k[3]), floor(k[3] * .62), ramp, 310 + i)
  end
  -- roped trunk with a lei
  for x = 401, 417 do px(x, 136 + (x - 401) // 6, ROPE.shade) px(x, 137 + (x - 401) // 6, (x % 3 == 0) and ROPE.hi or ROPE.base) px(x, 138 + (x - 401) // 6, ROPE.deep) end
  lei(402, 141, 416, 143, 1, 81)
  -- leis and shell strings hung on the low boughs
  for i, p in ipairs({ { 380, 108 }, { 392, 110 }, { 432, 108 }, { 442, 104 }, { 370, 106 }, { 426, 112 } }) do
    if i % 2 == 0 then shellString(p[1], p[2], 8 + i % 3, 90 + i) else leiDrop(p[1], p[2], 6 + i % 3, 90 + i) end
  end
  F.parrot(420, 82, "lory", true)
end
local function drumFrame(x0, yb)
  local posts = rect(x0, yb - 34, x0 + 2, yb):add(rect(x0 + 30, yb - 34, x0 + 32, yb))
  F.shadow(x0, x0 + 34, yb, 8, 3)
  rimOf(posts, DW) part(posts, DW, { nopop = true })
  posts:each(function(x, y) if (y - yb) % 9 == 0 then px(x, y, ROPE.base) end end)
  thatchRoof(x0 - 8, x0 + 40, yb - 34, x0 + 4, x0 + 28, yb - 45, TH, 93)
  -- the slit-log drum on two lava blocks: carved zigzag band, the dark slit on top
  local blocks = rect(x0 + 6, yb - 4, x0 + 10, yb):add(rect(x0 + 22, yb - 4, x0 + 26, yb))
  local log = c:rrect(x0 + 3, yb - 14, x0 + 29, yb - 4, 4)
  rimOf(union(blocks, log), DW)
  part(blocks, LAVA, { nopop = true })
  part(log, DW)
  log:each(function(x, y)
    local k = y - (yb - 14)
    if k == 2 and x > x0 + 6 and x < x0 + 26 then px(x, y, DW.edge)
    elseif k >= 5 and k <= 7 and ((x + k) % 4 == 0) then px(x, y, L.hibiscus.shade)
    elseif k == 4 or k == 8 then if x % 2 == 0 then px(x, y, DW.deep) end end
  end)
  F.logEnd(x0 + 4, yb - 9, 4, DW)
  -- a conch horn hanging from the beam
  vline(x0 + 16, yb - 32, yb - 26, ROPE.shade)
  conch(x0 + 16, yb - 25, true)
  leiDrop(x0 + 1, yb - 32, 7, 97) leiDrop(x0 + 30, yb - 32, 7, 98)
end
banyan()
drumFrame(300, 140)
local _, rx, ry = F.gnome(352, 142, { hat = L.awnA, coat = L.wall2, arm = "up", flip = true })
-- the drum stick, swung down onto the log
local stick = line({ { rx, ry }, { 326, 125 } }, 1)
stick:each(function(x, y) px(x, y, DW.deep) end)
fill(rect(325, 124, 327, 126), L.coconut.base) px(325, 124, L.coconut.hi)
-- sound ticks
for _, p in ipairs({ { 320, 120 }, { 316, 118 }, { 332, 119 } }) do px(p[1], p[2], L.cloud.top) end

---------------------------------------------------------------- the driftwood gate over the road
local function gateWood()
  local postL, postR = rect(204, 122, 209, 198), rect(271, 122, 276, 198)
  local kasagi = poly{ { 184, 112 }, { 194, 108 }, { 286, 108 }, { 296, 112 }, { 294, 118 }, { 186, 118 } }
  local shimaki = rect(192, 119, 288, 122)
  local nuki = rect(196, 132, 284, 136)
  local plaque = c:ellipse(240, 126, 6, 5)
  local feet = rect(201, 194, 212, 199):add(rect(268, 194, 279, 199))
  F.shadow(204, 280, 199, 10, 4)
  local sil = union(postL, postR, kasagi, shimaki, nuki, plaque, feet)
  rimOf(sil, DW)
  for _, p in ipairs({ { postL, 204 }, { postR, 271 } }) do
    part(p[1], DW)
    p[1]:each(function(x, y)
      local k = x - p[2]
      if k == 1 then px(x, y, DW.hi) elseif k == 5 then px(x, y, DW.shade)
      elseif hash(x, y // 5, 93) < .2 then px(x, y, DW.shade) elseif hash(x, y // 3, 94) < .1 then px(x, y, DW.hi) end
      if hash(x, y // 7, 95) < .06 then px(x, y, DW.deep) end
    end)
    -- sennit lashings
    for _, ly in ipairs({ 124, 128, 138, 142, 176 }) do for x = p[2], p[2] + 5 do px(x, ly, (x % 2 == 0) and ROPE.hi or ROPE.base) px(x, ly + 1, ROPE.deep) end end
  end
  part(nuki, L.board, { nopop = true }) F.bamboo(nuki, L.board, 3, { horizontal = true })
  for _, x in ipairs({ 196, 284 }) do local e = c:ellipse(x, 134, 1, 2) fill(e, L.board.hi) px(x, 134, L.board.deep) end
  part(shimaki, DW, { nopop = true }) hline(192, 288, 119, DW.hi)
  part(kasagi, TH, { nopop = true }) F.thatch(kasagi, TH, 108, 240) hline(194, 286, 108, TH.hi) hline(186, 294, 118, TH.edge)
  for x = 186, 294 do local n = floor(hash(x, 96, 7) * 3) for k = 0, n - 1 do px(x, 119 + k, k == n - 1 and TH.edge or TH.deep) end end
  part(feet, CS, { nopop = true }) F.courses(feet, 194, 3, 6, CS)
  -- the shell plaque: a scallop disc with ribs
  fill(plaque, L.shell.base)
  plaque:each(function(x, y)
    local a = math.atan(y - 131, x - 240)
    if floor(a * 6) % 2 == 0 then px(x, y, L.shell.shade) end
    if x < 238 and y < 125 then px(x, y, L.shell.hi) end
  end)
  c:edgeIn(plaque, L.coral.shade)
  px(240, 126, L.coral.base) px(239, 125, L.coral.hi)
  -- leis: draped along the tie beam and hanging off the posts
  lei(210, 137, 270, 137, 2.2, 101)
  leiDrop(203, 124, 12, 102) leiDrop(277, 124, 12, 103)
  for i, x in ipairs({ 214, 228, 252, 266 }) do leiDrop(x, 137 + floor(2.2 * 4 * ((x - 210) / 60) * (1 - (x - 210) / 60)) + 2, 3 + i % 2 * 2, 104 + i) end
  -- hibiscus at the post feet
  F.flower(200, 192, "hibiscus") F.flower(213, 193, "orange", true) F.flower(267, 193, "plumeria", true) F.flower(281, 192, "hibiscus")
end

---------------------------------------------------------------- bamboo torch on a lava base, scaled by depth
local function torch(x, yb, s)
  local h = floor(30 * s)
  local pw = s >= 1 and 3 or 2
  F.shadow(floor(x - 4 * s), floor(x + 5 * s), yb, floor(5 * s), floor(2 * s))
  F.lavaRock(x, yb, floor(5 * s) + 1, floor(4 * s) + 2, x)
  local pole = rect(x - pw // 2, yb - h, x - pw // 2 + pw - 1, yb - floor(3 * s))
  local cw = math.max(2, floor(3 * s))
  local cup = c:rrect(x - cw, yb - h - floor(4 * s) - 1, x + cw, yb - h + 1, 1)
  rimOf(union(pole, cup), DW)
  part(pole, L.board, { nopop = true, noshade = true })
  vline(x - pw // 2, yb - h, yb - floor(3 * s), L.board.hi)
  for y = yb - h + 4, yb - 4, floor(7 * s) + 2 do hline(x - pw // 2, x - pw // 2 + pw - 1, y, L.board.deep) end
  part(cup, L.coconut, { nopop = true })
  hline(x - cw, x + cw, yb - h - 1, ROPE.base)
  -- the flame
  local fh = floor(6 * s) + 3
  local fy = yb - h - floor(4 * s) - 2
  local flame = poly{ { x - cw + 1, fy + 1 }, { x + cw - 1, fy + 1 }, { x + 1, fy - fh + 2 }, { x, fy - fh } }
  c:rim(flame, L.glow.deep)
  fill(flame, L.glow.shade)
  flame:each(function(xx, yy) if yy > fy - fh * .6 and abs(xx - x) <= cw - 2 then px(xx, yy, L.glow.base) end end)
  px(x, fy - 1, L.glow.hi) px(x, fy, L.glow.hi)
  glowSpill(x, fy - 2, floor(5 * s) + 3, .22)
end

---------------------------------------------------------------- left hero: the giant-clam basin pavilion
local function basin()
  local x0, x1, yt, yb = 96, 184, 150, 214
  local posts = rect(x0 + 6, yt + 8, x0 + 9, yb):add(rect(x1 - 9, yt + 8, x1 - 6, yb))
  F.shadow(x0 + 6, x1, yb, 12, 5)
  rimOf(posts, DW) part(posts, DW, { nopop = true })
  posts:each(function(x, y) if hash(x, y // 3, 64) < .2 then px(x, y, DW.shade) end if (y - yb) % 11 == 0 then px(x, y, ROPE.base) end end)
  for _, x in ipairs({ x0 + 6, x1 - 9 }) do fill(rect(x - 1, yb - 3, x + 4, yb), LAVA.base) hline(x - 1, x + 4, yb - 3, LAVA.hi) end
  thatchRoof(x0 - 8, x1 + 8, yt + 8, x0 + 18, x1 - 18, yt - 16, TH, 66)
  ridgeRoll(x0 + 14, x1 - 14, yt - 20, yt - 16, TH)
  local tri = poly{ { 126, yt + 5 }, { 140, yt - 12 }, { 154, yt + 5 } }
  weave(tri, ROPE, L.needle) c:edgeIn(tri, TH.deep)
  F.sprite({ "..t..", ".tTt.", "tTTTt", ".tTt.", "t.t.t" }, 138, yt - 5, { t = L.foliage2.shade, T = L.seagrass.base }, { rim = false }) -- a turtle sign
  lei(x0 + 6, yt + 12, x1 - 6, yt + 12, 1.6, 67)
  -- the lava pedestal
  local front = rect(116, 196, 164, 210)
  rimOf(front, LAVA) part(front, LAVA) F.courses(front, 196, 5, 10, LAVA, 3)
  front:each(function(x, y) if hash(x, y, 68) < .1 then px(x, y, LAVA.deep) end end)
  -- the giant clam: fluted shell, wavy lip, turquoise water in it
  local clam = c:ellipse(140, 190, 32, 9):clip(rect(100, 183, 180, 200))
  clam:add(c:rect(110, 182, 170, 184))
  rimOf(clam, L.shell)
  clam:each(function(x, y)
    local a = math.atan(y - 204, x - 140)
    local rib = floor((a + pi) * 8) % 2
    local hcol = rib == 0 and L.stone.hi or L.stone.shade
    if x < 128 and rib == 0 then hcol = L.shell.hi end
    if x > 158 and rib == 1 then hcol = L.stone.deep end
    if y > 195 then hcol = rib == 0 and L.stone.shade or L.stone.deep end
    px(x, y, hcol)
  end)
  -- the scalloped lip
  for x = 108, 172 do local yy = 183 + floor(abs(sin((x - 108) / 64 * pi * 7)) * 2) px(x, yy, L.shell.hi) px(x, yy + 1, L.coral.base) end
  local wat = c:ellipse(140, 183, 26, 3)
  F.water(wat, L.lagoon, { step = 2 })
  -- floating plumeria flowers
  for _, k in ipairs({ { 126, 183 }, { 150, 184 } }) do F.flower(k[1], k[2], "plumeria", true) end
  -- lava rock spring and a bamboo spout with a trickle
  F.lavaRock(178, 194, 10, 11, 69)
  for _, t in ipairs({ { 172, 184 }, { 182, 185 } }) do F.fern(t[1], t[2], 3, L.seagrass) end
  local sp = rect(148, 168, 176, 171)
  rimOf(sp, L.board) part(sp, L.board, { nopop = true }) F.bamboo(sp, L.board, 4, { horizontal = true })
  hline(149, 175, 169, L.lagoon.base)
  vline(148, 172, 182, L.lagoon.hi) vline(149, 173, 182, L.lagoon.base)
  px(147, 182, L.surf) px(151, 182, L.lagoon.hi)
  vline(166, 172, 182, DW.base) vline(167, 172, 182, DW.deep)
  -- coconut-shell ladles on bamboo handles laid across the lip
  for k = 0, 2 do
    local lx = 114 + k * 8
    local h = line({ { lx + 2, 182 }, { lx + 8, 177 } })
    c:rim(h, L.board.edge) h:each(function(x, y) px(x, y, L.board.hi) end)
    local cup = c:ellipse(lx, 183, 2, 1) c:rim(cup, L.coconut.edge) fill(cup, L.coconut.base) px(lx - 1, 182, L.coconut.hi) px(lx + 1, 184, L.coconut.deep)
  end
  -- a gecko on the clam lip
  F.sprite({ "g...g..", ".gGGGGe", "g.GGg..", "...g..." }, 160, 179, { g = L.foliage.shade, G = L.foliage.base, e = L.timber.edge })
  px(162, 180, L.foliage.hi) px(164, 181, L.gold.base)
end

---------------------------------------------------------------- right hero: the offering rack of shell plaques and shell strings
local function rack()
  local x0, x1, yt, yb = 300, 384, 160, 214
  local posts = rect(x0, yt, x0 + 3, yb):add(rect(x1 - 3, yt, x1, yb))
  local rails = rect(x0, 172, x1, 173):add(rect(x0, 190, x1, 191))
  F.shadow(x0, x1, yb, 12, 4)
  rimOf(union(posts, rails), DW)
  part(posts, DW, { nopop = true }) part(rails, L.board, { nopop = true, noshade = true }) F.bamboo(rails, L.board, 2, { horizontal = true })
  posts:each(function(x, y) if (y - yb) % 10 == 0 then px(x, y, ROPE.base) end end)
  thatchRoof(x0 - 6, x1 + 6, yt, x0 + 6, x1 - 6, yt - 9, TH, 72)
  local cols = { L.awnA, L.accent, L.hibiscus, L.lav, L.seagrass, L.sea }
  for row = 0, 1 do
    local yy = row == 0 and 174 or 192
    for k = 0, 9 do
      local x = x0 + 5 + k * 8 + (row == 1 and 3 or 0)
      if x + 6 < x1 - 3 then
        if row == 1 and k % 3 ~= 1 then
          shellString(x + 1, yy, 9 + (k % 3) * 2, 120 + k) shellString(x + 4, yy, 7 + (k % 2) * 3, 130 + k)
        else
          -- a painted scallop-shell plaque
          local m = poly{ { x, yy + 3 }, { x + 3, yy }, { x + 6, yy + 3 }, { x + 6, yy + 7 }, { x + 3, yy + 9 }, { x, yy + 7 } }
          c:rim(m, L.shell.edge) fill(m, L.shell.hi)
          m:each(function(xx, y) if (xx - x) % 2 == 1 and y > yy + 2 then px(xx, y, L.shell.base) end end)
          vline(x + 6, yy + 3, yy + 7, L.shell.shade) hline(x + 1, x + 5, yy + 8, L.shell.shade)
          local cr = cols[(k + row * 2) % #cols + 1]
          if k % 2 == 0 then -- a painted little turtle
            hline(x + 2, x + 4, yy + 4, cr.base) hline(x + 2, x + 4, yy + 5, cr.shade) px(x + 3, yy + 3, cr.base) px(x + 1, yy + 6, cr.shade) px(x + 5, yy + 6, cr.shade)
          else -- a painted wave / wish
            px(x + 1, yy + 5, cr.base) px(x + 2, yy + 4, cr.base) px(x + 3, yy + 5, cr.shade) px(x + 4, yy + 4, cr.base) px(x + 5, yy + 5, cr.shade)
          end
          px(x + 3, yy - 1, ROPE.base)
        end
      end
    end
  end
  lei(x0 + 2, yt + 4, x1 - 2, yt + 4, 1.3, 140)
end
local function plinth(x, yb, w, h)
  local m = rect(x - w, yb - h, x + w, yb) rimOf(m, CS) part(m, CS) hline(x - w, x + w, yb - h, CS.hi)
  F.courses(m, yb - h, 3, 7, CS)
  m:each(function(xx, y) if hash(xx, y, 150 + x) < .06 then px(xx, y, L.coral.hi) end end)
end
-- a carved lava-stone sea turtle guardian on a plinth, head raised toward the road
local function stoneTurtle(x, yb, flip, bare)
  local s = flip and -1 or 1
  local function P(dx, dy) return { x + dx * s, yb + dy } end
  local shellM = c:ellipse(x - s, yb - 5, 8, 5):clip(rect(x - 12, yb - 11, x + 12, yb - 3))
  local skirt = rect(math.min(x - 9 * s, x + 7 * s), yb - 3, math.max(x - 9 * s, x + 7 * s), yb - 1)
  local neck = poly{ P(5, -3), P(8, -10), P(11, -10), P(9, -2) }
  local head = c:ellipse(x + 10 * s, yb - 11, 3, 2)
  local fl1 = poly{ P(3, -2), P(13, 0), P(4, 0) }
  local fl2 = poly{ P(-6, -2), P(-12, 0), P(-5, 0) }
  local m = union(shellM, skirt, neck, head, fl1, fl2)
  rimOf(m, LAVA) part(m, LAVA)
  -- carved scutes, each lit on its upper-left lip
  shellM:each(function(xx, y)
    local u, v = (xx - x) * s + 9, y - (yb - 10)
    local off = v < 4 and 0 or 2
    local h
    if v == 4 or (u + off) % 5 == 0 then h = LAVA.deep
    elseif v == 1 or v == 5 or (u + off) % 5 == 1 then h = (xx - x) * s < 3 and L.stone.shade or LAVA.hi
    elseif (xx - x) * s > 4 or v > 5 then h = LAVA.shade end
    if h then px(xx, y, h) end
  end)
  skirt:each(function(xx, y) px(xx, y, (xx % 3 == 0) and LAVA.deep or (y == yb - 3 and LAVA.base or LAVA.shade)) end)
  head:each(function(xx, y) if y < yb - 11 and (xx - x) * s < 11 then px(xx, y, LAVA.hi) end end)
  px(x + 11 * s, yb - 12, L.shell.hi) px(x + 11 * s, yb - 11, LAVA.edge) -- a shell-inlay eye
  px(x + 12 * s, yb - 10, LAVA.deep)
  if not bare then
    for k = 0, 5 do
      local r = LEI[k % #LEI + 1]
      px(x + (6 + k * .8) * s, yb - 8 + floor(k * .45), r.hi) px(x + (6 + k * .8) * s, yb - 7 + floor(k * .45), r.shade)
    end
    F.flower(x + 7 * s, yb - 6, "hibiscus", true)
  end
end

---------------------------------------------------------------- raked white coral-sand garden (bottom-left)
local function sandGarden()
  local g = poly{ { 20, 230 }, { 150, 226 }, { 162, 264 }, { 20, 266 } }
  local edge = g:grow(3):cut(g)
  edge:each(function(x, y)
    local v = hash(x // 2, y // 2, 77)
    px(x, y, v < .35 and LAVA.base or (v < .55 and LAVA.shade or (v < .75 and L.shell.base or L.coral.hi)))
  end)
  g:each(function(x, y) px(x, y, L.shell.hi) end)
  local rocks = { { 56, 246, 10 }, { 120, 248, 8 } }
  g:each(function(x, y)
    local best = 1e9
    for _, r in ipairs(rocks) do best = math.min(best, math.sqrt(((x - r[1]) / 1.6) ^ 2 + ((y - r[2])) ^ 2) - r[3] * .55) end
    if best < 14 then if floor(best) % 3 == 0 then px(x, y, L.shell.base) end
    elseif (y + floor(sin(x / 20) * 1.5)) % 3 == 0 then px(x, y, L.shell.base) end
    if hash(x, y, 78) < .012 then px(x, y, L.petal.base) end
  end)
  F.lavaRock(56, 250, 12, 12, 79) F.lavaRock(120, 251, 9, 9, 80) F.lavaRock(130, 252, 5, 5, 81)
  -- a staghorn coral and a few shells set in the sand
  F.coral(88, 244, 6, L.coral) F.coral(92, 246, 4, L.shell)
  F.shell(36, 240, "scallop", true) F.shell(140, 238, "cowrie") F.shell(70, 258, "conch", true)
  for _, f in ipairs({ { 18, 232, 6 }, { 24, 228, 5 }, { 160, 228, 6 }, { 166, 262, 7 } }) do F.fern(f[1], f[2], f[3], L.seagrass) end
end

---------------------------------------------------------------- compose
F.depth(3)
-- lava fire bowl with a smoke curl (left middle), a lava cairn beside it
do
  local legs = rect(54, 214, 55, 220):add(rect(66, 214, 67, 220))
  local bowl = c:rrect(50, 204, 71, 215, 4)
  F.shadow(52, 70, 220, 6, 2)
  rimOf(union(legs, bowl), LAVA)
  part(legs, LAVA, { nopop = true }) part(bowl, LAVA)
  bowl:each(function(x, y) if hash(x, y, 83) < .12 then px(x, y, LAVA.deep) end end)
  hline(52, 69, 204, L.glow.shade) hline(53, 68, 205, L.produce.deep)
  for x = 54, 67, 3 do px(x, 203, L.glow.base) px(x + 1, 203, L.produce.base) end
  px(60, 202, L.glow.hi) px(61, 201, L.glow.base)
  hline(50, 71, 208, LAVA.edge) for x = 53, 68, 3 do px(x, 211, LAVA.hi) end
  F.smoke(61, 201, 7, -.3, 2)
  cairn(38, 222, 6)
  F.flower(46, 218, "hibiscus", true) F.flower(74, 219, "plumeria", true)
end
-- a beached outrigger canoe with a paddle, a net of coconuts beside it
F.shadow(22, 66, 162, 6, 2)
F.outrigger(24, 64, 160, { side = -1, stripe = L.awnA })
local pad = line({ { 70, 150 }, { 78, 164 } }) c:rim(pad, DW.edge) pad:each(function(x, y) px(x, y, DW.base) end)
local blade = c:ellipse(79, 166, 2, 3) c:rim(blade, DW.edge) fill(blade, L.wall2.base) px(78, 165, L.wall2.hi)
for k, d in ipairs({ { 84, 166 }, { 88, 167 }, { 86, 163 } }) do F.coconut(d[1], d[2], 2, k == 2) end
basin()
rack()
for _, p in ipairs({ { 146, .5, 11 }, { 182, .7, 22 }, { 252, 1.3, 22 } }) do
  local y = p[1]
  torch(floor(F.xl(y)) - p[3], y, p[2])
  torch(floor(F.xr(y)) + p[3], y, p[2])
end
gateWood()
plinth(194, 214, 7, 6) stoneTurtle(190, 208, false)
plinth(291, 214, 14, 6) stoneTurtle(282, 208, true, true)
-- quirk: a real turtle hatchling sits on the plinth beside the stone turtle, in its lei and a little red gnome hat
F.sprite({
  "....R.........",
  "...RRr........",
  "...RRr........",
  "..RRRRr.......",
  ".hhhhhhh......",
  ".GGGGGG.......",
  "GeGGGgG.......",
  "nGGGGgG.......",
  ".GGGGG........",
  "..LlLlL.BBBB..",
  "..GGgLBBbBBBB.",
  ".GGGBBbBBbBBBb",
  "GGgBBBBBBBBbBb",
  "Gg.ccccccccccG",
  "....gg....ggg.",
}, 293, 193, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, G = L.seagrass.base, g = L.seagrass.shade, e = L.timber.edge,
  n = L.seagrass.deep, L = L.hibiscus.base, l = L.petal.hi, B = L.coconut.base, b = L.coconut.deep, c = L.board.shade })
px(296, 194, L.awnA.hi) px(294, 198, L.seagrass.hi) px(299, 203, L.coconut.hi) px(301, 204, L.coconut.hi)
sandGarden()
-- frangipani, banana and hibiscus at the right edge
F.banana(420, 226, 40, 55)
F.plumeria(440, 230, 62, 53)
F.plumeria(458, 226, 74, 54)
for i = 0, 16 do local x, y = 414 + floor(hash(i, 1, 55) * 50), 214 + floor(hash(i, 2, 55) * 14)
  if hash(i, 3, 55) < .6 then F.flower(x, y, i % 3 == 0 and "white" or "plumeria", true) else px(x, y, L.birchLeaf.base) px(x + 1, y, L.birchLeaf.shade) end end
for _, f in ipairs({ { 412, 230, 7 }, { 434, 230, 8 }, { 300, 224, 6 }, { 290, 232, 7 } }) do F.fern(f[1], f[2], f[3], L.seagrass) end
F.crab(404, 228, L.awnA) F.crab(338, 150, L.hibiscus, true)
F.coconut(318, 134, 2) F.coconut(323, 135, 2, true)
-- a hibiscus hedge and a gnome sweeping fallen frangipani by the right torches
F.hibiscus(406, 232, 12, 10, 12)
F.hibiscus(334, 250, 14, 10, 13)
local _, bx, by = F.gnome(348, 238, { hat = L.awnA, coat = L.hibiscus, flip = true, arm = "hold" })
fill(line({ { bx + 1, by - 6 }, { bx - 6, by + 6 } }, 1), DW.base)
-- a coconut-midrib broom
local broom = poly{ { bx - 12, by + 6 }, { bx - 3, by + 6 }, { bx - 4, by + 10 }, { bx - 13, by + 10 } }
rimOf(broom, ROPE) part(broom, ROPE, { nopop = true }) for x = bx - 12, bx - 4, 2 do vline(x, by + 7, by + 10, ROPE.deep) end
hline(bx - 7, bx - 4, by + 6, L.awnA.base)
-- the heap of frangipani flowers and dry palm bits he is sweeping up
for i = 0, 30 do local x, y = 312 + floor(hash(i, 1, 5) * 15), 240 + floor(hash(i, 2, 5) * 5) - (i % 3)
  if i % 3 == 0 then px(x, y, L.needle.base) px(x + 1, y, L.needle.shade)
  else px(x, y, (i % 2 == 0) and L.petal.hi or L.shell.hi) px(x + 1, y, (i % 2 == 0) and L.petal.base or L.shell.base) px(x, y + 1, L.gold.base) end end
-- a gnome hanging a new shell string on the rack
local _, ex, ey = F.gnome(392, 214, { hat = L.awnA, coat = L.seagrass, arm = "up", flip = true })
shellString(ex, ey - 1, 9, 160)
-- fairy terns on the gate cap, frigatebirds and terns over the hall
F.depth(0)
F.sprite({ ".ww.", "wwwe", "swwwk", ".y.." }, 196, 104, { w = L.cloud.top, s = L.cloud.under, e = L.timber.edge, k = L.timber.edge, y = L.timber.deep })
F.sprite({ "ww..", "ewww", "kwwws", "..y." }, 276, 104, { w = L.cloud.top, s = L.cloud.under, e = L.timber.edge, k = L.timber.edge, y = L.timber.deep })
F.birds({ { 330, 38, 3 }, { 342, 44, 2 }, { 168, 30, 2 }, { 180, 24, 1 } })
F.depth(3)
-- fallen frangipani and hibiscus petals scattered around
for i = 0, 50 do
  local x, y = 20 + floor(hash(i, 1, 77) * 440), 130 + floor(hash(i, 2, 77) * 130)
  if not (x > 376 and y > 226) then
    if i % 3 == 0 then px(x, y, L.awnA.base) px(x + 1, y, L.awnA.shade)
    else px(x, y, L.petal.hi) px(x + 1, y, L.shell.hi) px(x, y + 1, L.gold.base) end
  end
end
F.finish()
