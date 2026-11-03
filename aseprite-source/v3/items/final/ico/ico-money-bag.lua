-- ico-money-bag (final pass, Opus single pass). Bold icon: a plump-bottomed burlap coin sack, pinched at the neck by
-- a twisted gold cord, with a scalloped ruffle flaring above it. Sack: per-pixel pillow/sphere light (6-tone burlap,
-- cool-violet shade), diagonal weave texture, fold creases running out of the neck, dark AO rows above and below the
-- cord, dark open mouth between the ruffle peaks, cool bounce lower-right. Cord: 3 px, twisted strands, a dangling end
-- with a knot and frayed tip. Emblem: a stamped gold coin mark with a dark rim and a bright edge.
-- quirk: a moth-nibbled hole low on the right with a gold coin peeking out.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA7_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = A.new("ico-money-bag")
local SK = { "#3e2430", "#633a32", "#8e5a3a", "#b47e4c", "#d4a466", "#efcb8e" }
local GD = { "#6a3a1e", "#a8601e", "#d98d22", "#f5b82e", "#ffd862", "#fff0a8" }
local CX = 31.5
local btok, rtok, ctok, gtok = { r = { name = "sack" } }, { r = { name = "ruffle" } }, { r = { name = "cord" } }, { r = { name = "gold" } }

-- body profile
local function bhw(y)
  if y < 24 then return nil end
  if y <= 25 then return 5 end
  if y <= 38 then local t = (y - 25) / 13 return 5 + 9.5 * sin(t * pi / 2) end
  if y <= 46 then return 14.5 end
  local t = (y - 46) / 8.5
  if t > 1 then return nil end
  return 14.5 * sqrt(1 - t * t)
end
local body = HP.mask()
for y = 24, 55 do local w = bhw(y) if w then for x = floor(CX - w), floor(CX + w + 1) do if abs(x - CX) <= w then body:set(x, y) end end end end
-- ruffle: flares up from the neck, scalloped top
local ruf = HP.mask()
for y = 11, 23 do
  local t = (23 - y) / 10
  local w = 4.6 + 6.2 * min(1, t) ^ 0.8
  for x = floor(CX - w), floor(CX + w + 1) do
    if abs(x - CX) <= w then
      local top = 12 + 2.4 * sin((x - CX) * 0.62) ^ 2
      if y >= top then ruf:set(x, y) end
    end
  end
end
local cord = c:rect(25, 21, 38, 24)

-- sack body: lit, AO under the cord, weave, creases
local bias = {}
X.ao(bias, body, cord, 2, -1)
local n = A.body(body, CX - 1, 40, 15, 6, 0.55)
local idx = A.shade(c, body, n, SK, { bias = bias, tok = btok, amb = 0.12, wrap = 0.34 })
body:each(function(x, y)
  local i = idx[K(x, y)]
  if x % 2 == 0 and y % 2 == 0 and ((x + y) // 2) % 2 == 0 and i >= 4 then A.step(c, idx, SK, x, y, -1, btok) end
end)
-- creases fanning from the neck
local creases = { { 27, 26, 21, 36 }, { 36, 26, 41, 35 }, { 31, 27, 30, 33 } }
for _, cr in ipairs(creases) do
  for s = 0, 12 do local t = s / 12
    local x, y = floor(cr[1] + (cr[3] - cr[1]) * t + .5), floor(cr[2] + (cr[4] - cr[2]) * t + .5)
    if body:has(x, y) then A.step(c, idx, SK, x, y, -1, btok)
      if t < 0.6 and body:has(x - 1, y) then A.step(c, idx, SK, x - 1, y, 1, btok) end end
  end
end
-- cool bounce lower-right rim
local rim = X.rim(n)
body:edge():each(function(x, y) if rim[K(x, y)] > 0.75 and y > 36 then c:put(x, y, "#6a4a66", btok) end end)

-- ruffle: lit, mouth darkness between peaks, folds
local nr = X.pillow(ruf, 3)
local rbias = {}
X.ao(rbias, ruf, cord, 2, -1)
local ridx = A.shade(c, ruf, nr, SK, { bias = rbias, tok = rtok, amb = 0.1, wrap = 0.3 })
ruf:each(function(x, y)
  local top = 12 + 2.4 * sin((x - CX) * 0.62) ^ 2
  if y <= top + 0.6 and abs(sin((x - CX) * 0.62)) > 0.9 then A.step(c, ridx, SK, x, y, -2, rtok) end
  if abs(sin((x - CX) * 0.62)) < 0.18 and y > top + 2 then A.step(c, ridx, SK, x, y, 1, rtok) end
  if abs(sin((x - CX) * 0.62 - 0.9)) < 0.15 and y > top + 2 then A.step(c, ridx, SK, x, y, -1, rtok) end
end)

-- twisted cord
local cv = {}
cord:each(function(x, y) local t = (y - 21) / 3 cv[K(x, y)] = { 0, (t - 0.5) * 1.6, 1 } end)
for k, nn in pairs(cv) do cv[k] = { A.norm(nn[1], nn[2], nn[3]) } end
local cidx = A.shade(c, cord, cv, GD, { tok = ctok, amb = 0.2, wrap = 0.3 })
cord:each(function(x, y) if (x + y) % 3 == 0 then A.step(c, cidx, GD, x, y, -2, ctok) end end)
c:put(25, 21, GD[3], ctok) c:put(38, 24, GD[2], ctok)
-- dangling end + knot + frayed tip
local dm, _, _, _, didx = A.stem(c, { { 37, 23 }, { 40, 25 }, { 41, 28 }, { 40, 31 } }, function(t) return 1.2 end, GD, { tok = ctok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
dm:each(function(x, y) if (x + y) % 3 == 0 then A.step(c, didx, GD, x, y, -2, ctok) end end)
for _, p in ipairs{ { 39, 32 }, { 41, 32 }, { 40, 33 } } do c:put(p[1], p[2], GD[3], ctok) end
c:put(37, 22, GD[2], ctok) c:put(38, 22, GD[1], ctok)

-- emblem: stamped coin (ring + inner mark)
local EX, EY = 30.5, 41
body:each(function(x, y)
  local d = sqrt((x - EX)^2 + (y - EY)^2)
  if d <= 5.2 then
    local col
    if d > 4.3 then col = GD[1]
    elseif d > 3.4 then col = (x + y < EX + EY) and GD[6] or GD[3]
    else col = (x - EX) + (y - EY) < -1 and GD[5] or GD[4] end
    c:put(x, y, col, gtok)
  end
end)
-- inner star mark
A.map(c, {
  "..s..",
  ".sss.",
  "s.s..",
  ".sss.",
  "..s.s",
  ".sss.",
  "..s..",
}, 29, 38, { s = GD[2] }, gtok)
c:put(27, 38, A.CREAM, gtok)

-- quirk: nibbled hole with a coin peeking out
local HX, HY = 40, 47
local hole = A.rell(HX, HY, 1, 0, 3.2, 2.2)
hole:each(function(x, y) if body:has(x, y) then c:put(x, y, "#24141c", btok) end end)
for _, p in ipairs{ { HX - 2, HY - 3 }, { HX + 1, HY - 3 }, { HX - 4, HY - 1 } } do c:put(p[1], p[2], SK[6], btok) end
A.map(c, {
  ".hgg",
  "hggga",
  "ggga",
}, HX - 1, HY - 1, { h = GD[6], g = GD[4], a = GD[2] }, gtok)
c:put(HX, HY - 1, A.CREAM, gtok)
A.save(c, "ico-money-bag")
