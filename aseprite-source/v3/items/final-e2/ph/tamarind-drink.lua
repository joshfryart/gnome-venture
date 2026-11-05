-- NAME (lean E2_16)
local NAME = "tamarind-drink"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { .22, .4, .56, .72, .86 }
local _n = 0
local function shade(m, ramp, R, o)
  o = o or {}; _n = _n + 1
  local n = X.pillow(m, R or 4)
  local idx = X.tone(c, m, X.light(n, { amb = o.amb or .1, wrap = o.wrap or .25 }), ramp, { cuts = CUTS, tok = { r = { name = "p" .. _n } } })
  return idx, n
end
local function tok() _n = _n + 1 return { r = { name = "q" .. _n } } end
local function put(m, col) local t = tok() m:each(function(x, y) c:put(x, y, col, t) end) end
local function bez(p, t) local u = 1 - t
  return u*u*u*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t*t*t*p[4][1],
         u*u*u*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t*t*t*p[4][2] end

local GL = { "#5a8a9a", "#86b8c4", "#b0dce2", "#d4f0f2", "#eefafa", "#ffffff" }
local LIQ = { "#2a0e08", "#4a1a0e", "#702a14", "#9a4220", "#c0642c", "#e08a44" }
local POD = { "#2e1a14", "#4a2c1e", "#6c4430", "#8e6244", "#b08460", "#d2aa82" }
local ICE = { "#8ab8d0", "#b4dcec", "#d8f2fa", "#f4fcff" }
c:groundShadow(30, 58, 15, 2)
local glass = c:poly{ {16, 20}, {44, 20}, {40, 56}, {20, 56} }
shade(glass, GL, 8, { amb = .35, wrap = .4 })
local inner = c:poly{ {18, 26}, {42, 26}, {38, 52}, {22, 52} }
shade(inner, LIQ, 9, { amb = .2, wrap = .3 })
-- ice cubes floating at the surface
shade(c:rrect(21, 24, 29, 31, 2), ICE, 3, { amb = .4 })
shade(c:rrect(31, 26, 39, 33, 2), ICE, 3, { amb = .4 })
-- liquid meniscus line
for x = 19, 41 do c:put(x, 26, LIQ[6]) end
-- glass highlights and thick base
for y = 22, 50 do c:put(18 + floor((y - 22) / 9), y, "#ffffff") end
for x = 21, 39 do c:put(x, 53, GL[3]) c:put(x, 54, GL[2]) end
-- bubbles
c:put(34, 40, LIQ[6]) c:put(26, 44, LIQ[5]) c:put(32, 47, LIQ[6])
-- chili-salt rim flecks
for _, p in ipairs{ {18, 19}, {22, 19}, {27, 19}, {33, 19}, {38, 19}, {42, 19} } do c:put(p[1], p[2], "#d8402c") end
-- quirk: tamarind pod hooked over the rim
local pm, pn = G.tube({ {36, 10}, {44, 6}, {52, 12}, {54, 26} }, function(t) return 2.6 * sin(pi * (0.1 + 0.8 * t)) ^ 0.5 + 0.3 end)
X.tone(c, pm, X.light(pn, { amb = .12, wrap = .25 }), POD, { cuts = CUTS, tok = tok() })
c:put(46, 6, POD[6]) c:put(47, 6, POD[5])
c:sparkle(14, 18)

G.save(c, NAME)
