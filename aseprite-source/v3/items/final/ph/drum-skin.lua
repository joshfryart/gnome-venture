-- drum-skin (final, Opus single pass). A rawhide skin stretched over a slim bentwood hoop, seen in 3/4 from above:
-- a wide oval drumhead, the hide lapped over the rim with a ragged edge, and twisted cord lacing in V's down the hoop.
-- Material: per-pixel domed (taut) membrane on a 6-tone parchment ramp with hair-follicle flecks, a darker worn
-- strike spot, sheen glint; hoop on a 6-tone wood ramp with curved grain and a deep bottom row; cords alternate two
-- tones per pixel (twist) with knots; AO under the lapped hide.
-- quirk: a small darker hide patch is sewn on near the rim with gold stitches.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, max, min, sqrt, pi = math.floor, math.abs, math.sin, math.cos, math.max, math.min, math.sqrt, math.pi
local c = A.new("drum-skin")
local H  = { "#6a4636", "#98694e", "#c2946c", "#dcb88a", "#eed4a6", "#fbebc6" }
local WD = { "#3f2226", "#64352c", "#8c5235", "#b1733f", "#d29a58", "#ecc283" }
local CD = { "#5a2a2e", "#a8443a", "#d8704a" }
local htok, wtok, ctok = { r = { name = "hide" } }, { r = { name = "hoop" } }, { r = { name = "cord" } }
local CX, CY, RX, RY, DEPTH = 32, 27, 21.5, 11.5, 7

local function ell(dy, grow) return c:ellipse(CX, CY + dy, RX + (grow or 0), RY + (grow or 0)) end
local E = ell(0)
local shell = HP.mask()
for d = 0, DEPTH do shell:add(ell(d)) end
shell:cut(E)
-- lap: hide folded over the rim, 2-3 px, ragged lower edge
local lap = HP.mask()
shell:each(function(x, y)
  local ytop = nil
  for yy = y, y - DEPTH - 1, -1 do if E:has(x, yy) then ytop = yy break end end
  if ytop then
    local depth = y - ytop
    local lim = 2 + ((X.hash(x // 2, 0, 9) > 0.55) and 1 or 0)
    if depth <= lim then lap:set(x, y) end
  end
end)
local wood = shell:copy():cut(lap)

-- hoop: cylinder-ish normals (facing out from the ellipse), grain follows the curve
local wn, wb = {}, {}
wood:each(function(x, y) local nx = (x - CX) / (RX + 0.6)
  wn[K(x, y)] = { A.norm(nx, 0.25, sqrt(max(0.05, 1 - nx * nx))) } end)
-- AO under the lap
X.ao(wb, wood, lap, 1, -1)
local wi = A.shade(c, wood, wn, WD, { amb = 0.18, wrap = 0.35, bias = wb, tok = wtok })
-- grain: lines at fixed depth below the rim curve
wood:each(function(x, y)
  local yb = nil
  for yy = y, y - DEPTH - 2, -1 do if E:has(x, yy) then yb = yy break end end
  if yb then local dd = y - yb
    if (dd == 5 and X.hash(x // 5, 1, 4) > 0.3) or (dd == 4 and X.hash(x // 3, 2, 4) < 0.18) then
      c:put(x, y, WD[max(1, (wi[K(x, y)] or 3) - 1)], wtok) end
  end
end)
-- bottom deep row + a lit bevel just under the lap
wood:each(function(x, y) if not shell:has(x, y + 1) then c:put(x, y, WD[1], wtok) end end)

-- lap (hide over the rim)
local ln = {}
lap:each(function(x, y) local nx = (x - CX) / (RX + 0.6) ln[K(x, y)] = { A.norm(nx, -0.15, sqrt(max(0.05, 1 - nx * nx))) } end)
local li = A.shade(c, lap, ln, H, { amb = 0.1, wrap = 0.3, tok = htok })
-- dark crease where the head turns over the rim
E:edge():each(function(x, y) if y > CY and lap:has(x, y + 1) then c:put(x, y, H[3], htok) end end)

-- membrane: taut slight dome
local np = X.pillow(E, 4)
local nn = {}
for k, v in pairs(np) do nn[k] = { A.norm(v[1] * 0.9, v[2] * 1.4 - 0.05, v[3] * 1.4) } end
local mi = A.shade(c, E, nn, H, { amb = 0.3, wrap = 0.35, cuts = { 0.25, 0.42, 0.58, 0.74, 0.9 }, tok = htok })
-- edge on the far (top) side is the rim seen from inside: a thin darker band
E:edge():each(function(x, y) if y < CY then c:put(x, y, H[3], htok) end end)
-- worn strike spot (centre-left), one step down
E:each(function(x, y) local dx, dy = (x - (CX - 3)) / 6.5, (y - (CY + 1)) / 3.6
  local q = dx * dx + dy * dy
  if q < 1 and q > 0.45 and X.hash(x, y, 2) > 0.35 then local k = K(x, y) c:put(x, y, H[max(1, (mi[k] or 4) - 1)], htok) end end)
-- hair-follicle flecks + a couple of fibre veins
E:shrink(2):each(function(x, y) local h = X.hash(x, y, 77)
  if h < 0.045 then c:put(x, y, H[max(1, (mi[K(x, y)] or 4) - 1)], htok) end end)
for _, v in ipairs{ { 16, 25, 1, 0, 5 }, { 40, 32, 1, 0, 4 }, { 27, 20, 1, 0, 4 } } do
  for i = 0, v[5] - 1 do local x, y = v[1] + i, v[2] + ((i % 3 == 2) and 1 or 0) if E:has(x, y) then c:put(x, y, H[max(1, (mi[K(x, y)] or 4) - 1)], htok) end end
end
-- sheen glint upper-left
c:put(19, 21, H[6], htok) c:put(20, 21, H[6], htok) c:put(19, 20, "#fff6dc", htok)

-- quirk: sewn patch near the right rim
do
  local P = { "#8a5a40", "#a8704e", "#c08a60" }
  local pm = c:rrect(40, 22, 46, 26, 1)
  pm:each(function(x, y) local t = (x == 40 or y == 22) and 3 or ((x == 46 or y == 26) and 1 or 2) c:put(x, y, P[t], htok) end)
  c:put(43, 24, P[1], htok)
  -- gold stitch (2 on 1 off) just outside the patch top + left
  c:stitch{ { 39, 21 }, { 47, 21 }, { 47, 27 }, { 39, 27 }, { 39, 22 } }
end

-- lacing: V cords on the visible front of the hoop, twisted
local function cordLine(x0, y0, x1, y1)
  local N = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, N do local t = N == 0 and 0 or i / N
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    c:put(x, y, (i % 2 == 0) and CD[3] or CD[2], ctok)
  end
end
local function onRim(th, dy) return floor(CX + (RX - 0.3) * cos(th) + .5), floor(CY + RY * sin(th) + dy + .5) end
local NV = 7
for i = 0, NV - 1 do
  local tA = pi * (0.1 + 0.8 * i / (NV - 1))
  local ta2 = pi * (0.1 + 0.8 * (i + 1) / (NV - 1))
  local ax, ay = onRim(tA, 2)
  if i < NV - 1 then
    local mx, my = onRim((tA + ta2) / 2, DEPTH - 1)
    local bx, by = onRim(ta2, 2)
    cordLine(ax, ay, mx, my) cordLine(mx, my, bx, by)
    c:put(mx, my, CD[1], ctok)
  end
  -- lace hole in the lapped hide
  c:put(ax, ay - 1, H[1], htok)
end
A.save(c, "drum-skin")
