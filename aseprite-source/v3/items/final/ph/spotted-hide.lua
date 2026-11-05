-- spotted-hide (lean E2_08)
local NAME = "spotted-hide"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function blob(m, ramp, name, R, o)
  o = o or {}
  local n = X.pillow(m, R or 3)
  local tok = { r = { name = name } }
  return X.tone(c, m, X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.22 }), ramp, { cuts = CUTS, tok = tok }), n, tok
end
local function put(x, y, col, name) c:put(floor(x + .5), floor(y + .5), col, { r = { name = name or "d" } }) end
local function dots(m, col, name) m:each(function(x, y) c:put(x, y, col, { r = { name = name or "d" } }) end) end

local WOOD = { "#3a2218", "#5e3a26", "#82522f", "#a8703c", "#c8924e", "#e6b878" }
local HIDE = { "#6e3f1c", "#955a26", "#bc7c34", "#dc9f4a", "#f0c070", "#fbe0a0" }
local SPOT = { "#1e0f0c", "#3a1c14", "#582a1c", "#7a3e24", "#9a5632", "#b87444" }
local CORD = { "#8a7a60", "#bfae8c", "#e8dcc0" }
c:groundShadow(32, 57, 19, 3)
blob(c:rrect(18, 47, 23, 56, 1), WOOD, "legL", 2)
blob(c:rrect(41, 47, 46, 56, 1), WOOD, "legR", 2)
local ring = c:ellipse(32, 30, 22, 22)
ring:cut(c:ellipse(32, 30, 18, 18))
blob(ring, WOOD, "hoop", 2.5)
ring:each(function(x, y) if X.hash(x, y, 9) > 0.8 then c:put(x, y, WOOD[2], { r = { name = "grain" } }) end end)
-- hide: bumpy blob inside the hoop (legs flaps at 4 corners)
local hm = HP.mask()
for y = 8, 52 do for x = 8, 56 do
  local dx, dy = x - 32, y - 30
  local a = math.atan(dy, dx)
  local r = 13.5 + 2.2 * sin(a * 4 + 0.7) + 1.2 * sin(a * 9)
  if sqrt(dx * dx + dy * dy) <= r then hm:set(x, y) end
end end
local _, hn, htok = blob(hm, HIDE, "hide", 11, { wrap = 0.3 })
-- laces: cream cords from hide edge to hoop
for k = 0, 9 do
  local a = k * pi / 5 + 0.2
  local pts = {}
  for r = 12, 19 do local x, y = floor(32 + cos(a) * r + .5), floor(30 + sin(a) * r + .5)
    if not hm:has(x, y) then c:put(x, y, (r % 2 == 0) and CORD[2] or CORD[3], { r = { name = "lace" } }) end end
end
local spots = { {27,22,4,3}, {38,25,3,3}, {31,31,3,2.6}, {40,34,3.4,3}, {24,35,3,2.6}, {33,40,2.6,2}, {20,27,2,2}, {32,17,2,2} }
for i, s in ipairs(spots) do
  local sm = c:ellipse(s[1], s[2], s[3], s[4]); sm:clip(hm)
  local tok = { r = { name = "spot" .. i } }
  X.tone(c, sm, X.light(X.pillow(sm, 3), { amb = 0.1, wrap = 0.1 }), SPOT, { cuts = CUTS, tok = tok })
end
-- quirk: one heart-ish spot highlight + a cord tag
put(26,21,SPOT[6]) put(27,21,SPOT[6]) put(37,24,SPOT[6])
for x = 24, 34 do local y = 38 - floor(abs(x - 29) / 3) put(x, 48 - 0, HIDE[1], "x") end
c:sparkle(25, 17)
G.save(c, NAME)
