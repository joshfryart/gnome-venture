-- ferry.lua : "Ferry crossing" stop look, Maplewold (480x270 gate view). Opus second pass (art-2701 batch 4).
-- Builds on ../haiku/ferry.lua. Shared frame: ../../../art-2701-batch3/stops/opus3/_frame.lua (read-only).
-- Read: a wide river runs across the whole view and the road stops at it on a plank landing. The ferry raft is the
-- centre hero, mid-river and coming in: a ferryman poles it, a traveller with a bundle and cargo ride it, and a gnome
-- on the landing hauls it in by the tow rope. Far bank: the road goes on from a far landing past the ferryman's house
-- (bell post, lantern), a weeping willow, washing, a gnome waving. Near bank: ferry bell on a frame, a painted ferry
-- sign, a ticket booth with a gnome in the hatch, a bench of waiting travellers, a beached rowboat, cargo, and thick
-- cattail reed beds on both banks. Quirk: a big white hen in a red gnome hat, riding the ferry on a trunk.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch4/stops/opus3/"
local F = dofile("/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/opus3/_frame.lua")
  .build{ name = "ferry", out = DIR, roadTop = 178, farTrees = { 30, 70, 120, 168, 330, 372, 446 },
    clouds = { { 96, 46, 40 }, { 290, 34, 50 }, { 420, 70, 28 }, { 196, 76, 24 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local mix = F.mix
local Wt = L.water
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
  for i = 0, 60 do local x, y = floor(hash(i, 1, 18) * 480), 126 + floor(hash(i, 2, 18) * 64) if river:has(x, y) and river:has(x + 1, y) then px(x, y, "#fff0d0") px(x + 1, y, Wt.hi) end end
  -- far bank: dark lip under the grass, then a pale sand line; near bank: wet mud then sand
  for x = 0, 479 do
    px(x, yF(x), Wt.deep) px(x, yF(x) + 1, Wt.shade)
    px(x, yF(x) - 1, L.plaster.base)
    local yn = yN(x)
    for k = 1, 4 do px(x, yn + k, k == 1 and L.soil.shade or (k == 2 and L.soil.base or (hash(x, k, 5) < .3 and L.plaster.shade or L.plaster.base))) end
    if hash(x, 9, 6) < .25 then px(x, yn + 4, L.plaster.hi) end
    px(x, yn, Wt.hi)
  end
end

---------------------------------------------------------------- far bank: road on, landing, ferry house, willow, cottage
F.depth(1)
F.drawRoad(113, 122)
F.tree(112, 122, 28, 5)
F.building{ x0 = 36, x1 = 80, yb = 122, wh = 13, rh = 11, wall = L.plaster, roof = L.roof, noFrame = true, noAttic = true, chimney = true }
F.window(44, 113, 48, 116, L.timber) F.window(68, 113, 72, 116, L.timber)
F.smoke(70, 94, 4, .6, 2)
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
  if near then c:rim(m, L.leaf.edge) end
  m:each(function(xx, yy)
    local t = (yb - yy) / hmax
    local hsh = hash(xx, yy, seed)
    local col = t > .6 and L.leaf.hi or (t > .25 and L.leaf.base or L.leaf.shade)
    if hsh < .22 then col = L.leaf.shade elseif hsh > .9 then col = L.roof.base end
    if yy >= yb - 1 then col = L.leaf.deep end
    px(xx, yy, col)
  end)
  for _, hd in ipairs(heads) do
    local hx, hy = hd[1], hd[2]
    if near then
      local cm = rect(hx - 1, hy - 5, hx + 1, hy) c:rim(cm, L.timber.edge)
      fill(cm, L.timber.base) vline(hx - 1, hy - 5, hy - 1, L.timber.hi) vline(hx + 1, hy - 4, hy, L.timber.deep) px(hx, hy - 6, L.leaf.shade) px(hx, hy - 7, L.leaf.shade)
    else
      vline(hx, hy - 2, hy, L.timber.base) px(hx, hy - 3, L.leaf.shade)
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
  for _, x in ipairs({ 233, 248 }) do vline(x, 131, 135, L.timber.deep) end
end
F.depth(2)
do -- the ferryman's house: shingle roof, lantern pole and a bell post
  F.building{ x0 = 164, x1 = 214, yb = 125, wh = 20, rh = 16, wall = L.wall2, roof = L.roof2, shingle = true, noAttic = true, chimney = true }
  F.door(184, 113, 192, 124, L.timber)
  F.window(171, 110, 176, 115, L.timber) F.window(201, 110, 206, 115, L.timber)
  F.smoke(205, 78, 6, .7, 2)
  -- the far ferry bell post at the landing
  local bp = rect(222, 100, 223, 125):add(rect(218, 100, 230, 101)) rimOf(bp, L.timber) part(bp, L.timber, { nopop = true, noshade = true })
  local fb = poly{ { 226, 102 }, { 229, 102 }, { 230, 107 }, { 225, 107 } } c:rim(fb, L.timber.edge) part(fb, L.glow, { nopop = true })
  local lp = rect(256, 98, 257, 125) rimOf(lp, L.timber) part(lp, L.timber, { nopop = true, noshade = true })
  fill(rect(256, 98, 262, 98), L.timber.base)
  local lam = rect(259, 100, 263, 105) rimOf(lam, L.timber) fill(lam, L.glow.base) px(260, 101, L.glow.hi) vline(263, 101, 105, L.glow.shade)
  -- washing between the house and a pole
  local wp = rect(132, 106, 133, 124) rimOf(wp, L.timber) part(wp, L.timber, { nopop = true, noshade = true })
  F.washing(133, 106, 163, 108, { { "shirt", L.accent }, { "sock", L.awnA }, { "sheet", L.awnB } }, 3)
end
-- a small gnome waving from the far landing
F.gnome(242, 128, { small = true, hat = L.awnA, coat = L.leaf, arm = "up" })
do -- the weeping willow, strands hanging into the water
  local tr = rect(424, 100, 428, 128)
  rimOf(tr, L.timber) part(tr, L.timber, { nopop = true })
  F.crown(426, 84, 30, 18, L.leaf, 21)
  for i = 0, 26 do
    local sx = 398 + i * 2 + floor(hash(i, 1, 22) * 2)
    local top = 86 + floor(abs(sx - 426) * .45)
    local bot = 120 + floor(hash(i, 2, 22) * 12)
    for y = top, bot do
      local xx = sx + floor((y - top) * .08)
      px(xx, y, (y + i) % 5 == 0 and L.leaf.hi or (i % 3 == 0 and L.leaf.shade or L.leaf.base))
    end
    if bot > yF(sx) then px(sx + 1, bot + 1, Wt.hi) end
  end
end
-- reflections of the far bank in the water (broken dashes)
for x = 0, 479 do
  local y0 = yF(x) + 2
  local v = c:get(x, yF(x) - 6)
  if v and hash(x, 1, 31) < .55 then
    for y = y0, y0 + 5, 2 do if river:has(x, y) and hash(x, y, 32) < .6 then px(x, y, mix(v, Wt.base, .55)) end end
  end
end

---------------------------------------------------------------- left water: a far fishing boat drifting
F.depth(2)
do
  local x0, x1, y = 62, 100, 142
  local hull = poly{ { x0 - 3, y - 2 }, { x1 + 3, y - 2 }, { x1 - 3, y + 4 }, { x0 + 3, y + 4 } }
  F.gnome(78, y - 2, { small = true, hat = L.roof, coat = L.awnA, arm = "out", noShadow = true })
  rimOf(hull, L.timber) part(hull, L.awnA, { nopop = true }) hline(x0, x1, y, L.awnB.base)
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
  part(deck, L.board) F.planks(deck, L.board, 4, false, 9)
  part(face, L.timber, { nopop = true, noshade = true })
  for x = floor(F.xl(LY0)) - 5, floor(F.xr(LY0)) + 5, 7 do px(x, LY0 - 2, L.iron.hi) end
  for _, x in ipairs({ floor(F.xl(LY0)) - 6, floor(F.xr(LY0)) + 4 }) do hline(x - 2, x + 4, LY0 + 7, Wt.hi) fill(rect(x, LY0 - 7, x + 2, LY0 - 7), L.timber.hi) end
end

---------------------------------------------------------------- the ferry raft (centre hero)
local RX0, RX1, RY0, RY1 = 270, 366, 138, 150
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
  }, x0, y0, { R = L.awnA.base, r = L.awnA.shade, H = L.awnA.hi, b = L.roof.hi, W = "#fff6e0", w = L.awnB.base, s = L.awnB.shade,
    y = L.roof.base, Y = L.roof.shade, k = L.apple.base, e = L.timber.edge, l = L.roof.shade })
end
do
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
  hline(RX0 + 4, RX1 - 4, RY0, L.board.hi)
  part(face, L.timber, { nopop = true })
  -- log ends along the face
  for x = RX0 + 2, RX1 - 2, 5 do fill(c:ellipse(x, RY1 + 2.5, 1.5, 1.5), L.board.base) px(x, RY1 + 2, L.board.hi) px(x + 1, RY1 + 3, L.board.shade) end
  -- far rail behind the cargo
  for x = RX0 + 6, RX1 - 6 do px(x, RY0 - 6 + floor(2 * sin((x - RX0) / (RX1 - RX0) * pi)), L.board.shade) end
  -- cargo: milk churns and a crate of apples at the back
  F.crate(RX1 - 34, RY0 + 6, 12, 8, L.apple)
  for _, cx in ipairs({ RX0 + 9, RX0 + 16 }) do
    local ch = c:rrect(cx - 3, RY0 - 4, cx + 3, RY0 + 6, 2):add(rect(cx - 1, RY0 - 6, cx + 1, RY0 - 4))
    c:rim(ch, L.iron.edge) part(ch, L.iron) hline(cx - 3, cx + 3, RY0 - 1, L.iron.deep) px(cx - 2, RY0 - 3, L.iron.hi)
  end
  -- the trunk the hen stands on
  local T0 = RX0 + 40
  local tk = rect(T0, RY0 + 1, T0 + 18, RY0 + 9)
  c:rim(tk, L.timber.edge) part(tk, L.awnA) hline(T0, T0 + 18, RY0 + 4, L.timber.deep) vline(T0 + 6, RY0 + 1, RY0 + 9, L.roof.shade) vline(T0 + 12, RY0 + 1, RY0 + 9, L.roof.shade)
  fill(rect(T0 + 8, RY0 + 4, T0 + 10, RY0 + 6), L.roof.base) px(T0 + 8, RY0 + 4, L.roof.hi)
  -- the traveller with a big bundle on a stick
  local gx = RX0 + 28
  fill(line({ { gx + 7, RY1 - 18 }, { gx - 9, RY1 - 24 } }), L.board.base)
  local bun = c:ellipse(gx - 11, RY1 - 24, 4, 4) c:rim(bun, L.timber.edge) part(bun, L.awnA, { nopop = true })
  bun:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.awnB.hi) end end) px(gx - 11, RY1 - 28, L.awnA.deep)
  F.gnome(gx, RY1 - 1, { hat = L.lav, coat = L.roof, arm = "up", noShadow = true })
  -- QUIRK: the hen in the red gnome hat, riding on the trunk
  hen(T0 + 1, RY0 - 23)
  -- the ferryman, poling from the back right corner
  local _, fx, fy = F.gnome(RX1 - 14, RY1 - 1, { hat = L.leaf, coat = L.accent, arm = "up", flip = false, noShadow = true, hatBand = L.roof.base })
  local pole = line({ { fx - 3, fy - 10 }, { fx + 14, RY1 + 16 } }, 1)
  fill(pole, L.board.shade) line({ { fx - 2, fy - 10 }, { fx + 15, RY1 + 16 } }):each(function(x, y) if y < RY1 + 4 then px(x, y, L.board.hi) end end)
  for k = 0, 2 do hline(fx + 10 - k * 3, fx + 18 + k * 3, RY1 + 17 + k * 2, Wt.hi) end
  -- near rail and posts in front of everyone
  part(posts, L.timber, { nopop = true, noshade = true })
  for x = RX0 + 2, RX1 - 2 do px(x, RY1 - 7 + floor(2 * sin((x - RX0) / (RX1 - RX0) * pi)), L.board.deep) end
  -- tow rope from the raft's front corner down to the landing
  
end

---------------------------------------------------------------- near bank: gnome hauling the rope on the landing
F.depth(3)
do
  local _, hx, hy = F.gnome(244, 200, { hat = L.roof2, coat = L.board, arm = "up" })
  -- tow rope from the raft's front corner, sagging over the water, into the hauler's hands and down to a coil
  local x0, y0 = RX0 + 2, RY1 + 3
  for xx = hx, x0 do local t = (xx - hx) / (x0 - hx) px(xx, floor(hy + (y0 - hy) * t + 5 * 4 * t * (1 - t) + .5), L.board.deep) end
  local coil = c:ellipse(232, 200, 6, 2) c:rim(coil, L.timber.edge) part(coil, L.board, { nopop = true }) c:ellipse(232, 200, 3, 1):edge():each(function(x, y) px(x, y, L.board.deep) end)
  fill(line({ { hx - 9, hy + 4 }, { 236, 199 } }), L.board.shade)
end

DY = 10
---------------------------------------------------------------- near bank left: bell frame, ferry sign, booth, bench, rowboat
do -- the ferry bell on a frame
  local fr = rect(186, 150, 187, 196):add(rect(206, 150, 207, 196)):add(rect(183, 148, 210, 150))
  F.shadow(186, 208, 197, 6, 3)
  rimOf(fr, L.timber) part(fr, L.timber, { nopop = true, noshade = true }) hline(183, 210, 148, L.timber.hi)
  local roofb = poly{ { 181, 148 }, { 196, 140 }, { 212, 148 } } rimOf(roofb, L.roof2) part(roofb, L.roof2, { nopop = true })
  vline(196, 151, 153, L.iron.shade)
  local bell = poly{ { 193, 154 }, { 199, 154 }, { 201, 163 }, { 203, 165 }, { 189, 165 }, { 191, 163 } }:add(c:ellipse(196, 155, 3, 2))
  c:rim(bell, L.timber.edge) part(bell, L.glow) vline(193, 156, 163, L.glow.hi) hline(190, 202, 164, L.glow.shade)
  fill(rect(195, 166, 197, 167), L.iron.base)
  fill(line({ { 197, 167 }, { 199, 180 } }), L.board.shade)
end
do -- the ferry sign: a painted raft and a wavy river
  local post = rect(170, 168, 171, 200)
  local bd = rect(156, 152, 185, 168)
  rimOf(union(post, bd), L.timber) part(post, L.timber, { nopop = true }) part(bd, L.board, { nopop = true })
  c:edgeIn(bd, L.board.deep)
  for x = 159, 182 do px(x, 164 + floor(sin(x / 2) + .5), L.water.base) px(x, 165 + floor(sin(x / 2) + .5), L.water.shade) end
  fill(rect(162, 160, 180, 162), L.timber.base) hline(162, 180, 160, L.board.hi)
  vline(166, 155, 159, L.timber.edge) vline(176, 155, 159, L.timber.edge) fill(rect(169, 155, 173, 159), L.awnA.base) -- passengers on the painted raft
  fill(line({ { 180, 154 }, { 183, 158 } }), L.timber.deep)
end
F.depth(3)
do -- the ticket booth with a gnome in the hatch
  local wall = rect(38, 168, 92, 200)
  local roof = poly{ { 32, 170 }, { 65, 146 }, { 98, 170 } }:add(rect(32, 168, 98, 171))
  F.shadow(40, 92, 200, 10, 4)
  rimOf(union(wall, roof), L.timber)
  part(wall, L.timber) F.planks(wall, L.timber, 4, true, 3)
  part(roof, L.roof2, { sep = true }) F.courses(roof, 146, 3, 5, L.roof2)
  line({ { 32, 170 }, { 65, 146 } }):each(function(x, y) px(x, y, L.roof2.hi) end)
  -- hatch with awning
  local hatch = rect(50, 178, 80, 192)
  fill(hatch, L.soil.deep) c:edgeIn(hatch, L.timber.hi)
  F.gnome(65, 198, { hat = L.awnA, coat = L.accent, arm = "out", noShadow = true })
  local sill = rect(48, 192, 82, 194) rimOf(sill, L.timber) part(sill, L.board, { nopop = true })
  fill(rect(76, 189, 78, 191), L.awnB.hi) px(77, 189, L.awnA.base) -- a ticket
  local aw = poly{ { 46, 172 }, { 84, 172 }, { 88, 178 }, { 42, 178 } }
  rimOf(aw, L.awnA) fill(aw, L.awnA.base)
  aw:each(function(x, y) if ((x - 42) // 5) % 2 == 1 then px(x, y, L.awnB.base) end if y == 178 then px(x, y, ((x // 3) % 2 == 0) and L.awnA.deep or L.awnA.shade) end end)
  hline(46, 84, 172, L.awnA.hi)
  F.window(86, 158, 88, 161, L.timber)
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
  rimOf(tr, L.timber) part(tr, L.timber) hline(150, 168, 209, L.iron.base) vline(155, 204, 218, L.iron.shade) vline(163, 204, 218, L.iron.shade) px(159, 211, L.glow.hi)
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

---------------------------------------------------------------- the river right: ducks, lily pads, a moored punt
F.depth(3)
DY = 8
for _, p in ipairs({ { 360, 168 }, { 376, 174 }, { 344, 176 }, { 412, 160 } }) do
  local pad = c:ellipse(p[1], p[2], 5, 2) fill(pad, L.leaf.base) px(p[1] - 3, p[2] - 1, L.leaf.hi) px(p[1] + 2, p[2], L.leaf.deep) px(p[1] + 3, p[2] - 1, Wt.base)
end
px(376, 172, L.awnA.hi) px(377, 172, L.awnA.base) px(376, 171, "#fff0d0")
local function duck(x, y, big)
  local m = big and c:ellipse(x, y, 5, 3):add(c:ellipse(x - 5, y - 4, 2, 2)) or c:ellipse(x, y, 2, 1):add(rect(x - 2, y - 2, x - 1, y - 1))
  c:rim(m, L.timber.edge) part(m, big and L.awnB or L.roof, { nopop = true })
  if big then fill(rect(x - 9, y - 4, x - 8, y - 3), L.roof.base) px(x - 6, y - 5, L.timber.edge) fill(c:ellipse(x - 5, y - 4, 1, 1), L.leaf.shade) hline(x - 6, x + 6, y + 3, Wt.hi)
  else px(x - 3, y - 2, L.roof.shade) hline(x - 3, x + 3, y + 2, Wt.hi) end
end
duck(150, 140, true) duck(162, 144) duck(172, 142) duck(182, 146)
do -- a punt tied to a stake
  local y = 178
  local hull = poly{ { 420, y - 2 }, { 470, y - 2 }, { 466, y + 4 }, { 424, y + 4 } }
  rimOf(hull, L.timber) part(hull, L.board) hline(422, 468, y, L.board.deep)
  for k = 0, 2 do hline(424 + k * 2, 466 - k * 2, y + 6 + k * 2, Wt.shade) end
  local st = rect(410, y - 12, 412, y + 6) rimOf(st, L.timber) part(st, L.timber, { nopop = true, noshade = true })
  fill(line({ { 412, y - 8 }, { 422, y - 1 } }), L.board.shade)
end

---------------------------------------------------------------- near bank right: cargo waiting to cross, a gnome on a crate
F.depth(3)
do
  F.crate(300, 222, 18, 12, L.produce) F.crate(318, 222, 16, 12) F.crate(306, 209, 16, 10, L.apple)
  F.sack(342, 224, L.awnB, 7) F.sack(354, 226, L.board, 6)
  F.barrel(288, 224, L.timber, 12)
  local _, hx, hy = F.gnome(372, 236, { hat = L.lav, coat = L.leaf, arm = "out", flip = true })
  local ap = c:ellipse(hx - 1, hy - 2, 2, 2) c:rim(ap, L.timber.edge) part(ap, L.apple, { nopop = true }) px(hx - 1, hy - 5, L.leaf.base)
  -- a lantern on a post at the landing's right
  local lp = rect(280, 160, 281, 200) rimOf(lp, L.timber) part(lp, L.timber, { nopop = true, noshade = true })
  local lam = rect(277, 152, 284, 160) rimOf(lam, L.timber) fill(lam, L.glow.base) fill(rect(278, 153, 280, 158), L.glow.hi) vline(284, 153, 160, L.glow.shade)
  fill(rect(276, 150, 285, 151), L.timber.base)
end
-- foreground: a wheelbarrow of pumpkins waiting for the ferry, a mooring post, pebbles
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
  for _, p in ipairs({ { 104, y - 15, 5 }, { 116, y - 16, 6 }, { 127, y - 14, 4 }, { 110, y - 22, 4 } }) do
    local pk = c:ellipse(p[1], p[2], p[3], p[3] - 1) c:rim(pk, L.timber.edge) part(pk, L.produce)
    for dx = -p[3] + 2, p[3] - 2, 3 do vline(p[1] + dx, p[2] - p[3] + 2, p[2] + p[3] - 2, L.produce.shade) end
    fill(rect(p[1], p[2] - p[3] - 1, p[1] + 1, p[2] - p[3]), L.leaf.shade)
  end
end
F.rock(160, 254, 9, 6) F.rock(172, 257, 5, 4)
F.rock(70, 254, 6, 4)

DY = 0
F.depth(0)
F.birds({ { 150, 58, 2 }, { 162, 52, 1 }, { 360, 46, 2 }, { 372, 52, 2, L.awnB.hi } })
F.finish()
