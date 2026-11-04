-- feast-egg-pie (Opus single pass). A deep-dish egg pie on a blue-banded plate with one wedge already served: the cut face
-- shows the layers (flaky top pastry, golden custard with a halved boiled egg in section, baked base crust). Top: woven
-- lattice over the custard (strips lit on the upper-left, dark where they pass under), a crimped, pillow-lit rim.
-- The plate shows through the gap with an ambient shadow from the pie.
-- quirk: the cracked half-shell of the egg that went in sits on the plate in the empty slot.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_2.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, sqrt, max, min, abs, sin, cos, pi, atan = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.atan
local c = D.new("feast-egg-pie")
local PORC = { "#4a4766", "#7c7c9e", "#a9acc6", "#cdd2e2", "#e6eaf2", "#f8f5ec" }
local BAND = { "#2a4a7a", "#3a6eb0", "#5f9ad0" }
local CRUST = { "#5a2e22", "#8e4e2a", "#c07a36", "#e0a24c", "#f4c872", "#ffe4a4" }
local CUST = { "#8a5a1c", "#c48a22", "#eab432", "#f8d04e", "#ffe47e", "#fff4b8" }
local ptok, ktok, ftok = D.tok("plate"), D.tok("crust"), D.tok("filling")
local CX, CY, RX, RY, H = 32, 33, 19, 8, 10
local A1, A2 = 18, 78

c:groundShadow(32, 55, 21, 1)
-- plate
local PY = 44
local ptop = D.ellipseMask(CX, PY, 25, 8)
local prim = D.sweep(ptop, 2):cut(ptop)
D.toneN(c, prim, D.vcylN(prim, CX, 25, 0.5), PORC, { tok = ptok })
prim:each(function(x, y) if not prim:has(x, y + 1) then c:put(x, y, PORC[2], ptok) end end)
local pieFoot = D.ellipseMask(CX, CY + H, RX, RY)
local function inWedge(x, y, cy)
  local a = math.deg(atan((y - cy) / RY, (x - CX) / RX))
  return a >= A1 and a <= A2
end
local pbias = {}
local footSolid = HP.mask() pieFoot:each(function(x, y) if not inWedge(x, y, CY + H) then footSolid:set(x, y) end end)
X.ao(pbias, ptop, footSolid, 2, -1)
local pn = {} ptop:each(function(x, y) pn[K(x, y)] = { D.norm(0, -0.55, 1) } end)
D.toneN(c, ptop, pn, PORC, { tok = ptok, bias = pbias })
-- blue band on the plate rim + bright back bevel
local inner = D.ellipseMask(CX, PY, 22, 6.5)
ptop:copy():cut(inner):each(function(x, y)
  local d = inner:grow(1):has(x, y)
  if d then c:put(x, y, (y < PY) and BAND[1] or BAND[2], ptok) end end)
ptop:edge():each(function(x, y) if y < PY - 2 and x < CX + 8 then c:put(x, y, PORC[6], ptok) end end)

-- the slot's floor: shadow cast by the cut face onto the plate
local top = D.ellipseMask(CX, CY, RX, RY)
local wedgeTop = HP.mask() top:each(function(x, y) if inWedge(x, y, CY) then wedgeTop:set(x, y) end end)
local floorM = wedgeTop:shift(0, H)
floorM:each(function(x, y) local a = math.deg(atan((y - CY - H) / RY, (x - CX) / RX))
  if a < A1 + 14 or a > A2 - 10 then c:put(x, y, PORC[3], ptok) end end)

-- cut face (plane at A1): parallelogram centre -> rim, extruded down H
local ex, ey = CX + RX * cos(math.rad(A1)), CY + RY * sin(math.rad(A1))
local face = HP.poly{ { CX, CY }, { floor(ex + .5), floor(ey + .5) }, { floor(ex + .5), floor(ey + .5) + H }, { CX, CY + H } }
local faceTok = D.tok("face")
local slope = (ey - CY) / (ex - CX)
local eggX, eggY = CX + (ex - CX) * 0.55, 0
face:each(function(x, y)
  local d = y - (CY + slope * (x - CX))         -- depth below the top edge
  local t = (x - CX) / (ex - CX)
  local col
  if d < 2 then col = (d < 1) and CRUST[6] or CRUST[4]
  elseif d < 3 then col = CRUST[2]
  elseif d >= H - 1 then col = CRUST[2]
  elseif d >= H - 2 then col = CRUST[3]
  else
    col = (t < 0.25) and CUST[3] or CUST[4]
    if X.hash(x, y, 4) > 0.86 then col = CUST[5] end
    if X.hash(x, y, 6) > 0.93 then col = "#5f9a46" end    -- chive fleck
  end
  c:put(x, y, col, faceTok)
end)
-- halved boiled egg in section
local ecx = CX + (ex - CX) * 0.56
local ecy = CY + slope * (ecx - CX) + 5.5
local ew = D.ellipseMask(ecx, ecy, 3.3, 1.9)
ew:each(function(x, y) if face:has(x, y) then c:put(x, y, (x > ecx + 1.5 or y > ecy + 1) and "#e2dccc" or "#fff6e4", faceTok) end end)
local yk = D.ellipseMask(ecx - 0.3, ecy, 1.4, 0.9)
yk:each(function(x, y) if face:has(x, y) then c:put(x, y, "#f5a82a", faceTok) end end)
c:put(floor(ecx - 1), floor(ecy - 0.5), "#ffd65a", faceTok)
-- face edges: right edge darker (turning away), base row ambient
face:each(function(x, y) if not face:has(x + 1, y) then c:put(x, y, CRUST[2], faceTok) end end)

-- pie side wall (solid part only)
local wall = D.sweep(top, H):cut(top):cut(D.sweep(wedgeTop, H)):cut(face)
local widx = D.toneN(c, wall, D.vcylN(wall, CX, RX, 0.2), CRUST, { tok = ktok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
-- fluted wall: vertical flutes every 3 px
wall:each(function(x, y) local i = widx[K(x, y)] or 3
  if (x % 3) == 0 then c:put(x, y, CRUST[max(1, i - 1)], ktok) elseif (x % 3) == 1 and i < 6 then c:put(x, y, CRUST[i + 1], ktok) end
  if not wall:has(x, y + 1) then c:put(x, y, CRUST[1], ktok) end end)

-- top: crimped rim ring + custard + lattice (solid part only)
local solidTop = top:copy():cut(wedgeTop)
local fillM = D.ellipseMask(CX, CY, RX - 3, RY - 2):clip(solidTop)
local rimM = solidTop:copy():cut(fillM)
local rn = X.pillow(rimM, 1.6)
local ridx = D.toneN(c, rimM, rn, CRUST, { tok = ktok })
-- crimps: radial notches around the rim
rimM:each(function(x, y) local a = atan((y - CY) / RY, (x - CX) / RX)
  local s = floor(a / (2 * pi) * 34 + 100) % 2
  local i = ridx[K(x, y)] or 3
  if s == 0 then c:put(x, y, CRUST[max(1, i - 1)], ktok) end end)
local fn = {} fillM:each(function(x, y) fn[K(x, y)] = { D.norm(0, -0.5, 1) } end)
local fbias = {}
X.ao(fbias, fillM, rimM, 1, -1)
local fidx = D.toneN(c, fillM, fn, CUST, { tok = ftok, bias = fbias })
fillM:each(function(x, y) if X.hash(x, y, 8) > 0.9 then c:put(x, y, "#4f8a42", ftok) end end)   -- herb flecks
-- woven lattice: strips along x (rows) and along the ellipse depth (columns)
local function onRow(y) return (y - CY + 40) % 4 == 0 end
local function onCol(x) return (x - CX + 40) % 6 <= 1 end
fillM:each(function(x, y)
  local r, cl = onRow(y), onCol(x)
  if r or cl then
    local over = r
    if r and cl then over = ((x - CX + 40) // 6 + (y - CY + 40) // 4) % 2 == 0 end
    local col = CRUST[5]
    if over and r then col = (X.hash(x, 0, 2) > 0.8) and CRUST[6] or CRUST[5]
    elseif cl then col = ((x - CX + 40) % 6 == 0) and CRUST[5] or CRUST[3] end
    if x > CX + 8 then col = CRUST[4] end
    c:put(x, y, col, ktok)
    -- shadow under strips onto the custard
    if r and fillM:has(x, y + 1) and not onCol(x) then c:put(x, y + 1, CUST[2], ftok) end
  end
end)
-- glints
c:put(20, 30, "#fff4d6", ktok)
-- dark seam at the rim's cut ends
solidTop:each(function(x, y) if wedgeTop:has(x + 1, y) or wedgeTop:has(x, y + 1) or wedgeTop:has(x - 1, y) then
  if not face:has(x, y + 1) then c:put(x, y, CRUST[3], ktok) end end end)

-- quirk: cracked half eggshell in the empty slot
local stok = D.tok("shell")
local shell = {
  ".a.b.a.",
  "bAAcAAb",
  "AAAAAcc",
  ".dAAcd.",
}
local SC = { A = "#fff1dc", a = "#fff1dc", b = "#e8d4b4", c = "#d6bc98", d = "#a88a6e" }
local sx, sy = 40, 45
for yy, row in ipairs(shell) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if SC[ch] then c:put(sx + xx - 1, sy + yy - 1, SC[ch], stok) end end end
c:put(sx + 1, sy + 1, "#c9a04a", stok)    -- a smear of yolk inside
D.save(c, "ph", "feast-egg-pie")
