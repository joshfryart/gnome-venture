-- ramson-pesto (final, Sonnet high). A tall slim glass jar of wild-garlic pesto: thick glass with a bright rim and
-- cool bounce light, chunky pesto (leaf flecks, cream pine nuts, an air bubble) under a golden oil meniscus, a knurled
-- gold screw lid, hemp twine with a little bow round the neck, and a cream paper label printed with a ramson leaf.
-- quirk: a glossy dribble of pesto has run down the glass from under the lid.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("ramson-pesto")
local GLASS = { "#2c5560", "#41767c", "#68a6a6", "#9bd0c6", "#cdeadb", "#f4fff2" }
local PES   = { "#16301f", "#244d2a", "#37702f", "#538f3a", "#7db04a", "#aed06b" }
local GOLD  = { "#8f4a1f", "#c06a22", "#e0902a", "#f5b82e", "#ffd860", "#fff0a8" }
local OIL   = { "#7a7a22", "#a89c2e", "#cfc04a", "#eadf7a", "#fff6b0" }
local PAPER = { "#a68a66", "#c9b088", "#e6d3a8", "#f6e8c4", "#fffaf0" }
local TWINE = { "#6b4a2a", "#9c7440", "#c9a05a", "#e8c880" }
local LEAFG = { "#1c4a30", "#2c6a3c", "#44883e", "#68a84c", "#92c866", "#c4e592" }
local NUT   = { "#a8803c", "#d4aa5c", "#f0d890", "#fff2c0" }
local CX = 32
local function hw(y)
  if y <= 18 then return 8 end
  local sh = { [19] = 8, [20] = 9, [21] = 9, [22] = 10, [23] = 10 }
  if sh[y] then return sh[y] end
  if y <= 52 then return 11 end
  if y == 53 then return 10 end
  return 8
end
c:groundShadow(CX, 55, 13, 2)

-- glass jar
local jar, inner = HP.mask(), HP.mask()
for y = 16, 54 do local h = hw(y)
  for x = CX - h, CX + h do jar:set(x, y)
    if x > CX - h and x < CX + h - 1 and y <= 52 then inner:set(x, y) end end end
jar:each(function(x, y)
  local h = hw(y)
  local i
  if y == 54 then i = 2
  elseif y == 53 then i = 3
  elseif not inner:has(x, y) then
    if x == CX - h then i = 4 elseif x == CX + h then i = 2 else i = 3 end
  else
    local t = (x - CX) / h
    i = (t > 0.55) and 4 or 5
    if x == CX - h + 1 then i = 5 end
  end
  c:put(x, y, GLASS[i])
end)
for x = CX - 6, CX - 3 do c:put(x, 53, GLASS[5]) end          -- thick base catches light
for x = CX + 5, CX + 8 do c:put(x, 53, GLASS[2]) end
c:put(CX + 9, 52, GLASS[4]) c:put(CX + 8, 52, GLASS[4])        -- cool bounce in the corner

-- pesto fill under an oil meniscus
local pm = HP.mask()
inner:each(function(x, y) if y >= 25 then pm:set(x, y) end end)
local n = {}
pm:each(function(x, y) local t = max(-0.95, min(0.95, (x - CX) / 11)) n[K(x, y)] = { t, 0, sqrt(1 - t * t) } end)
local bias = {}
pm:each(function(x, y) local k = K(x, y)
  local r = X.hash(floor(x / 2), y, 5)
  if r < 0.11 then bias[k] = -1 elseif r > 0.88 then bias[k] = 1 end
  local r2 = X.hash(x, y, 9)
  if r2 > 0.95 then bias[k] = (bias[k] or 0) + 1 end
end)
local idx = A.shade(c, pm, n, PES, { amb = 0.12, wrap = 0.3, bias = bias })
pm:each(function(x, y)                                    -- oil on top
  if y == 25 then c:put(x, y, OIL[4])
  elseif y == 26 then c:put(x, y, OIL[3])
  elseif y == 27 and X.hash(x, y, 2) > 0.45 then c:put(x, y, OIL[2]) end
end)
for x = CX - 8, CX - 4 do c:put(x, 25, OIL[5]) end         -- meniscus glint
for x = CX - 10, CX + 9 do if X.hash(x, 27, 6) > 0.7 then c:put(x, 28, PES[5]) end end
-- pine nuts pressed against the glass
local function nut(x, y)
  c:put(x, y, NUT[3]) c:put(x + 1, y, NUT[2]) c:put(x, y + 1, NUT[2]) c:put(x + 1, y + 1, NUT[1]) c:put(x - 1, y, NUT[4])
end
nut(24, 31) nut(38, 30) nut(27, 49) nut(36, 50) nut(23, 41)
-- air bubble
for _, p in ipairs{ { 40, 38 }, { 41, 38 }, { 40, 39 } } do c:put(p[1], p[2], PES[6]) end
c:put(41, 39, PES[2])
-- glass streak (bright) + cool streak on the right
for y = 27, 49 do if y % 8 ~= 0 then c:put(CX - 9, y, y < 36 and GLASS[6] or GLASS[5]) end end
for y = 30, 48 do if y % 5 ~= 0 then c:put(CX + 8, y, GLASS[3]) end end
c:put(CX - 8, 27, GLASS[6])

-- paper label, wrapped round the jar
local lab = c:rect(25, 34, 39, 46)
local ln = {}
lab:each(function(x, y) local t = max(-0.95, min(0.95, (x - CX) / 11)) ln[K(x, y)] = { t, 0, sqrt(1 - t * t) } end)
A.shade(c, lab, ln, PAPER, { amb = 0.35, wrap = 0.6, cuts = { 0.3, 0.5, 0.7, 0.88 } })
for x = 25, 39 do c:put(x, 46, PAPER[2]) c:put(x, 34, PAPER[4]) end
c:put(39, 34, PAPER[5]) c:put(38, 34, PAPER[5]) c:put(39, 35, PAPER[1])  -- lifted corner
for x = 25, 39 do c:put(x, 47, PES[1]) end                  -- contact shadow under the label (inside jar)
-- ramson leaf print
local lm, lN, lT, lS = A.tornBlade(c, 28.5, 43, 31, 39.5, 36.5, 36.5, function(t)
  if t > 0.98 then return -1 end
  return max(0.5, 2.3 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.7) end,
  { ramp = LEAFG, veins = { 0.5, 0.7 }, sweep = 1.2, rib = 0.18, fold = 0.4 })
for x = 28, 30 do c:put(x, 45, "#8a6a48") end
for x = 32, 36 do c:put(x, 45, "#8a6a48") end
c:put(34, 45, PAPER[3])

-- gold screw lid, knurled
local lid = HP.mask()
for y = 9, 15 do local h = (y == 9) and 9 or 10 for x = CX - h, CX + h do lid:set(x, y) end end
local lnrm = {}
lid:each(function(x, y) local t = max(-0.95, min(0.95, (x - CX) / 11)) lnrm[K(x, y)] = { t, 0, sqrt(1 - t * t) } end)
local lidx = A.shade(c, lid, lnrm, GOLD, { amb = 0.2, wrap = 0.35, cuts = { 0.22, 0.4, 0.56, 0.72, 0.9 } })
lid:each(function(x, y)
  if y >= 10 and y <= 14 then
    local i = lidx[K(x, y)]
    if x % 2 == 0 then c:put(x, y, GOLD[max(1, i - 1)]) end
  end
end)
for x = CX - 9, CX + 9 do c:put(x, 15, (x < CX) and GOLD[2] or GOLD[1]) end
for x = CX - 8, CX + 8 do c:put(x, 9, (x < CX - 3) and GOLD[6] or GOLD[5]) end
for y = 10, 13 do c:put(CX - 7, y, GOLD[6]) c:put(CX - 8, y, GOLD[5]) end
c:put(CX + 9, 12, GOLD[1]) c:put(CX + 9, 11, GOLD[2])

-- twine on the neck with a bow
for y = 16, 18 do for x = CX - 8, CX + 8 do
  local i = 3
  if (x + y) % 3 == 0 then i = 2 end
  if x < CX - 3 then i = i + 1 elseif x > CX + 4 then i = i - 1 end
  if y == 18 then i = i - 1 end
  c:put(x, y, TWINE[max(1, min(4, i))])
end end
for x = CX - 8, CX + 8 do c:put(x, 16, TWINE[1]) end          -- AO under the lid
for _, p in ipairs{ { 28, 16 }, { 29, 16 }, { 28, 17 }, { 29, 17 }, { 28, 18 }, { 29, 18 }, { 30, 17 } } do c:put(p[1], p[2], TWINE[2]) end
c:put(28, 17, TWINE[4]) c:put(29, 17, TWINE[3])
for _, p in ipairs{ { 27, 19 }, { 26, 20 }, { 26, 21 }, { 25, 22 }, { 25, 23 }, { 24, 23 } } do c:put(p[1], p[2], TWINE[3]) end
for _, p in ipairs{ { 29, 19 }, { 30, 20 }, { 30, 21 }, { 31, 22 }, { 32, 22 }, { 32, 23 } } do c:put(p[1], p[2], TWINE[2]) end
c:put(24, 23, TWINE[4]) c:put(32, 23, TWINE[4])

-- quirk: pesto dribble from under the lid
local DR = { "#2d4a14", "#6f9428", "#a4c448", "#d0e472" }
for y = 16, 29 do
  if y == 16 or y == 17 or y == 18 then   -- lies over the twine
    c:put(37, y, DR[3]) c:put(38, y, DR[2])
  else
    c:put(37, y, DR[3]) c:put(38, y, DR[2])
  end
end
for _, p in ipairs{ { 36, 30 }, { 37, 30 }, { 38, 30 }, { 36, 31 }, { 37, 31 }, { 38, 31 }, { 37, 32 }, { 38, 32 } } do c:put(p[1], p[2], (p[1] == 36) and DR[3] or DR[2]) end
c:put(36, 30, DR[4]) c:put(37, 19, DR[4]) c:put(37, 22, DR[4]) c:put(38, 32, DR[1]) c:put(38, 31, DR[1])
c:put(36, 31, DR[3])
A.save(c, "ramson-pesto")
