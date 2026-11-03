-- ico-exclaim (final, Opus). A slim exclamation mark cut from a wooden board and painted in glossy red enamel: a
-- tall bar that tapers from a rounded top to a narrow foot, then a gap, then a round dot.
-- Material: pillow normals (4 px rounded bevel) snapped per pixel to a 6-tone ember ramp with cool-violet shade,
-- a long specular streak down the lit left bevel + cream glint, cool reflected light on the lower-right edges, a
-- dark ambient row at the foot of the bar and a 2-tone ground shadow under the dot.
-- quirk: a chip of paint is knocked off the top-right corner, showing pale wood with grain underneath.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-exclaim")
local RD = { "#561632", "#8a2238", "#c0323c", "#e64e3e", "#ff7f56", "#ffb98e" }
local WD = { "#864c33", "#b97a4a", "#e0aa72", "#f3cf98" }
local CREAM, BOUNCE = "#fff4d6", "#9c4a78"
local CX = 31.5
local T0, T1 = 8, 41                     -- bar top / bottom rows
local DY, DR = 50.5, 5.6                 -- dot centre y, radius
local btok, dtok, wtok = A.tok("bar"), A.tok("dot"), A.tok("wood")

c:groundShadow(32, floor(DY + DR) + 2, 8, 1)

-- bar: half width 7.5 at the top easing to 3.8 at the foot; rounded top corners and rounded foot
local bar = HP.mask()
for y = T0, T1 do
  local t = (y - T0) / (T1 - T0)
  local hw = 7.6 - 3.8 * t ^ 1.15
  if y - T0 < 3 then hw = hw - ({ 2.2, 0.9, 0.3 })[y - T0 + 1] end
  if T1 - y < 2 then hw = hw - ({ 1.4, 0.5 })[T1 - y + 1] end
  for x = floor(CX - hw + 0.5), floor(CX + hw + 0.5) do bar:set(x, y) end
end
-- chip on the top-right corner (quirk)
local chip = HP.mask()
for _, p in ipairs{ { 34, 8 }, { 35, 8 }, { 36, 8 }, { 37, 8 }, { 35, 9 }, { 36, 9 }, { 37, 9 }, { 38, 9 }, { 36, 10 }, { 37, 10 }, { 38, 10 }, { 39, 10 }, { 37, 11 }, { 38, 11 }, { 39, 11 }, { 38, 12 }, { 39, 12 } } do
  if bar:has(p[1], p[2]) then chip:set(p[1], p[2]) end
end
local bn = X.pillow(bar, 4)
local bb = {}
bar:each(function(x, y) if y >= T1 - 1 then bb[K(x, y)] = -1 end end)
local bidx = A.shade(c, bar, bn, RD, { tok = btok, amb = 0.06, wrap = 0.15, cuts = { 0.22, 0.4, 0.57, 0.73, 0.88 },
  bias = bb, tilt = { CX, 26, 22, 0.12 } })
-- the chip: wood under the paint, sunken edge shadow on its lower-left rim
local dark = {}
chip:each(function(x, y)
  local g = (x + y * 2) % 3 == 0
  c:put(x, y, g and WD[2] or WD[3], wtok)
end)
c:put(36, 8, WD[4], wtok) c:put(37, 9, WD[4], wtok)
chip:grow(1):cut(chip):each(function(x, y)
  if bar:has(x, y) and (chip:has(x + 1, y) or chip:has(x, y - 1)) then c:put(x, y, RD[1], btok) bidx[K(x, y)] = 1 end end)

-- dot
local dot = A.ell(CX, DY, DR, DR)
local dn = X.sphere(CX, DY, DR, dot)
local dp = X.pillow(dot, 3)
dot:each(function(x, y) local k = K(x, y)   -- blend sphere with the bevel so the dot matches the bar's flat face
  local a, b = dn[k], dp[k]
  local nx, ny, nz = a[1] * 0.55 + b[1] * 0.45, a[2] * 0.55 + b[2] * 0.45, a[3] * 0.55 + b[3] * 0.45
  local l = sqrt(nx * nx + ny * ny + nz * nz) dn[k] = { nx / l, ny / l, nz / l } end)
local didx = A.shade(c, dot, dn, RD, { tok = dtok, amb = 0.06, wrap = 0.15, cuts = { 0.22, 0.4, 0.57, 0.73, 0.88 } })

-- cool reflected light on the lower-right edges of both parts
for _, pr in ipairs{ { bar, bn, 16, T1 - 2 }, { dot, dn, floor(DY) - 1, floor(DY + DR) - 1 } } do
  local rim = X.rim(pr[2])
  pr[1]:edge():each(function(x, y) local k = K(x, y)
    if rim[k] and rim[k] > 0.55 and y >= pr[3] and y <= pr[4] and not chip:has(x, y) then c:put(x, y, BOUNCE, btok) end end)
end
-- specular streak down the lit left bevel of the bar, short streak on the dot, one cream glint
for y = 12, 30 do
  local t = (y - T0) / (T1 - T0)
  local hw = 7.6 - 3.8 * t ^ 1.15
  local x = floor(CX - hw + 0.5) + 2
  c:put(x, y, RD[6], btok)
end
c:put(floor(CX - 7.6 + 0.5) + 3, 11, CREAM, btok) c:put(floor(CX - 7.6 + 0.5) + 3, 12, RD[6], btok)
c:put(floor(CX) - 3, floor(DY) - 3, RD[6], dtok) c:put(floor(CX) - 2, floor(DY) - 4, RD[6], dtok)
c:put(floor(CX) - 3, floor(DY) - 2, RD[6], dtok)
A.save(c, "ico-exclaim")
