-- NAME (lean E2_16)
local NAME = "tamarind"
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

local POD = { "#2e1a14", "#4a2c1e", "#6c4430", "#8e6244", "#b08460", "#d2aa82" }
local PUL = { "#3a1408", "#5e2210", "#8a3a1a", "#b0582a", "#d07a3c", "#ec9c58" }
local SEED = { "#2a100c", "#4a1c14", "#6c2c1c", "#8e4428", "#b0643c", "#e0a070" }
local P = { { 9, 41 }, { 11, 4 }, { 49, 2 }, { 55, 40 } }
c:groundShadow(32, 58, 18, 2)
local pm, pn, PT = G.tube(P, function(t) return max(1.2, (5.2 * sin(pi * (0.08 + 0.84 * t)) ^ 0.5) + 0.9 * sin(t * pi * 8)) end)
local idx = X.tone(c, pm, X.light(pn, { amb = .12, wrap = .25 }), POD, { cuts = CUTS, tok = tok() })
-- scurfy shell texture
pm:each(function(x, y) if X.hash(x, y, 9) > 0.86 then c:put(x, y, POD[max(1, (idx[K(x, y)] or 3) - 1)]) end end)
-- cracked window: sticky pulp and seeds
local win = HP.mask(); pm:each(function(x, y) local t = PT[K(x, y)] if t and t > 0.4 and t < 0.64 then win:set(x, y) end end)
shade(win, PUL, 4, { amb = .2, wrap = .3 })
for i, t in ipairs{ 0.44, 0.52, 0.6 } do
  local x, y = bez(P, t)
  shade(c:ellipse(floor(x + .5), floor(y + .5), 2, 3), SEED, 2)
  c:put(floor(x - .5), floor(y - 1), "#ffe8c8")
end
win:edge():each(function(x, y) if pm:has(x, y) then c:put(x, y, POD[1]) end end)
-- stalk nub at the left end and a sticky drip
put(c:rect(7, 41, 10, 45), POD[2]) c:put(8, 42, POD[4]) c:put(7, 45, POD[1])
local dx, dy = bez(P, 0.52)
shade(c:ellipse(floor(dx + .5), floor(dy) + 9, 1, 2), PUL, 1)
c:put(floor(dx + .5), floor(dy) + 8, PUL[5])
c:sparkle(40, 10)

G.save(c, NAME)
