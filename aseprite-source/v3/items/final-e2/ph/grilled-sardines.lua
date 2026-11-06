-- grilled-sardines (lean E2_02)
local NAME = "grilled-sardines"
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
c:groundShadow(32, 56, 26, 3)
local SIL  = { "#1e3450", "#2f5470", "#4f84a0", "#86b4c6", "#bcd8e0", "#e8f4f2" }
local PL   = { "#2e3342", "#454c60", "#5f6b80", "#7d8aa0", "#a0adc0", "#c8d2de" }
local LEM  = { "#a8721c", "#d49a1c", "#f0c42a", "#f8dc4e", "#fcec86", "#fff6c0" }
local plate = c:ellipse(32, 45, 27, 11)
shade(plate, PL, 8, "plate")
local inner = c:ellipse(32, 44, 22, 8)
inner:each(function(x, y) px(x, y, y > 45 and PL[3] or PL[2], "plin") end)
-- fish
local body = c:ellipse(30, 32, 19, 8)
local tail = c:poly{ {13,32}, {3,22}, {7,32}, {3,42} }
local fin  = c:poly{ {24,26}, {31,17}, {36,26} }
local fin2 = c:poly{ {30,38}, {34,44}, {37,38} }
local fish = HP.mask(); fish:add(body); fish:add(tail); fish:add(fin); fish:add(fin2)
local idx, n = shade(fish, SIL, 5, "fish")
-- darker back, pale belly
body:each(function(x, y) if y <= 27 then px(x, y, y <= 26 and SIL[1] or SIL[2], "back") end end)
body:each(function(x, y) if y >= 37 and x > 18 then px(x, y, y == 37 and SIL[5] or SIL[6], "belly") end end)
-- scale shimmer
body:each(function(x, y) if y > 28 and y < 36 and x > 22 and (x + y) % 3 == 0 and X.hash(x, y, 5) > 0.5 then px(x, y, SIL[5], "sc") end end)
-- grill char bars
body:each(function(x, y) if x >= 15 and x <= 39 and ((x + y) % 8 < 2) and y > 24 and y < 40 then
  px(x, y, ((x + y) % 8 == 0) and "#2a1810" or "#5a3a22", "char") end end)
-- gill, eye
for yy = 26, 38 do if body:has(41, yy) and abs(yy - 32) > 1 then px(41, yy, SIL[2], "gill") end end
for _, p in ipairs{ {45,29},{46,29},{45,30},{46,30} } do px(p[1], p[2], "#f4f6e0", "eye") end
px(46, 30, "#1a1018", "eye")
-- tail fin streaks
for _, p in ipairs{ {7,26},{6,28},{7,36},{6,38},{5,32} } do px(p[1], p[2], SIL[2], "tf") end
spec(body, X.pillow(body, 5), "#ffffee")
-- lemon wedge (half disc)
local lem = c:ellipse(47, 45, 8, 8); lem:cut(c:rect(0, 0, 63, 45))
shade(lem, LEM, 4, "lem")
lem:shrink(1):each(function(x, y) px(x, y, y > 51 and LEM[3] or LEM[5], "pith") end)
for _, p in ipairs{ {47,47},{47,48},{47,49},{47,50},{43,48},{51,48},{44,50},{50,50} } do px(p[1], p[2], LEM[2], "seg") end
px(44, 47, LEM[6], "sp")
-- steam wisps
for _, p in ipairs{ {44,22},{45,21},{45,20},{44,19},{44,18},{45,17},{50,24},{51,23},{51,22},{50,21},{50,20} } do px(p[1], p[2], "#dfe8ee", "steam") end
G.save(c, NAME)
