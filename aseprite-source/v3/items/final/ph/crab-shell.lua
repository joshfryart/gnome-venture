-- crab-shell (final, Opus single pass). An empty green-crab carapace seen from above, front up: a domed shield
-- with three saw teeth on each front flank, two eye sockets and a lobed brow, tapering to a narrow back edge.
-- Material: per-pixel dome light (6-tone sea green), bevelled rim (lit lip + dark groove inside it), carved
-- branchial and cervical grooves (dark cut + lit far wall), granular bumps, one wet specular, cool reflected
-- light lower-right, and a 2-tone pale underside lip showing the shell's thickness.
-- quirk: a strand of red seaweed is snagged on the right rear tooth.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB22_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, cos, sin, rad = math.floor, math.sqrt, math.max, math.min, math.cos, math.sin, math.rad
local c = A.new("crab-shell")
local GR  = { "#163232", "#1f4b3c", "#2a6842", "#438843", "#6fa94b", "#a8cf68" }
local UND = { "#4a4430", "#8a8150", "#c4b97a" }
local SPEC, BOUNCE = "#fff1cf", "#5d8aa0"
local CX, CY, RX, RY = 32, 30, 19.5, 13.5

local body = HP.mask()
for y = 10, 50 do for x = 6, 58 do
  local dx, dy = (x - CX) / RX, (y - CY) / RY
  if dx*dx + dy*dy <= 1 then body:set(x, y) end
end end
body:clip(HP.poly{ { 2, 8 }, { 62, 8 }, { 62, 31 }, { 45, 46 }, { 19, 46 }, { 2, 31 } })
-- saw teeth on the front flanks
local function ep(a) return CX + RX * cos(rad(a)), CY + RY * sin(rad(a)) end
local function tooth(th, L)
  local x1, y1 = ep(th - 6) local x2, y2 = ep(th + 6) local xm, ym = ep(th)
  local dx, dy = cos(rad(th)), sin(rad(th)) - 0.55
  local l = sqrt(dx*dx + dy*dy)
  body:add(HP.poly{ { x1, y1 }, { x2, y2 }, { xm + dx / l * L, ym + dy / l * L } })
end
for _, t in ipairs{ 194, 211, 228 } do tooth(t, 3.4) tooth(180 - t + 360, 3.4) end
-- brow lobes between the eyes
for x = 28, 36 do if x ~= 32 then body:set(x, 16) end end
-- eye sockets
body:cut(A.rell(24.5, 18.2, 1, 0, 2.4, 1.6)):cut(A.rell(39.5, 18.2, 1, 0, 2.4, 1.6))

-- underside lip (shell thickness) on the lower half
local lip = body:shift(0, 2):cut(body)
local lip1 = body:shift(0, 1)
local ltok = { r = { name = "lip" } }
lip:each(function(x, y) if y > CY - 2 then c:put(x, y, lip1:has(x, y) and UND[3] or UND[2], ltok) end end)

-- dome
local stok = { r = { name = "shell" } }
local n = A.body(body, 30, 27, 21, 5, 0.55)
local idx = A.shade(c, body, n, GR, { tok = stok, amb = 0.08, wrap = 0.25 })
local function step(x, y, d) A.step(c, idx, GR, x, y, d, stok) end
-- bevel: lit outer lip on the upper-left, groove one pixel in on the lower half
local e1 = body:edge()
e1:each(function(x, y) if x + y < CX + CY then step(x, y, 1) end end)
body:shrink(1):edge():each(function(x, y) if y > CY - 1 and not e1:has(x, y) then step(x, y, -1) end end)
-- carved grooves: dark cut + lit far wall (lower-right side faces the light from the cut)
local grooves = {
  { { 27, 21 }, { 26, 25 }, { 27, 30 }, { 29, 35 }, { 30, 39 } },
  { { 37, 21 }, { 38, 25 }, { 37, 30 }, { 35, 35 }, { 34, 39 } },
  { { 23, 28 }, { 27, 30 }, { 32, 31 }, { 37, 30 }, { 41, 28 } },
  { { 29, 35 }, { 32, 36 }, { 35, 35 } },
}
local gm = HP.mask()
for _, g in ipairs(grooves) do gm:add(HP.line(g, 1)) end
gm:clip(body:shrink(3))
gm:each(function(x, y) step(x, y, -2) end)
gm:each(function(x, y) if not gm:has(x + 1, y + 1) and body:has(x + 1, y + 1) and not gm:has(x + 1, y) then step(x + 1, y + 1, 1) end end)
-- granules
body:shrink(3):each(function(x, y)
  if not gm:grow(1):has(x, y) and X.hash(x, y, 7) < 0.055 and not gm:has(x + 1, y + 1) then
    step(x, y, 1)
    if body:has(x + 1, y + 1) then step(x + 1, y + 1, -1) end
  end
end)
-- cool reflected light lower-right
local rim = X.rim(n)
e1:each(function(x, y) local k = K(x, y)
  if rim[k] and rim[k] > 0.55 and x > CX + 4 and y > CY + 2 then c:put(x, y, BOUNCE, stok) end end)
-- wet specular on the dome
local sx, sy = A.specAt(body:shrink(4), n, 40)
c:put(sx, sy, SPEC, stok) c:put(sx + 1, sy, GR[6], stok) c:put(sx, sy + 1, GR[6], stok)

-- quirk: red seaweed snagged on the right rear tooth, hanging down outside the shell
local wtok = { r = { name = "weed" } }
local WD = { "#7a2140", "#c2435a", "#ee7a80" }
local tx, ty = ep(346)
tx, ty = floor(tx + 2.5), floor(ty - 1)
local weed = { { 0, 0, 2 }, { 1, 0, 3 }, { 1, 1, 2 }, { 2, 1, 1 }, { 2, 2, 2 }, { 3, 2, 1 }, { 2, 3, 2 }, { 3, 3, 1 },
  { 2, 4, 3 }, { 3, 4, 2 }, { 3, 5, 2 }, { 4, 5, 1 }, { 3, 6, 2 }, { 4, 6, 1 }, { 2, 7, 3 }, { 3, 7, 2 }, { 2, 8, 2 },
  { 3, 8, 1 }, { 3, 9, 2 }, { 4, 10, 1 } }
for _, p in ipairs(weed) do c:put(tx + p[1], ty + p[2], WD[p[3]], wtok) end
-- a frond of it lying across the shell edge
c:put(tx - 1, ty, WD[2], wtok) c:put(tx - 2, ty + 1, WD[3], wtok) c:put(tx - 3, ty + 1, WD[2], wtok)
A.save(c, "crab-shell")
