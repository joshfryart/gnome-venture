-- mesquite-flatbread (final, Opus single pass). One round, thin mesquite-flour flatbread seen from above at a slant:
-- cocoa-tan domed top with a puffed rolled rim, a 3 px baked side wall underneath, toasted blisters (dark ring + lit
-- crown), bran flecks and pale flour dust, a griddle-scorch arc. quirk: a bite out of the right rim showing the pale
-- airy crumb, with two crumbs falling below.
local NAME = "mesquite-flatbread"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = A.new(NAME)
local CR = { "#4a2a26", "#6e3d2c", "#93573a", "#b5774a", "#d39c62", "#efc98e" }   -- crust
local SIDE = { "#3e2326", "#5c3329", "#7e4a33", "#a0663f" }
local CRUMB = { "#b98a56", "#dcb67e", "#f2d9a4" }
local BRAN, DUST = "#4f2d26", "#f6e2b4"
local cx, cy, rx, ry = 31, 30, 23.5, 13.5

local function ell(x0, y0, ax, ay) local m = HP.mask()
  for y = floor(y0 - ay) - 1, floor(y0 + ay) + 1 do for x = floor(x0 - ax) - 1, floor(x0 + ax) + 1 do
    if ((x - x0) / (ax + .4)) ^ 2 + ((y - y0) / (ay + .4)) ^ 2 <= 1 then m:set(x, y) end end end
  return m end
local top = ell(cx, cy, rx, ry)
local under = ell(cx, cy + 3, rx, ry)
-- bite: two overlapping round tooth arcs into the right rim
local bite = ell(55.5, 24, 5.2, 4.6):add(ell(53.5, 30.5, 4.2, 3.8))
top:cut(bite) under:cut(bite:shift(0, 1))
local side = under:copy():cut(top)

-- side wall: lit left, dark right, darker at the bottom row
local stok = { r = { name = "side" } }
side:each(function(x, y)
  local u = (x - cx) / rx
  local i = u < -0.55 and 4 or (u < 0.1 and 3 or (u < 0.65 and 2 or 1))
  if not side:has(x, y + 1) then i = max(1, i - 1) end
  c:put(x, y, SIDE[i], stok)
end)

-- top: gentle dome + puffed rim (pillow), toasted
local np = X.pillow(top, 3.2)
local n = {}
for k, a in pairs(np) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local ux, uy = (x - cx) / rx, (y - cy) / ry
  local r = sqrt(ux * ux + uy * uy)
  -- a slight dip just inside the rim (rolled edge reads as a ridge)
  local dip = (r > 0.62 and r < 0.8) and -0.35 or 0
  n[k] = { A.norm(a[1] * 0.9 + ux * (0.32 + dip), a[2] * 0.9 + uy * (0.32 + dip), a[3]) }
end
local tok = { r = { name = "top" } }
local bias = {}
-- bite edge: crust darkens toward the torn edge
X.ao(bias, top, bite, 1, -1)
local idx = A.shade(c, top, n, CR, { amb = 0.1, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = bias, tok = tok })

-- blisters: dark toasted ring, lit crown upper-left
local bl = { { 15, 25, 2 }, { 24, 21, 2 }, { 36, 22, 1 }, { 20, 33, 2 }, { 31, 30, 2 }, { 41, 33, 1 }, { 27, 38, 1 }, { 44, 26, 2 }, { 13, 33, 1 }, { 35, 39, 1 } }
for _, b in ipairs(bl) do
  local bx, by, r = b[1], b[2], b[3]
  for y = by - r, by + r do for x = bx - r - 1, bx + r + 1 do
    local d = ((x - bx) / (r + 0.8)) ^ 2 + ((y - by) / (r + 0.2)) ^ 2
    if top:has(x, y) and d <= 1 then
      local i = idx[K(x, y)] or 3
      if x - bx + y - by >= 0 then A.step(c, idx, CR, x, y, -2, tok) else A.step(c, idx, CR, x, y, -1, tok) end
    end
  end end
  if top:has(bx - 1, by) then c:put(bx - 1, by, CR[6], tok) end
  if r > 1 and top:has(bx, by) then c:put(bx, by, CR[5], tok) end
end
-- bran flecks + flour dust (hash-scattered, hard pixels)
top:each(function(x, y)
  local h = X.hash(x, y, 7)
  local i = idx[K(x, y)] or 3
  if h < 0.045 and i >= 3 then c:put(x, y, BRAN, tok)
  elseif h > 0.965 and i >= 4 then c:put(x, y, DUST, tok) end
end)
-- griddle scorch arc on the lower-right of the top
top:each(function(x, y)
  local ux, uy = (x - cx) / rx, (y - cy) / ry
  local r = sqrt(ux * ux + uy * uy)
  if r > 0.84 and r < 0.97 and ux > 0.05 and uy > 0.25 and X.hash(x, y, 3) < 0.55 then c:put(x, y, CR[1], tok) end
end)

-- bite face: pale airy crumb inside the cut, a dark crust lip on the top edge
local face = bite:grow(1):cut(bite):clip(under:copy():add(top))
local ctok = { r = { name = "crumb" } }
face:each(function(x, y)
  local h = X.hash(x, y, 11)
  local i = (h < 0.22) and 1 or ((x + y) % 3 == 0 and 3 or 2)
  if not bite:has(x - 1, y) and not bite:has(x, y - 1) and bite:has(x + 1, y) then i = min(3, i + 1) end
  c:put(x, y, CRUMB[i], ctok)
end)
-- crust lip: top pixels of the face that touch the upper rim stay dark
face:each(function(x, y) if top:has(x, y) and not top:has(x, y - 1) then c:put(x, y, CR[2], tok) end end)
-- falling crumbs (part of the bite quirk)
for _, q in ipairs{ { 58, 39, 2 }, { 59, 40, 1 }, { 55, 43, 2 } } do c:put(q[1], q[2], CRUMB[q[3]], ctok) end

-- one glint on the dome
c:put(18, 22, "#fff0c8", tok) c:put(19, 22, "#fff0c8", tok)

A.save(c, NAME)
