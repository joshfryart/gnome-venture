-- jetty.lua : "Lakeside jetty" stop look, ISLAND (island_palm), 480x270 gate view.
-- Same composition as the Maplewold jetty (art-2701-batch3/stops/opus3/jetty.lua), re-cast for a coral island:
-- right half: the clear turquoise lagoon over sand and dark coral heads, a ring of black lava stones in the
-- shallows (a fish weir), a palm-pole pier lashed with coir and decked with split bamboo, an outrigger canoe moored
-- under it, woven cone fish-traps hung off a pile, a glass-float lantern pole and a gnome fishing off the end;
-- a thatched canoe house on palm stilts and a crab-claw sail canoe on the far water, a dolphin leaping, a ray.
-- Left: an open-sided thatched fale on a lava platform with an earth oven smoking beside it, a bamboo rack of
-- drying reef fish and an octopus, a coir net on palm poles with glass floats, an upturned dugout being caulked,
-- woven fish traps, a calico cat eyeing the fish basket, crabs and shells.
-- Quirk (kept): the reef heron helping itself to the fish bucket -- here wearing a little red gnome hat.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-island-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "jetty", out = DIR, farTrees = { 24, 52, 120, 150, 330, 352, 440 },
  treeLineGap = { 220, 490 } } -- the right half is open lagoon down to the pier
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local mix, rp = F.mix, F.rp
local LG = L.lagoon

-- local ramps
local slate = rp("#9aa4b6 #78829a #5c6680 #444c64 #2c3248")      -- reef heron, dark morph
local dolph = rp("#a8bcd2 #7e98b6 #5e7698 #46587a #2c3a56")      -- bottlenose grey-blue
local koa = rp("#c88a5e #a0603e #7c4430 #5a3026 #3a1e1a")        -- dugout hardwood
local glassG = rp("#c8f0d0 #86d4a6 #52b086 #36886c #22584c")     -- green glass float
local glassB = rp("#b8dcf6 #78b6e6 #4c8cc8 #3466a0 #22446e")     -- blue glass float
local octo = rp("#f4b4b0 #e08488 #bc5c6c #8c4054 #5a2a3c")
local calico = rp("#fff0e0 #f2d6b8 #d6a87e #a6764e #5a3c2c")

-- the lagoon colours: bright over sand at the far edge, deepening toward the pier
local A, B, C, D, E = LG.hi, mix(LG.hi, LG.base, .5), LG.base, mix(LG.base, LG.shade, .5), LG.shade
local DEEP = mix(LG.shade, LG.deep, .55)
local shallowC = mix(A, L.ground.base, .4)
local shallow2 = mix(B, L.ground.hi, .22)

-- a palm-pole texture: lit left, rings every 3 px, dark right edge
local function palmPole(m, x0, x1)
  m:each(function(x, y)
    local h = (x == x0) and L.palmTrunk.hi or ((x == x1) and L.palmTrunk.deep or L.palmTrunk.base)
    if y % 3 == 0 then h = (x == x0) and L.palmTrunk.base or L.palmTrunk.shade end
    px(x, y, h)
  end)
end
-- a coir lashing band across a pole
local function lash(x0, x1, y)
  hline(x0, x1, y, L.rope.base) hline(x0, x1, y + 1, L.rope.shade) px(x0, y, L.rope.hi)
  hline(x0, x1, y + 2, L.rope.deep)
end

---------------------------------------------------------------- the lagoon (right half)
F.depth(0)
local WL = 113
local lake = poly{ { 266, WL }, { 479, WL }, { 479, 228 }, { 372, 228 }, { 350, 220 }, { 326, 202 }, { 304, 176 }, { 288, 150 }, { 276, 130 } }
-- the beach line becomes open water past the shore point
for x = 270, 479 do px(x, 112, hash(x // 3, 112, 3) < .2 and L.surf or A) end
-- wet sand band and a foam lace along the diagonal shore
local beach = lake:grow(4):cut(lake):clip(rect(0, WL, 479, 269))
beach:each(function(x, y)
  local v = hash(x, y, 5)
  px(x, y, v < .45 and L.duff or (v < .7 and L.ground.shade or L.ground.base))
end)
lake:each(function(x, y)
  local d = y - WL
  local h
  if d < 4 then h = A
  elseif d < 14 then h = hash(x // 7, y, 14) < .55 and A or B
  elseif d < 30 then h = hash(x // 7, y, 14) < .5 and B or C
  elseif d < 58 then h = C
  elseif d < 85 then h = hash(x // 6, y // 2, 15) < .55 and C or D
  else h = hash(x // 6, y // 2, 16) < .4 and D or E end
  -- the blue channel under the pier's end
  if d > 70 and x > 432 then h = hash(x // 4, y // 2, 17) < .5 and E or DEEP end
  if not lake:has(x - 7, y) or not lake:has(x, y + 7) or not lake:has(x + 5, y + 5) then h = shallow2 end
  if not lake:has(x - 4, y) or not lake:has(x, y + 4) or not lake:has(x + 3, y + 3) then h = shallowC end
  px(x, y, h)
end)
lake:edge():each(function(x, y) if y > WL and (not lake:has(x - 1, y) or not lake:has(x, y + 1)) then px(x, y, hash(x, y, 9) < .7 and L.surf or A) end end)
lake:grow(1):edge():each(function(x, y) if y > WL + 1 and not lake:has(x, y) and hash(x, y, 10) < .4 then px(x, y, L.mist) end end)

-- the reef under the water: dark coral heads, a brain coral, pale sand pockets, all tinted by the water over them
local function waterAt(x, y) return c:get(x, y) or C end
local function underwater(x, y, h, extra)
  local d = y - WL
  local t = math.max(.18, .55 - d * .004) + (extra or 0)
  px(x, y, mix(h, waterAt(x, y), t))
end
local heads = {
  { 298, 124, 6, 2, L.lava }, { 336, 133, 9, 3, L.coral }, { 392, 124, 7, 2, L.lava }, { 448, 130, 11, 3, L.coral },
  { 470, 150, 7, 3, L.gold }, { 356, 172, 8, 3, L.coral }, { 344, 196, 6, 3, L.coral }, { 300, 208, 0, 0, nil },
  { 404, 164, 5, 2, L.gold }, { 322, 150, 5, 2, L.seagrass },
}
for i, hd in ipairs(heads) do if hd[5] then
  local hx, hy, rx, ry, r = hd[1], hd[2], hd[3], hd[4], hd[5]
  for y = hy - ry - 1, hy + ry + 1 do for x = hx - rx - 1, hx + rx + 1 do
    local q = ((x - hx) / rx) ^ 2 + ((y - hy) / ry) ^ 2
    if lake:has(x, y) and beach:has(x, y) == false and q < .75 + .45 * hash(x, y, 20 + i) then
      local v = hash(x, y, 30 + i)
      local h = v < .3 and r.deep or (v < .7 and r.shade or r.base)
      if y < hy - ry * .3 and x < hx and v > .5 then h = r.hi end
      if hd[5] == L.gold and (x + y) % 3 == 0 then h = r.deep end -- brain-coral grooves
      underwater(x, y, h)
    end
  end end
  -- a pale sand rim below each head
  for x = hx - rx + 1, hx + rx - 1 do if lake:has(x, hy + ry + 1) and hash(x, i, 40) < .6 then underwater(x, hy + ry + 1, L.ground.hi, .1) end end
end end
-- sand pockets
for _, s in ipairs({ { 430, 168, 14, 2 }, { 316, 160, 7, 2 }, { 470, 196, 6, 2 } }) do
  c:ellipse(s[1], s[2], s[3], s[4]):each(function(x, y) if lake:has(x, y) and hash(x // 2, y, 41) < .8 then underwater(x, y, L.ground.hi, .15) end end)
end
-- a spotted eagle ray gliding over the sand
do
  local rx0, ry0 = 392, 196
  local ray = poly{ { rx0 - 9, ry0 }, { rx0, ry0 - 4 }, { rx0 + 9, ry0 }, { rx0, ry0 + 3 } }
  ray:each(function(x, y) underwater(x, y, (x < rx0 and y < ry0) and "#5a6878" or "#3e4a5c", -.05) end)
  for _, p in ipairs({ { -4, -1 }, { 3, 0 }, { -1, 1 }, { 5, -1 } }) do underwater(rx0 + p[1], ry0 + p[2], L.shell.hi, .05) end
  for k = 1, 9 do underwater(rx0 + k // 3, ry0 + 3 + k, "#3e4a5c", .1) end
end
-- reef fish: little bright flecks below the surface
for k = 0, 22 do
  local fx, fy = 290 + floor(hash(k, 1, 42) * 186), 122 + floor(hash(k, 2, 42) * 100)
  if lake:has(fx - 2, fy) and lake:has(fx + 2, fy) and not beach:has(fx, fy) then
    local r = ({ L.gold, L.accent, L.hibiscus, glassB })[1 + k % 4]
    underwater(fx, fy, r.base, -.1) underwater(fx + 1, fy, r.hi, -.1) underwater(fx - 1, fy, r.shade, -.05)
  end
end
-- lit ripple pairs (surf-white crest over a darker trough), longer and wider apart nearer
for y = 118, 226 do
  local d = y - 112
  local gap = 2 + d // 18
  if y % gap == 0 then
    local len = 2 + d // 9
    local x0 = 268 + floor(hash(y, 1, 13) * 30)
    while x0 < 478 do
      if hash(x0 // 9, y, 16) < .45 then
        for xx = x0, x0 + len do if lake:has(xx, y) and lake:has(xx, y + 1) and not beach:has(xx, y) then
          px(xx, y, d < 40 and L.surf or A) if d > 30 then px(xx, y + 1, d > 70 and DEEP or E) end end end
      end
      x0 = x0 + len + 6 + floor(hash(x0, y, 17) * 18)
    end
  end
end
-- hot sun glints
for k = 0, 44 do local gx, gy = 276 + floor(hash(k, 1, 18) * 200), 118 + floor(hash(k, 2, 18) * 104) if lake:has(gx, gy) and lake:has(gx + 1, gy) then px(gx, gy, "#fff4cc") px(gx + 1, gy, L.surf) end end

---------------------------------------------------------------- the lava-stone fish weir in the shallows
do
  local cx0, cy0, rx, ry = 298, 168, 30, 22
  -- calmer, greener water inside the ring (sea grass on the sand)
  c:ellipse(cx0, cy0, rx - 2, ry - 2):each(function(x, y)
    if lake:has(x, y) and not beach:has(x, y) then
      local v = c:get(x, y)
      if v then px(x, y, mix(v, hash(x // 2, y, 43) < .4 and L.seagrass.base or L.seagrass.hi, .28)) end
    end
  end)
  local n = 0
  for a = -1.95, 1.15, .085 do
    n = n + 1
    local sx, sy = floor(cx0 + rx * cos(a) + .5), floor(cy0 + ry * sin(a) + .5)
    if lake:has(sx, sy) and n % 17 ~= 0 then
      local w = 3 + floor(hash(n, 1, 44) * 2)
      local st = c:ellipse(sx, sy, w, 1)
      -- foam lace on the seaward side and a ripple on the pond side
      for k = -w - 1, w + 1 do if lake:has(sx + k + 1, sy + 2) and hash(n, k, 45) < .7 then px(sx + k + 1, sy + 2, L.surf) end end
      for k = -w, w do if lake:has(sx + k - 1, sy - 2) and hash(n, k, 46) < .4 then px(sx + k - 1, sy - 2, A) end end
      st:each(function(x, y)
        local wv = waterAt(x, y)
        local h
        if not st:has(x, y - 1) then h = mix(L.lava.base, L.lava.hi, hash(x, y, 47) < .5 and .2 or .6)
        elseif not st:has(x, y + 1) then h = mix(L.lava.deep, wv, .35)
        else h = mix(L.lava.shade, wv, .2) end
        px(x, y, h)
      end)
      px(sx - 1, sy - 1, "#b6ccd2") -- wet glint
    end
  end
end

---------------------------------------------------------------- far water: crab-claw sail canoe, a leaping dolphin
F.depth(1)
local function sailCanoe(x, y)
  local hull = poly{ { x - 9, y }, { x + 9, y }, { x + 11, y - 2 }, { x + 6, y + 2 }, { x - 6, y + 2 }, { x - 10, y - 2 } }
  local float = rect(x - 6, y + 4, x + 6, y + 4)
  local booms = rect(x - 3, y + 1, x - 3, y + 4):add(rect(x + 3, y + 1, x + 3, y + 4))
  -- the crab-claw sail: two curved spars meeting at the tack near the bow, a pandanus mat between
  local sailM = HP.mask()
  for yy = y - 20, y - 1 do
    local t = (y - 1 - yy) / 19
    local xa = floor(x + 4 - t * 10 - sin(t * pi) * 2 + .5)
    local xb = floor(x + 4 + t * 4 + sin(t * pi) * 3 + .5)
    for xx = xa, xb do sailM:set(xx, yy) end
  end
  rimOf(union(hull, sailM, float, booms), L.timber)
  part(hull, koa, { nopop = true }) hline(x - 8, x + 8, y, L.awnA.base)
  fill(float, L.board.shade) fill(booms, L.board.deep)
  sailM:each(function(xx, yy)
    local h = ((xx + yy) % 4 < 2) and L.rope.hi or L.rope.base
    if (y - yy) % 6 == 3 then h = L.awnA.base end
    if xx > x + 3 and yy > y - 14 then h = ((xx + yy) % 4 < 2) and L.rope.base or L.rope.shade end
    px(xx, yy, h)
  end)
  for k = 1, 3 do hline(x - 8 + k, x + 8 - k, y + 5 + k * 2, D) end
  for k = 1, 2 do hline(x - 2, x + 4 - k, y + 5 + k * 2 - 1, mix(L.rope.base, B, .55)) end
end
sailCanoe(316, 126)
F.depth(2)
do -- a bottlenose dolphin mid-leap over its splash rings
  local fx, fy = 362, 152
  c:ellipse(fx + 1, fy + 8, 10, 2):edge():each(function(x, y) if lake:has(x, y) then px(x, y, L.surf) end end)
  c:ellipse(fx + 1, fy + 8, 14, 3):edge():each(function(x, y) if (x // 2) % 2 == 0 and lake:has(x, y) then px(x, y, A) end end)
  local body = HP.mask()
  local pts = {}
  for k = 0, 24 do
    local t = k / 24
    local a = pi * (1 - t)
    local bx, by = fx + cos(a) * 10, fy + 6 - sin(a) * 9
    local w = 2.6 * sin(pi * math.min(1, t * 1.15 + .05)) + .6
    pts[#pts + 1] = { bx, by, w, a }
    for dx = -3, 3 do for dy = -3, 3 do if dx * dx + dy * dy <= w * w then body:set(floor(bx + dx + .5), floor(by + dy + .5)) end end end
  end
  local beak = line({ { fx + 9, fy + 4 }, { fx + 12, fy + 7 } })
  local fin = poly{ { fx - 3, fy - 2 }, { fx + 1, fy - 3 }, { fx - 4, fy - 6 } }
  local fluke = poly{ { fx - 13, fy + 6 }, { fx - 9, fy + 6 }, { fx - 12, fy + 10 } }:add(poly{ { fx - 10, fy + 7 }, { fx - 6, fy + 9 }, { fx - 9, fy + 10 } })
  local all = union(body, beak, fin, fluke)
  rimOf(all, dolph)
  all:each(function(x, y)
    local below = not all:has(x, y + 2)
    local h = dolph.base
    if y < fy - 2 or (x < fx and y < fy + 2) then h = dolph.hi end
    if below then h = L.shell.base end
    if x > fx + 6 then h = below and L.shell.shade or dolph.shade end
    px(x, y, h)
  end)
  fill(fin, dolph.shade) px(fx - 3, fy - 4, dolph.base)
  px(fx + 8, fy + 2, L.timber.edge)
  for _, d in ipairs({ { -14, 4 }, { -15, 2 }, { 13, 6 }, { 15, 4 }, { -12, 1 } }) do px(fx + d[1], fy + d[2], L.surf) end
end

---------------------------------------------------------------- far water: the thatched canoe house on palm stilts
local function canoeHouse()
  local top, cx, wallM, roofM = F.building{ x0 = 388, x1 = 444, yb = 140, wh = 26, rh = 22, wall = L.board, roof = L.roof, noShadow = true, noFrame = true, noAttic = true }
  F.bamboo(wallM:copy():clip(rect(388, top + 4, 444, 139)), L.board, 3)
  hline(388, 444, top + 4, L.timber.base) hline(388, 444, 139, L.timber.deep)
  -- a big open front with a carved canoe prow nosing out
  local d = rect(396, 122, 418, 140) fill(d, L.soil.deep) fill(rect(398, 132, 416, 140), DEEP)
  hline(398, 416, 133, E) hline(399, 415, 136, D)
  vline(396, 122, 140, L.palmTrunk.hi) vline(418, 122, 140, L.palmTrunk.shade) hline(396, 418, 121, L.palmTrunk.base)
  local prow = poly{ { 400, 130 }, { 414, 130 }, { 418, 126 }, { 415, 133 }, { 401, 133 } }
  c:rim(prow, koa.edge) part(prow, koa, { nopop = true }) hline(401, 414, 131, L.awnA.base)
  -- a woven shutter propped open, a hanging fish trap
  F.window(426, 120, 434, 126, L.timber)
  local sh = poly{ { 425, 119 }, { 435, 119 }, { 438, 114 }, { 428, 114 } }
  c:rim(sh, L.rope.edge) part(sh, L.rope, { nopop = true }) sh:each(function(x, y) if (x + y) % 2 == 0 then px(x, y, L.rope.shade) end end)
  -- palm-pole stilts, rings, coir lashings, their broken reflections
  for x = 390, 442, 8 do
    local p = rect(x, 141, x + 1, 151)
    c:rim(p, L.palmTrunk.edge) palmPole(p, x, x + 1)
    for y = 153, 162, 2 do if lake:has(x, y) then px(x, y, D) px(x + 1, y + 1, E) end end
  end
  for y = 153, 159, 2 do hline(392, 440, y, (y % 4 == 1) and E or D) end
  -- ladder down to the water
  vline(420, 141, 152, L.board.deep) vline(424, 141, 152, L.board.deep) for y = 143, 151, 3 do hline(421, 423, y, L.board.base) end
end
canoeHouse()

---------------------------------------------------------------- the palm-pole pier, moored outrigger, lantern pole, fisher gnome
F.depth(3)
local deck = rect(300, 178, 470, 185)
local face = rect(300, 186, 470, 188)
local piles = HP.mask()
for x = 312, 466, 18 do piles:add(rect(x, 189, x + 2, 206)) end
-- the water stain and shadow of the deck, pile reflections
for x = 300, 470 do for y = 189, 193 do if lake:has(x, y) and (x // 3 + y) % 2 == 0 then px(x, y, y < 191 and E or D) end end end
for x = 312, 466, 18 do for y = 208, 222, 3 do if lake:has(x, y) then px(x, y, DEEP) px(x + 1, y + 1, E) end end end
rimOf(union(deck, face, piles), L.palmTrunk)
for x = 312, 466, 18 do palmPole(rect(x, 189, x + 2, 206), x, x + 2) end
-- green weed and barnacles where the tide reaches the piles
piles:each(function(x, y) if y > 199 then local v = hash(x, y, 46) if v < .5 then px(x, y, y > 202 and L.seagrass.shade or L.seagrass.base) elseif v > .88 then px(x, y, L.shell.hi) end end end)
for x = 312, 466, 18 do hline(x, x + 2, 203, A) hline(x - 1, x + 3, 205, L.surf) end
-- split-bamboo decking laid across the bearers, lit lip, lashings at every pile
deck:each(function(x, y)
  local k, cane = (x - 300) % 3, (x - 300) // 3
  local old = hash(cane, 1, 53) < .12
  local r = old and L.timber or L.board
  local h = k == 0 and r.hi or (k == 2 and r.deep or r.base)
  if k == 1 and hash(cane, y, 55) < .1 then h = r.shade end
  if y == 180 + floor(hash(cane, 0, 52) * 4) and k ~= 2 then h = r.shade end -- one node per cane
  if y == 178 then h = k == 2 and r.base or r.hi end
  px(x, y, h)
end)
-- the bearer log along the front: a whole palm trunk, ringed
face:each(function(x, y)
  local h = y == 186 and L.palmTrunk.hi or (y == 187 and L.palmTrunk.base or L.palmTrunk.shade)
  if (x % 5) == 0 then h = L.palmTrunk.deep end
  px(x, y, h)
end)
for x = 312, 466, 18 do lash(x - 1, x + 3, 186) end
-- an outrigger canoe moored under the pier, paddles across the thwarts
F.outrigger(366, 424, 214, { side = 1, hull = koa, stripe = L.awnA })
for k = 0, 3 do hline(372 + k, 418 - k, 224 + k * 2, k < 2 and E or DEEP) end
line({ { 378, 208 }, { 402, 206 } }):each(function(x, y) px(x, y, L.board.base) end)
fill(c:ellipse(404, 206, 3, 1), L.board.shade) px(403, 205, L.board.hi)
fill(line({ { 364, 211 }, { 360, 189 } }), L.rope.shade) -- mooring line
-- woven cone fish-traps hung on a pile, half in the water
local function hangTrap(x, y)
  local m = poly{ { x - 3, y }, { x + 3, y }, { x + 2, y + 11 }, { x, y + 13 }, { x - 2, y + 11 } }
  c:rim(m, L.rope.edge) part(m, L.board, { nopop = true })
  m:each(function(xx, yy) if (yy - y) % 3 == 2 then px(xx, yy, L.board.deep) elseif (xx + yy) % 2 == 0 then px(xx, yy, L.board.shade) end end)
  hline(x - 2, x + 2, y, L.soil.deep)
  for yy = y + 8, y + 13 do for xx = x - 3, x + 3 do if m:has(xx, yy) then px(xx, yy, mix(c:get(xx, yy) or L.board.base, E, .45)) end end end
end
vline(331, 189, 194, L.rope.shade) vline(333, 189, 196, L.rope.shade)
hangTrap(331, 194) hangTrap(337, 197)
hline(330, 342, 210, L.surf)
-- the lantern pole at the pier's end: bamboo, a hanging hurricane lamp and a glass float in a net
local lp = rect(460, 140, 461, 177)
c:rim(lp, L.board.edge) F.bamboo(lp, L.board, 2)
local arm = rect(450, 140, 461, 141) fill(arm, L.board.shade) hline(450, 461, 140, L.board.base)
lash(459, 462, 142)
local lam = rect(450, 144, 455, 151) rimOf(lam, L.iron) fill(lam, L.glow.base) px(451, 145, L.glow.hi) px(452, 145, L.glow.hi) vline(455, 145, 151, L.glow.shade)
hline(450, 455, 143, L.iron.deep) hline(451, 454, 152, L.iron.deep) px(452, 142, L.iron.base)
local gf = c:ellipse(465, 160, 3, 3) c:rim(gf, glassB.edge) part(gf, glassB, { nopop = true }) px(464, 159, glassB.hi) px(463, 158, L.surf)
F.net(gf, L.rope) vline(465, 154, 156, L.rope.shade) hline(462, 465, 154, L.rope.shade)
-- a sooty tern on a pile-top lashing
F.sprite({ "..kk..", "bkkkk.", "..wwwk", "..wwww", "...ww.", "...l.l" }, 337, 180, { k = "#3e4252", b = "#e6b84a", w = L.awnB.hi, l = L.timber.edge })
-- fisher gnome on a woven cool-box, bamboo rod out over the channel, a float bobbing on the line
local bx = rect(422, 170, 436, 177) rimOf(bx, L.rope) part(bx, L.rope, { nopop = true })
bx:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.rope.shade) elseif (x - y) % 3 == 0 then px(x, y, L.rope.hi) end end)
hline(422, 436, 170, L.rope.deep)
local _, fhx, fhy = F.gnome(430, 169, { hat = L.roof2, coat = L.hibiscus, arm = "out", noShadow = true })
local rod = line({ { fhx, fhy }, { 446, 152 }, { 451, 145 } })
rod:each(function(x, y) px(x, y, ((x + y) % 4 == 0) and L.board.deep or L.board.base) end)
vline(451, 146, 177, L.awnB.shade) vline(451, 189, 213, L.awnB.shade) fill(rect(450, 213, 452, 215), L.awnA.base) px(450, 213, L.awnA.hi) px(451, 215, L.awnB.hi)
for k = 0, 2 do hline(447 - k * 2, 455 + k * 2, 217 + k * 2, L.surf) end
-- a calabash water gourd and a basket of reef fish on the deck
local gourd = c:ellipse(316, 172, 5, 5):add(c:ellipse(316, 165, 3, 3)):add(rect(315, 160, 316, 162))
rimOf(gourd, L.coconut) part(gourd, L.gold) px(314, 169, L.gold.hi) px(315, 168, L.gold.hi) fill(rect(315, 160, 316, 161), L.timber.base)
hline(311, 321, 172, L.coconut.base) -- the carrying cord
local fb = poly{ { 324, 177 }, { 342, 177 }, { 340, 170 }, { 326, 170 } }
rimOf(fb, L.rope) part(fb, L.rope, { nopop = true }) fb:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.rope.shade) end end)
for k = 0, 3 do local fx = 327 + k * 4 local r = ({ L.accent, L.hibiscus, glassB, L.gold })[k + 1]
  fill(c:ellipse(fx, 169, 2, 1), r.base) px(fx - 1, 168, r.hi) px(fx + 2, 169, r.deep) end
-- a green drinking coconut with a straw, and a conch trumpet on the deck
F.coconut(410, 175, 3, true) vline(411, 168, 172, L.awnB.base) px(412, 167, L.awnB.base)
F.shell(372, 177, "conch", true)

---------------------------------------------------------------- shore wedge: reef heron in a red gnome hat at the fish bucket (quirk), rope, stone anchor
F.eraseGround(rect(300, 236, 324, 251)) -- keep the bucket's silhouette clear
local bucket = poly{ { 304, 252 }, { 318, 252 }, { 316, 264 }, { 306, 264 } }
rimOf(bucket, L.timber) part(bucket, koa) hline(304, 318, 255, L.rope.base) hline(305, 317, 261, L.rope.base) px(305, 255, L.rope.hi)
for k = 0, 3 do
  local fx = 306 + k * 3
  local r = ({ L.accent, L.gold, glassB, L.hibiscus })[k + 1]
  fill(rect(fx, 248 - (k % 2), fx + 1, 252), r.base) px(fx, 248 - (k % 2), r.shade) px(fx + 1, 250, r.hi)
end
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
}, 284, 230, { k = slate.edge, w = slate.base, e = L.gold.hi, y = L.gold.base, Y = L.gold.shade, f = L.accent.hi, F = L.accent.shade,
  G = slate.hi, g = slate.base, d = slate.shade, D = slate.deep, l = L.gold.shade })
-- a white throat stripe down the slate neck
for _, p in ipairs({ { 299, 233 }, { 299, 235 }, { 298, 237 }, { 297, 239 }, { 296, 241 }, { 295, 243 } }) do px(p[1], p[2], L.awnB.base) end
-- the little red gnome hat, flopping back off the crest
do
  local hat = poly{ { 295, 230 }, { 302, 230 }, { 300, 226 }, { 297, 222 }, { 292, 221 }, { 295, 224 } }
  c:rim(hat, L.awnA.edge) part(hat, L.awnA, { nopop = true })
  hline(295, 302, 230, L.awnA.deep) px(297, 227, L.awnA.hi) px(298, 228, L.awnA.hi) px(296, 225, L.awnA.hi)
  px(291, 221, L.awnB.hi) px(291, 222, L.awnB.base) -- pompom
end
-- coiled coir rope and a lashed lava-stone anchor
local coil = c:ellipse(354, 248, 9, 4) rimOf(coil, L.rope) part(coil, L.rope) fill(c:ellipse(354, 248, 4, 1), L.rope.deep)
for k = 0, 2 do c:ellipse(354, 248, 8 - k * 2, 3 - k // 2):edge():each(function(x, y) if y > 247 then px(x, y, L.rope.shade) end end) end
do
  local st = poly{ { 330, 244 }, { 331, 236 }, { 336, 232 }, { 342, 235 }, { 344, 244 } }
  c:rim(st, L.lava.edge) part(st, L.lava, { nopop = true })
  st:each(function(x, y) if hash(x, y, 48) < .14 then px(x, y, L.lava.deep) end end)
  fill(c:ellipse(337, 236, 1, 1), L.lava.edge) -- the bored hole
  vline(337, 228, 235, L.rope.shade) hline(331, 343, 239, L.rope.base) hline(331, 343, 240, L.rope.shade) px(332, 238, L.rope.hi)
  line({ { 337, 228 }, { 346, 245 } }):each(function(x, y) px(x, y, L.rope.base) end)
end
F.lavaRock(370, 264, 8, 7, 80)
F.lavaRock(326, 268, 6, 4, 81)
F.crab(368, 252, L.awnA) F.crab(282, 266, L.hibiscus, true)
F.shell(344, 260, "scallop", true) F.shell(362, 238, "cowrie") F.shell(296, 214, "conch", true) F.shell(318, 228, "scallop")
for _, f in ipairs({ { 372, 244, 6 }, { 276, 248, 6 }, { 290, 222, 5 } }) do F.fern(f[1], f[2], f[3], L.seagrass) end

---------------------------------------------------------------- left: open-sided fale on a lava platform, earth oven, fish rack
F.depth(1)
F.tree(92, 128, 40, 3)
F.tree(8, 132, 42, 0)
do
  -- the lava-stone platform (paepae)
  local plat = rect(16, 128, 74, 137)
  rimOf(plat, L.lava) part(plat, L.lava, { nopop = true }) F.courses(plat, 128, 3, 6, L.lava)
  hline(16, 74, 128, L.lava.hi)
  -- the dark open interior, posts, rolled mats and gourds hanging under the eaves
  local inner = rect(20, 112, 70, 127)
  fill(inner, L.soil.deep) hline(20, 70, 127, L.soil.base) hline(20, 70, 126, L.soil.shade)
  for k = 0, 3 do local gx = 28 + k * 12 vline(gx, 112, 114, L.rope.shade) fill(c:ellipse(gx, 117, 2, 2), k % 2 == 0 and L.gold.shade or L.coconut.base) px(gx - 1, 116, L.gold.hi) end
  fill(rect(34, 122, 54, 125), L.rope.base) hline(34, 54, 122, L.rope.hi) for x = 38, 52, 5 do vline(x, 122, 125, L.rope.shade) end -- rolled mats
  local posts = HP.mask()
  for _, x in ipairs({ 18, 32, 58, 71 }) do posts:add(rect(x, 112, x + 1, 127)) end
  rimOf(posts, L.palmTrunk) posts:each(function(x, y) px(x, y, (x % 2 == 0) and L.palmTrunk.hi or L.palmTrunk.shade) end)
  -- the hipped thatch roof, a woven ridge cap
  local roofM = poly{ { 10, 114 }, { 26, 94 }, { 64, 94 }, { 80, 114 } }
  rimOf(roofM, L.roof) part(roofM, L.roof, { sep = true })
  F.thatch(roofM, L.roof, 94, 45)
  hline(10, 80, 114, L.roof.deep) hline(26, 64, 94, L.roof.hi)
  line({ { 11, 113 }, { 26, 95 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  fill(rect(26, 92, 64, 93), L.rope.base) for x = 28, 62, 4 do px(x, 92, L.rope.shade) end
  -- ragged fringe under the eaves
  for x = 11, 79 do if hash(x, 1, 49) < .6 then px(x, 115, L.roof.shade) end if hash(x, 2, 49) < .3 then px(x, 116, L.roof.deep) end end
  -- a carved fish sign on the corner post
  local fs = c:ellipse(42, 132, 6, 3):add(poly{ { 47, 132 }, { 52, 128 }, { 52, 136 } })
  rimOf(fs, L.accent) part(fs, L.accent) px(38, 131, L.timber.edge) px(41, 133, L.accent.hi) px(45, 131, L.accent.deep)
  -- the earth oven: a mound of hot lava stones under banana leaves, steaming
  local umu = c:ellipse(82, 140, 7, 3):clip(rect(70, 134, 94, 140))
  rimOf(umu, L.leaf) part(umu, L.leaf, { nopop = true }) umu:each(function(x, y) if (x - y) % 4 == 0 then px(x, y, L.leaf.deep) end end)
  for _, p in ipairs({ { 76, 141 }, { 80, 142 }, { 85, 141 }, { 89, 141 } }) do F.lavaRock(p[1], p[2], 2, 2, p[1]) end
  F.smoke(82, 120, 6, .5, 2)
end
local function fishRack(x0, x1, yb)
  local posts = rect(x0, yb - 22, x0 + 1, yb):add(rect(x1, yb - 22, x1 + 1, yb))
  local bar = rect(x0 - 2, yb - 22, x1 + 3, yb - 21)
  F.shadow(x0, x1, yb, 6, 3)
  rimOf(union(posts, bar), L.board)
  F.bamboo(posts, L.board, 2) F.bamboo(bar, L.board, 2, { horizontal = true })
  local cols = { L.accent, L.hibiscus, glassB, L.stone, L.awnA }
  for x = x0 + 4, x1 - 2, 5 do
    vline(x, yb - 20, yb - 19, L.rope.shade)
    local k = (x // 5) % 5 + 1
    if x == x0 + 24 then
      -- an octopus hung by its head, arms curling
      local hd = c:ellipse(x, yb - 16, 3, 3)
      c:rim(hd, octo.edge) part(hd, octo, { nopop = true })
      for a = -2, 2 do vline(x + a, yb - 13, yb - 6 + (a % 2), octo.shade) px(x + a, yb - 5 + (a % 2), octo.base) end
      px(x - 1, yb - 17, octo.hi) px(x + 1, yb - 15, octo.edge)
    else
      local r = cols[k]
      local fsh = poly{ { x - 1, yb - 18 }, { x + 2, yb - 18 }, { x + 2, yb - 9 }, { x, yb - 7 }, { x - 1, yb - 9 } }
      local tl = poly{ { x - 2, yb - 7 }, { x + 3, yb - 7 }, { x, yb - 9 } }
      fill(union(fsh, tl), r.base) vline(x - 1, yb - 18, yb - 10, r.hi) vline(x + 2, yb - 18, yb - 10, r.deep) px(x, yb - 16, L.timber.edge)
      if k == 1 then for y = yb - 15, yb - 10, 2 do px(x + 1, y, L.hibiscus.base) end end -- parrotfish streaks
    end
  end
end
fishRack(100, 154, 140)
F.depth(2)
for _, f in ipairs({ { 14, 142, 4 }, { 96, 144, 4 }, { 160, 140, 3 } }) do F.fern(f[1], f[2], f[3]) end
F.hibiscus(176, 140, 7, 9, 50)
F.depth(3)

---------------------------------------------------------------- left hero: coir net on palm poles with glass floats
local function netFrame(x0, x1, yt, yb)
  local mx = (x0 + x1) // 2
  local posts = rect(x0, yt, x0 + 3, yb):add(rect(x1 - 3, yt, x1, yb)):add(rect(mx - 1, yt, mx + 1, yb))
  local bar = rect(x0 - 3, yt, x1 + 3, yt + 3)
  F.shadow(x0, x1, yb, 14, 5)
  rimOf(union(posts, bar), L.palmTrunk)
  palmPole(rect(x0, yt, x0 + 3, yb), x0, x0 + 3) palmPole(rect(x1 - 3, yt, x1, yb), x1 - 3, x1) palmPole(rect(mx - 1, yt, mx + 1, yb), mx - 1, mx + 1)
  part(bar, L.timber, { nopop = true }) hline(x0 - 3, x1 + 3, yt, L.timber.hi)
  for _, x in ipairs({ x0, mx - 1, x1 - 3 }) do lash(x - 1, x + 4 - (x == mx - 1 and 1 or 0), yt + 4) end
  local function sag(x) local t = ((x - x0) % ((x1 - x0) // 2)) / ((x1 - x0) // 2) return floor(yb - 14 - 10 * sin(t * pi)) end
  for x = x0 + 4, x1 - 4 do
    if not (x >= mx - 1 and x <= mx + 1) then
      local y1 = sag(x)
      for y = yt + 4, y1 do
        local a, b = (x + y) % 5, (x - y) % 5
        if a == 0 or b == 0 then px(x, y, (a == 0) and L.coconut.shade or L.coconut.base) elseif hash(x, y, 2) < .06 then px(x, y, L.rope.shade) end
      end
      px(x, y1, L.coconut.deep) px(x, y1 - 1, L.coconut.shade)
    end
  end
  -- glass floats and red cork floats along the foot rope
  local n = 0
  for x = x0 + 8, x1 - 8, 9 do
    if not (x >= mx - 4 and x <= mx + 4) then
      n = n + 1
      local y1 = sag(x)
      if n % 3 == 0 then fill(rect(x - 1, y1 + 1, x + 1, y1 + 3), L.awnA.base) px(x - 1, y1 + 1, L.awnA.hi) px(x + 1, y1 + 3, L.awnA.deep)
      else
        local r = n % 2 == 0 and glassG or glassB
        local g = c:ellipse(x, y1 + 3, 3, 3)
        c:rim(g, r.edge) part(g, r, { nopop = true }) px(x - 1, y1 + 2, r.hi) px(x - 2, y1 + 1, L.surf) px(x + 1, y1 + 4, r.deep)
        g:each(function(xx, yy) if (xx + yy) % 3 == 0 then px(xx, yy, L.rope.shade) end end)
      end
    end
  end
  -- a strand of seaweed and a starfish caught in the net
  px(120, 170, L.seagrass.base) px(121, 171, L.seagrass.shade) px(121, 172, L.seagrass.base)
  F.sprite({ "..o..", "ooOoo", ".oOo.", "o...o" }, 158, 168, { o = L.hibiscus.base, O = L.hibiscus.hi })
end
netFrame(92, 192, 150, 214)
-- calabash gourds and a carved bowl by the net post
local function calabash(x, yb, r, rr)
  local m = c:ellipse(x, yb - rr, rr, rr):add(c:ellipse(x, yb - rr * 2 - 1, rr // 2, rr // 2))
  rimOf(m, L.coconut) part(m, r)
  px(x - rr // 2, yb - rr - rr // 2, r.hi) px(x - rr // 2 + 1, yb - rr - rr // 2, r.hi)
  hline(x - rr + 1, x + rr - 1, yb - rr - 1, L.rope.shade)
end
calabash(108, 224, L.gold, 6)
do -- a carved bowl of limes and a split drinking coconut
  local bowl = poly{ { 116, 220 }, { 132, 220 }, { 129, 226 }, { 119, 226 } }
  rimOf(bowl, koa) part(bowl, koa) hline(116, 132, 220, koa.hi) hline(119, 129, 226, koa.deep)
  for _, l in ipairs({ { 120, 218 }, { 124, 217 }, { 128, 218 } }) do F.coconut(l[1], l[2], 2, true) end
  local sp = c:ellipse(138, 225, 3, 2) c:rim(sp, L.coconut.edge) fill(sp, L.coconut.base) fill(c:ellipse(138, 224, 2, 1), L.shell.hi)
end
-- a basket of fish, woven pandanus
local bk = poly{ { 160, 214 }, { 182, 214 }, { 179, 224 }, { 163, 224 } }
rimOf(bk, L.rope) part(bk, L.rope) bk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.rope.shade) elseif (x - y) % 4 == 0 then px(x, y, L.rope.hi) end end)
hline(160, 182, 214, L.rope.deep)
for k = 0, 4 do local fx = 162 + k * 4 local r = ({ L.accent, glassB, L.hibiscus, L.stone, L.gold })[k + 1]
  fill(c:ellipse(fx, 212, 2, 1), r.base) px(fx - 1, 211, r.hi) px(fx + 2, 212, r.deep) end
-- leaf-bladed paddles leaning on the net post
for k, ox in ipairs({ -2, 6 }) do
  fill(line({ { 194 + ox, 228 }, { 186 + ox, 176 } }, 1), L.timber.base)
  local blade = poly{ { 184 + ox, 158 }, { 188 + ox, 165 }, { 188 + ox, 174 }, { 185 + ox, 180 }, { 183 + ox, 174 }, { 183 + ox, 165 } }
  c:rim(blade, koa.edge) part(blade, k == 1 and L.wall2 or L.timber, { nopop = true }) vline(184 + ox, 164, 174, k == 1 and L.wall2.hi or L.timber.hi) vline(188 + ox, 165, 174, k == 1 and L.wall2.shade or L.timber.shade)
  if k == 1 then hline(183 + ox, 188 + ox, 170, L.awnA.base) hline(183 + ox, 188 + ox, 171, L.awnA.shade) end
end
-- a calico cat sitting by the basket, eyeing the fish
F.sprite({
  "o...o..",
  "oo.oo..",
  "ttttt..",
  "tetet..",
  "ttntt..",
  ".ttt...",
  ".tOtt..",
  "tOOtt..",
  "tOtTTt.",
  "tttTTtt",
  "tttttt.",
  "wt.tw..",
}, 148, 212, { o = calico.edge, t = calico.hi, O = L.produce.base, T = calico.deep, e = L.leaf.base, n = L.petal.shade, w = calico.base })

---------------------------------------------------------------- bottom-left: big palm, an upturned dugout being caulked, fish traps
F.palm(44, 210, 60, L.foliage, 6, { lean = 10 })
F.coconut(62, 210, 4, true) F.coconut(72, 211, 4) F.coconut(67, 204, 4, true) F.coconut(80, 212, 3)
local function upCanoe()
  local pts = { { 24, 242 } }
  for x = 24, 136, 4 do pts[#pts + 1] = { x, 242 - floor(14 * sin((x - 20) / 120 * pi) ^ .6) - (x > 120 and (x - 120) // 2 or 0) } end
  pts[#pts + 1] = { 140, 228 } pts[#pts + 1] = { 132, 242 }
  local hull = poly(pts)
  local tre = rect(36, 242, 38, 256):add(rect(110, 240, 112, 256)):add(rect(30, 252, 44, 253)):add(rect(104, 252, 118, 253))
  F.shadow(26, 136, 258, 6, 3)
  rimOf(union(hull, tre), koa)
  part(tre, L.timber, { nopop = true, noshade = true })
  part(hull, koa)
  hull:each(function(x, y)
    local k = 242 - floor(14 * sin((x - 20) / 120 * pi) ^ .6)
    if (y - k) % 4 == 2 and hash(x // 7, y, 54) < .75 then px(x, y, koa.shade) end -- adzed grain along the log
    if (y - k) % 4 == 3 and hash(x // 5, y, 56) < .2 then px(x, y, koa.deep) end
    if y < k + 2 and x > 30 and x < 128 then px(x, y, koa.hi) end
    if x < 64 and y > k + 3 then px(x, y, hash(x, y, 51) < .2 and L.soil.shade or L.soil.deep) end -- fresh breadfruit-gum caulk
  end)
  -- a painted ochre band and a carved prow
  hline(26, 132, 239, L.awnA.base) hline(26, 132, 240, L.awnA.deep)
  for x = 30, 128, 8 do px(x, 238, L.awnB.hi) end
  hline(24, 132, 242, koa.deep)
  -- the gum pot over a little fire
  local pot = c:ellipse(60, 254, 5, 4) rimOf(pot, L.lava) part(pot, L.lava) hline(56, 64, 251, L.soil.deep)
  fill(line({ { 62, 250 }, { 68, 244 } }), L.board.base)
  px(57, 259, L.glow.base) px(59, 259, L.glow.shade) px(61, 259, L.glow.base) px(63, 259, L.glow.hi) px(60, 260, L.produce.base) px(58, 260, L.glow.hi)
  px(59, 247, L.mist2) px(61, 245, L.mist) px(60, 243, L.mist2)
  local _, thx, thy = F.gnome(82, 266, { hat = L.gold, coat = L.wall2, arm = "out", flip = true })
  fill(line({ { thx, thy }, { thx - 6, thy - 3 } }), L.board.base) fill(rect(thx - 9, thy - 6, thx - 6, thy - 3), L.soil.deep) px(thx - 9, thy - 6, L.soil.base)
end
upCanoe()
-- woven cone fish traps (two lying, one standing)
local function trap(x, yb, len, flip)
  local s = flip and -1 or 1
  local mouth = c:ellipse(x, yb - 5, 3, 5)
  local body = poly{ { x, yb - 10 }, { x + len * s, yb - 6 }, { x + len * s, yb - 4 }, { x, yb } }
  local all = union(mouth, body)
  rimOf(all, L.timber)
  body:each(function(xx, yy)
    local h = ((xx + yy) % 2 == 0) and L.timber.base or L.timber.shade
    if yy < yb - 7 then h = ((xx + yy) % 2 == 0) and L.timber.hi or L.timber.base end
    if (xx - x) % 4 == 0 then h = L.timber.deep end
    px(xx, yy, h)
  end)
  mouth:each(function(xx, yy) px(xx, yy, (xx - x) * s < 0 and L.timber.hi or L.timber.base) end)
  fill(c:ellipse(x, yb - 5, 2, 4), L.timber.deep) fill(c:ellipse(x, yb - 5, 1, 2), L.soil.deep)
end
trap(148, 266, 16) trap(186, 258, 12, true)
do -- one standing on its end
  local m = poly{ { 162, 252 }, { 174, 252 }, { 170, 238 }, { 166, 238 } }
  rimOf(m, L.timber) part(m, L.rope, { nopop = true })
  m:each(function(x, y) if (252 - y) % 3 == 0 then px(x, y, L.timber.deep) elseif (x + y) % 2 == 0 then px(x, y, L.timber.shade) end end)
  vline(164, 241, 250, L.timber.hi)
  hline(166, 170, 237, L.timber.base)
end
F.crab(140, 262, L.awnA, true)
F.shell(206, 258, "conch", true) F.shell(196, 266, "scallop", true) F.shell(14, 226, "cowrie")
for _, f in ipairs({ { 14, 222, 6 }, { 146, 246, 6 }, { 200, 238, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.flower(202, 248, "plumeria") F.flower(150, 236, "hibiscus", true)
-- mangrove seedlings and beach grass along the waterline, a hermit crab on the wet sand
for k = 0, 9 do
  local rx, ry = 296 + k * 3 + (k % 2), 168 + k * 3
  if k % 3 == 0 then
    vline(rx, ry - 6, ry, L.timber.base) px(rx - 1, ry - 7, L.foliage2.hi) px(rx, ry - 8, L.foliage2.base) px(rx + 1, ry - 7, L.foliage2.shade) px(rx - 2, ry - 6, L.foliage2.base) px(rx + 2, ry - 6, L.foliage2.deep)
  else
    local h = 3 + floor(hash(k, 4, 3) * 4)
    vline(rx, ry - h, ry, L.mossGround.shade) px(rx - 1, ry - h + 1, L.mossGround.hi) px(rx + 1, ry - h + 2, L.mossGround.base)
  end
end
for k = 0, 4 do local rx = 270 + k * 3 local ry = 128 + k * 4 vline(rx, ry - 4, ry, L.mossGround.shade) px(rx - 1, ry - 4, L.mossGround.hi) end
F.crab(352, 230, L.hibiscus)
-- signpost with a hanging fish board by the road
F.sign(206, 148, 18, 10, L.board)
F.lavaRock(222, 196, 6, 5, 82)
F.fern(206, 176, 5) F.fern(214, 210, 6)
F.depth(0)
F.birds({ { 360, 60, 3 }, { 376, 52, 2 }, { 300, 76, 2 }, { 150, 50, 2 }, { 452, 74, 3 } })
fill(c:ellipse(205, 153, 5, 2):add(poly{ { 209, 153 }, { 212, 150 }, { 212, 156 } }), L.accent.base) px(202, 152, L.timber.edge) px(203, 152, L.accent.hi)
F.finish()
