-- morel (ph, Opus single pass). A slim upright morel: tall rounded-cone cap of honeycomb pits (jittered
-- Voronoi cells, stretched vertically, compressed toward the silhouette so the cap reads round), pale ochre ridges
-- with deep violet-brown pits; each pit is shadowed under its upper-left ridge and lit on the far wall, and the
-- silhouette is nicked where pits meet the edge. Slim hollow cream stem, widening into a bulbous base, with mealy
-- grain specks, a few base wrinkles, AO under the cap and a small ground shadow. One dry specular on a ridge.
-- quirk: a single fallen pine needle lies across the foot of the stem.
local NAME = "morel"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, asin = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.asin
local c = G.new2(NAME)
local CAP  = { "#3a1f2a", "#5e3530", "#8a5636", "#b4813f", "#d8ab5e", "#f2d597" }
local STEM = { "#7d6a76", "#a8968f", "#cdbca6", "#e6d8bb", "#f5ecd1", "#fff8e6" }
local NEEDLE = { "#7a4630", "#b0713d", "#d9a35b" }
local SPEC = "#fff2c8"
local CX = 32

c:groundShadow(32, 56, 10, 2)

-- stem: slim hollow column, bulbous base
local SY0, SY1 = 34, 56
local function shw(y)
  local t = (y - SY0) / (SY1 - SY0)
  return 3.9 - 0.5 * sin(pi * min(1, t * 1.4)) + 2.0 * max(0, t - 0.62) ^ 1.4 * 4
end
local stem = HP.mask()
for y = SY0, SY1 do local h = shw(y)
  for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do stem:set(x, y) end end
local sn = {}
stem:each(function(x, y)
  local h = shw(y)
  local s = max(-0.97, min(0.97, (x + 0.5 - CX) / (h + 0.4)))
  local nyv = (y > SY1 - 3) and 0.5 or 0
  local l = sqrt(s * s + (1 - s * s) + nyv * nyv)
  sn[K(x, y)] = { s / l, nyv / l, sqrt(1 - s * s) / l }
end)
local sbias = {}
stem:each(function(x, y) local k = K(x, y)
  if y <= SY0 + 2 then sbias[k] = -2 elseif y == SY0 + 3 then sbias[k] = -1 end
  -- mealy grain: darker specks, a few pale ones
  local h = X.hash(x, y, 5)
  if y > SY0 + 3 and h > 0.86 then sbias[k] = (sbias[k] or 0) - 1 end
  if y > SY0 + 3 and h < 0.05 then sbias[k] = (sbias[k] or 0) + 1 end
  -- base wrinkles: short vertical grooves
  if y > SY1 - 7 and y < SY1 - 1 and (x == CX - 3 or x == CX + 1 or x == CX + 4) and X.hash(x, y, 9) > 0.25 then sbias[k] = (sbias[k] or 0) - 1 end
end)
local stok = { r = { name = "stem" } }
G.toneN(c, stem, sn, STEM, { tok = stok, bias = sbias, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.1, wrap = 0.35 })

-- cap: rounded cone
local Y0, Y1 = 7, 37
local function hw(y)
  local t = (y - Y0) / (Y1 - Y0)
  local w = 10.4 * sin(min(1, (t + 0.05) / 0.78) * pi / 2) ^ 0.62
  if t > 0.94 then w = w - 0.9 end
  return w
end
local cap = HP.mask()
for y = Y0, Y1 do local h = hw(y) for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do cap:set(x, y) end end

-- honeycomb cells in (arc, height) space
local RN = 9.5
local pts = {}
for j = 0, 8 do
  local vy = Y0 - 1 + j * 4.3
  for i = -4, 4 do
    local u = i * 4.6 + (j % 2) * 2.3 + (X.hash(i, j, 3) - 0.5) * 1.6
    pts[#pts + 1] = { u, vy + (X.hash(i, j, 8) - 0.5) * 1.4 }
  end
end
local D1, D2 = {}, {}
cap:each(function(x, y)
  local h = max(hw(y), 0.6)
  local q = max(-1, min(1, (x + 0.5 - CX) / h))
  local U = asin(q) * RN
  local b1, b2 = 1e9, 1e9
  for _, p in ipairs(pts) do
    local d = sqrt((U - p[1]) ^ 2 + ((y - p[2]) / 1.55) ^ 2)
    if d < b1 then b1, b2 = d, b1 elseif d < b2 then b2 = d end
  end
  D1[K(x, y)], D2[K(x, y)] = b1, b2
end)
local ridge = HP.mask()
cap:each(function(x, y) local k = K(x, y)
  if D2[k] - D1[k] < 0.95 or y <= Y0 + 1 then ridge:set(x, y) end end)
-- nick the silhouette where a pit meets the edge
local nick = HP.mask()
cap:edge():each(function(x, y) if not ridge:has(x, y) and D1[K(x, y)] < 1.5 and y > Y0 + 3 and y < Y1 - 1 then nick:set(x, y) end end)
cap:cut(nick) ridge:cut(nick)

local cn = X.pillow(cap, 6)
local cbias = {}
cap:each(function(x, y) local k = K(x, y)
  if ridge:has(x, y) then cbias[k] = 1
  else
    if ridge:has(x, y - 1) or ridge:has(x - 1, y) then cbias[k] = -3
    elseif ridge:has(x, y + 1) or ridge:has(x + 1, y) then cbias[k] = -1
    else cbias[k] = -2 end
  end
end)
-- the bottom margin of the cap rolls in: darker last row
cap:each(function(x, y) if y >= Y1 then cbias[K(x, y)] = (cbias[K(x, y)] or 0) - 1 end end)
local ctok = { r = { name = "cap" } }
G.toneN(c, cap, cn, CAP, { tok = ctok, bias = cbias, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.12, wrap = 0.3 })
-- cool reflected light on the shade-side ridges
local rim = X.rim(cn)
ridge:each(function(x, y) if rim[K(x, y)] and rim[K(x, y)] > 0.62 and y > Y0 + 8 then c:put(x, y, "#a98a8c", ctok) end end)
-- one dry specular on an upper-left ridge
do
  local bx, by, best
  local sp = X.spec(cn, 30)
  ridge:each(function(x, y) local s = sp[K(x, y)]
    if ridge:has(x + 1, y) and (not best or s > best) then best, bx, by = s, x, y end end)
  c:put(bx, by, SPEC, ctok) c:put(bx + 1, by, CAP[6], ctok)
end

-- quirk: one fallen pine needle across the stem foot
local ntok = { r = { name = "needle" } }
G.pline(c, { { 21, 58 }, { 41, 54 } }, NEEDLE[2], ntok)
c:put(21, 58, NEEDLE[1], ntok) c:put(22, 58, NEEDLE[1], ntok)
for _, p in ipairs{ { 28, 57 }, { 29, 56 }, { 33, 56 }, { 34, 56 } } do
  if c:get(p[1], p[2]) == NEEDLE[2] then c:put(p[1], p[2], NEEDLE[3], ntok) end
end
c:put(41, 54, NEEDLE[1], ntok) c:put(42, 53, NEEDLE[1], ntok)

G.save2(c, NAME)
