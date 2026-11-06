-- NAME (lean E2_16)
local NAME = "tide-bucket"
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

local WOOD = { "#3a2214", "#5a361c", "#7e5028", "#a2703a", "#c4944c", "#e0b86c" }
local METAL = { "#1c3a46", "#2c6070", "#3c8a96", "#62b4b4", "#98d8cc", "#d0f4e4" }
local WATER = { "#1c4a8a", "#2c6ab4", "#3c8ad0", "#68b0e4", "#a4d8f4", "#e8f6fc" }
local CRAB = { "#6a1c14", "#a02c1c", "#d0482a", "#ec7a3c", "#ffa860" }
local ROPE = { "#6a5030", "#9a7a46", "#c4a468", "#e6ce90" }
c:groundShadow(32, 59, 18, 2)
-- rope handle arch (behind)
local hm, hn = G.tube({ {17, 27}, {14, 1}, {50, 1}, {47, 27} }, function(t) return 1.8 end)
local ht = tok()
hm:each(function(x, y) local twist = (x + y) % 4 < 2 c:put(x, y, twist and ROPE[3] or ROPE[2], ht) end)
-- body
local body = c:poly{ {14, 22}, {50, 22}, {46, 56}, {18, 56} }
shade(body, WOOD, 9, { amb = .25, wrap = .35 })
for _, x in ipairs{ 22, 28, 34, 40, 45 } do for y = 24, 55 do
  local lx = floor(x + (y - 38) * ((x < 32) and -0.12 or 0.12) + .5)
  if body:has(lx, y) then c:put(lx, y, WOOD[2]) end end end
-- metal hoops
for _, yy in ipairs{ 31, 47 } do for y = yy, yy + 2 do for x = 12, 52 do
  if body:has(x, y) then c:put(x, y, y == yy and METAL[5] or (y == yy + 1 and METAL[3] or METAL[1])) end end end end
-- water with foam crest
local wm = c:ellipse(32, 22, 18, 5)
shade(wm, WATER, 4, { amb = .3, wrap = .4 })
for _, x in ipairs{ 18, 22, 27, 33, 38, 44 } do c:put(x, 19 + (x % 3), WATER[6]) end
-- rim
for x = 14, 50 do c:put(x, 22, WOOD[5]) end
-- seaweed draped over the left side
local sm, sn = G.tube({ {18, 21}, {10, 26}, {16, 36}, {13, 48} }, function(t) return 1.6 end)
X.tone(c, sm, X.light(sn, { amb = .2, wrap = .3 }), { "#1a3a22", "#285a2c", "#3c8a3c", "#64b048", "#9ae070" }, { cuts = { .25, .5, .75, .9 }, tok = tok() })
-- quirk: little crab peeking over the rim
shade(c:ellipse(42, 19, 5, 3), CRAB, 3)
shade(c:ellipse(36, 14, 2, 2), CRAB, 2) shade(c:ellipse(49, 14, 2, 2), CRAB, 2)
c:put(40, 16, "#1a1218") c:put(44, 16, "#1a1218") c:put(40, 15, "#f6fbff") c:put(44, 15, "#f6fbff")
c:sparkle(23, 36)

G.save(c, NAME)
