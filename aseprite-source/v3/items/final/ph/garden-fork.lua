-- garden-fork (aB33_0, Opus single pass). A slim four-tine digging fork, tilted so the D-grip sits upper-left:
-- pale ash D-handle and shaft (grain lines, a knot, end-grain cap on the grip bar), a riveted steel socket,
-- arched shoulders and four square-section tines (bevel, bright lit edge, specular), AO where parts meet.
-- quirk: a clod of soil is speared on the outer tine, and a two-leaf weed is already sprouting out of it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local NAME = "garden-fork"
local c = A.new(NAME)
local STEEL = { "#2c3048", "#474c68", "#6b7190", "#959bb4", "#c6cbdc", "#eef0f6" }
local WOOD  = { "#4a2a26", "#704029", "#985b35", "#bf8148", "#dea866", "#f4d494" }
local SOIL  = { "#2b1a1d", "#432820", "#5f3a27", "#7d5233", "#9e6e45", "#bd8f60" }
local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TINES = { -6.6, -2.2, 2.2, 6.6 }
local S = 0.94 -- vertical scale of the layout (fits a 54 px box)
local function ell(u, v, cu, cv, ru, rv) local a, b = (u - cu) / ru, (v - cv) / rv return a*a + b*b <= 1, a, b end

local parts = A.field(32, 32, -0.25, 34, function(u, v)
  v = v / S
  -- quirk: soil clod on the outer tine + weed
  local inC, a, b = ell(u, v, 7.0, 19.2, 3.3, 2.5)
  if inC then local q = max(0.02, 1 - a*a - b*b) return "clod", a, b, sqrt(q) * 1.2 end
  local sx = 8.4 + (18 - v) * 0.55
  if v >= 13.6 and v <= 17.6 and abs(u - sx) <= 0.55 then return "weed", 0, 0, 1 end
  local l1, a1, b1 = ell(u, v, 8.4, 13.4, 1.9, 1.0)
  local l2, a2, b2 = ell(u, v, 12.3, 14.4, 1.9, 1.05)
  if l1 then return "weed", a1 * 0.6, b1 * 0.6 - 0.3, 1 end
  if l2 then return "weed", a2 * 0.6, b2 * 0.6 - 0.3, 1 end
  -- socket / ferrule
  if v >= 3.5 and v <= 10.5 then
    local w = 2.05 + (v - 3.5) * 0.13
    if abs(u) <= w then return "ferrule", u / (w + 0.5), 0, sqrt(max(0.05, 1 - (u / (w + 0.5))^2)) end
  end
  -- shoulders (arched crossbar)
  local top, bot = 9.6 + 0.045 * u * u, 13.6 + 0.018 * u * u
  if abs(u) <= 8.3 and v >= top and v <= bot then return "head", 0, 0, 1 end
  -- tines
  for i, tu in ipairs(TINES) do
    if v > bot - 0.5 and v <= 25.2 then
      local t = (v - 13) / 12.2
      local w = t < 0.62 and 1.15 or max(0.35, 1.15 - (t - 0.62) * 2.1)
      local cu = tu + (i - 2.5) * 0.08 * (v - 13)
      if abs(u - cu) <= w then return "tine" .. i, (u - cu) / (w + 0.55), 0, 1 end
    end
  end
  -- shaft
  if v >= -15.5 and v < 3.6 and abs(u) <= 1.6 then return "shaft", u / 2.2, 0, sqrt(1 - (u / 2.2)^2) end
  -- D-grip: top bar + converging cheeks around a hole
  local inBar = abs(u) <= 6.2 and v >= -25 and v <= -21.8 and not (abs(u) > 4.6 and v < -24.0 and (abs(u) - 4.6)^2 + (v + 24.0)^2 > 2.6)
  local hw = 6.0 - (v + 22) * (4.4 / 7.5)
  local inCheek = v > -22 and v < -14.4 and abs(u) <= hw
  local holeW = 3.6 - (v + 21.4) * (3.0 / 4.6)
  local inHole = v >= -21.4 and v <= -17.4 and abs(u) <= holeW
  if (inBar or inCheek) and not inHole then return "grip", 0, 0, 1 end
  return nil
end)

local function P(t) return parts[t] or { m = HP.mask(), n = {}, U = {}, V = {} } end
-- D-grip and head get rounded-bevel normals from the silhouette
local grip, head, shaft, fer, clod, weed = P("grip"), P("head"), P("shaft"), P("ferrule"), P("clod"), P("weed")
grip.n = X.pillow(grip.m, 1.7)
head.n = X.pillow(head.m, 1.6)

-- wood: shaft + grip with grain + AO into the socket
local wtok = { r = { name = "wood" } }
local wb = {}
shaft.m:each(function(x, y) local k = K(x, y) local u, v = shaft.U[k], shaft.V[k] / S
  if (abs(u - 0.55) < 0.5 and v > -14 and v < -5) or (abs(u + 0.5) < 0.5 and v > -3 and v < 2.5) then wb[k] = -1 end
  if v > 1.6 then wb[k] = (wb[k] or 0) - 1 end
end)
X.ao(wb, grip.m, shaft.m, 1, -1)
A.tone(c, shaft.m, shaft.n, WOOD, { bias = wb, tok = wtok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
local gb = {}
grip.m:each(function(x, y) local k = K(x, y) local u, v = grip.U[k], grip.V[k] / S
  if v < -22 and abs(v + 23.3) < 0.45 and u > -3 and u < 4 then gb[k] = -1 end  -- grain along the bar
end)
A.tone(c, grip.m, grip.n, WOOD, { bias = gb, tok = wtok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
-- end grain: pale left cap of the grip bar with a ring
do local bx, by
  grip.m:each(function(x, y) local k = K(x, y) if grip.V[k] / S < -22.2 and grip.U[k] < -5.2 then
    if not bx or x < bx or (x == bx and y < by) then bx, by = x, y end
    c:put(x, y, WOOD[5], wtok) end end)
  if bx then c:put(bx + 1, by + 1, WOOD[4], wtok) end
end
-- knot on the shaft
do local best
  shaft.m:each(function(x, y) local k = K(x, y) local v = shaft.V[k] / S
    if abs(v + 8) < 0.6 and abs(shaft.U[k] - 0.2) < 0.7 then best = { x, y } end end)
  if best then c:put(best[1], best[2], WOOD[1], wtok) c:put(best[1] - 1, best[2] - 1, WOOD[3], wtok) end
end

-- steel: tines, head, ferrule
local stok = { r = { name = "steel" } }
for i = 1, 4 do
  local t = P("tine" .. i)
  local b = {}
  X.ao(b, t.m, head.m, 1, -1)
  t.m:each(function(x, y) local k = K(x, y) if t.V[k] / S > 23.6 then b[k] = (b[k] or 0) - 1 end end) -- earthy dull tips
  X.ao(b, t.m, clod.m, 1, -1)
  A.tone(c, t.m, t.n, STEEL, { bias = b, tok = stok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
  -- specular streak on the lit face of each tine
  t.m:each(function(x, y) local k = K(x, y) local v = t.V[k] / S
    if t.n[k][1] < -0.3 and v > 14.8 and v < 17.4 + i * 0.2 then c:put(x, y, STEEL[6], stok) end end)
end
local hb = {}
X.ao(hb, head.m, fer.m, 1, -1)
A.tone(c, head.m, head.n, STEEL, { bias = hb, tok = stok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
local fb = {}
fer.m:each(function(x, y) local k = K(x, y) local v = fer.V[k] / S
  if abs(v - 4.2) < 0.55 then fb[k] = 1 end            -- rolled lip: bright bevel ring
  if abs(v - 5.1) < 0.45 then fb[k] = -1 end
end)
A.tone(c, fer.m, fer.n, STEEL, { bias = fb, tok = stok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
do -- rivet: dark eye with a lit rim; specular streak on the socket
  local rx, ry
  fer.m:each(function(x, y) local k = K(x, y) if abs(fer.V[k] / S - 7.6) < 0.55 and abs(fer.U[k] - 0.2) < 0.55 then rx, ry = x, y end end)
  if rx then c:put(rx, ry, STEEL[1], stok) c:put(rx - 1, ry - 1, STEEL[6], stok) end
  fer.m:each(function(x, y) local k = K(x, y) local v = fer.V[k] / S
    if fer.n[k][1] < -0.45 and fer.n[k][1] > -0.75 and v > 6 and v < 10 then c:put(x, y, STEEL[6], stok) end end)
end

-- clod: crumbly soil (hash crumbs) + weed
local ctok = { r = { name = "soil" } }
local cb = {}
clod.m:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 7)
  if h < 0.18 then cb[k] = -1 elseif h > 0.86 then cb[k] = 1 end end)
A.tone(c, clod.m, clod.n, SOIL, { bias = cb, tok = ctok, amb = 0.12, cuts = { 0.15, 0.3, 0.48, 0.66, 0.84 } })
local ltok = { r = { name = "weed" } }
A.tone(c, weed.m, weed.n, LEAF, { tok = ltok, amb = 0.25, cuts = { 0.15, 0.3, 0.46, 0.62, 0.8 } })
weed.m:each(function(x, y) local k = K(x, y) local v = weed.V[k] / S
  if v > 15.2 then c:put(x, y, v > 16.8 and LEAF[2] or LEAF[3], ltok) end end)

A.save(c, NAME)
