-- spider-silk (lean D2o_4)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "spider-silk" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(m, ramp, R, o)
  local n = X.pillow(m, R)
  local v = X.light(n, o or { amb = 0.1, wrap = 0.25 })
  local idx = G.tone(c, m, v, ramp)
  return v, idx, n
end
local WOOD = { "#3b2a1f", "#5e432c", "#82603a", "#a98150" }
local SILK = { "#6f7898", "#98a2c0", "#c3cbe0", "#e2e8f3", "#f4f7fb", "#fbfcff" }
-- spindle stick
local stick = c:rect(31, 9, 32, 54)
stick:add(c:rect(32, 7, 32, 8)):add(c:rect(31, 55, 31, 56))
stick:each(function(x, y) c:px(x, y, x == 31 and WOOD[3] or WOOD[2]) end)
for y = 12, 52, 5 do c:px(32, y, WOOD[1]) end
c:px(31, 10, WOOD[4]) c:px(31, 20, WOOD[4])
-- wound silk mass
local mass = c:ellipse(32, 30, 11, 16)
local v, idx = shade(mass, SILK, 10, { amb = 0.1, wrap = 0.3 })
mass:each(function(x, y) local k = K(x, y)
  local i = idx[k] or 3
  if (x * 2 + y * 3) % 7 == 0 then c:px(x, y, SILK[max(1, i - 1)])
  elseif (x * 2 - y * 3) % 9 == 0 then c:px(x, y, SILK[min(6, i + 1)]) end
end)
mass:edge():each(function(x, y) if x > 33 and y > 34 then c:px(x, y, SILK[1]) end end)
-- tie band
c:fillMask(c:line({ {22,26}, {42,32} }, 1), "#7a8ab0")
-- loose thread + dewdrop (quirk)
c:fillMask(c:line({ {40,42}, {47,46}, {48,51}, {43,53} }, 1), SILK[3])
c:fillMask(c:ellipse(43, 55, 2, 2), "#8fcde8")
c:px(42, 54, "#f4f7fb") c:px(44, 56, "#4a8cc0") c:px(43, 56, "#6aaad8")
G.fin(c, "spider-silk")
