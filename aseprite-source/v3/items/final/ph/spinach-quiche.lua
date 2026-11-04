-- spinach-quiche (lean D2o_4)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "spinach-quiche" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(m, ramp, R, o)
  local n = X.pillow(m, R)
  local v = X.light(n, o or { amb = 0.1, wrap = 0.25 })
  local idx = G.tone(c, m, v, ramp)
  return v, idx, n
end
local PLATE = { "#5d6a8a", "#8693b3", "#aeb9d2", "#d3dbea", "#eef2f8" }
local CUST = { "#a8742a", "#cf9a36", "#e9bc4a", "#f4d466", "#fbe892", "#fff6c0" }
local CRUST = { "#5a3418", "#8a5326", "#b5773a", "#d89a52", "#efc07a" }
-- plate
local plate = c:ellipse(32, 47, 25, 9)
shade(plate, PLATE, 9)
c:fillMask(c:ellipse(32, 47, 19, 6), PLATE[4])
c:fillMask(c:ellipse(32, 48, 19, 6):cut(c:ellipse(32, 47, 19, 6)), PLATE[2])
-- wedge top
local top = c:poly{ {32,44}, {14,30}, {18,24}, {26,21}, {38,21}, {46,24}, {50,30} }
local side = top:copy():shift(0, 6):cut(top)
-- sides by depth
side:each(function(x, y)
  local k = 1
  while not top:has(x, y - k) and k < 8 do k = k + 1 end
  local lit = x < 32
  local hx
  if k <= 2 then hx = lit and CUST[4] or CUST[2]
  elseif k == 3 then hx = lit and "#5f9a3a" or "#2f6a2c"
  elseif k == 4 then hx = lit and CUST[3] or CUST[1]
  else hx = lit and CRUST[3] or CRUST[2] end
  c:px(x, y, hx)
end)
-- top filling
local v = X.light(X.pillow(top, 8), { amb = 0.1, wrap = 0.3 })
G.tone(c, top, v, CUST, { 0.18, 0.36, 0.54, 0.72, 0.88 })
top:each(function(x, y)
  local d = sqrt((x - 32)^2 + (y - 44)^2)
  if d >= 20 then
    local band = floor(x / 2) % 2 == 0
    c:px(x, y, d >= 22 and (band and CRUST[4] or CRUST[3]) or (band and CRUST[3] or CRUST[2]))
  else
    local h = X.hash(x, y, 9)
    if h > 0.8 then c:px(x, y, h > 0.93 and "#a6d860" or "#3f8a30")
    elseif h > 0.74 then c:px(x, y, "#2c6a2a") end
  end
end)
-- glossy glint + steam (quirk)
c:px(26, 31, CUST[6]) c:px(27, 31, CUST[6]) c:px(26, 32, CUST[5])
c:fillMask(c:line({ {29,19}, {27,16}, {30,13}, {28,10} }, 1), "#e8eef5")
c:fillMask(c:line({ {37,18}, {39,15}, {36,12}, {38,9} }, 1), "#d3dbea")
G.fin(c, "spinach-quiche")
