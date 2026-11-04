-- broken-harvest-sack (aB11_4, Opus single pass). Standing burlap grain sack: gathered ruffle top, twisted twine
-- tie with a dangling end, a pear body that slumps wide at the base, two red stencil stripes around its belly.
-- Material: pillow light on the sack, diagonal burlap weave, fold creases from the neck (dark groove + lit lip),
-- twine twist, AO under the tie and along the base, 2-tone ground shadow.
-- broken: a ragged hole torn low on the right with frayed threads; grain spills out onto the ground and one grain
-- is mid-fall. quirk: a mouse tail curls out of the hole.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_4.lua")
local HP, X, c = A.new("broken-harvest-sack")
local K = A.K
local B, GD, EM = A.BURL, A.GOLD, A.EMBER
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt

c:groundShadow(33, 52, 17, 2)

-- body
local body = c:ellipse(32, 41, 13, 11)
body:add(c:poly{ { 27, 20 }, { 37, 20 }, { 45, 38 }, { 19, 38 } })
body:cut(c:rect(0, 52, 63, 63))
local bias = {}
local n = X.pillow(body, 7)
-- AO under the tie and along the base
body:each(function(x, y) local k = K(x, y)
  if y <= 21 then bias[k] = -1 end
  if y >= 51 then bias[k] = (bias[k] or 0) - 1 end
end)
local bi = A.shade(c, body, n, B, { bias = bias, amb = 0.1, cuts = { 0.2, 0.36, 0.52, 0.68, 0.85 } })
-- burlap weave: diagonal crossing threads on the mid tones
body:each(function(x, y) local k = K(x, y)
  local i = bi[k]
  if i >= 2 and i <= 5 then
    if (x + 2 * y) % 5 == 0 then A.bump(c, bi, B, x, y, -1)
    elseif (2 * x - y) % 7 == 0 and i <= 4 then A.bump(c, bi, B, x, y, 1) end
  end
end)
-- fold creases from the neck
local function crease(pts)
  for _, p in ipairs(pts) do
    if body:has(p[1], p[2]) then A.bump(c, bi, B, p[1], p[2], -2) end
    if body:has(p[1] - 1, p[2]) then A.bump(c, bi, B, p[1] - 1, p[2], 1) end
  end
end
crease{ { 28, 22 }, { 28, 23 }, { 27, 24 }, { 27, 25 }, { 26, 26 }, { 26, 27 }, { 25, 28 } }
crease{ { 33, 22 }, { 33, 23 }, { 34, 24 }, { 34, 25 }, { 34, 26 } }
crease{ { 36, 22 }, { 37, 23 }, { 37, 24 }, { 38, 25 }, { 39, 26 }, { 39, 27 }, { 40, 28 } }
crease{ { 21, 47 }, { 22, 48 }, { 23, 49 } }
-- red stencil stripes around the belly (curve down in the middle)
for x = 18, 46 do
  local u = (x - 32) / 14
  local yc = floor(33 + 2.2 * (1 - u * u) + 0.5)
  for _, dy in ipairs{ 0, 2 } do
    local y = yc + dy
    if body:has(x, y) then
      local i = bi[K(x, y)]
      c:put(x, y, EM[A.clampI(i + (i >= 5 and 0 or 1))])
    end
  end
end

-- gathered ruffle top
local ruf = c:poly{ { 26, 18 }, { 22, 12 }, { 25, 12 }, { 25, 8 }, { 29, 10 }, { 31, 6 }, { 33, 9 }, { 36, 7 },
  { 37, 10 }, { 41, 8 }, { 40, 12 }, { 43, 13 }, { 38, 18 } }
local rn = X.pillow(ruf, 2)
local ri = A.shade(c, ruf, rn, B, { amb = 0.12 })
for _, f in ipairs{ { 25, 13, 4 }, { 29, 11, 6 }, { 33, 10, 7 }, { 37, 11, 6 }, { 40, 13, 4 } } do  -- pleats
  for d = 0, f[3] - 1 do
    local x, y = f[1] + (d >= 3 and (f[1] < 32 and 1 or (f[1] > 32 and -1 or 0)) or 0), f[2] + d
    if ruf:has(x, y) then A.bump(c, ri, B, x, y, -2) if ruf:has(x - 1, y) then A.bump(c, ri, B, x - 1, y, 1) end end
  end
end
for x = 27, 37 do if ruf:has(x, 17) then A.bump(c, ri, B, x, 17, -1) end end

-- twine tie: twisted rope band
local tie = c:rrect(26, 17, 38, 20, 1)
tie:each(function(x, y)
  local ph = (x + y) % 3
  local i = (ph == 0 and 3) or (ph == 1 and 4) or 5
  if x >= 36 then i = i - 1 end
  if y == 20 then i = i - 1 end
  c:put(x, y, GD[A.clampI(i)])
end)
c:put(28, 17, GD[6]) c:put(29, 17, GD[6])
-- knot + dangling end
c:put(39, 19, GD[4]) c:put(40, 19, GD[3]) c:put(39, 20, GD[3])
for _, p in ipairs{ { 40, 21, 4 }, { 41, 22, 5 }, { 41, 23, 4 }, { 42, 24, 3 }, { 42, 25, 4 }, { 41, 26, 3 } } do c:put(p[1], p[2], GD[p[3]]) end
c:put(41, 27, GD[5]) c:put(42, 27, GD[4])  -- frayed tip

-- damage: ragged hole low on the right
local hole = c:poly{ { 37, 41 }, { 40, 40 }, { 43, 42 }, { 43, 45 }, { 41, 47 }, { 38, 46 }, { 36, 44 } }
hole:each(function(x, y) c:put(x, y, y <= 42 and "#2e1b1f" or "#3d2622") end)
-- grain visible in the bottom of the hole
for _, p in ipairs{ { 38, 45, 4 }, { 39, 45, 5 }, { 40, 46, 4 }, { 41, 45, 3 }, { 42, 44, 4 }, { 39, 44, 3 } } do
  c:put(p[1], p[2], GD[p[3]]) end
-- frayed rim: pale broken threads poking into the hole, dark lip below
hole:grow(1):cut(hole):each(function(x, y)
  if body:has(x, y) then
    if y < 43 then c:put(x, y, B[6]) else c:put(x, y, B[2]) end
  end end)
c:put(38, 41, B[6]) c:put(41, 41, B[5]) c:put(43, 43, B[6]) c:put(37, 45, B[5])
-- spilled grain on the ground + one mid-fall
local function grain(x, y, lit)
  c:put(x, y, lit and GD[6] or GD[5]) c:put(x + 1, y, GD[4]) c:put(x + 1, y + 1, GD[3]) c:put(x, y + 1, GD[4])
end
grain(46, 47, true)
grain(45, 51) grain(48, 51, true) grain(51, 52) grain(47, 53) grain(50, 54)
c:put(53, 50, GD[5])

-- quirk: a mouse tail curling out of the hole
local tail = { { 43, 44, 1 }, { 44, 44, 2 }, { 45, 43, 2 }, { 46, 42, 1 }, { 47, 41, 2 }, { 47, 40, 1 }, { 46, 39, 2 } }
local TP = { "#e89aa4", "#c56f7f" }
for _, p in ipairs(tail) do c:put(p[1], p[2], TP[p[3]]) end
A.fin(c)
