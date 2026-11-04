-- chanterelle (final, Opus aB1r1_3). One slim golden trumpet: wavy, lobed cap rim with a sunken centre (concave
-- light), blunt forked false gills running from the rim down the stem, a tapering stem with a paler lower bevel
-- and a dark ambient row where gills meet the stem; small 2-tone ground shadow and a crumb of moss at the foot.
-- quirk: a single brown pine needle has fallen across the cap and pokes out over the rim.
local NAME = "chanterelle"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r1_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi, atan, sqrt = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.atan, math.sqrt
local c = A.new(NAME)
local GOLD = { "#6a2e1e", "#9a4e1c", "#c87420", "#e89a2a", "#f8c048", "#ffe08a" }
local MOSS = { "#24544a", "#3f9150", "#7cc35a" }
local CX = 32

c:groundShadow(CX + 1, 56, 8, 1.5)

-- body: trumpet flaring from stem to rim. half width per row
local Y0, YR, YB = 12, 31, 56
local function hw(y)
  if y <= YR then
    local t = (y - Y0) / (YR - Y0)
    return 3.6 + 17.5 * (1 - t) ^ 2.3
  end
  local t = (y - YR) / (YB - YR)
  return 3.6 - 0.6 * t + (t > 0.9 and -0.8 or 0) + (t > 0.82 and 0.6 or 0)
end
local body = HP.mask()
for y = Y0 + 2, YB do local w = hw(y)
  for x = floor(CX - w), floor(CX + w + 0.999) do if abs(x + 0.5 - CX) <= w then body:set(x, y) end end end
-- cap top: wavy lobed ellipse
local capm = HP.mask()
local CY, RX, RY = 13, 20, 4.6
for y = 5, 22 do for x = 8, 56 do
  local dx, dy = (x + 0.5 - CX), (y + 0.5 - CY)
  local a = atan(dy * RX / RY, dx)
  local wav = 1 + 0.07 * sin(a * 5 + 0.6) + 0.04 * sin(a * 9)
  if (dx / (RX * wav)) ^ 2 + (dy / (RY * wav)) ^ 2 <= 1 then capm:set(x, y) end
end end
body:cut(capm)

-- underside/stem normals: cylinder across, facing down under the flare
local gtok = A.tok("gills")
local n, U = {}, {}
body:each(function(x, y)
  local w = hw(y)
  local u = max(-0.96, min(0.96, (x + 0.5 - CX) / (w + 0.4)))
  local ny = (y <= YR) and 0.55 * (1 - (y - Y0) / (YR - Y0)) or 0
  n[K(x, y)] = { A.norm(u, ny, sqrt(1 - u * u)) }
  U[K(x, y)] = u
end)
local bias = {}
X.ao(bias, body, capm, 1, -1)
local gidx = A.shade(c, body, n, GOLD, { bias = bias, tok = gtok, amb = 0.12, wrap = 0.35 })
-- false gills: blunt ridges at fixed fractions of the width, forking near the rim
body:each(function(x, y)
  if y > YR + 6 then return end
  local k = K(x, y)
  local u = U[k]
  local f = (y - Y0) / (YR + 6 - Y0)
  local nr = f < 0.45 and 9 or 6
  local ph = (u + 1) * nr / 2
  local fr = ph - floor(ph)
  if fr < 0.18 then A.step(c, gidx, GOLD, x, y, -1, gtok)
  elseif fr < 0.36 and y < YR + 4 then A.step(c, gidx, GOLD, x, y, 1, gtok) end
end)
-- ambient band where gills taper into the stem
for x = CX - 4, CX + 4 do if body:has(x, YR + 6) then A.step(c, gidx, GOLD, x, YR + 6, -1, gtok) end end
-- stem: pale lower bevel on the lit edge, crumbs of soil
for y = YR + 8, YB - 2 do local x = floor(CX - hw(y) + 1) if body:has(x, y) then c:put(x, y, GOLD[6], gtok) end end

-- cap top: concave (sunken centre), lit far rim lip
local ctok = A.tok("cap")
local cn = {}
capm:each(function(x, y)
  local dx, dy = (x + 0.5 - CX) / RX, (y + 0.5 - CY) / RY
  local r = sqrt(dx * dx + dy * dy)
  -- concave: normals point inward (toward centre) except a rolled-over lip at the edge
  local s = r > 0.82 and 0.8 or -0.55 * r
  cn[K(x, y)] = { A.norm(dx * s, dy * s * 0.6 - 0.25, 1) }
end)
local cb = {}
capm:each(function(x, y)
  local dx, dy = (x + 0.5 - CX) / RX, (y + 0.5 - CY) / RY
  if dx * dx + dy * dy < 0.18 then cb[K(x, y)] = -1 end
end)
local cidx = A.shade(c, capm, cn, GOLD, { bias = cb, tok = ctok, amb = 0.18, wrap = 0.35 })
-- wavy rim lip: bright on the near (front) lower edge where it rolls over
capm:edge():each(function(x, y) if y >= CY + 2 and x < CX + 10 then c:put(x, y, GOLD[6], ctok) elseif y >= CY + 2 then c:put(x, y, GOLD[4], ctok) end end)
-- specular
c:put(20, 11, "#fff2c0", ctok) c:put(21, 11, GOLD[6], ctok)

-- quirk: pine needle across the cap, overhanging the rim to the right
local ntok = A.tok("needle")
A.pline(c, { { 25, 10 }, { 44, 15 } }, "#7a4a2c", ntok)
A.pline(c, { { 45, 16 }, { 50, 17 } }, "#7a4a2c", ntok)
A.pline(c, { { 25, 9 }, { 40, 13 } }, "#c08a52", ntok)
c:put(51, 17, "#51302b", ntok)

-- moss crumb at the foot
local mtok = A.tok("moss")
for _, q in ipairs{ { 26, 55, 2 }, { 27, 55, 3 }, { 27, 54, 3 }, { 28, 55, 2 }, { 37, 55, 2 }, { 38, 55, 1 }, { 37, 54, 3 } } do c:put(q[1], q[2], MOSS[q[3]], mtok) end

A.save(c, NAME)
