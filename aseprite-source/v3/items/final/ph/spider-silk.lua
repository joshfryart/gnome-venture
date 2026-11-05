-- spider-silk (lean P1b_O10)
-- A wooden drop-spindle wound with a fat cone of pale silk (diagonal thread wraps), a loose strand drooping to a tiny dangling spider (quirk: red hourglass).
local NAME = "spider-silk"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function paint(c, m, ramp, vf, nm, adj)
  local tok = { r = { name = nm } }
  local nr = #ramp
  m:each(function(x, y)
    local v = vf(x, y)
    local i = 1 + floor(max(0, min(0.999, v)) * nr)
    if adj then i = adj(x, y, i, v) or i end
    c:put(x, y, ramp[max(1, min(nr, i))], tok)
  end)
end
local function blob(c, m, R, ramp, nm, amb, wrap, adj)
  local v = X.light(X.pillow(m, R), { amb = amb or 0.1, wrap = wrap or 0.25 })
  paint(c, m, ramp, function(x, y) return v[K(x, y)] end, nm, adj)
end
local function LINE(c, pts, hex) c:line(pts, 1):each(function(x, y) c:put(x, y, hex, { r = { name = "ln" } }) end) end
local function T(nm) return { r = { name = nm } } end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local SILK = { "#5a5688", "#8683b4", "#b4b4d8", "#d8d9ee", "#eef0fa", "#fbfcff" }
local WOOD = { "#2e1a14", "#573320", "#80522c", "#a97a42", "#cfa062" }
local SP = { "#1a1020", "#34203c", "#563660" }
c:groundShadow(30, 56, 17, 3)
-- spindle shaft + hook
local sh = c:rect(30, 7, 32, 54)
paint(c, sh, WOOD, function(x, y) return x == 30 and 0.8 or (x == 31 and 0.5 or 0.2) end, "wood")
c:put(31, 6, WOOD[4], T"wood") c:put(32, 5, WOOD[3], T"wood") c:put(33, 5, WOOD[3], T"wood") c:put(34, 6, WOOD[2], T"wood")
-- whorl disc at the base
local wh = c:ellipse(31, 51, 11, 3)
blob(c, wh, 4, WOOD, "wood", 0.15, 0.3)
c:fillMask(c:rect(21, 52, 41, 52), WOOD[1])
-- silk cone
local cone = HP.mask()
for y = 14, 48 do
  local t = (y - 14) / 34
  local h = 13.5 * t ^ 0.75
  if y > 44 then h = h * (1 - (y - 44) * 0.12) end
  for x = floor(31 - h + 0.5), floor(31 + h) do cone:set(x, y) end
end
local R = {}
paint(c, cone, SILK, function(x, y)
  local nx = (x - 31) / (14 * ((y - 14) / 34) ^ 0.75 + 1)
  local nz = sqrt(max(0, 1 - nx * nx))
  return 0.15 + 0.85 * max(0, -nx * 0.62 + nz * 0.7)
end, "silk", function(x, y, i)
  local w = (y + (x - 31) * 0.55) % 3.6
  if w < 1 then return i - 1 end
  if w >= 2.6 and w < 3.6 then return i + 0 end
end)
-- glints on wraps
for _, p in ipairs{ {26, 36}, {27, 35}, {28, 31}, {29, 27}, {30, 23} } do c:put(p[1], p[2], SILK[6], T"silk") end
-- strand drooping from the cone to the spider
LINE(c, { {39, 42}, {42, 45}, {45, 46}, {47, 44}, {47, 47}, {47, 50} }, SILK[3])
-- spider
local body = c:ellipse(47, 53, 2, 2)
blob(c, body, 2.5, SP, "spider", 0.2, 0.3)
c:put(47, 54, "#d8283c", T"spider")
c:put(46, 52, SP[3], T"spider")
local legs = { {45,51,43,50},{45,53,43,54},{45,54,44,56},{49,51,51,50},{49,53,51,54},{49,54,50,56} }
for _, l in ipairs(legs) do LINE(c, { {l[1], l[2]}, {l[3], l[4]} }, SP[2]) end
G.save(c, NAME)
