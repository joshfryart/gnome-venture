-- fishermans-stew (final, Opus aB32_0). A shallow cobalt-glazed bowl on a bare-clay foot ring, full of saffron-tomato
-- broth with oil beads; a blue-black mussel, a curled pink shrimp and flaky cod chunks break the surface, two parsley leaves.
-- Glaze: per-pixel light, specular streak, painted cream wave band; lip shadow and foot AO; broth drips over the rim.
-- quirk: a red-and-cream fishing float bobs in the middle of the stew, ripple ring around it.
local NAME = "fishermans-stew"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new(NAME)
local BLUE = { "#1c2450", "#253a7a", "#2f58a6", "#3f7ec4", "#66a8dc", "#a8d8f0" }
local CLAY = { "#51302b", "#864c33", "#b97a4a", "#d89c66", "#efc28e" }
local BROTH = { "#7a2030", "#b23a2a", "#d9592a", "#ee8236", "#f8ad4e", "#ffd884" }
local SHELL = { "#1e1838", "#2c2550", "#3e3a72", "#585a96", "#8088be", "#b8c0e2" }
local SHR = { "#7d2c3e", "#b84444", "#e0664e", "#f58c66", "#ffb48a", "#ffe0c0" }
local RED = { "#6e2038", "#a82838", "#d8403c", "#f06a50", "#ff9c78" }
local CRM = { "#8a7a70", "#b4a494", "#d8cab2", "#efe2c6", "#fff4d6" }
local HERB = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local CX, RY = 32, 30

c:groundShadow(CX, 50, 16, 1)

-- foot ring (bare clay, turned grooves)
local foot = HP.rect(24, 45, 40, 48)
local ftok = { r = { name = "foot" } }
foot:each(function(x, y)
  local u = (x - CX) / 8.5
  local i = u < -0.55 and 4 or u < 0.05 and 3 or u < 0.6 and 2 or 1
  if y == 48 then i = max(1, i - 1) end
  if x == 26 and y == 46 then i = 5 end
  c:put(x, y, CLAY[i], ftok)
end)

-- bowl body + rim ellipse
local body = HP.ellipse(CX, RY, 21, 18):clip(HP.rect(0, RY, 63, 45)):add(HP.ellipse(CX, RY, 21, 5))
local n = {}
body:each(function(x, y)
  local u, v = (x - CX) / 21.5, (y - RY) / 18.5
  if y < RY then v = 0 end
  n[K(x, y)] = { A.norm(u * 0.95, v * 0.85 + 0.1, sqrt(max(0.06, 1 - u * u - v * v * 0.6))) }
end)
local bias = {}
body:each(function(x, y) local k = K(x, y)
  if y >= 44 and abs(x - CX) <= 9 then bias[k] = -1 end            -- AO where the foot meets
end)
local btok = { r = { name = "bowl" } }
local bidx = A.shade(c, body, n, BLUE, { amb = 0.05, wrap = 0.25, bias = bias, tok = btok, cuts = { 0.16, 0.32, 0.5, 0.7, 0.9 } })
-- cool reflected light low-right
body:each(function(x, y) local u, v = (x - CX) / 21.5, (y - RY) / 18.5
  if u > 0.3 and v > 0.35 and u * u + v * v > 0.78 and u * u + v * v < 0.9 and y < 44 then c:put(x, y, "#3a5f9a", btok) end end)
-- lip: ring of the rim ellipse around the opening; lip throws a shadow row on the body just below it
local open = HP.ellipse(CX, RY + 0.4, 18, 3.4)
local rimE = HP.ellipse(CX, RY, 21, 5)
local lip = rimE:copy():cut(open)
lip:each(function(x, y)
  local u = (x - CX) / 21
  local i
  if y > RY + 1 then i = u < -0.4 and 6 or u < 0.45 and 5 or 4 else i = u < -0.5 and 4 or u < 0.5 and 3 or 2 end
  c:put(x, y, BLUE[i], btok)
end)
for x = CX - 20, CX + 20 do
  local yb
  for y = RY + 7, RY, -1 do if rimE:has(x, y) then yb = y break end end
  if yb and body:has(x, yb + 1) then A.step(c, bidx, BLUE, x, yb + 1, -1, btok) end
end
-- painted cream wave band around the belly (follows the curve), dark line under it
for x = CX - 19, CX + 19 do
  local u = (x - CX) / 20.5
  local yb = floor(RY + 7 + 3.2 * sqrt(max(0, 1 - u * u)) + 0.5)
  local w = (x % 4 < 2) and 0 or 1
  if body:has(x, yb + w) then c:put(x, yb + w, u < 0.35 and CRM[5] or CRM[3], btok) end
  if body:has(x, yb + 2) then c:put(x, yb + 2, u < -0.2 and BLUE[3] or BLUE[2], btok) end
end
-- specular streak on the glaze (left belly)
for _, p in ipairs{ {15, 33}, {15, 34}, {16, 35}, {16, 36}, {17, 41}, {18, 42} } do c:put(p[1], p[2], BLUE[6], btok) end
c:put(16, 34, "#e6f6ff", btok)

-- opening: back inner wall + broth surface
local otok = { r = { name = "broth" } }
open:each(function(x, y)
  if y <= RY - 2 then c:put(x, y, (x - CX) < -6 and BLUE[3] or BLUE[2], otok)
  else
    local i = 4
    if not open:has(x, y + 1) or not open:has(x + 1, y) or not open:has(x - 1, y) then i = 3 end
    if y == RY - 1 then i = 2 end                                     -- AO under back wall
    c:put(x, y, BROTH[i], otok)
  end
end)
-- oil beads + glint
for _, p in ipairs{ {19, 31}, {23, 32}, {41, 31}, {45, 32}, {27, 33}, {38, 33} } do c:put(p[1], p[2], BROTH[5], otok) end
c:put(21, 30, BROTH[6], otok) c:put(22, 30, BROTH[6], otok)

-- drip over the front rim (food cue)
local drip = { {43, 35}, {43, 36}, {44, 36}, {43, 37}, {43, 38}, {44, 38}, {43, 39}, {44, 39} }
for i, p in ipairs(drip) do c:put(p[1], p[2], (p[1] == 43 and i < 7) and BROTH[4] or BROTH[3], otok) end
c:put(43, 34, BROTH[4], otok) c:put(44, 40, BROTH[2], otok) c:put(43, 40, BROTH[3], otok) c:put(43, 38, BROTH[5], otok)

-- flaky cod chunks (cream, flake lines)
local ctok = { r = { name = "cod" } }
local function chunk(x, y)
  for j = 0, 2 do for i = 0, 3 do
    local col = (j == 0) and CRM[5] or (i == 3 or j == 2) and CRM[2] or CRM[4]
    if i == 2 and j == 1 then col = CRM[3] end
    if not (j == 0 and i == 3) then c:put(x + i, y + j, col, ctok) end
  end end
  c:put(x, y + 3, BROTH[2], otok) c:put(x + 1, y + 3, BROTH[2], otok) c:put(x + 2, y + 3, BROTH[2], otok)
end
chunk(24, 29) chunk(36, 30)

-- mussel (left), tilted up out of the broth: dark shell, nacre rim, orange flesh peeking
local mm, mn = A.oval(19, 26, 5.2, 2.6, -0.85, 0.7)
local mtok = { r = { name = "mussel" } }
local midx = A.shade(c, mm, mn, SHELL, { amb = 0.05, wrap = 0.2, tok = mtok })
-- growth rings
mm:each(function(x, y) local d = sqrt((x - 15.5) ^ 2 + (y - 30.5) ^ 2)
  if (d > 4.4 and d < 5.1) or (d > 7.2 and d < 7.9) then A.step(c, midx, SHELL, x, y, -1, mtok) end end)
-- nacre rim on the lower-right edge + flesh
mm:edge():each(function(x, y) if (x - 19) - (y - 26) * 0.4 > 1.6 then c:put(x, y, SHELL[6], mtok) end end)
for _, p in ipairs{ {22, 28}, {23, 27}, {21, 29} } do c:put(p[1], p[2], BROTH[5], mtok) end
c:put(16, 24, SHELL[6], mtok) c:put(17, 23, SHELL[6], mtok)

-- shrimp (right): curled C, segment lines, tail fan
local sp = { { 39, 31 }, { 37, 24 }, { 46, 20 }, { 48, 27 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 2.4 * (1 - t * 0.6) end)
local stok = { r = { name = "shrimp" } }
local sidx = A.shade(c, sm, sn, SHR, { amb = 0.1, wrap = 0.3, tok = stok })
sm:each(function(x, y) local k = K(x, y) local t = ST[k]
  if (t * 6) % 1 < 0.14 and t > 0.1 and t < 0.92 then A.step(c, sidx, SHR, x, y, -2, stok) end
  if SS[k] < -0.5 and t > 0.15 and t < 0.8 and (t * 6) % 1 > 0.3 then c:put(x, y, SHR[6], stok) end
end)
for _, p in ipairs{ {47, 28, 3}, {48, 29, 4}, {49, 29, 3}, {49, 28, 2}, {47, 29, 2}, {50, 30, 3}, {46, 30, 2} } do c:put(p[1], p[2], SHR[p[3]], stok) end
-- antennae whisker
c:put(39, 32, SHR[3], stok)

-- parsley
local htok = { r = { name = "herb" } }
for _, p in ipairs{ {29, 33, 3}, {30, 33, 4}, {30, 32, 3}, {31, 32, 2}, {33, 33, 3}, {34, 33, 2}, {34, 32, 3}, {32, 33, 1} } do c:put(p[1], p[2], HERB[p[3]], htok) end

-- quirk: fishing float, red top / cream belly, antenna, ripple ring
local fx, fy = 31, 26
local fm = HP.ellipse(fx, fy, 2.6, 3.2)
local fn = X.sphere(fx, fy, 3, fm)
local ftk = { r = { name = "float" } }
local fv = X.light(fn, { amb = 0.08, wrap = 0.25 })
fm:each(function(x, y) local k = K(x, y) local i = max(1, min(5, floor(fv[k] * 5) + 1))
  c:put(x, y, (y <= fy) and RED[i] or CRM[i], ftk) end)
c:put(fx - 1, fy - 2, RED[5], ftk) c:put(fx - 1, fy - 1, "#ffd0b0", ftk)
for y = fy - 7, fy - 4 do c:put(fx, y, y == fy - 7 and RED[4] or "#5a3a3a", ftk) end
-- ripple ring
for _, p in ipairs{ {27, 30}, {28, 31}, {29, 31}, {33, 31}, {34, 31}, {35, 30} } do c:put(p[1], p[2], BROTH[5], otok) end
for x = fx - 2, fx + 2 do c:put(x, fy + 4, BROTH[2], otok) end

A.save(c, NAME)
