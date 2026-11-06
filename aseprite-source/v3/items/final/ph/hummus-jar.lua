-- hummus-jar (final, Opus single pass aC12_5). A slim, straight-sided glass preserving jar (taller than wide) packed
-- with creamy hummus that rises above the rim in a swirled peak: a gold olive-oil pool in the swirl, red paprika
-- flecks, three chickpeas on top, and a toasted pita chip stuck in at an angle. Kraft paper label tied with twine.
-- Material: per-pixel cylinder light on the hummus behind glass (6 tones), grainy dimples, pale glass walls with a
-- bright vertical streak + glint, a thick glass rim lip and a dark glass base, AO under the rim and under the peak,
-- pita chip with toasted blisters and a pale broken edge, twisted twine. Ground shadow.
-- quirk: one runaway chickpea has rolled out and sits on the ground beside the jar.
local NAME = "hummus-jar"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local HUM = { "#5e3a30", "#8a5e40", "#b8885a", "#dab27a", "#f0d49e", "#fff0c8" }
local GLASS = { "#3a5a7a", "#5a8aa8", "#8cbcc8", "#b6e0e0", "#dcf4ee", "#f4fff8" }
local PITA = { "#6a3424", "#9a5a30", "#c88a48", "#e8b46a", "#f8d898", "#fff0c4" }
local OIL = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local PEA = { "#6a4028", "#a87040", "#d8a868", "#f4d498", "#fff0c8" }
local KRAFT = { "#6e4630", "#9a6a44", "#c49462", "#e0b884", "#f4d6a4", "#fff0c8" }
local TW = { "#864c33", "#b97a4a", "#e8b982" }
local htok, gtok, ptok, otok = { r = { name = "hummus" } }, { r = { name = "glass" } }, { r = { name = "pita" } }, { r = { name = "oil" } }

c:groundShadow(32, 55, 13, 2)

-- jar body (glass) 22 wide
local X0, X1, Y0, Y1 = 21, 43, 25, 55
local CX, HW = 32.5, 11.5
local body = HP.rrect(X0, Y0, X1, Y1, 3)
local bn = A.vcyl(body, CX, HW, -0.05)
-- hummus inside (1 px glass wall each side, thick base)
local hum, glass = HP.mask(), HP.mask()
body:each(function(x, y) if x > X0 and x < X1 and y < Y1 - 1 then hum:set(x, y) else glass:set(x, y) end end)
local hidx = A.shade(c, hum, bn, HUM, { tok = htok, amb = 0.1, wrap = 0.3 })
A.shade(c, glass, bn, GLASS, { tok = gtok, amb = 0.1, wrap = 0.3 })
-- dimpled hummus grain behind the glass
hum:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 7) > 0.86 and (hidx[k] or 3) > 2 then c:put(x, y, HUM[(hidx[k] or 3) - 1], htok) end
  if X.hash(x, y, 11) > 0.93 and (hidx[k] or 3) < 6 then c:put(x, y, HUM[(hidx[k] or 3) + 1], htok) end end)
-- air pocket smears against the glass
for _, q in ipairs{ { 37, 49 }, { 38, 49 }, { 26, 31 }, { 40, 30 } } do c:put(q[1], q[2], HUM[3], htok) end
-- dark glass base
for x = X0 + 1, X1 - 1 do c:put(x, Y1, x < 28 and GLASS[3] or GLASS[1], gtok) c:put(x, Y1 - 1, x < 28 and GLASS[4] or GLASS[2], gtok) end
-- glass wall streak + glint (left), dark wall right
for y = 29, 51 do c:put(23, y, (y < 44) and GLASS[6] or GLASS[5], gtok) end
for y = 31, 37 do c:put(24, y, GLASS[5], gtok) end
c:put(23, 30, A.CREAM, gtok)
for y = 28, 53 do c:put(X1 - 1, y, HUM[1], htok) end

-- swirled peak above the rim
local peak = HP.mask()
for y = 12, 26 do for x = 20, 45 do
  local dx, dy = (x + 0.5 - 32.5) / 10.5, (y + 0.5 - 24) / 10
  local prof = 1 - abs(dx) ^ 1.6
  if dy <= 0 and -dy <= prof * 0.95 and abs(dx) <= 1 then peak:set(x, y) end
end end
peak:add(HP.rect(23, 25, 42, 25))
local pn = X.pillow(peak, 5)
local pbias = {}
local pidx = A.shade(c, peak, pn, HUM, { tok = htok, amb = 0.12, wrap = 0.32, bias = pbias })
-- spiral swirl grooves (dark line + lit lip above)
peak:each(function(x, y) local k = K(x, y)
  local dx, dy = (x + 0.5 - 32.5), (y + 0.5 - 21) * 2.2
  local r = sqrt(dx * dx + dy * dy)
  local a = atan(dy, dx)
  local ph = (r - a * 1.1) / 3.5
  local f = ph - floor(ph)
  if r > 2.2 and r < 10 and y < 25 then
    local i = pidx[k] or 3
    if f < 0.18 then c:put(x, y, HUM[max(1, i - 2)], htok)
    elseif f < 0.36 and i >= 3 then c:put(x, y, HUM[min(6, i + 1)], htok) end
  end
end)
-- olive oil pool in the swirl
local pool = HP.mask()
for _, r in ipairs{ { 29, 35, 19 }, { 28, 36, 20 }, { 29, 34, 21 } } do for x = r[1], r[2] do pool:set(x, r[3]) end end
pool:each(function(x, y) c:put(x, y, (y == 19) and OIL[2] or ((x < 31) and OIL[4] or OIL[3]), otok) end)
c:put(29, 20, A.CREAM, otok) c:put(35, 21, OIL[1], otok)
-- paprika flecks
for _, q in ipairs{ { 27, 21 }, { 38, 22 }, { 33, 17 }, { 25, 23 }, { 36, 19 }, { 31, 22 } } do c:put(q[1], q[2], (q[1] % 2 == 0) and "#c8402e" or "#e8603a", otok) end

-- glass rim lip in front of the peak foot
local rim = HP.rect(X0, 24, X1, 26)
rim:each(function(x, y)
  local i = (y == 24) and ((x < 30) and 6 or 4) or ((y == 25) and ((x < 28) and 4 or 3) or 2)
  if x == X0 or x == X1 then i = max(1, i - 2) end
  c:put(x, y, GLASS[i], gtok) end)
-- AO under the rim
for x = X0 + 1, X1 - 1 do local k = K(x, 27) c:put(x, 27, HUM[max(1, (hidx[k] or 3) - 2)], htok) end

-- chickpeas on top (round, with a beak)
local function pea(cx, cy, tok)
  local m = A.ball(c, cx, cy, 2.1, 1.9, { PEA[1], PEA[2], PEA[3], PEA[3], PEA[4], PEA[5] }, tok, { amb = 0.15 })
  c:put(floor(cx) + 1, floor(cy) - 2, PEA[2], tok)   -- beak
  c:put(floor(cx), floor(cy), PEA[2], tok)            -- seam dimple
  return m
end
local ktok = { r = { name = "pea" } }
pea(28, 17, ktok) pea(34, 14.5, ktok) pea(38.5, 18, ktok)

-- pita chip stuck in the peak, leaning right
local chip = HP.poly{ { 37, 16 }, { 44, 7 }, { 49, 13 }, { 41, 18 } }
local cn = X.pillow(chip, 2)
local cidx = A.shade(c, chip, cn, PITA, { tok = ptok, amb = 0.15, wrap = 0.3 })
chip:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 3) > 0.82 then c:put(x, y, PITA[max(1, (cidx[k] or 3) - 2)], ptok) end   -- toasted blisters
end)
chip:edge():each(function(x, y) if x + y < 50 then c:put(x, y, PITA[6], ptok) end end)  -- pale broken edge
-- hummus scooped onto the chip foot + AO on peak right of chip
for _, q in ipairs{ { 39, 16 }, { 40, 16 }, { 40, 15 }, { 41, 16 } } do c:put(q[1], q[2], HUM[5], htok) end
for _, q in ipairs{ { 42, 18 }, { 41, 19 }, { 43, 19 } } do if peak:has(q[1], q[2]) then c:put(q[1], q[2], HUM[1], htok) end end

-- kraft label tied with twine
local lab = HP.rect(X0, 36, X1, 46)
lab:each(function(x, y) local k = K(x, y)
  local i = (hidx[k] or (x < 30 and 4 or 2))
  local col = KRAFT[max(1, min(6, i))]
  if x == X0 or x == X1 then col = KRAFT[max(1, i - 2)] end
  c:put(x, y, col, htok) end)
for x = X0 + 1, X1 - 1 do c:put(x, 37, KRAFT[max(1, (hidx[K(x, 37)] or 3) - 1)], htok) end
-- label: a chickpea drawing and 'text' rows
A.paint(c, { ".ab.", "abbc", "bbcc", ".cc." }, 25, 39, { a = PEA[5], b = PEA[3], c = PEA[2] }, htok)
for x = 30, 39 do if x % 4 ~= 1 then c:put(x, 40, KRAFT[1], htok) end end
for x = 30, 37 do if x % 3 ~= 2 then c:put(x, 43, KRAFT[2], htok) end end
-- twine (twisted) over the label top, with a bow knot
local twt = { r = { name = "twine" } }
for x = X0, X1 do c:put(x, 35, (x % 2 == 0) and TW[3] or TW[2], twt) c:put(x, 36, (x % 2 == 0) and TW[1] or TW[2], twt) end
A.paint(c, { "a..a", "baab", ".bb." }, 25, 33, { a = TW[3], b = TW[1] }, twt)

-- quirk: runaway chickpea on the ground
pea(49, 54, { r = { name = "runaway" } })
A.save(c, NAME)
