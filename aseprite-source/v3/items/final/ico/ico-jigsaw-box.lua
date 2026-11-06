-- ico-jigsaw-box (final, Opus). A purple cardboard jigsaw box seen from above-front: overhanging lid printed with the
-- puzzle picture (sky, sun, rolling hills, faint piece seams), shallow base below.
-- Material: three planes lit per pixel (top bright, front mid, right side in shade) with bevelled card edges, scuffed
-- pale corners, a dark AO row where the lid overhangs the base, a sunken empty slot in the picture with a lit far
-- wall, cream label on the front. Ground shadow under (it stands).
-- quirk: the one missing piece has escaped and leans against the box, picture side out.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_0.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs, sin = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin
local c = A.new("ico-jigsaw-box")
local PU   = { "#24193f", "#36285f", "#503f92", "#6a52b6", "#8f74d6", "#bca2ee" }
local SKY  = { "#5f9ad0", "#8bc4ea", "#b9e2f5", "#e4f6ff" }
local HILL = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local SUN  = { "#f5b82e", "#ffe38a" }
local CARD = { "#6e4a34", "#9c6e48", "#c99a68", "#e8c48e" }
local PAP  = { "#c9b48e", "#eedcb6", "#fff4d6" }

c:groundShadow(28, 51, 20, 2)

-- planes (front, lid top seen from above, thin right side)
local DX, DY = 5, 12                         -- depth offset (right, up)
local FX0, FX1, FY1 = 10, 44, 50             -- front of the base
local top  = c:poly{ { 9, 33 }, { 45, 33 }, { 45 + DX, 33 - DY }, { 9 + DX, 33 - DY } }
local lidF = c:rect(9, 34, 45, 37)           -- lid rim, front
local lidR = c:poly{ { 46, 33 }, { 45 + DX, 33 - DY }, { 45 + DX, 37 - DY }, { 46, 37 } }
lidR:cut(top)
local baseF = c:rect(FX0, 38, FX1, FY1)
local baseR = c:poly{ { 45, 38 }, { 44 + DX, 38 - DY }, { 44 + DX, FY1 - DY }, { 45, FY1 } }
baseR:cut(lidR):cut(top)
local tok = { r = { name = "box" } }
local function plane(m, nx, ny, nz, R, bias)
  local p = X.pillow(m, R or 1.4)
  local n = A.tilt(p, nx, ny, nz, 0.72)
  return A.shade(c, m, n, PU, { amb = 0.08, wrap = 0.2, bias = bias, tok = tok })
end
local bb = {}
for x = FX0, FX1 do bb[K(x, 38)] = -2 bb[K(x, 39)] = -1 end            -- AO under the lid overhang
plane(baseF, -0.05, 0.25, 1, 1.4, bb)
local bbR = {}
baseR:each(function(x, y) if y <= 38 - floor((x - 45) * DY / DX) + 1 then bbR[K(x, y)] = -1 end end)
plane(baseR, 0.7, 0.05, 0.7, 1.0, bbR)
plane(lidF, -0.05, 0.2, 1, 1.2)
plane(lidR, 0.7, 0.05, 0.7, 1.0)

-- lid top: printed picture, inset 1px from the card edge
plane(top, -0.1, -0.85, 0.5, 1.2)
local ptok = { r = { name = "print" } }
local pic = top:copy():shrink(1)
local function U(x, y) return (x - 9 - (33 - y) * DX / DY) / 36 end
pic:each(function(x, y)
  local v = (33 - y) / DY                        -- 0 front .. 1 back
  local u = U(x, y)
  local hillA = 0.5 + 0.16 * sin(u * 9.5 + 0.6)
  local hillB = 0.24 + 0.1 * sin(u * 6 + 2.4)
  local col
  if v < hillB then col = HILL[(u > 0.7) and 2 or 3]
  elseif v < hillA then col = HILL[(u > 0.62) and 2 or ((v > hillA - 0.12) and 4 or 3)]
  else col = SKY[(v > 0.82) and 2 or 3] end
  if v >= hillA and v < hillA + 0.12 and u < 0.55 then col = SKY[4] end   -- haze above the hills
  local su, sv = (u - 0.84) * 36, (v - 0.72) * DY
  if su * su + sv * sv <= 6.5 then col = SUN[(su + sv < -0.8) and 2 or 1] end
  c:put(x, y, col, ptok)
end)
-- faint seams of the puzzle grid (one tone darker)
local dk = { [SKY[2]] = SKY[1], [SKY[3]] = SKY[2], [SKY[4]] = SKY[3], [HILL[2]] = HILL[1], [HILL[3]] = HILL[2], [HILL[4]] = HILL[3], [SUN[1]] = "#d98322", [SUN[2]] = SUN[1] }
local function darken(x, y) local cur = c:get(x, y) if pic:has(x, y) and dk[cur] then c:put(x, y, dk[cur], ptok) end end
for i = 1, 5 do for yy = 22, 32 do
  if yy % 4 ~= 1 then darken(floor(9 + (33 - yy) * DX / DY + i * 6 + 0.5), yy) end
end end
for x = 10, 50 do if x % 6 ~= 3 then darken(x, 27) end end

-- empty slot: same shape as the escaped piece; dark shadowed upper-left walls, lit lower-right wall
local slot = c:rect(22, 25, 29, 30):add(A.ell(25.5, 23.2, 1.9, 1.7)):add(A.ell(30.6, 27.5, 1.7, 1.9))
slot:each(function(x, y)
  local col = PU[1]
  if not slot:has(x, y + 1) or not slot:has(x + 1, y) then col = PU[4]
  elseif not slot:has(x, y + 2) or not slot:has(x + 2, y) then col = PU[2] end
  c:put(x, y, col, ptok)
end)
-- scuffed pale card corners
for _, p in ipairs{ { 9, 34 }, { 45, 34 }, { 10, 50 }, { 9 + DX, 33 - DY }, { 45 + DX, 33 - DY } } do c:put(p[1], p[2], CARD[4], tok) end
c:put(10, 34, CARD[3], tok) c:put(9, 35, CARD[3], tok)
-- lid rim highlight row (pop) and front label
for x = 11, 32 do if x % 7 ~= 0 then c:put(x, 34, PU[6], tok) end end
local lab = c:rrect(21, 41, 39, 46, 1)
local ltok = { r = { name = "label" } }
lab:each(function(x, y) c:put(x, y, (y == 46 or x == 39) and PAP[1] or ((y == 41 or x == 21) and PAP[3] or PAP[2]), ltok) end)
for x = 22, 39 do c:put(x, 47, PU[1], tok) end
for x = 23, 37 do if x ~= 30 then c:put(x, 43, "#5a459e", ltok) end end
for x = 23, 33 do c:put(x, 44, "#b9a2c8", ltok) end

-- quirk: the escaped piece stands against the front-left of the box (picture side out)
local PX, PY = 4, 38
local piece = c:rect(PX + 2, PY + 3, PX + 11, PY + 12)
piece:add(A.ell(PX + 6.5, PY + 1.6, 2.1, 2.0))            -- top knob
piece:add(A.ell(PX + 13.2, PY + 7.5, 2.0, 2.1))           -- right knob
piece:cut(A.ell(PX + 1.6, PY + 7.5, 1.6, 1.8))            -- left socket
-- ink separation where it overlaps the box
piece:grow(1):cut(piece):each(function(x, y) if c:get(x, y) and x > FX0 - 2 then c:put(x, y, A.INK) end end)
-- card thickness on the lower-right
local thick = piece:shift(1, 0):cut(piece)
thick:each(function(x, y) c:put(x, y, CARD[2], ltok) end)
local pn = X.pillow(piece, 1.8)
local qtok = { r = { name = "piece" } }
piece:each(function(x, y)
  local v = (y - PY) / 13
  local col = (v > 0.52 - 0.12 * sin((x - PX) * 0.6)) and HILL or SKY
  local n = pn[K(x, y)]
  local d = n[1] * X.L[1] + n[2] * X.L[2] + n[3] * X.L[3]
  local i = (d > 0.8) and 4 or ((d > 0.55) and 3 or 2)
  if col == SKY then i = min(3, max(2, i)) end
  c:put(x, y, col[i], qtok)
end)
c:put(PX + 5, PY + 1, A.CREAM, qtok) c:put(PX + 6, PY + 1, SKY[4], qtok)    -- pop on the knob
A.save(c, "ico-jigsaw-box")
