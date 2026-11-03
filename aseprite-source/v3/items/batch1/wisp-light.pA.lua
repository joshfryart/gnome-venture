-- wisp-light pass A (Opus). Slim hanging glass lantern: brass bail ring, domed vented cap, egg-shaped globe
-- with two thin wire cage bars, brass foot + drop finial. The wisp inside lights the glass from within.
-- quirk: one tiny spark has slipped out through the cap vent and drifts up beside the ring.
local NAME = "wisp-light.pA"
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local HP, X, P, K = H.HP, H.X, H.P, H.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs

local BRASS = { "#4e2c22", "#7f4a26", "#ad702c", "#d89a3a", "#f1c45e", "#fff0a8" }
local GLOW  = { "#1d2f55", "#24507a", "#2f7aa4", "#47a9c0", "#7fd6cf", "#c4f5e4" }
local WISP  = { "#7fd6cf", "#b4f2e2", "#e6fff2", "#fff4d6" }
local CX = 31.5

-- ring (torus) + short hanger neck
local ring = c:ellipse(CX, 7.5, 4, 3.5):cut(c:ellipse(CX, 7.5, 1.5, 1.5))
X.tone(c, ring, X.light(X.sphere(CX, 7.5, 4, ring), { amb = 0.15, wrap = 0.2 }), BRASS)
c:fillMask(c:rect(31, 11, 32, 11), BRASS[3]) c:px(31, 11, BRASS[5])

-- cap: dome with a lip
local cap = c:ellipse(CX, 15, 7.5, 4.5):clip(c:rect(0, 0, 63, 15)):add(c:rect(23, 15, 40, 17))
H.lit(c, cap, BRASS, { R = 3, amb = 0.12 })
for x = 23, 40 do c:px(x, 17, x < 28 and BRASS[3] or BRASS[2]) end     -- lip underside
for x = 24, 39 do c:px(x, 15, BRASS[5]) end c:px(39, 15, BRASS[4])       -- lip top edge catches light
c:px(28, 13, BRASS[1]) c:px(29, 13, BRASS[1]) c:px(34, 13, BRASS[1]) c:px(35, 13, BRASS[1])  -- vents

-- globe: egg (narrower top)
local glass = c:ellipse(CX, 33, 10.5, 14):clip(c:rect(0, 18, 63, 63))
glass:each(function(x, y) if y < 26 and abs(x - CX) > 4 + (y - 18) * 0.95 then end end)
local WX, WY = 31.5, 36
local d = X.dist(glass)
local v = {}
glass:each(function(x, y)
  local r = sqrt((x - WX) ^ 2 + ((y - WY) * 0.85) ^ 2)
  local g = max(0, 1 - r / 12) ^ 1.3
  local e = min(1, (d[K(x, y)] + 0.5) / 3)                 -- fresnel: edges darker
  v[K(x, y)] = g * 0.8 + e * 0.25 - ((x - CX) + (y - 33)) * 0.006
end)
X.tone(c, glass, v, GLOW, { cuts = { 0.18, 0.32, 0.46, 0.6, 0.76 } })
-- glass rim: bright upper-left rim, deep lower-right edge
glass:edge():each(function(x, y)
  if (x - CX) + (y - 33) * 0.8 < -6 then c:px(x, y, GLOW[5]) elseif (x - CX) + (y - 33) > 8 then c:px(x, y, GLOW[1]) end
end)
-- specular streak (curved, upper left)
for _, p in ipairs{ {24, 25}, {23, 26}, {23, 27}, {22, 28}, {22, 29}, {22, 30} } do c:px(p[1], p[2], "#f2fff8") end
c:px(25, 23, WISP[2])

-- wisp: flame drop with a curling tip
local wm = c:ellipse(WX, WY + 3, 4.5, 4)
local tail = H.sweep({ {31.5, 37}, {30, 32}, {35, 29}, {33, 24} }, function(t) return 3.6 * (1 - t) ^ 0.8 + 0.3 end)
wm:add(tail)
local wd = X.dist(wm)
local wv = {}
wm:each(function(x, y) wv[K(x, y)] = min(1, (wd[K(x, y)] + 0.5) / 3.5) - (x - WX) * 0.03 end)
X.tone(c, wm, wv, WISP, { cuts = { 0.3, 0.55, 0.8 } })
c:px(29, 38, P.ink) c:px(29, 39, P.ink) c:px(33, 38, P.ink) c:px(33, 39, P.ink)   -- eyes
c:px(31, 41, "#f5809f") c:px(32, 41, "#f5809f")

-- cage bars (meridians) over the glass, cast a dark line beside them
for _, sx in ipairs{ -0.62, 0.62 } do
  for y = 19, 46 do
    local q = 1 - ((y - 33) / 14) ^ 2
    if q > 0 then
      local x = floor(CX + sx * 11 * sqrt(q) + 0.5)
      if glass:has(x, y) then
        c:px(x, y, sx < 0 and BRASS[4] or BRASS[3])
        if glass:has(x + 1, y) then c:px(x + 1, y, GLOW[1]) end
      end
    end
  end
end

-- foot collar + drop finial
local foot = c:rrect(25, 46, 38, 49, 1)
H.lit(c, foot, BRASS, { R = 1.5, amb = 0.12 })
for x = 25, 38 do c:px(x, 46, BRASS[2]) end                       -- AO under the glass
local drop = c:ellipse(CX, 52, 2, 2.5)
H.lit(c, drop, BRASS, { R = 2 })
c:px(31, 54, BRASS[2]) c:px(32, 54, BRASS[2]) c:px(31, 55, BRASS[3])

-- quirk: escaped spark
c:px(43, 8, WISP[4]) c:px(42, 8, WISP[2]) c:px(44, 8, WISP[2]) c:px(43, 7, WISP[2]) c:px(43, 9, WISP[2])
c:px(40, 11, WISP[1])

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = H.out .. NAME .. ".aseprite", png = H.out .. NAME .. ".png", scale = 1 }
