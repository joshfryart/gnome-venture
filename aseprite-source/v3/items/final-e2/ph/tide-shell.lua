-- NAME (lean E2_16)
local NAME = "tide-shell"
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

local SH = { "#6a3a3c", "#946054", "#bc8a6c", "#dcb08a", "#f2d4aa", "#fff2d4" }
local PINK = { "#7a2438", "#b04058", "#d8687c", "#f090a0", "#ffc0c4", "#ffe8e4" }
local STR = "#7a4034"
c:groundShadow(32, 58, 20, 2)
-- spire (stacked whorls, upper right)
local W = { { 40, 24, 9, 7 }, { 45, 16, 6, 5 }, { 48, 10, 4, 3 } }
for i = 3, 1, -1 do local w = W[i] shade(c:ellipse(w[1], w[2], w[3], w[4]), SH, w[4]) end
-- siphon tail (lower left)
shade(c:poly{ {18, 44}, {30, 52}, {22, 56}, {8, 56} }, SH, 4)
-- body whorl
local body = c:ellipse(30, 40, 19, 14)
shade(body, SH, 9, { amb = .2, wrap = .3 })
-- spiral grooves
for _, r in ipairs{ 0.5, 0.72, 0.9 } do
  for a = 3.4, 6.1, 0.07 do
    local x, y = floor(30 + cos(a) * 19 * r + .5), floor(40 + sin(a) * 14 * r + .5)
    if body:has(x, y) then c:put(x, y, STR) end end end
-- shoulder knobs
for _, p in ipairs{ {14, 33}, {19, 28}, {26, 26}, {34, 27} } do shade(c:ellipse(p[1], p[2], 2, 2), SH, 2) c:put(p[1] + 1, p[2] + 1, SH[1]) end
-- aperture: flared pink lip with dark throat
local ap = c:ellipse(36, 46, 9, 7)
shade(ap, PINK, 6, { amb = .3, wrap = .35 })
put(c:ellipse(37, 47, 5, 4), "#4a1424")
put(c:ellipse(37, 48, 3, 2), "#2a0c18")
-- quirk: a tiny pearl in the throat and a water droplet
shade(c:ellipse(38, 49, 1, 1), { "#c0b8cc", "#e8e0f0", "#ffffff" }, 1)
shade(c:ellipse(12, 24, 1, 2), { "#2c6ab4", "#68b0e4", "#f0fcff" }, 1)
c:sparkle(24, 30)

G.save(c, NAME)
