-- ferry.lua : "Ferry crossing" stop look, TUNDRA (tundra_frost), 480x270 gate view.
-- Same composition as the Maplewold ferry (art-2701-batch4/stops/opus3/ferry.lua) and the forest ferry, re-cast as
-- an ice-road crossing: a half-frozen river runs across the whole view, shore ice on both banks, a dark open channel
-- full of drifting floes and frost smoke. The road stops at a snowy plank landing. The SLED-FERRY is the centre hero:
-- a plank raft on iron-shod sled runners (it is dragged over the ice in deep winter), running on a rope strung from a
-- pulley post on the far bank; a ferryman poles it, a traveller with a bundle and cargo ride it, and a gnome on the
-- landing hauls it in by the tow rope. Far bank: the road goes on from a far landing past the ferryman's ochre house
-- (slate roof, bell post, lantern), a sod-roofed driftwood hut with peat smoke, washing (a sweater, a mitten), a gnome
-- waving, and a stockfish drying rack under snowy spruces with ravens. Water: a gnome in a kayak among the floes, a
-- bearded seal hauled out on a floe, black guillemots, a skin boat frozen into the shore ice. Near bank: the ferry bell
-- under a slate hood, a painted ferry sign, a sod-roofed ticket booth with a gnome in the hatch, a bench of waiting
-- travellers on a reindeer skin, a kick-sled with a sled dog, a barrow of fish with a gull, cargo under snow, sedge
-- and cotton grass, an ice-fishing gnome at a hole in the shore ice, a snow goose after his apple.
-- Quirk: an arctic fox in a red gnome hat, riding the ferry on a falu-red trunk.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-tundra-stops/"
local F = dofile(DIR .. "_frame.lua")
  .build{ name = "ferry", out = DIR, roadTop = 178, farTrees = { 30, 70, 120, 168, 330, 372, 446 },
    clouds = { { 150, 44, 40 }, { 300, 30, 50 }, { 420, 64, 28 }, { 196, 76, 24 } },
    peaks = { { 120, 34, 50 }, { 178, 22, 28 }, { 330, 44, 60 }, { 400, 28, 34 }, { 470, 38, 40 }, { 30, 26, 34 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local mix = F.mix
local Wt, S, I = L.water, L.snow, L.ice
local GLINT = "#f2f6fa"
local SACK = F.rp("#ecd6aa #ccae80 #a68660 #7a604a #4a3a34")
local OCHRE = F.rp("#f2d48c #d8aa5a #ae8240 #7c5c36 #4a3628")
local FISH = F.rp("#e6dcc8 #c4b49a #9c8a74 #72624e #463a32")
local INK = "#34323e"
-- open channel water: darker than the ice so the floes read
local CH = F.rp("#b2d6e6 #8cbcd8 #6c9ec4 #5482ae #3a6088")
-- DY: a temporary vertical offset for whole near-bank groups (set, draw, reset)
local DY = 0
do local base = c.put c.put = function(self, x, y, h, o) base(self, x, y + DY, h, o) end end

local function yF(x) return 124 + floor(2 * sin(x / 31) + 1.5 * sin(x / 11)) end
local function yN(x) local t = (x - 240) / 240 return 177 + floor(14 * t * t + 3 * sin(x / 23) + 2 * sin(x / 9 + 1)) end

---------------------------------------------------------------- the half-frozen river
local river, openW = HP.mask(), HP.mask()
local fIce, nIce = {}, {} -- far ice bottom row, near ice top row, per x
for x = 0, 479 do
  for y = yF(x), yN(x) do river:set(x, y) end
  fIce[x] = yF(x) + 3 + floor(4 * F.vnoise(x / 16, 1, 201)) + (hash(x // 3, 1, 202) < .3 and 1 or 0)
  local w = 6 + floor(8 * F.vnoise(x / 20, 2, 203)) + floor(abs(x - 240) / 40)
  if x > 196 and x < 300 then w = 2 + floor(2 * hash(x // 4, 3, 204)) end -- the ferry keeps a lead open at the landing
  w = w + (hash(x // 2, 4, 205) < .25 and 1 or 0)
  nIce[x] = yN(x) - w
  for y = fIce[x] + 1, nIce[x] - 1 do openW:set(x, y) end
end
do
  -- open channel: lighter far (sky), darker near
  openW:each(function(x, y)
    local f = (y - fIce[x]) / math.max(1, nIce[x] - fIce[x])
    local h
    if f < .15 then h = CH.hi
    elseif f < .35 then h = hash(x // 8, y, 14) < .5 and CH.hi or CH.base
    elseif f < .7 then h = CH.base
    elseif f < .88 then h = hash(x // 6, y // 2, 15) < .6 and CH.shade or CH.base
    else h = CH.shade end
    px(x, y, h)
  end)
  -- current streaks
  for y = 128, 194 do
    local d = y - 122
    if y % 3 == 0 then
      local x = floor(hash(y, 1, 13) * 30)
      while x < 480 do
        local len = 4 + d // 3 + floor(hash(x, y, 18) * 8)
        if hash(x // 9, y, 16) < .5 then
          for xx = x, x + len do if openW:has(xx, y) and openW:has(xx, y + 1) then px(xx, y, Wt.base) if d > 22 then px(xx, y + 1, CH.deep) end end end
        end
        x = x + len + 10 + floor(hash(x, y, 17) * 22)
      end
    end
  end
  -- grease ice / slush: pale speckle drifting near the ice edges
  openW:each(function(x, y)
    local e = math.min(y - fIce[x], nIce[x] - y)
    if e < 5 and hash(x, y, 19) < .22 - e * .04 then px(x, y, hash(x, y, 20) < .5 and I.base or I.shade) end
  end)
  for i = 0, 50 do local x, y = floor(hash(i, 1, 18) * 480), 128 + floor(hash(i, 2, 18) * 60) if openW:has(x, y) and openW:has(x + 1, y) then px(x, y, GLINT) px(x + 1, y, Wt.hi) end end
  -- far shore ice: snow-topped shelf with a lit ice face and a dark water shadow under it
  for x = 0, 479 do
    local y0, y1 = yF(x), fIce[x]
    for y = y0, y1 do
      local h
      if y == y1 then h = I.shade
      elseif y == y1 - 1 then h = hash(x, y, 21) < .6 and I.base or I.hi
      else h = hash(x // 2, y, 22) < .2 and S.shade or (x < 240 and S.hi or S.base) end
      px(x, y, h)
    end
    px(x, y1 + 1, CH.deep)
    if hash(x // 3, 5, 23) < .4 then px(x, y1 + 2, CH.shade) end
    px(x, y0 - 1, S.shade)
  end
  -- near shore ice: a wide snow-dusted shelf, broken edge toward the channel, cracks, pressure lumps
  for x = 0, 479 do
    local y0, y1 = nIce[x], yN(x)
    for y = y0, y1 do
      local f = (y - y0) / math.max(1, y1 - y0)
      local v = F.vnoise(x / 9, y / 2, 206)
      local h = v < .38 and I.base or (v < .62 and I.hi or S.base)
      if f > .6 and hash(x, y, 207) < .5 then h = S.hi end
      if hash(x, y, 208) < .03 then h = I.shade end
      px(x, y, h)
    end
    px(x, y0, I.hi)
    if not openW:has(x, y0 - 1) then else px(x, y0 - 1, CH.deep) end
    if hash(x // 2, 6, 209) < .3 then px(x, y0 + 1, I.shade) end
  end
  -- long cracks in the near ice
  for i = 0, 26 do
    local x = floor(hash(i, 1, 210) * 470) local y = nIce[x] + 2
    local len = 6 + floor(hash(i, 2, 210) * 14)
    for k = 0, len do
      local xx, yy = x + k, y + floor(k * (hash(i, 3, 210) - .3) * .4)
      if yy > nIce[xx] + 1 and yy < yN(xx) - 1 then px(xx, yy, I.deep) px(xx, yy + 1, I.hi) end
    end
  end
  -- near bank lip: snow cornice over the ice foot, lilac undercut, icicles
  for x = 0, 479 do
    local yn = yN(x)
    for k = 1, 4 do px(x, yn + k, k == 1 and S.deep or (k == 2 and S.shade or (hash(x, k, 5) < .3 and S.base or S.hi))) end
    px(x, yn, I.shade)
    if hash(x, 7, 211) < .2 then px(x, yn + 1, I.base) end
  end
end

---------------------------------------------------------------- ice floes
local floeM = HP.mask()
local function floe(cx, cy, rx, ry, seed, bare)
  local pts = {}
  local n = 9
  for i = 0, n - 1 do
    local a = i / n * 2 * pi + hash(i, 1, seed) * .4
    local k = .72 + .4 * hash(i, 2, seed)
    pts[#pts + 1] = { cx + cos(a) * rx * k, cy + sin(a) * ry * k }
  end
  local top = poly(pts)
  local t = math.max(1, floor(ry / 3 + .5))
  local side = top:shift(0, t):cut(top)
  -- shadow and reflection in the water under it
  top:shift(1, t + 1):cut(top):cut(side):each(function(x, y) if openW:has(x, y) then px(x, y, CH.deep) end end)
  for y = cy + ry, cy + ry + 2 + t * 2, 2 do for x = cx - rx + 2, cx + rx - 2 do
    if openW:has(x, y) and not top:has(x, y) and not side:has(x, y) and hash(x // 2, y, seed) < .5 then px(x, y, mix(I.base, CH.base, .5)) end
  end end
  side:each(function(x, y) px(x, y, (x < cx - rx * .3) and I.base or ((hash(x, y, seed) < .3) and I.deep or I.shade)) end)
  top:each(function(x, y)
    local u, v = (x - cx) / rx, (y - cy) / ry
    local h
    if bare then h = (u + v < -.3) and I.hi or (hash(x // 3, y, seed) < .3 and I.shade or I.base)
    else h = (u + v < -.4) and S.hi or ((u + v > .6) and S.shade or S.base)
      if hash(x, y, seed + 1) < .05 then h = I.base end end
    if not top:has(x, y - 1) then h = bare and GLINT or S.hi end
    if not top:has(x + 1, y) or not top:has(x, y + 1) then h = bare and I.shade or S.shade end
    px(x, y, h)
  end)
  if not bare and rx > 9 then -- a crack and a snow ripple
    for k = -rx // 2, rx // 3 do px(cx + k, cy + floor(k * .15), S.shade) end
  end
  floeM:add(top):add(side)
  openW:cut(top):cut(side)
  return top
end
F.depth(1)
local floes = {
  { 22, 152, 14, 4, 301 }, { 126, 136, 10, 3, 302, true }, { 204, 140, 9, 2, 303 },
  { 40, 168, 18, 5, 305 }, { 118, 162, 15, 4, 306 }, { 178, 160, 9, 3, 307, true }, { 404, 148, 18, 4, 308 },
  { 448, 140, 13, 3, 309 }, { 434, 164, 12, 3, 310, true }, { 386, 135, 7, 2, 311 }, { 470, 154, 8, 3, 312, true },
  { 18, 136, 8, 2, 313, true }, { 222, 133, 6, 2, 314 }, { 82, 172, 9, 3, 315 }, { 380, 158, 6, 2, 316, true },
  { 196, 168, 8, 2, 317 }, { 466, 172, 10, 3, 318 },
}
for _, f in ipairs(floes) do floe(f[1], f[2], f[3], f[4], f[5], f[6]) end
-- pancake ice: little rounded plates with raised rims scattered through the channel
for i = 0, 70 do
  local x, y = floor(hash(i, 1, 320) * 480), 132 + floor(hash(i, 2, 320) * 50)
  local w = 1 + floor((y - 128) / 18 + hash(i, 3, 320) * 2)
  if openW:has(x - w - 1, y) and openW:has(x + w + 1, y) and openW:has(x, y + 2) and not (x > 262 and x < 374 and y < 172) and not (x > 50 and x < 118 and y < 152) then
    hline(x - w, x + w, y, I.hi) hline(x - w + 1, x + w - 1, y + 1, I.base) px(x + w, y + 1, I.shade) hline(x - w + 1, x + w, y + 2, CH.deep)
  end
end
-- the seal floe: a large flat floe with a bearded seal hauled out on it
local sealF = floe(160, 144, 22, 5, 304)
F.depth(2)
F.sprite({
  ".......ddddd......",
  "....ddDDDDDDdd....",
  "..wdDDDDDDDDDDd...",
  ".dDeDDDDDDDDDDDdd.",
  "nDDDDDDDDDDDDDDDdd",
  "wwdDDDDDDDDDDDDd.d",
  "..wddddddddddddd..",
}, 150, 135, { D = L.deer.shade, d = L.deer.deep, e = INK, n = INK, w = L.awnB.hi })
hline(150, 166, 140, L.deer.base)
hline(152, 166, 136, L.deer.hi) hline(154, 164, 137, L.deer.base) px(150, 140, L.awnB.base)

---------------------------------------------------------------- frost smoke drifting over the open channel
F.depth(0)
for y = 128, 168 do
  local x = floor(hash(y, 3, 41) * 40)
  while x < 480 do
    local len = 8 + floor(hash(x, y, 42) * 22)
    if hash(x // 11, y, 43) < .34 - (y - 128) * .007 then
      for xx = x, x + len do
        if openW:has(xx, y) and hash(xx, y, 44) < .75 and not (xx > 262 and xx < 374 and y > 128 and y < 172) then
          local v = c:get(xx, y + DY) if v then px(xx, y, mix(v, "#eef0f6", .5)) end
        end
      end
    end
    x = x + len + 10 + floor(hash(x, y, 45) * 30)
  end
end

---------------------------------------------------------------- far bank: road on, landing, hut, ferry house, rack
F.depth(1)
F.drawRoad(113, 122)
F.tree(112, 122, 30, 5)
F.tree(20, 122, 40, 2)
F.tree(96, 121, 24, 4)
F.willow(130, 122, 5, 4, 230) F.willow(8, 123, 4, 3, 231)
do -- a sod-roofed driftwood hut with peat smoke
  local top, cx, wallM, roofM = F.building{ x0 = 36, x1 = 80, yb = 122, wh = 13, rh = 11, wall = L.timber, roof = L.roof, noFrame = true, noAttic = true, chimney = true, snow = 3, icicles = 3 }
  F.planks(wallM, L.timber, 3, false, 232)
  F.window(44, 113, 48, 116, L.timber) F.window(68, 113, 72, 116, L.timber)
  F.smoke(70, 94, 4, .6, 2)
  F.drift(30, 122, 8, 3, 233)
end
-- far bank sedge and cotton grass along the shore
local function sedgeClump(x, yb, n, hmax, seed, near)
  local blades = {}
  for i = 1, n do
    local bx = x + floor((hash(i, 1, seed) - .5) * n * 1.6)
    local h = floor(hmax * (.55 + .45 * hash(i, 2, seed)))
    local lean = (hash(i, 3, seed) - .3) * (near and 8 or 4)
    blades[#blades + 1] = { bx, h, lean, hash(i, 4, seed) }
  end
  local m = HP.mask()
  local heads = {}
  for _, b in ipairs(blades) do
    local bx, h, lean, v = b[1], b[2], b[3], b[4]
    local pts = { { bx, yb }, { bx + lean * .3, yb - h * .5 }, { bx + lean, yb - h } }
    m:add(line(pts, near and (v < .6 and 2 or 1) or 1))
    if v < .5 then heads[#heads + 1] = { floor(bx + lean), yb - h - 1, v < .25 } end
  end
  if near then c:rim(m, L.fern.edge) end
  m:each(function(xx, yy)
    local t = (yb - yy) / hmax
    local hsh = hash(xx, yy, seed)
    local col = t > .6 and L.fern.hi or (t > .25 and L.fern.base or L.fern.shade)
    if hsh < .22 then col = L.fern.shade elseif hsh > .9 then col = L.rust.base end
    if near and not m:has(xx - 1, yy) and hsh < .3 then col = S.hi end -- rime on the windward side
    if yy >= yb - 1 then col = L.fern.deep end
    px(xx, yy, col)
  end)
  for _, hd in ipairs(heads) do
    local hx, hy, cotton = hd[1], hd[2], hd[3]
    if near then
      if cotton then -- cotton grass: a white tuft with a dark rim
        local cm = c:ellipse(hx, hy - 1, 2, 2) c:rim(cm, L.fur.deep) fill(cm, L.fur.base) px(hx - 1, hy - 2, GLINT) px(hx + 1, hy, L.fur.shade)
      else
        local cm = rect(hx - 1, hy - 4, hx, hy) c:rim(cm, L.soil.edge) fill(cm, L.soil.base) vline(hx - 1, hy - 4, hy - 1, L.soil.hi) px(hx, hy - 4, S.hi)
      end
    else
      px(hx, hy, cotton and L.fur.hi or L.soil.base) px(hx, hy - 1, cotton and L.fur.base or L.soil.shade)
    end
  end
end
for _, r in ipairs({ { 14, 8 }, { 110, 9 }, { 150, 12 }, { 192, 8 }, { 300, 8 }, { 352, 10 }, { 466, 8 } }) do
  sedgeClump(r[1], yF(r[1]) + 1, r[2], 7, r[1], false)
end
-- far landing
do
  local d = poly{ { 234, 121 }, { 248, 121 }, { 250, 130 }, { 232, 130 } }
  rimOf(d, L.timber) part(d, L.board) F.planks(d, L.board, 3, false, 4)
  hline(234, 248, 121, S.hi) for y = 123, 129, 3 do px(233 + (y % 2), y, S.base) end
  for _, x in ipairs({ 233, 248 }) do vline(x, 131, 135, L.timber.deep) px(x, 131, I.hi) end
end
F.depth(2)
-- snowy spruces on the far bank right of the landing, behind the rack
F.tree(290, 124, 46, 2)
F.tree(318, 123, 30, 1)
F.tree(352, 124, 40, 0)
F.tree(410, 123, 44, 1)
F.tree(458, 124, 56, 2)
F.tree(474, 125, 34, 6)
do -- the ferryman's ochre house: slate roof under snow, white trim, lantern pole and a bell post
  local top, cx, wallM, roofM = F.building{ x0 = 164, x1 = 214, yb = 125, wh = 20, rh = 16, wall = OCHRE, roof = L.roof2, shingle = true, noAttic = true, chimney = true, noFrame = true, snow = 4, icicles = 5 }
  F.planks(wallM, OCHRE, 3, true, 240)
  part(union(rect(164, top, 165, 124), rect(213, top, 214, 124)), L.plaster, { nopop = true, noshade = true })
  F.door(184, 113, 192, 124, L.wall2)
  F.window(171, 110, 176, 115, L.plaster) F.window(201, 110, 206, 115, L.plaster)
  F.smoke(205, 78, 6, .7, 2)
  F.drift(220, 125, 10, 4, 241)
  -- the far ferry bell post at the landing
  local bp = rect(222, 100, 223, 125):add(rect(218, 100, 230, 101)) rimOf(bp, L.timber) part(bp, L.timber, { nopop = true, noshade = true })
  hline(218, 230, 99, S.hi)
  local fb = poly{ { 226, 102 }, { 229, 102 }, { 230, 107 }, { 225, 107 } } c:rim(fb, L.timber.edge) part(fb, L.gold, { nopop = true })
  local lp = rect(256, 98, 257, 125) rimOf(lp, L.timber) part(lp, L.timber, { nopop = true, noshade = true })
  fill(rect(256, 98, 262, 98), L.timber.base) hline(256, 262, 97, S.hi)
  local lam = rect(259, 100, 263, 105) rimOf(lam, L.timber) fill(lam, L.glow.base) px(260, 101, L.glow.hi) vline(263, 101, 105, L.glow.shade)
  -- washing between a pole and the house: a knitted sweater, a mitten, a sheet
  local wp = rect(132, 106, 133, 124) rimOf(wp, L.timber) part(wp, L.timber, { nopop = true, noshade = true })
  F.washing(133, 106, 163, 108, { { "shirt", L.wall2 }, { "sock", L.accent }, { "sheet", L.awnB } }, 3)
  hline(130, 135, 105, S.hi)
  for _, p in ipairs({ { 141, 113 }, { 141, 116 } }) do hline(p[1] - 2, p[1] + 2, p[2], L.plaster.hi) end -- sweater pattern bands
end
-- a small gnome waving from the far landing
F.gnome(242, 128, { small = true, hat = L.awnA, coat = L.wall2, arm = "up" })
do -- the stockfish drying rack (hjell): pole A-frames, two rails hung with paired fish, snow on the rails, ravens
  local poles = HP.mask()
  for _, ax in ipairs({ 398, 428, 458 }) do
    poles:add(line({ { ax - 4, 126 }, { ax, 94 } }, 1)):add(line({ { ax + 4, 126 }, { ax, 94 } }, 1))
  end
  local rails = rect(392, 96, 464, 97):add(rect(394, 108, 462, 108))
  rimOf(union(poles, rails), L.timber)
  part(poles, L.timber, { nopop = true, noshade = true }) part(rails, L.timber, { nopop = true, noshade = true })
  for x = 392, 464 do if hash(x // 2, 1, 250) < .7 then px(x, 95, x < 428 and S.hi or S.base) end end
  for _, ry in ipairs({ 98, 109 }) do
    for x = 396, 461, 3 do
      if hash(x, ry, 251) < .82 then
        local len = 6 + floor(hash(x, ry, 252) * 3)
        local fm = rect(x, ry, x + 1, ry + len)
        fill(fm, FISH.base) vline(x, ry + 1, ry + len - 2, FISH.hi) vline(x + 1, ry + 2, ry + len, FISH.shade)
        px(x, ry + len, FISH.deep) px(x + 1, ry + len + 1, FISH.deep) px(x - 1, ry + len + 1, FISH.shade) -- tail
        px(x, ry, FISH.deep)
      end
    end
  end
  -- two ravens on the top rail
  for _, rv in ipairs({ { 404, 89, false }, { 446, 90, true } }) do
    F.sprite(rv[3] and { ".kk...", "kKKk..", "eKKKKk", ".KKKKKk", "..g.g.." } or { "...kk.", "..kKKk", "kKKKKe", "kKKKKK.", "..g.g.." },
      rv[1], rv[2], { k = "#3a3848", K = "#4e4c5e", e = "#2c2a36", g = "#2c2a36" })
  end
  -- the ferry rope post: a tall post with a pulley, guy line to a stake
  local rp = rect(386, 90, 388, 127)
  local guy = line({ { 386, 92 }, { 372, 126 } })
  rimOf(rp, L.timber) part(rp, L.timber, { nopop = true }) guy:each(function(x, y) px(x, y, L.board.deep) end)
  local wheel = c:ellipse(387, 91, 3, 3) c:rim(wheel, L.timber.edge) fill(wheel, L.iron.base) px(386, 90, L.iron.hi) px(387, 91, L.iron.deep)
  hline(384, 390, 87, S.hi)
end
-- reflections of the far bank in the channel (broken dashes)
for x = 0, 479 do
  local y0 = fIce[x] + 3
  local v = c:get(x, yF(x) - 6)
  if v and hash(x, 1, 31) < .55 then
    for y = y0, y0 + 5, 2 do if openW:has(x, y) and hash(x, y, 32) < .6 then px(x, y, mix(v, CH.base, .6)) end end
  end
end

---------------------------------------------------------------- left water: a gnome in a kayak among the floes
F.depth(2)
do
  local x0, x1, y = 62, 100, 142
  local hull = poly{ { x0 - 6, y - 1 }, { x0 + 6, y - 3 }, { x1 - 6, y - 3 }, { x1 + 6, y - 1 }, { x1 - 4, y + 3 }, { x0 + 4, y + 3 } }
  F.gnome(80, y - 1, { small = true, hat = L.awnA, coat = L.gold, arm = "out", noShadow = true })
  rimOf(hull, L.timber) part(hull, L.wall2, { nopop = true }) hline(x0, x1, y, L.board.base) hline(x0 + 4, x1 - 4, y + 2, L.wall2.deep)
  for k = 0, 2 do hline(x0 + k * 3, x1 - k * 3, y + 5 + k * 2, CH.deep) end
  -- double paddle, blades dripping
  line({ { 64, 132 }, { 98, 146 } }):each(function(x, yy) px(x, yy, L.board.shade) end)
  for _, b in ipairs({ { 62, 130 }, { 97, 145 } }) do local bm = rect(b[1], b[2], b[1] + 3, b[2] + 2) c:rim(bm, L.timber.edge) fill(bm, L.gold.base) px(b[1], b[2], L.gold.hi) end
  px(99, 149, GLINT) px(100, 151, Wt.hi) hline(94, 104, 152, Wt.hi)
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
  -- snow swept to the deck edges, a cleared path down the middle with boot prints
  deck:each(function(x, y) if abs(x - 240) > 15 - (y - LY0) * .1 and hash(x // 2, y, 105) < .55 then px(x, y, x < 240 and S.hi or S.base) end end)
  part(face, L.timber, { nopop = true, noshade = true })
  F.icicles(floor(F.xl(LY0)) - 6, floor(F.xr(LY0)) + 6, LY0, 4, 106, .5)
  for x = floor(F.xl(LY0)) - 5, floor(F.xr(LY0)) + 5, 7 do px(x, LY0 - 2, L.iron.hi) end
  for _, x in ipairs({ floor(F.xl(LY0)) - 6, floor(F.xr(LY0)) + 4 }) do
    hline(x - 2, x + 4, LY0 + 7, I.hi) hline(x - 1, x + 3, LY0 + 6, I.base) -- ice collar
    hline(x, x + 2, LY0 - 7, S.hi) hline(x - 1, x + 3, LY0 - 6, S.base)
  end
end

---------------------------------------------------------------- the sled-ferry (centre hero)
local RX0, RX1, RY0, RY1 = 270, 366, 137, 152
local FY = RY1 - 6
local function fox(x0, y0)
  F.sprite({
    "...........RR.....",
    "..........RRr.....",
    ".........HRRr.....",
    "........HRRRr.....",
    "........RRRRr.....",
    ".......HRRRRRr....",
    ".....q.RRRRRRr....",
    ".....QqHRRRRRRr...",
    ".....bbbbbbbbbbb..",
    "......FFFFFFFFf...",
    ".....FFeFFFFFFf...",
    "..kFFFFFFFFFFFf...",
    "...ffFFFFFFFFf....",
    ".....ffFFFFFFf....",
    "......FFFFFFFf....",
    ".....FFFFFFFFFf...",
    "....FFFFFFFFFFf...",
    "....FFFFFFFFFFf.ff",
    "....FFfFFFFFFFffFf",
    "....FFfFFFFFFFFFFf",
    "....FFfFFFFFFFFFf.",
    ".....ffFFFFFFFff..",
    "....kk.kk.ffff....",
  }, x0, y0, { R = L.awnA.base, r = L.awnA.shade, H = L.awnA.hi, b = L.gold.hi, F = L.fur.hi, f = L.fur.deep,
    q = L.fur.base, Q = INK, e = INK, k = INK })
end
do
  -- reflection and wake in the open lead
  for x = RX0, RX1 do for y = RY1 + 6, RY1 + 15 do
    if openW:has(x, y) and (y % 2 == 0) and hash(x // 2, y, 41) < .55 - (y - RY1) * .03 then px(x, y, mix(L.timber.shade, CH.base, .45)) end
  end end
  for k = 0, 2 do px(RX0 - 5 - k, RY0 + 8 + k * 3, GLINT) hline(RX0 - 8 - k * 3, RX0 - 5 - k * 2, RY0 + 10 + k * 3, Wt.hi) end
  for k = 0, 3 do hline(RX0 - 8 - k * 5, RX0 - 2 - k * 2, RY1 + 7 + k * 2, Wt.hi) hline(RX1 + 2 + k * 2, RX1 + 8 + k * 5, RY1 + 7 + k * 2, Wt.hi) end
  for x = RX0 - 2, RX1 + 2 do if (x // 3) % 2 == 0 then px(x, RY1 + 6, CH.deep) end end
  -- broken ice chunks the ferry pushes aside
  for _, ch in ipairs({ { RX0 - 10, RY1 + 2 }, { RX0 - 4, RY1 + 9 }, { RX1 + 6, RY1 + 3 }, { RX1 + 12, RY1 + 10 }, { RX0 + 30, RY1 + 13 } }) do
    hline(ch[1], ch[1] + 4, ch[2], I.hi) hline(ch[1] + 1, ch[1] + 4, ch[2] + 1, I.shade) hline(ch[1] + 1, ch[1] + 5, ch[2] + 2, CH.deep)
  end
  local deck = poly{ { RX0 + 4, RY0 }, { RX1 - 4, RY0 }, { RX1, RY1 }, { RX0, RY1 } }
  local face = rect(RX0, RY1 + 1, RX1, RY1 + 3)
  -- the sled runners: iron-shod, curling up at the bow (left, toward the landing)
  local runner = line({ { RX0 + 3, RY1 + 5 }, { RX1 - 1, RY1 + 5 } }, 2):add(line({ { RX0 + 3, RY1 + 5 }, { RX0 - 3, RY1 + 3 }, { RX0 - 6, RY1 - 1 }, { RX0 - 5, RY1 - 4 } }, 2))
  local stan = HP.mask()
  for x = RX0 + 8, RX1 - 6, 14 do stan:add(rect(x, RY1 + 4, x + 1, RY1 + 4)) end
  local posts = HP.mask()
  for _, x in ipairs({ RX0 + 1, RX1 - 2 }) do posts:add(rect(x, RY1 - 9, x + 1, RY1)) end
  for _, x in ipairs({ RX0 + 5, RX1 - 6 }) do posts:add(rect(x, RY0 - 8, x + 1, RY0)) end
  rimOf(union(deck, face, runner, stan), L.timber)
  part(runner, L.iron, { nopop = true }) runner:each(function(x, y) if not runner:has(x, y - 1) then px(x, y, L.iron.hi) end end)
  part(stan, L.timber, { nopop = true, noshade = true })
  part(deck, L.board) F.planks(deck, L.board, 5, true, 17)
  -- frost and trodden snow on the deck
  deck:each(function(x, y)
    local v = hash(x // 4, y // 3, 108)
    if v < .2 then px(x, y, ((x % 5) == 0) and L.board.shade or S.base) end
    if (y >= RY1 - 1 or y <= RY0 + 1) and hash(x, y, 109) < .5 then px(x, y, x < 318 and S.hi or S.base) end
  end)
  hline(RX0 + 4, RX1 - 4, RY0, S.hi)
  part(face, L.wall2, { nopop = true }) hline(RX0, RX1, RY1 + 1, L.wall2.hi)
  F.icicles(RX0 + 1, RX1 - 1, RY1 + 4, 3, 112, .35)
  for x = RX0 + 4, RX1 - 4, 8 do px(x, RY1 + 2, L.iron.hi) px(x + 1, RY1 + 2, L.iron.deep) end -- bolts
  -- far rail behind the cargo
  for x = RX0 + 6, RX1 - 6 do px(x, RY0 - 6 + floor(2 * sin((x - RX0) / (RX1 - RX0) * pi)), L.board.shade) end
  -- cargo: milk churns with snow lids, a crate of fish, a stack of driftwood
  local fc = F.crate(RX1 - 34, RY0 + 6, 12, 8)
  for k = 0, 3 do local fx = RX1 - 33 + k * 3 vline(fx, RY0 - 4, RY0 - 2, FISH.base) px(fx, RY0 - 5, FISH.deep) px(fx + 1, RY0 - 3, FISH.hi) end
  for _, cx in ipairs({ RX0 + 9, RX0 + 16 }) do
    local ch = c:rrect(cx - 3, RY0 - 4, cx + 3, RY0 + 6, 2):add(rect(cx - 1, RY0 - 6, cx + 1, RY0 - 4))
    c:rim(ch, L.iron.edge) part(ch, L.iron) hline(cx - 3, cx + 3, RY0 - 1, L.iron.deep) px(cx - 2, RY0 - 3, L.iron.hi)
    hline(cx - 1, cx + 1, RY0 - 7, S.hi)
  end
  for k = 0, 2 do F.logEnd(RX1 - 18 + k * 4, RY0 + 4, 2) end
  F.logEnd(RX1 - 16, RY0, 2) F.logEnd(RX1 - 12, RY0, 2)
  hline(RX1 - 18, RX1 - 10, RY0 - 3, S.hi)
  -- the falu-red trunk the fox rides on
  local T0 = RX0 + 40
  local tk = rect(T0, RY0 + 1, T0 + 18, RY0 + 9)
  c:rim(tk, L.timber.edge) part(tk, L.wall2) hline(T0, T0 + 18, RY0 + 4, L.timber.deep) vline(T0 + 6, RY0 + 1, RY0 + 9, L.gold.shade) vline(T0 + 12, RY0 + 1, RY0 + 9, L.gold.shade)
  fill(rect(T0 + 8, RY0 + 4, T0 + 10, RY0 + 6), L.gold.base) px(T0 + 8, RY0 + 4, L.gold.hi)
  -- the traveller with a big bundle on a stick
  local gx = RX0 + 28
  fill(line({ { gx + 7, FY - 17 }, { gx - 9, FY - 23 } }), L.board.base)
  local bun = c:ellipse(gx - 11, FY - 23, 4, 4) c:rim(bun, L.timber.edge) part(bun, L.accent, { nopop = true })
  bun:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.awnB.hi) end end) px(gx - 11, FY - 27, L.accent.deep)
  F.gnome(gx, FY, { hat = L.lav, coat = L.deer, arm = "up", noShadow = true })
  -- QUIRK: the arctic fox in the red gnome hat, riding on the trunk
  fox(T0, RY0 - 22)
  -- the ferryman, poling from the back right corner
  local _, fx, fy = F.gnome(RX1 - 14, FY, { hat = L.leaf, coat = L.accent, arm = "up", noShadow = true, hatBand = L.gold.base })
  local pole = line({ { fx - 3, fy - 10 }, { fx + 14, RY1 + 16 } }, 1)
  fill(pole, L.board.shade) line({ { fx - 2, fy - 10 }, { fx + 15, RY1 + 16 } }):each(function(x, y) if y < RY1 + 4 then px(x, y, L.board.hi) end end)
  for k = 0, 2 do hline(fx + 10 - k * 3, fx + 18 + k * 3, RY1 + 17 + k * 2, Wt.hi) end
  -- near rail and posts in front of everyone, snow on the post tops
  part(posts, L.timber, { nopop = true, noshade = true })
  for _, x in ipairs({ RX0 + 1, RX1 - 2, RX0 + 5, RX1 - 6 }) do px(x, x < 300 and (x == RX0 + 1 and RY1 - 9 or RY0 - 8) or (x == RX1 - 2 and RY1 - 9 or RY0 - 8), S.hi) end
  for x = RX0 + 2, RX1 - 2 do px(x, RY1 - 7 + floor(2 * sin((x - RX0) / (RX1 - RX0) * pi)), L.board.deep) end
  -- the ferry rope: from the far pulley post down to a block on the back post, rime along its top
  local x0, y0, x1, y1 = RX1 - 6, RY0 - 9, 387, 91
  local pts = {}
  for xx = x0, x1 do local t = (xx - x0) / (x1 - x0) pts[#pts + 1] = { xx, floor(y0 + (y1 - y0) * t + 5 * 4 * t * (1 - t) + .5) } end
  local rope = line(pts, 1)
  rope:each(function(x, y) px(x, y, (x + y) % 3 == 0 and L.board.deep or L.board.shade) if hash(x, y, 113) < .3 then px(x, y - 1, S.hi) end end)
  local blk = rect(x0 - 1, y0 - 1, x0 + 2, y0 + 1) c:rim(blk, L.timber.edge) fill(blk, L.iron.base) px(x0 - 1, y0 - 1, L.iron.hi)
end

---------------------------------------------------------------- near bank: gnome hauling the tow rope on the landing
F.depth(3)
do
  local _, hx, hy = F.gnome(244, 200, { hat = L.gold, coat = L.wall2, arm = "up" })
  local x0, y0 = RX0 + 2, RY1 - 8
  local pts = {}
  for xx = hx, x0 do local t = (xx - hx) / (x0 - hx) pts[#pts + 1] = { xx, floor(hy + (y0 - hy) * t + 9 * 4 * t * (1 - t) + .5) } end
  local rope = line(pts, 2)
  c:rim(rope, L.timber.edge)
  rope:each(function(x, y) local top = not rope:has(x, y - 1) px(x, y, top and L.board.hi or L.board.base) if (x + y) % 3 == 0 then px(x, y, L.board.shade) end end)
  for _, p in ipairs(pts) do if p[2] > yN(p[1]) - 6 and p[1] % 4 == 0 then px(p[1], p[2] + 2, I.base) px(p[1], p[2] + 3, I.deep) end end -- ice drips
  local coil = c:ellipse(232, 200, 6, 2) c:rim(coil, L.timber.edge) part(coil, L.board, { nopop = true }) c:ellipse(232, 200, 3, 1):edge():each(function(x, y) px(x, y, L.board.deep) end)
  local tail = line({ { hx - 1, hy + 1 }, { 236, 198 } }, 2) c:rim(tail, L.timber.edge) fill(tail, L.board.base) tail:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.board.shade) end end)
  F.steam(hx - 3, hy - 4, 3, .4, 115) -- breath in the cold
end

-- snowy spruces at the left of the near bank (behind the booth)
F.depth(3)
F.conifer(26, 196, 40, L.foliage, 131)
F.conifer(104, 186, 24, L.foliage2, 132)

DY = 10
---------------------------------------------------------------- near bank left: bell, sign, booth, bench, kick-sled
do -- the ferry bell on a frame under a slate hood
  local fr = rect(186, 150, 187, 196):add(rect(206, 150, 207, 196)):add(rect(183, 148, 210, 150))
  F.shadow(186, 208, 197, 4, 3)
  rimOf(fr, L.timber) part(fr, L.timber, { nopop = true, noshade = true }) hline(183, 210, 148, L.timber.hi)
  local roofb = poly{ { 181, 148 }, { 196, 140 }, { 212, 148 } } rimOf(roofb, L.roof2) part(roofb, L.roof2, { nopop = true })
  F.courses(roofb, 140, 3, 4, L.roof2)
  F.snowCap(roofb, 2, 114, { cx = 197, lip = true })
  F.icicles(182, 211, 149, 3, 116, .5)
  vline(196, 151, 153, L.iron.shade)
  local bell = poly{ { 193, 154 }, { 199, 154 }, { 201, 163 }, { 203, 165 }, { 189, 165 }, { 191, 163 } }:add(c:ellipse(196, 155, 3, 2))
  c:rim(bell, L.timber.edge) part(bell, L.gold) vline(193, 156, 163, L.gold.hi) hline(190, 202, 164, L.gold.shade)
  hline(194, 198, 153, S.hi)
  fill(rect(195, 166, 197, 167), L.iron.base)
  fill(line({ { 197, 167 }, { 199, 180 } }), L.board.shade)
end
do -- the ferry sign: a painted sled-ferry on a rope, floes on a blue river
  local post = rect(170, 168, 171, 200)
  local bd = rect(156, 152, 185, 168)
  rimOf(union(post, bd), L.timber) part(post, L.timber, { nopop = true }) part(bd, L.board, { nopop = true })
  c:edgeIn(bd, L.board.deep)
  fill(rect(158, 162, 183, 166), L.accent.base) hline(158, 183, 162, L.accent.hi)
  for _, fx in ipairs({ 159, 177 }) do hline(fx, fx + 4, 164, L.awnB.hi) hline(fx + 1, fx + 4, 165, L.awnB.shade) end
  fill(rect(164, 160, 176, 162), L.wall2.base) hline(164, 176, 160, L.wall2.hi)
  vline(166, 155, 159, L.timber.edge) vline(174, 155, 159, L.timber.edge) fill(rect(168, 156, 172, 159), L.awnA.base)
  line({ { 157, 154 }, { 184, 157 } }):each(function(x, y) px(x, y, L.timber.deep) end) -- the rope
  hline(155, 186, 151, S.hi) hline(156, 185, 152, S.base)
end
F.depth(3)
do -- the ticket booth: driftwood walls, a sod roof under snow, a gnome in the warm-lit hatch
  local wall = rect(38, 168, 92, 200)
  local roof = poly{ { 32, 170 }, { 65, 146 }, { 98, 170 } }:add(rect(32, 168, 98, 171))
  F.shadow(40, 92, 200, 6, 4)
  rimOf(union(wall, roof), L.timber)
  part(wall, L.timber) F.planks(wall, L.timber, 4, true, 3)
  part(roof, L.roof, { sep = true }) F.sod(roof, L.roof, 146, 65)
  F.snowCap(roof, 5, 117, { cx = 64, lip = true })
  F.icicles(32, 98, 172, 5, 118, .5)
  local hatch = rect(50, 178, 80, 192)
  fill(hatch, L.soil.deep) c:edgeIn(hatch, L.timber.hi)
  fill(rect(51, 179, 57, 184), L.glow.shade) fill(rect(51, 179, 54, 181), L.glow.base) px(52, 179, L.glow.hi) -- a lamp inside
  F.gnome(65, 198, { hat = L.awnA, coat = L.accent, arm = "out", noShadow = true })
  local sill = rect(48, 192, 82, 194) rimOf(sill, L.timber) part(sill, L.board, { nopop = true }) hline(48, 82, 191, S.hi)
  fill(rect(76, 189, 78, 191), L.awnB.hi) px(77, 189, L.awnA.base)
  local aw = poly{ { 46, 172 }, { 84, 172 }, { 88, 178 }, { 42, 178 } }
  rimOf(aw, L.awnA) fill(aw, L.awnA.base)
  aw:each(function(x, y) if ((x - 42) // 5) % 2 == 1 then px(x, y, L.awnB.base) end if y == 178 then px(x, y, ((x // 3) % 2 == 0) and L.awnA.deep or L.awnA.shade) end end)
  hline(46, 84, 172, S.hi) hline(47, 83, 173, S.base)
  F.window(86, 158, 88, 161, L.timber)
  -- a pair of antlers over the hatch
  F.sprite({ "b.b.....b.b", ".bb.....bb.", "..bbbbbbb.." }, 60, 163, { b = L.timber.shade }, { rim = false })
  F.drift(36, 200, 10, 5, 119)
end
do -- bench with two waiting travellers on a reindeer skin, and their luggage
  local seat = rect(100, 207, 146, 209)
  local legs = rect(103, 210, 104, 218):add(rect(142, 210, 143, 218))
  F.shadow(102, 146, 219, 5, 3)
  rimOf(union(seat, legs), L.timber) part(legs, L.timber, { nopop = true, noshade = true }) part(seat, L.board, { nopop = true }) hline(100, 146, 207, L.board.hi)
  local skin = poly{ { 104, 206 }, { 140, 206 }, { 142, 212 }, { 136, 214 }, { 108, 214 }, { 102, 211 } }
  c:rim(skin, L.deer.edge) part(skin, L.deer, { nopop = true })
  skin:each(function(x, y) if hash(x, y, 120) < .25 then px(x, y, L.fur.shade) end end)
  F.gnome(112, 214, { hat = L.roof, coat = L.lav, arm = "hold", noShadow = true })
  F.gnome(134, 215, { hat = L.accent, coat = L.awnA, flip = true, noShadow = true })
  local tr = c:rrect(150, 204, 168, 218, 3):clip(rect(150, 204, 168, 218))
  F.shadow(150, 168, 219, 4, 2)
  rimOf(tr, L.timber) part(tr, L.wall2) hline(150, 168, 209, L.iron.base) vline(155, 204, 218, L.iron.shade) vline(163, 204, 218, L.iron.shade) px(159, 211, L.glow.hi)
  F.snowCap(tr, 2, 121)
  local bag = c:rrect(152, 222, 166, 232, 3) rimOf(bag, L.timber) part(bag, L.lav)
  bag:each(function(x, y) if (x + y) % 4 == 0 then px(x, y, L.lav.hi) end end)
  fill(c:ellipse(159, 221, 3, 2):cut(c:ellipse(159, 221, 1, 1)):clip(rect(150, 218, 168, 221)), L.timber.base)
end
do -- a kick-sled (spark) with a bundle on its chair, a sled dog lying beside it
  local y = 228
  local runner = line({ { 20, y + 6 }, { 74, y + 6 } }):add(line({ { 74, y + 6 }, { 79, y + 3 }, { 78, y } })):add(line({ { 24, y + 5 }, { 70, y + 5 } }))
  local seatM = rect(56, y - 6, 70, y - 4)
  local back = rect(54, y - 16, 56, y - 4)
  local legs = rect(57, y - 3, 58, y + 4):add(rect(68, y - 3, 69, y + 4)):add(rect(54, y - 3, 55, y + 4))
  local handle = rect(50, y - 20, 58, y - 18)
  local m = union(runner, seatM, back, legs, handle)
  F.shadow(22, 76, y + 8, 4, 2)
  rimOf(m, L.timber)
  part(runner, L.iron, { nopop = true, noshade = true }) hline(20, 74, y + 6, L.iron.hi)
  part(union(seatM, back, legs, handle), L.wall2, { nopop = true })
  hline(56, 70, y - 7, S.hi) hline(50, 58, y - 21, S.hi)
  local bun = c:rrect(58, y - 14, 68, y - 7, 2) c:rim(bun, L.timber.edge) part(bun, SACK)
  hline(58, 68, y - 11, L.awnA.base)
  -- the sled dog: grey back, white face and belly, curled tail, pale eyes
  F.sprite({
    "..k.k.............",
    ".kKkKk......t.....",
    "kKwKKKk....tTt....",
    "kweWwKKKKKKKKTt...",
    "nwwWWKKKKKKKKKk...",
    ".wwWWWWWKKKKKKKk..",
    "..WWWWWWWWWWWWWw..",
    "..ww.ww...ww.ww...",
  }, 26, y - 7, { k = "#4a4858", K = "#6a6878", w = L.fur.base, W = L.fur.hi, e = "#6a8cbc", n = INK, t = "#6a6878", T = L.fur.base })
end
DY = 0
-- near sedge beds, cotton grass and willow scrub on both sides of the landing
sedgeClump(214, yN(214) + 3, 12, 20, 3, true)
sedgeClump(120, yN(120) + 3, 10, 16, 5, true)
sedgeClump(392, yN(392) + 3, 12, 20, 7, true)
sedgeClump(452, yN(452) + 3, 9, 18, 9, true)
sedgeClump(20, yN(20) + 3, 8, 15, 11, true)
F.willow(226, yN(226) + 5, 5, 7, 133) F.willow(106, yN(106) + 5, 4, 6, 134)

---------------------------------------------------------------- the river right: guillemots, a skin boat frozen into the ice
F.depth(3)
local function guillemot(x, y)
  local m = c:ellipse(x, y, 3, 2):add(c:ellipse(x - 3, y - 2, 1, 1))
  c:rim(m, INK) fill(m, "#3c3a48") px(x - 3, y - 3, "#56546a") hline(x - 1, x + 1, y - 1, L.fur.hi) px(x, y, L.fur.base)
  px(x - 3, y - 2, L.fur.base) hline(x - 4, x + 4, y + 3, Wt.hi)
end
guillemot(290, 170) guillemot(298, 174) guillemot(312, 165)
do -- a skin boat (umiak) caught in the shore ice, snow along its gunwale
  local y = 186
  local hull = poly{ { 418, y - 3 }, { 472, y - 3 }, { 466, y + 4 }, { 424, y + 4 } }
  rimOf(hull, L.timber) part(hull, L.deer) hline(420, 470, y, L.deer.deep)
  for x = 426, 466, 6 do vline(x, y - 2, y + 3, L.deer.shade) end
  hline(418, 472, y - 4, S.hi) hline(420, 470, y - 3, S.base)
  for x = 420, 470 do if hash(x, 1, 122) < .5 then px(x, y + 5, I.hi) px(x, y + 6, I.base) end end
  local st = rect(410, y - 12, 412, y + 6) rimOf(st, L.timber) part(st, L.timber, { nopop = true, noshade = true })
  hline(409, 413, y - 13, S.hi)
  fill(line({ { 412, y - 8 }, { 422, y - 2 } }), L.board.shade)
end

---------------------------------------------------------------- near bank right: cargo waiting to cross, a gnome on a crate
F.depth(3)
do
  F.snowCap(F.crate(300, 222, 18, 12), 2, 123)
  local fc = F.crate(318, 222, 16, 12)
  for k = 0, 4 do local fx = 320 + k * 3 vline(fx, 207, 209, FISH.base) px(fx, 206, FISH.deep) px(fx + 1, 208, FISH.hi) end
  F.snowCap(F.crate(306, 209, 16, 10, L.apple), 1, 124)
  F.snowCap(F.sack(342, 224, SACK, 7), 2, 125) F.snowCap(F.sack(354, 226, SACK, 6), 2, 126)
  F.snowCap(F.barrel(288, 224, L.timber, 12), 2, 127)
  local _, hx, hy = F.gnome(372, 236, { hat = L.lav, coat = L.leaf, arm = "out", flip = true })
  local ap = c:ellipse(hx - 1, hy - 2, 2, 2) c:rim(ap, L.timber.edge) part(ap, L.apple, { nopop = true }) px(hx - 1, hy - 5, L.greyMoss.base)
  -- the lantern on a post at the landing's right
  local lp = rect(280, 160, 281, 200) rimOf(lp, L.timber) part(lp, L.timber, { nopop = true, noshade = true })
  local lam = rect(277, 152, 284, 160) rimOf(lam, L.timber) fill(lam, L.glow.base) fill(rect(278, 153, 280, 158), L.glow.hi) vline(284, 153, 160, L.glow.shade)
  fill(rect(276, 150, 285, 151), L.timber.base) hline(276, 285, 149, S.hi)
  F.icicles(277, 284, 161, 2, 128, .4)
end
-- foreground: a barrow of fish waiting for the ferry with a gull on the rim, snow-capped rocks
do
  local y = 250
  local tray = poly{ { 96, y - 12 }, { 132, y - 12 }, { 128, y - 2 }, { 100, y - 2 } }
  local legs = rect(102, y - 2, 103, y + 4):add(line({ { 132, y - 8 }, { 146, y - 2 } }, 2))
  local wh = c:ellipse(92, y, 5, 5)
  F.shadow(92, 132, y + 5, 5, 3)
  -- the heap of fish first (behind the tray's front)
  for k = 0, 6 do
    local fx, fy = 100 + (k % 3) * 9 + (k // 3) * 4, y - 14 - (k // 3) * 3 + floor(hash(k, 2, 129) * 2)
    local flip = k % 2 == 1
    F.sprite(flip and { "tt.......", ".tSSSSSh.", "tssssssse" } or { ".......tt", ".hSSSSSt.", "essssssst" }, fx, fy,
      { S = L.iron.hi, s = L.iron.base, h = L.iron.hi, t = L.iron.shade, e = INK })
  end
  rimOf(union(tray, legs, wh), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true })
  part(tray, L.board) F.planks(tray, L.board, 5, true, 2)
  part(wh, L.timber, { nopop = true }) px(92, y, L.iron.hi) hline(88, 96, y, L.timber.deep)
  hline(96, 132, y - 13, S.hi)
  -- a glaucous gull eyeing the fish
  F.sprite({
    "...WWW....",
    ".yWWeWW...",
    "..WWWWWgg.",
    "...WWWWgggk",
    "....WwwWgk.",
    "......o.o..",
  }, 128, y - 21, { W = L.fur.hi, w = L.fur.shade, e = INK, y = L.gold.base, g = "#9a9eb4", k = "#5e6276", o = L.petal.base })
end
F.snowCap(F.rock(160, 254, 9, 6), 3, 130) F.rock(172, 257, 5, 4)
F.snowCap(F.rock(70, 254, 6, 4), 2, 131)
for _, f in ipairs({ { 30, 216, 6 }, { 148, 246, 6 }, { 186, 242, 7 }, { 270, 214, 5 }, { 362, 214, 5 }, { 60, 262, 7 }, { 196, 262, 8 }, { 290, 250, 7 }, { 330, 258, 6 }, { 214, 218, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.willow(184, 252, 6, 8, 135) F.willow(338, 262, 6, 6, 136)
F.tracks({ { 226, 214 }, { 214, 236 }, { 200, 258 } }, "boot", 6)
F.tracks({ { 330, 250 }, { 352, 240 } }, "bird", 4)

---------------------------------------------------------------- the ice-fisher, a snow goose after the apple
DY = 0
F.depth(3)
do
  local bk = poly{ { 410, 210 }, { 422, 210 }, { 420, 220 }, { 412, 220 } }
  F.shadowM(c:ellipse(420, 222, 10, 1))
  rimOf(bk, L.timber) part(bk, L.accent) hline(410, 422, 213, L.iron.shade) hline(411, 421, 218, L.iron.shade)
  local _, hx, hy = F.gnome(416, 210, { hat = L.awnA, coat = L.wall2, arm = "up", flip = true, noShadow = true, hatBand = L.gold.base })
  -- the hole in the shore ice: dark water, a rim of chipped ice, an ice pick
  local hole = c:ellipse(380, 180, 6, 2)
  local rim = hole:grow(1):cut(hole)
  rim:each(function(x, y) px(x, y, y < 180 and I.shade or I.hi) end)
  fill(hole, CH.deep) hline(377, 381, 180, CH.shade) px(378, 179, CH.base)
  for _, p in ipairs({ { 372, 182 }, { 388, 181 }, { 386, 183 }, { 373, 179 } }) do px(p[1], p[2], I.hi) px(p[1] + 1, p[2], I.shade) end
  local rod = line({ { hx, hy + 2 }, { 384, 166 } })
  fill(rod, L.timber.shade) px(384, 166, L.timber.deep)
  for yy = 167, 179 do px(384 - floor((yy - 167) * .3), yy, L.awnB.shade) end
  px(380, 180, L.awnA.base) -- the float
  -- creel with a char tail sticking out
  local cr = c:rrect(428, 212, 442, 222, 2) rimOf(cr, L.timber) part(cr, L.fern)
  cr:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.fern.shade) end end)
  F.snowCap(cr, 1, 137)
  F.sprite({ "s..s", "sSSs", ".SS.", ".ss." }, 433, 206, { s = L.produce.shade, S = L.produce.base })
end
-- a snow goose stretching its neck at the gnome's apple
F.sprite({
  "..........kk.",
  ".........kWWo",
  "..........Ww.",
  "..........W..",
  ".........WW..",
  "........WW...",
  "..WWWWWWWw...",
  ".WWWWwwwww...",
  "KKWwwwwwws...",
  ".Kwwwwwss....",
  "...ss.ss.....",
  "....o..o.....",
}, 340, 228, { W = L.fur.hi, w = L.fur.base, s = L.fur.shade, k = INK, K = "#3c3a48", o = L.petal.base })

DY = 0
F.depth(0)
F.birds({ { 150, 58, 2 }, { 162, 52, 1 }, { 360, 46, 2 }, { 372, 52, 2 } })
F.finish()
