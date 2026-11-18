-- jetty.lua : "Lakeside jetty" stop look, TUNDRA (tundra_frost), 480x270 gate view.
-- Same composition as the Maplewold jetty (art-2701-batch3/stops/opus3/jetty.lua) and the forest jetty, re-cast as
-- a frozen-lake ICE-FISHING landing: right half: the lake frozen over: wind-polished blue ice and snow skiffs,
-- pressure cracks, a ridge of shoved ice blocks along the shore; a driftwood jetty on piles locked in the ice with
-- a rowboat frozen in beside it, a lamp post (a raven on its arm) and a gnome jigging through an augered hole off
-- the end. Out on the ice: a blue fishing shack on runners (stovepipe smoke) where the boathouse stood, little red
-- and yellow shacks far off, an ice yacht where the sail was, a dog sled team, tip-up flags over a row of holes,
-- a gnome on a bucket hauling an arctic char out of a hole (where the trout leapt). Shore: stacked ice blocks.
-- Left: the falu-red fisher's cottage under a snowy sod roof, a stockfish drying rack, the frosted net frame with
-- red floats and icicles, a box of red-bellied char with a husky eyeing it, the upturned boat under snow being
-- tarred, wicker creels. Quirk (kept): an arctic fox in a red gnome hat helping itself to the fish bucket.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-tundra-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "jetty", out = DIR, farTrees = { 24, 52, 120, 196 },
  treeLineGap = { 262, 490 } } -- the right half is the far shore of the frozen lake, drawn here
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local mix, rp = F.mix, F.rp
local W, S, I = L.water, L.snow, L.ice
local SACK = rp("#ecd6aa #ccae80 #a68660 #7a604a #4a3a34")
local CHAR = rp("#e4e8ec #b8c2c8 #8a98a4 #5e6c7c #3a4454") -- arctic char: silver-grey back
local BELLY = rp("#ffb08a #f07858 #d0503e #9a3634 #5e2028") -- and its red belly
local SHACK = rp("#a6cce6 #6ea2cc #4e7eae #38598a #243c62") -- painted shack blue
local YEL = rp("#f6dc8a #e2b850 #b88c38 #86622c #52401e")

---------------------------------------------------------------- the frozen lake
local WL = 116 -- the ice edge under the far shore
local lake = poly{ { 266, WL }, { 479, WL }, { 479, 228 }, { 372, 228 }, { 350, 220 }, { 326, 202 }, { 304, 176 }, { 288, 150 }, { 276, 130 } }
-- far shore: a low snow bank under the fells, lit on its crest, lilac below
local shore = poly{ { 258, 112 }, { 479, 112 }, { 479, WL }, { 268, WL } }
shore:each(function(x, y)
  local h = y == 112 and S.hi or (y < 114 and S.base or (hash(x // 3, y, 81) < .5 and S.shade or L.shadow))
  if hash(x // 5, 0, 82) < .18 and y >= 113 then h = hash(x, y, 83) < .5 and L.tLichen[2] or L.tRust[2] end
  px(x, y, h)
end)
-- the near snow bank along the diagonal shore, stones and sedge in it
local beach = lake:grow(4):cut(lake):clip(rect(0, WL, 479, 269))
beach:each(function(x, y)
  local v = hash(x, y, 5)
  local h = v < .55 and S.base or (v < .8 and S.hi or S.shade)
  if hash(x // 3, y // 2, 6) < .1 then h = hash(x, y, 7) < .5 and L.stone.base or L.stone.shade end
  px(x, y, h)
end)
local iceM = lake:shrink(1)
local SKY1, SKY2 = mix(I.hi, L.sky[2], .45), mix(I.base, L.sky[1], .35)
local polished = HP.mask()
iceM:each(function(x, y)
  local d = y - WL
  local v = F.vnoise(x / 46, y / 2.6, 61) -- long wind streaks: snow skiffs vs swept ice
  local w = F.vnoise(x / 14, y / 5, 62)
  local thr = .47 - math.min(.12, d * .0014)
  local h
  if v + (w - .5) * .25 > thr then
    polished:set(x, y)
    if d < 10 then h = (hash(x // 5, y, 63) < .5) and SKY1 or I.hi
    elseif d < 40 then h = w < .45 and SKY2 or I.base
    elseif d < 75 then h = w < .35 and I.shade or (w < .7 and I.base or SKY2)
    else h = w < .4 and I.deep or (w < .65 and I.shade or I.base) end
    if hash(x, y, 64) < .02 then h = I.hi end -- trapped bubbles
  else
    if d < 6 then h = (hash(x, y, 65) < .5) and L.mist or S.base
    else
      h = hash(x, y, 66) < .22 and S.hi or S.base
      if (y + floor(x * .3)) % 5 == 0 and hash(x // 4, y, 67) < .55 then h = S.shade end -- sastrugi
      if d > 50 and (y + floor(x * .3)) % 5 == 1 and hash(x // 4, y - 1, 67) < .55 then h = S.hi end
    end
  end
  px(x, y, h)
end)
-- the snow skiff edges: a lit rim where snow meets swept ice
iceM:each(function(x, y)
  if not polished:has(x, y) and polished:has(x, y + 1) then px(x, y, S.shade) end
  if polished:has(x, y) and not polished:has(x, y - 1) then px(x, y, I.hi) end
end)
-- reflection of the fells and the shore bank in the polished far ice
for x = 268, 478 do
  local hgt = floor((112 - F.fFar(x)) * .3)
  for y = WL + 1, WL + 1 + hgt do if polished:has(x, y) then px(x, y, y == WL + 1 + hgt and SKY2 or mix(L.hillFar, I.hi, .35)) end end
end
-- pressure cracks: dark hairline with a lit lower lip, forking
for _, ck in ipairs({
  { { 282, 140 }, { 320, 146 }, { 352, 142 }, { 400, 150 }, { 478, 146 } },
  { { 300, 168 }, { 336, 176 }, { 362, 172 }, { 392, 196 }, { 430, 200 }, { 478, 194 } },
  { { 336, 176 }, { 350, 190 }, { 366, 212 } },
  { { 400, 150 }, { 420, 162 }, { 478, 168 } },
  { { 330, 126 }, { 380, 130 }, { 440, 124 } },
}) do
  line(ck):each(function(x, y)
    if iceM:has(x, y) then
      local on = polished:has(x, y)
      px(x, y, on and I.edge or I.deep)
      if iceM:has(x, y + 1) then px(x, y + 1, on and I.hi or S.hi) end
    end
  end)
end
-- the shove ridge: blocks of lake ice pushed up along the shore
do
  local ridge = iceM:copy():cut(iceM:shrink(4)):clip(rect(0, WL + 6, 479, 269))
  ridge:each(function(x, y)
    local bx, by = (x + floor(y * .5)) // 4, y // 3
    if hash(bx, by, 68) < .62 then
      local ry = y % 3
      local h = ry == 0 and I.hi or (((x + floor(y * .5)) % 4 == 3) and I.shade or I.base)
      if hash(bx, by, 69) < .3 then h = ry == 0 and S.hi or (ry == 1 and S.base or I.base) end
      if not ridge:has(x, y + 1) then h = I.deep end
      px(x, y, h)
    end
  end)
end
-- low-sun sparkle on the snow skiffs
for k = 0, 70 do
  local gx, gy = 276 + floor(hash(k, 1, 18) * 200), 120 + floor(hash(k, 2, 18) * 100)
  if iceM:has(gx, gy) then px(gx, gy, "#fff6ea") if k % 3 == 0 then px(gx + 1, gy, I.hi) px(gx, gy - 1, I.hi) end end
end

-- an augered hole in the ice: a slush ring, the lit far wall of ice, dark water, chips scattered round
local function hole(x, y, rx, ry, seed)
  local ring = c:ellipse(x, y, rx + 2, ry + 1)
  local wat = c:ellipse(x, y, rx, ry)
  F.obj()
  ring:each(function(xx, yy) px(xx, yy, yy < y and S.hi or (xx < x and S.base or S.shade)) end)
  wat:each(function(xx, yy)
    local h = W.deep
    if not wat:has(xx, yy - 1) then h = I.base elseif not wat:has(xx, yy - 2) then h = I.shade
    elseif yy > y and hash(xx, yy, seed or 1) < .25 then h = W.shade end
    if not wat:has(xx, yy + 1) then h = W.edge end
    px(xx, yy, h)
  end)
  px(x - 1, y + 1, W.hi)
  for k = 0, 5 do
    local a = hash(k, 1, seed or 2) * 2 * pi
    local cx, cy = x + floor(cos(a) * (rx + 4)), y + floor(sin(a) * (ry + 2) + .5)
    if not ring:has(cx, cy) then px(cx, cy, I.hi) px(cx + 1, cy, I.shade) end
  end
  return ring
end
-- a tip-up over a hole: crossed sticks, a spring wire and an orange flag (up when a fish has bitten)
local function tipUp(x, y, up)
  hline(x - 4, x + 4, y, L.timber.base) px(x - 4, y, L.timber.shade) px(x + 4, y, L.timber.deep)
  vline(x, y - 1, y + 1, L.timber.shade)
  if up then
    vline(x, y - 8, y - 1, L.iron.base) px(x, y - 8, L.iron.hi)
    fill(rect(x + 1, y - 8, x + 4, y - 6), L.produce.base) px(x + 1, y - 8, L.produce.hi) px(x + 4, y - 6, L.produce.deep) hline(x + 1, x + 4, y - 5, L.produce.deep)
  else
    line({ { x, y - 1 }, { x + 5, y - 3 } }):each(function(xx, yy) px(xx, yy, L.iron.shade) end)
    px(x + 5, y - 4, L.produce.shade) px(x + 6, y - 4, L.produce.base) px(x + 6, y - 3, L.produce.deep)
  end
end

---------------------------------------------------------------- far ice: little shacks, the ice yacht, the dog sled
F.depth(1)
-- sparse spruce clumps and willow scrub on the far shore
for _, t in ipairs({ { 282, 12, 1 }, { 290, 16, 2 }, { 297, 10, 3 }, { 352, 11, 4 }, { 358, 15, 5 }, { 446, 14, 6 }, { 454, 10, 7 }, { 470, 17, 8 } }) do
  F.conifer(t[1], 114, t[2], L.farTree, 500 + t[3], { far = true, slim = true })
end
for _, w in ipairs({ { 318, 114, 4, 3 }, { 400, 114, 5, 3 }, { 428, 115, 3, 2 } }) do F.willow(w[1], w[2], w[3], w[4], w[1]) end
-- a little ice shack on runners: plank walls, a shed roof under snow, a stovepipe
local function smallShack(x, yb, w, h, r, door)
  local body = rect(x, yb - h, x + w, yb - 1)
  local roof = poly{ { x - 1, yb - h }, { x - 1, yb - h - 2 }, { x + w + 1, yb - h - 4 }, { x + w + 1, yb - h } }
  local run = rect(x - 1, yb, x + w + 1, yb)
  local pipe = rect(x + w - 3, yb - h - 8, x + w - 2, yb - h - 3)
  F.shadowM(rect(x + 2, yb, x + w + 6, yb + 1))
  rimOf(union(body, roof, run, pipe), L.timber)
  part(body, r) F.planks(body, r, 3, true, x)
  part(roof, L.roof2, { nopop = true }) F.snowCap(roof, 2, x, { cx = x + 2 })
  part(run, L.timber, { nopop = true, noshade = true })
  part(pipe, L.iron, { nopop = true, noshade = true })
  if door then fill(rect(x + 2, yb - h + 3, x + 4, yb - 2), r.deep) px(x + 4, yb - h + 6, L.gold.hi) end
  px(x + w - 3, yb - h + 3, L.glow.base) px(x + w - 2, yb - h + 3, L.glow.shade)
  return x + w - 3, yb - h - 9
end
local sx1, sy1 = smallShack(332, 124, 9, 7, L.wall2, true)
local sx2, sy2 = smallShack(372, 122, 8, 6, YEL, true)
local sx3, sy3 = smallShack(466, 126, 9, 7, L.wall2, true)
F.smoke(sx1, sy1, 3, .5, 1) F.smoke(sx2, sy2, 3, .4, 1) F.smoke(sx3, sy3, 3, .5, 1)
-- gnome specks out at the far shacks
for _, g in ipairs({ { 346, 123, L.awnA }, { 386, 121, L.accent } }) do
  px(g[1], g[2] - 3, g[3].base) px(g[1], g[2] - 2, L.skin.base) px(g[1], g[2] - 1, L.timber.shade) px(g[1], g[2], L.timber.edge)
end
-- the ice yacht: a plank cross on three runners, a cream sail with a red band
local function iceYacht(x, y)
  local plank = rect(x - 10, y, x + 9, y + 1)
  local cross = rect(x - 3, y - 1, x + 1, y + 2)
  local s1 = poly{ { x, y - 1 }, { x, y - 18 }, { x + 10, y - 1 } }
  local s2 = poly{ { x - 1, y - 1 }, { x - 1, y - 13 }, { x - 8, y - 1 } }
  F.shadowM(rect(x - 8, y + 3, x + 14, y + 3))
  rimOf(union(plank, cross, s1, s2), L.timber)
  part(plank, L.timber, { nopop = true, noshade = true }) part(cross, L.timber, { nopop = true })
  fill(s1, L.awnB.base) fill(s2, L.awnB.shade)
  s1:each(function(xx, yy) if yy > y - 6 and yy < y - 3 then px(xx, yy, L.awnA.base) end end)
  s2:each(function(xx, yy) if yy > y - 6 and yy < y - 3 then px(xx, yy, L.awnA.shade) end end)
  vline(x, y - 18, y, L.timber.base) vline(x + 1, y - 15, y - 2, L.awnB.hi)
  px(x - 10, y + 2, L.iron.deep) px(x + 9, y + 2, L.iron.deep) px(x - 2, y + 3, L.iron.deep) -- runner blades
  hline(x - 18, x - 11, y + 2, I.shade) hline(x - 24, x - 19, y + 2, I.base) -- runner scratches on the ice
end
iceYacht(286, 134)
-- the dog sled team trotting out to the shacks
F.depth(2)
local function scale15(rows)
  local out, nh = {}, math.floor(#rows * 1.5 + .5)
  for j = 0, nh - 1 do
    local r = rows[math.floor(j / 1.5) + 1]
    local t = {}
    for i = 0, math.floor(#r * 1.5 + .5) - 1 do t[#t + 1] = r:sub(math.floor(i / 1.5) + 1, math.floor(i / 1.5) + 1) end
    out[#out + 1] = table.concat(t)
  end
  return out
end
local function dog(x, y)
  F.sprite({
    "........G.G...",
    "........GGGG..",
    ".w..GGGGGeWWn.",
    ".wwGGGGGGGWWW.",
    "..GGGGGGWWWW..",
    "..GWWWWWWWWG..",
    "..G.G....G.G..",
    "..k.k....k.k..",
  }, x, y - 3, { k = L.timber.edge, G = L.iron.base, W = L.fur.hi, w = L.iron.shade, e = L.timber.edge, n = L.timber.edge })
end
local function dogSled(x, y)
  -- tracks behind
  for k = 1, 9 do px(x - k * 4, y + 1 + (k // 4), S.shade) px(x - k * 4 - 1, y + 3 + (k // 4), S.shade) end
  local bed = rect(x, y - 5, x + 14, y - 1)
  local run = rect(x - 2, y, x + 16, y):add(rect(x - 2, y - 9, x - 1, y))
  F.shadowM(rect(x, y + 1, x + 22, y + 2))
  rimOf(union(bed, run), L.timber)
  part(bed, L.wall2) F.planks(bed, L.wall2, 3, true, 7)
  part(run, L.timber, { nopop = true, noshade = true })
  F.sack(x + 9, y - 5, SACK, 3)
  F.gnome(x + 2, y - 2, { small = true, hat = L.awnA, coat = L.leaf, noShadow = true })
  -- gangline and the team
  hline(x + 17, x + 54, y - 3, L.soil.shade)
  dog(x + 16, y - 6) dog(x + 28, y - 7) dog(x + 40, y - 6)
end
dogSled(304, 156)

---------------------------------------------------------------- the big blue fishing shack on runners (where the boathouse stood)
local function bigShack()
  F.drift(384, 141, 14, 6, 21) -- windward drift banked against its left wall
  local top, _, wallM, roofM = F.building{ x0 = 388, x1 = 444, yb = 136, wh = 22, rh = 18, wall = SHACK, roof = L.roof2,
    noShadow = true, noFrame = true, noAttic = true, shingle = true, snow = 4, icicles = 5 }
  F.planks(wallM:copy():clip(rect(388, top + 4, 444, 136)), SHACK, 4, true, 31)
  local trim = union(rect(388, top + 3, 389, 136), rect(443, top + 3, 444, 136))
  part(trim, L.plaster, { nopop = true, noshade = true })
  -- door, lit window, char hanging on a nail beside the door
  F.door(397, 120, 407, 136, L.plaster)
  F.window(424, 118, 432, 125, L.plaster)
  hline(423, 433, 126, S.hi)
  for k = 0, 1 do
    local fx = 412 + k * 4
    fill(rect(fx, 121, fx + 1, 129), CHAR.base) vline(fx + 1, 124, 128, BELLY.base) px(fx, 130, CHAR.shade) px(fx + 1, 130, CHAR.shade) px(fx, 121, L.timber.edge)
  end
  -- stovepipe with a rain cap
  local pipe = rect(434, top - 16, 436, top - 2) local cap = rect(432, top - 18, 438, top - 17)
  rimOf(union(pipe, cap), L.iron) part(pipe, L.iron, { nopop = true }) part(cap, L.iron, { nopop = true, noshade = true })
  hline(432, 438, top - 19, S.hi)
  -- runners: two driftwood skids with curled fronts
  local skid = rect(384, 137, 448, 139):add(line({ { 448, 139 }, { 451, 136 }, { 450, 134 } }, 2))
  rimOf(skid, L.timber) part(skid, L.timber, { nopop = true }) hline(384, 448, 137, L.timber.hi)
  F.shadowM(rect(392, 140, 470, 142))
  -- a bench with a bucket and an auger outside
  local bench = rect(450, 128, 462, 130):add(rect(451, 131, 452, 139)):add(rect(460, 131, 461, 139))
  rimOf(bench, L.timber) part(bench, L.board, { nopop = true }) hline(450, 462, 127, S.hi)
  F.smoke(435, top - 22, 5, .7, 2)
  return top
end
bigShack()
hole(426, 150, 4, 1, 11)
-- row of tip-ups across the middle ice
for _, t in ipairs({ { 288, 172, true }, { 410, 160, false }, { 466, 158, false }, { 436, 172, true } }) do hole(t[1], t[2], 3, 1, t[1]) tipUp(t[1], t[2], t[3]) end

---------------------------------------------------------------- mid ice: a gnome on a bucket, an arctic char coming out of the hole
do
  local hx, hy = 366, 166
  hole(hx + 19, hy + 1, 5, 2, 12)
  F.shadow(hx - 6, hx + 6, hy, 4, 2)
  local bkt = rect(hx - 5, hy - 6, hx + 5, hy)
  rimOf(bkt, L.iron) part(bkt, L.iron, { nopop = true }) hline(hx - 5, hx + 5, hy - 3, L.iron.deep)
  local _, ghx, ghy = F.gnome(hx, hy - 4, { hat = L.produce, coat = L.wall2, arm = "out", noShadow = true })
  -- short jigging rod, the line taut down to the char
  fill(line({ { ghx, ghy }, { hx + 22, hy - 20 } }), L.timber.deep)
  line({ { hx + 22, hy - 20 }, { hx + 21, hy - 14 } }):each(function(x, y) px(x, y, L.awnB.shade) end)
  F.sprite({
    "..kk..",
    ".kBBk.",
    ".kCcBk",
    "kCCCBk",
    "kCCcBk",
    "kCCCBk",
    ".kCBk.",
    ".kCBk.",
    "..kk..",
    ".kkkk.",
  }, hx + 18, hy - 13, { k = L.timber.edge, C = CHAR.base, c = CHAR.hi, B = BELLY.base })
  px(hx + 20, hy - 12, BELLY.hi)
  for _, d in ipairs({ { 14, -2 }, { 26, -1 }, { 16, -6 }, { 25, -7 } }) do px(hx + d[1], hy + d[2], W.hi) end -- flicked drops
  -- two char already on the ice beside him
  for k = 0, 1 do
    local fx, fy = hx - 18 + k * 7, hy + 2 + k
    fill(rect(fx, fy, fx + 5, fy + 1), CHAR.base) hline(fx, fx + 5, fy + 1, BELLY.base) px(fx + 6, fy, CHAR.shade) px(fx + 6, fy + 1, CHAR.shade) px(fx, fy, L.timber.edge)
  end
  F.tracks({ { 346, 178 }, { 358, 168 } }, "boot", 5)
end

---------------------------------------------------------------- the jetty, piles locked in the ice, a rowboat frozen in
local function rowboat(x0, x1, y)
  local hull = poly{ { x0 - 3, y - 2 }, { x0, y }, { x1, y }, { x1 + 3, y - 2 }, { x1 - 5, y + 11 }, { x0 + 6, y + 11 } }
  local inside = c:ellipse((x0 + x1) / 2, y - 2, (x1 - x0) / 2 - 1, 2)
  rimOf(union(hull, inside), L.timber)
  part(hull, L.wall2) hline(x0 + 2, x1 - 2, y + 3, L.plaster.base) hline(x0 + 3, x1 - 3, y + 4, L.plaster.shade) hline(x0 + 6, x1 - 6, y + 9, L.wall2.deep)
  fill(inside, L.timber.shade) c:edgeIn(inside, L.board.base)
  -- snow heaped in the boat and on the seats
  local sn = c:ellipse((x0 + x1) / 2, y - 3, (x1 - x0) / 2 - 4, 2)
  sn:each(function(x, yy) px(x, yy, yy < y - 3 and S.hi or S.base) end)
  vline(x0 + 16, y - 5, y - 1, L.board.hi) vline(x1 - 16, y - 5, y - 1, L.board.hi)
  -- the ice it is frozen into: a lip of ice and snow round the waterline, a drift on the lee side
  local lip = c:ellipse((x0 + x1) / 2 + 1, y + 10, (x1 - x0) / 2 + 2, 3):cut(c:ellipse((x0 + x1) / 2 + 1, y + 7, (x1 - x0) / 2 - 2, 2))
  F.obj()
  lip:each(function(x, yy) if yy >= y + 9 then px(x, yy, yy == y + 9 and I.hi or (hash(x, yy, 95) < .5 and S.base or I.base)) end end)
  F.drift(x1 + 6, y + 12, 10, 4, 96)
  F.icicles(x0 + 6, x1 - 6, y + 4, 2, 97, .25)
  -- the oar frozen in its rowlock, sticking out over the ice
  fill(line({ { x0 + 8, y - 2 }, { x1 + 6, y + 6 } }), L.board.shade) fill(rect(x1 + 4, y + 5, x1 + 8, y + 7), L.board.base)
end
F.depth(3)
local deck = rect(300, 178, 470, 185)
local face = rect(300, 186, 470, 188)
local piles = HP.mask()
for x = 312, 466, 18 do piles:add(rect(x, 189, x + 2, 206)) end
-- the deck's long lilac shadow on the ice
for x = 300, 476 do for y = 189, 194 do if iceM:has(x, y) and (y < 193 or hash(x, y, 98) < .5) then px(x, y, polished:has(x, y) and I.shade or L.shadow) end end end
rimOf(union(deck, face, piles), L.timber)
part(piles, L.timber, { nopop = true, noshade = true })
part(deck, L.board)
F.planks(deck, L.board, 5, true, 21)
-- snow lying on the deck, a cleared boot path down the middle (and swept round the fisher's crate)
deck:each(function(x, y)
  local path = y >= 181 and y <= 183
  if not path and hash(x // 9, y, 99) < .8 then px(x, y, y == 178 and S.hi or (y < 181 and S.base or S.shade)) end
  if path and hash(x // 5, y, 100) < .08 then px(x, y, S.base) end
end)
hline(300, 470, 177, S.hi)
for x = 302, 470, 14 do if hash(x, 1, 101) < .5 then px(x, 176, S.base) end end
part(face, L.timber, { nopop = true })
for x = 302, 470, 10 do px(x, 187, L.iron.hi) end
F.icicles(300, 470, 189, 5, 102, .5)
-- ice collars heaved up round each pile, rime on the pile heads
for x = 312, 466, 18 do
  local col = c:ellipse(x + 1, 206, 4, 2)
  F.obj()
  col:each(function(xx, yy) px(xx, yy, yy < 206 and I.hi or (xx < x + 1 and S.base or I.base)) end)
  px(x + 4, 207, I.shade) px(x - 2, 207, S.hi)
  hline(x, x + 2, 196, I.base) px(x, 199, I.hi)
end
rowboat(368, 422, 212)
fill(line({ { 366, 210 }, { 360, 189 } }), L.board.shade) -- mooring rope, stiff with frost
px(363, 199, S.hi) px(365, 205, S.hi)
-- lamp post at the end, a raven on the arm
local lp = rect(460, 140, 461, 177) rimOf(lp, L.timber) part(lp, L.timber, { nopop = true, noshade = true })
local arm = rect(452, 140, 461, 141) fill(arm, L.timber.base) hline(452, 461, 139, S.hi)
local lam = rect(450, 143, 455, 150) rimOf(lam, L.timber) fill(lam, L.glow.base) px(451, 144, L.glow.hi) vline(455, 144, 150, L.glow.shade)
hline(450, 455, 142, S.base) px(452, 151, L.timber.deep)
F.sprite({
  "..kk....",
  ".kKKk...",
  "bKeKKk..",
  "..KKKKk.",
  "..KKKKKk",
  "...KKKKK",
  "....d.d.",
}, 452, 133, { k = "#3a3646", K = "#4a4656", e = L.gold.hi, b = "#5e5a6a", d = L.timber.edge })
-- warm lamplight on the snow of the deck end
for x = 446, 462 do for y = 178, 180 do if hash(x, y, 103) < .45 then px(x, y, mix(S.base, L.glow.hi, .35)) end end end
-- fisher gnome on a crate, a jigging rod out over his own hole in the ice
F.crate(424, 177, 12, 6)
hline(424, 436, 170, S.hi)
local _, fhx, fhy = F.gnome(430, 171, { hat = L.awnA, coat = L.accent, arm = "out", noShadow = true })
fill(line({ { fhx, fhy }, { 448, 152 }, { 452, 146 } }), L.timber.deep)
vline(452, 152, 177, L.awnB.shade) vline(452, 189, 212, L.awnB.shade)
hole(452, 216, 5, 2, 104)
F.barrel(316, 177, L.timber, 9) F.snowCap(c:rrect(311, 168, 321, 177, 3), 2, 105)
F.crate(328, 177, 12, 7, CHAR)
-- an ice auger and a scoop leaning on the crate, a thermos flask on the deck
fill(line({ { 344, 177 }, { 350, 158 } }), L.iron.shade) hline(347, 353, 158, L.timber.base)
for y = 168, 176, 2 do px(345 + (176 - y) // 4, y, L.iron.hi) px(346 + (176 - y) // 4, y + 1, L.iron.deep) end
local mug = rect(406, 172, 409, 177) rimOf(mug, L.iron) part(mug, L.awnA, { nopop = true }) hline(406, 409, 172, L.iron.hi)
F.steam(407, 170, 3, .4, 12)

---------------------------------------------------------------- shore wedge: the fox at the fish bucket (quirk), a loaded pulk, an auger
F.eraseGround(rect(300, 236, 324, 251)) -- keep the bucket's silhouette clear
local bucket = poly{ { 304, 252 }, { 318, 252 }, { 316, 264 }, { 306, 264 } }
rimOf(bucket, L.timber) part(bucket, L.board) hline(304, 318, 255, L.iron.shade) hline(305, 317, 261, L.iron.shade)
for k = 0, 3 do local fx = 306 + k * 3 fill(rect(fx, 248 - (k % 2), fx + 1, 252), CHAR.hi) px(fx, 248 - (k % 2), CHAR.shade) px(fx + 1, 250, BELLY.base) end
F.shadowM(c:ellipse(292, 265, 12, 1))
-- arctic fox in white winter coat, a red gnome hat, a char in its jaws; ink rim, dark eye and nose so it reads on snow
F.sprite({
  "..............R.......",
  ".............RRr......",
  "............RRRr......",
  "...........RRRRrr.....",
  "..........hhhhhhhh....",
  "..........WWwWWWWWW...",
  ".........WWWWWWeWWWWn.",
  "........WWWWWWWWWWWWCC",
  "........WWWWWWWWWWBCCC",
  "....s...wWWWWWWWw..CC.",
  "...sWw..WWWWWWWw......",
  "..sWWWwWWWWWWWWw......",
  "..sWWWWWWWWWWWWw......",
  "...wWWWWWWWWWWw.......",
  "....wwWWWWWWWw........",
  ".....WW.wWW.WW........",
  ".....Ww..ww.Ww........",
  ".....dd..dd.dd........",
}, 284, 246, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, W = L.fur.base, w = L.fur.shade, s = L.fur.deep,
  e = L.timber.edge, n = L.timber.edge, C = CHAR.base, B = BELLY.base, d = L.fur.deep })
px(298, 249, L.awnB.hi) -- the hat's pompom catches the sun
F.tracks({ { 262, 268 }, { 276, 262 }, { 286, 264 } }, "hare", 6)
-- a hand pulk loaded with a fish box and a coil of rope
do
  local x0, yb = 330, 258
  local run = line({ { x0, yb }, { x0 + 34, yb } }):add(line({ { x0 + 34, yb }, { x0 + 38, yb - 4 }, { x0 + 37, yb - 7 } }))
  local bed = rect(x0 + 2, yb - 6, x0 + 32, yb - 2)
  F.shadow(x0, x0 + 34, yb, 6, 2)
  rimOf(union(run, bed), L.timber)
  part(run, L.timber, { nopop = true, noshade = true }) hline(x0, x0 + 34, yb, S.hi)
  part(bed, L.wall2) F.planks(bed, L.wall2, 4, true, 23)
  local box = rect(x0 + 4, yb - 13, x0 + 18, yb - 7)
  rimOf(box, L.timber) part(box, L.board) c:edgeIn(box, L.board.deep)
  for k = 0, 3 do local fx = x0 + 6 + k * 3 fill(rect(fx, yb - 15, fx + 1, yb - 13), CHAR.base) px(fx + 1, yb - 14, BELLY.base) px(fx, yb - 15, CHAR.hi) end
  local coil = c:ellipse(x0 + 26, yb - 9, 6, 3) rimOf(coil, L.board) part(coil, SACK) fill(c:ellipse(x0 + 26, yb - 9, 2, 1), L.board.deep)
  for k = 0, 1 do c:ellipse(x0 + 26, yb - 9, 5 - k * 2, 2):edge():each(function(x, y) if y > yb - 9 then px(x, y, SACK.shade) end end) end
  -- tow rope trailing back to the shore
  line({ { x0, yb - 3 }, { x0 - 8, yb + 2 }, { x0 - 14, yb + 1 } }):each(function(x, y) px(x, y, L.soil.shade) end)
end
-- an ice chisel stuck upright in the snow
local chis = rect(336, 222, 337, 244):add(rect(333, 222, 340, 223))
rimOf(chis, L.timber) part(chis, L.timber, { nopop = true, noshade = true }) fill(rect(336, 240, 337, 244), L.iron.base) px(336, 240, L.iron.hi)
F.snowCap(F.rock(368, 268, 9, 8), 3, 94)
F.snowCap(F.rock(326, 270, 6, 5), 2, 95)
for _, f in ipairs({ { 372, 250, 7 }, { 276, 248, 6 }, { 362, 234, 5 } }) do F.fern(f[1], f[2], f[3]) end

---------------------------------------------------------------- left: the falu-red fisher's cottage, a stockfish rack
F.depth(1)
F.tree(84, 128, 38, 3)
F.tree(10, 134, 40, 1)
local ctop, _, cwall, croof = F.building{ x0 = 20, x1 = 70, yb = 136, wh = 32, rh = 22, wall = L.wall2, roof = L.roof, chimney = true, noFrame = true, snow = 4 }
F.planks(cwall:copy():clip(rect(20, ctop + 4, 70, 136)), L.wall2, 4, true, 41)
part(union(rect(20, ctop + 3, 21, 136), rect(69, ctop + 3, 70, 136)), L.plaster, { nopop = true, noshade = true })
F.window(26, 112, 32, 118, L.plaster) F.door(48, 122, 55, 135, L.accent)
hline(25, 33, 119, S.hi)
F.smoke(61, 86, 6, .5, 2)
-- a fish-shaped sign on the cottage
local fs = c:ellipse(37, 128, 6, 3):add(poly{ { 42, 128 }, { 47, 124 }, { 47, 132 } })
rimOf(fs, L.accent) part(fs, L.accent) px(33, 127, L.timber.edge) hline(32, 40, 125, S.hi)
F.drift(16, 138, 8, 4, 42)
-- stockfish rack (hjell): two A-frame trestles, two rails hung thick with pairs of split fish, snow on the rails
local function fishRack(x0, x1, yb)
  local legs = HP.mask()
  for _, lx in ipairs({ x0, x1 }) do legs:add(line({ { lx - 3, yb }, { lx + 1, yb - 25 } }, 2)):add(line({ { lx + 5, yb }, { lx + 1, yb - 25 } }, 2)) end
  local bar = rect(x0 - 2, yb - 24, x1 + 4, yb - 23):add(rect(x0 - 2, yb - 13, x1 + 4, yb - 12))
  F.shadow(x0, x1, yb, 6, 3)
  rimOf(union(legs, bar), L.timber) part(legs, L.timber, { nopop = true, noshade = true }) part(bar, L.timber, { nopop = true, noshade = true })
  hline(x0 - 2, x1 + 4, yb - 25, S.hi) hline(x0 - 2, x1 + 4, yb - 14, S.base)
  for _, rail in ipairs({ { yb - 22, 0 }, { yb - 11, 2 } }) do
    for x = x0 + 4 + rail[2], x1 - 2, 4 do
      local len = 8 + floor(hash(x, rail[1], 43) * 3)
      local fsh = rect(x, rail[1], x + 1, rail[1] + len - 2)
      local tl = rect(x - 1, rail[1] - 1, x + 2, rail[1])
      local cod = hash(x, rail[1], 44) < .6
      local r = cod and L.lichen or CHAR
      fill(union(fsh, tl), r.base) vline(x + 1, rail[1] + 1, rail[1] + len - 3, r.shade) px(x, rail[1] + 1, r.hi)
      px(x, rail[1] + len - 2, r.deep) px(x + 1, rail[1] + len - 2, r.deep)
      if not cod then vline(x + 1, rail[1] + 3, rail[1] + len - 4, BELLY.shade) end
      px(x - 1, rail[1] - 1, L.timber.edge) px(x + 2, rail[1] - 1, L.timber.edge)
    end
  end
end
fishRack(96, 150, 140)
-- driftwood and peat stack against the cottage, under snow
F.depth(2)
for k = 0, 3 do F.logEnd(76 + k * 5, 146, 2) end
for k = 0, 2 do F.logEnd(78 + k * 5, 142, 2) end
for k = 0, 1 do F.logEnd(80 + k * 5, 138, 2) end
hline(78, 91, 135, S.hi) hline(76, 94, 140, S.base)
F.cairn(31, 166, 12, 44)
F.depth(1)
F.willow(18, 142, 5, 5, 45) F.willow(90, 143, 4, 4, 46)
F.depth(3)

---------------------------------------------------------------- left hero: net drying frame, frosted, red floats, icicles off the net
local function netFrame(x0, x1, yt, yb)
  local posts = rect(x0, yt, x0 + 3, yb):add(rect(x1 - 3, yt, x1, yb)):add(rect((x0 + x1) // 2 - 1, yt, (x0 + x1) // 2 + 1, yb))
  local bar = rect(x0 - 3, yt, x1 + 3, yt + 3)
  F.shadow(x0, x1, yb, 10, 5)
  rimOf(union(posts, bar), L.timber)
  part(posts, L.timber, { nopop = true }) part(bar, L.timber, { nopop = true })
  F.snowCap(bar, 2, 47, { cx = x0 + 20, lip = true })
  for _, px0 in ipairs({ x0, (x0 + x1) // 2 - 1, x1 - 3 }) do F.snowCap(rect(px0, yt - 1, px0 + 3, yt + 1), 2, px0) end
  local function sag(x) local t = ((x - x0) % ((x1 - x0) // 2)) / ((x1 - x0) // 2) return floor(yb - 14 - 10 * sin(t * pi)) end
  local NET = rp("#d8d0c0 #a89a84 #7e7262 #5a5048 #3a3432")
  F.obj()
  for x = x0 + 4, x1 - 4 do
    local y1 = sag(x)
    for y = yt + 4, y1 do
      local a, b = (x + y) % 5, (x - y) % 5
      if a == 0 or b == 0 then
        px(x, y, (hash(x, y, 48) < .1) and S.hi or NET.shade) -- rime on the mesh
        if a == 0 and b == 0 then px(x, y, S.base) end
      elseif hash(x, y, 2) < .015 then px(x, y, NET.base) end
    end
    px(x, y1, NET.deep)
    if x % 7 == 0 then fill(rect(x - 1, y1 + 1, x + 1, y1 + 3), L.awnA.base) px(x - 1, y1 + 1, L.awnA.hi) px(x + 1, y1 + 3, L.awnA.deep) px(x, y1 + 1, S.hi)
    elseif hash(x, 0, 49) < .3 then
      local len = 1 + floor(hash(x, 1, 49) * 4)
      for k = 1, len do px(x, y1 + k, k == len and I.deep or I.base) end
    end
  end
end
netFrame(92, 192, 150, 214)
F.barrel(110, 222, L.timber, 11) F.barrel(124, 224, L.board, 9)
F.snowCap(c:rrect(105, 211, 115, 222, 3), 2, 50) F.snowCap(c:rrect(119, 215, 129, 224, 3), 2, 51)
-- box of frozen char, red bellies up
local bk = rect(160, 214, 182, 224)
rimOf(bk, L.timber) part(bk, L.board) c:edgeIn(bk, L.board.deep) hline(161, 181, 219, L.board.shade)
for k = 0, 4 do
  local fx = 162 + k * 4
  fill(c:ellipse(fx, 212, 2, 1), CHAR.hi) px(fx + 2, 212, CHAR.shade) px(fx - 1, 212, BELLY.base) px(fx, 213, BELLY.shade)
end
-- an ice saw and a long chisel leaning on the frame
fill(line({ { 196, 228 }, { 188, 176 } }, 2), L.board.base) fill(c:rrect(186, 170, 191, 178, 2), L.iron.shade) px(187, 171, L.iron.hi)
local saw = poly{ { 82, 214 }, { 86, 214 }, { 92, 170 }, { 89, 170 } }
rimOf(saw, L.iron) part(saw, L.iron, { nopop = true }) for y = 174, 212, 3 do px(82 + (214 - y) * 9 // 44, y, L.iron.deep) end
fill(rect(88, 166, 94, 168), L.timber.base)
-- a husky sitting by the box, eyeing the fish: grey saddle, white mask, ice-blue eyes, curled tail
F.sprite({
  ".k...k...",
  "kGk.kGk..",
  "kGGGGGk..",
  "kGWGWGk..",
  "kWeWeWk..",
  "kWWnWWk..",
  ".kWWWk...",
  ".GGWWGk..",
  "GGGWWGGk.",
  "GGGWWGGkw",
  "GGGWWGGww",
  "GGWWWWGw.",
  "kWWkWWWk.",
  ".kk.kkk..",
}, 146, 211, { k = L.timber.edge, G = L.iron.shade, W = L.fur.base, e = L.accent.hi, n = L.timber.edge, w = L.fur.shade })

---------------------------------------------------------------- bottom-left: big spruce, upturned boat under snow being tarred, creels
F.tree(44, 206, 54, 6)
F.barrel(64, 210, L.timber, 10) F.barrel(76, 212, L.timber, 10) F.barrel(70, 201, L.board, 9)
F.snowCap(c:rrect(65, 192, 75, 201, 3), 2, 52)
local function upBoat()
  local pts = { { 24, 242 } }
  for x = 24, 136, 4 do pts[#pts + 1] = { x, 242 - floor(16 * sin((x - 20) / 120 * pi) ^ .6) - (x > 120 and (x - 120) // 2 or 0) } end
  pts[#pts + 1] = { 138, 230 } pts[#pts + 1] = { 132, 242 }
  local hull = poly(pts)
  local tre = rect(36, 242, 38, 256):add(rect(110, 240, 112, 256)):add(rect(30, 252, 44, 253)):add(rect(104, 252, 118, 253))
  F.shadow(26, 136, 258, 5, 3)
  rimOf(union(hull, tre), L.timber)
  part(tre, L.timber, { nopop = true, noshade = true })
  part(hull, SHACK)
  hull:each(function(x, y)
    local k = 242 - floor(16 * sin((x - 20) / 120 * pi) ^ .6)
    if (y - k) % 5 == 4 then px(x, y, SHACK.deep) end
    if x < 64 and y > k + 4 then px(x, y, (y - k) % 5 == 4 and L.timber.edge or L.timber.deep) end -- fresh tar
    if x > 100 and y > k + 2 and hash(x // 2, y, 99) < .12 then px(x, y, SHACK.hi) end -- worn paint
  end)
  -- snow lying along the keel, swept off where he has tarred
  local cap = F.snowCap(hull:copy():clip(rect(64, 200, 140, 242)), 4, 53, { cx = 80 })
  hline(24, 132, 241, L.awnA.base) hline(24, 132, 242, L.awnA.deep) -- red gunwale stripe
  F.icicles(66, 132, 243, 3, 54, .3)
  local pot = rect(56, 250, 64, 258) rimOf(pot, L.iron) part(pot, L.iron) hline(56, 64, 250, L.timber.edge)
  fill(line({ { 62, 250 }, { 68, 244 } }), L.board.base)
  -- a little fire under the tar pot, the snow melted round it
  for x = 52, 68 do px(x, 260, (x % 3 == 0) and L.soil.base or L.soil.shade) end
  px(58, 259, L.glow.base) px(60, 259, L.glow.shade) px(62, 259, L.glow.base) px(59, 260, L.glow.hi) px(61, 260, L.produce.base)
  local _, thx, thy = F.gnome(82, 266, { hat = L.gold, coat = L.roof2, arm = "out", flip = true })
  fill(line({ { thx, thy }, { thx - 6, thy - 3 } }), L.board.base) fill(rect(thx - 9, thy - 6, thx - 6, thy - 3), L.timber.edge) -- tar brush
end
upBoat()
F.steam(60, 247, 4, .5, 13) -- steam off the tar
local function creel(x, yb)
  local m = c:rrect(x - 7, yb - 10, x + 7, yb, 4)
  rimOf(m, L.board) part(m, L.board)
  m:each(function(xx, y) if (xx - x) % 3 == 0 or (y - yb) % 3 == 0 then px(xx, y, L.board.deep) end end)
  fill(c:ellipse(x, yb - 6, 2, 2), L.soil.deep)
  F.snowCap(m, 2, x)
end
creel(160, 262) creel(176, 262) creel(168, 251)
for _, f in ipairs({ { 14, 222, 6 }, { 146, 246, 6 }, { 190, 254, 7 }, { 200, 238, 5 }, { 140, 266, 6 } }) do F.fern(f[1], f[2], f[3]) end
F.willow(20, 262, 6, 6, 55)
F.tracks({ { 100, 266 }, { 150, 238 }, { 186, 232 } }, "boot", 6)
-- dry sedge and frosted reed stalks poking up along the shore ice
local function reed(rx, ry, h, head)
  vline(rx, ry - h, ry, (rx % 2 == 0) and L.fern.shade or L.fern.deep)
  px(rx - 1, ry - h // 2, L.fern.base) px(rx, ry - h, S.hi)
  if head then fill(rect(rx, ry - h - 1, rx + 1, ry - h + 1), L.soil.base) px(rx, ry - h - 1, S.hi) px(rx + 1, ry - h + 1, L.soil.deep) end
end
for k = 0, 13 do local rx = 298 + k * 3 + (k % 2) reed(rx, 168 + k * 3, 4 + floor(hash(k, 4, 3) * 6), k % 3 == 0) end
for k = 0, 7 do reed(346 + k * 3, 218 + k + (k % 2), 5 + floor(hash(k, 5, 3) * 5), k % 2 == 0) end

---------------------------------------------------------------- lake shore path: cut ice blocks stacked by the shore
F.depth(2)
local function iceBlock(x, y, w, h)
  local front = rect(x, y - h, x + w, y)
  local top = poly{ { x, y - h }, { x + 3, y - h - 2 }, { x + w + 3, y - h - 2 }, { x + w, y - h } }
  local side = poly{ { x + w, y - h }, { x + w + 3, y - h - 2 }, { x + w + 3, y - 2 }, { x + w, y } }
  rimOf(union(front, top, side), I)
  fill(front, I.base) fill(top, I.hi) fill(side, I.shade)
  front:each(function(xx, yy) if (xx - x) == (yy - y + h) // 2 + 1 or hash(xx, yy, 56) < .07 then px(xx, yy, I.hi) end end)
  hline(x + 1, x + w - 1, y - h, S.hi)
end
F.shadow(268, 300, 150, 4, 2)
iceBlock(270, 150, 9, 6) iceBlock(281, 150, 9, 6) iceBlock(275, 143, 9, 6) iceBlock(292, 150, 7, 5)
-- signpost with a hanging fish board by the road
F.depth(3)
F.sign(206, 148, 18, 10, L.board)
hline(197, 215, 147, S.hi)
F.snowCap(F.rock(222, 196, 6, 5), 2, 57)
F.fern(206, 176, 5) F.fern(214, 210, 6)
F.depth(0)
F.birds({ { 360, 60, 3 }, { 376, 52, 2 }, { 300, 76, 2 }, { 150, 50, 2 } })
fill(c:ellipse(205, 153, 5, 2):add(poly{ { 209, 153 }, { 212, 150 }, { 212, 156 } }), BELLY.base) px(202, 152, L.timber.edge) px(203, 152, BELLY.hi)
hline(201, 207, 154, CHAR.base)
F.finish()
