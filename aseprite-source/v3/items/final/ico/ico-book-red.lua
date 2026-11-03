-- ico-book-red (final pass, Opus). A thick red tome lying flat, seen from above at a 2:1 angle.
-- Structure: bevelled top board with a gold-tooled frame and a gold sun boss, rounded spine on the left-front face with
-- raised gold bands, page block on the right-front face (boards overhang top and bottom), brass corner caps and a
-- brass clasp strap running over the fore-edge.
-- Material: per-pixel plane + bevel light (top lit, left face mid, right face shade), leather grain and scuffs,
-- page lines with AO under the board, brass bevel + specular, cool bounce on the spine underside.
-- quirk: a little bookworm peeks out of a hole it chewed in the fore-edge.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_3.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new("ico-book-red")
local GO, BR, PG, MO = R.gold, R.brass, R.page, R.moss
local RD = { "#4a1830", "#6c1e3a", "#94223a", "#bc2c3a", "#dc4646", "#f47a68" }  -- crimson morocco

-- corners of the top board (2:1 iso)
local AX, AY = 9, 27    -- left
local BX, BY = 29, 17   -- back
local CX, CY = 55, 30   -- right
local DX, DY = 35, 40   -- front
local T = 9             -- thickness

-- underside board (shows as a 1px lip below the pages and spine)
local under = A.poly{ { AX, AY + T }, { DX, DY + T }, { CX, CY + T }, { CX, CY + T + 1 }, { DX, DY + T + 1.5 }, { AX, AY + T + 1 } }
under:each(function(x, y) c:put(x, y, RD[1]) end)

-- right-front face: page block D->C, inset under the board overhang
local pages = A.poly{ { DX, DY + 1 }, { CX - 1, CY + 1.5 }, { CX - 1, CY + T - 0.5 }, { DX, DY + T } }
pages:each(function(x, y)
  local yy = y - (DX - x) * -0.5    -- distance down from the top edge along the face
  local d = y - (DY + 1 + (x - DX) * (CY - DY) / (CX - DX))
  local t = (floor(d) % 2 == 0) and PG[4] or PG[3]
  if d < 1 then t = PG[2] end                 -- AO under the board
  if x >= CX - 3 then t = (floor(d) % 2 == 0) and PG[3] or PG[2] end
  c:put(x, y, t)
end)
-- bottom board lip on the right face
for x = DX, CX - 1 do
  local y = floor(DY + T + (x - DX) * (CY - DY) / (CX - DX) + 0.5)
  c:put(x, y, RD[2]) c:put(x, y + 1, RD[1])
end
c:put(CX, CY + 1, RD[2])
for y = CY + 1, CY + T + 1 do c:put(CX, y, RD[2]) end

-- left-front face: rounded spine A->D
local spine = A.poly{ { AX, AY + 0.5 }, { DX + 0.5, DY + 0.5 }, { DX + 0.5, DY + T + 1 }, { AX, AY + T + 0.5 } }
local sidx = A.face(c, spine, RD, { base = { -0.35, 0.25, 0.9 }, grain = 0.04, seed = 11,
  nfn = function(x, y, n)
    local top = AY + (x - AX) * (DY - AY) / (DX - AX)
    local u = ((y - top) - (T / 2)) / (T / 2 + 0.6)   -- -1 top .. 1 bottom
    return n[1] - 0.2, u * 0.9 + 0.1, 0.8
  end })
-- raised gold bands on the spine
for _, bx in ipairs{ 13, 17, 27, 31 } do
  for y = 0, T + 1 do
    local x = bx
    local top = AY + (x - AX) * (DY - AY) / (DX - AX)
    local yy = floor(top + y + 0.5)
    if spine:has(x, yy) then
      local i = sidx[K(x, yy)] or 3
      c:put(x, yy, GO[min(6, i + 1)])
      if spine:has(x + 1, yy) then c:put(x + 1, yy, GO[max(1, i - 1)]) end
    end
  end
end
-- cool bounce under the spine roll
for x = AX + 2, DX - 1 do
  local top = AY + (x - AX) * (DY - AY) / (DX - AX)
  local y = floor(top + T + 0.5) - 0
  if spine:has(x, y) and x % 3 ~= 0 then c:put(x, y, "#7a3a6a") end
end

-- top board
local top = A.poly{ { AX, AY }, { BX, BY }, { CX, CY }, { DX, DY } }
local tidx = A.face(c, top, RD, { R = 2.4, bev = 0.8, base = { 0.05, -0.35, 0.9 }, grain = 0.03, seed = 5, cuts = { 0.34, 0.56, 0.74, 0.87, 0.95 },
  nfn = function(x, y, n) return n[1] + (x - 32) / 70, n[2] + (y - 28) / 50, n[3] end })
-- spine roll edge where the top meets the spine (lit lip)
for x = AX + 1, DX - 1 do
  local y = floor(AY + (x - AX) * (DY - AY) / (DX - AX) + 0.5)
  if top:has(x, y - 1) then A.step(c, tidx, RD, x, y - 1, 1) end
end

-- gold-tooled frame: inset rhombus
local function lerp(a, b, t) return a + (b - a) * t end
local cx, cy = (AX + CX) / 2, (BY + DY) / 2
local function ins(px, py, s) return cx + (px - cx) * s, cy + (py - cy) * s end
local s = 0.72
local fa = { ins(AX, AY, s) } local fb = { ins(BX, BY, s) } local fc = { ins(CX, CY, s) } local fd = { ins(DX, DY, s) }
local function fline(p, q, col)
  A.seg(floor(p[1] + .5), floor(p[2] + .5), floor(q[1] + .5), floor(q[2] + .5)):each(function(x, y)
    if top:has(x, y) then c:put(x, y, col) end end)
end
fline(fa, fb, GO[5]) fline(fb, fc, GO[4]) fline(fc, fd, GO[2]) fline(fd, fa, GO[3])

-- gold sun boss in the centre
local boss = A.ellM(cx, cy, 4.2, 2.4)
local bn = {}
boss:each(function(x, y) local u, v = (x - cx) / 4.7, (y - cy) / 2.9
  bn[K(x, y)] = { A.norm(u, v * 1.2 - 0.5, math.sqrt(max(0.05, 1 - u * u - v * v))) } end)
X.tone(c, boss, X.light(bn, { amb = 0.1, wrap = 0.2 }), GO, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
-- rays
for _, r in ipairs{ { -7, 0 }, { 7, 0 }, { 0, -4 }, { 0, 4 }, { -5, -3 }, { 5, 3 }, { 5, -3 }, { -5, 3 } } do
  local x, y = floor(cx + r[1] + 0.5), floor(cy + r[2] + 0.5)
  if top:has(x, y) then c:put(x, y, (r[1] + r[2] < 0) and GO[5] or GO[3]) end
end
c:put(floor(cx) - 1, floor(cy) - 1, A.CREAM)
-- sunk shadow under the boss
boss:shift(1, 1):each(function(x, y) if not boss:has(x, y) and tidx[K(x, y)] then A.step(c, tidx, RD, x, y, -2) end end)

-- brass corner caps (left, back, right corners of the top board)
local function cap(pts)
  local m = A.poly(pts)
  A.face(c, m, BR, { R = 1.1, base = { 0, -0.3, 0.9 }, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  return m
end
cap{ { AX - 0.5, AY }, { AX + 6, AY - 3.2 }, { AX + 6, AY + 3.2 } }
cap{ { BX - 6, BY + 3 }, { BX, BY - 0.5 }, { BX + 6, BY + 3 }, { BX, BY + 5 } }
cap{ { CX + 0.5, CY }, { CX - 6, CY + 3.2 }, { CX - 6, CY - 3.2 } }

-- quirk: bookworm in a chewed hole on the fore-edge (before the clasp)
local wx, wy = 41, 41
A.map(c, {
  "..abb.",
  ".abcbb",
  "aKbbcd",
  "hbbcdd",
  "HhdddH",
  "HHHHHH",
}, wx, wy, { a = MO[6], b = MO[5], c = MO[4], d = MO[3], K = A.INK, h = PG[1], H = "#5a3a40" })
c:put(wx + 2, wy + 1, A.CREAM)

-- brass clasp strap from the top board over the fore-edge
local sx = 47
for i = 0, 2 do
  local x = sx + i
  local ytop = floor(DY + (x - DX) * (CY - DY) / (CX - DX) + 0.5)
  for y = ytop - 4, ytop + T - 1 do
    local col = (i == 0) and BR[5] or (i == 1 and BR[4] or BR[2])
    if y > ytop + 1 then col = (i == 0) and BR[4] or (i == 1 and BR[3] or BR[2]) end
    if y == ytop or y == ytop + 1 then col = (i == 0) and BR[6] or BR[4] end
    c:put(x, y, col)
  end
end
-- clasp catch (a small brass knob on the strap)
do local ky = floor(DY + (sx + 1 - DX) * (CY - DY) / (CX - DX) + 0.5) + 4
  c:put(sx, ky, BR[6]) c:put(sx + 1, ky, BR[5]) c:put(sx + 2, ky, BR[3])
  c:put(sx, ky + 1, BR[4]) c:put(sx + 1, ky + 1, BR[2]) c:put(sx + 2, ky + 1, BR[1]) end

A.save(c, "ico-book-red")
