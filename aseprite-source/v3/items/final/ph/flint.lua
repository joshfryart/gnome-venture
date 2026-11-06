-- flint (final, Opus single pass). A slim knapped flint blade lying on the diagonal: glassy blue-black body split into
-- concave conchoidal flake scars (each a shallow bowl with faint ripple rings), bright aretes where scars meet, a crisp
-- cool knife edge along the top, and a chalky cream cortex rind left on the lower-right back (pitted, AO where it meets
-- the glassy face). One cool specular streak on the main ridge.
-- quirk: a tiny fossil ammonite spiral sits in the chalk cortex.
local NAME = "flint"
local B = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_1.lua")
local HP, X, K = B.HP, B.X, B.K
local floor, max, min, abs, sqrt, sin = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin
local c = B.new(NAME)
local FL = { "#1a1624", "#28263c", "#3a3b58", "#525876", "#767f9f", "#aab4d0" }
local SPEC = "#e6eeff"
local CO = { "#6a564c", "#957d6a", "#b9a186", "#d5c3a2", "#ebdfc2", "#faf2dc" }

local body = c:poly{ { 9, 48 }, { 12, 39 }, { 19, 30 }, { 29, 21 }, { 40, 14 }, { 50, 10 }, { 55, 12 }, { 54, 19 },
  { 48, 29 }, { 39, 39 }, { 28, 47 }, { 18, 52 }, { 12, 53 } }
-- cortex: rind strip along the lower-right back, wavy inner boundary
local cortex = c:poly{ { 16, 56 }, { 18, 49 }, { 23, 46 }, { 27, 42 }, { 32, 39 }, { 36, 34 }, { 41, 31 }, { 44, 26 },
  { 48, 22 }, { 51, 17 }, { 60, 14 }, { 60, 60 }, { 14, 60 } }:clip(body)
local face = body:copy():cut(cortex)

-- flake scars: centre, tilt (nx, ny)
local F = { { 15, 46, -0.25, 0.05 }, { 21, 38, 0.1, -0.2 }, { 27, 31, -0.2, 0.15 }, { 26, 42, 0.2, 0.1 },
  { 34, 26, 0.05, -0.25 }, { 35, 34, -0.15, 0.2 }, { 42, 20, -0.25, -0.05 }, { 43, 28, 0.2, 0.05 }, { 50, 15, 0.0, -0.2 } }
local owner = {}
face:each(function(x, y)
  local best, bi = 1e9, 1
  for i, f in ipairs(F) do
    local q = (x - f[1])^2 + (y - f[2])^2 + X.hash(x, y, i) * 3
    if q < best then best, bi = q, i end
  end
  owner[K(x, y)] = bi
end)
local np = X.pillow(body, 3)
local n = {}
face:each(function(x, y) local k = K(x, y) local f = F[owner[k]] local a = np[k]
  local cx, cy = -(x - f[1]) * 0.07, -(y - f[2]) * 0.07         -- concave bowl
  n[k] = { B.norm(a[1] + f[3] + cx, a[2] + f[4] + cy, a[3]) }
end)
local bias = {}
-- ripple rings, AO against cortex
face:each(function(x, y) local k = K(x, y) local f = F[owner[k]]
  local d = sqrt((x - f[1] + 3)^2 + (y - f[2] + 3)^2)
  if d > 3 and d % 3.3 < 0.9 then bias[k] = -1 end
end)
X.ao(bias, face, cortex, 1, -1)
local tok = { r = { name = "flint" } }
local idx = X.tone(c, face, X.light(n, { amb = 0.05, wrap = 0.18 }), FL, { cuts = { 0.16, 0.3, 0.46, 0.62, 0.8 }, bias = bias, tok = tok })
-- aretes: scar boundaries, lit ridge on the facet to the lower-right
face:each(function(x, y) local k = K(x, y) local o = owner[k]
  for _, d in ipairs{ { -1, 0 }, { 0, -1 } } do
    local k2 = K(x + d[1], y + d[2])
    if owner[k2] and owner[k2] ~= o then c:put(x, y, FL[min(6, idx[k] + 2)], tok) return end
  end
end)
-- knife edge: upper-left rim of the glassy face
face:edge():each(function(x, y)
  if not body:has(x - 1, y) or not body:has(x, y - 1) then c:put(x, y, (x + y) % 5 == 0 and FL[5] or FL[6], tok) end
end)
-- specular streak along the main ridge
for _, p in ipairs{ { 30, 25 }, { 31, 24 }, { 32, 24 }, { 33, 23 } } do c:put(p[1], p[2], SPEC, tok) end

-- cortex: chalky, pitted
local ctok = { r = { name = "cortex" } }
local cb = {}
cortex:each(function(x, y) local h = X.hash(x, y, 7)
  if h < 0.18 then cb[K(x, y)] = -1 elseif h > 0.93 then cb[K(x, y)] = 1 end end)
local cidx = X.tone(c, cortex, X.light(X.pillow(cortex, 3), { amb = 0.12, wrap = 0.3 }), CO, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = cb, tok = ctok })
-- rind lip where it meets the glass: one bright row on the cortex side
cortex:each(function(x, y) if face:has(x - 1, y) or face:has(x, y - 1) then c:put(x, y, CO[5], ctok) end end)
-- quirk: fossil ammonite spiral in the chalk
local AX, AY = 37, 33
local amm = { ".aaa.", "ab.ba", "a.a.a", "ab.a.", ".a..." }
for j, row in ipairs(amm) do for i = 1, #row do local ch = row:sub(i, i)
  local x, y = AX + i - 1, AY + j - 1
  if ch ~= "." and cortex:has(x, y) then c:put(x, y, ch == "a" and CO[2] or CO[6], ctok) end
end end
B.save(c, NAME)
