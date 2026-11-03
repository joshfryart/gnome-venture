-- ico-hourglass (final, Opus). A slim standing hourglass: turned walnut end caps (bevelled rims, lip mouldings, bun
-- feet, horizontal grain streaks and a pale end-grain notch), two 3 px barley-twist posts in front, and a waisted
-- glass body with round per-pixel light (cool pale glass tones, bright rim on the right, curved cream specular in
-- each bulb). Golden sand: the top charge has sunk into a funnel, a thin stream falls through the neck, the bottom
-- heap is a cone with grain speckle. AO where glass and posts meet the caps; 2-tone ground shadow.
-- quirk: someone has built a tiny sand castle (with a red flag) on the bottom heap.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.cos, math.pi
local c = A.new("ico-hourglass")
local WD  = { "#3a2020", "#5a3226", "#7e4a30", "#a46a3e", "#c98e56", "#e8b982" }
local GLS = { "#5c7494", "#86a2bf", "#a9c8dc", "#c9e4ee", "#e6f6f6" }
local SND = { "#7a4a1c", "#a8691f", "#d0902c", "#eab445", "#f8d470", "#fff0b0" }
local wtok, gtok, stok, ptok = A.tok("wood"), A.tok("glass"), A.tok("sand"), A.tok("post")
local CX = 31.5

c:groundShadow(32, 57, 18, 1)
-- glass: waisted body, half-width per row
local G0, G1, NECK = 16, 49, 32.5
local function hw(y)
  local t = abs(y - NECK) / (NECK - G0)
  return 1.2 + 8.6 * math.sin(min(1, t) * pi / 2) ^ 0.9 * (t > 0.9 and (1 - (t - 0.9) * 1.6) or 1)
end
local glass, gn = HP.mask(), {}
for y = G0, G1 do local w = hw(y)
  for x = 20, 43 do local u = (x - CX) / (w + 0.5)
    if abs(u) <= 1 then glass:set(x, y)
      local sl = (y < NECK) and 0.25 or -0.25      -- walls lean toward the neck
      local ny = (y < NECK and -1 or 1) * 0.0 + sl * abs(u)
      local nx = u * 0.9
      gn[K(x, y)] = { nx, ny, sqrt(max(0.04, 1 - nx * nx - ny * ny)) }
    end end end
local gidx = A.shade(c, glass, gn, GLS, { tok = gtok, amb = 0.3, wrap = 0.5, cuts = { 0.3, 0.5, 0.68, 0.84 } })

-- sand: top charge (funnel surface), stream, bottom cone
local sand = HP.mask()
glass:each(function(x, y)
  local dx = abs(x - CX)
  if y < NECK and y >= 23 + max(0, 5 - dx * 0.8) then sand:set(x, y) end
  if y > NECK and y >= 40 + dx * 0.75 then sand:set(x, y) end
end)
local sn = {}
sand:each(function(x, y) local u = (x - CX) / 9 sn[K(x, y)] = { u * 0.85, -0.15, sqrt(max(0.05, 1 - u * u * 0.72 - 0.02)) } end)
local sidx = A.shade(c, sand, sn, SND, { tok = stok, amb = 0.12, wrap = 0.35, cuts = { 0.2, 0.38, 0.55, 0.72, 0.9 } })
-- heap surfaces: lit crest row on the funnel and the cone
sand:each(function(x, y)
  if not sand:has(x, y - 1) then c:put(x, y, x < CX and SND[6] or SND[5], stok) end
  if X.hash(x, y, 7) < 0.12 and sand:has(x, y - 1) then A.step(c, sidx, SND, x, y, -1, stok) end
end)
for y = 29, 40 do c:put(32, y, y < 33 and SND[4] or SND[5], stok) end
-- glass in front of the sand: keep its rim and specular so it reads as inside
glass:edge():each(function(x, y) local k = K(x, y)
  if gn[k][1] > 0.5 then c:put(x, y, GLS[4], gtok) end
  if gn[k][1] < -0.6 and y ~= G0 and y ~= G1 then c:put(x, y, GLS[2], gtok) end end)
-- curved cream speculars, one per bulb
for _, p in ipairs{ { 25, 19 }, { 24, 20 }, { 24, 21 }, { 24, 22 }, { 25, 23 }, { 24, 43 }, { 24, 44 }, { 24, 45 }, { 25, 46 } } do
  c:put(p[1], p[2], "#fff4d6", gtok) end
c:put(26, 19, GLS[5], gtok) c:put(25, 44, GLS[5], gtok)

-- quirk: tiny sand castle with a red flag on the bottom heap
A.map(c, {
  "....r..",
  "....rr.",
  "....i..",
  ".a.aia.",
  ".abbbb.",
  ".abdbc.",
}, 33, 39, { r = "#e8493b", i = WD[2], a = SND[6], b = SND[5], c = SND[3], d = SND[2] }, stok)

-- end caps: plate + lip moulding (+ feet at the bottom)
local function cap(y0, y1, ly0, ly1, top)
  local plate = HP.rrect(14, y0, 49, y1, 2)
  local pidx = A.pill(c, plate, 2.2, WD, { tok = wtok, amb = 0.12, wrap = 0.3, cuts = { 0.18, 0.36, 0.54, 0.72, 0.88 } })
  -- grain: broken horizontal streaks
  for x = 16, 47 do
    if X.hash(x, y0, 3) < 0.55 then A.step(c, pidx, WD, x, y0 + 2, -1, wtok) end
    if X.hash(x, y0, 9) < 0.25 then A.step(c, pidx, WD, x, y0 + 1, 1, wtok) end
  end
  -- end grain on the left face
  c:put(14, y0 + 2, WD[6], wtok) c:put(15, y0 + 2, WD[5], wtok)
  local lip = HP.rect(17, ly0, 46, ly1)
  local lidx = A.pill(c, lip, 1.2, WD, { tok = wtok, amb = 0.1, wrap = 0.3 })
  -- AO: the row of the lip that meets the plate
  for x = 17, 46 do A.step(c, lidx, WD, x, top and ly0 or ly1, -1, wtok) end
  return plate, lip
end
cap(9, 13, 14, 15, true)
cap(50, 54, 48, 49, false)
-- knob and bun feet
local knob = HP.rrect(27, 7, 36, 8, 1)
A.pill(c, knob, 1.4, WD, { tok = wtok, amb = 0.15, wrap = 0.3 })
for _, fx in ipairs{ 16, 43 } do A.pill(c, HP.rrect(fx, 55, fx + 4, 56, 1), 1.2, WD, { tok = wtok, amb = 0.1, wrap = 0.3 }) end
-- AO on glass rows touching the caps
for x = 20, 43 do
  if glass:has(x, G0) then A.step(c, gidx, GLS, x, G0, -2, gtok) end
  if glass:has(x, G1) then A.step(c, gidx, GLS, x, G1, -2, gtok) end
end

-- barley-twist posts (3 px) in front of the glass
for _, px in ipairs{ 17, 44 } do
  for y = 16, 47 do
    local ph = (y + (px > 30 and 2 or 0)) % 4
    local row = ph == 0 and { 2, 3, 2 } or ph == 1 and { 4, 5, 3 } or ph == 2 and { 5, 6, 4 } or { 3, 4, 2 }
    if y == 16 or y == 47 then row = { 1, 2, 1 } end
    for i = 0, 2 do c:put(px + i, y, WD[row[i + 1]], ptok) end
  end
end
-- pop: 2x1 hi on the top cap
c:put(18, 10, WD[6], wtok) c:put(19, 10, WD[6], wtok)
A.save(c, "ico-hourglass")
