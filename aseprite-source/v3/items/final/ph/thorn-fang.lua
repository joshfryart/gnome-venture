-- NAME (lean E2_16)
local NAME = "thorn-fang"
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

local BONE = { "#5a4a3e", "#8a7662", "#b09c80", "#d2c2a2", "#ece0c4", "#fffaea" }
local BARK = { "#2a1a12", "#4a2c1c", "#6c4228", "#8e5c36", "#b07c4c", "#d0a068" }
local GRN  = { "#1c4a28", "#2c7a34", "#48a844", "#7cd058", "#b8f080" }
c:groundShadow(30, 59, 18, 2)
-- small side thorn
local sm, sn = G.tube({ {18, 54}, {14, 48}, {10, 44}, {8, 38} }, function(t) return 3.2 * (1 - t) ^ 0.8 + 0.2 end)
X.tone(c, sm, X.light(sn, { amb = .12, wrap = .25 }), BONE, { cuts = CUTS, tok = tok() })
-- the big curved fang
local P = { { 18, 55 }, { 10, 28 }, { 32, 12 }, { 52, 12 } }
local fm, fn, FT = G.tube(P, function(t) return max(0.2, 8 * (1 - t) ^ 0.75) end)
local ft = tok()
local idx = X.tone(c, fm, X.light(fn, { amb = .1, wrap = .25 }), BONE, { cuts = CUTS, tok = ft })
-- woody bark base grading into bone
fm:each(function(x, y) local t = FT[K(x, y)] if t and t < 0.3 then
  local i = idx[K(x, y)] or 3
  c:put(x, y, BARK[max(1, min(6, i))], ft) end end)
fm:each(function(x, y) local t = FT[K(x, y)] if t and t >= 0.3 and t < 0.36 then c:put(x, y, BARK[2], ft) end end)
-- growth ridges
for _, t in ipairs{ 0.45, 0.58, 0.7 } do local x, y = bez(P, t)
  local dxp, dyp = bez(P, t + .01)
  for k = -2, 2 do local px, py = floor(x + .5) + k, floor(y + .5) - k * 0 
    if fm:has(px, py) and (px + py) % 2 == 0 then c:put(px, py, BONE[2]) end end end
-- sharp bright tip
c:put(51, 12, BONE[6]) c:put(50, 12, BONE[6]) c:put(49, 13, BONE[5])
-- quirk: a drop of green venom about to fall
shade(c:ellipse(52, 19, 2, 3), GRN, 2, { amb = .3, wrap = .4 })
c:put(52, 15, GRN[3]) c:put(52, 16, GRN[2]) c:put(51, 18, GRN[5])
c:sparkle(44, 8)

G.save(c, NAME)
