-- lentil-dal (final, Opus single pass). A shallow cobalt-glazed bowl on a short foot ring (glaze bevel, specular,
-- cream slip band, unglazed clay lip) filled with golden dal: domed surface lit per pixel, lentil grain flecks, a
-- red chilli-oil tadka swirl, cumin seeds, a dried red chilli and a coriander leaf; a short steam curl rises.
-- quirk: a fat drip of dal has run over the rim and down the outside of the bowl.
local NAME = "lentil-dal"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi, sqrt = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.sqrt
local c = A.new(NAME)

local BOWL = { "#1c2250", "#28367a", "#3650a4", "#4a72c6", "#78a4e0", "#bcdcf4" }
local CLAY = { "#7a4a34", "#a86a48", "#d09a6c", "#ecc89a" }
local SLIP = { "#a89cb0", "#d8d0cc", "#f4ecdc" }
local DAL  = { "#8a4812", "#b86a16", "#dc9220", "#f0b434", "#f8d062", "#fff0a6" }
local OIL  = { "#9a2a18", "#d0441e", "#f06a2a" }
local CHIL = { "#6e1a1e", "#b02a26", "#e04a34", "#ff8a6a" }
local GRN  = { "#24543e", "#3f8a4e", "#72b85a", "#a8d878" }
local CUM  = { "#3e2818", "#6a4628", "#9a7044" }
local STEAM = { "#d8d2dc", "#f4eee8" }

local CX, RY0 = 32, 31
c:groundShadow(32, 53, 12, 1)

-- bowl outer body: lower half-ellipse + rim ellipse + foot
local rim = c:ellipse(CX, RY0, 20, 6)
local body = c:ellipse(CX, RY0, 20, 17):clip(c:rect(0, RY0, 63, 63)):add(rim)
body:cut(c:rect(0, 46, 63, 63))
local foot = c:rrect(23, 45, 41, 51, 2)
local ftok = { r = { name = "foot" } }
local fn = X.pillow(foot, 2)
A.shade(c, foot, fn, BOWL, { tok = ftok, amb = 0.05, cuts = { 0.25, 0.42, 0.58, 0.74, 0.9 } })
for x = 24, 40 do c:put(x, 45, BOWL[1], ftok) end            -- AO under the bowl belly
local btok = { r = { name = "bowl" } }
local outer = body:copy():cut(rim)
local bn = A.body(outer, CX - 1, RY0 - 2, 20, 6, 0.65)
local bidx = A.shade(c, outer, bn, BOWL, { tok = btok, amb = 0.04, wrap = 0.2 })
-- cream slip band following the belly curve
outer:each(function(x, y) local dx = (x - CX) / 20
  local yb = RY0 + 6 + 3.6 * sqrt(max(0, 1 - dx * dx))
  if y == floor(yb + 0.5) or y == floor(yb + 0.5) + 1 then
    local i = bidx[K(x, y)] or 3
    c:put(x, y, (i >= 5) and SLIP[3] or ((i >= 3) and SLIP[2] or SLIP[1]), btok) end end)
-- dots on the slip band
for _, x in ipairs{ 16, 22, 28, 34, 40, 46 } do local dx = (x - CX) / 20
  local yb = floor(RY0 + 6 + 3.6 * sqrt(max(0, 1 - dx * dx)) + 0.5) + 3
  if outer:has(x, yb) then c:put(x, yb, BOWL[max(1, (bidx[K(x, yb)] or 3) + 1)], btok) end end
-- glaze specular: short streak upper-left, cool reflected light lower-right
for _, p in ipairs{ {16, 36}, {17, 37}, {17, 38} } do c:put(p[1], p[2], A.CREAM, btok) end
c:put(16, 37, BOWL[6], btok)
local rl = X.rim(bn)
outer:edge():each(function(x, y) if (rl[K(x, y)] or 0) > 0.75 and y > RY0 + 3 then c:put(x, y, "#5a7cb4", btok) end end)

-- rim: unglazed clay lip ring, inner wall, dal surface
local inner = c:ellipse(CX, RY0, 18.4, 4.7)
local lip = rim:copy():cut(inner)
local rtok = { r = { name = "lip" } }
lip:each(function(x, y) local dx, dy = x - CX, y - RY0
  local i = 3
  if dy < -2 then i = 4 elseif dy > 2 then i = 2 end
  if dx > 12 and dy > 0 then i = 1 end
  if dx < -14 then i = 4 end
  c:put(x, y, CLAY[i], rtok) end)
local wtok = { r = { name = "wall" } }
inner:each(function(x, y) local dx = (x - CX) / 18.4
  c:put(x, y, dx < -0.2 and BOWL[2] or (dx < 0.4 and BOWL[3] or BOWL[4]), wtok) end)
-- dal surface sits lower than the rim: domed
local dal = c:ellipse(CX, RY0 + 1.2, 17.4, 3.9):clip(inner)
local dn = {}
dal:each(function(x, y) local nx, ny = (x - CX) / 22, (y - RY0 - 1.2) / 10 dn[K(x, y)] = { A.norm(nx, ny - 0.15, 1) } end)
local dtok = { r = { name = "dal" } }
local dbias = {}
dal:each(function(x, y) if y <= RY0 - 2 then dbias[K(x, y)] = -1 end end)   -- AO under the far rim
local didx = A.shade(c, dal, dn, DAL, { tok = dtok, amb = 0.25, wrap = 0.4, bias = dbias, cuts = { 0.2, 0.36, 0.5, 0.64, 0.8 } })
-- lentil grain flecks
dal:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 21)
  if h < 0.12 then c:put(x, y, DAL[max(1, (didx[k] or 3) - 1)], dtok) elseif h > 0.9 then c:put(x, y, DAL[min(6, (didx[k] or 3) + 1)], dtok) end end)
-- chilli-oil tadka swirl (arc)
for i = 0, 18 do local a = pi * 0.15 + i / 18 * pi * 1.25
  local x, y = floor(CX + 2 + cos(a) * 8 + 0.5), floor(RY0 + 1.5 + sin(a) * 2.1 + 0.5)
  if dal:has(x, y) then c:put(x, y, (i < 5) and OIL[3] or ((i < 12) and OIL[2] or OIL[1]), dtok) end end
-- cumin seeds (2 px diagonal ticks)
for _, p in ipairs{ {20, 32}, {25, 30}, {41, 33}, {44, 31}, {30, 34}, {37, 29} } do
  c:put(p[1], p[2], CUM[1], dtok) c:put(p[1] + 1, p[2] - 1, CUM[2], dtok) end
-- coriander leaf
A.map(c, { ".gg.", "ghhg", ".gs." }, 22, 29, { g = GRN[2], h = GRN[4], s = GRN[1] }, { r = { name = "cori" } })
c:put(23, 30, GRN[3], { r = { name = "cori" } })
-- dried red chilli, lying across the dal
local chm, chn = A.tube({ {35, 31}, {38, 30}, {41, 29.5}, {44, 30} }, function(t) return 1.2 - 0.7 * t end)
chm:clip(inner)
local ctok = { r = { name = "chilli" } }
A.shade(c, chm, chn, CHIL, { tok = ctok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15 })
c:put(36, 30, CHIL[4], ctok)
c:put(34, 31, GRN[2], ctok) c:put(34, 30, GRN[1], ctok)        -- calyx
-- shadow line of the dal against the near wall
dal:each(function(x, y) if not dal:has(x, y + 1) and inner:has(x, y + 1) and x > CX - 14 then c:put(x, y + 1, BOWL[1], wtok) end end)

-- quirk: drip of dal over the rim, running down the outside
local dr = HP.mask()
for _, p in ipairs{ {43, 35}, {44, 35}, {43, 36}, {44, 36}, {43, 37}, {44, 37}, {43, 38}, {44, 38}, {43, 39}, {44, 39}, {45, 39}, {43, 40}, {44, 40}, {45, 40}, {44, 41} } do dr:set(p[1], p[2]) end
local drtok = { r = { name = "drip" } }
dr:each(function(x, y) c:put(x, y, (x == 43) and DAL[4] or DAL[3], drtok) end)
c:put(45, 40, DAL[2], drtok) c:put(44, 41, DAL[2], drtok) c:put(43, 38, DAL[6], drtok) c:put(43, 39, DAL[5], drtok)
for _, p in ipairs{ {43, 34}, {44, 34}, {45, 34} } do c:put(p[1], p[2], DAL[3], drtok) end   -- spill over the lip
dr:shift(1, 0):each(function(x, y) if outer:has(x, y) and not dr:has(x, y) then c:put(x, y, BOWL[1], btok) end end)

-- steam curl (hard pixels, two tones)
local stm = HP.line({ {33, 24}, {31, 21}, {32, 18}, {35, 16}, {35, 13}, {33, 11} }, 2)
local s2 = HP.line({ {27, 24}, {26, 21}, {27, 19} }, 1)
local sttok = { r = { name = "steam" } }
stm:each(function(x, y) c:put(x, y, stm:has(x - 1, y) and STEAM[1] or STEAM[2], sttok) end)
s2:each(function(x, y) c:put(x, y, STEAM[2], sttok) end)
A.save(c, NAME)
