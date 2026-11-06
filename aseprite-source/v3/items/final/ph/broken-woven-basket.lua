-- broken-woven-basket (final, Opus aB13_1 single pass). A round wicker basket seen a little from above: tapered body
-- woven over-under (round weavers and upright stakes, per-cell bump light on a cylinder, dark gaps between rows,
-- foreshortened toward the sides), a twisted rolled rim round a dark mouth, and a slim twisted arched handle.
-- Damage: the handle has snapped on the right (frayed fibre ends, a flying chip) and the lower front is punched
-- through (ragged hole into the dark inside, broken stake ends, a short crack). Ground shadow, AO under the rim.
-- quirk: one sprung weaver has curled out of the hole into a little pig's-tail loop.
local NAME = "broken-woven-basket"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB13_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, cos, pi, sqrt, asin = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt, math.asin
local norm = A.norm
local c = A.new(NAME)

local WK = { "#4a2a22", "#7a4626", "#a8682e", "#cf9440", "#e8b85a", "#f8dc8a" }
local HAND = { "#3a1f1c", "#5a3022", "#7e4a2a", "#a66a36", "#c98e4a", "#e8b46e" }
local INSIDE = { "#24141c", "#3a2024", "#55302a" }
local FIBRE = "#f4dc9c"

c:groundShadow(32, 55, 19, 2)

local CX, RY0 = 32, 27        -- rim ellipse centre
local ORX, ORY, IRX, IRY = 21, 5.6, 17.6, 3.4

-- handle (drawn first: the rim covers its feet)
local hpts = { { 13.5, 28 }, { 13, 3 }, { 51, 3 }, { 50.5, 28 } }
local hm, hn, HT, HS = A.tube(hpts, function(t) return 1.65 end)
local gap = {}
hm:each(function(x, y) local t = HT[K(x, y)]
  -- ragged snap: the break line wanders with S
  local s = HS[K(x, y)]
  if t > 0.6 + 0.025 * s and t < 0.75 - 0.03 * s then gap[#gap + 1] = K(x, y) end end)
for _, k in ipairs(gap) do hm.s[k] = nil end
local htok = { r = { name = "handle" } }
local hidx = A.shade(c, hm, hn, HAND, { amb = 0.12, wrap = 0.28, tok = htok })
hm:each(function(x, y) local k = K(x, y)
  -- twist: diagonal dark grooves with a lit lip
  local d = (HT[k] * 70 + HS[k] * 2.2) % 3.4
  if d < 0.75 then c:put(x, y, HAND[max(1, (hidx[k] or 3) - 2)], htok)
  elseif d < 1.4 and (hidx[k] or 3) >= 3 then c:put(x, y, HAND[min(6, (hidx[k] or 3) + 1)], htok) end
end)
-- frayed fibres at both broken ends
for _, p in ipairs{ { 0.595, -0.8, 1 }, { 0.595, 0.8, 2 }, { 0.755, 0.8, -1 } } do
  local x, y = A.bez(hpts, p[1])
  local x2, y2 = A.bez(hpts, p[1] + 0.01)
  local tx, ty = x2 - x, y2 - y local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  local dir = p[1] < 0.68 and 1 or -1
  for st = 1, 1 do
    c:put(floor(x + tx * dir * st + (-ty) * p[2] * 0.9 + 0.5), floor(y + ty * dir * st + tx * p[2] * 0.9 + 0.5), FIBRE, htok)
  end
end
-- flying chip off the break
for _, p in ipairs{ { 46, 6, 5 }, { 47, 6, 4 }, { 47, 5, 6 } } do c:put(p[1], p[2], HAND[p[3]], htok) end

-- body: tapered, top follows the rim's lower arc
local bm = HP.mask()
local function hwAt(y) local hw = 19.6 - (y - 28) * 0.24 if y >= 51 then hw = hw - (y - 50) * 1.2 end return hw end
for y = 26, 53 do
  local hw = hwAt(y)
  for x = floor(CX - hw), floor(CX + hw - 0.01) do
    local dx = x + 0.5 - CX
    local arc = RY0 + ORY * sqrt(max(0, 1 - (dx / ORX) ^ 2))
    if y >= arc - 1.5 then bm:set(x, y) end
  end
end
-- rim ring + mouth masks
local rim, mouth = HP.mask(), HP.mask()
for y = RY0 - 7, RY0 + 7 do for x = CX - ORX - 1, CX + ORX + 1 do
  local dx, dy = x + 0.5 - CX, y + 0.5 - RY0
  local qo = (dx / ORX) ^ 2 + (dy / ORY) ^ 2
  local qi = (dx / IRX) ^ 2 + (dy / IRY) ^ 2
  if qi <= 1 then mouth:set(x, y) elseif qo <= 1 then rim:set(x, y) end
end end
bm:cut(rim):cut(mouth)

-- hole in the lower front
local hole = HP.mask()
for y = 38, 50 do for x = 33, 47 do
  local q = ((x - 39.5) / 4.6) ^ 2 + ((y - 44) / 3.6) ^ 2 + 0.45 * (X.hash(x, y, 11) - 0.5)
  if q < 1 and bm:has(x, y) then hole:set(x, y) end
end end

-- weave
local bias = {}
X.ao(bias, bm, rim, 1, -1)
X.ao(bias, bm, hole, 1, -1)
local n, kind, FR, FC = {}, {}, {}, {}
bm:each(function(x, y) local k = K(x, y)
  local hw = hwAt(y)
  local dx = x + 0.5 - CX
  local cxn = max(-0.98, min(0.98, dx / hw))
  local colf = asin(cxn) / (pi / 2) * 5.5 + 20
  local rowY = y - 3.6 * sqrt(max(0, 1 - cxn * cxn))
  local rowf = rowY / 3.0 + 20
  local col, row = floor(colf), floor(rowf)
  local fc, fr = colf - col, rowf - row
  FR[k], FC[k] = fr, fc
  local bx, by = 0, 0
  if (row + col) % 2 == 0 then
    by = (fr - 0.5) * 1.5 kind[k] = "w"
    if fr < 0.18 then bias[k] = (bias[k] or 0) - 1 end
  else
    if fc > 0.28 and fc < 0.72 then bx = (fc - 0.5) * 3.2 kind[k] = "s"
    else by = (fr - 0.5) * 1.2 bias[k] = (bias[k] or 0) - 1 kind[k] = "b" end
  end
  local nx, ny, nz = cxn * 0.85 + bx, -0.15 + by, sqrt(max(0.05, 1 - cxn * cxn))
  n[k] = { norm(nx, ny, nz) }
end)
local btok = { r = { name = "body" } }
local vis = bm:copy():cut(hole)
local bidx = A.shade(c, vis, n, WK, { amb = 0.1, wrap = 0.3, bias = bias, tok = btok })
-- base row darker (where it meets the ground)
vis:each(function(x, y) if y >= 52 then A.step(c, bidx, WK, x, y, -1, btok) end end)

-- hole: dark inside, far wall weave hint, broken stake stubs, a crack
hole:each(function(x, y)
  local d = ((x - 39.5) / 4.6) ^ 2 + ((y - 44) / 3.6) ^ 2
  local col = INSIDE[d > 0.55 and 1 or 2]
  if y % 3 == 0 and d < 0.5 then col = INSIDE[3] end
  c:put(x, y, col, btok)
end)
for _, p in ipairs{ { 37, 41, 4 }, { 37, 42, 3 }, { 41, 41, 5 }, { 41, 42, 4 }, { 41, 43, 3 }, { 38, 47, 3 }, { 42, 47, 2 } } do
  if hole:has(p[1], p[2]) then c:put(p[1], p[2], WK[p[3]], btok) end end
for _, p in ipairs{ { 34, 39 }, { 33, 38 }, { 32, 37 }, { 31, 37 } } do if vis:has(p[1], p[2]) then c:put(p[1], p[2], WK[1], btok) end end

-- quirk: sprung weaver curling out of the hole into a loop
local curl = { { 44, 45, 5 }, { 45, 45, 5 }, { 46, 44, 5 }, { 47, 44, 6 }, { 48, 43, 5 }, { 49, 43, 5 }, { 50, 44, 4 }, { 50, 45, 4 },
  { 49, 46, 3 }, { 48, 46, 4 }, { 47, 45, 4 } }
for _, p in ipairs(curl) do c:put(p[1], p[2], WK[p[3]], btok) end

-- mouth: dark inside with the far wall's weave rows
mouth:each(function(x, y)
  local dy = y + 0.5 - RY0
  local col = dy > 0.8 and INSIDE[1] or INSIDE[2]
  if dy <= 0.8 and (x + floor(y / 2) * 2) % 4 == 0 then col = INSIDE[3] end
  c:put(x, y, col, btok)
end)

-- rim: twisted rolled tube round the mouth
local rtok = { r = { name = "rim" } }
local rn, RQ, RA = {}, {}, {}
rim:each(function(x, y) local k = K(x, y)
  local dx, dy = x + 0.5 - CX, y + 0.5 - RY0
  local ang = math.atan(dy / ORY, dx / ORX)
  local qo = sqrt((dx / ORX) ^ 2 + (dy / ORY) ^ 2)
  local qi = sqrt((dx / IRX) ^ 2 + (dy / IRY) ^ 2)
  local q = (qi - 1) / max(0.01, (qi - 1) + (1 - qo))     -- 0 inner edge .. 1 outer edge
  local s = q * 2 - 1
  local rx, ry = cos(ang), sin(ang) * 0.6
  local rl = sqrt(rx * rx + ry * ry) rx, ry = rx / rl, ry / rl
  rn[k] = { norm(rx * s * 0.9, ry * s * 0.9 - 0.25, sqrt(max(0.05, 1 - s * s))) }
  RQ[k], RA[k] = q, ang
end)
local ridx = A.shade(c, rim, rn, WK, { amb = 0.12, wrap = 0.3, tok = rtok })
rim:each(function(x, y) local k = K(x, y)
  local d = (RA[k] * 15 + RQ[k] * 2.4) % 2.6
  if d < 0.6 then c:put(x, y, WK[max(1, (ridx[k] or 3) - 2)], rtok) end
end)
-- one glint on the rim's front lip
c:put(22, 31, WK[6], rtok) c:put(23, 31, WK[6], rtok)

A.save(c, NAME)
