-- tomatillo (lean D3o_5)
-- A green sticky fruit peeking out of its papery lantern husk: ribbed tan husk with five scalloped lobes,
-- fruit showing between the lobes, curled stem tip.
-- quirk: one husk lobe is torn and curled up.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tomatillo" }
local sin, cos, pi, sqrt, abs, floor, max = math.sin, math.cos, math.pi, math.sqrt, math.abs, math.floor, math.max
local function sh(m, ramp, R, amb, wrap, bias, tok)
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = amb or 0.1, wrap = wrap or 0.25 })
  G.tone(c, m, v, ramp, nil, bias, tok)
  return n, v
end
local TG = { "#2a4a2c", "#40692f", "#5f9238", "#88b840", "#b4d85a", "#e2f290" }
local TAN = { "#5e4630", "#8e7048", "#bf9e62", "#dcc486", "#efdcaa", "#fff4d0" }
-- fruit
local fruit = c:ellipse(32, 43, 14, 12)
local fn, fv = sh(fruit, TG, 11, 0.06, 0.25)
fruit:each(function(x, y) if X.hash(x, y, 3) > 0.93 and fv[K(x, y)] > 0.5 then c:px(x, y, TG[6]) end end)
c:px(26, 38, "#fffff0") c:px(27, 38, "#fffff0") c:px(25, 39, TG[6])
-- husk
local function bottom(x) return 50 - 7 * abs(sin((x - 32) * pi / 11)) end
local husk = HP.mask()
for y = 13, 50 do for x = 14, 50 do
  local u = (y - 33) / 20
  local hw = 17 * (1 - abs(u) ^ 2.2) ^ 0.62
  if y < 33 then hw = 17 * (1 - abs(u) ^ 1.9) ^ 0.75 end
  if abs(x - 32) <= hw and y <= bottom(x) then husk:set(x, y) end
end end
local hn, hv = sh(husk, TAN, 9, 0.2, 0.35)
husk:each(function(x, y) local h = X.hash(x, y, 9) if h > 0.92 then c:px(x, y, TAN[5]) elseif h < 0.05 then c:px(x, y, TAN[2]) end end)
-- ribs
for _, ex in ipairs{ 21, 26.5, 32, 37.5, 43 } do
  local pts = { {32, 15}, {32 + (ex - 32) * 0.5, 26}, {32 + (ex - 32) * 0.9, 38}, {ex, bottom(ex) - 1} }
  c:line(pts, 1):each(function(x, y) if husk:has(x, y) then c:px(x, y, TAN[2]) end end)
  local p2 = {}
  for i, p in ipairs(pts) do p2[i] = { p[1] - 1, p[2] } end
  c:line(p2, 1):each(function(x, y) if husk:has(x, y) and hv[K(x, y)] > 0.55 then c:px(x, y, TAN[5]) end end)
end
-- cross veins
for _, yy in ipairs{ 24, 31, 38 } do
  for x = 17, 47 do if husk:has(x, yy + floor(sin(x * 0.9) + 0.5)) and X.hash(x, yy, 5) > 0.6 then c:px(x, yy + floor(sin(x * 0.9) + 0.5), TAN[3]) end end
end
-- shade under lobes onto fruit
for x = 16, 48 do local b = bottom(x) if husk:has(x, floor(b)) then c:px(x, floor(b), TAN[1]) end end
-- torn curled lobe (quirk) at right tip
c:px(44, 49, TAN[5]) c:px(45, 48, TAN[6]) c:px(45, 47, TAN[3]) c:px(44, 47, TAN[1])
-- stem
local sm, sn = G.tube({ {32, 15}, {32, 12}, {33, 9}, {36, 8} }, function(t) return 1.8 - 0.7 * t end)
G.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), { "#4a5a2c", "#6a8038", "#9ab04c", "#c8d878" }, { 0.3, 0.55, 0.8 })
G.fin(c, "tomatillo")
