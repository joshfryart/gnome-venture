-- ico-cup (final, Opus). A winner's trophy cup: a tulip bowl with an open rim, two slim loop handles, a thin stem
-- with a knop, a flared foot, standing on a walnut plinth with a brass plate; 2-tone ground shadow under it.
-- Material: polished gold, per-pixel cylinder normals plus a mirror band (bright streak left of centre, dark
-- horizon band right of centre), bright lip on the rim and a dark inside with a lit far wall, a raised moulded ring
-- round the bowl, AO where the stem meets bowl and foot; walnut with grain and a lit top bevel.
-- quirk: a blue prize ribbon is tied to the left handle, its two tails hanging down.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi, atan = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi, math.atan
local c = A.new("ico-cup")
local GOLD = { "#5a2c1e", "#924d1f", "#c77c22", "#eeac2e", "#ffd457", "#fff0a6" }
local WD   = { "#2c1820", "#4a2a26", "#6c3e2c", "#8f5a38", "#b47c4c", "#d8a46a" }
local RIB  = { "#1c2a5e", "#28449a", "#3a78c8", "#6ab4ec", "#b8e4ff" }
local CREAM = "#fff4d6"
local tG, tW, tR = A.tok("gold"), A.tok("wood"), A.tok("ribbon")
local CX = 31.5

c:groundShadow(31.5, 53, 15, 2)

-- profile of the turned gold body: half-width per row
local function hw(y)
  if y < 12 then return nil end
  if y <= 33 then local t = (y - 12) / 21 return 3 + 9.6 * (1 - t ^ 2.2) end   -- tulip bowl
  if y <= 35 then return 1.6 end                                              -- neck
  if y <= 38 then return 2.6 end                                              -- knop
  if y <= 40 then return 1.6 end                                              -- stem
  if y <= 44 then return 2.5 + (y - 40) * 1.8 end                             -- flared foot
  return nil
end
local body = HP.mask()
for y = 12, 44 do local w = hw(y) for x = 0, 63 do if abs(x - CX) <= w then body:set(x, y) end end end
-- rim ellipse on top (open mouth)
local RX, RY, RCY = 12.6, 3.6, 12
local rim = A.ell(CX, RCY, RX, RY)
body:add(rim)
local mouth = A.ell(CX, RCY - 0.2, RX - 1.8, RY - 1.5)

-- handles: thick loops on both sides (3 px), drawn first so the bowl sits over their roots
local hmask = HP.mask()
for _, sgn in ipairs{ -1, 1 } do
  local hx, hy = CX + sgn * 11.5, 21
  local loop = A.ring(hx, hy, 3.2, 5.6)
  loop:each(function(x, y) if (x - hx) * sgn > -1.5 then hmask:set(x, y) end end)
end
hmask:cut(body)
local hn = X.pillow(hmask, 1.6)
local hb = {}
X.ao(hb, hmask, body, 1, -1)
A.shade(c, hmask, hn, GOLD, { bias = hb, tok = tG, amb = 0.08, wrap = 0.25, tilt = { CX, 24, 22, 0.15 }, cuts = { 0.22, 0.38, 0.54, 0.72, 0.88 } })

-- body normals: cylinder across each row, plus curvature of the bowl
local bn = {}
body:each(function(x, y)
  local w = hw(y) or RX
  if rim:has(x, y) then w = RX end
  local q = max(-0.96, min(0.96, (x - CX) / (w + 0.5)))
  local ny = 0
  if y <= 33 then ny = 0.35 * ((y - 12) / 21) end            -- bowl turns under toward the stem
  if y > 40 then ny = -0.45 end                                -- foot faces up
  if y >= 35 and y <= 38 then ny = (y - 36.5) * 0.35 end      -- round knop
  bn[K(x, y)] = { A.norm(q, ny, sqrt(1 - q * q)) }
end)
local bias = {}
-- mirror band on the polished bowl
body:each(function(x, y) local k = K(x, y) local w = hw(y)
  if w and y > 14 and y <= 33 then
    local q = (x - CX) / (w + 0.5)
    if q > -0.66 and q < -0.42 then bias[k] = 1 end
    if q > 0.18 and q < 0.42 then bias[k] = -1 end
  end
  -- AO where the bowl narrows into the neck and where the stem meets the foot
  if y == 33 or y == 34 or y == 39 or y == 40 then bias[k] = (bias[k] or 0) - 1 end
end)
local idx = A.shade(c, body, bn, GOLD, { bias = bias, tok = tG, amb = 0.06, wrap = 0.22, cuts = { 0.22, 0.38, 0.54, 0.72, 0.88 } })
-- raised moulded ring round the bowl: dark groove row then lit row (follows the bowl's curve)
for x = 0, 63 do
  local w = hw(27) if abs(x - CX) <= w then
    local q = (x - CX) / w
    local y = 27 + floor(1.2 * (1 - q * q) + 0.5)
    A.step(c, idx, GOLD, x, y, -2, tG)
    if q < 0.2 then A.step(c, idx, GOLD, x, y + 1, 1, tG) end
  end
end
-- open mouth: dark inside, lit far wall at the bottom of the opening, bright front lip
mouth:each(function(x, y)
  local lower = y > RCY
  c:put(x, y, lower and GOLD[2] or GOLD[1], tG)
  if lower and (x - CX) < -3 then c:put(x, y, GOLD[3], tG) end
end)
rim:each(function(x, y) if not mouth:has(x, y) then
  local q = (x - CX) / RX
  c:put(x, y, (y >= RCY) and (q < 0.3 and GOLD[6] or GOLD[4]) or (q < -0.2 and GOLD[5] or GOLD[3]), tG)
end end)
-- shade under the front lip (the rim overhangs the bowl a hair)
for x = 0, 63 do if body:has(x, RCY + RY + 1) and not rim:has(x, RCY + RY + 1) then A.step(c, idx, GOLD, x, RCY + RY + 1, -1, tG) end end
-- specular: cream 2x1 glint on the streak + one small pop on the knop
c:put(23, 18, CREAM, tG) c:put(23, 19, CREAM, tG) c:put(23, 20, GOLD[6], tG)
c:put(30, 36, GOLD[6], tG)

-- walnut plinth with a brass plate
local plinth = c:rrect(19, 45, 44, 52, 1)
local pn = X.pillow(plinth, 2)
local pb = {}
plinth:each(function(x, y) if y == 45 and abs(x - CX) <= 9 then pb[K(x, y)] = -2 end end)   -- foot's contact shadow
local pidx = A.shade(c, plinth, pn, WD, { bias = pb, tok = tW, amb = 0.08, wrap = 0.25, tilt = { CX, 48, 14, 0.2 }, cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 } })
plinth:each(function(x, y)
  local w = y + 0.5 * sin(x * 0.5 + y * 1.3)
  if abs(w - 50.4) < 0.3 and X.hash(x, y, 5) > 0.2 then A.step(c, pidx, WD, x, y, -1, tW) end
end)
for x = 20, 30 do if plinth:has(x, 45) and not (abs(x - CX) <= 9) then c:put(x, 45, WD[6], tW) end end
-- plate: 3 px tall brass with a lit top edge and an engraved line
local plate = c:rect(26, 47, 37, 50)
local pln = X.pillow(plate, 1.2)
A.shade(c, plate, pln, GOLD, { tok = tG, amb = 0.1, wrap = 0.25, cuts = { 0.22, 0.38, 0.54, 0.72, 0.88 } })
for x = 28, 35 do c:put(x, 49, GOLD[2], tG) end

-- quirk: blue prize ribbon tied on the left handle, two tails hanging
do
  local rows = {
    "lL..Ll",
    "LlKKld",
    "ldKKdd",
    ".lLd..",
    ".lLdd.",
    "lL..d.",
    "lL..dd",
    "Ld...d",
  }
  local pal = { l = RIB[4], L = RIB[5], K = RIB[2], d = RIB[3] }
  A.map(c, rows, 13, 25, pal, tR)
end
A.save(c, "ico-cup")
