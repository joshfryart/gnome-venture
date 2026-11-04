-- cardboard-sheet (final, Opus single pass). A flat sheet of kraft corrugated board seen from above at a slight tilt:
-- lit top-left bevel, a fold score across it (dark valley + lit lip), faint flute ribs showing through the liner,
-- fibre flecks, a 4 px front edge showing liner / wavy flute / liner in section, a shaded right side, and along the
-- right the top liner is torn away (pale torn fibre edge, AO under it) baring the ridged flutes.
-- quirk: a faint coffee-cup ring stain, broken where the cup was lifted off at an angle.
local NAME = "cardboard-sheet"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new(NAME)

local KR = { "#4a2a20", "#76482e", "#a06a3e", "#c48c52", "#dcab6c", "#f0cb90" }
local FIB = "#f8e2b4"
local STAIN = "#9a6440"

-- face: TL + a*U + b*V
local TLx, TLy = 9, 16
local Ux, Uy = 42, -5
local Vx, Vy = 4, 32
local det = Ux * Vy - Uy * Vx
local function ab(x, y) local dx, dy = x + 0.5 - (TLx + 0.5), y + 0.5 - (TLy + 0.5)
  return (dx * Vy - dy * Vx) / det, (Ux * dy - Uy * dx) / det end
local face, FA, FB = HP.mask(), {}, {}
for y = 0, 63 do for x = 0, 63 do local a, b = ab(x, y)
  if a >= 0 and a <= 1 and b >= 0 and b <= 1 then face:set(x, y) FA[K(x, y)], FB[K(x, y)] = a, b end end end

-- edges: front (bottom) 4 rows, right side 2 cols
local tok = A.tok("board")
local etok = A.tok("edge")
local front, side = {}, {}
for d = 1, 4 do face:shift(0, d):each(function(x, y) local k = K(x, y)
  if not face:has(x, y) and not front[k] then front[k] = d end end) end
for d = 1, 2 do face:shift(d, 0):each(function(x, y) local k = K(x, y)
  if not face:has(x, y) and not front[k] and not side[k] then side[k] = d end end) end
for k, d in pairs(front) do local x, y = k % 1024 - 256, k // 1024 - 256
  local col
  if d == 1 then col = KR[4]
  elseif d == 4 then col = KR[2]
  else
    local ph = (x + (d == 3 and 2 or 0)) % 4
    col = (ph < 2) and KR[3] or KR[1]                -- wave crest vs. dark hollow
  end
  c:put(x, y, col, etok)
end
for k, d in pairs(side) do local x, y = k % 1024 - 256, k // 1024 - 256
  if not front[k] then c:put(x, y, (d == 1) and KR[3] or ((y % 4 < 2) and KR[2] or KR[1]), etok) end end

-- torn-away liner strip along the right edge
local Wpx, Hpx = 42, 32
local function tearA(b) local q = floor(b * Hpx / 2)
  return 1 - (6 + 4 * X.hash(q, 3, 11) + 3 * math.sin(b * 6)) / Wpx end
-- face tone
face:each(function(x, y) local k = K(x, y)
  local a, b = FA[k], FB[k]
  local px, py = a * Wpx, b * Hpx
  local i = 4
  if a + b < 0.42 then i = 5 elseif a + b > 1.5 then i = 3 end
  if py < 1 or px < 1 then i = 6 end                                     -- lit bevel on the top/left rim
  if px > Wpx - 1 or py > Hpx - 1 then i = 3 end                          -- slight rounding on the far rims
  if (floor(px) % 5 == 2) and i == 4 and py > 2 and py < Hpx - 2 then i = 4 - 0 end
  local col = KR[i]
  if floor(px) % 5 == 2 and py > 2 and py < Hpx - 2 and i >= 4 then col = KR[i - 1] == KR[3] and "#d09a5e" or "#e6bb7c" end -- faint flute ribs
  local h = X.hash(x, y, 4)
  if h > 0.94 and i >= 3 and i <= 5 then col = KR[i + 1] elseif h < 0.04 and i >= 3 then col = KR[i - 1] end -- fibre flecks
  c:put(x, y, col, tok)
end)
-- fold score across the sheet (along U at b = 0.36): dark valley with a lit lip below
face:each(function(x, y) local k = K(x, y)
  local py = FB[k] * Hpx
  if FA[k] * Wpx > 1 and FA[k] < 0.98 then
    if abs(py - 11.5) < 0.5 then c:put(x, y, KR[2], tok)
    elseif abs(py - 12.5) < 0.5 then c:put(x, y, KR[6], tok) end
  end
end)
-- quirk: coffee ring stain (ellipse in face space), gap where the cup was lifted
face:each(function(x, y) local k = K(x, y)
  local px, py = FA[k] * Wpx - 14, FB[k] * Hpx - 22
  local r = sqrt(px * px + (py * 1.15)^2)
  if abs(r - 5.6) < 0.55 and not (px > 2 and py < -2) then c:put(x, y, STAIN, tok) end
  if abs(r - 4.6) < 0.4 and px < -2 and py > 1 then c:put(x, y, "#b47c4c", tok) end   -- inner tide line, lower-left only
end)
-- torn region: flutes exposed
face:each(function(x, y) local k = K(x, y)
  local a, b = FA[k], FB[k]
  local ta = tearA(b)
  if a > ta and b > 0.03 then
    local ph = floor(a * Wpx) % 3
    local col = (ph == 0) and KR[5] or ((ph == 1) and KR[3] or KR[2])
    if a < ta + 1.3 / Wpx then col = KR[1] end                 -- AO under the torn liner lip
    c:put(x, y, col, tok)
  elseif a > ta - 1 / Wpx and b > 0.03 then
    c:put(x, y, FIB, tok)                                      -- pale torn fibre edge
  end
end)

A.save(c, NAME)
