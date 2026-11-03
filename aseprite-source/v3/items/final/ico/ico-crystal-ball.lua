-- ico-crystal-ball (final, Opus). A seer's glass sphere resting in a brass cup with three claw prongs, on a turned
-- walnut base; a 2-tone ground shadow under it (it stands).
-- Material: glass = pale core, darker body toward the edge, bright 1 px rim on the upper-left, deep rim lower-right,
-- a focused caustic glow inside the lower-right (light passing through), a soft window specular + cream glint, a
-- swirl of violet mist; brass = per-pixel cylinder light, bright top lip, AO under the ball; walnut = 6 tones,
-- horizontal grain lines and a lit bevel along the top edge.
-- quirk: a tiny crescent moon floats in the mist, as if the ball is showing tonight's sky.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi, atan = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi, math.atan
local c = A.new("ico-crystal-ball")
local GL   = { "#221c56", "#33378a", "#4656b4", "#6380d4", "#93b2ec", "#cce6ff" }
local MIST = { "#7a5cc0", "#a888e0", "#d2bdf4" }
local BR   = { "#5a2c1e", "#924d1f", "#c77c22", "#eeac2e", "#ffd457", "#fff0a6" }
local WD   = { "#2c1820", "#4a2a26", "#6c3e2c", "#8f5a38", "#b47c4c", "#d8a46a" }
local CREAM = "#fff4d6"
local tG, tM, tB, tW = A.tok("glass"), A.tok("mist"), A.tok("brass"), A.tok("wood")

local CX, CY, R = 31.5, 24.5, 16
c:groundShadow(31.5, 52, 15, 2)

-- walnut base: a turned, rounded trapezoid with a moulded lip
local base = c:poly{ { 18, 44 }, { 45, 44 }, { 49, 50 }, { 14, 50 } }
base:add(c:rrect(13, 48, 50, 52, 1))
local bn = X.pillow(base, 2.4)
local bb = {}
base:each(function(x, y) if y == 47 then bb[K(x, y)] = -1 end end)   -- groove between the cone and the foot
local bidx = A.shade(c, base, bn, WD, { bias = bb, tok = tW, amb = 0.08, wrap = 0.25, tilt = { 31.5, 48, 18, 0.2 }, cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 } })
-- grain: wavy horizontal dark lines, broken
base:each(function(x, y)
  local w = y + 0.6 * sin(x * 0.45 + y)
  if (abs(w - 45.6) < 0.35 or abs(w - 50.2) < 0.35) and X.hash(x, y, 3) > 0.25 then A.step(c, bidx, WD, x, y, -1, tW) end
end)
-- lit bevel on the foot's top edge
for x = 14, 32 do if base:has(x, 48) and not base:has(x, 47) then c:put(x, 48, WD[6], tW) end end

-- brass cup: shallow bowl that the ball sits in
local cup = A.ell(CX, 41.5, 10.5, 3.2)
cup:add(c:rect(20, 41, 43, 43))
local cupIn = HP.mask()
-- three claw prongs curling up onto the ball
local prongs = {}
for _, p in ipairs{ { 17, 36, 21, 42 }, { 46, 36, 42, 42 } } do
  local m = A.capsule(p[1], p[2], p[3], p[4], 1.5)
  prongs[#prongs + 1] = m cup:add(m)
end
-- ball (masks)
local ball = A.ell(CX, CY, R, R)
cup:cut(ball)
local cn = {}
cup:each(function(x, y)
  local q = max(-0.95, min(0.95, (x - CX) / 12))
  cn[K(x, y)] = { A.norm(q, -0.25 + (y - 41) * 0.12, sqrt(1 - q * q)) }
end)
local cb = {}
X.ao(cb, cup, ball, 1, -1)
local cidx = A.shade(c, cup, cn, BR, { bias = cb, tok = tB, amb = 0.08, wrap = 0.25, cuts = { 0.22, 0.38, 0.54, 0.72, 0.88 } })
-- underside row of the cup is deep where it meets the wood
cup:each(function(x, y) if base:has(x, y + 1) and not cup:has(x, y + 1) then A.step(c, cidx, BR, x, y, -1, tB) end end)
-- AO on the wood under the cup
base:each(function(x, y) if cup:has(x, y - 1) then A.step(c, bidx, WD, x, y, -1, tW) end end)

-- glass sphere
local ang0 = atan(1, 1)   -- lower-right direction
local gidx = {}
ball:each(function(x, y)
  local dx, dy = (x - CX) / (R + 0.5), (y - CY) / (R + 0.5)
  local r = sqrt(dx * dx + dy * dy)
  local a = atan(dy, dx)
  local v = 0.42 + 0.28 * (1 - r)                         -- pale core
  local lr = cos(a - ang0)                                -- +1 toward lower-right
  if r > 0.45 and r < 0.9 then v = v + 0.34 * max(0, lr) ^ 2 * min(1, (r - 0.45) / 0.25) end   -- caustic
  if r > 0.78 then v = v - 0.18 * (r - 0.78) / 0.22 end   -- body darkens to the edge
  if r > 0.55 and lr < -0.2 then v = v - 0.08 end          -- upper-left inner body (light passes away)
  local i = 1
  for j, t in ipairs{ 0.2, 0.34, 0.47, 0.6, 0.76 } do if v >= t then i = j + 1 end end
  gidx[K(x, y)] = i
  c:put(x, y, GL[i], tG)
end)
-- rims: bright 1 px upper-left arc, deep lower-right arc
ball:edge():each(function(x, y)
  local a = atan(y - CY, x - CX)
  local lr = cos(a - ang0)
  if lr < -0.35 then c:put(x, y, GL[5], tG) gidx[K(x, y)] = 5
  elseif lr > 0.4 then c:put(x, y, GL[1], tG) gidx[K(x, y)] = 1 end
end)
-- contact shade where the ball sits in the cup
ball:each(function(x, y) if cup:has(x, y + 1) or cup:has(x, y + 2) then A.step(c, gidx, GL, x, y, -1, tG) end end)

-- mist: two swirling strands (2 px), lit upper edge
local function strand(pts, w)
  local m = c:line(pts, w)
  m:clip(ball:shrink(2))
  m:each(function(x, y)
    local lit = not m:has(x, y - 1)
    local low = not m:has(x, y + 1)
    c:put(x, y, lit and MIST[3] or (low and MIST[1] or MIST[2]), tM)
  end)
  return m
end
do -- one flattened spiral of mist curling out from the centre
  local pts = {}
  for i = 0, 40 do
    local th = pi * 0.6 + i / 40 * pi * 2.3
    local r = 3 + 4.6 * (i / 40) * 2.3
    pts[#pts + 1] = { floor(CX + 1 + r * cos(th) + 0.5), floor(CY + 4 + 0.5 * r * sin(th) + 0.5) }
  end
  strand(pts, 2)
end

-- quirk: crescent moon in the mist (opens to the right)
A.map(c, { "..CC", ".CC.", ".Cc.", ".Cc.", ".CC.", "..CC" }, 34, 13,
  { C = CREAM, c = "#f5d78a" }, tM)

-- window specular (glass): soft 3x3 block + cream glint, upper-left
for _, p in ipairs{ { 21, 15 }, { 22, 15 }, { 20, 16 }, { 21, 16 }, { 20, 17 } } do c:put(p[1], p[2], GL[6], tG) end
c:put(22, 14, CREAM, tG) c:put(23, 14, CREAM, tG)
c:put(19, 19, GL[6], tG)

A.save(c, "ico-crystal-ball")
