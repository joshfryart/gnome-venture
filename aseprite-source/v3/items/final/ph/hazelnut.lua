-- hazelnut (lean E2_02)
local NAME = "hazelnut"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function shade(m, ramp, R, nm, o)
  o = o or {}
  local n = X.pillow(m, R or 4)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = CUTS, tok = { r = { name = nm or "p" } } })
  return idx, n
end
local function px(x, y, col, nm) c:put(x, y, col, { r = { name = nm or "d" } }) end
local function spec(m, n, col)
  local x, y = G.specAt(m, n, 30)
  if x then px(x, y, col or "#fff4dc", "spec") end
end
c:groundShadow(32, 55, 24, 3)
local NUT = { "#2e1a12", "#4e2c1c", "#744324", "#9a5e30", "#c08444", "#e4b068" }
local HUSK = { "#1d3d22", "#2c5a2c", "#418036", "#5fa046", "#86c05a", "#b4dc7c" }
-- twin nut behind
local tw = c:ellipse(45, 43, 9, 10)
shade(tw, NUT, 6, "twin")
tw:each(function(x, y) if (x == 43 or x == 47) and y > 36 and y < 50 and X.hash(x, y, 4) > 0.3 then px(x, y, NUT[2], "st") end end)
for _, p in ipairs{ {48,38},{49,38},{48,39},{49,39} } do px(p[1], p[2], "#ecdcb0", "bite") end
px(49, 39, "#2a1810", "bite")
spec(tw, X.pillow(tw, 6), "#fff0d0")
-- main nut
local nut = c:ellipse(29, 38, 15, 16)
local idx = shade(nut, NUT, 9, "nut")
nut:each(function(x, y) if (x - 29) % 5 == 0 and y > 30 and X.hash(x, y, 2) > 0.35 then px(x, y, NUT[idx[K(x, y)] > 3 and 3 or 2], "st") end end)
-- pale scar
local scar = c:ellipse(29, 52, 8, 3)
scar:each(function(x, y) px(x, y, y > 52 and "#c0a070" or (x < 28 and "#f0e2b8" or "#dcc690"), "scar") end)
spec(nut, X.pillow(nut, 9), "#fff4dc")
-- husk cap
local cap = c:ellipse(29, 27, 17, 10)
for i = 0, 5 do
  local x0 = 13 + i * 5
  cap:add(c:poly{ {x0, 30}, {x0 + 2.5, 37 + (i % 2) * 3}, {x0 + 5, 30} })
end
shade(cap, HUSK, 6, "husk")
cap:each(function(x, y) if y >= 28 and y <= 31 and (x % 5 == 0) then px(x, y, HUSK[1], "tooth") end end)
cap:each(function(x, y) if y < 28 and X.hash(x, y, 7) > 0.8 then px(x, y, HUSK[6], "fz") end end)
-- stem + leaf
local sm, sn = G.tube({ {29,18},{28,13},{30,10},{31,8} }, function(t) return 1.2 end)
G.toneN(c, sm, sn, HUSK, { tok = { r = { name = "stem" } } })
local lm, ln = G.blade(30, 11, 39, 3, 50, 9, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 4.5 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.75) end, { fold = 0.5 })
G.toneN(c, lm, ln, HUSK, { tok = { r = { name = "leaf" } }, amb = 0.1, wrap = 0.25 })
G.save(c, NAME)
