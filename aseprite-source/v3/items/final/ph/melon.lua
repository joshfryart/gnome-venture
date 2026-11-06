-- melon (final pass, Opus, replaces Sonnet draft). A slightly tall muskmelon: per-pixel lit 6-tone green-gold rind
-- under a raised cream net (Voronoi cells mapped onto the sphere, so the net compresses at the limb), ten faint
-- sutures from stem to blossom end, cool reflected light lower-right, one specular. Short woody stem on a slim
-- vine crossbar, a lobed palmate leaf with radiating veins, and a coiled tendril. AO under the stem knot.
-- quirk: a neat wedge has been cut from the lower right, showing orange flesh, pale rind and a seed cavity.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local NAME = "melon"
local c = A.new(NAME)

local SKIN = { "#1f3a2e", "#2e5634", "#4a763a", "#6f9842", "#9cba54", "#c9d978" }
local NET  = { "#4f5236", "#7c7a4c", "#a8a266", "#cdc68a", "#e8e0ae", "#fbf3d2" }
local LEAF = { "#173b33", "#21563d", "#2f7444", "#47944b", "#6db457", "#a0d06e" }
local WOOD = { "#3e2a22", "#5e4030", "#866040", "#ac8656", "#cfae7a" }
local FLESH = { "#86351f", "#b55224", "#dc7630", "#f19745", "#fbb866", "#ffd896" }
local RIND, RIND2, COOL, SPEC = "#d6e6a6", "#a9c67e", "#6f9c94", "#fffbe6"

local cx, cy, rx, ry = 31, 38, 14, 15.5
local body = A.ell(cx, cy, rx, ry)

-- vine crossbar + stem (behind body top)
local vtok, wtok, ltok = { r = { name = "vine" } }, { r = { name = "wood" } }, { r = { name = "leaf" } }
local vm, vn = A.tube({ { 22, 17 }, { 27, 15 }, { 35, 16 }, { 41, 13 } }, function(t) return 1.0 end)
A.shade(c, vm, vn, { LEAF[2], LEAF[3], LEAF[4], LEAF[5], LEAF[6] }, { tok = vtok, cuts = { 0.25, 0.45, 0.65, 0.82 } })
local sm, sn, ST = A.tube({ { 31, 24 }, { 31, 21 }, { 31, 19 }, { 31, 16 } }, function(t) return 1.5 - 0.3 * t end)
local sidx = A.shade(c, sm, sn, WOOD, { tok = wtok, cuts = { 0.22, 0.42, 0.62, 0.82 } })
sm:each(function(x, y) if y == 20 or y == 18 then local k = K(x, y) c:put(x, y, WOOD[max(1, (sidx[k] or 3) - 1)], wtok) end end) -- grain rings
c:put(30, 16, WOOD[5], wtok)

-- tendril: coil off the left end of the vine
local tdr = { { 22, 17 }, { 20, 16 }, { 19, 14 }, { 19, 12 }, { 20, 11 }, { 22, 11 }, { 23, 12 }, { 23, 13 }, { 22, 14 }, { 21, 13 } }
for _, p in ipairs(tdr) do c:put(p[1], p[2], LEAF[5], vtok) end
c:put(19, 13, LEAF[4], vtok) c:put(23, 13, LEAF[3], vtok)

-- palmate leaf: scalloped lobes, radiating veins
local lm, ln, LT, LS, len = A.blade(40, 14, 47, 6, 55, 9, function(t)
  if t > 0.98 then return -1 end
  local w = 5.6 * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.7
  return max(0.6, w + 0.9 * cos(t * 3 * 2 * pi) - 0.5)
end, { fold = 0.35 })
lm:cut(vm)
local lidx = A.shade(c, lm, ln, LEAF, { tok = ltok, cuts = { 0.14, 0.3, 0.47, 0.64, 0.8 }, amb = 0.14, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if abs(s) < 0.14 and t < 0.9 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  for _, vt in ipairs{ 0.18, 0.5, 0.8 } do
    local d = (t - vt) * len - abs(s) * 3.2
    if d > -0.5 and d < 0.5 and abs(s) > 0.2 and abs(s) < 0.8 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
  end
end)

-- body: sphere normals, net, sutures
local n = A.ellN(cx, cy, rx, ry, body, 1.0)
local bias = {}
X.ao(bias, body, sm, 2, -1)
local CELL = 3.3
local function vor(u, v)
  local i0, j0 = floor(u / CELL), floor(v / CELL)
  local d1, d2 = 1e9, 1e9
  for j = j0 - 1, j0 + 1 do for i = i0 - 1, i0 + 1 do
    local px, py = (i + 0.15 + 0.7 * X.hash(i, j, 3)) * CELL, (j + 0.15 + 0.7 * X.hash(i, j, 9)) * CELL
    local d = sqrt((u - px)^2 + (v - py)^2)
    if d < d1 then d2 = d1 d1 = d elseif d < d2 then d2 = d end
  end end
  return d2 - d1
end
local btok = { r = { name = "rind" } }
local v = X.light(n, { amb = 0.06, wrap = 0.22 })
local isNet = {}
body:each(function(x, y) local k = K(x, y)
  local nn = n[k]
  local lon, lat = atan(nn[1], nn[3]), math.asin(max(-1, min(1, nn[2])))
  local u, w = lon * 15, lat * 16
  if vor(u + 40, w + 40) < 0.62 then isNet[k] = true end
  local su = (lon / (2 * pi / 10)) % 1
  if su < 0.07 or su > 0.93 then bias[k] = (bias[k] or 0) - 1 end
end)
local idx = {}
body:each(function(x, y) local k = K(x, y)
  local val = v[k]
  local i = 1
  for j, t in ipairs(A.CUTS) do if val >= t then i = j + 1 end end
  i = max(1, min(6, i + (bias[k] or 0)))
  idx[k] = i
  if isNet[k] then c:put(x, y, NET[max(1, min(6, i + (i >= 3 and 0 or 1)))], btok)
  else c:put(x, y, SKIN[i], btok) end
end)
-- reflected cool light on the lower-right limb
local r = X.rim(n)
body:edge():each(function(x, y) local k = K(x, y) if r[k] > 0.72 and not isNet[k] then c:put(x, y, COOL, btok) end end)
-- specular + bloom specks
local spx, spy = A.specAt(body, n, 60)
c:put(spx, spy, SPEC, btok) c:put(spx + 1, spy, NET[6], btok) c:put(spx, spy + 1, NET[5], btok)

-- quirk: wedge cut out of the lower right
local a1, a2 = 0.32, 1.02
local mid = (a1 + a2) / 2
local ftok = { r = { name = "flesh" } }
local wedge = HP.mask()
body:each(function(x, y)
  local dx, dy = x - (cx + 1), y - (cy + 1)
  local ang = atan(dy, dx)
  local rho = sqrt((dx / (rx + 0.45))^2 + (dy / (ry + 0.45))^2)
  if ang >= a1 and ang <= a2 and rho <= 1.0 and rho > 0.12 then
    wedge:set(x, y)
    local lit = ang > mid
    local col
    if rho > 0.94 then col = SKIN[lit and 3 or 2]
    elseif rho > 0.84 then col = lit and RIND or RIND2
    elseif rho > 0.4 then
      local i = lit and 5 or 3
      if rho > 0.72 then i = i - 1 end
      col = FLESH[i]
    else col = lit and FLESH[6] or FLESH[4] end
    if abs(ang - mid) < 0.05 and rho <= 0.94 then col = FLESH[2] end   -- crease where the faces meet
    c:put(x, y, col, ftok)
  end
end)
-- wedge rim: dark edge along the upper (shaded) cut
wedge:each(function(x, y)
  local dx, dy = x - (cx + 1), y - (cy + 1)
  local ang = atan(dy, dx)
  if ang < a1 + 0.07 then c:put(x, y, FLESH[1], ftok) end
end)
-- seeds in the cavity
for _, s in ipairs{ { 35, 41 }, { 34, 42 }, { 36, 42 } } do
  if wedge:has(s[1], s[2]) then c:put(s[1], s[2], NET[6], ftok) end
end
-- juice glint on the lit face
c:put(37, 45, FLESH[6], ftok) c:put(38, 45, "#fff0c8", ftok)

A.save(c, NAME)
