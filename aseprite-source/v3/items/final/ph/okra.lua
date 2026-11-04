-- okra (final, Opus C3 single pass). One slim okra pod lying on the diagonal, tip lower-left, stem upper-right.
-- Five-ridged pod: lit ridges and dark grooves run the length and converge on the pointed tip; fine pale fuzz
-- specks, waxy bloom on the lit flank, one specular, cool reflected light on the shade flank. Frilly dark calyx
-- collar with AO onto the pod, short woody stem with a pale cut end.
-- quirk: a withered yellow petal with a maroon heart still clings to the pod tip.
local NAME = "okra"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, asin = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.asin
local c = A.new(NAME)
local POD = { "#173f34", "#22603c", "#33803f", "#4fa046", "#7cc155", "#b5e07e" }
local BLOOM, COOL, FUZZ = "#c9e8a4", "#3f7f7a", "#d8f0b0"
local CAL = { "#132e2a", "#1d4734", "#2b633c", "#3f8043", "#5f9e4e", "#8cbf66" }
local STEM = { "#3a3226", "#5a4e30", "#7a7038", "#9c9446", "#c2bc6a", "#e6e0a0" }
local PET = { "#7a4a1e", "#b67a26", "#e0aa3a", "#f5d466", "#fff0a8" }

-- pod: tip (12,55) -> stem end (47,17), slight belly curve
local pp = { { 11, 56 }, { 20, 46 }, { 32, 30 }, { 45, 19 } }
local pm, pn, PT, PS = A.tube(pp, function(t)
  if t < 0.02 then return 0.4 end
  return 0.5 + 4.6 * (min(1, t / 0.72)) ^ 0.62 - (t > 0.9 and (t - 0.9) * 6 or 0)
end)
-- ridged normals: 5 facets across the visible half-cylinder
local mod = {}
local RID = {}
pm:each(function(x, y) local k = K(x, y)
  local phi = asin(PS[k])                       -- -pi/2 .. pi/2
  local f = (phi / pi + 0.5) * 4.0               -- facet coordinate 0..4
  local fr = f - floor(f)
  local d = abs(fr - 0.5) * 2                     -- 1 at ridge, 0 mid facet
  RID[k] = d
  mod[k] = (d > 0.8 and 0.12 or 0) - (d < 0.18 and 0.1 or 0)
end)
local ptok = A.tok("pod")
local pidx = A.shade(c, pm, pn, POD, { mod = mod, tok = ptok, amb = 0.1, wrap = 0.3, cuts = { 0.16, 0.33, 0.5, 0.67, 0.84 } })
-- grooves: dark line where facets meet, only away from the tip
pm:each(function(x, y) local k = K(x, y)
  if RID[k] < 0.14 and PT[k] > 0.12 and PT[k] < 0.93 and abs(PS[k]) < 0.9 then A.step(c, pidx, POD, x, y, -1, ptok) end
end)
-- cool reflected light on the lower-right rim, waxy bloom streak on the lit flank, fuzz specks
pm:edge():each(function(x, y) local k = K(x, y)
  if PS[k] > 0.55 and PT[k] > 0.15 and PT[k] < 0.88 then c:put(x, y, COOL, ptok) end end)
pm:each(function(x, y) local k = K(x, y)
  if PS[k] < -0.35 and PS[k] > -0.62 and PT[k] > 0.3 and PT[k] < 0.7 and (x + y) % 3 == 0 then c:put(x, y, BLOOM, ptok) end
  if PS[k] < -0.6 and PT[k] > 0.1 and PT[k] < 0.85 and X.hash(x, y, 3) > 0.84 then c:put(x, y, FUZZ, ptok) end
end)
-- specular: 2x1 + 1 on the upper lit ridge, upper third
c:put(30, 28, "#effcc8", ptok) c:put(31, 27, "#effcc8", ptok) c:put(29, 30, POD[6], ptok)

-- calyx collar: frilly ring at the stem end, darker, with AO onto the pod
-- rebuild calyx as a wavy lozenge across the pod axis
local cm = HP.mask()
local ax, ay = 0.67, -0.74        -- pod axis direction near stem
local bx, by = 0.74, 0.67         -- across
for y = 10, 30 do for x = 34, 56 do
  local dx, dy = x - 43.5, y - 20.5
  local a = dx * ax + dy * ay        -- along
  local b = dx * bx + dy * by        -- across
  local wav = 1.2 * (0.5 + 0.5 * cos(b * 1.6))
  if a > -2.6 - wav and a < 1.2 and abs(b) < 5.9 - max(0, a) * 0.6 then cm:set(x, y) end
end end
local cn = X.pillow(cm, 2)
local ctok = A.tok("calyx")
local cidx = A.shade(c, cm, cn, CAL, { tok = ctok, cuts = { 0.25, 0.42, 0.58, 0.72, 0.88 } })
-- sepal folds
cm:each(function(x, y) local dx, dy = x - 43.5, y - 20.5
  local b = dx * bx + dy * by
  if abs(b - floor(b / 3.9 + 0.5) * 3.9) < 0.45 then A.step(c, cidx, CAL, x, y, -1, ctok) end end)
-- AO: pod pixels just below the collar
local bias = {}
cm:shift(-1, 1):each(function(x, y) if pm:has(x, y) and not cm:has(x, y) then A.step(c, pidx, POD, x, y, -2, ptok) end end)

-- stem: short, slightly bent, cut end
local sp = { { 45, 19 }, { 47, 16 }, { 49, 14 }, { 51, 11 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 1.7 - t * 0.2 end)
sm:cut(cm)
local stok = A.tok("stem")
local sidx = A.shade(c, sm, sn, STEM, { tok = stok, cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 } })
-- stem fibre line
sm:each(function(x, y) local k = K(x, y) if abs(SS[k] - 0.3) < 0.18 then A.step(c, sidx, STEM, x, y, -1, stok) end end)
-- cut face (pale end grain)
local face = HP.mask()
for _, q in ipairs{ { 51, 9 }, { 52, 9 }, { 50, 10 }, { 51, 10 }, { 52, 10 }, { 53, 10 }, { 51, 11 }, { 52, 11 } } do face:set(q[1], q[2]) end
face:each(function(x, y) c:put(x, y, STEM[6], stok) end)
c:put(52, 10, STEM[4], stok) c:put(53, 10, STEM[3], stok)

-- quirk: withered petal curl on the tip
local petal = {
  "..aa.",
  ".abba",
  "abcbd",
  ".bde.",
  "..e..",
}
local map = { a = PET[5], b = PET[4], c = "#7d2c3e", d = PET[3], e = PET[2] }
for j, row in ipairs(petal) do for i = 1, #row do local ch = row:sub(i, i)
  if map[ch] then c:put(5 + i, 55 + j - 1, map[ch], A.tok("petal")) end end end

A.save(c, NAME)
