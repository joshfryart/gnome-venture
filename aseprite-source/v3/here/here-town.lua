-- here-town: sunny market town of tiny creatures (480x270, layout key "town").
-- Planes: sky (4 bands, sun, puffs) / far hills + far rooftops + windmill (low contrast) /
-- mid: hedges, back lane, homes, library, shops + stall, wild wood, green with well, teahouse, board /
-- near: bushes in the bottom corners, flower barrel, pumpkin barrow, overhead bunting.
-- quirk: the well's bucket is a teacup borrowed from the teahouse.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local W, Hh, HOR = 480, 270, 112
local c = HP.canvas{ w = W, h = Hh, scale = 1, name = "here-town" }
local floor, sin, cos, abs, sqrt = math.floor, math.sin, math.cos, math.abs, math.sqrt
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local F = function(m, hex) c:fillMask(m, hex) end
local function H(x, y, s) local n = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453 return n - floor(n) end
local CREAMR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local NEARLEAF = { hi = P.moss.base, base = P.moss.shade, shade = P.moss.deep, deep = P.ink }

local EXITS = { {240,118}, {372,128}, {452,176}, {396,236}, {240,258}, {84,236}, {28,176}, {108,128} }
local STANDS = { {200,206}, {280,210}, {110,214}, {360,222}, {240,228}, {50,212} }
local function free(x, y, pad)
  pad = pad or 0
  for _, e in ipairs(EXITS) do local dx, dy = x - e[1], y - e[2] if dx * dx + dy * dy < (31 + pad) ^ 2 then return false end end
  for _, s in ipairs(STANDS) do local dx, dy = x - s[1], y - s[2] if dx * dx + dy * dy < (29 + pad) ^ 2 then return false end end
  return true
end

------------------------------------------------------------ SKY: 4 flat bands, sun, puffs
c:stripes(0, HOR - 1, { P.sky.deep, P.sky.shade, P.sky.base, P.sky.hi }, { 2, 3, 4, 4 })
F(E(54, 30, 13, 13), P.gold.base) F(E(52, 28, 10, 10), P.gold.hi) F(E(50, 25, 4, 3), P.cream)
c:cloud(96, 56, 44, P.cream, P.sky.hi)
c:cloud(250, 40, 56, P.cream, P.sky.hi)
c:cloud(312, 46, 26, P.cream, P.sky.hi)
c:cloud(398, 70, 36, P.cream, P.sky.hi)
c:cloud(168, 82, 22, P.cream, P.sky.hi)

------------------------------------------------------------ FAR: hills, windmill, far roofs (low contrast)
c:terrain(function(x) return 92 + 7 * sin(x / 47 + .6) + 3 * sin(x / 19) end, P.dusk.hi)
-- far windmill on the left hill
do
  R(150, 78, 155, 92, P.stone.hi) F(c:poly{ {149, 78}, {156, 78}, {152, 73} }, P.dusk.base)
  F(c:line({ {140, 66}, {164, 86} }, 1), P.dusk.base) F(c:line({ {164, 66}, {140, 86} }, 1), P.dusk.base)
end
c:terrain(function(x) return 102 + 4 * sin(x / 29 + 2) + 2 * sin(x / 11) end, P.sea.hi)
-- far rooftops of the old town, two tones
for _, r in ipairs{ {176, 101, 10}, {192, 98, 8}, {206, 103, 7}, {274, 102, 8}, {290, 97, 10}, {306, 103, 7} } do
  local x, y, hw = r[1], r[2], r[3]
  F(c:rect(x - hw + 2, y, x + hw - 2, HOR - 1), P.stone.hi)
  F(c:poly{ {x - hw, y + 1}, {x + hw, y + 1}, {x, y - hw + 2} }, P.dusk.base)
  F(c:poly{ {x, y + 1}, {x + hw, y + 1}, {x, y - hw + 2} }, P.dusk.shade)
  c:px(x - 2, y + 4, P.dusk.base) c:px(x + 2, y + 4, P.dusk.base)
end
-- N road climbing over the hill (thin, pale)
F(c:line({ {240, 111}, {244, 106}, {238, 101}, {243, 96} }, 1), P.stone.hi)

------------------------------------------------------------ GROUND
R(0, HOR, W - 1, Hh - 1, P.moss.base)
c:terrain(function(x) return HOR + 5 + 2 * sin(x / 13) end, P.moss.base) -- (keeps base)
F(c:rect(0, HOR, W - 1, HOR + 3), P.moss.hi)
for x = 0, W - 1, 2 do if H(x, 1, 2) < .5 then c:px(x, HOR + 4, P.moss.hi) end end
-- hedgerow along the horizon (behind everything)
for x = -4, W + 4, 9 do
  local hx = x + floor(H(x, 0, 5) * 4)
  F(E(hx, HOR + 1, 6, 3):clip(c:rect(0, HOR - 3, W - 1, HOR + 4)), P.moss.shade)
  c:px(hx - 2, HOR - 1, P.moss.base) c:px(hx - 1, HOR - 2, P.moss.base)
end
-- near band: darker grass at the bottom
c:terrain(function(x) return 250 + 3 * sin(x / 17) end, P.moss.shade)

------------------------------------------------------------ ROADS (width grows toward the viewer)
local roads = HP.mask()
local function road(pts, k)
  k = k or 1
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local len = sqrt((b[1] - a[1]) ^ 2 + (b[2] - a[2]) ^ 2)
    for s = 0, len do
      local t = s / math.max(len, 1)
      local x, y = a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t
      local r = (2.5 + math.max(0, y - HOR) * 0.062) * k
      roads:add(E(floor(x), floor(y), floor(r + .5), math.max(1, floor(r * .7 + .5))))
    end
  end
end
road({ {240, 170}, {240, 118}, {240, HOR} })                                                        -- N
road({ {66, HOR}, {108, 128}, {170, 123}, {240, 121}, {310, 123}, {372, 128}, {388, 120}, {396, HOR} }, .9) -- back lane, NW + NE
road({ {222, 186}, {160, 212}, {84, 236}, {48, 269} })                                               -- SW
road({ {240, 186}, {240, 269} })                                                                     -- S
road({ {258, 186}, {320, 210}, {396, 236}, {424, 269} })                                             -- SE
road({ {150, 216}, {90, 196}, {28, 176}, {0, 171} })                                                 -- W
road({ {326, 212}, {400, 199}, {452, 176}, {479, 170} })                                             -- E
-- clear end patches at every exit
for _, e in ipairs(EXITS) do local r = e[2] < 140 and 14 or 20 roads:add(E(e[1], e[2], r, floor(r * .72))) end
roads:clip(c:rect(0, HOR, W - 1, Hh - 1))
F(roads, P.wood.hi)
-- road edges + cobble/rut texture, never inside the clear circles
roads:each(function(x, y)
  if not free(x, y, -3) then return end
  if not roads:has(x, y + 1) or not roads:has(x + 1, y) then c:px(x, y, P.wood.base)
  elseif not roads:has(x, y - 1) or not roads:has(x - 1, y) then c:px(x, y, P.gold.hi)
  else
    local h = H(x, y, 9)
    if h < .05 then c:px(x, y, P.wood.base) elseif h < .09 then c:px(x, y, P.stone.hi) end
  end
end)

------------------------------------------------------------ THE GREEN: cobble ring, lawn, flower beds
local ring = E(240, 170, 54, 21)
local lawn = E(240, 169, 46, 16)
F(ring, P.stone.hi)
ring:each(function(x, y)
  if lawn:has(x, y) or not free(x, y, -6) then return end
  if (x + (y % 2) * 2) % 4 == 0 or y % 3 == 0 then c:px(x, y, P.stone.base) end
end)
c:rim(lawn, P.moss.shade)
F(lawn, P.moss.hi)
lawn:each(function(x, y)
  local h = H(x, y, 4)
  if (x + y) % 6 == 0 and h < .5 then c:px(x, y, P.moss.base) end      -- mown stripes
end)
-- flower beds at both ends of the lawn
for _, b in ipairs{ {206, 170}, {274, 170} } do
  local bed = E(b[1], b[2], 8, 4)
  c:rim(bed, P.wood.deep) F(bed, P.wood.shade)
  for i = 0, 6 do
    local fx, fy = b[1] - 6 + i * 2, b[2] - 1 + (i % 2) * 2
    local col = P[({ "petal", "gold", "ember", "dusk" })[i % 4 + 1]]
    c:px(fx, fy + 1, P.moss.shade) c:px(fx, fy, col.base) c:px(fx, fy - 1, col.hi)
  end
end

------------------------------------------------------------ GROUND SCATTER (only where it is not a clear zone)
for gy = HOR + 6, Hh - 3, 4 do
  for gx = 2, W - 3, 5 do
    local x = gx + floor(H(gx, gy, 1) * 4)
    local y = gy + floor(H(gx, gy, 2) * 3)
    if free(x, y, 2) and not roads:grow(0):has(x, y) and not ring:has(x, y) then
      local h = H(x, y, 3)
      local near = y > 200
      local dark = near and P.moss.deep or P.moss.shade
      if h < .38 then                                         -- grass tuft
        c:px(x, y, dark) c:px(x - 1, y - 1, dark) c:px(x + 1, y - 1, dark)
        if near then c:px(x, y - 2, dark) end
      elseif h < .52 then                                     -- speckle of light
        c:px(x, y, P.moss.hi) c:px(x + 1, y, P.moss.hi)
      elseif h < .64 then                                     -- flower
        local col = P[({ "petal", "gold", "cream", "dusk", "ember" })[floor(H(x, y, 7) * 5) + 1]] or P.cream
        local hx = type(col) == "table" and col.base or col
        c:px(x, y + 1, P.moss.shade) c:px(x, y, hx)
        if type(col) == "table" then c:px(x - 1, y, col.hi) end
      elseif h < .72 then                                     -- pebble
        c:px(x, y, P.stone.base) c:px(x + 1, y, P.stone.shade) c:px(x, y - 1, P.stone.hi)
      elseif h < .78 then                                     -- clover
        c:px(x, y, P.moss.hi) c:px(x - 1, y, P.moss.hi) c:px(x, y - 1, P.moss.hi) c:px(x, y + 1, P.moss.shade)
      end
    end
  end
end
-- moss on the shady side of path edges, fallen petals near the beds
for _, p in ipairs{ {176, 226}, {186, 232}, {300, 226}, {150, 250}, {330, 246} } do
  if free(p[1], p[2], 2) then c:px(p[1], p[2], P.petal.hi) c:px(p[1] + 2, p[2] + 1, P.petal.base) end
end
-- puddle with a sky reflection
do local pd = E(140, 246, 9, 3) c:rim(pd, P.wood.base) F(pd, P.sky.shade) R(134, 245, 138, 245, P.sky.hi) c:px(144, 247, P.cream) end
-- mushroom fairy ring
for i = 0, 7 do
  local a = i / 8 * 6.283
  local mx, my = floor(326 + 9 * cos(a)), floor(238 + 4 * sin(a))
  R(mx, my, mx, my + 1, P.cream) R(mx - 1, my - 1, mx + 1, my - 1, i % 3 == 0 and P.gold.base or P.ember.base) c:px(mx - 1, my - 1, P.ember.hi)
end
-- stepping stones by the homes' fence
for _, s in ipairs{ {70, 178}, {80, 184} } do c:part(E(s[1], s[2], 3, 2), "stone", { band = 1, nopop = true, inner = false }) end

------------------------------------------------------------ helpers for buildings
local function thatch(m, seed)
  c:part(m, "gold", { band = 3, nopop = true, inner = false })
  m:each(function(x, y)
    local h = H(x, floor(y / 3), seed)
    if not m:has(x, y + 1) or not m:has(x, y + 2) then c:px(x, y, (x % 3 == 0) and P.wood.base or P.gold.shade)
    elseif x % 3 == 0 and h < .55 then c:px(x, y, P.gold.shade)
    elseif y % 7 == 0 and H(x, y, seed + 1) < .7 then c:px(x, y, P.wood.base)
    elseif (not m:has(x - 1, y) or not m:has(x, y - 1)) then c:px(x, y, P.gold.hi) end
  end)
end
local function tiles(m, ramp, top, seed)
  local rr = P[ramp]
  c:part(m, ramp, { band = 3, nopop = true, inner = false })
  m:each(function(x, y)
    local r = (y - top) % 4
    if r == 3 then c:px(x, y, rr.shade)
    elseif r ~= 3 and (x + ((y - top) // 4) * 3) % 6 == 0 then c:px(x, y, rr.shade)
    elseif r == 0 and (not m:has(x - 1, y) or H(x, y, seed) < .25) then c:px(x, y, rr.hi) end
    if not m:has(x, y + 1) then c:px(x, y, rr.deep) end
  end)
end
local function wall(m) c:part(m, CREAMR, { band = 2, nopop = true, inner = false }) end
local function window(cx, cy, hw, hh, box, glass)
  R(cx - hw - 1, cy - hh - 1, cx + hw + 1, cy + hh + 1, P.wood.deep)
  R(cx - hw, cy - hh, cx + hw, cy + hh, glass or P.sea.base)
  R(cx - hw, cy - hh, cx - hw + 1, cy - hh, P.sea.hi) c:px(cx - hw, cy - hh + 1, P.sea.hi)
  R(cx, cy - hh, cx, cy + hh, P.wood.deep)
  if box then
    R(cx - hw - 2, cy + hh + 2, cx + hw + 2, cy + hh + 3, P.wood.base) R(cx - hw - 2, cy + hh + 3, cx + hw + 2, cy + hh + 3, P.wood.shade)
    for fx = cx - hw - 1, cx + hw + 1, 2 do
      local col = P[({ "petal", "gold", "ember", "dusk" })[(fx // 2) % 4 + 1]]
      c:px(fx, cy + hh + 1, col.base) c:px(fx + 1, cy + hh + 1, P.moss.base) c:px(fx, cy + hh, col.hi)
    end
  end
end
local function door(cx, by, hw, hh, ramp)
  local m = c:rrect(cx - hw, by - hh, cx + hw, by, hw)
  c:rim(m, P.wood.deep)
  c:part(m, ramp, { band = 1, nopop = true, inner = false })
  c:px(cx + hw - 1, by - hh // 2, P.gold.hi)
end
local function smoke(x, y)
  F(E(x, y, 2, 2), P.stone.hi) F(E(x + 3, y - 5, 3, 2), P.stone.hi) F(E(x + 1, y - 11, 4, 3), P.cream) c:px(x + 2, y - 12, P.sky.hi)
end

------------------------------------------------------------ MID TREES flanking the N road
for _, t in ipairs{ {190, 120, 8}, {292, 120, 8}, {204, 114, 5} } do
  local cr = E(t[1], t[2] - t[3], t[3], t[3])
  local tr = c:rect(t[1] - 1, t[2] - 2, t[1] + 1, t[2] + 5)
  c:rim(cr:copy():add(tr), P.moss.deep)
  c:part(tr, "wood", { band = 1, nopop = true, inner = false })
  c:part(cr, "moss", { band = 2, nopop = true, inner = false })
  cr:each(function(x, y) if H(x, y, 11) < .12 then c:px(x, y, P.moss.hi) elseif H(x, y, 12) < .1 then c:px(x, y, P.moss.shade) end end)
end

------------------------------------------------------------ WILD: overgrown trail into the wood (right edge)
do
  local trunks = c:rect(418, 104, 422, 150):add(c:rect(458, 98, 463, 146)):add(c:rect(474, 104, 478, 146))
  local crowns = E(420, 92, 15, 16):add(E(442, 80, 14, 13)):add(E(462, 84, 16, 17)):add(E(478, 96, 10, 14)):add(E(410, 110, 8, 8))
  local brambles = E(414, 142, 12, 7):add(E(470, 144, 12, 7)):add(E(452, 140, 5, 4))
  local all = trunks:copy():add(crowns):add(brambles)
  c:rim(all, P.moss.deep)
  -- dark gap where the trail enters
  F(c:poly{ {432, 148}, {450, 148}, {446, 108}, {436, 108} }, P.moss.deep)
  F(c:poly{ {436, 132}, {446, 132}, {444, 112}, {438, 112} }, P.dusk.deep)
  c:part(trunks, "wood", { band = 2, nopop = true, inner = false })
  trunks:each(function(x, y) if (y + x) % 5 == 0 then c:px(x, y, P.wood.shade) end end) -- bark grain
  c:part(crowns, NEARLEAF, { band = 4, pop = { 414, 80 }, inner = false })
  crowns:each(function(x, y)
    local h = H(x, y, 21)
    if h < .1 then c:px(x, y, P.moss.hi) elseif h < .22 then c:px(x, y, P.moss.deep) end
  end)
  c:part(brambles, "moss", { band = 2, nopop = true, inner = false })
  brambles:each(function(x, y) local h = H(x, y, 22) if h < .05 then c:px(x, y, P.dusk.shade) c:px(x, y - 1, P.dusk.hi) elseif h < .15 then c:px(x, y, P.moss.shade) end end)
  -- the wild trail, narrowing into the dark
  F(c:poly{ {434, 156}, {448, 156}, {444, 132}, {440, 124}, {437, 132} }, P.wood.base)
  F(c:poly{ {438, 154}, {444, 154}, {441, 134} }, P.wood.hi)
  -- leaning arrow sign
  R(427, 132, 428, 150, P.wood.shade)
  local sg = c:poly{ {422, 130}, {432, 129}, {435, 132}, {432, 135}, {422, 135} }
  c:rim(sg, P.wood.deep) F(sg, P.wood.hi) R(424, 132, 430, 132, P.wood.base)
end

------------------------------------------------------------ HOMES: a lane of three cottages
do
  -- D: back-left, thatched
  local dw, dr = c:rect(20, 134, 38, 147), c:poly{ {16, 136}, {42, 136}, {35, 124}, {23, 124} }
  -- A: tiled, middle
  local aw, ar = c:rect(38, 136, 58, 153), c:poly{ {35, 138}, {61, 138}, {48, 124} }
  -- B: front, big thatch
  local bw = c:rect(60, 144, 84, 165)
  local br = E(72, 146, 15, 12):clip(c:rect(0, 0, W, 146)):add(c:rect(57, 144, 87, 147))
  local chim = c:rect(50, 120, 54, 130)
  c:rim(dw:copy():add(dr):add(aw):add(ar):add(chim):add(bw):add(br), P.wood.deep)
  wall(dw) thatch(dr, 31)
  R(26, 140, 31, 140, P.wood.shade) window(32, 141, 2, 2, true) door(25, 147, 2, 5, "moss")
  c:part(chim, "stone", { band = 1, nopop = true, inner = false }) R(50, 124, 54, 124, P.stone.shade)
  wall(aw) tiles(ar, "ember", 124, 32)
  for _, x in ipairs{ 38, 58 } do R(x, 138, x, 153, P.wood.shade) end R(38, 144, 58, 144, P.wood.shade)
  window(44, 148, 2, 2, true) door(53, 153, 3, 7, "sea")
  c:part(bw, CREAMR, { band = 2, nopop = true, inner = false })
  for _, x in ipairs{ 60, 72, 84 } do R(x, 147, x, 165, P.wood.shade) end
  R(60, 154, 84, 154, P.wood.shade) F(c:line({ {61, 154}, {71, 147} }, 1), P.wood.shade) F(c:line({ {73, 147}, {83, 154} }, 1), P.wood.shade)
  thatch(br, 33)
  window(66, 158, 3, 2, true) window(79, 158, 3, 2, true)
  door(72, 165, 3, 7, "petal") -- round-top front door (petal pink)
  c:px(72, 151, P.gold.base) -- little house number
  smoke(52, 116)
  -- picket fence + front garden
  local fence = HP.mask()
  for x = 58, 94, 4 do fence:add(c:rect(x, 165, x + 1, 171)) end
  fence:add(c:rect(58, 167, 95, 167)):add(c:rect(58, 170, 95, 170))
  fence:cut(c:rect(70, 160, 75, 175)) -- gate gap
  c:rim(fence, P.stone.base) F(fence, P.cream)
  for x = 58, 94, 4 do c:px(x, 165, P.stone.hi) end
  -- hollyhocks against the wall
  for _, x in ipairs{ 88, 91 } do R(x, 152, x, 164, P.moss.shade) for y = 153, 162, 3 do c:px(x - 1, y, P.petal.base) c:px(x + 1, y + 1, P.petal.hi) end end
end

------------------------------------------------------------ LIBRARY: stone hall, slate roof, columns
do
  local wl = c:rect(130, 134, 162, 160)
  local rf = c:poly{ {126, 136}, {166, 136}, {156, 120}, {136, 120} }
  local gab = c:poly{ {138, 136}, {154, 136}, {146, 126} }
  local steps = c:rect(136, 160, 156, 163)
  local all = wl:copy():add(rf):add(steps)
  c:fillMask(E(146, 164, 22, 2), P.moss.shade)
  c:rim(all, P.stone.deep)
  c:part(wl, "stone", { band = 3, nopop = true, inner = false })
  wl:each(function(x, y) if (y - 134) % 5 == 4 then c:px(x, y, P.stone.shade) elseif (x + ((y - 134) // 5) * 4) % 8 == 0 then c:px(x, y, P.stone.shade) end end)
  tiles(rf, "dusk", 120, 41)
  c:rim(gab, P.stone.shade) F(gab, P.stone.hi) F(E(146, 132, 2, 2), P.sea.base) c:px(145, 131, P.sea.hi) -- gable oculus
  -- columns + lintel
  R(132, 137, 160, 138, P.stone.hi) R(132, 139, 160, 139, P.stone.shade)
  for _, x in ipairs{ 134, 140, 152, 158 } do R(x, 140, x + 1, 159, P.stone.hi) R(x + 1, 140, x + 1, 159, P.stone.base) end
  -- arched door + tall windows
  door(146, 159, 4, 12, "wood")
  R(145, 148, 145, 159, P.wood.shade)
  window(137, 147, 1, 4, false) window(155, 147, 1, 4, false)
  -- open-book sign over the door
  local bk = c:poly{ {139, 141}, {146, 143}, {153, 141}, {153, 145}, {146, 147}, {139, 145} }
  c:rim(bk, P.wood.deep) F(bk, P.cream) R(146, 143, 146, 147, P.ember.shade) R(141, 143, 144, 143, P.stone.base) R(148, 143, 151, 143, P.stone.base)
  c:part(steps, "stone", { band = 1, nopop = true, inner = false }) R(136, 161, 156, 161, P.stone.shade)
  -- book cart beside the steps
  local cart = c:rect(160, 154, 170, 160)
  c:rim(cart, P.wood.deep) F(cart, P.wood.base) R(160, 160, 170, 160, P.wood.shade)
  for i = 0, 4 do local col = P[({ "ember", "sea", "gold", "dusk", "moss" })[i + 1]] R(161 + i * 2, 150 + (i % 2), 162 + i * 2, 153, col.base) c:px(161 + i * 2, 150 + (i % 2), col.hi) end
  R(162, 161, 163, 162, P.stone.shade) R(167, 161, 168, 162, P.stone.shade)
end

------------------------------------------------------------ SHOPS: three fronts + a fruit stall
do
  c:fillMask(E(326, 160, 30, 2), P.moss.shade)
  local fr = {
    { x0 = 298, x1 = 316, top = 128, roof = "ember", aw = "petal", base = 159 },
    { x0 = 316, x1 = 335, top = 132, roof = "sea",   aw = "sea",   base = 159 },
    { x0 = 334, x1 = 352, top = 141, roof = "thatch", aw = "gold", base = 159 },
  }
  local all = HP.mask()
  for _, s in ipairs(fr) do
    s.w = c:rect(s.x0, s.top + 8, s.x1, s.base)
    local mid = (s.x0 + s.x1) // 2
    s.r = c:poly{ {s.x0 - 2, s.top + 9}, {s.x1 + 2, s.top + 9}, {mid, s.top - 2} }
    all:add(s.w):add(s.r)
  end
  c:rim(all, P.wood.deep)
  for i, s in ipairs(fr) do
    local mid = (s.x0 + s.x1) // 2
    wall(s.w)
    R(s.x0, s.top + 9, s.x0, s.base, P.wood.shade) R(s.x1, s.top + 9, s.x1, s.base, P.wood.shade)
    if s.roof == "thatch" then thatch(s.r, 50 + i) else tiles(s.r, s.roof, s.top - 2, 50 + i) end
    window(mid, s.top + 13, 1, 1, false)
    -- awning: striped, scalloped edge
    local aw = c:rect(s.x0 - 1, 146, s.x1 + 1, 149)
    c:rim(aw, P[s.aw].deep)
    aw:each(function(x, y) c:px(x, y, ((x - s.x0) // 3) % 2 == 0 and P[s.aw].base or P.cream) end)
    for x = s.x0, s.x1, 3 do c:px(x + 1, 150, P[s.aw].shade) end
    -- shop window with goods
    R(s.x0 + 2, 151, mid - 2, 157, P.wood.deep) R(s.x0 + 3, 152, mid - 3, 156, P.sea.hi)
    for gx = s.x0 + 3, mid - 3, 2 do
      local g = ({ P.gold.base, P.sea.base, P.ember.base })[i]
      c:px(gx, 156, g) c:px(gx, 155, i == 1 and P.gold.hi or g)
    end
    door(mid + 4, 159, 2, 6, ({ "moss", "ember", "dusk" })[i])
  end
  -- hanging signs: loaf, jar, spool
  R(306, 138, 306, 140, P.wood.deep) F(E(306, 142, 3, 2), P.gold.base) c:px(305, 141, P.gold.hi)
  R(325, 141, 325, 142, P.wood.deep) R(323, 143, 327, 146, P.sea.base) c:px(323, 143, P.sea.hi)
  -- small bunting between the shop roofs
  F(c:line({ {300, 136}, {316, 140}, {334, 144} }, 1), P.wood.deep)
  for i, x in ipairs{ 303, 309, 315, 321, 327 } do
    local y = 136 + floor((x - 300) * .24) + 1
    local col = P[({ "ember", "gold", "sea", "petal", "dusk" })[i]]
    F(c:poly{ {x - 1, y}, {x + 1, y}, {x, y + 2} }, col.base)
  end
  -- fruit stall in front (right)
  local posts = c:rect(337, 153, 338, 170):add(c:rect(360, 153, 361, 170))
  local awn = c:poly{ {335, 150}, {363, 150}, {364, 155}, {334, 155} }
  local cnt = c:rect(336, 162, 362, 170)
  c:rim(posts:copy():add(awn):add(cnt), P.wood.deep)
  c:part(posts, "wood", { band = 1, nopop = true, inner = false })
  awn:each(function(x, y) c:px(x, y, ((x - 335) // 3) % 2 == 0 and P.ember.base or P.cream) end)
  for x = 336, 362, 3 do c:px(x, 156, P.ember.shade) end
  c:part(cnt, "wood", { band = 1, nopop = true, inner = false })
  for x = 337, 361, 4 do R(x, 163, x, 169, P.wood.shade) end
  -- fruit heaps on the counter
  for i = 0, 11 do
    local fx = 338 + i * 2
    local col = P[({ "ember", "ember", "gold", "moss", "dusk" })[i % 5 + 1]]
    c:px(fx, 161 - (i % 2), col.base) c:px(fx + 1, 161 - (i % 2), col.shade) c:px(fx, 160 - (i % 2), col.hi)
  end
  -- crates beside the shops
  local cr = c:rect(288, 150, 296, 158):add(c:rect(290, 144, 296, 149))
  c:rim(cr, P.wood.deep) c:part(cr, "wood", { band = 1, nopop = true, inner = false })
  R(288, 154, 296, 154, P.wood.shade) for x = 289, 295, 2 do c:px(x, 149, P.gold.base) c:px(x, 143, P.moss.base) end
end

------------------------------------------------------------ WELL on the green (hero) + festival bunting
do
  local ringT = E(240, 170, 10, 3)
  local body = c:rect(230, 170, 250, 181)
  local posts = c:rect(231, 153, 232, 170):add(c:rect(248, 153, 249, 170))
  local roof = c:poly{ {225, 155}, {255, 155}, {246, 146}, {234, 146} }
  local base = E(240, 181, 10, 3)
  c:fillMask(E(242, 183, 15, 3), P.moss.shade)
  c:rim(body:copy():add(posts):add(roof):add(base):add(ringT), P.stone.deep)
  c:part(body:copy():add(base), "stone", { band = 3, nopop = true, inner = false })
  for y = 172, 182, 3 do
    for x = 230 + ((y // 3) % 2) * 2, 250, 4 do c:px(x, y, P.stone.shade) end
    R(230, y + 2, 250, y + 2, P.stone.shade)
  end
  R(231, 172, 236, 172, P.stone.hi) R(231, 175, 233, 175, P.stone.hi)
  F(ringT, P.stone.hi) F(E(240, 170, 8, 2), P.sea.deep) R(236, 170, 239, 170, P.sea.shade)
  c:part(posts, "wood", { band = 1, nopop = true, inner = false })
  tiles(roof, "wood", 146, 61)
  -- crank + rope
  R(229, 158, 251, 158, P.wood.shade) R(252, 157, 252, 161, P.wood.deep) R(253, 161, 255, 161, P.wood.deep)
  R(240, 159, 240, 163, P.wood.base)
  -- QUIRK: the bucket is a teacup (borrowed from the teahouse), saucer and all
  local cup = c:rect(237, 164, 243, 168)
  c:rim(cup, P.petal.deep) F(cup, P.cream) R(237, 166, 243, 166, P.petal.base) R(241, 167, 243, 168, P.stone.hi)
  c:px(244, 165, P.petal.deep) c:px(245, 166, P.petal.deep) c:px(244, 167, P.petal.deep)
  R(236, 169, 244, 169, P.petal.shade) c:px(238, 165, P.petal.hi)
  -- festival bunting from the well roof to two poles on the green
  R(206, 150, 207, 166, P.wood.shade) R(273, 150, 274, 166, P.wood.shade)
  c:px(206, 149, P.gold.hi) c:px(274, 149, P.gold.hi)
  local function swag(x0, y0, x1, y1)
    for x = x0, x1 do
      local t = (x - x0) / (x1 - x0)
      local y = floor(y0 + (y1 - y0) * t + 5 * sin(t * 3.14159))
      c:px(x, y, P.wood.deep)
      if (x - x0) % 5 == 2 and x > x0 + 1 and x < x1 - 1 then
        local col = P[({ "ember", "gold", "sea", "petal", "dusk" })[((x // 5) % 5) + 1]]
        R(x - 1, y + 1, x + 1, y + 1, col.base) c:px(x, y + 2, col.shade)
      end
    end
  end
  swag(207, 151, 234, 147) swag(246, 147, 273, 151)
  -- bench on the green (left of the well)
  local bench = c:rect(212, 160, 222, 161):add(c:rect(213, 162, 214, 165)):add(c:rect(220, 162, 221, 165)):add(c:rect(212, 156, 222, 157))
  c:rim(bench, P.wood.deep) F(bench, P.wood.base) R(212, 161, 222, 161, P.wood.shade)
  -- watering can left on the lawn (right of the well)
  local can = c:rrect(259, 162, 265, 167, 1)
  c:rim(can, P.sea.deep) c:part(can, "sea", { band = 1, nopop = true, inner = false }) R(266, 162, 268, 160, P.sea.shade) c:px(266, 161, P.sea.shade) c:px(267, 160, P.sea.shade)
end

------------------------------------------------------------ LAMP POST at the green
do
  local lp = c:rect(195, 136, 196, 158)
  c:rim(lp, P.stone.deep) F(lp, P.stone.shade)
  local lamp = c:rect(193, 130, 198, 135)
  c:rim(lamp, P.stone.deep) F(lamp, P.gold.hi) c:px(194, 131, P.cream) R(193, 129, 198, 129, P.stone.shade)
  R(193, 158, 198, 159, P.stone.base)
end

------------------------------------------------------------ TEAHOUSE (hero): round thatch, teapot sign, terrace
do
  local body = c:rect(134, 176, 172, 201)
  local roof = E(153, 178, 24, 16):clip(c:rect(0, 0, W, 179))
  local eave = E(153, 178, 25, 3)
  local chim = c:rect(163, 160, 167, 170)
  c:fillMask(E(154, 202, 24, 2), P.moss.shade)
  c:rim(body:copy():add(roof):add(eave):add(chim), P.wood.deep)
  c:part(chim, "stone", { band = 1, nopop = true, inner = false }) R(163, 160, 167, 160, P.stone.hi)
  c:part(body, CREAMR, { band = 3, nopop = true, inner = false })
  for _, x in ipairs{ 134, 146, 160, 172 } do R(x, 180, x, 201, P.wood.shade) end
  R(134, 190, 172, 190, P.wood.shade)
  thatch(roof:copy():add(eave), 71)
  smoke(166, 154)
  -- big round window + flower box, door with a teacup knocker
  window(141, 185, 3, 2, true)
  window(166, 185, 3, 2, true)
  door(153, 201, 4, 12, "moss")
  c:px(153, 192, P.cream) c:px(154, 192, P.petal.base)
  -- teapot sign on a bracket
  R(172, 176, 180, 176, P.wood.deep) R(178, 177, 178, 178, P.wood.deep)
  local pot = E(178, 183, 5, 4):add(c:rect(176, 178, 180, 179)):add(c:line({ {183, 182}, {186, 179} }, 1))
  c:rim(pot, P.ember.deep) c:part(pot, "ember", { band = 1, pop = { 175, 181 }, inner = false })
  R(178, 177, 178, 177, P.gold.base)
  -- terrace: little table + parasol on the left
  local para = c:poly{ {116, 178}, {132, 178}, {124, 172} }
  local tbl = c:rect(119, 185, 129, 186):add(c:rect(123, 187, 125, 192))
  c:rim(para:copy():add(tbl), P.petal.deep)
  para:each(function(x, y) c:px(x, y, ((x - 116) // 3) % 2 == 0 and P.petal.base or P.cream) end)
  R(124, 179, 124, 184, P.wood.shade)
  F(tbl, P.wood.base) R(119, 186, 129, 186, P.wood.shade)
  R(121, 183, 122, 184, P.cream) c:px(123, 183, P.cream) R(126, 184, 127, 184, P.gold.base)
  -- barrels by the wall
  for _, b in ipairs{ {176, 196}, {182, 198} } do
    local m = c:rrect(b[1] - 3, b[2] - 6, b[1] + 3, b[2], 2)
    c:rim(m, P.wood.deep) c:part(m, "wood", { band = 1, nopop = true, inner = false })
    R(b[1] - 3, b[2] - 4, b[1] + 3, b[2] - 4, P.stone.shade) R(b[1] - 3, b[2] - 1, b[1] + 3, b[2] - 1, P.stone.shade)
  end
end

------------------------------------------------------------ NOTICE BOARD
do
  local posts = c:rect(330, 180, 332, 200):add(c:rect(348, 180, 350, 200))
  local frame = c:rect(328, 176, 352, 193)
  local cap = c:poly{ {326, 177}, {354, 177}, {348, 171}, {332, 171} }
  c:fillMask(E(340, 201, 14, 2), P.moss.shade)
  c:rim(posts:copy():add(frame):add(cap), P.wood.deep)
  c:part(posts, "wood", { band = 1, nopop = true, inner = false })
  F(frame, P.wood.base) R(330, 178, 350, 191, P.wood.hi)
  frame:each(function(x, y) if (x == 328 or x == 352 or y == 193) then c:px(x, y, P.wood.shade) end end)
  tiles(cap, "ember", 171, 81)
  -- pinned notices
  local notes = { {331, 179, 336, 185, P.cream}, {338, 180, 343, 187, P.sky.hi}, {345, 179, 349, 184, P.petal.hi}, {333, 186, 339, 190, P.gold.hi}, {342, 188, 348, 191, P.cream} }
  for i, n in ipairs(notes) do
    R(n[1], n[2], n[3], n[4], n[5]) R(n[1] + 1, n[4], n[3], n[4], P.stone.base)
    for y = n[2] + 2, n[4] - 1, 2 do R(n[1] + 1, y, n[3] - 1 - (y % 3), y, P.stone.shade) end
    c:px((n[1] + n[3]) // 2, n[2], i % 2 == 0 and P.sea.shade or P.ember.base)
  end
end

------------------------------------------------------------ SIGNPOST at the south fork
do
  local post = c:rect(170, 222, 171, 242)
  local a1 = c:poly{ {162, 223}, {178, 223}, {181, 226}, {178, 229}, {162, 229} }
  local a2 = c:poly{ {180, 231}, {163, 231}, {160, 234}, {163, 237}, {180, 237} }
  c:rim(post:copy():add(a1):add(a2), P.wood.deep)
  c:part(post, "wood", { band = 1, nopop = true, inner = false })
  F(a1, P.wood.hi) F(a2, P.wood.hi) R(165, 226, 176, 226, P.wood.base) R(165, 234, 176, 234, P.wood.base)
  c:px(163, 224, P.cream) c:px(178, 232, P.wood.base)
  R(168, 242, 173, 243, P.moss.shade)
end

------------------------------------------------------------ NEAR PLANE
-- bottom-left bush with daisies
do
  local b = E(14, 262, 30, 16):add(E(44, 270, 12, 7)):add(E(4, 246, 10, 10))
  c:rim(b, P.moss.deep)
  c:part(b, NEARLEAF, { band = 4, pop = { 6, 244 }, inner = false })
  b:each(function(x, y)
    local h = H(x, y, 91)
    if h < .05 then c:px(x, y, P.cream) c:px(x + 1, y, P.gold.base) elseif h < .16 then c:px(x, y, P.moss.deep) elseif h < .2 then c:px(x, y, P.moss.base) end
  end)
end
-- bottom-right bush + sunflower
do
  local b = E(470, 256, 26, 18):add(E(446, 268, 12, 5))
  local stem = c:rect(458, 210, 459, 244)
  local leaf = c:poly{ {459, 228}, {468, 222}, {462, 231} }
  local head = E(458, 205, 7, 7)
  c:rim(b:copy():add(stem):add(leaf):add(head), P.moss.deep)
  c:part(b, NEARLEAF, { band = 4, pop = { 454, 244 }, inner = false })
  b:each(function(x, y) local h = H(x, y, 92) if h < .14 then c:px(x, y, P.moss.deep) elseif h < .18 then c:px(x, y, P.moss.base) elseif h < .21 then c:px(x, y, P.ember.base) end end)
  F(stem, P.moss.shade) F(leaf, P.moss.base) c:px(461, 226, P.moss.hi)
  c:part(head, "gold", { band = 2, pop = { 453, 200 }, inner = false })
  F(E(458, 205, 2, 2), P.wood.shade) c:px(457, 204, P.wood.base)
end
-- flower barrel (bottom centre-left)
do
  local bar = c:rrect(152, 252, 172, 269, 3)
  local fl = E(162, 249, 14, 6)
  c:rim(bar:copy():add(fl), P.wood.deep)
  c:part(bar, "wood", { band = 2, nopop = true, inner = false })
  bar:each(function(x, y) if (x - 152) % 5 == 0 then c:px(x, y, P.wood.shade) end end)
  R(152, 256, 172, 257, P.stone.base) R(152, 263, 172, 264, P.stone.base) R(152, 256, 160, 256, P.stone.hi)
  c:part(fl, "moss", { band = 2, nopop = true, inner = false })
  for i = 0, 9 do
    local fx, fy = 151 + i * 2 + (i % 2), 245 + (i * 7) % 6
    local col = P[({ "petal", "gold", "ember", "dusk", "cream" })[i % 5 + 1]] or P.cream
    if type(col) == "table" then c:px(fx, fy, col.base) c:px(fx + 1, fy, col.base) c:px(fx, fy - 1, col.hi) c:px(fx + 1, fy + 1, col.shade)
    else c:px(fx, fy, col) c:px(fx + 1, fy, col) c:px(fx, fy + 1, P.gold.base) end
  end
  -- watering can & trowel at the barrel foot
  R(176, 266, 184, 267, P.stone.shade) R(176, 265, 181, 265, P.stone.hi)
end
-- wheelbarrow of pumpkins (bottom centre-right)
do
  local tub = c:poly{ {292, 252}, {332, 252}, {326, 264}, {298, 264} }
  local wheel = E(314, 266, 5, 5)
  local handles = c:line({ {332, 254}, {346, 262} }, 1)
  local legs = c:rect(300, 264, 301, 269):add(c:rect(324, 264, 325, 269))
  local pumps = E(302, 248, 6, 4):add(E(314, 246, 7, 5)):add(E(325, 249, 5, 3))
  c:rim(tub:copy():add(wheel):add(handles):add(legs):add(pumps), P.wood.deep)
  c:part(legs:copy():add(handles), "wood", { band = 1, nopop = true, inner = false })
  c:part(tub, "sea", { band = 2, nopop = true, inner = false })
  R(294, 253, 330, 253, P.sea.hi) R(299, 259, 325, 259, P.sea.shade)
  c:part(pumps, "gold", { band = 2, nopop = true, inner = false })
  for _, x in ipairs{ 299, 305, 311, 317, 322 } do R(x, 245, x, 251, P.gold.shade) end
  R(314, 240, 314, 241, P.moss.shade) R(302, 243, 303, 244, P.moss.shade)
  c:px(309, 243, P.gold.hi) c:px(310, 243, P.gold.hi)
  c:part(wheel, "stone", { band = 2, nopop = true, inner = false }) F(E(314, 266, 1, 1), P.stone.deep)
end
-- overhead bunting across the top of the frame
do
  local function by(x) local t = (x - 240) / 240 return floor(4 + 22 * (1 - t * t)) end
  for x = 0, W - 1 do c:px(x, by(x), P.wood.deep) end
  local cols = { "ember", "gold", "sea", "petal", "dusk", "moss" }
  local i = 0
  for x = 8, W - 8, 16 do
    i = i + 1
    local y = by(x)
    local f = c:poly{ {x - 4, y + 1}, {x + 4, y + 1}, {x, y + 9} }
    local col = P[cols[i % #cols + 1]]
    c:rim(f, col.deep) F(f, col.base)
    f:each(function(px, py) if px >= x + 1 and py >= y + 3 then c:px(px, py, col.shade) end end)
    c:px(x - 2, y + 2, col.hi) c:px(x - 1, y + 2, col.hi)
  end
end

c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "here-town.aseprite", png = out .. "here-town.png", scale = 1 }
