-- shakshuka (D15 redraw, single pass). A cast-iron skillet seen from the front three-quarter, flared wall with a bright
-- vertical sheen, bevelled rim ring with specular, a long handle ending in a hanging-hole paddle and a rivet. Inside: the
-- dark back wall, a wet red tomato sauce (meniscus, oil sheen arcs, tomato chunks, two bubbles), two poached eggs with
-- crisped golden edges and glossy yolks (sphere light + specular), parsley, chilli flake and pepper.
-- A triangle of pita stands dipped in at the back left: puffed crust band, char blisters, sauce-soaked tip, ground shadow
-- under the pan, contact shadows on sauce and rim.
-- quirk: somebody already took a bite out of the pita's top corner (scalloped bite, pale crumb edge).
local NAME = "shakshuka"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local IRON = { "#17151f", "#262431", "#38374a", "#52516a", "#74758c", "#a4a6b8" }
local RED  = { "#4a0f1e", "#7e1428", "#b0182c", "#d92b2d", "#f25a3a", "#ff9a72" }
local RB   = { "#3e1020", "#6e1c2a", "#9c2a2e", "#c0402f", "#dc5e3a", "#f28a5c" }
local EW   = { "#8d7fa8", "#b3a8c4", "#d7cfdc", "#efe9e8", "#fbf6ec", "#fffdf5" }
local YK   = { "#9a4a1c", "#d2761e", "#f0a024", "#ffbf34", "#ffd860", "#fff0a8" }
local BR   = { "#4a2a1e", "#7a4a2a", "#a86a36", "#cf9448", "#ecbd6a", "#fbe2a0" }
local LEAF = A.R.leaf
local CUTS = { 0.3, 0.46, 0.62, 0.78, 0.9 }
local cx, cy, rx, ry = 28.5, 34, 21, 13.5
local D, rb, ryb = 7, 18.5, 10.5

c:groundShadow(29.5, 53, 21, 2.5)

-- handle (drawn first, the rim overlaps its root) ---------------------------------------------------------
local htok = { r = { name = "handle" } }
local hm, hn, hT, hS = A.tube({ { 48, 35 }, { 51, 35 }, { 54, 32.5 }, { 56, 28.5 } }, function(t) return 1.9 - 0.4 * t end)
local pad = A.ell(56, 27.2, 2.1, 3, 0)
local hall = hm:copy():add(pad)
local hnn = X.pillow(hall, 2)
A.toneN(c, hall, hnn, IRON, { tok = htok, cuts = CUTS, amb = 0.1, wrap = 0.3 })
c:put(55, 27, IRON[1], htok) c:put(56, 27, IRON[1], htok) c:put(55, 28, IRON[1], htok) c:put(56, 28, IRON[2], htok)
c:put(54, 26, IRON[5], htok)

-- pan body: flared wall ----------------------------------------------------------------------------------
local O = A.ell(cx, cy, rx, ry, 0)
local body = HP.mask()
for i = 0, 10 do local f = i / 10 body:add(A.ell(cx, cy + D * f, rx - (rx - rb) * f, ry - (ry - ryb) * f, 0)) end
local wall = body:copy():cut(O)
local wn = {}
wall:each(function(x, y) local t = max(-0.97, min(0.97, (x - cx) / rx)) wn[K(x, y)] = { t, 0.25, sqrt(1 - t * t) } end)
local wtok = { r = { name = "wall" } }
local widx = A.toneN(c, wall, wn, IRON, { tok = wtok, cuts = { 0.3, 0.5, 0.66, 0.8, 0.92 }, amb = 0.1, wrap = 0.3 })
-- underside of the rim and the bottom curve go dark
A.darken(c, A.ring(wall, O, 1), widx, IRON, wtok)
wall:each(function(x, y) if not body:has(x, y + 1) then c:put(x, y, IRON[1], wtok) end end)
-- vertical sheen on the lit side of the wall
local sx = floor(cx - 12)
for x = sx, sx + 1 do
  local y0, y1 = 1e9, -1e9
  wall:each(function(px, py) if px == x then y0, y1 = min(y0, py), max(y1, py) end end)
  for y = y0 + 2, y1 - 2 do if wall:has(x, y) then c:put(x, y, x == sx and IRON[5] or IRON[4], wtok) end end
end

-- rim ring -------------------------------------------------------------------------------------------------
local Iin = A.ell(cx, cy + 0.8, rx - 3, ry - 3, 0)
local ring = O:copy():cut(Iin)
local rn = X.pillow(ring, 1.8)
local rtok = { r = { name = "rim" } }
local ridx = A.toneN(c, ring, rn, IRON, { tok = rtok, cuts = { 0.34, 0.5, 0.64, 0.78, 0.9 }, amb = 0.1, wrap = 0.3 })
local rsp = X.spec(rn, 22)
ring:each(function(x, y) if rsp[K(x, y)] > 0.55 then c:put(x, y, IRON[6], rtok) end end)

-- inner back wall -------------------------------------------------------------------------------------------
local S = A.ell(cx, cy + 3.5, rx - 4.2, ry - 4.9, 0):clip(Iin)
local iw = Iin:copy():cut(S)
local iwidx = {}
iw:each(function(x, y)
  local i = 2 + ((x < cx - 5) and 1 or 0) + ((x < cx - 12) and 1 or 0)
  if y < cy - 7 then i = max(1, i - 1) end
  iwidx[K(x, y)] = i
  c:put(x, y, IRON[i], rtok)
end)
A.ring(iw, S, 1):each(function(x, y) c:put(x, y, IRON[1], rtok) end)
for _, q in ipairs{ { 24, 27 }, { 33, 27 }, { 37, 28 } } do if iw:has(q[1], q[2]) then c:put(q[1], q[2], RED[2], rtok) end end

-- sauce -----------------------------------------------------------------------------------------------------
local stok = { r = { name = "sauce" } }
local sd = X.dist(S)
local sidx = {}
S:each(function(x, y) local k = K(x, y)
  local i = 3
  if sd[k] < 1.4 then i = ((x - cx) + (y - cy) * 1.2 < 0) and 2 or 4 end
  local q = ((x - cx) / 15) ^ 2 + ((y - cy - 3.5) / 7.5) ^ 2
  if abs(q - 0.55) < 0.035 and x < cx + 3 and X.hash(x, y, 4) > 0.3 then i = 5 end
  if abs(q - 0.2) < 0.03 and x > cx - 8 and y < cy + 4 and X.hash(x, y, 6) > 0.4 then i = 4 end
  if X.hash(x, y, 9) > 0.965 then i = 2 end
  sidx[k] = i
  c:put(x, y, RED[i], stok)
end)
for _, b in ipairs{ { 17, 41 }, { 33, 44 }, { 44, 39 }, { 20, 31 }, { 46, 34 } } do
  c:put(b[1], b[2], RED[2], stok) c:put(b[1] + 1, b[2], RED[2], stok) c:put(b[1], b[2] + 1, RED[1], stok)
  c:put(b[1] + 1, b[2] + 1, RED[2], stok) c:put(b[1] - 1, b[2] - 1, RED[4], stok)
end

-- eggs ------------------------------------------------------------------------------------------------------
local e1 = A.ell(26.5, 38.2, 7.4, 4.9, 0):add(A.ell(22.8, 39.6, 3.6, 2.9, 0)):add(A.ell(30.4, 41.2, 3.8, 2.7, 0)):clip(S)
local e2 = A.ell(41, 33.4, 5.2, 3.8, 0):add(A.ell(38.3, 35, 2.8, 2.4, 0)):add(A.ell(43.6, 35.4, 2.7, 2.2, 0)):clip(S)
local eggs = e1:copy():add(e2)
-- contact shadow on the sauce
A.darken(c, A.ring(S, eggs, 1):add(A.under(S, eggs, 1, 1)), sidx, RED, stok)
local etok = { r = { name = "egg" } }
for _, e in ipairs{ e1, e2 } do
  local n = X.pillow(e, 2.2, 0.85)
  A.toneN(c, e, n, EW, { tok = etok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  -- crisped golden edge on the shade side
  local bx0, by0, bx1, by1 = e:bbox()
  local ecx, ecy = (bx0 + bx1) / 2, (by0 + by1) / 2
  e:edge():each(function(x, y) if (x - ecx) * 0.8 + (y - ecy) * 1.2 > 2.5 and X.hash(x, y, 12) > 0.3 then c:put(x, y, "#e0b86c", etok) end end)
end
local function yolk(ex, ey, r)
  local m = A.ell(ex, ey, r, r - 0.2, 0)
  local n = X.sphere(ex - 0.3, ey - 0.3, r, m)
  A.toneN(c, m, n, YK, { tok = etok, cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 }, amb = 0.08, wrap = 0.2 })
  m:edge():each(function(x, y) if (x - ex) + (y - ey) > 0.8 then c:put(x, y, YK[1], etok) end end)
  local bx, by = A.specAt(m, n, 40)
  if bx then c:put(bx, by, A.CREAM, etok) c:put(bx + 1, by, YK[6], etok) end
  return m
end
yolk(27.2, 37.4, 3.4)
yolk(41.2, 33, 2.9)
-- herbs and spice
local gk = { r = { name = "herb" } }
for _, q in ipairs{ { 31, 34, 2 }, { 24, 43, 2 }, { 44, 38, 1 }, { 38, 42, 2 }, { 20, 35, 2 }, { 36, 31, 1 }, { 15, 38, 1 } } do
  c:put(q[1], q[2], LEAF[5], gk) if q[3] == 2 then c:put(q[1] + 1, q[2], LEAF[4], gk) c:put(q[1], q[2] + 1, LEAF[3], gk) end
end
for _, q in ipairs{ { 23, 38 }, { 31, 40 }, { 40, 36 } } do c:put(q[1], q[2], "#3a2a30", gk) end
for _, q in ipairs{ { 29, 32 }, { 43, 31 }, { 34, 38 } } do c:put(q[1], q[2], RED[1], gk) end
-- bubbles
for _, b in ipairs{ { 42, 42 }, { 35, 44.5 } } do
  local bx, by = floor(b[1]), floor(b[2])
  for _, d in ipairs{ { 0, -1 }, { -1, 0 }, { 1, 0 }, { 0, 1 } } do c:put(bx + d[1], by + d[2], RED[5], stok) end
  c:put(bx, by, RED[3], stok) c:put(bx - 1, by - 1, RED[6], stok)
end

-- pita triangle ---------------------------------------------------------------------------------------------
local TL, TR, TP = { 7, 18 }, { 25, 13 }, { 17, 36 }
local M = c:poly{ TL, TR, TP }
local bites = A.ell(25.5, 13.5, 3.4, 3.2, 0):add(A.ell(22.3, 12.4, 2.5, 2.3, 0))
M:cut(bites)
-- shadows onto sauce and rim
A.darken(c, A.ring(S, M, 1):add(A.under(S, M, 1, 2)), sidx, RED, stok)
A.darken(c, A.under(ring, M, 1, 2), ridx, IRON, rtok)
local bias = {}
local ex, ey = TR[1] - TL[1], TR[2] - TL[2]
local el = sqrt(ex * ex + ey * ey)
M:each(function(x, y) local k = K(x, y)
  local dist = abs((x - TL[1]) * ey - (y - TL[2]) * ex) / el
  if dist < 2.4 then bias[k] = 1 end
end)
for _, b in ipairs{ { 12, 23 }, { 17, 22 }, { 14, 28 }, { 20, 19 }, { 16, 31 }, { 10, 20 }, { 21, 24 } } do
  for dy = 0, 1 do for dx = 0, 1 do if M:has(b[1] + dx, b[2] + dy) then bias[K(b[1] + dx, b[2] + dy)] = (dx + dy == 0) and -3 or -2 end end end
end
M:each(function(x, y) local k = K(x, y) if not bias[k] and X.hash(x, y, 21) > 0.93 then bias[k] = 1 end end)
local mn = X.pillow(M, 2.4)
local btok = { r = { name = "pita" } }
local bidx = A.toneN(c, M, mn, BR, { tok = btok, cuts = CUTS, amb = 0.16, wrap = 0.3, bias = bias })
-- sauce-soaked tip
M:each(function(x, y) local k = K(x, y)
  local dd = sqrt((x - TP[1]) ^ 2 + (y - TP[2]) ^ 2)
  if dd < 8.5 + 2.5 * X.hash(x, y, 31) then c:put(x, y, RB[bidx[k]], btok) end
end)
-- cut face of the bite: pale crumb
A.ring(M, bites, 1):each(function(x, y) c:put(x, y, BR[6], btok) end)
-- shade the lower-right edge of the pita
M:edge():each(function(x, y) if (x - TL[1]) * 0.9 + (y - TL[2]) * 0.5 > 17 then c:put(x, y, (y > 24) and RB[2] or BR[2], btok) end end)

-- rivet where the handle meets the rim
c:put(48, 33, IRON[6], rtok) c:put(49, 33, IRON[5], rtok) c:put(48, 34, IRON[4], rtok) c:put(49, 34, IRON[2], rtok)

A.save2(c, NAME)
