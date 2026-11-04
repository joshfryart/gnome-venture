-- bug-net (pass A). Slim bamboo cane handle (nodes), brass ferrule, steel wire hoop seen slightly from above,
-- pale gauze bag drooping to a soft tip (diamond mesh, drape folds, dark inside through the opening).
-- quirk: a firefly caught in the bag, its tail glowing gold through the gauze.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_b1g3.lua")
local HP, X, c, P = G.start(debug.getinfo(1, "S").source)
local K = G.K
local floor, max, min, abs = math.floor, math.max, math.min, math.abs

local GAUZE = { "#3f5d7c", "#5f86a6", "#86b2c8", "#acd5de", "#d2ece9", "#f0f9ef" }
local WIRE  = { "#3c3e57", "#555973", "#72778f", "#9296ab", "#b7bacb", "#e4e6ee" }
local BAMB  = { "#4f4220", "#76632a", "#9e8836", "#c4ad4c", "#e0cd72", "#f6e9a8" }
local BRASS = { "#73361c", "#a2521f", "#d0802a", "#eeab3a", "#ffd15e", "#fff0b4" }
local GLOW  = { "#f5b82e", "#ffe38a", "#fff4d6" }

local cx, cy, rx, ry = 41, 15, 13, 6            -- hoop
-- bag: from the hoop rim down to a tip, drifting right
local bag = c:poly{ {27,15},{28,22},{31,30},{35,38},{39,44},{43,48},{47,49},{50,47},{51,42},{53,33},{55,24},{55,15} }
bag:add(c:ellipse(cx, cy, rx, ry))
local bv = {}
local bias = {}
bag:each(function(x, y)
  -- soft cylinder across the bag (axis bends toward the tip), light from upper-left
  local t = (y - 15) / 34
  local axis = 41 + 6 * t * t
  local half = 13 * (1 - t ^ 1.6) + 3
  local s = max(-1, min(1, (x - axis) / half))
  local val = 0.62 - 0.42 * s - 0.25 * t
  bv[K(x, y)] = val
  -- diamond mesh
  if (x + y) % 4 == 0 or (x - y) % 4 == 0 then bias[K(x, y)] = -1 end
  -- drape folds converging on the tip
  for _, f in ipairs{ -0.45, 0.25 } do
    if abs(s - f * (1 - t)) < 0.07 and t > 0.25 then bias[K(x, y)] = (bias[K(x, y)] or 0) - 1 end
  end
end)
-- opening: we see the inside back wall, darker
local open = c:ellipse(cx, cy, rx - 1, ry - 1)
open:each(function(x, y) bv[K(x, y)] = 0.36 + 0.12 * ((x - cx) / rx) + 0.1 * ((y - cy) / ry) end)
G.paint(c, bag, bv, GAUZE, nil, bias)

-- quirk: firefly in the bag with gold glow showing through the gauze
local fx, fy = 41, 35
local glow = c:ellipse(fx + 1, fy, 3, 3)
glow:each(function(x, y) if bag:has(x, y) then
  local d = abs(x - fx - 1) + abs(y - fy)
  c:px(x, y, d <= 1 and GLOW[3] or d <= 3 and GLOW[2] or GLOW[1])
end end)
c:px(fx - 2, fy - 1, P.ink) c:px(fx - 1, fy - 1, P.ink) c:px(fx - 1, fy, "#5a459e")
c:px(fx - 2, fy - 2, "#c9b2f0")

-- hoop: steel wire, 2 px tube; back half drawn, front half over the gauze
local ring = c:ellipse(cx, cy, rx + 1, ry + 1):cut(c:ellipse(cx, cy, rx - 1, ry - 1))
local rn = G.ringNormals(ring, cx, cy, rx + 0.5, ry + 0.5, 1.0)
local rv = X.light(rn, { amb = 0.1, wrap = 0.2 })
G.paint(c, ring, rv, WIRE)
c:px(31, 11, WIRE[6]) c:px(32, 10, WIRE[6])

-- ferrule + handle (bamboo, nodes)
local AX, AY, BX, BY = 28, 19, 8, 58
local hm, hn, hT, hS = X.cyl(AX, AY, BX, BY, function(t) return 1.5 + (t > 0.97 and 0.3 or 0) end)
local hv = X.light(hn, { amb = 0.12, wrap = 0.3 })
local hb = {}
local nodes = { 0.3, 0.55, 0.8 }
hm:each(function(x, y)
  local k = K(x, y)
  for _, nt in ipairs(nodes) do
    local d = (hT[k] - nt) * 44
    if d >= -0.5 and d < 0.5 then hb[k] = -2 elseif d >= 0.5 and d < 1.5 then hb[k] = 1 end
  end
  if abs(hS[k] + 0.3) < 0.15 and (floor(hT[k] * 44) % 5 ~= 0) then hb[k] = (hb[k] or 0) + 1 end
end)
G.paint(c, hm, hv, BAMB, nil, hb)
local fm, fn = X.cyl(29, 18, 24, 26, function() return 2.2 end)
G.paint(c, fm, X.light(fn, { amb = 0.1, wrap = 0.2 }), BRASS)
-- end grain on butt
c:px(8, 58, BAMB[5]) c:px(9, 58, BAMB[4])

G.fin(c)
