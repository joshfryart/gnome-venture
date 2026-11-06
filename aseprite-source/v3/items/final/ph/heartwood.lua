-- heartwood (final, Opus aC11_3). A short sawn log lying on the diagonal, cut face toward the viewer. Body: per-pixel
-- cylinder light on fissured bark (6 tones, long ridges and cross checks, cool reflected light along the underside),
-- a small knot, AO where the bark meets the cut face. Cut face: dark bark rim, pale cream sapwood with fine rings,
-- deep red heartwood with darker growth rings, two radial drying checks, lit upper-left and bevelled lower-right.
-- quirk: the innermost growth rings form a little heart.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_3.lua")
local HP, X, K = A.HP, A.X, A.K
local max, min, floor, abs, sqrt, sin, cos = math.max, math.min, math.floor, math.abs, math.sqrt, math.sin, math.cos
local c = A.new("heartwood")
local BARK  = { "#2c1a1e", "#472a26", "#663c2e", "#875438", "#a8724a", "#c8945e" }
local SAP   = { "#a8743f", "#c69156", "#e0b378", "#f2d39a", "#fbe8bc" }
local HEART = { "#3e0f20", "#621a28", "#86262e", "#a83a36", "#c45a40", "#de7c4e" }
local COOL = "#6a4e6c"
local bt, ft = A.tok("bark"), A.tok("face")

local E, F = { 20, 41 }, { 45, 24 }
local L = sqrt((F[1] - E[1])^2 + (F[2] - E[2])^2)
local ux, uy = (F[1] - E[1]) / L, (F[2] - E[2]) / L
local px, py = -uy, ux
if px + py < 0 then px, py = -px, -py end
local R, MIN = 9.6, 6.2
local function loc(x, y, o) local dx, dy = x + .5 - o[1], y + .5 - o[2] return dx * ux + dy * uy, dx * px + dy * py end

-- body: cylinder E..F plus the far rounded end
local body = HP.mask()
for y = 0, 63 do for x = 0, 63 do
  local a, s = loc(x, y, E)
  if abs(s) <= R and a >= 0 and a <= L then body:set(x, y) end
  local a2, s2 = loc(x, y, F)
  if (s2 / (R + .3))^2 + (a2 / (MIN + .3))^2 <= 1 then body:set(x, y) end
end end
local face = HP.mask()
for y = 0, 63 do for x = 0, 63 do
  local a, s = loc(x, y, E)
  if (s / (R + .3))^2 + (a / (MIN + .3))^2 <= 1 then face:set(x, y) end
end end
body:cut(face)

-- bark normals + texture bias
local n, bias = {}, {}
body:each(function(x, y) local k = K(x, y)
  local a, s = loc(x, y, E)
  local q = max(-0.97, min(0.97, s / (R + .5)))
  n[k] = { px * q, py * q, sqrt(1 - q * q) }
  -- long fissures, slightly wavy, plus cross checks between bark plates
  local w = s + 0.8 * sin(a * 0.45 + s * 0.3)
  local f = (w / 2.7) % 1
  local b = 0
  if f < 0.3 then b = -1 elseif f > 0.62 and f < 0.8 and q < 0.3 then b = 1 end
  local plate = floor(w / 2.7)
  local chk = (a + X.hash(plate, 3, 5) * 9) % 8.5
  if chk < 0.9 and f >= 0.3 then b = -1 end
  if b ~= 0 then bias[k] = b end
end)
X.ao(bias, body, face, 2, -1)
A.shade(c, body, n, BARK, { amb = 0.1, wrap = 0.25, bias = bias, tok = bt })
-- cool reflected light along the underside edge
local rimL = X.rim(n)
body:edge():each(function(x, y) local k = K(x, y)
  local a, s = loc(x, y, E)
  if s > R - 1.2 and a > 2 and a < L - 1 and rimL[k] > 0.5 then c:put(x, y, COOL, bt) end end)
-- knot on the lit flank
local kx, ky = E[1] + ux * 19 - px * 4.5, E[2] + uy * 19 - py * 4.5
for y = floor(ky) - 3, floor(ky) + 3 do for x = floor(kx) - 3, floor(kx) + 3 do
  local dx, dy = x + .5 - kx, y + .5 - ky
  local aa, bb = dx * ux + dy * uy, dx * px + dy * py
  local q = (aa / 2.3)^2 + (bb / 1.5)^2
  if body:has(x, y) then
    if q <= 0.35 then c:put(x, y, SAP[2], bt)
    elseif q <= 1 then c:put(x, y, BARK[1], bt)
    elseif q <= 1.7 and bb < 0 then c:put(x, y, BARK[6], bt) end
  end
end end

-- cut face
local HX, HY = E[1] - 0.3, E[2] - 0.6
local function inHeart(x, y, s)
  local a, b = (x + .5 - HX) / s, -(y + .5 - HY) / s + 0.15
  return (a * a + b * b - 1)^3 - a * a * b * b * b <= 0
end
local checks = { { cos(-2.2), sin(-2.2) }, { cos(0.5), sin(0.5) } }
face:each(function(x, y)
  local a, s = loc(x, y, E)
  local rr = sqrt((s / (R + .3))^2 + (a / (MIN + .3))^2)
  local dxs, dys = x + .5 - E[1], y + .5 - E[2]
  local l = -(dxs + dys) / (R * 1.4)          -- >0 upper-left (lit), <0 lower-right
  local col
  if rr > 0.87 then
    col = l > 0.35 and BARK[5] or l > -0.2 and BARK[3] or BARK[2]
    if rr > 0.87 and rr < 0.95 and l < -0.4 then col = BARK[1] end
  elseif rr > 0.62 then
    local ring = ((rr - 0.62) / 0.085) % 1 < 0.3
    local i = l > 0.3 and 5 or l > -0.35 and 4 or 3
    if ring then i = i - 1 end
    if rr > 0.8 and l < -0.3 then i = i - 1 end   -- bevel lower-right
    col = SAP[max(1, i)]
  else
    local ring = (rr / 0.13) % 1 < 0.28
    local i = l > 0.25 and 5 or l > -0.3 and 4 or 3
    if ring then i = i - 2 end
    if rr > 0.57 then i = i - 1 end               -- heart/sap boundary
    col = HEART[max(1, i)]
  end
  -- radial drying checks
  for _, d in ipairs(checks) do
    local along = dxs * d[1] + dys * d[2]
    local across = abs(-dxs * d[2] + dys * d[1])
    if along > 1.5 and across < 0.55 and rr > 0.25 and rr < 0.72 then col = HEART[1] end
  end
  c:put(x, y, col, ft)
end)
-- heart core (quirk): dark heart ring, warm inside, pith dot
for y = floor(HY) - 5, floor(HY) + 5 do for x = floor(HX) - 5, floor(HX) + 5 do
  if inHeart(x, y, 3.3) then
    if inHeart(x, y, 2.2) then c:put(x, y, HEART[5], ft) else c:put(x, y, HEART[2], ft) end
  end
end end
c:put(floor(HX), floor(HY) + 1, HEART[2], ft)
c:put(floor(HX) - 2, floor(HY) - 1, HEART[6], ft)

A.save(c, "heartwood")
