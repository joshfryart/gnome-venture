-- root_cellar-mossy (final, Opus-style single pass). An ancient cellar swallowed by moss: eight overlapping moss
-- cushions (hemisphere height field, so every lobe has its own light and a dark crease where they meet) sit on a
-- squat earth footing. A flat post-and-lintel doorway of mossy block stone frames a banded plank door with an iron
-- Z-brace and ring pull; moss drips over the lintel. Two toadstools at the foot.
-- quirk: a snail has parked on the crown of the moss.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "root_cellar-mossy" }
local M, S, W, I, Y, CR = A.OLIVE, A.STONE, A.WOOD, A.IRON, A.YELLOW, A.CREAMR
local H = A.hash

c:groundShadow(32, 56, 25, 2)

-- earth footing
local foot = c:rect(7, 54, 57, 55)
local fidx = A.lit(c, foot, W, 1, { amb = 0.12 })
foot:each(function(x, y) local h = H(x, y, 21)
  if h > 0.86 then c:px(x, y, W[min(6, (fidx[K(x, y)] or 3) + 2)]) elseif h < 0.08 then c:px(x, y, W[1]) end end)

-- moss cushions
local lobes = { { 15, 41, 8 }, { 22, 30, 10 }, { 38, 26, 12 }, { 48, 36, 9 }, { 31, 39, 14 }, { 47, 46, 8 }, { 18, 48, 7 }, { 34, 20, 8 } }
local function hf(x, y)
  local best = 0
  for _, l in ipairs(lobes) do
    local dx, dy = x - l[1], y - l[2]
    local q = l[3] * l[3] - dx * dx - dy * dy
    if q > 0 then best = max(best, sqrt(q)) end
  end
  return best
end
local mm = HP.mask()
for y = 8, 53 do for x = 5, 60 do if hf(x, y) > 0 then mm:set(x, y) end end end
-- shaggy rim: carve some edge pixels, add some outside
local carve = mm:edge()
carve:each(function(x, y) if y < 52 and H(x, y, 41) < 0.16 then mm:cut(c:rect(x, y, x, y)) end end)
mm:grow(1):cut(mm):each(function(x, y) if y < 52 and y > 8 and x > 6 and x < 58 and H(x, y, 42) > 0.74 then mm:set(x, y) end end)

local door = HP.mask()   -- frame region (for AO bias)
local lintel = c:rect(22, 31, 41, 35)
local jl, jr = c:rect(22, 36, 25, 53), c:rect(38, 36, 41, 53)
local opening = c:rect(26, 36, 37, 53)
door:add(lintel):add(jl):add(jr):add(opening)

local n = {}
mm:each(function(x, y)
  local gx = (hf(x + 1, y) - hf(x - 1, y)) / 2
  local gy = (hf(x, y + 1) - hf(x, y - 1)) / 2
  local l = sqrt(gx * gx * 0.85 + gy * gy * 0.85 + 1)
  n[K(x, y)] = { -gx * 0.92 / l, -gy * 0.92 / l, 1 / l }
end)
local bias = {}
X.ao(bias, mm, door, 2, -1)
local idx = A.shade(c, mm, n, M, { amb = 0.05, wrap = 0.2, bias = bias, cuts = { 0.22, 0.4, 0.57, 0.73, 0.88 } })
mm:each(function(x, y) local h = H(x, y, 3)
  if h > 0.84 then A.bump(c, idx, M, x, y, 1) elseif h < 0.09 then A.bump(c, idx, M, x, y, -1) end end)
-- little frond ticks
for i = 0, 40 do
  local x, y = 8 + floor(H(i, 1, 70) * 48), 14 + floor(H(i, 2, 71) * 36)
  if mm:has(x, y) and mm:has(x + 1, y - 1) and not door:has(x, y) then
    c:px(x, y, M[min(6, (idx[K(x, y)] or 3) + 2)]) c:px(x + 1, y - 1, M[min(6, (idx[K(x + 1, y - 1)] or 3) + 1)])
  end
end

-- stone frame (post and lintel)
local frame = HP.mask():add(lintel):add(jl):add(jr)
local fn = X.pillow(frame, 2)
local fidx2 = A.shade(c, frame, fn, S, { amb = 0.1, wrap = 0.3 })
frame:each(function(x, y)
  local i = fidx2[K(x, y)]
  if y <= 35 then
    if x == 28 or x == 36 then i = 1 end
    if x >= 29 and x <= 35 then i = i + 1 elseif (x < 28 and y % 2 == 0 and false) then i = i end
  else
    local row = floor((y - 36) / 5)
    if (y - 36) % 5 == 4 then i = 1
    else
      local jx = (x <= 25) and 24 or 39
      if x == jx and ((y - 36) % 5 == 0 or (y - 36) % 5 == 1) and row % 2 == 1 then i = 1 end
      i = i + (((row + (x <= 25 and 0 or 1)) % 2 == 0) and 0 or -1)
    end
  end
  c:put(x, y, S[A.clamp(i)])
end)
-- cracks + moss on stone
for _, p in ipairs{ { 23, 44 }, { 23, 45 }, { 24, 46 }, { 40, 40 }, { 39, 41 }, { 39, 42 } } do c:px(p[1], p[2], S[1]) end
frame:each(function(x, y)
  local h = H(x, y, 9)
  if (y == 31 and h > 0.3) or (h > 0.9) or ((y > 49) and h > 0.6) then c:px(x, y, M[h > 0.95 and 6 or (h > 0.75 and 5 or 4)]) end
end)
for _, d in ipairs{ { 24, 4 }, { 31, 3 }, { 39, 5 }, { 28, 2 } } do
  for k = 0, d[2] - 1 do c:px(d[1], 32 + k, M[k == d[2] - 1 and 2 or (k == 0 and 5 or 4)]) end
end
A.contact(c, frame, M[1], mm:copy():cut(frame):cut(opening))

-- plank door
local pl = { 5, 4, 3 }
opening:each(function(x, y)
  local col = (x - 26) % 3
  local i = pl[col + 1]
  local ph = floor((x - 26) / 3)
  if ph % 2 == 1 then i = i - 1 end
  if (x - 26) % 3 == 0 and (x ~= 26) then i = 1 end
  if y < 38 then i = i - 2 elseif y < 40 then i = i - 1 end
  if x == 26 or x == 37 then i = i - 1 end
  local h = H(x, floor(y / 3), 12)
  if h > 0.85 then i = i - 1 end
  c:put(x, y, W[A.clamp(i)])
end)
for _, y in ipairs{ 40, 49 } do
  for x = 26, 37 do c:px(x, y, I[x < 30 and 5 or 4]) c:px(x, y + 1, I[2]) end
  c:px(26, y, I[6]) c:px(37, y, I[3])
end
for k = 0, 8 do c:px(27 + k, 49 - k, I[3]) end
for k = 0, 8 do c:px(28 + k, 49 - k, I[2]) end
c:px(35, 45, I[5]) c:px(36, 45, I[4]) c:px(35, 46, I[3]) c:px(36, 46, I[2])   -- ring pull
c:px(27, 36, W[1]) for x = 26, 37 do c:px(x, 36, W[1]) end
-- step
local step = c:rect(23, 54, 40, 55)
A.lit(c, step, S, 1.2)
for x = 23, 40 do c:px(x, 55, S[3]) c:px(x, 54, S[5]) end

-- toadstools
local cap1 = A.toad(c, 12, 48, 3.6, 5)
A.contact(c, cap1, M[1], mm)
local cap2 = A.toad(c, 52, 49, 3, 4)
A.contact(c, cap2, M[1], mm)
c:px(49, 53, M[4]) c:px(50, 52, M[3]) c:px(55, 53, M[4])   -- grass blades at the stems

-- snail on the crown
local sh = c:ellipse(33.5, 9.5, 3.4, 3.4)
local sn = X.sphere(33, 9, 3.4, sh)
A.shade(c, sh, sn, Y, { amb = 0.1, wrap = 0.3 })
for _, p in ipairs{ { 33, 9 }, { 34, 9 }, { 34, 8 }, { 33, 7 }, { 32, 7 }, { 31, 8 }, { 31, 9 }, { 32, 11 }, { 33, 11 }, { 34, 11 }, { 35, 10 } } do
  if sh:has(p[1], p[2]) then c:px(p[1], p[2], Y[2]) end
end
c:px(31, 7, Y[6]) c:px(32, 6, Y[6])
for x = 30, 38 do c:px(x, 12, CR[x > 34 and 5 or 4]) end
for x = 29, 38 do c:px(x, 13, CR[x < 31 and 2 or 3]) end
for x = 37, 40 do for yy = 11, 12 do c:px(x, yy, CR[5]) end end
c:px(40, 13, CR[3]) c:px(39, 13, CR[3])
c:px(38, 10, CR[4]) c:px(38, 9, CR[4]) c:px(38, 8, A.INK)
c:px(40, 10, CR[4]) c:px(40, 9, CR[3]) c:px(41, 8, A.INK) c:px(40, 8, CR[3])
c:px(29, 13, CR[1])

A.fin(c, "root_cellar-mossy")
