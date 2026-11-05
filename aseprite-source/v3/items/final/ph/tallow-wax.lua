-- NAME (lean E2_16)
local NAME = "tallow-wax"
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

local TAL = { "#7a6440", "#a68e5a", "#caB27a", "#e6d49c", "#f6ebc0", "#fffadc" }
c:groundShadow(32, 57, 23, 3)
shade(c:ellipse(32, 52, 24, 5), { "#9a8458", "#bca470", "#d8c48c", "#ece0aa" }, 4)  -- melted pool
-- lumpy cake
local m = HP.mask()
m:add(c:ellipse(30, 40, 17, 12)) m:add(c:ellipse(42, 42, 10, 9)) m:add(c:ellipse(20, 44, 8, 8)) m:add(c:ellipse(34, 33, 10, 6))
shade(m, TAL, 7, { amb = .15, wrap = .3 })
-- drips running down the front
for _, d in ipairs{ { 24, 46, 55 }, { 36, 48, 53 }, { 45, 44, 50 } } do
  local dm = c:rrect(d[1] - 1, d[2], d[1] + 1, d[3], 1)
  shade(dm, TAL, 2, { amb = .3, wrap = .4 })
  c:put(d[1] + 1, d[3] - 1, TAL[1])
end
-- thumbprint dent
shade(c:ellipse(40, 38, 4, 3), { TAL[1], TAL[2], TAL[3], TAL[4] }, 2)
c:put(38, 37, TAL[6])
-- braided wick loop out of the top
local wm, wn = G.tube({ {30, 31}, {26, 20}, {38, 14}, {34, 7} }, function(t) return 1.4 - 0.3 * t end)
local wt = tok()
wm:each(function(x, y) local k = K(x, y) local odd = (x + y) % 3 == 0
  c:put(x, y, odd and "#2a2018" or (y < 12 and "#3a3038" or "#6a5a48"), wt) end)
c:put(34, 6, "#1a1218") c:put(34, 7, "#2a2018")
-- wax shavings and a lit glint on top
c:put(26, 33, TAL[6]) c:put(27, 33, TAL[6]) c:put(25, 34, TAL[5])
c:sparkle(18, 36)

G.save(c, NAME)
