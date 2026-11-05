-- NAME (lean E2_16)
local NAME = "sundial"
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

local STONE = { "#2f2f3d", "#4a4a5e", "#6c6e80", "#8f92a0", "#b4b6bf", "#dcdbd8" }
local SAND  = { "#6a5a50", "#8a7a64", "#aa9a78", "#c8b88e", "#e2d4a6", "#f4ead0" }
local BRONZE = { "#4a2a1c", "#7a4a22", "#a8702c", "#d09a3c", "#ecc45a", "#fff0a0" }
c:groundShadow(32, 58, 20, 3)
shade(c:rect(24, 44, 40, 55), STONE, 5)
for _, x in ipairs{ 28, 32, 36 } do for y = 46, 53 do c:put(x, y, STONE[2]) end end   -- flutes
shade(c:rrect(19, 53, 45, 58, 2), STONE, 3)
-- dial: rim thickness then top face
shade(c:ellipse(32, 41, 23, 10), STONE, 5)
local dial = c:ellipse(32, 37, 23, 10)
shade(dial, SAND, 7, { amb = .3, wrap = .4 })
put(dial:shrink(3):edge(), SAND[2])
-- hour ticks
for i = 0, 10 do local a = pi * (0.1 + i * 0.08) + pi * 1.1
  local x, y = 32 + cos(a) * 19, 37 + sin(a) * 7.6
  c:put(floor(x + .5), floor(y + .5), STONE[1])
end
-- shadow wedge falling lower right
local sh = HP.mask(); sh:add(c:poly{ {32, 38}, {53, 36}, {46, 45}, {36, 45} })
local sm = HP.mask(); sh:each(function(x, y) if dial:has(x, y) then sm:set(x, y) end end)
put(sm, SAND[1])
-- bronze gnomon
local g = c:poly{ {30, 38}, {30, 13}, {41, 37} }
shade(g, BRONZE, 4)
for y = 16, 36 do c:put(30, y, BRONZE[5]) end
c:put(30, 13, BRONZE[6]) c:put(30, 14, BRONZE[6])
-- quirk: snail resting on the rim
shade(c:ellipse(48, 29, 3, 3), { "#5a2a2a", "#8a3c34", "#b45a46", "#d8826a", "#f0a88a", "#ffd8b8" }, 3)
put(c:rect(44, 31, 52, 31), "#c8b090") put(c:line({ {51, 30}, {53, 27} }, 1), "#c8b090")
c:put(48, 29, "#5a2a2a") c:put(49, 28, "#5a2a2a")
c:sparkle(45, 12)

G.save(c, NAME)
