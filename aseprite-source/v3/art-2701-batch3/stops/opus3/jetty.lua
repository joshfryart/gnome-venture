-- jetty.lua : "Lakeside jetty" stop look, Maplewold (480x270 gate view). Opus second pass.
-- Read: the right half is a lake with a sandy shore; a plank jetty on piles runs out across it with a moored
-- rowboat, a lamp post and a gnome fishing off the end; a boathouse on stilts and a sail on the far water;
-- on the left a fisher's cottage, a net drying frame with cork floats, a fish rack, an upturned boat being
-- tarred, creels. Quirk: a heron helping itself to the fish bucket.
-- opus3 richness pass: the lake gets depth (pale far water, sandy shallows, deeper near water), lit ripple pairs,
-- reflections, glints, a leaping fish and gulls; deck planks; 28 px gnomes; a cat eyeing the fish basket; the heron is
-- now a big readable bird (crest, striped neck, fish dangling over the bucket).
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/opus3/"
local F = dofile(DIR .. "_frame.lua").build{ name = "jetty", out = DIR, farTrees = { 24, 52, 120, 196, 290, 352, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local W = L.water

---------------------------------------------------------------- the lake
local lake = poly{ { 266, 113 }, { 479, 113 }, { 479, 228 }, { 372, 228 }, { 350, 220 }, { 326, 202 }, { 304, 176 }, { 288, 150 }, { 276, 130 } }
local beach = lake:grow(4):cut(lake):clip(rect(0, 114, 479, 269))
beach:each(function(x, y) px(x, y, hash(x, y, 5) < .2 and L.plaster.shade or L.plaster.base) end)
lake:edge():each(function(x, y) if y > 114 then px(x, y, L.plaster.hi) end end)
local mix = F.mix
local shallowC = mix(W.hi, L.plaster.base, .4)
lake:shrink(1):each(function(x, y)
  local d = y - 113
  local h
  if d < 4 then h = W.hi
  elseif d < 16 then h = hash(x // 7, y, 14) < .55 and W.hi or mix(W.hi, W.base, .5)
  elseif d < 55 then h = W.base
  elseif d < 85 then h = hash(x // 6, y // 2, 15) < .55 and W.base or mix(W.base, W.shade, .5)
  else h = mix(W.base, W.shade, .5) end
  if not lake:has(x - 4, y) or not lake:has(x, y + 4) or not lake:has(x + 3, y + 3) then h = shallowC end
  px(x, y, h)
end)
-- reflection of the far hills along the horizon
for x = 268, 478 do
  local hgt = floor((113 - F.fFar(x)) * .35)
  for y = 114, 114 + hgt do if lake:has(x, y) then px(x, y, y == 114 + hgt and "#b4d2cc" or "#c6dccc") end end
end
-- lit ripple pairs (cream-blue crest over a shade trough), longer and wider apart nearer
for y = 118, 226 do
  local d = y - 112
  local gap = 2 + d // 18
  if y % gap == 0 then
    local len = 2 + d // 9
    local x = 268 + floor(hash(y, 1, 13) * 30)
    while x < 478 do
      if hash(x // 9, y, 16) < .5 then
        for xx = x, x + len do if lake:has(xx, y) and lake:has(xx, y + 1) and px then px(xx, y, W.hi) if d > 30 then px(xx, y + 1, W.shade) end end end
      end
      x = x + len + 6 + floor(hash(x, y, 17) * 18)
    end
  end
end
for i = 0, 40 do local x, y = 276 + floor(hash(i, 1, 18) * 200), 120 + floor(hash(i, 2, 18) * 100) if lake:has(x, y) then px(x, y, "#fff0d0") px(x + 1, y, W.hi) end end
-- a leaping fish over its ring
do
  local fx, fy = 362, 154
  c:ellipse(fx, fy + 6, 9, 2):edge():each(function(x, y) px(x, y, W.hi) end)
  c:ellipse(fx, fy + 6, 13, 3):edge():each(function(x, y) if (x // 2) % 2 == 0 then px(x, y, W.hi) end end)
  F.sprite({ "...ff.", ".fffff", "fGGGe.", ".ff...", "f....." }, fx - 3, fy - 4, { f = L.stone.shade, G = L.stone.hi, e = L.timber.edge })
  for _, d in ipairs({ { -6, 2 }, { 5, 3 }, { -4, -1 } }) do px(fx + d[1], fy + d[2], W.hi) end
end
-- lily pads in the shallows by the reeds
for _, p in ipairs({ { 312, 168 }, { 322, 182 }, { 336, 196 } }) do
  local pad = c:ellipse(p[1], p[2], 4, 2) fill(pad, L.leaf.base) px(p[1] - 2, p[2] - 1, L.leaf.hi) px(p[1] + 1, p[2], L.leaf.deep) px(p[1] + 2, p[2] - 1, W.base)
end
F.depth(1)

---------------------------------------------------------------- far water: sail boat and a boathouse on stilts
local function sail(x, y)
  local hull = poly{ { x - 8, y }, { x + 8, y }, { x + 5, y + 3 }, { x - 5, y + 3 } }
  local s1 = poly{ { x, y - 1 }, { x, y - 16 }, { x + 8, y - 1 } }
  local s2 = poly{ { x - 1, y - 1 }, { x - 1, y - 12 }, { x - 7, y - 1 } }
  rimOf(union(hull, s1, s2), L.timber)
  part(hull, L.awnA, { nopop = true }) fill(s1, L.awnB.base) fill(s2, L.awnB.shade) vline(x, y - 16, y, L.timber.base)
  for k = 1, 3 do hline(x - 6 + k, x + 6 - k, y + 4 + k * 2, W.shade) end
end
sail(318, 124)
local function boathouse()
  local top = F.building{ x0 = 388, x1 = 444, yb = 140, wh = 26, rh = 20, wall = L.timber, roof = L.roof2, noShadow = true, noFrame = true, noAttic = true }
  F.window(424, 120, 430, 125, L.board)
  F.courses(rect(390, 115, 442, 138), 115, 4, 52, L.timber)
  -- big water door
  local d = rect(396, 124, 416, 140) fill(d, L.soil.deep) fill(rect(398, 134, 414, 140), W.deep)
  hline(396, 416, 124, L.timber.hi)
  local piles = HP.mask()
  for x = 390, 442, 8 do piles:add(rect(x, 141, x + 1, 150)) end
  rimOf(piles, L.timber) part(piles, L.timber, { nopop = true, noshade = true })
  for x = 390, 442, 8 do for y = 152, 160, 2 do px(x, y, W.shade) end end
  for y = 152, 158, 2 do hline(392, 440, y, (y % 4 == 0) and W.shade or W.base) end
end
boathouse()

---------------------------------------------------------------- the jetty, moored rowboat, lamp post, fisher gnome
local function rowboat(x0, x1, y)
  local hull = poly{ { x0 - 3, y - 2 }, { x0, y }, { x1, y }, { x1 + 3, y - 2 }, { x1 - 5, y + 8 }, { x0 + 6, y + 8 } }
  local inside = c:ellipse((x0 + x1) / 2, y - 2, (x1 - x0) / 2 - 1, 2)
  rimOf(union(hull, inside), L.timber)
  part(hull, L.accent) hline(x0 + 2, x1 - 2, y + 3, L.awnB.base) hline(x0 + 4, x1 - 4, y + 4, L.awnB.shade)
  fill(inside, L.timber.shade) c:edgeIn(inside, L.board.base)
  vline(x0 + 16, y - 4, y, L.board.hi) vline(x1 - 16, y - 4, y, L.board.hi)
  fill(line({ { x0 + 8, y - 2 }, { x1 + 6, y + 6 } }), L.board.shade) fill(rect(x1 + 4, y + 5, x1 + 8, y + 7), L.board.base)
  for k = 0, 3 do hline(x0 + 6 + k, x1 - 6 - k, y + 9 + k * 2, W.shade) end
end
F.depth(3)
local deck = rect(300, 178, 470, 185)
local face = rect(300, 186, 470, 188)
local piles = HP.mask()
for x = 312, 466, 18 do piles:add(rect(x, 189, x + 2, 206)) end
for x = 312, 466, 18 do for y = 208, 220, 3 do px(x, y, W.deep) px(x + 1, y + 1, W.shade) end end
rimOf(union(deck, face, piles), L.timber)
part(piles, L.timber, { nopop = true, noshade = true })
for x = 312, 466, 18 do hline(x, x + 2, 203, W.hi) end
part(deck, L.board)
F.planks(deck, L.board, 5, true, 21)
hline(300, 470, 178, L.board.hi)
-- reflections of the piles and the deck shadow on the water
for x = 300, 470 do if (x // 3) % 2 == 0 then px(x, 189, W.shade) end end
part(face, L.timber, { nopop = true })
for x = 302, 470, 10 do px(x, 187, L.iron.hi) end
rowboat(368, 422, 212)
-- mooring rope
fill(line({ { 366, 210 }, { 360, 189 } }), L.board.shade)
-- lamp post at the end
local lp = rect(460, 140, 461, 177) rimOf(lp, L.timber) part(lp, L.timber, { nopop = true, noshade = true })
local arm = rect(452, 140, 461, 141) fill(arm, L.timber.base)
local lam = rect(450, 143, 455, 150) rimOf(lam, L.timber) fill(lam, L.glow.base) px(451, 144, L.glow.hi) vline(455, 144, 150, L.glow.shade)
-- fisher gnome on a crate, rod out over the water
F.crate(424, 177, 12, 6)
local _, fhx, fhy = F.gnome(430, 171, { hat = L.roof, coat = L.awnA, arm = "out", noShadow = true })
fill(line({ { fhx, fhy }, { 448, 152 }, { 452, 146 } }), L.timber.deep)
vline(452, 147, 176, L.awnB.shade) vline(452, 189, 213, L.awnB.shade) fill(rect(451, 213, 453, 215), L.awnA.base) px(451, 213, L.awnA.hi)
for k = 0, 2 do hline(448 - k * 2, 456 + k * 2, 217 + k * 2, W.hi) end
F.barrel(316, 177, L.timber, 9)
F.crate(328, 177, 12, 7, L.water)

---------------------------------------------------------------- shore wedge: heron at the fish bucket (quirk), rope, anchor
local function heron(x, yb)
  local legs = rect(x, yb - 10, x, yb):add(rect(x + 3, yb - 10, x + 3, yb))
  local body = c:ellipse(x + 2, yb - 13, 6, 4)
  local neck = line({ { x - 2, yb - 15 }, { x - 5, yb - 22 }, { x - 3, yb - 27 } }, 2)
  local head = c:ellipse(x - 3, yb - 28, 2, 2)
  local sil = union(body, neck, head)
  rimOf(sil, L.stone) fill(legs, L.roof.deep)
  part(body, L.stone) part(neck, L.awnB, { nopop = true }) part(head, L.awnB, { nopop = true })
  hline(x - 1, x + 7, yb - 11, L.stone.deep)
  fill(line({ { x - 5, yb - 28 }, { x - 11, yb - 25 } }), L.roof.base)
  px(x - 3, yb - 29, L.timber.edge) hline(x - 4, x, yb - 30, L.stone.deep)
  -- a fish in its beak
  fill(c:ellipse(x - 12, yb - 23, 3, 1), L.water.hi) px(x - 15, yb - 24, L.water.shade) px(x - 15, yb - 22, L.water.shade)
end
local bucket = poly{ { 304, 252 }, { 318, 252 }, { 316, 264 }, { 306, 264 } }
rimOf(bucket, L.timber) part(bucket, L.board) hline(304, 318, 255, L.iron.shade) hline(305, 317, 261, L.iron.shade)
for k = 0, 3 do local fx = 306 + k * 3 fill(rect(fx, 248 - (k % 2), fx + 1, 252), W.hi) px(fx, 248 - (k % 2), W.shade) end
F.shadowM(c:ellipse(294, 263, 10, 1))
F.sprite({
  ".............kkkk...............",
  "...........kkwwwwk..............",
  "..............wwwwwyyyy.........",
  "..............wwwewyyyyyyy......",
  "...............wwwwYYYYYYYYYff..",
  "...............wwww........fFff.",
  "...............wwww.........ff..",
  "..............wwww..............",
  ".............wwww...............",
  "............wwwkw...............",
  "............wwww................",
  "...........wwwkw................",
  "...........wwww.................",
  "...........wwww.................",
  ".....GGGGGgwwww.................",
  "...GGGGgggggwww.................",
  "..GGggggggggggw.................",
  ".Gggggggdddgggg.................",
  ".gggggdddddggggg................",
  "kgggddddddddgggg................",
  "kkggdddDDddddggd................",
  ".kkgdddDDDdddddd................",
  "..kkddDDDDDdddd.................",
  "...kkdDDDDDddd..................",
  ".....DDDDDDdd...................",
  "........l..l....................",
  "........l..l....................",
  "........l..l....................",
  "........l..l....................",
  "........l..l....................",
  "........l..l....................",
  ".......ll.ll....................",
  "......l.l.l.l...................",
}, 284, 230, { k = "#4a3a4a", w = L.awnB.hi, e = L.timber.edge, y = L.roof.hi, Y = L.roof.shade, f = W.hi, F = W.shade,
  G = L.stone.hi, g = L.stone.base, d = L.stone.shade, D = L.stone.deep, l = L.roof.deep })
-- coiled rope + anchor
local coil = c:ellipse(354, 248, 9, 4) rimOf(coil, L.board) part(coil, L.board) fill(c:ellipse(354, 248, 4, 1), L.board.deep)
for k = 0, 2 do c:ellipse(354, 248, 8 - k * 2, 3 - k // 2):edge():each(function(x, y) if y > 247 then px(x, y, L.board.shade) end end) end
local anc = rect(336, 230, 337, 244):add(line({ { 330, 240 }, { 336, 245 }, { 343, 240 } }, 2)):add(rect(333, 232, 340, 233))
rimOf(anc, L.iron) part(anc, L.iron, { nopop = true }) fill(c:ellipse(336, 228, 2, 2):cut(c:ellipse(336, 228, 1, 1)), L.iron.base)

---------------------------------------------------------------- left: fisher cottage, fish rack
F.depth(1)
F.tree(84, 128, 38, 3)
F.building{ x0 = 20, x1 = 70, yb = 136, wh = 32, rh = 22, wall = L.plaster, roof = L.roof, chimney = true }
F.window(26, 112, 32, 118, L.timber) F.door(48, 122, 55, 135, L.accent)
F.smoke(61, 86, 6, .5, 2)
-- a fish-shaped sign on the cottage
local fs = c:ellipse(37, 128, 6, 3):add(poly{ { 42, 128 }, { 47, 124 }, { 47, 132 } })
rimOf(fs, L.accent) part(fs, L.accent) px(33, 127, L.timber.edge)
local function fishRack(x0, x1, yb)
  local posts = rect(x0, yb - 22, x0 + 1, yb):add(rect(x1, yb - 22, x1 + 1, yb))
  local bar = rect(x0 - 2, yb - 22, x1 + 3, yb - 21)
  F.shadow(x0, x1, yb, 6, 3)
  rimOf(union(posts, bar), L.timber) part(posts, L.timber, { nopop = true, noshade = true }) part(bar, L.timber, { nopop = true, noshade = true })
  for x = x0 + 4, x1 - 2, 5 do
    vline(x, yb - 20, yb - 19, L.timber.edge)
    local fsh = poly{ { x - 1, yb - 18 }, { x + 2, yb - 18 }, { x + 2, yb - 9 }, { x, yb - 7 }, { x - 1, yb - 9 } }
    local tl = poly{ { x - 2, yb - 7 }, { x + 3, yb - 7 }, { x, yb - 9 } }
    fill(union(fsh, tl), ((x // 5) % 2 == 0) and L.stone.base or L.produce.shade) vline(x + 2, yb - 18, yb - 10, L.stone.deep) px(x, yb - 16, L.timber.edge)
  end
end
fishRack(96, 150, 140)
F.depth(3)

---------------------------------------------------------------- left hero: net drying frame with cork floats
local function netFrame(x0, x1, yt, yb)
  local posts = rect(x0, yt, x0 + 3, yb):add(rect(x1 - 3, yt, x1, yb)):add(rect((x0 + x1) // 2 - 1, yt, (x0 + x1) // 2 + 1, yb))
  local bar = rect(x0 - 3, yt, x1 + 3, yt + 3)
  F.shadow(x0, x1, yb, 14, 5)
  rimOf(union(posts, bar), L.timber)
  part(posts, L.timber, { nopop = true }) part(bar, L.timber, { nopop = true })
  -- drape: sag between posts
  local function sag(x) local t = ((x - x0) % ((x1 - x0) // 2)) / ((x1 - x0) // 2) return floor(yb - 14 - 10 * sin(t * pi)) end
  for x = x0 + 4, x1 - 4 do
    local y1 = sag(x)
    for y = yt + 4, y1 do
      local a, b = (x + y) % 5, (x - y) % 5
      if a == 0 or b == 0 then px(x, y, L.accent.shade) elseif hash(x, y, 2) < .08 then px(x, y, L.accent.base) end
    end
    px(x, y1, L.accent.deep)
    if x % 7 == 0 then fill(rect(x - 1, y1 + 1, x + 1, y1 + 3), L.awnA.base) px(x - 1, y1 + 1, L.awnA.hi) end
  end
end
netFrame(92, 192, 150, 214)
F.barrel(110, 222, L.timber, 11) F.barrel(124, 224, L.board, 9)
-- basket of fish
local bk = poly{ { 160, 214 }, { 182, 214 }, { 179, 224 }, { 163, 224 } }
rimOf(bk, L.board) part(bk, L.roof) bk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.roof.shade) end end)
for k = 0, 4 do local fx = 162 + k * 4 fill(c:ellipse(fx, 212, 2, 1), W.hi) px(fx + 2, 212, W.shade) end
-- oars leaning
fill(line({ { 194, 228 }, { 186, 176 } }, 2), L.board.base) fill(c:rrect(184, 168, 189, 182, 2), L.board.shade)
-- a tabby cat sitting by the basket, eyeing the fish
F.sprite({
  "o...o..",
  "oo.oo..",
  "ttttt..",
  "tetet..",
  "ttntt..",
  ".ttt...",
  ".tTtt..",
  "tTttt..",
  "tTTttt.",
  "tTttttt",
  "tttttt.",
  "wt.tw..",
}, 148, 212, { o = L.timber.edge, t = L.produce.shade, T = L.produce.deep, e = L.leaf.hi, n = L.apple.shade, w = L.awnB.hi })

---------------------------------------------------------------- bottom-left: upturned boat on trestles, tar pot, creels
local function upBoat()
F.tree(44, 206, 54, 6)
F.barrel(64, 210, L.timber, 10) F.barrel(76, 212, L.timber, 10) F.barrel(70, 201, L.board, 9)
  local pts = { { 24, 242 } }
  for x = 24, 136, 4 do pts[#pts + 1] = { x, 242 - floor(16 * sin((x - 20) / 120 * pi) ^ .6) - (x > 120 and (x - 120) // 2 or 0) } end
  pts[#pts + 1] = { 138, 230 } pts[#pts + 1] = { 132, 242 }
  local hull = poly(pts)
  local tre = rect(36, 242, 38, 256):add(rect(110, 240, 112, 256)):add(rect(30, 252, 44, 253)):add(rect(104, 252, 118, 253))
  F.shadow(26, 136, 258, 6, 3)
  rimOf(union(hull, tre), L.timber)
  part(tre, L.timber, { nopop = true, noshade = true })
  part(hull, L.awnA)
  hull:each(function(x, y)
    local k = 242 - floor(16 * sin((x - 20) / 120 * pi) ^ .6)
    if (y - k) % 5 == 4 then px(x, y, L.awnA.deep) end
    if x < 64 and y > k + 4 then px(x, y, (y - k) % 5 == 4 and L.timber.edge or L.timber.deep) end -- fresh tar
  end)
  hline(24, 132, 241, L.awnB.base) hline(24, 132, 242, L.timber.base)
  local pot = rect(56, 250, 64, 258) rimOf(pot, L.iron) part(pot, L.iron) hline(56, 64, 250, L.timber.edge)
  fill(line({ { 62, 250 }, { 68, 244 } }), L.board.base)
  local _, thx, thy = F.gnome(82, 266, { hat = L.leaf, coat = L.roof, arm = "out", flip = true })
  fill(line({ { thx, thy }, { thx - 6, thy - 3 } }), L.board.base) fill(rect(thx - 9, thy - 6, thx - 6, thy - 3), L.timber.edge) -- tar brush
end
upBoat()
F.tree(44, 206, 54, 6)
F.barrel(64, 210, L.timber, 10) F.barrel(76, 212, L.timber, 10) F.barrel(70, 201, L.board, 9)
local function creel(x, yb)
  local m = c:rrect(x - 7, yb - 10, x + 7, yb, 4)
  rimOf(m, L.board) part(m, L.board)
  m:each(function(xx, y) if (xx - x) % 3 == 0 or (y - yb) % 3 == 0 then px(xx, y, L.board.deep) end end)
  fill(c:ellipse(x, yb - 6, 2, 2), L.soil.deep)
end
creel(160, 262) creel(176, 262) creel(168, 251)
-- reeds at the waterline
for i = 0, 9 do local x = 300 + i * 3 + (i % 2) local y = 170 + i * 3 local h = 5 + floor(hash(i, 4, 3) * 6)
  vline(x, y - h, y, L.leaf.shade) if i % 3 == 0 then fill(rect(x, y - h - 1, x + 1, y - h + 1), L.timber.base) end end
-- signpost with a hanging fish board by the road
F.sign(206, 148, 18, 10, L.board)
F.depth(0)
F.birds({ { 360, 60, 3, L.awnB.hi }, { 376, 52, 2, L.awnB.hi }, { 300, 76, 2, L.awnB.hi }, { 150, 50, 2 } })
fill(c:ellipse(205, 153, 5, 2):add(poly{ { 209, 153 }, { 212, 150 }, { 212, 156 } }), L.accent.base) px(202, 152, L.timber.edge)
F.finish()
