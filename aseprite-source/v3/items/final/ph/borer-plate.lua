-- borer-plate (final pass, Opus). The pronotum shield of a basalt borer (a wheelbarrow-sized mole-cricket): a slim
-- oblong domed plate laid on the diagonal, basalt-dark violet-brown chitin with faint hexagonal column cells, a rolled
-- bevelled rim (bright upper-left edge, AO groove inside it), a concave head notch at the front, a median suture
-- groove with a lit lip, two muscle-scar dimples, a velvety fringe of short hairs along the back edge and one hard
-- specular streak on the dome.
-- quirk: a tiny pale moss tuft has taken root in one of the cell seams.
local NAME = "borer-plate"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR21_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local CH = { "#1e1624", "#2e2234", "#463346", "#634a58", "#8a6c70", "#b8988e" }
local RIM = { "#2a1e2c", "#4a3644", "#6e5260", "#957878", "#c2a496", "#e8d2b8" }
local SPEC, HAIR = "#fff0d8", "#9a7c6a"
local MOSS = { "#2e6a44", "#5aa24a", "#a6d470" }

local CX, CY, RX, RY, ANG = 32, 33, 21.5, 12.5, -0.42
local ca, sa = cos(ANG), sin(ANG)
local function uv(x, y) local dx, dy = x - CX, y - CY return (dx * ca + dy * sa) / RX, (-dx * sa + dy * ca) / RY end
local PE = 2.6
local function q(x, y) local u, v = uv(x, y) return (abs(u) ^ PE + abs(v) ^ PE) ^ (1 / PE) end
-- head notch: concave bite at the front (-u end)
local NX, NY = CX - ca * (RX + 3.5), CY - sa * (RX + 3.5)
local function inNotch(x, y) local dx, dy = x - NX, y - NY
  local a, b = dx * ca + dy * sa, -dx * sa + dy * ca return (a / 6.2) ^ 2 + (b / 7.5) ^ 2 <= 1 end

local m = HP.mask()
for y = 0, 63 do for x = 0, 63 do if q(x, y) <= 1 and not inNotch(x, y) then m:set(x, y) end end end
-- dome height; the shell is a saddle-ish hood: high along the middle, rolled down at the sides
local function h(x, y) local qq = min(1, q(x, y)) local u = uv(x, y)
  return 7.5 * sqrt(max(0, 1 - qq ^ 2.2)) * (1 - 0.12 * u * u) end
local n = A.hnorm(m, h, 0.9)
local inner = m:shrink(2)
local rim = m:copy():cut(inner)
local rn = X.pillow(m, 2.2)
for k in pairs(rim.s) do local a, b = n[k], rn[k]
  n[k] = { A.norm(a[1] * 0.4 + b[1], a[2] * 0.4 + b[2], b[3] * 0.8) } end

-- bias: AO groove just inside the rim, median suture, dimples, basalt column seams
local bias = {}
X.ao(bias, inner, rim, 1, -1)
local cells = {}
for i = 1, 11 do cells[i] = { CX + (X.hash(i, 3, 7) - 0.5) * RX * 1.9, CY + (X.hash(i, 9, 2) - 0.5) * RY * 1.6 } end
local seam = {}
inner:each(function(x, y) local k = K(x, y)
  local d1, d2 = 1e9, 1e9
  for _, p in ipairs(cells) do local d = (x - p[1]) ^ 2 + (y - p[2]) ^ 2
    if d < d1 then d1, d2 = d, d1 elseif d < d2 then d2 = d end end
  if sqrt(d2) - sqrt(d1) < 0.9 then seam[k] = true bias[k] = (bias[k] or 0) - 1 end
end)
local sut = {}
inner:each(function(x, y) local u, v = uv(x, y) local k = K(x, y)
  if abs(v * RY) < 0.6 and u > -0.72 and u < 0.82 then sut[k] = 1 bias[k] = -2
  elseif v * RY >= -1.6 and v * RY < -0.6 and u > -0.68 and u < 0.78 then sut[k] = 2 bias[k] = (bias[k] or 0) + 1 end
end)
-- muscle-scar dimples either side of the suture (dark lower-right, lit upper-left inside)
local dimples = {}
for _, d in ipairs{ { -0.15, -0.48 }, { -0.15, 0.48 } } do
  local x0, y0 = CX + d[1] * RX * ca - d[2] * RY * sa, CY + d[1] * RX * sa + d[2] * RY * ca
  dimples[#dimples + 1] = { x0, y0 }
  local dm = A.rell(x0, y0, ca, sa, 2.6, 1.6)
  dm:each(function(x, y) local k = K(x, y) if inner:has(x, y) and not sut[k] then
    local s = (x - x0) + (y - y0)
    bias[k] = (bias[k] or 0) + (s < 0 and -2 or 1) end end)
end

local tok = { r = { name = "shell" } }
local idx = A.shade(c, inner, n, CH, { bias = bias, tok = tok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.12, wrap = 0.3 })
local rtok = { r = { name = "rim" } }
local ridx = A.shade(c, rim, n, RIM, { tok = rtok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.1, wrap = 0.25 })
-- separation: rim's inner row darker where it meets the dome on the lit side
-- velvet fringe: short hairs poking out past the back (+u) edge, lower-right side
local edge = m:edge()
edge:each(function(x, y) local u, v = uv(x, y)
  if u > 0.25 and v > 0.2 and X.hash(x, y, 5) > 0.45 then
    local hx, hy = x + 1, y + 1
    if not m:has(hx, hy) then c:put(hx, hy, HAIR, rtok) end
  end
end)
-- cool reflected light on the lower-right rim
rim:each(function(x, y) local u, v = uv(x, y) local k = K(x, y)
  if v > 0.86 and abs(u) < 0.7 and ridx[k] <= 2 then c:put(x, y, "#4a4a6a", rtok) end end)
-- specular streak on the dome (upper-left), plus one cream sparkle on the rim
local sx, sy = CX - 9, CY - 4
for i = 0, 3 do local x, y = floor(sx + i * ca * 1.2 + .5), floor(sy + i * sa * 1.2 + .5)
  if inner:has(x, y) and not sut[K(x, y)] then c:put(x, y, i == 1 and SPEC or CH[6], tok) end end
-- quirk: moss tuft in a cell seam toward the back
local mx, my
do local best
  for k in pairs(seam) do local x, y = k % 1024 - 256, k // 1024 - 256 local u, v = uv(x, y)
    local sc = abs(u - 0.5) + abs(v - 0.35)
    if not sut[k] and (not best or sc < best) then best, mx, my = sc, x, y end end
end
local mtok = { r = { name = "moss" } }
for _, p in ipairs{ { 0, 0, 1 }, { 1, 0, 2 }, { -1, 0, 2 }, { 0, -1, 2 }, { 1, -1, 3 }, { -1, -2, 2 }, { 0, -2, 3 }, { 2, -2, 3 } } do
  c:put(mx + p[1], my + p[2], MOSS[p[3]], mtok) end

A.save(c, NAME)
