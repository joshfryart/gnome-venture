-- feast-spicepeak-thali (B30, Opus single pass). A round steel thali in 3/4 view: rolled bright rim, a concave
-- brushed well and a thin front lip. In the middle a rice "mountain": saffron biryani below a zigzag snow-line of
-- white rice, grain-flecked, cone-lit. Three slim steel katoris (yellow dal, red curry, green saag with paneer)
-- and a blistered papad sit around it. Material: steel bevel + specular streak + brushed rings, rice grain,
-- glossy curry pops, papad blisters; contact shadows under every bowl.
-- quirk: a red chili is planted on the summit like a climber's flag.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sqrt, max, min, sin, cos, pi, atan = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi, math.atan
local c = G.new("feast-spicepeak-thali")
local ST   = { "#34354f", "#565a74", "#80849c", "#a9adc0", "#d0d3df", "#eff0f5" }
local SAF  = { "#7a3b22", "#b05a22", "#d9822a", "#efa940", "#f8cd6a", "#fde9a8" }
local RICE = { "#8a7a72", "#b3a493", "#d6c8ae", "#ebe0c6", "#f7f0dc", "#fffbee" }
local DAL  = { "#7a4a1e", "#b8741e", "#e0a22c", "#f2c24a", "#fbe08a", "#fff3c4" }
local RED  = { "#5e1a2a", "#94242c", "#c83a2e", "#e85a3a", "#f78a5a", "#ffc09a" }
local SAAG = { "#1d3d2a", "#2c5e34", "#3f8240", "#5ea64a", "#86c45e", "#bfe38c" }
local PAP  = { "#7a4a26", "#b07a3c", "#d8a85c", "#ecc77a", "#f7e0a2", "#fff1cc" }
local CHI  = { "#5a1428", "#8e1e2c", "#c42a2e", "#e64234", "#ff7a52", "#ffb48a" }
local CREAM = "#fff4d6"

local CX, CY, RX, RY = 32, 41, 24, 12
local WX, WY = 21, 10
c:groundShadow(CX + 1, 54, 22, 2)

-- plate: front lip (thickness) first, then the top
local outer = HP.ellipse(CX, CY, RX, RY)
local lip = HP.ellipse(CX, CY + 2, RX, RY):cut(outer)
lip:each(function(x, y)
  local first = outer:has(x, y - 1)
  local i = first and 3 or 2
  if x < CX - 12 then i = i + 1 elseif x > CX + 13 then i = i - 1 end
  c:put(x, y, ST[i])
end)
local plateN = {}
local well = HP.ellipse(CX, CY, WX, WY)
outer:each(function(x, y)
  local ex, ey = (x - CX) / (RX + .5), (y - CY) / (RY + .5)
  local q = sqrt(ex * ex + ey * ey)
  local dl = sqrt(ex * ex + ey * ey * 0.6) + 1e-6
  local rx, ry = ex / dl, ey / dl
  local k = K(x, y)
  if well:has(x, y) then
    -- concave well: walls near the edge tilt inward, flat brushed floor
    local s = max(0, (q - 0.68) / 0.22) * 0.75
    plateN[k] = { G.norm(-rx * s, -ry * s - 0.35, 0.95) }
  else
    local qi = (WX + .5) / (RX + .5)
    local t = max(0, min(1, (q - qi) / (1 - qi)))
    local a = (t - 0.5) * pi * 0.95
    plateN[k] = { G.norm(rx * sin(a), ry * sin(a) - 0.3 * cos(a), cos(a)) }
  end
end)
local pidx = G.shade(c, outer, plateN, ST, { amb = 0.1, wrap = 0.3, cuts = { 0.22, 0.4, 0.58, 0.76, 0.9 } })
-- brushed rings in the well (anisotropic glints upper-left and lower-right)
well:each(function(x, y)
  local ex, ey = (x - CX) / (WX + .5), (y - CY) / (WY + .5)
  local q = sqrt(ex * ex + ey * ey)
  local ang = atan(ey, ex)
  local d = abs(sin(ang + pi / 4))
  if ((q > 0.44 and q < 0.5) or (q > 0.24 and q < 0.29)) and d < 0.42 then
    local i = pidx[K(x, y)] or 4
    c:put(x, y, ST[min(6, i + 1)])
  end
end)
-- crisp inner rim line (where the rolled rim drops into the well), dark at the back, bright at the front
HP.ellipse(CX, CY, WX + 1, WY + 1):cut(well):each(function(x, y)
  if y < CY - 2 then c:put(x, y, ST[3]) elseif y > CY + 3 then c:put(x, y, ST[5]) end
end)
-- specular streak on the upper-left rim + glint
for _, p in ipairs{ { 13, 34 }, { 14, 33 }, { 15, 32 }, { 16, 32 } } do c:put(p[1], p[2], ST[6]) end
c:put(14, 33, CREAM)

-- katori (steel bowl) with curry
local plateTop = outer:copy()
local function katori(bx, by, CU, garnish)
  local body = HP.ellipse(bx, by + 2, 5, 2.5):add(HP.rect(bx - 5, by, bx + 5, by + 2))
  -- contact shadow on the plate (lower-right)
  HP.ellipse(bx + 1, by + 3, 6, 2.5):cut(body):each(function(x, y)
    if plateTop:has(x, y) and y >= by + 1 then c:put(x, y, ST[2]) end end)
  G.shade(c, body, G.vcylN(body, bx - 5, bx + 5, 0.25), ST, { amb = 0.08, wrap = 0.3 })
  -- dark foot row
  body:each(function(x, y) if not body:has(x, y + 1) and abs(x - bx) < 4 then c:put(x, y, ST[2]) end end)
  local rim = HP.ellipse(bx, by, 5, 1.6)
  rim:each(function(x, y)
    local i
    if y < by then i = x > bx + 2 and 4 or 5 else i = x < bx - 1 and 6 or (x > bx + 2 and 4 or 5) end
    c:put(x, y, ST[i])
  end)
  local inner = HP.ellipse(bx, by, 3.6, 0.8)
  inner:each(function(x, y)
    local i = 4
    if y < by then i = 3 end
    if x >= bx + 3 then i = 3 end
    c:put(x, y, CU[i])
  end)
  c:put(bx - 2, by, CU[6]) c:put(bx - 1, by, CU[6])
  -- far inner wall in shadow
  c:put(bx - 2, by - 1, ST[2]) c:put(bx - 1, by - 1, ST[2]) c:put(bx, by - 1, ST[2]) c:put(bx + 1, by - 1, ST[3])
  if garnish then garnish(bx, by) end
  return body:add(rim)
end

-- back bowls
katori(21, 34, DAL, function(bx, by) c:put(bx + 1, by, "#fff3d6") c:put(bx + 2, by + 1, CHI[3]) c:put(bx - 3, by + 1, SAAG[4]) end)
katori(43, 33, SAAG, function(bx, by) c:put(bx + 1, by, "#fff4e0") c:put(bx + 1, by + 1, "#e8dcc0") c:put(bx - 3, by + 1, "#fff4e0") end)

-- rice mountain
local AX, TOP, RB = 32, 19, 45
local rice, rn = HP.mask(), {}
local function hwL(t) return 0.4 + 8.6 * t ^ 0.8 end
local function hwR(t) return 0.4 + 9.0 * t ^ 1.05 + 1.3 * sin(t * 7.5) * t end
for y = TOP, RB do
  local t = (y - TOP) / (RB - TOP)
  for x = floor(AX - hwL(t) - 1), floor(AX + hwR(t) + 1) do
    local s = x + .5 - AX
    if s >= -hwL(t) and s <= hwR(t) then rice:set(x, y) end
  end
end
HP.ellipse(AX + 0.5, RB, 9.2, 2.5):each(function(x, y) if y >= RB then rice:set(x, y) end end)
rice:each(function(x, y)
  local t = max(0, min(1, (y - TOP) / (RB - TOP)))
  local s = x + .5 - AX
  local w = s < 0 and hwL(t) or hwR(t)
  local sn = max(-0.95, min(0.95, s / (w + 0.8)))
  if y > RB then sn = sn * 0.8 end
  rn[K(x, y)] = { G.norm(sn * 0.95, -0.42 + (y > RB and 0.5 or 0), 0.75) }
end)
local bias = {}
rice:each(function(x, y)
  local h = G.hash(x, y, 7)
  if h < 0.13 then bias[K(x, y)] = -1 elseif h > 0.9 then bias[K(x, y)] = 1 end
end)
-- contact shadow on the plate under the rice
HP.ellipse(AX + 2, RB + 1, 10, 2.5):cut(rice):each(function(x, y) if plateTop:has(x, y) and y >= RB then c:put(x, y, ST[2]) end end)
local v = X.light(rn, { amb = 0.1, wrap = 0.3 })
local function snowY(x) return 28 + abs((x % 6) - 3) end
rice:each(function(x, y)
  local k = K(x, y)
  local val = v[k]
  local i = 1
  for j, tt in ipairs{ 0.22, 0.4, 0.56, 0.72, 0.86 } do if val >= tt then i = j + 1 end end
  i = max(1, min(6, i + (bias[k] or 0)))
  local R = y < snowY(x) and RICE or SAF
  if y == snowY(x) and i <= 3 then R = SAF end
  c:put(x, y, R[i], { r = { name = "rice" } })
end)
-- a few stray saffron grains above the line and white grains below
for _, p in ipairs{ { 30, 26 }, { 35, 27 }, { 27, 36 }, { 31, 39 }, { 36, 37 }, { 29, 42 } } do
  if rice:has(p[1], p[2]) then c:put(p[1], p[2], p[2] < 30 and SAF[5] or RICE[5]) end end
-- fried onion and a cashew on the slope
for _, p in ipairs{ { 34, 41 }, { 35, 41 }, { 26, 40 } } do c:put(p[1], p[2], SAF[1]) end
c:put(37, 43, "#f2dcae") c:put(38, 43, "#f2dcae") c:put(38, 44, "#c8a87a")

-- quirk: chili planted on the summit (tip in the rice, calyx up)
local chm, chT = G.sweep({ { 32, 21 }, { 32.5, 17 }, { 34, 14 }, { 36, 12 } }, function(t) return 0.4 + 1.3 * t ^ 0.6 end, 60)
local chidx = G.pillow(c, chm, CHI, 1.4, { amb = 0.12 })
c:put(33, 16, CHI[6]) c:put(33, 17, CREAM)
-- green calyx + curly stalk
for _, p in ipairs{ { 35, 10 }, { 36, 10 }, { 37, 11 }, { 36, 11 }, { 35, 11 } } do c:put(p[1], p[2], SAAG[4]) end
c:put(37, 11, SAAG[3]) c:put(38, 11, SAAG[2])
for _, p in ipairs{ { 36, 9 }, { 37, 8 }, { 38, 8 } } do c:put(p[1], p[2], SAAG[3]) end
c:put(36, 9, SAAG[5])

-- front bowl
katori(44, 45, RED, function(bx, by) c:put(bx, by, "#fff1d8") c:put(bx + 1, by, "#fff1d8") c:put(bx - 3, by, SAAG[5]) end)

-- papad (blistered crisp disc) at front-left, leaning flat on the plate
local pap = HP.ellipse(19, 46, 6.5, 2.6)
pap:each(function(x, y) if G.hash(x, y, 3) < 0.35 and not HP.ellipse(19, 46, 5.4, 1.8):has(x, y) then pap.s[K(x, y)] = nil end end)
HP.ellipse(20, 47.5, 6.5, 2.5):cut(pap):each(function(x, y) if plateTop:has(x, y) and y >= 47 then c:put(x, y, ST[2]) end end)
local pidx2 = G.pillow(c, pap, PAP, 1.5, { amb = 0.15, wrap = 0.35 })
pap:each(function(x, y)
  local h = G.hash(x, y, 11)
  if h < 0.12 then c:put(x, y, PAP[2]) elseif h > 0.9 then c:put(x, y, PAP[6]) end
end)
c:put(16, 45, "#3a2a2a") c:put(22, 46, "#3a2a2a") c:put(19, 47, "#3a2a2a")

G.save(c, "feast-spicepeak-thali")
