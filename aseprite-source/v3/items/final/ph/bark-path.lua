-- bark-path (ph, round 3, artist 4). A short garden path tile: a diagonal bed of shredded bark mulch
-- (Voronoi chips, each lit by its own tilt, dark gaps between) carrying three sawn log-round stepping
-- stones that shrink into the distance. Each round: pale end grain with growth rings, a dark pith, a
-- radial drying crack, a lighter sapwood ring, then a furrowed bark side band (cylinder-lit, AO under the
-- top lip) and a contact shadow on the mulch. quirk: a grey woodlouse curled up on the middle round.
local NAME = "bark-path"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = G.new(NAME)

local MUL = { "#2a1418", "#46201e", "#682e24", "#8c432c", "#ae5e36", "#cc7e48" }
local BARK = { "#2a1a1c", "#43282a", "#613a32", "#80503c", "#9e6a4a", "#bc8862" }
local END = { "#6e3e2a", "#a8693e", "#d09a5e", "#e8bd80", "#f6d89e", "#fdecc2" }
local SAP = "#f6dca8"

-- mulch bed: a ragged diagonal band
local bed = HP.mask()
local function bandW(t) return 7.0 + 1.2 * sin(t * 7.3) + 0.8 * sin(t * 17 + 1) end
local bp = { { 10, 53 }, { 24, 46 }, { 38, 29 }, { 54, 18 } }
local bm, bn, BT, BS = G.tube(bp, function(t) return (bandW(t) - t * 1.6) * min(1, 0.45 + min(t, 1 - t) * 5) end)
bed:add(bm)
-- ragged edge: drop some edge pixels
bm:edge():each(function(x, y) if X.hash(x, y, 3) < 0.35 then bed.s[K(x, y)] = nil end end)
local C, E, cells = G.voronoi(bed, 3, 17)
local mtok = G.tok("mulch")
bed:each(function(x, y) local k = K(x, y)
  local cc = cells[C[k]]
  -- chip tone: random 3..5, lit by tilt and by position across the band (lower-right side darker)
  local i = 3 + floor(cc.tone * 2.99)
  if cc.tilt > 0.6 then i = i + 1 end
  if (BS[k] or 0) > 0.55 then i = i - 1 end
  if E[k] then i = 2 end
  -- top-left edge of each chip catches light
  if not E[k] and ((C[K(x - 1, y)] ~= C[k]) or (C[K(x, y - 1)] ~= C[k])) and cc.tilt > 0.35 then i = i + 1 end
  c:put(x, y, MUL[max(1, min(6, i))], mtok)
end)

-- log rounds: cx, cy (top face centre), rx, ry, side thickness
local rounds = { { 49, 21, 6, 3, 2 }, { 35, 32.5, 8, 4, 3 }, { 18, 46, 10, 5, 3 } }
for ri, r in ipairs(rounds) do
  local cx, cy, rx, ry, th = r[1], r[2], r[3], r[4], r[5]
  local top = c:ellipse(cx, cy, rx, ry)
  local body = HP.mask():add(top)
  for d = 1, th do body:add(c:ellipse(cx, cy + d, rx, ry)) end
  local side = body:copy():cut(top)
  -- contact shadow on the mulch (offset down-right)
  body:shift(1, 1):cut(body):each(function(x, y) if bed:has(x, y) then c:put(x, y, MUL[1], mtok) end end)
  body:shift(2, 1):cut(body):each(function(x, y) if bed:has(x, y) and X.hash(x, y, 9) < 0.5 then c:put(x, y, MUL[1], mtok) end end)
  -- bark side: cylinder lit by x, vertical furrows
  local btok = G.tok("bark" .. ri)
  side:each(function(x, y)
    local u = (x - cx) / (rx + 0.5)
    local i = (u < -0.55) and 4 or (u < 0.05 and 3 or (u < 0.6 and 2 or 1))
    local f = X.hash(floor((x - cx) * 0.7 + 50), ri, 4)
    if (x + ri) % 3 == 0 then i = i - 1 end           -- furrow
    if f > 0.75 then i = i + 1 end                     -- ridge catch
    -- AO under the top lip
    if top:has(x, y - 1) then i = 1 end
    c:put(x, y, BARK[max(1, min(6, i))], btok)
  end)
  -- end grain: rings in elliptical radius, light from upper-left across the face
  local etok = G.tok("end" .. ri)
  local pcx, pcy = cx + rx * 0.12, cy + ry * 0.1      -- pith off-centre (real logs)
  local rings = rx * 0.34
  top:each(function(x, y)
    local dx, dy = (x - pcx) / (rx + 0.3), (y - pcy) / (ry + 0.3)
    local rr = sqrt(dx * dx + dy * dy)
    local ex, ey = (x - cx) / (rx + 0.5), (y - cy) / (ry + 0.5)
    local er = sqrt(ex * ex + ey * ey)
    local ang = atan(dy, dx)
    local wob = 0.05 * sin(ang * 3 + ri)
    local ph = (rr + wob) * rings
    local i = 4
    local function phAt(xx, yy) local ddx, ddy = (xx - pcx) / (rx + 0.3), (yy - pcy) / (ry + 0.3)
      return (sqrt(ddx * ddx + ddy * ddy) + 0.05 * sin(atan(ddy, ddx) * 3 + ri)) * rings end
    if rr > 0.18 and (floor(phAt(x - 1, y)) ~= floor(ph) or floor(phAt(x, y - 1)) ~= floor(ph)) then i = 2 end   -- growth ring contour
    local lit = -(ex + ey) * 0.5                                     -- upper-left brighter
    if lit > 0.28 then i = i + 1 elseif lit < -0.32 then i = i - 1 end
    if er > 0.8 then i = (ex + ey < -0.2) and 6 or 5 end             -- sapwood ring
    if er > 0.8 and ex + ey > 0.7 then i = 3 end
    if rr < 0.16 then i = 1 end                                       -- pith
    c:put(x, y, END[max(1, min(6, i))], etok)
  end)
  -- outer bark lip ring on the top face (thin dark line at the rim, lower half only)
  top:edge():each(function(x, y) if y >= cy then c:put(x, y, BARK[3], etok) else c:put(x, y, BARK[5], etok) end end)
  -- radial crack from pith toward lower-right
  local ang = 0.55 + ri * 0.35
  for s = 1, rx * 0.75, 0.5 do
    local x, y = floor(pcx + cos(ang) * s + .5), floor(pcy + sin(ang) * s * ry / rx + .5)
    if top:has(x, y) then c:put(x, y, END[1], etok) if top:has(x + 1, y) and s < rx * 0.4 then c:put(x + 1, y, END[2], etok) end end
  end
  -- sawn sheen: one bright 2px on the lit face
  c:put(floor(cx - rx * 0.45), floor(cy - ry * 0.35), END[6], etok) c:put(floor(cx - rx * 0.45) + 1, floor(cy - ry * 0.35), END[6], etok)
end

-- a few loose chips spilling off the bed edge
for _, q in ipairs{ { 7, 44, 5 }, { 8, 44, 4 }, { 52, 28, 5 }, { 53, 28, 4 }, { 53, 29, 3 } } do c:put(q[1], q[2], MUL[q[3]], mtok) end

-- quirk: curled woodlouse on the middle round (segmented grey pill)
local W = { "#3a3a4e", "#5e5e74", "#8a8aa0", "#b8b8cc" }
local wt = G.tok("louse")
local wx, wy = 31, 29
local rows = { "  2332  ", " 123432 ", " 123321 ", "  1221  " }
for j, row in ipairs(rows) do for i = 1, #row do local ch = row:sub(i, i)
  if ch ~= " " then c:put(wx + i - 1, wy + j - 1, W[tonumber(ch)], wt) end end end
-- segment lines
for _, q in ipairs{ { 33, 30 }, { 35, 30 }, { 34, 31 } } do c:put(q[1], q[2], W[1], wt) end
c:put(33, 29, "#fff4d6", wt)

G.done(c, NAME)
