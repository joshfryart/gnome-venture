-- ico-sun (Opus artist pass): a round sun medallion with a calm sleepy face and eight slim, sharp rays standing
-- clear of the disc (air between them).
-- Material: the disc is a raised bevelled rim (lit upper-left, deep lower-right) around a softly domed face,
-- per-pixel lit, 6-tone gold; a warm glint on the rim and a cream specular on the dome; cheeks in a warm orange.
-- Rays are faceted like cut metal: each one has a lit and a shaded facet split along its spine, 5-tone ember-orange,
-- with a dark root where the ray points at the disc. quirk: the top ray has a curl, like a cowlick.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_aA10_3.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, max, min, sqrt, abs, sin, cos, pi = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.cos, math.pi
local c = D.new("ico-sun")
local SU, RY = D.SUN, D.RAY
local dtok, rtok = { r = { name = "disc" } }, { r = { name = "ray" } }
local CX, CY, RD = 32, 32, 13.2

-- rays (straight ones are faceted triangles)
local function ray(a, r0, r1, hw)
  local ux, uy = cos(a), sin(a)
  local px, py = -uy, ux
  local pts = { { CX + ux * r0 + px * hw, CY + uy * r0 + py * hw }, { CX + ux * r1, CY + uy * r1 }, { CX + ux * r0 - px * hw, CY + uy * r0 - py * hw } }
  local m = D.poly(pts)
  local n, ss = {}, {}
  m:each(function(x, y)
    local rx, ry = x - CX, y - CY
    local s = rx * px + ry * py
    local sg = s >= 0 and 1 or -1
    if abs(s) < 0.35 then sg = 0 end
    local nx, ny, nz = px * sg * 0.75 + ux * 0.25, py * sg * 0.75 + uy * 0.25, 0.62
    local l = sqrt(nx * nx + ny * ny + nz * nz)
    n[K(x, y)] = { nx / l, ny / l, nz / l }
    ss[K(x, y)] = (rx * ux + ry * uy - r0) / (r1 - r0)
  end)
  return m, n, ss
end
for i = 0, 7 do
  local a = -pi / 2 + i * pi / 4
  if i ~= 0 then
    local long = (i % 2 == 0)
    local m, n, T = ray(a, 16.6, long and 25.4 or 23.4, long and 4.2 or 3.8)
    local idx = D.tone(c, m, n, RY, { amb = 0.1, wrap = 0.2, tok = rtok, cuts = { 0.25, 0.45, 0.65, 0.82 } })
    m:each(function(x, y) local k = K(x, y) if T[k] < 0.12 then D.shift(c, x, y, RY, -1) end end)
  end
end
-- quirk: the top ray curls like a cowlick (swept tube, tapering, tip hooks right)
local cp = { { 32, 17.5 }, { 31.2, 12.5 }, { 30.5, 8.5 }, { 35.5, 7.2 } }
local cm, cn, CT, CS = G.tube(cp, function(t) return 4.1 * (1 - t) ^ 0.9 + 0.35 end)
local cidx = D.tone(c, cm, cn, RY, { amb = 0.1, wrap = 0.25, tok = rtok, cuts = { 0.25, 0.45, 0.62, 0.8 } })
cm:each(function(x, y) local k = K(x, y) if CT[k] < 0.08 then D.shift(c, x, y, RY, -1) end end)
c:put(30, 12, RY[5], rtok) c:put(30, 11, RY[5], rtok)

-- disc: raised rim + domed face
local dm = D.ell(CX, CY, RD, RD)
local function h(x, y)
  local r = sqrt((x - CX) ^ 2 + (y - CY) ^ 2)
  if r > RD + 0.5 then return 0 end
  local rim = RD - 2.6
  if r > rim then local q = (r - rim) / (RD + 0.5 - rim) return 4.2 * sqrt(max(0, 1 - q * q)) + 0.6 end
  -- shallow groove then dome
  local q = r / rim
  return 1.6 + 2.4 * (1 - q * q)
end
local dn = D.hnorm(dm, h)
local didx = D.tone(c, dm, dn, SU, { amb = 0.1, wrap = 0.22, tok = dtok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 } })
-- groove line between rim and face: darker on the lit side (inner wall in shadow), lighter on the shade side
dm:each(function(x, y)
  local r = sqrt((x - CX) ^ 2 + (y - CY) ^ 2)
  if r > RD - 3.3 and r <= RD - 2.4 then
    if (x - CX) + (y - CY) < 0 then D.shift(c, x, y, SU, -2) else D.shift(c, x, y, SU, 1) end
  end
end)
-- glints
c:put(23, 24, SU[6], dtok) c:put(24, 23, SU[6], dtok) c:put(22, 25, SU[6], dtok)
c:put(27, 26, D.CREAM, dtok) c:put(28, 26, SU[6], dtok) c:put(27, 27, SU[6], dtok)

-- face: sleepy closed eyes (ink arcs), small smile, warm cheeks
local INK = D.INK
for _, p in ipairs{ { 26, 31 }, { 27, 32 }, { 28, 32 }, { 29, 31 }, { 35, 31 }, { 36, 32 }, { 37, 32 }, { 38, 31 } } do c:put(p[1], p[2], INK, dtok) end
for _, p in ipairs{ { 30, 36 }, { 31, 37 }, { 32, 37 }, { 33, 36 } } do c:put(p[1], p[2], INK, dtok) end
c:put(24, 34, "#f58a5a", dtok) c:put(25, 34, "#f58a5a", dtok) c:put(39, 34, "#e8744a", dtok) c:put(40, 34, "#e8744a", dtok)
D.save(c, "ico-sun")
