-- moonfish (final, Opus single pass): an opah side-on. Deep oval disc body, steel-blue back over a rosy-silver belly,
-- scattered cream spots, a high-arched lateral line, gill arc, big gold-ringed eye. Crimson fins: tall sickle dorsal,
-- low trailing dorsal/anal strips, deep crescent tail, long sickle pectoral over the flank (contact shadow), pelvic fin.
-- quirk: one of its flank spots is a tiny crescent moon.
local NAME = "moonfish"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_0.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local BLUE = { "#222049", "#353a78", "#4a5ca0", "#6984c2", "#98b2dc", "#d0e2f4" }
local ROSE = { "#4e2444", "#7c4064", "#a8667e", "#cc8e9c", "#ecbcc0", "#fde6e0" }
local FIN  = { "#4e1630", "#801e36", "#b4303c", "#de4e44", "#f87e60", "#ffb894" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local SPOT, SPOTS = "#fff4d6", "#e6d8e8"
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.84 }

local CX, CY, RX, RY = 29, 32, 18, 13.5
local body = HP.mask()
for y = 16, 48 do for x = 9, 50 do
  local u, v = (x - CX) / (RX + 0.4), (y - CY) / (RY + 0.4)
  -- a touch blunter at the head, tapering into the peduncle at the back
  if u > 0 then v = v * (1 + 0.28 * u * u) end
  if u * u + v * v <= 1 then body:set(x, y) end
end end

local function tone(m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias, tok = o.tok })
end

-- ---- fins behind the body ----
local ftok = { r = { name = "fin" } }
local finsBack = HP.mask()
-- tail: narrow peduncle + deep crescent (two swept lobes)
local ped = c:poly{ { 44, 29 }, { 51, 30 }, { 51, 35 }, { 44, 36 } }
local up = G.blade(50, 32, 51, 22, 57, 16, function(t) if t > 0.98 then return -1 end return max(0.5, 2.3 * (1 - t) ^ 0.8) end, { fold = 0.2 })
local lo = G.blade(50, 33, 51, 43, 57, 49, function(t) if t > 0.98 then return -1 end return max(0.5, 2.3 * (1 - t) ^ 0.8) end, { fold = 0.2 })
local tail = ped:copy():add(up):add(lo)
-- sickle dorsal (tall, swept back) + low trailing dorsal strip
local dors = G.blade(22, 21, 24, 11, 31, 7, function(t) if t > 0.98 then return -1 end return max(0.5, 3.0 * (1 - t) ^ 0.9) end, { fold = 0.2 })
local dlow = HP.mask()
for x = 27, 46 do
  local u = (x - CX) / (RX + 0.4)
  local top = CY - (RY + 0.4) * sqrt(max(0, 1 - u * u)) / (1 + (u > 0 and 0.28 * u * u or 0))
  local h = x < 40 and 2 or 1
  for y = floor(top) - h, floor(top) + 1 do dlow:set(x, y) end
end
-- anal fin strip under the rear belly
local anal = HP.mask()
for x = 31, 45 do
  local u = (x - CX) / (RX + 0.4)
  local bot = CY + (RY + 0.4) * sqrt(max(0, 1 - u * u)) / (1 + 0.28 * u * u)
  local h = x < 39 and 2 or 1
  for y = floor(bot) - 1, floor(bot) + h do anal:set(x, y) end
end
finsBack:add(tail):add(dors):add(dlow):add(anal):cut(body)
local fb = {}
X.ao(fb, finsBack, body, 1, -1)
tone(finsBack, X.pillow(finsBack, 1.6), FIN, { bias = fb, tok = ftok, amb = 0.2 })
-- fin rays: darker strokes radiating from the base
finsBack:each(function(x, y) local k = K(x, y)
  if fb[k] then return end
  if dors:has(x, y) and (x + y) % 3 == 0 and y > 9 then c:put(x, y, FIN[3], ftok) end
  if tail:has(x, y) and x > 51 and (y % 3 == 0) then c:put(x, y, FIN[3], ftok) end
end)
-- tail fork edge highlight
for _, p in ipairs{ { 55, 18 }, { 54, 19 }, { 53, 21 } } do if tail:has(p[1], p[2]) then c:put(p[1], p[2], FIN[6], ftok) end end

-- ---- body ----
local n = A.body(body, CX - 3, CY - 2, 17, 6, 0.65)
local v = X.light(n, { amb = 0.06, wrap = 0.22 })
local btok = { r = { name = "body" } }
-- pectoral fin mask first (for the cast shadow on the flank)
local pec = G.blade(22, 35, 30, 33, 42, 28, function(t) if t > 0.985 then return -1 end return max(0.5, 2.4 * sin(pi * min(1, 0.15 + t * 0.9)) ^ 0.5 * (1 - t * 0.5)) end, { fold = 0.25 })
local pelv = G.blade(26, 44, 27, 48, 30, 51, function(t) if t > 0.98 then return -1 end return max(0.5, 2.0 * (1 - t) ^ 0.7) end, { fold = 0.2 })
local bias = {}
G.cast(bias, body, pec, 1, 1, -1)
G.cast(bias, body, pec, 1, 2, -1)
local function boundary(x) return CY + 1 - 0.22 * (x - CX) + 0.012 * (x - CX) ^ 2 end
local bidx = {}
body:each(function(x, y) local k = K(x, y)
  local i = 1
  for j, t in ipairs(CUTS) do if v[k] >= t then i = j + 1 end end
  i = max(1, min(6, i + (bias[k] or 0)))
  bidx[k] = i
  if y < boundary(x) then c:put(x, y, BLUE[i], btok) else c:put(x, y, ROSE[min(6, i + 1)], btok) end
end)
local function rampAt(x, y) return y < boundary(x) and BLUE or ROSE end
local function step(x, y, d) local k = K(x, y) if not bidx[k] then return end
  local r = rampAt(x, y) c:put(x, y, r[max(1, min(6, bidx[k] + d + (r == ROSE and 1 or 0)))], btok) end
-- soft transition row: back colour one step lighter right at the boundary (silver sheen band)
body:each(function(x, y) if y == floor(boundary(x)) - 1 and x > 13 and x < 46 then step(x, y, 1) end end)
-- gill arc
for y = 23, 41 do local x = floor(20.5 + 0.06 * (y - 32) ^ 2) if body:has(x, y) then step(x, y, -2) end
  if body:has(x - 1, y) and y > 26 and y < 38 then step(x - 1, y, 1) end end
-- lateral line: high arch over the pectoral, down to the peduncle
for x = 22, 47 do local y = floor(27 - 6.5 * sin(pi * (x - 22) / 34) + 0.5 + max(0, x - 40) * 0.5)
  if body:has(x, y) then step(x, y, -1) end end
-- cream spots scattered on the flank (skip head, fin path, edges)
local spots = { { 26, 22 }, { 33, 21 }, { 39, 24 }, { 30, 26 }, { 36, 28 }, { 43, 27 }, { 24, 30 }, { 44, 33 },
  { 35, 38 }, { 41, 38 }, { 29, 40 }, { 38, 43 }, { 32, 44 }, { 45, 39 }, { 22, 40 } }
for _, s in ipairs(spots) do local x, y = s[1], s[2]
  if body:has(x, y) and body:has(x + 1, y + 1) and not pec:has(x, y) and not pec:has(x + 1, y) then
    local lit = (bidx[K(x, y)] or 3) >= 3
    c:put(x, y, lit and SPOT or SPOTS, btok)
    if (x + y) % 2 == 0 then c:put(x + 1, y, lit and SPOTS or rampAt(x + 1, y)[5], btok) end
  end
end
-- quirk: the crescent-moon spot
for _, p in ipairs{ { 33, 33, SPOT }, { 32, 34, SPOT }, { 32, 35, SPOT }, { 33, 36, SPOTS }, { 34, 33, SPOTS } } do c:put(p[1], p[2], p[3], btok) end
c:put(34, 36, GOLD[4], btok)
-- head: snout shading + mouth
for _, p in ipairs{ { 11, 33 }, { 12, 33 }, { 13, 34 } } do if body:has(p[1], p[2]) then c:put(p[1], p[2], FIN[2], btok) end end
c:put(12, 32, FIN[5], btok)
-- big gold-ringed eye
local ex, ey = 15, 26
A.map(c, { ".hhh.", "hkkkh", "hkkkg", "hkkkg", ".ggg." }, ex, ey, { h = GOLD[3], g = GOLD[2], k = "#2b1c26" }, btok)
c:put(ex + 1, ey + 1, SPOT, btok)
c:put(ex + 3, ey + 3, "#3a3f7e", btok)
-- back specular
c:put(25, 19, BLUE[6], btok) c:put(26, 19, SPOT, btok)

-- ---- fins over the body ----
local over = pec:copy():add(pelv)
local ob = {}
X.ao(ob, pelv, body, 1, 0)
tone(over, X.pillow(over, 1.5), FIN, { tok = ftok, amb = 0.22, bias = ob })
-- pectoral rays + lit leading edge
pec:each(function(x, y) if (x * 2 + y) % 4 == 0 and x > 25 then c:put(x, y, FIN[3], ftok) end end)
pec:edge():each(function(x, y) if not pec:has(x, y - 1) and x < 40 then c:put(x, y, FIN[6], ftok) end end)
-- separate the pectoral root from the flank: deep row on the fin base
for _, p in ipairs{ { 22, 35 }, { 22, 36 }, { 23, 37 } } do if pec:has(p[1], p[2]) then c:put(p[1], p[2], FIN[1], ftok) end end

A.save(c, NAME)
