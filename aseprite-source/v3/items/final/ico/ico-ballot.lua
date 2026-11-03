-- ico-ballot (final, Opus). Three-quarter ballot box: oak box seen from front-above (lit lid, mid front,
-- dark right side), planked front with grain and a plank seam, brass corner caps with a bevel and a bright
-- edge, a dark slot in the lid. A ballot paper slants into the slot: pale card with a folded corner, a bold
-- green tick, AO where it enters the slot. Ground shadow under the box.
-- quirk: a stubby pencil hangs on a string from the box's side, ready for the next voter.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA0_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin
local c = A.new("ico-ballot")
local WD = { "#4a2a28", "#6b3d2d", "#8e5634", "#b37444", "#d4955c", "#ecb87e" }
local BR = { "#6b3a1e", "#a8661f", "#d9932a", "#f5bf45", "#ffe48c" }
local PA = { "#6f6888", "#9a94b0", "#c3bfd3", "#e2dee4", "#f4efe6", "#fffaf0" }
local TK = { "#24544a", "#3f9150", "#6cbf55", "#b4e27a" }
local wtok, ptok, btok = { r = { name = "wood" } }, { r = { name = "paper" } }, { r = { name = "brass" } }

c:groundShadow(33, 57, 22, 1.5)
-- box faces
local front = c:rect(11, 34, 46, 55)
local top = c:poly{ { 11, 33 }, { 46, 33 }, { 51, 27 }, { 16, 27 } }
local side = c:poly{ { 47, 33 }, { 51, 28 }, { 51, 50 }, { 47, 55 } }
side:cut(front)
top:cut(front)
local function face(m, tilt, R, bias)
  local n = X.pillow(m, R or 1.4)
  for k, v in pairs(n) do n[k] = { A.norm(v[1] * 0.6 + tilt[1], v[2] * 0.6 + tilt[2], v[3] * 0.6 + tilt[3]) } end
  return A.shade(c, m, n, WD, { amb = 0.06, wrap = 0.15, tok = wtok, bias = bias })
end
-- grain bias: wavy horizontal streaks on the front, along the lid on the top
local gb = {}
front:each(function(x, y)
  local g = y + sin(x * 0.35 + (y > 44 and 2 or 0)) * 0.9
  if (floor(g) % 4 == 0) and X.hash(x, y, 3) > 0.25 then gb[K(x, y)] = -1 end
end)
top:each(function(x, y)
  if (x + y * 0.8) % 7 < 0.9 and X.hash(x, y, 4) > 0.3 then gb[K(x, y)] = -1 end
end)
-- AO: front pixels under the lid lip, side next to the front
local fidx = face(front, { 0, 0.05, 1 }, 1.4, gb)
local tidx = face(top, { -0.1, -0.75, 0.75 }, 1.2, gb)
local sidx = face(side, { 0.85, 0.1, 0.45 }, 1.0)
-- lid lip: bright edge row along the front top + dark row under it
for x = 11, 46 do c:put(x, 33, WD[6], wtok) A.step(c, fidx, WD, x, 34, -2, wtok) end
-- plank seam across the front
for x = 12, 46 do c:put(x, 44, WD[2], wtok) A.step(c, fidx, WD, x, 45, 1, wtok) end
-- side: dark corner line against the front
for y = 34, 55 do if side:has(47, y) then c:put(47, y, WD[1], wtok) end end

-- slot in the lid (dark, with a lit back lip)
local slot = c:poly{ { 20, 31 }, { 41, 31 }, { 43, 29 }, { 22, 29 } }
c:fillMask(slot, "#2a1a24")
for x = 22, 43 do if top:has(x, 28) then c:put(x, 28, WD[2], wtok) end end
for x = 19, 41 do if top:has(x, 32) then c:put(x, 32, WD[6], wtok) end end

-- ballot paper: slanted card dropping into the slot
local paper = c:poly{ { 23, 30 }, { 39, 30 }, { 42, 9 }, { 26, 7 } }
local pn = X.pillow(paper, 1.2)
for k, v in pairs(pn) do pn[k] = { A.norm(v[1] * 0.5 - 0.15, v[2] * 0.5 - 0.1, 1) } end
local pb = {}
paper:each(function(x, y) if y >= 27 then pb[K(x, y)] = (y - 26) * -1 end end)
local pidx = A.shade(c, paper, pn, PA, { amb = 0.1, wrap = 0.3, tok = ptok, bias = pb })
-- folded corner top-right: cut the corner off along a diagonal, lay the flap back over the card
local cutc = HP.mask()
paper:each(function(x, y) if (x - 36) - (y - 7) > 0 and y <= 13 then cutc:set(x, y) end end)
cutc:each(function(x, y) c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end)
paper:cut(cutc)
for y = 8, 12 do for x = 36, 41 do
  local d = (x - 36) - (y - 7)
  if d <= 0 and d >= -2 and x >= 36 + (12 - y) * 0 and paper:has(x, y) and x + y >= 46 then
    c:put(x, y, d == 0 and PA[4] or PA[3], ptok)
  end
end end
for y = 8, 13 do for x = 34, 41 do
  if (x - 36) - (y - 7) == -3 and x + y >= 46 and paper:has(x, y) then c:put(x, y, PA[2], ptok) end
end end
-- two faint text lines on the card
A.pline(c, { { 28, 13 }, { 34, 13 } }, PA[3], ptok)
A.pline(c, { { 28, 15 }, { 32, 15 } }, PA[3], ptok)
-- bold tick (3 px stroke)
local tick = c:line({ { 27, 20 }, { 31, 24 }, { 38, 14 } }, 3)
tick:clip(paper)
c:fillMask(tick, TK[2])
tick:each(function(x, y)
  if not tick:has(x, y - 1) or not tick:has(x - 1, y) then c:put(x, y, TK[3]) end
  if not tick:has(x, y + 1) and not tick:has(x + 1, y) then c:put(x, y, TK[1]) end
end)
c:put(36, 16, TK[4])

-- brass corner caps on the two front top corners + bottom corners
local function cap(x0, y0, dx, dy)
  for i = 0, 3 do
    c:put(x0 + dx * i, y0, i == 0 and BR[5] or BR[4], btok) c:put(x0 + dx * i, y0 + dy, BR[2], btok)
    c:put(x0, y0 + dy * i, i == 0 and BR[5] or BR[3], btok) c:put(x0 + dx, y0 + dy * i, BR[2], btok)
  end
  c:put(x0 + dx, y0 + dy, BR[1], btok)
end
cap(11, 34, 1, 1) cap(46, 34, -1, 1) cap(11, 55, 1, -1) cap(46, 55, -1, -1)
-- brass label plate centre front with a bevel + one glint
local plate = c:rect(24, 38, 33, 41)
c:fillMask(plate, BR[3])
for x = 24, 33 do c:put(x, 38, BR[4], btok) c:put(x, 41, BR[2], btok) end
for y = 38, 41 do c:put(24, y, BR[4], btok) c:put(33, y, BR[1], btok) end
c:put(25, 38, BR[5], btok) c:put(26, 38, BR[5], btok)
for x = 26, 31 do c:put(x, 40, BR[2], btok) end
-- contact row around the plate
for x = 24, 34 do A.step(c, fidx, WD, x, 42, -1, wtok) end

-- quirk: pencil on a string from the side face
local stok = { r = { name = "string" } }
A.pline(c, { { 51, 36 }, { 53, 39 }, { 54, 43 } }, "#e2dccb", stok)
local pen = c:line({ { 55, 44 }, { 56, 55 } }, 3)
c:fillMask(pen, BR[3])
pen:each(function(x, y) if not pen:has(x - 1, y) then c:put(x, y, BR[4]) end
  if not pen:has(x + 1, y) then c:put(x, y, BR[2]) end end)
for x = 54, 57 do for y = 43, 45 do if pen:has(x, y) then c:put(x, y, "#f5809f") end end end
for x = 54, 57 do if pen:has(x, 46) then c:put(x, 46, "#aaa9b8") end end
for x = 54, 57 do for y = 54, 56 do if pen:has(x, y) then c:put(x, y, WD[5]) end end end
c:put(56, 57, "#444663")
A.save(c, "ico-ballot")
