-- garden-pond (final, Opus single pass). Small oval garden pond seen in 3/4: a ring of individually lit
-- cobbles (bevel per stone, dark mortar seams, a front face one tone down), deep-to-shallow water bands with
-- sky-glint streaks and a dark rim shadow under the far stones, a notched lily pad with radial veins and a pink
-- water-lily, and two slim reeds with a cattail rising from behind the left stones.
-- quirk: a goldfish tail flicks out of the water, ringed by a ripple.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_3.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local floor, max, min, abs, sqrt, atan, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.atan, math.pi
local c = A.new("garden-pond")
local ST, W, L = R.stone, R.water, R.leaf

local CX, CY = 32, 40
c:groundShadow(CX, 53, 25, 2)

-- reeds behind the rim (left)
local tokR = { r = { name = "reed" } }
A.leaf(c, 13, 40, 11, 28, 15, 15, 1.4, L, { tok = tokR, vs = 9 })
A.leaf(c, 16, 40, 18, 30, 23, 21, 1.2, L, { tok = tokR, vs = 9 })
A.stem(c, { { 14, 40 }, { 14, 30 }, { 15, 22 }, { 16, 13 } }, function(t) return 0.6 end, R.wood, { tok = tokR })
-- cattail head
local cat = c:rrect(15, 12, 17, 19, 1)
A.shade(c, cat, A.vcyl(cat, 15, 17, 1, 0.3), R.bark, { tok = tokR, amb = 0.15, wrap = 0.35 })
c:put(15, 13, R.bark[6], tokR) c:put(16, 10, R.wood[4], tokR) c:put(16, 11, R.wood[3], tokR)

-- stone rim: top ring + front face
local outer = A.ell(CX, CY, 25, 11)
local inner = A.ell(CX, CY - 0.5, 19.5, 7)
local face = A.ell(CX, CY + 3, 25, 11):cut(outer)
local ring = outer:copy():cut(inner)
local rim = ring:copy():add(face)
local tokS = { r = { name = "stone" } }
-- stones by angle; seams between them
local NS = 16
local function sid(x, y)
  local a = atan(y - CY, (x - CX) * 11 / 25)
  return floor(((a + pi) / (2 * pi) * NS) + 0.5 + (y > CY and 0.35 or 0)) % NS
end
local stones = {}
rim:each(function(x, y) local s = sid(x, y) stones[s] = stones[s] or HP.mask() stones[s]:set(x, y) end)
for s, m in pairs(stones) do
  -- shrink each stone a hair so seams show
  local seam = HP.mask()
  m:each(function(x, y)
    for _, d in ipairs{ { 1, 0 }, { 0, 1 } } do
      if rim:has(x + d[1], y + d[2]) and sid(x + d[1], y + d[2]) ~= s then seam:set(x, y) end
    end
  end)
  local n = X.pillow(m, 2.2)
  local bias = {}
  m:each(function(x, y) if face:has(x, y) then bias[K(x, y)] = -1 end end)
  local idx = A.shade(c, m, n, ST, { amb = 0.12, wrap = 0.3, bias = bias, tok = tokS })
  seam:each(function(x, y) c:put(x, y, ST[1], tokS) end)
  -- speckle / pitting
  m:each(function(x, y) local k = K(x, y)
    if not seam:has(x, y) and X.hash(x, y, s) < 0.07 and (idx[k] or 1) > 2 then c:put(x, y, ST[idx[k] - 1], tokS) end end)
end
-- face/top break line: lip highlight on the front top edge, moss tuft on a stone
face:each(function(x, y) if outer:has(x, y - 1) and X.hash(x, y, 2) > 0.3 then c:put(x, y, ST[2], tokS) end end)
A.map(c, { ".mM.", "mMmm" }, 46, 47, { m = L[4], M = L[5] }, tokS)

-- water: hard bands, darker under the far rim, lighter toward the near rim
local tokW = { r = { name = "water" } }
local water = inner:copy()
water:each(function(x, y)
  local d = y - (CY - 7.5)
  local i = d < 1.5 and 1 or (d < 3.5 and 2 or (d < 7.5 and 3 or (d < 11 and 4 or 4)))
  c:put(x, y, W[i], tokW)
end)
-- under-rim shadow on the left inner edge, lit shallow edge on the right front
water:edge():each(function(x, y)
  if y < CY and x < CX then c:put(x, y, W[1], tokW) elseif y > CY + 2 and x > CX + 4 then c:put(x, y, W[5], tokW) end end)
-- sky glint streaks
for _, s in ipairs{ { 22, 38, 5 }, { 25, 40, 3 }, { 36, 43, 6 }, { 30, 45, 3 } } do
  for x = s[1], s[1] + s[3] - 1 do if water:has(x, s[2]) then c:put(x, s[2], (x == s[1]) and W[6] or W[5], tokW) end end
end

-- lily pad (notched) with radial veins + water-lily
local tokP = { r = { name = "pad" } }
local pad = A.ell(22, 42, 5, 2.6)
pad:cut(c:poly{ { 22, 42 }, { 28, 40 }, { 28, 42.5 } })
local pn = X.pillow(pad, 1.6)
local pidx = A.shade(c, pad, pn, L, { amb = 0.2, wrap = 0.3, tok = tokP })
for _, v in ipairs{ { -4, 0 }, { -2, -2 }, { 2, 2 }, { -3, 2 }, { 0, -2 } } do
  for t = 1, 3 do local x, y = floor(22 + v[1] * t / 3 + .5), floor(42 + v[2] * t / 3 + .5)
    if pad:has(x, y) then c:put(x, y, L[max(1, (pidx[K(x, y)] or 3) - 1)], tokP) end end
end
for x = 18, 26 do if pad:has(x, 45) or pad:has(x, 44) then
  local y = pad:has(x, 45) and 45 or 44 if not pad:has(x, y + 1) then c:put(x, y + 1, W[1], tokW) end end end
local tokF = { r = { name = "flower" } }
A.map(c, {
  "..p.p..",
  ".pPhPp.",
  "pPhyhPp",
  ".dPPPd.",
}, 18, 37, { p = R.petal[4], P = R.petal[5], h = R.petal[6], y = "#ffd85a", d = R.petal[2] }, tokF)

-- quirk: goldfish tail flicking out of the water + ripple ring
local tokG = { r = { name = "fish" } }
for _, p in ipairs{ { 36, 40 }, { 37, 40 }, { 41, 40 }, { 42, 40 }, { 35, 41 }, { 43, 41 }, { 36, 42 }, { 42, 42 }, { 37, 43 }, { 38, 43 }, { 40, 43 }, { 41, 43 } } do
  if water:has(p[1], p[2]) then c:put(p[1], p[2], W[5], tokW) end end
A.map(c, {
  "Oo...oO",
  ".OHoHO.",
  "..oHo..",
  "...d...",
}, 36, 35, { O = "#e8493b", o = "#ff8a3a", H = "#ffc874", d = "#b52e3f" }, tokG)
c:put(38, 41, W[1], tokW) c:put(39, 41, W[1], tokW) c:put(40, 41, W[1], tokW)
c:put(39, 39, "#ff8a3a", tokG) c:put(39, 40, "#e8493b", tokG)
c:put(37, 36, A.CREAM, tokG)

A.save(c, "garden-pond")
