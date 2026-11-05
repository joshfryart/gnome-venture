-- tomatillo (lean E2_17)
local NAME = "tomatillo"
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
local HUSK = { "#5e4a2a", "#8a6f3e", "#b49a5c", "#d4be80", "#ead9a2", "#f8efc8" }
local FRUIT = { "#1c4a2a", "#2a6a30", "#44903a", "#6cb648", "#9ad46a", "#d4f09a" }
c:groundShadow(32, 58, 17, 3)
local fm = ell(32, 44, 14, 12) local ft = { r = { name = "fruit" } }
local fn = shade(fm, FRUIT, ft, 12, 0.1, 0.2)
local fx, fy = G.specAt(fm, fn, 24) if fx then c:put(fx, fy, FRUIT[6], ft) c:put(fx + 1, fy, FRUIT[5], ft) end
-- husk lantern
local hm = ell(32, 31, 19, 20)
hm:add(c:poly{ {26,16},{38,16},{32,6} })
local cut = HP.mask()
for x = 10, 54 do local zig = 45 + ((floor(x / 3) % 2 == 0) and 0 or 3) cut:add(c:rect(x, zig, x, 62)) end
hm:cut(cut)
local ht = { r = { name = "husk" } }
local hn = shade(hm, HUSK, ht, 17, 0.08, 0.25)
-- ribs from the tip to the rim
for _, off in ipairs{ -15, -8, 0, 8, 15 } do
  local pts = { {32,10}, {32 + off * 0.9, 24}, {32 + off * 1.1, 36}, {32 + off, 48} }
  c:line(pts, 1):clip(hm):each(function(x, y) c:put(x, y, off <= 0 and HUSK[2] or HUSK[3], ht) end)
end
-- papery veins between ribs
hm:each(function(x, y) if X.hash(x, y, 9) > 0.93 and y > 18 then c:put(x, y, HUSK[2], ht) end end)
local hx, hy = G.specAt(hm, hn, 30) if hx then c:put(hx, hy, HUSK[6], ht) end
-- stem
local sm = G.tube({ {32,8}, {32,4}, {35,2}, {38,3} }, function(t) return 1.6 - 0.4 * t end)
sm:each(function(x, y) c:put(x, y, x <= 32 and "#7a8a3a" or "#566a2c", { r = { name = "stem" } }) end)
-- quirk: husk is torn, one drip of sticky sap
for _, p in ipairs{ {47,50,FRUIT[4]},{47,51,FRUIT[3]},{47,52,FRUIT[5]} } do dot(p[1], p[2], p[3], ft) end
G.save(c, NAME)
