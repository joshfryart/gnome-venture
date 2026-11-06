-- beetle-shell (final pass, Opus). An empty jewel-beetle carapace seen from above: a narrow domed pronotum with a
-- median groove and two pits, a small scutellum triangle, and two long elytra that meet at a dark suture and taper
-- to rounded tips. Glossy chitin: per-elytron dome light on a violet 6-ramp, iridescent teal-green sheen on the lit
-- shoulders, cool reflected light on the shade margin, punctate striae (dotted rows) following the curve, AO at the
-- pronotum/elytra joint and along the suture, two specular streaks.
-- quirk: the tip of a folded amber hind wing still pokes out from under the right elytron.
local NAME = "beetle-shell"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR4_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = A.new(NAME)
local VIO = { "#1f1436", "#33205c", "#4c2f8c", "#6a44b8", "#9070dc", "#c4a8f4" }
local IRI = { "#2c6f86", "#3fa0a4", "#6ad0b4" }     -- teal-green sheen
local COOL = "#3c5a9c"
local SPEC = "#f2eaff"
local WING = { "#8a4a24", "#c98a3c", "#ecc47a", "#fbe6ae" }

local CX = 32
-- elytra: half-width profile along y (shoulders at top, taper to tip)
local Y0, Y1 = 22, 57
local function hw(y)
  local t = (y - Y0) / (Y1 - Y0)
  if t < 0 or t > 1 then return -1 end
  local w = 12.2 * (1 - t ^ 2.6) ^ 0.55
  if t < 0.08 then w = w - (0.08 - t) * 22 end
  return w
end
-- wing tip quirk (drawn first so the elytron sits over it)
local wm, wn, WT, WS = A.blade(36, 49, 43, 52, 47, 58, function(t)
  if t > 0.97 then return -1 end
  return max(0.4, 2.6 * sin(pi * min(1, t * 0.75 + 0.25)) ^ 0.8)
end, { fold = 0.2 })
local wtok = { r = { name = "wing" } }
wm:each(function(x, y) local k = K(x, y)
  local s, t = WS[k], WT[k]
  local i = s < -0.2 and 3 or 2
  if s > 0.55 then i = 1 end
  if abs(s + 0.05) < 0.16 and t > 0.15 then i = 1 end          -- main vein
  if t > 0.55 and s < -0.35 then i = 4 end                      -- pale membrane tip
  c:put(x, y, WING[i], wtok)
end)

-- elytra masks
local L, R = HP.mask(), HP.mask()
for y = Y0, Y1 do
  local w = hw(y)
  if w > 0 then
    for x = floor(CX - w + 0.5), CX - 1 do L:set(x, y) end
    for x = CX, floor(CX - 1 + w + 0.5) do R:set(x, y) end
  end
end
-- slight gap at the very tips (elytra tips part a little)
for y = Y1 - 3, Y1 do L:cut(HP.rect(CX - 1, y, CX - 1, y)) R:cut(HP.rect(CX, y, CX, y)) end
R:cut(HP.rect(CX, Y1 - 5, CX, Y1 - 4))
-- pronotum
local pm = HP.ellipse(CX - 0.5, 17, 8, 5.5)
pm:cut(HP.rect(0, 22, 63, 63))
pm:add(HP.rect(CX - 8, 19, CX + 7, 21))
-- head stub (empty shell: just the front rim)
local hm = HP.ellipse(CX - 0.5, 10.5, 4, 2.5)
hm:cut(pm)

local bias = {}
X.ao(bias, L, pm, 1, -1) X.ao(bias, R, pm, 1, -1)
local tok = { r = { name = "chitin" } }

local function elytron(m, side)
  local ecx = CX - 0.5 + side * 6
  local n = A.dome(m, ecx, 36, 13, 3, 0.55)
  -- stretch: make the elytra more cylindrical along their length
  for k, v in pairs(n) do n[k] = { A.norm(v[1] * 1.15, v[2] * 0.55, v[3]) } end
  local b = {}
  for k, v in pairs(bias) do b[k] = v end
  -- AO along the suture
  m:each(function(x, y) if abs(x - (CX - 0.5)) < 1 then b[K(x, y)] = (b[K(x, y)] or 0) - 1 end end)
  local idx = A.shade(c, m, n, VIO, { amb = 0.1, wrap = 0.3, bias = b, cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 }, tok = tok })
  -- iridescent sheen: lit shoulder pixels facing left/up
  m:each(function(x, y) local k = K(x, y) local nn = n[k]
    if side < 0 and nn[1] < -0.45 and y < 44 and idx[k] >= 4 then c:put(x, y, idx[k] >= 5 and IRI[3] or IRI[2], tok)
    elseif side < 0 and nn[1] < -0.62 and y >= 44 and y < 52 then c:put(x, y, IRI[1], tok)
    elseif side > 0 and nn[1] > 0.6 and y > 26 and y < 52 then c:put(x, y, COOL, tok) end
  end)
  -- punctate striae: dotted rows following the taper
  for _, f in ipairs{ 0.3, 0.58 } do
    for y = Y0 + 3, Y1 - 4, 2 do
      local w = hw(y)
      local x = floor(CX - 0.5 + side * (0.5 + f * w) + 0.5)
      local k = K(x, y)
      if idx[k] and not (side < 0 and n[k][1] < -0.45 and y < 44) then A.step(c, idx, VIO, x, y, -1, tok) end
    end
  end
  return idx, n
end
local li = elytron(L, -1)
local ri = elytron(R, 1)
-- suture line
for y = Y0, Y1 - 4 do c:put(CX - 1, y, VIO[1], tok) end
c:put(CX, Y0, VIO[2], tok)

-- pronotum: domed, slightly darker, median groove + two pits
local pn = A.dome(pm, CX - 0.5, 18, 9, 2.5, 0.6)
local pt = { r = { name = "pronotum" } }
local pidx = A.shade(c, pm, pn, VIO, { amb = 0.1, wrap = 0.3, cuts = { 0.22, 0.38, 0.54, 0.72, 0.9 }, tok = pt })
for y = 13, 20 do A.step(c, pidx, VIO, CX - 1, y, -1, pt) end
A.step(c, pidx, VIO, CX - 4, 17, -2, pt) A.step(c, pidx, VIO, CX + 3, 17, -2, pt)
A.step(c, pidx, VIO, CX - 4, 16, 1, pt) A.step(c, pidx, VIO, CX + 3, 16, 1, pt)
-- iridescent rim on the lit front edge
pm:edge():each(function(x, y) if x < CX - 3 and y < 19 then c:put(x, y, IRI[2], pt) end end)
-- joint shadow row under the pronotum
for x = CX - 8, CX + 7 do if L:has(x, 22) or R:has(x, 22) then c:put(x, 22, VIO[1], tok) end end
-- scutellum
for _, p in ipairs{ { -2, 23, 4 }, { -1, 23, 5 }, { 0, 23, 3 }, { 1, 23, 3 }, { -1, 24, 4 }, { 0, 24, 3 }, { -1, 25, 3 }, { 0, 25, 2 } } do
  c:put(CX + p[1], p[2], VIO[p[3]], tok) end
-- head rim
local htok = { r = { name = "head" } }
hm:each(function(x, y) c:put(x, y, (x < CX - 1 and y < 11) and VIO[3] or VIO[2], htok) end)
c:put(CX - 3, 9, VIO[4], htok)
for x = CX - 3, CX + 2 do c:put(x, 12, VIO[1], htok) end

-- specular streaks (glossy: two allowed)
for _, p in ipairs{ { 25, 28 }, { 25, 29 }, { 24, 30 }, { 24, 31 } } do c:put(p[1], p[2], SPEC, tok) end
c:put(25, 30, VIO[6], tok) c:put(26, 28, VIO[6], tok)
c:put(36, 27, VIO[6], tok) c:put(36, 28, SPEC, tok)
c:put(28, 15, SPEC, pt) c:put(29, 15, VIO[6], pt)


A.save(c, NAME)
