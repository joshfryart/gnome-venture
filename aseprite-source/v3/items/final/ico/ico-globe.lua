-- ico-globe (final, Opus). A slim desk globe: varnished sphere tilted 23 degrees in a gold half-meridian, on a thin
-- turned-wood neck and a round wood foot with a 2-tone ground shadow.
-- Material: per-pixel sphere light snapped to a 6-tone sea ramp and a 6-tone moss ramp for the land (continents are
-- blobs on the sphere surface, so they foreshorten toward the rim), pale shallow-water rim on every coast, a faint
-- tilted equator, glossy varnish streak + cream glint upper-left, cool violet reflected light lower-right.
-- Meridian: 3 px gold band with a lit inner bevel, dark degree ticks and two pivot bolts; AO where it crosses the
-- sphere. Wood: grain lines on the foot, a paler end-grain lip, a collar on the neck, dark row where the neck meets.
-- quirk: a tiny paper sailboat is crossing the ocean.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, exp, atan, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.exp, math.atan, math.pi
local c = A.new("ico-globe")
local SEA  = { "#1d2c5e", "#244488", "#2a62ad", "#3889cb", "#5cb2dd", "#a8e0f0" }
local LAND = { "#1a4838", "#24663e", "#36874a", "#58a850", "#88c75c", "#c2e380" }
local GOLD = { "#6a3a1c", "#9a5a1e", "#cc8a26", "#eab43a", "#f9d769", "#fff0b0" }
local WOOD = { "#3e2420", "#5e3729", "#864c33", "#a86a42", "#c98e5a", "#e8b982" }
local SPEC, BOUNCE = "#fff4d6", "#8a7cc8"
local CX, CY, R = 30, 25, 16
local gtok, rtok, wtok = A.tok("globe"), A.tok("ring"), A.tok("wood")
local TILT = 23 * pi / 180
local ax, ay = sin(TILT), -cos(TILT)          -- north axis in screen (upper-right)

-- ground shadow + wood foot (drawn first; globe is above it)
local FY = CY + 25
c:groundShadow(CX, FY + 3, 13, 2)
local foot = A.ell(CX, FY, 11, 2.2)
foot:add(HP.rect(CX - 11, FY, CX + 11, FY + 2))
local fn = {}
foot:each(function(x, y)
  local u = (x - CX) / 11.5
  if y > FY then fn[K(x, y)] = { u * 0.9, 0.35, sqrt(max(0.05, 1 - u * u)) * 0.6 }
  else
    local v = (y - FY) / 2.7
    fn[K(x, y)] = { u * 0.35, -0.75 + v * 0.2, 0.6 } end
end)
for k, v in pairs(fn) do local l = sqrt(v[1]^2 + v[2]^2 + v[3]^2) fn[k] = { v[1]/l, v[2]/l, v[3]/l } end
local fidx = A.shade(c, foot, fn, WOOD, { tok = wtok, amb = 0.1, wrap = 0.3 })
-- top lip (end grain) paler, side grain lines, bottom row dark
foot:each(function(x, y)
  if y == FY + 2 then A.step(c, fidx, WOOD, x, y, -1, wtok) end
  if y > FY and y < FY + 2 and (x % 5 == 1) then A.step(c, fidx, WOOD, x, y, -1, wtok) end
  if y <= FY and y == floor(FY - 2) + 1 and x % 4 == 0 then A.step(c, fidx, WOOD, x, y, -1, wtok) end
end)
-- neck: 3 px turned wood, collar ring 5 px
local NX = CX + 0
local neck = HP.rect(NX - 1, CY + R + 4, NX + 1, FY - 1)
local collar = HP.rect(NX - 2, FY - 3, NX + 2, FY - 2)
local nn = {}
local nm = neck:copy():add(collar)
nm:each(function(x, y) local w = collar:has(x, y) and 2.5 or 1.5
  local s = (x - NX) / w nn[K(x, y)] = { s, 0, sqrt(max(0.05, 1 - s * s)) } end)
local nidx = A.shade(c, nm, nn, WOOD, { tok = wtok, amb = 0.12, wrap = 0.3 })
-- AO where the neck meets the foot and the collar
for x = NX - 2, NX + 2 do A.step(c, nidx, WOOD, x, FY - 2, -1, wtok) end
for x = NX - 1, NX + 1 do A.step(c, nidx, WOOD, x, FY - 4, -1, wtok) end

-- sphere
local gm = A.ell(CX, CY, R, R)
local gn = X.sphere(CX, CY, R, gm)
local v = A.val(gn, { amb = 0.06, wrap = 0.22 })
-- globe frame: rotate normal so the axis is vertical (y up = north)
local function gframe(n)
  local x, y, z = n[1], n[2], n[3]
  local gx = x * cos(TILT) + y * sin(TILT)
  local gy = -x * sin(TILT) + y * cos(TILT)
  return gx, -gy, z                     -- north positive
end
local blobs = {   -- direction (gx, gy, gz) + angular size
  { -0.55, 0.45, 0.70, 0.42 }, { -0.20, 0.75, 0.62, 0.30 }, { -0.70, 0.05, 0.71, 0.26 },
  { 0.45, -0.35, 0.82, 0.34 }, { 0.62, -0.62, 0.48, 0.28 },
  { 0.25, 0.30, 0.92, 0.12 }, { -0.10, -0.78, 0.62, 0.18 },
}
for _, b in ipairs(blobs) do local l = sqrt(b[1]^2 + b[2]^2 + b[3]^2) b[1], b[2], b[3] = b[1]/l, b[2]/l, b[3]/l end
local land = HP.mask()
local GY = {}
gm:each(function(x, y) local k = K(x, y)
  local gx, gy, gz = gframe(gn[k])
  GY[k] = gy
  local f = 0
  for _, b in ipairs(blobs) do
    local d = gx * b[1] + gy * b[2] + gz * b[3]
    local ang = math.acos(max(-1, min(1, d)))
    f = f + exp(-(ang / b[4]) ^ 2)
  end
  f = f + (X.hash(floor(gx * 30), floor(gy * 30), 3) - 0.5) * 0.25
  if f > 0.55 then land:set(x, y) end
end)
-- drop stray 1-2 px specks of land and keep coasts clean
land:each(function(x, y) local nb = 0
  for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if land:has(x + d[1], y + d[2]) then nb = nb + 1 end end
  if nb <= 1 then land.s[K(x, y)] = nil end end)
local sea = gm:copy():cut(land)
local cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }
local sidx = X.tone(c, sea, v, SEA, { cuts = cuts, tok = gtok })
local lidx = X.tone(c, land, v, LAND, { cuts = { 0.16, 0.32, 0.5, 0.66, 0.84 }, tok = gtok })
-- shallow water along coasts (+1), equator (-1 on sea)
local shore = A.touch(sea, land)
shore:each(function(x, y) A.step(c, sidx, SEA, x, y, 1, gtok) end)
sea:each(function(x, y) local k = K(x, y)
  if abs(GY[k]) < 0.035 and not shore:has(x, y) then A.step(c, sidx, SEA, x, y, -1, gtok) end end)
-- land: a darker inland ridge texture (sparse) and lit coast on the upper-left
land:each(function(x, y)
  if X.hash(x, y, 11) < 0.06 and (lidx[K(x, y)] or 0) >= 3 then A.step(c, lidx, LAND, x, y, -1, gtok) end end)
-- cool reflected light on the lower-right rim
local rim = X.rim(gn)
gm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.72 then c:put(x, y, BOUNCE, gtok) end end)
-- varnish specular: curved streak + glint upper-left
for _, p in ipairs{ {20,15},{21,14},{22,13},{23,13},{19,16},{19,17},{18,18} } do
  local k = K(p[1], p[2])
  if sidx[k] then sidx[k] = 6 c:put(p[1], p[2], SEA[6], gtok) elseif lidx[k] then c:put(p[1], p[2], LAND[6], gtok) end end
c:put(22, 14, SPEC, gtok) c:put(21, 15, SPEC, gtok)

-- meridian: 3 px gold annulus, the half right of the tilted axis (passes under the sphere, where the neck holds it)
local R0, R1 = R + 1.6, R + 4.0
local ring = HP.mask()
local rn = {}
for y = CY - R - 6, CY + R + 6 do for x = CX - R - 6, CX + R + 6 do
  local dx, dy = x - CX, y - CY
  local d = sqrt(dx * dx + dy * dy)
  if d >= R0 and d <= R1 then
    -- side of the axis: cross(axis, p) > 0 => right of axis
    local cr = ax * dy - ay * dx
    if cr > -0.5 then
      ring:set(x, y)
      local s = (d - (R0 + R1) / 2) / ((R1 - R0) / 2 + 0.5)   -- -1 inner .. +1 outer
      local ux, uy = dx / d, dy / d
      rn[K(x, y)] = { ux * s * 0.8, uy * s * 0.8, sqrt(max(0.05, 1 - s * s * 0.64)) }
    end
  end
end end
local ridx = A.shade(c, ring, rn, GOLD, { tok = rtok, amb = 0.12, wrap = 0.35, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
-- degree ticks: dark marks across the band every ~14 degrees
ring:each(function(x, y)
  local a = atan(y - CY, x - CX) * 180 / pi
  local d = sqrt((x - CX)^2 + (y - CY)^2)
  if (floor(a + 720) % 15) == 0 and d > R0 + 0.8 then A.step(c, ridx, GOLD, x, y, -2, rtok) end
end)
-- AO on the sphere next to the ring (shade side) and on the ring where it meets the sphere edge
A.touch(gm, ring):each(function(x, y)
  if sidx[K(x, y)] then A.step(c, sidx, SEA, x, y, -1, gtok) elseif lidx[K(x, y)] then A.step(c, lidx, LAND, x, y, -1, gtok) end end)
-- ring end caps + pivot bolts at the poles
local function bolt(px, py)
  local m = A.ell(px, py, 1.6, 1.6)
  local bn = X.sphere(px, py, 1.6, m)
  A.shade(c, m, bn, GOLD, { tok = rtok, amb = 0.15, wrap = 0.3 })
  c:put(floor(px + 0.5), floor(py + 0.5), GOLD[1], rtok)
end
local pr = R + 2.8
bolt(CX + ax * pr, CY + ay * pr)
bolt(CX - ax * pr, CY - ay * pr)
-- neck attaches to the ring at the bottom: dark contact row
for x = NX - 1, NX + 1 do local y = CY + R + 4 if nidx[K(x, y)] then A.step(c, nidx, WOOD, x, y, -1, wtok) end end

-- quirk: tiny paper sailboat on the ocean (lower-left sea)
local bx, by = 20, 28
local BT = { s = "#fff4d6", S = "#e6d8c0", h = "#c98e5a", H = "#864c33", m = "#5e3729", w = "#a8e0f0" }
A.map(c, {
  "..s..",
  ".ssS.",
  "sssS.",
  "mhhhH",
  ".wHw.",
}, bx, by, BT, gtok)
A.save(c, "ico-globe")
