-- ico-acorn-nut (final pass, Opus single pass). Bold icon: an upright acorn, slim egg-shaped nut with a blunt nib,
-- glossy (big soft specular + cream glint, faint long streaks, cool bounce on the shade side); a domed scaly cupule
-- (staggered 4x3 scales: lit tip, dark gap) with a pale overhanging rim lip that casts a dark band on the nut; a
-- 3 px curved stalk with a pale end grain. 5 tones per material, 3 px minimum parts, reads at 16 px.
-- quirk: somebody has taken a little nibble out of the nut, showing the pale kernel.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA0_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = A.new("ico-acorn-nut")
local NUT = { "#5a2c26", "#8e4a2c", "#c47438", "#e8a24e", "#ffd486" }
local CAP = { "#33201e", "#5a3828", "#865a3a", "#b0804e", "#dcae72" }
local STEM = { "#3a2622", "#6a4630", "#a07448", "#d6ac72" }
local KERN = { "#d9a860", "#f2d49a", "#fff0c8" }
local NCUT = { 0.22, 0.45, 0.68, 0.88 }
local ntok, ctok, ttok = { r = { name = "nut" } }, { r = { name = "cap" } }, { r = { name = "stem" } }

-- nut: egg, widest a little above the middle, tapering to a blunt nib
local CX, CY = 32, 39
local nm = HP.mask()
for y = 20, 58 do for x = 14, 50 do
  local v = (y + 0.5 - CY) / 15.5
  local rx = 12.6 * (v < 0 and 1 or (1 - 0.38 * v * v))
  if abs(v) <= 1 and abs(x + 0.5 - CX) <= rx * sqrt(max(0, 1 - v * v * (v < 0 and 1 or 0.72))) then nm:set(x, y) end
end end
nm:add(c:rect(31, 54, 33, 56))                       -- nib
-- quirk: nibble out of the lower right (two overlapping bites)
local bite = c:ellipse(44, 45, 2.6, 2.6):add(c:ellipse(43, 49.5, 2.4, 2.4))
nm:cut(bite)
local nS = X.sphere(CX - 1, CY - 2, 14.5, nm)
local nP = X.pillow(nm, 4)
local nn = A.blend(nS, nP, 0.35)
local nbias = {}
local nidx = A.shade(c, nm, nn, NUT, { amb = 0.08, wrap = 0.25, cuts = NCUT, tok = ntok, bias = nbias })
-- faint long streaks on the mid tones
nm:each(function(x, y) local k = K(x, y)
  local v = (y + 0.5 - CY) / 15.5
  local s = (x + 0.5 - CX) / 12.6 / sqrt(max(0.15, 1 - v * v * 0.6))
  local f = (s * 2.6 + 10) % 1
  if y > 29 and y < 52 and (f < 0.12) and nidx[k] and nidx[k] >= 3 and nidx[k] <= 4 then A.step(c, nidx, NUT, x, y, -1, ntok) end
end)
-- nib: darker, with one lit pixel
c:put(31, 55, NUT[2], ntok) c:put(32, 55, NUT[2], ntok) c:put(33, 55, NUT[1], ntok)
c:put(31, 56, NUT[1], ntok) c:put(32, 56, NUT[1], ntok) c:put(33, 56, NUT[1], ntok) c:put(31, 54, NUT[3], ntok)
-- kernel inside the bite: pale ring along the bite edge, deeper inside
local grown = nm:grow(1)
bite:each(function(x, y)
  if grown:has(x, y) and not nm:has(x, y) then end end)
local kern = HP.mask()
nm:each(function(x, y)
  if bite:has(x + 1, y) or bite:has(x, y + 1) or bite:has(x - 1, y) or bite:has(x, y - 1) then kern:set(x, y) end end)
kern:each(function(x, y)
  local inner = bite:has(x + 1, y) or bite:has(x, y + 1)
  c:put(x, y, inner and KERN[2] or KERN[1], ntok) end)
-- shell rim around the kernel (thin brown skin line just inside)
kern:grow(1):cut(kern):cut(bite):each(function(x, y) if nm:has(x, y) then c:put(x, y, NUT[2], ntok) end end)
c:put(42, 44, KERN[3], ntok)
-- cool bounce on the lower-left-to-right shade rim
nm:edge():each(function(x, y) if x > CX + 3 and y > CY + 2 and y < 52 and not kern:has(x, y) then c:put(x, y, "#8a5468", ntok) end end)
-- gloss: soft 3-px specular + cream glint
c:put(23, 31, NUT[5], ntok) c:put(24, 31, NUT[5], ntok) c:put(23, 32, NUT[5], ntok) c:put(23, 33, NUT[5], ntok)
c:put(24, 30, A.CREAM, ntok)

-- cap: dome with an overhanging rim
local capm = c:ellipse(32, 26, 16, 9):cut(c:rect(0, 28, 63, 63))
capm:add(c:rrect(16, 26, 48, 29, 2))
local cn = A.blend(X.sphere(31, 27, 16, capm), X.pillow(capm, 3), 0.4)
local cbias = {}
local cidx = A.shade(c, capm, cn, CAP, { amb = 0.1, wrap = 0.3, cuts = NCUT, tok = ctok, bias = cbias })
-- scales: staggered 4x3 cells, lit tip + dark gap row
capm:each(function(x, y) local k = K(x, y)
  if y <= 27 then
    local row = floor((y - 15) / 3)
    local u = (x + (row % 2) * 2) % 4
    local v = (y - 15) % 3
    if v == 2 or (v == 1 and u == 3) then A.step(c, cidx, CAP, x, y, -1, ctok)
    elseif v == 0 and (u == 1 or u == 2) and x < 40 then A.step(c, cidx, CAP, x, y, 1, ctok) end
  end
end)
-- rim lip: pale top row, darker underside row
for x = 16, 48 do
  if capm:has(x, 28) then A.step(c, cidx, CAP, x, 28, (x < 38) and 1 or 0, ctok) end
  if capm:has(x, 29) then A.step(c, cidx, CAP, x, 29, -1, ctok) end
end
-- cast shadow of the rim on the nut
nm:each(function(x, y) if not capm:has(x, y) and (capm:has(x, y - 1) or capm:has(x, y - 2)) then
  c:put(x, y, capm:has(x, y - 1) and NUT[1] or NUT[max(1, (nidx[K(x, y)] or 2) - 1)], ntok) end end)

-- stalk: 3 px curved twig with pale end grain
local stm, stn = X.cyl(31, 18, 35, 9, function(t) return 1.1 end)
X.tone(c, stm, X.light(stn, { amb = 0.12, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = ttok })
c:put(34, 8, STEM[4], ttok) c:put(35, 8, STEM[4], ttok) c:put(36, 9, STEM[3], ttok)
for x = 29, 34 do if stm:has(x, 17) and capm:has(x, 18) then c:put(x, 18, CAP[1], ctok) end end
A.save(c, "ico-acorn-nut", "ico")
