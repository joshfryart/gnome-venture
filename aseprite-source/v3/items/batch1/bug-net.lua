-- bug-net (pass B, final). Slim bamboo cane (nodes with ridge highlights, hollow end), brass ferrule with a rivet,
-- steel wire hoop seen slightly from above with a cream cloth hem rolled over it, gauze bag that drapes and swings
-- back to a soft tip. Realism (hpx.lua): tube-lit wire, cylinder-lit cane, gauze lit as a bent cone with an open
-- diamond mesh, drape folds, a dark inside wall through the opening, AO under the hem, cool bounce on the shade side.
-- History: bug-net.pA (pass A).
-- quirk: a firefly caught in the bag, its tail glowing gold through the gauze.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_b1g3.lua")
local HP, X, c, P = G.start(debug.getinfo(1, "S").source)
local K = G.K
local floor, max, min, abs = math.floor, math.max, math.min, math.abs

local GAUZE = { "#3a5679", "#5a80a6", "#82adc9", "#a9d2df", "#d0ebea", "#f0f9ef" }
local BOUNCE = "#7f9fd6"
local HEM   = { "#9c8f86", "#d6c9b0", "#f6ecd2" }
local WIRE  = { "#3c3e57", "#555973", "#72778f", "#9296ab", "#b7bacb", "#e4e6ee" }
local BAMB  = { "#4f4220", "#76632a", "#9e8836", "#c4ad4c", "#e0cd72", "#f6e9a8" }
local BRASS = { "#73361c", "#a2521f", "#d0802a", "#eeab3a", "#ffd15e", "#fff0b4" }
local GLOW  = { "#f5b82e", "#ffe38a", "#fff4d6" }

local cx, cy, rx, ry = 42, 14, 12, 5            -- hoop
-- bag: hangs from the hoop, bellies right, tip swings back left
local bag = c:poly{ {30,14},{30,21},{32,28},{35,35},{37,41},{38,46},{40,50},{43,51},{45,49},{47,44},{50,38},
  {53,30},{55,22},{54,14} }
bag:add(c:ellipse(cx, cy, rx, ry))
local function axis(t) return 42 + 4 * math.sin(t * 2.2) - 2 * t end
local bv, bias, sv = {}, {}, {}
bag:each(function(x, y)
  local t = max(0, (y - 14) / 37)
  local half = 12 * (1 - t ^ 1.5) + 2.5
  local s = max(-1, min(1, (x - axis(t)) / half))
  sv[K(x, y)] = s
  bv[K(x, y)] = 0.66 - 0.44 * s - 0.22 * t
  -- open diamond mesh (cells lighter, cords one tone down)
  if (x + y) % 5 == 0 or (x - y) % 5 == 0 then bias[K(x, y)] = -1 end
  -- drape folds converging on the tip
  for _, f in ipairs{ -0.5, 0.2 } do
    local d = s - f * (1 - t)
    if t > 0.2 and d > -0.06 and d < 0.08 then bias[K(x, y)] = -2 end
    if t > 0.2 and d >= 0.08 and d < 0.2 then bias[K(x, y)] = 1 end
  end
end)
-- opening: inside back wall (lit lower-right, dark under the near rim)
local open = c:ellipse(cx, cy, rx - 1, ry - 1)
open:each(function(x, y) bv[K(x, y)] = 0.3 + 0.18 * ((x - cx) / rx) - 0.12 * ((y - cy) / ry) end)
G.paint(c, bag, bv, GAUZE, nil, bias)
-- cool reflected light along the lower-right edge of the bag
bag:each(function(x, y)
  if y > 24 and not bag:has(x + 1, y) and not open:has(x, y) and sv[K(x, y)] > 0.4 then c:px(x, y, BOUNCE) end
end)
local ring = c:ellipse(cx, cy, rx + 1, ry + 1):cut(c:ellipse(cx, cy, rx - 1, ry - 1))
-- hem rolled over the front of the hoop + AO row under it
for x = cx - rx, cx + rx do
  local yy = cy + floor(ry * math.sqrt(max(0, 1 - ((x - cx) / (rx + 0.5)) ^ 2)) + 0.5)
  if bag:has(x, yy + 2) and not ring:has(x, yy + 2) then
    c:px(x, yy + 2, (x < cx - 3) and HEM[3] or (x < cx + 7 and HEM[2] or HEM[1]))
    if bag:has(x, yy + 3) then c:px(x, yy + 3, GAUZE[2]) end
  end
end

-- quirk: firefly in the bag, glow through the gauze, little dusk wings
local fx, fy = 43, 36
local glow = c:ellipse(fx + 1, fy + 1, 3, 3)
glow:each(function(x, y) if bag:has(x, y) then
  local d = abs(x - fx - 1) + abs(y - fy - 1)
  c:px(x, y, d <= 1 and GLOW[3] or d <= 3 and GLOW[2] or GLOW[1])
end end)
c:px(fx - 1, fy - 1, P.ink) c:px(fx, fy - 1, P.ink) c:px(fx, fy, "#5a459e")
c:px(fx - 1, fy - 2, "#c9b2f0") c:px(fx + 1, fy - 2, "#c9b2f0") c:px(fx, fy - 2, "#8a6fd0")

-- hoop: steel wire, 2 px tube (front over the hem), specular on the upper-left
local rn = G.ringNormals(ring, cx, cy, rx + 0.5, ry + 0.5, 1.0)
G.paint(c, ring, X.light(rn, { amb = 0.1, wrap = 0.2 }), WIRE)
c:px(33, 10, WIRE[6]) c:px(34, 9, WIRE[6]) c:px(35, 9, WIRE[6])

-- handle: bamboo cane with nodes (dark ring + pale ridge), lengthwise fibre streak on the lit side
local AX, AY, BX, BY = 30, 18, 9, 57
local hm, hn, hT, hS = X.cyl(AX, AY, BX, BY, function(t) return 1.45 end)
local hv = X.light(hn, { amb = 0.12, wrap = 0.3 })
local hb = {}
local L = 44
hm:each(function(x, y)
  local k = K(x, y)
  for _, nt in ipairs{ 0.28, 0.54, 0.8 } do
    local d = (hT[k] - nt) * L
    if d >= -0.5 and d < 0.6 then hb[k] = -2 elseif d >= 0.6 and d < 1.6 then hb[k] = 1 elseif d >= -1.5 and d < -0.5 then hb[k] = -1 end
  end
  if hS[k] < -0.1 and hS[k] > -0.5 and not hb[k] then hb[k] = 1 end
end)
G.paint(c, hm, hv, BAMB, { 0.2, 0.38, 0.55, 0.72, 0.88 }, hb)
-- hollow end of the cane
c:px(9, 57, BAMB[1]) c:px(10, 57, BAMB[5]) c:px(8, 57, BAMB[4]) c:px(9, 58, BAMB[3])

-- ferrule (brass collar) where the cane meets the hoop, rivet + AO on the cane below it
local fm, fn = X.cyl(31, 16, 27, 23, function() return 2.1 end)
G.paint(c, fm, X.light(fn, { amb = 0.1, wrap = 0.2 }), BRASS)
c:px(29, 20, BRASS[1]) c:px(28, 19, BRASS[6])
hm:each(function(x, y) if not fm:has(x, y) and fm:grow(1):has(x, y) then c:px(x, y, BAMB[2]) end end)

G.fin(c)
