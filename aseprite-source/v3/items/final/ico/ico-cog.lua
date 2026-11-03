-- ico-cog (final, Opus). Spoked steel gear seen face on: eight squared teeth with chamfered tips on a bevelled rim,
-- four slim spokes with air between them, a raised domed hub with a dark axle bore and keyway.
-- Material: height-field normals (rim bevel, rounded spokes, dome hub) snapped to a 6-tone cool steel ramp, bright
-- machined edge on the upper-left of every face, specular streak along the upper-left rim, AO where spokes meet rim
-- and hub, a dark bore with a lit lower lip.
-- quirk: a fat drop of amber oil is about to drip off the lower-right tooth.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi, atan = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi, math.atan
local c = A.new("ico-cog")
local ST = { "#2c2e4a", "#474c6c", "#68708e", "#929ab2", "#c0c6d6", "#eceef4" }
local OIL = { "#4a2416", "#8a4a16", "#c87a1e", "#f0b23c", "#fff0b4" }
local CX, CY = 31.5, 31.5
local RROOT, RTIP, RIN, RHUB = 16.4, 22.6, 12, 6.2
local TILT = { 31.5, 31.5, 22, 0.3 }
local tok = A.tok("steel")

-- rim + teeth
local outer = HP.mask()
for y = 0, 63 do for x = 0, 63 do
  local r, a = A.polar(x, y, CX, CY)
  local ok = r <= RROOT + 0.4 and r >= RIN
  if not ok and r > RROOT - 0.5 then
    -- tooth: straight-sided, slightly tapered, flat tip (axis/perpendicular distance, not arc)
    for i = 0, 7 do
      local ta = i * pi / 4 + pi / 8
      local ux, uy = cos(ta), sin(ta)
      local ax = (x - CX) * ux + (y - CY) * uy
      local pp = abs(-(x - CX) * uy + (y - CY) * ux)
      local f = max(0, (ax - RROOT) / (RTIP - RROOT))
      if ax <= RTIP and ax > RROOT - 2 and pp <= 3.1 - 0.8 * f then ok = true end
      -- chamfer the two tip corners by 1 px
      if ok and ax > RTIP - 1 and pp > 1.7 and pp <= 3.1 - 0.8 * f and abs(-(x - CX) * uy + (y - CY) * ux) == pp then
        if ax > RTIP - 0.6 then ok = false end
      end
      if ok then break end
    end
  end
  if ok then outer:set(x, y) end
end end
-- spokes (4, diagonal) and hub
local spokes = HP.mask()
local SA = {}
for i = 0, 3 do SA[i + 1] = i * pi / 2 end
for y = 0, 63 do for x = 0, 63 do
  local r, a = A.polar(x, y, CX, CY)
  if r > RHUB - 1 and r < RIN + 0.5 then
    for _, ta in ipairs(SA) do
      local d = abs(((a - ta + pi) % (2 * pi)) - pi) * r
      if d <= 1.9 then spokes:set(x, y) end
    end
  end
end end
local hub = A.ell(CX, CY, RHUB, RHUB)
local bore = A.ell(CX, CY, 2.4, 2.4)
 -- keyway notch (top)
hub:cut(bore)
spokes:cut(hub):cut(outer)

-- rim: bevel height field (raised ridge 1.8 px from each edge)
local dO = X.dist(outer)
local function hR(x, y) local v = dO[K(x, y)] if not v then return 0 end return 2.2 * sqrt(1 - (1 - min(v + 0.5, 2) / 2) ^ 2) end
local nR = A.hnorm(outer, hR, 1.1)
local biasR = {}
X.ao(biasR, outer, spokes, 1, -1)
local idxR = A.shade(c, outer, nR, ST, { tok = tok, bias = biasR, amb = 0.1, wrap = 0.3, tilt = TILT, cuts = { 0.2, 0.38, 0.55, 0.74, 0.93 } })
-- machined groove ring on the rim face
outer:each(function(x, y)
  local r, a = A.polar(x, y, CX, CY)
  if r >= 13.6 and r < 14.5 then A.step(c, idxR, ST, x, y, -1, tok) end
  if r >= 14.5 and r < 15.3 and (a < -pi / 2 or a > pi * 0.9) then A.step(c, idxR, ST, x, y, 1, tok) end
end)
-- specular streak along the upper-left rim
outer:each(function(x, y)
  local r, a = A.polar(x, y, CX, CY)
  if r >= 15.3 and r <= 16.3 and a > -pi * 0.86 and a < -pi * 0.62 then c:put(x, y, ST[6], tok) end
end)

-- spokes: rounded across their width (cylinder normals)
local nS = {}
spokes:each(function(x, y)
  local r, a = A.polar(x, y, CX, CY)
  local best, bt = 1e9, 0
  for _, ta in ipairs(SA) do local d = ((a - ta + pi) % (2 * pi)) - pi if abs(d) < abs(best) then best, bt = d, ta end end
  local s = max(-0.95, min(0.95, best * r / 2.6))
  local px, py = -sin(bt), cos(bt)
  nS[K(x, y)] = { px * s, py * s, sqrt(1 - s * s) }
end)
local biasS = {}
X.ao(biasS, spokes, outer, 1, -1)
X.ao(biasS, spokes, hub, 1, -1)
A.shade(c, spokes, nS, ST, { tok = A.tok("spoke"), bias = biasS, amb = 0.06, wrap = 0.2, tilt = TILT })

-- hub: domed boss with a flat collar
local function hH(x, y)
  local r = sqrt((x - CX) ^ 2 + (y - CY) ^ 2)
  if r > RHUB + 0.5 then return 0 end
  local t = r / (RHUB + 0.5)
  return 4.2 * sqrt(max(0, 1 - t * t))
end
local nH = A.hnorm(hub, hH, 0.9)
local idxH = A.shade(c, hub, nH, ST, { tok = A.tok("hub"), amb = 0.1, wrap = 0.25, tilt = { 31.5, 31.5, 22, 0.12 } })
-- bore lip: lit lower-right inner edge, dark upper-left inner edge
A.touch(hub, bore):each(function(x, y)
  if x + y > 2 * CY + 0.5 then c:put(x, y, ST[5], A.tok("hub")) else c:put(x, y, ST[1], A.tok("hub")) end
end)
bore:each(function(x, y) c:put(x, y, "#1e1a2c", A.tok("bore")) end)
c:put(floor(CX) + 1, floor(CY) + 1, ST[2], A.tok("bore"))
-- hub glint
c:put(floor(CX) - 3, floor(CY) - 4, A.CREAM, A.tok("hub")) c:put(floor(CX) - 2, floor(CY) - 4, ST[6], A.tok("hub"))

-- cream sparkle on the top-left tooth tip
do local ta = -3 * pi / 4 + pi / 8 - pi / 4
  local x, y = floor(CX + cos(-5 * pi / 8) * 20.3 + 0.5), floor(CY + sin(-5 * pi / 8) * 20.3 + 0.5)
  if outer:has(x, y) then c:put(x, y, A.CREAM, tok) end
end

-- quirk: oil drop hanging from the lower-right tooth (pi/8 tooth points right-down-ish)
local ta = pi / 8 + pi / 4      -- 67.5 deg: the lower-right tooth
-- lowest tooth pixel near that tooth
local lx, ly = 0, 0
outer:each(function(x, y) local r, a = A.polar(x, y, CX, CY)
  if r > RTIP - 2 and abs(a - ta) < 0.3 and (y > ly or (y == ly and x > lx)) then lx, ly = x, y end end)
local otok = A.tok("oil")
local drop = A.ell(lx, ly + 3.6, 1.7, 1.8)
drop:set(lx, ly + 1)
local nD = X.sphere(lx - 0.2, ly + 3.4, 2, drop)
A.shade(c, drop, nD, OIL, { tok = otok, cuts = { 0.2, 0.42, 0.62, 0.84 }, amb = 0.15 })
c:put(lx, ly + 1, OIL[3], otok)
c:put(lx - 1, ly + 3, OIL[5], otok)
c:put(lx + 1, ly + 5, OIL[2], otok)
-- oil smear down the tooth flank
c:put(lx, ly, OIL[3], otok) c:put(lx - 1, ly, OIL[2], otok) c:put(lx, ly - 1, OIL[2], otok)
A.save(c, "ico-cog")
