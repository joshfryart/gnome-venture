-- broken-harvest-trug (aB11_4, Opus single pass). Shallow boat-shaped Sussex trug: four thin curved oak slats under a
-- pale bent rim, a slim arched handle with brass rivets, two block feet; inside, two carrots and a turnip.
-- Material: per-slat cylinder light following the hull curve, dark seam rows (AO) between slats, grain dashes,
-- pale end grain at the break, dark interior wall, ground shadow.
-- broken: the second slat is smashed through (dark gap with pale fractured ends), a splinter hangs from the gap and a
-- wood chip flies off to the lower right. quirk: a snail is out for a slow walk along the rim.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_4.lua")
local HP, X, c = A.new("broken-harvest-trug")
local K = A.K
local O, AS = A.OAK, A.ASH
local floor, max, min, abs, sqrt, sin = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin
local CX, HW = 32, 23

c:groundShadow(32, 48, 18, 2)

-- handle (behind everything)
local hm, hn, hT, hS, hidx = A.tube(c, { { 14, 31 }, { 14.5, 0 }, { 49.5, 0 }, { 50, 31 } }, function() return 1.55 end, AS, { amb = 0.12 })
hm:each(function(x, y) local k = K(x, y)
  if hS[k] < -0.4 and hT[k] > 0.3 and hT[k] < 0.55 then c:put(x, y, AS[6]) end
  if abs(hS[k] - 0.25) < 0.12 and (floor(hT[k] * 40) % 4 ~= 0) then A.bump(c, hidx, AS, x, y, -1) end  -- grain
end)

local function yr(x) local u = (x - CX) / HW return 30 - 4.5 * u ^ 4 end                    -- front rim top
local function yb(x) local u = (x - CX) / (HW + 0.5) return 30 + 15 * max(0, 1 - u * u) ^ 0.62 end -- hull bottom
local function yk(x) local u = (x - CX) / (HW - 1) return 30 - 5.5 * sqrt(max(0, 1 - u * u)) end  -- back rim

-- feet
for _, fx in ipairs{ 20, 41 } do
  local f = c:rect(fx, 42, fx + 4, 47)
  local fi = A.shade(c, f, A.vcylN(f, fx, fx + 4), O)
  for x = fx, fx + 4 do A.bump(c, fi, O, x, 47, -1) end
end

-- interior (back rim band + dark inner wall)
local inner, back = HP.mask(), HP.mask()
for x = CX - HW + 1, CX + HW - 1 do
  local t0, t1 = floor(yk(x) + 0.5), floor(yr(x) + 0.5)
  for y = t0, t1 do
    if y <= t0 + 1 then back:set(x, y) else inner:set(x, y) end
  end
end
back:each(function(x, y) c:put(x, y, (y == floor(yk(x) + 0.5)) and O[5] or O[4]) end)
inner:each(function(x, y)
  local d = y - floor(yk(x) + 0.5)
  c:put(x, y, d <= 2 and O[2] or O[1])
end)

-- contents: two carrots + a turnip
local function frond(ax, ay, bx, by, w) A.G.leaf(c, ax, ay, bx, by, w, A.MOSS, { 3 }) end
frond(23, 25, 18, 16, 1.6) frond(24, 25, 26, 15, 1.4)
frond(40, 25, 38, 16, 1.4) frond(41, 25, 46, 18, 1.6)
local tm = c:ellipse(32, 23, 5, 5)
local tn = X.sphere(31, 22, 5, tm)
local ti = A.shade(c, tm, tn, A.PURP, { amb = 0.1 })
tm:each(function(x, y) if y >= 25 then c:put(x, y, ti[K(x, y)] >= 4 and "#fff0e6" or "#e6cfd8") end end)
c:put(29, 20, A.CREAM) c:put(30, 20, A.PURP[6])
for _, p in ipairs{ { 32, 17 }, { 32, 16 }, { 33, 15 }, { 31, 15 } } do c:put(p[1], p[2], A.MOSS[4]) end
c:put(32, 18, A.MOSS[2])
for _, cc in ipairs{ { 23, 27 }, { 41, 27 } } do
  local m = c:ellipse(cc[1], cc[2], 3, 3)
  local n = X.sphere(cc[1] - 0.5, cc[2] - 0.5, 3, m)
  A.shade(c, m, n, A.ORNG, { amb = 0.1 })
  c:put(cc[1] - 1, cc[2] - 2, A.ORNG[6])
  c:put(cc[1], cc[2] - 3, A.MOSS[2])
  for x = cc[1] - 2, cc[1] + 2 do c:put(x, cc[2] - 1 + 1, A.ORNG[(x + cc[1]) % 2 == 0 and 2 or 3]) end -- growth ring
end

-- front hull: four slats under a rim, each lit as a little cylinder bent with the hull
local hull, slat, sv = HP.mask(), {}, {}
local NS = 4
for x = CX - HW, CX + HW do
  local t0, t1 = floor(yr(x) + 0.5), floor(yb(x) + 0.5)
  for y = t0, t1 do
    hull:set(x, y)
    local k = K(x, y)
    if y <= t0 + 2 then slat[k] = 0 sv[k] = (y - t0) / 2
    else
      local f = (y - t0 - 3) / max(1, (t1 - t0 - 2))
      local s = min(NS, floor(f * NS) + 1)
      slat[k] = s sv[k] = f * NS - (s - 1)
    end
  end
end
local hn2, bias = {}, {}
hull:each(function(x, y) local k = K(x, y)
  local u = (x - CX) / HW
  local ny = (sv[k] - 0.5) * 1.5 + (slat[k] or 0) * 0.08
  local nx = u * 0.85
  local l = sqrt(nx * nx + ny * ny + 1)
  hn2[k] = { nx / l, ny / l, 1 / l }
  -- seam row (first row of a slat) = ambient dark
  if slat[k] >= 1 and not (slat[k - 1024] == slat[k]) and hull:has(x, y - 1) then bias[k] = -2 end
end)
local RIM = { O[2], O[3], O[4], O[5], O[6], "#fbe3b0" }
local hidx2 = A.shade(c, hull, hn2, O, { bias = bias, amb = 0.1 })
hull:each(function(x, y) local k = K(x, y)
  if slat[k] == 0 then c:put(x, y, RIM[hidx2[k]]) end
  -- grain dashes along the slats
  if slat[k] >= 1 and abs(sv[k] - 0.55) < 0.14 and X.hash(floor(x / 3), slat[k], 7) > 0.45 then A.bump(c, hidx2, O, x, y, -1) end
end)
-- rivets (handle ends) + rim nails: dark eye + bright lip
for _, nx in ipairs{ 14, 50, 22, 42 } do
  local ny = floor(yr(nx) + 0.5) + 1
  c:put(nx, ny, (nx == 14 or nx == 50) and A.BRASS[3] or O[1])
  c:put(nx - 1, ny - 1, (nx == 14 or nx == 50) and A.BRASS[6] or RIM[6])
end
c:put(18, 30, "#fff1cf") c:put(19, 30, RIM[6])

-- damage: slat 2 smashed through
local gap = c:poly{ { 29, 36 }, { 33, 35 }, { 36, 37 }, { 35, 40 }, { 32, 39 }, { 30, 40 } }
gap:clip(hull)
gap:each(function(x, y) c:put(x, y, y <= 37 and "#2a1520" or "#3b1f24") end)
gap:grow(1):cut(gap):each(function(x, y)
  if hull:has(x, y) then local k = K(x, y)
    if x <= 30 or x >= 35 then c:put(x, y, "#f6d49a") end end end)    -- pale end grain at the breaks
-- hanging splinter from the left break
for _, p in ipairs{ { 30, 41, 5 }, { 31, 42, 4 }, { 31, 43, 5 }, { 32, 44, 3 } } do c:put(p[1], p[2], O[p[3]]) end
-- chip flying off
c:put(57, 40, O[5]) c:put(58, 40, O[4]) c:put(58, 41, O[2])
c:put(55, 36, O[5])

-- quirk: a snail walking the rim (right end)
A.map(c, {
  "..sss..",
  ".sShss.",
  ".sSHSs.",
  "bbsssbbe",
}, 44, 25, { s = "#c94f84", S = "#f5809f", h = "#ffc4d8", H = "#7d2c5e", b = "#d8c79a", e = "#8a7458" })
c:put(51, 24, "#8a7458")
A.fin(c)
