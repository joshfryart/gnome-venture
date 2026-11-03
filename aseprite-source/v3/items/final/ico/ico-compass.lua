-- ico-compass (final, Opus). Brass pocket compass face on: a domed bezel ring, a knurled crown and a slim bail ring
-- on top, a cream dial sunk inside with an inner rim shadow, a faint four-point rose, bold cardinal ticks, and a
-- slim diamond needle (red north, steel south) split into a lit and a shade half, on a brass pivot.
-- Material: height-field normals on the bezel (torus) and the bail (tube) snapped to 6-tone brass, a specular streak
-- on the upper-left bezel, a glass glint across the dial (two cream strokes), AO under the crown and at the pivot.
-- quirk: the north mark is a tiny red-cap toadstool instead of an N.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi, atan = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi, math.atan
local c = A.new("ico-compass")
local BR = { "#5a2e1e", "#8c5622", "#bf8a2c", "#e0b445", "#f6dc7a", "#fff4c2" }
local DIAL = { "#a88468", "#d0b48e", "#ecdcb6", "#fff4d6" }
local RED = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local STL = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }
local CX, CY, R, RD = 31.5, 35.5, 18, 13.6
local btok, dtok, ntok = A.tok("brass"), A.tok("dial"), A.tok("needle")

-- bail ring (torus seen face on) + crown, painted first so the case overlaps them
local BX, BY = CX, CY - R - 7.5
local bail = A.ring(BX, BY, 2.6, 5.4)
local function hB(x, y) local r = sqrt((x - BX) ^ 2 + (y - BY) ^ 2) local t = (r - 4) / 1.9 return 2 * sqrt(max(0, 1 - t * t)) end
A.shade(c, bail, A.hnorm(bail, hB, 1), BR, { tok = A.tok("bail"), amb = 0.08, wrap = 0.25 })
local crown = HP.rect(floor(CX) - 2, floor(CY - R) - 4, floor(CX) + 3, floor(CY - R) + 1)
crown:cut(HP.rect(floor(CX) - 2, floor(CY - R) - 4, floor(CX) - 2, floor(CY - R) - 4))
crown:cut(HP.rect(floor(CX) + 3, floor(CY - R) - 4, floor(CX) + 3, floor(CY - R) - 4))
local nC = {}
crown:each(function(x, y) local u = max(-0.95, min(0.95, (x - CX) / 3.2)) nC[K(x, y)] = { u, -0.1, sqrt(1 - u * u) } end)
local ctok = A.tok("crown")
local idxC = A.shade(c, crown, nC, BR, { tok = ctok, amb = 0.08 })
-- knurling: vertical grooves
crown:each(function(x, y) if (x - floor(CX)) % 2 == 1 then A.step(c, idxC, BR, x, y, -1, ctok) end end)
-- AO where the bail meets the crown
for x = floor(CX) - 1, floor(CX) + 2 do c:put(x, floor(CY - R) - 4, BR[2], ctok) end

-- case / bezel: domed ring from RD to R
local case = A.ell(CX, CY, R, R)
local function hK(x, y)
  local r = sqrt((x - CX) ^ 2 + (y - CY) ^ 2)
  if r > R + 0.5 then return 0 end
  if r < RD then return 0.8 end
  local t = (r - (RD + R) / 2) / ((R - RD) / 2 + 0.6)
  return 0.8 + 3.2 * sqrt(max(0, 1 - t * t))
end
local bezel = case:copy():cut(A.ell(CX, CY, RD, RD))
local biasK = {}
X.ao(biasK, bezel, crown, 1, -1)
local idxK = A.shade(c, bezel, A.hnorm(bezel, hK, 0.9), BR, { tok = btok, bias = biasK, amb = 0.08, wrap = 0.25, tilt = { CX, CY, R, 0.2 } })
-- fine engraved line on the bezel and specular streak upper-left
bezel:each(function(x, y)
  local r, a = A.polar(x, y, CX, CY)
  if r >= 17.0 and r < 17.7 then A.step(c, idxK, BR, x, y, -1, btok) end
  if r >= 15.2 and r < 16.2 and a > -0.83 * pi and a < -0.6 * pi then c:put(x, y, BR[6], btok) end
end)
c:put(floor(CX - 10.8), floor(CY - 10.2), A.CREAM, btok)

-- dial
local dial = A.ell(CX, CY, RD - 0.5, RD - 0.5)
dial:each(function(x, y)
  local r, a = A.polar(x, y, CX, CY)
  local t = 4
  -- inner rim shadow: upper-left crescent (the bezel wall), lower-right thin
  local ox, oy = x - 1.6, y - 1.6
  if sqrt((ox - CX) ^ 2 + (oy - CY) ^ 2) > RD - 0.6 then t = 2 end
  if r > RD - 1.4 and t == 4 then t = 3 end
  c:put(x, y, DIAL[t], dtok)
end)
-- faint four-point rose
local rose = HP.mask()
for i = 0, 3 do
  local a = i * pi / 2 - pi / 2
  local ux, uy = cos(a), sin(a)
  rose:add(HP.poly{ { CX + ux * 9.5, CY + uy * 9.5 }, { CX - uy * 2.2, CY + ux * 2.2 }, { CX + uy * 2.2, CY - ux * 2.2 } })
end
rose:each(function(x, y) if dial:has(x, y) then c:put(x, y, DIAL[3], dtok) end end)
-- rose shade halves (right side of each point darker)
rose:each(function(x, y)
  local dx, dy = x - CX, y - CY
  if dial:has(x, y) and ((abs(dy) > abs(dx) and dx > 0) or (abs(dx) > abs(dy) and dy > 0)) then c:put(x, y, DIAL[2], dtok) end
end)
-- cardinal ticks (bold, 2x3 / 3x2) and intercardinal dots
local TK = "#7a4a36"
for i = 0, 3 do
  local a = i * pi / 2
  if i ~= 3 then
    local x, y = CX + cos(a) * 11.4, CY + sin(a) * 11.4
    local w, h = (i % 2 == 0) and 1 or 0, (i % 2 == 0) and 0 or 1
    for dx = 0, w + 1 - (i % 2) do for dy = 0, h + 1 - (1 - i % 2) do end end
    if i % 2 == 0 then c:fillMask(HP.rect(floor(x) - 1, floor(y), floor(x) + 1, floor(y) + 1), TK)
    else c:fillMask(HP.rect(floor(x), floor(y) - 1, floor(x) + 1, floor(y) + 1), TK) end
  end
  local b = a + pi / 4
  c:put(floor(CX + cos(b) * 11 + 0.5), floor(CY + sin(b) * 11 + 0.5), DIAL[1], dtok)
end
-- quirk: toadstool north mark
local tx, ty = floor(CX) - 1, floor(CY) - 13
A.map(c, {
  ".rRr.",
  "rRcRr",
  "dddd.",
  ".sS..",
}, tx - 1, ty + 1, { r = RED[2], R = RED[3], c = A.CREAM, d = RED[1], s = "#e0cfa8", S = "#b89a7a" }, A.tok("toad"))
-- needle: slim diamond pointing NNE, lit half / shade half
local na = -pi / 2 + 0.72
local ux, uy = cos(na), sin(na)
local px, py = -uy, ux
local function half(L, side, col1, col2)
  local tip = { CX + ux * L, CY + uy * L }
  local m1 = HP.poly{ tip, { CX + 0.0, CY + 0.0 }, { CX + px * 3.4 * side, CY + py * 3.4 * side } }
  return m1
end
-- north (red)
local nL = half(11.5, -1) local nR = half(11.5, 1)
local sL = HP.poly{ { CX - ux * 10.5, CY - uy * 10.5 }, { CX, CY }, { CX - px * 3.4, CY - py * 3.4 } }
local sR = HP.poly{ { CX - ux * 10.5, CY - uy * 10.5 }, { CX, CY }, { CX + px * 3.4, CY + py * 3.4 } }
-- drop shadow of the needle on the dial (offset lower-right)
for _, m in ipairs{ nL, nR, sL, sR } do m:copy():shift(1, 2):each(function(x, y)
  if dial:has(x, y) then c:put(x, y, DIAL[1], dtok) end end) end
-- side facing upper-left is lit: for the north half the -p side (left), for the south half the -p side too
c:fillMask(nR, RED[2]) c:fillMask(nL, RED[3])
c:fillMask(sR, STL[2]) c:fillMask(sL, STL[3])
-- ridge highlight along the lit north edge
for t = 3, 9 do local x, y = floor(CX + ux * t - px * 0.6 + 0.5), floor(CY + uy * t - py * 0.6 + 0.5)
  if nL:has(x, y) then c:put(x, y, RED[4], ntok) end end
for t = 3, 6 do local x, y = floor(CX - ux * t - px * 0.6 + 0.5), floor(CY - uy * t - py * 0.6 + 0.5)
  if sL:has(x, y) then c:put(x, y, STL[4], ntok) end end
-- pivot: brass dome 3x3 with AO ring
local pX, pY = floor(CX), floor(CY)
A.map(c, { ".dd.", "dbhd", "dbbd", ".dd." }, pX - 1, pY - 1, { d = BR[2], b = BR[4], h = BR[6] }, A.tok("pivot"))
-- glass glint across the dial (two cream strokes, upper-left)
for i = 0, 3 do c:put(floor(CX) - 8 + i, floor(CY) - 4 - i, A.CREAM, A.tok("glass")) end
for i = 0, 1 do c:put(floor(CX) - 7 + i, floor(CY) - 1 - i, A.CREAM, A.tok("glass")) end
A.save(c, "ico-compass")
