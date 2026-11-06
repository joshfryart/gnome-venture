-- tomato (lean E2_17)
local NAME = "tomato"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local function ell(cx, cy, rx, ry, a)
  a = a or 0
  local ca, sa = cos(a), sin(a)
  local m = HP.mask()
  for y = floor(cy - max(rx, ry)) - 1, floor(cy + max(rx, ry)) + 1 do for x = floor(cx - max(rx, ry)) - 1, floor(cx + max(rx, ry)) + 1 do
    local dx, dy = x + 0.5 - cx, y + 0.5 - cy
    local u, v = (dx * ca + dy * sa) / rx, (-dx * sa + dy * ca) / ry
    if u * u + v * v <= 1 then m:set(x, y) end
  end end
  return m
end
local function shade(m, ramp, tok, R, amb, wrap)
  local n = X.pillow(m, R)
  G.toneN(c, m, n, ramp, { tok = tok, cuts = CUTS, amb = amb or 0.1, wrap = wrap or 0.2 })
  return n
end
local function dot(x, y, col, tok) c:put(floor(x), floor(y), col, tok) end
local RED = { "#4a0f22", "#7e1a26", "#b52a2a", "#dc4a2e", "#f27a42", "#ffb878" }
local LEAF = { "#173a2a", "#25603a", "#3c8a44", "#62b050", "#98d070" }
c:groundShadow(32, 58, 20, 3)
local m = ell(32, 36, 21, 18)
m:cut(c:rect(31, 17, 33, 19)) -- slight dimple handled by calyx
local t = { r = { name = "fruit" } }
local n = shade(m, RED, t, 20, 0.08, 0.2)
-- lobe creases
for _, x in ipairs{ 20, 44 } do c:line({ {x, 24}, {x - 1 + (x > 32 and 2 or 0), 38}, {x, 51} }, 1):clip(m):each(function(px, py) c:put(px, py, RED[2], t) end) end
local sx, sy = G.specAt(m, n, 22)
if sx then for _, p in ipairs{ {0,0},{1,0},{0,1},{-1,1},{2,1} } do dot(sx + p[1], sy + p[2], RED[6], t) end end
dot(sx + 3, sy + 4, "#ffd8a8", t)
-- calyx star: five pointed sepals
local ct = { r = { name = "calyx" } }
for i = 0, 4 do
  local a = -pi / 2 + (i - 2) * 1.2 + 0.0
  local ex, ey = 32 + cos(a) * 15, 21 + sin(a) * 6 + 3
  local lm, ln, LT, LS = G.blade(32, 21, 32 + cos(a) * 9, 21 + sin(a) * 6 - 2, ex, ey, function(u) if u > 0.97 then return -1 end return max(0.4, 2.8 * sin(pi * min(1, u * 0.95 + 0.05)) ^ 0.7) end, { fold = 0.3 })
  G.toneN(c, lm, ln, LEAF, { tok = ct, cuts = CUTS, amb = 0.1, wrap = 0.2 })
end
ell(32, 21, 3, 2):each(function(x, y) c:put(x, y, LEAF[2], ct) end)
-- stem
local sm = G.tube({ {32,21}, {32,14}, {33,9}, {37,7} }, function(u) return 2.0 - 0.5 * u end)
sm:each(function(x, y) c:put(x, y, x <= 32 and "#8aae48" or "#4e7a30", { r = { name = "stem" } }) end)
dot(32, 12, "#c4e078", ct)
-- quirk: a fat dew drop on the shoulder
for _, p in ipairs{ {44,28,"#ffd8d0"},{45,28,"#ffeee8"},{44,29,"#b8c8e8"},{45,29,"#8aa0d0"},{43,29,"#8aa0d0"} } do dot(p[1], p[2], p[3], t) end
G.save(c, NAME)
