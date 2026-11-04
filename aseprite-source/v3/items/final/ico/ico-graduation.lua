-- ico-graduation (final, Opus). Mortarboard in 3/4 view: a stiff diamond board with a visible 2 px thickness
-- (left face darker than right), the skull cap under it as a curved cloth cylinder with a hem band, a gold button
-- at the board centre, a twisted cord running to the front-right corner and dropping over the edge to a knotted
-- tassel with a fringe of strands.
-- Material: diagonal twill weave on cloth, bevel light on the board's top edges, AO under the board where it sits
-- on the cap, contact shadow of the cord, twist on the cord, strand lines + ragged ends on the tassel.
-- quirk: a loose thread has come undone from the hem and curls down.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA5_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new("ico-graduation")
local CL = { "#1c1838", "#2a2756", "#3a3a78", "#4e509a", "#686cba", "#8f96d8" }
local TS = { "#6a3418", "#a65e1c", "#d98322", "#f5b82e", "#ffd860", "#fff0a8" }
local ctok, gtok = { r = { name = "cloth" } }, { r = { name = "gold" } }

-- skull cap: vertical cylinder x 18..46, top hidden by the board, curved hem at the bottom
local CX, HWD = 32, 13.5
local cap = HP.mask()
local capN = {}
for x = 18, 46 do
  local u = (x - CX) / (HWD + 0.5)
  local yb = floor(36 + 3.2 * sqrt(max(0, 1 - u * u)) + 0.5)
  for y = 22, yb do cap:set(x, y) capN[K(x, y)] = { A.norm(u, 0.15, sqrt(max(0.03, 1 - u * u))) } end
end
local cb = {}
-- hem band: bottom 3 rows a step darker, with a lit lip row above it
cap:each(function(x, y) local k = K(x, y)
  local u = (x - CX) / (HWD + 0.5)
  local yb = floor(36 + 3.2 * sqrt(max(0, 1 - u * u)) + 0.5)
  if y >= yb - 2 then cb[k] = -1 elseif y == yb - 3 then cb[k] = 1 end
end)
local cidx = A.shade(c, cap, capN, CL, { tok = ctok, bias = cb, amb = 0.05, wrap = 0.28, cuts = { 0.18, 0.36, 0.54, 0.72, 0.88 } })
-- twill weave on the cap (diagonal)
cap:each(function(x, y) if (x + y) % 4 == 0 and cidx[K(x, y)] and cidx[K(x, y)] > 2 and cidx[K(x, y)] < 6 then A.step(c, cidx, CL, x, y, -1, ctok) end end)

-- board: diamond top plane + 2 px thickness on the two front faces
local T, R, B, L = { 32, 8 }, { 55, 19 }, { 32, 30 }, { 9, 19 }
local top = c:poly{ T, R, B, L }
local thick = top:shift(0, 1):add(top:shift(0, 2)):cut(top)
-- AO on the cap right under the board
local under = top:copy():add(thick)
for d = 1, 1 do under:shift(0, d):each(function(x, y) if cap:has(x, y) and not top:has(x, y) and not thick:has(x, y) then
  local k = K(x, y) if cidx[k] then cidx[k] = max(1, cidx[k] - (d == 1 and 2 or 1)) c:put(x, y, CL[cidx[k]], ctok) end end end) end
thick:each(function(x, y) c:put(x, y, x < B[1] and CL[3] or CL[2], ctok) end)
-- lit lower edge lip of the left face
thick:each(function(x, y) if x < B[1] - 1 and not thick:has(x, y + 1) and x % 3 ~= 0 then c:put(x, y, CL[4], ctok) end end)
top = c:poly{ T, R, B, L }
local tn = X.pillow(top, 2.2)
local tb = {}
top:each(function(x, y) local k = K(x, y)
  -- planar top tilted toward the viewer: front half a touch darker, far corner lighter
  if y > 22 then tb[k] = -1 elseif y < 13 then tb[k] = 1 end
end)
local bidx = A.shade(c, top, tn, CL, { tok = ctok, bias = tb, amb = 0.42, wrap = 0.5, cuts = { 0.2, 0.38, 0.56, 0.7, 0.84 } })
-- weave on the board, along the diamond's edges
top:each(function(x, y) local k = K(x, y)
  if bidx[k] and bidx[k] > 2 and bidx[k] < 6 and (x - 2 * y) % 6 <= 1 then A.step(c, bidx, CL, x, y, -1, ctok) end end)
-- bright bevel along the two back edges (lit from the upper left), one specular glint
for x = 11, 31 do local y = floor(19 - (x - 9) * 11 / 23 + 0.5) + 1 if top:has(x, y) then c:put(x, y, CL[6], ctok) end end
c:put(16, 17, A.CREAM)

-- cord: button at centre -> front-right edge, twisted 2 px
local cord = { { 33, 20 }, { 36, 21 }, { 39, 22 }, { 42, 23 }, { 45, 24 }, { 47, 25 } }
local cm = c:line(cord, 2)
-- contact shadow on the board under the cord
cm:shift(1, 1):each(function(x, y) if top:has(x, y) and not cm:has(x, y) then A.step(c, bidx, CL, x, y, -2, ctok) end end)
cm:each(function(x, y) c:put(x, y, ((x + y) % 3 == 0) and TS[3] or (((x + y) % 3 == 1) and TS[5] or TS[4]), gtok) end)
-- hanging cord over the front-right face, down to the knot
local hang = HP.mask()
for y = 25, 37 do hang:set(47, y) hang:set(48, y) end
hang:each(function(x, y) c:put(x, y, ((y + (x - 47)) % 3 == 0) and TS[2] or (x == 47 and TS[5] or TS[3]), gtok) end)
hang:shift(1, 0):each(function(x, y) if cap:has(x, y) and not hang:has(x, y) then A.step(c, cidx, CL, x, y, -2, ctok) end end)
-- button (domed)
A.map(c, { ".hb.", "hssb", "bsbd", ".dd." }, 30, 18, { h = TS[6], s = TS[5], b = TS[4], d = TS[2] })

-- tassel: knot cap + fringe of strands
A.map(c, {
  ".bssb.",
  "bhssbd",
  ".dbbd.",
}, 45, 37, { h = TS[6], s = TS[5], b = TS[4], d = TS[2] })
local fr = HP.mask()
for y = 40, 50 do
  local w = (y < 42) and 2 or 3
  local cxf = 47.5
  for x = floor(cxf - w), floor(cxf + w) do fr:set(x, y) end
end
-- ragged bottom
for _, p in ipairs{ { 44, 50 }, { 47, 50 }, { 50, 50 }, { 50, 49 }, { 44, 49 } } do fr.s[K(p[1], p[2])] = nil end
fr:each(function(x, y)
  local col = x - 44
  local i = (col % 2 == 0) and 4 or 3
  if x <= 45 then i = i + 1 end
  if x >= 49 then i = i - 1 end
  if y >= 48 and col % 2 == 1 then i = i - 1 end
  if y == 40 then i = 2 end
  c:put(x, y, TS[max(1, min(6, i))], gtok)
end)
c:put(45, 42, TS[6], gtok)
-- AO on the cap behind the tassel
fr:add(HP.mask()):shift(1, 0):each(function(x, y) if cap:has(x, y) and not fr:has(x, y) then A.step(c, cidx, CL, x, y, -2, ctok) end end)

-- quirk: loose thread curling down from the hem
for _, p in ipairs{ { 24, 40 }, { 24, 41 }, { 23, 42 }, { 23, 43 }, { 24, 44 }, { 25, 44 }, { 26, 43 } } do c:put(p[1], p[2], CL[5], ctok) end
c:put(24, 41, CL[4], ctok) c:put(23, 43, CL[4], ctok)

A.save(c, "ico-graduation")
