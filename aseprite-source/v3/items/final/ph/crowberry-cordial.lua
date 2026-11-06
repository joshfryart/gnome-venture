-- crowberry-cordial (final, Opus single pass). A slim, tall cordial bottle: long neck, sloped shoulders, cork
-- stopper, standing on a 2-tone ground shadow. Deep blue-violet cordial seen through glass, filled to the shoulder.
-- Material: per-pixel cylinder light on the liquid (6 tones), glass wall rim (bright on the lit edge, dark on the
-- shade edge), pale empty glass above the meniscus, long specular streak + short second streak, magenta light
-- transmitted through the liquid at the lower right, thick pale glass foot; cork with pores and pale end grain;
-- twisted twine round the neck with a bow; a wrap-round paper label following the curve with a berry stamp.
-- quirk: one fat drip of cordial has run down from the lip over the twine.
local NAME = "crowberry-cordial"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.pi
local c = A.new(NAME)
local LIQ   = { "#1a0e24", "#2b143e", "#45205c", "#632a76", "#86398c", "#b25ca8" }
local AIR   = { "#55708c", "#86a9bc", "#b7dade", "#e2f5ef" }
local CORK  = { "#4a2e22", "#6e4630", "#946240", "#b88452", "#d6a96c", "#f0cf94" }
local PAPER = { "#7a5a4a", "#b08c6e", "#d8bc92", "#eedcb2", "#fbf0d2" }
local TW    = { "#6b3f22", "#a8692e", "#dca246", "#f5d27a" }
local GLOW, SPEC, WALLHI, WALLLO = "#d878b8", "#f6eef8", "#cfe6ea", "#3b2c5a"
local CX = 32

-- profile: half width per row
local function hw(y)
  if y < 8 then return nil end
  if y <= 12 then return 3 + ((y <= 9) and 0.6 or 0) end      -- cork
  if y <= 14 then return 4.2 end                              -- lip
  if y <= 24 then return 3 end                                -- neck
  if y <= 33 then local f = (y - 24) / 9 return 3 + 6.2 * sin(f * pi / 2) ^ 1.3 end -- shoulder
  if y <= 53 then return 9.2 end
  if y <= 56 then return 9.2 - (y - 53) * 0.9 end
  return nil
end
c:groundShadow(CX + 1, 57, 15, 2)
local bottle, cork, glass, n = HP.mask(), HP.mask(), HP.mask(), {}
for y = 8, 56 do local w = hw(y)
  for x = floor(CX - w + 0.5), floor(CX + w - 0.5) + 1 do
    local dx = (x - CX + 0.5) / (w + 0.4)
    local ny = 0
    if y > 24 and y <= 33 then ny = -0.55 elseif y >= 54 then ny = 0.5 elseif y >= 13 and y <= 14 and y == 13 then ny = -0.6 end
    local nz = sqrt(max(0.05, 1 - dx * dx))
    local l = sqrt(dx * dx + ny * ny + nz * nz)
    n[K(x, y)] = { dx / l, ny / l, nz / l }
    if y <= 12 then cork:set(x, y) else glass:set(x, y) end
    bottle:set(x, y)
  end
end
local LEVEL = 28
-- glass interior split into air (above level) and liquid
local liq, air = HP.mask(), HP.mask()
glass:each(function(x, y) if y >= LEVEL and y <= 53 then liq:set(x, y) elseif y < LEVEL and y > 14 then air:set(x, y) end end)
local foot = HP.mask() glass:each(function(x, y) if y > 53 then foot:set(x, y) end end)
local lip = HP.mask() glass:each(function(x, y) if y <= 14 then lip:set(x, y) end end)

local gtok, ltok = { r = { name = "glass" } }, { r = { name = "liquid" } }
local lidx = A.shade(c, liq, n, LIQ, { tok = ltok, amb = 0.05, wrap = 0.3, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 } })
A.shade(c, air, n, AIR, { tok = gtok, amb = 0.25, wrap = 0.4, cuts = { 0.3, 0.55, 0.8 } })
A.shade(c, lip, n, AIR, { tok = gtok, amb = 0.3, wrap = 0.4, cuts = { 0.25, 0.5, 0.75 } })
A.shade(c, foot, n, { "#3a3060", "#5e5a8a", "#8fa0bc", "#c2dade" }, { tok = gtok, amb = 0.2, wrap = 0.4, cuts = { 0.3, 0.55, 0.8 } })
-- transmitted glow lower right, inside the liquid
liq:each(function(x, y) local dx = x - CX
  if y >= 44 and y <= 53 and dx >= 2 and dx <= 6 then
    local d = sqrt(((dx - 4) / 2.6) ^ 2 + ((y - 50) / 3.6) ^ 2)
    if d < 0.75 then c:put(x, y, GLOW, ltok) elseif d < 1.05 then c:put(x, y, LIQ[5], ltok) end end end)
-- meniscus: bright row with a darker row under
for x = CX - 6, CX + 7 do
  if liq:has(x, LEVEL) then c:put(x, LEVEL, (x < CX + 3) and LIQ[6] or LIQ[5], ltok) end
  if liq:has(x, LEVEL + 1) and x > CX - 5 then c:put(x, LEVEL + 1, LIQ[2], ltok) end
end
-- glass walls: 1 px column on each side of the liquid / air
for y = 15, 53 do local w = hw(y)
  local xl, xr = floor(CX - w + 0.5), floor(CX + w - 0.5) + 1
  c:put(xl, y, y >= LEVEL and WALLHI or AIR[4], gtok)
  c:put(xr, y, y >= LEVEL and WALLLO or AIR[1], gtok)
end
-- specular streaks: long one on the lit side, a short one beside it, a dot on the shoulder
for y = 34, 51 do if y ~= 45 and y ~= 46 then c:put(CX - 6, y, (y < 40) and SPEC or AIR[3], gtok) end end
for y = 36, 41 do c:put(CX - 4, y, AIR[2], gtok) end
c:put(CX - 5, 30, SPEC, gtok) c:put(CX - 4, 29, AIR[4], gtok) c:put(CX - 2, 17, AIR[4], gtok) c:put(CX - 2, 18, AIR[4], gtok)

-- label: wraps round the body, rows 38..47, curved bottom edge, deckled right end
local lab = HP.mask()
for y = 38, 47 do for x = CX - 8, CX + 8 do
  local dx = (x - CX) / 9.5
  local bot = 46 + floor(1.6 * (1 - dx * dx) + 0.5)
  local top = 37 + floor(1.6 * (1 - dx * dx) + 0.5)
  if y >= top and y <= bot and glass:has(x, y) then lab:set(x, y) end
end end
local ptok = { r = { name = "label" } }
local pidx = A.shade(c, lab, n, PAPER, { tok = ptok, amb = 0.2, wrap = 0.35, cuts = { 0.25, 0.45, 0.65, 0.85 } })
-- fine paper fibre and a berry stamp (three dots + twig)
lab:each(function(x, y) local k = K(x, y) if X.hash(x, y, 3) < 0.07 and pidx[k] >= 3 then c:put(x, y, PAPER[pidx[k] - 1], ptok) end end)
for _, q in ipairs{ { -2, 42, LIQ[3] }, { -1, 42, LIQ[2] }, { -2, 41, LIQ[4] }, { 1, 43, LIQ[3] }, { 2, 43, LIQ[2] }, { 1, 42, LIQ[4] },
                    { 0, 40, "#4f7a42" }, { 1, 39, "#4f7a42" }, { -1, 40, "#2f5a3a" }, { 3, 41, LIQ[3] }, { 3, 40, LIQ[4] } } do
  c:put(CX + q[1], q[2], q[3], ptok) end
-- label top and bottom shadow edge on liquid (AO)
lab:each(function(x, y) if not lab:has(x, y + 1) and liq:has(x, y + 1) then c:put(x, y + 1, LIQ[1], ltok) end end)

-- cork: pores, pale end grain on top, dark rim where it enters the lip
local ctok = { r = { name = "cork" } }
local cidx = A.shade(c, cork, n, CORK, { tok = ctok, amb = 0.12, wrap = 0.3 })
cork:each(function(x, y) local k = K(x, y)
  if y == 8 then c:put(x, y, (x < CX + 2) and CORK[6] or CORK[5], ctok)
  elseif y == 12 then c:put(x, y, CORK[2], ctok)
  elseif X.hash(x, y, 5) < 0.2 then c:put(x, y, CORK[max(1, cidx[k] - 2)], ctok) end end)
c:put(CX - 1, 8, CORK[4], ctok) c:put(CX + 1, 9, CORK[4], ctok)

-- twine: three twisted wraps round the neck (rows 19..21), bow ends hanging on the right
local ttok = { r = { name = "twine" } }
for y = 19, 21 do for x = CX - 4, CX + 4 do
  if (x + y) % 3 == 0 then c:put(x, y, TW[1], ttok)
  else local dx = (x - CX) / 4 c:put(x, y, dx < -0.3 and TW[4] or (dx < 0.4 and TW[3] or TW[2]), ttok) end
end end
-- bow: two small loops and two tails
A.map(c, {
  ".aab",
  "acdb",
  "abb.",
  ".b.b",
  ".b..b",
  "b...b",
}, CX + 4, 18, { a = TW[3], b = TW[2], c = TW[1], d = TW[4] }, ttok)

-- quirk: a drip running from the lip down over the twine
local DR = { { CX - 2, 15, 4 }, { CX - 2, 16, 4 }, { CX - 2, 17, 5 }, { CX - 2, 18, 4 }, { CX - 2, 19, 4 }, { CX - 2, 20, 4 },
             { CX - 2, 21, 3 }, { CX - 2, 22, 4 }, { CX - 3, 22, 5 }, { CX - 2, 23, 3 }, { CX - 3, 23, 4 }, { CX - 3, 21, 4 } }
for _, q in ipairs(DR) do c:put(q[1], q[2], LIQ[q[3]], ltok) end
c:put(CX - 3, 22, LIQ[6], ltok)
-- lip ring stain
c:put(CX - 2, 14, LIQ[4], ltok) c:put(CX - 1, 14, LIQ[3], ltok)

A.save(c, NAME)
