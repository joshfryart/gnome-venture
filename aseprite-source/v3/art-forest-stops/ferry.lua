-- ferry.lua : "Ferry crossing" stop look, FOREST (forest_pinewood), 480x270 gate view.
-- Same composition as the Maplewold ferry (art-2701-batch4/stops/opus3/ferry.lua), re-cast for a pine-wood river:
-- a cool misted river runs across the whole view and the road stops at it on a mossy plank landing. The ferry raft is
-- the centre hero, mid-river and coming in: a ferryman poles it, a traveller with a bundle and cargo ride it, and a gnome
-- on the landing hauls it in by the tow rope. Far bank: dark spruce and a red pine, the road goes on from a far landing
-- past the ferryman's log house (bell post, lantern), a log cabin with smoke, washing, a gnome waving; alders lean over
-- the water on the right with a grey heron fishing below them. Near bank: ferry bell under a bark roof, a painted ferry
-- sign, a log ticket booth with a gnome in the hatch, a bench of waiting travellers, a beached rowboat, a barrow of
-- firewood, cargo, ferns, mushrooms and cattail beds. Quirk: a big white hen in a red gnome hat, riding the raft on a trunk.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-forest-stops/"
local F = dofile(DIR .. "_frame.lua")
  .build{ name = "ferry", out = DIR, roadTop = 178, farTrees = { 30, 70, 120, 168, 330, 372, 446 },
    clouds = { { 150, 44, 40 }, { 290, 34, 50 }, { 420, 70, 28 }, { 196, 78, 24 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local mix = F.mix
local Wt = L.water
local GLINT = "#eef6e6"
local alder = F.rp("#a6c07c #6f9452 #4e7240 #365236 #20342a")
-- DY: a temporary vertical offset for whole near-bank groups (set, draw, reset)
local DY = 0
do local base = c.put c.put = function(self, x, y, h, o) base(self, x, y + DY, h, o) end end

local function yF(x) return 124 + floor(2 * sin(x / 31) + 1.5 * sin(x / 11)) end
local function yN(x) local t = (x - 240) / 240 return 177 + floor(14 * t * t + 3 * sin(x / 23) + 2 * sin(x / 9 + 1)) end

---------------------------------------------------------------- the river
local river = HP.mask()
for x = 0, 479 do for y = yF(x), yN(x) do river:set(x, y) end end
do
  river:each(function(x, y)
    local f = (y - yF(x)) / math.max(1, yN(x) - yF(x))
    local h
    if f < .18 then h = Wt.hi
    elseif f < .4 then h = hash(x // 8, y, 14) < .5 and Wt.hi or mix(Wt.hi, Wt.base, .5)
    elseif f < .78 then h = Wt.base
    else h = hash(x // 6, y // 2, 15) < .6 and mix(Wt.base, Wt.shade, .5) or Wt.base end
    px(x, y, h)
  end)
  -- current streaks: long thin lit lines drifting with the flow, longer nearer
  for y = 126, 194 do
    local d = y - 122
    if y % 3 == 0 then
      local x = floor(hash(y, 1, 13) * 30)
      while x < 480 do
        local len = 4 + d // 3 + floor(hash(x, y, 18) * 8)
        if hash(x // 9, y, 16) < .5 then
          for xx = x, x + len do if river:has(xx, y) and river:has(xx, y + 1) then px(xx, y, Wt.hi) if d > 22 then px(xx, y + 1, Wt.shade) end end end
        end
        x = x + len + 10 + floor(hash(x, y, 17) * 22)
      end
    end
  end
  for i = 0, 60 do local x, y = floor(hash(i, 1, 18) * 480), 126 + floor(hash(i, 2, 18) * 64) if river:has(x, y) and river:has(x + 1, y) then px(x, y, GLINT) px(x + 1, y, Wt.hi) end end
  -- far bank: dark lip under the moss, a line of wet stones; near bank: dark peat, wet mud, mossy stones
  for x = 0, 479 do
    px(x, yF(x), Wt.deep) px(x, yF(x) + 1, Wt.shade)
    local v = hash(x, 3, 7)
    px(x, yF(x) - 1, v < .3 and L.stone.base or (v < .5 and L.moss.shade or L.mossGround.shade))
    local yn = yN(x)
    for k = 1, 4 do
      local col
      if k == 1 then col = L.soil.deep elseif k == 2 then col = L.soil.shade
      else local w = hash(x, k, 5) col = w < .25 and L.stone.base or (w < .45 and L.moss.shade or (w < .6 and L.stone.shade or L.soil.base)) end
      px(x, yn + k, col)
    end
    if hash(x, 9, 6) < .25 then px(x, yn + 3, L.moss.hi) end
    if hash(x, 10, 6) < .12 then px(x, yn + 3, L.stone.hi) end
    px(x, yn, Wt.hi)
  end
end

---------------------------------------------------------------- far bank: road on, landing, ferry house, conifers, cabin
F.depth(1)
F.drawRoad(113, 122)
F.tree(112, 122, 34, 5)
F.tree(20, 122, 40, 2)
F.tree(96, 121, 30, 4)
do -- a log cabin with smoke
  local top, cx, wallM, roofM = F.building{ x0 = 36, x1 = 80, yb = 122, wh = 13, rh = 11, wall = L.timber, roof = L.roof, noFrame = true, noAttic = true, chimney = true, shingle = true }
  F.logs(wallM, L.timber, top, 3)
  F.moss(roofM, .16, 101)
  F.window(44, 113, 48, 116, L.timber) F.window(68, 113, 72, 116, L.timber)
  F.smoke(70, 94, 4, .6, 2)
end
-- far reed line along the whole far bank: dense little blades with cattail heads
local function reedClump(x, yb, n, hmax, seed, near)
  local blades = {}
  for i = 1, n do
    local bx = x + floor((hash(i, 1, seed) - .5) * n * 1.6)
    local h = floor(hmax * (.55 + .45 * hash(i, 2, seed)))
    local lean = (hash(i, 3, seed) - .5) * (near and 8 or 4)
    blades[#blades + 1] = { bx, h, lean, hash(i, 4, seed) }
  end
  local m = HP.mask()
  local heads = {}
  for _, b in ipairs(blades) do
    local bx, h, lean, v = b[1], b[2], b[3], b[4]
    local w = near and 2 or 1
    local pts = { { bx, yb }, { bx + lean * .3, yb - h * .5 }, { bx + lean, yb - h } }
    m:add(line(pts, w))
    if v < .45 then heads[#heads + 1] = { floor(bx + lean * .8), yb - h - 1 } end
  end
  if near then c:rim(m, L.fern.edge) end
  m:each(function(xx, yy)
    local t = (yb - yy) / hmax
    local hsh = hash(xx, yy, seed)
    local col = t > .6 and L.fern.hi or (t > .25 and L.fern.base or L.fern.shade)
    if hsh < .22 then col = L.fern.shade elseif hsh > .9 then col = L.needle.base end
    if yy >= yb - 1 then col = L.fern.deep end
    px(xx, yy, col)
  end)
  for _, hd in ipairs(heads) do
    local hx, hy = hd[1], hd[2]
    if near then
      local cm = rect(hx - 1, hy - 5, hx + 1, hy) c:rim(cm, L.soil.edge)
      fill(cm, L.soil.base) vline(hx - 1, hy - 5, hy - 1, L.soil.hi) vline(hx + 1, hy - 4, hy, L.soil.deep) px(hx, hy - 6, L.fern.shade) px(hx, hy - 7, L.fern.shade)
    else
      vline(hx, hy - 2, hy, L.soil.base) px(hx, hy - 3, L.fern.shade)
    end
  end
end
for _, r in ipairs({ { 14, 8 }, { 40, 10 }, { 110, 9 }, { 150, 12 }, { 192, 8 }, { 300, 8 }, { 352, 10 }, { 440, 12 }, { 466, 8 } }) do
  reedClump(r[1], yF(r[1]) + 1, r[2], 8, r[1], false)
end
-- far landing
do
  local d = poly{ { 234, 121 }, { 248, 121 }, { 250, 130 }, { 232, 130 } }
  rimOf(d, L.timber) part(d, L.board) F.planks(d, L.board, 3, false, 4)
  F.moss(d, .08, 102)
  for _, x in ipairs({ 233, 248 }) do vline(x, 131, 135, L.timber.deep) end
end
F.depth(2)
-- dark conifers on the far bank to the right of the landing, and a red pine
F.tree(292, 124, 50, 2)
F.tree(318, 123, 36, 1)
F.tree(352, 124, 54, 0)
F.tree(372, 123, 34, 6)
do -- the ferryman's log house: bark-shingle roof, lantern pole and a bell post
  local top, cx, wallM, roofM = F.building{ x0 = 164, x1 = 214, yb = 125, wh = 20, rh = 16, wall = L.timber, roof = L.roof2, shingle = true, noAttic = true, chimney = true, noFrame = true }
  F.logs(wallM, L.timber, top, 3)
  for y = top + 1, 123, 3 do F.logEnd(163, y, 1) F.logEnd(215, y, 1) end
  F.moss(roofM, .12, 103)
  F.door(184, 113, 192, 124, L.timber)
  F.window(171, 110, 176, 115, L.timber) F.window(201, 110, 206, 115, L.timber)
  F.smoke(205, 78, 6, .7, 2)
  -- a pair of antlers over the door
  F.sprite({ "b.b...b.b", ".bb...bb.", "..bbbbb.." }, 184, 105, { b = L.board.hi }, { rim = false })
  -- the far ferry bell post at the landing
  local bp = rect(222, 100, 223, 125):add(rect(218, 100, 230, 101)) rimOf(bp, L.timber) part(bp, L.timber, { nopop = true, noshade = true })
  local fb = poly{ { 226, 102 }, { 229, 102 }, { 230, 107 }, { 225, 107 } } c:rim(fb, L.timber.edge) part(fb, L.glow, { nopop = true })
  local lp = rect(256, 98, 257, 125) rimOf(lp, L.timber) part(lp, L.timber, { nopop = true, noshade = true })
  fill(rect(256, 98, 262, 98), L.timber.base)
  local lam = rect(259, 100, 263, 105) rimOf(lam, L.timber) fill(lam, L.glow.base) px(260, 101, L.glow.hi) vline(263, 101, 105, L.glow.shade)
  -- washing between the house and a pole
  local wp = rect(132, 106, 133, 124) rimOf(wp, L.timber) part(wp, L.timber, { nopop = true, noshade = true })
  F.washing(133, 106, 163, 108, { { "shirt", L.awnA }, { "sock", L.accent }, { "sheet", L.awnB } }, 3)
end
-- a small gnome waving from the far landing
F.gnome(242, 128, { small = true, hat = L.awnA, coat = L.leaf, arm = "up" })
do -- alders leaning over the water on the right: dark clumped crowns, grey trunks, hanging catkins
  local function alderTree(x, yb, h, lean, seed)
    local top = yb - floor(h * .6)
    local tr = line({ { x, yb }, { x + lean // 2, yb - h * .3 }, { x + lean, top } }, 2)
    tr:add(line({ { x + lean // 2, yb - floor(h * .32) }, { x + lean // 2 - 7, yb - floor(h * .5) } }, 1))
    rimOf(tr, L.iron) part(tr, L.iron, { nopop = true })
    tr:each(function(xx, yy) if hash(xx, yy // 2, seed) < .2 then px(xx, yy, L.iron.deep) elseif not tr:has(xx - 1, yy) then px(xx, yy, L.iron.hi) end end)
    local cx, cy = x + lean, yb - floor(h * .62)
    local m = F.crown(cx, cy, floor(h * .27), floor(h * .36), alder, seed)
    F.crown(cx - floor(h * .2), cy + floor(h * .16), floor(h * .15), floor(h * .18), alder, seed + 1)
    F.crown(cx + floor(h * .18), cy + floor(h * .12), floor(h * .15), floor(h * .2), alder, seed + 2)
    F.crown(cx + 1, cy - floor(h * .26), floor(h * .14), floor(h * .14), alder, seed + 3)
    -- catkins: little brown tassels hanging off the crown underside
    for k = 1, floor(h / 3) do
      local kx = cx - floor(h * .4) + floor(hash(k, 1, seed) * h * .8)
      local ky = cy + floor(h * .1) + floor(hash(k, 2, seed) * h * .2)
      if m:has(kx, ky) and hash(k, 3, seed) < .6 then vline(kx, ky, ky + 1, L.needle.shade) px(kx, ky + 2, L.needle.deep) end
    end
    return m
  end
  alderTree(452, 124, 46, -3, 121)
  alderTree(400, 125, 44, -4, 124)
  alderTree(426, 124, 56, -5, 127)
  -- their reflection in the water
  for x = 376, 462 do for y = yF(x) + 2, yF(x) + 12 do if river:has(x, y) and (y + x // 4) % 3 == 0 and hash(x, y, 27) < .7 then px(x, y, mix(alder.shade, Wt.base, .5)) end end end
end
-- reflections of the far bank in the water (broken dashes)
for x = 0, 479 do
  local y0 = yF(x) + 2
  local v = c:get(x, yF(x) - 6)
  if v and hash(x, 1, 31) < .55 then
    for y = y0, y0 + 5, 2 do if river:has(x, y) and hash(x, y, 32) < .6 then px(x, y, mix(v, Wt.base, .55)) end end
  end
end
-- a grey heron fishing in the shallows under the alders
F.depth(3)
do
  local hx, hy = 378, 112
  F.sprite({
    "......kkkkkk......",
    "....kkkWWWWkk.....",
    "yyyyyyyWeWWk......",
    "......dWWWWd......",
    ".......WWWd.......",
    "......WWWd........",
    "......WWd.........",
    ".......WWd........",
    ".......WWWd.......",
    ".......WWkd.......",
    "......WkkGGGg.....",
    "....dGGGGGGGggg...",
    "...dkGGGGGGgggdd..",
    "...dGGGGGGggggdddd",
    "....gGGGGgggddddd.",
    ".....ggggggddd..d.",
    "......gdddd.......",
    ".......l.l........",
    ".......l.l........",
    ".......l.l........",
    ".......l.l........",
    ".......l.l........",
    ".......l.l........",
    ".......l.l........",
    ".......l.l........",
    "......ll.ll.......",
    "......l...l.......",
  }, hx, hy, { k = "#34363f", W = "#e2e4d8", d = "#5c6670", G = "#a8b0b6", g = "#7e8890", e = "#26262e", y = L.gold.base, l = L.gold.shade })
  for k = 0, 2 do hline(hx + 3 - k * 2, hx + 11 + k * 2, hy + 27 + k, k == 1 and Wt.shade or Wt.hi) end
end
F.depth(2)

---------------------------------------------------------------- mist lying over the far half of the river
for y = 125, 138 do
  local x = floor(hash(y, 3, 41) * 40)
  while x < 480 do
    local len = 10 + floor(hash(x, y, 42) * 26)
    if hash(x // 11, y, 43) < .42 - (y - 125) * .025 then
      for xx = x, x + len do if river:has(xx, y) and c:get(xx, y) and hash(xx, y, 44) < .8 then px(xx, y, mix(c:get(xx, y), L.mist2, .55)) end end
    end
    x = x + len + 8 + floor(hash(x, y, 45) * 30)
  end
end

---------------------------------------------------------------- left water: a far fishing boat drifting
F.depth(2)
do
  local x0, x1, y = 62, 100, 142
  local hull = poly{ { x0 - 3, y - 2 }, { x1 + 3, y - 2 }, { x1 - 3, y + 4 }, { x0 + 3, y + 4 } }
  F.gnome(78, y - 2, { small = true, hat = L.awnA, coat = L.roof, arm = "out", noShadow = true })
  rimOf(hull, L.timber) part(hull, L.accent, { nopop = true }) hline(x0, x1, y, L.awnB.base)
  for k = 0, 2 do hline(x0 + k * 3, x1 - k * 3, y + 6 + k * 2, Wt.shade) end
  fill(line({ { 88, y - 8 }, { 112, y - 22 } }), L.timber.deep)
  vline(112, y - 21, y + 6, L.awnB.shade) px(112, y + 6, L.awnA.base) hline(108, 116, y + 8, Wt.hi)
end

---------------------------------------------------------------- the near landing and its piles
F.depth(3)
local LY0, LY1 = 166, 180
do
  local deck = poly{ { F.xl(LY0) - 6, LY0 }, { F.xr(LY0) + 6, LY0 }, { F.xr(LY1) + 6, LY1 }, { F.xl(LY1) - 6, LY1 } }
  local face = rect(floor(F.xl(LY0)) - 6, LY0 - 3, floor(F.xr(LY0)) + 6, LY0 - 1)
  local piles = HP.mask()
  for _, x in ipairs({ floor(F.xl(LY0)) - 6, floor(F.xr(LY0)) + 4 }) do piles:add(rect(x, LY0 - 6, x + 2, LY0 + 6)) end
  rimOf(union(deck, face, piles), L.timber)
  part(piles, L.timber, { nopop = true, noshade = true })
  F.moss(piles, .3, 104)
  part(deck, L.board) F.planks(deck, L.board, 4, false, 9)
  -- moss creeping in from the deck edges, green slime on the wet face
  deck:each(function(x, y) if (y >= LY1 - 2 or abs(x - 240) > 14) and hash(x // 2, y, 105) < .3 then px(x, y, hash(x, y, 106) < .5 and L.moss.base or L.moss.shade) end end)
  part(face, L.timber, { nopop = true, noshade = true })
  face:each(function(x, y) if y == LY0 - 1 and hash(x, y, 107) < .5 then px(x, y, L.moss.shade) end end)
  for x = floor(F.xl(LY0)) - 5, floor(F.xr(LY0)) + 5, 7 do px(x, LY0 - 2, L.iron.hi) end
  for _, x in ipairs({ floor(F.xl(LY0)) - 6, floor(F.xr(LY0)) + 4 }) do hline(x - 2, x + 4, LY0 + 7, Wt.hi) fill(rect(x, LY0 - 7, x + 2, LY0 - 7), L.moss.hi) end
end

---------------------------------------------------------------- the ferry raft (centre hero)
local RX0, RX1, RY0, RY1 = 270, 366, 137, 152
local FY = RY1 - 6 -- where figures stand: the front of the deck stays visible
local function hen(x0, y0)
  F.sprite({
    "..........RR.....",
    ".........RRr.....",
    "........HRRr.....",
    ".......HRRRr.....",
    ".......RRRRr.....",
    "......HRRRRRr....",
    "......RRRRRRr....",
    ".....HRRRRRRRr...",
    "....bbbbbbbbbbb..",
    ".....WWWWWW......",
    "....WWeWWWWW.....",
    "..yyWWWWWWWW.....",
    ".yYYkWWWWWWw.....",
    "...kkWWWWWWw...ww",
    "....kWWWWWWw..wWw",
    ".....WWWWWWWwwWWw",
    "....WWWWWWWWWWWWs",
    "....WWwwwWWWWWWWs",
    "....WWWwwwwWWWWs.",
    ".....WWWWwwwWWss.",
    "......sWWWWWsss..",
    "........l...l....",
    "........l...l....",
    ".......ll..ll....",
  }, x0, y0, { R = L.awnA.base, r = L.awnA.shade, H = L.awnA.hi, b = L.gold.hi, W = "#fff6e0", w = L.awnB.base, s = L.awnB.shade,
    y = L.gold.base, Y = L.gold.shade, k = L.apple.base, e = L.timber.edge, l = L.gold.shade })
end
do
  -- the raft's broken reflection under it (logs and figures as dark dashes) and a wider bow wave
  for x = RX0, RX1 do for y = RY1 + 5, RY1 + 14 do
    if river:has(x, y) and (y % 2 == 0) and hash(x // 2, y, 41) < .55 - (y - RY1) * .03 then px(x, y, mix(L.timber.shade, Wt.base, .45)) end
  end end
  for k = 0, 2 do px(RX0 - 3 - k, RY0 + 6 + k * 3, GLINT) hline(RX0 - 6 - k * 3, RX0 - 3 - k * 2, RY0 + 8 + k * 3, Wt.hi) end
  -- wake and ripples around the raft
  for k = 0, 3 do hline(RX0 - 8 - k * 5, RX0 - 2 - k * 2, RY1 + 6 + k * 2, Wt.hi) hline(RX1 + 2 + k * 2, RX1 + 8 + k * 5, RY1 + 6 + k * 2, Wt.hi) end
  for x = RX0 - 2, RX1 + 2 do if (x // 3) % 2 == 0 then px(x, RY1 + 5, Wt.deep) px(x, RY1 + 6, Wt.shade) end end
  local deck = poly{ { RX0 + 4, RY0 }, { RX1 - 4, RY0 }, { RX1, RY1 }, { RX0, RY1 } }
  local face = rect(RX0, RY1 + 1, RX1, RY1 + 4)
  -- rail: posts at the corners and a rope between
  local posts = HP.mask()
  for _, x in ipairs({ RX0 + 1, RX1 - 2 }) do posts:add(rect(x, RY1 - 9, x + 1, RY1)) end
  for _, x in ipairs({ RX0 + 5, RX1 - 6 }) do posts:add(rect(x, RY0 - 8, x + 1, RY0)) end
  rimOf(union(deck, face), L.timber)
  part(deck, L.board) F.planks(deck, L.board, 5, true, 17)
  -- weathered, mossy planks: grey streaks, moss in the seams and at the wet edges
  deck:each(function(x, y)
    local v = hash(x // 5, y // 3, 108)
    if v < .22 then px(x, y, ((x % 5) == 0) and L.timber.shade or L.timber.hi) end
    if (x % 5 == 0 or y >= RY1 - 1) and hash(x, y, 109) < .45 then px(x, y, hash(x, y, 110) < .5 and L.moss.base or L.moss.shade) end
  end)
  hline(RX0 + 4, RX1 - 4, RY0, L.board.hi)
  part(face, L.timber, { nopop = true })
  F.moss(face, .2, 111)
  -- log ends along the face
  for x = RX0 + 2, RX1 - 2, 5 do fill(c:ellipse(x, RY1 + 2.5, 1.5, 1.5), L.board.base) px(x, RY1 + 2, L.board.hi) px(x + 1, RY1 + 3, L.board.shade) end
  -- far rail behind the cargo
  for x = RX0 + 6, RX1 - 6 do px(x, RY0 - 6 + floor(2 * sin((x - RX0) / (RX1 - RX0) * pi)), L.board.shade) end
  -- cargo: milk churns and a crate of apples at the back, a bundle of firewood
  F.crate(RX1 - 34, RY0 + 6, 12, 8, L.apple)
  for _, cx in ipairs({ RX0 + 9, RX0 + 16 }) do
    local ch = c:rrect(cx - 3, RY0 - 4, cx + 3, RY0 + 6, 2):add(rect(cx - 1, RY0 - 6, cx + 1, RY0 - 4))
    c:rim(ch, L.iron.edge) part(ch, L.iron) hline(cx - 3, cx + 3, RY0 - 1, L.iron.deep) px(cx - 2, RY0 - 3, L.iron.hi)
  end
  for k = 0, 2 do F.logEnd(RX1 - 18 + k * 4, RY0 + 4, 2) end
  F.logEnd(RX1 - 16, RY0, 2) F.logEnd(RX1 - 12, RY0, 2)
  -- the trunk the hen stands on
  local T0 = RX0 + 40
  local tk = rect(T0, RY0 + 1, T0 + 18, RY0 + 9)
  c:rim(tk, L.timber.edge) part(tk, L.awnA) hline(T0, T0 + 18, RY0 + 4, L.timber.deep) vline(T0 + 6, RY0 + 1, RY0 + 9, L.gold.shade) vline(T0 + 12, RY0 + 1, RY0 + 9, L.gold.shade)
  fill(rect(T0 + 8, RY0 + 4, T0 + 10, RY0 + 6), L.gold.base) px(T0 + 8, RY0 + 4, L.gold.hi)
  -- the traveller with a big bundle on a stick
  local gx = RX0 + 28
  fill(line({ { gx + 7, FY - 17 }, { gx - 9, FY - 23 } }), L.board.base)
  local bun = c:ellipse(gx - 11, FY - 23, 4, 4) c:rim(bun, L.timber.edge) part(bun, L.accent, { nopop = true })
  bun:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.awnB.hi) end end) px(gx - 11, FY - 27, L.accent.deep)
  F.gnome(gx, FY, { hat = L.lav, coat = L.roof, arm = "up", noShadow = true })
  -- QUIRK: the hen in the red gnome hat, riding on the trunk
  hen(T0 + 1, RY0 - 23)
  -- the ferryman, poling from the back right corner
  local _, fx, fy = F.gnome(RX1 - 14, FY, { hat = L.foliage, coat = L.accent, arm = "up", flip = false, noShadow = true, hatBand = L.gold.base })
  local pole = line({ { fx - 3, fy - 10 }, { fx + 14, RY1 + 16 } }, 1)
  fill(pole, L.board.shade) line({ { fx - 2, fy - 10 }, { fx + 15, RY1 + 16 } }):each(function(x, y) if y < RY1 + 4 then px(x, y, L.board.hi) end end)
  for k = 0, 2 do hline(fx + 10 - k * 3, fx + 18 + k * 3, RY1 + 17 + k * 2, Wt.hi) end
  -- near rail and posts in front of everyone
  part(posts, L.timber, { nopop = true, noshade = true })
  F.moss(posts, .25, 112)
  for x = RX0 + 2, RX1 - 2 do px(x, RY1 - 7 + floor(2 * sin((x - RX0) / (RX1 - RX0) * pi)), L.board.deep) end
end

---------------------------------------------------------------- near bank: gnome hauling the tow rope on the landing
F.depth(3)
do
  local _, hx, hy = F.gnome(244, 200, { hat = L.roof2, coat = L.board, arm = "up" })
  -- a thick 2 px laid rope (twist marks, a lit top strand, ink rim) from the raft's front post, sagging to the
  -- water and up into the hauler's hands, then down to the coil.
  local x0, y0 = RX0 + 2, RY1 - 8
  local pts = {}
  for xx = hx, x0 do local t = (xx - hx) / (x0 - hx) pts[#pts + 1] = { xx, floor(hy + (y0 - hy) * t + 9 * 4 * t * (1 - t) + .5) } end
  local rope = line(pts, 2)
  c:rim(rope, L.timber.edge)
  rope:each(function(x, y) local top = not rope:has(x, y - 1) px(x, y, top and L.board.hi or L.board.base) if (x + y) % 3 == 0 then px(x, y, L.board.shade) end end)
  for _, p in ipairs(pts) do if p[2] > yN(p[1]) - 3 and p[1] % 5 == 0 then px(p[1], p[2] + 2, GLINT) end end -- drips where it skims the water
  local coil = c:ellipse(232, 200, 6, 2) c:rim(coil, L.timber.edge) part(coil, L.board, { nopop = true }) c:ellipse(232, 200, 3, 1):edge():each(function(x, y) px(x, y, L.board.deep) end)
  local tail = line({ { hx - 1, hy + 1 }, { 236, 198 } }, 2) c:rim(tail, L.timber.edge) fill(tail, L.board.base) tail:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.board.shade) end end)
end

-- young spruces at the left of the near bank (behind the booth)
F.depth(3)
F.conifer(28, 196, 40, L.foliage2, 131)
F.conifer(104, 186, 26, L.foliage, 132)

DY = 10
---------------------------------------------------------------- near bank left: bell frame, ferry sign, booth, bench, rowboat
do -- the ferry bell on a frame under a little bark roof
  local fr = rect(186, 150, 187, 196):add(rect(206, 150, 207, 196)):add(rect(183, 148, 210, 150))
  F.shadow(186, 208, 197, 6, 3)
  rimOf(fr, L.timber) part(fr, L.timber, { nopop = true, noshade = true }) hline(183, 210, 148, L.timber.hi)
  F.moss(rect(186, 186, 187, 196):add(rect(206, 186, 207, 196)), .4, 113)
  local roofb = poly{ { 181, 148 }, { 196, 140 }, { 212, 148 } } rimOf(roofb, L.roof2) part(roofb, L.roof2, { nopop = true })
  F.courses(roofb, 140, 3, 4, L.roof2) F.moss(roofb, .2, 114)
  vline(196, 151, 153, L.iron.shade)
  local bell = poly{ { 193, 154 }, { 199, 154 }, { 201, 163 }, { 203, 165 }, { 189, 165 }, { 191, 163 } }:add(c:ellipse(196, 155, 3, 2))
  c:rim(bell, L.timber.edge) part(bell, L.gold) vline(193, 156, 163, L.gold.hi) hline(190, 202, 164, L.gold.shade)
  fill(rect(195, 166, 197, 167), L.iron.base)
  fill(line({ { 197, 167 }, { 199, 180 } }), L.board.shade)
end
do -- the ferry sign: a painted raft, a pine and a wavy river
  local post = rect(170, 168, 171, 200)
  local bd = rect(156, 152, 185, 168)
  rimOf(union(post, bd), L.timber) part(post, L.timber, { nopop = true }) part(bd, L.board, { nopop = true })
  c:edgeIn(bd, L.board.deep)
  for x = 159, 182 do px(x, 164 + floor(sin(x / 2) + .5), L.water.base) px(x, 165 + floor(sin(x / 2) + .5), L.water.shade) end
  fill(rect(162, 160, 180, 162), L.timber.base) hline(162, 180, 160, L.board.hi)
  vline(166, 155, 159, L.timber.edge) vline(176, 155, 159, L.timber.edge) fill(rect(169, 155, 173, 159), L.awnA.base) -- passengers on the painted raft
  fill(line({ { 180, 154 }, { 183, 158 } }), L.timber.deep)
  F.sprite({ ".g.", "ggg", ".g.", "ggg", ".t." }, 158, 154, { g = L.foliage2.shade, t = L.timber.shade }, { rim = false })
  F.moss(rect(170, 192, 171, 200), .4, 115)
end
F.depth(3)
do -- the log ticket booth with a gnome in the hatch, a mossy bark-shingle roof
  local wall = rect(38, 168, 92, 200)
  local roof = poly{ { 32, 170 }, { 65, 146 }, { 98, 170 } }:add(rect(32, 168, 98, 171))
  F.shadow(40, 92, 200, 10, 4)
  rimOf(union(wall, roof), L.timber)
  part(wall, L.timber) F.logs(wall, L.timber, 168, 3)
  for y = 169, 199, 3 do F.logEnd(38, y, 1) F.logEnd(92, y, 1) end
  part(roof, L.roof2, { sep = true }) F.courses(roof, 146, 3, 5, L.roof2)
  F.moss(roof, .16, 116)
  line({ { 32, 170 }, { 65, 146 } }):each(function(x, y) px(x, y, L.roof2.hi) end)
  -- hatch with awning
  local hatch = rect(50, 178, 80, 192)
  fill(hatch, L.soil.deep) c:edgeIn(hatch, L.timber.hi)
  fill(rect(51, 179, 56, 183), L.glow.shade) px(52, 180, L.glow.base) -- a lamp lit inside
  F.gnome(65, 198, { hat = L.awnA, coat = L.accent, arm = "out", noShadow = true })
  local sill = rect(48, 192, 82, 194) rimOf(sill, L.timber) part(sill, L.board, { nopop = true })
  fill(rect(76, 189, 78, 191), L.awnB.hi) px(77, 189, L.awnA.base) -- a ticket
  local aw = poly{ { 46, 172 }, { 84, 172 }, { 88, 178 }, { 42, 178 } }
  rimOf(aw, L.awnA) fill(aw, L.awnA.base)
  aw:each(function(x, y) if ((x - 42) // 5) % 2 == 1 then px(x, y, L.awnB.base) end if y == 178 then px(x, y, ((x // 3) % 2 == 0) and L.awnA.deep or L.awnA.shade) end end)
  hline(46, 84, 172, L.awnA.hi)
  F.window(86, 158, 88, 161, L.timber)
  -- a pine cone plaque over the hatch
  F.sprite({ ".s.", "sSs", "SsS", "sSs", ".S." }, 64, 160, { s = L.soil.shade, S = L.soil.base })
end
do -- bench with two waiting travellers and their luggage
  local _, ax, ay = F.gnome(112, 214, { hat = L.roof, coat = L.lav, arm = "hold", noShadow = true })
  F.gnome(134, 215, { hat = L.accent, coat = L.awnA, flip = true, noShadow = true })
  local seat = rect(100, 207, 146, 209)
  local legs = rect(103, 210, 104, 218):add(rect(142, 210, 143, 218))
  F.shadow(102, 146, 219, 8, 3)
  rimOf(union(seat, legs), L.timber) part(legs, L.timber, { nopop = true, noshade = true }) part(seat, L.board, { nopop = true }) hline(100, 146, 207, L.board.hi)
  -- luggage: a round-lid trunk and a carpet bag
  local tr = c:rrect(150, 204, 168, 218, 3):clip(rect(150, 204, 168, 218))
  F.shadow(150, 168, 219, 5, 2)
  rimOf(tr, L.timber) part(tr, L.redbark) hline(150, 168, 209, L.iron.base) vline(155, 204, 218, L.iron.shade) vline(163, 204, 218, L.iron.shade) px(159, 211, L.glow.hi)
  local bag = c:rrect(152, 222, 166, 232, 3) rimOf(bag, L.timber) part(bag, L.lav)
  bag:each(function(x, y) if (x + y) % 4 == 0 then px(x, y, L.lav.hi) end end)
  fill(c:ellipse(159, 221, 3, 2):cut(c:ellipse(159, 221, 1, 1)):clip(rect(150, 218, 168, 221)), L.timber.base)
end
do -- a rowboat pulled up on the mud, oars across it
  local y = 228
  local hull = poly{ { 18, y - 4 }, { 24, y }, { 76, y + 2 }, { 82, y - 3 }, { 74, y + 9 }, { 26, y + 8 } }
  local inside = c:ellipse(50, y - 1, 26, 2)
  F.shadow(24, 78, y + 10, 6, 3)
  rimOf(union(hull, inside), L.timber)
  part(hull, L.accent) hline(24, 76, y + 4, L.awnB.base) hline(26, 74, y + 5, L.awnB.shade)
  hull:each(function(x, y2) if y2 >= y + 6 and hash(x // 2, y2, 117) < .35 then px(x, y2, L.moss.shade) end end)
  fill(inside, L.timber.shade) c:edgeIn(inside, L.board.base)
  fill(line({ { 30, y - 5 }, { 74, y + 1 } }), L.board.base) fill(rect(72, y - 1, 78, y + 1), L.board.base)
end
DY = 0
-- near reeds: thick cattail beds on both sides of the landing
reedClump(214, yN(214) + 3, 14, 22, 3, true)
reedClump(120, yN(120) + 3, 12, 18, 5, true)
reedClump(392, yN(392) + 3, 14, 22, 7, true)
reedClump(452, yN(452) + 3, 10, 20, 9, true)
reedClump(20, yN(20) + 3, 8, 16, 11, true)

---------------------------------------------------------------- the river right: mallards, lily pads, a moored punt
F.depth(3)
DY = 8
for _, p in ipairs({ { 360, 168 }, { 376, 174 }, { 344, 176 }, { 412, 160 } }) do
  local pad = c:ellipse(p[1], p[2], 5, 2) fill(pad, L.leaf.base) px(p[1] - 3, p[2] - 1, L.leaf.hi) px(p[1] + 2, p[2], L.leaf.deep) px(p[1] + 3, p[2] - 1, Wt.base)
end
px(376, 172, L.awnB.hi) px(377, 172, L.gold.hi) px(376, 171, GLINT) -- a white water lily
local function duck(x, y, big)
  local m = big and c:ellipse(x, y, 5, 3):add(c:ellipse(x - 5, y - 4, 2, 2)) or c:ellipse(x, y, 2, 1):add(rect(x - 2, y - 2, x - 1, y - 1))
  c:rim(m, L.timber.edge) part(m, big and L.awnB or L.needle, { nopop = true })
  if big then
    fill(c:ellipse(x - 5, y - 4, 2, 2), L.foliage2.base) px(x - 6, y - 5, L.foliage2.hi) hline(x - 7, x - 3, y - 2, L.awnB.hi)
    fill(rect(x - 9, y - 4, x - 8, y - 3), L.gold.base) px(x - 6, y - 5, L.timber.edge) px(x + 4, y - 2, L.timber.deep) hline(x - 6, x + 6, y + 3, Wt.hi)
  else px(x - 3, y - 2, L.gold.shade) hline(x - 3, x + 3, y + 2, Wt.hi) end
end
duck(150, 140, true) duck(162, 144) duck(172, 142) duck(182, 146)
do -- a punt tied to a stake
  local y = 178
  local hull = poly{ { 420, y - 2 }, { 470, y - 2 }, { 466, y + 4 }, { 424, y + 4 } }
  rimOf(hull, L.timber) part(hull, L.board) hline(422, 468, y, L.board.deep)
  hull:each(function(x, y2) if y2 >= y + 2 and hash(x // 2, y2, 118) < .4 then px(x, y2, L.moss.shade) end end)
  for k = 0, 2 do hline(424 + k * 2, 466 - k * 2, y + 6 + k * 2, Wt.shade) end
  local st = rect(410, y - 12, 412, y + 6) rimOf(st, L.timber) part(st, L.timber, { nopop = true, noshade = true })
  F.moss(st, .3, 119)
  fill(line({ { 412, y - 8 }, { 422, y - 1 } }), L.board.shade)
end

---------------------------------------------------------------- near bank right: cargo waiting to cross, a gnome on a crate
F.depth(3)
do
  F.crate(300, 222, 18, 12, L.apple) F.crate(318, 222, 16, 12) F.crate(306, 209, 16, 10, L.produce)
  F.sack(342, 224, L.awnB, 7) F.sack(354, 226, L.board, 6)
  F.barrel(288, 224, L.timber, 12)
  local _, hx, hy = F.gnome(372, 236, { hat = L.lav, coat = L.leaf, arm = "out", flip = true })
  local ap = c:ellipse(hx - 1, hy - 2, 2, 2) c:rim(ap, L.timber.edge) part(ap, L.apple, { nopop = true }) px(hx - 1, hy - 5, L.leaf.base)
  -- a lantern on a post at the landing's right
  local lp = rect(280, 160, 281, 200) rimOf(lp, L.timber) part(lp, L.timber, { nopop = true, noshade = true })
  F.moss(rect(280, 190, 281, 200), .4, 120)
  local lam = rect(277, 152, 284, 160) rimOf(lam, L.timber) fill(lam, L.glow.base) fill(rect(278, 153, 280, 158), L.glow.hi) vline(284, 153, 160, L.glow.shade)
  fill(rect(276, 150, 285, 151), L.timber.base)
end
-- foreground: a wheelbarrow of firewood waiting for the ferry, mossy rocks, ferns and mushrooms
do
  local y = 250
  local tray = poly{ { 96, y - 12 }, { 132, y - 12 }, { 128, y - 2 }, { 100, y - 2 } }
  local legs = rect(102, y - 2, 103, y + 4):add(line({ { 132, y - 8 }, { 146, y - 2 } }, 2))
  local wh = c:ellipse(92, y, 5, 5)
  F.shadow(92, 132, y + 5, 8, 3)
  rimOf(union(tray, legs, wh), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true })
  part(tray, L.board) F.planks(tray, L.board, 5, true, 2)
  part(wh, L.timber, { nopop = true }) px(92, y, L.iron.hi) hline(88, 96, y, L.timber.deep)
  for k = 0, 3 do F.logEnd(104 + k * 7, y - 15, 3, k == 2 and L.redbark or nil) end
  for k = 0, 2 do F.logEnd(107 + k * 7, y - 21, 3, k == 1 and L.redbark or nil) end
  F.logEnd(111, y - 27, 3) F.logEnd(118, y - 27, 3, L.redbark)
end
F.moss(F.rock(160, 254, 9, 6), .3, 121) F.rock(172, 257, 5, 4)
F.moss(F.rock(70, 254, 6, 4), .3, 122)
for _, f in ipairs({ { 30, 216, 6 }, { 148, 246, 6 }, { 186, 242, 7 }, { 270, 214, 5 }, { 362, 214, 5 }, { 60, 262, 7 }, { 196, 262, 8 }, { 290, 250, 7 }, { 330, 258, 6 }, { 300, 236, 5 }, { 214, 218, 5 }, { 96, 224, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.mushroom(176, 250, L.apple, true) F.mushroom(181, 252, L.apple) F.mushroom(82, 258, L.needle, true) F.mushroom(268, 222, L.apple)

---------------------------------------------------------------- bank grass, a fisher gnome, a goose after the apple
DY = 0
F.depth(3)
-- sedge overhanging the near bank lip, with mossy pebbles in the wet mud
for x = 0, 479 do
  local yn = yN(x)
  if hash(x, 1, 91) < .45 and not F.roadM:has(x, yn + 1) and not (x > 190 and x < 290) then
    local h = 2 + floor(hash(x, 2, 91) * 4)
    vline(x, yn + 4 - h, yn + 4, L.fern.deep) px(x, yn + 4 - h, L.fern.base) if h > 3 then px(x, yn + 3 - h, L.fern.hi) end
  end
  if hash(x, 3, 91) < .05 then px(x, yn + 5, L.stone.base) px(x + 1, yn + 5, L.stone.shade) px(x, yn + 4, L.moss.hi) end
end
-- a fisher gnome on an upturned bucket at the right bank, rod out over the reeds, a catch in the creel
do
  local bk = poly{ { 410, 210 }, { 422, 210 }, { 420, 220 }, { 412, 220 } }
  F.shadowM(c:ellipse(418, 222, 10, 1))
  rimOf(bk, L.timber) part(bk, L.board) hline(410, 422, 213, L.iron.shade) hline(411, 421, 218, L.iron.shade)
  local _, hx, hy = F.gnome(416, 210, { hat = L.awnA, coat = L.wall2, arm = "up", flip = true, noShadow = true, hatBand = L.gold.base })
  local rod = line({ { hx, hy + 2 }, { 380, 176 } })
  fill(rod, L.timber.shade) px(380, 176, L.timber.deep)
  for y = 177, 190 do px(380 - floor((y - 177) * .2), y, L.awnB.shade) end
  px(377, 191, L.apple.base) px(377, 190, GLINT) hline(372, 382, 192, Wt.hi)
  -- creel with a fish tail sticking out
  local cr = c:rrect(428, 212, 442, 222, 2) rimOf(cr, L.timber) part(cr, L.needle)
  cr:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) end end)
  F.sprite({ "s..s", "sSSs", ".SS.", ".ss." }, 433, 206, { s = L.iron.hi, S = L.iron.base })
  F.mushroom(446, 220, L.apple, true) F.mushroom(450, 222, L.apple)
end
-- a goose stretching its neck at the gnome's apple
F.sprite({
  "..........kk.",
  ".........kWWo",
  "..........Ww.",
  "..........W..",
  ".........WW..",
  "........WW...",
  "..WWWWWWWw...",
  ".WWWWwwwww...",
  "WWWwwwwwws...",
  ".swwwwwss....",
  "...ss.ss.....",
  "....o..o.....",
}, 340, 228, { W = "#f2f0e2", w = L.awnB.base, s = L.awnB.shade, k = L.iron.deep, o = L.gold.base })

DY = 0
F.depth(0)
F.birds({ { 150, 58, 2 }, { 162, 52, 1 }, { 360, 46, 2 }, { 372, 52, 2 } })
-- fix-up: detail on the plain lower-right near bank
F.depth(3)
F.fern(300, 252, 5) F.fern(334, 262, 5, L.needle) F.fern(266, 262, 4) F.fern(368, 248, 4) F.fern(352, 258, 3, L.needle)
F.mushroom(318, 246, L.apple, true) F.mushroom(322, 248, L.apple) F.mushroom(284, 256, L.needle, true)
do -- a fallen branch with a mossy stub
  local br = line({ { 306, 262 }, { 326, 258 } }, 2)
  rimOf(br, L.timber) part(br, L.timber, { nopop = true, noshade = true }) F.moss(br, .35, 71)
  px(326, 257, L.timber.hi)
end
for _, p in ipairs({ { 290, 242 }, { 346, 240 }, { 276, 250 }, { 360, 262 } }) do
  px(p[1], p[2], L.soil.base) px(p[1] + 1, p[2], L.soil.shade) px(p[1], p[2] - 1, L.soil.hi) px(p[1] + 1, p[2] + 1, L.soil.deep)
end
fill(rect(340, 250, 344, 251), L.stone.base) hline(340, 344, 249, L.stone.edge) px(340, 250, L.stone.hi) hline(341, 344, 252, L.stone.shade)
F.finish()
