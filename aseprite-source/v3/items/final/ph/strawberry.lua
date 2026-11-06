-- strawberry (lean W2_31)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "strawberry" }
local RED = { "#5a0f2e", "#8a1535", "#b8203a", "#dc3a3f", "#f2625a", "#ff9a84" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local ltok = { r = { name = "leaf" } }
local Y0, Y1 = 22, 56
local function hw(y)
  local t = (y - Y0) / (Y1 - Y0)
  if t < 0.4 then return 15 * sin(min(1, (t + 0.1) / 0.5) * pi / 2) ^ 0.6 end
  return 15 * ((1 - t) / 0.6) ^ 0.9 + 0.4
end
local b = HP.mask()
for y = Y0, Y1 do local h = hw(y) for x = floor(32 - h + 0.5), floor(32 + h - 0.5 + 1) - 1 do b:set(x, y) end end
local n = X.pillow(b, 10)
local v = X.light(n, { amb = 0.08, wrap = 0.2 })
local bias = {}
X.ao(bias, b, c:rect(26, 18, 38, Y0), 3, -1)
G.tone(c, b, v, RED, { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias)
-- seeds in pits
local inn = b:copy():shrink(2)
for row = 0, 8 do
  for col = -4, 4 do
    local x = 32 + col * 5 + ((row % 2) * 2.5 > 0 and 2 or 0) - 0
    local y = 27 + row * 3.6
    x, y = floor(x), floor(y)
    if inn:has(x, y) and inn:has(x, y + 1) and inn:has(x - 1, y) then
      c:px(x - 1, y, RED[1]) c:px(x - 1, y + 1, RED[2])
      c:px(x, y, "#f5dc7c") c:px(x, y + 1, "#c99a3c")
    end
  end
end
-- glossy spec
c:px(23, 31, "#fff0ea") c:px(24, 31, "#fff0ea") c:px(23, 32, RED[6]) c:px(25, 30, RED[6])
-- cool reflected light lower right
b:edge():each(function(x, y) if x > 36 and y > 34 and y < 50 and X.hash(x, y, 3) > 0.4 then c:px(x, y, "#c0405f") end end)
-- unripe pale tip (quirk)
for _, p in ipairs{ {32,55},{32,54},{31,54},{33,54},{32,53} } do if b:has(p[1], p[2]) then c:px(p[1], p[2], "#f0b79a") end end
-- calyx
local function lf(pts, w)
  local m, nn = G.tube(pts, function(t) return w * sin(pi * min(1, t * 0.85 + 0.12)) ^ 0.7 + 0.6 end)
  G.tone(c, m, X.light(nn, { amb = 0.15, wrap = 0.3 }), LEAF, { 0.2, 0.38, 0.55, 0.7, 0.86 }, nil, ltok)
  return m
end
lf({ {32,23},{24,21},{18,23},{15,28} }, 2.6)
lf({ {32,23},{40,21},{46,23},{49,28} }, 2.6)
lf({ {32,23},{26,25},{22,29},{22,34} }, 2.2)
lf({ {32,23},{38,25},{42,29},{42,34} }, 2.2)
lf({ {32,23},{31,20},{28,18},{27,16} }, 1.8)
-- stem
local sm, sn = G.tube({ {32,22},{32,17},{33,13},{36,10} }, function(t) return 1.8 - 0.6 * t end)
G.tone(c, sm, X.light(sn, { amb = 0.2, wrap = 0.3 }), { "#3b6449", "#5b8d5a", "#88b46e", "#b9d793" }, { 0.3, 0.55, 0.8 })
-- dew drop on left leaf
c:px(19, 25, "#d8f2f0") c:px(20, 25, "#9ad0d4") c:px(19, 26, "#6aa8b8")
G.fin(c, "strawberry")
